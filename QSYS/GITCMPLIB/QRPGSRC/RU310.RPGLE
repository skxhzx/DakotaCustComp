510dA /copy qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp('RU310')
510dDH*copyright('(c) Copyright BFC Software, Inc - 2004')
510dD7*option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Associates - All Rights Reserved
     *   BFC Associates
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU310     RF - Clear Runner Flags
     *  06 June 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *      16 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    06/02/04  MLB  4.17
     *      - Created.
     *
500 A*    03/29/05  MLB  5.00
     *      - Enh: Added Client custom code support to program.
500b *    05/10/05  HNK/MLB 5.00b
     *      - Changed to update LBVRFY with a "T" instead of " ".
500cA*    07/11/05  MLB  5.00c
     *      - Enh: Revised program to handle new fields added to
     *        RUNNER file.
     *      - Revised program to allow flag to be cleared even if
     *        LABEL record is Closed. LBVRFY will not be updated
     *        if record is Closed.
500eA*    12/08/05  JCJ  5.00e
     *      - Enh: Revised program to handle new fields added to
     *        RUNNER file.
500fA*    02/27/06  JCJ  5.00f
     *      - Enh: Revised program to allow other unit of measure
     *        qty's to be entered for shorted items that are smaller
     *        than ordered qty.
500gA*    03/18/06  MLB  5.00g
     *      - Enh: Revised program to only call RU312 when item
     *        being processed is a catchweight item. ITCWGT=Y.
500hA*    04/08/06  JCJ  5.00h
     *      - Enh: Revised program to add 4 new screens.
500iA*    04/25/06  MLB  5.00i
     *      - Fix: Correction to above mod. Revised program to not
     *        display Expiration, Box # capture screen unless a
     *        positive quantity was found by the runner.
500jA*    04/28/06  MLB  5.00j
     *      - Fix: Correction to 5.00e mod. Revised program to net
     *        out quantity shorted minus quantity found when updating
     *        Label record at Flag Clear time and Label record isn't
     *        updated at Selection time.
500kA*    05/16/06  JCJ  5.00k
     *      - Enh: Revised program to retrieve system value for catch
     *        weight variance.
500lA*    06/02/06  MLB  5.00l
     *      - Fix: Created new KLIST for file ORDBOX. Need to use
     *        full key to access file.
     *      - Fix: Revised program to not lock record on chain to
     *        file EXPDTE when determining to prompt for exp. date.
     *
510 A*    07/01/06  MLB  5.10
     *      - Fix: Revised program to convert W3QYSO to character
     *        from numeric. This is being done to more easily test
     *        for a blank or no entry. Users were pressing Enter
     *        without entering a value causing the flag to be cleared
     *        in error.
     *      - Changed description for desc(12) entry. Previous desc.
     *        no longer appropriate.
     *      - Requires pgm to be compiled to V5R2 level.
510aA*    12/16/05  MLB  5.10a (was 5.00d, part was missed.)
     *      - Enh: Revised ZZUPD3 to set LBVRFY='T' when not all
     *        short qty was found for Merge records.
510bA*    08/10/06  JCJ  5.10b
     *      - Fix: Changed logic to allow expiration date prompt
     *        to occur if the criteria is met.
510cA*    08/22/06  MLB  5.10c
     *      - Enh: Revised program to allow user to enter as many box
     *        numbers as needed. User will use F3/F12 to exit box
     *        entry screen instead of Enter on Screen 5.
     *      - This mod will remove the check to see if any boxes have
     *        been entered previously. The only test that will be made
     *        will be if the Box Flag=Y and qty shorted was > 0.
510dA*    05/24/07  DAS  5.10d
     *      - Enh: Added DRI logic to get item available qty.
     *      - Enh: Revised to display warning if user enters a zero
     *        quantity and Dakota shows available qty.
     *      - Enh: Revised to added record to ITMEXCP when override
     *        is taken.
520 A*    01/23/09  RBD  5.20
     *      - Enh: Added label# to screen1 and screen61.  New *runner
     *        option oprscn dictates whether tran# or label# will
     *        be scanned.
     *      - Added F8=Load function to screen1 and screen61, enabled
     *        if new *runner option oprloa = Y.
     *      - Added entry field to screen2 and screen62 for scanning
     *        pick slot if new *runner option oprvfs = Y.
     *      - Added screens screen6 and screen66 to ask for confirmation
     *        of qty found if new *runner option oprvfq = Y.
     *      - Added logic to print a runner label if 'Qty found' is
     *        accepted and > 0, AND the user has a belt printer
     *        checked out.
520aA*    08/28/09  RBD  5.20a
     *      - Fix: After processing screen6, go back to screen2
     *        for more transactions, rather than screen1.
520bA*    09/16/09  RBD  5.20b
     *      - Fix: sv_w2lbl# eliminated, send w2lbl# to PFMT instead.
520cA*    10/05/09  RBD  5.20c
     *      - Fix: send lblbl# to PFMT instead of w2lbl#.
     *
530a *    05/14/10  GJA  5.30a
     *      - Enh: increase label entry to 10 positions
     *
530b *    07/12/10  GJA  5.30b
     *      - Fix: Replace movel with eval to make sure field is left
     *
610a *    04/27/10  GJA  6.10a     P#00243
     *      - Enh: change UCI to be option driven.  OPUCI
     *
610b *    05/11/10  GJA  6.10b     P#00243
     *      - Fix: change UCI option position.
640aA*    08/30/11  RH   640a
     *      - Renamed format to RU31002 to merge EIb change.
     *
640b *    12/12/11  GJA  640b
     *      - Fix: when breakdown is allowed it was not correctly
     *             showing UOM
     *
640cA*    10/26/12  RBD  640c
     *      - Added calls to GETITEMSUB and RH182 for item substitute
     *        processing if no quantity found.
     *
640dA*    11/30/12  RBD  640d
     *      - Fix: Check Runner status before calling PT132PL and
     *        throw error if status = C ... before this fix multiple
     *        users could close the same Runner which could cause
     *        the qty picked to go negative.
     *
640eA*    01/07/13  RBD  640e
     *      - Fix: Added *SHORTM command to send to PFMT if rutype=U,
     *        otherwise still send *SHORT. If rutype=U that means
     *        multiple runners have picked shorts for this item,
     *        otherwise there will only be 1 runner record.  In PFMT
     *        we need to know that so we can determine what the next
     *        Trax#s on the runner pick labels should be. Before this
     *        fix to RU310, RU355, and PFMT, we were reprinting Trax#s
     *        on runner pick labels that had already been used because
     *        we were starting at the beginning, rather than where we
     *        left off.
     *
650aA*    05/15/13  RBD  650a
     *      - Enh: If no sub is returned from GETITEMSUB, do not call
     *        sub pgm RH182.
     *
650b *    07/16/14  GJA  6.50b
     *      - Enh: Add UCI selection to runner flag process.
650c *    09/11/14  LMC  6.50c
     *      - Fix: If no UCI's are found need to default 0 to
     *        w3qyfd field instead of blank.
700a *    07/10/16  DAS  7.00a
     *      - Change format to RU31004.
     *      - Added F6=Sub to Screen3.
     *      - F6 is not handled in zzcmd3. Instead, performs like the
     *        Enter key was pressed.
     *      - ZZCHK3 has been revised to for qty to be zero for F6.
     *      - ZZUPD3 has been revised to go into sub program when
     *        when F6 is pressed and there is no defined sub.
700b *    07/12/16  DAS  7.00b
     *      - Revised F6 on SC3 to override the qty in stock warning
     *        and proceed to the sub screen.
     *      - Revised ZZCMD3 to set on ovrrid when F6 is pressed and
     *        zeroovr is on. zeroovr is set on when the F10=Override
     *        is displayed.
710a *    06/28/17  TAB  7.10a
     *      - Add mod to process Box Breaker runner transaction
710b *    06/30/17  TAB  7.10b
     *      - Add mod to run UPC UOM check through VOSELECT
710c *    07/06/17  TAB  7.10c
     *      - Fix: New screen fomat for error message overlap
710d *    07/07/17  LMC  7.10d
     *      - Fix: When runner is completed we need to remove the
     *        runner transaction number from the uciinfo return tran#
     *        runnerdone subr existed in the program but was never
     *        being executed.
710e *    09/12/17  RBD  7.10e
     *      - Merged differences from PIRCBI700/RU310B into this pgm.
     *        RU310B was created by Jose for Cheney in 2006 as a modified
     *        version of RU310. Numerous revs have been added to RU310
     *        over the years, very few of which were added to RU310B.
     *        We are now merging RU310B into RU310 so we can discontinue
     *        RU310B and only have 1 program to maintain going forward.
     *        Note, some of the RU310B code added will be standard
     *        code, rev 710e, and some will be specific to Cheney.
     *      - Fix: If no runner trans# found on the first pass look
     *        for a 'U' type and use its runner trans#.
     *
710f *    12/18/17  RBD  7.10f
     *      - Reversed a portion of rev 700a, "ZZCHK3 has been revised
     *        for qty to be zero for F6".  A user will now be allowed to
     *        enter a partial qty found AND a sub item. They must key the
     *        qty found and then press F6=Sub rather than the Enter key.
720a *    04/20/18  RBD  7.20a
     *      - Added new runner status 'S' (Staged) currently only used
     *        by Cheney. If flag type N or M is cleared with quantity
     *        found the status will be changed to S rather than C.
     *        Status S will be updated to C when either the route is
     *        closed to the Loader Mod or the flag is cleared again
     *        here in RU310.  Runner file NOT recompiled.
     *
720b *    05/15/18  RBD  7.20b
     *      - Per Tam, increment w2nrsn if status 'U' as well as 'P'.
720c *    08/30/18  RBD  7.20c
     *      - Fix: only call subr loadr11 if client uses Loader Module.
720dA*    10/14/18  MLB  7.20d
     *      - Fix: Revised routine ZZCHK1 to not lock PIRTRAN when vali-
     *        dating that tran# keyed is RUNNER transaction.
     *
720e *    08/17/18  RBD  7.20e
     *      - Additional logic added to zzchk1 710e rev, if runner trans#
     *        is > 0 and qty found is less than qty short continue looking
     *        for additional runner records for the label scanned as
     *        there may be a 'U' type runner for the label. This happens
     *        when a partial qty is found for a label, leaving another
     *        runner flag for the remaining qty.
     *
720fA*    08/24/18  DAS  7.20f
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
720gA*    08/12/16  LMC  7.20g
     *      - Enh: UCI Tracking.
     *
720h *    05/23/18  RBD  7.20h
     *      - In zzinz2 check to see if $itrn or $ilab was passed in and
     *        if so it indicates that this pgm was called from LOADR10
     *        so we can skip showing RU310.01 since we already have trans
     *        or label. Added incoming parm for label number since user
     *        may enter trans OR label in LOADR10. Added return parm
     *        for error message in case this program errors out.
     *
730aA*    01/24/19  DAS  7.30a
     *      - Added call to PRTORDAUD after returning from Runnerdone.
     *        This will check to see if a order Audit report should
     *        be printed.
730bA*    06/28/19  LMC  7.30b
     *      - Don't allow more UCI's to be scanned that qty short.
730cA*    11/27/19  DAS  7.30c
     *      - Revised to have user scan base slot on screen 2.
     *
750aA*    08/17/21  RBD  7.50a
     *      - Added new runner option opscnl, Scan short to loader
     *        required before clearing runner flag.  If opscnl = Y
     *        and qty is found but short has not been loaded, set
     *        runner status to 'L' rather than 'C'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
EI  A*    06/01/06  MLB  EI
     *      - Revised program to allow box number to be entered if
     *        item doesn't already have one assigned.
EIa A*    08/22/06  MLB  EIa
     *      - EI mod above no longer required. Support provided by
     *        5.10c above.
EIb A*    07/30/10  RBD  EIb
     *      - Changed scrn format to RU31001.
     *      - Added screens SCREEN20 and SCREEN620 for entering emp#
     *        of runner.
EIc  *    11/23/11  GJA  EIc
     *      - EIb was only updating the employee#, needs to update
     *        crew and shift also.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI AA*    10/31/06  CBI-JGD
     A*      - Logic added to display a pop-up screen for
     A*        the flag loader to verify that the clear
     A*        flag operation ends up loading the flagged
     A*        item on the right Pallet/Trailer.
     A*
     A*        NOTE: When the flag runner is clearing the
     A*              flag and the qty found is > zero, a
     A*              pop-up screen will display showing
     A*              Pallet Id and Trailer # fields which
     A*              are used by the flag runner to scan in
     A*              either the Pallet Id (from pallet label)
     A*              or Trailer # (from inside trailer) as a
     A*              verification process to assure the item
     A*              was loaded on the proper Pallet/Trailer.
     A*              Flag clearing will not take place if the
     A*              information scanned in is wrong.
     *
CBIaA*    06/29/07  DAS  CBIa
     *      - Revised to call RU312 only for generation 1 'O' and 'M'
     *        records.
     *       - Revised to not set on cwgt flag for Meat/Insp items.
CBIbA*    11/11/15  MLB  CBIb
     *      - Enh: Revised pgm to not clear LBVRFY when = I and qty
     *        found was not 100%. Per Keith S.
      *
CBIbAA*    08/09/07  CBI-JGD
      *      - Logic added skips loading system po up screen
      *        when the route being processed is an export route.
      *        NOTE: This mod was applied to Riviera only since
      *              Ocala does not do EXPORT.
     *
CBIcA*    10/20/15  JCJ  CBIc
     *      - Revised to exit program when there is no more runners
     *        instead of returning to screen1.
     *
CBIeA*    07/26/17  RBD  CBIe
     *      - Fix: If user entered a qty found with leading space(s)
     *        the condition w3qyfd > 0 would fail and LOADR11 would
     *        not get called.  Changed logic to call LOADR11 if qty
     *        found <> blanks and <> zero.
     *
CBIfA*    09/12/17  RBD  CBIf
     *      - Added CBI logic from RU310B to call LOADR11.
     *
CBIgA*    01/02/18  RBD  CBIg
     *      - Revised to exit program when w2nrsn is zero instead of
     *        returning to screen2.
     *
CBIhA*    01/24/19  RBD  CBIh
     *      - Reverse 720c, applies to Cheney only.
     *
CBIiA*    07/23/19  RBD  CBIi
     *      - Change rev 720a to be Cheney only.  City Line was just
     *        upgraded and we discovered the status S logic doesn't
     *        work there.  In hindsight probably should have made it
     *        Cheney specific to start with.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
     *
PAK A*    08/08/07  JCJ  PAK    (removed 6.10a)
     *      - When client = packers use catch weight pgm CE120 instead
     *        of RU312.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLD A*    09/23/09  RBD  CLD   P#00221
     *      - Force belt printer user to have a belt printer checked
     *        out.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    08/17/13  MLB  GFS
     *      - Disable warning to user that Runner Flag being closed with
     *        zero qty has available qty in the whse. Per emaiil from
     *        Patrick Jens and approved by Nick P.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    01/15/16  MLB  CWD
     *      - Revised pgm to override 6.50a mod that was added to only
     *        call RH182 when $isub was > blanks. per Dustin H. email
     *        dated 01/15/2016.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    01/08/15  MLB  HMW  *** Temporary Mod Only ***
     *      - Disable call to pgm to check for item substitutions. Inter-
     *        face back to Canopy is not ready to accept subs. Per VM
     *        from Hemant on 01/08/15.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSTaA*    10/04/19  LMC  WSTa
     *      - Westside doesn't really do a runner process, they have
     *        requested we don't ask for UCI to be scanned because
     *        the user only has the weights, no actual boxes to scan.
     *        We did explain to them they no longer have proof of
     *        which boxes were sent to the customer if there is an
     *        issue on billed weights.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  92 - 93   VIEW MODE (PROTECT INPUT FIELDS)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530aDF*****ru310fm   cf   e             workstn
640aDF*u31001   cf   e             workstn
650bDF*ru31002   cf   e             workstn
700aDF*u31003   cf   e             workstn
710cDF*ru31004   cf   e             workstn
710cMFru31005   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
500fDF*Label     uf   e           k disk
500fMFLabel     uf a e           k disk
     Foptions   if   e           k disk
520 AFoptionz   if   e           k disk
     Fpiritem   if   e           k disk
EIb DF*irtran   if   e           k disk
EIb MFpirtran   uf   e           k disk
     Fpiruser1  if   e           k disk
520 AFpltsum4   if   e           k disk
520 AFrtehed    if   e           k disk
500cDF*runner    uf   e           k disk
500cMFrunner    uf a e           k disk
     Frunner3   if   e           k disk
     F                                     rename(rurec:rurec3)
520 AFrunner6   if   e           k disk
520 AF                                     rename(rurec:rurec6)
500fAFitemmsc   if   e           k disk
500hAForddm     if   e           k disk
500hAFordbox    uf a e           k disk
500hAFordexpdte uf a e           k disk
640cAFordh      if   e           k disk
650bAFORDC      UF A E           K DISK
510dAFitmexcp   o    e           k disk
750aAFldrovrf2  if   e           k disk
     F
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*
500 AD @getcl          c                   const('GETCLIENT')
500 A*
500 A /COPY QCOPYSRC,ID#CHENEY
EI  A /COPY QCOPYSRC,ID#EI
PAK A /copy qcopysrc,id#packers
CLD A /copy qcopysrc,id#citylin
GFS A /copy qcopysrc,id#gfs
CWD A /copy qcopysrc,id#cashwa
HMW A /copy qcopysrc,id#hmwagne
WSTaA /copy qcopysrc,id#westsid

650bA*----------------------------------------------------------------
650bA* Function prototypes.
650bA*----------------------------------------------------------------
650bA
650bA /copy qcopysrc,p.cw800
500cA /copy qcopysrc,p.bfcdteti
510dA*----------------------------------------------------------------
510dA*  DRI parameters
510dA*----------------------------------------------------------------

