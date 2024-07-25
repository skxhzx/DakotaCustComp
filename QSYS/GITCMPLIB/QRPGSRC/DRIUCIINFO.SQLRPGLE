      /copy qcopysrc,hspecs
740aMH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
     *
     *
     * COMPILING. In order to compile this program you will need
     *            to use options which allow it to work correctly
     *            between machines. These options are---
     *
     *               COMMIT = *NONE
     *               RDB    = Machine name that you will connect to.
     *               DLYPRP = *YES
     *               SQLPKG = The name & library that you want to
     *                        use for the package. This will put the
     *                        package on the RDB machine that you
     *                        specify.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  DRIUCIINFO  Dakota realtime interface - UCI info
     *  12 Sept 2012
     *  Lynn McMahon
     *
640  *    09/12/12  LMC  6.40
     *      - Created
     *
640a *    10/01/12  DAS  6.40a
     *      - Added command *SELECT
     *      - Changed command *GETALL to *GETLICREC
     *      - Renamed routine GetAllFields to FillDS.
     *      - Renamed routine RecFill to FillRec.
     *
650a *    06/17/13  LMC  6.50a
     *      - Recompile UCIINFO database change
     *
650b *    10/04/12  DAS  6.50b
     *      - Revised Add routine to populate $uiuciLcns if blank.
     *      - Revised to add LICINFO record if necessary.
     *
650c *    11/29/12  LMC  6.50c
     *      - Added command *GET1UCI
     *      This routine is used to get one uci record at a time for
     *      temporary license processing. Used by X-Dock, putaway by
     *      label, *no stock returns.
     *      - Based UCI found in GETUCI only if the UISELTRN# = 0
     *      - Added command * GET2RTN - used to get the previously
     *      selected UCI being returned
     *      - Added command *RETURN
     *      - Added command *RTNWHLORD
     *
650d *    01/16/13  LMC  6.50d
     *      - Selection uci
     *
650e *    03/06/13  LMC  6.50e
     *      - Added command *SELCWSEQ
     *
650f *    04/18/13  LMC  6.50f
     *      - Added command *ADDGS199
     *      - Added command *CHKASGN
650g *    07/02/13  LMC  6.50g
     *      - Don't check for existence on Add if coded as Non Unique
650h *    07/03/13  LMC  6.50h
     *      - Added command *CNT4BLK
     *      - Added command *GET4BLK
     *      - Added command *SEL4BLK
650i *    07/18/13  LMC  6.50I
     *      - Added command *SELECTPTI
650j *    07/24/13  LMC  6.50j in process
     *      - Added command *CNT4PTI
     *      - Added command *CNT4LCNS
     *      - Added edit in vfyselectpti to validate item being
     *        selected match the item in the ucifile for this PTI.
650k *    09/11/13  LMC  6.50k
     *      - Added command *CHKGS199
650l *    10/23/13  LMC  6.50l
     *      - Added logic to assume NON-unique UCI if breakdown uom
     *      is being selected.
650m *    02/18/14  LMC  6.50m
     *      - Need to send back error from GetLicRec if not found.
650n *    03/11/14  LMC  6.50n
     *      - Enh - When uci recieving is on and usi selection is not
     *      on yet, problems can occur if uci is returned, but was
     *      never marked as selected. So we will ignore unique code
     *      on returns until uci selection is turned on.
650o *    08/11/14  LMC  6.50o
     *      - Added command *CNT4RUN
     *      - Added command *UNDORUN
     *      - Added command *SELRUN
     *      - Added command *RUNDONE
     *      - Added command *GET1RUN
650p *    09/16/14  LMC  6.50p
     *      - invalid Date in ADDLICINFO procedure if no date is
     *      - extracted from the barcode
650q *    07/28/14  LMC  6.50q Added new commands for CW122 process
     *      - Added command *DELETECW
     *      - Added command *UPDATECW
650s *    10/01/14  LMC  6.50s
     *      - Added command *RESETUCI
650t *    12/10/14  KDE  6.50t
     *      - Added commands *CHKREPLEN and *REPLENUSE
650u *    02/13/15  LMC  6.50u
     *      - Fix: DELETEONE was assuming the UCI was unique.
     *      Added the uiseq to the sql. To ensure we only delete
     *      the one sequence number.
700a *    03/26/15  LMC  7.00a
     *      - Enh: Added new file CHGITEM. If the uci scanned
     *      doesn't find a match in the upc file for the item being
     *      selected. We now check to see if the original item from
     *      the scanned UCI has ever been changed to the item being
     *      selected. If a record exists for this combination in the
     *      ITEMCHG file, we will allow this UCI to be selected.
700b *    04/30/15  LMC  7.00b
     *      - Fix: Changed DELETECW & UPDATECW to use the UISELCSEQ
     *      instead of the UISEQ.
700c *    08/28/15  LMC  7.00c
     *      - Added command *GET1RTN
     *      This routine is used to get one uci record at a time for
     *      returns in order to update the previously selected UCI
     *      with the return transaction number.
700d *    09/15/15  LMC  7.00d
     *      - Fix if GTIN/dakota item combo is not found in UPC file
     *      and the UCI was not previously scanned during inbound for
     *      a different item/itemchg the scan will error with an item
     *      mismatch.
700e *    04/01/15  KDE  7.00e
     *      - Call fillds in CheckReplen to return data if found
700f *    04/14/15  KDE  7.00f
     *      - Added command *DELETEUCI to delete a specific UCI
     *        that was originally added via Box Breaker
700j *    10/03/16  LMC  7.00j
     *      -  For *SELECT, when the UCI code starts with '99TRAX'
     *         Treat as a unique UCI code.
700k *    10/17/16  LMC  7.00k
     *      -  For *SELECT, when the UCI code starts with '99TRAX'
     *         We need to send back a different Error message if the
     *         label has already been selected.
700lA*    11/04/16  LMC  7.00l
     *      - Enh: UPC file has a database change. Recompile only.
700m *    12/13/16  LMC  7.00m
     *      -  Enhanced error messages for INVLDUCI.
700n *    01/05/17  LMC  7.00n
     *      -  Fix - vfyselect - moved getitem up before the edits.
710a *    01/31/17  LMC  7.10a
     *      -  Fix - vfyselectAI99 validate item
710b *    03/08/17  TAB  7.10b
     *      - Added command *CKUCISPLT.
710c *    06/28/17  LMC  7.10c
     *      - Mod 650l no longer applies. We will use the same uci
     *        encoding for the breakdown uom as we do for the normal
     *        uom. If the item is setup as unique, all uom will be
     *        requiring unique gs1 scans
710d *    07/07/17  LMC  7.10d
     *      - Runner selection was not finding that the uci had
     *        previously been selected. We send the runner transaction
     *        number in and store it in the return transaction number
     *        so we can reload the uci scanned count if necessary.
     *        This was causing the GetSelected process to fail because
     *        if a uci has been returned, it is available to be
     *        selected again.
     *        Modified GetSelected to do a different check for the
     *        SELRUN command.
710e *    07/07/17  TAB  7.10e
     *      - Fix:  Revert back to CHKREPLEN instead of *CKUCISPLT.
     *              Had to change several things in CHKREPLEN to
     *              do everything correctly
720a *    05/15/18  LMC  7.20a
     *      - Enh:  In GetLicRec need to have logic to exclude records
     *              that are for PTI only. NO weight in records and
     *              the uiucilcns starts with P:.
720b *    05/23/18  LMC  7.20b
     *      - Enh:  New command *SELECTUPC this will store upc records
     *              in the UCIINFO File.
720c *    07/30/18  LMC  7.20c
     *      - Enh:  New command *COUNT4UNF this will send back a count
     *              for the number of labels that were previously
     *              scanned - used when we allow the user to restart
     *              an unfinished transaction if RF Pick.
720d *    08/08/18  LMC  7.20d
     *      - Fix:  Don't use item on the selectionn for *COUNT4UNF.
720e *    11/09/18  LMC  7.20e
     *      - Enh - Uci Tracking
     *      - Added commands *UPDATELIC and *UPDLICUCI to move
     *        original license  to field UIUCILCNS and update
     *        UILCNS with new license.
     *      - Added $cbwhse to CVTBAR call because p.CVTBAR had been
     *        changed in PIRENH700.
     *      - Added commands *CHK4MOVE
     *      - Added commands *CHK4ADJ
     *      - Added commands *UPDPARTL
     *      - Added commands *ADJCANCEL
     *      - Added commands *VFYCURMV - Verify current movement
     *        VFYCURMV - is used to make sure the same uci is not
     *        scanned again during current movement.
     *      - $uciinfo is maxed out - activated $uciinfo2
     *      - Added ucilog
     *      - Populate new parms for new UCIINFO file format.
     *      - Added new file UCIINFOEXA.
720f *    01/02/19  LMC  7.20f
     *      - Added command *CNT4LBL
730a *    01/30/19  LMC  7.30a
     *      - Little bit of logic change to uci tracking adjustments
     *        We will now be using the label number to get the link
     *        between the itemadj and the ucilog files for canopy.
730b *    01/31/19  LMC  7.30b
     *      - DELETEUCI - was not writing correct info to ucilog.
730c *    02/19/19  LMC  7.30c
     *      - GETADJUCI - Need to get each uci one at a time in order
     *        to determine the action needed by the adjustment program
     *      - RMVADJTIM- Need to remove the UIAPARTLTS value this
     *        uci does not need to be adjusted or transferred.
     *      - GETMISUCI - Need to get each uci one at a time in order
     *        to determine the action needed by the adjustment program
     *        for uci's that were not scanned with adjustment type 3.
730d *    04/24/19  LMC  7.30d
     *      - GETLICWGT - Need to get total weight for a license.
     *      - Fix GETMISUCI - selection needs to be on the timestamp
     *        not matching the time stamp sent in, instead of nodate.
730e *    08/07/19  LMC  7.30e
     *      - Reset UCIWORK loaded flag on rcvcancel.
     *      - allowing for the user to  start the uci receipt over
