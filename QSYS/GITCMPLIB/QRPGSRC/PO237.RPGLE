      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO237   VS PO receiving - UCI Item
     *  16 August, 2012
     *  Lynn McMahon
     *  NOTES:
     *  Created using PO232, previous revision comments were removed.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    08/16/12  LMC  6.40
     *      - Created
640aA*    09/20/12  RH   6.40a
     *      - Enh: Change to use wk field to pass mfg shelf life days
     *        to allow use of other values to be used in calculations
640bA*    10/26/12  LMC  6.40b
     *      - Enh: If catch weight is retrieved from gs1 barcode do
     *        not perform weight edits
     *      - Enh: Disable quantity received not equal to quantity
     *        ordered warning, user is scanning one uci at a time.
     *      - Fix: Wrong indicator s/b *in75
640cA*    11/14/12  LMC  6.40c
     *      - Enh: handle upc check if gtin is not provided but a
     *      valid upc code was scanned in po120.
640dA*    11/15/12  LMC  6.40d
     *      - Fix: Lot warning override was not being seton for f20
640eA*    12/18/12  LMC  6.40e
     *      - Fix: Revised program to set W1EXDT, W1MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650bA*    02/26/13  LMC  6.50b
     *      - Fix: SSB items not setting indicator *in94 correctly
650cA*    03/08/13  LMC/RH  6.50c
     *      - Fix: Move calculated check date to RCV exception date
     *      when entered date > today + # of days out (CKEXDT)
650dA*    01/10/13  LMC  6.50d
     *      - Fix: CMDLN1 was not being loaded correctly
650eA*    03/26/13  RBD  6.50e
     *      - Problem: Sporadically, PO's were being received with no c/w
     *        written to PODTL even though c/w was in fact being entered.
     *      - Scenario: User enters c/w which falls into the acceptable
     *        range and blanks out Average Y/N (W1AVG) which turns on
     *        error, but then subr zzchkt sets off error and W1AVG goes
     *        into zzzcw as blank. Note, qty recv'd, whether they enter
     *        the full qty ordered or not, has no impact.
     *      - Fix: In the above scenario, W1AVG was allowed to be blank,
     *        then in subr zzzcw value cwcalc was not getting populated,
     *        which in turn kept w1twgt from getting populated, then
     *        w1twgt would get passed to PO236 as 0. The culprit was in
     *        subr zzchkt, it should not have been setting off error.
650fA*    05/16/13  LMC  6.50f
     *      - Enh: Added RCVPO transaction.
650gA*    06/19/13  LMC  6.50g
     *      - Enh: Added parm to pass GTIN for calculating PTI
     *      in PO236.
     *      - Enh: Add call to CALCPTI
     *      - Fix: Fix Different lot check
     *      NOTE: this enhancement needs to include Program CALCPTI
650hA*    07/15/13  LMC  6.50h
     *      - Enh: Added logic to auto populate the UPC file with GTIN
     *      Rules: The GTIN number cannot already exist assigned to
     *      another item.
650iA*    07/16/13  LMC  6.50i
     *      - Enh: Changed display file to PO23701 to auto record
     *      advance on UCI scan.
650jA*    07/22/13  LMC  6.50j
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      We need to check LICLOG before we allow the user to
     *      reuse a license number.
650kA*    07/31/13  LMC  6.50k
     *      - Enh: Added Catch weight override to exception processing
650lA*    08/06/13  LMC  6.50l
     *      - Fix: Clear saveqty when license is cancelled.
650mA*    08/07/13  LMC  6.50m
     *      - Enh: Additional logic to edit for upc from screen1.
     *      remove the check from screen2, since we are adding UPC
     *      records on the fly from gs1/uci scanning.
     *      Renamed screen format from PO23701 to PO23702.
     *      - Added catch weight edits/overrides to screen3.
650nA*    08/13/13  LMC  6.50n
     *      - Enh: Add warning window requiring the user to press F12.
     *      This was added to lock the screen, so the user doesn't
     *      keep scanning, until they resolve the error.
     *      - Enh: Display file renamed to PO23703.
650oA*    09/23/13  LMC  6.50o
     *      - Fix: Lock on chain to POCTYPE, was causing error.
650pA*    11/06/13  LMC  6.50p
     *      - Enh: use production or pack data for manufactured date.
650qA*    10/07/13  LMC  6.50q
     *      - Fix: write pocwexcp everytime
650rA*    11/11/13  LMC  6.50r
     *      - Fix: ERLRNG & ERHRNG were being wiped out when the
     *        a tie/high error was issued, I was using those fields
     *        to write the POCWEXCP file, but when the tie/high error
     *        error occurred it clears the $mdt data structure losing
     *        the value of the fields for the write to the POCWEXCP
     *        file. Moving the value of those fields when they are
     *        populated on the warning to the fields in the POCWEXCP
     *        file to eliminate the dec data error that was occurring.
650sA*    01/15/14  LMC  6.50s
     *      - Enh: Add Oss license logic.
     *      - Fix: Po header was not being updated to show receipt
     *      - Clear moretoscan and firstuci upon completion of license
650tA*    03/07/14  LMC  6.50t
     *      - Enh: Added ability to process internal 99 gs1 barcodes
     *      - Fix: Clear saved weight field on license completion.
650uA*    06/06/14  LMC  6.50u
     *      - Enh:  New OSS Receiving.
     *      - Added incoming parm for New oss receiving notice.       d,
     *        Pass new oss parm to PO236.                             d,
     *      - Load W1NOTE field to indicate OSS Receiving on display. d,
     *      - replaced display file PO23704 with PO23705.
     *      - Disable F21 if new OSS Receiving parm is populated.
650vA*    05/01/14  LMC  6.50v was previously 650t on westside
     *      - Enh: Add f20 override for new UPC being added to file
650wA*    09/26/14  LMC  6.50w
     *      - Enh: If w1dwgt > 0 need to set cwcalc to 1, in order to
     *             load total weights to the poddtl file, even if
     *             Force CW entry is N and Allow catch weight entry
     *             is never. Weights came from GS1 scanning and should
     *             be updated into the PODTL file.
700aA*    08/25/15  RBD  7.00a
     *      - Fix: In zzchk3 change wtchk to allow catchweight override
     *        for Dairyland.
700bA*    11/04/15  LMC  7.00b
     *      - Fix: If no upc warning, need to add to upc file for UCI e
     *        receiving.
700cA*    11/05/15  LMC  7.00c
     *      - Enh: Load expiration date from either the barcode       e
     *        expiration date AI=17, or the barcode Sell By Date AI-15
     *      - Enh: If uci scanned, and weight retrieved from barcode  e
     *        do not force user to override the weight.
     *
700dA*    11/11/15  LMC  7.00d
     *      - Fix: left adjust uci scanned. Caused a problem with bulke
     *        uci selection weights.
700eA*    03/22/16  LMC  7.00e
     *      - Enh: Adding logic for Metric.
700fA*    07/11/16  LMC  7.00f
     *      - Enh: Recompile only - DB change to workoss.
700iA*    09/28/16  LMC  7.00i
     *      - Enh: Adding New screen for capturing breakdown UPC.
     *        This screen will display after the verifcation screen.
     *        Since UCI scanning needs to be done before we ask a user
     *        to open a case to scan a breakdown upc.
     *        Don't want to break their uci scanning flow.
710aA*    05/02/17  LMC  7.10a
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist.
720aA*    07/27/16  LMC  7.20a
     *      - Enh: UCI Tracking.
720bA*    11/28/18  LMC  7.20b
     *      - Fix: When moretoscan is turned on , turn on *in80
     *             otherwise the license edits take place again
     *             and they should only execute on the first time.
730a *    08/21/19  LMC  7.30a
     *      - Enh: Don't divide by #oum2q unless there is a value in
     *        there. We don't typically have #oum3q and nothing in
     *        #oum2q. But with new pick to weight setup we allow this.
740a *    01/15/20  LMC  7.40a
     *      - Enh: Add the ability to auto load all uci's that have
     *        been created for canopy gs1 labels. so user only has
     *        to scan one label in the set, and we auto load the rest.
740b *    05/22/20  LMC  7.40b
     *      - Enh: Send Vendor to all calls of CVTBAR so that the
     *        new decipher barcode process works.
740cA*    07/03/20  MLB  7.40c  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
740dA*    07/06/20  LMC  7.40d
     *      - Enh: If we encounter an error in zzchklncs load up
     *        error messages and leavesr.
740eA*    05/28/20  LMC  7.40f
     *      - Enh: Allowing 99 labels only on uci receiving.
     *        This will assume the item being received is Normal UOM
770aA*   07/27/22  TDC  770a
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *
     *----------------------------------------------------------------
     * BiRite's Custom Mods
     *
BIR A*   10/03/06  RAH  BIR
     *     - Added file UPCLOG.  Add records to this file any time    a
     *       a UPC record is added to UPC3.
     *
     *  Client Custom Revisions: Cheney Brothers
CBIaA*    02/01/07  RH   CBIa
     *      - Revised to display special designation code pick slot
     *        for special desig. item with no pick slot.
CBIbA*    02/07/07  RH   CBIb
     *      - Revised to display special desig pick slot or *NONE
     *        when overflow exists and no qty in pick slot.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    03/16/11  RH   DRYa
     *      - Revised program to NOT allow CW variace override.
DRYbA*    06/08/16  LMC DRYb
     *      - Enh: Bypass hard edit on expiration date. User will
     *        get this warning instead.
     *        "Item cannot be accepted - Use by date"  will allow them
     *        to receive expired product on date sensitive items, just
     *        as it does on Mfg Dated items, with the warning "Not
     *        Enough Shelf life remaining"
DRYcA*    06/13/16  LMC DRYc
     *      - Enh: If the expirtation is <= today, and the user
     *        overrides - Chef's want the status in PO236 to be set
     *        to 'QU' for quanrantine.
DRYdA*    06/29/16  LMC DRYd
     *      - Enh: If the mfg date entered fails the Not Enough Shelf
     *        life edit - Chef's want the status in PO236 to be set
     *        to 'QU' for quanrantine.
DRYeA*    10/30/17  LMC DRYe
     *      - Enh: Chef's no longer wants the receipts that are
     *        expired to have QU status.
DRYfA*    07/22/20  LMC DRYf
     *      - Enh: When chef's is doing uci receiving, set opcwen
     *        = 1. This program is only called when you are doing
     *        uci receiving.
     *----------------------------------------------------------------
     * Client Custom Revisions: Finkle Distributing
     *
FKL A*    03/02/09  MLB  FKL
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added Finkle to RNZa mod.
FKLaA*    08/19/08  RH   FKLa
     *      - Non-display tie/hi set on 88.
FKLbA*    10/17/08  RH   FKLb
     *      - Only allow one UPC code for an item/vendor
FKLcA*    12/18/08  RH   FKLc
     *      - Fix: change non-display tie/hi from 88 to 86
     *
     *----------------------------------------------------------------
     * Jordanos Custom Mods
     *
JORaA*   11/01/10  RH   JORa
     *     - Position cursor to quantity field, custom mod missed
     *       during V6.10 update.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Renzi Foodservice
     *
RNZ A*   08/11/08  MLB  RNZ
     *     - Revised program to force ITCWGT='N' when ITCWGT='S'.
     *       Want std wgt catchwgt items treated as non-catchwgt.
RNZaA*    03/02/09  MLB  RNZa
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added file PODTLM.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Springfield
SGCaA*   12/03/09  RH   SGCa
     *     - Enh: Revised program to display error if receive pallet
     *       qty is greater than mfg tie/hi quantity.
SGCbA*   02/15/12  RH   SGCb
     *     - Fix: Add to only execute SGCA for Springfield, fix desc
     *     - Only display error if Mfg Tie/hi is not 0
     *----------------------------------------------------------------
     * Client Custom Revisions: SoFo Foods
     *
SOF A*    03/02/09  MLB  SOF
     *      - Revised program to retrieve w/h dept, section type and
     *        item desc. for all 9's items.
     *      - Added SoFo to RNZa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Glazier
     *
GFCa *    10/04/11  GJA  GFCa
     *      - Enh:  Add password window when date override is
     *        processed.
GFCb *    10/04/11  GJA  GFCb
     *      - Enh:  Change expiration date check to be
     *        Expiration date < today + distr days
     *        Expiration date > today + mfg shelf life days
     *        Mfg date < today - distr days
     *        Mfg date = today
     *        Use by date < today + distr days
     *        Use by date > today + mfg shelf life days
     *
     *----------------------------------------------------------------
     * Westside Custom Mods
WSTa *   11/06/13  LMC  WSTa
     *     - Mod 650n is now conditioned for westside only
WSTb *   03/17/14  LMC  WSTb
     *     - Load the earliest prod/pack date from the UCI scan to
     *     wofifo date field
WSTc *   07/08/14  LMC  WSTc
     *     - If date is zero ignore, and use received date.
WSTd *   09/24/14  LMC  WSTd
     *     - If an invalid date is returned do not consider that date
     *     for setting the license date.
     *----------------------------------------------------------------
     * YHata's Custom Mods
     *
YHA A*   10/10/07  RH   YHA
     *     - Added ordered qty to screen 1.
YHAbA*   12/19/07  RH   YHAb
     *     - Allow invalid UPC codes to be captured.
YHAcA*   04/24/08  RH   YHAc
     *     - Display error if mfg date = today, allow override & exception
YHAdA*   09/20/12  RH   YHAd
     *     - Calculate pack date for Date senstitive only item using  tion
     *       # of days out - 1. Store in LICINFO code *MFGDTE         tion
     *
     *----------------------------------------------------------------
     * Client Custom Revisisions: Colony Foods
     *
CFIa *   09/27/18  RTR  CFIa
     *     - Added CFI to BIR mod to log UPC codes.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  66        Date Code Decipher check to non display cmd11
     *  88        Lot code entry not allowed. Hide fields.
     *  89        FIFO entered date entry not allowed. Hide fields.
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650iDF*po237fm   cf   e             workstn
650mDF*po23701   cf   e             workstn
650nDF*po23702   cf   e             workstn
650sDF*po23703   cf   e             workstn
650uDF*po23704   cf   e             workstn
700eDF*po23705   cf   e             workstn
700iDF*po23706   cf   e             workstn
700iMFpo23707   cf   e             workstn
     F                                     infds(infds)
     Fpodtl     if   e           k disk
     F                                     rename(pdrec:record)
     Fpodtlm    if   e           k disk
     Fpoexcp    if   e           k disk
     Fpohdr     uf   e           k disk
     Fwarehs    if   e           k disk
     Funmesr    if   e           k disk
     Fdesigsp   if   e           k disk
     Foptions   if   e           k disk
     Fupc3      uf a e           k disk
     Fupc2      if   e           k disk    rename(uprec:u2rec)
     Fupc1      if   e           k disk
     F                                     rename(uprec:u1rec)
650hAFupc       if   e           k disk
650hAF                                     rename(uprec:uprecp)
     Fslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
     Fslot3     if   e           k disk
     F                                     rename(slrec:s3rec)
     FLabel2    if   e           k disk
     Fpoctype   uf a e           k disk
     Fpomfr1    uf a e           k disk
     Fitmexcp   o    e           k disk
     Fpofifo    o    e           k disk
     Fupclog    if a e           k disk
650kAFpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
650sAFworkoss   uf a e           k disk
650sAFworkoss1  uf   e           k disk
650sAF                                     rename(worec:worec1)
740aAFuciwork2  uf   e           k disk    prefix(can_)
740aAFuciwork3  uf   e           k disk    prefix(can3_) rename(uiwrec:uiwrec3)
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D a13             s              1    dim(13)
     D desc            s             20    dim(16)ctdata perrcd(1)
     D lbl             s             13    dim(4) ctdata perrcd(1)
     D typ             s             10    dim(1) ctdata perrcd(1)
     D cwt             s             27    dim(3) ctdata perrcd(1)
650uDD*cmdln           s             79    dim(9) ctdata perrcd(1)
700iDD*cmdln           s             79    dim(13)ctdata perrcd(1)
700iMD cmdln           s             79    dim(14)ctdata perrcd(1)
650aAD $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /copy qcopysrc,id#birite
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#finkle
      /copy qcopysrc,id#renzi
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#sofo
      /copy qcopysrc,id#yhata
      /copy qcopysrc,id#jordano
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#glazier
WSTaA /copy qcopysrc,id#westsid
650sA /COPY QCOPYSRC,Id#Eastlan
650sA /COPY QCOPYSRC,Id#ICB
CFIaA /COPY QCOPYSRC,Id#cfi
     *----------------------------------------------------------------
     *  P/O Detail Misc. /copy mbrs
     *
      /copy qcopysrc,podm1_rtx
      /copy qcopysrc,podm2_rtx
      /copy qcopysrc,podm3_rtx
      /copy qcopysrc,podm4_rtx
      /copy qcopysrc,podm5_rtx
     *
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
     D savever#        s                   like($lnver#)
     *----------------------------------------------------------------
     *  Working variables
     *
     D rtxall9item     C                   const('9999999999')
770aAD dockvue         s              1n   inz('0')
770aAD nostamp         s               z     inz
     D*
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
     D  dsfdis                 1     12
     D  dstdis                13     24
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @pwd            c                   const('CHKLIST')
     D @fmtit          c                   const('FRMTIT')
650fAD @crtrcv         c                   const('CRTRCVTRN')
740cMD @prtpg          c                   const('BFCPRTLBL')
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
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     D  $llott                64     64
     D  $llict                65     65