510dA /COPY *libl/qcopysrc,C#DRIPARMS

510dA*----------------------------------------------------------------
510dA*  Data Formats
510dA*----------------------------------------------------------------

650bA /COPY *libl/qcopysrc,C#UCIINFO
650bA /COPY *libl/qcopysrc,C#CVTPARMS
650bA /COPY *libl/qcopysrc,C#BARCODE
650bA /COPY *libl/qcopysrc,C#CWLOG
650bA /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#Itemqty
710bA /Copy qcopysrc,p.getimuom
730cA /COPY *libl/qcopysrc,C#SLOT
     D save$itemqty    s                   like($itemqty)

520 A /COPY *libl/qcopysrc,C#EQUIPT
520 AD saveVer#        s                   like($etver#)

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optendp              117    117

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
510 DD*desc            s             50    dim(15) ctdata perrcd(1)
510dDD*desc            s             50    dim(16) ctdata perrcd(1)
520 DD*desc            s             50    dim(17) ctdata perrcd(1)
CLD DD*desc            s             50    dim(20) ctdata perrcd(1)
EIb DD*desc            s             50    dim(21) ctdata perrcd(1)
EIb MD desc            s             50    dim(22) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
510dAD                 ds
510dAD  dsrtrn#                1      7  0
510dAD  dsptrn#                8     14  0
510dAD  dsplbl#               15     21  0
510dAD  dsfdis                 1     12
510dAD  dstdis                13     24
     *----------------------------------------------------------------
     *  *GENPICK -  General picking.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N).
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *
     *
     * Data structure
     *
     D opdta1          DS
     D  OPERPT                 1      1
     D  OPELBL                 2      2
     D  OPRFWC                 3      3
     D  OPNRSC                 4      4  0
     D  OPHPWC                 5      5
     D  OPMRGA                 6      6
     D  OPPLSQ                 7      7
     D  OPEADJ                 8      8
     D  OPNOPK                 9      9
500eA***OPCLRF                10     10
500eAD  OPCLRF2               10     10
     D  OPTEND               117    117
500eA*----------------------------------------------------------------
500eA*  *RUNNER  -  PIR Runner Flag Options
500eA*----------------------------------------------------------------
500eA*
500eA* Fields
500eA*
500eA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
500eA*    OPUPLR  -  Update Label with quantity shorted during manual
500eA*               flag entry (Y/N)
500eA*               NOTE: Any change to this field will cause OPUPLV
500eA*                     in the *VOICE options record to be updated.
500eA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
500eA*               & create Priority Replenishment if necessary.
500eA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
500eA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
500eA*    OPRNRM  -  Send break message to user when new Runner
500eA*               task has been assigned. (Y/N)
500eA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
500eA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500fA*    OPRPCK  -  Print Runner pick list. (Y/N)
500fA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
500fA*               printer, 2=Belt printer
500fA*    OPRBDU  -  Allow shorts to be filled with breakdown units. (Y/N)
520 A*    OPRSCN  -  Scan tran# or label# to start pick.
520 A*                 1=tran#, 2=label#.
520 A*    OPRVFS  -  Verify pick slot, Y/N.
520 A*    OPRVFQ  -  Verify qty found, Y/N.
520 A*    OPRLOA  -  Using loader module, Y/N.
750aA*    OPSCNL  -  Scan short to loader required before
750aA*               clearing runner flag, Y/N.
500eA*
500eA* Data structure
500eA*
500eAD oprdta          ds
500eAD  opcrtm                 1      1
500eAD  opuplr                 2      2
500eAD  oprplf                 3      3
500eAD  opmrgf                 4      4
500eAD  opclrf                 5      5
500eAD  oprnrm                 6      6
500eAD  opclsf                 7      7
500eAD  opoutf                 8      8
500fAD  oprpck                 9      9
500fAD  oprlbl                10     10
500fAD  oprbdu                11     11
520 AD  oprscn                12     12
520 AD  oprvfs                13     13
520 AD  oprvfq                14     14
520 AD  oprloa                15     15
750aAD  opscnl                16     16
500eAD  optendr              117    117
500hA
500kA*----------------------------------------------------------------
500kA*  *SYSTEM  -  System options.
500kA*----------------------------------------------------------------
500kA*
500kA* Fields
500kA*
500kA*    OPEPM   -  Using EPM module (Y,N).
500kA*    OPRF    -  Using RF module (Y,N).
500kA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
500kA*    OPLETD  -  Print letdown labels (Y,N).
500kA*    OPWRNC  -  Perform catch weight variance check (Y,N).
500kA*    OPRG1C  -  Catch weight low variance percentage.
500kA*    OPRG2C  -  Catch weight high variance percentage.
500kA*    OPIMPI  -  Import item fields from host.(Y,N).
500kA*    OPICW   -  Individual catch weight entry (Y,N).
500kA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
500kA*    OPRCDY  -  Number of days to keep receiving logs.
500kA*    OPMPCK  -  Number of days to keep picking logs.
500kA*    OPRTHS  -  Number of weeks - exported routes to keep.
500kA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
500kA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
500kA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
500kA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
610a *    OPUCI   -  Use UCI processing (Y,N)
500kA*
500kA* Data structure
500kA*
500kAD opdta2          ds
500kAD  opepm                  1      1
500kAD  oprf                   2      2
500kAD  opcapc                 3      3
500kAD  opletd                 4      4
500kAD  opwrnc                 5      5
500kAD  oprg1c                 6      8  1
500kAD  oprg2c                 9     11  1
500kAD  opimpi                12     12
500kAD  opicw                 13     13
500kAD  opmpck                14     14
500kAD  oprcdy                15     15  0
500kAD  oppkdy                16     16  0
500kAD  oprths                17     19  0
500kAD  opcrhs                20     22  0
500kAD  oppohs                23     25  0
500kAD  opiahs                26     28  0
500kAD  opmshs                29     31  0
610bDD**opuci                 33     33
610bMD  opuci                 36     36
500kAD  optendj              117    117

500hAD Today                           d   Datfmt(*ISO) Inz
500hAD  TodayYear                     4    overlay(Today)
500hAD  TodayMonth                    2    overlay(Today:6)
500hAD  TodayDay                      2    overlay(Today:9)
     *----------------------------------------------------------------
     *  Working variables
     *
640cAD $cmd            s             10
640cAD $isub           s             15
720hAD $imsg           s             50
720hAD $ilab           s             10
720hAD $plab           s             10
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
650bAD ck4err          s              1
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
650bAD  CWcmd          s             10
650bAD  CWpgm          s             10
650bAD  CWrtn          s             10
650bAD  CWmsg          s             60
650bAD  CWdata         s            512
     D DONE            s              1
     D E               s              2  0
     D ENTER           s              5  0
     D ERROR           s              1
     D EXCPTN          s              1
650bAD fnc1Hex1D       C                   x'1D'
     D FOREVR          s              1
