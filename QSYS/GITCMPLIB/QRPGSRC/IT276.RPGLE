      /copy *libl/qcopysrc,hspecs
501jAH dftactgrp(*NO) actgrp(*NEW)
500kA*----------------------------------------------------------------
500kA*  Multilingual Verision
500kA*  Every screen and message has a corresponding Spanish version.
500kA*  Any changes must be made to both languages.
500kA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT276   RF- slot replenishments - VM   8 X 40
     *  18 June, 1999
     *  Roxanne Harrison
     *  Created using IT271 full screen.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
AFI  *    09/21/97  DAS  AFI
     *      - Made sure slot record was being unlocked.
     *
AFI  *    09/21/97  DAS  AFI
     *      - Not allowed to select slot if available qty is = 0.
     *
406  *    09/24/97  DAS  4.06
     *      - Revised to display pick slot record in the list.
408 A*    01/23/98  RH   4.08
    A*      - Revised to update pick slot entered and expiration dates
     *        with dates from 'From' slot.
409 A*    06/29/98  RH   4.09
    A*      - Revised to verify zero slots, added SC3 Verify Zero Slot
     *        Currently all qty in the slot is taken, so SC3 is
     *        displayed each time.  Future update - add screen with
     *        qty defaulted to slot qty and allow it to be changed.
     *        Add $RZERO verify zero slot parm and pass back to IT270.
    A*      - Revised to work with virtual slots.
409A *    07/06/98  RH      4.09
     *      - Can't verify slot if it has virtual slots tied to it.
     *        Don't display SC3.
410 A*      - Revised to start an Idle task, when repl. task is
     *        ended. ZZTASK, ZZCKU2, ZZTIME AND ZM72 routines added.
411  *    07/02/99  RH
     *      - Revised to replenish entered quantity, change SC3 to SC4
412  *    07/15/99  RH  V4.12
     *      - Revised screens from 8 lines to 3.
     *
412  *    09/15/99  DAS  4.12
     *      - Revised ZZSTRT to change 'Z' or 'V' status of the
     *        'To' slot to 'A'.
     *
413 A*    02/14/00  HNK  4.13
     *      - Revised to ignore Idle task in ZZCKU2 routine.
     *        Only indirect task used to subtract overlapping task.
     *
414aA*    08/03/00  MLB  4.14a
     *      - Revised to allow pgm to create transaction after just
     *        scanning the selected slot. This will only be allowed
     *        with program LT105.  All others, pgm will function as
     *        originally designed.
414bA*    08/08/00  MLB  4.14b
     *      - Revised arrays ZOPT, OPTLN to add new option 1=Select.
     *      - Revised OPTNS2 to add call to new routine ZZSLCT to
     *        process new option.
414cA*    08/28/00  MLB  4.14c
     *      - Revised the program to add row/column positioning to
     *        the program whenever user scans a slot.
414dA*    08/28/00  MLB  4.14d
     *      - Revised the program to not allow pick slots to be selected
     *        as a pull from slot.
414eA*    10/12/00  MLB  4.14e
     *      - Revised the program to only allow user to use 1=Select on
     *        one subfile entry.
     *
415aA*    05/03/01  MLB  4.15a
     *      - Revised program to not update SLEXPD and SLENTD when
     *        the calling program is LT105. LT105 is performing
     *        the date updates.
415bA*    06/12/01  MLB  4.15b
     *      - Revised routines ZZFGTN,ZZFGTP to not include virtual
     *        slots that are at "Z" status.
     *
416 A*    10/15/01  MLB  4.16
     *      - Revised SAVOPT to remove clear of OPTCNT.  Clear of
     *        OPTCNT added to CLRSCH.
416aA*    12/06/01  MLB  4.16a
     *      - Added file PIRTRAN1.
     *      - Revised ZZTASK to first look at PIRTRAN1 for a status
     *        '2' record. This will save reading through every record
     *        for the employee.
416bA*    12/19/01  MLB  4.16b
     *      - Added files ITMEXCP, OPTIONS.
     *      - Added OPTIONS DS *REPLEN.
     *      - Revised program to test whether user can select
     *        expired items for replenishement.
     *      - Revised program to test whether user can select
     *        items for replenishement out of FIFO order.
416cA*    12/28/01  MLB  4.16c
     *      - Revised program allow user to log exception for
     *        an overflow slot by typing a X in the option field
     *        and pressing Enter.
416dA*    01/17/02  MLB  4.16d
     *      - Added test for expired product to make sure that the
     *        slot expiration date is greater than zero.
416eA*    02/01/02  MLB  4.16e
     *      - Added f8 to call license plate info program.
     *      - Revised CMD01 to add call to LP120CL.
     *      - Revised CMDLN arrary to add F8=Lic inf cmd text.
416fA*    02/07/02  MLB  4.16f
     *      - Revised ZZEXCP to use SLWHDP instead of $PWHDP.
     *
416gA*    02/19/02  DAS  4.16g
     *      - Revised to work with DRISLOT interface.
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZD2S, ZZZCOP, ZZZISF, ZZZFS2, ZZZFS3
     *
416hA*    06/12/02  DAS  4.16h
     *      - Changed field A$LIC# from 7.0 to 15.
416iA*    09/26/02  MLB  4.16i
     *      - Enh: Added new routine ZZEXSL to write record to slot
     *        exception file.
     *      - Rename SLTRPEX fields to use 'SX'.
     *        Re: $SLOT data structure already using 'SE' prefix.
416jA*    12/06/02  MLB  4.16j
     *     - Enh: Program will capture date/time on entry. This will be
     *       passed to ADDSTDTRN2. This will enable the Specific Slot
     *       transaction to more accurately reflect the time the user
     *       started the transaction.
416kA*    12/04/02  MLB  4.16k
     *      - Enh: Revised ZZFGTN,ZZFGTP to omit all slots that are
     *        not at active status.
     *
417 A*    02/13/03  MLB  4.17
     *      - Fix: Revised ZZSTRT to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
417aA*    04/14/03  MLB  4.17a
     *      - Enh: Added support to allow display of overflow locations
     *        to be limited to one at a time.
417bA*    05/15/03  MLB  4.17b
     *      - Enh: Added 16-line support to program.
417cA*    05/15/03  MLB  4.17c
     *      - Enh: Added lot/license plate tracking support to program.
417dA*    04/05/04  MLB  4.17d
     *      - Enh: Revised program to add support for creating re-
     *        plenishments for breakdown items.
     *      - Added file ITEMLNK.
417eA*    09/08/04  DAS  4.17e
     *      - Fix: Needed to initialize KYITEM in ZZINZ2 because of
     *        417d change.
     *
500 A*    03/15/05  MLB  5.00
     *      - Enh: Revised program to add support tracking slot outs.
     *        Added F10=Out to allow user to flag an item that doesn't
     *        have any available overflow slots to replenish the pick
     *        slot.
     *      - Revised text for array CMDLN to combine F3/F12 together
     *        and F10=Out added.
     *      - File SLOTOUT added.
     *      - Added new entry to array DESC.
500aA*    08/05/05  MLB  5.00a
     *      - Enh: Change to 5.00 mod. Removed file SLOTOUT from program.
     *        Processing added to pgm RU380.
     *      - Removed requirement to compile pgm with CVTOPT(*DATETIME).
     *        Note at top of program has been deleted.
500bA*    12/14/05  Rh   5.00b
     *      - Fix: Clear CURTRN field, was updating old leftover transam.
500cA*    01/10/06  RH   5.00c
     *      - Enh: Add Parms for start date/time to be sent for LT105
500dA*    04/14/06  MLB  5.00d
     *      - Fix: Revised ENT01 to call routine ZZVSLT when a
     *        slot is scanned to find virtual slot for base slot.
     *
500eA*    05/29/06  JCJ  5.00e
     *      - Added Multilingual logic.
510aA*    08/09/06  RH   5.10a
     *      - Fix: Revised ZZSTRT to update SLOTDTE like LT105
510bA*    06/28/07  RBD  5.10B
     *      - Fix: Revised ZZEXCP to update exfdis (exception from
     *        slot) with virtual slot is one exists.
510cA*    08/30/07  JCJ  5.10c
     *      - Enh: Converted to RPG4.
     *      - Enh: Revised program to add support for Client id
510dA*    10/31/07  LMC  5.10d
     *      - Enh: Added additional code for 16 x 20 screens
510eA*    12/07/07  RH   5.10e
     *      - Enh: Return transfered item in $PITEM field.
520aA*    09/10/08  RH   5.20a
     *      - Fix: Reverse 510a change, was updating SLOTDTE with
     *        pulled qty, not just replenished qty and date.
530 A*    10/28/09  MLB/RH  5.30
     *      - Fix: Revised ENT01 routine to setoff FVSLOT and clear
     *        HLDVSLT for when slot is not entered manually by the
     *        user. Was causing invalid data to be loaded into the
     *        ITMEXCP file for FIFO rotation errors.
530aA*    10/28/09  MLB     5.30a NOT needed in V6.10
     *
600aA*    01/28/09  DAS  6.00a  P#00045
     *      - Incorporated changes from Jordano's version.
     *      - Deleted screens 2 - 4 because they weren't used.
     *      - Physically deleted old and unused code for readability.
     *      - Switched to using DRI programs.
     *
600bA*    01/30/09  DAS  6.00b
     *      - Addded WORKUSR file.
     *      - Changed how parms are sent in.
     *
600cA*    02/24/09  DAS  6.00c
     *      - Revised to call zzckrt for High and Medium tracked
     *        items instead of for expiration date items.
     *      - Revised zzckrt routine to use DRISLOT.
     *
600dA*    03/03/09  DAS  6.00d
     *      - Added wuPulBase to WORKUSR file.
     *      - Added $slPullLcns, $saPullDisp, $saPullBase to c#slot.
     *
600eA*    03/07/09  DAS  6.00e
     *      - Revised to not display RCV, STG, OSS or USR slots.
     *      - Revised to not display 'Z' status slots.
     *
600fA*    05/14/09  DAS  6.00f
     *      - Revised zzstrt to call LT210 with PUTTRAN.
     *
600gA*    06/10/09  DAS  6.00g
     *      - Revised to use %GETCHKVX instead of %GETCHKV. %GETCHKVX
     *        will not count the slot that was sent.
     *      - Revised to write $saFrmEmpty to workusr file after
     *        %TFR2USR. Value to be used in zzaskzrovy in LT105.
     *
600hA*    06/29/09  DAS  6.00h
     *      - Revised zzstrt to not call LT210 or DRISLOT for
     *        breakdown replenishment.
     *      - Revised zzwrtwrkusr to initialize certain fields for
     *        breakdown replenishment.
610aA*    08/27/09  RH   6.10a
     *      - Enh: Rename screen format to IT27601
     *      - Enh: Change Y,N to output field WOYN to display Y,N or
     *        1,9 for Saval.
610bA*    09/09/09  DAS  6.10b
     *      - Fix: Revised zzCHK1 to get first fifo slot containing
     *        item for base slot that was entered.
610cA*    10/16/09  DAS  6.10c
     *      - Fix: Revised ZZGETFROMSLV to use #homitmitem (parent
     *        item) when working with a breakdown item.
610dA*    12/03/09  MLB  6.10d
     *      - Fix: Revised to not allow user to enter slots that have
     *        SLDESG = BFC. Error message IT27101 is issued.
610eA*    07/26/10  MLB  6.10e
     *      - Fix: Revised routines ZZGETFROMIT, ZZGETPICKIT to set
     *        off ZMSFLAG.  Any error messages should be displayed
     *        in IT276.
     *
610fA*    08/03/10  DAS  6.10f
     *      - Added phrase logging.
     *
610gA*    09/01/10  JCJ  6.10g
     *      - Changed to allow specific slot replenishment from a slot
     *        with an item type of ' '.
     *
610hA*    11/04/10  DAS  6.10h
     *      - Format change to IT27602.
     *      - Added second view to all subfiles that includes license.
     *        It is controled by F9.
     *      - Changed command lines from ...
     *           CMDLN:
     *           F10=Out F11=Tfr F3/F12=Exit F8=Lic inf
     *           CMDCW:
     *           F10=Out F11=Tfr F3/F12=Exit F5=Refresh F8=Lic
     *           CMDLSP:
     *           F3/F12=Salir F5=Refrescar F8=Info de licencia F10=Vacio
     *
     *         To ...
     *           CMDLN:
     *           F10=Out F11=Tfr F9=View F8=Lic inf F3/F12=Exit
     *           CMDCW:
     *           F10=Out F11=Tfr F9=View F5=Refresh F8=Lic F3/F12=Exit
     *           CMDLSP:
     *           F3/F12=Salir F5=Refrescar F8=Info de licencia F10=Vacio F9=Vie
     *
640aA*    04/11/11  DAS  6.40a
     *      - Fix: Revised zzstrt to set lbitem to 'To' item.
640bA*    03/30/12  RH   6.40b
     *      - Enh: Default view=2 to display license # by default.
640cA*    08/02/12  LMC  6.40C
     *      - Fix: Frm Slot was not being written to ITMEXCP if the
     *        base slot was scanned, only if the slot was selected
     *        from the subfile list.
640dA*    08/30/12  LMC  6.40d
     *      - Fix: Frm Slot was being populated with pick slot when
     *        user placed an 'X' on the subfile to log a slot error.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised zzexcp to check if frm$slot.$slstk1 > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
     *
650aA*    05/01/13  MLB  6.50a
     *      - Fix: Format change to IT27603.
     *      - Revised program to seton *in81 when 1 or more subfile
     *        records to display.
     *
650bA*    08/01/13  KDE  6.50b
     *      - Enh: Now called from LT107 for user to override from
     *        slot for Repack Replenishments.  Also overriding qty
     *        instead of performing full slot move
     *
700 A*    05/04/17  JGD  7.00
     *      - Add select option 'S=Stuck Plt' to be logged as
     *        a replenishment exception and used later for reporting.
     *        Source copied from PIRMODS700.
700aA*    08/14/15  RH   7.00a
     *      - Enh: F10 OUT will create a replenishment exception.
700bA*    10/09/15  RH   7.00b
     *      - Fix: Count save WRKOPT to limit # of options selected to
     *        one.  Pgm loads one page of records at a time and was
     *        allowing more than one rec selected after page donw.
700cA*    05/03/16  DLS  7.00c
     *      - Fix: Added edit to prevent specific slot replenishments
     *             from same slot.
700dA*    06/27/16  LMC  7.00d
     *      - Reserved - UCI Tracking - New Item tracking level 'U'
710a *    02/10/17  GJA  7.10a
     *      - Fix:  change license process was not working correctly
     *              coming from IT276
710b *    03/01/17  LMC  7.10b
     *      - Fix:  Added to not display RTN to the list of slots to
     *        not display.  Previously these slots were non displayed.
     *        Revised to not display RCV, STG, OSS or USR slots.
     *
720a *    02/27/18  LMC  7.20a
     *      - Enh:  Sending in display if license was scanned from
     *        LT105. This feature is being added to accomodate new
     *        client MARQUES, and the replenishing of the store.
     *        If the display is being sent in from LT105, we will not
     *        display the subfile to allow the user to scan or pick
     *        the from slot. Since we already know the from slot from
     *        the license they are working on.
     *      - Also if the user cancels on the license confirmation
     *        from LT210. We will clear the $ilcnsdisp that was sent
     *        in and the user will be displayed the subfile for them
     *        to choose the slot.
     *
720b *    03/05/18  KDE  7.20b
     *      - Enh:  When replenishing Pick Slot at Store only show
     *        slots at the store, nothing from the Warehouse.  We will
     *        also submit to DRIPRTYRPL for automated Replenishment
     *