DRYcAD  $QUstat               66     67
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D* $lmfr#                19     29  0
     D* $lmfritem             30     44
     D* $ldakitem             45     59
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     *   Redefine key
     D  $mwhs3                19     20p 0
     D  $mpo3                 21     29
     D  $mseq                 30     32p 0
     D  $mitm3                33     47
     D  $mqyr1                48     50p 0
     D  $mqyr2                51     53p 0
     D  $mqyr3                54     56p 0
     D  $mcwte                57     59p 0
     D  $mcwtt                60     64p 2
     D  $mcwta                65     68p 2

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

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

     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     78
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                16     27
     *
     D  ermday                 1      2p 0
     D  ermfdt                 3      6p 0
     D  erexdt                 7     10p 0
     D  erltst                11     14p 0
     D  erdday                15     16p 0
     D  eruday                17     18p 0
     D  $ec                    1      2p 0
     *
     D  erused                 1      4p 0
     D  erdisd                 5      6p 0
     D  erusrd                 7      8p 0
     D  ersell                 9     12p 0
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erentd                 1      5p 0
     D  ertod                  6     10p 0
     *----------------------------------------------------------------
     * Data structure
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
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
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     *  *SYSTEM  -  System options.
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *****OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPWRNC  -  Check CW variance in Truck Builder (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *****OPICW   -  Individual catch weight entry (Y,N).
     *    OPICW   -  Check CW count in Truck Builder. (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPPKDY  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -
     *    OPWRNCR -  Check CW var during RCV individual Entry
     *    OPICWR  -  Check CW count during RCV individual Entry
     *    OPTRAX  -  Using TRAX module (Y/N).
770aA*    OPDCKV  -  Using DockVue
     *
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opishsa               33     35
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
770aAD  opdckv                50     50
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
      /COPY *libl/qcopysrc,C#PGMINFDS
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
     *  D-Specs created by RPG4MAX conversion.
     *
     D $code           s             10
     D $crew           s              6
     D $emp#           s              5  0
650sAD $ewhdp          s              5
     D $fnam           s             15
     D $init           s              1
     D $lnam           s             20
     D $nhrs           s             31
     D $rtn            s              8
     D $shft           s              6
     D $styp           s              1
     D $whdp           s              5
     D $whse           s              3  0
     D $ldwgt          s              9  2
     D $lflag          s              1
     D $lord           s              7  0
     D $lseq           s              5  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $msgf           s             10
650gAD $pw1pti         s              4  0
     D $unext          s             13  0
650gAD $pbcProdD       s              6  0
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3  0
     D #oum3           s              2
     D #oum3q          s              3  0
     D #sitem          s             15
650sAD #rcvarea        s              6
     D avgwt1          s              7  2
     D avgwt2          s              7  2
     D avgwt3          s              7  2
700iAD b1type          s              7
700iAD b2type          s              7
700iAD b1upc           s                   like(upupc)
700iAD b2upc           s                   like(upupc)
     D ck4err          s              1
     D ckupc           s                   like(w1upc)
     D ckexdt          s              8  0
     D ckqrc1          s                   like(pdqrc1)
     D clear           s              5  0
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D cwovr           s              1
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D ddcode          s              1
     D difflot         s               n
     D diffexpd        s               n
     D done            s              1
     D dtchk           s              1
     D dtchk2          s              1
     D dtchk3          s              1
     D dtchk4          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D exdtj           s              5  0
     D expd            s              8  0
     D expdj           s              5  0
     D expdwarn        s              1
     D expdovr         s              1
     D exwgt           s              9  2
650sAD extstgFlag      s               n
     D firstuci        s              1
     D firstlot#       s                   like($lnlot)
     D*firstMfrDt      s                   like($gsMfrDT)
     D*firstDKtExpDt   s                   like($gsDktExpDt)
     D*firstMfrExpDt   s                   like($gsMfrExpDt)
     D*firstGTIN       s                   like($gsGTIN)
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
     D hvskp           s              1
650sAD i               s              3  0
     D iaflag          s              1
     D iatest          s              1
650sAD icbLcns         s               n
650sAD icbOlcn         s             15
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
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
     D kgs2lbs         c                   2.20462262
     D KiloLbs         s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D lastseq         s                   like($lnseq)
     D lcnsExists      s               n
     D lflag           s              1
     D licinfoupd      s               n
     D lotwarn         s              1
     D lotovr          s              1
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D glzmfd          s              8  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
     D maxqty          s                   like(pdqrc1)
     D mexpd           s              8  0
     D mfgdte          s              8  0
700iAD Needb1          s               n
700iAD Needb2          s               n
700iAD Ntype           s              7
     D moretoscan      s              1
     D noupc           s              1
     D nxtscr          s              3
     D ocode           s              8
     D oaovr           s              1
     D obovr           s              1
     D ocovr           s              1
     D odovr           s              1
     D oeovr           s              1
     D ofovr           s              1
     D ossLcns         s               n
     D ovrrid          s              1
     D part            s              1
650fAD poppcs          s                   like($lpcs)
650gAd pplot           s             20
650gAd pppti           s              4  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D qtchk           s              1
     D qtchk1          s              1
650fAD rcvpocomplete   s               n
     D recv            s              1
     D rolldn          s              5  0
     D rollup          s              5  0
WSTbAD savewstfifo     s              8  0
WSTbAD wstfifo         s              8  0
650sAD rpal            s              3  0
     D savew1mfdt      s                   like(w1mfdt)
     D savew1exdt      s                   like(w1exdt)
650nAD savew1uci       s                   like(w1uci)
     D saveexpd        s                   like(expd)
     D savelotc        s                   like(w1lotc)
650nAD savenxtscr      s                   like(nxtscr)
     D savewgt         s                   like(w1dwgt)
     D saveqty         s                   like(sdqrc1)
     D sclear          s              1
     D sdesig          s              1
     D sdqrc1          s              5  0
     D sdqrc2          s              5  0
     D sdqrc3          s              5  0
     D ssbflg          s              1
     D stop            s              1
     D svckq1          s                   like(pdqrc1)
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svdwgt          s              9  2
     D svexck          s              1
     D svexdt          s              6  0
     D svhi            s              2  0
     D svmfdt          s              6  0
700eAD svopwum         s                   like(opwum)
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
     D svtie           s              4  0
     D svupc           s             50
     D t               s              1  0
     D temp10          s             10
     D templcns        s             15
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
     D upchk           s              1
     D upchk2          s              1
     D uxflag          s              1
     D vrfycw          s              1
     D uciexists       s               n
650vAD UPCwarn         s              1
650vAD UPCovr          s              1
     D unexta          s             13
     D warn            s              1
     D whse            s              3  0
640aAD wkmday          s              3  0
     D wkwhse          s                   like($pwhse)
     D woexdt          s              8  0
     D wofifo          s              8  0
     D woindt          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
     D wotcw           s              9  2
700iAD Writeb1         s               n
700iAD Writeb2         s               n
     D wrttyp          s              1
     D wtchk           s              1
     D w1item          s             15
     D w1upc           s                   like(upupc)
     D zmflag          s               n
     D zmsflag         s               n
740aAD psessid         s             40
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const
650gAD calcpti         pr                  extpgm('CALCPTI')
650gA * Input
650gAD   pGTIN                             like($bcgtin)
650gAD   pLOT                              like(pplot)
650gAD   pPackDate                         like($pmfgdt)
650gAD   pPTI                              like(pppti)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *              *QUICK   - Quick receive
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $pupc            20
     C                   parm                    $prsqt            7 0
     c                   parm                    $pqty             8 0
     c                   parm                    $p#pall           5 0
     c                   parm                    $pexpdt           6 0
     c                   parm                    $pwgt            11 3
     c                   parm                    $pmfgdt           6 0
     c                   parm                    $plot            20
     c                   parm                    $plpn            50
     c                   parm                    $puci           100
     c                   parm                    $pxd              2
650aAc                   parm                    $parms1
650fAC                   parm                    $lsavetrn         7 0
650uAc                   parm                    $posscode         1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
650fAc                   eval      rcvpocomplete = *off
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
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
700iAC     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     'CNL'         sccnl
650nAC     nxtscr        caseq     'ERR'         scerr
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650fA*
650fA*   check to see if po receipt is completed
650fA*   if completed update label/transaction with qty information
650fA*   else just mark them closed. - ended and closed dates
650fAC                   exsr      zzrcvpoclose
     C*                  return
     c
     C                   eval      *inlr = *on
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
      * if uci scan was passed in from another program don't display screen1
      * unless error occurs
     c                   select
     c
     c                   when      error = *on
     c                   if        moretoscan = *on
     C                   eval      cmdln2 = cmdln(8)
     c                   endif
     c                   write     cmdrec
     C                   exfmt     screen1                              50

     c                   when      moretoscan = *on
     c                   eval      w1lhdg = 'Scan Next UCI Label:'
     C                   eval      cmdln2 = cmdln(8)
     c                   write     cmdrec
     C                   exfmt     screen1                              50

     c                   when      $puci <> ' ' and firstuci <> *on
     c                   eval      w1uci = $puci
     c                   eval      firstuci = *on
     c                   eval      w1lhdg = 'Scan Next UCI Label:'

     c                   when      $puci = ' ' and firstuci <> *on
     c                   eval      w1uci = ' '
     c                   eval      firstuci = *on
     c                   eval      w1lhdg = 'Scan First UCI Label:'
     c                   if        moretoscan = *on
     C                   eval      cmdln2 = cmdln(8)
     c                   endif
     C                   write     cmdrec
     C                   exfmt     screen1                              50
650hAc                   other
650hAc                   write     cmdrec
650hAc                   exfmt     screen1

     c                   endsl

     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   eval      cmdln2 = cmdln(7)
     c                   if        error = '1' or
     c                             warn = '1'  or
     c                             cmdtkn = *on
     C                   write     cmdrec
     C                   exfmt     screen2                              50
     c                   endif
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   eval      cmdln2 = cmdln(9)
     C                   write     cmdrec
     C                   exfmt     screen3                              50
     C                   endif
     *
700iAC                   if        nxtscr = '04 '
700iAC                   write     cmdrec
700iAC                   exfmt     screen4                              50
700iAC                   endif
     C                   if        nxtscr = 'CNL'
     c                   exfmt     cnlwdw                               50
     C                   endif
     *
WSTaAC                   if        client = westside
650nAC                   if        nxtscr = 'ERR'
650nAc                   exfmt     errwdw                               50
650nAc                   leavesr
650nAC                   endif
WSTaAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       1415
700iAC                   setoff                                       1718
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       6162
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
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
     *    For Jordano's ...
     *  Position cursor to QTY field.

     C                   if        client = jordanos
     C                   eval      *in01 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk2
      * is this the first uci label scanned, if so need license entry
     c                   if        moretoscan = *on
     c                   eval      *in80 = *on
     c                   eval      *in15 = *off
650nA /free
WSTaA    if client = westside;
650nA      if error = *on and w1uci <> savew1uci;
650nA        savew1uci = w1uci;
650nA        savenxtscr = nxtscr;
650nA        nxtscr = 'ERR';
650nA      endif;
WSTaA    endif;
650nA /end-free
     c                   else
     c                   eval      *in80 = *off
     c                   if        $pxd = 'XD'
     c                   eval      *in15 = *off
650nA /free
WSTaA    if client = westside;
650nA      if error = *on and w1uci <> savew1uci;
650nA        savew1uci = w1uci;
650nA        savenxtscr = nxtscr;
650nA        nxtscr = 'ERR';
650nA      endif;
WSTaA    endif;
650nA /end-free
     c                   else
     c                   eval      *in15 = *on
     c                   endif
     c                   endif
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     c                   eval      w1mfdt = savew1mfdt
     c                   eval      w1exdt = savew1exdt
     c                   eval      expd   = saveexpd
     c                   eval      w1lotc = savelotc
     c                   eval      w1dwgt = savewgt
     c*                  eval      w1twgt = savewgt
650mAc                   eval      svdwgt = 0
720aAc                   select
720aAc                   when      uputyp = 'N'
     c                   eval      w1qrc1 = saveqty
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = saveqty
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = saveqty
720aAc                   endsl
     c                   eval      w1avg = 'N'
700eA /free
700eA   select;
700eA     when svopwum = 'KGS'
700eA      or svopwum = 'kgs'
700eA      or svopwum = 'Kgs';
700eA       KiloLbs = 'K';
700eA       W1KgLb  = svopwum;
700eA     other;
700eA       KiloLbs = 'P';
700eA       W1KgLb  = 'Lbs';
700eA   endsl;
700eA   exsr setupcmdln1;
700eA /end-free
WSTbAC                   if        client = westside
WSTbAc                   if        $itflgd <> 'Y'
WSTbAc                   eval      wofifo = savewstfifo
WSTbAC                   endif
WSTbAC                   endif
     C     end03i        endsr
700iA*----------------------------------------------------------------
700iA*
700iA*  Screen 04  initialization
700iA*
700iAC     scr04i        begsr
700iA*
700iA*  This screen will get initiated if receiving options to
700iA*  capture upc's for breakdown is turned on.
700iA*
700iA*  We will display the screen4  if the item has breakdowns
700iA*  defined, and we do not have a UPC record for the breakdown uom
700iA*
700iA /free
700iA   writeb1 = *off;
700iA   writeb2 = *off;
700iA   w1buom1 = ' ';
700iA   w1bupc1 = ' ';
700iA   w1buom2 = ' ';
700iA   w1bupc2 = ' ';
700iA   *in17 = *off;
700iA   *in18 = *off;
700iA   // breakdown 1 is setup on item
700iA   if $itum2 <> ' ';
700iA     Needb1  = *on;
700iA     // do we have a upc loaded for this breakdown uom
700iA     setll ($pwhse: $pitem) upc1;
700iA     dow forevr = forevr;
700iA       reade ($pwhse: $pitem) upc1;
700iA       if %eof(upc1);
700iA         leave;
700iA       endif;
700iA       if upuom = $itum2;
700iA         needb1  = *off;
700iA         leave;
700iA       endif;
700iA     enddo;
700iA   endif;
700iA   // breakdown 2 is setup on item
700iA   if $itum3 <> ' ';
700iA     Needb2  = *on;
700iA     // do we have a upc loaded for this breakdown uom
700iA     setll ($pwhse: $pitem) upc1;
700iA     dow forevr = forevr;
700iA       reade ($pwhse: $pitem) upc1;
700iA       if %eof(upc1);
700iA         leave;
700iA       endif;
700iA       if upuom = $itum3;
700iA         needb2  = *off;
700iA         leave;
700iA       endif;
700iA     enddo;
700iA   endif;
700iA   // need to capture a breakdown upc
700iA   if needb1 = *on or needb2 = *on;
700iA     nxtscr = '04 ';
700iA     exsr zzdft4;
700iA   else;
700iA     wolbl = *blanks;
700iA     woitem = *blanks;
700iA     wodsc1 = *blanks;
700iA     wodsc2 = *blanks;
700iA   endif;
700iA /end-free
700iAC     end04i        endsr
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
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc1
     c                   endif
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc1
     c                   endif
     C     *loval        setll     record
     c                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif

     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '


     C                   exsr      zzchk1
650nA /free
WSTaA    if client = westside;
650nA      if error = *on;
650nA        savenxtscr = nxtscr;
650nA        nxtscr = 'ERR';
650nA      endif;
WSTaA    endif;
650nA /end-free
     C     error         cabeq     *on           endsc1
     c                   eval      ovrrid = *off
     C                   endif
     *  If error, then do not update P.O. header file
     C     $lrtn         cabeq     '*CANCEL '    endsc1
     C     $lrtn         cabeq     '*EXIT   '    endsc1
     *
     c                   if        moretoscan = *on or
     c                             firstuci = *on
     c                   exsr      scr02i
WSTaAc                   if        client = westside
WSTaAc                   else
650nDC*                  eval      nxtscr = '02 '
WSTaDC                   eval      nxtscr = '02 '
WSTaAc                   endif
     c                   endif
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
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc2
     c                   endif
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   eval      lotwarn = *off
650vAC                   eval      UPCwarn = *off
     C                   eval      expdwarn = *off
     C                   eval      lotovr  = *off
650vAC                   eval      UPCovr  = *off
     C                   eval      expdovr  = *off
     c
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   eval      lotwarn = *off
650vAC                   eval      UPCwarn = *off
     C                   eval      expdwarn = *off
     C                   eval      lotovr  = *off
650vAC                   eval      UPCovr  = *off
     C                   eval      expdovr  = *off
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk2
650nA /free
WSTaA    if client = westside;
650nA      if error = *on and w1uci <> savew1uci;
650nA        savew1uci = w1uci;
650nA        savenxtscr = nxtscr;
650nA        nxtscr = 'ERR';
650nA      endif;
WSTaA    endif;
650nA /end-free
     C     error         cabeq     *on           endsc2
     c                   exsr      zzuci
     C                   endif
     c                   if        moretoscan = *off
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Not allowed - do nothing
     *
     C                   if        *inkc
     C                   if        moretoscan = *on
     c                   eval      nxtscr = 'CNL'
     C                   goto      endsc3
     c                   endif
     C*    *loval        setll     record
     C*                  eval      nxtscr = '01 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = '01 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     *     Setup converted weight field.
     C                   exsr      zzcnvwgt
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     $lrtn         cabeq     '*CANCEL'     endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     C                   eval      nxtscr = 'EOJ'
650sAc                   exsr      zzuhdr
     c                   eval      $pexpdt = 0
     c                   eval      $pwgt = 0
     c                   eval      $pmfgdt = 0
     c                   eval      $plot = ' '
WSTbAc                   eval      savewstfifo = 0
WSTbAc                   eval      wstfifo = 0
700iAC                   if        $ifrcvmth = '3' and $ittype = ' '
700iAc                   exsr      scr04i
700iAc                   endif
     C     endsc3        endsr
700iA*----------------------------------------------------------------
700iA*
700iA*  SC4  -  Screen 4
700iA*
700iAC     sc4           begsr
700iA*
700iA*  Test for F3 - Exit
700iA*
700iaC                   if        *inkc
700iAC     *loval        setll     record
700iAC                   eval      nxtscr = 'EOJ'
700iAC                   eval      $prtn = '*EXIT   '
700iAC                   goto      endsc4
700iAC                   endif
700iA*
700iA*  Test for F5 - Refresh
700iA*
700iAC                   if        *inke
700iAC                   if        $pcmd <> '*VIEW   '
700iAC                   exsr      scr04i
700iAC                   endif
700iAC                   goto      endsc4
700iAC                   endif
700iA*
700iA*  Test for F12 - Previous
700iA*
700iAC                   if        *inkl
700iAC     *loval        setll     record
700iAC                   eval      nxtscr = 'EOJ'
700iAC                   eval      $prtn = '*CANCEL '
700iAC                   goto      endsc4
700iAC                   endif
700iA*  Test for F9  - skip
700iA*
700iAC                   if        *inki
700iAC     *loval        setll     record
700iAC                   eval      nxtscr = 'EOJ'
700iAC                   eval      wolbl = *blanks
700iAC                   eval      woitem = *blanks
700iAC                   eval      wodsc1 = *blanks
700iAC                   eval      wodsc2 = *blanks
700iAc                   eval      $prtn = ' '
700iAC                   goto      endsc4
700iAC                   endif
700iA*
700iA*  Test for other command keys
700iA*
700iAC                   exsr      zzcmd4
700iAC     cmdtkn        cabeq     *on           endsc4
700iA*
700iA*  Some other key pressed.
700iA*
700iA*     Check input and write/update record.
700iA*
700iAC                   if        $pcmd = '*ADD    '  or
700iAC                             $pcmd = '*CHANGE '
700iA
700iAC                   exsr      zzchk4
700iAC     error         cabeq     *on           endsc4
700iAC                   exsr      zzupd4
700iAC     error         cabeq     *on           endsc4
700iAC                   endif
700iA*
700iAC                   eval      nxtscr = 'EOJ'
700iAC     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SCCNL-  Cancel Warning Window
     *
     C     scCnl         begsr
650fAc                   exsr      zzrcvpocheck
     *
     *  Test for F12 - Previous
     *
      /free
        if *inkl;
          nxtscr = '01 ';
          leavesr;
        endif;

      /end-free
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmdcnl
     C     cmdtkn        cabeq     *on           endsccnl
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzupdcnl
     c                   if        *inkj
     C                   eval      nxtscr = 'EOJ'
     c                   endif
     C     endsccnl      endsr
650nA*----------------------------------------------------------------
650nA*
650nA*  SCERR-  Error Warning Window
650nA*
650nAC     scErr         begsr
650nA*
650nA*  Test for F12 - Acknowledge Error
650nA*
650nA /free
650nA   if *inkl;
650nA     nxtscr = savenxtscr;
650nA     leavesr;
650nA   endif;
650nA
650nA /end-free
650nA*
650nA*  Some other key pressed.
650nA*
650nA*     Check input and write/update record.
650nA*
650nAC     endscerr      endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *                                                                   DOC
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr
     *----------------------------------------------------------------
     *  GETITEM      Get item info from driitem
     *----------------------------------------------------------------
      /free
        begsr getitem;
            exsr clr$item;

            $itWhse = $pwhse;
            $ititem = $pitem;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETALL';
            $drisys2upd = 'D';
            ck4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
              *in75 = *on;
            endif;
        endsr;
      /end-free

     *----------------------------------------------------------------
     C     gtoj$         begsr
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
     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

600bDC**                 eval      $lnuser = #user
600bMC                   eval      $lnuser = #curruser
600bAC                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr
650sA*----------------------------------------------------------------
650sA*  clr$slot  Clear $slot data structure fields
650sA*----------------------------------------------------------------
650sA
650sAC     clr$slot      begsr
650sAC                   eval      savever# = $slver#
650sAC                   clear                   $slot
650sAC                   clear                   $slot2
650sAC                   eval      $slver# = savever#
650sAC                   eval      $saemp#U = *on
650sAC                   eval      $saemp# = $emp#
650sAC                   endsr


     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C*                  eval      $uiwhse = $pwhse
     C*                  eval      $uiTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *
     *                                                                   DOC
     C     jtog$         begsr
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
700eA*----------------------------------------------------------------
700eA*  setupcmdln1  Setup command line 1
700eA*----------------------------------------------------------------
700eA
700eAC     setupcmdln1   begsr
700eAC                   select
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700eAC                             and $posscode <> ' '
700eAc                             and KiloLbs = 'P'
700eAC                   eval      cmdln1 = cmdln(10)
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700eAC                             and $posscode <> ' '
700eAc                             and KiloLbs = 'K'
700eAC                   eval      cmdln1 = cmdln(11)
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'N'
700eAC                             and $posscode <> ' '
700eAc                             and KiloLbs = 'P'
700eAC                   eval      cmdln1 = cmdln(12)
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'N'
700eAC                             and $posscode <> ' '
700eAc                             and KiloLbs = 'K'
700eAC                   eval      cmdln1 = cmdln(13)
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700eAc                             and KiloLbs = 'P'
700eAC                   eval      cmdln1 = cmdln(1)
     *
700eAc                   when      $itcwgt <> 'N' and $itflgd = 'Y'
700eAc                             and KiloLbs = 'K'
700eAC                   eval      cmdln1 = cmdln(2)
     *
700eAC                   when      $itcwgt <> 'N' and $itflgd = 'N'
700eAc                             and KiloLbs = 'P'
700eAC                   eval      cmdln1 = cmdln(3)
     *
700eAc                   when      $itcwgt <> 'N' and $itflgd = 'N'
700eAc                             and KiloLbs = 'K'
700eAC                   eval      cmdln1 = cmdln(4)
     *
700eAC                   when      $itcwgt = 'N' and $itflgd = 'Y'
700eAC                   eval      cmdln1 = cmdln(5)
     *
700eAC                   when      $itcwgt = 'N' and $itflgd = 'N'
700eAC                   eval      cmdln1 = cmdln(6)
     *
700eAC                   endsl
700eAc                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     c                   eval      $pupc  = ' '
     c                   eval      $prsqt = 0
     c                   eval      $pqty  = 0
     c                   eval      $p#pall  = 0
     c                   eval      $pexpdt = 0
     c                   eval      $pwgt  = 0
     c                   eval      $pmfgdt = 0
     c                   eval      $plot  = ' '
     c                   eval      $plpn  = ' '
     c                   eval      $puci  = ' '
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
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
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *   PIR0105  Generic message.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105s
     *
     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     *----------------------------------------------------------------
     *    PIR1010  Date must be <OR= today's date.
     *
     C     zm1010        begsr
     C                   eval      #msgid = 'PIR1010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZM13250  Item not date sensitive.
     *
     C     zm13250       begsr
     C                   eval      #msgid = 'PO13250'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13020  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23201  Error: UPC code exists for ventor/item.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO23201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
    AC                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9999  Generic message - length 78 chars.
     *
     C     zm9999        begsr
     C                   eval      #msgid = 'PIR9999'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO21001  Multiple qty entered, Catch wt avg must be 'N'
     *
     C     zm2101        begsr
     C                   eval      #msgid = 'PO21001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TF17201
     *
     C     zm3201        begsr
     C                   eval      #msgid = 'TF17201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23202  Qty received greater than qty ordered.
     *
     C     zm3202        begsr
     C                   eval      #msgid = 'PO23202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23701  Mixed Lots on License.
     *
     C     zm3701        begsr
     C                   eval      #msgid = 'PO23701'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO23702  Mixed Expiration Dates on License
     *
     C     zm3702        begsr
     C                   eval      #msgid = 'PO23702'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13226  cannot receive an item, if ready for export.
     *
     C     zm3226        begsr
     C                   eval      #msgid = 'PO13226'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PO13228  Item cannot be accepted.
     *
     C     zm3228        begsr
     C                   eval      #msgid = 'PO13228'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13229  Item cannot be accepted.
     *
     C     zm3229        begsr
     C                   eval      #msgid = 'PO13229'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13230  Item cannot be accepted - Exp Date
     *
     C     zm3230        begsr
     C                   eval      #msgid = 'PO13230'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13231  Warning: Exp date comes before existing date.
     *
     C     zm3231        begsr
     C                   eval      #msgid = 'PO13231'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13232  Item cannot be accepted - Calc Exp Date
     *
     C     zm3232        begsr
     C                   eval      #msgid = 'PO13232'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13233  Warning: Calc exp date comes before existing date.
     *
     C     zm3233        begsr
     C                   eval      #msgid = 'PO13233'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13234  CW must be zero when Avg = 'Y' for "First time"
     *
     C     zm3234        begsr
     C                   eval      #msgid = 'PO13234'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13243  Item cannot be accepted. # of days out
     *
     C     zm3243        begsr
     C                   eval      #msgid = 'PO13243'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO23210  Not enough shelf life remaining.
     *
     C     zm23210       begsr
     C                   eval      #msgid = 'PO23210'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO23211  This is a production date, enter date must be
     *              date previous to today.
     *
     C     zm23211       begsr
     C                   eval      #msgid = 'PO23211'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO23212  Days exceed Total shelf life.
     *
     C     zm23212       begsr
     C                   eval      #msgid = 'PO23212'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *     PO13202  Info message.
     *
     C     zm7202        begsr
     C                   eval      #msgid = 'PO13202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1slot
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM05     Slot is occupied with different item.
     *
     C     zm05          begsr
     C                   eval      #msgid = 'PO13221'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      eritm = slitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM06     Slot is a zero slot. It must be verified first.
     *
     C     zm06          begsr
     C                   eval      #msgid = 'PO13227'
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

     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
     C     zzchk2        begsr
     *   OAOVR = Manufacture date override, Caluclated exp date
     *           comes before existing overflow exp date. (PO13233)
     *   OBOVR = Manufacture date override, Manufacture date entered
     *           is greater than today.(PIR1010)
     *   OCOVR = Expiration date override, Expiration date is greater
     *           than allowed # of days out. (PO13243)
     *   ODOVR = Use by date override, Not enough user/dist days to
     *           sell before expiration date (PO13229)
     *   OEOVR = Mfg date override, Not enough user/dist days to
     *           sell before calculated expiration date (PO13228)
     *   OFOVR = Expiration date override, Expiration date entered
     *           comes before existing overflow exp date. (PO13231)
     *   DDCODE= Invalid Date returned from the Decipher progrmas
     *   CWOVR = Weight error override taken.
     *   DTCHK, QTCHK, WTCHK Flags are used to force F20 for each test
     *   DTCHK2 DTCHK3, DTCHK4,UPCHK2
     *   QTCHK1
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
650fAc                   exsr      zzrcvpocheck
     *
     *  Make sure license doesn't already exist if first scan
     *
     c                   if        *in80 = *off
     c                             and w1lcns <> ' '
     c                             and $pxd <> 'XD'
     c                   exsr      zzchklcns
     c                   endif
     *
     *  Make sure license is scanned on first scan
     *
     c                   if        *in80 = *off
     c                             and w1lcns = ' '
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg = desc(12)
     c                   exsr      zm0105
     c                   endif
     *
     *
     *  Verify normal quantity.
     *
     C                   if        w1qrc1 = 0  and
     C                             w1qrc2 = 0  and
     C                             w1qrc3 = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     C                   if        w1qrc1 < 0  or
     C                             w1qrc1 > 99999
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
     C                   if        w1qrc2 < 0  or
     C                             w1qrc2 > 99999
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
     C                   if        w1qrc3 < 0  or
     C                             w1qrc3 > 99999
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify # of Pallets.
     *
     C*                  if        w1plts <= 0  or
     C*                            w1plts > 999
     C*                  eval      error = *on
     C*                  eval      *in34 = *on
     C*                  eval      *in14 = *on
     C*                  eval      errmsg = *blanks
     C*                  movel     desc(7)       erfld
     C*                  movel     '1'           erfrom
     C*                  movel     '999'         erto
     C*                  exsr      zm0112
     C*                  endif
     *
     *  Verify FIFO (entered) date.
     *
     C                   if        not *in89  and
     C                             w1fifo <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fifo        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      #msgk = $cvmsg
     **                   EXSR ZMQMSG
     C                   goto      enderr
     C                   else
     C                   eval      w1fifo = $cvd6o
     C                   endif
     C                   endif
     *
     *  Verify expiration date.
     *
     C                   if        not *in96  and
     C                             w1exdt = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     *  Moved code here to calculate CKEXDT
     *  Verify Expiration date is within parameter (# of days out)     days)
     *  Calculate (Today + # days out)  = CHEXDT                       days)
     *

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imoday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ckexdt        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   if        w1exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   eval      w1exdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        woexdt
DRYbAc                   Select
DRYbAc                   when      client = Dairyland
DRYbAc                   other
     *  check expiration date enter to make sure it is greater than today.
     C                   if        expd <= today
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C                   goto      enderr
     C                   endif
DRYbAc                   endsl
     *  Code to calculate CKEXDT was moved from here to above.
     *
     *
     *  Verify Use by date.                                            days)
     *  Calculate (Today + Dist Days)  = DATE1                         days)
     *  Calculate  (Use By - User Days) = DATE2                        days)
     *

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date1         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   if        $immflg = 'Y'
     C                   eval      date2 = expd
     C                   else
     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif
     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date2         parm      0             $cddateout
     C                   parm      0             $cdtimeout
     C                   endif

     *
     C                   move      date2         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        date2o
     *
     C                   endif
     C                   endif
     C                   endif
     ***
     *  Verify Expire date and # of days out                           days)
     *  Allow warning and override                                     days)
     C                   if        expd <> 0
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk = *off
     C                   eval      ocovr = *off
     C                   endif
     *
     C                   if        dtchk = '2'  and
     C                             ovrrid = *on
     C                   if        client = Glazier
     C                   exsr      zzpwd
     C                   if        $prtn = '*NO'
     C                   eval      ovrrid = *off
     C                   eval      error  = *on
     C                   goto      enderr
     C                   else
     C                   eval      error = *on
     C                   eval      dtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imoday
     C                   exsr      zm3243
     C                   eval      ovrrid = *off
     C                   endif
     C                   endif
     C                   eval      ocovr = *on
     C                   eval      dtchk = *on
     C                   endif
     *
     C                   if        dtchk <> '1'
     C                   eval      dtchk = *on
     *
     *   If EXPD > /CKEXDT - Reject.
     *
     C                   if        expd > ckexdt
     C                             and client <> glazier
     C                   eval      error = *on
     C                   eval      dtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imoday
     C                   exsr      zm3243
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *
     *  Verify Use by date.                                            days)
     C                   if        expd <> 0
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk3 = *off
     C                   endif
     *
     C                   if        dtchk3 = '2'  and
     C                             ovrrid = *on
     C                   if        client = Glazier
     C                   exsr      zzpwd
     C                   if        $prtn = '*NO'
     C                   eval      ovrrid = *off
     C                   eval      error  = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imdday
     C                   eval      erusrd = $imuday
     C                   eval      ersell = date2o
     C                   exsr      zm3229
     C                   goto      enderr
     C                   endif
     C                   endif
     C                   eval      odovr = *on
     C                   eval      dtchk3 = *on
     C                   endif
     *
     C                   if        dtchk3 <> '1'
     C                   eval      dtchk3 = *on
     *
     *   If DATE2 <= Date1 - Reject.
     *
     C                   if        date2 <= date1
     C                   eval      error = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imdday
     C                   eval      erusrd = $imuday
     C                   eval      ersell = date2o
     C                   exsr      zm3229
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *
     *  Change to use DTCHK4 for override                                  )
     C                   if        svmfdt <> w1mfdt
     C                   eval      dtchk4 = *off
     C                   endif
     C                   if        dtchk4 = '2'  and
     C                             ovrrid = *on
     C                   if        client = Glazier
     C                   exsr      zzpwd
     C                   if        $prtn = '*NO'
     C                   eval      ovrrid = *off
     C                   eval      error  = *on
     C                   goto      enderr
     C                   endif
     C                   endif
     C                   if        mfgd > today
     C                   eval      obovr = *on
     C                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      obovr = *on
