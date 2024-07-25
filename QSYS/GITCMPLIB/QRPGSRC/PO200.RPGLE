500 A /COPY *libl/qcopysrc,hspecs
700cAH dftactgrp(*NO) actgrp(*NEW)
500hA*----------------------------------------------------------------
500hA*  Multilingual Verision
500hA*  Every screen and message has a corresponding Spanish version.
500hA*  Any changes must be made to both languages.
500hA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO200     RF receiving.
     *  25 November 1996
     *  Roxanne Harrison/Dave Sommerville
     *
     *  Notes
     *
     *       If you change this program, check to see if RC180 should
     *       get the same changes.
     *
     *       8 X 20 Screens for hand held scanners
     *       UPC code must be right adjusted.
     *       LFLAG on = enter license plate
     *
500hA*----------------------------------------------------------------
     *  Revisions
     *
218 A*    01/13/97  RH   2.18
     *      - Update PODTL file in RC160.
     *      - Call RC160 with Parm $RSEQ, $RRPCK, $RPLBL
     *      - Use CHECK(ER) to act as enter key for UPC scan.
     *      - Remove check to allow multiple UPC per vendor/item.
     *
218 A*    02/04/97  RH   2.18
     *      - Add expiration date based on ITFLGD
     *      - Remove breakdown qty1 from screen3.
     *
219 A*    03/11/97  RH   2.19
     *      - Add Catch weight and Average fields to screen 3
     *      - Protect & non-display catch weight & average if ITCWGT<>Y.
     *      - Added catch weight W2DWGT to PARMs.
     *      - Catch weight is required.
     *      - Update POHDR status , 1=partial, 2=full, 0=open .
221 A*    05/14/97  RH   2.21
     *      - Add OPPLCN use generic license option to set LFLAG.
     *      - Change to use W1WHSE not #WHSE.
     *      - Change to not lock POHDR records until ready to update.
     *
415 A*    03/11/01  DAS  4.15
     *      - Brought up-to-date.
     *      - Removed dock from screen 1.
     *      - Added warehouse to screen 1.
     *      - Changed screen 3 to only get quantity and number of
     *        pallets for manual putaway.
     *      - Added screen 8 to get exp/mfr date and weight.
     *      - Replaced call to screen 7 with calls to PO136 and
     *        PO236, the standard license plate entry programs.
     *
415aA*    03/14/01  DAS  4.15a
     *      - Revised ZZCHK2 to update WOLINE and WOITM# when item
     *        is found.
     *      - Revised SC3, SC5 and SC6 to call ZZCMD* with *BEFORE
     *        and *AFTER.
     *
415bA*    03/19/01  DAS  4.15b
     *      - Revised to use FRMTIT2 instead of FRMTIT. This will
     *        format the item string as Desc/Pack/Item#.
     *
415cA*    03/22/01  DAS  4.15c
     *      - Revised ZZCHK3 to make sure qty > 0.
     *
415dA*    03/06/01  RH   4.15d
     *      - Allow Use by date to be entered in expire date field.
     *      - Calculate to verify use by date item can be received.
     *
415eA*    03/28/01  DAS  4.15e
     *      - Increased length of UPC field to 50.
     *      - Added logic to decipher/verify UPC entry.
     *
415fA*    03/29/01  DAS  4.15f
     *      - Created second set of screens for 16-Line displays.
     *      - Created input parameter to identify which one to use.
     *      - Added more information to larger screens.
     *
415gA*    03/29/01  DAS  4.15f
     *      - Moved check for marked PO from ZZCHK1 to ZZCHK2.
     *      - Added F8=Mark/Unmark to screen 2.
     *
415hA*    04/03/01  DAS  4.15h
     *      - Added qty ordered to screen 3.
     *
415iA*    04/16/01  DAS  4.15i
     *      - Moved call to ZZLCNS from ZZINZ2 to ZZUPD1.
     *
415jA*    04/17/01  DAS  4.15j
     *      - Brought ZZUHDR routine up-to-date.
     *
415kA*    06/13/01  DAS  4.15k
     *      - Renamed $PLINE to #LLINE.
     *      - Changed to get #LLINE from a called program instead of
     *        being passed into program as parameter.
     *
415lA*    06/20/01  DAS  4.15l
     *      - Revised ZZCHK8 to do a better job of checking for a
     *        zero mfr date.
     *      - Commented line that moved 0 to W1EXDT.  This was putting
     *        zero in exp date field of slot file, when they take F20
     *        to override the warning.
     *
     *
415mA*    06/25/01  DAS  4.15m
     *      - Date variables not being initialized correctly.
     *
415nA*    08/24/01  DAS  4.15n
     *      - Revised ZZUOM to display correct uom for SSB items.
     *      - Revised ZZGETI to get home slot for base item when
     *        item type is 'A', 'C' or 'S'.
     *
416aA*    09/25/01  DAS  4.16a
     *      - Revised to use new receiving option for expiration dates
     *
416bA*    09/26/01  DAS  4.16b
     *      - Revised to use new receiving options for catch weights.
     *
416cA*    09/26/01  DAS  4.16c
     *      - Added file ITMEXCP.
     *      - Write record to ITMEXCP when exp date override taken.
     *
416dA*    10/06/01  DAS  4.16d
     *      - Revised to allow average to be selected when doing
     *        "First time only" catch weight entry.
     *      - Added file POCTYPE to track catch weight entry type.
     *      - Added routine ZZZCW to calculat catch weight.
     *
416eA*    01/10/02  MLB  4.16e
     *      - Revised program to receieve 4 new parms on the call
     *        to GETPSLT.
416fA*    05/23/02  RRH  4.16f
     *      - Change W7LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
416gA*    07/02/02  RH   4.16g
     *      - Recompiled, ITEMMSC changed.
416hA*    07/18/02  MLB  4.16h
     *      - Enh: Added call to pgm APICVTITM to extract item number
     *             out of data scanned in. Revised routines: SC5, ZZCHK5,
     *             ZZINZ.
416iA*    07/18/02  MLB  4.16i
     *      - Fix: Corrected field name on W3QT02 qty test in ZZCHK3.
     *
417 A*    03/20/03  MLB  4.17
     *      - Fix: Revised routine ZZPDIR to write out exception
     *        record when expiration date is overridden. See
     *        original mod 4.16c.
417aA*    04/02/03  RH   4.17a
     *      - Add code to check expiration date using # of days out.
     *      - ITEMMSC file changed.
417bA*    04/09/03  RH   4.17b
     *      - Check for multiple items for UPC, display error.
417cA*    04/15/03  MLB  4.17c
     *      - Enh: Add call to Retail UPC prompt program. This program
     *        will verify if Retail UPC is on file.
     *      - Added 3 new fields to *RCVLVL. OPRUPC, OPRUPS and OPRUPF.
417eA*    04/21/03  RH   4.17e
     *      - Change- allow override for #of days out from expiration
     *      - Enh: Create exception record if expire date override.
417fA*    04/28/03  MLB  4.17f
     *      - Revised ZZCHK7 to use *LEFTNOZ for call to ADJUST.
417gA*    06/25/03  RH   4.17g
     *      - Fix: Do not allow entry of special characters in license
     *             entry field.
417hA*    07/02/03  MLB  4.17h
     *      - Enh: Add support for lot/license tracking.
417iA*    07/02/03  MLB  4.17i
     *      - Enh: Add support for lot code entry.
417jA*    06/04/03  RH   4.17j
     *      - FIX:ODOVR date override was left on after first time in.
417kA*    07/22/03  RH   4.17k
     *      - FIX:Move code to calculate CKEXDT, was not calculated
     *            in some cases.
417lA*    11/14/03  MLB  4.17l
     *      - Enh: Revised $RPARM DS to add two new fields,
     *        $RFSLP and $RTSLP.
417mA*    02/26/04  RH   4.17m
     *      - ENH:Call RC160 with $RFIFO
417nA*    08/11/04  RH   4.17n
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
     *
500 A*    04/02/05  DAS  5.00
     *      - ENH:Added parms to PO136/PO236 calls.
     *      - ENH:Revised for Directed receiving to always call PO136.
     *
500cA*    02/06/06  RH   5.00c
     *      - ENH: Add OBOVR flag to write exception when F20 ovrride
     *        is taken for mfg date error.
     *        Change CWOVR field used to OAOVR field for clarity.
500dA*    04/02/05  DAS  5.00d
     *      - Revised to use CLCDUR2 instead of julian routines.
     *        (This was a 417r change in PO232)
     *      - Recalculate EXPD in ZZUPD8 routine for Mfr dated items.
     *        (This was a 416i change in PO232)
     *
500eA*    10/11/05  RH   5.00e
     *      - ENH: Revised to chain to POMFR1 with label#, update
     *        existing record if found.  Problem POMFR records
     *        already existing when label# have cycled around again
     *        and having previous item's expiration date info.
500fA*    02/14/06  RH   5.00f
     *      - FIX: Fix F10 override for MFGDTE, was always getting
     *        reset and rechecking for expiration and mfg dates.
500gA*    03/16/06  RH   5.00g
     *      - FIX: Was not doing edit for MFGDTE after 1st time,
     *        was putting 0 MFGDTE and EXPDTE in POMFR record.
     *
500hA*    06/03/06  JCJ  5.00
     *      - Added Multilingual logic.
510aA*    10/11/06  RH   5.10a
     *      - Enh: Add support for Client id.
510cA*    10/12/06  RH   5.10c
     *      - Enh: Revised program to send date keyed in in place
     *        of Mfg date parm.
510dA*    10/26/06  RH   5.10d
     *      - Fix: Initialize license date fields, was writing for
     *        non-dated item.
510eA*    12/27/06  RH   5.10e
     *      - Enh: Write different exception for each date override.
     *        Add OEOVR and OFOVR flags, each override sets a flag.
510fA*    03/14/07  RH   5.10f
     *      - Enh: Change to use PO20001 F10 override in place of
     *        PO13231 F20 override.
510gA*    10/01/07  LMC  5.10g
     *      - Enh: Added f11 for mfrdate decipher
510hA*    10/01/07  LMC  5.10h
     *      - Fix: If the user didn't enter the manufacturing date the
     *        program continued to the call to calculate expiration
     *        date and that program was blowing up because of invalid
     *        data being passed on the zero date
510iA*    10/09/07  LMC  5.10i
     *      - Enh: Added upc code for decipher lookup
510jA*    10/12/07  LMC  5.10j
     *      - Enh: Added call to MF200 with *open to determine if the
     *        date code decipher programs exist on the client site.
510kA*    12/04/07  LMC  5.10k
     *      - Enh: Write ITMEXCP record if invalid date is returned
     *        from the date code decipher programs.
510lA*    01/13/08  LMC  5.10l
     *      - Enh: Cmd11 - only valid on date sensitive items
610aA*    08/24/09  RH   6.10a
     *      - Enh: Add F7=Mark line as touched (with 'X')
     *      - Rename PO200FM to PO20001
610bA*    08/25/09  RH   6.10b
     *      - Change to use field to display choice Y,N or 1,9.
530aA*    08/05/10  RH   5.30a
     *      - Fix: Read to get correct seq # if entered on SC5.
     *        Was alwasy getting first seq# for item.
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
640bA*    07/13/12  LMC  6.40b
     *      - Enh: return decipher code to pass to licinfo file
     *      - Fix: found mods 530b in po232 applied as 640b to fix
     *        data being passed to MF200.
640dA*    09/20/12  RH   6.40d
     *      - Enh: Change to use wk field to pass mfg shelf life days
     *        to allow use of other values to be used in calculations
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
     *
650aA*    04/02/13  RBD  6.50a
     *      - Problem: Sporadically, PO's were being received with no c/w
     *        written to PODTL even though c/w was in fact being entered.
     *      - Scenario: User enters c/w which falls into the acceptable
     *        range and blanks out Average Y/N (W8AVG) which turns on
     *        error, but then subr zzchkt sets off error and W8AVG goes
     *        into zzzcw as blank. Note, qty recv'd, whether they enter
     *        the full qty ordered or not, has no impact.
     *      - Fix: In the above scenario, W8AVG was allowed to be blank,
     *        then in subr zzzcw value cwcalc was not getting populated,
     *        which in turn kept w1twgt from getting populated, then
     *        w1twgt would get passed to PO236 as 0. The culprit was in
     *        subr zzchkt, it should not have been setting off error.
     *
650bA*    03/22/13  LMC  6.50b
     *      - Ehn: Added UCI/GS1 processing in process
     *        Temporary changes for parms to PO236, will be updated
     *        when UCI changes are completed.
650cA*    05/20/13  LMC  6.50c
     *      - Ehn: Added RCVPO processing
650dA*    09/20/13  LMC  6.50d
     *      - Ehn: Added temporary changes for parms to PO236/PO136
     *        for PTI
650eA*    12/13/13  LMC  6.50e
     *      - Fix: RCVPO was being left at ended status - need to do
     *        RCVPO check from upc screen
650fA*    01/02/14  RBD  6.50f
     *      - Fix: Fields holding low/high var were not getting cleared,
     *        if an item had zero var but the previous item did not, the
     *        var for the last item was used instead of the system var.
     *      - Fix: Copied from PO232/520d.  Revised program to process
     *        catchwgt variance first time when no qty has been received
     *        when Catchwgt Option set to 2=First time only.
     *
650g *    04/15/14  RTR  6.50g
     *      - Enh: Added status 5 for import error from PI265S
650h *    06/05/14  LMC  6.50h
     *      - Enh: Pass empty parm to PO236 for new OSS Receiving.
650iA*    12/31/14  MLB  6.50i
     *      - Fix: Revised routine ZZCHK2 to add code to correct count
     *        for multiple items attached to same UPC code.
     *      - Added file UPC4 to pgm.
     *
700aA*    12/04/15  NLK  7.00a
     *      - Fix: Error Entering EACH qty discovered by Presto
     *        Err when 0 for w3qt01 with good qty in w3qt02
     *
700bA*    03/21/16  LMC  7.00b
     *      - Enh: Adding logic for Metric.
     *      - Fix: PODTLM - chain was using fileky, klist was whse/po
     *        would get the first record for the po in the podtlm file
     *        changed to use the  record for the po in the podtlm file
     *      - Fix: F10/F20 override was not allowed if there was a
     *        date warning for Chef's. Was missing a line of code that
     *        should not allow override on wtchk only.
     *      - Fix: When backing up from screen 8, the following fields
     *        were not getting reset.
     *        dtchk dtchk2 dtchk3 dtchk4 wtchk.
     *        Added the reset of these fields to scr08i
700cA*    09/08/16  LMC  7.00c
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display after screen6 if a upc is being
     *        verified for load. the screen to capture breakdowns will
     *        come after that. if a upc already exist, and no verify
     *        screen is displayed, the screen to capture breakdown upc
     *        codes will be displayed.....????
     *      - We will assume the normal uom upc is being recorded with
     *        the existing upc screens. New fields will be loaded as
     *        the normal uom.
700dA*    10/12/16  LMC  7.00d
     *      - Fix: RCVPO transaction was missing po#
710aA*    01/18/17  LMC  7.10a
     *      - Enh: Do Not allow Super PO to be used.
     *        The super PO logic doesn't exist in RF receiving, so
     *        we will edit for this and not allow the user to move
     *        forward if a super po is entered on screen 1.
720aA*    10/12/18  LMC  7.20a
     *      - Enh: Before calling PO236 for license plates, we need
     *        to print box labels if item is coded for printing
740aA*    02/04/20  LMC  7.40a
     *      - Enh: Use the UOM from the $item.
740bA*    01/24/20  LMC  7.40b
     *      - Enh: Added UCI Receiving functionality.
740cA*    03/30/20  LMC  7.40c
     *      - Enh: Edits for # of days out should not apply for
     *        Manufacturer dated items. Only if Expiration date
     *        is entered.
740dA*    04/03/20  LMC  7.40d
     *      - Enh: When adding the uci receiving, I disabled the
     *        loading of UPC's. putting that function back in before
     *        the call to the uci program.
740eA*    05/11/20  LMC  7.40e
     *      - Enh: Increased uci field from 50 to 70.
     *        Some international barcodes are longer than the
     *        guidelines of 48 characters.
     *      - Enh: Added uc920 if same upc exists for multiple items.
740fA*    05/22/20  LMC  7.40f
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740gA*    05/26/20  LMC  7.40g
     *      - Enh: Move the upc selection load to upitem within the
     *        endif.
750a *    06/01/21  LMC  7.50a
     *      - Enh: CW variances for breakdown were not being
     *        calculated.
760a *    05/10/22  LMC  7.60a
     *      - Enh: Don't load field woupc if the receiving
     *        option OPNUPC is set to Y, to not allow upc's to be
     *        loaded during receiving.
760b *   07/11/22  LMC  760b
     *     - The host system FRESHBYTE requires a lot code.
     *       They tell us the lot code is the po&line number
     *       On a email today 7/11/22 they said the lot# was
     *       9 positions, 6 for po with leading zeros and 3 for line
     *       I am assuming the 3 positions for line# should have a
     *       leading zero also. so po 000300001 300 is po line 1.
770aA*   08/27/22  TDC  7.70a
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *----------------------------------------------------------------
     *  Custom
ISYaA*    10/11/06  RH   ISYa
     *      - Enh: Force to 16 line version.
     *
ISYbA*    03/19/19  RBD  ISYb
     *      - Enh: Force to 8 line version per Todd.
     *
     *----------------------------------------------------------------
     * Saval Custom Mods
     *
SVLaA*   07/22/09  RH   SVL
     *     - Default # of pallets to 1 on screen 3
SVLbA*   08/22/09  RH   SVLb
     *     - Default Y/N field to '9'
     *----------------------------------------------------------------
     * YHata's Custom Mods
YHAaA*   09/20/12  RH   YHAa
     *     - Calculate pack date for Date senstitive only item using  tion
     *       # of days out - 1. Store in LICINFO code *MFGDTE         tion
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    12/30/13  RBD  DRYa
     *      - These revs are replicated from PO232/DRYc and DRYf.
     *      - Force the following options' values as follows:
     *        'Force catch weight entry' = Y
     *        'Allow catch weight entry' = 2 (First receipt only)
     *        'Catch weight value to enter' = 2 (Total)
     *      - Use imported weight, PODTLM/pdmms1 pos 9-15, for editing instead
     *        of itswgt.
     *      - If imported wgt is not numeric, use standard comparison tests.
     *      - Do not allow user to override catchweight entered.
     *      - Item received must pass 2 different tests.
     *        1. Calc the unit wt difference between what was ordered
     *           and received, and divide it by the ordered unit weight
     *           to get the tol%.  If tol% >= high var, throw hard halt.
     *        2. If there is a brkdn 1 qty ordered or received, calc the
     *           qty diff between ordered and received and divide it by
     *           qty ordered to get the tol%.  If tol% >= high var, throw
     *           hard halt.
     *      - Note: it doesn't matter whether we compare tol% to low or
     *        high var, at Dairyland they're always the same per Laury.
     *      - Includes conversion breakdown logic as they can import
     *        weight for one u/m and then receive the item in the same
     *        and/or different units of measure.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
510jA*  66        Date Code Decipher check to non display cmd11
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
610aDF*o200fm   cf   e             workstn
700bDF*po20001   cf   e             workstn
700cDF*po20002   cf   e             workstn
740eDF*po20003   cf   e             workstn
740eMFpo20004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
     FLabel2    if   e           k disk
219 D*OHDR   IF  E           K        DISK
219 MFpohdr     uf   e           k disk
     Fpodtl1    if   e           k disk
     F                                     rename(pdrec:record)
     Fpodtl     if   e           k disk
415fAFpodtl3    if   e           k disk
     F                                     rename(pdjrec:ptouch)
DRYaAFpodtlm    if   e           k disk
     Fupc       uf a e           k disk
     *PC1    IF  E           K        DISK
     *           UPREC                             KRENAMERECUP1
700cAFupc1      if   e           k disk    prefix(u1_)
700cAF                                     rename(uprec:u1rec)
650iAFupc4      if   e           k disk
650iAF                                     rename(uprec:uprec4)
     FLicense   uf a e           k disk
221 AFoptions   if   e           k disk
415 AFoptiond   if   e           k disk
415 AFitemmsc   if   e           k disk
416dAFpoctype   uf a e           k disk
610aDF*orcv     o  a e           k disk
610aMFporcv     uf a e           k disk
500eDF*omfr     o    e             disk
500eAFpomfr1    uf a e             disk
416cAFitmexcp   o    e           k disk
710aAFpospo     if   e           k disk
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
415 D**                  DESC    1   2 50
417gD**                  DESC    1   5 50
DRYaDD*desc            s             50    dim(6) ctdata perrcd(1)
710aDD*desc            s             50    dim(7) ctdata perrcd(1)
710aMD desc            s             50    dim(8) ctdata perrcd(1)
416bAD cwt             s              3    dim(2) ctdata perrcd(1)
DRYaDD*descsp          s             50    dim(6) ctdata perrcd(1)
710aDD*descsp          s             50    dim(7) ctdata perrcd(1)
710aMD descsp          s             50    dim(8) ctdata perrcd(1)
500hAD cwtsp           s              3    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
416cAD                 ds
416cAD  dspo                   1      9
416cAD  dslbl                 10     16  0
416cAD  dsexpd                17     24  0
416cAD  dsfdis                 1     12
416cAD  dstdis                13     24
409 A*
     *----------------------------------------------------------------
219 A* Data structure
219 A*
219 AD opdata          ds
415 AD  optlen               117    117
415 A*----------------------------------------------------------------
415 A*  *SYSTEM  -  System options.
415 A*----------------------------------------------------------------
415 A*
415 A* Fields
415 A*
415 A*    OPEPM   -  Using EPM module (Y,N).
415 A*    OPRF    -  Using RF module (Y,N).
415 A*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
415 A*    OPLETD  -  Print letdown labels (Y,N).
415 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
415 A*    OPRG1C  -  Catch weight low variance percentage.
415 A*    OPRG2C  -  Catch weight high variance percentage.
415 A*    OPIMPI  -  Import item fields from host.(Y,N).
415 A*    OPICW   -  Individual catch weight entry (Y,N).
415 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
415 A*    OPRCDY  -  Number of days to keep receiving logs.
415 A*    OPMPCK  -  Number of days to keep picking logs.
415 A*
415 A* Data structure
415 A*
415 AD sydata          ds
415 AD  opepm                  1      1
415 AD  oprf                   2      2
415 AD  opcapc                 3      3
415 AD  opletd                 4      4
415 AD  opwrnc                 5      5
415 AD  oprg1c                 6      8  1
415 AD  oprg2c                 9     11  1
415 AD  opimpi                12     12
415 AD  opicw                 13     13
415 AD  opmpck                14     14
415 AD  oprcdy                15     15  0
415 AD  oppkdy                16     16  0
770aAD  opdckv                50     50
415 AD  sysend               117    117
415 A*----------------------------------------------------------------
415 A*  *RCVLBL  -  Receiving options
417cA*
417cA*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
417cA*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
417cA*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
760aA*    OPNUPC  -  Do Not allow UPC's to be loaded during receiving
417cA*
415 A*----------------------------------------------------------------
415 AD rcdata          ds
221 AD  oplpgm                 1     10
221 AD  opupct                11     13  0
221 AD  oppdef                14     14  0
221 AD  oppbld                15     15  0
221 AD  oppact                16     16  0
221 AD  opfdef                17     17  0
221 AD  opfasl                18     18  0
221 AD  opfsid                19     19  0
221 AD  opflvl                20     20  0
221 AD  oppasl                21     21  0
221 AD  oppfrc                22     22
221 AD  opplcn                23     23
415fAD  oppchm                24     24
415fAD  oppmix                25     25
415fAD  opapck                26     26
415fAD  opfrcm                27     27
416aAD  opexck                28     28
416bAD  opcwen                29     29
416bAD  opcwtp                30     30
416bAD  opcwfr                31     31
417cAD  opipck                32     32
417cAD  oprupc                33     33
417cAD  oprups                34     34
417cAD  oprupf                35     35
760aAD  opnupc                62     62
219 AD  optend               117    117
415 A*----------------------------------------------------------------
415 A*  *PICK  -  Picking options
415 A*----------------------------------------------------------------
415 A*
415 A* Fields
415 A*
415 A*    OPNXTP  -  Next pallet number.
415 A*    OPBPCK  -  Bulk pick definition.
415 A*    OPPCUB  -  Maximum cube for PIR.
415 A*    OPFPAL  -  Pallets on fixed fork lift.
415 A*    OPFCUB  -  Maximum cube per fixed pallet.
415 A*    OPFSTP  -  Maximum stops per fixed pallet.
415 A*    OPINCL  -  Include PIR in fixed cube.
415 A*    OPSRCH  -  Number of previous pallets to search for space.
415 A*    OPFBLD  -  Fixed pallet building method.
415 A*                1 = By piece without concern for splitting stop.
415 A*                2 = By stop without splitting stop between plts.
415 A*    OPPBRK  -  Break pallets by aisle (Y,N).
415 A*    OPMPUT  -  Manual Put away (Y,N).
415 A*
415 A* Data structure
415 A*
415 AD opddta          ds
415 AD  opnxtp                 1      7  0 inz(0)
415 AD  oppcub                10     14  2 inz(0)
415 AD  opfpal                15     15  0 inz(0)
415 AD  opfcub                16     20  2 inz(0)
415 AD  opincl                22     22
415 AD  opsrch                23     24  0 inz(0)
415 AD  opfstp                25     26  0 inz(0)
415 AD  opfbld                27     27  0 inz(0)
415 AD  opbpck                28     30  0 inz(0)
415 AD  oppbrk                31     33
415 AD  opmput                34     34
415 AD  opdend               117    117
740bA*----------------------------------------------------------------
740bA*  Convert Barcode Parms
740bA*----------------------------------------------------------------