720fAD gGen            s              1  0
720fAD gGenTruck       s               n
720fAD gGenMerge       s               n
720fAD gGenOverflow    s               n
720fAD gGenTruckExt    s               n
720fAD gPltId          s                   like(lbpal#)
     D HELP            s              5  0
500dAD lblclosed       s              1      inz('N')
     D MORE            s              1
     D MSGK            s              4  0
650bAD Newseq          s              3  0
710eAD noParmsPassed   s               n
     D NXTSCR          s              3
510 AD pos             s              5  0   inz(0)
510 AD pos1            s              5  0   inz(0)
510 AD pos2            s              5  0   inz(0)
650bAD processstatus   s             10
     D qtychg          s              7  0
     D REDSPL          s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
650bAD space           c                   ' '
650bAD ucicwt          s              7  2
     D WARN            s              1
510dAD ovrrid          s              1
510dAD zeroovr         s              1
510dAD availflg        s              1
510 AD Nbrqyfd         s                   like(ruqyso)
510 AD Nbrqyf1         s                   like(ruqyso)
510 AD Nbrqyf2         s                   like(ruqyso)
520 AD NbrqyfPFMT      s                   like(ruqyso)
     D Forever         s              1    inz('1')
     D Nomore          s              1    inz('0')
     D Skip2           s              1    inz('1')
500eAD svwhse          s              3  0
510 AD valid           c                   const('0123456789 ')
500eAD $pcmd           s              8
500eAD $plbl#          s              7  0
500eAD $pqty           s              5  0
500fAD @pqty1          s              5  0
500fAD @pqty2          s              5  0
500fAD @pqty3          s              5  0
500fAD @pgrp1          s              1
500fAD @pgrp2          s              1
500fAD pqty3           s              5  0
500fAD @paisl          s              5  0
500fAD @pcmd           s             10
500fAD @pcube          s              9  3
500fAD @pdate          s              8  0
500fAD @pmsg           s              4
500fAD @ppcs           s              5  0
500fAD @ppo            s              9
500fAD @pprg           s             10
500fAD @prte           s              5
500fAD @prtn           s              8
500fAD @pstyp          s              1
500fAD @pswgt          s              9  2
500fAD @ptask          s              6
500fAD @ptime          s              6  0
500fAD @ptrn#          s              7  0
500fAD @ptype          s              8
500fAD @puser          s             10
500fAD @pwhdp          s              5
500fAD @pwhse          s              3  0
500fAD $pwcwgt         s              7  2
500hAD MDY             s               d   DatFmt(*MDY)
500hAD ISO             s               d   DatFmt(*ISO)
500kAD prg1c           s              4  3
500kAD prg2c           s              4  3
520 AD sv_ruotrn       s              7  0
520 AD sv_w2lbl#       s              7  0
510dAD today8          s              8  0
530aAD w1lab#          s              7  0
530aAD w2lbl#          s              7  0
EIc AD w20shft         s              6
EIc AD w20crew         s              6
650bAD zmflag          s               n
650bAD zmsflag         s               n
710bAD $pdqlib         s             10
710bAD $pdqnameout     s             10
710bAD $pdqkey         s             36
710bAD $pcominfo       s             25
710bAD $pheader        s            512
710bAD $pfields        s           2048
710bAD $prtnfields     s           2048
710bAD w2lbl           s              7  0
710bAD curtime         s               z
730aAd outRtnCode      s             10
730aAd outRtnMsg       s            100
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @viewpgm        c                   const('IT231')
500fAD @adjt2          c                   const('ADJTRAN2')
500fAD @catchwgt       c                   const('RU312')
PAK AD @catchwgt2      c                   const('CE120')
530aAD @cvtbarsel      c                   const('CVTBARSEL')
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     D  $litem                22     36
     D  $lalwc                65     65
     *
     D  $ltrn#                19     25  0
500fA*
500fAD  $plbl                 22     28  0
500fAD  $pqyfd                29     33  0
500fAD  $phcwgt               34     40  2
500fAD  $plcwgt               41     47  2
500fAD  $perror               48     48
     *
CBI A*  Pop-Up screen parms.
CBI A*
CBI A*
CBI AD $parm           ds
CBI AD  $pwhs#                 1      3  0
CBI AD  $prte#                 4      8
CBI AD  $pltid                 9     15  0
CBI AD  $labl#                16     22  0
     *
640cAD $sparm          ds
640cAD  $scmd                  1      8
640cAD  $sprg                  9     18
640cAD  $suky                 19     68
640cAD  $srtn                 69     76
640cAD  $serm                 77    136
640cAD  $smsg                 77     80
640cA*
640cA*   Redefine key
640cA*
640cAD  $swhse                19     21  0
640cAD  $srte                 22     26
640cAD  $scord                27     33  0
640cAD  $sord                 34     40  0
640cAD  $sseq                 41     45  0
640cAD  $sitem                46     60
     *
710eAD $itrn           s              7  0
710eAD $ptrn           s              7  0
     *
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
     D currstamp       s               z
500cAD dftstamp        s               z
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
710bAD #msgfc          c                   const('QCPFMSG   ')
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
     *----------------------------------------------------------------
     *  Talkman record formats
     *----------------------------------------------------------------
710bA /Copy qcopysrc,r#header

710bA /Copy qcopysrc,rislvfyupu

710bA /Copy qcopysrc,roslvfyupu

730aA*----------------------------------------------------------------
730aA*  Called program prototypes
730aA*----------------------------------------------------------------
730aA
730aAD/copy qcopysrc,p.prtordau

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
710eM*      Transaction
720hA*      Label number
     *
     *    Returned Parameters
720hA*      Error message
     *
     *----------------------------------------------------------------

710eAC     *entry        plist
710eAC                   parm                    $itrn
720hAC                   parm                    $ilab
720hAC                   parm                    $imsg

710eA /free

710eA    noParmsPassed = *on;

710eA    if %parms >= 1;
710eA      $ptrn = $itrn;
720hA      $plab = $ilab;
710eA      noParmsPassed = *off;
710eA    else;
710eA      $ptrn = 0;
720hA      $plab = *blanks;
710eA    endif;

710eA /end-free

     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      zzinz2
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
CLD AC                   if        client = cityline
CLD AC                   exsr      ForceBeltPrt
CLD AC                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
500hAC     nxtscr        caseq     '04 '         sc4
500hAC     nxtscr        caseq     '05 '         sc5
520 AC     nxtscr        caseq     '06 '         sc6
650bAC     nxtscr        caseq     '07 '         sc7
650bAC     nxtscr        caseq     '08 '         sc8
EIb AC     nxtscr        caseq     '20 '         sc20
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   Eval      *inlr = *on

720hA /free

720hA    if %parms >= 1;
720hA      $imsg = errmsg;
720hA    endif;

720hA /end-free

     *
650bA*----------------------------------------------------------------
650bA*  clrCWLog     Clear $cwlog   data structure fields
650bA*----------------------------------------------------------------

650bA /free
650bA   begsr ClrCWLog;

650bA     savever# = $cwver#;
650bA     clear $cwlog;
650bA     $cwver# = savever#;
650bA     $cwaddemp = #emp#;
650bA     $cwaddusr = #user;
650bA     $cwaddpgm  = #prog;
650bA     $cwaddjob  = #job;
650bA     $cwaddnbr = #jobn;
650bA
650bA   endsr;
650bA /end-free

     *----------------------------------------------------------------
520 A*  clr$equipt  Clear $equipt data structure fields
     *
520 AC     clr$equipt    begsr
 |   C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  clr$item  Clear $item data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$item      begsr
650bAC                   eval      savever# = $itver#
650bAC                   clear                   $item
650bAC                   clear                   $item2
650bAC                   eval      $itver# = savever#
650bAC                   endsr

730cA*----------------------------------------------------------------
730cA*  clr$slot  Clear $slot data structure fields
730cA*----------------------------------------------------------------
730cA
730cAC     clr$slot      begsr
730cAC                   eval      savever# = $slver#
730cAC                   clear                   $slot
730cAC                   clear                   $slot2
730cAC                   eval      $slver# = savever#
730cAC                   endsr

650bA*----------------------------------------------------------------
650bA*  clr$uciinfo  Clear $uciinfo data structure fields
650bA*----------------------------------------------------------------
650bA
650bAC     clr$uciinfo   begsr
650bAC                   eval      savever# = $uiver#
650bAC                   clear                   $uciinfo
720gAC                   clear                   $uciinfo2
650bAC                   eval      $uiver# = savever#
650bAC                   eval      $uiaddemp = #emp#
650bAC                   eval      $uiaddusr = #user
650bAC                   eval      $uiaddpgm  = #prog
650bAC                   eval      $uiaddjob  = #job
650bAC                   eval      $uiaddnbr = #jobn
650bAC                   eval      $uichgemp = #emp#
650bAC                   eval      $uichgusr = #user
650bAC                   eval      $uichgpgm  = #prog
650bAC                   eval      $uichgjob  = #job
650bAC                   eval      $uichgnbr = #jobn
650bAC                   endsr

650bA*----------------------------------------------------------------
650bA*
650bA*  DoUCIwgt      Create catchweight record in ORDC.
650bA*
650bAC     DoUCIwgt      begsr
650bAC
650bAC     Ockey         SetGt     Ordc
650bAC     Ockey         ReadPe(n) Ordc

650bAC                   If        %eof(ordc)
650bAC                   Eval      Ocseq = 0
650bAC                   Endif
650bAC                   Eval      NewSeq = OcSeq + 1

650bAC                   Clear                   OcRec
650bAC     OcNkey        Chain     Ordc
650bAC                   If        not %found(ordc)
650bAC                   Eval      OcWhse = LbWhse
650bAC                   Eval      OcOrd  = LbOrd
650bAC                   Eval      OcSeq# = LbSeq
650bAC                   Eval      OcItem = LbItem
650bAC                   Eval      OcSeq  = NewSeq
650bAC                   Eval      Occwgt = UciCwt
650bAC                   Eval      OcTran = LbTrn#
650bAC                   Eval      OcLbl# = LbLbl#
650bAC                   Write     OcRec
650bAc                   eval      processstatus = '*ADD'
650bAc                   exsr      processcwlog
650bAC                   Else
650bAC                   Eval      OcTran = LbTrn#
650bAC                   Eval      Occwgt = UciCwt
650bAC                   Update    OcRec
650bAc                   eval      processstatus = '*UPDATE'
650bAc                   exsr      processcwlog
650bAC                   Endif
650bAC
650bAC                   Endsr

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
     C                   select
     C                   when      nxtscr = '01 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen61                             50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen62                             50
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     *
     C                   when      nxtscr = '03 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen63                             50
     C                   other
     C                   exfmt     screen3                              50
     C                   endsl
500hA*
500hAC                   when      nxtscr = '04 '
500hA*
500hAC                   select
500hAC                   when      #lline =  '16'
500hAC                   exfmt     screen64                             50
500hAC                   other
500hAC                   exfmt     screen4                              50
500hAC                   endsl
500hA*
500hAC                   when      nxtscr = '05 '
500hA*
500hAC                   select
500hAC                   when      #lline =  '16'
500hAC                   exfmt     screen65                             50
500hAC                   other
500hAC                   exfmt     screen5                              50
500hAC                   endsl
     *
520 AC                   when      nxtscr = '06 '
520 A*
520 AC                   select
520 AC                   when      #lline =  '16'
520 AC                   exfmt     screen66                             50
520 AC                   other
520 AC                   exfmt     screen6                              50
520 AC                   endsl
650bA*
650bAC                   when      nxtscr = '07 '
650bA*
650bAC                   select
650bAC                   when      #lline =  '16'
650bAC                   exfmt     screen67                             50
650bAC                   other
650bAC                   exfmt     screen7                              50
650bAC                   endsl
650bA*
650bAC                   when      nxtscr = '08 '
650bA*
650bAC                   select
650bAC                   when      #lline =  '16'
650bAC                   exfmt     screen68                             50
650bAC                   other
650bAC                   exfmt     screen8                              50
650bAC                   endsl
     *
EIb AC                   when      nxtscr = '20 '
EIb A*
EIb AC                   select
EIb AC                   when      #lline =  '16'
EIb AC                   exfmt     screen620                            50
EIb AC                   other
EIb AC                   exfmt     screen20                             50
EIb AC                   endsl
     *
     C                   endsl
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
500hDC*                  setoff                                       9298
500hmC                   setoff                                         98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
CLD A*   Force belt printer to be checked out to user.
CLD A*
CLD AC     ForceBeltPrt  begsr
     *
     C                   if        #bpu <> 'Y'
     C                   eval      $etcode = '*NONE'
     C                   else

     C                   exsr      clr$equipt
     C                   eval      $etwhseu = *on
     C                   eval      $etwhse  = w1whse
     C                   eval      $etemp#u = *on
     C                   eval      $etemp#  = #emp#
     C                   eval      $etcodeu = *on
     C                   eval      $etcode  = 'BLTPRT'

     C                   eval      $dricommand = '*EQUIPT'
     C                   eval      $drisubcmd  = '%GETCHKOUT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   movel     desc(21)      errmsg
     C                   exsr      zm0105
     C                   endif
     C
     C                   endif
     C
     C                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  GetItem      Get item fields.
650bA*
650bAC     GetItem       begSr
650bA /free
650bA   exsr clr$item;
650bA
650bA   $itWhse = w1whse;
650bA   $ititem = lbitem;

650bA   $dricommand = '*ITEM';
650bA   $drisubcmd  = '%GETALL';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   zmflag  = *off;
650bA   exsr zzzdricop;
650bA   if error = *on;
650bA     $ifsltmth = ' ';
650bA   endif;
WSTaA   if client = westside;
WSTaA     $ifsltmth = '1';
WSTaA   endif;
650bA /end-free
650bAC                   endsr

     *----------------------------------------------------------------
520 A*
520 A*  GetPrintOpt  Get print options.
520 A*
520 AC     GetPrintOpt   begSr
 |   *
     *   See if user has belt printer checked out, if not,
     *   do not print label.
     *
     C                   exsr      clr$equipt
     C                   eval      $etwhseu = *on
     C                   eval      $etwhse  = w1whse
     C                   eval      $etemp#u = *on
     C                   eval      $etemp#  = #emp#
     C                   eval      $etcodeu = *on
     C                   eval      $etcode  = 'BLTPRT'

     C                   eval      $dricommand = '*EQUIPT'
     C                   eval      $drisubcmd  = '%GETCHKOUT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     *  Belt printer not checked out, setof error condition.
     C                   eval      error = *off
     C                   goto      endgetprtopt
     C                   endif
     *
     *  Get pallet summary information.

     C     ruotrn        chain     pltsum4
     C                   if        not %found(pltsum4)
     C                   goto      endgetprtopt
     C                   endif

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz
     C                   if        %eof(optionz)
     C                   GoTo      endgetprtopt
     C                   endif
     C                   endif
     *
     *    Set OPTIONZ device to belt printer being used.
     *
     C                   eval      oppdev = $etcode
     C                   eval      oppfrm = '*STD'

     *    Print shorts/runner flag label.

     C                   exsr      printlabels

     C     endgetprtopt  Endsr
     *
     *---------------------------------------------------------------
     *
520 A*  PrintLabels   Print Runner Flag labels
     *
520 AC     PrintLabels   BegSr
     *
520 A*    Define label set.
520 A*      It is assumed that the standard label set is in the format
520 A*      'PFMTZBRccc', where 'ccc' is the client id (i.e., PFMTZBRCBI).
520 A*      The belt printer label set will be BLTccc.

520 AC                   eval      @set = 'BLT' + %subst(oplpgm:8:3)

520 A*      Send qty found, whether normal, brkdwn 1, or brkdwn 2.

520 AC                   eval      nbrqyfPFMT = 0
520 AC                   select
520 AC                   when      nbrqyfd > 0
520 AC                   eval      nbrqyfPFMT = nbrqyfd
520 AC                   when      nbrqyf1 > 0
520 AC                   eval      nbrqyfPFMT = nbrqyf1
520 AC                   when      nbrqyf2 > 0
520 AC                   eval      nbrqyfPFMT = nbrqyf2
520 AC                   endsl

520 A*  Get route number.
520 AC     rhkey         chain     rtehed
520 AC                   if        not %found(rtehed)
520 AC                   eval      rhrte  = ' '
520 AC                   endif

640eAC                   if        rutype = 'U'
640eAC                   eval      $pfcmd = '*SHORTM '
640eAC                   else
640eAC                   eval      $pfcmd = '*SHORT  '
640eAC                   endif

520 AC                   call      'PFMT'
640eDC**                 parm      '*SHORT  '    $pfcmd            8
640eMC                   parm                    $pfcmd            8
520 AC                   parm                    @set              6
520 AC                   parm                    $pffmt            8
520 AC                   parm                    pswhse
520 AC                   parm                    psrtid
520 AC                   parm                    pscomp
520 AC                   parm                    pstzon
520 AC                   parm                    psgen
520 AC                   parm                    psszon
520 AC                   parm                    pstruk
520 AC                   parm                    rhrte
520 AC                   parm                    opzdta
520 AC                   parm      sv_ruotrn     $ptrn#            7 0
520 AC**520bD            parm      sv_w2lbl#     $plbl#            7 0
520bMC**520cD            parm      w2lbl#        $plbl#            7 0
520cMC                   parm      lblbl#        $plbl#            7 0
520 AC                   parm      nbrqyfPFMT    $pqty             5 0
520 AC                   parm      0             $pcwgt            7 2
     *
     C                   endsr
650bA*----------------------------------------------------------------
650bA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650bA*----------------------------------------------------------------

650bA /free
650bA   begsr processCWlog;
650bA     exsr clrCWLog;
650bA     $cwwhse = ocwhse;
650bA     $cwitem = ocitem;
650bA     $cwseltrn# = octran;
650bA     $cwsellbl# = oclbl#;
650bA     $cwselord  = ocord;
650bA     $cwselseq  = ocseq#;
650bA     $cwselcseq = ocseq;
650bA     if w7uci <> ' ';
650bA       $cwscan = %XLATE(fnc1Hex1D: space: w7uci);
650bA     endif;
650bA     $cwwgtlbs = occwgt;
650bA     if $cwscan <> ' ';
650bA       $cwentflg = 4;
650bA     else;
650bA       $cwentflg = 2;
650bA     endif;

650bA     cwdata = $cwlog;
650bA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650bA     $cwlog = cwdata;

650bA     select;
650bA       when %error;
650bA         error = *on;
650bA       when cwrtn <> '*OK';
650bA         error = *on;
650bA     endsl;
650bA   endsr;
650bA /end-free
     *
650bA*----------------------------------------------------------------
650bA*  RunnerDone    Runner Done - replace runner trn#/with sel trn#
650bA*----------------------------------------------------------------
650bA*  UCI Selection - Runner done
650bAC     Runnerdone    begsr

650bA /free
650bA    // replace runner tran# with selection tran#

650bA    exsr clr$uciinfo;
650bA    $uiwhse = lbwhse;
650bA    $uiitem = lbItem;
650bA    $uisellbl# = w2lbl#;
650bA    $uiseltrn# = lbtrn#;
650bA    $uirtntrn# = w1trn#;

650bA    $dricommand = '*UCIINFO';
650bA    $drisubcmd  = '*RUNDONE';
650bA    $drisys2upd = 'D';
650bA    exsr zzzdricop;
650bA    if error = *on;
650bA      errmsg = $drimessage;
650bA      exsr zm0105;
650bA    endif;
650bA    w7uci = ' ';
650bA
650bA /end-free
650bAC                   endsr
650bA*----------------------------------------------------------------
650bA*  UndoRunner    Undo runner - user cancelled
650bA*----------------------------------------------------------------
650bA*  UCI Selection - undo
650bAC     UndoRunner    begsr

650bA /free
650bA   // First I need to remove the CW records
650bA   // Get uci record so I have the CW seq# to remove
650bA   dow $drireturn <> '*DONE';
650bA     exsr clr$uciinfo;
650bA     $uiwhse = lbwhse;
650bA     $uiitem = lbItem;
650bA     $uisellbl# = w2lbl#;
650bA     $uiseltrn# = lbtrn#;
650bA     $uirtntrn# = w1trn#;

650bA     $dricommand = '*UCIINFO';
650bA     $drisubcmd  = '*GET1RUN';
650bA     $drisys2upd = 'D';
650bA     exsr zzzdricop;
650bA     if $drireturn <> '*DONE';
650bA       // go remove cw record for this cwseq#
650bA       if $uiselcseq > 0;
650bA         NewSeq = $uiselcseq;
650bA         chain (lbwhse: lbord: lbseq: lbitem: lblbl#: NewSeq)
650bA          ordc;
650bA         if %found(ordc);
650bA           delete ocrec;
650bA           // log the change
650bA           processstatus = '*DELETE';
650bA           exsr processcwlog;
650bA           // Remove selection info for transaction/label
650bA           $dricommand = '*UCIINFO';
650bA           $drisubcmd  = '*UNDORUN';
650bA           $drisys2upd = 'D';
650bA           exsr zzzdricop;
650bA         endif;
650bA       endif;
650bA     endif;
650bA   enddo;

650bA    w7uci = ' ';
650bA
650bA /end-free
650bAC                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   move      '01 '         nxtscr
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
510dAC                   eval      ovrrid = *off
510dAC                   eval      zeroovr = *off
510dAC                   eval      *in94  = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     C                   if        refrsh = *on
     C                   if        skip2 = *Off
     C     rukey         setll     runner3
     C                   endif
     C                   exsr      zzget2
     *
     *    End of Runner Flag entries. - Return to Screen 1.
     C                   if        nomore = *on
CBIcAC                   if        client = Cheney
CBIcAC                   move      'EOJ'         nxtscr
CBIcAC                   else
     C                   exsr      scr01i
CBIcAC                   endif
     C                   goto      end02i
     C                   endif
     *
     C                   exsr      zzfil2
     C                   endif
     *
     C                   eval      refrsh = *off
     *
     C     end02i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
510dAC                   eval      ovrrid = *off
510dAC                   eval      zeroovr = *off
510dAC                   eval      *in94 = *off
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  Screen 04 initialization
500hA*
500hAC     scr04i        begsr
500hAC                   move      '04 '         nxtscr
500hAC                   exsr      zzget4
500hAC                   exsr      zzfil4
500hAC                   eval      refrsh = *off
500hAC     end04i        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  Screen 05 initialization
500hA*
500hAC     scr05i        begsr
500hAC                   move      '05 '         nxtscr
500hAC                   exsr      zzget5
500hAC                   exsr      zzfil5
500hAC                   eval      refrsh = *off
500hAC     end05i        endsr
     *
     *----------------------------------------------------------------
520 A*
520 A*  Screen 06 initialization
520 A*
520 AC     scr06i        begsr
520 AC                   move      '06 '         nxtscr
520 AC                   exsr      zzget6
520 AC                   exsr      zzfil6
520 AC                   eval      refrsh = *off
520 AC     end06i        endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  Screen 07 initialization
650bA*
650bAC     scr07i        begsr
650bAC                   move      '07 '         nxtscr
650bAC                   exsr      zzget7
650bAC                   exsr      zzfil7
650bAC                   eval      refrsh = *off
650bAC     end07i        endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  Screen 08 initialization
650bA*
650bAC     scr08i        begsr
650bAC                   move      '08 '         nxtscr
650bAC                   eval      ovrrid = *off
650bAC                   eval      zeroovr = *off
650bAC                   eval      *in94 = *off
650bAC                   exsr      zzget3
650bAC                   exsr      zzfil3
650cDC*                  eval      w3qyfd  = %editc(w7qyfd:'Z')
650cMC                   eval      w3qyfd  = %editc(w7qyfd:'3')
650bAC                   eval      refrsh = *off
650bAC     end08i        endsr
     *----------------------------------------------------------------
EIb A*
EIb A*  Screen 20 initialization
EIb A*
EIb AC     scr20i        begsr
EIb AC                   move      '20 '         nxtscr
EIb AC                   exsr      zzget20
EIb AC                   exsr      zzfil20
EIb AC                   eval      refrsh = *off
EIb AC     end20i        endsr
     *
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
     C                   move      'EOJ'         nxtscr
     *
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
520 A*  Test for F8 - Load
     *
520 AC                   if        *inkh
     *
CLD AC                   if        client = cityline
CLD AC                   exsr      ForceBeltPrt
CLD AC                   if        error = *on
CLD AC                   goto      endsc1
CLD AC                   endif
CLD AC                   endif
     *
520 AC                   call      'LOADR10'
520 AC                   goto      endsc1
520 AC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     *
     C                   goto      endsc1
     C                   endif
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
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
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
650bAc                   if        $ifsltmth = '2'
650bAc                   exsr      undorunner
650bAc                   endif
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
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
650bAc                   if        $ifsltmth = '2'
650bAc                   exsr      undorunner
650bAc                   endif
     C                   eval      refrsh = *off
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
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
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   eval      refrsh = *off
     C                   exsr      scr02i
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
     C                   eval      refrsh = *off
     C                   move      '02 '         nxtscr
     C                   exsr      scr02i
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
     C     redspl        cabeq     *on           endsc3

CBIhDC**                 if        oprloa = 'Y'
CBIhMC                   if        client = cheney
CBIfA*
CBIfA*     Display Pop-Up Screen if flag qty found is >
CBIfA*     zero to verify that the item is loaded on the
CBIfA*     respective Pallet/Trailer.
CBIfA*
CBIfAC     Rtkey         chain     Rtehed
CBIfAC                   if        %Found(Rtehed)
CBIfAC                   if        rhrte >= '800' and
CBIfAC                             rhrte <= '899'
CBIfAC                   goto      endsc3
CBIfAC                   endif
CBIfAC                   endif
CBIfA *
CBIfAC                   if        w3qyfd <> *blanks
CBIfAC                             and %dec(w3qyfd:5:0) <> *zeros
CBIfAC                   Move      #prog         pprg             10
CBIfAC                   Move      *blanks       rtncd             8
CBIfAC                   Z-add     lbwhse        $pwhs#
CBIfAC                   move      lbrte         $prte#
CBIfAC                   z-add     lbpal#        $pltid
CBIfAC                   z-add     lblbl#        $labl#
CBIfA *
CBIfAC                   call      'LOADR11'
CBIfAC                   parm                    $parm
CBIfAC                   parm                    pprg
CBIfAC                   parm                    rtncd
CBIfA *
CBIfAC                   if        rtncd = '*EXIT   ' or
CBIfAC                             rtncd = '*CANCEL '
CBIfAC                   eval      refrsh = *on
CBIfAC                   exsr      scr03i
CBIfAC                   goto      endsc3
CBIfAC                   endif
CBIfAC                   endif
720cAC                   endif

520 A*    Ask for qty confirmation if option oprvfq = Y.
     C*
520 AC                   if        oprvfq = 'Y'
520 A*    Proceed to qty confirmation screen.
520 AC                   exsr      scr06i
520 AC                   goto      endsc3
520 AC                   endif

     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  SC4  -  Screen 4
500hA*
500hAC     sc4           begsr
500hA*
500hA*  Test for F5 - Refresh
500hA*
500hAC                   if        *inke
500hAC                   eval      refrsh = *on
500hAC                   exsr      scr04i
500hAC                   goto      endsc4
500hAC                   endif
500hA*
500hA*  Test for other command keys BEFORE verification and update.
500hA*
500hAC                   move      '*BEFORE '    cmdchk
500hAC                   exsr      zzcmd4
500hAC     cmdtkn        cabeq     *on           endsc4
500hA*
500hA*  Some other key pressed.
500hA*
500hA*     Check input and write/update record.
500hA*
500hAC                   exsr      zzchk4
500hAC     error         cabeq     *on           endsc4
500hAC     redspl        cabeq     *on           endsc4
500hAC                   exsr      zzupd4
500hAC     error         cabeq     *on           endsc4
500hA*
500hA*  Test for other command keys AFTER verification and update.
500hA*
500hAC                   move      '*AFTER  '    cmdchk
500hAC                   exsr      zzcmd4
500hAC     cmdtkn        cabeq     *on           endsc4
500hA*
500hAC     endsc4        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  SC5  -  Screen 5
500hA*
500hAC     sc5           begsr
510cA*
510cA*  Test for F3 - Exit
510cA*
510cAC                   if        *inkc
510cAC                   eval      refrsh = *on
510cAC                   exsr      scr02i
510cAC                   goto      endsc5
510cAC                   endif
500hA*
500hA*  Test for F5 - Refresh
500hA*
500hAC                   if        *inke
500hAC                   eval      refrsh = *on
500hAC                   exsr      scr05i
500hAC                   goto      endsc5
500hAC                   endif
510cA*
510cA*  Test for F12 - Previous
510cA*
510cAC                   if        *inkl
510cAC                   eval      refrsh = *on
510cAC                   exsr      scr02i
510cAC                   goto      endsc5
510cAC                   endif
500hA*
500hA*  Test for other command keys BEFORE verification and update.
500hA*
500hAC                   move      '*BEFORE '    cmdchk
500hAC                   exsr      zzcmd5
500hAC     cmdtkn        cabeq     *on           endsc5
500hA*
500hA*  Some other key pressed.
500hA*
500hA*     Check input and write/update record.
500hA*
500hAC                   exsr      zzchk5
500hAC     error         cabeq     *on           endsc5
500hAC     redspl        cabeq     *on           endsc5
500hAC                   exsr      zzupd5
500hAC     error         cabeq     *on           endsc5
500hA*
500hA*  Test for other command keys AFTER verification and update.
500hA*
500hAC                   move      '*AFTER  '    cmdchk
500hAC                   exsr      zzcmd5
500hAC     cmdtkn        cabeq     *on           endsc5
500hA*
500hAC     endsc5        endsr
     *
     *----------------------------------------------------------------
     *
520 A*  SC6  -  Screen 6
520 A*
520 AC     sc6           begsr
 |   *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
650bAc                   if        $ifsltmth ='2'
650bAC                   move      '07 '         nxtscr
650bAC                   eval      refrsh = *off
650bAC                   exsr      scr07i
650bAc                   else
     C                   move      '03 '         nxtscr
     C                   eval      refrsh = *off
     C                   exsr      scr03i
650bAc                   endif
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
650bAc                   if        $ifsltmth ='2'
650bAC                   move      '07 '         nxtscr
650bAC                   eval      refrsh = *off
650bAC                   exsr      scr07i
650bAc                   else
     C                   eval      refrsh = *off
     C                   move      '03 '         nxtscr
     C                   exsr      scr03i
650bAc                   endif
     C                   goto      endsc6
     C                   endif
     *
     *     Check input
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C     redspl        cabeq     *on           endsc6
     *
     *     Update
     *
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc6
     *
     *     Print runner label
     *
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  SC7  -  Screen 7
650bA*
650bAC     sc7           begsr
650bA*
650bA*
650bA*  Test for F12 - Previous
650bA*
650bAC                   if        *inkl
650bAC                   eval      refrsh = *off
650bAC                   move      '02 '         nxtscr
650bAC                   exsr      scr02i
650bAC                   goto      endsc7
650bAC                   endif
650bA*
650bA*  Test for other command keys BEFORE verification and update.
650bA*
650bAC                   move      '*BEFORE '    cmdchk
650bAC                   exsr      zzcmd7
650bAC     cmdtkn        cabeq     *on           endsc7
650bA*
650bA*  Some other key pressed.
650bA*
650bA*     Check input and write/update record.
650bA*
650bAC                   exsr      zzchk7
650bAC     error         cabeq     *on           endsc7
650bAC     redspl        cabeq     *on           endsc7
650bA
650bAC                   exsr      zzupd7
650bAC     error         cabeq     *on           endsc7
650bA*
650bA*  Test for other command keys AFTER verification and update.
650bA*
650bAC                   move      '*AFTER  '    cmdchk
650bAC                   exsr      zzcmd7
650bAC     cmdtkn        cabeq     *on           endsc7
650bA*
650bAC     endsc7        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  SC8  -  Screen 8
650bA*
650bAC     sc8           begsr
650bA*
650bA*  Test for F3 - Exit
650bA*
650bAC                   if        *inkc
650bAC                   move      '07 '         nxtscr
650bAC                   eval      refrsh = *off
650bAC                   exsr      scr07i
650bAC                   goto      endsc8
650bAC                   endif
650bA*
650bA*  Test for F5 - Refresh
650bA*
650bAC                   if        *inke
650bAC                   eval      refrsh = *on
650bAC                   exsr      scr08i
650bAC                   goto      endsc8
650bAC                   endif
650bA*
650bA*  Test for F12 - Previous
650bA*
650bAC                   if        *inkl
650bAC                   eval      refrsh = *off
650bAC                   move      '07 '         nxtscr
650bAC                   exsr      scr07i
650bAC                   goto      endsc8
650bAC                   endif
650bA*
650bA*  Test for other command keys BEFORE verification and update.
650bA*
650bAC                   move      '*BEFORE '    cmdchk
650bAC                   exsr      zzcmd8
650bAC     cmdtkn        cabeq     *on           endsc8
650bA*
650bA*  Some other key pressed.
650bA*
650bA*     Check input and write/update record.
650bA*
650bAC                   exsr      zzchk8
650bAC     error         cabeq     *on           endsc8
650bAC     redspl        cabeq     *on           endsc8
650bA
650bA*    Ask for qty confirmation if option oprvfq = Y.
650bAC*
650bAC                   if        oprvfq = 'Y'
650bA*    Proceed to qty confirmation screen.
650bAC                   exsr      scr06i
650bAC                   goto      endsc8
650bAC                   endif
650bA
650bAC                   exsr      zzupd8
650bAC     error         cabeq     *on           endsc8
650bA*
650bA*  Test for other command keys AFTER verification and update.
650bA*
650bAC                   move      '*AFTER  '    cmdchk
650bAC                   exsr      zzcmd8
650bAC     cmdtkn        cabeq     *on           endsc8
650bA*
650bAC     endsc8        endsr
650bA*
650bA*
650bA*----------------------------------------------------------------
EIb A*
EIb A*  SC20  -  Screen 20
EIb A*
EIb AC     sc20          begsr
EIb A*
EIb A*  Test for F3 - Exit
EIb A*
EIb AC                   if        *inkc
EIb AC                   move      '01 '         nxtscr
EIb AC                   exsr      scr01i
EIb AC                   goto      endsc20
EIb AC                   endif
EIb A*
EIb A*  Test for F12 - Previous
EIb A*
EIb AC                   if        *inkl
EIb AC                   eval      refrsh = *off
EIb AC                   move      '01 '         nxtscr
EIb AC                   exsr      scr01i
EIb AC                   goto      endsc20
EIb AC                   endif
EIb A*
EIb A*  Test for other command keys BEFORE verification and update.
EIb A*
EIb AC                   move      '*BEFORE '    cmdchk
EIb AC                   exsr      zzcmd20
EIb AC     cmdtkn        cabeq     *on           endsc20
EIb A*
EIb A*  Some other key pressed.
EIb A*
EIb A*     Check input and write/update record.
EIb A*
EIb AC                   exsr      zzchk20
EIb AC     error         cabeq     *on           endsc20
EIb AC     redspl        cabeq     *on           endsc20
EIb AC                   exsr      zzupd20
EIb AC     error         cabeq     *on           endsc20
EIb A*
EIb A*  Test for other command keys AFTER verification and update.
EIb A*
EIb AC                   move      '*AFTER  '    cmdchk
EIb AC                   exsr      zzcmd20
EIb AC     cmdtkn        cabeq     *on           endsc20
EIb A*
EIb AC     endsc20       endsr
EIb A*
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
500 A*
     *
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
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
     C                   eval      msgk = *zeros
     *
     C                   if        #lline = '16'
     C                   write     m16clr
     *
     C                   else
     C                   write     msgclr
     C                   endif
     *
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
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
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
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endif
     *
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     *
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
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500hA*----------------------------------------------------------------
500hA*    PIR1008  Date is required.
500hA*
500hAC     zm1008        begsr
500hAC                   move      'PIR1008'     #msgid
500hAC                   move      '*DIAG  '     #msgtp
500hAC                   movea     errmsg        $md
500hAC                   exsr      zmpmsg
500hAC                   endsr
500hA*----------------------------------------------------------------
500hA*    PIR1009  Date must be > today's date.
500hA*
500hAC     zm1009        begsr
500hAC                   move      'PIR1009'     #msgid
500hAC                   move      '*DIAG  '     #msgtp
500hAC                   movea     errmsg        $md
500hAC                   exsr      zmpmsg
500hAC                   endsr
     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
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
     *    PIR7872  Record not updated in file.
     *
     C     zm7872        begsr
     C                   move      'PIR7872'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
CLD AC                   if        client = cityline
CLD AC                   exsr      ForceBeltPrt
CLD AC                   if        error = *on
CLD AC                   goto      endck1
CLD AC                   endif
CLD AC                   endif
     *
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     *
     C                   call      'WH900'
     C                   parm                    $lparm
     *
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
520 M*  Confirm that a transaction number was entered if oprscn = '1'.
     *
     C                   If        w1trn# <= 0
520 AC                             and oprscn = '1'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
520 A*  Verify label number entered if oprscn = '2'.
     *
520 AC                   if        oprscn = '2'
     * grab label#
530aAC                   move      w1whse        $pwhse
530aAC                   movel     w1lab#b       $pbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $pwhse            3
530aAC                   parm                    $pbarcode        15
530aAC                   parm                    $plbl#
530aAC                   parm                    $prtid            5
530aAC                   parm                    $punq#            5
530aAC                   parm                    $preturn          8
530aAC                   parm                    $perrmsg         60
530aAC                   if        $preturn = '*OK'
530aAC                   eval      w1lab# = $plbl#
530aAC                   move      *blanks       w1lab#b
530bDC*****              move      $plbl#        w1lab#b
530bMC                   eval      w1lab#b = %char($plbl#)
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      *in28 = *on
530aAC                   movel     desc(5)       errmsg
530aAC                   exsr      zm0105
530aAC                   endif
     *
520 AC     w1lab#        chain (n) Label
520 AC                   if        not %found(Label)
520 AC                   eval      error = *on
520 AC                   eval      *in28 = *on
520 AC                   movel     desc(5)       errmsg
520 AC                   exsr      zm0105
520 AC                   else
520 AC                   eval      rutrn# = 0
520 AC     ru6key        chain     runner6
520 AC                   eval      w1trn# = rutrn#
710eA*  If no runner trans# found on the first pass look
710eA*  for a 'U' type and use its runner trans#
710eAC                   if        w1trn# = 0
720eAC                             or w1trn# > 0 and ruqyfd < ruqyso
710eAC     ru6key        setll     Runner6
710eAC                   Dow       Forever = Forever
710eAC     ru6key        reade     Runner6
710eAC                   Select
710eAC                   When      %eof(runner6)
710eAC                   Leave
710eA*
710eAC                   when      rutype = 'U'
710eAC                   Eval      w1trn# = rutrn#
710eAC                   Leave
710eAC                   Endsl
710eAC                   Enddo
710eAC                   endif

520 AC                   Endif
520 AC                   Endif
     *
     *  Verify transaction number.
     *
     C                   If        w1trn# >= 0
     C                   eval      $lcmd  = '*VERIFY '
     C                   eval      $ltrn# = w1trn#
     *
     C                   call      'PT900'
     C                   parm                    $lparm
     *
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error  = *on
     C                   eval      *in22  = *on
     C                   eval      *in02  = *on
     C                   move      $lmsg         #msgk
     C                   exsr      zmqmsg
     C                   endif
     *
     *  Verify transaction number is a RUNNER task
720dDC**   w1trn#        chain     pirtran
720dMC     w1trn#        chain(n)  pirtran
     C                   select
     C                   when      not %found(pirtran)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(2)       errmsg
     C                   exsr      zm0105
     *
     C                   when      %found(pirtran) and
     C                             pttask <> 'RUNNER'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     C                   endsl
     C                   endif
     *
500dA*    Find Flag Type user will be working on.
500dAC                   If        Error = *off
500dAC                   eval      kytype = 'N'
500dA*
500dA*      If found, Type is N=Normal.
500dAC     rukey         setll     runner3
500dAC                   If        not %equal(runner3)
500dAC                   eval      kytype = 'U'
500dA*
500dA*      If found, Type is U=Out.
500dAC     rukey         setll     runner3
500dAC                   if        not %equal(runner3)
500dA*      Else, Type is M=Merge.
500dAC                   eval      kytype = 'M'
500dA*      If not found
500dAC     rukey         setll     runner3
500dAC                   if        not %equal(runner3)
710aA*      Else, Type is B=Boxbreaker
710aAC                   eval      kytype = 'B'
710aAC                   endif
500dAC                   endif
500dAC                   endif
500dA*
500dAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     * grab label#
530aAC                   move      w1whse        $pwhse
530aAC                   move      *blanks       $pbarcode
530aAC                   movel     w2lbl#b       $pbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $pwhse            3
530aAC                   parm                    $pbarcode        15
530aAC                   parm                    $plbl#
530aAC                   parm                    $prtid            5
530aAC                   parm                    $punq#            5
530aAC                   parm                    $preturn          8
530aAC                   parm                    $perrmsg         60
530aAC                   if        $preturn = '*OK'
530aAC                   eval      w2lbl# = $plbl#
530aAC                   move      *blanks       w2lbl#b
530bDC*****              move      $plbl#        w2lbl#b
530bMC                   eval      w2lbl#b = %char($plbl#)
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      *in28 = *on
530aAC                   movel     desc(5)       errmsg
530aAC                   exsr      zm0105
530aAC                   endif
     *
     *  Verify label number entered.
     *
     C     W2lbl#        chain (n) Label
     C                   Select
     C                   When      not %found(Label)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Label)
     *
     *    Label not flagged yet.
     C                   Select
     C                   When      Lbvrfy <> 'F'
500cAC                             and Lbvrfy <> 'I'
500cAC                             and Lbstat <> 'C'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(6)       errmsg
     C                   exsr      zm0105
     *
     *    Label already closed.
500cD*     Removed test for closed label. Allow flag to be cleared
500cD*     even if label is closed. LBVRFY field will not be updated.
     C                   When      Lbstat = 'C'
500cDC*                  eval      error = *on
500cDC*                  eval      *in22 = *on
500cDC*                  eval      *in02 = *on
500cDC*                  movel     desc(7)       errmsg
500cDC*                  exsr      zm0105
     *
     C                   Endsl
     *
     *    Retrieve Flag file record.
500cDC*    W2lbl#        chain (n) Runner
500cMC     keyru         chain (n) Runner
     C                   Select
     C                   When      not %found(Runner)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(8)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Runner)
     *
     *    Flag record has been closed.
     C                   Select
     C                   When      Rustat = 'C'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(9)       errmsg
     C                   exsr      zm0105
     *
     *    Flag record at Picked status.
     C                   Other
     *
     C                   Endsl
     *
     C                   Endsl
     *
     C                   Endsl
     *