YHAcAC                   endif
     C                   if        today > ltstd8
     C                   eval      oeovr = *on
     C                   endif
     C                   eval      dtchk4 = *on
     C                   endif
     *
     C                   if        dtchk4 <> '1'
     C                   eval      dtchk4 = *on
     *
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      $immflg = 'Y'
     C                   if        w1mfdt = 0
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     C                   if        w1mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      #msgk = $cvmsg
     C                   goto      enderr
     C                   else
     C                   eval      w1mfdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgd
     C                   if        mfgd > today
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1010
     C                   endif
YHAcAC                   if        client = yhata  and
YHAcAC                             mfgd = today
YHAcAC                   eval      error = *on
YHAcAC                   eval      dtchk4 = '2'
YHAcAC                   eval      obovr = *off
YHAcAC                   eval      *in27 = *on
YHAcAC                   eval      *in07 = *on
YHAcAC                   eval      errmsg = *blanks
YHAcAC                   exsr      zm1010
YHAcAC                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     C     error         cabeq     *on           enderr
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd

     C                   if        client = Glazier
     *  Create expiration date mfgdate + mfg shelf life days
     *      instead of mfgdata + mfg shelf life days - User days
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     *  Find the latest acceptable date.: Exp date -Dist days
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        ltstd8

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      ltstd8        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ltstd8        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ltstd8        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        ltstd6

     *
     *   If Today's date is > Latest acceptable date - Reject.
     *
     C                   if        client = Glazier
     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     glzmfd        parm      0             $cddateout
     C                   parm      0             $cdtimeout
     C                   endif
     C                   select
     *   For Glazier mfg date < today - dist days
     C                   when      client = Glazier and
     C                             mfgd < glzmfd
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
     C                   exsr      zm23210
     C                   eval      w1exdt = 0
     C                   eval      expd = *zeros
     *   For Glazier today's date is = expiration date
     C                   when      client = Glazier and
     C                             today = mfgd
     *   For Glazier mfg date < today - dist days
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
     C                   exsr      zm23211
     C                   eval      w1exdt = 0
     C                   eval      expd = *zeros
     C                   when      today > ltstd8
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
     C                   exsr      zm23212
     C                   eval      w1exdt = 0
     C                   eval      expd = *zeros
     C                   endsl
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     C                   endif
     *
     *  Different expiration dates
      /free
          if moretoscan = *on and expdovr <> *on;
            if $immflg = 'Y';
              if savew1mfdt <> w1mfdt;
                error = *on;
                warn = *on;
                expdwarn = *on;
                exsr zm3702;
              endif;
            else;
              if $itflgd = 'Y';
                if savew1exdt <> w1exdt;
                  error = *on;
                  warn = *on;
                  expdwarn = *on;
                  exsr zm3702;
                endif;
              endif;
            endif;
          endif;
      /end-free
     C     error         cabeq     *on           enderr
     *   Check for ealier expiration dates (optional)                  days)
     *
     *     See if we can skip the check.                               days)
     *
     C                   if        w1exdt = 0  or
     C                             svexck <> '2'  and
     C                             svexck <> '3'
     C                   goto      skpxck
     C                   endif
     *
     *     Set warning check flag.                                     days)
     *
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk2 = *off
     C                   eval      oaovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   if        dtchk2 = '2'  and
     C                             ovrrid = *on
     C                   if        client = Glazier
     C                   exsr      zzpwd
     C                   if        $prtn = '*NO'
     C                   eval      error  = *on
     C                   goto      enderr
     C                   endif
     C                   endif
     C                   if        $immflg = 'Y'
     C                   eval      oaovr = *on
     C                   else
     C                   eval      ofovr = *on
     C                   endif
     C                   eval      dtchk2 = *on
     C                   goto      skpxck
     C                   endif
     *
     C     dtchk2        cabeq     '1'           skpxck
     *
     *     Do actual check                                             days)
     *
     C                   eval      dtchk2 = *on
     *
     *       Get date range of overflow slots.
     *
     C                   call      'GETEXPD'
     C                   parm      $pwhse        $swhse            3 0
     C                   parm                    #sitem
     C                   parm                    $dfrom            8 0
     C                   parm                    $dto              8 0
     *
     *       If date comes after end of range
     *         Then date can be recevied so skip the rest of the check
     *
     C                   if        expd >= $dto
     C                   goto      skpxck
     C                   endif
     *
     *       Otherwise, see if it's an error or warning.
     *
     *         '1' = Allow Let it go through
     *         '2' = Error (not allowed)
     *         '3' = Warning.
     *
     C                   eval      error = *on
     C                   if        $immflg = 'Y'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   else
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   eval      errmsg = *blanks
     C                   eval      erentd = expd
     C                   eval      ertod = $dto
     C                   select
     C                   when      svexck = '2'
     C                   eval      dtchk2 = *off
     C                   if        $immflg = 'Y'
     C                   exsr      zm3232
     C                   else
     C                   exsr      zm3230
     C                   endif
     C                   when      svexck = '3'
     C                   eval      dtchk2 = '2'
     C                   eval      warn = *on
     C*                  eval      oaovr = *on
     C*                  eval      cwovr = *on
     C                   if        $immflg = 'Y'
     C                   eval      oaovr = *on
     C                   exsr      zm3233
     C                   else
     C                   eval      ofovr = *on
     C                   exsr      zm3231
     C                   endif
     C                   endsl
     *
     C     error         cabeq     *on           enderr
     *
     C     skpxck        tag
     *
     *  Different lot - entered manually
      /free
        if w1lotc <> savelotc and moretoscan = *on and difflot = *off
           and $bcai99Sent;
          error = *on;
          warn = *on;
          lotwarn = *on;
          exsr zm3701;
        endif;
      /end-free
     C     error         cabeq     *on           enderr
     *
     *   Verify weight.
     *
     *  Always error if catchweight is negative
     *
     C                   if        w1dwgt < 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'Negative catchweight entered. '
     C                             + 'Catchweight must be greater than zero.'
     C                   exsr      zm9999
     C                   goto      enderr
     C                   endif
     *
     *  See if we need to verify catch weight.
     *
     C     vrfycw        cabeq     *off          skipcw
640bA*
640bA*  If Catch weight is retieved from gs1 scan do not edit
640bA*
650tDC*    $bcPNtLbSent  cabeq     *on           skipcw
700cMC     $bcPNtLbSent  cabeq     *on           skipcw
     *
     *  CW can't be zero if forced entry is selected.
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   if        svcwfr = 'Y'  and
     C                             w1dwgt = 0
     C                   if        svcwen = '1'  or
     C                             svcwen = '2'  and
     C                             w1avg <> 'Y'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0110
     C                   endif
     C                   endif
650tA*  CW can't be zero if uci receiving on catch weight item
650tAC                   if        w1dwgt = 0 and $itcwgt = 'Y' and
650tAc                             $ifucicde = '2'
650tAC                   eval      error = *on
650tAC                   eval      *in25 = *on
650tAC                   eval      *in05 = *on
650tAC                   eval      errmsg = *blanks
650tAC                   movel     desc(4)       errmsg
650tAC                   exsr      zm0110
650tAc                   endif
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w1avg <> 'Y'  and
     C                             w1avg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1005
     C                   endif
     *
     *  When 'First time only' entry with Avg = 'Y'
     *    Then catch weight must be zero.
     *
     C                   if        svcwen = '2'  and
     C                             w1avg = 'Y'  and
     C                             w1dwgt <> 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3234
     C                   endif
     *
     *
     *  When more than one qty is entered, catch weight average must be N
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   select
     C                   when      w1qrc1 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc2 <> 0  or
     C                             w1qrc3 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w1qrc2 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc1 <> 0  or
     C                             w1qrc3 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   when      w1qrc3 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
     C                   if        w1qrc1 <> 0  or
     C                             w1qrc2 <> 0
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm2101
     C                   endif
     *
     C                   endsl
     *
     *
     *  Skip catch weight variance check when ...
     *    "First time only" entry
     *
     C                   if        svcwen = '2'
     *      Skip variance check once qty has been received for item.
     C                             and (pdqrc1 > 0
     C                             or   pdqrc2 > 0
     C                             or   pdqrc3 > 0)
     C
     C                   goto      skipcw
     C                   endif
     *
     *
     *  Catch weight variance check.
     C                   if        svdwgt <> w1dwgt
     C                   eval      wtchk = *off
     C                   endif
     *
     C                   select
     C                   when      client = Dairyland
     C                   if        wtchk = '2'  and
     C                             ovrrid = *on
650mDC*****              eval      wtchk = '2'
650kAc                   eval      cwovr = *on
650mAC                   eval      wtchk = *on
     C                   endif
     C                   other
     C                   if        wtchk = '2'  and
     C                             ovrrid = *on
650kAc                   eval      cwovr = *on
     C                   eval      wtchk = *on
     C                   endif
     C                   endsl
     *
     C                   if        wtchk <> '1'
     C                   eval      wtchk = *on
     *   If catch weight >0,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        w1dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     *
     C                   if        w1avg = 'Y'
     C                   eval      exwgt = $itswgt
     C                   eval      wotcw = cnvwgt
     C                   else
     C                   if        svcwen = '2'
     C     pdqor1        mult      $itswgt       exwgt
     C                   else
     C     w1qrc1        mult      $itswgt       exwgt
     C                   endif
     C                   eval      wotcw = cnvwgt
     C                   endif
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C                   if        not *in75
     *
     C                   if        $imrg1c <> 0
     C     $imrg1c       div       100           prg1c
     C                   if        $imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        $imrg2c <> 0
     C     $imrg2c       div       100           prg2c
     C                   if        $imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = $itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = $itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = $itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     $itswgt       add       ihvar         ihrng
     *
     C                   endif
     *
     *     Check CW variance if CW > 0
     C                   if        w1dwgt > 0
     C                   exsr      zzchkt
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C     skipcw        tag
     *
     *
     *    Make sure slot is valid.
     *
     C                   if        w1slot <> *blanks
     C     slkey         chain(n)  s2rec                              79
     *
     *      Slot doesn't exist.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm04
     C                   goto      enderr
     C                   endif
     *
     *      Slot occupied by different item.
     *
     C                   if        slstat <> 'Z'  and
     C                             slitem <> ' '  and
     C                             slitem <> $pitem
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm05
     C                   goto      enderr
     C                   endif
     *
     *      Slot is a zero slot.
     *
     C                   if        slstat = 'Z'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm06
     C                   goto      enderr
     C                   endif
     C                   endif
     *
     C                   if        client = sgc
     C*  Error if pallet qty > tie/hi qty.
     C                   z-add     0             maxqty
     C     $imtie        mult      $imhigh       maxqty
     C                   if        w1qrc1 > 0
     C     w1qrc1        div       1             ckqrc1
     C                   endif
     C                   if        w1qrc2 > 0
     C     w1qrc2        div       1             ckqrc1
     C                   endif
     C                   if        svckq1 <> ckqrc1
     C                   eval      qtchk1 = *off
     C                   endif
     *
     C                   if        qtchk1 = '2'  and
     C                             ovrrid = *on
     C                   eval      qtchk1 = *on
     C                   endif
     *
     C                   if        qtchk1 <> '1'
     C                   eval      qtchk1 = *on
     C                   if        ckqrc1 > maxqty
     C                             and maxqty > 0
     C                   eval      qtchk1 = '2'
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(10)      erfld
     C                   movel     '1'           erfrom
     C                   move      maxqty        erto
     C                   exsr      zm0112
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     C                   endif
     *
     *  Warning:
     *
     C     w1qrc1        add       pdqrc1        svqrc1
     C     w1qrc2        add       pdqrc2        svqrc2
     C     w1qrc3        add       pdqrc3        svqrc3
     *
     *    Accumulate total exceptions to include in qty test.
     C                   exsr      zzttle
     *  Quantity.
     C                   if        sdqrc1 <> w1qrc1  or
     C                             sdqrc2 <> w1qrc2  or
     C                             sdqrc3 <> w1qrc3
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
640bDC*                  if        svqrc1 < pdqor1  or
640bDC*                            svqrc2 < pdqor2  or
640bDC*                            svqrc3 < pdqor3
640bDC*                  eval      warn = *on
640bDC*                  eval      error = *on
640bDC*                  eval      qtchk = '2'
640bDC*                  eval      *in21 = *on
640bDC*                  eval      *in22 = *on
640bDC*                  eval      *in23 = *on
640bDC*                  eval      *in01 = *on
640bDC*                  exsr      zm7201
640bDC*                  endif
650nDC*                  if        svqrc1 > pdqor1  or
650nDC*                            svqrc2 > pdqor2  or
650nDC*                            svqrc3 > pdqor3
650nDC*                  eval      warn = *on
650nDC*                  eval      error = *on
650nDC*                  eval      qtchk = '2'
650nDC*                  eval      *in21 = *on
650nDC*                  eval      *in22 = *on
650nDC*                  eval      *in23 = *on
650nDC*                  eval      *in01 = *on
650nDC*                  exsr      zm3202
650nDC*                  endif
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C     enderr        tag
     C                   eval      svdwgt = w1dwgt
     C                   eval      sdqrc1 = w1qrc1
     C                   eval      sdqrc2 = w1qrc2
     C                   eval      sdqrc3 = w1qrc3
     C                   eval      svmfdt = w1mfdt
     C                   eval      svexdt = w1exdt
     C                   eval      svupc = w1upcd
     C                   eval      svckq1 = ckqrc1
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
650fAc                   exsr      zzrcvpocheck
     C                   eval      noupc = *off

     c                   eval      w1qrc1 = 0
