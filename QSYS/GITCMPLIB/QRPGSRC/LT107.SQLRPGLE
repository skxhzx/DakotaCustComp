      /copy *libl/qcopysrc,hspecs
600aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT107     RF Let-Down - Automated
     *  22 September 2003
     *  Max Blacknik
     *
     *  Notes
     *       8 X 40 screen1 for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    09/22/03  MLB  4.17
     *      - Created.
417aA*    08/11/04  RH   4.17a
     *      - Note: Did not put call to getslotITM in program, code
     *        already loops to find the correct base slot.
     *
500 A*    08/30/04  DAS  5.00
     *      - Converted to ILE.
     *      - Revised to call LT210 to deal with licens plate screens.
     *      - Removed F7=Full from screens 1 & 2.
     *      - Added screen 9 to ask user if he wants to pull any more items
     *
500aA*    10/11/04  DAS  5.00a
     *      - Revised to only close replenishment transaction after all
     *        items have been put away.
     *      - Revised to create a REPLTF transaction for the remaining qty
     *        that needs to be put back.
     *
500bA*    10/15/04  DAS  5.00b
     *      - Changed Pushback to FlowRack and Eaches to Breakdown.
     *      - Changed F12 in SC1 to execute ZZABRT.
     *      - Revised ZZABRT to always reset PRPLFIL record.
     *      - Revised ZZDATE to just work off of opodrp field.
     *
500cA*    01/26/05  DAS  5.00c
     *      - Enh: Split *PUTAWAY into *PUTAWYB / *PUTAWYA.
     *      - Enh: Added new parms to LT210.
     *
500dA*    02/02/05  DAS  5.00d
     *      - Enh: Converted from legacy DRI into ILE DRI.
     *      - Enh: Change all s$ and a$ fields to $sl and $sa fields.
     *      - Enh: Converted to do all starting/ending of transactions
     *        through ADJTRAN2. PT132 is not used anymore.
     *
500eA*    02/15/05  DAS  5.00e
     *      - Enh: Moved license entry into LT210.
     *
500fA*    02/18/05  DAS  5.00f
     *      - Created routine zzputpick, called from zzupd5.
     *
500gA*    02/19/05  DAS  5.00g
     *      - Removed all unused code for clarity.
     *
500hA*    03/06/05  DAS  5.00h
     *      - Added F7=Specific to screen 7 (no more repl).
     *
500iA*    03/25/05  DAS  5.00i
     *      - Added check for *SKIP when returning from LT210 *PULDROP
     *
500jA*    04/10/05  DAS  5.00j
     *      - Revised ZZUPD9 to not update CUR fields until after *PULRTN
     *        was done.
     *      - Revised ZZUPD9 to call ZZGET1 and update CUR fields after
     *        a new record was retrieved from ZZNXT1.
     *      - Revised ZZNEXT to do a SETLL when UPDRPLREC = *OFF.
     *        Otherwise, a PRPLFIL record was being skipped each time.
     *      - Revised ZZGETWORKREC to use file WORKRPL2.
     *
500kA*    04/10/05  DAS  5.00k
     *      - Revised calls to ZZZDRICOP to look at DRIERR instead of ERROR
     *
500lA*    04/11/05  DAS  5.00l
     *      - Revised to do a better job of verifing entered quantites
     *        before trying to use them. In some cases we were getting
     *        an error that  use them. In some cases we were getting a
     *        "target to small" error.
     *
500mA*    04/11/05  DAS  5.00m
     *      - Revised to get tracking information.
     *      - Revised force leftover back to original slot when the
     *        original slot has multiple pallet positions.
     *        Re: This has been done to try and keep all of the pallet
     *        positions of the original slot in synch.
     *
500nA*    04/12/05  DAS  5.00n
     *      - Revised look for more replenishments when Enter is pressed
     *        on screen 7.
     *      - Revised skip SC1 if we are still on the same slot.
     *      - Revised to skip SC2 and set W2NQTY to the slot qty.
     *        Re: User always takes entire pallet, so there is no need for
     *        him to enter qty. Plus, we always want to pull entire slot
     *        quantity in order to update license history correctly.
     *      - Revised to never display SC9 asking user if he wants to pull
     *        another item. Re: Decided to only replenish one item at a
     *        time.
     *      - Revised to always force leftover back to original slot.
     *
500oA*    04/13/05  DAS  5.00o
     *      - Revised PULDROP to undo pull if *NOTFND returned.
     *
500pA*    04/13/05  DAS  5.00p
     *      - Revised to only return pallets to slot when base slot changes
     *        or getting out.
     *
500qA*    04/14/05  DAS  5.00q
     *      - Revised to have user work only with full cases when doing a
     *        Breakdown replenishment.
     *
500rA*    04/14/05  DAS  5.00r
     *      - Revised to use CHG versions of *SLOT commands.
     *      - Revised LT210 logic for screens 3 and 8 in order to handle
     *        Breakdown replenishments correctly.
     *
500sA*    04/19/05  DAS  5.00s
     *      - Revised zznextstep to do a zztrncrtstart instead of a
     *        zztrnstart when switching to doing putaway.
     *      - Revised zznextstep to close REPLTF transaction.
     *      - Revised zznextstep to unconditionally try and start an idle
     *        task when there are no more work records.
     *      - Revised zzupd7 to return pallets when no more repl to do.
     *      - Revised zzputpick to update curlbl# for leftover qty label.
     *      - Revised zzputovrf to delete label if everything put back into
     *        original slot.
     *
500tA*    04/22/05  DAS  5.00t
     *      - Added Side to parms sent to LT107.
     *      - Added priority replenishment condition for side. Only takes
     *        affect if aisle range is enterd.
     *      - Revised work with Breakdowns correctly. Put back to method
     *        where user builds a "pull" pallet of breakdown items, then
     *        is directed to put them in the pick slot.
     *
500uA*    04/29/05  DAS  5.00u
     *      - Revised so pull quantity is always put into transit.
     *      - Revised to not be concerned if item is being put back into
     *        slot it was originally pulled from.
     *      - Revised to do PUTAWYB instead of a PULUNDO.
     *
500vA*    04/30/05  DAS  5.00v
     *      - Enh: Added $tnorm1/2/3 parms.
     *      - Revised ZZUPD9 to not inz CUR fields before PULRTN.
     *      - Revised ZZGETWORKREC to inz curlbl# when rec found.
     *      - Removed references to newlb because it wasn't used.
     *
500wA*    05/03/05  DAS  5.00w
     *      - Added LT210 commands *RMVZERO and *RMVZRTN to remove
     *        (inactivate) a zero lichist record.
     *
500xA*    05/05/05  DAS  5.00x
     *      - Revised to skip "skipped" records correctly. Done by setting
     *        on bypass at the beginning of ZZUPD7.
     *      - Revised F12 to get out of program for *FLOW instead of going
     *        to SC7 or looping for next replenishment.
     *      - After the competion of a *FLOW replenishment, revised to only
     *        display SC7 if there are no more replenishments to be done.
     *        Otherwise, the program starts into the next one automatically
     *
500yA*    05/23/05  DAS  5.00y
     *      - Revised ZZCMD1 to not anything for F7. Option is not
     *        displayed but command was not disabled.
     *      - Deleted routine ZZUNDO because it is not called anymore.
     *
500zA*    06/20/05  MLB  5.00z
     *      - Fix: Revised ZZCLS0 to update LBSTAT='C' when replen-
     *        ishment is skipped, exceptioned or user canceled.
     *
501aA*    06/21/05  DAS  5.01a
     *      - Fix: Moved call to zzupd7 out of routine zznextstep.
     *        Re: This was causing a recursive call to zznextstep. zzupd5
     *        called zznextstep, which called zzupd7, which called zzupd1,
     *        which called zzupd2, which called zznextstep.
     *
501bA*    06/21/05  DAS  5.01b
     *      - Fix: Revised to only call zznext in routine zzupd2 when
     *        necessary.
     *
510aA*    10/23/06  RH   5.10a
     *     (was already done in LIC version, 500c).
     *      - Fix: Add parms to LT210 call.
     *
510bA*    02/14/07  JCJ  5.10b
     *     *** NOT IMPLEMENTED YET ***
     *     *** SOME 510E changes in ENH520 should be 510b changes ***
     *      - Enh: Add new replenishment type of '*REPACK'.
     *      - Enh: If lt210 returns no license plate or no license
     *             is scanned create one.
     *
510cA*    04/02/07  MLB  5.10c
     *      - Enh: Add client custom code support to program.
     *
510dA*    07/20/07  JCJ  5.10d
     *      (was already done in LIC version, 500b, but uses zzabrt).
     *      - Fix: Add routine zzundo to the F12 process in SC1.  This
     *             will back out a started replenishment.
     *
510eA*    07/21/07  JCJ  5.10e
     *      (was already done in LIC version).
     *      - Enh: Add F9 will skip to the next replenishment.
     *      - Enh: Activte f12 on screen2.
     *
510fA*    08/20/07  JCJ  5.10f
     *     *** NOT IMPLEMENTED YET ***
     *      - Fix: for repackes force rpl qty = pull qty.
     *
510gA*    10/25/07  LMC  5.10g
     *      - Enh: Added 16 X 20 screens for handheld device
     *
510hA*    12/21/07  LMC  5.10h
     *      (was already done in LIC version).
     *      - Enh: Added logic to handle flow rack replenishments
     *
510iA*    01/11/08  LMC  5.10i
     *      - Fix: Correct selection logic in zznext
     *     *** NEXT PART NOT IMPLEMENTED YET ***
     *      - Fix: Added additional logic in zzundo - for *flow repl
     *
510jA*    01/15/08  LMC  5.10j
     *      - Enh: Add f9 skip to screen2 and screen62
     *
520aA*    01/24/08  LMC  5.20a
     *     *** NOT IMPLEMENTED YET ***
     *      - Fix: To Slot recived bucket was not being correctly
     *             adjusted if the pull qty was changed from the
     *             suggested pull qty
520cA*    07/10/09  RH   5.20c
     *      - Fix: Revised to create ITEMADJ adjustment records with
     *        CI code for breakdown type 'B' item replenishment.
     *
600 A*    07/04/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - LIC version used as base, then 510 changes added.
     *
600aA*    06/13/00  DAS  6.00a
     *      - Replaced WORKRPL with WORKUSR2, RPL1 with USR4
     *        RPL2 with USR5, RPL3 with USR1.
     *
610aA*    07/06/09  DAS  6.10a
     *      - Revised ZZPUTOVRF2/3 to send base slot in $sldisp.
     *      - Revised ZZPUTOVRF2 to send USR slot and From item
     *        in $sac fields.
     *      - Revised ZZPUTPICK to send USR slot in $sac fields.
     *
610bA*    07/06/09  DAS  6.10b
     *      - Changed curlic#=wuscannbr to curlic#=wuusrlcns.
     *
610cA*    07/06/09  DAS  6.10c
     *      - Revised zzupd5 to only call zzputpick when a qty is
     *        entered.
     *
610dA*    07/07/09  DAS  6.10d
     *      - Revised to set wuscannbr to usr lcns.
     *      - Revised zzchk6b to not verify 'From' slot.
     *
610eA*    07/08/09  DAS  6.10e
     *      - Revised PUTAWYB in zzputpick to set partial flag
     *        strictly on allputaway flag.
     *
610fA*    07/17/09  DAS  6.10f
     *      - Revised to pass in $satask for %usr2put.
     *
610gA*    11/11/09  DAS  6.10g
     *      - Enh: Revised to send 'To' slot to LT210 for PULDROP.
     *
610hA*    03/11/10  JCJ  6.10h
     *      - Enh: Add repack processing.
     *
610iA*    09/22/10  JCJ  6.10i
     *      - Enh: Added repack processing to flow rack processing
     *
610jA*    09/28/10  JCJ  6.10j
     *      - Fix: Added repack and Flow rack processing to exception
     *        processing.
     *
610kA*    10/08/10  JCJ  6.10k
     *      - Fix: do not allow F12 when there are unfinished
     *        replenishments.
     *
610lA*    10/12/10  JCJ  6.10l
     *      - Fix: added item number to WORKUSR2 to resolve dupicate
     *        key problem.  WORKUSR2 previously used license plate in
     *        its key list.  When flow processing was added to repack
     *        replenishemnts license plate was no longer unique.  The
     *        duplicate key problem is caused when license plate of
     *        *MULTIPLE is used and more than 1 slot has that condition
     *        during replenishments.
     *
640aA*    01/11/12  DAS  6.40a
     *      - Revised zzupd1 to handle unexpected lt210 return code.
640bA*    06/05/12  LMC  6.40b
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
650aA*    03/02/13  DAS  6.50a
     *      - Revises to save date/time of %TFR2 and use it for the
     *        'from' ITEMADJ record if the item is changed. This is
     *        done so record can be connected back LICLOG record.
     *
650bA*    08/01/13  KDE  6.50b
     *      - Enh:  Allow user to override the from slot for a repack
     *        replenishment by calling IT276.  Pass requested quantity
     *        in #fromslavl1.
     *
650cA*    08/15/13  KDE  6.50c
     *      - Enh:  Create new replenishment when slot does not
     *              fulfill original replenishment request
     *              Also changed screen 1 to show quantity
     *              so operator can keep up as multiple slot
     *              replenishments reduce original quantity
     *
650dA*    09/10/13  KDE  6.50d
     *      - Enh:  Allow user to scan License plate number versus
     *              slot number.
     *
650eA*    01/29/14  KDE  6.50e
     *      - Enh:  Only force quantity check in 650c if replen
     *              is for a Work Order Replenishment
650fA*    06/19/14  KDE  6.50f
     *      - Enh: Modify to handle Production Type Replenishments
     *
650g *    11/06/14  RBD  6.50g
     *      - Added new *REPLEN option OPSKPR, Skip if pick slot physical
     *        quantity is greater than item replenishment level. In
     *        addition, item replenishment level must be greater than zero.
     *
650hA*    12/05/14  KDE  6.50h
     *             Force GS1 entry for Production Raw Material
     *             Replenishments.  this included creating a new
     *             screen 051 to capture valid GS1 and also
     *             introducing UCI DRI program to validate and add
     *
650iA*    03/25/15  KDE  6.50i
     *             Change to allow for Production Breakdown 1
     *             Replenishment.
700 A*    10/27/15  KDE  7.00
     *             Fix Array Index error for Production
700aA*    10/31/15  KDE  7.00a
     *             Generate Production Line slot if the Lin-101
     *             slot in PRPLFIL does not exists
     *
700bA*    01/23/16  DLS  7.00b
     *      - Fix made in subroutine WrtProdLog for production replenishment
     *        written to file: PRODLOG.
     *
700cA*    03/04/16  DLS  7.00c
     *      - Add department to SQL WHERE clause in subroutine zzChkLin to
     *        fix sqlstt=21000 issue when processing multiple department BOM
700dA*    04/29/16  DLS  7.00d
     *      - Fix: Changed w2sltq (Slot Qty on screen2) value to #fromslstk2
     *             for production breakdown replenishments. Case quantity was
     *             being displayed instead of breakdown quantity.
     *      - Fix: Changed display to show both w2um1a & w2um2a(total slot qty)
     *             when breakdown replenishment is greater than slot breakdown
     *             quantity.
     *      - Fix: Added calculation to accurately set $tpartial for breakdown
     *             replenishments. This fixes issue where pick slot license
     *             was changed to *NONE after partial replenishment.
     *
700eA*    06/07/16  DLS  7.00e
     *      - Enh: Updated program to process *EACH slot replenishments
     *             much like Breakdown item replenishments while avoiding
     *             creating a new replenishment type for *EACH slot items.
     *             The biggest difference between the two replenishment types
     *             is that we don't have to change the quantity from a case to
     *             eaches for a *EACH slot replenishment.
     *
700fA*    06/11/16  DAS  7.00f
     *      - Fix: Revised to identify a *EACH slot by the slot def
     *        pallet type, not the slot def code.
     *
700gA*    11/04/16  LMC  7.00g
     *      - Enh: UPC file has a database change. Recompile only.
710 A*    02/11/17  KDE  7.10
     *      - Fix: Revised check to UCISPLITS only when Breakdown Replenishment
     *      - Fix: Recompile for new Prodlog structure
     *      - Fix: Use #PICKSLRLVL instead of PRTRLVL in WRTPRODLOG routine
710aA*    01/25/17  KDE  7.10a
     *      - Enh: Revised to default pull quantity into replenishment
     *             quantity for Production Module Replenishments
710bA*    04/20/17  DAS  7.10a
     *      - Enh: Revised to skip a replenishment record if another
     *        replen exists for the same item with a better FIFO date.
     *      - Currently, Renzi is the only one using this.
     *      - Added file PRPLFIL9.
     *      - Added routine zzchkfifo.
710cA*    04/21/17  DAS  710c
     *     - Removed file slot2, as it was no longer being used.
710dA*    07/24/17  KDE  710d
     *     - Setup separate task code for Production Replenishments
710fA*    09/26/17  KDE  710f
     *     - Fix: change data structure name for *FEATURE option
     *       Field OPFEAT was getting overwritten because DS named
     *       as record format for options (OPDATA).  This was impacting
     *       how Repl Qty was being calculated
720 A*    02/19/18  KDE  720
     *     - Define for new replenishment styp StrRepl.  This process will
     *       move stock from Warehouse to StrRepl area then to Store
     *       or other offsite area needing stock
720aA*    10/17/18  KDE  720a
     *     - Fix:  Options data record incorrect for Production Options
720bA*    08/16/16  LMC  720b
     *     - Enh:  UCI Tracking
730 A*    08/26/19  KDE  7.30
     *     - Enh:  Change Production Replen from 'D' to 'O'
     *     - Enh:  Add 'D' back as Drop Pick Replenishment
     *     - Enh:  Add routine to have generate a virtual *DROP slot
     *             for "to" location for Drop Picks if none exist.  This
     *             will be shown as default and suggestion but screen 5
     *             will allow user to override if no allocation exist
740 A*    05/07/20  KDE  7.40
     *     - Enh:  Change status to DP for Drop Pick slots to prevent
     *             all other processes from touching these slots
750 A*    04/12/21  KDE  7.50
     *     - Enh:  Add UOM to screen 1 for Drop Picks
     *     -       Change several things related to F9 (bypass)
     *             All this was focused around Drop Pick processing
750aA*    08/14/21  KDE  7.50a
     *     - Enh:  Add call to getddslot for Drop Pick slot instead of
     *             code inside this program.  Missing some logic
     *     - Changed to call getddslot when deciding whether we have
     *             another replen.  If it is a drop pick replen and
     *             no more available drop picks exist we should not
     *             prompt to continue or not.
     *     - Changed to remove Drop Pick slot when user cancels
750bA*    09/21/21  KDE  7.50b
     *     - Enh:  Modify zero verify SQL to include pck buckets in slot file
750cA*    11/15/21  KDE  7.50c
     *     - Fix:  Corect issue where it was using base slot for Virtual instead
     *             of actual virtual scanned or selected
     *----------------------------------------------------------------

     *  Client Custom Revisions:
     *
     *  Coastal
CSP A*   01/21/15  KDE  CSP
     *      - Only enforce quantity check for Work Order Repacks
     *        For Coastal Produce.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi
RNZaA*    04/21/17  DAS  RNZa
     *      - Revised to use new 710a zzchkfifo routine.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  61        Display order qty on screen 2.
     *  74        NRF on chain to file LABEL.
     *  76        Error indicator on write to SLTRPEX.
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  93        At least one replenishment started. Exit pgm not
     *            allowed until all product putaway.
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  Binding Directories
600aA*----------------------------------------------------------------
600aA
600aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650bMF*t107fm   cf   e             workstn
650bAF*t10701   cf   e             workstn
650hDF*t10702   cf   e             workstn
700aDF*Lt10703   cf   e             workstn
720 DF*Lt10704   cf   e             workstn
750 DF*Lt10705   cf   e             workstn
750 MFLt10706   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
510gAF                                     sfile(m16rec:msgk)
     Fitemdef   if   e           k disk
     Fitemlnk   if   e           k disk
     Fitemmsc   if   e           k disk
     FLabel     uf a e           k disk
     FLabel7    if   e           k disk
     Foptiond   if   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
     Fprplfil1  uf a e           k disk    rename(prrec:prrec1)
     Fprplfil6  uf   e           k disk
710bAFprplfil9  if   e           k disk    rename(prrec:prrec9)
710bAF                                     prefix(p9_)
710cDF*lot2     uf a e           k disk
710cDF*                                    rename(slrec:slrec2)
     Fslot3     if   e           k disk
     F                                     rename(slrec:slrec3)
     Ftask      if   e           k disk
     Ftaskdet   uf   e           k disk
650iAFunmesr    if   e           k disk
     Fvslot1    uf   e           k disk
     F                                     rename(vsrec:vsrec1)
     Fvslot2    uf a e           k disk
     F                                     rename(vsrec:vsrec2)
600aDF*orkrpl   uf a e           k disk
600aDF*orkrpl1  uf   e           k disk
600aDF*                                    rename(wrrec:wrrec1)
600aDF*orkrpl2  uf   e           k disk
600aDF*                                    rename(wrrec:wrrec2)
600aDF*orkrpl3  if   e           k disk
600aDF*                                    rename(wrrec:wrrec3)
650bAFworkusr3  uf   e           k disk    rename(wurec:wurec3)
600aAFworkusr2  uf a e           k disk
600aAFworkusr4  uf   e           k disk
600aAF                                     rename(wurec:wurec4)
600aAFworkusr5  uf   e           k disk
600aAF                                     rename(wurec:wurec5)
600aDF*orkusr1  if   e           k disk    prefix(wu1_)
600aDF*                                    rename(wurec:wurec1)
520c Fitemadj   o    e           k disk
     Fitmexcp   o    e           k disk
650hAFupc       if   e           k disk
650hAfProdlog   uf a e           k disk
650hAfPrdDate1  if   e           k disk
650hAflicinfo   if   e           k disk
510cA*----------------------------------------------------------------
510cA*  Customer id
510cA*
JPF A /COPY QCOPYSRC,ID#PALMER
CWHaA /COPY QCOPYSRC,ID#CITYWHO
CSP A /COPY QCOPYSRC,ID#COASTAL
710bA /COPY QCOPYSRC,ID#RENZI
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
530 D *desc            s             50    dim(29) ctdata perrcd(1)
650cDD*desc            s             50    dim(30) ctdata perrcd(1)
650dDD*desc            s             50    dim(31) ctdata perrcd(1)
650fDD*desc            s             50    dim(32) ctdata perrcd(1)
650hDD*desc            s             50    dim(35) ctdata perrcd(1)
700eED* desc            s             50    dim(35) ctdata perrcd(1)
720 DD*desc            s             50    dim(36) ctdata perrcd(1)
720 AD desc            s             50    dim(37) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     D                 ds
     D  lbstim                 1      6  0
     D  stath                  1      2
     D  statm                  3      4
     D  stats                  5      6

500dA*----------------------------------------------------------------
500dA*  DRI parameters
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#DRIPARMS
650hA /COPY *libl/qcopysrc,C#UCIINFO
700aA /COPY *libl/qcopysrc,C#PROD
650hA /COPY *libl/qcopysrc,C#CVTPARMS
650hA /COPY *libl/qcopysrc,C#BARCODE
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#ITEM
500dA /COPY *libl/qcopysrc,C#SLOT
500dA /COPY *libl/qcopysrc,C#SLOTDEF
600aA /COPY *libl/qcopysrc,C#LICENSE
500dAD saveVer#        s                   like($slver#)
500dAD save$slot       s                   like($slot)

600aA*----------------------------------------------------------------
600aA* Function prototypes.
600aA*----------------------------------------------------------------
600aA
600aA /copy qcopysrc,p.bfcdteti

640bA*----------------------------------------------------------------
640bA*  Prototypes
640bA*----------------------------------------------------------------
640bA
640bAD wrttran1        pr                  extpgm('WRTTRAN1')
640bA * Input
640bAD   ppcmd                        8
640bAD   ppwait                       2  0
640bAD   ppwhse                       3  0
640bAD   pptran#                      7  0
640bAD   ppfromdate                   8  0
640bAD   pptodate                     8  0
640bAD   ppemp#                       5  0
650hAD ucilic#         pr                  extpgm('UCILIC#')
650hA * Input
650hAD   unext                       13  0 const
650hAD   uwhse                        3  0 const
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
     D  $whse                  1      3  0
     D  $itemds                4     18
     D  $home                 19     30
     D  $disp                 31     42
     D  $lbl#                 43     49  0
     D  $trn#                 50     56  0
     D  $bat#                 57     63  0
     D  $prg#                 64     73
     D  $pllp#                74     88
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pfail                27     29
     D  $ptail                30     32
     D  $prplt                33     33
500tAD  $pside                34     34
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @adjtr          c                   const('ADJTRAN  ')
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  prwhse                 1      3  0 inz(0)
     D  prwhdp                 4      8
     D  prfail                 9     11
     D  prtail                12     14
     D  prseq#                15     19  0 inz(0)
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $lzero                54     54
     D  $lstat                59     60
     D  $ltrn2                55     61  0
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $lspos                65     67  0
     *
     D  $laisl                27     29
     D  $lloc                 30     31p 0
     D  $lrlvl                32     33  0
     D  $lhand                34     35
     D  $lpos                 36     37p 0
     D  $lpdsp                38     49
     D  $lvdsp                50     61
     D  $lpllc                62     62
     D  $lmxps                63     64p 0
     *
     D  $litm2                22     36
     D  $ltdsp                37     48
     D  $lfdsp                49     60
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
     *
     D  $ldesg                19     23
     D  $ltyp                 24     24
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lfail                27     29
     D  $ltail                30     32
     D  $lseq#                33     37  0
     D  $ltrn3                38     44  0
     D  $lfeat                45     45
     D  $lrplt                46     46
     D  $lcrtt                47     47
     D  $lpbat                48     51p 0
     D  $llbl#                52     55p 0
     *
     D $ldata          ds
     D  $ldend                 1    100
     *
500mAD  $lwhse2               19     21  0
500mAD  $ltrackitem           22     22
500mAD  $ltrackpos            23     23
500mAD  $lposmrg              24     24
500mAD  $lposrtn              25     25
500mAD  $lpsplit              26     26
500mAD  $ltsplit              27     27
     *
     *----------------------------------------------------------------
     *  LICHIST - License history (Input Data)
     *
     D $rparm          ds
     D  $rwhse                 1      3  0
     D  $rltrn                 4      7p 0
     D  $racfl                 8      9
     D  $rtrn#                10     13p 0
     D  $rlbl#                14     17p 0
     D  $rlcns                18     32
     D  $rfmlc                33     47
     D  $rorlc                48     62
     D  $rlqy1                63     66p 0
     D  $rlqy2                67     70p 0
     D  $rlqy3                71     74p 0
     D  $raqy1                75     78p 0
     D  $raqy2                79     82p 0
     D  $raqy3                83     86p 0
     D  $rfmcd                87     87
     D  $rfara                88    102
     D  $rfwhd               103    107
     D  $rfasl               108    110
     D  $rfloc               111    113  0
     D  $rflvl               114    115  0
     D  $rfhnd               116    117
     D  $rfslp               118    119p 0
     D  $rtocd               120    120
     D  $rtara               121    135
     D  $rtwhd               136    140
     D  $rtasl               141    143
     D  $rtloc               144    146  0
     D  $rtlvl               147    148  0
     D  $rthnd               149    150
     D  $rtslp               151    152p 0
     D  $rtord               153    156p 0
     D  $rtseq               157    159p 0
     D  $rexcd               160    167
     D  $radts               168    193
     D  $raemp               194    196p 0
     D  $rausr               197    206
     D  $rajob               207    216
     D  $rajbn               217    222
     D  $rcdts               223    248
     D  $rcemp               249    251p 0
     D  $rcusr               252    261
     D  $rcjob               262    271
     D  $rcjbn               272    277
     *
     * Misc. work fields
     D $rdata          ds
     D  $rpo                   1      9
     D  $rseq                 10     12p 0
     D  $ritem                13     27
     D  $rlotc                28     57
     D  $rcwgt                58     62p 2
     D  $rnewp                63     64p 0
     D  rdtaln                 1    100

417qA*----------------------------------------------------------------
417qA*  LT210 parameters
417qA*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
500 AD  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
500vAD  $tnorm1        s              5  0
500vAD  $tnorm2        s              3  0
500vAD  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
500cAD  $tinslot       s              1
500cAD  $tsamepos      s              1
500cAD  $tdiffpos      s              1
500cAD  $tpsplit       s              1
500cAD  $tinlic#       s             15
500cAD  $toutlic#      s             15
500cAD  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4
610fAD  $ttoslot       s             12

     *
     *----------------------------------------------------------------
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
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
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
     *
     D  ernpck                 1      3p 0
     D  erapck                 4      6p 0
     *
     D  erfmsl                 1     12
     D  ertosl                13     24
     *
     D  eritdp                 1      5
     D  erslds                 6     17
     D  ersldp                18     22
     D  eritsc                23     23
     D  erslsc                24     24
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     *
     D  erptxt                 1     10
     D  erpnbr                11     14p 0
     D  erpusr                15     24
     *
     D  erlcns                 1     15
     D  erdsp                 16     27
     D  erpos                 28     29p 0
     *
     D                 ds
     D  $ec                    1      2p 0
     D                 ds
     D  errtyp                 1      8
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
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *                 1=Locator system installed.
     *                 2=Full system installed.
     *
     * Data structure
     *
710fDD*opdata          ds
710fAD opdta4          ds
     D  opfeat                 1      1
650hAD  opgs1o                22     22
     D  optend               117    117
     *----------------------------------------------------------------
650gA*  *REPLEN  -  Replenishment options.
650gA*----------------------------------------------------------------
650gA*
650gA* Fields
650gA*
650gA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
650gA*    OPOQRP  -  Order qty replenishment (Y/N).
650gA*    OPRPEX  -  Allow replenishment on expired items.
650gA*               1=Allow, 2=Don't allow, 3=Warn
650gA*    OPRPFI  -  Allow replenishments out of FIFO order.
650gA*               1=Allow, 3=Warn
650gA*    OPLMTS  -  Limit Specific Slot replenishment program to
650gA*               to display only one overflow location at a
650gA*               time. (Y/N)
650gA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
650gA*               letdown/transfer. (Y/N)
650gA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
650gA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
650gA*    OPSKPR  -  Skip if pick slot physical qty is greater than
650gA*               item replenishment level.
650gA*
650gA* Data structure
650gA*
650gAD opdta3          ds
650gAD  oprplb                 1      8
650gAD  opoqrp                 9      9
650gAD  oprpex                10     10
650gAD  oprpfi                11     11
650gAD  oplmts                12     12
650gAD  opcqty                13     13
650gAD  opbdrp                14     14
650gAD  oprsrt                15     24
650gAD  opskpr                25     25
650gAD  opcend               117    117
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
720bAD uprecuom      E ds                  extname(upc) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
500dAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
500dAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600aAD  #curruser            358    367
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
     *  Variables
     *

500dAD #fromitwhse     s                   like($itwhse)
500dAD #fromititem     s                   like($ititem)
500dAD #fromittype     s                   like($ittype)
500dAD #fromitdesc     s                   like($itdesc)
500dAD #fromitpdsc     s                   like($itpdsc)
500eAD #fromithead     s             70
500dAD #fromitwhdp     s                   like($itwhdp)
500dAD #fromitstyp     s                   like($itstyp)
500dAD #fromitdesg     s                   like($itdesg)
500dAD #fromitum1      s                   like($itum1)
500dAD #fromitflg1     s                   like($itflg1)
500dAD #fromitum2      s                   like($itum2)
500dAD #fromitumq2     s                   like($itumq2)
500dAD #fromitflg2     s                   like($itflg2)
500dAD #fromitum3      s                   like($itum3)
500dAD #fromitumq3     s                   like($itumq3)
500dAD #fromitnrpk     s                   like($imnrpk)
500dAD #fromitflgd     s                   like($itflgd)
500dAD #fromitcube     s                   like($itcube)
500dAD #fromitswgt     s                   like($itswgt)
500dAD #fromitcwgt     s                   like($itcwgt)
500dAD #fromitmitem    s                   like($itmitem)
500dAD #fromitsdef     s                   like($idsdef)
500dAD #fromittie      s                   like($idtie)
500dAD #fromithigh     s                   like($idhigh)

500dAD #fromssbflag    s               n
500dAD #fromssbititem  s                   like($ititem)
500dAD #fromssbittype  s                   like($ittype)
500dAD #fromssbitdesc  s                   like($itdesc)
500dAD #fromssbitpdsc  s                   like($itpdsc)
500dAD #fromssbitwhdp  s                   like($itwhdp)
500dAD #fromssbitstyp  s                   like($itstyp)
500dAD #fromssbitdesg  s                   like($itdesg)
500dAD #fromssbitum1   s                   like($itum1)
500dAD #fromssbitum2   s                   like($itum2)
500dAD #fromssbitumq2  s                   like($itumq2)
500dAD #fromssbitum3   s                   like($itum3)
500dAD #fromssbitumq3  s                   like($itumq3)

500dAD #fromslwhse     s                   like($slwhse)
500dAD #fromslwhdp     s                   like($slwhdp)
500dAD #fromslstyp     s                   like($slstyp)
500dAD #fromsldisp     s                   like($sldisp)
500dAD #fromslaisl     s                   like($slaisl)
500dAD #fromslloc      s                   like($slloc)
500dAD #fromslpseq     s                   like($slpseq)
500dAD #fromslrlvl     s                   like($slrlvl)
500dAD #fromslhand     s                   like($slhand)
500dAD #fromslstat     s                   like($slstat)
500dAD #fromslrsrv     s                   like($slrsrv)
500dAD #fromslentd     s                   like($slentd)
500dAD #fromslexpd     s                   like($slexpd)
500dAD #fromslslfd     s                   like($slslfd)
500dAD #fromslactv     s                   like($slactv)
500dAD #fromslbld      s                   like($slbld)
500dAD #fromslpick     s                   like($slpick)
500dAD #fromslitem     s                   like($slitem)
500dAD #fromslsdef     s                   like($slsdef)
500dAD #fromslside     s                   like($slside)
500dAD #fromslpos      s                   like($sdpos)
500dAD #fromslvirt     s                   like($sfvirt)
500dAD #fromslstk1     s                   like($slstk1)
500dAD #fromslstk2     s                   like($slstk2)
500dAD #fromslstk3     s                   like($slstk2)
500dAD #fromslalc1     s                   like($slalc1)
500dAD #fromslalc2     s                   like($slalc2)
500dAD #fromslalc3     s                   like($slalc3)
500dAD #fromsltfr1     s                   like($sltfr1)
500dAD #fromsltfr2     s                   like($sltfr2)
500dAD #fromsltfr3     s                   like($sltfr3)
500dAD #fromslpck1     s                   like($slpck1)
500dAD #fromslpck2     s                   like($slpck2)
500dAD #fromslpck3     s                   like($slpck3)
500dAD #fromslrcv1     s                   like($slrcv1)
500dAD #fromslrcv2     s                   like($slrcv2)
500dAD #fromslrcv3     s                   like($slrcv3)
500dAD #fromslphy1     s                   like($slphy1)
500dAD #fromslphy2     s                   like($slphy2)
500dAD #fromslphy3     s                   like($slphy3)
500dAD #fromslavl1     s                   like($slavl1)
500dAD #fromslavl2     s                   like($slavl2)
500dAD #fromslavl3     s                   like($slavl3)
650dAD #fromsldesg     s                   like($sldesg)
500dAD #frombasesldsp  s                   like($sldisp)
600aAD #fromsaToLcns   s                   like($saToLcns)
600aAD #fromsaToPos    s                   like($saToPos)
600aAD #fromsaOLcns    s                   like($saOLcns)

500dAD #ovrfslwhse     s                   like($slwhse)
500dAD #ovrfslwhdp     s                   like($slwhdp)
500dAD #ovrfslstyp     s                   like($slstyp)
500dAD #ovrfsldisp     s                   like($sldisp)
500dAD #ovrfslaisl     s                   like($slaisl)
500dAD #ovrfslloc      s                   like($slloc)
500dAD #ovrfslpseq     s                   like($slpseq)
500dAD #ovrfslrlvl     s                   like($slrlvl)
500dAD #ovrfslhand     s                   like($slhand)
500dAD #ovrfslstat     s                   like($slstat)
500dAD #ovrfslrsrv     s                   like($slrsrv)
500dAD #ovrfslentd     s                   like($slentd)
500dAD #ovrfslexpd     s                   like($slexpd)
500dAD #ovrfslslfd     s                   like($slslfd)
500dAD #ovrfslactv     s                   like($slactv)
500dAD #ovrfslbld      s                   like($slbld)
500dAD #ovrfslpick     s                   like($slpick)
500dAD #ovrfslitem     s                   like($slitem)
500dAD #ovrfslsdef     s                   like($slsdef)
500dAD #ovrfslpos      s                   like($sdpos)
500dAD #ovrfslvirt     s                   like($sfvirt)
500dAD #ovrfslstk1     s                   like($slstk1)
500dAD #ovrfslstk2     s                   like($slstk2)
500dAD #ovrfslstk3     s                   like($slstk2)
500dAD #ovrfslalc1     s                   like($slalc1)
500dAD #ovrfslalc2     s                   like($slalc2)
500dAD #ovrfslalc3     s                   like($slalc3)
500dAD #ovrfsltfr1     s                   like($sltfr1)
500dAD #ovrfsltfr2     s                   like($sltfr2)
500dAD #ovrfsltfr3     s                   like($sltfr3)
500dAD #ovrfslpck1     s                   like($slpck1)
500dAD #ovrfslpck2     s                   like($slpck2)
500dAD #ovrfslpck3     s                   like($slpck3)
500dAD #ovrfslrcv1     s                   like($slrcv1)
500dAD #ovrfslrcv2     s                   like($slrcv2)
500dAD #ovrfslrcv3     s                   like($slrcv3)
500dAD #ovrfslphy1     s                   like($slphy1)
500dAD #ovrfslphy2     s                   like($slphy2)
500dAD #ovrfslphy3     s                   like($slphy3)
500dAD #ovrfslavl1     s                   like($slavl1)
500dAD #ovrfslavl2     s                   like($slavl2)
500dAD #ovrfslavl3     s                   like($slavl3)
500dAD #ovrfbasesldsp  s                   like($sldisp)

