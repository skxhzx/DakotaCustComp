      /COPY *libl/qcopysrc,hspecs
640aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DRILICENSE  Dakota realtime interface - License
     *  29 October 2008
     *  Dave Sommerville
     *
600 A*    10/29/08  DAS  6.00
     *      - Created
     *
600aA*    04/29/09  DAS  6.00a
     *      - Added %SETLCNS0 to allow adding a license with zero qtys.
     *        This was done for %OSSIN because currently the OSS slot
     *        must be created before the qty is put into it.
     *      - Revised adjsltdte routine to not skip and OSS slot
     *        with zero qty.
     *
600bA*    05/18/09  DAS  6.00b
     *      - Revised tfrToRec to add qty for RTNORIG, which is sent
     *        when a qty is being return to its original slot during
     *        a transfer or replenishment.
     *
600cA*    05/19/09  DAS  6.00c
     *      - Added *GETSFGOSS.
     *
     *      - never used.
     *
600eA*    05/26/09  DAS  6.00e
     *      - Added *NOSTOCK.
     *
600fA*    05/31/09  DAS  6.00f
     *      - Revised how special LP is handled in tfrsltdte. If one
     *        is sent in we want to use it.
     *
600gA*    05/31/09  DAS  6.00g
     *      - Added *XDK.
     *
600hA*    06/04/09  DAS  6.00h
     *      - Added version 2 fields to C#LICENSE (Slot Fifo info)
     *      - Created routine getsltfifo to fill in new Fifo fields.
     *      - Revised many commands to call getsltfifo before returning.
     *
600iA*    06/04/09  DAS  6.00i
     *      - Added whdp and disp to vfyadjsltqty
     *
600jA*    06/06/09  DAS  6.00j
     *      - Added *CHGFIFO.
     *
600kA*    06/10/09  DAS  6.00k
     *      - Added *GETINFO.
     *
600lA*    06/11/09  DAS  6.00l
     *      - Revised to handle *NG licenses correctly for tfrsltdte.
     *
600mA*    06/15/09  DAS  6.00m
     *      - Revised vfyadjsltqty to set frmSitem info to toSitem info.
     *
600nA*    06/25/09  DAS  6.00n
     *      - Revised aaainit to initialize LAREC fields. Re: if a
     *        LicActive records doesn't exist an error could occur
     *        when trying to write a log record because it uses the
     *        LAWHSE field or it would use information from a the
     *        last good read of LicActive for a different action.
     *
600oA*    07/17/09  CWM  6.00o
     *      - Added %SETFIFO and supporting routines VFYSETLICFIFO,
     *        VFYTOPRTYSENT, VFYTOENTDSENT, VFYTOEXPDSENT and SETFIFO.
     *
610aA*    09/01/09  DAS  6.10a
     *      - Added command *CHGDP to change a *DP (direceted putaway)
     *        license to the scanned license.
     *
610bA*    09/20/09  DAS  6.10b
     *      - Revised adjsltqtyadd to use a zero qty license for
     *        Actions CNT (cycle count) and INV (inventory count).
     *
610cA*    10/19/09  DAS  6.10c
     *      - Revised tfrtorec to add qty to an existing license if
     *        the license doesn't start with '*' and the from
     *        license is *MULTIPLE. Re: This should only occur when
     *        transfering multiple license from a slot to an
     *        overflow slot for a Medium/High item. In that case
     *        we will ask the user for a new license and combine
     *        the multiple licenses into the new license.
     *
610dA*    10/26/09  DAS  6.10d
     *      - Revised tfrsltdte to only look for a wrong To item if
     *        the From and To slots are different.
     *
610eA*    04/09/10  DAS  6.10e
     *      - Revised %SETFIFO to call getsltfifo last not first.
     *
610fA*    09/27/10  DAS  6.10f
     *      - Fix: After calls to routine upToRecQty the program was
     *        checking the lowToRecQty field. This field gets trashed
     *        in that routine. Therefore, the individual laqty1/2/3
     *        need to be checked.
     *
640aA*    02/25/11  DAS  6.40a
     *      - Changed type to SQLRPGLE.
     *      - Added command *DLTORPHAN to delete LICACTIVE records
     *        that do not have a corresponding SLOT record.
     *
640bA*    04/01/11  DAS  6.40b
     *      - Revised routine TfrToRecExtra to set $liAQty values
     *        to the extra qty.
     *
640cA*    04/12/11  DAS  6.40c
     *      - Revised routine cvtllAQty to not convert qtys when
     *        action is 'CHG'. Re: When 7=Change Item is used in item
     *        maint, and you go from a normal item to a breakdown
     *        item, DRISLOT does not convert the qty to its breakdown
     *        equivalent. Therefore, we don't want this program to
     *        to it either.
     *
640dA*    07/07/11  DAS  6.40d
     *      - Added file identifier to sql stmt in routine dltOrphan.
     *        This is to prevent a job log entry from being created.
640eA*    10/20/11  MLB  6.40e
     *      - Fix: Revised getinfo to not lock LICLOG file when reading
     *        records.
640fA*    02/21/12  LMC  6.40f
     *      - Fix: Populate original license in subr NOSTOCK and XDK. g
     *      - It has been determined that this LICLOG record is not
     *        necessary and possibly confusing when we don't adjust
     *        anything, therefore we are removing the exsr
     *        WRTLICLOGADJ from subr ADJSLTQTYZERO.
640gA*    05/30/12  RH   6.40g
     *      - Fix: Create *NF license with entered date = current dateg
     *
640hA*    05/24/12  RBD  6.40h
     *      - Fix: Added missing fields to SETFIFO command : action,
     *        emp#, user, original license, and tran# are now being
     *        passed in by DRISLOT ... use subr getltrn to get license
     *        tran#.
640iA*    09/28/12  RH   6.40i
     *      - Fix: Added liclog Infocode for SETFIFO command
650aA*    02/26/13  LMC  6.50a
     *      - Enh: Keep breakdown items at received quantities in BFC
     *        designation slots. Once product is moved to a non BFC
     *        designation slot, the quantities will be converted.
650bA*    03/13/13  LMC  6.50b
     *      - Fix: When creating *NG licenses, use our Spcl license
     *        create logic instead of using the slot display as part
     *        of the license number. Change the Fixnglcns routine to
     *        read licative5 finding a match on whse/dept/disp and
     *        *NG license. Only 1 *NG license per whse/dept/disp
     *        should exist. Now set the neglcns field to that license.
650cA*    03/28/13  LMC  6.50c
     *      - Fix: Addition to 650a
     *
650dA*    04/03/13  LMC  6.50d
     *      - Fix: Hold value of $liToLcns in crtneglcns to restore
     *      after the NG license nubmer is generated.
     *
650eA*    06/03/13  LMC  6.50e
     *      - Fix: In ADJSLTQTYSUB check lalcns for *NG, only one *NG
     *      license would exist. The old check for lalcns = neglcns
     *      will never occur, since the *NG license no longer includes
     *      the slot in the license number.
     *      Moved the execution of CrtNegLcns to subr adjSltQtyCrtNeg.
650fA*    06/05/13  LMC  6.50f
     *      - Fix: Mod 650a caused a problem on change items if the
     *      breakdown qty's are not the same. Mod 650a needs the to
     *      slot/item information to determine if the product is
     *      moving into a BFC designated slot.
650gA*    08/23/13  RH   6.50g
     *      - Enh: Write full qty for Transfer/Chg item for base item
     *        to base item in Lic Log Result quantity.
     *
650hA*    12/10/13  RBD  6.50h
     *      - Fix: An inventory adjustment was creating a new license
     *        in a non-date-sensitive overflow slot where a license
     *        already existed ... the adj qty should've been added to
     *        the existing license.  Corrected 650e rev where the subst
     *        for lalcns was looking for an = condition but it should've
     *        been looking for <>.
     *
650iA*    12/23/13  DAS  6.50i
     *      - Fix: Revised to use correct status code for locked records.
650jA*    02/14/01  RH   6.50j
     *      - Fix: Revised adjSltQtyCrtNeg to set entered date=today
     *        like adjSltQtyCrt if $LITOENTD not passed in. Was
     *        creating *NG license with no entered date.
     *
650kA*    05/08/14  LMC  6.50k
     *      - Enh: Added CHKROTATE - routine to send back licactive
     *        data on first license in the slot. This is used in RC200
     *        to determine if user should be notified to rotate stock
     *        to assist in making sure the oldest product is in the
     *        front.
     *
650lA*    05/09/14  LMC  6.50l
     *      - Fix: When changing an Item in a slot using SL252 we were
     *        wiping out the lacode, laarea, and labase fields in
     *        Licactive file. Added logic to check for program SL252
     *        and not replace these fields if the $li* fields are
     *        blank.
650m *    07/28/14  RTR  6.50m
     *      - Enh: When changing an Item from low tracking to medium
     *        or high, this command used to transfer overflow with
     *        *Multiple license to virtual slots. *GETSLTREV
     *
650nA*    12/01/14  DAS  6.50n
     *      - Was 6.40d 6/2/11 change at Eastland.
     *      - Added command *CHGSLTSTS.
     *      - Added routine chgslotstat, vfychgsltstat, wrtLicLogChgStat
     *      - Added new fields to LICLOG file. (already added by 12/1/14)
     *
650oA*    12/01/14  DAS  6.50o
     *      - Was 6.40e 6/2/11 change at Eastland.
     *      - Writing new DRILICENSE parm $liItmChg to log.
     *
650pA*    12/01/14  DAS  6.50p
     *      - Was 6.40f 6/6/11 change at Eastland.
     *      - Added new fields to LICLOG. (already added by 12/1/14)
     *         - Added LLLTRNSEQ, which is a sequence number within a
     *           unique LLLTRN number.
     *         - Added LLFTRN / LLFTRNSEQ to create a link between
     *           the Normal slot From / To log entries for a TFR/RPL
     *           even if the TFR/RPL bombs in the middle.
     *
650q *    11/19/14  KDE  6.50q
     *      - Enh: Create code to write data to Production Log for
     *        select action codes.  This mod requires PRODLOG be
     *        in your files library in order to compile.  No other
     *        requirements are necessary to take this to a customer
     *        box.
     *
700a *    11/25/15  RTR  7.00a
     *      - Enh: Added call to DRILICSNAP for license log snapshot.
     *        This will show the actual license quantities at time of
     *        action for the inquiry screens.
     *
700b *    12/02/15  DLS  7.00b
     *      - Enh: Changed file PRDDATE1 to usropn like PRODLOG.
     *
700c *    04/18/16  LMC  7.00c
     *      - Fix: Breakdown quantities were not getting converted
     *        correctly due to the changes I made on 650a/650f
     *        Reinstated the conversion routine.
700d *    05/10/16  LMC  7.00d
     *      - Fix: Cross Dock licenses were not be loaded to LICACTIVE
     *        *NF LICENSES were being created, but we had no way to
     *        track them back to the original *XD license. They also
     *        were not getting loaded with expiration dates.
     *        So if the client wanted to transfer leftover product out
     *        of the XDK slot, no dates were carried with the product
     *        to the new slot.
700e *    07/12/16  LMC  7.00e
     *      - Reserved - UCI Tracking - New Item tracking level 'U'
710 A*    02/13/17  KDE  7.10
     *      - Added field PLRMUCI.  This field will hold the raw material
     *        UCI used to create a Dry Aged product.  Recompile now but may
     *        need logic change as well
     *      - Enh: Pass raw material UCI for Dry Production
710bA*    02/14/17  RH/LMC  7.10b
     *      - Tfr from pick with multiple license                     ial
     *        and NO new license is applied, was creating multiple *NAt may
     *        license for one slot.  Showing *MULTIPLE                t may
     *        Want to combine qty into one *NA license.               t may
710cA*    02/28/17  KDE     7.10c
     *      - Always take level as mfg line for Prodlog
710dA*    03/15/17  LMC     7.10d
     *      - Added GetClient
710eA*    04/17/17  LMC     7.10e
     *      - Added $license3 - for additional fields.
710fA*    04/21/17  LMC     7.10f
     *      - Added new command to see if a production license already
     *        exist for the same expd/entd dates. If so we can use it.
     *        *CHK4PRLIC command.
     *
710g *    06/02/17  RTR     7.10g
     *      - Reserved for LICADJ changes from A&D.
     *
710h *    07/03/17  LMC     7.10h
     *      - Added command %SETOLCNS
     *
710i *    12/27/17  RTR     7.10i
     *      - Fix for wrong previous LICLOG record when doing a
     *        multi-license transfer.
720a *    10/13/18  RTR     7.20a
     *      - Check for missing employee number in parms, attempt to
     *        look up in user table. Some programs are not passing it.
720b *    07/12/16  LMC     7.20b
     *      - UCI Tracking - New Item tracking level 'U'
720c *    01/10/19  KDE     7.20c
     *      - Change quantities written to Prodlog in certain case
730a *    01/30/19  LMC  7.30a
     *      - Little bit of logic change to uci tracking adjustments
     *        We will now be using the label number to get the link
     *        between the itemadj and the ucilog files for canopy.
     *
730b *    02/21/19  LMC  7.30b
     *      - Type 3&4 uci adjustmetns have been changed we previously
     *        processed it as on single adjustment. But we need to
     *        process each uci independently, for tracking adjustments
     *
730c *    05/08/19  LMC  7.30c
     *      - Revised adjsltqtyadd to use a zero qty license for
     *        program RTC330 (RTC inventory count).
730d *    12/16/19  LMC  7.30d
     *      - Added call to IT726s for real time interface.
730e *    12/26/19  LMC  7.30e
     *      - Need to get real user if BFCGUI*.
740a *    01/30/20  LMC  7.40a
     *      - Enh: reverse the part of 640f modification where we
     *        eliminated WRTLICLOGADJ from subr ADJSLTQTYZERO.
     *        In order to send the proper Hostlot for adjustment
     *        interfaces, we need a liclog record for the correct
     *        License. This came up when an adjustment was made to
     *        the weight only, no quantity was adjusted.
     *        Reinstating the writing of the LICLOG record.
740b *    07/09/20  LMC  7.40b
     *      - Enh: Check laarea for 'Temp' to do the same bypass as
     *        we do on program RTC330. This allows me to reactivate a
     *        license using RF Adjustment if you come thru LP120 and
     *        take the command key to activate(f10).
740c *    07/31/20  LMC  7.40c
     *      - Enh: When creating a special license, Add a check to
     *        make sure the new license doesn't exist in LICINFO.
750a *    07/28/21  LMC  7.50a
     *      - Enh: Added real time interface for returns.
750b *    05/18/20  DAS  7.50b (missed as 740b from CPJ)
     *      - Revised adjsltqtyadd to use a zero qty license for
     *        program WWTFR (Whse to Whse Tfr)
760a *    05/02/22  LMC  7.60a
     *      - Enh: Retrieve original license picked by label#.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
GFC A*    11/01/11  RBD  GFC
     *      - Added new command %ZEROEXPD to set the expiration date
     *        to zero in all licenses for the incoming slot item.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
CBIaA*    03/15/17  LMC  CBIa
     *      - Revised to do update expiration date in licactive.
     *        when transferring product from CLR to FRZ with a
     *        change item on mfg dated item.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R3M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Tracking options
     *
     * Values for trackpos fields:
     *
     *    trackpos     Track slot pallet position (Y/N)
     *
     *    trackposmrg  Putaway merge option
     *                 1 = Only ask for pallet position.
     *                 2 = Direct user step by step.
     *
     *    trackposrtn  Return pallet option
     *                 1 = Assume user returns pallets in LOFI order.
     *                 2 = Direct user step by step.
     *
     * Split Putaway Quantity Options (trackpsplit)
     *
     *   This option comes into play when a user is putting a partial
     *   quantity into a slot. This could either be during Putaway,
     *   Replenishment or Transfer.
     *
     *   1  =  LP goes with first quantity put into a slot.
     *   2  =  LP goes with last quantity put into a slot.
     *   3  =  Ask user.
     *
     * Split Transfer Quantity Options (tracktsplit)
     *
     *   This option comes into play when a user is doing a partial
     *   quantity transfer and will identify how to deal with the
     *   license plate for the quantity that stays in the From slot
     *   vs. the quantity that is being transfered.
     *
     *   1  =  LP stays with remaining quantity in From slot.
     *   2  =  LP goes with partial quantity being transfered.
     *   3  =  Ask user.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-Command Notes
     *
     *      *OPEN        Open program and return.
     *
     *      *CLOSE       Close program with *INLR = *ON
     *
     *      *ADJLCNS     Adjust license qty.
     *
     *      *ADJSLTDTE   Adjust slot rec(s) in date order.
     *
     *      *ADJSLTREV   Adjust slot rec(s) in reverse date order.
     *
610aA*      *CHGDP       Change *DP Directed Putaway license.
     *
600iA*      *CHGSLTFIF   Change FIFO info for slot.
     *
650nA*      *CHGSLTSTS   Log slot status change.
     *
     *      *CHK4EXIST   Check if item exists in base slot.
     *
710fA*      *CHK4PRLIC   Check for production slot - same date.
     *
650kA*      *CHKROTATE   Check need to rotate pallet.
     *
     *      *DELETEITM   Delete all records for an item.
     *
     *      *DELETESLT   Delete all records for a slot.
     *
640aA*      *DLTORPHAN   Delete orphan records.
     *
     *      *DLTSLTITM   Delete all records for a slot/item.
     *
600kA*      *GETINFO     Get info for a license number.
600kA*                   If LICACTIVE not found, get info from
600kA*                   first log record.
     *
760aA*      *GETLABEL    Get info for an original pick label.
     *
     *      *GETLCNS     Get info for a license number.
     *
600cA*      *GETSFGOSS   Special get for SFG. This will get the
600cA*                   first OSS license for an item. This
600cA*                   command is called from IT250.
     *
600hA*      *GETSLTFIF   Get FIFO information for slot.
     *
     *      *GETSLTLIC   Get first FIFO record info for a slot.
     *
     *      *GETSLTQTY   Get total qty for a slot.
     *
650mA*      *GETSLTREV   Get first license in reverse FIFO order.
     *
     *      *TFRLCNS     Transfer license to a new location.
     *
     *      *TFRSLTDTE   Transfer slot rec(s) in date order.
     *
     *      *TFRSLTREV   Transfer slot rec(s) in reverse date order.
     *
600oA*      *SETFIFO     Set (replace) FIFO fields.
     *
     *      *SETLCNS     Set (replace) license info.
     *
600aA*      *SETLCNS0    Set (replace) license info, allow zero qty.
     *
710hA*      *SETOLCNS    Set (replace) Original License & FIFO fields.
     *
600eA*      *NOSTOCK     Write log record for no stock return.
     *
600gA*      *XDK         Write log record for XDK.
     *
GFC A*      *ZEROEXPD         Zero expiration date in all licenses
GFC A*                        for this item.
     *
     *      *ZEROSLOT    Zero all rec(s) for a slot.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flicactive uf a e           k disk
     F                                     infds(file1ds)
     Flicactive1uf   e           k disk
     F                                     infds(file2ds)
     F                                     rename(larec:larec1)
     Flicactive2uf   e           k disk    usropn
     F                                     infds(file3ds)
     F                                     rename(larec:larec2)
     Flicactive3uf   e           k disk    usropn
     F                                     infds(file4ds)
     F                                     rename(larec:larec3)
     Flicactive4uf   e           k disk    usropn
     F                                     infds(file5ds)
     F                                     rename(larec:larec4)
650bAFlicactive5if   e           k disk    usropn
650bAF                                     infds(file6ds)
650bAF                                     rename(larec:larec5)
600kDF*iclog    o  a e           k disk
600kMFliclog    uf a e           k disk
650pAFliclog5   if   e           k disk    rename(llrec:llrec5) prefix(LL5_)
650qAFprodlog   uf a e           k disk    usropn
650qAF                                     infds(file16ds)
650qAFlicinfo   if   e           k disk
650qAfpiritem   if   e           k disk
700b Fprddate1  if   e           k disk    usropn
700b F                                     infds(file7ds)
760aAFliclog2   if   e           k disk    rename(llrec:llrec2) prefix(LL2_)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.drislot
      /copy qcopysrc,p.drislotd
      /copy qcopysrc,p.vfywhse
720bA /copy qcopysrc,p.driuci
710dA /copy qcopysrc,p.getclien
730dA /copy qcopysrc,p.getoptio