740bA /COPY *libl/qcopysrc,C#CVTPARMS
740bA /COPY *libl/qcopysrc,C#BARCODE
417gA*----------------------------------------------------------------
417gA*  Name constants
417gA*
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
760b D freshbyte       c                   const('FRESHBYTE')
700bA*----------------------------------------------------------------
700bA* Function prototypes.
700bA*----------------------------------------------------------------

700bA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
415bD**            'FRMTIT'              C         @FMTIT
     D @fmtit          c                   const('FRMTIT2')
650cAD @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
     *
720aAD $bparm          ds
720aAD  $bcmd                  1      8
720aAD  $bprg                  9     18
720aAD  $buky                 19     68
720aAD  $brtn                 69     76
720aAD  $berm                 77    136
720aAD  $bmsg                 77     80
720aA*   Redefine key
720aAD  $bpo                  19     27
720aAD  $brcvdt               28     35  0
720aAD  $bqty                 36     40  0
720aAD  $bprint               41     50
720aAD  $bitem                51     65
720aAD  $buom                 66     67
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
415 AD  $lpo2                 37     45
415 AD  $lrq1                 46     50  0
415 AD  $lrq2                 51     55  0
415 AD  $lrq3                 56     60  0
415 AD  $lrpal                61     63  0
417iAD  $llott                64     64
417iAD  $llict                65     65
     *
     D  $lpo                  22     30
     D  $lline                31     35  0
     D  $lpitm                36     50
     *
415fAD  $lwhs3                19     21  0
415fAD  $lpo3                 22     30
417cA*
417cAD  $lwhs4                19     20p 0
417cAD  $lpo4                 21     29
417cAD  $lseq4                30     32p 0
417cAD  $litm4                33     47
417iA*
417iAD  $llot                 37     37
417iAD  $lltrk                38     38
510gA*
640bDD* $lmfr#                19     29  0
640bDD* $lmfritem             30     44
640bDD* $ldakitem             45     59
640bMD  $lmfr#                22     32  0
640bMD  $lmfritem             33     47
640bMD  $ldakitem             48     62
510gA*
740eAD  $lupc                 22     41
740eAD  $litm1                42     56
417iA*
417iA*----------------------------------------------------------------
417iA*  LICHIST - License history (Input Data)
417iA*
417iAD $rparm          ds
417iAD  $rwhse                 1      3  0
417iAD  $rltrn                 4      7p 0
417iAD  $racfl                 8      9
417iAD  $rtrn#                10     13p 0
417iAD  $rlbl#                14     17p 0
417iAD  $rlcns                18     32
417iAD  $rfmlc                33     47
417iAD  $rorlc                48     62
417iAD  $rlqy1                63     66p 0
417iAD  $rlqy2                67     70p 0
417iAD  $rlqy3                71     74p 0
417iAD  $raqy1                75     78p 0
417iAD  $raqy2                79     82p 0
417iAD  $raqy3                83     86p 0
417iAD  $rfmcd                87     87
417iAD  $rfara                88    102
417iAD  $rfwhd               103    107
417iAD  $rfasl               108    110
417iAD  $rfloc               111    113  0
417iAD  $rflvl               114    115  0
417iAD  $rfhnd               116    117
417lAD  $rfslp               118    119p 0
417iAD  $rtocd               120    120
417iAD  $rtara               121    135
417iAD  $rtwhd               136    140
417iAD  $rtasl               141    143
417iAD  $rtloc               144    146  0
417iAD  $rtlvl               147    148  0
417iAD  $rthnd               149    150
417lAD  $rtslp               151    152p 0
417iAD  $rtord               153    156p 0
417iAD  $rtseq               157    159p 0
417iAD  $rexcd               160    167
417iAD  $radts               168    193
417iAD  $raemp               194    196p 0
417iAD  $rausr               197    206
417iAD  $rajob               207    216
417iAD  $rajbn               217    222
417iAD  $rcdts               223    248
417iAD  $rcemp               249    251p 0
417iAD  $rcusr               252    261
417iAD  $rcjob               262    271
417iAD  $rcjbn               272    277
417iA* Misc. work fields
417iAD $rdata          ds
417iAD  $rpo                   1      9
417iAD  $rseq                 10     12p 0
417iAD  $ritem                13     27
417iAD  $rlotc                28     57
417iAD  $rcwgt                58     62p 2
417iA*
     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
     *----------------------------------------------------------------
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
416hA*----------------------------------------------------------------
416hA*  API programs
416hA*
     D @apici          c                   const('APICVTITM ')
     D @llptr          c                   const('UPDLLPTRK')
417iA*----------------------------------------------------------------
417iA*  Working fields.
417iA*
417iAD                 ds
417iAD  lottrk                 1      4
417iAD  lictrk                 5      8
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     D  erpo                  31     39
     D  erfrom                31     40
     D  erto                  41     50
415 A*
415 AD  ermday                 1      2p 0
415 AD  ermfdt                 3      6p 0
415 AD  erexdt                 7     10p 0
415 AD  erltst                11     14p 0
415 AD  erdday                15     16p 0
415 AD  eruday                17     18p 0
415dA*
415dAD  erused                 1      4p 0
415dAD  erdisd                 5      6p 0
415dAD  erusrd                 7      8p 0
415dAD  ersell                 9     12p 0
415 A*
415 AD  ertcwt                 1      5p 2
415 AD  erlrng                 6     10p 2
415 AD  erhrng                11     15p 2
415 AD  errg1c                16     17p 1
415 AD  errg2c                18     19p 1
415 AD  erexwt                20     24p 2
     *
415  D  ertcw#                 1      3p 0
415  D  erqpck                 4      6p 0
     *
416aAD  erentd                 1      5p 0
416aAD  ertod                  6     10p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500hAD #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
415fA*----------------------------------------------------------------
415fA* Status message(s)
     D sts00           c                   const('Open')
     D sts01           c                   const('Partial receipt')
     D sts02           c                   const('Received in full')
     D sts03           c                   const('Ready for export')
650gAD sts04           c                   const('Partial export')
650gAD sts05           c                   const('Import error')

700cA*----------------------------------------------------------------
700cA*  DRI parameters
700cA*----------------------------------------------------------------
700cA /COPY *libl/qcopysrc,C#DRIPARMS
700cA
700cA*----------------------------------------------------------------
700cA*  Data Formats
700cA*----------------------------------------------------------------
700cA /COPY *libl/qcopysrc,C#ITEM
700cAD savever#        s                   like($itver#)
500dA*------------------------------------------------------------------
500dA* CLCDUR2 parameters
500dA*------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*----------------------------------------------------------------
510aA
510aA /copy qcopysrc,id#isupply
SVLaA /copy qcopysrc,id#saval
YHAaA /copy qcopysrc,id#yhata
DRYaA /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Variables
     *
500 AD $ldwgt          s              9  2
     D $lflag          s              1
     D $lord           s              7  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $msgf           s             10
650hAD $posscode       s              1
650dAD $pw1pti         s              4  0
     D #msgid          s              7
     D #msgtp          s              7
     D #oitem          s             15
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D #pgmq           s             10
500 AD avgwt1          s              7  2
500 AD avgwt2          s              7  2
500 AD avgwt3          s              7  2
700cAD Btype           s              7
DRYaAD caltol1         s             11  4
DRYaAD caltol2         s             11  4
DRYaAD caltol1x100     s             13  4
DRYaAD caltol2x100     s             13  4
700cAD chk4err         s               n
     D ckexdt          s              8  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
700bAD CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
510kAD ddcode          s              1
DRYaAD digits          c                   const('0123456789')
770aAD dockvue         s              1n   inz('0')
     D dtchk           s              1
     D dtchk2          s              1
500f D dtchk3          s              1
500f D dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
     D error           s              1
     D exdtj           s              5  0
     D expd            s              8  0
     D expdj           s              5  0
     D exwgt           s              9  2
     D forevr          s              1
     D full            s              1
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
DRYaAD hostcw0         s              7  0
DRYaAD hostcwa         s              7
DRYaAD hostcw2dec      s              7  2
DRYaAD hostUnitWgt     s              9  4
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
700bAD IMkilolbs       s              1
700bAD IMUom           s              3
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
700bAD kgs2lbs         c                   2.20462262
700bAD KiloLbs         s              1
     D kycode          s                   like(opdcod)
     D kyupc           s                   like(upupc)
     D lflag           s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
640bAD mexpd           s              8  0
640bAD mfgdte          s              8  0
     D msgk            s              4  0
     D noupc           s              1
700cAD Needb1          s               n
700cAD Needb2          s               n
770aAD nostamp         s               z     inz
700cAD Ntype           s              7
     D nxtscr          s              3
     D ocode           s              8
500c D oaovr           s              1
500c D obovr           s              1
510e D ocovr           s              1
     D odovr           s              1
510e D oeovr           s              1
510e D ofovr           s              1
     D ovrrid          s              1
     D part            s              1
650cAD poppcs          s                   like($lrq1)
     D prg1c           s              4  3
     D prg2c           s              4  3
     D qtchk           s              1
DRYaAD qtyDiff         s              5  0
DRYaAD qtyord          s              5  0
DRYaAD qtyord1         s              5  0
DRYaAD qtyord2         s              5  0
DRYaAD qtyord3         s              5  0
DRYaAD qtyrcv          s              5  0
DRYaAD qtyrcv1         s              5  0
DRYaAD qtyrcv2         s              5  0
650cAD rcvpocomplete   s               n
DRYaAD rcvUnitWgt      s              9  4
     D recv            s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              7  2
     D svexck          s              1
     D svexdt          s              6  0
     D svmfdt          s              6  0
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svrupc          s              1
760aAD svnupc          s              1
650iAD svupci          s                   like(pditem)
     D s6upc           s             20
     D s8flag          s              1
     D tmpwgt          s              9  2
     D today           s              8  0
     D todyj           s              5  0
     D upcctr          s              3  0
     D vrfycw          s              1
     D warn            s              1
DRYaAD wgtDiff         s             11  4
640dAD wkmday          s              3  0
     D wkwhse          s                   like(w1whse)
     D wobat           s              7  0
510cAD woexdt          s              8  0
500 AD wofifo          s              8  0
510cAD woindt          s              8  0
500 AD womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
700cAD Writeb1         s               n
700cAD Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w8exdt          s              6  0
     D w8mfdt          s              6  0
700cAD zmflag          s               n
700cAD zmsflag         s               n
650bAD $parms1         s             48    dim(20)
740bAD HoldUci         s            100
740bAD PO201Rtn        s              8
740bAD firstuci        s               n
740bAD rtnqty          s              5  0
740bAD rtnexpdt        s              6  0
740bAD rtnmfgdt        s              6  0
740bAD rtnlot          s             20
740bAD rtnwgt          s             11  3
740bAD rtnuomcd        s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
415fD**     None
415kD***    $PLINE  Lines on display (08 or 16).
     *
     *    Returned Parameters
     *      None
     *
415fA*----------------------------------------------------------------
415fA*  Let the show begin .....
415fA*
415kD**         *ENTRY    PLIST
415kD**                   PARM           $PLINE  2
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
650cAc                   eval      rcvpocomplete = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
415 AC     nxtscr        caseq     '08 '         sc8
417iAC     nxtscr        caseq     '09 '         sc9
700cAC     nxtscr        caseq     '10 '         sc10
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650cA*
650cA*   check to see if po receipt is completed
650cA*   if completed update label/transaction with qty information
650cA*   else just mark them closed. - ended and closed dates
650cAC                   exsr      zzrcvpoclose
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
     C                   if        nxtscr = '01 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn61sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen61                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn1sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen1                              50
415fAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn62sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen62                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn2sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen2                              50
415fAC                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn63sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen63                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn3sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen3                              50
415fAC                   endsl
     C                   endif
     C                   if        nxtscr = '04 '
500hAC                   if        e$lng = 'SP'
500hAC                   exfmt     scrn4sp                              50
500hAC                   else
     C                   exfmt     screen4                              50
500hAC                   endif
     C                   endif
     C                   if        nxtscr = '05 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn65sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen65                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn5sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen5                              50
415fAC                   endsl
     C                   endif
     C                   if        nxtscr = '06 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn66sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen66                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn6sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen6                              50
415fAC                   endsl
     C                   endif
     C                   if        nxtscr = '07 '
500hAC                   if        e$lng = 'SP'
500hAC                   exfmt     scrn7sp                              50
500hAC                   else
     C                   exfmt     screen7                              50
500hAC                   endif
     C                   endif
415 AC                   if        nxtscr = '08 '
415fAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn68sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
415fAC                   exfmt     screen68                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn8sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
415 AC                   exfmt     screen8                              50
415fAC                   endsl
415 AC                   endif
417iAC                   if        nxtscr = '09 '
417iAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn69sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
417iAC                   exfmt     screen69                             50
500hD **                 other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn9sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
417iAC                   exfmt     screen9                              50
417iAC                   endsl
417iAC                   endif
700cAC                   if        nxtscr = '10 '
700cAC                   select
700cAC                   when      #lline = '16' and e$lng = 'SP'
700cAC*                  exfmt     scrn66sp                             50
700cAC                   exfmt     screen10                             50
700cAC                   when      #lline = '16' and e$lng = 'EN'
700cAC*                  exfmt     screen66                             50
700cAC                   exfmt     screen10                             50
700cAC                   when      #lline <> '16' and e$lng = 'SP'
700cAC*                  exfmt     scrn6sp                              50
700cAC                   exfmt     screen10                             50
700cAC                   when      #lline <> '16' and e$lng = 'EN'
700cAC                   exfmt     screen10                             50
700cAC                   endsl
700cAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
416hAC                   eval      redspl = *off
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
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   if        refrsh = *on
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   if        refrsh = *on
217  *R         WOITM#    IFEQ *BLANKS
217  *R                   MOVE UPITEM    WOITM#
     *R                   MOVE UPUPC     WOUPC
     *
     *   Left adjust UPC code for dispaly.
     *
     *R                   MOVEL*BLANKS   $CSTR
     *R                   MOVELUPUPC     $CSTR
     *R                   CALL 'ADJUST'
     *R                   PARM '*LEFT   '$CCMD   8
     *R                   PARM           $CSTR  30
     *R                   MOVEL$CSTR     WOUPC
217  *R                   ENDIF
     C                   exsr      zzfil3
700cAc                   if        *inki = *off
700cAC                   if        $ifrcvmth = '3' and ittype = ' '
700cAc                   exsr      scr10i
700cAc                   endif
700cAc                   endif
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   if        refrsh = *on
     C                   exsr      zzfil4
     C                   endif
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   if        refrsh = *on
     C                   eval      woitm# = *blanks
     C                   eval      w4line = 0
     C                   eval      w4item = *blanks
     C                   exsr      zzfil5
     C                   endif
     C                   eval      refrsh = *off
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   eval      nxtscr = '06 '
     C                   if        refrsh = *on
     C                   eval      w6upc = *blanks
     C                   exsr      zzfil6
     C                   endif
     C                   eval      refrsh = *off
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   if        refrsh = *on
     C                   eval      w7pctr = 0
217 D*R                   EXSR ZZFIL7
     C                   endif
     C                   exsr      zzfil7
     C                   eval      refrsh = *off
     C     end07i        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  Screen 08 initialization
415 A*
415 AC     scr08i        begsr
     C                   eval      nxtscr = '08 '
     C                   if        refrsh = *on
     C                   exsr      zzfil8
     C                   endif
     C                   eval      refrsh = *off
700bAC* if a new item is selected the overrides need to be reset
700bAC                   eval      dtchk = *off
700bAC                   eval      dtchk2 = *off
700bAC                   eval      dtchk3 = *off
700bAC                   eval      dtchk4 = *off
700bAC                   eval      wtchk = *off
     C     end08i        endsr
417iA*----------------------------------------------------------------
417iA*
417iA*  Screen 09 initialization
417iA*
417iAC     scr09i        begsr
417iAC                   eval      nxtscr = '09 '
417iAC                   if        refrsh = *on
417iAC                   exsr      zzfil9
417iAC                   endif
417iAC                   eval      refrsh = *off
417iAC     end09i        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  Screen 10 initialization
700cA*
700cAC     scr10i        begsr
700cA*
700cA*  This screen will get initiated if receiving options to
700cA*  capture upc's for breakdown is turned on.
700cA*
700cA*  We will display the screen10 if the item has breakdowns
700cA*  defined, and we do not have a UPC record for the breakdown uom
700cA*
700cA /free
700cA   writeb1 = *off;
700cA   writeb2 = *off;
700cA   // breakdown 1 is setup on item
700cA   if itum2 <> ' ';
700cA     Needb1  = *on;
700cA     w10buom = itum2;
700cA     w10btyp = '1';
700cA     // do we have a upc loaded for this breakdown uom
700cA     setll (pdwhse: pditem) upc1;
700cA     dow forevr = forevr;
700cA       reade (pdwhse: pditem) upc1;
700cA       if %eof(upc1);
700cA         leave;
700cA       endif;
700cA       if u1_upuom = itum2;
700cA         needb1  = *off;
700cA         leave;
700cA       endif;
700cA     enddo;
700cA   endif;
700cA   // breakdown 2 is setup on item
700cA   if needb1 = *off;
700cA     if itum2 <> ' ';
700cA       Needb2  = *on;
700cA       w10buom = itum3;
700cA       w10btyp = '2';
700cA       // do we have a upc loaded for this breakdown uom
700cA       setll (pdwhse: pditem) upc1;
700cA       dow forevr = forevr;
700cA         reade (pdwhse: pditem) upc1;
700cA         if %eof(upc1);
700cA           leave;
700cA         endif;
700cA         if u1_upuom = itum3;
700cA           needb2  = *off;
700cA           leave;
700cA         endif;
700cA       enddo;
700cA     endif;
700cA   endif;
700cA   // need to capture a breakdown upc
700cA   if needb1 = *on or needb2 = *on;
700cA     nxtscr = '10 ';
700cA     exsr zzfil10;
700cA   else;
700cA     nxtscr = '03 ';
700cA   endif;
700cA /end-free
700cAC     end10i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
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
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
650eAc                   exsr      zzrcvpoclose
     C                   eval      nxtscr = 'EOJ'
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
650eAc                   exsr      zzrcvpoclose
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
415aAC                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
415aA*
415aA*  Test for other command keys AFTER verification and update.
415aA*
415aAC                   eval      cmdchk = '*AFTER  '
415aAC                   exsr      zzcmd3
415aAC     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
417iD*R                   MOVE 'EOJ'     NXTSCR
417iA*
417iAC                   eval      refrsh = *off
417iA*
417iA*    Lot tracking item. Return to Lot entry screen.
417iAC                   if        lottrk = '*YES'
417iAC                   exsr      scr09i
417iAC                   else
417iAC                   exsr      scr03i
417iAC                   endif
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
     C                   eval      refrsh = *off
417iA*
417iA*    Lot tracking item. Return to Lot entry screen.
417iAC                   if        lottrk = '*YES'
417iAC                   exsr      scr09i
417iAC                   else
     C                   exsr      scr03i
417iAC                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
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
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
415aAC                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
416hAC     redspl        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
415aA*
415aA*  Test for other command keys AFTER verification and update.
415aA*
415aAC                   eval      cmdchk = '*AFTER  '
415aAC                   exsr      zzcmd5
415aAC     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
650eAC                   exsr      zzrcvpoclose
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr06i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
650eAC                   exsr      zzrcvpoclose
     C                   exsr      scr05i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for other command keys
     *
415aAC                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
415aA*
415aA*  Test for other command keys AFTER verification and update.
415aA*
415aAC                   eval      cmdchk = '*AFTER  '
415aAC                   exsr      zzcmd6
415aAC     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr07i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     *
     *R         *INKL     IFEQ *ON
     *R                   MOVE *OFF      REFRSH
     *R                   EXSR SCR03I
     *R                   GOTO ENDSC7
     *R                   ENDIF
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  SC8  -  Screen 8
415 A*
415 AC     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
417iD*R                   MOVE 'EOJ'     NXTSCR
417iA*
417iAC                   eval      refrsh = *off
417iA*
417iA*    Lot tracking item. Return to Lot entry screen.
417iAC                   if        lottrk = '*YES'
417iAC                   exsr      scr09i
417iAC                   else
417iAC                   exsr      scr03i
417iAC                   endif
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
417iA*
417iA*    Lot tracking item. Return to Lot entry screen.
417iAC                   if        lottrk = '*YES'
417iAC                   exsr      scr09i
417iAC                   else
     C                   exsr      scr03i
417iAC                   endif
     C                   goto      endsc8
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
700bA*     Setup converted weight field.
700bAC                   exsr      zzcnvwgt
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     C     endsc8        endsr
417iA*----------------------------------------------------------------
417iA*
417iA*  SC9  -  Screen 9
417iA*
417iAC     sc9           begsr
417iA*
417iA*  Test for F3 - Exit
417iA*
417iAC                   if        *inkc
417iAC                   exsr      scr03i
417iAC                   goto      endsc9
417iAC                   endif
417iA*
417iA*  Test for F5 - Refresh
417iA*
417iAC                   if        *inke
417iAC                   eval      refrsh = *on
417iAC                   exsr      scr09i
417iAC                   goto      endsc9
417iAC                   endif
417iA*
417iA*  Test for F12 - Previous
417iA*
417iAC                   if        *inkl
417iAC                   eval      refrsh = *off
417iAC                   exsr      scr03i
417iAC                   goto      endsc9
417iAC                   endif
417iA*
417iA*  Test for other command keys BEFORE verification and update.
417iA*
417iAC                   eval      cmdchk = '*BEFORE '
417iAC                   exsr      zzcmd9
417iAC     cmdtkn        cabeq     *on           endsc9
417iA*
417iA*  Some other key pressed.
417iA*
417iA*     Check input and write/update record.
417iA*
417iAC                   exsr      zzchk9
417iAC     error         cabeq     *on           endsc9
417iAC                   exsr      zzupd9
417iAC     error         cabeq     *on           endsc9
417iA*
417iA*  Test for other command keys AFTER verification and update.
417iA*
417iAC                   eval      cmdchk = '*AFTER  '
417iAC                   exsr      zzcmd9
417iAC     cmdtkn        cabeq     *on           endsc9
417iA*
417iAC     endsc9        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  SC10 -  Screen 10
700cA*
700cAC     sc10          begsr
700cA*
700cA*  Test for F3 - Exit
700cA*
700cAC                   if        *inki
700cAC                   exsr      scr03i
700cAC                   goto      endsc10
700cAC                   endif
700cA*
700cA*
700cA*  Test for other command keys
700cA*
700cAC                   eval      cmdchk = '*BEFORE '
700cAC                   exsr      zzcmd10
700cAC     cmdtkn        cabeq     *on           endsc10
700cA*
700cA*  Some other key pressed.
700cA*
700cA*     Check input and write/update record.
700cA*
700cAC                   exsr      zzchk10
700cAC     error         cabeq     *on           endsc10
700cAC                   exsr      zzupd10
700cAC     error         cabeq     *on           endsc10
700cA*
700cA*  Test for other command keys AFTER verification and update.
700cA*
700cAC                   eval      cmdchk = '*AFTER  '
700cAC                   exsr      zzcmd10
700cAC     cmdtkn        cabeq     *on           endsc10
700cA*
700cAC     endsc10       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510aA*  Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
510aAC                   parm                    clientloc        10
760bAc                   parm                    clientinit        3
760bAc                   parm                    clienthost       10
510aA
     *
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
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
415 A*----------------------------------------------------------------
415 A*
500dA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
415 A*                                                                   DOC
415 AC     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
     C                   endsr