720aAc                   eval      w1qrc2 = 0
720aAc                   eval      w1qrc3 = 0
     c                   eval      $pexpdt = 0
     c                   eval      $pwgt   = 0
     c                   eval      $pmfgdt= 0
     c                   eval      $plot  = ' '
     c                   eval      *in92 = *off
     c                   eval      *in83 = *off
     c                   eval      *in84 = *off
     c                   eval      *in85 = *off
     c                   eval      *in72 = *off
      * check to make sure UCI barcode does not already exist
      /free
700dA   w1uci = %TrimL(w1uci);
        if w1uci <> ' ';
          exsr clr$uciinfo;

          $uiWhse = $pwhse;
          $uiuci  = w1uci;
          $uiitem = w1item;

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CHKACTV';
          $drisys2upd = 'D';
          ck4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error;
          endif;
          // if return is *EXIST seton error
          if $drireturn = '*EXIST';
            error = *on;
            errmsg = desc(11);
            exsr zm02;
          endif;
        endif;
        if w1uci = ' ';
          error = *on;
          errmsg = desc(16);
          exsr zm0105;
        endif;
      /end-free
     c                   if        w1uci <> *blanks
      * add the conversion of the UCI barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = w1uci
     c                   clear                   $barcode
     c                   clear                   $barcode2
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
740bDC*                  parm                    $cbven           10 0
740bMC                   parm      $itven#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
700eAC                   parm      $pwhse        $cbwhse
     c                   endif
     c*                  if        $cbrtn = '*NOMORE'
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
      * Load UPC
650nA * if gtin not found, error for invalid barcode scanned
     c                   if        $bcGtinSent
     c                   eval      w1upcd = $bcGtin
700iAc                   eval      ntype = 'GTIN'
     c                   move      $bcgtin       ckupc
     c                   eval      *in92 = *on
640cAc                   else
650tAc                   if        $bcai99sent
650tAc                   else
650nAc                   eval      error = *on
650nAC                   eval      errmsg = 'Invalid Barcode Scanned. '
650nAC                             + 'Scan GS1 barcode.'
650nAC                   exsr      zm9999

640cAC                   movel     w1upcd        $CSTR
640cAC                   call      'ADJUST'
640cAC                   parm      '*RIGHT  '    $CCMD             8
640cAC                   parm                    $CSTR            30
640cAc                   move      $cstr         ckupc
650tAc                   endif
     c                   endif
      * Load Expiration Date
700cAc                   Select
700cMc                   When      $bcExpDSent
700cDc*                  if        $bcExpDSent
     c                   eval      $pexpdt = $bcExpD
     c                   eval      *in83 = *on
700cDc*                  endif
700cAc                   When      $bcSlByDSent
700cAc                   eval      $pexpdt = $bcSlByD
700cAc                   eval      *in83 = *on
700cAc                   endsl
      * Load Manufacturing Date
     c                   if        $bcProdDSent
     c                   eval      $pmfgdt = $bcProdD
     c                   eval      *in84 = *on
WSTcDC*                  if        client = westside
WSTcMC                   if        client = westside and $bcProdD <> 0
WSTbAc                   move      $bcProdD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTdAc                   when      $cverm <> ' '
WSTdAc                   eval      error = *on
WSTdAC                   eval      errmsg = 'Invalid Barcode Scanned. '
WSTdAC                             + 'Scan GS1 barcode.'
WSTdAC                   exsr      zm9999
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650pAc                   else
650pAc                   if        $bcPackDSent
650pAc                   eval      $pmfgdt = $bcPackD
650pAc                   eval      *in84 = *on
WSTcDC*                  if        client = westside
WSTcMC                   if        client = westside and $bcPackD <> 0
WSTbAc                   move      $bcPackD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTdAc                   when      $cverm <> ' '
WSTdAc                   eval      error = *on
WSTdAC                   eval      errmsg = 'Invalid Barcode Scanned. '
WSTdAC                             + 'Scan GS1 barcode.'
WSTdAC                   exsr      zm9999
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650pAc                   endif
     c                   endif
      * Load Catch Weight
700eAc                   select
700eAC                   when      svopwum = 'KGS'
700eAC                             or svopwum = 'kgs'
700eAC                             or svopwum = 'Kgs'
700eAc                   if        $bcPNtkgSent
700eAc                   eval      $pwgt  = $bcPNtkg
700eAc                   eval      *in72 = *on
700eAc                   endif
700eAC                   other
     c                   if        $bcPNtLbSent
     c                   eval      $pwgt  = $bcPNtLb
     c                   eval      *in72 = *on
     c                   endif
700eAc                   endsl
      * Load Lot
     c                   if        $bcLotSent
     c                   eval      $plot   = $bcLot
     c                   eval      *in85 = *on
     c                   endif
720aDc*                  eval      w1qrc1 = 1
     c*                  endif
     *
     *  UPC not entered.
     *
     C                   if        w1upcd = *blanks
     C                   eval      noupc = *on
     C                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w1upcd <> *blanks
     *
     *  validate upc code if found in our file to make sure it is
     *  for the item selected to receive.
     c     upcky2        chain     upc2
     c                   if        %found(upc2)
720aAc                   select
720aAc                   when      uputyp = 'N'
720aAc                   eval      w1qrc1 = 1
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = 1
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = 1
720aAc                   other
720aMc                   eval      w1qrc1 = 1
720aAc                   endsl
     c
      * same item - ok
     c                   else
650hA * does the GTIN exist for a different item, if so this is an error
650hA /free
650hA    chain ($pwhse: ckupc) upc;
650hA    if %found(upc);
650hA      //diff item - issueing error
650hA      if upitem <> $pitem;
650hA        error = *on;
650hA        errmsg = desc(13);
650hA        exsr zm0105;
650hA      endif;
650hA    else;
650mA      // but first check to see if we already have a upc code for
650mA      // this item - warn user if we do before adding.
650mA      chain ($pwhse:$pitem) upc2;
650mA      if %found(upc2);
650mA        // warn user that a UPC already exist for this item - verify
650vD        //if svupc <> ckupc;
650vM        if svupc <> ckupc
650vA           or upcovr = *off;
650mA          eval svupc = ckupc;
650mA          eval error = *on;
650mA          errmsg = *blanks;
650mA          exsr zm21;
650vA          upcwarn = *on;
650mA          leavesr;
650mA        endif;
650mA      endif;
650hA      //if doesn't exist need to add if uci receiving
650vD      //if $ifrcvmth = '2';
650vM      if $ifrcvmth = '2'
700bD         //and upcovr = *on;
700bM         and upcovr = *on
700bA         or $ifrcvmth = '2'
700bA         and upcwarn = ' ';
650hA        upwhse = $pwhse;
650hA        upitem = $pitem;
650hA        upupc = ckupc;
650hA        upven = phven;
700iA        // lets add the new fields
700iA        upuom = $itum1;
700iA        uputyp = 'N';
700iA        Select;
700iA          when ntype = 'UPC-12';
700iA            upctyp = '1';
700iA          when ntype = 'EAN-13';
700iA            upctyp = '2';
700iA          when ntype = 'GTIN';
700iA            upctyp = '3';
700iA          when ntype = 'SCC-14';
700iA            upctyp = '4';
700iA          when ntype = 'SSCC-18';
700iA            upctyp = '5';
700iA        endsl;
650hA        write uprec;
650hA      endif;
650hA    endif;
650hA /end-free
      * diff item - issueing error
650hDc*                  eval      error = *on
650hDc*                  eval      errmsg = desc(13)
650hDc*                  exsr      zm0105
     c                   endif
     c                   endif
     *
     *  UPC code must match the first barcode scanned
      * check to make sure GTIN/UPC match previous entries
      /free
        if w1uci <> ' '
           and w1lcns <> ' '
           and moretoscan= *on;
650gD     //if $bclot <> savelotc and $bclot <> ' ' and lotovr = *off
650gM     if $bclot <> savelotc and lotovr = *off
             and $bcai99sent = *off;
            error = *on;
            warn = *on;
            lotwarn = *on;
            exsr zm3701;
          endif;
          // assume same lot if no lot found in GS1 and lot was entered on
          // the first recorded scanned, whether it was from gs1 or entered
          if $bclot = ' ' and savelotc <> ' ';
            $plot = Firstlot#;
          endif;
        endif;
      /end-free
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 1 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650fAc                   exsr      zzrcvpocheck
650mA*
650mA*   Verify weight.
650mA*
650mA*  Always error if catchweight is negative
650mA*
650mAC                   if        w1dwgt < 0
650mAC                   eval      error = *on
650mAC                   eval      *in25 = *on
650mAC                   eval      *in05 = *on
650mAC                   eval      errmsg = 'Negative catchweight entered. '
650mAC                             + 'Catchweight must be greater than zero.'
650mAC                   exsr      zm9999
650mAC                   goto      enderr3
650mAC                   endif
650mA*
650mA*  See if we need to verify catch weight.
650mA*
650mAC     vrfycw        cabeq     *off          skipcwf
650mA*
650mA*  CW can't be zero if forced entry is selected.
650mA*
650mA*    One exception for 'First time only' entry with Avg = 'Y'
650mA*
650mAC                   if        svcwfr = 'Y'  and
650mAC                             w1dwgt = 0
650mAC                   if        svcwen = '1'  or
650mAC                             svcwen = '2'  and
650mAC                             w1avg <> 'Y'
650mAC                   eval      error = *on
650mAC                   eval      *in25 = *on
650mAC                   eval      *in05 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   movel     desc(4)       errmsg
650mAC                   exsr      zm0110
650mAC                   endif
650mAC                   endif
650mA*
650mA*  Verify Catch weight average  (Y/N).
650mA*
650mAC                   if        w1avg <> 'Y'  and
650mAC                             w1avg <> 'N'
650mAC                   eval      error = *on
650mAC                   eval      *in32 = *on
650mAC                   eval      *in12 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   movel     desc(5)       errmsg
650mAC                   exsr      zm1005
650mAC                   endif
650mA*
650mA*  When 'First time only' entry with Avg = 'Y'
650mA*    Then catch weight must be zero.
650mA*
650mAC                   if        svcwen = '2'  and
650mAC                             w1avg = 'Y'  and
650mAC                             w1dwgt <> 0
650mAC                   eval      error = *on
650mAC                   eval      *in25 = *on
650mAC                   eval      *in05 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   exsr      zm3234
650mAC                   endif
650mA*
650mA*
650mA*  When more than one qty is entered, catch weight average must be N
650mA*
650mA*    One exception for 'First time only' entry with Avg = 'Y'
650mA*
650mAC                   select
650mAC                   when      w1qrc1 <> 0  and
650mAC                             w1avg = 'Y'  and
650mAC                             svcwen <> '2'
650mAC                   if        w1qrc2 <> 0  or
650mAC                             w1qrc3 <> 0
650mAC                   eval      error = *on
650mAC                   eval      *in32 = *on
650mAC                   eval      *in12 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   movel     desc(5)       errmsg
650mAC                   exsr      zm2101
650mAC                   endif
650mA*
650mAC                   when      w1qrc2 <> 0  and
650mAC                             w1avg = 'Y'  and
650mAC                             svcwen <> '2'
650mAC                   if        w1qrc1 <> 0  or
650mAC                             w1qrc3 <> 0
650mAC                   eval      error = *on
650mAC                   eval      *in32 = *on
650mAC                   eval      *in12 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   movel     desc(5)       errmsg
650mAC                   exsr      zm2101
650mAC                   endif
650mA*
650mAC                   when      w1qrc3 <> 0  and
650mAC                             w1avg = 'Y'  and
650mAC                             svcwen <> '2'
650mAC                   if        w1qrc1 <> 0  or
650mAC                             w1qrc2 <> 0
650mAC                   eval      error = *on
650mAC                   eval      *in32 = *on
650mAC                   eval      *in12 = *on
650mAC                   eval      errmsg = *blanks
650mAC                   movel     desc(5)       errmsg
650mAC                   exsr      zm2101
650mAC                   endif
650mA*
650mAC                   endsl
650mA*
650mA*
650mA*  Skip catch weight variance check when ...
650mA*    "First time only" entry
650mA*
650mAC                   if        svcwen = '2'
650mA*      Skip variance check once qty has been received for item.
650mAC                             and (pdqrc1 > 0
650mAC                             or   pdqrc2 > 0
650mAC                             or   pdqrc3 > 0)
650mAC
650mAC                   goto      skipcwf
650mAC                   endif
650mA*
650mA*
650mA*  Catch weight variance check.
650mAC                   if        svdwgt <> w1dwgt
650mAC                   eval      wtchk = *off
650mAC                   endif
650mA*
650mAC                   select
650mAC                   when      client = Dairyland
650mAC                   if        wtchk = '2'  and
650mAC                             ovrrid = *on
650mAc                   eval      cwovr = *on
700aDC**                 eval      wtchk = '2'
700aMC                   eval      wtchk = *on
650mAC                   endif
650mAC                   other
650mAC                   if        wtchk = '2'  and
650mAC                             ovrrid = *on
650mAc                   eval      cwovr = *on
650mAC                   eval      wtchk = *on
650mAC                   endif
650mAC                   endsl
650mA*
650mAC                   if        wtchk <> '1'
650mAC                   eval      wtchk = *on
650mA*   If catch weight >0,
650mA*     Calculate total expected catch weight,
650mA*     Calculate low/high ranges.
650mAC                   if        w1dwgt <> 0
650mAC                   eval      lwvar = 0
650mAC                   eval      hivar = 0
650mAC                   eval      lwrng = 0
650mAC                   eval      hirng = 0
650mAC                   eval      exwgt = 0
650mAC                   eval      ilvar = 0
650mAC                   eval      ihvar = 0
650mAC                   eval      ilrng = 0
650mAC                   eval      ihrng = 0
650mA*
650mAC                   if        w1avg = 'Y'
650mAC                   eval      exwgt = $itswgt
650mAC                   eval      wotcw = cnvwgt
650mAC                   else
650mAC                   if        svcwen = '2'
650mAC     pdqor1        mult      $itswgt       exwgt
650mAC                   else
650mAC     w1qrc1        mult      $itswgt       exwgt
650mAC                   endif
650mAC                   eval      wotcw = cnvwgt
650mAC                   endif
650mA*
650mA**   Iniz. flag used to skip variance check if = *ON.
650mAC                   eval      lvskp = *off
650mAC                   eval      hvskp = *off
650mA**   Use item variance % if it exists
650mAC                   if        not *in75
650mA*
650mAC                   if        $imrg1c <> 0
650mAC     $imrg1c       div       100           prg1c
650mAC                   if        $imrg1c = 99
650mAC                   eval      lvskp = *on
650mAC                   endif
650mAC                   endif
650mA*
650mAC                   if        $imrg2c <> 0
650mAC     $imrg2c       div       100           prg2c
650mAC                   if        $imrg2c = 99
650mAC                   eval      hvskp = *on
650mAC                   endif
650mAC                   endif
650mA*
650mAC                   endif
650mA*
650mAC                   if        prg1c = 0
650mAC     oprg1c        div       100           prg1c
650mAC                   endif
650mAC                   if        prg2c = 0
650mAC     oprg2c        div       100           prg2c
650mAC                   endif
650mA*
650mAC                   if        prg1c > 0
650mAC     exwgt         mult      prg1c         lwvar
650mAC                   eval      ilvar = $itswgt * prg1c
650mAC                   endif
650mAC                   eval      lwrng = exwgt - lwvar
650mAC                   eval      ilrng = $itswgt - ilvar
650mAC                   if        prg2c > 0
650mAC     exwgt         mult      prg2c         hivar
650mAC                   eval      ihvar = $itswgt * prg2c
650mAC                   endif
650mAC     exwgt         add       hivar         hirng
650mAC     $itswgt       add       ihvar         ihrng
650mA*
650mAC                   endif
650mA*
650mA*     Check CW variance if CW > 0
650mAC                   if        w1dwgt > 0
650mAC                   exsr      zzchkt
650mAC                   endif
650mAC     error         cabeq     *on           enderr3
650mAC                   endif
650mA*
650mAC     enderr3       tag
650mAC                   eval      svdwgt = w1dwgt
650mA*
650mAC     skipcwf       tag
     *
     C     endck3        endsr
700iA*----------------------------------------------------------------
700iA*
700iA*  ZZCHK4   Screen 4 error checking.
700iA*
700iAC     zzchk4        begsr
700iAC                   eval      error = *off
700iA*  at least one UPC must be entered or f9 to skip.
700iAc                   select
700iAc                   when      w1buom1 <> ' ' and
700iAC                             w1bupc1 = ' '  and
700iAc                             w1buom2 <> ' ' and
700iAC                             w1bupc2 = ' '
700iAC                   eval      error = *on
700iAC                   eval      *in17 = *on
700iAc                   eval      errmsg =  'Invalid ' + desc(6)
700iAc                   exsr      zm0105
700iAc                   leavesr
700iAc                   when      w1buom1 <> ' ' and
700iAC                             w1bupc1 = ' '  and
700iAc                             w1buom2 =  ' '
700iAC                   eval      error = *on
700iAC                   eval      *in17 = *on
700iAc                   eval      errmsg =  'Invalid ' + desc(6)
700iAc                   exsr      zm0105
700iAc                   leavesr
700iAc                   when      w1buom2 <> ' ' and
700iAC                             w1bupc2 = ' '  and
700iAc                             w1buom1 =  ' '
700iAC                   eval      error = *on
700iAC                   eval      *in18 = *on
700iAc                   eval      errmsg =  'Invalid ' + desc(6)
700iAc                   exsr      zm0105
700iAc                   leavesr
700iAc                   endsl
700iA*
700iA*  Extract UPC code from entered string.
700iA*
700iA * edit breakdown 1 upc
700iAc                   if        w1buom1 <> ' ' and
700iAC                             w1bupc1 <> *blanks
700iAC                   eval      $cbcmd = '*UPC    '
700iAC                   eval      $cbbar = w1bupc1
700iA*
700iAC                   call      'CVTBAR'
700iAC                   parm                    $cbcmd            8
700iAC                   parm                    $cbbar          100
700iAC                   parm                    $cbcod            3 0
700iAC                   parm                    $cbdec            1 0
700iAC                   parm                    $cbdsc           30
700iAC                   parm                    $cbpos            3 0
700iAC                   parm                    $cbtyp            1 0
700iAC                   parm                    $cbv1            11 3
700iAC                   parm                    $cbv2            50
700iAC                   parm                    $cbrtn            8
700iAC                   parm                    $cberm           60
740bAC                   parm      $itven#       $cbven           10 0
740bAC                   parm                    $cvtdata
740bAC                   parm                    $cvtdata2
700iA*
700iAC                   movel     $cbv2         $cstr
700iAC                   call      'ADJUST'
700iAC                   parm      '*RIGHT  '    $ccmd             8
700iAC                   parm                    $cstr            30
700iAC                   move      $cstr         b1upc
700iAC                   endif
700iA*   Do UPC Check
700iAC                   if        w1bupc1 <> ' '
700iA*
700iA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700iAC                   select
700iA*
700iAC                   when      $cbrtn = '*OK'
700iAc                   eval      writeb1 = *on
700iAc                   eval      b1type = %trimr($cbdsc)
700iA*
700iAC                   other
700iAC                   eval      error = *on
700iAC                   eval      *in17 = *on
700iAC                   movel     $cberm        errmsg
700iAC                   exsr      zm0105
700iAC                   endsl
700iA*
700iAC     error         cabeq     *on           endck4
700iAC                   endif
700iA*
700iA * edit breakdown 2 upc
700iAc                   if        w1buom2 <> ' ' and
700iAC                             w1bupc2 <> *blanks
700iAC                   eval      $cbcmd = '*UPC    '
700iAC                   eval      $cbbar = w1bupc2
700iA*
700iAC                   call      'CVTBAR'
700iAC                   parm                    $cbcmd            8
700iAC                   parm                    $cbbar          100
700iAC                   parm                    $cbcod            3 0
700iAC                   parm                    $cbdec            1 0
700iAC                   parm                    $cbdsc           30
700iAC                   parm                    $cbpos            3 0
700iAC                   parm                    $cbtyp            1 0
700iAC                   parm                    $cbv1            11 3
700iAC                   parm                    $cbv2            50
700iAC                   parm                    $cbrtn            8
700iAC                   parm                    $cberm           60
740bAC                   parm      $itven#       $cbven           10 0
740bAC                   parm                    $cvtdata
740bAC                   parm                    $cvtdata2
700iA*
700iAC                   movel     $cbv2         $cstr
700iAC                   call      'ADJUST'
700iAC                   parm      '*RIGHT  '    $ccmd             8
700iAC                   parm                    $cstr            30
700iAC                   move      $cstr         b2upc
700iAC                   endif
700iA*   Do UPC Check
700iAC                   if        w1bupc2 <> ' '
700iA*
700iA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700iAC                   select
700iA*
700iAC                   when      $cbrtn = '*OK'
700iAc                   eval      writeb2 = *on
700iAc                   eval      b2type = %trimr($cbdsc)
700iA*
700iAC                   other
700iAC                   eval      error = *on
700iAC                   eval      *in18 = *on
700iAC                   movel     $cberm        errmsg
700iAC                   exsr      zm0105
700iAC                   endsl
700iA*
700iAC     error         cabeq     *on           endck4
700iAC                   endif
700iA*
700iAC     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
650eDC**                 eval      error = *off
     *
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
     *
     *
     *
     *     Compare total catchweight to expected catchweight
     *
     *
     C                   if        lvskp = *off
     C                             and wotcw < lwrng
     C                             and opwrncr = 'Y'
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
650rAC                   eval      CW_exrngl = erlrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
650rAC                   eval      CW_exrngh = erhrng
     C                   else
     C                   eval      erhrng = hirng