520 A*  Verify pick slot if option to do so = Y
     *
520 AC                   if        oprvfs = 'Y'
730cDC**                           and w2disp <> w2dsp

730cMC                   if        w2dsp = ' '
520 AC                   eval      error = *on
520 AC                   eval      *in29 = *on
520 AC                   eval      *in09 = *on
520 AC                   movel     desc(18)      errmsg
520 AC                   exsr      zm0105
730cAC                   leavesr
520 AC                   endif
730cA*
730cA*  Verify slot scanned matches slot displayed
730cA*
730cAC                   exsr      clr$slot
730cAC                   eval      $dricommand = '*SLOT'
730cAC                   eval      $drisubcmd  = '%GET'
730cAC                   eval      $drisys2upd = 'D'
730cA
730cAC                   eval      $slwhseu = *on
730cAC                   eval      $slwhse = lbwhse
730cAC                   eval      $slwhdpu = *on
730cMC                   eval      $slwhdp = lbwhdp
730cAC                   eval      $sldispu = *on
730cAC                   eval      $sldisp = w2dsp
730cAC                   exsr      zzzdricop
730cA*
730cA * drislot returns $sacdsp with base slot
730cA*
730cAC                   if        w2dsp <> $sacdsp
730cAC                   eval      error = *on
730cAC                   eval      *in29 = *on
730cAC                   eval      *in09 = *on
730cAC                   eval      errmsg = *blanks
730cAC                   eval      errmsg = desc(18)
730cAC                   exsr      zm0105
730cAC                   leavesr
730cAC                   endif

650aAC                   endif
     *
     C     endck2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     *
     C                   Exsr      Zzchk2
     *
510 A*    Validate characters entered for qty short.
510 AC                   eval      pos  = %check (valid : w3qyfd)
510 AC                   eval      pos1 = %check (valid : w3qyf1)
510 AC                   eval      pos2 = %check (valid : w3qyf2)
510 A*    Invalid characters in qty found fields.
510 AC                   If           pos  > 0
510 AC                             or pos1 > 0
510 AC                             or pos2 > 0
510 AC                   eval      error = *on
510 AC                   movel     desc(16)      errmsg
510 AC                   exsr      zm0105
510 A*      Invalid characters found, flag field.
510 AC                   If           pos  > 0
510 AC                   eval      *in03 = *on
510 AC                   eval      *in23 = *on
510 AC                   Endif
510 A*      Invalid characters found, flag field.
510 AC                   If           pos1 > 0
510 AC                   eval      *in04 = *on
510 AC                   eval      *in24 = *on
510 AC                   Endif
510 A*      Invalid characters found, flag field.
510 AC                   If           pos2 > 0
510 AC                   eval      *in05 = *on
510 AC                   eval      *in25 = *on
510 AC                   Endif
510 A*
510dAC                   goto      endck3
510 AC                   Endif
510 A*
510 A*    Qty value must be entered for short.
510 A*
510 A*       Only single uom entry allowed and no entry by user.
510 AC                   If        w3qyfd = ' '
510 AC                             and *in92 = *on
510 AC                             and *in93 = *on
510 AC                   eval      error = *on
510 AC                   eval      *in23 = *on
510 AC                   eval      *in03 = *on
510 AC                   movel     desc(12)      errmsg
510 AC                   exsr      zm0105
510dAC                   goto      endck3
510 AC                   Endif
510 A*
510 A*       Only two uom entries allowed and no entry by user.
510 AC                   If            w3qyfd = ' '
510 AC                             and w3qyf1 = ' '
510 AC                             and *in92  = *off
510 AC                   eval      error = *on
510 AC                   eval      *in23 = *on
510 AC                   eval      *in03 = *on
510 AC                   movel     desc(12)      errmsg
510 AC                   exsr      zm0105
510dAC                   goto      endck3
510 AC                   Endif
510 A*
510 A*       All three uom entries allowed and no entry by user.
510 AC                   If            w3qyfd = ' '
510 AC                             and w3qyf1 = ' '
510 AC                             and *in92  = *off
510 AC                             and w3qyf2 = ' '
510 AC                             and *in93  = *off
510 AC                   eval      error = *on
510 AC                   eval      *in23 = *on
510 AC                   eval      *in03 = *on
510 AC                   movel     desc(12)      errmsg
510 AC                   exsr      zm0105
510dAC                   goto      endck3
510 AC                   Endif
     *
     *    Qty found must be greater than or equal zero.
     *