415 A*----------------------------------------------------------------
415 A*
500dA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
415 A*                                                                   DOC
415 AC     jtog$         begsr
     C     j$jd          div       365.25        j$yywk
     C     j$jd          div       365.25        j$tst
     C                   if        j$tst = 0
     C                   eval      j$yywk = j$yywk - 1
     C                   endif
     C                   eval      j$yd = j$yywk * 365.25
     C                   eval      j$yd = j$jd - j$yd
     C                   if        j$yd > 306
     C                   add       1             j$yywk
     C                   endif
     C                   eval      j$x = 0
     C                   dou       j$yd <= j$md
     C                   add       1             j$x
     C     j$x           mult(h)   30.6          j$md
     C                   enddo
     C                   eval      j$x = j$x - 1
     C     j$x           mult(h)   30.6          j$md
     C     j$yd          sub       j$md          j$dd
     C     j$x           add       3             j$mm
     C                   if        j$mm > 12
     C                   eval      j$mm = j$mm - 12
     C                   endif
     C     j$yywk        add       1900          j$yyyy
     C                   if        dtfrmt = 1
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   movel     work2         j$date
     C                   move      work4         j$date
     C                   else
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   move      work2         j$date
     C                   movel     work4         j$date
     C                   endif
     C                   endsr
740bA*----------------------------------------------------------------
740bA*
740bA* UCIReceive - Call UCI receiving program
740bA*                                                                   DOC
740bAC     UCIReceive    begsr
740bAc                   call      'PO201'
740bAc                   parm                    w1whse
740bAc                   parm                    wopo
740bAc                   parm                    woline
740bAc                   parm                    woitm#
740bAc                   parm                    woitem
740bAc                   parm                    pdspcl
740bAc                   parm                    holduci
740bAc                   parm      ' '           $pgslcns
740bAc                   parm                    firstuci
740bAc                   parm                    rtnqty
740bAc                   parm                    rtnexpdt
740bAc                   parm                    rtnmfgdt
740bAc                   parm                    rtnlot
740bAc                   parm                    rtnwgt
740bAc                   parm                    rtnuomcd
740bAc                   parm      ' '           PO201Rtn
740bAC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
415fAC                   select
415kMC                   when      #lline = '16'
415fAC                   write     m16ctl
415fAC                   other
     C                   write     msgctl
415fAC                   endsl
     C                   eval      msgk = *zeros
415fAC                   select
415kMC                   when      #lline = '16'
415fAC                   write     m16clr
415fAC                   other
     C                   write     msgclr
415fAC                   endsl
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
415fAC                   select
415kMC                   when      #lline = '16'
415fAC                   write     m16ctl
415fAC                   other
     C                   write     msgctl
415fAC                   endsl
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
500hAC                   select
500hAC                   when      e$lng  = 'SP'
500hAC                   eval      $msgf  = #msgsp
500hAC                   other
     C                   eval      $msgf  = #msgf
500hAC                   endsl
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
415fAC                   select
415kMC                   when      #lline = '16'
415fAC                   write     m16rec
415fAC                   other
     C                   write     msgrec
415fAC                   endsl
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
415fAC                   select
415kMC                   when      #lline = '16'
415fAC                   write     m16rec
415fAC                   other
     C                   write     msgrec
415fAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
415 A*----------------------------------------------------------------
415 A*   PT13019  Warning: Entered catch weight not within +/- range.
415 A*
415 AC     zm19          begsr
415 AC                   eval      #msgid = 'PT13019'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md
415 AC                   exsr      zmpmsg
415 AC                   endsr
510fA*----------------------------------------------------------------
510fA*     PO20001  Warning: Exp date comes before existing date.
510fA*
510fAC     zm2001        begsr
510fAC                   eval      #msgid = 'PO20001'
510fAC                   eval      #msgtp = '*DIAG  '
510fAC                   movea     errmsg        $md(1)
510fAC                   exsr      zmpmsg
510fAC                   endsr
     *----------------------------------------------------------------
     *    PO20022  DOCK number must be entered.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20022'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20023  UPC number must be entered.
     *
     C     zm023         begsr
     C                   eval      #msgid = 'PO20023'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20026  Line not in P.O.
     *
     C     zm026         begsr
     C                   eval      #msgid = 'PO20026'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   eval      erpo = wopo
     C                   exsr      zmpmsg
     C                   endsr
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
     *    PO20028  Different UPC entered.
     *
     C     zm028         begsr
     C                   eval      #msgid = 'PO20028'
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
     *    PO20030  Item or Line must be entered.
     *
     C     zm030         begsr
     C                   eval      #msgid = 'PO20030'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20031  Item has UPC for vendor.
     *
     C     zm031         begsr
     C                   eval      #msgid = 'PO20031'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20032  No UPC entered.
     *
     C     zm032         begsr
     C                   eval      #msgid = 'PO20032'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
417b *----------------------------------------------------------------
417b *    PO20035  Multiple items exist for UPC
417b *
417b C     zm035         begsr
417b C                   eval      #msgid = 'PO20035'
417b C                   eval      #msgtp = '*DIAG  '
417b C                   eval      $md = *blanks
417b C                   exsr      zmpmsg
417b C                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO15021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
DRYaA*----------------------------------------------------------------
DRYaA*   PT13023  Warning: Tot c/w not within +/- range.
DRYaA*
DRYaAC     zm23          begsr
DRYaAC                   eval      #msgid = 'PT13023'
DRYaAC                   eval      #msgtp = '*DIAG  '
DRYaAC                   movea     errmsg        $md
DRYaAC                   exsr      zmpmsg
DRYaAC                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     RC13073  Purchase order does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'RC13073'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVEAERRMSG    $MD,1
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
219 A*----------------------------------------------------------------
219 A*   PIR0110  Value must be > 0.
219 A*
219 AC     zm0110        begsr
219 AC                   eval      #msgid = 'PIR0110'
219 AC                   eval      #msgtp = '*DIAG  '
219 AC                   movea     errmsg        $md
219 AC                   exsr      zmpmsg
219 AC                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
219 A*   PIR1005  Value must be 'Y' or 'N'
     *
219 AC     zm1005        begsr
219 AC                   eval      #msgid = 'PIR1005'
219 AC                   eval      #msgtp = '*DIAG  '
219 AC                   movea     errmsg        $md
219 AC                   exsr      zmpmsg
219 AC                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
415dA*----------------------------------------------------------------
415dA*     PO13229  Item cannot be accepted.
415dA*
415dAC     zm3229        begsr
415dAC                   eval      #msgid = 'PO13229'
415dAC                   eval      #msgtp = '*DIAG  '
415dAC                   movea     errmsg        $md(1)
415dAC                   exsr      zmpmsg
415dAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13230  Item cannot be accepted - Exp Date
416aA*
416aAC     zm3230        begsr
416aAC                   eval      #msgid = 'PO13230'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13231  Warning: Exp date comes before existing date.
416aA*
416aAC     zm3231        begsr
416aAC                   eval      #msgid = 'PO13231'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13232  Item cannot be accepted - Calc Exp Date
416aA*
416aAC     zm3232        begsr
416aAC                   eval      #msgid = 'PO13232'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*     PO13233  Warning: Calc exp date comes before existing date.
416aA*
416aAC     zm3233        begsr
416aAC                   eval      #msgid = 'PO13233'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
416fA*----------------------------------------------------------------
416fA*     PO13234  CW must be zero when Avg = 'Y' for "First time"
416fA*
416fAC     zm3234        begsr
416fAC                   eval      #msgid = 'PO13234'
416fAC                   eval      #msgtp = '*DIAG  '
416fAC                   movea     errmsg        $md(1)
416fAC                   exsr      zmpmsg
416fAC                   endsr
417aA*----------------------------------------------------------------
417aA*     PO13243  Item cannot be accepted. # of days out
417aA*
417aAC     zm3243        begsr
417aAC                   eval      #msgid = 'PO13243'
417aAC                   eval      #msgtp = '*DIAG  '
417aAC                   movea     errmsg        $md(1)
417aAC                   exsr      zmpmsg
417aAC                   endsr
     *----------------------------------------------------------------
     *     TF17201  Warning: Quantity received not equal to ordered.
     *
     C     zm7201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
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
415 A*----------------------------------------------------------------
415 A*    PIR1010  Date must be <OR= today's date.
415 A*
415 AC     zm1010        begsr
415 AC                   eval      #msgid = 'PIR1010'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md
415 AC                   exsr      zmpmsg
415 AC                   endsr
510lA*----------------------------------------------------------------
510lA*    ZM13250  Item not date sensitive.
510lA*
510lAC     zm13250       begsr
510lAC                   eval      #msgid = 'PO13250'
510lAC                   eval      #msgtp = '*DIAG  '
510lAC                   movea     errmsg        $md
510lAC                   exsr      zmpmsg
510lAC                   endsr
415 A*----------------------------------------------------------------
415 A*    PO21001  Multiple qty entered, Catch wt avg must be 'N'
415 A*
415 AC     zm2101        begsr
415 AC                   eval      #msgid = 'PO21001'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   eval      $md = *blanks
415 AC                   exsr      zmpmsg
415 AC                   endsr
415 A*----------------------------------------------------------------
415 A*     PO13226  cannot receive an item, if ready for export.
415 A*
415 AC     zm3226        begsr
415 AC                   eval      #msgid = 'PO13226'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr
415 A*----------------------------------------------------------------
415 A*     PO13228  Item cannot be accepted.
415 A*
415 AC     zm3228        begsr
415 AC                   eval      #msgid = 'PO13228'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
415 A*
415 A*    Verify warehouse and get description.
415 A*
415 AC                   eval      $lcmd = '*VERIFY '
415 AC                   eval      $lwhse = w1whse
415 AC                   call      'WH900'
415 AC                   parm                    $lparm
415 AC                   if        $lrtn = '*ERROR  '
415 AC                   eval      error = *on
415 AC                   eval      *in22 = *on
415 AC                   eval      *in02 = *on
415 AC                   movel     $lerm         errmsg
415 AC                   exsr      zm0105
415 AC                   else
415 AC                   if        $lrtn = '*PGMQ   '
415 AC                   eval      error = *on
415 AC                   eval      *in22 = *on
415 AC                   eval      *in02 = *on
415 AC                   eval      #msgk = $lmsg
415 AC                   exsr      zmqmsg
415 AC                   endif
415 AC                   endif
     *
     *  P.O. number must be entered.
     *
     C                   if        w1po = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm21
     C                   endif
     *
     *  Verify P.O. number.
     *
     C                   if        w1po <> *blanks
     C                   eval      wopo = w1po
221 D*R         FILEKY    CHAINPOHDR                79
221 MC     fileky        chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm73
     C                   endif
     C                   endif
710aA*
710aA*  Super PO is not allowed.
710aA*
710aA /free
710aA   chain (w1whse: wopo) pospo;
710aA   if %found(pospo);
710aA     error = *on;
710aA     *in21 = *on;
710aA     *in01 = *on;
710aA     select;
710aA       when e$lng = 'SP';
710aA         errmsg = descsp(8);
710aA       other;
710aA         errmsg = desc(8);
710aA     endsl;
710aA     exsr zm0105;
710aA   endif;
710aA /end-free
415gD**
415gD**  Cannot receive an item, if the PO is ready for export.
415gD**
415gD**         PHSTAT    IFEQ '3'
415gD**                   MOVE *ON       ERROR
415gD**                   MOVE *ON       *IN21
415gD**                   MOVE *ON       *IN01
415gD**                   EXSR ZM3226
415gD**                   ENDIF
415 D**
415 D** Dock number must be entered.
415 D**
415 D**         W1DOCK    IFEQ 0
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN22
415 D**                   MOVE *ON       *IN02
415 D**                   EXSR ZM022
415 D**                   ENDIF
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      noupc = *off
650eAc                   exsr      zzrcvpocheck
740bAc                   eval      $bcGtinSent = '0'
417cA*
417cA*    Confirm Retail UPC on file before continuing with receiving.
417cA*
417cAC                   if        svrupc = 'Y'  and
417cAC                             w2upc > *blanks
417cAC                   exsr      zzrupc
417cAC     error         cabeq     *on           endck2
417cAC                   endif
415gA*
415gA*   Cannot receive an item, if the PO is ready for export.
415gA*
415gAC                   if        phstat = '3'
415gAC                   eval      error = *on
415gAC                   eval      *in29 = *on
415gAC                   eval      *in09 = *on
415gAC                   exsr      zm3226
415gAC                   goto      endck2
415gAC                   endif
     *
     *  UPC code must be entered.
     *
     *R         W2UPC     IFEQ *BLANKS
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN23
     *R                   MOVE *ON       *IN03
     *R                   EXSR ZM023
     *R                   ENDIF
     *
     *  UPC not entered.
     *
     C                   if        w2upc = *blanks
     C                   eval      noupc = *on
     C                   eval      woupc = *blanks
     C                   endif
740bAc                   if        w2upc <> *blanks
740bA * add the conversion of the uci barcode
740bAC                   eval      $cbcmd = '*ALL    '
740bAC                   eval      $cbbar = w2upc
740bAc                   clear                   $barcode
740bAc                   clear                   $barcode2
740bA*
740bAC                   call      'CVTBAR'
740bAC                   parm                    $cbcmd            8
740bAC                   parm                    $cbbar          100
740bAC                   parm                    $cbcod            3 0
740bAC                   parm                    $cbdec            1 0
740bAC                   parm                    $cbdsc           30
740bAC                   parm                    $cbpos            3 0
740bAC                   parm                    $cbtyp            1 0
740bAC                   parm                    $cbv1            11 3
740bAC                   parm                    $cbv2            50
740bAC                   parm                    $cbrtn            8
740bAC                   parm                    $cberm           60
740bAC                   parm      phven         $cbven           10 0
740bAC                   parm                    $cvtdata
740bAC                   parm                    $cvtdata2
740bAc                   else
740bAc                   clear                   $barcode
740bAc                   clear                   $barcode2
740bAc                   exsr      clr$item
740bAc                   endif
740bAc                   if        $cbrtn = '*NOMORE'
740fAc                             or $cbrtn = '*OK'
740bAc                   eval      $barcode = $cvtdata
740bAc                   eval      $barcode2 = $cvtdata2
740bAc                   endif
740bA * Load UPC
740bAc                   if        $bcGtinSent
740bAc                   eval      holduci = $cbbar
740bAc                   else
740bA ** Needed this because all barcodes are not gs1
740bAc*                  eval      w1upcd = w1uci
740bAc* if $bcgtinsent is not on we don't know what item this is.
740bAc* so turn off all the other $bc sent fields, without the item non of
740bAc* these are valid for our receiving purposes.
740bAc                   eval      $bcExpDSent = *off
740bAc                   eval      $bcSlByDSent = *off
740bAc                   eval      $bcProdDSent = *off
740bAc                   eval      $bcPackDSent = *off
740bAc                   eval      $bcPNtLbSent = *off
740bAc                   eval      $bcLotSent = *off
740bAc                   endif
740bA * Load Expiration Date
740bAc                   select
740bAc                   when      $bcExpDSent
740bAc                   eval      w8dte   = $bcExpD
740bAc                   when      $bcSlByDSent
740bAc                   eval      w8dte   = $bcSlByD
740bAc                   endsl
740bA * Load Manufacturing Date
740bAc                   if        $bcProdDSent
740bAc                   eval      $lmfgdt = $bcProdD
740bAc                   endif
740bA * Load Manufacturing Date
740bAc                   if        $bcPackDSent
740bAc                   eval      $lmfgdt = $bcPackD
740bAc                   endif
740bA * Load Catch Weight
740bAc                   if        $bcPNtLbSent
740bAc                             and $ifrcvmth = '2'
740bAc                   eval      w8dwgt  = $bcPNtLb
740bAc                   endif
740bA * Load Lot
740bAc                   if        $bcLotSent
740bAc                   eval      $llot   = $bcLot
740bAc                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w2upc <> *blanks
415eAC                   eval      $cbcmd = '*UPC    '
415eAC                   movel     w2upc         $cbbar
415eAC                   call      'CVTBAR'
415eAC                   parm                    $cbcmd            8
415eAC                   parm                    $cbbar          100
415eAC                   parm                    $cbcod            3 0
415eAC                   parm                    $cbdec            1 0
415eAC                   parm                    $cbdsc           30
415eAC                   parm                    $cbpos            3 0
415eAC                   parm                    $cbtyp            1 0
415eAC                   parm                    $cbv1            11 3
415eAC                   parm                    $cbv2            50
415eAC                   parm                    $cbrtn            8
415eAC                   parm                    $cberm           60
740fAC                   parm      phven         $cbven           10 0
740fAC                   parm                    $cvtdata
740fAC                   parm                    $cvtdata2
415eA*
415eAC                   if        $cbrtn = '*OK'
415eAC                   eval      w2upc = $cbv2
415eAC                   endif
     *
415eD**                   MOVE W2UPC     WOUPC
760aAc                   if        svnupc <> 'Y'
415eMC                   movel     w2upc         woupc
760aAc                   endif
     *
218 D*   Left adjust UPC code for display.
218 D*
218 D*R                   MOVEL*BLANKS   $CSTR
218 D*R                   MOVELW2UPC     $CSTR
218 D*R                   CALL 'ADJUST'
218 D*R                   PARM '*LEFT   '$CCMD   8
218 D*R                   PARM           $CSTR  30
218 D*R                   MOVEL$CSTR     WOUPC
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
415eD**                   MOVE $CSTR     W2UPC
415eMC                   move      $cstr         kyupc
417b *   Check if mulitple items exist for one UPC code.
417b *    UPCCTR = 0, error, upc code not found.
417b *    UPCCTR = 1, only one upc found, process for item.
417b *    UPCCTR > 1, multiple upc found, need to select item.
417b C                   eval      upcctr = 0
650iAc                   eval      svupci = ' '
650iDC*    upckey        setll     upc
640iMC     upckey        setll     upc4
417b C                   dow       forevr = forevr
650iDC*    upckey        reade     upc                                    79
650iMC     upckey        reade     upc4                                   79
     *
417b C                   if        *in79
417b C                   leave
417b C                   else
650iA*
650iAC                   if        svupci <> upitem
417b C                   add       1             upcctr
650iAC                   eval      svupci = upitem
650iAC                   endif
650iA*
417b C                   endif
     *
417b C                   enddo
     *
221 D*R         UPCKEY    CHAINUPC                  79
417bD**         UPCKEY    CHAINUPC                 N79
417bD**         *IN79     IFEQ *ON
417b C                   if        upcctr = 0
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN29
     *R                   MOVE *ON       *IN09
     *R                   EXSR ZM029
415eAC                   if        $cbrtn <> '*OK'
415eAC                   eval      error = *on
415eAC                   eval      *in29 = *on
415eAC                   eval      *in09 = *on
415eAC                   movel     $cberm        errmsg
415eAC                   exsr      zm0105
415eAC                   goto      endck2
415eAC                   endif
     C                   eval      noupc = *on
     C                   endif
     *   Multiple items exist for UPC
417b C                   if        upcctr > 1
740eAC                   eval      $lcmd = '*VERIFY '
740eAC                   eval      $lwhse = w1whse
740eAC                   eval      $lupc = kyupc
740eAC                   call      'UC920'
740eAC                   parm                    $lparm
740eAC                   if        $lrtn = '*ERROR  '
417bAC                   eval      error = *on
417bAC                   eval      *in29 = *on
417bAC                   eval      *in09 = *on
417b C                   exsr      zm035
417bAC                   goto      endck2
740eAC                   else
740eAC                   if        $lrtn = '*PGMQ   '
740eAC                   eval      error = *on
740eAC                   eval      *in29 = *on
740eAC                   eval      *in09 = *on
740eAC                   eval      #msgk = $lmsg
740eAC                   exsr      zmqmsg
740eAC                   goto      endck2
740eAC                   endif
740gMC                   eval      upitem = $litm1
740eAC                   endif
417b C                   endif
740gDC*                  eval      upitem = $litm1
     *
     *
     *   Verify Item exists on PO.
     *
     C                   if        noupc = *off
     C                   eval      woitm# = upitem
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm027
415aAC                   else
415aAC                   eval      woline = pdseq
415aAC                   eval      woitm# = pditem
740bAc                   if        $bcgtinsent
740bAc                   exsr      zzgeti
740bAc                   endif
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
415 A*   QTCHK Flag is used to force F20 for qty test
415 A*   Values: Flag = 0 Do check.
415 A*           Flag = 1 Check was done, ok.
415 A*           Flag = 2 Warning condition.
     *
415 A*   Note: For 4.15, all existing error checks were removed. They
415 A*         are deleted at end of routine. All of the new error
415 A*         checks are not coded with 4.15 for readability of
415 A*         future changes.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
650cAc                   exsr      zzrcvpocheck
     *
     *  Verify normal quantity.
     *
415cD**         W3QT01    IFLT 0
700aD *                  if        w3qt01 < 1  or
700aD *                            w3qt01 > 99999
700aAC                   if        w3qt01 = 0  and
700aAC                             w3qt02 = 0
     C                   eval      qtchk = *off
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   movel     descsp(1)     erfld
500hAC                   other
     C                   movel     desc(1)       erfld
500hAC                   endsl
415cD**                   MOVEL'0'       ERFROM
415cMC                   movel     '1'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
415cD**         W3QT01    IFLT 0
416iD*R         W3QT01    IFLT 1
416iMC                   if        w3qt01 < 0  or
     C                             w3qt02 > 99999
     C                   eval      qtchk = *off
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   movel     descsp(2)     erfld
500hAC                   other
     C                   movel     desc(2)       erfld
500hAC                   endsl
415cD**                   MOVEL'0'       ERFROM
415cMC                   movel     '1'           erfrom
416iD*R                   MOVEL'1'       ERFROM
416iMC                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify # of Pallets.
     *
     C                   if        opmput = 'Y'  and
     C                             w3plt <= 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   movel     descsp(3)     erfld
500hAC                   other
     C                   movel     desc(3)       erfld
500hAC                   endsl
415cD**                   MOVEL'0'       ERFROM
415cMC                   movel     '1'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Warning:
     *
     C     w3qt01        add       pdqrc1        svqrc1
     C     w3qt02        add       pdqrc2        svqrc2
     *
     *  Quantity.
     *
     C                   if        sdqrc1 <> w3qt01  or
     C                             sdqrc2 <> w3qt02
     C                   eval      qtchk = *off
     C                   endif
     *
     C                   if        qtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      qtchk = *on
     C                   endif
     *
     C                   if        qtchk <> '1'
     C                   eval      qtchk = *on
     *
     C                   if        svqrc1 <> pdqor1  or
     C                             svqrc2 <> pdqor2
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      qtchk = '2'
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm7201
     C                   endif
     C                   endif
     *
     *   Save screen fields.
     *
     C                   eval      sdqrc1 = w3qt01
     C                   eval      sdqrc2 = w3qt02
     *
