      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR610     Truck build - Select orders
     *  12 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/12/97  DAS  4.00
     *      -  Major revisions for truck build process.  This program
     *         based on OR510.  Old revisions were removed to clean
     *         up program.
     *      - Initial revisions have not be marked with the version.
     *      - A new route id field is used to uniquely identify routes.
     *      - Options are now tied to zones, not departments.
     *        Therefore, file OPTIONS has been replaced with OPTIONZ.
     *        There are no override options anymore.
404  *    08/28/97  RH   4.04
     *      -  Revised to work with cross dock line item.  Cross dock items
     *         have an 'XD' in the ODSPCL field.  These items are picked but
     *         do not adjust the warehouse qty or any slot qty's.
409 A*    03/13/98 DAS/RH  4.09
     *      - Revised PICKF routine to check for expired pick slot date.
     *        If expired, item will be picked as if no pick slot existed.
409 A*    03/13/98 DAS/RH  4.09
     *      - Change to unalocate item qty after replenishment for
     *        broken case.
409 A*    03/12/98 DAS/RH 4.09
     *      - Revised ALLOC routine to repeat the call to REPLNS untile.
     *        the return qty doesn't change indicating that nothing
     *        was replenished.
410 A*    11/20/98 DAS/RH 4.10
     *      - Added file OPTIONS along with data structure.
     *      - Made revisions to create labels for exceptions (not
     *        enough stock) based on user option.
     *      - Correct LWUWGT and LWUWGT calculation using ITUMQ3.
410bA*    12/10/98 RH     4.10
     *      - Change to do PICK subroutines each time for either
     *        normal or exception quantities.
     *
411 A*    05/26/99  DAS  4.11
     *      - Revised to deal with new item types.
     *      - Revised GETOD routine to no longer 'up' quantities.
     *        From now on we pick what the customer ordered.
     *      - Revised REPLNS routine to only ignore PIR pick slots
     *        that are not reserved. It is ok for a Fixed pick
     *        slot to not be reserved.
     *      - Revised AVAIL routine to set available qtys to zero
     *        if they are negative.
     *
412 A*    08/17/99  DAS  4.12
     *      - Revised to work with fixed items with multiple
     *        pick slots.
     *
412aA*    08/23/99  DAS  4.12
     *      - Revised PICKF2 to move check for pick slot to step 1
     *        and then to bulk pick check because bulk pick needs
     *        to know the home slot.
     *
413aA*    09/27/99  MLB  4.13a
     *      - Revised to add tracking modifications to program.
     *        Added file PIRTRCK2 to pgm.
413bA*    09/28/99  MLB  4.13b
     *      - Revised the following routines to add ITFLGD = 'Y'
     *        test to all expiration dates tests; BULKPK,PICKMP,PICKP
     *        PICKRP,PICKS,REPLNS.
413cA*    11/10/99  MLB  4.13c
     *      - Revised *INZSR to initialize field TIME for exception
     *        report.
413dA*    12/29/99  DAS  4.13d
     *      - Revised GETOD routine to initialize #BITYP.
     *
413eA*    02/08/00  DAS  4.13e
     *      - Initialized LWLAS2 to blanks before calling POST.
     *        This was done before some calls but not all of them.
     *
413fA*    01/27/00  MLB  4.13e
     *      - Revised routine REPLNS to not check available qty and just
     *        create replenishment to first pick slot.
414aA*    03/31/00  MLB  4.14a
     *      - Revised the following routines to add Host pick Will Call
     *        support to program: ALLOC,PICKF,PICKF2,PICKMP,PICKP,PICKRP,
     *        PICKS and PRTERR.
     *      - Added new fields to *GENPICK data structure.
414bA*    06/02/00  RH/DAS 4.14b
     *      - In Step 2, use saved values to identify home slot for   st
     *        bulk pick.
414cA*    06/16/00  RH   4.14c
     *      - Add item description, can use extended description.
     *
415 A*    02/16/01  DAS  4.15
     *      - Added REPORTS override for OR610PR.
     *
415aA*    06/20/01  HNK/DAS 4.15
     *      - Program will execute routine CRTLBL and not allocate
     *        quantity if the flag UPDFLG is set to '*NOUPDATE' in
     *        the begining of the program. If a client needs to use
     *        truck builder without allocting product on BFC side,
     *        this program should be custom changed to set the UPDFLG
     *        to '*NOUPDATE'.
415bA*    06/28/01  RH/MLB  4.15b
     *      - Add call to DUPPRTCL to duplicate the spool file.
     *        Program defaults to NOT call DUPPRTCL.
415cA*    08/01/01  RH/DAS  4.15c
     *      - Only skip slot if expired date is old AND there is
     *        quantity in stock.
     *
416aA*    09/05/02  MLB  4.16a
     *      - Enh: Revised routine ALLOC to only call CVTQTY when
     *        allocation exception has occured.
     *
417 A*    07/03/03  MLB  4.17
     *      - Enh: Added new feature to program, Pick items without pick
     *        slot as bulk pick, (Y/N). If N=No, then items will be
     *        included with regular order selection.
417aA*    08/08/03  MLB  4.17a
     *      - Fix: Revised CRTLBL routine to correct field usage. LWVRFY
     *        was being incorrectly set. Should be LWQRYF field.
417bA*    07/28/04  DAS  4.17b
     *      - Fix: Revised to call GETSLOTITM instead of GETBASE.
     *        Re: The item being retrieved from GETBASE was being
     *            used to get the slot for the original item. However,
     *            if the original item was an Alias item for an SSB
     *            item, GETBASE would return the SSB item, which is
     *            not a slot item. Therefore no slot would be found
     *            for the original item.
417cA*    08/06/04  RH   4.17c
     *      - Fix: Revised to call GETBASE for type A alias items.
     *             Changed the parms used for GETSLOTITM to #S, GETBASE
     *             will use #B parms.                                 E
     *             Move qty to corresponding base breakdown qty for   E
     *             Alias items tied to a type 'S' same slot breakdown E
     *      - NOTE: Moved some of 417b code instead of commenting to
     *              make code cleaner.
417dA*    09/08/04  DAS  4.17d
     *      - Fix: Revised ALLOC to handle negative allocated qty.
417zA*    08/13/04  MLB  4.17z
     *      - Enh: Revised program to add support for new Client id
     *        modifications.
     *
500 A*    12/03/04  DAS  5.00
     *      - Enh: Revised 417z change to call GETCLIENT program.
500aA*    06/10/05  MLB  5.00a
     *      - Fix: Revised 417d change to correct field name used.
500bA*    07/08/05  MLB  5.00b
     *      - Enh: Added JIT Letdown/Replen option to program. This
     *        mod will only allow Letdowns to be created when OPJITR=L.
     *        If OPJITR is R or N then no replenishments are created
     *        at this time.
500cA*    10/05/05  MLB  5.00c
     *      - Enh: Added new JIT Letdown/Replen option to program. This
     *        mod will only allow Letdowns to be created when OPJITR=P.
500dA*    10/07/05  MLB  5.00d
     *      - Enh: Revised program to convert codes used for JIT
     *        Replenishments. Update *GENPICK options text. All
     *        previous 5.00 changes relating to OPJITR have been
     *        overwritten for clarity.
500eA*    05/25/06  DAS  5.00e
     *      - Enh: Revised POST routine to try and get a slot for
     *        an OUT item, even if all slots are expired.
510aA*    11/02/06  RH   5.10a
     *      - Enh: Add USF code from PIRSTD library.
     *
510bA*    02/22/07  DAS  5.10b
     *      - Revised to see if *NONE has been returned from GETPSLT.
     *        If so, clear slot fields.
     *
520aA*    09/15/08  DAS  5.20a
     *      - Revised key KEYDEF to use #SITEM instead of ODITEM.
     *      - Commented out some unecessary lines in BULKPK routine.
     *
520bA*    10/03/08  DAS  5.20b  P#00140
     *      - Revised to up qty before updating Whse/Slot qtys.
     *        Re: We were running into breakdown 1 ordered qtys
     *            that were greater than 999.
     *
520cA*    10/03/08  DAS  5.20c  P#00140
     *      - Revised PICKS to call PICK0 routine instead of calling
     *        routines PICK1/2/3.
     *
520dA*    12/16/08  MLB  5.20d
     *      - Fix: Revised routine BULKPK to set DSQMAX to AVAIL1
     *        when DSQMAX is less than or equal zero. This happens
     *        when the tie and high are both zero for a slot def
     *        entry.
     *
520eA*    02/28/09  DAS  5.20e  P#00150
     *      - Converted to ILE
     *      - Revised to call GETZONE
     *
520fA*    03/11/09  DAS  5.20f
     *      - Revised to work with new 'Pick cases from Overflow'
     *        option.
     *      - Requires new program GETITEMFLD and revised ITEMFLD file.
     *      - Added client=packers logic around PCKe changes.
520gA*    05/20/09  MLB  5.20g
     *      - Fix: Revised routine PICKRP to add missing SETLL
     *        before inner read to find slot with smallest qty.
520hA*    09/28/09  MLB  5.20h
     *      - Fix: Revised routine PICKP to add missing SETLL
     *        before inner read to find slot with smallest qty.
520iA*    10/05/09  JCJ  5.20i
     *      - Enh: changed to not allow PIR items to be picked as bulk
520jA*    07/14/09  GJA  5.20j  (was 5.20h @ SGC)
     *      - Fix: If item does not have a pick slot, need to
     *        clear save fields.
     *
530 A*    12/04/09  MLB  5.30
     *      - Fix: Revised routines PICKP, PICKRP to save SLDISP so that
     *        a reade loop can be executed using SLOT3 after leaving
     *        inner read loop to find slot with smallest available qty.
     *        Pgm got stuck in loop when different slots had all the
     *        same full key values from SLOT3 and the wrong slot was
     *        selected.
     *
530aA*    11/16/09  JCJ  5.30a
     *      - Enh: Recomplied for database change to TRUCKH
     *      - Enh: Add Truck Template logic
     *
530bA*    02/09/10  RH   5.30b  (missed in update)
     *      - Enh: Add msg 'dated item'
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
     *      - Revised to ignore special license tracking slots,
     *        which are identified with SLDESG = 'BFC'.
610aA*    02/23/10  DAS  6.10a
     *      - Added custom Dierks mod DRKa
610bA*    08/23/10  JCJ  6.10b
     *      - Added On-Demand Repack item processing.
     *      - Move GETITEMFLD to SR GETOD.
610cA*    08/30/10  JCJ  6.10c
     *      - Added code to exit ZZCRTODRQTY if there was a problem
     *        Creating the ODR Slot.
     *
610dA*    11/10/10  GJA  6.10d
     *      - Fix:  Removed CROSSDK file processing.  When ORDD item
     *        was XD it was not processing WORKLBL records.
530bA*    11/08/10  MLB  5.30b
     *      - Enh: Revised program to use OUTQ instead of DEV when
     *        processing OVRPRTF cmd.
     *        change from: OVRPRTF FILE(OR610PR)  OUTQ(*DEV)
     *                   : DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
620aA*    11/16/10  RBD  6.20a
     *      - Added routine to allocate qty from PRE slots for
     *        Pre-pick routes.
620bA*    11/30/10  JCJ  6.20b
     *      - for prepick items retrieve stop from GETSTOP.
620cA*    12/01/10  DAS  6.20c
     *      - Revised that if prepick label isn't closed yet, then
     *        use the label's allocated qty as the slot avail qty.
620dA*    12/03/10  JCJ  6.20d
     *      - Added file KITCOMP
620eA*    12/13/10  DAS  6.20e
     *      - Revised to do prepick before on-demand repack and
     *        warehouse allocation.
620fA*    12/18/10  ???  6.20f
     *      - Minor mod made to zzcrt
620gA*    12/18/10  DAS  6.20g
     *      - Revised zzcrtodrqty to calculate qty to make at the
     *        beginning of the routine then use it in the rest of
     *        the routine.
     *      - Revised rpkqty routine to protect against missing
     *        record.
640aA*    06/20/11  JCJ  6.40a
     *      - Fix: revised BULKPK routine to allow allocation from
     *        overflow slots that do not have the same priority and
     *        dates as the original overflow slot.
640bA*    07/21/11  DAS  6.40b
     *      - Revised to look for a partially picked Batch Pick item.
     *        This situation would be created by OR610B2.
     *      - Added new file WORKLBL11.
640cA*    05/02/12  DAS  6.40c
     *      - Revised bulk pick to ignore ti/hi for High/Medium items.
640dA*    10/02/12  JCJ  6.40d
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
640eA*    10/11/12  RH   6.40e
     *      - Fix: BULKPK client specific to leave do loop was wrong.
     *        changed to SELECT statement.
     *      - Fix: Change BULKPK to use tie/hi if slot has system
     *        generated license plate even for high or medium tracking
640fA*    11/11/12  MLB  6.40f
     *      - Fix: Revised BULKPK routine to clear fields in ITEMDEF if
     *        record not found.
     *      - Fix: Revised pgm to intialize DEFS multi-occur DS. Was
     *        causing dta decimal errors in BULKPK routine.
640gA*    11/13/12  DAS  6.40g
     *      - Fix: Minor mod made to 640e change in bulkpk routine.
640hA*    10/10/12  DAS  6.40h (was 640e at Westside)
     *      - Revised AVAIL to include qty from open Directed Putaways.
640iA*    10/11/12  DAS  6.40i (was 640f at Westside)
     *      - Added parms to chkopndp.
650aA*    05/09/13  RH   6.50a
     *       - Fix: Initialize MJKPIR flag
650bA*    03/11/13  KDE  6.50b These changes are required for the
     *      - changes that allow multiple parent(component) items per
     *      - per the Repack Item
650cA*    05/30/13  KDE  6.50c These changes will enable multiple
     *        quantities to be defined for in KITITEM for output per
     *        a repack item configuration
650dA*    06/10/13  KDE  6.50d These changes allow for an on-demand
     *        item to call another on-demand item as a parent item
650eA*    06/18/13  KDE  6.50e These changes allow an on-demand item
     *        to ship using pick slot and overflow slots instead of
     *        always building what is ordered
650fA*    06/24/13  KDE  6.50f This change will search back to the
     *        case item for stock when an ODR item call an ODR item
     *        and neither have any stock.
650gA*    07/17/13  MLB  6.50g
     *       - Fix: Change to 6.10d mod. Corrected field name used on
     *         chain to SLOT10. Changed to use #sitem instead of ODITEM.
     *         Chain needs to use slot item number instead of ordered
     *         items.  Found this problem at Get Fresh while processing
     *         Alias items flagged as XD=Cross dock items.
650hA*    09/19/13  LMC  6.50h
     *       - Enh: Added printing of msg(5). Message was in table but
     *         never referenced to print.
650iA*    12/07/13  KDE  6.50i
     *       - Corrected read looping problem.  An iter was in place
     *         and a continious loop was occuring
     *
650kA*    12/19/13  RH   6.50j
     *       - Fix: Do not mark label for Prepick (PRE aisle) with
     *         special order flag, XD etc. Prepick can also be
     *         processed as Cross dock, PT132 updated ITEMQTY hold qty
     *         in-correctly based on special order flag in LABEL file
650lA*    01/02/14  KDE  6.50l
     *       - Fix: Initialize variables to determine if odr qty
     *         needs to be built
650mA*    02/07/14  KDE  6.50m
     *       - Fix: Force KITCOMP breakdown quantity on item master
     *         variables if missing in multi-level repack item
     *         and force negative calculated availables to zero
650nA*    07/01/14  KDE  6.50n
     *       - Enh: Add code to process Production items.
650oA*    12/23/14  DAS  6.50o
     *       - Fix: Revised to not allocate a prepick order from
     *         a PRE slot.
650pA*    02/10/15  JCJ  6.50p
     *       - Fix: Changed TRSQ50 from 3,0 to 4,0.
650qA*    09/17/14  LMC  6.50q
     *       - Enh: Added ability to allocate qty available from the
     *         pick slot first then remainder as Bulk if itflgb = 'C'
     *         Ignore minimum cube requirements for bulk itflgb = 'C'
     *         Once leftq1 < avail1 for a slot - allocate balance to
     *         the pick slot.
     *         Ignore tie hi for itflgb = 'C' and use entire license
     *         available qty.
700aA*    08/24/15  NLK  7.00a
     *      - Added routine to allocate qty from AMP slots for
     *        AMP routes, Advanced Merge Pick
     *        Important to note the order coming in as the
     *        Delivery Route of a previous AMP selection MUST
     *        have the same customer order number to connect the two
     *        Update AMPxRef with the Delv Rt info
700bA*    11/09/15  DAS  7.00b
     *      - Revised to update AMPXREF axdlbl# field
700cA*    11/13/15  MLB/RH  7.00c
     *      - Fix: PickPRE routine changes. From CDI. Chgs being tested.
700dA*    03/04/16  NLK     7.00d  (part of 520f and 640c at AJ Silberman)
520fA*      - Added code for pick case from overflow flag = 'Y'(GJA 9/2/11)
640cA*    10/19/11  JCJ  6.40C (brought back to BFC as 700dA)
     *      - Revised to check the "allow bulk pick" flag when
     *        assigning work label status.
700eA*    03/22/16  NLK     7.00e
     *      - FIX: XD, cross dock allowed in AMP normal delv rt
700fA*    05/11/16  LMC     7.00f
     *      - ENH: If an *EACH slot exists for an item, allocate all
     *         ordered Eaches(Breakdown 1 Qty) from that slot.
     *         If an each slot does not exist for the item, then
     *         allocate normally.
700gA*    06/27/16  LMC  7.00g
     *      - Reserved - UCI Tracking
700hA*    07/21/16  MLB  7.00h
     *      - Enh: Add support for *XDOCK in ZZZDRICOP routine.
700iA*    12/23/16  DAS  7.00i
     *      - Enh: Added Customer Expiry Days check. Certain
     *        customers have a specific number of expiry days allowed.
     *      - Added file CUSTDAYS.
     *      - Revised zztrck PCK050 TR09 to identify a customer
     *        expiry days situation.
     *      - Calculated expiration date to use in getod.
     *      - Revised all date checks to use expDate instead of 'today'
700jA*    12/23/16  DAS  7.00j
     *      - Fix: Revised to skip AMP check if out of ORDH records.
700kA*    12/15/16  LMC  7.00k
     *      - Enh: Add logic to add custmast record if not found.
     *      - Enh: ITEMQTY was not being allocated for PRD slot.
     *      - Enh: Use new production options to determine if we
     *        should allocate against the Cust. Order Pck Aisle.
     *      - Enh: Use new production options to determine if we
     *        should create work order for the allocation to the
     *        Cust. Order Pck Aisle.
     *      - Enh: Get production options
710aA*    08/19/15  DAS  7.10a   Note: Was 7.00a at CBI.
     *      -  Added order number to GETZONE call
710bA*    01/13/17  DAS  7.10b
     *      - Enh: Added fields CEDCAT and CEDDIST to CUSTDAYS.
710cA*    02/02/17  KDE  7.10c
     *      - Enh: Recompile after adding field in Itemprd
     *      - Enh: Several changes regarding CUSTMAST required recompile
710dA*    03/09/17  DAS  7.10d
     *      - Enh: Treat item as a non-allocated item if desig = NOALC.
710eA*    03/27/17  MLB  7.10e
     *      - Enh: Added parm for client location on @GETCL call.
710fA*    09/23/17  MLB  7.10f   Was 7.10c at Panos.
     *      - Enh: Increased size of C#CUBE to 11,3 from 7,3.
     *        Fixed at Panos when they went live with full system
     *        and started picking bulk picks (fries) from the pick
     *        slot and start-up inventory was in the pick slot.
710gA*    09/26/17  MLB  7.10g   Was 7.10f at Panos.
     *      - Enh: Revised pgm to create XDK slot for items that do not
     *        have any slots available in the whse. Items with slots
     *        where SLDESG = BFC will be treated as having zero slots.
     *
720aA*    02/27/18  LMC  7.20a
     *      - Enh: Allocate Will call routes to store slots if new    t
     *        *REPLEN flag OPSSLCN = 'Y'. If pick slot exists in store
     *        allocated to that slot, no pick slot in store allocate
     *        against normal warehouse pick slot.
720bA*    09/04/18  MLB  7.20b
     *      - Enh: Revised pgm to add USRDFNDTA keyword to OVRPRTF cmd to
     *        more easily identify whse and route report belongs to.
     *        Was done as part of mod for Westside to duplicate OR610PR
     *        report to outq that emails report to group list. The user
     *        defined data will be included in subject line.
720cA*    10/16/18  KDE  7.20c
     *      - Fix: Call command *AUTOWP when creating Production Work Order
720dA*    10/19/18  KDE  7.20d
     *      *** DO NOT TAKE without MOD 720h
     *      - Fix: Only call Store Slot code for Will Call Orders.
720eA*    10/25/18  DAS  7.20e
     *      - Enh: Add fields to GETZONE call.
720fA*    06/27/16  LMC  7.20f
     *      - Reserved - UCI Tracking
720gA*    12/12/18  KDE  7.20g
     *      - Fix: If pass odr slot is Virtual get the base slot to
     *        pass to DRISLOT.
720hA*    12/13/18  KDE  7.20h
     *      - Fix: Should not have zeroed warehouse. Was writing zero
     *        to warehouse in WORKLBL
730aA*    01/10/19  KDE  7.30a
     *      - Marques sent email saying all Will Call orders other than
     *        ones via HQ245s should follow normal warehouse rules for
     *        allocation
730bA*    01/23/19  KDE  7.30b
     *      - Change to build total case quantity versus order demand
     *        for On-Demand Repack items if the Kit Configuration is
     *        defined like that versus using breakdowns
730cA*    02/15/19  KDE  7.30c
     *      - Remove *AUTOWP command
     *      - Add code for new UPDLOOP command in DRIPROD for components
730dA*    03/04/19  KDE  7.30d
     *      - Enh: Enhance to use both PAR and PRD slots for Production logic
     *        Originally in place for Canopy at Chefs
730eA*    05/21/19  KDE  7.30e
     *      - Enh: Enhance to use DFPICKPSQ to assign PSEQ in WORKLBL
730fA*    07/12/19  MLB/RH  7.30f
     *      - Fix: Change to 7.10g mod. Revised routine ZZCHKSLOT
     *        to add logic to check for XDK slots. If found, then turn
     *        on slotfound flag and continue using XDK logic.
730gA*    08/14/19  DAS  7.30g
     *      - Added Flex Pick logic
730hA*    11/18/19  KDE  7.30h
     *      - Add code for Drop Pick Replenishments originally for Chefs
730iA*    12/09/19  RH/MLB  7.30i
     *      - ***Important *** This program must be compiled at
     *        TGTRLS(V7R1M0) or higher. Pgm fails when compiled at
     *        V6R1M0.
730jA*    11/03/19  DAS  7.30h
     *      - Revised to use LABELW
730kA*    12/05/19  DAS  7.30i
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
     *        **730h & 730i were changed to 730j&k, mods overwritten
740 A*    05/07/20  KDE  7.40
     *      - Change status for Drop Picks from "A" to "DP"
740 A*    04/06/20  MLB  7.40  ZD#01419.
     *      - Revised routine PICKRP to call GETOPT to determine if over-
     *        flow slot for item w/o pick slot is in a child zone. If
     *        yes, force LWLTYP = O instead of B. Bulk picks are not
     *        allowed in child zones.
740aA*    05/15/20  KDE  7.40a
     *      - Include new Drop Pick location range table (DRPRNGE)
     *        and routine loadToSlot to determine next Drop Pick
     *        base slot based on config in DRPRNGE
740bA*    06/16/20  RH/MLB  7.40b
     *      - Fix: Revised routine PICKXD to correctly set LWUTYP.
     *        Type S items were not being set correctly.
     *        Found at Cotati.
740cA*    07/13/20  KDE  7.40c
     *      - Fix Drop Pick issue where is Drop Pick slots are defined
     *        but none setup for specific item it was not allocating
740dA*    08/10/20  KDE  7.40d
     *      - Fix issue where drop picks were allocating as breakdown
     *        even though customer ordered as cases
740eA*    08/26/20  KDE  7.40e
     *      - Increase length of several work fields
     *      - Update ODSPCL with DP for Drop Pick order detail lines
740fA*    11/05/20  MLB  7.40f
     *      - Fix: Revised to use result variable $sslwhse defined on
     *        call to GETPSEQO. Pgm expecting packed 3,0 for whse.
     *        Was causing data decimal errors in called pgm.
740gA*    10/20/20  RH   7.40g
     *      - Enh: Revised to ignore whse-to-whse transfer aisle/loc.
     *        copied 740a mod from DRIPRTYRPL.
740hA*    12/18/20  KDE  7.40h
     *      - Fix: Revised to not allow Drop Pick if item has designation code
     *      - Also ensure status of DP no on items if not drop pick
     *
750 A*    02/22/21  MLB  7.50
     *      - Fix: ** Temporary mod** to only update to SLPSEQ in POST
     *        when GPSEQ > 0. GETPSEQO was clearing SLPSEQ on update.
     *
750aA*    05/05/21  KDE  7.50a
     *      - Enh: Apply updates to support Super Route (Chefs first)
     *
750bA*    06/10/21  KDE  7.50b
     *      - Enh: Apply changes to support auto subs (Greco first)
     *
750cA*    07/22/21  KDE  7.50c
     *      - Enh: Apply changes to prevent drop pick slot if no
     *        available overflow inventory.  Also ensure we only
     *        allocate what is available for Drop Pick instead of
     *        full order quantity
     *
750dA*    07/28/21  KDE  7.50d
     *      - Fix: Do not create XDK slot if Drop Pick
     *
750eA*    08/13/21  KDE  7.50e
     *      - Enh: Do not follow thru as Drop Pick if GETDDSLOT
     *        returns something other than *OK.  This could occur
     *        due to new parm where will limit the number of items
     *        for a base slot.  *NODD is returned if no available
     *        DD slots are found and it should treat as a Bulk pick
     *      - Enh: Change to not exceed capacity of slot based on
     *        slot type and item cube.  Once slot is full we will
     *        move remaining orders for that item to bulk pick.
     *
750fA*    10/29/21  KDE  7.50f
     *      - Enh: Do not perform Drop Pick logic for Will Call orders
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
CLD A*    08/13/04  MLB  CLD
     *      -  Revised program to not create 'OUT' label for PIR item
     *         that don't have any slots in warehouse.
CLDaA *    12/16/04  DAS  CLDa  (Not needed in V6.40)
      *      -  ENH: Skip letdown logic for all orders, don't create
      *         letdowns, system will create JIT priorty replenishments
CLDbA *    12/20/04  MLB  CLDb
      *      -  Enh: Revised program to allow OUT labels to be created
      *         for Breakdown items located in PIR.
CLDcA *    12/20/04  MLB  CLDc
      *      - Revised routines PICKP, PICKRP to re-load slot fields wh
      *        generating 'OUT' label.
CLDdA *    12/22/04  MLB  CLDd
      *      - Revised routines PICK1, PICK2 to allocate entire qty fro
      *        pick slot. Only create OUT label when no slot is found.
      *      - Revised routine ALLOC to call ADJQTY with *ALLOCF cmd to
      *        force entire qty to be allocated.
CLDeA*    01/18/16  MLB  CLDe
     *      -  Fix: Revised CLDc mod to not allow slots where SLDESG=BFC
     *         be selected.
CLDfA*    07/22/19  JCJ  CLDf
     *      -  Revised program to not create 'OUT' label for PIR item
     *         that don't have any slots in warehouse.  This was added
     *         because of the 710g mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPCaA*    11/09/07  DAS  TPCa
     *      - Revised to hard code max cube of a bulk pallet.
TPCbA*    06/26/20  MLB  TPCb
     *      - Revised program to to set ODSPCL = XE when XDK slot is
     *        created for item with no slots on file. XE code will be
     *        used at trans close time to create off-setting adjustment.
     *      - Added TPCb to JOR mod.
     *
     *----------------------------------------------------------------
EI  A*    08/18/11  RH   EI
     *      - Added to VIP3 to: PICKF, PICKF2 and PICKMP to ignore
     *        slot expiration dates on Fixed pick slots.
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJK A*    04/06/07  MLB  MJK
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
     *      - Added MJK to VIP mod.
MJK1A*    04/09/07  MLB  MJK1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
     *      - Added MJK to VIP1 mod.
MJK2A*    04/13/07  MLB  MJK2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
     *      - Added MJK to VIP2 mod.
MJKaA*    09/02/08  DAS  MJKa
     *      - Revised program to pick contract routes through the
     *        BULKPK routine. Re: They want contract items to be
     *        picked as full pallets when possible.
MJKbA*    09/15/08  DAS  MJKb
     *      - Revised BULKPK to do 2 passes. The first pass is to
     *        only look for full pallets as defined by the item's
     *        ti/hi for the slot's slot def code. Note, we grab the
     *        first match we come to. If the qty ordered is 50 and
     *        the first slot we come to has a ti/hi of 2x10 and the
     *        second 4x25, we will go ahead and grab the 2x10 pallet.
     *        The second pass will pick any left over qty.
MJKcA*    10/02/08  DAS  MJKc
     *      - Revised to use mfr ti/hi if slot def ti/hi not found.
MJKdA*    10/13/08  RH/DAS   MJKd
     *      - Fix: Had qty in LWQRMN, set to 0, was causing PT132 to
     *        set SLTFR qty negative.
MJKeA*    04/29/09  MLB  MJKe
     *      - Enh: Revised program to look for Retalix Division code
     *        = '  1' to determine if route is for Contract division
     *        instead of using 'CCxxx' from route number.
MJKfA*    07/07/10  MLB  MJKf
     *      - Enh: Revised program to move code to check for Contract
     *        division route down to the order level instead of the
     *        route level.  This is being done because MJK will be
     *        combining Div 1 and Div 2 orders onto the same route and
     *        MJK wants the Div 1 orders to be built in the same manner.
MJKgA*    10/11/12  RH   MJKg
     *      - Fix: Revised to process PIR using Mfg tie/hi, error
     *        caused by Version 6.40 update.
MJKhA*    05/09/13  RH   MJKh
     *      - Fix: Revised to process PIR using Mfg tie/hi, 640g
     *        mod was overriding MJKg fix.
MJKiA*    04/09/14  RH/MLB  MJKi
     *      - Fix: Will create OUT label and exception for Contract
     *        item that can't be picked.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques
     *
MQS A*    10/19/18  KDE  MQS
     *      - Revised routines PICKF2 and PICKMP to read hnadle Warehouse
     *        slots and Store Slots properly when allocating normal trucks
MQSaA*    11/06/18  KDE  MQSa
     *      - Force higher priority on Store Slots so they are read last
     *        in allocation routines
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/06/07  MLB  VIP
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
VIP1A*    04/09/07  MLB  VIP1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
VIP2A*    04/13/07  MLB  VIP2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
VIP3A*    04/18/07  MLB  VIP3
     *      - Revised routines: PICKF, PICKF2 and PICKMP to ignnore
     *        slot expiration dates on Fixed pick slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: US Foods
     *
USF A*    07/21/05  MLB  USF
     *      - Revised program to create bulk picks from pick slot if
     *        order quantity qualifies as a bulk pick. Stand-Alone
     *        Truck Builder won't have any overflow slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
     *
PCKaA*    10/20/04  HNK  PCKa
     *      -  ENH: Skip letdown logic for all orders, don't create    '
     *         letdowns. Use Sp Slot Replen                            '
PCKbA*    11/03/04  DAS  PCKb
     *      - Enh: Revised to pick from overflow slots when pick slot
     *        has available qty is negative or zero.
     *      - This was done because the users at Packers have not been
     *        using the system to do Replenishments.
PCKcA*    11/12/04  HNK  PCKc
     *      - Revised to ignore slots in aisle > 44
PCKdA*    01/27/05  RH   PCKd
     *      - Fix: slots in aisle 44 or > were slipping past and being
     *        selected in PICKRP.
     *      - ENH: Add code to BULKPK to not use aisle 44 or >.
PCKeA*    10/18/05  HNK  PCKe
     *      - Revised to ignore slots in aisle 1 thru 10 in DRY
     *      - Revised to enable slots in aisle 44 thru 65 in DRY
     *      - Revised to ignore slots in aisle 66 and above.
PCKfA*    03/15/07  DAS  PCKf
     *      - Removed PCKb change.
     *
PCKg *    03/23/07  HNK  PCKg
     *      - Reverse PCKa change.
PCKh *    02/02/10  MLB  PCKh
     *      - Change to PCKe change completed in 10/2005.
     *        Removed limitation on aisles 01-10 in dept DRY.
     *        Per Carlos Santos email dated 02/02/2010. Phone
     *        call from Carlos altered original email on same date.
PCKiA*    08/24/20  MLB  PCKi
     *      - Revised pgm to flag XDK labels created when no slots
     *        found for items with OUT. This will cause them to be
     *        directed to the Runner Flag module for processing.
     *        Per Hemant K email, dated 08.24.2020.
PCKjA*    04/15/21  MLB/RH  PCKj
     *      - Fix: Revised PCKI mod to bypass allocation for XDK
     *        flaged as OUT.  Was leaving qty in slot allocated.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVL1A*    08/18/09  MLB  SVL1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
SVLbA*    08/27/09  RH   SVLb
     *      - Revised program to print OUT labels for will call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC1A*    06/03/09  MLB  SGC1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
     *
SGCaA*    06/17/09  RH   SGCa
     *      - Removed call to GETITMFLD, program was not on system.
SGCbA*    06/25/09  MLB  SGCb
     *      - Added Springfield to MJKb mod.
     *      - Revised BULKPK to do 2 passes. The first pass is to
     *        only look for full pallets as defined by the item's
     *        ti/hi for the slot's slot def code. Note, we grab the
     *        first match we come to. If the qty ordered is 50 and
     *        the first slot we come to has a ti/hi of 2x10 and the
     *        second 4x25, we will go ahead and grab the 2x10 pallet.
     *        The second pass will pick any left over qty.
SGCcA*    11/24/14  MLB  SGCc
     *      - Revised SGC1 mod. Changed routines PICKMP, PICKRP to create
     *        an OUT label when an Allocation Override item = Y and no
     *        slot found.
SGCdA*    09/29/16  MLB  SGCd   *Retalix Mods*
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
     *      - Added SGCd to VIP mod.
SGCeA*    09/29/16  MLB  SGCe   *Retalix mods*
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
     *      - Added SGCe to VIP1 mod.
SGCfA*    09/29/16  MLB  SGCf   *Retalix Mods*
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
     *      - Added SGCf to VIP2 mod.
SGCgA*    03/14/17  MLB  SGCg
     *      - Revised program to create XDK slot and update ODSPCL = XD
     *        when OMIAOV = Y and no slot found for item.
     *      - Added SGCg to FRP3.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFC A*    07/25/11  MLB  GFC
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
     *      - Added GFC to VIP mod.
GFC1A*    07/25/11  MLB  GFC1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
     *      - Added GFC to VIP1 mod.
GFC2A*    07/25/11  MLB  GFC2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
     *      - Added GFC to VIP2 mod.
GFC3A*    04/26/12  JCJ  GFC3
     *      - Added to VIP3 to: PICKF, PICKF2 and PICKMP to ignore
     *        slot expiration dates on Fixed pick slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dierks Waukesha
     *
DRKaA*    02/23/10  DAS  DRKa
     *      - Temp mod to force Letdowns (OPJITR = '1')
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLBaA*    08/21/11  JCJ  SLBa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash-Wa
     *
CWDaA*    02/27/12  JCJ  CWDa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
CWDbA*    07/16/18  MLB  CWDb
     *      - Enh: Revised pgm to omit Cash Wa from 7.10g mod that
     *        creates XDK slots for items with no product in any pick/
     *        overflow slots. per Dustin H.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    02/27/12  JCJ  CTWa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: West Side Foods
     *
WSFa *    03/09/00  DAS  WSFa
     *      - Revised PICKRP to set label type to 'O' instead of 'B'.
     *        Also, set LWASL2 to 'DOC' instead of blanks.
     *        This was done because Westside has many new items which
     *        don't have pick slots.
WSFb *    11/15/06  MLB  WSFb
     *      - Revised OPNPRT to set printer device to P4
     *        when will-call routes are processed.
WSFc *    03/08/14  JCJ  WSFc
     *      - Enh: deactivate 650h for client.
WSFd *    01/18/18  GJA  WSFd
     *      - Revised to print report to P1 and P6
WSFeA*    08/30/18  MLB  WSFe
     *      - Revised WSFd mod to send duplicate copy to WSFBFCRPT.
     *        Per Moses S. email dated 08/30/18.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*    04/01/15  MLB  SOF
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
     *      - Added SOF to VIP mod.
SOF1A*    04/01/15  MLB  SOF1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
     *      - Added SOF1 to VIP1 mod.
SOF2A*    04/01/15  MLB  SOF2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
     *      - Added SOF2 to VIP2 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    11/18/14  LMC  HMWa
     *      - Revise program to check for SR status slot, if SR
     *        status slot does not exist - normal allocation process
     *        will be used. This is for Will Call Routes only.
HMWb *    01/08/15  RTR  HMWb
     *      - Removed 'SR' check from mod HMWa, do for all Will Call
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    07/01/03  CBI  MLB
     *      - Revised program to look for items with dept PRD. These
     *        items are non-stock items and will be treated as being
     *        fully allocated 100% and a label record generated.
CBIaA*    07/02/03  CBIa  MLB
     *      - Revised program to look for orders with MEATIN='Y' in
     *        OHMISC. These items have been previously picked and
     *        moved to the meat inspection area. These items will be
     *        treated as being allocated 100%.
CBIbA*    07/16/03  CBIb  DAS
     *      - Revised routine CRTLW2 to set LWSTYP to 'F'.
CBIcA*    07/17/03  CBIc  MLB
     *      - Revised routines PICKP, PICKRP to re-load slot fields when
     *        generating 'OUT' label.
CBIdA*    07/23/03  CBId  MLB
     *      - Revised routine CRTLW2 to load A1A's slot location into
     *        our aisle, location, level fields.
CBIeA*    08/26/03  CBIe  DAS
     *      - Revised routines PICKF, PICKF2 and PICKMP to ignore the
     *        slot expiration date. Currently, CBI is setting all of
     *        the pick slot exp dates to a future date before picking.
     *        However, some programs were moving an expired exp date
     *        into the slot. This change will not ignore the exp date
     *        all together for Fixed Pick slots.
CBIfA*    09/11/03  CBIf  DAS
     *      - Revised CRTLW2 to hardcode department and slot for Meat
     *        Inspection items.
CBIgA*    10/07/03  CBIg  DAS
     *      - Revised CBIf change so each department has its own slot.
     *      - Added Pre-Pick logic, similar to Meat inspection.
CBIhA*    10/15/03  CBIh  DAS
     *      - Revised CRTLW2 to set LWUTYP and LWUCOD correctly.
     *        *** CRTLW2 assumes only one quantity is sent ***
CBIiA*    10/15/03  CBIi  DAS
     *      - Revised CRTLW2 to set LWPSEQ field.
CBIjA*    12/29/03  RH   CBIj
     *                        (location OCA, PG)
     *      -  ENH: Skip letdown logic for CONTAINER or CRUISE orders  '
CBIkA*    02/05/04  DAS  CBIk
     *                        (location OCA, PG)
     *      -  FIX: Revised to add cc Pick qty into STOCK fields.      '
CBIlA*    03/22/04  HNK  CBIl
     *      -  FIX: Revised to change the CD-525-1 slot to CS-169-1    '
CBImA*    08/24/04  RH   CBIm  -no mods marked CBIm-
     *                         (location OCA, PG)
     *      -  ENH: Skip letdown logic for all orders, don't create    '
     *         letdowns, system will create JIT priorty replenishments '
     *         Set the opjitr flag so repl will not occur              '
     *         This mod will be handled with the following base code   '
     *         Do not create replenishments.                           '
     *                     if        opjitr <> '1'                     '
CBInA*    10/15/12  MLB  CBIn  P#01092
     *      - Revised pgm to use gross ship wgt stored in PIRITEM in
     *        field ITRCVD instead of net ship wgt, ITSWGT.
CBIoA*    06/08/14  MLB  CBIo  P#01218
     *                        (location gwb only)
     *      - Revised pgm to populate LWDISP = OUT when item does not
     *        have a pick slot for GWB warehouse items. Was causing
     *        update error on PLTSUN5 for will-call orders.
     *
CBIpA*    10/26/15  JCJ  CBIp
     *                        (location PG only)
     *      - Added Punta Gorda client copy specs.
     *      - ignore slot logic for Meatin/Prepck for Punta Gorda.
     *
CBIqA*    10/24/13  MLB  CBIq  P#nnnnn  (**CBIo from PIRMODS**)
     *                         (location OCA only)
     *    - Revised pgm to add support for Ocala to use Pre-Pick
     *    processing support. This also involved manual update of
     *    label fmts: PREPCKC, PREPCKD and PREPCKF with Ocala Pre-
     *    pick slots: C=PC-100-1, D=PD-100-1 and F=PF-100-1.
     *    - Per Gus C. email dated 10/24/13.
CBIrA*    04/21/17  DAS  CBIr (was CBIo)
     *      - Revised pgm to ignore CBIe change when working with
     *        a 700i Expiry Days customer. For these customers we
     *        want the program to pick from Overflow.
CBIsA*    03/24/17  JCJ  CBIs
     *      -  Enh: added custom slots for buyers 150, 155, 160 for
     *         Greensboro.
CBItA*    08/31/17  JCJ  CBIt
     *      -  Enh: Changed to retrieve the slot that prints on the
     *              pick labels in LIFO order when no slots for the
     *              item match the Expiry days criteria.  Attemped
     *              to get an overflow slot first then a Pick slot.
CBIuA*    03/05/18  NLK  CBIu like VIP2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
CBIvA*    05/23/18  NLK  CBIv  2017222
     *      - Enh: OCA to RIV Cross dock, needs to know what XDK
     *        slot to choose. CBI will send in ORDDM misc2 col 15-17
CBIwA*    06/27/18  NLK  CBIw  2018062 and 014
     *      - Enh: Container-Batch Pick, seton batchPickItem if
     *        truck template is CONTAINER.  Careful to remember,
     *        Only Normal quantities can be Batch picked, not Eaches.
     *        1 item per pallet/70 max pallets
CBIxA*    09/04/18  MLB  CBIx  P#2018180  (was CBIu)
     *      -  Enh: Revised pgm to disable 7.10g mod that creates
     *              XDK slots for items with no slot in whse. This
     *              was causing problems for CBI because they have
     *              production items that are made and shipped next day.
CBIyA*    01/09/18  MLB  CBIy  (was CBIt)
     *      -  Enh: Revised CBIs mods. Per CBI conf. call 01.09.18.
     *         Chg'd MT-84-09 to use MT-101-1.
     *         Chg'd FI-00-11 to use FI-100-1.
CBIzA*    11/28/18  MLB  CBIz  (was CBIu)
     *      -  Enh: Revised CBIy mods. Per CBI conf. call 11.28.18.
     *         Chg'd FI-100-1 to use FS-100-1 for buyer# 155.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    03/04/16  MLB  FPR
     *      - Revised program to allocate item# 9999999999 100%.
     *        Item is used for special order items.
FPR1A*    03/04/16  MLB  FPR1
     *      - Revised program to retrieve allocation override flag
     *        When alloc. override flag=Y=Yes, send *ALLOCFR cmd
     *        when calling ADJQTY program.
FPR2A*    03/04/16  MLB  FPR2
     *      - Revised program to load item weight, cube from ORDDM
     *        file for item# 9999999999.
FPR3A*    07/11/16  MLB  FPR3
     *      - Revised program to create XDK slot and update ODSPCL = XD
     *        when OMIAOV = Y and no slot found for item.
FPR4A*    08/17/16  MLB  FPR4
     *      - Fix: Revised FPR3 mod to call UNALOC to unallocate qty for
     *        item when OMIAOV = Y and XDK slot is created for the item.
     *        Qty was being left in Allocated bucket at whse level
     *        causing a whse/slot qty discrepancy. Per Roxanne's 08.17.16
     *        email.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos Foods
     *
PAN A*    08/24/16  MLB  PAN
     *      -  Enh: Revised program to use tie/hi when calculating
     *         pallet cubes for bulk picks.
PANaA*    08/26/16  MLB  PANa
     *      -  Enh: Revised BULKPK to get out if LEFTQ1 is less than
     *         DSQMAX, qty that will fit on 1 pallet. Only want to build
     *         full pallets that are bulk picks. Otherwise, pick normally.
PANbA*    09/23/17  MLB  PANb
     *      - Revised pgm to create bulk picks from pick slots for items
     *        based on tie/high and the item has Category Code=FRZN-POT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys Foods
     *
KFS A*    03/01/19  MLB  KFS
     *      -  Enh: Revised program to run routine, CRTLBL when dept
     *         for item = CHK. Chicken items will be treated as non-stock
     *         items. Per Roxanne H.
     *      -  Added file, ORDDS to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
JOR A*    06/28/19  MLB  JOR
     *      - Revised program to to set ODSPCL = XE when XDK slot is
     *        created for item with no slots on file. XE code will be
     *        used at trans close time to create off-setting adjustment.
     *----------------------------------------------------------------
     *  Quantity Types Notes
     *
411 A*   Contract Item
     *     - Quantity ordered is allocated from the warehouse quantity
     *       of the Contract item.
     *     - Quantity ordered is NOT allocated from the warehouse quantity
     *       of Base item (it was allocated at receiving).
     *     - Quantity is allocated from slots containing the Base item.
     *     - Label record will contain Contract item number.
     *     - Label record type will correspond to quantity type being
     *       received (Normal, Brk1, Brk2).
     *
     *   Same Slot Breakdown (SSB) Item
     *     - Quantity ordered is allocated from Base item Warehouse/Slot
     *       breakdown quantities (ie. a normal qty being picked will be
     *       allocated from the warehouse breakdown 1 quantity).
     *     - Quantity is allocated from slots containing the Base item.
     *     - Label record will contain SSB item number.
     *     - Label record type will correspond to warehouse/slot
     *       quantity being used internally (ie. a normal qty being
     *       picked will be put into the warehouse/slot breakdown 1
     *       quantity and would therefore have a label type of '2'.
     *
411 A*----------------------------------------------------------------
     *  Misc Notes
     *
411 A*    - Each item defined in the PIRITEM file, no matter the type,
     *      must contain its own detail information (ie. Description,
     *      Dimensions, Weight, Tie/Highs, Etc . . .).  This program
     *      will always deal with the Item information for the item
     *      that was sent into the program (the item being received).
     *      In the case of Alias, Contract and Same Slot Breakdown
     *      items the information should be identical to its
     *      corresponding Base item.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
CBIdA*  45        Invalid characters in PRD location.
530 A*  75        Record lock error on SLOT3
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordh2     uf   e           k disk
750aAfordh      uf   e           k disk    rename(ohrec:ohrecsr)
750aAf                                     prefix(sr_)
750aAfsrord     if   e           k disk
700aAFordhm     if   e           k disk
     Fordd1     uf   e           k disk
640bDF*rddm     if   e           k disk    usropn
640bMForddm     if   e           k disk
KFS AFordds     if   e           k disk
     Fslot3     uf   e           k disk
CBItAFslot13    if   e           k disk
CBItAF                                     rename(slrec:slrec13)
CBIvAFslot4     if   e           k disk
CBIvAF                                     rename(slrec:slrec4)
     Fpiritem   if   e           k disk
414cAFitemdsc   if   e           k disk
650nAFitemPrd   if   e           k disk
650nAFplined    if   e           k disk
650nAFpcslot    if   e           k disk
     Fitemdef1  if   e           k disk
MJKcAFitemmsc   if   e           k disk
     Foptionz   if   e           k disk
410 AFoptions   if   e           k disk
     Ftruckh    if   e           k disk
520eDF*oned2    if   e           k disk
404 AFslot2     if   e           k disk
     F                                     rename(slrec:slrec2)
610bAFvslot2    if   e           k disk
720gAfvslot1    if   e           k disk    rename(vsrec:vsrec2)
720gAf                                     prefix(v_)
610dDF***crossdk1  if   e           k disk
620aAFprexref1  uf   e           k disk
700aAFampxref1  uf   e           k disk
413aAFpirtrck2  o    e             disk
640bAFworklbl11 if   e           k disk
640bAF                                     rename(lwrec:lwrec11)
     Fworklbl   o  a e           k disk
415 D**610PR O   E             90     PRINTER
415 MFor610pr   o    e             printer oflind(*in90)
     F                                     usropn
610dAFslot10    if   e           k disk
     F                                     rename(slrec:slrec10)
730jDF*abel     if   e           k disk
730jMFlabelw    if   e           k disk
650fAFkitcomp   if   e           k disk
650dAFkititem   if   e           k disk
650qAFliclog1   if   e           k disk    usropn
700fAFslotdef   if   e           k disk
700iAFcustdays  if   e           k disk
700kAFcustmast  if a e           k disk
720dAFslotstr   if   e           k disk
730kAFbfcdebug  o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
415 AD a80             s              1    dim(80)
530bDD*msg             s             40    dim(5) ctdata perrcd(1)
FPR3DD*msg             s             40    dim(6) ctdata perrcd(1)
FPR3MD msg             s             40    dim(7) ctdata perrcd(1)
415 AD ovrprt          s             80    dim(1) ctdata perrcd(1)
650bA*
650bA*   definitions to work with user space to setup
650bA*     variable size array for Repack Components
650bA*
650bA*   API to create a user space object
650bA
650bAD CreateUserSpace...
650bAD                 pr                  extpgm('QUSCRTUS')
650bAD   NameAndLib                  20a   const
650bAD   ExtAttr                     10a   const
650bAD   InitSize                    10i 0 const
650bAD   InitValue                    1a   const
650bAD   PublicAut                   10a   const
650bAD   Description                 50a   const
650bAD   Replace                     10a   const
650bAD   ErrorStruct                 16a

650bAD ChangeUserSpaceAttributes...
     *   API to change user space object attributes
650bAD                 pr                  extpgm('QUSCUSAT')
650bAD   LibraryName                 10a
650bAD   NameAndLib                  20a   const
650bAD   Attributes                  10a   const
650bAD   ErrorStruct                 16a

650bAD AttrList        ds                  qualified
650bAD  Size                         10i 0
650bAD  Key                          10i 0
650bAD  DataLength                   10i 0
650bAD  Data                          1a

650bAD SpaceName       s             20a   inz('ARYRPD    QTEMP')
650bAD RtnLib          s             10a
650bAD ErrorStruct     s             16a   inz(*allx'00')

     *   API to retrieve a pointer to the user space
650bAD RtvPtrToUsrSpc  pr                  extpgm('QUSPTRUS')
650bAD   Name                        20a   const
650bAD   Ptr                           *
650bAD   Qusec                             LikeDS(Qusec)

     * API to delete a user space
650bAD DltUsrSpc       pr                  ExtPgm('QUSDLTUS')
650bAD   SpaceName                   20A   Const
650bAD   Errorcde                 32767A

650bAdQusec            ds
650bAd qusbprv                 1      4b 0
650bAd qusbavl                 5      8b 0
650bAd qusei                   9     15
650bAd quserved               16     16

750bA *----------------------------------------------------------------
750bA *   Sub-Procedures
750bA *---------------------------------------------------------------
750bAd KeepOrSub       pr              n
750bAd  iRtid                              like(ohrte)
750bAd  iOrd                               like(ohord)
750bAd  iItem                              like(oditem)
750bAd  iSeq                               like(odseq)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)

     d crtAutoSub      pr            99
750bAd  iOrd                               like(ohord)
750bAd  iItem                              like(oditem)
750bAd  iSeq                               like(odseq)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)
     d  isubitem                     15
     d  isubseq                            like(odseq)

     d wrtSubLog       pr
750bAd  iSubItem                           like(oditem)
750bAd  iAs                           1
750bAd  iSubSeq                            like(odseq)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)
     d  iActMsg                      99

750eAd maxCubeQty      pr              n
750bAd  iWhse                              like(slwhse)
750bAd  iWhdp                              like(slwhdp)
750bAd  iDisp                              like(sldisp)
750bAd  iItem                              like(oditem)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)

610bA*----------------------------------------------------------------
610bA*  DRI parameters
610bA*----------------------------------------------------------------

610bA /COPY *libl/qcopysrc,C#DRIPARMS

610bA*----------------------------------------------------------------
610bA*  Data Formats
610bA*----------------------------------------------------------------

610bA /COPY *libl/qcopysrc,C#ITEM
610bA /COPY *libl/qcopysrc,C#ITEMQTY
610bA /COPY *libl/qcopysrc,C#SLOT
700hA /COPY *libl/qcopysrc,C#XDOCK
510aA /COPY *libl/qcopysrc,C#PRTYRPL
650nA /COPY *libl/qcopysrc,C#PROD
720aA /COPY *libl/qcopysrc,C#ZONED
650qA /COPY *libl/qcopysrc,C#LICENSE
650qA /COPY *libl/qcopysrc,C#LICINFO
650qA /COPY *libl/qcopysrc,C#UCIINFO
610bAD saveVer#        s                   like($slver#)
610bAD save$slot       s                   like($slot)

417zA*----------------------------------------------------------------
417zA*  Customer id
417zA*
     D @getcl          c                   const('GETCLIENT')
500 A*
417zA /COPY QCOPYSRC,ID#CITYLIN
510aA /COPY QCOPYSRC,ID#USFCRP
MJK A /COPY QCOPYSRC,ID#MJKELLN
VIP A /COPY QCOPYSRC,ID#VIP
PCKeA /COPY QCOPYSRC,ID#PACKERS
SGC1A /COPY QCOPYSRC,ID#SGC
SVL A /COPY QCOPYSRC,ID#SAVAL
DRKaA /copy qcopysrc,id#dierks
EI  A /copy qcopysrc,id#ei
SLBaA /copy qcopysrc,id#silberm
GFC A /COPY QCOPYSRC,ID#GLAZIER
CWDaA /copy qcopysrc,id#cashwa
CTWaA /copy qcopysrc,id#citywho
WSFaA /copy qcopysrc,id#westsid
SOF A /copy qcopysrc,id#sofo
HMWaA /COPY QCOPYSRC,ID#hmwagne
CBIcA /COPY QCOPYSRC,Id#CHENEY
CBIcA /COPY QCOPYSRC,Id#CHENEYO
CBIcA /COPY QCOPYSRC,Id#CHENEYR
CBIcA */COPY QCOPYSRC,Id#CHENEYG
CBIcA /COPY QCOPYSRC,id#cheneyp
GLPaA /copy qcopysrc,id#GLP
TPCaA /copy qcopysrc,id#tpc
FPR A /copy qcopysrc,id#fpr
PAN A /copy qcopysrc,id#PAN
MQS A /copy qcopysrc,id#MQS
KFS A /copy qcopysrc,id#kfs
JOR A /copy qcopysrc,id#jordano
SGC1A*
SGC1A*----------------------------------------------------------------
SGC1A*
SGC1A /COPY QCOPYSRC,orddm1_sgc
CBIuA /COPY QCOPYSRC,orddm2_CBI
SGC1A*
SGC1A*
500 A*
     *------------------------------------------------------------
     *  Tie/High definitions data structure.
     *
     D defs            ds                  occurs(9)
     D  dssdef                 1      2
     D  dstie                  3      6  0
     D  dshigh                 7      8  0
     D  dsqmax                 9     15  0
     D  dsqmin                16     22  0
     D  dsmtch                23     23
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
MJKeAD                 DS
MJKeAD  HCMPN                  1      3
MJKeAD  HDIVN                  4      6
MJKeAD  HDPTN                  7      9
MJKeAD  HWHSN                 10     12
CBIaAD  meatin                15     15
CBIgAD  prepck                17     17
MJKeAD  OHMISC                 1     20
MJKeAD*
     D vip999          c                   const('9999999999')
GFC AD H_S999          c                   const('999999')
SVL1A /copy qcopysrc,orddm1_svl
VIP1AD vipms1          ds
VIP1AD  ommsc1                 1     40
VIP1AD  ompckm                 1      4  0
VIP1AD  omwhdp                 5      9
VIP1AD  omvpsz                10     24
VIP1AD  omiaov                25     25
VIP1AD  omsltn                26     32
VIP2AD  omcwcd                33     33
VIP2AD  omwtiw                34     37p 2
VIP2AD  omcbec                38     40p 3
VIP1A*
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximu orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTORD  -  Maximum orders per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
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
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D  opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opdend               117    117
410aA*----------------------------------------------------------------
410aA*  *GENPICK -  General picking options.
410aA*----------------------------------------------------------------
410 A*
410 A* Fields
410 A*
410 A*    OPERPT  -  Print exception (short) error report (Y,N).
410 A*    OPELBL  -  Print exception (short) labels (Y,N)
410BA*    OPRFWC  -  Using RF will call (Y,N).
414aA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
417 A*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
417 A*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
417 A*    OPEADJ  -  Close short labels without adjustment (Y,N).
417 A*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500dM*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500dM*                 0=None. No replenishments are created.
500dA*                 1=Letdowns are created during Truck Builder
500dA*                   Pick/Print processing.
500dA*                 2=Priority Replenishments are created during
500dA*                   Truck Builder Pick/Print processing.
500dA*                 3=JIT Letdowns created when transaction is
500dA*                   checked out.
500dA*                 4=JIT Priority Replenishments created when
500dA*                   transaction is checked out.
410 A*
410 A* Data structure
410 A*
410 AD opdta1          ds
410 AD  operpt                 1      1
410 AD  opelbl                 2      2
410BAD  oprfwc                 3      3
414aAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
417 AD  opmrga                 6      6
417 AD  opplsq                 7      7
417 AD  opeadj                 8      8
417 AD  opnopk                 9      9
500bAD  opjitr                12     12
750bAd  opsauto              102    102
410 AD  optend               117    117
414cAD opdta2          ds
414cAD  opstyp                 1      1
414cAD  opwhdp                 2      6
414cAD  opum1                  7      8
414cAD  opdum                  9     23
414cAD  opcum                 24     43
414cAD  opcdiv                44     52  2
414cAD  opcaut                53     53
414cAD  opcwrn                54     54
414cAD  opcrng                55     57  1
414cAD  opwum                 58     72
414cAD  opxdsc                73     73
700kA *
700kA*----------------------------------------------------------------
700kA*  *PROD  -  Production Option Settings
700kA*----------------------------------------------------------------
700kA*
700kA* Fields
700kA*
700kA*    OPLBRP  -  Reprint production labels
700kA*    OPLBDL  -  Delete Production labels
700kA*    OPVARM  -  Use Variable Measure for generated GTIN
700kA*    OPIMPGTIN  Import GTIN's from Customer
700kA*    OPGENGTIN  Generate GTIN's from customer item number
700kA*    OPPRDDTE-  Include Production date in GS1
700kA*    OPPCKDTE-  Include Package date in GS1
700kA*    OPEXPDTE-  Include Expiration Date in GS1
700kA*    OPNETLBS-  Include Net pounds in GS1
700kA*    OPLBSDEC-  Number of decimals for Net pounds
700kA*    OPNETKG -  Include Net kilograms in GS1
700kA*    OPKGDEC -  Number of decimals for Net kilograms
700kA*    OPREPLN -  Automated Replenishments to Production
700kA*    OPTYPRP -  Type of replenishment
700kA*    OPPRO   -  Produce Facility
700kA*    OPGS1   -  GS1 Scan
700kA*    OPBRKR  -  Allow Breakdown Replenishment
700kA*    OPBXBU  -  Use Box Breaker
700kA*    OPBXBP  -  Perform Box Breaker from pick slot
700kA*    OPBXBS  -  Box Breaker uses System Gen License
700kA*    opalccopa - Allocate against Cust. Order Pck Aisle
700kA*    opcrtwo -  Create production work order for Qty allocated
700kA*               against Cust. Order Pck Aisle.
700kA*
700kA*----------------------------------------------------------------

700kAD opdta3          ds
700kAD  oplbrp                 1      1
700kAD  oplbdl                 2      2
700kAD  opvarm                 3      3
700kAD  opimpgtin              4      4
700kAD  opgengtin              5      5
700kAD  opprddte               6      6
700kAD  oppckdte               7      7
700kAD  opexpdte               8      8
700kAD  opnetlbs               9      9
700kAD  oplbsdec              10     10  0
700kAD  opnetkg               11     11
700kAD  opkgdec               12     12  0
700kAD  oprepln               13     13
700kAD  optyprp               14     20
700kAD  oppro                 21     21
700kAD  opgs1                 22     22
700kAD  opbrkr                23     23
700kAD  opbxbu                24     24
700kAD  opbxbp                25     25
700kAD  opbxbs                26     26
700kAD  opalccopa             27     27
700kAD  opcrtwo               28     28

720aA*----------------------------------------------------------------
720aA*  *REPLEN  -  Replenishment options.
720aA*----------------------------------------------------------------
720aA*
720aA* Fields
720aA*
720aA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
720aA*    OPOQRP  -  Order qty replenishment (Y/N).
720aA*    OPRPEX  -  Allow replenishment on expired items.
720aA*               1=Allow, 2=Don't allow, 3=Warn
720aA*    OPRPFI  -  Allow replenishments out of FIFO order.
720aA*               1=Allow, 3=Warn
720aA*    OPLMTS  -  Limit Specific Slot replenishment program to
720aA*               to display only one overflow location at a
720aA*               time. (Y/N)
720aA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
720aA*               letdown/transfer. (Y/N)
720aA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
720aA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
720aA*    OPSKPR  -  Skip if pick slot physical qty is greater than
720aA*               item replenishment level.
720aA*    OPJITW  -  During specific slot repl if this option = N don't
720aA*               bother checking for JIT's as the user does not want
720aA*               the JIT notification window.
720aA*    OPLQTY  -  Replenish pick slots that display less than X
720aA*               cases.
720aA*    OPSSLCN -  Scan License to initiate specific Slot. Used when
720aA*               Staging replenishments for remote site such as
720aA*               Company Store.
720aA*
720aA* Data structure
720aA*
720aAD opdta4          ds
720aAD  oprplb                 1      8
720aAD  opoqrp                 9      9
720aAD  oprpex                10     10
720aAD  oprpfi                11     11
720aAD  oplmts                12     12
720aAD  opcqty                13     13
720aAD  opbdrp                14     14
720aAD  oprsrt                15     24
720aAD  opskpr                25     25
720aAD  opjitw                26     26
720aAD  oplqty                27     28  0
720aAD  oplqtya               27     28
720aAD  opsslcn               29     29
720aAD  opcend               117    117

520eD**---------------------------------------------------------------
520eD** Multiple occurance data structure for zone options
520eD**
520eDD*opts            ds                  occurs(50)
520eDD* #dzone                 1      6
520eDD* #dbpck                 7      9  0
413aA*----------------------------------------------------------------
413aA*
413aA* The following data structures are for capturing picking
413aA* tracking info.
413aA*
413aA*----------------------------------------------------------------
413aA*  *PCK001   -  Picking Batch detail info
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRPCMD  -  Program processing option
413aA*    TRPPRG  -  Calling program
413aA*    TROTYP  -  Order type
413aA*    TRRORD  -  Restart order number
413aA*    TRPKST  -  Picking status
413aA*    TRFLPK  -  Picking options error flag (0=Rcd found, 1=Missing)
413aA*    TRFLTK  -  Truck options error flag (0=Rcd found, 1=Missing)
413aA*
413aA* Data structure
413aA*
413aAD tr01ds          ds
413aAD  trpcmd                 1      8
413aAD  trprg                  9     18
413aAD  trotyp                19     19
413aAD  trrord                20     26  0
413aAD  trpkst                27     46
413aAD  trflpk                47     47
413aAD  trfltk                48     48
413aAD  trdt01                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK002  -  General Picking options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    Note: See general picking options definition.
413aA*
413aA* Data structure
413aA*
413aAD tr02ds          ds
413aAD  trdt02                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK003  -  Truck Header info
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRROWS -  Row in trailer
413aA*    TRCOLS -  Column in trailer
413aA*    TRBULK -  Allow bulk picks (Y/N)
413aA*    TRBAT  -  Allow batch picks (Y/N)
413aA*
413aA* Data structure
413aA*
413aAD tr03ds          ds
413aAD  trrows                 1      2  0
413aAD  trcols                 3      3  0
413aAD  trbulk                 4      4
413aAD  trbat                  5      5
413aAD  trdt03                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK010  -  Zone pick options definition.
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRZONE  -  Picking zone
413aA*    TRDT10  -  See defintion for zone pick options.
413aA*
413aA* Data structure
413aA*
413aAD tr10ds          ds
413aAD  trzone                 1     10
413aAD  trdt10                11    150
413aA*----------------------------------------------------------------
413aA*  *PCK040  -  Subroutines entered
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRSUBR  -  Subroutines entered.
413aA*
413aA* Data structure
413aA*
413aAD tr40ds          ds
413aAD  trr                    1    150
     D                                     DIM(25)
413aAD  trrfld                 1    150
413aA*----------------------------------------------------------------
413aA*  *PCK050  -  Tracking message(s)
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRSR50  -  Subroutine sending message
413aA*    TRDT50  -  Tracking message(s)
413aA*
413aA* Data structure
413aA*
413aAD tr50ds          ds
413aAD  trsr50                 1     10
413aAD  trdt50                11    150
413aA*----------------------------------------------------------------
413aA*  Tracking messages
413aA*----------------------------------------------------------------
     D tr05            c                   const('QtyOrd:')
     D tr06            c                   const('QtyAlc:')
     D tr07            c                   const('QtyPck:')
700iDD*tr08            c                   const('ExpDate:')
700iMD tr08            c                   const('Slot ExpDate:')
700iAD tr08c           c                   const('ExpDate:')
700iAD tr08d           c                   const('Days:')
     D tr09            c                   const('Slot bypassed: Produ-
     D                                     ct has expired.')
700iAD tr09c           c                   const('Slot bypassed: Produ-
700iAD                                     ct does not meet customer e-
700iAD                                     piry days')
     D tr10            c                   const('Slot bypassed: No pr-
     D                                     oduct in slot.')
     D tr11            c                   const('Slot bypassed: No pr-
     D                                     oduct available in s-
     D                                     lot.')
     D tr12            c                   const('Warehouse allocation-
     D                                      completed with no e-
     D                                     rrors.')
     D tr13            c                   const('Warehouse allocation-
     D                                      complete with at le-
     D                                     ast one allocation e-
     D                                     xception.')
     D tr14            c                   const('No overflow slots me-
     D                                     t bulk pick criteria-
     D                                     .')
     D tr15            c                   const('Qty remaining not en-
     D                                     ough for bulk pick:')
     D tr16            c                   const('Slot bypassed: Short-
     D                                      qty for bulk pick.')
     D tr17            c                   const('No tie/high availabl-
     D                                     e. Available qty is -
     D                                     one full pallet.')
     D tr18            c                   const('Bulk pick created.')
     D tr19            c                   const('Looking for qty to b-
     D                                     ulk pick.')
     D tr20            c                   const('Key:')
     D tr21            c                   const('QtyAvail:')
     D tr22            c                   const('QtyPicked:')
     D tr23            c                   const('Ck slots w/same date')
413aA*  Allocation status messages.
     D trerfl          c                   const('*NOTFOUND')
     D tr80            c                   const('Allocated           ')
     D tr81            c                   const('Allocation error    ')
     *----------------------------------------------------------------
415aAD                 ds
415aAD  wkoitm                 1     15
415aAD  wkaisl                 1      3
415aAD  wkdsh1                 4      4
415aAD  wkloc                  5      7  0
415aAD  wkdsh2                 8      8
415aAD  wkrlvl                 9     10  0
415aAD  wkhand                11     12
415aAD  wkbulk                15     15

620dAD                 ds
620dAD  wopqndec               1     15  2
620dAD  dec                   14     15  0
CBIaA*
CBIaA*----------------------------------------------------------------
CBIaA*  Re-definition data structures
CBIdAD                 ds
CBIdAD  prdail                 8      8
CBIdAD  prdloc                 9     15
CBIdAD  odoitm                 1     15
CBInAD                 ds
CBInAD  itgwgt                 2      8  2
CBInAD  itrcvd                 1      8  0
CBInA*
     D digits          c                   const('0123456789')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
610bAD @getit          c                   const('GETITEMFLD')

650bAD @usrSpc         pr                  Extpgm('RPKUSRSPC')
650bAD   wh                           3  0
650bAD   item                        15
650bAD   cmd                          8
650bAD   rtn                          8
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
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
730kA /copy qcopysrc,c#pgminfds
730kDD*               sds
730kDD* #prog            *proc
730kDD* #job                 2b4    253
730kDD* #user                254    263
730kDD* #jobn                264    269
730kDD* #jobdt               276    281  0
730kDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
730gA /copy qcopysrc,c#stdvar
730hA /copy qcopysrc,c#stdsql

730hA *----------------------------------------------------------
730hA *  SQL record layouts referenced
730hA *----------------------------------------------------------

730hAD slrecdd       E Ds                  Extname(Slot) prefix(s_)

     *----------------------------------------------------------------
     *  Variables
     *

650bA*  Data Structure for Repack data elements
650bA*  Pointer to the auto-extending user space Repack array
650ba*     found in QTEMP/aryRPD
650baD ptrRPD          s               *
650ba*  Dynamically allocated array stored in the user space
650ba*   any element beginning with "aer" is for the Repack Item
650ba*   and "aep" are for repsective parent(s).  aeDelcd is a
650ba*   status code of line in item maintenance only and aearyrec
650ba*   is the array position of a certain record for item maint
650baD RepackData      ds                  based(ptrRPD)
650baD aryRPD                              dim(700)
650bad  aeritem                      15a   overlay(aryRPD:*next)
650baD  aedelcd                       1a   overlay(aryRPD:*next)
650baD  aepitem                      15a   overlay(aryRPD:*next)
650baD  aepdisp                      12a   overlay(aryRPD:*next)
650baD  aepqty1                       3p 0 overlay(aryRPD:*next)
650baD  aepum1                        2a   overlay(aryRPD:*next)
650baD  aepqty2                       3p 0 overlay(aryRPD:*next)
650baD  aepum2                        2a   overlay(aryRPD:*next)
650baD  aepqty3                       3p 0 overlay(aryRPD:*next)
650baD  aepum3                        2a   overlay(aryRPD:*next)
650baD  aerrptp                       1a   overlay(aryRPD:*next)
650baD  aerdisp                      12a   overlay(aryRPD:*next)
650baD  aerqty1                       3p 0 overlay(aryRPD:*next)
650baD  aerum1                        2a   overlay(aryRPD:*next)
650baD  aerqty2                       3p 0 overlay(aryRPD:*next)
650baD  aerum2                        2a   overlay(aryRPD:*next)
650bad  aesitpe                       1a   overlay(aryRPD:*next)
650baD  aerqty3                       3p 0 overlay(aryRPD:*next)
650baD  aerum3                        2a   overlay(aryRPD:*next)
650baD  aearyrec                      5  0 overlay(aryRPD:*next)

650fA*  array used to loop through ODR calling ODR to ultimately
650fA*  get to case item for stock
650fAD ODRData         ds
650fAD aryODR                              dim(100)
650fAd  nxtODR                       15a   overlay(aryODR:*next)
650fAd  savRitem                     15a   overlay(aryODR:*next)
650fAd  savKitq1                      5  0 overlay(aryODR:*next)
650fAd  savKitq2                      5  0 overlay(aryODR:*next)
650fAd  savKitq3                      5  0 overlay(aryODR:*next)
650fAd  savOutqty                     5  0 overlay(aryODR:*next)
650fAd  savRpkq2                      5  0 overlay(aryODR:*next)
650fAd  savRpkq3                      5  0 overlay(aryODR:*next)

520eAD #dbpck                         3  0
     D $msgf           s             10
     D #bitem          s                   like(ititem)
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #sitem          s                   like(ititem)
650fAD hld#sitem       s                   like(ititem)
730hAD dpck            s               n
730hAd sltcnt          s              5  0
730hAd ddFound         s               n
730hAd generateddrpl   s               n
650qAD addbackq1       s              5  0
750bAd autoSub         s               n
750bAd subItem         s             15
640bAD batchPickItem   s               n
640aAD batchPickQty1   s              5  0
     D blkpct          s                   like(#dbpck)
     D bppass          s              1  0
730hAd cmpItem         s             15
730bAd noBDwnRpkQty    s              5  0
FPR3AD ck4err          s               n
710fDD*c#cube          s                   like(itcube)
710fMD c#cube          s             11s 3 inz(0)
740 AD chkchild        s              1    inz('0')
CBIw D container       c                   const('CONTAINER')
     D cvt1a           s              1
     D cvt5a           s              5
     D cvt8a           s              8
     D diffq1          s                   like(odqor1)
     D diffq2          s                   like(odqor2)
     D diffq3          s                   like(odqor3)
     D dscln           s             80
     D eofod           s              1
     D eofoh           s              1
730gDD**rror           s              1
650fAD aryCnt          s              3  0
650fAD fwdCnt          s              3  0
     D excpq1          s              5  0
     D excpq2          s              5  0
     D excpq3          s              5  0
650fAD outPutQty       s              5  0
     D flgpck          s              1
     D flgtrk          s              1
650nAD forceCustAlloc  s               n
730gDD**orever         s               n
650bAD aryBck          s             92    dim(700)
     D forevr          s              1
730gDD**ound           s              1
     D hmaisl          s                   like(slaisl)
     D hmdisp          s                   like(sldisp)
     D hmhand          s                   like(slhand)
     D hmloc           s                   like(slloc)
     D hmrlvl          s                   like(slrlvl)
     D hmstyp          s                   like(slstyp)
     D hmwhdp          s                   like(slwhdp)
     D hmwhse          s                   like(slwhse)
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opzcod)
     D kyentd          s                   like(slentd)
     D kyexpd          s                   like(slexpd)
     D kyhand          s                   like(slhand)
     D kyopen          s              1
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D kypseq          s                   like(slpseq)
     D kyrlvl          s                   like(slrlvl)
     D kyslvp          s                   like(sldisp)
JOR AD kyspcl          s                   like(odspcl)
     D kystat          s                   like(slstat)
     D kystyp          s                   like(slstyp)
     D kyum            s                   like(idum)
     D kywhdp          s                   like(slwhdp)
640eAD lcns            s                   like($saToLcns)
650bAD prqtyn          s              5  0
     D leftq1          s              5  0
     D leftq2          s              5  0
     D leftq3          s              5  0
CBInAD loc             s              3
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstopt          s              2  0
     D lstqty          s                   like(odqor1)
     D lstwhs          s                   like($whse)
CBInAD lvl             s              2
CBInAD lvl1            s              1
     D lwlas2          s              3
     D lwlqav          s              5  0
     D lwltyp          s              1
     D mjkcon          s              1
650aDD*mjkpir          s              1
650aMD mjkpir          s              1    inz('0')
     D nonalc          s              1
HMWaAD NOSRSlot        s               n
CBIvAD ocadisp         s                   like(sldisp)
CBIvAD ocastop         s              3
     D ocode           s              8
     D odflag          s              1
     D ohflag          s              1
     D opened          s              1
     D opndm           s              1
750eAd ordOrg1         s                   like(odqor1)
750eAd ordOrg2         s                   like(odqor2)
750eAd ordOrg3         s                   like(odqor3)
     D pckall          s              1
     D pckcnt          s              3  0
700fAD pckcnteach      s              3  0
CLDdAD pckcmd          s              8
     D pickq1          s              5  0
     D pickq2          s              5  0
     D pickq3          s              5  0
     D pr              s              3  0
     D picku1          s              5  0
     D picku2          s              5  0
     D picku3          s              5  0
620aAD hasPrepick      s               n
700aAD hasAMPpick      s               n
     D prflag          s              1
650qAD pristine        s               n
     D qtylft          s                   like(odqor1)
620fAD qtyToMake       s              5  0
650bAd loop            s              3  0
650bAd pcmd            s              8
650bAd pitem           s             15
650nAd prdSlot         s             12
650bAd prtn            s              8
     D r               s              3  0
     D remain          s              5  0
650qAD savekypick      s                   like(slpick)
530 AD savdisp         s                   like(sldisp)
CLDcAD savdsp          s                   like(sldisp)
CLDcAD savloc          s                   like(slloc)
710bAD savDays         s                   like(ceddays)
710bAD savDist         s                   like(ceddist)
710bAD savPriority     s              1  0
CLDdAD savqy1          s              7  0
CLDdAD savqy2          s              7  0
CLDdAD savqy3          s              7  0
650nAD tpsltqty1       s              7  0
650nAD tavail1         s              7  0
650nAD tavail2         s              7  0
650nAD tavail3         s              7  0
650nAD rmavail1        s              7  0
650nAD rmavail2        s              7  0
650nAD rmavail3        s              7  0
750cAD newQty1         s              7  0
750cAD newQty2         s              7  0
750cAD newQty3         s              7  0
     D s#cube          s                   like(itcube)
SGCbAD sgcbulk         s              1    inz('0')
710gAD slotfound       s              4    inz('*NO ')
     D stop            s              1
     D svaisl          s                   like(slaisl)
     D svavl1          s                   like(avail1)
     D svavl2          s                   like(avail2)
     D svavl3          s                   like(avail3)
     D svdisp          s                   like(sldisp)
730hAD dropDisp        s                   like(sldisp)
     D svhand          s                   like(slhand)
     D svloc           s                   like(slloc)
     D svpseq          s                   like(slpseq)
     D svqty2          s              5  0
     D svrlvl          s                   like(slrlvl)
     D svrtq1          s                   like($artq1)
     D svrtq2          s                   like($artq2)
     D svrtq3          s                   like($artq3)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
720dAd storeSlot       s               n
720dAd storeQty        s               n
720dAD spckcnt         s              3  0
720dAD ssvpseq         s                   like(slpseq)
720dAD ssvdisp         s                   like(sldisp)
720dAD ssvhand         s                   like(slhand)
720dAD ssvrlvl         s                   like(slrlvl)
720dAD ssvloc          s                   like(slloc)
720dAD ssvaisl         s                   like(slaisl)
720dAD ssvstyp         s                   like(slstyp)
720dAD ssvwhdp         s                   like(slwhdp)
720dAD ssvwhse         s                   like(slwhse)
     D temp2a          s              2
     D temp30          s             30
     D tmavl1          s                   like(avail1)
     D tmavl2          s                   like(avail2)
     D tmavl3          s                   like(avail3)
     D tmpflg          s              1
     D today           s              8  0
     D topick          s                   like(odqor1)
     D trerr           s              1
     D tried           s              1
     D trkey           s             10
     D trnbr           s              4
     D trsq10          s              3  0
     D trsq40          s              3  0
650xD *trsq50          s              3  0
650xMD trsq50          s              4  0
     D trsubr          s              6
     D ttlpk1          s              5  0
     D ttlpk2          s              5  0
     D ttlpk3          s              5  0
     D updflg          s             10
     D uxflag          s              1
     D xopt            s              2  0
520eDD*zone            s                   like(zdzone)
730hAD readprior       s               n
650fAD odrForceAlc     s               n
650fAD odrOrigSlt      s                   like(kidisp)
650fAD odrplus         s              5  0
650fAD odrPreviousQty  s              5  0
650fAD odrBldNeeded    s               n   inz('0')
610bAD odrbaseslot     s             12
650nAd pSessId         s             40
610bAD odrbasewhdp     s              5
650fAD hldQtyMake      s              5  0
610bAD FirstRecd       s               n
610bAD odrslot         s             12
650dAD lstodritm       s             15
650dAD odrppick        s             12
650eAD odrrpick        s             12
650eAD odrMinusq1      s              5  0
650eAD odrMinusq2      s              5  0
650eAD odrMinusq3      s              5  0
720dAd whStk1          s              5  0
720dAd whStk2          s              5  0
720dAd whStk3          s              5  0
650dAD frmzzGetCase    s               n
650fADonDmdcallsonDmd  s               n
650fADonDmdHold        s               n
610bAD drierr          s               n
610bAD chk4err         s               n
610bAD zmsflag         s               n
610bAD odritemflag     s               n
610bAD #odrpckavl      s                   like($iqavl1)
610bAD #odrovravl      s                   like($iqavl1)
610bAD #odriqavl1      s                   like($iqavl1)
610bAD #odriqavl2      s                   like($iqavl2)
610bAD #odriqavl3      s                   like($iqavl3)
610bAD #basiqavl1      s                   like($iqavl1)
610bAD #basiqavl2      s                   like($iqavl2)
610bAD #basiqavl3      s                   like($iqavl3)
610bAD odrbaseitem     s             15
610bAD odritem         s             15
610bAD #odrslavl1      s                   like($slavl1)
530aAD $ptmpl          s             10
620bAD $scmd           s              8
620bAD $swhse          s              3  0
620bAD $srtid          s              5
620bAD $sord           s              7  0
620bAD $sdstp          s              2  0
620bAD $sstp           s              5  0
740eDD*wopqn1          s              3  0
740eAD*wopqn2          s              3  0
740eAD*wopqn3          s              3  0
740eAD wopqn1          s              5  0
740eAD wopqn2          s              5  0
740eAD wopqn3          s              5  0
650nAd woqty           s                   like(leftq1)
700iAD hasCustDays     s               n
700iAD expDate         s              8  0
730kAD pNextLbl#       s             11  0
730kAd nextLbl#        s                   like(lwlbl#)
740gAD wwloc           s              3s 0
740gAD wwrtn           s             10
740gAD wwmsg           s             99    varying
740gAD wwwhse          s              3s 0

650nA*----------------------------------------------------------------
650nA*  Production Work Order Data Structure
650nA*----------------------------------------------------------------
650nAD wkwo#           ds
650nAD  wkwodate               1      8
650nAD  wkwoseq                9     13  0

710bA*----------------------------------------------------------------
710bA*  Prototypes
710bA*----------------------------------------------------------------
710bA
710bA /copy qcopysrc,p.getitmfl
730gA /copy qcopysrc,p.umordd
730gA /copy qcopysrc,p.umworklb
730kA /copy qcopysrc,p.pirlbl#w
740gA /copy qcopysrc,p.wwtfr
750bA /copy qcopysrc,p.exitemsb

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PICK    - Picking new orders.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PPRG   Program to send messages back to.
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PRTE   Route
     *      $PORD   Order
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
      *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $pord             7 0
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
417zA*
417zA* Get client id.
417zA*
500 D**         *NAMVAR   DEFN PIRCLIENT CLIENT 10
500 D**                   IN   CLIENT
500 AC                   call      @getcl
500 AC                   parm                    client           10
710eAC                   parm                    clientloc        10
650bA*
650bAc                   exsr      zzUserSpace
730hAc                   exsr      chkZstat
417zA*
     C                   eval      $prtn = *blanks
VIP1A*
640bDC**                 eval      opndm = *off
640bDC**                 if        client = vip  or
640bDC**                           client = mjkeln or
640bDC**                           client = SGC
640bDC**                           or client = Savalfoods
640bDC**                 if        opndm = *off
640bDC**                 open      orddm
640bDC**                 eval      opndm = *on
640bDC**                 endif
640bDC**                 endif
DRKaA
DRKaA* Dierks - Temporarily force Letdowns only.
DRKaA
DRKaAC                   if           client = dierks
DRKaAC                   eval         opjitr = '1'
DRKaAC                   endif
MJKaA*
MJKaA*   Set MJK Contract flag.
MJKaA*
MJKaAC                   eval      mjkcon = *off
MJKaAC                   if        client = mjkeln
MJKeDC*                  movel     $prte         temp2a
MJKeAC*
MJKfDC*    KEYOH2        SETLL     ORDH2
MJKfDC*    KEYOH2        READE(N)  ORDH2                                  79
MJKeDC*                  if        temp2a = 'CC'
MJKfDC*                  if        hdivn = '  1'
MJKfDC*                  eval      mjkcon = *on
MJKfDC*                  endif
MJKaAC                   endif
     *
415aA*  The program will execute CRTLBL only if UPDFLG is set to
415aA*  '*NOUPDAT'.  This flag should be custom set if the client
415aA*  wants to use truck builder without allocating qty on BFC side.
     *
415aAC                   eval      updflg = *blanks
415aAC                   if        updflg = '*NOUPDAT'
415aAC                   exsr      crtlbl
650bAC                   exsr      zzdltusrspc
415aAC                   eval      *inlr = *on
415aAC                   return
415aAC                   endif
     *
415 A*
415 A* Open printer
415 A*
415 AC                   exsr      opnprt
750aA /free
750aA    // if super route, flip children order types to blank beyond open orders
750aA    if %subst($pRte:1:3) = '#SR';
750aA      // Flip ohtype to blank for Super Route children orders.  Will flip
750aA      // back in RH134 if Super Route undone
750aA      setll ($pWhse:$pRtid) srord;
750aA      dow forevr = forevr;
750aA        reade ($pWhse:$pRtid) srord;
750aA        if %eof(srord) or not %equal(srord);
750aA          leave;
750aA        endif;
750aA        chain (srowhs:sromordid) ordh;
750aA        if %found(ordh);
750aA          sr_ohtype = *blanks;
750aA          update ohrecsr;
750aA        endif;
750aA      enddo;
750aA    endif;
750aA /end-free
     *
     * Loop through orders for the batch.
     *
     C                   eval      prflag = *off
     C                   eval      ohflag = *off
     C                   eval      eofoh = *off
     C                   dou       eofoh = *on
     C                   exsr      getoh
700jAC     eofoh         cabeq     *on           endoh
     *
700aA*  See if this is an earlier AMP customer order.
700aA*      first allow getoh so we have ohcord value
700aA*  still looking only at whse, ohcord-could be an Add-on if AMP qty=0
700aA*
700aAC                   eval      hasAMPpick = *off
700aAC     keyAMPX1      chain     ampxref1                           79
700aAC                   if        not *in79
700aAC                   eval      hasAMPpick = *on
700aAC                   endif
700aAC*
700jDC*    eofoh         cabeq     *on           endoh
MJKfAC*
MJKfAC*   Set MJK Contract flag.
MJKfAC*
MJKfAC                   move      *off          mjkcon            1
MJKfAC                   if        client = MJKellner
MJKfAC*
MJKfAC                   if        hdivn  = '  1'
MJKfAC                   eval      mjkcon = '1'
MJKfAC                   endif
MJKfAC*
MJKfAC                   endif
     *
     *    Loop through detail records for order.
     *
     C                   eval      odflag = *off
     C                   eval      eofod = *off
     C                   dou       eofod = *on
     C                   exsr      getod
     C     eofod         cabeq     *on           endod
VIP A*
VIP A*       Non-stock item, skip FS-WMS allocation.
VIP AC     nonalc        cabeq     *on           endod
     *
410 A*       Initialize exception quantity fields.
     *
410 AC                   eval      excpq1 = 0
410 AC                   eval      excpq2 = 0
410 AC                   eval      excpq3 = 0
750bA*
750bA*   if auto substitutions are allowed we need to see if
750bA*   this item should be substituted based on whether ordered
750bA*   item has stock to fill the order or whether sub fills the
750bA*   the order
750bA*
750bA /free
750bA                    autoSub = *off;
750bA                    if opsauto = 'Y' and odoitm=*blanks;
750bA                       // if sub exist for this item delete and then
750bA                       // reprocess
750bA                       exec sql delete from ordd
750bA                             where odwhse=:odwhse and odord=:odord
750bA                               and odoitm=:oditem and odor2=:odseq;
750bA                       autoSub = KeepOrSub(ohrte:ohord:oditem:odseq
750bA                                 :odqor1:odqor2:odqor3);
750bA                      if autoSub;
750bA                        // if auto sub was generated we will simply skip the originally
750bA                        // originally ordered item and then sub will allocate later
750bA                        // in this loop.  We decided not to generate an out label in
750bA                        // fear a selector could pick both original and sub item
750bA                        p1msg = 'sub with item ' + %trim(subItem);
750bA                        exsr prterr;
750bA                        iter;
750bA                      endif;
750bA                    endif;
750bA /end-free
620eA
620eA*   If Pre-pick, allocate qty from PRE slots.
650aA*     and order cannot be marked as a prepick order.
620eA
620eAC                   if        hasPrepick
650oAC                             and %subst(ohmisc:17:1) <> 'Y'
620eAC                   exsr      pickPRE
620eA
620eA*     If all qty allocated, update detail rec and loop.
620eA*     Otherwise, allocate remaining qty normally.
620eA
620eAC                   if        leftq1=0 and leftq2=0 and leftq3=0
620eAC                   eval      odstat = 'P'
620eAC                   update    odrec
620eAC                   iter
620eAC                   endif
620eA
620eAC                   endif

700aA*   If AMP-pick, allocate qty from AMP slots.
700aA*     and order cannot be marked as a AMPpick order.
700aA*     1st using rtid, check ordhm to see if this is AMP too
700aA*
700aAC                   eval      hmmsc4 = *blanks
700aAC     keyAMPx1b     chain     ordhm                              79
700aA*
700aAC                   if        hasAMPpick
700aAC                             and %subst(hmmsc4:13:1) <> 'Y'
700aAC                   exsr      pickAMP
700aA
700aA*     If all qty allocated, update detail rec and loop.
700aA*     Otherwise, allocate remaining qty normally.
700aA
700aAC                   if        leftq1=0 and leftq2=0 and leftq3=0
700aAC                   eval      odstat = 'P'
700aAC                   update    odrec
700aAC                   iter
700aAC                   endif
700aA
700aAC                   endif
610bA*
610bA*       Check 4 On demand Repack item
610bA*
650bA*  call zzCrtOdrQty from PrcRepack routine
650bDC*                  if        odritemflag
650bDC*                  exsr      ZZCrtOdrQty
650bDC*                  endif
650bAc                   if        ittype = 'R'
650bAc                   exsr      zzPrcRepack
650bAc                   endif
HMWaA /free
HMWaA   // check for the SR status slot
HMWaA   NOSRSlot = *off;
HMWaA   if client = HMWagner
HMWbD   // and odspcl = 'SR'
HMWaA      and $potyp = 'W';
HMWbD   //setll ($pwhse: #sitem: odspcl) slot3;
HMWbM     setll ($pwhse: #sitem: 'SR') slot3;
HMWaA     if %equal(slot3);
HMWbD       odspcl = 'SR';
HMWaA     else;
HMWaA       NOSRSlot = *on;
HMWaA     endif;
HMWaA   endif;
HMWaA /end-free
750dMc                   exsr      drppck
650nA*
650nA*       Check to see if this is a production item
650nA*
650nA /free
               // on Chefs Production box we have remarked out
               // chain below and forced blanks to IPPRDFLG until
               // better code in place to prevent PICKPRD routine
               // from running.  Once better code in place it
               // should be replaced with what is done in this version
650nA                    chain ($pwhse:oditem) itemPrd;
650nA /end-free
650nAc                   if        not %found(itemPrd)
650nAc                   eval      ipprdflg = ' '
650nAc                   endif
710gA*
710gA*     Look for item in any active whse slots. If none found, then
710gA*     create XDK slot to direct selector to pick item.
720cAc                   if        ipprdflg <> 'F'
710gAC                   exsr      zzchkslot
CBIxA*
CBIxAC                   if        client = Cheney
CBIxAC                             and slotfound = '*NO'
CBIxA*       Force pgm indicate slot found so that NO XDK is created.
CBIxAC                   eval      slotfound = '*YES'
CBIxAC                   endif
CLDfA*
CLDfAC                   if        client = cityln
CLDfAC                             and itstyp = 'P'
CLDfA*       Force pgm indicate slot found so that NO XDK is created.
CLDfAC                   eval      slotfound = '*YES'
CLDfAC                   endif
710gA*
710gA*     No slots found and print exception labels is on.
710gAC                   if            opelbl     = 'Y'
710gAC                             and slotfound = '*NO '
CWDbAC                             and (client <> CashWa)
710gAC                   exsr      zzcrxd
710gA*
710gA*      XDK slot on file or created, so update order to use it.
710gAC                   if           $drireturn = '*OK'
710gAC                             or $drireturn = 'XDKEXIST'
JOR A*
JOR AC                   if        client = Jordanos
TPCbAC                             or client = TPC
JOR A*     Flag items with XE when no slot found so off-setting
JOR A*     adjustment can be created at closing time.
JOR AC                   evaL      odspcl = 'XE'
JOR AC                   else
JOR A*
710gAC                   evaL      odspcl = 'XD'
JOR AC                   endif
JOR A*
710gAC                   endif
720cAC                   endif
710gA*
710gAC                   endif
720aA*
720aA*       If set to use Staging Replenishment check to see if item pick slot
720aA*       lives in remote location outside warehouse such as company Store
720aA*       If opsslcn set to 'Y' in REPLEN settings call getStrZ which looks
720aA*       for pick slot in Store Zone and sets $zdStgFlg='Y'
720aA*
720aAc                   eval      $zdStgFlg='N'
720dDc*                  if        opssLcn = 'Y'
730aDc*                  if        opssLcn = 'Y' and ohType='W'
730aDc*                  exsr      getStrZ
730aDc*                  endif
     *
     *       Do general allocation first (except for special orders).
     *
750dDc*                  exsr      drppck
     C                   if        odspcl = *blanks
650nAc                             and ipPrdFlg <> 'F'
700kAc                             or odspcl = *blanks
700kAc                             and opalccopa <> 'Y'
HMWaAc                             or NOSRSlot = *on
730aAc*                  if        $zdStgFlg='Y' and ohtype='W'
730aAc*                  else
730hAc                   if        not dPck
     C                   exsr      alloc
730hAc                   endif
730aDc*                  endif
     C                   endif
     *
     *       Then allocate from slots.
     *
520bAC                   eval      pckall = *off
520bA*
410bD*          LEFTQ1    IFGT 0
410bD*          LEFTQ2    ORGT 0
410bD*          LEFTQ3    ORGT 0
     *
     *
700kA* replaced with Select statement
700kA /free
740cA   if dPck;
740cA     exsr pickdd;
740cA   endif;
740cA
740cA   // Do normal allocation/pick if not Drop Pick or
740cA   // Drop Pick but no matching Drop Pick config from pickdd
740cA   if (dPck and
740cA      (leftq1>0 or leftq2>0 or leftq3>0)) or not dPck;
700kA     Select;
740cD     //when dPck;
740cD       //exsr pickdd;
700kA       when ipPrdFlg = 'F' and opalccopa = 'Y';
700kA         exsr pickprd;
HMWaA       when NOSRSlot = *on;
HMWkA         exsr pickf2;
700kA       when odspcl = 'XD'
730fA         or odspcl = 'XE';
700kA         exsr pickxd;
700kA       when odspcl <> '  ';
700kA         exsr picks;
700kA       when itstyp  = 'P';
700kA         exsr pickp;
700kA       other;
700kA         exsr pickf2;
700kA     endsl;
740cA   endif;
700kA /end-free
700kDc*    ipPrdFlg      caseq     'F'           pickprd
700kDC*    odspcl        caseq     'XD'          pickxd
700kDC*    odspcl        casne     *blanks       picks
700kDC*    itstyp        caseq     'P'           pickp
700kDC*                  cas                     pickf2
700kDC*                  endcs
     *
     *       Update detail record with allocated quantities.
     *
     C                   eval      odstat = 'P'
     *                    Z-ADDTTLPK1    ODQPK1
     *                    Z-ADDTTLPK2    ODQPK2
     *                    Z-ADDTTLPK3    ODQPK3
     C                   update    odrec
     *
     C     endod         tag
     C                   enddo
     *
     *    Update header record.
     *
     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohpbat = $pbat
     C                   update    ohrec
     *
     C     endoh         tag
     C                   enddo
     *
     * Close up shop and return home.
     *
     C     endpgm        tag
     C                   if        prflag = *on
     C                   write     foot1
WSFdA *
WSFdA *   Send another copy of report
WSFdA *
WSFdAC                   if        client = westside
WSFdAC                             and $potyp <> 'W'
WSFdAC                   move      *blanks       $loutq
WSFeDC*                  movel     'P6'          $loutq
WSFeMC                   movel     'WSFBFCRPT '  $loutq
WSFdA*
415 D**                 EXSR      DUPPRT
WSFdMC                   exsr      dupprt
WSFdAC                   endif
     C                   endif
413aA*
413aA*  Write out completion message.
413aA*
413aAC                   select
413aAC                   when      $pcmd <> '*OPEN'
413aAC                   if        trerr = *on
413aAC                   eval      trnbr = 'TR13'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'MAINLN  '    trsr50
413aAC                   exsr      zztrck
413aAC                   else
413aAC                   eval      trnbr = 'TR12'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'MAINLN  '    trsr50
413aAC                   exsr      zztrck
413aAC                   endif
413aA*
413aA*  Write out tracking record, force out contents of array.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'EXIT    '    trsubr
413aAC                   eval      r = 32
413aAC                   exsr      zztrck
413aA*
413aA*    Write out tracking record *PCK001.
413aA*
413aAC                   eval      trcode = '*PCK001 '
413aAC                   exsr      zztrck
413aAC                   endsl

610bA*   Do some clean up before leaving.

650bAC                   exsr      zzdltusrspc
610bAC                   exsr      zzzdriclose
413aA*
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
      /free
750bA      // Session Id used when calling Substitution process for Auto Subs
750bA            pSessId = 'OR610' + %char(#job) + %char(%timestamp());
      /end-free
413aA*
413aA*  Initialize tracking key.
413aA*
413aAC                   eval      trwhse = $pwhse
413aAC                   movel(p)  #prog         trpgm
413aAC                   eval      trjbnr = #jobn
413aAC                   eval      $cvcmd = '*MDYCMD '
730kMC                   move      #jobdate      $cvd6i
413aAC                   eval      $cvd8o = *zeros
413aAC                   call      @cvtdt
413aAC                   parm                    $cvtdt
413aAC                   eval      trjbdt = $cvd8o
730kMC                   eval      trjbtm = #jobtime
413aAC                   eval      trdev = #job
413aAC                   eval      truser = #user
413aAC                   eval      trtruk = $ptruk
413aAC                   eval      trrte = $prte
413aAC                   eval      trrtid = $prtid
413aAC                   eval      trpbat = $pbat
413aAC                   eval      r = *zeros
413aAC                   eval      trsubr = *blanks
413aAC                   eval      trkey = *blanks
413aAC                   eval      trrfld = *blanks
413aAC                   eval      trsq10 = *zeros
413aAC                   eval      trsq40 = *zeros
413aAC                   eval      trsq50 = *zeros
413aAC                   eval      trnbr = *blanks
413aAC                   eval      cvt1a = *blanks
413aAC                   eval      cvt5a = *blanks
413aAC                   eval      cvt8a = *blanks
413aAC                   eval      trkey = *blanks
413aAC                   eval      trerr = *off
413aAC                   eval      flgpck = *off
413aAC                   eval      flgtrk = *off
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     '*INZSR  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      kyopen = 'O'
411 A*
411 A*  Define save fields for different item types.
411 A*
411 AC                   eval      #otype = *blanks
650eA*
650eA*   Get default values for the user.
650eA*
650eAC                   call      'GETUSER'
650eAC                   parm                    #user
650eAC                   parm      0             #whse             3 0
650eAC                   parm      0             #emp#             5 0
650eAC                   parm                    #fnam            15
650eAC                   parm                    #init             1
650eAC                   parm                    #lnam            20
650eAC                   parm                    #whdp             5
650eAC                   parm                    #styp             1
650eAC                   parm                    #shft             6
650eAC                   parm                    #crew             6
650eAC                   parm      0             #nhrs             3 1
650eAC                   parm                    #rtn              8
650nA*
650nA*  Define a unique Session for Production routines
650nA*
650nAc                   eval      pSessId = %trim('OR610' +
650nAc                             %char(%date():*iso0) +
650nAc                             %char(%time():*hms0))
     *
404 A*  Define key for CROSSDK1 file.
     *
414cA*
414cA*     OPTIONS
414cA*
414cAC     opkey         klist
414cAC                   kfld                    $pwhse
414cAC                   kfld                    ocode
414cA*
414cA*     EXTENDED ITEM DESCRIPTION
414cA*
414cAC     idkey         klist
414cAC                   kfld                    $pwhse
414cAC                   kfld                    ititem
     *
404 AC     keycd1        klist
404 AC                   kfld                    odwhse
404 AC                   kfld                    odord
404 AC                   kfld                    odseq
     *
     *  Define partial key for ORDH2 file.
     *
     C     keyoh2        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyopen
     C                   kfld                    $potyp
     C                   kfld                    $prtid
     *
     *  Define partial key for ORDD1 file.
     *
     C     keyod1        klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C                   kfld                    kyopen
VIP1A*
VIP1A*  Define partial key for ORDDM file.
VIP1A*
VIP1AC     keyom         klist
VIP1AC                   kfld                    $pwhse
VIP1AC                   kfld                    ohord
VIP1AC                   kfld                    odseq
VIP1AC                   kfld                    oditem
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     *
     *  Define partial key for ITEMDEF1 file.
     *
     C     keyid1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     C                   kfld                    kyum
     C                   eval      kyum = 'N'
     *
     *  Define key for ITEMDEF1 file.
     *
     C     keydef        klist
     C                   kfld                    $pwhse
520aD**                   KFLD           ODITEM
520aMC                   kfld                    #sitem
     C                   kfld                    kyum
     C                   kfld                    slsdef
     *
404 A*  Define key for SLOT2 file.
     *
610dDC*****keysl2        klist
610dDC*****              kfld                    cdwhse
610dDC*****              kfld                    cdwhdp
610dDC*****              kfld                    cdslot
610dAC     keys10        klist
610dAC                   kfld                    odwhse
650gDC*                  kfld                    oditem
650gMC                   kfld                    #sitem
JOR DC*                  kfld                    odspcl
JOR MC                   kfld                    kyspcl
     *
620aAC     keysl2a       klist
620aAC                   kfld                    pxwhse
620aAC                   kfld                    pxsdep
620aAC                   kfld                    pxdisp
     *
700aAC     keysl2b       klist
700aAC                   kfld                    axwhse
700aAC                   kfld                    axawhdp
700aAC                   kfld                    axadisp
     *
VIP AC     vipsl2        klist
VIP AC                   kfld                    omwhse
VIP AC                   kfld                    omwhdp
VIP AC                   kfld                    kyslvp
     *
610bAC     keysl2v       klist
610bAC                   kfld                    vswhse
610bAC                   kfld                    vswhdp
610bAC                   kfld                    vsdisp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
411 D*R                   KFLD           ODITEM
417cD**                   KFLD           #BITEM
417cMC                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define partial key for SLOT3 file including dates.
     *
     C     keys3b        klist
     C                   kfld                    $pwhse
411 D*R                   KFLD           ODITEM
417cD**                   KFLD           #BITEM
417cMC                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     *
     *  Define full key for SLOT3 file.
     *
     C     keys3c        klist
     C                   kfld                    $pwhse
411 D*R                   KFLD           ODITEM
417cD**                   KFLD           #BITEM
417cMC                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     C                   kfld                    kywhdp
     C                   kfld                    kystyp
     C                   kfld                    kyaisl
     C                   kfld                    kypseq
     C                   kfld                    kyrlvl
     C                   kfld                    kyhand
     *
     *  Define partial key for SLOT3 file for special orders.
     *
     C     keyspc        klist
     C                   kfld                    $pwhse
411 D*R                   KFLD           ODITEM
417cD**                   KFLD           #BITEM
417cMC                   kfld                    #sitem
     C                   kfld                    kystat
     *
410 A*  Define partial key for OPTIONS file.
     *
410 AC     keyop         klist
410 AC                   kfld                    $pwhse
410 AC                   kfld                    opcode
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530aA ***                kfld                    $ptruk
530aAC                   kfld                    $ptmpl
     *
     *  Define key for truck file.
     *
     C     keyth         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
     *  Define key for zone detail search file.
     *
     C     keyzd2        klist
     C                   kfld                    $pwhse
530aA ***                kfld                    $ptruk
530aAC                   kfld                    $ptmpl
530aAC                   kfld                    itwhdp
MJKcA*
MJKcA*  Define key for ITEMMSC file.
MJKcA*
MJKcAC     keyim         klist
MJKcAC                   kfld                    $pwhse
MJKcAC                   kfld                    #sitem
6JKcA*
620aA*  Define partial key for PREXREF1 file.
620aA*
620aAC     keyPREX1      klist
620aAC                   kfld                    $pwhse
620aAC                   kfld                    $prte
700cA*
700aA*  Define partial key for AMPXREF1 file.
700aA*
700aAC     keyAMPX1      klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    ohcord
     *
620aA*  Define partial key for PREXREF1 file.
620aA*
620aAC     keyPREX1a     klist
620aAC                   kfld                    $pwhse
620aAC                   kfld                    $prte
620aAC                   kfld                    ohcord
620aAC                   kfld                    oditem
620aAC                   kfld                    itwhdp
     *
700aA*  Define partial key for AMPXREF1 file.
700aA*
700aAC     keyAMPX1a     klist
700aAC                   kfld                    $pwhse
700aAC***                kfld      **            $prte
700aAC                   kfld                    ohcord
700aAC                   kfld                    oditem
700aAC                   kfld                    itwhdp
700aA*
700aA *  Define partial key for ORDHM file - to get misc field 4
700aA*
700aAC     keyAMPX1b     klist
700aAC                   kfld                    $pwhse
700aAC                   kfld                    ohord
     *
610bA*  See if item is in virtual slot.
610bA*
610bAC     keyvs2l4      klist
610bAC                   kfld                    $pwhse
610bAC                   kfld                    itwhdp
610bAC                   kfld                    $gODRSlot

620dA*  Define key for KITCOMP file.

620dAC     keykc         klist
620dAC                   kfld                    $pwhse
620dAC                   kfld                    odritem

     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
412 AC                   eval      pckcnt = 0
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Create report heading.
     *
     *    Start with batch number ...
     *
413cAC                   time                    time
     C                   move      $pbat         temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd             8
     C                   parm                    temp30
     C     'BATCH:'      cat       temp30:1      hedln2
     *
     *    Then add warehouse ...
     *
     C     hedln2        cat       'WARE':2      hedln2
     C     hedln2        cat       'HOUSE:':0    hedln2
     C                   eval      temp30 = *blanks
     C                   move      $pwhse        temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd
     C                   parm                    temp30
     C     hedln2        cat       temp30:1      hedln2
     *
     *    Finish with route.
     *
     C     hedln2        cat       'ROUTE:':2    hedln2
     C     hedln2        cat       $prte:1       hedln2
     *
     *    Center it so it will look pretty.
     *
     C                   call      'CENTER'
     C                   parm                    hedln2
     C                   parm      60            $clen             3 0
700kA*
700kA*    Get production options from options file.
700kA*
700kA /free
700kA   chain ($pwhse: '*PROD') options;
700kA   if %found(options);
700kA     opdta3 = opdata;
700kA   else;
700kA     opalccopa = 'N';
700kA     opcrtwo   = 'N';
700kA   endif;
700kA /end-free

720aA*
720aA*    Get *REPLEN options from options file.
720aA*
720aA /free
720aA   chain ($pwhse: '*REPLEN') options;
720aA   if %found(options);
720aA     opdta4 = opdata;
720aA   else;
720aA     opsslcn = 'N';
720aA   endif;

700kA /end-free
     *
410 A*    Get general picking options from options file.
     *
410 AC                   eval      opcode = '*GENPICK'
410 AC     keyop         chain     options                            79
414cAC                   eval      opdta1 = opdata
410 AC                   if        *in79
410 AC                   eval      operpt = 'Y'
410 AC                   eval      opelbl = 'N'
414aAC                   eval      ophpwc = 'N'
500dD*                    MOVE 'R'       OPJITR
500dMC                   eval      opjitr = '2'
413aAC                   eval      flgpck = *on
410 AC                   endif
600aA
600aA* No longer allowing Letdowns. Adjust option accordingly.
600aA
600aAC                   select
600aAC                   when         opjitr = '1'
600aAC                   eval         opjitr = '2'
600aAC                   when         opjitr = '3'
600aAC                   eval         opjitr = '4'
600aAC                   endsl
DRKaA
DRKaA* Dierks - Temporarily force Letdowns only.
DRKaA
DRKaAC                   if           client = dierks
DRKaAC                   eval         opjitr = '1'
DRKaAC                   endif
520eDC**
520eDC**   Get zone options and save in data structure.
520eDC**
520eDC**                 eval      kycode = '*PICK   '
520eDC**   keyopz        setll     optionz
520eDC**                 eval      lstopt = 0
520eDC**                 dou       forevr <> forevr
520eDC**   keyopz        reade     optionz                                79
520eDC**                 if        *in79
520eDC**                 leave
520eDC**                 endif
520eDC**
520eDC**      Save options in data structure.
520eDC**
520eDC**                 add       1             lstopt
520eDC**   lstopt        occur     opts
520eDC**                 eval      #dzone = opzzon
520eDC**                 eval      #dbpck = opbpck
520eDC**
520eDC** Write out tracking record.
520eDC**
520eDC**                 eval      trcode = '*PCK010 '
520eDC**                 exsr      zztrck
520eDC**
520eDC**                 enddo
520eDC**
520eDC**      Initialize a "catch all" default.
520eDC**
520eDC**                 add       1             lstopt
520eDC**   lstopt        occur     opts
520eDC**                 eval      #dzone = *blanks
520eDC**                 eval      #dbpck = 999
640fAC*
640fAC*       Initialize DEF's data structure fields.
640fAC     1             do        9             lstopt
640fAC     lstopt        occur     defs
640fAC                   eval      dstie  = 0
640fAC                   eval      dshigh = 0
640fAC                   eval      dsqmax = 0
640fAC                   eval      dsqmin = 0
640fAC                   enddo
     *
     *    Get truck information.
     *
     C     keyth         chain     truckh                             79
     C                   if        *in79
     C                   eval      thbulk = 'N'
413aAC                   eval      flgtrk = *on
     C                   endif
     *
530aAC                   if        %found(truckh)
530aAC                             and thtype = 'T'
530aAC                   eval      $ptmpl = thztmp
530aAC                   else
530aAC                   eval      $ptmpl = $ptruk
530aAC                   endif
     *
620aA*  See if this is a Pre-pick route.
620aA*
620aAC                   eval      hasPrepick = *off
620aAC     keyPREX1      chain     prexref1                           79
620aAC                   if        not *in79
620aAC                   eval      hasPrepick = *on
620aAC                   endif
     *
700aA*  See if this is an earlier AMP customer order
700aA*      this check moved to getoh so I have the ohcord
     *
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK002 '
413aAC                   exsr      zztrck
413aAC                   eval      trcode = '*PCK003 '
413aAC                   exsr      zztrck
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ALLOC   Allocate item from ITEMQTY file.
     *
411 A*    Revised to allocate from Base item when item ordered
411 A*    is an Alias or Same Slot Breakdown item.
     *
     C     alloc         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'ALLOC   '    trsubr
413aAC                   exsr      zztrck
     C                   eval      tried = *off
     C     tryagn        tag
     *
     *   Allocate quantity needed from the warehouse qty (ITEMQTY).
     *
FPR1MC                   if        (client = vip
FPR1AC                             or  client = foodpro)
VIP1A*     IDS allocation override flag Y=Yes.
FPR1MC                             and omiaov = 'Y'  or
GFC1A*
GFC1AC                             client = glazier and
GFC1A*     H&S allocation override flag Y=Yes.
GFC1AC                             omiaov = 'Y'  or
GFC1A*
MJK1A*
MJK1AC                             client = mjkeln  and
MJK1A*     IDS allocation override flag Y=Yes.
MJK1AC                             omiaov = 'Y'  or
SOF1A*
SOF1AC                             client = sofofoods and
SOF1A*     IDS allocation override flag Y=Yes.
SOF1AC                             omiaov = 'Y'  or
SOF1A*
SGC1AC                             client = SGC
SGC1AC*     SGC allocation override flag Y=Yes.
SGCeDC*                            and sgcdm1_omalco = 'Y'
SGCeMC                             and omiaov = 'Y'
SGC1AC*
SVL1A*
SVL1AC                             or (client = Savalfoods)
SVL1A*     NDS allocation override flag Y=Yes.
SVL1AC                             and svldm1_filall = 'Y'
CLDdAC*
CLDdAC                             or client = cityln
730gAC
730gA*     Force allocation for Flex Picks
730gAC                             or umFlexPickFlag <> ''
VIP1A*
VIP1AC                   eval      $acmd = '*ALLOCFR'
VIP1AC                   else
520bAC                   select
650fA*  when repack item and odrBldNeeded is off this means either
650fA*  pick or overflow stock was found to fulfill order.  Therefore
650fA*  we will FORCE allocation knowing the replenishment is coming
650fAc                   when      ittype = 'R' and
650fAc                             not odrBldNeeded
650fAC                   eval      $acmd = '*ALLOCFR'
520bAC                   when      leftq1 > 0  and
520bAC                             leftq2 = 0  and
520bAC                             leftq3 = 0
520bAC                   eval      $acmd = '*ALLOCN '
520bAC                   when      leftq1 = 0  and
520bAC                             leftq2 > 0  and
520bAC                             leftq3 = 0
520bAC                   eval      $acmd = '*ALLOC1 '
520bAC                   when      leftq1 = 0  and
520bAC                             leftq2 = 0  and
520bAC                             leftq3 > 0
520bAC                   eval      $acmd = '*ALLOC2 '
520bAC                   other
     C                   eval      $acmd = '*ALLOC  '
520bAC                   endsl
VIP1AC                   endif
VIP1A*
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*BATCH  '
     C                   eval      $awhse = $pwhse
411 AC                   if        ittype = 'A'  or
411 AC                             ittype = 'S'
417cD**                   MOVE #BITEM    $AITEM
417cMC                   eval      $aitem = #sitem
411 AC                   else
     C                   eval      $aitem = oditem
411 AC                   endif
     C                   eval      $aqty1 = leftq1
     C                   eval      $aqty2 = leftq2
     C                   eval      $aqty3 = leftq3
     *
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
     *
     *   Convert allocated quantity to string for error msg.
416aA*   Note: code moved below.
     *
416aD*R                   MOVE '*QTY2STR'$CCMD
416aD*R                   MOVE '#PROG   '$CPRG
416aD*R         ITTYPE    IFEQ 'S'
416aD*R                   Z-ADD$ARTQ2    $CQTY1
416aD*R                   Z-ADD$ARTQ3    $CQTY2
416aD*R                   Z-ADD0         $CQTY3
416aD*R                   ELSE
416aD*R                   Z-ADD$ARTQ1    $CQTY1
416aD*R                   Z-ADD$ARTQ2    $CQTY2
416aD*R                   Z-ADD$ARTQ3    $CQTY3
416aD*R                   ENDIF
416aD*R                   CALL 'CVTQTY'
416aD*R                   PARM           $CCMD
416aD*R                   PARM           $CPRG
416aD*R                   PARM           $CQTY1
416aD*R                   PARM           $CQTY2
416aD*R                   PARM           $CQTY3
416aD*R                   PARM           $CUM1
416aD*R                   PARM           $CUM2
416aD*R                   PARM           $CUM3
416aD*R                   PARM           $CQSTR
416aD*R                   PARM           $CUSTR
416aD*R                   PARM           $CRTN
416aD*R                   PARM           $CERM
416aD*R                   MOVE $CQSTR    P1QALC
     *
     *   Print error message if entire qty could not be allocated.
     *
     C                   if        leftq1 <> $artq1  or
     C                             leftq2 > $artq2  or
     C                             leftq3 > $artq3
409 A*
409 A*   If return qty's are different it means that something was
409 A*   replenished last time but that we still do not have enough
409 A*   quantity to fullfill order.  Therefore, set the TRIED flag
409 A*   off so we can do another replenishment.
409 AC                   if        $artq1 <> svrtq1  or
409 AC                             $artq2 > svrtq2  or
409 AC                             $artq3 > svrtq3
409 AC                   eval      tried = *off
409 AC                   endif
409 A*   Save return qty's
409 AC                   eval      svrtq1 = $artq1
409 AC                   eval      svrtq2 = $artq2
409 AC                   eval      svrtq3 = $artq3
PCKg *      For ALL orders, do not replenish, get out of loop.
PCKg ***                  GOTO NOREPL
PCKg *
500bA*
500bA*      Do not create replenishments.
500dMC                   if        opjitr <> '1'
500bAC                   goto      norepl
500bAC                   endif
     *
411 D*R         ITTYPE    IFEQ 'B'
411 MC                   if        #bityp = 'B'  and
     C                             tried = *off  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             #bityp = 'B'  and
414aAC                             tried = *off  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
     C                   exsr      replns
520bAC                   select
520bAC                   when      $acmd = '*ALLOCN'
520bAC                   eval      $acmd = '*UNALOCN'
520bAC                   when      $acmd = '*ALLOC1'
520bAC                   eval      $acmd = '*UNALOC1'
520bAC                   when      $acmd = '*ALLOC2'
520bAC                   eval      $acmd = '*UNALOC2'
520bAC                   other
409 AC                   eval      $acmd = '*UNALLOC'
520bAC                   endsl
409 AC                   eval      $aqty1 = $artq1
409 AC                   eval      $aqty2 = $artq2
409 AC                   eval      $aqty3 = $artq3
     *
409 AC                   call      'ADJQTY'
409 AC                   parm                    $acmd
409 AC                   parm                    $aprg
409 AC                   parm                    $atype
409 AC                   parm                    $awhse
409 AC                   parm                    $aitem
409 AC                   parm                    $aqty1
409 AC                   parm                    $aqty2
409 AC                   parm                    $aqty3
409 AC                   parm                    $artq1
409 AC                   parm                    $artq2
409 AC                   parm                    $artq3
409 AC                   parm                    $artn
409 AC                   parm                    $aerm
     *
     C                   eval      tried = *on
     C                   goto      tryagn
     C                   endif
500bA*
500bAC     norepl        tag
416aA*
416aA*   Convert allocated quantity to string for error msg.
416aA*
416aAC                   eval      $ccmd = '*QTY2STR'
416aAC                   move      '#PROG   '    $cprg
416aAC                   if        ittype = 'S'
416aAC                   eval      $cqty1 = $artq2
416aAC                   eval      $cqty2 = $artq3
416aAC                   eval      $cqty3 = 0
416aAC                   else
416aAC                   eval      $cqty1 = $artq1
416aAC                   eval      $cqty2 = $artq2
416aAC                   eval      $cqty3 = $artq3
416aAC                   endif
416aAC                   call      'CVTQTY'
416aAC                   parm                    $ccmd
416aAC                   parm                    $cprg
416aAC                   parm                    $cqty1
416aAC                   parm                    $cqty2
416aAC                   parm                    $cqty3
416aAC                   parm                    $cum1
416aAC                   parm                    $cum2
416aAC                   parm                    $cum3
416aAC                   parm                    $cqstr
416aAC                   parm                    $custr
416aAC                   parm                    $crtn
416aAC                   parm                    $cerm
416aAC                   eval      p1qalc = $cqstr
     *
530bAC                   if        itflgd = 'Y'
530bAC                   eval      p1msg = msg(6)
530bAC                   else
     C                   eval      p1msg = msg(3)
530bAC                   endif
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR03'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   eval      trsr50 = 'ALLOC   '
413aAC                   exsr      zztrck
     C                   endif
410 A*   Calculate exception qty (Qty not allocated)
     *
417dAC                   if        $artq1 < 0
417dAC                   eval      excpq1 = leftq1
417dAC                   else
410 AC     leftq1        sub       $artq1        excpq1
417dAC                   endif
417dAC                   if        $artq2 < 0
417dAC                   eval      excpq2 = leftq2
417dAC                   else
410 AC     leftq2        sub       $artq2        excpq2
417dAC                   endif
417dAC                   if        $artq3 < 0
500aD*R                   Z-ADDLEFTQ2    EXCPQ3
500aMC                   eval      excpq3 = leftq3
417dAC                   else
410 AC     leftq3        sub       $artq3        excpq3
417dAC                   endif
     *
     *   Use the actual quantity allocated for picking from the slots.
     *     The quantity in the slots should always equal the quantity
     *     in the warehouse (ITEMQTY).
     *
417dAC                   if        $artq1 < 0
417dAC                   eval      leftq1 = 0
417dAC                   else
     C                   z-add     $artq1        leftq1
417dAC                   endif
417dAC                   if        $artq2 < 0
417dAC                   eval      leftq2 = 0
417dAC                   else
     C                   z-add     $artq2        leftq2
417dAC                   endif
417dAC                   if        $artq3 < 0
417dAC                   eval      leftq3 = 0
417dAC                   else
     C                   z-add     $artq3        leftq3
417dAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     C     avail         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'AVAIL   '    trsubr
413aAC                   exsr      zztrck
CBIjAc                   if        client = cheney
CBIjAC                             and (clientloc = cbipntgr
CBIjAc                             or clientloc = cbiocl)
CBIj *  Call program to calculate Container/Cruise alloc/pick qty.
CBIj C                   call      'CCQTY'
CBIj C                   parm                    $pwhse
CBIj C                   parm                    slitem
CBIj C                   parm                    slstyp
CBIj C                   parm                    slwhdp
CBIj C                   parm                    slaisl
CBIj C                   parm                    slpseq
CBIj C                   parm                    slrlvl
CBIj C                   parm                    slhand
CBIj C                   parm                    $lpck1            5 0
CBIj C                   parm                    $lpck2            3 0
CBIj C                   parm                    $lpck3            3 0
CBIj C                   parm                    $lalc1            5 0
CBIj C                   parm                    $lalc2            3 0
CBIj C                   parm                    $lalc3            3 0
CBIj C                   endif
     *
     *  Call program to calculate availabe slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
CBIjAc                   if        client = cheney
CBIjAC                             and (clientloc = cbipntgr
CBIjAC                             or clientloc = cbiocl)
CBIj *  Increase available by Container/cruise pick/allocate quantity.
CBIkAC                   add       $lpck1        stock1
CBIkAC                   add       $lpck2        stock2
CBIkAC                   add       $lpck3        stock3
CBIjAC     avail1        add       $lpck1        avail1
CBIjAC     avail2        add       $lpck2        avail2
CBIjAC     avail3        add       $lpck3        avail3
CBIjAC     avail1        add       $lalc1        avail1
CBIjAC     avail2        add       $lalc2        avail2
CBIjAC     avail3        add       $lalc3        avail3
CBIjAc                   endif
640hA
640hA*  Call program to get open Directed Putaway quantity.
640hA
640hAC                   call      'CHKOPNDP'
640hAC                   parm      slwhse        dWhse             3 0
640hAC                   parm      slwhdp        dWhdp             5
640hAC                   parm      sldisp        dDisp            12
640hAC                   parm      slitem        dItem            15
640iAC                   parm                    dTotal            3 0
640iAC                   parm                    dItmTtl           3 0
640hAC                   parm                    dQty1             5 0
640hAC                   parm                    dQty2             5 0
640hAC                   parm                    dQty3             5 0
640hA
640hAC                   eval      avail1 += dQty1
640hAC                   eval      avail2 += dQty2
640hAC                   eval      avail3 += dQty3
640hA
     *  Set negative quantities to zero

411 AC                   if        avail1 < 0
411 AC                   eval      avail1 = 0
411 AC                   endif
411 AC                   if        avail2 < 0
411 AC                   eval      avail2 = 0
411 AC                   endif
411 AC                   if        avail3 < 0
411 AC                   eval      avail3 = 0
411 AC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  BULKPK  Bulk pick.
     *
     *    06/11/97 DAS
     *      - Bulk pick is no longer based on a percentage.  Now the
     *        user enters the minimum cube for a bulk pick.
     *      - Saving home slot in the 'To' slot fields.
     *
     C     bulkpk        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'BULKPK  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     *
     C                   eval      s#cube = blkpct
520aD**                   Z-ADDTOPICK    QTYLFT
MJKaA*
MJKaA*   When processing MJK item,
MJKaA*     any qty is allowed, so set S#CUBE to zero.
MJKaA*
MJKaAC                   if        mjkpir = *on
MJKaAC                   eval      s#cube = 0
MJKaAC                   endif
SGCbA*
SGCbA*   Turn off SGC bulk processing flag. Flag will be used to force
SGCbA*   valid bulk picks to utilize MJK's 2 pass method.
SGCbAC                   if        client = SGC
SGCbAC                   eval      sgcbulk = '0'
SGCbAC                   endif
PANbA /free
PANbA
PANbA      // Get item category code
PANbA
PANbA      if client = Panos;
PANbA                    eval      $gcat = ' ';
PANbA                    eval      dsqmax= 0;
PANbA        callp getitemfld(itwhse: ititem: $gcat);
PAN A
PAN A        chain ($pwhse: ititem) itemmsc;
PAN A                    if        %found(itemmsc);
PAN A                      %occur(defs) = 1;
PAN A                      eval      dssdef = *blanks;
PAN A                      eval      dstie = imtie;
PAN A                      eval      dshigh = imhigh;
PAN A                      select;
PAN A                      when      imtie = 0;
PAN A                      eval      dsqmax = imhigh;
PAN A                      when      imhigh = 0;
PAN A                      eval      dsqmax = imtie;
PAN A                      other;
PAN A                      eval      dsqmax = imtie * imhigh;
PAN A                      endsl;
PAN A                    endif;
PANbA      endif;
PANbA
PANbA /end-free
PANbA
     *
     *   Get "Normal" Tie/High definitions for item.
     *
520aD**                   Z-ADD0         LSTDEF  10
520aD**                   Z-ADD0         CURDEF  10
MJKbA*
MJKbA*   For MJK PIR pick, run 2 passes.
SGCbA*   or  SGC Bulk picks, run 2 passes.
MJKbA*   For all other routes, only do single pass.
MJKbA*
MJKbAC     1             do        2             bppass
MJKbA*
640eDC*                  if        mjkpir <> *on  and
640eAC*
640eMC                   select
640eAC                   when      client = MJKellner
640eAC                   if        mjkpir <> *on  and
MJKbAC                             bppass = 2
640eAC                   leave
640eAC                   endif
640eDC*                            and client <> MJKellner
SGCbA*
640eAC                   when      client = SGC
640eDC*                            and sgcbulk <> *on
640eMC                   if        sgcbulk <> *on
SGCbAC                             and bppass = 2
640eAC                   leave
640eAC                   endif
640eDC*                            and client <> SGC
SGCbA*
640dAC                   other
SGCbAC                   if        bppass = 2
MJKbAC                   leave
MJKbAC                   endif
640eAC                   endsl
MJKbA*
     C                   eval      tmpflg = *off
     *
     *   Loop while ....
     *
     *       There is quantity left to be picked
     *       And something was picked last time through.
     *
     C                   eval      lstqty = 0
     *
     C                   dow       leftq1 <> 0  and
     C                             leftq1 <> lstqty
     *
     *   TMPFLG=*ON We did not find any slot that met bulk pick
     *              criteria.
     *
     C                   if        tmpflg = *on
413aAC                   eval      trnbr = 'TR14'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     *   Quantity left is not enough for bulk pick. Go home.
     *
     C     leftq1        mult      itcube        c#cube
     C                   if        c#cube < s#cube
PANaA*
PANaAC                             or client = Panos
PANaAC                             and ($gcat = 'FRZN-POT1'
PANaA*       Get out if not at least 1 full pallet qty.
PANaAC                             and  leftq1 < dsqmax)
PANaA*
413aAC                   eval      trnbr = 'TR15'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     C                   eval      lstqty = leftq1
SGCbA*
SGCbA*     Valid bulk pick qty, force 2 passes, sharing MJK mods.
SGCbAC                   if        client = SGC
SGCbAC                   eval      sgcbulk = '1'
SGCbAC                   endif
     *
     *     Loop through reserved slots to fulfill bulk pick.
     *
     C                   eval      kystat = 'A '
USF AC                   select
USF A*
USF A*    Look in pick slots to generate bulk pick.
USF AC                   when      client = usfcrp  or
MJKaAC                             mjkpir = *on
PANbA*
PANbAC                             or client = Panos
PANbAC                             and $gcat = 'FRZN-POT1'
PANbA*
USF AC                   eval      kypick = 'Y'
USF A*
USF AC                   other
     C                   eval      kypick = 'N'
USF AC                   endsl
650qAc                   if        itflgb = 'C'
650qAC                   eval      savekypick = kypick
650qAc                   exsr      PICKMC
650qAC                   eval      kypick = savekypick
650qAc                   endif
413aAC                   eval      trnbr = 'TR20'
413aAC                   eval      trkey = 'KEYSL3'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
PCKd *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
PCKe *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
PCKhD*     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
PCKd ****       SLAISL    IFGE ' 44'
520fAC                   if        client = packers
PCKe C                   if        slaisl >= ' 66'
PCKd C                   iter
PCKd C                   endif
     *
PCKhDC*                  if        slwhdp = 'DRY  '  and
PCKhDC*                            slaisl >= ' 01'  and
PCKhDC*                            slaisl <= ' 10'
PCKhDC****               iter
PCKhDC*                  endif
520fAC                   endif
     *
     *        Ignore slot if no normal stock or past expiration date.
     *
     C                   if        slstk1 <= 0  or
     C                             slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   select
413aAC                   when      slstk1 <= 0
413aAC                   eval      trnbr = 'TR10'
413aAC                   when      slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413aAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   endsl
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     *
     C                   if        avail1 <= 0
413aAC                   eval      trnbr = 'TR11'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Save slot information and available quantities.
     *
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
     *
     *     Calculate available cube.
     *
     C     avail1        mult      itcube        c#cube
     *
     *     Slot does not have enough for bulk pick.  Look for other
     *     slot with same date.
     *
     C                   eval      found = *off
     C                   if        c#cube < s#cube
650qAc                             and itflgb <> 'C'
640aAC                   iter
     *     This subroutine is commented out because, looking for
     *     slots with the same priority and dates ignored other
     *     valid overflow slots from being considered.
640aA ***                exsr      look4nxtslot
     *
     *     Found enough for bulk pick.  Take and run.
     *
     C                   else
650qA*  if itflgb = 'C' and left qty < avail qty get out and
650qA*  let the balance be allocated to the pick slot
650qAc                   if        itflgb = 'C' and leftq1 < avail1
650qAc                   leave
650qAc                   endif
650qA*  Before allocating this for bulk pick need to make sure
650qA*  we have a pristine license for bulk selection to auto load CW
650qA*  only check pristine license if the item is uci selection
650qA*  otherwise allocate pick slot then overflow ignoring min/max cube
650qA*  go get item uci selection flag if the item has changed
650qAc                   if        slitem <> $ititem
650qA /free
650qA     // get data from itemfld
650qA     exsr clr$item;

650qA     $itWhse = slwhse;
650qA     $ititem = slitem;

650qA     $dricommand = '*ITEM';
650qA     $drisubcmd  = '%GETALL';
650qA     $drisys2upd = 'D';
650qA     chk4err = *on;
650qA     exsr zzzdricop;
650qA     if error = *on;
650qA       $ifsltmth = '1';
650qA     endif;
650qA /end-free
650qAc                   endif
650qAc                   if        $ifsltmth = '1'
650qAc                   eval      pristine = *on
650qAc                   else
650qAc                   if        itflgb = 'C'
650qAc                   eval      pristine = *off
650qAc                   exsr      zzlicense
650qAc                   if        $litolcns <> '*NONE'
650qAc                   exsr      zzlicinfo
650qAc                   if        pristine = *off
650qA * ok we don't want to allocate this as a bulk
650qA * we want to reduce the left qty at this point by the avail1 qty
650qA * we will add this back at the end so it will get allocated from
650qA * the pick slot.
650qAc                   eval      addbackq1 = addbackq1 + avail1
650qAc                   eval      leftq1 = leftq1 - avail1
650qac                   iter
650qAc                   endif
650qAc                   endif
650qAc                   endif
650qAc                   endif
650qAc
     C                   eval      found = *on
     C                   endif
     *
     *   We did not find any slot that met bulk pick criteria.
     *
     C                   if        found = *off
     C                   eval      tmpflg = *on
413aAC                   eval      trnbr = 'TR14'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif

640cA*   Always get ITEMMSC record.
640cA
640cAC     keyim         chain     itemmsc
640cAC                   if        not %found(itemmsc)
640cAC                   clear                   imrec
640cAC                   endif
     *
     *   Get "Normal" Tie/High definitions for item.
MJKcA*     For MJK PIR, if not found, use Mfr ti/hi.
     *
     C     keydef        chain     itemdef1                           77
640fAC                   if        *in77 = '1'
640fAC                   eval      idsdef = ' '
640fAC                   eval      idtie  = 0
640fAC                   eval      idhigh = 0
640fAC                   eval      idum   = ' '
640fAC                   eval      idpref = ' '
640fAC                   endif
MJKcA*
MJKcAC                   if        *in77  and
MJKcAC                             mjkpir = *on
SGCbA*
SGCbAC                             or *in77  and
SGCbAC                             sgcbulk = *on
SGCbA*
640cDC**   keyim         chain     itemmsc                            77
640cDC**                 if        not *in77
MJKcAC                   if        imtie = 0  and
MJKcAC                             imhigh = 0
MJKcAC                   eval      *in77 = *on
MJKcAC                   else
MJKcAC                   eval      idtie = imtie
MJKcAC                   eval      idhigh = imhigh
MJKgAC                   eval      *in77 = *off
MJKcAC                   endif
640cDC**                 endif
MJKcAC                   endif
MJKcA*
640eA*   Get slot license
640eAC                   exsr      zzgetl

640cA*   Because of license tracking, only use ti/hi's if
640cA*   tracking is not High or Medium. Otherwise, we can
640cA*   assume a slot is a pallet.
640eA*   Or if license is system generated (starts with *)

640eDC**                 if        not *in77
640eDC**                           and imltrk <> 'H'
640eDC**                           and imltrk <> 'M'

640gMC                   if        not *in77
640gMC                             and (
720fDC*                                  (imltrk <> 'H' and imltrk <> 'M')
720fMC                                   (imltrk <> 'H' and
720fAC                                    imltrk <> 'M' and
720fAC                                    imltrk <> 'U')
640gMC                                   or %subst(lcns:1:1) = '*'
650qAc                                   and itflgb <> 'C'
640gMC                                 )
MJKhAC*
MJKhAC                             or not *in77
MJKhAC                             and mjkpir = '1'
720fDC*                            and   (imltrk = 'H' or imltrk = 'M')
720fMC                             and   (imltrk = 'H' or
720fAC                                    imltrk = 'M' or
720fAC                                    imltrk = 'U')
MJKhAC                             and avail1 > (imtie * imhigh)

     C     1             occur     defs
     C                   eval      dssdef = idsdef
     C                   eval      dstie = idtie
     C                   eval      dshigh = idhigh
     C                   select
     C                   when      idtie = 0
     C                   eval      dsqmax = idhigh
     C                   when      idhigh = 0
     C                   eval      dsqmax = idtie
     C                   other
     C                   eval      dsqmax = idtie * idhigh
     C                   endsl
     C                   if        avail1 < dsqmax  or
520dAC                             dsqmax <= 0
MJKbA*            For MJK PIR, we only want full pallets for pass 1.
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1
SGCbA*
SGCbAC                             or sgcbulk = *on  and
SGCbAC                             bppass = 1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
     C                   eval      dsqmax = avail1
     C                   endif
640gDC**                 endif
     *
     *   If no tie/high defined, then consider qty available as
     *   one full pallet load.
640cA*   ... Or tracking is High or Medium.
     *
     C                   else
MJKbA*            For MJK PIR, we must have a ti/hi for pass 1.
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1
SGCbA*
SGCbA*            For SGC bulkpicks, we must have a ti/hi for pass 1.
SGCbAC                             or sgcbulk = *on  and
SGCbAC                             bppass = 1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
     C                   eval      dsqmax = avail1
     C                   eval      idtie = 0
     C                   eval      idhigh = 0
     C                   eval      dstie = 0
     C                   eval      dshigh = 0
413aAC                   eval      trnbr = 'TR17'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   endif
640eDC**                 endif
MJKbA*
MJKbA*       For MJK PIR, we only want full pallets for pass 1.
MJKbA*
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1  and
MJKbAC                             dsqmax > leftq1
SGCbA*
SGCbAC                             or sgcbulk = *on and
SGCbAC                                bppass = 1 and
SGCbAC                                dsqmax > leftq1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
TPCaAC*
TPCaAC*   For TPC, hard code max size of bulk pick.
TPCaAC*
TPCaACSR                 if        client = TPC
TPCaACSR                 if        itcube > 0
TPCaACSR                 eval      dsqmax =  64 / itcube
TPCaACSR                 endif
TPCaACSR                 endif
     *
     *       Calculate quantity to pick.
     *
     C                   if        dsqmax <= leftq1
650qAc                   if        itflgb <> 'C'
     C                   z-add     dsqmax        pickq1
650qAc                   else
650qAC                   z-add     avail1        pickq1
650qAc                   endif
     C                   eval      remain = 0
     C                   else
     C                   eval      pickq1 = leftq1
     C     dsqmax        sub       leftq1        remain
     C                   endif
     *
     *       Create label for bulk pick.
     *
     C                   clear                   lwrec
     C                   eval      lwwhse = slwhse
640dD ***                select
640dD ***                when      client = silberman
640dD ***                          or client = cashwa
640dD ***                          or client = citywho
SLBaAC                   eval      lwtruk = $ptmpl
640dD ***                other
640dD ***                eval      lwtruk = $ptruk
640dD ***                endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwwhs2 = hmwhse
     C                   eval      lwwhd2 = hmwhdp
     C                   eval      lwasl2 = hmaisl
     C                   eval      lwloc2 = hmloc
     C                   eval      lwlvl2 = hmrlvl
     C                   eval      lwhnd2 = hmhand
     C                   eval      lwdsp2 = hmdisp
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
     C                   eval      lwqavl = avail1
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
     C                   eval      lwqrmn = remain
     C                   eval      lwtie = dstie
     C                   eval      lwhigh = dshigh
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = $potyp
MJKaAC                   if        mjkpir = *on
MJKaAC                   eval      lwtype = 'O'
MJKdAC                   eval      lwqrmn = 0
MJKaAC                   else
     C                   eval      lwtype = 'B'
MJKaAC                   endif
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     *
     *       Update slot allocation.
     *
     C                   add       pickq1        slalc1
     C                   update    slrec
     *
     *       Reduce quantity left to pick.
     *
     C                   eval      leftq1 = leftq1 - pickq1
     C                   add       pickq1        ttlpk1
     *
     *       Leave slot reading loop.
     *
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
650qAc                   if        itflgb <> 'C'
     C                   leave
650qAC                   endif
     C                   enddo
     *
650qA*  if itflgb = 'C' and left qty < avail qty get out and
650qA*  let the balance be allocated to the pick slot
650qAc                   if        itflgb = 'C' and leftq1 < avail1
650qAc                   leave
650qAc                   endif
650qA*
     C                   enddo
650qA*  but before we leave we need to add back the overflow slot qtys
650qA*  that we bypassed because the license was not pristine for use
650qA*  in bulk pick
650qAc                   if        itflgb = 'C' and addbackq1 >0
650qAc                   eval      leftq1 = leftq1 + addbackq1
650qAc                   eval      addbackq1 = 0
650qAc                   endif
     *
MJKbAC                   enddo
     C     endbp         endsr
650nA
650nA*----------------------------------------------------------------
650nA*  chkForWo   Check for matching Work Order
650nA*----------------------------------------------------------------
650nA
650nAC     chkForWo      begsr
650nA /free
650nA
650nA           savever# = $ppver#;
730cA           clear $pprod;
730cA           clear $pprod2;
650nA           $ppver# = savever#;
650nA
650nA   // returns matching Work Order number or *NF for not found in
650nA   // $ppWo#
650nA
650nA           $ppSessIdu = *on;
650nA           $ppSessid  = pSessId; // created in inzsr routine
650nA           $ppwhseu = *on;
650nA           $ppwhse  = $pwhse;
650nA           $ppitemu = *on;
650nA           $ppitem  = ititem;
650nA           $ppuser = #User;
650nA           $ppuseru = *on;
650nA           $ppdest = 'C';
650nA           $ppdestu = *on;
650nA           $ppcust = ohcust;
650nA           $ppcustu = *on;
650nA           $ppcustwo = ' ';
650nA           $ppcustwou = *on;
650nA           $ppcord = 0;
650nA           $ppcordu = *on;
650nA           $pplneno = ipmfgno;
650nA           $pplnenou = *on;
650nA           $ppWo# = ' ';
650nA           $ppWo#u = *off;
650nA
650nA           $dricommand = '*PROD';
650nA           $drisubcmd = '%CHKFORWO';
650nA           $drisys2upd = 'D';
650nA           exsr zzzDriCop;
650nA           if not drierr;
650nA              wkwo# = $ppwo#;
650nA           endif;
650nA
650nA /end-free
650nAC                   endsr
650nA
650nA*----------------------------------------------------------------
650nA*  crtProdWO  Create Production Work Order calling DRIPROD
650nA*----------------------------------------------------------------
650nA
650nAC     crtProdWO     begsr
650nA /free
650nA
650nA           savever# = $ppver#;
650nA           $ppver# = savever#;
650nA
650nA           $ppSessIdu = *on;
650nA           $ppSessid  = pSessId;
650nA           $ppwhseu = *on;
650nA           $ppwhse  = $pwhse;
650nA           $ppitemu = *on;
650nA           $ppitem  = ititem;
650nA           $ppuser = #User;
650nA           $ppuseru = *on;
650nA           $ppdest = 'C';
650nA           $ppdestu = *on;
650nA           $ppcust = ohcust;
650nA           $ppcustu = *on;
650nA           $ppcustwo = ' ';
650nA           $ppcustwou = *on;
650nA           $ppcord = ohcord;
650nA           $ppcordu = *on;
650nA           $ppmake = woqty;
650nA           $ppmakeu = *on;
730bA           $ppQty1 = woqty;
730bA           $ppQty1u = *on;
650nA           $pplneno = ipmfgno;
650nA           $pplnenou = *on;
650nA           $pporig = 'O';       // Origination in Planning
650nA           $pporigu = *on;
650nA           $ppstat = 'P';       // Status is Planning
650nA           $ppstatu = *on;
650nA           $pprmavl = 'Y';
650nA           $pprmavlu = *on;
650nA           $ppprio = 3;
650nA           $pppriou = *on;
650nA           $ppWo# = wkwo#;
650nA           $ppWo#u = *on;
730cA           $ppwipa='A';
730cA           $ppwipau=*on;
730cA           $ppovrdu=*on;
730cA           $ppovrd=0;
730cA           $ppcbd1u=*on;
730cA           $ppcbd1=0;
730cA           $ppcbd2u=*on;
730cA           $ppcbd2=0;
730cA           $ppNeedu=*on;
730cA           $ppNeed=0;
650nA
650nA           $dricommand = '*PROD';
730cD           //$drisubcmd = '%CRTPRODWO';
730cA           $drisubcmd = '%UPDLOOP';
650nA           $drisys2upd = 'D';
650nA           exsr zzzDriCop;
650nA
650nA /end-free
650nAC                   endsr
720aA
720aA*----------------------------------------------------------------
720aA*  getStrZ  Get Store/Remote location such as Company Store
720aA*----------------------------------------------------------------
720aA
720aAC     getStrZ       begsr
720aA
720 AC                   eval      savever# = $zdver#
720 AC                   clear                   $zoned
720 AC                   eval      $zdver# = savever#
720 A
720 Ac*  zdtsttruk can be complete name of specific Truck in Zoned or just a por
720 Ac*  I am sending only ! which is first character since we do not have way t
720 Ac*  desired zones currently.  This will read in any definitions beginning w
720 AC                   eval      $zdtsttruku = *on
720 AC                   eval      $zdtsttruk = '!'
720 AC                   eval      $zdwhseu = *on
720 AC                   eval      $zdwhse = odwhse

720 Ac                   eval      $zdwhdpu = *on
720 Ac                   eval      $zdwhdp = itwhdp

720 Ac                   eval      $zdstrbpcku = *off
720 Ac                   eval      $zdstrbpck = ' '
720 Ac                   eval      $zdstrcpcku = *off
720 Ac                   eval      $zdstrcpck = ' '
720 Ac                   if        ittype='B' or ittype='S'
720 Ac                   eval      $zdstrcpcku = *off
720 Ac                   eval      $zdstrcpck = ' '
720 Ac                   eval      $zdstrbpcku = *off
720 Ac                   eval      $zdstrbpck = ' '
720 Ac                   eval      $zdstrbitmu = *on
720 Ac                   eval      $zdstrbitm = ititem
720 Ac                   eval      $zdstrcitmu = *off
720 Ac                   eval      $zdstrcitm = *blanks
720 Ac                   else
720 Ac                   eval      $zdstrcpcku = *off
720 Ac                   eval      $zdstrcpck = ' '
720 Ac                   eval      $zdstrcitmu = *on
720 Ac                   eval      $zdstrcitm = ititem
720 Ac                   eval      $zdstrbitmu = *off
720 Ac                   eval      $zdstrbitm = *blanks
720 Ac                   endif
720 A
720 Ac                   eval      $dricommand = '*ZONED'
720 Ac                   eval      $drisubcmd = '%STRZONE'
650nAc                   eval      $drisys2upd = 'D'
720aAc                   exsr      zzzDriCop
720aA
720aAC     endstrz       endsr
720aA
640aA*----------------------------------------------------------------
640aA*
640aA*  LOOK4NXTSLOT - Loop through slots with same priority and dates
640aA*                 trying to fullfill minimum requirement for Bulk
640aA*                 pick.
640aA*
640aAC     look4nxtslot  begsr
640aA*
413aAC                   eval      trnbr = 'TR16'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     *
     *     Loop through slots with same priority and dates.
     *
413aAC                   eval      trnbr = 'TR20'
413aAC                   eval      trkey = 'KEYS3B'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   dou       forevr <> forevr
     C     keys3b        reade     slot3                                  76
     C                   if        *in76
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
PCKd *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
PCKe *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
PCKhD*     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
PCKd ****       SLAISL    IFGE ' 44'
520fAC                   if        client = packers
PCKe C                   if        slaisl >= ' 66'
PCKd C                   iter
PCKd C                   endif
     *
PCKhDC*                  if        slwhdp = 'DRY  '  and
PCKhDC*                            slaisl >= ' 01'  and
PCKhDC*                            slaisl <= ' 10'
PCKhDC****               iter
PCKhDC*                  endif
520fAC                   endif
     *
     *        Ignore slot if past expiration date.
     *
     C                   if        slstk1 <= 0  or
     C                             slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   select
413aAC                   when      slstk1 <= 0
413aAC                   eval      trnbr = 'TR10'
413aAC                   when      slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413aAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   endsl
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *        Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   if        avail1 <= 0
413aAC                   eval      trnbr = 'TR11'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate available cube.
     *
     C     avail1        mult      itcube        c#cube
     *
     *     Found enough for bulk pick.  Take and run.
     *
     C                   if        c#cube >= s#cube
     C                   eval      found = *on
     C                   leave
     C                   endif
     *
     C                   enddo
640aA*
640aAC                   endsr
     *----------------------------------------------------------------
     *
415aA*  CRTLBL  Create label records - No allocation on BFC side.
     *
415aAC     crtlbl        begsr
     *
     C     keyoh2        setll     ordh2
     C                   dou       forevr <> forevr
     C     keyoh2        reade     ordh2                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *    Loop thru detail records and create label records.
     C     keyod1        setll     ordd1
     C                   dou       forevr <> forevr
     C     keyod1        reade     ordd1                                  78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      wkoitm = odoitm
     C                   select
     C                   when      odqor1 > 0
     C                   eval      pickq1 = odqor1
     C                   when      odqor2 > 0
     C                   eval      pickq1 = odqor2
     C                   when      odqor3 > 0
     C                   eval      pickq1 = odqor3
     C                   endsl
     C                   clear                   lwrec
     C                   eval      lwwhse = $pwhse
640dD ***                select
640dD ***                when      client = silberman
640dD ***                          or client = cashwa
640dD ***                          or client = citywho
SLBaAC                   eval      lwtruk = $ptmpl
640dD ***                other
640dD ***                eval      lwtruk = $ptruk
640dD ***                endsl
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itwhdp = *blanks
     C                   eval      itstyp = *blanks
     C                   eval      itum1 = *blanks
     C                   eval      itcube = 0
     C                   eval      itswgt = 0
     C                   endif
     C                   eval      lwwhdp = itwhdp
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwaisl = wkaisl
     C                   eval      lwloc = wkloc
     C                   eval      lwrlvl = wkrlvl
     C                   eval      lwhand = wkhand
     C                   eval      lwstyp = itstyp
     C                   if        lwstyp = 'P'
417aD*R                   MOVE '1'       LWVRFY
417aMC                   move      '1'           lwqryf
     C                   else
417aD*R                   MOVE '0'       LWVRFY
417aMC                   move      '0'           lwqryf
     C                   endif
     C                   movel     odoitm        lwdisp
     C                   eval      lwasl2 = '***'
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
650jA *    Do NOT set special field for prepick slots.
700eA *    hasAMPpick in the Normal Delv Rt & should not clear sp cd
700eA *      AND the AMP order should not have special codes
700eA *      XD, cross dock in delv rt so allow XD to stay
650jAC                   if        lwaisl = 'PRE'
700eD **                           or hasAMPpick
650jAC                   eval      lwspcl = *blanks
650jAC                   else
     C                   eval      lwspcl = odspcl
650jAC                   endif
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = $potyp
     C                   eval      lwtype = wkbulk
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     C                   write     lwrec
     *
     C                   eval      odstat = 'P'
     C                   update    odrec
     *
     C                   enddo
     *   End detail records loop.
     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohpbat = $pbat
     C                   enddo
     *
415aAC     endlbl        endsr
VIP A*
VIP A*----------------------------------------------------------------
VIP A*
VIP A*  CRTLWV  Create label records - No allocation on BFC side.
VIP A*          * Single Item Only *
VIP A*
VIP A*         *** Assumes only one quantity sent ***
VIP A*
VIP AC     crtlwv        begsr
VIP A*
VIP AC                   eval      wkoitm = odoitm
VIP AC                   eval      nonalc = *on
VIP A*
VIP AC                   select
VIP AC                   when      odqor1 > 0
VIP AC                   eval      pickq1 = odqor1
VIP AC                   when      odqor2 > 0
VIP AC                   eval      pickq1 = odqor2
VIP AC                   when      odqor3 > 0
VIP AC                   eval      pickq1 = odqor3
VIP AC                   other
VIP AC                   eval      pickq1 = *zeros
VIP AC                   endsl
VIP A*
VIP AC                   clear                   lwrec
VIP A*
VIP AC                   eval      lwwhse = $pwhse
640dD ***                select
640dD ***                when      client = silberman
640dD ***                          or client = cashwa
640dD ***                          or client = citywho
SLBaAC                   eval      lwtruk = $ptmpl
640dD ***                other
640dD ***                eval      lwtruk = $ptruk
640dD ***                endsl
VIP AC                   if        omwhdp > ' '
VIP AC                   eval      lwwhdp = omwhdp
VIP AC                   else
VIP AC                   eval      lwwhdp = itwhdp
VIP AC                   endif
VIP AC                   eval      lwseq = odseq
VIP AC                   eval      lwitem = oditem
VIP AC                   eval      lwpbat = $pbat
VIP A*
KFS AC                   if        client = Kellys
KFS AC     keyom         chain     ordds
KFS AC                   if        not %found(ordds)
KFS AC                   eval      osdisp = ' '
KFS AC                   endif
KFS AC                   eval      omwhse = ohwhse
KFS AC                   eval      omwhdp = itwhdp
KFS AC                   eval      kyslvp = osdisp
KFS AC                   else
KFS A*
VIP AC                   eval      kyslvp = omsltn
KFS AC                   endif
KFS A*
VIP AC     vipsl2        chain     slot2                              79
VIP AC                   if        *in79
VIP AC                   eval      sldisp = *blanks
VIP AC                   eval      slaisl = *blanks
VIP AC                   eval      slloc = *zeros
VIP AC                   eval      slrlvl = *zeros
VIP AC                   eval      slhand = *blanks
VIP AC                   eval      slpseq = *zeros
VIP AC                   endif
VIP A*
VIP AC                   eval      lwaisl = slaisl
VIP AC                   eval      lwloc = slloc
VIP AC                   eval      lwrlvl = slrlvl
VIP AC                   eval      lwhand = slhand
KFS A*
KFS AC                   If        client = Kellys
KFS AC                   eval      lwdisp = osdisp
KFS AC                   else
KFS A*
VIP AC                   movel     omsltn        lwdisp
KFS AC                   endif
KFS A*
VIP AC                   eval      lwpseq = slpseq
VIP A*
VIP AC                   eval      lwstyp = 'F'
VIP AC                   if        lwstyp = 'P'
VIP AC                   move      '1'           lwqryf
VIP AC                   else
VIP AC                   move      '0'           lwqryf
VIP AC                   endif
VIP A*
VIP AC                   eval      lwasl2 = '***'
VIP AC                   eval      lwrte = ohrte
VIP AC                   eval      lwstop = ohstop
VIP AC                   eval      lword = ohord
650jA *    Do NOT set special field for prepick slots.
700eA *    hasAMPpick in the Normal Delv Rt & should not clear sp cd
700eA *      AND the AMP order should not have special codes
700eA *      XD, cross dock in delv rt so allow XD to stay
650jAC                   if        lwaisl = 'PRE'
700eD **                           or hasAMPpick
650jAC                   eval      lwspcl = *blanks
650jAC                   else
VIP AC                   eval      lwspcl = odspcl
650jAC                   endif
VIP A*
VIP AC                   eval      lwucub = 0
VIP AC                   eval      lwcube = 0
VIP AC                   eval      lwuwgt = 0
VIP AC                   eval      lwswgt = 0
VIP A*
VIP AC                   select
VIP A*
VIP AC                   when      odqor1 > 0
VIP AC                   eval      lwutyp = 'N'
VIP AC                   eval      lwucod = itum1
VIP2A*
CBIuAC                   select
CBIuAC                   when      client = cheney
CBIuAC                   eval      lwucub = cbidm2_omcube
CBIuAC                   other
VIP2AC                   eval      lwucub = omcbec
CBIuAC                   endsl
VIP2AC                   if        lwucub <= 0
VIP AC                   eval      lwucub = itcube
VIP2AC                   endif
VIP2A*
VIP AC     lwucub        mult      pickq1        lwcube
VIP2A*
CBIuAC                   select
CBIuAC                   when      client = cheney
CBIuAC                   eval      lwuwgt = cbidm2_omswgt
CBIuAC                   other
VIP2AC                   eval      lwuwgt = omwtiw
CBIuAC                   endsl
VIP2AC                   if        lwuwgt <= 0
VIP AC                   eval      lwuwgt = itswgt
VIP2AC                   endif
VIP2A*
VIP AC     lwuwgt        mult      pickq1        lwswgt
VIP A*
VIP AC                   when      odqor2 > 0
VIP AC                   eval      lwutyp = *on
VIP AC                   eval      lwucod = itum2
VIP AC                   if        itumq2 <> 0
VIP AC     itcube        div(h)    itumq2        lwucub
VIP AC     lwucub        mult      pickq1        lwcube
VIP AC     itswgt        div(h)    itumq2        lwuwgt
VIP AC     lwuwgt        mult      pickq1        lwswgt
VIP AC                   endif
VIP A*
VIP AC                   when      odqor3 > 0
VIP AC                   eval      lwutyp = '2'
VIP AC                   eval      lwucod = itum3
VIP AC                   if        itumq2 <> 0  and
VIP AC                             itumq3 <> 0
VIP AC     itcube        div(h)    itumq2        lwucub
VIP AC     lwucub        div(h)    itumq3        lwucub
VIP AC     lwucub        mult      pickq1        lwcube
VIP AC     itswgt        div(h)    itumq2        lwuwgt
VIP AC     lwuwgt        div(h)    itumq3        lwuwgt
VIP AC     lwuwgt        mult      pickq1        lwswgt
VIP AC                   endif
VIP A*
VIP AC                   endsl
VIP A*
VIP AC                   eval      lwqalc = pickq1
VIP AC                   eval      lwgrp1 = 'S'
VIP AC                   eval      lwgrp2 = $potyp
VIP AC                   eval      lwtype = 'O'
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
VIP AC                   eval      lwstat = 'A'
VIP AC                   eval      lwsdte = today
VIP AC                   time                    lwstim
VIP AC                   eval      lwrdte = today
VIP A*
VIP AC                   write     lwrec
VIP A*
VIP AC                   eval      odstat = 'P'
VIP AC                   update    odrec
VIP A*
VIP AC     endlwv        endsr
VIP A*
CBI A*----------------------------------------------------------------
CBI A*
CBI A*  CRTLW2  Create label records - No allocation on BFC side.
CBI A*          * Single Item Only *
CBI A*
CBIhA*         *** Assumes only one quantity sent ***
CBIhA*
CBI AC     crtlw2        begsr
CBI A*
CBI AC                   eval      wkoitm = odoitm
CBI AC                   eval      nonalc = *on
CBI A*
CBI AC                   select
CBI AC                   when      odqor1 > 0
CBI AC                   eval      pickq1 = odqor1
CBI AC                   when      odqor2 > 0
CBI AC                   eval      pickq1 = odqor2
CBI AC                   when      odqor3 > 0
CBI AC                   eval      pickq1 = odqor3
CBI AC                   endsl
CBI A*
CBI AC                   clear                   lwrec
CBI A*
CBI AC                   eval      lwwhse = $pwhse
CBI AC                   eval      lwtruk = $ptruk
CBI AC                   eval      lwwhdp = itwhdp
CBI AC                   eval      lwseq = odseq
CBI AC                   eval      lwitem = oditem
CBI AC                   eval      lwpbat = $pbat
CBIdA*
CBIdA*    Load slot location for A1A's produce items.
CBIdAC                   select
CBIdAC                   when      itwhdp = 'PRD  '
CBIdAC                   eval      pr = *zeros
CBIdA*
CBIdAC                   move(p)   prdail        lwaisl
CBIdA*
CBIdAC     ' '           check     prdloc        pr                       45
CBIdA*
CBIdA*    Must have minimum of 3 digits to process.
CBIdAC                   if        pr <= 3  and
CBIdAC                             *in45
CBIdA*    Extract slot location from string.
CBIdAC                   eval      loc = %subst(prdloc:pr:3)
CBIdA*    Verify location extracted is numeric. 45=No.
CBIdAC     digits        check     loc                                    45
CBIdAC                   if        not *in45
CBIdAC                   move      loc           lwloc
CBIdAC                   endif
CBIdA*
CBIdA*    Extract slot level from string.
CBIdAC                   add       3             pr
CBIdAC                   eval      lvl = *blanks
CBIdAC     2             subst     prdloc:pr     lvl                    45
CBIdA*    Verify level extracted is numeric. 45=No.
CBIdAC     digits        check     lvl           pr                       45
CBIdAC                   select
CBIdAC                   when      pr = 0
CBIdAC                   move      lvl           lwrlvl
CBIdA*
CBIdAC                   when      pr = 1
CBIdAC                   eval      lvl1 = %subst(lvl:2:1)
CBIdAC     digits        check     lvl1          pr                       45
CBIdAC                   if        not *in45
CBIdAC                   move      lvl1          lwrlvl
CBIdAC                   endif
CBIdA*
CBIdAC                   when      pr = 2
CBIdAC                   eval      lvl1 = %subst(lvl:1:1)
CBIdAC     digits        check     lvl1          pr                       45
CBIdAC                   if        not *in45
CBIdAC                   move      lvl1          lwrlvl
CBIdAC                   endif
CBIdA*
CBIdAC                   endsl
CBIdAC                   endif
CBIdA*
CBIdAC                   other
CBI AC                   eval      lwaisl = *blanks
CBI AC                   eval      lwloc = *zeros
CBI AC                   eval      lwrlvl = *zeros
CBIdAC                   endsl
CBIdA*
CBI AC                   eval      lwhand = *blanks
CBIbAC                   eval      lwstyp = 'F'
CBI AC                   if        lwstyp = 'P'
CBI AC                   move      '1'           lwqryf
CBI AC                   else
CBI AC                   move      '0'           lwqryf
CBI AC                   endif
CBI AC                   eval      lwdisp = *blanks
CBI AC                   eval      lwasl2 = '***'
CBI AC                   eval      lwrte = ohrte
CBI AC                   eval      lwstop = ohstop
CBI AC                   eval      lword = ohord
CBI AC                   eval      lwspcl = odspcl
CBIhA*
CBIhAC                   eval      lwucub = 0
CBIhAC                   eval      lwcube = 0
CBIhAC                   eval      lwuwgt = 0
CBIhAC                   eval      lwswgt = 0
CBIhA*
CBIhAC                   select
CBIhA*
CBIhAC                   when      odqor1 > 0
CBI AC                   eval      lwutyp = 'N'
CBI AC                   eval      lwucod = itum1
CBI AC                   eval      lwucub = itcube
CBI AC     lwucub        mult      pickq1        lwcube
CBInA*
CBInAC                   if        client = cheney
CBInAC                   if        itgwgt > 0
CBInAC                   eval      lwuwgt = itgwgt
CBInAC                   else
CBInAC                   eval      lwuwgt = itswgt
CBInAC                   endif
CBInAC                   else
CBInA*
CBI AC                   eval      lwuwgt = itswgt
CBInAC                   endif
CBInA*
CBI AC     lwuwgt        mult      pickq1        lwswgt
CBIhA*
CBIhAC                   when      odqor2 > 0
CBIhAC                   eval      lwutyp = *on
CBIhAC                   eval      lwucod = itum2
CBIhAC                   if        itumq2 <> 0
CBIhAC     itcube        div(h)    itumq2        lwucub
CBIhAC     lwucub        mult      pickq1        lwcube
CBInA*
CBInAC                   if        client = cheney
CBInAC                   if        itgwgt > 0
CBInAC     itgwgt        div(h)    itumq2        lwuwgt
CBInAC                   else
CBInAC     itswgt        div(h)    itumq2        lwuwgt
CBInAC                   endif
CBInAC                   else
CBInA*
CBIhAC     itswgt        div(h)    itumq2        lwuwgt
CBInAC                   endif
CBInA*
CBIhAC     lwuwgt        mult      pickq1        lwswgt
CBIhAC                   endif
CBIhA*
CBIhAC                   when      odqor3 > 0
CBIhAC                   eval      lwutyp = '2'
CBIhAC                   eval      lwucod = itum3
CBIhAC                   if        itumq2 <> 0  and
CBIhAC                             itumq3 <> 0
CBIhAC     itcube        div(h)    itumq2        lwucub
CBIhAC     lwucub        div(h)    itumq3        lwucub
CBIhAC     lwucub        mult      pickq1        lwcube
CBInA*
CBInAC                   if        client = cheney
CBInAC                   if        itgwgt > 0
CBInAC     itgwgt        div(h)    itumq2        lwuwgt
CBInAC                   else
CBInAC     itswgt        div(h)    itumq2        lwuwgt
CBInAC                   endif
CBInAC                   else
CBInA*
CBIhAC     itswgt        div(h)    itumq2        lwuwgt
CBInAC                   endif
CBInA*
CBIhAC     lwuwgt        div(h)    itumq3        lwuwgt
CBIhAC     lwuwgt        mult      pickq1        lwswgt
CBIhAC                   endif
CBIhA*
CBIhAC                   endsl
CBIhA*
CBI AC                   eval      lwqalc = pickq1
CBI AC                   eval      lwgrp1 = 'S'
CBI AC                   eval      lwgrp2 = $potyp
CBI AC                   eval      lwtype = 'O'
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
CBI AC                   eval      lwstat = 'A'
CBI AC                   eval      lwsdte = today
CBI AC                   time                    lwstim
CBI AC                   eval      lwrdte = today
CBIfA*
CBIfAC                   if        meatin = 'Y'  or
CBIgAC                             prepck = 'Y'
CBIgA*
CBIgAC                   select
CBIpAC                   when      client = cheney
CBIpAC                             and clientloc = cbipntgr
CBIgA*
CBIgAC                   when      itwhdp = 'DRY  '

CBIqAC                   select
CBIqAC                   when      client = cheney
CBIqAC                             and clientloc = cbiocl
CBIqAC                   eval      lwaisl = ' PF'
CBIqAC                   eval      lwloc = 100
CBIqAC                   eval      lwpseq = lwloc
CBIqAC                   eval      lwrlvl = 1
CBIqAC                   eval      lwdisp = 'PF-100-1'

CBIqAC                   other
CBIgAC                   eval      lwaisl = ' PT'
CBIgAC                   eval      lwloc = 160
CBIiAC                   eval      lwpseq = lwloc
CBIgAC                   eval      lwrlvl = 1
CBIgAC                   movel     'PT-160-1'    lwdisp
CBIqAC                   endsl
CBIgA*
CBIgAC                   when      itwhdp = 'FRZ  '

CBIqAC                   select
CBIqAC                   when      client = cheney
CBIqAC                             and clientloc = cbiocl
CBIqAC                   eval      lwaisl = ' FF'
CBIqAC                   eval      lwloc = 100
CBIqAC                   eval      lwpseq = lwloc
CBIqAC                   eval      lwrlvl = 1
CBIqAC                   eval      lwdisp = 'PF-100-1'

CBIqAC                   other
CBIgAC                   eval      lwaisl = ' FZ'
CBIgAC                   eval      lwloc = 184
CBIiAC                   eval      lwpseq = lwloc
CBIgAC                   eval      lwrlvl = 1
CBIgAC                   movel     'FZ-184-1'    lwdisp
CBIqAC                   endsl
CBIgA*
CBIgAC                   other
CBIqA
CBIqAC                   select
CBIqAC                   when      client = cheney
CBIqAC                             and clientloc = cbiocl
CBIqAC                   eval      lwaisl = ' PC'
CBIqAC                   eval      lwloc = 100
CBIqAC                   eval      lwpseq = lwloc
CBIqAC                   eval      lwrlvl = 1
CBIqAC                   eval      lwdisp = 'PC-100-1'

CBIqAC                   other
CBIl C                   eval      lwaisl = ' CS'
CBIl C                   eval      lwloc = 169
CBIiAC                   eval      lwpseq = lwloc
CBIfAC                   eval      lwrlvl = 1
CBIl C                   movel     'CS-169-1'    lwdisp
CBIqAC                   endsl
CBIgA*
CBIgAC                   endsl
CBIgA*
CBIfAC                   endif
CBIfA*
CBI AC                   write     lwrec
CBI A*
CBI AC                   eval      odstat = 'P'
CBI AC                   update    odrec
CBI A*
CBI AC     endlw2        endsr
CBI A*
415bA*----------------------------------------------------------------
415bA*
415bA*  DUPPRT  Dup. printer file.
415bA*
415bAC     dupprt        begsr
     *
     *      Duplicate printer file.
     *
415b C                   close     or610pr
     *  DUPPRTCL will execute the DUPSPLF command.
     *
415b C                   movel     'OR610PR'     $lfile
WSFdDC****               movel     'HEMANT'      $loutq
415b C                   movel     '*LAST'       $lspln
415b C                   movel     'OR610PR'     $lnnam
     *
415bAC                   call      'DUPPRTCL'
415bAC                   parm                    $lfile           10
415bAC                   parm                    #jobn
415bAC                   parm                    #user
415bAC                   parm                    #job
415bAC                   parm                    $loutq           10
415bAC                   parm      '*LIBL'       $lqlib           10
415bAC                   parm                    $lspln            6
415bAC                   parm      1             $lcpys            3 0
415bAC                   parm                    $lnnam           10
415bAC                   parm      '*NO'         $ldlto            4
     *
415bAC                   endsr

640bA*----------------------------------------------------------------
640bA*  GetBatchAlloc  Get Batch Pick Allocation for item
640bA*----------------------------------------------------------------
640bA
640bAC     GetBatchAlloc begsr
      /free

         batchPickQty1 = 0;

         setll (odwhse: $prtid: odord: odseq: oditem: 'O')
                worklbl11;

         dow forever = forever;

           reade (odwhse: $prtid: odord: odseq: oditem: 'O')
                  worklbl11;

           if %eof(worklbl11);
             leave;
           endif;

           if lwutyp <> 'N';
             iter;
           endif;

           if lwstat <> 'A';
             iter;
           endif;

           batchPickQty1 += lwqalc;

         enddo;

      /end-free
     C                   endsr

730kA*----------------------------------------------------------------
730kA*  GetNextLbl#    Get next label number
730kA*----------------------------------------------------------------
730kA
730kAC     getNextLbl#   begsr
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
650nA
650nA*----------------------------------------------------------------
650nA*  getNxtPWO   Get Production Work Order Number
650nA*----------------------------------------------------------------
650nA
650nAC     getNxtPWO     begsr
650nA /free
650nA
650nA           savever# = $ppver#;
650nA           $ppver# = savever#;
650nA           wkwo# = '*err';
650nA
650nA   // get next available Work Order Number
650nA
650nA           $ppSessIdu = *on;
650nA           $ppSessid  = pSessId;
650nA           $ppwhseu = *on;
650nA           $ppwhse  = $pwhse;
650nA           $ppuser = #User;
650nA           $ppuseru = *on;
650nA
650nA           $dricommand = '*PROD';
650nA           $drisubcmd = '%GETNXTWO';
650nA           $drisys2upd = 'D';
650nA           exsr zzzDriCop;
650nA           if not drierr;
650nA              wkwo# = $ppwo#;
650nA           endif;
650nA
650nA /end-free
650nAC                   endsr

     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *          This routine is only called when looking for a bulk pick.
     *
     C     getopt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETOPT  '    trsubr
413aAC                   exsr      zztrck
520eA
520eAC                   call      'GETZONE'
520eAC                   parm      '*GET'        $zcmd             8
520eAC                   parm      $ptruk        $ztruk           10
520eAC                   parm      ' '           $zrtid            5
520eAC                   parm      ohtype        $zotype           1
520eAC                   parm      slwhse        $zwhse            3 0
520eAC                   parm      slwhdp        $zwhdp            5
520eAC                   parm      sldisp        $zdisp           12
520eAC                   parm      slstyp        $zstyp            1
520eAC                   parm      slaisl        $zaisl            3
520eAC                   parm      slloc         $zloc             3 0
520eAC                   parm      slrlvl        $zrlvl            2 0
520eAC                   parm      slhand        $zhand            2
520eAC                   parm      slitem        $zitem           15
520eAC                   parm      sldesg        $zdesg            5
520eAC                   parm      ' '           $zutyp            1
520eAC                   parm      'N'           $ztote            1
520eAC                   parm      ' '           $zszon            6
520eAC                   parm      ' '           $zpzon            6
520eAC                   parm      ' '           $ztzon            6
520eAC                   parm      ' '           $zcomp            1
520eAC                   parm      0             $zgen             1 0
520eAC                   parm                    opzdta
710aAC                   parm      ohord         $zord             7 0
720eAC                   parm      slactv        $zactv            2
720eAC                   parm      slpick        $zpick            1
520eA
740 AC                   if        chkchild = '1'
740 AC                   goto      #endgetopt
740 AC                   endif
740 AC
520eAC                   if        $zszon = 'ZZZZZZ'
520eAC                   eval      #dbpck = 999
520eAC                   else
520eAC                   eval      #dbpck = opbpck
520eAC                   endif

520eDC**
520eDC**  Get zone for home slot.
520eDC**
520eDC**                 eval      zone = *blanks
520eDC**
520eDC**   keyzd2        setll     zoned2
520eDC**                 dou       forevr <> forevr
520eDC**   keyzd2        reade     zoned2                                 79
520eDC**                 if        *in79
520eDC**                 leave
520eDC**                 endif
520eDC**
520eDC**     See if slot matches criteria.
520eDC**
520eDC**                 select
520eDC**
520eDC**       Location
520eDC**
520eDC**                 when      zdloc1 > 0  or
520eDC**                           zdloc1 > 0
520eDC**
520eDC**                 if        slloc >= zdloc1  and
520eDC**                           slloc <= zdloc2  and
520eDC**                           slaisl = zdaisl  and
520eDC**                           slstyp = zdstyp  and
520eDC**                           slwhdp = zdwhdp
520eDC**                 if        zdrlvl = 0  or
520eDC**                           slrlvl = zdrlvl
520eDC**                 eval      zone = zdzone
520eDC**                 endif
520eDC**                 endif
520eDC**                 iter
520eDC**
520eDC**       Level
520eDC**
520eDC**                 when      zdrlvl > 0
520eDC**
520eDC**                 if        slrlvl = zdrlvl  and
520eDC**                           slaisl = zdaisl  and
520eDC**                           slstyp = zdstyp  and
520eDC**                           slwhdp = zdwhdp
520eDC**                 eval      zone = zdzone
520eDC**                 endif
520eDC**                 iter
520eDC**
520eDC**       Aisle
520eDC**
520eDC**                 when      zdaisl <> *blanks
520eDC**
520eDC**                 if        slaisl = zdaisl  and
520eDC**                           slstyp = zdstyp  and
520eDC**                           slwhdp = zdwhdp
520eDC**                 eval      zone = zdzone
520eDC**                 endif
520eDC**                 iter
520eDC**
520eDC**       Section
520eDC**
520eDC**                 when      zdstyp <> *blank
520eDC**
520eDC**                 if        slstyp = zdstyp  and
520eDC**                           slwhdp = zdwhdp
520eDC**                 eval      zone = zdzone
520eDC**                 endif
520eDC**                 iter
520eDC**
520eDC**       Department
520eDC**
520eDC**                 when      zdwhdp <> *blank
520eDC**
520eDC**                 if        slwhdp = zdwhdp
520eDC**                 eval      zone = zdzone
520eDC**                 endif
520eDC**                 iter
520eDC**
520eDC**                 endsl
520eDC**
520eDC**                 enddo
520eDC**
520eDC**  Go through data structure to find options for department.
520eDC**  If department hasn't changed then there is nothing to do.
520eDC**
520eDC**                 if        zone <> #dzone
520eDC**   1             do        lstopt        xopt
520eDC**   xopt          occur     opts
520eDC**                 if        #dzone = zone
520eDC**                 leave
520eDC**                 endif
520eDC**                 enddo
520eDC**                 endif
     *
740 AC     #endgetopt    tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOD   Get order detail record.
     *
     C     getod         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETOD   '    trsubr
413aAC                   exsr      zztrck
     *
     *   If first time, set record pointer.
     *
     C                   if        odflag = *off
     C     keyod1        setll     ordd1
     C                   eval      odflag = *on
     C                   endif
     *
     *   Try to get a 'open' detail record for order.
     *
     C                   eval      stop = *off
VIP AC                   eval      nonalc = *off
     C                   dou       stop = *on  or
     C                             eofod = *on
     C     keyod1        reade     ordd1                                  79
     *
     *   Set flag if there are no more detail records.
     *
     C                   if        *in79
     C                   eval      eofod = *on
     C                   goto      endodl
     C                   endif
VIP1A*
VIP1A*   Retrieve Order Detail Misc. file record.
VIP1A*
640bDC**                 if        client = vip  or
640bDC**                           client = mjkeln
640bDC**                           or client = Savalfoods
640bDC**   keyom         chain     orddm                              79
640bDC**                 if        *in79
640bMC     keyom         chain     orddm
640bMC                   if        not %found(orddm)
VIP1AC                   eval      vipms1 = *blanks
VIP1AC                   eval      ompckm = *zeros
VIP1AC                   eval      omiaov = 'N'
VIP1AC                   eval      omcwcd = 'N'
VIP1AC                   eval      omwtiw = *zeros
VIP1AC                   eval      omcbec = *zeros
CBIuA*
CBIuAC                   If        client = cheney
CBIuAC                   eval      ocastop = *blanks
CBIuAC                   endif
SVL1A*
SVL1AC                   If        client = Savalfoods
SVL1AC                   eval      svldm1_filall = 'N'
SVL1AC                   endif
SVL1A*
SVL1AC                   else
SVL1AC                   If        client = Savalfoods
SVL1AC                   eval      svldm1_base = ommsc1
SVL1AC                   endif
CBIvAC                   If        client = cheney
CBIvAC                   eval      ocastop = %subst(ommsc2:15:3)
CBIvAC                   eval      orddm2_cbi = ommsc2
CBIvAC                   endif
VIP A*
VIP AC                   if           client = vip
MJK AC                             or client = mjkeln
FPR AC                             or client = foodpro
VIP AC                   eval      vipms1 = ommsc1
VIP AC                   endif
SVL1A*
VIP1AC                   endif
640bDC**                 endif
KFS A*
KFS AC                   if           client = Kellys
KFS AC                   eval      ompckm = 0
KFS AC                   eval      omwtiw = 0
KFS AC                   eval      omcbec = 0
KFS AC                   endif
SGC1AC*
SGC1AC*   Retrieve Order Detail Misc. file record.
SGC1AC*
SGC1AC                   if        client = SGC
640bDC**   keyom         chain     orddm
SGC1AC                   if        not %found(orddm)
SGC1AC                   eval      orddm1_sgc    = ' '
SGC1AC                   eval      sgcdm1_omalco = 'N'
SGC1AC                   eval      sgcdm1_ommpck = 'N'
SGC1AC                   else
SGC1AC                   eval      orddm1_sgc = ommsc1
SGC1AC                   endif
SGC1AC                   endif
640bA
640bA*   Set Batch Pick Item flag
640bA
GLPa *   GLP - ommsc1 'Y' means AMP short qty vs DelvRt
640bAC                   if        %found(orddm)
640bAC                             and %subst(ommsc1:1:1) = 'Y'
GLPa C                             and client <> greenleaf
CBIwAC                             or client = cheney
CBIwAC                             and thtruk = container
640bAC                   eval      batchPickItem = *on
640bAC                   exsr      GetBatchAlloc
640bAC                   else
640bAC                   eval      batchPickItem = *off
640bAC                   eval      batchPickQty1 = 0
640bAC                   endif
     *
     *   Get item master record.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR01'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'GETOD   '    trsr50
413aAC                   exsr      zztrck
     C                   else
414cAC                   exsr      zzxopt
414cAC                   eval      dscln = *blanks
414cAC                   if        uxflag = *off
414cAC                   movel     itdesc        dscln
414cAC                   else
414cAC                   movel     ixdsc1        dscln
414cAC                   move      ixdsc2        dscln
414cAC                   endif
CBIsA*
CBIsA*   Get Itemmsc record
CBIsAC                   if        client = Cheney
CBIsAC     keyit         chain     itemmsc
CBIsAC                   if        not %found(itemmsc)
CBIsAC                   eval      imbnbr = 0
CBIsAC                   eval      imbnam = ' '
CBIsAC                   endif
CBIsAC                   endif
CBIsA*
520eDC**                 exsr      getopt
     C                   eval      stop = *on
     C                   endif
730gA
730gA*   Get ORDDUM information
730gA
730gA /free
730gA
730gA    monitor;
           umWhse = odwhse;
730gA      umordd('*GET': umRtnCode: umRtnMsg:
730gA             umWhse: odord: odseq: odItem:
730gA             umFlexPickFlag:
730gA             oduorq1: oduoru1: oduorq2: oduoru2: oduorq3: oduoru3:
730gA             oduorman: oduormab1: oduormab2:
730gA             oduorman: oduormab1: oduormab2);
730gA    on-error;
730gA      umFlexPickFlag = '';
730gA    endmon;
730gA
730gA /end-free
730gA
700iA*   Set minimum acceptable expiration date based on customer expiry days
710bA*   and/or Distributor Days to Sell
700iA
700iA /free
710bA
710bA    hasCustDays = *off;
710bA    expDate = 0;
710bA
710bA    if itflgd = 'Y';
710bA
700iA      // Initialize acceptable expiration date to today.
710bA
700iA      expDate = today;
710bA
700iA      // Get item category code
710bA
710bA      callp getitemfld(itwhse: ititem: $gcat);
710bA
700iA      // Look for matching CUSTDAYS record.
710bA
710bA      savDays = 0;
710bA      savDist = 0;
710bA      savPriority = 0;
700iA
710bA      setll (ohwhse: ohcust) custdays;
710bA
710bA      dow forever = forever;
700iA
710bA        reade (ohwhse: ohcust) custdays;
710bA
710bA        if %eof(custdays);
710bA          leave;
710bA        endif;
710bA
710bA        select;
710bA
710bA          when savPriority < 4  // highest priority
710bA               and cedwhdp <> '' and itwhdp = cedwhdp
710bA               and cedcat <> '' and $gcat = cedcat;
710bA                 savPriority = 4;
710bA                 savDays = ceddays;
710bA                 savDist = ceddist;
710bA                 leave;
710bA
710bA          when savPriority < 3
710bA               and cedcat <> '' and $gcat = cedcat;
710bA                 savPriority = 3;
710bA                 savDays = ceddays;
710bA                 savDist = ceddist;
710bA
710bA          when savPriority < 2
710bA               and cedwhdp <> '' and itwhdp = cedwhdp;
710bA                 savPriority = 2;
710bA                 savDays = ceddays;
710bA                 savDist = ceddist;
710bA
710bA          when savPriority < 1   // lowest priority
710bA               and cedwhdp = '' and cedcat = '';
710bA                 savPriority = 1;
710bA                 savDays = ceddays;
710bA                 savDist = ceddist;
710bA
710bA        endsl;
710bA
710bA      enddo;
710bA
710bA      if savPriority > 0;
710bA
710bA        hasCustDays = *on;
710bA
710bA        // See if Distribution Days to Sell should be used
710bA        // Dist days will be added to savDays, thus making the
710bA        // CEDDAYS field 'Additional' instead of 'Acceptable' days.
710bA
710bA        if savDist = 1;
710bA
710bA          chain (itwhse: ititem) itemmsc;
710bA          if %found(itemmsc);
710bA            savDays += imdday;
710bA          endif;
710bA
710bA        endif;
710bA
700iA        expDate = %dec(%date(today)+%days(savDays):*iso);
710bA
710bA      endif;
710bA
710bA    endif;
710bA
700iA /end-free
     *
VIP A*    Create label records for Special Order item# 999999999.
VIP A*    No allocation, assume 100% allocated/picked.
GFC A*    Note: H&S uses Special Order item# 999999.
VIP AC                   select
VIP AC                   when      client = vip  or
MJK AC                             client = mjkeln
GFC AC                             or client = glazier
SOF AC                             or client = sofofoods
FPR AC                             or client = foodpro
SGCdAC                             or client = SGC
KFS AC                             or client = Kellys
710dAC                             or itdesg = 'NOALC'
VIP AC                   if        oditem = vip999
GFC AC                             or oditem = h_s999
710dAC                             or itdesg = 'NOALC'
KFS A*
KFS AC                             or client = Kellys
KFS AC                             and itwhdp = 'CHK'
KFS A*
VIP AC                   exsr      crtlwv
VIP AC                   endif
VIP AC                   endsl
     *
CBI A*    Create label records for non-stock items.
CBIaA*    Create label records for Meat Inspection items.
CBI A*
CBI Ac                   if        client = cheney
CBIpAC                             and clientloc <> cbipntgr
CBI AC                   select
CBI AC                   when      itwhdp = 'PRD  '
CBIaAC                             or meatin = 'Y'
CBIgAC                             or prepck = 'Y'
CBI AC                   exsr      crtlw2
CBI AC                   leave
CBI AC                   endsl
CBI Ac                   endif
411 A*
411 A*  Save information about item being picked (Item that was ordered)
411 A*
411 AC                   eval      #otype = ittype
411 AC                   eval      #oitem = ititem
411 AC                   eval      #odesc = itdesc
411 AC                   eval      #opdsc = itpdsc
411 AC                   eval      #bitem = ititem
417cAC                   eval      #sitem = ititem
413dAC                   eval      #bityp = ittype
417cAC                   eval      #sityp = ittype
411 AC                   eval      #bdesc = itdesc
411 AC                   eval      #bpdsc = itpdsc
411 A*
610bM*  If Contract, Alias, SSB or Repack item
411 A*   Then get Base item.
650bA*   Getbase no longer gets base information for Repack Items
411 A*
610bMC                   if        ittype = 'C'
610bMC                             or ittype = 'A'
610bMC                             or ittype = 'S'
650bDC*                            or ittype = 'R'
417cMC                   call      'GETBASE'
417cD**                   CALL @GETSI
411 AC                   parm      itwhse        $gwhse            3 0
411 AC                   parm      ititem        $gitem           15
411 AC                   parm      ' '           #bitem
411 AC                   parm                    #bityp            1
411 AC                   parm                    #bdesc           30
411 AC                   parm                    #bpdsc           15
417cD**                   PARM           #SRTN  10
417cD**                   PARM           #SMSG  60
417cMC                   parm                    #bwhdp            5
417cMC                   parm                    #bstyp            1
417cMC                   parm                    #bum              2
417cMC                   parm                    #bum2             2
417cMC                   parm                    #bumq2            3 0
417cMC                   parm                    #bum3             2
417cMC                   parm                    #bumq3            3 0
417cMC                   parm      ' '           #bcitm           15
417cMC                   parm                    #bctyp            1
417cMC                   parm                    #bcdsc           30
417cMC                   parm                    #bcpds           15
417cMC                   parm                    #bcwdp            5
417cMC                   parm                    #bcstp            1
417cMC                   parm                    #bcum             2
417cMC                   parm                    #bcum2            2
417cMC                   parm                    #bcuq2            3 0
417cMC                   parm                    #bcum3            2
417cMC                   parm                    #bcuq3            3 0
417cMC                   parm                    #brtn             8
411 AC                   endif
417cA*
417cA*  If Contract, Alias or SSB item
417cA*   Then get Base Slot item.
417cA*
417cAC                   if        ittype = 'A'  or
417cAC                             ittype = 'A'  or
417cAC                             ittype = 'S'
417bMC                   call      @getsi
417bAC                   parm      itwhse        $gwhse
417bAC                   parm      ititem        $gitem
417bAC                   parm      ' '           #sitem
417bAC                   parm                    #sityp            1
417bAC                   parm                    #sdesc           30
417bAC                   parm                    #spdsc           15
417bAC                   parm                    #srtn            10
417bAC                   parm                    #smsg            60
417cAC                   endif
     C     endodl        tag
     C                   enddo
     *
     *   If a record was found then get quantities.
     *
     C                   if        eofod <> *on
     *
     *      Convert ordered quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = odqor1
     C                   eval      $cqty2 = odqor2
     C                   eval      $cqty3 = odqor3
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
     C                   eval      p1qord = $cqstr
     C                   eval      p1qalc = *blanks
     C                   eval      p1qpck = *blanks
     *
     *      Initialize quantities for picking.
     *
     C                   eval      leftq1 = odqor1
     C                   eval      leftq2 = odqor2
     C                   eval      leftq3 = odqor3
     C                   eval      pickq1 = 0
     C                   eval      pickq2 = 0
     C                   eval      pickq3 = 0
520bAC                   eval      picku1 = 0
520bAC                   eval      picku2 = 0
520bAC                   eval      picku3 = 0
     C                   eval      ttlpk1 = 0
     C                   eval      ttlpk2 = 0
     C                   eval      ttlpk3 = 0
     C                   eval      remain = 0
640bA
640bA*   Reduce qty by Batch Pick allocation
640bA
640bAC                   if        batchPickItem
640bAC                   eval      leftq1 -= batchPickQty1
640bAC                   if        leftq1 < 0
640bAC                   eval      leftq1 = 0
640bAC                   endif
640bAC                   endif
411 A*
411 A*  If Same Slot Breakdown Item
411 A*   Then quantities need to be changed into corresponding
411 A*        Base breakdown quantities.
411 A*
411 AC                   if        ittype = 'S'  or
417cAC                             ittype = 'A'  and
417cAC                             #bityp = 'S'
411 AC                   eval      leftq3 = leftq2
411 AC                   eval      leftq2 = leftq1
411 AC                   eval      leftq1 = 0
411 AC                   endif
     *
411 D*
411 D*   We are no longer "uping" quantities.  We want to pick
411 D*     exactly what the customer ordered. Also, "uping"
411 D*     the quantity for and SSB item would really confuse
411 D*     the customer, as well as everyone else.
411 D*
411 D*      Make sure breakdown qty's are not greater than
411 D*        quantity in the unit of measure.
411 D*
411 D*R         LEFTQ3    DOWGEITUMQ3
411 D*R         ITUMQ3    ANDNE0
411 D*R                   SUB  ITUMQ3    LEFTQ3
411 D*R                   ADD  1         LEFTQ2
411 D*R                   ENDDO
411 D*                                          t@getit
411 D*R         LEFTQ2    DOWGEITUMQ2
411 D*R         ITUMQ2    ANDNE0
411 D*R                   SUB  ITUMQ2    LEFTQ2
411 D*R                   ADD  1         LEFTQ1
411 D*R                   ENDDO

610bAC                   eval      odritem = *blanks
610bAC                   eval      odrbaseSlot = *blanks
610bAC                   eval      odrbaseWhdp = *blanks
610bAC                   eval      odrbaseitem = *blanks
610bAC                   eval      odritemflag = *off
650bA *  move type "R" processing to call for zzCRTOdrQty
650bAC                   if        ittype<>'R'
610bAC                   call      @getit
610bAC                   parm      $pwhse        $gWhse            3 0
610bAC                   parm      ititem        $gItem           15
610bAC                   parm      ' '           $gCat            10
610bAC                   parm      ' '           $gCaseOvf         1
610bAC                   parm      ' '           $gODRSlot        12
610bAC                   if        $gODRSlot <> *blanks
610bAC                   eval      odritem = ititem
610bAC                   eval      odritemflag = *on
610bAC                   eval      odrbaseslot = $gODRSlot
610bAC                   eval      odrbaseWhdp = itwhdp
610bAC                   eval      odrbaseitem = #bitem
610bAC                   endif
650bAC                   endif
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOH   Get order header record.
     *
     C     getoh         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'GETOH   '    trsubr
413aAC                   exsr      zztrck
     *
     *   If first time, set record pointer.
     *
     C                   if        ohflag = *off
     C     keyoh2        setll     ordh2
     C                   eval      ohflag = *on
     C                   endif
     *
     *   Try to get a 'open' header record.
     *
     C     keyoh2        reade     ordh2                                  79
     *
     *   Set flag if there are no more header records.
     *
     C                   if        *in79
     C                   eval      eofoh = *on
     C                   endif
     *
     C                   movel     ohcnam        p1cnam
     *
     C                   endsr
700fA*----------------------------------------------------------------
700fA*  GetSlotdef   Get slotdef record
700fA*----------------------------------------------------------------
700fA
700fAC     GetSlotdef    begsr
700fA /free
700fA    chain (slwhse: slsdef) slotdef;
700fA    if not %found;
700fA      sdpal = '';
700fA    endif;
700fA /end-free
700fAC                   endsr
415 A*----------------------------------------------------------------
415 A*
415 A*  OPNPRT  Open printer file.
415 A*
415 AC     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        $pwhse <> lstwhs
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OR610PR'     $lrpt            10
     C                   parm      $pwhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $whse
WSFbA*
WSFbA*   Send report for will-calls to alternate printer.
WSFbA*
WSFbAC                   if        client = westside
WSFbAC                             and $potyp = 'W'
WSFbAC                   movel     'P4'          $DEV
WSFbAC                   endif
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or610pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR610PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
720bA*
720bAC                   eval      qcmd = %trim(qcmd) + ' USRDFNDTA(''W/H:'
720bAC                             + %editc($pwhse : 'X')
720bAC                             + ' / Route:'
720bAC                             + %trim($prte)
720bAC                             + ''')'
     *
     C                   call      'QCMDEXC'
720bMC                   parm                    qcmd            200
720bMC                   parm      200           qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or610pr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
700aA*
700aA*  PICKAMP  Pick AMP items from AMP slots.  If qty to pick
700aA*  greater than available from AMP slots, pick rest from normal
700aA*  slots using subr PICKF2.
700aA*
700aAC     pickAMP       begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKAMP '    trsubr
     C                   exsr      zztrck
     *
     *   Loop through AMP-pick slots for order/item.
     *
700a C     keyAMPX1a     setll     ampxref1
     C                   dou       forevr <> forevr
700a C     keyAMPX1a     reade     ampxref1
     C                   if        %eof
     C                   leave
     C                   endif
     *
     *   Get corresponding AMP label record.
     *
730jDC*    axalbl#       chain     label
730jA /free
730jA                    chain ($pwhse: axalbl#) labelw;
730jA /end-free
730jMC                   if        not %found(labelw)
     C                   iter
     C                   endif
     *
     *   Get corresponding AMP slot record.
     *
700a C     keysl2b       chain     slot2
     C                   if        not %found(slot2)
     C                   iter
     C                   endif
     C                   eval      kystat = slstat
     C                   eval      kypick = slpick
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
     C                             itflgd = 'Y'
     C                   eval      trnbr = 'TR09'
     C                   eval      trcode = '*PCK050 '
700a C                   movel     'PICKAMP '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Pick only what is available.
     *
     C                   eval      pckall = *off
     C                   exsr      avail
     C                   exsr      pick0
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     *   Get slot record to update
     C     keys3c        chain     slot3
     C                   if        not %found(slot3)
     C                   iter
     C                   endif
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
700a *     Update AMPXREF record.
700b C                   eval      axdlbl# = lwlbl#
     C                   eval      axdrtid = ohrte
     C                   eval      axdord = ohord
     C                   eval      axdseq = odseq
700a *     new to add qty to special pick - AMP
     C                   eval      axdqty1 = ttlpk1
     C                   eval      axdqty2 = ttlpk2
     C                   eval      axdqty3 = ttlpk3
     *
700a C                   update    axrec
700a C                   eval      ttlpk1 = 0
700a C                   eval      ttlpk2 = 0
700a C                   eval      ttlpk3 = 0
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     C                   enddo
     *
700aAC                   endsr
     *----------------------------------------------------------------
     *
     *  PICKF   Pick fixed item.
     *
412 A*    *** Replaced by PICKF2 *****
     *
     *  Note:
     *
     *    A fixed item is only allowed to have one picking slot.
     *    The entire quantity needed is allocated from this slot
     *    whether or not there is enough physical stock in the slot.
     *    Because a general allocation has already been done we know
     *    that there should be enough quantity in the warehouse to
     *    fill the quantity that is needed. Replenishments will be
     *    determined when the labels are printed.
     *
     *    During general allocation a check was made to see if a
     *    carton needed to be broken to fill the order. If one did
     *    the stock quantity was adjusted to reflect this. However,
     *    since we allocate everything from one picking slot we will
     *    not know what is actually in the slot until picking time.
     *    Therefore, we wait until then to break a carton for the
     *    slot.
     *
     C     pickf         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKF   '    trsubr
413aAC                   exsr      zztrck
     *
     *   Get the picking slot for the item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C     keysl3        reade     slot3                                  77
409 A*
409 A*      Make sure picking slot date is not expired.
409 A*      If it is treat as if picking slot does not exist.
VIP3A*      For VIP,EI,Glazier process pick slots even if expired.
409 A*
CBIeAc                   if        client <> cheney
CBIrAc                             or hasCustDays
409 AC                   if        not *in77  and
409 AC                             itflgd = 'Y'  and
409 AC                             slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
VIP3A*
VIP3AC                             client <> vip
EI  AC                             and client <> ei
GFC3AC                             and client <> glazier
VIP3A*
409 AC                   eval      *in77 = *on
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKF   '    trsr50
413aAC                   exsr      zztrck
409 AC                   endif
CBIeAC                   endif
     C                   select
     *
     *   Picking slot does not exist.  Use bulk pick routine to pick
     *   everything from replenishment slots. If everything could not
     *   be picked then print an error.
     *
     C                   when      *in77  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             *in77  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
     *
     *      Pick everything from replenishment slots.
     *
     C                   exsr      pickrp
410 AC                   goto      pickfe
     *
     *
     *
     *
     *    Picking slot exists so allocate everything.
     *
     C                   other
     *
     *      Check for bulk pick for normal quantity.
     *
     C                   if        thbulk = 'Y'  and
     C                             itflgb = 'Y'  and
     C                             leftq1 > 0  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             thbulk = 'Y'  and
414aAC                             itflgb = 'Y'  and
414aAC                             leftq1 > 0  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
650qA*
650qAc                             or
650qAc                             thbulk = 'Y'  and
650qAc                             itflgb = 'C'  and
650qAc                             leftq1 > 0  and
650qAc                             ophpwc = 'N'  or
650qA*
650qAc                             thbulk = 'Y'  and
650qAc                             itflgb = 'C'  and
650qAc                             leftq1 > 0  and
650qAc                             ophpwc = 'Y'  and
650qAc                             $potyp <> 'W'
650qac
     C                   exsr      getopt
     **         #DBPCK    IFLE LEFTQ1
     C                   eval      blkpct = #dbpck
     C                   eval      hmwhse = slwhse
     C                   eval      hmwhdp = slwhdp
     C                   eval      hmstyp = slstyp
     C                   eval      hmaisl = slaisl
     C                   eval      hmloc = slloc
     C                   eval      hmrlvl = slrlvl
     C                   eval      hmhand = slhand
     C                   eval      hmdisp = sldisp
     C                   exsr      bulkpk
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C     keysl3        reade     slot3                                  77
     **                   ENDIF
     C                   endif
     *
     *      Then allocate the rest from the pick slot.
     *
     C                   eval      pickq1 = leftq1
     C                   eval      pickq2 = leftq2
     C                   eval      pickq3 = leftq3
     *
     *      Create picking label(s) and update totals.
     *
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = 0
     C                   eval      leftq2 = 0
     C                   eval      leftq3 = 0
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     *
     C                   endsl
     *
     *
410 A*      Create picking exception label(s).
     *
410 AC                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
410 AC                   if        excpq1 > 0  or
410 AC                             excpq2 > 0  or
410 AC                             excpq3 > 0
410 AC                   eval      pickq1 = excpq1
410 AC                   eval      pickq2 = excpq2
410 AC                   eval      pickq3 = excpq3
410 AC                   eval      lwltyp = 'O'
410 AC                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = 'OUT'
410 AC                   exsr      post
410 AC                   endif
410 AC                   endif
     *
     C     pickfe        endsr
412 A*----------------------------------------------------------------
412 A*
412 A*  PICKF2  Pick fixed item from multiple pick slots
412 A*
     *  Note:
     *
     *    This routine replaced the PICKF routine.
     *
     *    A fixed item can have more than one pick (home) slot.
     *    First, an attempt is made to pick the item as a bulk
     *    pick. If there is still quantity to be picked, a check
     *    is done to see if the item has any non-expired pick
     *    slots.  If it does not, then the rest of the quanitity
     *    is pick from overflow slots as bulk picks.
     *
     *    If a pick slot(s) exists, the quantity needed is allocated
     *    similarly to PIR allocation - Only the quantity available
     *    in the pick slot can be allocated. If quantity still
     *    remains after the allocation, the remaining quantity is
     *    allocated from the last slot read. Because a general
     *    allocation has already been done, we know that there
     *    should be enough quantity in the warehouse to fill the
     *    quantity that is needed. Letdowns will be determined
     *    when the labels are printed.
     *
     C     pickf2        begsr
720dA*
720dA*  Clear save fields since values can remain depending on whether
720dA*  slots are available for Store or Warehouse when Store Slots used
720dA*
720hDC*                  eval      svwhse = *zeros
720hAC                   eval      svwhse = itwhse
720dAC                   eval      svwhdp = itwhdp
720dAC                   eval      svstyp = itstyp
720dAC                   eval      svaisl = *blanks
720dAC                   eval      svloc = *zeros
720dAC                   eval      svrlvl = *zeros
720dAC                   eval      svhand = *blanks
720dAC                   eval      svdisp = *blanks
720dAC                   eval      svpseq = *zeros
720hDC*                  eval      ssvwhse = *zeros
720hAC                   eval      ssvwhse = itwhse
720dAC                   eval      ssvwhdp = itwhdp
720dAC                   eval      ssvstyp = itstyp
720dAC                   eval      ssvaisl = *blanks
720dAC                   eval      ssvloc = *zeros
720dAC                   eval      ssvrlvl = *zeros
720dAC                   eval      ssvhand = *blanks
720dAC                   eval      ssvdisp = *blanks
720dAC                   eval      ssvpseq = *zeros
700fA*
700fA*  Do Special *EACH processing first
700fA*
700fAC                   if        leftq2 > 0  or
700fAC                             leftq3 > 0
700fAc                   exsr      pickf2ea
700fAc                   endif
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKF2  '    trsubr
413aAC                   exsr      zztrck
520fA*
520fA*   Get 'Pick cases from overflow' option for item.
520fA*
610bD ***                if        client = SGC
610bD*   Only temporary until SGC gets updated with new ITEMFLD file.
610bD ***                else
610bD ***                call      'GETITEMFLD'
610bD ***                parm      $pwhse        $gWhse            3 0
610bD ***                parm      #sitem        $gItem           15
610bD ***                parm      ' '           $gCat            10
610bD ***                parm      ' '           $gCaseOvf         1
610bD ***                parm      ' '           $gODRSlot        12
610bD ***                endif
     *
     C                   dow       forevr = forevr
     *
     *  Step 1 -  Check for existing pick slot.
     *
     C                   eval      pckcnt = 0
720dAC                   eval      spckcnt = 0
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     *
     C                   dow       forevr = forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
520jAC*Item does not have a pick slot
720dDC*                  if        pckcnt=0
720dMC                   if        pckcnt=0 and spckcnt=0
WSFcAC                   if        client <> westside
730hAc                             and not dpck
650hAC                   eval      p1msg = msg(5)
650hAC                   exsr      prterr
WSFcAC                   endif

520jAC                   eval      svwhse = itwhse
520jAC                   eval      svwhdp = itwhdp
520jAC                   eval      svstyp = itstyp
520jAC                   eval      svaisl = *blanks
520jAC                   eval      svloc = *zeros
520jAC                   eval      svrlvl = *zeros
520jAC                   eval      svhand = *blanks
520jAC                   eval      svdisp = *blanks
520jAC                   eval      svpseq = *zeros
520jAC                   endif
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
700fA*
700fA*     Skip special *EACH pick slots
700fA*
700fA * We need to exclude *EACH slot
700fA * need to get slot definition before proceeding
700fAC                   exsr      GetSlotdef
700fAC                   if        sdpal = '*EACH'
700fAc                   iter
700fAc                   endif
     *
     *    Skip expired slots.
VIP3A*      For VIP,EI,Glazier process pick slots even if expired.
     *
CBIeAc                   if        client <> cheney
CBIrAc                             or hasCustDays
     C                   if        itflgd = 'Y'  and
     C                             slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
VIP3A*
VIP3AC                             client <> vip
EI  AC                             and client <> ei
GFC3AC                             and client <> glazier
VIP3A*
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKF2  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
CBIeAc                   endif
PCKfD**
PCKfD**  Skip slots with no available quantity.
PCKfD**
PCKfD**                   EXSR AVAIL
PCKfD**         AVAIL1    IFLE 0
PCKfD**                   ITER
PCKfD**                   ENDIF
720dA*
720dA*     If customer uses remote warehouse slots such as store skip those slo
720dA*     since we are not processing will call orders here
720dA*
720dA /free
720dA                    eval storeQty = *off;
720dA                    eval storeSlot = *off;
720dA                    if opssLcn = 'Y';      // Uses Staging/Store Slots
720dA                      chain (slwhse:slwhdp:sldisp) slotStr;
720dA                      if %found(slotStr);
720dA                        storeSlot=*on;
720dA                      endif;
720dA                    endif;
720dA /end-free
     *
     *    Increment pick slot counter and save slot.
     *
720dAc                   if        not storeSlot
     C                   add       1             pckcnt
     C                   eval      svwhse = slwhse
     C                   eval      svwhdp = slwhdp
     C                   eval      svstyp = slstyp
     C                   eval      svaisl = slaisl
     C                   eval      svloc = slloc
     C                   eval      svrlvl = slrlvl
     C                   eval      svhand = slhand
     C                   eval      svdisp = sldisp
     C                   eval      svpseq = slpseq
720dAc                   else
720dA*    if it is a store slot see if quantity exists
720dAc                   if        slstk1<>*zeros or slstk2<>*zeros
720dAc                               or slstk3<>*zeros
720dAc                   eval      storeQty=*on
720dAC                   add       1             spckcnt
720dAC                   eval      ssvwhse = slwhse
720dAC                   eval      ssvwhdp = slwhdp
720dAC                   eval      ssvstyp = slstyp
720dAC                   eval      ssvaisl = slaisl
720dAC                   eval      ssvloc = slloc
720dAC                   eval      ssvrlvl = slrlvl
720dAC                   eval      ssvhand = slhand
720dAC                   eval      ssvdisp = sldisp
720dAC                   eval      ssvpseq = slpseq
720dAc                   endif
720dAc                   endif
     *
     C                   enddo
     *
     *  Step 2 -  Check for bulk pick for normal quantity.
     *
     C                   if        thbulk = 'Y'  and
     C                             itflgb = 'Y'  and
     C                             leftq1 > 0  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             thbulk = 'Y'  and
414aAC                             itflgb = 'Y'  and
414aAC                             leftq1 > 0  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
650qAc                             or
650qAC                             thbulk = 'Y'  and
650qAC                             itflgb = 'C'  and
650qAC                             leftq1 > 0  and
650qAC                             ophpwc = 'N'  or
650qA*
650qAC                             thbulk = 'Y'  and
650qAC                             itflgb = 'C'  and
650qAC                             leftq1 > 0  and
650qAC                             ophpwc = 'Y'  and
650qAC                             $potyp <> 'W'
720dA*  move in either warehouse or store slot based on findings
720dAc                   select
720dAc                   when      pckcnt <> 0
414b C                   eval      slwhse = svwhse
414b C                   eval      slwhdp = svwhdp
414b C                   eval      slstyp = svstyp
414b C                   eval      slaisl = svaisl
414b C                   eval      slloc = svloc
414b C                   eval      slrlvl = svrlvl
414b C                   eval      slhand = svhand
414b C                   eval      sldisp = svdisp
720dAc                   when      spckcnt <> 0
720dAC                   eval      slwhse = ssvwhse
720dAC                   eval      slwhdp = ssvwhdp
720dAC                   eval      slstyp = ssvstyp
720dAC                   eval      slaisl = ssvaisl
720dAC                   eval      slloc = ssvloc
720dAC                   eval      slrlvl = ssvrlvl
720dAC                   eval      slhand = ssvhand
720dAC                   eval      sldisp = ssvdisp
720dAc                   endsl
     C                   exsr      getopt
520iAC                   if        $zpzon = *blanks
     C                   eval      blkpct = #dbpck
     C                   eval      hmwhse = slwhse
     C                   eval      hmwhdp = slwhdp
     C                   eval      hmstyp = slstyp
     C                   eval      hmaisl = slaisl
     C                   eval      hmloc = slloc
     C                   eval      hmrlvl = slrlvl
     C                   eval      hmhand = slhand
     C                   eval      hmdisp = sldisp
     C                   exsr      bulkpk
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
520iAC                   endif
     *
     C                   endif
     *
     *  Step 3 -  Allocate remainder of product.
     *
     C                   select
     *
     *    If picking slot does not exist . . .
     *      Pick everything from replenishment slots.
     *
720dDc*                  when      pckcnt = 0
720dMC                   when      pckcnt = 0  and spckcnt=0
     C                   exsr      pickrp
     *
     *    Marques special routine to handle Store Slot Routines
     *
730aDc*                  when      opssLcn = 'Y' and ohType<>'W'
730aMc                   when      opssLcn = 'Y'
MQS Ac                             and client=Marques
MQSaA /free
MQSaA    // Set Slot Priority for Store Slots to 3 so they will be
MQSaA    // found after Warehouse Slots
MQSaA    exec sql update slot10 set slprty=3
MQSaA             where slwhse=:$pWhse and
MQSaA                   slstat='A' and slitem=:#sitem and
MQSaA            (select count(*) from slotstr where
MQSaA              stwhse=slwhse and stwhdp=slwhdp and stdisp=sldisp)>0;
MQSaA /end-free
MQS AC                   exsr      pickmpStr
     *
     *    Otherwise . . .
     *      Pick everything from pick slots.
     *
     C                   other
     C                   exsr      pickmp
     *
     C                   endsl
     *
     C                   leave
     C                   enddo
     *
     C     pckf2e        endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  PICKF2EA Pick fixed item for *EACH pick slots
700fA*
700fA*  Note:
700fA*
700fA*    This routine will first deal breakdown ordered qty for
700fA*    *EACH slot.
700fA*
700fA*    When a breakdown qty is ordered, we will check for a slot
700fA*    with a slot definition assigned a pallet code of *EACH.
700fA*    If we find a slot with the pallet code of *EACH, we will
700fA*    allocate the breakdown qty ordered to that slot.
700fA*    If no slot with the pallet code of *EACH is found the
700fA*    normal allocation process will occur.
700fA*
700fA*    Items are only allowed one slot with pallet code *EACH.
700fA*
700fAC     pickf2EA      begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'PICKF2EA'    trsubr
700fAC                   exsr      zztrck
700fA*
700fAC                   dow       forevr = forevr
700fA*
700fA*  Step 1 -  Check for existing *EACH pick slot.
700fA*
700fAC                   eval      pckcnteach = 0
700fAC                   eval      kystat = 'A '
700fAC                   eval      kypick = 'Y'
700fAC     keysl3        setll     slot3
700fA*
700fAC                   dow       forevr = forevr
700fAC     keysl3        reade     slot3                                  77
700fAC                   if        *in77
700fAC*Item does not have a pick slot
700fAC                   leave
700fAC                   endif
700fA*
700fA*     Skip special license tracking slots
700fA*
700fAC                   if        sldesg = 'BFC'
700fAC                   iter
700fAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
700fA * We are looking for *EACH slot
700fA * need to get slot definition before proceeding
700fAC                   exsr      GetSlotdef
700fAC                   if        sdpal <> '*EACH'
700fAc                   iter
700fAc                   endif
700fA*
700fA*    Skip expired slots.
700fA*      For VIP,EI,Glazier process pick slots even if expired.
700fA*
700fAC                   if        itflgd = 'Y'  and
700fAC                             slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
700fA*
700fAC                             client <> vip
700fAC                             and client <> ei
700fAC                             and client <> glazier
700fA*
700fAC                   eval      trnbr = 'TR09'
700fAC                   eval      trcode = '*PCK050 '
700fAC                   movel     'PICKF2EA'    trsr50
700fAC                   exsr      zztrck
700fAC                   iter
700fAC                   endif
700fA*
700fA*    Increment pick slot counter and save slot.
700fA*
700fAC                   add       1             pckcnteach
700fAC                   eval      svwhse = slwhse
700fAC                   eval      svwhdp = slwhdp
700fAC                   eval      svstyp = slstyp
700fAC                   eval      svaisl = slaisl
700fAC                   eval      svloc = slloc
700fAC                   eval      svrlvl = slrlvl
700fAC                   eval      svhand = slhand
700fAC                   eval      svdisp = sldisp
700fAC                   eval      svpseq = slpseq
700fA*
700fAC                   enddo
700fA*
700fA*  Step 2 -  Allocate remainder of Each product.
700fA*
700fAC                   select
700fA*
700fA*    If picking slot does not exist . . .
700fA*      Get out of here.
700fA*
700fAC                   when      pckcnteach = 0
700fAc                   leavesr
700fA*
700fA*    Otherwise . . .
700fA*      Pick breakdown from *EACH pick slot.
700fA*
700fAC                   other
700fAC                   exsr      pickmpea
700fA*
700fAC                   endsl
700fA*
700fAC                   leave
700fAC                   enddo
700fA*
700fAC     pckf2eEA      endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  PICKMPEA  Pick breakdown  item from *EACH pick slot.
700fA*
700fA*  Note:  Within this routine, we allocate ALL of the
700fA*         breakdown qty ordered for the item to the *EACH
700fA*         pick slot. An Item can have only one *EACH pick slot.
700fA*
700fA*
700fAC     pickmpea      begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'PICKMPEA'    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*   Loop through picking slots for item.
700fA*
700fAC                   eval      kystat = 'A '
700fAC                   eval      kypick = 'Y'
700fAC     keysl3        setll     slot3
700fAC                   dou       forevr <> forevr
700fAC     keysl3        reade     slot3                                  77
700fAC                   if        *in77
700fAC                   leave
700fAC                   endif
700fA*
700fA*     Skip special license tracking slots
700fA*
700fAC                   if        sldesg = 'BFC'
700fAC                   iter
700fAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
700fA * We are looking for *EACH slot
700fA * need to get slot definition before proceeding
700fAC                   exsr      GetSlotdef
700fAC                   if        sdpal <> '*EACH'
700fAc                   iter
700fAc                   endif
700fA*
700fA*     Ignore slot if past expiration date.
700fA*      For VIP,EI,Glazier process pick slots even if expired.
700fA*
700fAC                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
700fAC                             itflgd = 'Y'  and
700fA*
700fAC                             client <> vip
700fAC                             and client <> ei
700fAC                             and client <> glazier
700fA*
700fAC                   eval      trnbr = 'TR09'
700fAC                   eval      trcode = '*PCK050 '
700fAC                   movel     'PICKMPEA'    trsr50
700fAC                   exsr      zztrck
700fAC                   iter
700fAC                   endif
700fA*
700fA*     If slot matches last pick slot read in PICKF2
700fA*       then allocate remainder from slot.
700fA*
700fAC                   if        slwhdp = svwhdp  and
700fAC                             slstyp = svstyp  and
700fAC                             slaisl = svaisl  and
700fAC                             slloc = svloc  and
700fAC                             slrlvl = svrlvl  and
700fAC                             slhand = svhand  and
700fAC                             (ipprdflg <> 'F' or
700fAc                              tavail1 > tpsltqty1)
700fA*
700fA*
700fAC                   eval      pckall = *on
700fAC                   exsr      avail
700fAC                   exsr      pick0ea
700fA*
700fA*     Otherwise, pick only what is available.
700fA*
700fAC                   else
700fA*
700fAC                   eval      pckall = *off
700fAC                   exsr      avail
700fAC                   exsr      pick0ea
700fA*
700fAC                   endif
700fA*
700fA*     If something was picked create picking label(s).
700fA*
700fAC                   if        pickq2 <> 0  or
700fAC                             pickq3 <> 0
700fAC                   eval      lwltyp = 'O'
700fAC                   eval      lwlqav = 0
700fAC                   eval      lwlas2 = *blanks
700fAC                   exsr      postea
700fAC                   eval      leftq2 = leftq2 - pickq2
700fAC                   eval      leftq3 = leftq3 - pickq3
700fAC                   add       pickq2        ttlpk2
700fAC                   add       pickq3        ttlpk3
700fAC                   endif
700fA*
700fA*     No need to look further, if no quantity left to pick.
700fA*
700fAC                   if        leftq2 = 0  and
700fAC                             leftq3 = 0
700fAC                   leave
700fAC                   endif
700fA*
700fAC                   enddo
700fA*
700fA*   If everything wasn't picked then print an error.
700fA*
700fAC                   if        leftq2 <> 0  or
700fAC                             leftq3 <> 0
700fA*
700fA*      If Production Item update remaining quantity and return to
700fA*      force to a Customer Specific Production slot
700fA*
700fAc                   if        ipprdflg = 'F'
700fAc                   eval      rmavail2 = leftq2
700fAc                   eval      rmavail3 = leftq3
700fAc                   else
700fA*
700fA*      Unallocate quantity left because it couldn't be allocated.
700fA*
700fAC                   exsr      unalocea
700fA*
700fA*      Convert picked quantity to string for error msg.
700fA*
700fAC                   eval      $ccmd = '*QTY2STR'
700fAC                   move      '#PROG   '    $cprg
700fAC                   if        ittype = 'S'
700fAC                   eval      $cqty1 = pickq2
700fAC                   eval      $cqty2 = pickq3
700fAC                   eval      $cqty3 = 0
700fAC                   else
700fAC                   eval      $cqty2 = pickq2
700fAC                   eval      $cqty3 = pickq3
700fAC                   endif
700fAC                   call      'CVTQTY'
700fAC                   parm                    $ccmd
700fAC                   parm                    $cprg
700fAC                   parm                    $cqty1
700fAC                   parm                    $cqty2
700fAC                   parm                    $cqty3
700fAC                   parm                    $cum1
700fAC                   parm                    $cum2
700fAC                   parm                    $cum3
700fAC                   parm                    $cqstr
700fAC                   parm                    $custr
700fAC                   parm                    $crtn
700fAC                   parm                    $cerm
700fAC                   eval      p1qpck = $cqstr
700fA*
700fA*      Print error message.
700fA*
700fAC                   eval      p1msg = msg(4)
700fAC                   exsr      prterr
700fAC                   eval      trnbr = 'TR04'
700fAC                   eval      trcode = '*PCK050 '
700fAC                   movel     'PICKMPEA'    trsr50
700fAC                   exsr      zztrck
700fAC                   endif
700fAC                   endif
700fA*
700fA*      Create picking exception label(s).
700fAC                   if        opelbl = 'Y'  and
700fAC                             ophpwc = 'N'  or
700fA*
700fAC                             opelbl = 'Y'  and
700fAC                             ophpwc = 'Y'  and
700fAC                             $potyp <> 'W' or
700fAC                             client = Savalfoods and
700fAC                             $potyp = 'W'
700fA*
700fAC                             or client = SGC
700fAC                             and opelbl = 'N'
700fAC                             and sgcdm1_omalco = 'Y'
700fA*
700fAC                   add       leftq2        excpq2
700fAC                   add       leftq3        excpq3
700fAC                   if        excpq2 > 0  or
700fAC                             excpq3 > 0
700fAC                   clear                   slrec
700fAC                   eval      slwhse = svwhse
700fAC                   eval      slwhdp = svwhdp
700fAC                   eval      slstyp = svstyp
700fAC                   eval      slaisl = svaisl
700fAC                   eval      slloc = svloc
700fAC                   eval      slrlvl = svrlvl
700fAC                   eval      slhand = svhand
700fAC                   eval      sldisp = svdisp
700fAC                   eval      slpseq = svpseq
700fAC                   eval      pickq1 = excpq1
700fAC                   eval      pickq2 = excpq2
700fAC                   eval      pickq3 = excpq3
700fAC                   eval      lwltyp = 'O'
700fAC                   eval      lwlqav = 0
700fAC                   eval      lwlas2 = 'OUT'
700fAC                   exsr      postea
700fAC                   endif
700fAC                   endif
700fA*
700fAC                   endsr
412 A*----------------------------------------------------------------
412 A*
412 A*  PICKMP  Pick fixed item from pick slot(s).
412 A*
     *  Note:  Within this routine, we allocate as much as we can
     *         from each pick slot for the item. If the pick slots
     *         do not contain enough product then the remainder is
     *         allocated from the last good pick slot read.
     *
     *         If a carton has to be broken the stock quantity is
     *         adjusted for the slot. This adjustment has already
     *         been done at the warehouse level when the item was
     *         initially allocated.
     *
     C     pickmp        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKMP  '    trsubr
413aAC                   exsr      zztrck
     *
     *   Loop through picking slots for item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
700fA*
700fA*     Skip special *EACH pick slots
700fA*
700fA * We need to exclude *EACH slot
700fA * need to get slot definition before proceeding
700fAC                   exsr      GetSlotdef
700fAC                   if        sdpal = '*EACH'
700fAc                   iter
700fAc                   endif
     *
     *     Ignore slot if past expiration date.
VIP3A*      For VIP,EI,Glazier process pick slots even if expired.
     *
CBIeAc                   if        client <> cheney
CBIrAc                             or hasCustDays
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'  and
VIP3A*
VIP3AC                             client <> vip
EI  AC                             and client <> ei
GFC3AC                             and client <> glazier
VIP3A*
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKMP  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
CBIeAc                   endif
     *
     *     If slot matches last pick slot read in PICKF2
     *       then allocate remainder from slot.
     *
     C                   if        slwhdp = svwhdp  and
     C                             slstyp = svstyp  and
     C                             slaisl = svaisl  and
     C                             slloc = svloc  and
     C                             slrlvl = svrlvl  and
650nMC                             slhand = svhand  and
650nAC                             (ipprdflg <> 'F' or
650nAc                              tavail1 > tpsltqty1)
650nAc*                             tavail1 > leftq1)
650nDC*                            slhand = svhand
     *
520bD**                   Z-ADDLEFTQ1    PICKQ1
520bD**                   Z-ADDLEFTQ2    PICKQ2
520bD**                   Z-ADDLEFTQ3    PICKQ3
520bA*
520bAC                   eval      pckall = *on
520bAC                   exsr      avail
520bAC                   exsr      pick0
     *
     *     Otherwise, pick only what is available.
     *
     C                   else
     *
520bAC                   eval      pckall = *off
     C                   exsr      avail
     C                   exsr      pick0
     *
     C                   endif
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
650nA*
650nA*      If Production Item update remaining quantity and return to
650nA*      force to a Customer Specific Production slot
650nA*
650nAc                   if        ipprdflg = 'F'
650nAc                   eval      rmavail1 = leftq1
650nAc                   eval      rmavail2 = leftq2
650nAc                   eval      rmavail3 = leftq3
650nAc                   else
     *
     *      Unallocate quantity left because it couldn't be allocated.
     *
     C                   exsr      unaloc
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   if        ittype = 'S'
     C                   eval      $cqty1 = pickq2
     C                   eval      $cqty2 = pickq3
     C                   eval      $cqty3 = 0
     C                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
     C                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR04'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKMP  '    trsr50
413aAC                   exsr      zztrck
650nAC                   endif
     C                   endif
     *
     *      Create picking exception label(s).
     C                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC*                            $potyp <> 'W'
SVLbAC                             $potyp <> 'W' or
SVLbAC                             client = Savalfoods and
SVLbAC                             $potyp = 'W'
SGCcA*
SGCcAC                             or client = SGC
SGCcAC                             and opelbl = 'N'
SGCcAC                             and sgcdm1_omalco = 'Y'
SGCcA*
     C                   add       leftq1        excpq1
     C                   add       leftq2        excpq2
     C                   add       leftq3        excpq3
     C                   if        excpq1 > 0  or
     C                             excpq2 > 0  or
     C                             excpq3 > 0
     C                   clear                   slrec
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      slstyp = svstyp
     C                   eval      slaisl = svaisl
     C                   eval      slloc = svloc
     C                   eval      slrlvl = svrlvl
     C                   eval      slhand = svhand
     C                   eval      sldisp = svdisp
     C                   eval      slpseq = svpseq
     C                   eval      pickq1 = excpq1
     C                   eval      pickq2 = excpq2
     C                   eval      pickq3 = excpq3
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = 'OUT'
     C                   exsr      post
     C                   endif
     C                   endif
     *
     C                   endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  PICKMPSTR  Pick fixed item from pick slot(s).
720dA*
720dA*  Note:  Copied from PICKMP.  Special code to handle
720dA*         allocation differences at Marques with the company
720dA*         store slots
720dA*
720dAC     pickmpStr     begsr
720dA*
720dA*  Write out tracking record.
720dA*
720dAC                   eval      trcode = '*PCK040 '
720dAC                   movel     'PICKMP  '    trsubr
720dAC                   exsr      zztrck
720dA*
720dA*   Loop through picking slots for item.
720dA*
720dAC                   eval      kystat = 'A '
720dAC                   eval      kypick = 'Y'
720dAC     keysl3        setll     slot3
720dAC                   dou       forevr <> forevr
720dAC     keysl3        reade     slot3                                  77
720dAC                   if        *in77
720dAC                   leave
720dAC                   endif
720dA*
720dA*     Skip special license tracking slots
720dA*
720dAC                   if        sldesg = 'BFC'
720dAC                   iter
720dAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
720dA*
720dA*     Skip special *EACH pick slots
720dA*
720dA * We need to exclude *EACH slot
720dA * need to get slot definition before proceeding
720dAC                   exsr      GetSlotdef
720dAC                   if        sdpal = '*EACH'
720dAc                   iter
720dAc                   endif
720dA*
720dA*     Ignore slot if past expiration date.
720dA*      For VIP,EI,Glazier process pick slots even if expired.
720dA*
720dAc                   if        client <> cheney
720dAc                             or hasCustDays
720dAC                   if        slexpd <> 0  and
720dAC**                           slexpd < today  and
720dAC                             slexpd < expDate and
720dAC                             itflgd = 'Y'  and
720dA*
720dAC                             client <> vip
720dAC                             and client <> ei
720dAC                             and client <> glazier
720dA*
720dAC                   eval      trnbr = 'TR09'
720dAC                   eval      trcode = '*PCK050 '
720dAC                   movel     'PICKMP  '    trsr50
720dAC                   exsr      zztrck
720dAC                   iter
720dAC                   endif
720dAc                   endif
720dA*
720dA*     If slot matches last pick slot read in PICKF2
720dA*       then allocate remainder from slot.
720dA*
720dAC                   if        slwhdp = svwhdp  and
720dAC                             slstyp = svstyp  and
720dAC                             slaisl = svaisl  and
720dAC                             slloc = svloc  and
720dAC                             slrlvl = svrlvl  and
720dAC                             slhand = svhand  and
720dAC                             (ipprdflg <> 'F' or
720dAc                              tavail1 > tpsltqty1)
720dAc*                             tavail1 > leftq1)
720dAC*                            slhand = svhand
720dA*
720dA*  if Staging/Store Slot Customer and StoreQty existed and warehouse
720dA*  did not have enough stock to fulfill order then only allocate available
720dA*
720dAc                   if        opssLcn = 'Y'
720dA /free
720dA                     whStk1=*zeros;
720dA                     whStk2=*zeros;
720dA                     whStk3=*zeros;
720dA    //  Sum stock quantities for warehouse slots for this specific item exc
720dA    //   Store slot quantities
720dA                     exec sql select sum(slstk1),sum(slstk2),sum(slstk3)
720dA                                into :whStk1, :whStk2, :whStk3
720dA                        from slot10 as a
720dA                            where slwhse=:$pWhse and slitem=:#sitem
720dA                             and slstat='A' and
720dA                            (select count(*) from slotStr as b
720dA                             where b.stwhse=a.slwhse and b.stwhdp=a.slwhdp
720dA                               and b.stdisp=a.sldisp)=0;
720dA    //  If Store quantity exist but Warehouse can cover all allocation then
720dA    //   all allocation to warehouse.  If Store has quantity and warehouse
720dA    //   allocate available to warehouse and try rest to Store.  If remaind
720dA    //   after store allocates we will push back through with warehouse pic
720dA    //   allocate the rest to the Warehouse pick
720dA /end-free
720dAc                   if        storeQty and (leftq1>0 and whStk1>=leftq1 or
720dAc                                           leftq2>0 and whStk2>=leftq2 or
720dAc                                           leftq3>0 and whStk3>=leftq3)
520bAC                   eval      pckall = *on
720dAc                   else
520bAC                   eval      pckall = *off
720dAc                   endif
720dAc                   else
720dAC                   eval      pckall = *on
720dAc                   endif
720dAC                   exsr      avail
720dAC                   exsr      pick0
720dA*
720dA*     Otherwise, pick only what is available.
720dA*
720dAC                   else
720dA*
720dAC                   eval      pckall = *off
720dAC                   exsr      avail
720dAC                   exsr      pick0
720dA*
720dAC                   endif
720dA*
720dA*     If something was picked create picking label(s).
720dA*
720dAC                   if        pickq1 <> 0  or
720dAC                             pickq2 <> 0  or
720dAC                             pickq3 <> 0
720dAC                   eval      lwltyp = 'O'
720dAC                   eval      lwlqav = 0
720dAC                   eval      lwlas2 = *blanks
720dAC                   exsr      post
720dAC                   eval      leftq1 = leftq1 - pickq1
720dAC                   eval      leftq2 = leftq2 - pickq2
720dAC                   eval      leftq3 = leftq3 - pickq3
720dAC                   add       pickq1        ttlpk1
720dAC                   add       pickq2        ttlpk2
720dAC                   add       pickq3        ttlpk3
720dAC                   endif
720dA*
720dA*     No need to look further, if no quantity left to pick.
720dA*
720dAC                   if        leftq1 = 0  and
720dAC                             leftq2 = 0  and
720dAC                             leftq3 = 0
720dAC                   leave
720dAC                   endif
720dA*
720dAC                   enddo
720dA*
720dA*      If Store Quantity existed and quantity still remains find
720dA*      the warehouse pick slot and force remaining to that slot
720dAc                   if        storeQty and (leftq1<>0 or
720dAc                              leftq2<>0 or leftq2<>0)
720dAC                   eval      kystat = 'A '
720dAC                   eval      kypick = 'Y'
720dAc                   eval      #sitem = oditem
720dAC     keysl3        setll     slot3
720dAC                   dou       forevr <> forevr
720dAC     keysl3        reade     slot3
720dAc                   if        %eof(slot3)
720dAc                   leave
720dAc                   endif
720dAC                   if        slwhdp = svwhdp  and
720dAC                             slstyp = svstyp  and
720dAC                             slaisl = svaisl  and
720dAC                             slloc = svloc  and
720dAC                             slrlvl = svrlvl  and
720dAC                             slhand = svhand
720dA /free
720dA                    eval pickq1 = leftq1;
720dA                    eval pickq2 = leftq2;
720dA                    eval pickq3 = leftq3;
720dA                    eval picku1 = leftq1;
720dA                    eval picku2 = leftq2;
720dA                    eval picku3 = leftq3;
720dA                    lwltyp = 'O';
720dA                    lwlqav = 0;
720dA                    lwlas2 = *blanks;
720dA                    exsr post;
720dA                    leftq1 = 0;
720dA                    leftq2 = 0;
720dA                    leftq3 = 0;
720dA /end-free
720dAc                   endif
720dAc                   enddo
720dAc                   endif
720dA*
720dA*   If everything wasn't picked then print an error.
720dA*
720dAC                   if        leftq1 <> 0  or
720dAC                             leftq2 <> 0  or
720dAC                             leftq3 <> 0
720dA*
720dA*      If Production Item update remaining quantity and return to
720dA*      force to a Customer Specific Production slot
720dA*
720dAc                   if        ipprdflg = 'F'
720dAc                   eval      rmavail1 = leftq1
720dAc                   eval      rmavail2 = leftq2
720dAc                   eval      rmavail3 = leftq3
720dAc                   else
720dA*
720dA*      Unallocate quantity left because it couldn't be allocated.
720dA*
720dAC                   exsr      unaloc
720dA*
720dA*      Convert picked quantity to string for error msg.
720dA*
720dAC                   eval      $ccmd = '*QTY2STR'
720dAC                   move      '#PROG   '    $cprg
720dAC                   if        ittype = 'S'
720dAC                   eval      $cqty1 = pickq2
720dAC                   eval      $cqty2 = pickq3
720dAC                   eval      $cqty3 = 0
720dAC                   else
720dAC                   eval      $cqty1 = pickq1
720dAC                   eval      $cqty2 = pickq2
720dAC                   eval      $cqty3 = pickq3
720dAC                   endif
720dAC                   call      'CVTQTY'
720dAC                   parm                    $ccmd
720dAC                   parm                    $cprg
720dAC                   parm                    $cqty1
720dAC                   parm                    $cqty2
720dAC                   parm                    $cqty3
720dAC                   parm                    $cum1
720dAC                   parm                    $cum2
720dAC                   parm                    $cum3
720dAC                   parm                    $cqstr
720dAC                   parm                    $custr
720dAC                   parm                    $crtn
720dAC                   parm                    $cerm
720dAC                   eval      p1qpck = $cqstr
720dA*
720dA*      Print error message.
720dA*
720dAC                   eval      p1msg = msg(4)
720dAC                   exsr      prterr
720dAC                   eval      trnbr = 'TR04'
720dAC                   eval      trcode = '*PCK050 '
720dAC                   movel     'PICKMP  '    trsr50
720dAC                   exsr      zztrck
720dAC                   endif
720dAC                   endif
720dA*
720dA*      Create picking exception label(s).
720dAC                   if        opelbl = 'Y'  and
720dAC                             ophpwc = 'N'  or
720dA*
720dAC                             opelbl = 'Y'  and
720dAC                             ophpwc = 'Y'  and
720dAC*                            $potyp <> 'W'
720dAC                             $potyp <> 'W' or
720dAC                             client = Savalfoods and
720dAC                             $potyp = 'W'
720dA*
720dAC                             or client = SGC
720dAC                             and opelbl = 'N'
720dAC                             and sgcdm1_omalco = 'Y'
720dA*
720dAC                   add       leftq1        excpq1
720dAC                   add       leftq2        excpq2
720dAC                   add       leftq3        excpq3
720dAC                   if        excpq1 > 0  or
720dAC                             excpq2 > 0  or
720dAC                             excpq3 > 0
720dAC                   clear                   slrec
720dAC                   eval      slwhse = svwhse
720dAC                   eval      slwhdp = svwhdp
720dAC                   eval      slstyp = svstyp
720dAC                   eval      slaisl = svaisl
720dAC                   eval      slloc = svloc
720dAC                   eval      slrlvl = svrlvl
720dAC                   eval      slhand = svhand
720dAC                   eval      sldisp = svdisp
720dAC                   eval      slpseq = svpseq
720dAC                   eval      pickq1 = excpq1
720dAC                   eval      pickq2 = excpq2
720dAC                   eval      pickq3 = excpq3
720dAC                   eval      lwltyp = 'O'
720dAC                   eval      lwlqav = 0
720dAC                   eval      lwlas2 = 'OUT'
720dAC                   exsr      post
720dAC                   endif
720dAC                   endif
720dA*
720dAC                   endsr
650qA*----------------------------------------------------------------
650qA*
650qA*  PICKMC     Pick fixed item from pick slot first when allow bulk=C
650qA*
650qA*  Note:  Within this routine, we allocate the available qty
650qA*         from the pick slot.
650qA*
650qA*
650qAC     pickmC        begsr
650qA*
650qA*  Write out tracking record.
650qA*
650qAC                   eval      trcode = '*PCK040 '
650qAC                   movel     'PICKMC  '    trsubr
650qAC                   exsr      zztrck
650qA*
650qA*   Loop through picking slots for item.
650qA*
650qAC                   eval      kystat = 'A '
650qAC                   eval      kypick = 'Y'
650qAC     keysl3        setll     slot3
650qAC                   dou       forevr <> forevr
650qAC     keysl3        reade     slot3                                  77
650qAC                   if        *in77
650qAC                   leave
650qAC                   endif
650qA*
650qA*     Skip special license tracking slots
650qA*
650qAC                   if        sldesg = 'BFC'
650qAC                   iter
650qAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
650qA*
650qA*     Ignore slot if past expiration date.
650qA*      For VIP,EI,Glazier process pick slots even if expired.
650qA*
650qAC                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
650qAC                             itflgd = 'Y'  and
650qA*
650qAC                             client <> vip
650qAC                             and client <> ei
650qAC                             and client <> glazier
650qA*
650qAC                   eval      trnbr = 'TR09'
650qAC                   eval      trcode = '*PCK050 '
650qAC                   movel     'PICKMC  '    trsr50
650qAC                   exsr      zztrck
650qAC                   iter
650qAC                   endif
650qA*
650qA*      pick only what is available.
650qA*
650qAC                   eval      pckall = *off
650qAC                   exsr      avail
650qAC                   exsr      pick0
650qA*
650qA*
650qA*     If something was picked create picking label(s).
650qA*
650qAC                   if        pickq1 <> 0  or
650qAC                             pickq2 <> 0  or
650qAC                             pickq3 <> 0
650qAC                   eval      lwltyp = 'O'
650qAC                   eval      lwlqav = 0
650qAC                   eval      lwlas2 = *blanks
650qAC                   exsr      post
650qAC                   eval      leftq1 = leftq1 - pickq1
650qAC                   eval      leftq2 = leftq2 - pickq2
650qAC                   eval      leftq3 = leftq3 - pickq3
650qAC                   add       pickq1        ttlpk1
650qAC                   add       pickq2        ttlpk2
650qAC                   add       pickq3        ttlpk3
650qAC                   endif
650qA*
650qA*     No need to look further, if no quantity left to pick.
650qA*
650qAC                   if        leftq1 = 0  and
650qAC                             leftq2 = 0  and
650qAC                             leftq3 = 0
650qAC                   leave
650qAC                   endif
650qA*
650qAC                   enddo
650qA*
650qA*
650qAC                   endsr
     *----------------------------------------------------------------
     *
     *  PICKP   Pick PIR item.
     *
     *  Note:  All PIR slots are picking slots. There are no
     *         replenishment slots for a PIR item. Therefore, we
     *         allocate as much as we can from a slot and then move
     *         on to the next one until the entire quantity is
     *         allocated. Because a general allocation has already
     *         been done we should be able to allocate everything.
     *         If we can't then there is an error between the ITEMQTY
     *         totals and the slot totals for the item.
     *
     *         If a carton has to be broken the stock quantity is
     *         adjusted for the slot. This adjustment has already
     *         been done at the warehouse level when the item was
     *         initially allocated.
     *
520bA*         In 520a this changed a little bit. For a brkdn 1 qty
520bA*         we attempt to pick full cases, then pick eaches.
520bA*
     C     pickp         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKP   '    trsubr
413aAC                   exsr      zztrck
CBIcAC                   if        client = cheney
CBIcA*
CBIcA*  Initialize key fields.
CBIcAC                   eval      kyaisl = *blanks
CBIcAC                   eval      kypseq = *zeros
CBIcAC                   eval      kyrlvl = *zeros
CBIcAC                   eval      savloc = *zeros
CBIcAC                   eval      kyhand = *blanks
CBIcAC                   eval      savdsp = *blanks
CBIcAC                   endif
MJKaA*
MJKaA*   For MJK Contract items, pick via bulk pick routine
MJKaA*
MJKaAC                   if        mjkcon = *on
MJKaAC                   eval      mjkpir = *on
MJKaAC                   exsr      bulkpk
MJKaAC                   eval      mjkpir = *off
MJKiAC                   if        leftq1 = 0 and
MJKiAC                             leftq2 = 0 and
MJKiAC                             leftq3 = 0
MJKaAC                   goto      pickpe
MJKiAC                   endif
MJKaAC                   endif
CLDcAC*
CLDcAC                   if        client = cityln
CLDcAC                   eval      kyaisl = *blanks
CLDcAC                   eval      kypseq = *zero
CLDcAC                   eval      kyrlvl = *zero
CLDcAC                   eval      savloc = *zero
CLDcAC                   eval      kyhand = *blanks
CLDcAC                   eval      savdsp = *blanks
CLDdAC*
CLDdAC                   eval      savqy1 = *zero
CLDdAC                   eval      savqy2 = *zero
CLDdAC                   eval      savqy3 = *zero
CLDdAC*
CLDdAC                   eval      savqy1 = leftq1
CLDdAC                   eval      savqy2 = leftq2
CLDdAC                   eval      savqy3 = leftq3
CLDcAC                   endif
     *
     *   Loop through picking slots for item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKP   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Ignore slot if nothing can be picked.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     C                   if        pickq1 = 0  and
     C                             pickq2 = 0  and
     C                             pickq3 = 0
     C                   iter
     C                   endif
     C                   eval      avail1 = tmavl1
     C                   eval      avail2 = tmavl2
     C                   eval      avail3 = tmavl3
     *
     *     Save slot information and available quantities.
     *
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
530 AC                   eval      savdisp = sldisp
CLDcAC*
CLDcAC*     Save slot location, display for use with "out" label.
CLDcAC                   if        client = cityln
CBIcAC                             or client = cheney
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endif
     *
     C                   eval      svavl1 = avail1
     C                   eval      svavl2 = avail2
     C                   eval      svavl3 = avail3
     *
     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.
     *
520gAC     keys3b        setll     slot3
     C                   dou       forevr <> forevr
     C     keys3b        reade     slot3                                  76
     C                   if        *in76
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
     *        Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKP   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *        Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Ignore slot if nothing can be picked.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     C                   if        pickq1 = 0  and
     C                             pickq2 = 0  and
     C                             pickq3 = 0
     C                   iter
     C                   endif
     C                   eval      avail1 = tmavl1
     C                   eval      avail2 = tmavl2
     C                   eval      avail3 = tmavl3
     *
     *        If this slot has the least qty available then
     *        save slot information and available quantities.
     *
     C                   if        avail1 < svavl1  or
     C                             avail1 = svavl1  and
     C                             avail2 < svavl2  or
     C                             avail1 = svavl1  and
     C                             avail2 = svavl2  and
     C                             avail3 < svavl3
     *
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
530 AC                   eval      savdisp = sldisp
CLDcAC*
CLDcAC*     Save slot location, display for use with "out" label.
CLDcAC                   if        client = cityln
CBIcAC                             or client = cheney
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endif
     *
     C                   eval      svavl1 = avail1
     C                   eval      svavl2 = avail2
     C                   eval      svavl3 = avail3
     *
     C                   endif
     *
     C                   enddo
     *
     *     Get the selected slot.
     *
530 AC     keys3c        setll     slot3
530 AC                   dow       forevr = forevr
530 DC*    keys3c        chain     slot3                              76
530 MC     keys3c        reade     slot3                                7576
     C                   if        *in76
530 DC*                  iter
530 MC                   leave
     C                   endif
530 A*
530 A*     Skip locked record.
530 AC                   if        *in75
530 AC                   iter
530 AC                   endif
530 A*
530 A*     Exit when slot display matches saved slot display.
530 A*     This is done because 2 or more slots may have matching
530 A*     full key values and correct slot may not be retrieved
530 A*     causing the program to go into a never-ending loop.
530 AC                   if        sldisp = savdisp
530 AC                   leave
530 AC                   endif
530 A*
530 AC                   enddo
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKP   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     *
     *     Pick quantity needed.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     *     Reset pointer to slot file to the first slot that has
     *     the priority and dates of the slot just used.
     *
     C     keys3b        setll     slot3
     *
     C                   enddo
     *
CLDcAC*
CLDcAC*     Entire qty not picked. Pick remaining qty from last PIR slot
CLDcAC*     that had qty picked from it.
CLDcAC                   if        client = cityln
CLDdAC                   if        leftq1 <> 0 and
CLDdAC                             leftq1 <> savqy1 or
CLDdAC                             leftq2 <> 0 and
CLDdAC                             leftq2 <> savqy2 or
CLDdAC                             leftq3 <> 0 and
CLDdAC                             leftq3 <> savqy3 or
CLDdAC*     If qty remaining and its a Breakdown item, Get qty from last
CLDdAC*     slot and create Label.
CLDdAC                             ittype = 'B' and
CLDdAC                             leftq1 <> 0  or
CLDdAC                             ittype = 'B' and
CLDdAC                             leftq2 <> 0  or
CLDdAC                             ittype = 'B' and
CLDdAC                             leftq3 <> 0
CLDdAC*     Get last pick slot.
CLDdAC                   if        savdsp = *blanks
CLDdAC                   eval      kystat = 'A '
CLDdAC                   eval      kypick = 'Y'
CLDdAC     keysl3        setll     slot3
CLDdAC                   dou       forevr <> forevr
CLDDAC     keysl3        reade(n)  slot3                                  79
CLDdAC                   select
CLDdAC                   when      *in79 = *on
CLDdAC                   leave
CLDdAC                   when      *in79 = *oFF
CLDdAC                   eval      kyprty = slprty
CLDdAC                   eval      kyexpd = slexpd
CLDdAC                   eval      kyentd = slentd
CLDdAC                   eval      kywhdp = slwhdp
CLDdAC                   eval      kystyp = slstyp
CLDdAC                   eval      kyaisl = slaisl
CLDdAC                   eval      kypseq = slpseq
CLDdAC                   eval      kyrlvl = slrlvl
CLDdAC                   eval      savloc = slloc
CLDdAC                   eval      kyhand = slhand
CLDdAC                   eval      savdsp = sldisp
CLDdAC                   endsl
CLDdAC                   enddo
CLDdAC                   endif
     *
CLDdAC     keys3c        chain     slot3                              76
CLDdAC                   if        *in76 = *off
CLDdAC                   eval      pckcmd = '*FORCE  '
CLDdAC                   exsr      pick0
CLDdAC                   eval      pckcmd = *blanks
CLDdAC*     If something was picked create picking label(s).
CLDdAC                   if        pickq1 = 0  or
CLDdAC                             pickq2 = 0  or
CLDdAC                             pickq3 = 0
CLDdAC                   eval      lwltyp = 'O'
CLDdAC                   eval      lwlqav = 0
CLDdAC                   eval      lwlas2 = *blanks
CLDdAC                   exsr      post
CLDdAC                   eval      leftq1 = leftq1 - pickq1
CLDdAC                   eval      leftq2 = leftq2 - pickq2
CLDdAC                   eval      leftq3 = leftq3 - pickq3
CLDdAC                   eval      ttlpk1 = ttlpk1 + pickq1
CLDdAC                   eval      ttlpk2 = ttlpk2 + pickq2
CLDdAC                   eval      ttlpk3 = ttlpk3 + pickq3
CLDdAC                   endif
CLDdAC                   endif
CLDdAC
CLDdAC                   endif
CLDcAC                   endif
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
     *
     *      Unallocate quantity left because it couldn't be allocated.
     *
     C                   exsr      unaloc
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
411 AC                   if        ittype = 'S'
411 AC                   eval      $cqty1 = pickq2
411 AC                   eval      $cqty2 = pickq3
411 AC                   eval      $cqty3 = 0
411 AC                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
411 AC                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR04'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKP   '    trsr50
413aAC                   exsr      zztrck
     C                   endif
410 A*
410 A*      Create picking exception label(s).
410 AC                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
410 AC                   add       leftq1        excpq1
410 AC                   add       leftq2        excpq2
410 AC                   add       leftq3        excpq3
410 AC                   if        excpq1 > 0  or
410 AC                             excpq2 > 0  or
410 AC                             excpq3 > 0
CBIcA*
CBIcA*    Retrieve first slot if no valid slots read.
CBIcAC                   if        client = Cheney
CBIcAC                   if        savdsp = *blanks
CBIcAC                   eval      kystat = 'A '
CBIcAC                   eval      kypick = 'Y'
CBIcAC     keysl3        setll     slot3
CBIcAC     keysl3        reade     slot3                                  79
CBIcAC                   select
CBIcAC                   when      not *in79
CBIcAC                   eval      kyaisl = slaisl
CBIcAC                   eval      kypseq = slpseq
CBIcAC                   eval      kyrlvl = slrlvl
CBIcAC                   eval      savloc = slloc
CBIcAC                   eval      kyhand = slhand
CBIcAC                   eval      savdsp = sldisp
CBIcA*
CBIcAC                   endsl
CBIcAC                   endif
CBIcAC                   endif
CBIcA*
410 AC                   clear                   slrec
CBIcA*
CBIcA*    Restore last location used for use with "out" label.
CBIcAC                   if        client = Cheney
CBIcAC                   eval      slaisl = kyaisl
CBIcAC                   eval      slloc = savloc
CBIcAC                   eval      slrlvl = kyrlvl
CBIcAC                   eval      slhand = kyhand
CBIcAC                   eval      slpseq = kypseq
CBIcAC                   eval      sldisp = savdsp
CBIcAC                   endif
CBIcA*
410 AC                   eval      slwhse = itwhse
410 AC                   eval      slwhdp = itwhdp
410 AC                   eval      slstyp = itstyp
410 AC                   eval      pickq1 = excpq1
410 AC                   eval      pickq2 = excpq2
410 AC                   eval      pickq3 = excpq3
410 AC                   eval      lwltyp = 'O'
410 AC                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = 'OUT'
410 AC                   exsr      post
410 AC                   endif
410 AC                   endif
     *
     C     pickpe        endsr
730hA*----------------------------------------------------------------
730hA*  PICKDD  This routine is called to Assign/Pick Drop Pick items
730hA*----------------------------------------------------------------
730hA*
730hAC     pickDD        begsr
730hA /free
730hA
730hA       // ensure at least one *DROP slot exist for this item
730ha       sltcnt=0;
730hA       exec sql  select count(*)
730hA                   into :sltcnt
730hA                    from slot
740 D             //where slwhse=:odwhse and slitem=:cmpitem and slstat='A '
740 M             where slwhse=:odwhse and slitem=:cmpitem and slstat='DP'
740aA               and sldesg='*DROP' and slwhdp=:itwhdp;
740aD               //and sldesg='*DROP';
730hA       if sltcnt=0;
740aA
730hA          // if no *DROP exist for this item create one.  At
730hA          // this point we know Base *DROP slots exist or we
730hA          // would not be here.
740aA          exsr zzLoadToSlt;
750eA          if pReturn <> '*OK';
750eA            // if *OK is not returned then no valid Drop
750eA            // Pick slot was found and we should return
750eA            // and process as a Bulk Pick
750eA            if odspcl = 'DP';
750eA              odspcl=*blanks;
750eA            endif;
750eA            dpck=*off;
750eA            leavesr;
750eA          endif;
730hA
730hA          // if Base Drop Pick found then create virtual
730hA          if s_sldisp<>*blanks;
750eA             // before creating Drop Pick slot we will make sure the
750eA             // quantity/cube will fit in the selected slot.  If it will
750eA             // not fit we will pick as Bulk
750eA             If maxCubeQty(odwhse:itwhdp:s_sldisp:cmpItem:leftq1:leftq2
750eA                                                             :leftq3);
750eA               // since complete order will not fit we will turn off drop pick
750eA               // and pick as Bulk Pick
750eA               if odspcl = 'DP';
750eA                 odspcl=*blanks;
750eA               endif;
750eA               dpck=*off;
750eA               leavesr;
750eA             endif;
730hA             exsr clr$slot;
730hA             $slwhseu = *on;
730hA             $slwhse  = odwhse;
730hA             $slwhdpu = *on;
730hA             $slwhdp  = itwhdp;
730hA             $sldispu = *on;
730hA             $sldisp  = s_sldisp;
730hA             $slitemu = *on;
730hA             $slitem  = cmpItem;
730hA             $dricommand = '*SLOT';
730hA             $drisubcmd = '%CRTVOFLW';
730hA             $drisys2upd = 'D';
730hA             exsr zzzdricop;
730hA          else;
730hA             // Should only come here if no configuration exist
730hA             // for said department/item in DRPRNGE (Drop Pick
730hA             // Slot Ranges) maintained by M309xx in MRC
740cD             //p1Msg = 'No Drop Pick configuration exist';
740cD             //exsr prterr;
730hA          endif;
750eA       else;
750eA         // Ensure order will fit in slot and leave to treat as bulk
750eA         // pick otherwise
750eA         if maxCubeQty(odwhse:itwhdp:s_sldisp:cmpItem:leftq1:leftq2
750eA                                                         :leftq3);
750eA           // since complete order will not fit we will turn off drop pick
750eA           // and pick as Bulk Pick
750eA           if odspcl = 'DP';
750eA             odspcl=*blanks;
750eA           endif;
750eA           dpck=*off;
750eA           leavesr;
750eA         endif;
730hA       endif;
730hA
730hA       ddFound=*off;
730hA       readprior=*off;
730hA       // Look for slot first that can handle needed
730hA       // allocation
740 D       //setll (odwhse:cmpItem:'A ') slot3;
740 M       setll (odwhse:cmpItem:'DP') slot3;
730hA       dow forever = forever;
740 D          //reade (odwhse:cmpItem:'A ') slot3;
740 M          reade (odwhse:cmpItem:'DP') slot3;
730hA          if %eof(slot3) or not %equal(slot3);
730hA             if ddFound and (leftq1<>0 or leftq2<>0 or leftq3<>0)
730hA                        and readprior=*off;
730hA                // get values from last *DROP slot found in loop below
730hA                setll (odwhse:itwhdp:dropDisp) slot2;
730hA                reade (odwhse:itwhdp:dropDisp) slot2;
730hA                // now set proper record on slot3 since that is what
730hA                // record is ultimately updated
730hA                setll (slwhse:slitem:slstat:slpick:slprty:slexpd:slentd:
730hA                       slwhdp:slstyp:slaisl:slpseq:slrlvl:slhand) slot3;
730hA                reade (slwhse:slitem:slstat:slpick:slprty:slexpd:slentd:
730hA                       slwhdp:slstyp:slaisl:slpseq:slrlvl:slhand) slot3;
730hA                readprior=*on;
730hA             else;
730hA                leave;
730hA             endif;
730hA          endif;
730hA          // set indicator that says at least one drop
730hA          // pick slot exist for this item.  If this loop
730hA          // does not find a drop pick slot with enough
730hA          // quantity this flag will be used to read previous
730hA          // slot and allocate to that slot.  If this value
730hA          // is off coming out of this loop it means no existing
730hA          // slot with *DROP designation exist for this slot and
730hA          // one will be assigned
730hA
730hA          // ignore if designation not *DROP
730hA          if sldesg <> '*DROP';
730hA             iter;
730hA          endif;
730hA
730hA          // ignore special need slots
730hA          if sldesg = 'BFC';
730hA             iter;
730hA          endif;
740gA
740gA          // warehouse-to-warehouse (GLOWWTFR) slots
740aA
740aA /free
740aA    monitor;
740aA      wwwhse = slwhse;
740aA      wwloc = slloc;
740aA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740aA      if wwrtn = '*YES';
740aA        iter;
740aA      endif;
740aA    on-error;
740aA    endmon;
740aA /end-free
740aA
730hA
730hA          // if expiration date passed ignore
730hA          if slexpd <> 0 and slexpd < expDate and itflgd = 'Y';
730hA             iter;
730hA          endif;
730hA
730hA          // check to see if this slot has enough quantity
730hA          rmavail1=*zeros;
730hA          rmavail2=*zeros;
730hA          rmavail3=*zeros;
730hA          if not readprior;
730hA          exsr avail;
730hA          select;
730hA            when itumq3 > 0;
730hA              // if Allocation exceeds available go to next slot
730hA              if ((leftq1*itumq2*itumq3) + (leftq2*itumq3) + leftq3) >
730hA                 ((avail1*itumq2*itumq3) + (avail2*itumq3) + avail3);
730hA                 rmavail3=((leftq1*itumq2*itumq3) + (leftq2*itumq3) +
730hA                          + leftq3) -
730hA                          ((avail1*itumq2*itumq3) + (avail2*itumq3) +
730hA                          + avail3);
730hA                 rmavail2=*zeros;
730hA                 rmavail1=*zeros;
730hA                 leftq3=((avail1*itumq2*itumq3) + (avail2*itumq3) +
730hA                        + avail3);
730hA                 leftq2=*zeros;
730hA                 leftq1=*zeros;
730hA              endif;
730hA            when itumq2 > 0;
730hA              // if Allocation exceeds available go to next slot
730hA              if ((leftq1*itumq2) + leftq2) >
730hA                 ((avail1*itumq2) + avail2);
730hA                 rmavail2=((leftq1*itumq2) + leftq2) -
730hA                          ((avail1*itumq2) + avail2);
730hA                 rmavail1=*zeros;
730hA                 rmavail3=*zeros;
730hA                 leftq2=((avail1*itumq2) + avail2);
730hA                 leftq1=*zeros;
730hA                 leftq3=*zeros;
730hA              endif;
730hA            other;
730hA              // if Allocation exceeds available go to next slot
730hA              if leftq1 > avail1;
730hA                 rmavail1=leftq1-avail1;
730hA                 leftq1=avail1;
730hA                 leftq2=*zeros;
730hA                 leftq3=*zeros;
730hA              endif;
730hA          endsl;
730hA          endif;
730hA
730hA          ddFound = *on;
730hA          dropDisp = sldisp;
730hA
730hA          // Readprior means we have processed all available
730hA          // *DROP slots for the given item.  That coupled with
730hA          // a quantity remaining in one of the leftq values means
730hA          // we need stock so we create a Drop Pick Replenishment.
730hA          // The code is different than standard replen here so
730hA          // we are calling separate routine
730hA          if readprior and (leftq1<>0 or leftq2<>0 or leftq3<>0);
730hA             exsr ddJitReplen;
730hA          endif;
730hA
730hA          if (leftq1>0 or leftq2>0 or leftq3>0);
740dA          // ensure quantity matches what was ordered
740dA          if odqor1<>0 and leftq1=0;
740dA            eval #bumq2=itumq2;
740dA            eval #bumq3=itumq3;
740dA            eval wopqn1 = leftq1;
740dA            eval wopqn2 = leftq2;
740dA            eval wopqn3 = leftq3;
740dA            exsr zzupqty;
740dA            eval leftq1 = wopqn1;
740dA            eval leftq2 = wopqn2;
740dA            eval leftq3 = wopqn3;
740dA          endif;
730hA          eval pickq1 = leftq1;
730hA          eval pickq2 = leftq2;
730hA          eval pickq3 = leftq3;
730hA          eval picku1 = leftq1;
730hA          eval picku2 = leftq2;
730hA          eval picku3 = leftq3;
730hA          lwltyp = 'O';
730hA          lwlqav = 0;
730hA          lwlas2 = *blanks;
730hA          // allocate qty in itemqty - force the allocation
730hA          $acmd = '*ALLOCFR';
730hA          $aprg = #prog;
730hA          $atype = '*BATCH  ';
730hA          $awhse = odwhse;
730hA          if ittype = 'A'  or
730hA             ittype = 'S';
730hA             $aitem = #sitem;
730hA          else;
730hA             $aitem = cmpItem;
730hA          endif;
730hA          $aqty1 = leftq1;
730hA          $aqty2 = leftq2;
730hA          $aqty3 = leftq3;
730hA /end-free
730hAC                   call      'ADJQTY'
730hAC                   parm                    $acmd
730hAC                   parm                    $aprg            10
730hAC                   parm                    $atype            8
730hAC                   parm                    $awhse            3 0
730hAC                   parm                    $aitem           15
730hAC                   parm                    $aqty1            7 0
730hAC                   parm                    $aqty2            7 0
730hAC                   parm                    $aqty3            7 0
730hAC                   parm                    $artq1            7 0
730hAC                   parm                    $artq2            7 0
730hAC                   parm                    $artq3            7 0
730hAC                   parm                    $artn             8
730hAC                   parm                    $aerm
740eAc                   eval      odspcl='DP'
730hAc                   exsr      post
730hAc                   endif
730hA /free
730hA        // if remaining quantity still exist then move to left
730hA        // quantity and look for next slot to allocate
730hA        if rmavail1<>0 or rmavail2<>0 or rmavail3<>0;
730hA           leftq1=rmavail1;
730hA           leftq2=rmavail2;
730hA           leftq3=rmavail3;
730hA        else;
730hA           // no remaining quantity so we leave
740cA           leftq1=0;
740cA           leftq2=0;
740cA           leftq3=0;
730hA           leave;
730hA        endif;
730hA
730hA       enddo;
730hA /end-free
730hAC     endDD         endsr
650nA*----------------------------------------------------------------
650nA*  PICKPRD  This routine is called for items marked as a prodution
650nA*  item.  The system will determine what available stock exists in
650nA*  the normal warehouse for pick and overflow.  The normal process
650nA*  will be called (pickf2) for that available quantity and the
650nA*  remaining quantity will be forced to a customer production slot.
650nA*----------------------------------------------------------------
650nA*
650nAC     pickPRD       begsr
650nA /free
650nA
700kA    // as a precaution, we will auto load custmast record if it
700kA    // does not exist
710cD    //chain (ohcust) CustMast;
710cA    chain (ohwhse:ohcust) CustMast;
700kA    if not %found(CustMast);
710cA      // This code simply adds a record with the Dakota numeric key to ensu
710cA      // an imported order can find a customer record in case one is missin
710cA      // The order import process should either add or update records in th
710cA      // file so this code should never run but is here just in case.  It i
710cA      // also includimg Auto Loader in the account name to indicate it was
710cA      // in OR610 and should determine why import did not add properly.
710cA      cmwhse = ohwhse;
700kA      cmcust = ohcust;
710cD      //  cmname = 'AUTO LOADED';
710cA      cmname = 'AUTO LOADED - ' + %trim(%subst(ohcnam:1:26));
710cA      cmcusta = *blanks;  // Alpha Customer Number
710cA      cmcad1 = ohcad1;
710cA      cmcad2 = ohcad2;
710cA      cmccty = ohccty;
710cA      cmcst = ohcst;
710cA      cmczip = ohczip;
710cA      cmstat = 'A';
710cA      cmaddts = %timestamp;
710cA      cmupdts = %timestamp;
710cA      cmjob = #job;
710cA      cmuser = #user;
710cA      cmjobnbr = #jobn;
700kA      write custrec;
700kA    endif;
650nA    // first determine if specific customer slot already exists
650nA    // for customer and item combination.  If so then force all
650nA    // allocation to that slot
730dA        $ppShpar=*blanks;
650nA        chain ($pwhse:ohcust:oditem) pcslot;
650nA        if %found(pcslot);
650nA           // confirm that slot is not zero verify status
650nA           chain ($pwhse:itwhdp:csdisp) slot2;
650nA           if %found(slot2) and slstat = 'PR';
650nA              forceCustAlloc = *on;
650nA           else;
650nA              forceCustAlloc = *off;
650nA           endif;
650nA        else;
650nA           forceCustAlloc = *off;
650nA        endif;
650nA
650nA     // if a customer slot did not exist then allocate available
650nA     // warehouse stock first, then force remaining to cust slot
650nA        if not forceCustAlloc;
650nA
650nA    // first determine stock available in normal warehouse slots
650nA    // for given production item
650nA           tpsltqty1 = 0;
650nA           tavail1 = 0;
650nA           tavail2 = 0;
650nA           tavail3 = 0;
650nA           kystat='A';
650nA           setll ($pwhse:#sitem:kystat) slot3;
650nA           dow forever = forever;
650nA              reade ($pwhse:#sitem:kystat) slot3;
650nA
650nA              if %eof(slot3);
650nA                 leave;
650nA              endif;
650nA
650nA          // ignore special need slots
650nA              if sldesg = 'BFC';
650nA                 iter;
650nA              endif;
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
650nA
650nA         // if no full case quantity then ignore
650nA              if slstk1 <= 0;
650nA                 iter;
650nA              endif;
650nA
650nA         // if expiration date passed ignore
700iD              //if slexpd <> 0 and slexpd < today and itflgd = 'Y';
700iM              if slexpd <> 0 and slexpd < expDate and itflgd = 'Y';
650nA                 iter;
650nA              endif;
650nA
650nA              exsr avail;
650nA              if slpick = 'Y';
650nA                 tpsltqty1 = tpsltqty1 + avail1;
650nA              endif;
650nA              tavail1 = tavail1 + avail1;
650nA              tavail2 = tavail2 + avail2;
650nA              tavail3 = tavail3 + avail3;
650nA
650nA           enddo;
650nA
650nA           if tavail1 >= leftq1;
650nA              exsr alloc;           // allocate from normal stock
650nA              exsr pickf2;
650nA /end-free
650nAc                   goto      endpprd
650nA /free
650nA           else;
650nA
650nA             // else, allocate available normal stock then force
650nA             // remaining to customer production slot
650nA              rmavail1 = leftq1 - tavail1;
650nA              rmavail2 = leftq2 - tavail2;
650nA              rmavail3 = leftq3 - tavail3;
650nA
650nA              leftq1 = tavail1;
650nA              leftq2 = tavail2;
650nA              leftq3 = tavail3;
650nA
650nA              // allocate normal stock for what remains
650nA              if leftq1<>0 or leftq2<>0 or leftq3<>0;
650nA                 exsr alloc;
650nA                 exsr pickf2;
650nA              endif;
650nA
650nA           endif;
650nA
650nA        else;   // else means force cust slot allocation
650nA
650nA           rmavail1 = leftq1;
650nA           rmavail2 = leftq2;
650nA           rmavail3 = leftq3;
650nA
650nA        endif;  // endif for forceCustAlloc
650nA
650nA     // since it fell through to here it means there was too
650nA     // little warehouse stock or a customer specific slot for
650nA     // this customer and item already exist so we should force
650nA     // the remaining allocation to the cust specific slot
650nA
650nA           leftq1 = rmavail1;
650nA           leftq2 = rmavail2;
650nA           leftq3 = rmavail3;
650nA
650nA           savever# = $ppver#;
650nA           $ppver# = savever#;
650nA
650nA    // Look to see if slot already reserved for customer
650nA    // and item.  If so simply go with that slot, otherwise
650nA    // find a slot using the line configuration in PLINED.
650nA    // if manufacutring line found in itemprd use it to get
650nA    // the slot aisle to use, otherwise take the slot aisle
650nA    // from the first manufacturing line found in plined
650nA    // if no records are found use manufacturing line 1 and
650nA    // PRD as the aisle
650nA
650nA         chain ($pwhse:oditem) piritem;
650nA         if %found(piritem);
650nA            $ppwhdpu = *on;
650nA            $ppwhdp  = itwhdp;
650nA            $ppitemu = *on;
650nA            $ppitem  = ititem;
650nA         endif;
650nA         chain ($pwhse:ohcust:oditem) pcslot;
650nA         if %found(pcslot) and forceCustAlloc;
650nA           drierr = *off;
650nA           $ppwhse = $pwhse;
650nA           $ppshpar = csdisp;
650nA           prdslot = csdisp;
650nA         else;
650nA           chain ($pwhse:ipmfgno) plined;
650nA           if not %found(plined);
650nA              ipmfgno = 0;
650nA              setll ($pwhse:ipmfgno) plined;
650nA              read plined;
650nA              if %found(plined);
650nA                 ipmfgno = inlneno;
650nA                 $ppdesc = indesc;
650nA                 prdSlot = ' ';
730dA                 // It will be assumed moving forward that Customer Specific
730dA                 // slots will only be created by either Production Planning
730dA                 // or the Canopy Production Quantity import that can call
730dA                 // out a specific customer.  If the warehouse is short of stock
730dA                 // and no customer specific slot exists for this item then
730dA                 // OR610 will create a PAR slot.
730dM                 $ppshpau = *off;
730dM                 $ppshpa = ' ';
730dA                 $ppparau = *on;
730dA                 $pppara = instkaisl;
650nA              else;
650nA                 ipmfgno = 1;
650nA                 $ppdesc = 'MFG Line 1';
650nA                 prdSlot = ' ';
730dM                 $ppparau = *on;
730dM                 $pppara = 'PAR';
650nA              endif;
650nA           else;
650nA              $ppdesc = indesc;
650nA              prdSlot = ' ';
730dM              $ppshpau = *off;
730dM              $ppshpa = ' ';
730dA              $ppparau = *on;
730dA              $pppara = instkaisl;
650nA           endif;
650nA
650nA           $ppwhseu = *on;
650nA           $ppwhse  = $pwhse;
650nA           $pplnenou = *on;
650nA           $pplneno = ipmfgno;
730dM           $ppcustu = *off;
730dM           $ppcust = 0;
730dM           $ppcustwo = *blanks;
730dM           $ppcustwou = *off;
650nA           $ppcord = 0;
650nA           $ppcordu =*on;
650nA           $pptypeu = *on;
650nA           $pptype = 'A';
650nA           $ppdestu = *on;
730dD           //$ppdest = 'C';
730dA           $ppdest = 'P';
650nA           $ppqty1u = *on;
650nA           $ppuser = #User;
650nA           $ppuseru = *on;
650nA
650nA           $dricommand = '*PROD';
650nA           $drisubcmd = '%GETSLOT';
650nA           $drisys2upd = 'D';
650nA           exsr zzzDriCop;
650nA         endif;
650nA           // if no errors found then force remaining to
650nA           // Customer Production slot found
650nA           if not drierr;
730dA              if $ppShpar <> *blanks;
730dA                // if customer specific use
650nA                prdSlot = $ppshpar;
730dA              else;
730dA                // otherwise use PAR slot
730dA                prdSlot = $ppparar;
730dA              endif;
650nA                    chain ($pwhse:itwhdp:prdslot) slot2;
650nA                    if %found(slot2);
650nA                       kystat = slstat;
650nA                       kypick = slpick;
650nA                       kyprty = slprty;
650nA                       kyexpd = slexpd;
650nA                       kyentd = slentd;
650nA                       kywhdp = slwhdp;
650nA                       kystyp = slstyp;
650nA                       kyaisl = slaisl;
650nA                       kypseq = slpseq;
650nA                       kyrlvl = slrlvl;
650nA                       kyhand = slhand;
650nA                    endif;
650nA /end-free
650nAc     keys3c        chain     slot3                              77
650nAc     *in77         cabeq     *on           endpprd
650nA /free
650nA              eval pickq1 = leftq1;
650nA              eval pickq2 = leftq2;
650nA              eval pickq3 = leftq3;
650nA              eval picku1 = leftq1;
650nA              eval picku2 = leftq2;
650nA              eval picku3 = leftq3;
650nA              eval woqty = leftq1;
650nA              lwltyp = 'O';
650nA              lwlqav = 0;
650nA              lwlas2 = *blanks;
700kA              // allocate qty in itemqty - force the allocation
700kA              $acmd = '*ALLOCFR';
700kA              $aprg = #prog;
700kA              $atype = '*BATCH  ';
700kA              $awhse = $pwhse;
700kA              if ittype = 'A'  or
700kA                 ittype = 'S';
700kA                $aitem = #sitem;
700kA              else;
700kA                $aitem = oditem;
700kA              endif;
700kA              $aqty1 = leftq1;
700kA              $aqty2 = leftq2;
700kA              $aqty3 = leftq3;
700kA /end-free
700kAC                   call      'ADJQTY'
700kAC                   parm                    $acmd
700kAC                   parm                    $aprg            10
700kAC                   parm                    $atype            8
700kAC                   parm                    $awhse            3 0
700kAC                   parm                    $aitem           15
700kAC                   parm                    $aqty1            7 0
700kAC                   parm                    $aqty2            7 0
700kAC                   parm                    $aqty3            7 0
700kAC                   parm                    $artq1            7 0
700kAC                   parm                    $artq2            7 0
700kAC                   parm                    $artq3            7 0
700kAC                   parm                    $artn             8
700kAC                   parm                    $aerm
700kA /free
650nA              exsr post;
650nA              leftq1 = 0;
650nA              leftq2 = 0;
650nA              leftq3 = 0;
650nA    // get negative quantity to ensure Work Order matches
700kA    // Only if create work order production for qty allocated
700kA    // against Cust. Order Pck Aisle is turned on.
700kA              if opcrtwo = 'Y';
650nA                chain ($pwhse:itwhdp:prdslot) slot2;
650nA                if %found(slot2);
730cD                  exsr chkForWo;
730cD                  if $ppWo# = '*NF';  // create new Work Order
730cD                  //  exsr getNxtPWo;  // get next available wo
730cD                    exsr crtProdWo;  // generate Work Order
730cD                  else;
730cD                    exsr updProdWo;  // Update Work Order
730cD                  endif;
650nA                endif;
700kA              endif;
650nA           endif;
650nA /end-free
650nAC     endpprd       endsr
720aA
720aA*---------------------------------------------------------
720aA*  PICKSTR  This routine is called to allocate order stock
720aA*  to Store/Remote Location to Warehouse
720aA*---------------------------------------------------------
720aA*
720aAC     pickSTR       begsr
720aA /free
720aA
720aA     // At this point we have determined the customer has a
720aA     // Store/Remote site and have already called getStrZ to
720aA     // determine this item pick slot lives in that zone.
720aA     // Therefore we will FORCE allocation to this zone vs. warehouse
720aA     // These orders will always pick from Store if slot available
720aA
720aA                    if ittype='B' or ittype='S';
720aA                       prdslot = $zdstrbpck;
720aA                    else;
720aA                       prdslot = $zdstrcpck;
720aA                    endif;
720aA
720aA                    chain ($pwhse:itwhdp:prdslot) slot2;
720aA                    if %found(slot2);
720aA                       kystat = slstat;
720aA                       kypick = slpick;
720aA                       kyprty = slprty;
720aA                       kyexpd = slexpd;
720aA                       kyentd = slentd;
720aA                       kywhdp = slwhdp;
720aA                       kystyp = slstyp;
720aA                       kyaisl = slaisl;
720aA                       kypseq = slpseq;
720aA                       kyrlvl = slrlvl;
720aA                       kyhand = slhand;
720aA                    endif;
720aA /end-free
720aAc     keys3c        chain     slot3                              77
720aAc     *in77         cabeq     *on           endpstr
720aA /free
720aA                       pickq1 = leftq1;
720aA                       pickq2 = leftq2;
720aA                       pickq3 = leftq3;
720aA                       picku1 = leftq1;
720aA                       picku2 = leftq2;
720aA                       picku3 = leftq3;
720aA                       lwltyp = 'O';
720aA                       lwlqav = 0;
720aA                       lwlas2 = *blanks;

720aA                       // allocate qty in itemqty - force the allocation
720aA                       $acmd = '*ALLOCFR';
720aA                       $aprg = #prog;
720aA                       $atype = '*BATCH  ';
720aA                       $awhse = $pwhse;
720aA                       if ittype = 'A'  or
720aA                       ittype = 'S';
720aA                          $aitem = #sitem;
720aA                       else;
720aA                          $aitem = oditem;
720aA                       endif;
720aA                       $aqty1 = leftq1;
720aA                       $aqty2 = leftq2;
720aA                       $aqty3 = leftq3;
720aA /end-free
720aAC                   call      'ADJQTY'
720aAC                   parm                    $acmd
720aAC                   parm                    $aprg            10
720aAC                   parm                    $atype            8
720aAC                   parm                    $awhse            3 0
720aAC                   parm                    $aitem           15
720aAC                   parm                    $aqty1            7 0
720aAC                   parm                    $aqty2            7 0
720aAC                   parm                    $aqty3            7 0
720aAC                   parm                    $artq1            7 0
720aAC                   parm                    $artq2            7 0
720aAC                   parm                    $artq3            7 0
720aAC                   parm                    $artn             8
720aAC                   parm                    $aerm
720aA /free
720aA                       exsr post;
720aA                       leftq1 = 0;
720aA                       leftq2 = 0;
720aA                       leftq3 = 0;
720aA /end-free
720aAC     endpstr       endsr
720aA
     *----------------------------------------------------------------
620aA*
620aA*  PICKPRE  Pick Pre-pick items from PRE slots.  If qty to pick
620aA*  greater than available from PRE slots, pick rest from normal
620aA*  slots using subr PICKF2.
620aA*
620aAC     pickPRE       begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKPRE '    trsubr
     C                   exsr      zztrck
     *
     *   Loop through PRE-pick slots for order/item.
     *
     C     keyPREX1a     setll     prexref1
     C                   dou       forevr <> forevr
     C     keyPREX1a     reade     prexref1
     C                   if        %eof
     C                   leave
     C                   endif
620cA*
620cA*   Get corresponding PRE label record.
620cA*
730jDC*    pxlbl#        chain     label
730jA /free
730jA                    chain ($pwhse: pxlbl#) labelw;
730jA /end-free
730jMC                   if        not %found(labelw)
620cAC                   iter
620cAC                   endif
     *
     *   Get corresponding PRE slot record.
     *
     C     keysl2a       chain     slot2
     C                   if        not %found(slot2)
     C                   iter
     C                   endif
     C                   eval      kystat = slstat
     C                   eval      kypick = slpick
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
     C                             itflgd = 'Y'
     C                   eval      trnbr = 'TR09'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'PICKPRE '    trsr50
     C                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Pick only what is available.
     *
     C                   eval      pckall = *off
620cA*
620cA*     If PRE label not closed yet,
620cA*       Set available qty to label allocated qty.
620cA*
620cAC                   if        lbstat <> 'C'
620cAC                   eval      avail1 = 0
620cAC                   eval      avail2 = 0
620cAC                   eval      avail3 = 0
620cAC                   select
620cAC                   when      lbutyp = 'N'
620cAC                   eval      avail1 = lbqalc
620cAC                   when      lbutyp = '1'
620cAC                   eval      avail2 = lbqalc
620cAC                   when      lbutyp = '2'
620cAC                   eval      avail3 = lbqalc
620cAC                   endsl
620cAC                   else
     C                   exsr      avail
620cAC                   endif
620cA
     C                   exsr      pick0
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     *   Get slot record to update
     C     keys3c        chain     slot3
     C                   if        not %found(slot3)
     C                   iter
     C                   endif
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
     C                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     *     Update PREXREF record.
     C                   eval      pxnrte = ohrte
     C                   eval      pxnord = ohord
     C                   eval      pxnseq = odseq
     C                   update    pxrec
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKRP  Pick item without a pick slot.
     *
     *  Note:  Fixed items without a pick slot are allocated like PIR
     *         items but picked as a bulk pick.    Therefore, we
     *         allocate as much as we can from a slot and then move
     *         on to the next one until the entire quantity is
     *         allocated. Because a general allocation has already
     *         been done we should be able to allocate everything.
     *         If we can't then there is an error between the ITEMQTY
     *         totals and the slot totals for the item.
     *
     *         If a carton has to be broken the stock quantity is
     *         adjusted for the slot. This adjustment has already
     *         been done at the warehouse level when the item was
     *         initially allocated.
     *
520bA*         In 520a this changed a little bit. For a brkdn 1 qty
520bA*         we attempt to pick full cases, then pick eaches.
520bA*
     C     pickrp        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKRP  '    trsubr
413aAC                   exsr      zztrck

CLDcA*   Initialize key fields.
CLDcAC                   if        client = cityln
CBIcAc                             or client = cheney
CLDcAC                   eval      kyaisl = *blanks
CLDcAC                   eval      kypseq = *zero
CLDcAC                   eval      kyrlvl = *zero
CLDcAC                   eval      savloc = *zero
CLDcAC                   eval      kyhand = *blanks
CLDcAC                   eval      savdsp = *blanks
CLDdAC                   endif
     *
     *   Loop through picking slots for item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
PCKc *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
PCKe *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
PCKhD*     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
     *
PCKc ***        SLAISL    IFGE ' 44'
520fAC                   if        client = packers
PCKe C                   if        slaisl >= ' 66'
PCKc C                   iter
PCKc C                   endif
     *
PCKhDC*                  if        slwhdp = 'DRY  '  and
PCKhDC*                            slaisl >= ' 01'  and
PCKhDC*                            slaisl <= ' 10'
PCKhDC****               iter
PCKhDC*                  endif
520fAC                   endif
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKRP  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Ignore slot if nothing can be picked.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     C                   if        pickq1 = 0  and
     C                             pickq2 = 0  and
     C                             pickq3 = 0
     C                   iter
     C                   endif
     C                   eval      avail1 = tmavl1
     C                   eval      avail2 = tmavl2
     C                   eval      avail3 = tmavl3
     *
     *     Save slot information and available quantities.
     *
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
530 AC                   eval      savdisp = sldisp
CLDcAC*     Save slot location, display for use with "out" label.
CLDcAC                   if        client = cityln
CBIcAc                             or client = cheney
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endif
     *
     C                   eval      svavl1 = avail1
     C                   eval      svavl2 = avail2
     C                   eval      svavl3 = avail3
     *
     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.
     *
520hAC     keys3b        setll     slot3
     C                   dou       forevr <> forevr
     C     keys3b        reade     slot3                                  76
     C                   if        *in76
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
PCKd *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
PCKe *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
PCKhD*     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
PCKd ****       SLAISL    IFGE ' 44'
520fAC                   if        client = packers
PCKe C                   if        slaisl >= ' 66'
PCKd C                   iter
PCKd C                   endif
     *
PCKhDC*                  if        slwhdp = 'DRY  '  and
PCKhDC*                            slaisl >= ' 01'  and
PCKhDC*                            slaisl <= ' 10'
PCKhDC****               iter
PCKhDC*                  endif
520fAC                   endif
     *
     *        Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKRP  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *        Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Ignore slot if nothing can be picked.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     C                   if        pickq1 = 0  and
     C                             pickq2 = 0  and
     C                             pickq3 = 0
     C                   iter
     C                   endif
     C                   eval      avail1 = tmavl1
     C                   eval      avail2 = tmavl2
     C                   eval      avail3 = tmavl3
     *
     *        If this slot has the least qty available then
     *        save slot information and available quantities.
     *
     C                   if        avail1 < svavl1  or
     C                             avail1 = svavl1  and
     C                             avail2 < svavl2  or
     C                             avail1 = svavl1  and
     C                             avail2 = svavl2  and
     C                             avail3 < svavl3
     *
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
530 AC                   eval      savdisp = sldisp
CLDcAC*     Save slot location, display for use with "out" label.
CLDcAC                   if        client = cityln
CBIcAC                             or client = cheney
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endif
     *
     C                   eval      svavl1 = avail1
     C                   eval      svavl2 = avail2
     C                   eval      svavl3 = avail3
     *
     C                   endif
     *
     C                   enddo
     *
     *     Get the selected slot.
     *
530 AC     keys3c        setll     slot3
530 AC                   dow       forevr = forevr
530 DC*    keys3c        chain     slot3                              76
530 MC     keys3c        reade     slot3                                7576
     C                   if        *in76
530 DC*                  iter
530 MC                   leave
     C                   endif
530 A*
530 A*     Skip locked record.
530 AC                   if        *in75
530 AC                   iter
530 AC                   endif
530 A*
530 A*     Exit when slot display matches saved slot display.
530 A*     This is done because 2 or more slots may have matching
530 A*     full key values and correct slot may not be retrieved
530 A*     causing the program to go into a never-ending loop.
530 AC                   if        sldisp = savdisp
530 AC                   leave
530 AC                   endif
530 A*
530 AC                   enddo
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKRP  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   eval      tmavl1 = avail1
     C                   eval      tmavl2 = avail2
     C                   eval      tmavl3 = avail3
     *
     *     Pick needed quantity.
     *
520bAC                   eval      pckall = *off
     C                   exsr      pick0
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
417 A*
417 A*    Pick items without pick slot as bulk pick? (Y/N)
417 A*    If set to N=No, then items will be included in regular
417 A*    item selection.
417 A*
417 AC                   if        opnopk = 'N'
417 AC                   eval      lwltyp = 'O'
417 A*
417 AC                   else
740 A*
740 AC                   eval      chkchild = '1'
740 AC                   exsr      getopt
740 AC                   eval      chkchild = '0'
740 A*      Pick slot part of Child zone. Treat as order pick.
740 AC                   if        $zpzon > ' '
740 AC                   eval      lwltyp = 'O'
740 AC                   else
740 A*
     C                   eval      lwltyp = 'B'
740 AC                   endif
740 A*
417 AC                   endif
417 A*
     C                   eval      lwlqav = tmavl1
413eAC                   eval      lwlas2 = *blanks
WSFaAC                   if        client = westside
WSFaAC                   eval      lwlas2 = 'DOC'
WSFaAC                   endif
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     *     Reset pointer to slot file to the first slot that has
     *     the priority and dates of the slot just used.
     *
     C     keys3b        setll     slot3
     *
     C                   enddo
FPR3A*
FRP3AC                   if            client = FoodPro
SGCgAC                                 or client = SGC
FPR3A*     Allocation Override = Y and qty still not picked.
FPR3A*     then create XDK slot.
FPR3AC                   if            omiaov = 'Y'
FPR3AC                             and (leftq1 <> 0
FPR3AC                             or   leftq2 <> 0
FPR3AC                             or   leftq3 <> 0)
FPR3AC                             and  pickq1 =  0
FPR3AC                             and  pickq2 =  0
FPR3AC                             and  pickq3 =  0
FPR3A*
FPR3AC                   exsr      zzcrxd
FPR3A*      XDK slot on file or created, so update order to use it.
FPR3AC                   if           $drireturn = '*OK'
FPR3AC                             or $drireturn = 'XDKEXIST'
FPR3AC                   evaL      odspcl = 'XD'
FPR3AC                   exsr      pickxd
FPR3A*      XDK slot assigned, so clear left over qty fields.
FPR3AC                   if            leftq1 = pickq1
FPR3AC                             and leftq2 = pickq2
FPR3AC                             and leftq3 = pickq3
FPR4A*
FPR4A*      Unallocate whse quantity when XDK slot is created.
FPR4AC                   exsr      unaloc
FPR4A*
FPR3AC                   eval      leftq1 = 0
FPR3AC                   eval      leftq2 = 0
FPR3AC                   eval      leftq3 = 0
FPR3A*
FPR3A*      Print XDK slot created message to negate previous allocation err ms
FPR3AC                   eval      p1msg = msg(7)
FPR3AC                   exsr      prterr
FPR3AC                   eval      trnbr = 'TR04'
FPR3AC                   eval      trcode = '*PCK050 '
FPR3AC                   movel     'PICKRP  '    trsr50
FPR3AC                   exsr      zztrck
FPR3A*
FPR3AC                   else
FPR3AC                   evaL      odspcl = '  '
FPR3AC                   endif
FPR3A*
FPR3AC                   endif
FPR3A*
FPR3AC                   endif
FPR3A*
FPR3AC                   endif
     *
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
     *
     *      Unallocate quantity left because it couldn't be allocated.
     *
     C                   exsr      unaloc
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
411 AC                   if        ittype = 'S'
411 AC                   eval      $cqty1 = pickq2
411 AC                   eval      $cqty2 = pickq3
411 AC                   eval      $cqty3 = 0
411 AC                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
411 AC                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR04'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKRP  '    trsr50
413aAC                   exsr      zztrck
     C                   endif
410 A*
410 A*      Create picking exception label(s).
410 AC                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
SGCcA*
SGCcAC                             or client = SGC
SGCcAC                             and opelbl = 'N'
SGCcAC                             and sgcdm1_omalco = 'Y'
SGCcA*
410 AC                   add       leftq1        excpq1
410 AC                   add       leftq2        excpq2
410 AC                   add       leftq3        excpq3
410 AC                   if        excpq1 > 0  or
410 AC                             excpq2 > 0  or
410 AC                             excpq3 > 0
CLDcAC*    Retrieve first slot if no valid slot read.
CBItAC                   select
CBItMC                   when      client = cityln
CBIcAC                             or client = cheney
CBItAC                             and not hasCustDays
CLDcAC                   if        savdsp = *blanks
CLDcAC                   eval      kystat = 'A '
CLDcAC                   eval      kypick = 'Y'
CLDcAC     keysl3        setll     slot3
CLDcAC     keysl3        reade     slot3                                  79
CLDcAC                   select
CLDcAC                   when      *in79 = *off
CLDeAC                             and sldesg <> 'BFC'
CLDcAC                   eval      kyaisl = slaisl
CLDcAC                   eval      kypseq = slpseq
CLDcAC                   eval      kyrlvl = slrlvl
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      kyhand = slhand
CLDcAC                   eval      savdsp = sldisp
CLDcAC*    No pick slot found for item. Find first overflow slot.
CLDcAC                   when      *in79 = *on
CLDcAC                   eval      kystat = 'A '
CLDcAC                   eval      kypick = 'N'
CLDcAC     keysl3        setll     slot3
CLDcAC     keysl3        reade     slot3                                  79
CLDcAC                   select
CLDcAC                   when      *in79 = *off
CLDeAC                             and sldesg <> 'BFC'
CLDcAC                   eval      kyaisl = slaisl
CLDcAC                   eval      kypseq = slpseq
CLDcAC                   eval      kyrlvl = slrlvl
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      kyhand = slhand
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endsl
CLDcAC                   endsl
CLDcAC
CLDcAC                   endif

CBItAC                   when      client = cheney
CBItAC                             and hasCustDays
CBItAC                   if        savdsp = *blanks
CBItAC                   eval      kystat = 'A '
CBItAC                   eval      kypick = 'N'
CBItAC     keysl3        setll     slot13
CBItAC     keysl3        reade     slot13                                 79
CBItAC                   select
CBItAC                   when      *in79 = *off
CBItAC                             and sldesg <> 'BFC'
CBItAC                   eval      kyaisl = slaisl
CBItAC                   eval      kypseq = slpseq
CBItAC                   eval      kyrlvl = slrlvl
CBItAC                   eval      savloc = slloc
CBItAC                   eval      kyhand = slhand
CBItAC                   eval      savdsp = sldisp
CBItAC*    No pick slot found for item. Find first overflow slot.
CBItAC                   when      *in79 = *on
CBItAC                   eval      kystat = 'A '
CLDcAC                   eval      kypick = 'Y'
CLDcAC     keysl3        setll     slot13
CLDcAC     keysl3        reade     slot13                                 79
CLDcAC                   select
CLDcAC                   when      *in79 = *off
CLDeAC                             and sldesg <> 'BFC'
CLDcAC                   eval      kyaisl = slaisl
CLDcAC                   eval      kypseq = slpseq
CLDcAC                   eval      kyrlvl = slrlvl
CLDcAC                   eval      savloc = slloc
CLDcAC                   eval      kyhand = slhand
CLDcAC                   eval      savdsp = sldisp
CLDcAC                   endsl
CLDcAC                   endsl
CLDcAC
CLDcAC                   endif
CBItMC                   endsl
410 AC                   clear                   slrec
CLDcAC*
CLDcAC*    Restore last location used for use with "out" label.
CBIsA*
CBIsAC                   if        clientloc = cbigr
CBIsAC                             and savdsp = *blanks
CBIsAC***                          and itwhdp = 'CLR'
CBIsAC                             and (imbnbr = 150
CBIsAC                             or   imbnbr = 155
CBIsAC                             or   imbnbr = 160)
CBIsAC                   select
CBIsAC                   when      imbnbr = 150
CBIsAC                             or imbnbr = 160
CBIsAC                   eval      slaisl = ' MT'
CBIyDC*                  eval      slloc = 84
CBIyMC                   eval      slloc = 101
CBIsAC                   eval      slpseq = slloc
CBIsAC                   eval      slrlvl = 1
CBIyDC*                  movel (p) 'MT-84-09'    sldisp
CBIyMC                   movel (p) 'MT-101-1'    sldisp

CBIsAC                   when      imbnbr = 155
CBIzDC*                  eval      slaisl = ' FI'
CBIzMC                   eval      slaisl = ' FS'
CBIyDC*                  eval      slloc = 00
CBIyMC                   eval      slloc = 100
CBIsAC                   eval      slpseq = slloc
CBIsAC                   eval      slrlvl = 1
CBIyDC*                  movel (p) 'FI-00-11'    sldisp
CBIzDC*                  movel (p) 'FI-100-1'    sldisp
CBIzMC                   movel (p) 'FS-100-1'    sldisp
CBIsAC                   endsl

CBIsAC                   else

CLDcAC                   if        client = cityln
CBIcAC                             or client = cheney
CLDcAC                   eval      slaisl = kyaisl
CLDcAC                   eval      slrlvl = kyrlvl
CLDcAC                   eval      slpseq = kypseq
CLDcAC                   eval      sldisp = savdsp
CBIcAc                   if        client = cheney
CBIcAC                   eval      slloc = savloc
CBIcAC                   eval      slhand = kyhand
CBIcAc                   endif
CLDcAC                   endif
CBIsAC                   endif
410 AC                   eval      slwhse = itwhse
410 AC                   eval      slwhdp = itwhdp
410 AC                   eval      slstyp = itstyp
410 AC                   eval      pickq1 = excpq1
410 AC                   eval      pickq2 = excpq2
410 AC                   eval      pickq3 = excpq3
410 AC                   eval      lwltyp = 'O'
410 AC                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = 'OUT'
410 AC                   exsr      post
410 AC                   endif
410 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICKS   Pick special order item.
     *
     *  Note: Special order items will be treated similarly too
     *        PIR items.  However, we are not limited to picking
     *        slots (although non-picking slots will be searched
     *        first) but we are limited to slots with a matching
     *        status code. Also, a general allocation was not done
     *        because these slots are considered inactive slots which
     *        can't be allocated from. Because this is a special order
     *        we should be able to allocate everything. If we can't,
     *        someone will have to determine why we were told to
     *        pick more stock than was set aside for the special
     *        orders.
     *
     *        If a carton has to be broken the stock quantity is
     *        adjusted for the slot. This adjustment will be made
     *        at the warehouse level when the item is picked.
     *
520bA*         In 520a this changed a little bit. For a brkdn 1 qty
520bA*         we attempt to pick full cases, then pick eaches.
520bA*
     C     picks         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKS   '    trsubr
413aAC                   exsr      zztrck
     *
     *   Loop through picking slots for item.
     *
     *     Note: This looks at both pick and reserve slots.
     *
     C                   eval      kystat = odspcl
     C     keyspc        setll     slot3
     C                   dou       forevr <> forevr
     C     keyspc        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKS   '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
520bAC                   eval      pckall = *off
520cAC                   exsr      pick0
     *
520cD**                   Z-ADD0         PICKQ1
520cD**                   Z-ADD0         PICKQ2
520cD**                   Z-ADD0         PICKQ3
520cD**
520cD**    Try to pick normal quantity.
520cD**
520cD**         LEFTQ1    IFGT 0
520cD**                   EXSR PICK1
520cD**                   ENDIF
520cD**
520cD**    Try to pick breakdown 1 quantity.
520cD**
520cD**         LEFTQ2    IFGT 0
520cD**                   EXSR PICK2
520cD**                   ENDIF
520cD**
520cD**    Try to pick breakdown 2 quantity.
520cD**
520cD**         LEFTQ3    IFGT 0
520cD**                   EXSR PICK3
520cD**                   ENDIF
     *
     *     If something was picked create picking label(s).
     *
     C                   if        pickq1 <> 0  or
     C                             pickq2 <> 0  or
     C                             pickq3 <> 0
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
413eAC                   eval      lwlas2 = *blanks
     C                   exsr      post
     C                   eval      leftq1 = leftq1 - pickq1
     C                   eval      leftq2 = leftq2 - pickq2
     C                   eval      leftq3 = leftq3 - pickq3
     C                   add       pickq1        ttlpk1
     C                   add       pickq2        ttlpk2
     C                   add       pickq3        ttlpk3
     C                   endif
     *
     *     No need to look further, if no quantity left to pick.
     *
     C                   if        leftq1 = 0  and
     C                             leftq2 = 0  and
     C                             leftq3 = 0
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *   If everything wasn't picked then print an error.
     *
     C                   if        leftq1 <> 0  or
     C                             leftq2 <> 0  or
     C                             leftq3 <> 0
     *
     *      We do not have to unallocate anything becuase warehouse
     *      allocation isn't done for special orders.
     *
     *      Convert picked quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
411 AC                   if        ittype = 'S'
411 AC                   eval      $cqty1 = pickq2
411 AC                   eval      $cqty2 = pickq3
411 AC                   eval      $cqty3 = 0
411 AC                   else
     C                   eval      $cqty1 = pickq1
     C                   eval      $cqty2 = pickq2
     C                   eval      $cqty3 = pickq3
411 AC                   endif
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      p1qpck = $cqstr
     *
     *      Print error message.
     *
     C                   eval      p1msg = msg(4)
     C                   exsr      prterr
413aAC                   eval      trnbr = 'TR04'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'PICKS   '    trsr50
413aAC                   exsr      zztrck
     C                   endif
410 A*
410 A*      Create picking exception label(s).
410 AC                   if        opelbl = 'Y'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             opelbl = 'Y'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
410 AC                   add       leftq1        excpq1
410 AC                   add       leftq2        excpq2
410 AC                   add       leftq3        excpq3
410 AC                   if        excpq1 > 0  or
410 AC                             excpq2 > 0  or
410 AC                             excpq3 > 0
410 AC                   clear                   slrec
410 AC                   eval      slwhse = itwhse
410 AC                   eval      slwhdp = itwhdp
410 AC                   eval      slstyp = itstyp
410 AC                   eval      pickq1 = excpq1
410 AC                   eval      pickq2 = excpq2
410 AC                   eval      pickq3 = excpq3
410 AC                   eval      lwltyp = 'O'
410 AC                   eval      lwlqav = 0
410 AC                   eval      lwlas2 = 'OUT'
410 AC                   exsr      post
410 AC                   endif
410 AC                   endif
     *
     C                   endsr
710gA*
710gA*----------------------------------------------------------------
710gA*
710gA*  ZZCHKSLOT   See if item occupies one or more regular slots in
710gA*              the whse. Slots where SLDESG = BFC will treatead
710gA*              as if item is not found in any slots.
710gA*
710gAC     zzchkslot     begsr
710gA*
730fAC                   select
750dAc                   when      dpck
750dAc                   eval      slotfound = '*YES'
750dAc                   leavesr
710gA*       Items with no Special Status code.
730fAC                   when      odspcl = ' '
730fA*
710gAC                   eval      kystat    = 'A '
710gAC                   eval      slotfound = '*NO '
710gAC     keyspc        setll     slot3
710gAC                   dow       forevr = forevr
710gAC     keyspc        reade (n) slot3
710gAC                   if        %eof(slot3)
710gAC                   leave
710gAC                   endif
710gA*
710gA*       Ignore internal use slots.
710gAC                   if        sldesg = 'BFC'
710gAC                   iter
710gAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
710gA*
710gAC                   eval      slotfound = '*YES'
730fDC*                  leave
730fMC                   leavesr
710gA*
710gAC                   enddo
710gA*
710gA*       Items with XD/XE Special Status code.
730fAC                   when         odspcl = 'XD'
730fAC                             or odspcl = 'XE'
730fA*
730fAC                   eval      kystat    = 'XD'
730fAC                   eval      slotfound = '*NO '
730fAC     keyspc        setll     slot3
730fAC                   dow       forevr = forevr
730fAC     keyspc        reade (n) slot3
730fAC                   if        %eof(slot3)
730fAC                   leave
730fAC                   endif
730fA*
730fA*       Ignore internal use slots.
730fAC                   if        sldesg = 'BFC'
730fAC                   iter
730fAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
710gA*
730fAC                   eval      slotfound = '*YES'
730ffC                   leavesr
730fA*
730fAC                   enddo
710gA*
710gA*       All other items with Special Status code.
730fAC                   when         odspcl > '  '
710gA*       Treat item as if slot was found.
710gA*       Do not want Special Status code to be overridden
710gA*       by XDK logic.
730fAC                   eval      slotfound = '*YES'
730ffC                   leavesr
730fA*
730fAC                   endsl
710gA*
710gAC     endchkslot    endsr
710gA*
710gA*----------------------------------------------------------------
710gA*
710gA*  ZZCRTXD   Use DRISLOT with %CRTXDOCK to create new cross dock
710gA*           slot if one does not exist.
710gA*
710gAC     zzcrtxd       begsr
710gA*
710gAC                   exsr      clr$slot
710gAC                   eval      $slwhseu = *on
710gAC                   eval      $slwhse  = odwhse
710gAC                   eval      $slwhdpu = *on
710gAC                   eval      $slwhdp  = itwhdp
710gAC                   eval      $slitemu = *on
710gAC                   eval      $slitem  = oditem
710gAC                   eval      $slaislu = *on
710gAC                   eval      $slaisl  = 'XDK'
710gAC                   eval      $dricommand = '*SLOT'
710gAC                   eval      $drisubcmd = '%CRTXDOCK'
710gAC                   eval      $drisys2upd = 'D'
710gAC                   eval      ck4err = *on
710gAC                   exsr      zzzdricop
710gAC                   if        error = *on
710gAC                   goto      endcrtxd
710gAC                   endif
710gA*
710gAC     endcrtxd      endsr
FPR3A*
FPR3A*----------------------------------------------------------------
FPR3A*
FPR3A*  ZZCRXD   Use DRISLOT with %CRTXDOCK to create new cross dock
FPR3A*           slot if one does not exist.  Then use %ALLOCATE to
FPR3A*           put the qty into the slot.
FPR3AC     zzcrxd        begsr
FPR3A*
FPR3AC                   exsr      clr$slot
FPR3AC                   eval      $slwhseu = *on
FPR3AC                   eval      $slwhse  = odwhse
FPR3AC                   eval      $slwhdpu = *on
FPR3AC                   eval      $slwhdp  = itwhdp
FPR3AC                   eval      $slitemu = *on
FPR3AC                   eval      $slitem  = oditem
FPR3AC                   eval      $slaislu = *on
FPR3AC                   eval      $slaisl  = 'XDK'
FPR3AC                   eval      $dricommand = '*SLOT'
FPR3AC                   eval      $drisubcmd = '%CRTXDOCK'
FPR3AC                   eval      $drisys2upd = 'D'
FPR3AC                   eval      ck4err = *on
FPR3AC                   exsr      zzzdricop
FPR3AC                   if        error = *on
FPR3AC                   goto      endcrxd
FPR3AC                   endif
FPR3A*
PCKjAC                   if        client = pack730
PCKjA*  Bypass allocation for XDK OUT label, will go to runner.
PCKjAC                   goto      endcrxd
PCKjAC                   endif
FPR3A*
FPR3A*
FPR3A*  Use DRISLOT/%ALLOCATE to put the qty into the slot.
FPR3A*
FPR3AC                   eval      $dricommand = '*SLOT'
FPR3AC                   eval      $drisubcmd = '%ALLOCATE'
FPR3AC                   eval      $drisys2upd = 'D'
FPR3AC                   eval      $saitemu = *on
FPR3AC                   eval      $saitem  = $slitem
FPR3AC                   eval      $sldispu = *on
FPR3AC                   eval      $saqtyu = *on
FPR3AC                   eval      $saqty1 = leftq1
FPR3AC                   eval      $saqty2 = leftq2
FPR3AC                   eval      $saqty3 = leftq3
FPR3AC                   eval      ck4err = *on
FPR3AC                   exsr      zzzdricop
FPR3AC                   if        error = *on
FPR3AC                   goto      endcrxd
FPR3AC                   endif
FPR3A*
FPR3AC     endcrxd       endsr
FPR3A*
740aA*----------------------------------------------------------------
740aA*  zzLoadToSlt   Load To Slot for Drop Pick when one is not already
740aA*                defined
740aA*----------------------------------------------------------------
740aA
740aAC     zzLoadToSlt   begsr
740aA
740aA *  Call GETDDSLOT to determine if Drop Pick Slot defined
740aA
740aAc                   call      'GETDDSLOT'
740aAc                   parm                    odwhse
740aAc                   parm                    itwhdp
740aAc                   parm                    cmpitem
740aAc                   parm      *blanks       prfdis           12
740aAc                   parm      *blanks       prfail            3
740aAc                   parm      *zeros        prfloc            3 0
740aAc                   parm      *blanks       s_sldisp
740aAc                   parm      *blanks       s_slaisl
740aAc                   parm      *zeros        s_slloc
740aAc                   parm      *zeros        s_slrlvl
740aAc                   parm      *blanks       s_slhand
750aAc                   parm      0             pddqty1           3 0
750aAc                   parm      ' '           pddtype           1
750aAc                   parm      'ALC'         ptrntype          3
740aAc                   parm      *blanks       pReturn          10
740aA
740aAC                   endsr
     *----------------------------------------------------------------
     *
404 A*  PICKXD  Pick cross dock item.
     *
     *  Note: A cross dock item is a special case.  The general idea is that
     *        the item is currently out of stock but will be received later
     *        during the picking shift.  Because of the time it takes to pick
     *        the order, the order must be sent to us before the item is
     *        received.  At import time, an 'XDK' slot record was created to
     *        contain the item.  A record was also created int he CROSSDK file
     *        to record this information.
     *
     *        This program gets the slot record and allocates everything that
     *        was ordered without check for available qty.
     *
     *
404 AC     pickxd        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICKXD  '    trsubr
413aAC                   exsr      zztrck
404 A*
404 A*   Get slot assigned to cross dock item.
     *
610dDC*****keycd1        chain     crossdk1                           77
610dDC******in77         cabeq     *on           endpxd
     *
610dDC*****keysl2        chain     slot2                              77
     *
     *   With Cheney, multi XDK will exist for same item
     *                  use ommsc1 OCASTOP vs sldisp/slloc
CBIvAC                   if        client = cheney
CBIvA /free
CBIvA    ocadisp = *blanks;
CBIvA    ocadisp = ('XDK-' + ocastop);
CBIvA    setll ($pwhse: itwhdp: oditem: ocadisp) slot4;
CBIvA    read slot4;
CBIvA /end-free
CBIvAC                   else

JOR AC                   eval      kyspcl = 'XD'
610dMC     keys10        chain     slot10                             77
     C     *in77         cabeq     *on           endpxd
CBIvAC                   endif
     C                   eval      kystat = slstat
     C                   eval      kypick = slpick
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
     C     keys3c        chain     slot3                              77
     C     *in77         cabeq     *on           endpxd
     *
     *     Pick everything.  No questions asked.
     *
740bA*  If Same Slot Breakdown Item
740bA*   Then quantities need to be changed into corresponding
740bA*        Base breakdown quantities.
740bA*
740bAC                   if        ittype = 'S'  or
740bAC                             ittype = 'A'  and
740bAC                             #bityp = 'S'
740bAC                   eval      pickq3 = odqor2
740bAC                   eval      pickq2 = odqor1
740bAC                   eval      pickq1 = 0
740bA*
740bAC                   eval      picku3 = odqor2
740bAC                   eval      picku2 = odqor1
740bAC                   eval      picku1 = 0
740bA*
740bAC                   else
740bA*
     C                   eval      pickq1 = odqor1
     C                   eval      pickq2 = odqor2
     C                   eval      pickq3 = odqor3
520bA*
520bAC                   eval      picku1 = odqor1
520bAC                   eval      picku2 = odqor2
520bAC                   eval      picku3 = odqor3
740bAC                   endif
     *
     *     Create picking labels.
     *
     C                   eval      lwltyp = 'O'
     C                   eval      lwlqav = 0
PCKiA*
PCKiA*     Set OUT flag so that items are sent to Runner module.
PCKiAC                   if        client = pack730
PCKiAC                   eval      lwlas2 = 'OUT'
PCKiAC                   else
PCKiA*
413eAC                   eval      lwlas2 = *blanks
PCKiAC                   endif
PCKiA*
     C                   exsr      post
404 AC     endpxd        endsr
     *----------------------------------------------------------------
     *
     *  PICK0   Pick quantity needed.
     *
     C     pick0         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICK0   '    trsubr
413aAC                   exsr      zztrck
     *
     *     Initialize pick quantities.
     *
     C                   eval      pickq1 = 0
     C                   eval      pickq2 = 0
     C                   eval      pickq3 = 0
520bA*
520bAC                   eval      picku1 = 0
520bAC                   eval      picku2 = 0
520bAC                   eval      picku3 = 0
     *
     *     Try to pick normal quantity.
     *
     C                   if        leftq1 > 0
     C                   exsr      pick1
     C                   endif
     *
     *     Try to pick breakdown 1 quantity.
     *
     C                   if        leftq2 > 0
     C                   exsr      pick2
     C                   endif
     *
     *     Try to pick breakdown 2 quantity.
     *
     C                   if        leftq3 > 0
     C                   exsr      pick3
     C                   endif
     *
520bAC                   eval      pckall = *off
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  PICK0EA Pick quantity needed for *EACH
700fA*
700fAC     pick0EA       begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'PICK0EA '    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*     Initialize pick quantities.
700fA*
700fAC                   eval      pickq2 = 0
700fAC                   eval      pickq3 = 0
700fA*
700fAC                   eval      picku2 = 0
700fAC                   eval      picku3 = 0
700fA*
700fA*
700fA*     Try to pick breakdown 1 quantity.
700fA*
700fAC                   if        leftq2 > 0
700fAC                   exsr      pick2EA
700fAC                   endif
700fA*
700fA*     Try to pick breakdown 2 quantity.
700fA*
700fAC                   if        leftq3 > 0
700fAC                   exsr      pick3EA
700fAC                   endif
700fA*
700fAC                   eval      pckall = *off
700fAC                   endsr
     *----------------------------------------------------------------
     *
     *  PICK1  Pick normal quantity.
     *
     C     pick1         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICK1   '    trsubr
413aAC                   exsr      zztrck
     *
     *   If there is enough normal qty available then grab it.
     *     Otherwise, just grab what is available.
     *
     C                   if        leftq1 <= avail1  or
520bAC                             pckall = *on  or
CLDdAC                             client = cityln and
CLDdAC                             slstyp = 'F' or
CLDdAC                             client = cityln and
CLDdAC                             pckcmd = '*FORCE  ' or
VIP1A*
FPR1MC                             (client = vip
FPR1AC                             or  client = foodpro)
VIP1A*     IDS allocation override flag Y=Yes.
FPR1MC                             and omiaov = 'Y'  or
MJK1A*
MJK1AC                             client = mjkeln  and
MJK1A*     IDS allocation override flag Y=Yes.
MJK1AC                             omiaov = 'Y'
GFC1A*
GFC1AC                             or client = glazier and
GFC1A*     H&S allocation override flag Y=Yes.
GFC1AC                             omiaov = 'Y'
SOF1A*
SOF1AC                             or client = sofofoods and
SOF1A*     IDS allocation override flag Y=Yes.
SOF1AC                             omiaov = 'Y'
SGC1AC*
SGC1AC                             or client = SGC
SGC1AC*     SGC allocation override flag Y=Yes.
SGCeDC*                            and sgcdm1_omalco = 'Y'
SGCeMC                             and omiaov = 'Y'
SGC1AC*
VIP1A*
     C                   eval      pickq1 = leftq1
     C                   else
     C                   eval      pickq1 = avail1
     C                   endif
     *
     C                   eval      avail1 = avail1 - pickq1
520bAC                   eval      picku1 = pickq1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK2  Pick breakdown 1 quantity.
     *
     C     pick2         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICK2   '    trsubr
413aAC                   exsr      zztrck
     *
     *   If there is enough breakdown 1 qty available then grab it.
     *
     C                   select
     C                   when      leftq2 <= avail2  or
CLDdAC                             client = cityln or
CLDdAC                             client = cityln and
CLDdAC                             pckcmd = '*FORCE  ' or
VIP1A*
FPR1MC                             (client = vip
FPR1AC                             or client = foodpro)
VIP1A*     IDS allocation override flag Y=Yes.
VIP1AC                             and omiaov = 'Y'  or
MJK1A*
MJK1AC                             client = mjkeln  and
MJK1A*     IDS allocation override flag Y=Yes.
MJK1AC                             omiaov = 'Y'
SOF1A*
SOF1AC                             or client = sofofoods and
SOF1A*     IDS allocation override flag Y=Yes.
SOF1AC                             omiaov = 'Y'
SGC1AC*
SGC1AC                             or client = SGC
SGC1AC*     SGC allocation override flag Y=Yes.
SGCeDC*                            and sgcdm1_omalco = 'Y'
SGCeMC                             and omiaov = 'Y'
SGC1AC*
VIP1A*
520bAC                   eval      picku2 = leftq2
     C                   eval      pickq2 = leftq2
520bAC                   sub       leftq2        avail2
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a normal unit.
520bA*           (This is not true)
     *
520bA*     As of 520a we try to pick full cases then eaches. This is
520bA*     because brkdn 1 qty's over 999 were being sent to be picked.
520bA*     The 'PICKU' qtys reflect the actual uom qty's we picked
520bA*     from the slot, while the 'PICKQ' qty's is what we picked
520bA*     of the label.
520bA*
     C                   other
520bA*
520bA*   First, try to pick full cases
520bA*
520bAC                   eval      svqty2 = leftq2
520bAC                   dow       svqty2 >= itumq2  and
520bAC                             avail1 > 0  and
520bAC                             itumq2 > 0
520bAC                   add       1             picku1
520bAC                   eval      avail1 = avail1 - 1
520bAC                   add       itumq2        pickq2
520bAC                   eval      svqty2 = svqty2 - itumq2
520bAC                   enddo
520bA*
520bA*   Then pick the remaining qty from the brkdn 1 qty
520bA*
520bAC                   dow       svqty2 > 0
520bA*
520bA*       If enough available, pick entire qty.
520bA*
520bAC                   if        svqty2 <= avail2
520bAC                   add       svqty2        picku2
520bAC                   add       svqty2        pickq2
520bAC                   sub       svqty2        avail2
520bAC                   eval      svqty2 = 0
520bAC                   leave
520bAC                   endif
520bA*
520bA*       Not enough availalbe, break down a case and loop.
520bA*
520bAC                   if        avail1 > 0  and
520bAC                             itumq2 > 0
520bAC                   eval      avail1 = avail1 - 1
520bAC                   add       itumq2        avail2
520bAC                   eval      slstk1 = slstk1 - 1
520bAC                   add       itumq2        slstk2
520bAC                   iter
520bAC                   endif
520bA*
520bA*       Case not available, take what we can get.
520bA*
520bAC                   if        avail2 > 0
520bAC                   add       avail2        picku2
520bAC                   add       avail2        pickq2
520bAC                   eval      svqty2 = svqty2 - avail2
520bAC                   eval      avail2 = 0
520bAC                   endif
520bA*
520bAC                   leave
520bAC                   enddo
520bA*
520bA*   If any qty still remains and we are to pick it all
520bA*     Then pick it all, cases first, then brkdn 1.
520bA*
520bAC                   if        pckall = *on
520bA*
520bAC                   if        svqty2 > 0
520bAC                   dow       svqty2 >= itumq2  and
520bAC                             itumq2 > 0
520bAC                   add       1             picku1
520bAC                   eval      avail1 = avail1 - 1
520bAC                   add       itumq2        pickq2
520bAC                   eval      svqty2 = svqty2 - itumq2
520bAC                   enddo
520bAC                   endif
520bA*
520bAC                   if        svqty2 > 0
520bAC                   add       svqty2        picku2
520bAC                   add       svqty2        pickq2
520bAC                   sub       svqty2        avail2
520bAC                   eval      svqty2 = 0
520bAC                   endif
520bA*
520bAC                   endif
520bA*
520bA*   Last of all, convert brkdn1 into cases
520bA*
520bAC                   dow       svqty2 >= itumq2  and
520bAC                             itumq2 > 0
520bAC                   add       1             picku1
520bAC                   eval      avail1 = avail1 - 1
520bAC                   add       itumq2        pickq2
520bAC                   eval      svqty2 = svqty2 - itumq2
520bAC                   enddo
520bA*
520bAC                   endsl
520bA*
520bA*
520bD**
520bD**     Try to break a normal unit and grab what's needed.
520bD**
520bD**                   SELEC
520bD**         AVAIL1    WHGT 0
520bD**                   SUB  1         AVAIL1
520bD**                   ADD  ITUMQ2    AVAIL2
520bD**                   SUB  1         SLSTK1
520bD**                   ADD  ITUMQ2    SLSTK2
520bD**                   Z-ADDLEFTQ2    PICKQ2
520bD**
520bD**     Otherwise, just grab what is available for breakdown 1.
520bD**
520bD**                   OTHER
520bD**                   Z-ADDAVAIL2    PICKQ2
520bD**
520bD**                   ENDSL
520bD**
520bD**                   ENDSL
520bD**
520bD**                   SUB  PICKQ2    AVAIL2
     *
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  PICK2EA  Pick breakdown 1 quantity for *EACH.
700fA*
700fAC     pick2EA       begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'PICK2EA '    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*   If there is enough breakdown 1 qty available then grab it.
700fA*
700fAC                   select
700fAC                   when      leftq2 <= avail2  or
700fAC                             client = cityln or
700fAC                             client = cityln and
700fAC                             pckcmd = '*FORCE  ' or
700fA*
700fAC                             client = vip  and
700fA*     IDS allocation override flag Y=Yes.
700fAC                             omiaov = 'Y'  or
700fA*
700fAC                             client = mjkeln  and
700fA*     IDS allocation override flag Y=Yes.
700fAC                             omiaov = 'Y'
700fAC*
700fAC                             or client = SGC
700fAC*     SGC allocation override flag Y=Yes.
700fAC                             and sgcdm1_omalco = 'Y'
700fAC*
700fA*
700fAC                   eval      picku1 = 0
700fAC                   eval      picku2 = leftq2
700fAC                   eval      pickq2 = leftq2
700fAC                   sub       leftq2        avail2
700fA*
700fA*   Otherwise try to break a larger unit to get qty needed.
700fA*
700fA*     Note: The qty needed will always be less than the qty
700fA*           in a normal unit.
700fA*           (This is not true)
700fA*
700fA*     As of 520a we try to pick full cases then eaches. This is
700fA*     because brkdn 1 qty's over 999 were being sent to be picked.
700fA*     The 'PICKU' qtys reflect the actual uom qty's we picked
700fA*     from the slot, while the 'PICKQ' qty's is what we picked
700fA*     of the label.
700fA*
700fAC                   other
700fA*
700fA*   First, try to pick full cases
700fA*
700fAC                   eval      svqty2 = leftq2
700fAC                   dow       svqty2 >= itumq2  and
700fAC                             avail1 > 0  and
700fAC                             itumq2 > 0
700fAC                   add       1             picku1
700fAC                   eval      avail1 = avail1 - 1
700fAC                   add       itumq2        pickq2
700fAC                   eval      svqty2 = svqty2 - itumq2
700fAC                   enddo
700fA*
700fA*   Then pick the remaining qty from the brkdn 1 qty
700fA*
700fAC                   dow       svqty2 > 0
700fA*
700fA*       If enough available, pick entire qty.
700fA*
700fAC                   if        svqty2 <= avail2
700fAC                   add       svqty2        picku2
700fAC                   add       svqty2        pickq2
700fAC                   sub       svqty2        avail2
700fAC                   eval      svqty2 = 0
700fAC                   leave
700fAC                   endif
700fA*
700fA*       Not enough availalbe, break down a case and loop.
700fA*
700fAC                   if        avail1 > 0  and
700fAC                             itumq2 > 0
700fAC                   eval      avail1 = avail1 - 1
700fAC                   add       itumq2        avail2
700fAC                   eval      slstk1 = slstk1 - 1
700fAC                   add       itumq2        slstk2
700fAC                   iter
700fAC                   endif
700fA*
700fA*       Case not available, take what we can get.
700fA*
700fAC                   if        avail2 > 0
700fAC                   add       avail2        picku2
700fAC                   add       avail2        pickq2
700fAC                   eval      svqty2 = svqty2 - avail2
700fAC                   eval      avail2 = 0
700fAC                   endif
700fA*
700fAC                   leave
700fAC                   enddo
700fA*
700fA*   If any qty still remains and we are to pick it all
700fA*     Then pick it all, cases first, then brkdn 1.
700fA*
700fAC                   if        pckall = *on
700fA*
700fAC                   if        svqty2 > 0
700fAC                   dow       svqty2 >= itumq2  and
700fAC                             itumq2 > 0
700fAC                   add       1             picku1
700fAC                   eval      avail1 = avail1 - 1
700fAC                   add       itumq2        pickq2
700fAC                   eval      svqty2 = svqty2 - itumq2
700fAC                   enddo
700fAC                   endif
700fA*
700fAC                   if        svqty2 > 0
700fAC                   add       svqty2        picku2
700fAC                   add       svqty2        pickq2
700fAC                   sub       svqty2        avail2
700fAC                   eval      svqty2 = 0
700fAC                   endif
700fA*
700fAC                   endif
700fA*
700fA*   Last of all, convert brkdn1 into cases
700fA*
700fAC                   dow       svqty2 >= itumq2  and
700fAC                             itumq2 > 0
700fAC                   add       1             picku1
700fAC                   eval      avail1 = avail1 - 1
700fAC                   add       itumq2        pickq2
700fAC                   eval      svqty2 = svqty2 - itumq2
700fAC                   enddo
700fA*
700fAC                   endsl
700fA*
700fA*
700fA*
700fAC                   endsr
     *----------------------------------------------------------------
     *
     *  PICK3  Pick breakdown 2 quantity.
     *
     C     pick3         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PICK3   '    trsubr
413aAC                   exsr      zztrck
     *
     *   If there is enough breakdown 2 qty available then grab it.
     *
     C                   select
     C                   when      leftq3 <= avail3
     C                   eval      pickq3 = leftq3
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a breakdown 1 unit.
     *
     C                   other
520cA*     Unfortunately, this was not the case until 520b, when
520cA*     the code was changed to up the LEFTQ1/2/3 fields.
520cA*
     *
     *      Try to break a breakdown 1 unit and grab what's needed.
     *
     C                   select
     C                   when      avail2 > 0
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Then try to break a normal unit and grab what's needed.
     *
     C                   when      avail1 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Otherwise, just grab what is available for breakdown 2.
     *
     C                   other
     C                   eval      pickq3 = avail3
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   sub       pickq3        avail3
520bAC                   eval      picku3 = pickq3
     *
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  PICK3EA  Pick breakdown 2 quantity for *EACH.
700fA*
700fAC     pick3EA       begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'PICK3EA '    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*   If there is enough breakdown 2 qty available then grab it.
700fA*
700fAC                   select
700fAC                   when      leftq3 <= avail3
700fAC                   eval      pickq3 = leftq3
700fA*
700fA*   Otherwise try to break a larger unit to get qty needed.
700fA*
700fA*     Note: The qty needed will always be less than the qty
700fA*           in a breakdown 1 unit.
700fA*
700fAC                   other
700fA*     Unfortunately, this was not the case until 520b, when
700fA*     the code was changed to up the LEFTQ1/2/3 fields.
700fA*
700fA*
700fA*      Try to break a breakdown 1 unit and grab what's needed.
700fA*
700fAC                   select
700fAC                   when      avail2 > 0
700fAC                   eval      avail2 = avail2 - 1
700fAC                   add       itumq3        avail3
700fAC                   eval      slstk2 = slstk2 - 1
700fAC                   add       itumq3        slstk3
700fAC                   eval      pickq3 = leftq3
700fA*
700fA*      Then try to break a normal unit and grab what's needed.
700fA*
700fAC                   when      avail1 > 0
700fAC                   eval      avail1 = avail1 - 1
700fAC                   add       itumq2        avail2
700fAC                   eval      slstk1 = slstk1 - 1
700fAC                   add       itumq2        slstk2
700fAC                   eval      avail2 = avail2 - 1
700fAC                   add       itumq3        avail3
700fAC                   eval      slstk2 = slstk2 - 1
700fAC                   add       itumq3        slstk3
700fAC                   eval      pickq3 = leftq3
700fA*
700fA*      Otherwise, just grab what is available for breakdown 2.
700fA*
700fAC                   other
700fAC                   eval      pickq3 = avail3
700fA*
700fAC                   endsl
700fA*
700fAC                   endsl
700fA*
700fAC                   sub       pickq3        avail3
700fAC                   eval      picku3 = pickq3
700fA*
700fAC                   endsr
     *----------------------------------------------------------------
     *
     *  POST    Post picking labels.
     *
     C     post          begsr
730eA**
730eA**  Get Slot Sequence with new Option and possible soft coding
730eA**
730eAc                   monitor
730eAc                   call      'GETPSEQO'
730eAc                   parm      '*GETPSEQ'    gpscmd            8
740fDc*                  parm                    slwhse
750 Mc                   parm      $pwhse        $sslwhse          3 0
730eAc                   parm                    slwhdp
730eAc                   parm                    sldisp
730eAc                   parm      ' '           gpSeqcd           1
730eAc                   parm      0             gpSeq             5 0
730eAc                   parm      ' '           usrDFPICK         1
730eAc                   on-error
730eAc                   eval      gpSeq = slpseq
730eAc                   endmon
730eA*
730eA**  Override SLPSEQ with what GETPSEQO returns
730eA*
750 AC                   IF        gpSeq > 0
730eAc                   eval      slpseq = gpSeq
750 AC                   endif
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'POST    '    trsubr
413aAC                   exsr      zztrck
     *
     *   Create picking labels - one for each quantity breakdown.
     *
CLD AC                   if        client = cityln
CLD A*    Don't create label for PIR item that doesn't have
CLD A*    any slots in the warehouse.
CLDbA*    Create OUT labels for Breakdown PIR items.
CLD AC                   if        itstyp = 'P'  and
CLD AC                             lwlas2 = 'OUT'  and
CLD AC                             sldisp = *blanks and
CLDbAC                             ittype <> 'B'
CLD AC                   goto      endpst
CLD A*
CLD AC                   endif
CLD AC                   endif
500eA*
500eA*      If OUT doesn't have a slot, try to get one.
500eA*
500eAC                   if        lwlas2 = 'OUT'  and
500eAC                             sldisp = *blanks
500eAC                   if        itstyp = 'P'
500eAC                   eval      $scmd = '*LAST'
500eAC                   else
500eAC                   eval      $scmd = '*FIRST'
500eAC                   endif
500eAC                   call      'GETPSLT'
500eAC                   parm                    $scmd             8
500eAC                   parm      itwhse        $swhse            3 0
500eAC                   parm      oditem        $sitem           15
500eAC                   parm                    sldisp
500eAC                   parm                    slaisl
500eAC                   parm                    slloc
500eAC                   parm                    slrlvl
500eAC                   parm                    slhand
500eAC                   parm                    $srtn             8
500eAC                   parm                    slpseq
510bAC                   if        $srtn = '*NONE'
510bAC                   eval      sldisp = *blanks
510bAC                   eval      slaisl = *blanks
510bAC                   eval      slloc = 0
510bAC                   eval      slrlvl = 0
510bAC                   eval      slhand = *blanks
510bAC                   eval      slpseq = 0
510bAC                   endif
500eAC                   endif
     *
     *      Initialize label fields.
     *
     C                   clear                   lwrec
     C                   eval      lwwhse = slwhse
640dD ***                select
640dD ***                when      client = silberman
640dD ***                          or client = cashwa
640dD ***                          or client = citywho
SLBaAC                   eval      lwtruk = $ptmpl
640dD ***                other
640dD ***                eval      lwtruk = $ptruk
640dD ***                endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
410 AC                   eval      lwasl2 = lwlas2
CBIoA*
CBIoAC                   if        client = cheney  and
CBIoAC                             clientloc = cbigwb  and
CBIoAC                             lwasl2 = 'OUT'  and
CBIoAC                             lwdisp = ' '
CBIoAC                   movel     'OUT'         lwdisp
CBIoAC                   endif
CBIoA*
     C                   eval      lwqavl = lwlqav
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop

620bAC*                  if        prepick = *on
620bAC*                  call      'GETSTOP'
620bAC*                  parm      '*ORDSTP'     $scmd
620bAC*                  parm      lwwhse        $swhse
620bAC*                  parm      lwrte         $srtid
620bAC*                  parm      lword         $sord
620bAC*                  parm      0             $sdstp
620bAC*                  parm                    $sstp
620bAC*                  endif

     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = ohtype
     C                   eval      lwtype = lwltyp
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
650jA *    Do NOT set special field for prepick slots.
700eA *    hasAMPpick in the Normal Delv Rt & should not clear sp cd
700eA *      AND the AMP order should not have special codes
700eA *      XD, cross dock in delv rt so allow XD to stay
650jAC                   if        lwaisl = 'PRE'
700eD **                           or hasAMPpick
650jAC                   eval      lwspcl = *blanks
650jAC                   else
     C                   eval      lwspcl = odspcl
650jAC                   endif
     C                   eval      lwucub = 0
     C                   eval      lwcube = 0
     C                   eval      lwuwgt = 0
     C                   eval      lwswgt = 0
     *
     *      Create label for normal quantity.
     *
     C                   if        pickq1 > 0
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
730gAC                   exsr      WriteUM
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 1 quantity.
     *
     C                   if        pickq2 > 0
     C                   eval      lwutyp = *on
     C                   eval      lwucod = itum2
     C                   if        itumq2 <> 0
     C     itcube        div(h)    itumq2        lwucub
     C     lwucub        mult      pickq2        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
     C     lwuwgt        mult      pickq2        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq2
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
730gAC                   exsr      WriteUM
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 2 quantity.
     *
     C                   if        pickq3 > 0
     C                   eval      lwutyp = '2'
     C                   eval      lwucod = itum3
     C                   if        itumq2 <> 0  and
     C                             itumq3 <> 0
     C     itcube        div(h)    itumq2        lwucub
410 MC     lwucub        div(h)    itumq3        lwucub
410 D*R         LWCUBE    DIV  ITUMQ3    LWUCUB    H
     C     lwucub        mult      pickq3        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
410 MC     lwuwgt        div(h)    itumq3        lwuwgt
410 D*R         LWSWGT    DIV  ITUMQ3    LWUWGT    H
     C     lwuwgt        mult      pickq3        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq3
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
730gAC                   exsr      WriteUM
     C                   write     lwrec
     C                   endif
     *
     *   Update slot allocation.
     *
404 A*     - Corss dock items were allocated during import.
     *
404 AC                   if        odspcl <> 'XD'
730fAC                             and odspcl <> 'XE'
520bD**                   ADD  PICKQ1    SLALC1
520bD**                   ADD  PICKQ2    SLALC2
520bD**                   ADD  PICKQ3    SLALC3
520bA*
520bAC                   add       slalc1        picku1
520bAC                   add       slalc2        picku2
520bAC                   add       slalc3        picku3
520bA*
520bAC                   dow       picku2 >= itumq2  and
520bAC                             itumq2 > 0
520bAC                   add       1             picku1
520bAC                   eval      picku2 = picku2 - itumq2
520bAC                   enddo
520bA*
520bAC                   eval      slalc1 = picku1
520bAC                   z-add     picku2        slalc2
520bAC                   z-add     picku3        slalc3
520bA*
520bAC                   exsr      avail
520bAC                   dow       avail2 >= itumq2  and
520bAC                             slstk2 >= itumq2  and
520bAC                             itumq2 > 0
520bAC                   add       1             slstk1
520bAC                   eval      slstk2 = slstk2 - itumq2
520bAC                   eval      avail2 = avail2 - itumq2
520bAC                   enddo
520bA*
404 AC                   endif
410 AC                   if        lwlas2 <> 'OUT'
     C                   update    slrec
410 AC                   endif
CLD A*
CLD AC     endpst        tag
     *
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  POSTEA  Post picking labels for *EACH
700fA*
700fAC     postea        begsr
730eA**
730eA**  Get Slot Sequence with new Option and possible soft coding
730eA**
730eAc                   monitor
730eAc                   call      'GETPSEQO'
730eAc                   parm      '*GETPSEQ'    gpscmd            8
740fDc*                  parm                    slwhse
750 Mc                   parm      $pwhse        $sslwhse          3 0
730eAc                   parm                    slwhdp
730eAc                   parm                    sldisp
730eAc                   parm      ' '           gpSeqcd           1
730eAc                   parm      0             gpSeq             5 0
730eAc                   parm      ' '           usrDFPICK         1
730aAc                   on-error
730eAc                   eval      gpSeq = slpseq
730eAc                   endmon
730eA*
730eA**  Override SLPSEQ with what GETPSEQO returns
730eA*
750 Ac                   if        gpSeq > 0
730eAc                   eval      slpseq = gpSeq
750 Ac                   endif
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'POSTEA  '    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*   Create picking labels - one for each quantity breakdown.
700fA*
700fAC                   if        client = cityln
700fA*    Don't create label for PIR item that doesn't have
700fA*    any slots in the warehouse.
700fA*    Create OUT labels for Breakdown PIR items.
700fAC                   if        itstyp = 'P'  and
700fAC                             lwlas2 = 'OUT'  and
700fAC                             sldisp = *blanks and
700fAC                             ittype <> 'B'
700fAC                   goto      endpstea
700fA*
700fAC                   endif
700fAC                   endif
700fA*
700fA*      If OUT doesn't have a slot, try to get one.
700fA*
700fAC                   if        lwlas2 = 'OUT'  and
700fAC                             sldisp = *blanks
700fAC                   if        itstyp = 'P'
700fAC                   eval      $scmd = '*LAST'
700fAC                   else
700fAC                   eval      $scmd = '*FIRST'
700fAC                   endif
700fAC                   call      'GETPSLT'
700fAC                   parm                    $scmd             8
700fAC                   parm      itwhse        $swhse            3 0
700fAC                   parm      oditem        $sitem           15
700fAC                   parm                    sldisp
700fAC                   parm                    slaisl
700fAC                   parm                    slloc
700fAC                   parm                    slrlvl
700fAC                   parm                    slhand
700fAC                   parm                    $srtn             8
700fAC                   parm                    slpseq
700fAC                   if        $srtn = '*NONE'
700fAC                   eval      sldisp = *blanks
700fAC                   eval      slaisl = *blanks
700fAC                   eval      slloc = 0
700fAC                   eval      slrlvl = 0
700fAC                   eval      slhand = *blanks
700fAC                   eval      slpseq = 0
700fAC                   endif
700fAC                   endif
700fA*
700fA*      Initialize label fields.
700fA*
700fAC                   clear                   lwrec
700fAC                   eval      lwwhse = slwhse
700fAC                   eval      lwtruk = $ptmpl
700fAC                   eval      lwwhdp = slwhdp
700fAC                   eval      lwaisl = slaisl
700fAC                   eval      lwloc = slloc
700fAC                   eval      lwrlvl = slrlvl
700fAC                   eval      lwhand = slhand
700fAC                   eval      lwpseq = slpseq
700fAC                   eval      lwstyp = slstyp
700fAC                   if        lwstyp = 'P'
700fAC                   eval      lwqryf = 1
700fAC                   else
700fAC                   eval      lwqryf = 0
700fAC                   endif
700fAC                   eval      lwdisp = sldisp
700fAC                   eval      lwasl2 = lwlas2
700fAC                   eval      lwqavl = lwlqav
700fAC                   eval      lwrte = ohrte
700fAC                   eval      lwstop = ohstop


700fAC                   eval      lword = ohord
700fAC                   eval      lwseq = odseq
700fAC                   eval      lwitem = oditem
700fAC                   eval      lwpbat = $pbat
700fAC                   eval      lwgrp1 = 'S'
700fAC                   eval      lwgrp2 = ohtype
700fAC                   eval      lwtype = lwltyp
700fAC                   eval      lwstat = 'A'
700fAC                   eval      lwsdte = today
700fAC                   time                    lwstim
700fAC                   eval      lwrdte = today
700fA *    Do NOT set special field for prepick slots.
700fA *    hasAMPpick in the Normal Delv Rt & should not clear sp cd
700eA *      AND the AMP order should not have special codes
700fA *      XD, cross dock in delv rt so allow XD to stay
700fAC                   if        lwaisl = 'PRE'
700fAC                   eval      lwspcl = *blanks
700fAC                   else
700fAC                   eval      lwspcl = odspcl
700fAC                   endif
700fAC                   eval      lwucub = 0
700fAC                   eval      lwcube = 0
700fAC                   eval      lwuwgt = 0
700fAC                   eval      lwswgt = 0
700fA*
700fA*      Create label for breakdown 1 quantity.
700fA*
700fAC                   if        pickq2 > 0
700fAC                   eval      lwutyp = *on
700fAC                   eval      lwucod = itum2
700fAC                   if        itumq2 <> 0
700fAC     itcube        div(h)    itumq2        lwucub
700fAC     lwucub        mult      pickq2        lwcube
700fAC     itswgt        div(h)    itumq2        lwuwgt
700fAC     lwuwgt        mult      pickq2        lwswgt
700fAC                   endif
700fAC                   eval      lwqalc = pickq2
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
700fAC                   write     lwrec
700fAC                   endif
700fA*
700fA*      Create label for breakdown 2 quantity.
700fA*
700fAC                   if        pickq3 > 0
700fAC                   eval      lwutyp = '2'
700fAC                   eval      lwucod = itum3
700fAC                   if        itumq2 <> 0  and
700fAC                             itumq3 <> 0
700fAC     itcube        div(h)    itumq2        lwucub
700fAC     lwucub        div(h)    itumq3        lwucub
700fAC     lwucub        mult      pickq3        lwcube
700fAC     itswgt        div(h)    itumq2        lwuwgt
700fAC     lwuwgt        div(h)    itumq3        lwuwgt
700fAC     lwuwgt        mult      pickq3        lwswgt
700fAC                   endif
700fAC                   eval      lwqalc = pickq3
730kDC**                 call      'PIRLBL#'
730kDC**                 parm                    lwlbl#
730kMC                   exsr      GetNextLbl#
730kMC                   eval      lwlbl# = nextLbl#
700fAC                   write     lwrec
700fAC                   endif
700fA*
700fA*   Update slot allocation.
700fA*
700fA*     - Corss dock items were allocated during import.
700fA*
700fAC                   if        odspcl <> 'XD'
730fAC                             and odspcl <> 'XE'
700fA*
700fAC                   add       slalc1        picku1
700fAC                   add       slalc2        picku2
700fAC                   add       slalc3        picku3
700fA*
700fAC                   dow       picku2 >= itumq2  and
700fAC                             itumq2 > 0
700fAC                   add       1             picku1
700fAC                   eval      picku2 = picku2 - itumq2
700fAC                   enddo
700fA*
700fAC                   eval      slalc1 = picku1
700fAC                   z-add     picku2        slalc2
700fAC                   z-add     picku3        slalc3
700fA*
700fAC                   exsr      avail
700fAC                   dow       avail2 >= itumq2  and
700fAC                             slstk2 >= itumq2  and
700fAC                             itumq2 > 0
700fAC                   add       1             slstk1
700fAC                   eval      slstk2 = slstk2 - itumq2
700fAC                   eval      avail2 = avail2 - itumq2
700fAC                   enddo
700fA*
700fAC                   endif
700fAC                   if        lwlas2 <> 'OUT'
700fAC                   update    slrec
700fAC                   endif
700fA*
700fAC     endpstea      tag
700fA*
700fAC                   endsr
     *----------------------------------------------------------------
     *
     *  PRTERR  Print error exception.
     *
     C     prterr        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'PRTERR  '    trsubr
413aAC                   exsr      zztrck
410 AC                   if        operpt <> 'N'  and
414aAC                             ophpwc = 'N'  or
414aA*
414aAC                             operpt <> 'N'  and
414aAC                             ophpwc = 'Y'  and
414aAC                             $potyp <> 'W'
     *
     *  See if we should printer header.
     *
     C                   if        prflag <> *on  or
     C                             *in90
     C                   write     head1
     C                   if        *in90
     C                   write     head2
     C                   endif
     C                   write     columns
     C                   eval      prflag = *on
     C                   eval      *in90 = *off
     C                   endif
     *
     *   Print detail line.
     *
     C                   write     detail1
414cAC                   write     detail2
410 AC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  REPLNS  Replenish PIR slot.
     *
     C     replns        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'REPLNS  '    trsubr
413aAC                   exsr      zztrck
     *
     *   Loop through picking slots for item.
     *
     C                   eval      found = *off
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade(n)  slot3                                  77
     C                   if        *in77  or
     C                             found = *on
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
     *
     *     Ignore slot if it is a PIR slot but not reserved.
     *
     C                   if        slrsrv <> 'Y'  and
411 AC                             slstyp = 'P'
     C                   iter
     C                   endif
     *
     *     Ignore slot if past expiration date.
415c *     and there is quantity in stock.
     *
     C                   if        slexpd <> 0  and
700iDC**                           slexpd < today  and
700iMC                             slexpd < expDate and
413bAC                             itflgd = 'Y'
415cAC                   if        slstk1 > 0  or
415cAC                             slstk2 > 0  or
415cAC                             slstk3 > 0
413aAC                   eval      trnbr = 'TR09'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'REPLNS  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
415cAC                   endif
     *
     *     Calculate quantity available in slot.
     *
411 AC                   if        ittype <> 'C'
     C                   exsr      avail
411 AC                   endif
     *
     *     Replenish slot if not enough available.
     *
413fD**         AVAIL1    IFLT LEFTQ1
413fD**         ITTYPE    OREQ 'C'
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = slwhdp
     C                   eval      $ltail = slaisl
     C                   eval      $ltdis = sldisp
411 AC                   if        ittype = 'C'
411 AC                   eval      $litem = oditem
411 AC                   else
     C                   eval      $litem = slitem
411 AC                   endif
     C                   z-add     leftq1        $lqty
     C                   eval      $lsdef = slsdef
     C                   eval      $lloc = slloc
     C                   eval      $lrlvl = slrlvl
     C                   eval      $lhand = slhand
     C                   eval      $lstyp = slstyp
     C                   eval      $ltype = ittype
     C                   eval      $lavl1 = 0
     C                   eval      $lavl2 = 0
     C                   eval      $lavl3 = 0
     C                   eval      $lrtn = *blanks
     C                   call      'OR634'
     C                   parm                    $lwhse            3 0
     C                   parm                    $lwhdp            5
     C                   parm                    $prtid
     C                   parm                    $pbat
     C                   parm                    $ltail            3
     C                   parm                    $ltdis           12
     C                   parm                    $litem           15
     C                   parm                    $lqty             3 0
     C                   parm                    $lsdef            2
     C                   parm                    $lloc             3 0
     C                   parm                    $lrlvl            2 0
     C                   parm                    $lhand            2
     C                   parm                    $lstyp            1
     C                   parm                    $ltype            1
     C                   parm                    $lavl1            3 0
     C                   parm                    $lavl2            3 0
     C                   parm                    $lavl3            3 0
     C                   parm                    $lrtn             8
413fD**                   ENDIF
     C                   eval      found = *on
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UNALOC  Unallocate quantity from ITEMQTY file.
     *
411 A*    Revised to unallocate from Base item when item ordered
411 A*    is an Alias or Same Slot Breakdown item.
     *
     C     unaloc        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'UNALOC  '    trsubr
413aAC                   exsr      zztrck
     *
     *   Unallocate quantity needed from the warehouse qty (ITEMQTY).
     *
     C                   eval      $acmd = '*UNALLOC'
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*BATCH  '
     C                   eval      $awhse = $pwhse
411 AC                   if        ittype = 'A'  or
411 AC                             ittype = 'S'
417cD**                   MOVE #BITEM    $AITEM
417cMC                   eval      $aitem = #sitem
411 AC                   else
     C                   eval      $aitem = oditem
411 AC                   endif
     C                   eval      $aqty1 = leftq1
     C                   eval      $aqty2 = leftq2
     C                   eval      $aqty3 = leftq3
     *
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     *
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  UNALOCEA  Unallocate quantity from ITEMQTY file for *EACH.
700fA*
700fA*    Revised to unallocate from Base item when item ordered
700fA*    is an Alias or Same Slot Breakdown item.
700fA*
700fAC     unalocEA      begsr
700fA*
700fA*  Write out tracking record.
700fA*
700fAC                   eval      trcode = '*PCK040 '
700fAC                   movel     'UNALOCEA'    trsubr
700fAC                   exsr      zztrck
700fA*
700fA*   Unallocate quantity needed from the warehouse qty (ITEMQTY).
700fA*
700fAC                   eval      $acmd = '*UNALLOC'
700fAC                   eval      $aprg = #prog
700fAC                   eval      $atype = '*BATCH  '
700fAC                   eval      $awhse = $pwhse
700fAC                   if        ittype = 'A'  or
700fAC                             ittype = 'S'
700fAC                   eval      $aitem = #sitem
700fAC                   else
700fAC                   eval      $aitem = oditem
700fAC                   endif
700fAC                   eval      $aqty1 = 0
700fAC                   eval      $aqty2 = leftq2
700fAC                   eval      $aqty3 = leftq3
700fA*
700fAC                   call      'ADJQTY'
700fAC                   parm                    $acmd
700fAC                   parm                    $aprg
700fAC                   parm                    $atype
700fAC                   parm                    $awhse
700fAC                   parm                    $aitem
700fAC                   parm                    $aqty1
700fAC                   parm                    $aqty2
700fAC                   parm                    $aqty3
700fAC                   parm                    $artq1
700fAC                   parm                    $artq2
700fAC                   parm                    $artq3
700fAC                   parm                    $artn
700fAC                   parm                    $aerm
700fA*
700fAC                   endsr

730gA*----------------------------------------------------------------
730gA*  WriteUM    Write WORKLBLUM record
730gA*----------------------------------------------------------------
730gA
730gAC     WriteUM       begsr
      /free

       // Get out if not a Flex Pick

       if umFlexPickFlag = '';
         leavesr;
       endif;

       // Initialize fields

       lwualq1 = 0;
       lwualu1 = '';
       lwualq2 = 0;
       lwualu2 = '';
       lwualq3 = 0;
       lwualu3 = '';

       // Only use fields associated with label UM type
       // For Pick-To-Weight, set label weight to the weight to pick.

       select;

         when lwutyp = 'N';
           lwualq1 = oduorq1;
           lwualu1 = oduoru1;
           if umFlexPickFlag = 'P2W';
             lwswgt = lwualq1;
           endif;

         when lwutyp = '1';
           lwualq2 = oduorq2;
           lwualu2 = oduoru2;
           if umFlexPickFlag = 'P2W';
             lwswgt = lwualq2;
           endif;

         when lwutyp = '2';
           lwualq3 = oduorq3;
           lwualu3 = oduoru3;
           if umFlexPickFlag = 'P2W';
             lwswgt = lwualq3;
           endif;

       endsl;

       monitor;
         umWhse = lwwhse;
         umworklbl('*ADD': umRtnCode: umRtnMsg:
                   umWhse: lwlbl#:
                   umFlexPickFlag:
                   lwualq1: lwualu1: lwualq2: lwualu2: lwualq3: lwualu3);
       on-error;
       endmon;

      /end-free
     C                   endsr

650nA
650nA*----------------------------------------------------------------
650nA*  updProdWO  Update Production Work Order calling DRIPROD
650nA*----------------------------------------------------------------
650nA
650nAC     updProdWO     begsr
650nA /free
650nA
650nA           savever# = $ppver#;
650nA           $ppver# = savever#;
650nA
650nA           $ppSessIdu = *on;
650nA           $ppSessid  = pSessId;
650nA           $ppwhseu = *on;
650nA           $ppwhse  = $pwhse;
650nA           $ppwo#u = *on;
650nA           $ppwo#  = wkwo#;
650nA           $ppitemu = *on;
650nA           $ppitem  = ititem;
650nA           $ppuser = #User;
650nA           $ppuseru = *on;
650nA           $ppdest = 'C';
650nA           $ppdestu = *on;
650nA           $ppcust = ohcust;
650nA           $ppcustu = *on;
650nA           $ppcustwo = ohcpo;
650nA           $ppcustwou = *on;
650nA           $ppcord = ohcord;
650nA           $ppcordu = *on;
650nA           $ppmake = $ppmake + woqty;
650nA           $ppmakeu = *on;
650nA           $ppQty1 = $ppmake;
650nA           $ppQty1u = *on;
650nA           $pplneno = ipmfgno;
650nA           $pplnenou = *on;
650nA           $ppstat = 'P';       // Status is Planning
650nA           $ppstatu = *on;
650nA           $ppprio = 3;
650nA           $pppriou = *on;
730cA           $ppwipa=' ';
730cA           $ppwipau=*on;
730cA           $ppovrdu=*on;
730cA           $ppovrd=0;
730cA           $ppcbd1u=*on;
730cA           $ppcbd1=0;
730cA           $ppcbd2u=*on;
730cA           $ppcbd2=0;
650nA
650nA           $dricommand = '*PROD';
730cD           //$drisubcmd = '%UPDPRODWO';
730cA           $drisubcmd = '%UPDLOOP';
650nA           $drisys2upd = 'D';
650nA           exsr zzzDriCop;
650nA
650nA /end-free
650nAC                   endsr
650dA*----------------------------------------------------------------
650dA*  ZZADJQTY Adjust parent quantity required per the output
650dA*           factor configured in KITITEM as part of Repack Itm
650dA*----------------------------------------------------------------
650dA
650dAC     zzadjqty      begsr
650dA /free
650dA
650dA  // Each quantity will be reviewed.  The total quantity requested
650dA  // will be divided by the output quantity defined in item maint.
650dA  // This value is found in KITITEM.  If that value exceeds 1 then
650dA  // the user is saying this represents on of these items.
650dA  // Therefore, if the user requested 10 and
650dA  // the components say they make 2 then we would divide the 10
650dA  // by 2 to get 5.  5 times the component list is what would be
650dA  // consumed to make these 10 pieces. The remainder is placed in
650dA  // the breakdown quantity below that level
650dA
650dA     // determine lowest level defined in item maintenance
650dA     select;
650dA        when #bumq3<>0;
650dA           wopqndec = (wopqn1 * #bumq2
650dA                         * #bumq3) +
650dA                      (wopqn2 * #bumq3)+
650dA                       wopqn3;
650dA           wopqndec = (wopqndec / OutPutQty);
650dA      // if it is decided later to enforce zero decimals between
650dA      // output quantity in kititem and parent quantity in kitcomp
650dA      // just take out the adding 1 if dec>0.  You will also need
650dA      // to make changes marked in IT116
650dA          if dec>0;
650dA             wopqn3 = wopqndec +1;
650dA          else;
650dA             wopqn3 = wopqndec;
650dA          endif;
650dA           wopqn1 = 0;
650dA           wopqn2 = 0;
650dA
650dA        when #bumq2<>0;
650dA           wopqndec = (wopqn1 * #bumq2) +
650dA                       wopqn2;
650dA           wopqndec = (wopqndec / OutPutQty);
650dA      // if it is decided later to enforce zero decimals between
650dA      // output quantity in kititem and parent quantity in kitcomp
650dA      // just take out the adding 1 if dec>0.  You will also need
650dA      // to make changes marked in IT116
650dA          if dec>0;
650dA             wopqn2 = wopqndec +1;
650dA          else;
650dA             wopqn2 = wopqndec;
650dA          endif;
650dA           wopqn1 = 0;
650dA           wopqn3 = 0;
650dA
650dA        other;
650dA           wopqndec = (wopqn1 / OutPutQty);
650dA      // if it is decided later to enforce zero decimals between
650dA      // output quantity in kititem and parent quantity in kitcomp
650dA      // just take out the adding 1 if dec>0.  You will also need
650dA      // to make changes marked in IT116
650dA          if dec>0;
650dA             wopqn1 = wopqndec +1;
650dA          else;
650dA             wopqn1 = wopqndec;
650dA          endif;
650dA           wopqn2 = 0;
650dA           wopqn3 = 0;
650dA
650dA     endsl;
650dA
650dA /end-free
650dAc                   endsr
650dA
650eA*----------------------------------------------------------------
650eA*  ZZAllocRepack - This routine will determine if available stock
650eA*    exists for ODR item request.  These stock quantities are
650eA*    are calculated to be used in determining whether to build
650eA*    stock or simply pull from stock.  If stock build is required
650eA*    additional routine will be called first to see and get qty
650eA*    from case item if it exist (zzGetCaseStock)
650eA*----------------------------------------------------------------
650eA
650eAC     zzallocRepack begsr
650eA /free
650eA
650eA  #odriqavl1 = 0;
650eA  #odriqavl2 = 0;
650eA  #odriqavl3 = 0;
650lA  #odrpckavl = 0;
650lA  #odrovravl = 0;
650lA  odrrPick = ' ';
650eA  if Firstrecd or frmzzGetCase;
650eA    if not frmzzGetCase;
650eA       exsr crtrpkslt;
650eA    endif;
650eA  // If ODR slot not created get out.
650eA    if not drierr or
650eA        (drierr and $drireturn = 'INSLOT')
650eA          or frmzzGetCase;
650eA       if not frmzzGetCase;
650fA          onDmdHold = onDmdcallsonDmd;
650fA          odrOrigSlt = odrslot;
650eA          #odrslavl1 = 0;
650eA          kystat='A';
650eA       endif;
650eA
650eA       setll ($pwhse:#sitem:kystat) slot3;
650iD  //   reade(n) ($pwhse:#sitem:kystat) slot3;
650iD  //   dow not %eof and %found;
650iA       dow forever = forever;
650eA
650iA          reade(n) ($pwhse:#sitem:kystat) slot3;
650iA          if %eof(slot3);
650iA             leave;
650iA          endif;
650iA
650eA  // exclude unwanted slots
650eA          if sldesg = 'BFC';
650eA             iter;
650eA          endif;
740gA
740gA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740gA
740gA /free
740gA    monitor;
740gA      wwwhse = slwhse;
740gA      wwloc = slloc;
740gA      WWTFR('*CHKTFR': slaisl: wwloc: wwwhse: #user: wwrtn: wwmsg);
740gA      if wwrtn = '*YES';
740gA        iter;
740gA      endif;
740gA    on-error;
740gA    endmon;
740gA /end-free
740gA
650eA
650eA          if slpick <> 'Y' and slpick <> 'N';
650eA             iter;
650eA          endif;
650eA
650eA  // retrieve all available stock for repack item
650eA          exsr clr$slot;
650eA          $slwhseu = *on;
650eA          $slwhse  = slwhse;
650eA          $slwhdpu = *on;
650eA          $slwhdp  = slwhdp;
650eA          $sldispu = *on;
650eA          $sldisp = sldisp;
650eA
650eA          $dricommand = '*SLOT';
650eA          $drisubcmd  = '%GET';
650eA          $drisys2upd = 'D';
650eA          chk4err = *on;
650eA          exsr zzzdricop;
650eA          if not drierr;
650eA            #odriqavl1 = #odriqavl1 + $slavl1;
650eA            #odriqavl2 = #odriqavl2 + $slavl2;
650eA            #odriqavl3 = #odriqavl3 + $slavl3;
650eA            if $slpick = 'Y';      //capture Pick and Ovrflw separate
650eA             #odrpckavl =+ $slavl1;  //capture full case qty pick slot
650eA             odrrPick = $sldisp;     //capture full case qty pick slot
650eA            else;
650eA             #odrovravl =+ $slavl1;  //capture full case qty ovrf slot
650eA            endif;
650eA          endif;
650eA
650iD  //      reade(n) ($pwhse:#sitem:kystat) slot3;
650eA
650eA       enddo;
650eA    endif;
650eA /end-free
650eA
650fA* If this was called from zzGetcase then only calc avl qty and return
650fA
650eAc                   if        frmzzGetCase
650eAc                   leavesr
650eAc                   endif
650mA
650mA* Force negative calculated availables to zero
650mAc                   if        #odrpckavl < 0
650mAc                   eval      #odrpckavl = 0
650mAc                   endif
650mA
650mAc                   if        #odrovravl < 0
650mAc                   eval      #odrovravl = 0
650mAc                   endif
650mA
650mAc                   if        #odriqavl1 < 0
650mAc                   eval      #odriqavl1 = 0
650mAc                   endif
650mA
650mAc                   if        #odriqavl2 < 0
650mAc                   eval      #odriqavl2 = 0
650mAc                   endif
650mA
650mAc                   if        #odriqavl3 < 0
650mAc                   eval      #odriqavl3 = 0
650mAc                   endif
650mA
730bA *
730bA *  if ondemand Repack item and no breakdown is defined on the RP status
730bA *  case item then convert quantity needed to case total instead of order demand.
730bA *  In other words we build how many the repack configuration states instead of
730bA *  the order demand and then pull one or more cases from RP status instead of
730bA *  building partials and reducing rp case by eaches/breakdowns.  This logic is
730bA *  is also used if kit configuration builds "X" number of repacks per a case
730bA *  or cases and uses no breakdowns of parent.  In this example the case item
730bA *  can still have a breakdown defined, but this logic will not use it.
730bA *
730bA /free
730bA                    noBDwnRpkQty = *zeros;
730bA                    // loop should always be correct based on parent item
730bA                    // being processed for Repack.  If repack has one parent
730bA                    // loop should be 1, if repack has 2 parents loop should
730bA                    // be 1 or 2.  I have if below in case it gets here with 0
730bA                    // but that should never happen
730bA                    if loop < 1;
730bA                       loop = 1;
730bA                    endif;
730bA                    if (leftq1 - #odrpckavl) > 0 and
730bA                           ((%trim(#bum2)='' and %trim(#bum3)='') or
730bA                            (aePqty1(loop)>0 and aePqty2(loop)=0
730bA                               and aePqty3(loop)=0));
730bA                        // if we are short of stock either no breakdown
730bA                        // is defined on the parent case or the kit uses
730bA                        // no breakdown quantities to build the repacks
730bA                        // we should
730bA                        // build repack item stock based on kititem
730bA                        // output quantity per the case
730bA                        qtyToMake = leftq1 - #odrpckavl;    // get order demand qty
730bA                        if kiqty1 = 0;
730bA                           kiqty1 = 1;
730bA                        endif;
730bA                        noBDwnRpkQty = %div((leftq1-#odrpckavl):kiqty1);
730bA                        if %rem((leftq1-#odrpckavl):kiqty1) > 0;  // get number cases required
730bA                           noBDwnRpkQty = noBDwnRpkQty + 1;
730bA                        endif;
730bA                        // change qtyToMAke to match number per full case(s) required
730bA                        qtyToMake = noBDwnRpkQty * kiQty1;
730bA                    else;
730bA /end-free
650eA
650fA* Calculate qty to make, leave if odr pick slot has required qty
650fA
650fAC                   eval      qtyToMake = leftq1 - #odrpckavl
650fAC                   if        qtyToMake <= 0
650fAc                   eval      odrBldNeeded = *off
650fAC                   leavesr
650fAC                   endif
730bAC                   endif
650fA*  check to see if overflow slots exist to cover the remaining
650fA*   pieces required for the order
650fAc                   if        #odrovravl >= qtyTomake
650fA*  execute DRIPRTYRPL code to create replenishment to pick
650fA*  and leave since everything is covered with existing stock
650fA*  Zero QTYMADE since no other parents should be processed
650fAc                   eval      prqtyn = qtyTomake
650fAc                   eval      qtyTomake = 0
650fAc                   exsr      crtprtyrpl
650fAc                   eval      odrBldNeeded = *off
650fAc
650fAc                   leavesr
650fAc                   else
650fA*  else, create replenishment with amount in overflow and
650fA*  and continue through repack process to create remainder
650fA*  qty required
650fAc                   if        #odrovravl > 0
650fAc                   eval      prqtyn = qtyTomake - #odrovravl
650fAc                   eval      qtyTomake = qtyTomake - #odrovravl
650fAc                   exsr      crtprtyrpl
650fAc                   endif
650fAc                   endif
650fAc                   endif
650fA
650fAc     zzEndAlloc    endsr
650fA
610bA*----------------------------------------------------------------
610bA*     ZZCrtOdrQty - Check 4 on demand repack item
610bA*----------------------------------------------------------------
610bA*
610bAC     ZZCrtOdrQty   begsr

650eA* Create Virtual pick slot for on demand repack item if one does
650eA* not exist.
650eAc                   if        FirstRecd
620fA
     **
     * Put Quantity in Pick slot

     *  Initialize data structure
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = itwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = odrSlot

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = odritem

     C                   eval      $saqtyu  = *on
620fAC                   eval      $saqty1  = qtyToMake

620fDC**                 select
620fDC**                 when      #odrslavl1 > 0
620fDC**                 eval      $saqty1  = #odrslavl1 - leftq1
    D ***                when      #odrslavl1 = 0
620fDC**                 when      #odrslavl1 <= 0
620fDC**                 eval      $saqty1  = leftq1
620fDC**                 endsl

620fDC**                 if        $saqty1 > 0

     C                   eval      $saqty2  = leftq2
     C                   eval      $saqty3  = leftq3

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'ODR'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
650fA /free
650fA              aryBck = %subarr(aryRPD:1:%elem(aryRPD));
650fA              exsr zzzdricop;
650fA              aryRPD = %subarr(aryBck:1:%elem(aryBck));
650fA /end-free
620fDC**                 endif
650bAc                   endif

610bA**
610bA* Take Quantity out of Breaker slot.
650bA
650bA*** Retrieve Slot info from parent on-demand slot
650bAC                   exsr      clr$slot
650bAC                   eval      $slwhseu = *on
650bAC                   eval      $slwhse  = $gwhse
650bAC                   eval      $slwhdpu = *on
650bAC                   eval      $slwhdp  = #bwhdp
650bAC                   eval      $sldispu = *on
650bAC                   eval      $sldisp  = aepdisp(loop)
650bA
650bAC                   eval      $dricommand = '*SLOT'
650dAc                   if        onDmdCallsonDmd
650dAc                   eval      $drisubcmd  = '%GETODRRPK'
650bAC                   eval      $slitemu = *on
650bAC                   eval      $slitem  = aepitem(loop)
650dAc                   else
650dAc                   eval      $drisubcmd  = '%GET'
650dAc                   endif
650bAC                   eval      $drisys2upd = 'D'
650bAC                   eval      chk4err = *on
650bAC                   eval      zmsflag = *on
650bAC                   exsr      zzzdricop
650bAC                   if        drierr
650bAC                   endif
650dAc                   eval      odrppick = $sldisp
650dA
650bA** If parent on-demand slot is normal slot then do not perform
650bA**   replen to a RP slot but to the normal pick slot
650bAc                   select
650bAc                   when      $slstat = 'A' and not onDmdCallsonDmd
650bAC                   eval      $saactionu = *on
650bAc                   eval      $saAction = ' '
650bAc                   other
650bAC                   eval      $saactionu = *on
650bAC                   eval      $saAction  = 'ODR'
650bAc                   endsl
650bA
     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
650bAC                   eval      $slwhse  = $gwhse

     C                   eval      $slwhdpu = *on
650bAC                   eval      $slwhdp = #bwhdp

     C                   eval      $sldispu = *on
650dMC*                  eval      $sldisp  = odrBaseSlot
650dAC                   eval      $sldisp  = odrppick

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = odrbaseitem

620dAC                   exsr      rpkqty
620fAC                   if        wopqn1=0 and wopqn2=0 and wopqn3=0
620fAC                   leavesr
620fAC                   endif

     C                   eval      $saqtyu  = *on
620fMC                   eval      $saqty1  = -(wopqn1)
620fMC                   eval      $saqty2  = -(wopqn2)
620fMC                   eval      $saqty3  = -(wopqn3)

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'ODR'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTORD'
     C                   eval      $drisys2upd = 'D'
650fA /free
650fA                    aryBck = %subarr(aryRPD:1:%elem(aryRPD));
650fA                    exsr zzzdricop;
650fA                    aryRPD = %subarr(aryBck:1:%elem(aryBck));
650fA /end-free

     C     EndCrtOdrQty  endsr

650fA*----------------------------------------------------------------
650fA*  zzGetCaseStock - This routine is called when it is determined
650fA*    that the order calls for an ODR item that is calling another
650fA*    ODR item where too little stock exists for the order.  This
650fA*    routine will read through kit structures until the case item
650fA*    is found.  It will create full pieces of the called ODR
650fA*    items and relieve quantity required to build quantity
650fA*    requested.  This will ensure the case item is the item
650fA*    driven negative if no stock exists
650fA*
650fA*    The routine will start at the bottom of the chain.  It starts
650fA*    with the Repack Item ordered and the parent(s) that calls.
650fA*    An array is kept with every ODR being called as it blows through
650fA*    the levels.  savKitq1-3 have the previous levels parent
650fA*    requirements, savRpkqt2-3 have the breakdown quantities for the
650fA*    previous Repack Item.  odrPreviousQty represents the quantity
650fA*    issued and used at the previous level and savOutQty represents
650fA*    the previous Kit Output quantity.  That is, a KIT can now produce
650fA*    more than one Repack quantity per the list of parents.
650fA*
650fA*    Keep in mind that this routine will start with moving inventory
650fA*    to the first parent and pulling stock from the next level.  Once
650fA*    a normal/non ODR item is found it goes no further and returns to
650fA*    the normal process which adds stock to the ordered ODR item and
650fA*    pulls from the parent items
650fA*
650fA*    Example:  Customer order ODR item1 which calls ODR item2
650fA*    which calls ODR item3 which calls the case item
650fA*
650fA*    This starts by adding stock to ODR item2 and pulling stock from
650fA*    ODR item3 in full normal units from ODR item3.  It will post
650fA*    the next ODR item item3 to an array as an indicator that we
650fA*    another level to process.  The next level will determine no more
650fA*    ODR items are being processed and will pull stock from the case
650fA*    item and post stock to ODR item3.  It will then return to the
650fA*    normal OR610 process flow and that will post ordered quantities
650fA*    to the ODR item the customer ordered and pull from the first
650fA*    parent(s).
650fA*
650fA*    The process will still produce the quantity the customer wants
650fA*    and drive things negative if no stock exists.  However, it will
650fA*    now trace all the way back to the case item instead of driving
650fA*    a Repack Item negative.
650fA*----------------------------------------------------------------
650fA
650fAC     zzgetCaseStockbegsr
650fA /free
650fA     //setup initial item search
650fA     odrPlus = 0;
650fA     aryCnt = 1;
650fA     fwdCnt = 2;
650fA     hldQtyMake = qtyToMake;
650fA     odrPreviousQty = qtyToMake;
650fA     %subarr(aryODR:1:%elem(aryODR)) = *loval; // initialize array
650fA     nxtODR(aryCNT) = aePitem(loop);
650fA     savKitq1(aryCNT) = aePQty1(loop);
650fA     savKitq2(aryCNT) = aePQty2(loop);
650fA     savKitq3(aryCNT) = aePQty3(loop);
650fA     savRitem(aryCNT) = aeRitem(loop);
650fA     savOutQty(aryCNT) = aeRQty1(loop);
650fA     savRpkq2(aryCNT) = #bumq2;
650fA     savRpkq3(aryCNT) = #bumq3;
650fA
650fA     dow nxtODR(arycnt) <> *loval;
650fa
650fA        //loop through ODR parent passed
650fA        setll (itwhse:nxtODR(aryCNT)) kitcomp;
650fA        dow forever = forever;
650fA
650fA        reade (itwhse:nxtODR(aryCNT)) kitcomp;
650fA
650fA        if %eof(kitcomp);
650fA           leave;
650fA        endif;
650fA
650fA           chain (kcwhse:kccitm) kititem;
650fA     //if parent read is an ODR item then add to array so it will
650fA     //be processed after current ODR is completed
650fA           if %found and kirptp = '2';
650fA              odritem = kccitm;
650fA              $gODRSlot = kcdisp;
650fA              exsr crtrpkslt;  //make sure ODR Slot exists item
650fA              nxtODR(fwdCnt) = kccitm;
650fA              savKitq1(fwdCnt) = kcqty1;
650fA              savKitq2(fwdCnt) = kcqty2;
650fA              savKitq3(fwdCnt) = kcqty3;
650fA              savRitem(fwdCnt) = kcitem;
650fA              savOutQty(fwdCNT) = kiqty1;
650fA              fwdCnt += 1;
650fA              onDmdCallsonDmd = *on;
650fA           else;
650fA              onDmdCallsonDmd = *off;
650fA           endif;
650fA
650fA     // make sure odr item parent has pick slot
650fA              chain (kcwhse:kcitem) kititem;
650fA              if %found and kirptp = '2';
650fA                 odritem = kiitem;
650fA                 $gODRSlot = kidisp;
650fA                 exsr crtrpkslt;  //make sure ODR Slot exists item
650fA              endif;
650fA    // determine slot and issue parent required stock
650fA              exsr clr$slot;
650fA              $slwhseu = *on;
650fA              $slwhse  = kcwhse;
650fA              $slwhdpu = *on;
650fA              $slwhdp  = #bwhdp;
650fA              $sldispu = *on;
650fA              $sldisp  = kcdisp;
650fA
650fA              $dricommand = '*SLOT';
650fA              if onDmdCallsonDmd;
650fA                 $drisubcmd  = '%GETODRRPK';
650fA                 $slitemu = *on;
650fA                 $slitem  = kccitm;
650fA              else;
650fA                 $drisubcmd  = '%GET';
650fA              endif;
650fA              $drisys2upd = 'D';
650fA              chk4err = *on;
650fA              zmsflag = *on;
650fA              exsr zzzdricop;
650fA              if drierr;
650fA              endif;
650fA              odrppick = $sldisp;
650fA              if onDmdCallsOnDmd;
650fA                 lstodritm = kccitm;
650fA              endif;
650fA
650fA              select;
650fA              when $slstat = 'A' and not onDmdCallsonDmd;
650fA                 $saactionu = *on;
650fA                 $saAction = ' ';
650fA              other;
650fA                 $saactionu = *on;
650fA                 $saAction  = 'ODR';
650fA              endsl;
650fA
650fA
650fA              savever# = $slver#;
650fA              clear $slot;
650fA              clear $slot2;
650fA              $slver# = savever#;
650fA
650fA              $slwhseu = *on;
650fA              $slwhse  = kcwhse;
650fA              $slwhdpu = *on;
650fA              $slwhdp = #bwhdp;
650fA              $sldispu = *on;
650fA              $sldisp  = odrppick; //pulled from kccitm above
650fA              $saitemu = *on;
650fA              $saitem  = kccitm; //ODR Item
650fA
650fA              exsr rpkqtypar; //determine how many normal qty from odr
650fA              odrMinusq1=0;
650fA              odrMinusq2=0;
650fA              odrMinusq3=0;
650fA              exsr zzupqtyodr; //up the odr quantity required
650fA              if wopqn1=0 and wopqn2=0 and wopqn3=0;
650fA                 odrPlus = 0;
650fA                 iter;
650fA              else;
650fA                 odrPlus = wopqn1;
650fA                 if wopqn2 <> 0 or wopqn3<>0;
650fA                    odrPlus += 1;
650fA                 endif;
650fA              endif;
650fA
650fA  // in select below extend odr quantity needed by what each parent
650fA  // requests from kitcomp to complete each of the requested odr items
650fA              select;
650fA              when savRpkq3(aryCnt)>0;
650fA                 if (odrPlus*kcqty3*kcqty2) < (#bumq3*#bumq2);
650fA             //if quantity moved is less than one full Repack Item
650fA             //then force the minimum of 1 to be issued
650fA                    odrPlus = ((#bumq3*#bumq2)/(odrPlus*kcqty3*kcqty2));
650fA                    $saqty3 = -(#bumq2 * #bumq3);
650fA                    $saqty2 = 0;
650fA                    $saqty1 = 0;
650fA                    odrPlus = %abs($saqty3 / savRpkq3(aryCnt));
650fA                 else;
650fA                    $saqty3 = -(odrPlus * kcqty3 * kcqty2);
650fA                    $saqty2 = 0;
650fA                    $saqty1 = 0;
650fA                 endif;
650fA              when savRpkq2(aryCnt)>0;
650fD    //           if (odrPlus*kcqty2) < (#bumq2);
650fD    //              odrPlus = #bumq2/(odrPlus*kcqty2);
650fD    //              $saqty2 = -(#bumq2);
650fD    //              $saqty1 = 0;
650fD    //              $saqty3 = 0;
650fD    //           else;
650fA                    $saqty2 = -(odrPlus * kcqty2);
650fA                    $saqty1 = 0;
650fA                    $saqty3 = 0;
650fD    //           endif;
650fA              other;
650fA                 $saqty1 = -(odrPlus);
650fA                 $saqty2 = 0;
650fA                 $saqty3 = 0;
650fA              endsl;
650fA
650fA              $saqtyu  = *on;
650fA              $sacwtau = *on;
650fA              $sacwta  = 0;
650fA              $sacodeu = *on;
650fA              $sacode  = 'R1';
650fA              $samemou = *on;
650fA              $samemo  = ' ';
650fA              $sabyu   = *on;
650fA              $saby    = 'RPK';
650fA              $dricommand = '*SLOT';
650fA              $drisubcmd  = '%ADJUSTORD';
650fA              $drisys2upd = 'D';
650fA              aryBck = %subarr(aryRPD:1:%elem(aryRPD));
650fA              exsr zzzdricop;
650fA              aryRPD = %subarr(aryBck:1:%elem(aryBck));
650fA
650fA        enddo;
650fA
650fA    //Make sure the pick slot exist for top level ODR item
650fA
650fA           odritem = kcitem;
650fA           $godrslot = kcdisp;
650fA           exsr crtrpkslt;
650fA
650fA    //Put Quantity on ODR item calling this parent item
650fA
650fA           if odrPlus > 0;
650fA              savever# = $slver#;
650fA              clear $slot;
650fA              clear $slot2;
650fA              $slver# = savever#;
650fA
650fA    //Move fields from record to data structure.
650fA
650fA              $slwhseu = *on;
650fA              $slwhse  = kcwhse;
650fA              $slwhdpu = *on;
650fA              $slwhdp = #bwhdp;
650fA              $sldispu = *on;
650fA              $sldisp  = odrSlot;
650fA              $saitemu = *on;
650fA              $saitem  = kcitem;
650fA              $saqtyu  = *on;
650fA              $saqty1  = odrPlus;
650fA              $saqty2  = 0;
650fA              $saqty3  = 0;
650fA              $sacwtau = *on;
650fA              $sacwta  = 0;
650fA              $sacodeu = *on;
650fA              $sacode  = 'R1';
650fA              $samemou = *on;
650fA              $samemo  = ' ';
650fA
650fA              $sabyu   = *on;
650fA              $saby    = 'RPK';
650fA              $dricommand = '*SLOT';
650fA              $drisubcmd  = '%ADJUST';
650fA              $drisys2upd = 'D';
650fA              aryBck = %subarr(aryRPD:1:%elem(aryRPD));
650fA              exsr zzzdricop;
650fA              aryRPD = %subarr(aryBck:1:%elem(aryBck));
650fA           endif;
650fA
650fA  // if ODR at this level had enough stock to fulfill this order
650fA  //  then exit this routine.  No need to build stock
650fA        if onDmdCallsonDmd;
650fA           frmzzGetCase = *on;
650fA           hld#sitem = #sitem;
650fA           #sitem = lstodritm;
650fA           exsr zzAllocRepack;
650fA           #sitem = hld#sitem;
650fA     // if the sum of available for this item is greater than zero
650fA     // then leave. At this point the negative adjustment has been
650fA     // applied.  Therfore if there is still a positive available
650fA     // or even ZERO there was enough stock to fulfill the order
650fA           if (#odrpckavl + #odrovravl) >= 0;
650fA             leave;
650fA           endif;
650fA        endif;
650fA
650fA        aryCnt += 1;
650fA
650fA       //if item just processed was another ODR being called then save
650fA       //the breakdown quantities to be used in next cycle
650fA        if nxtODR(aryCnt) <> *loval;
650fA           savRpkq2(aryCnt) = #bumq2;
650fA           savRpkq3(aryCnt) = #bumq3;
650fA           odrPreviousQty = odrPlus;
650fA        endif;
650fA
650fA     enddo;
650fA
650fA     odrSlot = odrOrigSlt;
650fA     onDmdcallsonDmd = onDmdHold;
650fA
650fA /end-free
650fAC                   endsr

650qA*----------------------------------------------------------------
650qA*
650qA*  ZZLICENSE   USE DRILICENSE for license
650qA*
650qAC     zzlicense     begsr
650qAC                   eval      error = *off
650qA*  Use DRI interface to get license information.
650qA
650qAC                   exsr      clr$license
650qAC                   eval      $liToWhdpU = *on
650qAC                   eval      $liToWhdp = slwhdp
650qAC                   eval      $liToDispU = *on
650qAC                   eval      $liToDisp = sldisp
650qAC                   eval      $liToDispU = *on
650qAC                   eval      $dricommand = '*LICENSE'
650qAC                   eval      $drisubcmd  = '%GETSLTLIC'
650qAC                   eval      $drisys2upd = 'D'
650qAC                   eval      chk4err = *on
650qAC                   exsr      zzzdricop
650qA
650qAC                   if        error = *on
650qAc                             or $drireturn <> '*OK'
650qAc                             or $liToLcns = '*NONE'
650qAC                   eval      $prtn = '*PGMQ   '
650qAC                   goto      endlic
650qAC                   endif
650qA
650qAC     endlic        endsr
650qA*----------------------------------------------------------------
650qA*
650qA*  ZZLICINFO   get licinfo receiving qty for license
650qA*
650qAC     zzlicinfo     begsr
650qAC                   eval      error = *off
650qA /free
650qA     exsr clr$licinfo;

650qA     $lnwhse  = slwhse;
650qA     $lnlcns  = $litolcns;
650qA     $lnseq = 1;

650qA     $dricommand = '*LICINFO';
650qA     $drisubcmd  = '%GET';
650qA     $drisys2upd = 'D';
650qA     chk4err = *on;
650qA     exsr zzzdricop;

650qA     if error = *on;
650qA       pristine = *off;
650qA       leavesr;
650qA     endif;

650qA     // first lets check the qty being pulled against the rcv qty
650qA     // on the license - if they are different we can't use this
650qA     // for bulk pick
650qA     if $lnrcvqty <> avail1;
650qA       pristine = *off;
650qA       leavesr;
650qA     endif;
650qA     // continue by checking to make sure license has had NO
650qA     // adjustments or selections.
650qA     if not %open(liclog1);
650qA       open liclog1;
650qA     endif;
650qA     setll (lbwhse: $litolcns) liclog1;
650qA     dow not %eof(liclog1);
650qA       reade (lbwhse: $litolcns) liclog1;
650qA       if %eof(liclog1);
650qA         leave;
650qA       else;
650qA         // is log for action ADJ or SEL
650qA         if llaction = 'ADJ';
650qA           close liclog1;
650qA           pristine = *off;
650qA           leavesr;
650qA         endif;
650qA         if llaction = 'SEL';
650qA           close liclog1;
650qA           pristine = *off;
650qA           leavesr;
650qA         endif;
650qA       endif;
650qA     enddo;

650qA     // if we get here then no adj or selection log records for license
650qA     // finally now go see if we have uci records for this license
650qA     // Check to make sure we have the same qty of UCI records
650qA     exsr clr$uciinfo;

650qA     $uiWhse = slwhse;
650qA     $uilcns = $litolcns;

650qA     $dricommand = '*UCIINFO';
650qA     $drisubcmd  = '%CNT4BLK';
650qA     $drisys2upd = 'D';
650qA     exsr zzzdricop;

650qA     // if return is *BULKQTY1 - NO UCI Were Found - so get out
650qA     if $drireturn   = '*BULKQTY1';
650qA       pristine = *off;
650qA       leavesr;
650qA     endif;

650qA     // if return is *BULKCNT  - pmessage holds the uci count
650qA     if $drireturn   = '*BULKCNT';
650qA       // count must be same as qty being pulled
650qA       if avail1 <> %dec($drimessage:5:0);
650qA         pristine = *off;
650qA         leavesr;
650qA       else;
650qA         pristine = *on;
650qA         leavesr;
650qA       endif;
650qA     endif;
650qA /end-free
650qAC     endlicinfo    endsr
650dA*----------------------------------------------------------------
650dA*  ZZUPQTY       Up quantity
650dA*----------------------------------------------------------------
650dA
650dAC     zzupqty       begsr

650dAC                   dow       #bumq3 > 0 and +
650dAC                               wopqn3 >= #bumq3
650dAC                   eval      wopqn3 -= #bumq3
650dAC                   eval      wopqn2 += 1
650dAC                   enddo

650dAC                   dow       #bumq2 > 0 and +
650dAC                               wopqn2 >= #bumq2
650dAC                   eval      wopqn2 -= #bumq2
650dAC                   eval      wopqn1 += 1
650dAC                   enddo

650dAC                   endsr

650dA*----------------------------------------------------------------
650dA*  ZZUPQTYODR    Up quantity
650dA*----------------------------------------------------------------
650dA
650dAC     zzupqtyodr    begsr


650dAC                   dow       savRpkq3(aryCnt) > 0 and +
650dAC                               wopqn3 >= savRpkq3(aryCnt)
650dAC                   eval      wopqn3 -= savRpkq3(aryCnt)
650dAC                   eval      wopqn2 += 1
650dAC                   enddo

650dAC                   dow       savRpkq2(aryCnt) > 0 and +
650dAC                               wopqn2 >= savRpkq2(aryCnt)
650dAC                   eval      wopqn2 -= savRpkq2(aryCnt)
650dAC                   eval      wopqn1 += 1
650dAC                   enddo

650dAC                   endsr

650eA*----------------------------------------------------------------
650eA*  crtprtyrpl  Create priority replenishment for item.
650eA*----------------------------------------------------------------
650eA
650eAC     crtprtyrpl    begsr
650eA
650eA*  Call DRIPRTYRPL for required quantity from overflow on-demand
650eA
650eAC                   exsr      clr$prtyrpl
650eA
650eAC                   eval      $prwhseu = *on
650eAC                   eval      $prwhse  = itwhse
650eA
650eAC                   eval      $pritemu = *on
650eAC                   eval      $pritem  = ititem
650eA
650eAC                   eval      $prwhdpu = *on
650eAC                   eval      $prwhdp  = itwhdp
650eA
650eAC                   eval      $prslotu = *on
650eAC                   eval      $prslot  = odrrpick
650eA
650eAC                   eval      $prqtynu = *on
650eAC                   eval      $prqtyn  = prqtyn
650eA
650eAc                   eval      $dricommand = '*PRTYRPL'
650eAc                   eval      $drisubcmd  = '*CRTRPLODN'
650eAc                   eval      $drisys2upd = 'D'
650eAc                   exsr      zzzdricop
650eAc                   if        error = *on
650eAc                   endif
650eAc                   endsr

610bA*----------------------------------------------------------------
610bA*  crtrpkslt   Create repack slots
610bA*----------------------------------------------------------------

610bAC     crtrpkslt     begsr

720gA *  If Virtual slot sent then get base
720gA /free
720gA          chain ($pWhse:odrBaseWhdp:$gODRSlot) vslot1;
720gA          if %found(vslot1);
720gA             $gODRSlot = v_vspdis;
720gA          endif;
720gA /end-free
     *  Create slot for Repack item.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = odrBaseWhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = odritem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $gODRSlot

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CRTREPAKD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
650mA /free
650mA     //if slot creation error then check to see if already exist
650mA           if drierr;
650mA              if onDmdCallsonDmd;
650mA                 $drisubcmd  = '%GETODRRPK';
650mA              else;
650mA                 $drisubcmd  = '%GET';
650mA              endif;
650mA              exsr zzzdricop;
650mA              if not drierr;
650mA                 odrSlot = $sldisp;
650mA              endif;
650mA           endif;
650mA /end-free
     C                   eval      odrSlot = $sldisp

     C                   eval      #odrslavl1 = $slavl1

     C     endcrtrpkslt  endsr

620dA*----------------------------------------------------------------
620dA*  rpkqty   Fill screen 1 fields with info from file.
620dA*----------------------------------------------------------------
620dA
620dAC     rpkqty        begsr

     *  Get Kit Component information.
650bA*   this information now comes from KIT array

650bDC*    keykc         setll     kitcomp
650bDC*    keykc         reade(e)  kitcomp
620fA
620fA*  Get out if not found
620fA
650bDC*                  if        %eof(kitcomp)
650bDC*                  eval      wopqn1 = 0
650bDC*                  eval      wopqn2 = 0
650bAC*                  eval      wopqn3 = 0
650bAC*                  leavesr
650bAC*                  endif
620fA
620fA*  Protect against negatives.
620fA
650bDC*                  if        kcqty1 < 0
650bDC*                  eval      kcqty1 = 0
650bDC*                  endif
650bDC*                  if        kcqty2 < 0
650bDC*                  eval      kcqty2 = 0
650bDC*                  endif
650bDC*                  if        kcqty3 < 0
650bDC*                  eval      kcqty3 = 0
650bDC*                  endif
650bAC                   if        aepqty1(loop) < 0
650bAC                   eval      aepqty1(loop) = 0
650bAC                   endif
650bAC                   if        aepqty2(loop) < 0
650bAC                   eval      aepqty2(loop) = 0
650bAC                   endif
650bAC                   if        aepqty3(loop) < 0
650bAC                   eval      aepqty3(loop) = 0
650bAC                   endif
620fA
620fA*  Calculate parent qty needed.
620fA
650cAc                   if        aeRQty1(loop) > 1
650fAc                   eval      outPutQty = aeRqty1(loop)
650cAc                   eval      wopqn1 = qtyToMake*aePQty1(loop)
650cAc                   eval      wopqn2 = qtyToMake*aePQty2(loop)
650cAc                   eval      wopqn3 = qtyToMake*aePQty3(loop)
650cAc                   exsr      zzUpqty
650cAc                   exsr      zzadjQty
650cAc                   exsr      zzUpqty
650cAc                   else
650fAc                   eval      outPutQty = 1
650cAC                   eval      wopqn1 = aePqty1(loop) * qtyToMake
650cAC                   eval      wopqn2 = aePqty2(loop) * qtyToMake
650cAC                   eval      wopqn3 = aePqty3(loop) * qtyToMake
650cAc                   endif
650bDC*                  eval      wopqn1 = kcqty1 * qtyToMake
650bDC*                  eval      wopqn2 = kcqty2 * qtyToMake
650bDC*                  eval      wopqn3 = kcqty3 * qtyToMake

     C                   endsr

650fA*----------------------------------------------------------------
650fA*  rpkqtypar   Routine called from within the ODR loop looing
650fA*              for case item quantity
650fA*----------------------------------------------------------------
650fA
650fAC     rpkqtypar     begsr
650fA
650fA*  get base information for new component being called from
650fA*  original item
650fAC                   call      'GETBASE'
650fAC                   parm      itwhse        $gwhse            3 0
650fAC                   parm      kcitem        $gitem           15
650fAC                   parm      kccitm        #bitem
650fAC                   parm      'R'           #bityp            1
650fAC                   parm                    #bdesc           30
650fAC                   parm                    #bpdsc           15
650fAC                   parm                    #bwhdp            5
650fAC                   parm                    #bstyp            1
650fAC                   parm                    #bum              2
650fAC                   parm                    #bum2             2
650fAC                   parm                    #bumq2            3 0
650fAC                   parm                    #bum3             2
650fAC                   parm                    #bumq3            3 0
650fAC                   parm      ' '           #bcitm           15
650fAC                   parm      ' '           #bctyp            1
650fAC                   parm      ' '           #bcdsc           30
650fAC                   parm      ' '           #bcpds           15
650fAC                   parm      ' '           #bcwdp            5
650fAC                   parm      ' '           #bcstp            1
650fAC                   parm      ' '           #bcum             2
650fAC                   parm      ' '           #bcum2            2
650fAC                   parm      0             #bcuq2            3 0
650fAC                   parm      ' '           #bcum3            2
650fAC                   parm      0             #bcuq3            3 0
650fAC                   parm      ' '           #brtn             8
650fA
650fA*  Protect against negatives.
650fA
650fAC                   if        savKitq1(aryCnt) < 0
650fAC                   eval      savKitq1(aryCnt) = 0
650fAC                   endif
650fAC                   if        savKitq2(aryCnt) < 0
650fAC                   eval      savKitq2(aryCnt) = 0
650fAC                   endif
650fAC                   if        savKitq3(aryCnt) < 0
650fAC                   eval      savKitq3(aryCnt) = 0
650fAc                   endif
650fA
650fA*  Calculate parent qty needed.
650fA
650fAc                   if        savOutQty(aryCnt) > 1
650fAc                   eval      outPutQty = savOutQty(aryCnt)
650fAc                   eval      wopqn1 = odrPreviousQty*savKitq1(aryCnt)
650fAc                   eval      wopqn2 = odrPreviousQty*savKitq2(aryCnt)
650fAc                   eval      wopqn3 = odrPreviousQty*savKitq3(aryCnt)
650fAc                   exsr      zzUpqty
650fAc                   exsr      zzadjQty
650fAc                   exsr      zzUpqty
650fAc                   else
650fAc                   eval      outPutQty = 1
650fAC                   eval      wopqn1 = savKitq1(aryCnt) * odrPreviousQty
650fAC                   eval      wopqn2 = savKitq2(aryCnt) * odrPreviousQty
650fAC                   eval      wopqn3 = savKitq3(aryCnt) * odrPreviousQty
650fAc                   endif
650fAc*  remove available quantities from original available
650fAc                   eval      wopqn1 = wopqn1 - odrMinusq1
650fAc                   eval      wopqn2 = wopqn2 - odrMinusq2
650fAc                   eval      wopqn3 = wopqn3 - odrMinusq3
650fA
650fAc                   if        wopqn1 < 0
650fAc                   eval      wopqn1 = 0
650fAc                   endif
650fA
650fAc                   if        wopqn2 < 0
650fAc                   eval      wopqn2 = 0
650fAc                   endif
650fA
650fAc                   if        wopqn3 < 0
650fAc                   eval      wopqn3 = 0
650fAc                   endif
650fA
650fAC                   endsr
650fA
730kA*----------------------------------------------------------------
730kA*  wrtDebug    Write out debug record
730kA*----------------------------------------------------------------
730kA
730kA /free
730kA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
650bA*----------------------------------------------------------------
650bA*     ZZPrcRepack - Process Repack Items
650bA*
650bAC     zzPrcRepack   begsr
650bA /free
650bA    odrBldNeeded = *on;
650bA    FirstRecd = *on;
650bA    // load repack item array
650bA    pitem = ititem;
650bA    pcmd = '*ITEM';
650bA    prtn = ' ';
650bA    callp @usrSpc($pwhse:pitem:pcmd:prtn);
650bA
650bA    // setup look and process the Repack Item as well as parents
650bA    for loop = 1 to %elem(aryRPD);
650bA       if aeritem(loop) > ' ';    // leave loop once you reach end
650bA
650bA /end-free
650bAC                   call      'GETBASE'
650bAC                   parm      itwhse        $gwhse            3 0
650bAC                   parm      ititem        $gitem           15
650bAC                   parm      aepitem(loop) #bitem
650bAC                   parm      'R'           #bityp            1
650bAC                   parm                    #bdesc           30
650bAC                   parm                    #bpdsc           15
650bAC                   parm                    #bwhdp            5
650bAC                   parm                    #bstyp            1
650bAC                   parm                    #bum              2
650bAC                   parm                    #bum2             2
650bAC                   parm                    #bumq2            3 0
650bAC                   parm                    #bum3             2
650bAC                   parm                    #bumq3            3 0
650bAC                   parm      ' '           #bcitm           15
650bAC                   parm      ' '           #bctyp            1
650bAC                   parm      ' '           #bcdsc           30
650bAC                   parm      ' '           #bcpds           15
650bAC                   parm      ' '           #bcwdp            5
650bAC                   parm      ' '           #bcstp            1
650bAC                   parm      ' '           #bcum             2
650bAC                   parm      ' '           #bcum2            2
650bAC                   parm      0             #bcuq2            3 0
650bAC                   parm      ' '           #bcum3            2
650bAC                   parm      0             #bcuq3            3 0
650bAC                   parm      ' '           #brtn             8
650bA /free
650bA          if aeRdisp(loop) <> ' '; //on-demand slot defined
650bA             odritemflag = *on;
650bA             odritem = aeRitem(loop);
650bA             $gODRSlot = aeRdisp(loop);
650bA             odrbaseSlot = aePdisp(loop);
650bA             odrbaseItem = aePitem(loop);
650bA             odrbaseWhdp = #bwhdp;
650mA
650mA   //force KITCOMP repack breakdown on item master if missing
650mA   //these breakdown quantities are used when ODR items call
650mA   //other ODR items
650mA            if #bitem = aepitem(loop)
650mA               and ititem = aeritem(loop);
650mA               select;
650mA                  when itumq2 = 0 and aepQty2(loop) > 0;
650mA                     itumq2 = aepQty2(loop);
650mA                     itum2 = aepum2(loop);
650mA                  when itumq3 = 0 and aepQty3(loop) > 0;
650mA                     itumq3 = aepQty3(loop);
650mA                     itum3 = aepum3(loop);
650mA               endsl;
650mA            endif;
650dA
        //determine if both repack item and parent are on-demand items
650dA
650dA             chain ($pwhse:aeRitem(loop)) kititem;
650dA             if %found;
650dA                if kidisp<>' ' and kirptp='2';
650dA                   onDmdCallsonDmd = *on;
650dA                   chain ($pwhse:aePitem(loop)) kititem;
650dA                   if %found;
650dA                      if kidisp<>' ' and kirptp='2';
650dA                         onDmdCallsonDmd = *on;
650dA                      else;
650dA                         onDmdCallsonDmd = *off;
650dA                      endif;
650dA                   else;
650dA                      onDmdCallsonDmd = *off;
650dA                   endif;
650dA                else;
650dA                   onDmdCallsonDmd = *off;
650dA                endif;
650dA             else;
650dA                onDmdCallsonDmd = *off;
650dA             endif;
650dA             frmzzGetCase = *off;
650eA             exsr zzAllocRepack;
650fA
650fA     //check to make sure original Repack Item did not have stock
650fA     //to fulfill order
650fA             if onDmdCallsonDmd;
650fA                frmzzGetCase = *on;
650fA                hld#sitem = #sitem;
650fA                #sitem = #bitem;
650fA                exsr zzAllocRepack;
650fA                frmzzGetCase = *off;
650fA                #sitem = hld#sitem;
650fA     //if the on-hand for the original repack item equals or exceeds
650fA     //the need then skip looking for case quantity.
650fA                select;
650fA                  when #bumq3 > 0;
650fA                     if (qtyToMake * itumq2 * itumq3) >
650fA                          ((#odriqavl1 * #bumq2 * #bumq3) +
650fA                            (#odriqavl2 * #bumq3) + #odriqavl3);
650fA                        odrMinusq1 = #odriqavl1;  //save avl qtys
650fA                        odrMinusq2 = #odriqavl2;
650fA                        odrMinusq3 = #odriqavl3;
650fA                        exsr zzgetCaseStock;
650fA                     endif;
650fA                  when #bumq2 > 0;
650fA                     if (qtyToMake * itumq2) >
650fA                          ((#odriqavl1 * #bumq2) + #odriqavl2);
650fA                        odrMinusq1 = #odriqavl1;  //save avl qtys
650fA                        odrMinusq2 = #odriqavl2;
650fA                        odrMinusq3 = #odriqavl3;
650fA                        exsr zzgetCaseStock;
650fA                     else;
650fA                        // do nothing.  There is enough stock at the
650fA                        // second level to fulfill order
650fA                     endif;
650fA                  other;
650fA                     if qtyToMake > #odriqavl1;
650fA                        odrMinusq1 = #odriqavl1;  //save avl qtys
650fA                        odrMinusq2 = #odriqavl2;
650fA                        odrMinusq3 = #odriqavl3;
650fA                        exsr zzgetCaseStock;
650fA                     endif;
650fA                endsl;
650fA             endif;
650fA
650fA     //odrBldNeeded is on by default.  It will be turned off if either
650fA     //of the conditions below are met
650fA     //1) Stock is found at the ODR level to fulfill order
650fA     //2) The search through the ODR chain locates parent stock to
650fA     //   fulfill order
650fA
650fA             if odrBldNeeded;
650fA                odritem = aeRitem(loop);
650fA                $godrslot = aeRdisp(loop);
650bA                exsr zzCRTOdrQty;
650fA             endif;
650fA
650bA             FirstRecd = *off;
650bA          endif;
650bA       else;
650bA          leave;
650bA       endif;
650bA    endfor;
650fA /end-free
650bAc                   endsr
650fA
413aA*----------------------------------------------------------------
413aA*     ZZTRCK - Write tracking records to tracking file
413aA*
413aAC     zztrck        begsr
413aAC                   select
413aAC                   when      trcode = '*PCK001 '
413aAC                   eval      trpcmd = $pcmd
413aAC                   eval      trprg = $pprg
413aAC                   eval      trpbat = $pbat
413aAC                   eval      trrord = $pord
413aAC                   eval      trotyp = $potyp
413aAC                   eval      trrtid = $prtid
413aAC                   select
413aAC                   when      trerr = *off
413aAC                   eval      trpkst = tr80
413aAC                   when      trerr = *on
413aAC                   eval      trpkst = tr81
413aAC                   endsl
413aAC                   eval      trflpk = flgpck
413aAC                   eval      trfltk = flgtrk
413aAC                   eval      trdata = tr01ds
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr01rec
413aA*
413aAC                   when      trcode = '*PCK002 '
413aAC                   if        flgpck = *on
413aAC                   eval      trdata = trerfl
413aAC                   else
413aAC                   eval      trdata = opdata
413aAC                   endif
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr02rec
413aA*
413aAC                   when      trcode = '*PCK003 '
413aAC                   if        flgpck = *on
413aAC                   eval      trdata = trerfl
413aAC                   else
413aAC                   eval      trrows = throws
413aAC                   eval      trcols = thcols
413aAC                   eval      trbulk = thbulk
413aAC                   eval      trbat = thbat
413aAC                   eval      trdata = tr03ds
413aAC                   endif
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr03rec
413aA*
413aAC                   when      trcode = '*PCK010 '
413aAC                   add       1             trsq10
413aAC                   movel     opzzon        trzone
413aAC                   eval      trdt10 = opzdta
413aAC                   eval      trdata = tr10ds
413aAC                   eval      trsqnr = trsq10
413aAC                   write     tr10rec
413aA*
413aAC                   when      trcode = '*PCK040 '
413aAC                   add       1             r
413aA*    Array is full, add to file and then reset array.
413aAC                   if        r > 25
413aAC                   add       1             trsq40
413aAC                   eval      trsqnr = trsq40
413aAC                   eval      trdata = tr40ds
413aAC                   write     tr40rec
413aAC                   eval      trrfld = *blanks
413aAC                   eval      r = 1
413aAC                   endif
413aAC                   eval      trr(r) = trsubr
413aA*
413aAC                   when      trcode = '*PCK050 '
413aA*R                   MOVE *ON       TRERR
413aAC                   add       1             trsq50
413aAC                   eval      trord = ohord
413aAC                   eval      trstop = ohstop
413aAC                   eval      tritem = oditem
413aAC                   eval      trmsgt = 'S'
413aA*
413aAC                   select
413aAC                   when      trnbr = 'TR01'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(1)
413aAC     trdt50        cat       tr05:2        trdt50
413aAC                   eval      $ccmd = '*QTY2STR'
413aAC                   eval      $cqty1 = odqor1
413aAC                   eval      $cqty2 = odqor2
413aAC                   eval      $cqty3 = odqor3
413aAC                   eval      $cqstr = *blanks
413aAC                   exsr      zzcvqy
413aAC     trdt50        cat       $cqstr:1      trdt50
413aA*
413aAC                   when      trnbr = 'TR03'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(3)
413aAC     trdt50        cat       tr05:2        trdt50
413aAC     trdt50        cat       p1qord:0      trdt50
413aAC     trdt50        cat       tr06:2        trdt50
413aAC     trdt50        cat       p1qalc:0      trdt50
413aAC     trdt50        cat       tr07:2        trdt50
413aAC     trdt50        cat       p1qpck:0      trdt50
413aA*
413aAC                   when      trnbr = 'TR04'
413aAC                   eval      trerr = *on
413aAC                   eval      trdt50 = msg(4)
413aAC     trdt50        cat       tr05:2        trdt50
413aAC     trdt50        cat       p1qord:0      trdt50
413aAC     trdt50        cat       tr06:2        trdt50
413aAC     trdt50        cat       p1qalc:0      trdt50
413aAC     trdt50        cat       tr07:2        trdt50
413aAC     trdt50        cat       p1qpck:0      trdt50
413aA*
413aAC                   when      trnbr = 'TR09'
700iAC                   if        hasCustDays
413aAC                   eval      trdt50 = %trimr(tr09c) + ' ' + sldisp
700iAC                   else
413aAC                   eval      trdt50 = %trimr(tr09) + ' ' + sldisp
700iAC                   endif
413aAC     trdt50        cat       tr08:2        trdt50
413aAC                   move      slexpd        cvt8a
413aAC     trdt50        cat       cvt8a:0       trdt50
700iAC     trdt50        cat       tr08c:2       trdt50
700iAC                   move      expDate       cvt8a
700iAC     trdt50        cat       cvt8a:0       trdt50
700iAC                   if        hasCustDays
700iAC                   move      ceddays       cvt5a
700iAC     trdt50        cat       tr08d:2       trdt50
700iAC     trdt50        cat       cvt5a:0       trdt50
700iAC                   endif
413aA*
413aAC                   when      trnbr = 'TR10'
413aAC                   eval      trdt50 = %trimr(tr10) + ' ' + sldisp
413aA*
413aAC                   when      trnbr = 'TR11'
413aAC                   eval      trdt50 = %trimr(tr11) + ' ' + sldisp
413aA*
413aAC                   when      trnbr = 'TR12'
413aAC                   eval      trord = *zeros
413aAC                   eval      trstop = *zeros
413aAC                   eval      tritem = *blanks
413aAC                   eval      trdt50 = tr12
413aA*
413aAC                   when      trnbr = 'TR13'
413aAC                   eval      trord = *zeros
413aAC                   eval      trstop = *zeros
413aAC                   eval      tritem = *blanks
413aAC                   eval      trdt50 = tr13
413aA*
413aAC                   when      trnbr = 'TR14'
413aAC                   eval      trdt50 = tr14
413aA*
413aAC                   when      trnbr = 'TR15'
413aAC                   eval      trdt50 = tr15
413aAC                   move      leftq1        cvt5a
413aAC     trdt50        cat       cvt5a:0       trdt50
413aA*
413aAC                   when      trnbr = 'TR16'
413aAC                   eval      trdt50 = %trimr(tr16) + sldisp
413aAC     trdt50        cat       tr23:1        trdt50
413aA*
413aAC                   when      trnbr = 'TR17'
413aAC                   eval      trdt50 = %trimr(tr17) + ' ' + sldisp
413aAC     trdt50        cat(p)    tr21:2        trdt50
413aAC                   move      avail1        cvt5a
413aAC     trdt50        cat       cvt5a:0       trdt50
413aA*
413aAC                   when      trnbr = 'TR18'
413aAC                   eval      trdt50 = %trimr(tr18) + ' ' + sldisp
413aAC     trdt50        cat(p)    tr22:2        trdt50
413aAC                   move      pickq1        cvt5a
413aAC     trdt50        cat       cvt5a:0       trdt50
413aA*
413aAC                   when      trnbr = 'TR19'
413aAC                   eval      trdt50 = tr19
413aA*
413aAC                   when      trnbr = 'TR20'
413aAC                   eval      trdt50 = %trimr(tr20) + trkey
413aAC                   eval      trmsgt = 'D'
413aA*
413aAC                   select
413aAC                   when      trkey = 'KEYSL3'
413aAC     trdt50        cat       'Stat:':1     trdt50
413aAC     trdt50        cat       kystat:1      trdt50
413aAC     trdt50        cat       'Pick:':1     trdt50
413aAC     trdt50        cat       kypick:1      trdt50
413aA*
413aAC                   when      trkey = 'KEYS3B'
413aAC     trdt50        cat       'Stat:':1     trdt50
413aAC     trdt50        cat       kystat:1      trdt50
413aAC     trdt50        cat       'Pick:':1     trdt50
413aAC     trdt50        cat       kypick:1      trdt50
413aAC     trdt50        cat       'Prty:':1     trdt50
413aAC                   move      kyprty        cvt1a
413aAC     trdt50        cat       cvt1a:1       trdt50
413aAC     trdt50        cat       'Expd:':1     trdt50
413aAC                   move      kyexpd        cvt8a
413aAC     trdt50        cat       cvt8a:0       trdt50
413aAC     trdt50        cat       'Entd:':1     trdt50
413aAC                   move      kyentd        cvt8a
413aAC     trdt50        cat       cvt8a:0       trdt50
413aA*
413aAC                   endsl
413aA*
413aAC                   endsl
413aAC                   eval      trdata = tr50ds
413aAC                   eval      trmsgn = trnbr
413aAC                   eval      trsqnr = trsq50
413aAC                   write     tr50rec
413aA*
413aAC                   endsl
413aAC                   endsr
413aA*----------------------------------------------------------------
413aA*     ZZCVQY - Convert receive qty's to string for msg display
413aA*
413aAC     zzcvqy        begsr
413aAC                   call      'CVTQTY'
413aAC                   parm                    $ccmd
413aAC                   parm                    $cprg
413aAC                   parm                    $cqty1
413aAC                   parm                    $cqty2
413aAC                   parm                    $cqty3
413aAC                   parm                    $cum1
413aAC                   parm                    $cum2
413aAC                   parm                    $cum3
413aAC                   parm                    $cqstr
413aAC                   parm                    $custr
413aAC                   parm                    $crtn
413aAC                   parm                    $cerm
413aAC                   endsr
640eA*----------------------------------------------------------------
     *
640eA*  ZZGETL   Get slot license
     *
640eAC     zzgetL        begsr
     *
640eAC                   exsr      clr$slot
640eAC                   eval      $slwhseu = *on
640eAC                   eval      $slwhse  = slwhse
640eAC                   eval      $slwhdpu = *on
640eAC                   eval      $slwhdp  = slwhdp
640eAC                   eval      $sldispu = *on
640eAC                   eval      $sldisp  = sldisp
640eA
640eAC                   eval      $dricommand = '*SLOT'
640eAC                   eval      $drisubcmd  = '%GET'
640eAC                   eval      $drisys2upd = 'D'
640eAC                   exsr      zzzdricop
640eAC                   if        error = *on
640eAC                   eval      error = *off
640eAC                   eval      $saToPos = 0
640eAC                   endif
     *
640eAC                   eval      lcns = $saToLcns
     *
640eAC                   endsr
     *
650bA*----------------------------------------------------------------
650bA*     ZZUserSpace - Maintain User Space for Repack Item Array
650bA*
650bAC     zzUserSpace   begsr
650bA*
650bA*  ensure user space exists for Repack KIT array

650bA /free
650bA    //  make calls to ensure user space setup for Repack Item Ary
650bA    RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD: Qusec);
650bA    if qusbavl>0;     // object not found
650bA       pitem = ' ';
650bA       pcmd = '*SETUP';
650bA       prtn = ' ';
650bA       callp @usrSpc($pwhse:pitem:pcmd:prtn);
650bA    endif;
650bA    RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD : Qusec);
650bA /end-free
650bAc                   endsr
     *
650bA*----------------------------------------------------------------
650bA*     ZZDltUsrSp - Remove User Space for Repack Item Array
650bA*
650bAC     zzDltUsrSpc   begsr
650bA*

650bA /free
650bA    //  make calls to remove user space setup for Repack Item Ary
650bA    pitem = ' ';
650bA    pcmd = '*DELETE';
650bA    prtn = ' ';
650bA    callp @usrSpc($pwhse:pitem:pcmd:prtn);
650bA /end-free
650bAc                   endsr
     *
650bA*----------------------------------------------------------------
414cA*  ZZXOPT   Get use extended description option
     *
414cAC     zzxopt        begsr
     *
414cA*   Get extended description option.
414cAC                   eval      uxflag = *off
414cAC                   eval      ocode = '*ITEMMNT'
     *
414cAC     opkey         chain     options                            79
414cAC                   if        not *in79
414cAC                   move      opdata        opdta2
414cAC                   if        opxdsc = 'Y'
414cAC                   eval      uxflag = *on
414cAC                   endif
414cAC                   endif
     *
414cAC                   if        uxflag = *on
414cAC     idkey         chain     itemdsc                            79
414cAC                   if        *in79
414cAC                   eval      ixdsc1 = *blanks
414cAC                   eval      ixdsc2 = *blanks
414cAC                   endif
414cAC                   endif
414cAC                   endsr

610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------
610bA*                     DRI SUBROUTINES
610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------

650dA*----------------------------------------------------------------
650dA*  clr$prtyrpl  Clear $prtyrpl data structure fields
650dA*----------------------------------------------------------------
650dA
650dAC     clr$prtyrpl   begsr
650dAC                   eval      savever# = $prver#
650dAC                   clear                   $prtyrpl
650dAC                   eval      $prver# = savever#
650dAC                   endsr

     *----------------------------------------------------------------
     *  clr$itemqty  Clear $itemqty data structure fields
     *----------------------------------------------------------------

     C     clr$itemqty   begsr
     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#
     C                   endsr

650qA*----------------------------------------------------------------
650qA*  clr$item  Clear $item data structure fields
650qA*----------------------------------------------------------------

650qAC     clr$item      begsr
650qAC                   eval      savever# = $itver#
650qAC                   clear                   $item
650qAC                   clear                   $item2
650qAC                   eval      $itver# = savever#
650qAC                   endsr

650qA*----------------------------------------------------------------
650qA*  clr$license  Clear $license data structure fields
650qA*----------------------------------------------------------------

650qAC     clr$license   begsr
650qAC                   eval      savever# = $liver#
650qAC                   clear                   $license
650qAC                   eval      $liver# = savever#
650qAC                   eval      $liemp# = 0
650qAC                   eval      $liuser = #user
650qAC                   eval      $lipgm  = #prog
650qAC                   eval      $lijob  = #job
650qAC                   eval      $lijobn = #jobn
650qAC                   eval      $liTowhse = $whse
650qaC                   eval      $liTowhseu = *on
650qAC                   endsr

650qA*----------------------------------------------------------------
650qA*  clr$licinfo  Clear $licinfo data structure fields
650qA*----------------------------------------------------------------

650qAC     clr$licinfo   begsr
650qAC                   eval      savever# = $lnver#
650qAC                   clear                   $licinfo
650qAC                   clear                   $licinfo2
650qAC                   eval      $lnver# = savever#

650qAC                   eval      $lnuser = #user
650qAC                   eval      $lnemp# = 0
650qAC                   eval      $lnpgm  = #prog
650qAC                   eval      $lnjob  = #job
650qAC                   eval      $lnjobnbr = #jobn

650qAC                   endsr

610bA*----------------------------------------------------------------
610bA*  clr$slot  Clear $slot data structure fields
610bA*----------------------------------------------------------------

610bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

650qA*----------------------------------------------------------------
650qA*  clr$uciinfo  Clear $uciinfo data structure fields
650qA*----------------------------------------------------------------

650qAC     clr$uciinfo   begsr
650qAC                   eval      savever# = $uiver#
650qAC                   clear                   $uciinfo
650qAC                   eval      $uiver# = savever#
650qAC                   eval      $uiaddemp = 0
650qAC                   eval      $uiaddusr = #user
650qAC                   eval      $uiaddpgm  = #prog
650qAC                   eval      $uiaddjob  = #job
650qAC                   eval      $uiaddnbr = #jobn
650qAC                   endsr

610bA*----------------------------------------------------------------
610bA*  zzzdriclose   Close any open files or programs.
610bA*----------------------------------------------------------------

610bAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEMQTY'
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
700hA
700hAC                   eval      $dricommand = '*XDOCK'
700hAC                   eval      $drisubcmd  = '%CLOSE'
700hAC                   eval      $drisys2upd = 'D'
700hAC                   eval      chk4err = *off
700hAC                   eval      zmsflag = *off
700hAC                   exsr      zzzdricop

     C                   endsr

610bA*----------------------------------------------------------------
610bA*  zzzdricop  Call DRICOP
610bA*----------------------------------------------------------------

610bAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
700hAC                   when      $dricommand = '*XDOCK'
700hAC                   eval      $dridata = $xdock
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $dridata = $itemqty
650dAC                   when      $dricommand = '*PRTYRPL'
650dAC                   eval      $dridata = $prtyrpl
650nAC                   when      $dricommand = '*PROD'
650nAC                   eval      $dridata = $pprod
650nAC                   eval      $dridata2 = $pprod2
720aAC                   when      $dricommand = '*ZONED'
720aAC                   eval      $dridata = $zoned
650qAC                   when      $dricommand = '*LICENSE'
650qAC                   eval      $dridata = $license
650qAC                   when      $dricommand = '*LICINFO'
650qAC                   eval      $dridata = $licinfo
650qAC                   eval      $dridata2 = $licinfo2
650qAC                   when      $dricommand = '*UCIINFO'
650qAC                   eval      $dridata = $uciinfo
650qAC                   when      $dricommand = '*ITEM'
650qAC                   eval      $dridata = $item
650qAC                   eval      $dridata2 = $item2
     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
650qAC                             or $dricommand = '*LICINFO'
650qAC                             or $dricommand = '*ITEM'
650nAC                             or $dricommand = '*PROD'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endsl

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
700hAC                   when      $dricommand = '*XDOCK'
700hAC                   eval      $xdock = $dridata
720aAC                   when      $dricommand = '*ZONED'
720aAC                   eval      $zoned = $dridata
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $itemqty = $dridata
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
650qAC                   when      $dricommand = '*LICENSE'
650qAC                   eval      $license = $dridata
650qAC                   when      $dricommand = '*LICINFO'
650qAC                   eval      $licinfo = $dridata
650qAC                   eval      $licinfo2 = $dridata2
650qAC                   when      $dricommand = '*UCIINFO'
650qAC                   eval      $uciinfo = $dridata
650qAC                   when      $dricommand = '*ITEM'
650qAC                   eval      $item = $dridata
650qAC                   eval      $item2 = $dridata2
650nAC                   when      $dricommand = '*PROD'
650nAC                   eval      $pprod = $dridata
730cAC                   eval      $pprod2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

730hA *----------------------------------------------------------------
730hA *  chkZstat  -   Zero Verify any Drop Pick status virtuals
730hA *----------------------------------------------------------------
730hA
730hA /free
730hA  begsr chkZstat;
730hA
730hA    // build sql to retrieve any left behind "Z" status
730hA    // Drop Pick slots
730hA
730hA    SqlStmt = 'select * from slot where  ' +
730hA               'slwhse=' + %char($pWhse) + ' and ' +
730hA               'slstat=' + sq + 'Z' + sq + ' and sldesg=' +
730hA               sq + '*DROP' + sq;
730hA
730hA    exec sql Prepare Selzs from :Sqlstmt;
730hA    exec sql Declare Slotz scroll cursor for selzs;
730hA    exec sql Open Slotz;
730hA    exec sql Fetch first from Slotz into :slrecdd;
730hA
730hA    if Sqlstt = sqlsuccess;
730hA       dow Sqlstt = sqlsuccess;
730hA          exsr clr$slot;
730hA          $slver# = savever#;
730hA
730hA          $slwhseu = *on;
730hA          $slwhse  = s_slwhse;
730hA
730hA          $slaislu = *on;
730hA          $slaisl  = s_slaisl;
730hA
730hA          $slwhdpu = *on;
730hA          $slwhdp = s_slwhdp;
730hA
730hA          $sldispu = *on;
730hA          $sldisp = %trim(s_sldisp);
730hA
730hA          $saitemu = *on;
730hA          $saitem  = s_slitem;
730hA
730hA          $sabyu   = *on;
730hA          $saby    = #user;
730hA
730hA          $saemp#u = *on;
730hA          $saemp# = #emp#;
730hA          $saToAreaU = *on;
730hA          $saToArea = 'Slot';
730hA
730hA          $dricommand = '*SLOT';
730hA          $drisubcmd  = '%ZEROVFY';
730hA          $drisys2upd = 'D';
730hA          exsr zzzDriCop;
730hA          exec sql Fetch next from Slotz into :slrecdd;
730hA       enddo;
730hA    endif;
730hA    exec sql Close Slotz;
730hA
730hA  endsr;
730hA
730hA /end-free
730hA
730hA*----------------------------------------------------------------
730hA*  drpPck   Determine if item is Drop Pick Item
730hA*----------------------------------------------------------------
730hA
730hAC     drpPck        begsr
730hA
730hA /free
750eA     dpck=*off;
750fA     if ohtype <> ' ';
750fA       // do not allocate to drop pick slots for Will Call orders
750fA       leavesr;
750fA     endif;
750eA     cmpItem = oditem;
750eA     exec sql  select count(*)
750eA                 into :sltcnt
750eA               from slot
750eA           where slwhse=:odwhse and slitem=:oditem and slstat='DP'
750eA             and sldesg='*DROP' and slwhdp=:itwhdp;
750eA     if sqlstt='00000' and sltcnt>0;
750eA       dpck=*on;
750eA       leavesr;
750eA     endif;
740hA     if itdesg<>*blanks and itdesg<>'*DROP';
740hA       // Drop Pick not allowed if item has
740hA       // Designation code
740hA       dpck = *off;
740hA       if odspcl='DP';
740hA         odspcl=*blanks;
740hA       endif;
740hA       leavesr;
740hA     endif;
730hA     cmpItem=oditem;
730hA     //  If Contract, Alias or SSB item
730hA     //   Then get Base Slot item.
730hA     //
730hA     if ittype = 'A'  or
730hA        ittype = 'C'  or
730hA        ittype = 'S';
730hA /end-free
730hAc                   call      'GETSLOTITM'
730hAc                   parm                    odwhse
730hAc                   parm                    oditem
730hAc                   parm      ' '           #sitem           15
730hAc                   parm                    #sityp            1
730hAc                   parm                    #sdesc           30
730hAc                   parm                    #spdsc           15
730hAc                   parm                    #srtn            10
730hAc                   parm                    #smsg            60
730hA /free
730hA                    // use base item if found
730hA                      if #srtn='*OK';
730hA                        cmpItem = #sitem;
730hA                      endif;
730hA                    endif;
750eD      // cmpItem=#sitem;
730hA      // Ensure item has no pick slot
730hA      pckcnt=0;
730hA      exec sql select count(*)
730hA                into :pckcnt
730hA               from slot
730hA             where slwhse=:odwhse and slitem=:cmpItem
730hA               and slpick='Y' and slstat<>'Z ' and slwhdp=:itwhdp;
730hA      if pckcnt>0;
730hA        // if pick slot is found set dpck to
730hA        // false meaning it is not a Drop Pick
730hA        dpck = *off;
730hA        leavesr;
730hA      endif;
730hA
730hA      // Ensure slots exist with *DROP designation.
730hA      // If none exist return false meaning not a drop pick
730hA      sltcnt=0;
730hA      exec sql select count(*)
730hA                into :sltcnt
730hA               from slot
740 D             //where slwhse=:odwhse and slstat='A '
740 M             where slwhse=:odwhse and slstat='DP'
730hA               and sldesg='*DROP' and slwhdp=:itwhdp;
730hA      if sqlStt <> '00000' or sltcnt=0;
730hA        // if read fails or no *DROP slots found then return
730hA        // false meaning it is not a Drop Pick
730hA        dpck = *off;
730hA        leavesr;
730hA      endif;
730hA
750cA      // Ensure at least one overflow slot exists with available qty
750cA      newQty1=0;
750cA      newQty2=0;
750cA      newQty3=0;
750cA      setll (odwhse:oditem:'A') slot3;
750cA      dow forever = forever;
750cA         reade (odwhse:oditem:'A') slot3;
750cA         if %eof(slot3) or not %equal(slot3);
750cA           // since nothing ever found we should leave without turning on dpck
750cA           leave;
750cA         endif;
750cA
750cA         // ignore special need slots
750cA         if sldesg = 'BFC';
750cA            iter;
750cA         endif;
750cA
750cA         // if expiration date passed ignore
750cA         if slexpd <> 0 and slexpd < expDate and itflgd = 'Y';
750cA            iter;
750cA         endif;
750cA
750cA         // check to see if this slot has available quantity
750cA         // compared to uom availibility.  It will create the
750cA         // drop pick if any availibility exists for the specific
750cA         // uom ordered
750cA         exsr avail;
750cA         if (odqor1>0 and avail1>0) or
750cA            (odqor2>0 and (avail2>0 or avail1>0)) or
750cA            (odqor3>0 and (avail3>0 or avail2>0 or avail1>0));
750cA           // keep track of available
750cA           newqty1=newqty1+avail1;
750cA           newqty2=newqty2+avail2;
750cA           newqty3=newqty3+avail3;
750cA         else;
750cA           // otherwise it reads next of slot
750cA           iter;
750cA         endif;
750cA
750cA         // turn on Drop Pick indicator to process as a Drop Pick
750cA        dpck = *on;
750cA
750cA       enddo;
750cA
730hA      // Since *DROP slots exist and no pick slot exist
730hA      // for item then this is a Drop Pick item
750cD      //dpck = *on;
750cA      // Set left quantities to match available when
750cA      // available is less than quantity ordered
750cA      // and determined to be a drop pick item
750cA       // Normal Quantity
750cA       if dpck;
750cA         if odqor1>0;
750cA           if newqty1<leftq1;
750cA             leftq1=newQty1;
750cA           endif;
750cA         endif;
750cA         // Bredakdown Qty 1
750cA         if odqor2>0;
750cA           if ((newqty1*itumq2)+newQty2) <
750cA              ((leftq1*itumq2)+leftq2);
750cA             leftq2=((newqty1*itumq2)+newQty2);
750cA           endif;
750cA         endif;
750cA         // Bredakdown Qty 2
750cA         if odqor3>0;
750cA           if ((newQty1*itumq2*itumq3)+(newQty2*itumq3)+newQty3) <
750cA              ((leftq1*itumq2*itumq3)+(leftq2*itumq3)+leftq3);
750cA             leftq3=((newQty1*itumq2*itumq3)+(newQty2*itumq3)+newQty3);
750cA           endif;
750cA         endif;
750cA       endif;
730hA
730hA /end-free
730hAC                   endsr
730hA
730hA*----------------------------------------------------------------
730hA*  ddJitReplen  -  Generate JIT Replenishments for Drop Pick
730hA*----------------------------------------------------------------
730hA
730hAC     ddJitReplen   begsr
730hA /free
730hA     loop=1;
730hA     dow loop < 3;
730hA       generateddrpl=*off;
730hA       // Create Priority Replenishment for Drop Pick
730hA       exsr clr$prtyrpl;
730hA
730hA       $prwhseu = *on;
730hA       $prwhse  = odwhse;
730hA
730hA       $pritemu = *on;
730hA       $pritem  = cmpItem;
730hA
730hA       $prwhdpu = *on;
730hA       $prwhdp  = itwhdp;
730hA
730hA       if loop=1 and leftq1>0;
730hA          $prqtynu = *on;
730hA          $prqtyn  = leftq1;
730hA          generateddrpl=*on;
730hA       endif;
730hA
730hA       if loop=2 and (leftq2>0 or leftq3>0);
730hA          generateddrpl=*on;
730hA          $prqtywu = *on;
730hA          $prqtyw  = leftq2;
730hA          if leftq3>0 and itumq3>0;
730hA            // only replenishes to breakdown 1.  If breakdown 2
730hA            // was sent we will roll to breakdown 1 and replen
730hA            // mininum of 1 breakdown 1 if partial two was sent
730hA            $prqtyw  = $prqtyw + %div(leftq3:itumq3);
730hA            if %rem(leftq3:itumq3) > 0;
730hA               $prqtyw  = $prqtyw + 1;
730hA            endif;
730hA          endif;
730hA       endif;
730aA
730hA       $prslotu = *on;
730hA       // logic in DRIPRTYRPL will determine if slot is assigned
730hA       // and will place there.  If no slot is assigned yet the
730hA       // PRPLFIL records will be added with PRTDIS *DDSLOT
730hA       // which will tell LT107 the user MUST supply the *DROP
730hA       // slot to be used for todays picks
730hA       $prslot  = '*DDSLOT';
730hA
730hA       $prfill  = 'D';         // Drop Pick
730hA
730hA       $dricommand = '*PRTYRPL';
730hA       $drisubcmd  = '*CRTDDRPL';
730hA
730hA       $drisys2upd = 'D';
730hA       if generateddrpl;
730hA         exsr zzzdricop;
730hA       endif;
730hA       loop = loop + 1;
730hA     enddo;
730hA
730hA /end-free
730hAc                   endsr

750bAC*----------------------------------------------------------------
750bZC*  KeepOrSub -  Determine if use original item or substitute
750bAC*----------------------------------------------------------------

750bAp KeepOrSub       b

     * Local Files

     Fslot3     if   e           k disk
     Fpiritem   if   e           k disk

     d KeepOrSub       pi              n
750bAd  iRtid                              like(ohrte)
750bAd  iOrd                               like(ohord)
750bAd  iItem                              like(oditem)
750bAd  iSeq                               like(odseq)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)

     * Local File Data Structures

     d rsl             ds                  likerec(slrec: *input)
     d rit             ds                  likerec(itrec: *input)

     * Local Variables

     d  avl1           s              5  0 inz(0)
     d  avl2           s              5  0 inz(0)
     d  avl3           s              5  0 inz(0)
     d  wkItem         s             15
     d  savItem        s             15
     d  nxtSeq         s              3p 0
     d  wkCust         s             11  0
     d  rtnSub         s             15
     d  wkAutoSub      s              1
     d  wkSubSeq       s              5  0
     d  wkMSg          s             99

      /free

       savItem = iItem;
       wkItem = *blanks;
       subItem = *blanks;
       nxtSeq = 0;

       // Get next order detail sequence to use
       exec sql select max(odseq) into :wkSubSeq from ordd
             where odwhse=:odwhse and odord=:iOrd;
       if sqlstt='00000';
         wkSubSeq = wkSubSeq + 1;
       else;
         wkSubSeq = 1;
       endif;

       // loop original item and sub items if necessary to find available inventory
       dow forever = forever;

         if wkitem = *blanks;
           // when blanks we are checking original ordered item for stock
           wkitem = iItem;
         else;
           // when wkitem has value we should read next sub with sequence
           // greater than the nxtSeq field that starts at 0
           exWhse = odwhse;
           wkCust = *zeros;
           wkAutoSub = 'Y';
           rtnSub = *blanks;
           exitemsub ('*GETSEQ':exRtnCode:exRtnMsg:exWhse:savItem:wkCust:
                                rtnSub:wkAutoSub:nxtSeq);
           if exRtnCode <> '*OK';
             // do not write itemsublog record since one is written on a
             // positive or negative situation below.  This simply means
             // no subs are deined.
             return *off;
           else;
             wkItem = rtnSub;
             subItem = rtnSub;
           endif;
         endif;

         // Read through active slots and determine availability for selected item
         setll ($pWhse: wkItem: 'A') slot3;
         chain ($pWhse:wkItem) piritem rit;
         if %eof(piritem);
           // return existing item since it was not found
           iter;
         endif;

         avl1=0;
         avl2=0;
         avl3=0;

         dow forever = forever;

           reade ($pWhse: wkItem: 'A') slot3 rsl;

           if %eof(slot3);
             leave;
           endif;

           // ignore BFC special slots
           if rsl.sldesg = 'BFC';
             iter;
           endif;

           // get availibility
           avl1 = avl1 + (rsl.slstk1+rsl.slrcv1) -
                  (rsl.sltfr1+rsl.slrcv1) - rsl.slalc1;
           avl2 = avl2 + (rsl.slstk2+rsl.slrcv2) -
                  (rsl.sltfr2+rsl.slpck2) - rsl.slalc2;
           avl3 = avl3 + (rsl.slstk3+rsl.slrcv3) -
                  (rsl.sltfr3+rsl.slpck3) - rsl.slalc3;

           // confirm not expired if set
           if rit.itflgd = 'Y';
             if rsl.slexpd>0 and rsl.slexpd <=
                     %dec(%char(%date():*ymd0):6:0);
               iter;
             endif;

           endif;
         enddo;
         // confirm enough stock to handle order
         select;
           when rit.itumq3 > 0;
             if ((iQty1*rit.itumq2*rit.itumq3) +
                 (iQty2*rit.itumq3) + iQty3) >=
                ((avl1*rit.itumq2*rit.itumq3)  +
                 (avl2*rit.itumq3)  + avl3);
               // when order quantity is greater than available loop for next item/sub
               if wkitem<>iitem;
                 // Write not available message to log for this sub
                 wkMsg = 'Available inventory is short of ordered quantity';
                 wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
               endif;
               iter;
             else;
               if wkItem = iItem;
                 // when enough stock and this matches orders item then return to use ordered
                 return *off;
               else;
                 // when auto sub item and enough stock then generate sub and return to use sub
                 wkMsg= crtAutoSub(iOrd:iItem:iSeq:iQty1:iQty2:iQty3:wkItem
                                   :wkSubSeq);
                 if wkMsg = *blanks;
                   wkmsg = 'sub item ' + %trim(iItem) + ' for item '
                                        + %trim(wkItem);
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   return *on;
                 else;
                   // reset order detail key since sub failed and write log entry
                   // with failure
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   setll ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   reade ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   iter;
                 endif;
               endif;
             ENDIF;
           when rit.itumq2 > 0;
             if ((iQty1*rit.itumq2) + iQty2) >= ((avl1*rit.itumq2) + avl2);
               // when order quantity is greater than available loop for next item/sub
               if wkitem<>iitem;
                 // Write not available message to log for this sub
                 wkMsg = 'Available inventory is short of ordered quantity';
                 wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
               endif;
               iter;
             else;
               if wkItem = iItem;
                 // when enough stock and this matches orders item then return to use ordered
                 return *off;
               else;
                 // when auto sub item and enough stock then generate sub and return to use sub
                 wkMsg= crtAutoSub(iOrd:iItem:iSeq:iQty1:iQty2:iQty3:wkItem
                                   :wkSubSeq);
                 if wkMsg = *blanks;
                   wkmsg = 'sub item ' + %trim(iItem) + ' for item '
                                        + %trim(wkItem);
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   return *on;
                 else;
                   // reset order detail key since sub failed and write log entry
                   // with failure
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   setll ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   reade ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   iter;
                 endif;
               endif;
             ENDIF;
           other;
             if iQty1 >= avl1;
               // when order quantity is greater than available loop for next item/sub
               if wkitem<>iitem;
                 // Write not available message to log for this sub
                 wkMsg = 'Available inventory is short of ordered quantity';
                 wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
               endif;
               iter;
             else;
               if wkItem = iItem;
                 // when enough stock and this matches orders item then return to use ordered
                 return *off;
               else;
                 // when auto sub item and enough stock then generate sub and return to use sub
                 wkMsg= crtAutoSub(iOrd:iItem:iSeq:iQty1:iQty2:iQty3:wkItem
                                   :wkSubSeq);
                 if wkMsg = *blanks;
                   wkmsg = 'sub item ' + %trim(iItem) + ' for item '
                                        + %trim(wkItem);
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   return *on;
                 else;
                   // reset order detail key since sub failed and write log entry
                   // with failure
                   wrtSubLog(wkItem:wkAutoSub:wkSubSeq:iQty1:iQty2:iQty3:wkMsg);
                   setll ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   reade ($pWhse:ohord:kyopen:iSeq:iItem) ordd1;
                   iter;
                 endif;
               endif;
             endif;
         endsl;
       enddo;


      /end-free

750bAp                 e

750bAC*----------------------------------------------------------------
750bZC*  crtAutoSub - Create Auto Sub
750bAC*----------------------------------------------------------------

750bAp crtAutoSub      b

     d crtAutoSub      pi            99
750bAd  iOrd                               like(ohord)
750bAd  iItem                              like(oditem)
750bAd  iSeq                               like(odseq)
750bAd  iQty1                              like(odqor1)
750bAd  iQty2                              like(odqor2)
750bAd  iQty3                              like(odqor3)
     d  isubitem                     15
     d  isubseq                            like(odseq)

     c                   unlock    ordd1
     c                   call      'RTESUB'
     c                   parm      *blanks       perrmsg          99
     c                   parm                    pSessId
     c                   parm                    #user
     c                   parm      #prog         dictpgm          20
     c                   parm                    odwhse
     c                   parm                    odord
     c                   parm                    odseq
     c                   parm                    oditem
     c                   parm                    iSubItem
     c                   parm                    iSubSeq
     c                   parm                    iQty1
     c                   parm                    iQty2
     c                   parm                    iQty3
     c                   parm      *blanks       pSubSlot         12
     c                   parm      *zeros        pSubPltId         7 0
     c                   parm      *blanks       pSubDev          10

      /free
                         return pErrMsg;
      /end-free

750bAp                 e


750bAC*----------------------------------------------------------------
750bZC*  wrtSubLog - Write item sub log entry
750bAC*----------------------------------------------------------------

750bAp wrtSubLog       b

     d wrtSubLog       pi
750bAd  iSubItem                     15
750bAd  iAs                           1
750bAd  iSubSeq                       5  0
750bAd  iQty1                         5  0
750bAd  iQty2                         5  0
750bAd  iQty3                         5  0
     d  iActMsg                      99

     * Local Variables

     D ts              S               Z

      /free
              ts=%timestamp();
              // insert log entry for Auto Substitutions
              exec sql insert into itemsublog
              values(:odwhse,:ohrte,:odord,:odseq,:oditem,
                     :ohcord,:iSubItem,:iAs,:iSubSeq,:iQty1,
                     :iQty2,:iQty3,:iActMsg,:ts,:#user);
      /end-free

750bAp                 e

750eAC*----------------------------------------------------------------
750eAC*  maxCubeQty  - Calculate Max cube quantity for slot
750eAC*                Used only in PICKDD (Drop Pick)
750eAC*----------------------------------------------------------------

750eAp maxCubeQty      b

     * Local Files

     Fvslot2    if   e           k disk
     Fslot2     if   e           k disk
     Fpiritem   if   e           k disk
     Fslotdef   if   e           k disk

750eAd maxCubeQty      pi              n
750eAd  iWhse                              like(slwhse)
750eAd  iWhdp                              like(slwhdp)
750eAd  iDisp                        12
750eAd  iItem                        15
750eAd  iQty1                         5  0
750bAd  iQty2                         5  0
750bAd  iQty3                         5  0

     * Local File Data Structures

     d vsl             ds                  likerec(vsrec: *input)
     d slt             ds                  likerec(slrec: *input)
     d itm             ds                  likerec(itrec: *input)
     d stp             ds                  likerec(sdrec: *input)

     * Local Variables

     D first           S               n
     D mxcubeqty       S               n
     d sltCubeFt       s             10  3 inz(0)
     D totCbe          S             10  3 inz(0)

      /free

           // Loop through all drop pick virtuals to calculate
           // current cube to determine if this new order will fit
           first = *on;
           totcbe=0;
           setll (iWhse:iWhdp:iDisp) vslot2;
           reade (iWhse:iWhdp:iDisp) vslot2 vsl;

           // Reads first slot to determine which route to process based
           // on whether virtuals exist or not.  If no virtuals we still
           // need to process to calculate current item needs to understand
           // if it will fit in this slot or not

           select;
             when not %eof(vslot2);
               setll (iWhse:iWhdp:iDisp) vslot2;
               dow forever = forever;
                 reade (iWhse:iWhdp:iDisp) vslot2 vsl;
                 if %eof(vslot2);
                   leave;
                 endif;

                 // read each slot2 for quantities
                 chain (vsl.vswhse:vsl.vswhdp:vsl.vsdisp) slot2 slt;
                 if slt.slstat='DP';
                   // on first slot calculator slot type cube
                   if first;
                     chain (slt.slwhse:slt.slsdef) slotdef stp;
                     if %found(slotdef) and (stp.sdlen*stp.sdwdth*stp.sdhgt)<>0;
                       sltCubeFt = (stp.sdlen*stp.sdwdth*stp.sdhgt) / 1728;
                     else;
                       // do not retrict Cube if Slot Def not setup
                       mxCubeQty = *off;
                       return mxCubeQty;
                     endif;
                     first=*off;
                   endif;
                   // accumulate item cube for every virtual under this base
                   chain (slt.slwhse:slt.slitem) piritem itm;
                   if not %found(piritem);
                     itm.itcube=0;
                   endif;
                   select;
                     when slt.slstk1 >= (slt.slalc1+slt.slpck1)
                                          and slt.slstk1<>0;
                       totCbe = totCbe + (slt.slstk1*itm.itcube);
                     other;
                       totCbe = totCbe + ((slt.slalc1+slt.slpck1)*itm.itcube);
                   endsl;
                   if itm.itumq2<>0;
                     select;
                       when slt.slstk2 >= (slt.slalc2+slt.slpck2)
                                          and slt.slstk2<>0;
                         totCbe = totCbe + (slt.slstk2*(itm.itcube/itm.itumq2));
                       other;
                         totCbe = totCbe + ((slt.slalc2+slt.slpck2)
                                          *(itm.itcube/itm.itumq2));
                     endsl;
                   endif;
                   if itm.itumq3<>0;
                     select;
                       when slt.slstk3 >= (slt.slalc3+slt.slpck3)
                                          and slt.slstk3<>0;
                         totCbe = totCbe + (slt.slstk3*(itm.itcube/itm.itumq3));
                       other;
                        totCbe = totCbe + ((slt.slalc3+slt.slpck3)
                                          *(itm.itcube/itm.itumq3));
                     endsl;
                   endif;
                 endif;
               enddo;
               // accumulate item cube for this one order
               chain (iWhse:iItem) piritem itm;
               if not %found(piritem);
                 itm.itcube=0;
               endif;
               totCbe = totCbe + (iQty1*itm.itcube);
               if itm.itumq2<>0;
                 totCbe = totCbe + (iQty2*(itm.itcube/itm.itumq2));
               endif;
               if itm.itumq3<>0;
                 totCbe = totCbe + (iQty3*(itm.itcube/itm.itumq3));
               endif;

             when %eof(vslot2);
               // since no virtuals exist we will read the base slot to get
               // the total cube to compare against this one order
               chain (iWhse:iWhdp:iDisp) slot2 slt;
               if slt.slstat='DP';
                 chain (slt.slwhse:slt.slsdef) slotdef stp;
                 if %found(slotdef) and (stp.sdlen*stp.sdwdth*stp.sdhgt)<>0;
                   sltCubeFt = (stp.sdlen*stp.sdwdth*stp.sdhgt) / 1728;
                 else;
                   // do not retrict Cube if Slot Def not setup
                   mxCubeQty = *off;
                   return mxCubeQty;
                 endif;
                 // accumulate item cube for this one order
                 chain (iWhse:iItem) piritem itm;
                 if not %found(piritem);
                   itm.itcube=0;
                 endif;
                 totCbe = totCbe + (iQty1*itm.itcube);
                 if itm.itumq2<>0;
                   totCbe = totCbe + (iQty2*(itm.itcube/itm.itumq2));
                 endif;
                 if itm.itumq3<>0;
                   totCbe = totCbe + (iQty3*(itm.itcube/itm.itumq3));
                 endif;
               endif;
             endsl;

           if totCbe > sltCubeFt;
             mxCubeQty = *on;
             return mxCubeQty;
           else;
             mxCubeQty = *off;
             return mxCubeQty;
           endif;

      /end-free

750eAp                 e
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   Error messages
Item master record not on file.
First item after restarting batch.
Not enough stock available for order.
Slots did not contain enough stock.
No picking slot defined for item.
Not enough stock for order, dated item.
XDK slot created for Alloc Ovr=Y item.
**   OVRPRTF statment
OVRPRTF FILE(OR610PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
