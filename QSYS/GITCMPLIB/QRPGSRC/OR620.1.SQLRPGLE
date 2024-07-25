500gA /copy qcopysrc,hspecs
750 AH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR620     Truck build - Build pallets
     *  13 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/11/97  DAS  4.00
     *      -  Major revisions for truck build process.  This program
     *         based on OR510.  Old revisions were removed to clean
     *         up program.
     *      - Initial revisions have not be marked with the version.
     *      - A new route id field is used to uniquely identify routes.
     *      - Options are now tied to zones, not departments.
     *        Therefore, file OPTIONS has been replaced with OPTIONZ.
     *        There are no override options anymore.
     *
402 A*    07/27/97  DAS  4.02
     *      -  Revised STPSUM routine to create summaries for every generation.
     *      -  Revised MERGE routine to use LWUWGT instead of LWSWGT to
     *         calculate LFTWGT.
     *
404 A*    08/04/97  DAS  4.04
     *      -  Change LW fields to ZW fields in mainline.
     *
404 A*    08/07/97  DAS  4.04
     *      -  Revised MERGE routine to include 'M' type records.
     *
404 A*    08/19/97  HNK  4.04
     *      -  Corresponding tran# update corrected in MERGE subroutine.
410 A*    11/23/98  DAS/RH 4.10
     *      -  Made revisions to deal with exception labels.
     *      -  Revised BULK routine to look at pieces instead of cube
     *         to determine if anything is already on the current
     *         pallet.
     *
410aA*    12/13/98  RH     4.10
     *      -  Additional revisions to deal with exception labels.
     *
411 A*    02/08/99  DAS    4.11
     *      -  Revised BLDPLT and MERGE routine to check for
     *         max stops per pallet.
     *      -  Revised GETPLT routine to set STPCNT to 0.
     *      -  Revised BLDPLT routine to skip update for *EXCP.
     *      -  Added MRGSTP variable to *INZSR.
     *
412 A*    09/02/99  DAS    4.12
     *      - Revised for separate pallet pick for a stop.
     *      - Added file ORDH.
     *      - Revised routines BLDPLT, BULK, MERGE and *INZSR.
     *      - Created routine CHKSP to check for separate pallet
650bM*        and to set the separate pallet flag, DPFLAG.
     *      - Revised file PLTSUM1 to include row and col
     *
412aA*    09/08/99  DAS    4.12a
     *      - Revised for PLTSUM1 key to include row and column.
     *      - Added row and col to KEYPS key list
     *      - Initialize row and col for KEYPS in appropriate places.
     *      - When creating pallets, changed the seq# from a standard
     *        99 to an incrementing number starting at 71.
     *      - Created routine CNTSTP to count the stops on a pallet.
     *      - Revised routine GETPLT to call CNTSTP instead of just
     *        setting the stop count to zero.
     *
412bA*    09/11/99  DAS    4.12b
     *      - Revised to save label record before and restore it
     *        after GETPLT call to GETPLT routine. Reason: new
     *        routine CNTSTP uses the WORKLBL6 which trashes
     *        the LW fields.
     *
413 A*    11/29/99  HNK    4.13
     *      - Revised to ignore pallet, if the maximum cube defined
     *        for this pallet is zero.
     *
414 A*    05/16/00  DAS    4.14
     *      - Revised routine INIT to use SETLL/READE to get zone
     *        instead of CHAIN. This will insure that we always get
     *        the first truck zone alphabetically when there are
     *        more than one truck zone defined for a compartment.
     *
414aA*    05/18/00  DAS    4.14a
     *      - Changed key of file ZONEH1 to include ZHZONE at the end.
     *      - Recompiled this program. No other changes were made
     *        to this program.
     *
415 A*    02/04/01  DAS  4.15
     *      - Move initialization of LSTUNL from BLDPLT routine
     *        into mainline.
     *
415aA*    03/26/01  DAS  4.15a
     *      - Change definition of NEWMAX to be based on PSCUBE (7.3)
     *        instead of PSMAXC (5.3).
     *
417aA*    06/20/03  MLB  4.17a
     *      - Fix: Revised CHKSP to re-activate code used to create new
     *        pallet when coming out of Single Pallet mode.
417bA*    06/30/03  MLB  4.17b
     *      - Added file WORKLBLA to program.
     *      - Added file WORKLBLC to program.
     *      - Added file PLTSUM5  to program.
     *      - Revised program to allow pallets to be built in reverse
     *        stop order.
417cA*    06/30/03  MLB  4.17c
     *      - Added file OPTIONS to program.
     *      - Added OPTIONSDS DS to program.
     *      - Revised program to load either a Unload sequence or Load
     *        sequence for each regular pallet.
417dA*    06/30/03  MLB  4.17d
     *      - Revised program to start new pallet everytime aisle changes
     *        when Build Method is 2=Location.
417eA*    09/29/03  MLB  4.17e
     *      - Fix: Revised BLDPLT, GETPLT to not set off single pallet
     *        indicator. This was done to fix problem with other stops
     *        being added to the single pallet stop.
500aA*    01/21/05 DAS/RH 5.00a
     *      - Fix: SETGT was not positioning correctly because
     *        LWSTOP was decending in WORKLBLC, change to SETLL.
500bA*    01/21/05 DAS/RH 5.00b
     *      - NOTE: Had to reverse 500a change, was creating double
     *        merge records for some records.  *LOVAL is -99, this
     *        causes a problem with sotp 99.  Cheney will change
     *        stop 99 to stop 1 until we can find a solution for this.
500cA*    03/17/06  JCJ  5.00c
     *      - ENH: Changed Merge routine to process Totes.
500dA*    03/23/06  DAS  5.00d
     *      - Fix: After doing BLDPLT for *EXCP, reinitialized BLDTYP.
     *
500eA*    03/31/06  DAS  5.00e
     *      - Enh: Revised program to add support for Client id
     *      - Added files WORKLBOA and WORKLBO2.
     *
500fA*    04/03/06  DAS  5.00f
     *      - Enh: Revised to work with new max pcs option value.
     *
500gA*    04/07/06  DAS  5.00g
     *      - Converted to ILE.
     *      - Changed OPTOTE to OPPTYP.
     *      - Changed MERGET into MERGETOTE
     *      - Revised how MERGETOTE was called from MERGE. Now doing
     *        it after-the-fact in order to calculate the weight of
     *        the tote.
     *
