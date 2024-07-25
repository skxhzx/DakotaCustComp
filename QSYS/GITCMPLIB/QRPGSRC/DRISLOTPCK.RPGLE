500gA /COPY *libl/qcopysrc,hspecs

PCKe *----------------------------------------------------------------
     * Notice!!  This version is not for BFC Production use.
     *           This src code came from Packer's Provision system
     *           and it contains updates that are not included in
     *           any current versions of the pgm:
     *           Updates: 4.17m, 4.17n, 5.10h, 5.10i and 5.20
     *
PCKe *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRISLOT     Dakota realtime interface - Slot maintenance
     *  10 October 2001
     *  Dave Sommerville
     *
416  *    10/10/01  DAS  4.16
     *      - Created
     *
416aA*    10/29/01  DAS  4.16a
     *      - Revised UPDSTOCK routine to update SLREC2 instead of SLREC.
     *      - Revised UPDSTOCK routine to recalculate qtys at the end.
     *
416bA*    11/21/01  DAS  4.16b
     *      - Added subcommand *NXTOVRF, *PRVOVRF, *NXTPICK, *PRVPICK,
     *        *NXTSLOT, *PRVSLOT, *NXTSLOTI, *PRVSLOTI, *NXTITEM, *PRVITEM.
     *
416cA*    11/26/01  DAS  4.16c
     *      - Added subcommand *UPDQTY.
     *      - Added logging.
     *
416dA*    12/04/01  DAS  4.16d
     *      - Added routine *VERIFYQTY.
     *      - Added subcommands *ADJALC, *ADJPCK, *ADJSTK, *ADJPCKSTK,
     *        *ADJUST, *ADJUSTORD and *ALC2PCK.
     *
416eA*    01/11/02  DAS  4.16e
     *      - Added subcommand *SEQPTYRPL.
     *      - Revised routine crtprtyrpl to use *CRTRPLSEQ instead of
     *        *CRTRPL. New code will automatically assign sequence
     *        number to Priority Replenishment.
     *      - Added call to crtprtyrpl at end of qtypick routine.
     *
416eA*    01/23/02  DAS  4.16f
     *      - Implemented logging.
     *
416g *    01/24/02  DAS  4.16g
     *      - Moved getting record for change from changerec routine
     *        into verifychg routine.
     *
416h *    01/23/02  DAS  4.16h
     *      - Revised to identify if called from Dakota.
     *      - Revised to call DRIMAIN2 to update the host when called
     *        from Dakota. This allows the Dakota program to only have
     *        to make a single call to the interface.
     *
416i *    01/23/02  DAS  4.16i
     *      - Remove *UPDSTOCK, not used anymore.
     *      - Added special code *NOUPDATE* that is sent from a
     *        Dakota program in the $preturn field. See notes below.
     *      - Added *ADDVS for creating virtual slots.
     *      - Replaced VFYDESG with DRIDESIG.
     *      - Replaced VFYDEPT with DRIDEPT.
     *      - Added verification logic to verifyqty, qtytfrout,
     *        qtyclstfrout,
     *      - Added command *VERIFYTFO, *SET2VFY.
     *
416j *    02/09/02  DAS  4.16j
     *      - Added *CRTXDOCK for creating crossdock slot.
     *      - Added *GETXDOCK to get crossdock slot for item.
     *      - Added routines crtxdock, getxdock and verifygetxdk.
     *
416k *    02/16/02  DAS  4.16k
     *      - Revised deleteslot routine to use slot2 for *VERIFYDEL.
     *
416l *    02/25/02  DAS  4.16l
     *      - Revised crtprtyrpl routine to use set $prfill to 'Y'.
     *
416m *    02/28/02  DAS  4.16m
     *      - Revised changeslot by replacing calls to ADJQTY
     *        with calls to DRIITEMQTY.
     *      - Revised verifychg to initialize #slot fields.
     *      - Revised verifychg to only do active pick slot check when
     *        the status code is being changed to 'A'.
     *      - Revised divide by zero errors with catch weights.
     *