650rAC                   eval      CW_exrngh = erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off
     C                             and wotcw > hirng
     C                             and opwrncr = 'Y'
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
650rAC                   eval      CW_exrngl = erlrng
     C                   else
     C                   eval      erlrng = lwrng
650rAC                   eval      CW_exrngl = erlrng
     C                   endif
     C                   eval      erhrng = hirng
650rAC                   eval      CW_exrngh = erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   exsr      zm19
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKLCNS  Check for active license
     *
     C     zzchklcns     begsr
     C                   eval      lcnsExists = *off
     C*                  eval      ossLcns = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     c                   if        $pxd = ' '
     C                   eval      $liToLcns = w1lcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
650sAC                   if        $drireturn = '*OK'
650sAC                             and $liToAisl =  'OSS'
650sAC                             or $drireturn = 'INVLDLCNS'
650sDC*                  if        error
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
650jA*
650jA*  Check LICLOG before accepting this license
650jA*
650jAC                   exsr      clr$license
650jAC                   eval      $liToLcnsU = *on
650jAc                   if        $pxd = ' '
650jAC                   eval      $liToLcns = w1lcns
650jAc                   else
650jAC                   eval      $liToLcns = templcns
650jAc                   endif
650jAC                   eval      $liOLcnsU = *on
650jAc                   if        $pxd = ' '
650jAC                   eval      $liOLcns = w1lcns
650jAc                   else
650jAC                   eval      $liToLcns = templcns
650jAc                   endif
650jAC                   eval      $dricommand = '*LICENSE'
650jAC                   eval      $drisubcmd  = '%GETINFO'
650jAC                   eval      $drisys2upd = 'D'
650jAC                   eval      ck4err = *off
650jAC                   exsr      zzzdricop
650jAc* if we get an ok on the return this means it exist - don't use
650jAC                   if        $drireturn = '*OK'
650sAC                             and $liToAisl <> 'OSS'
650jAC                   eval      lcnsExists = *on
650jAC                   eval      error = *on
650jAC                   eval      *in15 = *on
650jAc                   eval      errmsg= desc(15)
650jAc                   exsr      zm02
740dAc                   leavesr
650jAC                   endif
650jA
710aA*
710aA*  Check LICINFO before accepting this license
710aA*
710aAC                   exsr      clr$licinfo
710aAC                   eval      $lnwhse   = $pwhse
710aAc                   if        $pxd = ' '
710aAC                   eval      $lnlcns   = w1lcns
710aAc                   else
710aAC                   eval      $lnlcns   = templcns
710aAc                   endif
710aAC                   eval      $dricommand = '*LICINFO'
710aAC                   eval      $drisubcmd  = '%GET'
710aAC                   eval      $drisys2upd = 'D'
710aAC                   eval      ck4err = *off
710aAC                   exsr      zzzdricop
710aAc* if we get an ok on the return this means it exist - don't use
710aAC                   if        $drireturn = '*OK'
710aAC                             and $liToAisl <> 'OSS'
710aAC                   eval      lcnsExists = *on
710aAC                   eval      error = *on
710aAC                   eval      *in15 = *on
710aAc                   eval      errmsg= desc(15)
710aAc                   exsr      zm02
710aAC                   endif
710aA
     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      errmsg= desc(15)
     c                   exsr      zm02
     C                   endif


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 1.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Slot.
     *
     C                   when      row# = 18
     C                   eval      *in13 = *on
     C                   eval      $lcmd = '*BOTH   '
     C                   eval      $lwhs2 = $pwhse
     C                   eval      $lwhd2 = $itwhdp
     C                   eval      $litm2 = $pitem
     C                   eval      $ldisp = *blanks
     C                   eval      $ldesg = $itdesg
     C                   eval      $lst = 'V '
     C                   eval      $lsdef = *blanks
     C                   eval      $lactv = *blanks
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1slot = $ldisp
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Test for F7 - Kilograms/Pounds toggle
     *
     C                   if        *inkg and $itcwgt = 'N'
     C                   eval      cmdtkn = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(9)       errmsg
     C                   exsr      zm0105
     C                   goto      endcm2
     C                   endif
     C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   if        KiloLbs = 'P'
     C                   eval      KiloLbs = 'K'
     C                   eval      W1KgLb  = 'Kgs'
     C                   else
     C                   eval      KiloLbs = 'P'
     C                   eval      W1KgLb  = 'Lbs'
     C                   endif
     C                   select

650uAC                   when      KiloLbs = 'K' and $itflgd = 'Y'
650uAC                             and $posscode <> ' '
650uAC                   eval      cmdln1 = cmdln(11)

650uAC                   when      KiloLbs = 'P' and $itflgd = 'Y'
650uAC                             and $posscode <> ' '
650uAC                   eval      cmdln1 = cmdln(10)

650uAC                   when      KiloLbs = 'K' and $itflgd = 'N'
650uAC                             and $posscode <> ' '
650uAC                   eval      cmdln1 = cmdln(13)

650uAC                   when      KiloLbs = 'P' and $itflgd = 'N'
650uAC                             and $posscode <> ' '
650uAC                   eval      cmdln1 = cmdln(12)

650dDC*                  when      KiloLbs = 'K' and $immflg = 'Y'
650dMC                   when      KiloLbs = 'K' and $itflgd = 'Y'
     C                   eval      cmdln1 = cmdln(2)

650dDC*                  when      KiloLbs = 'P' and $immflg = 'Y'
650dMC                   when      KiloLbs = 'P' and $itflgd = 'Y'
     C                   eval      cmdln1 = cmdln(1)

650dDC*                  when      KiloLbs = 'K' and $immflg = 'N'
650dMC                   when      KiloLbs = 'K' and $itflgd = 'N'
     C                   eval      cmdln1 = cmdln(4)

650dDC*                  when      KiloLbs = 'P' and $immflg = 'N'
650dMC                   when      KiloLbs = 'P' and $itflgd = 'N'
     C                   eval      cmdln1 = cmdln(3)

     C                   endsl
     C                   endif
     *
     *      F8  - Item Tie/High Maintenance.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    $pitem
     C                   endif
     *
     *
     *      F9  - Scan Item Catchweight labels.
     *
     C                   if        *inki  and
     C                             ($itcwgt = 'Y'
     C                              or $itcwgt = 'S')
     C                   eval      cmdtkn = *on
     C                   eval      $mcmd = '*CHANGE '
     C                   eval      $mwhs3 = $pwhse
     C                   eval      $mpo3 = $ppo
     C                   eval      $mseq = $pseq
     C                   eval      $mitm3 = $pitem
     C                   eval      $mqyr1 = w1qrc1
     C                   eval      $mqyr2 = w1qrc2
     C                   eval      $mqyr3 = w1qrc3
     C                   eval      $mcwte = *zeros
     C                   eval      $mcwtt = *zeros
     C                   eval      $mcwta = *zeros
     C                   call      'CW122'
     C                   parm                    $mparm
     *
     *    Load weight from entry program / Change flag to show not avg.
     C                   eval      w1dwgt = $mcwtt
     C                   eval      w1avg = 'N'
700eA*    If weight is returned, set to default item options UOM mode
700eM*    If weight is returned, force 'pounds' mode.-700e changed and
700eA*    We no longer force the mode to pounds mode.
     C                   if        $mcwtt > 0
700eDC*                  eval      KiloLbs = 'P'
700eDC*                  eval      W1KgLb  = 'Lbs'
700eDC*                  select
650dDC*                  when      $immflg = 'Y'
700eDC*                  when      $itflgd = 'Y'
700eDC*                            and $posscode <> ' '
700eDC*                  eval      cmdln1 = cmdln(10)
700eDC*                  when      $itflgd = 'Y'
700eDC*                  eval      cmdln1 = cmdln(1)
700eDC*                  other
700eDC*                  eval      cmdln1 = cmdln(3)
700eDC*                  endsl
      /free
700eA   select;
700eA     when svopwum = 'KGS'
700eA      or svopwum = 'kgs'
700eA      or svopwum = 'Kgs';
700eA       KiloLbs = 'K';
700eA       W1KgLb  = svopwum;
700eA     other;
700eA       KiloLbs = 'P';
700eA       W1KgLb  = 'Lbs';
700eA   endsl;
700eA   exsr setupcmdln1;
      /end-free
     C                   endif
     C                   endif
     *
     *      F11 - Manufacturer code decipher
     *
      * don't execute if dates were brought in from gs1 scan
     c                   if        *inkk and
     c                             not $bcExpDSent and not $bcProdDSent
     C                   eval      $lexpdat = 0
     C                   eval      $lmfrdat = 0
     c                   eval      $lrtn = ' '
      * f11 is only valid on date sensitive items
     c                   If        $itflgd = 'Y' or $immflg = 'Y'
     c
     c                   eval      $lmfr#    = phven
     c                   eval      $lmfritem = pdvitm
     c                   eval      $ldakitem = pditem
     c                   eval      $lupc     = w1upcd
     c                   eval      ddcode = *off
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     c                   else
     c                   exsr      zm13250
     c                   endif
      * Set ddcode if date returned is invalid
     c                   if        $lrtn <> *blanks and $lrtn <> 'OK'
     c                   select
     c                   when      $lexpdat = 0 and $lmfrdat = 0
     c                   eval      ddcode = *on
640eAc                   eval      w1exdt = 0
640eAc                   eval      w1mfdt = 0

     c                   when      $lexpdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lexpdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif

     c                   when      $lmfrdat <> 0
     c                   eval      $cvcmd = '*MDYEDT'
     c                   move      $lmfrdat      $cvd6i
     c                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      ddcode= *on
     c                   endif
     c                   other
     c
     c                   endsl
     c                   endif
     c                   exsr      zzmfrdates
     C                   eval      w1exdt = $lexpdat
     c                   if        $immflg = 'Y'
     C                   eval      w1mfdt = $lmfrdat
     c                   endif
     c                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                             or *inkj
     C                   eval      ovrrid = *on
     c                   if        expdwarn = *on
     c                   eval      diffexpd = *on
     c                   eval      expdovr = *on
     c                   endif
     c                   if        lotwarn = *on
     c                   eval      difflot = *on
     c                   eval      lotovr = *on
     c                   endif
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
650sA*
650sA*      F21 - External Storage License Print
650sA*
650sAC                   if        *inkv
650uAC                             and $posscode = ' '
650sAc                   eval      rpal = 1
650sAc                   eval      w3pal = 1
650sAC                   eval      cmdtkn = *on
650sAC                   exsr      zzextstg
650sAC                   goto      endcm2
650sAC                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 2.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                             or *inkj
     C                   eval      ovrrid = *on
     c                   if        lotwarn = *on
     C                   eval      difflot = *on
640dDC*                  eval      lotwarn = *off
640dAC                   eval      lotovr = *on
     c                   endif
650vAc                   if        UPCwarn = *on
650vAC                   eval      UPCovr = *on
650vAc                   endif
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     *
     *      F22 - Complete License.
      *
     C                   if        *inkw
650fAc                   exsr      zzrcvpocheck
     c                   if        saveqty > 0
     C                   eval      cmdtkn = *on
     c                   eval      nxtscr = '03 '
     c                   exsr      scr03i
     c                   endif
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
650mA*
650mA*      F20 - Accept Warning.
650mA*
650mAC                   if        *inku
650mAC                             or *inkj
650mAC                   eval      ovrrid = *on
650mAC                   else
650mAC                   eval      ovrrid = *off
650mAC                   endif
     C     endcm3        endsr
700iA*----------------------------------------------------------------
700iA*
700iA*  ZZCMD4   User defined command keys for screen 4.
700iA*
700iAC     zzcmd4        begsr
700iAC                   eval      cmdtkn = *off
700iA*
700iAC     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMDCNL User defined command keys for cancel window warning
     *
     C     zzcmdCnl      begsr
     C     endcmCnl      endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
700eA /free
700eA   select;
700eA     when svopwum = 'KGS'
700eA      or svopwum = 'kgs'
700eA      or svopwum = 'Kgs';
700eA       if KiloLbs = 'K';
700eA         eval cnvwgt = w1dwgt;
700ea       else;
700eA         eval(h) cnvwgt = w1dwgt / kgs2lbs;
700eA       endif;
700eA     other;
700eM       if KiloLbs = 'K';
700eM         eval(h) cnvwgt = w1dwgt * kgs2lbs;
700eM       else;
700eM         eval cnvwgt = w1dwgt;
700eM       endif;
700eA   endsl;
700eA /end-free
     *
     *    If in kilograms mode, convert into pounds for processing.
     *
700eDC*                  if        KiloLbs = 'K'
700eDC*                  eval(h)   cnvwgt = w1dwgt * kgs2lbs
700eDC*                  else
700eDC*                  eval      cnvwgt = w1dwgt
700eDC*                  endif

     C                   endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
700iA*----------------------------------------------------------------
700iA*
700iA*  ZZDFT4   Get default values for add.
700iA*
700iAC     zzdft4        begsr
700iA /free
700iA   // setup which fields are displayed
700iA   if needb1 = *on;
700iA     w1bupc1 = ' ';
700iA     w1buom1 = $itum2;
700iA     *in38 = *off;
700iA   else;
700iA     *in38 = *on;
700iA   endif;
700iA   if needb2 = *on;
700iA     w1bupc2 = ' ';
700iA     w1buom2 = $itum3;
700iA     *in39 = *off;
700iA   else;
700iA     *in39 = *on;
700iA   endif;
700iA   cmdln1 = cmdln(14);
700iA /end-free
700iAC                   endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C*                  eval      $dridata2 = $uciinfo2
720aMC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0105s
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C*                  exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C*                  eval      $uciinfo2 = $dridata2
720aMC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr
650sA*----------------------------------------------------------------
650sA*
650sA*  ZZEXTSTG   External Storage Label creation
650sA*
650sAC     zzextstg      begsr
650sAC                   eval      $ewhdp = $itwhdp
650sAC                   eval      w3dev  = '*JOB'
650sAC                   eval      w3stg  = 'E'
650sA
650sA*  Springfield setup defaults for screen
650sA
650sAC                   if        client = sgc
650sA*  Protect stage field
650sAC                   eval      *in55 = *on
650sAC                   if        $ewhdp = 'DRY  '
650sAC                   eval      w3stg = 'K'
650sAC                   eval      w3dev  = 'LP8'
650sAC                   else
650sAC                   eval      w3stg = 'W'
650sAC                   eval      w3dev  = 'LP7'
650sAC                   endif
650sAC**                 eval      w3dev  = 'LP8       '
650sAC                   endif
650sA
650sA*  Eastland setup defaults for screen
650sA
650sAC                   if        client = eastland
650sA*  Protect stage field
650sAC                   eval      *in55 = *on
650sAC                   if        $ewhdp = 'CB   '
650sAC                   eval      w3stg = 'G'
650sAC***                eval      w3dev  = 'LP8'
650sAC                   else
650sAC                   eval      w3stg = 'F'
650sAC***                eval      w3dev  = 'LP7'
650sAC                   endif
650sAC                   endif
650sA
650sA*  Process window to produce license plates for external storage
650sA
650sAC                   dow       forevr = forevr
650sAC                   exfmt     WEXTSTG
650sAC                   if        *inkl = *on
650sAC                   leave
650sAC                   endif
650sA
650sAC                   eval      *in52 = *off
650sAC                   eval      *in53 = *off
650sAC                   eval      *in54 = *off
650sAC                   eval      *in55 = *off
650sA
650sA*     Make sure staging is not blank
650sA
650sAC                   if        w3stg = ' '
650sAC                   eval      *in54 = *on
650sAC                   iter
650sAC                   endif
650sA
650sA*     Check number of pallets entered
650sA
650sAC                   if        rpal < w3pal
650sAC                   eval      *in52 = *on
650sAC                   iter
650sAC                   endif
650sA
650sA*     Number of pallets cannot be zero
650sA
650sAC                   if        w3pal = 0
650sAC                   eval      *in53 = *on
650sAC                   iter
650sAC                   endif
650sA
650sA
650sA*     No errors, create slots and print labels
650sA
650sAC                   eval      extstgFlag = *on
650sAC                   for       i = 1 to w3pal
650sAC                   exsr      zzextstg2
650sAC                   eval      icblcns = *off
650sAC                   eval      icbolcn = *blanks
650sAC                   if        error
650sAC                   leave
650sAC                   endif
650sAC                   if        client = icb
650sAC                   eval      icbolcn = wklic
650sAC                   eval      icblcns = *on
650sAC                   endif
650sAC                   endfor
650sAC                   leave
650sA
650sAC                   enddo
650sA
650sAC                   endsr
650sA*----------------------------------------------------------------
650sA*
650sA*  ZZEXTSTG2  Create OSS slot
650sA*
650sAC     zzextstg2     begsr
650sA
650sA*  Set #rcvarea to apppropriate OSS area.
650sA
650sAC                   select
650sA
650sAC                   when      client = sgc
650sAC                             and w3stg = 'K'
650sAC                   eval      #rcvarea = 'KANSAS'
650sA
650sAC                   when      client = sgc
650sAC                             and w3stg = 'W'
650sAC                   eval      #rcvarea = 'WILLOW'
650sA
650sAC                   when      client = eastland
650sAC                             and w3stg = 'G'
650sAC                   eval      #rcvarea = 'CGEN'
650sA
650sAC                   when      client = eastland
650sAC                             and w3stg = 'F'
650sAC                   eval      #rcvarea = 'CFROZ'
650sA
650sAC                   other
650sAC                   eval      #rcvarea = w3stg
650sA
650sAC                   endsl
650sA
650sA*  Create special license
650sA
650sAC                   call      'PIROSSLCN'
650sAC                   parm                    $pwhse
650sAC                   parm                    w3stg
650sAC                   parm      ' '           wklic            15
650sA
650sA*  Initialize slot fields
650sA
650sAC                   exsr      clr$slot
650sAC                   eval      $slwhseu = *on
650sAC                   eval      $slwhse  = $pwhse
650sAC                   eval      $slwhdpu = *on
650sAC                   eval      $slwhdp  = $itwhdp
650sAC                   eval      $slitemu = *on
650sAC                   eval      $slitem  = $ititem
650sAC                   eval      $sldispu = *on
650sAC                   eval      $sldisp  = ' '
650sAC                   eval      $slstatu = *on
650sAC                   eval      $slstat  = ' '
650sAC                   eval      $slstypu = *on
650sAC                   eval      $slstyp = $itstyp
650sAC                   eval      $slexpdu = *on
650sAC                   eval      $slexpd = $rexpd
650sAC                   eval      $saitemu = *on
650sAC                   eval      $saitem  = $ititem
650sA
650sAC                   eval      $saqtyu = *on
650sAC                   eval      $saqty1 = 0
650sAC                   eval      $saqty2 = 0
650sAC                   eval      $saqty3 = 0
650sA
650sAC                   eval      $saActionU = *on
650sAC                   eval      $saAction = 'OSS'
650sAC                   eval      $saTrn#U = *on
650sAC                   eval      $saTrn# = 0
650sAC                   eval      $saETrn#U = *on
650sAC                   eval      $saETrn# = 0
650sAC                   eval      $saLbl#U = *on
650sAC                   eval      $saLbl# = 0
650sAC                   eval      $saToPosU = *on
650sAC                   eval      $saToPos = 1
650sAC                   eval      $saToVrfyU = *on
650sAC                   eval      $saToVrfy = 'N'
650sAC                   eval      $saToCodeu = *on
650sAC                   eval      $saToCode = 'D'
650sAC                   eval      $saToAreaU = *on
650sAC                   eval      $saToArea = #rcvarea
650sA
650sAC                   eval      $saToLcnsU = *on
650sAC                   eval      $saToLcns = wklic
650sAC                   eval      $saOLcnsU = *on
650sAC                   eval      $saOLcns = wklic
650sA
650sAC                   eval      $dricommand = '*SLOT'
650sAC                   eval      $drisubcmd  = '%OSSIN'
650sAC                   eval      $drisys2upd = 'D'
650sAC                   eval      ck4err = *on
650sAC                   eval      zmflag  = *on
650sAC                   exsr      zzzdricop
650sAC                   if        error
650sAC                   leavesr
650sAC                   endif
650sA
650sA*  Create workoss record
650sA
650sAC                   eval      wowhse  = $slwhse
650sAC                   eval      wowhdp  = $slwhdp
650sAC                   eval      wodisp  = $sldisp
650sAC                   eval      wolcns  = wklic
650sAC                   eval      woaddts   = %timestamp()
650sAC                   eval      woaddcusr = #curruser
650sAC                   eval      woaddjob  = #job
650sAC                   eval      woaddnbr  = #jobnbr
650sAC                   write(e)  worec
650sA
650sA*  Print label
650sA
650sAC                   eval      $plfmt = 'STORAGE'
650sAC                   select
650sAC                   when      client = sgc
650sA ***                eval      $plset = 'STOSFG'
650sAC                   eval      $plset = 'ZBRSF2'
650sAC                   when      client = eastland
650sAC                   eval      $plset = 'ZBREFC'
650sAC                   other
650sAC                   eval      $plset = 'PLBL40'
650sAC                   endsl
650sA *
650sAC                   if        w3dev <> '*JOB'
650sAC                   eval      $pdev  = w3dev
650sAC                   endif
650sA
650sAC                   eval      $pexpda = %editc($rexpd:'X')
650sAC                   eval      $pindta = %editc(today:'X')
650sA
740cMC                   call      @PRTPG
650sAC                   parm                    $pcmd             8
650sAC                   parm                    $plset            6
650sAC                   parm                    $plfmt            8
650sAC                   parm      $pwhse        $plwhse           3 0
650sAC                   parm                    $pwhsd           30
650sAC                   parm                    $slwhdp
650sAC                   parm                    $sldisp
650sAC                   parm                    $pdispa           1
650sAC                   parm                    $pdispb          11
650sAC                   parm                    $pchkd1           3
650sAC                   parm                    $pchkd2           3
650sAC                   parm                    $pchkd3           3
650sAC                   parm                    wklic            15
650sAC                   parm                    $plcn2           15
650sAC                   parm                    $slitem
650sAC                   parm                    $pbrnd           10
650sAC                   parm                    $ppdesc          15
650sAC                   parm                    $itdesc          30
650sAC                   parm                    $ptxt1           30
650sAC                   parm                    $ptxt2           30
650sAC                   parm                    $ptxt3           30
650sAC                   parm                    $ptrailr          8
650sAC                   parm                    $psize            3
650sAC                   parm                    $pdev            10
650sAC                   parm                    $pform           10
650sAC                   parm                    $pexpda           8
650sAC                   parm                    $pindta           8
650sA
650sAC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 1 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *    Default FIFO entered date if entry is allowed.
     C                   if        not *in89
     C                   move      today         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        todayo
     *
     C                   eval      w1fifo = todayo
     C                   else
     C                   eval      w1fifo = 0
     C                   endif
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #pgm
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = pditem
     *    Protect,non-display lot code entry field.
     C                   eval      *in88 = *on
     C                   call      'GETLLP'
     C                   parm                    $lparm
     *
     C                   select
     *    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
     c                             or $plot <> ' '
     C                   eval      lottrk = '*YES'
     *    Display lot code entry field.
     C                   eval      *in88 = *off
     C                   else
     C                   eval      lottrk = '*NO '
     C                   endif
     C                   if        $lltrk = 'Y'
     C                   eval      lictrk = '*YES'
     C                   else
     C                   eval      lictrk = '*NO '
     C                   endif
     C                   other
     C                   eval      lottrk = '*NO '
     C                   eval      lictrk = '*NO '
     C                   endsl
     C                   if        $pcmd = '*QUICK  '
     C                   eval      w1qrc1 = pdqor1
     C                   eval      w1qrc2 = pdqor2
     C                   eval      w1qrc3 = pdqor3
     C                   else
     C                   eval      w1qrc1 = 0
     C                   eval      w1qrc2 = 0
     C                   eval      w1qrc3 = 0
     C                   endif
     C                   eval      w1exdt = 0
     C                   eval      w1avg = 'N'
     C                   eval      iatest = *blanks
     C                   eval      iaflag = *off
     C                   eval      w1mfdt = 0
     C                   eval      w1lotc = *blanks
     C                   eval      woexdt = 0
     C                   eval      woindt = 0
     c                   if        moretoscan <> *on
     C                   eval      w1brand = *blanks
     c                   endif
     *
     *   Get Unit of measure fields
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   eval      w1dwgt = 0
     C                   if        client = cheney
     C     $itdesg       chain     desigsp                            79
     C                   if        *in79 = *off
     C                   eval      sdesig = *on
     C                   else
     C                   eval      sdesig = *off
     C                   eval      dsscde = *blanks
     C                   endif
     C                   endif
     C                   if        client = yhata
     C                   eval      *in63 = *off
     C*   Convert quantity to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #pgm
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   eval      woqor = $cqstr
     C*
     C                   else
     C                   eval      *in63 = *on
     C                   eval      woqor = *blanks
     C                   endif
     *
     *   Enable/Disable catch weight fields.
     *
     C                   eval      vrfycw = *off
     C                   eval      *in82 = *off
     *
     *     First, see if catch weight entry is allowed.
     *
     C                   if        ($itcwgt <> 'Y'  and
     C                              $itcwgt <> 'S') or
     C                             svcwen = '3'
     C                   eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   else
     C                   eval      *in95 = *off
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see if we should block entry ...
     *       because catch weight previously entered.
     *
     C                   if        svcwen = '2'  and
     C                             pddwgt <> 0
     C                   eval      *in82 = *on
     C                   eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   endif