720c *    05/18/18  KDE  7.20c
     *      *** NOTE DO NOT TAKE without MODS 720d and 720g
     *      - Enh:  Allow user to scan either Slot or License on location
     *        entry screen.  Originally coded for Colony (Pizza Boxes)
     *      - Fix:  Bypass Virtual search of oldest license when a
     *        license is scanned
     *      - Fix:  When selecting a overflow with option 1 force that
     *        slot display on w1scan as well as w1disp
720d *    07/16/18  RH   7.20d
     *      - Fix:  If license scanned instead of slot, verify license
     *        item is replenishment item.
     *
720e *    08/29/18  KDE  7.20e
     *      - Enh:  Ignore FIFO when Store Staging Replenishment
720fA*    06/27/16  LMC  7.20f
     *      - UCI Tracking - New Item tracking level 'U'
720g *    12/13/18  LMC  7.20g
     *      - Fix:  720d would not allow case item to be scanned for
     *        breakdown replenishment.
     *
730a *    09/24/19  LMC  7.30a
     *      - Enh:  Added to not display RWO to the list of slots to
     *        not display.  Previously these slots were non displayed.
     *        Revised to not display RCV, STG, OSS or USR slots.
730bA*    11/15/19  MLB  7.30b
     *      - Enh: Revised IT27605 to add CHECK(ER) to W1SCAN on SCANREC.
     *      - Enh: Rename screen format to IT27605.
     *
740 A*    02/25/20  MLB  7.40
     *      - Fix: Revised pgm to allow opt# 9=View slot qty on pick
     *        slot. Was issuing erroneous error msg, Replenish from same
     *        slot not allowed.
740aA*    12/29/20  LMC  7.40a
     *      - Enh: Revised program to treat any license being pulled for
     *        replenishments as a partial if there is any inventory in
     *        the breakdown fields. We were orphaning breakdown qty in
     *        the slot with no license. Replenishments only move qty
     *        in the normal unit of measure.
750aA*    05/05/21  RH   7.50a
     *      - Fix: Add code to redisplay slot from APICVTSLT for      or
     *        double scan.  Fix cursor position                       or
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYL A*    08/30/07  JCJ  RYL
     *      - Add slot check to see if taken out of FIFO date rotation
     *----------------------------------------------------------------
     * City Line Distributors Custom Mod
     *
CLDaA*    02/07/13  LMC  CLDa
     *      - Revised W1lcns to only contain last 3 characters of license.
     *        Re: User manually entering license for High tracked items.
CLDbA*    02/18/13  LMC  CLDb
     *      - Revised W1lcns to display seven dashes instead of last 3
     *        positions of the license.
CLDcA*    09/19/13  RH   CLDd
     *      - Revised to default to view 1 to reverse 640b mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CWa A*    12/11/07  LMC  CWa
     *      - Display command keys in a different order
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
GFCa *    02/22/11  GJA  GFCa
     *      - Enh:  Default overflow selection
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
SVLaA*    08/27/09  RH   SVLa
     *      - Revised to use 1,9 in place of Y,N choice.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    10/12/09  MLB  FRF
     *      - Add slot check to see if taken out of FIFO date rotation
     *        Add FRF to RYL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
SFGaA*    02/08/13  LMC  SFGa
     *      - Revised to use the CLDa modification logic showing      nse.
     *        last 3 positions of the license on high tracked item    s.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
CSPaA*    02/08/13  LMC  CSPa
     *      - Revised to use the CLDa modification logic showing      nse.
     *        last 3 positions of the license on high tracked item    s.
     *----------------------------------------------------------------
     *  Client Custom Revisions: WestSide Foods
WSTa *    08/06/15  GJA  WSTa
     *      - Revised to use the CLDa modification logic showing
     *        last 3 positions of the license on high tracked item
416 A*----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Bros.
     *
CBI A*    02/15/17  TAB  CBI
     *      - Check for non-date sensitive item, and don't force override
     *        window, so item exception record will not be written.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
417dA*  64        Reverse image breakdown text on SCANREC.
416iA*  76        Error indicator on write to SLTRPEX.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  Binding Directories
600bA*----------------------------------------------------------------
600bA
600bAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

610aDF*t276fm   cf   e             workstn
610hDF*it27601   cf   e             workstn
650aDF*t27602   cf   e             workstn
720cDF*t27603   cf   e             workstn
730bDF*it27604   cf   e             workstn
730bMFit27605   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
610hAF                                     sfile(dspsfl2:recno)
     F                                     sfile(d16sfl:recno)