510 DC*                  If        w3qyfd < 0
510 DC*                  eval      error = *on
510 DC*                  eval      *in23 = *on
510 DC*                  eval      *in03 = *on
510 DC*                  movel     desc(12)      errmsg
510 DC*                  exsr      zm0105
510 DC*                  Endif
510 A*
510 A*    Convert characters entered into numeric fields.
510 AC                   eval      nbrqyfd = 0
510 AC                   eval      nbrqyf1 = 0
510 AC                   eval      nbrqyf2 = 0
510 A*
510 AC                   if        w3qyfd > ' '
510 AC                             and pos = 0
510 AC                   eval      nbrqyfd = %dec(w3qyfd:5:0)
510 AC                   endif
510 A*
510 AC                   if        w3qyf1 > ' '
510 AC                             and pos = 0
510 AC                   eval      nbrqyf1 = %dec(w3qyf1:5:0)
510 AC                   endif
510 A*
510 AC                   if        w3qyf2 > ' '
510 AC                             and pos = 0
510 AC                   eval      nbrqyf2 = %dec(w3qyf2:5:0)
510 AC                   endif
510dA
510dA*    Clear override flags if quantity was entered.
510dA
510dAC                   if        Nbrqyfd > 0
510dAC                             or Nbrqyf1 > 0
510dAC                             or Nbrqyf2 > 0
510dAC                   eval      zeroovr = *off
510dAC                   eval      ovrrid = *off
510dAC                   eval      *in94 = *off
510dAC                   endif
700aA
710fD**   Quantity cannot be entered if F6=Sub pressed
710fM*    A partial qty can be entered if F6=Sub pressed
700aA
710fDC**                 if        Nbrqyfd > 0
710fDC**                           or Nbrqyf1 > 0
710fDC**                           or Nbrqyf2 > 0
710fMC                   if        Nbrqyfd >= ruqyso
710fMC                             or Nbrqyf1 >= ruqyso
710fMC                             or Nbrqyf2 >= ruqyso
700aAC                   if        *inkf = *on
700aAC                   eval      error = *on
700aAC                   eval      *in23 = *on
700aAC                   eval      *in03 = *on
710fDC**                 eval      errmsg = 'F6=Sub not allowed with quantity'
710fMC                   eval      errmsg = 'No sub allowed if full qty found'
700aAC                   exsr      zm0105
700dAC                   goto      endck3
700aAC                   endif
700aAC                   endif
     *
     *    Qty found can't be greater than qty short/outq.
510 DC*                  If        w3qyfd >  ruqyso
510 MC                   If        Nbrqyfd >  ruqyso
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     DESC(13)      errmsg
     C                   exsr      zm0105
510dAC                   goto      endck3
     C                   Endif
510dA
510dA*    Warn if qty entered is zero and avail qty exists.
510dA
510dAC                   eval      $dricommand = '*ITEMQTY'
510dAC                   eval      $drisubcmd  = '*GET'
510dAC                   eval      $iqwhse  = lbwhse
510dAC                   eval      $iqitem  = lbitem
510dAC                   eval      $drisys2upd = 'D'
510dAC                   exsr      zzzdricop
510dAC                   if        error = *on
510dAC                   eval      $iqavl1 = 0
510dAC                   eval      $iqavl2 = 0
510dAC                   eval      $iqavl3 = 0
510dAC                   eval      error = *off
510dAC                   endif
510dA
510dAC                   if        $iqavl1 > 0
510dAC                             or $iqavl2 > 0
510dAC                             or $iqavl3 > 0
510dAC                   eval      availflg = *on
510dAC                   else
510dAC                   eval      availflg = *off
510dAC                   eval      zeroovr = *off
510dAC                   endif
510dA
510dAC                   if        Nbrqyfd = 0
510dAC                             and Nbrqyf1 = 0
510dAC                             and Nbrqyf2 = 0
510dAC                             and availflg = *on
510dAC                             and ovrrid = *off
GFS A*
GFS AC                   if        client = GetFresh
GFS A*      Bypass warning about available qty in whse.
GFS AC                   eval      zeroovr = *on
GFS AC                   else
GFS A*
510dAC                   eval      error = *on
510dAC                   eval      warn = *on
510dAC                   eval      zeroovr = *on
510dAC                   eval      *in94 = *on
510dAC                   eval      *in23 = *on
510dAC                   eval      *in03 = *on
510dAC                   eval      errmsg = desc(17)
510dAC                   exsr      zm0105
GFS AC                   endif
GFS A*
510dAC                   goto      endck3
510dAC                   endif
     *
     C     endck3        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZCHK4   Screen 4 error checking.
500hA*
500hAC     zzchk4        begsr
500hAC                   move      *off          error

500hA*  Verify entered date

500hAC                   if        w4date = *zeros
500hAC                   eval      error = *on
500hAC                   eval      *in25 = *on
500hAC                   eval      *in05 = *on
500hAC                   eval      errmsg = *blanks
500hAC                   exsr      zm1008
500hAC                   goto      endck4
500hAC                   endif

500hAC                   eval      $cvcmd = '*MDYEDT '
500hAC                   move      w4date        $cvd6i
500hAC                   call      @cvtdt
500hAC                   parm                    $cvtdt
500hAC                   if        $cvrtn = '*PGMQ   '
500hAC                   eval      error = *on
500hAC                   eval      *in25 = *on
500hAC                   eval      *in05 = *on
500hAC                   eval      #msgk = $cvmsg
500hAC                   exsr      zmqmsg
500hAC                   goto      endck4
500hAC                   endif

500hAC     *mdy          move      w4date        mdy
500hAC                   move      mdy           iso
500hAC                   if        iso < today
500hAC                   eval      *in25 = *on
500hAC                   eval      *in05 = *on
500hAC                   eval      error = *on
500hAC                   eval      errmsg = *blanks
500hAC                   exsr      zm1009
500hAC                   goto      endck4
500hAC                   endif
500hA*
500hAC     endck4        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZCHK5   Screen 5 error checking.
500hA*
500hAC     zzchk5        begsr
500hAC                   move      *off          error

500hA*  Verify box entered

500hAC                   if        w5box# <= *zeros
510cDC*                            and client <> EI
510cD*
510cDC*                            or  client =  EI
510cDC*                            and w5box# < *zeros
510cD*
500hAC                   eval      error = *on
500hAC                   eval      *in27 = *on
500hAC                   eval      *in07 = *on
500hAC                   eval      errmsg = *blanks
500hAC                   movel     desc(15)      errmsg
500hAC                   exsr      zm0110
500hAC                   goto      endck5
500hAC                   endif

500hAC     endck5        endsr
     *
     *----------------------------------------------------------------
     *
520 A*  ZZCHK6   Screen 6 error checking.
     *
520 AC     zzchk6        begsr
520 AC                   move      *off          error

520 A*  Verify qty confirmation

520 AC                   if        w6conf <> 'Y'
520 AC                             and w6conf <> 'N'
     *
520 AC                   eval      error = *on
520 AC                   eval      *in30 = *on
520 AC                   eval      *in10 = *on
520 AC                   eval      errmsg = *blanks
520 AC                   movel     desc(20)      errmsg
520 AC                   exsr      zm0105
520 AC                   goto      endck6
520 AC                   endif

520 AC                   if        w6conf <> 'Y'
520 AC                   eval      error = *on
520 AC                   eval      *in23 = *on
520 AC                   eval      *in03 = *on
520 AC                   movel     desc(19)      errmsg
520 AC                   exsr      zm0105
520 AC                   goto      endck6
520 AC                   endif

520 AC     endck6        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCHK7   Screen 7 error checking.
650bA*
650bAC     zzchk7        begsr
650bAC                   move      *off          error
650bAc     assigned      tag

650bA*  UCI Selection

650bA /free

730bA    // don't allow more uci's to be scanned than qty short
730bA    if w3qyso = w7qyfd;
730bA      error = *on;
730bA      *in23 = *on;
730bA      *in03 = *on;
730bA      errmsg = 'Qty Found=Qty Short Done?';
730bA      exsr zm0105;
730bA      leavesr;
730bA    endif;
650bA    // Update selection info for UCI.
650bA    // Extra checks done in DRIUCIINFO.

650bA    exsr clr$uciinfo;
650bA    $uiwhse = lbwhse;
650bA    $uiuci  = w7uci;
650bA    $uiitem = lbItem;
650bA    $uiseltrn# = lbtrn#;
650bA    $uisellbl# = w2lbl#;
650bA    $uiselord  = lbord;
650bA    $uiselseq  = lbseq;
650bA    $uiselcseq = 0;
650bA    $uiseltrax = ' ';
650bA    $uirtntrn# = w1trn#;
720gA    // Lets add some more stuff for tracking
720gA    $uiaction = 'SELECTRUN';
720gA    $uiaolcns = $uiaOlcns;
720gA    $uiaoseq = $uiaOseq;
720gA    $uiscan = ' ';
720gA    $uitran# = lbtrn#;
720gA    $uilbl# = lblbl#;
650bA
650bA    $dricommand = '*UCIINFO';
650bA    $drisubcmd  = '*SELRUN';
650bA    $drisys2upd = 'D';
650bA    exsr zzzdricop;
650bA    if error = *on
650bA       and $DRIMESSAGE = 'GS1-99 not assigned';
650bA /end-free
650bAc                   call      'LB411CL'
650bAc                   parm                    w1whse
650bAc                   parm      ' '           $ret              8
650bAc                   parm      ' '           $dev             10
650bAc                   parm      ' '           $form            10
650bAc                   parm      '*ASSIGN'     $cmd
650bAc                   if        $ret = ' '
650bAc                   goto      assigned
650bAc                   endif
650bA /free
650bA    endif;
650bA    if error = *on;
650bA      errmsg = $drimessage;
650bA      exsr zm0105;
650bA      leavesr;
650bA    endif;
650bA
650bA /end-free
650bA    // If weight item, add weight to ORDC.
650bA
650bAC                   call      'CVTBAR'
650bAC                   parm      '*ALL'        $cbcmd
650bAC                   parm      w7uci         $cbbar
650bAC                   parm                    $cbcod
650bAC                   parm                    $cbdec
650bAC                   parm                    $cbdsc
650bAC                   parm                    $cbpos
650bAC                   parm                    $cbtyp
650bAC                   parm                    $cbv1
650bAC                   parm                    $cbv2
650bAC                   parm                    $cbrtn
650bAC                   parm                    $cberm
650bAC                   parm                    $cbven
650bAC                   parm                    $cvtdata
650bAC                   parm                    $cvtdata2
650bA
650bAC                   eval      $barcode = $cvtdata
650bAC                   eval      $barcode2 = $cvtdata2
650bA
710bA*  Verify UPC UOM is the correct UOM being picked.
710bA* Fill r#header ds
710bAc                   if        not $bcai99sent
710bAC                   eval      $hdrcommand = 'vfyupcuom'
710bAC                   time                    curtime
710bAC                   eval      $hdrtimestamp = %char(curtime)
710bAC                   eval      $slvuuitman#  = #job
710bAC                   movel     w2lbl#b       $pbarcode
710bAC                   move      *blanks       w2lbl#b
710bAC                   move      $plbl#        w2lbl#b
710bAC                   z-add     $plbl#        w2lbl
710bAC                   eval      $slvuuilbl#  = w2lbl
710bAC                   eval      $slvuuivalue = w7uci
710bAC                   eval      $pheader = $header
710bAC                   eval      $pfields = $slvfyupuin
710bAC                   call      'VOSELECT'
710bAC                   parm      '*none'       $pdqlib
710bAC                   parm      '*none'       $pdqnameout
710bAC                   parm      '*none'       $pdqkey
710bAC                   parm                    $pheader
710bAC                   parm                    $pfields
710bAC                   parm                    $prtnfields
710bAC                   eval      $slvfyupuout = $prtnfields
710bA*
710bAC                   if        $slvuuoerrnum   <> 0
710bAC                   eval      error = *on
710bAC                   eval      *in23 = *on
710bAC                   eval      *in03 = *on
710bAC                   eval      errmsg = $slvuuoerrtxt
710bAC                   exsr      zm0105
710bAC                   goto      endck7
710bAC                   endif
710bAC                   endif
     *
     *
650bAC                   if        $bcPNtLbSent
650bAC                   eval      $cbv1 = $bcPNtLb
650bAC                   endif
650bA /free
650bA    // for gs1-99 pre printed labels, we need to check if the weight
650bA    // is passed back from DRIUCIINFO, if not in barcode format
650bA    if $cbv1 = 0;
650bA      select;
650bA        when $uiwgtlbs > 0;
650bA          $cbv1 = $uiwgtlbs;
650bA        when $uiwgtkgs > 0;
650bA          $cbv1 = $uiwgtkgs;
650bA      endsl;
650bA    endif;
650bA    if $cbv1 > 0;
650bA      //$glowhse = lbwhse;
650bA      exsr getitem;
650bA      if $itcwgt = 'Y';
650bA        ucicwt = $cbv1;
650bA        exsr douciwgt;
650bA        ucicwt = 0;
650bA        // Update cw seq# into the uci record.

650bA        exsr clr$uciinfo;
650bA        $uiwhse = lbwhse;
650bA        $uiuci  = w7uci;
650bA        $uiitem = lbitem;
650bA        $uiseltrn# = lbtrn#;
650bA        $uisellbl# = lblbl#;
650bA        $uiselord  = lbord;
650bA        $uiselseq  = lbseq;
650bA        $uiselcseq = ocseq;
650bA        $uiseltrax = ' ';
650bA        $uirtntrn# = w1trn#;
700dA        // Lets add some more stuff for tracking
700dA        $uiaction = 'SELRUNCW';
700dA        $uiaolcns = $uiaOlcns;
700dA        $uiaoseq = $uiaOseq;
700dA        $uiscan = ' ';

650bA        $dricommand = '*UCIINFO';
650bA        $drisubcmd  = '*SELCWSEQ';
650bA        $drisys2upd = 'D';
650bA        exsr zzzdricop;
650bA      endif;
650bA    endif;

650bA    w7uci = ' ';

650bA /end-free

650bAC     endck7        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCHK8   Screen 8 error checking.
650bA*           uses screen 3 checks
650bA*
650bAC     zzchk8        begsr
650bAc                   exsr      zzchk3
650bAC     endck8        endsr
     *
     *----------------------------------------------------------------
EIb A*
EIb A*  ZZCHK20   Screen 20 error checking.
EIb A*
EIb AC     zzchk20       begsr
EIb AC                   eval      error = *off
EIc AC                   eval      w20shft = *blanks
EIc AC                   eval      w20crew = *blanks
EIb A*
EIb A*  Verify emp#
EIb A*
EIb AC     w20emp        chain     piruser1
EIb AC                   Select
EIb AC                   When      not %found(piruser1)
EIb AC                   eval      error = *on
EIb AC                   movel     desc(22)      errmsg
EIb AC                   exsr      zm0105
EIc AC                   When      %found(piruser1)
EIc AC                   eval      w20shft = usshft
EIc AC                   eval      w20crew = uscrew
EIc A*
EIb AC                   Endsl
EIb A*
EIb AC     endck20       endsr
EIb A*
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
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm1        endsr
     *
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
     C                   select
     *    Test for F9 - Skip current Runner flag entry.
     C                   when      *inki = *on
     C                   eval      cmdtkn = *on
     C                   eval      skip2  = *on
     C                   eval      refrsh = *on
     C                   exsr      scr02I
     C                   endsl
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
700bA
700ba*      F6=Sub Override
700ba*        - If zeroovr is on, it means that the qty on hand warning
700ba*          was displayed. Instead of pressing F10, the user will be
700ba*          allowed to press F6 to override the warning and go to subs.
700ba
700bAC                   if        *inkf and zeroovr = *on
700bAC                   eval      ovrrid = *on
700bAC                   endif
     *
     *       F7=Display slot list.
     *
     C                   if        *inkg = *on
     C                   eval      cmdtkn = *on
     C                   eval      $lwhse = lbwhse
     C                   eval      $litem = lbitem
     C                   eval      $lalwc = 'N'
     C                   call      @viewpgm
     C                   parm                    $luky
     C                   parm                    $lreturn          8
     C                   endif