416n *    03/08/02  DAS  4.16n
     *      - Added *CHGITEM/*VFYCHGITM subcommands.
     *
416o *    04/19/02  DAS  4.16o
     *      - Added subcommand *VERIFYTFI.
     *
416p *    05/21/02  DAS  4.16p
     *      - Revised routine SHIFTSSBQTY to shift quantity fields if
     *        sent item is a type 'S'. A normal quantity sent in is
     *        shifted into a breakdown 1 quantity for the update.
     *      - Revised routine VERIFYQTY to get SSB item for the
     *        slot item and not the sent item.
     *      - Revised routine VERIFYQTY to call new routine.
     *      - Revised routine mainline to call new routine after
     *        call SAVEBEFORE routine. This routine restores the
     *        original values that were sent in, thus undoing the
     *        shift done from the VERIFYQTY routine.
     *
416q *    06/10/02  DAS  4.16q
     *      - Recompiled because $salic#/$iqlic# changed from 7.0 to 15.
     *
416r *    07/18/02  DAS  4.16r
     *      - Added *NXTPICKAV to get next pick slot with avail qty.
     *      - Revised slot2ds to get base slot for *GET, *NXT and *PRV
     *        operations. Base slot is put into $slcdsp. For non-virtual
     *        slots it is set to $sldisp.
     *
416s *    08/28/02  DAS  4.16s
     *      - Revised fixbrkdn routine to use #slotumq fields instead of
     *        $itumq fields.
     *
416t *    10/07/02  DAS  4.16t
     *      - Revised VERIFYNXTPRV routine to set $slprty to -9 when
     *        not sent for *NXTPICKAV.
     *
416u *    04/10/03  DAS  4.16u
     *      - Revised VERIFYCHG to not allow status to be changed to 'V'.
     *        Re: Slots must be verified through the verification program
     *            so corresonding records get deleted.
     *      - Added subcommand *ADJUSTTFR. It is only passed through to the
     *        host. No local files are updated by it. Re: When changing
     *        an item number during a transfer, adjustment records are made
     *        but the slot quantities are changed using the TFRIN/OUT
     *        subcommands. However, we want the host system to be able to
     *        just look at ADJUST commands to keep warehouse quantities
     *        in synch.
     *
417  *    05/02/03  DAS  4.17
     *      - Revised QTYRECEIVE routine to change priority to 0 if the
     *        slot is a reserved pick slot.
     *      - VERIFYRCVM was skipping the get record logic even when we
     *        were not doing just a verify.
     *
417a *    06/07/03  DAS  4.17a
     *      - Added subcommands *GETCHKV, *GETICHKV, *NXTVSLOT and
     *        *PRVVSLOT.
     *      - Added routine openvslot2.
     *      - Revised routine look4slot to call routine openvslot2.
     *
417b *    07/18/03  DAS  4.17b
     *      - Revised check for virtual for *NXT and *PRV.
     *
417c *    09/18/03  DAS  4.17c
     *      - Added subcommand *ZEROVFY.
     *      - Added *ZEROVFY data structure.
     *      - Added files SPCLORD, VSLEXCP, CROSSDK.
     *      - Added routines zerovfy, deletespclord, deletecrossdk,
     *        deletevlsexcp, openspclord, opencrossdk, openvlsexcp,
     *        and openvslot2.
     *      - Revised routine set2vfy to update slrec2 and to be used
     *        by *ZEROVFY and to set status to 'V'.
     *      - Revised routine deleteslot to delete associated records
     *        and to be used by *ZEROVFY.
     *
417d *    09/29/03  DAS  4.17d
     *      - Fields added to C#SLOT, version 6.
     *      - Brought CLEARERRFLAGS routine up to date.
     *      - Revised Transfer Out/In to handle an item change.
     *
417e *    10/03/03  DAS  4.17e
     *      - Field added to C#SLOT, version 7.
     *      - Revised to send back check digit with slot information.
     *
417f *    10/16/03  DAS  4.17f
     *      - Added *TFRINCHG, *TFROUTCHG, *VFYTFICHG, *VFYTFOCHG,
     *        *CLSTFICHG and *CLSTFOCHG.
     *        These commands take into account that the item may change and
     *        because of this, the IN qty may have to be converted.
     *
417g *    10/17/03  DAS  4.17g
     *      - Added *NXTOVRFAV to get next overflow slot with avail qty.
     *
417h *    10/31/03  DAS  4.17h
     *      - Added commands specific for Returns. Letdowns, Specific Slot
     *        Replenishments and Priority Replenishments. This was done
     *        1) to provide more informative commands that can be viewed in
     *        the log and 2) because entered/expirations date logic needs
     *        to know what type of transaction is being performed.
     *
417i *    11/03/03  DAS  4.17i
     *      - Created routines setentdate, setexpdate, setpriority
     *        and setstatus. The date routines use the new date
     *        options.
     *      - Revised routines qtyclsrcv and qtyreceive to call new
     *        routines.
     *
417j *    11/11/03  DAS  4.17j
     *      - Added more error checking logic to VERIFYRCVM.
     *      - Revised LOOK4SLOT to see if exp dates are the same.
     *
417k *    11/16/03  DAS  4.17k
     *      - Revised NEXTPREV routine by moving call to slot2ds after
     *        the qtys are checked.
     *
417l *    11/20/03  DAS  4.17l
     *      - Revised NEXTPREV routine to do setll first.
     *
417m *    02/04/04  DAS  4.17m
     *      - Revised keyvs2 to use $k fields.
     *
417n *    02/18/04  DAS  4.17n
     *      - Revised deleteslot to use slot2 file for *zerovfy.
     *
417o *    04/07/04  MLB  4.17o
     *      - Fix: Revised VerifyChg to not allow RSRV field to be
     *        changed to V=Virtual slot.
     *
417p *    04/07/04  DAS  4.17p
     *      - Fix: Revised WRITEADJ routine to use SSB item number
     *        when writing SSB adjustment record.
     *
417q *    05/27/04  DAS  4.17q
     *      - Fix: Revised look4slot to initializ error field.
     *
417r *    06/08/04  DAS  4.17r
     *      - Fix: Revised to call checkstat before setentdate.
     *        Re: checkstat was overwriting entered date.
     *
417s *    10/07/04  DAS  4.17s
     *      - Enh: Added command *CLSRCVADJ to receive qty and
     *        create adjustment record.
     *
500  *    11/05/04  DAS  5.00
     *      - Added *NXTITEMAV to get next item slot with avail qty.
     *      - Added *GETITEMAV to get next item slot with avail qty.
     *
500a *    09/09/04  DAS  5.00a (was 4.17s in PIRVOICE)
     *      - Enh: Added *GETOVRFAV'
     *
500b *    11/05/04  DAS  5.00b
     *      - Added *GETITEMAV to get next item slot with avail qty.
     *      - Removed some 5.00a code from NXTPREV routine.
     *
500c *    11/17/04  DAS  5.00c
     *      - Revised to handle Alias items when adjusting quantities.
     *
500dA*    12/17/04  DAS  5.00d
     *      - Fix: Removed check for negative avail whse qty.
     *
500eA*    01/26/05  DAS  5.00e
     *      - Fix: For *NXT if priority is 0, set to -9.
     *
500eA*    01/27/05  DAS  5.00e
     *      - Enh: Added commands *VERIFYPUT and *VERIFYRTN.
     *      - Reserved
     *
500fA*    01/28/05  DAS  5.00f
     *      - Enh: Added putaway check that a virtual slot cannot
     *        be sent in.
     *      - Second part not added to this version.
     *
500gA*    01/29/05  DAS  5.00g
     *      - Reserved
     *
500hA*    02/06/05  DAS  5.00h
     *      - Enh: Revised to not do Host call. Re: No one currently using
     *        it. Not calling host will cut down on log records.
     *
500iA*    02/09/05  DAS  5.00i
     *      - Reserved
     *
500jA*    02/10/05  DAS  5.00j
     *      - Reserved
     *
500kA*    02/22/05  DAS  5.00k
     *      - Added command *CRTVPICK.
     *      - Added routines CRTVPICK and VFYCRTVPICK
     *      - Revised routine VERIFYPICK to user $saitem instead of slitem.
500lA*    05/08/05  DAS  5.00l
     *      - Enh: Revised program to add support for Client id
500xA*    08/04/05  DAS  5.00x
     *      - Added commands *STAGEPUT, *CLSSTGPUT and *VFYSTGPUT.
     *        These the same as *PUTAWAY, *CLSPUTAWY and *VERIFYPUT,
     *        excpet that we force the MANUALPUTAWAY flag on.
     *
510aA*    06/06/06  DAS  5.10a
     *      - Revised to call UPDSLTDTE to update the slot date recs.
510bA*    07/13/06  RH   5.10b
     *      - FIX: Was getting error if all hand stack's were used for
     *        virtual slots.
510cA*    09/27/06  RAH  5.10c
     *      - Revised to load the date and time to $sadate and $satime
     *        for so this date/time can be returned in parm list and
     *        used in other programs.
510dA*    02/24/07  DAS  5.10d
     *      - Added commands *CRTREPAKR, *CRTREPAKP, GETREPACK.
510eA*    02/24/07  DAS  5.10e
     *      - Added some 500g changes into look4slot. Marked 500g.
510fA*    03/05/07  DAS  5.10f
     *      - Revised verifyqtyadj routine to compare "low" qtys
     *        instead of individual qtys.
510gA*    04/14/07  MLB  5.10g
     *      - FIX: Revised VERIFYCHG routine to increment VOCOUNT by
     *        1 to include new pick slot when current status <> 'A '
     *        or item number is changing.
510hA*    08/14/07  DAS  5.10h
     *      - Added routine zerovfyauto. This routine will auto
     *        verify a slot under specific conditions.
     *      - Revised to always call zerovfyauto after a slot has
     *        been updated to a 'Z' status as a result of the
     *        checkstatus routine.
510iA*    06/19/07  JCJ  5.10i
     *      - do not load $sadate and $satime if passed in.
520 A*    01/22/08  JCJ  5.20
     *      - Enh: Revise program to add two new options dealing with
     *             expiration dates during receiving / returns putaway
     *
     *----------------------------------------------------------------
     * Jordano's Custom Changes
     *
JOR  *    04/14/05  MLB  JOR
     *      - Revised CRTVIRTUAL to allow virtual pick slots to be
     *        created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
     *
PAK A*    08/17/07  RBD  PAK  P#00111
     *      - Revised subr verifychg to not allow status to be changed
     *        to QA or BL unless the slot is empty.
     *      - As of 7/15/09 this project was canceled because the SAP
     *        Host app never went live.  The rev's will remain, but
     *        the code will likely never be used.
     *
PCKaA*    05/10/07  TJ   PCKa
     *      - Revised to ignore the inactive slot status code edit.
     *        This mod was added when merging It352 pirlic510 and
     *        pirenh510.
     *
PCKbA*    01/18/08  JCJ  PCKb
     *      - Allow override to put item in overflow slot with dif dte
PCKcA*    11/19/09  MLB  PCKc
     *      - Allow user to put items into slots with slot status
     *        equal to SO = Star Meats special order slots.
PCKdA*    11/19/09  MLB  PCKd
     *      - Revised CRTVIRTUAL routine to allow virtual pick slots
     *        to be created when SLPICK=Y and SLRSRV='N' and
     *        psubcmd = *PUTAWAY.
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
     *  - Some Dakota programs will send '*NOUPDATE*' in the $preturn
     *    parameter. This identifies that the operation was already
     *    done by the calling program and is being sent to this
     *    interface program to 1) log it and 2) send it to the host.
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Standard Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *    Retrieval Sub-Commands
      *
      *      *GET              Get slot information using slot display.
      *
417aA *      *GETCHKV          Get slot information using slot display
      *                        and check if associated virtual slot exists.
      *
      *      *GETI             Get slot information using individual fields.
      *
417aA *      *GETICHKV         Get slot information using individual fields.
      *                        and check if associated virtual slot exists.
      *
500 A *      *GETITEMAV        Get item slot within physical slot.
      *
500aA *      *GETOVRFAV        Get item overflow slot within physical slot.
      *
510dA *      *GETREPACK        Get repack slot for item.
510dA *                          - Assumes only 1 repack slot for item.
      *
416jA *      *GETXDOCK         Get crossdock slot for item.
416jA *                          - Assumes only 1 crossdock slot for item.
      *
416bA *      *NXTITEM          Get next slot for item.
      *                        Does a SETGT and then a READE.
      *
500 A *      *NXTITEMAV        Get next slot for item with available qty.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTOVRF          Get next overflow slot.
      *                        Does a SETGT and then a READE.
      *
417gA *      *NXTOVRFAV        Get next overflow slot with available qty.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTPICK          Get next pick slot.
      *                        Does a SETGT and then a READE.
      *
416rA *      *NXTPICKAV        Get next pick slot with available quantity.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTSLOT          Get next slot using slot display field.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTSLOTI         Get next slot using individual fields.
      *                        Does a SETGT and then a READE.
      *
417aA *      *NXTVSLOT         Get next virtual slot.
      *                        Does a SETGT and then a READE.
      *
416bA *      *PRVITEM          Get previous slot for item.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVOVRF          Get previous overflow slot.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVPICK          Get previous pick slot.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVSLOT          Get previous slot using slot display field.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVSLOTI         Get previous slot using individual fields.
      *                        Does a SETLL and then a READPE.
      *
417aA *      *PRVVSLOT         Get previous virtual slot.
      *                        Does a SETLL and then a READPE.
      *
      *    Maintenance Sub-Commands
      *
      *      *ADD              Add slot.
      *
      *      *ADDVS            Add virtual slot.
      *
416jA *      *ADDXDOCK         Add crossdock slot.
416jA *                         - Not used by program
416jA *                         - If sent, assumed to be sent by Dakota and
416jA *                           is passed through to host.
416jA *                         - Used to tell host that XDK slot created
416jA *                           by Dakota using *CRTXDOCK command.
416jA *                         - Host system should only send *CRTXDOCK.
      *
      *      *CHANGE           Change slot.
      *
416nA *      *CHGITEM          Change item number in slot.
      *
510dA *      *CRTREPAKP        Create Parent repack slot.
      *
510dA *      *CRTREPAKR        Create Repack repack slot.
      *
416jA *      *CRTXDOCK         Create crossdock slot.
      *
500kA *      *CRTVPICK         Create virtual pick slot.
      *
      *      *DELETE           Delete slot using slot display field.
      *      *DELETEI          Delete slot using individual slot fields.
      *      *DELETEX          Delete slot w/o checks using slot display fld
      *
      *      *SET2VFY          Set slot to Verified state.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
416nA *      *VFYCHGITM        Do "*CHGITEM" verification without update.
      *
      *      *WARN             Check for warnings. Only one warning is
      *                        flagged at a time.
      *
      *      *WARNOVR          Override warning. Check for another warning.
      *
417cA *      *ZEROVFY          Zero verify slot.
      *
      *    Quantity Sub-Commands
      *
      *      *ADJUST           Normal stock adjustment.
      *                        For negative adjustment, the adjustment qty
      *                        cannot be greater than the calculated
      *                        adjustable quantity.
      *
      *      *ADJUSTORD        Selection order stock adjustment.
      *                        This adjustment should only be used with the
      *                        Locator system. Slot quantity is allowed to
      *                        go negative. If slot is a pick slot and slot
      *                        quantity goes negative, generate a Priority
      *                        Replenishment.
      *
416uA *      *ADJUSTTFR        Transfer adjustment record created.
      *                        This subcommand does not update an local
      *                        files. It is only passed to the host system.
      *
416cA *      *ALC2PCK          Move qty from allocated to picked.
416cA *                        Decrease allocated qty with original qty.
416cA *                        Increase pick qty with adjust qty.
      *
416cA *      *ALLOCATE         Update allocated quantity.
416cA *                        Inc/Dec allocated qty with adjust qty.
      *
417hA *      *CLSLETIN         Close letdown-in.
417hA *                        See *CLSTFRIN.
      *
417hA *      *CLSLTICHG        Close letdown-in with possible item change.
417hA *                        See *CLSTFICHG.
      *
417hA *      *CLSLETOUT        Close letdown-out.
417hA *                        See *CLSTFROUT.
      *
417hA *      *CLSLTOCHG        Close letdown-out with possible item change.
417hA *                        See *CLSTFOCHG.
      *
416cA *      *CLSPICK          Close pick.
416cA *                        Decrease pick qty with original qty.
416cA *                        Decrease stock qty with adjust qty.
      *
417hA *      *CLSPRIN          Close priority repl - in
417hA *                        See *CLSTFRIN.
      *
417hA *      *CLSPRICHG        Close prty repl-in with possible item change.
417hA *                        See *CLSTFICHG.
      *
417hA *      *CLSPROUT         Close priority repl - out
417hA *                        See *CLSTFROUT.
      *
417hA *      *CLSPROCHG        Close prty rpl-out with possible item change.
417hA *                        See *CLSTFOCHG.
      *
417hA *      *CLSPUTAWY        Close putaway.
417hA *                        See *CLSRCV.
      *
416cA *      *CLSRCV           Close receiving/putaway.
416cA *                        Decrease receive qty with original qty.
416cA *                        Increase stock qty with adjust qty.
      *
417sA *      *CLSRCVADJ        Close receiving/putaway w/adjustment.
417sA *                        Decrease receive qty with original qty.
417sA *                        Increase stock qty with adjust qty.
417sA *                        Create adjustment record.
      *
417hA *      *CLSRTN           Close return putaway.
417hA *                        See *CLSRCV.
      *
417hA *      *CLSSSIN          Close specific slot - in
417hA *                        See *CLSTFRIN.
      *
417hA *      *CLSSSICHG        Close spec slot-in with possible item change.
417hA *                        See *CLSTFICHG.
      *
417hA *      *CLSSSOUT         Clost specific slot - out
417hA *                        See *CLSTFROUT.
      *
417hA *      *CLSSSOCHG        Close spec slt-out with possible item change.
417hA *                        See *CLSTFOCHG.
      *
500xA *      *CLSSTGPUT        Close staged putaway.
500xA *                        See *CLSPUTAWY.
      *
416cA *      *CLSTFRIN         Close transfer-in.
416cA *                        Decrease receive qty with original qty.
416cA *                        Increase stock qty with adjust qty.
      *
417fA *      *CLSTFICHG        Close transfer-in with possible item change.
417fA *                        Decrease receive qty with original qty.
417fA *                        Increase stock qty with adjust qty.
417fA *                        Note: Qtys will be converted for Parent/Child
417fA *                              relationship.
      *
416cA *      *CLSTFROUT        Close transfer-out.
416cA *                        Decrease transfer qty with original qty.
416cA *                        Decrease stock qty with adjust qty.
      *
417fA *      *CLSTFOCHG        Close transfer-out with possible item change.
417fA *                        Decrease transfer qty with original qty.
417fA *                        Decrease stock qty with adjust qty.
      *
417hA *      *LETIN            Transfer Letdown quantity into slot.
417hA *                        See *TFRIN.
      *
417hA *      *LETINCHG         Transfer Letdown quantity into slot
417hA *                          with possible item change.
417hA *                        See *TFRINCHG.
      *
417hA *      *LETOUT           Transfer Letdown quantity out of slot.
417hA *                        See *TFROUT.
      *
417hA *      *LETOUTCHG        Transfer Letdown quantity out of slot
417hA *                          with possible item change.
417hA *                        See *TFROUTCHG.
      *
416cA *      *PCK2ALC          Move qty from picked to allocated.
416cA *                        Decrease pick qty with original qty.
416cA *                        Increase allocated qty with adjust qty.
      *
416cA *      *PICK             Update picked quantity.
416cA *                        Inc/Dec pick qty with adjust qty.
      *
417hA *      *PRIN             Transfer Priority Repl quantity into slot.
417hA *                        See *TFRIN.
      *
417hA *      *PRINCHG          Transfer Priority Repl quantity into slot
417hA *                          with possible item change.
417hA *                        See *TFRINCHG.
      *
417hA *      *PROUT            Transfer Priority Repl quantity out of slot.
417hA *                        See *TFROUT.
      *
417hA *      *PROUTCHG         Transfer Priority Repl quantity out of slot
417hA *                          with possible item change.
417hA *                        See *TFROUTCHG.
      *
417hA *      *PUTAWAY          Update receive quantity for Putaway.
417hA *                        See *RECEIVE.
      *
416cA *      *RECEIVE          Update receive quantity.
416cA *                        Inc/Dec receive qty with adjust qty.
      *
417hA *      *RETURN           Update receive quantity for Return.
417hA *                        See *RECEIVE.
      *
416eA *      *SEQPTYRPL        Sequence priority replenishments
      *
417hA *      *SSIN             Tfr Specific Slot Repl quantity into slot.
417hA *                        See *TFRIN.
      *
417hA *      *SSINCHG          Tfr Specific Slot Repl quantity into slot
417hA *                          with possible item change.
417hA *                        See *TFRINCHG.
      *
417hA *      *SSOUT            Tfr Specific Slot Repl quantity out of slot.
417hA *                        See *TFROUT.
      *
417hA *      *SSOUTCHG         Tfr Specific Slot Repl quantity out of slot
417hA *                          with possible item change.
417hA *                        See *TFROUTCHG.
      *
500xA *      *STAGEPUT         Update receive quantity for staged putaway.
500xA *                        See *PUTAWAY.
      *
416cA *      *STOCK            Update stock quantity.
416cA *                        Inc/Dec stock qty with adjust qty.
      *
416cA *      *TFRIN            Transfer quantity into slot.
416cA *                        Inc/Dec receive qty with adjust qty.
      *
417fA *      *TFRINCHG         Transfer quantity into slot
417fA *                          with possible item change.
417fA *                        Inc/Dec receive qty with adjust qty
417fA *                        Note: Qtys will be converted for Parent/Child
417fA *                              relationship.
      *
416cA *      *TFROUT           Transfer quantity out of slot.
416cA *                        Inc/Dec transfer qty with adjust qty.
      *
      *
417fA *      *TFROUTCHG        Transfer quantity out of slot
417fA *                          with possible item change.
417fA *                        Inc/Dec transfer qty with adjust qty.
      *
      *      *VERIFY           Do verification for *ADJUST.
      *
      *      *VERIFYORD        Do verification for *ADJUSTORD.
      *
500eA *      *VERIFYPUT        Do verification for *PUTAWAY.
500eA *      *VERIFYRTN        Do verification for *RETURN.
417hA *      *VERIFYLTI        Do verification for *LETIN.
417hA *      *VERIFYPRI        Do verification for *PRIN.
417hA *      *VERIFYSSI        Do verification for *SSIN.
416oA *      *VERIFYTFI        Do verification for *TFRIN.
417hA *      *VERIFYLTO        Do verification for *LETOUT.
417hA *      *VERIFYPRO        Do verification for *PROUT.
417hA *      *VERIFYSSO        Do verification for *SSOUT.
      *      *VERIFYTFO        Do verification for *TFROUT.
417hA *      *VFYLTICHG        Do verification for *LETINCHG.
417hA *      *VFYPRICHG        Do verification for *PRINCHG.
417hA *      *VFYSSICHG        Do verification for *SSINCHG.
500xA *      *VFYSTGPUT        Do verification for *STAGEPUT.
417fA *      *VFYTFICHG        Do verification for *TFRINCHG.
417hA *      *VFYLTOCHG        Do verification for *LETOUTCHG.
417hA *      *VFYPROCHG        Do verification for *PROUTCHG.
417hA *      *VFYSSOCHG        Do verification for *SSOUTCHG.
417fA *      *VFYTFOCHG        Do verification for *TFROUTCHG.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fslot1     uf a e           k disk    usropn
     F                                     infds(file1ds)
     Fslot2     uf a e           k disk    usropn
     F                                     infds(file2ds)
     F                                     rename(slrec:slrec2)
416bAFslot3     uf a e           k disk    usropn
416bAF                                     infds(file4ds)
416bAF                                     rename(slrec:slrec3)
412 AFvslot     uf a e           k disk
     F                                     infds(file3ds)
     Fvslot2    if   e           k disk
416bAF                                     rename(vsrec:vsrec2)
     Fitemadj   o  a e           k disk    usropn
     Flabel     o  a e           k disk    usropn
412 AFoptions   if   e           k disk
     Flogslot   o    e           k disk
417cAFspclord   uf   e           k disk    usropn
417cAFvslexcp   uf   e           k disk    usropn
417cAFcrossdk   uf   e           k disk    usropn
417eAFslotdgt   if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

409 AD hnd             S              2    dim(702)
409 AD ltr             S              1    dim(27) ctdata perrcd(27)

500lA*----------------------------------------------------------------
500lA*  Customer id
500lA*----------------------------------------------------------------
500lA
500lA /copy qcopysrc,id#jordano
500lA /copy qcopysrc,id#vigo
PAK A /copy qcopysrc,id#packers

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
     D savesubcmd      s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#ITEMQTY
416bA /COPY *libl/qcopysrc,C#PRTYRPL
416bA /COPY *libl/qcopysrc,C#DEPT
416bA /COPY *libl/qcopysrc,C#DESIG
     D saveVer#        s                   like($slver#)
     D savedisp        s                   like($sldisp)
     D saveexpdu       s                   like($slexpdu)
     D saveexpd        s                   like($slexpd)
     D saveslfdu       s                   like($slslfdu)
     D saveslfd        s                   like($slslfd)
     D saveprtyu       s                   like($slprtyu)
     D saveprty        s                   like($slprty)
     D $slotbefore     s                   like($slot)
     D $slotinput      s                   like($slot)
     D $preturninput   s                   like($preturn)
     D $pmessageinput  s                   like($pmessage)

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     D slphy1          s                   like(slstk1)
     D slphy2          s                   like(slstk2)
     D slphy3          s                   like(slstk3)
     D slavl1          s                   like(slstk1)
     D slavl2          s                   like(slstk2)
     D slavl3          s                   like(slstk3)
     D sladj1          s                   like(slstk1)
     D sladj2          s                   like(slstk2)
     D sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vactv          s                   like($slactv)
     D $vbld           s                   like($slbld)
     D $vcode          s                   like($sacode)
     D $vdesg          s                   like($sldesg)
     D $vdisp          s                   like($sldisp)
     D $vitem          s                   like($slitem)
     D $vsdef          s                   like($slsdef)
     D $vstat          s                   like($slstat)
416aAD $vsys           s              1
     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D pgm2close       s             10

     D dridept         s               n
     D dridesig        s               n
     D driitem         s               n
     D driitemqty      s               n
     D driprtyrpl      s               n
     D vfyadjc         s               n
     D vfyactv         s               n
     D vfybld          s               n
     D vfysdef         s               n
     D vfysstat        s               n
     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n
     D UpdateDakota    s               n

     D DirectPutaway   s               n
     D ManualPutaway   s               n

510eAD autovfy         s               n
     D check4err       s               n
417dAD cssbflag        s               n
     D curdate         s              8  0
     D curtime         s              6  0
     D desigcode       s                   like($sldesg)
417jAD difexpdte       s               n
     D dummy           s                   like($slloc)
     D error           s               n
     D exist           s               n
     D flaghs          s               n
     D forever         s               n   inz(*on)
     D found           s               n
     D i               s              3  0
     D item#           s                   like(slitem)
     D j               s              3  0
     D k               s              3  0
     D kywhse          s                   like(slwhse)
     D kywhdp          s                   like(slwhdp)
     D kydisp          s                   like(sldisp)
416jAD kystat          s                   like(slstat)
416jAD kyaisl          s                   like(slaisl)
417mAD kvwhse          s                   like(slwhse)
417mAD kvwhdp          s                   like(slwhdp)
417mAD kvdisp          s                   like(sldisp)
     D lasttime        s              6  0 inz(999999)
     D lock            s               n
417eAD lockedslotdgt   s               n
     D lockeditemqty   s               n
     D lockedslot1     s               n
     D lockedslot2     s               n
     D lockedvslot     s               n
     D logit           s               n
     D lowiaorg        s              7  0
     D lowiaqty        s              7  0
510fAD lownewavl       s              7  0
     D lowunitwgt      s              9  2
     D lowwhavl        s              7  0
     D newavlqty1      s                   like(slavl1)
     D newavlqty2      s                   like(slavl2)
     D newavlqty3      s                   like(slavl3)
     D newvs           s               n
     D nextseq#        s              7  0
500aAD noneavail       s               n
     D openstack       s             10    dim(15)
     D                                     inz(' ')
     D phactv          s                   like(SLACTV)
     D phaisl          s                   like(SLAISL)
     D phbld           s                   like(SLBLD)
     D phdesg          s                   like(SLDESG)
     D phdisp          s                   like(SLDISP)
     D phhand          s                   like(SLHAND)
     D phloc           s                   like(SLLOC)
     D phpseq          s                   like(SLPSEQ)
     D phrlvl          s                   like(SLRLVL)
     D phsdef          s                   like(SLSDEF)
     D phside          s                   like(SLSIDE)
     D phslfd          s                   like(SLSLFD)
     D phstyp          s                   like(SLSTYP)
     D phwhdp          s                   like(SLWHDP)
     D phwhse          s                   like(SLWHSE)
     D pssrflag        s               n
417fAD remainder       s              5  0
     D remaincw        s              7  2
     D ssbflag         s               n
417fAD temp5n          s              5  0
416dAD tmploc          s                   like(slloc)
     D updexpdte       s               n
     D updprty         s               n
     D vslotcreated    s               n
     D warningtype     s                   like($psubcmd)

416dAD #dtypeitem      s                   like($dstype)
416dAD #dtypeslot      s                   like($dstype)

416dAD #sentitem       s                   like($ititem)
416dAD #senttype       s                   like($ittype)
416dAD #sentdesc       s                   like($itdesc)
416dAD #sentpdsc       s                   like($itpdsc)
416dAD #sentwhdp       s                   like($itwhdp)
416dAD #sentstyp       s                   like($itstyp)
416dAD #sentdesg       s                   like($itdesg)
416dAD #sentum1        s                   like($itum1)
416dAD #sentflg1       s                   like($itflg1)
416dAD #sentum2        s                   like($itum2)
416dAD #sentumq2       s                   like($itumq2)
416dAD #sentflg2       s                   like($itflg2)
416dAD #sentum3        s                   like($itum3)
416dAD #sentumq3       s                   like($itumq3)
417fAD #sentmitem      s                   like($itmitem)

416dAD #slotitem       s                   like($ititem)
416dAD #slottype       s                   like($ittype)
416dAD #slotdesc       s                   like($itdesc)
416dAD #slotpdsc       s                   like($itpdsc)
416dAD #slotwhdp       s                   like($itwhdp)
416dAD #slotstyp       s                   like($itstyp)
416dAD #slotdesg       s                   like($itdesg)
416dAD #slotum1        s                   like($itum1)
416dAD #slotflg1       s                   like($itflg1)
416dAD #slotum2        s                   like($itum2)
416dAD #slotumq2       s                   like($itumq2)
416dAD #slotflg2       s                   like($itflg2)
416dAD #slotum3        s                   like($itum3)
416dAD #slotumq3       s                   like($itumq3)
416dAD #slotnrpk       s                   like($imnrpk)
416dAD #slotflgd       s                   like($itflgd)
416nAD #slotswgt       s                   like($itswgt)
416nAD #slotcwgt       s                   like($itcwgt)
417fAD #slotmitem      s                   like($itmitem)

416dAD #ssbitem        s                   like($ititem)
416dAD #ssbtype        s                   like($ittype)
416dAD #ssbdesc        s                   like($itdesc)
416dAD #ssbpdsc        s                   like($itpdsc)
416dAD #ssbwhdp        s                   like($itwhdp)
416dAD #ssbstyp        s                   like($itstyp)
416dAD #ssbdesg        s                   like($itdesg)
416dAD #ssbum1         s                   like($itum1)
416dAD #ssbum2         s                   like($itum2)
416dAD #ssbumq2        s                   like($itumq2)
416dAD #ssbum3         s                   like($itum3)
416dAD #ssbumq3        s                   like($itumq3)

417dAD #csentitem      s                   like($ititem)
417dAD #csenttype      s                   like($ittype)
417dAD #csentdesc      s                   like($itdesc)
417dAD #csentpdsc      s                   like($itpdsc)
417dAD #csentwhdp      s                   like($itwhdp)
417dAD #csentstyp      s                   like($itstyp)
417dAD #csentdesg      s                   like($itdesg)
417dAD #csentum1       s                   like($itum1)
417dAD #csentflg1      s                   like($itflg1)
417dAD #csentum2       s                   like($itum2)
417dAD #csentumq2      s                   like($itumq2)
417dAD #csentflg2      s                   like($itflg2)
417dAD #csentum3       s                   like($itum3)
417dAD #csentumq3      s                   like($itumq3)
417fAD #csentmitem     s                   like($itmitem)

417dAD #cslotitem      s                   like($ititem)
417dAD #cslottype      s                   like($ittype)
417dAD #cslotdesc      s                   like($itdesc)
417dAD #cslotpdsc      s                   like($itpdsc)
417dAD #cslotwhdp      s                   like($itwhdp)
417dAD #cslotstyp      s                   like($itstyp)
417dAD #cslotdesg      s                   like($itdesg)
417dAD #cslotum1       s                   like($itum1)
417dAD #cslotflg1      s                   like($itflg1)
417dAD #cslotum2       s                   like($itum2)
417dAD #cslotumq2      s                   like($itumq2)
417dAD #cslotflg2      s                   like($itflg2)
417dAD #cslotum3       s                   like($itum3)
417dAD #cslotumq3      s                   like($itumq3)
417dAD #cslotnrpk      s                   like($imnrpk)
417dAD #cslotflgd      s                   like($itflgd)
417nAD #cslotswgt      s                   like($itswgt)
417nAD #cslotcwgt      s                   like($itcwgt)
417fAD #cslotmitem     s                   like($itmitem)

417dAD #cssbitem       s                   like($ititem)
417dAD #cssbtype       s                   like($ittype)
417dAD #cssbdesc       s                   like($itdesc)
417dAD #cssbpdsc       s                   like($itpdsc)
417dAD #cssbwhdp       s                   like($itwhdp)
417dAD #cssbstyp       s                   like($itstyp)
417dAD #cssbdesg       s                   like($itdesg)
417dAD #cssbum1        s                   like($itum1)
417dAD #cssbum2        s                   like($itum2)
417dAD #cssbumq2       s                   like($itumq2)
417dAD #cssbum3        s                   like($itum3)
417dAD #cssbumq3       s                   like($itumq3)

416dAD #whseadj1       s                   like($iqadj1)
416dAD #whseadj2       s                   like($iqadj2)
416dAD #whseadj3       s                   like($iqadj3)
416dAD #whsefix1       s                   like($iqfix1)
416dAD #whsefix2       s                   like($iqfix2)
416dAD #whsefix3       s                   like($iqfix3)
416dAD #whseorg1       s                   like($iqorg1)
416dAD #whseorg2       s                   like($iqorg2)
416dAD #whseorg3       s                   like($iqorg3)
     D #whsestat       s                   like(slstat)

416dAD #fromitem       s                   like($ititem)
416dAD #fromtype       s                   like($ittype)
416dAD #fromumq2       s                   like($itumq2)
416dAD #fromumq3       s                   like($itumq3)
417fAD #frommitem      s                   like($itmitem)

416dAD #toitem         s                   like($ititem)
416dAD #totype         s                   like($ittype)
416dAD #toumq2         s                   like($itumq2)
416dAD #toumq3         s                   like($itumq3)
417fAD #tomitem        s                   like($itmitem)

417iA*----------------------------------------------------------------
417iA*  *DATEOPT  -  Expiration/Entered date options
417iA*----------------------------------------------------------------
417iA*
417iA* Fields
417iA*
417iA*    OPLTDN  -  Letdown transactions.  <1-3>
417iA*    OPODRP  -  On-demand replenishment transactions. <1-3>
417iA*    OPSLTF  -  Slot transfer transactions. <1-3>
417iA*    OPPARC  -  Product put-away - Receiving transactions. <1-3>
417iA*    OPPART  -  Product put-away - Returns transactions. <1-3>
520 A*    OPRCVO  -  Receiving to overflow slot. <1-3>
520 A*    OPRTNO  -  Returns to overflow slot. <1-3>
417iA*
417iA*     Destination options:
417iA*       1=Use From Slot date.
417iA*       2=Use oldest date.
417iA*       3=Use From Slot date if To Slot available qty is zero.
417iA*
417iA*     Note: For Receiving/Returns, substitute date captured during
417iA*           receiving/returns processing for From Slot date.
417iA*
417iA* Data structure
417iA*
417iAD opdta1          ds
417iAD  opltdn                 1      1
417iAD  opodrp                 2      2
417iAD  opsltf                 3      3
417iAD  opparc                 4      4
417iAD  oppart                 5      5
520 AD  oprcvo                 6      6
520 AD  oprtno                 7      7
417iAD  opendd               117    117

412 A*----------------------------------------------------------------
412 A*  *SYSTEM  -  System options.
412 A*----------------------------------------------------------------
412  *
412  * Fields
412  *
412  *    OPEPM   -  Using EPM module (Y,N).
412  *    OPRF    -  Using RF module (Y,N).
412  *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
412  *    OPLETD  -  Print letdown labels (Y,N).
412 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
412 A*    OPRG1C  -  Catch weight low variance percentage.
412 A*    OPRG2C  -  Catch weight high variance percentage.
412 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
412 A*
412 A*----------------------------------------------------------------
412 A
412 AD opdat2          ds
412 AD  opepm                  1      1
412 AD  oprf                   2      2
412 AD  opcapc                 3      3
412 AD  opletd                 4      4
412 AD  opwrnc                 5      5
412 AD  oprg1c                 6      8  1
412 AD  oprg2c                 9     11  1
412 AD  opimpi                12     12
412 AD  opmpck                14     14
412 AD  opten2               117    117
416aA
416aA*----------------------------------------------------------------
416aA*  *ZEROVFY -  Zero verify options
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPVFYV  -  Verify virtual slot using RF (Y,N)
416aA*
416aA* Data structure
416aA*
416aAD opdat3          ds
416aAD  opvfyv                 1      1
416aAD  opten3               117    117

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     D File2DS         ds
     D  f2filename             1      8
     D  f2openind              9      9
     D  f2endoffile           10     10
     D  f2status              11     15  0
     D  f2opercode            16     21
     D  f2routine             22     29
     D  f2stmtnbr             30     37
     D  f2recordcd            38     45
     D  f2messageid           46     52
     D  f2sourceid            53     54

     D File3DS         ds
     D  f3filename             1      8
     D  f3openind              9      9
     D  f3endoffile           10     10
     D  f3status              11     15  0
     D  f3opercode            16     21
     D  f3routine             22     29
     D  f3stmtnbr             30     37
     D  f3recordcd            38     45
     D  f3messageid           46     52
     D  f3sourceid            53     54

416bAD File4DS         ds
416bAD  f4filename             1      8
416bAD  f4openind              9      9
416bAD  f4endoffile           10     10
416bAD  f4status              11     15  0
416bAD  f4opercode            16     21
416bAD  f4routine             22     29
416bAD  f4stmtnbr             30     37
416bAD  f4recordcd            38     45
416bAD  f4messageid           46     52
416bAD  f4sourceid            53     54

416bAD File5DS         ds
416bAD  f5filename             1      8
416bAD  f5openind              9      9
416bAD  f5endoffile           10     10
416bAD  f5status              11     15  0
416bAD  f5opercode            16     21
416bAD  f5routine             22     29
416bAD  f5stmtnbr             30     37
416bAD  f5recordcd            38     45
416bAD  f5messageid           46     52
416bAD  f5sourceid            53     54

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

     C                   eval      $slotinput     = $pdata
     C                   eval      $preturninput  = $preturn
     C                   eval      $pmessageinput = $pmessage

     C                   if        $preturn = '*NOUPDATE*'
     C                   eval      UpdateDakota = *off
     C                   else
     C                   eval      UpdateDakota = *on
     C                   endif

     C                   eval      $slot    = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
500lA
500lA* Get client id.
500lA
500lAC                   call      'GETCLIENT'
500lAC                   parm                    client           10

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   eval      logit = *off
     C                   if        DakotaCall
     C                   exsr      callhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   eval      logit = *off
     C                   if        DakotaCall
     C                   exsr      callhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Force right adjustment of certain fields.

     C                   exsr      rightadj

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   eval      logit = *on
     C                   if        DakotaCall
     C                   exsr      callhost
     C                   endif
     C                   if        UpdateDakota and not error
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      addslot
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*ADDVS'
     C                   eval      logit = *on
     C                   if        UpdateDakota
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      addslot
     C                   endif
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416jAC                   when      $psubcmd = '*ADDXDOCK' and DakotaCall
416jAC                   eval      logit = *on
416jAC                   exsr      callhost

416cAC                   when      $psubcmd = '*ADJUST'    or
416cAC                             $psubcmd = '*ADJUSTORD'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      verifyqtyadj
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyadjust
     C                   endif
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
416cAC                   endif

416uAC                   when      $psubcmd = '*ADJUSTTFR'
416uAC                   if        DakotaCall
416uAC                   exsr      callhost
416uAC                   endif

416cAC                   when      $psubcmd = '*ALC2PCK'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyalc2pck
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416cAC                   when      $psubcmd = '*ALLOCATE'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyallocate
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   eval      logit = *on
     C                   if        DakotaCall
     C                   exsr      callhost
     C                   endif
     C                   if        UpdateDakota and not error
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      savebefore
     C                   exsr      changeslot
     C                   endif
     C                   endif
     C                   endif

416nAC                   when      $psubcmd = '*CHGITEM'
416nAC                   eval      logit = *on
416nAC                   if        DakotaCall
416nAC                   exsr      callhost
416nAC                   endif
416nAC                   if        UpdateDakota and not error
416nAC                   exsr      vfychgitm
416nAC                   endif
416nAC                   if        not error
416nAC                   exsr      changeitem
416nAC                   endif

416cAC                   when      $psubcmd = '*CLSPICK'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyclspick
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416cAC                   when      $psubcmd = '*CLSRCV'    or
417sMC                             $psubcmd = '*CLSRCVADJ' or
417hMC                             $psubcmd = '*CLSRTN'    or
417hMC                             $psubcmd = '*CLSPUTAWY' or
500xAC                             $psubcmd = '*CLSSTGPUT' or
417fMC                             $psubcmd = '*CLSTFRIN'  or
417hMC                             $psubcmd = '*CLSLETIN'  or
417hMC                             $psubcmd = '*CLSPRIN'   or
417hMC                             $psubcmd = '*CLSSSIN'   or
417fAC                             $psubcmd = '*CLSTFICHG' or
417hAC                             $psubcmd = '*CLSLTICHG' or
417hAC                             $psubcmd = '*CLSPRICHG' or
417hAC                             $psubcmd = '*CLSSSICHG'
xxxx C                   eval      $saqty1 = $saqty1
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      verifyrcv
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyclsrcv
     C                   endif
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

417fMC                   when      $psubcmd = '*CLSTFROUT' or
417hAC                             $psubcmd = '*CLSLETOUT' or
417hAC                             $psubcmd = '*CLSPROUT'  or
417hAC                             $psubcmd = '*CLSSSOUT'  or
417fAC                             $psubcmd = '*CLSTFOCHG' or
417hAC                             $psubcmd = '*CLSLTOCHG' or
417hAC                             $psubcmd = '*CLSPROCHG' or
417hAC                             $psubcmd = '*CLSSSOCHG'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyclstfrout
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

510dAC                   when      $psubcmd = '*CRTREPAKP' or
510dAC                             $psubcmd = '*CRTREPAKR'
510dAC                   eval      logit = *on
510dAC                   exsr      vfycrtrepack
510dAC                   if        not error
510dAC                   exsr      crtrepack
510dAC                   endif

     C                   when      $psubcmd = '*CRTXDOCK'
     C                   eval      logit = *on
     C                   exsr      verifygetxdk
     C                   if        not error
     C                   exsr      crtxdock
     C                   endif

500kAC                   when      $psubcmd = '*CRTVPICK'
500kAC                   eval      logit = *on
500kAC                   exsr      vfycrtvpick
500kAC                   if        not error
500kAC                   exsr      crtvpick
500kAC                   endif

     C                   when      $psubcmd = '*DELETE' or
     C                             $psubcmd = '*DELETEI'
     C                   eval      logit = *on
     C                   if        DakotaCall
     C                   exsr      callhost
     C                   endif
     C                   if        UpdateDakota and not error
     C                   exsr      deleteslot
     C                   endif

     C                   when      $psubcmd = '*DELETEX'
     C                   eval      logit = *on
     C                   if        UpdateDakota
     C                   exsr      deleteslot
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

     C                   when      $psubcmd = '*SET2VFY'
     C                   eval      logit = *on
     C                   if        UpdateDakota
     C                   exsr      set2vfy
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

417cAC                   when      $psubcmd = '*ZEROVFY'
417cAC                   eval      logit = *on
417cAC                   if        UpdateDakota
417cAC                   exsr      zerovfy
417cAC                   endif
417cAC                   if        DakotaCall and not error
417cAC                   exsr      callhost
417cAC                   endif

417aMC                   when      $psubcmd = '*GET'     or
417aAC                             $psubcmd = '*GETCHKV'
     C                   eval      logit = *off
     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        not error
     C                   exsr      slot2ds
     C                   endif

417aMC                   when      $psubcmd = '*GETI'     or
417aAC                             $psubcmd = '*GETICHKV'
     C                   eval      logit = *off
     C                   eval      lock = *off
     C                   exsr      getslot1
     C                   if        not error
     C                   exsr      slot2ds
     C                   endif

510dAC                   when      $psubcmd = '*GETREPACK'
510dAC                   eval      logit = *off
510dAC                   exsr      verifygetrpk
510dAC                   if        not error
510dAC                   exsr      getrepack
510dAC                   if        not error
510dAC                   exsr      slot2ds
510dAC                   endif
510dAC                   endif

416jAC                   when      $psubcmd = '*GETXDOCK'
416jAC                   eval      logit = *off
416jAC                   exsr      verifygetxdk
416jAC                   if        not error
416jAC                   exsr      getxdock
416jAC                   if        not error
416jAC                   exsr      slot2ds
416jAC                   endif
416jAC                   endif

500aAC                   when      $psubcmd = '*GETOVRFAV'
500bAC                             or $psubcmd = '*GETITEMAV'
500aAC                   eval      logit = *off
500aAC                   exsr      vfygetovrfav
500aAC                   if        not error
500aAC                   exsr      getovrfav
500aAC                   endif

416bAC                   when      (%subst($psubcmd:1:4) = '*NXT' or
416bAC                              %subst($psubcmd:1:4) = '*PRV') and
416bAC                             (%subst($psubcmd:5:5) = 'ITEM '  or
500 AC                              %subst($psubcmd:5:6) = 'ITEMAV' or
416bAC                              %subst($psubcmd:5:5) = 'OVRF '  or
417gAC                              %subst($psubcmd:5:6) = 'OVRFAV' or
416bAC                              %subst($psubcmd:5:5) = 'PICK '  or
416rAC                              %subst($psubcmd:5:6) = 'PICKAV' or
417aAC                              %subst($psubcmd:5:5) = 'VSLOT'  or
416bAC                              %subst($psubcmd:5:5) = 'SLOT '  or
416bAC                              %subst($psubcmd:5:5) = 'SLOTI')
     C                   eval      logit = *off
416bAC                   exsr      verifynxtprv
416bAC                   if        not error
416bAC                   exsr      nextprev
416bAC                   endif

416cAC                   when      $psubcmd = '*PCK2ALC'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtypck2alc
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416cAC                   when      $psubcmd = '*PICK'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtypick
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416cAC                   when      $psubcmd = '*RECEIVE'  or
417hMC                             $psubcmd = '*PUTAWAY'  or
500xAC                             $psubcmd = '*STAGEPUT' or
417hMC                             $psubcmd = '*RETURN'   or
417fMC                             $psubcmd = '*TFRIN'    or
417fAC                             $psubcmd = '*TFRINCHG' or
417hMC                             $psubcmd = '*LETIN'    or
417hAC                             $psubcmd = '*LETINCHG' or
417hMC                             $psubcmd = '*PRIN'     or
417hAC                             $psubcmd = '*PRINCHG'  or
417hMC                             $psubcmd = '*SSIN'     or
417hAC                             $psubcmd = '*SSINCHG'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      verifyrcv
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyreceive
     C                   endif
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416eAC                   when      $psubcmd = '*SEQPTYRPL'
     C                   eval      logit = *off
416eAC                   exsr      seqprtyrpl

416cAC                   when      $psubcmd = '*STOCK'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtystock
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416fMC                   when      $psubcmd = '*TFROUT' or
417hAC                             $psubcmd = '*LETOUT' or
417hAC                             $psubcmd = '*PROUT' or
417hAC                             $psubcmd = '*SSOUT' or
417fAC                             $psubcmd = '*TFROUTCHG' or
417hAC                             $psubcmd = '*LETOUTCHG' or
417hAC                             $psubcmd = '*PROUTCHG' or
417hAC                             $psubcmd = '*SSOUTCHG'
     C                   eval      logit = *on
416cAC                   if        UpdateDakota
416cAC                   exsr      verifyqty
416cAC                   if        not error
     C                   exsr      savebefore
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtytfrout
     C                   endif
     C                   endif
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

416cAC                   when      $psubcmd = '*VERIFY'    or
416cAC                             $psubcmd = '*VERIFYORD'
     C                   eval      logit = *off
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      verifyqtyadj
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif
416cAC                   endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   eval      logit = *off
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyadd
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   eval      logit = *off
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifychg
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   eval      logit = *off
     C                   exsr      deleteslot
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

417fMC                   when      $psubcmd = '*VERIFYTFI' or
417hAC                             $psubcmd = '*VERIFYLTI' or
417hAC                             $psubcmd = '*VERIFYPRI' or
417hAC                             $psubcmd = '*VERIFYSSI' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG' or
500eAC                             $psubcmd = '*VERIFYPUT' or
500xAC                             $psubcmd = '*VFYSTGPUT' or
500eAC                             $psubcmd = '*VERIFYRTN'
416oAC                   eval      logit = *off
416oAC                   exsr      verifyqty
416oAC                   if        not error
416cAC                   exsr      verifyrcv
416cAC                   if        not error
416cAC                   exsr      qtyreceive
416oAC                   endif
416oAC                   endif
416oAC                   if        DakotaCall and not error
416oAC                   exsr      callhost
416oAC                   endif

417fMC                   when      $psubcmd = '*VERIFYTFO' or
417hAC                             $psubcmd = '*VERIFYLTO' or
417hAC                             $psubcmd = '*VERIFYPRO' or
417hAC                             $psubcmd = '*VERIFYSSO' or
417fAC                             $psubcmd = '*VFYTFOCHG' or
417hAC                             $psubcmd = '*VFYLTOCHG' or
417hAC                             $psubcmd = '*VFYPROCHG' or
417hAC                             $psubcmd = '*VFYSSOCHG'
     C                   eval      logit = *off
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      qtytfrout
416cAC                   endif
416oAC                   if        DakotaCall and not error
416oAC                   exsr      callhost
416oAC                   endif

416nAC                   when      $psubcmd = '*VFYCHGITM'
416nAC                   eval      logit = *off
416nAC                   exsr      vfychgitm
     C                   if        DakotaCall and not error
     C                   exsr      callhost
     C                   endif

     C                   other
     C                   eval      logit = *on
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  Log it

     C                   if        logit
     C                   exsr      writelog
     C                   endif

     *  Make sure that nothing is locked.

     C                   exsr      unlock

     *  We are finished so get out

     C                   eval      $pdata = $slot
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for SLOT1 file.

     C     keysl1        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $slaisl
     C                   kfld                    $slloc
     C                   kfld                    $slrlvl
     C                   kfld                    $slhand
416jA
416jA*  Define partial key for SLOT1 file for xdock lookup
416jA
416jAC     keys1x        klist
     C                   kfld                    $slwhse
     C                   kfld                    #slotwhdp
     C                   kfld                    kyaisl

     *  Define key for SLOT2 file.

     C     keysl2        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kydisp
416bA
416bA*  Define key for SLOT3 file.
416bA
416bAC     keysl3        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slitem
     C                   kfld                    $slstat
     C                   kfld                    $slpick
     C                   kfld                    $slprty
     C                   kfld                    $slexpd
     C                   kfld                    $slentd
     C                   kfld                    $slwhdp
     C                   kfld                    $slstyp
     C                   kfld                    $slaisl
     C                   kfld                    $slpseq
     C                   kfld                    $slrlvl
     C                   kfld                    $slhand
416bA
416bA*  Define partial key for SLOT3 file.
416bA
416bAC     keysl3p1      klist
     C                   kfld                    $slwhse
     C                   kfld                    $slitem
     C                   kfld                    $slstat
416bA
416bA*  Define partial key for SLOT3 file.
416bA
416bAC     keysl3p2      klist
     C                   kfld                    $slwhse
     C                   kfld                    $slitem
     C                   kfld                    $slstat
     C                   kfld                    $slpick
416jA
416jA*  Define partial key for SLOT3 file for xdock lookup.
416jA
416jAC     keysl3x       klist
     C                   kfld                    $slwhse
     C                   kfld                    #slotitem
     C                   kfld                    kystat
416bA
416bA*  Define partial key for SLOT1/2.
416bA
416bAC     keyslp        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
417eA
417eA*  Define key for SLOTDGT.
417eA
417eAC     keyscd        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sldisp

     *  Define key for VSLOT file.

     C     keyvs         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    slaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand

417qA*  Define key for VSLOT file using parm fields.
417qA
417qAC     keyvs$        klist
417qAC                   kfld                    $slwhse
417qAC                   kfld                    $slwhdp
417qAC                   kfld                    $slaisl
417qAC                   kfld                    $slloc
417qAC                   kfld                    $slrlvl
417qAC                   kfld                    $slhand

     *  Define key for VSLOT2 file.

     C     keyvs2        klist
417mMC                   kfld                    kvwhse
417mMC                   kfld                    kvwhdp
417mMC                   kfld                    kvdisp
417mDC*                  kfld                    slwhse
417mDC*                  kfld                    slwhdp
417mDC*                  kfld                    sldisp

500gA*  Define key for VSLOT2 file for look4slot routine.
500gA
500gAC     keyvs2l4      klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sldisp

417aA*  Define key for VSLOT2 file using parm fields.
417aA*    $sacdsp contains Base slot.
417aA
417aAC     keyvs2$       klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sacdsp

417aA*  Define full key for VSLOT2 file using parm fields.
417aA*    $sacdsp contains Base (Parent) slot.
417aA
417aAC     keyvs2$f      klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sacdsp
     C                   kfld                    $sldisp

     *  Define key for options file, System values.

     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
417cA*
417cA*  Define key to get virtual slot.
417cA*
417cAC     keysl2vs      klist
417cAC                   kfld                    vswhse
417cAC                   kfld                    vswhdp
417cAC                   kfld                    vsdisp

     *   Get system options.

     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM '
     C     keyop         chain     options
 1B  C                   if        not %found
     C                   eval      opmpck = 'N'
 1X  C                   else
     C                   eval      opdat2 = opdata
 1E  C                   endif

     *   Load handstack array with codes (A..Z, AA..AZ, ...)

     C                   eval      k = 0
 1B  C     1             do        27            i
 2B  C     2             do        27            j
     C                   add       1             k
 2E  C                   eval      hnd(k) = ltr(i) + ltr(j)
 2E  C                   enddo
 1E  C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr

     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr

     C                   if        dridept
     C                   call(e)   'DRIDEPT'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        dridesig
     C                   call(e)   'DRIDESIG'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        driitem
     C                   call(e)   'DRIITEM'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        driitemqty
     C                   call(e)   'DRIITEMQTY'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        driprtyrpl
     C                   call(e)   'DRIPRTYRPL'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      0             $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfysdef
     C                   call(e)   'VFYSDEF'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      0             $vwhse
     C                   parm      ' '           $vsdef
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfysstat
     C                   call(e)   'VFYSSTAT'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      ' '           $vstat
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfybld
     C                   call(e)   'VFYBLD'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      ' '           $vbld
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfyactv
     C                   call(e)   'VFYACTV'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      ' '           $vactv
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        vfyadjc
     C                   call(e)   'VFYADJC'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      ' '           $vcode
416aAC                   parm      ' '           $vsys
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  addslot  Add slot record.
     *----------------------------------------------------------------

     C     addslot       begsr

     *  Make sure file is open.

     C                   if        not %open(slot1)
     C                   exsr      openslot1
     C                   if        error
     C                   goto      endaddslot
     C                   endif
     C                   endif

     *  Get current date and time.

     C                   exsr      getdatetime

     *  Clear slot record.

     C                   clear                   slrec

     *  Move information into slot fields.

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = $slwhdp
     C                   eval      sldisp = $sldisp
     C                   eval      slaisl = $slaisl
     C                   eval      slloc  = $slloc
     C                   eval      slrlvl = $slrlvl
     C                   eval      slhand = $slhand
     C                   if        $psubcmd = '*ADDXDK'
     C                   eval      slstyp = 'X'
     C                   eval      slstat = 'XD'
     C                   else
     C                   eval      slstyp = $slstyp
     C                   eval      slstat = $slstat
     C                   endif
     C                   eval      slsdef = $slsdef

     C                   if        $sldesgu
     C                   eval      sldesg = $sldesg
     C                   endif

     C                   if        $slactvu
     C                   eval      slactv = $slactv
     C                   endif

     C                   if        $slbldu
     C                   eval      slbld  = $slbld
     C                   endif

     C                   if        $slpicku
     C                   eval      slpick = $slpick
     C                   else
     C                   eval      slpick = 'N'
     C                   endif

     C                   if        $slpsequ
     C                   eval      slpseq = $slpseq
     C                   endif

     C                   if        $slprtyu
     C                   eval      slprty = $slprty
     C                   endif

     C                   if        $slexpdu
     C                   eval      slexpd = $slexpd
     C                   endif

     C                   if        $slslfdu
     C                   eval      slslfd = $slslfd
     C                   endif

     C                   if        $slrsrvu
     C                   eval      slrsrv = $slrsrv
     C                   endif

     C                   if        $slitemu
     C                   eval      slitem = $slitem
     C                   endif

     *  Set status date & time.

     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime

     *  Set enter date if item is not blank.

     C                   if        slitem <> ' '
     C                   eval      slentd = curdate
     C                   endif

     *  Calculate side.

     C     slloc         div       2             dummy
     C                   mvr                     slside

     *  Add record

     C                   write(e)  slrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Slot" command '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endaddslot
     C                   endif

     C     endaddslot    endsr

     *----------------------------------------------------------------
     *  calcqtys  Calculate slot quantities.
     *----------------------------------------------------------------

     C     calcqtys      begsr

     *  Calculate physical quantity in slot.

     *    Note: The quantities that are used to calculate the physical
     *          slot quantity are part of processes which should be
     *          completed soon. We can not wait until the processes
     *          are closed to say the stock is or isn't there.

     *          For example: A replenishment request can not be refused
     *          because the picks that depleted the slot have not been
     *          closed yet. Timing is everything.

     C                   eval      slphy1 = (slstk1+slrcv1)-(sltfr1+slpck1)
     C                   eval      slphy2 = (slstk2+slrcv2)-(sltfr2+slpck2)
     C                   eval      slphy3 = (slstk3+slrcv3)-(sltfr3+slpck3)

     *  Calculate available quantity in slot.

     C                   eval      slavl1 = slphy1 - slalc1
     C                   eval      slavl2 = slphy2 - slalc2
     C                   eval      slavl3 = slphy3 - slalc3

     *  Calculate adjustable quantity in slot.

     C                   eval      sladj1 = slavl1 - slrcv1
     C                   eval      sladj2 = slavl2 - slrcv2
     C                   eval      sladj3 = slavl3 - slrcv3

     C                   endsr

     *----------------------------------------------------------------
     *  callhost   Call host program.
     *----------------------------------------------------------------

     C     callhost      begsr

500hAC                   goto      endcallhost

     C                   if        UpdateDakota = *off
     C                   eval      $drireturn = '*LEGACY*'
     C                   else
     C                   eval      $drireturn = ' '
     C                   endif

     C                   call(e)   'DRIMAIN2'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      $slot         $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIMAIN2'
     C                                       + '/' + %trim($dricommand)
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      $drireturn <> '*OK'        and
     C                             $drireturn <> '*NOPROGRAM'
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = 'H:' + $drimessage

     C                   endsl

     *  If calling Dakota program already performed the operation
     *    then we ignore any errors from the host.

     C                   if        UpdateDakota = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif

500hMC     endcallhost   endsr

416nA*----------------------------------------------------------------
416nA*  changeitem  Change item in slot - Part 1
416nA*----------------------------------------------------------------
416nA
416nAC     changeitem    begsr

     *  Get & Lock slot.

     C                   eval      lock = *on
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endchangeitem
     C                   endif

     *  Get current date and time.

     C                   exsr      getdatetime

     *  Do adjustment for original item ...

     C                   eval      #slotitem = slitem
     C                   exsr      changeitem2
     C                   if        error
     C                   goto      endchangeitem
     C                   endif

     *  Do adjustment for new item ...

     C                   eval      #slotitem = $saitem
     C                   exsr      changeitem2
     C                   if        error
     C                   goto      endchangeitem
     C                   endif

     *  Finally, update slot record with new item.

     C                   eval      slitem = $saitem
     C                   if        slentd = 0
     C                   eval      slentd = curdate
     C                   endif
     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endchangeitem
     C                   endif

     C     endchangeitem endsr

416nA*----------------------------------------------------------------
416nA*  changeitem2  Change item in slot - Part 2
416nA*----------------------------------------------------------------
416nA
416nAC     changeitem2   begsr

     *  Get item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = #slotitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endchangeitm2
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt

     *  Get corresponding SSB item for original item (if any)

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSSB'
     C                   eval      item# = #slotitem
     C                   exsr      getitem

     C                   if        error

     C                   eval      error = *off
     C                   eval      ssbflag = *off
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     C                   else

     C                   eval      ssbflag = *on
     C                   eval      #ssbitem = $ititem
     C                   eval      #ssbtype = $ittype
     C                   eval      #ssbdesc = $itdesc
     C                   eval      #ssbpdsc = $itpdsc
     C                   eval      #ssbwhdp = $itwhdp
     C                   eval      #ssbstyp = $itstyp
     C                   eval      #ssbdesg = $itdesg
     C                   eval      #ssbum1  = $itum1
     C                   eval      #ssbum2  = $itum2
     C                   eval      #ssbumq2 = $itumq2
     C                   eval      #ssbum3  = $itum3
     C                   eval      #ssbumq3 = $itumq3

     C                   endif

     *  Set adjustment quantities accordingly.

     C                   if        #slotitem = slitem
     C                   eval      $saqty1 = -(slstk1)
     C                   eval      $saqty2 = -(slstk2)
     C                   eval      $saqty3 = -(slstk3)
     C                   else
     C                   eval      $saqty1 = slstk1
     C                   eval      $saqty2 = slstk2
     C                   eval      $saqty3 = slstk3
     C                   endif

     *  Converty adjustment quantities to lowest uom quantitiy.

     C                   if        #slotumq2 <= 0
     C                   eval      #slotumq2 = 1
     C                   endif

     C                   if        #slotumq3 <= 0
     C                   eval      #slotumq3 = 1
     C                   endif

     C                   eval      lowiaqty = ($saqty1 * #slotumq2 * #slotumq3)
     C                                      + ($saqty2 * #slotumq3)
     C                                      + $saqty3

     C                   eval      lowiaorg = 0

     *  Calculate catchweight adjustment.

     C                   if        #slotcwgt <> 'Y'
     C                   eval      $sacwta  = 0
     C                   else
     C                   eval      $sacwta  = (#slotswgt * $saqty1)
     C                                      + ((#slotswgt/#slotumq2) * $saqty2)
     C                                      + (((#slotswgt/#slotumq2)/#slotumq3)
     C                                           * $saqty3)
     C                   endif

     *  Lock itemqty record.

     C                   eval      check4err = *on
     C                   eval      lock = *on
     C                   exsr      getitemqty
     C                   if        error
     C                   eval      $sldispe = '1'
     C                   goto      endchangeitm2
     C                   endif

     *  Update warehouse quantities for original item ...

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endchangeitm2
     C                   endif

     *  Write adjustment and label records.

     C                   exsr      writeadj
510aA
510aA*  Update slot date quantites.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = $saqty1
510aAC                   eval      $uqty2 = $saqty2
510aAC                   eval      $uqty3 = $saqty3
510aAC                   exsr      updslotdte

     C     endchangeitm2 endsr

     *----------------------------------------------------------------
     *  changeslot  Change slot record.
     *----------------------------------------------------------------

     C     changeslot    begsr

     *  Get & lock slot information.

     C                   eval      lock = *on
     C                   exsr      getslot1
     C                   if        error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slaisle = '1'
     C                   eval      $slloce = '1'
     C                   eval      $slrlvle = '1'
     C                   eval      $slhande = '1'
     C                   goto      endchangeslot
     C                   endif

     *  Get current date and time.

     C                   exsr      getdatetime

     *  If status changed, set status date and time.

     C                   if        $slstatu and $slstat <> slstat
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   eval      $slsdteu = *off
     C                   eval      $slstimu = *off
     C                   endif

     *  If status changed from Active to inactive ...
     *    Warehouse hold quantitiy must be increased.

     C                   if        slstat = 'A'
     C                   if        $slstatu and
     C                             $slstat <> 'A' and
     C                             $slstat <> 'V' and
     C                             $slstat <> 'Z'

     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#

416mAC                   eval      #whsestat = $slstat

416mAC                   eval      #whsefix1 = 0
416mAC                   eval      #whsefix2 = 0
416mAC                   eval      #whsefix3 = 0

416mAC                   eval      #whseadj1 = slstk1
416mAC                   eval      #whseadj2 = slstk2
416mAC                   eval      #whseadj3 = slstk3

416mAC                   eval      #whseorg1 = 0
416mAC                   eval      #whseorg2 = 0
416mAC                   eval      #whseorg3 = 0

416mAC                   eval      savesubcmd = $psubcmd
416mAC                   eval      $psubcmd   = '*HOLD'

416mAC                   exsr      qtywhse

416mAC                   eval      $psubcmd   = savesubcmd

416mAC                   if        error
416mAC                   goto      endchangeslot
416mAC                   endif

     C                   endif
     C                   endif

     *  If status changed from inactive to Active ...
     *    Warehouse hold quantitiy must be decreased.

     C                   if        slstat <> 'A' and
     C                             slstat <> 'V' and
     C                             slstat <> 'Z'
     C                   if        $slstatu and $slstat = 'A'

     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#

416mAC                   eval      #whsestat = $slstat

416mAC                   eval      #whsefix1 = 0
416mAC                   eval      #whsefix2 = 0
416mAC                   eval      #whsefix3 = 0

416mAC                   eval      #whseadj1 = -(slstk1)
416mAC                   eval      #whseadj2 = -(slstk2)
416mAC                   eval      #whseadj3 = -(slstk3)

416mAC                   eval      #whseorg1 = 0
416mAC                   eval      #whseorg2 = 0
416mAC                   eval      #whseorg3 = 0

416mAC                   eval      savesubcmd = $psubcmd
416mAC                   eval      $psubcmd   = '*HOLD'

416mAC                   exsr      qtywhse

416mAC                   eval      $psubcmd   = savesubcmd

416mAC                   if        error
416mAC                   goto      endchangeslot
416mAC                   endif

     C                   endif
     C                   endif

     *  Move information into slot fields.

     C                   if        $slwhseu
     C                   eval      slwhse = $slwhse
     C                   endif

     C                   if        $slwhdpu
     C                   eval      slwhdp = $slwhdp
     C                   endif

     C                   if        $sldispu
     C                   eval      sldisp = $sldisp
     C                   endif

     C                   if        $slaislu
     C                   eval      slaisl = $slaisl
     C                   endif

     C                   if        $sllocu
     C                   eval      slloc  = $slloc
     C                   endif

     C                   if        $slrlvlu
     C                   eval      slrlvl = $slrlvl
     C                   endif

     C                   if        $slhandu
     C                   eval      slhand = $slhand
     C                   endif

     C                   if        $slstypu
     C                   eval      slstyp = $slstyp
     C                   endif

     C                   if        $slstatu
     C                   eval      slstat = $slstat
     C                   endif

     C                   if        $slsdteu
     C                   eval      slsdte = $slsdte
     C                   endif

     C                   if        $slstimu
     C                   eval      slstim = $slstim
     C                   endif

     C                   if        $slsdefu
     C                   eval      slsdef = $slsdef
     C                   endif

     C                   if        $sldesgu
     C                   eval      sldesg = $sldesg
     C                   endif

     C                   if        $slactvu
     C                   eval      slactv = $slactv
     C                   endif

     C                   if        $slbldu
     C                   eval      slbld  = $slbld
     C                   endif

     C                   if        $slpicku
     C                   eval      slpick = $slpick
     C                   endif

     C                   if        $slpsequ
     C                   eval      slpseq = $slpseq
     C                   endif

     C                   if        $slprtyu
     C                   eval      slprty = $slprty
     C                   endif

     C                   if        $slentdu
     C                   eval      slentd = $slentd
     C                   endif

     C                   if        $slexpdu
     C                   eval      slexpd = $slexpd
     C                   endif

     C                   if        $slslfdu
     C                   eval      slslfd = $slslfd
     C                   endif

     C                   if        $slrsrvu
     C                   eval      slrsrv = $slrsrv
     C                   endif

     C                   if        $slitemu
     C                   eval      slitem = $slitem
     C                   endif

     *  Always recalculate 'side' field.

     C     slloc         div       2             dummy
     C                   mvr                     slside

     *  If status is 'V' make sure fields are cleaned up.

     C                   if        slstat = 'V'
     C                   eval      slitem = ' '
     C                   eval      slentd = 0
     C                   eval      slexpd = 0
     C                   eval      slprty = 0
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     C                   endif

     *  Update record

     C                   update(e) slrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Slot" command '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'
     C                                       + '-' + f1messageid

     C                   goto      endchangeslot
     C                   endif
510aA
510aA*  Delete slot date quantities.
510aA
510aAC                   if        slstat = 'V'
510aAC                   exsr      deleteslotdte
510aAC                   endif

     C     endchangeslot endsr

417aA*----------------------------------------------------------------
417aA*  check4virtual  Check if slot has an associated virtual slot.
417aA*----------------------------------------------------------------
417aA
417aAC     check4virtual begsr

     C                   eval      found = *off

     *  Make sure appropriate file is open.

417aAC                   exsr      openvslot2
417aAC                   if        error
417aAC                   goto      endchk4virt
417aaC                   endif

     *  See if item is in virtual slot.

     C     keyvs2$       setll     vslot2
     C                   dow       forever = forever

     C     keyvs2$       reade     vslot2
     C                   if        %eof
     C                   leave
     C                   endif

     C                   eval      lock = *off
     C                   eval      kywhse = vswhse
     C                   eval      kywhdp = vswhdp
     C                   eval      kydisp = vsdisp
     C                   exsr      getslot2

     C                   if        error
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   iter
     C                   endif

     C                   if        slstat = 'V' or  slstat = 'Z'
     C                   iter
     C                   endif

     C                   eval      found = *on
     C                   leave

     C                   enddo

     C                   if        found
     C                   eval      $sfvirt = 'Y'
     C                   else
     C                   eval      $sfvirt = 'N'
     C                   endif

     C     endchk4virt   endsr

416cA*----------------------------------------------------------------
416cA*  checkstatus  Check if slot status should change.
416cA*----------------------------------------------------------------
416cA
416cAC     checkstatus   begsr

     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnewstat         2
     C                   parm                    $creturn          8

     C                   if        $creturn  = '*CHANGED'
     C                   eval      slstat = $cnewstat
     C                   exsr      getdatetime
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   if        slstat = 'A'
     C                   eval      slentd = curdate
     C                   endif
     C                   endif

     C     endchkstat    endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $slwhsee = '1'
     C                   eval      $slwhsee = '0'
     C                   endif

     C                   if        $slwhdpe = '1'
     C                   eval      $slwhdpe = '0'
     C                   endif

     C                   if        $slaisle = '1'
     C                   eval      $slaisle = '0'
     C                   endif

     C                   if        $slloce = '1'
     C                   eval      $slloce = '0'
     C                   endif

     C                   if        $slrlvle = '1'
     C                   eval      $slrlvle = '0'
     C                   endif

     C                   if        $slhande = '1'
     C                   eval      $slhande = '0'
     C                   endif

417dAC                   if        $slsidee = '1'
417dAC                   eval      $slsidee = '0'
417dAC                   endif

     C                   if        $sldispe = '1'
     C                   eval      $sldispe = '0'
     C                   endif

     C                   if        $slstype = '1'
     C                   eval      $slstype = '0'
     C                   endif

     C                   if        $slstate = '1'
     C                   eval      $slstate = '0'
     C                   endif

417dAC                   if        $slsdtee = '1'
417dAC                   eval      $slsdtee = '0'
417dAC                   endif

417dAC                   if        $slstime = '1'
417dAC                   eval      $slstime = '0'
417dAC                   endif

     C                   if        $slsdefe = '1'
     C                   eval      $slsdefe = '0'
     C                   endif

     C                   if        $sldesge = '1'
     C                   eval      $sldesge = '0'
     C                   endif

     C                   if        $slactve = '1'
     C                   eval      $slactve = '0'
     C                   endif

     C                   if        $slblde = '1'
     C                   eval      $slblde = '0'
     C                   endif

     C                   if        $slpicke = '1'
     C                   eval      $slpicke = '0'
     C                   endif

     C                   if        $slpseqe = '1'
     C                   eval      $slpseqe = '0'
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      $slprtye = '0'
     C                   endif

417dAC                   if        $slentde = '1'
417dAC                   eval      $slentde = '0'
417dAC                   endif

417dAC                   if        $slexpde = '1'
417dAC                   eval      $slexpde = '0'
417dAC                   endif

     C                   if        $slslfde = '1'
     C                   eval      $slslfde = '0'
     C                   endif

     C                   if        $slrsrve = '1'
     C                   eval      $slrsrve = '0'
     C                   endif

     C                   if        $sliteme = '1'
     C                   eval      $sliteme = '0'
     C                   endif

417dAC                   if        $saiteme = '1'
417dAC                   eval      $saiteme = '0'
417dAC                   endif

417dAC                   if        $saqty1e = '1'
417dAC                   eval      $saqty1e = '0'
417dAC                   endif

417dAC                   if        $saqty2e = '1'
417dAC                   eval      $saqty2e = '0'
417dAC                   endif

417dAC                   if        $saqty3e = '1'
417dAC                   eval      $saqty3e = '0'
417dAC                   endif

417dAC                   if        $saorg1e = '1'
417dAC                   eval      $saorg1e = '0'
417dAC                   endif

417dAC                   if        $saorg2e = '1'
417dAC                   eval      $saorg2e = '0'
417dAC                   endif

417dAC                   if        $saorg3e = '1'
417dAC                   eval      $saorg3e = '0'
417dAC                   endif

417dAC                   if        $sacwtae = '1'
417dAC                   eval      $sacwtae = '0'
417dAC                   endif

417dAC                   if        $sacodee = '1'
417dAC                   eval      $sacodee = '0'
417dAC                   endif

417dAC                   if        $samemoe = '1'
417dAC                   eval      $samemoe = '0'
417dAC                   endif

417dAC                   if        $saciteme = '1'
417dAC                   eval      $saciteme = '0'
417dAC                   endif

417eAC                   if        $scddgte = '1'
417eAC                   eval      $scddgte = '0'
417eAC                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  crtprtyrpl   Create priority replenishment
416bA*----------------------------------------------------------------

416bAC     crtprtyrpl    begsr

     *  Initialize data structure

     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#

     *  Initialize fields

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = $slwhse

     C                   eval      $pritemu = *on
     C                   eval      $pritem  = $slitem

     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = $slwhdp

     C                   eval      $prslotu = *on
     C                   eval      $prslot  = $sldisp

     C                   eval      $prqtynu = *on
     C                   eval      $prqtyn  = %abs($slavl1)

     C                   eval      $prfillu = *on
416lDC**                 eval      $prfill  = 'N'
416lMC                   eval      $prfill  = 'Y'

     *  Call program to create priority replenishments.

     *  Note: the priority replenishment program will send back a
     *        non-*OK return code explaining why a replenishment
     *        couldn't be created, as well as errors, of course.
     *        Since, creating a priority replenishment is not our
     *        primary concern, we ignore all return codes.

     C                   eval      driprtyrpl = *on
     C                   call(e)   'DRIPRTYRPL'
416eMC                   parm      '*CRTRPLSEQ'  $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $prtyrpl      parm      $prtyrpl      $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIPRTYRPL'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  crtvirtual  Create virtual slot
     *
     *    Routine was called ZZCKNS in older programs.
     *
     *----------------------------------------------------------------

     C     crtvirtual    begsr
     C                   eval      error = *off
     C                   eval      newvs = *off
     C                   eval      vslotcreated = *off

     *   IF WE WANT VIRTUAL PICK SLOT, COMMENT OUT THE NEXT IF.
     *   Get out if physical slot is a pick slot so we do not
     *   create virtual pick slots.

500kA*   Allowed for *CRTVPICK.

JOR AC                   if        client <> jordanos
VGO AC                             and client <> vigo
     C                   if        slpick = 'Y'
500kAC                             and $psubcmd  <> '*CRTVPICK'
PCKdAC                             and client <> Packers
PCKdA*
PCKdA*      Packer's does not want to crete virtual pick slots
PCKdA*      if slot is reserved.
PCKdAC                             or  client = Packers
PCKdAC                             and slpick = 'Y'
PCKdAC                             and slrsrv = 'Y'
PCKdA*
     C                   eval      error = *on
     C                   eval      $preturn = 'VRTNOTALWP'
     C                   exsr      getmsg
     C                   goto      endcrtvirtual
     C                   endif

JOR AC                   endif

     *  Verify that the # of pick slots doesn't exceed maximum for item.
     *    (Force status to 'Z' for verification purposes).

     C                   eval      slstat = 'Z'
     C                   exsr      verifypick
     C                   if        error
     C                   goto      endcrtvirtual
     C                   endif

     *   Get out if physical slot already uses both
     *   positions of handstack field.

     C                   if        %subst(slhand:1:1) <> ' '
     C                   eval      error = *on
     C                   eval      $preturn = 'VRTNOTALWH'
     C                   exsr      getmsg
     C                   goto      endcrtvirtual
     C                   endif

     *   Set handstack flag for later use.

     C                   if        slhand <> ' '
     C                   eval      flaghs = *on
     C                   else
     C                   eval      flaghs = *off
     C                   endif

     *   Loop & increment handstack to find new v-slot to create.

     C                   eval      k = 0

510bDC*                  dow       k <= 702
510bMC                   dow       k < 702
     C                   eval      k = k + 1

     *     If physical slot had handstack then limit hs we can use.

 4B  C                   if        flaghs and
 5B  C                             %subst(hnd(k):1:1) <> %subst(slhand:2:1)
 3I  C                   iter
 5E  C                   endif

     C                   call      'FRMTVS'
     C                   parm                    $sldisp
     C                   parm                    flaghs
     C                   parm      hnd(k)        $vhand            2
     C                   parm      ' '           $vdisp           12

     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $vdisp
     C                   eval      check4err = *on
     C                   exsr      getslot2

 4B  C                   if        error
     C                   eval      newvs = *on
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
 3L  C                   leave
 4X  C                   endif

 3E  C                   enddo

     *  If unused virtual slot number not found, then get out.

     C                   if        not newvs
     C                   eval      error = *on
     C                   eval      $preturn = 'VRTNOTALWU'
     C                   exsr      getmsg
     C                   goto      endcrtvirtual
     C                   endif

     *  Otherwise, create virtual slot.

     *    Re-retrieve base slot.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endcrtvirtual
     C                   endif

416oA*    If we are only verifying, then we just fake the create.

416oAC                   if        $psubcmd = '*VERIFYTFI'
417gAC                             or $psubcmd = '*VERIFYLTI'
417gAC                             or $psubcmd = '*VERIFYPRI'
417gAC                             or $psubcmd = '*VERIFYSSI'
417gAC                             or $psubcmd = '*VFYTFICHG'
417hAC                             or $psubcmd = '*VFYLTICHG'
417hAC                             or $psubcmd = '*VFYPRICHG'
417hAC                             or $psubcmd = '*VFYSSICHG'
500eAC                             or $psubcmd = '*VERIFYPUT'
500xAC                             or $psubcmd = '*VFYSTGPUT'
500eAC                             or $psubcmd = '*VERIFYRTN'
416oAC                   eval      vslotcreated = *on
416oAC                   goto      endcrtvirtual
416oAC                   endif

     *    Initialize some fields and create new virtual slot.

     *      Get values from base slot.

     C                   eval      $slaislu= *on
     C                   eval      $slaisl = slaisl
     C                   eval      $sllocu = *on
     C                   eval      $slloc  = slloc
     C                   eval      $slrlvlu= *on
     C                   eval      $slrlvl = slrlvl
     C                   eval      $slsideu= *on
     C                   eval      $slside = slside
     C                   eval      $slstypu= *on
     C                   eval      $slstyp = slstyp
     C                   eval      $slsdefu= *on
     C                   eval      $slsdef = slsdef
     C                   eval      $sldesgu= *on
     C                   eval      $sldesg = sldesg
     C                   eval      $slactvu= *on
     C                   eval      $slactv = slactv
     C                   eval      $slbldu = *on
     C                   eval      $slbld  = slbld
     C                   eval      $slpicku= *on
     C                   eval      $slpick = slpick
     C                   eval      $slpsequ= *on
     C                   eval      $slpseq = slpseq

     *      Clear some values.

     C                   eval      savedisp  = $sldisp

     C                   eval      saveexpdu = $slexpdu
     C                   eval      saveexpd  = $slexpd
     C*                  eval      $slexpdu  = *off
     C*                  eval      $slexpd   = 0

     C                   eval      saveslfdu = $slslfdu
     C                   eval      saveslfd  = $slslfd
     C*                  eval      $slslfdu  = *off
     C*                  eval      $slslfd   = 0

     C                   eval      saveprtyu = $slprtyu
     C                   eval      saveprty  = $slprty
     C*                  eval      $slprtyu  = *off
     C*                  eval      $slprty   = 0

     *      Set values unique to the virtual slot.

     C                   eval      $slitemu= *on
510dAC                   if        $psubcmd = '*CRTREPAKP'
510dAC                             or $psubcmd = '*CRTREPAKR'
510dAC                   eval      $slitem = #sentitem
510dAC                   else
     C                   eval      $slitem = $saitem
510dAC                   endif
     C                   eval      $slhandu= *on
     C                   eval      $slhand = $vhand
     C                   eval      $sldispu= *on
     C                   eval      $sldisp = $vdisp
     C                   eval      $slstatu= *on
510dAC                   if        $psubcmd = '*CRTREPAKP'
510dAC                             or $psubcmd = '*CRTREPAKR'
510dAC                   eval      $slstat = 'RP'
510dAC                   else
     C                   eval      $slstat = 'A'
510dAC                   endif
PCKcA*
PCKcAC                   if        client = Packers
PCKcA*      Force any putaway to have save slot status as Base slot.
PCKcAC                   if        $psubcmd = '*PUTAWAY'
PCKcAC                             and slstat = 'SO'
PCKcAC                   eval      $slstat = 'SO'
PCKcAC                   endif
PCKcA*
PCKcAC                   endif
PCKcA*
     C                   eval      $slrsrvu= *on
     C                   eval      $slrsrv = 'V'

     *      Create the virtual slot.

     C                   exsr      addslot
     C                   if        not error
     C                   eval      vslotcreated = *on
     C                   exsr      writelog
     C                   exsr      crtvslot
     C                   endif

     *      Restore values.

     C                   eval      $slexpdu = saveexpdu
     C                   eval      $slexpd  = saveexpd
     C                   eval      $slslfdu = saveslfdu
     C                   eval      $slslfd  = saveslfd
     C                   eval      $slprtyu = saveprtyu
     C                   eval      $slprty  = saveprty

     C     endcrtvirtual endsr

500kA*----------------------------------------------------------------
500kA*  crtvpick   Create Virtual Pick slot.
500kA*----------------------------------------------------------------

     C     crtvpick      begsr

     C                   eval      $saitem = $slitem
     C                   exsr      crtvirtual
     C                   if        error
     C                   goto      endcrtvpick
     C                   endif

     C                   eval      $preturn = 'VRTPCKCRT'
     C                   exsr      getmsg

     C     endcrtvpick   endsr


     *----------------------------------------------------------------
     *  crtvslot   Create vslot record to connect virtual with base
     *----------------------------------------------------------------

     C     crtvslot      begsr

417qA* See if vslot exists.
417qA*   It shouldn't but we want to protect against an orphan rec.
417qA
417qAC                   eval      lock = *on
417qAC                   eval      check4err = *off
417qAC                   exsr      getvslot

     * Initialize fields.

     C                   eval      vswhse = $slwhse
     C                   eval      vswhdp = $slwhdp
     C                   eval      vsaisl = $slaisl
     C                   eval      vsloc  = $slloc
     C                   eval      vsrlvl = $slrlvl
     C                   eval      vshand = $slhand
     C                   eval      vsdisp = $sldisp
     C                   eval      vspdis = savedisp
     C                   eval      vscdte = $slsdte
     C                   eval      vsctim = $slstim

417qM* Update/Create vslot record.

417qAC                   if        not error
417qAC                   update(e) vsrec
417qAC                   if        %error
417qAC                   eval      error = *on
417qAC                   eval      $preturn = 'ERRUPDVS'
417qAC                   eval      $pmessage = 'Error on "Update '
417qAC                                       + 'VSlot" command '
417qAC                                       + '('
417qAC                                       + %Trim(%editc($slwhse:'Z'))
417qAC                                       + '/'
417qAC                                       + %trim($slwhdp)
417qAC                                       + '/'
417qAC                                       + %trim($sldisp)
417qAC                                       + ')'
417qAC                                       + '-' + f3messageid
417qAC                   goto      endcrtvslot
417qAC                   endif
417qAC                   else
417qAC                   eval      error = *off
     C                   write(e)  vsrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDVS'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'VSlot" command '
     C                                       + '('
     C                                       + %Trim(%editc($slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($slwhdp)
     C                                       + '/'
     C                                       + %trim($sldisp)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   goto      endcrtvslot
     C                   endif
417qAC                   endif

     C     endcrtvslot   endsr

510dA*----------------------------------------------------------------
510dA*  crtrepack   Create repack slot for item.
510dA*----------------------------------------------------------------

     C     crtrepack     begsr

     *  Try and create a virtual slot.

     C                   exsr      crtvirtual
     C                   if        error
     C                   goto      endcrtrepack
     C                   endif

     *  Move slot fields into data structure.

     C                   exsr      slot2ds

     C     endcrtrepack  endsr

     *----------------------------------------------------------------
     *  crtxdk   Create crossdock slot for item.
     *----------------------------------------------------------------

     C     crtxdock      begsr

     *  See if xdock slot already exists for item.

     C                   exsr      getxdock
     C                   if        not error
     C                   exsr      slot2ds
     C                   eval      $preturn = 'XDKEXIST'
     C                   exsr      getmsg
     C                   goto      endcrtxdock
     C                   else
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif

     *  Make sure file is open.

     C                   if        not %open(slot1)
     C                   exsr      openslot1
     C                   if        error
     C                   goto      endcrtxdock
     C                   endif
     C                   endif

     *  Find next available XDK slot to use.

     C                   z-add     1             tmploc
     C                   move      'XDK'         kyaisl
     C     keys1x        setll     slot1
 1B  C                   dow       forever = forever
     C     keys1x        reade(n)  slot1
 2B  C                   if        %eof or slloc > tmploc
 1L  C                   leave
 2E  C                   endif
 2E  C                   eval      tmploc = tmploc + 1
 1E  C                   enddo

     *  Get current date and time.

     C                   exsr      getdatetime

     *  Clear slot record.

     C                   clear                   slrec

     *  Move information into slot fields.

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = #slotwhdp
     C                   eval      slaisl = 'XDK'
     C                   eval      slloc  = tmploc
     C                   eval      slrlvl = 1
     C                   eval      slhand = ' '
     C                   eval      slstyp = 'X'
     C                   eval      slpseq = tmploc
     C                   eval      slitem = #slotitem
     C                   eval      slstat = 'XD'
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slprty = 0
     C                   eval      slentd = curdate

     C                   if        $slexpdu
     C                   eval      slexpd = $slexpd
     C                   endif

     C     slloc         div       2             dummy
     C                   mvr                     slside

     *    Format display slot.

     C                   call      'FRMTSL'
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    slstyp
     C                   parm                    slpseq
     C                   parm                    sldisp

     *  Add record

     C                   write(e)  slrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDXDK'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'XDK" command '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endcrtxdock
     C                   endif

     *  Move slot fields into data structure.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     *  When called from Dakota, send *ADDXDOCK to host.

     C                   if        DakotaCall
     C                   eval      savesubcmd = $psubcmd
     C                   eval      $psubcmd   = '*ADDXDOCK'
     C                   exsr      callhost
     C                   eval      $psubcmd   = savesubcmd
     C                   if        $preturn <> '*OK'
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   endif

     C     endcrtxdock   endsr

417cA*----------------------------------------------------------------
417cA*  deletecrossdk  Delete associated crossdk records.
417cA*----------------------------------------------------------------
417cA
417cAC     deletecrossdk begsr
     C                   eval      error = *off

     *  Open crossdk file.

     C                   exsr      opencrossdk
     C                   if        error
     C                   goto      enddltcrossdk
     C                   endif

     *  Delete special order record(s)

417mAC                   eval      kvwhse = slwhse
417mAC                   eval      kvwhdp = slwhdp
417mAC                   eval      kvdisp = sldisp
     C     keyvs2        setll     crossdk
 3B  C                   dou       forever <> forever
     C     keyvs2        reade     cdrec
 4B  C                   if        %eof
 3L  C                   leave
 4E  C                   endif
     C                   delete    cdrec
 3E  C                   enddo

     C     enddltcrossdk endsr

     *----------------------------------------------------------------
     *  deleteslot  Delete slot record.
     *----------------------------------------------------------------

     C     deleteslot    begsr
     C                   eval      error = *off

     *  Get and lock slot.

417cAC                   if        $psubcmd <> '*ZEROVFY'

     C                   if        $psubcmd = '*DELETE'  or
     C                             $psubcmd = '*DELETEI' or
     C                             $psubcmd = '*DELETEX'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif

     C                   if        $psubcmd = '*DELETE' or
416kMC                             $psubcmd = '*DELETEX' or
416kAC                             $psubcmd = '*VERIFYDEL'
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   else
     C                   exsr      getslot1
     C                   endif

     C                   if        error
     C                   goto      enddel
     C                   endif

417cAC                   endif

     *  Check for quantity.

     C                   if        $psubcmd <> '*DELETEX'
417cAC                             and $psubcmd <> '*ZEROVFY'
     C                   if        slstk1 <> 0 or
     C                             slstk2 <> 0 or
     C                             slstk3 <> 0 or
     C                             slalc1 <> 0 or
     C                             slalc2 <> 0 or
     C                             slalc3 <> 0 or
     C                             sltfr1 <> 0 or
     C                             sltfr2 <> 0 or
     C                             sltfr3 <> 0 or
     C                             slpck1 <> 0 or
     C                             slpck2 <> 0 or
     C                             slpck3 <> 0 or
     C                             slrcv1 <> 0 or
     C                             slrcv2 <> 0 or
     C                             slrcv3 <> 0
     C                   eval      error = *on
416kMC                   if        $psubcmd = '*DELETE' or
416kAC                             $psubcmd = '*VERIFYDEL'
     C                   unlock    slot2
     C                   endif
     C                   if        $psubcmd = '*DELETEI'
     C                   unlock    slot1
     C                   endif
     C                   eval      $preturn = 'DELQTYEXST'
     C                   exsr      getmsg
     C                   goto      enddel
     C                   endif
     C                   endif

     *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

     *  Delete slot record.

     C                   if        $psubcmd = '*DELETE' or
417cMC                             $psubcmd = '*DELETEX' or
417nMC                             $psubcmd = '*ZEROVFY'
417nDC**                           $psubcmd <> '*ZEROVFY'
     C                   delete(e) slrec2
     C                   else
     C                   delete(e) slrec
     C                   endif
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Slot" '
     C                                       + 'command '
     C                                       + '('
     C                                       + %Trim(%editc($slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($slwhdp)
     C                                       + '/'
     C                                       + %trim($sldisp)
     C                                       + ')'
     C                   if        $psubcmd = '*DELETE'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f2messageid
     C                   else
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid
     C                   endif

     C                   goto      enddel
     C                   endif

     *  Delete corresponding vslot record.

     C                   exsr      deletevslot
417cA
417cA*  Delete crossdock record(s).
417cA
417cAC                   exsr      deletecrossdk
417cA
417cA*  Delete special order record(s).
417cA
417cAC                   exsr      deletespclord
417cA
417cA*  Delete Printed exception record(s).
417cA
417cAC                   exsr      deletevslexcp
510aA
510aA*  Delete slot date record(s).
510aA
510aAC                   exsr      deleteslotdte

     C     enddel        endsr

510aA*----------------------------------------------------------------
510aA*  deleteslotdte  Delete associated slotdte records.
510aA*----------------------------------------------------------------
510aA
510aAC     deleteslotdte begsr

     C                   call      'UPDSLTDTE'
     C                   parm      '*DELETE'     $ucmd             8
     C                   parm      $pprogram     $upgm            10
     C                   parm      #prog         $upgm2           10
     C                   parm      slwhse        $uwhse            3 0
     C                   parm      slwhdp        $uwhdp            5
     C                   parm      sldisp        $uslot           12
     C                   parm      slpick        $upick            1
     C                   parm      ' '           $uitem           15
     C                   parm      ' '           $unewi           15
     C                   parm      0             $uentd            8 0
     C                   parm      0             $uexpd            8 0
     C                   parm      0             $uqty1            5 0
     C                   parm      0             $uqty2            5 0
     C                   parm      0             $uqty3            5 0
     C                   parm      ' '           $urtn             8

     C                   endsr

417cA*----------------------------------------------------------------
417cA*  deletespclord  Delete associated spclord records.
417cA*----------------------------------------------------------------
417cA
417cAC     deletespclord begsr
     C                   eval      error = *off

     *  Open spclord file.

     C                   exsr      openspclord
     C                   if        error
     C                   goto      enddltspclord
     C                   endif

     *  Delete special order record(s)

417mAC                   eval      kvwhse = slwhse
417mAC                   eval      kvwhdp = slwhdp
417mAC                   eval      kvdisp = sldisp
     C     keyvs2        setll     spclord
 2B  C                   dou       forever <> forever
     C     keyvs2        reade     sprec
     C                   if        %eof
 2L  C                   leave
 3E  C                   endif
     C                   delete(e) sprec
 2E  C                   enddo

     C     enddltspclord endsr

     *----------------------------------------------------------------
     *  deletevslot  Delete vslot record.
     *----------------------------------------------------------------

     C     deletevslot   begsr
     C                   eval      error = *off

     C*  Get and lock vslot.

     C                   eval      lock = *on
416rAC                   eval      check4err = *off
     C                   exsr      getvslot

     C*  If there is an error, assume that vslot record doesn't exist.

     C                   if        error
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   goto      endvdel
     C                   endif

      *  Delete vslot record.

     C                   delete(e) vsrec
     C                   if        %error
     C                   eval      $preturn = 'DELERRORV'
     C                   eval      $pmessage = 'Error on "Delete VSlot" '
     C                                       + 'command '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(slaisl)
     C                                       + '/'
     C                                       + %Trim(%editc(slloc:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(slrlvl:'Z'))
     C                                       + '/'
     C                                       + %trim(slhand)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   goto      endvdel
     C                   endif

     C     endvdel       endsr

417cA*----------------------------------------------------------------
417cA*  deletevslexcp  Delete associated vslexcp records.
417cA*----------------------------------------------------------------
417cA
417cAC     deletevslexcp begsr
     C                   eval      error = *off

     *  Open vslexcp file.

     C                   exsr      openvslexcp
     C                   if        error
     C                   goto      enddltvslexcp
     C                   endif

     *  Delete Printed exception record(s).

417mAC                   eval      kvwhse = slwhse
417mAC                   eval      kvwhdp = slwhdp
417mAC                   eval      kvdisp = sldisp
     C     keyvs2        setll     vslexcp
 2B  C                   dow       forever = forever
     C     keyvs2        reade     vslexcp
     C                   if        %eof
 2L  C                   leave
 3E  C                   endif
     C                   if        vxpdte <> 0
     C                   delete(e) vxrec
 3E  C                   endif
 2E  C                   enddo


     C     enddltvslexcp endsr

416cA*----------------------------------------------------------------
416cA*  fixbrkdn  Fix breakdown quantities.
416cA*----------------------------------------------------------------
416cA
416cAC     fixbrkdn      begsr

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     *  Recalculate slot available quantities.

     C                   exsr      calcqtys

     *  First make sure there are no negative available brkdn2/3 qtys.

     *    Breakdown 3 ...

416sMC                   if        #slotumq3 > 0
 2B  C                   dow       slavl3 < 0
     C                   eval      slstk2 = slstk2 - 1
416sMC                   eval      slstk3 = slstk3 + #slotumq3
     C                   eval      slavl2 = slavl2 - 1
416sMC                   eval      slavl3 = slavl3 + #slotumq3
     C                   eval      #whsefix2 = #whsefix2 - 1
416sMC                   eval      #whsefix3 = #whsefix3 + #slotumq3
 2E  C                   enddo
 2E  C                   endif

     *    Breakdown 2 ...

416sMC                   if        #slotumq2 > 0
 2B  C                   dow       slavl2 < 0
     C                   eval      slstk1 = slstk1 - 1
416sMC                   eval      slstk2 = slstk2 + #slotumq2
     C                   eval      slavl1 = slavl1 - 1
416sMC                   eval      slavl2 = slavl2 + #slotumq2
     C                   eval      #whsefix1 = #whsefix1 - 1
416sMC                   eval      #whsefix2 = #whsefix2 + #slotumq2
 2E  C                   enddo
 2E  C                   endif

     *  Now try to "up" available/stock quantities.

     *    Breakdown 3 ...

 2B  C                   if        #slotumq3 > 0
416sMC                   dow       slavl3 >= #slotumq3
416sMC                   eval      slstk3 = slstk3 - #slotumq3
     C                   eval      slstk2 = slstk2 + 1
416sMC                   eval      slavl3 = slavl3 - #slotumq3
     C                   eval      slavl2 = slavl2 + 1
416sMC                   eval      #whsefix3 = #whsefix3 - #slotumq3
     C                   eval      #whsefix2 = #whsefix2 + 1
 2E  C                   enddo
 2E  C                   endif

     *    Breakdown 2 ...

416sMC                   if        #slotumq2 > 0
416sMC                   dow       slavl2 >= #slotumq2
416sMC                   eval      slstk2 = slstk2 - #slotumq2
     C                   eval      slstk1 = slstk1 + 1
416sMC                   eval      slavl2 = slavl2 - #slotumq2
     C                   eval      slavl1 = slavl1 + 1
416sMC                   eval      #whsefix2 = #whsefix2 - #slotumq2
     C                   eval      #whsefix1 = #whsefix1 + 1
 2E  C                   enddo
 2E  C                   endif
 2E
     C                   endsr

416rA*----------------------------------------------------------------
416rA*  getbaseslot  Get corresponding base slot
416rA*----------------------------------------------------------------

     C     getbaseslot   begsr

     C                   eval      $sacdsp = $sldisp

     C                   if        $slrsrv = 'V'
     C                   eval      check4err = *off
     C                   eval      lock = *off
     C                   exsr      getvslot
     C                   if        error
     C                   eval      error = *off
     C                   else
     C                   eval      $sacdsp = vspdis
     C                   endif
     C                   endif

     C                   endsr

417eA*----------------------------------------------------------------
417eA*  getchkdigit  Get slot check digit.
417eA*----------------------------------------------------------------
417eA
417eAC     getchkdigit   begsr
     C                   eval      lockedslotdgt = *off

     C* Open slotdgt file.

     C                   if        not %open(slotdgt)
     C                   exsr      openslotdgt
     C                   if        error
     C                   goto      endgetslotdgt
     C                   endif
     C                   endif

     C* Get slotdgt record

     C                   if        lock
     C     keyscd        chain     slotdgt
     C                   else
     C     keyscd        chain(n)  slotdgt
     C                   endif

     C                   if        not %found
     C                   clear                   scdrec
     C***                eval      error = *on
     C***                eval      $preturn = 'INVLDSLOT'
     C***                exsr      getmsg
     C                   goto      endgetslotdgt
     C                   endif

     C                   if        lock
     C                   eval      lockedslotdgt = *on
     C                   endif

     C     endgetslotdgt endsr

417iA*----------------------------------------------------------------
417iA*  getdateopt   Get Expiration/Entered date options
     *               Default to use Oldest Date.
417iA*----------------------------------------------------------------
417iA
417iAC     getdateopt    begsr

     C                   eval      kywhse = $slwhse
     C                   eval      opcode = '*DATEOPT'
     C     keyop         chain     options
     C                   if        %found
     C                   eval      opdta1 = opdata
     C                   else
     C                   eval      opltdn = '2'
     C                   eval      opodrp = '2'
     C                   eval      opsltf = '2'
     C                   eval      opparc = '2'
     C                   eval      oppart = '2'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  getdept   Get department info.
     *----------------------------------------------------------------

     C     getdept       begsr

     C                   eval      savever# = $wdver#
     C                   clear                   $dept
     C                   eval      $wdver# = savever#

     C                   eval      $wdpmth = '1'
     C                   eval      $wdwhse = $slwhse
     C                   eval      $wdcode = $slwhdp

     C                   eval      dridept = *on
     C                   call(e)   'DRIDEPT'
     C                   parm      '*GET'        $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $dept         parm      $dept         $dridata

     C                   select
     C                   when      %error and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIDEPT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   endsl

     C                   if        $wdpmth = '2'
500xAC                             or $psubcmd = '*STAGEPUT'
500xAC                             or $psubcmd = '*CLSSTGPUT'
500xAC                             or $psubcmd = '*VFYSTGPUT'
     C                   eval      ManualPutaway = *on
     C                   eval      DirectPutaway = *off
     C                   else
     C                   eval      DirectPutaway = *on
     C                   eval      ManualPutaway = *off
     C                   endif

     C     endgetdept    endsr

     *----------------------------------------------------------------
     *  getdesig  Get designation info.
     *----------------------------------------------------------------

     C     getdesig      begsr

     C                   eval      savever# = $dsver#
     C                   clear                   $desig
     C                   eval      $dsver# = savever#

     C                   eval      $dstype = 'H'
     C                   eval      $dscode = desigcode

     C                   eval      dridesig = *on
     C                   call(e)   'DRIDESIG'
     C                   parm      '*GET'        $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $desig        parm      $desig        $dridata

     C                   select
     C                   when      %error and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIDESIG'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   endsl

     C     endgetdesig   endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'ALLZERO'
     C                   eval      $pmessage = 'All quantites and catch '
     C                                       + 'weight values are zero'

     C                   when      $preturn = 'ASLNOTSNT'
     C                   eval      $pmessage = 'Aisle code must be sent'

     C                   when      $preturn = 'BLANKDISP'
     C                   eval      $pmessage = 'Slot display cannot be '
     C                                       + 'blank'

     C                   when      $preturn = 'BLANKITEM'
     C                   eval      $pmessage = 'Item number cannot be blank'

417fAC                   when      $preturn = 'BRKNOTDEF'
417fAC                   eval      $pmessage = 'Breakdown not defined'
417fAC                                       + 'for parent item'

417dAC                   when      $preturn = 'CITMNOTALW'
     C                   eval      $pmessage = 'Corresponding item not  '
     C                                       + 'allowed for '
     C                                       + $psubcmd

     C                   when      $preturn = 'DELQTYEXST'
     C                   eval      $pmessage = 'Slot not deleted - '
     C                                       + 'Quantity exists '
     C                                       + '('
     C                                       + %Trim(%editc($slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($slwhdp)
     C                                       + '/'
     C                                       + %trim($sldisp)
     C                                       + ')'

417jAC                   when      $preturn = 'DIFEXPDTE'
417jAC                   eval      $pmessage = 'Putaway not allowed - '
417jAC                                       + 'Expiration dates different'

     C                   when      $preturn = 'DSPNOTSNT'
     C                   eval      $pmessage = 'Slot display must be sent'

416bAC                   when      $preturn = 'ENTDNOTSNT'
416bAC                   eval      $pmessage = 'Enter date must be sent'

416bAC                   when      $preturn = 'EXPDNOTSNT'
416bAC                   eval      $pmessage = 'Expire date must be sent'

     C                   when      $preturn = 'HNDNOTSNT'
     C                   eval      $pmessage = 'Handstack must be sent'
500kA
500kAC                   when      $preturn = 'INSLOT'
500kAC                   eval      $pmessage = 'Item '
500kAC                                       + %trim($slitem)
500kAC                                       + ' already in slot '
500kAC                                       + %trim($sldisp)

     C                   when      $preturn = 'INVLDBRKQ'
     C                   eval      $pmessage = 'Breakdow quantity not '
     C                                       + 'allowed for item'

417dAC                   when      $preturn = 'INVLDCBRKQ'
417dAC                   eval      $pmessage = 'Breakdown qty not '
417dAC                                       + 'allowed for '
417dAC                                       + 'corresponding item'

417dAC                   when      $preturn = 'INVLDCITYP'
417dAC                   eval      $pmessage = 'Invalid corresponding '
417dAC                                       + 'item type '
417dAC                                       + '(' + #slottype + ') '
417dAC                                       + 'for transfer'

417dAC                   when      $preturn = 'INVLDITYP'
417dAC                   eval      $pmessage = 'Invalid item type '
417dAC                                       + '(' + #slottype + ')'
417dAC                                       + 'for transfer'

     C                   when      $preturn = 'INVLDPICK'
     C                   eval      $pmessage = 'Invalid pick slot option '
     C                                       + '(' + $slpick + ')'

417fAC                   when      $preturn = 'INVLDQTY1'
417fAC                   eval      $pmessage = 'Quantity 1 not multiple of '
417fAC                                       + 'base quantity'

417fAC                   when      $preturn = 'INVLDQTY2'
417fAC                   eval      $pmessage = 'Quantity 2 not multiple of '
417fAC                                       + 'base quantity'

     C                   when      $preturn = 'INVLDRSRV'
     C                   eval      $pmessage = 'Invalid reserve slot '
     C                                       + 'option '
     C                                       + '(' + $slrsrv + ')'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'INVLDSLOT'
     C                   eval      $pmessage = 'Invalid slot '
     C                                       + '('
     C                                       + %Trim(%editc($slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($slwhdp)
     C                                       + '/'
     C                                       + %trim($sldisp)
     C                                       + ')'

     C                   when      $preturn = 'INVLDSTYP'
     C                   eval      $pmessage = 'Invalid section type '
     C                                       + '(' + $slstyp + ')'

     C                   when      $preturn = 'INVLDVSLOT'
     C                   eval      $pmessage = 'Invalid vslot '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(slaisl)
     C                                       + '/'
     C                                       + %Trim(%editc(slloc:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(slrlvl:'Z'))
     C                                       + '/'
     C                                       + %trim(slhand)
     C                                       + ')'

     C                   when      $preturn = 'INVLDVSTAT'
     C                   eval      $pmessage = 'Status cannot be changed '
     C                                       + 'to "V" because quantity '
     C                                       + 'exists'

     C                   when      $preturn = 'INVLDZSTAT'
     C                   eval      $pmessage = 'Status cannot be changed '
     C                                       + 'to "Z" because quantity '
     C                                       + 'exists'

PAK AC                   when      $preturn = 'INVLDPSTAT'
PAK AC                   eval      $pmessage = 'Status cannot be changed '
PAK AC                                       + 'to QA or BL unless slot'
PAK AC                                       + ' is empty'

     C                   when      $preturn = 'ISMISMTCH'
     C                   eval      $pmessage = 'Item dept/styp/desg '
     C                                       + '('
     C                                       + %trim($itwhdp)
     C                                       + '/'
     C                                       + %trim($itstyp)
     C                                       + '/'
     C                                       + %trim($itdesg)
     C                                       + ')'
     C                                       + ' does not match slot'

     C                   when      $preturn = 'ITEMCHG'
     C                   eval      $pmessage = 'Item cannot be changed - '
     C                                       + 'Quantity exists '

417fAC                   when      $preturn = 'ITMNOTCOMP'
417fAC                   eval      $pmessage = 'Normal item and Breakdown '
417fAC                                       + 'item are not compatible'

     C                   when      $preturn = 'ITMNOTSNT'
     C                   eval      $pmessage = 'Item number must be sent'

     C                   when      $preturn = 'LOCNOTSNT'
     C                   eval      $pmessage = 'Location must be sent'

     C                   when      $preturn = 'LVLNOTSNT'
     C                   eval      $pmessage = 'Level must be sent'

     C                   when      $preturn = 'NEGATIVLOC'
     C                   eval      $pmessage = 'Location must be positive'

     C                   when      $preturn = 'NEGATIVLVL'
     C                   eval      $pmessage = 'Level must be positive'

     C                   when      $preturn = 'NEGATIVPSQ'
     C                   eval      $pmessage = 'Picking sequence must be '
     C                                       + 'positive'

     C                   when      $preturn = 'NEGAVLSLT'
     C                   eval      $pmessage = 'Adjustment would make slot '
     C                                       + 'available qty go negative'

     C                   when      $preturn = 'NEGAVLWHS'
     C                   eval      $pmessage = 'Adjustment would make '
     C                                       + 'warehouse available qty '
     C                                       + 'go negative'

     C                   when      $preturn = 'NEGRCVQTY'
     C                   eval      $pmessage = 'Cannot reduce receive qty '
     C                                       + 'for a slot with a '
     C                                       + 'Z or V status'

416nAC                   when      $preturn = 'NEWNOTSNT'
416nAC                   eval      $pmessage = 'New item number must be '
416nAC                                       + 'sent'

416nAC                   when      $preturn = 'NONSTKEXST'
416nAC                   eval      $pmessage = 'Item cannot be changed - '
416nAC                                       + 'Non-Stock qty exists'

     C                   when      $preturn = 'NOTACTIVE'
     C                   eval      $pmessage = 'Slot is not active. Status '
     C                                       + 'is "' + %trim(slstat) + '"'

510dAC                   when      $preturn = 'NOTPARENT'
510dAC                   eval      $pmessage = 'Item '
510dAC                                       + '(type "'
510dAC                                       + %trim(#senttype) + '") '
510dAC                                       + 'is not a Parent for a '
510dAC                                       + 'Repack item.'

510dAC                   when      $preturn = 'NOTREPACK'
510dAC                   eval      $pmessage = 'Item '
510dAC                                       + '(type "'
510dAC                                       + %trim(#senttype) + '") '
510dAC                                       + 'is not a Repack item.'

417cAC                   when      $preturn = 'NOTZROSTAT'
417cAC                   eval      $pmessage = 'Slot not verified - '
417cAC                                       + 'Stat is "'
417cAC                                       + %trim(slstat)
417cAC                                       + '" not "Z" or "V"'

     C                   when      $preturn = 'OPNERRSLT1'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open Slot1 file'

     C                   when      $preturn = 'OPNERRSLT2'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open Slot2 file'

     C                   when      $preturn = 'ORGNOTALW'
     C                   eval      $pmessage = 'Original quantities not '
     C                                       + 'allowed for '
     C                                       + $psubcmd

500aAC                   when      $preturn = 'OVRFNOTAVL'
500aAC                   eval      $pmessage = 'no quantity available '
500aAC                                       + 'in slot '
500aAC                                       + %trim(savedisp)

500aAC                   when      $preturn = 'OVRFNOTFND'
500aAC                   eval      $pmessage = 'item not found in slot '
500aAC                                       + %trim($sldisp)

416bAC                   when      $preturn = 'PCKNOTSNT'
416bAC                   eval      $pmessage = 'Pick flag must be sent'

     C                   when      $preturn = 'PCKOVRFLW'
     C                   eval      $pmessage = 'Maximum pick slots ('
     C                                       + %Trim(%editc($imnrpk:'3'))
     C                                       + ') already defined for item '

416bAC                   when      $preturn = 'PSEQNOTSNT'
416bAC                   eval      $pmessage = 'Pick sequence must be sent'

416bAC                   when      $preturn = 'PRTYNOTSNT'
416bAC                   eval      $pmessage = 'Priority must be sent'

     C                   when      $preturn = 'QTYNOTSNT'
     C                   eval      $pmessage = 'Adjustment qty must be '
     C                                       + 'sent for '
     C                                       + $psubcmd

510dAC                   when      $preturn = 'RPKNOTFND'
510dAC                   eval      $pmessage = 'Repack slot not found for '
510dAC                                       + 'item ('
510dAC                                       + %Trim(%editc($slwhse:'Z'))
510dAC                                       + '/'
510dAC                                       + %trim(#slotwhdp)
510dAC                                       + '/'
510dAC                                       + %trim(#slotitem)
510dAC                                       + ')'

     C                   when      $preturn = 'SLOT1EXIST'
     C                   eval      $pmessage = 'Slot not added - Already '
     C                                       + 'exists ('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(slaisl)
     C                                       + '/'
     C                                       + %Trim(%editc(slloc:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(slrlvl:'Z'))
     C                                       + '/'
     C                                       + %trim(slhand)
     C                                       + ')'

     C                   when      $preturn = 'SLOT2EXIST'
     C                   eval      $pmessage = 'Slot not added - Already '
     C                                       + 'exists ('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'

417jAC                   when      $preturn = 'SLTNOTACTV'
417jAC                   eval      $pmessage = 'Put away not allowed - '
417jAC                                       + 'Slot not at active status'

500kAC                   when      $preturn = 'SLTNOTPICK'
500kAC                   eval      $pmessage = 'Slot must be a Pick slot'

510dAC                   when      $preturn = 'SLTNOTRPK'
510dAC                   eval      $pmessage = 'Slot must be a in Repack area, '
510dAC                                       + 'aisle RPK.'

     C                   when      $preturn = 'STPNOTSNT'
     C                   eval      $pmessage = 'Section type must be sent'

     C                   when      $preturn = 'STSNOTSNT'
     C                   eval      $pmessage = 'Status code must be sent'

     C                   when      $preturn = 'UPDERRSLT2'
     C                   eval      $pmessage = 'Update error occured doing '
     C                                       + %trim($psubcmd)
     C                                       + ' - ' + f2messageid

     C                   when      $preturn = 'UPDSTKERR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'update slot with stock '
     C                                       + 'quantity'

500fAC                   when      $preturn = 'VIRTLSLOT'
500fAC                   eval      $pmessage = 'Base slot must be '
500fAC                                       + 'entered. Slot '
500fAC                                       + %trim($sldisp)
500fAC                                       + ' is a Virtual slot.'

     C                   when      $preturn = 'VRTNOTALWH'
     C                   eval      $pmessage = 'VSlot cannot be created - '
     C                                       + 'double handstack ('
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'

     C                   when      $preturn = 'VRTNOTALWP'
     C                   eval      $pmessage = 'VSlot cannot be created '
     C                                       + 'for a pick slot ('
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'

     C                   when      $preturn = 'VRTNOTALWU'
     C                   eval      $pmessage = 'VSlot cannot be created - '
     C                                       + 'No openings ('
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'

416uAC                   when      $preturn = 'VNOTALLOW'
416uAC                   eval      $pmessage = 'Status code cannot be '
416uAC                                       + 'changed to "V". '

500kAC                   when      $preturn = 'VRTPCKCRT'
500kAC                   eval      $pmessage = 'VSlot '
500kAC                                       + %trim(slwhdp)
500kAC                                       + '/'
500kAC                                       + %trim(sldisp)
500kAC                                       + ' created'

500fAC                   when      $preturn = 'WARNPICK'
500fAC                   eval      $pmessage = 'Older product in stock. '
500fAC                                       + 'Put in overflow.'

     C                   when      $preturn = 'WHDNOTSNT'
     C                   eval      $pmessage = 'Department must be sent'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

416dAC                   when      $preturn = 'WRONGITEM'
416dAC                   eval      $pmessage = 'Item '
416dAC                                       + %trim(#slotitem)
416dAC                                       + ' not found in slot '
416dAC                                       + %trim(slwhdp)
416dAC                                       + '/'
416dAC                                       + %trim(sldisp)
416dAC                                       + '/'
416dAC                                       + %trim(slitem)

416jAC                   when      $preturn = 'XDKEXIST'
416jAC                   eval      $pmessage = 'Xdock slot exists for '
416jAC                                       + 'item ('
416jAC                                       + %Trim(%editc($slwhse:'Z'))
416jAC                                       + '/'
416jAC                                       + %trim(#slotwhdp)
416jAC                                       + '/'
416jAC                                       + %trim(#slotitem)
416jAC                                       + ')'

416jAC                   when      $preturn = 'XDKNOTFND'
416jAC                   eval      $pmessage = 'Xdock slot not found for '
416jAC                                       + 'item ('
416jAC                                       + %Trim(%editc($slwhse:'Z'))
416jAC                                       + '/'
416jAC                                       + %trim(#slotwhdp)
416jAC                                       + '/'
416jAC                                       + %trim(#slotitem)
416jAC                                       + ')'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $slwhse
     C                   eval      $ititem = item#

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getitemqty  Get ItemQty record.
     *----------------------------------------------------------------

     C     getitemqty    begsr
     C                   eval      lockeditemqty = *off

     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#

     C                   eval      $iqwhseu = *on
     C                   eval      $iqwhse = $slwhse
     C                   eval      $iqitemu = *on
     C                   eval      $iqitem = #slotitem

     C                   if        lock
     C                   eval      $drisubcmd = '*GET&LOCK'
     C                   else
     C                   eval      $drisubcmd = '*GET'
     C                   endif

     C                   eval      driitemqty = *on
     C                   call(e)   'DRIITEMQTY'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $itemqty      parm      $itemqty      $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEMQTY'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitemqty
     C                   endsl

     C                   if        lock
     C                   eval      lockeditemqty = *on
     C                   endif

     C     endgetitemqty endsr

500aA*----------------------------------------------------------------
500aA*  getovrfav  Get overflow slot w/available qty for physical slot.
500aA*----------------------------------------------------------------
500aA
500aAC     getovrfav     begsr

     C* Make sure appropriate file is open.

     C                   exsr      openslot3
     C                   if        error
     C                   goto      endgetovrfav
     C                   endif

     C* Set file pointer.

500bAC                   if        $psubcmd = '*GETITEMAV'
500bAC     keysl3p1      setll     slot3
500bAC                   else
     C                   eval      $slpick = 'N'
     C     keysl3p2      setll     slot3
500bAC                   endif

     C* Create read loop.

     C                   eval      found = *off
     C                   eval      noneavail = *off

     C                   dow       forever = forever

     C* Get record.

500bAC                   if        $psubcmd = '*GETITEMAV'
500bAC     keysl3p1      reade(n)  slot3
500bAC                   else
     C     keysl3p2      reade(n)  slot3
500bAC                   endif

     C* Check for eof.

     C                   if        %eof
     C                   eval      $preturn = 'EOF'
     C                   goto      endgetovrfav
     C                   endif

     C* Look for a slot within the physical slot that was sent.

     C                   if        slwhdp <> $slwhdp or
     C                             slaisl <> $slaisl or
     C                             slloc  <> $slloc  or
     C                             slrlvl <> $slrlvl
     C                   iter
     C                   endif

     C* Calculate quantities.

     C                   exsr      calcqtys

     C* See if we need to loop around and try again.

     C                   if        slavl1 <= 0             and
     C                             slavl2 <= 0             and
     C                             slavl3 <= 0
     C                   eval      noneavail = *on
     C                   eval      savedisp  = sldisp
     C                   iter
     C                   endif

     C* Move record fields into data structure.

     C                   eval      found = *on
     C                   exsr      slot2ds

     C                   leave
     C                   enddo

     C                   select

     C* If record was found, then there is nothing else to do.

     C                   when      found

     C* If a record was found but nothing was available,
     C*   Then send back an error message.

     C                   when      noneavail
     C                   eval      error = *on
     C                   eval      $preturn = 'OVRFNOTAVL'
     C                   exsr      getmsg

     C* Otherwise, no record was found, so send back an error message.

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'OVRFNOTFND'
     C                   exsr      getmsg

     C                   endsl

     C     endgetovrfav  endsr

     *----------------------------------------------------------------
     *  getslot1  Get slot info from file SLOT1.
     *----------------------------------------------------------------

     C     getslot1      begsr
     C                   eval      lockedslot1 = *off

     C* Open slot1 file.

     C                   if        not %open(slot1)
     C                   exsr      openslot1
     C                   if        error
     C                   goto      endgetslot1
     C                   endif
     C                   endif

     C* Get slot1 record

     C                   if        lock
     C     keysl1        chain     slot1
     C                   else
     C     keysl1        chain(n)  slot1
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSLOT'
     C                   exsr      getmsg
     C                   goto      endgetslot1
     C                   endif

     C                   if        lock
     C                   eval      lockedslot1 = *on
     C                   endif

     C                   exsr      calcqtys

     C     endgetslot1   endsr

     *----------------------------------------------------------------
     *  getslot2  Get slot info from file SLOT2.
     *----------------------------------------------------------------

     C     getslot2      begsr
     C                   eval      lockedslot2 = *off

     C* Open slot2 file.

     C                   if        not %open(slot2)
     C                   exsr      openslot2
     C                   if        error
     C                   goto      endgetslot2
     C                   endif
     C                   endif


     C* Get slot2 record

     C                   if        lock
     C     keysl2        chain     slot2
     C                   else
     C     keysl2        chain(n)  slot2
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSLOT'
     C                   exsr      getmsg
     C                   goto      endgetslot2
     C                   endif

     C                   if        lock
     C                   eval      lockedslot2 = *on
     C                   endif

     C                   exsr      calcqtys

     C     endgetslot2   endsr

     *----------------------------------------------------------------
     *  getvslot  Get VSLOT record.
     *----------------------------------------------------------------

     C     getvslot      begsr
     C                   eval      lockedvslot = *off

     C* Open vslot file.

     C                   if        not %open(vslot)
     C                   exsr      openvslot
     C                   if        error
     C                   goto      endgetvslot
     C                   endif
     C                   endif

     C* Get vslot record

     C                   if        lock
     C     keyvs         chain     vslot
     C                   else
     C     keyvs         chain(n)  vslot
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
416rAC                   if        check4err = *on
     C                   eval      $preturn = 'INVLDVSLOT'
     C                   exsr      getmsg
416rAC                   endif
     C                   goto      endgetvslot
     C                   endif

     C                   if        lock
     C                   eval      lockedvslot = *on
     C                   endif

416rAC     endgetvslot   tag
416rAC                   eval      check4err = *off
416rMC                   endsr

510dA*----------------------------------------------------------------
510dA*  getrepack  Get repack slot for item.
510dA*----------------------------------------------------------------
510jA
510jAC     getrepack     begsr

     C* Open slot3 file.

     C                   if        not %open(slot3)
     C                   exsr      openslot3
     C                   if        error
     C                   goto      endgetrpk
     C                   endif
     C                   endif

     C* Get repack slot for item.

     C                   eval      kystat = 'RP'
     C     keysl3x       setll     slot3
     C                   dow       forever = forever
     C     keysl3x       reade(n)  slot3

     C                   if        %eof
     C                   eval      error = *on
     C                   eval      $preturn = 'RPKNOTFND'
     C                   exsr      getmsg
     C                   goto      endgetrpk
     C                   endif

     C                   if        slaisl <> 'RPK' or
     C                             slwhdp <> #slotwhdp
     C                   iter
     C                   endif

     C                   leave
     C                   enddo

     C                   exsr      calcqtys

     C     endgetrpk     endsr

416jA*----------------------------------------------------------------
416jA*  getxdock  Get crossdock slot for item.
416jA*----------------------------------------------------------------
416jA
416jAC     getxdock      begsr

     C* Open slot3 file.

     C                   if        not %open(slot3)
     C                   exsr      openslot3
     C                   if        error
     C                   goto      endgetxdk
     C                   endif
     C                   endif

     C* Get crossdock slot for item.

     C                   eval      kystat = 'XD'
     C     keysl3x       setll     slot3
     C                   dow       forever = forever
     C     keysl3x       reade(n)  slot3

     C                   if        %eof
     C                   eval      error = *on
     C                   eval      $preturn = 'XDKNOTFND'
     C                   exsr      getmsg
     C                   goto      endgetxdk
     C                   endif

     C                   if        slaisl <> 'XDK' or
     C                             slwhdp <> #slotwhdp
     C                   iter
     C                   endif

     C                   leave
     C                   enddo

     C                   exsr      calcqtys

     C     endgetxdk     endsr

     *----------------------------------------------------------------
     *  look4slot   Look for item in existing slot
     *
     *    Routine was called ZZCKSL in older programs.
     *
     *----------------------------------------------------------------

     C     look4slot     begsr
     C                   eval      found = *off

     *  Make sure appropriate file is open.

417aAC                   exsr      openvslot2
417aAC                   if        error
417aAC                   goto      endlook4slot
417aaC                   endif

     *  See if item is in base slot (retreived during verify process).

     C                   if        slitem = #slotitem and
     C                             slstat <> 'V' and slstat <> 'Z'
     C                   eval      found = *on
417jDC**                 goto      endlook4slot
417jMC                   goto      l4sbottom
     C                   endif

     *  See if item is in virtual slot.

500gDC**   keyvs2        setll     vslot2
500gMC     keyvs2l4      setll     vslot2
     C                   dow       forever = forever

500gDC**   keyvs2        reade     vslot2
500gMC     keyvs2l4      reade     vslot2
     C                   if        %eof
     C                   leave
     C                   endif

     C                   eval      lock = *off
     C                   eval      kywhse = vswhse
     C                   eval      kywhdp = vswhdp
     C                   eval      kydisp = vsdisp
     C                   exsr      getslot2

     C                   if        error
417qAC                   eval      error = *off
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   iter
     C                   endif

     C                   if        slitem <> #slotitem or
     C                             slstat = 'V' or  slstat = 'Z'
     C                   iter
     C                   endif

     C                   eval      found = *on
     C                   leave

     C                   enddo

417jAC     l4sbottom     tag

417jA*  See if expiration date of putaway matches slot exp date.

417jA*    Date is NOT considered different when ...

417jAC                   select

417jA*    ... Slot is a Pick slot.

417jAC                   when      slpick = 'Y'
417jAC                   eval      difexpdte = *off

417jA*    ... Slot expiration date is zero.

417jAC                   when      slexpd = 0
417jAC                   eval      difexpdte = *off

417jA*    ... Expiration dates are the same (of course).

417jAC                   when      $slexpdu and slexpd = $slexpd
417jAC                   eval      difexpdte = *off

417jA*    ... All quantities are zero.

417jAC                   when      slstk1 = 0 and
417jAC                             slstk2 = 0 and
417jAC                             slstk3 = 0 and
417jAC                             slalc1 = 0 and
417jAC                             slalc2 = 0 and
417jAC                             slalc3 = 0 and
417jAC                             sltfr1 = 0 and
417jAC                             sltfr2 = 0 and
417jAC                             sltfr3 = 0 and
417jAC                             slpck1 = 0 and
417jAC                             slpck2 = 0 and
417jAC                             slpck3 = 0 and
417jAC                             slrcv1 = 0 and
417jAC                             slrcv2 = 0 and
417jAC                             slrcv3 = 0
417jAC                   eval      difexpdte = *off

PCKbAC                   when      client = 'PACKERS'
PCKbAC                             and $slpicke = '4'
PCKbAC                   eval      difexpdte = *off
PCKbAC                   eval      $slpicke = '0'

417jA*    Otherwise, we have different expiration dates.

417jAC                   other
417jAC                   eval      difexpdte = *on

417jAC                   endsl

     C     endlook4slot  endsr

416bA*----------------------------------------------------------------
416bA*  nextprev  Get next/previous slot record.
416bA*----------------------------------------------------------------
416bA
416bAC     nextprev      begsr

     C* Make sure appropriate file is open.

     C                   select

     C                   when      $psubcmd = '*NXTSLOTI' or
     C                             $psubcmd = '*PRVSLOTI'
     C                   exsr      openslot1
     C                   if        error
     C                   goto      endnextprev
     C                   endif

     C                   when      $psubcmd = '*NXTSLOT' or
     C                             $psubcmd = '*PRVSLOT'
     C                   exsr      openslot2
     C                   if        error
     C                   goto      endnextprev
     C                   endif

417aAC                   when      $psubcmd = '*NXTVSLOT' or
417aAC                             $psubcmd = '*PRVVSLOT'
417aAC                   exsr      openslot2
417aAC                   if        error
417aAC                   goto      endnextprev
417aaC                   endif
417aAC                   exsr      openvslot2
417aAC                   if        error
417aAC                   goto      endnextprev
417aaC                   endif

     C                   other
     C                   exsr      openslot3
     C                   if        error
     C                   goto      endnextprev
     C                   endif

     C                   endsl
417lA
417lAC* Set file pointer.
417lA
417lAC                   select
417lA
417lAC                   when      $psubcmd = '*NXTITEM'
500 AC                             or $psubcmd = '*NXTITEMAV'
417lAC                   if        $slpick = ' '
417lAC                   eval      $slpick = *hival
417lAC                   endif
500eAC                   if        $slprty = 0
500eAC                   eval      $slprty = -9
500eAC                   endif
417lAC     keysl3        setgt     slot3
417lA
417lAC                   when      $psubcmd = '*PRVITEM'
417lAC     keysl3        setll     slot3
500bD **
500bDC**                 when      $psubcmd = '*GETOVRFAV'
500bDC**                 eval      $slpick = 'N'
500bDC**   keysl3        setll     slot3
417lA
417lAC                   when      $psubcmd = '*NXTOVRF'
417lAC                             or $psubcmd = '*NXTOVRFAV'
417lAC                   eval      $slpick = 'N'
417lAC     keysl3        setgt     slot3

417lAC                   when      $psubcmd = '*PRVOVRF'
417lAC                   eval      $slpick = 'N'
417lAC     keysl3        setll     slot3
417lA
417lAC                   when      $psubcmd = '*NXTPICK'
417lAC                             or $psubcmd = '*NXTPICKAV'
417lAC                   eval      $slpick = 'Y'
500eAC                   if        $slprty = 0
500eAC                   eval      $slprty = -9
500eAC                   endif
417lAC     keysl3        setgt     slot3
417lA
417lAC                   when      $psubcmd = '*PRVPICK'
417lAC                   eval      $slpick = 'Y'
417lAC     keysl3        setll     slot3
417lA
417lAC                   when      $psubcmd = '*NXTSLOT'
417lAC     keysl2        setgt     slot2
417lA
417lAC                   when      $psubcmd = '*PRVSLOT'
417lAC     keysl2        setll     slot2
417lA
417lAC                   when      $psubcmd = '*NXTSLOTI'
417lAC     keysl1        setgt     slot1
417lA
417lAC                   when      $psubcmd = '*PRVSLOTI'
417lAC     keysl1        setll     slot1
417lA
417lAC                   when      $psubcmd = '*NXTVSLOT'
417lAC     keyvs2$f      setgt     vslot2
417lA
417lAC                   when      $psubcmd = '*PRVVSLOT'
417lAC     keyvs2$f      setll     vslot2
417lA
417lAC                   endsl

416rAC* Create read loop.

416rAC                   dow       forever = forever

     C* Get record.

     C                   select

     C                   when      $psubcmd = '*NXTITEM'
500 AC                             or $psubcmd = '*NXTITEMAV'
417lDC**                 if        $slpick = ' '
417lDC**                 eval      $slpick = *hival
417lDC**                 endif
417lDC**   keysl3        setgt     slot3
     C     keysl3p1      reade(n)  slot3

     C                   when      $psubcmd = '*PRVITEM'
417lDC**   keysl3        setll     slot3
     C     keysl3p1      readpe(n) slot3

     C                   when      $psubcmd = '*NXTOVRF'
417gAC                             or $psubcmd = '*NXTOVRFAV'
500bDC**                           or $psubcmd = '*GETOVRFAV'
417lDC**                 eval      $slpick = 'N'
417lDC**   keysl3        setgt     slot3
     C     keysl3p2      reade(n)  slot3

     C                   when      $psubcmd = '*PRVOVRF'
417lDC**                 eval      $slpick = 'N'
417lDC**   keysl3        setll     slot3
     C     keysl3p2      readpe(n) slot3

     C                   when      $psubcmd = '*NXTPICK'
416rAC                             or $psubcmd = '*NXTPICKAV'
417lDC**                 eval      $slpick = 'Y'
417lDC**   keysl3        setgt     slot3
     C     keysl3p2      reade(n)  slot3

     C                   when      $psubcmd = '*PRVPICK'
417lDC**                 eval      $slpick = 'Y'
417lDC**   keysl3        setll     slot3
     C     keysl3p2      readpe(n) slot3

     C                   when      $psubcmd = '*NXTSLOT'
417lDC**   keysl2        setgt     slot2
     C     keyslp        reade(n)  slot2

     C                   when      $psubcmd = '*PRVSLOT'
417lDC**   keysl2        setll     slot2
     C     keyslp        readpe(n) slot2

     C                   when      $psubcmd = '*NXTSLOTI'
417lDC**   keysl1        setgt     slot1
     C     keyslp        reade(n)  slot1

     C                   when      $psubcmd = '*PRVSLOTI'
417lDC**   keysl1        setll     slot1
     C     keyslp        readpe(n) slot1

417aAC                   when      $psubcmd = '*NXTVSLOT'
417lDC**   keyvs2$f      setgt     vslot2
417aAC     keyvs2$       reade     vslot2

417aAC                   when      $psubcmd = '*PRVVSLOT'
417lDC**   keyvs2$f      setll     vslot2
417aAC     keyvs2$       readpe    vslot2

     C                   endsl

     C* Check for eof.

     C                   if        %eof
     C                   eval      $preturn = 'EOF'
     C                   goto      endnextprev
     C                   endif
417aA
417aAC* Get slot record for *NXTVSLOT/*PRVVSLOT.
417aA
417aAC                   if        $psubcmd = '*NXTVSLOT' or
417aAC                             $psubcmd = '*PRVVSLOT'
417aAC                   eval      lock = *off
417aAC                   eval      kywhse = vswhse
417aAC                   eval      kywhdp = vswhdp
417aAC                   eval      kydisp = vsdisp
417aAC                   eval      check4err = *on
417aAC                   exsr      getslot2
417aAC                   if        error
417aAC                   goto      endnextprev
417aAC                   endif
417aAC                   endif

     C* Calculate quantities.

     C                   exsr      calcqtys

417kDC**Move record fields into data structure.
417kDC**
417kDC**                 exsr      slot2ds
416rA
416rAC* See if we need to loop around and try again.
416rA
416rAC*   Loop if needing a pick slot with avail qty and all qtys <= 0
416rA
416rAC                   if        $psubcmd = '*NXTPICKAV' and
416rAC                             slavl1 <= 0             and
416rAC                             slavl2 <= 0             and
416rAC                             slavl3 <= 0
416rAC                   iter
416rAC                   endif
417gA
417gAC*   Loop if needing a overflow slot with avail qty and all qtys <= 0
417gA
417gAC                   if        $psubcmd = '*NXTOVRFAV' and
417gAC                             slavl1 <= 0             and
417gAC                             slavl2 <= 0             and
417gAC                             slavl3 <= 0
417gAC                   iter
417gAC                   endif
500 A
500 AC*   Loop if needing a item slot with avail qty and all qtys <= 0
500 A
500 AC                   if        $psubcmd = '*NXTITEMAV' and
500 AC                             slavl1 <= 0             and
500 AC                             slavl2 <= 0             and
500 AC                             slavl3 <= 0
500 AC                   iter
500 AC                   endif

417kAC* Move record fields into data structure.
417kA
417kAC                   exsr      slot2ds

416rAC                   leave
416rAC                   enddo

     C     endnextprev   endsr

417eA*----------------------------------------------------------------
417eA*  openslotdgt  Open file SlotDgt
417eA*----------------------------------------------------------------
417eA
417eAC     openslotdgt   begsr

     C                   if        not %open(slotdgt)
     C                   open(e)   slotdgt
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRSCD'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file SLOTDGT in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

417cA*----------------------------------------------------------------
417cA*  opencrossdk  Open file CrossDk
417cA*----------------------------------------------------------------
417cA
417cAC     opencrossdk   begsr

     C                   if        not %open(crossdk)
     C                   open(e)   crossdk
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRXDK'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file CROSSDK in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openitemadj  Open file ItemAdj
416bA*----------------------------------------------------------------
416bA
416bAC     openitemadj   begsr

     C                   if        not %open(itemadj)
     C                   open(e)   itemadj
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRIADJ'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file ITEMADJ in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openlabel  Open file Label
416bA*----------------------------------------------------------------
416bA
416bAC     openlabel     begsr

     C                   if        not %open(label)
     C                   open(e)   label
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLBL'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file LABEL in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openslot1  Open file Slot1
416bA*----------------------------------------------------------------
416bA
416bAC     openslot1     begsr

     C                   if        not %open(slot1)
     C                   open(e)   slot1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRSLT1'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file SLOT1 in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openslot2  Open file Slot2
416bA*----------------------------------------------------------------
416bA
416bAC     openslot2     begsr

     C                   if        not %open(slot2)
     C                   open(e)   slot2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRSLT2'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file SLOT2 in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openslot3  Open file Slot3
416bA*----------------------------------------------------------------
416bA
416bAC     openslot3     begsr

     C                   if        not %open(slot3)
     C                   open(e)   slot3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRSLT3'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file SLOT3 in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

417cA*----------------------------------------------------------------
417cA*  openspclord  Open file SpclOrd
417cA*----------------------------------------------------------------
417cA
417cAC     openspclord   begsr

     C                   if        not %open(spclord)
     C                   open(e)   spclord
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRSPCL'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file SPCLORD in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

417cA*----------------------------------------------------------------
417cA*  openvslexcp  Open file VslExcp
417cA*----------------------------------------------------------------
417cA
417cAC     openvslexcp   begsr

     C                   if        not %open(vslexcp)
     C                   open(e)   vslexcp
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNVSLEXP'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file VSLEXCP in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openvslot  Open file VSlot
416bA*----------------------------------------------------------------
416bA
416bAC     openvslot     begsr

     C                   if        not %open(vslot)
     C                   open(e)   vslot
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRVSLT'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file VSLOT in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416aA*----------------------------------------------------------------
417aA*  openvslot2  Open file VSlot2
417aA*----------------------------------------------------------------
417aA
417aAC     openvslot2    begsr

     C                   if        not %open(vslot2)
     C                   open(e)   vslot2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRVSL2'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file VSLOT2 in pgm'
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  qtyadjust   Adjust quantities for *ADJUST/*ADJUSTORD
     *----------------------------------------------------------------

     C     qtyadjust     begsr

     *  Open ItemAdj and Label files.

     C                   exsr      openitemadj
     C                   if        error
     C                   goto      endqtyadjust
     C                   endif

     C                   exsr      openlabel
     C                   if        error
     C                   goto      endqtyadjust
     C                   endif

     *  Get current date and time.

     C                   exsr      getdatetime

     *  Update slot and warehouse quantities.
416nA*    Only if Dakota should be updated according to adj code type.

416nAC                   if        $vsys <> 'H'
     C                   exsr      qtystock
     C                   if        error
     C                   goto      endqtyadjust
     C                   endif
416nAC                   endif
416nA
416nA*  Execute routine to write out adjustment and label recs.
416nA*    (code used to be part of this routine)
416nA
416nAC                   exsr      writeadj

416bA*    See if we should try to create a priority replenishment.

416bAC                   if        $psubcmd = '*ADJUSTORD' and
416bAC                             $vsys <> 'H' and
416bAC                             $slpick = 'Y' and
416bAC                             $slavl1 < 0
416bAC                   exsr      crtprtyrpl
416bAC                   endif

     C     endqtyadjust  endsr

416cA*----------------------------------------------------------------
416cA*  qtyalc2pck   Move quantity from allocated to picked.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyalc2pck    begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtya2p
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtya2p
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = $saorg1
     C                   eval      #whseorg2 = $saorg2
     C                   eval      #whseorg3 = $saorg3

     *  Update slot ...

     *    Reduce allocated quantites by original quantities.

     C                   eval      slalc1 = slalc1 - $saorg1
     C                   eval      slalc2 = slalc2 - $saorg2
     C                   eval      slalc3 = slalc3 - $saorg3

     *    Increase picked quantites by adjust quantities.

     C                   eval      slpck1 = slpck1 + $saqty1
     C                   eval      slpck2 = slpck2 + $saqty2
     C                   eval      slpck3 = slpck3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtya2p
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtya2p
     C                   endif

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtya2p     endsr

416cA*----------------------------------------------------------------
416cA*  qtyallocate  Update allocated quantites.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyallocate   begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtyalc
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtyalc
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     *  Update slot ...

     *    Update allocated quantites.

     C                   eval      slalc1 = slalc1 + $saqty1
     C                   eval      slalc2 = slalc2 + $saqty2
     C                   eval      slalc3 = slalc3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyalc
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyalc
     C                   endif

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtyalc     endsr

416cA*----------------------------------------------------------------
416cA*  qtyclspick   Close pick by reducing picked and stock quantities.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyclspick    begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtyclspck
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtyclspck
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = $saorg1
     C                   eval      #whseorg2 = $saorg2
     C                   eval      #whseorg3 = $saorg3

     *  Update slot ...

     *    Reduce picked quantites by original quantities.

     C                   eval      slpck1 = slpck1 - $saorg1
     C                   eval      slpck2 = slpck2 - $saorg2
     C                   eval      slpck3 = slpck3 - $saorg3

     *    Reduce stock quantites by adjust quantities.

     C                   eval      slstk1 = slstk1 - $saqty1
     C                   eval      slstk2 = slstk2 - $saqty2
     C                   eval      slstk3 = slstk3 - $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyclspck
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyclspck
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = -($saqty1)
510aAC                   eval      $uqty2 = -($saqty2)
510aAC                   eval      $uqty3 = -($saqty3)
510aAC                   exsr      updslotdte

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtyclspck  endsr

416cA*----------------------------------------------------------------
416cA*  qtyclsrcv    Close rcv by reducing received and increasing stock.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyclsrcv     begsr

417fA*  For "change" Transfer In's, convert quantity if necessary.
417fA*    (Note: This is duplicated in QTYRECEIVE and VERIFYQTY).

417fAC                   if        $psubcmd = '*TFRINCHG'  or
417hAC                             $psubcmd = '*LETINCHG'  or
417hAC                             $psubcmd = '*PRINCHG'  or
417hAC                             $psubcmd = '*SSINCHG'  or
417fAC                             $psubcmd = '*CLSTFICHG' or
417fAC                             $psubcmd = '*CLSLTICHG' or
417fAC                             $psubcmd = '*CLSPRICHG' or
417fAC                             $psubcmd = '*CLSSSICHG' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG'

417fAC                   select

417fAC                   when      #fromtype = ' ' and
417fAC                               (#totype = 'B' or #totype = 'S')
     C                   eval      $saqty1 = $saqty1 * #fromumq2
     C                   eval      $saqty2 = $saqty2 * #fromumq3

417fAC                   when      (#fromtype = 'B' or #fromtype = 'S')
417fAC                               and #totype = ' '
     C                   if        $saqty1 <> 0 and #toumq2 > 0
     C                   eval      $saqty1 = $saqty1 / #toumq2
417fAC                   endif
     C                   if        $saqty2 <> 0 and #toumq3 > 0
     C                   eval      $saqty2 = $saqty2 / #toumq3
417fAC                   endif

417fAC                   endsl

417fAC                   endif

     *  Do extra verification ...

     *    When closing to zero we will ignore the following conditions:
     *      - Slot status is 'Z' or 'V'.
     *      - Item is not in the slot.

     C                   if        $saqty1 = 0 and
     C                             $saqty2 = 0 and
     C                             $saqty3 = 0
     C                   if        slstat = 'Z' or
     C                             slstat = 'V' or
     C                             slitem <> #slotitem
     C                   goto      endqtyclsrcv
     C                   endif
     C                   endif

     *    Calculate new available slot quantities.

     C                   eval      newavlqty1  = slavl1 - $saorg1 + $saqty1
     C                   eval      newavlqty2  = slavl2 - $saorg2 + $saqty2
     C                   eval      newavlqty3  = slavl3 - $saorg3 + $saqty3

     *    New available slot quantities cannot be negative ...
     *      when reducing the available qty

     C                   if        newavlqty1 < 0 and $saqty1 < 0 or
     C                             newavlqty2 < 0 and $saqty2 < 0 or
     C                             newavlqty3 < 0 and $saqty3 < 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'NEGAVLSLT'
     C                   exsr      getmsg
     C                   goto      endqtyclsrcv
     C                   endif

     *    New warehouse available quantity cannot be negative ...
     *      when reducing the available qty

     C                   if        $saqty1 < 0 or
     C                             $saqty2 < 0 or
     C                             $saqty3 < 0
500dDC**                 if        (lowwhavl - lowiaqty) < 0
500dDC**                 eval      error = *on
500dDC**                 eval      $saqty1e = '1'
500dDC**                 eval      $saqty2e = '1'
500dDC**                 eval      $saqty3e = '1'
500dDC**                 eval      $preturn = 'NEGAVLWHS'
500dDC**                 exsr      getmsg
500dDC**                 goto      endqtyclsrcv
500dDC**                 endif
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = $saorg1
     C                   eval      #whseorg2 = $saorg2
     C                   eval      #whseorg3 = $saorg3

     *  Update slot ...

     *    Update item if blank.

     C                   if        slitem = ' '
     C                   eval      slitem = $saitem
     C                   endif
417iDC**
417iDC**  Update expiration date.
417iDC**
417iDC**                 eval      updexpdte = *off
417iDC**
417iDC**    Set expiration date to zero if necessary.
417iDC**
417iDC**                 if        #slotflgd <> 'Y' or not $slexpdu
417iDC**                 eval      $slexpd = 0
417iDC**                 endif
417iDC**
417iDC**    Update if item is not date sensitive.
417iDC**
417iDC**                 if        #slotflgd <> 'Y'
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if status is 'V' or 'Z' or existing date is zero.
417iDC**
417iDC**                 if        slstat = 'V' or
417iDC**                           slstat = 'Z' or
417iDC**                           slexpd = 0
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if stock qty is zero.
417iDC**
417iDC**                 if        slstk1 <= 0 and
417iDC**                           slstk2 <= 0 and
417iDC**                           slstk3 <= 0
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if stock qty is not zero and older expiraton date
417iDC**      (date sent in comes before existing date)
417iDC**
417iDC**                 if        slstk1 >= 0 or
417iDC**                           slstk2 >= 0 or
417iDC**                           slstk3 >= 0
417iDC**                 if        $slexpd < slexpd
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**                 endif
417iDC**
417iDC**    Update date.
417iDC**
417iDC**                 if        updexpdte
417iDC**                 eval      slexpd = $slexpd
417iDC**                 endif
417iDC**
417iDC**  Update priority.
417iDC**
417iDC**                 eval      updprty = *off
417iDC**
417iDC**    Set priority to zero if necessary.
417iDC**
417iDC**                 if        not $slprtyu
417iDC**                 eval      $slprty = 0
417iDC**                 endif

417iDC**    Make sure priority is less than or equal to zero.
417iDC**
417iDC**                 if        $slprty > 0
417iDC**                 eval      $slprty = -($slprty)
417iDC**                 endif
417iDC**
417iDC**    Update if status is 'V' or 'Z'.
417iDC**
417iDC**                 if        slstat = 'V' or
417iDC**                           slstat = 'Z'
417iDC**                 eval      updprty = *on
417iDC**                 endif
417iDC**
417iDC**    Update if higher priority than existing priority.
417iDC**
417iDC**                 if        %abs($slprty) > %abs(slprty)
417iDC**                 eval      updprty = *on
417iDC**                 endif
417iDC**
417iDC**    Update priority.
417iDC**
417iDC**                 if        updprty
417iDC**                 eval      slprty = $slprty
417iDC**                 endif

     *    Reduce received quantites by original quantities.

     C                   eval      slrcv1 = slrcv1 - $saorg1
     C                   eval      slrcv2 = slrcv2 - $saorg2
     C                   eval      slrcv3 = slrcv3 - $saorg3

     *    Increase stock quantites by adjust quantities.

     C                   eval      slstk1 = slstk1 + $saqty1
     C                   eval      slstk2 = slstk2 + $saqty2
     C                   eval      slstk3 = slstk3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn
417iDC**
417iDC**  See if status should change.
417iDC**
417iDC**    if status sent in, use it.
417iDC**    otherwise call routine to see if it should change.
417iDC**
417iDC**                 if        $slstatu and $slstat <> ' '
417iDC**                 eval      slstat = $slstat
417iDC**                 exsr      getdatetime
417iDC**                 eval      slsdte = curdate
417iDC**                 eval      slstim = curtime
417iDC**                 else
417iDC**                 exsr      checkstatus
417iDC**                 endif
417iDC**
417iDC**  Check for zero entered date.
417iDC**
417iDC**                 if        slentd <= 0
417iDC**                 exsr      getdatetime
417iDC**                 eval      slentd = curdate
417iDC**                 endif

417iA*    Set dates, priority and status.
417iA
417rAC                   exsr      setstatus
417iAC                   exsr      getdateopt
417iAC                   exsr      setentdate
417iAC                   exsr      setexpdate
417iAC                   exsr      setpriority
417rDC**                 exsr      setstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyclsrcv
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds
417sA
417sA*  Execute routine to write out adjustment and label recs.
417sA
417sAC                   if        $psubcmd = '*CLSRCVADJ'
417sAC                   exsr      writeadj
417sAC                   endif

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyclsrcv
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*DATE'
510aAC                   eval      $uqty1 = $saqty1
510aAC                   eval      $uqty2 = $saqty2
510aAC                   eval      $uqty3 = $saqty3
510aAC                   exsr      updslotdte

     C     endqtyclsrcv  endsr

416cA*----------------------------------------------------------------
416cA*  qtyclstfrout  Close tfrout by reducing tfr and stock quantities.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyclstfrout  begsr

     *  Do extra verification ...
417dA
417dA*    Item type cannot be 'C'.
417dA
417dAC                   if        #slottype = 'C'
417dAC                   eval      error = *on
417dAC                   eval      $saitem = '1'
417dAC                   eval      $preturn  = 'INVLDITYP'
417dAC                   exsr      getmsg
417dAC                   goto      endqtyclstfro
417dAC                   endif
417dA
417dA*    Corresponding item type cannot be 'C'.
417dA
417dAC                   if        #cslottype = 'C'
417dAC                   eval      error = *on
417dAC                   eval      $saitem = '1'
417dAC                   eval      $preturn  = 'INVLDCITYP'
417dAC                   exsr      getmsg
417dAC                   goto      endqtyclstfro
417dAC                   endif

     *    When closing to zero we will ignore the following conditions:
     *      - Slot status is 'Z' or 'V'.
     *      - Item is not in the slot.

     C                   if        $saqty1 = 0 and
     C                             $saqty2 = 0 and
     C                             $saqty3 = 0
     C                   if        slstat = 'Z' or
     C                             slstat = 'V' or
     C                             slitem <> #slotitem
     C                   goto      endqtyclstfro
     C                   endif
     C                   endif

     *    Make sure that slot is not at Verified status.

     C                   if        slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtyclstfro
     C                   endif

     *    Make sure slot is not at Zero status unless all adjustment
     *    quantities are negative (This would indicate user is trying
     *    to undo a previous *CLSTFROUT that set the status to Zero).

     C                   if        slstat = 'Z'
     C                   if        $saqty1 > 0 or
     C                             $saqty2 > 0 or
     C                             $saqty3 > 0
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtyclstfro
     C                   endif
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtyclstfro
     C                   endif

     *    Calculate new available slot qty.

     C                   eval      newavlqty1  = slavl1 + $saorg1 - $saqty1
     C                   eval      newavlqty2  = slavl2 + $saorg2 - $saqty2
     C                   eval      newavlqty3  = slavl3 + $saorg3 - $saqty3

     *    New available slot quantities cannot be negative ...
     *      when reducing the available qty ($saqty is positive)

     C                   if        newavlqty1 < 0 and $saqty1 > 0 or
     C                             newavlqty2 < 0 and $saqty2 > 0 or
     C                             newavlqty3 < 0 and $saqty3 > 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'NEGAVLSLT'
     C                   exsr      getmsg
     C                   goto      endqtyclstfro
     C                   endif

     *    New warehouse available quantity cannot be negative ...
     *      when reducing the available qty ($saqty is positive)

     C                   if        $saqty1 > 0 or
     C                             $saqty2 > 0 or
     C                             $saqty3 > 0
500dDC**                 if        (lowwhavl + lowiaorg - lowiaqty) < 0
500dDC**                 eval      error = *on
500dDC**                 eval      $saqty1e = '1'
500dDC**                 eval      $saqty2e = '1'
500dDC**                 eval      $saqty3e = '1'
500dDC**                 eval      $preturn = 'NEGAVLWHS'
500dDC**                 exsr      getmsg
500dDC**                 goto      endqtyclstfro
500dDC**                 endif
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = $saorg1
     C                   eval      #whseorg2 = $saorg2
     C                   eval      #whseorg3 = $saorg3

     *  Update slot ...

     *    Reduce transfered quantites by original quantities.

     C                   eval      sltfr1 = sltfr1 - $saorg1
     C                   eval      sltfr2 = sltfr2 - $saorg2
     C                   eval      sltfr3 = sltfr3 - $saorg3

     *    Reduce stock quantites by adjust quantities.

     C                   eval      slstk1 = slstk1 - $saqty1
     C                   eval      slstk2 = slstk2 - $saqty2
     C                   eval      slstk3 = slstk3 - $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyclstfro
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyclstfro
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = -($saqty1)
510aAC                   eval      $uqty2 = -($saqty2)
510aAC                   eval      $uqty3 = -($saqty3)
510aAC                   exsr      updslotdte

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtyclstfro endsr

416cA*----------------------------------------------------------------
416cA*  qtypck2alc   Move quantity from picked to allocated.
416cA*----------------------------------------------------------------
416cA
416cAC     qtypck2alc    begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtyp2a
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtyp2a
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = $saorg1
     C                   eval      #whseorg2 = $saorg2
     C                   eval      #whseorg3 = $saorg3

     *  Update slot ...

     *    Reduce picked quantites by original quantities.

     C                   eval      slpck1 = slpck1 - $saorg1
     C                   eval      slpck2 = slpck2 - $saorg2
     C                   eval      slpck3 = slpck3 - $saorg3

     *    Increase allocated quantites by adjust quantities.

     C                   eval      slalc1 = slalc1 + $saqty1
     C                   eval      slalc2 = slalc2 + $saqty2
     C                   eval      slalc3 = slalc3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyp2a
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyp2a
     C                   endif

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtyp2a     endsr

416cA*----------------------------------------------------------------
416cA*  qtypick      Update picked quantites.
416cA*----------------------------------------------------------------
416cA
416cAC     qtypick       begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtypck
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtypck
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     *  Update slot ...

     *    Update allocated quantites.

     C                   eval      slpck1 = slpck1 + $saqty1
     C                   eval      slpck2 = slpck2 + $saqty2
     C                   eval      slpck3 = slpck3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtypck
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtypck
     C                   endif

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

416eA*    See if we should try to create a priority replenishment.

416eAC                   if        slpick = 'Y' and  slavl1 < 0
416eAC                   exsr      crtprtyrpl
416eAC                   endif

     C     endqtypck     endsr

416cA*----------------------------------------------------------------
416cA*  qtyreceive   Update received quantities
416cA*----------------------------------------------------------------
416cA
416cAC     qtyreceive    begsr

417fA*  For "change" Transfer In's, convert quantity if necessary.
417fA*    (Note: This is duplicated in QTYCLSRCV and VERIFYQTY).

417fAC                   if        $psubcmd = '*TFRINCHG'  or
417hAC                             $psubcmd = '*LETINCHG'  or
417hAC                             $psubcmd = '*PRINCHG'  or
417hAC                             $psubcmd = '*SSINCHG'  or
417fAC                             $psubcmd = '*CLSTFICHG' or
417hAC                             $psubcmd = '*CLSLTICHG' or
417hAC                             $psubcmd = '*CLSPRICHG' or
417hAC                             $psubcmd = '*CLSSSICHG' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG'

417fAC                   select

417fAC                   when      #fromtype = ' ' and
417fAC                               (#totype = 'B' or #totype = 'S')
     C                   eval      $saqty1 = $saqty1 * #fromumq2
     C                   eval      $saqty2 = $saqty2 * #fromumq3

417fAC                   when      (#fromtype = 'B' or #fromtype = 'S')
417fAC                               and #totype = ' '
     C                   if        $saqty1 <> 0 and #toumq2 > 0
     C                   eval      $saqty1 = $saqty1 / #toumq2
417fAC                   endif
     C                   if        $saqty2 <> 0 and #toumq3 > 0
     C                   eval      $saqty2 = $saqty2 / #toumq3
417fAC                   endif

417fAC                   endsl

417fAC                   endif

     *  Do extra verification ...

     *    Calculate new available slot quantities.

     C                   eval      newavlqty1  = slavl1 + $saqty1
     C                   eval      newavlqty2  = slavl2 + $saqty2
     C                   eval      newavlqty3  = slavl3 + $saqty3

     *    New available slot quantities cannot be negative ...
     *      when reducing the available qty

     C                   if        newavlqty1 < 0 and $saqty1 < 0 or
     C                             newavlqty2 < 0 and $saqty2 < 0 or
     C                             newavlqty3 < 0 and $saqty3 < 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'NEGAVLSLT'
     C                   exsr      getmsg
     C                   goto      endqtyrcv
     C                   endif

     *    New warehouse available quantity cannot be negative ...
     *      when reducing the available qty

     C                   if        $saqty1 < 0 or
     C                             $saqty2 < 0 or
     C                             $saqty3 < 0
500dDC**                 if        (lowwhavl - lowiaqty) < 0
500dDC**                 eval      error = *on
500dDC**                 eval      $saqty1e = '1'
500dDC**                 eval      $saqty2e = '1'
500dDC**                 eval      $saqty3e = '1'
500dDC**                 eval      $preturn = 'NEGAVLWHS'
500dDC**                 exsr      getmsg
500dDC**                 goto      endqtyrcv
500dDC**                 endif
     C                   endif

416oA*    Skip actual update when verifying.
416oA
416oAC                   if        $psubcmd = '*VERIFYTFI'
417hAC                             or $psubcmd = '*VERIFYLTI'
417hAC                             or $psubcmd = '*VERIFYPRI'
417hAC                             or $psubcmd = '*VERIFYSSI'
417fAC                             or $psubcmd = '*VFYTFICHG'
417hAC                             or $psubcmd = '*VFYLTICHG'
417hAC                             or $psubcmd = '*VFYPRICHG'
417hAC                             or $psubcmd = '*VFYSSICHG'
500eAC                             or $psubcmd = '*VERIFYPUT'
500xAC                             or $psubcmd = '*VFYSTGPUT'
500eAC                             or $psubcmd = '*VERIFYRTN'
416oAC                   goto      endqtyrcv
416oAC                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     *  Update slot ...

     *    Update item if blank.

     C                   if        slitem = ' '
     C                   eval      slitem = $saitem
     C                   endif
417iDC**
417iDC**   Update expiration date.
417iDC**
417iDC**                 eval      updexpdte = *off
417iDC**
417iDC**    Set expiration date to zero if necessary.
417iDC**
417iDC**                 if        #slotflgd <> 'Y' or not $slexpdu
417iDC**                 eval      $slexpd = 0
417iDC**                 endif
417iDC**
417iDC**    Update if item is not date sensitive.
417iDC**
417iDC**                 if        #slotflgd <> 'Y'
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if status is 'V' or 'Z' or existing date is zero.
417iDC**
417iDC**                 if        slstat = 'V' or
417iDC**                           slstat = 'Z' or
417iDC**                           slexpd = 0
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if stock qty is zero.
417iDC**
417iDC**                 if        slstk1 <= 0 and
417iDC**                           slstk2 <= 0 and
417iDC**                           slstk3 <= 0
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**
417iDC**    Update if stock qty is not zero and older expiraton date
417iDC**      (date sent in comes before existing date)
417iDC**
417iDC**                 if        slstk1 >= 0 or
417iDC**                           slstk2 >= 0 or
417iDC**                           slstk3 >= 0
417iDC**                 if        $slexpd < slexpd
417iDC**                 eval      updexpdte = *on
417iDC**                 endif
417iDC**                 endif
417iDC**
417iDC**    Update date.
417iDC**
417iDC**                 if        updexpdte
417iDC**                 eval      slexpd = $slexpd
417iDC**                 endif
417iDC**
417iDC**  Update priority.
417iDC**
417iDC**                 eval      updprty = *off
417iDC**
417iDC**    Set priority to zero if necessary.
417iDC**
417iDC**                 if        not $slprtyu or
417iDC**                           $slpick = 'Y' and $slrsrv = 'Y'
417iDC**                 eval      $slprty = 0
417iDC**                 endif
417iDC**
417iDC**    Make sure priority is less than or equal to zero.
417iDC**
417iDC**                 if        $slprty > 0
417iDC**                 eval      $slprty = -($slprty)
417iDC**                 endif
417iDC**
417iDC**    Update if status is 'V' or 'Z'.
417iDC**
417iDC**                 if        slstat = 'V' or
417iDC**                           slstat = 'Z'
417iDC**                 eval      updprty = *on
417iDC**                 endif
417iDC**
417iDC**    Update if higher priority than existing priority.
417iDC**
417iDC**                 if        %abs($slprty) > %abs(slprty)
417iDC**                 eval      updprty = *on
417iDC**                 endif
417iDC**
417iDC**    Update priority.
417iDC**
417iDC**                 if        updprty
417iDC**                 eval      slprty = $slprty
417iDC**                 endif

     *    Update received quantites.

     C                   eval      slrcv1 = slrcv1 + $saqty1
     C                   eval      slrcv2 = slrcv2 + $saqty2
     C                   eval      slrcv3 = slrcv3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn
417iDC**
417iDC**  See if status should change.
417iDC**
417iDC**    if status sent in, use it.
417iDC**    otherwise call routine to see if it should change.
417iDC**
417iDC**                 if        $slstatu and $slstat <> ' '
417iDC**                 eval      slstat = $slstat
417iDC**                 exsr      getdatetime
417iDC**                 eval      slsdte = curdate
417iDC**                 eval      slstim = curtime
417iDC**                 else
417iDC**                 exsr      checkstatus
417iDC**                 endif
417iDC**
417iDC**  Check for zero entered date.
417iDC**
417iDC**                 if        slentd <= 0
417iDC**                 exsr      getdatetime
417iDC**                 eval      slentd = curdate
417iDC**                 endif

417iA*    Set dates, priority and status.
417iA
417rAC                   exsr      setstatus
417iAC                   exsr      getdateopt
417iAC                   exsr      setentdate
417iAC                   exsr      setexpdate
417iAC                   exsr      setpriority
417rDC**                 exsr      setstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtyrcv
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtyrcv
     C                   endif

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtyrcv     endsr

416cA*----------------------------------------------------------------
416cA*  qtystock     Update stock quantites.
416cA*----------------------------------------------------------------
416cA
416cAC     qtystock      begsr

     *  Do extra verification ...

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtystk
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtystk
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     *  Update slot ...

     *    Update allocated quantites.

     C                   eval      slstk1 = slstk1 + $saqty1
     C                   eval      slstk2 = slstk2 + $saqty2
     C                   eval      slstk3 = slstk3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtystk
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtystk
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = $saqty1
510aAC                   eval      $uqty2 = $saqty2
510aAC                   eval      $uqty3 = $saqty3
510aAC                   exsr      updslotdte

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endqtystk     endsr

416cA*----------------------------------------------------------------
416cA*  qtytfrout    Update transfer quantities
416cA*----------------------------------------------------------------
416cA
416cAC     qtytfrout     begsr

     *  Do extra verification ...
417dA
417dA*    Item type cannot be 'C'.
417dA
417dAC                   if        #slottype = 'C'
417dAC                   eval      error = *on
417dAC                   eval      $saitem = '1'
417dAC                   eval      $preturn  = 'INVLDITYP'
417dAC                   exsr      getmsg
417dAC                   goto      endqtytfro
417dAC                   endif
417dA
417dA*    Corresponding item type cannot be 'C'.
417dA
417dAC                   if        #cslottype = 'C'
417dAC                   eval      error = *on
417dAC                   eval      $saitem = '1'
417dAC                   eval      $preturn  = 'INVLDCITYP'
417dAC                   exsr      getmsg
417dAC                   goto      endqtytfro
417dAC                   endif

     *    Make sure that slot is active.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdp = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn  = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endqtytfro
     C                   endif

     *    Make sure that slot contains "slot" item.

     C                   if        slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endqtytfro
     C                   endif

     *    Calculate new available slot quantities.

     C                   eval      newavlqty1  = slavl1 - $saqty1
     C                   eval      newavlqty2  = slavl2 - $saqty2
     C                   eval      newavlqty3  = slavl3 - $saqty3

     *    New available slot quantities cannot be negative ...
     *      when reducing the available qty ($saqty is positive)

500xAC                   if        $pprogram <> 'LT107'
     C                   if        newavlqty1 < 0 and $saqty1 > 0 or
     C                             newavlqty2 < 0 and $saqty2 > 0 or
     C                             newavlqty3 < 0 and $saqty3 > 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'NEGAVLSLT'
     C                   exsr      getmsg
     C                   goto      endqtytfro
     C                   endif
500xAC                   endif

     *    New warehouse available quantity cannot be negative ...
     *      when reducing the available qty ($saqty is positive)

     C                   if        $saqty1 > 0 or
     C                             $saqty2 > 0 or
     C                             $saqty3 > 0
500dDC**                 if        (lowwhavl - lowiaqty) < 0
500dDC**                 eval      error = *on
500dDC**                 eval      $saqty1e = '1'
500dDC**                 eval      $saqty2e = '1'
500dDC**                 eval      $saqty3e = '1'
500dDC**                 eval      $preturn = 'NEGAVLWHS'
500dDC**                 exsr      getmsg
500dDC**                 goto      endqtytfro
500dDC**                 endif
     C                   endif

     *    Skip actual update when verifying.

     C                   if        $psubcmd = '*VERIFYTFO'
417hAC                             or $psubcmd = '*VERIFYLTO'
417hAC                             or $psubcmd = '*VERIFYPRO'
417hAC                             or $psubcmd = '*VERIFYSSO'
417fAC                             or $psubcmd = '*VFYTFOCHG'
417hAC                             or $psubcmd = '*VFYLTOCHG'
417hAC                             or $psubcmd = '*VFYPROCHG'
417hAC                             or $psubcmd = '*VFYSSOCHG'
     C                   goto      endqtytfro
     C                   endif

     *  Initialize warehouse updated quantities.

     C                   eval      #whsestat = slstat

     C                   eval      #whsefix1 = 0
     C                   eval      #whsefix2 = 0
     C                   eval      #whsefix3 = 0

     C                   eval      #whseadj1 = $saqty1
     C                   eval      #whseadj2 = $saqty2
     C                   eval      #whseadj3 = $saqty3

     C                   eval      #whseorg1 = 0
     C                   eval      #whseorg2 = 0
     C                   eval      #whseorg3 = 0

     *  Update slot ...

     *    Update transfer quantites.

     C                   eval      sltfr1 = sltfr1 + $saqty1
     C                   eval      sltfr2 = sltfr2 + $saqty2
     C                   eval      sltfr3 = sltfr3 + $saqty3

     *    Fix breakdown quantities.

     C                   exsr      fixbrkdn

     *    See if status should change.

     C                   exsr      checkstatus

     *    Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDERRSLT2'
     C                   exsr      getmsg
     C                   goto      endqtytfro
     C                   endif
510hA
510hA*    If slot goes to 'Z',
510hA*      then see if it should be automatically zero verified.
510hA
510hAC                   exsr      zerovfyauto

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     *  Update warehouse quantities ...

     C                   exsr      qtywhse
     C                   if        error
     C                   goto      endqtytfro
     C                   endif

     C     endqtytfro    endsr

416cA*----------------------------------------------------------------
416cA*  qtywhse      Update warehouse quantites.
416cA*----------------------------------------------------------------
416cA
416cAC     qtywhse       begsr

     *  Pass along subcommand & quantities sent in ...

     C                   eval      $drisubcmd = $psubcmd

     *  Add some slot and item information ...

     C                   eval      $iqwhseu = *on
     C                   eval      $iqwhse = $slwhse
     C                   eval      $iqitemu = *on
     C                   eval      $iqitem = #slotitem
     C                   eval      $iqstatu = *on
     C                   eval      $iqstat = #whsestat
     C                   eval      $iqumq2u = *on
     C                   eval      $iqumq2 = #slotumq2
     C                   eval      $iqumq3u = *on
     C                   eval      $iqumq3 = #slotumq3

     *  Don't forget the quantities ...

     C                   eval      $iqfixu = *on
     C                   eval      $iqfix1 = #whsefix1
     C                   eval      $iqfix2 = #whsefix2
     C                   eval      $iqfix3 = #whsefix3
     C                   eval      $iqadju = *on
     C                   eval      $iqadj1 = #whseadj1
     C                   eval      $iqadj2 = #whseadj2
     C                   eval      $iqadj3 = #whseadj3
     C                   eval      $iqorgu = *on
     C                   eval      $iqorg1 = #whseorg1
     C                   eval      $iqorg2 = #whseorg2
     C                   eval      $iqorg3 = #whseorg3

     *  And throw in some fields for tracking.

     C                   if        $iqtrn#u
     C                   eval      $iqtrn#u = *on
     C                   eval      $iqtrn#  = $satrn#
     C                   endif

     C                   if        $iqlic#u
     C                   eval      $iqlic#u = *on
     C                   eval      $iqlic#  = $salic#
     C                   endif

     C                   if        $iqlic#u
     C                   eval      $iqtasku = *on
     C                   eval      $iqtask  = $satask
     C                   endif

     *  Then call interface to do the update.

     C                   eval      driitemqty = *on
     C                   call(e)   'DRIITEMQTY'
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $itemqty      parm      $itemqty      $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEMQTY'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $saiteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endqtywhse
     C                   endsl

     C                   eval      lockeditemqty = *off

     C     endqtywhse    endsr

     *----------------------------------------------------------------
     *  rightadj  Right adjust slot fields.
     *----------------------------------------------------------------

     C     rightadj      begsr

      *  Aisle

     C                   if        $slaislu
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      $slaisl       $cstr            30
     C                   move      $cstr         $slaisl
     C                   endif

      *  Handstack

     C                   if        $slhandu
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm      $slhand       $cstr            30
     C                   move      $cstr         $slhand
     C                   endif

     C                   endsr

416eA*----------------------------------------------------------------
416eA*  savebefore   Save before image of slot.
416eA*----------------------------------------------------------------

416eAC     savebefore    begsr

     *  Move information about slot into ds fields.

     C                   exsr      slot2ds

     *  Save as before image.

     C                   eval      $slotbefore = $slot

     *  Restore original input (saved at beginning of program).

     C                   eval      $slot = $slotinput

     C                   endsr

     *----------------------------------------------------------------
     *  set2vfy   Set slot to verified state.
     *----------------------------------------------------------------

     C     set2vfy       begsr
     C                   eval      error = *off

     *  Get and lock slot.

417cAC                   if        $psubcmd <> '*ZEROVFY'

     C                   eval      lock = *on
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2

     C                   if        error
     C                   goto      endset2vfy
     C                   endif

417cAC                   endif

     *  Make sure fields are cleaned up.

417cAC                   eval      slstat = 'V'
     C                   eval      slitem = ' '
     C                   eval      slentd = 0
     C                   eval      slexpd = 0
     C                   eval      slprty = 0
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0

417cAC                   exsr      getdatetime
417cAC                   eval      slsdte = curdate
417cAC                   eval      slstim = curtime

     *  Update record

417cDC**                 update(e) slrec
417cMC                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Err on "Upd '
     C                                       + 'Slt" cmd '
     C                                       + '('
     C                                       + %Trim(%editc(slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(slwhdp)
     C                                       + '/'
     C                                       + %trim(sldisp)
     C                                       + ')'
417cMC                                       + '-' + f2messageid
417cDC**                                     + '-' + f1messageid

     C                   goto      endset2vfy
     C                   endif
510aA
510aA*  Delete slot date quantities.
510aA
510aAC                   exsr      deleteslotdte

     C     endset2vfy    endsr

417iA*----------------------------------------------------------------
417iA*  setentdate  Set slot entered date.
417iA*----------------------------------------------------------------
417iA
417iAC     setentdate    begsr
     C                   eval      error = *off

     *  If entered date wasn't sent or is zero,
     *    set input field to current date.

     C                   if        not $slentdu or $slentd = 0
     C                   exsr      getdatetime
     C                   eval      $slentd = curdate
     C                   endif

     *  Determine if and how expiration date should be set.

     *    Set to From (Sent) date if one of the following ...
     *      - Existing date is zero.
     *      - Current (before) status is 'V' or 'Z'.
     *      - Stock qty is less than or equal to zero.
     *      - Doing a transfer and date option is set to '1'.
     *      - Doing a letdown and date option is set to '1'.
     *      - Doing a priority replenishment and date option is set to '1'.
     *      - Doing a specific slot repl and date option is set to '1'.
     *      - Doing a receiving/putaway and date option is set to '1'.
     *      - Doing a return and date option is set to '1'.

     C                   if        slentd = 0
     C                             or (slstat = 'V' or slstat = 'Z')
     C                             or (slstk1 <= 0
     C                                 and slstk2 <= 0
     C                                 and slstk3 <= 0)
     C                             or (($psubcmd = '*TFRIN'
     C                                  or $psubcmd = '*TFRINCHG'
     C                                  or $psubcmd = '*CLSTFRIN'
     C                                  or $psubcmd = '*CLSTFICHG')
     C                                 and opsltf = '1')
     C                             or (($psubcmd = '*LETIN'
     C                                  or $psubcmd = '*LETINCHG'
     C                                  or $psubcmd = '*CLSLETIN'
     C                                  or $psubcmd = '*CLSLTICHG')
     C                                 and opltdn = '1')
     C                             or (($psubcmd = '*PRIN'
     C                                  or $psubcmd = '*PRINCHG'
     C                                  or $psubcmd = '*CLSPRIN'
     C                                  or $psubcmd = '*CLSPRICHG')
     C                                 and opodrp = '1')
     C                             or (($psubcmd = '*SSIN'
     C                                  or $psubcmd = '*SSINCHG'
     C                                  or $psubcmd = '*CLSSSIN'
     C                                  or $psubcmd = '*CLSSSICHG')
     C                                 and opodrp = '1')
     C                             or (($psubcmd = '*RECEIVE'
     C                                  or $psubcmd = '*PUTAWAY'
500xAC                                  or $psubcmd = '*STAGEPUT'
     C                                  or $psubcmd = '*CLSRCV'
417sAC                                  or $psubcmd = '*CLSRCVADJ'
500xMC                                  or $psubcmd = '*CLSPUTAWY'
500xAC                                  or $psubcmd = '*CLSSTGPUT')
     C                                 and opparc = '1')
     C                             or (($psubcmd = '*RETURN'
     C                                  or $psubcmd = '*CLSRTN')
     C                                 and oppart = '1')
     C                   eval      slentd = $slentd
     C                   goto      endsetentdate
     C                   endif

     *    Otherwise, set to oldest date.

     C                   if        $slentd < slentd
     C                   eval      slentd = $slentd
     C                   goto      endsetentdate
     C                   endif

     C     endsetentdate endsr

417iA*----------------------------------------------------------------
417iA*  setexpdate  Set slot expiration/entered dates.
417iA*----------------------------------------------------------------
417iA
417iAC     setexpdate    begsr
     C                   eval      error = *off

     *  Determine if and how expiration date should be set.

     *    Set to zero if ...
     *      Item is not date sensitive

     C                   if        #slotflgd <> 'Y'
     C                   eval      slexpd = 0
     C                   goto      endsetexpdate
     C                   endif

     *    Do nothing if Sent (From) date is zero or wasn't sent.

     C                   if        $slexpd = 0 or not $slexpdu
     C                   goto      endsetexpdate
     C                   endif

     *    Set to From (Sent) date if one of the following ...
     *      - Existing date is zero.
     *      - Current (before) status is 'V' or 'Z'.
     *      - Stock qty is less than or equal to zero.
     *      - Doing a transfer and date option is set to '1'.
     *      - Doing a letdown and date option is set to '1'.
     *      - Doing a priority replenishment and date option is set to '1'.
     *      - Doing a specific slot repl and date option is set to '1'.
     *      - Doing a receiving/putaway and date option is set to '1'.
     *      - Doing a return and date option is set to '1'.

     C                   if        slexpd = 0
     C                             or (slstat = 'V' or slstat = 'Z')
     C                             or (slstk1 <= 0
     C                                 and slstk2 <= 0
     C                                 and slstk3 <= 0)
     C                             or (($psubcmd = '*TFRIN'
     C                                  or $psubcmd = '*TFRINCHG'
     C                                  or $psubcmd = '*CLSTFRIN'
     C                                  or $psubcmd = '*CLSTFICHG')
     C                                 and opsltf = '1')
     C                             or (($psubcmd = '*LETIN'
     C                                  or $psubcmd = '*LETINCHG'
     C                                  or $psubcmd = '*CLSLETIN'
     C                                  or $psubcmd = '*CLSLTICHG')
     C                                 and opltdn = '1')
     C                             or (($psubcmd = '*PRIN'
     C                                  or $psubcmd = '*PRINCHG'
     C                                  or $psubcmd = '*CLSPRIN'
     C                                  or $psubcmd = '*CLSPRICHG')
     C                                 and opodrp = '1')
     C                             or (($psubcmd = '*SSIN'
     C                                  or $psubcmd = '*SSINCHG'
     C                                  or $psubcmd = '*CLSSSIN'
     C                                  or $psubcmd = '*CLSSSICHG')
     C                                 and opodrp = '1')
     C                             or (($psubcmd = '*RECEIVE'
     C                                  or $psubcmd = '*PUTAWAY'
520 AC                                 and slpick   = 'Y'
500xAC                                  or $psubcmd = '*STAGEPUT'
     C                                  or $psubcmd = '*CLSRCV'
417sAC                                  or $psubcmd = '*CLSRCVADJ'
500xMC                                  or $psubcmd = '*CLSPUTAWY'
500xAC                                  or $psubcmd = '*CLSSTGPUT')
     C                                 and opparc = '1')
     C                             or (($psubcmd = '*RETURN'
     C                                  or $psubcmd = '*CLSRTN')
     C                                 and oppart = '1')
520 AC                                  or $psubcmd = '*PUTAWAY'
520 AC                                 and slpick   = 'N'
520 AC                                 and oprcvo = '1'
     C                   eval      slexpd = $slexpd
     C                   goto      endsetexpdate
     C                   endif

     *    Otherwise, set to oldest date.

     C                   if        $slexpd < slexpd
     C                   eval      slexpd = $slexpd
     C                   goto      endsetexpdate
     C                   endif

     C     endsetexpdate endsr

417iA*----------------------------------------------------------------
417iA*  setpriority  Set slot priority.
417iA*----------------------------------------------------------------
417iA
417iAC     setpriority   begsr
     C                   eval      error = *off
     C                   eval      updprty = *off

     *  If priority wasn't sent, set input field to zero.

     C                   if        not $slprtyu
     C                   eval      $slprty = 0
     C                   endif

     *  Make sure priority is less than or equal to zero.

     C                   if        $slprty > 0
     C                   eval      $slprty = -($slprty)
     C                   endif

     *  Set to From (Sent) priority if one of the following ...
     *    - Current (before) status is 'V' or 'Z'.
     *    - From priority is higher that existing priority.

     C                   if        (slstat = 'V' or slstat = 'Z')
     C                             or %abs($slprty) > %abs(slprty)
     C                   eval      slprty = $slprty
     C                   goto      endsetprty
     C                   endif

     C     endsetprty    endsr

417iA*----------------------------------------------------------------
417iA*  setstatus    Set slot status
417iA*----------------------------------------------------------------
417iA
417iAC     setstatus     begsr
     C                   eval      error = *off

     *  See if status should change.

     *    if status sent in, use it.
     *    otherwise call routine to see if it should change.

     C                   if        $slstatu and $slstat <> ' '
     C                   eval      slstat = $slstat
     C                   exsr      getdatetime
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   else
     C                   exsr      checkstatus
     C                   endif

     C     endstatus     endsr

416eA*----------------------------------------------------------------
416eA*  seqprtyrpl   Sequence priority replenishments
416eA*----------------------------------------------------------------

416eAC     seqprtyrpl    begsr

     *  Initialize data structure

     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#

     *  Initialize fields

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = $slwhse

     C                   eval      driprtyrpl = *on
     C                   call(e)   'DRIPRTYRPL'
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $prtyrpl      parm      $prtyrpl      $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIPRTYRPL'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   endsl

     C                   endsr

416pA*----------------------------------------------------------------
416pA*  shiftssbqty   Shift quantities for SSB item.
416pA*----------------------------------------------------------------

416pAC     shiftssbqty   begsr

     *  Shift quantities if sent item is an SSB item.

     C                   if        #senttype = 'S'
     C                   eval      $saqty3 = $saqty2
     C                   eval      $saqty2 = $saqty1
     C                   eval      $saqty1 = 0
     C                   eval      $saorg3 = $saorg2
     C                   eval      $saorg2 = $saorg1
     C                   eval      $saorg1 = 0
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  slot2ds  Move slot fields to data structure fields
     *----------------------------------------------------------------

     C     slot2ds       begsr

     C* Move information to data structure.

     C                   eval      $slwhse = slwhse
     C                   eval      $slwhdp = slwhdp
     C                   eval      $sldisp = sldisp
     C                   eval      $slaisl = slaisl
     C                   eval      $slloc  = slloc
     C                   eval      $slrlvl = slrlvl
     C                   eval      $slhand = slhand
     C                   eval      $slside = slside
     C                   eval      $slstyp = slstyp
     C                   eval      $slstat = slstat
     C                   eval      $slsdte = slsdte
     C                   eval      $slstim = slstim
     C                   eval      $slsdef = slsdef
     C                   eval      $sldesg = sldesg
     C                   eval      $slactv = slactv
     C                   eval      $slbld  = slbld
     C                   eval      $slpick = slpick
     C                   eval      $slpseq = slpseq
     C                   eval      $slprty = slprty
     C                   eval      $slentd = slentd
     C                   eval      $slexpd = slexpd
     C                   eval      $slslfd = slslfd
     C                   eval      $slrsrv = slrsrv
     C                   eval      $slitem = slitem
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
     C                   eval      $slphy1 = slphy1
     C                   eval      $slphy2 = slphy2
     C                   eval      $slphy3 = slphy3
     C                   eval      $slavl1 = slavl1
     C                   eval      $slavl2 = slavl2
     C                   eval      $slavl3 = slavl3
     C                   eval      $sladj1 = sladj1
     C                   eval      $sladj2 = sladj2
     C                   eval      $sladj3 = sladj3
417eA
417eA*  Get slot check digit.
417eA
417eAC                   eval      lock = *off
417eAC                   exsr      getchkdigit
417eAC                   eval      $scddgt = scddgt
416rA
416rA*  Get base slot for some operations.
416rA
416rAC                   if        $psubcmd = '*GET'  or
416rAC                             $psubcmd = '*GETI' or
416bAC                             %subst($psubcmd:1:4) = '*NXT' or
417aMC                             %subst($psubcmd:1:4) = '*PRV' or
417aAC                             $psubcmd = '*GETCHKV' or
417aAC                             $psubcmd = '*GETICHKV'
416rAC                   exsr      getbaseslot
416rAC                   endif
417aA
417aA*  For some operations, check for virtual associated with base.
417aA
417aAC                   if        $psubcmd = '*GETCHKV'  or
417bMC                             $psubcmd = '*GETICHKV' or
417bAC                             %subst($psubcmd:1:4) = '*NXT' or
417bAC                             %subst($psubcmd:1:4) = '*PRV'
417aAC                   exsr      check4virtual
417aAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  unlock         Unlock records.
     *----------------------------------------------------------------

     C     unlock        begsr

     C                   if        lockeditemqty
     C                   eval      $drisubcmd = '*UNLOCK'
     C                   eval      driitemqty = *on
     C                   call(e)   'DRIITEMQTY'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $itemqty      parm      $itemqty      $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        lockedslot1
     C                   unlock    slot1
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        lockedslot2
     C                   unlock    slot2
     C                   if        %error
     C                   endif
     C                   endif


     C                   if        lockedvslot
     C                   unlock    vslot
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsr

416cA*----------------------------------------------------------------
416cA*  updqty     Update slot quantities.
416cA*----------------------------------------------------------------
416cA
416cAC     updqty        begsr
     C                   move      *off          error

     *  Update slot quantities.

     C                   eval      slstk1 = slstk1 + $slstk1
     C                   eval      slstk2 = slstk2 + $slstk2
     C                   eval      slstk3 = slstk3 + $slstk3

     C                   eval      slalc1 = slalc1 + $slalc1
     C                   eval      slalc2 = slalc2 + $slalc2
     C                   eval      slalc3 = slalc3 + $slalc3

     C                   eval      sltfr1 = sltfr1 + $sltfr1
     C                   eval      sltfr2 = sltfr2 + $sltfr2
     C                   eval      sltfr3 = sltfr3 + $sltfr3

     C                   eval      slpck1 = slpck1 + $slpck1
     C                   eval      slpck2 = slpck2 + $slpck2
     C                   eval      slpck3 = slpck3 + $slpck3

     C                   eval      slrcv1 = slrcv1 + $slrcv1
     C                   eval      slrcv2 = slrcv2 + $slrcv2
     C                   eval      slrcv3 = slrcv3 + $slrcv3

     *  See if status should change.

     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnewstat         2
     C                   parm                    $creturn          8

     C                   if        $creturn  = '*CHANGED'
     C                   eval      slstat = $cnewstat
     C                   exsr      getdatetime
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   if        slstat = 'A'
     C                   eval      slentd = curdate
     C                   endif
     C                   endif

     *  Get item information.

     C                   eval      check4err = *off
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = slitem
     C                   exsr      getitem

     *  Try to "up" breakdown quantities.

     C                   dow       $itumq3 > 0 and slavl3 > $itumq3
     C                   eval      slstk3 = slstk3 - $itumq3
     C                   eval      slavl3 = slavl3 - $itumq3
     C                   eval      slstk2 = slstk2 + 1
     C                   eval      slavl2 = slavl2 + 1
     C                   enddo

     C                   dow       $itumq2 > 0 and slavl2 > $itumq2
     C                   eval      slstk2 = slstk2 - $itumq2
     C                   eval      slavl2 = slavl2 - $itumq2
     C                   eval      slstk1 = slstk1 + 1
     C                   eval      slavl1 = slavl1 + 1
     C                   enddo

     *  Update record.

     C                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDSTKERR'
     C                   exsr      getmsg
     C                   goto      endupdqty
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = $slstk1
510aAC                   eval      $uqty2 = $slstk2
510aAC                   eval      $uqty3 = $slstk3
510aAC                   exsr      updslotdte

     *  Recalculate slot quantities.

     C                   exsr      calcqtys
     C                   exsr      slot2ds

     C     endupdqty     endsr

510aA*----------------------------------------------------------------
510aA*  updslotdte  Update slotdte records.
510aA*----------------------------------------------------------------
510aA
510aAC     updslotdte    begsr

     C                   call      'UPDSLTDTE'
     C                   parm                    $ucmd             8
     C                   parm      $pprogram     $upgm            10
     C                   parm      #prog         $upgm2           10
     C                   parm      slwhse        $uwhse            3 0
     C                   parm      slwhdp        $uwhdp            5
     C                   parm      sldisp        $uslot           12
     C                   parm      slpick        $upick            1
     C                   parm      slitem        $uitem           15
     C                   parm      ' '           $unewi           15
     C                   parm      slentd        $uentd            8 0
     C                   parm      slexpd        $uexpd            8 0
     C                   parm                    $uqty1            5 0
     C                   parm                    $uqty2            5 0
     C                   parm                    $uqty3            5 0
     C                   parm      ' '           $urtn             8

     C                   endsr

     *----------------------------------------------------------------
     *  updstock   Update stock quantities.
     *----------------------------------------------------------------

     C     updstock      begsr
     C                   move      *off          error

     *  Update stock quantities.

     C                   eval      slstk1 = $slstk1
     C                   eval      slstk2 = $slstk2
     C                   eval      slstk3 = $slstk3

     *  See if status should change.

     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnewstat         2
     C                   parm                    $creturn          8

     C                   if        $creturn  = '*CHANGED'
     C                   eval      slstat = $cnewstat
     C                   exsr      getdatetime
     C                   eval      slsdte = curdate
     C                   eval      slstim = curtime
     C                   if        slstat = 'A'
     C                   eval      slentd = curdate
     C                   endif
     C                   endif

     *  Get item information.

     C                   eval      check4err = *off
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = slitem
     C                   exsr      getitem

     *  Try to "up" breakdown quantities.

     C                   dow       $itumq3 > 0 and slavl3 > $itumq3
     C                   eval      slstk3 = slstk3 - $itumq3
     C                   eval      slavl3 = slavl3 - $itumq3
     C                   eval      slstk2 = slstk2 + 1
     C                   eval      slavl2 = slavl2 + 1
     C                   enddo

     C                   dow       $itumq2 > 0 and slavl2 > $itumq2
     C                   eval      slstk2 = slstk2 - $itumq2
     C                   eval      slavl2 = slavl2 - $itumq2
     C                   eval      slstk1 = slstk1 + 1
     C                   eval      slavl1 = slavl1 + 1
     C                   enddo

     *  Update record.

416aMC                   update(e) slrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'UPDSTKERR'
     C                   exsr      getmsg
     C                   goto      endupdslot
     C                   endif
510aA
510aA*  Update slot date quantities.
510aA
510aAC                   eval      $ucmd  = '*FIFO'
510aAC                   eval      $uqty1 = $slstk1
510aAC                   eval      $uqty2 = $slstk2
510aAC                   eval      $uqty3 = $slstk3
510aAC                   exsr      updslotdte

416aA*  Recalculate slot quantities.

416aAC                   exsr      calcqtys
416aAC                   exsr      slot2ds

     C     endupdslot    endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify slot information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     *  Section must be sent.

     C                   if        not $slstypu
     C                   eval      error = *on
     C                   eval      $slstype = '1'
     C                   eval      $preturn = 'STPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Status must be sent.

     C                   if        not $slstatu
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = 'STSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  If designation is not sent set code to blank and type to 'S'.

     C                   if        not $sldesgu
     C                   eval      $sldesg = ' '
     C                   eval      #dtypeslot = 'S'
     C                   endif

     *  Item number must be sent when creating Active slot.

     C                   if        $slstat = 'A' and not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Item cannot be blank when creating Active slot.

     C                   if        $slstat = 'A' and $slitem = ' '
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'BLANKITEM'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Slot1 cannot already exist.

     C                   eval      lock = *off
     C                   exsr      getslot1
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slaisle = '1'
     C                   eval      $slloce = '1'
     C                   eval      $slrlvle = '1'
     C                   eval      $slhande = '1'
     C                   eval      $preturn = 'SLOT1EXIST'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   when      $preturn = 'OPNERRSLT1'
     C                   goto      endvfyadd
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *  Slot2 cannot already exist.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'SLOT2EXIST'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   when      $preturn = 'OPNERRSLT2'
     C                   goto      endvfyadd
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *  Verify that item is allowed in slot.

     C                   if        $slitem <> ' '
     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*VERIFYS'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Get item information.

     C                   if        $slitem <> ' '
     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETALL'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfyadd
     C                   endif
     C                   eval      check4err = *off
     C                   eval      desigcode = $itdesg
     C                   exsr      getdesig
     C                   eval      #dtypeitem = $dstype
     C                   endif

     *  When creating an active slot ...
     *    Then the dept, section and designation must match item.
     *    Otherwise, match isn't necessary.

     C                   if        $slstat = 'A' and $psubcmd <> '*ADDXDK'
     C                   if        $slwhdp <> $itwhdp or
     C                             $slstyp <> $itstyp or
     C                             $sldesg <> $itdesg and #dtypeslot ='H' or
     C                             $sldesg <> $itdesg and #dtypeitem ='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $sldesge = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Special checks when adding a fixed, active pick slot.

     C                   if        $slstyp = 'F' and
     C                             $slstat = 'A' and
     C                             $slpick = 'Y' and
     C                             $psubcmd <> '*ADDXDK'

     *    Make sure maximum number of picks slots is <= 1 if ...
     *      Department is Directed putaway
     *      or mulitple pick slots are not allowed.

     C                   if        DirectPutaway or opmpck <> 'Y'
     C                   if        $imnrpk > 1
     C                   eval      $imnrpk = 1
     C                   endif
     C                   endif

     *    Count existing active pick slots for item.


     C                   call      'CNTPICK'
     C                   parm      $slwhse       $vwhse
     C                   parm      $slitem       $vitem
     C                   parm      ' '           $vwhdp
     C                   parm      ' '           $vdisp
     C                   parm                    $vcount
     C                   parm                    $vreturn
     C                   parm                    $vmessage

     C                   if        $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfyadd
     C                   endif

     *    See if we already have maximum pick slots for item.

     C                   if        $vcount >= $imnrpk
     C                   eval      error = *on
     C                   eval      $preturn = 'PCKOVRFLW'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     C                   endif

     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifychg   Verfify slot information for change
     *----------------------------------------------------------------

     C     verifychg     begsr

     *  Get slot information.

     C                   eval      lock = *off
     C                   exsr      getslot1
     C                   if        error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slaisle = '1'
     C                   eval      $slloce = '1'
     C                   eval      $slrlvle = '1'
     C                   eval      $slhande = '1'
     C                   goto      endvfychg
     C                   endif

     *  If display changed then Slot2 cannot already exist.

     C                   if        $sldispu and $sldisp <> sldisp
     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'SLOT2EXIST'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   when      $preturn = 'OPNERRSLT2'
     C                   goto      endvfychg
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl
     C                   endif
416uA
416uA*  Status not allowed to be changed to 'V'.
416uA
416uAC                   if        $slstatu and
416uAC                             $slstat = 'V' and slstat <> 'V'
416uAC                   eval      error = *on
416uAC                   eval      $slstate = '1'
416uAC                   eval      $preturn = 'VNOTALLOW'
416uAC                   exsr      getmsg
416uAC                   goto      endvfychg
416uAC                   endif

     *  Slot status cannot be changed to 'V' when qty <> 0
     *    unless stat is already a 'Z'.

     *    Note: New status is $slstat. Old status is slstat.

 1B  C                   if        $slstatu and $slstat <> slstat and
 1B  C                             $slstat = 'V' and slstat <> 'Z'
 2B  C                   if        slstk1 <> 0  or
     C                             slstk2 <> 0  or
     C                             slstk3 <> 0  or
     C                             slalc1 <> 0  or
     C                             slalc2 <> 0  or
     C                             slalc3 <> 0  or
     C                             sltfr1 <> 0  or
     C                             sltfr2 <> 0  or
     C                             sltfr3 <> 0  or
     C                             slpck1 <> 0  or
     C                             slpck2 <> 0  or
     C                             slpck3 <> 0  or
     C                             slrcv1 <> 0  or
     C                             slrcv2 <> 0  or
     C                             slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = 'INVLDVSTAT'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Slot status cannot be changed to 'Z' when qty <> 0

     *    Note: New status is $slstat. Old status is slstat.

 1B  C                   if        $slstatu and $slstat <> slstat and
 1B  C                             $slstat = 'Z'
 2B  C                   if        slstk1 <> 0  or
     C                             slstk2 <> 0  or
     C                             slstk3 <> 0  or
     C                             slalc1 <> 0  or
     C                             slalc2 <> 0  or
     C                             slalc3 <> 0  or
     C                             sltfr1 <> 0  or
     C                             sltfr2 <> 0  or
     C                             sltfr3 <> 0  or
     C                             slpck1 <> 0  or
     C                             slpck2 <> 0  or
     C                             slpck3 <> 0  or
     C                             slrcv1 <> 0  or
     C                             slrcv2 <> 0  or
     C                             slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = 'INVLDZSTAT'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif

PAK AC                   if        client = Packers
PAK A*  Status may not be changed to QA or BL unless slot is empty.
     *    Note: New status is $slstat. Old status is slstat.
PAK AC                   if        $slstatu and $slstat <> slstat and
PAK AC                             $slstat = 'QA'
PAK AC                             or
PAK AC                             $slstatu and $slstat <> slstat and
PAK AC                             $slstat = 'BL'
PAK AC                   if        slstk1 <> 0  or
PAK AC                             slstk2 <> 0  or
PAK AC                             slstk3 <> 0  or
PAK AC                             slalc1 <> 0  or
PAK AC                             slalc2 <> 0  or
PAK AC                             slalc3 <> 0  or
PAK AC                             sltfr1 <> 0  or
PAK AC                             sltfr2 <> 0  or
PAK AC                             sltfr3 <> 0  or
PAK AC                             slpck1 <> 0  or
PAK AC                             slpck2 <> 0  or
PAK AC                             slpck3 <> 0  or
PAK AC                             slrcv1 <> 0  or
PAK AC                             slrcv2 <> 0  or
PAK AC                             slrcv3 <> 0
PAK AC                   eval      error = *on
PAK AC                   eval      $slstate = '1'
PAK AC                   eval      $preturn = 'INVLDPSTAT'
PAK AC                   exsr      getmsg
PAK AC                   goto      endvfychg
PAK AC                   endif
PAK AC                   endif
PAK AC                   endif

     *  When status is Active, item number must be present.

 1B  C                   if        $slstatu and $slstat = 'A' or
 1B  C                             not $slstatu and slstat = 'A'
 2B  C                   if        $slitemu and $slitem = ' ' or
 2B  C                             not $slitemu and slitem = ' '
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'BLANKITEM'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Item number cannot change when quantities exist.

 2B  C                   if        $slitemu and $slitem <> slitem
 1B  C                   if        $slstatu and $slstat <> 'Z' or
 1B  C                             not $slstatu and slstat <> 'Z'
 2B  C                   if        slstk1 <> 0  or
     C                             slstk2 <> 0  or
     C                             slstk3 <> 0  or
     C                             slalc1 <> 0  or
     C                             slalc2 <> 0  or
     C                             slalc3 <> 0  or
     C                             sltfr1 <> 0  or
     C                             sltfr2 <> 0  or
     C                             sltfr3 <> 0  or
     C                             slpck1 <> 0  or
     C                             slpck2 <> 0  or
     C                             slpck3 <> 0  or
     C                             slrcv1 <> 0  or
     C                             slrcv2 <> 0  or
     C                             slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITEMCHG'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif
     C                   endif

     *  Verify that item is allowed in slot.

     C                   if        $slitemu and $slitem <> ' '
     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*VERIFYS'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Get item information.

416mMC                   if        $slitemu and $slitem <> ' ' or
416mAC                             not $slitemu and slitem <> ' '
     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETALL'
     C                   if        $slitemu
     C                   eval      item# = $slitem
     C                   else
     C                   eval      item# = slitem
     C                   endif
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfychg
     C                   endif

416mAC                   eval      #slotitem = $ititem
416mAC                   eval      #slottype = $ittype
416mAC                   eval      #slotdesc = $itdesc
416mAC                   eval      #slotpdsc = $itpdsc
416mAC                   eval      #slotwhdp = $itwhdp
416mAC                   eval      #slotstyp = $itstyp
416mAC                   eval      #slotdesg = $itdesg
416mAC                   eval      #slotum1  = $itum1
416mAC                   eval      #slotflg1 = $itflg1
416mAC                   eval      #slotum2  = $itum2
416mAC                   eval      #slotumq2 = $itumq2
416mAC                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt

     C                   eval      check4err = *off
     C                   eval      desigcode = $itdesg
     C                   exsr      getdesig
     C                   eval      #dtypeitem = $dstype
     C                   endif

     *  Get slot designation type if designation wasn't sent in.
     *  If it was sent, then the type was retreived in verifygen.

     C                   if        not $sldesgu
     C                   eval      check4err = *off
     C                   eval      desigcode = sldesg
     C                   exsr      getdesig
     C                   eval      #dtypeslot = $dstype
     C                   endif

     *  For an active slot ...

     *    Then the dept, section and designation area must match item.
     *    Otherwise, match isn't necessary.

     C                   if        $slstatu and $slstat = 'A' or
     C                             not $slstatu and slstat = 'A'
     C                   if        $slwhdp <> $itwhdp or
     C                             $slstypu and $slstyp <> $itstyp or
     C                             not $slstypu and slstyp <> $itstyp or
     C                             $sldesgu and $sldesg <> $itdesg and
     C                               #dtypeslot ='H' or
     C                             $sldesgu and $sldesg <> $itdesg and
     C                               #dtypeitem ='H' or
     C                             not $sldesgu and sldesg <> $itdesg and
     C                               #dtypeslot ='H' or
     C                             not $sldesgu and sldesg <> $itdesg and
     C                               #dtypeitem ='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $sldesge = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif
     C                   endif

416mM*  Special checks for a fixed, pick slot where the
416mA*    status is being changed to Active.

     C                   if        $slstypu and $slstyp = 'F' or
     C                             not $slstypu and slstyp = 'F'
416mDC**                 if        $slstatu and $slstat = 'A' or
416mDC**                           not $slstatu and slstat = 'A'
     C                   if        $slpicku and $slpick = 'Y' or
     C                             not $slpicku and slpick = 'Y'
416mAC                   if        $slstatu and $slstat = 'A' and
416mAC                             slstat <> 'A'
510gAC                             or $slstatu and $slstat = 'A '
510gAC                             and slstat = 'A '
510gAC                             and $slitem <> slitem

     *    Make sure maximum number of picks slots is <= 1 if ...
     *      Department is Directed putaway
     *      or mulitple pick slots are not allowed.

     C                   if        DirectPutaway or opmpck <> 'Y'
     C                   if        $imnrpk > 1
     C                   eval      $imnrpk = 1
     C                   endif
     C                   endif

     *    Count existing active pick slots for item.

     C                   call      'CNTPICK'
     C                   parm      $slwhse       $vwhse
     C                   parm      $slitem       $vitem
     C                   parm      ' '           $vwhdp
     C                   parm      ' '           $vdisp
     C                   parm                    $vcount
     C                   parm                    $vreturn
     C                   parm                    $vmessage

     C                   if        $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfychg
     C                   endif
510gA
510gA*    Increment $vcount to include new slot if previous status
510gA*    was not 'A ' or status=A and item number is changing.
510gA
510gAC                   if        $slstatu and $slstat = 'A '
510gAC                             and slstat <> 'A '
510gAC                             or $slstatu and $slstat = 'A '
510gAC                             and slstat = 'A '
510gAC                             and $slitem <> slitem
510gAC                   eval      $vcount = $vcount + 1
510gAC                   endif

     *    See if we already have maximum pick slots for item.

     C                   if        $slpick = slpick and
     C                             $vcount > $imnrpk or
     C                             $slpick <> slpick and
     C                             $vcount >= $imnrpk
     C                   eval      error = *on
     C                   eval      $preturn = 'PCKOVRFLW'
     C                   exsr      getmsg
     C                   goto      endvfychg
     C                   endif

     C                   endif
     C                   endif
     C                   endif


     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifygen   General verification.
     *----------------------------------------------------------------

     C     verifygen     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Verify warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $slwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl

     *  Verify warehouse department.

     C                   eval      check4err = *on
     C                   exsr      getdept
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   goto      endvfygen
     C                   endif

     *  Aisle must be sent.

     C                   if        not $slaislu or $slaisl = ' '
     C                   eval      error = *on
     C                   eval      $slaisle = '1'
     C                   eval      $preturn = 'ASLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Location must be sent.

     C                   if        not $sllocu
     C                   eval      error = *on
     C                   eval      $slloce = '1'
     C                   eval      $preturn = 'LOCNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Location can't be negative.

     C                   if        $slloc < 0
     C                   eval      error = *on
     C                   eval      $slloce = '1'
     C                   eval      $preturn = 'NEGATIVLOC'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Level must be sent.

     C                   if        not $slrlvlu
     C                   eval      error = *on
     C                   eval      $slrlvle = '1'
     C                   eval      $preturn = 'LVLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Level can't be negative.

     C                   if        $slrlvl < 0
     C                   eval      error = *on
     C                   eval      $slrlvle = '1'
     C                   eval      $preturn = 'NEGATIVLVL'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Handstack must be sent.

     C                   if        not $slhandu
     C                   eval      error = *on
     C                   eval      $slhande = '1'
     C                   eval      $preturn = 'HNDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Slot display cannot be blank.

     C                   if        $sldispu and $sldisp = ' '
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'BLANKDISP'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Verify slot type.

     C                   if        $slstypu and $psubcmd <> '*ADDXDK'
     C                   if        $slstyp <> 'F' and $slstyp <> 'P'
     C                   eval      error = *on
     C                   eval      $slstype = '1'
     C                   eval      $preturn = 'INVLDSTYP'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif
     C                   endif

     *  Picking seq can't be negative.

     C                   if        $slpsequ and $slpseq < 0
     C                   eval      error = *on
     C                   eval      $slpseqe = '1'
     C                   eval      $preturn = 'NEGATIVPSQ'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Verify slot definition.

     C                   if        $slsdefu
     C                   eval      vfysdef = *on
     C                   call(e)   'VFYSDEF'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $slwhse       $vwhse
     C                   parm      $slsdef       $vsdef
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slsdefe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYSDEF'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slsdefe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl
     C                   endif

     *  Verify status code.

     C                   if        $slstatu
     C                   eval      vfysstat = *on
     C                   call(e)   'VFYSSTAT'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $slstat       $vstat
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYSSTAT'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl
     C                   endif

     *  Verify build code.

     C                   if        $slbldu
     C                   eval      vfybld = *on
     C                   call(e)   'VFYBLD'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $slbld        $vbld
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slblde = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYBLD'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slblde = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl
     C                   endif

     *  Verify activity zone code.

     C                   if        $slactvu
     C                   eval      vfyactv = *on
     C                   call(e)   'VFYACTV'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $slactv       $vactv
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slactve = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYACTV'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slactve = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl
     C                   endif

     *  Verify designation code.

     C                   if        $sldesgu
     C                   eval      check4err = *on
     C                   eval      desigcode = $sldesg
     C                   exsr      getdesig
     C                   if        error
     C                   eval      $sldesge = '1'
     C                   goto      endvfygen
     C                   endif
     C                   eval      #dtypeslot = $dstype
     C                   endif

     *  Verify pick flag.

     C                   if        $slpicku
     C                   if        $slpick <> 'Y' and $slpick <> 'N'
     C                   eval      error = *on
     C                   eval      $slpicke = '1'
     C                   eval      $preturn = 'INVLDPICK'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif
     C                   endif

     *  Verify reserved flag.

     C                   if        $slrsrvu
     C                   if        $slrsrv <> 'Y' and
     C                             $slrsrv <> 'N' and
     C                             $slrsrv <> 'V'
417oAC*    Item was at Reserve=Y or Reserve=N, Can't chg to V=Virtual.
417oAC                             or  slrsrv = 'Y'
417oAC                             and $slrsrv = 'V'
417oAC                             or  slrsrv = 'N'
417oAC                             and $slrsrv = 'V'
     C                   eval      error = *on
417oDC*                  eval      $slpicke = '1'
417oMC                   eval      $slrsrve = '1'
     C                   eval      $preturn = 'INVLDRSRV'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif
     C                   endif

     C     endvfygen     endsr

510dA*----------------------------------------------------------------
510dA*  verifygetrpk  GETREPACK verification
510dA*----------------------------------------------------------------
510dA
510dAC     verifygetrpk  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetrpk
     C                   endif

     *    Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetrpk
     C                   endif

     *  Get "sent" item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfygetrpk
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3

     *  Get corresponding "slot" item for "sent" item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSLOT'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfygetrpk
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
     C                   eval      #slotswgt = $itswgt
     C                   eval      #slotcwgt = $itcwgt

     C     endvfygetrpk  endsr

416jA*----------------------------------------------------------------
416jA*  verifygetxdk  GETXDK verification.
416jA*----------------------------------------------------------------
416jA
416jAC     verifygetxdk  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetxdk
     C                   endif

     *    Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetxdk
     C                   endif

     *  Get "sent" item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfygetxdk
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3

     *  Get corresponding "slot" item for "sent" item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSLOT'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfygetxdk
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt

     C     endvfygetxdk  endsr

416bA*----------------------------------------------------------------
416bA*  verifynxtprv Nxt/Prv verification.
416bA*----------------------------------------------------------------
416bA
416bAC     verifynxtprv  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif
416rA
416rA*  Checks for PICKAV.
416rA
416rAC                   if        $psubcmd = '*NXTPICKAV'
416rA
416rA*    Item must be sent.
416rA
416rAC                   if        not $slitemu
416rAC                   eval      error = *on
416rAC                   eval      $sliteme = '1'
416rAC                   eval      $preturn = 'ITMNOTSNT'
416rAC                   exsr      getmsg
416rAC                   goto      endvfynxtprv
416rAC                   endif
416rA
416rA*    Status must be sent.
416rA
416rAC                   if        not $slstatu
416rAC                   eval      error = *on
416rAC                   eval      $slstate = '1'
416rAC                   eval      $preturn = 'STSNOTSNT'
416rAC                   exsr      getmsg
416rAC                   goto      endvfynxtprv
416rAC                   endif
416tA
416tA*  If priority not sent, set to -9.
416tA
416tAC                   if        not $slprtyu
416tAC                   eval      $slprty = -9
416rAC                   endif
416rA
416rAC                   endif

     *  Checks for ITEM, OVRF and PICK.

     C                   if        $psubcmd = '*NXTITEM' or
500 AC                             $psubcmd = '*NXTITEMAV' or
     C                             $psubcmd = '*PRVITEM' or
     C                             $psubcmd = '*NXTOVRF' or
417gAC                             $psubcmd = '*NXTOVRFAV' or
500bDC**                           $psubcmd = '*GETOVRFAV' or
     C                             $psubcmd = '*PRVOVRF' or
     C                             $psubcmd = '*NXTPICK' or
417gAC                             $psubcmd = '*NXTPICKAV' or
     C                             $psubcmd = '*PRVPICK'

     *    Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Status must be sent.

     C                   if        not $slstatu
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = 'STSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Aisle must be sent.

     C                   if        not $slaislu
     C                   eval      error = *on
     C                   eval      $slaisle = '1'
     C                   eval      $preturn = 'ASLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Pick seq must be sent.

     C                   if        not $slpsequ
     C                   eval      error = *on
     C                   eval      $slpseqe = '1'
     C                   eval      $preturn = 'PSEQNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Level must be sent.

     C                   if        not $slrlvlu
     C                   eval      error = *on
     C                   eval      $slrlvle = '1'
     C                   eval      $preturn = 'LVLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Handstack must be sent.

     C                   if        not $slhandu
     C                   eval      error = *on
     C                   eval      $slhande = '1'
     C                   eval      $preturn = 'HNDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Priority must be sent.

     C                   if        not $slprtyu
     C                   eval      error = *on
     C                   eval      $slprtye = '1'
     C                   eval      $preturn = 'PRTYNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Expiration date must be sent.

     C                   if        not $slexpdu
     C                   eval      error = *on
     C                   eval      $slexpde = '1'
     C                   eval      $preturn = 'EXPDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Enter date must be sent.

     C                   if        not $slentdu
     C                   eval      error = *on
     C                   eval      $slentde = '1'
     C                   eval      $preturn = 'ENTDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Extra checks for ITEM.

     *      Pick flag must be sent.

     C                   if        $psubcmd = '*NXTITEM' or
500 AC                             $psubcmd = '*NXTITEMAV' or
     C                             $psubcmd = '*PRVITEM'
     C                   if        not $slpicku
     C                   eval      error = *on
     C                   eval      $slpicke = '1'
     C                   eval      $preturn = 'PCKNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif
     C                   endif

     C                   endif

     *  Checks for SLOTI.

     C                   if        $psubcmd = '*NXTSLOTI' or
     C                             $psubcmd = '*PRVSLOTI'

     *    Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Aisle must be sent.

     C                   if        not $slaislu
     C                   eval      error = *on
     C                   eval      $slaisle = '1'
     C                   eval      $preturn = 'ASLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Location must be sent.

     C                   if        not $sllocu
     C                   eval      error = *on
     C                   eval      $slloce = '1'
     C                   eval      $preturn = 'LOCNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Level must be sent.

     C                   if        not $slrlvlu
     C                   eval      error = *on
     C                   eval      $slrlvle = '1'
     C                   eval      $preturn = 'LVLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Handstack must be sent.

     C                   if        not $slhandu
     C                   eval      error = *on
     C                   eval      $slhande = '1'
     C                   eval      $preturn = 'HNDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     C                   endif

     *  Checks for SLOT.

     C                   if        $psubcmd = '*NXTSLOT' or
417aMC                             $psubcmd = '*PRVSLOT' or
417aAC                             $psubcmd = '*NXTVSLOT' or
417aAC                             $psubcmd = '*PRVVSLOT'

     *    Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     C                   endif
417aA
417aA*  Checks for VSLOT.
417aA
     C                   if        $psubcmd = '*NXTVSLOT' or
     C                             $psubcmd = '*PRVVSLOT'

     *    Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     *    Corresponding slot display (Base slot) must be sent.

     C                   if        not $sacdspu
     C                   eval      error = *on
     C*****              eval      $sacdspe = '1'
     C                   eval      $preturn = 'CDSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfynxtprv
     C                   endif

     C                   endif

     C     endvfynxtprv  endsr

416bA*----------------------------------------------------------------
416bA*  verifypick   Verify number of pick slots.
416bA*----------------------------------------------------------------

416bAC     verifypick    begsr

     *  Verify that the # of pick slots doesn't exceed maximum for item.

     *    Only check Fixed pick slots.

     C                   if        slstyp <> 'F' or slpick <> 'Y'
     C                   goto      endverifypick
     C                   endif

     *    Only check when receiving slot is at status 'V' or 'Z'.
     *    (For active slots we assume that this check was already done)

     C                   if        slstat <> 'V' and slstat <> 'Z'
     C                   goto      endverifypick
     C                   endif

     *      Make sure maximum number of picks slots is <= 1 if
     *         mulitple pick slots are not allowed.

     C                   if        opmpck <> 'Y' and #slotnrpk > 1
     C                   eval      #slotnrpk = 1
     C                   endif

     *      Special case for transfers ...

     *        Since we do not know the "From" slot, we do not know
     *        if we are moving from one pick slot to another.
     *        Therefore, increase the maximum by 1 to allow for this.

     *        Note: This does leave open the possibility of doing a
     *              transfer from an overflow to a new pick slot, with
     *              the end result of having more pick slots than allowed.

     C                   if        $psubcmd = '*TFROUT' or
417hAC                             $psubcmd = '*LETOUT' or
417hAC                             $psubcmd = '*PROUT' or
417hAC                             $psubcmd = '*SSOUT' or
     C                             $psubcmd = '*CLSTFROUT' or
417hAC                             $psubcmd = '*CLSLETOUT' or
417hAC                             $psubcmd = '*CLSPROUT'  or
417hAC                             $psubcmd = '*CLSSSOUT'
     C                   eval      #slotnrpk = #slotnrpk + 1
     C                   endif

     *      Count existing active pick slots for item.

     C                   call      'CNTPICK'
500kDC**                 parm      slwhse        $vwhse
500kDC**                 parm      slitem        $vitem
500kMC                   parm      $slwhse       $vwhse
500kMC                   parm      $saitem       $vitem
     C                   parm      ' '           $vwhdp
     C                   parm      ' '           $vdisp
     C                   parm                    $vcount
     C                   parm                    $vreturn
     C                   parm                    $vmessage

     C                   if        $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endverifypick
     C                   endif

     *      See if we already have maximum pick slots for item.

     C                   if        $vcount >= #slotnrpk
     C                   eval      error = *on
     C                   eval      $preturn = 'PCKOVRFLW'
     C                   exsr      getmsg
     C                   goto      endverifypick
     C                   endif

     C     endverifypick endsr

416dA*----------------------------------------------------------------
416dA*  verifyqty  Verify information when changing quantities.
416dA*----------------------------------------------------------------
416dA
416daC     verifyqty     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Verify warehouse department.

     C                   eval      check4err = *on
     C                   exsr      getdept
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   goto      endvfyqty
     C                   endif

     *  Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Item must be sent.

     C                   if        not $saitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif
417dA
417dA*  Corresponding item can only be sent for some operations.
417dA
417dAC                   if        $sacitemu
417fAC                   if        $psubcmd <> '*TFRINCHG'  and
417hAC                             $psubcmd <> '*LETINCHG'  and
417hAC                             $psubcmd <> '*PRINCHG'  and
417hAC                             $psubcmd <> '*SSINCHG'  and
417fAC                             $psubcmd <> '*TFROUTCHG' and
417hAC                             $psubcmd <> '*LETOUTCHG' and
417hAC                             $psubcmd <> '*PROUTCHG' and
417hAC                             $psubcmd <> '*SSOUTCHG' and
417fAC                             $psubcmd <> '*CLSTFICHG' and
417hAC                             $psubcmd <> '*CLSLTICHG' and
417hAC                             $psubcmd <> '*CLSPRICHG' and
417hAC                             $psubcmd <> '*CLSSSICHG' and
417fAC                             $psubcmd <> '*CLSTFOCHG' and
417hAC                             $psubcmd <> '*CLSLTOCHG' and
417hAC                             $psubcmd <> '*CLSPROCHG' and
417hAC                             $psubcmd <> '*CLSSSOCHG' and
417fAC                             $psubcmd <> '*VFYTFICHG' and
417hAC                             $psubcmd <> '*VFYLTICHG' and
417hAC                             $psubcmd <> '*VFYPRICHG' and
417hAC                             $psubcmd <> '*VFYSSICHG' and
417fAC                             $psubcmd <> '*VFYTFOCHG' and
417hAC                             $psubcmd <> '*VFYLTOCHG' and
417hAC                             $psubcmd <> '*VFYPROCHG' and
417hAC                             $psubcmd <> '*VFYSSOCHG'
417dAC                   eval      error = *on
417dAC                   eval      $saciteme = '1'
417dAC                   eval      $preturn = 'CITMNOTALW'
417dAC                   exsr      getmsg
417dAC                   goto      endvfyqty
417dAC                   endif
417dAC                   endif

     *  Adjustment qtys must be sent.

     C                   if        not $saqtyu
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'QTYNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Original qtys cannot be sent for some operations.

     C                   if        $saorgu
     C                   if        $psubcmd = '*ALLOCATE' or
     C                             $psubcmd = '*PICK'     or
     C                             $psubcmd = '*RECEIVE'  or
417hAC                             $psubcmd = '*PUTAWAY'  or
500xAC                             $psubcmd = '*STAGEPUT' or
417hAC                             $psubcmd = '*RETURN'   or
     C                             $psubcmd = '*STOCK'    or
     C                             $psubcmd = '*TFRIN'    or
417hAC                             $psubcmd = '*LETIN'    or
417hAC                             $psubcmd = '*PRIN'     or
417hAC                             $psubcmd = '*SSIN'     or
     C                             $psubcmd = '*TFROUT'   or
417hAC                             $psubcmd = '*LETOUT'   or
417hAC                             $psubcmd = '*PROUT'   or
417hAC                             $psubcmd = '*SSOUT'   or
417fAC                             $psubcmd = '*TFRINCHG'  or
417hAC                             $psubcmd = '*LETINCHG'  or
417hAC                             $psubcmd = '*PRINCHG'  or
417hAC                             $psubcmd = '*SSINCHG'  or
417fAC                             $psubcmd = '*TFROUTCHG' or
417hAC                             $psubcmd = '*LETOUTCHG' or
417hAC                             $psubcmd = '*PROUTCHG' or
417hAC                             $psubcmd = '*SSOUTCHG' or
416oAC                             $psubcmd = '*VERIFYTFI' or
417hAC                             $psubcmd = '*VERIFYLTI' or
417hAC                             $psubcmd = '*VERIFYPRI' or
417hAC                             $psubcmd = '*VERIFYSSI' or
417fMC                             $psubcmd = '*VERIFYTFO' or
417hAC                             $psubcmd = '*VERIFYLTO' or
417hAC                             $psubcmd = '*VERIFYPRO' or
417hAC                             $psubcmd = '*VERIFYSSO' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG' or
417fAC                             $psubcmd = '*VFYTFOCHG' or
417hAC                             $psubcmd = '*VFYLTOCHG' or
417hAC                             $psubcmd = '*VFYPROCHG' or
417hAC                             $psubcmd = '*VFYSSOCHG' or
500eAC                             $psubcmd = '*VERIFYPUT' or
500xAC                             $psubcmd = '*VFYSTGPUT' or
500eAC                             $psubcmd = '*VERIFYRTN'
     C                   eval      error = *on
     C                   eval      $saorg1e = '1'
     C                   eval      $saorg2e = '1'
     C                   eval      $saorg3e = '1'
     C                   eval      $preturn = 'ORGNOTALW'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif
     C                   endif

     *  Verify that there is something to do.

     C                   if        not $saqtyu  and
     C                             not $saorgu  and
     C                             not $sacwtau or
     C                             $saqty1 = 0  and
     C                             $saqty2 = 0  and
     C                             $saqty3 = 0  and
     C                             $saorg1 = 0  and
     C                             $saorg2 = 0  and
     C                             $saorg3 = 0  and
     C                             $sacwta = 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $sacwtae = '1'
     C                   eval      $preturn = 'ALLZERO'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Initialize original qty to zero if not sent.
     *    This will help with future calculations.

     C                   if        not $saorgu
     C                   eval      $saorg1 = 0
     C                   eval      $saorg2 = 0
     C                   eval      $saorg3 = 0
     C                   endif

     *  Get "sent" item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfyqty
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3
417fAC                   eval      #sentmitem = $itmitem
500cA
500cA*  If "sent" item is Alias, then set item type to parent's type.
500cA
500cAC                   if        #senttype = 'A'
500cA
500cAC                   eval      check4err = *on
500cAC                   eval      $drisubcmd = '*GETMAIN'
500cAC                   eval      item# = $itmitem
500cAC                   exsr      getitem
500cAC                   if        error
500cAC                   goto      endvfyqty
500cAC                   endif
500cA
500cAC                   eval      #senttype = $ittype
500cA
500cAC                   endif

416pA*  Shift SSB quantities.

416pAC                   exsr      shiftssbqty

     *  Get corresponding "slot" item for "sent" item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSLOT'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfyqty
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt
417fAC                   eval      #slotmitem = $itmitem

416pM*  Get corresponding SSB item for "slot" item (if any)
416pM*    (moved from before getting slot item)
416pM*    (revised to get SSB for slot item)

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSSB'
416pDC**                 eval      item# = $saitem
416pMC                   eval      item# = #slotitem
     C                   exsr      getitem

     C                   if        error

     C                   eval      error = *off
     C                   eval      ssbflag = *off
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     C                   else

     C                   eval      ssbflag = *on
     C                   eval      #ssbitem = $ititem
     C                   eval      #ssbtype = $ittype
     C                   eval      #ssbdesc = $itdesc
     C                   eval      #ssbpdsc = $itpdsc
     C                   eval      #ssbwhdp = $itwhdp
     C                   eval      #ssbstyp = $itstyp
     C                   eval      #ssbdesg = $itdesg
     C                   eval      #ssbum1  = $itum1
     C                   eval      #ssbum2  = $itum2
     C                   eval      #ssbumq2 = $itumq2
     C                   eval      #ssbum3  = $itum3
     C                   eval      #ssbumq3 = $itumq3

     C                   endif
417dA
417dA*  Get "Corresponding" item information.
417dA
417dA*    If corresponding item not sent or blank,
417dA*      then set it to $saitem.
417dA
417dAC                   if        $sacitemu <> '1' or $sacitem = ' '
417dAC                   eval      $sacitem = $saitem
417dAC                   endif
417dA
417dAC                   select
417dA*    If item and corresponding item are the same ...
417dA
417dAC                   when      $sacitem = $saitem
417dA
417dAC                   eval      #csentitem = #sentitem
417dAC                   eval      #csenttype = #senttype
417dAC                   eval      #csentdesc = #sentdesc
417dAC                   eval      #csentpdsc = #sentpdsc
417dAC                   eval      #csentwhdp = #sentwhdp
417dAC                   eval      #csentstyp = #sentstyp
417dAC                   eval      #csentdesg = #sentdesg
417dAC                   eval      #csentum1  = #sentum1
417dAC                   eval      #csentflg1 = #sentflg1
417dAC                   eval      #csentum2  = #sentum2
417dAC                   eval      #csentumq2 = #sentumq2
417dAC                   eval      #csentflg2 = #sentflg2
417dAC                   eval      #csentum3  = #sentum3
417dAC                   eval      #csentumq3 = #sentumq3
417fAC                   eval      #csentmitem = #sentmitem
417dA
417dAC                   eval      #cslotitem = #slotitem
417dAC                   eval      #cslottype = #slottype
417dAC                   eval      #cslotdesc = #slotdesc
417dAC                   eval      #cslotpdsc = #slotpdsc
417dAC                   eval      #cslotwhdp = #slotwhdp
417dAC                   eval      #cslotstyp = #slotstyp
417dAC                   eval      #cslotdesg = #slotdesg
417dAC                   eval      #cslotum1  = #slotum1
417dAC                   eval      #cslotflg1 = #slotflg1
417dAC                   eval      #cslotum2  = #slotum2
417dAC                   eval      #cslotumq2 = #slotumq2
417dAC                   eval      #cslotflg2 = #slotflg2
417dAC                   eval      #cslotum3  = #slotum3
417dAC                   eval      #cslotumq3 = #slotumq3
417dAC                   eval      #cslotnrpk = #slotnrpk
417dAC                   eval      #cslotflgd = #slotflgd
417dAC                   eval      #cslotswgt = #slotswgt
417dAC                   eval      #cslotcwgt = #slotcwgt
417fAC                   eval      #cslotmitem = #slotmitem
417dA
417dAC                   eval      #cssbitem = #ssbitem
417dAC                   eval      #cssbtype = #ssbtype
417dAC                   eval      #cssbdesc = #ssbdesc
417dAC                   eval      #cssbpdsc = #ssbpdsc
417dAC                   eval      #cssbwhdp = #ssbwhdp
417dAC                   eval      #cssbstyp = #ssbstyp
417dAC                   eval      #cssbdesg = #ssbdesg
417dAC                   eval      #cssbum1  = #ssbum1
417dAC                   eval      #cssbum2  = #ssbum2
417dAC                   eval      #cssbumq2 = #ssbumq2
417dAC                   eval      #cssbum3  = #ssbum3
417dAC                   eval      #cssbumq3 = #ssbumq3
417dA
417dA*    If item and corresponding item are different ...
417dA
417dAC                   other
417dA
417dA*      Get "sent" corresponding item information.
417dA
417dAC                   eval      check4err = *on
417dAC                   eval      $drisubcmd = '*GETMAIN'
417dAC                   eval      item# = $sacitem
417dAC                   exsr      getitem
417dAC                   if        error
417dAC                   goto      endvfyqty
417dAC                   endif
417dA
417dAC                   eval      #csentitem = $ititem
417dAC                   eval      #csenttype = $ittype
417dAC                   eval      #csentdesc = $itdesc
417dAC                   eval      #csentpdsc = $itpdsc
417dAC                   eval      #csentwhdp = $itwhdp
417dAC                   eval      #csentstyp = $itstyp
417dAC                   eval      #csentdesg = $itdesg
417dAC                   eval      #csentum1  = $itum1
417dAC                   eval      #csentflg1 = $itflg1
417dAC                   eval      #csentum2  = $itum2
417dAC                   eval      #csentumq2 = $itumq2
417dAC                   eval      #csentflg2 = $itflg2
417dAC                   eval      #csentum3  = $itum3
417dAC                   eval      #csentumq3 = $itumq3
417fAC                   eval      #csentmitem = $itmitem
417dA
417dA*      Get corresponding "slot" item for "sent" corresp. item.
417dA
417dAC                   eval      check4err = *on
417dAC                   eval      $drisubcmd = '*GETSLOT'
417dAC                   eval      item# = $sacitem
417dAC                   exsr      getitem
417dAC                   if        error
417dAC                   goto      endvfyqty
417dAC                   endif
417dA
417dAC                   eval      #cslotitem = $ititem
417dAC                   eval      #cslottype = $ittype
417dAC                   eval      #cslotdesc = $itdesc
417dAC                   eval      #cslotpdsc = $itpdsc
417dAC                   eval      #cslotwhdp = $itwhdp
417dAC                   eval      #cslotstyp = $itstyp
417dAC                   eval      #cslotdesg = $itdesg
417dAC                   eval      #cslotum1  = $itum1
417dAC                   eval      #cslotflg1 = $itflg1
417dAC                   eval      #cslotum2  = $itum2
417dAC                   eval      #cslotumq2 = $itumq2
417dAC                   eval      #cslotflg2 = $itflg2
417dAC                   eval      #cslotum3  = $itum3
417dAC                   eval      #cslotumq3 = $itumq3
417dAC                   eval      #cslotnrpk = $imnrpk
417dAC                   eval      #cslotflgd = $itflgd
417dAC                   eval      #cslotswgt = $itswgt
417dAC                   eval      #cslotcwgt = $itcwgt
417fAC                   eval      #cslotmitem = $itmitem
417dA
417dA*      Get corresponding SSB item for "slot" corr. item (if any)
417dA
417dAC                   eval      check4err = *on
417dAC                   eval      $drisubcmd = '*GETSSB'
417dAC                   eval      item# = #cslotitem
417dAC                   exsr      getitem
417dA
417dAC                   if        error
417dA
417dAC                   eval      error = *off
417dAC                   eval      cssbflag = *off
417dAC                   eval      $preturn = '*OK'
417dAC                   eval      $pmessage = ' '
417dA
417dAC                   else
417dA
417dAC                   eval      cssbflag = *on
417dAC                   eval      #cssbitem = $ititem
417dAC                   eval      #cssbtype = $ittype
417dAC                   eval      #cssbdesc = $itdesc
417dAC                   eval      #cssbpdsc = $itpdsc
417dAC                   eval      #cssbwhdp = $itwhdp
417dAC                   eval      #cssbstyp = $itstyp
417dAC                   eval      #cssbdesg = $itdesg
417dAC                   eval      #cssbum1  = $itum1
417dAC                   eval      #cssbum2  = $itum2
417dAC                   eval      #cssbumq2 = $itumq2
417dAC                   eval      #cssbum3  = $itum3
417dAC                   eval      #cssbumq3 = $itumq3
417dA
417dAC                   endif
417dA
417dAC                   endsl

     *  If breakdown quantity sent, see if it is allowed.
     *    (If item has corresponding SSB item, all qty's allowed)

     C                   if        ssbflag = *off
     C                   if        $saqty2 <> 0 and #slotflg1 <> 'Y' or
     C                             $saqty2 <> 0 and #slotumq2 <= 0   or
     C                             $saqty3 <> 0 and #slotflg2 <> 'Y' or
     C                             $saqty3 <> 0 and #slotumq3 <= 0   or
     C                             $saorg2 <> 0 and #slotflg1 <> 'Y' or
     C                             $saorg2 <> 0 and #slotumq2 <= 0   or
     C                             $saorg3 <> 0 and #slotflg2 <> 'Y' or
     C                             $saorg3 <> 0 and #slotumq3 <= 0
     C                   eval      error = *on
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'INVLDBRKQ'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif
     C                   endif
417dA
417dA*  If breakdown quantity sent,
417dA*  see if it is allowed for the "Corresponding" item.
417dA*    (If item has corresponding SSB item, all qty's allowed)
417dA
417dAC                   if        $sacitem <> $saitem
417dAC                   if        cssbflag = *off
417dAC                   if        $saqty2<>0 and #cslotflg1 <> 'Y' or
417dAC                             $saqty2<>0 and #cslotumq2 <= 0   or
417dAC                             $saqty3<>0 and #cslotflg2 <> 'Y' or
417dAC                             $saqty3<>0 and #cslotumq3 <= 0   or
417dAC                             $saorg2<>0 and #cslotflg1 <> 'Y' or
417dAC                             $saorg2<>0 and #cslotumq2 <= 0   or
417dAC                             $saorg3<>0 and #cslotflg2 <> 'Y' or
417dAC                             $saorg3<>0 and #cslotumq3 <= 0
417dAC                   eval      error = *on
417dAC                   eval      $saqty2e = '1'
417dAC                   eval      $saqty3e = '1'
417dAC                   eval      $preturn = 'INVLDCBRKQ'
417dAC                   exsr      getmsg
417dAC                   goto      endvfyqty
417dAC                   endif
417dAC                   endif
417dAC                   endif

417fA*  Extra checks for "Change" transfer requests.
417fA
417fAC                   if        $psubcmd <> '*TFRINCHG'  and
417hAC                             $psubcmd <> '*LETINCHG'  and
417hAC                             $psubcmd <> '*PRINCHG'  and
417hAC                             $psubcmd <> '*SSINCHG'  and
417fAC                             $psubcmd <> '*TFROUTCHG' and
417hAC                             $psubcmd <> '*LETOUTCHG' and
417hAC                             $psubcmd <> '*PROUTCHG' and
417hAC                             $psubcmd <> '*SSOUTCHG' and
417fAC                             $psubcmd <> '*CLSTFICHG' and
417hAC                             $psubcmd <> '*CLSLTICHG' and
417hAC                             $psubcmd <> '*CLSPRICHG' and
417hAC                             $psubcmd <> '*CLSSSICHG' and
417fAC                             $psubcmd <> '*CLSTFOCHG' and
417hAC                             $psubcmd <> '*CLSLTOCHG' and
417hAC                             $psubcmd <> '*CLSPROCHG' and
417hAC                             $psubcmd <> '*CLSSSOCHG' and
417fAC                             $psubcmd <> '*VFYTFICHG' and
417fAC                             $psubcmd <> '*VFYLTICHG' and
417fAC                             $psubcmd <> '*VFYPRICHG' and
417fAC                             $psubcmd <> '*VFYSSICHG' and
417fAC                             $psubcmd <> '*VFYTFOCHG' and
417hAC                             $psubcmd <> '*VFYLTOCHG' and
417hAC                             $psubcmd <> '*VFYPROCHG' and
417hAC                             $psubcmd <> '*VFYSSOCHG'
417fAC                   goto      skipchgtfrchk
417fAC                   endif
417fA
417fA*    Skip checks if item number not being changed.
417fA
417fAC                   if        #slotitem = #cslotitem
417fAC                   goto      skipchgtfrchk
417fAC                   endif
417fA
417fA*    First, sort out the From/To information.
417fA
417fAC                   if        $psubcmd = '*TFROUTCHG'  or
417hAC                             $psubcmd = '*LETOUTCHG'  or
417hAC                             $psubcmd = '*PROUTCHG'  or
417hAC                             $psubcmd = '*SSOUTCHG'  or
417fAC                             $psubcmd = '*CLSTFOCHG' or
417hAC                             $psubcmd = '*CLSLTOCHG' or
417hAC                             $psubcmd = '*CLSPROCHG' or
417hAC                             $psubcmd = '*CLSSSOCHG' or
417fAC                             $psubcmd = '*VFYTFOCHG' or
417hAC                             $psubcmd = '*VFYLTOCHG' or
417hAC                             $psubcmd = '*VFYPROCHG' or
417hAC                             $psubcmd = '*VFYSSOCHG'
417fA
417fAC                   eval      #fromitem  = #slotitem
417fAC                   eval      #frommitem = #slotmitem
417fAC                   eval      #fromtype  = #slottype
417fAC                   eval      #fromumq2  = #slotumq2
417fAC                   eval      #fromumq3  = #slotumq3
417fAC                   eval      #toitem    = #cslotitem
417fAC                   eval      #tomitem   = #cslotmitem
417fAC                   eval      #totype    = #cslottype
417fAC                   eval      #toumq2    = #cslotumq2
417fAC                   eval      #toumq3    = #cslotumq3
417fA
417fAC                   else
417fA
417fAC                   eval      #fromitem  = #cslotitem
417fAC                   eval      #frommitem = #cslotmitem
417fAC                   eval      #fromtype  = #cslottype
417fAC                   eval      #fromumq2  = #cslotumq2
417fAC                   eval      #fromumq3  = #cslotumq3
417fAC                   eval      #toitem    = #slotitem
417fAC                   eval      #tomitem   = #slotmitem
417fAC                   eval      #totype    = #slottype
417fAC                   eval      #toumq2    = #slotumq2
417fAC                   eval      #toumq3    = #slotumq3
417fA
417fAC                   endif
417fA
417fA*    Make sure From/To items are compatible.
417fA
417fAC                   if        #fromtype='B' and #frommitem<>#toitem
417fAC                             or
417fAC                             #fromtype='S' and #frommitem<>#toitem
417fAC                             or
417fAC                             #totype='B' and #tomitem<>#fromitem
417fAC                             or
417fAC                             #totype='S' and #tomitem<>#fromitem
417fA
417fAC                   eval      error = *on
417fAC                   eval      $saitem = '1'
417fAC                   eval      $sacitem = '1'
417fAC                   eval      $preturn  = 'ITMNOTCOMP'
417fAC                   exsr      getmsg
417fAC                   goto      endvfyqty
417fA
417fAC                   endif
417fA
417fA*    When going from a Normal item to a Breakdown item,
417fA*      Then sent item UOM quanity cannot be zero.
417fA
417fAC                   if        #fromtype = ' ' and
417fAC                               (#totype = 'B' or #totype = 'S')
417fAC                   if        $saqty1 <> 0 and #fromumq2 <= 0 or
417fAC                             $saqty2 <> 0 and #fromumq3 <= 0
417fAC                   eval      error = *on
417fAC                   eval      $saitem = '1'
417fAC                   eval      $preturn  = 'BRKNOTDEF'
417fAC                   exsr      getmsg
417fAC                   goto      endvfyqty
417fAC                   endif
417fAC                   endif
417fA
417fA*    When going from a Breakdown item to a Normal item,
417fA*      Then corresponding UOM quanity cannot be zero.
417fA
417fAC                   if        (#fromtype = 'B' or #fromtype = 'S')
417fAC                               and #totype = ' '
417fAC                   if        $saqty1 <> 0 and #toumq2 <= 0 or
417fAC                             $saqty2 <> 0 and #toumq3 <= 0
417fAC                   eval      error = *on
417fAC                   eval      $saitem = '1'
417fAC                   eval      $preturn  = 'BRKNOTDEF'
417fAC                   exsr      getmsg
417fAC                   goto      endvfyqty
417fAC                   endif
417fAC                   endif
417fA
417fA*    When going from a Breakdown item to a Normal item,
417fA*      Then make sure qty is evenly divisible by UOM quantity.
417fA
417fAC                   if        (#fromtype = 'B' or #fromtype = 'S')
417fAC                               and #totype = ' '
417fA
417fAC                   if        $saqty1 > 0
417fAC     $saqty1       div       #toumq2       temp5n
417fAC                   mvr                     remainder
417fAC                   if        remainder > 0
417fAC                   eval      error = *on
417fAC                   eval      $saqty1e = '1'
417fAC                   eval      $preturn  = 'INVLDQTY1'
417fAC                   exsr      getmsg
417fAC                   goto      endvfyqty
417fAC                   endif
417fAC                   endif
417fA
417fAC                   if        $saqty2 > 0
417fAC     $saqty2       div       #toumq3       temp5n
417fAC                   mvr                     remainder
417fAC                   if        remainder > 0
417fAC                   eval      error = *on
417fAC                   eval      $saqty2e = '1'
417fAC                   eval      $preturn  = 'INVLDQTY2'
417fAC                   exsr      getmsg
417fAC                   goto      endvfyqty
417fAC                   endif
417fAC                   endif
417fA
417fAC                   endif
417fA
417fAC     skipchgtfrchk tag

     *  Get slot - Lock it if not verifying or doing manual putaway.

     C                   if        $psubcmd = '*VERIFY'    or
     C                             $psubcmd = '*VERIFYORD' or
416oAC                             $psubcmd = '*VERIFYTFI' or
417hAC                             $psubcmd = '*VERIFYLTI' or
417hAC                             $psubcmd = '*VERIFYPRI' or
417hAC                             $psubcmd = '*VERIFYSSI' or
     C                             $psubcmd = '*VERIFYTFO' or
417hAC                             $psubcmd = '*VERIFYLTO' or
417hAC                             $psubcmd = '*VERIFYPRO' or
500eAC                             $psubcmd = '*VERIFYPUT' or
500xAC                             $psubcmd = '*VFYSTGPUT' or
500eAC                             $psubcmd = '*VERIFYRTN' or
417hAC                             $psubcmd = '*VERIFYSSO' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG' or
417fAC                             $psubcmd = '*VFYTFOCHG' or
417hAC                             $psubcmd = '*VFYLTOCHG' or
417hAC                             $psubcmd = '*VFYPROCHG' or
417hAC                             $psubcmd = '*VFYSSOCHG' or
     C                             $psubcmd = '*RECEIVE'
     C                                and ManualPutaway    or
417hAC                             $psubcmd = '*PUTAWAY'
417hAC                                and ManualPutaway    or
500xAC                             $psubcmd = '*STAGEPUT'
500xAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*RETURN'
417hAC                                and ManualPutaway    or
     C                             $psubcmd = '*CLSRCV'
     C                                and ManualPutaway    or
417sAC                             $psubcmd = '*CLSRCVADJ'
417sAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSRTN'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSPUTAWY'
417hAC                                and ManualPutaway    or
500xAC                             $psubcmd = '*CLSSTGPUT'
500xAC                                and ManualPutaway    or
     C                             $psubcmd = '*TFRIN'
     C                                and ManualPutaway    or
417hAC                             $psubcmd = '*LETIN'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*PRIN'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*SSIN'
417hAC                                and ManualPutaway    or
417fAC                             $psubcmd = '*TFRINCHG'
417fAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*LETINCHG'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*PRINCHG'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*SSINCHG'
417hAC                                and ManualPutaway    or
     C                             $psubcmd = '*CLSTFRIN'
417fMC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSLETIN'
417hMC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSPRIN'
417hMC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSSSIN'
417hMC                                and ManualPutaway    or
417fAC                             $psubcmd = '*CLSTFICHG'
417fAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSLTICHG'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSPRICHG'
417hAC                                and ManualPutaway    or
417hAC                             $psubcmd = '*CLSSSICHG'
417hAC                                and ManualPutaway
     C                   eval      lock = *off
     C                   else
     C                   eval      lock = *on
     C                   endif
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfyqty
     C                   endif

     *  Get itemqty record - Lock if not verifying.

     C                   eval      check4err = *on
     C                   if        $psubcmd = '*VERIFY'    or
     C                             $psubcmd = '*VERIFYORD' or
416oAC                             $psubcmd = '*VERIFYTFI' or
417hAC                             $psubcmd = '*VERIFYLTI' or
417hAC                             $psubcmd = '*VERIFYPRI' or
417hAC                             $psubcmd = '*VERIFYSSI' or
417fMC                             $psubcmd = '*VERIFYTFO' or
417hAC                             $psubcmd = '*VERIFYLTO' or
417hAC                             $psubcmd = '*VERIFYPRO' or
417hAC                             $psubcmd = '*VERIFYSSO' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG' or
417fAC                             $psubcmd = '*VFYTFOCHG' or
417hAC                             $psubcmd = '*VFYLTOCHG' or
417hAC                             $psubcmd = '*VFYPROCHG' or
417hAC                             $psubcmd = '*VFYSSOCHG' or
500eAC                             $psubcmd = '*VERIFYPUT' or
500xAC                             $psubcmd = '*VFYSTGPUT' or
500eAC                             $psubcmd = '*VERIFYRTN'
     C                   eval      lock = *off
     C                   else
     C                   eval      lock = *on
     C                   endif
     C                   exsr      getitemqty
     C                   if        error
     C                   eval      $saiteme = '1'
     C                   goto      endvfyqty
     C                   endif

417fA*  For "change" transfers In's, convert quantity if necessary.
417fA*    (Note: This is duplicated in QTYCLSRCV and QTYRECEIVE).

417fAC                   if        $psubcmd = '*TFRINCHG'  or
417hAC                             $psubcmd = '*LETINCHG'  or
417hAC                             $psubcmd = '*PRINCHG'  or
417hAC                             $psubcmd = '*SSINCHG'  or
417fAC                             $psubcmd = '*CLSTFICHG' or
417hAC                             $psubcmd = '*CLSLTICHG' or
417hAC                             $psubcmd = '*CLSPRICHG' or
417hAC                             $psubcmd = '*CLSSSICHG' or
417fAC                             $psubcmd = '*VFYTFICHG' or
417hAC                             $psubcmd = '*VFYLTICHG' or
417hAC                             $psubcmd = '*VFYPRICHG' or
417hAC                             $psubcmd = '*VFYSSICHG'

417fAC                   select

417fAC                   when      #fromtype = ' ' and
417fAC                               (#totype = 'B' or #totype = 'S')
     C                   eval      $saqty1 = $saqty1 * #fromumq2
     C                   eval      $saqty2 = $saqty2 * #fromumq3

417fAC                   when      (#fromtype = 'B' or #fromtype = 'S')
417fAC                               and #totype = ' '
     C                   if        $saqty1 <> 0 and #toumq2 > 0
     C                   eval      $saqty1 = $saqty1 / #toumq2
417fAC                   endif
     C                   if        $saqty2 <> 0 and #toumq3 > 0
     C                   eval      $saqty2 = $saqty2 / #toumq3
417fAC                   endif

417fAC                   endsl

417fAC                   endif

     *  Converty adjustment quantities to lowest uom quantitiy.

     C                   if        #slotumq2 <= 0
     C                   eval      #slotumq2 = 1
     C                   endif

     C                   if        #slotumq3 <= 0
     C                   eval      #slotumq3 = 1
     C                   endif

     C                   eval      lowiaqty = ($saqty1 * #slotumq2 * #slotumq3)
     C                                      + ($saqty2 * #slotumq3)
     C                                      + $saqty3

     C                   eval      lowiaorg = ($saorg1 * #slotumq2 * #slotumq3)
     C                                      + ($saorg2 * #slotumq3)
     C                                      + $saorg3

     *    Converty warehouse available qtys to lowest uom quantitiy.

     C                   eval      lowwhavl = ($iqavl1 * #slotumq2 * #slotumq3)
     C                                      + ($iqavl2 * #slotumq3)
     C                                      + $iqavl3

     C     endvfyqty     endsr

     *----------------------------------------------------------------
     *  verifyqtyadj  Verification for *ADJUST/*ADJUSTORD
     *----------------------------------------------------------------

     C     verifyqtyadj  begsr
     C                   move      *off          error

     *  Validate adjustment code.

     C                   eval      vfyadjc = *on
     C                   call(e)   'VFYADJC'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $sacode       $vcode
416aAC                   parm      ' '           $vsys
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYADJC'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endverifyqa

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $sacodee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endverifyqa

     C                   endsl

     *  Calculate new available.

     C                   eval      newavlqty1  = slavl1 + $saqty1
     C                   eval      newavlqty2  = slavl2 + $saqty2
     C                   eval      newavlqty3  = slavl3 + $saqty3
510fA
510fA*    Convert new available qtys to lowest uom quantitiy.
510fA
510fAC                   eval      lownewavl = (newavlqty1
510fAC                                           * #slotumq2 * #slotumq3)
510fAC                                       + (newavlqty2 * #slotumq3)
510fAC                                       + newavlqty3

     *  New available quantities cannot be negative ...
     *    when doing a normal adjustment and reducing quantity.

     C                   if        $psubcmd = '*VERIFY' or
     C                             $psubcmd = '*ADJUST'
510fDC**                 if        newavlqty1 < 0 and $saqty1 < 0 or
510fDC**                           newavlqty2 < 0 and $saqty2 < 0 or
510fDC**                           newavlqty3 < 0 and $saqty3 < 0
510fMC                   if        lownewavl < 0 and lowiaqty < 0
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'NEGAVLSLT'
     C                   exsr      getmsg
     C                   goto      endverifyqa
     C                   endif
     C                   endif

     *  New warehouse available quantity cannot be negative ...
     *    when doing a normal adjustment.

     C                   if        $psubcmd = '*VERIFY' or
     C                             $psubcmd = '*ADJUST'
500dDC**                 if        (lowiaqty + lowwhavl) < 0
500dDC**                 eval      error = *on
500dDC**                 eval      $saqty1e = '1'
500dDC**                 eval      $saqty2e = '1'
500dDC**                 eval      $saqty3e = '1'
500dDC**                 eval      $preturn = 'NEGAVLWHS'
500dDC**                 exsr      getmsg
500dDC**                 goto      endverifyqa
500dDC**                 endif
     C                   endif

     C     endverifyqa   endsr

416dA*----------------------------------------------------------------
416dA*  verifyrcv  Verify information when receiving.
416dA*----------------------------------------------------------------
416dA
416daC     verifyrcv     begsr

     *  Directed putaway checks.

     C                   if        DirectPutaway
     C                   exsr      verifyrcvd
     C                   if        error
     C                   goto      endvfyrcv
     C                   endif
     C                   endif

     *  Manual putaway checks.

     C                   if        ManualPutaway
     C                   exsr      verifyrcvm
     C                   if        error
     C                   goto      endvfyrcv
     C                   endif
     C                   endif
417sA
417sA*  Special check for *CLSRCVADJ.
417sA
417sAC                   if        $psubcmd = '*CLSRCVADJ'
417sA
417sA*    Validate adjustment code.
417sA
417sAC                   eval      vfyadjc = *on
417sAC                   call(e)   'VFYADJC'
417sAC                   parm      '*VERIFY'     $vcommand
417sAC                   parm      '*NONE'       $vprg
417sAC                   parm      $sacode       $vcode
417sAC                   parm      ' '           $vsys
417sAC                   parm      ' '           $vdesc
417sAC                   parm      ' '           $vreturn
417sAC                   parm      ' '           $vmessage
417sAC                   parm      ' '           $vmsgk
417sA
417sAC                   select
417sAC                   when      %error
417sAC                   eval      error = *on
417sAC                   eval      $preturn  = 'CALLERROR'
417sAC                   eval      $pmessage = 'Error occured on call to '
417sAC                                       + 'VFYADJC'
417sAC                                       + '/' + %trim($vcommand)
417sAC                                       + ' from ' + #prog
417sAC                   goto      endvfyrcv
417sA
417sAC                   when      $vreturn <> '*OK'
417sAC                   eval      error = *on
417sAC                   eval      $sacodee = '1'
417sAC                   eval      $preturn = $vreturn
417sAC                   eval      $pmessage = $vmessage
417sAC                   goto      endvfyrcv
417sA
417sAC                   endsl
417sA
417sAC                   endif

     C     endvfyrcv     endsr

416dA*----------------------------------------------------------------
416dA*  verifyrcvd   Verify for Directed putaway department.
416dA*----------------------------------------------------------------
416dA
416daC     verifyrcvd    begsr
416oAC                   eval      vslotcreated = *off

     *  If called from RC160 (Directed Putaway)
     *    then we can skip the rest of the checks.

     C                   if        $pprogram = 'RC160'
     C                   goto      endvfyrcvd
     C                   endif

     *  Make sure that slot contains "slot" item ...
     *    except when dealing with a Verified slot.

     C                   if        slstat <> 'V' and slitem <> #slotitem
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   goto      endvfyrcvd
     C                   endif

     *  If receiving into an Active or Verified slot ...
     *    Then the dept, section and designation must match.
     *    Otherwise, match isn't necessary.

     C                   if        slstat = 'A' or slstat = 'V'
     C                   if        slwhdp <> #slotwhdp  or
     C                             slstyp <> #slotstyp  or
     C                             sldesg <> #slotdesg
     C                               and #dtypeslot ='H' or
     C                             sldesg <> #slotdesg
     C                               and #dtypeitem ='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $sldesge = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfyrcvd
     C                   endif
     C                   endif

     *  Cannot reduce the quantity of a 'Z' or 'V' slot.

     C                   if        slstat = 'V' or slstat = 'Z'
     C                   if        ($saqty1 - $saorg1) < 0 or
     C                             ($saqty2 - $saorg2) < 0 or
     C                             ($saqty3 - $saorg3) < 0
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn = 'NEGRCVQTY'
     C                   exsr      getmsg
     C                   goto      endvfyrcvd
     C                   endif
     C                   endif

     *  Verify that the # of pick slots doesn't exceed maximum for item.

     C                   exsr      verifypick
     C                   if        error
     C                   goto      endvfyrcvd
     C                   endif

     C     endvfyrcvd    endsr

416dA*----------------------------------------------------------------
416dA*  verifyrcvm   Verify for Manual putaway department.
416dA*----------------------------------------------------------------
416dA
416daC     verifyrcvm    begsr
     C                   eval      vslotcreated = *off

500fA*  Virtual slot is not allowed to be sent.
500fA
500fAC                   if        slrsrv = 'V'
500fAC                   eval      error = *on
500fAC                   eval      $slwhdpe = '1'
500fAC                   eval      $sldispe = '1'
500fAC                   eval      $preturn = 'VIRTLSLOT'
500fAC                   exsr      getmsg
500fAC                   goto      endvfyrcvm
500fAC                   endif

     *  If reducing quantity,
     *    assume we are adjusting an existing slot and skip lookup.

     C                   if        ($saqty1 - $saorg1) < 0 or
     C                             ($saqty2 - $saorg2) < 0 or
     C                             ($saqty3 - $saorg3) < 0
     C                   goto      haveslot
     C                   endif

417jA*  If slot is inactive, prevent receiving into slot.
417jA
416jAC                   if        $psubcmd = '*RECEIVE'  or
417jMC                             $psubcmd = '*PUTAWAY'  or
500xAC                             $psubcmd = '*STAGEPUT' or
417jMC                             $psubcmd = '*RETURN'   or
416jAC                             $psubcmd = '*CLSRCV'   or
416sAC                             $psubcmd = '*CLSRCVADJ' or
417jMC                             $psubcmd = '*CLSRTN'   or
417jMC                             $psubcmd = '*CLSPUTAWY' or
500xAC                             $psubcmd = '*CLSSTGPUT' or
PCKaDC**                           $psubcmd = '*VERIFYPUT' or
PCKaMC                             $psubcmd = '*VERIFYPUT' and
PCKaAC                             client <> 'PACKERS'     or
500xAC                             $psubcmd = '*VFYSTGPUT' or
PCKaDC**                           $psubcmd = '*VERIFYRTN'
PCKaMC                             $psubcmd = '*VERIFYRTN' and
PCKaAC                             client <> 'PACKERS'
417jAC                   if        slstat <> 'A' and
417jAC                             slstat <> 'V' and
417jAC                             slstat <> 'Z'
PCKcAC                             and client <> Packers
PCKcA*
PCKcA*      Allow Special Order status slots to be putaway.
PCKcAC                             or  client = Packers
PCKcAC                             and (slstat <> 'A'
PCKcAC                             and  slstat <> 'V'
PCKcAC                             and  slstat <> 'Z'
PCKcAC                             and  slstat <> 'SO')
PCKcA*
417jAC                   eval      error = *on
417jAC                   eval      $slwhdpe = '1'
417jAC                   eval      $sldispe = '1'
417jAC                   eval      $preturn = 'SLTNOTACTV'
417jAC                   exsr      getmsg
417jAC                   goto      endvfyrcvm
417jAC                   endif
417jAC                   endif

     *  See if item already exists in slot (either base or virtual).

     C                   exsr      look4slot

417jA*  If item exists in slot ...

417jA*    If item and slot have a different expiration date,
417jA*      then don't allow item to be put into slot.

417jAC                   if        found and difexpdte
417jAC                   eval      error = *on
417jAC                   eval      $slwhdpe = '1'
417jAC                   eval      $sldispe = '1'
417jAC                   eval      $slexpde = '1'
417jAC                   eval      $preturn = 'DIFEXPDTE'
PCKbAC                   if        client = 'PACKERS'
PCKbAC                   eval      $slpicke = '3'
PCKbAC                   endif
417jAC                   exsr      getmsg
417jAC                   goto      endvfyrcvm
417jAC                   endif

417jA*  Otherwise ...
     *  If item exists in slot then we can skip trying to create a slot.

     C                   if        found
     C                   goto      haveslot
     C                   endif

     *  Re-retreive base slot. Info was destroyed in look4slot routines.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfyrcvm
     C                   endif

     *  If base slot does not have an inactive status ...
     *    Then the dept, section and designation must match.
     *    Otherwise, match isn't necessary.

     C                   if        slstat = 'A' or
     C                             slstat = 'V' or
     C                             slstat = 'Z'
     C                   if        slwhdp <> #slotwhdp  or
     C                             slstyp <> #slotstyp  or
     C                             sldesg <> #slotdesg
     C                               and #dtypeslot ='H' or
     C                             sldesg <> #slotdesg
     C                               and #dtypeitem ='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $sldesge = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfyrcvm
     C                   endif
     C                   endif

     *  If base slot is at 'V' status, use it.

     C                   if        slstat = 'V'
PCKcA*
PCKcA*  Treat slots with SO status and no item as Verified.
PCKcAC                             or  client = Packers
PCKcAC                             and slstat = 'SO'
PCKcAC                             and slitem = ' '
PCKcA*
     C                   exsr      verifypick
     C                   if        error
     C                   goto      endvfyrcvm
     C                   endif
     C                   goto      haveslot
     C                   endif

     *  Otherwise, try and create a virtual slot.

     C                   exsr      crtvirtual
     C                   if        error
     C                   goto      endvfyrcvm
     C                   endif

     *  We now have a slot that we can use. Now for a few more checks.

     C     haveslot      tag

416oA*  If we are just verifying and a virtual slot was created ...
416oA*    Then skip to the end.
416oA
417 AC                   if        $psubcmd = '*VERIFYTFI'
417hAC                             or $psubcmd = '*VERIFYLTI'
417hAC                             or $psubcmd = '*VERIFYPRI'
417hAC                             or $psubcmd = '*VERIFYSSI'
417gAC                             or $psubcmd = '*VFYTFICHG'
417hAC                             or $psubcmd = '*VFYLTICHG'
417hAC                             or $psubcmd = '*VFYPRICHG'
417hAC                             or $psubcmd = '*VFYSSICHG'
500eAC                             or $psubcmd = '*VERIFYPUT'
500xAC                             or $psubcmd = '*VFYSTGPUT'
500eAC                             or $psubcmd = '*VERIFYRTN'
416oAC                   if        vslotcreated
417mDC**                 goto      endvfyrcvm
417mMC                   goto      haveslot2
416oAC                   endif
417 AC                   endif

     *  Cannot update a 'Z' or 'V' slot with negative quantity.

     C                   if        slstat = 'V' or slstat = 'Z'
     C                   if        ($saqty1 - $saorg1) < 0 or
     C                             ($saqty2 - $saorg1) < 0 or
     C                             ($saqty3 - $saorg1) < 0
     C                   eval      error = *on
     C                   eval      $slitem = '1'
     C                   eval      $preturn = 'NEGRCVQTY'
     C                   exsr      getmsg
     C                   goto      endvfyrcvm
     C                   endif
     C                   endif

     *  Get and lock the slot to be used.
416oA*    - Don't lock when just verifying.

417mAC     haveslot2     tag

416oAC                   if        $psubcmd = '*VERIFYTFI'
417hAC                             or $psubcmd = '*VERIFYLTI'
417hAC                             or $psubcmd = '*VERIFYPRI'
417hAC                             or $psubcmd = '*VERIFYSSI'
417gAC                             or $psubcmd = '*VFYTFICHG'
417hAC                             or $psubcmd = '*VFYLTICHG'
417hAC                             or $psubcmd = '*VFYPRICHG'
417hAC                             or $psubcmd = '*VFYSSICHG'
500eAC                             or $psubcmd = '*VERIFYPUT'
500xAC                             or $psubcmd = '*VFYSTGPUT'
500eAC                             or $psubcmd = '*VERIFYRTN'
416oAC                   eval      lock = *off
416oAC                   else
     C                   eval      lock = *on
416oAC                   endif
     C                   eval      kywhse = slwhse
     C                   eval      kywhdp = slwhdp
     C                   eval      kydisp = sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfyrcvm
     C                   endif

     C     endvfyrcvm    endsr

416nA*----------------------------------------------------------------
416nA*  vfychgitm    Verify information when changing item in slot.
416nA*----------------------------------------------------------------
416nA
416naC     vfychgitm     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  Department must be sent.

     C                   if        not $slwhdpu or $slwhdp = ' '
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  Verify warehouse department.

     C                   eval      check4err = *on
     C                   exsr      getdept
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   goto      endvfychgitm
     C                   endif

     *  Slot display must be sent.

     C                   if        not $sldispu or $sldisp = ' '
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  New item must be sent.

     C                   if        not $saitemu or $saitem = ' '
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'NEWNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  Validate adjustment code (default is 'CI')

     C                   if        not $sacodeu   or
     C                             $sacode = ' '  or
     C                             $sacode = 'CI'

     C                   eval      $sacode = 'CI'
     C                   eval      $vsys   = 'S'

     C                   else

     C                   eval      vfyadjc = *on
     C                   call(e)   'VFYADJC'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $sacode       $vcode
416aAC                   parm      ' '           $vsys
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYADJC'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfychgitm

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $sacodee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfychgitm

     C                   endsl

     C                   endif

     *  Get slot information.

     C                   eval      lock = *off
     C                   exsr      getslot2
     C                   if        error
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldisp = '1'
     C                   goto      endvfychgitm
     C                   endif

     C                   eval      check4err = *off
     C                   eval      desigcode = sldesg
     C                   exsr      getdesig
     C                   eval      #dtypeslot = $dstype

     *  Slot cannot have a Zero or Verify status.

     C                   if        slstat = 'Z' or slstat = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldisp = '1'
     C                   eval      $preturn = 'NOTACTIVE'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  Item number cannot be changed when non-stock quantities exist.

     C                   if        slalc1 <> 0  or
     C                             slalc2 <> 0  or
     C                             slalc3 <> 0  or
     C                             sltfr1 <> 0  or
     C                             sltfr2 <> 0  or
     C                             sltfr3 <> 0  or
     C                             slpck1 <> 0  or
     C                             slpck2 <> 0  or
     C                             slpck3 <> 0  or
     C                             slrcv1 <> 0  or
     C                             slrcv2 <> 0  or
     C                             slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'NONSTKEXST'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     *  Verify that new item is allowed in slot.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*VERIFYS'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $saiteme = '1'
     C                   goto      endvfychgitm
     C                   endif

     *  Get "sent" item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfychgitm
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3

     C                   eval      check4err = *off
     C                   eval      desigcode = $itdesg
     C                   exsr      getdesig
     C                   eval      #dtypeitem = $dstype

     *  When slot is Active ...
     *    Then the dept, section and designation must match new item.
     *    Otherwise, match isn't necessary.

     C                   if        slstat = 'A'
     C                   if        slwhdp <> #sentwhdp or
     C                             slstyp <> #sentstyp or
     C                             sldesg <> #sentdesg and #dtypeslot='H' or
     C                             sldesg <> #sentdesg and #dtypeitem='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldisp  = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif
     C                   endif

     *  Special checks for a fixed, active pick slot.

     C                   if        slstyp = 'F' and
     C                             slstat = 'A' and
     C                             slpick = 'Y'

     *    Make sure maximum number of picks slots is <= 1 if ...
     *      Department is Directed putaway
     *      or mulitple pick slots are not allowed.

     C                   if        DirectPutaway or opmpck <> 'Y'
     C                   if        $imnrpk > 1
     C                   eval      $imnrpk = 1
     C                   endif
     C                   endif

     *    Count existing active pick slots for new item.

     C                   call      'CNTPICK'
     C                   parm      $slwhse       $vwhse
     C                   parm      $saitem       $vitem
     C                   parm      ' '           $vwhdp
     C                   parm      ' '           $vdisp
     C                   parm                    $vcount
     C                   parm                    $vreturn
     C                   parm                    $vmessage

     C                   if        $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfychgitm
     C                   endif

     *    See if we already have maximum pick slots for item.

     C                   if        $vcount >= $imnrpk
     C                   eval      error = *on
     C                   eval      $preturn = 'PCKOVRFLW'
     C                   exsr      getmsg
     C                   goto      endvfychgitm
     C                   endif

     C                   endif


     *  Verify itemqty record exists for new item.

     C                   eval      check4err = *on
     C                   eval      lock = *off
     C                   eval      #slotitem = $saitem
     C                   exsr      getitemqty
     C                   if        error
     C                   eval      $sldispe = '1'
     C                   goto      endvfychgitm
     C                   endif

     *  Verify itemqty record for original item.

     C                   eval      check4err = *on
     C                   eval      lock = *off
     C                   eval      #slotitem = slitem
     C                   exsr      getitemqty
     C                   if        error
     C                   eval      $sldispe = '1'
     C                   goto      endvfychgitm
     C                   endif

     C     endvfychgitm  endsr

510dA*----------------------------------------------------------------
510dA*  vfycrtrepack  Verify for *CRTREPAKP / *CRTREPAKR
510dA*----------------------------------------------------------------
510dA
510dAC     vfycrtrepack  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Verify warehouse department.

     C                   eval      check4err = *on
     C                   exsr      getdept
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   goto      endvfycrtrpk
     C                   endif

     *  Verify slot.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfycrtrpk
     C                   endif

     *  Virtual slot is not allowed to be sent.

     C                   if        slrsrv = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'VIRTLSLOT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Slot must be in Repack aisle.

     C                   if        slaisl <> 'RPK'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'SLTNOTRPK'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Verify item and that it is allowed in slot.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*VERIFYS'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfycrtrpk
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3
     C                   eval      #sentmitem = $itmitem

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
     C                   eval      #slotswgt = $itswgt
     C                   eval      #slotcwgt = $itcwgt
     C                   eval      #slotmitem = $itmitem

     *  See if item already exists in slot (either base or virtual).

     C                   exsr      look4slot

     *  If item exists in slot then we can skip trying to create a slot.

     C                   if        found
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'INSLOT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Re-retreive base slot. Info was destroyed in look4slot routines.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfycrtrpk
     C                   endif

     *  Dept and section must match item.

     C                   if        slwhdp <> #sentwhdp or
     C                             slstyp <> #sentstyp
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpk
     C                   endif

     *  Call apporpriate verification routine for command.

     C                   select
     C                   when      $psubcmd = '*CRTREPAKP'
     C                   exsr      vfycrtrepackp
     C                   when      $psubcmd = '*CRTREPAKR'
     C                   exsr      vfycrtrepackr
     C                   endsl

     C     endvfycrtrpk  endsr

510dA*----------------------------------------------------------------
510dA*  vfycrtrepackp  Verify for *CRTREPAKP
510dA*----------------------------------------------------------------
510dA
510dAC     vfycrtrepackp begsr

     *  Item must be a normal item to be a Repack Parent.

     C                   if        #senttype <> ' '
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'NOTPARENT'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpkp
     C                   endif

     C     endvfycrtrpkp endsr

510dA*----------------------------------------------------------------
510dA*  vfycrtrepackr  Verify for *CRTREPAKR
510dA*----------------------------------------------------------------
510dA
510dAC     vfycrtrepackr begsr

     *  Item must be a Repack item.

     C                   if        #senttype <> 'R'
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'NOTREPACK'
     C                   exsr      getmsg
     C                   goto      endvfycrtrpkr
     C                   endif

     C     endvfycrtrpkr endsr

500kA*----------------------------------------------------------------
500kA*  vfycrtvpick  Verify for *CRTVPICK
500kA*----------------------------------------------------------------
500kA
500KAC     vfycrtvpick   begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Department must be sent.

     C                   if        not $slwhdpu
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $preturn = 'WHDNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Verify warehouse department.

     C                   eval      check4err = *on
     C                   exsr      getdept
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   goto      endvfycrtvpck
     C                   endif

     *  Slot display must be sent.

     C                   if        not $sldispu
     C                   eval      error = *on
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'DSPNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Verify slot.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfycrtvpck
     C                   endif

     *  Virtual slot is not allowed to be sent.

     C                   if        slrsrv = 'V'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'VIRTLSLOT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  If slot is not a pick slot, prevent creating a virtual slot.

     C                   if        slpick <> 'Y'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'SLTNOTPICK'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  If slot is inactive, prevent creating a virtual slot.

     C                   if        slstat <> 'A' and
     C                             slstat <> 'V' and
     C                             slstat <> 'Z'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   eval      $preturn = 'SLTNOTACTV'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Verify item and that it is allowed in slot.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*VERIFYS'
     C                   eval      item# = $slitem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $sliteme = '1'
     C                   goto      endvfycrtvpck
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3
417fAC                   eval      #sentmitem = $itmitem

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt
417fAC                   eval      #slotmitem = $itmitem

     *  Get item designation code information.

     C                   eval      check4err = *off
     C                   eval      desigcode = $itdesg
     C                   exsr      getdesig
     C                   eval      #dtypeitem = $dstype

     *  Dept, section and designation must match item.

     C                   if        slwhdp <> $itwhdp or
     C                             slstyp <> $itstyp or
     C                             sldesg <> $itdesg and #dtypeslot ='H' or
     C                             sldesg <> $itdesg and #dtypeitem ='H'
     C                   eval      error = *on
     C                   eval      $slwhdpe = '1'
     C                   eval      $slstype = '1'
     C                   eval      $sldesge = '1'
     C                   eval      $preturn = 'ISMISMTCH'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  See if item already exists in slot (either base or virtual).

     C                   exsr      look4slot

     *  If item exists in slot then we can skip trying to create a slot.

     C                   if        found
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'INSLOT'
     C                   exsr      getmsg
     C                   goto      endvfycrtvpck
     C                   endif

     *  Re-retreive base slot. Info was destroyed in look4slot routines.

     C                   eval      lock = *off
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2
     C                   if        error
     C                   eval      $slwhdpe = '1'
     C                   eval      $sldispe = '1'
     C                   goto      endvfycrtvpck
     C                   endif

     C     endvfycrtvpck endsr

500aA*----------------------------------------------------------------
500aA*  vfygetovrfav  GETOVRFAV verification
500aA*----------------------------------------------------------------
500aA
500aAC     vfygetovrfav  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     *    Item must be sent.

     C                   if        not $slitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     *    Status must be sent.

     C                   if        not $slstatu
     C                   eval      error = *on
     C                   eval      $slstate = '1'
     C                   eval      $preturn = 'STSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     *    Aisle must be sent.

     C                   if        not $slaislu
     C                   eval      error = *on
     C                   eval      $slaisle = '1'
     C                   eval      $preturn = 'ASLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     *    Location must be sent.

     C                   if        not $sllocu
     C                   eval      error = *on
     C                   eval      $slloce = '1'
     C                   eval      $preturn = 'LOCNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     *    Level must be sent.

     C                   if        not $slrlvlu
     C                   eval      error = *on
     C                   eval      $slrlvle = '1'
     C                   eval      $preturn = 'LVLNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetovrf
     C                   endif

     C     endvfygetovrf endsr

     *----------------------------------------------------------------
     *  warningchk   Warning checks.
     *----------------------------------------------------------------

     C     warningchk    begsr

     *  Set warning type

     C                   eval      warningtype = $psubcmd

     *  Main loop.

     C                   dow       forever = forever

     *    Blank build code.

     *      See if previous warning has been overridden.

     C                   if        warningtype ='*WARNOVR' and $slblde = 'W'

     C                   if        $slbldu and $slbld = ' '
     C                   eval      error = *on
     C                   eval      $slblde = '2'
     C                   eval      $preturn = 'WARNBLD'
     C                   eval      $pmessage = 'Warning: Build code is '
     C                                       + 'blank'
     C                   goto      endwarn
     C                   endif

     C                   endif

     C                   leave
     C                   enddo

     C     endwarn       endsr

416nA*----------------------------------------------------------------
416nA*  writeadj    Write itemadj and adj label record(s).
416nA*              Original code taken from qtyadjust routine.
416nA*----------------------------------------------------------------
416nA
416nAC     writeadj      begsr

     *  Open ItemAdj and Label files.

     C                   exsr      openitemadj
     C                   if        error
     C                   goto      endwriteadj
     C                   endif

     C                   exsr      openlabel
     C                   if        error
     C                   goto      endwriteadj
     C                   endif

     *  Calculate unit weight for lowest uom.

     C                   eval      lowunitwgt = 0
416mMC                   if        $sacwta <> 0 and lowiaqty <> 0
     C                   eval      lowunitwgt = $sacwta / lowiaqty
     C                   endif
416aA
416aA*  If adjustment code is marked for only updating the host ...
416aA*    then just write label record(s).
416aA
416aAC                   if        $vsys = 'H'
416aAC                   goto      writelabel
416aAC                   endif

     *  Create adjustment record(s) ...

     C                   clear                   iarec
     C                   eval      iawhse = $slwhse
     C                   eval      iaitem = $saitem
     C                   eval      iawhdp = $slwhdp
     C                   eval      iadisp = $sldisp
     C                   eval      iacode = $sacode
     C                   eval      iamemo = $samemo
     C                   eval      iaby   = $saby
510iAC                   select
510iAC                   when      $sadate <> *zeros
510iAC                   eval      iadate = $sadate
510iAC                   eval      iatime = $satime
510iAC                   other
     C                   eval      iadate = curdate
     C                   eval      iatime = curtime
510cAC                   eval      $sadate = curdate
510cAC                   eval      $satime = curtime
510iAC                   endsl

     C                   select

     *    When only catch weight sent ...

     C                   when      $sacwta <> 0 and
     C                             $saqty1 = 0  and
     C                             $saqty2 = 0  and
     C                             $saqty3 = 0

     C                   eval      iacwta = $sacwta
     C                   write     iarec
     C                   if        %error
     C                   endif

     *    When SSB item exists ...

     C                   when      ssbflag = *on

     C                   eval      remaincw = $sacwta

     *      Write adjustment record for base item.

     C                   if        $saqty1 <> 0

     C                   eval      iaqty1 = $saqty1
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   if        $saqty2 = 0 and $saqty3 = 0
     C                   eval      iacwta = $sacwta
     C                   else
     C                   eval      iacwta = ($saqty1 * #slotumq2 * #slotumq3)
     C                                    * lowunitwgt
     C                   eval      remaincw = $sacwta - iacwta
     C                   endif
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endif

     *      Write adjustment record for SSB item.

     C                   if        $saqty2 <> 0 or $saqty3 <> 0

417pAC                   eval      iaitem = #ssbitem
     C                   eval      iaqty1 = $saqty2
     C                   eval      iaqty2 = $saqty3
     C                   eval      iaqty3 = 0
     C                   eval      iacwta = remaincw
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endif

     *    When SSB item does not exist ...

     C                   other

     *      Write single adjustment record for item.

     C                   eval      iaqty1 = $saqty1
     C                   eval      iaqty2 = $saqty2
     C                   eval      iaqty3 = $saqty3
     C                   eval      iacwta = $sacwta
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endsl

     *  Create label record(s).

416aAC     writelabel    tag

     C                   clear                   lbrec
     C                   eval      lbwhse = $slwhse
     C                   eval      lbitem = $saitem
     C                   eval      lbwhdp = $slwhdp
416aAC                   if        $vsys <> 'H'
     C                   eval      lbaisl = $slaisl
     C                   eval      lbloc  = $slloc
     C                   eval      lbrlvl = $slrlvl
     C                   eval      lbhand = $slhand
     C                   eval      lbpseq = $slpseq
     C                   eval      lbstyp = $slstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
416aAC                   endif
     C                   eval      lbdisp = $sldisp
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   eval      lbrdte = curdate
     C                   eval      lbtype = 'A'

     C                   select

     *    Write single label when only weight was sent.

     C                   when      $sacwta <> 0 and
     C                             $saqty1=0 and $saqty2=0 and $saqty3=0

     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = 'WT'
     C                   eval      lbswgt = $sacwta
     C                   write     lbrec
     C                   if        %error
     C                   endif

     *    Otherwise, write one label record for each quantity sent.
     *      Note: Not trying to compensate for catch weight rounding errors

     C                   other

     C                   if        $saqty1 <> 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
416aAC                   eval      lbqalc = $saqty1
416aAC                   if        $vsys <> 'H'
     C                   eval      lbqpck = $saqty1
416aAC                   endif
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = #slotum1
     C                   if        $saqty2 = 0 and $saqty3 = 0
     C                   eval      lbswgt = $sacwta
     C                   else
     C                   eval      lbswgt = ($saqty1 * #slotumq2 * #slotumq3)
     C                                    * lowunitwgt
     C                   endif
     C                   write     lbrec
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        $saqty2 <> 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
416aAC                   eval      lbqalc = $saqty2
416aAC                   if        $vsys <> 'H'
     C                   eval      lbqpck = $saqty2
416aAC                   endif
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = #slotum2
     C                   eval      lbswgt = $saqty2 * lowunitwgt
     C                   if        $saqty1 = 0 and $saqty3 = 0
     C                   eval      lbswgt = $sacwta
     C                   else
     C                   eval      lbswgt = ($saqty2 * #slotumq3)
     C                                    * lowunitwgt
     C                   endif
     C                   write     lbrec
     C                   if        %error
     C                   endif
     C                   endif

     C                   if        $saqty3 <> 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
416aAC                   eval      lbqalc = $saqty3
416aAC                   if        $vsys <> 'H'
     C                   eval      lbqpck = $saqty3
416aAC                   endif
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = #slotum3
     C                   if        $saqty1 = 0 and $saqty2 = 0
     C                   eval      lbswgt = $sacwta
     C                   else
     C                   eval      lbswgt = $saqty3 * lowunitwgt
     C                   endif
     C                   write     lbrec
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsl

     C     endwriteadj   endsr

     *----------------------------------------------------------------
     *  writelog    Write record to log file
     *----------------------------------------------------------------

     C     writelog      begsr

     * Get next sequence number to use.

     C     *dtaara       define    logslot#      nextseq#
     C     *lock         in        nextseq#
     C                   eval      lgslotseq# = nextseq#
     C                   if        nextseq# = 9999999
     C                   eval      nextseq# = 1
     C                   else
     C                   eval      nextseq# = nextseq# + 1
     C                   endif

     * Initialize log fields.

     C                   exsr      getdatetime

     C                   eval      lgslotdate = curdate
     C                   eval      lgslottime = curtime
     C                   eval      lgslotscmd = $psubcmd
     C                   eval      lgslotpgm  = $pprogram

     * Write log record.

     C                   select

     *   Single record if virtual slot was created.

     C                   when      vslotcreated
     C                   eval      lgslottype = 'PT'
     C                   eval      lgslotrtn  = $preturn
     C                   eval      lgslotmsg  = $pmessage
     C                   eval      lgslotdata = $slot
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     *   Single record if update was done by calling program.

     C                   when      not UpdateDakota
     C                   eval      lgslottype = 'NU'
     C                   eval      lgslotrtn  = $preturninput
     C                   eval      lgslotmsg  = $pmessageinput
     C                   eval      lgslotdata = $slotinput
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     *   Single record if error occured during update.

     C                   when      error
     C                   eval      lgslottype = 'ER'
     C                   eval      lgslotrtn  = $preturn
     C                   eval      lgslotmsg  = $pmessage
     C                   eval      lgslotdata = $slot
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     *   Single record for *ADD or *CRTXDOCK.

     C                   when      $psubcmd = '*ADD' or
416jAC                             $psubcmd = '*CRTXDOCK'
     C                   eval      lgslottype = 'PT'
     C                   eval      lgslotrtn  = $preturn
     C                   eval      lgslotmsg  = $pmessage
     C                   eval      lgslotdata = $slot
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     *   Single record for *DELETE.

     C                   when      $psubcmd = '*DELETE'  or
     C                             $psubcmd = '*DELETEI'
     C                   eval      lgslottype = 'DL'
     C                   eval      lgslotrtn  = $preturn
     C                   eval      lgslotmsg  = $pmessage
     C                   eval      lgslotdata = $slot
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     *   Before/After records for everything else.

     C                   other
     C                   eval      lgslottype = 'UB'
     C                   eval      lgslotrtn  = $preturninput
     C                   eval      lgslotmsg  = $pmessageinput
     C                   eval      lgslotdata = $slotbefore
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif
     C                   eval      lgslotseq# = nextseq#
     C                   if        nextseq# = 9999999
     C                   eval      nextseq# = 1
     C                   else
     C                   eval      nextseq# = nextseq# + 1
     C                   endif
     C                   eval      lgslottype = 'UP'
     C                   eval      lgslotrtn  = $preturn
     C                   eval      lgslotmsg  = $pmessage
     C                   eval      lgslotdata = $slot
     C                   write(e)  lgslotrec
     C                   if        %error
     C                   endif

     C                   endsl

     * Update sequence number to use.

     C                   out       nextseq#

     C     endwritelog   endsr

417cA*----------------------------------------------------------------
417cA*  zerovfy    Zero verify slot
417cA*----------------------------------------------------------------
417cA
417cAC     zerovfy       begsr
     C                   eval      error = *off

     *  Get and lock slot.

     C                   eval      lock = *on
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2

     C                   if        error
     C                   goto      endzerovfy
     C                   endif

     *  If slot is not at 'Z' status, then send back an error.

     C                   if        slstat <> 'Z' and slstat <> 'V'
     C                   eval      error = *on
     C                   eval      $preturn = 'NOTZROSTAT'
     C                   exsr      getmsg
     C                   goto      endzerovfy
     C                   endif

     *  Delete special order record(s).

     C                   exsr      deletespclord

     *  Delete Printed exception record(s).

     C                   exsr      deletevslexcp

     *  Change status code for ...

 2B  C                   select

     *    Crossdock and Virtual slots - Delete record and skip to end.

 2X  C                   when      slstyp = 'X' or
 2X  C                             slrsrv = 'V'
     C                   exsr      deleteslot
goto C                   goto      endzerovfy

     *    Verified slot - Just unlock record.

 2X  C                   when      slstat <> 'Z'
     C                   unlock    slot2

     *    Zero slot - Delete associated records and Verify slot.

 2X  C                   other
     C                   exsr      deletespclord
     C                   exsr      deletevslexcp
     C                   exsr      set2vfy

 2E  C                   endsl

     *  See if we should delete corresponding Zero virtual slots.

     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*ZEROVFY'
     C     keyop         chain     options
 1B  C                   if        not %found
     C                   eval      opvfyv = 'N'
     C                   else
     C                   eval      opdat3 = opdata
 1E  C                   endif

     *  User has chosen to verify virtuals individually, so skip to end.

 2B  C     opvfyv        cabeq     'Y'           endzerovfy

     *  Open virtual slot file.

     C                   exsr      openvslot2
     C                   if        error
     C                   goto      endzerovfy
     C                   endif

     *  Loop through virtuals for slot, delete if status 'Z'

     C     keysl2        setll     vslot2
 3B  C                   dow       forever = forever
     C     keysl2        reade     vslot2
 4B  C                   if        %eof
 3L  C                   leave
 4E  C                   endif

     C     keysl2vs      chain     slot2
 5B  C                   if        %found and slstat = 'Z'
     C                   exsr      deleteslot
     C*****              delete    slrec2
     C*****              delete    vsrec2
 5E  C                   endif

 3E  C                   enddo

     C     endzerovfy    endsr

510hA*----------------------------------------------------------------
510hA*  zerovfyauto  Auto zero verify slot
510hA*----------------------------------------------------------------
510hA
510hAC     zerovfyauto   begsr
     C                   eval      error = *off

     *  See if we are allow to auto zero verify slot.

     C                   select

     *    If slot isn't at 'Z' status do not auto verify.

     C                   when      slstat <> 'Z'
     C                   eval      autovfy = *off

     *    If slot is a Repack slot, then auto verify.

     C                   when      slaisl = 'RPK'
     C                   eval      autovfy = *on

     *    Otherwise do not auto verify.

     C                   other
     C                   eval      autovfy = *off
     C                   endsl

     *  If slot should not be auto verified, then get out.

     C                   if        not autovfy
     C                   goto      endzerovfyauto
     C                   endif

     *  Get and lock slot.

     C                   eval      lock = *on
     C                   eval      kywhse = $slwhse
     C                   eval      kywhdp = $slwhdp
     C                   eval      kydisp = $sldisp
     C                   eval      check4err = *on
     C                   exsr      getslot2

     C                   if        error
     C                   goto      endzerovfyauto
     C                   endif

     *  If slot is not at 'Z' status, then do nothing and return.

     C                   if        slstat <> 'Z'
     C                   unlock    slot2
     C                   goto      endzerovfyauto
     C                   endif

     *  Delete special order record(s).

     C                   exsr      deletespclord

     *  Delete Printed exception record(s).

     C                   exsr      deletevslexcp

     *  Delete slot date quantities.

     C                   exsr      deleteslotdte

     *  Change status code for ...

     C                   select

     *    Virtual slots - Delete record and skip to end.

     C                   when      slrsrv = 'V'
     C                   delete(e) slrec2

     *    Zero slot - Verify slot.

     C                   other
     C                   exsr      set2vfy

     C                   endsl

     C     endzerovfyautoendsr

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