415 D**--------------------------------------------------------------
415 D**
415 D** Below are the original checks before 4.15.
415 D**
415 D** Everything after this point should be deleted.
415 D**
415 D** Verify expiration date.
415 D**
415 D**         *IN96     IFEQ *OFF
415 D**         W3EXDT    ANDEQ0
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN26
415 D**                   MOVE *ON       *IN06
415 D**                   MOVEL*BLANKS   ERRMSG
415 D**                   EXSR ZM1008
415 D**                   ELSE
415 D**         W3EXDT    IFNE 0
415 D**                   MOVE '*MDYEDT '$CVCMD
415 D**                   MOVE W3EXDT    $CVD6I
415 D**                   CALL @CVTDT
415 D**                   PARM           $CVTDT
415 D**         $CVRTN    IFEQ '*PGMQ   '
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN26
415 D**                   MOVE *ON       *IN06
415 D**                   MOVE $CVMSG    #MSGK
415 D**                   EXSR ZMQMSG
415 D**                   GOTO ENDCK3
415 D**                   ELSE
415 D**                   MOVE $CVD6O    W3EXDT
415 D**                   MOVE '*MDYCMD '$CVCMD
415 D**                   CALL @CVTDT
415 D**                   PARM           $CVTDT
415 D**                   MOVE $CVD8O    EXPD    80
415 D**         EXPD      IFLE TODAY
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN26
415 D**                   MOVE *ON       *IN06
415 D**                   MOVEL*BLANKS   ERRMSG
415 D**                   EXSR ZM1009
415 D**                   GOTO ENDCK3
415 D**                   ENDIF
415 D**                   ENDIF
415 D**                   ENDIF
415 D**                   ENDIF
415 D**
415 D**  Verify quantity.
415 D**
415 D** Warning:
415 D**         OVRRID    IFEQ *OFF
415 D**         W3QT01    IFNE PDQOR1
415 D**         W3QT02    ORNE PDQOR2
415 D**                   MOVE *ON       WARN
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN24
415 D**                   MOVE *ON       *IN25
415 D**                   MOVE *ON       *IN04
415 D**                   MOVE *ON       *IN05
415 D**                   EXSR ZM7201
415 D**                   ENDIF
415 D**                   ENDIF
415 D**
415 D**  Verify catchweight.
415 D**
415 D**         *IN99     IFEQ *OFF
415 D**         W3DWGT    ANDEQ0
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN29
415 D**                   MOVE *BLANKS   ERRMSG
415 D**                   MOVELDESC,2    ERRMSG
415 D**                   EXSR ZM0110
415 D**                   ENDIF
415 D**
415 D** Verify Catch weight average  (Y/N).
415 D**
415 D**         W3AVG     IFNE 'Y'
415 D**         W3AVG     ANDNE'N'
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN32
415 D**                   MOVE *ON       *IN12
415 D**                   MOVE *BLANKS   ERRMSG
415 D**                   MOVELDESC,1    ERRMSG
415 D**                   EXSR ZM1005
415 D**                   ENDIF
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
650cAc                   exsr      zzrcvpocheck
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
650cAc                   exsr      zzrcvpocheck
417cA*
417cA*    Confirm Retail UPC on file before continuing with receiving.
417cA*
417cAC                   if        svrupc = 'Y'  and
417cAC                             w4line <> 0  or
417cAC                             svrupc = 'Y'  and
417cAC                             w4item > *blanks
417cAC                   exsr      zzrupc
417cAC     error         cabeq     *on           endck5
417cAC                   endif
     *
     *  Item # or Line # must be entered.
     *
     C                   if        w4line = 0  and
     C                             w4item = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm030
     C                   endif
     *   Verify Line #.
     *
     C                   if        w4line <> 0
     C                   eval      woline = w4line
     C     partky        setll     podtl                              79
218 MC     partky        reade     podtl                                  79
     C                   if        *in79
     *R                   MOVE WOPO      ERPO
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm026
     C                   else
     C                   eval      woline = pdseq
     C                   eval      woitm# = pditem
     C                   endif
     C                   endif
     *
     *   Verify Item #.
     *
     C                   if        w4item <> *blanks
416hA*
416hA*  Call API for item.
416hA*
416hAC                   call      @apici
416hAC                   parm                    w4item
416hAC                   parm      6             worow             3 0
416hAC                   parm      7             wocol             3 0
416hAC                   parm                    @artn             8
416hAC                   if        @artn = '*REDSPLY'
416hA*R                   MOVE *ON       REDSPL
416hA*R                   GOTO ENDCK5
416hAC                   endif
416hA*
     C                   eval      woitm# = w4item
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm027
     C                   else
     C                   eval      woline = pdseq
     C                   eval      woitm# = pditem
     C                   endif
     C                   endif
     *
740bA /free
740bA   // is this a uci item?
740bA   exsr zzgeti;
740bA /end-free
     *
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 6 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
650cAc                   exsr      zzrcvpocheck
     *
415eAC                   eval      $cbcmd = '*UPC    '
415eAC                   eval      $cbbar = w6upc
415eAC                   call      'CVTBAR'
415eAC                   parm                    $cbcmd
415eAC                   parm                    $cbbar
415eAC                   parm                    $cbcod
415eAC                   parm                    $cbdec
415eAC                   parm                    $cbdsc
415eAC                   parm                    $cbpos
415eAC                   parm                    $cbtyp
415eAC                   parm                    $cbv1
415eAC                   parm                    $cbv2
415eAC                   parm                    $cbrtn
415eAC                   parm                    $cberm
740fAC                   parm      phven         $cbven           10 0
740fAC                   parm                    $cvtdata
740fAC                   parm                    $cvtdata2
415eA*
415eAC                   if        $cbrtn = '*OK'
415eAC                   eval      w6upc = $cbv2
700cAc                   eval      ntype = %trimr($cbdsc)
415eAC                   endif
     *
415eD**                   MOVE W6UPC     S6UPC  20
415eMC                   movel     w6upc         s6upc
     *
     *   Right adjust UPC code.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w6upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
415eD**                   MOVE $CSTR     W6UPC
415eMC                   move      $cstr         kyupc
     *
     *   Verify UPC.
     *
     C                   if        s6upc <> woupc
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   exsr      zm028
     C                   endif
218 D*
218 D*   Verify UPC doesn't exist for item,vendor.
218 D*
218 D*R         UPCKY1    CHAINUPC1                 79
218 D*R         *IN79     IFEQ *OFF
218 D*R                   MOVE *ON       ERROR
218 D*R                   MOVE *ON       *IN28
218 D*R                   MOVE *ON       *IN08
218 D*R                   EXSR ZM031
218 D*R                   ENDIF
     *
     C     endck6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 7 error checking.
     *
     C     zzchk7        begsr
     C                   eval      error = *off
650cAc                   exsr      zzrcvpocheck
     *
     *  License # must be entered.
     *
416fD**         W7LCNS    IFEQ 0
416f C                   if        w7lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
     *
416fA*  Left justify license.
416fAC                   eval      $cstr = *blanks
416fAC                   move      w7lcns        $cstr
416fAC                   call      'ADJUST'
417fD*R                   PARM '*LEFT   '$CCMD   8
417fMC                   parm      '*LEFTNOZ'    $ccmd
416fAC                   parm                    $cstr
416fAC                   movel     $cstr         w7lcns
     *
417gAC                   eval      *in81 = *off
417gAC     valid         check     w7lcns                                 81
417gA*
417gA*  *IN81 = *ON - One of the positions did not have valid value
417gA*
417gAC                   if        *in81
417gAC                   eval      error = *on
417gAC                   eval      *in33 = *on
417gAC                   eval      *in13 = *on
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      errmsg = descsp(6)
500hAC                   other
417gAC                   eval      errmsg = desc(6)
500hAC                   endsl
417gAC                   exsr      zm1001
417gAC                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
     *
     C     endck7        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZCHK8   Screen 8 error checking.
415 A*
500c *   OAOVR = Manufacture date override, Caluclated exp date
500c *           comes before existing overflow exp date. (PO13233)
500c *   OBOVR = Manufacture date override, Manufacture date entered
500c *           is greater than today.(PIR1010)
500c *   OCOVR = Expiration date override, Expiration date is greater
500c *           than allowed # of days out. (PO13243)
500c *   ODOVR = Use by date override, Not enough user/dist days to
500c *           sell before expiration date (PO13229)
500c *   OEOVR = Mfg date override, Not enough user/dist days to
500c *           sell before calculated expiration date (PO13228)
500c *   OFOVR = Expiration date override, Expiration date entered
500c *           comes before existing overflow exp date. (PO13231)
415 A*   DTCHK, WTCHK Flags are used to force F20 for each test
416aA*   DTCHK2, DTCHK3, DTCHK4
415 A*   Values: Flag = 0 Do check.
415 A*           Flag = 1 Check was done, ok.
415 A*           Flag = 2 Warning condition.
415 A*
415 AC     zzchk8        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
650cAc                   exsr      zzrcvpocheck
     C                   eval      w8mfdt = 0
415mD**                   Z-ADD0         MFGD
     C                   eval      w8exdt = 0
415mD**                   Z-ADD0         EXPD
     *
     *  Move screen date into correct date check field.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      w8mfdt = w8dte
     C                   eval      w8exdt = 0
500f C                   eval      svexdt = 0
     C                   when      itflgd = 'Y'
     C                   eval      w8exdt = w8dte
     C                   eval      w8mfdt = 0
500f C                   eval      svmfdt = 0
     C                   endsl
     *
     *  Verify expiration date.
     *
     C                   if        itflgd = 'Y'  and
500fMC                             immflg <> 'Y'
500fMC                   if        w8exdt = 0
500fDC*                            immflg <> 'Y'  and
500fDC*                            w8exdt = 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
417kA*  Moved code here to calculate CKEXDT
417aA*  Verify Expiration date is within parameter (# of days out)     days)
417aA*  Calculate (Today + # days out)  = CKEXDT                       days)
417aA*
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      today         $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imoday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     ckexdt        parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dDC**                 move      today         g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      todyj = g$jd
417aA*
500dDC**   todyj         add       imoday        j$jd
500dDC**                 exsr      jtog$
500dDC**                 eval      date16 = j$date
417aA*
500dDC**                 move      date16        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        ckexdt
417aA*
     C                   if        w8exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w8exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w8exdt
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
510cAC                   move      $cvd8o        woexdt
     C                   if        expd <= today
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C                   endif
417kA*  Code to calculate CKEXDT was moved from here to above.
415dA*
415dA*  Verify Use by date.                                            days)
415dA*  Calculate (Today + Dist Days)  = DATE1                         days)
415dA*  Calculate  (Use By - User Days) = DATE2                        days)
415dA*
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      today         $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imdday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     date1         parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     date2         parm      0             $cddateout
500dAC                   parm      0             $cdtimeout

500dDC**                 move      today         g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      todyj = g$jd
415dA*
500dDC**   todyj         add       imdday        j$jd
500dDC**                 exsr      jtog$
500dDC**                 eval      date16 = j$date
415dA*
500dDC**                 move      date16        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        date1
415dA*
500dDC**                 move      expd          g$date
500dDC**                 eval      dtfrmt = 1
500dDC**                 exsr      gtoj$
500dDC**                 eval      expdj = g$jd
415dA*
500dDC**                 eval      j$jd = expdj - imuday
500dDC**                 exsr      jtog$
500dDC**                 eval      date26 = j$date
415dA*
500dDC**                 move      date26        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        date2
415dA*
500dDC**                 move      date26        $cvd6i
500dDC**                 eval      $cvcmd = '*YMDMDY '
500dMC                   move      date2         $cvd8i
500dMC                   eval      $cvcmd = '*CMDMDY '
415dAC                   call      @cvtdt
415dAC                   parm                    $cvtdt
415dAC                   move      $cvd6o        date2o
415dA*
     C                   endif
     C                   endif
500fAC                   endif
     C                   endif
417eA***
417eA*  Verify Expire date and # of days out                           days)
417eA*  Allow warning and override                                     days)
500fDC*                  if        expd <> 0
500fMC                   if        expd <> 0     and
500fMC                             w8exdt <> 0
417eAC                   if        svexdt <> w8exdt
417eAC                   eval      dtchk = *off
510eMC                   eval      ocovr = *off
510eDC*                  eval      odovr = *off
417eAC                   endif
417e *
417eAC                   if        dtchk = '2'  and
417eAC                             ovrrid = *on
510eMC                   eval      ocovr = *on
510eDC*                  eval      odovr = *on
417eAC                   eval      dtchk = *on
417eAC                   endif
417e *
417eMC                   if        dtchk <> '1'
417eAC                   eval      dtchk = *on
417eA*
417eA*   If EXPD > /CKEXDT - Reject.
417eA*
417eAC                   if        expd > ckexdt
740cAC                             and $immflg <> 'Y'
417eAC                   eval      error = *on
417eAC                   eval      dtchk = '2'
417eAC                   eval      warn = *on
417eAC                   eval      *in24 = *on
417eAC                   eval      *in04 = *on
417eAC                   eval      errmsg = *blanks
417eAC                   eval      erused = w8exdt
417eAC                   eval      erdisd = imoday
417eAC                   exsr      zm3243
417eAC                   endif
417e *
417eAC     error         cabeq     *on           enderr
417e *
417eAC                   endif
500fDC***                eval      dtchk = *off
417eMC                   eval      expd = date2
417eAC                   endif
     *
415dA*
415dA*  Verify Use by date.                                            days)
500fA*  Change to use DTCHK3 for override                              days)
415mD**         EXPD      IFNE 0
415mMC                   if        w8exdt <> 0
415dAC                   if        svexdt <> w8exdt
500fMC                   eval      dtchk3 = *off
500fDC*                  eval      dtchk = *off
415dAC                   endif
415d *
415dAC                   if        dtchk3 = '2'  and
415dAC                             ovrrid = *on
500cAC                   eval      odovr = *on
415dAC                   eval      dtchk3 = *on
415dAC                   endif
415d *
415dMC                   if        dtchk3 <> '1'
415dAC                   eval      dtchk3 = *on
417bA*
415dA*
415dA*   If DATE2 <= Date1 - Reject.
415dA*
415dAC                   if        date2 <= date1
415dAC                   eval      error = *on
415dAC                   eval      dtchk3 = '2'
415dAC                   eval      warn = *on
415dAC                   eval      *in25 = *on
415dAC                   eval      *in05 = *on
415dAC                   eval      errmsg = *blanks
415dAC                   eval      erused = w8exdt
415dAC                   eval      erdisd = imdday
415dAC                   eval      erusrd = imuday
415dAC                   eval      ersell = date2o
415dAC                   exsr      zm3229
415dAC                   endif
415d *
415dAC     error         cabeq     *on           enderr
415d *
415dAC                   endif
415dMC                   eval      expd = date2
415dAC                   endif
     *
500fA*  Change to use DTCHK4 for override                                  )
     C                   if        svmfdt <> w8mfdt  or
415lAC                             w8mfdt = 0
500fMC                   eval      dtchk4 = *off
     C                   endif
     *
500fMC                   if        dtchk4 = '2'  and
     C                             ovrrid = *on
510eAC                   if        mfgd > today
500cAC                   eval      obovr = *on
510eAC                   endif
510eAC                   if        today > ltstd8
510eAC                   eval      oeovr = *on
510eAC                   endif
     C                   eval      dtchk4 = *on
     C                   endif
     *
500fMC                   if        dtchk4 = '1'
416aAC                   eval      w8exdt = svexdt
416aAC                   endif
     *
413 D*R         OVRRID    IFEQ *OFF
500fMC                   if        dtchk4 <> '1'
500fMC                   eval      dtchk4 = *on
     *
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   if        w8mfdt = 0
     C                   eval      error = *on
500fMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
510hAc                   goto      endck8
     C                   else
     C                   if        w8mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w8mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
500fMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     **                   EXSR ZMQMSG
     C                   goto      enderr
     C                   else
     C                   move      $cvd6o        w8mfdt
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgd
     C                   if        mfgd > today
     C                   eval      error = *on
500fMC                   eval      dtchk4 = *off
500cAC                   eval      obovr = *off
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1010
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w8mfdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        expd
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      immday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC                   parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      $cddateout    $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     expd          parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      expd          $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        w8exdt

500dDC**                 eval      g$date = w8mfdt
500dDC**                 eval      dtfrmt = 2
500dDC**                 exsr      gtoj$
500dDC**                 eval      mfdtj = g$jd
     *
500dDC**   mfdtj         add       immday        j$jd
500dDC**                 eval      j$jd = j$jd - imuday
500dDC**                 exsr      jtog$
500dDC**                 move      j$date        $cvd6o
500dDC**                 move      $cvd6o        w8exdt
     *
500dDC**                 eval      $cvcmd = '*MDYCMD '
500dDC**                 move      w8exdt        $cvd6i
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        expd
     *
     *  Find the latest acceptable date.: Exp date -Dist days
     *
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w8exdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        ltstd8
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      ltstd8        $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imdday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     ltstd8        parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      ltstd8        $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        ltstd6

500dDC**                 eval      g$date = w8exdt
500dDC**                 eval      dtfrmt = 2
500dDC**                 exsr      gtoj$
500dDC**                 eval      exdtj = g$jd
     *
500dDC**                 eval      j$jd = exdtj - imdday
500dDC**                 exsr      jtog$
500dDC**                 move      j$date        $cvd6o
500dDC**                 move      $cvd6o        ltstd6
     *
500dDC**                 move      ltstd6        $cvd6i
500dDC**                 eval      $cvcmd = '*MDYCMD '
500dDC**                 call      @cvtdt
500dDC**                 parm                    $cvtdt
500dDC**                 move      $cvd8o        ltstd8
     *
     *   If Today's date is > Latest acceptable date - Reject.
     *
     C                   if        today > ltstd8
     C                   eval      error = *on
510eAC                   eval      oeovr = *off
500fMC                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ermday = immday
     C                   eval      ermfdt = w8mfdt
     C                   eval      erexdt = w8exdt
     C                   eval      erltst = ltstd6
     C                   eval      erdday = imdday
     C                   eval      eruday = imuday
     C                   exsr      zm3228
415lD**                   Z-ADD0         W8EXDT
     C                   endif
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     C                   endif
416aA*
416aA*   Check for ealier expiration dates (optional)                  days)
416aA*
416aA*     See if we can skip the check.                               days)
416aA*
416aAC                   if        w8exdt = 0  or
416aAC                             svexck <> '2'  and
416aAC                             svexck <> '3'
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aA*     Set warning check flag.                                     days)
416aA*
416aAC                   if        svexdt <> w8exdt
416aAC                   eval      dtchk2 = *off
500cMC                   eval      oaovr = *off
510eAC                   eval      ofovr = *off
510cDC*                  eval      cwovr = *off
416aAC                   endif
416aA*
416aAC                   if        dtchk2 = '2'  and
416aAC                             ovrrid = *on
510eAC                   if        immflg = 'Y'
510eMC                   eval      oaovr = *on
510eAC                   else
510eAC                   eval      ofovr = *on
510eAC                   endif
416aAC                   eval      dtchk2 = *on
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aAC     dtchk2        cabeq     '1'           skpxck
416aA*
416aA*     Do actual check                                             days)
416aA*
416aAC                   eval      dtchk2 = *on
416aA*
416aA*       Get date range of overflow slots.
416aA*
416aAC                   call      'GETEXPD'
416aAC                   parm      w1whse        $swhse            3 0
417nMC                   parm                    #sitem
417nD**                   PARM           #BITEM
416aAC                   parm                    $dfrom            8 0
416aAC                   parm                    $dto              8 0
416aA*
416aA*       If date comes after end of range
416aA*         Then date can be recevied so skip the rest of the check
416aA*
416aAC                   if        expd >= $dto
416aAC                   goto      skpxck
416aAC                   endif
416aA*
416aA*       Otherwise, see if it's an error or warning.
416aA*
416aA*         '1' = Allow Let it go through
416aA*         '2' = Error (Not Allowed)
416aA*         '3' = Warning.
416aA*
416aAC                   eval      error = *on
416aAC                   eval      *in26 = *on
416aAC                   eval      *in06 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   eval      erentd = expd
416aAC                   eval      ertod = $dto
416aAC                   select
416aAC                   when      svexck = '2'
416aAC                   eval      dtchk2 = *off
416aAC                   if        immflg = 'Y'
416aAC                   exsr      zm3232
416aAC                   else
416aAC                   exsr      zm3230
416aAC                   endif
416aAC                   when      svexck = '3'
416aAC                   eval      dtchk2 = '2'
416aAC                   eval      warn = *on
510eDC*                  eval      cwovr = *on
416aAC                   if        immflg = 'Y'
510eAC                   eval      oaovr = *on
416aAC                   exsr      zm3233
416aAC                   else
510eAC                   eval      ofovr = *on
510fDC*                  exsr      zm3231
510fMC                   exsr      zm2001
416aAC                   endif
416aAC                   endsl
416aA*
416aAC     error         cabeq     *on           enderr
416aA*
416aAC     skpxck        tag
416bA*
416bA*  See if we need to verify catch weight.
416bA*
416bAC     vrfycw        cabeq     *off          skipcw
416bA*
416bA*  CW can't be zero if forced entry is selected.
416bA*
416dA*    One exception for 'First time only' entry with Avg = 'Y'
416dA*
416bAC                   if        svcwfr = 'Y'  and
416bAC                             w8dwgt = 0
416dAC                   if        svcwen = '1'  or
416dAC                             svcwen = '2'  and
416dAC                             w8avg <> 'Y'
416bAC                   eval      error = *on
416bAC                   eval      *in29 = *on
416bAC                   eval      *in09 = *on
416bAC                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      errmsg = descsp(4)
500hAC                   other
416bAC                   eval      errmsg = desc(4)
500hAC                   endsl
416bAC                   exsr      zm0110
416dAC                   endif
416bAC                   endif
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w8avg <> 'Y'  and
     C                             w8avg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      errmsg = descsp(5)
500hAC                   other
     C                   eval      errmsg = desc(5)
500hAC                   endsl
     C                   exsr      zm1005
     C                   endif
416dA*
416dA*  When 'First time only' entry with Avg = 'Y'
416dA*    Then catch weight must be zero.
416dA*
416dAC                   if        svcwen = '2'  and
416dAC                             w8avg = 'Y'  and
416dAC                             w8dwgt <> 0
416dAC                   eval      error = *on
416dAC                   eval      *in29 = *on
416dAC                   eval      *in09 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   exsr      zm3234
416dAC                   endif
     *
     *
     *  When more than one qty is entered, catch weight average must be N
     *
416dA*    One exception for 'First time only' entry with Avg = 'Y'
416dA*
     C                   select
     C                   when      w3qt01 <> 0  and
     C                             w8avg = 'Y'  and
416dAC                             svcwen <> '2'
     C                   if        w3qt02 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      errmsg = descsp(5)
500hAC                   other
     C                   eval      errmsg = desc(5)
500hAC                   endsl
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w3qt02 <> 0  and
     C                             w8avg = 'Y'  and
416dAC                             svcwen <> '2'
     C                   if        w3qt01 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      errmsg = descsp(5)
500hAC                   other
     C                   eval      errmsg = desc(5)
500hAC                   endsl
     C                   exsr      zm2101
     C                   endif
     *
     C                   endsl
416dA*
416dA*  Skip catch weight variance check when ...
416dA*    "First time only" entry
416dA*
416dAC                   if        svcwen = '2'
650fA*      Skip variance check once qty has been received for item.
650fAC                             and (pdqrc1 > 0
650fAC                             or   pdqrc2 > 0
650fAC                             or   pdqrc3 > 0)
650fAC
413dAC                   goto      skipcw
416dAC                   endif
     *
     *  Catch weight variance check.
     *
     C                   if        svdwgt <> w8dwgt
     C                   eval      wtchk = *off
     C                   endif
     *
     C                   if        wtchk = '2'  and
     C                             ovrrid = *on
     C                   eval      wtchk = *on
     C                   endif
     *
     C                   if        wtchk <> '1'
     C                   eval      wtchk = *on
     *
     *   If catch weight >0,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     *
     C                   if        w8dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
DRYaAC                   eval      hostcw0 = 0
DRYaAC                   eval      hostcw2dec = 0
     *
     C                   if        w8avg = 'Y'
     C                   eval      exwgt = itswgt
700bDC*                  eval      wotcw = w8dwgt
700bMC                   eval      wotcw = cnvwgt
     C                   else
416bAC                   if        svcwen = '2'
750aA /free
750aA   exwgt = pdqor1 * itswgt;
750aA   if pdqor2 > 0 and itumq2 > 0;
750aA     exwgt = exwgt + (pdqor2 * (itswgt /itumq2));
750aA   endif;
750aA   if pdqor3 > 0 and itumq3 > 0;
750aA     exwgt = exwgt + (pdqor3 * (itswgt /itumq3));
750aA   endif;
750aA /end-free
750aDC*    pdqor1        mult      itswgt        exwgt