500dAD #pickitwhse     s                   like($itwhse)
500dAD #pickititem     s                   like($ititem)
500dAD #pickittype     s                   like($ittype)
500dAD #pickitdesc     s                   like($itdesc)
500dAD #pickitpdsc     s                   like($itpdsc)
500eAD #pickithead     s             70
500dAD #pickitwhdp     s                   like($itwhdp)
500dAD #pickitstyp     s                   like($itstyp)
500dAD #pickitdesg     s                   like($itdesg)
500dAD #pickitum1      s                   like($itum1)
500dAD #pickitflg1     s                   like($itflg1)
500dAD #pickitum2      s                   like($itum2)
500dAD #pickitumq2     s                   like($itumq2)
500dAD #pickitflg2     s                   like($itflg2)
500dAD #pickitum3      s                   like($itum3)
500dAD #pickitumq3     s                   like($itumq3)
500dAD #pickitnrpk     s                   like($imnrpk)
500dAD #pickitflgd     s                   like($itflgd)
500dAD #pickitcube     s                   like($itcube)
500dAD #pickitswgt     s                   like($itswgt)
500dAD #pickitcwgt     s                   like($itcwgt)
500dAD #pickitmitem    s                   like($itmitem)
500dAD #pickitsdef     s                   like($idsdef)
500dAD #pickittie      s                   like($idtie)
500dAD #pickithigh     s                   like($idhigh)

500dAD #pickssbflag    s               n
500dAD #pickssbititem  s                   like($ititem)
500dAD #pickssbittype  s                   like($ittype)
500dAD #pickssbitdesc  s                   like($itdesc)
500dAD #pickssbitpdsc  s                   like($itpdsc)
500dAD #pickssbitwhdp  s                   like($itwhdp)
500dAD #pickssbitstyp  s                   like($itstyp)
500dAD #pickssbitdesg  s                   like($itdesg)
500dAD #pickssbitum1   s                   like($itum1)
500dAD #pickssbitum2   s                   like($itum2)
500dAD #pickssbitumq2  s                   like($itumq2)
500dAD #pickssbitum3   s                   like($itum3)
500dAD #pickssbitumq3  s                   like($itumq3)

500dAD #pickslwhse     s                   like($slwhse)
500dAD #pickslwhdp     s                   like($slwhdp)
500dAD #pickslstyp     s                   like($slstyp)
500dAD #picksldisp     s                   like($sldisp)
500dAD #pickslaisl     s                   like($slaisl)
500dAD #pickslloc      s                   like($slloc)
500dAD #pickslpseq     s                   like($slpseq)
500dAD #pickslrlvl     s                   like($slrlvl)
500dAD #pickslhand     s                   like($slhand)
500dAD #pickslstat     s                   like($slstat)
500dAD #pickslrsrv     s                   like($slrsrv)
500dAD #pickslentd     s                   like($slentd)
500dAD #pickslexpd     s                   like($slexpd)
500dAD #pickslslfd     s                   like($slslfd)
500dAD #pickslside     s                   like($slside)
500dAD #pickslactv     s                   like($slactv)
500dAD #pickslbld      s                   like($slbld)
500dAD #pickslpick     s                   like($slpick)
500dAD #pickslitem     s                   like($slitem)
500dAD #pickslsdef     s                   like($slsdef)
500dAD #pickslpos      s                   like($sdpos)
500dAD #pickslvirt     s                   like($sfvirt)
500dAD #pickslstk1     s                   like($slstk1)
500dAD #pickslstk2     s                   like($slstk2)
500dAD #pickslstk3     s                   like($slstk2)
500dAD #pickslalc1     s                   like($slalc1)
500dAD #pickslalc2     s                   like($slalc2)
500dAD #pickslalc3     s                   like($slalc3)
500dAD #picksltfr1     s                   like($sltfr1)
500dAD #picksltfr2     s                   like($sltfr2)
500dAD #picksltfr3     s                   like($sltfr3)
500dAD #pickslpck1     s                   like($slpck1)
500dAD #pickslpck2     s                   like($slpck2)
500dAD #pickslpck3     s                   like($slpck3)
500dAD #pickslrcv1     s                   like($slrcv1)
500dAD #pickslrcv2     s                   like($slrcv2)
500dAD #pickslrcv3     s                   like($slrcv3)
500dAD #pickslphy1     s                   like($slphy1)
500dAD #pickslphy2     s                   like($slphy2)
500dAD #pickslphy3     s                   like($slphy3)
500dAD #pickslavl1     s                   like($slavl1)
500dAD #pickslavl2     s                   like($slavl2)
500dAD #pickslavl3     s                   like($slavl3)
500dAD #pickbasesldsp  s                   like($sldisp)
700fAD #picksdpal      s                   like($sdpal)

     D $msgf           s             10
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D #bitem          s                   like(lbitem)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
650dAD LicenseEntered  s               n
500fAD it276Flag       s               n
500fAD allputaway      s               n
500dAD askzrovfy       s               n
     D availf          s              7  0
     D a58             s             58
     D balexc          s              1
     D balrem          s              4
     D basslt          s                   like(lbdisp)
     D bszero          s              1
     D bypass          s              1
     D cases           s                   like(lbqpck)
     D chknew          s              1
500dAD chk4err         s               n
500kDD**k4err          s              1
650hAD ckupc           s                   like(upupc)
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D crtdsc          s              1
     D crtrcd          s              1
720 Ad hldStrLcns      s             15
     D csqty           s                   like(lbqpck)
     D curasl          s                   like(lbaisl)
500fAD curdate         s              8  0
     D curdsp          s                   like(lbdisp)
     D curent          s              1
     D curhnd          s                   like(lbhand)
500 AD curitm          s                   like($titem)
500fAD curlbl#         s                   like(lblbl#)
500 AD curlic#         s                   like($tlic#)
     D curloc          s                   like(lbloc)
     D curlvl          s                   like(lbrlvl)
600aMD curpos          s                   like(wupulpos)
500fAD curtime         s              6  0
     D curtrn          s              7  0
500dAD curtrn#         s              7  0
     D curtsk          s              6
     D curtyp          s              1
500 AD curwhd          s                   like(lbwhdp)
     D difpck          s                   like(lbqpck)
     D difrep          s                   like(lbqpck)
     D difrpl          s                   like(lbqpck)
730 AD dropPick        s               n
650iAd NullInds        s              5i 0 inz(-1)
650hAd gs1c            s              3  0 inz(0)
650hAD gs1count        s                   like(w5nqty)
     D slphy1          s                   like(slstk1)
     D slphy2          s                   like(slstk2)
     D slphy3          s                   like(slstk3)
     D slavl1          s                   like(slstk1)
     D slavl2          s                   like(slstk2)
     D slavl3          s                   like(slstk3)
     D done            s              1
500kMD drierr          s               n
500kDD**rizm           s              1
     D dteofl          s              1
     D dteold          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
500dMD error           s               n
     D excptn          s              1
     D exist           s              1
     D fintim          s                   like(ptetim)
710bAD firstP9         s               n
500fAD firstput        s               n
720 AD firstrpl        s               n
     D flaghs          s              1
     D flrplt          s              5  0
     D fmentd          s                   like(slentd)
     D fmexpd          s                   like(slexpd)
     D fmpck           s                   like(slpick)
     D forever         s               n
     D forevr          s              1
     D found           s              1
500fAD foundworkrec    s               n
     D frmasl          s                   like(slaisl)
500dAD getwhse         s                   like($slwhse)
500dAD getwhdp         s                   like($slwhdp)
500dAD getdisp         s                   like($sldisp)
     D hasvs           s              1
     D help            s              5  0
     D i               s              2  0
     D itdtyp          s                   like($ltyp)
     D j               s              2  0
     D k               s              3  0
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kydcod          s                   like(opdcod)
     D kydisp          s                   like(sldisp)
     D kydwdp          s                   like(opdwdp)
     D kydwhs          s                   like(opdwhs)
600aMD kyfasl          s                   like(wupulaisl)
     D kyitem          s                   like(ilitm2)
600aDD*kynbr           s                   like(wrnbr)
600aAD kyrectype       s                   like(wurectype)
     D kystat          s                   like(ptstat)
600aMD kytasl          s                   like(wupulaisl)
     D kytrn#          s                   like(pttrn#)
600aMD kytype          s                   like(wuscantype)
     D kywhdp          s                   like(lbwhdp)
     D kywhse          s                   like(opwhse)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
500fAD lasttime        s              6  0
500mAD lastslot        s             12
500fAD leftover        s              5  0
     D loop            s              1
     D lstscr          s              3
500fDD*lstslt          s             12
600aAD lt108Flag       s               n
     D maxplt          s                   like(prfpos)
     D msgk            s              4  0
500vDD*newlb           s              1
501aDD*newrpl          s              1
501aMD newrpl          s               n
501aAD nomoresteps     s               n
     D nxtscr          s              3
710bAD outOfFifoOrder  s               n
     D ovrrid          s              1
650gAD pckSltPhyQ      s             10  0
650hAd prddte          s              8  0
     D ptatyp          s              8
     D qtychg          s              1
     D redspl          s              1
     D refrsh          s              1
500tAD remainder       s              5  0
500sAD rpltfrflag      s               n
     D retry           s               n
     D rolldn          s              5  0
     D rollup          s              5  0
     D rpldif          s                   like(sltfr1)
500fAD rplmode         s              3
     D rplqty          s                   like(lbqpck)
     D rplstr          s              4
     D rpltyp          s              8
     D rtnhom          s              1
     D rtnto           s              8