730f *    08/14/19  LMC  7.30f
     *      - Added UndoSelect/*UNDOSEL
     *      - Added Get4UnPick/*GET4UN
730g *    08/19/19  LMC  7.30g
     *      - Fix - single uci adjust out, to clear the partial
     *        timestamp field that is used as a place holder.
730h *    08/22/19  LMC  7.30h
     *      - Fix - GS1 99 labels that we generate should always
     *        be considered unique. That label can not be on more
     *        than one box.
730i *    08/27/19  LMC  7.30i
     *      - Enh - Added GET4LBL
     *        Needed this for or402 in order to get the label record.
     *      - Enh - Added WGT4LBL/Weight4LBL- Copied from GetLicWgt
     *        Needed this for or402 in order to get the Weight for
     *        Pick to weight items in case the user has abnormal end
     *        after scanning, prior to label update.
730j *    10/04/19  KDE  7.30j
     *      - Enh - Added GETPRDDTE
     *        Added for Westside Returns.  Need to get oldest Production
     *        date associated with passed in selection label and item
730k *    11/18/19  LMC  7.30k
     *      - Fix - Error code for uciinfoexa should be ERRADDREC5
730l *    11/19/19  LMC  7.30l
     *      - Fix - GET1UCI command - make sure we get a successful
     *        return on uciinfoexa otherwise don't fillds.
730m *    12/27/19  LMC  7.30m
     *      - Fix - Deleteone - specify the $uiucilcns as part of
     *        the where clause to make sure we get the correct record.
740a *    01/07/20  LMC  7.40a
     *      - Enh - Added new command REDUCE to accomodate Canopy scan
     *        to usage where we will reduce the weight in the uciinfo
     *        record, this will mean the weight in the gs1 barcode
     *        will no longer match the weight in the uciinfo file.
     *      - Enh - Added new command GETLBS to accomodate Canopy scan
     *        to usage where we will reduce the weight in the uciinfo
     *        record, this will mean the weight in the gs1 barcode
     *        will no longer match the weight in the uciinfo file.
740b *    04/22/20  LMC  7.40b
     *      - Enh - Added Additional parms to cvtbar.
740c *    05/28/20  LMC  7.40c
     *      - Enh - Added fillds to *GET command.
740d *    06/25/20  LMC  7.40d
     *      - Enh - Moved up getitem so we have the vendor to send
     *        to cvtbar.
740e *    08/20/20  LMC  7.40e
     *      - Enh - Added command *CNT4UCI. Will be used to determine
     *        if we need to display a list of uci's from inquiry info.
     *      - Enh - Added command *GETINFO. Will be used for single
     *        UCI lookup.
     *      - Enh - Added return transaction to the fillds routine.
740f *    12/01/20  LMC  7.40f
     *      - Enh - Added command *CLEANUP1 for selection cleanup.
740f *    12/02/20  LMC  7.40f
     *      - Enh - Added command *CLEANUP2 for receiving wgt cleanup
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * More Notes
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

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add record to new UCIINFO format
      *
650fA *      *ADDGS199         Add internal gs199 to new UCIINFO format
      *
720eA *      *ADJCANCEL        Cancel from Adjustments - UCI added need deleted
      *
650KA *      *CHKGS199         Check for active GS199 for replacement
      *
650Kt *      *CHKREPLEN        Check for active during replenishment
      *
720eA *      *CHK4ADJ          Check for active UCI Adjustment
      *
720eA *      *CHK4MOVE         Check for active UCI movement/tracking
      *
740fA *      *CLEANUP1         Cleanup for Selection
      *
740gA *      *CLEANUP2         Cleanup for receiving weight
      *
650qA *      *DELETECW         Delete CW record - CW122/PO232
650qA *
      *      *DELETEONE        Delete first UCI record for a license number
      *
      *      *DELETEUCI        Delete specific UCI per Box Breaker
      *
      *      *GET              Get uciinfo record.
      *
740eA *      *GETINFO          Get uciinfo record for specific uci lcns
      *
740aA *      *GETLBS           Get pounds from the uci record
      *
700cA *      *GET1RTN          Gets one UCI at a time - loop process all
      *
650cA *      *GET2RTN          Gets the UCI being returned
      *
650cA *      *GET1UCI          Gets one UCI at a time - loop process all
      *
730cA *      *GETADJUCI        Gets one UCI at a time - for adjustments
      *
730cA *      *GETMISUCI        Gets one UCI at a time - for removing
      *                        UCI's that were not scanned during adjustment
      *
650dA *      *GETLICINFO       Get LICINFO
      *
      *      *GETLICREC        Get first UCI record for license number
      *
730jA *      *GETPRDDTE        Get oldest production date for given sel. label
      *
740aA *      *REDUCE           Reduce the weight in the uciinfo record
      *
      *      *REPLACE          Replaces GS1 XDK temp license with permanent
      *
650tA *      *REPLENUSE        Update GS1 with Replen transaction
      *
650cA *      *RETURN           Return UCI
      *
730cA *      *RMVADJTIM        Remove the value inf UIAPARTLTS
730cA *
720eA *      *RMVUCIADJ        Remove UCIINFO record
720eA *
720eA *      *RMVALLADJ        Remove all UCIINFO records for a license
720eA *
720eA *      *RMVMISUCI        Update UCIINFO record for any UCI's
720eA *                        that were not scanned for the adjustment
720eA *                        We will consider these missing.
720eA *
730cA *      *RMVUCILCS        Update UCIINFO record for any UCI's
730cA *                        that were not scanned for the adjustment
730cA *                        We will consider these missing.
730cA *
730cA *      *RMVADJLCS        Update UCIINFO record for the UCI
730cA *                        that we are doing a negative adjustment
730cA *
730cA *      *SETADJLCS        Update UCIINFO record for the UCI
730cA *                        that we are doing a positive adjustment
730cA *
650cA *      *RTNWHLORD        Return whole order - update uci by label
      *
650eA *      *SELCWSEQ         Post Catch weight seq#
      *
640aA *      *SELECT           Select UCI
      *
650oA *      *SELRUN           Select UCI RUNNER
      *
650iA *      *SELECTPTI        Select PTI
      *
720bA *      *SELECTUPC        Select UPC
      *
650qA *      *UPDATECW         Update CW record - CW122/PO232
650qA *
720eA *      *UPDATELIC        Update UCIINFO record with original
720eA *                        and new license number by license
720eA *                        number.
720eA *
720eA *      *UPDPARLIC        Update UCIINFO record with new license
720eA *                        when partial uci movement from one
720eA *                        license to a new license.
720eA *
720eA *      *UPDLICUCI        Update UCIINFO record with original
720eA *                        and new license number by UCI.
720eA *
720eA *      *UPDPARTL         Update UCIINFO record with time stamp
720eA *                        for partial license movement by UCI.
720eA *
720eA *      *VFYCURMV         Check for current movement of this UCI
720eA *                        UCI is already in the movement process.
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

720eA*----------------------------------------------------------------
720eA* File Specs
720eA*----------------------------------------------------------------

720eAFucilog    uf a e           k disk
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#BARCODE
      /COPY *libl/qcopysrc,C#CVTPARMS
640aA /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
650bA /COPY *libl/qcopysrc,C#LICINFO
     D saveVer#        s                   like($uiver#)
720eAD slot$Item       ds                  likeds($Item)
720eAD slot$Item2      ds                  likeds($Item2)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.vfywhse
640aA /copy qcopysrc,p.driitem
640aA /copy qcopysrc,p.cvtbar
650bA /copy qcopysrc,p.drimain3
650dA /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D uirec         e ds                  extname(UCIINFO) inz(*EXTDFT)
     D uprec         e ds                  extname(UPC) inz(*EXTDFT)
650dAD lnrec         e ds                  extname(LICINFO) inz(*EXTDFT)
650lAD lbrec         e ds                  extname(label) inz(*EXTDFT)
700aAD icrec         e ds                  extname(itemchg)
710bAD usrec         e ds                  extname(ucisplits) inz(*EXTDFT)
720eAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
730eAD uiwrec        e ds                  extname(UCIWORK) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(uiwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

640aAD driItemCalled   s               n
     D vfywhseCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

640aAD baseItem        s                   like(uiitem)
     D count           s              5p 0
     D DakotaCall      s               n
     D HostCall        s               n
650pAD invaliddate     s               n
640aAD itemFound       s               n
640aAD kyitem          s                   like(uiitem)
640aAD kywhse          s                   like(uiwhse)
720eAD nxtutrn#        s              7  0
720eAD nxtutrnSeq      s              2  0
650jAD PTIFound        s               n
650bAD recUpdated      s               n
730aAD Savelabel       s                   like($uilbl#)
650cAD SaveRtnLcns     s                   like(uilcns)
720eAD SaveRtnTrn#     s                   like($uirtntrn#)
650bAD savlcns         s                   like(uilcns)
650bAD savseq          s                   like(uiseq)
640aAD selectedFound   s               n
720eAD sentItem        s                   like(uiitem)
640aAD uciFound        s               n
650bAD uniqueUCI       s               n
640aAD unselectedFound...
     D                 s               n
730dAd MyfieldNull     s              5i 0
730dAd total_wgt       s              7  2

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d AAAInit         pr
     d AAAClose        pr
     d Add             pr
650fAd Addgs199        pr
650bAd AddLicInfo      pr
720eAd ADJCancel       pr
     d CheckActive     pr
650fAd CheckAssign     pr
650kAd CheckGs199      pr
650tAd CheckReplen     pr
720eAd Check4Move      pr
720eAd Check4Adj       pr
710bAd CkUciSplt       pr
740fAd Cleanup1        pr
740gAd Cleanup2        pr
650hAd Count4Bulk      pr
650jAd Count4Lcns      pr
650jAd Count4PTI       pr
650oAd Count4RUN       pr
720fAd Count4LBL       pr
740eAd Count4UCI       pr
720cAd Count4UNF       pr
     d ChkData         pr
650bAd Clr$LicInfo     pr
650qAd DeleteCW        pr
     d DeleteOne       pr
700f d DeleteUci       pr
     d FillDS          pr
     d FillRec         pr
730cAd GetAdjUci       pr
740aAd GetLbs          pr
740eAd GetInfo         pr
730cAd GetMISUci       pr
     d GetCurrStamp    pr
     d GetItem         pr
720eAd GetSlotItem     pr
650lAd GetLabel        pr
     d GetSelected     pr
650dAd GetSpclUciLcns  pr
     d GetUCI          pr
650cAd Get1UCIbyLic    pr
650oAd Get1UCI4Run     pr
700cAd Get1RTN         pr
650cAd Get2Rtn         pr
650hAd Get4Bulk        pr
730iAd Get4Lbl         pr
730fAd Get4UnPick      pr
     d GetUnselected   pr
650dAd GetLicInfo      pr
     d GetLicRec       pr
730dAd GetLicWgt       pr
     d RcvCancel       pr
740aAd Reduce          pr
     d Replace         pr
650tAd ReplenUse       pr
650sAd ResetUCI        pr
650cAd ReturnUCI       pr
730cAd RmvAdjTime      pr
720eAd RmvAllAdjust    pr
720eAd RmvMISAdjust    pr
720eAd RmvUCIAdjust    pr
730cAd RmvMisUCILcs    pr
730cAd RmvADJUCILcs    pr
730cAd SetADJUCILcs    pr
650cAd RtnWhlOrd       pr
650oAd RunnerDone      pr
640aAd SelectUCI       pr
650iAd SelectPTI       pr
720bAd SelectUPC       pr
650hAd Sel4BlkUCI      pr
650bAd SelectUCIUpd    pr
650hAd Sel4BlkUCIUpd   pr
650eAd SelCWSeqUpd     pr
650oAd UndoRunner      pr
730fAd UndoSelect      pr
650qAd UpdateCW        pr
     d VfyAdd          pr
     d VfyFldWhse      pr             1  0
     d VfyFldUCI       pr             1  0
720eAd VfyMoveGS1      pr             1  0
720eAd  upcCode                      20    const
650jAd VFYPTIItem      pr
720eAd VfyCurMove      pr
     d VfySelect       pr
     d VfySelectAI99   pr             1  0
     d VfySelectGS1    pr             1  0
530aAd  upcCode                      20    const
650iAd VfySelectPTI    pr
720bAd VfySelectUPC    pr
650bAd ZZZDriCop       pr
720eAd UpdLicByUCI     pr
720eAd UpdateLicense   pr
720eAd UpdatePartial   pr
720eAd UpdParLicense   pr
730iAd Weight4LBL      pr
720eAd WrtUCILog       pr

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
720eAD NoDate          s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

650cA*----------------------------------------------------------------
650cA*  Data structure for error message parameters
650cA*
650cAD $mdt            ds
650cAD  errmsg                 1     50
650cA*
650cAD  erfld                  1     30
650cAD  erfrom                31     40
650cAD  erto                  41     50
650cA*
650cAD  erfld1                 1     20
650cAD  erfld2                21     40
650cAD  erflvl                41     42p 0
650cAD  erclvl                43     44p 0
650cA*
650cAD  erqty1                 1      4p 0
650cAD  erqty2                 5      8p 0
650cAD  eruom                  9     13
650cAD                 ds
650cAD  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
650dA*----------------------------------------------------------------
650dA*  CVTDTE constant and parameter data structure.
650dA*----------------------------------------------------------------

650dAD $cvtdt          ds
650dAD  $cvcmd                 1      8
650dAD  $cvprg                 9     18
650dAD  $cvd6i                19     24
650dAD  $cvd8i                25     32
650dAD  $cvd6o                33     38  0
650dAD  $cvd8o                39     46  0
650dAD  $cvsto                47     64
650dAD  $cvrtn                65     72
650dAD  $cverm                73    132
650dAD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650bAD ucilic#         pr                  extpgm('UCILIC#')
650bAD   unext                       13  0
650bAD   uwhse                        3  0 const

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
720eAC                   parm                    $pdata2

      /free
         $uciinfo = $pdata;
720eA    if %parms >= 6;
720eA      $uciinfo2 = $pdata2;
720eA    endif;
         if $uiseq = 0;
           $uiseq = 1;
         endif;
         $preturn = '*OK';
         $pmessage = ' ';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

      /free
        if %subst($psubcmd:1:1) = '%';
          DakotaCall = *on;
          HostCall   = *off;
          %subst($psubcmd:1:1) = '*';
        else;
          HostCall   = *on;
          DakotaCall = *off;
        endif;

         // Make sure the file exist on client box
         exec sql select count(*)
                  into :count
                  from systables
                  where name = 'UCIINFO';

         If sqlstt <> sqlSuccess or count =0;
           $preturn = '*NOFILE';
           $pmessage = 'ICIINFO file does not exist';
           return;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             return;

           when $psubcmd = '*CLOSE';
             aaaclose();
             *inlr = *on;
             return;

         endsl;

         // Otherwise, do some initialization and move on.

         aaainit();
         error = *off;

         // Do what user has requested.

         select;

           when $psubcmd = '*CHKACTV';
             CheckActive();

650kA      when $psubcmd = '*CHKGS199';
650kA        CheckGS199();

720eA      when $psubcmd = '*CHK4MOVE';
720eA        Check4Move();

720eA      when $psubcmd = '*CHK4ADJ';
720eA        Check4Adj();

           when $psubcmd = '*ADD';
             VfyAdd();
             if not error;
720eA          exsr getutrn;
               Add();
             endif;

650fA      when $psubcmd = '*ADDGS199';
650fA        VfyAdd();
650fA        if not error;
650fA          // Decipher UCI
650fA
650fA          cvtbar('*ALL': $uiUCI:
650fA             $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM             $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA            $cbkilolbsSent: $cbitem);
740bD           //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
700jD             //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
650fA          $barcode = $cvtdata;
650fA          $barcode2 = $cvtdata2;
650fA
650fA          GetLicInfo();
650fA          AddGS199();
650fA        endif;

           when $psubcmd = '*CANCEL';
720eA        exsr getutrn;
             RcvCancel();

720eA      when $psubcmd = '*ADJCANCEL';
720eA        exsr getutrn;
720eA        AdjCancel();

650fA      when $psubcmd = '*CHKASGN';
650fA        CheckAssign();

650tA      when $psubcmd = '*CHKREPLEN';
650tA        CheckReplen();

740fA      when $psubcmd = '*CLEANUP1';
740fA        Cleanup1();

740gA      when $psubcmd = '*CLEANUP2';
740gA        Cleanup2();

650hA      when $psubcmd = '*CNT4BLK';
650hA        Count4Bulk();

650jA      when $psubcmd = '*CNT4LCNS';
650jA        Count4Lcns();

650jA      when $psubcmd = '*CNT4PTI';
650jA        Count4PTI();

650oA      when $psubcmd = '*CNT4RUN';
650oA        Count4RUN();

720fA      when $psubcmd = '*CNT4LBL';
720fA        Count4LBL();

740eA      when $psubcmd = '*CNT4UCI';
740eA        Count4UCI();

720cA      when $psubcmd = '*CNT4UNF';
720cA        Count4UNF();

           when $psubcmd = '*GET';
               Getuci();
740cA          fillds();

740eA      when $psubcmd = '*GETINFO';
740eA          GetInfo();
740eA          fillds();

730cA      when $psubcmd = '*GETADJUCI';
730cA        GetAdjUci();

740aA      when $psubcmd = '*GETLBS';
740aA        GetLbs();

730cA      when $psubcmd = '*GETMISUCI';
730cA        GetMISUci();

           when $psubcmd = '*GETLICREC';
               GetLicRec();

730dA      when $psubcmd = '*GETLICWGT';
730dA        GetLicWgt();

650cA      when $psubcmd = '*GET1UCI  ';
650cA          Get1UCIbyLic();

650oA      when $psubcmd = '*GET1RUN  ';
650oA          Get1UCI4Run();

700cA      when $psubcmd = '*GET1RTN  ';
700cA          Get1RTN();

650cA      when $psubcmd = '*GET2RTN  ';
650cA          Get2Rtn();

650hA      when $psubcmd = '*GET4BLK';
650hA        Get4Bulk();

730iA      when $psubcmd = '*GET4LBL';
730iA        Get4lbl();

730fA      when $psubcmd = '*GET4UNPCK';
730fA        Get4UnPick();

           when $psubcmd = '*CHKDATA';
             ChkData();

740aA      when $psubcmd = '*REDUCE';
740aA        exsr getutrn;
740aA        Reduce();

650sA      when $psubcmd = '*RESETUCI';
720eA        exsr getutrn;
650sA        ResetUCI();

           when $psubcmd = '*REPLACE';
720eA        exsr getutrn;
             Replace();

650tA      when $psubcmd = '*REPLENUSE';
650tA        Replenuse();

650cA      when $psubcmd = '*RETURN';
720eA        exsr getutrn;
650cA        ReturnUCI();

650cA      when $psubcmd = '*RTNWHLORD';
720eA        exsr getutrn;
650cA        RtnWhlOrd();

650eA      when $psubcmd = '*SELCWSEQ';
720eA        exsr getutrn;
650eA        SelCWSeqUpd();

650oD      //when $psubcmd = '*SELECT';
650oM      when $psubcmd = '*SELECT'
650oA        or $psubcmd = '*SELRUN';
             VfySelect();
             if not error;
720eA          exsr getutrn;
640aA          SelectUCI();
             endif;

650iA      when $psubcmd = '*SELECTPTI';
650iA        VfySelectPTI();
650iA        if not error;
650iA          SelectPTI();
650iA        endif;

720bA      when $psubcmd = '*SELECTUPC';
720bA        VfySelectUPC();
720bA        if not error;
720bA          SelectUPC();
720bA        endif;

650hA      when $psubcmd = '*SEL4BLK';
650hA        VfySelect();
650hA        if not error;
720eA          exsr getutrn;
650hA          Sel4BlkUCI();
650hA        endif;

650qA      when $psubcmd = '*DELETECW';
650qA        DeleteCW();

700fA      when $psubcmd = '*DELETEUCI';
720eA        // Get Item information
720eA        kywhse = $uiWhse;
720eA        kyitem = $uiItem;
720eA        getItem();
720eA        exsr getutrn;
720eA        DeleteUci();

           when $psubcmd = '*DELETE1';
720eA        exsr getutrn;
             Deleteone();

730cA      when $psubcmd = '*RMVADJTIM';
730cA        RmvAdjTime();

720eA      when $psubcmd = '*RMVALLADJ';
720eA        exsr getutrn;
720eA        RmvALLAdjust();

720eA      when $psubcmd = '*RMVMISUCI';
720eA        exsr getutrn;
720eA        RmvMisAdjust();

730cA      when $psubcmd = '*RMVUCILCS';
730cA        exsr getutrn;
730cA        RmvMisUCILcs();

730cA      when $psubcmd = '*RMVADJLCS';
730cA        exsr getutrn;
730cA        RmvADJUCILcs();

730cA      when $psubcmd = '*SETADJLCS';
730cA        exsr getutrn;
730cA        SetADJUCILcs();

720eA      when $psubcmd = '*RMVUCIADJ';
720eA        exsr getutrn;
720eA        RmvUCIAdjust();

650oA      when $psubcmd = '*UNDORUN ';
720eA        exsr getutrn;
650oA        UndoRunner();

730fA      when $psubcmd = '*UNDOSEL ';
730fA        exsr getutrn;
730fA        UndoSelect();

650qA      when $psubcmd = '*UPDATECW';
650qA        UpdateCW();

720eA      when $psubcmd = '*UPDATELIC';
720eA        exsr getutrn;
720eA        UpdateLicense();

720eA      when $psubcmd = '*UPDPARLIC';
720eA        exsr getutrn;
720eA        UpdParLicense();

720eA      when $psubcmd = '*UPDLICUCI';
720eA        exsr getutrn;
720eA        UpdLicByUCI();

720eA      when $psubcmd = '*UPDPARTL';
720eA        exsr getutrn;
720eA        UpdatePartial();

650oA      when $psubcmd = '*RUNDONE ';
650oA        RunnerDone();

710bA      when $psubcmd = '*CKUCISPLT';
710bA        CkUciSplt();

720eA      when $psubcmd = '*VFYCURMV';
720eA        VfyCurMove();

730iA      when $psubcmd = '*WGT4LBL';
730iA        Weight4LBL();

           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;

       // We are finished so get out

       $pdata = $uciinfo;
720eA  if %parms >= 6;
720eA    $pdata2 = $uciinfo2;
720eA  endif;
       return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------


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

720eA*----------------------------------------------------------------
720eA*  getutrn   Get Uci Log transaction number.
720eA*----------------------------------------------------------------

720eAC     getutrn       begsr

720eAC                   call      'PIRUCI#'
720eAC                   parm      0             nxtutrn#

720eAC                   eval      nxtutrnSeq = 0

720eAC                   endsr


     *----------------------------------------------------------------
     *  AAAInit      Pre-subcommand initialization.
     *----------------------------------------------------------------

     p AAAInit         b
     d AAAInit         pi

      /free

      /end-free
     p AAAInit         e

     *----------------------------------------------------------------
     *  AAAClose     Close Called Programs.
     *----------------------------------------------------------------

     p AAAClose        b
     d AAAClose        pi

      /free

640aA    if driItemCalled;
640aA      driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
640aA               $dridata: $dridata2);
640aA    endif;

         if vfyWhseCalled;
           vfyWhse('*CLOSE': '*NONE': $vwhse: $vdesc:
                   $vreturn: $vmessage: $vmsgk);
         endif;

      /end-free
     p AAAClose        e

     *----------------------------------------------------------------
     *  Add       Add Receiver Scanned GS1/UCI barcodes
     *----------------------------------------------------------------

     p Add             b
     d Add             pi

      /free
         error = *off;

650dA    // Get special UCI license if not sent.
650dA    GetSpclUCILcns();

         // Initialize record fields

         clear uirec;
         FillRec();

         GetCurrStamp();

         uiaddts = CurrStampSys;
720eA    uiaaddts = CurrStampSys;
         uiadduc = CurrStampUC;
         uiaddpgm = $uiaddpgm;
         uiaddemp = $uiaddemp;
         uiaddusr = $uiaddusr;
         uiaddjob = $uiaddjob;
         uiaddnbr = $uiaddnbr;

         uichgts = uiaddts;
         uichguc = uiadduc;
         uichgpgm = uiaddpgm;
         uichgemp = uiaddemp;
         uichgusr = uiaddusr;
         uichgjob = uiaddjob;
         uichgnbr = uiaddnbr;

         // Create record

         exec sql insert into uciinfo values(:uirec);

640aD    //if sqlstt = sqlDupRecd;
640aM    if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRADDREC4';
           $pmessage = 'Error Adding rec '
                     + '('
                     + %trim(%editc(uiwhse:'Z'))
                     + '/'
                     + %trim(uiuci)
                     + ')'
                     + '-' + 'UCIINFO';
720eA    else;
720eA      WrtUCIlog();
         endif;

720eA    exec sql insert into uciinfoexa values(:uiarec);

720eA    if sqlstt <> sqlSuccess;
720eA      error = *on;
720eA      $preturn = 'ERRADDREC5';
720eA      $pmessage = 'Error Adding rec '
720eA                + '('
730kD                //+ %trim(%editc(uiwhse:'Z'))
730kM                + %char(uiaaddts)
720eA                + '/'
730kD                //+ %trim(uiuci)
730kM                + %trim(uiaucilcns)
730kA                + '/'
730kA                + %trim(uialcns)
720eA                + ')'
720eA                + '-' + 'UCIINFOEXA';
720eA    endif;
      /end-free
     p Add             e

650fA*----------------------------------------------------------------
650fA*  AddGS199  Add GS199 - assigned to an item  - internal uci
650fA*----------------------------------------------------------------

650fAp AddGS199        b
650fAd AddGS199        pi

      /free
         error = *off;

         // Get special UCI license if not sent.
         GetSpclUCILcns();

         // Initialize record fields

         clear uirec;
         FillRec();
720eA    uiaLot     = $bcLot;
720eA    if $bcgtin = *blanks;
720eA       uiaGtin = 0;
720eA    else;
720eA       uiaGtin = %DEC($bcGTIN:14:0);
720eA    endif;
720eA    uiaExpd    = $bcExpD;

         GetCurrStamp();

         uiaddts = CurrStampSys;
720eA    uiaaddts = CurrStampSys;
         uiadduc = CurrStampUC;
         uiaddpgm = $uiaddpgm;
         uiaddemp = $uiaddemp;
         uiaddusr = $uiaddusr;
         uiaddjob = $uiaddjob;
         uiaddnbr = $uiaddnbr;

         uichgts = uiaddts;
         uichguc = uiadduc;
         uichgpgm = uiaddpgm;
         uichgemp = uiaddemp;
         uichgusr = uiaddusr;
         uichgjob = uiaddjob;
         uichgnbr = uiaddnbr;

         // Create record

         exec sql insert into uciinfo values(:uirec);

         //if sqlstt = sqlDupRecd;
         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRADDREC4';
           $pmessage = 'Error Adding rec '
                     + '('
                     + %trim(%editc(uiwhse:'Z'))
                     + '/'
                     + %trim(uiuci)
                     + ')'
                     + '-' + 'UCIINFO';
720eA    else;
720eA      WrtUCIlog();
         endif;
720eA    // Create uciinfo extension file a

720eA    exec sql insert into uciinfoexa values(:uiarec);

720eA    if sqlstt <> sqlSuccess;
720eA      error = *on;
730kD      //$preturn = 'ERRADDREC4';
730kM      $preturn = 'ERRADDREC5';
720eA      $pmessage = 'Error Adding rec '
720eA                + '('
730kD                //+ %trim(%editc(uiwhse:'Z'))
730kM                + %char(uiaaddts)
720eA                + '/'
730kD                //+ %trim(uiuci)
730kM                + %trim(uiaucilcns)
730kA                + '/'
730kA                + %trim(uialcns)
720eA                + ')'
730kD                //+ '-' + 'UCIINFO';
730kM                + '-' + 'UCIINFOEXA';
720eA    endif;

      /end-free
650fAp AddGS199        e

650bA*----------------------------------------------------------------
650bA*  AddLicInfo   Add record to LICINFO
650bA*----------------------------------------------------------------
650bA
650bAp AddLicInfo      b
     d AddLicInfo      pi

      /free
         error = *off;
650fA    if $psubcmd = '*ADDGS199';
650fA      // Get Item information
650fA      kywhse = $uiWhse;
650fA      kyitem = $uiItem;
650fA      getItem();
650fA      if not itemFound;
650fA        error = *on;
650fA        $preturn  = 'INVLDITEM';
650fA        $pmessage = 'Error: Invalid Item';
650fA        return;
650fA      endif;
650fA    endif;
650dA    clr$licinfo();
650dA    $lnwhse = $uiwhse;
650dA    $lnitem = $uiitem;
650dA    $lnseq = 1;
650dA    $lnseqqty = 1;
650fA    if $psubcmd = '*ADDGS199';
650fA      $lnrcvtyp = '4';
650fA    else;
650dA      $lnrcvtyp = '3';
650fA    endif;
650dA    $lndateflag = $itflgd;
650dA    $lnmfgflag = $immflg;
650dA    $lnmfgdays = $immday;
650dA    $lnusrdays = $imuday;
650dA    $lndstdays = $imdday;

650dA    if $bcLotSent;
650dA      $lnlot = $bclot;
650dA    endif;
650dA    if $bcExpDSent;
650dA      // convert the date from the uci scan
650dA      $cvcmd = '*YMDCMD ';
650dA      $cvd6i = %trimr(%editc($bcExpD:'X'));
650dA      cvtdte ($cvtdt);
650dA      $lnmfgexp  = $cvd8o;
650dA      $lnentdate = $cvd8o;
650dA      $lnenttype = '*USEDTE';
650dA    endif;
650dA    if $bcProdDSent;
650dA      // convert the date from the uci scan
650dA      $cvcmd = '*YMDCMD ';
650dA      $cvd6i = %trimr(%editc($bcProdD:'X'));
650dA      cvtdte ($cvtdt);
650dA      $lnmfgdate = $cvd8o;
650dA      $lnentdate = $cvd8o;
650pD      //$lnenttype = '*NFGDTE';
650pM      $lnenttype = '*MFGDTE';
650dA    endif;
650dA    if $bcPNtLbSent;
650dA      $lnttllbs = $bcPNtLb;
650dA    endif;
650dA
650dA    GetSpclUCILcns();
650dA       // need uci license for this
650dA       $lnLcns  = $uiuciLcns;
650dA       $uiLcns  = $uiuciLcns;
650dA
650dA     $dricommand = '*LICINFO';
650dA     $drisubcmd  = '%ADDS';
650dA     $drisys2upd = 'D';

650dA   zzzdricop();

      /end-free
     p AddLicInfo      e

720eA*----------------------------------------------------------------
720eA*  AdjCancel    User Cancelled - all UCI added will be deleted
720eA*----------------------------------------------------------------

720eAp AdjCancel       b
720eAd AdjCancel       pi

720eA /free

720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before resetting.
720eA    dow forever = forever;
720eA    exec sql select uiwhse, uiaddts, uiucilcns,uiseltrn#, uiapartlts,
                         uiaaddts, uiaucilcns, uiuci, uiasItem, uiitem
720eA         into      :uiwhse,:uiaddts,:uiucilcns,:uiseltrn#,:uiapartlts,
                        :uiaaddts,:uiaucilcns,:uiuci,:uiasItem,:uiitem
720eA         from UCIINFO
720eA              inner join uciinfoexa
720ea              on uiaddts = uiaaddts
720ea              and uiucilcns = uiaucilcns
720ea              and uialcns = uilcns
720eA         where uilcns = :$uilcns
720eA           and uiwhse = :$uiwhse
720eA           and uiseltrn# = 0
720eA           and uiapartlts = :$uiapartlts
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        leave;
720eA      else;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        $uiaction = 'ADJCANCEL';
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getSlotItem();
720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;
720eA    // delete all records for the license

720eA    exec sql delete
720eA             from uciinfo
720eA             where uilcns = :$uilcns
720eA               and uiuci = :$uiuci
720eA               and uiwhse = :$uiwhse
720eA               and uiseltrn# = 0;

730cA    exec sql delete
730cA             from uciinfoexa
730cA             where uialcns = :$uilcns
730cA               and uiaaddts = :uiaddts
730cA               and uiaucilcns = :uiucilcns;

720eA    enddo;
720eA    // need to remove timestamp from UCI that already existed
720eA    // when the user cancels the adjustment
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before resetting.
720eA    dow forever = forever;
720eA    exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uiwhse,
720eA                    uiseltrn#, uiasitem, uiitem
720eA         into      :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uiwhse,
720eA                   :uiseltrn#,:uiasitem,:uiitem
720eA         from UCIINFO
720eA              inner join uciinfoexa
720ea              on :uiaddts = :uiaaddts
720ea              and :uiucilcns = :uiaucilcns
720ea              and :uialcns = :uilcns
720eA         where :uiwhse = :$uiwhse
720eA           and :uiseltrn# = 0
720eA           and :uiapartlts = :$uiapartlts
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        $uiaction = 'ADJCANCEL';
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getSlotItem();
720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;
720eA      // now remove the timestamp

720eA      Exec Sql
720eA        UPDATE uciinfoexa as a
720eA        SET uiapartlts = :nodate
720eA        WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and b.uiseltrn# = 0
720eA             and a.uiapartlts = :$uiapartlts
720eA             and a.uiaaddts = b.uiaddts
720eA             and a.uiaucilcns = b.uiucilcns
720eA             and a.uialcns = b.uilcns
720eA             and b.uiuci = :uiuci ) >0;

720eA    enddo;
720eA /end-free
720eAp AdjCancel       e

     *----------------------------------------------------------------
     *  CheckActive  Check for Active GS1/UCI barcode
     *----------------------------------------------------------------

     p CheckActive     b
     d CheckActive     pi

      /free

         // Get Item information

         kywhse = $uiWhse;
         kyitem = $uiItem;
         getItem();
         if not itemFound;
           error = *on;
           $preturn  = 'INVLDITEM';
           $pmessage = 'Error: Invalid Item';
           return;
         endif;

         // If item is not defined as unique UCI, then get out.

730hA    // 99i label will always be unique
730hA    if %subst($uiuci:1:3) = '99I';
730hA    else;
           if $ifucicde <> '2'        // Unique GS1
             and $ifucicde <> '4';    // Unique Internal AI99 GS1
               return;
           endif;
730hA    endif;

650nA    // If item is using uci receiving but not using uci selection
650nA    // Returns can not check for unique uci. Get out

650nA    if $ifrcvmth = '2'        // uci receiving
650nA       and $ifsltmth <> '2'     // uci selection
650nA       and $pprogram = ('RN120')
650nA       or  $ifrcvmth = '2'        // uci receiving
650nA       and $ifsltmth <> '2'     // uci selection
650nA       and $pprogram = ('RN250');
650nA      return;
650nA    endif;

         // Error if UCI exists.

         GetUCI();

         if uciFound;
           error = *on;
           $preturn = '*EXIST    ';
           $pmessage = 'UCI already exists '
                     + '('
                     + %trim(%editc($uiwhse:'Z'))
                     + '/'
                     + %trim($uiuci)
                     + ')';
         endif;

      /end-free
     p CheckActive     e

650fA*----------------------------------------------------------------
650fA*  CheckAssign  Check for Assigned Internal gs1-99 barcodes
650fA*----------------------------------------------------------------

650fAp CheckAssign     b
650fAd CheckAssign     pi

650fA /free

         // Error if UCI exists.

         GetUCI();

         if uciFound;
           error = *on;
           $preturn = '*EXIST    ';
           $pmessage = 'UCI already exists '
                     + '('
                     + %trim(%editc($uiwhse:'Z'))
                     + '/'
                     + %trim($uiuci)
                     + ')';
         endif;

      /end-free
650fAp CheckAssign     e

650tA*----------------------------------------------------------------
650tA*  CheckReplen  Check status of GS1 being scanned during Replen
650tA*----------------------------------------------------------------

650tAp CheckReplen     b
650tAd CheckReplen     pi

650tA /free

650tA    cvtbar('*ALL': $uiUCI:
650tA        $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM        $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA        $cbkilolbsSent: $cbitem);
740bD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
700jD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
650tA    $barcode = $cvtdata;
650tA    $barcode2 = $cvtdata2;

710eD    // exec sql select * into :uirec
710eD       //   from UCIINFO
710eD       //  where uiwhse = :$uiwhse
710eD       //   and uiuci = :$uiuci
710eD       // fetch first row only;

710eD   //  if sqlstt = sqlSuccess;
710eD   //   if not $bcSer#Sent;
650tA        exec sql select * into :uirec
650tA           from UCIINFO
650tA            where uiwhse = :$uiwhse
650tA             and uiuci = :$uiuci
650tA             and uiSeltrn# = 0
650tA            fetch first row only;
710eD   //   endif;
710eD   // endif;

650tA    if sqlstt = sqlSuccess;
         //---------------------------------------------//
710eD    //  if uiSeltrn# <> 0;
710eD    //     $preturn = '*EXIST';
710eD    //    $pmessage = 'UCI already used '
710eD    //               + '('
710eD    //               + %trim(%editc($uiwhse:'Z'))
710eD    //               + '/'
710eD    //               + %trim($uiuci)
710eD    //              + ')';
710eD    //   else;
         //---------------------------------------------//
650tA         $preturn = '*OKUPD    ';
700eA         fillds();
710eD     // endif;
650tA    else;
710eD     //  if not $bcGTINsent;
710eD     //   if GTIN not sent then reply with an error
710eA       exec sql select * into :uirec
710eA            from UCIINFO
710eA            where uiwhse = :$uiwhse
710eA            and uiuci = :$uiuci
710eA            fetch first row only;

710eA       if sqlstt = sqlSuccess;
710eA          kyWhse = uiwhse;
710eA          kyItem = uiItem;
710eA          GetItem();

710eA          if uniqueUCI;
710eA             // UCI exists and used so return error it already exist
650tA             $preturn = '*EXIST';
710eA          Else;
710eA             // UCI exists but duplicates allowed so add
650tA             $preturn = '*OKADD';
710eA          EndIf;
710eA
710eA       Else;
710eA          // UCI does not exist in any form so add
650tA          $preturn = '*OKADD    ';
650tA       endif;
650tA    endif;

      /end-free
650tAp CheckReplen     e

720eA*----------------------------------------------------------------
720eA*  Check4Move   Check for Active UCI for movement/Tracking
720eA*----------------------------------------------------------------

720eAp Check4Move      b
720eAd Check4Move      pi

720eA /free

720eA    // Get Item information
720eA
720eA    kywhse = $uiWhse;
720eA    kyitem = $uiItem;
720eA    getItem();
720eA    if not itemFound;
720eA      error = *on;
720eA      $preturn  = 'INVLDITEM';
720eA      $pmessage = 'Error: Invalid Item';
720eA      return;
720eA    endif;
720eA    // Get base item number
720eA
720eA    if $ittype = ' ' or $ittype = 'B';
720eA      baseItem = $ititem;
720eA    else;
720eA      baseItem = $itmitem;
720eA    endif;

720eA    // If item is not defined as unique UCI, then get out.

720eA    if $ifucicde <> '2'        // Unique GS1
720eA      and $ifucicde <> '4';    // Unique Internal AI99 GS1
720eA        return;
720eA    endif;

720eA    // Error if UCI exists.

720eA    sentItem = $uiitem;
720eA    GetUCI();

720eA    if not uciFound;
720eA      error = *on;
720eA      $preturn = '*NOTACTIVE';
720eA      $pmessage = 'UCI is not Active  '
720eA                + '('
720eA                + %trim(%editc($uiwhse:'Z'))
720eA                + '/'
720eA                + %trim($uiuci)
720eA                + ')';
720eA    endif;

720eA      // Decipher UCI
720eA
720eA      cvtbar('*ALL': $uiUCI:
720eA         $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM         $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA         $cbkilolbsSent: $cbitem);
740bD         //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse)  ;
720eA      $barcode = $cvtdata;
720eA      $barcode2 = $cvtdata2;

720eA    if uciFound;
720eA      // gs1-99 won't have a gtin - just compare items
720eA      if %subst($uiuci:1:3) = '99I';
720eA        if $uiitem <> sentitem;
720eA          $preturn  = 'ITMMISMTCH';
720eA          $pmessage = 'GS1-99 item does not match';
720eA        endif;
720eA      else;
720eA        if VfyMoveGS1($bcGtin) < 1;
720eA          return;
720eA        endif;
720eA      endif;

720eA      // need to make sure it is for the correct item being moved
720eA    endif;

720eA /end-free
720eAp Check4Move      e

720eA*----------------------------------------------------------------
720eA*  Check4Adj    Check for Active UCI for adjustment
720eA*----------------------------------------------------------------

720eAp Check4Adj       b
720eAd Check4Adj       pi

720eA /free

720eA    // Get Item information
720eA
720eA    kywhse = $uiWhse;
720eA    kyitem = $uiItem;
720eA    getItem();
720eA    if not itemFound;
720eA      error = *on;
720eA      $preturn  = 'INVLDITEM';
720eA      $pmessage = 'Error: Invalid Item';
720eA      return;
720eA    endif;
720eA    // Get base item number
720eA
720eA    if $ittype = ' ' or $ittype = 'B';
720eA      baseItem = $ititem;
720eA    else;
720eA      baseItem = $itmitem;
720eA    endif;

720eA    // If item is not defined as unique UCI, then get out.

720eA    if $ifucicde <> '2'        // Unique GS1
720eA      and $ifucicde <> '4';    // Unique Internal AI99 GS1
720eA        return;
720eA    endif;

720eA    // Error if UCI exists.

720eA    sentItem = $uiitem;
720eA    GetUCI();

720eA    if not uciFound;
720eA      error = *on;
720eA      $preturn = '*NOTACTIVE';
720eA      $pmessage = 'UCI is not Active  '
720eA                + '('
720eA                + %trim(%editc($uiwhse:'Z'))
720eA                + '/'
720eA                + %trim($uiuci)
720eA                + ')';
720eA    else;
720eA     fillds();
720eA    endif;

720eA      // Decipher UCI
720eA
720eA      cvtbar('*ALL': $uiUCI:
720eA         $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM         $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA         $cbkilolbsSent: $cbitem);
740bD         //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse)  ;
720eA      $barcode = $cvtdata;
720eA      $barcode2 = $cvtdata2;

720eA    if uciFound;
720eA      // gs1-99 won't have a gtin - just compare items
720eA      if %subst($uiuci:1:3) = '99I';
720eA        if $uiitem <> sentitem;
720eA          $preturn  = 'ITMMISMTCH';
720eA          $pmessage = 'GS1-99 item does not match';
720eA        endif;
720eA      else;
720eA        if VfyMoveGS1($bcGtin) < 1;
720eA          return;
720eA        endif;
720eA      endif;

720eA      // need to make sure it is for the correct item being moved
720eA    endif;

720eA /end-free
720eAp Check4Adj       e

     *----------------------------------------------------------------
     *  ChkData      Check all data for a match to first barcode scanned
     *----------------------------------------------------------------

     p ChkData         b
     d ChkData         pi

      /free

         // License Number
           exec sql select * into :uirec
                    from uciinfo
                    where uiwhse = :$uiwhse
                      and uilcns = :$uilcns
                    order by uiwhse, uilcns, uiadduc
                    fetch first row only;

           if sqlstt = sqlSuccess;
             $uiitem = uiitem;
             $preturn = '*FOUND';
           endif;

      /end-free
     p ChkData         e

650kA*----------------------------------------------------------------
650kA*  CheckGS199  Check for Active GS199 barcode
650kA*----------------------------------------------------------------

650kAp CheckGS199      b
650kAd CheckGS199      pi

650kA /free

650kA    // force unique for gs199

650kA    $ifucicde = '2';

650kA    // Error if UCI does not exist or has been selected.

650kA    GetUCI();

650kA    if not uciFound;
650kA      error = *on;
650kA      $preturn = '*EXIST    ';
650kA      $pmessage = 'GS199 Invalid '
650kA                + '('
650kA                + %trim(%editc($uiwhse:'Z'))
650kA                + '/'
650kA                + %trim($uiuci)
650kA                + ')';
650kA    else;
650kA     fillds();
650kA    endif;

650kA /end-free
650kAp CheckGS199      e

740fA*----------------------------------------------------------------
740fA*  Cleanup1     Cleanup selection records.                       ic
740fA*----------------------------------------------------------------

740fAp Cleanup1        b
740fAd Cleanup1        pi

740fA /free

740fA    // delete the UCI's for selection label sent in

740fA    exec sql delete
740fA             from uciinfo
740fA             where uisellbl# = :$uisellbl#
740fA               and uiseltrn# = :$uiseltrn#
740fA               and uiwhse = :$uiwhse;

740fA /end-free
740fAp Cleanup1        e

740fA*----------------------------------------------------------------
740gA*  Cleanup2     Cleanup Receiving weight records                 ic
740gA*----------------------------------------------------------------

740gAp Cleanup2        b
740gAd Cleanup2        pi

740gA /free

740gA    // delete the UCI's for individual weights at receiving.
740gA    // these are not true uci records, just stored in this file

740gA    exec sql delete
740gA             from uciinfo
740gA             where uicrtby = :$uicrtby
740gA               and uilcns = :$uilcns
740gA               and uiwhse = :$uiwhse;

740gA /end-free
740gAp Cleanup2        e

650hA*----------------------------------------------------------------
650hA*  Count4Bulk   Count available uci for bulk pick
650hA*----------------------------------------------------------------

650hAp Count4Bulk      b
650hAd Count4Bulk      pi

650hA /free

650hA    // Need to determine the number of UCI records available on
650hA    // the license to see if we can auto load catch weights for
650hA    // bulk picks.

650hA   exec sql select count(*)
650hA            into :count
650hA            from uciinfo2
650hA            where uilcns = :$uilcns
650hA              and uiwhse = :$uiwhse
650hA              and uiseltrn# = 0
650hA              and (uiwgtlbs > 0 or uiwgtkgs > 0);

650hA    If sqlstt = sqlSuccess;
650hA    endif;

650hA    if count = 0;
650hA      error = *on;
650hA      $preturn = '*BULKQTY1 ';
650hA      $pmessage = 'CW Not Auto Loaded.';
650hA    endif;

650hA    // need to send count back - use $pmessage field
650hA    if count > 0;
650hA      $preturn = '*BULKCNT ';
650hA      $pmessage = %trim(%editc(COUNT:'X'));
650hA    endif;

650hA /end-free
650hAp Count4Bulk      e

650jA*----------------------------------------------------------------
650jA*  Count4LCNS   Count available PTI for a license
650jA*----------------------------------------------------------------

650jAp Count4Lcns      b
650jAd Count4Lcns      pi

650jA /free

650jA    // Need to determine the number of PTI records for the license

650jA   exec sql select count(*)
650jA            into :count
650jA            from uciinfo2
650jA            where uilcns = :$uilcns
650jA              and uiwhse = :$uiwhse
650jA              and uiseltrn# = 0;

650jA    If sqlstt = sqlSuccess;
650jA    endif;

650jA    // need to send count back - use $pmessage field
650jA      $preturn = '*PTILCNS ';
650jA      $pmessage = %trim(%editc(COUNT:'X'));

650jA /end-free
650jAp Count4Lcns      e

650jA*----------------------------------------------------------------
650jA*  Count4PTI    Count available PTI.
650jA*----------------------------------------------------------------

650jAp Count4PTI       b
650jAd Count4PTI       pi

650jA /free

650jA    // Need to determine the number of PTI records available.

650jA   exec sql select count(*)
650jA            into :count
650jA            from uciinfo2
650jA            where uiitem = :$uiitem
650jA              and uiwhse = :$uiwhse
650jA              and uiseltrn# = 0;

650jA    If sqlstt = sqlSuccess;
650jA    endif;

650jA    // need to send count back - use $pmessage field
650jA      $preturn = '*PTICNT  ';
650jA      $pmessage = %trim(%editc(COUNT:'X'));

650jA /end-free
650jAp Count4PTI       e

650oA*----------------------------------------------------------------
650oA*  Count4RUN    Count UCI's scanned for Runner
650oA*----------------------------------------------------------------

650oAp Count4RUN       b
650oAd Count4RUN       pi

650oA /free

650oA    // Need to get count in case user backs up a screen.

650oA   exec sql select count(*)
650oA            into :count
650oA            from uciinfo2
650oA            where uiitem = :$uiitem
650oA              and uiwhse = :$uiwhse
650oA              and uisellbl# = :$uisellbl#
650oA              and uirtntrn# = :$uirtntrn#
650oA              and uiseltrn# = :$uiseltrn#;

650oA    If sqlstt = sqlSuccess;
650oA    endif;

650oA    // need to send count back - use $pmessage field
650oA      $preturn = '*RUNCNT  ';
650oA      $pmessage = %trim(%editc(COUNT:'X'));

650oA /end-free
650oAp Count4RUN       e

720fA*----------------------------------------------------------------
720fA*  Count4LBL    Count UCI's scanned for Label
720fA*----------------------------------------------------------------

720fAp Count4LBL       b
720fAd Count4LBL       pi

720fA /free

720fA    // Need to get count for the label

720fA   exec sql select count(*)
720fA            into :count
720fA            from uciinfo2
720fA            where uiitem = :$uiitem
720fA              and uiwhse = :$uiwhse
720fA              and uisellbl# = :$uisellbl#;

720fA    If sqlstt = sqlSuccess;
720fA    endif;

720fA    // need to send count back - use $pmessage field
720fA      $preturn = '*LBLCNT  ';
720fA      $pmessage = %trim(%editc(COUNT:'X'));

720fA /end-free
720fAp Count4LBL       e

740eA*----------------------------------------------------------------
740eA*  Count4UCI    Count how many time the UCI is in file
740eA*----------------------------------------------------------------

740eAp Count4UCI       b
740eAd Count4UCI       pi

740eA /free

740eA    // Need to get count for the uci for inquiry

740eA   exec sql select count(*)
740eA            into :count
740eA            from uciinfo
740eA            where uiuci  = :$uiuci
740eA              and uiwhse = :$uiwhse;

740eA    If sqlstt = sqlSuccess;
740eA    endif;

740eA    // need to send count back - use $pmessage field
740eA      $preturn = '*UCICNT  ';
740eA      $pmessage = %trim(%editc(COUNT:'X'));

740eA /end-free
740eAp Count4UCI       e

720cA*----------------------------------------------------------------
720cA*  Count4UNF    Count scanned labels for unfinished transaction
720cA*----------------------------------------------------------------

720cAp Count4UNF       b
720cAd Count4UNF       pi

720cA /free

720cA    // Need to get count in case user restarts unfinished tran.

720cA   exec sql select count(*)
720cA            into :count
720cA            from uciinfo2
720dD            //where uiitem = :$uiitem
720dM            where uiwhse = :$uiwhse
720cA              and uisellbl# = :$uisellbl#
720cA              and uirtntrn# = :$uirtntrn#
720cA              and uiseltrn# = :$uiseltrn#;

720cA    If sqlstt = sqlSuccess;
720cA    endif;

720cA    // need to send count back - use $pmessage field
720cA      $preturn = '*UNFCNT  ';
720cA      $pmessage = %trim(%editc(COUNT:'X'));

720cA /end-free
720cAp Count4UNF       e

650qA*----------------------------------------------------------------
650qA*  DeleteCW     Delete the CW entry for the temporary license
650qA*----------------------------------------------------------------

650qAp DeleteCW        b
650qAd DeleteCW        pi

650qA /free

650qA    // delete the CW entry for the temporary license

650qA    exec sql delete
650qA             from uciinfo
650qA             where uilcns = :$uilcns
650qA               and uiwhse = :$uiwhse
700bD               //and uiseq  = :$uiseq;
700bM               and uiselcseq  = :$uiselcseq;

650qA /end-free
650qAp DeleteCW        e

     *----------------------------------------------------------------
     *  DeleteOne    Delete the first uci for this license - xdock logic
     *----------------------------------------------------------------

     p Deleteone       b
     d Deleteone       pi

      /free

720eA    // in order to write logs for each uci, I will need to get
720eA    // the uci before deleting.
720eA    exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
720eA                    uiwhse, uiseq, uiuci, uiaolcns
720eA         into      :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
720eA                   :uiwhse,:uiseq,:uiuci,:uiaolcns
720eA         from UCIINFO
720eA              inner join uciinfoexa
720eA              on uiaddts = uiaaddts
720eA              and uiucilcns = uiaucilcns
720eA              and uilcns   = uialcns
720eA             where uilcns = :$uilcns
720eA               and uiwhse = :$uiwhse
720eA               and uiseq  = :$uiseq
730mA               and uiucilcns = :$uiucilcns
720eA               and uiuci  = :$uiuci;

720eA    if sqlstt <> sqlSuccess;
720eA      return;
720eA    else;
720eA      WrtUCIlog();
720eA    endif;

         // delete the first record for the temporary license

         exec sql delete
                  from uciinfo
                  where uilcns = :$uilcns
                    and uiwhse = :$uiwhse
650uA               and uiseq  = :$uiseq
650uA               and uiucilcns = :$uiucilcns
                    and uiuci  = :$uiuci;

720eA    exec sql delete
720eA             from uciinfoexa
720eA             where uialcns = :$uilcns
720eA               and uiaaddts = :uiaddts
720eA               and uiaucilcns = :uiucilcns;

      /end-free
     p Deleteone       e

700fA*----------------------------------------------------------------
700fA*  DeleteUci    Delete specific UCI from Box Breaker App
700fA*----------------------------------------------------------------

700fAp DeleteUci       b
700fAd DeleteUci       pi

700fA /free
730bA    // in order to write logs for each uci, I will need to get
730bA    // the uci before deleting.
730bA    exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
730bA                    uiwhse, uiseq, uiuci, uiaolcns
730bA         into      :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
730bA                   :uiwhse,:uiseq,:uiuci,:uiaolcns
730bA         from UCIINFO
730bA              inner join uciinfoexa
730bA              on uiaddts = uiaaddts
730bA              and uiucilcns = uiaucilcns
730bA              and uilcns   = uialcns
730bA             where uiwhse = :$uiwhse
730bA               and uiuci  = :$uiuci;

730bA    if sqlstt <> sqlSuccess;
730bA      return;
730bA    else;
730bA      WrtUCIlog();
730bA    endif;

700fA    // delete one specific UCI from Box Breaker

700fA    exec sql delete
700fA             from uciinfo
700fA             where uiwhse = :$uiwhse
700fA               and uiuci = :$uiuci
700fA               and uiSelTrn# = 0;

730bA    exec sql delete
730bA             from uciinfoexa
730bA             where uialcns = :uilcns
730bA               and uiaaddts = :uiaddts
730bA               and uiaucilcns = :uiucilcns;

730bD    //WrtUCIlog();
720eA /end-free
720eAp DeleteUci       e

710bA*----------------------------------------------------------------
710bA*  CkUciSplt Check to see if UCI splits record has been created
710bA*----------------------------------------------------------------

710bAp CkUciSplt       b
710bAd CkUciSplt       pi

710bA /free

710bA    cvtbar('*ALL': $uiUCI:
710bA        $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM        $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA        $cbkilolbsSent: $cbitem);
740bD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
710bD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
710bA    $barcode = $cvtdata;
710bA    $barcode2 = $cvtdata2;

710bA    exec sql select * into :usrec
710bA         from UCISPLITS
710bA         where uswhse = :$uiwhse
710bA           and USGS1C = :$uiuci
710bA           and usgs1b = '*UNASSIGNED'
710bA         fetch first row only;

710bA    if sqlstt = sqlSuccess;
710bA         $preturn = '*EXIST';
710bA         $pmessage = 'UCI '
710bA                   + '('
710bA                   + %trim(%editc($uiwhse:'Z'))
710bA                   + '/'
710bA                   + %trim($uiuci)
710bA                  + ') has already been broken down';
710bA      else;
710bA         $preturn = '*OK';
710bA         exec sql select * into :uirec
710bA              from uciinfo
710bA              where uiwhse = :$uiwhse
710bA                and uiuci  = :$uiuci
710bA              fetch first row only;
710bA         fillds();
710bA      endif;

      /end-free
710aAp CkUciSplt       e
     *----------------------------------------------------------------
     *  FillDS   Move record fields into data structure fields
     *----------------------------------------------------------------

     p FillDS          b
     d FillDS          pi

      /free

        $uiWhse    = uiWhse;
        $uiItem    = uiItem;
        $uiuci     = uiuci;
        $uiUciLcns = uiUciLcns;
        $uiLcns    = uiLcns;
        $uiSeq     = uiSeq;
        $uiserial  = uiserial;
        $uiWgtlbs  = uiWgtlbs;
        $uiWgtKgs  = uiWgtKgs;
        $uiSelTrn# = uiSelTrn#;
        $uiSelLbl# = uiSelLbl#;
        $uiSelOrd  = uiSelOrd;
        $uiSelSeq  = uiSelSeq;
        $uiSelCSeq = uiSelCSeq;
        $uiSelTrax = uiSelTrax;
        $uiCrtBy   = uiCrtBy;
740eA   $uirtntrn# = uirtntrn#;
720eA   $uiaGTIN    = uiaGTin;
720eA   $uiaLot     = uiaLot;
720eA   $uialcns  = uiaLcns;
720eA   $uiaolcns  = uiaoLcns;
720eA   $uiaOSeq    = uiSeq ;
720eA   $uiaUTyp    = uiauTyp;
720eA   $uiaEntd    = uiaEntd;
720eA   $uiaExpd    = uiaExpd;
720eA   //$uiSlotItm = uiaSItem;
720eA   $uiaSlUTyp  = uiaSUTyp;
        $uiaddts   = uiaddts;
        $uiadduc   = uiadduc;
        $uiaddpgm  = uiaddpgm;
        $uiaddemp  = uiaddemp;
        $uiaddusr  = uiaddusr;
        $uiaddjob  = uiaddjob;
        $uiaddnbr  = uiaddnbr;

        $uichgts  = uichgts;
        $uichguc  = uichguc;
        $uichgpgm = uichgpgm;
        $uichgemp = uichgemp;
        $uichgusr = uichgusr;
        $uichgjob = uichgjob;
        $uichgnbr = uichgnbr;

      /end-free
     p FillDS          e

     *----------------------------------------------------------------
     *  FillRec      Fill record fields
     *----------------------------------------------------------------

     p FillRec         b
     d FillRec         pi

      /free

        uiwhse    = $uiWhse;
        uiitem    = $uiItem;
        uiuci     = $uiuci;
        uiUciLcns = $uiUciLcns;
720eA   uiaUciLcns = $uiUciLcns;
        uilcns    = $uiLcns;
        uiSeq     = $uiSeq;
        uiSerial  = $uiSerial;
        uiWgtLbs  = $uiwgtlbs;
        uiWgtKgs  = $uiWgtKgs;
        uiSelTrn# = $uiSelTrn#;
        uiSelLbl# = $uiSelLbl#;
        uiSelOrd  = $uiSelOrd;
        uiSelSeq  = $uiSelSeq;
        uiSelCSeq = $uiSelCSeq;
        uiSelTrax = $uiSelTrax;
650dA   uiCrtBy   = $uiCrtBy;
650oA   uiRtnTrn# = $uiRtnTrn#;
720eA   uiaGTIN    = $uiaGTin;
720eA   uiaLot     = $uiaLot;
720eA   uialcns    = $uiaLcns;
720eA   uiaolcns  = $uiaoLcns;
720eA   uiaOSeq    = $uiSeq ;
720eA   uiaUTyp    = $uiauTyp;
720eA   uiasUTyp    = $uiasluTyp;
720eA   uiaEntd    = $uiaEntd;
720eA   uiaExpd    = $uiaExpd;
720eA   getSlotItem();
720eD   //uiSItem   = $uiSlotItm;
720eM   uiaSItem   = slot$item.$ititem;
720eA   uiaSUTyp   = $uiaSlUTyp;
720eA   uiapartlts = $uiapartlts;

      /end-free
     p FillRec         e

730cA*----------------------------------------------------------------
730cA*  GetAdjUci    Get one uci at a time for adjustmetn program
730cA*----------------------------------------------------------------

730cAp GetAdjUci       b
730cAd GetAdjUci       pi

730cA /free

730cA    // Get each uci scanned and send back to the adjustment
730cA    // program for individual processing.
730cA    exec sql select uiwhse, uiaddts, uiucilcns,uiseltrn#, uiapartlts,
730cA                    uiaaddts, uiaucilcns, uiuci, uiasItem, uiitem,
730cA                    uilcns, uiseq , uiserial, uiwgtlbs, uiwgtkgs,
730cA                    uisellbl#, uiselord, uiselseq, uiselcseq,
730cA                    uiseltrax, uicrtby, uiaddpgm, uiaddemp,
730cA                    uiaddusr, uiaddjob, uiaddnbr, uichgts,
730cA                    uichgpgm, uichgemp, uichgusr, uichgjob, uichgnbr,
730cA                    uialcns, uiaolcns, uiaoseq, uiautyp, uiasitem,
730cA                    uiasutyp, uiagtin, uiaentd, uiaexpd, uialot,
730cA                    uiapartlts, uiaucilcns
730cA         into      :uiwhse,:uiaddts,:uiucilcns,:uiseltrn#,:uiapartlts,
730cA                   :uiaaddts,:uiaucilcns,:uiuci,:uiasItem,:uiitem,
730cA                   :uilcns,:uiseq,:uiserial,:uiwgtlbs,:uiwgtkgs,
730cA                   :uisellbl#,:uiselord,:uiselseq,:uiselcseq,
730cA                   :uiseltrax,:uicrtby,:uiaddpgm,:uiaddemp,
730cA                   :uiaddusr,:uiaddjob,:uiaddnbr,:uichgts,
730cA                   :uichgpgm,:uichgemp,:uichgusr,:uichgjob,:uichgnbr,
730cA                   :uialcns,:uiaolcns,:uiaoseq,:uiautyp,:uiasitem,
730cA                   :uiasutyp,:uiagtin,:uiaentd,:uiaexpd,:uialot,
730cA                   :uiapartlts,:uiaucilcns
730cA         from UCIINFO
730cA              inner join uciinfoexa
730cA              on uiaddts = uiaaddts
730cA              and uiucilcns = uiaucilcns
730cA              and uialcns = uilcns
730cA         where uiseltrn# = 0
730cA           and uiapartlts = :$uiapartlts
730cA         fetch first row only;

730cA      if sqlstt <> sqlSuccess;
             $preturn = '*DONE';
730cA      else;
730cA        fillds();
730cA      endif;

730cA /end-free
730cAp GetAdjUci       e

730cA*----------------------------------------------------------------
730cA*  GetMisUci    Get one uci at a time for adjustmemt program
730cA*----------------------------------------------------------------

730cAp GetMisUci       b
730cAd GetMisUci       pi

730cA /free

730cA    // Get each uci scanned and send back to the adjustment
730cA    // program for individual processing.
730cA    exec sql select uiwhse, uiaddts, uiucilcns,uiseltrn#, uiapartlts,
730cA                    uiaaddts, uiaucilcns, uiuci, uiasItem, uiitem,
730cA                    uilcns, uiseq , uiserial, uiwgtlbs, uiwgtkgs,
730cA                    uisellbl#, uiselord, uiselseq, uiselcseq,
730cA                    uiseltrax, uicrtby, uiaddpgm, uiaddemp,
730cA                    uiaddusr, uiaddjob, uiaddnbr, uichgts,
730cA                    uichgpgm, uichgemp, uichgusr, uichgjob, uichgnbr,
730cA                    uialcns, uiaolcns, uiaoseq, uiautyp, uiasitem,
730cA                    uiasutyp, uiagtin, uiaentd, uiaexpd, uialot,
730cA                    uiapartlts, uiaucilcns
730cA         into      :uiwhse,:uiaddts,:uiucilcns,:uiseltrn#,:uiapartlts,
730cA                   :uiaaddts,:uiaucilcns,:uiuci,:uiasItem,:uiitem,
730cA                   :uilcns,:uiseq,:uiserial,:uiwgtlbs,:uiwgtkgs,
730cA                   :uisellbl#,:uiselord,:uiselseq,:uiselcseq,
730cA                   :uiseltrax,:uicrtby,:uiaddpgm,:uiaddemp,
730cA                   :uiaddusr,:uiaddjob,:uiaddnbr,:uichgts,
730cA                   :uichgpgm,:uichgemp,:uichgusr,:uichgjob,:uichgnbr,
730cA                   :uialcns,:uiaolcns,:uiaoseq,:uiautyp,:uiasitem,
730cA                   :uiasutyp,:uiagtin,:uiaentd,:uiaexpd,:uialot,
730cA                   :uiapartlts,:uiaucilcns
730cA         from UCIINFO
730cA              inner join uciinfoexa
730cA              on uiaddts = uiaaddts
730cA              and uiucilcns = uiaucilcns
730cA              and uialcns = uilcns
730cA         where uiseltrn# = 0
730cA           and uilcns     = :$uilcns
730dD           //and uiapartlts = :nodate
730dM           and uiapartlts <> :$uiapartlts
730cA         fetch first row only;

730cA      if sqlstt <> sqlSuccess;
             $preturn = '*DONE';
730cA      else;
730cA        fillds();
730cA      endif;

730cA /end-free
730cAp GetMisUci       e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

740eA*----------------------------------------------------------------
740eA*  GetInfo      Get UCI record for specific uci license
740eA*----------------------------------------------------------------

740eAp GetINFO         b
740eAd GetINFO         pi

740eA /free

740eA   if $uiucilcns <> ' ';
740eA    exec sql select * into :uirec
740eA             from UCIINFO
740eA             where uiwhse = :$uiwhse
740eA               and uiuci = :$uiuci
740eA               and uiucilcns = :$uiucilcns
740eA             fetch first row only;
740eA
740eA   else;
740eA    exec sql select * into :uirec
740eA             from UCIINFO
740eA             where uiwhse = :$uiwhse
740eA               and uiuci = :$uiuci
740eA             fetch first row only;
740eA   endif;

740eA    if sqlstt = sqlSuccess;
740eA      uciFound = *on;
720eA      exec sql select * into :uiarec
720eA             from UCIINFOEXA
720eA             where uiaaddts = :uiaddts
720eA               and uiaucilcns = :uiucilcns
720eA               and uialcns = :uilcns
720eA             fetch first row only;
720eA    else;
720eA      uciFound = *off;
720eA    endif;

720eA /end-free
720eAp GetInfo         e

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
             itemFound = *off;
             uniqueUCI = *off;
           when $drireturn <> '*OK';
             itemFound = *off;
             uniqueUCI = *off;
           other;
             itemFound = *on;
             if $ifucicde = '2'       // Unique GS1
               or $ifucicde = '4';    // Unique Internal AI99 GS1
                 uniqueUCI = *on;
             else;
                 uniqueUCI = *off;
             endif;
650nA        // If item is using uci receiving but not using uci selection
650nA        // Returns can not check for unique uci. Turn off unique
650nA
650nA        if $ifrcvmth = '2'        // uci receiving
650nA           and $ifsltmth <> '2'     // uci selection
650nA           and $pprogram = ('RN120')
650nA           or  $ifrcvmth = '2'        // uci receiving
650nA           and $ifsltmth <> '2'     // uci selection
650nA           and $pprogram = ('RN250');
650nA          uniqueUCI = *off;
650nA        endif;
         endsl;

      /end-free

     p GetItem         e

720eA*----------------------------------------------------------------
720eA*  getslotItem  Get slot item info.
720eA*----------------------------------------------------------------

720eAp GetSlotItem     b
720eAd GetSlotItem     pi

720eA /free

720eA    error = *off;

720eA    savever# = $itver#;
720eA    clear slot$Item;
720eA    clear slot$Item2;
720eA    slot$item.$itver# = savever#;

720eA    slot$item.$itwhse = kywhse;
720eA    slot$item.$ititem = kyitem;
720eA    $dridata =  slot$Item;
720eA    $dridata2 = slot$Item2;

720eA    driItemCalled = *on;
720eA    driItem('%GETSLOT': $pprogram: $drireturn: $drimessage:
720eA             $dridata: $dridata2);
720ea    slot$Item  = $dridata;
720eA    slot$Item2 = $dridata2;

720eA /end-free

720eAp GetSlotItem     e

650lA*----------------------------------------------------------------
650lA*  GetLabel      Get Label to determine if breakdown uom
650lA*----------------------------------------------------------------

650lAp GetLabel        b
650lAd GetLabel        pi

650lA /free

650lA    exec sql select * into :lbrec
650lA             from label
650lA             where lbwhse = :$uiwhse
650lA               and lblbl# = :$uisellbl#
650lA             fetch first row only;

650lA    if sqlstt = sqlSuccess;
650lA      if lbutyp = 'N';
650lA      else;
650lA        uniqueUCI = *off;
650lA      endif;
650lA    endif;

650lA /end-free
650lAp GetLabel        e

     *----------------------------------------------------------------
     *  GetSelected   Get selected UCI record
     *----------------------------------------------------------------

     p GetSelected     b
     d GetSelected     pi

      /free

710dA    if $psubcmd = '*SELRUN';
710dA      exec sql select * into :uirec
710dA               from UCIINFO
710dA               where uiwhse = :$uiwhse
710dA                 and uiuci = :$uiuci
710dA                 and uiseltrn# <> 0
710dA                 and uirtntrn# = :$uirtntrn#
710dA                 or  uiwhse = :$uiwhse
710dA                 and uiuci = :$uiuci
710dA                 and uiseltrn# <> 0
710dA                 and uirtntrn# = 0
710dA               fetch first row only;
710dA    else;
           exec sql select * into :uirec
                    from UCIINFO
                    where uiwhse = :$uiwhse
                      and uiuci = :$uiuci
                      and uiseltrn# <> 0
700cA                 and uirtntrn# =  0
                    fetch first row only;
710dA    endif;

         if sqlstt = sqlSuccess;
           selectedFound = *on;
         else;
           selectedFound = *off;
         endif;

      /end-free
     p GetSelected     e

650dA*----------------------------------------------------------------
650dA*  GetSpclUciLcns   Get special UCI License
650dA*----------------------------------------------------------------

650dAp GetSpclUciLcns  b
650dAd GetSpclUciLcns  pi

     *  Local variables

650dAD nextChar        s             13
650dAD nextNum         s             13  0

650dA /free
650dA    error = *off;

650dA    // Get special UCI license if not sent.

650dA    if $uiuciLcns = ' ';
650dA      ucilic#(nextNum: $uiwhse);
650dA      nextChar = %editc(nextNum:'X');
650iA      select;
650iA        when $psubcmd = '*SELECTPTI';
650iA          $uiuciLcns = 'P:' + nextChar;
650iA        other;
650dA          $uiuciLcns = 'U:' + nextChar;
650iA      endsl;
650dA    endif;

650dA /end-free
650dAp GetSpclUciLcns  e

     *----------------------------------------------------------------
     *  GetUCI       Get UCI record
     *----------------------------------------------------------------

     p GetUCI          b
     d GetUCI          pi

      /free

         exec sql select * into :uirec
                  from UCIINFO
                  where uiwhse = :$uiwhse
                    and uiuci = :$uiuci
650cA               and uiseltrn# = 0
                  fetch first row only;

         if sqlstt = sqlSuccess;
           uciFound = *on;
720eA      exec sql select * into :uiarec
720eA             from UCIINFOEXA
720eA             where uiaaddts = :uiaddts
720eA               and uiaucilcns = :uiucilcns
720eA               and uialcns = :uilcns
720eA             fetch first row only;
         else;
           uciFound = *off;
         endif;

      /end-free
     p Getuci          e

     *----------------------------------------------------------------
     *  GetUnselected   Get unselected UCI Record
     *----------------------------------------------------------------

     p GetUnselected   b
     d GetUnselected   pi

      /free

         // First see if a record exists for the UCI

         getUCI();
         if not uciFound;
           unselectedFound = *off;
           return;
         endif;

         // Now see if an unselected record exists for the UCI

         if uiseltrn# = 0;
           unselectedFound = *on;
           return;
         endif;

         exec sql select * into :uirec
                  from UCIINFO
                  where uiwhse = :$uiwhse
                    and uiuci = :$uiuci
                    and uiseltrn# = 0
                  fetch first row only;

         if sqlstt = sqlSuccess;
           unselectedFound = *on;
         else;
           unselectedFound = *off;
         endif;

      /end-free
     p GetUnselected   e

650dA*----------------------------------------------------------------
650dA*  GetLicInfo   Get licinfo
650dA*----------------------------------------------------------------

650dAp GetLicInfo      b
650dAd GetLicInfo      pi

      /free
        $dricommand = '*LICINFO';
        $drisubcmd  = '*FIND4UCI';
        $drisys2upd = 'D';
        select;
          when $bcProdDSent and $bcLotSent;
            // convert the date from the uci scan
            $cvcmd = '*YMDCMD ';
            $cvd6i = %trimr(%editc($bcProdD:'X'));
            cvtdte ($cvtdt);
            clr$licinfo();
            $lnwhse = $uiwhse;
            $lnitem = $uiitem;
            $lnmfgdate = $cvd8o;
            $lnlot     = $bclot;

          when $bcExpDSent and $bcLotSent;
            // convert the date from the uci scan
            $cvcmd = '*YMDCMD ';
            $cvd6i = %trimr(%editc($bcExpD:'X'));
            cvtdte ($cvtdt);
            clr$licinfo();
            $lnwhse = $uiwhse;
            $lnitem = $uiitem;
            $lnmfgexp  = $cvd8o;
            $lnlot     = $bclot;

          when $bcProdDSent;
            // convert the date from the uci scan
            $cvcmd = '*YMDCMD ';
            $cvd6i = %trimr(%editc($bcProdD:'X'));
            cvtdte ($cvtdt);
            clr$licinfo();
            $lnwhse = $uiwhse;
            $lnitem = $uiitem;
            $lnmfgdate = $cvd8o;

          when $bcExpDSent;
            // convert the date from the uci scan
            $cvcmd = '*YMDCMD ';
            $cvd6i = %trimr(%editc($bcExpD:'X'));
            cvtdte ($cvtdt);
            clr$licinfo();
            $lnwhse = $uiwhse;
            $lnitem = $uiitem;
            $lnmfgexp  = $cvd8o;

          when $bcGtinSent;
            clr$licinfo();
            $lnwhse = $uiwhse;
            $lnitem = $uiitem;

650fA     when $bcAi99Sent;
650fA       clr$licinfo();
650fA       $lnwhse = $uiwhse;
650fA       $lnitem = $uiitem;
650fA       $lnlcns = $uilcns;

        endsl;

        zzzdricop();

        if $lnlcns > ' ';
          $uilcns = $lnlcns;
          $uiseq = $lnseq;
        else;
          AddLicInfo();
        endif;

      /end-free
650dAp GetLicInfo      e

     *----------------------------------------------------------------
     *  GetLicRec    Get the first uci record for the license number
     *----------------------------------------------------------------

     p GetLicRec       b
     d GetLicRec       pi

      /free

        exec sql select * into :uirec
                 from UCIINFO
                 where uiwhse = :$uiwhse
                   and uilcns = :$uilcns
720aA              and UIWGTLBS <> 0
                 fetch first row only;

640aD   //if sqlstt = sqlNoData;
640aD   if sqlstt = sqlSuccess;
650mD     //$preturn = '*DONE';
650mM     $preturn = '*OK  ';
650mA   else;
650mA     $preturn = '*NONE';
        endif;

      /end-free
     p GetLicRec       e
730dA*----------------------------------------------------------------
730dA*  GetLicWgt    Get total weight for license.
730dA*----------------------------------------------------------------

730dAp GetLicWgt       b
730dAd GetLicWgt       pi

730dA /free

730dA    // Need to get total weight for a license.

720 A   exec sql select sum(UIWGTLBS) into :total_wgt:MyfieldNull
730dA            from uciinfo2
730dA            where uilcns = :$uilcns
730dA              and uiwhse = :$uiwhse;

730dA   if MyfieldNull = -1;
730dA     total_wgt=0;
730dA   endif;

730dA    If sqlstt = sqlSuccess;
730dA    endif;

730dA    // need to send count back - use $pmessage field
730dA      $preturn = '*LICWGT  ';
730dA      $pmessage = %trim(%editc(total_wgt:'X'));

730dA /end-free
730dAp GetLicWgt       e

650cA*----------------------------------------------------------------
650cA*  Get1UCIbyLic Get one Uci at a time - until no more = *DONE.
650cA*----------------------------------------------------------------

650cAp Get1UCIbyLic    b
650cAd Get1UCIbyLic    pi

      /free

        exec sql select * into :uirec
                 from UCIINFO
                 where uiwhse = :$uiwhse
                   and uilcns = :$uilcns
                 fetch first row only;

        if sqlstt = sqlNoData;
          $preturn = '*DONE';
        else;
720eA     exec sql select * into :uiarec
720eA            from UCIINFOexa
720eA            where uiaaddts = :uiaddts
720eA              and uiaucilcns = :uiucilcns
720eA              and uialcns = :uilcns
720eA            fetch first row only;
730lA    If sqlstt = sqlSuccess;
           FillDs();
730lA    endif;
        endif;

      /end-free
650cAp Get1UCIbyLic    e

650oA*----------------------------------------------------------------
650oA*  Get1UCI4Run  Get one Uci at a time - until no more = *DONE.
650oA*----------------------------------------------------------------

650oAp Get1UCI4Run     b
650oAd Get1UCI4Run     pi

650oA /free

650oA   exec sql select * into :uirec
650oA            from UCIINFO
650oA            where uiwhse = :$uiwhse
650oA             and uisellbl# = :$uisellbl#
650oA             and uirtntrn# = :$uirtntrn#
650oA             and uiseltrn# = :$uiseltrn#
                 fetch first row only;

650oA   if sqlstt = sqlNoData;
650oA     $preturn = '*DONE';
650oA   else;
650oA     FillDs();
650oA   endif;

650oA /end-free
650oAp Get1UCI4Run     e

700cA*----------------------------------------------------------------
700cA*  Get1RTN Get one Uci at a time - until no more = *DONE.
700cA*----------------------------------------------------------------

700cAp Get1RTN         b
700cAd Get1RTN         pi

700cA /free

700cA   exec sql select * into :uirec
700cA            from UCIINFO
700cA            where uiwhse = :$uiwhse
700cA              and uilcns = :$uilcns
700cA              and uiucilcns > :$uiucilcns
700cA            fetch first row only;

700cA   if sqlstt = sqlNoData;
700cA     $preturn = '*DONE';
700cA   else;
700cA     FillDs();
700cA   endif;

700cA /end-free
700cAp Get1RTN         e

650cA*----------------------------------------------------------------
650cA*  Get2Rtn      Get UCI record previously selected being returned
650cA*----------------------------------------------------------------

650cAp Get2Rtn         b
650cAd Get2Rtn         pi

      /free

         exec sql select * into :uirec
                  from UCIINFO
                  where uiwhse = :$uiwhse
                    and uiuci = :$uiuci
                    and uiseltrn# <> 0
                    and uirtntrn# =  0
                  fetch first row only;

         if sqlstt = sqlSuccess;
           fillds();
           uciFound = *on;
         else;
           uciFound = *off;
           error = *on;
           $preturn = '*NOPRVSEL ';
           $pmessage = 'UCI not previously selected '
                     + '('
                     + %trim(%editc($uiwhse:'Z'))
                     + '/'
                     + %trim($uiuci)
                     + ')';
         endif;

      /end-free
650cAp Get2Rtn         e

650hA*----------------------------------------------------------------
650hA*  Get4Bulk     Get one Uci at a time - until no more = *DONE.
650hA*----------------------------------------------------------------

650hAp Get4Bulk        b
650hAd Get4Bulk        pi

      /free

        exec sql select * into :uirec
                 from UCIINFO
                 where uiwhse = :$uiwhse
                   and uilcns = :$uilcns
                   and uiseltrn# = 0
                 fetch first row only;

        if sqlstt = sqlNoData;
          $preturn = '*DONE';
        else;
          FillDs();
        endif;

      /end-free
650hAp Get4Bulk        e

730iA*----------------------------------------------------------------
730iA*  Get4Lbl      Get the uci that has been seleted
730iA*----------------------------------------------------------------

730iAp Get4Lbl         b
730iAd Get4Lbl         pi

730iA /free

730iA   exec sql select * into :uirec
730iA            from UCIINFO
730iA            where uiwhse = :$uiwhse
730iA              and uiuci  = :$uiuci
730iA              and uiseltrn# <> 0
730iA              and uirtntrn# = 0
730iA            fetch first row only;

730iA   if sqlstt = sqlSuccess;
730iA     FillDs();
730iA   endif;

730iA /end-free
730iAp Get4Lbl         e

730fA*----------------------------------------------------------------
730fA*  Get4UnPick   Get the UCI being deleted from selection.
730fA*----------------------------------------------------------------

730fAp Get4UnPick      b
730fAd Get4UnPick      pi

730fA /free

730fA   exec sql select * into :uirec
730fA            from UCIINFO
730fA            where uiwhse = :$uiwhse
730fA              and uiuci  = :$uiuci
730fA              and uiseltrn# = :$uiseltrn#
730fA              and uisellbl# = :$uisellbl#
730fA            fetch first row only;

730fA   if sqlstt = sqlNoData;
730fA     error = *on;
730fA     $preturn = 'UCINOTSEL';
730fA     $pmessage = 'Error UCI was not previously selected';
730fA   else;
730fA     FillDs();
730fA   endif;

730fA /end-free
730fAp Get4UnPick      e

740aA*----------------------------------------------------------------
740aA*  GetLbs    Get lbs from uciinfo record
740aA*----------------------------------------------------------------

740aAp GetLbs          b
740aAd GetLbs          pi

740aA /free

740aA   error = *off;

740aA   exec sql select * into :uirec
740aA      from UCIINFO
740aA       where uiwhse = :$uiwhse
740aA         and uiuci = :$uiuci;
740aA   if sqlstt <> sqlSuccess;
740aA     $preturn = 'UseGS1Wgt';
740aA   else;
          fillds();
740aA   endif;

740aA /end-free
740aAp GetLbs          e

     *----------------------------------------------------------------
     *  RcvCancel    User Cancelled - all entries will be deleted
     *----------------------------------------------------------------

     p RcvCancel       b
     d RcvCancel       pi

      /free

720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before resetting.
720eA    dow forever = forever;
720eA    exec sql select * into :uirec
720eA         from UCIINFO
720eA         where uilcns = :$uilcns
720eA           and uiwhse = :$uiwhse
720eA           and uiseltrn# = 0
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        $uiaction = 'CANCEL';
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getSlotItem();
720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;
         // delete all records for the license

         exec sql delete
                  from uciinfo
                  where uilcns = :$uilcns
720eA               and uiuci = :$uiuci
                    and uiwhse = :$uiwhse
                    and uiseltrn# = 0;

720eA    exec sql delete
720eA             from uciinfoexa
720eA             where uiaaddts = :uiaddts
720eA               and uiaucilcns = :uiucilcns
720eA               and uialcns = :uilcns;

730eA    // need to reset uciwork file
730eA    exec sql update uciwork set
730eA            uiwload = ' '
730eA         where uiwwhse = :$uiwhse
730eA           and uiwuci = :uiuci;
720eA    enddo;
      /end-free
     p RcvCancel       e

740aA*----------------------------------------------------------------
740aA*  Reduce    Reduce the weight in the uciinfo record
740aA*----------------------------------------------------------------

740aAp Reduce          b
740aAd Reduce          pi

740aA /free

740aA   error = *off;

740aA   exec sql select * into :uirec
740aA      from UCIINFO
740aA       where uiwhse = :$uiwhse
740aA         and uiuci = :$uiuci
740aA         and uiSeltrn# = 0;
740aA   if sqlstt <> sqlSuccess;
740aA     error = *on;
740aA     $preturn = 'ERRREDUCE';
740aA     $pmessage = 'Error Reducing   '
740aA               + '('
740aA               + %trim(%editc($uiwhse:'Z')                        )
740aA               + '/'
740aA               + %trim($uiuci)
740aA               + ')'
740aA               + '/'
740aA               + %trim(%editc($uiwgtlbs:'Z')                      )
740aA               + ')'
740aA               + '-' + 'UCIINFO';
740aA   else;
740aA     uiwgtlbs = uiwgtlbs - $uiwgtlbs;
740aA     if uiwgtlbs < 0;
740aA       uiwgtlbs = 0;
740aA     endif;
740aA     GetCurrStamp();
740aA     exec sql update uciinfo set
740aA              uiwgtlbs = :uiwgtlbs,
740aA              uichgts = :currStampSys,
740aA              uichguc = :currStampUC
740aA            where uiwhse = :$uiwhse
740aA             and uiuci = :$uiuci
740aA             and uiseltrn# = 0;
740aA    if sqlstt <> sqlSuccess;
740aA      error = *on;
740aA      $preturn = 'ERRREDUCE1';
740aA      $pmessage = 'Error Updating   '
740aA                + '('
740aA                + %trim(%editc(uiwhse:'Z')                        )
740aA                + '/'
740aA                + %trim(uiuci)
740aA                + ')'
740aA               + '/'
740aA               + %trim(%editc($uiwgtlbs:'Z')                      )
740aA               + ')'
740aA                + '-' + 'UCIINFO';
740aA    else;
740aA      fillds();
740aA      WrtUCIlog();
740aA    endif;
740aA   endif;

740aA /end-free
740aAp Reduce          e

     *----------------------------------------------------------------
     *  Replace   Replace temp xdock with permanent
     *----------------------------------------------------------------

     p Replace         b
     d Replace         pi

      /free

         error = *off;

         // initialize fields
         clear uirec;
720eA    clear uiarec;
         FillRec();

700bA    uiselcseq = $uiselcseq;
         GetCurrStamp();
         uiaddts = $uiaddts;
720eA    uiaaddts = $uiaddts;
         uiadduc = $uiadduc;
         uiaddpgm = $uiaddpgm;
         uiaddemp = $uiaddemp;
         uiaddusr = $uiaddusr;
         uiaddjob = $uiaddjob;

         uichgnbr = $uichgnbr;
         uichgts = CurrStampSys;
         uichguc = CurrStampUC;
         uichgpgm = $uichgpgm;
         uichgemp = $uichgemp;
         uichgusr = $uichgusr;
         uichgjob = $uichgjob;
         uichgnbr = $uichgnbr;

         exec sql insert into uciinfo values(:uirec);

640aD    //if sqlstt = sqlDupRecd;
640aM    if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRADDREC4';
           $pmessage = 'Error Adding rec '
                     + '('
                     + %trim(%editc(uiwhse:'Z')                        )
                     + '/'
                     + %trim(uiuci)
                     + ')'
                     + '-' + 'UCIINFO';
720eA    else;
720eA      WrtUCIlog();
         endif;

720eA    exec sql insert into uciinfoexa values(:uiarec);

720eA    if sqlstt <> sqlSuccess;
720ea      error = *on;
730kD      //$preturn = 'ERRADDREC4';
730kM      $preturn = 'ERRADDREC5';
720eA      $pmessage = 'Error Adding rec '
720eA                + '('
730kD                //+ %trim(%editc(uiwhse:'Z'))
730kM                + %char(uiaaddts)
720eA                + '/'
730kD                //+ %trim(uiuci)
730kM                + %trim(uiaucilcns)
730kA                + '/'
730kA                + %trim(uialcns)
720eA                + ')'
720eA                + '-' + 'UCIINFOEXA';
720eA    endif;
      /end-free
     p Replace         e

650sA*----------------------------------------------------------------
650sA*  ResetUCI     Remove selection info for RESETUCI from Voice
650sA*----------------------------------------------------------------

650sAp ResetUCI        b
650sAd ResetUCI        pi

650sA /free

650sA    // Need to remove selection information.


650sA   GetCurrStamp();

720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before resetting.
720eA    dow forever = forever;
720eA    exec sql select * into :uirec
720eA         from UCIINFO
720eA         where uiwhse = :$uiwhse
720eA          and uisellbl# = :$uisellbl#
720eA          and uiseltrn# = :$uiseltrn#
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        uilcns = uilcns;
720eA        $uiaction = 'RESETUCI';
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getslotItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;

650sA   exec sql update uciinfo set
650sA              uiseltrn# = 0,
650sA              uisellbl# = 0,
650sA              uiselord  = 0,
650sA              uiselseq  = 0,
650sA              uiselcseq = 0,
650sA              uiseltrax = 0,
650sA              uirtntrn# = 0,
650sA              uichgts = :currStampSys,
650sA              uichguc = :currStampUC,
650sA              uichgpgm = :$uichgpgm,
650sA              uichgemp = :$uichgemp,
650sA              uichgusr = :$uichgusr,
650sA              uichgjob = :$uichgjob,
650sA              uichgnbr = :$uichgnbr
650sA            where uiwhse = :$uiwhse
650sA             and uisellbl# = :$uisellbl#
720eA             and uiseltrn# = :$uiseltrn#
720eA             and uiuci = :uiuci;

650sA   if sqlstt = sqlSuccess;
650sA     recUpdated = *on;
650sA   endif;

720eA   enddo;
650sA /end-free
650sAp ResetUCI        e

650cA*----------------------------------------------------------------
650cA*  ReturnUCI    Mark UCI as Returned
650cA*----------------------------------------------------------------

650cAp ReturnUCI       b
650cAd ReturnUCI       pi

     *  Local Variables
     d zone            s              6
      /free

        GetCurrStamp();

        exec sql update uciinfo set
                   uirtntrn# = :$uirtntrn#,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                    where uiwhse = :$uiwhse
                      and uilcns = :$uilcns
                      and uiuci  = :$uiuci
                      and uiucilcns = :$uiucilcns;

        if sqlstt <> sqlSuccess;
          error = *on;
          $preturn = 'RTNERR2';
          $pmessage = 'Error Updating return info '
                    + '('
                    + %trim(%editc(uiwhse:'Z'))
                    + '/'
                    + %trim(uiuci)
                    + ')'
                    + '-' + 'UCIINFO';
720eA   else;
720eA      WrtUCIlog();
        endif;


      /end-free
650cAp ReturnUCI       e

650tA*----------------------------------------------------------------
650tA*  ReplenUse    Mark UCI as Used by Replenishment
650tA*----------------------------------------------------------------

650tAp ReplenUse       b
650tAd ReplenUse       pi

     *  Local Variables
     d zone            s              6
      /free

        GetCurrStamp();

720eA   // in order to write logs for each uci, I will need to get
720eA   // each uci before updating.
720eA   dow forever = forever;
720eA     exec sql select * into :uirec
720eA          from UCIINFO
720eA          where uiwhse = :$uiwhse
720eA            and uiuci  = :$uiuci
720eA            and uiseltrn# = 0
720eA          fetch first row only;

720eA     if sqlstt <> sqlSuccess;
720eA       return;
720eA     else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA       // setup some data that isn't passed in
720eA       $uiuci  = uiuci;
720eA       uilcns = uilcns;
720eA       $uiaction = 'REPLUSE';
720eA       // Get slot information
720eA       kywhse = uiWhse;
720eA       kyitem = uiasItem;
720eA       getItem();

720eA       // Get item information
720eA       kywhse = uiWhse;
720eA       kyitem = uiItem;
720eA       getItem();
720eA       WrtUCIlog();
720eA     endif;
          exec sql update uciinfo set
                   uiseltrn# = :$uiseltrn#,
                   uisellbl# = :$uisellbl#,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                    where uiwhse = :$uiwhse
                      and uiuci  = :$uiuci
                      and uiseltrn# = 0;

        if sqlstt <> sqlSuccess;
          error = *on;
          $preturn = 'REPLENERR';
          $pmessage = 'Error Updating Replenishment Use '
                    + '('
                    + %trim(%editc(uiwhse:'Z'))
                    + '/'
                    + %trim(uiuci)
                    + ')'
                    + '-' + 'UCIINFO';
        endif;

720eA   enddo;

      /end-free
650tAp ReplenUse       e

730cA*----------------------------------------------------------------
730cA*  RmvAdjTime   Remove the UIAPARTLTS  value
730cA*----------------------------------------------------------------

730cAp RmvAdjTime      b
730cAd RmvAdjTime      pi

730cA /free
730cA   Exec Sql
730cA     UPDATE uciinfoexa as a
730cA     SET uiapartlts = :nodate
730cA     WHERE (Select count(*) From uciinfo as b
730cA             where b.uiwhse = :$uiwhse
730cA             and a.uiapartlts = :$uiapartlts
730cA             and a.uiaaddts = b.uiaddts
730cA             and a.uiaucilcns = b.uiucilcns
730cA             and a.uialcns = b.uilcns
730cA             and b.uiuci = :$uiuci) >0;
730cA /end-free
730cAp RmvAdjTime      e

720eA*----------------------------------------------------------------
720eA*  RmvALLAdjust  Remove ALL UCI - used by adjustments for taking
720eA*                 all uci for the license out of system
720eA*----------------------------------------------------------------
720eAp RmvALLAdjust    b
720eAd RmvALLAdjust    pi
720eA
720eA /free
720eA
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before updating.
720eA    dow forever = forever;
720eA      exec sql select * into :uirec
720eA         from UCIINFO
720eA         Where uilcns = :$uitolcns
720eA           and uiwhse = :$uiwhse
720eA           and uisellbl# = 0
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        // don't think we want to do this
720eA        //uilcns = $uitolcns;
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;

720eA      GetCurrStamp();
720eA      Exec Sql
720eA      UPDATE uciinfoexa as a
720eA      SET uialcns   = ' '
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA      exec sql update uciinfo set
720eA              uichgts = :currStampSys,
720eA              uichguc = :currStampUC,
720eA              uichgpgm = :$uichgpgm,
720eA              uichgemp = :$uichgemp,
720eA              uichgusr = :$uichgusr,
720eA              uichgjob = :$uichgjob,
720eA              uichgnbr = :$uichgnbr,
730cD              //uisellbl# = :$uilbl#,
720eA              uilcns = ' '
720eA               where uiwhse = :$uiwhse
720eA                 and uiuci = :$uiuci;

720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'ADJRMVALL';
720eA        $pmessage = 'Error: UCI was not removed.';
720eA      endif;
720eA
720eA    enddo;
720eA /end-free
720eA
720eAp RmvALLAdjust    e
720eA*----------------------------------------------------------------
720eA*  RmvMisAdjust  Remove ALL UCI for the license - that were not
720eA*                 scanned during adjustment type 3
720eA*----------------------------------------------------------------
720eAp RmvMisAdjust    b
720eAd RmvMisAdjust    pi
720eA
720eA /free
720eA
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before updating.
720eA    dow forever = forever;
720eA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
720eA                      uiwhse, uisellbl#, uiapartlts, uiasitem, uiitem
730aA                      , uiuci, uilcns
720eA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
720eA                     :uiwhse,:uisellbl#,:uiapartlts,:uiasitem,:uiitem
730aA                     ,:uiuci,:uilcns
720eA         from UCIINFO
720eA              inner join uciinfoexa
720ea              on uiaddts = uiaaddts
720ea              and uiucilcns = uiaucilcns
720ea              and uialcns = uilcns
720eA         Where uilcns = :$uitolcns
720eA           and uiwhse = :$uiwhse
720eA           and uisellbl# = 0
720eA           and uiapartlts = :nodate
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;

720eA      GetCurrStamp();
720eA      Exec Sql
720eA      UPDATE uciinfoexa as a
720eA      SET uialcns   = ' '
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA      exec sql update uciinfo set
720eA              uichgts = :currStampSys,
720eA              uichguc = :currStampUC,
720eA              uichgpgm = :$uichgpgm,
720eA              uichgemp = :$uichgemp,
720eA              uichgusr = :$uichgusr,
720eA              uichgjob = :$uichgjob,
720eA              uichgnbr = :$uichgnbr,
730cD              //uisellbl# = :$uilbl#,
720eA              uilcns = ' '
720eA               where uiwhse = :$uiwhse
720eA                 and uiuci = :$uiuci;

720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'RMVMISADJ';
720eA        $pmessage = 'Error: UCI was not removed.';
720eA      endif;
720eA
720eA    enddo;
720eA /end-free
720eA
720eAp RmvMisAdjust    e
730cA*----------------------------------------------------------------
730cA*  RmvMisUCILcs  Remove license from uci that was not
730cA*                 scanned during adjustment type 3
730cA*----------------------------------------------------------------
730cAp RmvMisUCILcs    b
730cAd RmvMisUCILcs    pi
730cA
730cA /free
730cA
730cA    // in order to write logs for each uci, I will need to get
730cA    // each uci before updating.
730cA    //dow forever = forever;
730cA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
730cA                      uiwhse, uisellbl#, uiapartlts, uiasitem, uiitem
730cA                      , uiuci, uilcns
730cA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
730cA                     :uiwhse,:uisellbl#,:uiapartlts,:uiasitem,:uiitem
730cA                     ,:uiuci,:uilcns
730cA         from UCIINFO
730cA              inner join uciinfoexa
730cA              on uiaddts = uiaaddts
730cA              and uiucilcns = uiaucilcns
730cA              and uialcns = uilcns
730cA         Where uiuci = :$uiuci
730cA           and uiwhse = :$uiwhse
730cA           and uisellbl# = 0
730cA           and uiapartlts = :nodate
730cA         fetch first row only;

730cA      if sqlstt <> sqlSuccess;
730cA        return;
730cA      else;
730cA        // Get slot information
730cA        kywhse = uiWhse;
730cA        kyitem = uiasItem;
730cA        getItem();

730cA        // Get item information
730cA        kywhse = uiWhse;
730cA        kyitem = uiItem;
730cA        getItem();
730cA        WrtUCIlog();
730cA      endif;
730cA
730cA      GetCurrStamp();
730cA      Exec Sql
730cA      UPDATE uciinfoexa as a
730cA      SET uialcns   = ' '
730cA      WHERE (Select count(*) From uciinfo as b
730cA             where b.uiwhse = :$uiwhse
730cA             and   b.uiaddts = a.uiaaddts
730cA             and   b.uilcns = a.uialcns
730cA             and   b.uiucilcns = a.uiaucilcns
730cA             and b.uiuci = :uiuci ) >0;
730cA      if sqlstt <> sqlSuccess;
730cA      endif;
730cA
730cA      exec sql update uciinfo set
730cA              uichgts = :currStampSys,
730cA              uichguc = :currStampUC,
730cA              uichgpgm = :$uichgpgm,
730cA              uichgemp = :$uichgemp,
730cA              uichgusr = :$uichgusr,
730cA              uichgjob = :$uichgjob,
730cA              uichgnbr = :$uichgnbr,
730cA              //uisellbl# = :$uilbl#,
730cA              uilcns = ' '
730cA               where uiwhse = :$uiwhse
730cA                 and uiuci = :$uiuci;
730cA
730cA      if sqlstt <> sqlSuccess;
730cA        error = *on;
730cA        $preturn  = 'RMVUCILCS';
730cA        $pmessage = 'Error: UCI was not removed.';
730cA      endif;
730cA
730cA    //enddo;
730cA /end-free
730cA
730cAp RmvMisUCILcs    e
730cA*----------------------------------------------------------------
730cA*  RmvADJUCILcs  Remove license from uci that is being adjusted
730cA*                 out -  during adjustment type 3
730cA*----------------------------------------------------------------
730cAp RmvADJUCILcs    b
730cAd RmvADJUCILcs    pi
730cA
730cA /free
730cA
730cA    // in order to write logs for each uci, I will need to get
730cA    // each uci before updating.
730cA    //dow forever = forever;
730cA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
730cA                      uiwhse, uisellbl#, uiapartlts, uiasitem, uiitem
730cA                      , uiuci, uilcns
730cA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
730cA                     :uiwhse,:uisellbl#,:uiapartlts,:uiasitem,:uiitem
730cA                     ,:uiuci,:uilcns
730cA         from UCIINFO
730cA              inner join uciinfoexa
730cA              on uiaddts = uiaaddts
730cA              and uiucilcns = uiaucilcns
730cA              and uialcns = uilcns
730cA         Where uiuci = :$uiuci
730cA           and uiwhse = :$uiwhse
730cA           and uisellbl# = 0
730cA           and uiapartlts = :$uiapartlts
730cA         fetch first row only;

730cA      if sqlstt <> sqlSuccess;
730cA        return;
730cA      else;
730cA        // Get slot information
730cA        kywhse = uiWhse;
730cA        kyitem = uiasItem;
730cA        getItem();

730cA        // Get item information
730cA        kywhse = uiWhse;
730cA        kyitem = uiItem;
730cA        getItem();
730cA        WrtUCIlog();
730cA      endif;
730cA
730cA      GetCurrStamp();
730cA      Exec Sql
730aA      UPDATE uciinfoexa as a
730cA      SET uialcns   = ' '
730cA      WHERE (Select count(*) From uciinfo as b
730cA             where b.uiwhse = :$uiwhse
730cA             and   b.uiaddts = a.uiaaddts
730cA             and   b.uilcns = a.uialcns
730cA             and   b.uiucilcns = a.uiaucilcns
730cA             and b.uiuci = :uiuci ) >0;
730cA      if sqlstt <> sqlSuccess;
730cA      endif;
730cA
730cA      exec sql update uciinfo set
730cA              uichgts = :currStampSys,
730cA              uichguc = :currStampUC,
730cA              uichgpgm = :$uichgpgm,
730cA              uichgemp = :$uichgemp,
730cA              uichgusr = :$uichgusr,
730cA              uichgjob = :$uichgjob,
730cA              uichgnbr = :$uichgnbr,
730cA              //uisellbl# = :$uilbl#,
730cA              uilcns = ' '
730cA               where uiwhse = :$uiwhse
730cA                 and uiuci = :$uiuci;
730cA
730cA      if sqlstt <> sqlSuccess;
730cA        error = *on;
730cA        $preturn  = 'RMVADJLCS';
730cA        $pmessage = 'Error: UCI was not removed.';
730cA      endif;
730cA
730cA    //enddo;
730cA /end-free
730cA
730cAp RmvADJUCILcs    e
730cA*----------------------------------------------------------------
730cA*  SetADJUCILcs  Set license from uci that is being adjusted
730cA*                 in -  during adjustment type 3
730cA*----------------------------------------------------------------
730cAp SetADJUCILcs    b
730cAd SetADJUCILcs    pi
730cA
730cA /free
730cA
730cA    // in order to write logs for each uci, I will need to get
730cA    // each uci before updating.
730cA    //dow forever = forever;
730cA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uilcns,
730cA                      uiwhse, uisellbl#, uiapartlts, uiasitem, uiitem
730cA                      , uiuci, uilcns
730cA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uilcns,
730cA                     :uiwhse,:uisellbl#,:uiapartlts,:uiasitem,:uiitem
730cA                     ,:uiuci,:uilcns
730cA         from UCIINFO
730cA              inner join uciinfoexa
730cA              on uiaddts = uiaaddts
730cA              and uiucilcns = uiaucilcns
730cA              and uialcns = uilcns
730cA         Where uiuci = :$uiuci
730cA           and uiwhse = :$uiwhse
730cA           and uisellbl# = 0
730cA           and uiapartlts = :$uiapartlts
730cA         fetch first row only;

730cA      if sqlstt <> sqlSuccess;
730cA        return;
730cA      else;
730cA        // Get slot information
730cA        kywhse = uiWhse;
730cA        kyitem = uiasItem;
730cA        getItem();

730cA        // Get item information
730cA        kywhse = uiWhse;
730cA        kyitem = uiItem;
730cA        getItem();
730cA        WrtUCIlog();
730cA      endif;
730cA
730cA      GetCurrStamp();
730cA      Exec Sql
730cA      UPDATE uciinfoexa as a
730cA      SET uialcns   = :$uitolcns
730cA      WHERE (Select count(*) From uciinfo as b
730cA             where b.uiwhse = :$uiwhse
730cA             and   b.uiaddts = a.uiaaddts
730cA             and   b.uilcns = a.uialcns
730cA             and   b.uiucilcns = a.uiaucilcns
730cA             and b.uiuci = :uiuci ) >0;
730cA      if sqlstt <> sqlSuccess;
730cA      endif;
730cA
730cA      exec sql update uciinfo set
730cA              uichgts = :currStampSys,
730cA              uichguc = :currStampUC,
730cA              uichgpgm = :$uichgpgm,
730cA              uichgemp = :$uichgemp,
730cA              uichgusr = :$uichgusr,
730cA              uichgjob = :$uichgjob,
730cA              uichgnbr = :$uichgnbr,
730cA              //uisellbl# = :$uilbl#,
730cA              uilcns = :$uitolcns
730cA               where uiwhse = :$uiwhse
730cA                 and uiuci = :$uiuci;
730cA
730cA      if sqlstt <> sqlSuccess;
730cA        error = *on;
730cA        $preturn  = 'RMVADJLCS';
730cA        $pmessage = 'Error: UCI was not removed.';
730cA      endif;
730cA
730cA    //enddo;
730cA /end-free
730cA
730cAp SetADJUCILcs    e
720eA*----------------------------------------------------------------
720eA*  RmvUCIAdjust  Remove UCI - used by adjustments for taking
720eA*                 uci out of system
720eA*----------------------------------------------------------------
720eAp RmvUCIAdjust    b
720eAd RmvUCIAdjust    pi
720eA
720eA /free
720eA
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before updating.
720eA    dow forever = forever;
720eA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uiwhse,
720eA                      uisellbl#, uiuci, uiasitem, uiitem
720eA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uiwhse,
720eA                     :uisellbl#,:uiuci,:uiasitem,:uiitem
720eA         from UCIINFO
720eA              inner join uciinfoexa
720ea              on uiaddts = uiaaddts
720ea              and uiucilcns = uiaucilcns
720ea              and uialcns = uilcns
720eA         Where uiapartlts = :$uiapartlts
720eA           and uiwhse = :$uiwhse
720eA           and uisellbl# = 0
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        // don't think we want to do this
720eA        //uilcns = $uitolcns;
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;

720eA      // Do not remove just update sellbl field

720eA     GetCurrStamp();
720eA      Exec Sql
720eA      UPDATE uciinfoexa as a
730gM      SET uialcns   = ' ',
730gA          uiapartlts = :nodate
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA     exec sql update uciinfo set
720eA              uichgts = :currStampSys,
720eA              uichguc = :currStampUC,
720eA              uichgpgm = :$uichgpgm,
720eA              uichgemp = :$uichgemp,
720eA              uichgusr = :$uichgusr,
720eA              uichgjob = :$uichgjob,
720eA              uichgnbr = :$uichgnbr,
730cD              //uisellbl# = :$uilbl#,
720eA              uilcns = ' '
720eA               where uiwhse = :$uiwhse
720eA                 and uiuci = :$uiuci;
720eA
720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'ADJRMVUCI';
720eA        $pmessage = 'Error: UCI was not removed.';
720eA      endif;
720eA
720eA    enddo;
720eA /end-free
720eA
720eAp RmvUCIAdjust    e

650cA*----------------------------------------------------------------
650cA*  RtnWhlOrd    Mark UCI as Returned for the incoming label-whole order
650cA*----------------------------------------------------------------

650cAp RtnWhlOrd       b
     d RtnWhlOrd       pi

     *  Local Variables
     d zone            s              6
      /free

720eA   SaveRtnTrn# = $uirtntrn#;
        GetCurrStamp();

        exec sql update uciinfo set
                   uirtntrn# = :$uirtntrn#,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                    where uiwhse = :$uiwhse
                      and uisellbl# = :$uisellbl#
                      and uisellbl# > 0
                      and uirtntrn# = 0;

        if sqlstt <> sqlSuccess;
          error = *on;
          $preturn = 'RTNERR2';
          $pmessage = 'Error Updating return info '
                    + '('
                    + %trim(%editc(uiwhse:'Z'))
                    + '/'
                    + %trim(uiuci)
                    + ')'
                    + '-' + 'UCIINFO';
        endif;

        // Write out new active UCI keeping history on origianl UCI

        SqlStmt = 'select * '
                + 'from uciinfo '
                + 'where uiwhse = ' + %char($uiwhse) + ' '
                +   'and uisellbl# = ' + %char($uisellbl#) + ' '
                +   'and uirtntrn# = ' + %char($uirtntrn#) + ' ' ;

        exec sql prepare updrtnstmt from :SqlStmt;
        exec sql declare updrtncsr cursor for updrtnstmt;
        exec sql open updrtncsr;

        sqlstt = sqlSuccess;
        dou sqlstt = sqlNoMoreData;
        exec sql fetch next from updrtncsr
                 into :uirec;

        if sqlstt <> sqlSuccess;
          error = *on;
          $preturn = 'RTNERR1';
          $pmessage = 'Error Finding Return UCI '
                    + '('
                    + %trim(%editc(uiwhse:'Z'))
                    + '/'
                    + %trim(uiuci)
                    + ')'
                    + '-' + 'UCIINFO';
        else;
          // Save the *rt sent in
          SaveRtnLcns = $uilcns;
          // move the fetched data to the ds fields
          FillDs();

720eA     kywhse = $uiWhse;
720eA     kyitem = $uiItem;
720eA     getItem();
720eA     WrtUCIlog();
          // init the selection/return fields
          $uilcns = SaveRtnLcns;
          $uiseltrn# = 0;
          $uisellbl# = 0;
          $uiselord = 0;
          $uiselseq = 0;
          $uiselcseq = 0;
          $uiseltrax = ' ';
          $uirtntrn# = 0;
          $uicrtby = '2';
          $uiaddpgm = $uichgpgm;
          // need to add active uci
             VfyAdd();
             if not error;
               Add();
             endif;
        endif;
        enddo;

        exec sql close updrtncsr;


      /end-free
650cAp RtnWhlOrd       e

650oA*----------------------------------------------------------------
650oA*  RunnerDone   Remove temp transaction stored in return trn#
650oA*----------------------------------------------------------------

650oAp RunnerDone      b
650oAd RunnerDone      pi

650oA /free

650oA    // Need to remove selection information.


650oA   GetCurrStamp();

650oA   exec sql update uciinfo set
650oA              uirtntrn# = 0,
650oA              uichgts = :currStampSys,
650oA              uichguc = :currStampUC,
650oA              uichgpgm = :$uichgpgm,
650oA              uichgemp = :$uichgemp,
650oA              uichgusr = :$uichgusr,
650oA              uichgjob = :$uichgjob,
650oA              uichgnbr = :$uichgnbr
650oA            where uiwhse = :$uiwhse
650oA             and uisellbl# = :$uisellbl#
650oA             and uirtntrn# = :$uirtntrn#
650oA             and uiseltrn# = :$uiseltrn#;

650oA   if sqlstt = sqlSuccess;
650oA     recUpdated = *on;
650oA   endif;

650oA /end-free
650oAp RunnerDone      e

650eA*----------------------------------------------------------------
650eA*  SelCWSeqUpd    Updated existing UCI with catch weight seq#
650eA*----------------------------------------------------------------
650eA
650eAp SelCWSeqUpd     b
     d SelCWSeqUpd     pi

      /free
          recUpdated = *off;

        GetCurrStamp();
720eA   // write the log record before updating
720eA   exec sql select * into :uirec
720eA        from UCIINFO
720eA        where uiwhse = :$uiwhse
720eA          and uiuci = :$uiuci
720eA          and uiseltrn# = :$uiseltrn#
720eA          and uisellbl# = :$uisellbl#
720eA          and uiselord = :$uiselord
720eA          and uiselseq = :$uiselseq
720eA          and uiselcseq = 0;
720eA   if sqlstt = sqlSuccess;
720eA     WrtUCIlog();
720eA   endif;


        exec sql update uciinfo set
                   uiselcseq = :$uiselcseq,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                     where uiwhse = :$uiwhse
                      and uiuci = :$uiuci
                      and uiseltrn# = :$uiseltrn#
                      and uisellbl# = :$uisellbl#
                      and uiselord = :$uiselord
                      and uiselseq = :$uiselseq
                      and uiselcseq = 0;

        if sqlstt = sqlSuccess;
          recUpdated = *on;
        endif;

      /end-free
650eAp SelCWSeqUpd     e

640aA*----------------------------------------------------------------
640aA*  SelectUCI    Mark UCI as Selected
640aA*----------------------------------------------------------------
640aA
640aAp SelectUCI       b
     d SelectUCI       pi

     *  Local Variables
     d zone            s              6
      /free

         // First try to update unselected record for UCI.

         SelectUCIUpd();
         if recUpdated;
650fA      if $bcai99sent and not $bcpntlbsent and not $bcpntkgsent;
650fA        fillds();
650fA      endif;
           return;
         endif;

650oA    if $psubcmd = '*SELRUN';
650oA    $uiCrtBy = '8';
650oA    else;
650dA    $uiCrtBy = '3';
650oA    endif;
650dA    if $bcPNtLbSent;
650dA      $uiwgtlbs = $bcPNtLb;
650dA    endif;
650dA    if $bcPNtKgSent;
650dA      $uiwgtKgs = $bcPNtKg;
650dA    endif;
650dA    if $bcSer#Sent;
650dA      $uiserial = $bcSer#;
650dA    endif;

         // If non-unique selected record found,
         //   Add using selected license info.

         if not uniqueUCI and selectedFound;
           $uilcns = savlcns;
           $uiseq  = savseq;
           Add();
           return;
         endif;

         // Otherwise, get license to apply to UCI rec.

         GetLicInfo();

         // Then, add record ($uilcns set in GetLicInfo).

         Add();

      /end-free
     p SelectUCI       e

720aA*----------------------------------------------------------------
720bA*  SelectUPC    Mark UPC as Selected
720bA*----------------------------------------------------------------
720bA
720bAp SelectUPC       b
720bAd SelectUPC       pi

720bA*  Local Variables
720bAd zone            s              6
720bA /free

720bA    $uiCrtBy = 'C';
720bA    GetSpclUCILcns();
720bA    eval $uilcns = $uiucilcns;

720bA    Add();

720bA /end-free
720bAp SelectUPC       e

650iA*----------------------------------------------------------------
650iA*  SelectPTI    Mark PTI as Selected
650iA*----------------------------------------------------------------
650iA
650iAp SelectPTI       b
     d SelectPTI       pi

     *  Local Variables
     d zone            s              6
      /free

         // First try to update unselected record for PTI.

         SelectUCIUpd();
         if recUpdated;
             fillds();
           return;
         endif;

         // If non-unique selected record found,
         //   Add using selected license info.

         if not uniqueUCI and selectedFound;
           $uilcns = savlcns;
           $uiseq  = savseq;
           // we will add to uciinfo if we find this PTI for this item.
           if uiitem = $uiitem and
              uiuci = $uiuci;
             $uiCrtBy = '3';
             Add();
             return;
           else;
             // if no match can't accept
             error = *on;
             $preturn  = 'INVLDPTI';
             $pmessage = 'Error: NO PTI Found';
             return;
           endif;
         else;
           // if no match can't accept
           error = *on;
           $preturn  = 'INVLDPTI';
           $pmessage = 'Error: NO PTI Found';
           return;
         endif;

      /end-free
650iAp SelectPTI       e

650hA*----------------------------------------------------------------
650hA*  Sel4BlkUCI   Mark UCI as Selected - Bulk
650hA*----------------------------------------------------------------
650hA
650hAp Sel4BlkUCI      b
     d Sel4BlkUCI      pi

     *  Local Variables
     d zone            s              6
      /free

         // First try to update unselected record for UCI.
         Sel4BlkUCIUpd();
         if recUpdated;
           if $bcai99sent and not $bcpntlbsent and not $bcpntkgsent;
             fillds();
           endif;
           return;
         endif;

         $uiCrtBy = '3';
         if $bcPNtLbSent;
           $uiwgtlbs = $bcPNtLb;
         endif;
         if $bcPNtKgSent;
           $uiwgtKgs = $bcPNtKg;
         endif;
         if $bcSer#Sent;
           $uiserial = $bcSer#;
         endif;

         // If non-unique selected record found,
         //   Add using selected license info.

         if not uniqueUCI and selectedFound;
           $uilcns = savlcns;
           $uiseq  = savseq;
           Add();
           return;
         endif;

         // Otherwise, get license to apply to UCI rec.

         GetLicInfo();

         // Then, add record ($uilcns set in GetLicInfo).

         Add();

      /end-free
650hAp Sel4BlkUCI      e

640aA*----------------------------------------------------------------
640aA*  SelectUCIUpd   Updated existing UCI/PTI with select info
640aA*----------------------------------------------------------------
640aA
640aAp SelectUCIUpd    b
     d SelectUCIUpd    pi

      /free
          recUpdated = *off;

          SqlStmt = 'select * '
                  + 'from uciinfo '
                  + 'where uiwhse = ' + %char($uiwhse) + ' '
650dD             //+   'and uiuci = ' + %trimr($uiuci) + ' '
650dM             +   'and uiuci = ' + sq + %trimr($uiuci) + sq + ' '
                  +   'and uiseltrn# = 0 '
650dD             //+ 'fetch first row only '
                  + 'for update of '
                  +   'uiseltrn#,uisellbl#,uiselord,uiselseq,'
650oD             //+   'uiselcseq,uiseltrax,'
650oM             +   'uiselcseq,uiseltrax,uirtntrn#,'
                  +   'uichgts,uichguc,uichgpgm,uichgemp,'
                  +   'uichgusr,uichgjob,uichgnbr';

        exec sql prepare updselstmt from :SqlStmt;
        sqlstt = sqlstt;
        exec sql declare updselcsr cursor for updselstmt;
        sqlstt = sqlstt;
        exec sql open updselcsr;
        sqlstt = sqlstt;

        exec sql fetch next from updselcsr
                 into :uirec;

        if sqlstt <> sqlSuccess;
          return;
        endif;

        GetCurrStamp();
720eA   WrtUCIlog();

        exec sql update uciinfo set
                   uiseltrn# = :$uiseltrn#,
                   uisellbl# = :$uisellbl#,
                   uiselord  = :$uiselord,
                   uiselseq  = :$uiselseq,
                   uiselcseq = :$uiselcseq,
                   uiseltrax = :$uiseltrax,
650oA              uirtntrn# = :$uirtntrn#,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                 where current of updselcsr;

        if sqlstt = sqlSuccess;
          recUpdated = *on;
        endif;

        exec sql close updselcsr;

      /end-free
     p SelectUCIUpd    e

650hA*----------------------------------------------------------------
650hA*  Sel4BlkUCIUpd   Updated existing UCI with select info - BULK
650hA*----------------------------------------------------------------
650hA
650hAp Sel4BlkUCIUpd   b
     d Sel4BlkUCIUpd   pi

      /free
          recUpdated = *off;

          SqlStmt = 'select * '
                  + 'from uciinfo '
                  + 'where uiwhse = ' + %char($uiwhse) + ' '
                  +   'and uiuci = ' + sq + %trimr($uiuci) + sq + ' '
                  +   'and uilcns = ' + sq + %trimr($uilcns) + sq + ' '
                  +   'and uiseltrn# = 0 '
                  + 'for update of '
                  +   'uiseltrn#,uisellbl#,uiselord,uiselseq,'
                  +   'uiselcseq,uiseltrax,'
                  +   'uichgts,uichguc,uichgpgm,uichgemp,'
                  +   'uichgusr,uichgjob,uichgnbr';

        exec sql prepare updselstmt from :SqlStmt;
        sqlstt = sqlstt;
        //exec sql declare updselcsr cursor for updselstmt;
        sqlstt = sqlstt;
        exec sql open updselcsr;
        sqlstt = sqlstt;

        exec sql fetch next from updselcsr
                 into :uirec;

        if sqlstt <> sqlSuccess;
          return;
        endif;

        GetCurrStamp();

        exec sql update uciinfo set
                   uiseltrn# = :$uiseltrn#,
                   uisellbl# = :$uisellbl#,
                   uiselord  = :$uiselord,
                   uiselseq  = :$uiselseq,
                   uiselcseq = :$uiselcseq,
                   uiseltrax = :$uiseltrax,
                   uichgts = :currStampSys,
                   uichguc = :currStampUC,
                   uichgpgm = :$uichgpgm,
                   uichgemp = :$uichgemp,
                   uichgusr = :$uichgusr,
                   uichgjob = :$uichgjob,
                   uichgnbr = :$uichgnbr
                 where current of updselcsr;

        if sqlstt = sqlSuccess;
          recUpdated = *on;
        endif;

        exec sql close updselcsr;

      /end-free
650hAp Sel4BlkUCIUpd   e

650oA*----------------------------------------------------------------
650oA*  UndoRunner   Remove selection info from Runner being cancelled
650oA*----------------------------------------------------------------

650oAp UndoRunner      b
650oAd UndoRunner      pi

650oA /free

720eA   // in order to write logs for each uci, I will need to get
720eA   // each uci before undoing runner data.
720eA   dow forever = forever;
720eA     exec sql select * into :uirec
720eA          from UCIINFO
720eA            where uiwhse = :$uiwhse
720eA             and uiselcseq = :$uiselcseq
720eA             and uisellbl# = :$uisellbl#
720eA             and uirtntrn# = :$uirtntrn#
720eA             and uiseltrn# = :$uiseltrn#
720eA          fetch first row only;

720eA     if sqlstt <> sqlSuccess;
720eA       return;
720eA     else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA       // setup some data that isn't passed in
720eA       $uiuci  = uiuci;
720eA       uilcns = uilcns;
720eA       $uiaction = 'CANCEL';
720eA       // Get slot information
720eA       kywhse = uiWhse;
720eA       kyitem = uiasItem;
720eA       getItem();

720eA       // Get item information
720eA       kywhse = uiWhse;
720eA       kyitem = uiItem;
720eA       getItem();
720eA       WrtUCIlog();
720eA     endif;

650oA    // Need to remove selection information.


650oA   GetCurrStamp();

650oA   exec sql update uciinfo set
650oA              uiseltrn# = 0,
650oA              uisellbl# = 0,
650oA              uiselord  = 0,
650oA              uiselseq  = 0,
650oA              uiselcseq = 0,
650oA              uiseltrax = 0,
650oA              uirtntrn# = 0,
650oA              uichgts = :currStampSys,
650oA              uichguc = :currStampUC,
650oA              uichgpgm = :$uichgpgm,
650oA              uichgemp = :$uichgemp,
650oA              uichgusr = :$uichgusr,
650oA              uichgjob = :$uichgjob,
650oA              uichgnbr = :$uichgnbr
650oA            where uiwhse = :$uiwhse
720eA             and uiuci = :$uiuci
650oA             and uiselcseq = :$uiselcseq
650oA             and uisellbl# = :$uisellbl#
650oA             and uirtntrn# = :$uirtntrn#
650oA             and uiseltrn# = :$uiseltrn#;

650oA   if sqlstt = sqlSuccess;
650oA     recUpdated = *on;
650oA   endif;

720eA  enddo;
650oA /end-free
650oAp UndoRunner      e

730fA*----------------------------------------------------------------
730fA*  UndoSelect   Remove selection info for UCI being unselected
730fA*----------------------------------------------------------------

730fAp UndoSelect      b
730fAd UndoSelect      pi

730fA /free

730fA   // in order to write logs for each uci, I will need to get
730fA   // each uci before unselecting the uci data.
730fA   dow forever = forever;
730fA     exec sql select * into :uirec
730fA          from UCIINFO
730fA            where uiwhse = :$uiwhse
730fA             and uiuci     = :$uiuci
730fA             and uisellbl# = :$uisellbl#
730fA             and uiseltrn# = :$uiseltrn#
730fA          fetch first row only;

730fA     if sqlstt <> sqlSuccess;
730fA       return;
730fA     else;
730fA        exec sql select * into :uiarec
730fA           from UCIINFOEXA
730fA           Where uiaaddts = :uiaddts
730fA             and uiaucilcns = :uiucilcns
730fA             and uialcns = :uilcns
730fA           fetch first row only;
730fA       // setup some data that isn't passed in
730fA       $uiuci  = uiuci;
730fA       uilcns = uilcns;
730fA       $uiaction = 'UNPICK';
730fA       // Get slot information
730fA       kywhse = uiWhse;
730fA       kyitem = uiasItem;
730fA       getItem();

730fA       // Get item information
730fA       kywhse = uiWhse;
730fA       kyitem = uiItem;
730fA       getItem();
730fA       WrtUCIlog();
730fA     endif;

730fA    // Need to remove selection information.


730fA   GetCurrStamp();

730fA   exec sql update uciinfo set
730fA              uiseltrn# = 0,
730fA              uisellbl# = 0,
730fA              uiselord  = 0,
730fA              uiselseq  = 0,
730fA              uiselcseq = 0,
730fA              uiseltrax = 0,
730fA              uirtntrn# = 0,
730fA              uichgts = :currStampSys,
730fA              uichguc = :currStampUC,
730fA              uichgpgm = :$uichgpgm,
730fA              uichgemp = :$uichgemp,
730fA              uichgusr = :$uichgusr,
730fA              uichgjob = :$uichgjob,
730fA              uichgnbr = :$uichgnbr
730fA            where uiwhse = :$uiwhse
730fA             and uiuci = :$uiuci
730fA             and uisellbl# = :$uisellbl#
730fA             and uiseltrn# = :$uiseltrn#;

730fA   if sqlstt = sqlSuccess;
730fA     recUpdated = *on;
730fA   endif;

730fA  enddo;
730fA /end-free
730fAp UndoSelect      e

650qA*----------------------------------------------------------------
650qA*  UpdateCW     Update the CW entry for the CW122/PO232
650qA*----------------------------------------------------------------

650qAp UpdateCW        b
650qAd UpdateCW        pi

650qA /free

650qA    // update the CW entry for the temporary license

650qA    exec sql update uciinfo set
650qA              uiwgtlbs = :$uiwgtlbs,
650qA              uichgts = :currStampSys,
650qA              uichguc = :currStampUC
650qA             where uilcns = :$uilcns
650qA               and uiwhse = :$uiwhse
700bD               //and uiseq  = :$uiseq;
700bM               and uiselcseq = :$uiselcseq;

650qA /end-free
650qAp UpdateCW        e

     *----------------------------------------------------------------
     *  VfyAdd       Verify information for add
     *----------------------------------------------------------------

     p VfyAdd          b
     d VfyAdd          pi

      /free

         // Validate Fields

         if VfyFldWhse() < 0;
           return;
         endif;

         if VfyFldUCI() < 0;
           return;
         endif;

720eA    kywhse = $uiWhse;
720eA    kyitem = $uiItem;
720eA    getItem();
720eA    if not itemFound;
720eA      error = *on;
720eA      $preturn  = 'INVLDITEM';
720eA      $pmessage = 'Error: Invalid Item';
720eA      return;
720eA    endif;
650gA    // If item is not defined as unique UCI, then get out.

650gA    if $ifucicde <> '2'        // Unique GS1
650gA      and $ifucicde <> '4';    // Unique Internal AI99 GS1
650gA        return;
650gA    endif;
650nA    // If item is using uci receiving but not using uci select    ion
650nA    // Returns can not check for unique uci. Get out

650nA    if $ifrcvmth = '2'        // uci receiving
650nA        and $ifsltmth <> '2'     // uci selection
650nA        and $pprogram = ('RN120')
650nA        or  $ifrcvmth = '2'        // uci receiving
650nA        and $ifsltmth <> '2'     // uci selection
650nA        and $pprogram = ('RN250');
650nA      return;
650nA    endif;
         // Error if UCI already exists

         GetUCI();
         if uciFound;
           error = *on;
           $preturn  = 'UCIEXISTS';
           $pmessage = 'Error: UCI already exists';
           return;
         endif;

      /end-free

     p VfyAdd          e

720eA*----------------------------------------------------------------
720eA*  VfyCurMove   Verify to see if uci is currently being moved
720eA*----------------------------------------------------------------

720eAp VfyCurMove      b
720eAd VfyCurMove      pi

720eA /free

720eA    // Error if partial time stamp is populated.
720eA    exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns, uiwhse,
720eA                    uiuci, uiapartlts
720eA             into  :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,:uiwhse,
720eA                   :uiuci,:uiapartlts
720eA             from UCIINFO
720eA              inner join uciinfoexa
720ea              on uiaddts = uiaaddts
720ea              and uiucilcns = uiaucilcns
720ea              and uilcns = uialcns
720eA             where uiwhse = :$uiwhse
720eA               and uiuci = :$uiuci
720eA               and uiapartlts = :$uiapartlts;
720eA               //and uilcns = :$uilcns;

720eA    if sqlstt = sqlSuccess;
720eA      uciFound = *on;
720eA    else;
720eA      uciFound = *off;
720eA    endif;

720eA    if uciFound;
720eA      error = *on;
720eA      $preturn = '*CURMOVE  ';
720eA      $pmessage = 'UCI has already been scanned for movement';
720eA    endif;

720eA /end-free
720eAp VfyCurMove      e

720eA*----------------------------------------------------------------
720eA*  VfyMoveGS1    Extra Movement verification for GS1 code
720eA*----------------------------------------------------------------

720eAp VfyMoveGS1      b
720eAd VfyMoveGS1      pi             1  0
720eAd  upcCode                      20    const

720eA*  Local variables
720eAd  upcCodeR       s             20
720eA
720eA /free
720eA
720eA    // Right justify UPC code
720eA
720eA    evalr upcCodeR = %trimr(upcCode);
720eA
720eA    // Verify sent item same as UPC item
720eA
720eA    exec sql select * into :uprec
720eA             from upc2
720eA             where upwhse = :$uiwhse
720eA               //and upitem = :uiitem
720eA               and upitem = :sentItem
720eA               and upupc = :upcCodeR
720eA             fetch first row only;
720eA
720eA    if sqlstt <> sqlSuccess;
720eA      // need to check for chgitem
720eA        exec sql select * into :icrec
720eA                 from itemchg
720eA                 where icwhse = :$uiwhse
720eA                   //and icfitm = :uiitem
720eA                   and icfitm = :sentItem
720eA                   and ictitm = :baseitem
720eA                 fetch first row only;
720eA        if sqlstt <> sqlSuccess;
720eA          error = *on;
720eA          $preturn  = 'ITMMISMTCH';
720eA          $pmessage = 'UPC item does not match item';
720eA          return -1;
720eA        endif;
720eA      ucifound = *off;
720eA    endif;
720eA
720eA    return 0;
720eA /end-free
720eA
720eAp VfyMoveGS1      e

650jA*----------------------------------------------------------------
650jA*  VfyPTIItem    Verify pti is for the item being selected
650jA*----------------------------------------------------------------

650jAp VfyPTIItem      b
650jAd VfyPTIItem      pi

650jA /free

650jA    exec sql select * into :uirec
650jA             from UCIINFO
650jA             where uiwhse = :$uiwhse
650jA               and uiuci = :$uiuci
650jA             fetch first row only;

650jA    if sqlstt = sqlSuccess;
650jA      PTIFound = *on;
650jA    else;
650jA      PTIFound = *off;
650jA    endif;

650jA /end-free
650jAp VfyPTIItem      e

     *----------------------------------------------------------------
     *  VfySelect     Verify information for SELECTUCI
     *----------------------------------------------------------------

     p VfySelect       b
     d VfySelect       pi

      /free

         // Validate Fields

         if VfyFldWhse() < 0;
           return;
         endif;

         if VfyFldUCI() < 0;
           return;
         endif;

740dM    // moved this code up - fields were not being populated before
740dM    // the edits were happening.
740dM    // Get item information.
740dM
740dM    kywhse = $uiWhse;
740dM    kyitem = $uiItem;
740dM    getItem();
740dM    if not itemFound;
740dM      error = *on;
740dM      $preturn  = 'INVLDITEM';
740dM      $pmessage = 'Error: Invalid Item';
740dM      return;
740dM    endif;

740dM    // for scanning trax# force to uniqueUCI
740dM    if %subst($uiuci:1:6) = '99TRAX';
740dM      uniqueUCI = *on;
740dM    endif;

740dM    // Get base item number
740dM
740dM    if $ittype = ' ' or $ittype = 'B';
740dM      baseItem = $ititem;
740dM    else;
740dM      baseItem = $itmitem;
740dM    endif;
         // Decipher UCI

740dA    eval $cbven = $itven#;
700mA    clear $barcode;
700mA    clear $barcode2;
         cvtbar('*ALL': $uiUCI:
                $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740bM           $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740bA           $cbkilolbsSent: $cbitem);
740bD          //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
700jD           //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
         $barcode = $cvtdata;
         $barcode2 = $cvtdata2;

700nM    // moved this code up - fields were not being populated before
700nM    // the edits were happening.
700nM    // Get item information.
700nM
740dD    //kywhse = $uiWhse;
740dD    //kyitem = $uiItem;
740dD    //getItem();
740dD    //if not itemFound;
740dD      //error = *on;
740dD      //$preturn  = 'INVLDITEM';
740dD      //$pmessage = 'Error: Invalid Item';
740dD      //return;
740dD    //endif;

740dD    // for scanning trax# force to uniqueUCI
740dD    //if %subst($uiuci:1:6) = '99TRAX';
740dD      //uniqueUCI = *on;
740dD    //endif;

740dD    // Get base item number
740dD
740dD    //if $ittype = ' ' or $ittype = 'B';
740dD      //baseItem = $ititem;
740dD    //else;
700nM      //baseItem = $itmitem;
740dD    //endif;

650pA    // if we extract a date we need to validate it before
650pA    // it goes to cvtdte - to eliminate putmsg which has
650pA    // no display file to send the message
650pA    invaliddate = *off;
650pA    if $bcProdDSent;
650pA      test(de) *ymd $bcProdD;
650pA      if %error;
650pA        invaliddate = *on;
650pA      endif;
650pA    endif;
650pA    if $bcPackDSent;
650pA      test(de) *ymd $bcPackD;
650pA      if %error;
650pA        invaliddate = *on;
650pA      endif;
650pA    endif;
650pA    if $bcExpDSent;
650pA      test(de) *ymd $bcExpD;
650pA      if %error;
650pA        invaliddate = *on;
650pA      endif;
650pA    endif;
700mA    // do we have a valid gtin/upc?
700mA    if not $bcSsccSent and not $bcGtinSent and not $bcAI99Sent;
700mA      error = *on;
700mA      $preturn  = 'INVLDUCI';
700mA      $pmessage = $cberm;
700mA      return;
700ma    endif;

700mA    // is there an invalid date in the barcode
700mA    if $bcProdDSent and invaliddate
700mA      or $bcPackDSent and invaliddate
700mA      or $bcExpDSent  and invaliddate;
700mA      error = *on;
700mA      $preturn  = 'INVLDUCI';
700mA      $pmessage = 'Error: UCI Invalid Date';
700mA      return;
700mA    endif;

700mA    // Is this a catch weight item - barcode needs weight
700mA    if $itcwgt = 'Y' and not $bcPNtLbSent and not $bcPNtKgSent
700mA       and not $bcAI99Sent;
700mA      error = *on;
700mA      $preturn  = 'INVLDUCI';
700mA      $pmessage = 'Error: UCI Missing weight';
700mA      return;
700mA    endif;

700mA    // the below edits were broken apart to issue better messages
700mA    // this edit has been deleted.
650pD    //if not $bcSsccSent and not $bcGtinSent and not $bcAI99Sent;
700mD    //if not $bcSsccSent and not $bcGtinSent and not $bcAI99Sent
700mD      //or $itcwgt = 'Y' and not $bcPNtLbSent and not $bcPNtKgSent
700mD        // and not $bcAI99Sent
700mD      //or $bcProdDSent and invaliddate
700mD      //or $bcPackDSent and invaliddate
700mD      //or $bcExpDSent  and invaliddate;
700mD      //error = *on;
700mD      //$preturn  = 'INVLDUCI';
700mD      //$pmessage = 'Error: Invalid UCI';
700mD      //return;
700mD    //endif;

700nM    // moved getitem above
         // See if UCI already selected

         clear savlcns;
         clear savseq;

         GetSelected();

         if selectedFound;

650lA      // get label to determine if breakdown uom is being selected
650lA      // breakdown uom - assumes non-unique.
710cA      // This assumption no longer applies - no need to GetLabel
710cD      //GetLabel();

           // Error if a unique UCI already selected

           if uniqueUCI;
             error = *on;
             $preturn  = 'SELECTED';
700kA        // for scanning trax# send back a different message.
700kA        if %subst($uiuci:1:6) = '99TRAX';
700kA          $pmessage = 'Error: Label previously selected';
700kA        else;
               $pmessage = 'Error: UCI previously selected';
700kA        endif;
             return;
           endif;

           // Otherwise, save license info for later use.

650dD      //savlcns = ucilcns;
650dD      //savseq  = uciseq;
650dM      savlcns = uilcns;
650dM      savseq  = uiseq;

         endif;

         // Do more checking based on type of UCI code

         select;

700jA      when %subst($uiuci:1:6) = '99TRAX';

           when $bcSsccSent;
             if VfySelectGS1($bcSscc) < 1;
               return;
             endif;

           when $bcGtinSent;
             if VfySelectGS1($bcGtin) < 1;
               return;
             endif;

           other;
650fA        if VfySelectAI99() < 1;
650fA          return;
650fA        endif;

         endsl;

      /end-free

     p VfySelect       e

     *----------------------------------------------------------------
     *  VfySelectAI99   Extra SELECT verification for AI99 code
     *----------------------------------------------------------------

     p VfySelectAI99   b
     d VfySelectAI99   pi             1  0

      /free

650fA    // GS1-99 label must be assigned to an item in order to use
650fA    // without being assigned, we don't have weight and lot data
650fA    GetUCI();
650fA    if uciFound;
710aA      if $uiitem <> uiitem;
710aA        // need to chech for changed item
710aA        exec sql select * into :icrec
710aA                 from itemchg
710aA                 where icwhse = :$uiwhse
710aA                   and icfitm = :uiitem
710aA                   and ictitm = :baseitem
710aA                 fetch first row only;
710aA        if sqlstt <> sqlSuccess;
710aA          error = *on;
710aA          $preturn  = 'GS199ITEM';
710aA          $pmessage = 'GS1-99 Wrong Item';
710aA          return -1;
710aA        endif;
710aA      endif;
650fA    else;
650fA      error = *on;
650fD      //$preturn  = 'PTINOTIMPL';
650fD      //$pmessage = 'PTI not implemented';
650fA      $preturn  = 'GS199NOTAS';
650fA      $pmessage = 'GS1-99 not assigned';
650fA      return -1;
650fA    endif;

         return 0;
      /end-free

     p VfySelectAI99   e

     *----------------------------------------------------------------
     *  VfySelectGS1    Extra SELECT verification for GS1 code
     *----------------------------------------------------------------

     p VfySelectGS1    b
     d VfySelectGS1    pi             1  0
     d  upcCode                      20    const

     *  Local variables
     d  upcCodeR       s             20

      /free

         // Right justify UPC code

         evalr upcCodeR = %trimr(upcCode);

         // Verify sent item same as UPC item

         exec sql select * into :uprec
                  from upc2
                  where upwhse = :$uiwhse
                    and upitem = :baseItem
                    and upupc = :upcCodeR
                  fetch first row only;

         if sqlstt <> sqlSuccess;
700aA      // need to check for chgitem
700aA      getuci();
700aA      if ucifound;
700aA        exec sql select * into :icrec
700aA                 from itemchg
700aA                 where icwhse = :$uiwhse
700aA                   and icfitm = :uiitem
700aA                   and ictitm = :baseitem
700aA                 fetch first row only;
700aA        if sqlstt <> sqlSuccess;
               error = *on;
               $preturn  = 'ITMMISMTCH';
               $pmessage = 'UPC item does not match label item';
               return -1;
700aA        endif;
700dA      else;
700dA        error = *on;
700dA        $preturn  = 'ITMMISMTCH';
700dA        $pmessage = 'UPC item does not match label item';
700dA        return -1;
700aA      endif;
700aA      ucifound = *off;
         endif;

         return 0;
      /end-free

     p VfySelectGS1    e

650iA*----------------------------------------------------------------
650iA*  VfySelectPTI  Verify information for SELECTPTI
650iA*----------------------------------------------------------------

650iAp VfySelectPTI    b
650iAd VfySelectPTI    pi

      /free

         // Validate Fields

         if VfyFldWhse() < 0;
           return;
         endif;

         if VfyFldUCI() < 0;
           return;
         endif;

         // Get item information.

         kywhse = $uiWhse;
         kyitem = $uiItem;
         getItem();
         if not itemFound;
           error = *on;
           $preturn  = 'INVLDITEM';
           $pmessage = 'Error: Invalid Item';
           return;
         endif;

         // Get base item number

         if $ittype = ' ' or $ittype = 'B';
           baseItem = $ititem;
         else;
           baseItem = $itmitem;
         endif;

         // See if PTI already selected

         clear savlcns;
         clear savseq;

650jA    VfyPTIItem();
650jA    if PTIFound;
650jA      if $uiitem <> uiitem;
650jA        error = *on;
650jA        $preturn  = 'INVPTIITEM';
650jA        $pmessage = 'Error: Invalid PTI Item';
650jA        return;

650jA      endif;
650jA    endif;

         GetSelected();

         if selectedFound;

           // Error if a unique PTI already selected

           if uniqueUCI;
             error = *on;
             $preturn  = 'SELECTED';
             $pmessage = 'Error: PTI previously selected';
             return;
           endif;

           // Otherwise, save license info for later use.

           //savlcns = ucilcns;
           //savseq  = uciseq;
           savlcns = uilcns;
           savseq  = uiseq;

         endif;

      /end-free

650iAp VfySelectPTI    e

720bA*----------------------------------------------------------------
720bA*  VfySelectUPC  Verify information for SELECTUPC
720bA*----------------------------------------------------------------

720bAp VfySelectUPC    b
720bAd VfySelectUPC    pi

720bA /free

720bA    // Validate Fields

720bA    if VfyFldWhse() < 0;
720bA      return;
720bA    endif;

720bA    if VfyFldUCI() < 0;
720bA      return;
720bA    endif;

720bA    // Get item information.

720bA    kywhse = $uiWhse;
720bA    kyitem = $uiItem;
720bA    getItem();
720bA    if not itemFound;
720bA      error = *on;
720bA      $preturn  = 'INVLDITEM';
720bA      $pmessage = 'Error: Invalid Item';
720bA      return;
720bA    endif;

720bA    uniqueUCI = *off;

720bA    // Get base item number

720bA    if $ittype = ' ' or $ittype = 'B';
720bA      baseItem = $ititem;
720bA    else;
720bA      baseItem = $itmitem;
720bA    endif;

720bA /end-free

720bAp VfySelectUPC    e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyFldUCI     Verify UCI sent
     *----------------------------------------------------------------

     p VfyFldUCI       b
     d VfyFldUCI       pi             1  0

      /free

         if $uiUCI = ' ';
           error = *on;
           $preturn  = 'UCIBLANK';
           $pmessage = 'Error: UCI cannot be blank';
           return -1;
         endif;

         return 0;
      /end-free

     p VfyFldUCI       e

     *----------------------------------------------------------------
     *  vfyFldWhse    Verify warehouse
     *----------------------------------------------------------------

     p VfyFldWhse      b
     d VfyFldWhse      pi             1  0

      /free

         vfyWhseCalled = *on;
650pD    //vfyWhse('*VERIFY': '*NONE': $uiWhse: $vdesc:
650pM    callp(e) vfyWhse('*VERIFY': '*NONE': $uiWhse: $vdesc:
                 $vreturn: $vmessage: $vmsgk);

         select;

           when %error;
             error = *on;
             $preturn  = 'CALLERROR';
             $pmessage = 'Error occured on call to VFYWHSE/'
                       + %trim($vcommand) + ' from ' + #pgm;
             return -1;

           when $vreturn <> '*OK';
             error = *on;
             $preturn = $vreturn;
             $pmessage = $vmessage;
             return -1;

         endsl;

         return 0;
      /end-free

     p VfyFldWhse      e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------
     p Clr$LicInfo     b
     d Clr$LicInfo     pi

      /free

         savever# = $lnver#;
         clear $licinfo;
         clear $licinfo2;
         $lnver# = savever#;

         $lnuser = #curruser;
650dD    //$lnemp# = $emp#;
650dM    $lnemp# = $uiaddemp;
         $lnpgm  = #pgm;
         $lnjob  = #job;
         $lnjobnbr = #jobnbr;

      /end-free

     p Clr$LicInfo     e

720eA*----------------------------------------------------------------
720eA*  updLicByUCI    Update From/To License for UCI record
720eA*                 by UCI
720eA*----------------------------------------------------------------
720eAp UpdLicByUCI     b
720eAd UpdLicByUCI     pi
720eA
720eA /free
720eA
720eA    // Update uci license with license number and
720eA    // update license number with new 'TO' license
720eA    // by UCI
720eA      Exec Sql
720eA      UPDATE uciinfoexa as a
720eA      SET uialcns   = :$uiToLcns
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA    exec sql update uciinfo set uilcns = :$uiToLcns
720eA             where uiuci  = :$uiuci
720eA               and uiwhse = :$uiwhse;
720eA
720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'LICUPDUCI';
720eA        $pmessage = 'Error: License not updated';
720eA      endif;
720eA
720eA /end-free
720eA
720eAp UpdLicByUCI     e
720eA*----------------------------------------------------------------
720eA*  updateLicense  Update From/To License for UCI record
720eA*                 by License
720eA*----------------------------------------------------------------
720eAp UpdateLicense   b
720eAd UpdateLicense   pi
720eA
720eA /free
720eA
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before changing license.
720eA    dow forever = forever;
720eA      exec sql select * into :uirec
720eA           from UCIINFO
720eA           where uilcns = :$uilcns
720eA             and uiwhse = :$uiwhse
720eA           fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        exec sql select * into :uiarec
720eA           from UCIINFOEXA
720eA           Where uiaaddts = :uiaddts
720eA             and uiaucilcns = :uiucilcns
720eA             and uialcns = :uilcns
720eA           fetch first row only;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        uilcns = $uitolcns;
720eA        $uiaction = 'CHGLCNS  ';
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
720eA        WrtUCIlog();
720eA      endif;

720eA      // Update uci license with license number and
720eA      // update license number with new 'TO' license
720eA      Exec Sql
720eA      UPDATE uciinfoexa as a
720eA      SET uialcns   = :$uiToLcns
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA      exec sql update uciinfo set uilcns = :$uiToLcns
720eA               where uilcns = :$uilcns
720eA                 and uiwhse = :$uiwhse
720eA                 and uiuci = :uiuci;
720eA
720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'LICUPDATE';
720eA        $pmessage = 'Error: License not updated';
720eA      endif;
720eA
720eA    enddo;
720eA /end-free
720eA
720eAp UpdateLicense   e
720eA*----------------------------------------------------------------
720eA*  updParLicense  Update From/To License for UCI record
720eA*                 by Time Stamp
720eA*----------------------------------------------------------------
720eAp UpdParLicense   b
720eAd UpdparLicense   pi
720eA
720eA /free
720eA
720eA    // in order to write logs for each uci, I will need to get
720eA    // each uci before updating.
720eA    dow forever = forever;
720eA      exec sql select uiaddts, uiaaddts, uiucilcns, uiaucilcns,
720eA                      uiapartlts, uiwhse, uiasitem, uiitem
730aA                      , uiuci, uilcns
720eA         into        :uiaddts,:uiaaddts,:uiucilcns,:uiaucilcns,
720eA                     :uiapartlts,:uiwhse,:uiasitem,:uiitem
730aA                     ,:uiuci,:uilcns
720eA         from UCIINFO
720eA              inner join uciinfoexa
720ea              on uiaddts = uiaaddts
720ea              and uiucilcns = uiaucilcns
720ea              and uilcns = uialcns
720eA         Where uiapartlts = :$uiapartlts
720eA           and uiwhse = :$uiwhse
720eA         fetch first row only;

720eA      if sqlstt <> sqlSuccess;
720eA        return;
720eA      else;
720eA        // setup some data that isn't passed in
720eA        $uiuci  = uiuci;
720eA        // took this out - retest partials
720eA        //uilcns = $uitolcns;
720eA        // Get slot information
720eA        kywhse = uiWhse;
720eA        kyitem = uiasItem;
720eA        getItem();

720eA        // Get item information
720eA        kywhse = uiWhse;
720eA        kyitem = uiItem;
720eA        getItem();
730aA        // don't load label into log record already have $uitolcns
730aA        savelabel = $uilbl#;
730aA        if $uitolcns <> uilcns;
720eA          WrtUCIlog();
730aA        else;
730aA          $uilbl# = 0;
720eA          WrtUCIlog();
730aA          $uilbl# = savelabel;
730aA        endif;
720eA      endif;

720eA    // update license number with new 'TO' license for Time Stamp
720eA   Exec Sql
720eA      UPDATE uciinfoexa as a
720eA      SET uialcns   = :$uiToLcns
720eA      WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   a.uiapartlts = :$uiapartlts
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
720eA             and b.uiuci = :uiuci ) >0;
720eA      if sqlstt <> sqlSuccess;
720eA      endif;

720eA   Exec Sql
720eA     UPDATE uciinfo as a
720eA     SET uilcns = :$uitolcns, uisellbl# = 0
720eA     WHERE (Select count(*) From uciinfoexa as b
720eA             where a.uiwhse = :$uiwhse
720eA             and b.uiapartlts = :$uiapartlts
720eA             and b.uiaaddts = a.uiaddts
720eA             and b.uiaucilcns = a.uiucilcns
720eA             and b.uialcns = :$uiToLcns
720eA             and a.uiuci = :uiuci ) >0;


720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'LICUPDPAR';
720eA        $pmessage = 'Error: Partial License not updated';
720eA      endif;
720eA
720eA   Exec Sql
720eA     UPDATE uciinfoexa as a
720eA     SET uiapartlts = :nodate
720eA     WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and a.uiapartlts = :$uiapartlts
720eA             and a.uiaaddts = b.uiaddts
720eA             and a.uiaucilcns = b.uiucilcns
720eA             and a.uialcns   = b.uilcns
720eA             and b.uiuci = :uiuci ) >0;

720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'LICUPDPAR';
720eA        $pmessage = 'Error: Partial License not updated exa file';
720eA      endif;
720eA
720eA    enddo;
720eA /end-free
720eA
720eAp UpdParLicense   e
720eA*----------------------------------------------------------------
720eA*  upddatePartial Update scanned UCI with partial movement
720eA*                 timestamp
720eA*----------------------------------------------------------------
720eAp UpdatePartial   b
720eAd UpdatePartial   pi
720eA
720eA /free
720eA
720eA    // Update uci with partial movement timestamp.
720eA
720eA   Exec Sql
720eA     UPDATE uciinfoexa as a
720eA     SET uiapartlts = :$uiapartlts
720eA     WHERE (Select count(*) From uciinfo as b
720eA             where b.uiwhse = :$uiwhse
720eA             and   b.uiaddts = a.uiaaddts
720eA             and   b.uilcns = a.uialcns
720eA             and   b.uiucilcns = a.uiaucilcns
740aD             //and b.uiuci = :uiuci ) >0;
740aM             and b.uiuci = :$uiuci ) >0;

720eA      if sqlstt <> sqlSuccess;
720eA        error = *on;
720eA        $preturn  = 'UPDPARTL';
720eA        $pmessage = 'Error: UCI not updated';
720eA      else;
720eA        WrtUCIlog();
720eA      endif;
720eA
720eA /end-free
720eA
720eAp UpdatePartial   e
730iA*----------------------------------------------------------------
730iA*  Weight4LBL   Get total weight for selection label
730iA*----------------------------------------------------------------

730iAp Weight4Lbl      b
730iAd Weight4Lbl      pi

730iA /free

730iA    // Need to get total weight for a Selection label

730iA   exec sql select sum(UIWGTLBS) into :total_wgt:MyfieldNull
730iA            from uciinfo2
730iA            where uisellbl# = :$uisellbl#
730iA              and uiseltrn# = :$uiseltrn#
730iA              and uiwhse = :$uiwhse
730iA              and uirtntrn# = 0;

730iA   if MyfieldNull = -1;
730iA     total_wgt=0;
730iA   endif;

730iA    If sqlstt = sqlSuccess;
730iA    endif;

730iA    // need to send count back - use $pmessage field
730iA      $preturn = '*LBLWGT  ';
730iA      $pmessage = %trim(%editc(total_wgt:'X'));

730iA /end-free
730iAp Weight4Lbl      e

720eA*----------------------------------------------------------------
720eA*  wrtUcilog   Write UCILOG record
720eA*----------------------------------------------------------------

720eAp WrtUCILog       b
720eAd WrtUCILog       pi

720eA /free
720eA   // we are only writing ucilog records for items that have UCI
720eA   // Receiving or Selection turned on.
720eA   if $ifrcvmth = '2' or $ifsltmth = '2';

720eA     // load up from fields first
720eA     ulfuci   = uiuci;
720eA     ulfitem   = uiItem;
720eA     Ulfitype  = $ittype;
720eA     ulfutyp   = uiautyp;
720eA     ulfsitem  = uiasitem;
720eA     ulfsitype = slot$item.$ittype;
720eA     ulfsutyp  = uiasutyp;
720eA     ulflcns =  uiLcns;
720eA     ulfseq  =  uiSeq;
720eA     ulfentd   = uiaentd;
720eA     ulfexpd   = uiaexpd;
720eA     if uiuci <> $uiuci;
720eA       ulucichg = 'Y';
720eA     endif;
720eA     select;
720eA       when uiitem = $uiitem;
720eA       when uiasitem = $uiitem;
720eA       when $uiitem = ' ';
720eA       other;
720eA         ulitemchg = 'Y';
720eA     endsl;
720eA     if uilcns <> $uitolcns and $uitolcns <> ' ';
720eA       ullcnschg = 'Y';
720eA     endif;
720eA     if uiaentd <> $uiaentd and $uiaentd <> 0;
720eA       ulentchg = 'Y';
720eA     endif;
720eA     if uiaexpd <> $uiaexpd and $uiaexpd <> 0;
720eA       ulexpchg = 'Y';
720eA     endif;

720eA     ulwhse = $uiWhse;
720eA     uluci  = $uiuci;
720eA     ulaction = $uiaction;
720eA     ulucilcns = uiucilcns;
720eA     if $uitolcns <> ' ';
720eA       ullcns = $uitolcns;
720eA     else;
720eA       ullcns = uilcns;
720eA     endif;
720eA     ulseq  = uiseq;
720eA     ulolcns = uiaOLcns;
720eA     uloseq = uiaOSeq;
720eA     ulutrn = nxtutrn#;
720eA     nxtutrnSeq += 1;
720eA     ulutrnseq = nxtutrnseq;
720eA     if ulaction = 'RTNWHLORD';
720eA       ultrn# =  savertntrn#;
720eA     else;
720eA       ultrn# =  $uiTran#;
720eA     endif;
720eA     ullbl# = $uilbl#;
720eA     uletrn# = $uiETrn#;
720eA     ulscan = $uiscan;


720eA     // selection infromation
720eA     ulseltrn# = uiSelTrn#;
720eA     ulsellbl# = uiSelLbl#;
720eA     ulselord  = uiSelOrd;
720eA     ulselseq  = uiSelSeq;
720eA     ulselcseq = uiSelCSeq;
720eA     ulseltrax = uiSelTrax;

720eA     // return information
720eA     ulrtntrn# = uiRtnTrn#;

720eA     // Exception Information
720eA     ulexccode =  $uiexccode;
720eA     ulexcstat =  $uiexcstat;
720eA     ulexcuser =  $uiexcuser;
720eA     ulexcts   =  $uiexcts;

720eA     // Export information
720eA     ulexpflag = $uiexpflag;
720eA     ulexpts   = $uiexpts;
720eA     ulexpuc   = $uiexpuc;
720eA     ulexpjusr = $uiexpjusr;
720eA     ulexpjob  = $uiexpjob;
720eA     ulexpnbr  = $uiexpnbr;

720eA     // timestamps - user tracking
720eA     GetCurrStamp();
720eA     uladdts = currstampsys;
720eA     uladduc = currstampuc;
720eA     uladdcpgm = $uiaddpgm;
720eA     uladdjpgm = #pgm;
720eA     uladdemp = $uiaddEmp;
720eA     uladdeusr = $uiaddUsr;
720eA     uladdcusr = #curruser;
720eA     uladdjusr = #user;
720eA     uladdjob = #job;
720eA     uladdnbr = #jobnbr;


720eA     write(e) ulrec;
720eA     if %error;
720eA     else;
720eA     endif;

720eA     clear ulrec;

720eA   endif;
720eA /end-free
720eAp wrtucilog       e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------
     p ZZZDriCop       b
     d ZZZDriCop       pi

      /free

         select;
           when $dricommand = '*LICINFO';
             $dridata = $licinfo;
             $dridata2 = $licinfo2;
         endsl;

650dA    $drisys2upd = 'D';
650dD    //DriMain3($dricommand: $drisubcmd: 'D': $pprogram:
650dM    DriMain3($dricommand: $drisubcmd: $drisys2upd: $pprogram:
                  $drireturn: $drimessage: $dridata: $dridata2);

         select;
           when %error;
             error = *on;
             errmsg = 'Error occured on call to '
                    + 'DRICOP'
                    + '/' + %trim($drisubcmd)
                    + ' from ' + #pgm;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

         select;
           when $dricommand = '*LICINFO';
             $licinfo = $dridata;
             $licinfo2 = $dridata2;
         endsl;

      /end-free

     p ZZZDriCop       e