DRYaA* If specific client, use imported c/w value for variance checking if
DRYaA* it's numeric, otherwise, use standard comparison tests.

DRYaAC                   eval      hostUnitWgt  = 0
DRYaAC                   eval      rcvUnitWgt  = 0

DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   eval      hostcwa = %subst(pdmms1:9:7)
DRYaAC     digits        check     hostcwa                                68
DRYaAC                   if        *in68 = *off
DRYaAC                   eval      hostcw0 = %dec(%subst(pdmms1:9:7):7:0)
DRYaAC                   move      hostcw0       hostcw2dec

DRYaAC                   eval      qtyord  = 0
DRYaAC                   eval      qtyord1 = 0
DRYaAC                   eval      qtyord2 = 0
DRYaAC                   eval      qtyord3 = 0

DRYaAC                   if        pdqor1 > 0
DRYaAC                   eval      qtyord1 = pdqor1
DRYaAC                   if        itumq2 > 0
DRYaAC                   eval      qtyord1 = qtyord1 * itumq2
DRYaAC                   endif
DRYaAC                   if        itumq3 > 0
DRYaAC                   eval      qtyord1 = qtyord1 * itumq3
DRYaAC                   endif
DRYaAC                   endif

DRYaAC                   if        pdqor2 > 0
DRYaAC                   eval      qtyord2 = pdqor2
DRYaAC                   if        itumq3 > 0
DRYaAC                   eval      qtyord2 = qtyord2 * itumq3
DRYaAC                   endif
DRYaAC                   endif

DRYaAC                   if        pdqor3 > 0
DRYaAC                   eval      qtyord3 = pdqor3
DRYaAC                   endif

DRYaAC                   eval      qtyord = qtyord1 + qtyord2 + qtyord3

DRYaAC                   eval      exwgt = 0
DRYaAC                   eval      qtyrcv = 0
DRYaAC                   eval      qtyrcv1 = 0
DRYaAC                   eval      qtyrcv2 = 0

DRYaAC                   if        w3qt01 > 0
DRYaAC                   eval      qtyrcv1 = w3qt01
DRYaAC                   if        itumq2 > 0
DRYaAC                   eval      qtyrcv1 = qtyrcv1 * itumq2
DRYaAC                   endif
DRYaAC                   if        itumq3 > 0
DRYaAC                   eval      qtyrcv1 = qtyrcv1 * itumq3
DRYaAC                   endif
DRYaAC                   endif

DRYaAC                   if        w3qt02 > 0
DRYaAC                   eval      qtyrcv2 = w3qt02
DRYaAC                   if        itumq3 > 0
DRYaAC                   eval      qtyrcv2 = qtyrcv2 * itumq3
DRYaAC                   endif
DRYaAC                   endif

DRYaAC                   eval      qtyrcv = qtyrcv1 + qtyrcv2

DRYaAC                   eval      hostUnitWgt = hostcw2dec / qtyord
700bDC*                  eval      rcvUnitWgt = w8dwgt / qtyrcv
700bMC                   eval      rcvUnitWgt = cnvwgt / qtyrcv
DRYaAC                   eval      wgtDiff = hostUnitWgt - rcvUnitWgt
DRYaAC                   eval      caltol1 = %abs(wgtDiff) / hostUnitWgt

DRYaAC                   if           pdqor2 > 0
DRYaAC                             or w3qt02 > 0
DRYaAC                   eval      qtyDiff  = qtyord - qtyrcv
DRYaAC                   eval      caltol2  = %abs(qtyDiff) / qtyord
DRYaAC                   endif

DRYaAC                   else
DRYaAC     w3qt01        mult      itswgt        exwgt
DRYaAC                   endif
DRYaAC                   endsl

416bAC                   else
750aA /free
750aA   exwgt = w3qt01 * itswgt;
750aA   if w3qt02 > 0 and itumq2 > 0;
750aA     exwgt = exwgt + (w3qt02 * (itswgt /itumq2));
750aA   endif;
750aA   if w3qt03 > 0 and itumq3 > 0;
750aA     exwgt = exwgt + (w3qt03 * (itswgt /itumq3));
750aA   endif;
750aA /end-free
750aDC*    w3qt01        mult      itswgt        exwgt
416bAC                   endif
700bDC*                  eval      wotcw = w8dwgt
700bMC                   eval      wotcw = cnvwgt
     C                   endif
     *
     *    Iniz. flag used to skip variance check if = *ON.
     *
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
650fA*
650fA**   Iniz. fields used to hold low/high variance.
650fAC                   eval      prg1c = 0
650fAC                   eval      prg2c = 0
     *
     *    Use item variance % if it exists
     *
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
DRYaA*
DRYaA*     Don't do following extended weight calcs if you're using
DRYaA*     Dairyland's imported c/w method for comparing wgt tolerance.
DRYaAC                   select
DRYaAC                   when      hostcw2dec = 0
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     itswgt        add       ihvar         ihrng
     *
DRYaAC                   endsl
     C                   endif
     *
     *     Check CW variance if CW > 0
     *
     C                   if        w8dwgt <> 0
DRYaAC                   if        hostcw2dec > 0
DRYaA*     Use Dairyland's tests for comparing wgt and qty tolerances.
DRYaAC                   exsr      zzchkt1
DRYaAC                   else
     C                   exsr      zzchkt
DRYaAC                   endif
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
416bA*
416bAC     skipcw        tag
     *
     C     enderr        tag
     *
     *   Save screen fields.
     *
     C                   eval      svdwgt = w8dwgt
     C                   eval      sdqrc1 = w3qt01
     C                   eval      sdqrc2 = w3qt02
     C                   eval      svmfdt = w8mfdt
415dAC                   eval      svexdt = w8exdt
     *
     C     endck8        endsr
417iA*----------------------------------------------------------------
417iA*
417iA*  ZZCHK9   Screen 9 error checking.
417iA*
417iAC     zzchk9        begsr
417iAC                   eval      error = *off
650cAc                   exsr      zzrcvpocheck
417iA*
417iA*
417iAC     endck9        endsr
417iA*
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZCHK10  Screen 10 error checking.
700cA*
700cAC     zzchk10       begsr
700cAC                   eval      error = *off
700cAC                   eval      errflg = *off
700cAc                   exsr      zzrcvpocheck
700cA*
700cAC                   eval      $cbcmd = '*UPC    '
700cAC                   eval      $cbbar = w10upc
700cAC                   call      'CVTBAR'
700cAC                   parm                    $cbcmd
700cAC                   parm                    $cbbar
700cAC                   parm                    $cbcod
700cAC                   parm                    $cbdec
700cAC                   parm                    $cbdsc
700cAC                   parm                    $cbpos
700cAC                   parm                    $cbtyp
700cAC                   parm                    $cbv1
700cAC                   parm                    $cbv2
700cAC                   parm                    $cbrtn
700cAC                   parm                    $cberm
740fAC                   parm      phven         $cbven           10 0
740fAC                   parm                    $cvtdata
740fAC                   parm                    $cvtdata2
700cA*
700cAC                   if        $cbrtn = '*OK'
700cAC                   eval      w10upc = $cbv2
700cAc                   eval      btype = %trimr($cbdsc)
700cAC                   endif
700cA*
700cA*   Right adjust UPC code.
700cA*
700cAC                   eval      $cstr = *blanks
700cAC                   movel     w10upc        $cstr
700cAC                   call      'ADJUST'
700cAC                   parm      '*RIGHT  '    $ccmd
700cAC                   parm                    $cstr
700cAC                   move      $cstr         kyupc
700cA*
700cAC                   if        $cbrtn <> '*OK'
700cAC                   eval      error = *on
700cAC                   eval      *in29 = *on
700cAC                   eval      *in09 = *on
700cAC                   movel     $cberm        errmsg
700cAC                   exsr      zm0105
700cAC                   goto      endck10
700cAC                   endif
700cAC     endck10       endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZCHKT   Screen 3 error check totals
415 A*
415 AC     zzchkt        begsr
650aDC**                 eval      error = *off
     *
     *     Compare total catchweight to expected catchweight
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
416bAC                   eval      erexwt = exwgt
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   exsr      zm23
DRYaAC                   other
     C                   exsr      zm19
DRYaAC                   endsl
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
416bAC                   eval      erexwt = exwgt
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   exsr      zm23
DRYaAC                   other
     C                   exsr      zm19