650tA*     if uci receiving and item is catch weight must get catchweigt
650tA*       either from barcode or from entry.
650tAC                   if        $itcwgt = 'Y' and
650tAC                             $ifucicde = '2'
650tAC                   eval      *in95 = *off
650tAC                   eval      vrfycw = *on
650tAC                   endif
     *
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C                   eval      *in81 = *on
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(2)
     C                   when      svcwtp = '3'
     C                   eval      *in81 = *on
     C                   eval      w1avg = 'Y'
     C                   eval      wocrcv = cwt(3)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      w1avg = 'N'
     C                   eval      wocrcv = cwt(1)
     C                   endsl
     *
     *   Enable/Disable expiration date fields.
     *
     C                   if        $itflgd <> 'Y'
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in96 = *off
     C                   endif
     *
     *
     C                   if        $itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse
     C                   parm                    #sitem
     C                   parm                    woslot
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     *
     * Try to display Special Designation slot.
     C                   select
     C                   when      Client = cheney
     C                   if        woslot = '*NONE*  ' and
     C                             sdesig = *on
     C                   eval      woslot = dssdsp
     C                   endif
     C                   endsl
     *
     C                   eval      w1slot = *blanks
     *  See if any stock in overflow slot.
     *
     C                   eval      wOostk = 'N'
     C                   move      'A '          kystat
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
     C                   dow       forevr = forevr
     C     keys3         reade     slot3                                  79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        sldesg = 'BFC'
     C                   iter
     C                   endif
     *
     C                   if        not *in79
     C                   if        slstk1 > 0  or
     C                             slstk2 > 0  or
     C                             slstk3 > 0
     C                   eval      wOostk = 'Y'
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     *   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
     *
     C                   if        not *in75  and
     C                             $immflg = 'Y'
     C                   eval      *in87 = *off
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in87 = *on
     C                   endif
640bDC*                  if        *in79
640bMC                   if        *in75
     C                   eval      $immflg = 'N'
     C                   endif
      * load up fields from uci incoming information
      * Expiration Date
     c                   If        not *in96
     c                   if        $pexpdt > 0
     C                   move      $pexpdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt
     c                   endif
     c                   endif
      * Manufacturing Date
     c                   If        $immflg = 'Y'
     c                   if        $pmfgdt > 0
     C                   move      $pmfgdt       $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1mfdt
     c                   endif
     c                   endif
      * Lot
     c                   If        lottrk = '*YES'
     c                   if        $pLot <> ' '
     c                   eval      w1lotc = $plot
     c                   endif
     c                   endif
      * Catch Weight
     c                   If        vrfycw = *on
     c                   if        $pwgt > 0
     c                   eval      w1dwgt = $pwgt
     c                   endif
     c                   endif
      * Quantity
     c                   if        $pqty > 0
     c                   eval      w1qrc1 = $pqty
     c                   eval      *in71 = *on
     c                   eval      *in01 = *off
     c                   else
      * assume qty1 if uci receiving
720aAc                   select
720aAc                   when      uputyp = 'N'
720aAc                   eval      w1qrc1 = 1
720aAc                   when      uputyp = '1'
720aAc                   eval      w1qrc2 = 1
720aAc                   when      uputyp = '2'
720aAc                   eval      w1qrc3 = 1
720aAc                   other
720aMc                   eval      w1qrc1 = 1
720aAc                   endsl
720aDc*                  eval      w1qrc1 = 1
     c                   eval      *in71 = *on
     c                   eval      *in01 = *off
     c                   endif
      * # of Pallets
     c                   if        $p#pall > 0
     c                   endif
      * Cross Dock - use temporary license
     c                   if        $pxd = 'XD'
     c                   eval      w1lcns = 'Cross Dock'
     c                   eval      templcns = 'XD' +  #jobnbr
     c                   eval      *in73 = *on
     c                   eval      *in15 = *off
     c                   else
     c                   eval      *in73 = *off
     c                   eval      templcns = ' '
     c                   endif
      * pos cursor to brand if brand is used
     c                   if        *in74 = *off
     c                   eval      *in16 = *on
     c                   else
     c                   eval      *in16 = *off
     c                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 2 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1po = pdpo
     C                   eval      w1item = pditem
     C                   eval      w2vitm = pdvitm
     C                   eval      w1whse = $pwhse
     C     w1whse        chain     warehs                             79
     C                   if        not *in79
     C                   eval      w1fdsc = whdesc
     C                   else
     C                   eval      w1fdsc = *blanks
     C                   endif
650uA * OSS Receiving
650uA /free
650uA     w1note = ' ';
650uA     *in70 = '0';
650uA   if $posscode <> ' ';
650uA     w1note = 'OSS Receiving';
650uA     *in70 = '1';
650uA   endif;
650uA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             79
     *
     *  Record locked.
     *
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *   If viewing, release record.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif
     C                   if           client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C*      Retrieve P/O Detail Misc. record.
     C                   if        pditem = rtxall9item
     C                   exsr      zzgtpdm
     C                   endif
     C                   endif
     C*
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUCI    Write UCI data
     *
     C     zzuci         begsr
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     C                   endif
     * add records to uci file
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   eval      $code = #curruser
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
      /free
        // need to determine if the licinfo record already exist for
        // this lcns/lot/exp date - keep checking until we find a match
        // or no more licinfo records exist - if no match and no licinfo
        // exist need to write the next available seq# to licinfo.
        // if licinfo record exist - just update the qty and the weight
        select;
          when moretoscan = *on and difflot = *on  or
               moretoscan = *on and diffexpd = *on;
            exsr zzlicinfochk;
          when moretoscan = *on and difflot <> *on and diffexpd <> *on;
            exsr zzlicinfoseq;
        endsl;

        if licinfoupd <> *on and difflot = *on or
           licinfoupd <> *on and diffexpd = *on or
           moretoscan <> *on;
          exsr zzlicinfonew;
        endif;

        exsr clr$uciinfo;
        $uiWhse = $pwhse;
        $uiItem = $pitem;
        $uiuci = w1uci;
        ucilic#($unext: $pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        if $pxd = ' ';
          $uiLcns = w1lcns;
        else;
          $uiLcns = templcns;
        endif;
        if difflot = *on or
          diffexpd = *on;
          $uiseq = $lnseq;
        else;
          $uiseq = 1;
        endif;
        $uiSerial = $bcSer#;
720aA   if $bcgtin = *blanks;
720aA      $uiaGTin = 0;
720aA   else;
720aA      $uiaGtin   = %DEC($bcgtin:14:0);
720aA   endif;
740eA   if $bcai99sent and saveqty = 0;
740eA     uputyp = 'N';
740eA   endif;
720aA   $uiaLot    = $bclot;
720aA   $uiaUTyp   = uputyp;
720aA   $uiaSlUTyp = uputyp;
720aA   if saveexpd = 0;
720aA      $uiaExpD   = expd;
720aA   else;
720aA      $uiaExpD = saveexpd;
720aA   endif;
720aA   $uiaEntD   = today;
        // if user entered weight use that/ if uci had weight use that
        // 700e metric changes
        select;
700eD     //when w1dwgt > 0;
700eM     when w1dwgt > 0 and kilolbs = 'P';
            $uiwgtlbs = w1dwgt;
          when $bcPNtLbSent = *on;
            $uiwgtlbs = $bcPNtLb;
          other;
            $uiwgtlbs = 0;
        endsl;
        // Weight KG  - only if uci barcode contained KG
        // 700e metric changes - if item options weight uom = kgs
700eM   select;
700eA     when svopwum = 'KGS'
700eA      or  svopwum = 'kgs'
700eA      or  svopwum = 'Kgs';
700eA       select;
700eA         when w1dwgt > 0 and kilolbs = 'K';
700eA           $uiwgtkgs = w1dwgt;
700eA         when w1dwgt > 0 and kilolbs = 'P';
700eA           $uiwgtkgs = cnvwgt;
700eA         when $bcPNtkgSent = *on;
700eA           $uiwgtkgs = $bcPNtkg;
700eA         other;
700eA           $uiwgtkgs = 0;
700eA       endsl;
700eA     other;
            if $bcPNtKgSent = *on;
              $uiWgtKgs = $bcPntKg;
            else;
              $uiWgtKgs = 0;
            endif;
700eA   endsl;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '1';

720aA   // Lets add some more stuff for tracking
720aA   $uiaction = 'RCV';
720aA   $uiaolcns = $uilcns;
720aA   $uialcns = $uilcns;
720aA   $uiaoseq = $uiseq;
720aA   $uiscan = 'Y';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        ck4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error;
          uciExists = *on;
          error = *on;
          errmsg= desc(11);
          exsr zm02;
          leavesr;
        else;
          UciExists = *off;
          error = *off;
        endif;

        // save the values from the first scan to be used for the license
        if moretoscan <> *on;
          if $immflg = 'Y';
            savew1mfdt = w1mfdt;
          endif;
          if $itflgd = 'Y';
            savew1exdt = w1exdt;
          endif;
          saveexpd = expd;
          savelotc = w1lotc;
        endif;
700eD   //savewgt  = savewgt + w1dwgt;
700eM   savewgt  = savewgt + cnvwgt;
        saveqty  = saveqty + 1;
        // scan some more uci barcodes
        // save first scanned lot and dates
        moretoscan = *on;
720bA   *in80 = *on;
        nxtscr = '01 ';
        $puci = ' ';
        w1uci = ' ';
650nA   savew1uci = ' ';
650nA   savew1uci = ' ';
        ovrrid = *off;
        difflot = *off;
        diffexpd = *off;
        lotwarn = *off;
650vA   UPCwarn = *off;
        expdwarn = *off;
        lotovr  = *off;
650vA   UPCovr  = *off;
        expdovr  = *off;
        licinfoupd = *off;

740aA   // Are we loading canopy gs1 labels that have been printed
740aA   psessid = #user + #jobn;
740aA   chain ($uiwhse: $uiserial: $uiuci) uciwork2;
740aA   if %found(uciwork2);
740aA     can_uiwload = 'Y';
740aA     update uiwrec;
740aA     // this is a canopy gs1 label we need to auto load the others
740aA     setll (can_uiwwhse: can_uiwpo: can_uiwposeq) uciwork3;
740aA     dow forevr = forevr;
740aA       reade (can_uiwwhse: can_uiwpo: can_uiwposeq) uciwork3;
740aA       if %eof(uciwork3);
740aA         leave;
740aA       endif;
740aA       if can3_uiwload = 'Y';
740aA         iter;
740aA       endif;
740aA       if can3_uiwpo <> $ppo;
740aA         iter;
740aA       endif;
740aA       if can3_uiwposeq <> $pseq;
740aA         iter;
740aA       endif;
740aA       if can3_uiwitem <> $pitem;
740aA         iter;
740aA       endif;
740aA       if can3_uiwprint <> 'Y';
740aA         iter;
740aA       endif;
740aA       // ready to auto load a uci
740aA       exsr clr$uciinfo;
740aA       $uiWhse = can3_uiwwhse;
740aA       $uiItem = can3_uiwitem;
740aA       $uiuci = can3_uiwuci;
740aA       ucilic#($unext: $pwhse);
740aA       unexta = %editc($unext:'X');
740aA       $uiuciLcns = 'U:' + unexta;
740aA       if $pxd  = ' ';
740aA         $uiLcns = w1lcns;
740aA       else;
740aA         $uiLcns = templcns;
740aA       endif;
740aA       //if difflot = *on or
740aA         //diffexpd = *on;
740aA         //$uiseq = $lnseq;
740aA       //else;
740aA       $uiseq = 1;
740aA       //endif;
740aA       $uiSerial = can3_uiwserial;
740aA       $uiwgtlbs = can3_uiwwgtlbs;
740aA       savewgt  = savewgt + $uiwgtlbs;
740aA       saveqty  = saveqty + 1;
740aA       $uiWgtKgs = 0;
740aA       $uiSelTrn# = 0;
740aA       $uiSelLbl# = 0;
740aA       $uiSelOrd = 0;
740aA       $uiSelSeq = 0;
740aA       $uiSelCSeq = 0;
740aA       $uiSelTrax = ' ';
740aA       $uiCrtBy = '1';
740aA       $uiaGtin = %dec(can3_uiwgtin:14:0);
740aA       $uiaLot  = ' ';
740aA       //workupc = blank6 + $bcGtin;
740aA       //uputyp     = 'N';
740aA       //exec sql select * into :uprecuom
740aA          //from upc
740aA          //where upwhse = :pwhse
740aA            //and upITEM = :ppoitem
740aA            //and upupc  = :workupc
740aA          //fetch first row only;
740aA       $uiaUTyp   = uputyp;
740aA       $uiaSlUTyp = uputyp;
740aA       if saveexpd = 0;
740aA          $uiaExpD = expd;
740aA       else;
740aA          $uiaExpD = saveexpd;
740aA       endif;
740aA       $uiaEntD   = today;
740aA       // Lets add some more stuff for tracking
740aA       $uiaction = 'RCV';
740aA       $uiaolcns = $uilcns;
740aA       $uialcns = $uilcns;
740aA       $uiaoseq = $uiseq;
740aA       $uiscan = 'Y';
740aA
740aA       $dricommand = '*UCIINFO';
740aA       $drisubcmd  = '%ADD';
740aA       $drisys2upd = 'D';
740aA       ck4err= *on;
740aA       zmflag  = *off;
740aA       exsr zzzdricop;
740aA       if error;
740aA         error = *on;
740aA         errmsg = $drimessage;
740aA         exsr zm0105;
740aA       else;
740aA         can3_uiwload = 'Y';
740aA         *inkw = *on;
740aA         update uiwrec3;
740aA       endif;
740aA     enddo;
740aA     // simulate the completed license command key
740aA     if *inkw;
740aA       exsr zzrcvpocheck;
740aA       if saveqty > 0;
740aA         cmdtkn = *on;
740aA         nxtscr = '03 ';
740aA         exsr scr03i;
740aA       endif;
740aA     endif;
740aA   endif;
      /end-free
     c
     C     enduci        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for SLOT2 file.
     *
     C     slkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $itwhdp
     C                   kfld                    w1slot
     *  Define partial key for SLOT3 file.
     *
     C     keys3         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ititem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *     UPC
     *
     C     upcky         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1upc
     *
     C     upcky3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    w1upc
     C                   kfld                    phven
     *
700iAC     upcky3U       klist
700iAC                   kfld                    $pwhse
700iAC                   kfld                    $pitem
700iAC                   kfld                    w1upc
700iAC                   kfld                    phven
700iAc                   kfld                    uputyp
     C     upcky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    ckupc
     *
     C     upcky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    phven
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
     **                   KFLD           $PITEM
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *
     *  Define key for LABEL2  file.
     *
     C     lbkey         klist
     C                   kfld                    $lord
     C                   kfld                    $pwhse
     *
     *  Define key for POCTYPE file.
     *
     C     keypoc        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   eval      forevr = *on
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $cvprg = #pgm
     C                   eval      #pgmq = #pgm
     C                   eval      $rprg = #pgm
      * determine if mfr decipher is available to client
     c                   eval      $lcmd = '*OPEN'
     c                   call      'MF200'                              66
     C                   parm                    $lparm
     C                   parm      0             $lexpdat          6 0
     C                   parm      0             $lmfrdat          6 0
     C                   parm                    $lupc            20
     C                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
     *
     C                   setoff                                       kckl
     C                   eval      dtchk = *off
     C                   eval      dtchk2 = *off
     C                   eval      dtchk3 = *off
     C                   eval      dtchk4 = *off
     C                   eval      qtchk = *off
     C                   eval      qtchk1 = *off
     C                   eval      wtchk = *off
     C                   eval      upchk = *off
     C                   eval      upchk2 = *off
     C                   eval      expd = 0
700iAC                   eval      needb1 = *off
700iAC                   eval      needb2 = *off
     *    Default to 'pounds' mode.