710bAD saveEntd        s                   like(slentd)
710bAD saveExpd        s                   like(slexpd)
710bAD savePrty        s                   like(slprty)
     D savseq          s                   like(prseq#)
     D savtrn          s                   like(pttrn#)
650hAD ScanGs1         s               n
     D sclear          s              1
     D skippd          s              1
     D skpslt          s              1
     D sldtyp          s                   like($ltyp)
     D sltmax          s              3  0
     D stdate          s                   like(ptsdte)
     D stop            s              1
720bAD today           s              8  0
     d ucispltcnt      s              5  0
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svcube          s                   like(lbcube)
     D svexpd          s                   like(slexpd)
     D svfdis          s                   like(sldisp)
     D svfhnd          s                   like(prfhnd)
     D svfpos          s                   like(prfpos)
     D svfseq          s                   like(slpseq)
     D svfsid          s                   like(slside)
     D svitem          s                   like(lbitem)
     D svlbl#          s                   like(lblbl#)
600aMD svlcns          s                   like(wuscannbr)
     D svorsl          s                   like(sldisp)
     D svpick          s                   like(slpick)
600aMD svpnbr          s                   like(wuscannbr)
600aMD svptyp          s                   like(wuscantype)
     D svqalc          s                   like(lbqalc)
     D svqpck          s                   like(lbqpck)
     D svqrmn          s                   like(lbqrmn)
     D svrplb          s                   like(lblbl#)
     D svrtpo          s                   like(ptrtpo)
     D svseq#          s                   like(prseq#)
     D svswgt          s                   like(lbswgt)
     D svtask          s                   like(pttask)
     D svtfr1          s                   like(sltfr1)
     D svtlen          s                   like(ptdmin)
     D svtran          s                   like(pttrn#)
     D svtrn#          s                   like(pttrn#)
     D svtseq          s                   like(slpseq)
     D svtsid          s                   like(slside)
     D svtype          s                   like(ittype)
     D svumq2          s                   like(itumq2)
     D svumq3          s                   like(itumq3)
     D t#task          s              6
     D tempa2          s              2
500sAD temp3n          s              3  0
     D timlen          s                   like(ptdmin)
650aAD tfr2usrDate     s                   like(iadate)
650aAD tfr2usrTime     s                   like(iatime)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D toaisl          s                   like(slaisl)
     D topck           s                   like(slpick)
     D topick          s                   like(lbqpck)
     D toslot          s                   like(sldisp)
500mAD trackitem       s              1
500mAD trackpos        s              1
500mAD trackposmrg     s              1
500mAD trackposrtn     s              1
500mAD trackpsplit     s              1
500mAD tracktsplit     s              1
     D trndte          s              8  0
500qAD trnlic#         s                   like($tlic#)
     D trntim          s              6  0
700dAD ttlLowW2sltq    s             13s 0 inz(0)
650hAD $unext          s             13  0
650hAD unexta          s             13
     D updrplrec       s               n
650cAD qtyGrtSlt       s               n
     D usrrpl          s              1
750aAd validateonly    s               n
     D vfyslt          s              4
     D vrtslt          s              1
750cAd vrtsltcnt       s              3  0
     D warn            s              1
730 Ad wkdesg          s                   like(sldesg)
     D wkgrp1          s                   like(ptgrp1)
     D wkgrp2          s                   like(ptgrp2)
     D wkqty           s                   like(lbqpck)
     D wkrtpo          s                   like(ptrtpo)
700aAd wkritem         s                   like(slitem)
     d wkrstat         s                   like(slstat)
650hAD wkupcd          s                   like(upupc)
     D woemty          s              1
500tAD workcount       s              5  0
     D wotrn#          s                   like(pttrn#)
     D wozero          s              1
     D wrkqty          s                   like(lbqpck)
640bAD wrtpcmd         s             10
640bAD wrtpwait        s              2  0
640bAD wrtpwhse        s              3  0
640bAD wrtptran#       s                   like(pttrn#)
640bAD wrtpfrmdate     s              8  0
640bAD wrtptodate      s              8  0
640bAd wrtpemp#        s                   like(ptemp#)
     D w1task          s              6
     D w2aval          s              7  0
730 Ad ddtosl          s                   like(sldisp)
     D w4qty           s              1
500dAD zmsflag         s               n
750aAd rtnzzget5       s               n
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     D savslavl3       s                   like($slavl3)
720bAD blank6          s              6
720bAD workupc         s                   like(upupc)

650hAd                 ds
650hAd gs1                                 dim(500)
650hAD  hldgs1                       50
650hAd                                     overlay(gs1:*next)
650hAD  hldwgt                        9p 3
650hAd                                     overlay(gs1:*next)
650hAD  hldser                       20
650hAd                                     overlay(gs1:*next)

600aA*----------------------------------------------------------------
600aA*  Time variables
600aA*----------------------------------------------------------------
600aa
600aAD CurrStamploc    s               z
600aAD CurrStampsys    s               z
600aAD CurrStampuc     s               z
600aA
600aaD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     Iitrec
     I              itdesc                      pitdsc
     I              itpdsc                      pitpds
650bA*----------------------------------------------------------------
650bA*  PRPLFIL1 record layout
650bA*
650bAIprrec1
650bAI              prwhse                      prwhs1
650bAI              prwhdp                      prwhd1
650bAI              prfail                      prfai1
650bAI              prfloc                      prflo1
650bAI              prflvl                      prflv1
650bAI              prfhnd                      prfhn1
650bAI              prfpos                      prfpo1
650bAI              prtail                      prtai1
650bAI              prtloc                      prtlo1
650bAI              prtlvl                      prtlv1
650bAI              prthnd                      prthn1
650bAI              prtpos                      prtpo1
650bAI              prfdis                      prfdi1
650bAI              prtdis                      prtdi1
650bAI              pritem                      pritm1
650bAI              prseq#                      prseq1
650bAI              prqty                       prqty1
650bAI              prsdef                      prsde1
650bAI              prflag                      prflg1
650bAI              prprty                      prprt1
650bAI              prfree                      prfre1
650bAI              prstat                      prsta1
650bAI              prtype                      prtyp1
650bAI              prrplt                      prrpl1
650bAI              pradte                      pradt1
650bAI              pratim                      pratm1
650bAI              praqs                       praqs1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *STRPPR - Start Pushback Priority Replenishments
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $PUKY   Contains first key selected.
     *      $PRTN   blank    - No problem encountered.
     *              *OK      - Unique key exists for *VERIFY
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *
     *----------------------------------------------------------------
     *  Main line
     *
720bA*
720bA*  Convert today's date into century format.
720bA*
720bAC                   eval      $cvcmd = '*CURCMD '
720bAC                   call      @cvtdt
720bAC                   parm                    $cvtdt
720bAC                   eval      today = $cvd8o
      *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
650hAC     nxtscr        caseq     '051'         sc51
720 AC     nxtscr        caseq     '052'         sc52
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
500 AC     nxtscr        caseq     '09 '         sc9
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
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
     C                   select
510gAC                   when      nxtscr = '01 '  and #lline = '16'
650bAc                   eval      wocol = 9
510gAC                   exfmt     screen61                             50
     C                   when      nxtscr = '01 '
650bAc                   eval      wocol = 13
     C                   exfmt     screen1                              50
     *
510gAC                   when      nxtscr = '02 '  and #lline = '16'
510gAC                   exfmt     screen62                             50
     C                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
     *
510gAC                   when      nxtscr = '03 '  and #lline = '16'
510gAC                   exfmt     screen63                             50
     C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
     *
510gAC                   when      nxtscr = '04 '  and #lline = '16'
510gAC                   exfmt     screen64                             50
     C                   when      nxtscr = '04 '
     C                   exfmt     screen4                              50
     *
510gAC                   when      nxtscr = '05 '  and #lline = '16'
510gAC                   exfmt     screen65                             50
     C                   when      nxtscr = '05 '
     C                   exfmt     screen5                              50
650hAC                   when      nxtscr = '051'
650hAC                   exfmt     screen51
720 AC                   when      nxtscr = '052'
720 Ac                   if        firstRpl
720 AC                   exfmt     screen52
720 Ac                   endif
     *
510gAC                   when      nxtscr = '06 '  and #lline = '16'
510gAC                   exfmt     screen66                             50
     C                   when      nxtscr = '06 '
     C                   exfmt     screen6                              50
     *
510gAC                   when      nxtscr = '07 '  and #lline = '16'
510gAC                   exfmt     screen67                             50
     C                   when      nxtscr = '07 '
     C                   exfmt     screen7                              50
     *
510gAC                   when      nxtscr = '09 '  and #lline = '16'
510gAC                   exfmt     screen69                             50
500 AC                   when      nxtscr = '09 '
500 AC                   exfmt     screen9                              50
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
     C                   setoff                                       9298
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
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     *
720 Ac                   eval      firstrpl = *on
720 Ac                   eval      w5strloc = *blanks
650iAc                   eval      *in75 = *off
650iAc                   eval      *in07 = *off
650iAc                   eval      *in01 = *on
     C                   eval      nxtscr = '01 '
     *
650bAc*    if repack replenishment then show F10=Override Slot
650bAc                   if        pttask = 'REPLRP'
710dDc*                             and prrplt <> 'D'
650bAc                   eval      *in43 = *on
650bAc                   else
650bAc                   eval      *in43 = *off
650bAc                   endif
500tDC**   If no replenishments started, F12=Cancel is available.
500tDC**                 if        rplstr = '*NO '
500tDC**                 eval      *in93 = *off
500tDC**   Otherwise, F12=Cancel NOT available.
500tDC**                 else
500tDC**                 eval      *in93 = *on
500tDC**
500tDC**                 endif
     *
500dAC                   exsr      zzget1
     C                   exsr      zzfil1
650cAc                   eval      qtyGrtSlt = *off
     C                   eval      refrsh = *off
     *
     C     end01i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     *
     C                   eval      nxtscr = '02 '
     C                   eval      availf = 0
     C                   eval      hasvs = *off
     C                   eval      wozero = 'N'
     C                   eval      ptatyp = '*LICENSE'
500dAC                   exsr      zzget2
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C                   eval      rtnhom = *off
     *
500tDC**   If no replenishments started, F12=Cancel is available.
500cDC**                 if        rplstr = '*NO '
500tDC**                 eval      *in93 = *off
500tDC**   Otherwise, F12=Cancel NOT available.
500cDC**                 else
500cDC**                 eval      *in93 = *on
     *
500cDC**                 endif
     *
     C     end02i        endsr
730 A*
730 A*----------------------------------------------------------------
730 A*
730 A*  Check to see if this is a Drop Pick Replenishment
730 A*
730 AC     chkForDrpPck  begsr
     *
730 Ac                   eval      ddtosl=*blanks
730 Ac                   eval      *in75=*off
750aAc                   call      'GETDDSLOT'
750aAc                   parm                    ddwhse            3 0
750aAc                   parm                    ddwhdp            5
750aAc                   parm                    dditem           15
750aAc                   parm                    ddodisp          12
750aAc                   parm                    ddoaisle          3
750aAc                   parm                    ddoloc            3 0
750aAc                   parm                    ddddisp          12
750aAc                   parm                    dddaisle          3
750aAc                   parm                    dddloc            3 0
750aAc                   parm                    dddlvl            2 0
750aAc                   parm                    dddhand           2
750aAc                   parm                    ddqty             3 0
750aAc                   parm                    ddtype            1
750aAc                   parm                    ddtrntype         3
750aAc                   parm                    pReturn          10
      /free
750aA        if not validateOnly;
750aA             ddtosl = ddddisp;
750aA             exec sql update label
750aA                  set lbdsp2=:ddddisp,lbasl2=:dddaisle,lbloc2=:dddloc,
750aA                      lbhnd2=:dddhand,lblvl2=:dddlvl
750aA                  where lblbl#=:wulbl#;
750aA                  lbwhs2=lbwhse;
750aA                  lbwhd2=lbwhdp;
750aA                  lbdsp2=ddddisp;
730 A
730 A           // Since no virtual exist create one.  User will still
730 A           // be allowed to override if no allocation or pick quantity
730 A           // if they cancel we will remove and cleanup on the way out
730 A           exsr clr$slot;
730 A           $slwhseu = *on;
750aM           $slwhse  = lbwhse;
730 A           $slwhdpu = *on;
750aM           $slwhdp  = lbwhdp;
730 A           $sldispu = *on;
750aM           $sldisp  = ddtosl;
730 A           $slitemu = *on;
750aM           $slitem  = lbitem;
730 A           $dricommand = '*SLOT';
730 A           $drisubcmd = '%CRTVOFLW';
730 A           $drisys2upd = 'D';
730 A           exsr zzzdricop;
750aA       endif;
730 A
730 A /end-free
     *
730 AC     endchkdd      endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
500dAC                   exsr      zzget5
     C                   exsr      zzfil5
     *
     C                   eval      refrsh = *off
     *
     C     end05i        endsr
650hA*
650hA*----------------------------------------------------------------
650hA*
650hA*  Screen 051 initialization
650hA*
650hAC     scr051i       begsr
650hAC                   eval      nxtscr = '051'
650hA*
650hAC                   eval      refrsh = *off
650hAc                   eval      w5gs1 = ' '
650hA*
650hAC     end051i       endsr
720 A*
720 A*----------------------------------------------------------------
720 A*
720 A*  Screen 051 initialization
720 A*
720 AC     scr052i       begsr
720 AC                   eval      nxtscr = '052'
720 A*
720 AC                   exsr      zzget5
720 AC                   eval      refrsh = *off
720 Ac
720 Ac                   if        firstRpl = *blanks
720 Ac                   eval      w5strloc = ' '
720 Ac                   endif
720 A*
720 AC     end052i       endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     *
     C                   eval      nxtscr = '06 '
500fAC                   exsr      zzget6
     C                   exsr      zzfil6
     *
     C                   eval      refrsh = *off
     *
     C     end06i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   exsr      zzfil7
     C                   eval      refrsh = *off
     C     end07i        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  Screen 09 initialization
500 A*
500 AC     scr09i        begsr
     C                   eval      nxtscr = '09 '
     C                   exsr      zzfil9
     C                   eval      refrsh = *off
     C     end09i        endsr
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
500bAC                   exsr      zzabrt
500tDC**                 if        rplstr = '*YES'
500tAC                   if        (rpltyp = '*BRKDWN'
610kAC                             or rpltyp = '*REPACK'
720 AC                             or rpltyp = '*STRREPL'
650fAC                             or rpltyp = '*PROD'
750eAC                             or rpltyp = '*DROPP')
500tMC                             and workcount > 0
500 AC                   exsr      scr09i
500 AC                   else
500xMC                   eval      nxtscr = 'EOJ'
500xDC**                 exsr      scr07i
500 AC                   endif
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
     C     redspl        cabeq     *on           endsc1
     *
500iDC**                 eval      usrrpl = *off
     C                   eval      bypass = *off
     C                   eval      wkrtpo = '0'
     *
     *    Check installed feature level.
     *
     C                   eval      kywhse = $pwhse
     C                   exsr      zzfeat
     *
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
500 AC                   if        *inkl
500bAC                   exsr      zzabrt
500sDC**                 if        rplstr = '*YES'
500tAC                   if        (rpltyp = '*BRKDWN'
500tAC                             or rpltyp = '*REPACK'
720 AC                             or rpltyp = '*STRREPL'
650fAC                             or rpltyp = '*PROD'
750aAC                             or rpltyp = '*DROPP')
500tMC                             and workcount > 0
500 AC                   exsr      scr09i
500 AC                   else
500sDC**                 exsr      scr01i
500xDC**                 exsr      scr07i
500xMC                   eval      nxtscr = 'EOJ'
500 AC                   endif
500 AC                   goto      endsc2
500 AC                   endif
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
     C     redspl        cabeq     *on           endsc2
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
     C                   exsr      scr02i
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
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
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
     C                   eval      refrsh = *off
     C                   exsr      scr02i
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
     *
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
     *
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
650hAc     ScanGs1       cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     C     endsc5        endsr
650hA*----------------------------------------------------------------
650hA*
650hA*  SC51  -  Screen 51
650hA*
650hAC     sc51          begsr
650hA*
650hA*  Test for F3 - Exit
650hA*
650hAC                   if        *inkc
650hAC                   eval      nxtscr = 'EOJ'
650hAC                   goto      endsc51
650hAC                   endif
650hA*
650hA*  Test for F5 - Refresh
650hA*
650hAC                   if        *inke
650hAC                   eval      refrsh = *on
650hAC                   exsr      scr051i
650hAC                   goto      endsc51
650hAC                   endif
650hA*
650hA*  Test for F12 - Previous
650hA*
650hAC                   if        *inkl
650hA*
650hAC                   goto      endsc51
650hAC                   endif
650hA*
650hA*     Check input and write/update record.
650hA*
650hA*  User should only click F10 when they have no valid GS1
650hA*  and no time to have someone generate one to complete
650hA*  the replenishment.  This will write OVERRIDE GS1 in the
650hA*  GS1 field instead of the code itself
650hA*
650hAc     *inkj         cabeq     '1'           skpGS1
650hAc                   exsr      zzchk51
650hAC     error         cabeq     *on           endsc51
650hAc*
650hAc*  if all quantity delivered with GS1 transactions then return
650hAc*  to original replenishment code to complete updates
650hAc     skpGS1        tag
650hAC                   exsr      zzupd51
650hAC     error         cabeq     *on           endsc51
650hAc*
650hAc                   eval      gs1c = gs1c + 1
650hAc                   eval      gs1Count = gs1Count - 1
650hAc                   eval      w5gs1cnt = w5pulq - gs1count
650hAc                   if        gs1Count = 0
650hAc                   eval      nxtscr = '05 '
650hAc                   exsr      zzupd5
650hAc                   endif
650hA*
650hAc     endsc51       endsr
720 A*----------------------------------------------------------------
720 A*
720 A*  SC52  -  Screen 52
720 A*
720 AC     sc52          begsr
720 A*
720 A*  Test for F3 - Exit
720 A*
720 AC                   if        *inkc
720 AC                   eval      nxtscr = 'EOJ'
720 AC                   goto      endsc52
720 AC                   endif
720 A*
720 A*     Check input and write/update record.
720 A*
720 A*  Confirm that scanned location matches that of Store Replenishment Staging Area
720 A*
720 Ac                   exsr      zzchk52
720 AC     error         cabeq     *on           endsc52
720 Ac                   eval      firstRpl = *off
720 Ac                   exsr      zzupd5
720 Ac*
720 Ac* since user scanned correct Staging Location we will now dump
720 Ac* item into Staging Location
720 A*
720 Ac     endsc52       endsr
     *
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C     redspl        cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
500pAC                   if        lastslot <> ' '
500pAC                   exsr      zzreturnplt
500pAC                   endif
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     *
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
     C                   if        *inkl
     *
     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     C     error         cabeq     *on           endsc7
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
500 A*----------------------------------------------------------------
500 A*
500 A*  SC9  -  Screen 9
500 A*
500 AC     sc9           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr09i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     C     endsc9        endsr
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510cA*
510cA* Get client id.
510cA*
510cAC                   call      'GETCLIENT'
510cAC                   parm                    client           10
510cAC                   parm                    clientloc        10
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
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
510gAc                   select
510gAc                   when      #lline = '16'
510gAC                   write     m16ctl
510gAc                   other
     C                   write     msgctl
510gAc                   endsl
     C                   eval      msgk = *zeros
510gAc                   select
510gAc                   when      #lline = '16'
510gAC                   write     m16clr
510gAc                   other
     C                   write     msgclr
510gAc                   endsl
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
510gAc                   select
510gAc                   when      #lline = '16'
510gAC                   write     m16ctl
510gAc                   other
     C                   write     msgctl
510gAc                   endsl
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
510gAc                   select
510gAc                   when      #lline = '16'
510gAC                   write     m16rec
510gAc                   other
     C                   write     msgrec
510gAc                   endsl
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
510gAc                   select
510gAc                   when      #lline = '16'
510gAC                   write     m16rec
510gAc                   other
     C                   write     msgrec
510gAc                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   DRI0001  Interface error.
     *
     C     zm0001        begsr
     C                   movel     $drimessage   tempa2
     C                   if        tempa2 = 'H:'
     C                   eval      #msgid = 'DRI0002'
     C                   move      $drimessage   a58
     C                   eval      $drimessage = a58
     C                   else
     C                   eval      #msgid = 'DRI0001'
     C                   endif
     C                   eval      erdmsg = $drimessage
     C                   eval      erdrtn = $drireturn
     C                   eval      erdcmd = $dricommand
     C                   eval      erdsub = $drisubcmd
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

500 A*----------------------------------------------------------------
500 A*    DRI0001s Local system caused error (send to different program)
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001s       begsr
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

     *----------------------------------------------------------------
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20003 Put Away Quantity must be > 0.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'RC20003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20008 License/Label already scanned in.
     *
     C     zm2008        begsr
     C                   eval      #msgid = 'RC20008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29001  Invalid slot entered.(FROM)
     *
     C     zm2901        begsr
     C                   eval      #msgid = 'IT29001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29002  Invalid slot entered.(TO)
     *
     C     zm2902        begsr
     C                   eval      #msgid = 'IT29002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT29003 Qty cannot be > system assigned qty.
     *
     C     zm2903        begsr
     C                   eval      #msgid = 'IT29003'
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
500 A*----------------------------------------------------------------
500 A*      0105s
500 A*
500 AC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
650dA*----------------------------------------------------------------
650dA*    LP11022  License not on file.
650dA*
650dAC     zm022         begsr
650dAC                   eval      #msgid = 'LP11022'
650dAC                   eval      #msgtp = '*DIAG  '
650dAC                   eval      $md = *blanks
650dAC                   exsr      zmpmsg
650dAC                   endsr
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
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
     *
     C                   eval      error = *off
     *
     *  Update slot qty (Decrease RCV qty) (To Slot)
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #pickslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #pickslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #picksldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #pickslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem = #fromslitem
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
500qDC**                 if        pttask = 'REPLBK'
500qDC**                 eval      $saqty1 = -(svqrmn)
500qDC**                 else
600aDC**                 eval      $saqty1 = -(svqpck)
500qDC**                 endif
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PRINCHG'
500dDC**                 eval      drirtn = @noupd
600aDC**                 eval      chk4err = *off
500kDC**                 eval      drizm = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop
     *
500tDC**                 exsr      zztrnabort

     *  Update slot qty (Decrease TFR qty)

600aDC**                 exsr      clr$slot
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #fromslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #fromslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #fromsldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #fromslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem = #pickslitem
600aDC**                 eval      $satrn#u = *on
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = -(svqpck)
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
500sDC**                 eval      $drisubcmd = '%PROUT'
600aDC**                 eval      $drisubcmd = '%PROUTCHG'
600aDC**                 eval      chk4err = *off
500kDC**                 eval      drizm = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop
     *
     *    Update label record.
     *
     C     lbkey         chain     label                              79
     C                   select
     C                   when      usrrpl = *on  and
     C                             not *in79
     C                   delete    lbrec
     *
     C                   other
     C                   if        not *in79
     C                   eval      lbqalc = svqalc
     C                   eval      lbqpck = svqpck
     C                   eval      lbcube = svcube
     C                   eval      lbswgt = svswgt
     C                   eval      lbqrmn = svqrmn
     C                   update    lbrec
     C                   endif
     *
     C                   endsl
     *
     C                   eval      crtdsc = *on
     *
     *    Reset priority replenishment so it can be processed later.
     *
500tAC                   eval      bypass = *on
     C     prky6e        chain     prplfil6                           7978
     C                   if        not *in79
     C                   eval      prflag = 'S'
720 Ac*  Zap To Location fields for Store Replen Stage type
720 Ac                   if        rpltyp='*STRREPL'
720 Ac                   eval      prtdis=*blanks
720 Ac                   eval      prtloc=*zeros
720 Ac                   eval      prtlvl=*zeros
720 Ac                   eval      prthnd=*blanks
720 Ac                   endif
     C                   update    prrec                                78
     C                   endif
500sD*
500sD*  Update license history.
500sD*
500sDC**                 exsr      zzzclr$lt210
500sDC**                 eval      $tcmd  = '*PULUNDO'
500sDC**                 eval      $tlic# = curlic#
500sDC**                 exsr      zzzcall$lt210
     *
     *    If balance left over from replenishment, undo transfer rcd.
     *
     C                   if        pttask = 'REPL    '  and
     C                             lbctr# > *zero  or
     C                             pttask = 'REPLBK  '  and
     C                             lbctr# > *zero
     C                   endif
500tA*
500tA*    Delete work record for label.
500tA*
500tAC                   exsr      zzdlwr1

720 Ac*  Remove the RPADOCK slot for "S" Store Repln Types
     c*  once the Workusr record is deleted
720 Ac                   if        rpltyp='*STRREPL'
720 Ac                   eval      getwhse=#fromslwhse
720 Ac                   eval      curwhd=#fromslwhdp
720 Ac                   eval      svfdis=#fromsldisp
720 Ac                   eval      #fromslwhse=#pickslwhse
720 Ac                   eval      #fromslwhdp=#pickslwhdp
720 Ac                   eval      #fromsldisp=#picksldisp
720 A /free
720 A             exec sql update slot2 set slstat='Z'
720 A                     where slwhse=:#fromslwhse and slwhdp=:#fromslwhdp
720 A                       and sldisp=:#fromsldisp and slstk1=0 and
720 A                       slstk2=0 and slstk3=0;
720 A /end-free
720 Ac                   exsr      zzzerovfy
720 Ac                   eval      #fromslwhse=getwhse
720 Ac                   eval      #fromslwhdp=curwhd
720 Ac                   eval      #fromsldisp=svfdis
720 Ac                   endif
750aAc*  Remove the Drop Pick slot if no activity when user
750aAc*  cancel replenishment
750aAc                   if        prrplt='D' or prtdis='*DDSLOT'
750aAc                   eval      getwhse=#fromslwhse
750aAc                   eval      curwhd=#fromslwhdp
750AAc                   eval      svfdis=#fromsldisp
750aAc                   eval      #fromslwhse=#pickslwhse
750aAc                   eval      #fromslwhdp=#pickslwhdp
750aA /free
750aA             // Get Virtual Drop Pick slot from base slot if one exists
750aA             exec sql select sldisp into :#fromsldisp
750aA                   from slot2,vslot2
750aA               where slwhse=vswhse and slwhdp=vswhdp and sldisp=vsdisp
750aA                 and vspdis=:#picksldisp and slstat='DP'
750aA                 and sldesg='*DROP' fetch first row only;
750aA             exec sql update slot2 set slstat='Z'
750aA                     where slwhse=:#fromslwhse and slwhdp=:#fromslwhdp
750aA                       and sldisp=:#fromsldisp and slstk1=0 and
750aA                       slstk2=0 and slstk3=0 and
750aA                       slalc1=0 and slalc2=0 and slalc3=0 and
750aA                       slrcv1=0 and slrcv2=0 and slrcv3=0 and
750bA                       slpck1=0 and slpck2=0 and slpck3=0;
750aA /end-free
750aAc                   exsr      zzzerovfy
750aAc                   eval      #fromslwhse=getwhse
750aAc                   eval      #fromslwhdp=curwhd
750aAc                   eval      #fromsldisp=svfdis
750aAc                   endif
500tA*
500tA*    Abort transaction when ...
500tA*      - Working with Flowrack replenishments (one at a time)
500tA*      - No more work records.
500tA*
500tAC                   if        rpltyp = '*FLOW'
500tAC                             or workcount <= 0

500tAC                   exsr      zztrnabort
     *
     C                   eval      usrrpl = *off
     *
     *    Start an 'IDLE' task.
     *
500tDC****               if        bypass = *off
     *
     *    Start an 'IDLE' task, if no open task.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C                   if        curent = *off
     C                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
     C                   endif
500tA
500tA*    Return pallet.
500tA
750 A *    it was flashing a previous LT210 screen when pressing F9 to skip
750 Ac                   if        bypass = *off and nxtscr = '01'
500tAC                   exsr      zzzclr$lt210
500tAC                   eval      $tcmd  = '*PULRTN'
500tAC                   eval      $twhdp  = #fromslwhdp
500tAC                   eval      $tslot  = #fromsldisp
500tAC                   eval      $titem  = #fromslitem
500tAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
500tAC                   exsr      zzzcall$lt210
500tAC                   if        $treturn <> '*OK'
500tAC                   endif
750 AC                   endif

     C                   endif

     C     endabr        endsr
500tA*----------------------------------------------------------------
500tA*
500tA*  ZZABRTSKIP  Skip last item pulled.
500tA*
500tAC     zzabrtskip    begsr
     *
     C                   eval      error = *off
     *
     *  Update slot qty (Decrease RCV qty) (To Slot)
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #pickslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #pickslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #picksldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #pickslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem = #fromslitem
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = -(svqpck)
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PRINCHG'
600aDC**                 eval      chk4err = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop

     *  Update slot qty (Decrease TFR qty)

600aDC**                 exsr      clr$slot
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #fromslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #fromslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #fromsldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #fromslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem = #pickslitem
600aDC**                 eval      $satrn#u = *on
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = -(svqpck)
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PROUTCHG'
600aDC**                 eval      chk4err = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop
     *
     *    Update label record.
     *
     C     lbkey         chain     label                              79
     C                   select
     C                   when      usrrpl = *on  and
     C                             not *in79
     C                   delete    lbrec
     *
     C                   other
     C                   if        not *in79
     C                   eval      lbqalc = svqalc
     C                   eval      lbqpck = svqpck
     C                   eval      lbcube = svcube
     C                   eval      lbswgt = svswgt
     C                   eval      lbqrmn = svqrmn
     C                   update    lbrec
     C                   endif
     *
     C                   endsl
     *
     C                   eval      crtdsc = *on
     *
     *    Reset priority replenishment so it can be processed later.
     *
500tAC                   eval      bypass = *on
     C     prky6e        chain     prplfil6                           7978
     C                   if        not *in79
     C                   eval      prflag = 'S'
720 Ac*  Zap To Location fields for Store Replen Stage type
720 Ac                   if        rpltyp='*STRREPL'
720 Ac                   eval      prtdis=*blanks
720 Ac                   eval      prtloc=*zeros
720 Ac                   eval      prtlvl=*zeros
720 Ac                   eval      prthnd=*blanks
720 Ac                   endif
     C                   update    prrec                                78
     C                   endif
500tA*
500tA*    Delete work record for label.
500tA*
500tAC                   exsr      zzdlwr1

720 Ac*  Remove the RPADOCK slot for "S" Store Repln Types
720 Ac                   if        rpltyp='*STRREPL'
720 Ac                   eval      getwhse=#fromslwhse
720 Ac                   eval      curwhd=#fromslwhdp
720 Ac                   eval      svfdis=#fromsldisp
720 Ac                   eval      #fromslwhse=#pickslwhse
720 Ac                   eval      #fromslwhdp=#pickslwhdp
720 Ac                   eval      #fromsldisp=#picksldisp
720 A /free
720 A             exec sql update slot2 set slstat='Z'
720 A                     where slwhse=:#fromslwhse and slwhdp=:#fromslwhdp
720 A                       and sldisp=:#fromsldisp and slstk1=0 and
720 A                       slstk2=0 and slstk3=0;
720 A /end-free
720 Ac                   exsr      zzzerovfy
720 Ac                   eval      #fromslwhse=getwhse
720 Ac                   eval      #fromslwhdp=curwhd
720 Ac                   eval      #fromsldisp=svfdis
720 Ac                   endif

     C     endabrskp     endsr

500dA*----------------------------------------------------------------
500dA*  ZZASKZROVFY  See if we should ask user to zero verify the slot
500dA*----------------------------------------------------------------
500dA
500dAC     zzaskzrovfy   begsr
500dAC                   eval      askzrovfy = *off

500tA*  Temporarily never ask to zero verify.
500tAC                   goto      endaskzrovfy

     C                   dow       forever = forever

     *  Ask the user to zero verify slot if ...

     *  ... the replenishment is not for a Breakdown item.

     C** ?????           if        rpltype = 'B'
     C** ?????           leave
     C** ?????           endif

     *  ... the slot only has 1 pallet position.

     C                   if        #fromslpos > 1
     C                   leave
     C                   endif

     *  ... the slot doesn't have a virtual slot associated with it.

     C                   if        #fromslvirt = 'Y'
     C                   leave
     C                   endif
600aA
600aA*      ... %TFR2USR, which is called just before calling this
600aA*          routine, says the slot is empty.
600aA
600aAC                   if        wuPulVfy <> 'Y'
600aAC                   leave
600aAC                   endif
600aDC**
600aDC** ... slot quantities don't reflect other activity.
600aDC**
600aDC**                 if        #fromslalc1 <> 0 or
600aDC**                           #fromslalc2 <> 0 or
600aDC**                           #fromslalc3 <> 0 or
600aDC**                           #fromslrcv1 <> 0 or
600aDC**                           #fromslrcv2 <> 0 or
600aDC**                           #fromslrcv3 <> 0 or
600aDC**                           #fromsltfr1 <> 0 or
600aDC**                           #fromsltfr2 <> 0 or
600aDC**                           #fromsltfr3 <> 0
600aDC**                 leave
600aDC**                 endif

     *  ... slot is either not a virtual slot or
     *      it is the only virtual and the base slot is empty.

     C                   if        #fromslrsrv = 'V'

     *        Get base slot info.

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #frombasesldsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
500kAC                   eval      chk4err = *on
     C                   exsr      zzzdricop
500kDC**                 if        error
500kMC                   if        drierr
     C                   leave
     C                   endif

     *        Status must be 'Z' or 'V'

     C                   if        $slstat <> 'V' and $slstat <> 'Z'
     C                   leave
     C                   endif

     *        See if any other virtuals are associated with slot.

     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp = $sldisp
     C                   eval      $sldisp = ' '
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTVSLOT'
     C                   eval      $drisys2upd = 'D'
500kAC                   eval      chk4err = *on
     C                   dow       forever = forever
     C                   exsr      zzzdricop
500kMC                   if        drierr or $drireturn = 'EOF'
     C                   leave
     C                   endif
     C                   if        $sldisp = #fromsldisp
     C                   iter
     C                   endif
     C                   leave
     C                   enddo
     C                   if        $drireturn <> 'EOF'
     C                   leave
     C                   endif

     C                   endif

     *  Whew! We have finally determined that we can have the user
     *     verify if the slot is physically empty.

     C                   eval      askzrovfy = *on

     C                   leave
     C                   enddo

     C     endaskzrovfy  endsr

     *----------------------------------------------------------------
     *
     *  ZZCLS0   Close transaction to Zero
     *
     C     zzcls0        begsr
     *
     C                   eval      topick = *zeros
     *    Update pick quantity in label record.
     C     lbkey         chain     label                              79

500dAC                   eval      lbqpck = 0
500dAC                   eval      lbqrmn = 0
500dAC                   eval      lbcube = 0
500dAC                   eval      lbswgt = 0
500zA*    No qty putaway. Close label record.
500zAC                   eval      lbstat = 'C'
500zAC                   exsr      zzgetdatetime
500zAC                   eval      lbsdte = curdate
500zAC                   eval      lbstim = curtime

     C                   update    lbrec

     *    Update quantity in transaction record.

500dMC     ptkey         chain(n)  pirtran                            79
500dAC                   exsr      zztrnzero

     *    Update transfer quantity in slot record.(From slot)

600aDC**                 exsr      clr$slot
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #fromslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #fromslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #fromsldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #fromslitem
600aDC**                 eval      $satrn#u = *on
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = -(svqpck)
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PROUT'
600aDC**                 eval      chk4err = *off
500kDC**                 eval      drizm = *off
600aDC**                 eval      zmsflag = *off
     C                   exsr      zzzdricop
     *
     *    Update receive quantity in slot record.(To slot)
     *
     *
600aDC**                 exsr      clr$slot
     *
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #pickslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #pickslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #picksldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #pickslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem  = #fromslitem
600aDC**                 eval      $satrn#u = *on
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = -(svqpck)
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PRIN'
600aDC**                 eval      chk4err = *off
500kDC**                 eval      drizm = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop
     *
     C     endcl0        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
510gAC*
510gA * Set worow/wocol based on the size of the screen being processed
510gAc                   select
510gAc                   when      #lline = '16'
510gAc                   eval      worow = 8
510gAc                   eval      wocol = 9
510gAc                   other
650dAc                   if        w1lcns = ' '
510gAc                   eval      worow = 6
510gAc                   eval      wocol = 13
650dAc                   else
510gAc                   eval      worow = 5
510gAc                   eval      wocol = 13
650dAc                   endif
510gAc                   endsl
650dA*
650dA*  Verify License if entered.
650dA*
650dAC                   if        w1lcns <> ' '
650dAC                   exsr      clr$license
650dAC                   eval      $liToLcnsU = *on
650dAC                   eval      $liToLcns = w1lcns
650dAC                   eval      $dricommand = '*LICENSE'
650dAC                   eval      $drisubcmd  = '%GETINFO'
650dAC                   eval      $drisys2upd = 'D'
650dAC                   eval      chk4err = *on
650dAC                   exsr      zzzdricop
650dA
650dAC                   if        drierr
650dAc                             or $liToDisp = '<not active>'
650dAC                   eval      error = *on
650dAC                   eval      *in25 = *on
650dAC                   eval      *in07 = *on
650dAC                   eval      errmsg = *blanks
650dAC                   exsr      zm022
650dAC                   goto      endck1
650dAC                   else
650dA*  if user scans a License where the item does not match the
650dA*  replenishment stop with an error
650dAc                   if        #fromslItem <> $litoItem
650dAC                   eval      error = *on
650dAC                   eval      *in25 = *on
650dAC                   eval      *in07 = *on
650dAC                   eval      errmsg = desc(32)
650dAC                   exsr      zm0105
650dAC                   goto      endck1
650dAc                   else
650dAC                   eval      w1scan = $litobase
650dAC                   eval      w1fmsl = $litobase
650dAc                   exsr      zzspfc
650dAc                   endif
650dAC                   endif
650dAC                   endif
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w1scan
510gDC*                  parm      6             worow
510gDC*                  parm      13            wocol
510gMC                   parm                    worow
510gMC                   parm                    wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck1
     C                   endif
     *
     *    Slot can't be blank.
     *
     C                   if        w1scan = ' '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(4)       errmsg
     C                   exsr      zm0203
500nAC                   goto      endck1
     C                   endif
     *
     *    Slot must match From slot.
     *
500dMC                   if        w1scan <> #frombasesldsp
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = lbdisp
     C                   exsr      zm2901
500nAC                   goto      endck1
     C                   endif
     *
500nAC                   eval      lastslot = w1scan
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      rtnhom = *off
500lA*
500lA*    Cannot pull more qty than is currently in the slot
500lA*    or Contract item types cannot have replenishment qty
500lA*    increased.
500lA*
700dDC*                   if        w2nqty > w2sltq  or
700dAC                   if        (not *in76 and w2nqty > w2sltq) or
500lA*
500lAC                             w2nqty > w2repq  and
500lAC                             svtype = 'C'
500lA*
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
500lAC                   eval      errmsg = *blanks
500lAC                   if        svtype = 'C'
500lAC                   eval      erqty = w2repq
500lAC                   else
500lAC                   eval      erqty = w2sltq
500lAC                   endif
500lAC                   eval      ernqty = w2nqty
500lAC                   exsr      zm2903
500lAC                   goto      endck2
500lAC                   endif
500lA*
500lA*    Replenish qty cannot be less than zero.
500lA*
500lAC                   if        w2nqty < 0
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
500lAC                   eval      errmsg = desc(12)
500lAC                   exsr      zm0105
500lAC                   goto      endck2
500lAC                   endif

700dA /free
700dA  // Breakdown pull quantity can't be greater than replenishment
700dA  // quantity nor total slot quantity.
700dA  if *in76 and w2nqty > ttlLowW2sltq;
700dA    error = *on;
700dA    *in23 = *on;
700dA    *in03 = *on;
700dA    errmsg = desc(18);
700dA    exsr zm0105;
700dA    leavesr;
700dA  endif;
700dA /end-free

500lA*
500lA*    Pull qty cannot be greater than slot qty.
500lA*
500lAC                   if        w2nqty > w2sltq
700dAC                             and not *in76
500lAC                   eval      error = *on
500lAC                   eval      *in23 = *on
500lAC                   eval      *in03 = *on
500lAC                   eval      errmsg = desc(18)
500lAC                   exsr      zm0105
500lAC                   goto      endck2
500lAC                   endif
650cA
650cA*
650cA*    Qty must match either slot quantity or Replenishment qty
650cA*    when a repack replenishment is being processed
650cA*    This prevents user from selecting a partial quantity
650cA*    times against the same slot and causing a duplicate key in
650cA*    Workusr.  We could have approached by changing original
650cA*    Workusr, Label, pirtran and linceses but felt this would?
650cA*    work and the user would typically not need to pull partial
650cA*    quantity on two different passes for the same slot
650cA*
650eA*    only enforce for WORK ORDER replenishments
650cAc                   if        rpltyp = '*REPACK'
650fAc                              or rpltyp = '*PROD'
750aAc                              or rpltyp = '*DROPP'
720 Ac                              or rpltyp = '*STRREPL'
650cAC                   if        w2nqty <> w2sltq
650cAC                             and w2nqty < w2repq
650eAc                             and #pickslaisl = 'RPK'
CSP Ac                             and client = coastl
650cAC                   eval      error = *on
650cAC                   eval      *in23 = *on
650cAC                   eval      *in03 = *on
650cAC                   eval      errmsg = desc(31)
650cAC                   exsr      zm0105
650cAC                   goto      endck2
650cAC                   endif
650cAC                   endif

     *    Save To slot side, pick sequence to update workfile.

500dMC                   eval      svtsid = #pickslside
500dMC                   eval      svtseq = #pickslpseq
     *
     *    Re-compute From slot qty as it may have changed.
600aD*    No longer necessary when using new USR slots.
     *
600aDC**                 eval      getwhse = lbwhse
600aDC**                 eval      getwhdp = lbwhdp
600aDC**                 eval      getdisp = lbdisp
600aDC**                 exsr      zzgetfromsl
     *
     *    Save From slot side, pick sequence to update workfile.
     *
500dMC                   eval      svfsid = #fromslside
500dMC                   eval      svfseq = #fromslpseq
     *
     C                   eval      w2sltq = #fromslstk1 + #fromslrcv1
     C                   if        w2sltq < *zeros
     C                   eval      w2sltq = *zeros
     C                   endif
500dMC                   eval      rpldif = #fromsltfr1 - svqpck
     *
     *    Check if product is allocated or picked. If yes, then flag
     *    any overflow to come back to this slot.
600aD **** Or more than one replenishment exists from this slot.
500mA*    Or tracking slot position and slot has multiple positions.
     *
600aAC                   eval      rtnhom = *off
     *
500dMC                   if        #fromslpck1 <> 0  or
500dMC                             #fromslpck2 <> 0  or
500dMC                             #fromslpck3 <> 0  or
     *
500dMC                             #fromslalc1 <> 0  or
500dMC                             #fromslalc2 <> 0  or
500dMC                             #fromslalc3 <> 0  or
     *
500dMC                             #fromslrcv1 <> 0  or
500dMC                             #fromslrcv2 <> 0  or
600aMC                             #fromslrcv3 <> 0
     *
600aDC**                           rpldif <> 0
500mA*
500vDC**                           trackpos = 'Y' and #fromslpos > 1
     C                   eval      rtnhom = *on
     C                   endif
500lDC**
500lDC**  Cannot pull more qty than is currently in the slot
500lDC**  or Contract item types cannot have replenishment qty
500lDC**  increased.
500lDC**
500lDC**                 if        w2nqty > w2sltq  or
500lDC**
500lDC**                           w2nqty > w2repq  and
500lDC**                           svtype = 'C'
500lDC**
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = *blanks
500lDC**                 if        svtype = 'C'
500lDC**                 eval      erqty = w2repq
500lDC**                 else
500lDC**                 eval      erqty = w2sltq
500lDC**                 endif
500lDC**                 eval      ernqty = w2nqty
500lDC**                 exsr      zm2903
500lDC**                 endif
500lDC**
500lDC**  Replenish qty cannot be less than zero.
500lDC**
500lDC**                 if        w2nqty < 0
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = desc(12)
500lDC**                 exsr      zm0105
500lDC**                 endif
500lDC**
500lDC**  Pull qty cannot be greater than slot qty.
500lDC**
500lDC**                 if        w2nqty > w2sltq
500lDC**                 eval      error = *on
500lDC**                 eval      *in23 = *on
500lDC**                 eval      *in03 = *on
500lDC**                 eval      errmsg = desc(18)
500lDC**                 exsr      zm0105
500lDC**                 endif
500dA
500dA*  Use DRI interface to do rest of the verifications.
500dA
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu  = *on
500dAC                   eval      $slwhse   = #fromslwhse
500dAC                   eval      $slwhdpu  = *on
500dAC                   eval      $slwhdp   = #fromslwhdp
500dAC                   eval      $sldispu  = *on
500dAC                   eval      $sldisp   = #fromsldisp
500dAC                   eval      $saitemu  = *on
500dAC                   eval      $saitem   = #fromslitem
500dAC                   eval      $sacitemu  = *on
500dAC                   eval      $sacitem   = #pickslitem
500dAC                   eval      $saqtyu   = *on

730 MC                   if        prtype = 'E' and (prrplt = 'O' or prrplt='D')
700dAC                   eval      $saqty1   = 0
700dAC                   eval      $saqty2   = w2nqty
700dAC                   eval      $saqty3   = 0
700dAC                   else
500dAC                   eval      $saqty1   = w2nqty
500dAC                   eval      $saqty2   = 0
500dAC                   eval      $saqty3   = 0
700dAC                   endif
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%VFYPROCHG'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500kMC                   if        drierr
500kAC                   eval      error = *on
500dAC                   exsr      zm0001
500dAC                   goto      endck2
500dAC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     *    Verify Zero, Y,N
     *
     C                   if        w3zero <> 'Y'  and
     C                             w3zero <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm1005
     C                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     C                   eval      errflg = *off
650hA*
650hA*  Clear array that holds multiple GS1 for each scan
650hA*
650hAc                   eval      gs1c = 1
650hAc                   dow       gs1c < 501
650hAc                   eval      gs1(gs1c) = *blanks
650hAc                   eval      gs1c = gs1c + 1
650hAc                   enddo
650hAc                   eval      gs1c = 1
610cA*
610cA*  User is allowed to enter zero qty.
610cA*  If zero qty is entered there is nothing else to check,
610cA*  Therefore, get out.
610cA*
610cAC                   if        w5nqty = 0
610cAC                   leavesr
610cAC                   endif
610cA *
510gA * Set worow/wocol based on the size of the screen being processed
510gAc                   select
510gAc                   when      #lline = '16'
510gAc                   eval      worow = 11
510gAc                   eval      wocol = 9
510gAc                   other
510gAc                   eval      worow = 6
510gAc                   eval      wocol = 29
510gAc                   endsl
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w5scan
510gDC*                  parm      6             worow
510gDC*                  parm      29            wocol
510gMC                   parm                    worow
510gMC                   parm                    wocol
     C                   parm                    @artn
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck5
     C                   endif
     *
     *    Verify display.(TO slot)
     *
750aA /free
750aA      // When Drop Pick and user scans different slot than suggested we
750aA      // confirm it is a valid drop pick slot and the chkfordrppck rtn
750aA      // will confirm the slot can hold another item
750aA                    if prrplt='D';
750aA                      if w5scan <> #pickbasesldsp;
750aA                        validateOnly = *on;
750aA    // When validate only the system will not create a Virtual Drop Pick Slot.
750aA    // Wil only ensure this is a drop pick slot and it has an available Drop Pick Slot
750aA                        ddwhse=#fromslwhse;
750aA                        ddwhdp=#fromslwhdp;
750aA                        dditem=#fromslitem;
750aA                        ddodisp=#fromsldisp;
750aA                        ddoaisle=#fromslaisl;
750aA                        ddoloc=#fromslloc;
750aA                        ddddisp=w5scan;
750aA                        dddaisle=*blanks;
750aA                        dddloc=0;
750aA                        dddlvl=0;
750aA                        dddhand=*blanks;
750aA                        ddqty=0;
750aA                        ddtype=' ';
750aA                        ddtrntype='RPL';
750aA                        pReturn=*blanks;
750aA                        exsr chkforDrpPck;
750aA                        if pReturn <> '*OK';
750aA                          error = *on;
750aA                          *in23 = *on;
750aA                          *in03 = *on;
750aA                          errmsg='Either invalid Drop Pick or ' +
750aA                                 'slot has max items';
750aA                          exsr zm0105;
750aA /end-free
750aAc                   goto      endck5
750aA /free
750aA                        endif;
750aA                      endif;
750aA                    endif;
750aA /end-free
750aAc
750aMC                   if        (w5scan <> #pickbasesldsp and
750aMc                              $sldesg = '*DROP' and
750aDc*                            ($slalc1<>0 or $slalc2<>0 or $slalc3<>0 or
750aMc*                             $slpck1<>0 or $slpck2<>0 or $slpck3<>0))
750aMc                             (#pickslalc1<>0 or #pickslalc2<>0
750aMc                                  or #pickslalc3<>0 or
750aMc                               #pickslpck1<>0 or #pickslpck2<>0
750aMc                                  or #pickslpck3<>0))
750aMC                   eval      error = *on
750aMC                   eval      *in23 = *on
750aMC                   eval      *in03 = *on
750aMC                   eval      errmsg = *blanks
750aMC                   eval      errmsg='When allocated you cannot change'
750aMC                   exsr      zm0105
750aMC                   goto      endck5
750aMC                   endif
     *
     *    Replenish qty cannot be less than zero.
     *
     C                   if        w5nqty < 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(12)
     C                   exsr      zm0105
500lAC                   goto      endck5
     C                   endif
     *
     *    Replenish qty cannot be greater than slot qty for
     *    base items. Breakdown items must be same as repl. qty.
500qA*
500qA*    Screen 3 now deals with full cases, not brkdwn qtys.
     *
500qDC**                 if        w5nqty > w5pulq  and
500qDC**                           pttask <> 'REPLBK  '  or
     *
500qDC**                           pttask = 'REPLBK  '  and
500qDC**                           w5nqty > w5repq
500qA
500qMC                   if        w5nqty > w5pulq
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(19)
     C                   exsr      zm0105
500lAC                   goto      endck5
     C                   endif
     *
500dA
500dA*  Use DRI interface to do rest of the verifications.
500dA
500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu  = *on
500dAC                   eval      $slwhse   = #pickslwhse
500dAC                   eval      $slwhdpu  = *on
500dAC                   eval      $slwhdp   = #pickslwhdp
500dAC                   eval      $sldispu  = *on
500dAC                   eval      $sldisp   = #picksldisp
500dAC                   eval      $slexpdu  = *on
500dAC                   eval      $slexpd   = #fromslexpd
500dAC                   eval      $saitemu  = *on
500dAC                   eval      $saitem   = #pickslitem
500dAC                   eval      $saqtyu   = *on
500dAC                   eval      $saqty1   = w5nqty
500dAC                   eval      $saqty2   = 0
500dAC                   eval      $saqty3   = 0
500dAC                   eval      $sacitemu = *on
500dAC                   eval      $sacitem  = #fromslitem
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%VFYPRICHG'
500dAC                   eval      $drisys2upd = 'D'
500dAC                   eval      chk4err = *on
500dAC                   eval      zmsflag = *off
500dAC                   exsr      zzzdricop
500kMC                   if        drierr
500kAC                   eval      error = *on
500dAC                   eval      *in23 = *on
500dAC                   eval      *in03 = *on
500dAC                   goto      endck5
500dAC                   endif
      *
650hA *  if option set force user to scan valid GS1
650hAc                   if        ScanGs1
650hAc                   eval      nxtscr = '051'
650hAc                   eval      gs1count = w5nqty
650hAc                   eval      w5gs1cnt = 0
650hAc                   else
650hAc*  if production settings do not require GS1 case barcode be
650hAc*  scanned we should still write rplenishment action to prodlog
730 Mc                   if        $prplt = 'O'
650hAc                   eval      gs1c = gs1c + 1
650hAc                   eval      hldgs1(gs1c) = 'NO GS1 REQUIRED'
650hAc                   eval      hldwgt(gs1c) = 999999.999
650hAc                   eval      hldser(gs1c) = *blanks
650hAc                   endif
650hAc                   endif

     C     endck5        endsr
650hA*----------------------------------------------------------------
650hA*
650hA*  ZZCHK51  Screen 51 error checking.
650hA*
650hAC     zzchk51       begsr
650hAC                   eval      error = *off
650hAC                   eval      errflg = *off
650hA *   Pass scanned GS1 to verify validity.  Once confirmed
650hA *   add if not already present
650hAC                   eval      error = *off
650hAC                   eval      refrsh = *on
650hA *
650hA * make sure scanned bar code represents valid UCI and UPC
650hA *
650hAc                   eval      wkupcd = ' '
650hAC                   eval      $cbcmd = '*ALL    '
650hAC                   eval      $cbbar = w5gs1
650hAc                   clear                   $barcode
650hAc                   clear                   $barcode2
650hA*
650hAC                   call      'CVTBAR'
650hAC                   parm                    $cbcmd            8
650hAC                   parm                    $cbbar          100
650hAC                   parm                    $cbcod            3 0
650hAC                   parm                    $cbdec            1 0
650hAC                   parm                    $cbdsc           30
650hAC                   parm                    $cbpos            3 0
650hAC                   parm                    $cbtyp            1 0
650hAC                   parm                    $cbv1            11 3
650hAC                   parm                    $cbv2            50
650hAC                   parm                    $cbrtn            8
650hAC                   parm                    $cberm           60
650hAC                   parm                    $cbven           10 0
650hAC                   parm                    $cvtdata
650hAC                   parm                    $cvtdata2
650hA
650hAc                   eval      $barcode = $cvtdata
650hAc                   eval      $barcode2 = $cvtdata2
650hA * Load UPC
650hA * if gtin not found, error for invalid barcode scanned
650hAc                   if        not $bcGtinSent
650hAc                   eval      error = *on
650hAc                   eval      errmsg = desc(34)
650hAc                   exsr      zm0105
650hA *  invalid barcode scanned
650hAc                   else
650hAc                   eval      $cstr = ' '
650hAc                   eval      $cstr = $bcGtin
650hAc                   call      'ADJUST'
650hAc                   parm      '*RIGHT  '    $CCMD             8
650hAc                   parm                    $CSTR            30
650hAc                   move      $cstr         ckupc
650hA /free
650hA   chain (#pickslwhse: ckupc) upc;
650hA   if %found(upc);
650hA      // issue error is found but item differs
650hA      if upitem <> #pickslitem;
650hA         error = *on;
650hA         errmsg = desc(32);
650hA         exsr zm0105;
650hA      endif;
650hA   else;
650hA      // upc not found so I throw error.  it might be that we
650hA      // want to automatically add upc record
650hA      error = *on;
650hA      errmsg = desc(34);
650hA      exsr zm0105;
650hA   endif;
650iA  // if breakdown replenishment then confirm UCI scanned is
650iA  // is a breakdown UCI found in UCISPLITS file
730 M      if prtype='E' and (prrplt='O' or prrplt='D');
650iA          exec sql
650iA           select count(*)
650iA           into :UCISPLTCNT :NullInds
650iA           from UciSplits
650iA            where usgs1b = :w5gs1;
650iA         if sqlstt <> '00000' or NullInds = -1
650iA            or ucispltcnt = 0 or ucispltcnt > 1;
650iA            error = *on;
650iA            errmsg = 'Scanned UCI not valid Breakdown UCI';
650iA            exsr zm0105;
650iA         endif;
710 A      endif;
650hA                    endif;
650hA
650hA   // check to see if scanned UCI exists and not issued
650hA   if w5gs1 <> ' ' and not error;
650hA     exsr clr$uciinfo;
650hA
650hA     $uiWhse = #pickslwhse;
650hA     $uiuci  = w5gs1;
650hA     $uiitem = #pickslitem;
650hA     $uiseq = 0;
650hA
650hA     $drisubcmd  = '%CHKREPLEN';
650hA     $dricommand = '*UCIINFO';
650hA     $drisys2upd = 'D';
650hA     chk4err = *on;
650hA     exsr zzzdricop;

          if $drireturn = '*OKADD' or $drireturn = '*OKUPD';
             $drimessage = ' ';
650hA        exsr clr$uciinfo;
650hA        $uiWhse = #pickslwhse;
650hA        $uiItem = #pickslitem;
650hA        $uiuci = w5gs1;
650hA        ucilic#($unext: #pickslwhse);
650hA        unexta = %editc($unext:'X');
650hA        $uiuciLcns = 'U:' + unexta;
650hA        $uiLcns = $tinlic#;
650hA        $uiseq = 1;
650hA        $uiSerial = $bcSer#;
650hA        if $bcSer#Sent;
650hA           hldser(gs1c) = $bcSer#;
650hA        else;
650hA           hldser(gs1c) = $bcLot;
650hA        endif;
650hA   // if user entered weight use that if uci had weight use that
650hA        select;
650hA           when $bcPNtLbSent = *on;
650hA             $uiwgtlbs = $bcPNtLb;
650hA             hldWgt(gs1c) = $bcPNtLb;
650hA           other;
650hA             hldWgt(gs1c) = 0;
650hA             $uiwgtlbs = 0;
650hA        endsl;
650hA   // Weight KG  - only if uci barcode contained KG
650hA        if $bcPNtKgSent = *on;
650hA           $uiWgtKgs = $bcPntKg;
650hA           hldWgt(gs1c) =$bcPNtKg * 2.2046;  // convert to pounds log
650hA        else;
650hA           $uiWgtKgs = 0;               // do not zero log weight ould
650hA        endif;
650hA
650hA        $uiSelTrn# = lbtrn#;
650hA        $uiSelLbl# = lblbl#;
650hA        $uiSelOrd = 0;
650hA        $uiSelSeq = 0;
650hA        $uiSelCSeq = 0;
650hA        $uiSelTrax = ' ';
650hA        $uiCrtBy = '9';
650hA
650hA        if $drireturn = '*OKADD';
650hA           $drisubcmd  = '%ADD';
650hA        else;
650hA           $uichgpgm = #pgm;
650hA           $uichgemp = #emp#;
650hA           $uichgusr = #user;
650hA           $uichgjob = #job;
650hA           $uichgnbr = #jobnbr;
650hA           $drisubcmd  = '%REPLENUSE';
650hA        endif;
720bA
720bA        if $drisubcmd = '%ADD';
720bA           eval  $drisubcmd = '%ADD';
720bA           if $bcgtin = *blanks;
720bA              $uiaGtin = 0;
720bA           else;
720bA              $uiaGtin  = %DEC($bcGTin:14:0);
720bA           endif;
720bA           workupc = blank6 + $bcgtin;
720bA           uputyp     = 'N';
720bA           exec sql select * into :uprecuom
720bA                    from upc
720bA                    where upwhse = :#pickslwhse
720bA                      and upITEM = :#pickslitem
720bA                      and upupc  = :workupc
720bA                    fetch first row only;
720bA           $uiaUTyp  = uputyp;
720bA           $uiaSlUTyp = uputyp;
720bA           $uiaLot   = $bclot;
720bA           $uiaExpD  = $slexpd;
720bA           $uiaEntD  = today;
720bA           // Lets add some more stuff for tracking
720bA           $uiaction = 'RCV?';
720bA           $uiaolcns = $uilcns;
720bA           $uialcns = $uilcns;
720bA           $uiaoseq = $uiseq;
720bA           $uiscan = 'Y';

720bA        endif;
650hA
650hA        $dricommand = '*UCIINFO';
650hA        $drisys2upd = 'D';
650hA        chk4err = *on;
650hA        exsr zzzdricop;
650hA        if error;
650hA           error = *on;
650hA           errmsg = desc(35);
650hA           exsr zm0105;
650hA        endif;
          else;
650hA        error = *on;
650hA     endif;
650hA   endif;
650hA /end-free
650hAC     endck51       endsr
720 A*----------------------------------------------------------------
720 A*
720 A*  ZZCHK52  Screen 52 error checking.
720 A*
720 AC     zzchk52       begsr
720 AC                   eval      error = *off
720 Ac*
720 Ac* Confirm user scans Store Staging Area to Drop pull items
720 Ac*
720 AC                   if        w5strloc <> 'RPADOCK'
720 Ac                   eval      error = *on
720 Ac                   eval      errmsg = 'Scanned location invalid'
720 Ac                   exsr      zm0105
720 Ac                   endif
720 AC     endck52       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 06 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
510gA * Set worow/wocol based on the size of the screen being processed
510gAc                   select
510gAc                   when      #lline = '16'
510gAc                   eval      worow = 8
510gAc                   eval      wocol = 9
510gAc                   other
510gAc                   eval      worow = 5
510gAc                   eval      wocol = 29
510gAc                   endsl
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w6scan
510gDC*                  parm      5             worow
510gDC*                  parm      29            wocol
510gMC                   parm                    worow
510gMC                   parm                    wocol
     C                   parm                    @artn
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck6
     C                   endif
     *
     *    Slot can't be blank.
     *
     C                   if        w6scan = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(4)       errmsg
     C                   exsr      zm0203
500lAC                   goto      endck6
     C                   endif
     *
     *    Verify slot.
     *
500fAC                   exsr      zzgetovrfsl
500fAC     error         cabeq     *on           endck6
     *
     *    Return Home Flag on - product must go back to pull slot.
     *
     C                   if        *inkj  and
     C                             rtnhom = *on
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = desc(21)
     C                   exsr      zm0105
500lAC                   goto      endck6
     C                   endif
     *
     *    Quantity must be greater than 0.
     *
     C                   if        w6nqty <= 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm2003
500lAC                   goto      endck6
     C                   endif
     *
     *    Quantity cannot be greater than balance.
     *
     C                   if        w6nqty > w6balq
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(22)
     C                   exsr      zm0105
500lAC                   goto      endck6
     C                   endif
     *
     *    Retrieve "From Slot".
     C                   if        rtnhom = *off
     *
500dMC                   eval      fmpck = #fromslpick
500dMC                   eval      svpick = #fromslpick
     *
     C                   endif
     *
     *    Product allocated - must go back to overflow slot.
     *
     C                   if        rtnhom = *on  and
     C                             w6scan <> w6rtn2
     *
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = %trimr(desc(16)) + ' ' + w6rtn2
     C                   exsr      zm0105
500lAC                   goto      endck6
     C                   endif
     *
     *    Product allocated - Entire balance must be returned.
     *
     C                   if        rtnhom = *on  and
     C                             w6nqty <> w6balq
     *
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(17)
     C                   exsr      zm0105
500lAC                   goto      endck6
     C                   endif
500dA
500dA*  Use DRI interface to do rest of the verifications.
500tA
500tA*    Two different methods are used depending on whether the
500tA*    quantity is going back into the original #FROM slot or not.
500tA
600aDC**                 if        #ovrfslwhse = #fromslwhse  and
600aDC**                           #ovrfslwhdp = #fromslwhdp  and
600aDC**                           #ovrfbasesldsp = #frombasesldsp
600aDC**                 exsr      zzchk6a
600aDC**                 else
500tAC                   exsr      zzchk6b
600aDC**                 endif
500tA
500tDC                   if        error
500tAC                   eval      *in23 = *on
500tAC                   eval      *in03 = *on
500tAC                   goto      endck6
500tAC                   endif
     *
     C     endck6        endsr
500tA
500tA*----------------------------------------------------------------
500tA*  ZZCHK6A  Verify putting full/partial quantity into #from slot.
500tA*----------------------------------------------------------------
500tA
500tAC     zzchk6a       begsr

     *  We just send a negative qty back because all we want to do
     *  is remove the qty from the Tfr bucket.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #fromslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #pickslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = -(w6nqty)
     C                   eval      $saqty2   = 0
     C                   eval      $saqty2   = 0
     C                   eval      $saorgu   = *off
     C                   eval      $saorg1   = 0
     C                   eval      $saorg2   = 0
     C                   eval      $saorg2   = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYPROCHG'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endchk6a
     C                   endif

     C     endchk6a      endsr
500tA
500tA*----------------------------------------------------------------
500tA*  ZZCHK6B  Vfy putting full/partial quantity into non-#from slot.
500tA*----------------------------------------------------------------
500tA
500tAC     zzchk6b       begsr

     *  Verify To slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #ovrfslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #ovrfslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #ovrfsldisp
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w6nqty
     C                   eval      $saqty2   = 0
     C                   eval      $saqty3   = 0
600aMC                   eval      $saToPosu = *on
600aMC                   eval      $saToPos  = $tslotpos

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYCLSPRI'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endchk6b
     C                   endif
610dD **
610dD ** Verify From slot
610dD **
610dDC**                 exsr      clr$slot
610dDC**                 eval      $slwhseu  = *on
610dDC**                 eval      $slwhse   = #fromslwhse
610dDC**                 eval      $slwhdpu  = *on
610dDC**                 eval      $slwhdp   = #fromslwhdp
610dDC**                 eval      $sldispu  = *on
610dDC**                 eval      $sldisp   = #fromsldisp
610dDC**                 eval      $saitemu  = *on
610dDC**                 eval      $saitem   = #fromslitem
610dDC**                 eval      $sacitemu = *on
610dDC**                 eval      $sacitem  = #pickslitem
610dDC**                 eval      $saqtyu   = *on
610dDC**                 eval      $saqty1   = w6nqty
610dDC**                 eval      $saqty2   = 0
610dDC**                 eval      $saqty2   = 0
610dDC**                 eval      $saorgu   = *on
610dDC**                 eval      $saorg1   = w6nqty
610dDC**                 eval      $saorg2   = 0
610dDC**                 eval      $saorg2   = 0
610dDC**
610dDC**                 eval      $dricommand = '*SLOT'
610dDC**                 eval      $drisubcmd  = '%VFYCLSPOC'
610dDC**
610dDC**                 eval      $drisys2upd = 'D'
610dDC**                 eval      chk4err = *on
610dDC**                 eval      zmsflag = *off
610dDC**                 exsr      zzzdricop
610dDC**                 if        drierr
610dDC**                 eval      error = *on
610dDC**                 goto      endchk6b
610dDC**                 endif

     C     endchk6b      endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 07 error checking.
     *
     C     zzchk7        begsr
     C                   eval      error = *off
     *
     *
     C     endck7        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZCHK9   Screen 9 error checking.
500 A*
500 AC     zzchk9        begsr
     C                   eval      error = *off
     *
     *    Verify Zero, Y,N
     *
     C                   if        w9opt <> 'Y'  and
     C                             w9opt <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(29)
     C                   exsr      zm1005
     C                   endif
     *
     C     endck9        endsr

710bA*----------------------------------------------------------------
710bA*
710bA*  ZZCHKFIFO    Check if selected replen is out of FIFO order
710bA*
710bAC     zzchkfifo     begsr


      /free

       outOfFifoOrder = *off;

       // See if we should do this check

RNZaA  if client <> renzi;
RNZaA    leavesr;
RNZaA  endif;

       //  Loop through replenishments for item
       //  PRPLFIL9 only includes prflag='S' records.

       firstP9 = *on;

       setll (prwhse: prrplt: pritem) prplfil9;

       dou forever <> forever;

         reade (prwhse: prrplt: pritem) prplfil9;

         if %eof(prplfil9);
           leave;
         endif;

         // Skip selected record

         if p9_prfdis = prfdis;
           iter;
         endif;

         // First time through, get slot for selected replen

         if firstP9 = *on;

           // Get slot info for selected replen

           exsr clr$slot;
           $slwhseu = *on;
           $slwhse  = prwhse;
           $slwhdpu = *on;
           $slwhdp  = prwhdp;
           $sldispu = *on;
           $sldisp  = prfdis;

           $dricommand = '*SLOT';
           $drisubcmd  = '%GET2';
           $drisys2upd = 'D';
           chk4err = *off;
           zmsflag = *off;

           exsr zzzdricop;
           if drierr;
             leavesr;
           endif;

           savePrty = $slprty;
           saveExpd = $slexpd;
           saveEntd = $slentd;
           firstP9 = *off;

         endif;

         // Get slot info for P9 record

         exsr clr$slot;
         $slwhseu = *on;
         $slwhse  = p9_prwhse;
         $slwhdpu = *on;
         $slwhdp  = p9_prwhdp;
         $sldispu = *on;
         $sldisp  = p9_prfdis;

         $dricommand = '*SLOT';
         $drisubcmd  = '%GET2';
         $drisys2upd = 'D';
         chk4err = *off;
         zmsflag = *off;

         exsr zzzdricop;
         if drierr;
           iter;
         endif;

         // Keep selected rec if priority is greater than p9 rec

         if savePrty > $slprty;
           iter;
         endif;

         // Keep selected rec if expiration date is less than p9 rec

         if saveExpd <= $slexpd;
           iter;
         endif;


         // Keep selected rec if entered date is less than or equal to p9 rec
         // Only check when not using expiration dates.

         if (saveExpd <= 0 and $slexpd <= 0) and saveEntd <= $slentd;
           iter;
         endif;

         // Otherwise, P9 rec should be replenished first,
         // So, set flag and get out

         outOfFifoOrder = *on;
         leave;

       enddo;

      /end-free

     C                   endsr

     *
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
     *    F10=Override Replenishment slot
     *    Only valid with Repack Replenishments
650bAC                   if        *inkj
650bAc                   eval      it276Flag = *off
650dAc                   eval      LicenseEntered = *off
650bAc                   exsr      zzspfc
650bAc                   endif
     *
     *    F7=Full pallet. Proceed to putaway.
500yDC**                 if        *inkg
500yDC**                 eval      cmdtkn = *on
     *
     *    Reset status on current Pushback replenishment. User
     *    says pallet is full. Reset so it can be picked later.
500yDC**   prky6e        chain     prplfil6                           7978
500yDC**                 if        not *in79
500yDC**                 eval      prflag = 'S'
500yDC**                 update    prrec                                78
500yDC**                 endif
     *
     *    Undo last replenishment created.
500yDC**                 exsr      zzundo
500 A
500 A*    If an item has been pulled, start putaway processes.
500 A
500yDC**                 if        rplstr = '*YES'
500yDC**                 exsr      zznextstep
500yDC**                 endif
     *
500yDC**                 endif
500nA*
     *    F9=Skip
     C                   if        *inki
     C                   eval      cmdtkn = *on
500iA
500iA*    Abort current replenishment.
500iA
500tDC                   exsr      zzabrt
500tMC***                exsr      zzabrtskip
500iA
500iA*      Look for another replenishment.
500iA
500iAC                   eval      updrplrec = *on
500nAC                   eval      bypass = *on
500iAC                   exsr      zznxt1
500iAC                   select
500iA
500iA*        Found one. Redisplay screen 1 with new information.
500iA
500iAC                   when      done = *off
500iAC                   exsr      zzget1
500iAC                   eval      curitm = lbitem
500iAC                   eval      curwhd = lbwhdp
500iAC                   eval      curasl = lbaisl
500iAC                   eval      curloc = lbloc
500iAC                   eval      curlvl = lbrlvl
500iAC                   eval      curhnd = lbhand
500iAC                   eval      curdsp = lbdisp
500nA
500nAC                   if        w1scan = #frombasesldsp
500nAC                   exsr      zzupd1
500nAC                   else
500iAC                   exsr      scr01i
500nAC                   endif
500iA
500iA*        No more replenishments found.
500iA
500iAC                   other
500iA
500iA*          If transaction started (at least on repl found),
500iA*            Then start replenishing to the pick slots.
500iA*            Otherwise, tell user there is nothing to do.
500iA
500iAC                   if        rplstr = '*YES'
500iAC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
500iAC                   else
500iAC                   exsr      scr07i
500iAC                   endif
500 A
500 AC                   endsl
500 A
     *
     C                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
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
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *    F7=Full pallet. Proceed to putaway.
     C                   if        *inkg
     C                   eval      cmdtkn = *on
     *
     *    Reset status on current Pushback replenishment. User
     *    says pallet is full. Reset so it can be picked up
     *    later.
     C     prky6e        chain     prplfil6                           7978
     C                   if        not *in79
     C                   eval      prflag = 'S'
     C                   update    prrec                                78
     C                   endif
500 A
500 A*    Move on to the putaway processes.
500 A
500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
     *
     C                   endif
510jA*
510jA*    F9=Skip
510jAC                   if        *inki
650cAc                   eval      qtyGrtSlt = *off
510jAC                   eval      cmdtkn = *on
510jA
510jA*    Abort current replenishment.
510jA
510jAC                   exsr      zzabrt
510jA
510jA*      Look for another replenishment.
510jA
510jAC                   eval      updrplrec = *on
510jAC                   eval      bypass = *on
510jAC                   exsr      zznxt1
510jAC                   select
510jA
510jA*        Found one. Redisplay screen 1 with new information.
510jA
510jAC                   when      done = *off
510jAC                   exsr      zzget1
510jAC                   eval      curitm = lbitem
510jAC                   eval      curwhd = lbwhdp
510jAC                   eval      curasl = lbaisl
510jAC                   eval      curloc = lbloc
510jAC                   eval      curlvl = lbrlvl
510jAC                   eval      curhnd = lbhand
510jAC                   eval      curdsp = lbdisp
510jA
510jAC                   if        w1scan = #frombasesldsp
510jAC                   exsr      zzupd1
510jAC                   else
510jAC                   exsr      scr01i
510jAC                   endif
510jA
510jA*        No more replenishments found.
510jA
510jAC                   other
510jA
510jA*          If transaction started (at least on repl found),
510jA*            Then start replenishing to the pick slots.
510jA*            Otherwise, tell user there is nothing to do.
510jA
510jAC                   if        rplstr = '*YES'
510jAC                   exsr      zznextstep
510jAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
510jAC                   exsr      zzupd7
510jAC                   endif
510jAC                   else
510jAC                   exsr      scr07i
510jAC                   endif
510jA
510jAC                   endsl
510jA
510jA*
510jAC                   endif
500tA*
500tA*    Test for F10 - Exception
500tA*
500tAC                   if        *inkj
500tAC                   eval      cmdtkn = *on
500tAC                   exsr      zzabrt

610jAC                   if        rpltyp = '*REPACK'
610jAC                             or rpltyp = '*FLOW  '
650fAC                             or rpltyp = '*PROD  '
750aAC                             or rpltyp = '*DROPP '
720 AC                             or rpltyp = '*STRREPL'
610jAC                   exsr      zzexcp
610jAC                   endif

610jD ***                if        rpltyp = '*BRKDWN'
610jMC                   if        (rpltyp = '*BRKDWN'
610jAC                             or rpltyp = '*REPACK'
650fAC                             or rpltyp = '*PROD  '
750aAC                             or rpltyp = '*DROPP '
720 AC                             or rpltyp = '*STRREPL'
610jAC                             or rpltyp = '*FLOW  ')
500tMC                             and workcount > 0
500tAC                   exsr      scr09i
500tAC                   else
500tAC                   exsr      scr07i
500tAC                   endif
500tAC                   goto      endcm2
500tAC                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
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
     C                   eval      cmdtkn = *off
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 06.
     *
     C     zzcmd6        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *    Test for F10 - Exception
     *
     C                   eval      balexc = *off
     C                   if        *inkj  and
     C                             rtnhom = *off
     C                   eval      cmdtkn = *on
     C                   eval      balexc = *on
     C                   eval      lstscr = nxtscr
     C                   eval      pttask = svtask
     C                   goto      endcm6
     C                   endif
     *
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 07.
     *
     C     zzcmd7        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   select
     C                   when      cmdchk = '*BEFORE '
500  *
     *    Test for F7 - User selected specific slot replenishment.
     *
     C                   if        *inkg
500pAC                   if        lastslot <> ' '
500pAC                   exsr      zzreturnplt
500pAC                   endif
     C                   eval      refrsh = *on
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*SSRPL'
     C                   goto      endcm7
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   when      cmdchk = '*AFTER  '
     *
     C                   endsl
     *
     C     endcm7        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZCMD9   User defined command keys for screen 9.
500 A*
500 AC     zzcmd9        begsr
     C                   eval      cmdtkn = *off
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm9        endsr

520cA*----------------------------------------------------------------
520cA*
520cA*  ZZCRTA  Create adjustment for breakdown replenishments
520cA*
520cAC     zzcrta        begsr

     *    Get todays date.

     C                   exsr      zzgetdatetime

     *    Create 'From' adjustment record

     C                   clear                   iarec
     C                   eval      iawhse = #fromslwhse
     C                   eval      iaitem = #fromslitem
650aDC**                 eval      iadate = curdate
650aDC**                 eval      iatime = curtime
650aMC                   eval      iadate = tfr2usrDate
650aMC                   eval      iatime = tfr2usrTime
     C                   eval      iaby = #curruser
     C                   eval      iawhdp = #fromslwhdp
     C                   eval      iadisp = #fromsldisp
     C                   eval      iacwta = 0
     C                   eval      iaqty1 = -(w5nqty)
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   eval      iacode = 'CI'
     C                   eval      iamemo = 'To ' + #pickslitem
     C                   write     iarec

     *    Create 'To' adjustment record

     C                   clear                   iarec
     C                   eval      iawhse = #pickslwhse
     C                   eval      iaitem = #pickslitem
     C                   eval      iadate = curdate
     C                   eval      iatime = curtime
     C                   eval      iaby = #curruser
     C                   eval      iawhdp = #pickslwhdp
     C                   eval      iadisp = #picksldisp
     C                   eval      iacwta = 0
     C                   eval      iaqty1 = w5nqty * #fromitumq2
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   eval      iacode = 'CI'
     C                   eval      iamemo = 'From ' + #fromslitem
     C                   write     iarec

520cAC     endcta        endsr

500 A*----------------------------------------------------------------
500 A*  ZZDROP  Call program to drop pallet(s).
500 A*----------------------------------------------------------------
500 A
500 AC     zzdrop        begsr
     C                   eval      error = *off
     *
     *  Call program that will (if necessary) ...
     *    - Prompt user to pull pallet.
     *    - Have user verify license being pulled.
     *    - Update license information.
     *
     C                   exsr      zzzclr$lt210
650bAc                   if        it276Flag = *on
     c                             or LicenseEntered
650bAc*                             and topick < #fromslavl1
650bAc                   eval      $tcmd   = '*PULTRAN'
650bAC                   eval      $tnewlic# = #fromsaToLcns
650bAC                   eval      $tqty1    = topick
650bAC                   eval      $tqty2    = 0
650bAC                   eval      $tqty3    = 0
650bAC                   eval      $tnorm1   = topick
650bAC                   eval      $tnorm2   = 0
650bAC                   eval      $tnorm3   = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                              and (prrplt = 'O' or prrplt='D')
650iAC                   eval      $tqty1    = 0
650iAC                   eval      $tqty2    = topick
650iAC                   eval      $tqty3    = 0
650iAC                   eval      $tnorm1   = 0
650iAC                   eval      $tnorm2   = topick
650iAC                   eval      $tnorm3   = 0
650iAc                   endif
650bAc                   else
     C                   eval      $tcmd   = '*PULDROP'
650bAc                   endif
     C                   eval      $twhdp  = #fromslwhdp
     C                   eval      $tslot  = #fromsldisp
     C                   eval      $titem  = #fromslitem
500eAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
610gAC                   eval      $ttoslot  = #picksldisp
     C                   exsr      zzzcall$lt210

     C                   if        $treturn = '*NOTFND'
500oDC**                 exsr      zzexcp
500oA
500sDC**                 exsr      zzzclr$lt210
500sDC**                 eval      $tcmd   = '*PULRTN'
500sDC**                 eval      $twhse  = #fromslwhse
500sDC**                 eval      $twhdp  = #fromslwhdp
500sDC**                 eval      $tslot  = #fromsldisp
500sDC**                 eval      $titem  = #fromslitem
500sDC**                 eval      $titemdsc = #fromithead
500sDC**                 exsr      zzzcall$lt210
500sDC**
     C                   endif

     C     enddrop       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record.
     *
     C                   eval      exwhse = lbwhse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      exfdis = lbdisp
     C                   eval      extdis = lbdsp2
     C                   eval      extask = pttask
     *    Get todays date.
500fMC                   exsr      zzgetdatetime
500fMC                   eval      exgdte = curdate
500fMC                   eval      exgtim = curtime
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFEAT   Check for installed feature.
     *
     C     zzfeat        begsr
     *
650hA*  if production replenishment then set option for GS1 scan
650hA*    if selected
650hAc                   eval      ScanGs1 = *off
750aDc*                  if        $prplt = 'O' or $prplt='D'
750aMc                   if        $prplt = 'O'
650hAC                   eval      kycode = '*PROD'
650hAC     opkey         chain     options                            79
650hAc                   if        not *in79
720aAc                   eval      opdta4 = opdata
710fAc                   if        opgs1o = 'Y'
650hAc                   eval      ScanGs1 = *on
650hAc                   else
650hAc                   eval      ScanGs1 = *off
650hAc                   endif
650hAc                   endif
650hAc                   endif
     C                   eval      kycode = '*FEATURE'
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opfeat = '2'
710fAc                   else
710fAc                   eval      opdta4 = opdata
     C                   endif
     *
650gAC                   eval      kycode = '*REPLEN '
650gAC     opkey         chain     options                            79
650gAC                   if        *in79
650gAC                   eval      opskpr = 'N'
650gAC                   else
650gAC                   eval      opdta3 = opdata
650gAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      wohdr2 = *blanks
     *
     C                   select
     C                   when      pttask = 'REPL'
     *
500dMC                   eval      $iitem = #fromititem
500dMC                   eval      $idesc = #fromitdesc
500dMC                   eval      $ipdsc = #fromitpdsc
     C                   eval      woitem = *blanks
     C                   exsr      zzgeti
     *
530 AC                   when      pttask = 'REPLRP'
710dAC                             or pttask = 'REPLPD'
710dAC                             or pttask = 'REPLRS'
530 AC                   eval      $iitem = #fromititem
530 AC                   eval      $idesc = #fromitdesc
530 AC                   eval      $ipdsc = #fromitpdsc
530 AC                   eval      woitem = *blanks
530 AC                   exsr      zzgeti
530 AC                   eval      *in64 = *on
     *
530 AC                   movel     desc(8)       wohdr2
     *
     C                   when      pttask = 'REPLBK  '
500sAC                   eval      $iitem = #pickititem
500sAC                   eval      $idesc = #pickitdesc
500sAC                   eval      $ipdsc = #pickitpdsc
500sAC                   eval      woitem = *blanks
500sAC                   exsr      zzgeti
     C                   eval      *in64 = *on
     *
     C                   movel     desc(7)       wohdr2
     *
     C                   endsl
     *
700eA*    Check for *EACH slot
700fDC**                 if        #pickslsdef = 'EA'
700fMC                   if        #picksdpal = '*EACH'
700eAC                   eval      *in64 = *on
700eAC                   movel     desc(36)      wohdr2
700eAC                   endif
     *
     C                   movel     $istr         woitem
     *
     *    Retrieve base slot for From location.
500dMC                   eval      w1fmsl = #frombasesldsp
500 D**   Retrieve current position for pallet.
500 DC**????             eval      w1plps = $rtslp
     *
650cAc                   eval      w1qty = prqty
     C                   eval      w1scan = ' '
650dAC                   eval      w1lcns = ' '

750 A    //  if production breakdown replenishments then show
750 A    //  breakdown unit of measure instead of normal uom
750 A    if prtype = 'E'
750 A          and (prrplt = 'O' or prrplt='D');
750 A      *in75 = *on;
750 A    else;
750 A      *in75 = *off;
750 A    endif;
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      *in60 = *off
     C                   eval      *in64 = *off
     C                   eval      wohdr2 = *blanks
     *
     C                   if        done = *off
     C                   eval      *in60 = *on
     *
     C                   select
     C                   when      pttask = 'REPL'
     *
500dMC                   eval      $iitem = #fromititem
500dMC                   eval      $idesc = #fromitdesc
500dMC                   eval      $ipdsc = #fromitpdsc
     C                   eval      woitem = *blanks
     C                   exsr      zzgeti
     *
530 AC                   when      pttask = 'REPLRP'
710dAC                             or pttask = 'REPLPD'
710dAC                             or pttask = 'REPLRS'
650bAc                   if        *in42 = *on
650dAc                   if        LicenseEntered
650dAc                   eval      w2lic# = $liToLcns
650dAc                   else
650bAc                   eval      w2lic# = curlic#
650dAc                   endif
650bAc                   else
650bAc                   eval      w2lic# = ' '
650bAc                   endif
530 AC                   eval      $iitem = #fromititem
530 AC                   eval      $idesc = #fromitdesc
530 AC                   eval      $ipdsc = #fromitpdsc
530 AC                   eval      woitem = *blanks
530 AC                   exsr      zzgeti
530 AC                   eval      *in64 = *on
     *
530 AC                   movel     desc(8)       wohdr2
     *
     C                   when      pttask = 'REPLBK  '
500sAC                   eval      $iitem = #pickititem
500sAC                   eval      $idesc = #pickitdesc
500sAC                   eval      $ipdsc = #pickitpdsc
500sAC                   eval      woitem = *blanks
500sAC                   exsr      zzgeti
     C                   eval      *in64 = *on
     C                   movel     desc(7)       wohdr2
     *
     C                   endsl
     *
700eA*    Check for *EACH slot
700fDC**                 if        #pickslsdef = 'EA'
700fMC                   if        #picksdpal = '*EACH'
700eAC                   eval      *in64 = *on
700eAC                   movel     desc(36)      wohdr2
700eAC                   endif
     *
     C                   movel     $istr         woitem
500dMC                   eval      w2fmsl = #fromsldisp

500 AC                   eval      w2plps = curpos
     *
     *    Retrieve tie/high for From Slot.
     *
500dMC                   eval      w2tie = #fromittie
500dMC                   eval      w2high = #fromithigh
     C                   eval      w2ordq = praqs
     *
      /free
700dA    *in76 = *off;                     // *off = display CS; *On = CS & PC
730 M    if prtype = 'E' and (prrplt = 'O' or prrplt='D');
700dA      w2sltq = #fromslstk2 + #fromslrcv2;
700dA      ttlLowW2sltq = ((#fromslstk1 + #fromslrcv1) * #fromitumq2)
700dA                   + (#fromslstk2 + #fromslrcv2);
700dA      if ttlLowW2sltq < 0;
700dA        ttlLowW2sltq = *zeros;
700dA      endif;
700dA    else;
500dM      w2sltq = #fromslstk1 + #fromslrcv1;
700dA    endif;

         if w2sltq < *zeros;
           w2sltq = *zeros;
         endif;

700dD  ////  if LicenseEntered
700dD  ////        and w2sltq >= $liTorQty1;
700dD  ////    w2sltq = $liTorQty1;
700dD  ////  endif;

700dA    // Update screen2 slot quantity when user enters license
700dA    select;
700dA      when LicenseEntered and w2sltq >= $liTorQty1
730 M           and NOT(prtype = 'E' and prrplt = 'O')
730 A           and NOT(prtype = 'E' and prrplt = 'D');
700dA        w2sltq = $liTorQty1;
700dA      // Adjust screen2 slot quantity for breakdown replenishments
700dA      when LicenseEntered and w2sltq >= $liTorQty2
730 M           and (prtype = 'E' and prrplt = 'O'
730 A           or prtype = 'E' and prrplt = 'D');
700dA        w2sltq = $liTorQty2;
700dA    endsl;

500nD    //*                 eval      w2nqty = lbqpck
500sA    if rpltyp = '*FLOW';
500nM      w2nqty = w2sltq;
500sA    else;
500sA      w2nqty = lbqpck;
500sA    endif;

650iA    //  if production breakdown replenishments then show
650iA    //  breakdown unit of measure instead of normal uom
650iA    if prtype = 'E'
730 M          and (prrplt = 'O' or prrplt='D');
650iA      *in75 = *on;
500dM      w2um1a = #fromitum2;
500dM      w2um2a = #fromitum2;
500dM      w2um3a = #fromitum2;
650iA    else;
650iA      *in75 = *off;
500dM      w2um1a = #fromitum1;
500dM      w2um2a = #fromitum1;
500dM      w2um3a = #fromitum1;
650iA    endif;

         w2qty = lbqpck;
650cD    //                  eval      w2repq = lbqpck
         w2aval = lbqavl;
650cA
650cA    if rpltyp = '*REPACK'
720 A          or rpltyp = '*STRREPL'
750aA          or rpltyp = '*DROPP '
650fA          or rpltyp = '*PROD  ';
650cA      w2repq = prqty;
650cA      if w2repq > w2sltq;
700dA        //  Show both normal & breakdown quantities when breakdown replenishment
700dA        //  exceeds slot breakdown quantity.
700dA        //  Ex. Slot quantity = 2CS 1PC, Replenishment = 4PC, then show 2CS 1PC.
700dA        if w2repq > w2sltq and w2repq <= ttlLowW2sltq;
700dA          *in76 = *on;
700dA          w2nqty  = w2repq;
700dA          w2sltq  = #fromslstk1 + #fromslrcv1;
700dA          w2um1a  = #fromitum1;
700dA          w2sltq2 = #fromslstk2 + #fromslrcv2;
700dA          w2um1a2 = #fromitum2;
700dA          w2tie2  = w2tie;
700dA          w2high2 = w2high;
700dA        else;
650cA          w2nqty = w2sltq;
700dA        endif;
650cA      endif;
650cA    else;
650cA      w2repq = lbqpck;
650cA    endif;
       endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3whdp = $pwhdp
500dMC                   eval      w3fmsl = #frombasesldsp
500dMC                   eval      w3plps = #fromslpos
     C                   eval      w3zero = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     *
      /free
730 A          exec sql  select sldesg,slalc1,slalc2,slalc3
730 A                      into :$sldesg,:slalc1,:slalc2,:slalc3
730 A                       from slot
730 A                     where sldisp=:#picksldisp
730 A                        fetch first row only;
      /end-free
     C                   eval      w5lic# = curlic#

500tDC**                 eval      $iitem = #fromititem
500tDC**                 eval      $idesc = #fromitdesc
500tDC**                 eval      $ipdsc = #fromitpdsc
500tAC                   eval      $iitem = #pickititem
500tAC                   eval      $idesc = #pickitdesc
500tAC                   eval      $ipdsc = #pickitpdsc
     C                   exsr      zzgeti
     C                   movel     $istr         w5item
500dMC                   eval      w5tosl = #picksldisp
650iAc*  if Production Replenishment coming from breakdown 1 quantity
650iAc*  then use unit of measure 2 instead of 1/Normal
730 Mc                   if        (wurpltype = 'O' and wupulutype = '1' or
730 Ac                              wurpltype = 'D' and wupulutype = '1')
650iAC                   eval      w5um1a = #fromitum2
650iAC                   eval      w5um2a = #fromitum2
650iAC                   eval      w5um3a = #fromitum2
650iAc                   eval      *in75 = *on
650iAc                   else
650iAc                   eval      *in75 = *off
650iAC                   eval      w5um1a = #fromitum1
650iAC                   eval      w5um2a = #fromitum1
650iAC                   eval      w5um3a = #fromitum1
650iAc                   endif
     *
     *
     *    Retrieve tie/high for To Slot.
     *
500dAC                   eval      w5tie = #pickittie
500dAC                   eval      w5high = #pickithigh
     *
     C                   eval      w5pulq = lbqpck
500qDC**                 if        pttask = 'REPLBK  '
500qDC**                 eval      w5repq = lbqrmn
500qDC**                 else
     C                   eval      w5repq = lbqpck
500qDC**                 endif
     C                   eval      w5balq = w5pulq - w5repq
     C                   if        w5balq > *zeros
     C                   eval      *in63 = *on
     C                   eval      balrem = '*YES'
     C                   else
     C                   eval      *in63 = *off
     C                   eval      balrem = '*NO '
     C                   eval      w5balq = *zeros
     C                   endif
500tAC                   if        pttask = 'REPLBK'
710aAc                             or rpltyp = '*PROD'
750aAc                             or rpltyp = '*DROPP'
500tAC                   eval      w5nqty = w5pulq
500tAC                   eval      *in05 = *off
500tAC                   eval      *in06 = *on
500tAC                   else
     C                   eval      w5nqty = *zeros
500tAC                   eval      *in05 = *on
500tAC                   eval      *in06 = *off
500tAC                   endif
     *
     C                   eval      w5scan = *blanks
610hAC                   if        rpltyp = '*REPACK'
610iAC                             and #pickslaisl = 'RPK'
610hAC                   eval      w5scan = 'RPK-101-1'
610hAC                   endif
650fA /free
650hA            // get current production date for mfg line
710 D       //   chain ($pwhse:prtlvl:'O') prddate1;
710 A            chain ($pwhse:#pickslrlvl:'O') prddate1;
650hA            if %found(prddate1);
650hA               prddte = pddate;
650hA            else;
650hA               prddte = %dec(%char(%date():*iso0):8:0);
650hA            endif;
650fA            // get physical slot for production replenishments
650fA                    if rpltyp = '*PROD'
750aA                       or rpltyp = '*DROPP';
650fA                       chain (#pickslwhse:#pickslwhdp:
650fA                            #picksldisp) vslot1;
650fA                       if %found(vslot1);
650fA                          w5scan = vspdis;
650fA                          unlock vslot1;
650fA                       endif;
650fA                    endif;
650fA /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 06 fields with info from file.
     *
     C     zzfil6        begsr
     *
     C                   eval      svorsl = *blanks
500fDC**                 if        newlb = *off
     C                   eval      wkrtpo = '0'
500vA*
500vDC**                 eval      kytrn# = lbtrn#
500vDC**                 exsr      zzstr2
500vA
500dMC                   eval      svorsl = #fromsldisp
500dMC                   eval      w6item = #fromslitem
600aMC                   eval      w6balq = wuremqty1
500vDC**                 endif
     *    Load originating slot for replenishment.
     C                   eval      w6orsl = svorsl
600aMC                   if        wurtnhome = 'Y'
     C                   eval      *in65 = *on
500mDC**                 eval      w6rtn2 = wrfdsp
500mMC                   eval      w6rtn2 = #frombasesldsp
     C                   else
     C                   eval      *in65 = *off
     C                   eval      w6rtn2 = *blanks
     C                   endif
     *
     C                   eval      w6scan = *blanks
     C                   eval      w6nqty = *zeros
500vA
500vA*  Start transaction.
500vA
600uMC                   eval      kytrn# = wutrn#
500vAC                   exsr      zzstr2
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 07 fields with info from file.
     *
     C     zzfil7        begsr
     *
     *    Check for additional pushback/eaches replenishments to do.
     *
     C                   eval      chknew = *on
     C                   eval      newrpl = *off
     C     prky6a        setll     prplfil6
     C                   exsr      zznext
     C                   eval      chknew = *off
     *
     *    More pushback/eaches replenishments to do.
     C                   if        newrpl = *on
     C                   eval      w7txt1 = 'Not all ' + wohdr1
     *
     *    No more pushhback/eaches replenishments to do.
     C                   else
     C                   eval      w7txt1 = 'All ' + wohdr1
     C                   endif
     C                   eval      w7txt3 = 'Press Enter to continue '
     C                                    + 'or F3=Exit'
     *
     C                   eval      w7whse = $pwhse
     C                   eval      w7whdp = $pwhdp
     *
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZFIL9   Fill screen 9 fields with info from file.
500 A*
500 AC     zzfil9        begsr
500tA
500tA*  Do not allow F12.
500tA
500tAC                   eval      *in93 = *on
500tA
500tA*  Initialize screen field
500tA
750aAc                   if        rpltyp='*DROPP'
750aAc                   eval      w9opt = 'Y'
750aAc                   else
     C                   eval      w9opt = 'N'
750aAc                   endif
     C                   endsr
     *----------------------------------------------------------------
650gA*  ZZGETPICKSLQ   Get Pick slot physical qty.
650gA*----------------------------------------------------------------
650gA
650gAC     zzgetpickslq  begsr
650gA
     *   Get SLOT record.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = prwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = prwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = prtdis

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET2'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      pckSltPhyQ = 0
     C                   eval      $pcmd = '*QTY2STR'
     *
     *      Convert physical quantity to string.
     *
     C                   eval      $pqty1 = $slphy1
     C                   eval      $pqty2 = $slphy2
     C                   eval      $pqty3 = $slphy3
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn
     C                   parm                    $perm

     *   Convert string to numeric.

     C                   monitor
     C                   eval      pckSltPhyQ = %dec($pqstr:10:0)
     C                   on-error
     C                   eval      pckSltPhyQ = 0
     C                   endmon

     C                   endsr
500dA*----------------------------------------------------------------
500dA*  ZZGET1   Get record(s) for screen 1.
500dA*----------------------------------------------------------------
500dA
500dAC     zzget1        begsr

     *  Get From slot information.

     C                   eval      getwhse = lbwhse
     C                   eval      getwhdp = lbwhdp
     C                   eval      getdisp = lbdisp
     C                   exsr      zzgetfromsl

     *  Get From Item information.

     C                   exsr      zzgetfromit

     *  Get Pick slot information.

     C                   eval      getwhse = lbwhs2
     C                   eval      getwhdp = lbwhd2
     C                   eval      getdisp = lbdsp2
     C                   exsr      zzgetpicksl

     *  Get Pick Item information.

     C                   exsr      zzgetpickit
650iA * pull in breakdown unit of measure if this is a Production
650iA * replenishment for a breakdown request
650iA /free
650iA                    if prtype = 'E'
730 M                       and (prrplt = 'O' or prrplt = 'D');
650iA                       *in75 = *on;
650iA                       chain (#pickitum2) unmesr;
650iA                       if %found(unmesr);
650iA                          if umshrt = ' ';
650iA                             w1uom = 'BDQ';
650iA                          else;
650iA                             w1uom = umshrt;
650iA                          endif;
650iA                       else;
650iA                          w1uom = 'BDQ';
650iA                       endif;
650iA                    endif;
650iA /end-free

     C     endget1       endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGET2   Get record(s) for screen 1.
500dA*----------------------------------------------------------------
500dA
500dAC     zzget2        begsr

     *  Get From slot information.

     C*                  eval      getwhse = lbwhse
     C*                  eval      getwhdp = lbwhdp
     C*                  eval      getdisp = lbdisp
     C*                  exsr      zzgetfromsl

     *  Get From Item information.

     C*                  exsr      zzgetfromit

     *  Get Pick slot information.

     C*                  eval      getwhse = lbwhs2
     C*                  eval      getwhdp = lbwhd2
     C*                  eval      getdisp = lbdsp2
     C*                  exsr      zzgetpicksl

     *  Get Pick Item information.

     C*                  exsr      zzgetpickit

     C     endget2       endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGET5   Get record(s) for screen 5.
500dA*----------------------------------------------------------------
500dA
500dAC     zzget5        begsr

     *  Get Label record.

600aMC     wulbl#        chain(n)  label
     C                   if        not %found
     C                   endif
750aAc*                  exsr      chkfordrppck

     *  Get From slot information.

     C                   eval      getwhse = lbwhse
     C                   eval      getwhdp = lbwhdp
     C                   eval      getdisp = lbdisp
     C                   exsr      zzgetfromsl

     *  Get From Item information.

     C                   exsr      zzgetfromit

     *  Get Pick slot information.

     C                   eval      getwhse = lbwhs2
     C                   eval      getwhdp = lbwhd2
     C                   eval      getdisp = lbdsp2
     C                   exsr      zzgetpicksl
750aA /free
750aA     // get virtual for this if it represents Drop Pick
750aA     exec sql select slalc1,slalc2,slalc3,
750aA                     slpck1,slpck2,slpck3,
750aA                     slstk1,slstk2,slstk3
750aA             into :#pickslalc1,:#pickslalc2,:#pickslalc3,
750aA                  :#pickslpck1,:#pickslpck2,:#pickslpck3,
750aA                  :#pickslstk1,:#pickslstk2,:#pickslstk3
750aA                        from vslot,slot
750aA                where vspdis=:#picksldisp and vswhse=slwhse and
750aA              slwhdp=vswhdp and sldisp=vsdisp and slstat='DP'
750aA              and slitem=:#pickslitem fetch first row only;
750aA /end-free

     *  Get Pick Item information.

     C                   exsr      zzgetpickit
650iA*  if Production and label set for breakdown 1 set replen
650iA*  item type to Each so everything moves from correct quantity
650iA /free
730 M                    if wuRplType = 'O' or wuRplType='D';
650iA                       if lbutyp = '1';
650iA                          prtype = 'E';
650iA                       else;
650iA                          prtype = #pickittype;
650iA                       endif;
650iA                    endif;
650iA /end-free

     C     endget5       endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGET6   Get record(s) for screen 6.
500dA*----------------------------------------------------------------
500dA
500dAC     zzget6        begsr

     *  Get Label record.

600aMC     wulbl#        chain(n)  label
     C                   if        not %found
     C                   endif
500vA
500vA*  Get From slot information.
500vA
600aMC                   eval      getwhse = wuwhse
600aMC                   eval      getwhdp = wupulwhdp
600aMC                   eval      getdisp = wupuldisp
500vAC                   exsr      zzgetfromsl
500vA
500vA*  Get From Item information.
500vA
500vAC                   exsr      zzgetfromit
500vA
500vA*  Get Pick slot information.
500vA
600aMC                   eval      getwhse = wuwhse
600aMC                   eval      getwhdp = wupckwhdp
600aMC                   eval      getdisp = wupckdisp
500vAC                   exsr      zzgetpicksl
500vA
500vA*  Get Pick Item information.
500vA
500vAC                   exsr      zzgetpickit

     C     endget6       endsr

600aA*----------------------------------------------------------------
600aA*  getcurrstamp  Get current timestamps
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

500fA*----------------------------------------------------------------
500fA*  zzgetdatetime  Get current date & time
500fA*----------------------------------------------------------------
500fA
500fAC     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETFROMIT   Get From item being replenished.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetfromit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #fromslwhse
     C                   eval      $ititem  = #fromslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
500kMC                   if        drierr
500kAC                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetfromit
     C                   endif

     C                   eval      #fromitwhse = $itwhse
     C                   eval      #fromititem = $ititem
     C                   eval      #fromittype = $ittype
     C                   eval      #fromitdesc = $itdesc
     C                   eval      #fromitpdsc = $itpdsc
     C                   eval      #fromitwhdp = $itwhdp
     C                   eval      #fromitstyp = $itstyp
     C                   eval      #fromitdesg = $itdesg
     C                   eval      #fromitum1  = $itum1
     C                   eval      #fromitflg1 = $itflg1
     C                   eval      #fromitum2  = $itum2
     C                   eval      #fromitumq2 = $itumq2
     C                   eval      #fromitflg2 = $itflg2
     C                   eval      #fromitum3  = $itum3
     C                   eval      #fromitumq3 = $itumq3
     C                   eval      #fromitnrpk = $imnrpk
     C                   eval      #fromitflgd = $itflgd
     C                   eval      #fromitcube = $itcube
     C                   eval      #fromitswgt = $itswgt
     C                   eval      #fromitcwgt = $itcwgt
     C                   eval      #fromitmitem = $itmitem
     C                   eval      #fromitsdef = ' '
     C                   eval      #fromittie  = 0
     C                   eval      #fromithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
500mA
500mA*  Get tracking info for item.
500mA
500mAC                   exsr      zzgettrack

     *  Get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #fromitwhse
     C                   eval      $ititem  = #fromititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      #fromssbflag = *off
     C                   eval      #fromssbititem = ' '
     C                   eval      #fromssbittype = ' '
     C                   eval      #fromssbitdesc = ' '
     C                   eval      #fromssbitpdsc = ' '
     C                   eval      #fromssbitwhdp = ' '
     C                   eval      #fromssbitstyp = ' '
     C                   eval      #fromssbitdesg = ' '
     C                   eval      #fromssbitum1  = ' '
     C                   eval      #fromssbitum2  = ' '
     C                   eval      #fromssbitumq2 = 0
     C                   eval      #fromssbitum3  = ' '
     C                   eval      #fromssbitumq3 = 0
     C                   else
     C                   eval      #fromssbflag = *on
     C                   eval      #fromssbititem = $ititem
     C                   eval      #fromssbittype = $ittype
     C                   eval      #fromssbitdesc = $itdesc
     C                   eval      #fromssbitpdsc = $itpdsc
     C                   eval      #fromssbitwhdp = $itwhdp
     C                   eval      #fromssbitstyp = $itstyp
     C                   eval      #fromssbitdesg = $itdesg
     C                   eval      #fromssbitum1  = $itum1
     C                   eval      #fromssbitum2  = $itum2
     C                   eval      #fromssbitumq2 = $itumq2
     C                   eval      #fromssbitum3  = $itum3
     C                   eval      #fromssbitumq3 = $itumq3
     C                   endif

     C     endgetfromit  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETFROMSL   Get From slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetfromsl   begsr

600aA*    Do not call DRISLOT after coming from LT108.
600aA*    Re: LT108 has already moved qtys from the From slot into
600aA*        the USR slot, so LT108 sends us the $slot/2 info.

600aAC                   if        not lt108Flag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = getwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = getwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = getdisp
650dAC                   eval      $sldesgu = *on
650dAC                   eval      $sldesg  = ' '

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
     C                   goto      endgetfromsl
     C                   endif

600aAC                   endif

     C                   eval      #fromslwhse = $slwhse
     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslstat = $slstat
     C                   eval      #fromslrsrv = $slrsrv
     C                   eval      #fromslentd = $slentd
     C                   eval      #fromslexpd = $slexpd
     C                   eval      #fromslslfd = $slslfd
     C                   eval      #fromslactv = $slactv
     C                   eval      #fromslbld  = $slbld
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslsdef = $slsdef
     C                   eval      #fromslside = $slside
     C                   eval      #fromslvirt = $sfvirt
     C                   eval      #fromslstk1 = $slstk1
     C                   eval      #fromslstk2 = $slstk2
     C                   eval      #fromslstk3 = $slstk3
     C                   eval      #fromslalc1 = $slalc1
     C                   eval      #fromslalc2 = $slalc2
     C                   eval      #fromslalc3 = $slalc3
     C                   eval      #fromsltfr1 = $sltfr1
     C                   eval      #fromsltfr2 = $sltfr2
     C                   eval      #fromsltfr3 = $sltfr3
     C                   eval      #fromslpck1 = $slpck1
     C                   eval      #fromslpck2 = $slpck2
     C                   eval      #fromslpck3 = $slpck3
     C                   eval      #fromslrcv1 = $slrcv1
     C                   eval      #fromslrcv2 = $slrcv2
     C                   eval      #fromslrcv3 = $slrcv3
     C                   eval      #fromslphy1 = $slphy1
     C                   eval      #fromslphy2 = $slphy2
     C                   eval      #fromslphy3 = $slphy3
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
     C                   eval      #fromslavl3 = $slavl3
650dAC                   eval      #fromsldesg = $sldesg

     C                   eval      #frombasesldsp = $sacdsp

600aAC                   eval      #fromsaToLcns = $saToLcns
600aAC                   eval      #fromsaToPos  = $saToPos
600aAC                   eval      #fromsaOLcns  = $saOLcns

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #fromslpos = $sdpos

     C     endgetfromsl  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETOVRFSL   Get Overflow slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetovrfsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #fromslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w6scan

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
500kAC                   eval      error = *on
     C                   goto      endgetovrfsl
     C                   endif

     C                   eval      #ovrfslwhse = $slwhse
     C                   eval      #ovrfslwhdp = $slwhdp
     C                   eval      #ovrfslstyp = $slstyp
     C                   eval      #ovrfsldisp = $sldisp
     C                   eval      #ovrfslaisl = $slaisl
     C                   eval      #ovrfslloc  = $slloc
     C                   eval      #ovrfslpseq = $slpseq
     C                   eval      #ovrfslrlvl = $slrlvl
     C                   eval      #ovrfslhand = $slhand
     C                   eval      #ovrfslstat = $slstat
     C                   eval      #ovrfslrsrv = $slrsrv
     C                   eval      #ovrfslentd = $slentd
     C                   eval      #ovrfslexpd = $slexpd
     C                   eval      #ovrfslslfd = $slslfd
     C                   eval      #ovrfslactv = $slactv
     C                   eval      #ovrfslbld  = $slbld
     C                   eval      #ovrfslpick = $slpick
     C                   eval      #ovrfslitem = $slitem
     C                   eval      #ovrfslsdef = $slsdef
     C                   eval      #ovrfslvirt = $sfvirt
     C                   eval      #ovrfslstk1 = $slstk1
     C                   eval      #ovrfslstk2 = $slstk2
     C                   eval      #ovrfslstk3 = $slstk3
     C                   eval      #ovrfslalc1 = $slalc1
     C                   eval      #ovrfslalc2 = $slalc2
     C                   eval      #ovrfslalc3 = $slalc3
     C                   eval      #ovrfsltfr1 = $sltfr1
     C                   eval      #ovrfsltfr2 = $sltfr2
     C                   eval      #ovrfsltfr3 = $sltfr3
     C                   eval      #ovrfslpck1 = $slpck1
     C                   eval      #ovrfslpck2 = $slpck2
     C                   eval      #ovrfslpck3 = $slpck3
     C                   eval      #ovrfslrcv1 = $slrcv1
     C                   eval      #ovrfslrcv2 = $slrcv2
     C                   eval      #ovrfslrcv3 = $slrcv3
     C                   eval      #ovrfslphy1 = $slphy1
     C                   eval      #ovrfslphy2 = $slphy2
     C                   eval      #ovrfslphy3 = $slphy3
     C                   eval      #ovrfslavl1 = $slavl1
     C                   eval      #ovrfslavl2 = $slavl2
     C                   eval      #ovrfslavl3 = $slavl3

     C                   eval      #ovrfbasesldsp = $sacdsp

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
500kMC                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #ovrfslpos = $sdpos

     C     endgetovrfsl  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETPICKIT   Get pick slot item being replenished.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetpickit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickslwhse
     C                   eval      $ititem  = #pickslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
500kMC                   if        drierr
500kAC                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #pickitwhse = $itwhse
     C                   eval      #pickititem = $ititem
     C                   eval      #pickittype = $ittype
     C                   eval      #pickitdesc = $itdesc
     C                   eval      #pickitpdsc = $itpdsc
     C                   eval      #pickitwhdp = $itwhdp
     C                   eval      #pickitstyp = $itstyp
     C                   eval      #pickitdesg = $itdesg
     C                   eval      #pickitum1  = $itum1
     C                   eval      #pickitflg1 = $itflg1
     C                   eval      #pickitum2  = $itum2
     C                   eval      #pickitumq2 = $itumq2
     C                   eval      #pickitflg2 = $itflg2
     C                   eval      #pickitum3  = $itum3
     C                   eval      #pickitumq3 = $itumq3
     C                   eval      #pickitnrpk = $imnrpk
     C                   eval      #pickitflgd = $itflgd
     C                   eval      #pickitcube = $itcube
     C                   eval      #pickitswgt = $itswgt
     C                   eval      #pickitcwgt = $itcwgt
     C                   eval      #pickitmitem = $itmitem
     C                   eval      #pickitsdef = ' '
     C                   eval      #pickittie  = 0
     C                   eval      #pickithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #pickititem
     C                   parm                    #pickitdesc
     C                   parm                    #pickitpdsc
     C                   parm      ' '           #pickithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #pickslsdef
     C                   eval      #pickitsdef = $idsdef(i)
     C                   eval      #pickittie  = $idtie(i)
     C                   eval      #pickithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo

     *  Get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickitwhse
     C                   eval      $ititem  = #pickititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      #pickssbflag = *off
     C                   eval      #pickssbititem = ' '
     C                   eval      #pickssbittype = ' '
     C                   eval      #pickssbitdesc = ' '
     C                   eval      #pickssbitpdsc = ' '
     C                   eval      #pickssbitwhdp = ' '
     C                   eval      #pickssbitstyp = ' '
     C                   eval      #pickssbitdesg = ' '
     C                   eval      #pickssbitum1  = ' '
     C                   eval      #pickssbitum2  = ' '
     C                   eval      #pickssbitumq2 = 0
     C                   eval      #pickssbitum3  = ' '
     C                   eval      #pickssbitumq3 = 0
     C                   else
     C                   eval      #pickssbflag = *on
     C                   eval      #pickssbititem = $ititem
     C                   eval      #pickssbittype = $ittype
     C                   eval      #pickssbitdesc = $itdesc
     C                   eval      #pickssbitpdsc = $itpdsc
     C                   eval      #pickssbitwhdp = $itwhdp
     C                   eval      #pickssbitstyp = $itstyp
     C                   eval      #pickssbitdesg = $itdesg
     C                   eval      #pickssbitum1  = $itum1
     C                   eval      #pickssbitum2  = $itum2
     C                   eval      #pickssbitumq2 = $itumq2
     C                   eval      #pickssbitum3  = $itum3
     C                   eval      #pickssbitumq3 = $itumq3
     C                   endif

     C     endgetpickit  endsr
500dA
500dA*----------------------------------------------------------------
500dA*  ZZGETPICKSL   Get Pick slot.
500dA*----------------------------------------------------------------
500dA
500dAC     zzgetpicksl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = getwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = getwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = getdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
     C                   goto      endgetpicksl
     C                   endif

     C                   eval      #pickslwhse = $slwhse
     C                   eval      #pickslwhdp = $slwhdp
     C                   eval      #pickslstyp = $slstyp
     C                   eval      #picksldisp = $sldisp
     C                   eval      #pickslaisl = $slaisl
     C                   eval      #pickslloc  = $slloc
     C                   eval      #pickslpseq = $slpseq
     C                   eval      #pickslrlvl = $slrlvl
     C                   eval      #pickslhand = $slhand
     C                   eval      #pickslstat = $slstat
     C                   eval      #pickslrsrv = $slrsrv
     C                   eval      #pickslentd = $slentd
     C                   eval      #pickslexpd = $slexpd
     C                   eval      #pickslslfd = $slslfd
     C                   eval      #pickslactv = $slactv
     C                   eval      #pickslbld  = $slbld
     C                   eval      #pickslpick = $slpick
     C                   eval      #pickslitem = $slitem
730 Ac                   if        #pickslitem = *blanks and $sldesg='*DROP'
730 Ac                   eval      #pickslitem = #fromititem
730 Ac                   endif
     C                   eval      #pickslsdef = $slsdef
     C                   eval      #pickslside = $slside
     C                   eval      #pickslvirt = $sfvirt
     C                   eval      #pickslstk1 = $slstk1
     C                   eval      #pickslstk2 = $slstk2
     C                   eval      #pickslstk3 = $slstk3
     C                   eval      #pickslalc1 = $slalc1
     C                   eval      #pickslalc2 = $slalc2
     C                   eval      #pickslalc3 = $slalc3
     C                   eval      #picksltfr1 = $sltfr1
     C                   eval      #picksltfr2 = $sltfr2
     C                   eval      #picksltfr3 = $sltfr3
     C                   eval      #pickslpck1 = $slpck1
     C                   eval      #pickslpck2 = $slpck2
     C                   eval      #pickslpck3 = $slpck3
     C                   eval      #pickslrcv1 = $slrcv1
     C                   eval      #pickslrcv2 = $slrcv2
     C                   eval      #pickslrcv3 = $slrcv3
     C                   eval      #pickslphy1 = $slphy1
     C                   eval      #pickslphy2 = $slphy2
     C                   eval      #pickslphy3 = $slphy3
     C                   eval      #pickslavl1 = $slavl1
     C                   eval      #pickslavl2 = $slavl2
     C                   eval      #pickslavl3 = $slavl3

     C                   eval      #pickbasesldsp = $sacdsp

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
700fAC                   eval      $sdpal = ''
     C                   endif
     C                   eval      #pickslpos = $sdpos
700fAC                   eval      #picksdpal = $sdpal

     C     endgetpicksl  endsr

     *----------------------------------------------------------------
     *  zzgetworkrec  Get next work record.
     *----------------------------------------------------------------

     C     zzgetworkrec  begsr
     C                   eval      foundworkrec = *off
     C                   eval      retry = *on

     C                   dow       forever = forever

600aMC     keywu5whdp    reade(n)  workusr5

     *    First time EOF is reached. Reposition to BOF.
     *    Look for any missed replenishments.

     C                   if        %eof and retry
     C                   eval      kyfasl = *blanks
600jMC     keywu5fasl    setll     workusr5
     C                   eval      retry = *off
     C                   iter
     C                   endif

     *    Next time EOF is reached. Get out.

     C                   if        %eof
     C                   leave
     C                   endif

     *    If in Replenishment mode, then look for status 1 records.

600aMC                   if        rplmode = 'RPL' and wustat = '1'
500 AC                   eval      foundworkrec = *on
610bDC**                 eval      curlic# = wuscannbr
610bMC                   eval      curlic# = wuusrlcns
600aMC                   eval      curlbl# = wulbl#
     C                   leave
     C                   endif

     *    If in Putback mode, then look for status 2 records.

600aMC                   if        rplmode = 'PUT' and wustat = '2'
500 AC                   eval      foundworkrec = *on
610bDC**                 eval      curlic# = wuscannbr
610bMC                   eval      curlic# = wuusrlcns
600aMC                   eval      curlbl# = wulbl#
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *    LABEL7 file is a Join file with PIRITEM and hence, no need
     *    to chain to that file.
     *
     C                   eval      $istr = *blanks
500dMC                   call      'FRMTIT'
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      svitem = $iitem
     *
     C                   endsr

500mA*----------------------------------------------------------------
500mA*  ZZGETTRACK  Get tracking options.
500mA*----------------------------------------------------------------
500mA
500mAC     zzgettrack    begsr

     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #pgm
     C                   eval      $lwhse2 = $pwhse
     C                   eval      $ltrackitem = $imltrk

     C                   call      'GETTRACK'
     C                   parm                    $lparm

     C                   eval      trackitem   = $ltrackitem
     C                   eval      trackpos    = $ltrackpos
     C                   eval      trackposmrg = $lposmrg
     C                   eval      trackposrtn = $lposrtn
     C                   eval      trackpsplit  = $lpsplit
     C                   eval      tracktsplit  = $ltsplit

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGTW1   Get work pushback replenishment record. From slot seq
     *----------------------------------------------------------------

     C     zzgtw1        begsr
     C                   eval      retry = *on

     C                   dow       forever = forever

600aMC     keywu4emp#    reade(n)  workusr4
     C                   select

     *    First time EOF is reached. Reposition to BOF.
     *    Look for any missed replenishments.

     C                   when      %eof and retry
     C                   eval      kyfasl = *blanks
     C     keywu4fasl    setll     workusr4
     C                   eval      *in79 = *off
     C                   eval      retry = *off
     C                   iter

     *    Next time EOF is reached. Get out.

     C                   when      %eof
     C                   eval      stop = *on
     C                   leave

     *    Replenishment doesn't have any qty to return to From slot.
     *    or Replenishment balance returned to overflow slot.
     *    Select ONLY replenishments that have balance qty.

600aMC                   when      wustat = '1'
610bDC**                 eval      curlic# = wuscannbr
610bMC                   eval      curlic# = wuusrlcns
     C                   leave

     C                   endsl

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGTW2   Get work pushback replenishment record. To slot seq
     *----------------------------------------------------------------

     C     zzgtw2        begsr
     C                   eval      retry = *on

     C                   dow       forever = forever

600aMC     keywu5Whdp    reade(n)  workusr5
     C                   select

     *    First time EOF is reached. Reposition to BOF.
     *    Look for any missed replenishments.

     C                   when      %eof and retry
     C                   eval      kytasl = *blanks
600aMC     keywu5tasl    setll     workusr5
     C                   eval      retry = *off
     C                   iter

     *    Next time EOF is reached. Get out.

     C                   when      %eof
     C                   eval      stop = *on
     C                   leave

     *    Replenishment to pick slot complete and zero balance
     *    remaining or qty remaining to be returned to overflow slot.
     *    Select ONLY replenishments to pick slots that haven't been
     *    completed.

600AMC                   when      wustat = '2'
     C                   leave

     C                   endsl

     C                   enddo

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      balexc = *off
     C                   eval      balrem = *blanks
     C                   eval      bszero = *off
     C                   eval      bypass = *off
     C                   eval      chknew = *off
     C                   eval      curent = *off
     C                   eval      crtrcd = *off
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      dteold = *off
     C                   eval      dteofl = *off
     C                   eval      exist = *off
     C                   eval      flaghs = *off
     C                   eval      forevr = *off
     C                   eval      flrplt = *zeros
     C                   eval      lstscr = *blanks
500vDC**                 eval      newlb = *off
     C                   eval      newrpl = *off
     C                   eval      ptatyp = *blanks
     C                   eval      retry = *off
     C                   eval      rpltyp = *blanks
     C                   eval      rtnhom = *off
     C                   eval      rtnto = *blanks
     C                   eval      sltmax = *zeros
     C                   eval      skippd = *off
     C                   eval      skpslt = *off
     C                   eval      stop = *off
     C                   eval      usrrpl = *off
     C                   eval      vrtslt = *off
     C                   eval      wozero = 'N'
     C                   eval      woemty = ' '
     C                   eval      w4qty = *blanks
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
     *
     *    Define partial key for LABEL7 file.
     *
     C     lbkey7        klist
     C                   kfld                    pttrn#
500sDC**                 kfld                    kyitem
     *
     *    Define key for ITEMDEF file.
     *
     C     keyid         klist
     C                   kfld                    lbwhse
     C                   kfld                    slitem
     C                   kfld                    slsdef
     *
     *  Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *    Define key for LABEL file.
     *
     C     lbkey         klist
     C                   kfld                    svlbl#
     *
     *  Define key for OPTIOND file.
     *
     C                   eval      kydcod = '*PICK   '
     C     opdkey        klist
     C                   kfld                    kydcod
     C                   kfld                    kydwhs
     C                   kfld                    kydwdp
     *
     *    Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     C                   eval      kycode = '*FEATURE'
     *
     *    Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    svtrn#
     *
     *    Define key for PIRTRAN2 file.
     *
     C     ptke22        klist
     C                   kfld                    #emp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    #emp#
     C                   kfld                    kystat
     *
     *    Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    #emp#
     C                   kfld                    stdate
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C                   eval      wkgrp1 = 'L'
     C                   eval      wkgrp2 = ' '
     C     ptkey3        klist
     C                   kfld                    $pwhse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     *
     *    Define Full key for PIRTRAN3 file.
     *
     C                   eval      wkrtpo = '0'
     C     ptky3a        klist
     C                   kfld                    $pwhse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     C                   kfld                    wkrtpo
     C                   kfld                    kytrn#
     *
     *    Define Partial key for PRPLFIL6 file.
     *
     C     prky6a        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    $pfail
     *
     C     prky6b        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     *
     C     prky6c        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    prfail
     C                   kfld                    prfloc
     C                   kfld                    prflvl
     *
     C     prky6d        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    prfail
     C                   kfld                    prfloc
     C                   kfld                    prflvl
     C                   kfld                    svfpos
     C                   kfld                    svseq#
650bA *
650bAC     keypr2        klist
650bAC                   kfld                    prwhse
650bAC                   kfld                    prwhdp
650bAC                   kfld                    prseq#
600uA*
600uA*    Define full key for WORKUSR 3 file
600uA*
600uAC     keywu3        klist
600uAC                   kfld                    kyrectype
600uAC                   kfld                    #emp#
600uAC                   kfld                    kywhse
600uaC                   kfld                    kywhdp
600uAC                   kfld                    kydisp
     *
     *    Define Full key for PRPLFIL6 file.
     *
     C     prky6e        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    prfail
     C                   kfld                    prfloc
     C                   kfld                    prflvl
     C                   kfld                    prfpos
     C                   kfld                    prseq#
     *
     *    Define key for SLOTDEF file.
     *
     C     sdkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    slsdef
     *
     *    Define key for SLOT2 file. (From slot)
     *
     C     keysl1        klist
     C                   kfld                    w7whse
     C                   kfld                    w7whdp
     C                   kfld                    kyaisl
     *
     *    Define key for SLOT2 file. (From slot)
     *
     C     slfkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp
     C     slfmky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    lbdisp
     *
     C     sfmky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    w6scan
     *
     *    Define key for SLOT2 file. (To slot)
     *
     C     sltkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdsp2
     *
     *  Define partial key for SLOT3 file.
     *
     C     keys3         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     *    Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *    Define key for TASKDET file.
     *
     C     keytd         klist
     C                   kfld                    pttask
     C                   kfld                    ptwhse
     C                   kfld                    ptwhdp
     C                   kfld                    ptstyp
     *
     *    Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    kyitem
     *
650gA*    Define key for PIRITEM file.
650gA*
650gAC     itkey1        klist
650gAC                   kfld                    prwhse
650gAC                   kfld                    pritem
     *
     *    Define key for ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *    Define key for VSLOT1 file. (From slot)
     *
     C     svfkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    svfdis
     C     keyvs2        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kydisp
     *
     *    Define key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
600aD **
600aD **   Define key for WORKRPL file.
600aD **
600aDC**   wrkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aD **
600aDC**   wrkya         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aDC**                 kfld                    wrnbr
600aDC**                 kfld                    wrtype
600aD **
600aD **   Define key for WORKRPL1 file.
600aD **
600aDC**   wrkey1        klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aDC**                 kfld                    $pwhdp
600aDC**                 kfld                    kyfasl
600aDC**   wrky1a        klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aD **
600aD **   Define key for WORKRPL2 file.
600aD **
600aDC**   wrkey2        klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aDC**                 kfld                    $pwhdp
600aDC**                 kfld                    kytasl
600aDC**   wrky2a        klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    #user
600aDC**                 kfld                    $pwhdp
600aD **
600aD ** Define key for WORKRPL3 file.
600aD **
600aDC**   wrkey3        klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    kynbr
600aDC**                 kfld                    kytype
600aA*
600aA*    Define key for WORKUSR1 file
600aA*
600aAC**   keywu1        klist
600aAC**                 kfld                    $pwhse
600aAC**                 kfld                    kynbr
600aAC**                 kfld                    kytype
600aA*
600aA*    Define full key for WORKUSR2 file
600aA*
600aAC     keywu2        klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    wuscannbr
600aAC                   kfld                    wuscantype
610lAC                   kfld                    kyitem
600aA*
600aA*    Define partial key for WORKUSR2 file
600aA*
600aAC     keywu2p       klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aA*
600aA*    Define partial key for WORKUSR4 file
600aA*
600aAC     keywu4emp#    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aA*
600aA*    Define partial key for WORKUSR4 file
600aA*
600aAC     keywu4whdp    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aA*
600aAC     keywu4fasl    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aAC                   kfld                    kyfasl
600aA*
600aAC     keywu4tasl    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aAC                   kfld                    kytasl
600aA*
600aA*    Define partial key for WORKUSR5 file
600aA*
600aAC     keywu5whdp    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aA*
600aAC     keywu5fasl    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aAC                   kfld                    kyfasl
600aA*
600aAC     keywu5tasl    klist
600aAC                   kfld                    kyrectype
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aAC                   kfld                    kytasl
     *
     *    - Get default values for the user.
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
500 A*
500 A*   Load handstack array with codes (A..Z, AA..AZ, ...)
500 A*
500 AC                   eval      k = 0
500 AC     1             do        27            i
500 AC     2             do        27            j
500 AC                   add       1             k
500 AC     ltr(i)        cat       ltr(j)        hnd(k)
500 AC                   enddo
500 AC                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
600aAC                   eval      kyrectype = 'RPL'
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      refrsh = *on
     C                   eval      done = *off
     C                   eval      excptn = *off
     C                   eval      rplstr = '*NO '
     C                   eval      vfyslt = '*NO '
500fAC                   eval      rplmode = 'RPL'
500nAC                   eval      bypass = *off
510gAC*
510gAC*   Get screen size being used.
510gAC*
510gAC                   call      'PIRRFSCR'
510gAC                   PARM      '*GET'        #LCMD             8
510gAC                   PARM                    #LLINE            2
510gAC                   PARM                    #LCOL             3
     *
     *    Get virtual slot options.
     C                   eval      kywhse = $pwhse
     *    Get installed feature level.
     C                   exsr      zzfeat
     *    Remove any existing previously scanned in entries for this user.
     C                   exsr      zzdlwr
     *
     *    Initialize Replenishment type to be processed.
     C                   select
500bMC                   when      $prplt = 'F'
500bMC                   eval      rpltyp = '*FLOW'
     C                   eval      *in61 = *on
     *
     C                   when      $prplt = 'B'
500bMC                   eval      rpltyp = '*BRKDWN'
     C                   eval      *in61 = *on
530 A*
530 AC                   when      $prplt = 'R'
530 AC                   eval      rpltyp = '*REPACK'
530 AC                   eval      *in61 = *on
650fA*
730 AC                   when      $prplt = 'D'
750aDC*                  eval      rpltyp = '*PROD'
750aMC                   eval      rpltyp = '*DROPP'
730 AC                   eval      *in61 = *on
730 MC                   when      $prplt = 'O'
650fAC                   eval      rpltyp = '*PROD'
650fAC                   eval      *in61 = *on
720 A*
720 AC                   when      $prplt = 'S'
720 AC                   eval      rpltyp = '*STRREPL'
720 AC                   eval      *in61 = *on
     *
     C                   endsl
     *
     *    Load appropriate display headings.
     *
     C                   select
     *
500bMC                   when      rpltyp = '*BRKDWN'
     C                   eval      wohdr1 = desc(10)
     *
500bMC                   when      rpltyp = '*FLOW'
     C                   eval      wohdr1 = desc(11)
650fA*
650fAC                   when      rpltyp = '*PROD'
650fAC                   eval      wohdr1 = desc(33)
750aA*
750aAC                   when      rpltyp = '*DROPP'
750aAC                   eval      wohdr1 = 'Drop Pick'
720 A*
720 AC                   when      rpltyp = '*STRREPL'
720 AC                   eval      wohdr1 = desc(37)
     *
530 AC                   when      rpltyp = '*REPACK'
530 AC                   movel     desc(30)      wohdr1
     *
     C                   endsl
     C                   eval      wohdr2 = *blanks
     *
     *    Get & create Pushback Priority Replenishment.
     C     prky6a        setll     prplfil6
     C                   eval      done = *off
500 AC                   eval      updrplrec = *on
     C                   exsr      zznxt1
     C                   select
     *
     *    Replenishments to do. Get to work.
     C                   when      done = *off
500 AC                   eval      curitm = lbitem
500 AC                   eval      curwhd = lbwhdp
     C                   eval      curasl = lbaisl
     C                   eval      curloc = lbloc
     C                   eval      curlvl = lbrlvl
     C                   eval      curhnd = lbhand
     C                   eval      curdsp = lbdisp
     C                   eval      flrplt = *zeros
     *
     C                   exsr      scr01i
     *
     C                   other
     *
     *    End of Pushback/Eaches replenishments. Display screen.
     C                   exsr      scr07i
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZADWR   Add license plates to work file for user.
     *
     C     zzadwr        begsr
     *
600aAC                   exsr      zzgetcurrstamp

600aMC                   clear                   wurec
     *
600aAC                   eval      wurectype = kyrectype
600aDC**                 eval      wruser = #user
610dDC**                 eval      wuscannbr = #fromsaToLcns
610dMC                   eval      wuscannbr = $saToLcns
600aMC                   eval      wuscantype = 'P'
600aMC                   eval      wutrn# = lbtrn#
600aMC                   eval      wulbl# = lblbl#
600aMC                   eval      wustat = '1'
600aMC                   eval      wuwhse = lbwhse

600aMC                   eval      wupulitem = #fromslitem
600aMC                   eval      wunewitem = #pickslitem

600aAC                   eval      wuremqty1 = w2nqty
600aAC                   eval      wuremqty2 = 0
600aAC                   eval      wuremqty3 = 0

600aAC                   eval      wupullcns  = #fromsaToLcns
600aAC                   eval      wupulolcns = #fromsaOLcns
600aMC                   eval      wupulwhdp = #fromslwhdp
600aAC                   eval      wupulbase = #frombasesldsp
600aMC                   eval      wupuldisp = #fromsldisp
600aAC                   eval      wupulaisl = #fromslaisl
600aMC                   eval      wupulloc = #fromslloc
600aMC                   eval      wupulrlvl = #fromslrlvl
600aMC                   eval      wupulhand = #fromslhand
600aAC                   eval      wupulcode  = 'S'
600aAC                   eval      wupularea  = 'Slot'
600aMC                   eval      wupulpos   = $tslotpos
600aMC                   eval      wupulpseq = #fromslpseq
600aMC                   eval      wupulside = #fromslside
600aAC                   eval      wupulutype = lbutyp

600aAC                   eval      wuusrlcns  = $saToLcns
600aAC                   eval      wuusrwhdp  = $slwhdp
600aAC                   eval      wuusrdisp  = $sldisp

600aAC                   eval      wupckwhdp = #pickslwhdp
600aMC                   eval      wupckdisp = #picksldisp
600aMC                   eval      wupckaisl = #pickslaisl
600aMC                   eval      wupckloc = #pickslloc
600aMC                   eval      wupckrlvl = #pickslrlvl
600aMC                   eval      wupckhand = #pickslhand
600aAC                   eval      wupckcode  = 'S'
600aAC                   eval      wupckarea  = 'Slot'
600aMC                   eval      wupckpos   = 0
600aMC                   eval      wupckpseq = #pickslpseq
600aMC                   eval      wupckside = #pickslside
600aAC                   eval      wupckutype = ' '

     *    Product needed back in slot when replenishment complete.
     C                   if        rtnhom = *on
600aMC                   eval      wurtnhome = 'Y'
     C                   else
600aMC                   eval      wurtnhome = 'N'
     C                   endif

     *    Zero Verify From slot when replenishment is complete.
     C                   if        vfyslt = '*YES'
600aMC                   eval      wupulvfy = 'Y'
     C                   else
600aMC                   eval      wupulvfy = 'N'
     C                   endif

     C                   eval      wurpltype  = $prplt

600aAC                   eval      wuaddts  = currstampsys
600aAC                   eval      wuadduc  = currstampuc
600aAC                   eval      wuaddpgm = #pgm
600aAC                   eval      wuaddemp = #emp#
600aAC                   eval      wuaddeusr = #curruser
600aAC                   eval      wuaddjusr = #user
600aAC                   eval      wuaddjob = #job
600aAC                   eval      wuaddnbr = #jobnbr
     *
600aMC                   write     wurec
     *
500tAC                   eval      workcount = workcount + 1
     *
     C                   endsr
     *
650cA*----------------------------------------------------------------
650cA*
650cA*  zzCrtRptRepl  Create Repack Replenishment for remaining
650cA*                quantity when Repack was asking for more
650cA*                quantity than found in first slot
650cA*
650cAc     zzCrtRptRepl  begsr
650cA /free
650cA    // determine next unique sequence number to be used
650cA        setgt (prwhse:prwhdp:prseq#) prplfil1;
650cA        read prplfil1;
650cA        if not %eof(prplfil1);
650cA           dow not %eof(prplfil1) and %found(prplfil1);
650cA              prseq1 = prseq1 + 2;
650cA              read prplfil1;
650cA           enddo;
650cA        else;
650cA           prseq1 = prseq# + 2;
650cA        endif;
650cA /end-free
650cAc                   eval      prwhs1 = prwhse
650cAc                   eval      prwhd1 = prwhdp
650cAc                   eval      prfai1 = prfail
650cAc                   eval      prflo1 = prfloc
650cAc                   eval      prflv1 = prflvl
650cAc                   eval      prfhn1 = prfhnd
650cAc                   eval      prfpo1 = prfpos
650cAc                   eval      prtai1 = prtail
650cAc                   eval      prtlo1 = prtloc
650cAc                   eval      prtlv1 = prtlvl
650cAc                   eval      prthn1 = prthnd
650cAc                   eval      prtpo1 = prtpos
650cAc                   eval      prfdi1 = prfdis
650cAc                   eval      prtdi1 = prtdis
650cAc                   eval      pritm1 = pritem
650cAc                   eval      prqty1 = w2repq - w2nqty
650cAc                   eval      prsde1 = prsdef
650cAc                   eval      prflg1 = 'S'
650cAc                   eval      prprt1 = prprty
650cAc                   eval      prfre1 = prfree
650cAc                   eval      prsta1 = prstat
650cAc                   eval      prtyp1 = prtype
650cAc                   eval      prrpl1 = prrplt
650cAc                   eval      pradt1 = pradte
650cAc                   eval      pratm1 = pratim
650cAc                   eval      praqs1 = praqs
650dA
650dAc                   exsr      getNxtSlot
650dAc                   if        fndSlot = 'Yes'
650dAc                   eval      prfdi1 = sldisp
650dAc                   eval      prfai1 = slaisl
650dAc                   eval      prflo1 = slloc
650dAc                   eval      prflv1 = slrlvl
650dAc                   eval      prfhn1 = slhand
650dAc                   endif
650dA
650cAc                   write     prrec1
650cAc                   eval      qtyGrtSlt = *on
650cAc                   endsr
     *
600aD *----------------------------------------------------------------
600aD *
600aD *  ZZCKWR   Check if number scanned is in the file already.
600aD *
600aDC**   zzckwr        begsr
600aD **
600aDC**   keywu1        setll     workusr1                               76
600aDC**                 select
600aD **   License or label already scanned in by another user.
600aDC**                 when      *in76
600aD **   Retrieve record so we know who scanned in record.
600aDC**   keywu1        reade     workusr1                               76
600aDC**                 if        *in76
600aDC**                 eval      wu1_wuuser = *blanks
600aDC**                 endif
600aDC**                 eval      error = *on
600aDC**                 eval      erpnbr = wu1_wuscannbr
600aDC**                 eval      erpusr = wu1_wuuser
600aDC**                 select
600aDC**                 when      ptatyp = '*LICENSE'
600aDC**                 eval      *in02 = *on
600aDC**                 eval      *in22 = *on
600aDC**                 movel     desc(28)      erptxt
600aD **
600aDC**                 when      ptatyp = '*LABEL  '
600aDC**                 eval      *in02 = *on
600aDC**                 eval      *in22 = *on
600aDC**                 movel     desc(27)      erptxt
600aD **
600aDC**                 endsl
600aDC**                 exsr      zm2008
600aDC**                 endsl
600aD **
600aDC**                 endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDLWR   Delete existing work records for user.
     *
     C     zzdlwr        begsr
     *
600aMC     keywu2P       setll     workusr2
     C                   dow       forevr = forevr
600aMC     keywu2p       reade     workusr2                               79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
600aMC                   delete    wurec
     *
     C                   endsl
     C                   enddo
     *
500tAC                   eval      workcount = 0
     C                   endsr
500tA*----------------------------------------------------------------
500tA*
500tA*  ZZDLWR1  Delete single work record for user.
500tA*
500tAC     zzdlwr1       begsr
     *
600aMC     keywu2p       setll     workusr2
     C                   dow       forevr = forevr
600aMC     keywu2p       reade     workusr2
     C                   if        %eof
     C                   leave
     C                   endif
     *
600aMC                   if        wulbl# <> lblbl#
     C                   iter
     C                   endif
     *
600aMC                   delete    wurec
500tAC                   eval      workcount = workcount - 1
     C                   leave
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSTR2   Start a new transaction - (Created automatically)
     *
     C     zzstr2        begsr
     C                   eval      done = *off
     *    Get next Let-Down record.
     C     ptky3a        setll     pirtran3                               77
     *    -Match not found
     C                   if        not *in77
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *    -Match found - Read the records until we find the Let-Down.
     C     ptky3a        reade     pirtran3                               77
     *    - EOF
     C                   if        *in77
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *    - Transaction inuse.
     C                   if        ptstat >= '2'
     C                   eval      done = *on
     C                   goto      endst2
     C                   endif
     *
     *    Found created let-down record.  Process it.
     *
414fD*R                   Z-ADDPTTRN#    SVTRN#
414fMC                   eval      svtran = pttrn#
     *
     *    - Get label record. LetDowns has only one label record
     *      per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
415uA*
415uA*    - Wrong transaction number.
415uAC                   if        lbtrn# <> pttrn#  or
415uAC                             *in79
415uAC                   eval      done = *on
415uAC                   goto      endst2
415uAC                   endif
     *
414fA*    Get current task.
416hAC                   eval      curtrn = *zeros
416hAC                   eval      curtsk = *blanks
416hAC                   eval      curtyp = *blanks
416hAC                   eval      curent = *off
414fA*    Now retrieve next task record again.
414fAC     svtran        chain(n)  pirtran                            79
414fMC                   eval      svtrn# = svtran

500dAC                   exsr      zztrnstart

     C                   eval      topick = lbqpck
500qDC**                 if        pttask = 'REPLBK'
500qDC**                 eval      rplqty = lbqrmn
500qDC**                 else
     C                   eval      rplqty = topick
500qDC**                 endif
     C                   eval      svlbl# = lblbl#
     C                   eval      svqalc = lbqalc
     C                   eval      svqpck = lbqpck
     C                   eval      svcube = lbcube
     C                   eval      svswgt = lbswgt
     C                   eval      svqrmn = lbqrmn
     C     endst2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPPR   Update single work record.
     *
     C     zzuppr        begsr
     *
600aMC     keywu2        chain     workusr2                           79
     C                   select
     C                   when      not *in79
600aMC                   eval      wupulvfy = w3zero
600aMC                   update    wurec
     *
     C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zznextstep   Get next step - Replenishment or Putaway.
     *----------------------------------------------------------------

     C     zznextstep    begsr
501aAC                   eval      nomoresteps = *off

     C                   if        rplmode = ' '
     C                   eval      rplmode = 'RPL'
     C                   endif

     *  Keep looping until we determine what to do.

     C                   dow       forever = forever

     *    Get the next work recordzzgetworkrecrent mode we're in.

     C                   exsr      zzgetworkrec

     *    Work record found for current mode.

     C                   if        foundworkrec

     *      Display appropriate screen and get out.

     C                   select

     C                   when      rplmode = 'RPL'
720 Ac*   Add code to handle replenishments from warehouse to Store
720 Ac*   Staging Area
720 Ac                   if        rplTyp='*STRREPL'
720 Ac                   exsr      scr052i
720 Ac                   else
     C                   exsr      scr05i
720 Ac                   endif

     C                   when      rplmode = 'PUT'
500dMC                   if        firstput
500sMC                   exsr      zztrncrtstart
500dMC                   eval      firstput = *off
500sAC                   eval      rpltfrflag = *on
500dMC                   endif
     C                   exsr      scr06i

     C                   endsl

     C                   leave

     C                   endif

     *    Work record not found for current mode.

     *    If in Replenishment mode, then switch to Putback and try again.

     C                   if        rplmode = 'RPL'

     *      Close current Replenishment transaction.

500aAC                   eval      svtask = pttask
500dMC                   eval      curtrn# = pttrn#
500dMC                   exsr      zztrnclose

     *      Look for a Putback to do.

     C                   eval      rplmode = 'PUT'
500dMC                   eval      firstput = *on
     C                   iter
     C                   endif

     *    Otherwise, there is nothing left to do.
501aA
501aA*      Set flag to identify that there are no more steps to process.
501aA
501aAC                   eval      nomoresteps = *on
500sA
500sA*      Close current Replenishment Tfr transaction.
500sA
500sAC                   if        rpltfrflag
500sAC                   exsr      zztrnclose
500sAC                   endif
500sA
500sA*      Start idle task
500sA
500dMC                   exsr      zztrnidle
500sA
500sA*      Display info screen.
500sA
501aA*      Note: The call to zzupd7 has been moved after each call to
501aA*            this routine. Re: Under certain circumstances it was
501aA*            causing a recurssive call back to this routine.
501aA
     C                   exsr      scr07i
501aDC**                 if        rpltyp = '*FLOW'
501aDC**                 exsr      zzupd7
501aDC**                 endif
     C                   leave

     C                   enddo

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNXT1   Find & create next priority replenishment.
     *
     C     zznxt1        begsr
     *
     C     #nxt1         tag
     *
     C                   exsr      zznext
     C     done          cabeq     *on           endnx1
     *
     C                   eval      $lcmd = '*DELETE '
     C                   eval      $luky = dsfkey
     C                   eval      $lfeat = opfeat
     C                   eval      $lrplt = $prplt
     *
     *    No pushback replenishments started. Create new transaction/label.
     C                   if        rplstr = '*NO '
     C                   eval      $lcrtt = 'Y'
     C                   eval      $ltrn3 = *zeros
     C                   eval      $lpbat = *zeros
     C                   eval      $llbl# = *zeros
     *
     C                   else
     C                   eval      $lcrtt = 'N'
500fMC                   eval      $ltrn3 = curtrn#
     C                   eval      $lpbat = lbpbat
     C                   eval      $llbl# = *zeros
     *
     C                   endif

     *    Create actual transaction / replenishment.

500dMC                   call      'LT108'
     C                   parm                    $lparm
600aAC                   parm                    $slot
600aAC                   parm                    $slot2

500fAC                   if        $lrtn = '*NONE   '
500fAC     prky6e        chain     prplfil6                           7978
500fAC                   if        not *in79
500fAC                   eval      prflag = 'D'
500fAC                   update    prrec                                78
500fAC                   endif
500fAC                   goto      #nxt1
500fAC                   endif

     *    Start Pushback/Eaches transaction.

600aAC                   eval      lt108flag = *on

     C                   if        rplstr = '*NO '
500fMC                   eval      curtrn# = $ltrn3
500fMC                   exsr      zztrnstart
     C                   endif
     *
     C                   eval      wkrtpo = *blanks
     C                   eval      kytrn# = $ltrn3
     C     ptky3a        setll     pirtran3
     C     #nxt1a        tag
     C     ptkey3        reade     pirtran3                               77
     C                   if        *in77
     C                   eval      done = *on
     C                   goto      endnx1
     C                   endif
     *
     *    - Wrong transaction number.
     C                   if        pttrn# <> $ltrn3
     C                   goto      #nxt1a
     C                   endif
     *
     *    - Transaction NOT at Open status.
     C                   if        ptstat <> '2'
     C                   goto      #nxt1a
     C                   endif
     *
     *    - Different department.
     *
     C                   if        ptwhdp <> $pwhdp
     C                   goto      #nxt1a
     C                   endif
     *
     *    Found Pushback/Eaches Slot replenishment rcd - Process it.
     C                   eval      svtrn# = pttrn#
     *
     *    - Get replenishment record. Pushback/Eaches replenishment
     *      will have multiple label records per transaction number.
     *
500sDC**                 eval      kyitem = pritem
     C     lbkey7        setll     label7
     C     #nxt1b        tag
     C     lbkey7        reade     label7                                 79
     C                   if        *in79
     C                   eval      done = *on
     C                   goto      endnx1
     C                   endif
     *
     *    - Wrong label record.
     C                   if        lblbl# <> $llbl#
     C                   goto      #nxt1b
     C                   endif
     *
     C                   eval      topick = lbqpck
     C                   eval      rplqty = topick
     *
     *    Save this info to use it when a transaction is aborted.
     *
     C                   eval      usrrpl = *on
     C                   eval      svlbl# = lblbl#
     C                   eval      svqalc = lbqalc
     C                   eval      svqpck = lbqpck
     C                   eval      svcube = lbcube
     C                   eval      svswgt = lbswgt
     C                   eval      svqrmn = lbqrmn
     *
     C                   eval      curlbl# = lblbl#
     *
600aAC     endnx1        tag
600aAC                   eval      lt108flag = *off
600aMC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNEXT   Find next priority replenishment.
     *
     C     zznext        begsr
     *
     *    -Skip priority replenishment - Get next replenisment avail.
750 DC*                  if        bypass = *on
750 MC                   if        bypass = *on and $prplt<>'D'
650dAc  NKI              eval      prseq# = 0
     C     prky6e        setgt     prplfil6
     C                   endif
     *
     C                   eval      loop = *off
     C                   dow       forevr = forevr
     C     prky6b        reade     prplfil6                             7879
     C                   select
     C                   when      *in79
     *
     *     If end of file is reached and a replenishment was skipped,
     *     reset back to top of file looking for another or same trans.
     C                   select
     C                   when      loop = *off
     C     prky6b        setll     prplfil6
     C                   eval      loop = *on
     C                   iter
     C                   endsl
     *
     C                   eval      done = *on
     C                   leave
     *
     C                   when      *in78  or
     *
     C                             prflag <> 'S'  or
     *
     C                             $pfail > *blanks  and
510iDC*                            prfail < $pfail  or
510iMC                             prtail < $pfail  or
     *
     C                             $pfail > *blanks  and
     C                             prtail > $ptail
     *
     *     User selected to skip this replenishment.
500nDC**                           bypass = *on
     C                   iter
     *
     C                   other
500tA*
500tA*     See if replenishment is for correct side.
500tA*      Note: Only when aisle range is being used.
500tAC                   if        $pfail > *blanks
500tAC     prtloc        div       2             temp3n
500tAC                   mvr                     remainder
500tAC                   if        remainder = 0 and $pside = 'O'
500tAC                             or remainder > 0 and $pside = 'E'
500tAC                   iter
500tAC                   endif
500tAC                   endif
     *
     *    If just checking for new replenishments - set flag and exit.
     C                   if        chknew = *on
     C                   eval      newrpl = *on
     C                   unlock    prplfil6
501bAC                   eval      prseq# = prseq# - 1
     C                   goto      endnxt
     C                   endif

650gA*    If *REPLEN flag OPSKPR = Y and the phys qty > item repl level,
650gA*    and the item repl level is > 0, skip this replenishment.
650gA*
650gAC                   if        opskpr = 'Y'
650gAC                   exsr      zzGetPickslQ
650gAC     itkey1        chain     piritem
650gAC                   if        %found(piritem)
650gAC                             and itrepl > 0
650gAC                             and pckSltPhyQ > itrepl
650gAC                   iter
650gAC                   endif
650gAC                   endif
710bA*
710bA*     See if another replen for same item should be done first
710bA*
710bAC                   exsr      zzchkfifo
710bAC                   if        outOfFifoOrder
710bAC                   iter
710bAC                   endif
     *
     *    Tag replenishment record as in process.
     *
730 Mc                   if        prrplt = 'O' or prrplt='O'
700aAc                   exsr      zzchkLin
700aAc                   endif
      *
500 AC                   if        updrplrec
     C                   eval      prflag = 'A'
     C                   update    prrec
500 AC                   else
500 AC                   unlock    prplfil6
500jAC     prky6e        setll     prplfil6
500 AC                   endif
750aAc                   if        prrplt='D' or prtdis='*DDSLOT'
750aAc*  When validate only the system will not create a Virtual Drop Pick Slot.  Will only
750aAc*  ensure this is a drop pick slot and it has an available Drop Pick Slot
750aAc                   eval      validateOnly=*on
750aAc                   eval      ddwhse=prwhse
750aAc                   eval      ddwhdp=prwhdp
750aAc                   eval      dditem=pritem
750aAc                   eval      ddodisp=prfdis
750aAc                   eval      ddoaisle=prfail
750aAc                   eval      ddoloc=prfloc
750aAc                   eval      ddddisp=*blanks
750aAc                   eval      dddaisle=*blanks
750aAc                   eval      dddloc=0
750aAc                   eval      dddlvl=0
750aAc                   eval      dddhand=*blanks
750aAc                   eval      ddqty=prqty
750aAc                   eval      ddtype=prtype
750aAc                   eval      ddtrntype=*blanks
750aAc                   eval      pReturn=*blanks
750cAc                   if        prtdis <> '*DDSLOT'
750cAc                   eval      ddtrntype='RPL'
750cAc                   eval      ddddisp=prtdis
750cAc                   endif
750aAc                   exsr      chkfordrppck
750aAc                   if        pReturn = '*OK'
750aAc                   eval      done = *off
750aAc                   else
750aAC                   eval      done = *on
750aAC     prky6e        setll     prplfil6
750aAC     prky6e        reade     prplfil6
750aAc                   if        %equal(prplfil6)
750aAc                   eval      prflag='D'
750aAc                   update    prrec
750aAC     prky6e        setll     prplfil6
750aAc                   endif
750aAc                   endif
750aAc                   else
     c                   eval      done = *off
750aAc                   endif
     *
     C                   leave
     *
     C                   endsl
     C                   enddo
     C     endnxt        endsr

500fA*----------------------------------------------------------------
500fA*
500fA*  zzputovrf   Put leftover qty back into overflow slot.
500fA*              PIRVOICE/VORPLSS used as a template.
500fA*
500fAC     zzputovrf     begsr
500rAC                   eval      error = *off

     *  See if everything was putaway.

     C                   if        w6nqty <> w6balq
     C                   eval      allputaway = *off
     C                   else
     C                   eval      allputaway = *on
     C                   endif

     *  Get replenishment label record.

     C     curlbl#       chain(e)  label
     C                   if        %error
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = 'Label record not found '
     C                                    + '('
     C                                    + %trim(%editc(curlbl#:'P'))
     C                                    + ')'
     C                   goto      endputovrf
     C                   endif
500rA
500rA*  Update license history and slots.
500rA
500rA*    Two different methods are used depending on whether the
500rA*    quantity is going back into the original #FROM slot or not.
500rA
500rAC                   if        #ovrfslwhse = #fromslwhse  and
500rAC                             #ovrfslwhdp = #fromslwhdp  and
500rAC                             #ovrfbasesldsp = #frombasesldsp
500uDC**                           #pickittype <> 'B'
500rAC                   exsr      zzputovrf2
600rAC                   else
500rAC                   exsr      zzputovrf3
600rAC                   endif
500rAC                   if        error
500rAC                   unlock    label
500rAC                   goto      endputovrf
500rAC                   endif

500rA*  Update label records.
500rA
     C                   select

     *  When entire quantity put into slot ...

     C                   when      allputaway

     *    Update replenishment label record (locked at beg of routine).

     C                   exsr      zzgetdatetime
     C                   eval      lbasl2 = #ovrfslaisl
     C                   eval      lbloc2 = #ovrfslloc
     C                   eval      lblvl2 = #ovrfslrlvl
     C                   eval      lbhnd2 = #ovrfslhand
     C                   eval      lbdsp2 = #ovrfsldisp
500sAC                   eval      lbstat = 'C'
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   update(e) lbrec
     C                   if        %error
     C                   endif

     *    Zero verify slot, if necessary.

600aMC                   if        wupulvfy = 'Y'
     C                   exsr      zzzerovfy
     C                   endif

     *    Delete work record.

610lAC                   eval      kyitem = lbitem
600aMC     keywu2        chain     workusr2
     C                   if        %found
600aMC                   delete    wurec
500tAC                   eval      workcount = workcount - 1
     C                   endif

     *  When partial quantity put into slot ...

     C                   other

     *    Calculate quantity not put away.

     C                   eval      leftover = w6balq - w6nqty
     *
     C                   if        leftover <> *zeros
     C                   eval      w6balq = leftover
     C                   endif

417eA*    Get new putaway label number for the remainder.
417eA*      (Record created below)
417eA
417eAC                   call      'PIRLBL#'
417eAC                   parm                    lbctr#

     *    Update replenishment label record (locked at beg of routine).

     C                   eval      lbqpck = w6nqty
     C                   eval      lbcube = lbucub * lbqpck
     C                   eval      lbswgt = lbuwgt * lbqpck
     C                   eval      lbstat = 'C'
     C                   exsr      zzgetdatetime
     C                   eval      lbasl2 = #ovrfslaisl
     C                   eval      lbloc2 = #ovrfslloc
     C                   eval      lblvl2 = #ovrfslrlvl
     C                   eval      lbhnd2 = #ovrfslhand
     C                   eval      lbdsp2 = #ovrfsldisp
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   update(e) lbrec
     C                   if        %error
     C                   endif

     *    Create new putaway label record for the remainder.
417eA*      (Label number retrieved above)

417eAC                   eval      svlbl# = lblbl#
417eAC                   eval      lblbl# = lbctr#
     C                   eval      lbctr# = svlbl#
     C                   eval      lbwhd2 = ' '
     C                   eval      lbasl2 = ' '
     C                   eval      lbloc2 = 0
     C                   eval      lblvl2 = 0
     C                   eval      lbhnd2 = ' '
     C                   eval      lbdsp2 = ' '
     C                   eval      lbqavl = 0
     C                   eval      lbqalc = leftover
     C                   eval      lbqpck = leftover
     C                   eval      lbcube = lbucub * lbqpck
     C                   eval      lbswgt = lbuwgt * lbqpck
     C                   eval      lbstat = 'P'
     C                   exsr      zzgetdatetime
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   eval      lbrdte = curdate
     C                   eval      lbtrn# = 0
     C                   write(e)  lbrec
     C                   if        %error
     C                   endif

     *    Zero verify slot, if necessary.

600aMC                   if        wupulvfy = 'Y'
     C                   exsr      zzzerovfy
     C                   endif

     *    Update work record to a status of '2'

610lAC                   eval      kyitem = lbitem
600aMC     keywu2        chain     workusr2
     C                   if        %found
600aMC                   eval      wustat = '2'
600aMC                   eval      wulbl# = lblbl#
600aMC                   eval      wuremqty1 = leftover
600aMC                   update    wurec
     C                   endif

     C                   endsl

     C     endputovrf    endsr
500rA
500rA*----------------------------------------------------------------
500rA*  ZZPUTOVRF2  Putting full/partial quantity into #from slot.
500rA*----------------------------------------------------------------
500rA
500rAC     zzputovrf2    begsr
500uA
500uA*  Note: We don't do a PUTAWYB because we are putting the qty back
500uA*        where it came from and are assuming that it is physically
500uA*        being put back where it came from (i.e. same pallet pos).
500uA*        Therefore, we do not want to ask the user any questions.
500uA
500uDC**
500uDC** Put balance into transit, if any.
500uDC**
500uDC**                 if        not allputaway
500uDC**                 exsr      zzzclr$lt210
500uDC**                 eval      $tcmd  = '*PULTRAN'
500uDC**                 eval      $tlic# = curlic#
500uDC**                 eval      $tnewlic# = curlic#
500uDC**                 eval      $twhse  = #fromslwhse
500uDC**                 eval      $titem  = #fromslitem
500uDC**                 eval      $titemdsc = #fromithead
500uDC**                 eval      $tpartial = *on
500uDC**                 eval      $tqty1 = w6balq - w6nqty
500uDC**                 eval      $tqty2 = 0
500uDC**                 eval      $tqty3 = 0
500uDC**                 eval      $tnorm1 = $tqty1
500uDC**                 eval      $tnorm2 = 0
500uDC**                 eval      $tnorm2 = 0
500uDC**                 exsr      zzzcall$lt210
500uDC**
500uDC**                 select
500uDC**                 when      $treturn = '*CANCEL'
500uDC**                 goto      endputovrf2
500uDC**                 when      $treturn <> '*OK'
500uDC**                 eval      error = *on
500uDC**                 eval      *in21 = *on
500uDC**                 eval      *in01 = *on
500uDC**                 goto      endputovrf2
500uDC**                 endsl
500uDC**
500uDC**                 eval      curlic# = $tlic#
500uDC**
500uDC**                 endif

     *  Tell user to put back #FROM slot pallets.

500pDC**                 exsr      zzzclr$lt210
500pDC**                 eval      $tcmd  = '*PULRTN'
500pDC**                 eval      $twhse  = #fromslwhse
500pDC**                 eval      $twhdp  = #fromslwhdp
500pDC**                 eval      $tslot  = #fromsldisp
500pDC**                 eval      $titem  = #fromslitem
500pDC**                 eval      $titemdsc = #fromithead
500pDC**                 exsr      zzzcall$lt210
500pDC**                 if        $treturn <> '*OK'
500pDC**                 endif

     *  Use DRI interface to update #FROM slot.

     *  We just send a negative qty back because all we want to do
     *  is remove the qty from the Tfr bucket.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #fromslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
610aDC**                 eval      $sldisp   = #fromsldisp
610aMC                   eval      $sldisp   = #frombasesldsp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
600aAC                   eval      $sacwhdu  = *on
610aDC**                 eval      $sacwhd   = #pickslwhdp
610aMC                   eval      $sacwhd   = wuUsrWhdp
600aAC                   eval      $sacdspu  = *on
610aDC**                 eval      $sacdsp   = #picksldisp
610aMC                   eval      $sacdsp   = wuUsrDisp
     C                   eval      $sacitemu = *on
610aDC**                 eval      $sacitem  = #pickslitem
610aMC                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu   = *on
600aDC**                 eval      $saqty1   = -(w6nqty)
600aMC                   eval      $saqty1   = w6nqty
     C                   eval      $saqty2   = 0
     C                   eval      $saqty2   = 0
650iAc*  if production breakdown replen of case item then move
650iAc*  quantity 2 instead of quantity 1
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAC                   eval      $saqty1   = 0
650iAC                   eval      $saqty2   = w6nqty
650iAc                   endif
     C                   eval      $saorgu   = *off
     C                   eval      $saorg1   = 0
     C                   eval      $saorg2   = 0
     C                   eval      $saorg2   = 0
600aA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'RPL'
600aAC                   eval      $saTrn#U = *on
600aAC                   eval      $saTrn# = lbtrn#
600aAC                   eval      $saETrn#U = *on
600aAC                   eval      $saETrn# = 0
600aAC                   eval      $saLbl#U = *on
600aAC                   eval      $saLbl# = lblbl#
600aAC                   eval      $saToLcnsU = *on
600aDC**                 eval      $saToLcns = wuUsrLcns
600aMC                   eval      $saToLcns = wuPulLcns
600aAC                   eval      $saToPosU = *on
600aDC**                 eval      $saToPos = $tslotpos
600aMC                   eval      $saToPos = wuPulpos
600aAC                   eval      $saToVrfyU = *on
600aAC                   eval      $saToVrfy = 'N'
600aAC                   eval      $saToCodeu = *on
600aAC                   eval      $saToCode = 'S'
600aAC                   eval      $saToAreaU = *on
600aAC                   eval      $saToArea = 'Slot'
600aAC                   eval      $saFrmLcnsU = *on
600aAC                   eval      $saFrmLcns = wuUsrLcns
600aAC                   eval      $saOLcnsU = *on
600aAC                   eval      $saOLcns = wuPulOLcns
600aAC                   eval      $sapullwhdpu = *on
600aAC                   eval      $sapullwhdp  = wuPulWhdp
600aAC                   eval      $sapulldispu = *on
600aAC                   eval      $sapulldisp  = wuPulDisp
600aAC                   eval      $sapullbaseu = *on
600aAC                   eval      $sapullbase  = wuPulBase
600aAC                   eval      $sapulllcnsu = *on
600aAC                   eval      $sapulllcns  = wuPulLcns

600aAC                   eval      $saexcdU = *on
600aAC                   eval      $saexcd  = 'RTNORIG'
610fAC                   eval      $satasku = *on
610fAC                   eval      $satask = pttask

     C                   eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd  = '%PROUTCHG'
600aMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500vA
500vA*  Update #OVRF info for writting to Label file later.
500vA
500vAC                   eval      #ovrfslhand = $slhand
500vAC                   eval      #ovrfsldisp = $sldisp
500uA
500uA*  Call license tracking for putaway - After update.
500uA
500uA*  Note: Since we didn't call PUTAWYB, we need to fill in a few
500uA*        extra parameters.
500uA
500uAC                   eval      $tcmd  = '*PUTAWYA'
500uAC                   eval      $tnexttask= 'PUTAWAY'
500uAC                   eval      $tlic#  = curlic#
500uAC                   eval      $tinlic#  = curlic#
500uAC                   eval      $toutlic# = curlic#
600aDC**                 if        not allputaway
600aDC**                 eval      $tpartial = *on
600aDC**                 else
500uAC                   eval      $tpartial = *off
600aDC**                 endif
500uAC                   eval      $twhse  = #fromslwhse
500uAC                   eval      $twhdp  = #fromslwhdp
500uAC                   eval      $tslot  = #fromsldisp
500uAC                   eval      $titem  = #fromslitem
500uAC                   eval      $titemdsc = #fromithead
500uAC                   eval      $tqty1 = w6nqty
500uAC                   eval      $tqty2 = 0
500uAC                   eval      $tqty3 = 0
500uAC                   eval      $tnorm1 = w6nqty
500uAC                   eval      $tnorm2 = 0
500uAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
500uAC                   eval      $tqty1 = 0
500uAC                   eval      $tqty2 = w6nqty
500uAC                   eval      $tqty3 = 0
500uAC                   eval      $tnorm1 = 0
500uAC                   eval      $tnorm2 = w6nqty
500uAC                   eval      $tnorm3 = 0
650iAc                   endif
500uAC                   exsr      zzzcall$lt210
500uA
500uAC                   if        $treturn <> '*OK'
500uAC                   endif
500wA
500wA*    If everything putaway, see if a zero rec needs to be removed.
500wA
500wAC                   if        allputaway
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*RMVZERO'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
500wAC                   eval      $tslot  = #fromsldisp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic# = curlic#
500wAC                   exsr      zzzcall$lt210
500wAC                   if        $treturn <> '*OK'
500wAC                   endif
500wAC                   endif

     C     endputovrf2   endsr
500rA
500rA*----------------------------------------------------------------
500rA*  ZZPUTOVRF3  Putting full/partial quantity into non-#from slot.
500rA*----------------------------------------------------------------
500rA
500rAC     zzputovrf3    begsr

     *  Initialize interface data structure.

     C                   exsr      clr$slot

     *  Call license tracking for putaway - Before update

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PUTAWYB'
     C                   eval      $tlic#  = curlic#
     C                   if        allputaway
     C                   eval      $tpartial = *off
     C                   else
     C                   eval      $tpartial = *on
     C                   endif
     C                   eval      $twhse  = #ovrfslwhse
     C                   eval      $twhdp  = #ovrfslwhdp
610aDC**                 eval      $tslot  = #ovrfsldisp
610aMC                   eval      $tslot  = #ovrfbasesldsp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tqty1 = w6nqty
     C                   eval      $tqty2 = 0
     C                   eval      $tqty3 = 0
500vAC                   eval      $tnorm1 = w6nqty
500vAC                   eval      $tnorm2 = 0
500vAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAc                   eval      $tqty1 = 0
650iAC                   eval      $tqty2 = w6nqty
650iAC                   eval      $tqty3 = 0
650iAC                   eval      $tnorm1 = 0
650iAC                   eval      $tnorm2 = w6nqty
650iAC                   eval      $tnorm3 = 0
650iAc                   endif
     C                   exsr      zzzcall$lt210

     C                   select
     C                   when      $treturn = '*CANCEL'
     C                   eval      redspl = *on
     C                   goto      endputovrf3
     C                   when      $treturn <> '*OK'
     C                   eval      error = *on
600aAC                   eval      errmsg = 'LT210: ' + $terrmsg
600aAC                   exsr      zm0105
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endputovrf3
     C                   endsl

     *  Use DRI interface to update To slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #ovrfslwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #ovrfslwhdp
     C                   eval      $sldispu  = *on
610aDC**                 eval      $sldisp   = #ovrfsldisp
610aMC                   eval      $sldisp   = #ovrfbasesldsp
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
600aAC                   eval      $sacwhdu = *on
600aAC                   eval      $sacwhd  = wuUsrWhdp
600aAC                   eval      $sacdspu = *on
600aAC                   eval      $sacdsp  = wuUsrDisp
600aAC                   eval      $sacitemu = *on
600aAC                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w6nqty
     C                   eval      $saqty2   = 0
     C                   eval      $saqty3   = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAC                   eval      $saqty1   = 0
650iAC                   eval      $saqty2   = w6nqty
650iAC                   eval      $saqty3   = 0
650iAc                   endif
600aMC                   eval      $saToPosu = *on
600aMC                   eval      $saToPos  = $tslotpos
600aA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'RPL'
600aAC                   eval      $saTrn#U = *on
600aAC                   eval      $saTrn# = lbtrn#
600aAC                   eval      $saETrn#U = *on
600aAC                   eval      $saETrn# = 0
600aAC                   eval      $saLbl#U = *on
600aAC                   eval      $saLbl# = lblbl#
600aAC                   eval      $saToLcnsU = *on
600aAC                   eval      $saToLcns = $tinlic#
600aAC                   eval      $saToPosU = *on
600aAC                   eval      $saToPos = $tslotpos
600aAC                   eval      $saToVrfyU = *on
600aAC                   eval      $saToVrfy = 'N'
600aAC                   eval      $saToCodeu = *on
600aAC                   eval      $saToCode = 'S'
600aAC                   eval      $saToAreaU = *on
600aAC                   eval      $saToArea = 'Slot'
600aAC                   eval      $saFrmLcnsU = *on
600aAC                   eval      $saFrmLcns = $toutlic#
600aAC                   eval      $saOLcnsU = *on
600aAC                   eval      $saOLcns = wuPulOLcns
600aAC                   eval      $sapullwhdpu = *on
600aAC                   eval      $sapullwhdp  = wuPulWhdp
600aAC                   eval      $sapulldispu = *on
600aAC                   eval      $sapulldisp  = wuPulDisp
600aAC                   eval      $sapullbaseu = *on
600aAC                   eval      $sapullbase  = wuPulBase
600aAC                   eval      $sapulllcnsu = *on
600aAC                   eval      $sapulllcns  = wuPulLcns
610fAC                   eval      $satasku = *on
610fAC                   eval      $satask = pttask

     C                   eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd  = '%CLSPRIN'
600aMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endputovrf3
     C                   endif

     *  Update #TO slot info in case item was put into a virtual slot.

     C                   eval      #ovrfslhand = $slhand
     C                   eval      #ovrfsldisp = $sldisp

600aD ** Use DRI interface to update From slot.
600aD **
600aDC**                 exsr      clr$slot
600aDC**                 eval      $slwhseu  = *on
600aDC**                 eval      $slwhse   = #fromslwhse
600aDC**                 eval      $slwhdpu  = *on
600aDC**                 eval      $slwhdp   = #fromslwhdp
600aDC**                 eval      $sldispu  = *on
600aDC**                 eval      $sldisp   = #fromsldisp
600aDC**                 eval      $saitemu  = *on
600aDC**                 eval      $saitem   = #fromslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem  = #pickslitem
600aDC**                 eval      $saqtyu   = *on
600aDC**                 eval      $saqty1   = w6nqty
600aDC**                 eval      $saqty2   = 0
600aDC**                 eval      $saqty2   = 0
600aDC**                 eval      $saorgu   = *on
600aDC**                 eval      $saorg1   = w6nqty
600aDC**                 eval      $saorg2   = 0
600aDC**                 eval      $saorg2   = 0
600aD **
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd  = '%CLSPROCHG'
600aD **
600aDC**                 eval      $drisys2upd = 'D'
600aDC**                 eval      chk4err = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop

     *  Call license tracking for putaway - After update.
     *  Note, some parms remembered from Before processing.

     C                   eval      $tcmd  = '*PUTAWYA'
     C                   eval      $tlic#  = curlic#
     C                   if        allputaway
     C                   eval      $tpartial = *off
     C                   else
     C                   eval      $tpartial = *on
     C                   endif
     C                   eval      $twhse  = #ovrfslwhse
     C                   eval      $twhdp  = #ovrfslwhdp
     C                   eval      $tslot  = #ovrfsldisp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tqty1 = w6nqty
     C                   eval      $tqty2 = 0
     C                   eval      $tqty3 = 0
500vAC                   eval      $tnorm1 = w6nqty
500vAC                   eval      $tnorm2 = 0
500vAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAC                   eval      $tqty1 = 0
650iAC                   eval      $tqty2 = w6nqty
650iAC                   eval      $tqty3 = 0
650iAC                   eval      $tnorm1 = 0
650iAC                   eval      $tnorm2 = w6nqty
650iAC                   eval      $tnorm3 = 0
650iAc                   endif
     C                   exsr      zzzcall$lt210

     C                   if        $treturn <> '*OK'
     C                   endif
500wA
500wA*    If everything putaway, see if a zero rec needs to be removed.
500wA
500wAC                   if        allputaway
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*RMVZERO'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
500wAC                   eval      $tslot  = #fromsldisp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = curlic#
500wAC                   exsr      zzzcall$lt210
500wAC                   if        $treturn <> '*OK'
500wAC                   endif
500wAC                   endif

     C     endputovrf3   endsr

500fA*----------------------------------------------------------------
500fA*
500fA*  zzputpick   Put quantity into pick slot.
500fA*              PIRVOICE/VORPLSS used as a template.
500fA*
500fAC     zzputpick     begsr

     *  See if everything was putaway.

500qDC**                 if        #pickittype <> 'B' and w5pulq <> w5nqty
500qDC**                           or
500qDC*                            #pickittype = 'B' and w5repq <> w5nqty
500qA
500qMC                   if        w5pulq <> w5nqty
     C                   eval      allputaway = *off
     C                   else
     C                   eval      allputaway = *on
     C                   endif
500rA*
500rA*    Call license tracking for putaway - First show it in transit.
500rA*    This is done for two reasons. First, to ask any necessary license
500rA*    questions. Second, for REPLBK this will create the necessary
500rA*    split record to be updated with the new item number and qty.
500rA*
500uDC**                 eval      trnlic# = curlic#
500uDC**                 if        rpltyp <> '*BRKDWN'
500uDC**                           or not allputaway
500uDC**                 exsr      zzzclr$lt210
500uDC**                 eval      $tcmd  = '*PULTRAN'
500uDC**                 eval      $tlic# = curlic#
500uDC**                 eval      $tnewlic# = curlic#
500uDC**                 eval      $twhse  = #fromslwhse
500uDC**                 eval      $titem  = #fromslitem
500uDC**                 eval      $titemdsc = #fromithead
500uDC**                 if        allputaway
500uDC**                 eval      $tpartial = *off
500uDC**                 else
500uDC**                 eval      $tpartial = *on
500uDC**                 endif
500uDC**                 eval      $tqty1 = w5nqty
500uDC**                 exsr      zzzcall$lt210
500rA*
500uDC**                 select
500uDC**                 when      $treturn = '*CANCEL'
500uDC**                 goto      endputpick
500uDC**                 when      $treturn <> '*OK'
500uDC**                 eval      error = *on
500uDC**                 eval      *in21 = *on
500uDC**                 eval      *in01 = *on
500uDC**                 goto      endputpick
500uDC**                 endsl
500rA*
500uDC**                 eval      trnlic# = $tlic#
500uDC**                 endif

     *  Call license tracking for putaway - Now do the Before update

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PUTAWYB'
500uAC                   eval      $tlic#  = curlic#
500uDC**                 eval      $tlic#  = trnlic#
610eDC**                 if        not allputaway and rpltyp = '*BRKDWN'
610eMC                   if        not allputaway
500tMC                   eval      $tpartial = *on
500tMC                   else
500tMC                   eval      $tpartial = *off
500tMC                   endif
     C                   eval      $twhse  = #pickslwhse
     C                   eval      $twhdp  = #pickslwhdp
     C                   eval      $tslot  = #picksldisp
     C                   eval      $titem  = #pickslitem
     C                   eval      $titemdsc = #pickithead
500rAC                   if        pttask = 'REPLBK'
500rAC                   eval      $tqty1 = w5nqty * #fromitumq2
500rAC                   else
500rAC                   eval      $tqty1 = w5nqty
500rAC                   endif
500rAC                   eval      $tqty2 = 0
500rAC                   eval      $tqty3 = 0
500vAC                   eval      $tnorm1 = w5nqty
500vAC                   eval      $tnorm2 = 0
500vAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAc                   eval      $tqty1 = 0
650iAc                   eval      $tqty2 = w5nqty
650iAc                   eval      $tqty3 = 0
650iAC                   eval      $tnorm1 = 0
650iAC                   eval      $tnorm2 = w5nqty
650iAC                   eval      $tnorm3 = 0
650iAc                   endif
     C                   exsr      zzzcall$lt210
     *
     C                   if        $treturn <> '*OK'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endputpick
     C                   endif

     *  Get replenishment label record.

     C     curlbl#       chain(e)  label
     C                   if        %error
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = 'Label record not found '
     C                                    + '('
     C                                    + %trim(%editc(curlbl#:'P'))
     C                                    + ')'
     C                   goto      endputpick
     C                   endif

     *  Update slots ...

600aD **   Update From slot
600aD **
600aDC**                 exsr      clr$slot
600aD **
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse  = #fromslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp  = #fromslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp  = #fromsldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem  = #fromslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem  = #pickslitem
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1  = w5nqty
600aDC**                 eval      $saorgu = *on
600aDC**                 eval      $saorg1  = w5nqty
600aDC**                 eval      $saslposu = *on
600aDC**                 eval      $saslpos  = $tslotpos
600aD **
600aDC**                 eval      $dricommand = '*SLOT'
500rDC**                 eval      $drisubcmd  = '%CLSPROUT'
600aDC**                 eval      $drisubcmd  = '%CLSPROCHG'
600aDC**                 eval      $drisys2upd = 'D'
600aDC**                 eval      chk4err = *on
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop
600aDC**                 if        drierr
600aDC**                 goto      endputpick
600aDC**                 endif

     *    Update Pick (To) slot.

     C                   exsr      clr$slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #pickslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #pickslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #picksldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #pickslitem
600aAC                   eval      $sacwhdu = *on
610aDC**                 eval      $sacwhd  = #fromslwhdp
610aMC                   eval      $sacwhd  = wuUsrWhdp
600aAC                   eval      $sacdspu = *on
610aDC**                 eval      $sacdsp  = #fromsldisp
610aMC                   eval      $sacdsp  = wuUsrDisp
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu = *on
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iMC                   eval      $saqty1  = 0
650iMC                   eval      $saqty2  = w5nqty
650iAc                   else
500 MC                   eval      $saqty2  = 0
500 MC                   eval      $saqty1  = w5nqty
650iAc                   endif
600aDC**                 eval      $saorgu = *on
600aMC                   eval      $saorgu = *off
600aDC**                 eval      $saorg1  = w2nqty
600aMC                   eval      $saorg1  = 0
417hAC                   eval      $slentdu = *on
417hAC                   eval      $slentd  = #fromslentd
417hAC                   eval      $slexpdu = *on
417hAC                   eval      $slexpd  = #fromslexpd
600aMC                   eval      $saToPosu = *on
600aMC                   eval      $saToPos  = $tslotpos
600aMC                   eval      $saPrdWgtu = *off
650fAc                   eval      $saPrdWgt = 0
600aMC                   eval      $saser#u = *off
650fAc                   eval      $saSer# = *blanks
600aMC                   eval      $sags1u = *off
650fAc                   eval      $saGs1 = *blanks
600aMC                   eval      $saMfgLneu = *on
650fAc                   eval      $saMfgLne = #pickslrlvl
600aA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'RPL'
600aAC                   eval      $saTrn#U = *on
600aAc                   eval      $saTrn# = lbtrn#
600aAC                   eval      $saETrn#U = *on
600aAC                   eval      $saETrn# = 0
600aAC                   eval      $saLbl#U = *on
600aAC                   eval      $saLbl# = lblbl#
600aAC                   eval      $saToLcnsU = *on
600aAC                   eval      $saToLcns = $tinlic#
730 Ac                   if        dropPick
730 Ac*   *DP is already used for Directed Putaway.  *PD is Drop Pick
730 Ac*    reversed since *DP already used
730 Ac                   eval      $saToLcns = '*PD'
730 Ac                   endif
600aAC                   eval      $saToPosU = *on
600aAC                   eval      $saToPos = $tslotpos
600aAC                   eval      $saToVrfyU = *on
600aAC                   eval      $saToVrfy = 'N'
600aAC                   eval      $saToCodeu = *on
600aAC                   eval      $saToCode = 'S'
600aAC                   eval      $saToAreaU = *on
600aAC                   eval      $saToArea = 'Slot'
600aAC                   eval      $saFrmLcnsU = *on
600aAC                   eval      $saFrmLcns = $toutlic#
600aAC                   eval      $saOLcnsU = *on
600aAC                   eval      $saOLcns = wuPulOLcns
600aAC                   eval      $sapullwhdpu = *on
600aAC                   eval      $sapullwhdp  = wuPulWhdp
600aAC                   eval      $sapulldispu = *on
600aAC                   eval      $sapulldisp  = wuPulDisp
600aAC                   eval      $sapullbaseu = *on
600aAC                   eval      $sapullbase  = wuPulBase
600aAC                   eval      $sapulllcnsu = *on
600aAC                   eval      $sapulllcns  = wuPulLcns
610fAC                   eval      $satasku = *on
610fAC                   eval      $satask = pttask

     C                   eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd  = '%CLSPRICHG'
720 Ac                   if        rpltyp = '*STRREPL'
600aAC                   eval      $saToArea = 'DOCK'
720 MC                   eval      $drisubcmd  = '%USR2RPA'
720 A /free
720 M                              $sapulldisp = #picksldisp;   // Pick has RPADOC-xx
720 M                              $sldisp = wuUsrDisp;         // wuusr has User Slot
720 A /end-free
720 Ac                   else
600aMC                   eval      $drisubcmd  = '%USR2PUT'
720 Ac                   endif
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
500kMC                   if        drierr
     C                   goto      endputpick
     C                   endif
650hA
650hA*    Write Production Log entries with data returned DRILICENSE  lot.
650hA
650hAc                   eval      gs1c = 1
650hAc                   dow       gs1c < 501
650hAc                   if        gs1(gs1c) <> *blanks
650hAc                   exsr      WrtProdLog
650hAc*                  else
650hAc*                  leave
650hAc                   endif
650hAc                   eval      gs1c = gs1c + 1
650hAc                   enddo
650hAc                   eval      gs1c = 1

     *    Update #pick slot info in case item was put into a virtual slot.

     C                   eval      #pickslhand = $slhand
     C                   eval      #picksldisp = $sldisp
520cA
520ca*    Create adjustment records for breakdown replenishments.
520cA
520cAC                   if        pttask = 'REPLBK'
520cAC                   exsr      zzcrta
520cAC                   endif

     *  Update license tracking
     *  Note, some parms remembered from Before processing.

     C                   eval      $tcmd  = '*PUTAWYA'
500uAC                   eval      $tlic#  = curlic#
500uDC**                 eval      $tlic#  = trnlic#
730 DC*                  if        allputaway
730 MC                   if        allputaway and not dropPick
     C                   eval      $tpartial = *off
     C                   else
     C                   eval      $tpartial = *on
     C                   endif
     C                   eval      $twhdp  = #pickslwhdp
     C                   eval      $tslot  = #picksldisp
     C                   eval      $titem  = #pickslitem
     C                   eval      $titemdsc = #pickithead
500rAC                   if        pttask = 'REPLBK'
500rAC                   eval      $tqty1 = w5nqty * #fromitumq2
500rAC                   else
     C                   eval      $tqty1 = w5nqty
500rAC                   endif
     C                   eval      $tqty2 = 0
     C                   eval      $tqty3 = 0
500vAC                   eval      $tnorm1 = w5nqty
500vAC                   eval      $tnorm2 = 0
500vAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAc                   eval      $tqty1 = 0
650iAc                   eval      $tqty2 = w5nqty
650iAc                   eval      $tqty3 = 0
650iAC                   eval      $tnorm1 = 0
650iAC                   eval      $tnorm2 = w5nqty
650iAC                   eval      $tnorm3 = 0
650iAc                   endif
     C                   exsr      zzzcall$lt210
     *

     C                   if        $treturn <> '*OK'
     C                   endif

     C                   select

     *  When entire quantity put into slot ...

     C                   when      allputaway
500wA
500wA*    See if a zero rec needs to be removed.
500wA
500wAC                   exsr      zzzclr$lt210
500wAC                   eval      $tcmd  = '*RMVZERO'
500wAC                   eval      $twhse  = #fromslwhse
500wAC                   eval      $twhdp  = #fromslwhdp
500wAC                   eval      $tslot  = #fromsldisp
500wAC                   eval      $titem  = #fromslitem
500wAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic# = curlic#
500wAC                   exsr      zzzcall$lt210
500wAC                   if        $treturn <> '*OK'
500wAC                   endif

     *    Update replenishment label record (locked at beg of routine).

     C                   eval      lbstat = 'C'
     C                   exsr      zzgetdatetime
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   update(e) lbrec
     C                   if        %error
     C                   endif

     *    Zero verify slot, if necessary.

600aMC                   if        wupulvfy = 'Y'
     C                   exsr      zzzerovfy
     C                   endif

     *    Delete work record.

500fDC**                 exsr      zzdlp1
610lAC                   eval      kyitem = lbitem
600aMC     keywu2        chain     workusr2
     C                   if        %found
600aMC                   delete    wurec
500tAC                   eval      workcount = workcount - 1
     C                   endif

     *  When partial quantity put into slot ...

     C                   other

     *    Calculate quantity not put away.

500tDC**                 if        #pickittype = 'B'
500tDC**                 eval      leftover = (w5repq-w5nqty)/#fromitumq2
500tDC**                 else
     C                   eval      leftover = w5pulq - w5nqty
500tDC**                 endif
     *
500tDC**                 if        leftover <> *zeros
     C                   eval      w5balq = leftover
500tDC**                 endif

417eA*    Get new putaway label number for the remainder.
417eA*      (Record created below)
417eA
417eAC                   call      'PIRLBL#'
417eAC                   parm                    lbctr#

     *    Update replenishment label record (locked at beg of routine).

     C                   eval      lbqpck = w5nqty
     C                   eval      lbcube = lbucub * lbqpck
     C                   eval      lbswgt = lbuwgt * lbqpck
500 AC                   if        #pickittype = 'B'
500 AC                   eval      lbqrmn = lbqpck * #fromitumq2
500 AC                   endif
     C                   eval      lbstat = 'C'
     C                   exsr      zzgetdatetime
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   update(e) lbrec
     C                   if        %error
     C                   endif

     *    Create new putaway label record for the remainder.
417eA*      (Label number retrieved above)

417eAC                   eval      svlbl# = lblbl#
417eAC                   eval      lblbl# = lbctr#
     C                   eval      lbctr# = svlbl#
     C                   eval      lbwhd2 = ' '
     C                   eval      lbasl2 = ' '
     C                   eval      lbloc2 = 0
     C                   eval      lblvl2 = 0
     C                   eval      lbhnd2 = ' '
     C                   eval      lbdsp2 = ' '
     C                   eval      lbqavl = 0
     C                   eval      lbqalc = leftover
     C                   eval      lbqpck = leftover
     C                   eval      lbcube = lbucub * lbqpck
     C                   eval      lbswgt = lbuwgt * lbqpck
     C                   eval      lbstat = 'P'
     C                   exsr      zzgetdatetime
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   eval      lbrdte = curdate
     C                   eval      lbtrn# = 0
     C                   write(e)  lbrec
     C                   if        %error
     C                   endif
500sA
500sAC                   eval      curlbl# = lblbl#

     *    Zero verify slot, if necessary.

600aMC                   if        wupulvfy = 'Y'
     C                   exsr      zzzerovfy
     C                   endif

     *    Update work record to a status of '2'

610lAC                   eval      kyitem = lbitem
600aMC     keywu2        chain     workusr2
     C                   if        %found
600aMC                   eval      wustat = '2'
600aMC                   eval      wulbl# = lblbl#
600aMC                   eval      wuremqty1 = leftover
600aMC                   update    wurec
600aMC                   endif

     C                   endsl

     C     endputpick    endsr

500pA*----------------------------------------------------------------
500pA*  zzreturnplt  Return pallets to slot.
500pA*----------------------------------------------------------------
500pA
500pAC     zzreturnplt   begsr

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PULRTN'
     C                   eval      $twhse  = #fromslwhse
     C                   eval      $twhdp  = #fromslwhdp
     C                   eval      $tslot  = lastslot
600aAC                   eval      $tlic#  = #fromsaToLcns
     C                   exsr      zzzcall$lt210
     C                   if        $treturn <> '*OK'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZRMTF   Remove transfer label/transaction records.
     *
     C     zzrmtf        begsr
     *
     C                   eval      crtrcd = *off
     C                   eval      @pcmd = '*ABORT  '
     *
     C     svrplb        chain     label                              79
     C                   if        not *in79
     C     lbtrn#        chain(n)  pirtran                            78
     C                   if        *in79
     C                   eval      pttask = *blanks
     C                   eval      pttrn# = *zeros
     C                   endif
     *
     C                   call      @adjtr
     C                   parm                    @pcmd
     C                   parm                    #job
     C                   parm      lbtrn#        @ptrn#
     C                   parm      pttask        @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      lbwhdp        @pwhdp
     C                   parm      lbstyp        @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
     C                   parm      'L'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *    Delete label record.
     *
     C                   delete    lbrec
     *
     *    Remove link in coresponding tran# of original rcd.
     C     svlbl#        chain     label                              79
     C                   if        not *in79
     C                   eval      lbctr# = *zeros
     C                   update    lbrec                                78
     C                   endif
     *
     C                   endif
     *
     C                   endsr
500vA
500vA*----------------------------------------------------------------
500vA*  ZZRTNHOMCHK  Return home check.
500vA*----------------------------------------------------------------
500vA
500vAC     zzrtnhomchk   begsr

     *    Check if product is allocated or picked. If yes, then flag
     *    any overflow to come back to this slot.
     *    Or more than one replenishment exists from this slot.

     C                   eval      rpldif = #fromsltfr1 - svqpck

     C                   if        #fromslpck1 <> 0  or
     C                             #fromslpck2 <> 0  or
     C                             #fromslpck3 <> 0  or
     *
     C                             #fromslalc1 <> 0  or
     C                             #fromslalc2 <> 0  or
     C                             #fromslalc3 <> 0  or
     *
     C                             #fromslrcv1 <> 0  or
     C                             #fromslrcv2 <> 0  or
     C                             #fromslrcv3 <> 0  or
     *
     C                             rpldif <> 0
     C                   eval      rtnhom = *on
     C                   endif

     C                   endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZSPFC   Call to display specific slot replenishments.  Override
650bA*           pick slot for parent replenishment
650dA*           This routine is also called when the user scans a
650dA*           license instead of a slot.  In that scenario IT276
650dA*           is not called but the transaction and label(s) must
650dA*           be updated
650bA*
650bAC     zzspfc        begsr
650bAC                   eval      error = *off
650bAC                   eval      done = *off
650bA*
650bA*    Display list of slots item occupies.
650bA*
650bAC                   eval      $iWhse = #pickslwhse
650bAC                   eval      $iItem = #pickslitem
650bAC                   eval      $iWhdp = #pickslwhdp
650bAC                   eval      $iHome = #picksldisp
650bMC*                  eval      $iPrg = #prog
650bAc                   eval      $pPrg = 'LT107R'
650bAc                   eval      savSlavl3 = $slavl3
650bAc                   eval      $slavl3 = topick
650bA*
650dAc                   if        w1lcns = ' '
650bAC                   call      'IT276'
650bAC                   parm                    $pPrg            10
650bAC                   parm                    $iWhse            3 0
650bAC                   parm                    $iWhdp            5
650bAC                   parm                    $iHome           12
650bAC                   parm                    $iItem           15
650bAC                   parm                    $slot
650bAC                   parm                    $slot2
650bAC                   parm                    $iReturn          8
650dAc                   else
650dA*    get the new from slot from the scanned license
650dAC                   eval      getwhse = #pickslwhse
650dAC                   eval      getwhdp = #pickslwhdp
650dAc                   eval      getdisp = $liToDisp
650dAc                   exsr      zzGetFromSl
650dAc                   endif
650bA
650bAc                   eval      $slavl3 = savSlavl3
650bA*
650bA*    User has selected different slot to replnishment with for Repack
650bA*
650bA*    Get transaction record created in it276
650bA
650bAC                   if        $iReturn = '*OK     '
650dAc                             or w1lcns <> ' '
650bAc                   eval      it276flag = *on
650bAc                   eval      *in42 = *on
650bAC                   eval      wkrtpo = *blanks
650bAC                   eval      kytrn# = svTrn#
650bAC     ptky3a        setll     pirtran3
650bAC     #spfc1        tag
650bAC     ptkey3        reade     pirtran3                               77
650bA*    - EOF
650bAC                   if        *in77
650bAC                   eval      done = *on
650bAC                   goto      #spfc2
650bAC                   endif
650bA*
650bA*    - Wrong transaction number.
650bAC                   if        pttrn# <> svTrn#
650bAC                   goto      #spfc1
650bAC                   endif
650bA*
650bA*    - Transaction inuse.
650bAC                   if        ptstat <> '2'
650bAC                   goto      #spfc1
650bAC                   endif
650bA*
650bA*    - Different department.
650bA*
650bAC                   if        ptwhdp <> #pickslwhdp
650bAC                   goto      #spfc1
650bAC                   endif
650bA*
650bA*    Found Specific Slot replenishment rcd - Process it.
650bAC                   eval      svtrn# = pttrn#
650bA
650bA*    Get Label record.
650bA
650bAC     svlbl#        chain     label
650bAC                   if        %found
650bAc                   eval      lbdisp = $sldisp
650bAc                   eval      lbaisl = $slaisl
650bAc                   eval      lbloc = $slloc
650bAc                   eval      lbrlvl = $slrlvl
650bAc                   eval      lbhand = $slhand
650bAc                   eval      lbdisp = $sldisp
650bAc                   update    lbrec
650bMC                   endif
650bA
650bA*  Get From slot information.
650bA
650bAC                   eval      getwhse = ptwhse
650bAC                   eval      getwhdp = ptwhdp
650bAC                   eval      getdisp = $sldisp
650bAC                   exsr      zzgetfromsl
650bA
650bA*  Get From Item information.
650bA
650bAC                   exsr      zzgetfromit
650bA
650bA*  Get Pick slot information.
650bA
650bAC                   eval      getwhse = lbwhs2
650bAC                   eval      getwhdp = lbwhd2
650bAC                   eval      getdisp = lbdsp2
650bAC                   exsr      zzgetpicksl
650bA
650bA*  Get Pick Item information.
650bA
650bAC                   exsr      zzgetpickit
650bAc                   endif
650bA*
650bA*    Return user to specific slot screen.
650bA*
650bAc     #spfc2        tag
650dA*   If license was scanned then pass in slot information and
650dA*   move on the the next screen.  At this point all edits have
650dA*   been checked and everything is good
650dAc                   if        w1lcns <> ' '
650dAc                             and #fromsldesg <> 'BFC'
650dAc                   eval      LicenseEntered = *on
650dAc                   eval      w1lcns = ' '
650dAc                   eval      w1scan = $litoBase
650dAc                   eval      w1fmsl = $litoBase
650dAc                   exsr      zzupd1
650dAc                   else
650dAc                   if        #fromsldesg <> 'BFC'
650bAc                   eval      *in01 = *on
650bAC                   exsr      scr01i
650dAc                   endif
650dAc                   endif
650bA*
650bAC     endspf        tag
650bAC                   endsr
600i *----------------------------------------------------------------
600i *
600i *  ZZSPFD   Close rec after specific slot replenishment was done.
600i *
600i C     zzspfd        begsr
600i *
600i *    Remove priority replenishment record.
600i C                   if        rpltyp = '*PRIORTY'
600i C     keypr2        chain     prplfil1                           7978
600i C                   if        not *in79
600iAC                   eval      prflg1 = 'D'
600iMC                   update    prrec                                78
600i C                   endif
600i C                   endif
     *
600i C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   eval      kystat = '2'
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
     C                   if        *in79
     C                   eval      found = *off
     C                   goto      endtsk
     C                   endif
     *
     C     ptke22        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptemp# <> #emp#
     C                   eval      found = *off
     C                   leave
     C                   endif
     C                   if        ptstat <> '2'
     C                   iter
     C                   endif
     *    Found an active transaction
     C                   eval      curent = *on
     C                   eval      curtrn = pttrn#
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        not *in79
     C                   eval      curtsk = tkcode
     C                   eval      curtyp = tktype
     C                   endif
     C                   leave
     C                   enddo
     C     endtsk        endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNABORT  Abort/Undo a transaction.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnabort    begsr

     *    If this replenishment was created by this program then,
     *    remove transaction completely. Otherwise just reset
     *    transaction

     C                   if        usrrpl = *on
     C                   eval      @pcmd = '*ABORT'
     C                   else
     C                   eval      @pcmd = '*UNDO'
     C                   endif

     C                   call      'ADJTRAN2'
     C                   parm                    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNCLOSE  Close a transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnclose    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNCRTSTART  Create and Start transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrncrtstart begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'TFRMOV'      @ptask            6
     C                   parm      lbwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'T'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNIDLE   Start and IDLE transaction.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnidle     begsr

710fA *   For Production defined employees in file PLABCSTLNE the
710fA *   system will always put them on their default task instead
710fA *   of IDLE.  The reason for this is to spread their cost at
710fA *   end of day instead of between operations going to indirect.
710fA *   This routine only gets called when a Close transaction is
710fA *   called from MRC instead of the CRTSTRT, and therefore no new
710fA *   task.
710fA *
710fA /free
710fA        exec sql select lctask into :@ptask
710fA                  from pLabCstLne
710fA                    where lcucde=:#User;
710fA        if sqlStt <> '00000';
710fA           @pTask = 'IDLE';
710fA        endif;
710fA /end-free
     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      #fromslwhse   @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNSTART  Start a transaction
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnstart    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*START'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'T'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnupdate   begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      wrkqty        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500dA*----------------------------------------------------------------
500dA*  ZZTRNZERO  Zero transaction pcs, cube and weight.
500dA*----------------------------------------------------------------
500dA
500dAC     zztrnzero     begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*DECTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      ptcube        @pcube            9 3
     C                   parm      ptswgt        @pswgt            9 2
     C                   parm      ptpcs         @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUNDO   Undo last replenishment. User says pallet is full.
     *
500yDC**   zzundo        begsr
     *
     *    Remove transfer quantity from slot record.(From slot)
     *
500yDC**   slfkey        chain     slot2                              79
500yDC**                 if        not *in79
500yDC**                 eval      sltfr1 = sltfr1 - svqpck
500yDC**                 update    slrec2
500yDC**                 endif
     *
     *    Remove receive quantity from slot record.(To slot)
     *
500yDC**   sltkey        chain     slot2                              79
500yDC**                 if        not *in79
500yDC**                 eval      slrcv1 = slrcv1 - svqpck
500yDC**                 update    slrec2
500yDC**                 endif
     *
     *    Close label record to zero.
     *
500yDC**   ptkey         chain     pirtran                            79
500yDC**   lbkey         chain     label                              74
     *
     *    Update PIRTRAN file
500yDC**                 if        not *in79
500yDC**                 eval      ptpcs = ptpcs - svqpck
500yDC**                 eval      ptswgt = ptswgt - lbswgt
500yDC**                 eval      ptcube = ptcube - lbcube
500yDC**                 update    ptrec
500yDC**                 endif
     *
     *    Update LABEL file
500yDC**                 if        not *in74
500yDC**                 eval      lbqpck = *zeros
500yDC**                 eval      lbswgt = *zeros
500yDC**                 eval      lbcube = *zeros
500yDC**                 eval      lbstat = 'C'
     *    Get todays date.
500yDC**                 exsr      zzgetdatetime
500yDC**                 eval      lbsdte = curdate
500yDC**                 eval      lbstim = curtime
500yDC**                 update    lbrec
500yDC**                 endif
     *
500yDC**                 endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
500nAC     begupd1       tag
     *
     C                   eval      error = *off
     C                   eval      done = *off
     C                   eval      crtrcd = *off
     C                   eval      *in61 = *off
500 A
500 A*  Physically get pallet and take care of license stuff.
500 A
500 A
500 AC                   exsr      zzdrop
500 AC                   eval      curlic# = $tlic#
650bAc                   eval      it276Flag = *off
500fA
500 AC                   select
500fA
500fA*    User got pallet.
500fA
500 AC                   when      $treturn = '*OK'
500 AC                   eval      curlic# = $tlic#
500 AC                   eval      curitm  = $titem
500 AC                   eval      curpos  = $tslotpos
750aAc                   exsr      scr02i
750aDC*                  exsr      chkForDrpPck
500sAC                   if        rpltyp = '*FLOW'
500vAC                   exsr      zzrtnhomchk
500nAC                   exsr      zzupd2
500sAC                   endif
500fA
500fA*    User did NOT get pallet ...
500fA
500 AC                   when      $treturn = '*NOTFND'
500fA
500fA*      Write exception.
500fA
500oDC**                 exsr      zzexcp

500tA*      Delete replenishment when item could not be found.
500tA*      Exception was written in LT210.

500tAC     prky6e        chain     prplfil6
500tAC                   if        %found
500tAC                   eval      prflag = 'D'
500tAC                   update    prrec                                78
500tAC                   endif
500iA
500iA*      Abort current replenishment.
500iA
500tDC                   exsr      zzabrt
500tMC***                exsr      zzabrtskip
500fA
500fA*      Look for another replenishment.
500fA
500 AC                   eval      updrplrec = *on
500 AC                   exsr      zznxt1
500fMC                   select
500fA
500fA*        Found one. Redisplay screen 1 with new information.
500fA
500fMC                   when      done = *off
500dAC                   exsr      zzget1
500 AC                   eval      curitm = lbitem
500 AC                   eval      curwhd = lbwhdp
500 AC                   eval      curasl = lbaisl
500 AC                   eval      curloc = lbloc
500 AC                   eval      curlvl = lbrlvl
500 AC                   eval      curhnd = lbhand
500 AC                   eval      curdsp = lbdisp
500nA
500nAC                   if        w1scan = #frombasesldsp
500nAC                   goto      begupd1
500nAC                   else
500fMC                   exsr      scr01i
500nAC                   endif
500fA
500fA*        No more replenishments found.
500fA
500fMC                   other
500fA
500fA*          If transaction started (at least on repl found),
500fA*            Then start replenishing to the pick slots.
500fA*            Otherwise, tell user there is nothing to do.
500fA
500 AC                   if        rplstr = '*YES'
500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
500 AC                   else
500 AC                   exsr      scr07i
500 AC                   endif
500fAC                   endsl
500iA
500iA*    User wants to skip replenishment.
500iA
500iAC                   when      $treturn = '*SKIP'
500iA
500iA*      Abort current replenishment.
500iA
500tDC                   exsr      zzabrt
500tMC***                exsr      zzabrtskip
500iA
500iA*      Look for another replenishment.
500iA
500iAC                   eval      updrplrec = *on
500nAC                   eval      bypass = *on
500iAC                   exsr      zznxt1
500iAC                   select
500iA
500iA*        Found one. Redisplay screen 1 with new information.
500iA
500iAC                   when      done = *off
500iAC                   exsr      zzget1
500iAC                   eval      curitm = lbitem
500iAC                   eval      curwhd = lbwhdp
500iAC                   eval      curasl = lbaisl
500iAC                   eval      curloc = lbloc
500iAC                   eval      curlvl = lbrlvl
500iAC                   eval      curhnd = lbhand
500iAC                   eval      curdsp = lbdisp
500nA
500nAC                   if        w1scan = #frombasesldsp
500nAC                   goto      begupd1
500nAC                   else
500iAC                   exsr      scr01i
500nAC                   endif
500iA
500iA*        No more replenishments found.
500iA
500iAC                   other
500iA
500iA*          If transaction started (at least on repl found),
500iA*            Then start replenishing to the pick slots.
500iA*            Otherwise, tell user there is nothing to do.
500iA
500iAC                   if        rplstr = '*YES'
500iAC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
500iAC                   else
500iAC                   exsr      scr07i
500iAC                   endif
500iAC                   endsl
500tA
500tA*    User canceled pull.
500tA
500tAC                   when      $treturn = '*CANCEL'
500tA
500tA*      Abort current replenishment.
500tA
500tAC                   exsr      zzabrt
500tAC***                exsr      zzabrtskip
500tA
500tA*      Determine which screen to display to user.
500tA
500tAC                   if        rpltyp = '*BRKDWN'
610kMC                             or rpltyp = '*REPACK'
720 AC                             or rpltyp = '*STRREPL'
650fAC                             or rpltyp = '*PROD'
750aAC                             or rpltyp = '*DROPP'
500tAC                   exsr      scr09i
500tAC                   else
500xDC**                 exsr      scr07i
500xMC                   eval      nxtscr = 'EOJ'
500tAC                   endif
640aA
640aA*    Unexpected lt210 return code.
640aA
640aAC                   other
640aAC                   eval      error = *on
640aAC                   eval      *in21 = *on
640aAC                   eval      *in01 = *on
640aAC                   eval      errmsg = 'LT210: ' + $terrmsg
640aAC                   exsr      zm0105
500 A
500 AC                   endsl
500 A
500 AC                   goto      endup1

     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
500vDC**                 eval      rtnhom = *on
     *
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      *in42 = *off
720 Ac**  If Store Replenishment then force user to Apply License
720 Ac**  for what was pulled.  This will be pusedh to RPADOCK virtual
720 Ac**  slots in ZZUPD5.
720 A /free
                   if rplTyp = '*STRREPL';
720 A                    exsr zzzclr$lt210;
720 A                    $tlic# = #fromsaToLcns;
720 A                    $tcmd = '*PUTAWY9';     // Send with 9 and flip last to B in LT210
720 A                    $tpartial = '1';        // Force License Entry
720 A                    $twhse = #fromslwhse;
720 A                    $twhdp = #fromslwhdp;
720 A                    $tslot = #fromsldisp;
720 A                    $titem = #fromslitem;
720 A                    $titemdsc = #fromithead;
720 A                    $tqty1 = 0;
720 A                    $tqty2 = 0;
720 A                    $tqty3 = 0;
720 A                    $tnorm1 = 0;
720 A                    $tnorm2 = 0;
720 A                    $tnorm3 = 0;
720 A                    exsr zzzcall$lt210;
720 A /end-free
720 A*
720 Ac                   if        $treturn = '*CANCEL'
720 Ac                   eval      hldStrLcns = *blanks
720 Ac                   goto      endup2
720 Ac                   else
720 A /free
720 A       // Holf License to use when moving to User Slot
720 A                        hldStrLcns = $tinlic#;
720 A /end-free
720 Ac                   endif
720 Ac                   endif
     *
     *    Update From Slot if difference in pull qty.
     *
     C                   eval      difpck = w2nqty - w2repq
500dA
500dA*    License tracking - show qty in transit.
500dA
500dA*    Note, this was moved to the beginning of the routine because
500dA*    LT210 will be asking for a license plate, where the user can
500dA*    take F12.
500dA
500uDC**                 if        rpltyp = '*BRKDWN'
500sAC                   exsr      zzzclr$lt210
500sAC                   eval      $tcmd  = '*PULTRAN'
600aMC                   eval      $tlic# = #fromsaToLcns
600aMC                   eval      $tnewlic# = #fromsaToLcns
600aAC                   eval      $twhse = #fromslwhse
500sAC                   eval      $titem  = #fromititem
500sAC                   eval      $titemdsc = #fromithead
500sAC                   if        w2nqty < #fromslstk1
500sAC                   eval      $tpartial = *on
500sAC                   else
500sAC                   eval      $tpartial = *off
500sAC                   endif
500sAC                   eval      $tqty1 = w2nqty
500sAC                   eval      $tqty2 = 0
500sAC                   eval      $tqty3 = 0
500vAC                   eval      $tnorm1 = w2nqty
500vAC                   eval      $tnorm2 = 0
500vAC                   eval      $tnorm3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
      /free
650iA  if prtype = 'E'
730 M        and (prrplt = 'O' or prrplt='D');
700dA    // Verify $TPARTIAL by comparing total lowest unit of measure quantity
700dA    if w2nqty < ((#fromslstk1 * #fromitumq2) + #fromslstk2);
700dA      $tpartial = *on;
700dA    else;
700dA      $tpartial = *off;
700dA    endif;

500sA    $tqty1 = 0;
500sA    $tqty2 = w2nqty;
500sA    $tqty3 = 0;
500vA    $tnorm1 = 0;
500vA    $tnorm2 = w2nqty;
500vA    $tnorm3 = 0;
650iA  endif;
      /end-free
650dA*  If license entered then pulled from that license
650dAc                   if        LicenseEntered
600aAC                   eval      $tlic# = $liToLcns
600aAC                   eval      $tnewlic# = $liOlcns
650dAc                   endif
500sAC                   exsr      zzzcall$lt210
500dA*
500sAC                   if        $treturn = '*CANCEL'
500sAC                   goto      endup2
500sAC                   endif
500uDC**                 endif
600aD **
600aD ** If qty didn't change, then skip updating slots.
600aD **
600aDC**                 if        difpck = 0
600aDC**                 goto      skipqtyupd
600aDC**                 endif
     *
     *    Update transfer quantity in slot record.(From slot)
     *
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = #fromslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = #fromsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = #fromslitem
500rAC                   eval      $sacitemu = *on
610aDC**                 eval      $sacitem = #pickslitem
610aMC                   eval      $sacitem = #fromslitem
     C                   eval      $satrn#u = *on
     C                   eval      $satrn# = lbtrn#
     C                   eval      $satasku = *on
     C                   eval      $satask = pttask
     C                   eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = difpck
600aMC                   eval      $saqty1 = w2nqty
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
650iAc*  if Production and Breakdown Replen requested then
650iAc*  pass quantities in breakdown field instead of normal
650iAc                   if        prtype = 'E'
730 Mc                             and (prrplt = 'O' or prrplt='D')
650iAC                   eval      $saqty1 = 0
650iAC                   eval      $saqty2 = w2nqty
650iAC                   eval      $saqty3 = 0
650iAc                   endif
600aA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'RPL'
600aAC                   eval      $saETrn#U = *on
600aAC                   eval      $saETrn# = 0
600aAC                   eval      $saLbl#U = *on
600aAC                   eval      $saLbl# = lblbl#
600aAC                   eval      $saToLcnsU = *on
720 Ac                   if        $prplt = 'S'
720 Ac                   eval      $tinlic# = hldStrLcns
720 Ac                   endif
600aAC                   eval      $saToLcns = $tinlic#
600aAC                   eval      $saToPosU = *on
600aAC                   eval      $saToPos = $tslotpos
600aAC                   eval      $saToVrfyU = *on
600aAC                   eval      $saToVrfy = 'N'
600aAC                   eval      $saToCodeu = *on
600aAC                   eval      $saToCode = 'U'
600aAC                   eval      $saToAreaU = *on
600aAC                   eval      $saToArea = 'User'
600aAC                   eval      $saFrmLcnsU = *on
600aAC                   eval      $saFrmLcns = $toutlic#
600aAC                   eval      $saOLcnsU = *on
600aAC                   eval      $saOLcns = #fromsaOLcns
650dA*  If license entered then pulled from that license
650dAc                   if        LicenseEntered
600aAC                   eval      $saFrmLcns = $liToLcns
600aAC                   eval      $saOLcns = $liOlcns
650dAc                   endif
600aA
500aAC                   eval      $dricommand = '*SLOT'
500rDC**                 eval      $drisubcmd = '%PROUT'
600aDC**                 eval      $drisubcmd = '%PROUTCHG'
600aMC                   eval      $drisubcmd = '%TFR2USR'
500kMC                   eval      chk4err = *off
500kDC**                 eval      drizm = *off
500kMC                   eval      zmsflag = *off
600aAC                   if        w2nqty > 0
     C                   exsr      zzzdricop
650aAC                   exsr      zzgetdatetime
650aAC                   eval      tfr2usrDate = curdate
650aAC                   eval      tfr2usrTime = curtime
600aAC                   endif
600aA
600aAC                   eval      curlic# = $saToLcns
     *
     *    Update pick quantity in label record.
     *
     C     lbkey         chain     label                              79
     C                   z-add     w2nqty        lbqpck
     C                   if        itumq2 > *zeros
510bMC                             and pttask = 'REPLBK'
     C     itumq2        mult      w2nqty        wrkqty
     C                   eval      lbqrmn = wrkqty
     C                   else
     C                   z-add     w2nqty        wrkqty
510bAC                   eval      lbqrmn = wrkqty
     C                   endif
     C     lbucub        mult      wrkqty        lbcube
     C     lbuwgt        mult      wrkqty        lbswgt
     C                   update    lbrec
     *
     *    Update quantity in transaction record.
     *
     C     ptkey         chain     pirtran                            79
     C                   eval      ptpcs = wrkqty
     C     lbucub        mult      wrkqty        ptcube
     C     lbuwgt        mult      wrkqty        ptswgt
     C                   update    ptrec
640bAc                   exsr      zzwrttrand
     *
600aD **   Update receive quantity in slot record.(To slot)
600aD **
600aDC**                 exsr      clr$slot
600aD **
600aDC**                 eval      $slwhseu = *on
600aDC**                 eval      $slwhse = #pickslwhse
600aDC**                 eval      $slwhdpu = *on
600aDC**                 eval      $slwhdp = #pickslwhdp
600aDC**                 eval      $sldispu = *on
600aDC**                 eval      $sldisp = #picksldisp
600aDC**                 eval      $saitemu = *on
600aDC**                 eval      $saitem = #pickslitem
600aDC**                 eval      $sacitemu = *on
600aDC**                 eval      $sacitem = #fromslitem
600aDC**                 eval      $satrn#u = *on
600aDC**                 eval      $satrn# = lbtrn#
600aDC**                 eval      $satasku = *on
600aDC**                 eval      $satask = pttask
600aDC**                 eval      $saqtyu = *on
600aDC**                 eval      $saqty1 = difpck
600aDC**                 eval      $saqty2 = 0
600aDC**                 eval      $saqty3 = 0
600aDC**                 eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%PRINCHG'
600aDC**                 eval      chk4err = *off
500kDC**                 eval      drizm = *off
600aDC**                 eval      zmsflag = *off
600aDC**                 exsr      zzzdricop

500fAC     skipqtyupd    tag

     *
     *    Replenishment(s) started. F12=Cancel not available.
     C                   eval      rplstr = '*YES'
650cA*
650cA*   Create additional Repack Replenishment for remaining qty
650cA*   if replenishment quantity is greate than current pull qty
650cA*
650cAc                   if        rpltyp = '*REPACK'
720 Ac                              or rpltyp = '*STRREPL'
650fAc                              or rpltyp = '*PROD'
750aAc                              or rpltyp = '*DROPP'
650cAc                   if        w2repq > w2nqty
650cAc                   exsr      zzCrtRptRepl
650cAc                   endif
650cAc                   endif
     *
     *    Remove Pushback priority replenishment from file when
     *    has been successfully completed.
     *
     C     prky6e        chain     prplfil6                           7978
     C                   if        not *in79
     C                   eval      prflag = 'D'
     C                   update    prrec                                78
     C                   endif
     *
     *    Entire qty being replenished from slot &
     *    no qty allocated & no qty rcv'd into slot &
     *    virtual slots associated are at either 'Z'
     *    status or zero qty
     *    Update work file with replenishment info.
     *
500dAC                   exsr      zzaskzrovfy
500dAC                   if        askzrovfy
     *
500eMC                   eval      svpnbr = $tlic#
     C                   eval      svptyp = 'P'
     C                   eval      vfyslt = '*NO '
     C                   exsr      zzadwr
     *
     *    Display screen for user to Zero verify slot.
     C                   exsr      scr03i

500 AC                   goto      endup2
     C                   endif
     *
500 A
500 A*  Don't need to zero verify, so move on.
500 A
     *    Update work file with replenishment info.
500 A
500eAC                   eval      svpnbr = $tlic#
     C                   eval      svptyp = 'P'
     C                   eval      vfyslt = '*NO '
     C                   exsr      zzadwr
500 M
     *    See if there is another item to pull for replenishment.
500 A
500 AC                   eval      updrplrec = *off
501bDC**                 exsr      zznext
500nA
500nA*    Only want to do one replenishment at a time. Therefore,
500nA*    fool system into thinking there are no more replenishments
500nA*    so we will skip SC9.
500nA
500sAC                   if        rpltyp <> '*BRKDWN'
610iAC                             and rpltyp <> '*FLOW'
610iAC                             and rpltyp <> '*REPACK'
720 AC                             and rpltyp <> '*STRREPL'
650fAC                             and rpltyp <> '*PROD'
650fAC                             and rpltyp <> '*DROPP'
500nAC                   eval      done = *on
501bAC                   else
501bAC                   exsr      zznext
500sAC                   endif
500 A
500 A*    If one is found,
500 A*      Then ask user if he wants to pull any more items.
500 A
500 AC                   if        done = *off
500 AC                   exsr      scr09i
500 AC                   goto      endup2
500 AC                   endif
500 A
500 A*    Otherwise, if no more replenishments,
500 A*      Then tell user to put back an pulled pallets.
500 A*           and move on to the putaway process.
500 A
500sAC                   if        rpltyp = '*BRKDWN'
610kAC                             or rpltyp = '*REPACK'
720 AC                             or rpltyp = '*STRREPL'
650fAC                             or rpltyp = '*PROD'
750aAC                             or rpltyp = '*DROPP'
500sAC                   exsr      zzzclr$lt210
500sAC                   eval      $tcmd  = '*PULRTN'
500sAC                   eval      $twhdp  = #fromslwhdp
500sAC                   eval      $tslot  = #fromsldisp
500sAC                   eval      $titem  = #fromslitem
500sAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
500sAC                   exsr      zzzcall$lt210
500sAC                   if        $treturn <> '*OK'
500sAC                   endif
500sAC                   endif
500 A
500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
610iA
610iAC                   exsr      zznextstep
610iAC                   if        rpltyp='*REPACK' and nomoresteps and newrpl
650fAC                             or rpltyp='*PROD' and nomoresteps and newrpl
750aAC                             or rpltyp='*DROPP' and nomoresteps and newrpl
720 AC                             or rpltyp='*STRREPL' and nomoresteps and
720 AC                                 newrpl
610iAC                   exsr      zzupd7
610iAC                   endif
500 A
     C     endup2        endsr
730 A*----------------------------------------------------------------
730 A*
730 A*  ZZUPDdd   Update for Drop Pick Slot
730 A*
730 AC     zzupddd       begsr
730 A
750cD *  Check for Virtual slot
750cDC*                  exsr      clr$slot
750cDC*                  eval      $slwhseu = *on
750cDC*                  eval      $slwhse  = #pickslwhse
750cDC*                  eval      $slwhdpu = *on
750cDC*                  eval      $slwhdp  = #pickslwhdp
750cDC*                  eval      $sldispu = *on
750cDC*                  eval      $sldisp  = #picksldisp
750cDC*                  eval      $sldesgu = *on
750cDC*                  eval      $sldesg  = ' '
730 A
750cDC*                  eval      $dricommand = '*SLOT'
750cDC*                  eval      $drisubcmd  = '%GETCHKV'
750cDC*                  eval      $drisys2upd = 'D'
750cDC*                  eval      chk4err = *on
750cDC*                  eval      zmsflag = *off
750cDC*                  exsr      zzzdricop
750cA /free
750cA          vrtsltcnt=0;
750cA          exec sql select count(*) into :vrtsltcnt
750cA                  from vslot
750cA               where vswhse=:#pickslwhse and
750cA                     vswhdp=:#pickslwhdp and
750cA                     vspdis=:#picksldisp and
750cA              (select count(*) from slot where
750cA                 slwhse=vswhse and slwhdp=vswhdp and
750cA                 sldisp=vsdisp and slitem=:#fromslitem)>0;
750cA /end-free
750cAC*                  if        drierr
750cAc                   if        sqlstt<>'00000' or vrtsltcnt=0
730 A /free
730 A       exec sql  select sldisp,slaisl,slloc,slrlvl,slhand
730 A                   into :lbdsp2,:lbasl2,:lbloc2,:lblvl2,:lbhnd2
730 A                    from slot
740 D                  //where sldisp=:w5tosl and sldesg='*DROP' and slstat='A '
740 M                  where sldisp=:w5tosl and sldesg='*DROP' and slstat='DP'
730 A                     fetch first row only;
730 A /end-free
730 AC                   goto      endupdd
730 AC                   endif
730 A /free
730 A       // When no virtual use base slot and initial virtual will be created
750cD       //if $sfvirt = 'N'
750cA         if sqlstt='00000' and vrtsltcnt > 0;
750cD         //exec sql  select sldisp,slaisl,slloc,slrlvl,slhand
750cD         //            into :lbdsp2,:lbasl2,:lbloc2,:lblvl2,:lbhnd2
750cD         //             from slot
750cD                   //where sldisp=:w5tosl and sldesg='*DROP' and slstat='A '
750cD         //           where sldisp=:w5tosl and sldesg='*DROP' and slstat='DP'
750cD         //              fetch first row only;
750cD       //else;
730 A         // when virtual exists pass along so it will not create multiple virtuals
730 A         // for same item
730 A         exec sql  select vsdisp,vsaisl,vsloc,vsrlvl,vshand
730 A                     into :lbdsp2,:lbasl2,:lbloc2,:lblvl2,:lbhnd2
730 A                      from vslot,slot
730 A                    where vspdis=:#picksldisp
750cA                      and slwhse=vswhse and slwhdp=vswhdp
750cA                      and sldisp=vsdisp and slitem=:#fromslitem
730 A                       fetch first row only;
750cA
750cA*  Get Pick slot information.
750cA
750cAC                   eval      getwhse = lbwhs2
750cAC                   eval      getwhdp = lbwhd2
750cAC                   eval      getdisp = lbdsp2
750cAC                   exsr      zzgetpicksl
750cAc
730 A       endif;
730 A       if sqlStt = '00000';
730 A          // Update Label record to move forward in case user
730 A          // scanned another slot versus what system suggested
730 A          exec sql update label
730 A               set lbdsp2=:lbdsp2,lbasl2=:lbasl2,lbloc2=:lbloc2,
730 A                   lbhnd2=:lbhnd2
730 A               where lblbl#=:lblbl#;
730 A       endif;
730 A       // At this point we know the scanned slot is good
730 A       // so we really just need to forward to original screen 2
730 A /end-free
730 Ac     endupdd       tag
730 Ac                   if        nxtscr <> '05 '
730 Ac*    when coming from Screen 5 we should simply update label
730 Ac*    record and return
730 Ac                   exsr      scr02i
730 Ac                   endif
730 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     *
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   select
     *    User said slot was empty and system found NOT empty virtual slots.
500dMC                   when      #fromslvirt = 'Y' and
     C                             w3zero = 'Y'
     C                   eval      exerid = 'VRTSLT '
     C                   eval      exqty = *zeros
     C                   exsr      zzexcp
     *
     *    User said slot was NOT empty and system thinks it is.
     C                   when      #fromslvirt = 'N'  and
     C                             w3zero = 'N'
     C                   eval      exerid = 'NOTEMTY'
     C                   eval      exqty = *zeros
     C                   exsr      zzexcp
     *
     C                   endsl
     *
     *
     *    Retrieve next item to pull for replenishment.
     *
500fMC                   eval      updrplrec = *off
500dMC                   exsr      zznext
500nA
500nA*    Only want to do one replenishment at a time. Therefore,
500nA*    fool system into thinking there are no more replenishments
500nA*    so we will skip SC9.
500nA
500nAC                   eval      done = *on
500dA
500dA*    If one is found,
500dA*      Then ask user if he wants to pull any more items.
500dA
500dAC                   if        done = *off
500dAC                   exsr      scr09i
500dAC                   goto      endup3
500dAC                   endif
500dA
500dA*    Otherwise, if no more replenishments,
500dA*      Then tell user to put back an pulled pallets.
500dA*           and move on to the putaway process.
500dA
500mDC**                 exsr      zzzclr$lt210
500mDC**                 eval      $tcmd  = '*PULRTN'
500mDC**                 eval      $twhdp  = #fromslwhdp
500mDC**                 eval      $tslot  = #fromsldisp
500mDC**                 eval      $titem  = #fromslitem
500mDC**                 eval      $titemdsc = #fromithead
500mDC**                 exsr      zzzcall$lt210
500mDC**                 if        $treturn <> '*OK'
500mDC**                 endif
500dA
500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
     *
     *    Find this item's currrent location.
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C     endup4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     *
730 A /free
750cA          if w5scan <> ' ';
750cA             #picksldisp = w5scan;
750cA          endif;
750cD          //#picksldisp = w5scan;
730 A          exec sql  select sldesg
730 A                      into :$sldesg
730 A                       from slot
750cD                     //where sldisp=:w5scan
750cM                     where sldisp=:#picksldisp
730 A                        fetch first row only;
730 A /end-free

730 Ac                   if        $sldesg='*DROP'
730 A*  When Drop Pick we should update to Virtual slot if one exist
730 Ac                   eval      dropPick=*on
730 Ac                   exsr      zzupddd
730 Ac                   else
730 Ac                   eval      dropPick=*off
730 Ac                   endif
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      qtychg = *off
     *
610cA*   If user enters zero qty, just update work record status.
610cA*   Otherwise, call routine to put qty into slot.
610cA*
720 Ac                   if        rplTyp='*STRREPL'
720 Ac                   eval      w5nQty = wuRemqty1
720 Ac                   eval      w5pulq = wuRemqty1
720 ac                   endif
610cAC                   if        w5nqty = 0
610lAC                   eval      kyitem = lbitem
610cAC     keywu2        chain     workusr2
610cAC                   if        %found
610cAC                   eval      wustat = '2'
610cAC                   update    wurec
610cAC                   endif
610cAC                   else
500fAC                   exsr      zzputpick
730 A /free
730 A      // Since user is allowed to Scan a different virtual than
730 A      // the one suggested when no allocation or pick quantity
730 A      // exist we should loop through any *DROP picks for this
730 A      // item and remove any not used
740 D      //setll (#pickslwhse:#pickslitem:'A ') slot3;
740 M      setll (#pickslwhse:#pickslitem:'DP') slot3;
730 A      dow forever=forever;
740 D        //reade (#pickslwhse:#pickslitem:'A ') slot3;
740 M        reade (#pickslwhse:#pickslitem:'DP') slot3;
730 A        if not %found(slot3) or %eof(slot3);
730 A          leave;
730 A        endif;

             // only process Drop Pick slots.  Since Chefs wanted status
             // to be "A" for Active we have to skip non Drop Pick slots
             if sldesg <> '*DROP';
                iter;
             endif;

730 A        if slalc1=0 and slalc2=0 and slalc3=0 and
730 A           slstk1=0 and slstk2=0 and slstk3=0 and
730 A           slpck1=0 and slpck2=0 and slpck3=0;
730 A           // change to "Z" status and verify
                exec sql update slot2 set slstat='Z'
750aD                   //where slwhse=:slwhdp and
750am                   where slwhse=:slwhse and
                              slwhdp=:slwhdp and
                              sldisp=:sldisp;
730 A           exsr clr$slot;
730 A           $slwhseu = *on;
730 A           $slwhse = slwhse;
730 A           $slwhdpu = *on;
730 A           $slwhdp = slwhdp;
730 A           $sldispu = *on;
730 A           $sldisp = sldisp;
730 A           $dricommand = '*SLOT';
730 A           $drisubcmd  = '%ZEROVFY';
730 A           $drisys2upd = 'D';
730 A           exsr zzzDriCop;
730 A        endif;
730 A      enddo;
      /end-free
610cAC                   endif

     C                   eval      w1scan = ' '
     C                   eval      usrrpl = *off
500vDC**                 eval      newlb = *off

500fAC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif

     C     endup5        endsr
650hA*
650hA*----------------------------------------------------------------
650hA*
650hA*  ZZUPD51  Update for screen 51.
650hA*
650hAC     zzupd51       begsr
650hAc*
650hAc*   Setup production fields so they can be passed into
650hAc*   DRISLOT and then DRILICENSE to create the correct
650hAc*   log entries in PRODLOG
650hAc*
650hAc                   if        rpltyp = '*PROD'
750aAc                             or rpltyp = '*DROPP'
650hAc                   if        *inkj
650hAc                   eval      hldGs1(gs1c) = 'Overridden'
650hAc                   eval      hldser(gs1c) = ' '
650hAc                   eval      hldWgt(gs1c) = 0
650hAc                   else
650hAc                   eval      hldGs1(gs1c) = w5gs1
650hAc                   endif
      /free
              // if no GS1 weight then send all 9's and DRILICENSE will
              // either replace with a LicInfo average weight or item
              // master box weight
                         if hldWgt(gs1c) = 0;
                            hldwgt(gs1c) = 999999.999;
                         endif;
      /end-free
650hAc                   endif
650hAc                   eval      w5gs1 = ' '
650hAc*
650hAC     endup51       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 06.
     *
     C     zzupd6        begsr
     *
     C                   eval      error = *off
     C                   eval      refrsh = *on

500fAC                   exsr      zzputovrf
500fAC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif

     C     endup6        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD7   Update for screen 07.
     *
     C     zzupd7        begsr
     *
     C                   eval      error = *off
500xAC                   eval      bypass = *on
500nA
500nA*  If there are no replenishments to be done, get out.
500nA
500nAC     newrpl        cabeq     *off          done7
500nA
500nA*  Otherwise get next item to pull for replenishment.
500nA
500nAC                   dow       forever = forever
500nA
500nAC                   eval      rplmode = 'RPL'
500nAC                   eval      rplstr = '*NO'
500nAC                   eval      updrplrec = *on
500nAC     prky6e        setll     prplfil6
500nAC                   exsr      zznxt1
500nA
500nA*    If no more, get out.
500nA
500nAC     done          cabeq     *on           done7
500nA
500nA*    Otherwise, send user to slot.
500nA
500nAC                   exsr      zzget1
500nAC                   eval      curitm = lbitem
500nAC                   eval      curwhd = lbwhdp
500nAC                   eval      curasl = lbaisl
500nAC                   eval      curloc = lbloc
500nAC                   eval      curlvl = lbrlvl
500nAC                   eval      curhnd = lbhand
500nAC                   eval      curdsp = lbdisp
500nA
500nAC                   if        lastslot = #frombasesldsp
650dAc                             and not it276Flag
650dAc                             and not LicenseEntered
500nAC                   exsr      zzupd1
500nAC                   else
500pAC                   exsr      zzreturnplt
500nAC                   exsr      scr01i
500nAC                   endif
500nAC                   goto      endup7
500nA
500nAC                   enddo
500nA
500nA*  No more replenishments to do so return to first screen.
500nA
500nAC     done7         tag
500sA
500sA*    Return pallets if necessary.
500sA
500sAC                   if        lastslot <> ' '
500sAC                   exsr      zzreturnplt
500sAC                   endif
     *
     *    End program. Return to calling program.
     C                   eval      nxtscr = 'EOJ'
     *
     *    Start an 'IDLE' task, if no open task.
     *
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C                   if        curent = *off
     C                   eval      w1task = 'IDLE  '
500dMC                   exsr      zztrnidle
     C                   endif
     *
     C     endup7        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZUPD9   Update for screen 9.
500 A*
500 AC     zzupd9        begsr
     *
     C                   eval      error = *off
     C                   eval      refrsh = *on

     *  If user doesn't want to pull any more items,
500 A*    Then tell user to put back an pulled pallets.
500 A*         and move on to the putaway process.

     C                   if        w9opt <> 'Y'

500sAC                   if        rpltyp = '*BRKDWN'
610kMC                             or rpltyp = '*REPACK'
720 MC                             or rpltyp = '*STRREPL'
650fMC                             or rpltyp = '*PROD'
750aMC                             or rpltyp = '*DROPP'
500sAC                   exsr      zzzclr$lt210
500sAC                   eval      $tcmd  = '*PULRTN'
500sAC                   eval      $twhdp  = #fromslwhdp
500sAC                   eval      $tslot  = #fromsldisp
500sAC                   eval      $titem  = #fromslitem
500sAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
500sAC                   exsr      zzzcall$lt210
500sAC                   if        $treturn <> '*OK'
500sAC                   endif
500sAC                   endif
500 A
500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
     C                   goto      endup9

     C                   endif

     *  Otherwise get next item to pull for replenishment.

     C                   dow       forever = forever

500 AC                   eval      updrplrec = *on
     C                   exsr      zznxt1

     *    If no more ...

     C                   if        done = *on

     *      ... Tell user to put back an pulled pallets.

500sAC                   if        rpltyp = '*BRKDWN'
610kMC                             or rpltyp = '*REPACK'
720 AC                             or rpltyp = '*STRREPL'
650fMC                             or rpltyp = '*PROD'
750aMC                             or rpltyp = '*DROPP'
500sAC                   exsr      zzzclr$lt210
500sAC                   eval      $tcmd  = '*PULRTN'
500vDC**                 eval      $twhdp  = curwhd
500vDC**                 eval      $tslot  = curdsp
500vDC**                 eval      $titem  = lbitem
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500vAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
500sAC                   exsr      zzzcall$lt210
500sAC                   if        $treturn <> '*OK'
500sAC                   endif
500sAC                   endif

     *      ... And move on to the putaway process.

500fMC                   exsr      zznextstep
501aAC                   if        rpltyp='*FLOW' and nomoresteps and newrpl
501aAC                   exsr      zzupd7
501aAC                   endif
     C                   goto      endup9

     C                   endif

     *    If next item is in same slot as last item,
     *      Then physically get pallet and take care of license stuff.
     *        If user is not able to get item, then loop for another.
     *        Otherwise, display this screen for new item.

650cA*     This if will only display screen two if the user did not
650cA*     use the knew function to override the suggested pick slot
650cA*
650fDc*                  if        ((rpltyp = '*REPACK'
650fAc                   if        (((rpltyp = '*REPACK'
650fAc                                 or rpltyp = '*PROD'
750aAc                                 or rpltyp = '*DROPP'
720 Ac                                 or rpltyp = '*STRREPL')
650cAc                              and not qtyGrtSlt)
650fDc*                             or rpltyp <> '*REPACK')
650fAc                              or (rpltyp <> '*REPACK'
650fMc                                 and rpltyp <> '*PROD'
750aMc                                 and rpltyp <> '*DROPP'
720 Ac                                 and rpltyp <> '*STRREPL'))
     C                   if        lbaisl = curasl
     C                             and lbloc = curloc
     C                             and lbrlvl = curlvl

500jAC                   exsr      zzget1
500jAC                   eval      curitm = lbitem
500jAC                   eval      curwhd = lbwhdp
500jAC                   eval      curasl = lbaisl
500jAC                   eval      curloc = lbloc
500jAC                   eval      curlvl = lbrlvl
500jAC                   eval      curhnd = lbhand
500jAC                   eval      curdsp = lbdisp

500jDC**                 eval      curitm = lbitem
500jDC**                 eval      curhnd = lbhand
500jDC**                 eval      curdsp = lbdisp

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd   = '*PULDROP'
     C                   eval      $twhdp  = lbwhdp
     C                   eval      $tslot  = lbdisp
     C                   eval      $titem  = lbitem
500jAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
     C                   exsr      zzzcall$lt210

     C                   select

     C                   when      $treturn = '*NOTFND'
500oDC**                 exsr      zzexcp
500pDC**
500pDC**                 exsr      zzzclr$lt210
500pDC**                 eval      $tcmd   = '*PULRTN'
500pDC**                 eval      $twhse  = lbwhse
500pDC**                 eval      $twhdp  = lbwhdp
500pDC**                 eval      $tslot  = lbdisp
500pDC**                 eval      $titem  = lbitem
500pDC**                 eval      $titemdsc = #fromithead
500pDC**                 exsr      zzzcall$lt210

500tA*      Delete replenishment when item could not be found.
500tA*      Exception was written in LT210.

500tAC     prky6e        chain     prplfil6
500tAC                   if        %found
500tAC                   eval      prflag = 'D'
500tAC                   update    prrec                                78
500tAC                   endif
500oA
     C                   iter

500iAC                   when      $treturn = '*SKIP'
500iAC                   iter

     C                   when      $treturn = '*CANCEL'
     C                   goto      endup9

     C                   when      $treturn = '*OK'
     C                   eval      curlic# = $tlic#
     C                   eval      curpos  = $tslotpos
     C                   eval      rplstr = '*YES'

     C                   endsl

750aAc                   exsr      scr02i
750aDc*                  exsr      chkForDrpPck
     C                   goto      endup9
     C                   endif
650cAC                   endif

     *    Otherwise, item is not in same slot as last item,
     *      Therefore, put pallets pulled for last item back up,
     *                 then send user to new slot.

500sAC                   if        rpltyp = '*BRKDWN'
610kMC                             or rpltyp = '*REPACK'
650fAC                             or rpltyp = '*PROD'
750aAC                             or rpltyp = '*DROPP'
720 AC                             or rpltyp = '*STRREPL'
500vDC**                 eval      curitm = lbitem
500vDC**                 eval      curwhd = lbwhdp
500vDC**                 eval      curasl = lbaisl
500vDC**                 eval      curloc = lbloc
500vDC**                 eval      curlvl = lbrlvl
500vDC**                 eval      curhnd = lbhand
500vDC**                 eval      curdsp = lbdisp

500sAC                   exsr      zzzclr$lt210
500sAC                   eval      $tcmd  = '*PULRTN'
500vDC**                 eval      $twhdp  = curwhd
500vDC**                 eval      $tslot  = curdsp
500jDC**                 eval      $titem  = lbitem
500vDC**                 eval      $titem  = curitm
500vAC                   eval      $twhdp  = #fromslwhdp
500vAC                   eval      $tslot  = #fromsldisp
500vAC                   eval      $titem  = #fromslitem
500vAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic#  = #fromsaToLcns
500sAC                   exsr      zzzcall$lt210
500sAC                   if        $treturn <> '*OK'
500sAC                   endif
500sAC                   endif

500jAC                   eval      curitm = lbitem
500jAC                   eval      curwhd = lbwhdp
500jAC                   eval      curasl = lbaisl
500jAC                   eval      curloc = lbloc
500jAC                   eval      curlvl = lbrlvl
500jAC                   eval      curhnd = lbhand
500jAC                   eval      curdsp = lbdisp

     C                   exsr      scr01i
     C                   goto      endup9

     C                   enddo

     C     endup9        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPW1   Update pushback replenishment workfile - From slot seq
     *
     C     zzupw1        begsr
600aMC                   update    wurec4
     C     enduw1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPW2   Update pushback replenishment workfile - To slot seq
     *
     C     zzupw2        begsr
600aMC                   update    wurec5
     C     enduw2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZZEROVFY   Verify zero slots.
     *
     C     zzzerovfy     begsr

500dAC                   exsr      clr$slot
500dAC                   eval      $slwhseu = *on
500dAC                   eval      $slwhse  = #fromslwhse
500dAC                   eval      $slwhdpu = *on
500dAC                   eval      $slwhdp  = #fromslwhdp
500dAC                   eval      $sldispu = *on
500dAC                   eval      $sldisp  = #fromsldisp
500dA
500dAC                   eval      $dricommand = '*SLOT'
500dAC                   eval      $drisubcmd  = '%ZEROVFY'
500dAC                   eval      $drisys2upd = 'D'
500kMC                   eval      chk4err = *on
500dAC                   exsr      zzzdricop
500kMC                   if        drierr
500dAC                   eval      error = *off
500dAC                   endif
     *
     C     endzro        endsr

500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------
500dA*                     DRI SUBROUTINES
500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------

500dA*----------------------------------------------------------------
500dA*  clr$item  Clear $item data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

650dA*----------------------------------------------------------------
650dA*  clr$license  Clear $license data structure fields
650dA*----------------------------------------------------------------
650dA
650dAC     clr$license   begsr
650dAC                   eval      savever# = $liver#
650dAC                   clear                   $license
650dAC                   eval      $liver# = savever#
650dAC**                 eval      $liemp# = $emp#
650dAC                   eval      $liuser = #curruser
650dAC                   eval      $lipgm  = #pgm
650dAC                   eval      $lijob  = #job
650dAC                   eval      $lijobn = #jobnbr
650dAC                   eval      $liTowhse = getwhse
650dAC                   eval      $liTowhseu = *on
650dAC                   endsr
500dA*----------------------------------------------------------------
500dA*  clr$slot  Clear $slot data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600aAC                   eval      $saemp#U = *on
600aAC                   eval      $saemp# = #emp#
     C                   endsr

500dA*----------------------------------------------------------------
500dA*  clr$slotdef  Clear $slotdef data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
650hA*----------------------------------------------------------------
650hA*  clr$uciinfo  Clear $uciinfo data structure fields
650hA*----------------------------------------------------------------
650hA
650hAC     clr$uciinfo   begsr
650hAC                   eval      savever# = $uiver#
650hAC                   clear                   $uciinfo
720bAC                   clear                   $uciinfo2
650hAC                   eval      $uiver# = savever#
650hAC                   eval      $uiaddemp = #emp#
650hAC                   eval      $uiaddusr = #user
650hAC                   eval      $uiaddpgm  = #prog
650hAC                   eval      $uiaddjob  = #job
d50hAC                   eval      $uiaddnbr = #jobn
650hAC                   endsr
650hAC
650hA*----------------------------------------------------------------
650hA*  wrtProdLog   Write Beginning Inventory Production Log Entry
650hA*----------------------------------------------------------------
650hAC
650hAC/free
650hA  begsr WrtProdLog;
650hA
650hA     // have SQL delete record if one already exist for this
650hA     // mfg line, item, slot, and production date and warehouse
650hA
650hA    // create Production Log entry
650hA
650hA    plwhse = $pwhse;
650hA    plitem = lbitem;
650hA    plfgitm = ' ';
650hA
650hA    plaction = 'RPL';
650hA    // call DRISLOT to get license for slot
650hA    savever# = $slver#;
650hA    clear $slot;
650hA    clear $slot2;
650hA    $slver# = savever#;
650hA
650hA   // Move fields to slot data structure for quantity adjustment
650hA
650hA  //  $slwhseu = *on;
650hA  //  $slwhse  = $pwhse;
650hA
650hA  //  $slwhdpu = *on;
650hA  //  $slwhdp = $pwhdp;
650hA  //  $sldispu = *on;
650hA  //  $sldisp = prfdis;
650hA  //  $saOLcnsu = *on;
650hA
650hA  //$dricommand = '*SLOT';
650hA  //$drisubcmd  = '%GET';
650hA  //$drisys2upd = 'D';
650hA  //exsr zzzDriCop;
650hA
650hA  //if driErr;
650hA  //   plFlcns = ' ';
650hA  //   plTlcns = ' ';
650hA  //else;
650hA       plFLCNs = wuPulLcns;
650hA       plTlcns = $tlic#;
650hA  //endif;
650hA
710 d  //  plline = prtlvl;
710 A    plline = #pickslrlvl;
650hA
650hA    plprdDte = prddte;
650hA
650hA    pldisp = #picksldisp;
650hA
650hA    plgs1 = hldgs1(gs1c);
650hA
650hA    if not scangs1;
700bA      if prtype = 'E';     //Breakdown1 replenishment
700bA        plqtyn = 0;
700bA        plqty1 = w5nqty;
700bA      else;
650hA        plqtyn = w5nqty;   //Normal Breakdown replenishment
700bA        plqty1 = 0;
700bA      endif;
650hA    else;
650hA       plqtyn = 1;
700bA       plqty1 = 0;
650hA    endif;
700bD  //  650hA    plqty1 = 0;
650hA    plqty2 = 0;
650hA
650hA    plweght = hldwgt(gs1c);
650qA    // if calling program sends in liPRDWGT as 999999.999
650qA    // that says it was unable to get specific weight.
650qA    // DRILICENSE will now look to the license info for
650qA    // average weight, then to item master for box weight.
650qA    if plweght = 999999.999;
650qA       plweght = 0;
650qA       chain ($pwhse:$saolcns:1) licinfo;
650qA       if %found(licinfo);
650qA          plweght = lnavglbs;
650qA       endif;
650qA       if plweght = 0;
650qA          chain ($pwhse:lbitem) piritem;
650qA          if %found(piritem);
650qA             plweght = itswgt;
650qA          endif;
650qA       endif;
650qA    endif;
650hA
650hA    plbfcwo = ' ';   // BFC work order number.
650qA
650hA    pltare = 0;
650hA
650hA    plpgm = #pgm;
650hA    pluser = #user;
650hA    pljob = #job;
650hA
650hA    pllsts = hldser(gs1c);
650hA
650hA    plCUSTWO = ' ';
650hA
650hA    pltrn# = lbtrn#;
650hA
650hA    pllbl# = lblbl#;
650hA
650hA    plcts = %timestamp();
650hA    pldtetim = %subst(%char(plcts):1:4) +
650hA               %subst(%char(plcts):6:2) +
650hA               %subst(%char(plcts):9:2) +
650hA               %subst(%char(plcts):12:2) +
650hA               %subst(%char(plcts):15:2) +
650hA               %subst(%char(plcts):18:2);
650hA    write plrec;
650hA
650hA  endsr;
650hA /end-free
640bA*----------------------------------------------------------------*********
640bA*
640bA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640bA*
640bA /free
640bA   begsr zzwrttrand;
640bA     wrtpcmd = '*ONETRAN';
640bA     wrtpwait = 0;
640bA     wrtpwhse = ptwhse;
640bA     wrtptran# = pttrn#;
640bA     wrtpfrmdate = 0;
640bA     wrtptodate = 0;
640bA     wrtpemp# = 0;
640bA
640bA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640bA               wrtpfrmdate: wrtptodate: wrtpemp#);
640bA   endsr;
640bA /end-free
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdriclose   Close any open files or programs.
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdricop  Call DRICOP
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
700aAc                   when      $dricommand = '*PROD'
700aAc                   eval      $dridata = $pprod
700 Ac                   eval      $dridata2 = $pprod2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600aAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
650dAC                   when      $dricommand = '*LICENSE'
650dAC                   eval      $dridata = $license
650dAC                   eval      $dridata2 = $license2
650hAC                   when      $dricommand = '*UCIINFO'
650hAC                   eval      $dridata = $uciinfo
720bAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
700aAC                             or $dricommand = '*PROD'
600aAC                             or $dricommand = '*SLOT'
650dAC                             or $dricommand = '*LICENSE'
720bAC                             or $dricommand = '*UCIINFO'
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

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
700aAc                   when      $dricommand = '*PROD'
700aAc                   eval      $pprod = $dridata
700aAc                   eval      $pprod2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
650dAC                   when      $dricommand = '*LICENSE'
650dAC                   eval      $license = $dridata
650dAC                   eval      $license2 = $dridata2
650hAC                   when      $dricommand = '*UCIINFO'
650hAC                   eval      $uciinfo = $dridata
720bAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

417qA*----------------------------------------------------------------
417qA*  ZZZCLR$LT210  -  Clear LT210 parameters.
417qA*----------------------------------------------------------------

417qAC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
500 AC                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
500vAC                   clear                   $tnorm1
500vAC                   clear                   $tnorm2
500vAC                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
500cAC                   clear                   $tinslot
500cAC                   clear                   $tsamepos
500cAC                   clear                   $tdiffpos
500cAC                   clear                   $tpsplit
500cAC                   clear                   $tinlic#
500cAC                   clear                   $toutlic#
500caC                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid
610gAC                   clear                   $ttoslot

     C                   endsr

417qA*----------------------------------------------------------------
417qA*  ZZZCALL$LT210  -  Call LT210 program.
417qA*----------------------------------------------------------------

417qAC     ZZZCALL$LT210 begsr

730 Ac                   eval      $ttoslot = #picksldisp
500eAC                   select
500eAC                   when      $prplt = 'B'
500eAC                   eval      $ttype = 'BRK'
700fDC**                 if        #pickslsdef = 'EA'
700fMC                   if        #picksdpal = '*EACH'
700eAC                   eval      $thead = 'EACH Slot Replenish'
700eAC                   else
500eAC                   eval      $thead = 'BrkDn Repl.'
700eAC                   endif
530aAC                   when      $prplt = 'R'
530aAC                   eval      $ttype = 'RPK'
530aAC                   eval      $thead = 'Repack Repl'
730 AC                   when      $prplt = 'D'
730 AC                   eval      $ttype = 'RPK'
730 AC                   eval      $thead = 'Prod Repl'
730 MC                   when      $prplt = 'O'
650fAC                   eval      $ttype = 'RPK'
650fAC                   eval      $thead = 'Prod Repl'
720 AC                   when      $prplt = 'S'
720 AC                   eval      $ttype = 'RPA'
720 AC                   eval      $thead = 'Store Repl'
500eAC                   when      $prplt = 'F'
500eAC                   eval      $ttype = 'FLW'
500eAC                   eval      $thead = 'Flowrack Repl.'
500eAC                   other
500eAC                   eval      $ttype = 'RPL'
500eAC                   eval      $thead = 'Replenishment'
500eAC                   endsl

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
500eMC                   parm                    $ttype
500eMC                   parm                    $thead
     C                   parm      $pwhse        $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
500 AC                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
500vAC                   parm                    $tnorm1
500vAC                   parm                    $tnorm2
500vAC                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
500cAC                   parm                    $tinslot
500cAC                   parm                    $tsamepos
500cAC                   parm                    $tdiffpos
500cAC                   parm                    $tpsplit
500cAC                   parm                    $tinlic#
500cAC                   parm                    $toutlic#
500cAC                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
610gAC                   parm                    $ttoslot

     C                   endsr
700aA
700aA*----------------------------------------------------------------
700aA*  zzChkLin  Verify Production Line slot exists for Production
700aA*            Replenishment
700aA*----------------------------------------------------------------
700aA
700aAC     zzChkLin      begsr
      *
      /free
                         exec sql
                              select slitem,slstat into
                                     :wkritem, :wkrstat
                                from slot
                                where sldisp = :prtdis
700cA                             and slwhdp = :prwhdp;

                         if sqlStt <> '00000'
                            or wkrstat <> 'PR' or wkritem <> pritem;
                            // Production Line Slot not found.  Need to
                            // get slot from DRIPROD and update this
                            // replenishment to Slot
                            clear $pprod;
                            clear $pprod2;
650nA                       $ppwhdpu = *on;
650nA                       $ppwhdp = prwhdp;
650nA                       $ppitemu = *on;
650nA                       $ppitem = pritem;
650nA                       $pprcvau = *on;
650nA                       $pprcva = %subst(prtdis:1:3);
650nA                       $ppwhseu = *on;
650nA                       $ppwhse  = prwhse;
650nA                       $ppdest = *on;
650nA                       $ppdest  = 'M';   // get LIN slot
650nA                       $pplnenou = *on;
650nA                       $pplneno = prtlvl;
650nA                       $ppuser = #User;
650nA                       $ppuseru = *on;
650nA
650nA                       $dricommand = '*PROD';
650nA                       $drisubcmd = '%GETSLOT';
650nA                       $drisys2upd = 'D';
650nA                       exsr zzzDriCop;
650nA                       if not drierr;
                               // pass new LIN slot to replenishment
650nA                          prtdis = $pprcvar;
                            endif;
                         endif;
      /end-free
      *
700aAC                   endsr

650dA*----------------------------------------------------------------
650dA*  getNxtSlot  Get next available slot Repack adding additional
650dA*              Replenishment Record
650dA*----------------------------------------------------------------
650dA
650dAC     getNxtSlot    begsr
650dA
650dAC* Look for available pick slot first
650dA
650dAc                   movel     'No '         fndSlot           3
650dAC                   eval      k3pick = 'Y '
650dAC                   eval      k3stat = 'A '
650dAC     keys3         setll     slot3
650dAC                   dow       forever = forever
650dAC     keys3         reade(n)  slot3
650dA
650dAC                   if        %eof
650dAC                   goto      lookforOvr
650dAC                   endif
650dA
650dAc                   if        slaisl='USR'
650dAc                             or slaisl='RCV'
650dAc                             or slaisl='STG'
650dAc                             or slaisl='OSS'
650dAc                   iter
650dAc                   endif
650dA
650dAC                   exsr      calcqtys
650dAC                   if        slavl1 >0
650dAc                   eval      fndSlot = 'Yes'
650dAc                   goto      endgetSlt
650dAc                   else
650dAc                   iter
650dAc                   endif
650dA
650dAC                   enddo
650dA
650dAc     lookforOvr    tag
650dAC                   eval      k3pick = 'N'
650dAC                   eval      k3stat = 'A'
650dAC     keys3         setll     slot3
650dAC                   dow       forever = forever
650dAC     keys3         reade(n)  slot3
650dA
650dAC                   if        %eof
650dAC                   goto      endgetSlt
650dAC                   endif
650dA
650dAc                   if        slaisl='USR'
650dAc                             or slaisl='RCV'
650dAc                             or slaisl='STG'
650dAc                             or slaisl='OSS'
650dAc                   iter
650dAc                   endif
650dA
650dAC                   exsr      calcqtys
650dAC                   if        slavl1 >0
650dAc                   eval      fndSlot = 'Yes'
650dAc                   goto      endgetSlt
650dAc                   else
650dAc                   iter
650dAc                   endif
650dA
650dAC                   enddo
650dA
650dAC     endgetSlt     endsr
650dA
650dA*----------------------------------------------------------------
650dA*  calcqtys  Calculate slot quantities.
650dA*----------------------------------------------------------------
650dA
650dAC     calcqtys      begsr
650dA
650dAC                   eval      slphy1 = (slstk1+slrcv1)-(sltfr1+slpck1)
650dA
650dA*  Calculate available quantity in slot.
650dA
650dAC                   eval      slavl1 = slphy1 - slalc1
650dA
650dAC                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Item
Qty
Verify Zero
Slot
Slot empty
Item number
 Brkdwn
Replenishment
   Let down
Breakdown Repl
 FlowRack Repl
Let down qty cannot be less than zero.
From aisle not valid.
To aisle not valid.
From/to both blank or both filled in.
Rtn product to slot:
Entire bal. qty must be entered.
Pull qty cannot be gt than slot qty.
Replen qty cannot be gt than pull qty.
Repl qty gt avail qty in from slot.
F10=Excpt not avail when Rtn home active
Qty putaway cannot be gt than balance.
New Replen's to do.
Pull qty must be gt zero for letdown.
Repl type
License not entered.
Label
License
Option
Repack
Qty must match either slot or repl qty
Scanned item must match replen item
Production
Scanned GS1 Invalid
Error Adding GS1 to UCIINFO
EACH Slt
Staging
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