610hAF                                     sfile(d16sfl2:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     F                                     sfile(dspsflsp:recno)
610hAF                                     sfile(dspsflsp2:recno)
     F                                     sfile(d16sflsp:recno)
610hAF                                     sfile(d16sflsp2:recno)
     Fworkopt   uf a e           k disk
416bAFitmexcp   uf a e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
720cAFslot2     if   e           k disk    prefix(ss_)
720cAF                                     rename(slrec:slrec2)
RYLbDF*lot10    if   e           k disk    rename(slrec:slrec10)
410 MFLabel     uf a e           k disk
     Fbatctl    o    e           k disk
416bAFoptions   if   e           k disk
720cAflicactive if   e           k disk
510cMFsltrpex   uf a e           k disk    Prefix(x)
600bAFworkusr3  uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
CWa AD cmdcw           s             79    dim(1) ctdata perrcd(1)
500 D*                   DESC    1   5 40
700cDD*desc            s             40    dim(6) ctdata perrcd(1)
700cAD desc            s             40    dim(7) ctdata perrcd(1)
500eAD optlsp          s             75    dim(1) ctdata perrcd(1)
500eAD cmdlsp          s             79    dim(1) ctdata perrcd(1)
700cDD*descsp          s             40    dim(6) ctdata perrcd(1)
700cAD descsp          s             40    dim(7) ctdata perrcd(1)
510cA*----------------------------------------------------------------
510cA*  Customer id
510cA*----------------------------------------------------------------
     D @getcl          c                   const('GETCLIENT')

510cA /COPY QCOPYSRC,ID#ROYAL
CWa A /COPY QCOPYSRC,ID#CITYWHO
SVLaA /COPY QCOPYSRC,ID#SAVAL
GFCaA /COPY QCOPYSRC,ID#GLAZIER
FRF A /COPY QCOPYSRC,ID#FRF
CLDaA /copy qcopysrc,id#citylin
SFGaA /copy qcopysrc,id#sgc
CSPaA /copy qcopysrc,id#coastal
WSTaA /copy qcopysrc,id#westsid
CBI A /copy qcopysrc,ID#CHENEY

500dA*----------------------------------------------------------------
500dA*  DRI parameters
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#ITEM
500dA /COPY *libl/qcopysrc,C#SLOT
720bA /COPY *libl/qcopysrc,C#ZONED
500dA /COPY *libl/qcopysrc,C#SLOTDEF
500dAD saveVer#        s                   like($slver#)
500dAD save$slot       s                   like($slot)

600bAD frm$Slot        ds                  likeds($slot)
600bAD frm$Slot2       ds                  likeds($slot2)

600bA*----------------------------------------------------------------
600bA* Function prototypes.
600bA*----------------------------------------------------------------
600bA
600bA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
600bDD**$whse                  1      3  0
600bDD**$itemds                4     18
600bDD**$home                 19     30
600bDD**$disp                 31     42
600bDD**$lbl#                 43     49  0
600bDD**$trn#                 50     56  0
600bDD**$bat#                 57     63  0
600bDD**$prg                  64     73
600bDD**$pllp#                74     88

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  slstat                19     20
     D  slpick                21     21
     D  slprty                22     22  0 inz(0)
     D  slexpd                23     30  0 inz(0)
     D  slentd                31     38  0 inz(0)
     D  slwhdp                39     43
     D  slstyp                44     44
     D  slaisl                45     47
     D  slpseq                48     52  0 inz(0)
     D  slrlvl                53     54  0 inz(0)
     D  slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('NONE')
     D @vewpg          c                   const('NONE')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
     D @addtr          c                   const('ADDSTDTRN')
     D @addt2          c                   const('ADDSTDTRN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @sltdt          c                   const('UPDSLTDTE')
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
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
417cA*----------------------------------------------------------------
417cA*  Called program parameters
417cA*
417cAD $lparm          ds
417cAD  $lcmd                  1      8
417cAD  $lprg                  9     18
417cAD  $luky                 19     68
417cAD  $lrtn                 69     76
417cAD  $lerm                 77    136
417cAD  $lmsg                 77     80
417cA*
417cA*   Redefine key
417cA*
417cAD  $lwhse                19     21  0
417cAD  $litem                22     36
417cA*
417cAD  $llot                 37     37
417cAD  $lltrk                38     38
500 A*
500 AD  $lwhdp                22     26
500 AD  $ldisp                27     38
500aAD  $litm2                39     53
417cA*
510eAD  $ldsp2                54     65
416bA*----------------------------------------------------------------
416bA*  *REPLEN  -  Replenishment options.
416bA*----------------------------------------------------------------
416bA*
416bA* Fields
416bA*
416bA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY)
416bA*    OPOQRP  -  Order qty replenishment (Y/N).
416bA*    OPRPEX  -  Allow replenishment on expired items.
416bA*               1=Allow, 2=Don't allow, 3=Warn
416bA*    OPRPFI  -  Allow replenishments out of FIFO order.
416bA*               1=Allow, 3=Warn
417aA*    OPLMTS  -  Limit Specific Slot replenishment program to
417aA*               to display only one overflow location at a
417aA*               time. (Y/N)
720bA*    OPSSLCN -  Initiate Specific Slot by License.  In this program
720bA*               this is used to trigger the fact this customer uses
720bA*               a remote location such as a company Store and
720bA*               therefore checks to see if pick slot scanned lives
720bA*               in the store or the warehouse
416bA*
416bA* Data structure
416bA*
416bAD opdata          ds
416bAD  oprplb                 1      8
416bAD  opoqrp                 9      9
416bAD  oprpex                10     10
416bAD  oprpfi                11     11
417aAD  oplmts                12     12
720bAD  opsslcn               29     29
416bAD  optend               117    117
416bA*
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
416bA*----------------------------------------------------------------
416bA*  Replenishment error messages(s).
416bA*
     D msg101          c                   const('Slot no es dispon ')
     D msg102          c                   const('para reaprovisiona')
     D msg103          c                   const('Expiro :')
     D msg104          c                   const('Intente slot nuev ')
416bA*
     D msg201          c                   const('Slot tiene prdcto ')
     D msg202          c                   const('expirado.')
416bA*
     D msg301          c                   const('Slot seleccionado')
     D msg302          c                   const('en orden incrrcto')
510cA*
510cAD msg101e         c                   const('Slot not available')
510cAD msg102e         c                   const('para reaprovisiona')
510cAD msg103e         c                   const('Expired:')
510cAD msg104e         c                   const('Try a different slot')
510cA*
510cAD msg201e         c                   const('Slot has item     ')
510cAD msg202e         c                   const('expired. ')
510cA*
510cAD msg301e         c                   const('Slot selected in ')
510cAD msg302e         c                   const('incorrect order  ')
416bA*
414cA*----------------------------------------------------------------
414cA*  API programs
414cA*
     D @apics          c                   const('APICVTSLT ')
417cA*----------------------------------------------------------------
417cA*  Working fields.
417cA*
417cAD                 ds
417cAD  lottrk                 1      4
417cAD  lictrk                 5      8
     D llp01           c                   const('Escanda licencia  ')
     D llp02           c                   const('Escn numero de lot')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
417cD*                                      16  27 ERDISP
417cMD  erdisp                 1     12
     *
416gAD  erdmsg                 1     60
416gAD  erdrtn                61     70
416gAD  erdcmd                71     80
416gAD  erdsub                81     90
     D                 ds
     D  $ec                    1      2p 0
417dAD $aerm           ds
417dAD  xaerm                  1     60
417dAD  $amsg                  1      4
     *----------------------------------------------------------------
     *
416BAD                 ds
416BAD  wkyy                   3      4
416BAD  wkmm                   5      6
416BAD  wkdd                   7      8
416BAD  wkexpd                 1      8  0
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
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
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
600aAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
600aAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600aAD  #curruser            358    367

600cA*----------------------------------------------------------------
600cA*  Tracking variables
600cA*----------------------------------------------------------------
600cA
600cA /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Variables
     *

600aAD #fromitwhse     s                   like($itwhse)
600aAD #fromititem     s                   like($ititem)
600aAD #fromittype     s                   like($ittype)
600aAD #fromitdesc     s                   like($itdesc)
600aAD #fromitpdsc     s                   like($itpdsc)
600aAD #fromithead     s             70
600aAD #fromitwhdp     s                   like($itwhdp)
600aAD #fromitstyp     s                   like($itstyp)
600aAD #fromitdesg     s                   like($itdesg)
600aAD #fromitum1      s                   like($itum1)
600aAD #fromitflg1     s                   like($itflg1)
600aAD #fromitum2      s                   like($itum2)
600aAD #fromitumq2     s                   like($itumq2)
600aAD #fromitflg2     s                   like($itflg2)
600aAD #fromitum3      s                   like($itum3)
600aAD #fromitumq3     s                   like($itumq3)
600aAD #fromitnrpk     s                   like($imnrpk)
600aAD #fromitflgd     s                   like($itflgd)
600aAD #fromitcube     s                   like($itcube)
600aAD #fromitswgt     s                   like($itswgt)
600aAD #fromitcwgt     s                   like($itcwgt)
600aAD #fromitmitem    s                   like($itmitem)
600aAD #fromitsdef     s                   like($idsdef)
600aAD #fromittie      s                   like($idtie)
600aAD #fromithigh     s                   like($idhigh)
600aAD #fromimltrk     s                   like($imltrk)

600aAD #homeitwhse     s                   like($itwhse)
600aAD #homeititem     s                   like($ititem)
600aAD #homeittype     s                   like($ittype)
600aAD #homeitdesc     s                   like($itdesc)
600aAD #homeitpdsc     s                   like($itpdsc)
600aAD #homeithead     s             70
600aAD #homeitwhdp     s                   like($itwhdp)
600aAD #homeitstyp     s                   like($itstyp)
600aAD #homeitdesg     s                   like($itdesg)
600aAD #homeitum1      s                   like($itum1)
600aAD #homeitflg1     s                   like($itflg1)
600aAD #homeitum2      s                   like($itum2)
600aAD #homeitumq2     s                   like($itumq2)
600aAD #homeitflg2     s                   like($itflg2)
600aAD #homeitum3      s                   like($itum3)
600aAD #homeitumq3     s                   like($itumq3)
600aAD #homeitnrpk     s                   like($imnrpk)
600daD #homeitflgd     s                   like($itflgd)
600daD #homeitcube     s                   like($itcube)
600daD #homeitswgt     s                   like($itswgt)
600daD #homeitcwgt     s                   like($itcwgt)
600daD #homeitmitem    s                   like($itmitem)
600daD #homeitsdef     s                   like($idsdef)
600daD #homeittie      s                   like($idtie)
600daD #homeithigh     s                   like($idhigh)
600aAD #homeimltrk     s                   like($imltrk)

600aAD #homeslwhse     s                   like($slwhse)
600aAD #homeslwhdp     s                   like($slwhdp)
600aAD #homesldisp     s                   like($sldisp)
600aAD #homeslitem     s                   like($slitem)
600aAD #homeslaisl     s                   like($slaisl)
600aAD #homeslloc      s                   like($slloc)
600aAD #homeslrlvl     s                   like($slrlvl)
600aAD #homeslhand     s                   like($slhand)

     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D a58             s             58
     D bot             s              1
     D cancel          s              1
600aAD chk4err         s               n
     D ckexpd          s                   like(today)
510cAD ckentd          s                   like(today)
     D ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D drierr          s              1
     D drizm           s              1
     D dsplyd          s              2  0
     D dspwin          s              4
     D e               s              2  0
     D eacube          s                   like($itcube)
     D easwgt          s                   like($itswgt)
     D enter           s              5  0
     D error           s               n
     D fmentd          s              8  0
     D fmexpd          s              8  0
     D forceb          s              1
     D forevr          s              1
     D found           s              1
     D frstky          s                   like($puky)
     D fvslot          s              1
     D goback          s              2  0
     D hasvs           s              1
     D help            s              5  0
     D hldvsl          s             12
610fAD i               s              2  0
     D keysta          s                   like($slstat)
     D kycode          s                   like(opcode)
     D kydisp          s                   like($sldisp)
     D kyexpd          s                   like($slexpd)
510cAD kyentd          s                   like($slentd)
     D kyitem          s                   like($ititem)
     D kypick          s                   like($slpick)
     D kyprty          s                   like($slprty)
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
600fAD partial         s               n
     D recno           s              4  0
     D redspl          s              1
     D refrsh          s              1
     D repos           s              1
     D repqty          s                   like(lbqpck)
     D rltype          s                   like($ittype)
     D rolldn          s              5  0
     D rollup          s              5  0
     D rplqty          s                   like(lbqpck)
     D rtvslt          s              4
610bAD scannedSlot     s               n
     D sclear          s              1
     D stop            s              1
     D t#task          s              6
     D tempa2          s              2
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D topick          s              5  0
     D trndte          s              8  0
     D trntim          s              6  0
     D tstdte          s                   like(today)
610hAD view            s              1  0
     D warn            s              1
     D woavl1          s              5  0
     D worqty          s              5  0
     D woslt           s             12
CLDaAD w1ldspFull      s             15
CLDbAD w1ldspFullNone  s             15    inz('-------')
CLDaAD licLen          s              3  0
     D x               s              3  0
     D y               s              3  0
600aAD zmsflag         s               n
600aAD LT107_Repack    s               n
710aAD $newlp#         s                   like($tlic#)
720cAd w1disp          s             12
720cAd lcnsScan        s               n

600aA*----------------------------------------------------------------
600aA*  LT210 parameters
600aA*----------------------------------------------------------------

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
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

510cD*----------------------------------------------------------------
510cD*  Redefine field names in file SLOTRPEX
510cD*
510cD **serec
510cD **            sewhse                      sxwhse
510cD **            sewhdp                      sxwhdp
510cD **            sedisp                      sxdisp
510cD **            seitem                      sxitem
510cD **            seadte                      sxadte
510cD **            seatim                      sxatim
510cD **            seaby                       sxaby

600bA*----------------------------------------------------------------
600bA*  Time variables
600bA*----------------------------------------------------------------
600ba
600bAD CurrStamploc    s               z
600bAD CurrStampsys    s               z
600bAD CurrStampuc     s               z
600bA
600baD bfcoffset       s              3  0 inz(0)

610fA*----------------------------------------------------------------
610fA*  Phrase Variables
610fA*----------------------------------------------------------------
610fA
610fA /COPY *libl/qcopysrc,c#phrasvar
610fAD  currFile       s             10
610fAD  currRoutine    s             20
610fAD  lastnxtscr     s              3
610fAD  stackCount     s              3  0
610fAD  aRoutine       s             20    dim(30)
610fA
610fA*----------------------------------------------------------------
610fA*  Phrases
610fA*----------------------------------------------------------------
610fA
610fA /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
600bA*      $iPrg    Calling program
600bA*      $iWhse   Warehouse
600bA*      $iWhdp   Warehouse department
600bA*      $iHome   Home slot from LT105.01
600bA*      $iItem   Item number
     *
     *    Returned Parameters
600bA*      frm$Slot   $slot for From slot
600bA*      frm$Slot2  $slot2 for From slot
600bA*      $iReturn   *Exit
600bA*                 *Cancel
600bA*                 *OK
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
600bAC                   parm                    $iPrg            10
600bAC                   parm                    $iWhse            3 0
600bAC                   parm                    $iWhdp            5
600bAC                   parm                    $iHome           12
600bAC                   parm                    $iItem           15
600bAC                   parm                    frm$slot
600bAC                   parm                    frm$slot2
600bAC                   parm                    $iReturn          8
720aAC                   parm                    $ilcnsdisp       12
      **
600bDC**                 parm                    $prtky
600bDC**                 parm                    $rtncd            8
600bDC**                 parm                    $rzero            1
600bDC**                 parm                    $rendd            8 0
600bDC**                 parm                    $rendt            6 0

650bA*  if coming from LT107 and Repack Replenishment then user wants
650bA*  to override from slot.  Use the partial quantity vs. full slot
650bAc                   if        $iPrg = 'LT107R'
650bAc                   eval      $iPrg = 'LT107'
650bAc                   eval      topick = frm$slot.$slavl3
650bAc                   eval      frm$slot.$slavl3 = 0
650bAc                   eval      LT107_Repack = *on
650bAc                   else
650bAc                   eval      LT107_Repack = *off
650bAc                   endif
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
     *----------------------------------------------------------------
     *  Main line
     *
610fAC                   eval      stackCount = 0
610fAC                   eval      currRoutine = 'main'
610fAC                   exsr      phpgmV1V2V3s
     C                   eval      *in97 = *on
600bMC                   eval      $iReturn = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
610fAC                   exsr      phpgmV1V2V3e
213 AC                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
610fA*
610fA*   Write tracking phrase of which screen is being displayed.
610fA*
610fAC                   exsr      phscrV1PgmV2
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
720aAc                   if        %parms >= 9 and $ilcnsdisp <> ' '
720aAc*                  eval      w1disp = $ilcnsdisp
720aAc                   else
500eAC                   select
510dAC                   when      e$lng = 'SP' and #lline = '16'
510dAC                   read      po16nrsp                               50
510dAC                   read      sc16resp                               50
500eAC                   when      e$lng = 'SP'
500eAC                   read      postnrsp                               50
500eAC                   read      scanresp                               50
510dAC                   when      e$lng = 'EN' and #lline = '16'
510dAC                   read      po16nrec                               50
510dAC                   read      sc16rec                                50
500eAC                   other
     C                   read      postnrec                               50
     C                   read      scanrec                                50
500EAC                   endsl
720aAc                   endif
     C                   endif
610fA*
610fA*   Write tracking phrase of what was pressed.
610fA*
610fAC                   exsr      phV2onV1
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       0323
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
414cAC                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
610hAC                   select
610hAC                   when      view = 2
610hA
720aAc                   if        %parms >= 9 and $ilcnsdisp <> ' '
720aAc                   else
610hAC                   select
610hAC                   when      #lline = '16'
610hAC                             and e$lng = 'SP'
610hAC                   read      d16sfcsp2                              50
610hAC                   when      #lline = '16'
610hAC                             and e$lng = 'EN'
610hAC                   read      d16sfc2                                50
610hAC                   when      #lline <> '16'
610hAC                             and e$lng = 'SP'
610hAC                   read      dspsfcsp2                              50
610hAC                   when      #lline <> '16'
610hAC                             and e$lng = 'EN'
610hAC                   read      dspsfc2                                50
610hAC                   endsl
720aAc                   endif
610hA
610hAC                   other

417bAC                   select
417bAC                   when      #lline = '16'
500eAC                             and e$lng = 'SP'
500eAC                   read      d16sfcsp                               50
500eAC                   when      #lline = '16'
500eAC                             and e$lng = 'EN'
417bAC                   read      d16sfc                                 50
500eAC                   when      #lline <> '16'
500eAC                             and e$lng = 'SP'
500eAC                   read      dspsfcsp                               50
500eAC                   when      #lline <> '16'
500eAC                             and e$lng = 'EN'
     C                   read      dspsfc                                 50
417bAC                   endsl
     *
610hAC                   endsl

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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
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
510cAC                   call      @getcl
510cAC                   parm                    client           10
510dA*
510dA*   Get screen size being used.
510dA*
510dAC                   call      'PIRRFSCR'
510dAC                   parm      '*GET'        #lcmd             8
510dAC                   parm                    #lline            2
510dAC                   parm                    #lcol             3
510cA*
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1

500eAC                   select
510dAC                   when      e$lng = 'SP' and #lline = '16'
500dAC                   write     d16sflsp                             79
610hAC                   write     d16sflsp2                            79
500eAC                   when      e$lng = 'SP'
500eAC                   write     dspsflsp                             79
610hAC                   write     dspsflsp2                            79
510dAC                   when      e$lng = 'EN' and #lline = '16'
510dAC                   write     d16sfl                               79
610hAC                   write     d16sfl2                              79
500eAC                   other
     C                   write     dspsfl                               79
610hAC                   write     dspsfl2                              79
500eAC                   endsl
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ChkCnt   Check option count, can't select > 1
700bA*
700bAC     chkcnt        begsr
700bAC     wkoprt        setll     workopt
700bAC     wkoprt        reade     workopt                              7979
700bAC                   if        not *in79
700bAC                   eval      optcnt = 1
700bAC                   endif
700bAC                   endsr
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
416 AC                   eval      optcnt = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
600bMC                   eval      $iReturn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
600bMC                   eval      $iReturn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR F5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
417bMC     1             do        dsplyd        x
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC     x             chain     d16sflsp2                          79
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC     x             chain     d16sfl2                            79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC     x             chain     dspsflsp2                          79
610hAC                   when      #lline <> '16'
610hAC                   when      e$lng = 'EN'
610hAC     x             chain     dspsfl2                            79
610hAC                   endsl
610hAC                   if        not *in79
610hAC                   eval      option = '  '
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    d16sflsp2
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    d16sfl2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    dspsflsp2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    dspsfl2
610hAC                   endsl
610hAC                   endif
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC     x             chain     d16sflsp                           79
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC     x             chain     d16sfl                             79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC     x             chain     dspsflsp                           79
500eAC                   when      #lline <> '16'
500eAC                   when      e$lng = 'EN'
     C     x             chain     dspsfl                             79
417bAC                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    d16sflsp
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   update    d16sfl
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    dspsflsp
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   update    dspsfl
417bAC                   endsl
     C                   endif
610hA
610hAC                   endsl
610hA
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
650aAC                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
650aAC                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR F6 - ADD RECORD
     *
     C                   if        *inkf
     C                   eval      $pprg = #prog
600aDC**                 eval      ukwhse = itwhse
600aDC**                 eval      ukwhdp = itwhdp
600aDC**                 eval      ukdisp = *blanks
600aDC**                 eval      ukitem = ititem
     C                   eval      $puky = dsukey
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
     C                   if        $prtn <> '*EXIT   '  and
     C                             $prtn <> '*CANCEL '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
416eA*
416eA*  TEST FOR F8 - Display license plate info.
416eA*
416eAC                   if        *inkh
416eAC                   call      'LP120CL'
416eAC                   goto      cmd01e
416eAC                   endif
     *
500 M*  TEST FOR F10 - Out. No more replenishment slots available.
     *
     C                   if        *inkj
700aA*    Write out exception record.
700aAC                   eval      exerid = 'SLOTOUT'
700aAC                   exsr      zzexcp
500 AC                   exsr      zzout
     C                   endif
510e C*  Test for F11 - Call transfer program, bypass transaction.
510e C*  Code is from F9 skip.
510e C*
510e C                   if        *inkk
510eAC* Call RF transfer.
510eAC                   eval      $lwhse = 0
510eAC                   eval      $lwhdp = ' '
510eAC                   eval      $litem = lbitem
510eAC                   eval      $ldisp = lbdisp
510eAC                   eval      $ldsp2 = ' '
510eAC                   call      'IT250'
510eAC                   PARM                    $lparm
510eAC                   endif
510eAC*
     *
     *  TEST FOR F17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F18 - REPOSITION TO BOTTOM OF DISPLAY
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
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
650aAC                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
650aAC                   endif
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
221 A*  CHECK IF SLOT WAS ENTERED.
     *
530 AC                   eval      fvslot = *off
530 AC                   eval      hldvsl = *blanks
610bAC                   eval      scannedSlot = *off
720cAc                   eval      lcnsScan = *off
720cDC*                  if        w1disp <> *blanks
720cAC                   if        w1scan <> *blanks
720cAc*   confirm scan was slot vs. license
720cA /free
720cA             w1disp = %trim(w1scan);
720cA             chain ($iWhse:$iWhdp:W1DISP) slot2;
720cA             if %found(slot2);
720cA                // nothing to do if valid slot
720cA             else;
720cA                //  get slot from licactive
720cA                chain ($iWhse:w1scan) licactive;
720cA                if %found(licactive);
720cA                   lcnsScan = *on;
720cA                   w1disp = ladisp;
720cA                endif;
720cA             endif;
720cA /end-free
610bAC                   eval      scannedSlot = *on
221 AC                   exsr      zzchk1
221 AC     error         cabeq     *on           ent01e
414cAC     redspl        cabeq     *on           ent01e
417cAC     cancel        cabeq     *on           ent01e
600bDC**                 eval      $iDisp = w1disp
600bDC**                 eval      $puky = dsukey
     *
     C                   exsr      zzstrt

600bMC                   eval      $iReturn = '*OK     '
414aA*
414aAC                   eval      nxtscr = 'EOJ'
411 MC                   goto      ent01e
     *
720cAc                   else
720cAc                   eval      w1disp = *blanks
221 AC                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     C     ent01e        endsr
     *
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
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
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
     C                   exsr      zzkeyi
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
     C                   exsr      zzkeyi
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
     C     fileky        setll     record
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
     C                   move      $prtky        $puky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
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
     C                   if        refrsh = '1'
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
     C                   select
414bA*
414bA*   Select slot for replenishment.
414bA*
414bAC                   when      wkoopt = ' 1'
414eAC                   eval      dsukey = $puky
414bAC                   exsr      zzslct
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @vewpg
     C                   parm                    $parms
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     *   View slot quantities.
     *
     C                   when      wkoopt = ' 9'
411 MC                   call      'SL635'
     C                   parm      #homeitwhse   $twhse
     C                   parm                    #homeitwhdp
     C                   parm                    $pdisp
700 A*
700 A*    Log slot error in item exception file.
700 A*
700 AC                   when      wkoopt = ' S'
700 AC                   eval      kydisp = $pdisp
700 AC                   eval      w1disp = $pdisp
770 Ac                   exsr      zzgetfromsl
770 A*
770 A*    Write out exception record.
700 AC                   eval      exerid = 'STKPLT '
700 AC                   exsr      zzexcp
700 A*
700 A*    Write record to slot exception file.
700 AC                   if        slpick <> 'Y'
700 AC                   exsr      zzexsl
700 AC                   endif
700 A*
700 AC                   select
700 AC                   when      e$lng = 'SP'
700 AC                   eval      errmsg = %trimr(descsp(5)) + ' ' + sldisp
700 AC                   other
700 AC                   eval      errmsg = %trimr(desc(5)) + ' ' + sldisp
700 AC                   endsl
700 AC                   exsr      zm0105
     *
416cA*
416cA*    Log slot error in item exception file.
416cA*
416cAC                   when      wkoopt = ' X'
416bAC                   eval      kydisp = $pdisp
640dAC                   eval      w1disp = $pdisp
640dAc                   exsr      zzgetfromsl
416cA*
416cA*    Write out exception record.
416cAC                   eval      exerid = 'WRGITM '
416cAC                   exsr      zzexcp
416iA*
416iA*    Write record to slot exception file.
416iAC                   if        slpick <> 'Y'
416iAC                   exsr      zzexsl
416iAC                   endif
416iA*
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = %trimr(descsp(5)) + ' ' + sldisp
500eAC                   other
416iAC                   eval      errmsg = %trimr(desc(5)) + ' ' + sldisp
500eAC                   endsl
416iAC                   exsr      zm0105
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
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
     C                   eval      bot = *off
     C                   exsr      pag1fw
720bA*  If Store Pick Slot was scanned and no slots to replenish from return with message
720bAc                   if        $zdstgflg='Y' and p=0
720bAc                   eval      $iReturn = 'STRNOSTK'
720bAc                   return
720bAc                   endif
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
     *
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
417aAC                   eval      offlag = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
417aA*
417aA*    Display is empty. Force flag on in case user pages back.
417aAC                   if        oplmts = 'Y'  and
417aAC                             offlag = *off
417aAC                   eval      offlag = *on
417aAC                   endif
417aA*
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
417aA*
417aA*    Display is configured to display 1 overflow slot at a time.
417aA*
417aAC                   if        oplmts = 'Y'  and
417aAC                             slpick = 'N'  and
417aAC                             offlag = *off
417aAC                   eval      offlag = *on
417aAC                   eval      stop = *on
417aAC                   goto      endfwd
417aAC                   endif
417aA*
417bMC                   if        recno >= 3  and
417bAC                             #lline <> '16'  or
510dDC*                            recno >= 10  and
510dMC                             recno >= 8   and
417bAC                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   endif
     C                   endif
     C     endfwd        tag
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
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
417aA*
417aA*    Display is limited to one overflow location at a time.
417aAC                   if        offlag = *on
417aAC     dsplyd        add       1             goback
417aAC                   else
417bAC                   select
417bAC                   when      #lline = '16'
417bAC     dsplyd        add       10            goback
417bAC                   other
412 MC     dsplyd        add       3             goback
417bAC                   endsl
417aAC                   endif
     C                   if        bot = '1'
412 MC                   if        goback = 3  and
417bAC                             #lline <> '16'  or
417bAC                             goback = 10  and
417bAC                             #lline = '16'
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
     C                   dou       stop = '1'
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
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
650aAC                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
650aAC                   endif
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
650aAC                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
650aAC                   endif
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
600cAC                   eval      optcnt = 0
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
414eMC                   eval      *in85 = *off
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC                   readc     d16sflsp2                              79
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC                   readc     d16sfl2                                79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC                   readc     dspsflsp2                              79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC                   readc     dspsfl2                                79
610hAC                   endsl
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
417bAC                   readc     d16sflsp                               79
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   readc     d16sfl                                 79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   readc     dspsflsp                               79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   readc     dspsfl                                 79
417bAC                   endsl
610hA
610hAC                   endsl
610hA
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
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
     *    OR CLIENT/OPTION NOT ALLOWED.
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50 or
700 AC                             client <> cheney and
700 AC                             option = ' S'
     C                   eval      error = *on
     C                   eval      *in21 = *on
414eAC                   eval      *in85 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
414eA*
414eA*    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
414eA*
414eAC                   if        option = ' 1'
700bDC*                  add       1             optcnt
700bMC                   exsr      chkcnt
700bMC                   if        optcnt >= 1
700bDC*                  if        optcnt > 1
414eAC                   eval      error = *on
414eAC                   eval      *in21 = *on
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(4)
500eAC                   other
414eAC                   eval      errmsg = desc(4)
500eAC                   endsl
414eAC                   exsr      zm0105
414eAC                   endif
414eA*
414eA*    Force SFLNXTCHG to be on each time.
414eAC                   eval      *in85 = *on
414eAC                   endif

700cA      // Specific slot replenishments from the same slot not allowed.
700cA /free
740 M  if $ihome = sldisp
740 A     and option = ' 1'
740 M     or $ihome = sldisp
740 A     and option = ' ';
700cA    error = *on;
700cA    *in21 = *on;
700cA    *in85 = *on;
700cA    select;
700cA    when e$lng = 'SP';
700cA      errmsg = descsp(7);
700cA    other;
700cA      errmsg = desc(7);
700cA    endsl;
700cA    exsr zm0105;
700cA  endif;
700cA /end-free

414eA*
414eA*    Pick slot not available for replenishment.
417dA*     If breakdown replenishment, allow pick slot to be used.
414eA*
414eAC                   if        slpick = 'Y'  and
414eAC                             option = ' 1'  and
600aMC                             #homeittype <> 'B'
610gAC                             and #homeittype <> ' '
600aDC**                           rltype <> 'B'
414eAC                   eval      error = *on
414eAC                   eval      *in21 = *on
414eAC                   eval      *in85 = *on
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
414eAC                   eval      errmsg = desc(3)
500eAC                   endsl
414eAC                   exsr      zm0105
414eAC                   endif
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
414eMC                   move      *in85         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
414eMC                   move      *in85         wkoerr
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
417bMC                   if        recno < 3  and
417bAC                             #lline <> '16'  or
510dDC*                            recno < 10  and
510dMC                             recno < 8   and
417bAC                             #lline = '16'
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
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     d16sflsp
610hAC                   write     d16sflsp2
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   write     d16sfl
610hAC                   write     d16sfl2
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     dspsflsp
610hAC                   write     dspsflsp2
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   write     dspsfl
610hAC                   write     dspsfl2
417bAC                   endsl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     d16sfcsp
610hAC                   write     d16sfcsp2
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   write     d16sfc
610hAC                   write     d16sfc2
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     dspsfcsp
610hAC                   write     dspsfcsp2
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   write     dspsfc
610hAC                   write     dspsfc2
417bAC                   endsl
     C                   eval      recno = 0
GFCaAC                   eval      w1disp = *blanks
720cAC                   eval      w1scan = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     c16rec
417bAC                   other
     C                   write     cmdrec
417bAC                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   other
417bAC                   endsl
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
500eAC                   select
510dAC                   when      e$lng = 'SP' and #lline = '16'
510dAC                   write     po16nrsp
500eAC                   when      e$lng = 'SP'
500eAC                   write     postnrsp
510dAC                   when      e$lng = 'EN' and #lline = '16'
510dAC                   write     po16nrec
500eAC                   other
     *
     *  IF CLIENT CHENEY, DISPLAY OPTION "S=Stuck Plt".
     *
700 AC                   if        client = cheney
700 AC                   seton                                        22
700 AC                   endif
     C                   write     postnrec
500eAC                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
650aAC                             and dsplyd > 0
650aA*
650aAC                   if        dsplyd > 0
650aAC                   eval      *in81 = *on
650aAC                   else
650aAC                   eval      *in81 = *off
650aAC                   endif
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC     1             chain     d16sflsp2                          79
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC     1             chain     d16sfl2                            79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC     1             chain     dspsflsp2                          79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610h C     1             chain     dspsfl2                            79
610hAC                   endsl
610hAC                   if        not *in79
610hAC                   eval      *in20 = *on
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    d16sflsp2
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    d16sfl2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    dspsflsp2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    dspsfl2
610hAC                   endsl
610hAC                   endif
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC     1             chain     d16sflsp                           79
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC     1             chain     d16sfl                             79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC     1             chain     dspsflsp                           79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C     1             chain     dspsfl                             79
417bAC                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    d16sflsp
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   update    d16sfl
417bAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    dspsflsp
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   update    dspsfl
417bAC                   endsl
     C                   endif
610hA
610hAC                   endsl
610hA
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC                   write     d16sfcsp2
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC                   write     d16sfc2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC                   write     dspsfcsp2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC                   write     dspsfc2
610hAC                   endsl
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     d16sfcsp
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   write     d16sfc
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   write     dspsfcsp
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   write     dspsfc
417bAC                   endsl
610hA
610hAC                   endsl
500eA*
500eAC                   select
510dAC                   when      e$lng = 'SP' and #lline = '16'
510dAC                   write     sc16resp
500eAC                   when      e$lng = 'SP'
414cAC                   write     scanresp
510dAC                   when      e$lng = 'EN' and #lline = '16'
510dAC                   write     sc16rec
500eAC                   other
414cAC                   write     scanrec
500eAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
417bMC     1             do        dsplyd        x
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC     x             chain     d16sflsp2                          79
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC     x             chain     d16sfl2                            79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC     x             chain     dspsflsp2                          79
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC     x             chain     dspsfl2                            79
610hAC                   endsl
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC     x             chain     d16sflsp                           79
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC     x             chain     d16sfl                             79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC     x             chain     dspsflsp                           79
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
417bAC                   endsl
610hA
610hAC                   endsl
610hA
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
414eAC                   eval      *in85 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
414eAC                   eval      *in85 = *off
720aA /free
720aA   if $ilcnsdisp = sldisp;
720aA     option = '1 ';
          *in85 = *on;
720aA   else;
720aA     option = '  ';
720aA   endif;
720aA /end-free
     C                   endif
610hA
610hAC                   select
610hAC                   when      view = 2
610hA
610hAC                   select
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    d16sflsp2
610hAC                   when      #lline = '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    d16sfl2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'SP'
610hAC                   update    dspsflsp2
610hAC                   when      #lline <> '16'  and
610hAC                             e$lng = 'EN'
610hAC                   update    dspsfl2
610hAC                   endsl
610hA
610hAC                   other
610hA
417bAC                   select
417bAC                   when      #lline = '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    d16sflsp
500eAC                   when      #lline = '16'  and
500eAC                             e$lng = 'EN'
417bAC                   update    d16sfl
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'SP'
500eAC                   update    dspsflsp
500eAC                   when      #lline <> '16'  and
500eAC                             e$lng = 'EN'
     C                   update    dspsfl
417bAC                   endsl
610hA
610hAC                   endsl
610hA
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
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     m16ctl
417bAC                   other
     C                   write     msgctl
417bAC                   endsl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     m16clr
417bAC                   other
     C                   write     msgclr
417bAC                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     m16ctl
417bAC                   other
     C                   write     msgctl
417bAC                   endsl
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
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      $msgf = #msgsp
500eAC                   other
     C                   eval      $msgf = #msgf
500eAC                   endsl
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
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     m16rec
417bAC                   other
     C                   write     msgrec
417bAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   write     m16rec
417bAC                   other
     C                   write     msgrec
417bAC                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
417bAC                   select
417bAC                   when      #lline = '16'
417bAC                   other
417bAC                   endsl
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      $msgf = #msgsp
500eAC                   other
     C                   eval      $msgf = #msgf
500eAC                   endsl
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*    DRI0001  Local system caused error
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001        begsr
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

600aA*----------------------------------------------------------------
600aA*    DRI0001s Local system caused error (send to different program)
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001s       begsr
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
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
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
600aA*----------------------------------------------------------------
600aA*      0105s
600aA*
600aAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
409 A*----------------------------------------------------------------
409 A*   PIR1005  Value must be 'Y' or 'N'
409 A*
409 AC     zm1005        begsr
409 AC                   eval      #msgid = 'PIR1005'
409 AC                   eval      #msgtp = '*DIAG  '
409 AC                   movea     errmsg        $md
409 AC                   exsr      zmpmsg
409 AC                   endsr
     *----------------------------------------------------------------
221 A*    IT27101  SLOT
221 A*
221 AC     zm7101        begsr
221 AC                   eval      #msgid = 'IT27101'
221 AC                   eval      #msgtp = '*DIAG  '
221 AC                   eval      $md = *blanks
221 AC                   exsr      zmpmsg
221 AC                   endsr
AFI A*----------------------------------------------------------------
AFI A*     ZM0110   Quantity must be greater than 0.
AFI A*
AFI AC     zm0110        begsr
AFI AC                   eval      #msgid = 'PIR0110'
AFI AC                   eval      #msgtp = '*DIAG  '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(1)     errmsg
500eAC                   other
AFI AC                   eval      errmsg = desc(1)
500eAC                   endsl
AFI AC                   movea     errmsg        $md(1)
AFI AC                   exsr      zmpmsg
AFI AC                   endsr
416kA*----------------------------------------------------------------
416kA*   PIR2007  Invalid slot, slot inactive.
416kA*
416kAC     zm2007        begsr
416kAC                   eval      #msgid = 'PIR2007'
416kAC                   eval      #msgtp = '*DIAG  '
416kAC                   eval      $md = *blanks
416kAC                   exsr      zmpmsg
416kAC                   endsr
720dA*----------------------------------------------------------------
720dA*   PIR2104  Item for license scanned not equal to item required
720dA*
720dAC     zm2104        begsr
720dAC                   eval      #msgid = 'PIR2104'
720dAC                   eval      #msgtp = '*DIAG  '
720dAC                   eval      $md = *blanks
720dAC                   exsr      zmpmsg
720dAC                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
410 AC     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
410 AC                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
410 AC     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
410 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr

610hAC                   if        *inki
610hAC                   eval      view += 1
610hAC                   if        view > 2
610hAC                   eval      view = 1
610hAC                   endif
610hAC                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
221 A*  ZZCHK1   Screen 1 error checking.
221 A*
221 AC     zzchk1        begsr
221 AC                   eval      error = *off
416bAC                   eval      rtvslt = '*NO '
417cAC                   eval      wwllp# = *blanks
720dA*
720dA*  Verify scanned license is for repl item.
720dAC                   if        lcnsScan and
720gDC*                            laitem <> $iitem
720gMC                             laitem <> $ititem
720dAC                   eval      error = *on
720dAC                   eval      *in21 = *on
720dAC                   eval      *in01 = *on
720dAC                   eval      errmsg = *blanks
720dAC                   exsr      zm2104
720dAC                   goto      endck1
720dAC                   endif
720dA*
221 A*
221 AC                   eval      noslt = *off
221 A*
221 A*  SLOT not entered.
221 A*
720cDC*                  if        w1disp = *blanks
720cAC                   if        w1scan = *blanks
221 AC                   eval      noslt = *on
221 AC                   eval      woslt = *blanks
720cDc                   eval      w1disp=*blanks
     C                   goto      endck1
221 AC                   endif
414cA*
414cA*  Call API for slot.
414cA*
510dAc                   if        #lline = '16'
510dAc                   eval      worow = 2
750aAc                   eval      wocol = 12
750aDc*                  eval      wocol = 9
510dAc                   else
510dAc                   eval      worow = 1
750aMc                   eval      wocol = 31
750aDc*                  eval      wocol = 29
510dAc                   endif
414cAC                   call      @apics
414cAC                   parm                    w1disp
510dDC*                  parm      1             worow
510dDC*                  parm      27            wocol
510dMC                   parm                    worow
510dMC                   parm                    wocol
414cAC                   parm                    @artn             8
414cAC                   if        @artn = '*REDSPLY'
750aAC                   eval      w1scan = w1disp
414cAC                   eval      redspl = *on
414cAC                   goto      endck1
414cAC                   endif
600aA*
600aA*  Get scanned From slot.
600aA*
600aAC                   eval      rtvslt = '*YES'
600aAC                   exsr      zzgetfromsl
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   eval      errmsg = *blanks
600aAC                   exsr      zm04
600aAC                   goto      endck1
600aAC                   endif
610dA*
610dA*  Verify that scanned/entered slot is not internal use slot.
610dA*
610dAC                   if        $sldesg = 'BFC'
610dAC                   eval      error = *on
610dAC                   eval      *in21 = *on
610dAC                   eval      *in01 = *on
610dAC                   eval      errmsg = *blanks
610dAC                   exsr      zm7101
610dAC                   goto      endck1
610dAC                   endif
610bA
610bA*  If slot was scanned,
610bA*  then get first fifo slot for item within the scanned slot.
610bA
720cDC*                  if        scannedSlot
720cMC                   if        scannedSlot and not lcnsScan
610bAC                   exsr      zzgetfromslv
610bAC                   if        fvslot <> *on
610bAC                   eval      error = *on
610bAC                   eval      *in21 = *on
610bAC                   eval      *in01 = *on
610bAC                   goto      endck1
610bAC                   endif
610bAC                   endif
416bA*
416bAC                   select
416bA*    Check only date sensitive items.
600aMC                   when      #fromitflgd = 'Y'  and
416bAC                             option = ' 1'  or
416bA*
600aMC                             #fromitflgd = 'Y'  and
416bAC                             option = '  '
416bA*
416bA*    Retrieve current date in yyyymmdd format.
416bAC                   eval      $cvcmd = '*CURCMD '
416bAC                   exsr      zzcvdt
416bAC                   eval      tstdte = $cvd8o
416bA*
416bA*    Check slot selected for expired product.
416bAC                   select
416bA*    Replenishment with expired product not allowed. Display msg.
416bAC                   when      oprpex = '2'  and
600aMC                             frm$slot.$slexpd < tstdte  and
600aMC                             frm$slot.$slexpd > 0  or
416bA*
416bA*    Replenishment with expired product, warn user. Display msg.
416bAC                             oprpex = '3'  and
600aMC                             frm$slot.$slexpd < tstdte  and
600aMC                             frm$slot.$slexpd > 0
416bA*
416bAC                   eval      msgtyp = '*EXPIRED'
416bAC                   exsr      zzwarn
416bAC                   if        error = *on
416bAC                   goto      endck1
416bAC                   endif
416bA*
416bAC                   endsl
416bAC                   endsl
416bA*
416bAC                   select
600cA
600cD**** Check only date sensitive items.
600cM*    Now, check all non-Low tracking items
416bA*      Check slot to see if taken out of FIFO date rotation.
RYLbA*    For Royal, check all items
RYLbA
CBI AC                   when      client = cheney and
CBI AC                             #fromitflgd = 'Y'

CBI AC                             or client <> cheney
CBI AC                   select

600cDC**                 when      #fromitflgd = 'Y'  and
600cMC                   when      #fromimltrk <> tLow and
416bAC                             option = ' 1'  and
416bAC                             oprpfi = '3'  and
416bAC                             error = *off  or
416bA*
600cDC**                           #fromitflgd = 'Y'  and
600cMC                             #fromimltrk <> tLow and
416bAC                             option = '  '  and
416bAC                             oprpfi = '3'  and
416bAC                             error = *off
416bA*
RYLbAC                             or client = royal
FRF AC                             or client = FRF
RYLbA
416bAC                   eval      kydisp = w1disp
416bAC                   exsr      zzckrt
416bAC                   select
416bAC                   when      dspwin = '*YES'
720eAc                               and $ilcnsdisp=*blanks
416bAC                   eval      msgtyp = '*FIFO   '
416bAC                   exsr      zzwarn
416bAC                   if        error = *on
416bAC                   goto      endck1
416bAC                   endif
416bA*
416bAC                   endsl
416bA*
416bAC                   endsl
CBI AC                   endsl
RYLbDC**
RYLbDC**   If client = Royal, also Check non date sensitive items.
RYLbDC**     Check slot to see if taken out of FIFO date rotation.
RYLbDC**
RYLbDC**                 if        client = royal
RYLbDC**
RYLbDC**                 select
RYLbDC**                 when      #fromitflgd <> 'Y'  and
RYLbDC**                           option = ' 1'  and
RYLbDC**                           oprpfi = '3'  and
RYLbDC**                           error = *off  or
RYLbDC**
RYLbDC**                           #fromitflgd <> 'Y'  and
RYLbDC**                           option = '  '  and
RYLbDC**                           oprpfi = '3'  and
RYLbDC**                           error = *off
RYLbDC**
RYLbDC**                 eval      kydisp = w1disp
RYLbDC**                 exsr      zzckrt2
RYLbDC**                 select
RYLbDC**                 when      dspwin = '*YES'
RYLbDC**                 eval      msgtyp = '*FIFO   '
RYLbDC**                 exsr      zzwarn
RYLbDC**                 if        error = *on
RYLbDC**                 goto      endck1
RYLbDC**                 endif
RYLbDC**
RYLbDC**                 endsl
RYLbDC**
RYLbDC**                 endsl
RYLbDC**                 endif

416kA*
416kA*    Scanned slot not active. Not eligible for replenishment.
600aMC                   if        frm$slot.$slstat <> 'A '
416kAC                   eval      error = *on
416kAC                   eval      *in21 = *on
416kAC                   eval      *in01 = *on
416kAC                   exsr      zm2007
416kAC                   goto      endck1
416kAC                   endif

700cA      // Specific slot replenishments from the same slot not allowed.
700cA /free
700cA  if (option = *blanks and $ihome = w1disp)
700cA  or (option = '1' and $ihome = sldisp);
700cA    cancel = *on;
700cA    error  = *on;
700cA    *in21  = *on;
700cA    *in85  = *on;
700cA    *in01  = *on;
700cA    select;
700cA    when e$lng = 'SP';
700cA      errmsg = descsp(7);
700cA    other;
700cA      errmsg = desc(7);
700cA    endsl;
700cA    exsr zm0105;
700cA  endif;
700cA /end-free

     *
     *     Slot not a replenishment slot for item.
417dA*     If breakdown replenishment, allow pick slot to be used.
     *
600aMC                   if        frm$slot.$slpick = 'Y'  and
600aMC                             #homeittype <> 'B'
610kAC                             and #homeittype <> ' '
414dAC                   eval      cancel = *on
414dAC                   eval      error = *on
414dAC                   eval      *in21 = *on
414dAC                   eval      *in85 = *on
414dAC                   eval      *in01 = *on
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
414dAC                   eval      errmsg = desc(3)
500eAC                   endsl
414dAC                   exsr      zm0105
414dAC                   endif
610bDC**                 if        frm$slot.$slitem <> $iItem  and
610bDC**                           #homeittype <> 'B'
610bDC**    Look for a virtual slot for item.
610bDC**                 exsr      zzgetfromslv
610bDC**                 if        fvslot <> *on
610bDC**                 eval      error = *on
610bDC**                 eval      *in21 = *on
610bDC**                 eval      *in01 = *on
610bDC**                 goto      endck1
610bDC**                 endif
610bDC**                 endif
     *
     *     Available qty must be greater than zero.
     *
600aMC                   if        frm$slot.$slavl1 <= 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0110
     C                   endif
600aA
600aA*  Call program that will (if necessary) ...
600aA*    - Prompt user to pull pallet.
600aA*    - Have user verify license being pulled.
600aA*    - Update license information.
650bA*    - Do not prompt if slot change for repack item
600aA
650bAc                   if        not LT107_Repack
600aAC                   exsr      zzzclr$lt210
600aAC                   eval      $tcmd   = '*PULDROP'
600aAC                   eval      $twhdp  = frm$slot.$slwhdp
600aAC                   eval      $tslot  = frm$slot.$sldisp
600aAC                   eval      $titem  = frm$slot.$slitem
600aAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic# = frm$slot2.$saToLcns
600aAC                   exsr      zzzcall$lt210
600aA
600aAC                   select
600aAC                   when      $treturn = '*OK'
600aDC**                 eval      $pllp#  = $tlic#
710aAC                   If        frm$slot.$sldisp <> $tslot and
710aAC                             $tslot <> *blanks
710aAC                   Eval      frm$slot.$sldisp = $tslot
710aDC                   eval      $newlp# = $tlic#
710aAC                   Exsr      zzChgRpl
710aAC                   EndIf
600aA
600aAC                   when      $treturn = '*CANCEL'
600aAC                             or $treturn = '*SKIP'
720aAc                   eval      w1disp = ' '
720cAc                   eval      w1scan = ' '
720aAc                   eval      $ilcnsdisp  = ' '
600aAC                   eval      cancel = *on
600aA
600aAC                   when      $treturn = '*NOTFND'
600aA
600aAC                   exsr      zzzclr$lt210
600aAC                   eval      $tcmd   = '*PULRTN'
600aAC                   eval      $twhse  = frm$slot.$slwhse
600aAC                   eval      $twhdp  = frm$slot.$slwhdp
600aAC                   eval      $tslot  = frm$slot.$sldisp
600aAC                   eval      $titem  = frm$slot.$slitem
600aAC                   eval      $titemdsc = #fromithead
600aAC                   eval      $tlic# = frm$slot2.$saToLcns
600aAC                   exsr      zzzcall$lt210
600aA
600aAC                   eval      cancel = *on
600aA
600aAC                   endsl
650bAc                   endif
221 A*
221 AC     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *R         FILUKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
600aDC***  filuky        chain     recordu                            79
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
     C     partky        reade     record                                 79
     C     *in79         cabeq     *on           endgtn
600eDC**                 if        slstat = 'Z '  and
600eDC**                           slrsrv <> 'Y'  or
416kA*
416kA*    Omit all non-active slots.
600eA*      and some special license tracking slots.
600eMC                   if        slstat <> 'A '
600eAC                             or %subst(sldisp:1:3) = 'RCV'
600eAC                             or %subst(sldisp:1:3) = 'STG'
600eAC                             or %subst(sldisp:1:3) = 'OSS'
600eAC                             or %subst(sldisp:1:3) = 'USR'
710bAC                             or %subst(sldisp:1:3) = 'RTN'
730aAC                             or %subst(sldisp:1:3) = 'RWO'
416kA*
     C                   goto      try1
     C                   endif
720aA*    if user scanned a license to start the process
720aA*      we will only load the slot for that license.
720bAc                   select
720aAC                   when      sldisp <> $ilcnsdisp
720aAc                             and $ilcnsdisp <> ' '
720aA*
720aAC                   goto      try1
720bAc                   when      $ilcnsdisp = sldisp
720aAc                             and $ilcnsdisp <> ' '
720bAc                   goto      endgtn
720bAC                   endsl
720aA*    if user did not scan license to start to process and
720aA*      Pick Slot is in a Store/Remote location skip these slots
720bAC                   if        ($ilcnsdisp = *blanks and $zdStgFlg='Y' and
720bAc                              $zdstrovf1 <> sldisp and
720bAc                              $zdstrovf2 <> sldisp and
720bAc                              $zdstrcpck <> sldisp and
720bAc                              $zdstrbpck <> sldisp and
720bAc                              $zdstrovf3 <> sldisp)
720bAC                             or %subst(sldisp:1:3) = 'RPA'
720bAC                   goto      try1
720aAC                   endif
     *
     C     endgtn        endsr
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
     C     partky        readpe    record                                 79
417aAC                   if        *in79
417aAC                   eval      offlag = *off
     C     *in79         cabeq     *on           endgtp
417aAC                   endif
417aA*
600eDC**                 if        slstat = 'Z '  and
600eDC**                           slrsrv <> 'Y'  or
416kA*
416kA*    Omit all non-active slots.
600eA*      and some special license tracking slots.
600eMC                   if        slstat <> 'A '
600eAC                             or %subst(sldisp:1:3) = 'RCV'
600eAC                             or %subst(sldisp:1:3) = 'STG'
600eAC                             or %subst(sldisp:1:3) = 'OSS'
600eAC                             or %subst(sldisp:1:3) = 'USR'
720bAC                             or %subst(sldisp:1:3) = 'RPA'
416kA*
     C                   goto      try2
     C                   endif
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   eval      w1disp = *blanks
720cAC                   eval      w1scan = *blanks
     *   Change priority from negative to positive.
     *
     C                   eval      w1prty = -(slprty)
GFCaA*   Default selection for first overflow
     *
GFCaAC                   if        client = glazier
GFCaAC                   if        slpick <> 'Y' and *in77 = *off
GFCaAC                   eval      w1disp = sldisp
GFCaAC                   eval      *in77  = *on
GFCaAC                   endif
GFCaAC                   endif
     *
     *   Expiration date
     *
     C                   if        slexpd = 0
     C                   eval      w1expd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     C                   endif
     *
     *   Entered date
     *
     C                   if        slentd = 0
     C                   eval      w1entd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
     C                   endif
     *
     *    Create a quantity string to print.
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
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
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
     *
     C                   eval      w1qty = $pqstr

610hA*  Get license for slot
610hA
610hAC                   exsr      clr$slot
610hAC                   eval      $slwhseu = *on
610hAC                   eval      $slwhse  = slwhse
610hAC                   eval      $slwhdpu = *on
610hAC                   eval      $slwhdp  = slwhdp
610hAC                   eval      $sldispu = *on
610hAC                   eval      $sldisp  = sldisp
610hA
610hAC                   eval      $dricommand = '*SLOT'
610hAC                   eval      $drisubcmd  = '%GET'
610hAC                   eval      $drisys2upd = 'D'
610hAC                   eval      chk4err = *on
610hAC                   eval      zmsflag = *off
610hAC                   exsr      zzzdricop
610hAC                   if        drierr = *on
610hAC                   eval      w1lcns = ' '
610hAC                   else
CLDaDC*                  eval      w1lcns = $saToLcns
CLDaAC                   eval      w1ldspfull = $saToLcns
CLDaA /free
CLDaA     licLen = %len(%trimr($saToLcns));
CLDbA     select;
CLDbA       when client = Cityline and #fromimltrk = thigh;
CLDbA         w1lcns = w1ldspFullNone;
720fA       when client = Cityline and #fromimltrk = tUCI;
720fA         w1lcns = w1ldspFullNone;
CLDbA       other;
CLDaA         if licLen > 3 and client = cityline
CLDaA                       and #fromimltrk = tHigh or
720fA            licLen > 3 and client = cityline
720fA                       and #fromimltrk = tUCI or
SFGaA           // licLen > 3 and client = sgc
SFGaA           //            and #fromimltrk = tHigh or
CSPaA            licLen > 3 and client = CoastalSunbelt
WSTaM                       and #fromimltrk = tHigh or
720fA            licLen > 3 and client = CoastalSunbelt
720fA                       and #fromimltrk = tUCI or
720fA            licLen > 3 and client = WestSide
720fA                       and #fromimltrk = tUCI or
WSTaA            licLen > 3 and client = WestSide
WSTaA                       and #fromimltrk = tHigh;
CLDaA           w1lcns = %subst($saToLcns: licLen-2 : 3);
CLDaA         else;
CLDaA           w1lcns = $saTolcns;
CLDaA         endif;
CLDbA     endsl;
CLDaA /end-free
CLDaAC
610hAC                   endif
     *
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  getcurrstamp  Get current timestamps
600bA*----------------------------------------------------------------
600bA
600bAC     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZGETFROMIT   Get From slot item being replenished.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetfromit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #homeitwhse
     C                   if        #homeittype = 'B'
     C                   eval      $ititem  = #homeitmitem
     C                   else
     C                   eval      $ititem  = #homeititem
     C                   endif

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
610eDC*                  eval      zmsflag = *on
610eMC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
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
     C                   eval      #fromimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     C     endgetfromit  endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZGETFROMSL   Get From slot.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetfromsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $iWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $iWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $dricommand = '*SLOT'
600gDC**                 eval      $drisubcmd  = '%GETCHKV'
600gMC                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   goto      endgetfromsl
     C                   endif

     C                   eval      frm$slot = $slot
     C                   eval      frm$slot2 = $slot2

     C     endgetfromsl  endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZGETFROMSLV  Get virtual From slot.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetfromslv  begsr
     C                   eval      fvslot = *off

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #homeitwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #homeitwhdp
     C                   eval      $slitemu = *on
610cDC**                 eval      $slitem  = #homeititem
610cMC                   eval      $slitem  = #fromititem
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'A'
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = frm$slot.$slaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = frm$slot.$slloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = frm$slot.$slrlvl

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETITEMAV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   select
     C                   when      $drireturn = 'EOF'
     C                   eval      $drimessage = 'Virtual slot not found '
     C                                         + 'for item'
     C                   exsr      zm0001
     C                   goto      endgetfromslv
     C                   when      $drireturn <> '*OK'
     C                   exsr      zm0001
     C                   goto      endgetfromslv
     C                   endsl

     C                   eval      fvslot = *on
     C                   eval      w1disp = $sldisp

     C                   eval      frm$slot  = $slot
     C                   eval      frm$slot2 = $slot2

     C     endgetfromslv endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZGETPICKIT   Get Pick slot (sent) item being replenished.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetpickit   begsr

     *  Get item.

     C                   exsr      clr$item
600bMC                   eval      $itwhse  = $iWhse
600bMC                   eval      $ititem  = $iItem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
610eDC*                  eval      zmsflag = *on
610eMC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #homeitwhse = $itwhse
     C                   eval      #homeititem = $ititem
     C                   eval      #homeittype = $ittype
     C                   eval      #homeitdesc = $itdesc
     C                   eval      #homeitpdsc = $itpdsc
     C                   eval      #homeitwhdp = $itwhdp
     C                   eval      #homeitstyp = $itstyp
     C                   eval      #homeitdesg = $itdesg
     C                   eval      #homeitum1  = $itum1
     C                   eval      #homeitflg1 = $itflg1
     C                   eval      #homeitum2  = $itum2
     C                   eval      #homeitumq2 = $itumq2
     C                   eval      #homeitflg2 = $itflg2
     C                   eval      #homeitum3  = $itum3
     C                   eval      #homeitumq3 = $itumq3
     C                   eval      #homeitnrpk = $imnrpk
     C                   eval      #homeitflgd = $itflgd
     C                   eval      #homeitcube = $itcube
     C                   eval      #homeitswgt = $itswgt
     C                   eval      #homeitcwgt = $itcwgt
     C                   eval      #homeitmitem = $itmitem
     C                   eval      #homeimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #homeititem
     C                   parm                    #homeitdesc
     C                   parm                    #homeitpdsc
     C                   parm      ' '           #homeithead

     C     endgetpickit  endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZGETPICKSL   Get Pick slot.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetpicksl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $iWhse
     C                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $iWhdp
     C                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $iHome

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   goto      endgetpicksl
     C                   endif

     C                   eval      #homeslwhse = $slwhse
     C                   eval      #homeslwhdp = $slwhdp
     C                   eval      #homesldisp = $sldisp
     C                   eval      #homeslaisl = $slaisl
     C                   eval      #homeslloc  = $slloc
     C                   eval      #homeslrlvl = $slrlvl
     C                   eval      #homeslhand = $slhand

     C     endgetpicksl  endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
409aA*
409aAC                   eval      forevr = *off
414cAC                   eval      worow = *zeros
414cAC                   eval      wocol = *zeros
416bAC                   eval      msgtyp = *blanks
416bAC                   eval      rtvslt = '*NO '
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slstat
     C                   kfld                    slpick
     C                   kfld                    slprty
     C                   kfld                    slexpd
     C                   kfld                    slentd
     C                   kfld                    slwhdp
     C                   kfld                    slstyp
     C                   kfld                    slaisl
     C                   kfld                    slpseq
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
600bMC                   kfld                    $iWhse
417dMC                   kfld                    kyitem
416bA*
416bA*  Define key for ITMEXCP file.
416bA*
416bAC     exkey         klist
416bAC                   kfld                    exwhse
416bAC                   kfld                    exwhdp
416bAC                   kfld                    exstyp
416bAC                   kfld                    exitem
416bAC                   kfld                    exgdte
416bAC                   kfld                    exgtim
600cDC**
600cDC** Define key for SLOT3 file.
600cDC**   slky3a        klist
600cDC**                 kfld                    $iWhse
600cDC**                 kfld                    $iItem
600cDC**                 kfld                    keysta
600cDC**                 kfld                    kypick
600cDC**                 kfld                    kyprty
600cDC**                 kfld                    kyexpd
600cDC**
600cDC     slky3b        klist
600cDC                   kfld                    $iWhse
600cDC                   kfld                    $iItem
600cDC                   kfld                    keysta
600cDC                   kfld                    kypick
RYLbDC**
RYLbDC** Define key for SLOT10 file.
RYLbDC**   slky3c        klist
RYLbDC**                 kfld                    $iWhse
RYLbDC**                 kfld                    $iItem
RYLbDC**                 kfld                    keysta
RYLbDC**                 kfld                    kypick
RYLbDC**                 kfld                    kyprty
RYLbDC**                 kfld                    kyentd
416bA*
416bA*  Define key for OPTIONS file.
416bA*
416bAC     opkey         klist
600bMC                   kfld                    $iWhse
416bAC                   kfld                    kycode
     *
     *  Setup option and command display lines.
     *
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      optln1 = optlsp(1)
500eAC                   eval      cmdln1 = cmdlsp(1)
500eAC                   other
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
CWa AC                   if        client = citywho
CWa  C                   eval      cmdln1 = cmdcw(1)
CWa AC                   Endif
500eAC                   endsl
416iA*
416iA*  Dummy read for compiler.
416iA*
416iAC                   if        0 = 1
416iAC                   read      sltrpex                                79
416iAC                   endif
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
610fAC                   eval      currRoutine = 'zzinz2'
610fAC                   exsr      phpgmV1V2V3s
640bDC*                  eval      view = 1
CLDcAC                   select
CLDcAC                   when      client = cityline
CLDcAC                   eval      view = 1
CLDcAC                   other
640bMC                   eval      view = 2
CLDcAC                   endsl
500eA*
500eA*   Get employee options.
500eA*
500eAC                   call      'GETUSER'
500eAC                   parm      #user         e$code           10
500eAC                   parm                    e$whse            3 0
500eAC                   parm                    e$emp#            5 0
500eAC                   parm                    e$fnam           15
500eAC                   parm                    e$init            1
500eAC                   parm                    e$lnam           20
500eAC                   parm                    e$whdp            5
500eAC                   parm                    e$styp            1
500eAC                   parm                    e$shft            6
500eAC                   parm                    e$crew            6
500eAC                   parm                    e$nhrs            3 1
500eAC                   parm                    e$rtn             8
500eAC                   parm                    e$bpu             1
500eAC                   parm                    e$lng             2
500eAC                   if        e$rtn <> '*OK'
500eAC                   eval      e$lng = 'EN'
500eAC                   endif
500eA*
600bMC                   eval      kyitem = $iItem
416jA*
416jA*    Capture date/time user entered program to be used
416jA*    for starting transaction. This will more accurately
416jA*    reflect when the process started.
416jAC                   eval      $cvcmd = '*CURCMD '
416jAC                   exsr      zzcvdt
416jAC                   eval      trndte = $cvd8o
416jAC                   time                    trntim
417bA*
417bA*   Get screen size being used.
417bA*
510dDC*                  call      'PIRRFSCR'
510dDC*                  parm      '*GET'        #lcmd             8
510dDC*                  parm                    #lline            2
510dDC*                  parm                    #lcol             3
416bA*
416bA*   Get replenishment options from file.
416bA*
416bAC                   eval      kycode = '*REPLEN '
416bAC     opkey         chain     options                            79
416bAC                   if        *in79
416bAC                   eval      oprpex = '3'
416bAC                   eval      oprpfi = '3'
417aAC                   eval      oplmts = 'N'
416bAC                   endif
416bA*
416bAC                   eval      dspwin = '*NO '
417aAC                   eval      offlag = *off
417cAC                   eval      lottrk = '*NO '
417cAC                   eval      lictrk = '*NO '
     *
     *   Get item description.
     *
     C                   eval      w1item = *blanks
417dAC                   eval      *in64 = *off
417dAC                   eval      scanhd = *blanks
417dAC                   eval      rplqty = *zeros
600bMC     $iItem        cat       '-':1         w1item
600aMC                   exsr      zzgetpickit
600aAC                   exsr      zzgetfromit
600dA*
600dA*    Get pick slot information
600aAC                   exsr      zzgetpicksl
417dA*
417dA*    Breakdown item. Load base item into display.
600aMC                   if        #homeittype = 'B'
417dAC                   eval      scanhd = 'Brkdwn'
417dAC                   eval      *in64 = *on
600aMC                   eval      kyitem = #fromititem
600aMC                   eval      w1item = #fromititem
417dAC                   endif
417dA*
600aDC**   w1item        cat       itdesc:1      w1item
600aMC                   eval      w1item = %trim(w1item)
600aMC                                    + ' ' + #fromitdesc
     *
416bAC                   eval      $cvcmd = '*CURCMD '
416bAC                   exsr      zzcvdt
416bAC                   eval      today = $cvd8o
416bA*
720bA*   If a Pick Slot was scanned check to see if it lives in Store
720bA*   if this customer uses Staging Replenishment
720bA*
720bAc                   if        %parms>=9 and $ilcnsdisp<>' '
720bAc                   else
720bAc                   if        opsslcn = 'Y'
720bA*   Check slot to see if it lives in the store/remote location
720bAC                   eval      savever# = $zdver#
720bAC                   clear                   $zoned
720bAC                   eval      $zdver# = savever#
720bA
720bAc*  zdtsttruk can be complete name of specific Truck in Zoned or just a portion
720bAc*  I am sending only ! which is first character since we do not have way to pass
720bAc*  desired zones currently.  This will read in any definitions beginning with !
720bAC                   eval      $zdtsttruku = *on
720bAC                   eval      $zdtsttruk = '!'
720bAC                   eval      $zdwhseu = *on
720bAC                   eval      $zdwhse = $iWhse
720bA
720bAc                   eval      $zdwhdpu = *on
720bAc                   eval      $zdwhdp = $iwhdp
720bAc
720bAc*  By sending in either Case ITem , Breakdown Item or Case Pick Slot, Breakdown
720bAc*  pick slot command STRZONE in DRIZONED returns both pick slots along with
720bAc*  any overflow slots found in Store Zone and flag zdstgflg as "Y" for yes.  If not
720bAc*  found in Store zone passed it returns all blanks with flag zdstgflg='N'
720bAc                   select
720bAc                   when      frm$Slot.$sldisp <> *blanks
720bAc                   if        #homeittype='B'
720bAc                   eval      $zdstrbpcku = *on
720bAc                   eval      $zdstrbpck = frm$Slot.$sldisp
720bAc                   else
720bAc                   eval      $zdstrcpcku = *on
720bAc                   eval      $zdstrcpck = frm$Slot.$sldisp
720bAc                   endif
720bAc                   other
720bAc                   if        #homeittype = 'B'
720bAc                   eval      $zdstrcpcku = *off
720bAc                   eval      $zdstrcpck = ' '
720bAc                   eval      $zdstrbpcku = *on
720bAc                   eval      $zdstrbpck = frm$Slot.$sldisp
720bAc                   eval      $zdstrbitmu = *on
720bAc                   eval      $zdstrbitm = #homeitmitem
720bAc                   eval      $zdstrcitmu = *off
720bAc                   eval      $zdstrcitm = *blanks
720bAc                   else
720bAc                   eval      $zdstrcpcku = *on
720bAc                   eval      $zdstrcpck = frm$Slot.$sldisp
720bAc                   eval      $zdstrcitmu = *on
720bAc                   eval      $zdstrcitm = #homeititem
720bAc                   eval      $zdstrbitmu = *off
720bAc                   eval      $zdstrbitm = *blanks
720bAc                   endif
720bAc                   endsl
720bA
720bAc                   eval      $drisubcmd = '%STRZONE'
720bAC                   eval      $dricommand = '*ZONED'
720bAc                   exsr      zzzDriCop
720bAc                   endif
720bAc                   endif
720bA*
     C                   exsr      clrsch
     C                   exsr      scr01i
610fAC                   exsr      phpgmV1V2V3e
     C                   endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZCKRT  Check if replenishment is pulled in FIFO order.
416bA*
416bAC     zzckrt        begsr
416bA*
416bAC                   eval      dspwin = '*NO '
600cA
600cAC                   exsr      clr$slot
600cAC                   eval      $slot = frm$slot
600cAC                   eval      $slot2 = frm$slot2
600cAC                   eval      $slwhseu = *on
600cAC                   eval      $slitemu = *on
600cAC                   eval      $slstatu = *on
600cAC                   eval      $slstypu = *on
600cAC                   eval      $slwhdpu = *on
600cAC                   eval      $sldispu = *on
600cAC                   eval      $slaislu = *on
600cAC                   eval      $slpsequ = *on
600cAC                   eval      $slrlvlu = *on
600cAC                   eval      $slhandu = *on
600cAC                   eval      $slprtyu = *on
600cAC                   eval      $slexpdu = *on
600cAC                   eval      $slentdu = *on
600cA
600cAC                   eval      $dricommand = '*SLOT'
600cAC                   eval      $drisubcmd  = '%CHKFIFO'
600cAC                   eval      $drisys2upd = 'D'
600cAC                   eval      chk4err = *off
600cAC                   eval      zmsflag = *off
600cAC                   exsr      zzzdricop
600cA
600cAC                   If        $drireturn = 'NOTFIFO'
600cAC                   eval      dspwin = '*YES'
600cAC                   endif

416bA*
600cDC**                 eval      keysta = frm$slot.$slstat
600cDC**                 eval      kypick = 'N'
600cDC**                 eval      kyprty = frm$slot.$slprty
600cDC**                 eval      kyexpd = frm$slot.$slexpd
600cDC**
600cDC**                 eval      ckexpd = frm$slot.$slexpd
600cDC**
600cDC**   slky3a        setll     slot3
600cDC**   slky3b        readpe    slot3                                  79
600cDC**                 select
600cDC**   No other slots found - slot ok for replenishment.
600cDC**                 when      *in79
600cDC**                 eval      slstk1 = *zeros
600cDC**                 eval      slstk2 = *zeros
600cDC**                 eval      slstk3 = *zeros
600cDC**                 eval      slexpd = *zeros
600cDC**
600cDC**   Older product found, not expired. Display warning.
600cDC**                 when      slstat = 'A '  and
600cDC**                           slexpd < ckexpd  and
600cDC**                           slexpd > *zeros  and
600cDC**                           slexpd >= tstdte
600cDC**                 eval      dspwin = '*YES'
600cDC**                 endsl

416bAC                   endsr
RYLbDC**---------------------------------------------------------------
RYLbDC** ZZCKRT2 Check if replenishment is pulled in FIFO order.
RYLbDC**---------------------------------------------------------------
RYLbDC**
RYLbDC**   zzckrt2       begsr
RYLbDC**
RYLbDC**                 eval      dspwin = '*NO '
RYLbDC**
RYLbDC**                 eval      kypick = 'N'
RYLbDC**                 eval      keysta = frm$slot.$slstat
RYLbDC**                 eval      kyentd = frm$slot.$slentd
RYLbDC**                 eval      kyprty = frm$slot.$slprty
RYLbDC**
RYLbDC**                 eval      ckentd = frm$slot.$slentd
RYLbDC**
RYLbDC**   slky3c        setll     slot10
RYLbDC**   slky3b        readpe    slot10
RYLbDC**                 select
RYLbDC**
RYLbDC**   No other slots found - slot ok for replenishment.
RYLbDC**                 when      %eof(slot10)
RYLbDC**                 eval      slstk1 = *zeros
RYLbDC**                 eval      slstk2 = *zeros
RYLbDC**                 eval      slstk3 = *zeros
RYLbDC**                 eval      slentd = *zeros
RYLbDC**                 eval      slexpd = *zeros
RYLbDC**
RYLbDC**   Older product found, Display warning.
RYLbDC**                 when      slstat = 'A '  and
RYLbDC**                           slentd < ckentd  and
RYLbDC**                           slentd > *zeros  and
RYLbDC**                           slentd >= tstdte
RYLbDC**                 eval      dspwin = '*YES'
RYLbDC**                 endsl
RYLbDC**
RYLbDC**                 endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZCVDT  Convert date to proper format.
416bA*
416bAC     zzcvdt        begsr
416bA*
416bA*    Convert date into proper format.
416bA*
416bAC                   call      @cvtdt
416bAC                   parm                    $cvtdt
416bA*
416bAC     endcvd        endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZEXCP Write item exception record to file.
416bA*
416bAC     zzexcp        begsr
416bA*
416bA*    Write an item exception record.
600aMC                   eval      exwhse = frm$slot.$slwhse
416fD*R                   MOVE $PWHDP    EXWHDP
600aMC                   eval      exwhdp = frm$slot.$slwhdp
600aMC                   eval      exstyp = frm$slot.$slstyp
600aMC                   eval      exitem = #homeititem
600bMC                   eval      extdis = $iHome
650 A*
650 AC                   if        frm$slot.$slstk1 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
600aMC                   eval      exqty = frm$slot.$slstk1
650 AC                   endif
650 A*
416bAC                   eval      extask = 'REPL  '
510bA*    Update 'exception from slot' with virtual slot if it exists.
640cDC*                  if        fvslot = *on
640cDC*                  eval      exfdis = hldvsl
640cDC*                  else
600aMC                   eval      exfdis = frm$slot.$sldisp
640cDC*                  endif
416bA*    Get todays date.
416bAC                   eval      $cvcmd = '*CURCMD '
416bAC                   exsr      zzcvdt
416bAC                   eval      exgdte = $cvd8o
416bAC                   time                    exgtim
416bAC                   eval      exgby = #user
416bAC                   eval      exesta = '1 '
416bAC     exkey         setll     itmexcp                                79
416bA*
416bA*    Loop to generate unique timestamp for item exception.
416bAC                   dow       *in79
416bAC                   add       1             exgtim
416bAC     exkey         setll     itmexcp                                79
416bAC                   enddo
416bA*
416bAC                   write     exrec
416bA*
416bAC     endexc        endsr
416iA*----------------------------------------------------------------
416iA*
416iA*  ZZEXSL Write slot exception record to file.
416iA*
416iAC     zzexsl        begsr
416iA*
416iA*    Write a slot exception record. This will prevent slot
416iA*    from being selected for another letdown transaction.
416iA*
600aMC                   eval      xsewhse = frm$slot.$slwhse
600aMC                   eval      xsewhdp = frm$slot.$slwhdp
600aMC                   eval      xsedisp = frm$slot.$sldisp
600aMC                   eval      xseitem = #homeititem
416iA*    Get todays date.
416iAC                   eval      $cvcmd = '*CURCMD '
416iAC                   exsr      zzcvdt
416iAC                   eval      xseadte = $cvd8o
416iAC                   time                    xseatim
416iAC                   eval      xseaby = #user
416iAC                   write     serec                                76
416iA*
416iAC     endse         endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   slwhse
     C                   clear                   slitem
     C                   clear                   slstat
     C                   clear                   slpick
     C                   clear                   slprty
     C                   clear                   slexpd
     C                   clear                   slentd
     C                   clear                   slwhdp
     C                   clear                   slstyp
     C                   clear                   slaisl
     C                   clear                   slpseq
     C                   clear                   slrlvl
     C                   clear                   slhand
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = slwhse
     C                   eval      ukwhdp = slwhdp
     C                   eval      ukdisp = sldisp
     C                   eval      ukitem = slitem
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZOUT    User flagged item as having no overflow product to
500 A*           replenish into pick slot.
500 A*
500 AC     zzout         begsr
500 A*
500aA*    Logic for SLOTOUT file moved to RU380.
500aD*          KEYSO     CHAINSLOTOUT              79
500aD*          *IN79     IFEQ *ON
500aD*                    CLEARSOREC
500aD*
500aD*                    Z-ADD$WHSE     SOWHSE
500aD*                    MOVE ITWHDP    SOWHDP
500aD*                    MOVE $HOME     SODISP
500aD*                    MOVE $ITEM     SOITEM
500aD*
500aD* Update the datestamp field with the current time.
500aD*                    CALL 'GETTS'
500aD*                    PARM           SOADTS
500aD*                    MOVE #USER     SOABY
500aD*
500aD*                    WRITESOREC                  78
500aD*
500aD*                    ELSE
500aD*                    UNLCKSLOTOUT
500aD*
500aD*                    ENDIF
500 A*
500 A*    Change status of all Open Runner Flag entries to U=Out.
500 AC                   eval      $lcmd = '*CHG2OUT'
500 AC                   eval      $lprg = #prog
600bMC                   eval      $lwhse = $iWhse
600bMC                   eval      $lwhdp = $iWhdp
600bMC                   eval      $ldisp = $iHome
600aMC                   eval      $litm2 = $iItem
500aD*                    MOVE 'C'       $LNWST
500 A*
500 AC                   call      'RU380'
500 AC                   parm                    $lparm
500 A*
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(6)     errmsg
500eAC                   other
500 AC                   eval      errmsg = desc(6)
500eAC                   endsl
500 AC                   exsr      zm0105
500 A*
500 AC     endout        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     *R         PTINP1    IFNE 0
     *R                   Z-ADDPTINP1    ODDLIN
     *R                   Z-ADD0         PTINP1
     *R                   MOVE *ON       REPOS
     *R                   END
     C                   endsr
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
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
417cA*
414bA*----------------------------------------------------------------
414bA*
414bA*  ZZSLCT   Select a slot for replenishment.
414bA*
414bAC     zzslct        begsr
414bA*
414eMC                   eval      w1disp = ukdisp
720cAC                   eval      w1scan = ukdisp
414bAC                   exsr      zzchk1
414bAC     error         cabeq     *on           endslc
417cAC     cancel        cabeq     *on           endslc
414bA*
600bDC**                 eval      $iDisp = frm$slot.$sldisp
414bA*
414bAC                   exsr      zzstrt
600bMC                   eval      $iReturn = '*OK     '
414bA*
414bAC                   eval      nxtscr = 'EOJ'
414aA*
414bAC     endslc        endsr
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
     *
600aAC                   if        #homeittype = 'B'
600aAC                   eval      topick = 0
600aAC                   else
650bA* variable topick is set upon entry when user overrides repack
650bA* from slot.  We only move the quantity requested
650bAc                   if        not LT107_Repack
600aMC                   eval      topick = frm$slot.$slavl1
650bAc                   else
650bAc                   exsr      zzgetfromsl
650bAc                   goto      endstr
650bAc                   endif
600aAC                   endif
600fA*
600fA*  Set partial quantity flag.
600fA*
600fA*    These values were recalculated and sent back from
600fA*    the VFYTFOCHG command. If all of the original #FROM
600fA*    buckets were zero and the new Avail quantities are
600fA*    tero, then the entire quantity is being taken.
600fA*
600fAC                   if        frm$slot.$slalc1 > 0
600fAC                             or frm$slot.$slalc2 > 0
600fAC                             or frm$slot.$slalc3 > 0
600fAC                             or frm$slot.$slpck1 > 0
600fAC                             or frm$slot.$slpck2 > 0
600fAC                             or frm$slot.$slpck3 > 0
740aAC                             or frm$slot.$slstk2 > 0
740aAC                             or frm$slot.$slstk3 > 0
650bAc                             or LT107_Repack and
650bAc                                topick < frm$slot.$slavl1
600fAC                   eval      partial = *on
600fAC                   else
600fAC                   eval      partial = *off
600fAC                   endif
600fA
600fA*  License plate tracking item. Update to show in transit.
600hA*    - Only if not a Breakdown replenishment.
600fA
600hAC                   if        #homeittype <> 'B'
600hA
600fAC                   exsr      zzzclr$lt210
600fAC                   eval      $tcmd     = '*PULTRAN'
600fAC                   eval      $tlic#    = frm$slot2.$saToLcns
600fAC                   eval      $tnewlic# = frm$slot2.$saToLcns
600fAC                   eval      $twhse    = $iwhse
600fAC                   eval      $titem    = #fromititem
600fAC                   eval      $titemdsc = #fromithead
600fAC                   eval      $tpartial = partial
600fAC                   eval      $tqty1    = topick
600fAC                   eval      $tqty2    = 0
600fAC                   eval      $tqty3    = 0
600fAC                   eval      $tnorm1   = topick
600fAC                   eval      $tnorm2   = 0
600fAC                   eval      $tnorm3   = 0
600fAC                   exsr      zzzcall$lt210
600fA
600fAC                   if        $treturn <> '*OK'
600fAC                   endif
600fA
600hAC                   endif
     *
     *     - Get new transaction number.
     *
     C                   call      'PIRTRN#'
600dMC                   parm                    curtrn#           7 0
     *
     *  Create label record.
     *
     C                   clear                   lbrec
600dAC                   call      'PIRLBL#'
600dAC                   parm                    lblbl#
     *
     *  FROM Slot.
600hA*    - Only if not a Breakdown replenishment.
     *
600hAC                   if        #homeittype <> 'B'
600hA
     *  Update slot qty (Increase TFR qty)  **** Already got in ZZCHK1 ****
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse = frm$slot.$slwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = frm$slot.$slwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = frm$slot.$sldisp
600aAC                   eval      $saitemu = *on
600aAC                   eval      $saitem = frm$slot.$slitem
600aAC                   eval      $sacitemu = *on
600aAC                   eval      $sacitem = #homeslitem
610aAC                   eval      $saqtyu = *on
610aAC                   eval      $saqty1 = topick
600aAC                   eval      $saqty2 = 0
600aAC                   eval      $saqty3 = 0
600aAC                   eval      $satrn#u = *on
600aAC                   eval      $satrn# = curtrn#
600aAC                   eval      $satasku = *on
600aAC                   if        #homeittype = 'B'
600aAC                   eval      $satask = 'REPLBK'
600aAC                   else
600aAC                   eval      $satask = 'REPL  '
600aAC                   endif
600aA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'RPL'
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
600aAC                   eval      $saToCode = 'U'
600aAC                   eval      $saToAreaU = *on
600aAC                   eval      $saToArea = 'User'
600aAC                   eval      $saFrmLcnsU = *on
600aAC                   eval      $saFrmLcns = $toutlic#
600aAC                   eval      $saOLcnsU = *on
600aAC                   eval      $saOLcns = frm$slot2.$saOLcns
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aDC**                 eval      $drisubcmd = '%SSOUTCHG'
600aMC                   eval      $drisubcmd = '%TFR2USR'
600aAC                   eval      chk4err = *off
600aAC                   eval      zmsflag = *off
600aAC                   if        topick > 0
600aAC                   exsr      zzzdricop
600aAC                   endif
600hA
600hAC                   endif
     *
600aA*
600aAC*                  exsr      clr$slot
600aAC*                  eval      $slwhseu = *on
600aAC*                  eval      $slwhse = #homeitwhse
600aAC*                  eval      $slwhdpu = *on
600aAC*                  eval      $slwhdp = #homeitwhdp
600aAC*                  eval      $sldispu = *on
600aAC*                  eval      $sldisp = #homesldisp
600aAC*                  eval      $slentdu = *on
600aMC*                  eval      $slentd = frm$slot.$slentd
600aAC*                  eval      $slexpdu = *on
600aMC*                  eval      $slexpd = frm$slot.$slexpd
600aAC*                  eval      $saitemu = *on
600aMC*                  eval      $saitem = #homeititem
600aAC*                  eval      $sacitemu = *on
600aAC*                  eval      $sacitem = #fromititem
600aAC*                  eval      $saqtyu = *on
600aAC*                  eval      $saqty1 = topick
600aAC*                  eval      $saqty2 = 0
600aAC*                  eval      $saqty3 = 0
600aAC*                  eval      $satrn#u = *on
600aAC*                  eval      $satrn# = $trn#
600aAC*                  eval      $satasku = *on
600aAC*                  if        #homeittype = 'B'
600aAC*                  eval      $satask = 'REPLBK'
600aAC*                  else
600aAC*                  eval      $satask = 'REPL  '
600aAC*                  endif
600aAC*                  eval      $dricommand = '*SLOT'
600aMC*                  eval      $drisubcmd = '%SSINCHG'
600aAC*                  eval      zmsflag = *off
600aAC*                  if        topick > 0
600aAC*                  exsr      zzzdricop
600aAC*                  endif
     *
     *     - Get new batch number.
     *
     C                   call      'PIRBAT#'
     C                   parm                    batch#            7 0
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = batch#
     C                   eval      btwhse = slwhse
     C                   eval      bttype = '*REPLEN '
     C                   eval      btstat = *blanks
     C                   eval      btrte = *blanks
     C                   eval      btstrd = today
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
     *
     *  Create label record (initialized above)
     *
600aMC                   eval      lbwhse = frm$slot.$slwhse
600aMC                   eval      lbwhdp = frm$slot.$slwhdp
600aMC                   eval      lbaisl = frm$slot.$slaisl
600aMC                   eval      lbloc = frm$slot.$slloc
600aMC                   eval      lbrlvl = frm$slot.$slrlvl
600aMC                   eval      lbhand = frm$slot.$slhand
600aMC                   eval      lbdisp = frm$slot.$sldisp
600aMC                   eval      lbpseq = frm$slot.$slpseq
600aMC                   eval      lbstyp = frm$slot.$slstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
600aMC                   eval      lbqavl = frm$slot.$slavl1
     *
600aMC                   eval      lbwhs2 = #homeslwhse
600aMC                   eval      lbwhd2 = #homeslwhdp
600aMC                   eval      lbasl2 = #homeslaisl
600aMC                   eval      lbloc2 = #homeslloc
600aMC                   eval      lblvl2 = #homeslrlvl
600aMC                   eval      lbhnd2 = #homeslhand
600aMC                   eval      lbdsp2 = #homesldisp
     *
     C                   eval      lbrte = *blanks
640aDC**                 eval      lbitem = frm$slot.$slitem
640aMC                   eval      lbitem = #homeititem
     C                   eval      lbpbat = batch#
     C                   eval      lbutyp = 'N'
600aMC                   eval      lbucod = #fromitum1
     *
     *  Quantity remaining field is used to contain break down
     *  quantity for broken case item.
     *
600aMC                   if        #homeittype = 'B'
600aDC**                 eval      lbqrmn = repqty
600aMC                   eval      lbqrmn = topick * #fromitumq2
417dAC                   else
     C                   eval      lbqrmn = 0
417dAC                   endif
     C                   eval      lbqalc = topick
     C                   eval      lbqpck = topick
     *
600aMC                   if        #homeittype = 'B'  and
600aMC                             #fromitumq2 > 0
600aMC     #fromitcube   div       #fromitumq2   eacube
600aMC     #fromitswgt   div       #fromitumq2   easwgt
600aMC                   endif
     *
600aMC                   if        #homeittype = 'B'
417dAC                   eval      lbucub = eacube
417dAC                   else
600aMC                   eval      lbucub = #fromitcube
417dAC                   endif
     C     lbucub        mult      topick        lbcube
600aMC                   if        #homeittype = 'B'
417dAC                   eval      lbuwgt = easwgt
417dAC                   else
600aMC                   eval      lbuwgt = #fromitswgt
417dAC                   endif
     C     lbuwgt        mult      topick        lbswgt
600bMC                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
600aD **    - Get new label number.
600aDC**                 call      'PIRLBL#'
600aDC**                 parm                    lblbl#
600aDC**                 eval      $lbl# = lblbl#
     C                   eval      lbgrp1 = 'L'
     C                   eval      lbgrp2 = ' '
     C                   eval      lbtype = 'R'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
600aA*
600aA*  Create and start transaction.
600aA*
600aAC                   exsr      zztrncrtstart
600eA*
600eA*  Create workusr record
600eA*
600eAC                   exsr      zzwrtwrkusr
     *
     C     endstr        endsr

600aA*----------------------------------------------------------------
600aA*  ZZTRNCRTSTART  Create and Start transaction
600aA*----------------------------------------------------------------
600aA
600aAC     zztrncrtstart begsr

     C                   if        #homeittype = 'B'
     C                   eval      @ptask = 'REPLBK'
     C                   else
     C                   eval      @ptask = 'REPL  '
     C                   endif

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      lbwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      trndte        @pdate            8 0
     C                   parm      trntim        @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZWARN   Display Error Message if slot has date/FIFO issues.
416bA*
416bAC     zzwarn        begsr
416bAC                   eval      wotxt1 = *blanks
416bAC                   eval      wotxt2 = *blanks
416bAC                   eval      wotxt3 = *blanks
416bAC                   eval      wotxt4 = *blanks
SVLaAC                   if        client = saval
SVLaAC                   eval      woyn = '(1/9)'
610aAC                   else
610aAC                   eval      woyn = '(Y/N)'
SVLaAC                   endif
     *
416bA*
416bA*    Load warning message into window text fields.
416bAC                   select
416bAC                   when      msgtyp = '*EXPIRED'
416bA*
600aMC                   eval      wkexpd = frm$slot.$slexpd
416bAC                   select
416bA*    User not allowed to select expired product.
416bAC                   when      oprpex = '2'
416bA*    Reply to message not allowed. (40=Off)
416bAC                   eval      *in40 = *off
510cAC                   select
510cAC                   when      e$lng = 'SP'
416bAC                   movel     msg101        wotxt1
416bAC                   movel     msg102        wotxt2
416bAC     msg103        cat       wkmm:1        wotxt3
510cAC                   other
510cAC                   movel     msg101e       wotxt1
510cAC                   movel     msg102e       wotxt2
510cAC     msg103e       cat       wkmm:1        wotxt3
510cAC                   endsl
416bAC     wotxt3        cat       '/':0         wotxt3
416bAC     wotxt3        cat       wkdd:0        wotxt3
416bAC     wotxt3        cat       '/':0         wotxt3
416bAC     wotxt3        cat       wkyy:0        wotxt3
416bAC     wotxt3        cat       '.':0         wotxt3
510cAC                   select
510cAC                   when      e$lng = 'SP'
416bAC                   movel     msg104        wotxt4
510cAC                   other
510cAC                   movel     msg104e       wotxt4
510cAC                   endsl
416bA*
416bA*    User must be warned when selecting expired product.
416bAC                   when      oprpex = '3'
416bA*    Reply to message allowed. (40=On)
416bAC                   eval      *in40 = *on
510cAC                   select
510cAC                   when      e$lng = 'SP'
416bAC                   movel     msg201        wotxt2
416bAC     msg202        cat       wkmm:1        wotxt3
510cAC                   other
510cAC                   movel     msg201e       wotxt2
510cAC     msg202e       cat       wkmm:1        wotxt3
510cAC                   endsl
416bAC     wotxt3        cat       '/':0         wotxt3
416bAC     wotxt3        cat       wkdd:0        wotxt3
416bAC     wotxt3        cat       '/':0         wotxt3
416bAC     wotxt3        cat       wkyy:0        wotxt3
416bAC     wotxt3        cat       '.':0         wotxt3
416bA*
416bAC                   endsl
416bA*
416bAC                   when      msgtyp = '*FIFO   '
416bA*
416bAC                   select
416bA*
416bA*   User must be warned when selecting product out of FIFO rotation.
416bAC                   when      oprpfi = '3'
416bA*    Reply to message allowed. (40=On)
416bAC                   eval      *in40 = *on
510cAC                   select
510cAC                   when      e$lng = 'SP'
416bAC                   movel     msg301        wotxt2
416bAC                   movel     msg302        wotxt3
510cAC                   other
510cAC                   movel     msg301e       wotxt2
510cAC                   movel     msg302e       wotxt3
510cAC                   endsl
416bA*
416bAC                   endsl
416bA*
416bAC                   endsl
416bA*
416bA*    Display warning message to user.
416bA*
SVLa C                   if        client = saval
SVLaAC                   eval      woyes = '9'
SVLa C                   else
416bAC                   eval      woyes = 'N'
SVLa C                   endif
416bAC                   dow       forevr = forevr
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     wdwmsgsp
500eAC                   other
416bAC                   exfmt     wdwmsg
500eAC                   endsl
416bAC                   select
416bA*    F3/F12 selected - Cancel selection.
416bAC                   when      *inkc  or
416bAC                             *inkl
416bAC                   eval      w1disp = *blanks
720cAC                   eval      w1scan = *blanks
720aAC                   eval      $ilcnsdisp = *blanks
416bAC                   eval      error = *on
416bAC                   leave
416bA*
416bA*    Reply to warning is active.
416bAC                   when      *in40
416bA*
416bAC                   select
416bA*    User chose to continue and override warning. Log exception.
416bAC                   when      woyes = 'Y'
SVLaAC                             or woyes = '1'
416bAC                   select
416bAC                   when      msgtyp = '*EXPIRED'
416bAC                   eval      exerid = 'SLTEXPD'
416bAC                   when      msgtyp = '*FIFO   '
416bAC                   eval      exerid = 'FIFOROT'
416bAC                   endsl
416bA*
416bA*    Write out exception record.
416bAC                   exsr      zzexcp
416bA*
416bA*    User chose to NOT to continue. Return to display.
416bAC                   when      woyes = 'N'
SVLaAC                             or woyes = '9'
416bAC                   eval      error = *on
416bAC                   eval      w1disp = *blanks
720cAC                   eval      w1scan = *blanks
720aAC                   eval      $ilcnsdisp = *blanks
416bAC                   endsl
416bA*
416bAC                   leave
416bA*
416bAC                   endsl
416bAC                   enddo
416bA*
416bAC     endwrn        endsr

600bA*----------------------------------------------------------------
600bA*  ZZWRTWRKUSR   Write workusr record
600bA*----------------------------------------------------------------
600bA*
600bAC     zzwrtwrkusr   begsr

     C                   exsr      zzgetcurrstamp

     C                   eval      wurectype = 'RPL'
     C                   eval      wuscannbr = frm$slot2.$saToLcns
     C                   eval      wuscantype = 'P'
600bMC                   eval      wutrn#    = curtrn#
     C                   eval      wulbl#    = lblbl#
     C                   eval      wustat    = ' '
     C                   eval      wuwhse    = frm$slot.$slwhse

     C                   eval      wupulitem = frm$slot.$slitem
     C                   eval      wunewitem = #homeslitem

     C                   eval      wuremqty1 = topick
     C                   eval      wuremqty2 = 0
     C                   eval      wuremqty3 = 0

     C                   eval      wupullcns  = frm$slot2.$saToLcns
     C                   eval      wupulolcns = frm$slot2.$saOLcns
     C                   eval      wupulwhdp  = frm$slot.$slwhdp
600dAC                   eval      wupulbase  = frm$slot.$sacdsp
     C                   eval      wupuldisp  = frm$slot.$sldisp
     C                   eval      wupulaisl  = frm$slot.$slaisl
     C                   eval      wupulloc   = frm$slot.$slloc
     C                   eval      wupulrlvl  = frm$slot.$slrlvl
     C                   eval      wupulhand  = frm$slot.$slhand
     C                   eval      wupulcode  = 'S'
     C                   eval      wupularea  = 'Slot'
600hAC                   if        #homeittype = 'B'
600hAC                   eval      wupulpos   = 0
600hAC                   else
     C                   eval      wupulpos   = $tslotpos
600hAC                   endif
     C                   eval      wupulpseq  = frm$slot.$slpseq
     C                   eval      wupulside  = frm$slot.$slside
     C                   eval      wupulutype = lbutyp
600hAC                   if        #homeittype = 'B'
600hMC                   eval      wupulvfy   = ' '
600hAC                   else
600gMC                   eval      wupulvfy   = $saFrmEmpty
600hAC                   endif

600fDC**                 eval      wuusrlcns  = $tinlic#
600hAC                   if        #homeittype = 'B'
600hAC                   eval      wuusrlcns  = ' '
600hAC                   eval      wuusrwhdp  = ' '
600hAC                   eval      wuusrdisp  = ' '
600hAC                   else
600fMC                   eval      wuusrlcns  = $saToLcns
     C                   eval      wuusrwhdp  = $slwhdp
     C                   eval      wuusrdisp  = $sldisp
600hAC                   endif

     C                   eval      wupckwhdp  = #homeslwhdp
     C                   eval      wupckdisp  = #homesldisp
     C                   eval      wupckaisl  = ' '
     C                   eval      wupckloc   = 0
     C                   eval      wupckrlvl  = 0
     C                   eval      wupckhand  = ' '
     C                   eval      wupckcode  = 'S'
     C                   eval      wupckarea  = 'Slot'
     C                   eval      wupckpos   = 0
     C                   eval      wupckpseq  = 0
     C                   eval      wupckside  = 0
     C                   eval      wupckutype = ' '

     C                   eval      wurtnhome  = ' '
600hAC                   if        #homeittype = 'B'
600hAC                   eval      wurpltype  = 'B'
600hAC                   else
     C                   eval      wurpltype  = ' '
600hAC                   endif

     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = e$emp#
     C                   eval      wuaddeusr = #curruser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr

     C                   write     wurec

     C                   endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
600aAC                   eval      $saemp#U = *on
600aAC                   eval      $saemp# = e$emp#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slotdef  Clear $slotdef data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdriclose   Close any open files or programs.
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdriclose   begsr

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

     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
720bAC                   when      $dricommand = '*ZONED'
720bAC                   eval      $dridata = $zoned
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
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
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
720bAC                   when      $dricommand = '*ZONED'
720bAC                   eval      $zoned = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

710aA*----------------------------------------------------------------
710aA*  zzChgRpl     -  User changed replenishment in LT210
710aA*----------------------------------------------------------------
710aA
      /free
       begsr zzChgRpl;
         Exsr clr$slot;
         Eval $slwhseu = *on;
         Eval $slwhse  = frm$slot.$slwhse;
         Eval $slwhdpu = *on;
         Eval $slwhdp  = frm$slot.$slwhdp;
         Eval $sldispu = *on;
         Eval $sldisp  = frm$slot.$sldisp;
         Eval $dricommand = '*SLOT';
         Eval $drisubcmd  = '%GET';
         Eval $drisys2upd = 'D';
         Exsr zzzdricop;
         Eval frm$slot=$slot;
         Eval frm$slot2=$slot2;
       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
600aA*----------------------------------------------------------------
600a
600aAC     ZZZCLR$LT210  begsr

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
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

600aA*----------------------------------------------------------------
600aA*  ZZZCALL$LT210  -  Call LT210 program.
600aA*----------------------------------------------------------------
600a
600aAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'RPL'         $ttype
     C                   parm      'Replenish'   $thead
600bMC                   parm      $iWhse        $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm                    $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   endsr

610fA*----------------------------------------------------------------
610fA*----------------------------------------------------------------
610fA*  Phrase Routines
610fA*----------------------------------------------------------------
610fA*----------------------------------------------------------------

610fA*----------------------------------------------------------------
610fA*  pushRoutine  -  Add routine to stack
610fA*----------------------------------------------------------------
610fA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  popRoutine  -  Remove routine from stack
610fA*----------------------------------------------------------------
610fA
      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  phClearVars  - Clear phrase variables
610fA*----------------------------------------------------------------
610fA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


610fA*----------------------------------------------------------------
610fA*  zzWrtPhrase  - Write logging phrase
610fA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = 0;
         pEmp# = e$emp#;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = ' ';
         pWhdp = ' ';
         pLocation = ' ';
         pTrn# = 0;
         pLcns = ' ';
         pLtrn = 0;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free

         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  phV2onV1
610fA*----------------------------------------------------------------
610fA
      /free
       begsr phV2onV1;

         pPhraseId = V2onV1;

         exsr phClearVars;
         v1 = nxtscr;

         select;
           when status = rollup;
             v2 = 'PageDn';
           when status = rolldn;
             v2 = 'PageUp';
           when status = comand;
             select;
               when *inka;
                 v2 = 'F1';
               when *inkb;
                 v2 = 'F2';
               when *inkc;
                 v2 = 'F3';
               when *inkd;
                 v2 = 'F4';
               when *inke;
                 v2 = 'F5';
               when *inkf;
                 v2 = 'F6';
               when *inkg;
                 v2 = 'F7';
               when *inkh;
                 v2 = 'F8';
               when *inki;
                 v2 = 'F9';
               when *inkj;
                 v2 = 'F10';
               when *inkk;
                 v2 = 'F11';
               when *inkl;
                 v2 = 'F12';
               when *inkm;
                 v2 = 'F13';
               when *inkn;
                 v2 = 'F14';
               when *inkp;
                 v2 = 'F15';
               when *inkq;
                 v2 = 'F16';
               when *inkr;
                 v2 = 'F17';
               when *inks;
                 v2 = 'F18';
               when *inkt;
                 v2 = 'F19';
               when *inku;
                 v2 = 'F20';
               when *inkv;
                 v2 = 'F21';
               when *inkw;
                 v2 = 'F22';
               when *inkx;
                 v2 = 'F23';
               when *inky;
                 v2 = 'F24';
               other;
                 v2 = 'Unknown Command Key';
             endsl;
           other;
             v2 = 'ENTER';
         endsl;

         exsr phWrtPhrase;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  phScrV1pgmV2
610fA*----------------------------------------------------------------
610fA
      /free
       begsr phScrV1pgmV2;

         pPhraseId = scrV1pgmV2;

         exsr phClearVars;

         v1 = nxtscr;
         select;
           when nxtscr <> lastnxtscr;
             v2 = 'displayed';
           when error = *on;
             v2 = 'redisplayed with error';
           when warn = *on;
             v2 = 'redisplayed with warning';
           other;
             v2 = 'redisplayed';
         endsl;
         lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  phPgmV1V2V3e
610fA*----------------------------------------------------------------
610fA
      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*  phPgmV1V2V3s
610fA*----------------------------------------------------------------
610fA
      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 9 X S
**  OPTLN - Option display line
  1=Select  9=View Slot Quantities
**  CMDLN - Command display line
F10=Out F11=Tfr F9=View F8=Lic inf F3/F12=Exit
**  CMDCW - Command display line
F10=Out F11=Tfr F9=View F5=Refresh F8=Lic F3/F12=Exit
**  DESC - Description
Available Quantity
Verify Zero
Pick slot not allowed for replenishment.
1=Select can be used only once.
Slot error logged for slot:
Item flagged as Out.
Replenish from same slot not allowed.
**  OPTLSP - Option display line
  1=Seleccionar  9=Ver cantidades de slot
**  CMDLSP - Command display line
F3/F12=Salir F5=Refrescar F8=Info de licencia F10=Vacio F9=View
**  DESCSP - Description
Cantidad Disponible
Verifique nada
No permite pick slot por reaprovisionamiento
Puede usar 1=Seleccionar solamente una vez
Archivo` error de slot:
Producto marcado como vacio
Reponer a partir misma ranura no permitido