710dA*----------------------------------------------------------------
710dA*  Customer id
710dA*----------------------------------------------------------------
710dA
CBIaA /COPY QCOPYSRC,Id#CHENEY
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#SLOTDEF
720bA /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($liver#)
     D save$license    ds                  likeds($license)
     D save$license2   ds                  likeds($license2)
710eAD save$license3   ds                  likeds($license3)
     D toSItem         ds                  likeds($item)
     D frmSItem        ds                  likeds($item)
     D saveSItem       ds                  likeds($item)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(lawhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n
     D driSlotCalled   s               n
     D driSlotDefCalled...
     D                 s               n
720bAD driUCICalled    s               n
     D vfyWhseCalled   s               n

     *----------------------------------------------------------------
     *  Saved record formats
     *----------------------------------------------------------------

     D larecds       e ds                  extname(licactive)
     D frmLAREC        ds                  likeds(larecds)
760aAd lbrec         e ds                  extname(labelw)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

710dAD client          s             10
710dAD clientloc       s             10
     D DakotaCall      s               n
730dAd ExportType      s            117a
600hAD firstNonExp     s               n
600hAD firstRec        s               n
     D frmZero         s               n
     D HostCall        s               n
     D spclLcns        s               n
700dAD xdkLcns         s               n
     D reverseOrder    s               n
     D throwErr        s               n
     D debugnode       s               n   inz(*on)
     D foundLA         s               n
     D frmLcns         s                   like(lalcns)
650dAD hld$liToLcns    s                   like($liToLcns)
     D kybase          s                   like(labase)
     D kycode          s                   like(lacode)
     D kydisp          s                   like(ladisp)
     D kyitem          s                   like(laitem)
     D kylcns          s                   like(lalcns)
     D kypos           s                   like(lapos)
     D kysdef          s                   like($sdcode)
     D kywhdp          s                   like(lawhdp)
     D kywhse          s                   like(lawhse)
     D negLcns         s                   like(lalcns)
720c d prdLogQty1      s              5  0
720c d prdLogQty2      s              5  0
720c d prdLogQty3      s              5  0
     D lockedLA        s               n
     D lowActiveQty    s              9  0
     D lowActualAdj    s              9  0
     D lowFrmAdjustQty...
     D                 s              9  0
     D lowFrmRecQty    s              9  0
     D lowFrmResultQty...
     D                 s              9  0
     D lowllaQty       s              9  0
     D lowToRecQty     s              9  0
600lAD lowRemAdj       s              9  0
     D lowToResultQty...
     D                 s              9  0
     D lowumq2         s                   like($itumq2)
     D lowumq3         s                   like($itumq3)
600lAD ngLowToRecQty   s              9  0
     D nxtltrn#        s              7  0
650pAD nxtltrnSeq      s              2  0
     D openlicactive   s               n
     D openlicactive1  s               n
     D openlicactive2  s               n
     D recCount        s              3  0
     D returnLcns      s                   like($liToLcns)
650pAD saveltrn        s              7  0
650pAD saveltrnSeq     s              2  0
     D saveToLcns      s                   like($liToLcns)
     D tmpFrmAdjustQty...
     D                 s              9  0
     D tmpFrmResultQty...
     D                 s              9  0
600hAD todayYMD        s              8  0
600iAD updFifo         s               n
650pAD usrfltrn        s              7  0
650pAD usrfltrnSeq     s              2  0

     *----------------------------------------------------------------
     *  Data Areas
     *----------------------------------------------------------------

     D pirllp#         s              7  0 dtaara

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds
      /copy qcopysrc,c#file2ds
      /copy qcopysrc,c#file3ds
      /copy qcopysrc,c#file4ds
      /copy qcopysrc,c#file5ds
      /copy qcopysrc,c#file6ds
650qA /copy qcopysrc,c#file16ds
700b  /copy qcopysrc,c#file7ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata
     C                   parm                    $pdata2
710eAC                   parm                    $pdata3

      /free
         $license = $pdata;
         if %parms >=6;
           $license2 = $pdata2;
         endif;
710eA    if %parms >=7;
710eA      $license3 = $pdata3;
710eA    endif;
         $preturn = '*OK';
         $pmessage = ' ';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       dou 1=1; //bottom

         // See which system is calling the program.

         if %subst($psubcmd:1:1) = '%';
           DakotaCall = *on;
           HostCall = *off;
           %subst($psubcmd:1:1) = '*';
         else;
           HostCall = *on;
           DakotaCall = *off;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             $preturn = '*OK';
             $pmessage = ' ';
             leave; //bottom

           when $psubcmd = '*CLOSE';
             $preturn = '*OK';
             $pmessage = ' ';
             exsr aaaclose;
             *inlr = *on;
             leave; //bottom

         endsl;

         // Otherwise, do some initialization and move on.

         exsr aaainit;
         error = *off;
730eA    if %subst(#curruser:1:6) = 'BFCGUI' and $liuser <> ' ' or
730eA       %subst(#curruser:1:3) = 'MRC' and $liuser <> ' ';
730eA      #curruser = $liuser;
730eA    endif;

         // Do what user has requested.

         select;

           when $psubcmd = '*ADJSLTDTE'
                or $psubcmd = '*ADJSLTREV';
             exsr vfyadjsltqty;
             if not error;
               exsr getltrn;
               exsr adjsltqty;
600lA          exsr fixNGLcns;
600hA          exsr getsltfifo;
             endif;

610aA      when $psubcmd = '*CHGDP';
610aA        exsr vfychgdp;
610aA        if not error;
610aA          exsr getltrn;
610aA          exsr chgdp;
610aA        endif;

600iA      when $psubcmd = '*CHGSLTFIF';
600iA        exsr vfychgsltfifo;
600iA        if not error;
               exsr getltrn;
600iA          exsr chgsltfifo;
600iA          exsr getsltfifo;
600iA        endif;

650nA      when $psubcmd = '*CHGSLTSTS';
650nA        exsr vfychgsltstat;
650nA        if not error;
650nA          exsr getltrn;
650nA          exsr chgsltstat;
650nA        endif;

           when $psubcmd = '*CHK4EXIST';
             exsr vfychk4exist;
             if not error;
               exsr chk4exist;
             endif;
710fA      when $psubcmd = '*CHK4PRLIC';
710fA        exsr vfychk4prlic;
710fA        if not error;
710fA          exsr chk4prlic;
710fA        endif;


650kA      when $psubcmd = '*CHKROTATE';
650kA        exsr vfychk4exist;
650kA        if not error;
650kA          exsr chkrotate;
650kA        endif;

           when $psubcmd = '*DELETEITM';
             exsr vfydeleteitm;
             if not error;
               exsr getltrn;
               exsr deleteitm;
             endif;

           when $psubcmd = '*DELETESLT';
             exsr vfydeleteslt;
             if not error;
               exsr getltrn;
               exsr deleteslt;
             endif;

640aA      when $psubcmd = '*DLTORPHAN';
640aA        exsr vfydltorphan;
640aA        if not error;
640aA          exsr getltrn;
640aA          exsr dltorphan;
640aA        endif;

           when $psubcmd = '*DLTSLTITM';
             exsr vfydltsltitm;
             if not error;
               exsr getltrn;
               exsr dltsltitm;
             endif;

760aA      when $psubcmd = '*GETLABEL';
760aA        exsr vfygetlabel;
760aA        if not error;
760aA          exsr getlabel;
760aA        endif;

           when $psubcmd = '*GETLCNS';
             exsr vfygetlcns;
             if not error;
               exsr getlcns;
600hA          if not error;
600hA            exsr getsltfifo;
600hA          endif;
             endif;

600kA      when $psubcmd = '*GETINFO';
600kA        exsr vfygetlcns;
600kA        if not error;
600kA          exsr getinfo;
600kA          if not error;
600kA            exsr getsltfifo;
600kA          endif;
600kA        endif;

600cA      when $psubcmd = '*GETSFGOSS';
600cA        exsr vfygetsfgoss;
600cA        if not error;
600cA          exsr getsfgoss;
600cA        endif;

600hA      when $psubcmd = '*GETSLTFIF';
600hA        exsr vfygetsltfifo;
600hA        if not error;
600hA          exsr getsltfifo;
600hA        endif;

           when $psubcmd = '*GETSLTLIC'
650mA           or $psubcmd = '*GETSLTREV';
             exsr vfygetsltlic;
             if not error;
               exsr getsltlic;
600hA          exsr getsltfifo;
             endif;

           when $psubcmd = '*GETSLTQTY';
             exsr vfygetsltqty;
             if not error;
               exsr getsltqty;
             endif;

600oA      when $psubcmd = '*SETFIFO';
             exsr vfySetLicFifo;
             if not error;
610eD          //exsr getsltfifo;
640hA          exsr getltrn;
               exsr setfifo;
610eA          exsr getsltfifo;
             endif;

           when $psubcmd = '*SETLCNS'
             or $psubcmd = '*SETLCNS0';
             exsr vfysetlcns;
             if not error;
               exsr getltrn;
               exsr setlcns;
600hA          exsr getsltfifo;
             endif;

710hA      when $psubcmd = '*SETOLCNS';
710hA        exsr vfySetOLicFifo;
710hA        if not error;
710hA          exsr getltrn;
710hA          exsr setOlcnsfifo;
710hA          exsr getsltfifo;
710hA        endif;

           when $psubcmd = '*TFRLCNS';
             exsr vfytfrlcns;
             if not error;
               exsr getltrn;
               exsr tfrlcns;
             endif;

           when $psubcmd = '*TFRSLTDTE'
                or $psubcmd = '*TFRSLTREV';
             exsr vfytfrsltdte;
             if not error;
               exsr getltrn;
               exsr tfrsltdte;
600lA          exsr fixNGLcns;
600hA          exsr getsltfifo;
             endif;

GFC A      when $psubcmd = '*ZEROEXPD';
GFC A        exsr vfydeleteitm;
GFC A        if not error;
GFC A          exsr zeroLicExp;
GFC A        endif;

           when $psubcmd = '*ZEROSLOT';
             exsr vfydeleteslt;
             if not error;
               exsr getltrn;
               exsr deleteslt;
             endif;

600eA      when $psubcmd = '*NOSTOCK';
600eA        exsr getltrn;
600eA        exsr noStock;

600gA      when $psubcmd = '*XDK';
600gA        exsr getltrn;
600gA        exsr xdk;

           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;

       enddo; //bottom

       // We are finished so get out

       $pdata = $license;
       if %parms >=6;
         $pdata2 = $license2;
       endif;
710eA  if %parms >=7;
710eA    $pdata3 = $license3;
710eA  endif;
       return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
710dA /free
710dA   getclient(client: clientLoc);
710dA /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

      /free
       begsr aaainit;

600nA    // Initialize LicActive fields in case a record is not found.
600nA
600nA    clear larec;
600nA
600nA    lawhse = $liToWhse;
600nA    lalcns = $liToLcns;
600nA
600nA    if $liOLcnsU;
600nA      laolcns = $liOLcns;
600nA    else;
600nA      laolcns = $liToLcns;
600nA    endif;
600nA
600nA    if $liToCodeU;
600nA      lacode = $liToCode;
600nA    endif;
600nA
600nA    if $liToAreaU;
600nA      laarea = $liToArea;
600nA    endif;
600nA
600nA    if $liToWhdpU;
600nA      lawhdp = $liToWhdp;
600nA    endif;
600nA
600nA    if $liToDispU;
600nA      ladisp = $liToDisp;
600nA    endif;
600nA
600nA    if $liToAislU;
600nA      laaisl = $liToAisl;
600nA    endif;
600nA
600nA    if $liToLocU;
600nA      laloc = $liToLoc;
600nA    endif;
600nA
600nA    if $liToRlvlU;
600nA      larlvl = $liToRlvl;
600nA    endif;
600nA
600nA    if $liToHandU;
600nA      lahand = $liToHand;
600nA    endif;
600nA
600nA    if $liToBaseU;
600nA      labase = $liToBase;
600nA    endif;
600nA
600nA    if $liToPosU;
600nA      lapos = $liToPos;
600nA    endif;
600nA
600nA    if $liToItemU;
600nA      laitem = $liToItem;
600nA    endif;
600nA
600nA    if $liToITypeU;
600nA      laitype = $liToIType;
600nA    endif;
600nA
600nA    if $liToSItemU;
600nA      lasitem = $liToSItem;
600nA    endif;
600nA
600nA    if $liToSITypeU;
600nA      lasitype = $liToSIType;
600nA    endif;
600nA
600nA    if $liToPrtyU;
600nA      laPrty = $liToPrty;
600nA    endif;
600nA
600nA    if $liToEntDU;
600nA      laentd = $liToEntD;
600nA    endif;
600nA
600nA    if $liToExpDU;
600nA      laexpd = $liToExpD;
600nA    endif;
600nA
600nA    if $liToOrdU;
600nA      laord = $liToOrd;
600nA    endif;
600nA
600nA    if $liToSeqU;
600nA      laseq = $liToSeq;
600nA    endif;
720cA    prdLogQty1 = *zeros;
720cA    prdLogQty2 = *zeros;
720cA    prdLogQty3 = *zeros;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

      /free
       begsr aaaclose;

         if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
         endif;

         if driSlotCalled;
           driSlot('%CLOSE': $pprogram: $drireturn: $drimessage:
                             $dridata: $dridata2);
         endif;

         if driSlotDefCalled;
           driSlotDef('%CLOSE': $pprogram: $drireturn: $drimessage: $dridata);
         endif;

         if vfyWhseCalled;
           vfyWhse('*CLOSE': '*NONE': $vwhse: $vdesc:
                   $vreturn: $vmessage: $vmsgk);
         endif;

720bA    if driUCICalled;
720bA      driuciinfo('%CLOSE': $pprogram: $drireturn: $drimessage:
720bA               $dridata: $dridata2);
720bA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQty  Adjust qty for a slot/item
     *----------------------------------------------------------------

      /free
       begsr adjSltQty;

         // Create negative license number for slot.

650eD    //exsr crtNegLcns;

         if $psubcmd = '*ADJSLTREV';
           reverseOrder = *on;
         else;
           reverseOrder = *off;
         endif;

         // For clean up purposes, delete any active recs that don't
         // have matching item for slot.

         kywhse = $liToWhse;
         kywhdp = $liToWhdp;
         kydisp = $liToDisp;
         kyitem = $liToSItem;
         exsr deletewrgitm;

         // Calculate low value of incoming qtys.

         exsr calcLowTo;

         // Calculate low qty of records for slot/item.

         exsr sumSlot;

         // Calc adj from current active qty to new result qty.

         lowActualAdj = lowToResultQty - lowActiveQty;

         // Call appropriate routine.

         select;

           // Need to increase active rec(s) to match new result.

           when lowActualAdj > 0;
             exsr adjSltQtyAdd;

           // Need to decrease active rec(s) to match new result.

           when lowActualAdj < 0;
             exsr adjSltQtySub;

           // Don't need to do anything to match new result.

           other;
             exsr adjSltQtyZero;

         endsl;

         // If new result qty is zero,
         //   then delete any current active recs for slot.

         if lowToResultQty = 0;
           exsr deleteslt;
         endif;

730dA    // check to see if Real time interface should execute
730dA    exsr zzrti;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQtyAdd  Increase slot qty of Slot/Item
     *----------------------------------------------------------------

      /free
       begsr adjSltQtyAdd;

         // Loop through all records for slot/item in picking order.

         if reverseOrder;
           setgt ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;
         else;
           setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;
         endif;

         dow forever = forever;

           if reverseOrder;
             readpe ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                    licactive1;
           else;
             reade ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                   licactive1;
           endif;

           if %eof(licactive1);
             leave;
           endif;

710fA      // for uci track items - we are looking for a specific
710fA      // license to update. This license is passed in $litolcns
710fA      if $litolcns <> ' ' and $imltrk = 'U' and
710fA         $litolcns <> lalcns;
710fA        iter;
710fa      endif;
           select;

             // Igonore active recs with zero qty. The will be deleted below.
             // In theory, there shouldn't be any at this point.
600aA        // Allow zero qty for OSS slot.
610bA        // Allow zero qty for Action CNT (cycle count)
610bA        // Allow zero qty for Action INV (inventory count)
730cA        // Allow zero qty for program RTC330 (RTC inventory)
750bA        // Allow zero qty for program WWTFR (Whse to Whse Tfr)

610bD        //when laQty1 = 0 and laQty2 = 0 and laQty3 = 0 and laAisl <> 'OSS'
610bM        when laQty1 = 0 and laQty2 = 0 and laQty3 = 0 and laAisl <> 'OSS'
730cA         and $pprogram <> 'RTC330'
750bA         and $pprogram <> 'WWTFR'
740bA         and laarea    <> 'Temp'
610bA          and $liAction <> 'CNT' and $liAction <> 'INV';
                 lowllAQty = 0;
                 // ignore

             // If negative license found ...

650eD        //when laLcns = negLcns;
650eM        when %subst(lalcns:1:3) = '*NG';

                 // Igonore negative license that has positive qty.
                 // In therory, this shouldn't occur.

                 if laQty1 > 0 or laQty2 > 0 or laQty3 > 0;
                   iter;
                 endif;

                 // Turn laqty's to positive

                 laqty1 = -(laqty1);
                 laqty2 = -(laqty2);
                 laqty3 = -(laqty3);

                 exsr calcToLowRecQty;

                 // If active rec has plenty of qty,
                 // Reduce it by adjustment qty.

                 if lowToRecQty >= lowActualAdj;

                   lowToRecQty -= lowActualAdj;
                   lowllAQty = lowActualAdj;
                   lowActualAdj = 0;

                 // Otherwise, active rec doesn't have enough qty,
                 // Reduce active rec to zero.

                 else;

                   lowActualAdj -= lowToRecQty;
                   lowllAQty = lowToRecQty;
                   lowToRecQty = 0;

                 endif;

                 exsr upToRecQty;

                 // Turn laqty's back to negative

                 laqty1 = -(laqty1);
                 laqty2 = -(laqty2);
                 laqty3 = -(laqty3);

             // When license is not a negative license ...

650eD        //when laLcns <> negLcns;
650hD        //when %subst(lalcns:1:3) = '*NG';
650hM        when %subst(lalcns:1:3) <> '*NG';

                 // Add entire adjustment qty to record.

                 exsr calcToLowRecQty;
                 lowToRecQty += lowActualAdj;
                 lowllAQty = lowActualAdj;
                 lowActualAdj = 0;
                 exsr upToRecQty;

           endsl;

           exsr upTollAQty;

           // Delete active record if all qtys are zero.

610fD      //if lowToRecQty = 0;
610fM      if laQty1=0 and laQty2=0 and laQty3=0;

             llexcd  = 'DELZRO';
             exsr wrtLicLogAdj;
             delete larec1;

           // Otherwise, update record.

           else;

             exsr wrtLicLogAdj;
             exsr updateLA1;

           endif;
720bA      // UCI Tracking
720bA      if $imltrk = 'U';
720bA        exsr updateUCI;
720bA      endif;

         enddo;

         // If adjustment qty still left, create new active record.

         if lowActualAdj > 0;
           exsr adjSltQtyCrt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQtyCrt    Create record for left over adj qty
     *----------------------------------------------------------------

      /free
       begsr adjSltQtyCrt;

         exsr chk4SpclLcns;
700dA    exsr chk4xdkLcns;
700dA    if not xdkLcns;
           if not spclLcns;
             $liToLcns = '*NF';
             // Set entered date for *NF
             if $liToEntDU = *off;
               $liToEntDU = *on;
               $liToEntD = todayymd;
             endif;
           endif;
700dA    endif;

         lowllAQty = lowActualAdj;
         exsr upTollAQty;

         // Convert qty if necessary (i.e. when going from ' ' to 'B')

         exsr cvtllAQty;

         // Set quantity

         $liToRQty1 = llAQty1;
         $liToRQty2 = llAQty2;
         $liToRQty3 = llAQty3;
720cA    prdLogQty1 = llAqty1;
720cA    prdLogQty2 = llAqty2;
720cA    prdLogQty3 = llAqty3;

         // Create license

         exsr setLcns;

         if returnLcns = ' ';
           returnLcns = $liToLcns;
         else;
           returnLcns = '*MULTIPLE';
         endif;
720bA    // UCI Tracking
720bA    if $imltrk = 'U';
720bA      exsr updateUCI;
720bA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQtyCrtNeg  Create negative record for left over adj qty
     *----------------------------------------------------------------

      /free
       begsr adjSltQtyCrtNeg;

650eA    exsr crtNegLcns;
         $liToLcns = negLcns;
650jA      // Set entered date for *NG
650jA      if $liToEntDU = *off;
650jA        $liToEntDU = *on;
650jA        $liToEntD = todayymd;
650jA      endif;

         lowllAQty = lowActualAdj;
         exsr upTollAQty;

         // Convert qty if necessary (i.e. when going from ' ' to 'B')

         exsr cvtllAQty;

         // Reverse log qty

         llaqty1 = -(llaqty1);
         llaqty2 = -(llaqty2);
         llaqty3 = -(llaqty3);
720cA    prdLogQty1 = llaqty1;
720cA    prdLogQty2 = llaqty2;
720cA    prdLogQty3 = llaqty3;

         // Set result qty

         $liToRQty1 = llAQty1;
         $liToRQty2 = llAQty2;
         $liToRQty3 = llAQty3;

         // Create license

         exsr setLcns;

         if returnLcns = ' ';
           returnLcns = $liToLcns;
         else;
           returnLcns = '*MULTIPLE';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQtySub  Decrease slot qty of Slot/Item
     *----------------------------------------------------------------

      /free
       begsr adjSltQtySub;

         // Change negative adjustment qty into a positive qty.

         lowActualAdj = %abs(lowActualAdj);

         // Loop through all records for slot/item in picking order.

         if reverseOrder;
           setgt ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;
         else;
           setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;
         endif;

         dow forever = forever;

           if reverseOrder;
             readpe ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                    licactive1;
           else;
             reade ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                   licactive1;
           endif;

           if %eof(licactive1);
             leave;
           endif;

710fA      // for uci track items - we are looking for a specific
710fA      // license to update. This license is passed in $litolcns
710fA      if $litolcns <> ' ' and $imltrk = 'U' and
710fA         $litolcns <> lalcns;
710fA        iter;
710fa      endif;

           // Calculate record qty

           exsr calcToLowRecQty;

           select;

             // Igonore active recs with zero qty. The will be deleted below.
             // In theory, there shouldn't be any at this point.

             when lowToRecQty = 0;
               lowllAQty = 0;
               // ignore

             // If negative license found, just reduce it.
             // In theory, a negative license for a slot should be
             // the only licactive record for the slot.

650eD        //when laLcns = negLcns;
650eM        when %subst(lalcns:1:3) = '*NG';
               lowToRecQty -= lowActualAdj;
               lowllAQty = lowActualAdj;
               lowActualAdj = 0;

             // If active rec has plenty of qty,
             // Reduce it by adjustment qty.

             when lowToRecQty > lowActualAdj;
               lowToRecQty -= lowActualAdj;
               lowllAQty = lowActualAdj;
               lowActualAdj = 0;

             // If active rec doesn't have enough qty,
             // Reduce active rec to zero.

             when lowToRecQty <= lowActualAdj;
               lowActualAdj -= lowToRecQty;
               lowllAQty = lowToRecQty;
               lowToRecQty = 0;

           endsl;

           exsr upToRecQty;

           exsr upTollAQty;

           llaqty1 = -(llaqty1);
           llaqty2 = -(llaqty2);
           llaqty3 = -(llaqty3);

           // Update active record.

610fD      //if lowToRecQty = 0;
610fM      if laQty1=0 and laQty2=0 and laQty3=0;

             llexcd  = 'DELZRO';
             exsr wrtLicLogAdj;
             delete larec1;

           else;

             exsr wrtLicLogAdj;
             exsr updateLA1;

           endif;
720bA      // UCI Tracking
720bA      if $imltrk = 'U';
720bA        exsr updateUCI;
720bA      endif;

           if lowActualAdj <= 0;
             leave;
           endif;

         enddo;

         // If adjustment qty still left, create new active record.

         if lowActualAdj > 0;
           exsr adjSltQtyCrtNeg;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  adjSltQtyZero  No adjustment needed - Result Qty = Slot Qty
     *----------------------------------------------------------------

      /free
       begsr adjSltQtyZero;

         if $liAction <> 'FIX'
            and $liAction <> 'IMP'
            and $liAction <> 'SU';

              llexcd  = 'ZROADJ';
640fA    // remove this exsr - determined it is not needed
640fD         //exsr wrtLicLogAdj;
740aM         exsr wrtLicLogAdj;

         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  calcLowFrm  Calculate low From Adjust/Result qty's
     *----------------------------------------------------------------

      /free
       begsr calcLowFrm;

         if frmSItem.$itumq2 <= 0;
           lowumq2 = 1;
         else;
           lowumq2 = frmSItem.$itumq2;
         endif;

         if frmSItem.$itumq3 <= 0;
           lowumq3 = 1;
         else;
           lowumq3 = frmSItem.$itumq3;
         endif;

         lowFrmAdjustQty = ($liAQty1 * lowumq2 * lowumq3)
                         + ($liAqty2 * lowumq3)
                         + $liAqty3;

         lowFrmResultQty = ($liFrmRQty1 * lowumq2 * lowumq3)
                         + ($liFrmRqty2 * lowumq3)
                         + $liFrmRQty3;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  calcLowTo  Calculate low TO Result qty
     *----------------------------------------------------------------

      /free
       begsr calcLowTo;

         if toSItem.$itumq2 <= 0;
           lowumq2 = 1;
         else;
           lowumq2 = toSItem.$itumq2;
         endif;

         if toSItem.$itumq3 <= 0;
           lowumq3 = 1;
         else;
           lowumq3 = toSItem.$itumq3;
         endif;

         lowToResultQty = ($liToRQty1 * lowumq2 * lowumq3)
                        + ($liToRqty2 * lowumq3)
                        + $liToRQty3;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  calcFrmLowRecQty   Calc low rec qty using From item values
     *----------------------------------------------------------------

      /free
       begsr calcFrmLowRecQty;

         if frmSItem.$itumq2 <= 0;
           lowumq2 = 1;
         else;
           lowumq2 = frmSItem.$itumq2;
         endif;

         if frmSItem.$itumq3 <= 0;
           lowumq3 = 1;
         else;
           lowumq3 = frmSItem.$itumq3;
         endif;

         lowFrmRecQty = (laqty1 * lowumq2 * lowumq3)
                      + (laqty2 * lowumq3)
                      + laqty3;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  calcToLowRecQty   Calc low rec qty using To item values
     *----------------------------------------------------------------

      /free
       begsr calcToLowRecQty;

         if toSItem.$itumq2 <= 0;
           lowumq2 = 1;
         else;
           lowumq2 = toSItem.$itumq2;
         endif;

         if toSItem.$itumq3 <= 0;
           lowumq3 = 1;
         else;
           lowumq3 = toSItem.$itumq3;
         endif;

         lowToRecQty = (laqty1 * lowumq2 * lowumq3)
                     + (laqty2 * lowumq3)
                     + laqty3;

       endsr;
      /end-free

610aA*----------------------------------------------------------------
610aA*  chgdp    Change *DP Directed Putaway license
610aA*----------------------------------------------------------------
610aA
610aA /free
610aA  begsr chgdp;

         // Get record for Old license

         kywhse = $liToWhse;
         kylcns = $liFrmOldLcns;
         lock = *on;
         throwErr = *on;
         exsr getlicactive;
         if error;
           leavesr;
         endif;

         // Update the license numbers

         lalcns = $liToLcns;
         laolcns = $liOLcns;

         exsr getcurrstamp;
         lachgts = currstampsys;
         lachguc = currstampuc;
         lachgpgm = #pgm;
         lachgemp = $liemp#;
         lachgeusr = $liuser;
         lachgcusr = #curruser;
         lachgjusr = #user;
         lachgjob = #job;
         lachgnbr = #jobnbr;

         // First write log record

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         exsr wrtliclog;

         // Then update licactive record

         update(e) larec;
         if %error;
           llexcd = 'LAUPDERR';
           exsr wrtliclog;
         endif;

       endsr;
      /end-free

600iA*----------------------------------------------------------------
600iA*  chgsltfifo   Change FIFO information for slot
600iA*----------------------------------------------------------------
600iA
600iA /free
600iA  begsr chgsltfifo;

         // Loop through records for slot in priority order

         firstRec = *on;
         setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
               licactive1;

         dow forever = forever;

           updFifo = *off;
           reade ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;

           if %eof(licactive1);
             leave;
           endif;

           // Only change priority of first record

           if laprty <> $liToPrty;
             if firstRec;
               laprty = $liToPrty;
               updFifo = *on;
             endif;
           endif;

           // Change expiration date ...
           //   If current date is different than new date
           //      And first record or current date comes before new date

           if laexpd <> $liToExpd;
             if firstrec or laexpd < $liToExpd;
               laexpd = $liToExpd;
               updFifo = *on;
             endif;
           endif;

           // Change entered date ...
           //   If current date is different than new date
           //      And first record or current date comes before new date

           if laentd <> $liToEntd;
             if firstrec or laentd < $liToEntd;
               laentd = $liToEntd;
               updFifo = *on;
             endif;
           endif;

           // Update record if a change was made.

           if updFifo;
             exsr updateChgFlds;
             update(e) larec1;
             llexcd  = 'CHGFIFO';
             exsr wrtLicLogChgFifo;
           endif;

           firstRec = *off;

         enddo;

       endsr;
      /end-free

650nA*----------------------------------------------------------------
650nA*  chgsltstat   Log slot status change
650nA*----------------------------------------------------------------
650nA
650nA /free
650nA  begsr chgsltstat;

         // Loop through records for slot

         setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
               licactive1;

         dow forever = forever;

           reade ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;

           if %eof(licactive1);
             leave;
           endif;

           // Log change.

           llexcd  = 'CHGFIFO';
           exsr wrtLicLogChgStat;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  chk4exist  Check if slot item already exists in base slot.
     *----------------------------------------------------------------

      /free
       begsr chk4exist;

         // Open licactive3 file

         exsr fileOpenLA3;
         if error;
             leavesr;
         endif;

         // Get first licactive record for slot

         setll ($liToWhse: $liToWhdp: $liToBase: $liToSItem)
               licactive3;

         dow forever = forever;
             reade ($liToWhse: $liToWhdp: $liToBase: $liToSItem)
                   licactive3;

             if %eof(licactive3);
                 $preturn = 'NOTFOUND';
                 leavesr;
             endif;

             select;
                 when lapos = $liTopos;
                     if $preturn = 'FOUNDDIFF';
                         $preturn = 'FOUNDBOTH';
                         leave;
                     else;
                         $preturn = 'FOUNDSAME';
                     endif;
                 when lapos <> $liTopos;
                     if $preturn = 'FOUNDSAME';
                         $preturn = 'FOUNDBOTH';
                         leave;
                     else;
                         $preturn = 'FOUNDDIFF';
                     endif;
             endsl;

         enddo;

       endsr;
      /end-free

710fA*----------------------------------------------------------------
710fA*  chk4PRLic  Check if production item exists in slot same date
710fA*----------------------------------------------------------------

710fA /free
710fA  begsr chk4PRLic;

710fA    // Open licactive5 file

710fA    exsr fileOpenLA5;
710fA    if error;
710fA      leavesr;
710fA    endif;

710fA    // Get first licactive record for slot

710fA    chain ($liToWhse: $liToWhdp: $liToDisp: $liToSItem:
710fA           $liToExpd: $liToEntd)
710fA          licactive5;

710fA        if not %found(licactive5);
710fA          $preturn = 'NOTFOUND';
710fA        else;
710fA          $liToLcns =  lalcns;
710fA        endif;

710fA  endsr;
710fA /end-free

650kA*----------------------------------------------------------------
650kA*  chkrotate  Check the need to rotate pallets in overflow.
650kA*----------------------------------------------------------------

650kA /free
650kA  begsr chkrotate;

650kA    // Open licactive3 file

650kA    exsr fileOpenLA3;
650kA    if error;
650kA        leavesr;
650kA    endif;

650kA    // Get first licactive record for slot

650kA    setll ($liToWhse: $liToWhdp: $liToBase: $liToSItem)
650kA          licactive3;

650kA    dow forever = forever;
650kA        reade(N) ($liToWhse: $liToWhdp: $liToBase: $liToSItem)
650kA              licactive3;

650kA        if %eof(licactive3);
650kA            $preturn = 'NOTFOUND';
650kA            leavesr;
650kA        else;
650kA          exsr larec2ds;
650kA          leavesr;
650kA        endif;

650kA    enddo;

650kA  endsr;
650kA /end-free

     *----------------------------------------------------------------
     *  chk4SpclLcns   Check for special license number
     *----------------------------------------------------------------

      /free
       begsr chk4SpclLcns;

         // First character has to be '*'
         // Next 2 characters cannot be blank
         // The rest of the characters must be blank
         // (i.e. '*NT            ')

         if %subst($liToLcns:1:1) = '*'
            and %subst($liToLcns:2:1) <> ' '
            and %subst($liToLcns:3:1) <> ' '
            and %subst($liToLcns:4:12) = ' ';
              spclLcns = *on;
         else;
              spclLcns = *off;
         endif;

       endsr;
      /end-free

700dA*----------------------------------------------------------------
700dA*  chk4xdkLcns    Check for Cross Dock license number
700dA*----------------------------------------------------------------

700dA /free
700dA  begsr chk4xdkLcns;

700dA    // First 3 characters has to be '*XD'

700dA    if %subst($liToLcns:1:3) = '*XD';
700dA         xdkLcns = *on;
700dA    else;
700dA         xdkLcns = *off;
700dA    endif;

700dA  endsr;
700dA /end-free

     *----------------------------------------------------------------
     *  crtNegLcns   Create negative license number
     *
     *    A special "negative" license number will be used to contain
     *    a negative qty associated with a slot. The license number
     *    will be a combination of '*NG' and the slot number, like
     *    '*NGDA-101-1'.
     *
     *    In theory, the only negative qty's in the LICACTIVE file
     *    should be associated with a '*NG' license.
     *
650bA*    This is changed to use our normal special license process
     *
     *----------------------------------------------------------------

      /free
       begsr crtNegLcns;

650dA    hld$liToLcns = $liToLcns;
650bA    $liToLcns = '*NG';
650bA    exsr crtspcllcns;
650bD    //negLcns = '*NG' + %trim($liToDisp);
650bM    negLcns = $liToLcns;
650dA    $liToLcns = hld$liToLcns;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  crtSpclLcns   Create special license number
     *----------------------------------------------------------------

      /free
       begsr crtSpclLcns;

         for i = 1 to 9999999;
           in(e) *lock pirllp#;
           if %error;
             error = *on;
             $preturn = 'PIRLLP#ERR';
             $pmessage = 'Error opening PIRLLP# data area';
             leave;
           endif;

           kylcns = %trim($liToLcns) + %editc(pirllp#:'X');

           pirllp# += 1;
           out pirllp#;

           kywhse = $liToWhse;
           lock = *off;
           throwErr = *off;
           exsr getlicactive;
           if not foundLA;
740cA        // also check licinfo to make sure license does not exist
740ca        chain (kywhse: kylcns) licinfo;
740cA        if %found(licinfo);
740cA          iter;
740cA        endif;
             $liToLcns = kylcns;
             spclLcns = *on;
             leave;
           endif;

         endfor;

         if foundLA;
           error = *on;
           $preturn = 'SPCLCODERR';
           $pmessage = 'License could not be created for '
                      + %subst($liToLcns:1:3);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  cvtllAQty   Convert llAQty if necessary
     *----------------------------------------------------------------

      /free
       begsr cvtllAQty;

640cA    // Get out if action is 'CHG'.
640cA
640cA    if $liAction = 'CHG';
640cA      leavesr;
640cA    endif;

         // Adjust qty when changing item type

         select;

           // Going from Normal item to Breakdown

           when frmSItem.$ittype = ' '
                and (toSItem.$ittype = 'B' or toSItem.$ittype = 'S');

                  if frmSItem.$itumq2 <= 0;
                    lowumq2 = 1;
                  else;
                    lowumq2 = frmSItem.$itumq2;
                  endif;

                  if frmSItem.$itumq3 <= 0;
                    lowumq3 = 1;
                  else;
                    lowumq3 = frmSItem.$itumq3;
                  endif;

                  llaqty1 = (llaqty1*lowumq2) + llaqty2;
                  llaqty2 = (llaqty2*lowumq3);
                  llaqty3 = 0;

           // Going from Breakdown item to Normal

           When (frmSItem.$ittype = 'B' or frmSItem.$ittype = 'S')
                and toSItem.$ittype = ' ';

                  llaqty3 = llaqty2;
                  llaqty2 = llaqty1;
                  llaqty1 = 0;
                  exsr fixbrkdnllaqty;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteItm     Delete all LICACTIVE records for a slot item
     *----------------------------------------------------------------

      /free
       begsr deleteItm;

         kyWhse = $liToWhse;
         kyItem = $liToSItem;

         // Open licactive2 file

         exsr fileOpenLA2;
         if error;
             leavesr;
         endif;

         setll (kywhse: kyitem) licactive2;

         dow forever = forever;

           reade (kywhse: kyitem) licactive2;
           if %eof(licactive2);
             leave;
           endif;

           llaqty1 = -(laQty1);
           llaqty2 = -(laQty2);
           llaqty3 = -(laQty3);
           laqty1  = 0;
           laqty2  = 0;
           laqty3  = 0;

           llExcd  = 'DLTITEM';
           exsr wrtliclogAdj;

           delete larec2;

       enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteLA    Delete specific licactive record
     *----------------------------------------------------------------

      /free
       begsr deleteLA;

         delete    (lawhse: lalcns) licactive;
         if %error;
           llexcd = 'DELLAERR';
           exsr wrtliclog;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteSlt     Delete all LICACTIVE records for a slot
     *----------------------------------------------------------------

      /free
       begsr deleteSlt;

         kyWhse = $liToWhse;
         kyWhdp = $liToWhdp;
         kyDisp = $liToDisp;

         setll (kyWhse: kyWhdp: kyDisp) licactive1;

         dow forever = forever;

           reade (kyWhse: kyWhdp: kyDisp) licactive1;
           if %eof(licactive1);
             leave;
           endif;

           llaqty1 = -(laQty1);
           llaqty2 = -(laQty2);
           llaqty3 = -(laQty3);
           laqty1  = 0;
           laqty2  = 0;
           laqty3  = 0;

           llExcd  = 'DLTSLOT';
           exsr wrtliclogAdj;

           delete larec1;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteWrgItm   Delete all LICACTIVE records for a slot
     *                 that don't match the sent item.
     *----------------------------------------------------------------

      /free
       begsr deleteWrgItm;

         setll (kyWhse: kyWhdp: kyDisp) licactive1;

         dow forever = forever;

           reade (kyWhse: kyWhdp: kyDisp) licactive1;
           if %eof(licactive1);
             leave;
           endif;

           if laSItem = KyItem;
             iter;
           endif;

           if laQty1 <> 0 or laQty2 <> 0 or laQty3 <> 0;
             llaqty1 = -(laqty1);
             llaqty2 = -(laqty2);
             llaqty3 = -(laqty3);
             laqty1  = 0;
             laqty2  = 0;
             laqty3  = 0;
           endif;

           llexcd  = 'DLTWRGIT';
           exsr wrtliclogAdj;

           delete larec1;

         enddo;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  dltOrphan      Delete orphaned LICACTIVE records for whdp/slot
640aA*                 sent in.
640aA*----------------------------------------------------------------
640aA
640aA /free
640aA  begsr dltOrphan;

         kyWhse = $liToWhse;
         kyWhdp = $liToWhdp;
         kyDisp = $liToDisp;

         sqlStmt = 'select * '
640dM            + 'from licactive as a '
                 + 'where lawhse = ' + %char(kyWhse);

         select;
           when kyWhdp <> ' ' and kyDisp <> ' ';
             sqlStmt = %trimr(sqlStmt) + ' '
                     + 'and lawhdp = ' + sq + %trimr(kywhdp) + sq
                     + 'and ladisp = ' + sq + %trimr(kydisp) + sq;
           when kyWhdp <> ' ';
             sqlStmt = %trimr(sqlStmt) + ' '
                     + 'and lawhdp = ' + sq + %trimr(kywhdp) + sq;
         endsl;

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'and not exists (select sldisp from slot where '
640dM            +       'slwhse=a.lawhse and slwhdp=a.lawhdp '
640dM            +       'and sldisp=a.ladisp)';

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'for update';

         exec sql prepare stmtOrphan from :SqlStmt;
         sqlstt=sqlstt;
         exec sql declare cursorOrphan cursor for stmtOrphan;
         sqlstt=sqlstt;
         exec sql open cursorOrphan;
         sqlstt=sqlstt;

         dow forever = forever;

           exec sql fetch next from cursorOrphan
                    into :larecds;

           if sqlstt <> sqlSuccess and sqlstt <> '01503';
             leave;
           endif;

           exec sql delete from licactive
                    where current of cursorOrphan;

           if sqlstt <> sqlSuccess;
             iter;
           endif;

           llaqty1 = -(laQty1);
           llaqty2 = -(laQty2);
           llaqty3 = -(laQty3);
           laqty1  = 0;
           laqty2  = 0;
           laqty3  = 0;

           llexcd  = 'DLTSLTOR';
           exsr wrtliclogAdj;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  dltSltItm      Delete all LICACTIVE records for a slot
     *                 that match the sent item.
     *----------------------------------------------------------------

      /free
       begsr dltSltItm;

         kyWhse = $liToWhse;
         kyWhdp = $liToWhdp;
         kyDisp = $liToDisp;
         kyItem = $liToSItem;

         setll (kyWhse: kyWhdp: kyDisp) licactive1;

         dow forever = forever;

           reade (kyWhse: kyWhdp: kyDisp) licactive1;
           if %eof(licactive1);
             leave;
           endif;

           if laSItem <> KyItem;
             iter;
           endif;

           llaqty1 = -(laQty1);
           llaqty2 = -(laQty2);
           llaqty3 = -(laQty3);
           laqty1  = 0;
           laqty2  = 0;
           laqty3  = 0;

           llexcd  = 'DLTSLTIT';
           exsr wrtliclogAdj;

           delete larec1;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fileclose  Close file btswhse
     *----------------------------------------------------------------

      /free
       begsr fileclose;

         if %open(licactive);
           close(e) licactive;
           if %error;
             error = *on;
             $preturn = 'ERRCLSLA';
             $pmessage = 'Error closing LICACTIVE file';
           endif;
         endif;

         if %open(licactive1);
           close(e) licactive1;
           if %error;
             error = *on;
             $preturn = 'ERRCLSLA1';
             $pmessage = 'Error closing LICACTIVE1 file';
           endif;
         endif;

         if %open(licactive2);
           close(e) licactive2;
           if %error;
             error = *on;
             $preturn = 'ERRCLSLA2';
             $pmessage = 'Error closing LICACTIVE2 file';
           endif;
         endif;

         if %open(licactive3);
           close(e) licactive3;
           if %error;
             error = *on;
             $preturn = 'ERRCLSLA3';
             $pmessage = 'Error closing LICACTIVE3 file';
           endif;
         endif;

         if %open(liclog);
           close(e) liclog;
           if %error;
             error = *on;
             $preturn = 'ERRCLSLL';
             $pmessage = 'Error closing LICLOG file';
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fileopenLA2  Open file licactive2
     *----------------------------------------------------------------

      /free
       begsr fileopenLA2;

         if not %open(licactive2);
           open(e) licactive2;
           if %error;
             error = *on;
             $preturn  = 'OPNERRLA2';
             $pmessage = 'Error occured trying to '
                       + 'open file LICACTIVE2 in pgm '
                       + #pgm;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fileopenLA3  Open file licactive3
     *----------------------------------------------------------------

      /free
       begsr fileopenLA3;

         if not %open(licactive3);
           open(e) licactive3;
           if %error;
             error = *on;
             $preturn  = 'OPNERRLA3';
             $pmessage = 'Error occured trying to '
                       + 'open file LICACTIVE3 in pgm '
                       + #pgm;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fileopenLA4  Open file licactive4
     *----------------------------------------------------------------

      /free
       begsr fileopenLA4;

         if not %open(licactive4);
           open(e) licactive4;
           if %error;
             error = *on;
             $preturn  = 'OPNERRLA4';
             $pmessage = 'Error occured trying to '
                       + 'open file LICACTIVE4 in pgm '
                       + #pgm;
           endif;
         endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  fileopenLA5  Open file licactive5
650bA*----------------------------------------------------------------

650bA /free
650bA  begsr fileopenLA5;

         if not %open(licactive5);
           open(e) licactive5;
           if %error;
             error = *on;
             $preturn  = 'OPNERRLA5';
             $pmessage = 'Error occured trying to '
                       + 'open file LICACTIVE5 in pgm '
                       + #pgm;
           endif;
         endif;

       endsr;
650bA /end-free

     *----------------------------------------------------------------
     *  fileopenLL   Open file liclog
     *----------------------------------------------------------------

      /free
       begsr fileopenLL;

         if not %open(liclog);
           open(e) liclog;
           if %error;
             error = *on;
             $preturn  = 'OPNERRLL';
             $pmessage = 'Error occured trying to '
                       + 'open file LICLOG in pgm '
                       + #pgm;
           endif;
         endif;

       endsr;
      /end-free
650q
650q *----------------------------------------------------------------
650q *  fileopenPP   Open file prodlog
650q *----------------------------------------------------------------
650q
650q  /free
650q   begsr fileopenpp;
650q
650q     if not %open(prodlog);
650q       open(e) prodlog;
650q       if %error;
650q         error = *on;
650q         $preturn  = 'OPNERRPP';
650q         $pmessage = 'Error occured trying to '
650q                   + 'open file PRODLOG in pgm '
650q                   + #pgm;
650q       endif;
650q     endif;
650q
650q   endsr;
650q  /end-free

700b
700b *----------------------------------------------------------------
700b *  fileopenPD   Open file prddate1
700b *----------------------------------------------------------------
700b
700b  /free
700b   begsr fileopenpd;
700b
700b     if not %open(prddate1);
700b       open(e) prddate1;
700b       if %error;
700b         error = *on;
700b         $preturn  = 'OPNERRPD';
700b         $pmessage = 'Error occured trying to '
700b                   + 'open file PRDDATE1 in pgm '
700b                   + #pgm;
700b       endif;
700b     endif;
700b
700b   endsr;
700b  /end-free

     *----------------------------------------------------------------
     *  fixbrkdnllAQty  Fix breakdown quantities for llAQty
     *----------------------------------------------------------------

      /free
       begsr fixbrkdnllAQty;

         // First make sure there are no negative available brkdn2/3 qtys.

           // Breakdown 3 ...

           if toSItem.$itumq3 > 0;
             dow llAQty3 < 0;
               llAQty2 = llAQty2 - 1;
               llAQty3 = llAQty3 + toSItem.$itumq3;
             enddo;
           endif;

           // Breakdown 2 ...

           if toSItem.$itumq2 > 0;
             dow llAQty2 < 0;
               llAQty1 = llAQty1 - 1;
               llAQty2 = llAQty2 + toSItem.$itumq2;
             enddo;
           endif;

         // Now try to "up" available/stock quantities.

           // Breakdown 3 ...

           if toSItem.$itumq3 > 0;
             dow llAQty3 >= toSItem.$itumq3;
               llAQty3 = llAQty3 - toSItem.$itumq3;
               llAQty2 = llAQty2 + 1;
             enddo;
           endif;

           // Breakdown 2 ...

           if toSItem.$itumq2 > 0;
             dow llAQty2 >= toSItem.$itumq2;
               llAQty2 = llAQty2 - ToSItem.$itumq2;
               llAQty1 = llAQty1 + 1;
             enddo;
           endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fixbrkdnliToRQty  Fix breakdown quantities for $liToRQty
     *----------------------------------------------------------------

      /free
       begsr fixbrkdnliToRQty;

         // First make sure there are no negative available brkdn2/3 qtys.

           // Breakdown 3 ...

           if toSItem.$itumq3 > 0;
             dow $liToRQty3 < 0;
               $liToRQty2 = $liToRQty2 - 1;
               $liToRQty3 = $liToRQty3 + toSItem.$itumq3;
             enddo;
           endif;

           // Breakdown 2 ...

           if toSItem.$itumq2 > 0;
             dow $liToRQty2 < 0;
               $liToRQty1 = $liToRQty1 - 1;
               $liToRQty2 = $liToRQty2 + toSItem.$itumq2;
             enddo;
           endif;

         // Now try to "up" available/stock quantities.

           // Breakdown 3 ...

           if toSItem.$itumq3 > 0;
             dow $liToRQty3 >= toSItem.$itumq3;
               $liToRQty3 = $liToRQty3 - toSItem.$itumq3;
               $liToRQty2 = $liToRQty2 + 1;
             enddo;
           endif;

           // Breakdown 2 ...

           if toSItem.$itumq2 > 0;
             dow $liToRQty2 >= toSItem.$itumq2;
               $liToRQty2 = $liToRQty2 - ToSItem.$itumq2;
               $liToRQty1 = $liToRQty1 + 1;
             enddo;
           endif;

       endsr;
      /end-free

600lA*----------------------------------------------------------------
600lA*  fixnglcns  Fix *NG license by applying positive license to it
600lA*----------------------------------------------------------------
600lA
600lA /free
600lA  begsr fixNGLcns;

         // Create negative license number for slot.

650bD    //exsr crtNegLcns;

650bA    // Find the *NG if it exist

650bA    exsr fileopenLA5;
650bA    neglcns = ' ';
650bA    setll ($litowhse: $litowhdp: $litodisp) licactive5;
650bA    dow forever = forever;
650bA      reade ($litowhse: $litowhdp: $litodisp) licactive5;
650bA      if %eof(licactive5);
650bA        leave;
650bA      endif;
650bA      if %subst(lalcns:1:3) = '*NG';
650bA        neglcns = lalcns;
650bA        leave;
650bA      endif;
650bA    enddo;

650bA    // if negative license. If not found, leave.

650bA    if neglcns = ' ';
650bA      leavesr;
650bA    endif;

         // Get negative license. If not found, leave.

         chain(n) ($liToWhse: neglcns) licactive;

         if not %found;
           leavesr;
         endif;

         // Igonore negative license that has positive qty.
         // In therory, this shouldn't occur.

         if laQty1 > 0 or laQty2 > 0 or laQty3 > 0;
           leavesr;
         endif;

         // Convert qtys to positive values.

         laqty1 = -(laqty1);
         laQty2 = -(laqty2);
         laQty3 = -(laqty3);

         // Calculate low qty for neglcns.

         exsr calcToLowRecQty;
         ngLowToRecQty = lowToRecQty;
         lowRemAdj = lowToRecQty;

         // Loop through all records for To slot/item in picking order.

         setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
               licactive1;

         dow forever = forever;

           reade ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;

           if %eof(licactive1);
             leave;
           endif;

           // Skip negatvie license.

650eD      //if lalcns = negLcns;
650eM      if %subst(lalcns:1:3) = '*NG';
             iter;
           endif;

           // Calculate low qty for record.

           exsr calcToLowRecQty;

           // If positive rec has plenty of qty,
           // Reduce it by adjust qty.

           if lowToRecQty >= lowRemAdj;

             lowActualAdj = lowRemAdj;
             lowRemAdj -= lowActualAdj;
             lowToRecQty -= lowActualAdj;
             lowllAQty = lowActualAdj;

           // Otherwise, positive rec doesn't have enough qty,
           // Reduce positive rec to zero.

           else;

             lowActualAdj = lowToRecQty;
             lowRemAdj -= lowActualAdj;
             lowToRecQty -= lowActualAdj;
             lowllAQty = lowActualAdj;

           endif;

           // Up positve rec qtys

           exsr upToRecQty;

           // Up log qty and negate them.

           exsr upTollAQty;
           llaqty1 = -(llaqty1);
           llaqty2 = -(llaqty2);
           llaqty3 = -(llaqty3);

           // Write log record.

610fD      //if lowToRecQty = 0;
610fM      if laQty1=0 and laQty2=0 and laQty3=0;
             llexcd  = 'DELZRO';
           endif;
           frmLcns = negLcns;
           exsr wrtLicLogFixNG;

           // Update positive record.

           exsr updateLA1;

           // If positive rec is zero, then delete it.

610fD      //if lowToRecQty = 0;
610fM      if laQty1=0 and laQty2=0 and laQty3=0;
             exsr deleteLA;
           endif;

           frmLcns = lalcns;
           exsr fixNGLcnsUpdNG;

           // If adjust qty is down to zero, get out.

           if lowRemAdj = 0;
             leave;
           endif;

         enddo;

       endsr;
      /end-free

600lA*----------------------------------------------------------------
600lA*  fixNGLcnsUpdNG  Update *NG license.
600lA*----------------------------------------------------------------
600lA
600lA /free
600lA  begsr fixNGLcnsUpdNG;

         // Get negative license. If not found, leave.

         chain ($liToWhse: neglcns) licactive;

         if not %found;
           leavesr;
         endif;

         // Reverse sign of quantities.

         laqty1 = -(laqty1);
         laQty2 = -(laqty2);
         laQty3 = -(laqty3);

         // Calculate low qty for neglcns.

         exsr calcToLowRecQty;

         // Calculate new low qty.

         eval lowToRecQty -= lowActualAdj;

         // Up rec qtys

         exsr upToRecQty;

         // Reverse sign of quantities.

         laqty1 = -(laqty1);
         laQty2 = -(laqty2);
         laQty3 = -(laqty3);

         // Calculate log qty

         lowllAQty = lowActualAdj;
         exsr upTollAQty;

         // Write log record.

610fD    //if lowToRecQty = 0;
610fM    if laQty1=0 and laQty2=0 and laQty3=0;
           llexcd  = 'DELZRO';
         endif;
         exsr wrtLicLogFixNG;

         // Update neglcns record.

         exsr updateLA;

         // If neglcns rec is zero, then delete it.

610fD    //if lowToRecQty = 0;
610fM    if laQty1=0 and laQty2=0 and laQty3=0;
           exsr deleteLA;
         endif;

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

      /free
       begsr getItem;

         error = *off;

         savever# = $itver#;
         clear $item;
         $itver# = savever#;

         $itwhse = kywhse;
         $ititem = kyitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);

         $item = $dridata;
         $item2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getSlot  Get slot info.
     *----------------------------------------------------------------

      /free
       begsr getSlot;

         error = *off;

         savever# = $slver#;
         clear $slot;
         $slver# = savever#;

         $slwhse = kywhse;
         $slwhdp = kywhdp;
         $sldisp = kydisp;
         $dridata = $slot;

         driSlotCalled = *on;
         driSlot('%GET': $pprogram: $drireturn: $drimessage:
                         $dridata: $dridata2);

         $slot = $dridata;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getSlotDef  Get slot def info.
     *----------------------------------------------------------------

      /free
       begsr getSlotDef;

         error = *off;

         savever# = $sdver#;
         clear $slotdef;
         $sdver# = savever#;

         $sdwhse = kywhse;
         $sdcode = kysdef;
         $dridata = $slotdef;

         driSlotDefCalled = *on;
         driSlot('%GET': $pprogram: $drireturn: $drimessage:
                         $dridata: $dridata2);

         $slotdef = $dridata;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

       endsr;
      /end-free

600kA*----------------------------------------------------------------
600kA*  getinfo  Get license info
600kA*----------------------------------------------------------------
600kA
600kA /free
600kA  begsr getinfo;

         // First try to get active record for slot.

         kywhse = $liToWhse;
         kylcns = $liToLcns;
         lock = *off;
         throwErr = *on;
         exsr getlicactive;

         // If Active exists, return info.

         if not error;
           exsr larec2ds;
           leavesr;
         endif;

         // If Active doesn't exist, then try to get first log record.

         error = *off;
         $preturn = '*OK';
         $pmessage = ' ';

         setll ($liToWhse: $liToLcns) liclog;
640eD    // reade ($liToWhse: $liToLcns) liclog;
640eM    reade(n) ($liToWhse: $liToLcns) liclog;

         // If log rec doesn't exist, then return error.

         if %eof(liclog);
           error = *on;
           $preturn = 'INVLDLCNS';
           $pmessage = 'Invalid license '
                     + '('
                     + %Trim(%editc($liToWhse:'Z'))
                     + '/'
                     + %trim($liToLcns)
                     + ')';
           $liToWhseE = $drierror;
           $liToLcnsE = $drierror;
           leavesr;
         endif;

         // Otherwise, return info from log record.

         exsr llrec2ds;

       endsr;
      /end-free

760aA*----------------------------------------------------------------
760aA*  getlabel Get license for a pick label
760aA*----------------------------------------------------------------

760aA /free
760aA  begsr getlabel;

760aA    exec sql select * into :lbrec
760aA    from labelw
760aA      where lbwhse = :$liToWhse
760aA        and lblbl#  = :$liLbl#
760aA      fetch first 1 rows only;
760aA    If sqlstt = sqlSuccess;
760aA      setll (lbwhse: lbtrn#: lblbl#) liclog2;
760aA      dow forever = forever;
760aA        reade (lbwhse: lbtrn#: lblbl#) liclog2;
760aA        if %eof(liclog2);
760aA          leave;
760aA        endif;
760aA        // got a license is it in licinfo with a lot#
760aA        chain (lbwhse: ll2_llolcns: 1) licinfo;
760aA        if %found(licinfo);
760aA          if lnlot <> ' ';
760aA            $liolcns = ll2_llolcns;
760aA            leave;
760aA          else;
760aA            iter;
760aA          endif;
760aA        else;
760aA          iter;
760aA        endif;
760aA      enddo;

760aA    endif;

760aA  endsr;
760aA /end-free

     *----------------------------------------------------------------
     *  getlcns  Get license record
     *----------------------------------------------------------------

      /free
       begsr getlcns;

         kywhse = $liToWhse;
         kylcns = $liToLcns;
         lock = *off;
         throwErr = *on;
         exsr getlicactive;
         if not error;
           exsr larec2ds;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getlicactive  Get license info
     *----------------------------------------------------------------

      /free
       begsr getlicactive;

         lockedLA = *off;
         foundLA = *off;

         // Get licactive record

         if lock;
           chain (kywhse: kylcns) licactive;
         else;
           chain(n) (kywhse: kylcns) licactive;
         endif;

         if not %found;
           if throwErr;
             error = *on;
             $preturn = 'INVLDLCNS';
             $pmessage = 'Invalid license '
                       + '('
                       + %Trim(%editc($liToWhse:'Z'))
                       + '/'
                       + %trim($liToLcns)
                       + ')';
             $liToWhseE = $drierror;
             $liToLcnsE = $drierror;
           endif;
           leavesr;
         endif;

         if lock;
           lockedLA = *on;
         endif;

         foundLA = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getltrn   Get license history transaction number.
     *----------------------------------------------------------------

     C     getltrn       begsr

     C                   call      'PIRLLP#'
     C                   parm      0             nxtltrn#

650pAC                   eval      nxtltrnSeq = 0

     C                   endsr

     *----------------------------------------------------------------
     *  getSfgOss     Get next OSS license
     *----------------------------------------------------------------

      /free
       begsr getSfgOss;

         kyWhse = $liToWhse;
         kyItem = $liToSItem;

         // Open licactive2 file

         exsr fileOpenLA2;
         if error;
             leavesr;
         endif;

         setll (kywhse: kyitem) licactive2;
         recCount = 0;

         dow forever = forever;

           reade(n) (kywhse: kyitem) licactive2;
           if %eof(licactive2);
             leave;
           endif;

           if laaisl <> 'OSS';
             iter;
           endif;

           recCount += 1;
           exsr larec2ds;
           leave;

         enddo;

         // Set return information based on what was read.

         select;

         when recCount = 0;
           error = *on;
           $liToLcns  = '*NONE';
           $liToPos   = 0;
           $preturn = '*OK';
           $pmessage = 'No license found for slot '
                     + '('
                     + %Trim(%editc($liToWhse:'Z'))
                     + '/'
                     + %trim($liToWhdp)
                     + '/'
                     + %trim($liToDisp)
                     + ')';

         when recCount = 1;
           $preturn = '*OK';

         endsl;

       endsr;
      /end-free

600hA*----------------------------------------------------------------
600hA*  getsltfifo   Get FIFO information for slot
600hA*----------------------------------------------------------------
600hA
600hA /free
600hA  begsr getsltfifo;

         exsr getcurrstamp;
         todayYMD = %dec(%date(currStampSys):*iso);

         // Initialize fifo fields to be sent back

         $liFirstFifoEntD = 0;
         $liFirstFifoExpD = 0;
         $liFirstFifoPrty = 0;

         $liFirstNEFifoEntD = 0;
         $liFirstNEFifoExpD = 0;
         $liFirstNEFifoPrty = 0;

         $liLastFifoEntD = 0;
         $liLastFifoExpD = 0;
         $liLastFifoPrty = 0;

         // Loop through records for slot in priority order

         firstRec = *on;
         firstNonExp = *off;
         setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
               licactive1;

         dow forever = forever;

           reade(n) ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                    licactive1;

           if %eof(licactive1);
             leave;
           endif;

           if firstRec;
             $liFirstFifoEntD = laentd;
             $liFirstFifoExpD = laexpd;
             $liFirstFifoPrty = laprty;
             firstRec = *off;
           endif;

           if not firstNonExp;
             if laexpd = 0
                or laexpd >= todayYMD;
               $liFirstNEFifoEntD = laentd;
               $liFirstNEFifoExpD = laexpd;
               $liFirstNEFifoPrty = laprty;
               firstNonExp = *on;
             endif;
           endif;

           $liLastFifoEntD = laentd;
           $liLastFifoExpD = laexpd;
           $liLastFifoPrty = laprty;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getsltlic  Get license for slot
     *----------------------------------------------------------------

      /free
       begsr getsltlic;

650mA    if $psubcmd = '*GETSLTREV';
650mA      reverseOrder = *on;
650mA    else;
650mA      reverseOrder = *off;
650mA    endif;

         // Read through licactive records for slot

650mA    if reverseOrder;
650mA      setgt ($liToWhse: $liToWhdp: $liToDisp) licactive1;
650mA    else;
           setll ($liToWhse: $liToWhdp: $liToDisp) licactive1;
650mA    endif;
         recCount = 0;

         dow forever = forever;

650mA      if reverseOrder;
650mA        readpe(n) ($liToWhse: $liToWhdp: $liToDisp) licactive1;
650mA      else;
             reade(n) ($liToWhse: $liToWhdp: $liToDisp) licactive1;
650mA      endif;
           if %eof(licactive1);
             leave;
           endif;

           recCount += 1;

           // Move first license into return parms.
           // After reading second record, leave.

           select;
             when recCount = 1;
               exsr larec2ds;
             other;
               leave;
           endsl;

         enddo;

         // Set return information based on what was read.

         select;

         when recCount = 0;
           error = *on;
           $liToLcns  = '*NONE';
           $liToPos   = 0;
           $preturn = '*OK';
           $pmessage = 'No license found for slot '
                     + '('
                     + %Trim(%editc($liToWhse:'Z'))
                     + '/'
                     + %trim($liToWhdp)
                     + '/'
                     + %trim($liToDisp)
                     + ')';

         when recCount = 1;
           $preturn = '*OK';

         other;
650mA      // *MULTI does not return actual license number.
650mA      //   For *GETSLTREV we also need actual license number,
650mA      //   so we will move to From Old License for calling pgm.
650mA      if $psubcmd = '*GETSLTREV';
650mA        $liFrmOldLcns = $liToLcns;
650mA        $liFrmRQty1   = $liToRQty1;
650mA        $liFrmRQty2   = $liToRQty2;
650mA        $liFrmRQty3   = $liToRQty3;
650mA      endif;
           $liToLcns  = '*MULTIPLE';
           $liToPos   = 1;
           $preturn = '*OK';
           $pmessage = 'Multiple lcns recs found for slot '
                     + '('
                     + %Trim(%editc($liToWhse:'Z'))
                     + '/'
                     + %trim($liToWhdp)
                     + '/'
                     + %trim($liToDisp)
                     + ')';

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getsltqty    Get total qty for slot location.
     *----------------------------------------------------------------

      /free
       begsr getsltqty;

         // Initialize qtys to be sent back

         $liToRQty1 = 0;
         $liToRQty2 = 0;
         $liToRQty3 = 0;

         // Loop through records for slot

         setll (kyWhse: kyWhdp: kyDisp) licactive1;
         dow forever = forever;
           reade(n) (kyWhse: kyWhdp: kyDisp) licactive1;
           if %eof(licactive1);
             leave;
           endif;
           $liToRQty1 += laQty1;
           $liToRQty2 += laQty2;
           $liToRQty3 += laQty3;
         enddo;

         exsr fixbrkdnliToRQty;

       endsr;
      /end-free

650pA*----------------------------------------------------------------
650pA*  GetUsrInRec   Get record putting qty into USR slot
650pA*----------------------------------------------------------------
650pA
650pA /free
650pA  begsr GetUsrInRec;

         usrFLTrn = 0;
         usrFLTrnSeq = 0;

         setgt (lawhse: lawhdp: ladisp) liclog5;

         dow forever = forever;

           readpe (lawhse: lawhdp: ladisp) liclog5;

           if %eof(liclog5);
             leave;
           endif;

           if LL5_llaqty1 < 0 or LL5_llaqty2 < 0 or LL5_llaqty3 < 0;
             iter;
           endif;

710iA      // Also make sure license is the same, should only be an
710iA      // issue when moving more than one license.
710iA      if LL5_lllcns <> lalcns;
710iA        iter;
710iA      endif;

           usrFLTrn = LL5_llfltrn;
           usrFLTrnSeq = LL5_llfltrnseq;

           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetUsrNum     Get user number for user id
     *----------------------------------------------------------------
720aAc     GetUsrNum     begsr
720aA
720aAc                   monitor
720aAc                   call      'GETUSER'
720aAc                   parm                    $liuser
720aAc                   parm      0             #whse             3 0
720aAc                   parm      0             #emp#             5 0
720aAc                   parm                    #fnam            15
720aAc                   parm                    #init             1
720aAc                   parm                    #lnam            20
720aAc                   parm                    #whdp             5
720aAc                   parm                    #styp             1
720aAc                   parm                    #shft             6
720aAc                   parm                    #crew             6
720aAc                   parm      0             #nhrs             3 1
720aAc                   parm                    #rtn              8
720aAc                   on-error
720aAc                   eval      #emp# = 0
720aAc                   endmon
720aAc                   eval      $liemp# = #emp#
720aA
720aAc                   endsr

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

      /free
       begsr inzchkflds;

         $liStampSysE = $driok;
         $liStampUcE = $driok;
         $liToWhseE = $driok;
         $liLTrnE = $driok;
         $liTrn#E = $driok;
         $liLbl#E = $driok;
         $liActionE = $driok;
         $liAQty1E = $driok;
         $liAQty2E = $driok;
         $liAQty3E = $driok;
         $liExcdE = $driok;
         $liOLcnsE = $driok;
         $liToLcnsE = $driok;
         $liToOldLcnsE = $driok;
         $liToVrfyE = $driok;
         $liToRQty1E = $driok;
         $liToRQty2E = $driok;
         $liToRQty3E = $driok;
         $liToCodeE = $driok;
         $liToAreaE = $driok;
         $liToWhdpE = $driok;
         $liToDispE = $driok;
         $liToAislE = $driok;
         $liToLocE  = $driok;
         $liToRlvlE = $driok;
         $liToHandE = $driok;
         $liToBaseE = $driok;
         $liToPosE  = $driok;
         $liToItemE = $driok;
         $liToITypeE = $driok;
         $liToSItemE = $driok;
         $liToSITypeE = $driok;
         $liToPrtyE = $driok;
         $liToEntDE = $driok;
         $liToExpDE  = $driok;
         $liToOrdE  = $driok;
         $liToSeqE  = $driok;
         $liFrmNewLcnsE = $driok;
         $liFrmOldLcnsE = $driok;
         $liFrmVrfyE = $driok;
         $liFrmRQty1E = $driok;
         $liFrmRQty2E = $driok;
         $liFrmRQty3E = $driok;
         $liFrmWhseE = $driok;
         $liFrmWhdpE = $driok;
         $liFrmDispE = $driok;
         $liFrmAislE = $driok;
         $liFrmLocE  = $driok;
         $liFrmRlvlE = $driok;
         $liFrmHandE = $driok;
         $liFrmBaseE = $driok;
         $liFrmPosE  = $driok;
         $liFrmItemE = $driok;
         $liFrmITypeE = $driok;
         $liFrmSItemE = $driok;
         $liFrmSITypeE = $driok;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  larec2ds   Move licactive file fields to data structure fields
     *----------------------------------------------------------------

      /free
       begsr larec2ds;

         // Initialize data structure

         savever# = $liver#;
         clear $license;
         $liver# = savever#;

         // Move information to data structure

         $liOLcnsE = $driok;
         $liOLcns = laolcns;

         $liToLcnsE = $driok;
         $liToLcns = lalcns;

         $liToCodeE = $driok;
         $liToCode = lacode;

         $liToAreaE = $driok;
         $liToArea = laarea;

         $liToRQty1E = $driok;
         $liToRQty1 = laqty1;

         $liToRQty2E = $driok;
         $liToRQty2 = laqty2;

         $liToRQty3E = $driok;
         $liToRQty3 = laqty3;

         $liToWhseE = $driok;
         $liToWhse = lawhse;

         $liToWhdpE = $driok;
         $liToWhdp = lawhdp;

         $liToDispE = $driok;
         $liToDisp = ladisp;

         $liToAislE = $driok;
         $liToAisl = laaisl;

         $liToLocE  = $driok;
         $liToLoc  = laloc;

         $liToRLvlE = $driok;
         $liToRLvl = larlvl;

         $liToHandE = $driok;
         $liToHand = lahand;

         $liToBaseE = $driok;
         $liToBase = labase;

         $liToPosE  = $driok;
         $liToPos  = lapos;

         $liToItemE = $driok;
         $liToItem = laitem;

         $liToITypeE = $driok;
         $liToIType = laitype;

         $liToSItemE = $driok;
         $liToSItem = lasitem;

         $liToSITypeE = $driok;
         $liToSIType = lasitype;

         $liToEntdE = $driok;
         $liToEntd = laentd;

         $liToExpdE = $driok;
         $liToExpd = laexpd;

         $liToOrdE  = $driok;
         $liToOrd  = laord;

         $liToSeqE  = $driok;
         $liToSeq  = laseq;

       endsr;
      /end-free

600kA*----------------------------------------------------------------
600kA*  llrec2ds   Move liclog file fields to data structure fields
600kA*----------------------------------------------------------------
600kA
600kA /free
600kA  begsr llrec2ds;

         // Initialize data structure

         savever# = $liver#;
         clear $license;
         $liver# = savever#;

         // Move information to data structure

         $liOLcnsE = $driok;
         $liOLcns = llolcns;

         $liToLcnsE = $driok;
         $liToLcns = lllcns;

         $liToWhseE = $driok;
         $liToWhse = llwhse;

         $liToDispE = $driok;
         $liToDisp = '<not active>';

         $liToItemE = $driok;
         $liToItem = llitem;

         $liToITypeE = $driok;
         $liToIType = llitype;

         $liToSItemE = $driok;
         $liToSItem = llsitem;

         $liToSITypeE = $driok;
         $liToSIType = llsitype;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  moveBack   Move back items in slot (increment slot pos)
     *----------------------------------------------------------------

      /free
       begsr moveBack;

         // Open licactive4 file

         exsr fileOpenLA4;
         if error;
           leavesr;
         endif;

         // Get slot positions

         kywhse = $liToWhse;
         kywhdp = $liToWhdp;
         kydisp = $liToBase;
         exsr getSlot;
         if error;
           $sdpos = 1;
         else;
           kywhse = $slwhse;
           kysdef = $slsdef;
           exsr getSlotDef;
           if error;
             $sdpos = 1;
           endif;
         endif;

         // Loop through licactive records in reverse position order.

         kycode = 'S';
         kypos  = *hival;

         setgt ($liToWhse: $liToWhdp: $liToBase: kycode: kypos)
               licactive4;

         dow forever = forever;
           readpe(e) ($liToWhse: $liToWhdp: $liToBase: kycode)
                     licactive4;

           if %eof(licactive4);
             leave;
           endif;

           // We shouldn't have any, but ignore locked records.

650iD      //if %status(licactive4) = 1217;
650iM      if %status(licactive4) = 1218;
             iter;
           endif;

           // Skip if already in greatest slot postion.

           if lapos >= $sdpos;
             iter;
           endif;

           // Increment slot position and update record.

           lapos += 1;

           exsr getcurrstamp;
           lachgts = currstampsys;
           lachguc = currstampuc;
           lachgpgm = #pgm;
           lachgemp = $liemp#;
           lachgeusr = $liuser;
           lachgcusr = #curruser;
           lachgjusr = #user;
           lachgjob = #job;
           lachgnbr = #jobnbr;

           lldrilic = $psubcmd;
           lldrislot = $lidrislot;

           // First write log record

           exsr wrtliclog;

           // Then write or update licactive record

           update(e) larec4;
           if %error;
             llexcd = 'LA4UPDERR';
             exsr wrtliclog;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  moveBackF   Move back items on the floor (increment slot pos)
     *----------------------------------------------------------------

      /free
       begsr moveBackF;

         // Open licactive4 file

         exsr fileOpenLA4;
         if error;
             leavesr;
         endif;

         // Get slot positions

         kywhse = $liToWhse;
         kywhdp = $liToWhdp;
         kydisp = $liToBase;
         exsr getSlot;
         if error;
           $sdpos = 1;
         else;
           kywhse = $slwhse;
           kysdef = $slsdef;
           exsr getSlotDef;
           if error;
             $sdpos = 1;
           endif;
         endif;

         // Loop through licactive records in reverse position order.

         kycode = 'F';
         kypos  = *hival;

         setgt ($liToWhse: $liToWhdp: $liToBase: kycode: kypos)
               licactive4;

         dow forever = forever;
           readpe(e) ($liToWhse: $liToWhdp: $liToBase: kycode)
                     licactive4;

           if %eof(licactive4);
             leave;
           endif;

           // We shouldn't have any, but ignore locked records.

650iD      //if %status(licactive4) = 1217;
650iM      if %status(licactive4) = 1218;
             iter;
           endif;

           // Skip if already in greatest slot postion.

           if lapos >= $sdpos;
             iter;
           endif;

           // Increment slot position and update record.

           lapos += 1;

           exsr getcurrstamp;
           lachgts = currstampsys;
           lachguc = currstampuc;
           lachgpgm = #pgm;
           lachgemp = $liemp#;
           lachgeusr = $liuser;
           lachgcusr = #curruser;
           lachgjusr = #user;
           lachgjob = #job;
           lachgnbr = #jobnbr;

           lldrilic = $psubcmd;
           lldrislot = $lidrislot;


           // First write log record

           exsr wrtliclog;

           // Then write or update licactive record

           update(e) larec4;
           if %error;
             llexcd = 'LA4UPDERR';
             exsr wrtliclog;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  moveFwd    Move forward items in slot (decrement slot pos)
     *----------------------------------------------------------------

      /free
       begsr moveFwd;

         // Open licactive4 file

         exsr fileOpenLA4;
         if error;
           leavesr;
         endif;

         // Loop through licactive records in reverse position order.

         kycode = 'S';
         kypos  = 0;

         setgt ($liToWhse: $liToWhdp: $liToBase: kycode: kypos)
               licactive4;

         dow forever = forever;
           readpe(e) ($liToWhse: $liToWhdp: $liToBase: kycode)
                     licactive4;

           if %eof(licactive4);
             leave;
           endif;

           // We shouldn't have any, but ignore locked records.

650iD      //if %status(licactive4) = 1217;
650iM      if %status(licactive4) = 1218;
             iter;
           endif;

           // Skip if already in first position.

           if lapos <= 1;
             iter;
           endif;

           // Decrement slot position and update record.

           lapos -= 1;

           exsr getcurrstamp;
           lachgts = currstampsys;
           lachguc = currstampuc;
           lachgpgm = #pgm;
           lachgemp = $liemp#;
           lachgeusr = $liuser;
           lachgcusr = #curruser;
           lachgjusr = #user;
           lachgjob = #job;
           lachgnbr = #jobnbr;

           lldrilic = $psubcmd;
           lldrislot = $lidrislot;

           // First write log record

           exsr wrtliclog;

           // Then write or update licactive record

           update(e) larec4;
           if %error;
             llexcd = 'LA4UPDERR';
             exsr wrtliclog;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  moveFwdF   Move forward items on floor (decrement slot pos)
     *----------------------------------------------------------------

      /free
       begsr moveFwdF;

         // Open licactive4 file

         exsr fileOpenLA4;
         if error;
           leavesr;
         endif;

         // Loop through licactive records in reverse position order.

         kycode = 'F';
         kypos  = 0;

         setgt ($liToWhse: $liToWhdp: $liToBase: kycode: kypos)
               licactive4;

         dow forever = forever;
           readpe(e) ($liToWhse: $liToWhdp: $liToBase: kycode)
                     licactive4;

           if %eof(licactive4);
             leave;
           endif;

           // We shouldn't have any, but ignore locked records.

650iD      //if %status(licactive4) = 1217;
650iM      if %status(licactive4) = 1218;
             iter;
           endif;

           // Skip if already in first position.

           if lapos <= 1;
             iter;
           endif;

           // Decrement slot position and update record.

           lapos -= 1;

           exsr getcurrstamp;
           lachgts = currstampsys;
           lachguc = currstampuc;
           lachgpgm = #pgm;
           lachgemp = $liemp#;
           lachgeusr = $liuser;
           lachgcusr = #curruser;
           lachgjusr = #user;
           lachgjob = #job;
           lachgnbr = #jobnbr;

           lldrilic = $psubcmd;
           lldrislot = $lidrislot;

           // First write log record

           exsr wrtliclog;

           // Then write or update licactive record

           update(e) larec4;
           if %error;
             llexcd = 'LA4UPDERR';
             exsr wrtliclog;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
600o *  setfifo  Set (replace) LICACTIVE FIFO information for license
     *----------------------------------------------------------------

      /free
       begsr Setfifo;

         // Get active license record

         kywhse = $liToWhse;
         kylcns = $liToLcns;
         lock = *on;
         throwErr = *off;
         exsr getlicactive;

         if foundLA = *on;

         // Update FIFO Active License FIelds

         if $liToPrtyU;
           laPrty = $liToPrty;
         endif;

         if $liToEntDU;
           laentd = $liToEntD;
         endif;

         if $liToExpDU;
           laexpd = $liToExpD;
         endif;

         exsr getcurrstamp;
         lachgts = currstampsys;
         lachguc = currstampuc;
         lachgpgm = #pgm;
         lachgemp = $liemp#;
         lachgeusr = $liuser;
         lachgcusr = #curruser;
         lachgjusr = #user;
         lachgjob = #job;
         lachgnbr = #jobnbr;

         // First write log record

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;
640iA    llexcd  = 'CHGFIFO';

         exsr wrtliclog;

         // Then update licactive record

             if $psubcmd = '*SETFIFO';
                 update(e) larec;
             endif;

           if %error;
               llexcd = 'LAUPDERR';
               exsr wrtliclog;
           endif;

        endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  setlcns  Set (replace) LICACTIVE info for license
     *----------------------------------------------------------------

      /free
       begsr setlcns;

         // Check for special LP

         exsr chk4SpclLcns;
         if spclLcns;
           exsr crtSpclLcns;
           if error;
             leavesr;
           endif;
         endif;

         // Initialize Old license if necessary

         if not $liToOldLcnsU;
            $liToOldLcns = $liToLcns;
            $liToOldLcnsU = *on;
         endif;

         // Get record for Old license

         kywhse = $liToWhse;
         kylcns = $liToOldLcns;
         lock = *on;
         throwErr = *off;
         exsr getlicactive;

         // Initialize a few fields if we need to create a record

         if not foundLA;
           clear larec;
           lawhse = $liToWhse;
           if $liOLcnsU;
             laolcns = $liOLcns;
           else;
             $liOLcnsU = *on;
             $liOLcns = $liToOldLcns;
             laolcns = $liToOldLcns;
           endif;
         endif;

         // Update the rest of the fields

         lalcns = $liToLcns;

         if $liToRQty1U;
           laqty1  = $liToRQty1;
           laqty2  = $liToRQty2;
           laqty3  = $liToRQty3;
         else;
           laqty1  = 0;
           laqty2  = 0;
           laqty3  = 0;
         endif;

         if $liToCodeU;
           lacode = $liToCode;
         endif;

         if $liToAreaU;
           laarea = $liToArea;
         endif;

         if $liToWhdpU;
           lawhdp = $liToWhdp;
         endif;

         if $liToDispU;
           ladisp = $liToDisp;
         endif;

         if $liToAislU;
           laaisl = $liToAisl;
         endif;

         if $liToLocU;
           laloc = $liToLoc;
         endif;

         if $liToRlvlU;
           larlvl = $liToRlvl;
         endif;

         if $liToHandU;
           lahand = $liToHand;
         endif;

         if $liToBaseU;
           labase = $liToBase;
         endif;

         if $liToPosU;
           lapos = $liToPos;
         endif;

         if $liToItemU;
           laitem = $liToItem;
         endif;

         if $liToITypeU;
           laitype = $liToIType;
         endif;

         if $liToSItemU;
           lasitem = $liToSItem;
         endif;

         if $liToSITypeU;
           lasitype = $liToSIType;
         endif;

         if $liToPrtyU;
           laPrty = $liToPrty;
         endif;

         if $liToEntDU;
           laentd = $liToEntD;
         endif;

         if $liToExpDU;
           laexpd = $liToExpD;
         endif;

         if $liToOrdU;
           laord = $liToOrd;
         endif;

         if $liToSeqU;
           laseq = $liToSeq;
         endif;

         exsr getcurrstamp;
         lachgts = currstampsys;
         lachguc = currstampuc;
         lachgpgm = #pgm;
         lachgemp = $liemp#;
         lachgeusr = $liuser;
         lachgcusr = #curruser;
         lachgjusr = #user;
         lachgjob = #job;
         lachgnbr = #jobnbr;

         // First write log record

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         if $liAQty1U;
           llaqty1 = $liAQty1;
           llaqty2 = $liAQty2;
           llaqty3 = $liAQty3;
         endif;

         exsr wrtliclog;

         // Then write or update licactive record

         if not foundLA;
             if laqty1 <> 0
                or laqty2 <> 0
                or laqty3 <> 0
600aA           or $psubcmd = '*SETLCNS0';
                 write(e) larec;
                 if %error;
                   llexcd = 'LAWRTERR';
                   exsr wrtliclog;
                 endif;
             else;
                 $liAqty1U = *off;
                 llexcd  = 'DELZRO';
                 exsr wrtliclog;
             endif;
         else;
             if laqty1 <> 0
                or laqty2 <> 0
                or laqty3 <> 0
600aA           or $psubcmd = '*SETLCNS0';
                 update(e) larec;
                 if %error;
                   llexcd = 'LAUPDERR';
                   exsr wrtliclog;
                 endif;
             else;
                 llexcd  = 'DELZRO';
                 exsr wrtliclog;
                 delete larec;
             endif;
         endif;

       endsr;
      /end-free

710hA*----------------------------------------------------------------
710hA*  setOLcnsfifo Set (replace) LICACTIVE original License and
710hA*                             FIFO information for license
710hA*----------------------------------------------------------------

710hA /free
710hA  begsr SetOLcnsfifo;

710hA    // Get active license record

710hA    kywhse = $liToWhse;
710hA    kylcns = $liToLcns;
710hA    lock = *on;
710hA    throwErr = *off;
710hA    exsr getlicactive;

710hA    if foundLA = *on;

710hA    // Update FIFO Active License FIelds

710hA    if $liToPrtyU;
710hA      laPrty = $liToPrty;
710hA    endif;

710hA    if $liToEntDU;
710hA      laentd = $liToEntD;
710hA    endif;

710hA    if $liToExpDU;
710hA      laexpd = $liToExpD;
710hA    endif;

710hA    if $liOLcnsU;
710hA      laolcns = $liOLcns;
710hA    endif;

710hA    // If license and orginal need to be assigned

710hA    if $liFrmOldLcnsU = *on;
710hA      lalcns = $liOLcns;
710hA      $litoLcns = $liOLcns;
710hA      llexcd  = 'CHGLCNS';
710hA    else;
710hA      llexcd  = 'CHGOLCNS';
710hA    endif;

710hA    exsr getcurrstamp;
710hA    lachgts = currstampsys;
710hA    lachguc = currstampuc;
710hA    lachgpgm = #pgm;
710hA    lachgemp = $liemp#;
710hA    lachgeusr = $liuser;
710hA    lachgcusr = #curruser;
710hA    lachgjusr = #user;
710hA    lachgjob = #job;
710hA    lachgnbr = #jobnbr;

710hA    // First write log record

710hA    lldrilic = $psubcmd;
710hA    lldrislot = $lidrislot;

710hA    exsr wrtliclog;


710hA    // Then update licactive record

710hA        if $psubcmd = '*SETOLCNS';
710hA            update(e) larec;
710hA        endif;

710hA      if %error;
710hA          llexcd = 'LAUPDERR';
710hA          exsr wrtliclog;
710hA      endif;

710hA   endif;

710hA  endsr;

710hA /end-free

     *----------------------------------------------------------------
     *  setTo2Frm  Set $liTo fields to $liFrm fields
     *----------------------------------------------------------------

      /free
       begsr setTo2Frm;

         $liToLcnsU = $liFrmNewLcnsU;
         if $liFrmNewLcnsU;
           $liToLcns = $liFrmNewLcns;
         endif;

         $liToOldLcnsU = $liFrmOldLcnsU;
         if $liFrmOldLcnsU;
           $liToOldLcns = $liFrmOldLcns;
         endif;

         $liToVrfyU = $liFrmVrfyU;
         if $liFrmVrfyU;
           $liToVrfy = $liFrmVrfy;
         endif;

         $liToRqty1U = $liFrmRqty1U;
         if $liFrmRqty1U;
           $liToRQty1  = $liFrmRQty1;
           $liToRQty2  = $liFrmRQty2;
           $liToRQty3  = $liFrmRQty3;
         endif;

         $liToWhseU = $liFrmWhseU;
         if $liFrmWhseU;
           $liToWhse = $liFrmWhse;
         endif;

         $liToWhdpU = $liFrmWhdpU;
         if $liFrmWhdpU;
           $liToWhdp = $liFrmWhdp;
         endif;

         $liToDispU = $liFrmDispU;
         if $liFrmDispU;
           $liToDisp = $liFrmDisp;
         endif;

         $liToAislU = $liFrmAislU;
         if $liFrmAislU;
           $liToAisl = $liFrmAisl;
         endif;

         $liToLocU = $liFrmLocU;
         if $liFrmLocU;
           $liToLoc = $liFrmLoc;
         endif;

         $liToRlvlU = $liFrmRlvlU;
         if $liFrmRlvlU;
           $liToRlvl = $liFrmRlvl;
         endif;

         $liToHandU = $liFrmHandU;
         if $liFrmHandU;
           $liToHand = $liFrmHand;
         endif;

         $liToBaseU = $liFrmBaseU;
         if $liFrmBaseU;
           $liToBase = $liFrmBase;
         endif;

         $liToPosU = $liFrmPosU;
         if $liFrmPosU;
           $liToPos = $liFrmPos;
         endif;

         $liToItemU = $liFrmItemU;
         if $liFrmItemU;
           $liToItem = $liFrmItem;
         endif;

         $liToITypeU = $liFrmITypeU;
         if $liFrmITypeU;
           $liToIType = $liFrmIType;
         endif;

         $liToSItemU = $liFrmSItemU;
         if $liFrmSItemU;
           $liToSItem = $liFrmSItem;
         endif;

         $liToSITypeU = $liFrmSITypeU;
         if $liFrmSITypeU;
           $liToSIType = $liFrmSIType;
         endif;

         $liToCodeU = *off;
         $liToCode = ' ';

         $liToAreaU = *off;
         $liToArea = ' ';

         $liToPrtyU = *off;
         $liToPrty = 0;

         $liToEntDU = *off;
         $liToEntD = 0;

         $liToExpDU = *off;
         $liToExpD = 0;

         $liToOrdU = *off;
         $liToOrd = 0;

         $liToSeqU = *off;
         $liToSeq = 0;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sumSlot    Sum qty's for a slot/item
     *----------------------------------------------------------------

      /free
       begsr sumSlot;

         if toSItem.$itumq2 <= 0;
           lowumq2 = 1;
         else;
           lowumq2 = toSItem.$itumq2;
         endif;

         if toSItem.$itumq3 <= 0;
           lowumq3 = 1;
         else;
           lowumq3 = toSItem.$itumq3;
         endif;

         // Loop through all records for slot/item

         recCount = 0;
         lowActiveQty = 0;

         setll ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
               licactive1;

         dow forever = forever;

           reade(n) ($liToWhse: $liToWhdp: $liToDisp: $liToSItem)
                 licactive1;

           if %eof(licactive1);
             leave;
           endif;

           recCount += 1;
           lowActiveQty += (laqty1 * lowumq2 * lowumq3)
                         + (laqty2 * lowumq3)
                         + laqty3;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  tfrLcns    Transfer specific license
     *----------------------------------------------------------------

      /free
       begsr tfrLcns;

         // If $liFrmRQty not zero, then this is a partial transfer
         // So update From license

         if not $liFrmRQty1U
            or ($liFrmRQty1 = 0
                and $liFrmRQty2 = 0
                and $liFrmRQty3 = 0);

           // Save current To information.

           save$license = $license;

           // Move From parms into To parms.

           exsr setTo2Frm;

           // Update From license record.

           exsr setLcns;

           // Restore To information.

           $license = save$license;

         endif;

         // Next, update To license.

         exsr setLcns;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  tfrSltDte  Transfer slot qty in date order
     *----------------------------------------------------------------

      /free
       begsr tfrSltDte;

         returnLcns = ' ';

         // For clean up purposes, delete any active recs that don't
         // have matching item for slot.

         kywhse = $liFrmWhse;
         kywhdp = $liFrmWhdp;
         kydisp = $liFrmDisp;
         kyitem = $liFrmSItem;
         exsr deleteWrgItm;

610dA    if $liFrmWhdp <> $liToWhdp
610dA      or $liFrmDisp <> $liToDisp;
             kywhse = $liToWhse;
             kywhdp = $liToWhdp;
             kydisp = $liToDisp;
             kyitem = $liToSItem;
             exsr deleteWrgItm;
610dA    endif;

         // Set reverse flag.

         if $psubcmd = '*TFRSLTREV';
           reverseOrder = *on;
         else;
           reverseOrder = *off;
         endif;

         // Calculate low value of incoming qtys.

         if not $liToRQty1U;
           $liToRQty1 = 0;
           $liToRQty2 = 0;
           $liToRQty3 = 0;
         endif;

         if not $liFrmRQty1U;
           $liFrmRQty1 = 0;
           $liFrmRQty2 = 0;
           $liFrmRQty3 = 0;
         endif;

         exsr calcLowFrm;

         // Loop through all records for From slot/item in picking order.

         if reverseOrder;
           setgt ($liFrmWhse: $liFrmWhdp: $liFrmDisp: $liFrmSItem)
                 licactive1;
         else;
           setll ($liFrmWhse: $liFrmWhdp: $liFrmDisp: $liFrmSItem)
                 licactive1;
         endif;

         dow forever = forever;

           if reverseOrder;
             readpe ($liFrmWhse: $liFrmWhdp: $liFrmDisp: $liFrmSItem)
                    licactive1;
           else;
             reade ($liFrmWhse: $liFrmWhdp: $liFrmDisp: $liFrmSItem)
                   licactive1;
           endif;

           if %eof(licactive1);
             leave;
           endif;

           // If From license sent in, license's must match

           if $liFrmOldLcnsU
              and %subst($liFrmOldLcns:1:1) <> '*'
              and $liFrmOldLcns <> lalcns;
               iter;
           endif;

           // Save record information for creation of To record.

           frmLAREC = larecds;

           // Calculate low qty for record.

           exsr calcFrmLowRecQty;

           // Calculate qty being adjusted out of record.

           if lowFrmRecQty <= lowFrmAdjustQty;
             tmpFrmAdjustQty = lowFrmRecQty;
           else;
             tmpFrmAdjustQty = lowFrmAdjustQty;
           endif;

           // Save the To license that was sent in.

           saveToLcns = $liToLcns;

           // Check for special To LP

           exsr chk4SpclLcns;

           // Determine To license to use.

           select;

600fD        // If transferring entire record qty
600fD        // and we are dealing with a special To license
600fD        //   Then set To license to current record license.

600fA        //   As of 600f we want to use the special LP if sent.

600fD  //    when (lowFrmRecQty = tmpFrmAdjustQty) and spclLcns;
600fD  //        $liToLcns = lalcns;

             // If transferring entire record qty
             // and we are dealing with a '*MULTIPLE' To license
             //   Then set To license to current record license.

             when (lowFrmRecQty = tmpFrmAdjustQty)
               and ($liToLcns = '*MULTIPLE');
                 $liToLcns = lalcns;

             // If we are not transferring entire record qty
             // and we are dealing with a special To license
             //   Then create a new special To license.

             when spclLcns;
               exsr crtSpclLcns;
               if error;
                 $liToLcns = saveToLcns;
                 leavesr;
               endif;

             // Otherwise, use To license that was sent.

           endsl;

           // Update From record for transfer

           exsr tfrFrmRec;

           // Create/Update To record for transfer

           exsr tfrToRec;

           // Restore the To license that was sent in.

710bA      if %subst(saveToLcns:1:3) <> '*NA';
             $liToLcns = saveToLcns;
710bA      endif;

           // Reduce adjustment quantity

           lowFrmAdjustQty -= tmpFrmAdjustQty;

720bA      // UCI Tracking
720bA      if $imltrk = 'U';
720bA        exsr updateUCI;
720bA      endif;
           // If nothing left to adjust, leave

           if lowFrmAdjustQty <= 0;
             leave;
           endif;

         enddo;

         // If adjustment qty still left, create new active record.
         //   (this should never happen when From License is sent in)

         if lowFrmAdjustQty > 0;
           exsr tfrToRecExtra;
         endif;

         $liToLcns = returnLcns;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  tfrFrmRec      Update From record for transfer.
     *----------------------------------------------------------------

      /free
       begsr tfrFrmRec;

         // Reduce From rec with qty being transferred.

         lowFrmRecQty -= tmpFrmAdjustQty;
         exsr upFrmRecQty;

         // Write log record.

         lowllAQty = tmpFrmAdjustQty;
         exsr upFrmllaQty;
         llaqty1 = -(llaqty1);
         llaqty2 = -(llaqty2);
         llaqty3 = -(llaqty3);
         if laQty1=0 and laQty2=0 and laQty3=0;
           llexcd  = 'DELZRO';
         endif;
         exsr wrtLicLogTfrFrm;

         // Update licactive record.

         exsr updateLA1;
         frmLcns = lalcns;

         // If From rec is zero, then delete it.

         frmZero = *off;
         if laQty1=0 and laQty2=0 and laQty3=0;
           frmZero = *on;
           exsr deleteLA;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  tfrToRec      Create/Update To record for transfer.
     *----------------------------------------------------------------

      /free
       begsr tfrToRec;

         // See if record already exists for To license

         kywhse = $liToWhse;
         kylcns = $liToLcns;
         lock = *on;
         throwErr = *off;
         exsr getlicactive;

         // Initialize a few fields if we need to create a record

         if not foundLA;
           larecds = frmLAREC;
           lalcns = $liToLcns;
         endif;

         // Determine quantity for TO license.

         //   If From license sent in, transfer entire sent in qty
         //     (in theory tmpFrmAdjustQty should equal entire qty)
         //   Otherwise, just transfer qty taken from From slot.

         if $liFrmOldLcnsU
            and %subst($liFrmOldLcns:1:1) <> '*';
             lowllAQty = lowFrmAdjustQty;
         else;
             lowllAQty = tmpFrmAdjustQty;
         endif;

650fA    if $lifrmitype = 'S';
650aD    //exsr upFrmllAQty;
650aM    exsr upTollAQty;
650fA    else;
650fA    exsr upFrmllAQty;

         // Convert qty if necessary (i.e. when going from ' ' to 'B')

         //700c - cvtllaqty was deleted previously in 650a/c/f
700cM    exsr cvtllAQty;
700cM    endif;

         // Set quantity
           // If license exists and we are cancelling a transaction,
610cA      //   or the To license is not special and the from
610cA      //      license is *MULTIPLE
           //   Then add the qty to it.
           //   Otherwise, replace the qty.

         if foundLA;
600bM      if $liExcdu and $liExcd = 'CANCEL'
600bA         or $liExcdu and $liExcd = 'RTNORIG'
710bA         or (%subst($liToLcns:1:3) = '*NA'
710bA             and $liPullLcns = '*MULTIPLE')
610cA         or (%subst($liToLcns:1:1) <> '*'
610cA             and $liPullLcns = '*MULTIPLE');
                laQty1 += llAQty1;
                laQty2 += llAQty2;
                laQty3 += llAQty3;
           else;
                laQty1 = llAQty1;
                laQty2 = llAQty2;
                laQty3 = llAQty3;
600bA      endif;
600bA    else;
600bA         laQty1 = llAQty1;
600bA         laQty2 = llAQty2;
600ba         laQty3 = llAQty3;
         endif;

         // Set location

         if $liToCodeU;
650lA      if $pprogram = 'SL252' and
650lA         $liToCode = ' ';
650lA      else;
             lacode = $liToCode;
650lA      endif;
         endif;

         if $liToAreaU;
650lA      if $pprogram = 'SL252' and
650lA         $liToArea = ' ';
650lA      else;
             laarea = $liToArea;
650lA      endif;
         endif;

         if $liToWhdpU;
           lawhdp = $liToWhdp;
         endif;

         if $liToDispU;
           ladisp = $liToDisp;
         endif;

         if $liToAislU;
           laaisl = $liToAisl;
         endif;

         if $liToLocU;
           laloc = $liToLoc;
         endif;

         if $liToRlvlU;
           larlvl = $liToRlvl;
         endif;

         if $liToHandU;
           lahand = $liToHand;
         endif;

         if $liToBaseU;
650lA      if $pprogram = 'SL252' and
650lA         $liToBase = ' ';
650lA      else;
             labase = $liToBase;
650lA      endif;
         endif;

         if $liToPosU;
           lapos = $liToPos;
         endif;

         if $liToItemU;
650aA      if $litodesg = 'BFC';
             laitem = $liToItem;
650aA      else;
650aA        laitem = $liToSItem;
650aA      endif;
         endif;

         if $liToITypeU;
650aA      if $litodesg = 'BFC';
             laitype = $liToIType;
650aA      else;
650aA        laitype = $liToSIType;
650aA      endif;
         endif;

         if $liToSItemU;
           lasitem = $liToSItem;
         endif;

         if $liToSITypeU;
           lasitype = $liToSIType;
         endif;

         if $liToPrtyU;
           laPrty = $liToPrty;
         endif;

CBIaA    // load up new expiration date if needed.
CBIaA    if client = cheney and
CBIaA       $liItmChg = 'Y' and
CBIaA       $litowhdp = 'FRZ' and
CBIaA       $lifrmwhdp = 'CLR' and
CBIaA       $litoexpd > 0;
CBIaA      laexpd = $litoexpd;
CBIaA    endif;
         // First write log record

         exsr wrtLicLogTfrTo;

         // Then write or update licactive record

         if not foundLA;
           exsr writeLA;
         else;
           exsr updateLA;
         endif;

         if returnLcns = ' ';
           returnLcns = $liToLcns;
         else;
           returnLcns = '*MULTIPLE';
         endif;

710bD  //  $liToLcns = saveToLcns;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  tfrToRecExtra   Create To record for extra qty not found
     *                  in From records.
     *----------------------------------------------------------------

      /free
       begsr tfrToRecExtra;

         $liToLcns = '*EX';

         lowllAQty = lowFrmAdjustQty;
         exsr upFrmllAQty;

         // Convert qty if necessary (i.e. when going from ' ' to 'B')

         exsr cvtllAQty;

         // Set quantity

         $liToRQty1 = llAQty1;
         $liToRQty2 = llAQty2;
         $liToRQty3 = llAQty3;

640bA    $liAQty1 = llAQty1;
640bA    $liAQty2 = llAQty2;
640bA    $liAQty3 = llAQty3;

         // Create license

         exsr setLcns;

         if returnLcns = ' ';
           returnLcns = $liToLcns;
         else;
           returnLcns = '*MULTIPLE';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updateChgFlds   Update CHG fields
     *----------------------------------------------------------------

      /free
       begsr updateChgFlds;

         exsr getcurrstamp;
         lachgts = currstampsys;
         lachguc = currstampuc;
         lachgpgm = #pgm;
         lachgemp = $liemp#;
         lachgeusr = $liuser;
         lachgcusr = #curruser;
         lachgjusr = #user;
         lachgjob = #job;
         lachgnbr = #jobnbr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updateLA    Update current LICACTIVE
     *----------------------------------------------------------------

      /free
       begsr updateLA;

         exsr updateChgFlds;

         update(e) larec;
         if %error;
           llexcd = 'UPDLAERR';
           exsr wrtliclog;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updateLA1   Update current LICACTIVE1
     *----------------------------------------------------------------

      /free
       begsr updateLA1;

         exsr updateChgFlds;

         update(e) larec1;
         if %error;
           llexcd = 'UPDLA1ERR';
           exsr wrtliclog;
         endif;

       endsr;
      /end-free

720bA*----------------------------------------------------------------
720bA*  updateUCI - for UCI tracked items update the uci's if needed
720bA*----------------------------------------------------------------

720bA /free
720bA  begsr updateUCI;


720bA    Select;
720bA      when $liAction = 'TFR';
720bA        // if a time sent this is a partial transfer
720bA        // if no time is sent this is a full qty transfer
720bA        // if $lifrmoldlcns = *multiple - transfer from pick slot
720bA        select;
720bA          when frmlcns = '*MULTIPLE';
720bA            leavesr;
720bA          when $litolcns = '*MULTIPLE';
720bA            leavesr;
720bA          when $litolcns = '*SP ';
720bA            leavesr;
720bA          when $liUCITS = *loval and frmlcns = $litolcns;
720bA            leavesr;
720bA        endsl;
720bA      when $liAction = 'PUT';
720bA        select;
720bA          when $liUCITS = *loval and frmlcns = $litolcns;
720bA            leavesr;
720bA        endsl;
720bA      when $liAction = 'RPL';
720bA        select;
720bA          when $liUCITS = *loval and frmlcns = $litolcns;
720bA            leavesr;
720bA        endsl;
720bA      other;
720bA    endsl;

720bA    error = *off;

720bA    savever# = $uiver#;
720bA    clear $uciinfo;
720bA    clear $uciinfo2;
720bA    $uiver# = savever#;

720bA    // setup some data to pass to driuciinfo
720bA    $uiaddpgm = $lipgm;
720bA    $uiaddemp = $liemp#;
720bA    $uiaddusr = #curruser;
720bA    $uichgpgm = $lipgm;
720bA    $uichgemp = $liemp#;
720bA    $uichgusr = #curruser;
720bA    $uiTran# = $litrn#;
720bA    $uilbl# = $lilbl#;

720bA    $uiwhse = kywhse;
720bA    $uiitem = kyitem;
720bA    select;

720bA      // transfer full qty
720bA      when $liAction = 'TFR' and $liUCITS = *loval;
720bA        $uilcns = frmlcns;
720bA        $uialcns = frmlcns;
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = $litolcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'TFR';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDATELIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      when $liAction = 'TFR' and $liUCITS <> *loval;
720bA        $uilcns = $lipulllcns;
720bA        $uialcns = $lipulllcns;
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = $litolcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'TFRSPLLIC';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDPARLIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      when $liAction = 'PUT' and $liUCITS <> *loval;
720bA        $uilcns = $lipulllcns;
720bA        $uialcns = $lipulllcns;
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = $litolcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'PUTSPLLIC';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDPARLIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      when $liAction = 'RPL' and $liUCITS <> *loval;
720bA        $uilcns = $lipulllcns;
720bA        $uialcns = $lipulllcns;
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = $litolcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'RPLSPLLIC';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDPARLIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

730bA      when $liAction = 'ADJ' and $liUCITS <> *loval
730bA           and $liucitype = '3' and $lirmuci <> ' '
730bA           and ($liaqty1 < 0 or $liaqty2 < 0 or $liaqty3 < 0);
730bA        // special system license
730bA        //if spcllcns;
730bA          //$uiToLcns = kylcns;
730bA        //else;
730bA          //$uiToLcns = lalcns;
730bA        //endif;
730bA        $uiaPartlts = $liUCIts;
730bA        $uiuci = $liRmUci;
730bA        $uiaction = 'RMVADJLCS';

730bA        $dridata = $uciinfo;
730bA        $dridata2 = $uciinfo2;
730bA        driUCICalled = *on;
730bA        driuciinfo('%RMVADJLCS': $pprogram: $drireturn: $drimessage:
730bA                 $dridata: $dridata2);

730bA      when $liAction = 'ADJ' and $liUCITS <> *loval
730bA           and $liucitype = '3' and $lirmuci <> ' '
730bA           and ($liaqty1 > 0 or $liaqty2 > 0 or $liaqty3 > 0);
730bA        // special system license
730bA        if spcllcns;
730bA          $uiToLcns = kylcns;
730bA        else;
730bA          $uiToLcns = lalcns;
730bA        endif;
730bA        $uiaPartlts = $liUCIts;
730bA        $uiuci = $liRmUci;
730bA        $uiaction = 'SETADJLCS';

730bA        $dridata = $uciinfo;
730bA        $dridata2 = $uciinfo2;
730bA        driUCICalled = *on;
730bA        driuciinfo('%SETADJLCS': $pprogram: $drireturn: $drimessage:
730bA                 $dridata: $dridata2);

720bA      when $liAction = 'ADJ' and $liUCITS <> *loval
720bA           and $liucitype = '3';
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = lalcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
730aA        if $liaqty1 < 0 or
730aA           $liaqty2 < 0 or
730aA           $liaqty3 < 0;
730aA          $uilbl# = $lilbl#;
730aA        else;
730aA          $uilbl# = 0;
730aA        endif;
720bA        // mark the uci's that were not scanned when type 3
720bA        // adjustment scanning was selected
730bA        // This needs to be handled different now that we process
730bA        // each UCI indepently on type 3 adjustments
730bD        //$uiaction = 'MISSING';
730bD        //$dridata = $uciinfo;
730bD        //$dridata2 = $uciinfo2;
730bD        //driUCICalled = *on;
730bD        //driuciinfo('%RMVMISUCI': $pprogram: $drireturn:
730bD                    //$drimessage: $dridata: $dridata2);
             // now deal with the uci's that were scanned
730aA        if $liaqty1 > 0 or
730aA           $liaqty2 > 0 or
730aA           $liaqty3 > 0;
730aA          $uilbl# = $lilbl#;
730aA        else;
730aA          $uilbl# = 0;
730aA        endif;
720bA        $uiaction = 'ADJLIC';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDPARLIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      when $liAction = 'ADJ' and $liUCITS <> *loval
720bA           and ($liaqty1 > 0 or $liaqty2 > 0 or $liaqty3 > 0);
720bA        //$uilcns = $lipulllcns;
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = lalcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'ADJLIC';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%UPDPARLIC': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      when $liAction = 'ADJ' and $liUCITS <> *loval
720bA           and ($liaqty1 < 0 or $liaqty2 < 0 or $liaqty3 < 0);
720bA        // special system license
720bA        if spcllcns;
720bA          $uiToLcns = kylcns;
720bA        else;
720bA          $uiToLcns = lalcns;
720bA        endif;
720bA        $uiaPartlts = $liUCIts;
720bA        $uiaction = 'RMVUCI';

720bA        $dridata = $uciinfo;
720bA        $dridata2 = $uciinfo2;
720bA        driUCICalled = *on;
720bA        driuciinfo('%RMVUCIADJ': $pprogram: $drireturn: $drimessage:
720bA                 $dridata: $dridata2);

720bA      // adjustment is removing all inventory/uci attached

730bA      when $liAction = 'ADJ' and $liUCITS = *loval
730bA           and $liucitype = '4' and $lirmuci <> ' '
730bA           and ($liaqty1 < 0 or $liaqty2 < 0 or $liaqty3 < 0);
730bA        // special system license
730bA        //if spcllcns;
730bA          //$uiToLcns = kylcns;
730bA        //else;
730bA          //$uiToLcns = lalcns;
730bA        //endif;
730bA        $uiaPartlts = $liUCIts;
730bA        $uiuci = $liRmUci;
730bA        $uiaction = 'RMVUCILCS';

730bA        $dridata = $uciinfo;
730bA        $dridata2 = $uciinfo2;
730bA        driUCICalled = *on;
730bA        driuciinfo('%RMVUCILCS': $pprogram: $drireturn: $drimessage:
730bA                 $dridata: $dridata2);

730bD      //when $liAction = 'ADJ' and $liUCITS = *loval
730bD        //   and ($liaqty1 < 0 or $liaqty2 < 0 or $liaqty3 < 0);
730bD        // special system license
730bD        //if spcllcns;
730bD          //$uiToLcns = kylcns;
730bD        //else;
730bD          //$uiToLcns = lalcns;
730bD        //endif;
730bD        //$uiaPartlts = $liUCIts;
730bD        //$uiaction = 'RMVUCIALL';

730bD        //$dridata = $uciinfo;
730bD        //$dridata2 = $uciinfo2;
730bD        //driUCICalled = *on;
730bD      //driuciinfo('%RMVALLADJ': $pprogram: $drireturn: $drimessage:
730bD         //      $dridata: $dridata2);
730bA
730bA      when $liAction = 'ADJ' and $liUCITS = *loval
730bA           and $liucitype = '3' and $lirmuci <> ' '
730bA           and ($liaqty1 < 0 or $liaqty2 < 0 or $liaqty3 < 0);
730bA        // special system license
730bA        //if spcllcns;
730bA          //$uiToLcns = kylcns;
730bA        //else;
730bA          //$uiToLcns = lalcns;
730bA        //endif;
730bA        $uiaPartlts = $liUCIts;
730bA        $uiuci = $liRmUci;
730bA        $uiaction = 'RMVUCILCS';

730bA        $dridata = $uciinfo;
730bA        $dridata2 = $uciinfo2;
730bA        driUCICalled = *on;
730bA        driuciinfo('%RMVUCILCS': $pprogram: $drireturn: $drimessage:
730bA                 $dridata: $dridata2);
720bA    endsl;

720bA    $uciinfo = $dridata;
720bA    $uciinfo2 = $dridata2;

720bA    select;
720bA      when %error;
720bA        error = *on;
720bA      when $drireturn <> '*OK';
720bA        error = *on;
720bA    endsl;

720bA  endsr;
720bA /end-free
720bA
     *----------------------------------------------------------------
     *  upFrmllAQty   Up log adj qty using From item values
     *----------------------------------------------------------------

      /free
       begsr upFrmllAQty;
650aA    if $lifrmdesg = 'BFC' and $lifrmitype = 'S';
650aA      llaqty1 = $liaqty1;
650aA      llaqty2 = $liaqty2;
650aA      llaqty3 = $liaqty3;
650aA    else;

           if frmSItem.$itumq2 <= 0;
             lowumq2 = 1;
           else;
             lowumq2 = frmSItem.$itumq2;
           endif;

           if frmSItem.$itumq3 <= 0;
             lowumq3 = 1;
           else;
             lowumq3 = frmSItem.$itumq3;
           endif;

           llaqty3    = %rem(lowllaQty : lowumq3);
           lowllaQty = %div(lowllaQty : lowumq3);

           llaqty2    = %rem(lowllaQty : lowumq2);
           lowllaQty = %div(lowllaQty : lowumq2);

           llaqty1    = lowllaQty;

650aA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  upFrmRecQty  Up lowFrmRecQty into licactive qty fields
     *----------------------------------------------------------------

      /free
       begsr upFrmRecQty;
650aA    if $lifrmdesg = 'BFC' and $lifrmitype = 'S';
650aA      laqty1 = $lifrmrqty1;
650aA      laqty2 = $lifrmrqty2;
650aA      laqty3 = $lifrmrqty3;
650aA    else;

           if frmSItem.$itumq2 <= 0;
             lowumq2 = 1;
           else;
             lowumq2 = frmSItem.$itumq2;
           endif;

           if frmSItem.$itumq3 <= 0;
             lowumq3 = 1;
           else;
             lowumq3 = frmSItem.$itumq3;
           endif;

           laQty3    = %rem(lowFrmRecQty : lowumq3);
           lowFrmRecQty = %div(lowFrmRecQty : lowumq3);

           laQty2    = %rem(lowFrmRecQty : lowumq2);
           lowFrmRecQty = %div(lowFrmRecQty : lowumq2);

           laQty1    = lowFrmRecQty;

650aA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  upTollAQty   Up log adj qty using To item values
     *----------------------------------------------------------------

      /free
       begsr upTollAQty;
650aA    if $litodesg = 'BFC' and $litoitype = 'S';
650aA      llaqty1 = $liaqty1;
650aA      llaqty2 = $liaqty2;
650aA      llaqty3 = $liaqty3;
650aA    else;

           if toSItem.$itumq2 <= 0;
             lowumq2 = 1;
           else;
             lowumq2 = toSItem.$itumq2;
           endif;

           if toSItem.$itumq3 <= 0;
             lowumq3 = 1;
           else;
             lowumq3 = toSItem.$itumq3;
           endif;

           llaqty3    = %rem(lowllaQty : lowumq3);
           lowllaQty = %div(lowllaQty : lowumq3);

           llaqty2    = %rem(lowllaQty : lowumq2);
           lowllaQty = %div(lowllaQty : lowumq2);

           llaqty1    = lowllaQty;

650aA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  upToRecQty  Up lowToRecQty into licactive qty fields
     *----------------------------------------------------------------

      /free
       begsr upToRecQty;
650aA    if $litodesg = 'BFC' and $litoitype = 'S';
650aA      laqty1 = $litorqty1;
650aA      laqty2 = $litorqty2;
650aA      laqty3 = $litorqty3;
650aA    else;

           if toSItem.$itumq2 <= 0;
             lowumq2 = 1;
           else;
             lowumq2 = toSItem.$itumq2;
           endif;

           if toSItem.$itumq3 <= 0;
             lowumq3 = 1;
           else;
             lowumq3 = toSItem.$itumq3;
           endif;

           laQty3    = %rem(lowToRecQty : lowumq3);
           lowToRecQty = %div(lowToRecQty : lowumq3);

           laQty2    = %rem(lowToRecQty : lowumq2);
           lowToRecQty = %div(lowToRecQty : lowumq2);

           laQty1    = lowToRecQty;
740bA      if laarea = 'Temp';
740bA        laarea = 'Slot';
740bA        lacode = 'S';
740bA      endif;

650aA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  writeLA     Write LICACTIVE record
     *----------------------------------------------------------------

      /free
       begsr writeLA;

         exsr updateChgFlds;

         write(e) larec;
         if %error;
           llexcd = 'WRTLAERR';
           exsr wrtliclog;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtliclog   Write LICLOG record
     *----------------------------------------------------------------

      /free
       begsr wrtLicLog;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;

         if $liActionU;
           llaction = $liAction;
         endif;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = $liToLcns;

         if $liOLcnsU;
           llolcns = $liOLcns;
         endif;

         if $liToVrfyU;
           llvrfy = $liToVrfy;
         endif;

         if $liFrmOldLcnsU;
           llflcns = $liFrmOldlcns;
         endif;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llsqty1 = $liAQty1;
         llsqty2 = $liAQty2;
         llsqty3 = $liAQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if $liToOrdU;
           llord = $liToOrd;
         endif;
         if $liToSeqU;
           llseq = $liToSeq;
         endif;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
650qA    else;
650qA       if ($liAction = 'PIU' or $liAction = 'PIW'
650qA         or $liAction = 'PBF' or $liAction = 'PSC'
650qA         or $liAction = 'PBL' or laaisl='PAR' or laaisl='PRD'
650qA         or laaisl='LIN' or laaisl='WIP' or $liaction='BXB')
650qA         and $liaction<>'RPL';
650qA          exsr wrtProdLog;
650qA       endif;
         endif;

         clear llrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLicLogAdj   Write LICLOG record for an adjustment
     *----------------------------------------------------------------

      /free
       begsr wrtLicLogAdj;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;

         llaction = $liAction;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;
         llvrfy = 'N';
         llflcns = ' ';

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llsqty1 = $liAQty1;
         llsqty2 = $liAQty2;
         llsqty3 = $liAQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if $liToOrdU;
           llord = $liToOrd;
         endif;
         if $liToSeqU;
           llseq = $liToSeq;
         endif;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
650qA    else;
650qA       if ($liAction = 'PIU' or $liAction = 'PIW'
650qA         or $liAction = 'PBF' or $liAction = 'PSC'
650qA         or $liAction = 'PBL' or laaisl='PAR' or laaisl='PRD'
650qA         or laaisl='LIN' or laaisl='WIP' or $liaction='BXB')
650qA         and $liaction<>'RPL';
650qA          exsr wrtProdLog;
650qA       endif;
         endif;

         clear llrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLicLogChgFifo  Write LICLOG record for chg Fifo
     *----------------------------------------------------------------

      /free
       begsr wrtLicLogChgFifo;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;

         llaction = $liAction;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;

         if $liToVrfyU;
           llvrfy = $liToVrfy;
         endif;

         llflcns = frmLcns;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if $liToOrdU;
           llord = $liToOrd;
         endif;
         if $liToSeqU;
           llseq = $liToSeq;
         endif;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
         endif;

         clear llrec;

       endsr;
      /end-free

650nA*----------------------------------------------------------------
650nA*  wrtLicLogChgStat  Write LICLOG record for chg Status
650nA*----------------------------------------------------------------
650nA
650nA /free
650nA  begsr wrtLicLogChgStat;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;

         llaction = $liAction;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;

         if $liToVrfyU;
           llvrfy = $liToVrfy;
         endif;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

         if $liToStatu;
           lltstat = $liToStat;
         endif;

         if $liFrmStatu;
           llostat = $liFrmStat;
         endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
         endif;

         clear llrec;

       endsr;
      /end-free

600lA*----------------------------------------------------------------
600lA*  wrtLicLogFixNG    Write LICLOG record for fix NG
600lA*----------------------------------------------------------------
600lA
600lA /free
600lA  begsr wrtLicLogFixNG;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;

         llaction = 'NG';

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;

         llvrfy = 'N';
         llflcns = frmLcns;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
         endif;

         clear llrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLicLogTfrFrm   Write LICLOG record for From part of transfer
     *----------------------------------------------------------------

      /free
       begsr wrtLicLogTfrFrm;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    if laaisl = 'USR';
650pA      exsr getUsrInRec;
650pA      saveltrn = usrFLTrn;
650pA      saveltrnSeq = usrFLTrnSeq;
650pA      llfltrn = usrFLTrn;
650pA      llfltrnSeq = usrFLTrnSeq;
650pA    else;
650pA      saveltrn = nxtltrn#;
650pA      saveltrnSeq = nxtltrnseq;
650pA      llfltrn = 0;
650pA      llfltrnSeq = 0;
650pA    endif;

         llaction = $liAction;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;

         if $liFrmVrfyU;
           llvrfy = $liFrmVrfy;
         endif;

         llflcns = $liToLcns;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         llsqty1 = $liAQty1;
         llsqty2 = $liAQty2;
         llsqty3 = $liAQty3;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if $liToOrdU;
           llord = $liToOrd;
         endif;
         if $liToSeqU;
           llseq = $liToSeq;
         endif;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
650qA    else;
650qA       if ($liAction = 'PIU' or $liAction = 'PIW'
650qA         or $liAction = 'PBF' or $liAction = 'PSC'
650qA         or $liAction = 'PBL' or laaisl='PAR' or laaisl='PRD'
650qA         or laaisl='LIN' or laaisl='WIP' or $liaction='BXB')
650qA         and $liaction<>'RPL';
650qA          exsr wrtProdLog;
650qA       endif;
         endif;

         clear llrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLicLogTfrTo   Write LICLOG record for To part of transfer
     *----------------------------------------------------------------

      /free
       begsr wrtLicLogTfrTo;

720aA    if $liemp# = 0;
720aA        exsr GetUsrNum;
720aA    endif;

         llwhse = laWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;

650pA    llfltrn = saveltrn;
650pA    llfltrnseq = saveltrnSeq;

         llaction = $liAction;

         if $liTrn#U;
           lltrn# = $liTrn#;
         endif;

         if $liETrn#U;
           lletrn# = $liETrn#;
         endif;

         if $liLbl#U;
           lllbl# = $liLbl#;
         endif;

         lllcns = lalcns;
         llolcns = laolcns;

         if $liToVrfyU;
           llvrfy = $liToVrfy;
         endif;

         llflcns = frmLcns;

         llrqty1 = laQty1;
         llrqty2 = laQty2;
         llrqty3 = laQty3;

         // 650g Use original full qty if from/to items both normal
         if $psubcmd = '*TFRSLTDTE'
            and $litoitype = ' '
            and $lifrmitype = ' ';
           llrqty1 = $liAQty1;
           llrqty2 = $liAQty2;
           llrqty3 = $liAQty3;
         endif;

         llcode = laCode;
         llarea = laArea;
         llwhdp = laWhdp;
         lldisp = laDisp;
         llaisl = laAisl;
         llloc = laLoc;
         llrlvl = laRlvl;
         llhand = laHand;
         llbase = laBase;
         llpos = laPos;
         llitem = laItem;
         llitype = laIType;

         llsitem = laSItem;
         llsitype = laSIType;
         llprty = laPrty;
         llentd = laEntD;
         llexpd = laExpD;

         if $liToOrdU;
           llord = $liToOrd;
         endif;
         if $liToSeqU;
           llseq = $liToSeq;
         endif;

         if llexcd = ' ' and $liexcdu;
           llexcd  = $liexcd;
         endif;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;
         lldrislot = $lidrislot;

         write(e) llrec;
         if %error;
650qA    else;
650qA       if ($liAction = 'PIU' or $liAction = 'PIW'
650qA         or $liAction = 'PBF' or $liAction = 'PSC'
650qA         or $liAction = 'PBL' or laaisl='PAR' or laaisl='PRD'
650qA         or laaisl='LIN' or laaisl='WIP' or $liaction='BXB')
650qA         and $liaction<>'RPL';
650qA          exsr wrtProdLog;
650qA       endif;
         endif;

         clear llrec;

       endsr;
      /end-free
650q
650qA*----------------------------------------------------------------
650qA*  wrtProdLog    Write Production Log for certain actions
650qA*----------------------------------------------------------------
650qA
650qA /free
650qA  begsr wrtProdLog;
650qA
650qA    // Open Production Log File
650qA
650qA    exsr fileOpenpp;
650qA    if error;
650qA        leavesr;
650qA    endif;
650qA
700b     // Open Production Date File
700b
700b     exsr fileOpenpd;
700b     if error;
700b         leavesr;
700b     endif;
700b
650qA    // create Production Log entry
650qA
650qA    plwhse = lawhse;
650qA    plitem = laitem;
650qA
650qA    if $liPrdSitmu;
650qA       plfgitm = $liPrdSitm;
650qA    else;
650qA       plfgitm = ' ';
650qA    endif;
650qA
650qA    plaction = $liAction;
650qA    plFLCNs = laolcns;
650qA    plTlcns = lalcns;
650qA
650qA    if $liAction = 'PBL'
650qA       and $liToLcns <> ' ';
650qA       plTlcns = $liToLcns;
650qA    endif;
650qA
710cD  //  if $liMfglneu;
710cC  //     if $liMfgLne = 0;
650qA          plline = larlvl;
710cD  //     else;
710cD  //        plline = $liMfgLne;
710cD  //     endif;
710cD  //  else;
710cD  //     plline = larlvl;
710cD  //  endif;
650qA
650qA      // get Production Date for Mfg Line
650qA    chain (lawhse:plline:'O') prdDate1;
650qA    if %found(prdDate1);
650qA       plprdDte = pddate;
650qA    else;
650qA       plprdDte = %dec(%char(%date():*iso0):8:0);
650qA    endif;
650qA
650qA    pldisp = ladisp;
710 A
710 A    plrmuci = $liRmUci;
650qA
650qA    if $liGS1u;
650qA       plgs1 = $ligs1;
650qA    else;
650qA       plgs1 = '';
650qA    endif;
650qA
720cA    if (prdLogQty1<>0 or prdLogQty2<>0 or prdLogQty3<>0);
720cA      plqtyn = prdLogQty1;
720cA      plqty1 = prdLogQty2;
720cA      plqty2 = prdLogQty3;
720cA    else;
650qA      plqtyn = llaqty1;
650qA      plqty1 = llaqty2;
650qA      plqty2 = llaqty3;
720cA    endif;
650qA
650qA    if $liPrdWgtu;
650qA       plweght = $liPrdWgt;
650qA    else;
650qA       plweght = 0;
650qA    endif;
650qA
650qA    // if calling program sends in liPRDWGT as 999999.999
650qA    // that says it was unable to get specific weight.
650qA    // DRILICENSE will now look to the license info for
650qA    // average weight, then to item master for box weight.
650qA    if plweght = 999999.999;
650qA       plweght = 0;
650qA       chain (lawhse:laolcns:1) licinfo;
650qA       if %found(licinfo);
650qA          plweght = lnavglbs;
650qA       endif;
650qA       if plweght = 0;
650qA          chain (lawhse:laitem) piritem;
650qA          if %found(piritem);
650qA             plweght = itswgt;
650qA          endif;
650qA       endif;
650qA    endif;
650qA
650qA
650qA    if $liPrdWou;
650qA       plbfcwo = $liPrdWo;
650qA    else;
650qA       plbfcwo = ' ';
650qA    endif;
650qA
650qA    if $liTareWgtu;
650qA       pltare = $liTareWgt;
650qA    else;
650qA       pltare = 0;
650qA    endif;
650qA
650qA    plpgm = #pgm;
650qA    pluser = #user;
650qA    pljob = #job;
650qA
650qA    if $liser#u;
650qA       pllsts = $liser#;
650qA    else;
650qA       pllsts = ' ';
650qA    endif;
650qA
650qA    plCUSTWO = ' '; // Update once BFC Work Order pr              ocess
650qA
650qA    if $liTrn#u;
650qA       pltrn# = $litrn#;
650qA    endif;
650qA
650qA    if $lilbl#u;
650qA       pllbl# = $lilbl#;
650qA    endif;
650qA
650qA    plcts = %timestamp();
650qA    pldtetim = %subst(%char(plcts):1:4) +
650qA               %subst(%char(plcts):6:2) +
650qA               %subst(%char(plcts):9:2) +
650qA               %subst(%char(plcts):12:2) +
650qA               %subst(%char(plcts):15:2) +
650qA               %subst(%char(plcts):18:2);
650qA    write plrec;
650qA
650qA  endsr;
650qA /end-free

600eA*----------------------------------------------------------------
600eA*  noStock    Write LICLOG record for *NOSTOCK
600eA*----------------------------------------------------------------
600eA
600eA /free
600eA  begsr noStock;

         llwhse = $liToWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;
650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;
         llaction = $liAction;
         lltrn# = $liTrn#;
         lletrn# = $liETrn#;
         lllbl# = $liLbl#;
         lllcns = $liToLcns;
640fA    llolcns = $liOLcns;

         llaqty1 = $liAQty1;
         llaqty2 = $liAQty2;
         llaqty3 = $liAQty3;

         llsqty1 = $liAQty1;
         llsqty2 = $liAQty2;
         llsqty3 = $liAQty3;

         llitem = $liToItem;
         // llsitem = laSItem;
         llexcd  = $liexcd;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;

         write(e) llrec;
         if %error;
         endif;

         clear llrec;

       endsr;
      /end-free

600gA*----------------------------------------------------------------
600gA*  xdk        Write LICLOG record for *XDK
600gA*----------------------------------------------------------------
600gA
600gA /free
600gA  begsr xdk;

         llwhse = $liToWhse;

         llltrn = nxtltrn#;
650pA    nxtltrnSeq += 1;
650pA    llltrnseq = nxtltrnSeq;
650pA    llfltrn = 0;
650pA    llfltrnSeq = 0;
         llaction = $liAction;
         lltrn# = $liTrn#;
         lletrn# = $liETrn#;
         lllbl# = $liLbl#;
         lllcns = $liToLcns;
640fA    llolcns = $liOLcns;

         llaqty1 = $liAQty1;
         llaqty2 = $liAQty2;
         llaqty3 = $liAQty3;

         llsqty1 = $liAQty1;
         llsqty2 = $liAQty2;
         llsqty3 = $liAQty3;

         llitem = $liToItem;
         // llsitem = laSItem;
         llexcd  = $liexcd;

650nA    if $liToStatu;
650nA      lltstat = $liToStat;
650nA    endif;

650nA    if $liFrmStatu;
650nA      llostat = $liFrmStat;
650nA    endif;

650oA    if $liItmChgu;
650oA      llichg = $liItmChg;
650oA    endif;

         exsr getcurrstamp;
         lladdts = currstampsys;
         lladduc = currstampuc;
         lladdcpgm = $liPgm;
         lladdjpgm = #pgm;
         lladdemp = $liEmp#;
         lladdeusr = $liUser;
         lladdcusr = #curruser;
         lladdjusr = #user;
         lladdjob = #job;
         lladdnbr = #jobnbr;

         lldrilic = $psubcmd;

         write(e) llrec;
         if %error;
         endif;

         clear llrec;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  SubCommand Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyAdjSltQty  Verify information for *ADJSLTQTY
     *----------------------------------------------------------------

      /free
       begsr vfyAdjSltQty;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

600iA    exsr vfyToWhdpSent;
600iA    if error;
600iA      leavesr;
600iA    endif;

600iA    exsr vfyToDispSent;
600iA    if error;
600iA      leavesr;
600iA    endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

         // Get item information.

         kywhse = $liToWhse;
         kyitem = $liToSItem;
         exsr getItem;
         if error;
           leavesr;
         endif;
         toSItem = $item;
600mA    frmSItem = $item;

       endsr;
      /end-free

610aA*----------------------------------------------------------------
610aA*  vfyChgDP     Verify information for *CHGDP
610aA*----------------------------------------------------------------
610aA
610aA /free
610aA  begsr vfyChgDP;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToLcnsSent;
         if error;
           leavesr;
         endif;

         exsr vfyFrmOldLcnsSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

600iA*----------------------------------------------------------------
600iA*  vfyChgSltFifo  Verify information for *CHGSLTFIF
600iA*----------------------------------------------------------------
600iA
600iA /free
600iA  begsr vfyChgSltFifo;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

650nA*----------------------------------------------------------------
650nA*  vfyChgSltStat  Verify information for *CHGSLTSTS
650nA*----------------------------------------------------------------
650nA
650nA /free
650nA  begsr vfyChgSltStat;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyChk4Exist  Verify information for *CHK4EXIST
     *----------------------------------------------------------------

      /free
       begsr vfyChk4Exist;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToBaseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

710fA*----------------------------------------------------------------
710fA*  vfyChk4PRLic  Verify information for *CHK4PRLIC
710fA*----------------------------------------------------------------

710fA /free
710fA  begsr vfyChk4PRLic;

710fA    exsr inzchkflds;

710fA    // Verify that necessary fields were sent.

710fA    exsr vfyToWhseSent;
710fA    if error;
710fA      leavesr;
710fA    endif;

710fA    exsr vfyToWhdpSent;
710fA    if error;
710fA      leavesr;
710fA    endif;

710fA    exsr vfyToDispSent;
710fA    if error;
710fA      leavesr;
710fA    endif;

710fA    exsr vfyToSItemSent;
710fA    if error;
710fA      leavesr;
710fA    endif;

710fA  endsr;
710fA /end-free


     *----------------------------------------------------------------
     *  vfyDeleteItm  Verify information for *DELETEITM
     *----------------------------------------------------------------

      /free
       begsr vfyDeleteItm;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyDeleteSlt  Verify information for *DELETESLT
     *----------------------------------------------------------------

      /free
       begsr vfyDeleteSlt;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;


         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  vfyDtlOrphan  Verify information for *DLTORPHAN
640aA*----------------------------------------------------------------
640aA
      /free
       begsr vfyDltOrphan;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyDtlSltItm  Verify information for *DLTSLTITM
     *----------------------------------------------------------------

      /free
       begsr vfyDltSltItm;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;


         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

760aA*----------------------------------------------------------------
760aA*  vfyGetLabel   Verify information for *GETLABEL
760aA*----------------------------------------------------------------

760aA /free
760aA  begsr vfyGetLabel;

760aA    exsr inzchkflds;

760aA    // Verify that necessary fields were sent.

760aA    exsr vfyToWhseSent;
760aA    if error;
760aA      leavesr;
760aA    endif;

760aA    exsr vfyLabelSent;
760aA    if error;
760aA      leavesr;
760aA    endif;

760aA  endsr;
760aA /end-free

     *----------------------------------------------------------------
     *  vfyGetLcns    Verify information for *GETLCNS
     *----------------------------------------------------------------

      /free
       begsr vfyGetLcns;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToLcnsSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

600cA*----------------------------------------------------------------
600cA*  vfyGetSfgOss  Verify information for *GETSFGOSS
600cA*----------------------------------------------------------------
600cA
600cA /free
       begsr vfyGetSfgOss;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
600oA*  vfySetLicFifo  Verify information for *SETFIFO
     *----------------------------------------------------------------

      /free
       begsr vfySetLicFifo;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToLcnsSent;
         if error;
           leavesr;
         endif;

         exsr vfyToPrtySent;
         if error;
           leavesr;
         endif;

         exsr vfyToEntdSent;
         if error;
           leavesr;
         endif;

         exsr vfyToExpdSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

710hA*----------------------------------------------------------------
710hA*  vfySetOLicFifo  Verify information for *SETOLCNS
710hA*----------------------------------------------------------------

710hA /free
710hA  begsr vfySetOLicFifo;

710hA    exsr inzchkflds;

710hA    // Verify that necessary fields were sent.

710hA    exsr vfyToWhseSent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA    exsr vfyToLcnsSent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA    exsr vfyOLcnsSent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA    exsr vfyToPrtySent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA    exsr vfyToEntdSent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA    exsr vfyToExpdSent;
710hA    if error;
710hA      leavesr;
710hA    endif;

710hA  endsr;
710hA /end-free

600aA*----------------------------------------------------------------
600aA*  vfyGetSltFifo  Verify information for *GETSLTFIF
600aA*----------------------------------------------------------------
600aA
600aA /free
600aA  begsr vfyGetSltFifo;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

         exsr vfyToSItemSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyGetSltLIC  Verify information for *GETSLTLIC
     *----------------------------------------------------------------

      /free
       begsr vfyGetSltLic;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyGetSltQty  Verify information for *GETSLTQTY
     *----------------------------------------------------------------

      /free
       begsr vfyGetSltQty;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToDispSent;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfySetLcns    Verify information for *SETLCNS
     *----------------------------------------------------------------

      /free
       begsr vfySetLcns;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyToLcnsSent;
         if error;
           leavesr;
         endif;

         exsr vfyActionSent;
         if error;
           leavesr;
         endif;

         exsr vfyAQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToRQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToCodeSent;
         if error;
           leavesr;
         endif;

         exsr vfyToAreaSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToItemSent;
         if error;
           leavesr;
         endif;

         // Validate warehouse

         exsr vfyFldToWhse;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyTfrLcns    Verify information for *TFRLCNS
     *----------------------------------------------------------------

      /free
       begsr vfyTfrLcns;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToLcnsSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyActionSent;
         if error;
           leavesr;
         endif;

         exsr vfyAQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToRQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToCodeSent;
         if error;
           leavesr;
         endif;

         exsr vfyToAreaSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToItemSent;
         if error;
           leavesr;
         endif;

         exsr vfyFrmNewLcnsSent;
         if error;
           leavesr;
         endif;

         exsr vfyFrmOldLcnsSent;
         if error;
           leavesr;
         endif;

         // Validate warehouse

         exsr vfyFldToWhse;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyTfrSltDte  Verify information for *TFRSLTDTE
     *----------------------------------------------------------------

      /free
       begsr vfyTfrSltDte;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyActionSent;
         if error;
           leavesr;
         endif;

         exsr vfyAQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToRQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToCodeSent;
         if error;
           leavesr;
         endif;

         exsr vfyToAreaSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToItemSent;
         if error;
           leavesr;
         endif;

         // Validate warehouse

         exsr vfyFldToWhse;
         if error;
           leavesr;
         endif;

         // Get To Slot item information.

         kywhse = $liToWhse;
         kyitem = $liToSItem;
         exsr getItem;
         if error;
           leavesr;
         endif;
         toSItem = $item;

         // Get From Slot item information.

         kywhse = $liFrmWhse;
         kyitem = $liFrmSItem;
         exsr getItem;
         if error;
           leavesr;
         endif;
         frmSItem = $item;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyTfrSltRev  Verify information for *TFRSLTREV
     *----------------------------------------------------------------

      /free
       begsr vfyTfrSltRev;

         exsr inzchkflds;

         // Verify that necessary fields were sent.

         exsr vfyToWhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyActionSent;
         if error;
           leavesr;
         endif;

         exsr vfyAQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToRQtysSent;
         if error;
           leavesr;
         endif;

         exsr vfyToCodeSent;
         if error;
           leavesr;
         endif;

         exsr vfyToAreaSent;
         if error;
           leavesr;
         endif;

         exsr vfyToWhdpSent;
         if error;
           leavesr;
         endif;

         exsr vfyToItemSent;
         if error;
           leavesr;
         endif;

         // Validate warehouse

         exsr vfyFldToWhse;
         if error;
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyFldToWhse   Verify warehouse
     *----------------------------------------------------------------

      /free
       begsr vfyFldToWhse;

         vfyWhseCalled = *on;
         vfyWhse('*VERIFY': '*NONE': $liToWhse: $vdesc:
                 $vreturn: $vmessage: $vmsgk);

         select;

           when %error;
             error = *on;
             $liToWhsee = $drierror;
             $preturn  = 'CALLERROR';
             $pmessage = 'Error occured on call to VFYWHSE/'
                       + %trim($vcommand) + ' from ' + #pgm;

           when $vreturn <> '*OK';
             error = *on;
             $liToWhsee = $drierror;
             $preturn = $vreturn;
             $pmessage = $vmessage;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Sent Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyActionSent  Verify that action was sent
     *----------------------------------------------------------------

      /free
       begsr vfyActionSent;

         if not $liActionU;
           error = *on;
           $liActionE = $drierror;
           $preturn  = 'ACTNOTSNT';
           $pmessage = 'Action code must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyAQtysSent  Verify that Action Qtys were sent
     *----------------------------------------------------------------

      /free
       begsr vfyAQtysSent;

         if not $liAQty1U;
           error = *on;
           $liAQty1E = $drierror;
           $preturn  = 'AQTYNOTSNT';
           $pmessage = 'Action quantity must be sent';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToAreaSent  Verify that area was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToAreaSent;

         if not $liToAreaU;
           error = *on;
           $liToAreaE = $drierror;
           $preturn  = 'AREANOTSNT';
           $pmessage = 'Area must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToBaseSent  Verify that To Base slot was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToBaseSent;

         if not $liToBaseU;
           error = *on;
           $liToBaseE = $drierror;
           $preturn  = 'BASENOTSNT';
           $pmessage = 'Base slot must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToCodeSent  Verify that location code was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToCodeSent;

         if not $liToCodeU;
           error = *on;
           $liToCodeE = $drierror;
           $preturn  = 'LCODNOTSNT';
           $pmessage = 'Location code must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToDispSent  Verify that slot display was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToDispSent;

         if not $liToDispU;
           error = *on;
           $liToDispE = $drierror;
           $preturn  = 'DISPNOTSNT';
           $pmessage = 'Slot display must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyFrmOldLcnsSent  Verify that From Old license was sent
     *----------------------------------------------------------------

      /free
       begsr vfyFrmOldLcnsSent;

         if not $liFrmOldLcnsU;
           error = *on;
           $liFrmOldLcnsE = $drierror;
           $preturn  = 'FOLDNOTSNT';
           $pmessage = 'From Old License must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyFrmNewLcnsSent  Verify that From New license was sent
     *----------------------------------------------------------------

      /free
       begsr vfyFrmNewLcnsSent;

         if not $liFrmNewLcnsU;
           error = *on;
           $liFrmNewLcnsE = $drierror;
           $preturn  = 'FNEWNOTSNT';
           $pmessage = 'From New License must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyFrmWhdpSent  Verify that From department was sent
     *----------------------------------------------------------------

      /free
       begsr vfyFrmWhdpSent;

         if not $liFrmWhdpU;
           error = *on;
           $liFrmWhdpE = $drierror;
           $preturn  = 'FWHDNOTSNT';
           $pmessage = 'From Dept code must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyFrmWhseSent  Verify that from warehouse was sent
     *----------------------------------------------------------------

      /free
       begsr vfyFrmWhseSent;

         if not $liFrmWhseU;
           error = *on;
           $liFrmWhseE = $drierror;
           $preturn  = 'FWHSNOTSNT';
           $pmessage = 'From Warehouse code must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyOLcnsSent  Verify that original license was sent
     *----------------------------------------------------------------

      /free
       begsr vfyOLcnsSent;

         if not $liOLcnsU;
           error = *on;
           $liOLcnsE = $drierror;
           $preturn  = 'OLCNNOTSNT';
           $pmessage = 'Original License must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToItemSent  Verify that item was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToItemSent;

         if not $liToItemU;
           error = *on;
           $liToItemE = $drierror;
           $preturn  = 'ITEMNOTSNT';
           $pmessage = 'Item must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToOldLcnsSent  Verify that To Old license was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToOldLcnsSent;

         if not $liToOldLcnsU;
           error = *on;
           $liToOldLcnsE = $drierror;
           $preturn  = 'TOLDNOTSNT';
           $pmessage = 'To Old License must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToLcnsSent  Verify that To license was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToLcnsSent;

         if not $liToLcnsU;
           error = *on;
           $liToLcnsE = $drierror;
           $preturn  = 'TLCNNOTSNT';
           $pmessage = 'To License must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
600oA*  vfyToPrtySent  Verify Pick Prority was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToPrtySent;

         if not $lItoprtyu;
           error = *on;
           $liToPrtyE = $drierror;
           $preturn  = 'TPRTNOTSNT';
           $pmessage = 'To Pick Priority must be sent';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  vfyToRQtysSent  Verify that Result Qtys were sent
     *----------------------------------------------------------------

      /free
       begsr vfyToRQtysSent;

         if not $liToRQty1U;
           error = *on;
           $liToRQty1E = $drierror;
           $preturn  = 'RQTYNOTSNT';
           $pmessage = 'Result quantity must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToSItemSent  Verify that slot item was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToSItemSent;

         if not $liToSItemU;
           error = *on;
           $liToSItemE = $drierror;
           $preturn  = 'SITMNOTSNT';
           $pmessage = 'Slot item must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToWhdpSent  Verify that department was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToWhdpSent;

         if not $liToWhdpU;
           error = *on;
           $liToWhdpE = $drierror;
           $preturn  = 'TWHDNOTSNT';
           $pmessage = 'To Department code must be sent';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  vfyToWhseSent  Verify that warehouse was sent
     *----------------------------------------------------------------

      /free
       begsr vfyToWhseSent;

         if not $liToWhseU;
           error = *on;
           $liToWhseE = $drierror;
           $preturn  = 'TWHSNOTSNT';
           $pmessage = 'To Warehouse code must be sent';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
600o *  vfyToEntdSent  Verify Entry Date
     *----------------------------------------------------------------

      /free
       begsr vfyToEntdSent;

         if not $liToEntdu;
           error = *on;
           $liToEntdE = $drierror;
           $preturn  = 'TENTDNOTSNT';
           $pmessage = 'To Entry Date Must Be Sent';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
600o *  vfyToExpdSent  Verify Expiration Date
     *----------------------------------------------------------------

      /free
       begsr vfyToExpdSent;

         if not $liToExpdu;
           error = *on;
           $liToExpdE = $drierror;
           $preturn  = 'TEXPDNOTSNT';
           $pmessage = 'To Expiration Date Must Be Sent';
         endif;

       endsr;
      /end-free
760aA*----------------------------------------------------------------
760aA*  vfyLabelSent   Verify that label was sent
760aA*----------------------------------------------------------------

760aA /free
760aA  begsr vfyLabelSent;

760aA    if not $liLbl#U;
760aA      error = *on;
760aA      $liLbl#E = $drierror;
760aA      $preturn  = 'LBL#NOTSNT';
760aA      $pmessage = 'Pick Label not sent';
760aA    endif;

760aA  endsr;
760aA /end-free

GFC A*----------------------------------------------------------------
GFC A*  zeroLicExp    Set expiration date to zero in all licenses
GFC A*                for the incoming slot item.
GFC A*----------------------------------------------------------------
GFC A
GFC A /free
GFC A  begsr zeroLicExp;

         kyWhse = $liToWhse;
         kyItem = $liToSItem;

         // Open licactive2 file

         exsr fileOpenLA2;
         if error;
             leavesr;
         endif;

         setll (kywhse: kyitem) licactive2;

         dow forever = forever;

           reade (kywhse: kyitem) licactive2;
           if %eof(licactive2);
             leave;
           endif;

           laexpd  = 0;

           update larec2;

       enddo;

       endsr;
      /end-free

730dA*----------------------------------------------------------------
730dA*  zzrti     Export Real time interface.
730dA*----------------------------------------------------------------

730dAC     zzrti         begsr

730dA /free
750aD   //if $liaction <> 'ADJ';
750aM   if $liaction <> 'ADJ' and $liaction <> 'RTN';
730dA     leavesr;
730dA   endif;
730dA   // Is this real time staging
730dA   GetOptions(%editc(0:'X'):
730dA              '*FTP': '001': '001': ExportType);
730dA   if ExportType = 'R';
730dA /end-free
730dAC                   call      'IT726S'
730dAC                   parm                    $liToWhse

730dAc                   endif

730dAC                   endsr