510dA
510dA*      F10=Accept Warning.
510dA
510dAC                   if        *inkj
510dAC                   eval      ovrrid = *on
510dAC                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm3        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZCMD4   User defined command keys for screen 4.
500hA*
500hAC     zzcmd4        begsr
500hA*
500hA*  Command keys to check BEFORE verification and update.
500hA*
500hAC                   if        cmdchk = '*BEFORE '
500hA*
500hAC                   endif
500hA*
500hA*  Command keys to check AFTER verification and update.
500hA*
500hAC                   if        cmdchk = '*AFTER  '
500hA*
500hAC                   endif
500hA*
500hAC     endcm4        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZCMD5   User defined command keys for screen 5.
500hA*
500hAC     zzcmd5        begsr
500hA*
500hA*  Command keys to check BEFORE verification and update.
500hA*
500hAC                   if        cmdchk = '*BEFORE '
500hA*
500hAC                   endif
500hA*
500hA*  Command keys to check AFTER verification and update.
500hA*
500hAC                   if        cmdchk = '*AFTER  '
500hA*
500hAC                   endif
500hA*
500hAC     endcm5        endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCMD7   User defined command keys for screen 7.
650bA*
650bAC     zzcmd7        begsr
650bA*
650bA*  Command keys to check BEFORE verification and update.
650bA*
650bAC                   if        cmdchk = '*BEFORE '
650bA*
650bA
650bA*      F22=Done scanning uci
650bA
650bAC                   if        *inkw
650bAC                   eval      cmdtkn = *on
650bAC                   exsr      scr08i
650bAC                   endif
650bA*
650bAC                   endif
650bA*
650bA*  Command keys to check AFTER verification and update.
650bA*
650bAC                   if        cmdchk = '*AFTER  '
650bA*
650bAC                   endif
650bA*
650bAC     endcm7        endsr
650bA*
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCMD8   User defined command keys for screen 8.
650bA*           uses cmd3 logic - this is just a verification screen
650bA*           identical to screen3 but fields are protected based
650bA*           on uci scans.
650bAC     zzcmd8        begsr
650bAc                   exsr      zzcmd3
650bAC     endcm8        endsr
     *----------------------------------------------------------------
EIb A*
EIb A*  ZZCMD20  User defined command keys for screen 20.
EIb A*
EIb AC     zzcmd20       begsr
EIb A*
EIb A*  Command keys to check BEFORE verification and update.
EIb A*
EIb AC                   if        cmdchk = '*BEFORE '
EIb A*
EIb AC                   endif
EIb A*
EIb A*  Command keys to check AFTER verification and update.
EIb A*
EIb AC                   if        cmdchk = '*AFTER  '
EIb A*
EIb AC                   endif
EIb A*
EIb AC     endcm20       endsr
EIb A*
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
CBI DC*                  eval      w1trn# = *zeros
CBI MC                   eval      w1trn# = $ptrn
520 AC                   eval      w1lab# = *zeros
720hAC                   eval      w1lab#b = $plab
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2disp = rudisp
520 AC**520bD            eval      sv_w2lbl# = w2lbl#
530aDC*****              eval      w2lbl# = rulbl#
530bDC*****              movel     rulbl#        w2lbl#b
530bMC                   eval      w2lbl#b = %char(rulbl#)
520 AC                   eval      w2dsp  = ' '
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3lbl# = w2lbl#
     C                   eval      w3disp = w2disp
     *
     C                   eval      $iitem = lbitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr  = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     *
     C                   eval      w3qyso = ruqyso
510 DC*                  eval      w3qyfd = 0
510 MC                   eval      w3qyfd = ' '
     C                   eval      w3ucod = lbucod
500fAC                   eval      w3uco3 = lbucod

510 DC*                  eval      w3qyf1 = *zeros
510 MC                   eval      w3qyf1 = ' '
500fAC                   eval      w3uco1 = *blanks
510 DC*                  eval      w3qyf2 = *zeros
510 MC                   eval      w3qyf2 = ' '
500fAC                   eval      w3uco2 = *blanks
500fAC                   eval      *in92 = *on
500fAC                   eval      *in93 = *on

500fAC                   if        OPRBDU = 'Y'
500fAC                   if        ITFlg1 = 'Y'
640bAC                             and lbutyp = 'N'
500fAC                   eval      w3uco1 = itum2
500fAC                   eval      *in92 = *off
500fAC                   endif

640bAC                   if        ITFlg1 = 'Y' and ITFlg2 = 'Y'
640bAC                             and lbutyp = '1'
640bAC                   eval      w3uco1 = itum3
640bAC                   eval      *in92 = *off
640bAC                   endif

500fAC                   if        ITFlg1 = 'Y' and ITFlg2 = 'Y'
640bAC                             and lbutyp = 'N'
500fAC                   eval      w3uco2 = itum3
500fAC                   eval      *in93 = *off
500fAC                   endif
500fAC                   endif
     *
     C     endfl3        endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZFIL4   Fill screen 4 fields with info from file.
500hA*
500hAC     zzfil4        begsr
500hA*
500hAC                   eval      w4lbl# = w3lbl#
500hAC                   eval      w4disp = w3disp
510 DC*                  eval      w4qyfd = w3qyfd
510 MC                   eval      w4qyfd = Nbrqyfd
500hAC                   eval      w4ucod = w3ucod
510 DC*                  eval      w4qyf1 = w3qyf1
510 MC                   eval      w4qyf1 = Nbrqyf1
500hAC                   eval      w4uco1 = w3uco1
510 DC*                  eval      w4qyf2 = w3qyf2
510 MC                   eval      w4qyf2 = Nbrqyf2
500hAC                   eval      w4uco2 = w3uco2
500hAC                   eval      w4date = *zeros
500hA*
500fAC                   eval      *in92 = *on
500fAC                   eval      *in93 = *on

500fAC                   if        OPRBDU = 'Y'
500fAC                   if        ITFlg1 = 'Y'
500fAC                   eval      w3uco1 = itum2
500fAC                   eval      *in92 = *off
500fAC                   endif

500fAC                   if        ITFlg1 = 'Y' and ITFlg2 = 'Y'
500fAC                   eval      w3uco2 = itum3
500fAC                   eval      *in93 = *off
500fAC                   endif
500fAC                   endif

500hAC                   endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZFIL5   Fill screen 5 fields with info from file.
500hA*
500hAC     zzfil5        begsr
500hA*
500hAC                   eval      w5lbl# = w3lbl#
500hAC                   eval      w5disp = w3disp
510 DC*                  eval      w5qyfd = w3qyfd
510 MC                   eval      w5qyfd = Nbrqyfd
500hAC                   eval      w5ucod = w3ucod
510 DC*                  eval      w5qyf1 = w3qyf1
510 MC                   eval      w5qyf1 = Nbrqyf1
500hAC                   eval      w5uco1 = w3uco1
510 DC*                  eval      w5qyf2 = w3qyf2
510 MC                   eval      w5qyf2 = Nbrqyf2
500hAC                   eval      w5uco2 = w3uco2
510cD*
510cDC*                  if        client = EI
510cDC*                  eval      w5box# = obbox#
510cD*      If box nbr found, protect it.
510cDC*                  if        w5box# > 0
510cDC*                  eval      *in90 = *on
510cDC*                  endif
510cD*
510cDC*                  else
510cAC                   eval      *in90 = *off
500hAC                   eval      w5box# = *zeros
510cDC*                  endif
500hA*
500hAC                   endsr
     *
520 A*----------------------------------------------------------------
520 A*
520 A*  ZZFIL6   Fill screen 6 fields.
520 A*
520 AC     zzfil6        begsr
     *
     C                   eval      w6conf = ' '
     C                   eval      w6lbl# = w3lbl#
     C                   eval      w6disp = w3disp
     C                   eval      w6qyso = w3qyso
     C                   eval      w6uco3 = w3uco3
     C                   eval      w6qyfd = Nbrqyfd
     C                   eval      w6ucod = w3ucod
     C                   eval      w6qyf1 = Nbrqyf1
     C                   eval      w6uco1 = w3uco1
     C                   eval      w6qyf2 = Nbrqyf2
     C                   eval      w6uco2 = w3uco2

     C                   endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZFIL7   Fill screen 7 fields.
650bA*
650bAC     zzfil7        begsr
     *
650bAC                   eval      w7lbl# = w2lbl#
650bAC                   eval      w7disp = w2disp
650bAC                   eval      w7qyfd = Nbrqyfd
650bAC                   eval      w7ucod = lbucod
650bAC                   eval      w3qyso = ruqyso
650bA * Check to see if UCI's are scanned for this label
650bA*  UCI count

650bA /free
650bA    // Counts UCI's previously scanned for this label

650bA    exsr clr$uciinfo;
650bA    $uiwhse = lbwhse;
650bA    $uiitem = lbItem;
650bA    $uisellbl# = w2lbl#;
650bA    $uiseltrn# = lbtrn#;
650bA    $uirtntrn# = w1trn#;
650bA
650bA    $dricommand = '*UCIINFO';
650bA    $drisubcmd  = '*CNT4RUN';
650bA    $drisys2upd = 'D';
650bA    exsr zzzdricop;
650bA    // message will have the count
650bA    w7qyfd  = %dec($drimessage:5:0);
650bA /end-free

650bAC                   endsr
     *----------------------------------------------------------------
EIb A*
EIb A*  ZZFIL20  Fill screen 20 fields with info from file.
EIb A*
EIb AC     zzfil20       begsr
EIb A*
EIb AC                   eval      w20emp = 0
EIb A*
EIb AC                   endsr
EIb A*
     *----------------------------------------------------------------
     *
     *  ZZGet2   Get  PIR employee master record.
     *
     C     zzget2        begsr
     *
     C     #top2         tag
     *
     C     rukey         reade     runner3
     *
     C                   select
     C                   when      %eof(runner3)
     C     rukey         setll     runner3
     *
     C                   select
     *    Not all flag entries closed. Start at top again.
     C                   when      %equal(runner3)
     C                   eval      skip2 = *off
     C                   goto      #top2
     *
     *    No records found - End Clear Runner Flags.
     C                   when      not %equal(runner3)
     C                   eval      nomore = *on
     C                   endsl
     *
     *  Runner flag entry found.
     C                   when      not %eof(runner3)
     *
     C                   endsl
     *
     C     endgt2        Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGet3   Get  PIR item master record.
     *
     C     zzget3        begsr
     *
     C     rulbl#        chain (n) label
     C                   if        not %found
     C                   eval      lbitem = ' '
     C                   eval      lblbl# = 0
     C                   eval      lbrte  = ' '
     C                   eval      lbucod = ' '
     C                   endif
     *
     *  Retrieve item description.
     C     Itkey         chain     piritem
     C                   if        Not %found
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
500gAC                   eval      itcwgt = 'N'
     C                   endif
     *
     C     endgt3        Endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZGet4   Get
500hA*
500hAC     zzget4        begsr
500hA*
500hA*
500hAC     endgt4        Endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZGet5   Get
500hA*
500hAC     zzget5        begsr
500hA*
500hA*
500hAC     endgt5        Endsr
     *
     *----------------------------------------------------------------
520 A*
520 A*  ZZGet6   Get
520 A*
520 AC     zzget6        begsr
520 A*
520 A*
520 AC     endgt6        Endsr
     *
     *----------------------------------------------------------------
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZGet7   Get
650bA*
650bAC     zzget7        begsr
650bA*
650bA*
650bAC     endgt7        Endsr
     *
     *----------------------------------------------------------------
EIb A*
EIb A*  ZZGet20  Get
EIb A*
EIb AC     zzget20       begsr
EIb A*
EIb A*
EIb AC     endgt20       Endsr
EIb A*
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
640cAC                   eval      $sprg = #prog
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    rulbl#
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    opcode
     *
520 A*  Define key for OPTIONZ file.
     *
520 AC     *like         define    opzcod        kycode
520 AC     keyopz        klist
520 AC                   kfld                    kycode
520 AC                   kfld                    pswhse
520 AC                   kfld                    pstruk
520 AC                   kfld                    psszon
520 AC
     *
520 A*  Define partial key for OPTIONZ file.
     *
520 AC
520 AC     keyop2        klist
520 AC                   kfld                    kycode
520 AC                   kfld                    pswhse
520 AC                   kfld                    pstruk
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbitem

520 A*  Define key for RTEHED file.
520 AC     rhkey         klist
520 AC                   kfld                    pswhse
520 AC                   kfld                    psrtid
     *
500cA*  Define key for RUNNER file.
500cA*
500cAC     keyru         klist
500cAC                   kfld                    w1whse
500cAC                   kfld                    kytype
500cAC                   kfld                    w2lbl#
     *
     *  Define key for RUNNER1 file.
     *
500cAC     *like         define    rutype        kytype
     C     rukey         klist
     C                   kfld                    w1whse
500cAC                   kfld                    kytype
     C                   kfld                    w1trn#
CBIbA*
CBIbA*  Define key for RTEHED file.
CBIbA*
CBIbAC     rtkey         klist
CBIbAC                   kfld                    w1whse
CBIbAC                   kfld                    lbrte

520 A*  Define key for RUNNER6 file.
     *
520 AC     ru6key        klist
520 AC                   kfld                    w1whse
520 AC                   kfld                    w1lab#
500hA*
500hA*  Define key for ORDDM file.
500hA*
500hAC     orkey         klist
500hAC                   kfld                    lbwhse
500hAC                   kfld                    lbord
500hAC                   kfld                    lbseq
500hAC                   kfld                    lbitem
500lA*
500lA*  Define key for ORDBOX file.
500lA*
500lAC     obkey         klist
500lAC                   kfld                    lbwhse
500lAC                   kfld                    lbord
500lAC                   kfld                    lbseq
500lAC                   kfld                    lbitem
500lAC                   kfld                    rulbl#
640cA*
640cA*  Define key for ORDH file.
640cA*
640cAC     ohkey         klist
640cAC                   kfld                    lbwhse
640cAC                   kfld                    lbord

650bAC     Ockey         KList
650bAC                   Kfld                    Lbwhse
650bAC                   Kfld                    Lbord
650bAC                   Kfld                    Lbseq
650bAC                   Kfld                    Lbitem
650bAC                   Kfld                    Lblbl#

650bAC     OcNkey        Klist
650bAC                   Kfld                    Lbwhse
650bAC                   Kfld                    Lbord
650bAC                   Kfld                    Lbseq
650bAC                   Kfld                    Lbitem
650bAC                   Kfld                    Lblbl#
650bAC                   Kfld                    NewSeq
510dA*
510dA*  Convert today's date into century format.
510dA*
510dAC                   eval      $cvcmd = '*CURCMD '
510dAC                   call      @cvtdt
510dAC                   parm                    $cvtdt
510dAC                   eval      today8 = $cvd8o
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get screen size being used.
     *
     C                   Call      'PIRRFSCR'
     C                   parm      '*GET'        #LCMD             8
     C                   parm                    #LLINE            2
     C                   parm                    #LCOL             3
     *
500fAC                   if        #lline = '00' and #lcol = '000'
500fAC                   eval      #lline  = '16'
500fAC                   eval      #lcol   = '020'
500fAC                   endif
     *
     C                   move      *on           refrsh
     C                   move      *off          more
     C                   move      *off          done
     C                   move      *off          excptn
     C     *like         define    lbtrn#        svtrn#
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
CLD AC                   parm                    #bpu              1
500kA*
500kA* get system high / low variance
500kA*
500kAC                   ExSr      zzgetsyop
     *
     C                   eval      w1whse = #whse
     *
520 AC                   ExSr      zzgetruop
     *
500hAC                   move      *year         TodayYear
500hAC                   move      *month        TodayMonth
500hAC                   move      *day          TodayDay
500hA*
     C                   exsr      scr01i
720hAC                   if        $ptrn > 0 or $plab <> *blanks
720hAC                   exsr      sc1
720hAC                   if        error = *off
720hAC                   exsr      scr02i
720hAC                   endif
720hAC                   endif
     *
     C                   endsr
500lA*
500lA*----------------------------------------------------------------
500lA*
500lA*  ZZCKORDBOX  Check if Box Nbr needs to be captured.
500lA*
500lAC     zzckordbox    begsr
500lA*
500lAC                   select
500lAC                   When      omcbox = 'Y'
510 MC                             and (Nbrqyfd > 0 or Nbrqyf1 > 0 or
510 MC                                  Nbrqyf2 > 0)
510 DC*                            and (w3qyfd > 0 or w3qyf1 > 0 or
510 DC*                                 w3qyf2 > 0)
510cDC*    obkey         chain (n) ordbox
510cDC*                  select
510cDC*                  when      not %found(ordbox)
510cDC*                  eval      obbox# = 0
500lAC                   exsr      scr05i
500lAC
510cDC*                  when      %found(ordbox) and obbox# = *zeros
510cDC*                            or client = EI
510cDC*                  exsr      scr05i
510cDC*                  endsl
500lA*
500lAC                   endsl
500lA*
500lAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETOP  Get General Picking Options record.
     *
     C     zzgetop       begsr
     *
     C                   MOVE      '*GENPICK'    opcode
     *
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      opclrf = 'Y'
     C                   else
     C                   movel     opdata        opdta1
     C                   endif
     *
     C                   endsr