700eDC*                  eval      KiloLbs = 'P'
700eDC*                  eval      W1KgLb  = 'Lbs'
     *    Setup command display line 2.
     C                   eval      cmdln2 = cmdln(7)
     *
     *   Cannot receive an item, if the PO is ready for export.
     *
     C     phkey         chain(n)  pohdr                              79
     C                   if        not *in79  and
     C                             phstat = '3'
     C                   exsr      zm3226
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      endinz
     C                   endif
     *
     *   Set Move In FIFO flag.
     C                   if        phvnam = 'MOVEIN'  or
     C                             phvnam = move1  or
     C                             phvnam = move2
     C                   eval      *in89 = *off
     C                   else
     C                   eval      *in89 = *on
     C                   endif
     *
     *   Remove any existing catchweight entry records.
     C                   exsr      zzdlcw
     *
     C                   eval      lflag = *off
     C                   exsr      zzxopt
     C                   exsr      zzlcns
     *
     C                   eval      ocode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
770aAC                   eval      opdckv = 'N'
     C                   endif
770aA
770aAc                   if        opdckv = 'Y'
770aAc                   eval      dockvue = *on
770aAc                   else
770aAc                   eval      dockvue = *off
770aAc                   endif
770aA
     *
     *   Select first screen to display.
     *
     *
     C                   movel     w1upcd        w1upc
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
     C                             $pcmd = '*QUICK  '
     C                   exsr      scr01i
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
     C                   if        svrupc = 'Y'
     C                   exsr      zzrupc
     C     error         cabeq     *on           endinz
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VIEW   '
     C                   endif
     c                   exsr      getitem
     *
     *    Setup command display line 1.
     *
700eA * code was moved to subr so it could be used for scr03i
700eAc                   exsr      setupcmdln1
     *
     C                   if        $pcmd <> '*QUICK  '
     C                   eval      $pcmd = '*CHANGE '
     C                   endif
     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZDLCW   Delete catchweight entry records.
     *
     C     zzdlcw        begsr
     *
     C                   eval      $mwhs3 = $pwhse
     C                   eval      $mpo3 = $ppo
     C                   eval      $mseq = $pseq
     C                   call      'DELTMPCW'
     C                   parm                    $mparm
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGTPDM  Get P/O Detail Misc. file
     *
     C     ZZGTPDM       Begsr
     C*
     C     fileky        chain     podtlm
     C                   if        not %found(podtlm)
     C                   eval      pdmitm = ' '
     C                   eval      pdmpom = ' '
     C                   eval      pdmods = ' '
     C                   eval      pdmms1 = ' '
     C                   eval      pdmms2 = ' '
     C                   eval      pdmms3 = ' '
     C                   eval      pdmms4 = ' '
     C                   eval      pdmms5 = ' '
     C                   eval      podm1_rtx = ' '
     C                   eval      rtxdm1_dnpckm = 0
     C                   eval      rtxdm1_dniaov = 'N'
     C                   eval      rtxdm1_dncwcd = 'N'
     C                   eval      rtxdm1_dnwtiw = 0
     C                   eval      rtxdm1_dncbec = 0
     C                   eval      podm2_rtx = ' '
     C                   eval      podm3_rtx = ' '
     C                   eval      podm4_rtx = ' '
     C                   eval      podm5_rtx = ' '
     C                   else
     *      Load P/O Detail Misc. record into Host Interface map fields.
     C                   eval      podm1_rtx = pdmms1
     C                   eval      podm2_rtx = pdmms2
     C                   eval      podm3_rtx = pdmms3
     C                   eval      podm4_rtx = pdmms4
     C                   eval      podm5_rtx = pdmms5
     C                   endif
     C*
     C                   Endsr
     C*
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
     C                   eval      lflag = *off
     C                   eval      svexck = *on
     C                   eval      svcwen = *on
     C                   eval      svcwtp = *on
     C                   eval      svcwfr = 'N'
     C                   eval      svrupc = 'N'
     C                   eval      ocode = '*RCVLBL '
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
     C                   endif
DRYfAc                   if        client = Dairyland
DRYfAc                   eval      opcwen = '1'
DRYfAc                   endif
     C                   eval      svexck = opexck
     C                   eval      svcwen = opcwen
     C                   eval      svcwtp = opcwtp
     C                   eval      svcwfr = opcwfr
     C                   eval      svrupc = oprupc
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     *----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
     *----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          Lastseq  = 1;
          dow forevr = forevr;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = lastseq + 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
            leave;
          else;
            // compare lot and date fields
            if $lnlot = w1lotc and
               $lnexpdate = expd;
              // add qty and weight, update licinfo
              $lnttllbs = $lnttllbs + w1dwgt;
              $lnseqqty = $lnseqqty + 1;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              ck4err = *on;
              exsr zzzdricop;
              licinfoupd = *on;
              leave;
            endif;
            eval lastseq = lastseq + 1;
          endif;

        enddo;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
     *----------------------------------------------------------------

      /free
        begsr zzlicinfoseq;

          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            $lnseqqty = $lnseqqty + 1;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            ck4err = *on;
            exsr zzzdricop;
            licinfoupd = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFONew Update New format of LICINFO
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = $pwhse;
          if $pxd = ' ';
            $lnlcns  = w1lcns;
          else;
            $lnlcns  = templcns;
          endif;

          if difflot or diffexpd;
            $lnseq = lastseq + 1;
            $lnseqqty = $lnseqqty + 1;
            $lnttllbs = w1dwgt;
          else;
            $lnseq = 1;
            $lnseqqty = 1;
          endif;
          $lnpo = $ppo;
          $lnposeq = $pseq;
          $lnitem = $pitem;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file

          select;
            when $ifucicde = ' ';
              $lnrcvtyp = '1';
            when $ifucicde = '1';
              $lnrcvtyp = '1';
            when $ifucicde = '2';
              $lnrcvtyp = '3';
            when $ifucicde = '3';
              $lnrcvtyp = '4';
            // don't know exactly what 2 will represent
          endsl;
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            when w1fifo <> 0;
              $lnentdate = wofifo;
            when w1mfdt <> 0;
              $lnentdate = womfdt;
            other;
              $lnentdate = woexdt;
          endsl;

          if wofifo > 0;
            $lnenttype = '*FIFODT';
          else;
            if $itflgd = 'Y';
              select;
                when $imuday > 0 or
                     $imdday > 0;
                  if $immflg = 'Y';
                    $lnenttype = '*MFGDTE';
                  else;
                    $lnenttype = '*USEDTE';
                  endif;
                other;
                  $lnenttype = '*EXPDTE';
              endsl;
            else;
              $lnenttype = '*ENTDTE';
            endif;

            $lndateflag = $itflgd;
            $lnmfgflag = $immflg;

            $lnmfgdays = $immday;
            $lnusrdays = $imuday;
            $lndstdays = $imdday;
          endif;

          $lnmfgdate = womfdt;

          if mexpd > 0;
            $lnmfgexp = mexpd;
          endif;

          if wofifo > 0;
            $lnfifodate = wofifo;
          endif;

          if expd > 0;
            $lnexpdate = expd;
          endif;

          if $ldecvalue > ' ';
            $lnmfgcode = $ldecvalue;
          endif;

          $lnavglbs = 0;

          if W1lotc <> ' ';
            $lnlot = w1lotc;
          endif;

          if w1brand <> ' ';
            $lnbrand = w1brand;
          endif;

650gA       // calculate the PTI.
650gA       if $bclot <> ' ' and $bcgtinsent;
650gA         pplot  = %subst($bclot: 1 : 20);
650gA         calcpti ($bcgtin: pplot: $pmfgdt: pppti);
650gA         if pppti > 0;
650gA           $lnlotPTI4 = %editc(pppti:'X');
650gA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650gA         endif;
650gA       endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZmfrdates  Set manufactures dates
     *
     C     zzmfrdates    begsr
     c                   select
     c                   when      $lmfrdat > 0 and $ldecvalue > ' '
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lmfrdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout


     *
     *  Calculate Mfg date if mfg exp date is entered
     *
     c                   when      $lexpdat > 0 and $ldecvalue > ' '

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lexpdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
640aAC                   eval      wkmday = $immday
YHAdA*  Use By date -1 to be used as mfg shelf life days
YHAdAC                   if        client = yhata
YHAdAC                   if        $immday = 0
YHAdAC                             and $imoday > 0
YHAdAC                   eval      wkmday = $imoday - 1
YHAdAC                   endif
YHAdAC                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
640aDC*                  parm      $immday       $cddays
640aMC                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout
640aDc*                  if        $immday = 0
640aMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   when      w1mfdt > 0 and $itflgd = 'Y'
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   when      w1exdt > 0

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
640aAC                   eval      wkmday = $immday
YHAdA*  Use By date -1 to be used as mfg shelf life days
YHAdAC                   if        client = yhata
YHAdAC                   if        $immday = 0
YHAdAC                             and $imoday > 0
YHAdAC                   eval      wkmday = $imoday - 1
YHAdAC                   endif
YHAdAC                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
640aDC*                  parm      $immday       $cddays
640aMC                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

640aDc*                  if        $immday = 0
640aMc                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPWD    Get password for expirtation date override
     *
     C     zzpwd         begsr
     *
     C                   eval      w1pwrd = *blanks
     C                   exfmt     paswrd
     C                   call      @pwd
     C                   parm      'PO232'       $PGMID           10
     C                   parm      w1pwrd        $PGMOPT          20
     C                   parm      'BFC'         $PUSR            10
     C                   parm                    $PRTN             8
     *
     C                   endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZRCVPOCHECK check for started RCVPO Transaction
650fA*
650fAC     zzrcvpocheck  begsr
650fA*
650fA*  See if RCVPO transaction is status 2 - start new if needed
650fA*
650fAC                   call      @crtrcv
650fAC                   parm      '*PO'         $lcmdr           10
650fAC                   parm      '*CHECK '     $lsubcmd         10
650fAC                   parm      $pwhse        @lwhse            3 0
650fAC                   parm      0             $lpcs             5 0
650fAC                   parm      0             $lpallets         5 0
650fAC                   parm                    $lsavetrn         7 0
650fAC                   parm                    $ppo              9
650fAC                   parm      $itstyp       $litstyp          1
650fAC                   parm      $itwhdp       $litwhdp          5
650fAC                   parm                    $lrtnr           10
650fAC                   endsr
650fA*----------------------------------------------------------------
650fA*
650fA*  ZZRCVPOCLOSE  Close RCVPO transaction.
650fA*
650fAC     zzrcvpoclose  begsr
650fAc                   if        rcvpocomplete

650fAc                   select
650fAc                   when      $lrq1 > 0
650fAc                   eval      poppcs = $lrq1
650fAc                   when      $lrq2 > 0
650fAc                   eval      poppcs = $lrq2
650fAc                   when      $lrq3 > 0
650fAc                   eval      poppcs = $lrq3
650fAc                   endsl

650fAC                   call      @crtrcv
650fAC                   parm      '*PO'         $lcmdr           10
650fAC                   parm      '*COMPLETE'   $lsubcmd         10
650fAC                   parm      $pwhse        @lwhse            3 0
650fAC                   parm      poppcs        $lpcs             5 0
650fAC                   parm      $lrpal        $lpallets         5 0
650fAC                   parm                    $lsavetrn         7 0
650fAC                   parm                    $ppo              9
650fAC                   parm      $itstyp       $litstyp          1
650fAC                   parm      $itwhdp       $litwhdp          5
650fAC                   parm                    $lrtnr           10
650fAc                   else

650fAc                   eval      $lpcs = 0
650fAC                   call      @crtrcv
650fAC                   parm      '*PO'         $lcmdr           10
650fAC                   parm      '*CLOSE'      $lsubcmd         10
650fAC                   parm      $pwhse        @lwhse            3 0
650fAC                   parm      0             $lpcs             5 0
650fAC                   parm      0             $lpallets         5 0
650fAC                   parm                    $lsavetrn         7 0
650fAC                   parm                    $ppo              9
650fAC                   parm      $itstyp       $litstyp          1
650fAC                   parm      $itwhdp       $litwhdp          5
650fAC                   parm                    $lrtnr           10
650fAc                   endif
650fAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRUPC   Verify Retail UPC on file for item.
     *
     C     zzrupc        begsr
     *
     C                   eval      $mcmd = '*VERIFY '
     C                   eval      $mwhs3 = $pwhse
     C                   eval      $mpo3 = $ppo
     C                   eval      $mseq = $pseq
     C                   eval      $mitm3 = $pitem
     *
     C                   call      'PO245'
     C                   parm                    $mparm
     *
     C                   select
     C                   when      $mrtn = '*EXIT   '  or
     C                             $mrtn = '*CANCEL '
     C                   eval      error = *on
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTIHI   Get use Preferred or 1st tie hi record.
     *
     C     zztihi        begsr
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = $idtie(1)
     C                   eval      svhi = $idhigh(1)
     C                   endif
     c                   do        5             t
     c                   if        $idpref(t) = 'Y'
     C                   eval      wotie = $idtie(t)
     C                   eval      wohi = $idhigh(t)
     c                   leave
     c                   endif
     c                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
     *
     c                   if        client = finkle
     C                   eval      *in86 = *on
     C                   else
     C                   eval      *in86 = *off
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTTLE   Accumlate total exception quantity.
     *
     C     zzttle        begsr
     *
     C     fileky        setll     poexcp
     C                   dow       forevr = forevr
     C     fileky        reade     poexcp                                 76
     C                   select
     C                   when      *in76
     C                   leave
     *
     C                   other
     C                   add       peqex1        svqrc1
     C                   add       peqex2        svqrc2
     C                   add       peqex3        svqrc3
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN94=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C                   eval      wolbl = *blanks
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
     *
     C                   eval      ssbflg = *off
     C                   eval      wolbls = *blanks
     C                   eval      wositm = *blanks
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     *
     c*                  exsr      getitem
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
     C                   eval      $itdesc = *blanks
     C                   eval      $itpdsc = *blanks
     C                   eval      $itcwgt = 'N'
     C                   eval      wopdsc = *blanks
     C                   eval      wolbl = lbl(4)
     C                   movel     desc(8)       woitem
     C     '-'           cat       woitem:1      woitem
     C     $pitem        cat       woitem:1      woitem
     C                   goto      enduom
     C                   else
     C*
      * check for brand flag
     c                   if        $ifbrdflg = 'Y'
     c                   eval      *in74 = *off
     c                   else
     c                   eval      *in74 = *on
     c                   endif
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $itwhdp = rtxdm1_dnwhdp
     C                   eval      $itdesc = pdmods
     C                   eval      $itcwgt = rtxdm1_dncwcd
     C                   eval      $itswgt = rtxdm1_dnwtiw
     C                   eval      $itcube = rtxdm1_dncbec
     C                   endif
     C                   endif
     C*
     C                   eval      wopdsc = $itpdsc
     C                   exsr      zztihi
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #otype = $ittype
     C                   eval      #oitem = $ititem
     C                   eval      #odesc = $itdesc
     C                   eval      #opdsc = $itpdsc
     C                   eval      #oswgt = $itswgt
     C                   eval      #oum1 = $itum1
     C                   eval      #oum2 = $itum2
     C                   eval      #oum2q = $itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = $itum3
     C                   eval      #oum3q = $itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
730aAc                             and #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     *
     C                   if        client = Renzi
     *   Force standard-wgt catchwgt to non-catchwgt.
     C                   if        $itcwgt = 'S'
     C                   eval      $itcwgt = 'N'
     C                   endif
     *
     C                   endif
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
     C                   if        $itum1 <> *blanks
     C     $itum1        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu1 = umshrt
     C                   else
     C                   movel     $itum1        #osu1
     C                   endif
     C                   endif
     *
     C                   if        $itum2 <> *blanks
     C     $itum2        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu2 = umshrt
     C                   else
     C                   movel     $itum2        #osu2
     C                   endif
     C                   endif
     *
     C                   if        $itum3 <> *blanks
     C     $itum3        chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu3 = umshrt
     C                   else
     C                   movel     $itum3        #osu3
     C                   endif
     C                   endif
     *
     *   Initialize base information.
     *
     C                   eval      #bitem = $ititem
     C                   eval      #sitem = $ititem
     C                   eval      #bityp = $ittype
     C                   eval      #bdesc = $itdesc
     C                   eval      #bpdsc = $itpdsc
     C                   eval      #bum1 = $itum1
     C                   eval      #bum2 = $itum2
     C                   eval      #bum3 = $itum3
     C                   eval      #bsu1 = #osu1
     C                   eval      #bsu2 = #osu2
     C                   eval      #bsu3 = #osu3
     *
     *   Get SSB item, if one exists
     *
     C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        $ittype = 'C'  or
     C                             $ittype = 'A'  or
     C                             $ittype = 'S'  or
     C                             $ittype = 'B'
     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
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
     C                   parm                    #brtn
     C                   endif
     *   Get slot item.
     C                   call      @getsi
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
     C                   if        #bum1 <> #oum1
     C     #bum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu1 = umshrt
     C                   else
     C                   movel     #bum1         #bsu1
     C                   endif
     C                   endif
     *
     C                   if        #bum2 <> #oum2
     C     #bum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu2 = umshrt
     C                   else
     C                   movel     #bum2         #bsu2
     C                   endif
     C                   endif
     *
     C                   if        #bum3 <> #oum2
     C     #bum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu3 = umshrt
     C                   else
     C                   movel     #bum3         #bsu3
     C                   endif
     C                   endif
     *
     *
     *   Set indicators to protect breakdown quantities.
     *
     C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in94 = *on
     C                   endif
     C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     *
     *   When dealing with an SSB item, the quantity is actually
     *   received into the "normal" screen quantity. If a third
     *   breakdown is allowed, then that will be received into the
     *   breakdown 1 quantity on the screen. The second breakdown
     *   screen quantity is always protected for an SSB item.
     *
     C                   if        $ittype = 'S'  and
     C                             $itflg2 = 'Y'
     C                   eval      *in94 = *off
650bAc                   else
650bAc                   if        $ittype = 'S'
650bAc                   eval      *in94 = *on
650bAc                   endif
     C                   endif
     *
     C                   if        $ittype = 'S'
     C                   eval      *in93 = *on
     C                   endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a13
     C                   if        #otype = 'S'
     C                   movea     #osu2         a13(7)
     C                   else
     C                   movea     #osu1         a13(7)
     C                   endif
     C                   movea     a13           wolbl
     C     wolbl         cat       ')':0         wolbl
     C                   move      ':'           wolbl
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      woitem
     C     woitem        cat       '-':1         woitem
     C     woitem        cat       #odesc:1      woitem
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a13
     C                   movea     #bsu2         a13(6)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
     C                   movea     lbl(2)        a13
     C                   movea     'N/A'         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a13
     C                   movea     #bsu1         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     C                   endsl
     *
     *   Determine item number going into slot.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C                   eval      #sitem = #oitem
     C                   endif
     *
     *   Get extend description headings if being used.
     *
     C                   if        uxflag = *off
     C                   else
     C                   if        not *in75
     C*
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $ixdsc1 = pdmods
     C                   endif
     C                   endif
     C*
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
     C                   endif
     C                   endif
     *
     *   Initialize unit of measure names for quantity fields.
     *
     C                   if        #otype = 'S'
     C                   eval      w1um1 = #osu2
     C                   else
     C                   eval      w1um1 = #osu1
     C                   endif
     *
     C                   if        not *in94
     C                   if        #otype = 'S'
     C                   eval      w1um2 = #osu3
     C                   else
     C                   eval      w1um2 = #osu2
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C                   eval      w1um3 = #osu3
     C                   endif
     *
     *   Determine if this item should be put away into warehouse.
     *   An '*' in last position of designation says that the item
     *   will NOT be put away into the warehouse.
     *
     C                   move      $itdesg       iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     *  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      $pwhse        $swhse
     C                   parm                    $itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     C                   eval      *in65 = *off
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     C                   eval      *in65 = *on
     C                   endif
     *
     *    The following EndIf is for statment *IN75 IFEQ *ON, which
     *    comes after the chain to PIRITEM.
     *
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  Outlog - Write UPCLOG Record for BiRite.
     *
     c     outlog        begsr
     *
     c     upcky3        chain     upclog
     c                   if        Not %Found(upclog)
     *
     c                   eval      ulwhse = $pwhse
     c                   eval      ulitem = $pitem
700iAc                   Select
700iAc                   when      w1upc <> ' '
700iAc                   eval      ulupc  = w1upc
700iAc                   when      b1upc <> ' '
700iAc                   eval      ulupc  = b1upc
700iAc                   when      b2upc <> ' '
700iAc                   eval      ulupc  = b2upc
700iAc                   endsl
700iDc*                  eval      ulupc  = w1upc
     c                   eval      ulven  = phven
     c                   eval      ulvnam = upvnam
     c                   eval      ulvitm = upvitm
     c                   eval      ulbran = upbran
     c                   eval      ulpo   = $ppo
     c                   eval      ulposq = $pseq
     c                   eval      uladte = today
     c                   time                    ulatim
     c                   eval      uluser = #curruser
     c                   eval      uljob  = #job
     c                   eval      uljob# = #jobnbr
     c                   write     ulrec
     *
     c                   endif
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update HDR record.
     *
     C     zzuhdr        begsr
     C                   eval      error = *off
     C                   eval      full = *on
     C                   eval      part = *off
     C                   eval      recv = *off
     C     partky        setll     podtl                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     partky        reade     podtl                                  79
     C                   move      *in79         eof
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
     C                   enddo
     *
     C                   if        recv = *off
     C                   eval      full = *off
     C                   eval      part = *off
     C                   endif
     *
     C     phkey         chain     pohdr                              79
     C                   if        not *in79
     C                   if        part = *on
     C                   eval      phstat = *on
     C                   endif
     C                   if        full = *on
     C                   eval      phstat = '2'
     C                   endif
     C                   if        part = *off  and
     C                             full = *off
     C                   eval      phstat = *off
     C                   endif
     C                   update    phrec