500hA*    04/12/06  DAS  5.00h
     *      - Revised how GETPLT reads PLTSUM file for gen 2 pallets
     *        when doing 3/*STOP.
     *
500iA*    04/21/06  DAS  5.00i
     *      - Revised how GETPLT reads PLTSUM file for gen 2 pallets
     *
500jA*    04/25/06  DAS  5.00j
     *      - Revised MERGET to initialize a few more WORKLBL fields.
     *      - Revised to look a PSPCS instead of PSCUBE when checking
     *        for an empty pallet/tote.
     *
500kA*    04/26/06  DAS  5.00k
     *      - Revised CRTPLT to work with column number for gen 2.
     *        Re: When picking everything 1 order to a pallet, we exceeded
     *        the 99 pallets the current method allowed.
     *
500lA*    04/26/06  DAS  5.00l
     *      - Added parms to GETPALLET.
     *
500mA*    05/04/06  DAS  5.00m
     *      - Revised MERGET to initialize ord/seq fields.
     *
500nA*    05/04/06  DAS  5.00n
     *      - Removed 2 pass method in BLDTOTE.
     *      - Start new pallet when designation changes.
     *
500oA*    05/05/06  DAS  5.00o
     *      - Added file PLTSUM8.
     *      - Revised to renumber unload seq and pal# for Merge
     *        zones.
     *        Re: OR630 used PLTSUM5, which will reverse the order
     *            when assigning transaction numbers.
     *
500pA*    05/08/06  MLB  5.00p
     *      - Fix: Revised program to set lwucub to 1.000 if cube
     *        less than or equal zero to prevent divide by zero error.
     *
500pA*    05/17/06  DAS  5.00p
     *      - Revised to use PLTSUM1 file for gen > 1.
     *      - Revised to set psunld to 0 for gen > 1.
     *      - Re: For totes the unload seq would loop because there
     *        were more than 99 totes, which would mess up the
     *        repositioning for GETPLT after coming back from CRTPLT,
     *        resulting in getting a used pallet instead of a new one.
     *      - Removed RENUMBER routine.
     *      - Removed PLTSUM8 file.
     *
510aA*    07/06/06  DAS/RH  5.10a
     *      - Fix: Revised to SETGT in BULK when processing by stop
     *        Was processing the bulk rec twice and creating an extra
     *        merge rec with different pallet #.
     *
510bA*    08/02/06  DAS  5.10b
     *      - Revised BLDTOTE to ignore cube when max pieces is used.
     *
510cA*    08/02/06  DAS  5.10b
     *      - Split BLDTOTE into 2 routines, BLDTOTECUBE and
     *        BLDTOTEPCS. BLDTOTE was left in program but is not used.
     *
510dA*    08/21/06  DAS  5.10c
     *      - Revised GETOPT routine to condition curLimitOrders by
     *        the curIsTote flag.
     *
510eA*    10/19/06  JCJ  5.10e
     *      - Removed two pass method from BLDTOTEPCS routine.  Changed the
     *        BLDTOTEPCS process to keep track of the current partial tote
     *        and fill full even if that means spliting a label to fit it
     *        on the tote and create a new label with the remaining qty.
     *        However, if a label is encountered that can fill 1 or several
     *        totes the process stop filling the current partial tote and
     *        fill as many full totes as is required and then return to
     *        the previous partial tote when done.
     *
510fA*    10/20/06  DAS  5.10f
     *      - Made fix to 510d change.
     *
510gA*    11/07/06  JCJ  5.10g
     *      - Changed BLDTOTECub routine to not put multiple stops
     *        on a palled.
     *
510hA*    11/15/06  JCJ  5.10h
     *      - Changed BLDFULLTOTE routine to initialize CURPARTIALTOTE
     *        if zeros.
     *
510iA*    11/16/06  DAS  5.10i
     *      - Revised BLDTOTEPCS, BLDFULLTOTE and BLDPARTTOTE routines
     *      - Routine FINFULLTOTE no longer used.
     *      - Added stop check to BLDTOTEPCS.
     *
510jA*    11/28/06  JCJ  5.10j
     *      - Revised CHKSP routine.
     *
510kA*    12/02/06  JCJ  5.10k
     *      - Revised GETOPT routine to only set the CurByStopOrdAsc/Dsc
     *        flags when CurOrdersPerPlt > 0.
     *
510lA*    06/02/06  DAS  5.10k
     *      - Added file WORKLBLAD, which is in slot descending order.
     *        This is done to build pallet from lightest to heaviest.
     *
510mA*    06/11/07  DAS  5.10m
     *      - Revised to allow Tote items without slots to be picked
     *        in normal BLDTOTE* routine instead of as an exception
     *        with the BLDPLT routine. Re: Tne exception method
     *        always caused confusion because it looked like multiple
     *        stops were put into a tote.
     *
510nA*    01/03/07  JCJ  5.10n
     *      - Enh: Revised to retrieve the flag that determines
     *        whether to honor the *SP processing.
     *      - (DAS) This was originally done for USF and is coded
     *        as chang 510l in their version. However, the code is
     *        slightly different between the two versions.
     *
510oA*    07/18/07  DAS  5.10o
     *      - Revised CHKSP to handle SP flag correctly.
510pA*    08/08/07  DAS/MLB  5.10p
     *      - Fix: Revised CNTSTP to use LSTSTP2 instead of LSTSTP.
     *        CNTSTP routine was corrupting the LSTSTP variable which
     *        caused bulk pick label records to be skipped and no
     *        labels generated and assigned to pallet(s) on the truck.
     *
520 A*    06/27/08  MLB  5.20
     *      - Fix: Revised BLDPLT to call CNTSTP after update to
     *        WORKLBLx file if STPCNT = 0. If single item placed on
     *        pallet and no more labels for stop, and Max Stops=1, then
     *        items from next stop will be placed on pallet because
     *        STPCNT field did not get updated.
     *
520aA*    02/29/08  DAS  520a / USFh
     *      - Revised to make gen 1 overflow pallet unload seq#'s
     *        unique. If more than 14 rows of overflow pallets
     *        need to be created, rows 15+ will have seq #'s
     *        97/98, thus causing duplicate seq #'s for the truck.
     *
520bA*    02/09/08  DAS  5.20b  P#00011
     *      - Added file TOTEHDR.
     *      - Revised TOTEMRG to write record to TOTEHDR.
     *
520cA*    10/02/08  RBD  5.20c
     *      - Fix:  Because of field size differences between
     *        TOHWGT and MRGTOTEWGT, if the value of MRGTOTEWGT
     *        is > 999.99, move 999.99 into TOHWGT.
     *        Change field name TOHNUM to TOHCNT (TOHNUM was
     *        already being used in TORDH).
     *        Also, field sizes changed for TOHNUM (now TOHCNT)
     *        and TOHPCS.
520dA*    07/30/09  RBD  5.20d
     *      - Fix:  Allow for lwgen to be > 2.
520eA*    08/19/09  JCJ  5.20e
     *      - Enh: update *pick data structure.
     *      - Enh: created a batch pick flag
     *
530 A*    11/11/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
620aA*    11/16/10  JCJ  6.20a
     *      - Added Normal Route Pallet Building of Pre-Picked items
     *        Processing.
     *
620bA*    12/14/10  DAS  6.20b
     *      - Revised routine to build pallets using only
     *        aisl/loc/lvl/hand.
     *      - Revised key of worklblf
     *
640aA*    03/15/11  JCJ  6.40a
     *      - Added GETORDH routine.
     *
640bA*    11/15/11  JCJ  6.40b
     *      - Added sort by stop descending logic in for Batch pick.
     *
640cA*    05/29/12  JCJ  640c
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest (softcoded)
     *
650 A*    02/24/13  MLB  6.50
     *      - Fix: Revised program to remove compartment test when
     *        finding highest unload sequence for the truck. Compart-
     *        ments no longer start over at 1. Fixes problem with load
     *        sequence set to 2=Load in Gen. Pick Options.
650aA*    03/11/15  MLB  6.50a
     *      - Fix: Revised 4.17c mod. Removed compartment test when
     *        computing Load Sequence (PSPAL#) for the truck. Compart-
     *        ments no longer start over at 1. Fixes problem when Load
     *        Sequence set to 2=Load in Gen. Pick Options. Was issue
     *        at RFS because truck contained multiple Load Sequences
     *        when pallets from other compartments were moved onto
     *        empty pallets in different compartment.
     *      - Note: Current code will be left in place for clients that
     *              require the Load Seq. be unique per compartment.
     *
650bA*    06/01/13  JCJ  650b
     *      - Enh: Changed *SP logic to be *DP logic.
     *      - Enh: Changed *SP logic to work with 5 digit host stop
     *        number.
     *      - Enh: Added program getstop to retrieve Host 9 digit
     *        stop number.
     *
700aA*    11/05/15  DAS  7.00a
     *      - Enh: Created bldToteBox for AMP boxes.
     *
700bA*    02/05/16  DAS  7.00b
     *      - Revised bldToteBox to leave main loop, not leave subroutine.
     *      - Revised bldToteBox to unlock worklbl if zones don't match.
     *
700cA*    02/06/16  DAS  7.00c
     *      - Added file ampbox.
     *      - Revised bldToteBox to change pltsum pallet # to box #.
700dA*    03/31/16  MLB  7.00d
     *      - Enh: Added CLIENTLOC parm to @GETCL pgm call.
700e *    06/29/16  DAS  7.00e
     *        Enh: Recompiled because AMPBOX abxbox# changed from 3.0 to 5.0
     *
700f *    07/11/16  TAB  7.00f
     *      - Added logic for option to run DFPICK mode for PrePalletBuild
     *        This code was originally setup for client (PANOS) at the
     *        beginning, but may possibly be used for other clients.
     *        2 new flags were added to determine whether LWLVL2 field
     *        is before or after deparmtent field, therefore 14 new
     *        logical files have been added.
     *
720aA*    03/29/18  DAS  7.20a
     *      - Revised *INZSR to get dataarea DragDrop2.
     *      - Revised crtplt to create gen 1 overflow pallets similar
     *        to gen 2 pallets when working with DD2.
     *      - Create dd2plts subroutine. Called from end of mainline.
     *      - Changed WORKLBL6 into an update file.
     *
720bA*    04/06/18  DAS  7.20b
     *      - Commented out 720a logic for overflow pallets
     *
720cA*    04/27/18  DAS  7.20c
     *      - Revised to use lstcl6 for gen 1 overflow
     *      - Revised to not use +/- 10% for DD2.
     *
720dA*    03/30/16  MLB  7.20d P#01349  Was 7.00b at CWD.
     *      - Enh: Revised 7.00a mod to reference WORKLBL fields with
     *        prefix LW. Required for CWD mod use of WORKLBL.
     *
720eA*    05/23/18  DAS  7.20e
     *      - For DD1 & 2, revised how the max cube of a pallet is
     *        determined. See notes.
     *
720fA*    06/04/18  DAS  7.20f
     *      - Revised to work with new max weight zone option, OPFWGT
     *
720gA*    06/14/18  DAS  7.20g
     *      - Added preventSplit option to not split a label
     *
720hA*    08/22/18  DAS  7.20h
     *      - Added preventSplitSP option to not split a label that is
     *        for a *SP order.
     *
720iA*    08/23/18  DAS  7.20i
     *      - Fix: Revised MERGE and MRGFLR routines to set work2a
     *        and work2b values when Stop changes.
     *      - Fix: Revised CHKSP routine to always get Stop info
     *        for work2a/work2b.
     *      - Re: The end of CHKSP compares values $phstpa and
     *        $phstpb, but they only get set at the beginning of CHKSP,
     *        but only when *SPFLAG is on, which doesn't get set
     *        until later in the CHKSP routine.
     *      - Fix: Revised CHKSP to set $phstpa/$phstpb to work2a/work2b
     *        when $ph values are zero. This would indicate that the
     *        RTESTP file is not being used.
     *
720jA*    09/07/18  DAS  7.20j
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced usingDD2 with tbEnhanced.
     *
720kA*    11/14/18  DAS  7.20k
     *      - Reinstated original Bulk logic of creating 'M' label rec
     *        for Advanced TB.
     *      - Revised Bulk routine to put 'B' recs into gen 7 pallet
     *        for Advanced TB, assigning each bulk to a new row/col.
     *
720lA*    11/27/18  DAS  7.20l
     *      - Revised preventSplit and preventSplitSP to allow an
     *        order detail line to be split if it is the only item
     *        on the pallet.
     *
720mA*    12/17/18  DAS  7.20m
     *      - set SPFLAG & SPFLAG2 off when OPSTOP = 'Y' in CHKSP.
     *
730aA*    05/21/19  KDE  7.30a
     *      - Set switch to read work label by lvl2 if soft coding exist
     *
730bA*    05/24/19  DAS  7.30b
     *      - Added logic to handle zero weights for 720f change.
     *
730cA*    05/30/19  DAS  7.30c
     *      - Revised LF's WORKLBD3 and WORKLBD10 to change LWLVL2
     *        key to DESCEND. See notes below.
     *      - No recompile necessary.
     *
730dA*    08/14/19  DAS  7.30d
     *      - Added preventSplitFP to prevent splitting of a
     *        Flex Pick label
     *
730eA*    10/15/19  DAS  7.30e
     *      - Revised to use WORKLBLW
     *
730fA*    12/05/19  DAS  7.30f
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
     *
740 A*    02/26/20  KDE  7.40
     *      - Revised to monitor opfwgt in case not initialized proper
     *        in zone setup.  Will force zero if fails
     *
740aA*    05/06/20  KDE  7.40a
     *      - Revised to turn on spflag based on setting in CUSTMASTXA
     *
740bA*    11/10/20  KDE  7.40b
     *      - Add routine to ensure multiple lines do not exist for the
     *        same order,seq, item, slot in same pallet position
     *
750 A*    01/27/21  KDE  7.50
     *      - Enh:  Add code to integrate new options to Prevent Item Splits
     *        (Label splits).  You can also state whether you want an empty pallet
     *        to ashorb complete label even though it exceeds max cube.  There
     *        are several points where it calculates max quantity available to be
     *        placed on pallet based on item each cube and label total cube.  This mode
     *        forces this label on an empty pallet if this setting is set
     *
750aA*    04/07/21  KDE  7.50a
     *      - Enh:  Remove DD2 extra flags if exist
     *
750bA*    07/15/21  KDE  7.50b
     *      - Enh:  Add code to control the number of item numbers on a pallet
     *        First introduced at US Foods for Multi-Site processing
     *
750cA*    07/26/21  DAS  7.50c
     *      - Added monitor around 7.50b
     *
750dA*    08/11/21  KDE  7.50d
     *      - Fix:  Reset values that track max items per pallet to
     *        crtplt routine to always reset when pallet created for
     *        other reasons
     *
750eA*    12/15/21  KDE  7.50e
     *      - Fix:  Skip 740b mod when will call order since this cannot happen
     *        with will call order.  Also added where clause on duplines sql
     *
760 A*    04/14/22  KDE  7.60
     *      - Fix:  Use setll insteadof setgt on worklbl when stop is 99
     *
     *----------------------------------------------------------------
     *  CLIENT MODS
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    06/20/03  MLB  CBI
     *      - Revised CHKSP to only put items on separate pallet when
     *        truck compartment is standard compartment; D, F or R.
     *
CBIaA*    11/17/10  DAS  CBIa
     *      - Revised to use special handling of FLRPIR zone.
     *      - It is assumed that the parent of FLRPIR is DRY.
     *      - Routine MERGE reviesd to only grab FLRPIR cases.
     *      - Routine MERGE reviesd to to call new routine MRGFLR
     *        when getting merge items for parent PKDRY.
     *      - New routen MRGFLR created. Copy of MERGE except that
     *        it is hard coded to use parent zone DRY and it will
     *        only look for FLRPIR Eaches.
CBIbA*    04/17/14  MLB  CBIb
     *      - Fix: Correction to CBIa mod. Revised program to correctly
     *        FLRPIR Eaches to PKDRY even if no other PKDRY items
     *        previously assigned to the pick zone. Pgm was not creating
     *        Merge records for the FLRPIR Each items if no PKDRY items
     *        on the route.
CBIcA*    03/23/16  MLB  CBIc
     *      - Revised CBI mod to allow *SP stops to be placed on
     *        separate pallets for certain PKxxxx zones. Ref# 2015231.
CBIdA*   10/30/16  MLB  CBId
     *     - Enh: Revised pgm to add Ocala to 6.50 mod that assigns
     *       Load Seq numbers unique to compartment instead of unique
     *       by route.
     *     - Per Hemant phone call. 10.30.16 while on-site at Ocala.
     *     - Added Riviera to Mod.  11.18.16
CBIeA*   06/11/18  MLB  CBIe
     *     - Enh: Revised pgm to add Tifton to 6.50 mod that assigns
     *       Load Seq numbers unique to compartment instead of unique
     *       by route.
     *     - Per Hemant phone call. 06.10.18 while on-site at Ocala.
     *
     *----------------------------------------------------------------
     *  CLIENT MODS
     *----------------------------------------------------------------
     *  Client Custom Revisions - Anderson DuBose
     *
ADCaA*    06/14/18  DAS  ADCa
     *      - Revised to set preventSplit *ON
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HAR A*    03/03/08  RBD  HAR   P#00011
     *      - Revised BLDTOTECUBE and BLDTOTEPCS to limit orders per
     *        tote to 1 for Walgreen's orders.
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Glazier
     *
GFCaA*    05/08/12  GJA  GFCa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *----------------------------------------------------------------
     *  Client Custom Revisions - I Supply
     *
ISYaA*    08/25/09  GJA  ISYa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett
     *
EBLaA*   06/16/07  DAS  EBLa
     *     - Made custom revision to merge Chem items from DRYP
     *       into ZCHEM zone instead of defined DRYF zone.
     *       This is done by changing the gen 2 DRYP record's
     *       LWTZON and LWPZON to ZCHEM when the record is assigned
     *       to a pallet in the BLDPLT routine.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
     *
EGFaA*   05/03/11  DAS  EGFa
     *     - Revised to set curBySlotDesc to *on for DRY zone.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJKaA*   09/02/08  DAS  MJKa
     *     - Revised BLDPLT routine to not split a label record
     *       for Contract routes. Re: For contract routes we are more
     *       concerned about keeping full pallets together than
     *       maximizize truck pallet usage.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *----------------------------------------------------------------
     *
CTWaA*   08/20/08  DAS  CTWa
     *     - Revised Tote building to break at aisle 101.
     *
CTWbA*   01/13/12  JCJ  CTWb
     *     - Commented out CTWa mod because it did not exit on
     *       City Wholesales box.
CTWcA*
CTWcA*   06/30/08  JCJ  ctwa
CTWcA*     - Revised to only execute BLDPARTTOTE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Coastal
     *
CSPa *    08/25/09  GJA  CSPa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley
     *
CPCaA*   04/27/11  JCJ  CPCa
     *     - Enh: Add weight limit to truck pallets.
     *
CPCbA*   09/02/11  JCJ  CPCb
     *     - Enh: change weight limit form 2744 to 2576.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas
     *
NCSaA*   05/15/11  JCJ  NCSa
     *     - Enh: add palletized customer logic
     *
NCSbA*   11/14/11  JCJ  NCSb
     *     - Enh: Add piece limit (tie/high) to truck pallets.
NCScA*   03/28/13  MLB  NCSc
     *     - Fix: Change to NCSb mod. Change PSMAXC1 to be defined
     *       as 7,2 instead of PSMAXC which was defined as 5,2.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas
     *
YHAaA*   05/26/11  JCJ  YHAa
     *     - Enh: Add weight limit to truck pallets.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar
     *
ASCaA*   06/28/12  RTR  ASCa
     *     - Enh: Add Agar to pallet change for ISupply ISYa
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
     *
CDI A*   08/15/16  MLB  CDI
     *     - Enh: Revised pgm to force SPFLAG = On when LWSZON = ZCART.
     *       Need to have each stop's coke cartrige items picked
     *       separately now that they are no longer using Pre-Pull.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart - Agar
     *
RFSaA*   03/06/12  RTR  RFSa
     *     - Enh: Add Reinhart Agar to pallet change for ISupply ISYa
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Royal
     *
RYLaA*    03/24/14  JCJ  RYLa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    04/09/15  MLB  CWD  P#01349
     *      - Fix: Revised program to accumulate pieces, weight and cube
     *        in multi-occur DS when processing totes. Pgm was not
     *        writing record for each order id assigned to tote.
     *      - Added files WORKLBL, WORKLBL5.
     *      - Issue was identified at Cash Wa.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Kohl
     *
KHLaA*    08/16/18  JCJ  KHLa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *
KHLbA*    08/22/18  DAS  KHLb
     *      - Revised to set preventSplitSP *ON
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Presto
     *
PFCaA*    05/06/21  KDE  PFCa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - PFG
     *
PFGaA*    11/19/18  JCJ  PFGa
     *      - Turn curBySlotDesc *on to build pallets lighest
     *        to heaviest
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Southwest Traders
     *
SWTaA*    03/21/19  JCJ  SWTa
     *      - Removed zone description from Tote item number
     *
     *----------------------------------------------------------------
412 A* Notes:
     *
412 A*   - If a stop needs to be put on a separate pallet all by
650bM*     itself, it must contain '*DP' anywhere in the order header
     *     misc. field - OHMISC.
412 A*   - Because the pallet summary file does not contain a field
     *     to identify the pallet as a single stop pallet, the max
     *     stop field, PSSTP2, field will be used. If field PSSTP1
     *     contains a stop number and PSSTP2 is zero, then this pallet
     *     is assumed to be a single stop pallet.
412 A*   - Separate pallet pick is only used when building pallets
     *     by stop and not location.
     *
720eA*   - For DD1 & 2, the maximum cube of a pallet being built is
     *     determined by taking the lesser of the following:
     *         - Max cube for truck location
     *         - Max cube for zone
     *     Therefore, the maximum cube in a truck location definintion
     *     should be the maximum that will fit in that space, not the
     *     maximum of the zone (i.e. Frz) that is going into that
     *     location. A location with a lesser location would indicate
     *     an obstruction in that location, such as a refer unit.
     *     In the end, PLTSUM 'O' rec will have the truck max cube
     *     and the PLTSUM 'P' rec will have the zone max cube.
     *
730cA*   - curBySlotDesc was defined as building pallet in lightest
     *     to heaviest order, with the assumption being the
     *     heaviest items would be in the frist slots. However, with
     *     user-defined DFPICK, we are now building in reverse
     *     Pick (DFPICK) order. To do that properly, we needed to
     *     set LWLVL2 to Descending in WORKLBD3 and WORKLBD10.
     *     Note, curBySlotDesc is only used with curByStopLocDsc.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fworkzon2  if   e           k disk
     Fpltsum1   uf   e           k disk
     F                                     rename(psrec:psrec1)
     Fpltsum2   uf a e           k disk
     F                                     rename(psrec:psrec2)
640aAFpltsum3   if   e           k disk    prefix(x)
640aAF                                     rename(psrec:psrec3)
417bAFpltsum5   uf   e           k disk
     F                                     rename(psrec:psrec5)
417bAFworklbla  uf a e           k disk
     F                                     rename(lwrec:lwreca)
510lAFworklblad uf   e           k disk
510lAF                                     rename(lwrec:lwrecad)
417bAFworklblc  if   e           k disk
     F                                     rename(lwrec:lwrecc)
     Fworklbl2  uf a e           k disk
     F                                     rename(lwrec:lwrec2)
     Fworklbl3  uf a e           k disk
     F                                     rename(lwrec:lwrec3)
     Fworklbl4  if   e           k disk
     F                                     rename(lwrec:lwrec4)
720aDF*orklbl6  if   e           k disk
720aMFworklbl6  uf a e           k disk
     F                                     rename(lwrec:lwrec6)
     Fpltstp1   uf a e           k disk
530 AFtruckh    if   e           k disk
     Ftruckd    if   e           k disk
EBLaAFzoneh     if   e           k disk    rename(zhrec:zhrec0)
     Fzoneh1    if   e           k disk
417cAFoptions   if   e           k disk
     Foptionz   if   e           k disk
     Fordh      if   e           k disk
404 AFworkzon1  if   e           k disk
     F                                     rename(zwrec:zwrec1)
500eAFworklboa  uf a e           k disk
     F                                     rename(lwrec:lwrecoa)
500eAFworklbo2  uf a e           k disk
     F                                     rename(lwrec:lwreco2)
520eAFworklble  uf a e           k disk
     F                                     rename(lwrec:lwrece)
620aAFworklblf  uf   e           k disk
620bMF                                     rename(lwrec:lwrecf)
500eAFpiritem   if   e           k disk
CWD DF*totehdr   o    e           k disk
CWD MFtotehdr   uf a e           k disk
MJKaAFrtehed    if   e           k disk
NCSbAFitemmsc   if   e           k disk
640cAFtruckhm1  if   e           k disk
700aAFampxref5  if   e           k disk
700cAFampbox    if   e           k disk
730eDF*orklbl   uf   e           k disk
730eMFworklblw  uf   e           k disk
720dAF                                     prefix(lw)
CWD AFworklbl5  if   e           k disk    prefix(lw5)
CWD AF                                     rename(lwrec:lwrec5)
730fAFbfcdebug  o  a e           k disk
700fA*----------------------------------------------------------------
700fA*  New logical files for DFPICK order
700fA*----------------------------------------------------------------
  |  FWorklbd1  UF A E           K Disk    Rename(lwrec:lwrecd1)
  |  FWorklbd2  UF A E           K Disk    Rename(lwrec:lwrecd2)
  |  FWorklbd3  UF A E           K Disk    Rename(lwrec:lwrecd3)
  |  FWorklbd4  UF A E           K Disk    Rename(lwrec:lwrecd4)
  |  FWorklbd5  UF A E           K Disk    Rename(lwrec:lwrecd5)
  |  FWorklbd6  UF A E           K Disk    Rename(lwrec:lwrecd6)
  |  FWorklbd7  UF A E           K Disk    Rename(lwrec:lwrecd7)
  |  FWorklbd8  UF A E           K Disk    Rename(lwrec:lwrecd8)
  |  FWorklbd9  UF A E           K Disk    Rename(lwrec:lwrecd9)
  |  FWorklbd10 UF A E           K Disk    Rename(lwrec:lwrecd10)
  |  FWorklbd11 UF A E           K Disk    Rename(lwrec:lwrecd11)
  |  FWorklbd12 UF A E           K Disk    Rename(lwrec:lwrecd12)
  |  FWorklbd13 UF A E           K Disk    Rename(lwrec:lwrecd13)
  |  FWorklbd14 UF A E           K Disk    Rename(lwrec:lwrecd14)
700fA*----------------------------------------------------------------
500eA*----------------------------------------------------------------
500eA*  Customer id
500eA*
500eAD @getcl          c                   const('GETCLIENT')
650bAD @getstop        c                   const('GETSTOP')
500eA*
ADCaA /COPY QCOPYSRC,ID#ADC
500eA /COPY QCOPYSRC,ID#HARBOR
EBLaA /COPY QCOPYSRC,ID#ELLENBE
MJKaA /COPY QCOPYSRC,ID#MJKELLN
ISYaA /COPY QCOPYSRC,ID#ISUPPLY
RYLaA /COPY QCOPYSRC,ID#ROYAL
GFCaA /COPY QCOPYSRC,ID#GLAZIER
CTWaA /copy qcopysrc,id#citywho
CSPaA /copy qcopysrc,id#coastal
MAT A /copy qcopysrc,id#matt
NCSaA /copy qcopysrc,id#nichola
CPCaA /copy qcopysrc,id#cpc
EGFaA /COPY QCOPYSRC,ID#EGF
YHAaA /copy qcopysrc,id#yhata
ASCaA /copy qcopysrc,id#agar
CDI A /copy qcopysrc,id#cdi
RFSaA /copy qcopysrc,id#rfs
CBI A /copy qcopysrc,id#cheney
CBIcA /COPY QCOPYSRC,Id#CHENEYR
CBIcA /COPY QCOPYSRC,Id#CHENEYO
PAN A /copy qcopysrc,id#pan
CWD A /copy qcopysrc,id#cashwa
KHLaA /COPY QCOPYSRC,ID#KHL
PFGaA /COPY QCOPYSRC,ID#PFG
PFCaA /COPY QCOPYSRC,ID#PFC
SWTaA /copy qcopysrc,id#swt

HAR A*----------------------------------------------------------------
HAR A*  Order Misc field data structures
HAR A*----------------------------------------------------------------
HAR A
HAR A /copy qcopysrc,ohmisc_har
NCSaA /copy qcopysrc,ohmisc_nch

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
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
     *    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
417bA*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
417dA*    OPNWPL  -  Start new pallet when aisle changes if build method
417dA*               is 2=Location.
500iM*    OPFORD  -  Maximum orders per pallet.
500eM*    OPPTYP  -  Pallet type (P=Pallet, T-Tote).
500cA*    OPFTOT  -  Maximum totes per pallet
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500eA*    OPFPCS  -  Maximum pieces per fixed pallet.
650bM*    OPSTOP  -  Honor *DP/*SP flag (Y=Yes, N=No).
520eA*    OPGCDE  -  USF Group Code (0-9).
520eA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520eA*    OPSPAL  -  Merge pallet should only contain
520eA*               items for single truck pallet (Y=Yes, N=No).
520eA*    OPPITM  -  Maximum items per pallet.
650aA*    OPLBL   -  Pick Label Printing method.
650aA*                N = Normal
650aA*                S = Side by Side
656aA*                C = Custom
700aA*    OPPMTZ  -  Allow multi-truck assignments.
700aA*    OPDDDO  -  Dock door drop off order.
700aA*    OPMCUB  -  Minimum cube per fixed pallet.
710aA*    OPNBPS  -  Number of Pallet Sections.
720aA*    OPFWGT  -  Maximu weight per pallet.
720aA*    OPFPLT  -  Pallet code
720aA*    OPBSEQ  -  Build sequence number
     *
     * Data structure
     *
     D opzdta          ds
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
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
400 AD  opbmrg                37     37
417dAD  opnwpl                38     38
500dAD  opford                39     40  0
500cMD  opptyp                41     41
500dAD  opftot                42     43  0
500dAD  optecb                44     48  2
500dAD  opticb                49     53  2
500dAD  optstp                54     55  0
500dAD  optord                56     57  0
500dAD  optpcs                58     60  0
510nAD  opstop                61     61
520 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
700aD ** OPGCDE moved to pos 76 as of 700
700aDD**opgcde                62     62
520eAD  oppkup                62     62
520eAD  opspal                63     63
     D  oppitm                64     67  0 inz(0)
650aAD  oplbl                 68     68
700aAD  opdddo                69     69
700aAD  opmcub                70     74  2 inz(0)
700aAD  wkmcub                70     74
700aAD  oppmtz                75     75
700aAD  opgcde                76     76
710aAD  opnbps                77     77  0 inz(0)
720aAD  opfwgt                78     81  0 inz(0)
720fAD  opfwgtalpha           78     81
720aAD  opfplt                82     87
720aAD  opbseq                88     89  0 inz(0)
750 Ad  oppisplt              98     98
750 Ad  oppstuff             108    108
     D  opdend               117    117
417cA*----------------------------------------------------------------
417cA*  *GENPICK -  General picking options.
417cA*----------------------------------------------------------------
417cA*
417cA* Fields
417cA*
417cA*    OPERPT  -  Print exception (short) error report (Y,N).
417cA*    OPELBL  -  Print exception (short) labels (Y,N)
417cA*    OPRFWC  -  Using RF will call (Y,N).
417cA*    OPNRSC  -  Number of pallet sections (1-9).
417cA*    OPHPWC  -  Host pick Will Call (Y/N).
417cA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
417cA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
417cA*
417cA* Data structure
417cA*
417cAD opdata          ds
417cAD  operpt                 1      1
417cAD  opelbl                 2      2
417cAD  oprfwc                 3      3
417cAD  opnrsc                 4      4  0
417cAD  ophpwc                 5      5
417cAD  opmrga                 6      6
417cAD  opplsq                 7      7
417cAD  optend               117    117
500cA*----------------------------------------------------------------
500cA*  OPTIONZ data structure
500cA*
500cAD opzdt1          ds
500cAD  opzend               117    117
     *----------------------------------------------------------------
     *  Data structures for saving/restoring label record
     *
412bAD wlds          e ds                  extname(worklbl)
412bAD wlsav           ds
412bAD  ds1000              1000   1000
417bA*----------------------------------------------------------------
417bA*  Truck compartment table
417bA*
417bAD tkcomp          ds                  occurs(100)
417bAD  t$comp                 1      1
417bAD  t$pick                 2      3  0

740bA*----------------------------------------------------------------
740bA*   Prototype call for PS162
740bA*   Combine labels
740bA*----------------------------------------------------------------

740bAD ps162           pr                  extpgm('PS162')
740bAD  iparm                        80

CWD A*
CWD A*----------------------------------------------------------------
CWD A*  Tote Orders Summary table
CWD A*
CWD AD toteorders      ds                  occurs(500)
CWD AD  toteordid              1      7  0 inz(0)
CWD AD  totepltid              8     14  0 inz(0)
CWD AD  totephylbl            15     21  0 inz(0)
CWD AD  totepcs               22     28  0 inz(0)
CWD AD  totecube              29     39  3 inz(0)
CWD AD  totewgt               40     48  2 inz(0)
CWD A*
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *----------------------------------------------------------------
     *
650bAD $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
740bA*
740bA*   Key used for PS162 call
740bA*
740bAD  $lwhse                19     21  0
740bAD  $lrte                 22     26
740bAD  $lpal#                27     33  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
730fA /copy qcopysrc,c#pgminfds
730fDD*               sds
730fDD* #prog            *proc
730fDD* #job                 244    253
730fDD* #user                254    263
730fDD* #jobn                264    269
730fDD* #jobdt               276    281  0
730fDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
730dA /copy qcopysrc,c#stdvar
740bA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Variables
     *
     D avlcub          s                   like(pscube)
500gAD avlpcs          s                   like(pspcs)
     D bldtyp          s              8
     D blkflg          s              1
500iDD**hkpcs          s              1
500iAD exceptionPass   s               n
500iAD normalPass      s               n
500iAD curIsTote       s               n
500iAD curAscend       s               n
500iAD curDescend      s               n
500iAD curByLocation   s               n
510lAD curBySlotDesc   s               n
510lAD updrecad        s               n
500iAD curByStop       s               n
500iAD curByStopAsc    s               n
500iAD curByStopDesc   s               n
500iADcurByStopLocAsc  s               n
500iADcurByStopLocDsc  s               n
500iADcurByStopOrdAsc  s               n
500iADcurByStopOrdDsc  s               n
500iAD curLimitOrders  s               n
500iAD curChkMaxPcs    s               n
500iADcurNewPlt4Aisle  s               n
500iADcurAllowMrgOnBk  s               n
520eAD curIsBatch      s               n
620aAD curIsPrePick    s               n
520eAD curByGroup2     s               n
500iAD curMaxPltCube   s                   like(opfcub)
720fAD curMaxPltWgt    s                   like(opfwgt)
500iAD curStopsPerPlt  s                   like(opfstp)
500iADcurOrdersPerPlt  s                   like(opford)
500iADcurTotesPerPlt   s                   like(opftot)
500iADcurStopsPerTote  s                   like(optstp)
500iADcurOrderPerTote  s                   like(optord)
500iADcurPcsPerTote    s                   like(optpcs)
500iADcurExtToteCube   s                   like(optecb)
500iADcurIntToteCube   s                   like(opticb)
HAR AD HldCurLimitOrd  s               n
750 Ad forceOnPallet   s               n
500iAD mrgIsTote       s               n
500iADmrgExtToteCube   s                   like(optecb)
500iADmrgIntToteCube   s                   like(opticb)
500iADmrgPcsPerTote    s                   like(optpcs)
500iAD lstByStopDesc   s               n
520eAD curItemsPerPlt  s                   like(oppitm)
520eAD curLimitItems   s               n
700fAD curDFPickOrdB   s               n
700fAD curDFPickOrdA   s               n
720aAD ddRtnCode       s             10
720aAD ddRtnMsg        s            100
720aDD ddRtnStr        s          65535    varying
     D dum6            s              6
     D eofzw           s              1
     D first           s              1
     D first1          s              1
     D forevr          s              1
730DDD**orever         s               n
     D gtzone          s              1
620bAD kyaisl          s                   like(lwaisl)
     D kybtyp          s                   like(lwtype)
     D kycode          s                   like(opzcod)
     D kycol           s                   like(pscol)
CBIaAD kycomp          s                   like(lwcomp)
     D kygen           s                   like(psgen)
     D kyptyp          s                   like(lwtype)
     D kypzon          s                   like(lwpzon)
     D kyrow           s                   like(psrow)
     D kystop          s                   like(lwstop)
     D kytype          s                   like(lwtype)
CBIaAD kytzon          s                   like(lwtzon)
     D kyunld          s                   like(psunld)
     D kyzone          s                   like(opzzon)
700aAD lastBoxId       s                   like(axaboxid)
     D lblflg          s              1
     D lftcub          s                   like(lwcube)
     D lftqty          s                   like(lwqalc)
     D lftwgt          s                   like(lwswgt)
650aAD loadseq         s                   like(pspal#)
     D lsbltp          s              8
     D lspbld          s              1
500gAD lastpal#        s                   like(lwpal#)
     D lstasl          s                   like(lwaisl)
620aAD lstloc          s                   like(lwloc)
620aAD lstrlvl         s                   like(lwrlvl)
500kAD lstcl2          s              2  0
720cAD lstcl6          s              2  0
720kAD lstcl7          s              2  0
     D lstcmp          s                   like(pscomp)
500gAD lstord          s                   like(lword)
500nAD lstdsg          s                   like(itdesg)
     D lstrow          s                   like(psrow)
     D lstrw2          s                   like(psrow)
720kAD lstrw7          s                   like(psrow)
     D lststp          s                   like(psstp1)
510pAD lststp2         s                   like(psstp1)
500gAD lstszn          s                   like(lwszon)
500pDD*lstul2          s                   like(psunld)
500pMD lstul2          s                   like(pspal#)
     D lstunl          s                   like(psunld)
     D lstwhd          s                   like(lwwhdp)
520eAD lstgrp2         s              3
520eAD kybgrp2         s              3
     D maxmlt          s              3  2
     D maxqty          s                   like(lwqalc)
720fAD maxqtyByWgt     s                   like(lwqalc)
     D minmlt          s              3  2
     D mrgstp          s                   like(lwstop)
     D newavl          s                   like(pscube)
     D newmax          s                   like(pscube)
     D newmin          s                   like(psmaxc)
520aAD nxt71           s                   like(psunld)
720aAD oldPlid         s                   like(psplid)
510cAD pass            s              1  0
     D postn2          s              1
720gAD preventSplit    s               n
730dAD preventSplitFP  s               n
720hAD preventSplitSP  s               n
     D pvpal#          s              7  0
500iDD**avchkpcs       s              1
500gAD savelwwhse      s                   like(lwwhse)
500gAD savelwpzon      s                   like(lwpzon)
500gAD savelwszon      s                   like(lwszon)
500gAD savelwitem      s                   like(lwitem)
500gAD savelwwhdp      s                   like(lwwhdp)
500gAD savelwaisl      s                   like(lwaisl)
500gAD savelwloc       s                   like(lwloc)
500gAD savelwpseq      s                   like(lwpseq)
500gAD savelwrlvl      s                   like(lwrlvl)
500gAD savelwhand      s                   like(lwhand)
500gAD savelwdisp      s                   like(lwdisp)
500jAD savelwutyp      s                   like(lwutyp)
500jAD savelwucod      s                   like(lwucod)
500gAD savelwucub      s                   like(lwucub)
500gAD savelwcube      s                   like(lwcube)
500gAD savelwswgt      s                   like(lwswgt)
500gAD savelwqalc      s                   like(lwqalc)
500gAD savelwtype      s                   like(lwtype)
500gAD savelwctr#      s                   like(lwctr#)
500gAD savelwlbl#      s                   like(lwlbl#)
500gAD savelwpal#      s                   like(lwpal#)
500gAD savelwsdte      s                   like(lwsdte)
500gAD savelwstim      s                   like(lwstim)
500jAD savelwstop      s                   like(lwstop)
500mAD savelword       s                   like(lword)
500mAD savelwseq       s                   like(lwseq)
650bMD dpflag          s              1
650bMD dpflag2         s              1
650bMD spflag          s              1
640aAD spflag2         s              1
650bAD $pordr          s              7  0
650bAD $phstp          s              5  0
650bAD $phstpa         s              5  0
650bAD $phstpb         s              5  0
     D stpcnt          s              3  0
     D svaisl          s                   like(lwaisl)
     D svcol           s                   like(pscol)
EBLaAD svcomp          s                   like(lwcomp)
     D svgen           s                   like(lwgen)
     D svhand          s                   like(lwhand)
     D svlbl#          s                   like(lwlbl#)
     D svord           s                   like(lword)
     D svpseq          s                   like(lwpseq)
EBLaAD svtzon          s                   like(lwtzon)
     D svpzon          s                   like(lwpzon)
     D svqalc          s                   like(lwqalc)
     D svrlvl          s                   like(lwrlvl)
     D svrow           s                   like(psrow)
     D svsdte          s                   like(lwsdte)
     D svstat          s                   like(lwstat)
     D svstim          s                   like(lwstim)
     D svstop          s                   like(lwstop)
     D svtype          s                   like(lwtype)
     D svunld          s                   like(psunld)
     D svwhdp          s                   like(lwwhdp)
520eAD svgrp2          s              3
     D szone           s                   like(zwszon)
CWD AD svtoteordid     s                   like(lword)
CWD AD                                     inz(-9999999)
CWD AD t               s              3  0 inz(0)
CWD AD toteordcnt      s              3  0 inz(0)
     D tmpcub          s                   like(lwucub)
     D tmpqty          s                   like(lwqalc)
     D tmpwgt          s                   like(lwuwgt)
     D today           s              8  0
MJKaAD mjkContract     s               n
500gAD mrgtotecube     s                   like(pscube)
500gAD mrgtoteitem     s                   like(lwitem)
500gAD mrgtotelbl#     s                   like(lwlbl#)
500gAD mrgtotepcs      s                   like(pspcs)
500gAD mrgtotestp1     s                   like(psstp1)
500gAD mrgtotestp2     s                   like(psstp2)
500gAD mrgtoteszon     s                   like(lwszon)
500gAD mrgtotewgt      s                   like(psswgt)
500mAD mrgtoteord      s                   like(lword)
500mAD mrgtoteseq      s                   like(lwseq)
500iDD*tote            s              1
     D ttlcub          s                   like(psscub)
     D ttlpcs          s                   like(psspcs)
     D ttlwgt          s                   like(pssswt)
     D t1              s              3  0
     D t2              s              3  0
730dDD*x               s              1  0
     D xxbcnt          s                   like(psbcnt)
     D xxcube          s                   like(pscube)
     D xxlbl#          s                   like(pslbl#)
     D xxpcs           s                   like(pspcs)
     D xxplid          s                   like(psplid)
     D xxstp1          s                   like(psstp1)
     D xxstp2          s                   like(psstp2)
     D xxswgt          s                   like(psswgt)
     D xxtype          s                   like(pstype)
720kAD xxgen           s                   like(psgen)
720kAD xxrow           s                   like(psrow)
720kAD xxcol           s                   like(pscol)
730dDD*y               s              2  0
     D z2comp          s                   like(zwcomp)
     D z2gen           s                   like(zwgen)
     D z2pzon          s                   like(zwpzon)
     D z2rtid          s                   like(zwrtid)
     D z2szon          s                   like(zwszon)
     D z2truk          s                   like(zwtruk)
     D z2tzon          s                   like(zwtzon)
     D z2whse          s                   like(zwwhse)
530 AD $ptmpl          s             10
EBLaAD zchemComp       s                   like(zhcomp)
EBLaAD zchemZone       s                   like(zhzone)
500oAD zonePltCnt      s                   like(pspal#)
500oAD maxUnld         s                   like(psunld)
500oAD newPal#         s                   like(pspal#)
500oAD newUnld         s                   like(psunld)
510eAD CurPartialTote  s                   like(pspal#)
510eAD CurPartialPcs   s                   like(pspcs)
510eAD FirstPass       s              1    inz('Y')
510eAD ToteFlag        s               n
510eAD xscomp          s              1
510eAD xstzon          s              6
510eAD xsgen           s              1  0
510eAD xsszon          s              6
510eAD xstype          s              1
510eAD xsunld          s              2  0
510eAD xsrow           s              2  0
510eAD xscol           s              1  0
510gAD lststop         s                   like(lwstop)
620aAD xwwhdp          s                   like(lwwhdp)
620aAD xwaisl          s                   like(lwaisl)
720fDD*psmaxw          s              9  2
CPCaAD avlwgt          s              7  0
NCSbAD psmaxp          s                   like(pspcs)
NCSbAD avlpcs2         s                   like(pspcs)
NCScDD*psmaxc1         s                   like(psmaxc)
NCScMD psmaxc1         s                   like(pscube)
750bAd wkPltItmCnt     s              3  0
750bAd wkPltItmStr     s           3000
750bAd wkPltNxtPos     s              4  0
650bAD work2           s              2  0
650bAD work2a          s              2  0
650bAD work2b          s              2  0
650bAD $pDsda          s              9
650bAD $pDsdb          s              9
720aAD dd2Location     s               n
720aAD locationMax     s                   like(psplid)
720jAd tbEnhanced      s               n
720jAd tbPalletType    s              1
720jAd tbType          s              1
730fAD pNextLbl#       s             11  0
730fAd nextLbl#        s                   like(lwlbl#)

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,p.dd410
     d/copy qcopysrc,p.dd430
720jAd/copy qcopysrc,p.gettbtyp
730dAd/copy qcopysrc,p.umworklb
730fA /copy qcopysrc,p.pirlbl#w
740aA /copy qcopysrc,p.excustma

740bA*----------------------------------------------------------------
740bA*  Query used to determine dup item lines on pallet position
740bA*----------------------------------------------------------------
740bAd wkrec           ds            71
740bAd  duwhse                        3  0
740bAd  durte                         5
740bAd  dupal#                        7  0
740bAd  duitem                       15
740bAd  duseq                         5  0
740bAd  duord                         7  0
740bAd  dudisp                       12
740bAd  ductr#                        7  0
740bAd  duasl2                        3
740bAd  duutyp                        1
740bAd  dutype                        1
740bAd  ducnt                         5  0

750bA*----------------------------------------------------------------
750bA*   Sub-Procedures
750bA*---------------------------------------------------------------
750bAd maxPltItems     pr              n
750bAd  iItem                              like(lwitem)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PTRUK  Truck
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
     *----------------------------------------------------------------
     *  Main line
     *
     *  Create initial pallet records.
     *
     C                   exsr      init
ADCaA*
ADCaA*  For Anderson-DuBose prevent splitting label
ADCaA*
ADCaAC                   if        client = adc
ADCaAC                   eval      preventSplit = *on
750 Ac                   eval      forceonpallet = *on
ADCaAC                   endif
KHLbA*
KHLbA*  For Kohl prevent splitting label for *SP orders
KHLbA*
KHLbAC                   if        client = kohl
KHLbAC                   eval      preventSplitSP = *on
750 Ac                   eval      forceonpallet = *on
KHLbAC                   endif

EBLaA*
EBLaA*  For Ellenbee get ZCHEM information.
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC                   eval      kyzone = 'ZCHEM'
EBLaAC     keyzh         chain     zoneh
EBLaAC                   if        not %found
EBLaAC                   eval      zchemZone = '?'
EBLaAC                   eval      zchemComp = '?'
EBLaAC                   else
EBLaAC                   eval      zchemZone = zhzone
EBLaAC                   eval      zchemComp = zhcomp
EBLaAC                   endif
EBLaAC                   endif
MJKaA*
MJKaA*  For MJ Kellner check for Contract route.
MJKaA*
620aD ***                if        client = mjkellner
MJKaAC     keyrh         chain     rtehed
620aMC                   if        client = mjkellner
MJKaAC                   if        %found
MJKaAC                             and %subst(rhrte:1:2)='CC'
MJKaAC                   eval      mjkContract = *on
MJKaAC                   else
MJKaAC                   eval      mjkContract = *off
MJKaAC                   endif
MJKaAC                   endif
     *
     *  Loop through zone work file.
     *
520aAC                   eval      nxt71 = 71
500oAC                   eval      maxUnld = *hival
     C                   eval      eofzw = *off
     C                   eval      lstcmp = '@'
     C                   eval      lstrw2 = 0
500kAC                   eval      lstcl2 = 0
720cAC                   eval      lstcl6 = 0
720kAC                   eval      lstrw7 = 0
720kAC                   eval      lstcl7 = 0
     C     keyzw2        setll     workzon2
     C                   dow       forevr = forevr
     C     keyzw2        reade     workzon2                               79
     *
     *    After we run out of defined zones . . .
     *      Look for items outside of defined zones and then get out.
     *
     C                   if        *in79
     C                   if        eofzw = *on
     C                   leave
     C                   else
     C                   eval      eofzw = *on
     C                   eval      zwtzon = 'ZZZZZZ'
     C                   eval      zwpzon = 'ZZZZZZ'
     C                   eval      zwszon = 'ZZZZZZ'
     C                   eval      zwcomp = 'Z'
     C                   eval      zwgen = 1
     C                   endif
     C                   endif
     *
500oAC                   eval      zonePltCnt = 0
EGFaA
EGFaA*    Set curBySlotDesc for EG Forrest
EGFaA
EGFaAC                   if        client = egf
EGFaAC                   if        zwszon = 'DRY'
EGFaAC                   eval      curBySlotDesc = *on
EGFaAC                   else
EGFaAC                   eval      curBySlotDesc = *off
EGFaAC                   endif
EGFaAC                   endif
     *
417bA*    Get options for the zone.
417bAC                   eval      kyzone = zwszon
417bAC                   exsr      getopt
     *
     *    Loop if no normal, merge or bulk label records exist for zone.
     *
     C                   eval      kytype = 'O'
417bAC                   select
500iDC**                 when      oppbld = '3'
500iMC                   when      curByStopDesc
417bAC     keylb2        setll     worklbla                               78
417bAC                   other
     C     keylb2        setll     worklbl2                               78
417bAC                   endsl
     C                   if        not *in78
     C                   eval      kypzon = zwszon
417bAC                   select
500iDC**                 when      oppbld = '3'
500iMC                   when      curByStopDesc
417bAC     keymg2        setll     worklblc                               78
417bAC                   other
     C     keymg2        setll     worklbl4                               78
417bAC                   endsl
     C                   endif
     C                   if        not *in78
     C                   eval      kybtyp = 'B'
417bAC                   select
500iDC**                 when      oppbld = '3'
500iMC                   when      curByStopDesc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keybk2        setll     worklblad                              78
510lAC                   other
417bAC     keybk2        setll     worklbla                               78
510lAC                   endsl
417bAC                   other
     C     keybk2        setll     worklbl2                               78
417bAC                   endsl
     C                   endif
     C                   if        not *in78
CBIbAC                   if        client <> cheney
CBIbAC                             or client = cheney
CBIbAC                             and zwtzon <> 'PKDRY'
     C                   iter
CBIbAC                   endif
     C                   endif
     *
500kAC**520dD            if        lwgen = 2
520dMC                   if        lwgen > 1
500kAC                   eval      lstul2 = 0
500kAC                   endif
     *
     *    Did compartment change?
     *
404 D*          LWCOMP    IFNE LSTCMP
404 MC                   if        zwcomp <> lstcmp
     **                   Z-ADD0         LSTRW2
     C                   eval      lstul2 = 0
404 D*                    MOVE LWCOMP    LSTCMP
404 MC                   eval      lstcmp = zwcomp
417bA*
417bA*    Retrieve maximum pallet positions for compartment.
417bAC     1             do        t1            t2
417bAC     t2            occur     tkcomp
417bAC                   select
417bAC                   when      zwcomp = t$comp
417bAC                   leave
417bA*
417bAC                   endsl
417bAC                   enddo
417bA*
     C                   endif
     *
     *    Get picking options for zone.
     *
404 D*                    MOVE LWSZON    KYZONE
417bD*                    MOVE ZWSZON    KYZONE
417bD*                    EXSR GETOPT
     *
     *    Get first pallet for zone.
     *
417bA*    Build pallet(s) for zone.
417bA*
500iDC**                 if        oppbld = '2'
500iMC                   if        curByLocation
500iDC**                 eval      bldtyp = '*LOC    '
417dAC                   move      *all'@'       lstwhd
417dAC                   move      *all'@'       lstasl
417dAC                   eval      first1 = *off
417bAC                   else
500iDC**                 eval      bldtyp = '*STOP   '
417bAC                   endif
     C                   eval      postn2 = *on
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP '
500iMC                   when      curByStopDesc
417bAC                   eval      kyunld = t$pick
417bAC                   eval      kyrow = 0
417bAC                   eval      kycol = 0
417bAC                   eval      lstunl = 0
417bA*
417bAC                   other
417bA*
     C                   eval      kyunld = 0
412aAC                   eval      kyrow = 0
412aAC                   eval      kycol = 0
415 AC                   eval      lstunl = 0
417bAC                   endsl
     C                   exsr      getplt
     *
410 A*    Build exception pallet(s) for zone.
410 A*      (Only for non-truck zones)
510mA*      (Only for non-tote zones)
     *
410 AC                   if        zwgen > 1
510mMC                             and not curIsTote
500iDC**                 eval      bldtyp = '*EXCP   '
500iMC                   eval      normalPass = *off
500iMC                   eval      exceptionPass = *on
410 AC                   exsr      bldplt
500iAC                   eval      exceptionPass = *off
410 AC                   if        pspcs > 0
500iDC**                 if        oppbld = '2'
500iDC**                 eval      bldtyp = '*LOC    '
500iDC**                 else
500iDC**                 eval      bldtyp = '*STOP   '
500iDC**                 endif
410 AC                   exsr      getplt
410 AC                   endif
410 AC                   endif
     *
     *
     *    Build pallet(s) for zone.
     *
500iDC**                 if        oppbld = '2'
500iMC                   if        curByLocation
500iDC**                 eval      bldtyp = '*LOC    '
417dAC                   eval      first1 = *off
500iDC**                 else
500iDC**                 eval      bldtyp = '*STOP   '
     C                   endif

500iMC                   eval      normalPass = *on
500iMC                   eval      exceptionPass = *off

500iMC                   if        curIsTote
510iAC                   eval      first1 = *off
510cDC**                 exsr      bldtote
700aAC*
700aAC*        See if tote zone is for AMP boxes.
700aAC*        If it is, then skip other tote processing.
700aAC                   exsr      bldtotebox
700aAC                   if        lastBoxId = 0
700aAC*
510cAC                   if        curChkMaxPcs
510cAC                   exsr      bldtotepcs
510cAC                   else
510cAC                   exsr      bldtotecube
510cAC                   endif
700aAC*
700aAC                   endif
500gAC                   else
620aAC                   if        curIsPrePick
620aAC                   exsr      bldPrePick
620aAC                   else
     C                   exsr      bldplt
620aAC                   endif
500gAC                   endif
     *
     C                   enddo
720aA*
720aA*  Extra DD2 logic
720aA*
720aA /free
720aA
720aA    // Extra TruckBuilder Enhanced logic
720aA
720jM    if tbEnhanced;
720aA
720aA      // Create PLTSUM 'P' records
720aA
720aA      exsr dd2plts;
720aA
720aA      // Call program to create DDDETAIL records
720aA
720aA      dd410('*ROUTE': $pwhse: $prtid: '': 0: 0:
720aA            #user: #jobn: '': 'OR620': ddRtnCode: ddRtnMsg);
720aA
720aA      // Call program to create DDDETAIL records
720aA
720aA      dd430('*CRTALL': '': $pwhse: $prtid:
720aA            #user: #jobn: '': 'OR620': ddRtnCode: ddRtnMsg: ddRtnStr);
720aA
720aA    endif;
720aA
720aA /end-free
     *
     *  Create pallet stop summary records.
     *
     C                   exsr      stpsum
740bA*
740bA*  Ensure no order/item/seq/slot dups within specific pallet locations
740bA*
750eAc                   if        $potyp <> 'W'
740bAC                   exsr      duplines
750eAc                   endif
     *
     * Close up shop and return home.
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
417bAC                   eval      gtzone = *off
417dAC                   eval      first1 = *off
700fAC                   Eval      curDFPickordB = *OFF
700fAC                   Eval      curDFPickordA = *OFF
750aA
750aA /free
750aA         // this will ensure DD2 clears extra flags record
750aA         // when user clicks Rebuild within DD2
750aA         exec sql delete ddwrkflds where ddwwhse=:$pWhse and
750aA                                        ddwrtid=:$pRtid;
750aA /end-free
750aA
500eA*
500eA* Get client id.
500eA*
500eAC                   call      @getcl
500eAC                   parm                    client           10
700dAC                   parm                    clientloc        10
720jMc*
720jMc*   Determine if using TruckBUilder Enhanced
720jMc*
720jA /free
720jA      GetTBType($pwhse: $prtid: tbType);
720jA      if tbType = 'E';
720jA        tbEnhanced = *on;
720jA        tbPalletType = 'P';
720jA      else;
720ja        tbEnhanced = *off;
720jA        tbPalletType = 'O';
720ja      endif;
720jA /end-free
730aA**
730aA**  Get Slot Sequence with new Option and possible soft coding
730aA**
730aAc                   eval      gpscmd = '*ISSOFT'
730aAc                   monitor
730aAc                   call      'GETPSEQO'
730aAc                   parm                    gpscmd            8
730aAc                   parm                    $pwhse
730aAc                   parm      ' '           gpswhdp           5
730aAc                   parm      ' '           gpsdisp          12
730aAc                   parm      ' '           gpsSeqcd          1
730aAc                   parm      0             gpsSeq            5 0
730aAc                   parm      ' '           usrDFPICK         1
730aAc                   on-error
730aAc                   eval      usrDFPICK = 'N'
730aAc                   endmon
700fA*
700fA* Check if client is to run in DFPICK order and set flag
700fA*
700fAC                   IF        Client = Panos
730aAc                             or usrDFPICK = 'Y'
700fAC                   Eval      curDFPickordB = *On
700fAC                   EndIf
     *
     *  Define partial key for TRUCKD file.
     *
     C     keytd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
EBLaA*
EBLaA*  Define  key for ZONEH file.
EBLaA*
EBLaAC     keyzh         klist
EBLaAC                   kfld                    $pwhse
EBLaAC                   kfld                    $ptruk
EBLaAC                   kfld                    kyzone
     *
     *  Define  key for ZONEH1 file.
     *
     C     keyzh1        klist
     C                   kfld                    $pwhse
530 D **                 kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    tdcomp
     *
     *  Define partial key for WORKZON2 file.
     *
     C     keyzw2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
404 A*
404 A*  Define key for WORKZON1 file.
404 A*
404 AC     keyzw1        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    lwszon
417cA*
417cA*  Define key for OPTIONS file
417cA*
417cAC     opskey        klist
417cAC                   kfld                    opwhse
417cAC                   kfld                    opcode
     *
     *  Define full key for PLTSUM1 file.
     *
     C                   eval      kyptyp = 'O'
     C     keyps         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kyptyp
     C                   kfld                    kyunld
412aAC                   kfld                    kyrow
412aAC                   kfld                    kycol
     *
     *  Define partial key for PLTSUM1 file.
     *
     C     keyps1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kyptyp
     *
     *  Define partial key for PLTSUM2 file.
     *
     C     keyps2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
510eA*
510eA*  Define full key for PLTSUM1 file.
510eA*
510eAC     keypsx        klist
510eAC                   kfld                    $pwhse
510eAC                   kfld                    $prtid
510eAC                   kfld                    xscomp
510eAC                   kfld                    xstzon
510eAC                   kfld                    xsgen
510eAC                   kfld                    xsszon
510eAC                   kfld                    xstype
510eAC                   kfld                    xsunld
510eAC                   kfld                    xsrow
510eAC                   kfld                    xscol
     *
     *  Define partial key for WORKLBL2 file.
     *
     C     keylb         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lwcomp
     C                   kfld                    lwtzon
     C                   kfld                    lwpzon
     C                   kfld                    lwszon
     C                   kfld                    lwgen
     C                   kfld                    lwtype
     C                   kfld                    lwstop
     C                   kfld                    lwwhdp
     C                   kfld                    lwaisl
     C                   kfld                    lwpseq
     C                   kfld                    lwrlvl
     C                   kfld                    lwhand
     C                   kfld                    lwlbl#
     *
     *  Define partial key for WORKLBL2 file.
     *
     C     keylb2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kytype
620aA*
620aA*  Define partial key for WORKLBLF file.
620aA*
620aAC     keylbf        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
620bAC                   kfld                    kyaisl
620bDC**                 kfld                    zwcomp
620bDC**                 kfld                    zwtzon
620bDC**                 kfld                    zwgen
620bDC**                 kfld                    zwszon
620bDC**                 kfld                    kytype
     C***                kfld                    lwwhdp
     C***                kfld                    lwaisl
620aA*
620bDC**   keylbf2       klist
620bDC**                 kfld                    $pwhse
620bDC**                 kfld                    $prtid
620bDC**                 kfld                    zwcomp
620bDC**                 kfld                    zwtzon
620bDC**                 kfld                    zwgen
620bDC**                 kfld                    zwszon
620bDC**                 kfld                    kytype
620bDC**                 kfld                    xwwhdp
620bDC**                 kfld                    xwaisl
     *
     *  Define partial key for WORKLBL4 file for merging.
     *
     C     keymg1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    kypzon
     C                   kfld                    kystop
     *
CBIaAC     flrmg1        klist
CBIaAC                   kfld                    $pwhse
CBIaAC                   kfld                    $prtid
CBIaAC                   kfld                    kycomp
CBIaAC                   kfld                    kytzon
CBIaAC                   kfld                    kypzon
CBIaAC                   kfld                    kystop
     *
     *  Define partial key for WORKLBL4 file for merging.
     *
     C     keymg2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    kypzon
     *
CBIaAC     flrmg2        klist
CBIaAC                   kfld                    $pwhse
CBIaAC                   kfld                    $prtid
CBIaAC                   kfld                    kycomp
CBIaAC                   kfld                    kytzon
CBIaAC                   kfld                    kypzon
     *
     *  Define partial key for WORKLBL2 file for bulk picks.
     *
     C     keybk1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kybtyp
     C                   kfld                    kystop
520eA*
520eA*  Define partial key for WORKLBLE file for bulk picks.
520eA*
520eAC     keybk1e       klist
520eAC                   kfld                    $pwhse
520eAC                   kfld                    $prtid
520eAC                   kfld                    zwcomp
520eAC                   kfld                    zwtzon
520eAC                   kfld                    zwgen
520eAC                   kfld                    zwszon
520eAC                   kfld                    kybtyp
520eAC                   kfld                    kybgrp2
520eAC                   kfld                    kystop
     *
     *  Define partial key for WORKLBL2 file for bulk picks.
     *
     C     keybk2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zwcomp
     C                   kfld                    zwtzon
     C                   kfld                    zwgen
     C                   kfld                    zwszon
     C                   kfld                    kybtyp
     *
     *  Define partial key for PLTSUM2 file for stop summary.
     *
     C     keyss         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    kygen
     *
     *  Define partial key for WORKLBL6 file.
     *
     C     keylw6        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
CWD A*
CWD A*  Define partial key for WORKLBL5 file.
CWD A*
CWD AC     keylw5        klist
CWD AC                   kfld                    $pwhse
CWD AC                   kfld                    $prtid
CWD AC                   kfld                    lwlwpal#
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
     *
412 A*  Define key for ORDH file.
     *
     C     keyoh         klist
     C                   kfld                    lwwhse
     C                   kfld                    lword
412aA*
412aA*  Define key for PLTSTP1 file.
412aA*
412aAC     keypss        klist
412aAC                   kfld                    pswhse
412aAC                   kfld                    psrtid
412aAC                   kfld                    psplid
412aAC                   kfld                    psrow
412aAC                   kfld                    pscol
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     trkey         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
500eA*
500eA*  Define key for PIRITEM file.
500eA*
500eAC     keyit         klist
500eAC                   kfld                    lwwhse
500eAC                   kfld                    lwitem
MJKaA*
MJKaA*  Define key for RTEHED file.
MJKaA*
MJKaAC     keyrh         klist
MJKaAC                   kfld                    $pwhse
MJKaAC                   kfld                    $prtid
     *
640cA*  Define key for TRUCKHM file.
     *
640cAC     trmky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptmpl
     *
     *  Define variables.
     *
417bAC                   eval      t1 = *zeros
417bAC                   eval      t2 = *zeros
417bA*
415aD**         *LIKE     DEFN PSMAXC    NEWMAX
720cA
720cA*  For TruckBUilder Enhanced, no longer doing +/- 10%
720cA
720jMC                   if        tbEnhanced
720cAC                   eval      maxmlt = 1
720cAC                   eval      minmlt = 0
720cAC                   else
412aAC                   eval      maxmlt = 1.10
412aAC                   eval      minmlt = .10
720cAC                   endif
417bA*
417bA*  Initializie Pick data structure.
417bA*
417bAC     1             do        100           t1
417bAC     t1            occur     tkcomp
417bAC                   eval      t$pick = *zeros
417bAC                   enddo
417bAC                   eval      t1 = *zeros
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     trkey         chain     truckh
530 AC                   if        %found(truckh) and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
640cA*
640cA* Get Zone Template heavy to light code.
640cA*
640cAC     trmky         chain     truckhm1
640cAC                   select
640cAC                   when      %found(truckhm1) and tmsort = 'Y'
640cAC                   eval      curBySlotDesc = *on
640cAC                   when      %found(truckhm1) and tmsort = 'N'
640cAC                   eval      curBySlotDesc = *off
640cAC                   when      %found(truckhm1) and tmsort = *blanks
640cAC                   eval      curBySlotDesc = *off
640cAC                   when      not %found(truckhm1)
640cAC                   eval      curBySlotDesc = *off
640cAC                   endsl
     *
YHAaA*
720fDC**                 select
720fDC**                 when      client = cpc
CPCbD ***                eval      psmaxw =  2744
720fDC**                 eval      psmaxw =  2576
720fDC**                 when      client = yhata
720fDC**                 eval      psmaxw =  2744
720fDC**                 other
720fDC**                 eval      psmaxw =  9999
720fDC**                 endsl
YHAaA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  BLDPLT  Build pallet(s) for zone.
     *
410 A*   Added *EXCP BLDTYP.  This is used for non-truck zones to
410 A*     put all of the exception items that do not have a slot
410 A*     onto their own pallet.  For truck pallets, the items
410 A*     are put onto their corresponding stop pallet whether or
410 A*     not it has a slot.
410 A*
     *
     C     bldplt        begsr
417bA*
417bA*    When building pallets in reverse order, set last stop
417bA*    to 99, this will position file pointer at top of file.
417bAC                   select
500iDC**                 when      oppbld = '3'  and
599iDC**                           bldtyp = '*STOP'
500iMC                   when      normalPass and curByStopDesc
417bAC                   eval      lststp = 99
417bAC                   other
     C                   eval      lststp = -(1)
417bAC                   endsl

520eAC                   eval      lstgrp2 = *blanks
520eAC                   if        CurIsBatch
520eAC                   eval      lstgrp2 = '1'
520eAC                   endif

417bA*
417eD*R                   MOVE *OFF      SPFLAG  1
415 D**                   Z-ADD0         LSTUNL
     *
     *   If building by location, do merge and bulk picks first.
     *
500iDC**                 if        bldtyp = '*LOC'
500iMC                   if        curByLocation
     C                   exsr      merge
     C                   exsr      bulk
     C                   endif
     *
     *   Loop through labels for current zone.
     *
     C                   eval      kytype = 'O'
500iDC**                 if        bldtyp = '*LOC'  or
500iDC**                           bldtyp = '*EXCP'
500iDC**                 eval      spflag = *off
500iDC**   keylb2        setll     worklbl3
500iDC**                 else
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   keylb2        setll     worklbla
500iDC**                 other
500iDC**   keylb2        setll     worklbl2
500iDC**                 endsl
500iDC**                 endif

500iMC                   select
500iA
500iMC                   when      exceptionPass
650bMC                   eval      spflag = *off
650bMC                   eval      dpflag = *off
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd1
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd8
700fAC                   Other
500iAC     keylb2        setll     worklbl3
700fAC                   EndSl
500iA
500iMC                   when      curByLocation
650bMC                   eval      spflag = *off
650bMC                   eval      dpflag = *off
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd1
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd8
700fAC                   Other
500iAC     keylb2        setll     worklbl3
700fAC                   EndSl
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd2
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd9
700fAC                   Other
500iAC     keylb2        setll     worklbl2
700fAC                   EndSl
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd3
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd10
700fAC                   Other
510lAC     keylb2        setll     worklblad
700fAC                   EndSl

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd4
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd11
700fAC                   Other
500iAC     keylb2        setll     worklbla
700fAC                   EndSl
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd5
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd12
700fAC                   Other
500iAC     keylb2        setll     worklbo2
700fAC                   EndSl
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd6
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd13
700fAC                   Other
500iAC     keylb2        setll     worklboa
700fAC                   EndSl
520eA
520eAC                   when      curByGroup2
650bMC                   eval      spflag = *off
650bMC                   eval      dpflag = *off
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        setll     worklbd7
700fAC                   When      curDFPickordA
700fAC     keylb2        setll     worklbd14
700fAC                   Other
520eAC     keylb2        setll     worklble
700fAC                   EndSl
500iA
500iMC                   endsl
     *
     C                   dow       forevr = forevr
     *
500iDC**                 if        bldtyp = '*LOC'  or
500iDC**                           bldtyp = '*EXCP'
500iDC**   keylb2        reade     worklbl3                               78
500iDC**                 else
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   keylb2        reade     worklbla                               78
500iDC**                 other
500iDC**   keylb2        reade     worklbl2                               78
500iDC**                 endsl
500iDC**                 endif

510lAC                   eval      updrecad = *off
500iAC                   select
500iA
500iAC                   when      exceptionPass
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd1                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd8                               78
700fAC                   Other
500iAC     keylb2        reade     worklbl3                               78
700fAC                   EndSl
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd1                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd8                               78
700fAC                   Other
500iAC     keylb2        reade     worklbl3                               78
700fAC                   EndSl
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd2                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd9                               78
700fAC                   Other
500iAC     keylb2        reade     worklbl2                               78
700fAC                   EndSl
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select

510lAC                   when      curBySlotDesc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd3                               78
700fAC                   eval      updrecad = *on
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd10                              78
700fAC                   eval      updrecad = *on
700fAC                   Other
510lAC     keylb2        reade     worklblad                              78
510lAC                   eval      updrecad = *on
700fAC                   EndSl

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd4                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd11                              78
700fAC                   Other
500iAC     keylb2        reade     worklbla                               78
700fAC                   EndSl
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd5                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd12                              78
700fAC                   Other
500iAC     keylb2        reade     worklbo2                               78
700fAC                   EndSl
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd6                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd13                              78
700fAC                   Other
500iAC     keylb2        reade     worklboa                               78
700fAC                   EndSl
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keylb2        reade     worklbd7                               78
700fAC                   When      curDFPickordA
700fAC     keylb2        reade     worklbd14                              78
700fAC                   Other
520eAC     keylb2        reade     worklble                               78
700fAC                   EndSl
500iA
500iMC                   endsl
     *
     C                   if        *in78
     C                   leave
     C                   endif
410 A*      Skip exceptions w/o slot when not doing an *EXCP
410 A*        and zone is a merge zone (GEN > 1).
410 A*
500iDC**                 if        bldtyp <> '*EXCP'  and
500iMC                   if        normalPass and
410 AC                             lwgen > 1  and
410 AC                             lwasl2 = 'OUT'  and
410 AC                             lwdisp = *blanks
410 AC                   iter
410 AC                   endif
410 A*      Skip non-exceptions when doing an *EXCP run.
410 A*
500iDC**                 if        bldtyp = '*EXCP'  and
500iMC                   if        exceptionPass and
410 AC                             lwasl2 <> 'OUT'
410 AC                   iter
410 AC                   endif
410 A*      Skip exceptions with slot when doing an *EXCP run.
410 A*
500iDC**                 if        bldtyp = '*EXCP'  and
500iMC                   if        exceptionPass and
410 AC                             lwasl2 = 'OUT'  and
510mMC                             lwdisp <> *blanks  and
510mAC                             not curIsTote
410 AC                   iter
410 AC                   endif
EBLaA*
EBLaA*      For Ellenbee be item information.
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC     keyit         chain     piritem
EBLaAC                   if        not %found
EBLaAC                   eval      itdesg = *blanks
EBLaAC                   endif
EBLaAC                   endif
NCSbAC                   if        client = nicholas
NCSbAC                             and CurIsBatch
NCSbAC     keyit         chain     piritem
NCSbAC     keyit         chain     itemmsc
NCSbAC                   if        not %found(itemmsc)
NCSbAC                   eval      imtie = *zeros
NCSbAC                   eval      imhigh = *zeros
NCSbAC                   eval      psmaxc1 = curMaxPltCube
NCSbAC                   else
NCSbAC                   eval      psmaxc1 = imtie * imhigh * itcube
NCSbAC                   if        psmaxc1 = 0
NCSbAC                   eval      psmaxc1 = curMaxPltCube
NCSbAC                   endif
NCSbAC                   endif
NCSbAC                   endif
730dA
730dA*      Get corresponding UM record
730dA
730dA /free
730dA  umFlexPickFlag = '';
730dA  preventSplitFP = *off;
730dA  umWhse = lwwhse;
730dA  monitor;
730dA    umworklbl('*GET': umRtnCode: umRtnMsg:
730dA              umWhse: lwlbl#:
730dA              umFlexPickFlag);
730dA  on-error;
730dA  endmon;
730dA  if umFlexPickFlag <> '';
730dA    preventSplitFP = *on;
730dA  endif;
730dA /end-free
     *
     *      Save record information.
     *
     C                   eval      svtype = lwtype
412 AC                   eval      svgen = lwgen
     C                   eval      svstop = lwstop
EBLaAC                   eval      svcomp = lwcomp
EBLaAC                   eval      svtzon = lwtzon
     C                   eval      svpzon = lwpzon
     C                   eval      svwhdp = lwwhdp
     C                   eval      svaisl = lwaisl
     C                   eval      svpseq = lwpseq
     C                   eval      svrlvl = lwrlvl
     C                   eval      svhand = lwhand
     C                   eval      svlbl# = lwlbl#
     C                   eval      svqalc = lwqalc
     C                   eval      svstat = lwstat
     C                   eval      svsdte = lwsdte
     C                   eval      svstim = lwstim
412aAC                   eval      svord = lword
520eAC                   eval      svgrp2 = lwbcod
     *
     *      When stop changes, get merge items and bulk picks for stop.
     *
500iDC**                 if        bldtyp = '*STOP'  and
500iMC                   if        normalPass and curByStop and
     C                             lwstop <> lststp
     C                   exsr      merge
     C                   exsr      bulk
411 A*
411 A*         Start new pallet if we exceed max stops per pallet.
411 A*         Note: Merge routine may have already counted new stop.
411 A*
411 AC                   if        mrgstp <> svstop
412aAC                   eval      lword = svord
520eAC                   eval      lwbcod = svgrp2

650bAC                   eval      work2a = mrgstp
650bAC                   eval      work2b = svstop

412 AC                   exsr      chksp
500iDC**                 if        stpcnt >= opfstp
500iMC                   if        stpcnt >= curStopsPerPlt
411 AC                   exsr      getplt
411 AC                   endif
411 AC                   add       1             stpcnt
411 AC                   endif
411 A*
     C                   eval      kybtyp = 'O'
     C                   eval      kystop = svstop
520eAC                   eval      kybgrp2 = svgrp2
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   keybk1        setll     worklbla
500iDC**                 other
500iDC**   keybk1        setll     worklbl2
500iDC**                 endsl

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setll     worklbd2
700fAC                   When      curDFPickordA
700fAC     keybk1        setll     worklbd9
700fAC                   Other
500iAC     keybk1        setll     worklbl2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setll     worklbd3
700fAC                   When      curDFPickordA
700fAC     keybk1        setll     worklbd10
700fAC                   Other
510lAC     keybk1        setll     worklblad
700fAC                   EndSL

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setll     worklbd4
700fAC                   When      curDFPickordA
700fAC     keybk1        setll     worklbd11
700fAC                   Other
500iAC     keybk1        setll     worklbla
700fAC                   EndSL
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setll     worklbd5
700fAC                   When      curDFPickordA
700fAC     keybk1        setll     worklbd12
700fAC                   Other
500iAC     keybk1        setll     worklbo2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setll     worklbd6
700fAC                   When      curDFPickordA
700fAC     keybk1        setll     worklbd13
700fAC                   Other
500iAC     keybk1        setll     worklboa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1e       setll     worklbd7
700fAC                   When      curDFPickordA
700fAC     keybk1e       setll     worklbd14
700fAC                   Other
520eAC     keybk1e       setll     worklble
700fAC                   EndSL
500iA
500iMC                   endsl
412 D*R                   Z-ADDLWSTOP    LSTSTP
412 MC                   eval      lststp = svstop
     C                   iter
     C                   endif
417dA*
417dA*    Set Dept/Aisle hold fields first time.
417dA*
417dAC                   if        first1 = *off
417dAC                   eval      first1 = *on
417dAC                   eval      lstwhd = lwwhdp
417dAC                   eval      lstasl = lwaisl
500iAC                   eval      lstord = lword
510gAC                   eval      lststop = lwstop
520eAC                   eval      lstgrp2 = lwbcod
750bAc                   eval      wkPltItmCnt = *zeros
750bAc                   eval      wkPltNxtPos = 1
750bAc                   eval      wkPltItmStr = *blanks
417dAC                   endif
417dA*
417dA*       When building by location and user wants a new pallet every
417dA*       time aisle changes, get new pallet when dept, aisle change
417dA*       and product put on current pallet.
417dA*
500iDC**                 if        bldtyp = '*LOC'  and
500iDC**                           opnwpl = 'Y'  and
500iMC                   if        curByLocation and
500iMC                             curNewPlt4Aisle and
500jDC**                           pscube <> *zeros
500jMC                             pspcs <> *zeros
417dAC                   if        lwwhdp <> lstwhd  or
417dAC                             lwaisl <> lstasl
417dAC                   exsr      getplt
417dAC                   eval      lstwhd = lwwhdp
417dAC                   eval      lstasl = lwaisl
417dAC                   endif
417dAC                   endif
750bA*
750bA*       Get new pallet when number of Items exceeds option setting
750bA*
750bA /free
750bA                    if curItemsPerPlt > 1;
750bA                      if maxPltItems(lwitem);
750bA                        exsr getplt;
750bA                      endif;
750bA                    endif;
750bA /end-free
500iA*
500iA*       Get new pallet when order changes.
500iA*
500iAC                   if        curLimitOrders and
500iAC                             lword <> lstord
500jDC**                 if        pscube <> *zeros
500jMC                   if        pspcs <> *zeros
500iAC                   exsr      getplt
500iAC                   endif
500iAC                   eval      lstord = lword
500iAC                   endif
520eA*
520eA*       Get new pallet when group code changes.
520eA*
520eAC                   if        curLimitItems
520eAC                             and CurIsBatch
520eAC                             and lwbcod <> lstgrp2
520eAC                   if        pspcs <> *zeros
520eAC                   exsr      getplt
520eAC                   endif
520eAC                   eval      lstgrp2 = lwbcod
520eAC                   endif
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
     C                   dow       forevr = forevr
CPCaA*
CPCaA*       Calculate weight available on pallet.
CPCaA*
720fDC**                 if        client = cpc
720fDC**                           or client = yhata
720fMC                   if        curMaxPltWgt > 0
CPCaA*
720fDC**                 eval      avlwgt = psmaxw - psswgt
720fMC                   eval      avlwgt = curMaxPltWgt - psswgt
CPCaA*
CPCaA*       If one case doesn't fit then get new pallet.
CPCaA*
CPCaAC                   if        psswgt > 0
CPCaaC                             and avlwgt < lwuwgt
CPCaAC                   exsr      getplt
CPCaAC                   iter
CPCaAC                   endif
CPCaAC                   endif
     *
     *       Calculate cube available on pallet.
     *
NCSbAC                   if        client = nicholas
NCSbAC                             and CurIsBatch
NCSbAC                   eval      avlcub = psmaxc1 - pscube
NCSbAC                   else
     C                   eval      avlcub = psmaxc - pscube
NCSbAC                   endif
     *
     *       If one case doesn't fit then get new pallet.
     *
     C                   if        pscube > 0  and
     C                             avlcub < lwucub
     C                   exsr      getplt
     C                   iter
     C                   endif
720gA*
720gA*       If option set to not split order detail line
720gA*       and entire qty won't fit on pallet, Then start a new pallet
720gA*
720gAC                   if        preventSplit and pspcs > 0
720hAC                             or preventSplitSP and spflag=*on and pspcs>0
730dAC                             or preventSplitFP and pspcs > 0
720gAC                   if        lwcube > avlcub or
720gAC                             (curMaxPltWgt > 0 and lwswgt > avlwgt)
720gAC                   exsr      getplt
720gAC                   iter
720gAC                   endif
720gAC                   endif
     *
     *       If total qty can't fit into NEWAVL
     *         And AVLCUB of pallet is less than the minimum cube
     *         Then Start a new pallet.
720gA*       This would never be triggered in DD2 because minmlt is zero.
     *
NCSbAC                   if        client = nicholas
NCSbAC                             and CurIsBatch
NCSbAC     psmaxc1       mult      minmlt        newmin
NCSbAC                   eval      newmax = psmaxc1
NCSbAC                   else
412aAC     psmaxc        mult      minmlt        newmin
412aAC                   eval      newmax = psmaxc * maxmlt
NCSbAC                   endif
412aMC                   eval      newavl = newmax - pscube
     *
412aAC                   if        lwcube > newavl  and
412aAC                             avlcub < newmin
412aAC                   exsr      getplt
412aAC                   iter
412aAC                   endif
     *
     *       Compare stop against min/max stop for pallet.
412 A*         PSSTP2 is not used for a separate pallet pick.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2  and
650bMC                             (dpflag = *off
650bMC                             and spflag = *off)
     C                   eval      psstp2 = lwstop
     C                   endif
     *
     *       Will entire qty fit on current pallet?
720gA*       Or Splits not allowed
720lM*          and pallet is not empty.
720hA*       Or Splits for *SP not allowed
720lM*          and pallet is not empty.
730dA*       Or Splits for Flex Pick is not allowed
MJKaA*       Or, MJK Contract route and pallet is empty?
     *
     *       Yes, Put on pallet and move on.
     *
720fDC**                 if        client = cpc
720fDC**                           or client = yhata
720gDC**                 if        curMaxPltWgt > 0
720gDC**                           and lwswgt > avlwgt
720fDC**   avlwgt        div       lwuwgt        maxqty
720gDC**   avlwgt        div       lwuwgt        maxqtyByWgt
720gDC**                 goto      cpctag
720gDC**                 endif
412aD*R         LWCUBE    IFLE AVLCUB
720fDC**                 if        lwcube <= newavl
720fAC                   if        (curMaxPltWgt = 0 and lwcube <= newavl)
720fAC                             or (curMaxPltWgt > 0 and lwcube <= newavl
720fAC                                 and lwswgt <= avlwgt)
720lDC**                           or preventSplit
720lMC                             or (preventSplit and pspcs > 0)
720lDC**                           or (preventSplitSP and spflag=*on)
720lMC                             or (preventSplitSP and spflag=*on
720lMC                                 and pspcs > 0)
730dAC                             or preventSplitFP
MJKaAC                             or client = mjkellner
MJKaAC                                and mjkContract
MJKaAC                                and pspcs = 0
     C                   add       lwqalc        pspcs
     C                   add       lwcube        pscube
     C                   add       lwswgt        psswgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500iDC**                 if        bldtyp = '*LOC'  or
500iDC**                           bldtyp = '*EXCP'
500iDC**                 update    lwrec3
500iDC**                 else
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**                 update    lwreca
500iDC**                 other
500iDC**                 update    lwrec2
500iDC**                 endsl
500iDC**                 endif
EBLaA*
EBLaA*         For Ellenbee, force DRYP chemicals onto ZCHEM
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC                   if        lwszon = 'DRYP'
EBLaAC                             and itdesg = 'CHEM'
EBLaAC                             and zchemComp <> '?'
EBLaAC                   eval      lwcomp = zchemComp
EBLaAC                   eval      lwtzon = zchemZone
EBLaAC                   eval      lwpzon = zchemZone
EBLaAC                   endif
EBLaAC                   endif

500iAC                   select
500iA
500iAC                   when      exceptionPass
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd8
700fAC                   Other
500iAC                   update    lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd8
700fAC                   Other
500iAC                   update    lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd9
700fAC                   Other
500iAC                   update    lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select

510lAC                   when      updrecad
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd3
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd10
700fAC                   Other
510lAC                   update    lwrecad
700fAC                   EndSL
510lAC                   eval      updrecad = *off

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd4
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd11
700fAC                   Other
500iAC                   update    lwreca
700fAC                   EndSL
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd5
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd12
700fAC                   Other
500iAC                   update    lwreco2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd6
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd13
700fAC                   Other
500iAC                   update    lwrecoa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd7
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd14
700fAC                   Other
520eAC                   update    lwrece
700fAC                   EndSL
500iA
500iMC                   endsl
520 A*
520 A*       At least one item placed on pallet, ck stop count.
520 AC                   if        stpcnt = 0
520 AC                   exsr      cntstp
520 AC                   endif
EBLaA*
EBLaA*         For Ellenbee, reset zones.
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC                   eval      lwcomp = svcomp
EBLaAC                   eval      lwtzon = svtzon
EBLaAC                   eval      lwpzon = svpzon
EBLaAC                   endif
500iA
     C                   leave
     C                   endif
MJKaA*
MJKaA*     Nope, split quantity.
MJKaA*
720gDC*    cpctag        tag
     C
MJKaA*       For MJK, do not split Contract labels.
MJKaA*
MJKaAC                   if        client = mjkellner
MJKaAC                             and mjkContract
MJKaAC                   exsr      getplt
MJKaAC                   iter
MJKaAC                   endif
     *
     *       Nope, calculate quantity that can fit on current pallet.
     *
     C     avlcub        div       lwucub        maxqty
750 Ac                   if        (preventSplit and pspcs=0 and forceonpallet)
750 Ac                             or (preventSplitSP and pspcs=0 and
750 Ac                                 forceonpallet and spflag=*on)
750 Ac     lwcube        div       lwucub        maxqty
750 ac                   endif
730bAC                   if        lwuwgt = 0
730bAC                   eval      maxqtyByWgt = maxqty
730bAC                   else
720fAC                   eval      maxqtyByWgt = avlwgt / lwuwgt
730bAC                   endif
720fDC**   cpctag        tag

720fA*       Use the smaller maxqty of weight or cube
720fA
720fMC                   if        curMaxPltWgt > 0  and maxqtyByWgt < maxqty
720fAC                   eval      maxqty = maxqtyByWgt
720fAC                   endif
     *
     *       Protect against unit cube greater than max pallet cube.
     *
     C                   if        maxqty = 0
     C                   eval      maxqty = 1
     C                   endif
     *
     *       Put quantity on pallet.
     *
     C     maxqty        mult      lwucub        tmpcub
     C     maxqty        mult      lwuwgt        tmpwgt
     C                   add       maxqty        pspcs
     C                   add       tmpcub        pscube
     C                   add       tmpwgt        psswgt
     *
     *       Adjust current label record with qty put on pallet.
     *
     C                   eval      lwqalc = maxqty
     C                   eval      lwcube = tmpcub
     C                   eval      lwswgt = tmpwgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500iDC**                 if        bldtyp = '*LOC'  or
500iDC**                           bldtyp = '*EXCP'
500iDC**                 update    lwrec3
500iDC**                 else
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**                 update    lwreca
500iDC**                 other
500iDC**                 update    lwrec2
500iDC**                 endsl
500iDC**                 endif
EBLaA*
EBLaA*         For Ellenbee, force DRYP chemicals onto ZCHEM
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC                   if        lwszon = 'DRYP'
EBLaAC                             and itdesg = 'CHEM'
EBLaAC                             and zchemComp <> '?'
EBLaAC                   eval      lwcomp = zchemComp
EBLaAC                   eval      lwtzon = zchemZone
EBLaAC                   eval      lwpzon = zchemZone
EBLaAC                   endif
EBLaAC                   endif

500iAC                   select
500iA
500iAC                   when      exceptionPass
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd8
700fAC                   Other
500iAC                   update    lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd8
700fAC                   Other
500iAC                   update    lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd9
700fAC                   Other
500iAC                   update    lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select

510lAC                   when      updrecad
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd3
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd10
700fAC                   Other
510lAC                   update    lwrecad
700fAC                   EndSL
510lAC                   eval      updrecad = *off

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd4
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd11
700fAC                   Other
500iAC                   update    lwreca
700fAC                   EndSL
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd5
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd12
700fAC                   Other
500iAC                   update    lwreco2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd6
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd13
700fAC                   Other
500iAC                   update    lwrecoa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd7
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd14
700fAC                   Other
520eAC                   update    lwrece
700fAC                   EndSL
500iA
500iMC                   endsl
520 A*
520 A*       At least one item placed on pallet, ck stop count.
520 AC                   if        stpcnt = 0
520 AC                   exsr      cntstp
520 AC                   endif
EBLaA*
EBLaA*         For Ellenbee, reset zones.
EBLaA*
EBLaAC                   if        client = ellenbee
EBLaAC                   eval      lwcomp = svcomp
EBLaAC                   eval      lwtzon = svtzon
EBLaAC                   eval      lwpzon = svpzon
EBLaAC                   endif
500iA
     *
     *       Create new label record with remaining quantity.
     *
     C                   if        svqalc > maxqty
     C                   eval      lwqalc = svqalc - maxqty
     C     lwqalc        mult      lwucub        lwcube
     C     lwqalc        mult      lwuwgt        lwswgt
     C                   eval      lwpal# = 0
     C                   eval      lwstat = svstat
     C                   eval      lwsdte = svsdte
     C                   eval      lwstim = svstim
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
500iDC**                 if        bldtyp = '*LOC'  or
500iDC**                           bldtyp = '*EXCP'
500iDC**                 write     lwrec3
500iDC**                 else
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**                 write     lwreca
500iDC**                 other
500iDC**                 write     lwrec2
500iDC**                 endsl
500iDC**                 endif

500iAC                   select
500iA
500iAC                   when      exceptionPass
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd8
700fAC                   Other
500iAC                   write     lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd1
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd8
700fAC                   Other
500iAC                   write     lwrec3
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd9
700fAC                   Other
500iAC                   write     lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd4
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd11
700fAC                   Other
500iAC                   write     lwreca
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd5
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd12
700fAC                   Other
500iAC                   write     lwreco2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd6
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd13
700fAC                   Other
500iAC                   write     lwrecoa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd7
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd14
700fAC                   Other
520eAC                   write     lwrece
700fAC                   EndSL
500iA
500iMC                   endsl
500iA
     C                   endif
     *
     C                   leave
     *
     C                   enddo
     *
     C                   enddo
     *
     *   Get any orphan merge records or bulk picks.
     *
500iDC**                 if        bldtyp = '*STOP'
500iMC                   if        normalPass and curByStop
417bA*
417bA*   Initialize save field to low value when building pallets
417bA*   in reverse order.
500iDC**                 if        oppbld = '3'
500iMC                   if        curByStopDesc
417bAC                   eval      svstop = *loval
417bAC                   else
     C                   eval      svstop = *hival
417bAC                   endif
     C                   exsr      merge
     C                   exsr      bulk
     C                   endif
     *
     *   Update current pallet before leaving to get new zone.
     *
500iDC**                 if        bldtyp = '*EXCP'
500iMC                   if        exceptionPass
411 D*          PSPCS     ANDGT0
410aAC                   goto      endbp
410aAC                   endif
417bA*
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500pMC                   when      curByStopDesc and zwgen = 1
417bAC                   update    psrec5
520eAC**                 when      curByGroup2   and zwgen = 1
520eAC**                 update    psrec5
417bAC                   other
     C                   update    psrec1
417bAC                   endsl
     *
     C     endbp         endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  BldPrePick  Build pallet(s) for zone.
620aA*
620aA*
620aAC     bldPrePick    begsr
     *
620bDC**                 eval      lststp = -(1)
     *
     *   Loop through labels for current zone.
     *
620bDC**                 eval      kytype = 'O'
620bDC**                 eval      xwwhdp = *blanks
620bDC**                 eval      xwaisl = *blanks
620bDC**   keylbf        chain     worklblf
620bDC**                 if        %found(worklblf)
620bDC**                 eval      xwwhdp = lwwhdp
620bDC**                 eval      xwaisl = lwaisl
620bDC**                 eval      first1 = *off
620bDC**                 endif

620bAC                   eval      first1 = *off
620bAC                   eval      kyaisl = 'PRE'
     C     keylbf        setll     worklblf
     C                   dow       forevr = forevr
     *
620bMC     keylbf        reade     worklblf                               78
     *
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *    Set Location/Level hold fields first time.
     *
     C                   if        first1 = *off
     C                   eval      first1 = *on
     C                   eval      lstwhd = lwwhdp
     C                   eval      lstloc = lwloc
     C                   eval      lstrlvl = lwrlvl
     C                   eval      lstord = lword
     C                   eval      lststop = lwstop
     C                   endif
     *
     *     When slot location number or level changes start a new
     *     pallet.  Each Pre-Pick route will have a unique location
     *     number and each pallet will have a unique level.
     *
     C                   if        lwloc <> lstloc
     C                             or lwrlvl <> lstrlvl
     C                   exsr      getplt
     C                   eval      lstloc = lwloc
     C                   eval      lstrlvl= lwrlvl
     C                   endif
     *
     *     Yes, Put on pallet and move on.
     *
     C                   add       lwqalc        pspcs
     C                   add       lwcube        pscube
     C                   add       lwswgt        psswgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     *
     *     Update stop range.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and dpflag = *off
650bMC                             and spflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif

     C                   update    lwrecf
     *
     *     At least one item placed on pallet, ck stop count.
     C                   if        stpcnt = 0
     C                   exsr      cntstp
     C                   endif
     *
     C                   enddo
     *
     C                   update    psrec5
     *
     C     endbpp        endsr
500gA*----------------------------------------------------------------
500gA*
500gA*  BLDTOTE  Build tote (Based on BLDPAL)
500gA*
500gA*          It is assumed that *LOC is not allowed for totes.
500gA*          It is assumed that nothing is merged into a Tote zone.
500gA*
500gAC     bldtote       begsr
     *
     *   Loop through routine twice.
     *     - First time is for non-chemical items.
     *     - Second time is for chemical items.
     *
500nDC**   1             do        2             pass
417bA*
417bA*    When building pallets in reverse order, set last stop
417bA*    to 99, this will position file pointer at top of file.
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      normalPass and curByStopDesc
417bAC                   eval      lststp = 99
417bAC                   other
     C                   eval      lststp = -(1)
417bAC                   endsl
417bA*
417eD*R                   MOVE *OFF      SPFLAG  1
415 D***                  Z-ADD0         LSTUNL
500gD***
500gD*** If building by location, do merge and bulk picks first.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***                  ENDIF
     *
     *   Loop through labels for current zone.
     *
     C                   eval      kytype = 'O'
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  MOVE *OFF      SPFLAG
500gD***        KEYLB2    SETLLWORKLBL3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklboa
500iDC**                 else
500iDC**   keylb2        setll     worklbla
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklbo2
500iDC**                 else
500iDC**   keylb2        setll     worklbl2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iMC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        setll     worklbl2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        setll     worklblad
510lAC                   other
500iAC     keylb2        setll     worklbla
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        setll     worklbo2
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        setll     worklboa
500iA
500iMC                   endsl
     *
     C                   dow       forevr = forevr
     *
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***        KEYLB2    READEWORKLBL3                 78
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklboa                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbla                               78
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklbo2                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbl2                               78
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

510lAC                   eval      updrecad = *off
500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        reade     worklbl2                               78
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        reade     worklblad                              78
510lAC                   eval      updrecad = *on
510lAC                   other
500iAC     keylb2        reade     worklbla                               78
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        reade     worklbo2                               78
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        reade     worklboa                               78
500iA
500iMC                   endsl
     *
     C                   if        *in78
     C                   leave
     C                   endif
410 A*      Skip exceptions w/o slot when not doing an *EXCP
410 A*        and zone is a merge zone (GEN > 1).
410 A*
500gD***        BLDTYP    IFNE '*EXCP'
500gMC                   if        lwgen > 1  and
410 AC                             lwasl2 = 'OUT'  and
410 AC                             lwdisp = *blanks
410 AC                   iter
410 AC                   endif
500gD***    Skip non-exceptions when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDNE'OUT'
500gD***                  ITER
500gD***                  ENDIF
500gD***    Skip exceptions with slot when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDEQ'OUT'
500gD***        LWDISP    ANDNE*BLANKS
500gD***                  ITER
500gD***                  ENDIF
500gA*
500gA*      Get PIRITEM record.
500gA*
500gAC     keyit         chain     piritem                            77
500gAC                   if        *in77
500gAC                   eval      itdesg = *blanks
500gAC                   endif
500nD **
500nD **     Skip chemical items on pass 1.
500nD **
500nDC**                 if        pass = 1  and
500nDC**                           itdesg = 'CHEM'
500nDC**                 iter
500nDC**                 endif
500nD **
500nD **     Skip non-chemical items on pass 2.
500nD **
500nDC**                 if        pass = 2  and
500nDC**                           itdesg <> 'CHEM'
500nDC**                 iter
500nDC**                 endif
     *
     *      Save record information.
     *
     C                   eval      svtype = lwtype
412 AC                   eval      svgen = lwgen
     C                   eval      svstop = lwstop
     C                   eval      svpzon = lwpzon
     C                   eval      svwhdp = lwwhdp
     C                   eval      svaisl = lwaisl
     C                   eval      svpseq = lwpseq
     C                   eval      svrlvl = lwrlvl
     C                   eval      svhand = lwhand
     C                   eval      svlbl# = lwlbl#
     C                   eval      svqalc = lwqalc
     C                   eval      svstat = lwstat
     C                   eval      svsdte = lwsdte
     C                   eval      svstim = lwstim
412aAC                   eval      svord = lword
500gA*
500gA*
500gA*     Since this routine breaks on order #, there is no reason
500gA*     to check if the stop changed, because an order # can only
500gA*     be for a single stop. The order number is checked below.
500gA*     Also, we are assuming that nothing gets merged onto a Tote.
500gA*
500gD***
500gD***    When stop changes, get merge items and bulk picks for stop.
500gD***
500gD***        BLDTYP    IFEQ '*STOP'
500gD***        LWSTOP    ANDNELSTSTP
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***
500gD***       Start new pallet if we exceed max stops per pallet.
500gD***       Note: Merge routine may have already counted new stop.
500gD***
500gD***        MRGSTP    IFNE SVSTOP
500gD***                  Z-ADDSVORD     LWORD
500gD***                  EXSR CHKSP
500gD***        STPCNT    IFGE OPFSTP
500gD***                  EXSR GETPLT
500gD***                  ENDIF
500gD***                  ADD  1         STPCNT
500gD***                  ENDIF
500gD***
500gD***                  MOVE 'O'       KYBTYP
500gD***                  Z-ADDSVSTOP    KYSTOP
500gD***                  SELEC
500gD***        OPPBLD    WHEQ '3'
500gD***        BLDTYP    ANDEQ'*STOP'
500gD***        KEYBK1    SETLLWORKLBHA
500gD***                  OTHER
500gD***        KEYBK1    SETLLWORKLBH2
500gD***                  ENDSL
412 D*R                   Z-ADDLWSTOP    LSTSTP
500gD***                  Z-ADDSVSTOP    LSTSTP
500gD***                  ITER
500gD***                  ENDIF
417dA*
417dA*    Set Dept/Aisle hold fields first time.
417dA*
417dAC                   if        first1 = *off
417dAC                   eval      first1 = *on
500gAC                   eval      lstord = lword
417dAC                   eval      lstwhd = lwwhdp
417dAC                   eval      lstasl = lwaisl
500nAC                   eval      lstdsg = itdesg
510gAC                   eval      lststop = lwstop
417dAC                   endif
500gD***
500gD***     When building by location and user wants a new pallet every
500gD***     time aisle changes, get new pallet when dept, aisle change
500gD***     and product put on current pallet.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        OPNWPL    ANDEQ'Y'
500gD***        PSCUBE    ANDNE*ZEROS
500gD***        LWWHDP    IFNE LSTWHD
500gD***        LWAISL    ORNE LSTASL
500gD***                  EXSR GETPLT
500gD***                  MOVE LWWHDP    LSTWHD
500gD***                  MOVE LWAISL    LSTASL
500gD***                  ENDIF
500gD***                  ENDIF
500gA*
500gA*       Get new pallet when order changes.
500gA*
500gAC                   if        curLimitOrders and
500gAC                             lword <> lstord
500jDC**                 if        pscube <> *zeros
500jMC                   if        pspcs <> *zeros
500gAC                   exsr      getplt
500gAC                   endif
500gAC                   eval      lstord = lword
500gAC                   endif
500nA*
500nA*       Get new pallet when designation changes to/from CHEM
500nA*
500nAC                   if        lstdsg <> itdesg
500nAC                   if        lstdsg = 'CHEM' or itdesg = 'CHEM'
500nMC                   if        pspcs <> *zeros
500nAC                   exsr      getplt
500nAC                   endif
500nAC                   endif
500nAC                   eval      lstdsg = itdesg
500nAC                   endif
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
     C                   dow       forevr = forevr
     *
     *       Calculate cube available on pallet.
     *
     C                   eval      avlcub = psmaxc - pscube
500fA*
500fA*       Calculate pcs available on pallet.
500fA*
500iDC**                 if        chkpcs = *on
500iDC**   opfpcs        sub       pspcs         avlpcs
500iMC                   if        curChkMaxPcs
500iMC                   eval      avlpcs = curPcsPerTote - pspcs
500fAC                   if        avlpcs < 0
500fAC                   eval      avlpcs = 0
500fAC                   endif
500fAC                   endif
     *
     *       If one case doesn't fit then get new pallet.
510bA*         Only check cube or pieces, not both.
     *
510bDC**                 if        pscube > 0  and
510bDC**                           avlcub < lwucub  or
500iDC**                           chkpcs = *on  and
510bAC                   if        not curChkMaxPcs and
510bAC                             pscube > 0  and
510bAC                             avlcub < lwucub
510bAC                             or
500iMC                             curChkMaxPcs and
500fAC                             avlpcs = 0
     C                   exsr      getplt
     C                   iter
     C                   endif
     *
     *       If total qty can't fit into NEWAVL
     *         And AVLCUB of pallet is less than the minimum cube
     *         Then Start a new pallet.
     *
412aAC     psmaxc        mult      minmlt        newmin
412aAC                   eval      newmax = psmaxc * maxmlt
412aMC                   eval      newavl = newmax - pscube
     *
510bA*         Only check cube if not working with max pieces.
510bA*
510bAC                   if        not curChkMaxPcs
412aAC                   if        lwcube > newavl  and
412aAC                             avlcub < newmin
412aAC                   exsr      getplt
412aAC                   iter
412aAC                   endif
510bAC                   endif
     *
     *       Compare stop against min/max stop for pallet.
412 A*         PSSTP2 is not used for a separate pallet pick.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif
     *
     *       Will entire qty fit on current pallet?
     *
     *       Yes, Put on pallet and move on.
     *
412aD*R         LWCUBE    IFLE AVLCUB
412aMC                   if        lwcube <= newavl  and
500iDC**                           chkpcs = *off  or
500iMC                             not curChkMaxPcs or
510bDC**                           lwcube <= newavl  and
500iDC**                           chkpcs = *on  and
500iMC                             curChkMaxPcs and
500fAC                             lwqalc <= avlpcs
     C                   add       lwqalc        pspcs
     C                   add       lwcube        pscube
     C                   add       lwswgt        psswgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  UPDATLWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwrecoa
500iDC**                 else
500iDC**                 update    lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwreco2
500iDC**                 else
500iDC**                 update    lwrec2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   update    lwrec2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
500iAC                   update    lwreca
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   update    lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   update    lwrecoa
500iA
500iMC                   endsl
500iA
     C                   leave
     C                   endif
     *
     *       Nope, calculate quantity that can fit on current pallet.
     *
500pAC                   if        lwucub <= 0
500pAC                   eval      lwucub = 1.000
500pAC                   endif
     C     avlcub        div       lwucub        maxqty
750 Ac                   if        (preventSplit and pspcs=0 and forceonpallet)
750 Ac                             or (preventSplitSP and pspcs=0 and
750 Ac                                 forceonpallet and spflag=*on)
750 Ac     lwcube        div       lwucub        maxqty
750 Ac                   endif
     *
     *       Protect against unit cube greater than max pallet cube.
     *
     C                   if        maxqty = 0
     C                   eval      maxqty = 1
     C                   endif
510bA*
510bA*       Override max qty when working with max pieces.
510bA*
510bAC                   if        curChkMaxPcs
510bAC                   eval      maxqty = avlpcs
510bAC                   endif
510bD**
510bD**      Make sure quantity not greater than max pcs for pallet.
510bD**
500iDC**                 if        chkpcs = *on  and
510bDC**                 if        curChkMaxPcs and
510bDC**                           maxqty > avlpcs
510bDC**                 eval      maxqty = avlpcs
510bDC**                 endif
     *
     *       Put quantity on pallet.
     *
     C     maxqty        mult      lwucub        tmpcub
     C     maxqty        mult      lwuwgt        tmpwgt
     C                   add       maxqty        pspcs
     C                   add       tmpcub        pscube
     C                   add       tmpwgt        psswgt
     *
     *       Adjust current label record with qty put on pallet.
     *
     C                   eval      lwqalc = maxqty
     C                   eval      lwcube = tmpcub
     C                   eval      lwswgt = tmpwgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  UPDATLWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwrecoa
500iDC**                 else
500iDC**                 update    lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwreco2
500iDC**                 else
500iDC**                 update    lwrec2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   update    lwrec2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
500iAC                   update    lwreca
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   update    lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   update    lwrecoa
500iA
500iMC                   endsl
500iA
     *
     *       Create new label record with remaining quantity.
     *
     C                   if        svqalc > maxqty
     C                   eval      lwqalc = svqalc - maxqty
     C     lwqalc        mult      lwucub        lwcube
     C     lwqalc        mult      lwuwgt        lwswgt
     C                   eval      lwpal# = 0
     C                   eval      lwstat = svstat
     C                   eval      lwsdte = svsdte
     C                   eval      lwstim = svstim
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  WRITELWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 write     lwrecoa
500iDC**                 else
500iDC**                 write     lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 write     lwreco2
500iDC**                 else
500iDC**                 write     lwrec2
500iDC**                 endif
500iDC**                 endsl

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   write     lwrec2
500iA
500iMC                   when      curByStopLocDsc
500iAC                   write     lwreca
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   write     lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   write     lwrecoa
500iA
500iMC                   endsl
500iA
     C                   endif
500gD***                  ENDIF
     *
     C                   leave
     *
     C                   enddo
     *
     C                   enddo
     *
500nDC**                 enddo
500gD***
500gD*** Get any orphan merge records or bulk picks.
500gD***
500gD***        BLDTYP    IFEQ '*STOP'
500gD***
500gD*** Initialize save field to low value when building pallets
500gD*** in reverse order.
500gD***        OPPBLD    IFEQ '3'
500gD***                  Z-ADD*LOVAL    SVSTOP
500gD***                  ELSE
500gD***                  Z-ADD*HIVAL    SVSTOP
500gD***                  ENDIF
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***                  ENDIF
     *
     *   Update current pallet before leaving to get new zone.
     *
500gD***        BLDTYP    IFEQ '*EXCP'
411 D*          PSPCS     ANDGT0
500gD***                  GOTO ENDBP
500gD***                  ENDIF
417bA*
     C                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500pMC                   when      curByStopDesc and zwgen = 1
417bAC                   update    psrec5
417bAC                   other
     C                   update    psrec1
417bAC                   endsl
     *
     C     endbldtote    endsr
700aA
700aA*----------------------------------------------------------------
700aA*  BLDTOTEBOX   Build totes for AMP boxes
700aA*----------------------------------------------------------------
700aA
700aAC     bldtotebox    begsr
      /free

         // Loop through ampxref records looking for boxes

         lastBoxId = 0;

         setgt ($pwhse: $prtid: lastBoxId) ampxref5;

         dow forever = forever;

           reade ($pwhse: $prtid) ampxref5;
           if %eof(ampxref5);
700bD        //leavesr;
700bM        leave;
           endif;

           // Get corresponding WORKLBL record

730eD      //chain (axdlbl#) worklbl;
730eM      chain ($pwhse: axdlbl#) worklblw;
730eM      if not %found(worklblw);
             iter;
           endif;

           // Move on to next box if different zone.

720dD      //if lwszon <> zwszon;
720dM      if lwlwszon <> zwszon;
73oeM        unlock worklblw;
             setgt ($pwhse: $prtid: axaboxid) ampxref5;
             iter;
           endif;

           // Save label info

720dM      svtype = lwlwtype;
720dM      svgen  = lwlwgen;
720dM      svstop = lwlwstop;
720dM      svpzon = lwlwpzon;
720dM      svwhdp = lwlwwhdp;
720dM      svaisl = lwlwaisl;
720dM      svpseq = lwlwpseq;
720dM      svrlvl = lwlwrlvl;
720dM      svhand = lwlwhand;
720dM      svlbl# = lwlwlbl#;
720dM      svqalc = lwlwqalc;
720dM      svstat = lwlwstat;
720dM      svsdte = lwlwsdte;
720dM      svstim = lwlwstim;
720dM      svord  = lwlword;

           // Get item info

720dD      //chain (lwwhse: lwitem) piritem;
720dM      chain (lwlwwhse: lwlwitem) piritem;
           if not %found(piritem);
             itdesg = '';
           endif;

           // First time through we don't want to get new pallet.

           if  first1 = *off;
             first1 = *on;
             lastBoxId = axaboxid;
700cA        // change pltsum pallet # to box #
720dD        //chain (lwwhse: axaboxid) ampbox;
720dM        chain (lwlwwhse: axaboxid) ampbox;
700cA        if %found(ampbox);
700cA          pspal# = abxbox#;
700cA        endif;
           endif;

           // Start new tote for a new box

           if axaboxid <> lastBoxId;
             exsr getplt;
             lastBoxId = axaboxid;
700cA        // change pltsum pallet # to box #
720dD        //chain (lwwhse: axaboxid) ampbox;
720dM        chain (lwlwwhse: axaboxid) ampbox;
700cA        if %found(ampbox);
700cA          pspal# = abxbox#;
700cA        endif;
           endif;

           // Put label into tote

720dM      pspcs  += lwlwqalc;
720dM      pscube += lwlwcube;
720dM      psswgt += lwlwswgt;
720dM      lwlwpal# = psplid;
720dM      lwlwstat = 'B';
720dM      lwlwsdte = today;
720dM      lwlwstim = %dec(%time());

           update lwrec;

         enddo;

         // Update current tote before leaving

         if lastBoxId <> 0;

           select;
             when curByStopDesc and zwgen = 1;
               update psrec5;
             other;
               update psrec1;
             endsl;

         endif;

      /end-free
     C     endbldtoteb   endsr
510cA*----------------------------------------------------------------
510cA*
510cA*  BLDTOTECUBE  Build tote using cube
510cA*
510cA*          It is assumed that *LOC is not allowed for totes.
510cA*          It is assumed that nothing is merged into a Tote zone.
510cA*
510cAC     bldtotecube   begsr
417bA*
417bA*    When building pallets in reverse order, set last stop
417bA*    to 99, this will position file pointer at top of file.
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      normalPass and curByStopDesc
417bAC                   eval      lststp = 99
417bAC                   other
     C                   eval      lststp = -(1)
417bAC                   endsl
417bA*
417eD*R                   MOVE *OFF      SPFLAG  1
415 D***                  Z-ADD0         LSTUNL
500gD***
500gD*** If building by location, do merge and bulk picks first.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***                  ENDIF
     *
     *   Loop through labels for current zone.
     *
     C                   eval      kytype = 'O'
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  MOVE *OFF      SPFLAG
500gD***        KEYLB2    SETLLWORKLBL3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklboa
500iDC**                 else
500iDC**   keylb2        setll     worklbla
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklbo2
500iDC**                 else
500iDC**   keylb2        setll     worklbl2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iMC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        setll     worklbl2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        setll     worklblad
510lAC                   other
500iAC     keylb2        setll     worklbla
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        setll     worklbo2
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        setll     worklboa
500iA
500iMC                   endsl
     *
     C                   dow       forevr = forevr
     *
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***        KEYLB2    READEWORKLBL3                 78
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklboa                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbla                               78
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklbo2                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbl2                               78
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

510lAC                   eval      updrecad = *off
500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        reade     worklbl2                               78
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        reade     worklblad                              78
510lAC                   eval      updrecad = *on
510lAC                   other
500iAC     keylb2        reade     worklbla                               78
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        reade     worklbo2                               78
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        reade     worklboa                               78
500iA
500iMC                   endsl
     *
     C                   if        *in78
     C                   leave
     C                   endif
510mD**     Skip exceptions w/o slot when not doing an *EXCP
510mD**       and zone is a merge zone (GEN > 1).
510mD**
500gD***        BLDTYP    IFNE '*EXCP'
510mDC**                 if        lwgen > 1  and
510mDC**                           lwasl2 = 'OUT'  and
510mDC**                           lwdisp = *blanks
510mDC**                 iter
510mDC**                 endif
500gD***    Skip non-exceptions when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDNE'OUT'
500gD***                  ITER
500gD***                  ENDIF
500gD***    Skip exceptions with slot when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDEQ'OUT'
500gD***        LWDISP    ANDNE*BLANKS
500gD***                  ITER
500gD***                  ENDIF
500gA*
500gA*      Get PIRITEM record.
500gA*
500gAC     keyit         chain     piritem                            77
500gAC                   if        *in77
500gAC                   eval      itdesg = *blanks
500gAC                   endif
     *
     *      Save record information.
     *
     C                   eval      svtype = lwtype
412 AC                   eval      svgen = lwgen
     C                   eval      svstop = lwstop
     C                   eval      svpzon = lwpzon
     C                   eval      svwhdp = lwwhdp
     C                   eval      svaisl = lwaisl
     C                   eval      svpseq = lwpseq
     C                   eval      svrlvl = lwrlvl
     C                   eval      svhand = lwhand
     C                   eval      svlbl# = lwlbl#
     C                   eval      svqalc = lwqalc
     C                   eval      svstat = lwstat
     C                   eval      svsdte = lwsdte
     C                   eval      svstim = lwstim
412aAC                   eval      svord = lword
500gA*
500gA*
500gA*     Since this routine breaks on order #, there is no reason
500gA*     to check if the stop changed, because an order # can only
500gA*     be for a single stop. The order number is checked below.
500gA*     Also, we are assuming that nothing gets merged onto a Tote.
500gA*
500gD***
500gD***    When stop changes, get merge items and bulk picks for stop.
500gD***
500gD***        BLDTYP    IFEQ '*STOP'
500gD***        LWSTOP    ANDNELSTSTP
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***
500gD***       Start new pallet if we exceed max stops per pallet.
500gD***       Note: Merge routine may have already counted new stop.
500gD***
500gD***        MRGSTP    IFNE SVSTOP
500gD***                  Z-ADDSVORD     LWORD
500gD***                  EXSR CHKSP
500gD***        STPCNT    IFGE OPFSTP
500gD***                  EXSR GETPLT
500gD***                  ENDIF
500gD***                  ADD  1         STPCNT
500gD***                  ENDIF
500gD***
500gD***                  MOVE 'O'       KYBTYP
500gD***                  Z-ADDSVSTOP    KYSTOP
500gD***                  SELEC
500gD***        OPPBLD    WHEQ '3'
500gD***        BLDTYP    ANDEQ'*STOP'
500gD***        KEYBK1    SETLLWORKLBHA
500gD***                  OTHER
500gD***        KEYBK1    SETLLWORKLBH2
500gD***                  ENDSL
412 D*R                   Z-ADDLWSTOP    LSTSTP
500gD***                  Z-ADDSVSTOP    LSTSTP
500gD***                  ITER
500gD***                  ENDIF
417dA*
417dA*    Set Dept/Aisle hold fields first time.
417dA*
417dAC                   if        first1 = *off
417dAC                   eval      first1 = *on
500gAC                   eval      lstord = lword
417dAC                   eval      lstwhd = lwwhdp
417dAC                   eval      lstasl = lwaisl
500nAC                   eval      lstdsg = itdesg
510gAC                   eval      lststop = lwstop
417dAC                   endif
500gD***
500gD***     When building by location and user wants a new pallet every
500gD***     time aisle changes, get new pallet when dept, aisle change
500gD***     and product put on current pallet.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        OPNWPL    ANDEQ'Y'
500gD***        PSCUBE    ANDNE*ZEROS
500gD***        LWWHDP    IFNE LSTWHD
500gD***        LWAISL    ORNE LSTASL
500gD***                  EXSR GETPLT
500gD***                  MOVE LWWHDP    LSTWHD
500gD***                  MOVE LWAISL    LSTASL
500gD***                  ENDIF
500gD***                  ENDIF
500gA*
HAR A*    Force curlimitorders *ON for Walgreen's orders
HAR A*
HAR AC                   if        lword <> lstord
HAR AC                             and client = harbor
HAR AC                             and curLimitOrders = *off
HAR AC     keyoh         chain     ordh
HAR AC                   if        %found(ordh)
HAR AC                   eval      harmsc_base = ohmisc
HAR AC                   if        harmsc_asn = 'Y'
HAR AC                   eval      curLimitOrders = *on
HAR AC                   endif
HAR AC                   endif
HAR AC                   endif
HAR A*
500gA*       Get new pallet when order changes.
500gA*
500gAC                   if        curLimitOrders and
500gAC                             lword <> lstord
500jDC**                 if        pscube <> *zeros
500jMC                   if        pspcs <> *zeros
500gAC                   exsr      getplt
500gAC                   endif
500gAC                   eval      lstord = lword
510gAC                   eval      lststop = lwstop
500gAC                   endif
500gA*
HAR A*    Set curLimitOrders back to its original value
HAR A*
HAR AC                   eval      curLimitOrders = HldCurLimitOrd
500gA*
500gA*       Get new pallet when stop changes.
500gA*
510gAC                   if        lwstop <> lststop
510gAC                   if        pspcs <> *zeros
510gAC                   exsr      getplt
510gAC                   endif
510gAC                   eval      lststop = lwstop
510gAC                   endif
500nA*
500nA*       Get new pallet when designation changes to/from CHEM
500nA*
500nAC                   if        lstdsg <> itdesg
500nAC                   if        lstdsg = 'CHEM' or itdesg = 'CHEM'
500nMC                   if        pspcs <> *zeros
500nAC                   exsr      getplt
500nAC                   endif
500nAC                   endif
500nAC                   eval      lstdsg = itdesg
500nAC                   endif
CTWaA*
CTWaA*       For City Wholesale ...
CTWaA*         Get new pallet when aisle changes from 101.
CTWaA*
CTWaA ***                if        client = citywholesale
CTWaA ***                          and lwaisl <> lstasl
CTWaA ***                          and (lstasl='101' or lwaisl='101')
CTWaA ***                if        pspcs <> *zeros
CTWaA ***                exsr      getplt
CTWaA ***                endif
CTWaA ***                eval      lstasl = lwaisl
CTWaA ***                endif
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
     C                   dow       forevr = forevr
     *
     *       Calculate cube available on pallet.
     *
     C                   eval      avlcub = psmaxc - pscube
     *
     *       If one case doesn't fit then get new pallet.
     *
510bDC**                 if        pscube > 0  and
510bDC**                           avlcub < lwucub  or
500iDC**                           chkpcs = *on  and
510bAC                   if        pscube > 0  and
510bAC                             avlcub < lwucub
     C                   exsr      getplt
     C                   iter
     C                   endif
     *
     *       If total qty can't fit into NEWAVL
     *         And AVLCUB of pallet is less than the minimum cube
     *         Then Start a new pallet.
     *
412aAC     psmaxc        mult      minmlt        newmin
510cDC**                 eval      newmax = psmaxc * maxmlt
510cMC                   eval      newmax = psmaxc
412aMC                   eval      newavl = newmax - pscube
     *
412aAC                   if        lwcube > newavl  and
412aAC                             avlcub < newmin
412aAC                   exsr      getplt
412aAC                   iter
412aAC                   endif
     *
     *       Compare stop against min/max stop for pallet.
412 A*         PSSTP2 is not used for a separate pallet pick.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif
     *
     *       Will entire qty fit on current pallet?
     *
     *       Yes, Put on pallet and move on.
     *
412aD*R         LWCUBE    IFLE AVLCUB
510cMC                   if        lwcube <= newavl
     C                   add       lwqalc        pspcs
     C                   add       lwcube        pscube
     C                   add       lwswgt        psswgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  UPDATLWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwrecoa
500iDC**                 else
500iDC**                 update    lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwreco2
500iDC**                 else
500iDC**                 update    lwrec2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   update    lwrec2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
500iAC                   update    lwreca
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   update    lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   update    lwrecoa
500iA
500iMC                   endsl
500iA
     C                   leave
     C                   endif
     *
     *       Nope, calculate quantity that can fit on current pallet.
     *
500pAC                   if        lwucub <= 0
500pAC                   eval      lwucub = 1.000
500pAC                   endif
     C     avlcub        div       lwucub        maxqty
750 Ac                   if        (preventSplit and pspcs=0 and forceonpallet)
750 Ac                             or (preventSplitSP and pspcs=0 and
750 Ac                                 forceonpallet and spflag=*on)
750 Ac     lwcube        div       lwucub        maxqty
750 Ac                   endif
     *
     *       Protect against unit cube greater than max pallet cube.
     *
     C                   if        maxqty = 0
     C                   eval      maxqty = 1
     C                   endif
     *
     *       Put quantity on pallet.
     *
     C     maxqty        mult      lwucub        tmpcub
     C     maxqty        mult      lwuwgt        tmpwgt
     C                   add       maxqty        pspcs
     C                   add       tmpcub        pscube
     C                   add       tmpwgt        psswgt
     *
     *       Adjust current label record with qty put on pallet.
     *
     C                   eval      lwqalc = maxqty
     C                   eval      lwcube = tmpcub
     C                   eval      lwswgt = tmpwgt
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  UPDATLWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwrecoa
500iDC**                 else
500iDC**                 update    lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 update    lwreco2
500iDC**                 else
500iDC**                 update    lwrec2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   update    lwrec2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
500iAC                   update    lwreca
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   update    lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   update    lwrecoa
500iA
500iMC                   endsl
500iA
     *
     *       Create new label record with remaining quantity.
     *
     C                   if        svqalc > maxqty
     C                   eval      lwqalc = svqalc - maxqty
     C     lwqalc        mult      lwucub        lwcube
     C     lwqalc        mult      lwuwgt        lwswgt
     C                   eval      lwpal# = 0
     C                   eval      lwstat = svstat
     C                   eval      lwsdte = svsdte
     C                   eval      lwstim = svstim
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  WRITELWREC3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**                 write     lwrecoa
500iDC**                 else
500iDC**                 write     lwreca
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**                 write     lwreco2
500iDC**                 else
500iDC**                 write     lwrec2
500iDC**                 endif
500iDC**                 endsl

500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC                   write     lwrec2
500iA
500iMC                   when      curByStopLocDsc
500iAC                   write     lwreca
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   write     lwreco2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   write     lwrecoa
500iA
500iMC                   endsl
500iA
     C                   endif
500gD***                  ENDIF
     *
     C                   leave
     *
     C                   enddo
     *
     C                   enddo
     *
500nDC**                 enddo
500gD***
500gD*** Get any orphan merge records or bulk picks.
500gD***
500gD***        BLDTYP    IFEQ '*STOP'
500gD***
500gD*** Initialize save field to low value when building pallets
500gD*** in reverse order.
500gD***        OPPBLD    IFEQ '3'
500gD***                  Z-ADD*LOVAL    SVSTOP
500gD***                  ELSE
500gD***                  Z-ADD*HIVAL    SVSTOP
500gD***                  ENDIF
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***                  ENDIF
     *
     *   Update current pallet before leaving to get new zone.
     *
500gD***        BLDTYP    IFEQ '*EXCP'
411 D*          PSPCS     ANDGT0
500gD***                  GOTO ENDBP
500gD***                  ENDIF
417bA*
     C                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500pMC                   when      curByStopDesc and zwgen = 1
417bAC                   update    psrec5
417bAC                   other
     C                   update    psrec1
417bAC                   endsl
     *
     C     endbldtotec   endsr
510cA*----------------------------------------------------------------
510cA*
510cA*  BLDTOTEPCS  Build tote by pieces
510cA*
510cA*          It is assumed that *LOC is not allowed for totes.
510cA*          It is assumed that nothing is merged into a Tote zone.
510cA*
510cAC     bldtotepcs    begsr
     *
510eD*** Loop through routine twice.
510eD***   - First time is for full totes.
510eD***   - Second time is for everything left over.
510eD***
510eD ***  1             do        2             pass
417bA*
417bA*    When building pallets in reverse order, set last stop
417bA*    to 99, this will position file pointer at top of file.
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      normalPass and curByStopDesc
417bAC                   eval      lststp = 99
417bAC                   other
     C                   eval      lststp = -(1)
417bAC                   endsl
417bA*
417eD*R                   MOVE *OFF      SPFLAG  1
415 D***                  Z-ADD0         LSTUNL
500gD***
500gD*** If building by location, do merge and bulk picks first.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***                  ENDIF
     *
     *   Loop through labels for current zone.
     *
     C                   eval      kytype = 'O'
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***                  MOVE *OFF      SPFLAG
500gD***        KEYLB2    SETLLWORKLBL3
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklboa
500iDC**                 else
500iDC**   keylb2        setll     worklbla
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        setll     worklbo2
500iDC**                 else
500iDC**   keylb2        setll     worklbl2
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

500iMC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        setll     worklbl2
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        setll     worklblad
510lAC                   other
500iAC     keylb2        setll     worklbla
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        setll     worklbo2
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        setll     worklboa
500iA
500iMC                   endsl
     *
     C                   dow       forevr = forevr
     *
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        BLDTYP    OREQ '*EXCP'
500gD***        KEYLB2    READEWORKLBL3                 78
500gD***                  ELSE
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklboa                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbla                               78
500iDC**                 endif
500iDC**                 other
500iDC**   opnwor        ifeq      'Y'
500iDC**   keylb2        reade     worklbo2                               78
500iDC**                 else
500iDC**   keylb2        reade     worklbl2                               78
500iDC**                 endif
500iDC**                 endsl
500gD***                  ENDIF

510lAC                   eval      updrecad = *off
500iAC                   select
500iA
500iMC                   when      curByStopLocAsc
500iAC     keylb2        reade     worklbl2                               78
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc
510lAC     keylb2        reade     worklblad                              78
510lAC                   eval      updrecad = *on
510lAC                   other
500iAC     keylb2        reade     worklbla                               78
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
500iAC     keylb2        reade     worklbo2                               78
500iA
500iMC                   when      curByStopOrdDsc
500iAC     keylb2        reade     worklboa                               78
500iA
500iMC                   endsl
     *
     C                   if        *in78
     C                   leave
     C                   endif
510mD**     Skip exceptions w/o slot when not doing an *EXCP
510mD**       and zone is a merge zone (GEN > 1).
510mD**
500gD***        BLDTYP    IFNE '*EXCP'
510mDC**                 if        lwgen > 1  and
510mDC**                           lwasl2 = 'OUT'  and
510mDC**                           lwdisp = *blanks
510mDC**                 iter
510mDC**                 endif
510cA*
510cA*      If record already on a pallet, then skip it.
510cA*
510cAC                   if        lwpal# > 0
510cAC                   iter
510cAC                   endif
500gD***    Skip non-exceptions when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDNE'OUT'
500gD***                  ITER
500gD***                  ENDIF
500gD***    Skip exceptions with slot when doing an *EXCP run.
500gD***
500gD***        BLDTYP    IFEQ '*EXCP'
500gD***        LWASL2    ANDEQ'OUT'
500gD***        LWDISP    ANDNE*BLANKS
500gD***                  ITER
500gD***                  ENDIF
500gA*
500gA*      Get PIRITEM record.
500gA*
500gAC     keyit         chain     piritem                            77
500gAC                   if        *in77
500gAC                   eval      itdesg = *blanks
500gAC                   endif
     *
     *      Save record information.
     *
     C                   eval      svtype = lwtype
412 AC                   eval      svgen = lwgen
     C                   eval      svstop = lwstop
     C                   eval      svpzon = lwpzon
     C                   eval      svwhdp = lwwhdp
     C                   eval      svaisl = lwaisl
     C                   eval      svpseq = lwpseq
     C                   eval      svrlvl = lwrlvl
     C                   eval      svhand = lwhand
     C                   eval      svlbl# = lwlbl#
     C                   eval      svqalc = lwqalc
     C                   eval      svstat = lwstat
     C                   eval      svsdte = lwsdte
     C                   eval      svstim = lwstim
412aAC                   eval      svord = lword
500gA*
500gA*     Since this routine breaks on order #, there is no reason
500gA*     to check if the stop changed, because an order # can only
500gA*     be for a single stop. The order number is checked below.
500gA*     Also, we are assuming that nothing gets merged onto a Tote.
500gA*
500gD***
500gD***    When stop changes, get merge items and bulk picks for stop.
500gD***
500gD***        BLDTYP    IFEQ '*STOP'
500gD***        LWSTOP    ANDNELSTSTP
500gD***                  EXSR MERGE
500gD***                  EXSR BULK
500gD***
500gD***       Start new pallet if we exceed max stops per pallet.
500gD***       Note: Merge routine may have already counted new stop.
500gD***
500gD***        MRGSTP    IFNE SVSTOP
500gD***                  Z-ADDSVORD     LWORD
500gD***                  EXSR CHKSP
500gD***        STPCNT    IFGE OPFSTP
500gD***                  EXSR GETPLT
500gD***                  ENDIF
500gD***                  ADD  1         STPCNT
500gD***                  ENDIF
500gD***
500gD***                  MOVE 'O'       KYBTYP
500gD***                  Z-ADDSVSTOP    KYSTOP
500gD***                  SELEC
500gD***        OPPBLD    WHEQ '3'
500gD***        BLDTYP    ANDEQ'*STOP'
500gD***        KEYBK1    SETLLWORKLBHA
500gD***                  OTHER
500gD***        KEYBK1    SETLLWORKLBH2
500gD***                  ENDSL
412 D*R                   Z-ADDLWSTOP    LSTSTP
500gD***                  Z-ADDSVSTOP    LSTSTP
500gD***                  ITER
500gD***                  ENDIF
417dA*
417dA*    Set Dept/Aisle hold fields first time.
417dA*
417dAC                   if        first1 = *off
417dAC                   eval      first1 = *on
500gAC                   eval      lstord = lword
417dAC                   eval      lstwhd = lwwhdp
417dAC                   eval      lstasl = lwaisl
500nAC                   eval      lstdsg = itdesg
510gAC                   eval      lststop = lwstop
417dAC                   endif
500gD***
500gD***     When building by location and user wants a new pallet every
500gD***     time aisle changes, get new pallet when dept, aisle change
500gD***     and product put on current pallet.
500gD***
500gD***        BLDTYP    IFEQ '*LOC'
500gD***        OPNWPL    ANDEQ'Y'
500gD***        PSCUBE    ANDNE*ZEROS
500gD***        LWWHDP    IFNE LSTWHD
500gD***        LWAISL    ORNE LSTASL
500gD***                  EXSR GETPLT
500gD***                  MOVE LWWHDP    LSTWHD
500gD***                  MOVE LWAISL    LSTASL
500gD***                  ENDIF
500gD***                  ENDIF
510iA*
510iA*       Get new pallet when stop changes.
510iA*
510iAC                   if        lwstop <> lststop
510iAC                   if        pspcs <> *zeros
510iAC                   exsr      getplt
510iAC                   endif
510iAC                   eval      lststop = lwstop
510iAC                   endif
HAR A*
HAR A*    Force curlimitorders *ON for Walgreen's orders
HAR A*
HAR AC                   if        lword <> lstord
HAR AC                             and client = harbor
HAR AC                             and curLimitOrders = *off
HAR AC     keyoh         chain     ordh
HAR AC                   if        %found(ordh)
HAR AC                   eval      harmsc_base = ohmisc
HAR AC                   if        harmsc_asn = 'Y'
HAR AC                   eval      curLimitOrders = *on
HAR AC                   endif
HAR AC                   endif
HAR AC                   endif
500gA*
500gA*       Get new pallet when order changes.
500gA*
500gAC                   if        curLimitOrders and
500gAC                             lword <> lstord
500jDC**                 if        pscube <> *zeros
500jMC                   if        pspcs <> *zeros
510eAC                   eval      ToteFlag = *On
500gAC                   exsr      getplt
500gAC                   endif
500gAC                   eval      lstord = lword
500gAC                   endif
HAR A*
HAR A*    Set curLimitOrders back to its original value
HAR A*
HAR AC                   eval      curLimitOrders = HldCurLimitOrd
500nA*
500nA*       Get new pallet when designation changes to/from CHEM
500nA*
500nAC                   if        lstdsg <> itdesg
500nAC                   if        lstdsg = 'CHEM' or itdesg = 'CHEM'
500nMC                   if        pspcs <> *zeros
510eAC                   eval      ToteFlag = *On
500nAC                   exsr      getplt
500nAC                   endif
500nAC                   endif
500nAC                   eval      lstdsg = itdesg
500nAC                   endif
CTWaA*
CTWaA*       For City Wholesale ...
CTWaA*         Get new pallet when aisle changes from 101.
CTWaA*
CTWaA ***                if        client = citywholesale
CTWaA ***                          and lwaisl <> lstasl
CTWaA ***                          and (lstasl='101' or lwaisl='101')
CTWaA ***                if        pspcs <> *zeros
CTWaA ***                eval      ToteFlag = *On
CTWaA ***                exsr      getplt
CTWaA ***                endif
CTWaA ***                eval      lstasl = lwaisl
CTWaA ***                endif
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
510eA*       If qty >= max pieces for tote build full tote

510eAC                   select
CTWcA*       If city wholesale only execute bldparttote
CTWcAC                   when      client = citywholesale
CTWcAC                   exsr      bldparttote

510eA*       If qty >= max pieces for tote build full tote

510eAC                   when      lwqalc >= curPcsPerTote
510eAC                   exsr      bldfulltote

510eA*       If qty fits on partial tote add to partial tote

510eAC                   when      lwqalc <  curPcsPerTote
510eAC                   exsr      bldparttote
510iA
510eAC                   endsl
510iA
510iAC                   enddo
510iA
510iAC                   select
510iAC                   when      curByStopDesc and zwgen = 1
510iAC                   update    psrec5
510iAC                   other
510iAC                   update    psrec1
510iAC                   endsl
     *
     C     endbldtotep   endsr
510eA*----------------------------------------------------------------
510eA*  BLDPARTTOTE  Build/add pieces to partial tote
510eA*
510eAC     bldparttote   begsr
510iA*
510iA*     Put qty on existing pallet or new pallet.
510iA*     Don't hesitate to split item across pallets.
510iA*
510iAC                   dow       forevr = forevr
510eA*
510eA*       Calculate pcs available on pallet.
510eA*
510iMC                   eval      avlpcs = curPcsPerTote - pspcs
510eA
510iA*       Get new pallet if no space left on current pallet.

510iMC                   if        avlpcs <= 0
510eAC                   eval      ToteFlag = *On
510eAC                   exsr      getplt
510eAC                   eval      avlpcs = curPcsPerTote
510eAC                   endif
510eA*
510eA*       Compare stop against min/max stop for pallet.
510eA*         PSSTP2 is not used for a separate pallet pick.
510eA*
510eAC                   if        psstp1 = 0  or
510eAC                             lwstop < psstp1
510eAC                   eval      psstp1 = lwstop
510eAC                   endif
510eAC                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
510eAC                   eval      psstp2 = lwstop
510eAC                   endif
510eA*
510eA*       Will entire qty fit on current pallet?
510eA*
510eA*       Yes, Put on pallet and move on.
510eA*
510eAC                   if        lwqalc <= avlpcs
510eAC                   add       lwqalc        pspcs
510eAC                   add       lwcube        pscube
510eAC                   add       lwswgt        psswgt
510iMC                   eval      lwpal# = psplid
510eAC                   eval      lwstat = 'B'
510eAC                   eval      lwsdte = today
510eAC                   time                    lwstim
510eA
510eAC                   select
510eA
510eAC                   when      curByStopLocAsc
510eAC                   update    lwrec2
510eA
510eAC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
510eAC                   update    lwreca
510lAC                   endsl
510eA
510eAC                   when      curByStopOrdAsc
510eAC                   update    lwreco2
510eA
510eAC                   when      curByStopOrdDsc
510eAC                   update    lwrecoa
510eA
510eAC                   endsl
510eA
510iAC                   leave
510eAC                   endif
510iA
510iA*
510iA*       Nope, calculate quantity that can fit on current pallet.
510iA*
510iAC                   eval      maxqty = avlpcs
510iA*
510iA*       Put quantity on pallet.
510iA*
510iAC     maxqty        mult      lwucub        tmpcub
510iAC     maxqty        mult      lwuwgt        tmpwgt
510iAC                   add       maxqty        pspcs
510iAC                   add       tmpcub        pscube
510iAC                   add       tmpwgt        psswgt
510iA*
510iA*       Adjust current label record with qty put on pallet.
510iA*
510iAC                   eval      lwqalc = maxqty
510iAC                   eval      lwcube = tmpcub
510iAC                   eval      lwswgt = tmpwgt
510iAC                   eval      lwpal# = psplid
510iAC                   eval      lwstat = 'B'
510iAC                   eval      lwsdte = today
510iAC                   time                    lwstim
510iA
510iAC                   select
510iA
510iAC                   when      curByStopLocAsc
510iAC                   update    lwrec2
510iA
510iAC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
510iAC                   update    lwreca
510lAC                   endsl
510iA
510iAC                   when      curByStopOrdAsc
510iAC                   update    lwreco2
510iA
510iAC                   when      curByStopOrdDsc
510iAC                   update    lwrecoa
510iA
510iAC                   endsl
510iA*
510iA*       Create new label record with remaining quantity.
510iA*
510iAC                   if        svqalc > maxqty
510iAC                   eval      lwqalc = svqalc - maxqty
510iAC     lwqalc        mult      lwucub        lwcube
510iAC     lwqalc        mult      lwuwgt        lwswgt
510iAC                   eval      lwpal# = 0
510iAC                   eval      lwstat = svstat
510iAC                   eval      lwsdte = svsdte
510iAC                   eval      lwstim = svstim
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
510iA
510iAC                   select
510iA
510iAC                   when      curByStopLocAsc
510iAC                   write     lwrec2
510iA
510iAC                   when      curByStopLocDsc
510iAC                   write     lwreca
510iA
510iAC                   when      curByStopOrdAsc
510iAC                   write     lwreco2
510iA
510iAC                   when      curByStopOrdDsc
510iAC                   write     lwrecoa
510iA
510iAC                   endsl
510eA
510iMC                   endif
510eA
510iAC                   leave
510iMC                   enddo
510eA
510eAC                   endsr

510eA*----------------------------------------------------------------
510eA*  BLDFULLTOTE  Build full tote
510eA*
510eAC     bldfulltote   begsr
510iA
510iA*  Start off with an empty tote.
510iA*  If current tote isn't empty, save info for later.
510iA
510iAC                   if        pspcs = 0
510iAC                   eval      curpartialtote = 0
510iA
510iAC                   else
510iAC                   eval      curpartialtote = psplid
510iAC                   eval      xscomp = pscomp
510iAC                   eval      xstzon = pstzon
510iAC                   eval      xsgen  = psgen
510iAC                   eval      xsszon = psszon
510iAC                   eval      xstype = pstype
510iAC                   eval      xsunld = psunld
510iAC                   eval      xsrow  = psrow
510iAC                   eval      xscol  = pscol
510iA
510iAC                   eval      ToteFlag = *On
510iAC                   exsr      getplt
510iA
510iAC                   endif
510iA
510eA
510eA*       Set max qty.
510eA
510eAC                   eval      maxqty = curPcsPerTote
510eA*
510eA*       Put quantity on pallet.
510eA*
510eAC     maxqty        mult      lwucub        tmpcub
510eAC     maxqty        mult      lwuwgt        tmpwgt
510eAC                   add       maxqty        pspcs
510eAC                   add       tmpcub        pscube
510eAC                   add       tmpwgt        psswgt
510eA*
510eA*       Adjust current label record with qty put on pallet.
510eA*
510eAC                   eval      lwqalc = maxqty
510eAC                   eval      lwcube = tmpcub
510eAC                   eval      lwswgt = tmpwgt
510eAC                   eval      lwpal# = psplid
510eAC                   eval      lwstat = 'B'
510eAC                   eval      lwsdte = today
510eAC                   time                    lwstim
510eA
510eAC                   select
510eA
510eAC                   when      curByStopLocAsc
510eAC                   update    lwrec2
510eA
510eAC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
510lAC                   update    lwrecad
510lAC                   eval      updrecad = *off
510lAC                   other
510eAC                   update    lwreca
510lAC                   endsl
510eA
510eAC                   when      curByStopOrdAsc
510eAC                   update    lwreco2
510eA
510eAC                   when      curByStopOrdDsc
510eAC                   update    lwrecoa
510eA
510eAC                   endsl
510eA*
510eA*       Create new label record with remaining quantity.
510eA*
510eAC                   if        svqalc > maxqty
510eAC                   eval      lwqalc = svqalc - maxqty
510eAC     lwqalc        mult      lwucub        lwcube
510eAC     lwqalc        mult      lwuwgt        lwswgt
510eAC                   eval      lwpal# = 0
510eAC                   eval      lwstat = svstat
510eAC                   eval      lwsdte = svsdte
510eAC                   eval      lwstim = svstim
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
510eA
510eAC                   select
510eA
510eAC                   when      curByStopLocAsc
510eAC                   write     lwrec2
510eA
510eAC                   when      curByStopLocDsc
510eAC                   write     lwreca
510eA
510eAC                   when      curByStopOrdAsc
510eAC                   write     lwreco2
510eA
510eAC                   when      curByStopOrdDsc
510eAC                   write     lwrecoa
510eA
510eAC                   endsl
510eA
510eAC                   endif
510eA*
510eA*       Compare stop against min/max stop for pallet.
510eA*         PSSTP2 is not used for a separate pallet pick.
510eA*
510eAC                   if        psstp1 = 0  or
510eAC                             lwstop < psstp1
510eAC                   eval      psstp1 = lwstop
510eAC                   endif
510eAC                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
510eAC                   eval      psstp2 = lwstop
510eAC                   endif
510iA
510iA*    Either retrieve partial tote or start new one.
510iA
510iAC                   if        curpartialtote > 0
510iAC                   update    psrec1
510iAC     keypsx        chain     pltsum1
510iA
510iAC                   else
510iA
510iAC                   eval      ToteFlag = *On
510iAC                   exsr      getplt
510iA
510iAC                   endif
510eA
510eAC                   endsr
     *----------------------------------------------------------------
     *
     *  BULK    Get bulk picks.
     *
     C     bulk          begsr
     *
     *   Save unload seq# of current pallet summary record.
     *
     C                   eval      svunld = psunld
412aAC                   eval      svrow = psrow
412aAC                   eval      svcol = pscol
     *
     *   Loop through bulk pick labels.
     *
     *     Note: When building by stop we position the pointer just
     *           after the last stop and then get all the bulk picks
     *           through the current stop.  This ensures that we don't
     *           miss any stops that don't have items on normal pallets.
     *
     C                   eval      kybtyp = 'B'
     C                   eval      blkflg = *off
500iDC**                 if        bldtyp = '*LOC'
500iDC**   keybk2        setll     worklbl2
500iDC**                 else
500iDC**                 eval      kystop = lststp
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   keybk1        setgt     worklbla
500iDC**                 other
500iDC**   keybk1        setgt     worklbl2
500iDC**                 endsl
500iDC**                 endif

500iMC                   select
500iA
500iAC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        setll     worklbd2
700fAC                   When      curDFPickordA
700fAC     keybk2        setll     worklbd9
700fAC                   Other
500iAC     keybk2        setll     worklbl2
700fAC                   EndSl
500iA
500iAC                   when      curByStopLocAsc
500iAC                   eval      kystop = lststp

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setgt     worklbd2
700fAC                   When      curDFPickordA
700fAC     keybk1        setgt     worklbd9
700fAC                   Other
510aMC     keybk1        setgt     worklbl2
510aDC*    keybk1        setll     worklbl2
700fAC                   EndSl
500iA
500iAC                   when      curByStopLocDsc
500iAC                   eval      kystop = lststp
510lAC                   select
510lAC                   when      curBySlotDesc

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setgt     worklbd3
700fAC                   When      curDFPickordA
700fAC     keybk1        setgt     worklbd10
700fAC                   Other
510lAC     keybk1        setgt     worklblad
700fAC                   EndSl

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setgt     worklbd4
700fAC                   When      curDFPickordA
700fAC     keybk1        setgt     worklbd11
700fAC                   Other
510aMC     keybk1        setgt     worklbla
700fAC                   EndSl
510lAC                   endsl

510aDC*    keybk1        setll     worklbla
500iA
500iMC                   when      curByStopOrdAsc
500iAC                   eval      kystop = lststp

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setgt     worklbd5
700fAC                   When      curDFPickordA
700fAC     keybk1        setgt     worklbd12
700fAC                   Other
510aMC     keybk1        setgt     worklbo2
700fAC                   EndSl
510aDC*    keybk1        setll     worklbo2
500iA
500iMC                   when      curByStopOrdDsc
500iAC                   eval      kystop = lststp

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1        setgt     worklbd6
700fAC                   When      curDFPickordA
700fAC     keybk1        setgt     worklbd13
700fAC                   Other
510aMC     keybk1        setgt     worklboa
700fAC                   EndSl
510aDC*    keybk1        setll     worklboa
520eA
520eAC                   when      curByGroup2
520eAC                   eval      kybgrp2 = lstgrp2
520eAC                   eval      kystop = lststp

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk1e       setgt     worklbd7
700fAC                   When      curDFPickordA
700fAC     keybk1e       setgt     worklbd14
700fAC                   Other
520eAC     keybk1e       setll     worklble
700fAC                   EndSl
500iA
500iMC                   endsl
     *
     C                   dow       forevr = forevr
     *
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**   keybk2        reade     worklbla                               78
500iDC**                 other
500iDC**   keybk2        reade     worklbl2                               78
500iDC**                 endsl

510lAC                   eval      updrecad = *off
500iMC                   select
500iA
500iAC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd2                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd9                               78
700fAC                   Other
500iAC     keybk2        reade     worklbl2                               78
700fAC                   EndSl
500iA
500iAC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd2                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd9                               78
700fAC                   Other
500iAC     keybk2        reade     worklbl2                               78
700fAC                   EndSl
500iA
500iAC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      curBySlotDesc

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd3                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd10                              78
700fAC                   Other
510lAC     keybk2        reade     worklblad                              78
700fAC                   EndSl
510lAC                   eval      updrecad = *on

510lAC                   other

700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd4                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd11                              78
700fAC                   Other
500iAC     keybk2        reade     worklbla                               78
700fAC                   EndSl
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd5                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd12                              78
700fAC                   Other
500iAC     keybk2        reade     worklbo2                               78
700fAC                   EndSl
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd6                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd13                              78
700fAC                   Other
500iAC     keybk2        reade     worklboa                               78
700fAC                   EndSl
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC     keybk2        ReadE     worklbd7                               78
700fAC                   When      curDFPickordA
700fAC     keybk2        ReadE     worklbd14                              78
700fAC                   Other
520eAC     keybk2        reade     worklble                               78
700fAC                   EndSl
500iA
500iMC                   endsl
     *
     C                   if        *in78  or
500iDC**                           bldtyp = '*STOP'  and
500iMC                             curByStopAsc and
500iMC                             lwstop > svstop or
500iDC**                           oppbld <> '3'  or
417bA*
500iDC**                           bldtyp = '*STOP'  and
500iMC                             curByStopDesc and
417bAC                             lwstop < svstop
500iDC**                           oppbld = '3'
     C                   leave
     C                   endif
     *
     *     Only look at type 'B' records.
     *
     C                   if        lwtype <> 'B'
     C                   iter
     C                   endif
     *
     C                   eval      blkflg = *on
     *
     *     Need a new pallet for bulk picks.
     *
410 D*R         PSCUBE    IFGT 0
410 MC                   if        pspcs > 0
     C                   exsr      getplt
     C                   endif
     *
     *     Create special bulk pick record.
     *
     C                   eval      xxpcs = pspcs
     C                   eval      xxcube = pscube
     C                   eval      xxswgt = psswgt
     C                   eval      xxlbl# = pslbl#
     C                   eval      xxplid = psplid
720kAC                   eval      xxgen  = psgen
720kAC                   eval      xxrow  = psrow
720kAC                   eval      xxcol  = pscol
     C                   eval      xxstp1 = psstp1
     C                   eval      xxstp2 = psstp2
     C                   eval      xxtype = pstype
     C                   eval      xxbcnt = psbcnt
     *
     *     Create special bulk pick record.
     *
720kA*     For TruckBuilder Enhanced,
720kA*       Bulk pick records will use gen 7 and be
720kA*       created similar to overflow.
720kA
720kAC                   if        tbEnhanced
720kA
720bA /free
720kA
720kA    pstype = 'B';
720kA    pspcs = lwqalc;
720kA    pscube = lwcube;
720kA    psswgt = lwswgt;
720kA    pslbl# = lwlbl#;
720kA    psstp1 = lwstop;
720kA
720kA    if lstrw7 = 0;
720kA      lstrw7 = 1;
720kA    endif;
720kA
720kA    if lstcl7 = 9;
720kA      lstrw7 += 1;
720kA      lstcl7 = 1;
720kA    else;
720kA      lstcl7 += 1;
720kA    endif;
720kA
720kA    psgen = 7;
720kA    psrow = lstrw7;
720kA    pscol = lstcl7;
720kA
720kA    dsplid = 0;
720kA    dsplgn = 7;
720kA    dsplrw = psrow;
720kA    dsplcl = pscol;
720kA    dsplsq = 0;
720kA    psplid = dsplid;
720kA
720kA /end-free
720kA
720kA
720kAC                   else
720kA
     C                   eval      pstype = 'B'
     C                   eval      dsplid = psplid
     C                   eval      dsplsq = 1
     C                   eval      psplid = dsplid
     C                   eval      pspcs = lwqalc
     C                   z-add     lwcube        pscube
     C                   eval      psswgt = lwswgt
     C                   eval      pslbl# = lwlbl#
     C                   eval      psstp1 = lwstop
720kA
720kAC                   endif
412 A*
412 A*      PSSTP2 is not used for a separate pallet pick.
412 A*
650bMC                   if        spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
412 AC                   endif
     C                   eval      psbcnt = 0
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC                   write     psrec2
417bAC                   other
     C                   write     psrec2
417bAC                   endsl
     *
     *     Update label record with pallet number.
     *
     C                   eval      lwpal# = psplid
     C                   eval      lwstat = 'B'
     C                   eval      lwsdte = today
     C                   time                    lwstim
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**                 update    lwreca
500iDC**                 other
500iDC**                 update    lwrec2
500iDC**                 endsl

500iAC                   select
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd9
700fAC                   Other
500iAC                   update    lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd9
700fAC                   Other
500iAC                   update    lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
510lAC                   select
510lAC                   when      updrecad
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd3
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd10
700fAC                   Other
510lAC                   update    lwrecad
700fAC                   EndSL
510lAC                   eval      updrecad = *off

510lAC                   other
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd4
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd11
700fAC                   Other
500iAC                   update    lwreca
700fAC                   EndSL
510lAC                   endsl
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd5
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd12
700fAC                   Other
500iAC                   update    lwreco2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd6
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd13
700fAC                   Other
500iAC                   update    lwrecoa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Update    lwrecd7
700fAC                   When      curDFPickordA
700fAC                   Update    lwrecd14
700fAC                   Other
520eAC                   update    lwrece
700fAC                   EndSL
500iA
500iMC                   endsl
500iA
720jA*     For TruckBuilder Enhanced, skip creating Merge record
720kA*     Decided to go back to original Bulk pick logic
720jA
720kDC**                 if        not tbEnhanced
720jA
     *
     *     Create merge label for bulk pick.
     *
     *       The zone will be set to '*BULK*'.
     *       Put zone into LWWHDP and LWSTYP fields and clear
     *       other slot fields. This will allow us to summarize
     *       merge records by zone.
     *
     C                   eval      lwwhdp = '*BULK'
     C                   eval      lwstyp = '*'
     C                   eval      lwaisl = *blanks
     C                   eval      lwloc = 0
     C                   eval      lwpseq = 0
     C                   eval      lwrlvl = 0
     C                   eval      lwhand = *blanks
     C                   eval      lwtype = 'M'
720kDC**                 eval      dsplsq = 0
720kDC**                 eval      lwpal# = dsplid
720kMC                   eval      lwpal# = xxplid
     C                   eval      lwctr# = lwlbl#
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
500iDC**                 select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iDC**                 write     lwreca
500iDC**                 other
500iDC**                 write     lwrec2
500iDC**                 endsl

500iAC                   select
500iA
500iMC                   when      curByLocation
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd9
700fAC                   Other
500iAC                   write     lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd2
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd9
700fAC                   Other
500iAC                   write     lwrec2
700fAC                   EndSL
500iA
500iMC                   when      curByStopLocDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd4
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd11
700fAC                   Other
500iAC                   write     lwreca
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdAsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd5
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd12
700fAC                   Other
500iAC                   write     lwreco2
700fAC                   EndSL
500iA
500iMC                   when      curByStopOrdDsc
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd6
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd13
700fAC                   Other
500iAC                   write     lwrecoa
700fAC                   EndSL
520eA
520eAC                   when      curByGroup2
700fAC                   Select
700fAC                   When      curDFPickordB
700fAC                   Write     lwrecd7
700fAC                   When      curDFPickordA
700fAC                   Write     lwrecd14
700fAC                   Other
520eAC                   write     lwrece
700fAC                   EndSL
500iA
500iMC                   endsl
500iA
720jA*     End of merge skip For TruckBuilder Enhanced
720jA
720kDC**                 endif
720jA
     *
     *     Update totals on current pallet.
412 A*        PSSTP2 is not used for a separate pallet pick.
     *
     C                   eval      pstype = xxtype
     C                   eval      psplid = xxplid
720kAC                   eval      psgen = xxgen
720kAC                   eval      psrow = xxrow
720kAC                   eval      pscol = xxcol
     C     xxpcs         add       lwqalc        pspcs
     C     xxcube        add       lwcube        pscube
     C     xxswgt        add       lwswgt        psswgt
     C                   eval      pslbl# = xxlbl#
     C                   eval      psstp1 = xxstp1
     C                   eval      psstp2 = xxstp2
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif
     C     xxbcnt        add       1             psbcnt
     *
     C                   enddo
     *
     *   Update current pallet and then get original pallet.
     *
     C                   if        blkflg = *on
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500pMC                   when      curByStopDesc and zwgen = 1
417bAC                   update    psrec5
417bAC                   other
     C                   update    psrec1
417bAC                   endsl
     C                   eval      postn2 = *on
     C                   eval      kyunld = svunld
412aAC                   eval      kyrow = svrow
412aAC                   eval      kycol = svcol
     C                   exsr      getplt
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
412 A*  CHKSP   Check for separate pallet pick for stop.
     *
     C     chksp         begsr

720iDC**                 if        spflag = *on
650bAC                   eval      work2 = work2a
650bAC                   exsr      getstop
650bAC                   eval      $phstpa = $phstp
650bAC                   eval      work2 = work2b
650bAC                   exsr      getstop
650bAC                   eval      $phstpb = $phstp
720iDC**                 endif

720iAC                   if        $phstpa = 0
720iAC                   eval      $phstpa = work2a
720iAC                   endif
720iAC                   if        $phstpb = 0
720iAC                   eval      $phstpb = work2b
720iAC                   endif

     *
     *   If last stop was a separate pallet stop . . .
     *     Then get a new pallet before proceeding.
     *
650bAC                   if        spflag = *on
650bAC                             and pspcs > 0
650bAC                   if        $phstpa <> $phstpb
650bAC                   exsr      getplt
650bAC                   endif
650bAC                   endif

650bMC                   if        dpflag = *on  and
417aMC                             pspcs > 0
417aMC                   exsr      getplt
417aMC                   endif
     *
     *   If we are not building by location or not at generation 1
     *     Then set the flag off and skip to the bottom.
     *
500iDC**                 if        bldtyp <> '*STOP'  or
510jD ***                if        curByStop or
510jMC                   if        not curByStop or
     C                             svgen <> 1
750 A **  If preventSplitSP and we want to force cube on pallet with beyond
750 A **  max cube then continue to determine if single pallet
750 Ac                   if        preventSplitSP and forceonpallet
750 Ac                   else
650bMC                   eval      dpflag = *off
     C                   goto      endsp
750 Ac                   endif
     C                   endif
CBI A*
CBI A*     Cheney - If current compartment isn't D, F, or R skip to the bottom.
CBI AC                   if        client = cheney  and
CBI AC                             zwcomp <> 'D'  and
CBI AC                             zwcomp <> 'F'  and
CBI AC                             zwcomp <> 'R'
CBIcAC                             and clientloc <> cbiocl
CBIcAC*
CBIcAC*     Or current compartment isn't D, F, R or 1 skip to the bottom.
CBIcAC                             or  client = Cheney
CBIcAC                             and clientloc = Cbiocl
CBIcAC                             and zwcomp <> 'D'
CBIcAC                             and zwcomp <> 'F'
CBIcAC                             and zwcomp <> 'R'
CBIcAC                             and zwcomp <> '1'
CBIcAC                             and zwcomp <> '2'
CBIcAC*
CBIcAC                   eval      spflag = '0'
CBI AC                   goto      endsp
CBI AC                   endif
510nA*
510nA*   If zone does not honor separate pallet stop . . .
510nA*     Then set the flag off and skip to the bottom.
510oA*   Actual option wording is ...
510oA*     "Prevent single pallet *SP picks"
510nA*
510oDC**                 if        opstop = 'N'
510oMC                   if        opstop = 'Y'
650bMC                   eval      dpflag = *off
650bMC                   eval      dpflag2 = *off
720mAC                   eval      spflag = *off
720mAC                   eval      spflag2 = *off
510nAC                   goto      endsp
510nAC                   endif
     *
650bD ***                eval      dum6 = lwtzon
650bD ***                eval      dum6 = lwpzon
650bD ***                eval      dum6 = lwszon
650bD ***                move      lwstop        dum6
     *
     *   Get order header and check for separate flag.
     *
640aAC                   select
640aAC                   when      client = nicholas
640aAC                   exsr      getordh
640aAC                   other
650bD ***  keyoh         chain     ordh                               79
650bD ***                if        *in79
650bD*R                   MOVE *OFF      SPFLAG
650bD ***                eval      spflag = *off
650bD ***                else
650bD ***  '*SP'         scan      ohmisc                                 50
650bD ***                if        *in50
650bD ***                eval      spflag = *on
650bD ***                else
650bD ***                eval      spflag = *off
650bD ***                endif
650bD ***                endif

650bA /free
        chain(n) (lwwhse: lword) ordh;
        if not %found;
          spflag = *off;
          dpflag = *off;
        else;

        spflag = *off;
        dpflag = *off;
        if %scan ('*DP' : ohmisc) > 0;
          dpflag = *on;
        endif;
        if %scan ('*SP' : ohmisc) > 0
CDI A      or client = cdi
           and (lwszon = 'ZCART');
          spflag = *on;
          dpflag = *off;
        endif;
        endif;

740aA   // if single pallet flag not found in ohmisc
740aA   // look in customer to see if flagged
740aA   monitor;
740aA    if spflag <> *on;
740aA      exWhse = ohwhse;
740aA      excustmast ('*GET': exRtnCode: exRtnMsg: exWhse: ohcust:
740aA                  cmaaudflg: cmaaudexpd: cmspflg);
740aA      if exRtnCode = '*OK';
740aA        if cmSpFlg = 'Y';
740aA          spflag=*on;
740aA        endif;
740aA      endif;
740aA    endif;
740aA   on-error;
740aA   endmon;
      /end-free

640aAC                   endsl
     *
     *   If stop is a separate pallet stop . . .
     *     Then get a new pallet before proceeding.
     *
640aAC                   select
640aAC                   when      client = nicholas
640aAC                             and spflag2 = *on
640aAC                             and lwszon <> nchmsc_pkzn
650bMC                   eval      dpflag = *off
640aAC                   other
650bMC                   if        dpflag = *on  and
     C                             pspcs > 0
     C                   exsr      getplt
     C                   eval      spflag = *on
     C                   endif
650bAC                   if        spflag = *on
650bAC                             and pspcs > 0
650bAC                   if        $phstpa <> $phstpb
650bAC                   exsr      getplt
650bMC                   eval      spflag = *on
650bAC                   endif
650bAC                   endif
640aAC                   endsl
     *
     C     endsp         endsr
     *----------------------------------------------------------------
     *
412aA*  CNTSTP  Count stops on a pallet.
     *
412aAC     cntstp        begsr
     *
     *        Loop through label records for pallet.
     *
     C                   eval      stpcnt = 0
     C                   eval      first = *on
     C     keylw6        setll     worklbl6
     C                   dow       forevr = forevr
720aMC     keylw6        reade(n)  worklbl6                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *          See if we should ignore label.
     *
     C                   if        pstype = 'O'  and
     C                             lwtype <> 'O'  and
     C                             lwtype <> 'M'  or
     C                             pstype = 'B'  and
     C                             lwtype <> 'B'
     C                   iter
     C                   endif
     *
     *          First time through initialization.
     *
     C                   if        first = *on
     C                   eval      first = *off
510pDC*                  eval      lststp = lwstop
510pMC                   eval      lststp2 = lwstop
     C                   eval      stpcnt = 1
     C                   endif
     *
     *          Increment count when stop changes.
     *
510pDC*                  if        lwstop <> lststp
510pMC                   if        lwstop <> lststp2
     C                   add       1             stpcnt
510pDC*                  eval      lststp = lwstop
510pMC                   eval      lststp2 = lwstop
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTPLT  Create new pallet.
     *
     *    Note: When picking first generation zones a "Row" of pallets
     *          must be created.
     *
720aA*    For DD2 Overflow pallets are created like Gen 2 pallets. (future)
720aA*    For DD2, we only create 1 overflow pallet at a time.
     *
     C     crtplt        begsr
     *
     *      Add new row.
     *
     C                   clear                   psrec2
     C                   eval      pswhse = $pwhse
     C                   eval      psrtid = $prtid
     C                   eval      pstruk = $ptruk
     C                   eval      pstzon = zwtzon
     C                   eval      pspzon = zwpzon
     C                   eval      psszon = zwszon
     C                   eval      pscomp = zwcomp
     C                   eval      psgen = zwgen

720cA*  Get column to use

500kAC                   if        zwgen = 1

720jMC                   if        tbEnhanced
720cAC                   eval      lstcl6 += 1
720cAC                   if        lstcl6 > 9
720cAC                   eval      lstcl6 = 1
720cAC                   endif
720cAC                   eval      pscol = lstcl6
720cA
720cAC                   else
720cA
500kAC                   eval      pscol = 1
720cAC                   endif

500kAC                   else

500kAC                   eval      lstcl2 = lstcl2 + 1
500kAC                   if        lstcl2 > 9
500kAC                   eval      lstcl2 = 1
500kAC                   endif
500kAC                   eval      pscol = lstcl2

500kAC                   endif

720cA*  Get row to use

     C                   if        zwgen = 1

720jMC                   if        tbEnhanced
500kAC                   if        lstcl6 > 1
720cAC                   eval      psrow = lstrow
720cAC                   else
720cAC                   eval      lstrow += 1
720cAC                   eval      psrow = lstrow
720cAC                   endif
720cA
720cAC                   else
720cA
     C     lstrow        add       1             psrow
     C                   add       1             lstrow
720cAC                   endif

     C                   else

500kAC                   if        lstcl2 > 1
500kAC                   eval      psrow = lstrw2
500kAC                   else
     C     lstrw2        add       1             psrow
     C                   add       1             lstrw2
500kAC                   endif

     C                   endif

720cA*  Done getting row/col

500iMC                   eval      psmaxc = curMaxPltCube
520aAC*  do not start over at 71 for each zone.
     C                   if        zwgen = 1
412aAC                   if        lstunl < 71
520aAC                   eval      psunld = nxt71
412aAC                   else
412aMC     lstunl        add       1             psunld
412aAC                   endif
520aAC*  protect against unload seq# from going over 98.
520aAC                   if        psunld = 99
520aAC                   eval      nxt71 =97
520aAC                   eval      psunld = 97
520aAC                   endif
412aAC                   eval      lstunl = psunld
520aAC                   if        lstunl >= 71
520aAC                   eval      nxt71 = lstunl + 1
520aAC                   endif
     C                   else
500pMC                   eval      psunld = 0
     C                   endif
417cA*
417cA*    Pallets are being sequenced using the Load sequence.
417cAC                   if        opplsq = '2'  and
417cAC                             psunld <= t$pick  and
417cAC                             zwgen = 1
417cAC                   eval      pspal# = t$pick - psunld
417cAC                   add       1             pspal#
417cA*    Pallets are being sequenced using the Default UnLoad sequence.
417cAC                   else
     C                   eval      pspal# = psunld
417cAC                   endif
500pA
500pA*    Child pallets are always sequenced sequentially.
500pA
500pAC                   if        zwgen > 1
500pMC                   eval      lstul2 = lstul2 + 1
500pAC                   eval      pspal# = lstul2
500pAC                   endif
500pA
     C                   eval      pstype = 'O'
     C                   eval      psbcnt = 0
     C                   eval      psflag = *on
     C                   eval      pspcs = 0
     C                   eval      pscube = 0
     C                   eval      psswgt = 0
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     *
     C                   eval      dsplsq = 0
     C                   eval      dsplcl = pscol
     C                   eval      dsplrw = psrow
     C                   eval      dsplgn = psgen
     C                   eval      dsplxx = 0
     C                   eval      psplid = dsplid
     *
     C                   write     psrec2
500oAC                   eval      zonePltCnt = zonePltCnt + 1
     *
     *      Reposition to record just added.
     *
     C                   eval      kyunld = psunld
412aAC                   eval      kyrow = psrow
412aAC                   eval      kycol = pscol
     C                   eval      postn2 = *on
     *
     *      Add second column record if 1st generation.
720cA*      For TruckBulder Enhanced, we only create 1 overflow pallet at a time.
     *
720cDC**                 if        zwgen = 1
720jMC                   if        zwgen = 1 and not tbEnhanced
     C                   add       1             pscol
412aMC                   add       1             psunld
412aAC                   eval      lstunl = psunld
520aAC                   if        lstunl >= 71
520aAC                   eval      nxt71 = lstunl + 1
520aAC                   endif
     C                   eval      pstype = 'O'
417cA*
417cA*    Pallets are being sequenced using the Load sequence.
417cAC                   if        opplsq = '2'  and
417cAC                             psunld <= t$pick
417cAC                   eval      pspal# = t$pick - psunld
417cAC                   add       1             pspal#
417cA*    Pallets are being sequenced using the Default UnLoad sequence.
417cAC                   else
     C                   eval      pspal# = psunld
417cAC                   endif
     *
     C                   eval      dsplcl = pscol
     C                   eval      psplid = dsplid
     *
     C                   write     psrec2
500oAC                   eval      zonePltCnt = zonePltCnt + 1
     C                   endif
     *
     C                   endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  DUPLINES  When user splits same item and sequence across
740bA*            multiple pallets and then rebuilds OR620 is putting
740bA*            those multiple lines back in one position.  When
740bA*            the user then drags the stop or pallet to another
740bA*            location the iSeries is combining the multiple lines
740bA*            into one label but DD1 is not.  This change is to prevent
740bA*            that issue
740bA*
740bAC     duplines      begsr
740bA /free
740bA       sqlstmt = 'select lwwhse,lwrte,lwpal#,lwitem, lwseq,' +
740bA                 'lword,lwdisp,lwctr#,lwasl2,' +
740bA                 'lwutyp,lwtype,count(*) from worklblg ' +
750eA                 'where lwwhse=' + %char($pWhse) + ' ' +
750eA                 'and lwrte=' + sq + %trim($pRtid) + sq + ' ' +
740bA                 'group by lwwhse,lwrte,lword,lwseq,lwpal#,' +
740bA                 'lwitem,lwtype,lwdisp,lwctr#,lwasl2,' +
740bA                 'lwutyp having count(*)>1';
740bA
740bA       exec sql PREPARE dups FROM :SqlStmt;
740bA       exec sql DECLARE dupl SCROLL CURSOR FOR dups;
740bA       exec sql OPEN dupl;
740bA
740bA       dow sqlstt = sqlSuccess;
740bA         exec sql fetch next from dupl into :wkrec;
740bA         if sqlstt <> sqlSuccess;
740bA           leave;
740bA         endif;
740bA         // if count exceeds 1 call process to combine
740bA         if ducnt > 1;
740bA           $lwhse=duwhse;
740bA           $lrte=durte;
740bA           $lpal#=dupal#;
740bA           ps162($lparm);
740bA         endif;
740bA       enddo;
740bA
740bA       exec sql CLOSE dupl;
740bAb/end-free
740bAC                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *
     C     getopt        begsr
     *
     C                   eval      kycode = '*PICK   '
     C     keyopz        chain     optionz                            79
     C                   if        *in79
750 Ac                   eval      oppisplt = 'N'
750 Ac                   eval      oppstuff = 'N'
     C                   eval      opfpal = 1
     C                   eval      opfcub = 64
720fAC                   eval      opfwgt = 0
412 D*R                   Z-ADD99        OPFSTP
412 MC                   eval      opfstp = 1
     C                   eval      oppbld = *on
500iAC                   eval      opford = 0
500eMC                   eval      opptyp = 'P'
500iAC                   eval      opftot = 1
500iAC                   eval      optecb = 0
500iAC                   eval      opticb = 0
500iAC                   eval      optstp = 0
500iAC                   eval      optord = 0
500iAC                   eval      optpcs = 0
520eAC                   eval      oppitm = 0
     C                   endif

750 Ac                   if        client<>adc and client<>kohl
750 Ac                   if        oppisplt = 'Y'
750 Ac                   eval      preventSplit = '1'
750 Ac                   else
750 Ac                   eval      preventSplit = '0'
750 Ac                   endif
750 Ac                   endif

750 Ac                   if        client<>adc and client<>kohl
750 Ac                   if        oppisplt = 'S' or oppisplt = 'Y'
750 Ac                   eval      preventSplitSP = '1'
750 Ac                   else
750 Ac                   eval      preventSplitSP = '0'
750 Ac                   endif
750 Ac                   endif

750 Ac                   if        client<>adc and client<>kohl
750 Ac                   if        oppstuff = 'Y'
750 Ac                   eval      forceonpallet = '1'
750 Ac                   else
750 Ac                   eval      forceonpallet = '0'
750 Ac                   endif
750 Ac                   endif

740 Ac                   monitor
740 Ac                   eval      opfwgt = opfwgt
740 Ac                   on-error
740 Ac                   eval      opfwgt = 0
740 Ac                   endmon
740 DC*                  if        opfwgtalpha = *blanks
740 DC*                  eval      opfwgt = 0
740 DC*                  endif

     *  Convert options to English.

500iAC                   eval      curMaxPltCube    = opfcub

720fAC                   select
CPCaAC                   when      client = cpc and opfwgt = 0
CPCaAC                   eval      curMaxPltWgt =  2576
YHAaAC                   when      client = yhata and opfwgt = 0
YHAaAC                   eval      curMaxPltWgt =  2744
720fAC                   other
720fAC                   eval      curMaxPltWgt = opfwgt
720fAC                   endsl

500iAC                   eval      curStopsPerPlt   = opfstp
500iAC                   eval      curOrdersPerPlt  = opford
500iAC                   eval      curTotesPerPlt   = opftot
500iAC                   eval      curStopsPerTote  = optstp
500iAC                   eval      curOrderPerTote  = optord
500iAC                   eval      curPcsPerTote    = optpcs
500iAC                   eval      curExtToteCube   = optecb
500iAC                   eval      curIntToteCube   = opticb

500iAC                   if        opptyp = 'T'
500iAC                   eval      curIsTote = *on
500iAC                   eval      curMaxPltCube    = curIntToteCube
500iAC                   eval      curOrdersPerPlt  = curOrderPerTote
500iAC                   else
500iAC                   eval      curIsTote = *off
500iAC                   endif

520eAC                   if        opptyp = 'B'
520eAC                   eval      curIsBatch = *on
520eAC                   eval      curItemsPerPlt   = oppitm
520eAC                   else
520eAC                   eval      curIsBatch  = *off
520eAC                   eval      curItemsPerPlt   = 0
750bAc                   if        opptyp = 'P'
750cAc                   monitor
750bAc                   eval      curItemsPerPlt   = oppitm
750cAc                   on-error
750cAc                   eval      curItemsPerPlt   = 0
750cAc                   endmon
750bAc*     If Max Items not set for an item we will force it to 26 to
750bAc*     ensure no pallet position can exceed virtual slots per the alphabet
750bAc                   monitor
750bAc                   eval      curItemsPerPlt = curItemsPerPlt
750bAc                   on-error
750bAc                   eval      curItemsPerPlt = 0
750bAc                   endmon
750bAc                   monitor
750bAc                   eval      opnbps = opnbps
750bAc                   on-error
750bAc                   eval      opnbps = 0
750bAc                   endmon
750bAc                   monitor
750bAc                   eval      opnrsc = opnrsc
750bAc                   on-error
750bAc                   eval      opnrsc = 0
750bAc                   endmon
750bAc                   if        curItemsPerPlt = 0 and
750bAc                             (opnbps>3 or opnrsc>3)
750bAc                   select
750bAc                   when      opnbps>3
750bAc                   monitor
750bAc                   eval      curItemsPerPlt = 26 * opnbps
750bAc                   on-error
750bAc                   eval      curItemsPerPlt = 0
750cAc                   endmon
750bAc                   when      opnrsc>3
750bAc                   monitor
750bAc                   eval      curItemsPerPlt = 26 * opnrsc
750bAc                   on-error
750bAc                   eval      curItemsPerPlt = 0
750bAc                   endmon
750bAc                   endsl
750bAc                   endif
750bAc                   endif
520eAC                   endif

620aAC                   if        opptyp = 'S'
620aAC                   eval      curIsPrePick = *on
620aAC                   eval      oppbld = '3'
620aAC                   else
620aAC                   eval      curIsPrePick = *off
620aAC                   endif

500iAC                   if        curIsTote and curPcsPerTote > 0
500iAC                   eval      curChkMaxPcs = *on
500iAC                   else
500iAC                   eval      curChkMaxPcs = *off
500iAC                   endif

500iAC                   if        opnwpl = 'Y'
500iAC                   eval      curNewPlt4Aisle = *on
500iAC                   else
500iAC                   eval      curNewPlt4Aisle = *off
500iAC                   endif

500iAC                   if        opbmrg = 'Y'
500iAC                   eval      curAllowMrgOnBk  = *on
500iAC                   else
500iAC                   eval      curAllowMrgOnBk  = *off
500iAC                   endif

500iAC                   eval      curAscend        = *off
500iAC                   eval      curDescend       = *off
500iAC                   eval      curByStop        = *off
500iAC                   eval      curByStopAsc     = *off
500iAC                   eval      curByStopDesc    = *off
500iAC                   eval      curByStopLocAsc  = *off
500iAC                   eval      curByStopLocDsc  = *off
500iAC                   eval      curByStopOrdAsc  = *off
500iAC                   eval      curByStopOrdDsc  = *off
500iAC                   eval      curByLocation    = *off
500iAC                   eval      curLimitOrders   = *off
HAR AC                   eval      HldCurLimitOrd   = *off
520eAC                   eval      curByGroup2      = *off

500iAC                   select
520eAC                   when      curIsBatch = *on
520eAC                   eval      curByGroup2   = *on
640bAC                   if        oppbld = '3'
640bAC                   eval      curDescend = *on
640bAC                   eval      curByStop = *on
640bAC                   eval      curByStopDesc = *on
640bAC                   endif
750bDC*                  if        curItemsPerPlt > 0
750bMC                   if        curItemsPerPlt > 0 and opptyp<>'P'
520eAC                   eval      curLimitItems = *on
520eAC                   endif
520eAC                   if        curOrdersPerPlt > 0
520eAC                   eval      curLimitOrders = *on
520eAC                   endif

500iAC                   when      oppbld = '1'
500iAC                   eval      curAscend = *on
500iAC                   eval      curByStop = *on
500iAC                   eval      curByStopAsc = *on
500iAC                   if        curOrdersPerPlt > 0
500iAC                   eval      curLimitOrders = *on
510dAC                   endif
510kD ***                if        curIsTote
510kD ***                          or curOrdersPerPlt > 0
510kAC                   if        curOrdersPerPlt > 0
500iAC                   eval      curByStopOrdAsc = *on
500iAC                   else
500iAC                   eval      curByStopLocAsc = *on
500iAC                   endif

500iAC                   when      oppbld = '2'
500iAC                   eval      curAscend = *on
500iAC                   eval      curByLocation = *on

500iAC                   when      oppbld = '3'
500iAC                   eval      curDescend = *on
500iAC                   eval      curByStop = *on
500iAC                   eval      curByStopDesc = *on
500iAC                   if        curOrdersPerPlt > 0
500iAC                   eval      curLimitOrders = *on
510dAC                   endif
510kD ***                if        curIsTote
510kD ***                          or curOrdersPerPlt > 0
510kAC                   if        curOrdersPerPlt > 0
500iAC                   eval      curByStopOrdDsc = *on
500iAC                   else
500iAC                   eval      curByStopLocDsc = *on
500iAC                   endif
500iAC                   endsl

HAR AC                   eval      HldCurLimitOrd = curLimitOrders

     C                   endsr
500iA*----------------------------------------------------------------
500iA*
500iA*  GETMRGOPT  Get picking options for merge zone.
500iA*
500iAC     getmrgopt     begsr
     *
     C                   eval      kycode = '*PICK   '
     C     keyopz        chain     optionz                            79
     C                   if        *in79
750 Ac                   eval      oppisplt='N'
750 Ac                   eval      oppstuff='N'
     C                   eval      optecb = 0
     C                   eval      opticb = 0
     C                   eval      optpcs = 0
     C                   endif

     *  Convert options to English.

500iAC                   eval      mrgIsTote = *off

500iAC                   if        opptyp = 'T'
500iAC                   eval      mrgIsTote = *on
500iAC                   endif

500iAC                   eval      mrgPcsPerTote  = optpcs
500iAC                   eval      mrgExtToteCube = optecb
500iAC                   eval      mrgIntToteCube = opticb

     C                   endsr

730fA*----------------------------------------------------------------
730fA*  GetNextLbl#    Get next label number
730fA*----------------------------------------------------------------
730fA
730fAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lwwhse) + ', '
                    + 'Rtid: ' + %trimr(lwrte) + ', '
                    + 'Ord: ' + %char(lword) + ', '
                    + 'Seq: ' + %char(lwseq) + ', '
                    + 'Itm: ' + %trimr(lwitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  GETORDH    Get order header record.
640aA*
640aAC     getordh       begsr

650bMC                   eval      dpflag2 = *off
640aAC     keyoh         chain     ordh
640aAC                   if        not %found(ordh)
640aAC                   eval      nchmsc_base = *blanks
650bMC                   eval      dpflag = *off
640aAC                   else
640aAC                   eval      nchmsc_base = ohmisc

640aAC                   Select
650bMC                   when      nchmsc_Sngplt = '*DP'
650bMC                             and nchmsc_Pkzn = *blanks
650bMC                   eval      dpflag = *on

650bMC                   when      nchmsc_Sngplt = '*DP'
640aAC                             and nchmsc_Pkzn <> *blanks
640aAC     keyzw2        setll     pltsum3
640aAC                   dou       %eof(pltsum3)
640aAC     keyzw2        reade     pltsum3
640aAC                   if        not %eof(pltsum3)
640aAC                   if        nchmsc_Pkzn = xpsszon
650bMC                   eval      dpflag2 = *on
640aAC                   leave
640aAC                   endif
640aAC                   endif
640aAC                   enddo
650bMC                   eval      dpflag = *on

640aAC                   other
650bMC                   eval      dpflag = *off
640aAC                   endsl
640aAC                   endif

640aAC                   endsr
     *----------------------------------------------------------------
     *
     *  GETPLT  Get pallet.
     *
     C     getplt        begsr
750dAc*
750dAc*  Reset values that limit number of items per pallet
750dAc*
750dAc                   eval      wkPltItmCnt = 1
750dAc                   eval      wkPltNxtPos = 16
750dAc                   eval      wkPltItmStr = lwitem
750dAC
412bAC                   movel     wlds          wlsav
     C                   dow       forevr = forevr
     *
     *   Either position to first pallet or update current pallet.
     *
     C                   if        postn2 = *on
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500pDC**                 when      curByStopDesc and
500pDC**                           zwgen > 1
500pDC**   keyps         setgt     pltsum5
500hA*
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500iMC                   when      curByStopDesc and
500pAC                             zwgen = 1 and
417bAC                             kyunld < 71
417bAC     keyps         setll     pltsum5
417bA*
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500iMC                   when      curByStopDesc and
500pAC                             zwgen = 1 and
417bAC                             kyunld >= 71
417bAC     keyps         setgt     pltsum5
417bA*
417bAC                   other
     C     keyps         setll     pltsum1
417bAC                   endsl
     C                   eval      postn2 = *off
500pA
     C                   else
500pA
417bAC                   select
500iDC**                 when      lspbld = '3'  and
500iDC**                           lsbltp = '*STOP'
500pMC                   when      lstByStopDesc and zwgen = 1
417bAC                   update    psrec5
417bAC                   other
     C                   update    psrec1
417bAC                   endsl
     C                   endif
     *
     *   Get next pallet.
     *
417bAC                   select
510iA
510iAC                   when      ToteFlag
510iAC                   eval      ToteFlag = *off
510iAC                   exsr      crtplt
510iAC                   iter
510iA
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500pDC**                 when      curByStopDesc and
500pDC**                           zwgen > 1
500iDC**                 eval      lsbltp = bldtyp
500iDC**                 eval      lspbld = oppbld
500pDC**                 eval      lstByStopDesc = curByStopDesc
500pDC**   keyps1        readpe    pltsum5                                78
500hA*
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500iMC                   when      curByStopDesc and
500pAC                             zwgen = 1 and
417bAC                             kyunld < 71
500iDC**                 eval      lsbltp = bldtyp
500iDC**                 eval      lspbld = oppbld
500iAC                   eval      lstByStopDesc = curByStopDesc
417bAC     keyps1        reade     pltsum5                                78
417bA*
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'  and
500iMC                   when      curByStopDesc and
500pAC                             zwgen = 1 and
417bAC                             kyunld >= 71
500iDC**                 eval      lsbltp = bldtyp
500iDC**                 eval      lspbld = oppbld
500iAC                   eval      lstByStopDesc = curByStopDesc
417bAC     keyps1        readpe    pltsum5                                78
417bA*
417bAC                   other
500iDC**                 eval      lsbltp = bldtyp
500iDC**                 eval      lspbld = oppbld
500iAC                   eval      lstByStopDesc = curByStopDesc
     C     keyps1        reade     pltsum1                                78
417bAC                   endsl
     *
     *     If one doesn't exist, create it then loop around and get it.
     *
     C                   if        *in78
     C                   exsr      crtplt
     C                   iter
     C                   endif
     *
     *   If bulk pick pallet, see if we are allowed to add to it.
     *
     C                   if        psbcnt > 0  and
500iMC                             not curAllowMrgOnBk
500iDC**                           opbmrg <> 'Y'
     C                   iter
     C                   endif
413 A*
413 A*   If max cube is zero, skip this pallet.
413 A*
413 AC                   if        psmaxc = 0
413 AC                   iter
413 AC                   endif
     *
     *   Breakout and use pallet.
     *
     C                   leave
     C                   enddo
411 AC                   eval      stpcnt = 0
412aAC                   exsr      cntstp
417eD*R                   MOVE *OFF      SPFLAG
     *
720eA*  If maximum zone cube is less than pltsum (truck) cube
720eA*    then use maximum zone cube.
720eA*
720eAc                   if        curMaxPltCube < psmaxc
720eAC                   eval      psmaxc = curMaxPltCube
720eAC                   endif
     *
412bAC                   movel     wlsav         wlds
     C                   endsr
     *----------------------------------------------------------------
     *
650bA*  GetStop    Get stop number
     *
     C     GetStop       begsr

     C                   call      @getstop
     C                   parm      '*PLTSTP'     $lcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      *zeros        $pordr
     C                   parm                    work2
     C                   parm                    $phstp
     c                   parm                    $pDdrop           3
     c                   parm                    $pDextd          30
     c                   parm                    $pDsd             9

650bAC                   endsr
     *----------------------------------------------------------------
     *
     *  INIT    Initialize pallet summary from truck file.
     *
     C     init          begsr
510lA*
510lA*  Manually set slot build order until option is added to OPTIONS.
510lA*
ISYaAC                   if        client=isupply
RYLaAC                             or client = royal
CSPaAC                             or client=coastl
GFCaAC                             or client=glazier
ASCaAC                             or client = agar
RFSaAC                             or client = rfs
KHLaAC                             or client = kohl
PFGaAC                             or client = pfg
PFCaAC                             or client = presto
ISYaAC                   eval      curBySlotDesc = *on
ISYaAC                   endif
510lAC******             eval      curBySlotDesc = *on
417cA*
417cA*  Retrieve General Picking Options record.
417cA*
417cAC                   eval      opwhse = $pwhse
417cAC                   eval      opcode = '*GENPICK'
417cAC     opskey        chain     options                            79
417cAC                   if        *in79
417cAC                   eval      opplsq = *on
417cAC                   endif
     *
     *  Delete existing pallet records.
     *
     C     keyps2        setll     pltsum2
     C                   dow       forevr = forevr
     C     keyps2        reade     pltsum2                                78
     C                   if        *in78
417bA*    No truck detail defined. Ininitialize unload seq.
417bAC                   if        t1 = *zeros
417bAC                   eval      psunld = *zeros
417bAC                   endif
     C                   leave
     C                   else
     C                   delete    psrec2
     C                   endif
     C                   enddo
     *
     *  Delete existing merge records.
     *
     C     keyps2        setll     worklbl2
     C                   dow       forevr = forevr
     C     keyps2        reade     worklbl2                               78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lwtype = 'M'
     C                   delete    lwrec2
     C                   else
     C                   eval      lwpal# = 0
     C                   eval      lwstat = 'A'
     C                   update    lwrec2
     C                   endif
     C                   enddo
     *
     *  Delete existing pallet stop summary records.
     *
     C     keyps2        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyps2        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   else
     C                   delete    pssrec
     C                   endif
     C                   enddo
CWD A*
CWD A*      Clear Tote Orders DS.
CWD AC                   if        client = Cashwa
CWD AC                   clear     *all          toteorders
CWD A*
CWD A*  Delete existing pallet stop summary records.
CWD A*
CWD AC     keyps2        setll     totehdr
CWD AC                   dow       forevr = forevr
CWD AC     keyps2        reade     totehdr
CWD AC                   if        %eof(totehdr)
CWD AC                   leave
CWD AC                   else
CWD AC                   delete    tohrec
CWD AC                   endif
CWD AC                   enddo
CWD A*
CWD AC                   endif
     *
     *  Create initial pallet records from truck pallets.
     *
     C                   eval      lstrow = 0
     C                   eval      lstunl = 0
     C     keytd         setll     truckd
     C                   dow       forevr = forevr
     C     keytd         reade     truckd                                 78
     C                   if        *in78
     C                   leave
     C                   endif
414 D**         KEYZH1    CHAINZONEH1               77
414 AC     keyzh1        setll     zoneh1
414 AC     keyzh1        reade     zoneh1                                 77
     C                   if        *in77
     C                   eval      zhzone = *blanks
     C                   endif
     C                   eval      pswhse = $pwhse
     C                   eval      psrtid = $prtid
     *
     C                   eval      dsplsq = 0
     C                   eval      dsplcl = tdcol
     C                   eval      dsplrw = tdrow
     C                   if        tdrow > lstrow
     C                   eval      lstrow = tdrow
     C                   endif
     C                   eval      dsplgn = 1
     C                   eval      dsplxx = 0
     C                   eval      psplid = dsplid
     *
     C                   eval      pstruk = tdtruk
     C                   eval      pstzon = zhzone
     C                   eval      pspzon = *blanks
     C                   eval      psszon = zhzone
     C                   eval      pscomp = tdcomp
     C                   eval      psgen = 1
     C                   eval      psrow = tdrow
     C                   eval      pscol = tdcol
     C                   eval      psmaxc = tdcube
     C                   eval      psunld = tdpick
     C                   eval      pspal# = psunld
     C                   eval      pstype = 'O'
     C                   eval      psbcnt = 0
     C                   eval      psflag = *off
     C                   eval      pspcs = 0
     C                   eval      pscube = 0
     C                   eval      psswgt = 0
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     C                   eval      pslbl# = 0
     C                   write     psrec2
417bA*
417bA*    Build table with maximum pallet positions for each
417bA*    compartment on truck.
417bAC     1             do        100           t2
417bAC     t2            occur     tkcomp
417bAC                   select
417bA*
417bA*    New compartment, load values then exit loop.
417bAC                   when      t$comp = *blanks  and
417bAC                             tdcomp > *blanks
417bAC                   eval      t$comp = tdcomp
417bAC                   eval      t$pick = tdpick
417bAC                   add       1             t1
417bAC                   leave
417bA*
417bA*    Existing compartment, load values then exit loop.
417bAC                   when      t$comp > *blanks  and
417bAC                             tdcomp = t$comp
417bAC                   if        tdpick > t$pick
417bAC                   eval      t$pick = tdpick
417bAC                   endif
417bAC                   leave
417bAC                   endsl
417bAC                   enddo
417bA*
     C                   enddo
417cA*
417cA*    Pallets are being sequenced using the Load sequence.
417cA*
417cAC                   if        opplsq = '2'
650aAC                   eval      loadseq = 0
417cAC     keyps2        setll     pltsum2
417cAC                   dow       forevr = forevr
417cAC     keyps2        reade     pltsum2                                79
417cAC                   select
417cAC                   when      *in79
417cA*    Release record lock before leaving.
417cAC                   unlock    pltsum2
417cAC                   leave
417cA*
417cAC                   when      psgen = 1  and
417cAC                             pstype = 'O'
417cA*
650aAC                   select
CBIdAC                   when      client = Cheney
CBIdAC                             and (clientloc = CheneyOcala
CBIdAC                              or  clientloc = CheneyRiviera
CBIeAC                              or  clientloc = CBITIF
CBIdAC                              or  clientloc = CBIMLK)
650aA*
417cA*    Retrieve maximum pallet positions for compartment.
417cAC     1             do        t1            t2
417cAC     t2            occur     tkcomp
417cAC                   select
CBIeMC                   when      pscomp = t$comp  and
CBIeMC                             psgen = 1
CBIeMC*                  when      psgen = 1
417cA*    Pallets are being sequenced using the Load sequence.
417cAC                   if        opplsq = '2'  and
417cAC                             psunld <= t$pick
417cAC                   eval      pspal# = t$pick - psunld
417cAC                   add       1             pspal#
417cAC                   update    psrec2
417cAC                   endif
417cAC                   leave
417cA*
417cAC                   endsl
417cAC                   enddo
650aA*
650aAC                   other
650aA*      Set Load Sequence sequentially from front to back of truck.
650aAC                   eval      LoadSeq = LoadSeq + 1
650aAC                   eval      pspal#  = LoadSeq
650aAC                   update    psrec2
650aA*
650aAC                   endsl
417cA*
417cAC                   endsl
417cAC                   enddo
417cAC                   endif
417cA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  MERGE   Merge children for a stop onto pallet.
     *
     *    Note: When a label record is merged onto a pallet a new label
     *          record is created with the following differences:
750 A*
750 A*      ** This routine is called when merging a MERGE pallet onto
750 A*         a truck pallet, not when building the merge pallet
750 A*
     *
     *            - The type will be 'M'
     *            - The parent zone will be the parent's parent zone.
     *            - The LWWHDP and LWSTYP will contain the child's slot
     *              zone and the other slot fields will be cleared.
     *            - The quantity will differ when item is split across
     *              pallets.
     *            - The pallet number will be parent's pallet number.
     *            - The corresponding transaction number will be the
     *              child's label number.
     *
     C     merge         begsr
500gAC                   eval      mrgTotewgt = 0
500gAC                   eval      mrgTotepcs = 0
500gAC                   eval      mrgToteszon = ' '
500gAC                   eval      mrgTotestp1 = 0
500gAC                   eval      mrgTotestp2 = 0
500mAC                   eval      mrgToteOrd  = 0
500mAC                   eval      mrgToteSeq  = 0
500gAC                   eval      lastpal# = 0
     *
     *   Loop through children labels.
     *
     *     Note: When building by stop we position the pointer just
     *           after the last stop and then get all the children
     *           that have a stop greater than the last stop and less
     *           than or equal to the current stop.  This ensures that
     *           we don't miss any stops that don't have items on
     *           normal pallets.
     *
411 AC                   eval      mrgstp = lststp
     *
     C                   eval      kypzon = zwszon
500iDC**                 if        bldtyp = '*LOC'
500iMC                   if        curByLocation
     C     keymg2        setll     worklbl4
     C                   else
     C                   eval      kystop = lststp
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
500bD*R         KEYMG1    SETLLWORKLBLC
760 Ac                   if        kystop=99
760 AC     keymg1        setll     worklblc
760 Ac                   else
417bAC     keymg1        setgt     worklblc
760 Ac                   endif
417bAC                   other
760 Ac                   if        kystop=99
760 Ac     keymg1        setll     worklbl4
760 Ac                   else
     C     keymg1        setgt     worklbl4
760 Ac                   endif
417bAC                   endsl
     C                   endif
     *
     C                   dow       forevr = forevr
     *
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC     keymg2        reade     worklblc                               78
417bAC                   other
     C     keymg2        reade     worklbl4                               78
417bAC                   endsl
     *
500iDC**                 if        *in78  or
500iDC**                           bldtyp = '*STOP'  and
500iDC**                           lwstop > svstop  and
500iDC**                           oppbld <> '3'  or
500iD*
500iDC**                           bldtyp = '*STOP'  and
500iDC**                           lwstop < svstop and
500iDC**                           oppbld = '3'
500iDC**                 leave
500iDC**                 endif

500iMC                   if        *in78  or
500iMC                             curByStopAsc and
500iMC                             lwstop > svstop  or
500iM*
500iMC                             curByStopDesc and
500iMC                             lwstop < svstop
500iMC                   leave
500iMC                   endif
CBIaA*
CBIaA*     Cheney custom mod:
CBIaA*       Only want to get FLRPIR Cases ...
CBIaA*       (It is assumed the parent of FLRPIR isn't PKDRY)
CBIaA*
CBIaAC                   if        client = Cheney
CBIaAC                   if        lwszon = 'FLRPIR'  and
CBIaAC                             lwutyp <> 'N'
CBIaAC                   iter
CBIaAC                   endif
CBIaAC                   endif
404 D*
404 D*     Only look at type 'O' record.
404 D*
404 D*          LWTYPE    IFNE 'O'
404 D*                    ITER
404 D*                    ENDIF
     *
404 A*
404 A*     Use type 'O' and 'M' records.  Ignore everyone else.
404 A*
404 AC                   select
404 A*
404 A*       Type 'O' - SZON stays the same.
404 A*
404 AC                   when      lwtype = 'O'
404 AC                   eval      szone = zwszon
404 A*
404 A*       Type 'M' - SZON becomes the PZON of the label
404 A*                  record's SZON.
404 A*
404 AC                   when      lwtype = 'M'
404 A*
404 AC                   eval      z2whse = zwwhse
404 AC                   eval      z2rtid = zwrtid
404 AC                   eval      z2comp = zwcomp
404 AC                   eval      z2tzon = zwtzon
404 AC                   eval      z2pzon = zwpzon
404 AC                   eval      z2szon = zwszon
404 AC                   eval      z2gen = zwgen
404 AC                   eval      z2truk = zwtruk
404 A*
404 AC     keyzw1        chain     workzon1                           78
404 AC                   if        *in78
404 AC                   eval      szone = z2szon
404 AC                   else
404 AC                   eval      szone = zwpzon
404 AC                   endif
404 A*
404 AC                   eval      zwwhse = z2whse
404 AC                   eval      zwrtid = z2rtid
404 AC                   eval      zwcomp = z2comp
404 AC                   eval      zwtzon = z2tzon
404 AC                   eval      zwpzon = z2pzon
404 AC                   eval      zwszon = z2szon
404 AC                   eval      zwgen = z2gen
404 AC                   eval      zwtruk = z2truk
404 A*
404 A*       Ignore all other types.
404 A*
404 AC                   other
404 AC                   iter
404 AC                   endsl
500gA*
500gA*     If pallet changes and last pallet was for a Tote,
500gA*     Then create merge record for Tote.
500gA*
500gAC                   if        lwpal# <> lastpal#
500gAC                   if        mrgTotepcs > 0
500gAC                   exsr      mergetote
500gAC                   endif
500gAC                   eval      mrgTotelbl# = lwlbl#
500gAC                   eval      mrgTotepcs = 0
500gAC                   eval      mrgTotewgt = 0
500gAC                   eval      mrgToteszon = ' '
500gAC                   eval      mrgTotestp1 = 0
500gAC                   eval      mrgTotestp2 = 0
500mAC                   eval      mrgToteOrd  = 0
500mAC                   eval      mrgToteSeq  = 0
500gAC                   eval      lastpal# = lwpal#
500gAC                   endif
500cA*
500cA*     On first pass save zone data.  Check label zone for Tote Flag.
500cA*     Restore saved zone data.
500cA*
500gAC                   if        lwszon <> lstszn
500gAC                   move      lwszon        lstszn
500iDC**                 eval      tote = *off
500iDC**                 eval      opzdt1 = opzdta
500iDC**                 eval      savchkpcs = chkpcs
500cAC                   eval      kyzone = lwszon
500iDC**                 exsr      getopt
500iMC                   exsr      getmrgopt
500iDC**                 if        opptyp = 'T'
500iDC**                 eval      tote = *on
500iDC**                 eval      totecube = optcub
500iDC**                 endif
500iDC**                 eval      opzdta = opzdt1
500iDC**                 eval      chkpcs = savchkpcs
500gAC                   endif
     *
     *     Put zone into LWWHDP and LWSTYP fields and clear
     *     other slot fields. This will allow us to summarize
     *     merge records by zone.
     *
     C                   movel     lwszon        lwwhdp
     C                   move      lwszon        lwstyp
     C                   eval      lwaisl = *blanks
     C                   eval      lwloc = 0
     C                   eval      lwpseq = 0
     C                   eval      lwrlvl = 0
     C                   eval      lwhand = *blanks
750bA*
750bA*       Get new pallet when number of Items exceeds option setting
750bA*
750bA /free
750bA                    if curItemsPerPlt > 1;
750bA                      if maxPltItems(lwitem);
750bA                        exsr getplt;
750bA                      endif;
750bA                    endif;
750bA /end-free
411 A*
411 A*     Start new pallet if we exceed max stops per pallet.
411 A*
411 AC                   if        lwstop <> mrgstp
720iAC                   eval      work2a = mrgstp
720iAC                   eval      work2b = lwstop
411 AC                   eval      mrgstp = lwstop
411 AC                   exsr      chksp
500iDC**                 if        stpcnt >= opfstp
500iMC                   if        stpcnt >= curStopsPerPlt
411 AC                   exsr      getplt
411 AC                   endif
411 AC                   add       1             stpcnt
411 AC                   endif
500gA*
500gA*     If Tote, update pieces and weight. Then get next record.
500gA*
500iDC**                 if        tote = *on
500iMC                   if        mrgIsTote
500gAC                   eval      mrgTotepcs = lwqalc
500gAC                   eval      mrgTotewgt = lwswgt
500gAC                   eval      mrgToteszon = lwszon
500mAC                   eval      mrgToteOrd  = lword
500mAC                   eval      mrgToteSeq  = lwseq
500gAC                   if        mrgTotestp1 = 0  or
500gAC                             lwstop < mrgTotestp1
500gAC                   eval      mrgTotestp1 = lwstop
500gAC                   endif
500gAC                   if        lwstop > mrgTotestp2
500gAC                   eval      mrgTotestp2 = lwstop
500gAC                   endif
500gAC                   iter
500gAC                   endif
730dA
730dA*      Get corresponding UM record
730dA
730dA /free
730dA  umFlexPickFlag = '';
730dA  preventSplitFP = *off;
730dA  umWhse = lwwhse;
730dA  monitor;
730dA    umworklbl('*GET': umRtnCode: umRtnMsg:
730dA              umWhse: lwlbl#:
730dA              umFlexPickFlag);
730dA  on-error;
730dA  endmon;
730dA  if umFlexPickFlag <> '';
730dA    preventSplitFP = *on;
730dA  endif;
730dA /end-free
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
     C                   eval      lftqty = lwqalc
404 AC                   eval      svlbl# = lwlbl#
     C                   dow       lftqty > 0
     *
     *       Calculate cube available on pallet.
     *
     C                   eval      avlcub = psmaxc - pscube
720fA*
720fA*       Calculate weight available on pallet.
720fA*
720fMC                   if        curMaxPltWgt > 0
720fAC                   eval      avlwgt = curMaxPltWgt - psswgt
720fAC                   endif
     *
     *       Calculate cube qty left.
     *
     C     lftqty        mult      lwucub        lftcub
402 MC     lftqty        mult      lwuwgt        lftwgt
     *
     *       If one case doesn't fit then get new pallet.
     *
     C                   if        pscube > 0  and
417bMC                             avlcub < lwucub
     C                   exsr      getplt
     C                   iter
     C                   endif
720fA*
720fAC                   if        curMaxPltWgt > 0  and psswgt > 0
720faC                             and avlwgt < lwuwgt
720fAC                   exsr      getplt
720fAC                   iter
720fAC                   endif
720gA*
720gA*       If option set to not split order detail line
720gA*       and entire qty won't fit on pallet, Then start a new pallet
720gA*
720gAC                   if        preventSplit and pspcs > 0
720hAC                             or preventSplitSP and spflag=*on and pspcs>0
730dAC                             or preventSplitFP and pspcs>0
720gAC                   if        lwcube > avlcub or
720gAC                             (curMaxPltWgt > 0 and lwswgt > avlwgt)
720gAC                   exsr      getplt
720gAC                   iter
720gAC                   endif
720gAC                   endif
     *
     *       Compare stop against min/max stop for pallet.
412 A*           PSSTP2 is not used for a separate pallet pick.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif
     *
     *       Will entire qty fit on current pallet?
     *
     *          Yes, Put on pallet and create pallet merge label.
     *
720fDC**                 if        lftcub <= avlcub
720fAC                   if        (curMaxPltWgt = 0 and lftcub <= avlcub)
720fAC                             or (curMaxPltWgt > 0 and lftcub <= avlcub
720fAC                                 and lftwgt <= avlwgt)
720gAC                             or preventSplit
720hAC                             or (preventSplitSP and spflag=*on)
730dAC                             or preventSplitFP
     C                   add       lftqty        pspcs
     C                   add       lftcub        pscube
     C                   add       lftwgt        psswgt
     *
     C                   eval      lwtype = 'M'
     C                   eval      lwpzon = zwpzon
404 AC                   eval      lwszon = szone
     C                   eval      lwpal# = psplid
404 AC                   eval      lwctr# = svlbl#
404 D**                   Z-ADDLWLBL#    LWCTR#
     C                   eval      lwqalc = lftqty
     C                   eval      lwcube = lftcub
     C                   eval      lwswgt = lftwgt
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC                   write     lwreca
417bAC                   other
     C                   write     lwrec2
417bAC                   endsl
     C                   leave
     C                   endif
     *
     *       Nope, calculate quantity that can fit on current pallet.
     *
     C     avlcub        div       lwucub        maxqty
750 Ac                   if        (preventSplit and pspcs=0 and forceonpallet)
750 Ac                             or (preventSplitSP and pspcs=0 and
750 Ac                                 forceonpallet and spflag=*on)
750 AC     lwcube        div       lwucub        maxqty
750 Ac                   endif

720fAC                   if        curMaxPltWgt > 0
730bAC                             and lwuwgt > 0
720fAC                   eval      maxqtyByWgt = avlwgt / lwuwgt
720fAC                   if        maxqtyByWgt < maxqty
720fAC                   eval      maxqty = maxqtyByWgt
720fAC                   endif
720fAC                   endif
     *
     *       Protect against unit cube greater than max pallet cube.
     *
     C                   if        maxqty = 0
     C                   eval      maxqty = 1
     C                   endif
     *
     *       Put quantity on pallet and create pallet merge record.
     *
     C     maxqty        mult      lwucub        tmpcub
     C     maxqty        mult      lwuwgt        tmpwgt
     C                   add       maxqty        pspcs
     C                   add       tmpcub        pscube
     C                   add       tmpwgt        psswgt
     *
     C                   eval      lwtype = 'M'
     C                   eval      lwpzon = zwpzon
404 AC                   eval      lwszon = szone
     C                   eval      lwpal# = psplid
404 AC                   eval      lwctr# = svlbl#
404 D**                   Z-ADDLWLBL#    LWCTR#
404 D*                    Z-ADDLFTQTY    LWQALC
404 D*                    Z-ADDLFTCUB    LWCUBE
404 D*                    Z-ADDLFTWGT    LWSWGT
404 MC                   eval      lwqalc = maxqty
404 MC                   eval      lwcube = tmpcub
404 MC                   eval      lwswgt = tmpwgt
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC                   write     lwreca
417bAC                   other
     C                   write     lwrec2
417bAC                   endsl
     *
     C                   eval      lftqty = lftqty - maxqty
     *
     C                   enddo
     *
     C                   enddo
500cA*
500cA*     If last records we were working with were for a Tote,
500cA*     Then create Tote merge record.
500cA*
500cAC                   if        mrgTotepcs > 0
500cAC                   exsr      mergetote
500cAC                   endif
CBIaA*
CBIaA*    Cheney custom mod ...
CBIaA*      If getting items for PKDRY,
CBIaA*        Then see if there are any FLRPIR Eaches to get.
CBIaA*        (It is assumed the parent of FLRPIR isn't PKDRY)
CBIaA*
CBIaAC                   if        client = Cheney
CBIaAC                   if        kypzon = 'PKDRY'
CBIaAC                   exsr      mrgflr
CBIaAC                   endif
CBIaAC                   endif
     *
     C                   endsr
CBIaA*
CBIaA*----------------------------------------------------------------
CBIaA*
CBIaA*  MRGFLR  Special merge for FLRPIR zone
CBIaA*
CBIaA*    It is assumed that the parent of zone FLRPIR is DRY.
CBIaA*
CBIaA*    When the MERGE routine is getting the records for parent
CBIaA*    PKDRY, this routine will be called to get the Eaches from
CBIaA*    the FLRPIR zone.
CBIaA*
CBIaA*    This is basically a copy of the MERGE routine with the
CBIaA*    custom changes to set the parent zone to DRY and only
CBIaA*    grab FLRPIR Eaches.
CBIaA*
CBIaAC     mrgflr        begsr
     *
     *   Loop through children labels.
     *
     *     Note: When building by stop we position the pointer just
     *           after the last stop and then get all the children
     *           that have a stop greater than the last stop and less
     *           than or equal to the current stop.  This ensures that
     *           we don't miss any stops that don't have items on
     *           normal pallets.
     *
411 AC                   eval      mrgstp = lststp
     *
CBIaAC                   eval      svcomp = lwcomp
CBIaAC                   eval      svtzon = lwtzon
CBIaAC                   eval      kycomp = 'D'
CBIaAC                   eval      kytzon = 'DRY   '
CBIaAC                   eval      kypzon = 'DRY   '
     C                   if        bldtyp = '*LOC'
CBIaMC     flrmg2        setll     worklbl4
     C                   else
     C                   eval      kystop = lststp
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
760 Ac                   if        kystop=99
760 AC     flrmg1        setll     worklblc
760 Ac                   else
CBIaMC     flrmg1        setgt     worklblc
760 Ac                   endif
500bD*R         KEYMG1    SETLLWORKLBLC
417bAC                   other
760 Ac                   if        kystop=99
760 AC     flrmg1        setll     worklbl4
760 Ac                   else
CBIaMC     flrmg1        setgt     worklbl4
760 Ac                   endif
417bAC                   endsl
     C                   endif
     *
     C                   dow       forevr = forevr
     *
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
CBIaMC     flrmg2        reade     worklblc                               78
417bAC                   other
CBIaMC     flrmg2        reade     worklbl4                               78
417bAC                   endsl
     *
500iDC**                 if        *in78  or
500iDC**                           bldtyp = '*STOP'  and
500iDC**                           lwstop > svstop  and
500iDC**                           oppbld <> '3'  or
500iD*
500iDC**                           bldtyp = '*STOP'  and
500iDC**                           lwstop < svstop  and
500iDC**                           oppbld = '3'
500iDC**                 leave
500iDC**                 endif

500iMC                   if        *in78  or
500iMC                             curByStopAsc and
500iMC                             lwstop > svstop  or
500iM*
500iMC                             curByStopDesc and
500iMC                             lwstop < svstop
500iMC                   leave
500iMC                   endif
CBIaA*
CBIaA*     Cheney custom mod:
CBIaA*       Only want to get FLRPIR Eaches ...
CBIaA*
CBIaAC                   if        lwszon <> 'FLRPIR'  or
CBIaAC                             lwutyp <> '1'
CBIaAC                   iter
CBIaAC                   endif
404 D*
404 D*     Only look at type 'O' record.
404 D*
404 D*          LWTYPE    IFNE 'O'
404 D*                    ITER
404 D*                    ENDIF
     *
404 A*
404 A*     Use type 'O' and 'M' records.  Ignore everyone else.
404 A*
404 AC                   select
404 A*
404 A*       Type 'O' - SZON stays the same.
404 A*
404 AC                   when      lwtype = 'O'
404 AC                   eval      szone = zwszon
404 A*
404 A*       Type 'M' - SZON becomes the PZON of the label
404 A*                  record's SZON.
404 A*
404 AC                   when      lwtype = 'M'
404 A*
404 AC                   eval      z2whse = zwwhse
404 AC                   eval      z2rtid = zwrtid
404 AC                   eval      z2comp = zwcomp
404 AC                   eval      z2tzon = zwtzon
404 AC                   eval      z2pzon = zwpzon
404 AC                   eval      z2szon = zwszon
404 AC                   eval      z2gen = zwgen
404 AC                   eval      z2truk = zwtruk
404 A*
404 AC     keyzw1        chain     workzon1                           78
404 AC                   if        *in78
404 AC                   eval      szone = z2szon
404 AC                   else
404 AC                   eval      szone = zwpzon
404 AC                   endif
404 A*
404 AC                   eval      zwwhse = z2whse
404 AC                   eval      zwrtid = z2rtid
404 AC                   eval      zwcomp = z2comp
404 AC                   eval      zwtzon = z2tzon
404 AC                   eval      zwpzon = z2pzon
404 AC                   eval      zwszon = z2szon
404 AC                   eval      zwgen = z2gen
404 AC                   eval      zwtruk = z2truk
404 A*
404 A*       Ignore all other types.
404 A*
404 AC                   other
404 AC                   iter
404 AC                   endsl
     *
     *     Put zone into LWWHDP and LWSTYP fields and clear
     *     other slot fields. This will allow us to summarize
     *     merge records by zone.
     *
     C                   movel     lwszon        lwwhdp
     C                   move      lwszon        lwstyp
     C                   eval      lwaisl = *blanks
     C                   eval      lwloc = 0
     C                   eval      lwpseq = 0
     C                   eval      lwrlvl = 0
     C                   eval      lwhand = *blanks
411 A*
411 A*     Start new pallet if we exceed max stops per pallet.
411 A*
411 AC                   if        lwstop <> mrgstp
720iAC                   eval      work2a = mrgstp
720iAC                   eval      work2b = lwstop
411 AC                   eval      mrgstp = lwstop
411 AC                   exsr      chksp
500iDC**                 if        stpcnt >= opfstp
500iMC                   if        stpcnt >= curStopsPerPlt
411 AC                   exsr      getplt
411 AC                   endif
411 AC                   add       1             stpcnt
411 AC                   endif
411 A*
     *
     *     Put qty on existing pallet or new pallet.
     *     Don't hesitate to split item across pallets.
     *
     C                   eval      lftqty = lwqalc
404 AC                   eval      svlbl# = lwlbl#
     C                   dow       lftqty > 0
     *
     *       Calculate cube available on pallet.
     *
     C                   eval      avlcub = psmaxc - pscube
     *
     *       Calculate cube qty left.
     *
     C     lftqty        mult      lwucub        lftcub
402 D*          LFTQTY    MULT LWSWGT    LFTWGT
402 MC     lftqty        mult      lwuwgt        lftwgt
     *
     *       If one case doesn't fit then get new pallet.
     *
     C                   if        pscube > 0  and
417bD*R         AVLCUB    ANDLTLFTCUB
417bMC                             avlcub < lwucub
     C                   exsr      getplt
     C                   iter
     C                   endif
     *
     *       Compare stop against min/max stop for pallet.
412 A*           PSSTP2 is not used for a separate pallet pick.
     *
     C                   if        psstp1 = 0  or
     C                             lwstop < psstp1
     C                   eval      psstp1 = lwstop
     C                   endif
     C                   if        lwstop > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
     C                   eval      psstp2 = lwstop
     C                   endif
     *
     *       Will entire qty fit on current pallet?
     *
     *          Yes, Put on pallet and create pallet merge label.
     *
     C                   if        lftcub <= avlcub
     C                   add       lftqty        pspcs
     C                   add       lftcub        pscube
     C                   add       lftwgt        psswgt
     *
     C                   eval      lwtype = 'M'
CBIaAC                   eval      lwcomp = svcomp
CBIaAC                   eval      lwtzon = svtzon
     C                   eval      lwpzon = zwpzon
404 AC                   eval      lwszon = szone
     C                   eval      lwpal# = psplid
404 AC                   eval      lwctr# = svlbl#
404 D**                   Z-ADDLWLBL#    LWCTR#
     C                   eval      lwqalc = lftqty
     C                   eval      lwcube = lftcub
     C                   eval      lwswgt = lftwgt
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC                   write     lwreca
417bAC                   other
     C                   write     lwrec2
417bAC                   endsl
     C                   leave
     C                   endif
     *
     *       Nope, calculate quantity that can fit on current pallet.
     *
     C     avlcub        div       lwucub        maxqty
750 Ac                   if        (preventSplit and pspcs=0 and forceonpallet)
750 Ac                             or (preventSplitSP and pspcs=0 and
750 Ac                                 forceonpallet and spflag=*on)
750 AC     lwcube        div       lwucub        maxqty
750 Ac                   endif
     *
     *       Protect against unit cube greater than max pallet cube.
     *
     C                   if        maxqty = 0
     C                   eval      maxqty = 1
     C                   endif
     *
     *       Put quantity on pallet and create pallet merge record.
     *
     C     maxqty        mult      lwucub        tmpcub
     C     maxqty        mult      lwuwgt        tmpwgt
     C                   add       maxqty        pspcs
     C                   add       tmpcub        pscube
     C                   add       tmpwgt        psswgt
     *
     C                   eval      lwtype = 'M'
CBIaAC                   eval      lwcomp = svcomp
CBIaAC                   eval      lwtzon = svtzon
     C                   eval      lwpzon = zwpzon
404 AC                   eval      lwszon = szone
     C                   eval      lwpal# = psplid
404 AC                   eval      lwctr# = svlbl#
404 D**                   Z-ADDLWLBL#    LWCTR#
404 D*                    Z-ADDLFTQTY    LWQALC
404 D*                    Z-ADDLFTCUB    LWCUBE
404 D*                    Z-ADDLFTWGT    LWSWGT
404 MC                   eval      lwqalc = maxqty
404 MC                   eval      lwcube = tmpcub
404 MC                   eval      lwswgt = tmpwgt
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
417bAC                   select
500iDC**                 when      oppbld = '3'  and
500iDC**                           bldtyp = '*STOP'
500iMC                   when      curByStopDesc
417bAC                   write     lwreca
417bAC                   other
     C                   write     lwrec2
417bAC                   endsl
     *
     C                   eval      lftqty = lftqty - maxqty
     *
     C                   enddo
     *
     C                   enddo
     *
     *
     C                   endsr
CBIaA*
500cA*----------------------------------------------------------------
500cA*  MERGETOTE  Create Tote Merge Label Record
500cA*
500cAC     mergetote     begsr
500cA*
500cA*  Save current worklbl fields.
500cA*
500cAC                   eval      savelwwhse = lwwhse
500cAC                   eval      savelwpzon = lwpzon
500cAC                   eval      savelwszon = lwszon
500cAC                   eval      savelwitem = lwitem
500cAC                   eval      savelwwhdp = lwwhdp
500cAC                   eval      savelwaisl = lwaisl
500cAC                   eval      savelwloc  = lwloc
500cAC                   eval      savelwpseq = lwpseq
500cAC                   eval      savelwrlvl = lwrlvl
500cAC                   eval      savelwhand = lwhand
500cAC                   eval      savelwdisp = lwdisp
500jAC                   eval      savelwutyp = lwutyp
500jAC                   eval      savelwucod = lwucod
500cAC                   eval      savelwucub = lwucub
500cAC                   eval      savelwcube = lwcube
500cAC                   eval      savelwswgt = lwswgt
500cAC                   eval      savelwqalc = lwqalc
500cAC                   eval      savelwtype = lwtype
500cAC                   eval      savelwctr# = lwctr#
500cAC                   eval      savelwlbl# = lwlbl#
500cAC                   eval      savelwpal# = lwpal#
500cAC                   eval      savelwsdte = lwsdte
500cAC                   eval      savelwstim = lwstim
500jAC                   eval      savelwstop = lwstop
500mAC                   eval      savelword  = lword
500mAC                   eval      savelwseq  = lwseq
500cA*
500cA*  See if we need to get a new pallet.
500cA*
500cAC                   eval      avlcub = psmaxc - pscube
500jDC**                 if        mrgTotecube > avlcub
500jMC                   if        mrgExtToteCube > avlcub
500cAC                   exsr      getplt
500cAC                   endif
500cA*
500cA*  Update pallet totals.
500cA*
500cAC                   add       1             pspcs
500jDC**                 add       mrgTotecube   pscube
500jMC                   eval      pscube = pscube + mrgExtToteCube
500cAC                   add       mrgTotewgt    psswgt
500cA*
500cA*  Get pallet number of tote.
720jA*    For TruckBuilder Enhanced, we will still sent 'O' because
720jA*    we are building everything normally, then converting it to 'P'.
500cA*
500cAC                   call      'GETPALLET'
500cAC                   parm                    $pwhse
500cAC                   parm                    $prtid
500cAC                   parm      'O'           $gtype            1
500cAC                   parm                    lastpal#
500cAC                   parm                    $gpal#            7 0
500lAC                   parm                    $gtzon            6
500lAC                   parm                    $gpzon            6
500jAC                   parm                    $gszon            6
500lAC                   parm                    $gcomp            1
500lAC                   parm                    $ggen             1 0
500lAC                   parm                    $gtruk           10
500lAC                   parm                    $gunld            2 0
500lAC                   parm                    $grow             2 0
500lAC                   parm                    $gcol             1 0
500lAC                   parm                    $gstp1            2 0
500lAC                   parm                    $gstp2            2 0
500lAC                   parm                    $gpcs             5 0
500lAC                   parm                    $gcube            7 3
500lAC                   parm                    $gswgt            9 2
500lAC                   parm                    $gbcnt            1 0
500lAC                   parm                    $gflag            1
500lAC                   parm                    $glbl#            7 0
500lAC                   parm                    $gtrn#            7 0
500cAC                   parm                    $greturn          8
500cA*
500cA*  Create item number.
500cA*
500cAC                   if        $greturn <> '*OK'
500cAC                   eval      mrgToteitem = 'TOTE'
500cAC                   else

SWTaAC                   select
SWTaAC                   when      client = swt
500kMC                   eval      mrgToteitem = 'TOTE '
500cAC                                      + %trim(%editc($gpal#:'P'))
SWTaAC                   other
500kMC                   eval      mrgToteitem = 'TOTE '
500cAC                                      + %trim(%editc($gpal#:'P'))
500kMC                                      + ' '
500jAC                                      + %trim($gszon)
SWTaAC                   endsl

500cAC                   endif
500cA*
500cA*  Create Merge record.
500cA*
500cAC                   eval      lwwhse = $pwhse
500cAC                   eval      lwpzon = zwpzon
500cAC                   eval      lwszon = szone
500cAC                   eval      lwitem = mrgToteitem
500cAC                   movel     mrgToteszon   lwwhdp
500cAC                   move      mrgToteszon   lwstyp
500cAC                   eval      lwaisl = *blanks
500cAC                   eval      lwloc = 0
500cAC                   eval      lwpseq = 0
500cAC                   eval      lwrlvl = 0
500cAC                   eval      lwhand = *blanks
500cAC                   eval      lwdisp = *blanks
500jAC                   eval      lwstop = mrgToteStp1
500jAC                   eval      lwutyp = 'N'
500jAC                   eval      lwucod = 'TO'
500jDC**                 eval      lwucub = mrgTotecube
500jDC**                 eval      lwcube = mrgTotecube
500jMC                   eval      lwucub = mrgExtToteCube
500jMC                   eval      lwcube = mrgExtToteCube
500cAC                   eval      lwswgt = mrgTotewgt
500cAC                   eval      lwqalc = 1
500cAC                   eval      lwtype = 'M'
500cAC                   eval      lwctr# = mrgTotelbl#
500mAC                   eval      lword  = mrgToteOrd
500mAC                   eval      lwseq  = mrgToteSeq
730fDC**                 call      'PIRLBL#'
730fDC**                 parm                    lwlbl#
730fMC                   exsr      GetNextLbl#
730fMC                   eval      lwlbl# = nextLbl#
500cAC                   eval      lwpal# = psplid
500cAC                   eval      lwsdte = today
500cAC                   time                    lwstim
500cA*
500cAC                   select
500iMC                   when      curByStopDesc
500cAC                   write     lwreca
500cAC                   other
500cAC                   write     lwrec2
500cAC                   endsl
520bA*
520bA*  Create TOTEHDR record.
CWD AC                   select
CWD AC                   when      client = CashWa
CWD AC                   exsr      crttotehdr
CWD AC                   other
CWD A*
520bA*
520cA*  Do special processing for TOHWGT
     *
520cAC                   if        mrgTotewgt > 999.99
520cAC                   eval      tohwgt = 999.99
520cAC                   else
520cAC                   eval      tohwgt = mrgTotewgt
520cAC                   endif
     *
520bAC                   eval      tohwhs = $pwhse
520bAC                   eval      tohrid = $prtid
520bAC                   eval      tohppi = lastpal#
520bAC** 520cD           eval      tohnum = $gpal#
520cMC                   eval      tohcnt = $gpal#
520bAC                   eval      tohord = mrgToteOrd
520bAC                   eval      tohlay = 0
520bAC                   eval      tohsec = ' '
520bAC                   eval      tohecb = mrgExtToteCube
520bAC                   eval      tohicb = mrgIntToteCube
520bAC                   eval      tohmxp = mrgPcsPerTote
520bAC                   eval      tohcub = 0
520bAC                   eval      tohpcs = mrgTotepcs
520bAC**520cD            eval      tohwgt = mrgTotewgt
520bAC                   eval      tohlbl = mrgTotelbl#
520bAC                   eval      tohtr# = 0
520bAC                   eval      tohmpi = lwpal#
520bAC                   eval      tohml# = lwlbl#
520bAC                   eval      tohmt# = 0
520bAC                   write     tohrec
CWD A*
CWD AC                   endsl
500cA*
500cA*  Compare stop against min/max stop for pallet.
500cA*      PSSTP2 is not used for a separate pallet pick.
500cA*
500cAC                   if        psstp1 = 0  or
500cAC                             mrgTotestp1 < psstp1
500cAC                   eval      psstp1 = mrgTotestp1
500cAC                   endif
500cAC                   if        mrgTotestp2 > psstp2
650bMC                             and spflag = *off
650bMC                             and dpflag = *off
500cAC                   eval      psstp2 = mrgTotestp2
500cAC                   endif
500cA*
500cA*  Restore current worklbl fields.
500cA*
500cAC                   eval      lwwhse = savelwwhse
500cAC                   eval      lwpzon = savelwpzon
500cAC                   eval      lwszon = savelwszon
500cAC                   eval      lwitem = savelwitem
500cAC                   eval      lwwhdp = savelwwhdp
500cAC                   eval      lwaisl = savelwaisl
500cAC                   eval      lwloc  = savelwloc
500cAC                   eval      lwpseq = savelwpseq
500cAC                   eval      lwrlvl = savelwrlvl
500cAC                   eval      lwhand = savelwhand
500cAC                   eval      lwdisp = savelwdisp
500jAC                   eval      lwutyp = savelwutyp
500jAC                   eval      lwucod = savelwucod
500cAC                   eval      lwucub = savelwucub
500cAC                   eval      lwcube = savelwcube
500cAC                   eval      lwswgt = savelwswgt
500cAC                   eval      lwqalc = savelwqalc
500cAC                   eval      lwtype = savelwtype
500cAC                   eval      lwctr# = savelwctr#
500cAC                   eval      lwlbl# = savelwlbl#
500cAC                   eval      lwpal# = savelwpal#
500cAC                   eval      lwsdte = savelwsdte
500cAC                   eval      lwstim = savelwstim
500jAC                   eval      lwstop = savelwstop
500mAC                   eval      lword  = savelword
500mAC                   eval      lwseq  = savelwseq
500cA*
500cAC                   endsr
CWD A*
CWD A*----------------------------------------------------------------
CWD A*
CWD A*  CRTTOTEHDR  Create TOTEHDR Record.
CWD A*
CWD AC     crttotehdr    begsr
CWD A*
CWD A*      Retrieve Gen 2 Tote Pallet ID.
730eDC*    mrgToteLbl#   chain (n) worklbl
730eM /free
730eM      chain(n) ($pwhse: mrgToteLbl#) worklblw;
730eM /end-free
730eMC                   if        not %found(worklblw)
CWD AC                   eval      lwlwpal# = 0
CWD AC                   endif
CWD A*
CWD AC                   eval      t          = 1
CWD AC                   eval      toteordcnt = 0
CWD AC                   eval      svtoteordid = -9999999
CWD AC     keylw5        setll     worklbl5
CWD AC                   dow       forevr = forevr
CWD AC     keylw5        reade     worklbl5
CWD AC                   if        %eof(worklbl5)
CWD AC                   leave
CWD AC                   endif
CWD A*
CWD A*      Save label details into Tote DS.
CWD AC     1             do        100           t
CWD AC     t             occur     toteorders
CWD AC                   select
CWD AC                   when      toteordid = 0
CWD AC                   eval      toteordcnt = toteordcnt + 1
CWD AC                   eval      toteordid  = lw5lword
CWD AC                   eval      totepltid  = lw5lwpal#
CWD AC                   eval      totephylbl = lw5lwlbl#
CWD AC                   leave
CWD A*
CWD AC                   when      lw5lword <> toteordid
CWD AC                   iter
CWD A*
CWD AC                   when      lw5lword = toteordid
CWD AC                   leave
CWD A*
CWD AC                   endsl
CWD AC                   enddo
CWD AC                   eval      svtoteordid = lw5lword
CWD A*
CWD AC                   eval      totepcs  = totepcs + lw5lwqalc
CWD AC                   eval      totecube = totecube + lw5lwcube
CWD AC                   eval      totewgt  = totewgt + lw5lwswgt
CWD A*
CWD AC                   enddo
CWD A*
CWD A*  Do special processing for TOHWGT
CWD A*
CWD AC     1             do        toteordcnt    t
CWD AC     t             occur     toteorders
CWD AC                   if        totewgt > 999.99
CWD AC                   eval      tohwgt = 999.99
CWD AC                   else
CWD DC*                  eval      tohwgt = mrgTotewgt
CWD MC                   eval      tohwgt = totewgt
CWD AC                   endif
     *
520bAC                   eval      tohwhs = $pwhse
520bAC                   eval      tohrid = $prtid
700 DC*                  eval      tohppi = lastpal#
700 MC                   eval      tohppi = totepltid
520bAC** 520cD           eval      tohnum = $gpal#
520cMC                   eval      tohcnt = $gpal#
700 DC*                  eval      tohord = mrgToteOrd
700 MC                   eval      tohord = toteordid
520bAC                   eval      tohlay = 0
520bAC                   eval      tohsec = ' '
520bAC                   eval      tohecb = mrgExtToteCube
520bAC                   eval      tohicb = mrgIntToteCube
520bAC                   eval      tohmxp = mrgPcsPerTote
700 DC*                  eval      tohcub = 0
700 MC                   eval      tohcub = totecube
700 DC*                  eval      tohpcs = mrgTotepcs
700 MC                   eval      tohpcs = totepcs
520bAC**520cD            eval      tohwgt = mrgTotewgt
520bAC                   eval      tohlbl = totephylbl
520bAC                   eval      tohtr# = 0
520bAC                   eval      tohmpi = lwpal#
520bAC                   eval      tohml# = lwlbl#
520bAC                   eval      tohmt# = 0
520bAC                   write     tohrec
CWD A*
CWD A*      Clear current occurrence of tote info.
CWD AC                   clear                   toteorders
CWD A*
CWD AC                   enddo
CWD A*
CWD AC                   eval      toteordcnt = 0
CWD AC                   eval      svtoteordid = -9999999
CWD A*
CWD AC                   endsr
CWD A*
     *----------------------------------------------------------------
     *
     *  STPSUM  Create stop summary records for truck pallets.
     *
     C     stpsum        begsr
     *
     *  Create stop summary recs for normal truck pallets then bulk picks.
     *
402 D*                    Z-ADD1         KYGEN
402 AC     1             do        9             y
402 AC                   z-add     y             kygen
720cDC**   1             do        2             x
720cDC**                 if        x = 1
720cDC**                 eval      kytype = 'O'
720cDC**                 else
720cDC**                 eval      kytype = 'B'
720cDC**                 endif
720c
720cMC     1             do        3             x
720cA
720cAC                   eval      dd2Location = *off
720cA
720cMC                   select
720cA
720cMC                   when      x = 1
720cMC                   eval      kytype = 'O'
720jMC                   if        tbEnhanced and kygen = 1
720cAC                   eval      dd2Location = *on
720cAC                   endif
720cA
720cMC                   when      x = 2
720cMC                   eval      kytype = 'P'
720cA
720cMC                   when      x = 3
720cMC                   eval      kytype = 'B'
720cA
720cMC                   endsl
     *
     *     Loop through pallets for current type.
     *
     C     keyss         setll     pltsum2
     C                   dow       forevr = forevr
     C     keyss         reade     pltsum2                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *        Initialize stop summary fields with pallet info.
     *
     C                   eval      psswhs = pswhse
     C                   eval      pssrid = psrtid
     C                   eval      pssrow = psrow
     C                   eval      psscol = pscol
     C                   eval      psspli = psplid
     C                   eval      dsplid = psplid
     C                   eval      pssbsq = dsplsq

720cAC                   if        dd2Location
720aAC                   eval      dsplsq = 9
720cAC                   eval      locationMax = dsplid
720cAC                   endif
     *
     *        Loop through label records for pallet.
     *
     C                   eval      first = *on
     C                   eval      lblflg = *off
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C
     C     keylw6        setll     worklbl6
     C                   dow       forevr = forevr
720cAC                   if        dd2Location
720aMC     keyps2        reade(n)  worklbl6                               78
720cAC                   else
720aMC     keylw6        reade(n)  worklbl6                               78
720cAC                   endif
     C                   if        *in78
     C                   leave
     C                   endif

     *          If using DD2, get out after exhausting pallet location

720cAC                   if        dd2Location and lwpal# > locationMax
720cAC                   leave
720cAC                   endif
     *
     *          See if we should ignore label.
     *
     C                   if        kytype = 'O'  and
     C                             lwtype <> 'O'  and
     C                             lwtype <> 'M'  or
720cAC                             kytype = 'P'  and
720cAC                             lwtype <> 'O'  and
720cAC                             lwtype <> 'M'  or
     C                             kytype = 'B'  and
     C                             lwtype <> 'B'
     C                   iter
     C                   endif
     *
     *          First time through initialization.
     *
     C                   if        first = *on
     C                   eval      first = *off
     C                   eval      lststp = lwstop
     C                   endif
     *
     *          Create stop summary record when stop changes.
     *
     C                   if        lwstop <> lststp
     *
     C                   eval      pssstp = lststp
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   write     pssrec

     C                   eval      lststp = lwstop
     C                   eval      lblflg = *off
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   endif
     *
     *          Add label amounts to totals.
     *
     C                   eval      lblflg = *on
     C                   add       lwcube        ttlcub
     C                   add       lwswgt        ttlwgt
     C                   add       lwqalc        ttlpcs
     *
     C                   enddo
     *
     *       Create last stop summary record for pallet.
     *
     C                   if        lblflg = *on
     *
     C                   eval      pssstp = lststp
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   write     pssrec
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
402 AC                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  DD2PLTS    Create DD2 pallets
     *
     *    For DragDrop 2.0, 'O' pallets, ones where the pallet id
     *    ends with zero, are considered Location summary pallets.
     *    Actual pallets that are in a location are type 'B' or
     *    new type 'P' records. A type 'P' record is created by this
     *    routine and are similar to type 'B' records, where the
     *    pallet id ends with a number greater than zero, thus
     *    allowing up to 9 pallets in a single pallet location.
     *
     *    For now, we will let OR620 create the pallets the old way,
     *    then create the new records.
     *
720kA*    Reinstated original Bulk logic of creating a corresponding
720kA*    'M' label record. Therefore, a corresponding 'P' record will
720kA*    need to be created for each 'B' record.
     *
     *----------------------------------------------------------------
720aAC     dd2plts       begsr
      /FREE

       // Whip through the PLTSUM records for the route

       setll ($pwhse: $prtid: 'O': 1) pltsum2;

       dow forever = forever;

         reade ($pwhse: $prtid: 'O': 1) pltsum2;
         if %eof(pltsum2);
           leave;
         endif;

720kD    // Skip pallets that already contain a bulk pick.
720kA    // Bulk picks have been moved to gen 7

720kD    //if psbcnt > 0;
720kD    //  iter;
720kD    //endif;

         // Skip pallets that are empty

         if pspcs = 0;
           iter;
         endif;

         // Skip pallets that don't have a zero for last digit

         dsplid = psplid;
         if dsplsq > 0;
           iter;
         endif;

720eA    // Set location rec max cube to truck max cube
720eA
720eA    chain (pswhse: pstruk: psrow: pscol) truckd;
720eA    if %found(truckd);
720eA      psmaxc = tdcube;
720eA    endif;

         // Update Bulk Count of record
720kA    // This will always be 1 because psbcnt is now
720kA    // the number of pallets in a location and
720kA    // this program only creates 1 pallet per location

720kD    //psbcnt += 1;
720kM    psbcnt = 1;

         update psrec2;

720eA    // Set pallet rec max cube to zone max cube
720eA
720eA    kyzone = pstzon;
720ea    exsr getopt;
720eA    psmaxc = curMaxPltCube;

         // Create new pallet record.

         oldPlid = psplid;
         pstype = 'P';
         psplid += 1;
         //psbcnt = 0;
         write psrec2;

         // Create corresponding PLTSTP records for new pallet id

         setll (pswhse: psrtid: oldPlid) pltstp1;
         dow forever = forever;
           reade (pswhse: psrtid: oldPlid) pltstp1;
           if %eof(pltstp1);
             leave;
           endif;
           psspli = psplid;
           write pssrec;
         enddo;

         // Update corresponding WORKLBL records for pallet id

         setll (pswhse: psrtid: oldPlid) worklbl6;
         dow forever = forever;
           reade (pswhse: psrtid: oldPlid) worklbl6;
           if %eof(worklbl6);
             leave;
           endif;
           lwpal# = psplid;
           update lwrec6;
         enddo;

       enddo;

      /END-FREE
     C                   endsr
730fA*----------------------------------------------------------------
730fA*  wrtDebug    Write out debug record
730fA*----------------------------------------------------------------
730fA
730fA /free
730fA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
750bAC*----------------------------------------------------------------
750bAC*  maxPltIems - Return flag to start new pallet if max items
750bAC*               defined and exceeded
750bAC*----------------------------------------------------------------
750bA
750bAp maxPltITems     b
750bAd maxPltITems     pi              n
750bAd  iItem                        15
750bA
750bA * Local Variables
750bAd  rtnVal         s               n
750bA
750bA /free
750bA
750bA          rtnVal = *off;
750bA          if %scan(iItem:wkPltItmStr) = 0;
750bA            // this item has not been put on this pallet
750bA            // yet so we need to ensure this will not
750bA            // exceed the number of items per pallet
750bA            wkPltItmCnt = wkPltItmCnt + 1;
750bA            if wkPltItmCnt > curItemsPerPlt;
750bA              // work fields get reset in get pallet routine (getplt)
750bA              //wkPltItmCnt = 1;
750bA              //wkPltNxtPos = 16;
750bA              //wkPltItmStr = iItem;
750bA              rtnVal = *on;
750bA            else;
750bA              %subst(wkPltItmStr:wkPltNxtPos)
750bA                                   =iItem;
750bA              wkPltNxtPos = wkPltNxtPos + 15;
750bA            endif;
750bA          endif;
750bA
750bA          return rtnVal;
750bA
750bA /end-free
750bA
750bAp                 e