DRYaAC                   endsl
     C                   endif
     *
     C                   endsr
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA*  ZZCHKT1  Screen 8 error checks:
DRYaA*           1. Compare imported cw to entered cw.
DRYaA*           2. Compare ordered qty to received qty.
DRYaA*
DRYaAC     zzchkt1       begsr
     *
     C                   if        hvskp = *off
     C                             and caltol1 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      caltol1x100 = caltol1 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Wgt tol% '
     C                                      + %triml(%editc(caltol1x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C                   if        hvskp = *off
     C                             and caltol2 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      caltol2x100 = caltol2 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      errmsg = 'Qty tol% '
     C                                      + %triml(%editc(caltol2x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   exsr      zm0105
     C                   goto      endckt1
     C                   endif

     C     endckt1       endsr
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
415gA*
415gA*  Test for F8 - Mark/UnMark for export
415gA*
415gAC                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhs3 = w1whse
     C                   eval      $lpo3 = wopo
     C                   eval      $lcmd = '*MRKUNM '
     C                   eval      $lrtn = *blanks
     C                   call      'PO111'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ'
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   eval      refrsh = *on
     C     fileky        chain(n)  pohdr                              79
     C                   exsr      scr02i
     C                   endif
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
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
610a *      F07 - Mark line as touched (X)
610a C                   if        *inkg
SVLbAC                   if        client = saval
SVLa C                   eval      woyes = '9'
SVLa C                   else
610a C                   eval      woyes = 'N'
SVLbAC                   endif
     *
610a C                   if        woyes = 'N' or
610b C                             woyes = '9'
610a C                   exfmt     verify
610a C                   endif
610a C                   if        woyes = 'Y' or
610b C                             woyes = '1'
     **
     **
     *   Read PORCV.  If not found then add...
610a C     partky        setll     porcv
610a C     partky        reade     porcv                                  55
610a C                   if        *in55
610a C                   eval      porwhs = pdwhse
610a C                   eval      porpo = pdpo
610a C                   eval      porseq = pdseq
610a *
610aAC                   move      #jobdt        $cvd6i
610aAC                   eval      $cvcmd = '*MDYCMD '
610aAC                   call      @cvtdt
610aAC                   parm                    $cvtdt
610aAC                   eval      pordte = $cvd8o
610aDC**** #jobdt        mult      10000.01      wrkdte
610aDC**** 20000000      add       wrkdte        pordte
610a C                   eval      portim = #jobtm
610a C                   eval      porusr = #user
610a C                   eval      poremp = $emp#
610a C                   eval      portrn = 0
     **                   Z-ADD0         PORLIC
610a C                   eval      porlic = *blanks
610a C                   eval      porlbl = 0
610a C                   eval      poract = 'X'
610aAC                   eval      poredt = 0
610aAC                   eval      poreti = 0
610a C                   write     porrec
6l0a C                   else
610aA*    Release lock if record found.
610aAC                   unlock    porcv
610a C                   endif
610a C                   eval      refrsh = *on
610a C                   exsr      scr02i
610a C                   endif
610a C                   endif
     *
     *      F20 - Accept Warning.
415 A*      F10 - Accept Warning.
     *
     C                   if        *inku  or
415 AC                             *inkj
     C                   eval      ovrrid = *on
415 AC                   else
415 AC                   eval      ovrrid = *off
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
415 D**     F20 - Accept Warning.
415 D**
415 D**         *INKU     IFEQ *ON
415 D**                   MOVE *ON       OVRRID
415 D**                   ENDIF
     *
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm4
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Line #.
     *
     C                   when      row# = 5  and
415kMC                             #lline <> '16'  or
415gAC                             row# = 8  and
415kMC                             #lline = '16'
    D*R                   MOVE *ON       *IN12
415gD**                   MOVE '*LOOKUP '$LCMD
415kMC                   if        #lline = '16'
415gAC                   eval      $lcmd = '*SELEC16'
415gAC                   else
415gAC                   eval      $lcmd = '*SELECT '
415gAC                   endif
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo = wopo
     C                   eval      $lline = 0
     C                   eval      $lpitm = *blanks
     C                   call      'PO910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w4line = $lline
     C                   eval      w4item = $lpitm
     C                   endif
     *
     *     Item #.
     *
     C                   when      row# = 6  and
415kMC                             #lline <> '16'  or
415gAC                             row# = 10  and
415kMC                             #lline = '16'
    D*R                   MOVE *ON       *IN12
415gD**                   MOVE '*LOOKUP '$LCMD
415kMC                   if        #lline = '16'
415gAC                   eval      $lcmd = '*SELEC16'
415gAC                   else
415gAC                   eval      $lcmd = '*SELECT '
415gAC                   endif
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo = wopo
     C                   eval      $lline = 0
     C                   eval      $lpitm = *blanks
     C                   call      'PO920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w4line = $lline
     C                   eval      w4item = $lpitm
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 6.
     *
     C     zzcmd6        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm6
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 7.
     *
     C     zzcmd7        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm7
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm7        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZCMD8   User defined command keys for screen 8.
415 A*
415 AC     zzcmd8        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
700bA*
700bA*      F7 - kilograms/Pounds toggle
700bA*
700bAC                   if        *inkg
700bAC                   eval      cmdtkn = *on
700bAC                   if        KiloLbs = 'P'
700bAC                   eval      KiloLbs = 'K'
700bAC                   eval      dspuom  = 'Kgs'
700bAc                   eval      *in67 = *off
700bAC                   else
700bAC                   eval      KiloLbs = 'P'
700bAC                   eval      dspuom  = 'Lbs'
700bAc                   eval      *in67 = *on
700bAC                   endif
700bAC                   goto      endcm8
700bAC                   endif
     *
     *      F20 - Accept Warning.
     *      F10 - Accept Warning.
     *
DRYaA* If specific client, do not allow override for c/w difference.
DRYaA*
DRYaAC                   if        (*inku or *inkj) and
700bAC                             wtchk = '2' and
DRYaAC                             client = Dairyland
DRYaAC                   eval      cmdtkn = *on
DRYaAC                   eval      error = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   movel     desc(7)       errmsg
DRYaAC                   exsr      zm0105
DRYaAC                   goto      endcm8
DRYaAC                   endif
     *
     C                   if        *inku  or
     C                             *inkj
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
510gA*      F11 - Manufacturer code decipher
510gA*
510gAc                   if        *inkk
510lA * f11 is only valid on date sensitive items
510lAc                   If        itflgd = 'Y' or immflg = 'Y'
510gAc                   eval      $lmfr#    = phven
510gAc                   eval      $lmfritem = pdvitm
510gAc                   eval      $ldakitem = pditem
510iAc                   eval      $lupc     = w2upc
510kAc                   eval      ddcode = *off
510jDc*                  call      'MF200'
510jMc                   call      'MF200'                              66
510gAC                   parm                    $lparm
510gAC                   parm      0             $lexpdat          6 0
510gAC                   parm      0             $lmfrdat          6 0
510iAC                   parm                    $lupc            20
640bAC                   parm      ' '           $ldecvalue       15
510lAc                   else
510lac                   exsr      zm13250
510lAc                   endif
510kA * Set ddcode if date returned is invalid
510kAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
510kAc                   select
510kAc                   when      $lexpdat = 0 and $lmfrdat = 0
510kAc                   eval      ddcode = *on
510kA
510kAc                   when      $lexpdat <> 0
510kAc                   eval      $cvcmd = '*MDYEDT'
510kAc                   move      $lexpdat      $cvd6i
510kAc                   call      @cvtdt
510kAC                   parm                    $cvtdt
510kAC                   if        $cvrtn = '*PGMQ   '
510kAC                   eval      ddcode= *on
510kAc                   endif
510kA
510kAc                   when      $lmfrdat <> 0
510kAc                   eval      $cvcmd = '*MDYEDT'
510kAc                   move      $lmfrdat      $cvd6i
510kAc                   call      @cvtdt
510kAC                   parm                    $cvtdt
510kAC                   if        $cvrtn = '*PGMQ   '
510kAC                   eval      ddcode= *on
510kAc                   endif
510kAc                   other
510kAc
510kAc                   endsl
510kAc                   endif
640bAc                   exsr      zzmfrdates
510gAC                   if        wodte = 'Mfr date'
510gAC                   eval      w8dte  = $lmfrdat
510gAc                   endif
510gAC                   if        wodte = 'Exp date'
510gAC                   eval      w8dte = $lexpdat
510gAC                   endif
510gAc                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr
417iA*----------------------------------------------------------------
417iA*
417iA*  ZZCMD9   User defined command keys for screen 9.
417iA*
417iAC     zzcmd9        begsr
417iA*
417iA*  Command keys to check BEFORE verification and update.
417iA*
417iAC                   if        cmdchk = '*BEFORE '
417iA*
417iAC                   endif
417iA*
417iA*  Command keys to check AFTER verification and update.
417iA*
417iAC                   if        cmdchk = '*AFTER  '
417iA*
417iAC                   endif
417iA*
417iAC     endcm9        endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZCMD10  User defined command keys for screen 10.
700cA*
700cAC     zzcmd10       begsr
700cAC                   eval      cmdtkn = *off
700cA*
700cA*  Command keys to check BEFORE verification and update.
700cA*
700cAC                   if        cmdchk = '*BEFORE '
700cA*
700cA*  Test for F4 - Lookup
700cA*
700cAC                   if        *inkd
700cAC                   eval      cmdtkn = *on
700cAC                   z-add     0             row#
700cAC                   eval      row = rowin
700cAC                   z-add     0             col#
700cAC                   eval      col = colin
700cAC                   select
700cA*
700cA*
700cAC                   other
700cA*
700cA*     Cursor not on a valid lookup field.
700cA*
700cAC                   eval      error = *on
700cAC                   exsr      zm9905
700cAC                   endsl
700cAC                   goto      endcm10
700cAC                   endif
700cA*
700cAC                   endif
700cA*
700cA*  Command keys to check AFTER verification and update.
700cA*
700cAC                   if        cmdchk = '*AFTER  '
700cAC                   endif
700cAC     endcm10       endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCNVWGT  Setup converted weight field.
700ba*
700bAC     zzcnvwgt      begsr
700bA*
700ba*    If in kilograms mode, convert into pounds for processing.
700bA*
700bA* If item options is setup as kgs and user enters kgs no conversion
700bA* If item options is setup as kgs and user enters lbs need conversion
700bA* If item options is setup as lbs and user enters lbs no conversion
700bA* If item options is setup as lbs and user enters kgs need conversion
700bA /free
700bA   select;
700bA     when IMkilolbs = 'K';
700bA       if KiloLbs = 'K';
700bA         eval cnvwgt = w8dwgt;
700ba       else;
700bA         eval(h) cnvwgt = w8dwgt / kgs2lbs;
700bA       endif;
700bA     other;
700bM       if KiloLbs = 'K';
700bM         eval(h) cnvwgt = w8dwgt * kgs2lbs;
700bM       else;
700bM         eval cnvwgt = w8dwgt;
700bM       endif;
700bA   endsl;
700bA /end-free
700bA
700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
415 AC                   call      'GETWHSE'
415 AC                   parm                    #user
415 AC                   parm      0             #whse             3 0
415 A*
415 AC                   eval      w1whse = #whse
     *
     C                   eval      w1po = *blanks
415 D**                   Z-ADD0         W1DOCK
700bA*
700bA*   Get Item Maintenance options.
700bA*
700bA /free
700bA    //wkwhse = $pwhse;
700bA    getimuom(#whse: IMkilolbs: IMUom);
700bA    select;
700bA      when IMkilolbs = 'K';
700bA        KiloLbs = 'K';
700bA        dspuom  = IMUom;
700bA        *in67 = *off;
700bA      other;
700bA        kiloLbs = 'P';
700bA        dspuom  = 'Lbs';
700bA        *in67 = *on;
700bA    endsl;
700bA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      wopo = w1po
     C                   eval      w2upc = *blanks
415fAC                   exsr      zztrcv
415fAC                   select
415fAC                   when      phstat = '0'
415fAC                   eval      wostat = sts00
415fAC                   when      phstat = '1'
415fAC                   eval      wostat = sts01
415fAC                   when      phstat = '2'
415fAC                   eval      wostat = sts02
415fAC                   when      phstat = '3'
415fAC                   eval      wostat = sts03
650gAC                   when      phstat = '4'
650gAC                   eval      wostat = sts04
650gAC                   when      phstat = '5'
650gAC                   eval      wostat = sts05
415fAC                   other
415fAC                   eval      wostat = *blanks
415fAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *
     C     podky1        setll     podtl1                               79
530aAC     nxtd          tag
218 MC     podky1        reade     podtl1                               7879
     C                   if        not *in79
530aA*
530aAC                   if        woline = 0
     C                   eval      woline = pdseq
530aAC                   else
530aAC     pdseq         cabne     woline        nxtd
530aAC                   endif
530aA*
     C                   else
     C                   eval      woline = 0
     C                   endif
     *
415 AC                   eval      woord1 = pdqor1
415 AC                   z-add     pdqor2        woord2
     *
     *   Item description and pack description.
     *
     C                   exsr      zzgeti
650eAc                   if        $lsavetrn = 0
650cAc                   exsr      zzrcvpo
650eAc                   else
650eAc                   exsr      zzrcvpocheck
650eAc                   endif
     *
     *   Get Unit of measure fields
     C                   eval      woum1 = *blanks
     C                   eval      woum2 = *blanks
     C                   exsr      zzuom
415 D**         WOUM2     IFEQ *BLANKS
415 D**                   MOVE *ON       *IN92
415 D**                   ELSE
415 D**                   MOVE *OFF      *IN92
415 D**                   ENDIF
     C                   eval      w3qt01 = 0
415 MC                   eval      w3qt02 = 0
415 AC                   eval      w3plt = 0
SVLaAC                   if        client = saval
SVLaAC                   eval      w3plt = 1
SVLaAC                   endif
415aAC                   eval      sdqrc1 = 0
415aAC                   eval      sdqrc2 = 0
415 D**                   Z-ADD0         W3EXDT
415 D**                   Z-ADD0         W3DWGT
415 D**                   MOVE 'N'       W3AVG
     *
415 D**         ITCWGT    IFNE 'Y'
415 D**                   MOVE *ON       *IN99
415 D**                   ELSE
415 D**                   MOVE *OFF      *IN99
415 D**                   ENDIF
415 D**         ITFLGD    IFNE 'Y'
415 D**                   MOVE *ON       *IN96
415 D**                   ELSE
415 D**                   MOVE *OFF      *IN96
415 D**                   ENDIF
417hA*
417hA*    Retrieve Item Lot/license plate tracking info.
417hAC                   eval      $lcmd = *blanks
417hAC                   eval      $lprg = #prog
417hAC                   eval      $lwhse = w1whse
417hAC                   eval      $litem = pditem
417hAC                   call      'GETLLP'
417hAC                   parm                    $lparm
417hA*
417hAC                   select
417hA*    Lot/license plate tracking values found.
417hAC                   when      $lrtn = '*OK     '
417hAC                   if        $llot = 'Y'
417hAC                   eval      lottrk = '*YES'
417hAC                   else
417hAC                   eval      lottrk = '*NO '
417hAC                   endif
417hAC                   if        $lltrk = 'Y'
417hAC                   eval      lictrk = '*YES'
417hAC                   else
417hAC                   eval      lictrk = '*NO '
417hAC                   endif
417hAC                   other
417hAC                   eval      lottrk = '*NO '
417hAC                   eval      lictrk = '*NO '
417hAC                   endsl
417hA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     C                   eval      woqt01 = $rrq1
     C                   eval      woqt02 = $rrq2
     C                   eval      woplet = $rrpal
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *
     C     zzfil6        begsr
     *
     *   Item description and pack description.
     C                   exsr      zzgeti
650eAc                   if        $lsavetrn = 0
650cAc                   exsr      zzrcvpo
650eAc                   else
650eAc                   exsr      zzrcvpocheck
650eAc                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *
     C     zzfil7        begsr
     C                   eval      wobat = $rord
     C                   eval      w7pal = $rrpal
416fD**                   Z-ADD0         W7LCNS
416f C                   eval      w7lcns = *blanks
     C                   if        w7pctr = 0
     C     partk2        setll     label2
     C                   endif
     C     partk2        reade     label2                               7879
     C                   if        not *in79
     C                   eval      w7tie = lbtie
     C                   eval      w7hi = lbhigh
     C                   add       1             w7pctr
     C                   endif
     *
     C                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZFIL8   Fill screen 3 fields with info from file.
415 A*
415 AC     zzfil8        begsr
     *
DRYaAC                   if           client = Dairyland
DRYaAC                   exsr      zzgtpdm
DRYaAC                   endif
     *
     C                   eval      w8dte = 0
     C                   eval      w8dwgt = 0
     C                   eval      w8avg = 'N'
415mAC                   eval      mfgd = 0
415mAC                   eval      expd = 0
500gAC                   eval      svmfdt = 0
500gAC                   eval      svexdt = 0
415mAC                   eval      dtchk = *off
510dAC                   eval      woexdt = 0
510dAC                   eval      woindt = 0
     *
     *   Set indicator to display/non-display weight fields.
     *
416bAC                   eval      vrfycw = *off
416bAC                   eval      *in82 = *off
416bA*
416bA*     First, see if catch weight entry is allowed.
416bA*
     C                   if        itcwgt <> 'Y'  or
416bAC                             svcwen = '3'
     C                   eval      *in93 = *on
416bAC                   eval      vrfycw = *off
     C                   else
     C                   eval      *in93 = *off
416bAC                   eval      vrfycw = *on
     C                   endif
416bA*
416bA*     Then see if we should block entry ...
416bA*       because catch weight previously entered.
416bA*
416bAC                   if        svcwen = '2'  and
416bAC                             pddwgt <> 0
416bAC                   eval      *in82 = *on
416dAC                   eval      *in93 = *on
416bAC                   eval      vrfycw = *off
416bAC                   endif
416bA*
416bA*     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
416bA*
416bAC                   select
416bAC                   when      svcwtp = '2'
416bAC                   eval      *in81 = *on
416bAC                   eval      w8avg = 'N'
416bAC                   eval      wocrcv = cwt(1)
416bAC                   when      svcwtp = '3'
416bAC                   eval      *in81 = *on
416bAC                   eval      w8avg = 'Y'
416bAC                   eval      wocrcv = cwt(2)
416bAC                   other
416bAC                   eval      *in81 = *off
416bAC                   eval      w8avg = 'N'
416bAC                   eval      wocrcv = cwt(2)
416bAC                   endsl
     *
     *   Initialize date fields.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   eval      wodte = 'Mfr date'
     C                   eval      *in94 = *off
     C                   when      itflgd = 'Y'
     C                   eval      wodte = 'Exp date'
     C                   eval      *in94 = *off
     C                   other
     C                   eval      wodte = *blanks
     C                   eval      *in94 = *on
     C                   endsl
     *
     C                   endsr
417iA*----------------------------------------------------------------
417iA*
417iA*  ZZFIL2   Fill screen 2 fields with info from file.
417iA*
417iAC     zzfil9        begsr
417iA*
417iAC                   eval      w9lotc = *blanks
417iA*
417iAC                   endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZFIL10  Fill screen 10 fields with info from file.
700cA*
700cAC     zzfil10       begsr
700cA*
700cAc                   eval      w10upc = ' '
700cA * do we already have breakdown upc loaded?
700cAc                   if        $lsavetrn = 0
700cAc                   exsr      zzrcvpo
700cAc                   else
700cAc                   exsr      zzrcvpocheck
700cAc                   endif
700cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
415 A*
415 A*   Get item
415 A*
700cA * add dri to get data from itemfld
700cA /free
700cA       exsr clr$item;

700cA       $itWhse = w1whse;
700cA       $ititem = woitm#;

700cA       $dricommand = '*ITEM';
700cA       $drisubcmd  = '%GETALL';
700cA       $drisys2upd = 'D';
700cA       chk4err = *on;
700cA       zmflag  = *off;
700cA       exsr zzzdricop;
700cA       if error = *on;
700cA         $ifucicde = '1';
700cA         $ifrcvmth = '1';
700cA         $ifbrdflg = ' ';
700cA       endif;
700cA /end-free
     C                   eval      woitem = *blanks
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
416dA*
416dA*  Save information about selected item (Item that was sent in)
416dA*
416dAC                   eval      #otype = ittype
416dAC                   eval      #oitem = ititem
416dAC                   eval      #oswgt = itswgt
416dAC                   eval      #oum1 = itum1
416dAC                   eval      #oum2 = itum2
416dAC                   eval      #oum2q = itumq2
416dAC                   eval      #oswt2 = 0
416dAC                   if        #oum2q <> 0
416dAC     itswgt        div(h)    #oum2q        #oswt2
416dAC                   endif
416dAC                   eval      #oum3 = itum3
416dAC                   eval      #oum3q = itumq3
416dAC                   eval      #oswt3 = 0
416dAC                   if        #oum3q <> 0
416dAC     itswgt        div(h)    #oum2q        #oswt3
416dAC     #oswt3        div(h)    #oum3q        #oswt3
416dAC                   endif
415 A*
415 A*   Format item description
415 A*
     C                   eval      $iitem = woitm#
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
415 A*
415 A*   Get SSB item, if one exists
415 A*
414 AC                   eval      ssbflg = *off
415 AC                   if        ittype = ' '
415 AC                   call      'GETSSB'
415 AC                   parm      itwhse        $gwhse            3 0
415 AC                   parm      ititem        $gitem           15
415 AC                   parm      ' '           #bitem           15
415 AC                   parm                    #bdesc           30
415 AC                   parm                    #bpdsc           15
415 AC                   parm                    #bwhdp            5
415 AC                   parm                    #bstyp            1
415 AC                   parm                    #bum              2
415 AC                   parm                    #bum2             2
415 AC                   parm                    #bumq2            3 0
415 AC                   parm                    #bum3             2
415 AC                   parm                    #bumq3            3 0
415 AC                   parm                    #brtn             8
415 A*
415 AC                   if        #brtn = '*FOUND  '
415 AC                   eval      ssbflg = *on
415 AC                   endif
415 AC                   endif
415 A*
415 A*   See if item is an FS-WMS item or not.
415 A*
415 AC                   move      itdesg        iatest
415 AC                   if        iatest = '*'
415 AC                   eval      iaflag = *on
415 AC                   eval      *in64 = *off
415 AC                   else
415 AC                   eval      iaflag = *off
415 AC                   eval      *in64 = *on
415 AC                   endif
500 A
500 A*  ... Or department isn't live (this overrides iaflag).
500 A
500 AC                   call      'CHKLIVE'
640aAC                   parm      itwhse        $swhse
500 AC                   parm                    itwhdp
500 AC                   parm                    livestat          8
500 A
500 AC                   if        livestat = '*NOTLIVE'
500 AC                   eval      *in65 = *off
500 AC                   eval      iaflag = *off
500 AC                   eval      *in64 = *on
500 AC                   else
500 AC                   eval      *in65 = *on
500 AC                   endif
415 A*
415 A*   Get putaway option (Directed or Manual)
415 A*
415 AC                   eval      kycode = '*PICK   '
415 AC     opkey2        chain     optiond                            79
415 AC                   if        *in79
415 AC                   eval      opmput = 'N'
415 AC                   endif
415 A*
415 A*   Initialize indicator that displays pallet field.
415 A*
415 AC                   if        opmput = 'Y'
415 AC                   eval      *in96 = *off
415 AC                   else
415 AC                   eval      *in96 = *on
415 AC                   endif
415 A*
415 A*   Get ITEMMSC record for item.
415 A*
415 AC     imkey         chain     itemmsc                            79
415 AC                   if        *in79
415 AC                   eval      immflg = 'N'
415 AC                   eval      imdday = 0
415 AC                   eval      imuday = 0
415 AC                   eval      immday = 0
415 AC                   eval      imrg1c = 0
415 AC                   eval      imrg2c = 0
415 AC                   endif
415 A*
415 A*   Set screen 8 (date/weight) flag.
415 A*
416bD**         ITCWGT    IFEQ 'Y'
416bD**         ITFLGD    OREQ 'Y'
416bMC                   if        itflgd = 'Y'  or
415 AC                             immflg = 'Y'
415 AC                   eval      s8flag = *on
415 AC                   else
415 AC                   eval      s8flag = *off
415 AC                   endif
416bA*
416bAC                   if        itcwgt = 'Y'
416bAC                   if        svcwen = '1'  or
416bAC                             svcwen = '2'  and
416bAC                             pddwgt = 0
416bAC                   eval      s8flag = *on
416bAC                   endif
416bAC                   endif
415nA*
415nA*  If selected item is a Contract, Alias, SSB item .              . .
415nA*    Then get corresponding Base item.
415nA*
415nAC                   eval      #bitem = ititem
417nAC                   eval      #sitem = ititem
415nAC                   if        ittype = 'C'  or
415nAC                             ittype = 'A'  or
415nAC                             ittype = 'S'
415nAC                   call      'GETBASE'
415nAC                   parm      itwhse        $gwhse
415nAC                   parm      ititem        $gitem
415nAC                   parm      ' '           #bitem
415nAC                   parm                    #bityp            1
415nAC                   parm                    #bdesc
415nAC                   parm                    #bpdsc
415nAC                   parm                    #bwhdp
415nAC                   parm                    #bstyp
415nAC                   parm                    #bum1             2
415nAC                   parm                    #bum2
415nAC                   parm                    #bumq2
415nAC                   parm                    #bum3
415nAC                   parm                    #bumq3
415nAC                   parm      ' '           #bcitm           15
415nAC                   parm                    #bctyp            1
415nAC                   parm                    #bcdsc           30
415nAC                   parm                    #bcpds           15
415nAC                   parm                    #bcwdp            5
415nAC                   parm                    #bcstp            1
415nAC                   parm                    #bcum1            2
415nAC                   parm                    #bcum2            2
415nAC                   parm                    #bcuq2            3 0
415nAC                   parm                    #bcum3            2
415nAC                   parm                    #bcuq3            3 0
415nAC                   parm                    #brtn
415nAC                   endif
417nA*   Get slot item.
417nAC                   call      @getsi
417nAC                   parm      itwhse        $gwhse
417nAC                   parm      ititem        $gitem
417nAC                   parm      ' '           #sitem           15
417nAC                   parm                    #sityp            1
417nAC                   parm                    #sdesc           30
417nAC                   parm                    #spdsc           15
417nAC                   parm                    #srtn            10
417nAC                   parm                    #smsg            60
415fA*
415fA*   Get the picking slot for the item.
415fA*
415fAC                   if        itstyp = 'P'
415fAC                   eval      $scmd = '*LAST'
415fAC                   else
415fAC                   eval      $scmd = '*FIRST'
415fAC                   endif
415fAC                   call      'GETPSLT'
415fAC                   parm                    $scmd             8
415fAC                   parm      itwhse        $swhse
415nD**                   PARM           ITITEM
417nD**                   PARM           #BITEM
417nMC                   parm                    #sitem
415fAC                   parm                    wohome
416eAC                   parm      *blanks       $saisl            3
416eAC                   parm      *zeros        $sloc             3 0
416eAC                   parm      *zeros        $srlvl            2 0
416eAC                   parm      *blanks       $shand            2
415fAC                   parm                    $srtn             8
415fA*
415fA*   Get preferred tie/high.
415fA*
415fAC                   call      'GETPTIHI'
415fAC                   parm      itwhse        prfwhs            3 0
415fAC                   parm                    ititem
415fAC                   parm                    prfti             4 0
415fAC                   parm                    prfhi             2 0
415fAC                   parm                    prfth             7
415fAC                   parm                    $lrtn
415fAC                   eval      wotihi = prfth
     *
     C                   endsr
DRYaA*----------------------------------------------------------------
DRYaA*
DRYaA*  ZZGTPDM  Get P/O Detail Misc. file
DRYaA*
DRYaAC     ZZGTPDM       Begsr
DRYaAC*
700bDC*    fileky        chain     podtlm
700bMC     podkey        chain     podtlm
     C                   if        not %found(podtlm)
     C                   eval      pdmms1 = ' '
     C                   endif
     *
     C                   Endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
415fAC                   eval      forevr = *on
416hAC                   eval      redspl = *off
     C                   eval      $rprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Define partial key for item tie/high definition file.
     *
     C     partk2        klist
     C                   kfld                    wobat
     C                   kfld                    w1whse
     *
     *  Define key for POHDR file.
     *
     C     fileky        klist
     C                   kfld                    w1whse
     C                   kfld                    wopo
     *
     *  Define key for PODTL file.
     *
     C     podkey        klist
     C                   kfld                    w1whse
     C                   kfld                    wopo
     C                   kfld                    woline
     C                   kfld                    woitm#
     *  Define partial key for PODTL file.
     *
     C     partky        klist
     C                   kfld                    w1whse
     C                   kfld                    wopo
     C                   kfld                    woline
219 A*
219 A*  Define partial key for PODTL file.
219 A*
219 AC     prtdky        klist
219 AC                   kfld                    w1whse
219 AC                   kfld                    wopo
     *
     *  Define key for PODTL1 file.
     *
     C     podky1        klist
     C                   kfld                    w1whse
     C                   kfld                    wopo
     C                   kfld                    woitm#
     *
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    w1whse
415eMC                   kfld                    kyupc
415eD**                   KFLD           W2UPC
     *
     *  Define key for UPC1 file.
     *
     C     upcky1        klist
     C                   kfld                    w1whse
     C                   kfld                    woitm#
     C                   kfld                    phven
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    woitm#
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    w1whse
     C                   kfld                    w7lcns
221 A*
221 A*     OPTIONS
221 A*
221 AC     opkey         klist
415 D*                    KFLD           W1WHSE
415 MC                   kfld                    wkwhse
221 AC                   kfld                    ocode
415 A*
415 A*  Define key for OPTIOND.
415 A*
415 AC     opkey2        klist
415 AC                   kfld                    kycode
415 AC                   kfld                    w1whse
415 AC                   kfld                    itwhdp
415 AC                   eval      kycode = '*PICK   '
415 A*
415 A*  Define key for LABEL2  file.
415 A*
415 AC     lbkey         klist
415 AC                   kfld                    $rord
415 AC                   kfld                    w1whse
415 A*
415 A*  Define key for ITEMMSC file.
415 A*
415 AC     imkey         klist
415 AC                   kfld                    itwhse
415 AC                   kfld                    ititem
415fA*
415fA*  Define full key for PODTL3 file.
415fA*
415fAC     detlky        klist
415fAC                   kfld                    pdwhse
415fAC                   kfld                    pdpo
415fAC                   kfld                    pdseq
416dA*
416dA*  Define key for POCTYPE file.
416dA*
416dAC     keypoc        klist
416dAC                   kfld                    w1whse
416dAC                   kfld                    wopo
416dAC                   kfld                    woline
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
218 AC                   eval      #pgmq = #prog
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse
     *
     C                   eval      w1whse = #whse
     *
510jA * determine if mfr decipher is available to client
510jAc                   eval      $lcmd = '*OPEN'
510jAc                   call      'MF200'                              66
510jAC                   parm                    $lparm
510jAC                   parm      0             $lexpdat          6 0
510jAC                   parm      0             $lmfrdat          6 0
510jAC                   parm                    $lupc            20
640bAC                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
415 AC                   setoff                                       kckl
415 AC                   eval      dtchk = *off
416aAC                   eval      dtchk2 = *off
500fAC                   eval      dtchk3 = *off
500fAC                   eval      dtchk4 = *off
415 AC                   eval      qtchk = *off
415 AC                   eval      wtchk = *off
415kA*
415kA*   Get screen size being used.
415kA*
415kAC                   call      'PIRRFSCR'
415kAC                   parm      '*GET'        #lcmd             8
415kAC                   parm                    #lline            2
415kAC                   parm                    #lcol             3
ISYbD*  Not anymore ---> Force to 16 line version for ISupply.
ISYbM*  Force to 8 line version for ISupply.
ISYaAC                   if        client = isupply
ISYbDC**                 eval      #lline = '16'
ISYbMC                   eval      #lline = '08'
ISYaAC                   eval      #lcol = '020'
ISYaAC                   Endif
     *
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse            3 0
     C                   parm                    woitm#           15
     C                   parm                    w3qt01
218 MC                   parm      0             w3qt02            5 0
218 D*R                   PARM           W3QT02
     C                   parm      0             w3qt03            5 0
     C                   parm                    wopo
     C                   parm                    w1ven            11 0
     C                   parm                    w1vnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm                    $rexpd            8 0
417m C                   parm      0             $rfifo            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    $rslot           12
218 AC                   parm      0             $rseq
218 AC                   parm                    $rrpck            1
218 AC                   parm                    $rplbl            1
219 AC                   parm                    w3twgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *
221 D*R                   MOVE *ON       LFLAG   1
221 MC                   eval      lflag = *off
     C                   eval      refrsh = *on
415iD**                   EXSR ZZLCNS
415 AC                   eval      ocode = '*SYSTEM '
415 AC                   eval      wkwhse = 0
415 AC     opkey         chain     options                            79
415 AC                   eval      sydata = opdata
415 AC                   if        *in79
415 AC                   eval      opcapc = 'Y'
413fAC                   eval      opwrnc = 'N'
413fAC                   eval      oprg1c = 0
413fAC                   eval      oprg2c = 0
413f C                   eval      opicw = 'N'
770aAC                   eval      opdckv = 'N'
413fAC                   endif
770aA
770aAc                   if        opdckv = 'Y'
770aAc                   eval      dockvue = *on
770aAc                   else
770aAc                   eval      dockvue = *off
770aAc                   endif
770aA
415 A*
415 A*    Get User's employee number to be written to PORCV file
415 A*    if any records are flagged as touched.
415 A*
415 AC                   call      'GETUSER'
415 AC                   parm      #user         $code            10
415 AC                   parm      0             $whse             3 0
415 AC                   parm      0             $emp#             5 0
415 AC                   parm      *blanks       $fnam            15
415 AC                   parm      *blanks       $init             1
415 AC                   parm      *blanks       $lnam            20
415 AC                   parm      *blanks       $whdp             5
415 AC                   parm      *blanks       $styp             1
415 AC                   parm      *blanks       $shft             6
415 AC                   parm      *blanks       $crew             6
415 AC                   parm      0             $nhrs             3 1
415 AC                   parm      *blanks       $rtn              8
500hAC                   parm                    e$bpu             1
500hAC                   parm                    e$lng             2
500hAC                   if        $rtn <> '*OK'
500hAC                   eval      e$lng = 'EN'
500hAC                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
221 A*  ZZLCNS   Get use generic license option
     *
221 AC     zzlcns        begsr
     *
221 A*   Get use generic license option.
221 AC                   eval      lflag = *off
416aAC                   eval      svexck = *on
416bAC                   eval      svcwen = *on
416bAC                   eval      svcwtp = *on
416bAC                   eval      svcwfr = 'N'
417cAC                   eval      svrupc = 'N'
221 AC                   eval      ocode = '*RCVLBL '
415 AC                   eval      wkwhse = w1whse
     *
221 AC     opkey         chain     options                            79
221 AC                   if        not *in79
415 AC                   eval      rcdata = opdata
221 AC                   if        opplcn = 'Y'
221 AC                   eval      lflag = *on
221 AC                   endif
DRYaAC                   if        client = Dairyland
DRYaAC                   eval      opcwen = '2'
DRYaAC                   eval      opcwtp = '2'
DRYaAC                   eval      opcwfr = 'Y'
DRYaAC                   endif
416aAC                   eval      svexck = opexck
416bAC                   eval      svcwen = opcwen
416bAC                   eval      svcwtp = opcwtp
416bAC                   eval      svcwfr = opcwfr
417cAC                   eval      svrupc = oprupc
760aAC                   eval      svnupc = opnupc
221 AC                   endif
     *
221 AC                   endsr
     *
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZPDIR   Directed putaway
415 A*
415 AC     zzpdir        begsr
     *
     C                   call      'RC160'
     C                   parm      '*RECEIVE'    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    woitm#
     C                   parm                    w3qt01
     C                   parm                    w3qt02
     C                   parm      0             w3qt03
     C                   parm                    wopo
     C                   parm                    w1ven
     C                   parm                    phvnam
     C                   parm                    pdvitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      expd          $rexpd
417m C                   parm      0             $rfifo
     C                   parm                    w1dev
     C                   parm                    w1form
     C                   parm      *blanks       $rslot
     C                   parm                    woline
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w8twgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
     C                   goto      endpdr
     C                   endif
     *
     **                   ADD  $RRQ1     $PRSQT
     **                   ADD  $RRQ2     $PRSQT
     **                   ADD  $RRQ3     $PRSQT
     *
500 DC**                 if        lflag = *on
500 AC                   eval      $lflag = lflag
500 AC                   if        lflag = *off
500 AC                   eval      $lcmd = '*LICONLY'
500 AC                   else
     C                   eval      $lcmd = '*CHANGE '
500 AC                   endif
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo2 = w1po
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w3qt01
     C                   eval      $lrq2 = w3qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w3plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
500 AC                   eval      $lven = phven
500 AC                   eval      $lvnam = phvnam
500 AC                   eval      $lvitm = pdvitm
417hA*
417hA*    Lot tracking item - Pass single char flag to license entry pgm
417hAC                   if        lottrk = '*YES'
417hAC                   eval      $llott = 'Y'
417hAC                   else
417hAC                   eval      $llott = 'N'
417hAC                   endif
417hA*    Lic.tracking item - Pass single char flag to license entry pgm
417hAC                   if        lictrk = '*YES'
417hAC                   eval      $llict = 'Y'
417hAC                   else
417hAC                   eval      $llict = 'N'
417hAC                   endif
417hA*
417iAC                   eval      $lseq = pdseq
417iAC                   eval      $ldwgt = w8twgt
417iAC                   eval      $llotc = w9lotc
760bA /free
760bA     if clienthost = freshbyte;
760bA       $llotc = %subst(pdpo:1:6) +
760ba                %subst(%EditC(pdseq:'X'):3:3);
760bA     endif;
760bA /end-free
417iA*
720aA ** do we need to print box labels
720aA ** 4 and 6 print normal uom labels
720aAc                   if        $ifrcvmth = '4' and $lrq1 > 0 or
720aAc                             $ifrcvmth = '6' and $lrq1 > 0
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   eval      $bqty = $lrq1
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum1
740aMc                   eval      $buom =  $itum1
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown1 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
720aAc                   else
720aAc                   eval      $bqty = $lrq2
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum2
740aMc                   eval      $buom =  $itum2
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown2 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0 or $lrq2 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
720aAc                                   + ($lrq2 * $itumq3) + $lrq3
720aAc                   else
720aAc                   eval      $bqty = $lrq3
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum3
740aMc                   eval      $buom =  $itum3
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
     C                   call      'PO136'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
500 AC                   parm                    $lflag            1
417iAC                   parm                    $lseq             5 0
500 AC                   parm                    $lven
500 AC                   parm                    $lvnam
500 AC                   parm                    $lvitm
500 AC                   parm      expd          $rexpd
500 AC                   parm                    $pdev
500 AC                   parm                    $pform
417iAC                   parm                    $ldwgt            9 2
500 AC                   parm                    avgwt1
500 AC                   parm                    avgwt2
500 AC                   parm                    avgwt3
417iAC                   parm                    $llotc           30
500 AC                   parm                    womfdt
500 AC                   parm      0             wofifo
500 AC                   parm                    woupc
640bAc                   parm                    $ldecvalue
640bAC                   parm      mexpd         $lmfgex           8 0
640bAC                   parm      mfgdte        $lmfgdt           8 0
650bAc                   parm      ' '           $plpn            50
650bAc                   parm      ' '           $pgslcns         15
650bAc                   parm      ' '           $pbrand          10
650bAc                   parm                    $parms1
650cAC                   parm                    $lsavetrn
650dAc                   parm                    $pgtin           14
650dAc                   parm                    $pbcProdD         6 0
650dAc                   parm                    $pbclot          20
650dAc                   parm      0             $pw1pti
500 DC**                 endif
650cAC                   if        $lrtn = '*OK     '
650cAc                   eval      rcvpocomplete = *on
650cAC                   endif
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        immflg = 'Y'
500eAC     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = lbwhse
     C                   eval      pmpo = lbpo
     C                   eval      pmseq = lbseq
     C                   eval      pmitem = lbitem
     C                   eval      pmexpd = $rexpd
     C                   eval      pmmfgd = mfgd
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
500eAC                   if        not *in78
500eAC                   update    pmrec
500eAC                   else
     C                   write     pmrec
500eAC                   endif
417 A*
417 A*      Write record to item exception file for date override.
417 A*
510kA * add additional exception if date decipher error
510kAc                   if        ddcode = *on
510kAC                   eval      exerid = 'DD-CODE'
510kAC                   eval      exwhse = lbwhse
510kAC                   eval      exwhdp = lbwhdp
510kAC                   eval      exstyp = lbstyp
510kAC                   eval      exitem = lbitem
510kAC                   eval      dspo = lbpo
510kAC                   eval      dslbl = lblbl#
510kAC                   eval      dsexpd = $dto
510kAC                   eval      exfdis = dsfdis
510kAC                   eval      extdis = dstdis
510kAC                   eval      exgdte = lbsdte
510kAC                   eval      exgtim = lbstim
510kAC                   eval      exqty = 0
510kaC                   eval      extask = 'RCV'
510kAC                   eval      exgby = #user
510kAC                   eval      exesta = '1 '
510kAC                   write     exrec
510kAC                   eval      ddcode = *off
510kac                   endif
417 AC                   if        cwovr = *on  or
417eAC                             odovr = *on
417 AC                   eval      exwhse = lbwhse
417 AC                   eval      exwhdp = lbwhdp
417 AC                   eval      exstyp = lbstyp
417 AC                   eval      exitem = lbitem
417 AC                   eval      dspo = lbpo
417 AC                   eval      dslbl = lblbl#
417 AC                   eval      dsexpd = $dto
417 AC                   eval      exfdis = dsfdis
417 AC                   eval      extdis = dstdis
417 AC                   eval      exgdte = lbsdte
417 AC                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
417 AC                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
417 aC                   eval      extask = 'RCV'
417 AC                   eval      exgby = #user
417eAC                   if        odovr = *on
417eA***                  MOVEL'DAYSOVR' EXERID
417 AC                   eval      exerid = 'EXPDOVR'
417eAC                   else
417 AC                   eval      exerid = 'EXPDOVR'
417eAC                   endif
417 AC                   eval      exesta = '1 '
417 AC                   write     exrec
417jAC                   eval      odovr = *off
417 AC                   endif
417 A*
     C                   endif
     C                   if        lflag = *off
     C                   exsr      zzurcv
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   exsr      zzuhdr
650cAc                   if        rcvpocomplete = *on
650cAc                   exsr      zzrcvpoclose
650cAc                   eval      rcvpocomplete = *off
650cAc                   eval      $lsavetrn = 0
650cAc                   endif
     *
     C     endpdr        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZPMAN   Manual putaway
415 A*
415 AC     zzpman        begsr
     *
     *   Enter qty per pallet and license.
     *
     C                   eval      $lflag = lflag
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = w1whse
     C                   eval      $lpo2 = w1po
     C                   eval      $litem = woitm#
     C                   eval      $lrq1 = w3qt01
     C                   eval      $lrq2 = w3qt02
     C                   eval      $lrq3 = 0
     C                   eval      $lrpal = w3plt
     C                   eval      $lum1 = woum1
     C                   eval      $lum2 = woum2
     C                   eval      $lum3 = *blanks
     C                   eval      $lord = $rord
     C                   eval      $lseq = pdseq
     C                   eval      $lven = phven
     C                   eval      $lvnam = phvnam
     C                   eval      $lvitm = pdvitm
     C                   eval      $ldwgt = 0
417hA*
417hA*    Lot tracking item - Pass single char flag to license entry pgm
417hAC                   if        lottrk = '*YES'
417hAC                   eval      $llott = 'Y'
417hAC                   else
417hAC                   eval      $llott = 'N'
417hAC                   endif
417hA*    Lic.tracking item - Pass single char flag to license entry pgm
417hAC                   if        lictrk = '*YES'
417hAC                   eval      $llict = 'Y'
417hAC                   else
417hAC                   eval      $llict = 'N'
417hAC                   endif
510cAC                   eval      wofifo = 0
510cA* Move mfg or expire or fifo date to keyed in date field
510cA* to send to PO236
510cAC                   eval      woindt = 0
510cAC                   select
510cAC                   when      wofifo <> 0
510cAC                   eval      woindt = wofifo
510cAC                   when      w8mfdt <> 0
510cAC                   eval      woindt = womfdt
510cAC                   other
510cAC                   eval      woindt = woexdt
510cAC                   endsl
417hA*
720aA ** do we need to print box labels
720aA ** 4 and 6 print normal uom labels
720aAc                   if        $ifrcvmth = '4' and $lrq1 > 0 or
720aAc                             $ifrcvmth = '6' and $lrq1 > 0
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   eval      $bqty = $lrq1
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum1
740aMc                   eval      $buom =  $itum1
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown1 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum2 <> ' ' and
720aAc                             $itflg1 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2) + $lrq2
720aAc                   else
720aAc                   eval      $bqty = $lrq2
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum2
740aMc                   eval      $buom =  $itum2
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
720aA **
720aA ** 5 and 6 print breakdown2 uom labels
720aAc                   if        $ifrcvmth = '5' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y' or
720aAc                             $ifrcvmth = '6' and $lum3 <> ' ' and
720aAc                             $itflg2 = 'Y'
720aAc                   eval      $bpo = $lpo
720aAc                   eval      $brcvdt = today
720aAc                   if        $lrq1 <> 0 or $lrq2 <> 0
720aAc                   eval      $bqty = ($lrq1 * $itumq2 * $itumq3)
720aAc                                   + ($lrq2 * $itumq3) + $lrq3
720aAc                   else
720aAc                   eval      $bqty = $lrq3
720aAc                   endif
720aAc                   eval      $bprint = '*JOB'
720aAc                   eval      $bitem = $litem
740aDc*                  eval      $buom =  $lum3
740aMc                   eval      $buom =  $itum3
720aAc                   call      'PO250'
720aAC                   parm                    $bparm
720aAc                   endif
760bA /free
760bA     if clienthost = freshbyte;
760bA       w9lotc = %subst(pdpo:1:6) +
760ba                %subst(%EditC(pdseq:'X'):3:3);
760bA     endif;
760bA /end-free
720aA **
     C                   call      'PO236'
     C                   parm                    $lparm
     C                   parm                    $lum1
     C                   parm                    $lum2
     C                   parm                    $lum3
     C                   parm                    $lord
     C                   parm                    $lflag
     C                   parm                    $lseq
     C                   parm                    $lven
     C                   parm                    $lvnam
     C                   parm                    $lvitm
     C                   parm      expd          $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    w8twgt
500 AC                   parm                    avgwt1
500 AC                   parm                    avgwt2
500 AC                   parm                    avgwt3
417iAC                   parm                    w9lotc
510cDC*                  parm                    womfdt
510cMC                   parm                    woindt
510cDC*                  parm      0             wofifo
510cMC                   parm                    wofifo
500 AC                   parm                    woupc
640bAc                   parm                    $ldecvalue
640bAC                   parm      mexpd         $lmfgex           8 0
640bAC                   parm      mfgdte        $lmfgdt           8 0
650bAc                   parm      ' '           $plpn            50
650bAc                   parm      ' '           $pgslcns         15
650bAc                   parm      ' '           $pbrand          10
650bAc                   parm                    $parms1
650cAC                   parm                    $lsavetrn         7 0
650dAC                   parm                    $pgtin           14
650dAc                   parm                    $pbcProdD
650dAc                   parm                    $pbclot
650dAc                   parm      0             $pw1pti
650hAc                   parm      ' '           $posscode
     *
     C     $lrtn         cabeq     '*EXIT'       endpdm
     C     $lrtn         cabeq     '*CANCEL'     endpdm
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C                   if        $lrtn = '*OK     '
640bAc                   eval      $ldecvalue  = ' '
640bAc                   eval      $lmfgex = 0
640bAc                   eval      $lmfgdt = 0
640bAc                   eval      mexpd     = 0
640bAc                   eval      mfgdte   = 0
650cAc                   eval      rcvpocomplete = *on
     C                   if        w8mfdt <> 0  or
     C                             w8exdt <> 0
     C                   eval      $rord = $lord
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
500eAC     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = lbwhse
     C                   eval      pmpo = lbpo
     C                   eval      pmseq = lbseq
     C                   eval      pmitem = lbitem
     C                   eval      pmexpd = expd
     C                   eval      pmmfgd = mfgd
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
500eAC                   if        not *in78
500eAC                   update    pmrec
500eAC                   else
     C                   write     pmrec
500eAC                   endif
416cA*
416cA*      Write record to item exception file for date override.
416cA*
510kA * add additional exception if date decipher error
510kAc                   if        ddcode = *on
510kAC                   eval      exerid = 'DD-CODE'
510kAC                   eval      exwhse = lbwhse
510kAC                   eval      exwhdp = lbwhdp
510kAC                   eval      exstyp = lbstyp
510kAC                   eval      exitem = lbitem
510kAC                   eval      dspo = lbpo
510kAC                   eval      dslbl = lblbl#
510kAC                   eval      dsexpd = $dto
510kAC                   eval      exfdis = dsfdis
510kAC                   eval      extdis = dstdis
510kAC                   eval      exgdte = lbsdte
510kAC                   eval      exgtim = lbstim
510kAC                   eval      exqty = 0
510kaC                   eval      extask = 'RCV'
510kAC                   eval      exgby = #user
510kAC                   eval      exesta = '1 '
510kAC                   write     exrec
510kAC                   eval      ddcode = *off
510kac                   endif
500cDC*                  if        cwovr = *on  or
500cMC                   if        oaovr = *on  or
510eAC                             obovr = *on  or
510eAC                             ocovr = *on  or
417eAC                             odovr = *on  or
510eAC                             oeovr = *on  or
510eAC                             ofovr = *on
416cAC                   eval      exwhse = lbwhse
416cAC                   eval      exwhdp = lbwhdp
416cAC                   eval      exstyp = lbstyp
416cAC                   eval      exitem = lbitem
416cAC                   eval      dspo = lbpo
416cAC                   eval      dslbl = lblbl#
416cAC                   eval      dsexpd = $dto
416cAC                   eval      exfdis = dsfdis
416cAC                   eval      extdis = dstdis
416cAC                   eval      exgdte = lbsdte
416cAC                   eval      exgtim = lbstim
416cAC                   eval      exqty = 0
416caC                   eval      extask = 'RCV'
416cAC                   eval      exgby = #user
510eAC                   select
510eAC                   when      oaovr = *on
510eAC                   eval      exerid = 'OA-DOVR'
510eAC                   when      obovr = *on
510eAC                   eval      exerid = 'OB-DOVR'
510eAC                   when      ocovr = *on
510eAC                   eval      exerid = 'OC-DOVR'
510eAC                   when      odovr = *on
510eAC                   eval      exerid = 'OD-DOVR'
510eAC                   when      oeovr = *on
510eAC                   eval      exerid = 'OE-DOVR'
510eAC                   when      ofovr = *on
510eAC                   eval      exerid = 'OF-DOVR'
510eAC                   other
510eAC                   eval      exerid = 'EXPDOVR'
510eAC                   endsl
510eDC*                  if        odovr = *on
417eA***                  MOVEL'DAYSOVR' EXERID
417eDC**                 eval      exerid = 'EXPDOVR'
417eDC**                 else
416cDC**                 eval      exerid = 'EXPDOVR'
417eDC**                 endif
416cAC                   eval      exesta = '1 '
416cAC                   write     exrec
510eAC                   eval      oaovr = *off
510eAC                   eval      obovr = *off
510eAC                   eval      ocovr = *off
510eAC                   eval      odovr = *off
510eAC                   eval      oeovr = *off
510eAC                   eval      ofovr = *off
416cAC                   endif
416cA*
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C                   exsr      zzuhdr
650cAc                   if        rcvpocomplete = *on
650cAc                   exsr      zzrcvpoclose
650cAc                   endif
     *
     C     endpdm        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZPNON   Receive Non-FS-WMS item.
415 A*
415 AC     zzpnon        begsr
     *
     C                   call      'RC161'
     C                   parm      '*RECEIVE'    $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    woitm#
     C                   parm                    w3qt01
     C                   parm                    w3qt02
     C                   parm      0             w3qt03
     C                   parm      wopo          $rpo
     C                   parm                    $rven            11 0
     C                   parm                    $rvnam           40
     C                   parm                    w2vitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      expd          $rexpd
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm      *blanks       $rslot
     C                   parm      woline        $rseq
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm                    w8twgt            9 2
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   goto      endpnn
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C     endpnn        endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZmfrdates  Set manufactures dates
640bA*
640bAC     zzmfrdates    begsr
640bAc                   select
640bAc                   when      $lmfrdat > 0 and $ldecvalue > ' '
640bA*
640bA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640bA*

640bAC                   eval      $cvcmd = '*MDYCMD '
640bAC                   move      $lmfrdat      $cvd6i
640bAC                   call      @cvtdt
640bAC                   parm                    $cvtdt
640bAC                   move      $cvd8o        mfgdte

640bA*  Create mfg expiration date mfgdate + mfg shelf life days
640bA
640bAC                   call      'CLCDUR2'
640bAC                   parm      '*ADD'        $cdcmd
640bAC                   parm      mfgdte        $cddatein
640bAC                   parm      0             $cdtimein
640bAC                   parm      0             $cdyears
640bAC                   parm      0             $cdmonths
640bAC                   parm      immday        $cddays
640bAC                   parm      0             $cdhours
640bAC                   parm      0             $cdminutes
640bAC                   parm      0             $cdseconds
640bAC     mexpd         parm      0             $cddateout
640bAC                   parm      0             $cdtimeout

640bA*
640bA*  Calculate Mfg date if mfg exp date is entered
640bA*
640bAc                   when      $lexpdat > 0 and $ldecvalue > ' '

640bA*
640bA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640bA*

640bAC                   eval      $cvcmd = '*MDYCMD '
640bAC                   move      $lexpdat      $cvd6i
640bAC                   call      @cvtdt
640bAC                   parm                    $cvtdt
630bAC                   move      $cvd8o        mexpd
640dAC                   eval      wkmday = immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        immday = 0
YHAaAC                             and imoday > 0
YHAaAC                   eval      wkmday = imoday - 1
YHAaAC                   endif
YHAaAC                   endif

640bA*  Create mfg date - date mfg exp date - mfg shelf life days
640bA
640bAC                   call      'CLCDUR2'
640bAC                   parm      '*SUB'        $cdcmd
640bAC                   parm      mexpd         $cddatein
640bAC                   parm      0             $cdtimein
640bAC                   parm      0             $cdyears
640bAC                   parm      0             $cdmonths
640dDC*                  parm      immday        $cddays
640dMC                   parm      wkmday        $cddays
640bAC                   parm      0             $cdhours
640bAC                   parm      0             $cdminutes
640bAC                   parm      0             $cdseconds
640bAC     mfgdte        parm      0             $cddateout
640bAC                   parm      0             $cdtimeout

640dDc*                  if        immday = 0
640dMc                   if        wkmday = 0
640bAc                   eval      mfgdte = 0
640bAc                   endif

640bAc                   when      w8mfdt > 0 and itflgd = 'Y'
640bA*
640bA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640bA*

640bAC                   eval      $cvcmd = '*MDYCMD '
640bAC                   move      w8mfdt        $cvd6i
640bAC                   call      @cvtdt
640bAC                   parm                    $cvtdt
640bAC                   move      $cvd8o        mfgdte

640bA*  Create mfg expiration date mfgdate + mfg shelf life days
640bA
640bAC                   call      'CLCDUR2'
640bAC                   parm      '*ADD'        $cdcmd
640bAC                   parm      mfgdte        $cddatein
640bAC                   parm      0             $cdtimein
640bAC                   parm      0             $cdyears
640bAC                   parm      0             $cdmonths
640bAC                   parm      immday        $cddays
640bAC                   parm      0             $cdhours
640bAC                   parm      0             $cdminutes
640bAC                   parm      0             $cdseconds
640bAC     mexpd         parm      0             $cddateout
640bAC                   parm      0             $cdtimeout

640bAc                   when      w8exdt > 0

640bA*
640bA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640bA*

640bAC                   eval      $cvcmd = '*MDYCMD '
640bAC                   move      w8exdt        $cvd6i
640bAC                   call      @cvtdt
640bAC                   parm                    $cvtdt
630bAC                   move      $cvd8o        mexpd
640dAC                   eval      wkmday = immday
YHAaA*  Use By date -1 to be used as mfg shelf life days
YHAaAC                   if        client = yhata
YHAaAC                   if        immday = 0
YHAaAC                             and imoday > 0
YHAaAC                   eval      wkmday = imoday - 1
YHAaAC                   endif
YHAaAC                   endif

640bA*  Create mfg date - date mfg exp date - mfg shelf life days
640bA
640bAC                   call      'CLCDUR2'
640bAC                   parm      '*SUB'        $cdcmd
640bAC                   parm      mexpd         $cddatein
640bAC                   parm      0             $cdtimein
640bAC                   parm      0             $cdyears
640bAC                   parm      0             $cdmonths
640dDC*                  parm      immday        $cddays
640dMC                   parm      wkmday        $cddays
640bAC                   parm      0             $cdhours
640bAC                   parm      0             $cdminutes
640bAC                   parm      0             $cdseconds
640bAC     mfgdte        parm      0             $cddateout
640bAC                   parm      0             $cdtimeout

640dDc*                  if        immday = 0
640dMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
640bAc                   endif

640bAc                   endsl
640bAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVPOCHECK check for started RCVPO Transaction
650cA*
650cAC     zzrcvpocheck  begsr
650cA*
650cA*  See if RCVPO transaction is status 2 - start new if needed
650cA*
650cAC                   call      @crtrcv
650cAC                   parm      '*PO'         $lcmdr           10
650cAC                   parm      '*CHECK '     $lsubcmd         10
650cAC                   parm      pdwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
700dDC*                  parm                    $ppo              9
700dMC                   parm                    w1po
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVPO  Create receiver transaction.
650cA*
650cAC     zzrcvpo       begsr
650cA*
650cA*     clear the return field used in po236
650cA*
650cAc                   eval      $lrtn = ' '
650cAC                   call      @crtrcv
650cAC                   parm      '*PO'         $lcmdr           10
650cAC                   parm      '*CREATE'     $lsubcmd         10
650cAC                   parm      pdwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
700dDC*                  parm                    $ppo              9
700dMC                   parm                    w1po
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cA*
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZRCVPOCLOSE  Close RCVPO transaction.
650cA*
650cAC     zzrcvpoclose  begsr
650cAc                   if        rcvpocomplete

650cAc                   select
650cAc                   when      $lrq1 > 0
650cAc                   eval      poppcs = $lrq1
650cAc                   when      $lrq2 > 0
650cAc                   eval      poppcs = $lrq2
650cAc                   when      $lrq3 > 0
650cAc                   eval      poppcs = $lrq3
650cAc                   endsl
650cAC                   call      @crtrcv
650cAC                   parm      '*PO'         $lcmdr           10
650cAC                   parm      '*COMPLETE'   $lsubcmd         10
650cAC                   parm      pdwhse        @lwhse            3 0
650cAC                   parm      poppcs        $lpcs             5 0
650cAC                   parm      $lrpal        $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
700dDC*                  parm                    $ppo              9
700dMC                   parm                    w1po
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10

650cAc                   else

650cAC                   call      @crtrcv
650cAC                   parm      '*PO'         $lcmdr           10
650cAC                   parm      '*CLOSE'      $lsubcmd         10
650cAC                   parm      pdwhse        @lwhse            3 0
650cAC                   parm      0             $lpcs             5 0
650cAC                   parm      0             $lpallets         5 0
650cAC                   parm                    $lsavetrn         7 0
700dDC*                  parm                    $ppo              9
700dMC                   parm                    w1po
650cAC                   parm      itstyp        $litstyp          1
650cAC                   parm      itwhdp        $litwhdp          5
650cAC                   parm                    $lrtnr           10
650cAc                   endif
650cAC                   endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZRUPC   Verify Retail UPC on file for item.
417cA*
417cAC     zzrupc        begsr
417cA*
417cAC                   eval      $lcmd = '*VERIFY '
417cAC                   eval      $lwhs4 = pdwhse
417cAC                   eval      $lpo4 = pdpo
417cAC                   eval      $lseq4 = pdseq
417cAC                   eval      $litm4 = pditem
417cA*
417cAC                   call      'PO245'
417cAC                   parm                    $lparm
417cA*
417cAC                   select
417cAC                   when      $lrtn = '*EXIT   '  or
417cAC                             $lrtn = '*CANCEL '
417cAC                   eval      error = *on
417cA*
417cAC                   endsl
417cA*
417cAC                   endsr
417cA*
415fA*----------------------------------------------------------------
415fA*
415fA*  ZZTRCV   Calculate total qty received for PO
415fA*
415fAC     zztrcv        begsr
     *
     C                   eval      wolord = 0
     C                   eval      wolrcv = 0
     C                   eval      wopord = 0
     C                   eval      woprcv = 0
     *
     *  Loop through all detail lines for PO
     *
     C     fileky        setll     record
     C                   dow       forevr = forevr
     C     fileky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Increment Lines Ordered/Received(Marked)
     *
     C                   add       1             wolord
     C     detlky        chain     podtl3                             78
     C                   if        not *in78
     C                   add       1             wolrcv
     C                   endif
     *
     *    Increment Pieces Ordered/Received
     *
     C                   add       pdqor1        wopord
     C                   add       pdqor2        wopord
     C                   add       pdqor3        wopord
     C                   add       pdqrc1        woprcv
     C                   add       pdqrc2        woprcv
     C                   add       pdqrc3        woprcv
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
219 A*
219 A*  ZZUHDR   Update HDR record.
219 A*
219 AC     zzuhdr        begsr
219 AC                   eval      error = *off
219 AC                   eval      part = *off
415jD**                   MOVE *OFF      FULL    1
415jMC                   eval      full = *on
415jAC                   eval      recv = *off
219 AC     prtdky        setll     podtl                              79
219 AC                   move      *in79         eof
219 AC                   dow       eof = *off
219 AC     prtdky        reade     podtl                                  79
219 AC                   move      *in79         eof
219 AC                   if        not *in79
415jAC                   if        pdqrc1 < pdqor1
415jAC                   eval      part = *on
415jAC                   eval      full = *off
415jAC                   endif
415jA*
415jAC                   if        pdqrc2 < pdqor2
415jAC                   eval      part = *on
415jAC                   eval      full = *off
415jAC                   endif
415jA*
415jAC                   if        pdqrc3 < pdqor3
415jAC                   eval      part = *on
415jAC                   eval      full = *off
415jAC                   endif
415jA*
415jAC                   if        pdqrc1 > 0
415jAC                   eval      recv = *on
415jAC                   endif
415jA*
415jAC                   if        pdqrc2 > 0
415jAC                   eval      recv = *on
415jAC                   endif
415jA*
415jAC                   if        pdqrc3 > 0
415jAC                   eval      recv = *on
415jAC                   endif
415jAC                   endif
     *
415jD**         PDQRC1    IFGE PDQOR1
415jD**         PDQRC2    ANDGEPDQOR2
415jD**         PDQRC3    ANDGEPDQOR3
415jD**                   MOVE *ON       FULL
415jD**                   ITER
415jD**                   ENDIF
415jD**         PDQRC1    IFGT 0
415jD**         PDQRC1    ANDLTPDQOR1
415jD**                   MOVE *ON       PART
415jD**                   MOVE *OFF      FULL
415jD**                   LEAVE
415jD**                   ENDIF
415jD**         PDQRC2    IFGT 0
415jD**         PDQRC2    ANDLTPDQOR2
415jD**                   MOVE *ON       PART
415jD**                   MOVE *OFF      FULL
415jD**                   LEAVE
415jD**                   ENDIF
415jD**         PDQRC3    IFGT 0
415jD**         PDQRC3    ANDLTPDQOR3
415jD**                   MOVE *ON       PART
415jD**                   MOVE *OFF      FULL
415jD**                   LEAVE
415jD**                   ENDIF
415jD**                   ENDIF
219 AC                   enddo
415jA*
415jAC                   if        recv = *off
415jAC                   eval      full = *off
415jAC                   eval      part = *off
415jAC                   endif
219 A*
219 AC     fileky        chain     pohdr                              79
219 AC                   if        not *in79
219 AC                   if        part = *on
219 AC                   eval      phstat = *on
219 AC                   endif
219 AC                   if        full = *on
219 AC                   eval      phstat = '2'
219 AC                   endif
415jAC                   if        part = *off  and
415jAC                             full = *off
415jAC                   eval      phstat = *off
415jAC                   endif
219 AC                   update    phrec
770aA*
770aA*   Update the POSTATUS file for a change to POHDR
770aA*   Check for DockVue system option
770aA*
770aA /free
770aA   // Set status for DockVue
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = :phstat,
770aA                     posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo  = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
219 AC                   endif
219 A*
219 AC     endhdr        endsr
219 A*
415 A*---------------------------------------------------------------
415 A*
415 A*  ZZURCV   Update PORCV file.
415 A*
415 AC     zzurcv        begsr
    A*
    A*   Add record to PORCV.
    A*
    AC                   eval      porwhs = lbwhse
    AC                   eval      porpo = lbpo
    AC                   eval      porseq = lbseq
    AC                   eval      pordte = today
    AC                   time                    portim
    AC                   eval      porusr = #user
    AC                   eval      pordev = #job
    AC                   eval      poremp = $emp#
    AC                   eval      portrn = lbtrn#
416fD**                   Z-ADD0         PORLIC
416fAC                   eval      porlic = *blanks
    AC                   eval      porlbl = lblbl#
    AC                   eval      poract = 'R'
416fAC                   eval      poredt = 0
416fAC                   eval      poreti = 0
    AC                   write     porrec                               49
    AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
415 A*    *IN95=Protect & non-display breakdown1 unit of measure
     *
     C     zzuom         begsr
415 A*
415 A*   Determine which UOM's are needed.
415 A*
415 AC                   if        itflg1 = 'Y'  or
415 AC                             ssbflg = *on
415 AC                   eval      *in95 = *off
415 AC                   else
415 AC                   eval      *in95 = *on
415 AC                   endif
     *
     *   Get Unit of Measures.
     *
     *
415 D**         ITKEY     CHAINPIRITEM              75
415 D**         *IN75     IFEQ *ON
415 D**                   GOTO ENDUOM
415 D**                   ENDIF
     *
415nAC                   if        ittype = 'S'
415nAC     itum2         chain     unmesr                             75
415nAC                   else
     C     itum1         chain     unmesr                             75
415nAC                   endif
     C                   if        not *in75
415 D**                   MOVE UMSHRT    WOUM1
415 MC                   movel     umcode        woum1
     C                   else
     C                   eval      woum1 = *blanks
     C                   endif
     *
415 AC                   eval      woum2 = *blanks
415 AC                   if        itflg1 = 'Y'  or
415 AC                             ssbflg = *on  or
415nAC                             ittype = 'S'  and
415nAC                             itumq3 > 0
415nAC                   if        ittype = 'S'
415nAC     itum3         chain     unmesr                             75
415nAC                   else
     C     itum2         chain     unmesr                             75
415nAC                   endif
     C                   if        not *in75
415 D**                   MOVE UMSHRT    WOUM2
415 MC                   movel     umcode        woum2
     C                   else
     C                   eval      woum2 = *blanks
     C                   endif
415 AC                   endif
     *
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
415iAC                   exsr      zzlcns
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
740dDc*                  Select
740dDc*                  when      $ifrcvmth = '2'
740dDc*                  eval      firstuci = *on
740dDc*                  exsr      UCIReceive
740dDC*                  eval      w2upc = ' '
740dDc*                  other
     C                   if        noupc = *on
     C                   eval      error = *on
     C                   if        woupc = *blanks
     C                   exsr      zm032
     C                   else
     C                   exsr      zm029
     C                   endif
     C                   exsr      scr05i
     C                   else
740dAc                   Select
740dAc                   when      $ifrcvmth = '2'
740dAc                   eval      firstuci = *on
740dAc                   exsr      UCIReceive
740dAC                   eval      w2upc = ' '
740dAc                   other
     C                   exsr      scr03i
740dAc                   endsl
     C                   endif
740dDc*                  endsl
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
417iAC                   eval      w9lotc = *blanks
417iA*
417iA*    If lot tracking item, display screen to capture lot code.
417iA*
417iAC                   if        lottrk = '*YES'
417iAC                   exsr      scr09i
417iAC                   goto      endup3
417iAC                   endif
415 A*
415 A*  See if we need to get date or weight.
415 A*
415 AC                   if        s8flag = *on
415 AC                   exsr      scr08i
415 AC                   goto      endup3
415 AC                   endif
     *
416dAC                   eval      vrfycw = *off
416dAC                   exsr      zzzcw
     *
219 A*
415 AC                   eval      w3twgt = 0
415 AC                   eval      w8mfdt = 0
415 AC                   eval      mfgd = 0
415 AC                   eval      w8exdt = 0
415 AC                   eval      expd = 0
415 A*
415 A*   What is done next depends on receiving method being used.
415 A*
415 AC                   select
415 A*
415 A*     Non-FS-WMS item receiving.
415 A*
415 AC                   when      iaflag = *on
415 AC                   exsr      zzpnon
415 AC     error         cabeq     *on           endup3
415 AC                   eval      refrsh = *on
415 AC                   exsr      scr02i
415 A*
415 A*     Manual putaway
415 A*
415 AC                   when      opmput = 'Y'
415 AC                   exsr      zzpman
415 AC     error         cabeq     *on           endup3
415 AC     $lrtn         cabeq     '*EXIT'       endup3
415 AC     $lrtn         cabeq     '*CANCEL'     endup3
415 AC                   eval      refrsh = *on
415 AC                   exsr      scr02i
415 A*
415 A*     Or Directed Putaway
415 A*
415 AC                   other
415 AC                   exsr      zzpdir
415 AC     error         cabeq     *on           endup3
415 AC                   if        lflag = *off
415 AC                   exsr      scr04i
415 AC                   else
415 AC                   eval      refrsh = *on
415 AC                   exsr      scr02i
415 AC                   endif
     *
415 AC                   endsl
     *
415 D**         W3AVG     IFEQ 'Y'
415 D**         W3DWGT    MULT W3QT01    W3TWGT
415 D**                   ELSE
415 D**                   Z-ADDW3DWGT    W3TWGT
415 D**                   ENDIF
     *
415 D**                   CALL 'RC160'
415 D**                   PARM '*RECEIVE'$RCMD
415 D**                   PARM           $RPRG
415 D**                   PARM '*INTER  '$RTYPE
415 D**                   PARM           W1WHSE
415 D**                   PARM           WOITM#
415 D**                   PARM           W3QT01
415 D**                   PARM 0         W3QT02
415 D**                   PARM           W3QT02
415 D**                   PARM 0         W3QT03
415 D**                   PARM           WOPO
415 D**                   PARM           W1VEN
415 D**                   PARM           W1VNAM
415 D**                   PARM           W2VITM
415 D**                   PARM 0         $RORD
415 D**                   PARM *BLANKS   $RRCOD
415 D**                   PARM *BLANKS   $RRMEM
415 D**                   PARM           $REXPD
415 D**                   PARM           W1DEV
415 D**                   PARM           W1FORM
415 D**                   PARM           $RSLOT
415 D**                   PARM           WOLINE
415 D**                   PARM           $RRPCK
415 D**                   PARM           $RPLBL
415 D**                   PARM           W3TWGT
415 D**                   PARM           $RRQ1
415 D**                   PARM           $RRQ2
415 D**                   PARM           $RRQ3
415 D**                   PARM           $RRPAL
415 D**                   PARM           $RRTN
415 D**                   PARM           $RMSG
     *
415 D**         $RRTN     IFEQ '*PGMQ   '
415 D**                   MOVE *ON       ERROR
415 D**                   MOVE *ON       *IN24
415 D**                   MOVE *ON       *IN03
415 D**                   MOVE $RMSG     #MSGK
415 D**                   EXSR ZMQMSG
415 D**                   GOTO ENDUP3
415 D**                   ENDIF
218 D*R                   ELSE
218 D*   - This update code must be removed when RC160 is changed
218 D*   - to update PODTL file.  We are not updateing POHDR in PO200.
218 D*R                   ADD  W3QT01    PDQRC1
218 D*R                   ADD  W3QT02    PDQRC2
218 D*   - Update record (it was read and locked in ZZFIL3)
218 D*R                   UPDATRECORD                 79
218 D*R         *IN79     IFEQ *ON
218 D*R                   MOVE *ON       ERROR
218 D*R                   MOVE *ON       *IN24
218 D*R                   MOVE *ON       *IN03
218 D*R                   EXSR ZM72
218 D*R                   GOTO ENDUP3
218 D*R                   ENDIF
     *
415 D**         LFLAG     IFEQ *ON
415 D**                   EXSR SCR07I
415 D**                   ELSE
415 D**                   EXSR SCR04I
415 D**                   ENDIF
218 D*R                   ENDIF
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
219 AC                   exsr      zzuhdr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     C     endup4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
740dDc*                  Select
740dDc*                  when      $ifrcvmth = '2'
740dDc*                  eval      firstuci = *on
740dDc*                  exsr      UCIReceive
740dDC*                  eval      w2upc = ' '
740dDc*                  if        po201RTN = '*CANCEL'
740dDC*                  eval      woitm# = *blanks
740dDC*                  eval      w4line = 0
740dDC*                  eval      w4item = *blanks
740dDc*                  else
740dDc*                  exsr      scr02i
740dDc*                  endif
740dDc*                  other
     C                   if        woupc = *blanks
740dAc                   Select
740dAc                   when      $ifrcvmth = '2'
740dAc                   eval      firstuci = *on
740dAc                   exsr      UCIReceive
740dAC                   eval      w2upc = ' '
740dAc                   if        po201RTN = '*CANCEL'
740dAC                   eval      woitm# = *blanks
740dAC                   eval      w4line = 0
740dAC                   eval      w4item = *blanks
740dAc                   exsr      scr02i
740dAc                   else
740dAc                   exsr      scr02i
740dAc                   endif
740dAc                   other
     C                   exsr      scr03i
740dAc                   endsl
     C                   else
     C                   exsr      scr06i
     C                   endif
740dDc*                  endsl
     *
     C     endup5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 6.
     *
     C     zzupd6        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
221 D*R                   Z-ADD#WHSE     UPWHSE
221 MC                   eval      upwhse = w1whse
     C                   eval      upitem = woitm#
415eD**                   MOVE W6UPC     UPUPC
415eMC                   eval      upupc = kyupc
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
700cA * load new upc fields
700cA /free
700cA   upuom = itum1;
700cA   uputyp = 'N';
700cA   Select;
700cA     when ntype = 'UPC-12';
700cA       upctyp = '1';
700cA     when ntype = 'EAN-13';
700cA       upctyp = '2';
700cA     when ntype = 'GTIN';
700cA       upctyp = '3';
700cA     when ntype = 'SCC-14';
700cA       upctyp = '4';
700cA     when ntype = 'SSCC-18';
700cA       upctyp = '5';
700cA   endsl;
700cA /end-free
     *
     *   Add record
     *
     C                   write     uprec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup6
     C                   endif
740dAc                   Select
740dAc                   when      $ifrcvmth = '2'
740dAc                   eval      firstuci = *on
740dAc                   exsr      UCIReceive
740dAC                   eval      w2upc = ' '
740dAc                   if        po201RTN = '*CANCEL'
740dAC                   eval      woitm# = *blanks
740dAC                   eval      w4line = 0
740dAC                   eval      w4item = *blanks
740dAc                   else
740dAc                   exsr      scr02i
740dAc                   endif
740dAc                   other
     C                   exsr      scr03i
740dAc                   endsl
     *
     C     endup6        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD7   Update for screen 7.
     *
     C     zzupd7        begsr
     C                   eval      error = *off
     *R                   MOVE *ON       REFRSH
     *
221 D*R                   Z-ADD#WHSE     LIWHSE
221 MC                   eval      liwhse = w1whse
416fD**                   Z-ADDW7LCNS    LILCNS
416f C                   eval      lilcns = w7lcns
     C                   eval      litrn# = lbtrn#
     *
     *   Add record
     *
     C                   write     lirec                                79
     C                   if        *in79
     C                   eval      error = *on
     *R                   EXSR ZM71
     *R                   GOTO ENDUP7
     C                   endif
     C                   if        w7pctr <> w7pal
     C                   exsr      scr07i
     C                   else
219 AC                   exsr      zzuhdr
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     C     endup7        endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  ZZUPD8   Update for screen 8.
415 A*
415 AC     zzupd8        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
640bAc                   if        $ldecvalue = ' '
640bAc                   exsr      zzmfrdates
640bAc                   endif
     *
416dAC                   exsr      zzzcw
416dD**                   Z-ADD0         W8TWGT
416dD**         W8AVG     IFEQ 'Y'
416dD**         W8DWGT    MULT W3QT01    W8TWGT
416dD**                   ELSE
416dD**                   Z-ADDW8DWGT    W8TWGT
416dD**                   ENDIF
500dA*
500dAC                   if        immflg = 'Y'
500dA*
500dA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
500dA*
500dA
500dAC                   eval      $cvcmd = '*MDYCMD '
500dAC                   move      w8mfdt        $cvd6i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd8o        expd
500dAC                   move      $cvd8o        womfdt
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*ADD'        $cdcmd
500dAC                   parm      expd          $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      immday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC                   parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   call      'CLCDUR2'
500dAC                   parm      '*SUB'        $cdcmd
500dAC                   parm      $cddateout    $cddatein
500dAC                   parm      0             $cdtimein
500dAC                   parm      0             $cdyears
500dAC                   parm      0             $cdmonths
500dAC                   parm      imuday        $cddays
500dAC                   parm      0             $cdhours
500dAC                   parm      0             $cdminutes
500dAC                   parm      0             $cdseconds
500dAC     expd          parm      0             $cddateout
500dAC                   parm      0             $cdtimeout
500dA
500dAC                   eval      $cvcmd = '*CMDMDY '
500dAC                   move      expd          $cvd8i
500dAC                   call      @cvtdt
500dAC                   parm                    $cvtdt
500dAC                   move      $cvd6o        w8exdt
500dA
500dAC                   endif
     *
     *   What is done next depends on receiving method being used.
     *
     C                   select
     *
     *     Non-FS-WMS item receiving.
     *
     C                   when      iaflag = *on
     C                   exsr      zzpnon
     C     error         cabeq     *on           endup8
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Manual putaway
     *
     C                   when      opmput = 'Y'
     C                   exsr      zzpman
     C     error         cabeq     *on           endup8
     C     $lrtn         cabeq     '*EXIT'       endup8
     C     $lrtn         cabeq     '*CANCEL'     endup8
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *     Or Directed Putaway
     *
     C                   other
     C                   exsr      zzpdir
     C     error         cabeq     *on           endup8
     C                   if        lflag = *off
     C                   exsr      scr04i
     C                   else
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     C                   endsl
     *
     C     endup8        endsr
417iA*
417iA*----------------------------------------------------------------
417iA*
417iA*  ZZUPD9   Update for screen 9.
417iA*
417iAC     zzupd9        begsr
417iAC                   eval      error = *off
417iAC                   eval      refrsh = *on
417iA*
417iA*  See if we need to get date or weight.
417iA*
417iAC                   if        s8flag = *on
417iAC                   exsr      scr08i
417iAC                   goto      endup9
417iAC                   endif
417iA*
417iAC                   eval      vrfycw = *off
417iAC                   exsr      zzzcw
417iA*
417iAC                   eval      w3twgt = 0
417iAC                   eval      w8mfdt = 0
417iAC                   eval      mfgd = 0
417iAC                   eval      w8exdt = 0
417iAC                   eval      expd = 0
417iA*
417iA*   What is done next depends on receiving method being used.
417iA*
417iAC                   select
417iA*
417iA*     Non-FS-WMS item receiving.
417iA*
417iAC                   when      iaflag = *on
417iAC                   exsr      zzpnon
417iAC     error         cabeq     *on           endup9
417iAC                   eval      refrsh = *on
417iAC                   exsr      scr02i
417iA*
417iA*     Manual putaway
417iA*
417iAC                   when      opmput = 'Y'
417iAC                   exsr      zzpman
417iAC     error         cabeq     *on           endup9
417iAC     $lrtn         cabeq     '*EXIT'       endup9
417iAC     $lrtn         cabeq     '*CANCEL'     endup9
417iAC                   eval      refrsh = *on
417iAC                   exsr      scr02i
417iA*
417iA*     Or Directed Putaway
417iA*
417iAC                   other
417iAC                   exsr      zzpdir
417iAC     error         cabeq     *on           endup9
417iAC                   if        lflag = *off
417iAC                   exsr      scr04i
417iAC                   else
417iAC                   eval      refrsh = *on
417iAC                   exsr      scr02i
417iAC                   endif
417iA*
417iAC                   endsl
417iA*
417iAC     endup9        endsr
417iA*
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZUPD10  Update for screen 10.
700cA*
700cAC     zzupd10       begsr
700cAC                   eval      error = *off
700cAC                   eval      refrsh = *on
700cA*
700cAC                   eval      upwhse = w1whse
700cAC                   eval      upitem = woitm#
700cAC                   eval      upupc = kyupc
700cAC                   eval      upven = phven
700cAC                   eval      upvnam = phvnam
700cAC                   eval      upvitm = pdvitm
700cAC                   eval      upbran = *blanks
700cA * load new upc fields
700cA /free
700cA   upuom = w10buom;
700cA   uputyp = w10btyp;
700cA   Select;
700cA     when btype = 'UPC-12';
700cA       upctyp = '1';
700cA     when btype = 'EAN-13';
700cA       upctyp = '2';
700cA     when btype = 'GTIN';
700cA       upctyp = '3';
700cA     when btype = 'SCC-14';
700cA       upctyp = '4';
700cA     when btype = 'SSCC-18';
700cA       upctyp = '5';
700cA   endsl;
700cA /end-free
700cA*
700cA*   Add record
700cA*
700cAC                   write     uprec                                79
700cAC                   if        *in79
700cAC                   eval      error = *on
700cAC                   exsr      zm71
700cAC                   goto      endup10
700cAC                   endif
700cA
700cA * this needs to be based on if we are done with breakdowns
700cAC                   if        $ifrcvmth = '3' and ittype = ' '
700cAc                   exsr      scr10i
700cAc                   endif
700cAC*                  exsr      scr03i
700cAC*                  exsr      scr03i
700cA*
700cAC     endup10       endsr
700cA*
416fA*----------------------------------------------------------------
416fA*
416fA*  ZZZCW    Calculate catch weight
416fA*
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W8AVG  POCTYP  Action
     *   ------  ------  ------  -----  ------  --------------------
     *     Y       1       1       N       -    CW = Calc1
     *
     *     Y       1       1       Y       -    CW = Calc2
     *
     *     Y       1       2       -       -    CW = Calc1
     *
     *     Y       1       3       -       -    CW = Calc2
     *
     *     Y       2       1       N       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       1       Y       -    CW = Calc3
     *                                          Write POCTYP = 'A'
     *
     *     Y       2       2       -       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       3       -       -    Not allowed
     *
     *     N       1       -       -       -    Not allowed
     *
     *     N       2       -       -       T    None
     *
     *     N       2       -       -       A    CW = Calc3
     *
     *     N       3       -       -       -    None
     *
     *  Keys:
     *
     *   SVCWEN - 1=Every time, 2=First time only, 3=Never
     *   SVCWTP - 1=Choice, 2=Total, 3=Average
     *   Calc1  - Entered weight
     *   Calc2  - Qty * Entered weight
     *   Calc3  - Qty * Item weight
     *
     *----------------------------------------------------------------
416fAC     zzzcw         begsr
     *
     C                   eval      w8twgt = 0
500 AC                   eval      avgwt1 = 0
500 AC                   eval      avgwt2 = 0
500 AC                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
     C     keypoc        chain     poctype                            79
     C                   if        *in79
     C                   eval      poctyp = 'T'
     C                   endif
     C                   endif
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'Y'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '3'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w8avg = 'Y'
     C                   eval      cwcalc = 3
     C                   eval      wrttyp = 'A'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'T'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'A'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '3'
     *
     C                   endsl
     *
     *   Calculate catch weight.
     *
     C                   select
     *
     *     Straight total.
     *
     C                   when      cwcalc = 1
700bDC*                  eval      w8twgt = w8dwgt
700bMC                   eval      w8twgt = cnvwgt
700bDC*    w8dwgt        div       w3qt01        avgwt1
700bMC     cnvwgt        div       w3qt01        avgwt1
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
700bDC*    w8dwgt        mult      w3qt01        w8twgt
700bDC*                  z-add     w8dwgt        avgwt1
700bMC     cnvwgt        mult      w3qt01        w8twgt
700bMC                   z-add     cnvwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w3qt01 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w3qt01        w8twgt
500 AC                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w3qt01 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w3qt01        w8twgt
500 AC                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w3qt02 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w3qt02        tmpwgt
     C                   add       tmpwgt        w8twgt
500 AC                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w3qt02 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w3qt02        tmpwgt
     C                   add       tmpwgt        w8twgt
500 AC                   eval      avgwt2 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     *   Write POCTYPE record.
     *
     C                   if        wrttyp <> ' '
     C     keypoc        chain     poctype                            79
     C                   if        not *in79
     C                   eval      poctyp = wrttyp
     C                   update    pocrec
     C                   else
     C                   eval      pocwhs = w1whse
     C                   eval      pocpo = wopo
     C                   eval      pocseq = woline
     C                   eval      poctyp = wrttyp
     C                   write     pocrec                               78
     C                   endif
     C                   endif
     *
     C                   endsr
700cA*----------------------------------------------------------------
700cA*  clr$item  Clear $item data structure fields
700cA*----------------------------------------------------------------

700cAC     clr$item      begsr
700cAC                   eval      savever# = $itver#
700cAC                   clear                   $item
700cAC                   clear                   $item2
700cAC                   eval      $itver# = savever#
700cAC                   endsr

700cA*----------------------------------------------------------------
700cA*  zzzdricop  Call DRICOP
700cA*----------------------------------------------------------------

700cAC     zzzdricop     begsr
700cAC                   eval      error = *off

700cAC                   select
700cAC                   when      $dricommand = '*ITEM'
700cAC                   eval      $dridata = $item
700cAC                   eval      $dridata2 = $item2
700cAC                   endsl

700cAC                   if        $dricommand = '*ITEM'
700cAC                   call(e)   'DRICOP'
700cAC                   parm                    $dricommand
700cAC                   parm                    $drisubcmd
700cAC                   parm                    $drisys2upd
700cAC                   parm      #prog         $driprogram
700cAC                   parm      ' '           $drireturn
700cAC                   parm      ' '           $drimessage
700cAC                   parm                    $dridata
700cAC                   parm                    $dridata2
700cAC                   else
700cAC                   call(e)   'DRICOP'
700cAC                   parm                    $dricommand
700cAC                   parm                    $drisubcmd
700cAC                   parm                    $drisys2upd
700cAC                   parm      #prog         $driprogram
700cAC                   parm      ' '           $drireturn
700cAC                   parm      ' '           $drimessage
700cAC                   parm                    $dridata
700cAC                   endif

700cAC                   select

700cAC                   when      chk4err and %error
700cAC                   eval      error = *on

700cAC                   when      chk4err and $drireturn <> '*OK'
700cAC                   eval      error = *on

700cAC                   endsl

700cAC                   select
700cAC                   when      $dricommand = '*ITEM'
700cAC                   eval      $item = $dridata
700cAC                   eval      $item2 = $dridata2
700cAC                   endsl

700cAC                   eval      zmflag = *off
700cAC                   eval      zmsflag = *off
700cAC                   eval      chk4err = *off
700cAC     enddricop     endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Number of pallets
Average
Catch weight
license number
No CW override
Super Po Not Allowed
**
Ttl
Avg
** Descsp
Ctd. normal
Romper 1 cantidad
Numero de paletas
Promedio
CW
numero de licencia
anular no peso
Super Po Not Allowed
**
Ttl
Prm