770aA*
770aA*   Update the POSTATUS file for a change to POHDR
770aA*   Check for DockVue system option
770aA*
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
770aA*
     C                   endif
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
     C                   exsr      zzdlcw
     C                   endif
     *
     C     endhdr        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Move key values to parameters
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C     phkey         chain(n)  pohdr                              79
     C                   if        *in79
     C                   eval      phven = 0
     C                   eval      phvnam = *blanks
     C                   endif
     *
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     C                   endif
     *
     C                   if        w1upcd <> *blanks  and
     C                             w1upc <> *blanks
700iA /free
700iA   select;
700iA     when      w1qrc1 > 0;
700iA       eval      uputyp = 'N';
700iA     when      w1qrc2 > 0;
700iA       eval      uputyp = '1';
700iA     when      w1qrc3 > 0;
700iA       eval      uputyp = '2';
700iA   endsl;
700iA /end-free
700iDC*    upcky3        chain(n)  upc3                               79
700iMC     upcky3U       chain(n)  upc3                               79
     C                   if        *in79
     C                   eval      upwhse = $pwhse
     C                   eval      upitem = $pitem
     C                   eval      upupc = w1upc
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
700iA * load new upc fields
700iA /free
700iA   select;
700iA     when      w1qrc1 > 0;
700iA       eval      upuom = $itum1;
700iA       eval      uputyp = 'N';
700iA     when      w1qrc2 > 0;
700iA       eval      upuom = $itum2;
700iA       eval      uputyp = '1';
700iA     when      w1qrc3 > 0;
700iA       eval      upuom = $itum3;
700iA       eval      uputyp = '2';
700iA   endsl;
700iA   Select;
700iA     when ntype = 'UPC-12';
700iA       upctyp = '1';
700iA     when ntype = 'EAN-13';
700iA       upctyp = '2';
700iA     when ntype = 'GTIN';
700iA       upctyp = '3';
700iA     when ntype = 'SCC-14';
700iA       upctyp = '4';
700iA     when ntype = 'SSCC-18';
700iA       upctyp = '5';
700iA   endsl;
700iA /end-free
     *
     *   Add record
     *
     C                   write     uprec                                78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
     C                   endif
     c                   if        client = birite
CFIaAc                             or client = Colony
     c                   exsr      outlog
     c                   endif
     C                   endif
     *
     C                   eval      $rven = phven
     C                   eval      $rvnam = phvnam
     *
     *   Call receiving program, if this is a replenishment type
     *   of transfer.(Customer order# blank)
     *
     C                   if        w1exdt = 0
     C                   eval      $rexpd = 0
     C                   else
     C                   eval      $rexpd = expd
     C                   endif
     *
     C                   exsr      zzzcw
     *
     *   If not a FSWMS item, don't put away only update PODTL
     *
     C                   if        iaflag = *on
     C                   eval      $rpo = $ppo
     C                   eval      $rseq = $pseq
     C                   eval      $rslot = w1slot
     *
     C                   call      'RC161'
     C                   parm      '*RECEIVE'    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm      w1qrc1        $rqrc1            5 0
     C                   parm      w1qrc2        $rqrc2            5 0
     C                   parm      w1qrc3        $rqrc3            5 0
     C                   parm                    $rpo              9
     C                   parm                    $rven            11 0
     C                   parm                    $rvnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm                    $rexpd            8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $rslot           12
     C                   parm                    $rseq             5 0
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm                    w1twgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *R If error          PARM           $RMSG   4
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup3
     C                   endif
     C                   goto      jmpup3
     C                   endif
     *
     *   Enter qty per pallet and license.
     *
     C                   eval      $lrpal = 1
     C                   eval      $lflag = lflag
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lpo = $ppo
     C                   eval      $litem = $pitem
     C                   eval      $lrq1 = w1qrc1
     C                   eval      $lrq2 = w1qrc2
     C                   eval      $lrq3 = w1qrc3
     C                   eval      $lum1 = w1um1
     C                   eval      $lum2 = w1um2
     C                   eval      $lum3 = w1um3
     C                   eval      $lord = $rord
     C                   eval      $lseq = pdseq
     C                   eval      $lven = phven
     C                   eval      $lvnam = phvnam
     C                   eval      $lvitm = pdvitm
     C                   eval      $ldwgt = 0
     *    Lot tracking item - Pass single char flag to license entry pgm
     C                   if        lottrk = '*YES'
     C                   eval      $llott = 'Y'
     C                   else
     C                   eval      $llott = 'N'
     C                   endif
     *    Lic.tracking item - Pass single char flag to license entry pgm
     C                   if        lictrk = '*YES'
     C                   eval      $llict = 'Y'
     C                   else
     C                   eval      $llict = 'N'
     C                   endif
     *    Convert fifo date into yyyymmdd.
     C                   if        w1fifo = 0
WSTbA* if westside don't clear wofifo
WSTbAC                   if        client = westside and wofifo > 0
WSTbAc                   else
     C                   eval      wofifo = 0
WSTbAc                   endif
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fifo        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        wofifo
     C                   endif
     * Move mfg or expire or fifo date to keyed in date field
     * to send to PO236
     C                   eval      woindt = 0
     C                   select
     C                   when      w1fifo <> 0
     C                   eval      woindt = wofifo
     C                   when      w1mfdt <> 0
     C                   eval      woindt = womfdt
     C                   other
     C                   eval      woindt = woexdt
     C                   endsl
     c                   if        $pxd = 'XD'
     c                   eval      w1lcns = templcns
     c                   endif
DRYeDc*                  Select
DRYeDc*                  when      client = Dairyland
DRYeDc*                  if        expd <= today and
DRYeDc*                            odovr = *on
DRYeDC*                            or oeovr = *on
DRYeDc*                  eval      $QUstat = 'QU'
DRYeDc*                  else
DRYeDc*                  eval      $QUstat = '  '
DRYeDc*                  endif
DRYeDC*                  other
DRYcac                   eval      $QUstat = '  '
DRYeDc*                  endsl
     *
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
     C                   parm                    $rexpd
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    w1twgt
     C                   parm                    avgwt1
     C                   parm                    avgwt2
     C                   parm                    avgwt3
     C                   parm                    w1lotc
     C                   parm                    woindt
     C                   parm                    wofifo
     C                   parm                    w1upc
     c                   parm                    $ldecvalue
     C                   parm      mexpd         $lmfgex           8 0
     C                   parm      mfgdte        $lmfgdt           8 0
     C                   parm      $plpn         $llpn            50
     C                   parm                    w1lcns
     C                   parm                    w1brand
650aAC                   parm                    $parms1
650fAC                   parm                    $lsavetrn
650gAC                   parm                    $bcGtin
650gAc                   parm      $bcProdd      $pbcProdD
650gAc                   parm                    $bclot
650gAc                   parm                    $pw1pti
650uAc                   parm      $posscode     $losscode         1
     *
     C                   if        $lrtn = '*OK     '
     C                   eval      $prtn = $lrtn
     C                   eval      $pmsg = $lmsg
     c                   eval      $ldecvalue  = ' '
     c                   eval      $lmfgex = 0
     c                   eval      $lmfgdt = 0
     c                   eval      mexpd     = 0
     c                   eval      mfgdte   = 0
     c                   eval      w1brand  = ' '
650fAc                   eval      rcvpocomplete = *on
650tAc                   eval      moretoscan = *off
650tAc                   eval      firstuci = *off
700iAc                   if        $ifrcvmth <> '3' or $ittype <> ' '
650tAC                   eval      wolbl = *blanks
650tAC                   eval      woitem = *blanks
650tAC                   eval      wodsc1 = *blanks
650tAC                   eval      wodsc2 = *blanks
700iAc                   endif
650tAc                   eval      $puci = ' '
650tAc                   eval      w1uci = ' '
650tAc                   eval      w1lcns= ' '
650tAc                   eval      templcns = ' '
650tAc                   eval      saveqty  = 0
650tAc                   eval      svdwgt = 0
650tAc                   eval      savewgt= 0
     *  If no error was found then send message to calling program.
     C                   call      'MOVMSGP'
     C                   parm                    $pprg
     C                   endif
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
     C                   if        $lrtn = '*OK     '
     C                   if        w1mfdt <> 0  or
     C                             w1exdt <> 0
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = $pwhse
     C                   eval      pmpo = $ppo
     C                   eval      pmseq = $pseq
     C                   eval      pmitem = $pitem
     C                   eval      pmexpd = $rexpd
     C                   if        w1mfdt <> 0
     C                   move      w1mfdt        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pmmfgd = $cvd8o
     C                   else
     C                   eval      pmmfgd = 0
     C                   endif
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        *in78  = *off
     C                   update    pmrec
     C                   else
     C                   write     pmrec
     C                   endif
     *
     *      Write record to item exception file for date override.
     *
      * add additional exception if date decipher error
     c                   if        ddcode = *on
     C                   eval      exerid = 'DD-CODE'
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = $dto
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #curruser
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      ddcode = *off
     c                   endif
     C                   if        oaovr = *on  or
     C                             obovr = *on  or
     C                             ocovr = *on  or
     C                             odovr = *on  or
     C                             oeovr = *on  or
     C                             ofovr = *on
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
650cAC                   select
650cAC                   when      ocovr = *on
650cAC                   eval      dsexpd = ckexdt
650cAC                   other
     C                   eval      dsexpd = $dto
650cAC                   endsl
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
650 A*
650 AC                   if        lbqpck > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     lbqpck        exqty
650 AC                   endif
650 A*
     C                   eval      extask = 'RCV'
     C                   eval      exgby = #curruser
     C                   select
     C                   when      oaovr = *on
     C                   eval      exerid = 'OA-DOVR'
     C                   when      obovr = *on
     C                   eval      exerid = 'OB-DOVR'
     C                   when      ocovr = *on
     C                   eval      exerid = 'OC-DOVR'
     C                   when      odovr = *on
     C                   eval      exerid = 'OD-DOVR'
     C                   when      oeovr = *on
     C                   eval      exerid = 'OE-DOVR'
     C                   when      ofovr = *on
     C                   eval      exerid = 'OF-DOVR'
     C                   other
     C                   eval      exerid = 'EXPDOVR'
     C                   endsl
     C                   eval      exesta = '1 '
     C                   write     exrec
     C                   eval      oaovr = *off
     C                   eval      obovr = *off
     C                   eval      ocovr = *off
     C                   eval      odovr = *off
     C                   eval      oeovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
650kA* catch weight override exception
650kAC                   if        cwovr = *on
650kAC     lbkey         setll     label2
650kAC                   eval      stop = *off
650kAC                   dou       stop = *on
650kAC     lbkey         reade     label2                                 79
650kAC                   if        *in79
650kAC                   eval      stop = *on
650kAc                   leave
650kAC                   else
650kAC                   if        lbqpck > 999
650kAC                   eval      exqty = 999
650kAC                   else
650kAC                   z-add     lbqpck        exqty
650kAC                   endif
650kAC                   endif
650kA*
650kAC                   eval      exwhse = lbwhse
650kAC                   eval      exwhdp = lbwhdp
650kAC                   eval      exstyp = lbstyp
650kAC                   eval      exitem = lbitem
650kAC                   eval      dspo = lbpo
650kAC                   eval      dslbl = lblbl#
650kAC*                  eval      dsexpd = $dto
650kAC                   eval      dsexpd = 0
650kAC                   eval      exfdis = dsfdis
650kAC                   eval      extdis = dstdis
650kAC                   eval      exgdte = lbsdte
650kAC                   eval      exgtim = lbstim
650kA*
650kAC                   eval      extask = 'RCV'
650kAC                   eval      exgby = #user
650kAC                   select
650kAC                   when      cwovr = *on
650kAC                   eval      exerid = 'CW-OVR '
650kAC                   endsl
650kAC                   eval      exesta = '1 '
650kAC                   write     exrec
650kA * load new file pocwexcp
650kA /free
650qD   //chain ($pwhse: lblbl#) pocwexcp;
650qD   //cw_exwhse = $pwhse;
650qD   //cw_expo = $ppo;
650qD   //cw_exseq = $pseq;
650qD   //cw_exitem = $pitem;
650kA   cw_exwhse = lbwhse;
650kA   cw_expo = lbpo;
650kA   cw_exseq = lbseq;
650kA   cw_exitem = lbitem;
650kA   cw_extrn# = lbtrn#;
650kA   cw_exlbl# = lblbl#;
650kA   cw_exwgt = W1DWGT;
650rD   //cw_exrngl = erlrng;
650rD   //cw_exrngh = erhrng;
650kA   cw_exgdte = lbsdte;
650kA   cw_exgtim = lbstim;
650kA   cw_exrg1c = prg1c * 100;
650kA   cw_exrg2c = prg2c * 100;
650kA   cw_exswgt = exwgt;
650kA   select;
650kA     when $imrg1c > 0;
650kA       cw_exrg1w = 'I';
650kA     when oprg1c > 0;
650kA       cw_exrg1w = 'S';
650kA     other;
650kA       cw_exrg1w = 'P';
650kA   endsl;
650kA   select;
650kA     when $imrg2c > 0;
650kA       cw_exrg2w = 'I';
650kA     when oprg2c > 0;
650kA       cw_exrg2w = 'S';
650kA     other;
650kA       cw_exrg2w = 'P';
650kA   endsl;
650qD   //if %found(pocwexcp);
650qD     //update cwexrec;
650qD   //else;
650kA     write cwexrec;
650qD   //endif;
650kA /end-free
650kAC                   enddo
650kAC                   eval      cwovr = *off
650kA*
650kAC                   endif
     *
     *    Write records to POFIFO file.
     C                   if        $lrtn = '*OK     '  and
     C                             w1fifo <> 0
     C     lbkey         setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     lbkey         reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   move      w1fifo        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        wofifo
     C                   eval      pffifo = wofifo
     C                   eval      pflbl# = lblbl#
     C                   write     pfrec
     C                   endif
     C                   enddo
     C                   endif
     *
     *   Move key values to parameters
     *
     C     jmpup3        tag
     C                   eval      $pseq = pdseq
     C                   eval      $pitem = pditem
     *
     *   Move key values to parameters
     *
     C     endup3        endsr
     *
700iA*----------------------------------------------------------------
700iA*
700iA*  ZZUPD4   Write breakdown upc
700iA*
700iAC     zzupd4        begsr

700iA /free
700iA   // breakdown1
700iA   if writeb1 = *on;
700iA     upwhse = $pwhse;
700iA     upitem = $pitem;
700iA     upupc = b1upc;
700iA     upven = phven;
700iA     upvnam = phvnam;
700iA     upvitm = $itvit#;
700iA     upbran = $imbrnd;
700iA     upuom = w1buom1;
700iA     uputyp = '1';
700iA     Select;
700iA       when b1type = 'UPC-12';
700iA         upctyp = '1';
700iA       when b1type = 'EAN-13';
700iA         upctyp = '2';
700iA       when b1type = 'GTIN';
700iA         upctyp = '3';
700iA       when b1type = 'SCC-14';
700iA         upctyp = '4';
700iA       when b1type = 'SSCC-18';
700iA         upctyp = '5';
700iA     endsl;
700iA     write uprec;
700iA     if client = birite
CFIaA      or client = Colony;
700iA       exsr outlog;
700iA     endif;
700iA   endif;
700iA   // breakdown2
700iA   if writeb2 = *on;
700iA     upwhse = $pwhse;
700iA     upitem = $pitem;
700iA     upupc = b2upc;
700iA     upven = phven;
700iA     upvnam = phvnam;
700iA     upvitm = $itvit#;
700iA     upbran = $imbrnd;
700iA     upuom = w1buom2;
700iA     uputyp = '2';
700iA     Select;
700iA       when b2type = 'UPC-12';
700iA         upctyp = '1';
700iA       when b2type = 'EAN-13';
700iA         upctyp = '2';
700iA       when b2type = 'GTIN';
700iA         upctyp = '3';
700iA       when b2type = 'SCC-14';
700iA         upctyp = '4';
700iA       when b2type = 'SSCC-18';
700iA         upctyp = '5';
700iA     endsl;
700iA     write uprec;
700iA     if client = birite
CFIaA      or client = Colony;
700iA       exsr outlog;
700iA     endif;
700iA   endif;
700iA   $prtn = ' ';
700iA /end-free
700iAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDCnl Delete scanned records
     *
     C     zzupdCnl      begsr
     C                   eval      error = *off
     *   Remove any LICUCI records
      /free
        if moretoscan = *on;
          if *inkj;
            // Delete LICINFO Records
            exsr zzlicinfocan;

            exsr clr$uciinfo;

            // warehouse
            $uiWhse = $pwhse;

            // License
            if $pxd = ' ';
              $uiLcns = w1lcns;
            else;
              $uiLcns = templcns;
            endif;

            $dricommand = '*UCIINFO';
            $drisubcmd  = '%CANCEL';
            $drisys2upd = 'D';
            ck4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error;
            endif;
            moretoscan = *off;
            $puci = ' ';
            w1uci = ' ';
            w1lcns = ' ';
            templcns = ' ';
            ovrrid = *off;
            $pexpdt = 0;
            $pwgt = 0;
            $pmfgdt = 0;
            $plot = ' ';
650lA       saveqty = 0;
650tA       svdwgt = 0;
650tA       savewgt= 0;
          endif;
        endif;

      /end-free
     *
     *   Move key values to parameters
     *
     C     endupCnl      endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     C                   eval      wkwhse = $pwhse
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
700eA*    We will set the default for lbs/kgs from the option file
700eA /free
700eA   // save the field for later use, the opdata field gets changed
700eA   svopwum = opwum;
700eA   select;
700eA     when opwum = 'KGS'
700eA      or opwum = 'kgs'
700eA      or opwum = 'Kgs';
700eA       KiloLbs = 'K';
700eA       W1KgLb  = opwum;
700eA     other;
700eA       KiloLbs = 'P';
700eA       W1KgLb  = 'Lbs';
700eA   endsl;
700eA /end-free
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCW    Calculate catch weight
     *
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W1AVG  POCTYP  Action
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
650wA*     Y       3  GS1 Catchweights     -    CW = Calc1
650wA*                $ifrcvmth = '2'
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
     C     zzzcw         begsr
     *
     C                   eval      w1twgt = 0
     C                   eval      avgwt1 = 0
     C                   eval      avgwt2 = 0
     C                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
650oMC     keypoc        chain(n)  poctype                            79
650oDC**   keypoc        chain     poctype                            79
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
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
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
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
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
650wAC                   when      vrfycw = *on  and
650wAC                             w1dwgt > 0    and
650wAc                             $ifrcvmth = '2'
650wAC                   eval      cwcalc = 1
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
     C                   eval      w1twgt = cnvwgt
     C                   select
     C                   when      w1qrc1 > 0
     C     cnvwgt        div       w1qrc1        avgwt1
     C                   when      w1qrc2 > 0
     C     cnvwgt        div       w1qrc2        avgwt1
     C                   when      w1qrc3 > 0
     C     cnvwgt        div       w1qrc3        avgwt1
     C                   endsl
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
     C                   select
     C                   when      w1qrc1 > 0
     C     cnvwgt        mult      w1qrc1        w1twgt
     C                   when      w1qrc2 > 0
     C     cnvwgt        mult      w1qrc2        w1twgt
     C                   when      w1qrc3 > 0
     C     cnvwgt        mult      w1qrc3        w1twgt
     C                   endsl
     C                   z-add     cnvwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt3
     C                   endif
     *
     *       Brk2 qty for non-SSB items.
     *
     C                   if        w1qrc3 > 0  and
     C                             #otype <> 'S'
     C     #oswt3        mult      w1qrc3        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt3 = #oswt3
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
     C                   eval      pocwhs = $pwhse
     C                   eval      pocpo = $ppo
     C                   eval      pocseq = $pseq
     C                   eval      poctyp = wrttyp
     C                   write     pocrec                               78
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
* * INVALID ITEM * *
F7 only for c/w's
Tie/Hi Qty on Pallet
UCI Barcode
Scan/Enter License
Different Item
Different GTIN/UPC
License
Scan UCI Barcode
**
Item (
Base (
SSB (
Item  . . . .
**
(Type ' ')
**
Catch weight (Ttl or Avg) .
Catch weight (Total)  . . .
Catch weight (Average)  . .
**  CMDLN - Command display line
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code  F21=Off Site
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code  F21=Off Site
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry  F21=Off Site
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry  F21=Off Site
F8=Tie/Hi  F11=Mfr Code
F8=Tie/Hi
F3=Exit  F5=Refresh  F12=Cancel  F20=Accept warning
F3=Exit F5=Refresh F12=Cancel F20=Accept warning  F22=Complete License
F12=Cancel
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry  F11=Mfr Code
F7=Kilograms  F8=Tie/Hi  F9=Cwgt Entry
F7=Pounds  F8=Tie/Hi  F9=Cwgt Entry
F9=Skip