500eA*
500eA*----------------------------------------------------------------
500eA*
500eA*  ZZGETRUOP  Get Runner Options record.
500eA*
500eAC     zzgetruop     begsr
500eA*
500eAC                   eval      opcode = '*RUNNER '
500eA*
500eAC     opkey         chain     options
500eAC                   if        not %found(options)
500eAC                   eval      opclrf = 'Y'
520 AC                   eval      oprscn = '1'
520 AC                   eval      oprvfs = 'N'
520 AC                   eval      oprvfq = 'N'
520 AC                   eval      oprloa = 'N'
750aAC                   eval      opscnl = 'N'
500eAC                   else
500eAC                   movel     opdata        oprdta
500eAC                   endif
500eA*
520 AC                   if        oprscn = '1'
520 AC                   eval      *in41 = '1'
520 AC                   endif
520 A*
520 AC                   if        oprloa = 'Y'
520 AC                   eval      *in95 = '1'
520 AC                   endif
520 A*
520 AC                   if        oprvfs = 'Y'
520 AC                   eval      *in42 = '1'
520 AC                   endif
520 A*
500eAC                   endsr
500kA*
500kA*----------------------------------------------------------------
500kA*
500kA*  ZZGETSYOP  Get System Options record.
500kA*
500kAC     zzgetsyop     begsr
500kA*
500kAC                   eval      opcode = '*SYSTEM '
500kA*
500kAC                   eval      w1whse = *zeros
500kA*
500kAC     opkey         chain     options
500kAC                   if        not %found(options)
500kAC                   eval      opwrnc = 'N'
500kAC                   eval      oprg1c = *zeros
500kAC                   eval      oprg2c = *zeros
610aAC                   eval      opuci  = 'N'
500kAC                   else
500kAC                   movel     opdata        opdta2
500kAC                   endif
500kA*
500kAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNRFLAGS  Check Runner file for any Flags at Picked status.
     *
     C     zznrflags     begsr
     *
     C     rukey         setll     Runner3
     C                   Dow       Forever = Forever
     C     rukey         reade     Runner3
     C                   Select
     C                   When      %eof(runner3)
     C                   Leave
     *
     C                   when      rustat = 'P'
720bAC                             or rustat = 'U'
     C                   Eval      w2nrsn = w2nrsn + 1
     C                   Endsl
     C                   Enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   move      *off          error
     *
     *  On to screen 2...
500eA *****              exsr      zzgetop
500eA*     Get *RUNNER options record.
500eAC                   if        w1whse <> svwhse
500eAC                   exsr      zzgetruop
500eAC                   eval      svwhse = w1whse
500eAC                   endif
     C                   eval      w2nrsn = 0
     C                   eval      nomore = *off
     C                   exsr      zznrflags
     *
     *  Flags remaining to be cleared under this transaction #.
     C                   if        w2nrsn > 0
     *
EIb A*  For specified clients, go to screen20 before screen2
EIb AC                   if        client = EI
EIb AC                   exsr      scr20i
EIb AC                   goto      endup1
EIb AC                   endif
     *
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     *
     *  Send message RUNNER flags all cleared.
     C                   else
     C                   eval      refrsh = *off
     C                   eval      error  = *on
     C                   eval      *in22  = *on
     C                   eval      *in02  = *on
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     *
     C                   move      *off          error
     *
650bA*    Determine if UCI screen should display
650bA* Add DRI to get data from ITEMFLD
650bA /free
650bA   exsr getitem;
650bA   if $ifsltmth = '2';
650bA     exsr scr07i;
650bA   else;
650bA     exsr scr03i;
650bA   endif;
650bA /end-free
650bA*    Proceed to third screen. Enter qty found and update flag.
650bDC*                  exsr      scr03i
     *
     C     endupd2       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 2.
     *
     C     zzupd3        begsr
     *
     C                   move      *off          error
     *
500cDC*    W2lbl#        chain     Runner
500cMC     keyru         chain     Runner
     C                   If        Not %found(Runner)
     C                   eval      error  = *on
     C                   movel     desc(8)       errmsg
     C                   exsr      zm0105
     *
     C                   Else
     *
520 AC                   eval      sv_ruotrn = ruotrn
     *
640dA*    Flag record has already been closed.
640dAC                   Select
640dAC                   When      Rustat = 'C'
640dAC                   move      *on           error
640dAC                   eval      *in23 = *on
640dAC                   eval      *in03 = *on
640dAC                   movel     desc(9)       errmsg
640dAC                   exsr      zm0105
640dA*
640dAC                   Other
     *
     *  Update Runner flag entry as closed.

CBIiAC                   if        client = Cheney
720aAC                   if        (rutype = 'N' or rutype = 'M')
720aAC                             and nbrqyfd > 0 and rustat <> 'S'
720aAC                   eval      rustat = 'S'
720aAC                   else
CBIiAC                   Eval      Rustat = 'C'
CBIiAC                   endif
CBIiAC                   else
     C                   Eval      Rustat = 'C'
720aAC                   endif

750aA*  If opscnl = Y and qty found, check to see if short has been
750aA*  scanned to loader, if so, leave runner status as 'C', if not,
750aA*  set to new status 'L'.

750aA /free
750aA   if opscnl = 'Y' and (Nbrqyfd > 0 or Nbrqyf1 > 0 or Nbrqyf2 > 0);
750aA     rhrte = ' ';
750aA     chain (w1whse: lbrte) rtehed;
750aA     chain (lbwhse: rhrte: lblbl#: lbitem) ldrovrf2;
750aA     if not %found(ldrovrf2);
750aA       rustat = 'L';
750aA     endif;
750aA   endif;
750aA /end-free

510 DC*                  Eval      Ruqyfd = w3qyfd
510 MC                   Eval      Ruqyfd = Nbrqyfd
     C                   time                    currstamp
     C                   Eval      Rucdts = Currstamp
     *
     C                   Update    Rurec
     C                   If        %Error
     C                   eval      error  = *on
     C                   eval      errmsg = desc(11) + ' ' +
     C                               %trim(%editc(w2lbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
640dAC                   Endsl
     C                   Endif
     *
     *    No errors - proceed to update LABEL record.
     C                   If        Error = *off
     C                   sub       1             w2nrsn
     *
     *    Compute difference. See if any qty not found.
     C                   Eval      qtychg = ruqyso - ruqyfd
500eA
500eAC                   If        opclsf = 'Y' and lbtype <> 'M'
500eAC                   eval      $pcmd = '*CLSFLAG'
500eAC                   eval      $plbl# = W2lbl#
500jA*
500jA*    Send net quantity not found to reduce Label pick qty.
500jAC                   if        opuplr = 'N'
500jAC                   eval      $pqty = qtychg
500jAC                   else
500eAC                   eval      $pqty = ruqyfd
500jAC                   endif
500eAC                   call      'PT132PL'
500eAC                   parm                    $pcmd
500eAC                   parm                    $plbl#
500eAC                   parm                    $pqty
500eAC                   endif
500eA
500cA*
500cA*    Only partial qty found and clear flag is N=No.
500cA*     Create Flag Type U=Out.
500cAC                   if        opclrf = 'N'
500cAC                             and kytype = 'N'
500cAC                             and qtychg <> 0
500cAC                   eval      rutype = 'U'
500cAC                   eval      rutrn# = 0
500cAC                   eval      ruqyso = qtychg
500cAC                   eval      ruqyfd = 0
500cAC                   eval      rustat = 'O'
500cAC                   time                    currstamp
500cAC                   eval      ruodts = currstamp
500cAC                   eval      rupdts = dftstamp
500cAC                   eval      rucdts = dftstamp
500cAC*
500cAC                   write     rurec
500cAC                   endif
     *
     *    Update LABEL record and update flag.
     C     W2lbl#        chain     Label
     C                   Select
     C                   When      not %found(Label)
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Label)
     *
     *    Label not flagged yet.
     C                   Select
     C                   When      Lbvrfy <> 'F'
500cAC                             and Lbvrfy <> 'I'
500cAC                             and lbstat <> 'C'
     C                   unlock    label
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     desc(6)       errmsg
     C                   exsr      zm0105
     *
     *    Label already closed.
500cA*     Don't flag error if label closed. Allow Runner
500cA*     Flag to be cleared.
     C                   When      Lbstat = 'C'
     C                   unlock    label
500cDC*                  eval      error = *on
500cDC*                  eval      *in22 = *on
500cDC*                  eval      *in02 = *on
500cDC*                  movel     desc(7)       errmsg
500cDC*                  exsr      zm0105
     *
     *    Label ok to update.
     C                   When      Lbstat = 'P' and lbvrfy = 'F'
500cAC                             or Lbstat = 'P' and lbvrfy = 'I'
     *
     *    Qty still short/out. Update flag to 'I' for Inventory
     *    Control to try and find. If still short/out, flag to be
     *    cleared by route close program pt132.
     C                   if        opclrf = 'N'
     C                             and qtychg <> 0
510aAC                             and lbtype <> 'M'
     C                   eval      lbvrfy = 'I'
     C                   else
CBIbA*
CBIbAC                   select
CBIbAC                   when      client = Cheney
CBIbAC                   if            lbvrfy = 'I'
CBIbAC                             and qtychg <> 0
CBIbA*      Runner Flag Type U, qty still short. Do not clear.
CBIbAC                   else
CBIbAC                   eval      lbvrfy = 'T'
CBIbAC                   endif
CBIbA*
CBIbAC                   other
CBIbA*
500bMC                   eval      lbvrfy = 'T'
500bDC*                  eval      lbvrfy = ' '
CBIbAC                   endsl
CBIbA*
     C                   endif
     *
     C                   update    lbrec
500fAC                   eval      $plbl  = lblbl#
510 DC*                  eval      $pqyfd = w3qyfd
510 MC                   eval      $pqyfd = Nbrqyfd
     C                   eval      $lwhse = w1whse

650bAc* Don't execute catch weight programs if UCI selection
650bAc                   if        $ifsltmth = '2'
650bAc                   else
510 DC*                  if        w3qyfd <> *zeros
510 MC                   if        Nbrqyfd <> *zeros
500gAC                             and itcwgt = 'Y'
500fAC     itkey         chain     itemmsc
500fAC                   if        not %found(itemmsc)
500fAC                   eval      imrg1c = *zeros
500fAC                   eval      imrg2c = *zeros
500fAC                   endif

500kAC                   eval      prg1c = *zeros
500kAC                   eval      prg2c = *zeros
500kAC                   eval      $plcwgt = *zeros
500kAC                   eval      $phcwgt = *zeros

500kAC                   If        imrg1c <> *zeros
500kAC                   eval      prg1c = imrg1c / 100
500kAC                   endif

500kAC                   If        imrg2c <> *zeros
500kAC                   eval      prg2c = imrg2c / 100
500kAC                   endif

500kAC                   if        prg1c = *zeros
500kAC                   eval      prg1c = oprg1c / 100
500kAC                   endif

500kAC                   if        prg2c = *zeros
500kAC                   eval      prg2c = oprg2c / 100
500kAC                   endif

500fA * Calc low catch weight Variance
500kDC**                 eval      $pwcwgt = lbuwgt * imrg1c
500kMC                   eval      $pwcwgt = lbuwgt * prg1c
500fAC                   eval      $plcwgt = lbuwgt - $pwcwgt

500fA * Calc high catch weight Variance
500kDC**                 eval      $pwcwgt = lbuwgt * imrg2c
500kMC                   eval      $pwcwgt = lbuwgt * prg2c
500fAC                   eval      $phcwgt = lbuwgt + $pwcwgt

720fAC                   eval      gPltId = lbpal#
720fAC                   exsr      GetGenInfo

500gDC*                  if        w3qyfd <> *zeros
CBIaAC                   if        client <> cheney
PAK AC******                       and client <> packers
610aAC                             and opuci  <> 'Y'
CBIaAC                             and w3qyfd <> *zeros
CBIaAC                             or client = cheney
720fDC**                           and lbpal# < 20000
720fMC                             and gGenTruck
CBIaAC                             and w3qyfd <> *zeros
500fAC                   call      @catchwgt
500fAC                   parm                    $lparm
CBIaAC                   endif
PAK AC*****              if        client = packers
610aAC                   if        opuci  = 'Y'
PAK AC                   eval      $lcmd = '*PICK   '
PAK AC                   call      @catchwgt2
PAK AC                   parm                    $lparm
PAK AC                   endif
500fAC                   endif
     *
650bAc                   endif
     C                   If        %Error
     C                   eval      error = *on
     C                   Eval      errmsg = desc(14) + ' ' +
     C                               %trim(%editc(w2lbl#: '4'))
     C                   exsr      zm7872
     C                   Endif
     *
     C                   Endsl
     *
     C                   Endsl

500fA * Create label for breakdown 1 quantity.

510 DC*                  if        oprbdu = 'Y' and w3qyf1 <> *zeros
510 MC                   if        oprbdu = 'Y' and Nbrqyf1 <> *zeros
500fAC                                          and $perror = *blanks
500fAC                   eval      lbutyp = '1'
500fAC                   eval      lbucod = itum2
500fAC                   if        itumq2 <> *zeros
500fAC                   eval(h)   lbucub = itcube / itumq2
510 DC*                  eval      lbcube = lbucub * w3qyf1
510 MC                   eval      lbcube = lbucub * Nbrqyf1
510 DC*                  eval(h)   lbuwgt = itswgt / w3qyf1
510 MC                   eval(h)   lbuwgt = itswgt / Nbrqyf1
510 DC*                  eval      lbswgt = lbuwgt * w3qyf1
510 MC                   eval      lbswgt = lbuwgt * Nbrqyf1
500fAC                   endif
500fAC                   call      'PIRLBL#'
500fAC                   parm                    lblbl#
500fAC                   If        opclsf = 'Y'
500fAC                   eval      lbqpck = *zeros
500fAC                   endif
500fAC                   write     lbrec

     * Update slot quantities
500fA
500fAC                   If        opclsf = 'Y' and lbtype <> 'M'
500fAC                   eval      $pcmd = '*CLSFLAG'
500fAC                   eval      $plbl# = lblbl#
510 DC*                  eval      $pqty = w3qyf1
510 MC                   eval      $pqty = Nbrqyf1
500fAC                   call      'PT132PL'
500fAC                   parm                    $pcmd
500fAC                   parm                    $plbl#
500fAC                   parm                    $pqty
500fAC                   endif

500fA * update PIRTRAN record

510 DC*                  eval      @ppcs = w3qyf1
510 MC                   eval      @ppcs = Nbrqyf1
500fAC                   exsr      zzupd3a

500fAC                   eval      rulbl# = lblbl#
510 DC*                  eval      ruqyfd = w3qyf1
510 MC                   eval      ruqyfd = Nbrqyf1
500fAC                   eval      ruoqys = *zeros
500fAC                   eval      ruqyso = *zeros
500fAC                   write     rurec

500fAC                   eval      $plbl  = lblbl#
510 DC*                  eval      $pqyfd = w3qyf1
510 MC                   eval      $pqyfd = Nbrqyf1
     C                   eval      $lwhse = w1whse

510 DC*                  if        w3qyf1 <> *zeros
510 MC                   if        Nbrqyf1 <> *zeros
500gAC                             and itcwgt = 'Y'
500kAC                   eval      $plcwgt = *zeros
500kAC                   eval      $phcwgt = *zeros
500fA * Calc low catch weight Variance
500kAC                   if        prg1c <> *zeros
500kDC**                 eval      $pwcwgt = lbuwgt * imrg1c
500kMC                   eval      $pwcwgt = lbuwgt * prg1c
500fAC                   eval      $plcwgt = lbuwgt - $pwcwgt
500kAC                   endif

500fA * Calc high catch weight Variance
500kAC                   if        prg2c <> *zeros
500kDC**                 eval      $pwcwgt = lbuwgt * imrg2c
500kMC                   eval      $pwcwgt = lbuwgt * prg2c
500fAC                   eval      $phcwgt = lbuwgt + $pwcwgt
500kAC                   endif

720fAC                   eval      gPltId = lbpal#
720fAC                   exsr      GetGenInfo

CBIaAC                   if        client <> cheney
PAK AC******                       and client <> packers
610aAC                             and opuci  <> 'Y'
CBIaAC                             or client = cheney
720fDC**                           and lbpal# < 20000
720fMC                             and gGenTruck
500fAC                   call      @catchwgt
500fAC                   parm                    $lparm
CBIaAC                   endif
610aAC                   if        opuci  = 'Y'
PAK AC******             if        client = packers
PAK AC                   eval      $lcmd = '*PICK   '
PAK AC                   call      @catchwgt2
PAK AC                   parm                    $lparm
PAK AC                   endif
500gAC                   endif
500fAC                   endif

500fA * Create label for breakdown 2 quantity.

510 DC*                  if        oprbdu = 'Y' and w3qyf2 <> *zeros
510 MC                   if        oprbdu = 'Y' and Nbrqyf2 <> *zeros
500fAC                                          and $perror = *blanks
500fAC                   eval      lbutyp = '2'
500fAC                   eval      lbucod = itum3
500fAC                   if        itumq2 <> *zeros and itumq3 <> *zeros
500fAC                   eval(h)   lbucub = itcube / itumq2
500fAC                   eval(h)   lbucub = lbucub / itumq3
510 DC*                  eval      lbcube = lbucub * w3qyf2
510 MC                   eval      lbcube = lbucub * Nbrqyf2
500fAC                   eval(h)   lbuwgt = itswgt / itumq2
500fAC                   eval(h)   lbuwgt = lbuwgt / itumq3
510 DC*                  eval      lbswgt = lbuwgt * w3qyf2
510 MC                   eval      lbswgt = lbuwgt * Nbrqyf2
500fAC                   endif
510 DC*                  eval      lbqpck = w3qyf2
510 MC                   eval      lbqpck = Nbrqyf2
500fAC                   call      'PIRLBL#'
500fAC                   parm                    lblbl#
500fAC                   write     lbrec

     * Update slot quantities
500fA
500fAC                   If        opclsf = 'Y' and lbtype <> 'M'
500fAC                   eval      $pcmd = '*CLSFLAG'
500fAC                   eval      $plbl# = lblbl#
510 DC*                  eval      $pqty = w3qyf2
510 MC                   eval      $pqty = Nbrqyf2
500fAC                   call      'PT132PL'
500fAC                   parm                    $pcmd
500fAC                   parm                    $plbl#
500fAC                   parm                    $pqty
500fAC                   endif

500fA * update PIRTRAN record

510 DC*                  eval      @ppcs = w3qyf1
510 MC                   eval      @ppcs = Nbrqyf1
500fAC                   exsr      zzupd3a

500fAC                   eval      rulbl# = lblbl#
510 DC*                  eval      ruqyfd = w3qyf2
510 MC                   eval      ruqyfd = Nbrqyf2
500fAC                   eval      ruoqys = *zeros
500fAC                   eval      ruqyso = *zeros
500fAC                   write     rurec
500fAC                   eval      $plbl  = lblbl#
510 DC*                  eval      $pqyfd = w3qyf2
510 MC                   eval      $pqyfd = Nbrqyf2
     C                   eval      $lwhse = w1whse

510 DC*                  if        w3qyf2 <> *zeros
510 MC                   if        Nbrqyf2 <> *zeros
500gAC                             and itcwgt = 'Y'
500kAC                   eval      $plcwgt = *zeros
500kAC                   eval      $phcwgt = *zeros
500fA * Calc low catch weight Variance
500kAC                   if        prg1c <> *zeros
500kDC**                 eval      $pwcwgt = lbuwgt * imrg1c
500kMC                   eval      $pwcwgt = lbuwgt * prg1c
500fAC                   eval      $plcwgt = lbuwgt - $pwcwgt
500kAC                   endif

500fA * Calc high catch weight Variance
500kAC                   if        prg2c <> *zeros
500kDC**                 eval      $pwcwgt = lbuwgt * imrg2c
500kMC                   eval      $pwcwgt = lbuwgt * prg2c
500fAC                   eval      $phcwgt = lbuwgt + $pwcwgt
500kAC                   endif

720fAC                   eval      gPltId = lbpal#
720fAC                   exsr      GetGenInfo

CBIaAC                   if        client <> cheney
PAK AC*****                        and client <> packers
610aAC                             and opuci  <> 'Y'
CBIaAC                             or client = cheney
720fDC**                           and lbpal# < 20000
720fMC                             and gGenTruck
500fAC                   call      @catchwgt
500fAC                   parm                    $lparm
CBIaAC                   endif
PAK AC*****              if        client = packers
610aAC                   if        opuci  = 'Y'
PAK AC                   eval      $lcmd = '*PICK   '
PAK AC                   call      @catchwgt2
PAK AC                   parm                    $lparm
PAK AC                   endif
500gAC                   endif
500fAC                   endif
416eA*
416eA*      Write record to item exception file for zero override.
416eA*
510aMC                   if        zeroovr = *on
416eAC                   clear                   exrec
416eaC                   eval      extask = 'RUNNER'
510eAC                   eval      exerid = 'OVRZRO'
416eAC                   eval      exwhse = lbwhse
416eAC                   eval      exwhdp = lbwhdp
416eAC                   eval      exstyp = lbstyp
416eAC                   eval      exitem = lbitem
416eAC                   eval      dsrtrn# = rutrn#
416eAC                   eval      dsptrn# = lbtrn#
416eAC                   eval      dsplbl# = lblbl#
416eAC                   eval      exfdis = dsfdis
416eAC                   eval      extdis = dstdis
416eAC                   eval      exgdte = today8
416eAC                   time                    exgtim
416eAC                   eval      exgby = #user
416eAC                   eval      exesta = '1'
416eAC                   write     exrec
416eAC                   endif
     *
500hAC     orkey         chain     orddm
500hA
500hAC                   Select
500iA*    Capture Expiration Date for item.
500hAC                   When      %found(orddm) and OMCEXP = 'Y'
510 MC                             and (Nbrqyfd > 0 or Nbrqyf1 > 0 or
510 MC                                  Nbrqyf2 > 0)
510 DC*                            and (w3qyfd > 0 or w3qyf1 > 0 or
510 DC*                                 w3qyf2 > 0)
500lDC*    orkey         chain     ordexpdte
510bDC**   orkey         chain (n) ordexpdte
510bMC     obkey         chain (n) ordexpdte
510bD***                 if        not %found(ordexpdte)
510bD***                 exsr      scr04i
510bD***                 endif
510bD***                 if        %found(ordexpdte) and oedate = *zeros
510bD***                 exsr      scr04i
510bD***                 else
510bD***                 exsr      zzckordbox
510bD***                 endif
510bMC                   select
510bMC                   when      not %found(ordexpdte)
510bMC                   exsr      scr04i
500bMC                   when      %found(ordexpdte) and oedate = *zeros
510bMC                   exsr      scr04i
510bMC                   other
510bMC                   exsr      zzckordbox
510bMC                   endsl
500hA
500iA*    Capture Box Number for item.
500iAC                   When      %found(orddm) and OMCBOX = 'Y'
510 MC                             and (Nbrqyfd > 0 or Nbrqyf1 > 0 or
510 MC                                  Nbrqyf2 > 0)
510 DC*                            and (w3qyfd > 0 or w3qyf1 > 0 or
510 DC*                                 w3qyf2 > 0)
500lDC*    orkey         chain     ordbox
510cDC*    obkey         chain (n) ordbox
510cDC*                  if        not %found(ordbox)
510cDC*                  eval      obbox# = 0
500iAC                   exsr      scr05i
510cDC*                  endif
510cDC*                  if        %found(ordbox) and obbox# = *zeros
510cDC*                            or client = EI
510cDC*                  exsr      scr05i
510cDC*                  endif
500iA
500hAC                   other
640cA
710fD*** If no qty found, see if substitutes are allowed.
710fM*   If less than orig qty found, see if substitutes are allowed.
640cA*
710fDC**                 if            nbrqyfd = 0
710fDC**                           and nbrqyf1 = 0
710fDC**                           and nbrqyf2 = 0
710fMC                   if            nbrqyfd < ruqyso
710fMC                             and nbrqyf1 < ruqyso
710fMC                             and nbrqyf2 < ruqyso
HMW AC                             and client <> HMWagner
640cAC                   eval      $scmd = '*SUB    '
640cAC                   eval      $swhse = lbwhse
640cAC                   eval      $srte = lbrte
640cAC                   eval      $scord = 0
640cAC                   eval      $sord = lbord
640cAC                   eval      $sseq = lbseq
640cAC                   eval      $sitem = lbitem
640cA
640cAC     ohkey         chain     ordh
640cAC                   if        not %found
640cAC                   eval      errmsg = 'Order header not found'
640cAC                   exsr      zm0105
640cAC                   else
640cAC                   eval      $cmd = '*GET      '
640cAC                   eval      $whs30 = $swhse
640cAC                   call      'GETITEMSUB'
640cAC                   parm                    $cmd
640cAC                   parm                    $whs30            3 0
640cAC                   parm                    $sitem
640cAC                   parm                    ohcust
640cAC                   parm                    $isub
640cAC                   parm                    $srtn
640cAC                   parm                    $serm
640cAC                   endif
640cA
640cA*   If subs are allowed, call the item substitute program.
700aA*   If a sub it is not defined, user can press F6=Sub.
640cA*
640cAC                   if        $srtn = '*OK     '
700aDC**                           and $isub <> *blanks
700aMC                   if        $isub <> *blanks
700aAC                             or *inkf = *on
CWD A*
CWD AC                             or  client = CashWa
CWD AC                             and $srtn = '*OK     '
CWD A*
640cAC                   eval      $scmd = '*SUBRUN '
640cAC                   call      'RH182'
640cAC                   parm                    $sparm
640cAC                   parm                    $isub
700aAC                   endif
640cAC                   endif
640cAC                   endif

710dA /free
710dA   exsr runnerdone;
710dA /end-free

730aA*   See if order audit report should be printed.
730aA
730aA /free
730aA   monitor;
730aA     prtordaud ('*PRTORDER': 'Y': lbwhse: '': lbord:
730aA                outRtnCode: outRtnMsg);
730aA   on-error;
730aA   endmon;
730aA /end-free

     *       Display next flag entry to be found.
     C                   if        error = *off
CBIgAC                   if        client = Cheney
CBIgAC                             and w2nrsn = 0
CBIgAC                   move      'EOJ'         nxtscr
CBIgAC                   else
     C                   eval      refrsh = *on
     C                   exsr      scr02i
CBIgAC                   endif
     C                   endif
500hAC                   endsl
     *
     C                   Endif
     *
     C     endup3        endsr
500fA*
500fA*----------------------------------------------------------------
500fA*
500fA*  ZZUPD3a  Update pirtran record
500fA*
500fAC     zzupd3a       begsr

500fA*    - Update totals in trans.

500fAC                   call      @adjt2
500fAC                   parm      '*INCTTL '    @pcmd
500fAC                   parm      #job          @pprg
500fAC                   parm      '*INTER  '    @ptype
500fAC                   parm      pttrn#        @ptrn#
500fAC                   parm      'PUTRTN'      @ptask
500fAC                   parm      w1whse        @pwhse
500fAC                   parm      *blanks       @pwhdp
500fAC                   parm      lBstyp        @pstyp
500fAC                   parm      lbcube        @pcube
500fAC                   parm      lbswgt        @pswgt
500fAC                   parm                    @ppcs
500fAC                   parm      0             @paisl
500fAC                   parm      0             @pqty1
500fAC                   parm      0             @pqty2
500fAC                   parm      0             @pqty3
500fAC                   parm      ' '           @prte
500fAC                   parm      ' '           @ppo
500fAC                   parm      'R'           @pgrp1
500fAC                   parm      ' '           @pgrp2
500fAC                   parm      0             @pdate
500fAC                   parm      0             @ptime
500fAC                   parm      #user         @puser
500fAC                   parm      ' '           @prtn
500fAC                   parm      ' '           @pmsg
500fA*
500fAC                   endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZUPD4   Update for screen 4.
500hA*
500hAC     zzupd4        begsr

510bD***   orkey         chain     ordexpdte
510bMC     obkey         chain     ordexpdte
500hAC                   select
500hAC                   when      not %found(ordexpdte)
500hAC                   eval      oewhse = lbwhse
500hAC                   eval      oeord  = lbord
500hAC                   eval      oeseq# = lbseq
500hAC                   eval      oeitem = lbitem
500hAC                   eval      oetran = w1trn#
500hAC                   eval      oelbl# = lblbl#
500hAC                   eval      oedate = w4date
500hAC                   write     oerec

500hAC                   when      %found(ordexpdte)
500hAC                   eval      oetran = w1trn#
500hAC                   eval      oelbl# = lblbl#
500hAC                   eval      oedate = w4date
500hAC                   update    oerec
500hAC                   endsl

500hAC                   If        %found(orddm) and OMCBOX = 'Y'
510cAC                             and (Nbrqyfd > 0 or Nbrqyf1 > 0 or
510cAC                                  Nbrqyf2 > 0)

500lDC*    orkey         chain     ordbox
510cDC*    obkey         chain (n) ordbox
510cDC*                  Select
510cDC*                  when      not %found(ordbox)
510cDC*                  eval      obbox# = 0
510cDC*                  exsr      scr05i
510cDC*                  when      %found(ordbox) and obbox# = *zeros
510cDC*                            or client = EI
500hAC                   exsr      scr05i
510cDC*                  other
510cDC*                  exsr      scr02i
510cDC*                  endsl
500iA
500iAC                   else
500iA*  Retrieve next flag.
500iAC                   exsr      scr02i

500hAC                   endif

500hAC     endupd4       endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZUPD5   Update for screen 5.
500hA*
500hAC     zzupd5        begsr

500lDC*    orkey         chain     ordbox
510cDC*    obkey         chain     ordbox
510cDC*                  Select
510cDC*                  when      not %found(ordbox)
510cDC*                            and client <> EI
510cD*
510cDC*                            or client = EI
510cDC*                            and not %found(ordbox)
510cDC*                            and w5box# > 0
510cD*
500hAC                   eval      obwhse = lbwhse
500hAC                   eval      obord  = lbord
500hAC                   eval      obseq# = lbseq
500hAC                   eval      obitem = lbitem
500hAC                   eval      obtran = w1trn#
500hAC                   eval      oblbl# = lblbl#
500hAC                   eval      obbox# = w5box#
500hAC                   write     obrec
510cDC*                  when      %found(ordbox)
510cDC*                  eval      obtran = w1trn#
510cDC*                  eval      oblbl# = lblbl#
510cDC*                  eval      obbox# = w5box#
510cDC*                  update    obrec
510cDC*                  endsl

510cDC*                  if        error = *off
510cDC*                  eval      refrsh = *on
510cDC*                  exsr      scr02i
510cDC*                  endif
510cA*
510cA*      Redisplay Box Entry screen to allow more boxes to be entered.
510cA*      Exit from box Entry screen will be via F3/F12.
510cAC                   eval      w5box# = 0

500hAC     endupd5       endsr

520 A*----------------------------------------------------------------
520 A*
520 A*  ZZUPD6   Update for screen 6.
520 A*
520 AC     zzupd6        begsr

520 A*   Go see if belt printer user, if so, print short/runner label.
     *
520 AC                   if        Nbrqyfd > 0
520 AC                             or Nbrqyf1 > 0
520 AC                             or Nbrqyf2 > 0
520 AC                   exsr      getprintopt
520 AC                   endif
     *
520 A*    Proceed to screen 1.
520 AC***520aD           exsr      scr01i
     *
520aA*       Display next flag entry to be found.
520aAC                   if        error = *off
520aAC                   eval      refrsh = *on
520aAC                   exsr      scr02i
520aAC                   endif
     *
520 AC     endupd6       endsr

650bA*----------------------------------------------------------------
650bA*
650bA*  ZZUPD7   Update for screen 7.
650bA*
650bAC     zzupd7        begsr

650bA /free
650bA   w7qyfd = w7qyfd + 1;
650bA   Nbrqyfd = w7qyfd;
650bA /end-free
650bA*
650bAC     endupd7       endsr

650bA*----------------------------------------------------------------
650bA*
650bA*  ZZUPD8   Update for screen 8.
650bA*
650bAC     zzupd8        begsr
650bAc                   exsr      zzupd3

     *
650bAC     endupd8       endsr

     *----------------------------------------------------------------
EIb A*
EIb A*  ZZUPD20  Update for screen 20.
EIb A*
EIb AC     zzupd20       begsr
EIb A*
EIb AC                   move      *off          error
EIb A*
EIb AC     w1trn#        chain     pirtran
EIb AC                   if        %found(pirtran) and
EIb AC                             pttask = 'RUNNER'
EIb AC                   eval      ptemp# = w20emp
EIc AC                   eval      ptcrew = w20crew
EIc AC                   eval      ptshft = w20shft
EIb AC                   update    ptrec
EIb AC                   endif
EIb A*
EIb AC                   eval      refrsh = *on
EIb AC                   exsr      scr02i
EIb A*
EIb AC     endupd20      endsr
EIb A*
510dA*----------------------------------------------------------------
510dA*  zzzdricop  Call DRICOP
510dA*----------------------------------------------------------------
510dA
510dAC     zzzdricop     begsr
     C                   eval      error = *off

520 AC                   select
520 AC                   when      $dricommand = '*EQUIPT'
520 AC                   eval      $dridata = $equipt
520 AC                   when      $dricommand = '*ITEMQTY'
520 AC                   eval      $dridata = $itemqty
650bAC                   when      $dricommand = '*ITEM'
650bAC                   eval      $dridata = $item
650bAC                   eval      $dridata2 = $item2
730cAC                   when      $dricommand = '*SLOT'
730cAC                   eval      $dridata = $slot
730cAC                   eval      $dridata2 = $slot2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $dridata = $uciinfo
720gAC                   eval      $dridata2 = $uciinfo2
520 AC                   endsl
650bAC                   if        $dricommand = '*ITEM'
730cAC                             or $dricommand = '*SLOT'
720gAC                             or $dricommand = '*UCIINFO'
650bAC                   call(e)   'DRICOP'
650bAC                   parm                    $dricommand
650bAC                   parm                    $drisubcmd
650bAC                   parm                    $drisys2upd
650bAC                   parm      #prog         $driprogram
650bAC                   parm      ' '           $drireturn
650bAC                   parm      ' '           $drimessage
650bAC                   parm                    $dridata
650bAC                   parm                    $dridata2
650bAC                   else

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
520 DC**   $itemqty      parm      $itemqty      $dridata
     C                   parm                    $dridata
650bAC                   endif

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

520 AC                   select
520 AC                   when      $dricommand = '*EQUIPT'
520 AC                   eval      $equipt = $dridata
520 AC                   when      $dricommand = '*ITEMQTY'
520 AC                   eval      $itemqty = $dridata
650bAC                   when      $dricommand = '*ITEM'
650bAC                   eval      $item = $dridata
650bAC                   eval      $item2 = $dridata2
730cAC                   when      $dricommand = '*SLOT'
730cAC                   eval      $slot = $dridata
730cAC                   eval      $slot2 = $dridata2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $uciinfo = $dridata
720gAC                   eval      $uciinfo2 = $dridata2
520 AC                   endsl

     C     enddricop     endsr

720fA*----------------------------------------------------------------
720fA*  GetGenInfo    Get pallet generation info
720fA*----------------------------------------------------------------
720fAC     GetGenInfo    begsr
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

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Trn#                                              1
Trn# not found.                                   2
Trn# not RUNNER task                              3
All flags cleared.                                4
Invalid lbl#                                      5
Lbl not flagged.                                  6
Lbl already closed.                               7
Flag rcd not found.                               8
Flag rcd closed.                                  9
Flag being picked.                                10
Label number                                      11
Qty not entered.                                  12
Qty > Short/out qty                               13
Lbl not updated.                                  14
Box#                                              15
Only numbers allowed                              16
Warning: Qty is available                         17
Slot scanned mismatch                             18
Qty not confirmed                                 19
Confirm must be Y or N                            20
No belt printer checked out. Exit and try again.  21
Invalid employee#                                 17
