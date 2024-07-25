     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SI275     FTP StuffIt Import 3 - Post
     *  27 June 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  NOTES:
     *      - Must compile at V5R2 or greater
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/27/05  MLB  5.00
     *      - Created
500aA*    08/12/05  MLB  5.00a
     *      - Fix: Revised proram to only verify item number when sent
     *        with slot. Revised program to not update Entered Date
     *        unless item number sent with slot.
500bA*    08/17/05  MLB  5.00b
     *      - Enh: Added client custom code support.
500cA*    08/18/05  MLB  5.00c
     *      - Enh: Picking Priority (SIPRTY) field added to IMPFSTUF3.
     *        Revised program to update SLPRTY with the imported value.
500dA*    08/18/05  MLB  5.00d
     *      - Enh: Revised program to not process any items that are
     *        sent without a slot.
500eA*    08/22/05  MLB  5.00e
     *      - Fix: Revised ZZSSB to set SSBFLG=On on good return to find
     *        SSB item attached to item being imported.
500fA*    08/25/05  MLB  5.00f
     *      - Enh: Revised ZZCKNS to do a SETLL to SLOT2 to test for
     *        existance of slot. If not found, create new virtual slot.
500gA*    11/01/05  MLB  5.00g
     *      - Enh: Revised program to call WD900 to validiate warehouse
     *        department sent with slot.
500hA*    11/08/05  MLB  5.00h
     *      - Enh: Revised program to call WD900 with new cmd *VERIFYB.
500iA*    11/29/05  MLB  5.00i
     *      - Enh: Revised program to add support for maintaining Slot
     *        Check Digits.
     *      - Added file SLOTDGT to program.
     *
510 A*    03/22/07  MLB  5.10
     *      - Enh: Revised program to allow Item Type R=Repack item to
     *        be populated into the SLOT file.
510aA*    04/21/07  MLB  5.10a
     *     - Fix: Revised program to add (e) to write statement for
     *       SLOT and VSLOT files to prevent duplicate key errors.
     *
520 A*    04/30/09  MLB  5.20
     *      - Fix: Revised routine ZZUPD to clear SLREC format when
     *        adding a new virtual slot. Quantity from transfer/receive
     *        buckets were being carried over to new slot record from
     *        prior reads done in the program.
520aA*    06/15/09  MLB  5.20a
     *      - Fix: Revised routine ZZUPD to correctly set SLPICK when
     *        creating new virtual slots.
     *
530 A*    01/18/10  MLB  5.30
     *     - Fix: Revised routine ZZBKDN to add SIITEM > blanks when
     *       testing all import qty fields = 0 before allowing GOOD1
     *       flag to be set to Y=Yes.
     *
600aA*    03/01/09  DAS  6.00a  P#00065
     *     - Enh: Revised to call LT001 at the end of the program to
     *       to sychronize licsense plate qty's with slot qtys.
     *
600bA*    05/18/09  DAS  6.00b
     *     - Enh: Added DRICOP routines to be used for creating
     *       some slots for SGC.
     *
650a *    10/09/14  RTR  6.50a
     *     - Fix: Add 1 to "Not Updated" total when record
     *       skipped after breakdown qty check, and if error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
     *
USF A*    08/17/05  MLB  USF
     *      - Revised program to count number of items in 3 default
     *        slots and when count reaches 704, increment default
     *        slot counter for that slot and append to end of slot.
USFaA*    08/25/05  MLB  USFa
     *      - Enh: Revised ZZCKNS to not reset Index K for every slot
     *        when processing 3 default slots: DIREC, ZQUIP and ZVIRD.
     *        Leaving Index K at previous value will reduce time spent
     *        finding next unused slot.
USFbA*    08/29/05  MLB  USFb
     *      - Enh: Revised ZZCKSL to force each item in a slot into its
     *        own virtual slot. No combining quantities for an item in
     *        the same slot with the same dates.
USFcA*    01/26/06  MLB  USFc
     *      - Enh: Added support to program to call  when doing write
     *        to SLOT2 file to handle duplicate key errors.
USFdA*    01/26/06  MLB USFd
     *      - Enh: Revised program to add support for A-Sys slots.
     *        Routine crtslot_asys will be created to process the new
     *        slot formats.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett
     *
ELL A*    04/21/07  MLB  ELL
     *      - Revised program to add new routine CRTSLOT4 to create
     *        slots based on ELL's format.
ELL1A*    05/02/07  MLB  ELL1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: GSC
     *
GSC A*    10/31/05  MLB  GSC
     *      - Revised program to add new routine CRTSLOT2 to create
     *        slots based on GSC's format.
GSC1A*    12/27/05  MLB  GSC1
     *      - Revised program to not run routine ZZCKDGT.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Wholesale
     *
HAR A*    03/20/06  MLB  HAR
     *      - Revised program to add new routine CRTSLOT3 to create
     *        slots based on Harbor's format.
HAR1A*    04/12/06  MLB  HAR1
     *      - Revised program to add check for rack levels extracted
     *        from import slot fields >= 9 and force level to 8.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    06/04/08  MLB  JOR
     *      - Revised program to add new routine CRTSLOT10 to create
     *        slots in CLR dept. in Dakota format. No adding of
     *        additional pad to rack level or slot location.
JOR1A*    10/31/08  MLB  JOR1
     *      - Revised routine to create slots with single character
     *        aisles. And add 200 to slot location and pick sequence.
JOR2A*    10/31/08  MLB  JOR2
     *      - Revised routine to create slots with handstack as normal
     *        slots instead of virtual slots.
JOR3A*    10/31/08  MLB  JOR3
     *      - Revised program to skip to just before slot check digit
     *        update instead of going to PRTDTL tag.
JOR4A*    11/14/08  MLB  JOR4
     *      - Revised program to add support for retrieving double
     *        digit rack level values from imported slot.
JOR5A*    04/06/11  MLB  JOR5
     *      - Revised program to import new trailer slots with embedded
     *        dashes. Create slots without embedded dashes.
     *      - Revised program to bypass running LT001.
     *      - Revised program to execute ZZCDGT for new slots.
JOR6A*    09/11/13  MLB  JOR6
     *      - Fix: Revised JOR3 mod. Mod was causing slot/item update
     *        processing to be bypassed for all other clients.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPC A*    03/24/07  MLB  TPC
     *      - Revised program to create slots based on TPC format.
TPCaA*    01/28/17  MLB  TPCa
     *      - Revised program to not call LT001 since TPC is loading
     *        only empty slots.
TPCbA*    02/10/17  MLB  TPCb
     *      - Revised program to update SLBLD = NW for new created slots
     *        to more easily identify new slots.
TPCcA*    01/16/18  MLB  TPCc
     *      - Revised program turn off HANDSTACK variable. Slots with hand-
     *        stack are going to be base slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery Co.
     *
SGC A*    04/29/07  MLB  SGC
     *      - Revised program to add new routine CRTSLOT5 to create
     *        slots based on SGC's format.
SGC1A*    05/02/07  MLB  SGC1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
SGCaA*    05/31/07  MLB  SGCa
     *      - Revised program to handle all character slots.
     *      - Add 1 to rack level for all slots.
SGCbA*    05/12/09  MLB  SGCb
     *      - Revised program to load SLEXPD from SIFIFO for date
     *        sensitive items.
SGCcA*    05/18/09  DAS  SGCc
     *      - Revised to create Willow/Kansas slots using DRISLOT.
SGCdA*    02/15/10 MLBS  SGCd
     *      - Revised CRTSLOT5 to map SGC's slots using new format.
     *        Ex: CA100 where CA=Aisle, 1=Level, 00=Location.
     *      - Revised not execute the call to LT001. The slots being
     *        imported are empty, so no need to run LT001.
SGCeA*    02/18/10 MLBS  SGCe
     *      - Revised CRTSLOT5 to map SGC's slots using new format.
     *        Ex: CA100A where CA=Aisle, 1=Level, 00=Location, A=Hndstk
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CWH A*    09/20/07  RBD  CWH
     *      - Revised program to add new routine CRTSLOT6 to create
     *        slots based on CWH's format.
CWHaA*    09/28/07  RBD  CWHa
     *      - Revised to take division from rightmost bytes of dept
     *        and prefix slot with them.  Also, remove division from
     *        department.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    04/21/08  CWM  FRF
     *      - Revised program to add new routine CRTSLOT7 to create
     *        slots based on FRF's format.
FRFaA*    04/21/08  MLB  FRFa
     *      - Revised program to check for blank in position 6 of
     *        SIDISP and then extract first 5 characters for slot disp.
FRFbA*    05/12/08  MLB  FRFb
     *      - Revised program to load import pick/reserve fields into
     *        SLPICK and SLRSRV fields.
FRFcA*    07/01/08  MLB  FRFc
     *      - Revised program to not update slot qty's when slot being
     *        processed is a 01ROCxxxxxxx slot. Qty's sent with 01ROC
     *        slots will be written out to file IMPFPCKQ file to be
     *        adjusted into the slot sent on the import. Slot item is
     *        assigned to will be sent for adjustment.
FRFdA*    07/03/08  MLB  FRFd
     *      - Revised program to call ZZRCAL routine before exiting
     *        program to update warehouse qty's.
FRFeA*    02/03/09  MLB  FRFe
     *      - Revised program to not update slot qty's when slot being
     *        processed is a 01BOLxxxxxxx slot. Qty's sent with 01BOL
     *        slots will be written out to file IMPFPCKQ file to be
     *        adjusted into the slot sent on the import. Slot, item is
     *        assigned to will be sent for adjustment.
FRFfA*    02/03/09  MLB  FRFf
     *      - Revised program to update entered date sent by host for
     *        01ROC and 01BOL base slots, if entered date=0.
FRFgA*    12/12/09  MLB  FRFg
     *      - Revised program to only open file IMPFPCKQ when $pcmd
     *        = *FRFROC.
FRFhA*    05/04/10  MLB  FRFh
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
FRFiA*    02/13/14  MLB  FRFi  P#01175
     *      - Revised program to add support for importing PIR slots.
     *        Example slot: 70011B where aisle = 70, location=01,
     *        level = 1 and handstack = B.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foodservice
     *
IFD A*    10/28/08  MLB  IFD
     *      - Revised program to create slots based on IFD format.
IFDaA*    02/03/09  MLB  IFDa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
IFDbA*    02/04/09  MLB  IFDb
     *      - Revised program to load 4 digits from slot display
     *        into slot pick sequence field, SLPSEQ. IFD needs to
     *        pick by level instead of by bay.
IFDcA*    02/05/09  MLB  IFDc
     *      - Revised program to compute slot side using first 2
     *        numeric digits of sidisp field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
     *
EGF A*    02/13/09  MLB  EGF
     *      - Revised program to create slots based on EGF format.
     *      - EG Forrest's slot format: XXYY-A-SS
     *          Where XX=Aisle, YY=Slot location, A=Rack level and
     *          SS=Position within slot location.
EGFaA*    02/13/09  MLB  EGFa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
EGFbA*    03/21/09  MLB  EGFb
     *      - Revised program to add support for slot format: nnnn
     *        where nnnn=4 digit number string.
EGFcA*    03/21/09  MLB  EGFc
     *      - Revised program to change test to seton indicator
     *        for ALLCHRSLT.
EGFdA*    05/08/09  MLB  EGFd
     *      - Revised program to add support for slot format:
     *        nnnn-x-y where nnnn=4 digit number string, x=rack level
     *        and y=subslot or handstack indicator.
EGFeA*    11/02/09  MLB  EGFe
     *      - Revised program to call ZZRCAL routine before exiting
     *        program to update warehouse qty's.
     *      - Added client to FRFd mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVL A*    03/04/09  MLB  SVL
     *      - Revised program to create slots based on SVL format.
     *      - Added SVL to IFD mod using CRTSLOT8 routine. Both
     *        clients are NDS houses.
SVLaA*    02/03/09  MLB  SVLa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
SVLbA*    03/10/09  MLB  SVLb
     *      - Removed Saval from IFD mod using CRTSLOT8 routine.
     *      - Createed new routine, CRTSLOT10 to proces Saval slots,
SVLcA*    07/19/09  MLB  SVLc
     *      - Enh: Revised CRTSLOT10 to load slot type from check
     *        digit type field in preparation for going Inbound Dakota.
SVLdA*    07/19/09  MLB  SVLd
     *      - Enh: Revised program to load dept 3 when SIWHDP=2 and
     *        1st character of SIDISP=C.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    08/19/09  MLB  HAL
     *      - Revised program to create slots based on HAL format.
HALaA*    08/19/09  MLB  HALa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
HALbA*    09/14/09  MLB  HALb
     *      - Revised program to call ZZRCAL routine before exiting
     *        program to update warehouse qty's.
     *      - Added HALb to FRFd mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
     *
CDI A*    09/19/09  MLB  CDI
     *      - Revised program to add new routine CRTSLOT11 to create
     *        slots based on CDI's format.
CDI1A*    09/19/09  MLB  CDI1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
CDI2A*    11/29/09  MLB  CDI2
     *      - Revised routine CRTSLOT11 to add support for slots
     *        then end with numeric rack level instead of alpha
     *        rack level.
CDI3A*    12/02/09  MLB  CDI3
     *      - Revised routine CRTSLOT11 to add 3 to SLRLVL when
     *        slot display ends with numeric value instead of an
     *        alpha value.
CDI4A*    02/19/10  MLB  CDI4
     *      - Revised routine CRTSLOT11 to disable CDI3 mod above.
     *        CDI converted slots to numeric rack levels from alpha
     *        rack levels. Per August W.
CDI5A*    06/04/14  MLB  CDI5
     *      - Revised routine CRTSLOT11 to add support for single
     *        digit numeric aisles. Pgm will populate SLAISL with
     *        leading zero for single digit aisles so that slots
     *        will sort correctly.
CDI6A*    11/25/14  MLB  CDI6
     *      - Revised program to not run LT001 since only creating
     *        new, empty slots. No need to update license info.
     *      - Added CDI6 to GFCg mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/01/09  MLB  DRY
     *      - Revised program to create slots based on DRY format.
     *        Created routine, CRTSLOT12.
DRY1A*    12/01/09  MLB  DRY1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
DRY2A*    02/15/10  MLB  DRY2
     *      - Revised DRY mod above to pad 1 & 2 character aisles with
     *        trailing . so that aisles will sort correctly.
DRY3A*    02/17/10  MLB  DRY3
     *      - Revised DRY mod above to pad 1 character aisles with
     *        leading zero and trailing . so the slots sort correctly.
DRY4A*    04/14/10  MLB  DRY4
     *      - Revised program to set SLLOC=0 and SLRLVL=1 when slot
     *        display has blank location/rack level. Ex: 42__________.
DRY5A*    07/09/10  MLB  DRY5
     *      - Revised to remove adding of 100 to slloc when = 0.
DRY6A*    09/22/10  MLB  DRY6
     *      - Revised to check positions 4-7 of SIDISP if > blanks,
     *        then treat as all character slot.
DRY7A*    10/04/10  MLB  DRY7
     *      - Revised CRTSLOT12 to add support for Dakota formatted
     *        slots to be imported as part of move to Inbound Dakota.
DRY8A*    10/21/10  MLB  DRY8  *Temporary Mod Until all slots converted.*
     *      - Revised CRTSLOT12 to make temporary change to how SLAISL
     *        value is populated for new slots. Single character aisles
     *        will be populated as 8.. Dbl char aisles as 18. This is
     *        done so that new slots will sort correctly with existing
     *        slots. Once all slots converted to Dakota format, then
     *        SLAISL will be converted to be padded with leading zeros.
     *        SLAISL will have 008 or 018 or 180
DRY9A*    01/28/11  MLB  DRY9
     *      - Revised CRTSLOT12 to remove all temporary code added for
     *        mod DRY8. It is no longer needed.
DRY0A*    02/18/11  MLB  DRY0
     *      - Revised program to look up pick slot using SLOT3 when
     *        SIPICK=Y and SIDISP=blnaks. Part of Inbound Dakota
     *        start-up processing.
DRYaA*    07/01/11  MLB  DRYa
     *      - Revised program to add support for slightly different
     *        slot format used at the whse 55 Hanover warehouse.
     *        Ex: bbAbb12345 where the b=blanks, A1=Aisle, 2=Rack level
     *        and 345=Location.
DRYbA*    07/01/11  MLB  DRYb
     *      - Revised program to not call LT001 since Hanover whse
     *        is starting off with Outbound Only Dakota TruckBuilder.
DRYcA*    12/20/11  MLB  DRYc
     *      - Revised program to support for new slot format, 123bbbb456
     *        where aisle = 12, location = 34 and rack level = 5 and
     *        handstack = 6. This format is for the new San Francisco
     *        warehouse, 095.
DRYdA*    12/20/11  MLB  DRYd
     *      - Revised program to add new warehouses to DRYb mod;
     *        061, 090 and 095.
DRYeA*    01/25/12  MLB  DRYe
     *      - Revised program to add support for slots with 2 digit
     *        rack levels. ex: 040-101-12A.
DRYfA*    04/14/12  MLB  DRYf
     *      - Revised program to load department code from PIRITEM file
     *        into SIWHDP if item and SIWHDP don't match. Each whse can
     *        put the item into a different department than the item is
     *        is in on the Host.
DRYgA*    11/30/12  MLB  DRYg
     *      - Revised program to no longer run cmd LT001 per Kelly R.
     *        email dated 11/29/12.
DRYhA*    05/16/13  MLB  DRYh
     *      - Revised program to support for new slot format, b11bb6b021
     *        where aisle = 11, location = 006 and rack level = 2 and
     *        and handstack = 1=A.
     *        This format is for the new Las Vegas warehouse, 098.
     *      - Added /copy ID#DRYLV to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash WA Distribution
     *
CWD A*    10/29/08  MLB  CWD
     *      - Revised program to create slots based on Cash WA format.
CWDaA*    12/06/08  MLB  CWDa
     *      - Revised program to add support to map slots sent to TB
     *        with dashes in the slot format.
CWDbA*    01/26/09  MLB  CWDb
     *      - Revised program to correct problems with how slots with
     *        handstack characters are created. Changed them to be
     *        created as permanent slots, not virtual slots.
     *      - Revised program to add support for creating slots with
     *        rack levels greater than 9.
CWDcA*    03/30/09  MLB  CWDc
     *      - Revised CRTSLOT13 to check LOCA and LVLA fields to ensure
     *        that they contain numeric values before moving them into
     *        SLLOC and SLRLVL.
CWDdA*    03/30/09  MLB  CWDd
     *      - Enhanced CWDb mod for dealing with double digit levels.
CWDeA*    12/10/09  MLB  CWDe
     *      - Enhanced CWDb mod for dealing with slots that do not have
     *        numeric location or rack levels.
     *      - Note: Changed CWD's routine to CRTSLOT13 from CRTSLOT9
     *              in order to add CWD's mods.
CWDfA*    05/05/10  MLB  CWDf
     *      - Revised program to correctly map slots with single
     *        character aisles.  For ex: E-200-2.
CWDgA*    12/20/11  MLB  CWDg
     *      - Revised routine ZZBKDN to set Good1 = Y so that check
     *        digits can be updated for the pick slots.
CWDhA*    03/27/13  MLB  CWDh
     *      - Revised routine CRTSLOT13 to set SLSDEF with value from
     *        SIDGTP if > blanks else set SLSDEF = XX.
CWDiA*    02/12/14  RTR  CWDi
     *      - Added CashWa to mod GMM1 for 5 digit checkdigit.
CWDjA*    05/14/14  MLB  CWDj
     *      - Revised program to not call LT001 since Aberdeen whse
     *        is starting off with Outbound Only Dakota TruckBuilder.
     *        and Kearney whse is full system. Loading new slots that
     *        are empty. Needed for new CLR slots being added.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Mattingly Foods
     *
MAT A*    01/25/10  MLB  MAT
     *      - Revised program to add new routine CRTSLOT15 to create
     *        slots based on Mattingly's format.
     *        Sample slot: SC035E where SC=Aisle, 035=Location and E
     *        rack level (E=5).
     *        Sample slot: TS01J where TS=Aisle, 01=Location and J=
     *        rack level (J=10).
MAT1A*    05/02/07  MLB  MAT1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFCa *    06/17/09  MLB  GFCa
     *      - Revised program to add new routine CRTSLOT21 to create
     *        slots based on Glazier's format.
GFCb *    06/17/09  MLB  GFCb
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
GFCc *    01/18/10  MLB  GFCc
     *      - Revised CRTSLOT21 to remove unconditional add of 1
     *        to rack level for all slots. Per Hemant K.
GFCd *    06/09/10  MLB  GFCd
     *      - Revised program to call ZZRCAL routine before exiting
     *        program to update warehouse qty's.
     *      - Added GFCd to FRFd mod.
GFCe *    08/22/10  MLB  GFCe
     *      - Revised CRTSLOT21 to revise how slots are mapped into
     *        Dakota from H&S.
     *        New mapping: DA-00-11 where slaisl= DA, SLLOC=000,
     *                     SLRLVL=1, SLPSEQ=001.  Where SLPSEQ will
     *                     SLLOC + last digit of slot display.
GFCf *    06/01/11  MLB  GFCf
     *      - Revised CRTSLOT21 to revise how slots are mapped into
     *        Dakota from H&S.
     *        New mapping: DA0011 where slaisl= DA, SLLOC=000,
     *                     SLRLVL=1, SLPSEQ=001.  Where SLPSEQ will
     *                     be SLLOC + last digit of slot display.
GFCg *    06/02/11  MLB  GFCg
     *      - Revised program to not run LT001 since only creating
     *        new, empty slots. No need to update license info.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods Company
     *
FFC A*    03/25/10  MLB  FFC
     *      - Revised program to add new routine CRTSLOT16 to create
     *        slots based on Fischer's format.
     *        Sample slot: 10-101-1 where 10=Aisle, 101=Location and 1
     *        rack level.
FFC1A*    03/25/10  MLB  FFC1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
FFCbA*    10/09/14  RTR  FFCb
     *      - Fixed report totals for slots added.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*    03/31/10  MLB  CCP
     *      - Revised program to add new routine CRTSLOT17 to create
     *        slots based on Capitol City's format.
     *        Sample slot: 10-10-1 where 10=Aisle, 10=Location and 1
     *        rack level.
CCP1A*    03/25/10  MLB  CCP1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    04/01/10  MLB  CSP
     *      - Revised program to add new routine CRTSLOT18 to create
     *        slots based on Coastal's format.
     *        Sample slot: 40-351A where 40=Aisle, 351=Location and A
     *        rack level (A=1).
     *        Sample slot: 40-351-1 where 40=Aisle, 351=Location and
     *        1=rack level.
CSP1A*    04/01/10  MLB  CSP1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
CSP2A*    04/19/16  MLB  CSP2
     *      - Revised program to add support for CSP's new slot format:
     *        11-112-01B where 11=Aisle, 112=Location, 01=Level and
     *        B=Hanstack.
CSP3A*    04/21/16  MLB  CSP3
     *      - Revised program to bypass running LT001.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    02/10/11  MLB  CPC
     *      - Revised program to add new routine CRTSLOT19 to create
     *        slots based on Crumbley's format.
     *        Sample slot: B8211  where B=Aisle, 82=Location and
     *        1=Rack level and 1=Handstack.
     *        New slots will have numeric aisle values. Example above
     *        will change to 128211.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas & Co.
     *
NCH A*    03/06/11  MLB  NCH
     *      - Revised program to add new routine CRTSLOT20 to create
     *        slots based on Nicholas' format.
     *        Sample slot: CD075S where CD0=Aisle, 75=Location and
     *        1=Rack level and S=Handstack. CD075S does not have
     *        a rack level specified. If it did, it would come after
     *        the 'S' in the slot. Other slots have this format:
     *        DN111R1 where DN1=Aisle, 11=Location, Rack level=1 and
     *        Handstack=R.
NCH1A*    03/06/11  MLB  NCH1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
NCH2A*    05/16/11  MLB  NCH2
     *      - Revised NCH mod above to change how part of slot is
     *        mapped into Dakota. Sample slot: CD075S where CD=Aisle,
     *        075=Location. Everything else remains the same.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: JT Davenport  *Pilot Project*
     *
JTD A*    09/24/10  MLB  JTD
     *      - Revised program to add new routine CRTSLOT22 to create
     *        slots based on European Import's format.
     *      - JTD uses Retalix PwrWhse module.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avlon Foodservice
     *
AVL A*    09/23/11  MLB  AVL
     *      - Revised program to add new routine CRTSLOT22 to create
     *        slots based on JT Davenport's format.
     *      - Added AVL to JTD mod.
     *      - AVL uses Retalix PwrWhse module.
AVLaA*    10/13/11  MLB  AVLa
     *      - Revised program to create slot check digits if entry
     *        found in table, AVASLOT1 using SIWHSE, SIWHDP.
     *      - Added file AVASLOT1 to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICB A*    02/01/12  MLB  ICB
     *      - Revised program to create slots based on ICB format.
     *      - Added ICB to IFD mod.
ICBaA*    02/01/12  MLB  ICBa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
ICBbA*    02/01/12  MLB  ICBb
     *      - Revised program to load 4 digits from slot display
     *        into slot pick sequence field, SLPSEQ. IFD needs to
     *        pick by level instead of by bay.
     *      - Added ICB to IFDb mod.
ICBcA*    02/05/09  MLB  ICBc
     *      - Revised program to compute slot side using first 2
     *        numeric digits of sidisp field.
     *      - Added ICB to IFDc mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Supply Co.
     *
ASC A*    03/22/12  MLB  ASC
     *      - Revised program to create slots based on ASC format.
     *        Agar's slot format is 12-34-56. Where aisle=12,
     *        location=34 and rlvl=56.
ASC1A*    03/26/12  MLB  ASC1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
ASC2A*    05/07/12  MLB  ASC2
     *      - Revised routine CRTSLOT23 to correct problem with mapping
     *        non-standard slot formats.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    04/03/12  MLB  HMW
     *      - Revised program to create slots based on HMW formats.
     *        Wagner's slot format is 2232D1, Where aisle=22,
     *        location=32 and rlvl=4(D=4) and Handstack=1.
     *      - New routine, CRTSLOT25 will be used for HMW.
HMWbA*    04/04/12  MLB  HMWb
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
HMWcA*    04/05/12  MLB  HMWc
     *      - Revised program to add support for new slot formats:
     *        Wagner's slot format is ZXC1A1, Where aisle=ZXC,
     *        location=1 and rlvl=1(A=1) and Handstack=1.
     *        Wagner's slot format is ZXCR1, Where aisle=ZXC,
     *        location=1 and rlvl=18(R=18) and Handstack=' '.
HMWdA*    08/27/13  MLB  HMWd
     *      - Revised program to add support for Dakota slot formats:
     *        Slot format is 02-545-1A, where aisle=02, location=545
     *        rlvl=1 and handstack=A. Routine CRTSLOT25 updated.
     *      - Mod HMWa has been disabled. No longer needed.
HMWeA*    02/05/14  MLB  HMWe
     *      - Revised to convert departments from 1,2,3 for Aspen
     *        host system.
     *      - Code from HMWa mod from pgm, SI255S deleted from pgm and
     *        replaced
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grave's Menu Maker
     *
GMM A*    04/07/12  MLB  GMM
     *      - Revised program to create slots based on GMM formats.
     *        Grave's slot format is A12-A, Where aisle=A,
     *        location=12 and rlvl=1 and Handstack=A.
     *        Grave's new slot format is AA-123-4 where aisle=AA,
     *        location=123 and rlvl=4 and Handstack=blanks.
     *      - New routine, CRTSLOT24 will be used for GMM.
GMM1A*    04/07/12  MLB  GMM1
     *      - Revised program to add support for 2nd and 3rd check digits.
     *        Added file SLOTDGTA.
GMM2A*    04/09/12  MLB  GMM2
     *      - Revised program to create slot check digits entries even
     *        if item nbr not sent.
GMM3A*    04/19/12  MLB  GMM3
     *      - Revised program to DISABLE processing of check digit
     *        entries. Per Ginger skype msg.
GMM4A*    05/02/12  MLB  GMM4
     *      - Revised program to reset DFTLOCATION counter back to 600
     *        each time dept. changes.
GMM5A*    06/04/12  MLB  GMM5
     *      - Revised program to add support for new slot format. New
     *        slot format is: R1234 where: aisle=R, location=12, rlvl=3
     *        and handstack=4
GMM6A*    07/25/12  MLB  GMM6
     *      - Revised program to load slot type code from SIDGTP field.
GMM7A*    07/25/12  MLB  GMM7
     *      - Revised CRTSLOT24 so that it would use the correct select
     *        stmt to process Dakota formatted slots.
GMM8A*    08/22/12  MLB  GMM8
     *      - Revised CRTSLOT24 to set SLDESG=SPCL if SLLOC=199.
     *        Per Roxanne skype msg on 08/22/12.
GMM9A*    11/12/12  MLB  GMM9
     *      - Revised program to only load slot type code for Jefferson
     *        whse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood.
     *
HKW A*    12/21/12  MLB  HKW
     *      - Revised program to add new routine CRTSLOT16 to create
     *        slots based on Fischer's format.
     *        Sample slot: 10-101-1 where 10=Aisle, 101=Location and 1
     *        rack level.
     *      - Added HKW to FFC mod.
HKW1A*    12/21/12  MLB  HKW1
     *      - Revised program to not run routine ZZCKDGT.
     *      - Added HKW1 to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SPI A*    12/07/12  MLB  SPI
     *      - Revised program to add new routine CRTSLOT17 to create
     *        slots based on Capitol City's format.
     *        Sample slot: 10-10-1 where 10=Aisle, 10=Location and 1
     *        rack level.
     *      - Added SPI to CCP mod.
SPI1A*    12/07/12  MLB  SPI1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart Foodservice - Agar
     *
RFS A*    01/04/13  MLB  RFS
     *      - Revised program to add new routine CRTSLOT26 to create
     *        slots based on RFS's format.
     *        Sample slot: FK-0702 where FK=Aisle, 070=Location and 2
     *        handstack. If the position after the 2 is blank, the rack
     *        level will be 1. If the position after the 2 is A-Z then
     *        the rack level will be the converted rack level + 1 which
     *        B=2 since blank or A is 1.
RFSaA*    04/04/13  MLB  RFSa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
RFSbA*    02/27/13  RTR  RFSb
     *      - Revised program to not run LT001, copy of SGCd mod.
RFScA*    02/22/15  RTR  RFSc
     *      - Revised to check for invalid level and handle error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    01/04/13  MLB  GLP
     *      - Revised program to add new routine CRTSLOT27 to create
     *        slots based on GLP's format.
     *        Sample slot: 1007-A1 where 10=Aisle, 70=Location and A=Lvl
     *        1=Handstack. If the position after the A is blank, no hand-
     *        stack is assign. If the position after the A is 1-9 then
     *        the handstack will be set 1-9.
GLPaA*    04/04/13  MLB  GLPa
     *      - Revised program to not run routine ZZCKDGT. Added GLP to
     *        GSC1 mod.
GLPbA*    05/20/13 MLB  GLPb
     *      - Revised not execute the call to LT001. The slots being
     *        imported are empty, so no need to run LT001. GLP is full
     *        system so running LT001 when system active causes problems.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Williams Foods
     *
WIF A*    04/30/14  MLB  WIF
     *      - Revised program to add new routine CRTSLOT28 to create
     *        slots based on WIF's format.
     *        Sample slot: A031 where A=Aisle, 03=Location and 1=Lvl and
     *        ''=Handstack.
     *        Sample slot: A03 where A=Aisle, 03=Location and assume that
     *        level will be 1 and handstack = blanks.
WIFaA*    04/30/14  MLB  WIFa
     *      - Revised program to not run routine ZZCKDGT. Added WIFa to
     *        GSC1 mod.
WIFbA*    05/07/14  MLB  WIFb
     *      - Revised WIF mod above. Revised routine to add 1 to rack
     *        level for slots with format A031 or A0312. This was needed
     *        because they also have slots with format A03 where the pgm
     *        sets the rack level to 1. This was causing slot exceptions.
WIFcA*    05/07/14  MLB  WIFc
     *      - Revised WIF mod above. Revised routine to set rack level
     *        to zero for slot format A01.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHLa *    07/18/14  RTR  KHLa
     *      - Revised program to add new routine CRTSLOT34 to create
     *        slots based on Kohl's format.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WIL A*    09/02/14  RTR  WIL
     *      - Revised program to use existing routine CRTSLOT16 to create
     *        slots based on Will Foods format.
     *        Sample slot: 10-101-1 where 10=Aisle, 101=Location and 1
     *        rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    03/13/15  RTR  JSLa
     *      - Revised program to use existing routine CRTSLOT16 to create
     *        slots based on Julius Silvert format.
     *        Sample slot: 10-101-1 where 10=Aisle, 101=Location and 1
     *        rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
JSLb *    07/16/15  RTR  JSLb
     *      - Changed to move UOM to breakdown for type S items.
JSLc *    10/03/16  RTR  JSLc
     *      - Changed to allow slots with .x postfix like '92-301-4.2'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *    03/03/16  RTR  FGLa
     *      - Revised program to use existing routine CRTSLOT16 to create
     *        slots based on Foods Galore format.
     *        Sample slot: 10-101-1 where 10=Aisle, 101=Location and 1
     *        rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFC A*    09/04/14  MLB  PFC
     *      - Revised program to add new routine CRTSLOT30 to create
     *        slots based on PFC's format.
     *        Sample slot: SC-035-E where SC=Aisle, 035=Location and E
     *        rack level (E=5).
PFCaA*    09/04/14  MLB  PFCa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
PFCbA*    09/23/14  RTR  PFCb
     *      - Added conversion to uppercase for SIDISP and SIITEM.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    02/16/15  MLB  FPR
     *      - Revised program to add new routine CRTSLOT31 to create
     *        slots based on FoodPro's format.
     *        Sample slot: EG01A2 where EG=Aisle, 01=Location, 2=Level
     *        and A=Handstack.
FPR1A*    02/16/15  MLB  FPR1
     *      - Revised program to not run routine ZZCKDGT.
     *      - Added FPR1 to GSC1 mod.
FPR2A*    03/23/15  MLB  FPR2
     *      - Revised FPR mod. Add support to convert alpha character
     *        into numeric rack level.
FPR3A*    03/12/20  MLB  FPR3
     *      - Revised CRTSLOT31 to add support for 2-digit rack level
     *        for new PIR slots.
FPR4A*    03/12/20  MLB  FPR4
     *      - Revised not execute the call to LT001. The slots being
     *        imported are empty, so no need to run LT001.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers - Pate Dawson
     *
CBI A*    01/11/17  MLB  CBI
     *      - Revised program to load SLEXPD from SIFIFO for date
     *        sensitive items.
     *        Added CBI to SGCb mod.
CBIaA*    01/11/17  MLB  CBIa
     *      - Revised program to not run routine ZZCKDGT.
     *        Added CBIa to GSC1 mod.
CBIbA*    02/03/17  MLB  CBIb
     *      - Revised program to load slots for Pate Dawson whses
     *        in their custom format. Added routine, CRTSLOT32
     *        Sample slot: AC-64-B4 where AC=Aisle, 64=Location and
     *        B=Rack level (converted to 2) and 4=Handstack (converted
     *        to D).
     *        Sample slot: MA-00-12 where MA=Aisle, 00=Location and
     *        1=Rack level and 2=Handstack (converted to B)
CBIcA*    02/05/17  MLB  CBIc
     *      - Revised program to translate slot display characters
     *        into uppercase from lowercase.
CBIdA*    05/23/18  MLB  CBId
     *      - Revised program to load slots for Tifton, GA whse
     *        in their custom format. Revised routine, CRTSLOT32
     *        Sample slot: 10-104-01 where 10=Aisle, 104=Location and
     *        01=Rack level
CBIeA*    05/23/18  MLB  CBIe
     *      - Revised program to not run LT001, copy of SGCd mod.
CBIfA*    06/09/18  MLB  CBIf
     *      - Revised program to add Tifton, GA to CBI mod to populate
     *        expiration dates frome info in SIFIFO.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    08/15/16  RTR  ADFa
     *      - Revised program to add new routine CRTSLOT33 to create
     *        slots based on ADF's format.
     *      - Sample slot: 5B107-3
     *              where: 5B=Aisle, 107=Location and 3=Rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFPa *    02/12/18  RTR  SFP
     *      - Revised program to add new routine CRTSLOT35 to create
     *        slots based on Thyme format.
     *        Sample slot: 10-10-AB where 10=Aisle, 10=Location,
     *        A=Rack level, B=Handstack
     *      - Added SFP to CCP mod.
     *      - Changed to CRTSLOT36 because sofo already used CRTSLOT35
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    09/05/18  RTR  EOPa
     *      - Revised program to use existing routine CRTSLOT16
     *          to create slots based on customer slot format.
     *      - Sample slot: B1-101-1A where
     *          B1=Aisle, 101=Location, 1=rack level, A=handstack.
     *      - Added to GSC1 mod to not run routine ZZCKDGT.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*    01/06/17  MLB  SOF
     *      - Revised program to add new routine CRTSLOT32 to create
     *        slots based on ADF's format.
     *      - Sample slot: 5B107-3
     *              where: 5B=Aisle, 107=Location and 3=Rack level.
     *      - Sample Sofo slot: 64128-1
     *              where: 64=Aisle, 128=Location and 1=Rack level.
     *      - Added SOF mod to ADFa mod.
SOFaA*    01/06/17  MLB  SOFa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        SOFa mod to GSC1 mod.
SOFbA*    09/07/17  MLB  SOFb
     *      - Revised SOF mod to create new routine, CRTSLOT34 in order
     *        to accomodate Sofo's Ohio whse slot format.
     *      - Sample slot: 80124A1
     *              where: 80=Aisle, 124=Location and A=1=Rack level and
     *              1=A=Handstack.
SOFcA*    09/07/17  MLB  SOFc
     *      - Revised program to not run LT001 since only creating
     *        new, empty slots. No need to update license info.
SOFdA*    04/22/18  MLB  SOFd
     *      - Revised SOFb mod to add test for Rack Level A-Z so that
     *        Georgia slot format is processed correctly.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    04/05/18  RTR  CFIa
     *      - Added Colony Foods to use CRTSLOT30.
     *      - Sample slot: AA-015-D1
     *              where: AA=Aisle, 015=Location and D=Rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
ACCa *    09/04/18  RTR  ACCa
     *      - Revised program to add new routine CRTSLOTACC to create
     *          slots based on ACC's format.
     *      - Sample slot: 200-101-3A where:
     *          200=Aisle, 101=Location, 3=Rack level, A=Handstack.
     *      - Revised program to not run routine ZZCKDGT,
     *          added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFSa *    09/19/18  RTR  KFSa
     *      - Revised program to add new routine CRTSLOTKFS to create
     *        slots based on Kelly's new format.
     *      - Sample slots:
     *        LD-11-1A:  LD=Aisle, 011=Loc, 1=Rack lvl, A=Handstack
     *        FE-219-2A: FE=Aisle, 219=Loc, 2=Rack lvl, A=Handstack
     *        WGD-233-1: WGD=Aisle, 233=Loc, 1=Rack lvl
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dependable Food Corp
     *
DFCa *    01/20/19  RTR  DFCa
     *      - Revised program to add new routine CRTSLOTDFC to create
     *          slots based on DFC's format.
     *      - Sample slot: A-050-B where:
     *          A=Aisle, 050=Location, B=Rack level.
     *      - Do not run routine ZZCKDGT, added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Foods
     *
SUNa *    08/18/20  RTR  SUNa
     *      - Added Sunrise Foods to use CRTSLOTSUN.
     *      - Sample slot: AA-015-1A
     *              where: AA=Aisle, 015=Location and 1=Rack level.
     *      - Sample slot: P-015-1B
     *              where: P=Aisle, 015=Location and 1=Rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     * Indicators
     *
IFDbA*  68        - invalid digits in string
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fimpfstuf3 if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
500iAFslotdgt   uf a e           k disk
GMM1AFslotdgta  uf a e           k disk
     Fslot2     uf a e           k disk
DRY0AFslot3     if   e           k disk    rename(slrec:slrec3)
DRY0AF                                     prefix(sl3)
     Fvslot2    uf a e           k disk
AVLaAFavaslot1  if   e           k disk
FRFcAFimpfpckq  o    e           k disk    usropn
     Fsi275pr   o    e             printer oflind(*in91)

500bA*----------------------------------------------------------------
500bA*  Client id's for custom mods.
500bA*----------------------------------------------------------------

USF AD/copy qcopysrc,id#usfcrp
USFdAD/copy qcopysrc,id#usfcorp
USFdAD/copy qcopysrc,id#usfasys
USFdAD/copy qcopysrc,id#usfpsys
ELL AD/copy qcopysrc,id#ellenbe
GSC AD/copy qcopysrc,id#gsc
HAR AD/copy qcopysrc,id#harbor
JOR AD/copy qcopysrc,id#jordano
TPC AD/copy qcopysrc,id#tpc
SVL AD/copy qcopysrc,id#saval
SGC AD/copy qcopysrc,id#sgc
CWH AD/copy qcopysrc,id#citywho
GFCaAD/copy qcopysrc,id#glazier
FRF AD/copy qcopysrc,id#frf
IFD AD/copy qcopysrc,id#ifd
EGF AD/copy qcopysrc,id#egf
HAL AD/copy qcopysrc,id#halsey
CDI AD/copy qcopysrc,id#cdi
DRY AD/copy qcopysrc,id#dairyla
DRYcA**D/copy qcopysrc,id#drysf
DRYdAD/copy qcopysrc,id#dryhano
DRYdA**D/copy qcopysrc,id#dryla
DRYhA**D/copy qcopysrc,id#drylv
DRYdAD/copy qcopysrc,id#drymia
DRYdAD/copy qcopysrc,id#dryport
CWD AD/copy qcopysrc,id#cashwa
MAT AD/copy qcopysrc,id#matt
FFC AD/copy qcopysrc,id#fischer
CCP AD/copy qcopysrc,id#capitol
CSP AD/copy qcopysrc,id#coastal
CPC AD/copy qcopysrc,id#cpc
NCH AD/copy qcopysrc,id#nichola
JTD AD/copy qcopysrc,id#jtd
AVL AD/copy qcopysrc,id#avalon
ICB AD/copy qcopysrc,id#icb
ASC AD/copy qcopysrc,id#agar
HMW AD/copy qcopysrc,id#hmwagne
GMM AD/copy qcopysrc,id#gmm
HKW AD/copy qcopysrc,id#hkw
SPI AD/copy qcopysrc,id#spi
RFS AD/copy qcopysrc,id#rfs
GLP AD/copy qcopysrc,id#glp
WIF AD/copy qcopysrc,id#wif
KHLaAD/copy qcopysrc,id#khl
WILaAD/copy qcopysrc,id#wil
JSLaAD/copy qcopysrc,id#jsl
FGLaAD/copy qcopysrc,id#fgl
PFC AD/copy qcopysrc,id#pfc
FPR AD/copy qcopysrc,id#fpr
CBI AD/copy qcopysrc,id#cheney
ADFaAD/copy qcopysrc,id#adf
SFPaAD/copy qcopysrc,id#sfp
EOPaAD/copy qcopysrc,id#eop
SOF AD/copy qcopysrc,id#sofo
CFIaAD/copy qcopysrc,id#cfi
ACCaAD/copy qcopysrc,id#acc
KFSaAD/copy qcopysrc,id#kfs
DFCaAD/copy qcopysrc,id#dfc
SUNaAd/copy qcopysrc,id#sun

500bAD client          s             10
DRYbAD clientloc       s             10

500iA*----------------------------------------------------------------
500iA*  DRI parameters
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,C#DRIPARMS
500iA /COPY *libl/qcopysrc,C#DRIPARMP
500iAD savesubcmd      s                   like($psubcmd)
500iAD savesubcmd2     s                   like($psubcmd)
500iA
500iA*----------------------------------------------------------------
500iA*  Data Formats
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,C#ITEM
500iA /COPY *libl/qcopysrc,C#SLOT
500iAD saveVer#        s                   like($slver#)
500iAD driitem         s               n   inz(*off)
500iAD drislot         s               n   inz(*off)
500iA
500iA*----------------------------------------------------------------
500iA*  Standard variables
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,c#stdvar
500iA
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
500dDD*desc            s             20    dim(10) ctdata perrcd(1)
500iDD*desc            s             20    dim(11) ctdata perrcd(1)
SGCcDD*desc            s             20    dim(12) ctdata perrcd(1)
SGCcMD desc            s             20    dim(13) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $jobq           s              1
     D $pwhs           s             15  5
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D allchrslot      s              1    inz('0')
600bAD ck4err          s              1
     D crtbaseslot     s              1    inz('0')
USF AD ctr_direc       s              5  0 inz(0)
USF AD ctr_zquip       s              5  0 inz(0)
USF AD ctr_zvird       s              5  0 inz(0)
     D count           s              3  0
     D dftlocation     s              3  0 inz(600)
USF AD dft_direc       s              5  0 inz(0)
USF AD dft_zquip       s              5  0 inz(0)
USF AD dft_zvird       s              5  0 inz(0)
USF AD editw5          c                   '0     '
     D digits          c                   const('0123456789')
     D dummy           s                   like(slloc)
500iDD*error           s              1
600bAD  errmsg         s             50
     D exist           s              1
     D flaghs          s              1
     D forevr          s              1
     D good1           s              1
     D handstack       s              1     inz('0')
500iDD*i               s              2  0
     D impdte          s              8  0
     D imptim          s              6  0
500iDD*j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kydisp          s                   like(sldisp)
AVLaAD kyprfx          s                   like(avaprfx)
     D len             s              1  0
     D linppg          s              3  0
CWH AD loc2_3          s              3  0
     D lstwhd          s              5
     D lstwhs          s              3  0
     D newvs           s              1
     D nwchar          s              2
     D oddeven         s                   like(slloc)
     D odisp           s                   like(sldisp)
     D pflag           s              1
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D pos             s              1  0
     D ssbflg          s              1
USFaAD svdisp          s                   like(sldisp)
     D svexpd          s                   like(slexpd)
     D svhand          s                   like(slhand)
USFaAD svwhdp          s                   like(slwhdp)
500gAD validdept       s              4    inz('*YES')
     D wkchar          s              2
     D work3a          s              3
GFCaAD work4a          s              4
     D temp6a          s              6

     D dashpos         s              2  0
     D loca            s              3
CWH AD loca_x          s              3
     D lvla            s              1
USFdAD lvlaa           s              2
JOR4AD lvla2           s              2
     D locnotnum       s               n
     D lvlnotnum       s               n
     D notcreated      s               n
IFDbAD pseq4           s              4
DRY AD rowlen          s              3  0
DRY AD sectlen         s              3  0
USFdAD slotcreated     s               n

SGCcAD #rcvarea        s              6
SGCcAD sgcKansas       s               n
SGCcAD sgcWillow       s               n
GMM1AD wkdigit5        s              5a
GMM1AD wkckdgt2        s              3a
GMM1AD wkckdgt3        s              3a
SGCcAD wkWhse          s              3s 0
SGCcAD wkStgLoc        s              1
SGCcAD wkLcns          s             15
DRYaAD wksect          s              3
DRYaAD wkrow           s              3
PFCbAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
PFCbAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Date fields
     *----------------------------------------------------------------

     D datefld         s               d

     D                 ds
     D  fifodate               1      8  0 inz(0)
     D  fifoyear               1      4  0 inz(0)
     D  fifomonth              5      6  0 inz(0)
     D  fifoday                7      8  0 inz(0)

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
     *  *PICK  -  Picking options
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
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
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
     D  opmput                34     34
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
500gAD  $ltype                81     88
500gA*
500gA*   Redefine key
500gA*
500gAD  $lwhse                19     21  0
500gAD  $lwhdp                22     26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600bA /COPY *libl/qcopysrc,C#PGMINFDS
600bDD*               sds
600bDD* #prog            *proc
600bDD* #job                 244    253
600bDD* #user                254    263
600bDD* #jobn                264    269
600bDD* #jobdt               276    281  0
600bDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
FRFcA*      $PCMD   *FULL    - Full slot import sent.
FRFcA*              *PARTIAL - Partial slot import sent.
FRFcA*              *FRFROC  - 01ROC slot(s) import sent.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
FRFcA*
FRFcAC     *entry        plist
FRFcAC                   parm                    $pcmd             8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
600bA
600bA*    Get User's employee number to be written to PORCV file
600bA*    if any records are flagged as touched.
600bA
600bAC                   call      'GETUSER'
600bAC                   parm      #curruser     $code            10
600bAC                   parm      0             $whse             3 0
600bAC                   parm      0             $emp#             5 0
600bAC                   parm      *blanks       $fnam            15
600bAC                   parm      *blanks       $init             1
600bAC                   parm      *blanks       $lnam            20
600bAC                   parm      *blanks       $whdp             5
600bAC                   parm      *blanks       $styp             1
600bAC                   parm      *blanks       $shft             6
600bAC                   parm      *blanks       $crew             6
600bAC                   parm      0             $nhrs             3 1
600bAC                   parm      *blanks       $rtn              8

     * Get import date/time.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim

     * Get report date.

     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate  = $cvd6o
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      noslot = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     C                   eval      badtyp = 0
     C                   eval      baddte = 0
     C                   eval      notcrt = 0
     C                   eval      notupd = 0
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      forevr = *on
     C                   eval      linppg = 55
     C                   eval      count = 999
     C                   eval      lstwhs = -(1)
     C                   eval      lstwhd = '@@@@@'
     *
     C                   dow       forevr = forevr
     *
     C                   read      impfstuf3
     C                   if        %eof(impfstuf3)
     C                   leave
     C                   endif
     *
     C                   add       1             grdlin

HMWeAC                   select
HMWeDC*                  if        client = citywho
HMWeMC                   when      client = citywho

CWHaAC                   select

CWHaAC                   when      %subst(siwhdp:1:3) = 'DRY'
CWHaAC                   if           %subst(siwhdp:4:2) = '1 '
CWHaAC                             or %subst(siwhdp:4:2) = '2 '
CWHaAC                             or %subst(siwhdp:4:2) = '3 '
CWHaAC                             or %subst(siwhdp:4:2) = '4 '
CWHaAC                             or %subst(siwhdp:4:2) = '5 '
CWHaAC                             or %subst(siwhdp:4:2) = '6 '
CWHaAC                             or %subst(siwhdp:4:2) = '7 '
CWHaAC                             or %subst(siwhdp:4:2) = '8 '
CWHaAC                             or %subst(siwhdp:4:2) = '9 '
CWHaAC                   eval      sidisp = '0' + %subst(siwhdp:4:1) + sidisp
CWHaAC                   else
CWHaAC                   eval      sidisp = %subst(siwhdp:4:2) + sidisp
CWHaAC                   endif
CWHaAC                   eval      siwhdp = 'DRY  '

CWHaAC                   when      %subst(siwhdp:1:3) = 'CLR'
CWHaAC                   if           %subst(siwhdp:4:2) = '1 '
CWHaAC                             or %subst(siwhdp:4:2) = '2 '
CWHaAC                             or %subst(siwhdp:4:2) = '3 '
CWHaAC                             or %subst(siwhdp:4:2) = '4 '
CWHaAC                             or %subst(siwhdp:4:2) = '5 '
CWHaAC                             or %subst(siwhdp:4:2) = '6 '
CWHaAC                             or %subst(siwhdp:4:2) = '7 '
CWHaAC                             or %subst(siwhdp:4:2) = '8 '
CWHaAC                             or %subst(siwhdp:4:2) = '9 '
CWHaAC                   eval      sidisp = '0' + %subst(siwhdp:4:1) + sidisp
CWHaAC                   else
CWHaAC                   eval      sidisp = %subst(siwhdp:4:2) + sidisp
CWHaAC                   endif
CWHaAC                   eval      siwhdp = 'COOL '

CWHaAC                   when      %subst(siwhdp:1:3) = 'FRZ'
CWHaAC                   if           %subst(siwhdp:4:2) = '1 '
CWHaAC                             or %subst(siwhdp:4:2) = '2 '
CWHaAC                             or %subst(siwhdp:4:2) = '3 '
CWHaAC                             or %subst(siwhdp:4:2) = '4 '
CWHaAC                             or %subst(siwhdp:4:2) = '5 '
CWHaAC                             or %subst(siwhdp:4:2) = '6 '
CWHaAC                             or %subst(siwhdp:4:2) = '7 '
CWHaAC                             or %subst(siwhdp:4:2) = '8 '
CWHaAC                             or %subst(siwhdp:4:2) = '9 '
CWHaAC                   eval      sidisp = '0' + %subst(siwhdp:4:1) + sidisp
CWHaAC                   else
CWHaAC                   eval      sidisp = %subst(siwhdp:4:2) + sidisp
CWHaAC                   endif
CWHaAC                   eval      siwhdp = 'FREEZ'

CWHaAC                   endsl
HMWeDC*                  endif
HMWeA*
HMWeAC                   when      client = HMWagner
HMWeAC                   select
HMWeAC                   when      siwhdp = '1    '
HMWeAC                   eval      siwhdp = 'DRY  '
HMWeA*
HMWeAC                   when      siwhdp = '2    '
HMWeAC                   eval      siwhdp = 'CLR  '
HMWeA*
HMWeAC                   when      siwhdp = '3    '
HMWeAC                   eval      siwhdp = 'FRZ  '
HMWeA*
HMWeAC                   endsl
HMWeA*
KHLaAC                   when      client = Kohl
KHLaAC                   select
KHLaAC                   when      siwhdp = '5    '
KHLaAC                             and %subst(sidisp:1:1) = '5'
KHLaAC                   eval      siwhdp = '1    '
KHLaAC                   when      siwhdp = '5    '
KHLaAC                             and %subst(sidisp:1:1) = '6'
KHLaAC                   eval      siwhdp = '1    '
KHLaAC                   endsl
KHLaA*
SVLdAC                   when      client = Savalfoods
SVLdA
SVLdAC                   select
SVLdA*  Force combined dept 2 to be split into 2=Dry, 3=Clr.
SVLdAC                   when      siwhdp = '2    '
SVLdAC                             and %subst(sidisp:1:1) = 'C'
SVLdAC                   eval      siwhdp = '3    '
SVLdAC                   endsl

CBIcAC                   when      client = Cheney
CBIcA
CBIcAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
HMWeMC                   endsl

     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> siwhse
     *
     C                   if        lstwhs > 0
     C                   exsr      zzrcal
     C                   endif
     *
     C                   eval      whcode = siwhse
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      siwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     C                   eval      lstwhs = siwhse
     C                   eval      count = 999
     C                   endif
     *
     *  Get options when department changes
     *
     C                   if        lstwhd <> siwhdp
500gA*
500ga*  Validate warehouse deptartment sent with slot.
500gAC                   eval      $lwhse = siwhse
500gAC                   eval      $lwhdp = siwhdp
500gAC                   eval      $lcmd = '*VERIFYB'
500gAC                   call      'WD900'
500gAC                   parm                    $lparm
500gAC                   if        $lrtn = '*OK'
500gAC                   eval      validdept = '*YES'
500gAC                   else
500gAC                   eval      validdept = '*NO '
500gAC                   endif
500gA*
     C                   eval      kycode = '*PICK   '
     C     keyop         chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     C                   eval      lstwhd = siwhdp
     C                   endif
     *
     C                   eval      itdesc = *blanks
     C                   eval      ittype = *blanks
     C                   eval      detmsg = *blanks
USFdAC                   eval      slotcreated = *off
USF A*
USF A*  Slots requiring specialty processing.
USF A*
USF AC                   if        client = usfcrp
USFaA*
USFaA*  Reset handstack index every time slot display changes.
USFaA*  This is done so that when the slot changes from DIREC to ZQUIP
USFaA*  to ZVIRD, we reset the index to start at the beginning.
USFaA*
USFaAC                   if        sidisp <> svdisp
USFaAC                   eval      k      = 0
USFaAC                   eval      svdisp = sidisp
USFaAC                   endif
USFaA*
USF A*
USF A*  Default slots with more than 703 items per slot.
USF A*
USF AC                   select
USF AC                   when      sidisp = 'DIREC'
USFaA*
USFaAC                   if        siwhdp <> svwhdp
USFaAC                   eval      ctr_direc = 0
USFaAC                   eval      dft_direc = 0
USFaAC                   eval      k         = 0
USFaAC                   eval      svwhdp    = siwhdp
USFaAC                   endif
USFaA*
USF AC                   eval      ctr_direc = ctr_direc + 1
USF A*
USF A*  Maximum items assigned to this slot, increment counter.
USF AC                   if        ctr_direc = 704
USF AC                   eval      dft_direc = dft_direc + 1
USF AC                   eval      ctr_direc = 1
USFaAC                   eval      k = 0
USF AC                   endif
USF A*
USF A*  Create new slot.
USF AC                   if        dft_direc > 0
USF AC                   eval      sidisp = %trim(sidisp) +
USF AC                                      %trim(%editw(dft_direc:editw5))
USF AC                   endif
USF AC
USF A*
USF AC                   when      sidisp = 'ZQUIP'
USFaA*
USFaAC                   if        siwhdp <> svwhdp
USFaAC                   eval      ctr_zquip = 0
USFaAC                   eval      dft_direc = 0
USFaAC                   eval      k         = 0
USFaAC                   eval      svwhdp    = siwhdp
USFaAC                   endif
USFaA*
USF AC                   eval      ctr_zquip = ctr_zquip + 1
USF A*
USF A*  Maximum items assigned to this slot, increment counter.
USF AC                   if        ctr_zquip = 704
USF AC                   eval      dft_zquip = dft_zquip + 1
USF AC                   eval      ctr_zquip = 1
USFaAC                   eval      k = 0
USF AC                   endif
USF A*
USF A*  Create new slot.
USF AC                   if        dft_zquip > 0
USF AC                   eval      sidisp = %trim(sidisp) +
USF AC                                      %trim(%editw(dft_zquip:editw5))
USF AC                   endif
USF AC
USF A*
USF AC                   when      sidisp = 'ZVIRD'
USFaA*
USFaAC                   if        siwhdp <> svwhdp
USFaAC                   eval      ctr_zvird = 0
USFaAC                   eval      dft_direc = 0
USFaAC                   eval      k         = 0
USFaAC                   eval      svwhdp    = siwhdp
USFaAC                   endif
USFaA*
USF AC                   eval      ctr_zvird = ctr_zvird + 1
USF A*
USF A*  Maximum items assigned to this slot, increment counter.
USF AC                   if        ctr_zvird = 704
USF AC                   eval      dft_zvird = dft_zvird + 1
USF AC                   eval      ctr_zvird = 1
USFaAC                   eval      k = 0
USF AC                   endif
USF A*
USF A*  Create new slot.
USF AC                   if        dft_zvird > 0
USF AC                   eval      sidisp = %trim(sidisp) +
USF AC                                      %trim(%editw(dft_zvird:editw5))
USF AC                   endif
USF AC
USF A*
USF AC                   endsl
USF A*
USF AC                   endif
DRY0A*
DRY0A*  Look up pick slot for item, if not assigned.
DRYoAC                   if        client = Dairyland
DRY0A*
DRYfAC                   if        siitem > ' '
DRYfA*
DRYfA*  Retrieve item master to check whse dept. code.
DRYfAC     keyit         chain     piritem
DRYfAC                   if        %found(piritem)
DRYfAC                             and itwhdp <> siwhdp
DRYfAC                   eval      siwhdp = itwhdp
DRYfAC                   endif
DRYfA*
DRYfAC                   endif
DRYfA*
DRYoAC                   if        (siwhdp = 'FRZ' or siwhdp = 'REF')
DRY0AC                             and sidisp = ' ' and sipick='Y'
DRYoAC     keysl3        setll     slot3
DRY0AC     keysl3        reade     slot3
DRY0AC                   if        not %eof(slot3)
DRY0AC                   eval      sidisp = sl3sldisp
DRY0AC                   endif
DRY0AC                   endif
DRY0A*
DRY0AC                   endif
500dA*
500dA*  If not slot sent, write error message.
500dA*
500dAC                   if        sidisp = ' '
500dAC                   eval      detmsg = desc(11)
500dAC                   add       1             noslot
500dAC                   goto      prndtl
500dAC                   endif
SGCcA
SGCcA*  Flag Springfield Willow/Kansas slots.
SGCcA
SGCcAC                   eval      sgcWillow = *off
SGCcAC                   eval      sgcKansas = *off
SGCcAC                   if        client = SGC
SGCcAC                   select
SGCcAC                   when      sidisp = 'WILLOW'
SGCcAC                   eval      sgcWillow = *on
SGCcAC                   when      sidisp = 'KANSAS'
SGCcAC                   eval      sgcKansas = *on
SGCcAC                   endsl
SGCcAC                   endif
SGCcA
SGCcA*  Skip slot create for Springfield Willow/Kansas slots.
SGCcA
SGCcAC                   if        sgcWillow or sgcKansas
SGCcAC                   goto      skipCrtSlot
SGCcAC                   endif
     *
     *  If slot doesn't exist write error message.
     *
     C     keysl2        chain(n)  slot2
     C                   if        not %found(slot2)

GSC AC                   select

GSC AC                   when      client = GSC
GSC AC                   exsr      crtslot2

HAR AC                   when      client = Harbor
HAR AC                   exsr      crtslot3

JOR AC                   when      client = Jordanos
JOR AC                   exsr      crtslot29

TPC AC                   when      client = TPC
TPC AC                   exsr      crtslot_tpc
TPC AC*
USFdAC                   when      client = USFCORP
USFdAC                   if        usfsystype = usfasys
USFdAC                   exsr      crtslot_asys
USFdAC                   else
USFdAC                   exsr      crtslot
USFdAC                   endif

ELL AC                   when      client = Ellenbe
ELL AC                   exsr      crtslot4

SGC AC                   when      client = SGC
SGC AC                   exsr      crtslot5

CWH AC                   when      client = CityWho
CWH AC                   exsr      crtslot6

FRF AC                   when      client = FRF
FRF AC                   exsr      crtslot7

IFD AC                   when      client = IFD
ICB AC                             or client = ICB
IFD AC                   exsr      crtslot8

EGF AC                   when      client = EGF
EGF AC                   exsr      crtslot9

SVLbAC                   when      client = SavalFoods
SVLbAC                   exsr      crtslot10

CDI AC                   when      client = CDI
CDI AC                   exsr      crtslot11

DRY AC                   when      client = Dairyland
DRYhAC                   if        siwhdp <> svwhdp
DRYhAC                   eval      dftlocation = 600
DRYhAC                   eval      svwhdp      = siwhdp
DRYhAC                   endif
DRY AC                   exsr      crtslot12

CWD AC                   when      client = Cashwa
CWD AC                   exsr      crtslot13

HAL AC                   when      client = Halsey
HAL AC                   exsr      crtslot14

MAT AC                   when      client = Mattfoods
MAT AC                   exsr      crtslot15

GFCaAC                   when      client = Glazier
GFCaAC                   exsr      crtslot21

FFC AC                   when      client = FischerFoods
HKW AC                             or client = Hearnkirkwood
WIL AC                             or client = WillFoods
JSLaAC                             or client = JSilvert
FGLaAC                             or client = FoodsGalore
EOPaAC                             or client = Earls
FFC AC                   exsr      crtslot16

CCP AC                   when      client = CapitolCity
SPI AC                             or client = Sternproduce
CCP AC                   exsr      crtslot17

CSP AC                   when      client = CoastalSunbelt
CSP AC                   exsr      crtslot18

CPC AC                   when      client = CPC
CPC AC                   exsr      crtslot19

NCH AC                   when      client = Nicholas
NCH A*
NCH AC                   if        siwhdp <> svwhdp
NCH AC                   eval      dftlocation = 600
NCH AC                   eval      svwhdp      = siwhdp
NCH AC                   endif
NCH AC                   exsr      crtslot20

JTD AC                   when         client = JTD
AVL AC                             or client = Avalon
AVL A*
AVL AC                   if        siwhdp <> svwhdp
AVL AC                   eval      dftlocation = 600
AVL AC                   eval      svwhdp      = siwhdp
AVL AC                   endif
JTD AC                   exsr      crtslot22

ASC AC                   when      client = Agar
ASC2A*
ASC2AC                   if        siwhdp <> svwhdp
ASC2AC                   eval      dftlocation = 600
ASC2AC                   eval      svwhdp      = siwhdp
ASC2AC                   endif
ASC AC                   exsr      crtslot23

GMM AC                   when      client = Menumaker
GMM4AC                   if        siwhdp <> svwhdp
GMM4AC                   eval      dftlocation = 600
GMM4AC                   eval      svwhdp      = siwhdp
GMM4AC                   endif
GMM AC                   exsr      crtslot24

HMW AC                   when      client = HMWagner
HMWeA*
HMWeAC                   if        siwhdp <> svwhdp
HMWeAC                   eval      dftlocation = 600
HMWeAC                   eval      svwhdp      = siwhdp
HMWeAC                   endif
HMW AC                   exsr      crtslot25

RFS AC                   when      client = RFS
RFS A*
RFS AC                   if        siwhdp <> svwhdp
RFS AC                   eval      dftlocation = 600
RFS AC                   eval      svwhdp      = siwhdp
RFS AC                   endif
RFS AC                   exsr      crtslot26

GLP AC                   when      client = Greenleaf
GLP A*
GLP AC                   if        siwhdp <> svwhdp
GLP AC                   eval      dftlocation = 600
GLP AC                   eval      svwhdp      = siwhdp
GLP AC                   endif
GLP AC                   exsr      crtslot27

WIF AC                   when      client = Williamsfoods
WIF A*
WIF AC                   if        siwhdp <> svwhdp
WIF AC                   eval      dftlocation = 600
WIF AC                   eval      svwhdp      = siwhdp
WIF AC                   endif
WIF AC                   exsr      crtslot28

KHLaAC                   when      client = Kohl
KHLaA*
KHLaAC                   if        siwhdp <> svwhdp
KHLaAC                   eval      dftlocation = 600
KHLaAC                   eval      svwhdp      = siwhdp
KHLaAC                   endif
KHLaAC                   exsr      crtslot34

PFC AC                   when      client = Accardi
PFC A*
PFC AC                   if        siwhdp <> svwhdp
PFC AC                   eval      dftlocation = 600
PFC AC                   eval      svwhdp      = siwhdp
PFC AC                   endif
PFC AC                   exsr      crtslotacc

PFC AC                   when      client = Prestofoods
PFC A*
PFC AC                   if        siwhdp <> svwhdp
PFC AC                   eval      dftlocation = 600
PFC AC                   eval      svwhdp      = siwhdp
PFC AC                   endif
PFC AC                   exsr      crtslot30

FPR AC                   when      client = FoodPro
FPR A*
FPR AC                   if        siwhdp <> svwhdp
FPR AC                   eval      dftlocation = 600
FPR AC                   eval      svwhdp      = siwhdp
FPR AC                   endif
FPR AC                   exsr      crtslot31

CBIbAC                   when      client = Cheney
CBIbA*
CBIbAC                   if        siwhdp <> svwhdp
CBIbAC                   eval      dftlocation = 600
CBIbAC                   eval      svwhdp      = siwhdp
CBIbAC                   endif
CBIbAC                   exsr      crtslot32

ADFaAC                   when      client = AandDFoods
ADFaA*
ADFaAC                   if        siwhdp <> svwhdp
ADFaAC                   eval      dftlocation = 600
ADFaAC                   eval      svwhdp      = siwhdp
ADFaAC                   endif
ADFaAC                   exsr      crtslot33

SFPaAC                   when      client = Seashore
SFPaA*
SFPaAC                   if        siwhdp <> svwhdp
SFPaAC                   eval      dftlocation = 600
SFPaAC                   eval      svwhdp      = siwhdp
SFPaAC                   endif
SFPaAC                   exsr      crtslot36

KFSaAc                   when      client = Kellys
KFSaAc                   if        siwhdp <> svwhdp
KFSaAc                   eval      dftlocation = 600
KFSaAc                   eval      svwhdp      = siwhdp
KFSaAc                   endif
KFSaAc                   exsr      crtslotKfs

SOFbAC                   when      client = SofoFoods
SOFbA*
SOFbAC                   if        siwhdp <> svwhdp
SOFbAC                   eval      dftlocation = 600
SOFbAC                   eval      svwhdp      = siwhdp
SOFbAC                   endif
SOFbAC                   exsr      crtslot35

DFCaAC                   when      client = Dependable
DFCaAC                   if        siwhdp <> svwhdp
DFCaAC                   eval      dftlocation = 400
DFCaAC                   eval      svwhdp      = siwhdp
DFCaAC                   endif
DFCaAC                   exsr      crtslotdfc

GSC AC                   Other

     C                   exsr      crtslot
GSC AC                   endsl

     C                   if        notcreated
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   goto      prndtl
     C                   endif
     C                   endif
     *
JOR3AC                   if        client = Jordanos
JOR3AC                   goto      #ckdgt
JOR6DC*                  else
JOR3A*
JOR6DC*                  goto      prndtl
JOR3AC                   endif
SGCcA
SGCcAC     skipCrtSlot   tag
     *
     *  If item doesn't exist write error message.
     *
500aAC                   eval      ittype = *blanks
500aAC                   if        siitem > ' '
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   goto      prndtl
     C                   endif
     *
     *  If item type not ' ' or 'B' write error message.
510aA*  and not type 'R' write error message.
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
510 AC                             and ittype <> 'R'
JSLbAC                   if        client = JSilvert
JSLbAC                             and ittype = 'S'
JSLbAC                   eval      ittype = ' '
JSLbAC                   eval      %subst(siitem:8:1) = ' '
JSLbAC                   eval      %subst(ititem:8:1) = ' '
JSLbAC                   eval      siqty2 = siqty1
JSLbAC                   eval      siqty1 = 0
JSLbAC                   else
     C                   eval      detmsg = desc(4)
     C                   add       1             badtyp
     C                   goto      prndtl
JSLbAC                   endif
     C                   endif
     *
     *  If item dept/section not same as slot dept write error message.
     *
     C                   if        itwhdp <> siwhdp
     C                             or itstyp <> sistyp
     C                   eval      detmsg = desc(10)
     C                   move      itwhdp        detmsg
     C                   add       1             baddpt
     C                   goto      prndtl
     C                   endif
500aAC                   endif
     *
     *  If invalid mmddyy FIFO date write error message.
     *
     C                   if        sififo > 0
     C                   move      sififo        temp6a
     C     *mdy0         test(de)                temp6a
     C                   if        %error
     C                   eval      detmsg = desc(9)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
     C     *mdy0         move      temp6a        datefld
     C                   extrct    datefld:*y    fifoyear
     C                   extrct    datefld:*m    fifomonth
     C                   extrct    datefld:*d    fifoday
     C                   endif
     *
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *  Check if breakdown qty is allowed using piritem file.
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *
     C                   eval      good1 = 'N'
     C                   exsr      zzbkdn
AVLaA*
AVLaAC                   if        client = Avalon
GMMbAC                             or client = Menumaker
AVLaA*
AVLaAC                   if        good1 = 'N'
AVLaA*      Need to update check digit.
AVLaAC                   goto      SkipUpdSlot
AVLaAC                   endif
AVLaA*
AVLaAC                   endif
AVLaA*
650aAC                   if        good1 = 'N'
650aAC                   add       1             notupd
650aAC                   endif
     C     good1         cabeq     'N'           prndtl
SGCcA
SGCcA*  Skip slot update for Springfield Willow/Kansas slots.
SGCcA
SGCcAC                   if        sgcWillow or sgcKansas
SGCcAC                   goto      skipUpdSlot
SGCcAC                   endif
     *
     *  If doing manual putaway,
     *   Then get actual slot to use for the putaway.
     *
     C                   eval      newvs = *off
     C                   if        opmput = 'Y'
     C                   exsr      zzman
650aAC                   if        good1 = 'N'
650aAC                   add       1             notupd
650aAC                   endif
     C     error         cabeq     *on           prndtl
     C                   endif
     *
     *  Update slot record.
     *
     C                   exsr      zzupd
SGCcA
SGCcAC     skipUpdSlot   tag
SGCcA
SGCcA*  For Springfield Willow/Kansas slots, now create OSS slot.
SGCcA
SGCcAC                   if        sgcWillow or sgcKansas
SGCcAC                   exsr      crtSlot5OSS
SGCcAC     error         cabeq     *on           prndtl
SGCcAC                   endif
JOR3A*
JOR3AC     #ckdgt        tag
500iA*
500iA*  Update Slot Check Digit
GSC1AC                   if        client <> gsc
JOR5MC***                          and client <> Jordanos
ELL1AC                             and client <> Ellenbe
SGC1AC                             and client <> SGC
TPC AC                             and client <> TPC
IFDaAC                             and client <> IFD
EGFaAC                             and client <> EGF
SVLaAC                             and client <> SavalFoods
HALaAC                             and client <> Halsey
CDI1AC                             and client <> CDI
DRY1AC                             and client <> Dairyland
MAT1AC                             and client <> Mattfoods
GFCbAC                             and client <> Glazier
FFC1AC                             and client <> FischerFoods
CCP1AC                             and client <> CapitolCity
CSP1AC                             and client <> CoastalSunbelt
FRFhAC                             and client <> FRF
NCH1AC                             and client <> Nicholas
ICBaAC                             and client <> ICB
ASC1AC                             and client <> Agar
HMWbAC                             and client <> HMWagner
GMM3AC                             and client <> Menumaker
HKW1AC                             and client <> Hearnkirkwood
SPI1AC                             and client <> Sternproduce
SFPaAC                             and client <> Seashore
RFSaAC                             and client <> RFS
GLPaAC                             and client <> Greenleaf
WIFaAC                             and client <> Williamsfoods
KHLaAC                             and client <> Kohl
WILaAC                             and client <> WillFoods
JSLaAC                             and client <> JSilvert
FGLaAC                             and client <> FoodsGalore
EOPaAC                             and client <> Earls
PFCaAC                             and client <> Prestofoods
CFIaAC                             and client <> Colony
SUNaAC                             and client <> Sunrise
FPR1AC                             and client <> FoodPro
SOFaAC                             and client <> SofoFoods
CSP3AC                             and client <> CoastalSunbelt
CBIaAC                             and client <> Cheney
500iAC                   exsr      zzckdgt
GSC1AC                   endif
     *
     *  Print detail and update subtotals
     *
     C     prndtl        tag
     C                   if        detmsg <> *blanks
     C                   exsr      zrhead
     C                   write     detail
     **                 write     serec
     C                   add       1             count
     C                   endif
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   exsr      zrhead
     C                   write     grndttl
     *
     *  Update ItemQty totals
     *
     C                   if        lstwhs > 0
FRFdAC                   if        client = FRF
EGFeAC                             or client = EGF
HALbAC                             or client = Halsey
GFCdAC                             or client = Glazier
CSP3AC                             or client = CoastalSunbelt
USFdDC*                  exsr      zzrcal
FRFdMC                   exsr      zzrcal
FRFdAC                   endif
     C                   endif
600aA
600aA*  Synchronize license qtys with slot qtys
600aA
NCH AC                   if        client = Nicholas
JOR5AC                             or client = Jordanos
GFCgAC                             or client = Glazier
SGCdAC                             or client = SGC
CDI6AC                             or client = CDI
CWDjAC                             or client = Cashwa
RFSbAC                             or client = RFS
GLPbAC                             or client = Greenleaf
SOFcAC                             or client = SofoFoods
FPR4AC                             or client = FoodPro
TPCaAC                             or client = TPC
DRYbAC                             or client = Dairyland
CBIeAC                             or client = Cheney
DRYgDC*                            and (clientloc = dryHanover
DRYgDC*                             or  clientloc = dryMiami
DRYgDC*                             or  clientloc = dryLosangeles
DRYgDC*                             or  clientloc = dryPortland
DRYgDC*                             or  clientloc = drySanfran)
CSP3AC                             or client = CoastalSunbelt
DRYgMC*    Do nothing for all Dairyland installations. LT001 run manually
DRYgAC*    for new warehouse startups.
NCH A*  No items and/or qty being imported, so no need to run LT001.
NCH AC                   else
600aAC                   call(e)   'LT001'
600aAC                   parm      'SI'          lpAction          3
600aAC                   parm      siwhse        lpWhse            3 0
600aAC                   parm      ' '           lpWhdp            5
600aAC                   parm      ' '           lpDisp           12
600aAC                   parm      ' '           lpDummy           1
NCH AC                   endif
     *
     *  We are finished so get out
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
500bA
500bA*  Get client id
500bA
500bAC                   call      'GETCLIENT'
500bAC                   parm                    client
DRYbAC                   parm                    clientloc
500bA
USFcAC                   if        client = USFCORP
USFcA* Get USF System Type (ASYS or PSYS).
USFcAC                   call      'GETUSFSYS'
USFcAC                   parm                    usfsystype       10
USFcAC                   endif
FRFcA*
FRFcAC                   if        client = FRF
FRFgAC                   if        $pcmd = '*FRFROC'
FRFcA* Open IMPFPCKQ file for Fox River.
FRFcAC                   open      impfpckq
FRFgAC                   endif
FRFcAC                   endif
FRFcA*
     C                   eval      error = *off
     C                   eval      exist = *off
     C                   eval      newvs = *off
     *
     * Key definitions
     *
     * Item file
     *
     C     keyit         klist
     C                   kfld                    siwhse
     C                   kfld                    siitem
     *
     * Slot2 file
     *
     C     keysl2        klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp
     C     keysl2b       klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    kydisp
DRY0A*
DRY0A* Slot3 file
DRY0A*
DRY0AC     *like         define    slstat        kystat
DRY0AC     *like         define    slpick        kypick
DRY0AC                   eval      kystat = 'A '
DRY0AC                   eval      kypick = 'Y'
DRY0AC     keysl3        klist
DRY0AC                   kfld                    siwhse
DRY0AC                   kfld                    siitem
DRY0AC                   kfld                    kystat
DRY0AC                   kfld                    kypick
500iA*
500iA* Slotdgt file
500iA*
500iAC     *like         define    slwhse        kywhse
500iAC     *like         define    slwhdp        kywhdp
500iAC     keyscd        klist
500iAC                   kfld                    kywhse
500iAC                   kfld                    kywhdp
500iAC                   kfld                    kydisp
     *
     *  OPTIOND file
     *
     C     keyop         klist
     C                   kfld                    kycode
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    vsdisp
     *
     C     ckkey         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    $vdisp
AVLaA*
AVLaA* Avalon Group Slot file - AVASLOT1
AVLaA*
AVLaAC     keyava        klist
AVLaAC                   kfld                    siwhse
AVLaAC                   kfld                    kyprfx
     *
     *  Define variables
     *
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLSL  Fill order detail fields.
     *
     C     fillsl        begsr
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   endsr
500iA
500iA*----------------------------------------------------------------
500iA*  getslot  Get slot info.
500iA*----------------------------------------------------------------
500iA
500iAC     getslot       begsr
500iA
600bDC**                 eval      savever# = $slver#
600bDC**                 clear                   $slot
600bDC**                 eval      $slver# = savever#
600bA
600bMC                   exsr      clr$slot
500iA
600bAC                   eval      $slwhseu = *on
500iAC                   eval      $slwhse = siwhse
600bAC                   eval      $slwhdpu = *on
500iAC                   eval      $slwhdp = siwhdp
600bAC                   eval      $sldispu = *on
500iAC                   eval      $sldisp = sidisp
600bA
600bAC                   eval      $dricommand = '*SLOT'
600bAC                   eval      $drisubcmd  = '%GET'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      ck4err = *on
600bAC                   exsr      zzzdricop
600bAC                   if        error
600bAC                   endif
500iA
600bDC**                 eval      drislot = *on
600bDC**                 call(e)   'DRISLOT'
600bDC**                 parm      '*GET      '  $drisubcmd
600bDC**                 parm      $pprogram     $driprogram
600bDC**                 parm      ' '           $drireturn
600bDC**                 parm      ' '           $drimessage
600bDC**   $slot         parm      $slot         $dridata
500iA
500iAC     endgetslot    endsr
500iA
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   if        siqty1 = 0  and
     C                             siqty2 = 0  and
     C                             siqty3 = 0
530 AC                             and siitem > ' '
CWDgAC                             or  client = Cashwa
     C                   eval      good1 = 'Y'
     C                   goto      endbkd
     C                   endif
     *
     C                   exsr      zzssb
     *
     C                   if        siqty2 <> 0  and
     C                             itflg1 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty3 <> 0  and
     C                             itflg2 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty2 <> 0  and
     C                             itflg1 = 'Y'  or
     C                             siqty2 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty3 <> 0  and
     C                             itflg2 = 'Y'  or
     C                             siqty3 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
     *
     C     endbkd        endsr
500iA*
500iA*----------------------------------------------------------------
500iA*
500iA*  ZZCKDGT   Update Slot Check Digit.
500iA*
500iAC     zzckdgt       begsr
500iA*
AVLaAC                   if        client = Avalon
AVLaA*
AVLaAC                   eval      kyprfx = %subst(siwhdp:1:3)
AVLaAC     keyava        chain     avaslot1
AVLaAC                   if        not %found(avaslot1)
AVLaA*      Get out if entry not found in table.
AVLaAC                   leavesr
AVLaA*
AVLaAC                   endif
AVLaA*
AVLaAC                   endif
AVLaA*
500iAC                   eval      kywhse = siwhse
500iAC                   eval      kywhdp = siwhdp
500iAC                   eval      kydisp = sidisp
500iA*    Get base slot for slot being imported.
500iAC                   exsr      getslot
500iA*    Base slot not found. Print error line on report.
500iAC                   if        error
500iAC                   eval      error   = *off
500iAC                   eval      detmsg = desc(12)
500iAC                   exsr      zrhead
500iAC                   write     detail
500iAC                   eval      count = count + 1
500iA*
500iA*    Base slot was found. Update slot check digit.
500iAC                   else
500iA*
500iA*    Retrieve Slot Check Digit record.
500iAC                   eval      kydisp = $sacdsp
500iAC     keyscd        chain     slotdgt
500iAC                   if        not %found(slotdgt)
500iAC                   clear                   scdrec
500iAC                   eval      scdwhs = kywhse
500iAC                   eval      scdwhd = kywhdp
500iAC                   eval      scddsp = kydisp
AVLaA*
AVLaAC                   if        client = Avalon
AVLaAC                   eval      scddgt = avachkdgt
AVLaAC                   else
AVLaA*
500iAC                   eval      scddgt = sidgt
AVLaAC                   endif
AVLaA*
500iAC                   eval      scdadt = impdte
500iAC                   eval      scdatm = imptim
500iAC                   eval      scdaby = #user
500iAC                   write     scdrec
500iAC
500iAC                   else
AVLaA*
AVLaAC                   if        client = Avalon
AVLaAC                   eval      scddgt = avachkdgt
AVLaAC                   else
AVLaA*
500iAC                   eval      scddgt = sidgt
AVLaAC                   endif
AVLaA*
500iAC                   eval      scdadt = impdte
500iAC                   eval      scdatm = imptim
500iAC                   eval      scdaby = #user
500iAC                   update    scdrec
500iAC                   endif
500iAC                   endif
500iA*
GMM1A*
GMM1AC                   if        client = Menumaker
CWDiAC                             or client = Cashwa
GMM1A*
GMM1AC                   eval      wkdigit5 = %editc(sidgt:'X') + sidgtp
GMM1AC                   eval      wkckdgt2 = %subst(wkdigit5:2:3)
GMM2AC                   if        wkckdgt2 = ' '
GMM2AC                   eval      wkckdgt2 = '000'
GMM2AC                   endif
GMM2MC                   eval      wkckdgt3 = %subst(wkdigit5:3:3)
GMM2AC                   if        wkckdgt3 = ' '
GMM2AC                   eval      wkckdgt3 = '000'
GMM2AC                   endif
GMM1A*    Retrieve Slot Check Digit record.
GMM1AC     keyscd        chain     slotdgta
GMM1AC                   if        not %found(slotdgta)
GMM1AC                   clear                   scdreca
GMM1AC                   eval      scdwhsa = kywhse
GMM1AC                   eval      scdwhda = kywhdp
GMM1AC                   eval      scddspa = kydisp
GMM1A*
GMM1AC                   eval      scddgt2 = %dec(wkckdgt2:3:0)
GMM1AC                   eval      scddgt3 = %dec(wkckdgt3:3:0)
GMM1A*
GMM1AC                   eval      scdadt2 = impdte
GMM1AC                   eval      scdatm2 = imptim
GMM1AC                   eval      scdadt3 = impdte
GMM1AC                   eval      scdatm3 = imptim
GMM1AC                   eval      scdaby2 = #user
GMM1AC                   eval      scdaby3 = #user
GMM1AC                   write     scdreca
GMM1A*
GMM1AC                   else
GMM1AC                   eval      scddgt2 = %dec(wkckdgt2:3:0)
GMM1AC                   eval      scddgt3 = %dec(wkckdgt3:3:0)
GMM1A*
GMM1AC                   eval      scdadt2 = impdte
GMM1AC                   eval      scdatm2 = imptim
GMM1AC                   eval      scdadt3 = impdte
GMM1AC                   eval      scdatm3 = imptim
GMM1AC                   eval      scdaby2 = #user
GMM1AC                   eval      scdaby3 = #user
GMM1A*
GMM1AC                   eval      scdadt = impdte
GMM1AC                   eval      scdatm = imptim
GMM1AC                   eval      scdaby = #user
GMM1AC                   update    scdreca
GMM1AC                   endif
GMM1A*
GMM1AC                   endif
GMM1A*
500iAC                   endsr
500iA*
     *----------------------------------------------------------------
     *
     *  ZZCKNS   Use reg slot or get new Vslot.
     *
     C     zzckns        begsr
     C                   eval      newvs = *off
     C                   eval      error = *on
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   eval      error = *off
     C                   goto      endckn
     C                   else
     *
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     *
     C                   movea     slhand        a2
     C                   if        a2(1) <> ' '
     C                   goto      endckn
     C                   endif
     *
     *   Set handstack flag for later use.
     *
     C                   if        slhand <> ' '
     C                   eval      flaghs = *on
     C                   else
     C                   eval      flaghs = *off
     C                   endif
     *
     * SAVE PHYSICAL SLOT FIELDS
     *
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
     C                   eval      phaisl = slaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld = slbld
     C                   eval      phslfd = slslfd
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
USFaA*
USFaA*
USFaAC                   if        client = usfcrp
USFaAC
USFaAC                   if            %subst(sidisp:1:5) <> 'DIREC'
USFaAC                             and %subst(sidisp:1:5) <> 'ZQUIP'
USFaAC                             and %subst(sidisp:1:5) <> 'ZVIRD'
USFaAC                   eval      k = 0
USFaAC                   endif
USFaA*
USFaAC                   else
     C                   eval      k = 0
USFaAC                   endif
USFaA*
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *
     *** Loop & increment handstack to find new v-slot to create.
     *
     C                   dow       k < 702
     C                   add       1             k
     *
     *     If physical slot had handstack then limit hs we can use.
     *
     C                   if        flaghs = *on
     C                   movea     hnd(k)        a2n
     C                   if        a2n(1) <> a2(2)
     C                   iter
     C                   endif
     C                   endif
     C                   eval      $vhand = hnd(k)
     C                   call      'FRMTVS'
     C                   parm                    phdisp
     C                   parm                    flaghs
     C                   parm                    $vhand            2
     C                   parm                    $vdisp           12
     *
500fdC*    ckkey         chain(n)  slot2                              79
500fMC     ckkey         setll     slot2                                  79
500fDC*                  if        *in79
500fMC                   if        not *in79
     C                   eval      newvs = *on
     C                   eval      error = *off
     C                   eval      sidisp = $vdisp
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C     endckn        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKSL   Check if item exists in reg or V slot
     *
     C     zzcksl        begsr
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
USFbAC                             and client <> usfcrp
     C                   eval      exist = *on
     C                   goto      endcks
     C                   else
     C     keysl2        setll     vslot2
     C     nxt1          tag
     C     keysl2        reade     vslot2                                 78
     C                   if        not *in78
     C     keyvs         chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
USFbAC                             and client <> usfcrp
     C                   eval      exist = *on
     C                   eval      sidisp = sldisp
     C                   goto      endcks
     C                   else
     C                   goto      nxt1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcks        endsr
     *----------------------------------------------------------------
     *
     *  ZZMAN    Get slot to use for manual putaway.
     *
     C     zzman         begsr
     C                   eval      error = *off
     C                   eval      exist = *off
     *
     *  Check if item already exists in the base slot
     *    or in a corresponding virtual slot.
     *
     C                   exsr      zzcksl
     *
     *  If item doesn't already exist in the slot,
     *    Then try to get a new virtual slot number for it.
     *
     C                   if        exist = *off
     C                   exsr      zzckns
     C                   if        error = *on
     C                   eval      detmsg = desc(5)
     C                   add       1             notcrt
     C                   goto      endman
     C                   endif
     C                   endif
     C     endman        endsr
     *----------------------------------------------------------------
     *
     *  ZZRCAL   Recalculate item quantity from slots.
     *
     C     zzrcal        begsr
     C                   eval      error = *off
     *
     * Recalculate item qty.
     C                   eval      $pwhs = lstwhs
     C                   eval      $jobq = 'Y'
     C                   call      'UT812'
     C                   parm                    $pwhs
500iDC*                  parm      '*ALL    '    $item            15
500iMC                   parm      '*ALL    '    $itemo           15
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcal        endsr
     *----------------------------------------------------------------
     *
     *  ZZSSB   Check for SSB item.
     *
     C     zzssb         begsr
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
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
500eA*
500eA*    SSB item found attached to item being imported. Allow
500eA*    Qty 2,3 fields to be updated.
500eAC                   if        #brtn = '*FOUND'
500eAC                   eval      ssbflg = *on
500eAC                   endif
500eA*
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update slot file
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *   Update record.
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on
520 A*
520 AC                   clear                   slrec
520 A*
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
     C                   eval      slstat = 'A '
     C                   eval      slaisl = $vaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = phactv
     C                   eval      slbld  = phbld
     C                   eval      slpseq = $vpseq
500cA*
500cAC                   select
500cA*    Set picking priority based on import.
500cA*      0=Lowest priority to -9=Highest priority.
500cAC                   when      siprty >= 1
500cAC                   eval      slprty = siprty * -1
500cAC                   when      siprty < 0
500cAC                   eval      slprty = siprty
500cAC                   other
500cAC                   eval      slprty = 0
500cAC                   endsl
500cAC
     C                   eval      slslfd = 0
520aAC                   eval      slpick = $vpick
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
500cDC*                  eval      slprty = 0
500aAC
500aAC                   if        siitem > ' '
500aAC
     C                   if        sififo > 0
     C                   eval      slentd = fifodate
SGCbAC*
SGCbAC                   if        client = SGC
CBI A*
CBI AC                             or client = Cheney
CBI AC                             and (clientloc = cbigr
CBI AC                               or clientloc = cbigo
CBIfAC                               or clientloc = cbitif
CBI AC                               or clientloc = cbist)
CBI A*
SGCbAC*      Load expiration date for date sensitive items.
SGCbAC                   if        itflgd = 'Y'
SGCbAC                   eval      slexpd = fifodate
SGCbAC                   endif
SGCbAC                   endif
SGCbAC*
     C                   else
     C                   eval      slentd = impdte
     C                   endif
500aAC                   endif
500aAC
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   eval      slitem = siitem
FRFcA*
FRFcA*      Outside storage slots need qty adjustment tracking.
FRFcAC                   if        client = FRF
FRFcAC                             and $pcmd = '*FRFROC'
FRFeDC*                            and %subst(sidisp:1:5) = '01ROC'
FRFeMC                             and (%subst(sidisp:1:5) = '01ROC'
FRFeAC                             or   %subst(sidisp:1:5) = '01BOL')
FRFcA*      Qty adjustments to be done by HQ245.
FRFcAC                   eval      slstk1 = 0
FRFcAC                   eval      slstk2 = 0
FRFcAC                   eval      slstk3 = 0
FRFcAC                   exsr      write01roc
FRFcAC                   else
FRFcA*
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
500eAC                             or ssbflg = *on
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
FRFcA*
FRFcAC                   endif
     *
     C                   write     slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(7)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif
     C                   add       1             sltcrt
     *
     *  create vslot record.
     *
     C                   eval      vswhse = $vwhse
     C                   eval      vswhdp = $vwhdp
     C                   eval      vsaisl = $vaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   eval      vspdis = phdisp
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif
     ***
     C                   else
     *
     *** Update slot record
     *
     C     keysl2        chain     slot2                              79
     *
     C                   if        not *in79
     *
     C                   eval      slitem = siitem
     C                   if        slstat = 'V '  or
     C                             slstat = 'Z '
500aAC
500aAC                   if        siitem > ' '
500aAC
     C                   eval      slstat = 'A '
500aAC                   endif
500aAC
     C                   endif
500cA*
500cAC                   select
500cA*    Set picking priority based on import.
500cA*      0=Lowest priority to -9=Highest priority.
FRFcA*
FRFcAC                   when      client = FRF
FRFcAC                             and $pcmd = '*FRFROC'
FRFeDC*                            and %subst(sidisp:1:5) = '01ROC'
FRFeMC                             and (%subst(sidisp:1:5) = '01ROC'
FRFeAC                             or   %subst(sidisp:1:5) = '01BOL')
FRFcA*      Outside storage slots. Leave slot alone.
FRFcAC*
500cAC                   when      siprty >= 1
500cAC                   eval      slprty = siprty * -1
500cAC                   when      siprty < 0
500cAC                   eval      slprty = siprty
500cAC                   other
500cAC                   eval      slprty = 0
500cAC                   endsl
500cAC
CWDhAC                   if        client = Cashwa
CWDhA*
CWDhA*      Update Slot Definition if sent from Host.
CWDhAC                   if            sidgtp > ' '
CWDhAC                             and slsdef <> sidgtp
CWDhAC                   eval      slsdef = sidgtp
CWDhAC                   endif
CWDhA*
CWDhAC                   endif
FRFcA*
FRFcA*      Outside storage slots need qty adjustment tracking.
FRFcAC                   if        client = FRF
FRFcAC                             and $pcmd = '*FRFROC'
FRFeDC*                            and %subst(sidisp:1:5) = '01ROC'
FRFeMC                             and (%subst(sidisp:1:5) = '01ROC'
FRFeAC                             or   %subst(sidisp:1:5) = '01BOL')
FRFcA*      Qty adjustments to be done by HQ245.
FRFcAC                   exsr      write01roc
FRFcAC                   else
FRFcA *
FRFcA*
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
500eAC                             or ssbflg = *on
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
FRFcA*
FRFcAC                   endif
     *
500aAC                   if        siitem > ' '
500aAC
FRFcA*      Outside storage slots need qty adjustment tracking.
FRFcAC                   if        client = FRF
FRFcAC                             and $pcmd = '*FRFROC'
FRFeDC*                            and %subst(sidisp:1:5) = '01ROC'
FRFeMC                             and (%subst(sidisp:1:5) = '01ROC'
FRFeAC                             or   %subst(sidisp:1:5) = '01BOL')
FRFfA*
FRFfAC                   if        slentd = 0
FRFfA*
FRFfA*      Update Entered Date, if zero.
FRFfAC                   if        sififo > 0
FRFfAC                   eval      slentd = fifodate
SGCbAC*
SGCbAC                   if        client = SGC
CBIfAC                             or clientloc = cbitif
SGCbAC*      Load expiration date for date sensitive items.
SGCbAC                   if        itflgd = 'Y'
SGCbAC                   eval      slexpd = fifodate
SGCbAC                   endif
SGCbAC                   endif
SGCbAC*
FRFfAC                   else
FRFfAC                   eval      slentd = impdte
FRFfAC                   endif
FRFfA*
FRFfAC                   endif
FRFfA*
FRFcA*      Outside storage slots. Leave slot alone.
FRFcAC                   else
FRFcA*
     C                   if        sififo > 0
     C                   eval      slentd = fifodate
SGCbAC*
SGCbAC                   if        client = SGC
CBIfAC                             or clientloc = cbitif
SGCbAC*      Load expiration date for date sensitive items.
SGCbAC                   if        itflgd = 'Y'
SGCbAC                   eval      slexpd = fifodate
SGCbAC                   endif
SGCbAC                   endif
SGCbAC*
     C                   else
     C                   eval      slentd = impdte
     C                   endif
FRFcAC                   endif
FRFcA*
500aAC                   else
500aAC                   eval      slentd = 0
500aAC                   endif
500aAC
FRFcA*      Outside storage slots need qty adjustment tracking.
FRFcAC                   if        client = FRF
FRFcAC                             and $pcmd = '*FRFROC'
FRFeDC*                            and %subst(sidisp:1:5) = '01ROC'
FRFeMC                             and (%subst(sidisp:1:5) = '01ROC'
FRFeAC                             or   %subst(sidisp:1:5) = '01BOL')
FRFcA*      Outside storage slots. Leave slot alone.
FRFcAC                   else
FRFcA*
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
FRFcAC                   endif
FRFcA*
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  crtslot  Try and create physical slot.
     *----------------------------------------------------------------

     C     crtslot       begsr
     C                   eval      notcreated = *off
USFdA*  Turn on SlotCreated flag even if slot isn't created
USFdA*  so ZZUPD routine doesn't get executed.
USFdAC                   eval      slotcreated= *on
     C                   eval      handstack  = *off
     C                   clear                   slrec

     *  Extract location and level. Test if they are numeric.

     C                   eval      locnotnum = *off
     C                   eval      lvlnotnum = *off
     C                   eval      dashpos = 0
     C                   eval      loca  = ' '
     C                   eval      lvla  = ' '

     *  Check for all alpha slot. If no digits, default slot location
     *  will be assigned.
     C                   If            %subst(sidisp:2:2) >= '00'
     C                             and %subst(sidisp:2:2) <= '99'
     C                             or  %subst(sidisp:3:2) >= '00'
     C                             and %subst(sidisp:3:2) <= '99'
     C                   eval      allchrslot = *off
     C                   else
     C                   eval      allchrslot = *on
     C                   endif

     C                   select

     *  Dashes specified. Single character aisle
     C                   when      %subst(sidisp:2:1) = '-'
     C                             and %subst(sidisp:6:1) = '-'
     C                   eval      dashpos = 2
     C                   eval      slaisl = '  ' + %subst(sidisp:1:1)
     C                   eval      loca  = %subst(sidisp:3:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:7:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:8:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif

     *  Dashes specified. Double character aisle
     C                   when      %subst(sidisp:3:1) = '-'
     C                             and %subst(sidisp:7:1) = '-'
     C                   eval      slaisl = ' ' + %subst(sidisp:1:2)
     C                   eval      loca  = %subst(sidisp:4:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:8:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:9:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = 3

     *  No dashes specified. All character slot.
     C                   when      allchrslot = *on
     C
     C                   eval      kydisp = sidisp
     C                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
     C
     C                   eval      dftlocation = dftlocation + 1
     C                   eval      loca   = %char(dftlocation)
     C                   eval      slloc  = dftlocation
     C
     C                   eval      slrlvl = 1
     C                   eval      lvla   = '1'
     C
     C                   eval      slhand  = '  '
     C                   eval      dashpos = -1

     *  No dashes specified. Double character aisle, numeric rack level.
     C                   when           %subst(sidisp:2:1) >= 'A'
     C                             and  %subst(sidisp:2:1) <= 'Z'
     C                             and (%subst(sidisp:5:1) >= '0'
     C                             and  %subst(sidisp:5:1) <= '9'
     C                             or   %subst(sidisp:5:1)  = ' ')
     C
     C                   eval      kydisp = %subst(sidisp:1:5)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))

     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move (p)  loca          slloc

     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   move (p)  lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Double character aisle, alpha rack level,
     C                   when          %subst(sidisp:2:1) >= 'A'
     C                             and %subst(sidisp:2:1) <= 'Z'
     C                             and %subst(sidisp:5:1) >= 'A'
     C                             and %subst(sidisp:5:1) <= 'Z'
     C
     C                   eval      kydisp = %subst(sidisp:1:5)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move (p)  loca          slloc
     C
     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   evalr     wkchar = %trimr(lvla)
     C                   exsr      zzcvt2nbr
     C                   evalr     lvla   = %trimr(nwchar)
     C                   eval      slrlvl = %dec(nwchar:2:0)
     C                   eval      slrlvl = slrlvl + 10
     C
     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Single character aisle, numeric rack level.
     C                   when           %subst(sidisp:2:1) >= '0'
     C                             and  %subst(sidisp:2:1) <= '9'
     C                             and (%subst(sidisp:4:1) >= '0'
     C                             and  %subst(sidisp:4:1) <= '9'
     C                             or   %subst(sidisp:4:1)  = ' ')
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:1))
     C
     C                   evalr     loca    = %trimr(%subst(sidisp:2:2))
     C                   move (p)  loca          slloc
     C
     C                   eval      lvla    = %subst(sidisp:4:1)
     C                   move (p)  lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1
     C
     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:5:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Single character aisle, alpha rack level.
     C                   when          %subst(sidisp:2:1) >= '0'
     C                             and %subst(sidisp:2:1) <= '9'
     C                             and %subst(sidisp:4:1) >= 'A'
     C                             and %subst(sidisp:4:1) <= 'Z'
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:1))
     C
     C                   evalr     loca    = %trimr(%subst(sidisp:2:2))
     C                   move (p)  loca          slloc

     C                   eval      lvla    = %subst(sidisp:4:1)
     C                   evalr     wkchar = %trimr(lvla)
     C                   exsr      zzcvt2nbr
     C                   evalr     lvla   = %trimr(nwchar)
     C                   eval      slrlvl = %dec(nwchar:2:0)
     C                   eval      slrlvl = slrlvl + 10

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:5:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Extract out slot breakdown.
     C                   other
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   eval      slaisl  = ' ' + %subst(sidisp:1:2)

     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move      loca          slloc

     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   move      lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     C                   endsl


     *  Begin testing parts for ALL slots.
     C                   testn                   loca                 5050
     C                   if        *in50 = *off
     C                   eval      locnotnum = *on

     C                   else

     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slloc = slloc + 200
     C                   else
     C                   eval      slloc = slloc + 100
     C                   endif

     C                   endif

     C                   testn                   lvla                 50
     C                   if        *in50 = *off
     C                   eval      lvlnotnum = *on
     C                   else
     C                   select
     C                   when      slrlvl = 0
     C                   eval      slrlvl = slrlvl + 11
     C                   when      slrlvl < 0
     C                   eval      slrlvl = slrlvl * -1
     C                   endsl
     C                   endif

     *    Convert numeric handstack to alpha character.

     C                   if            slhand >= ' 0'
     C                             and slhand <= '99'
     C                   eval      wkchar = slhand
     C                   exsr      zzcvt2ltr
     C                   eval      slhand = nwchar
     C                   endif

     C     slloc         div       2             dummy
     C                   mvr                     oddeven
     C                   if        oddeven <> 0
     C                   eval      slside = 1
     C                   else
     C                   eval      slside = 0
     C                   endif
     *
     *    Check if base slot exists for imported slot with handstacks.
     *
     C                   eval      crtbaseslot = *off
     C                   if        handstack = *on
     C     keysl2b       setll     slot2
     C                   if        not %equal(slot2)
     C                   eval      crtbaseslot = *on
     C                   endif
     C                   endif

     *    See if slot meets criteria for allowing it to be created.

     C                   select

     *    If non-special slot doesn't have hypens, then don't add it.

     C                   when      dashpos = 0
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Don't allow creation if department is unknown.

500gDC*                  when      siwhdp <> 'DRY'
500gMC                   when      validdept = '*NO '
500gDC*                            and siwhdp <> 'REF'
500gDC*                            and siwhdp <> 'FRZ'
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    If location or level is not numeric, then don't add.

     C                   when      locnotnum or lvlnotnum
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Otherwise, slot is ok to be created.

     C                   other
     C                   eval      slwhdp = siwhdp
     C                   eval      sldisp = sidisp
     C                   eval      slstyp = sistyp

     C                   endsl

     *    Try and create the Base slot.

     C                   if        crtbaseslot = *on
     *    Save handstack for virtual slot.
     C                   eval      svhand = slhand

     C                   eval      slwhse = siwhse
     C                   eval      sldisp = kydisp
     C                   eval      slpseq = sipseq
     C                   select
     C                   when      slpseq = 0
     C                   eval      slpseq = slloc
     C                   when      slpseq < 0
     C                   eval      slpseq = slpseq * -1
     C                   endsl
     C                   eval      slstat = 'V '
     C                   eval      slhand = '  '
     C                   eval      slrsrv = sirsrv
     C                   eval      slsdef = 'XX'
     C                   eval      slpick = sipick

510aMC                   write (e) slrec
     C                   if        %error
     C                   eval      notcreated = *on
     C                   endif
     *
     C                   endif

     *    Try and create the imported slot.

     C                   eval      slwhse = siwhse
     *
     *    Replace base slot display, handstack w/ imported fields.
     C                   if        crtbaseslot = *on
     C                   eval      slhand = svhand
     C                   eval      sldisp = sidisp
     C                   endif
     *
     C                   eval      slpseq = sipseq
     C                   select
     C                   when      slpseq = 0
     C                   eval      slpseq = slloc
     C                   when      slpseq < 0
     C                   eval      slpseq = slpseq * -1
     C                   endsl
500iAC                   if        slitem > ' '
     C                   eval      slstat = 'A'
500iAC                   else
500iAC                   eval      slstat = 'V'
500iAC                   endif
     *
     *    Slot has handstack, create as virtual slot.
     C                   if        handstack = *on
     C                   eval      slrsrv = 'V'
     C                   else
     C                   eval      slrsrv = sirsrv
     C                   endif
     C                   eval      slsdef = 'XX'
     C                   eval      slpick = sipick

510aMC                   write (e) slrec
     C                   if        %error
     C                   eval      notcreated = *on
     C                   endif

     *    Create Virtual slot record.

     C                   if        handstack = *on
     C                   eval      vswhse = slwhse
     C                   eval      vswhdp = slwhdp
     C                   eval      vsaisl = slaisl
     C                   eval      vsloc  = slloc
     C                   eval      vsrlvl = slrlvl
     C                   eval      vshand = slhand
     C                   eval      vsdisp = sldisp
     C                   eval      vspdis = kydisp
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
510aMC                   write (e) vsrec
     C                   if        %error
     C                   eval      error  = *on
     C                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endcreate
     C                   endif

     C                   endif


     C     endcreate     endsr

USFdA*----------------------------------------------------------------
USFdA*  crtslot_asys  Try and create physical slot.
USFdA*----------------------------------------------------------------
USFdA
USFdAC     crtslot_asys  begsr
USFdA*  Turn on SlotCreated flag even if slot isn't created
USFdA*  so ZZUPD routine doesn't get executed.
USFdAC                   eval      slotcreated= *on
USFdAC                   eval      notcreated = *off
USFdAC                   eval      handstack  = *off
USFdAC                   clear                   slrec
USFdA
USFdA*  Extract location and level. Test if they are numeric.
USFdA
USFdAC                   eval      locnotnum = *off
USFdAC                   eval      lvlnotnum = *off
USFdAC                   eval      dashpos = 0
USFdAC                   eval      loca  = ' '
USFdAC                   eval      lvlaa = '  '
USFdA
USFdA*  Check for all alpha slot. If no digits, default slot location
USFdA*  will be assigned.
USFdAC                   If            %subst(sidisp:2:2) >= '00'
USFdAC                             and %subst(sidisp:2:2) <= '99'
USFdAC                             or  %subst(sidisp:4:3) >= '000'
USFdAC                             and %subst(sidisp:4:3) <= '999'
USFdAC                             or  %subst(sidisp:7:2) >= '00'
USFdAC                             and %subst(sidisp:7:2) <= '99'
USFdAC                   eval      allchrslot = *off
USFdAC                   else
USFdAC                   eval      allchrslot = *on
USFdAC                   endif
USFdA
USFdAC                   select
USFdA
USFdA*  Dashes specified. Single character aisle
USFdAC                   when      %subst(sidisp:2:1) = '-'
USFdAC                             and %subst(sidisp:6:1) = '-'
USFdAC                   eval      dashpos = 2
USFdAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
USFdAC                   eval      loca  = %subst(sidisp:3:3)
USFdAC                   move      loca          slloc
USFdAC                   eval      lvlaa  = %subst(sidisp:7:2)
USFdAC                   move      lvlaa         slrlvl
USFdAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdA
USFdA*  Dashes specified. Double character aisle
USFdAC                   when      %subst(sidisp:3:1) = '-'
USFdAC                             and %subst(sidisp:7:1) = '-'
USFdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
USFdAC                   eval      loca  = %subst(sidisp:4:3)
USFdAC                   move      loca          slloc
USFdAC                   eval      lvlaa  = %subst(sidisp:8:2)
USFdAC                   move      lvlaa         slrlvl
USFdAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = 3
USFdA
USFdA*  Dashes specified. Triple character aisle
USFdAC                   when      %subst(sidisp:4:1) = '-'
USFdAC                             and %subst(sidisp:8:1) = '-'
USFdAC                   eval      slaisl = ' ' + %subst(sidisp:1:3)
USFdAC                   eval      loca  = %subst(sidisp:5:3)
USFdAC                   move      loca          slloc
USFdAC                   eval      lvlaa  = %subst(sidisp:9:2)
USFdAC                   move      lvlaa         slrlvl
USFdAC                   eval      slhand  = ' ' + %subst(sidisp:11:1)
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = 3
USFdA
USFdA*  No dashes specified. All character slot.
USFdAC                   when      allchrslot = *on
USFdAC
USFdAC                   eval      kydisp = %subst(sidisp:1:8)
USFdAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
USFdAC
USFdAC                   eval      dftlocation = dftlocation + 1
USFdAC                   eval      loca   = %char(dftlocation)
USFdAC                   eval      slloc  = dftlocation
USFdAC
USFdAC                   eval      slrlvl = 1
USFdAC                   eval      lvlaa   = '01'
USFdAC
USFdAC                   eval      slhand  = '  '
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Triple character aisle
USFdAC                   when           %subst(sidisp:1:1) >= 'A'
USFdAC                             and  %subst(sidisp:1:1) <= 'Z'
USFdAC                             and (%subst(sidisp:2:2) >= '00'
USFdAC                             and  %subst(sidisp:2:2) <= '99')
USFdA
USFdAC                   eval      kydisp = %subst(sidisp:1:8)
USFdAC                   eval      slaisl = %subst(sidisp:1:3)
USFdAC                   eval      loca  = %subst(sidisp:4:3)
USFdAC                   move      loca          slloc
USFdAC                   eval      lvlaa  = %subst(sidisp:7:2)
USFdAC                   move      lvlaa         slrlvl
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:9:2))
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Double character aisle, numeric rack level.
USFdAC                   when           %subst(sidisp:2:1) >= 'A'
USFdAC                             and  %subst(sidisp:2:1) <= 'Z'
USFdAC                             and (%subst(sidisp:8:2) >= '00'
USFdAC                             and  %subst(sidisp:8:2) <= '99')
USFdAC
USFdAC                   eval      kydisp  = %subst(sidisp:1:8)
USFdAC                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
USFdA
USFdAC                   evalr     loca    = %trimr(%subst(sidisp:3:3))
USFdAC                   move (p)  loca          slloc
USFdA
USFdAC                   eval      lvlaa   = %subst(sidisp:6:2)
USFdAC                   move (p)  lvlaa         slrlvl
USFdAC                   eval      slrlvl  = slrlvl + 1
USFdA
USFdA*   Special reserved slot. Don't break out handstack characters.
USFdAC                   if        %subst(sidisp:8:3) = 'OVR'
USFdAC                   eval      slhand  = '  '
USFdAC                   else
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:8:2))
USFdAC                   endif
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Double character aisle, alpha rack level,
USFdAC                   when          %subst(sidisp:2:1) >= 'A'
USFdAC                             and %subst(sidisp:2:1) <= 'Z'
USFdAC                             and %subst(sidisp:8:2) >= 'A '
USFdAC                             and %subst(sidisp:8:2) <= 'ZZ'
USFdAC
USFdAC                   eval      kydisp  = %subst(sidisp:1:8)
USFdAC                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
USFdAC                   evalr     loca    = %trimr(%subst(sidisp:3:3))
USFdAC                   move (p)  loca          slloc
USFdAC
USFdAC                   eval      lvlaa   = %subst(sidisp:6:2)
USFdAC                   evalr     wkchar = %trimr(lvla)
USFdAC                   exsr      zzcvt2nbr
USFdAC                   evalr     lvlaa  = %trimr(nwchar)
USFdAC                   eval      slrlvl = %dec(nwchar:2:0)
USFdAC                   eval      slrlvl = slrlvl + 10
USFdAC
USFdA*   Special reserved slot. Don't break out handstack characters.
USFdAC                   if        %subst(sidisp:8:3) = 'OVR'
USFdAC                   eval      slhand  = '  '
USFdAC                   else
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:8:2))
USFdAC                   endif
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Single character aisle, numeric rack level.
USFdAC                   when           %subst(sidisp:2:1) >= '0'
USFdAC                             and  %subst(sidisp:2:1) <= '9'
USFdAC                             and (%subst(sidisp:5:2) >= '00'
USFdAC                             and  %subst(sidisp:5:2) <= '99')
USFdAC
USFdAC                   eval      kydisp  = %subst(sidisp:1:7)
USFdAC                   evalr     slaisl  = %trimr(%subst(sidisp:1:1))
USFdAC
USFdAC                   evalr     loca    = %trimr(%subst(sidisp:2:3))
USFdAC                   move (p)  loca          slloc
USFdAC
USFdAC                   eval      lvla    = %subst(sidisp:5:3)
USFdAC                   move (p)  lvla          slrlvl
USFdAC                   eval      slrlvl  = slrlvl + 1
USFdAC
USFdA*   Special reserved slot. Don't break out handstack characters.
USFdAC                   if        %subst(sidisp:7:3) = 'OVR'
USFdAC                   eval      slhand  = '  '
USFdAC                   else
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:7:2))
USFdAC                   endif
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Single character aisle, alpha rack level.
USFdAC                   when          %subst(sidisp:2:1) >= '0'
USFdAC                             and %subst(sidisp:2:1) <= '9'
USFdAC                             and %subst(sidisp:5:2) >= 'A '
USFdAC                             and %subst(sidisp:5:2) <= 'ZZ'
USFdAC
USFdAC                   eval      kydisp = %subst(sidisp:1:7)
USFdAC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
USFdAC
USFdAC                   evalr     loca   = %trimr(%subst(sidisp:2:3))
USFdAC                   move (p)  loca          slloc
USFdA
USFdAC                   eval      lvlaa  = %subst(sidisp:5:2)
USFdAC                   evalr     wkchar = %trimr(lvla)
USFdAC                   exsr      zzcvt2nbr
USFdAC                   evalr     lvlaa  = %trimr(nwchar)
USFdAC                   eval      slrlvl = %dec(nwchar:2:0)
USFdAC                   eval      slrlvl = slrlvl + 10
USFdA
USFdA*   Special reserved slot. Don't break out handstack characters.
USFdAC                   if        %subst(sidisp:7:3) = 'OVR'
USFdAC                   eval      slhand  = '  '
USFdAC                   else
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:7:2))
USFdAC                   endif
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdA*  No dashes specified. Extract out slot breakdown.
USFdAC                   other
USFdAC
USFdAC                   eval      kydisp = %subst(sidisp:1:7)
USFdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
USFdA
USFdAC                   evalr     loca   = %trimr(%subst(sidisp:3:3))
USFdAC                   move      loca          slloc
USFdA
USFdAC                   eval      lvlaa  = %subst(sidisp:6:2)
USFdAC                   move      lvlaa         slrlvl
USFdAC                   eval      slrlvl  = slrlvl + 1
USFdA
USFdA*   Special reserved slot. Don't break out handstack characters.
USFdAC                   if        %subst(sidisp:8:3) = 'OVR'
USFdAC                   eval      slhand  = '  '
USFdAC                   else
USFdAC                   evalr     slhand  = %trimr(%subst(sidisp:8:2))
USFdAC                   endif
USFdAC                   if        slhand > ' '
USFdAC                   eval      handstack = *on
USFdAC                   endif
USFdAC                   eval      dashpos = -1
USFdA
USFdAC                   endsl
USFdA
USFdA
USFdA*  Begin testing parts for ALL slots.
USFdAC                   testn                   loca                 5050
USFdAC                   if        *in50 = *off
USFdAC                   eval      locnotnum = *on
USFdA
USFdAC                   else
USFdA
USFdAC                   if        %subst(sidisp:8:3) = 'OVR'
USFdAC                   eval      slloc = slloc + 200
USFdAC                   else
USFdAC                   eval      slloc = slloc + 100
USFdAC                   endif
USFdA
USFdAC                   endif
USFdA
USFdAC                   testn                   lvlaa                50
USFdAC                   if        *in50 = *off
USFdAC                   eval      lvlnotnum = *on
USFdAC                   else
USFdAC                   select
USFdAC                   when      slrlvl = 0
USFdAC                   eval      slrlvl = slrlvl + 11
USFdAC                   when      slrlvl < 0
USFdAC                   eval      slrlvl = slrlvl * -1
USFdAC                   endsl
USFdAC                   endif
USFdA
USFdA*    Convert numeric handstack to alpha character.
USFdA
USFdAC                   if            slhand >= ' 0'
USFdAC                             and slhand <= '99'
USFdAC                   eval      wkchar = slhand
USFdAC                   exsr      zzcvt2ltr
USFdAC                   eval      slhand = nwchar
USFdAC                   endif
USFdA
USFdAC     slloc         div       2             dummy
USFdAC                   mvr                     oddeven
USFdAC                   if        oddeven <> 0
USFdAC                   eval      slside = 1
USFdAC                   else
USFdAC                   eval      slside = 0
USFdAC                   endif
USFdA*
USFdA*    Check if base slot exists for imported slot with handstacks.
USFdA*
USFdAC                   eval      crtbaseslot = *off
USFdAC                   if        handstack = *on
USFdAC     keysl2b       setll     slot2
USFdAC                   if        not %equal(slot2)
USFdAC                   eval      crtbaseslot = *on
USFdAC                   endif
USFdAC                   endif
USFdA
USFdA*    See if slot meets criteria for allowing it to be created.
USFdA
USFdAC                   select
USFdA
USFdA*    If non-special slot doesn't have hypens, then don't add it.
USFdA
USFdAC                   when      dashpos = 0
USFdAC                   eval      notcreated = *on
USFdAC                   goto      endcrt_asys
USFdA
USFdA*    Don't allow creation if department is unknown.
USFdA
USFdAC                   when      siwhdp <> 'DRY'
USFdAC                             and siwhdp <> 'REF'
USFdAC                             and siwhdp <> 'FRZ'
USFdAC                   eval      notcreated = *on
USFdAC                   goto      endcrt_asys
USFdA
USFdA*    If location or level is not numeric, then don't add.
USFdA
USFdAC                   when      locnotnum or lvlnotnum
USFdAC                   eval      notcreated = *on
USFdAC                   goto      endcrt_asys
USFdA
USFdA*    Otherwise, slot is ok to be created.
USFdA
USFdAC                   other
USFdAC                   eval      slwhdp = siwhdp
USFdAC                   eval      sldisp = sidisp
USFdAC                   eval      slstyp = sistyp
USFdA
USFdAC                   endsl
USFdA
USFdA*    Try and create the Base slot.
USFdA
USFdAC                   if        crtbaseslot = *on
USFdA*    Save handstack for virtual slot.
USFdAC                   eval      svhand = slhand
USFdA
USFdAC                   eval      slwhse = siwhse
USFdAC                   eval      sldisp = kydisp
USFdAC                   eval      slpseq = sipseq
USFdAC                   select
USFdAC                   when      slpseq = 0
USFdAC                   eval      slpseq = slloc
USFdAC                   when      slpseq < 0
USFdAC                   eval      slpseq = slpseq * -1
USFdAC                   endsl
USFdAC                   eval      slstat = 'V '
USFdAC                   eval      slhand = '  '
USFdAC                   eval      slrsrv = sirsrv
USFdAC                   eval      slsdef = 'XX'
USFdAC                   eval      slpick = sipick
USFdA
USFdAC                   write     slrec                                78
USFdAC                   if        *in78 = *on
USFdAC                   eval      notcreated = *on
USFdAC                   endif
USFdA*
USFdAC                   endif
USFdA
USFdA*    Try and create the imported slot.
USFdA
USFdAC                   eval      slwhse = siwhse
USFdA*
USFdA*    Replace base slot display, handstack w/ imported fields.
USFdAC                   if        crtbaseslot = *on
USFdAC                   eval      slhand = svhand
USFdAC                   eval      sldisp = sidisp
USFdAC                   endif
USFdA*
USFdAC                   eval      slpseq = sipseq
USFdAC                   select
USFdAC                   when      slpseq = 0
USFdAC                   eval      slpseq = slloc
USFdAC                   when      slpseq < 0
USFdAC                   eval      slpseq = slpseq * -1
USFdAC                   endsl
USFdAC                   eval      slstat = 'V '
USFdA*
USFdA*    Slot has handstack, create as virtual slot.
USFdAC                   if        handstack = *on
USFdAC                   eval      slrsrv = 'V'
USFdAC                   else
USFdAC                   eval      slrsrv = sirsrv
USFdAC                   endif
USFdAC                   eval      slsdef = 'XX'
USFdAC                   eval      slpick = sipick
USFdA
USFdAC                   write     slrec                                78
USFdAC                   if        *in78 = *on
USFdAC                   eval      notcreated = *on
USFdAC                   endif
USFdA
USFdA*    Create Virtual slot record.
USFdA
USFdAC                   if        handstack = *on
USFdAC                   eval      vswhse = slwhse
USFdAC                   eval      vswhdp = slwhdp
USFdAC                   eval      vsaisl = slaisl
USFdAC                   eval      vsloc  = slloc
USFdAC                   eval      vsrlvl = slrlvl
USFdAC                   eval      vshand = slhand
USFdAC                   eval      vsdisp = sldisp
USFdAC                   eval      vspdis = kydisp
USFdAC                   eval      vscdte = impdte
USFdAC                   eval      vsctim = imptim
USFdAC                   add       1             vsctim
USFdAC                   write     vsrec                                78
USFdAC                   if        *in78 = *on
USFdAC                   eval      error  = *on
USFdAC                   eval      detmsg = desc(8)
USFdAC                   add       1             notcrt
USFdAC                   goto      endcrt_asys
USFdAC                   endif
USFdA
USFdAC                   endif
USFdA
USFdA
USFdAC     endcrt_asys   endsr

TPC  *----------------------------------------------------------------
TPC  *  crtslot_TPC  Try and create physical slot.
TPC  *----------------------------------------------------------------
TPC
TPC  C     crtslot_tpc   begsr
TPC  C                   eval      notcreated = *off
TPC A*  Turn on SlotCreated flag even if slot isn't created
TPC A*  so ZZUPD routine doesn't get executed.
TPC AC                   eval      slotcreated= *on
TPC AC                   eval      handstack  = *off
TPC AC                   clear                   slrec
TPC A
TPC A*  Extract location and level. Test if they are numeric.
TPC A
TPC AC                   eval      locnotnum = *off
TPC AC                   eval      lvlnotnum = *off
TPC AC                   eval      dashpos = 0
TPC AC                   eval      loca  = ' '
TPC AC                   eval      lvla  = ' '
TPC A
TPC A*  Check for all alpha slot. If no digits, default slot location
TPC A*  will be assigned.
TPC AC                   If            %subst(sidisp:1:2) >= '00'
TPC AC                             and %subst(sidisp:1:2) <= '99'
TPC AC                             or  %subst(sidisp:4:3) >= '000'
TPC AC                             and %subst(sidisp:4:3) <= '999'
TPC AC                   eval      allchrslot = *off
TPC AC                   else
TPC AC                   eval      allchrslot = *on
TPC AC                   endif
TPC A
TPC AC                   select
TPC A
TPC A*  Dashes specified. Single character aisle and alpha rack lvl
TPC AC                   when      %subst(sidisp:2:1) = '-'
TPC AC                             and %subst(sidisp:6:1) = '-'
TPC AC                             and %subst(sidisp:7:1) >= 'A'
TPC AC                             and %subst(sidisp:7:1) <= 'Z'
TPC AC                   eval      dashpos = 2
TPC AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
TPC AC                   eval      loca  = %subst(sidisp:3:3)
TPC AC                   move      loca          slloc
TPC A*      Convert alpha level into numeric value.
TPC AC                   eval      lvla    = %subst(sidisp:7:1)
TPC AC                   evalr     wkchar = %trimr(lvla)
TPC AC                   exsr      zzcvt2nbr
TPC AC                   evalr     lvla   = %trimr(nwchar)
TPC AC                   eval      slrlvl = %dec(nwchar:2:0)
TPC A*
TPC AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
TPC AC                   if        slhand > ' '
TPCcDC*                  eval      handstack = *on
TPC AC                   endif
TPC A
TPC A*  Dashes specified. Double character aisle and alpha rack lvl
TPC AC                   when      %subst(sidisp:3:1) = '-'
TPC AC                             and %subst(sidisp:7:1) = '-'
TPC AC                             and %subst(sidisp:8:1) >= 'A'
TPC AC                             and %subst(sidisp:8:1) <= 'Z'
TPC AC                   eval      dashpos = 3
TPC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
TPC AC                   eval      loca  = %subst(sidisp:4:3)
TPC AC                   move      loca          slloc
TPC A*      Convert alpha level into numeric value.
TPC AC                   eval      lvla    = %subst(sidisp:8:1)
TPC AC                   evalr     wkchar = %trimr(lvla)
TPC AC                   exsr      zzcvt2nbr
TPC AC                   evalr     lvla   = %trimr(nwchar)
TPC AC                   eval      slrlvl = %dec(nwchar:2:0)
TPC A*
TPC AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
TPC AC                   if        slhand > ' '
TPCcDC*                  eval      handstack = *on
TPC AC                   endif
TPC A
TPC A*  No dashes specified. All character slot.
TPC AC                   when      allchrslot = *on
TPC AC
TPC AC                   eval      kydisp = sidisp
TPC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
TPC AC
TPC AC                   eval      dftlocation = dftlocation + 1
TPC AC                   eval      loca   = %char(dftlocation)
TPC AC                   eval      slloc  = dftlocation
TPC AC
TPC AC                   eval      slrlvl = 1
TPC AC                   eval      lvla   = '1'
TPC AC
TPC AC                   eval      slhand  = '  '
TPC AC                   eval      dashpos = -1
TPC A
TPC A*  No dashes specified. Extract out slot breakdown.
TPC AC                   other
TPC AC
TPC AC                   eval      kydisp = %subst(sidisp:1:4)
TPC AC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
TPC A
TPC AC                   evalr     loca    = %trimr(%subst(sidisp:3:2))
TPC AC                   move      loca          slloc
TPC A
TPC AC                   eval      lvla    = %subst(sidisp:5:1)
TPC AC                   move      lvla          slrlvl
TPC AC                   eval      slrlvl  = slrlvl + 1
TPC A
TPC AC                   if        slhand > ' '
TPCcDC*                  eval      handstack = *on
TPC AC                   endif
TPC AC                   eval      dashpos = -1
TPC A
TPC AC                   endsl
TPC A
TPC A
TPC A*  Begin testing parts for ALL slots.
TPC AC                   testn                   loca                 5050
TPC AC                   if        *in50 = *off
TPC AC                   eval      locnotnum = *on
TPC A
TPC AC                   else
TPC A
TPC AC                   if        %subst(sidisp:6:3) = 'OVR'
TPC AC                   eval      slloc = slloc + 200
TPC AC                   else
TPC AC                   if        slloc = 0
TPC AC                   eval      slloc = slloc + 100
TPC AC                   endif
TPC AC                   endif
TPC A
TPC AC                   endif
TPC A
TPC AC                   testn                   lvla                 50
TPC AC                   if        *in50 = *off
TPC AC                   eval      lvlnotnum = *on
TPC AC                   else
TPC AC                   select
TPC AC                   when      slrlvl = 0
TPC AC                   eval      slrlvl = slrlvl + 11
TPC AC                   when      slrlvl < 0
TPC AC                   eval      slrlvl = slrlvl * -1
TPC AC                   endsl
TPC AC                   endif
TPC A
TPC A*    Convert numeric handstack to alpha character.
TPC A
TPC AC                   if            slhand >= ' 0'
TPC AC                             and slhand <= '99'
TPC AC                   eval      wkchar = slhand
TPC AC                   exsr      zzcvt2ltr
TPC AC                   eval      slhand = nwchar
TPC AC                   endif
TPC A
TPC AC     slloc         div       2             dummy
TPC AC                   mvr                     oddeven
TPC AC                   if        oddeven <> 0
TPC AC                   eval      slside = 1
TPC AC                   else
TPC AC                   eval      slside = 0
TPC AC                   endif
TPC A*
TPC A*    Check if base slot exists for imported slot with handstacks.
TPC A*
TPC AC                   eval      crtbaseslot = *off
TPC AC                   if        handstack = *on
TPC AC     keysl2b       setll     slot2
TPC AC                   if        not %equal(slot2)
TPC AC                   eval      crtbaseslot = *on
TPC AC                   endif
TPC AC                   endif
TPC A
TPC A*    See if slot meets criteria for allowing it to be created.
TPC A
TPC AC                   select
TPC A
TPC A*    If non-special slot doesn't have hypens, then don't add it.
TPC A
TPC AC                   when      dashpos = 0
TPC AC                   eval      notcreated = *on
TPC AC                   goto      endcreate_tpc
TPC A
TPC A*    Don't allow creation if department is unknown.
TPC A
TPC AC                   when      siwhdp <> 'DRY'
TPC AC                             and siwhdp <> 'REF'
TPC AC                             and siwhdp <> 'FRZ'
TPC AC                   eval      notcreated = *on
TPC AC                   goto      endcreate_tpc
TPC A
TPC A*    If location or level is not numeric, then don't add.
TPC A
TPC AC                   when      locnotnum or lvlnotnum
TPC AC                   eval      notcreated = *on
TPC AC                   goto      endcreate_tpc
TPC A
TPC A*    Otherwise, slot is ok to be created.
TPC A
TPC AC                   other
TPC AC                   eval      slwhdp = siwhdp
TPC AC                   eval      sldisp = sidisp
TPC AC                   eval      slstyp = sistyp
TPC A
TPC AC                   endsl
TPC A
TPC A*    Try and create the Base slot.
TPC A
TPC AC                   if        crtbaseslot = *on
TPC A*    Save handstack for virtual slot.
TPC AC                   eval      svhand = slhand
TPC A
TPC AC                   eval      slwhse = siwhse
TPC AC                   eval      sldisp = kydisp
TPC AC                   eval      slpseq = sipseq
TPC AC                   select
TPC AC                   when      slpseq = 0
TPC AC                   eval      slpseq = slloc
TPC AC                   when      slpseq < 0
TPC AC                   eval      slpseq = slpseq * -1
TPC AC                   endsl
TPC AC                   eval      slstat = 'V '
TPC AC                   eval      slhand = '  '
TPC AC                   eval      slrsrv = sirsrv
TPC AC                   eval      slsdef = 'XX'
TPC AC                   eval      slpick = sipick
TPCbAC                   eval      slbld  = 'NW'
TPC A
TPC AC                   write     slrec                                78
TPC AC                   if        *in78 = *on
TPC AC                   eval      notcreated = *on
TPC AC                   endif
TPC A*
TPC AC                   endif
TPC A
TPC A*    Try and create the imported slot.
TPC A
TPC AC                   eval      slwhse = siwhse
TPC A*
TPC A*    Replace base slot display, handstack w/ imported fields.
TPC AC                   if        crtbaseslot = *on
TPC AC                   eval      slhand = svhand
TPC AC                   eval      sldisp = sidisp
TPC AC                   endif
TPC A*
TPC AC                   eval      slpseq = sipseq
TPC AC                   select
TPC AC                   when      slpseq = 0
TPC AC                   eval      slpseq = slloc
TPC AC                   when      slpseq < 0
TPC AC                   eval      slpseq = slpseq * -1
TPC AC                   endsl
TPC AC                   eval      slstat = 'V'
TPC A*
TPC A*    Slot has handstack, create as virtual slot.
TPC AC                   if        handstack = *on
TPC AC                   eval      slrsrv = 'V'
TPC AC                   else
TPC AC                   eval      slrsrv = sirsrv
TPC AC                   endif
TPCdA*
TPCdAC                   if        sidgtp > ' '
TPCdAC                   eval      slsdef = sidgtp
TPCdAC                   else
TPCdA*
TPC AC                   eval      slsdef = 'XX'
TPCdAC                   endif
TPCdA*
TPC AC                   eval      slpick = sipick
TPCbAC                   eval      slbld  = 'NW'
TPC A
TPC AC                   write     slrec                                78
TPC AC                   if        *in78 = *on
TPC AC                   eval      notcreated = *on
TPC AC                   endif
TPC A
TPC A*    Create Virtual slot record.
TPC A
TPC AC                   if        handstack = *on
TPC AC                   eval      vswhse = slwhse
TPC AC                   eval      vswhdp = slwhdp
TPC AC                   eval      vsaisl = slaisl
TPC AC                   eval      vsloc  = slloc
TPC AC                   eval      vsrlvl = slrlvl
TPC AC                   eval      vshand = slhand
TPC AC                   eval      vsdisp = sldisp
TPC AC                   eval      vspdis = kydisp
TPC AC                   eval      vscdte = impdte
TPC AC                   eval      vsctim = imptim
TPC AC                   add       1             vsctim
TPC AC                   write     vsrec                                78
TPC AC                   if        *in78 = *on
TPC AC                   eval      error  = *on
TPC AC                   eval      detmsg = desc(8)
TPC AC                   add       1             notcrt
TPC AC                   goto      endcreate_tpc
TPC AC                   endif
TPC A
TPC AC                   endif
TPC A
TPC AC     endcreate_tpc endsr

GSC A*----------------------------------------------------------------
GSC A*  crtslot2  Try and create physical slot.
GSC A*----------------------------------------------------------------
GSC A
GSC AC     crtslot2      begsr
GSC AC                   eval      notcreated = *off
GSC AC                   eval      handstack  = *off
GSC AC                   clear                   slrec
GSC A
GSC A*  Extract location and level. Test if they are numeric.
GSC A
GSC AC                   eval      locnotnum = *off
GSC AC                   eval      lvlnotnum = *off
GSC AC                   eval      dashpos = 0
GSC AC                   eval      loca  = ' '
GSC AC                   eval      lvla  = ' '
GSC A
GSC AC                   select
GSC A
GSC A*  Dashes specified. Single character aisle
GSC AC                   when      %subst(sidisp:2:1) = '-'
GSC AC                             and %subst(sidisp:6:1) = '-'
GSC AC                   eval      dashpos = 2
GSC AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
GSC AC                   eval      loca  = %subst(sidisp:3:3)
GSC AC                   move      loca          slloc
GSC AC                   eval      lvla  = %subst(sidisp:7:1)
GSC AC                   move      lvla          slrlvl
GSC AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
GSC AC                   if        slhand > ' '
GSC AC                   eval      handstack = *on
GSC AC                   endif
GSC A
GSC A*  Dashes specified. Double character aisle
GSC AC                   when      %subst(sidisp:3:1) = '-'
GSC AC                             and %subst(sidisp:7:1) = '-'
GSC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
GSC AC                   eval      loca  = %subst(sidisp:4:3)
GSC AC                   move      loca          slloc
GSC AC                   eval      lvla  = %subst(sidisp:8:1)
GSC AC                   move      lvla          slrlvl
GSC AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
GSC AC                   if        slhand > ' '
GSC AC                   eval      handstack = *on
GSC AC                   endif
GSC AC                   eval      dashpos = 3
GSC A
GSC A*  No dashes specified. Double character aisle, numeric rack level.
GSC AC                   when          (%subst(sidisp:2:1) >= 'A'
GSC AC                             and  %subst(sidisp:2:1) <= 'Z'
GSC AC                             or   %subst(sidisp:2:1)  = ' ')
GSC AC                             and (%subst(sidisp:6:1) >= '0'
GSC AC                             and  %subst(sidisp:6:1) <= '9'
GSC AC                             or   %subst(sidisp:6:1)  = ' ')
GSC AC
GSC AC                   eval      kydisp = %subst(sidisp:1:12)
GSC AC                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
GSC A
GSC AC                   evalr     loca    = %trimr(%subst(sidisp:3:3))
GSC AC                   move (p)  loca          slloc
GSC AC                   if        slloc <= 0
GSC AC                   eval      slloc = slloc + 100
GSC AC                   endif
GSC A
GSC AC                   eval      lvla    = %subst(sidisp:6:1)
GSC AC                   move (p)  lvla          slrlvl
GSC AC                   eval      slrlvl = slrlvl + 1
GSC A
GSC A*   Special reserved slot. Don't break out handstack characters.
GSC AC                   if        %subst(sidisp:7:3) = 'OVR'
GSC AC                   eval      slhand  = '  '
GSC AC                   else
GSC AC                   evalr     slhand  = %trimr(%subst(sidisp:7:2))
GSC AC                   endif
GSC AC                   if        slhand > ' '
GSC AC                   eval      handstack = *on
GSC AC                   endif
GSC AC                   eval      dashpos = -1
GSC A
GSC A*  No dashes specified. Extract out slot breakdown.
GSC AC                   other
GSC AC
GSC AC                   eval      kydisp = %subst(sidisp:1:12)
GSC AC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
GSC A
GSC AC                   evalr     loca    = %trimr(%subst(sidisp:3:3))
GSC AC                   move      loca          slloc
GSC AC                   eval      slrlvl  = slrlvl + 1
GSC A
GSC AC                   eval      lvla    = %subst(sidisp:6:1)
GSC AC                   move      lvla          slrlvl
GSC AC                   eval      slrlvl  = slrlvl + 1
GSC A
GSC A*   Special reserved slot. Don't break out handstack characters.
GSC AC                   if        %subst(sidisp:7:3) = 'OVR'
GSC AC                   eval      slhand  = '  '
GSC AC                   else
GSC AC                   evalr     slhand  = %trimr(%subst(sidisp:7:2))
GSC AC                   endif
GSC AC                   if        slhand > ' '
GSC AC                   eval      handstack = *on
GSC AC                   endif
GSC AC                   eval      dashpos = -1
GSC A
GSC AC                   endsl
GSC A
GSC A
GSC A*  Begin testing parts for ALL slots.
GSC AC                   testn                   loca                 5050
GSC AC                   if        *in50 = *off
GSC AC                   eval      locnotnum = *on
GSC A
GSC AC                   else
GSC A
GSC AC                   if        %subst(sidisp:7:3) = 'OVR'
GSC AC                   eval      slloc = slloc + 200
GSC AC                   endif
GSC A
GSC AC                   endif
GSC A
GSC AC                   testn                   lvla                 50
GSC AC                   if        *in50 = *off
GSC AC                   eval      lvlnotnum = *on
GSC AC                   else
GSC AC                   select
GSC AC                   when      slrlvl = 0
GSC AC                   eval      slrlvl = slrlvl + 1
GSC AC                   when      slrlvl < 0
GSC AC                   eval      slrlvl = slrlvl * -1
GSC AC                   endsl
GSC AC                   endif
GSC A
GSC A*    Convert numeric handstack to alpha character.
GSC A
GSC AC                   if            slhand >= ' 0'
GSC AC                             and slhand <= '99'
GSC AC                   eval      wkchar = slhand
GSC AC                   exsr      zzcvt2ltr
GSC AC                   eval      slhand = nwchar
GSC AC                   endif
GSC A
GSC AC     slloc         div       2             dummy
GSC AC                   mvr                     oddeven
GSC AC                   if        oddeven <> 0
GSC AC                   eval      slside = 1
GSC AC                   else
GSC AC                   eval      slside = 0
GSC AC                   endif
GSC A*
GSC A*    Check if base slot exists for imported slot with handstacks.
GSC A*
GSC AC                   eval      crtbaseslot = *off
GSC AC                   if        handstack = *on
GSC AC     keysl2b       setll     slot2
GSC AC                   if        not %equal(slot2)
GSC AC                   eval      crtbaseslot = *on
GSC AC                   endif
GSC AC                   endif
GSC A
GSC A*    See if slot meets criteria for allowing it to be created.
GSC A
GSC AC                   select
GSC A
GSC A*    If non-special slot doesn't have hypens, then don't add it.
GSC A
GSC AC                   when      dashpos = 0
GSC AC                   eval      notcreated = *on
GSC AC                   goto      endcreate2
GSC A
GSC A*    Don't allow creation if department is unknown.
GSC A
GSC AC                   when      validdept = '*NO '
GSC AC                   eval      notcreated = *on
GSC AC                   goto      endcreate2
GSC A
GSC A*    If location or level is not numeric, then don't add.
GSC A
GSC AC                   when      locnotnum or lvlnotnum
GSC AC                   eval      notcreated = *on
GSC AC                   goto      endcreate2
GSC A
GSC A*    Otherwise, slot is ok to be created.
GSC A
GSC AC                   other
GSC AC                   eval      slwhdp = siwhdp
GSC AC                   eval      sldisp = sidisp
GSC AC                   eval      slstyp = sistyp
GSC A
GSC AC                   endsl
GSC A
GSC A*    Try and create the Base slot.
GSC A
GSC AC                   if        crtbaseslot = *on
GSC A*    Save handstack for virtual slot.
GSC AC                   eval      svhand = slhand
GSC A
GSC AC                   eval      slwhse = siwhse
GSC AC                   eval      sldisp = kydisp
GSC AC                   eval      slpseq = sipseq
GSC AC                   select
GSC AC                   when      slpseq = 0
GSC AC                   eval      slpseq = slloc
GSC AC                   when      slpseq < 0
GSC AC                   eval      slpseq = slpseq * -1
GSC AC                   endsl
GSC AC                   eval      slstat = 'V '
GSC AC                   eval      slhand = '  '
GSC AC                   eval      slrsrv = sirsrv
GSC AC                   eval      slsdef = 'XX'
GSC AC                   eval      slpick = sipick
GSC A
510aMC                   write (e) slrec
GSC AC                   if        %error
GSC AC                   eval      notcreated = *on
GSC AC                   endif
GSC A*
GSC AC                   endif
GSC A
GSC A*    Try and create the imported slot.
GSC A
GSC AC                   eval      slwhse = siwhse
GSC A*
GSC A*    Replace base slot display, handstack w/ imported fields.
GSC AC                   if        crtbaseslot = *on
GSC AC                   eval      slhand = svhand
GSC AC                   eval      sldisp = sidisp
GSC AC                   endif
GSC A*
GSC AC                   eval      slpseq = sipseq
GSC AC                   select
GSC AC                   when      slpseq = 0
GSC AC                   eval      slpseq = slloc
GSC AC                   when      slpseq < 0
GSC AC                   eval      slpseq = slpseq * -1
GSC AC                   endsl
GSC AC                   if        slitem > ' '
GSC AC                   eval      slstat = 'A '
GSC AC                   Else
GSC AC                   eval      slstat = 'V '
GSC AC                   Endif
GSC A*
GSC A*    Slot has handstack, create as virtual slot.
GSC AC                   if        handstack = *on
GSC AC                   eval      slrsrv = 'V'
GSC AC                   else
GSC AC                   eval      slrsrv = sirsrv
GSC AC                   endif
GSC AC                   eval      slsdef = 'XX'
GSC AC                   eval      slpick = sipick
GSC A
510aMC                   write (e) slrec
GSC AC                   if        %error
GSC AC                   eval      notcreated = *on
GSC AC                   endif
GSC A
GSC A*    Create Virtual slot record.
GSC A
GSC AC                   if        handstack = *on
GSC AC                   eval      vswhse = slwhse
GSC AC                   eval      vswhdp = slwhdp
GSC AC                   eval      vsaisl = slaisl
GSC AC                   eval      vsloc  = slloc
GSC AC                   eval      vsrlvl = slrlvl
GSC AC                   eval      vshand = slhand
GSC AC                   eval      vsdisp = sldisp
GSC AC                   eval      vspdis = kydisp
GSC AC                   eval      vscdte = impdte
GSC AC                   eval      vsctim = imptim
GSC AC                   add       1             vsctim
510aMC                   write (e) vsrec
GSC AC                   if        %error
GSC AC                   eval      error  = *on
GSC AC                   eval      detmsg = desc(8)
GSC AC                   add       1             notcrt
GSC AC                   goto      endcreate2
GSC AC                   endif
GSC A
GSC AC                   endif
GSC A
GSC A
GSC AC     endcreate2    endsr

HAR A*----------------------------------------------------------------
HAR A*  crtslot3  Try and create physical slot.
HAR A*----------------------------------------------------------------
HAR A
HAR AC     crtslot3      begsr
HAR AC                   eval      notcreated = *off
HAR AC                   eval      handstack  = *off
HAR AC                   clear                   slrec
HAR A
HAR A*  Extract location and level. Test if they are numeric.
HAR A
HAR AC                   eval      locnotnum = *off
HAR AC                   eval      lvlnotnum = *off
HAR AC                   eval      dashpos = 0
HAR AC                   eval      loca  = ' '
HAR AC                   eval      lvla  = ' '
HAR A
HAR AC                   select
HAR A
HAR A*  Dashes specified. Triple character aisle
HAR AC                   when      %subst(sidisp:4:1) = '-'
HAR AC                             and %subst(sidisp:9:1) = '-'
HAR AC                   eval      slaisl = %subst(sidisp:1:3)
HAR AC                   eval      loca  = %subst(sidisp:5:3)
HAR AC                   move      loca          slloc
HAR AC                   if        slloc <= 0
HAR AC*                  eval      slloc = slloc + 100
HAR AC                   endif
HAR AC                   if            %subst(sidisp:10:1) >= 'A'
HAR AC                             and %subst(sidisp:10:1) <= 'Z'
HAR AC                   eval      lvla  = %subst(sidisp:10:1)
HAR AC                   evalr     wkchar = %trimr(lvla)
HAR AC                   exsr      zzcvt2nbr
HAR AC*                  evalr     lvla   = %trimr(nwchar)
HAR AC                   eval      slrlvl = %dec(nwchar:2:0)
HAR AC                   if        %subst(sidisp:10:1) = 'Z'
HAR AC                   eval      slrlvl = 08
HAR AC                   endif
HAR AC                   else
HAR AC                   eval      lvla  = %subst(sidisp:10:1)
HAR AC                   move      lvla          slrlvl
HAR1AC                   if        slrlvl >= 9
HAR1AC                   eval      slrlvl = 08
HAR1AC                   endif
HAR AC                   endif
HAR AC                   eval      slrlvl = slrlvl
HAR AC                             + ((%dec(%subst(sidisp:8:1):1:0) * 10)+1)
HAR AC                   eval      slhand  = ' ' + %subst(sidisp:11:1)
HAR AC                   if        slhand > ' '
HAR AC                   eval      handstack = *on
HAR AC                   endif
HAR AC                   eval      dashpos = 3
HAR A
HAR AC                   endsl
HAR A
HAR A
HAR A*  Begin testing parts for ALL slots.
HAR AC                   testn                   loca                 5050
HAR AC                   if        *in50 = *off
HAR AC                   eval      locnotnum = *on
HAR A
HAR AC                   else
HAR A
HAR AC                   if        %subst(sidisp:7:3) = 'OVR'
HAR AC                   eval      slloc = slloc + 200
HAR AC                   endif
HAR A
HAR AC                   endif
HAR A
HAR AC                   testn                   lvla                 50
HAR AC                   if        *in50 = *off
HAR AC                   eval      lvlnotnum = *on
HAR AC                   else
HAR AC                   select
HAR AC                   when      slrlvl = 0
HAR AC                   eval      slrlvl = slrlvl + 1
HAR AC                   when      slrlvl < 0
HAR AC                   eval      slrlvl = slrlvl * -1
HAR AC                   endsl
HAR AC                   endif
HAR A
HAR A*    Convert numeric handstack to alpha character.
HAR A
HAR AC                   if            slhand >= ' 0'
HAR AC                             and slhand <= '99'
HAR AC                   eval      wkchar = slhand
HAR AC                   exsr      zzcvt2ltr
HAR AC                   eval      slhand = nwchar
HAR AC                   endif
HAR A
HAR AC     slloc         div       2             dummy
HAR AC                   mvr                     oddeven
HAR AC                   if        oddeven <> 0
HAR AC                   eval      slside = 1
HAR AC                   else
HAR AC                   eval      slside = 0
HAR AC                   endif
HAR A*
HAR A*    Check if base slot exists for imported slot with handstacks.
HAR A*
HAR AC                   eval      crtbaseslot = *off
HAR AC                   if        handstack = *on
HAR AC     keysl2b       setll     slot2
HAR AC                   if        not %equal(slot2)
HAR AC                   eval      crtbaseslot = *on
HAR AC                   endif
HAR AC                   endif
HAR A
HAR A*    See if slot meets criteria for allowing it to be created.
HAR A
HAR AC                   select
HAR A
HAR A*    If non-special slot doesn't have hypens, then don't add it.
HAR A
HAR AC                   when      dashpos = 0
HAR AC                   eval      notcreated = *on
HAR AC                   goto      endcreate3
HAR A
HAR A*    Don't allow creation if department is unknown.
HAR A
HAR AC                   when      validdept = '*NO '
HAR AC                   eval      notcreated = *on
HAR AC                   goto      endcreate3
HAR A
HAR A*    If location or level is not numeric, then don't add.
HAR A
HAR AC                   when      locnotnum or lvlnotnum
HAR AC                   eval      notcreated = *on
HAR AC                   goto      endcreate3
HAR A
HAR A*    Otherwise, slot is ok to be created.
HAR A
HAR AC                   other
HAR AC                   eval      slwhdp = siwhdp
HAR AC                   eval      sldisp = sidisp
HAR AC                   eval      slstyp = sistyp
HAR A
HAR AC                   endsl
HAR A
HAR A*    Try and create the Base slot.
HAR A
HAR AC                   if        crtbaseslot = *on
HAR A*    Save handstack for virtual slot.
HAR AC                   eval      svhand = slhand
HAR A
HAR AC                   eval      slwhse = siwhse
HAR AC                   eval      sldisp = kydisp
HAR AC                   eval      slpseq = sipseq
HAR AC                   select
HAR AC                   when      slpseq = 0
HAR AC                   eval      slpseq = slloc
HAR AC                   when      slpseq < 0
HAR AC                   eval      slpseq = slpseq * -1
HAR AC                   endsl
HAR AC                   eval      slstat = 'V '
HAR AC                   eval      slhand = '  '
HAR AC                   eval      slrsrv = sirsrv
HAR AC                   eval      slsdef = 'XX'
HAR AC                   eval      slpick = sipick
HAR A
510aMC                   write (e) slrec
HAR AC                   if        %error
HAR AC                   eval      notcreated = *on
HAR AC                   endif
HAR A*
HAR AC                   endif
HAR A
HAR A*    Try and create the imported slot.
HAR A
HAR AC                   eval      slwhse = siwhse
HAR A*
HAR A*    Replace base slot display, handstack w/ imported fields.
HAR AC                   if        crtbaseslot = *on
HAR AC                   eval      slhand = svhand
HAR AC                   eval      sldisp = sidisp
HAR AC                   endif
HAR A*
HAR AC                   eval      slpseq = sipseq
HAR AC                   select
HAR AC                   when      slpseq = 0
HAR AC                   eval      slpseq = slloc
HAR AC                   when      slpseq < 0
HAR AC                   eval      slpseq = slpseq * -1
HAR AC                   endsl
HAR AC                   if        slitem > ' '
HAR AC                   eval      slstat = 'A '
HAR AC                   Else
HAR AC                   eval      slstat = 'V '
HAR AC                   Endif
HAR A*
HAR A*    Slot has handstack, create as virtual slot.
HAR AC                   if        handstack = *on
HAR AC                   eval      slrsrv = 'V'
HAR AC                   else
HAR AC                   eval      slrsrv = sirsrv
HAR AC                   endif
HAR AC                   eval      slsdef = 'XX'
HAR AC                   eval      slpick = sipick
HAR A
510aMC                   write (e) slrec
HAR AC                   if        %error
HAR AC                   eval      notcreated = *on
HAR AC                   endif
HAR A
HAR A*    Create Virtual slot record.
HAR A
HAR AC                   if        handstack = *on
HAR AC                   eval      vswhse = slwhse
HAR AC                   eval      vswhdp = slwhdp
HAR AC                   eval      vsaisl = slaisl
HAR AC                   eval      vsloc  = slloc
HAR AC                   eval      vsrlvl = slrlvl
HAR AC                   eval      vshand = slhand
HAR AC                   eval      vsdisp = sldisp
HAR AC                   eval      vspdis = kydisp
HAR AC                   eval      vscdte = impdte
HAR AC                   eval      vsctim = imptim
HAR AC                   add       1             vsctim
510aMC                   write (e) vsrec
HAR AC                   if        %error
HAR AC                   eval      error  = *on
HAR AC                   eval      detmsg = desc(8)
HAR AC                   add       1             notcrt
HAR AC                   goto      endcreate3
HAR AC                   endif
HAR A
HAR AC                   endif
HAR A
HAR A
HAR AC     endcreate3    endsr

ELL A*----------------------------------------------------------------
ELL A*  crtslot4  Try and create physical slot.
ELL A*----------------------------------------------------------------
ELL A
ELL AC     crtslot4      begsr
ELL AC                   eval      notcreated = *off
ELL AC                   eval      handstack  = *off
ELL AC                   clear                   slrec
ELL A
ELL A*  Extract location and level. Test if they are numeric.
ELL A
ELL AC                   eval      locnotnum = *off
ELL AC                   eval      lvlnotnum = *off
ELL AC                   eval      dashpos = 0
ELL AC                   eval      loca  = ' '
ELL AC                   eval      lvla  = ' '
ELL A
ELL AC                   select
ELL A
ELL A*  No Dashes specified. Double character aisle
ELL AC                   when      %subst(sidisp:8:1) = ' '
ELL A
ELL aC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
ELL A
ELL AC                   eval      loca  = %subst(sidisp:3:3)
ELL AC                   move      loca          slloc
ELL AC                   if        slloc <= 0
ELL AC                   eval      slloc = slloc + 100
ELL AC                   endif
ELL A
ELL AC                   eval      lvla  = %subst(sidisp:6:1)
ELL AC                   move      lvla          slrlvl
ELL AC                   eval      slrlvl = slrlvl
ELL A
ELL AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
ELL AC                   if        slhand > ' '
ELL AC***                eval      handstack = *on
ELL AC                   endif
ELL A
ELL AC                   eval      dashpos = -1
ELL A
ELL A*  No Dashes specified. Double character aisle - 8 char slot
ELL AC                   when      %subst(sidisp:8:1) > ' '
ELL A
ELL aC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
ELL A
ELL AC                   eval      loca  = %subst(sidisp:4:3)
ELL AC                   move      loca          slloc
ELL AC                   if        slloc <= 0
ELL AC                   eval      slloc = slloc + 100
ELL AC                   endif
ELL A
ELL AC                   eval      lvla  = %subst(sidisp:7:1)
ELL AC                   move      lvla          slrlvl
ELL AC                   eval      slrlvl = slrlvl
ELL A
ELL AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
ELL AC                   if        slhand > ' '
ELL AC***                eval      handstack = *on
ELL AC                   endif
ELL A
ELL AC                   eval      dashpos = -1
ELL A
ELL AC                   endsl
ELL A
ELL A
ELL A*  Begin testing parts for ALL slots.
ELL AC                   testn                   loca                 5050
ELL AC                   if        *in50 = *off
ELL AC                   eval      locnotnum = *on
ELL AC                   endif
ELL A
ELL AC                   testn                   lvla                 50
ELL AC                   if        *in50 = *off
ELL AC                   eval      lvlnotnum = *on
ELL AC                   else
ELL AC                   select
ELL AC                   when      slrlvl = 0
ELL AC                   eval      slrlvl = slrlvl + 1
ELL AC                   when      slrlvl < 0
ELL AC                   eval      slrlvl = slrlvl * -1
ELL AC                   endsl
ELL AC                   eval      slrlvl = slrlvl + 1
ELL AC                   endif
ELL A
ELL A*    Convert numeric handstack to alpha character.
ELL A
ELL AC                   if            slhand >= ' 0'
ELL AC                             and slhand <= '99'
ELL AC                   eval      wkchar = slhand
ELL AC                   exsr      zzcvt2ltr
ELL AC                   eval      slhand = nwchar
ELL AC                   endif
ELL A
ELL AC     slloc         div       2             dummy
ELL AC                   mvr                     oddeven
ELL AC                   if        oddeven <> 0
ELL AC                   eval      slside = 1
ELL AC                   else
ELL AC                   eval      slside = 0
ELL AC                   endif
ELL A*
ELL A*    Check if base slot exists for imported slot with handstacks.
ELL A*
ELL AC                   eval      crtbaseslot = *off
ELL AC                   if        handstack = *on
ELL AC     keysl2b       setll     slot2
ELL AC                   if        not %equal(slot2)
ELL AC                   eval      crtbaseslot = *on
ELL AC                   endif
ELL AC                   endif
ELL A
ELL A*    See if slot meets criteria for allowing it to be created.
ELL A
ELL AC                   select
ELL A
ELL A*    If non-special slot doesn't have hypens, then don't add it.
ELL A
ELL AC                   when      dashpos = 0
ELL AC                   eval      notcreated = *on
ELL AC                   goto      endcreate4
ELL A
ELL A*    Don't allow creation if department is unknown.
ELL A
ELL AC                   when      validdept = '*NO '
ELL AC                   eval      notcreated = *on
ELL AC                   goto      endcreate4
ELL A
ELL A*    If location or level is not numeric, then don't add.
ELL A
ELL AC                   when      locnotnum or lvlnotnum
ELL AC                   eval      notcreated = *on
ELL AC                   goto      endcreate4
ELL A
ELL A*    Otherwise, slot is ok to be created.
ELL A
ELL AC                   other
ELL AC                   eval      slwhdp = siwhdp
ELL AC                   eval      sldisp = sidisp
ELL AC                   eval      slstyp = sistyp
ELL A
ELL AC                   endsl
ELL A
ELL A*    Try and create the Base slot.
ELL A
ELL AC                   if        crtbaseslot = *on
ELL A*    Save handstack for virtual slot.
ELL AC                   eval      svhand = slhand
ELL A
ELL AC                   eval      slwhse = siwhse
ELL AC                   eval      sldisp = kydisp
ELL AC                   eval      slpseq = sipseq
ELL AC                   select
ELL AC                   when      slpseq = 0
ELL AC                   eval      slpseq = slloc
ELL AC                   when      slpseq < 0
ELL AC                   eval      slpseq = slpseq * -1
ELL AC                   endsl
ELL AC                   eval      slstat = 'V '
ELL AC                   eval      slhand = '  '
ELL AC                   eval      slrsrv = sirsrv
ELL AC                   eval      slsdef = 'XX'
ELL AC                   eval      slpick = sipick
ELL A
510aMC                   write (e) slrec
ELL AC                   if        %error
ELL AC                   eval      notcreated = *on
ELL AC                   endif
ELL A*
ELL AC                   endif
ELL A
ELL A*    Try and create the imported slot.
ELL A
ELL AC                   eval      slwhse = siwhse
ELL A*
ELL A*    Replace base slot display, handstack w/ imported fields.
ELL AC                   if        crtbaseslot = *on
ELL AC                   eval      slhand = svhand
ELL AC                   eval      sldisp = sidisp
ELL AC                   endif
ELL A*
ELL AC                   eval      slpseq = sipseq
ELL AC                   select
ELL AC                   when      slpseq = 0
ELL AC                   eval      slpseq = slloc
ELL AC                   when      slpseq < 0
ELL AC                   eval      slpseq = slpseq * -1
ELL AC                   endsl
ELL AC                   if        slitem > ' '
ELL AC                   eval      slstat = 'A '
ELL AC                   Else
ELL AC                   eval      slstat = 'V '
ELL AC                   Endif
ELL A*
ELL A*    Slot has handstack, create as virtual slot.
ELL AC                   if        handstack = *on
ELL AC                   eval      slrsrv = 'V'
ELL AC                   else
ELL AC                   eval      slrsrv = sirsrv
ELL AC                   endif
ELL AC                   eval      slsdef = 'XX'
ELL AC                   eval      slpick = sipick
ELL A
510aMC                   write (e) slrec
ELL AC                   if        %error
ELL AC                   eval      notcreated = *on
ELL AC                   endif
ELL A
ELL A*    Create Virtual slot record.
ELL A
ELL AC                   if        handstack = *on
ELL AC                   eval      vswhse = slwhse
ELL AC                   eval      vswhdp = slwhdp
ELL AC                   eval      vsaisl = slaisl
ELL AC                   eval      vsloc  = slloc
ELL AC                   eval      vsrlvl = slrlvl
ELL AC                   eval      vshand = slhand
ELL AC                   eval      vsdisp = sldisp
ELL AC                   eval      vspdis = kydisp
ELL AC                   eval      vscdte = impdte
ELL AC                   eval      vsctim = imptim
ELL AC                   add       1             vsctim
510aMC                   write (e) vsrec
ELL AC                   if        %error
ELL AC                   eval      error  = *on
ELL AC                   eval      detmsg = desc(8)
ELL AC                   add       1             notcrt
ELL AC                   goto      endcreate4
ELL AC                   endif
ELL A
ELL AC                   endif
ELL A
ELL A
ELL AC     endcreate4    endsr

SGC A*----------------------------------------------------------------
SGC A*  crtslot5  Try and create physical slot.
SGC A*----------------------------------------------------------------
SGC A
SGC AC     crtslot5      begsr
SGC AC                   eval      notcreated = *off
SGC AC                   eval      handstack  = *off
SGC AC                   clear                   slrec
SGC A
SGC A*  Extract location and level. Test if they are numeric.
SGC A
SGC AC                   eval      locnotnum = *off
SGC AC                   eval      lvlnotnum = *off
SGC AC                   eval      dashpos = 0
SGC AC                   eval      loca  = ' '
SGC AC                   eval      lvla  = ' '
SGCaA
SGCaA*  Check for all alpha slot. If no digits, default slot location
SGCaA*  will be assigned.
SGCaAC                   If            %subst(sidisp:3:2) >= '00'
SGCaAC                             and %subst(sidisp:3:2) <= '99'
SGCdA*
SGCdAC                             or  %subst(sidisp:3:3) >= '000'
SGCdAC                             and %subst(sidisp:3:3) <= '999'
SGCaAC                   eval      allchrslot = *off
SGCaAC                   else
SGCaAC                   eval      allchrslot = *on
SGCaAC                   endif
SGC A
SGC AC                   select
SGCaA
SGCaA*  No dashes specified. All character slot.
SGC A*
SGCaAC                   when      allchrslot = *on
SGCaAC
SGCaAC                   eval      kydisp = sidisp
SGCaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
SGCaAC
SGCaAC                   eval      dftlocation = dftlocation + 1
SGCaAC                   eval      loca   = %char(dftlocation)
SGCaAC                   eval      slloc  = dftlocation
SGCaAC
SGCaAC                   eval      slrlvl = 1
SGCaAC                   eval      lvla   = '1'
SGCaAC
SGCaAC                   eval      slhand  = '  '
SGCaAC                   eval      dashpos = -1
SGCdA
SGCdA*  Dashes specified. Double character aisle
SGCdAC                   when          %subst(sidisp:3:1) = '-'
SGCdAC                             and %subst(sidisp:7:1) = ' '
SGCdA
SGCdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SGCdA
SGCdAC                   eval      loca  = '0' + %subst(sidisp:5:2)
SGCdAC                   move      loca          slloc
SGCdA
SGCdAC                   eval      lvla  = %subst(sidisp:4:1)
SGCdAC                   move      lvla          slrlvl
SGCdAC                   eval      slrlvl = slrlvl
SGCdA
SGCdAC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
SGCdAC                   if        slhand > ' '
SGCdAC***                eval      handstack = *on
SGCdAC                   endif
SGCdA
SGCdAC                   eval      dashpos = 3
SGC A
SGC A*  No Dashes specified. Double character aisle
SGC AC                   when      %subst(sidisp:7:1) = ' '
SGC A
SGC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SGC A
SGCdDC*                  eval      loca  = '0' + %subst(sidisp:3:2)
SGCdMC                   eval      loca  = '0' + %subst(sidisp:4:2)
SGC AC                   move      loca          slloc
SGC AC                   if        slloc <= 0
SGCdAC*                  eval      slloc = slloc + 100
SGC AC                   endif
SGC A
SGCdDC*                  eval      lvla  = %subst(sidisp:5:1)
SGCdMC                   eval      lvla  = %subst(sidisp:3:1)
SGC AC                   move      lvla          slrlvl
SGC AC                   eval      slrlvl = slrlvl
SGC A
SGC AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
SGC AC                   if        slhand > ' '
SGC AC***                eval      handstack = *on
SGC AC                   endif
SGC A
SGC AC                   eval      dashpos = -1
SGC A
SGC A*  No Dashes specified. Double character aisle - 9 char slot
SGC AC                   when      %subst(sidisp:7:1) > ' '
SGC A
SGC AC                   eval      slaisl = %subst(sidisp:1:3)
SGC A
SGC AC                   eval      loca  = '0' + %subst(sidisp:4:2)
SGC AC                   move      loca          slloc
SGC AC                   if        slloc <= 0
SGC AC                   eval      slloc = slloc + 100
SGC AC                   endif
SGC A
SGC AC                   eval      lvla  = %subst(sidisp:6:1)
SGC AC                   move      lvla          slrlvl
SGC AC                   eval      slrlvl = slrlvl
SGC A
SGC AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
SGC AC                   if        slhand > ' '
SGC AC***                eval      handstack = *on
SGC AC                   endif
SGC A
SGC AC                   eval      dashpos = -1
SGC A
SGC AC                   endsl
SGC A
SGC A
SGC A*  Begin testing parts for ALL slots.
SGC AC                   testn                   loca                 5050
SGC AC                   if        *in50 = *off
SGC AC                   eval      locnotnum = *on
SGC AC                   endif
SGC A
SGC AC                   testn                   lvla                 50
SGC AC                   if        *in50 = *off
SGC AC                   eval      lvlnotnum = *on
SGC AC                   else
SGC AC                   select
SGC AC                   when      slrlvl = 0
SGC AC                   eval      slrlvl = slrlvl + 1
SGC AC                   when      slrlvl < 0
SGC AC                   eval      slrlvl = slrlvl * -1
SGC A*
SGCaAC                   other
SGCdDC*                  eval      slrlvl = slrlvl + 1
SGC A*
SGC AC                   endsl
SGC AC***                eval      slrlvl = slrlvl + 1
SGC AC                   endif
SGC A
SGC A*    Convert numeric handstack to alpha character.
SGC A
SGC AC                   if            slhand >= ' 0'
SGC AC                             and slhand <= '99'
SGC AC                   eval      wkchar = slhand
SGC AC                   exsr      zzcvt2ltr
SGC AC                   eval      slhand = nwchar
SGC AC                   endif
SGC A
SGC AC     slloc         div       2             dummy
SGC AC                   mvr                     oddeven
SGC AC                   if        oddeven <> 0
SGC AC                   eval      slside = 1
SGC AC                   else
SGC AC                   eval      slside = 0
SGC AC                   endif
SGC A*
SGC A*    Check if base slot exists for imported slot with handstacks.
SGC A*
SGC AC                   eval      crtbaseslot = *off
SGC AC                   if        handstack = *on
SGC AC     keysl2b       setll     slot2
SGC AC                   if        not %equal(slot2)
SGC AC                   eval      crtbaseslot = *on
SGC AC                   endif
SGC AC                   endif
SGC A
SGC A*    See if slot meets criteria for allowing it to be created.
SGC A
SGC AC                   select
SGC A
SGC A*    If non-special slot doesn't have hypens, then don't add it.
SGC A
SGC AC                   when      dashpos = 0
SGC AC                   eval      notcreated = *on
SGC AC                   goto      endcreate5
SGC A
SGC A*    Don't allow creation if department is unknown.
SGC A
SGC AC                   when      validdept = '*NO '
SGC AC                   eval      notcreated = *on
SGC AC                   goto      endcreate5
SGC A
SGC A*    If location or level is not numeric, then don't add.
SGC A
SGC AC                   when      locnotnum or lvlnotnum
SGC AC                   eval      notcreated = *on
SGC AC                   goto      endcreate5
SGC A
SGC A*    Otherwise, slot is ok to be created.
SGC A
SGC AC                   other
SGC AC                   eval      slwhdp = siwhdp
SGC AC                   eval      sldisp = sidisp
SGC AC                   eval      slstyp = sistyp
SGC A
SGC AC                   endsl
SGC A
SGC A*    Try and create the Base slot.
SGC A
SGC AC                   if        crtbaseslot = *on
SGC A*    Save handstack for virtual slot.
SGC AC                   eval      svhand = slhand
SGC A
SGC AC                   eval      slwhse = siwhse
SGC AC                   eval      sldisp = kydisp
SGC AC                   eval      slpseq = sipseq
SGC AC                   select
SGC AC                   when      slpseq = 0
SGC AC                   eval      slpseq = slloc
SGC AC                   when      slpseq < 0
SGC AC                   eval      slpseq = slpseq * -1
SGC AC                   endsl
SGC AC                   eval      slstat = 'V '
SGC AC                   eval      slhand = '  '
SGC AC                   eval      slrsrv = sirsrv
SGCeAC                   if        sidgtp > ''
SGCeAC                   eval      slsdef = sidgtp
SGCeAC                   else
SGC AC                   eval      slsdef = 'XY'
SGCeAC                   endif
SGC AC                   eval      slpick = sipick
SGC A
510aMC                   write (e) slrec
SGC AC                   if        %error
SGC AC                   eval      notcreated = *on
SGC AC                   endif
SGC A*
SGC AC                   endif
SGC A
SGC A*    Try and create the imported slot.
SGC A
SGC AC                   eval      slwhse = siwhse
SGC A*
SGC A*    Replace base slot display, handstack w/ imported fields.
SGC AC                   if        crtbaseslot = *on
SGC AC                   eval      slhand = svhand
SGC AC                   eval      sldisp = sidisp
SGC AC                   endif
SGC A*
SGC AC                   eval      slpseq = sipseq
SGC AC                   select
SGC AC                   when      slpseq = 0
SGC AC                   eval      slpseq = slloc
SGC AC                   when      slpseq < 0
SGC AC                   eval      slpseq = slpseq * -1
SGC AC                   endsl
SGC AC                   if        slitem > ' '
SGC AC                   eval      slstat = 'A '
SGC AC                   Else
SGC AC                   eval      slstat = 'V '
SGC AC                   Endif
SGC A*
SGC A*    Slot has handstack, create as virtual slot.
SGC AC                   if        handstack = *on
SGC AC                   eval      slrsrv = 'V'
SGC AC                   else
SGC AC                   eval      slrsrv = sirsrv
SGC AC                   endif
SGCeAC                   if        sidgtp > ''
SGCeAC                   eval      slsdef = sidgtp
SGCeAC                   else
SGC AC                   eval      slsdef = 'XY'
SGCeAC                   endif
SGC AC                   eval      slpick = sipick
SGC A
510aMC                   write (e) slrec
SGC AC                   if        %error
SGC AC                   eval      notcreated = *on
SGC AC                   endif
SGC A
SGC A*    Create Virtual slot record.
SGC A
SGC AC                   if        handstack = *on
SGC AC                   eval      vswhse = slwhse
SGC AC                   eval      vswhdp = slwhdp
SGC AC                   eval      vsaisl = slaisl
SGC AC                   eval      vsloc  = slloc
SGC AC                   eval      vsrlvl = slrlvl
SGC AC                   eval      vshand = slhand
SGC AC                   eval      vsdisp = sldisp
SGC AC                   eval      vspdis = kydisp
SGC AC                   eval      vscdte = impdte
SGC AC                   eval      vsctim = imptim
SGC AC                   add       1             vsctim
510aMC                   write (e) vsrec
SGC AC                   if        %error
SGC AC                   eval      error  = *on
SGC AC                   eval      detmsg = desc(8)
SGC AC                   add       1             notcrt
SGC AC                   goto      endcreate5
SGC AC                   endif
SGC A
SGC AC                   endif
SGC A
SGC A
SGC AC     endcreate5    endsr

SGCcA*----------------------------------------------------------------
SGCcA*  crtslot5OSS  Create special OSS slot for Willow/Kansas slots
SGCcA*----------------------------------------------------------------
SGCcA
SGCcAC     crtslot5OSS   begsr
     C                   eval      notcreated = *off
     C                   eval      handstack  = *off
     C                   clear                   slrec

     C                   select
     C                   when      sgcKansas
     C                   eval      wkStgLoc = 'K'
     C                   eval      #rcvArea = 'KANSAS'
     C                   when      sgcWillow
     C                   eval      wkStgLoc = 'W'
     C                   eval      #rcvArea = 'WILLOW'
     C                   endsl

     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm      siwhse        wkWhse
     C                   parm                    wkStgLoc
     C                   parm      ' '           wkLcns

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = siwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = siwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = siitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = sistyp
     C                   if        fifodate > 0
     C                   eval      $slentdu = *on
     C                   eval      $slentd = fifodate
     C                   endif
     C                   if        itflgd = 'Y' and fifodate > 0
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = fifodate
     C                   endif
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = siitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saqty1 = siqty1
     C                   if        itflg1 = 'Y'
     C                             or ssbflg = *on
     C                   eval      $saqty2 = siqty2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      $saqty3 = siqty3
     C                   endif

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'IMP'
     C*                  eval      $saTrn#U = *on
     C*                  eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C*                  eval      $saLbl#U = *on
     C*                  eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = wkLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = wkLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   if        notcreated
     C                   eval      detmsg = desc(13)
     C                   add       1             notcrt
     C                   leavesr
     C                   endif
     C                   endif

     *  Initialize some SL fields in case they are needed somewhere else.

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = $slwhdp
     C                   eval      sldisp = $sldisp
     C                   eval      slaisl = $slaisl
     C                   eval      slloc  = $slloc
     C                   eval      slrlvl = $slrlvl
     C                   eval      slhand = $slhand
     C                   eval      slstyp = $slstyp
     C                   eval      sldesg = $sldesg
     C                   eval      slsdef = $slsdef
     C                   eval      slstk1 = $slstk1
     C                   eval      slstk2 = $slstk2
     C                   eval      slstk3 = $slstk3

     C                   endsr

     *----------------------------------------------------------------
CWH A*  crtslot6  Try and create physical slot.
CWH A*----------------------------------------------------------------
CWH A
CWH AC     crtslot6      begsr
CWH AC                   eval      notcreated = *off
CWH AC                   eval      handstack  = *off
CWH AC                   clear                   slrec
CWH A
CWH A*  Extract location and level. Test if they are numeric.
CWH A
CWH AC                   eval      locnotnum = *off
CWH AC                   eval      lvlnotnum = *off
CWH AC                   eval      dashpos = 0
CWH AC                   eval      loca  = ' '
CWH AC                   eval      lvla  = ' '
CWH A
CWH AC                   select
CWH A
CWH A*  No Dashes specified. Single character aisle
CWHaMC                   when      %subst(sidisp:8:1) = ' '
CWH A
CWHaMC                   eval      kydisp = %subst(sidisp:1:7)
CWHaMC                   evalr     slaisl  = %trimr(%subst(sidisp:1:3))
CWH AC
CWHaMC                   evalr     loca    = %trimr(%subst(sidisp:4:2) +
CWHaMC                                       (%subst(sidisp:7:1)))
CWH AC                   move (p)  loca          slloc
CWH AC
CWHaMC                   eval      lvla    = %subst(sidisp:6:1)
CWH AC                   move (p)  lvla          slrlvl
CWH DC                   eval      slrlvl  = slrlvl + 1
CWH A
CWHaMC                   evalr     slhand  = %trimr(%subst(sidisp:8:1))
CWH AC                   if        slhand > ' '
CWH AC                   endif
CWH A
CWH AC                   eval      dashpos = -1
CWH A
CWH AC                   endsl
CWH A
CWH A
CWH A*  Begin testing parts for ALL slots.
CWH AC                   testn                   loca                 5050
CWH AC                   if        *in50 = *off
CWH AC                   eval      locnotnum = *on
CWH AC                   endif
CWH A
CWH AC                   testn                   lvla                 50
CWH AC                   if        *in50 = *off
CWH AC                   eval      lvlnotnum = *on
CWH AC                   else
CWH AC                   select
CWH AC                   when      slrlvl = 0
CWH AC                   eval      slrlvl = slrlvl + 1
CWH AC                   when      slrlvl < 0
CWH AC                   eval      slrlvl = slrlvl * -1
CWH AC                   endsl
CWH AC***                eval      slrlvl = slrlvl + 1
CWH AC                   endif
CWH A
CWH A*    Convert numeric handstack to alpha character.
CWH A
CWH AC                   if            slhand >= ' 0'
CWH AC                             and slhand <= '99'
CWH AC                   eval      wkchar = slhand
CWH AC                   exsr      zzcvt2ltr
CWH AC                   eval      slhand = nwchar
CWH AC                   endif
CWH A
CWH AC                   eval      loca_x  = ' '
CWH AC                   evalr     loca_x  = %trimr(%subst(sidisp:2:2))
CWH AC                   move (p)  loca_x        loc2_3
CWH AC     loc2_3        div       2             dummy
CWH AC                   mvr                     oddeven
CWH AC                   if        oddeven <> 0
CWH AC                   eval      slside = 1
CWH AC                   else
CWH AC                   eval      slside = 0
CWH AC                   endif
CWH A*
CWH A*    Check if base slot exists for imported slot with handstacks.
CWH A*
CWH AC                   eval      crtbaseslot = *off
CWH AC                   if        handstack = *on
CWH AC     keysl2b       setll     slot2
CWH AC                   if        not %equal(slot2)
CWH AC                   eval      crtbaseslot = *on
CWH AC                   endif
CWH AC                   endif
CWH A
CWH A*    See if slot meets criteria for allowing it to be created.
CWH A
CWH AC                   select
CWH A
CWH A*    If non-special slot doesn't have hypens, then don't add it.
CWH A
CWH AC                   when      dashpos = 0
CWH AC                   eval      notcreated = *on
CWH AC                   goto      endcreate6
CWH A
CWH A*    Don't allow creation if department is unknown.
CWH A
CWH AC                   when      validdept = '*NO '
CWH AC                   eval      notcreated = *on
CWH AC                   goto      endcreate6
CWH A
CWH A*    If location or level is not numeric, then don't add.
CWH A
CWH AC                   when      locnotnum or lvlnotnum
CWH AC                   eval      notcreated = *on
CWH AC                   goto      endcreate6
CWH A
CWH A*    Otherwise, slot is ok to be created.
CWH A
CWH AC                   other
CWH AC                   eval      slwhdp = siwhdp
CWH AC                   eval      sldisp = sidisp
CWH AC                   eval      slstyp = sistyp
CWH A
CWH AC                   endsl
CWH A
CWH A*    Try and create the Base slot.
CWH A
CWH AC                   if        crtbaseslot = *on
CWH A*    Save handstack for virtual slot.
CWH AC                   eval      svhand = slhand
CWH A
CWH AC                   eval      slwhse = siwhse
CWH AC                   eval      sldisp = kydisp
CWH AC                   eval      slpseq = sipseq
CWH AC                   select
CWH AC                   when      slpseq = 0
CWH AC                   eval      slpseq = slloc
CWH AC                   when      slpseq < 0
CWH AC                   eval      slpseq = slpseq * -1
CWH AC                   endsl
CWH AC                   eval      slstat = 'V '
CWH AC                   eval      slhand = '  '
CWH AC                   eval      slrsrv = sirsrv
CWH AC                   eval      slsdef = 'XX'
CWH AC                   eval      slpick = sipick
CWH A
CWH AC                   write (e) slrec
CWH AC                   if        %error
CWH AC                   eval      notcreated = *on
CWH AC                   endif
CWH A*
CWH AC                   endif
CWH A
CWH A*    Try and create the imported slot.
CWH A
CWH AC                   eval      slwhse = siwhse
CWH A*
CWH A*    Replace base slot display, handstack w/ imported fields.
CWH AC                   if        crtbaseslot = *on
CWH AC                   eval      slhand = svhand
CWH AC                   eval      sldisp = sidisp
CWH AC                   endif
CWH A*
CWH AC                   eval      slpseq = sipseq
CWH AC                   select
CWH AC                   when      slpseq = 0
CWH AC                   eval      slpseq = slloc
CWH AC                   when      slpseq < 0
CWH AC                   eval      slpseq = slpseq * -1
CWH AC                   endsl
CWH AC                   if        slitem > ' '
CWH AC                   eval      slstat = 'A '
CWH AC                   Else
CWH AC                   eval      slstat = 'V '
CWH AC                   Endif
CWH A*
CWH A*    Slot has handstack, create as virtual slot.
CWH AC                   if        handstack = *on
CWH AC                   eval      slrsrv = 'V'
CWH AC                   else
CWH AC                   eval      slrsrv = sirsrv
CWH AC                   endif
CWH AC                   eval      slsdef = 'XX'
CWH AC                   eval      slpick = sipick
CWH A
CWH AC                   write (e) slrec
CWH AC                   if        %error
CWH AC                   eval      notcreated = *on
CWH AC                   endif
CWH A
CWH A*    Create Virtual slot record.
CWH A
CWH AC                   if        handstack = *on
CWH AC                   eval      vswhse = slwhse
CWH AC                   eval      vswhdp = slwhdp
CWH AC                   eval      vsaisl = slaisl
CWH AC                   eval      vsloc  = slloc
CWH AC                   eval      vsrlvl = slrlvl
CWH AC                   eval      vshand = slhand
CWH AC                   eval      vsdisp = sldisp
CWH AC                   eval      vspdis = kydisp
CWH AC                   eval      vscdte = impdte
CWH AC                   eval      vsctim = imptim
CWH AC                   add       1             vsctim
CWH AC                   write (e) vsrec
CWH AC                   if        %error
CWH AC                   eval      error  = *on
CWH AC                   eval      detmsg = desc(8)
CWH AC                   add       1             notcrt
CWH AC                   goto      endcreate6
CWH AC                   endif
CWH A
CWH AC                   endif
CWH A
CWH A
CWH AC     endcreate6    endsr


FRF A*----------------------------------------------------------------
FRF A*  crtslot7  Fox River Foods - Create physical slot.
FRF A*----------------------------------------------------------------
FRF A
FRF AC     crtslot7      begsr
FRF A
FRF AC                   eval      allChrSlot = *off
FRF AC                   eval      notCreated = *off
FRF AC                   eval      handStack  = *off

FRF AC                   clear                   slrec
FRF A
FRF A*  Extract location and level. Test if they are numeric.
FRF A
FRF AC                   eval      locNotNum = *off
FRF AC                   eval      lvlNotNum = *off

FRF AC                   eval      dashPos = 0

FRF AC                   eval      loca  = ' '
FRF AC                   eval      lvla  = ' '
FRF A
FRF AC                   select
FRFiA
FRFiA*  No Dashes specified. Double character aisle with Handstacks.
FRFiA
FRFiAC                   when      %subst(sidisp:6:1) > ' '
FRFiA
FRFiAC                   eval      kydisp = %subst(sidisp:1:5)
FRFiAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FRFiAC                   eval      loca  = '0' + %subst(sidisp:3:2)
FRFiA
FRFiAC                   testn                   loca                 5050
FRFiA
FRFiAC                   if        *in50 = *off
FRFiAC                   eval      locnotnum = *on
FRFiAC                   else
FRFiAC                   move (p)  loca          slloc
FRFiAC***                eval      slloc = slloc + 100
FRFiAC                   endif
FRFiA
FRFiAC                   eval      lvla    = %subst(sidisp:5:1)
FRFiAC                   testn                   lvla                 50
FRFiA
FRFiAC                   if        *in50 = *off
FRFiAC                   eval      lvlnotnum = *on
FRFiAC                   else
FRFiAC                   move (p)  lvla          slrlvl
FRFiAC***                eval      slrlvl = slrlvl + 1
FRFiAC                   endif
FRFiA
FRFiAC                   evalr     slhand = %trimr(%subst(sidisp:6:1))
FRF A
FRF A*  No Dashes specified. Double character aisle

FRFaMC                   when      %subst(sidisp:6:1) = ' '
FRF A
FRFaMC                   eval      kydisp = %subst(sidisp:1:5)
FRF AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FRF AC                   eval      loca  = '0' + %subst(sidisp:3:2)
FRF A
FRF AC                   testn                   loca                 5050
FRF A
FRF AC                   if        *in50 = *off
FRF AC                   eval      locnotnum = *on
FRF AC                   else
FRF AC                   move (p)  loca          slloc
FRF AC**                 if        slloc <= 0
FRF AC**                 eval      slloc = 1
FRF AC                   eval      slloc = slloc + 100
FRF AC**                 endif
FRF AC                   endif
FRF A
FRFaMC                   eval      lvla    = %subst(sidisp:5:1)
FRF AC                   testn                   lvla                 50
FRF A
FRF AC                   if        *in50 = *off
FRF AC                   eval      lvlnotnum = *on
FRF AC                   else
FRF AC                   move (p)  lvla          slrlvl
FRF AC**                 if        slrlvl <= 0
FRF AC                   eval      slrlvl = slrlvl + 1
FRF AC**                 endif
FRF AC                   endif
FRF A
FRF AC                   endsl
FRF A*
FRF A*    Check if base slot exists for imported slot with handstacks.
FRF A*
FRF AC                   eval      crtbaseslot = *off
FRF AC                   if        handstack = *on
FRF AC     keysl2b       setll     slot2
FRF AC                   if        not %equal(slot2)
FRF AC                   eval      crtbaseslot = *on
FRF AC                   endif
FRF AC                   endif
FRF A
FRF A*    See if slot meets criteria for allowing it to be created.
FRF A
FRF AC                   select
FRF A
FRF A*    If non-special slot doesn't have hypens, then don't add it.
FRF A
FRF AC*                  when      dashpos = 0
FRF AC*                  eval      notcreated = *on
FRF AC*                  goto      endcreate7
FRF A
FRF A*    Don't allow creation if department is unknown.
FRF A
FRF AC                   when      validdept = '*NO '
FRF AC                   eval      notcreated = *on
FRF AC                   goto      endcreate7
FRF A
FRF A*    If location or level is not numeric, then don't add.
FRF A
FRF AC                   when      locnotnum or lvlnotnum
FRF AC                   eval      notcreated = *on
FRF AC                   goto      endcreate7
FRF A
FRF A*    Otherwise, slot is ok to be created.
FRF A
FRF AC                   other
FRF A
FRF AC                   eval      slwhdp = siwhdp
FRF AC                   eval      sldisp = sidisp
FRF AC                   eval      slstyp = sistyp
FRFbAC                   eval      slpick = sipick
FRFbAC                   eval      slrsrv = sirsrv
FRFiA*
FRFiAC                   if        sidgtp > ' '
FRFiAC                   eval      slsdef = sidgtp
FRFiAC                   else
FRFiA*
FRFbAC                   eval      slsdef = 'XX'
FRFiAC                   endif
FRF A
FRF AC                   endsl
FRF A
FRF A*    Try and create the Base slot.
FRF A
FRF AC                   if        crtbaseslot = *on
FRF A*    Save handstack for virtual slot.
FRF AC                   eval      svhand = slhand
FRF A
FRF AC                   eval      slwhse = siwhse
FRF AC                   eval      sldisp = kydisp
FRF AC                   eval      slpseq = sipseq
FRF A
FRF AC                   select
FRF AC                   when      slpseq = 0
FRF AC                   eval      slpseq = slloc
FRF AC                   when      slpseq < 0
FRF AC                   eval      slpseq = slpseq * -1
FRF AC                   endsl
FRF A
FRF AC                   eval      slstat = 'V '
FRF AC                   eval      slhand = '  '
FRF AC                   eval      slrsrv = sirsrv
FRF AC                   eval      slsdef = 'XX'
FRF AC                   eval      slpick = sipick
FRF A*
FRF A* SLOT2 FILE
FRF A*
FRF AC                   write (e) slrec
FRF A
FRF AC                   if        %error
FRF AC                   eval      notcreated = *on
FRF AC                   endif
FRF A*
FRF AC                   endif
FRF A
FRF A*    Try and create the imported slot.
FRF A
FRF AC                   eval      slwhse = siwhse
FRF A*
FRF A*    Replace base slot display, handstack w/ imported fields.
FRF A*
FRF AC                   if        crtbaseslot = *on
FRF AC                   eval      slhand = svhand
FRF AC                   eval      sldisp = sidisp
FRF AC                   endif
FRF A*
FRF AC                   eval      slpseq = sipseq
FRF A*
FRF AC                   select
FRF AC                   when      slpseq = 0
FRF AC                   eval      slpseq = slloc
FRF AC                   when      slpseq < 0
FRF AC                   eval      slpseq = slpseq * -1
FRF AC                   endsl
FRF A
FRF AC                   if        slitem > ' '
FRF AC                   eval      slstat = 'A '
FRF AC                   Else
FRF AC                   eval      slstat = 'V '
FRF AC                   Endif
FRF A*
FRF A*    Slot has handstack, create as virtual slot.
FRF A*
FRF AC                   if        handstack = *on
FRF AC                   eval      slrsrv = 'V'
FRF AC                   else
FRF AC                   eval      slrsrv = sirsrv
FRF AC                   endif
FRF A
FRF AC                   eval      slsdef = 'XX'
FRF AC                   eval      slpick = sipick
FRF A
FRF AC                   write (e) slrec
FRF A
FRF AC                   if        %error
FRF AC                   eval      notcreated = *on
FRF AC                   endif
FRF A
FRF A*    Create Virtual slot record.
FRF A
FRF AC                   if        handstack = *on
FRF AC                   eval      vswhse = slwhse
FRF AC                   eval      vswhdp = slwhdp
FRF AC                   eval      vsaisl = slaisl
FRF AC                   eval      vsloc  = slloc
FRF AC                   eval      vsrlvl = slrlvl
FRF AC                   eval      vshand = slhand
FRF AC                   eval      vsdisp = sldisp
FRF AC                   eval      vspdis = kydisp
FRF AC                   eval      vscdte = impdte
FRF AC                   eval      vsctim = imptim
FRF AC                   add       1             vsctim
FRF A
FRF AC                   write (e) vsrec
FRF A
FRF AC                   if        %error
FRF AC                   eval      error  = *on
FRF AC                   eval      detmsg = desc(8)
FRF AC                   add       1             notcrt
FRF AC                   goto      endcreate7
FRF AC                   endif
FRF A
FRF AC                   endif
FRF A
FRF AC     endcreate7    endsr
FRF
IFD A*----------------------------------------------------------------
IFD A*  crtslot8  Try and create physical slot.
IFD A*----------------------------------------------------------------
IFD A
IFD AC     crtslot8      begsr
IFD AC                   eval      notcreated = *off
IFD A
IFD A*  Turn on SlotCreated flag even if slot isn't created
IFD A*  so ZZUPD routine doesn't get executed.
IFD AC                   eval      slotcreated= *on
IFD AC                   eval      handstack  = *off
IFD AC                   clear                   slrec
IFD A
IFD A*  Extract location and level. Test if they are numeric.
IFD A
IFD AC                   eval      locnotnum = *off
IFD AC                   eval      lvlnotnum = *off
IFD AC                   eval      dashpos = 0
IFD AC                   eval      loca  = ' '
IFD AC                   eval      lvla  = ' '
IFD A
IFD A*  Check for all alpha slot. If no digits, default slot location
IFD A*  will be assigned.
IFD AC                   If            %subst(sidisp:2:2) >= '00'
IFD AC                             and %subst(sidisp:2:2) <= '99'
IFD AC                             or  %subst(sidisp:3:2) >= '00'
IFD AC                             and %subst(sidisp:3:2) <= '99'
IFD AC                   eval      allchrslot = *off
IFD AC                   else
IFD AC                   eval      allchrslot = *on
IFD AC                   endif
IFD A
IFD AC                   select
IFD A
IFD A*  No Dashes specified. Single character aisle
IFD AC                   when          %subst(sidisp:2:2) >= '00'
IFD AC                             and %subst(sidisp:2:2) <= '99'
IFD AC                   eval      dashpos = -1
IFD AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
IFD AC                   eval      loca  = %subst(sidisp:2:2) +
IFD AC                                     %subst(sidisp:5:1)
IFD AC                   if        %subst(loca:3:1) = ' '
IFD AC                   eval      loca = %subst(loca:1:2) + '0'
IFD AC                   endif
IFD AC                   move      loca          slloc
IFD AC                   eval      lvla  = %subst(sidisp:4:1)
IFD AC                   move      lvla          slrlvl
IFD AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
IFD AC                   if        slhand > ' '
IFD AC                   eval      handstack = *on
IFD AC                   endif
IFD A
IFD A*  No Dashes specified. Double character aisle
IFD AC                   when          %subst(sidisp:3:2) >= '00'
IFD AC                             and %subst(sidisp:3:2) <= '99'
IFD AC                   eval      dashpos = -1
IFD AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
IFD AC                   eval      loca  = %subst(sidisp:3:2) +
IFD AC                                     %subst(sidisp:6:1)
IFD AC                   if        %subst(loca:3:1) = ' '
IFD AC                   eval      loca = %subst(loca:1:2) + '0'
IFD AC                   endif
IFD AC                   move      loca          slloc
IFD AC                   eval      lvla  = %subst(sidisp:5:1)
IFD AC                   move      lvla          slrlvl
IFD AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
IFD AC                   if        slhand > ' '
IFD AC                   eval      handstack = *on
IFD AC                   endif
IFD A
IFD A*  No dashes specified. All character slot.
IFD AC                   when      allchrslot = *on
IFD AC
IFD AC                   eval      kydisp = sidisp
IFD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
IFD AC
IFD AC                   eval      dftlocation = dftlocation + 1
IFD AC                   eval      loca   = %char(dftlocation)
IFD AC                   eval      slloc  = dftlocation
IFD AC
IFD AC                   eval      slrlvl = 1
IFD AC                   eval      lvla   = '1'
IFD AC
IFD AC                   eval      slhand  = '  '
IFD AC                   eval      dashpos = -1
IFD A
IFD AC                   endsl
IFD A
IFD A*  Begin testing parts for ALL slots.
IFD AC                   testn                   loca                 5050
IFD AC                   if        *in50 = *off
IFD AC                   eval      locnotnum = *on
IFD A
IFD AC                   else
IFD AC                   select
IFD AC                   when      slloc  = 0
IFD AC                   eval      slloc = slloc + 100
IFD AC                   when      slloc < 0
IFD AC                   eval      slloc = slloc * -1
IFD AC                   endsl
IFD AC                   endif
IFD A
IFD AC                   testn                   lvla                 50
IFD AC                   if        *in50 = *off
IFD AC                   eval      lvlnotnum = *on
IFD AC                   else
IFD AC                   select
IFD AC                   when      slrlvl = 0
IFD AC                   eval      slrlvl = slrlvl + 10
IFD AC                   when      slrlvl < 0
IFD AC                   eval      slrlvl = slrlvl * -1
IFD AC                   endsl
IFD AC                   endif
IFD A
IFD A*    Convert numeric handstack to alpha character.
IFD A
IFD AC                   if            slhand >= ' 0'
IFD AC                             and slhand <= '99'
IFD AC                   eval      wkchar = slhand
IFD AC                   exsr      zzcvt2ltr
IFD AC                   eval      slhand = nwchar
IFD AC                   endif
IFD A
IFDcAC                   eval      loca_x  = ' '
IFDcAC                   evalr     loca_x  = %trimr(%subst(sidisp:2:2))
IFDcAC                   move (p)  loca_x        loc2_3
IFDcDC*    slloc         div       2             dummy
IFDcMC     loc2_3        div       2             dummy
IFD AC                   mvr                     oddeven
IFD AC                   if        oddeven <> 0
IFD AC                   eval      slside = 1
IFD AC                   else
IFD AC                   eval      slside = 0
IFD AC                   endif
IFD A*
IFD A*    Check if base slot exists for imported slot with handstacks.
IFD A*
IFD AC                   eval      crtbaseslot = *off
IFD AC                   if        handstack = *on
IFD AC     keysl2b       setll     slot2
IFD AC                   if        not %equal(slot2)
IFD AC                   eval      crtbaseslot = *on
IFD AC                   endif
IFD AC                   endif
IFD A
IFD A*    See if slot meets criteria for allowing it to be created.
IFD A
IFD AC                   select
IFD A
IFD A*    If non-special slot doesn't have hypens, then don't add it.
IFD A
IFD AC                   when      dashpos = 0
IFD AC                   eval      notcreated = *on
IFD AC                   goto      endcreate8
IFD A
IFD A*    Don't allow creation if department is unknown.
IFD A
IFD AC                   when      validdept = '*NO '
IFD AC                   eval      notcreated = *on
IFD AC                   goto      endcreate8
IFD A
IFD A*    If location or level is not numeric, then don't add.
IFD A
IFD AC                   when      locnotnum or lvlnotnum
IFD AC                   eval      notcreated = *on
IFD AC                   goto      endcreate8
IFD A
IFD A*    Otherwise, slot is ok to be created.
IFD A
IFD AC                   other
IFD AC                   eval      slwhdp = siwhdp
IFD AC                   eval      sldisp = sidisp
IFD AC                   eval      slstyp = sistyp
IFD A
IFD AC                   endsl
IFD A
IFD A*    Try and create the Base slot.
IFD A
IFD AC                   if        crtbaseslot = *on
IFD A*    Save handstack for virtual slot.
IFD AC                   eval      svhand = slhand
IFD A
IFD AC                   eval      slwhse = siwhse
IFD AC                   eval      sldisp = kydisp
IFD AC                   eval      slpseq = sipseq
IFD AC                   select
IFD AC                   when      slpseq = 0
IFD AC                   eval      slpseq = slloc
IFD AC                   when      slpseq < 0
IFD AC                   eval      slpseq = slpseq * -1
IFD AC                   endsl
IFD AC                   eval      slstat = 'V '
IFD AC                   eval      slhand = '  '
IFD AC                   eval      slrsrv = sirsrv
IFD AC                   eval      slsdef = 'XX'
IFD AC                   eval      slpick = sipick
IFD A
IFD AC                   write (e) slrec
IFD AC                   if        %error
IFD AC                   eval      notcreated = *on
IFD AC                   endif
IFD A*
IFD AC                   endif
IFD A
IFD A*    Try and create the imported slot.
IFD A
IFD AC                   eval      slwhse = siwhse
IFD A*
IFD A*    Replace base slot display, handstack w/ imported fields.
IFD AC                   if        crtbaseslot = *on
IFD AC                   eval      slhand = svhand
IFD AC                   eval      sldisp = sidisp
IFD AC                   endif
IFD A*
IFD AC                   eval      slpseq = sipseq
IFDbAC*
IFDbAC                   eval      pseq4 = %subst(sidisp:2:4)
IFDbAC     digits        check     pseq4                                  68
IFDbAC                   if        *in68 = *off
IFDbAC                   move      pseq4         slpseq
IFDbAC                   endif
IFDbAC*
IFD AC                   select
IFD AC                   when      slpseq = 0
IFD AC                   eval      slpseq = slloc
IFD AC                   when      slpseq < 0
IFD AC                   eval      slpseq = slpseq * -1
IFD AC                   endsl
IFD AC                   if        slitem > ' '
IFD AC                   eval      slstat = 'A'
IFD AC                   else
IFD AC                   eval      slstat = 'V'
IFD AC                   endif
IFD A*
IFD A*    Slot has handstack, create as virtual slot.
IFD AC                   if        handstack = *on
IFD AC                   eval      slrsrv = 'V'
IFD AC                   else
IFD AC                   eval      slrsrv = sirsrv
IFD AC                   endif
IFD AC                   eval      slsdef = 'XX'
IFD AC                   eval      slpick = sipick
IFD A
IFD AC                   write (e) slrec
IFD AC                   if        %error
IFD AC                   eval      notcreated = *on
IFD AC                   endif
IFD A
IFD A*    Create Virtual slot record.
IFD A
IFD AC                   if        handstack = *on
IFD AC                   eval      vswhse = slwhse
IFD AC                   eval      vswhdp = slwhdp
IFD AC                   eval      vsaisl = slaisl
IFD AC                   eval      vsloc  = slloc
IFD AC                   eval      vsrlvl = slrlvl
IFD AC                   eval      vshand = slhand
IFD AC                   eval      vsdisp = sldisp
IFD AC                   eval      vspdis = kydisp
IFD AC                   eval      vscdte = impdte
IFD AC                   eval      vsctim = imptim
IFD AC                   add       1             vsctim
IFD AC                   write (e) vsrec
IFD AC                   if        %error
IFD AC                   eval      error  = *on
IFD AC                   eval      detmsg = desc(8)
IFD AC                   add       1             notcrt
IFD AC                   goto      endcreate8
IFD AC                   endif
IFD A
IFD AC                   endif
IFD A
IFD A
IFD AC     endcreate8    endsr
FRF
EGF A*----------------------------------------------------------------
EGF A*  crtslot9  Try and create physical slot.
EGF A*----------------------------------------------------------------
EGF A
EGF AC     crtslot9      begsr
EGF AC                   eval      notcreated = *off
EGF A
EGF A*  Turn on SlotCreated flag even if slot isn't created
EGF A*  so ZZUPD routine doesn't get executed.
EGF AC                   eval      slotcreated= *on
EGF AC                   eval      handstack  = *off
EGF AC                   clear                   slrec
EGF A
EGF A*  Extract location and level. Test if they are numeric.
EGF A
EGF AC                   eval      locnotnum = *off
EGF AC                   eval      lvlnotnum = *off
EGF AC                   eval      dashpos = 0
EGF AC                   eval      loca  = ' '
EGF AC                   eval      lvla  = ' '
EGF A
EGF A*  Check for all alpha slot. If no digits, default slot location
EGF A*  will be assigned.
EGFcDC*                  If            %subst(sidisp:1:4) >= '0000'
EGFcDC*                            and %subst(sidisp:1:4) <= '9999'
EGFcMC                   If            %subst(sidisp:1:2) >= '00'
EGFcMC                             and %subst(sidisp:1:2) <= '99'
EGFcAC                             and %subst(sidisp:3:2) >= '00'
EGFcAC                             and %subst(sidisp:3:2) <= '99'
EGF AC                   eval      allchrslot = *off
EGF AC                   else
EGF AC                   eval      allchrslot = *on
EGF AC                   endif
EGF A
EGF AC                   select
EGF A
EGF A*  No dashes specified. All character slot.
EGF AC                   when      allchrslot = *on
EGF AC
EGF AC                   eval      kydisp = sidisp
EGF AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
EGF AC
EGF AC                   eval      dftlocation = dftlocation + 1
EGF AC                   eval      loca   = %char(dftlocation)
EGF AC                   eval      slloc  = dftlocation
EGF AC
EGF AC                   eval      slrlvl = 1
EGF AC                   eval      lvla   = '1'
EGF AC
EGF AC                   eval      slhand  = '  '
EGF AC                   eval      dashpos = -1
EGF A
EGFdM*  Dashes specified. Double character aisle format: nnnn-x
EGF AC                   when      %subst(sidisp:5:1) = '-'
EGFbAC                             and %subst(sidisp:6:7) > ' '
EGFdAC                             and %subst(sidisp:7:1) = ' '
EGF AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
EGF A
EGF AC                   eval      loca  = ' ' + %subst(sidisp:3:2)
EGF AC                   move      loca          slloc
EGF A
EGF A*      Convert alpha level into numeric value.
EGF AC                   eval      lvla    = %subst(sidisp:6:1)
EGF AC                   evalr     wkchar = %trimr(lvla)
EGF AC                   exsr      zzcvt2nbr
EGF AC                   evalr     lvla   = %trimr(nwchar)
EGF AC                   eval      slrlvl = %dec(nwchar:2:0)
EGF A
EGF AC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
EGF AC                   if        slhand > ' '
EGF AC*                  eval      handstack = *on
EGF AC                   endif
EGF AC                   eval      dashpos = 5
EGF A
EGFdA*  Dashes specified. Double character aisle format: nnnn-x-y
EGFdAC                   when      %subst(sidisp:5:1) = '-'
EGFdAC                             and %subst(sidisp:7:1) = '-'
EGFbAC                             and %subst(sidisp:6:7) > ' '
EGFdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
EGFdA
EGFdAC                   eval      loca  = ' ' + %subst(sidisp:3:2)
EGFdAC                   move      loca          slloc
EGFdA
EGFdA*      Convert alpha level into numeric value.
EGFdAC                   eval      lvla    = %subst(sidisp:6:1)
EGFdAC                   evalr     wkchar = %trimr(lvla)
EGFdAC                   exsr      zzcvt2nbr
EGFdAC                   evalr     lvla   = %trimr(nwchar)
EGFdAC                   eval      slrlvl = %dec(nwchar:2:0)
EGFdA
EGFdA*      Convert numeric handstack into alpha handstack value.
EGFdAC                   if        %subst(sidisp:8:1) >= '0'
EGFdAC                             and %subst(sidisp:8:1) <= '9'
EGFdAC                   evalr     wkchar = %trimr(%subst(sidisp:8:1))
EGFdAC                   exsr      zzcvt2ltr
EGFdAC                   evalr     slhand = %trimr(nwchar)
EGFdAC                   else
EGFdAC                   if        %subst(sidisp:8:1) >= 'A'
EGFdAC                             and %subst(sidisp:8:1) <= 'Z'
EGFdAC                   eval      slhand = ' ' + %subst(sidisp:8:1)
EGFdAC                   endif
EGFdAC                   endif
EGFdAC                   if        slhand > ' '
EGFdAC*                  eval      handstack = *on
EGFdAC                   endif
EGFdAC                   eval      dashpos = 5
EGFbA
EGFbA*  Dashes specified. Double character aisle. No rack lvl specified.
EGFbAC                   when      %subst(sidisp:5:8) = ' '
EGFbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
EGFbA
EGFbAC                   eval      loca  = ' ' + %subst(sidisp:3:2)
EGFbAC                   move      loca          slloc
EGFbA
EGFbA*      No level specified. Force level to A.
EGFbAC                   eval      lvla    = 'A'
EGFbAC                   evalr     wkchar = %trimr(lvla)
EGFbAC                   exsr      zzcvt2nbr
EGFbAC                   evalr     lvla   = %trimr(nwchar)
EGFbAC                   eval      slrlvl = %dec(nwchar:2:0)
EGFbA
EGFbAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
EGFbAC                   if        slhand > ' '
EGFbAC*                  eval      handstack = *on
EGFbAC                   endif
EGFbAC                   eval      dashpos = 5
EGF A
EGF AC                   endsl
EGF A
EGF A*  Begin testing parts for ALL slots.
EGF AC                   testn                   loca                 5050
EGF AC                   if        *in50 = *off
EGF AC                   eval      locnotnum = *on
EGF A
EGF AC                   else
EGF AC                   select
EGF AC                   when      slloc  = 0
EGF AC                   eval      slloc = slloc + 100
EGF A
EGF AC                   when      slloc < 0
EGF AC                   eval      slloc = slloc * -1
EGF A
EGF AC                   endsl
EGF AC                   endif
EGF A
EGF AC                   testn                   lvla                 50
EGF AC                   if        *in50 = *off
EGF AC                   eval      lvlnotnum = *on
EGF AC                   else
EGF AC                   select
EGF AC                   when      slrlvl = 0
EGF AC                   eval      slrlvl = slrlvl + 10
EGF AC                   when      slrlvl < 0
EGF AC                   eval      slrlvl = slrlvl * -1
EGF AC                   endsl
EGF AC                   endif
EGF A
EGF A*    Convert numeric handstack to alpha character.
EGF A
EGF AC                   if            slhand >= ' 0'
EGF AC                             and slhand <= '99'
EGF AC                   eval      wkchar = slhand
EGF AC                   exsr      zzcvt2ltr
EGF AC                   eval      slhand = nwchar
EGF AC                   endif
EGF A
EGF AC     slloc         div       2             dummy
EGF AC                   mvr                     oddeven
EGF AC                   if        oddeven <> 0
EGF AC                   eval      slside = 1
EGF AC                   else
EGF AC                   eval      slside = 0
EGF AC                   endif
EGF A*
EGF A*    Check if base slot exists for imported slot with handstacks.
EGF A*
EGF AC                   eval      crtbaseslot = *off
EGF AC                   if        handstack = *on
EGF AC     keysl2b       setll     slot2
EGF AC                   if        not %equal(slot2)
EGF AC                   eval      crtbaseslot = *on
EGF AC                   endif
EGF AC                   endif
EGF A
EGF A*    See if slot meets criteria for allowing it to be created.
EGF A
EGF AC                   select
EGF A
EGF A*    If non-special slot doesn't have hypens, then don't add it.
EGF A
EGF AC                   when      dashpos = 0
EGF AC                   eval      notcreated = *on
EGF AC                   goto      endcreate9
EGF A
EGF A*    Don't allow creation if department is unknown.
EGF A
EGF AC                   when      validdept = '*NO '
EGF AC                   eval      notcreated = *on
EGF AC                   goto      endcreate9
EGF A
EGF A*    If location or level is not numeric, then don't add.
EGF A
EGF AC                   when      locnotnum or lvlnotnum
EGF AC                   eval      notcreated = *on
EGF AC                   goto      endcreate9
EGF A
EGF A*    Otherwise, slot is ok to be created.
EGF A
EGF AC                   other
EGF AC                   eval      slwhdp = siwhdp
EGF AC                   eval      sldisp = sidisp
EGF AC                   eval      slstyp = sistyp
EGF A
EGF AC                   endsl
EGF A
EGF A*    Try and create the Base slot.
EGF A
EGF AC                   if        crtbaseslot = *on
EGF A*    Save handstack for virtual slot.
EGF AC                   eval      svhand = slhand
EGF A
EGF AC                   eval      slwhse = siwhse
EGF AC                   eval      sldisp = kydisp
EGF AC                   eval      slpseq = sipseq
EGF AC                   select
EGF AC                   when      slpseq = 0
EGF AC                   eval      slpseq = slloc
EGF AC                   when      slpseq < 0
EGF AC                   eval      slpseq = slpseq * -1
EGF AC                   endsl
EGF AC                   eval      slstat = 'V '
EGF AC                   eval      slhand = '  '
EGF AC                   eval      slrsrv = sirsrv
EGF AC                   eval      slsdef = 'XX'
EGF AC                   eval      slpick = sipick
EGF A
EGF AC                   write (e) slrec
EGF AC                   if        %error
EGF AC                   eval      notcreated = *on
EGF AC                   endif
EGF A*
EGF AC                   endif
EGF A
EGF A*    Try and create the imported slot.
EGF A
EGF AC                   eval      slwhse = siwhse
EGF A*
EGF A*    Replace base slot display, handstack w/ imported fields.
EGF AC                   if        crtbaseslot = *on
EGF AC                   eval      slhand = svhand
EGF AC                   eval      sldisp = sidisp
EGF AC                   endif
EGF A*
EGF AC                   eval      slpseq = sipseq
EGF AC*
EGF AC                   select
EGF AC                   when      slpseq = 0
EGF AC                   eval      slpseq = slloc
EGF AC*
EGF AC                   when      slpseq < 0
EGF AC                   eval      slpseq = slpseq * -1
EGF AC*
EGF AC                   endsl
EGF AC*
EGF AC                   if        slitem > ' '
EGF AC                   eval      slstat = 'A'
EGF AC                   else
EGF AC                   eval      slstat = 'V'
EGF AC                   endif
EGF A*
EGF A*    Slot has handstack, create as virtual slot.
EGF AC                   if        handstack = *on
EGF AC                   eval      slrsrv = 'V'
EGF AC                   else
EGF AC                   eval      slrsrv = sirsrv
EGF AC                   endif
EGF AC                   eval      slsdef = 'XX'
EGF AC                   eval      slpick = sipick
EGF A
EGF AC                   write (e) slrec
EGF AC                   if        %error
EGF AC                   eval      notcreated = *on
EGF AC                   endif
EGF A
EGF A*    Create Virtual slot record.
EGF A
EGF AC                   if        handstack = *on
EGF AC                   eval      vswhse = slwhse
EGF AC                   eval      vswhdp = slwhdp
EGF AC                   eval      vsaisl = slaisl
EGF AC                   eval      vsloc  = slloc
EGF AC                   eval      vsrlvl = slrlvl
EGF AC                   eval      vshand = slhand
EGF AC                   eval      vsdisp = sldisp
EGF AC                   eval      vspdis = kydisp
EGF AC                   eval      vscdte = impdte
EGF AC                   eval      vsctim = imptim
EGF AC                   add       1             vsctim
EGF AC                   write (e) vsrec
EGF AC                   if        %error
EGF AC                   eval      error  = *on
EGF AC                   eval      detmsg = desc(8)
EGF AC                   add       1             notcrt
EGF AC                   goto      endcreate9
EGF AC                   endif
EGF A
EGF AC                   endif
EGF A
EGF A
EGF AC     endcreate9    endsr
SVLbA
SVLbA*----------------------------------------------------------------
SVLbA*  crtslot10  Try and create physical slot.
SVLbA*----------------------------------------------------------------
SVLbA
SVLbAC     crtslot10     begsr
SVLbAC                   eval      notcreated = *off
SVLbA
SVLbA*  Turn on SlotCreated flag even if slot isn't created
SVLbA*  so ZZUPD routine doesn't get executed.
SVLbAC                   eval      slotcreated= *on
SVLbAC                   eval      handstack  = *off
SVLbAC                   clear                   slrec
SVLbA
SVLbA*  Extract location and level. Test if they are numeric.
SVLbA
SVLbAC                   eval      locnotnum = *off
SVLbAC                   eval      lvlnotnum = *off
SVLbAC                   eval      dashpos = 0
SVLbAC                   eval      loca  = ' '
SVLbAC                   eval      lvla  = ' '
SVLbA
SVLbA*  Check for all alpha slot. If no digits, default slot location
SVLbA*  will be assigned.
SVLbAC                   If            %subst(sidisp:2:3) >= '000'
SVLbAC                             and %subst(sidisp:2:3) <= '999'
SVLbAC                             or  %subst(sidisp:3:3) >= '000'
SVLbAC                             and %subst(sidisp:3:3) <= '999'
SVLbAC                   eval      allchrslot = *off
SVLbAC                   else
SVLbAC                   eval      allchrslot = *on
SVLbAC                   endif
SVLbA
SVLbAC                   select
SVLbA
SVLbA*  No Dashes specified. Single character aisle
SVLbAC                   when          %subst(sidisp:2:3) >= '000'
SVLbAC                             and %subst(sidisp:2:3) <= '999'
SVLbAC                   eval      dashpos = -1
SVLbAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
SVLbAC                   eval      loca  = '0' + %subst(sidisp:2:2)
SVLbAC                   move      loca          slloc
SVLbAC                   eval      lvla  = %subst(sidisp:3:1)
SVLbAC                   move      lvla          slrlvl
SVLbAC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
SVLbA
SVLbA*  No Dashes specified. Double character aisle
SVLbAC                   when          %subst(sidisp:3:3) >= '000'
SVLbAC                             and %subst(sidisp:3:3) <= '999'
SVLbAC                   eval      dashpos = -1
SVLbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SVLbAC                   eval      loca  = '0' + %subst(sidisp:3:2)
SVLbAC                   move      loca          slloc
SVLbAC                   eval      lvla  = %subst(sidisp:5:1)
SVLbAC                   move      lvla          slrlvl
SVLbAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
SVLbA
SVLbA*  No dashes specified. All character slot.
SVLbAC                   when      allchrslot = *on
SVLbAC
SVLbAC                   eval      kydisp = sidisp
SVLbAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
SVLbAC
SVLbAC                   eval      dftlocation = dftlocation + 1
SVLbAC                   eval      loca   = %char(dftlocation)
SVLbAC                   eval      slloc  = dftlocation
SVLbAC
SVLbAC                   eval      slrlvl = 1
SVLbAC                   eval      lvla   = '1'
SVLbAC
SVLbAC                   eval      slhand  = '  '
SVLbAC                   eval      dashpos = -1
SVLbA
SVLbAC                   endsl
SVLbA
SVLbA*  Begin testing parts for ALL slots.
SVLbAC                   testn                   loca                 5050
SVLbAC                   if        *in50 = *off
SVLbAC                   eval      locnotnum = *on
SVLbA
SVLbAC                   else
SVLbAC                   select
SVLbAC                   when      slloc  = 0
SVLbAC                   eval      slloc = slloc + 100
SVLbAC                   when      slloc < 0
SVLbAC                   eval      slloc = slloc * -1
SVLbAC                   endsl
SVLbAC                   endif
SVLbA
SVLbAC                   testn                   lvla                 50
SVLbAC                   if        *in50 = *off
SVLbAC                   eval      lvlnotnum = *on
SVLbAC                   else
SVLbAC                   select
SVLbAC                   when      slrlvl = 0
SVLbAC                   eval      slrlvl = slrlvl + 1
SVLbAC                   when      slrlvl < 0
SVLbAC                   eval      slrlvl = slrlvl * -1
SVLbAC                   endsl
SVLbAC                   endif
SVLbA
SVLbA*    Convert numeric handstack to alpha character.
SVLbA
SVLbAC                   if            slhand >= ' 0'
SVLbAC                             and slhand <= '99'
SVLbAC                   eval      wkchar = slhand
SVLbAC                   exsr      zzcvt2ltr
SVLbAC                   eval      slhand = nwchar
SVLbAC                   endif
SVLbA
SVLbAC     slloc         div       2             dummy
SVLbAC                   mvr                     oddeven
SVLbAC                   if        oddeven <> 0
SVLbAC                   eval      slside = 1
SVLbAC                   else
SVLbAC                   eval      slside = 0
SVLbAC                   endif
SVLbA
SVLbA*    See if slot meets criteria for allowing it to be created.
SVLbA
SVLbAC                   select
SVLbA
SVLbA*    If non-special slot doesn't have hypens, then don't add it.
SVLbA
SVLbAC                   when      dashpos = 0
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate10
SVLbA
SVLbA*    Don't allow creation if department is unknown.
SVLbA
SVLbAC                   when      validdept = '*NO '
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate10
SVLbA
SVLbA*    If location or level is not numeric, then don't add.
SVLbA
SVLbAC                   when      locnotnum or lvlnotnum
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate10
SVLbA
SVLbA*    Otherwise, slot is ok to be created.
SVLbA
SVLbAC                   other
SVLbAC                   eval      slwhdp = siwhdp
SVLbAC                   eval      sldisp = sidisp
SVLbAC                   eval      slstyp = sistyp
SVLbA
SVLbAC                   endsl
SVLbA
SVLbA*    Try and create the imported slot.
SVLbA
SVLbAC                   eval      slwhse = siwhse
SVLbAC                   eval      slpseq = sipseq
SVLbAC*
SVLbAC                   select
SVLbAC                   when      slpseq = 0
SVLbAC                   eval      slpseq = slloc
SVLbAC                   when      slpseq < 0
SVLbAC                   eval      slpseq = slpseq * -1
SVLbAC                   endsl
SVLbAC                   if        slitem > ' '
SVLbAC                   eval      slstat = 'A'
SVLbAC                   else
SVLbAC                   eval      slstat = 'V'
SVLbAC                   endif
SVLbA*
SVLbAC                   eval      slrsrv = sirsrv
SVLcAC                   if        sidgtp > ' '
SVLcAC                   eval      slsdef = sidgtp
SVLcAC                   else
SVLbAC                   eval      slsdef = 'XX'
SVLcAC                   endif
SVLbAC                   eval      slpick = sipick
SVLbA
SVLbAC                   write (e) slrec
SVLbAC                   if        %error
SVLbAC                   eval      notcreated = *on
SVLbAC                   endif
SVLbA
SVLbA
SVLbAC     endcreate10   endsr
CDI A
CDI A*----------------------------------------------------------------
CDI A*  crtslot11  Try and create physical slot.
CDI A*----------------------------------------------------------------
CDI A
CDI AC     crtslot11     begsr
CDI AC                   eval      notcreated = *off
CDI A
CDI A*  Turn on SlotCreated flag even if slot isn't created
CDI A*  so ZZUPD routine doesn't get executed.
CDI AC                   eval      slotcreated= *on
CDI AC                   eval      handstack  = *off
CDI AC                   clear                   slrec
CDI A
CDI A*  Extract location and level. Test if they are numeric.
CDI A
CDI AC                   eval      locnotnum = *off
CDI AC                   eval      lvlnotnum = *off
CDI AC                   eval      dashpos = 0
CDI AC                   eval      loca  = ' '
CDI AC                   eval      lvla  = ' '
CDI A
CDI A*  Check for all alpha slot. If no digits, default slot location
CDI A*  will be assigned.
CDI AC                   If            %subst(sidisp:3:3) >= '000'
CDI AC                             and %subst(sidisp:3:3) <= '999'
CDI5AC                             or  %subst(sidisp:4:3) >= '000'
CDI5AC                             and %subst(sidisp:4:3) <= '999'
CDI AC                   eval      allchrslot = *off
CDI AC                   else
CDI AC                   eval      allchrslot = *on
CDI AC                   endif
CDI A
CDI A
CDI AC                   select
CDI A
CDI A*  No dashes specified. All character slot.
CDI AC                   when      allchrslot = *on
CDI AC
CDI AC                   eval      kydisp = sidisp
CDI AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CDI AC
CDI AC                   eval      dftlocation = dftlocation + 1
CDI AC                   eval      loca   = %char(dftlocation)
CDI AC                   eval      slloc  = dftlocation
CDI AC
CDI AC                   eval      slrlvl = 1
CDI AC                   eval      lvla   = '1'
CDI AC
CDI AC                   eval      slhand  = '  '
CDI AC                   eval      dashpos = -1
CDI A
CDI A*  No Dashes specified. Double character aisle w/2nd aisle char blnk
CDI AC                   when          %subst(sidisp:2:1) = ' '
CDI AC                             and %subst(sidisp:3:3) >= '000'
CDI AC                             and %subst(sidisp:3:3) <= '999'
CDI AC                   eval      dashpos = -1
CDI AC                   eval      slaisl = ' ' + %subst(sidisp:1:1) + '*'
CDI AC                   eval      loca  = %subst(sidisp:3:3)
CDI AC                   move      loca          slloc
CDI A*
CDI A*      Convert alpha level into numeric value.
CDI AC                   eval      lvla    = %subst(sidisp:6:1)
CDI AC                   evalr     wkchar = %trimr(lvla)
CDI AC                   exsr      zzcvt2nbr
CDI AC                   if        nwchar > ' '
CDI AC                   evalr     lvla   = %trimr(nwchar)
CDI AC                   eval      slrlvl = %dec(nwchar:2:0)
CDI AC                   else
CDI2MC                   evalr     lvla  = %subst(sidisp:6:1)
CDI2AC                   move      lvla          slrlvl
CDI3DC*                  eval      slrlvl = slrlvl + 1
CDI3MC                   eval      slrlvl = slrlvl + 3
CDI AC                   endif
CDI2DC*                  move      lvla          slrlvl
CDI AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
CDI A
CDI A*  No Dashes specified. Double character aisle
CDI AC                   when          %subst(sidisp:2:1) > ' '
CDI5AC                             and %subst(sidisp:2:1) <> '- '
CDI AC                             and %subst(sidisp:3:3) >= '000'
CDI AC                             and %subst(sidisp:3:3) <= '999'
CDI AC                   eval      dashpos = -1
CDI AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CDI AC                   eval      loca  = %subst(sidisp:3:3)
CDI AC                   move      loca          slloc
CDI A*
CDI A*      Convert alpha level into numeric value.
CDI AC                   eval      lvla    = %subst(sidisp:6:1)
CDI AC                   evalr     wkchar = %trimr(lvla)
CDI AC                   exsr      zzcvt2nbr
CDI AC                   if        nwchar > ' '
CDI AC                   evalr     lvla   = %trimr(nwchar)
CDI AC                   eval      slrlvl = %dec(nwchar:2:0)
CDI AC                   else
CDI2MC                   evalr     lvla  = %subst(sidisp:6:1)
CDI2AC                   move      lvla          slrlvl
CDI3DC*                  eval      slrlvl = slrlvl + 1
CDI3MC                   eval      slrlvl = slrlvl + 3
CDI AC                   endif
CDI2DC*                  move      lvla          slrlvl
CDI AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
CDI A
CDI5A*  Dashes specified. Single character aisle
CDI5AC                   when          %subst(sidisp:2:1) = '-'
CDI5AC                             and %subst(sidisp:3:3) >= '000'
CDI5AC                             and %subst(sidisp:3:3) <= '999'
CDI5AC                   eval      dashpos = -1
CDI5AC                   eval      slaisl = ' 0' + %subst(sidisp:1:1)
CDI5AC                   eval      loca  = %subst(sidisp:3:3)
CDI5AC                   move      loca          slloc
CDI5A*
CDI5A*      Convert alpha level into numeric value.
CDI5AC                   eval      lvla    = %subst(sidisp:7:1)
CDI5AC                   evalr     wkchar = %trimr(lvla)
CDI5AC                   exsr      zzcvt2nbr
CDI5AC                   if        nwchar > ' '
CDI5AC                   evalr     lvla   = %trimr(nwchar)
CDI5AC                   eval      slrlvl = %dec(nwchar:2:0)
CDI5AC                   else
CDI5AC                   evalr     lvla  = %subst(sidisp:7:1)
CDI5AC                   move      lvla          slrlvl
CDI5AC                   endif
CDI5AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CDI5A*
CDI5A*  Dashes specified. Double character aisle
CDI5AC                   when          %subst(sidisp:3:1) = '-'
CDI5AC                             and %subst(sidisp:4:3) >= '000'
CDI5AC                             and %subst(sidisp:4:3) <= '999'
CDI5AC                   eval      dashpos = -1
CDI5AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CDI5AC                   eval      loca  = %subst(sidisp:4:3)
CDI5AC                   move      loca          slloc
CDI5A*
CDI5A*      Convert alpha level into numeric value.
CDI5AC                   eval      lvla    = %subst(sidisp:8:1)
CDI5AC                   evalr     wkchar = %trimr(lvla)
CDI5AC                   exsr      zzcvt2nbr
CDI5AC                   if        nwchar > ' '
CDI5AC                   evalr     lvla   = %trimr(nwchar)
CDI5AC                   eval      slrlvl = %dec(nwchar:2:0)
CDI5AC                   else
CDI5AC                   evalr     lvla  = %subst(sidisp:8:1)
CDI5AC                   move      lvla          slrlvl
CDI5AC                   endif
CDI5AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CDI A
CDI AC                   endsl
CDI A
CDI A*  Begin testing parts for ALL slots.
CDI AC                   testn                   loca                 5050
CDI AC                   if        *in50 = *off
CDI AC                   eval      locnotnum = *on
CDI A
CDI AC                   else
CDI AC                   select
CDI AC                   when      slloc  = 0
CDI AC                   eval      slloc = slloc + 100
CDI AC                   when      slloc < 0
CDI AC                   eval      slloc = slloc * -1
CDI AC                   endsl
CDI AC                   endif
CDI A
CDI AC                   testn                   lvla                 50
CDI AC                   if        *in50 = *off
CDI AC                   eval      lvlnotnum = *on
CDI AC                   else
CDI AC                   select
CDI AC                   when      slrlvl = 0
CDI AC                   eval      slrlvl = slrlvl + 1
CDI AC                   when      slrlvl < 0
CDI AC                   eval      slrlvl = slrlvl * -1
CDI AC                   endsl
CDI AC                   endif
CDI A
CDI A*    Convert numeric handstack to alpha character.
CDI A
CDI AC                   if            slhand >= ' 0'
CDI AC                             and slhand <= '99'
CDI AC                   eval      wkchar = slhand
CDI AC                   exsr      zzcvt2ltr
CDI AC                   eval      slhand = nwchar
CDI AC                   endif
CDI A
CDI AC     slloc         div       2             dummy
CDI AC                   mvr                     oddeven
CDI AC                   if        oddeven <> 0
CDI AC                   eval      slside = 1
CDI AC                   else
CDI AC                   eval      slside = 0
CDI AC                   endif
CDI A
CDI A*    See if slot meets criteria for allowing it to be created.
CDI A
CDI AC                   select
CDI A
CDI A*    If non-special slot doesn't have hypens, then don't add it.
CDI A
CDI AC                   when      dashpos = 0
CDI AC                   eval      notcreated = *on
CDI AC                   goto      endcreate11
CDI A
CDI A*    Don't allow creation if department is unknown.
CDI A
CDI AC                   when      validdept = '*NO '
CDI AC                   eval      notcreated = *on
CDI AC                   goto      endcreate11
CDI A
CDI A*    If location or level is not numeric, then don't add.
CDI A
CDI AC                   when      locnotnum or lvlnotnum
CDI AC                   eval      notcreated = *on
CDI AC                   goto      endcreate11
CDI A
CDI A*    Otherwise, slot is ok to be created.
CDI A
CDI AC                   other
CDI AC                   eval      slwhdp = siwhdp
CDI AC                   eval      sldisp = sidisp
CDI AC                   eval      slstyp = sistyp
CDI A
CDI AC                   endsl
CDI A
CDI A*    Try and create the imported slot.
CDI A
CDI AC                   eval      slwhse = siwhse
CDI AC                   eval      slpseq = sipseq
CDI AC*
CDI AC                   select
CDI AC                   when      slpseq = 0
CDI AC                   eval      slpseq = slloc
CDI AC                   when      slpseq < 0
CDI AC                   eval      slpseq = slpseq * -1
CDI AC                   endsl
CDI AC                   if        slitem > ' '
CDI AC                   eval      slstat = 'A'
CDI AC                   else
CDI AC                   eval      slstat = 'V'
CDI AC                   endif
CDI A*
CDI AC                   eval      slrsrv = sirsrv
CDI AC                   eval      slsdef = 'XX'
CDI AC                   eval      slpick = sipick
CDI A
CDI AC                   write (e) slrec
CDI AC                   if        %error
CDI AC                   eval      notcreated = *on
CDI AC                   endif
CDI A
CDI AC     endcreate11   endsr
DRY A
DRY A*----------------------------------------------------------------
DRY A*  crtslot12  Try and create physical slot.
DRY A*----------------------------------------------------------------
DRY A
DRY AC     crtslot12     begsr
DRY AC                   eval      notcreated = *off
DRY A
DRY A*  Turn on SlotCreated flag even if slot isn't created
DRY A*  so ZZUPD routine doesn't get executed.
DRY AC                   eval      slotcreated= *on
DRY AC                   eval      handstack  = *off
DRY AC                   clear                   slrec
DRY A
DRY A*  Extract location and level. Test if they are numeric.
DRY A
 RY AC                   eval      locnotnum = *off
DRY AC                   eval      lvlnotnum = *off
DRY AC                   eval      dashpos = 0
DRY AC                   eval      rowlen  = 0
DRY AC                   eval      sectlen = 0
DRY AC                   eval      loca  = ' '
DRY AC                   eval      lvla  = ' '
DRY AC                   eval      lvlaa = ' '
DRY A
DRY A*  Check for all alpha slot. If no digits, default slot location
DRY A*  will be assigned.
DRY AC                   If            %subst(sidisp:8:3) >= '000'
DRY AC                             and %subst(sidisp:8:3) <= '999'
DRY6AC                             and %subst(sidisp:4:4)  = ' '
DRY7A*
DRYaAC                             or  %subst(sidisp:8:3) >= '000'
DRYaAC                             and %subst(sidisp:8:3) <= '999'
DRYaAC                             and %subst(sidisp:4:2)  = ' '
DRYhA*
DRYhAC                             or  %subst(sidisp:8:3) >= '000'
DRYhAC                             and %subst(sidisp:8:3) <= '999'
DRYhAC                             and %subst(sidisp:4:1)  = ' '
DRYhAC                             and %subst(sidisp:7:1)  = ' '
DRYaA*
DRY7AC                             or  %subst(sidisp:5:3) >= '000'
DRY7AC                             and %subst(sidisp:5:3) <= '999'
DRY7AC                             and %subst(sidisp:4:1)  = '-'
DRY7AC                             and %subst(sidisp:8:1)  = '-'
DRYcA*
DRYcAC                             or  %subst(sidisp:1:3) >= '000'
DRYcAC                             and %subst(sidisp:1:3) <= '999'
DRYcAC                             and %subst(sidisp:4:4)  = ' '
DRYcAC                             and %subst(sidisp:8:3) >= '000'
DRYcAC                             and %subst(sidisp:8:3) <= '999'
DRY AC                   eval      allchrslot = *off
DRY AC                   else
DRY AC                   eval      allchrslot = *on
DRY AC                   endif
DRY A
DRY AC                   select
DRY A
DRY A*  No Dashes specified. Standard Dairyland slot.
DRY AC                   when          %subst(sidisp:8:3) >= '000'
DRY AC                             and %subst(sidisp:8:3) <= '999'
DRYcAC                             and %subst(sidisp:3:1) >= 'A'
DRYcAC                             and %subst(sidisp:3:1) <= 'Z'
DRY AC                             and allchrslot = '0'
DRY AC                   eval      dashpos = -1
DRY A
DRY AC                   eval      sectlen = %len(%trim(%subst(sidisp:1:3)))
DRY AC                   eval      rowlen  = %len(%trim(%subst(sidisp:4:3)))
DRY AC                   if        sectlen + Rowlen > 3
DRY AC                   if        %subst(sidisp:4:3) > ' '
DRY2DC*                  evalr     slaisl = %trimr(%subst(sidisp:4:3))
DRY2MC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRY AC                   else
DRY AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRY AC                   endif
DRY AC                   else
DRYaAC                   eval      wksect = %subst(sidisp:1:3)
DRYaAC                   eval      wkrow  = %subst(sidisp:4:3)
DRYaDC*                  evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRY2DC*                                     %trimr(%subst(sidisp:4:3))
DRYaAC                   evalr     slaisl = %trimr(wksect) + %trim(wkrow)
DRY AC                   endif
DRY2AC                   select
DRY2AC                   when      %len(%trim(slaisl)) = 1
DRY3DC*                  evalr     slaisl = %trim(slaisl) + '..'
DRY3MC                   evalr     slaisl = '0' + %trim(slaisl) + '.'
DRY2AC                   when      %len(%trim(slaisl)) = 2
DRY2AC                   evalr     slaisl = %trim(slaisl) + '.'
DRY2AC                   endsl
DRY AC
DRY AC                   eval      loca  = %subst(sidisp:8:3)
DRY AC                   move      loca          slloc
DRY AC
DRY AC                   if            %subst(sidisp:7:1) >= '0'
DRY AC                             and %subst(sidisp:7:1) <= '9'
DRY AC                   eval      lvla = %subst(sidisp:7:1)
DRY AC                   move      lvla          slrlvl
DRY AC                   else
DRY AC                   eval      lvla  = %subst(sidisp:7:1)
DRY AC                   if        lvla >= 'A' and lvla <= 'Z'
DRY AC                             or lvla = ' '
DRY AC                   evalr     wkchar = %trimr(lvla)
DRY AC                   exsr      zzcvt2nbr
DRY AC                   evalr     lvla   = %trimr(nwchar)
DRY AC                   testn                   lvla                 50
DRY AC                   if        *in50 = *on
DRY AC                   move      lvla          slrlvl
DRY AC                   endif
DRY A*
DRY AC                   endif
DRY A*
DRY AC                   endif
DRY AC                   eval      slhand  = ' ' + %subst(sidisp:11:1)
DRYhA
DRYhA*  No Dashes specified. Las Vegas whse slot format. b11bb6b021
DRYhAC                   when          client    = Dairyland
DRYhAC                             and (clientloc = Drylv)
DRYhA*
DRYhAC                             and (%subst(sidisp:1:3) >= '000'
DRYhAC                             and  %subst(sidisp:1:3) <= '999'
DRYhAC                             and  %subst(sidisp:4:1)  = ' '
DRYhAC                             and  %subst(sidisp:7:1)  = ' '
DRYhAC                             and  %subst(sidisp:8:3) >= '000'
DRYhAC                             and  %subst(sidisp:8:3) <= '999'
DRYhAC                             and  allchrslot = '0'
DRYhA*
DRYhAC                             or   %subst(sidisp:1:3) >= ' 00'
DRYhAC                             and  %subst(sidisp:1:3) <= ' 99'
DRYhAC                             and  %subst(sidisp:4:1)  = ' '
DRYhAC                             and  %subst(sidisp:7:1)  = ' '
DRYhAC                             and  %subst(sidisp:8:3) >= '000'
DRYhAC                             and  %subst(sidisp:8:3) <= '999'
DRYhAC                             and  allchrslot = '0'
DRYhA*
DRYhAC                             or   %subst(sidisp:1:3) >= '  0'
DRYhAC                             and  %subst(sidisp:1:3) <= '  9'
DRYhAC                             and  %subst(sidisp:4:1)  = ' '
DRYhAC                             and  %subst(sidisp:7:1)  = ' '
DRYhAC                             and  %subst(sidisp:8:3) >= '000'
DRYhAC                             and  %subst(sidisp:8:3) <= '999'
DRYhAC                             and  allchrslot = '0')
DRYhAC                   eval      dashpos = -1
DRYhA
DRYhAC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRYhA*
DRYhAC                   select
DRYhAC                   when      %len(%trim(slaisl)) = 1
DRYhAC                   evalr     slaisl = '0' + %trim(slaisl) + '.'
DRYhAC                   when      %len(%trim(slaisl)) = 2
DRYhAC                   evalr     slaisl = %trim(slaisl) + '.'
DRYhAC                   endsl
DRYhAC
DRYhAC                   if        %subst(sidisp:5:1) = ' '
DRYhAC                   eval      loca  = '00' + %subst(sidisp:6:1)
DRYhAC                   else
DRYhAC                   eval      loca  = '0' + %subst(sidisp:5:2)
DRYhAC                   endif
DRYhAC                   move      loca          slloc
DRYhAC
DRYhAC                   select
DRYhA*      Slot has single digit rack level.
DRYhAC                   when          %subst(sidisp:9:1) >= '0'
DRYhAC                             and %subst(sidisp:9:1) <= '9'
DRYhAC                             and %subst(sidisp:8:1)  = ' '
DRYhAC                   eval      lvla = %subst(sidisp:9:1)
DRYhAC                   move      lvla          slrlvl
DRYhA*      Slot has double digit rack level.
DRYhAC                   when          %subst(sidisp:8:2) >= '00'
DRYhAC                             and %subst(sidisp:8:2) <= '99'
DRYhAC                   eval      lvlaa = %subst(sidisp:8:2)
DRYhAC                   move      lvlaa         slrlvl
DRYhAC
DRYhAC                   other
DRYhAC
DRYhAC                   eval      lvla = %subst(sidisp:9:1)
DRYhAC                   if        lvla >= 'A' and lvla <= 'Z'
DRYhAC                             or lvla = ' '
DRYhAC                   evalr     wkchar = %trimr(lvla)
DRYhAC                   exsr      zzcvt2nbr
DRYhAC                   evalr     lvla   = %trimr(nwchar)
DRYhAC                   testn                   lvla                 50
DRYhAC                   if        *in50 = *on
DRYhAC                   move      lvla          slrlvl
DRYhAC                   endif
DRYhA*
DRYhAC                   endif
DRYhA*
DRYhAC                   endsl
DRYhA*
DRYcA
DRYcA*  No Dashes specified. San Francisco whse slot format.
DRYcAC                   when          %subst(sidisp:1:3) >= '000'
DRYcAC                             and %subst(sidisp:1:3) <= '999'
DRYcAC                             and %subst(sidisp:4:4)  = ' '
DRYcAC                             and %subst(sidisp:8:3) >= '000'
DRYcAC                             and %subst(sidisp:8:3) <= '999'
DRYcAC                             and allchrslot = '0'
DRYcAC                   eval      dashpos = -1
DRYcA
DRYcAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
DRYcAC                   eval      wksect = %subst(sidisp:1:2)
DRYcAC                   eval      wkrow  = %subst(sidisp:4:4)
DRYcAC                   evalr     slaisl = %trimr(wksect) + %trim(wkrow)
DRYcA*
DRYcAC                   select
DRYcAC                   when      %len(%trim(slaisl)) = 1
DRYcAC                   evalr     slaisl = '0' + %trim(slaisl) + '.'
DRYcAC                   when      %len(%trim(slaisl)) = 2
DRYcAC                   evalr     slaisl = %trim(slaisl) + '.'
DRYcAC                   endsl
DRYcAC
DRYcAC                   eval      loca  = '0' + %subst(sidisp:3:1)
DRYcAC                                         + %subst(sidisp:8:1)
DRYcAC                   move      loca          slloc
DRYcAC
DRYcAC                   if            %subst(sidisp:9:1) >= '0'
DRYcAC                             and %subst(sidisp:9:1) <= '9'
DRYcAC                   eval      lvla = %subst(sidisp:9:1)
DRYcAC                   move      lvla          slrlvl
DRYcAC                   else
DRYcAC                   eval      lvla  = %subst(sidisp:9:1)
DRYcAC                   if        lvla >= 'A' and lvla <= 'Z'
DRYcAC                             or lvla = ' '
DRYcAC                   evalr     wkchar = %trimr(lvla)
DRYcAC                   exsr      zzcvt2nbr
DRYcAC                   evalr     lvla   = %trimr(nwchar)
DRYcAC                   testn                   lvla                 50
DRYcAC                   if        *in50 = *on
DRYcAC                   move      lvla          slrlvl
DRYcAC                   endif
DRYcA*
DRYcAC                   endif
DRYcA*
DRYcAC                   endif
DRYcA*
DRYcAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
DRY7A
DRY7A*  Dashes specified. triple character aisle
DRY7AC                   when      %subst(sidisp:4:1) = '-'
DRY7AC                             and %subst(sidisp:8:1) = '-'
DRY7AC                   eval      slaisl = %trim(%subst(sidisp:1:3))
DRY7AC                   eval      loca  = %subst(sidisp:5:3)
DRY7AC                   move      loca          slloc
DRYeA*
DRYeA*      Slot has 2 digit rack level.
DRYeAC                   if            %subst(sidisp:9:1) >= '0'
DRYeAC                             and %subst(sidisp:9:1) <= '9'
DRYeAC                             and %subst(sidisp:10:1) >= '0'
DRYeAC                             and %subst(sidisp:10:1) <= '9'
DRYeAC                   eval      lvlaa = %subst(sidisp:9:2)
DRYeAC                   move      lvlaa         slrlvl
DRYeAC                   evalr     slhand  = %trimr(%subst(sidisp:11:2))
DRYeAC                   else
DRYeA*
DRY7AC                   eval      lvla  = %subst(sidisp:9:1)
DRY7AC                   move      lvla          slrlvl
DRY7AC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
DRYeAC                   endif
DRYeA*
DRY7AC                   if        slhand > ' '
DRY7DC*                  eval      handstack = *on
DRY7AC                   endif
DRY7AC                   eval      dashpos = 4
DRY A
DRY A*  No dashes specified. All character slot.
DRY AC                   when      allchrslot = *on
DRY AC
DRY AC                   eval      kydisp = sidisp
DRY AC                   if        %subst(sidisp:4:3) > ' '
DRY2DC*                  evalr     slaisl = %trimr(%subst(sidisp:4:3))
DRY2MC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRY AC                   else
DRY AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
DRY AC                   endif
DRY2AC                   select
DRY2AC                   when      %len(%trim(slaisl)) = 1
DRY3DC*                  evalr     slaisl = %trim(slaisl) + '..'
DRY3MC                   evalr     slaisl = '0' + %trim(slaisl) + '.'
DRY2AC                   when      %len(%trim(slaisl)) = 2
DRY2AC                   evalr     slaisl = %trim(slaisl) + '.'
DRY2AC                   endsl
DRY AC
DRY4AC*      If slot display contains only the aisle character, set
DRY4AC*      slot location = 000 and rack level = 1.
DRY4AC                   if        %subst(sidisp:4:9) = ' '
DRY4AC                   eval      loca   = '000'
DRY4AC                   move      loca          slloc
DRY4AC                   eval      lvla = '1'
DRY4AC                   move      lvla          slrlvl
DRY4AC                   else
DRY4AC*
DRY AC                   eval      dftlocation = dftlocation + 1
DRY AC                   eval      loca   = %char(dftlocation)
DRY AC                   eval      slloc  = dftlocation
DRY AC
DRY AC
DRY AC                   if            %subst(sidisp:7:1) >= '0'
DRY AC                             and %subst(sidisp:7:1) <= '9'
DRY AC                   eval      lvla = %subst(sidisp:8:3)
DRY AC                   move      lvla          slrlvl
DRY AC                   else
DRY AC                   eval      slrlvl = 2
DRY AC                   eval      lvla   = '2'
DRY AC                   endif
DRY AC
DRY4AC                   endif
DRY4AC*
DRY AC                   eval      slhand  = '  '
DRY AC                   eval      dashpos = -1
DRY A
DRY AC                   endsl
DRY A
DRY A*  Begin testing parts for ALL slots.
DRY AC                   testn                   loca                 5050
DRY AC                   if        *in50 = *off
DRY AC                   eval      locnotnum = *on
DRY A
DRY AC                   else
DRY AC                   select
DRY AC                   when      slloc  = 0
DRY4AC                             and %subst(sidisp:4:9) > ' '
DRY5DC*                  eval      slloc = slloc + 100
DRY AC                   when      slloc < 0
DRY AC                   eval      slloc = slloc * -1
DRY AC                   endsl
DRY AC                   endif
DRY A
DRYeAC                   if        lvlaa > ' '
DRYeAC                   testn                   lvlaa                5050
DRYeAC                   else
DRYeA*
DRY AC                   testn                   lvla                 50
DRYeAC                   endif
DRYeA*
DRY AC                   if        *in50 = *off
DRY AC                   eval      lvlnotnum = *on
DRY AC                   else
DRY AC                   select
DRY AC                   when      slrlvl = 0
DRY AC                   eval      slrlvl = slrlvl + 1
DRY AC                   when      slrlvl < 0
DRY AC                   eval      slrlvl = slrlvl * -1
DRY AC                   endsl
DRY AC                   endif
DRY A
DRY A*    Convert numeric handstack to alpha character.
DRY A
DRY AC                   if            slhand >= ' 0'
DRY AC                             and slhand <= '99'
DRYcA*
DRYcAC                   if        clientloc = drysanfran
DRYcA*    Leave SLHAND field as numeric value.
DRYcAC                   else
DRYcA*
DRY AC                   eval      wkchar = slhand
DRY AC                   exsr      zzcvt2ltr
DRY AC                   eval      slhand = nwchar
DRYcAC                   endif
DRYcA*
DRY AC                   endif
DRY A
DRY AC     slloc         div       2             dummy
DRY AC                   mvr                     oddeven
DRY AC                   if        oddeven <> 0
DRY AC                   eval      slside = 1
DRY AC                   else
DRY AC                   eval      slside = 0
DRY AC                   endif
DRY A
DRY A*    See if slot meets criteria for allowing it to be created.
DRY A
DRY AC                   select
DRY A
DRY A*    If non-special slot doesn't have hypens, then don't add it.
DRY A
DRY AC                   when      dashpos = 0
DRY AC                   eval      notcreated = *on
DRY AC                   goto      endcreate12
DRY A
DRY A*    Don't allow creation if department is unknown.
DRY A
DRY AC                   when      validdept = '*NO '
DRY AC                   eval      notcreated = *on
DRY AC                   goto      endcreate12
DRY A
DRY A*    If location or level is not numeric, then don't add.
DRY A
DRY AC                   when      locnotnum or lvlnotnum
DRY AC                   eval      notcreated = *on
DRY AC                   goto      endcreate12
DRY A
DRY A*    Otherwise, slot is ok to be created.
DRY A
DRY AC                   other
DRY AC                   eval      slwhdp = siwhdp
DRY AC                   eval      sldisp = sidisp
DRY AC                   eval      slstyp = sistyp
DRY A
DRY AC                   endsl
DRY A
DRY A*    Try and create the imported slot.
DRY A
DRY AC                   eval      slwhse = siwhse
DRY AC                   eval      slpseq = sipseq
DRY AC*
DRY AC                   select
DRY AC                   when      slpseq = 0
DRY AC                   eval      slpseq = slloc
DRY AC                   when      slpseq < 0
DRY AC                   eval      slpseq = slpseq * -1
DRY AC                   endsl
DRY AC                   if        slitem > ' '
DRY AC                   eval      slstat = 'A'
DRY AC                   else
DRY AC                   eval      slstat = 'V'
DRY AC                   endif
DRY A*
DRY AC                   eval      slrsrv = sirsrv
DRY7AC                   if        sidgtp > ' '
DRY7AC                   eval      slsdef = sidgtp
DRY7AC                   else
DRY AC                   eval      slsdef = 'XX'
DRY7AC                   endif
DRY AC                   eval      slpick = sipick
DRY A
DRY AC                   write (e) slrec
DRY AC                   if        %error
DRY AC                   eval      notcreated = *on
DRY AC                   endif
DRY A
DRY AC     endcreate12   endsr
    A
CWD A*----------------------------------------------------------------
CWD A*  crtslot13  Try and create physical slot.
CWD A*----------------------------------------------------------------
CWD A
CWD AC     crtslot13     begsr
CWD AC                   eval      notcreated = *off
CWD A
CWD A*  Turn on SlotCreated flag even if slot isn't created
CWD A*  so ZZUPD routine doesn't get executed.
CWD AC                   eval      slotcreated= *on
CWD AC                   eval      handstack  = *off
CWD AC                   clear                   slrec
CWD A
CWD A*  Extract location and level. Test if they are numeric.
CWD A
CWD AC                   eval      locnotnum = *off
CWD AC                   eval      lvlnotnum = *off
CWD AC                   eval      dashpos = 0
CWD AC                   eval      loca  = ' '
CWD AC                   eval      lvla  = ' '
CWDbAC                   eval      lvlaa = '  '
CWD A
CWD A*  Check for all alpha slot. If no digits, default slot location
CWD A*  will be assigned.
CWD AC                   If            %subst(sidisp:2:3) >= '000'
CWD AC                             and %subst(sidisp:2:3) <= '999'
CWDeAC                             and %subst(sidisp:6:1)  = ' '
CWD AC                             or  %subst(sidisp:3:3) >= '000'
CWD AC                             and %subst(sidisp:3:3) <= '999'
CWDeAC                             and %subst(sidisp:7:1)  = ' '
CWDaAC                             or  %subst(sidisp:4:3) >= '000'
CWDaAC                             and %subst(sidisp:4:3) <= '999'
CWDfAC                             or  %subst(sidisp:2:1)  = '-'
CWDfAC                             and %subst(sidisp:3:3) >= '000'
CWDfAC                             and %subst(sidisp:3:3) <= '999'
CWD AC                   eval      allchrslot = *off
CWD AC                   else
CWD AC                   eval      allchrslot = *on
CWD AC                   endif
CWD A
CWD AC                   select
CWD A
CWD A*  No Dashes specified. Single character aisle
CWD AC                   when          %subst(sidisp:2:3) >= '000'
CWD AC                             and %subst(sidisp:2:3) <= '999'
CWDaAC                             and %subst(sidisp:6:1)  = ' '
CWD AC                   eval      dashpos = -1
CWDaMC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
CWD AC                   eval      loca  = %subst(sidisp:2:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWD AC                   move      loca          slloc
CWDcAC                   endif
CWD AC                   eval      lvla  = %subst(sidisp:5:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWD AC                   move      lvla          slrlvl
CWDcAC                   endif
CWD AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
CWD AC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWD AC                   endif
CWD A
CWD A*  No Dashes specified. Double character aisle
CWD AC                   when          %subst(sidisp:3:3) >= '000'
CWD AC                             and %subst(sidisp:3:3) <= '999'
CWDaAC                             and %subst(sidisp:7:1)  = ' '
CWD AC                   eval      dashpos = -1
CWD AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CWD AC                   eval      loca  = %subst(sidisp:3:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWD AC                   move      loca          slloc
CWDcAC                   endif
CWD AC                   eval      lvla  = %subst(sidisp:6:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWD AC                   move      lvla          slrlvl
CWDcAC                   endif
CWD AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
CWD AC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWD AC                   endif
CWDaA
CWDaA*  Dashes specified. Single character aisle
CWDaAC                   when      %subst(sidisp:2:1) = '-'
CWDaAC                             and %subst(sidisp:6:1) = '-'
CWDeAC                             and allchrslot = '0'
CWDaAC                   eval      dashpos = 2
CWDaAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
CWDaAC                   eval      loca  = %subst(sidisp:3:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      loca          slloc
CWDcAC                   endif
CWDaAC                   eval      lvla  = %subst(sidisp:7:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvla          slrlvl
CWDcAC                   endif
CWDaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CWDaAC                   if        slhand > ' '
CWDbDC*                  eval      handstack = *on
CWDaAC                   endif
CWDaA
CWDaA*  Dashes specified. Double character aisle
CWDaAC                   when      %subst(sidisp:3:1) = '-'
CWDaAC                             and %subst(sidisp:7:1) = '-'
CWDeAC                             and allchrslot = '0'
CWDaAC                   eval      dashpos = 3
CWDaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CWDaAC                   eval      loca  = %subst(sidisp:4:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      loca          slloc
CWDcAC                   endif
CWDdAC                   if            %subst(sidisp:8:1) >= '0'
CWDdAC                             and %subst(sidisp:8:1) <= '9'
CWDdAC                             and %subst(sidisp:9:1) >= '0'
CWDdAC                             and %subst(sidisp:9:1) <= '9'
CWDdAC                   eval      lvlaa = %subst(sidisp:8:2)
CWDcAC                   testn                   lvlaa                5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvlaa         slrlvl
CWDcAC                   endif
CWDdAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
CWDdAC                   else
CWDaAC                   eval      lvla  = %subst(sidisp:8:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvla          slrlvl
CWDcAC                   endif
CWDdAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDdAC                   endif
CWDdDC*                  eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDaAC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWDaAC                   endif
CWD A
CWD A*  No dashes specified. All character slot.
CWD AC                   when      allchrslot = *on
CWD AC
CWD AC                   eval      kydisp = sidisp
CWD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CWD AC
CWD AC                   eval      dftlocation = dftlocation + 1
CWD AC                   eval      loca   = %char(dftlocation)
CWD AC                   eval      slloc  = dftlocation
CWD AC
CWDeAC                   select
CWDeA*        Single digit level defined with no handstack defined.
CWDeAC                   when          %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) = ' '
CWDeA*        Single digit level defined with handstack defined.
CWDeAC                             or  %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) >= 'A'
CWDeAC                             and %subst(sidisp:9:1) <= 'Z'
CWDeAC                   eval      lvla = %subst(sidisp:8:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDeAC                   testn                   lvla                 50
CWDeAC                   if        *in50 = *on
CWDeAC                   move      lvla          slrlvl
CWDeAC                   endif
CWDeAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDeA*        Double digit level defined.
CWDeAC                   when          %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) >= '0'
CWDeAC                             and %subst(sidisp:9:1) <= '9'
CWDeAC                   eval      lvlaa = %subst(sidisp:8:2)
CWDeAC                   testn                   lvlaa                5050
CWDeAC                   if        *in50 = *on
CWDeAC                   move      lvlaa         slrlvl
CWDeAC                   endif
CWDeAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
CWDeAC                   other
CWD AC                   eval      slrlvl = 1
CWD AC                   eval      lvla   = '1'
CWD AC
CWD AC                   eval      slhand  = '  '
CWDeAC                   endsl
CWD AC                   eval      dashpos = -1
CWD A
CWD AC                   endsl
CWD A
CWD A*  Begin testing parts for ALL slots.
CWD AC                   testn                   loca                 5050
CWD AC                   if        *in50 = *off
CWD AC                   eval      locnotnum = *on
CWD A
CWD AC                   else
CWD AC                   select
CWD AC                   when      slloc  = 0
CWD AC                   eval      slloc = slloc + 100
CWD AC                   when      slloc < 0
CWD AC                   eval      slloc = slloc * -1
CWD AC                   endsl
CWD AC                   endif
CWD A
CWDdAC                   if        lvlaa > ' '
CWDdAC                   testn                   lvlaa                5050
CWDdAC                   else
CWD AC                   testn                   lvla                 50
CWDdAC                   endif
CWDdA
CWD AC                   if        *in50 = *off
CWD AC                   eval      lvlnotnum = *on
CWD AC                   else
CWD AC                   select
CWD AC                   when      slrlvl = 0
CWDdDC*                  eval      slrlvl = slrlvl + 10
CWDdMC                   eval      slrlvl = slrlvl + 1
CWD AC                   when      slrlvl < 0
CWD AC                   eval      slrlvl = slrlvl * -1
CWDdAC***                when      slrlvl > 0
CWDdAC***                          and slrlvl < 99
CWDdAC***                eval      slrlvl = slrlvl + 1
CWD AC                   endsl
CWD AC                   endif
CWD A
CWD A*    Convert numeric handstack to alpha character.
CWD A
CWD AC                   if            slhand >= ' 0'
CWD AC                             and slhand <= '99'
CWD AC                   eval      wkchar = slhand
CWD AC                   exsr      zzcvt2ltr
CWD AC                   eval      slhand = nwchar
CWD AC                   endif
CWD A
CWD AC     slloc         div       2             dummy
CWD AC                   mvr                     oddeven
CWD AC                   if        oddeven <> 0
CWD AC                   eval      slside = 1
CWD AC                   else
CWD AC                   eval      slside = 0
CWD AC                   endif
CWD A*
CWD A*    Check if base slot exists for imported slot with handstacks.
CWD A*
CWD AC                   eval      crtbaseslot = *off
CWD AC                   if        handstack = *on
CWD AC     keysl2b       setll     slot2
CWD AC                   if        not %equal(slot2)
CWD AC                   eval      crtbaseslot = *on
CWD AC                   endif
CWD AC                   endif
CWD A
CWD A*    See if slot meets criteria for allowing it to be created.
CWD A
CWD AC                   select
CWD A
CWD A*    If non-special slot doesn't have hypens, then don't add it.
CWD A
CWD AC                   when      dashpos = 0
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    Don't allow creation if department is unknown.
CWD A
CWD AC                   when      validdept = '*NO '
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    If location or level is not numeric, then don't add.
CWD A
CWD AC                   when      locnotnum or lvlnotnum
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    Otherwise, slot is ok to be created.
CWD A
CWD AC                   other
CWD AC                   eval      slwhdp = siwhdp
CWD AC                   eval      sldisp = sidisp
CWD AC                   eval      slstyp = sistyp
CWD A
CWD AC                   endsl
CWD A
CWD A*    Try and create the Base slot.
CWD A
CWD AC                   if        crtbaseslot = *on
CWD A*    Save handstack for virtual slot.
CWD AC                   eval      svhand = slhand
CWD A
CWD AC                   eval      slwhse = siwhse
CWD AC                   eval      sldisp = kydisp
CWD AC                   eval      slpseq = sipseq
CWD AC                   select
CWD AC                   when      slpseq = 0
CWD AC                   eval      slpseq = slloc
CWD AC                   when      slpseq < 0
CWD AC                   eval      slpseq = slpseq * -1
CWD AC                   endsl
CWD AC                   eval      slstat = 'V '
CWD AC                   eval      slhand = '  '
CWD AC                   eval      slrsrv = sirsrv
CWDhA*
CWDhAC                   if        sidgtp > ' '
CWDhAC                   eval      slsdef = sidgtp
CWDhAC                   else
CWDhA*
CWD AC                   eval      slsdef = 'XX'
CWDhAC                   endif
CWDhA*
CWD AC                   eval      slpick = sipick
CWD A
CWD AC                   write (e) slrec
CWD AC                   if        %error
CWD AC                   eval      notcreated = *on
CWD AC                   endif
CWD A*
CWD AC                   endif
CWD A
CWD A*    Try and create the imported slot.
CWD A
CWD AC                   eval      slwhse = siwhse
CWD A*
CWD A*    Replace base slot display, handstack w/ imported fields.
CWD AC                   if        crtbaseslot = *on
CWD AC                   eval      slhand = svhand
CWD AC                   eval      sldisp = sidisp
CWD AC                   endif
CWD A*
CWD AC                   eval      slpseq = sipseq
CWD AC                   select
CWD AC                   when      slpseq = 0
CWD AC                   eval      slpseq = slloc
CWD AC                   when      slpseq < 0
CWD AC                   eval      slpseq = slpseq * -1
CWD AC                   endsl
CWD AC                   if        slitem > ' '
CWD AC                   eval      slstat = 'A'
CWD AC                   else
CWD AC                   eval      slstat = 'V'
CWD AC                   endif
CWD A*
CWD A*    Slot has handstack, create as virtual slot.
CWD AC                   if        handstack = *on
CWD AC                   eval      slrsrv = 'V'
CWD AC                   else
CWD AC                   eval      slrsrv = sirsrv
CWD AC                   endif
CWD AC                   eval      slsdef = 'XX'
CWD AC                   eval      slpick = sipick
CWD A
CWD AC                   write (e) slrec
CWD AC                   if        %error
CWD AC                   eval      notcreated = *on
CWD AC                   endif
CWD A
CWD A*    Create Virtual slot record.
CWD A
CWD AC                   if        handstack = *on
CWD AC                   eval      vswhse = slwhse
CWD AC                   eval      vswhdp = slwhdp
CWD AC                   eval      vsaisl = slaisl
CWD AC                   eval      vsloc  = slloc
CWD AC                   eval      vsrlvl = slrlvl
CWD AC                   eval      vshand = slhand
CWD AC                   eval      vsdisp = sldisp
CWD AC                   eval      vspdis = kydisp
CWD AC                   eval      vscdte = impdte
CWD AC                   eval      vsctim = imptim
CWD AC                   add       1             vsctim
CWD AC                   write (e) vsrec
CWD AC                   if        %error
CWD AC                   eval      error  = *on
CWD AC                   eval      detmsg = desc(8)
CWD AC                   add       1             notcrt
CWD AC                   goto      endcreate13
CWD AC                   endif
CWD A
CWD AC                   endif
CWD A
CWD A
CWD AC     endcreate13   endsr
HAL A
HAL A*----------------------------------------------------------------
HAL A*  crtslot14  Try and create physical slot.
HAL A*----------------------------------------------------------------
HAL A
HAL AC     crtslot14     begsr
HAL AC                   eval      notcreated = *off
HAL A
HAL A*  Turn on SlotCreated flag even if slot isn't created
HAL A*  so ZZUPD routine doesn't get executed.
HAL AC                   eval      slotcreated= *on
HAL AC                   eval      handstack  = *off
HAL AC                   clear                   slrec
HAL A
HAL A*  Extract location and level. Test if they are numeric.
HAL A
HAL AC                   eval      locnotnum = *off
HAL AC                   eval      lvlnotnum = *off
HAL AC                   eval      dashpos = 0
HAL AC                   eval      loca  = ' '
HAL AC                   eval      lvla  = ' '
HAL A
HAL A*  Check for all alpha slot. If no digits, default slot location
HAL A*  will be assigned.
HAL AC                   If            %subst(sidisp:3:3) >= '000'
HAL AC                             and %subst(sidisp:3:3) <= '999'
HAL AC                             and %subst(sidisp:7:1) >= '0'
HAL AC                             and %subst(sidisp:7:1) <= '9'
HAL AC                   eval      allchrslot = *off
HAL AC                   else
HAL AC                   eval      allchrslot = *on
HAL AC                   endif
HAL A
HAL AC                   select
HAL A
HAL A*  Dash specified. Single character aisle
HAL AC                   when          %subst(sidisp:2:3) >= '000'
HAL AC                             and %subst(sidisp:2:3) <= '999'
HAL AC                             and %subst(sidisp:5:1) = '-'
HAL AC                   eval      dashpos = -1
HAL AC                   eval      slaisl = ' ' + %subst(sidisp:1:1)
HAL AC                   eval      loca  = %subst(sidisp:3:3)
HAL AC                   move      loca          slloc
HAL AC                   eval      lvla  = %subst(sidisp:6:1)
HAL AC                   move      lvla          slrlvl
HAL AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
HAL A
HAL A*  Dash specified. Double character aisle
HAL AC                   when          %subst(sidisp:3:3) >= '000'
HAL AC                             and %subst(sidisp:3:3) <= '999'
HAL AC                             and %subst(sidisp:6:1) = '-'
HAL AC                   eval      dashpos = -1
HAL AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HAL AC                   eval      loca  = %subst(sidisp:3:3)
HAL AC                   move      loca          slloc
HAL AC                   eval      lvla  = %subst(sidisp:7:1)
HAL AC                   move      lvla          slrlvl
HAL AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
HAL A
HAL A*  No dashes specified. All character slot.
HAL AC                   when      allchrslot = *on
HAL AC
HAL AC                   eval      kydisp = sidisp
HAL AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
HAL AC
HAL AC                   eval      dftlocation = dftlocation + 1
HAL AC                   eval      loca   = %char(dftlocation)
HAL AC                   eval      slloc  = dftlocation
HAL AC
HAL AC                   eval      slrlvl = 1
HAL AC                   eval      lvla   = '1'
HAL AC
HAL AC                   eval      slhand  = '  '
HAL AC                   eval      dashpos = -1
HAL A
HAL AC                   endsl
HAL A
HAL A*  Begin testing parts for ALL slots.
HAL AC                   testn                   loca                 5050
HAL AC                   if        *in50 = *off
HAL AC                   eval      locnotnum = *on
HAL A
HAL AC                   else
HAL AC                   select
HAL AC                   when      slloc  = 0
HAL AC                   eval      slloc = slloc + 100
HAL AC                   when      slloc < 0
HAL AC                   eval      slloc = slloc * -1
HAL AC                   endsl
HAL AC                   endif
HAL A
HAL AC                   testn                   lvla                 50
HAL AC                   if        *in50 = *off
HAL AC                   eval      lvlnotnum = *on
HAL AC                   else
HAL AC                   select
HAL AC                   when      slrlvl = 0
HAL AC                   eval      slrlvl = slrlvl + 1
HAL AC                   when      slrlvl < 0
HAL AC                   eval      slrlvl = slrlvl * -1
HAL AC                   endsl
HAL AC                   endif
HAL A
HAL A*    Convert numeric handstack to alpha character.
HAL A
HAL AC                   if            slhand >= ' 0'
HAL AC                             and slhand <= '99'
HAL AC                   eval      wkchar = slhand
HAL AC                   exsr      zzcvt2ltr
HAL AC                   eval      slhand = nwchar
HAL AC                   endif
HAL A
HAL AC     slloc         div       2             dummy
HAL AC                   mvr                     oddeven
HAL AC                   if        oddeven <> 0
HAL AC                   eval      slside = 1
HAL AC                   else
HAL AC                   eval      slside = 0
HAL AC                   endif
HAL A
HAL A*    See if slot meets criteria for allowing it to be created.
HAL A
HAL AC                   select
HAL A
HAL A*    If non-special slot doesn't have hypens, then don't add it.
HAL A
HAL AC                   when      dashpos = 0
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    Don't allow creation if department is unknown.
HAL A
HAL AC                   when      validdept = '*NO '
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    If location or level is not numeric, then don't add.
HAL A
HAL AC                   when      locnotnum or lvlnotnum
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    Otherwise, slot is ok to be created.
HAL A
HAL AC                   other
HAL AC                   eval      slwhdp = siwhdp
HAL AC                   eval      sldisp = sidisp
HAL AC                   eval      slstyp = sistyp
HAL A
HAL AC                   endsl
HAL A
HAL A*    Try and create the imported slot.
HAL A
HAL AC                   eval      slwhse = siwhse
HAL AC                   eval      slpseq = sipseq
HAL AC*
HAL AC                   select
HAL AC                   when      slpseq = 0
HAL AC                   eval      slpseq = slloc
HAL AC                   when      slpseq < 0
HAL AC                   eval      slpseq = slpseq * -1
HAL AC                   endsl
HAL AC                   if        slitem > ' '
HAL AC                   eval      slstat = 'A'
HAL AC                   else
HAL AC                   eval      slstat = 'V'
HAL AC                   endif
HAL A*
HAL AC                   eval      slrsrv = sirsrv
HAL AC                   if        sidgtp > ' '
HAL AC                   eval      slsdef = sidgtp
HAL AC                   else
HAL AC                   eval      slsdef = 'XX'
HAL AC                   endif
HAL AC                   eval      slpick = sipick
HAL A
HAL AC                   write (e) slrec
HAL AC                   if        %error
HAL AC                   eval      notcreated = *on
HAL AC                   endif
HAL A
HAL AC     endcreate14   endsr
MAT A
MAT A*----------------------------------------------------------------
MAT A*  crtslot15  Try and create physical slot.
MAT A*----------------------------------------------------------------
MAT A
MAT AC     crtslot15     begsr
MAT AC                   eval      notcreated = *off
MAT A
MAT A*  Turn on SlotCreated flag even if slot isn't created
MAT A*  so ZZUPD routine doesn't get executed.
MAT AC                   eval      slotcreated= *on
MAT AC                   eval      handstack  = *off
MAT AC                   clear                   slrec
MAT A
MAT A*  Extract location and level. Test if they are numeric.
MAT A
MAT AC                   eval      locnotnum = *off
MAT AC                   eval      lvlnotnum = *off
MAT AC                   eval      dashpos = 0
MAT AC                   eval      loca  = ' '
MAT AC                   eval      lvla  = ' '
MAT A
MAT A*  Check for all alpha slot. If no digits, default slot location
MAT A*  will be assigned.
MAT AC                   If            %subst(sidisp:3:3) >= '000'
MAT AC                             and %subst(sidisp:3:3) <= '999'
MAT A
MAT AC                             or  %subst(sidisp:3:2) >= '00'
MAT AC                             and %subst(sidisp:3:2) <= '99'
MAT AC                             and %subst(sidisp:5:1) >= 'A'
MAT AC                             and %subst(sidisp:5:1) <= 'Z'
MAT AC                   eval      allchrslot = *off
MAT AC                   else
MAT AC                   eval      allchrslot = *on
MAT AC                   endif
MAT A
MAT A
MAT AC                   select
MAT A
MAT A*  No dashes specified. All character slot.
MAT AC                   when      allchrslot = *on
MAT AC
MAT AC                   eval      kydisp = sidisp
MAT AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
MAT AC
MAT AC                   eval      dftlocation = dftlocation + 1
MAT AC                   eval      loca   = %char(dftlocation)
MAT AC                   eval      slloc  = dftlocation
MAT AC
MAT AC                   eval      slrlvl = 1
MAT AC                   eval      lvla   = '1'
MAT AC
MAT AC                   eval      slhand  = '  '
MAT AC                   eval      dashpos = -1
MAT A
MAT A*  No Dashes specified. Double character aisle (Ex TS01A)
MAT AC                   when          %subst(sidisp:2:1) > ' '
MAT AC                             and %subst(sidisp:3:2) >= '00'
MAT AC                             and %subst(sidisp:3:2) <= '99'
MAT AC                             and %subst(sidisp:5:1) >= 'A'
MAT AC                             and %subst(sidisp:5:1) <= 'Z'
MAT AC                   eval      dashpos = -1
MAT AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
MAT AC                   eval      loca  = '0' + %subst(sidisp:3:2)
MAT AC                   move      loca          slloc
MAT A*
MAT A*      Convert alpha level into numeric value.
MAT AC                   eval      lvla    = %subst(sidisp:5:1)
MAT AC                   evalr     wkchar = %trimr(lvla)
MAT AC                   exsr      zzcvt2nbr
MAT AC                   if        nwchar > ' '
MAT AC                   evalr     lvla   = %trimr(nwchar)
MAT AC                   eval      slrlvl = %dec(nwchar:2:0)
MAT AC                   else
MAT AC                   evalr     lvla  = %subst(sidisp:5:1)
MAT AC                   move      lvla          slrlvl
MAT AC                   eval      slrlvl = slrlvl + 3
MAT AC                   endif
MAT AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
MAT A
MAT A
MAT A*  No Dashes specified. Double character aisle (Ex SC053A)
MAT AC                   when          %subst(sidisp:2:1) > ' '
MAT AC                             and %subst(sidisp:3:3) >= '000'
MAT AC                             and %subst(sidisp:3:3) <= '999'
MAT AC                             and %subst(sidisp:6:1) >= 'A'
MAT AC                             and %subst(sidisp:6:1) <= 'Z'
MAT AC                   eval      dashpos = -1
MAT AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
MAT AC                   eval      loca  = %subst(sidisp:3:3)
MAT AC                   move      loca          slloc
MAT A*
MAT A*      Convert alpha level into numeric value.
MAT AC                   eval      lvla    = %subst(sidisp:6:1)
MAT AC                   evalr     wkchar = %trimr(lvla)
MAT AC                   exsr      zzcvt2nbr
MAT AC                   if        nwchar > ' '
MAT AC                   evalr     lvla   = %trimr(nwchar)
MAT AC                   eval      slrlvl = %dec(nwchar:2:0)
MAT AC                   else
MAT AC                   evalr     lvla  = %subst(sidisp:6:1)
MAT AC                   move      lvla          slrlvl
MAT AC                   eval      slrlvl = slrlvl + 3
MAT AC                   endif
MAT AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
MAT A
MAT AC                   endsl
MAT A
MAT A*  Begin testing parts for ALL slots.
MAT AC                   testn                   loca                 5050
MAT AC                   if        *in50 = *off
MAT AC                   eval      locnotnum = *on
MAT A
MAT AC                   else
MAT AC                   select
MAT AC                   when      slloc  = 0
MAT AC                   eval      slloc = slloc + 100
MAT AC                   when      slloc < 0
MAT AC                   eval      slloc = slloc * -1
MAT AC                   endsl
MAT AC                   endif
MAT A
MAT AC                   testn                   lvla                 50
MAT AC                   if        *in50 = *off
MAT AC                   eval      lvlnotnum = *on
MAT AC                   else
MAT AC                   select
MAT AC                   when      slrlvl = 0
MAT AC                   eval      slrlvl = slrlvl + 1
MAT AC                   when      slrlvl < 0
MAT AC                   eval      slrlvl = slrlvl * -1
MAT AC                   endsl
MAT AC                   endif
MAT A
MAT A*    Convert numeric handstack to alpha character.
MAT A
MAT AC                   if            slhand >= ' 0'
MAT AC                             and slhand <= '99'
MAT AC                   eval      wkchar = slhand
MAT AC                   exsr      zzcvt2ltr
MAT AC                   eval      slhand = nwchar
MAT AC                   endif
MAT A
MAT AC     slloc         div       2             dummy
MAT AC                   mvr                     oddeven
MAT AC                   if        oddeven <> 0
MAT AC                   eval      slside = 1
MAT AC                   else
MAT AC                   eval      slside = 0
MAT AC                   endif
MAT A
MAT A*    See if slot meets criteria for allowing it to be created.
MAT A
MAT AC                   select
MAT A
MAT A*    If non-special slot doesn't have hypens, then don't add it.
MAT A
MAT AC                   when      dashpos = 0
MAT AC                   eval      notcreated = *on
MAT AC                   goto      endcreate15
MAT A
MAT A*    Don't allow creation if department is unknown.
MAT A
MAT AC                   when      validdept = '*NO '
MAT AC                   eval      notcreated = *on
MAT AC                   goto      endcreate15
MAT A
MAT A*    If location or level is not numeric, then don't add.
MAT A
MAT AC                   when      locnotnum or lvlnotnum
MAT AC                   eval      notcreated = *on
MAT AC                   goto      endcreate15
MAT A
MAT A*    Otherwise, slot is ok to be created.
MAT A
MAT AC                   other
MAT AC                   eval      slwhdp = siwhdp
MAT AC                   eval      sldisp = sidisp
MAT AC                   eval      slstyp = sistyp
MAT A
MAT AC                   endsl
MAT A
MAT A*    Try and create the imported slot.
MAT A
MAT AC                   eval      slwhse = siwhse
MAT AC                   eval      slpseq = sipseq
MAT AC*
MAT AC                   select
MAT AC                   when      slpseq = 0
MAT AC                   eval      slpseq = slloc
MAT AC                   when      slpseq < 0
MAT AC                   eval      slpseq = slpseq * -1
MAT AC                   endsl
MAT AC                   if        slitem > ' '
MAT AC                   eval      slstat = 'A'
MAT AC                   else
MAT AC                   eval      slstat = 'V'
MAT AC                   endif
MAT A*
MAT AC                   eval      slrsrv = sirsrv
MAT AC                   eval      slsdef = 'XX'
MAT AC                   eval      slpick = sipick
MAT A
MAT AC                   write (e) slrec
MAT AC                   if        %error
MAT AC                   eval      notcreated = *on
MAT AC                   endif
MAT A
MAT AC     endcreate15   endsr
FFC A
FFC A*----------------------------------------------------------------
FFC A*  crtslot16  Try and create physical slot.  Fischer Foods
FFC A*----------------------------------------------------------------
FFC A
FFC AC     crtslot16     begsr
FFC AC                   eval      notcreated = *off
FFC A
FFC A*  Turn on SlotCreated flag even if slot isn't created
FFC A*  so ZZUPD routine doesn't get executed.
FFC AC                   eval      slotcreated= *on
FFC AC                   eval      handstack  = *off
FFC AC                   clear                   slrec
FFC A
FFC A*  Extract location and level. Test if they are numeric.
FFC A
FFC AC                   eval      locnotnum = *off
FFC AC                   eval      lvlnotnum = *off
FFC AC                   eval      dashpos = 0
FFC AC                   eval      loca  = ' '
FFC AC                   eval      lvla  = ' '
FFC A
FFC A*  Check for all alpha slot. If no digits, default slot location
FFC A*  will be assigned.
FFC AC                   If            %subst(sidisp:4:3) >= '000'
FFC AC                             and %subst(sidisp:4:3) <= '999'
FFC AC                             and %subst(sidisp:8:1) >= '0'
FFC AC                             and %subst(sidisp:8:1) <= '9'
FFC A
FFC AC                             or  %subst(sidisp:4:3) >= '000'
FFC AC                             and %subst(sidisp:4:3) <= '999'
FFC AC                             and %subst(sidisp:8:2) >= '00'
FFC AC                             and %subst(sidisp:8:2) <= '99'
FFC A
FFC AC                   eval      allchrslot = *off
FFC AC                   else
FFC AC                   eval      allchrslot = *on
FFC AC                   endif
FFC A
FFC A
FFC AC                   select
FFC A
FFC A*  No dashes specified. All character slot.
FFC AC                   when      allchrslot = *on
FFC AC
FFC AC                   eval      kydisp = sidisp
FFC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
FFC AC
FFC AC                   eval      dftlocation = dftlocation + 1
FFC AC                   eval      loca   = %char(dftlocation)
FFC AC                   eval      slloc  = dftlocation
FFC AC
FFC AC                   eval      slrlvl = 1
FFC AC                   eval      lvla   = '1'
FFC AC
FFC AC                   eval      slhand  = '  '
FFC AC                   eval      dashpos = -1
FFC A
FFC A*  No Dashes specified. Double character aisle (Ex 10-101-1)
FFC AC                   when          %subst(sidisp:3:1) = '-'
FFC AC                             and %subst(sidisp:4:3) >= '000'
FFC AC                             and %subst(sidisp:4:3) <= '999'
FFC AC                             and %subst(sidisp:8:1) >= '0'
FFC AC                             and %subst(sidisp:8:1) <= '9'
FFC AC                   eval      dashpos = -1
FFC A*
FFC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FFC A*
FFC AC                   eval      loca  = %subst(sidisp:4:3)
FFC AC                   move      loca          slloc
FFC A*
FFC AC                   evalr     lvla  = %subst(sidisp:8:1)
FFC AC                   move      lvla          slrlvl
FFC A*
JSLcAC                   if        %subst(sidisp:9:1) = '.'
JSLcAC                   eval      slhand  = %subst(sidisp:9:2)
JSLcAC                   else
FFC AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
JSLcAC                   endif
FFC A
FFC A*  No Dashes specified. Double character aisle (Ex 10-101-10)
FFC AC                   when          %subst(sidisp:3:1) = '-'
FFC AC                             and %subst(sidisp:4:3) >= '000'
FFC AC                             and %subst(sidisp:4:3) <= '999'
FFC AC                             and %subst(sidisp:8:2) >= '00'
FFC AC                             and %subst(sidisp:8:2) <= '99'
FFC AC                   eval      dashpos = -1
FFC A*
FFC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FFC A*
FFC AC                   eval      loca  = %subst(sidisp:4:3)
FFC AC                   move      loca          slloc
FFC A*
FFC AC                   evalr     lvla  = %subst(sidisp:8:2)
FFC AC                   move      lvla          slrlvl
FFC A*
JSLcAC                   if        %subst(sidisp:10:1) = '.'
JSLcAC                   eval      slhand  = %subst(sidisp:10:2)
JSLcAC                   else
FFC AC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
JSLcAC                   endif
FFC A
FFC AC                   endsl
FFC A
FFC A*  Begin testing parts for ALL slots.
FFC AC                   testn                   loca                 5050
FFC AC                   if        *in50 = *off
FFC AC                   eval      locnotnum = *on
FFC A
FFC AC                   else
FFC AC                   select
FFC AC                   when      slloc  = 0
FFC AC                   eval      slloc = slloc + 100
FFC AC                   when      slloc < 0
FFC AC                   eval      slloc = slloc * -1
FFC AC                   endsl
FFC AC                   endif
FFC A
FFC AC                   testn                   lvla                 50
FFC AC                   if        *in50 = *off
FFC AC                   eval      lvlnotnum = *on
FFC AC                   else
FFC AC                   select
FFC AC                   when      slrlvl = 0
FFC AC                   eval      slrlvl = slrlvl + 1
FFC AC                   when      slrlvl < 0
FFC AC                   eval      slrlvl = slrlvl * -1
FFC AC                   endsl
FFC AC                   endif
FFC A
FFC A*    Convert numeric handstack to alpha character.
FFC A
FFC AC                   if            slhand >= ' 0'
FFC AC                             and slhand <= '99'
JSLcAC                             and %subst(slhand:1:1) <> '.'
FFC AC                   eval      wkchar = slhand
FFC AC                   exsr      zzcvt2ltr
FFC AC                   eval      slhand = nwchar
FFC AC                   endif
FFC A
FFC AC     slloc         div       2             dummy
FFC AC                   mvr                     oddeven
FFC AC                   if        oddeven <> 0
FFC AC                   eval      slside = 1
FFC AC                   else
FFC AC                   eval      slside = 0
FFC AC                   endif
FFC A
FFC A*    See if slot meets criteria for allowing it to be created.
FFC A
FFC AC                   select
FFC A
FFC A*    If non-special slot doesn't have hypens, then don't add it.
FFC A
FFC AC                   when      dashpos = 0
FFC AC                   eval      notcreated = *on
FFC AC                   goto      endcreate16
FFC A
FFC A*    Don't allow creation if department is unknown.
FFC A
FFC AC                   when      validdept = '*NO '
FFC AC                   eval      notcreated = *on
FFC AC                   goto      endcreate16
FFC A
FFC A*    If location or level is not numeric, then don't add.
FFC A
FFC AC                   when      locnotnum or lvlnotnum
FFC AC                   eval      notcreated = *on
FFC AC                   goto      endcreate16
FFC A
FFC A*    Otherwise, slot is ok to be created.
FFC A
FFC AC                   other
FFC AC                   eval      slwhdp = siwhdp
FFC AC                   eval      sldisp = sidisp
FFC AC                   eval      slstyp = sistyp
FFC A
FFC AC                   endsl
FFC A
FFC A*    Try and create the imported slot.
FFC A
FFC AC                   eval      slwhse = siwhse
FFC AC                   eval      slpseq = sipseq
FFC AC*
FFC AC                   select
FFC AC                   when      slpseq = 0
FFC AC                   eval      slpseq = slloc
FFC AC                   when      slpseq < 0
FFC AC                   eval      slpseq = slpseq * -1
FFC AC                   endsl
FFC AC                   if        slitem > ' '
FFC AC                   eval      slstat = 'A'
FFC AC                   else
FFC AC                   eval      slstat = 'V'
FFC AC                   endif
FFC A*
FFC AC                   eval      slrsrv = sirsrv
FFC A*
JSLaA*  For Julius Silvert, put check digit type in sdef
JSLaAC                   select
JSLaAC                   when      client = JSilvert
JSLaAC                             and sidgt = 0
JSLaAC                             and sidgtp <> *blank
JSLaAC                   eval      slsdef = sidgtp
JSLaAC                   other
FFC AC                   eval      slsdef = 'XX'
JSLaAC                   endsl
FFC A*
FFC AC                   eval      slpick = sipick
FFC A
FFC AC                   write (e) slrec
FFC AC                   if        %error
FFC AC                   eval      notcreated = *on
FFCbAC                   eval      notupd = notupd + 1
FFCbAC                   else
FFCbAC                   eval      sltcrt = sltcrt + 1
FFC AC                   endif
FFC A
FFC AC     endcreate16   endsr
CCP A
CCP A*----------------------------------------------------------------
CCP A*  crtslot17  Try and create physical slot.  Capitol City Produce
CCP A*----------------------------------------------------------------
CCP A
CCP AC     crtslot17     begsr
CCP AC                   eval      notcreated = *off
CCP A
CCP A*  Turn on SlotCreated flag even if slot isn't created
CCP A*  so ZZUPD routine doesn't get executed.
CCP AC                   eval      slotcreated= *on
CCP AC                   eval      handstack  = *off
CCP AC                   clear                   slrec
CCP A
CCP A*  Extract location and level. Test if they are numeric.
CCP A
CCP AC                   eval      locnotnum = *off
CCP AC                   eval      lvlnotnum = *off
CCP AC                   eval      dashpos = 0
CCP AC                   eval      loca  = ' '
CCP AC                   eval      lvla  = ' '
CCP A
CCP A*  Check for all alpha slot. If no digits, default slot location
CCP A*  will be assigned.
CCP AC                   If            %subst(sidisp:4:2) >= '00'
CCP AC                             and %subst(sidisp:4:2) <= '99'
CCP AC                             and %subst(sidisp:7:1) >= '0'
CCP AC                             and %subst(sidisp:7:1) <= '9'
CCP AC                   eval      allchrslot = *off
CCP AC                   else
CCP AC                   eval      allchrslot = *on
CCP AC                   endif
CCP A
CCP A
CCP AC                   select
CCP A
CCP A*  No dashes specified. All character slot.
CCP AC                   when      allchrslot = *on
CCP AC
CCP AC                   eval      kydisp = sidisp
CCP AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CCP AC
CCP AC                   eval      dftlocation = dftlocation + 1
CCP AC                   eval      loca   = %char(dftlocation)
CCP AC                   eval      slloc  = dftlocation
CCP AC
CCP AC                   eval      slrlvl = 1
CCP AC                   eval      lvla   = '1'
CCP AC
CCP AC                   eval      slhand  = '  '
CCP AC                   eval      dashpos = -1
CCP A
CCP A*  No Dashes specified. Double character aisle (Ex 10-10-1)
CCP AC                   when          %subst(sidisp:3:1) = '-'
CCP AC                             and %subst(sidisp:4:2) >= '00'
CCP AC                             and %subst(sidisp:4:2) <= '99'
CCP AC                             and %subst(sidisp:7:1) >= '0'
CCP AC                             and %subst(sidisp:7:1) <= '9'
CCP AC                   eval      dashpos = -1
CCP A*
CCP AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CCP A*
CCP AC                   eval      loca  = '0' + %subst(sidisp:4:2)
CCP AC                   move      loca          slloc
CCP A*
CCP AC                   evalr     lvla  = '0' + %subst(sidisp:7:1)
CCP AC                   move      lvla          slrlvl
CCP A*
CCP AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CCP A
CCP A*  No Dashes specified. Double character aisle (Ex 10-10-10)
CCP AC                   when          %subst(sidisp:3:1) = '-'
CCP AC                             and %subst(sidisp:4:2) >= '00'
CCP AC                             and %subst(sidisp:4:2) <= '99'
CCP AC                             and %subst(sidisp:7:2) >= '00'
CCP AC                             and %subst(sidisp:7:2) <= '99'
CCP AC                   eval      dashpos = -1
CCP A*
CCP AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CCP A*
CCP AC                   eval      loca  = '0' + %subst(sidisp:4:2)
CCP AC                   move      loca          slloc
CCP A*
CCP AC                   evalr     lvla  = %subst(sidisp:7:2)
CCP AC                   move      lvla          slrlvl
CCP A*
CCP AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CCP A
CCP AC                   endsl
CCP A
CCP A*  Begin testing parts for ALL slots.
CCP AC                   testn                   loca                 5050
CCP AC                   if        *in50 = *off
CCP AC                   eval      locnotnum = *on
CCP A
CCP AC                   else
CCP AC                   select
CCP AC                   when      slloc  = 0
CCP AC                   eval      slloc = slloc + 10
CCP AC                   when      slloc < 0
CCP AC                   eval      slloc = slloc * -1
CCP AC                   endsl
CCP AC                   endif
CCP A
CCP AC                   testn                   lvla                 50
CCP AC                   if        *in50 = *off
CCP AC                   eval      lvlnotnum = *on
CCP AC                   else
CCP AC                   select
CCP AC                   when      slrlvl = 0
CCP AC                   eval      slrlvl = slrlvl + 1
CCP AC                   when      slrlvl < 0
CCP AC                   eval      slrlvl = slrlvl * -1
CCP AC                   endsl
CCP AC                   endif
CCP A
CCP A*    Convert numeric handstack to alpha character.
CCP A
CCP AC                   if            slhand >= ' 0'
CCP AC                             and slhand <= '99'
CCP AC                   eval      wkchar = slhand
CCP AC                   exsr      zzcvt2ltr
CCP AC                   eval      slhand = nwchar
CCP AC                   endif
CCP A
CCP AC     slloc         div       2             dummy
CCP AC                   mvr                     oddeven
CCP AC                   if        oddeven <> 0
CCP AC                   eval      slside = 1
CCP AC                   else
CCP AC                   eval      slside = 0
CCP AC                   endif
CCP A
CCP A*    See if slot meets criteria for allowing it to be created.
CCP A
CCP AC                   select
CCP A
CCP A*    If non-special slot doesn't have hypens, then don't add it.
CCP A
CCP AC                   when      dashpos = 0
CCP AC                   eval      notcreated = *on
CCP AC                   goto      endcreate17
CCP A
CCP A*    Don't allow creation if department is unknown.
CCP A
CCP AC                   when      validdept = '*NO '
CCP AC                   eval      notcreated = *on
CCP AC                   goto      endcreate17
CCP A
CCP A*    If location or level is not numeric, then don't add.
CCP A
CCP AC                   when      locnotnum or lvlnotnum
CCP AC                   eval      notcreated = *on
CCP AC                   goto      endcreate17
CCP A
CCP A*    Otherwise, slot is ok to be created.
CCP A
CCP AC                   other
CCP AC                   eval      slwhdp = siwhdp
CCP AC                   eval      sldisp = sidisp
CCP AC                   eval      slstyp = sistyp
CCP A
CCP AC                   endsl
CCP A
CCP A*    Try and create the imported slot.
CCP A
CCP AC                   eval      slwhse = siwhse
CCP AC                   eval      slpseq = sipseq
CCP AC*
CCP AC                   select
CCP AC                   when      slpseq = 0
CCP AC                   eval      slpseq = slloc
CCP AC                   when      slpseq < 0
CCP AC                   eval      slpseq = slpseq * -1
CCP AC                   endsl
CCP AC                   if        slitem > ' '
CCP AC                   eval      slstat = 'A'
CCP AC                   else
CCP AC                   eval      slstat = 'V'
CCP AC                   endif
CCP A*
CCP AC                   eval      slrsrv = sirsrv
CCP AC                   eval      slsdef = 'XX'
CCP AC                   eval      slpick = sipick
CCP A
CCP AC                   write (e) slrec
CCP AC                   if        %error
CCP AC                   eval      notcreated = *on
CCP AC                   endif
CCP A
CCP AC     endcreate17   endsr
MAT A
CSP A*----------------------------------------------------------------
CSP A*  crtslot18  Try and create physical slot. Coastal Sunbelt Produce
CSP A*----------------------------------------------------------------
CSP A
CSP AC     crtslot18     begsr
CSP AC                   eval      notcreated = *off
CSP A
CSP A*  Turn on SlotCreated flag even if slot isn't created
CSP A*  so ZZUPD routine doesn't get executed.
CSP AC                   eval      slotcreated= *on
CSP AC                   eval      handstack  = *off
CSP AC                   clear                   slrec
CSP A
CSP A*  Extract location and level. Test if they are numeric.
CSP A
CSP AC                   eval      locnotnum = *off
CSP AC                   eval      lvlnotnum = *off
CSP AC                   eval      dashpos = 0
CSP AC                   eval      loca  = ' '
CSP AC                   eval      lvla  = ' '
CSP A
CSP A*  Check for all alpha slot. If no digits, default slot location
CSP A*  will be assigned.
CSP AC                   If            %subst(sidisp:3:3) >= '000'
CSP AC                             and %subst(sidisp:3:3) <= '999'
CSP A
CSP AC                             or  %subst(sidisp:4:3) >= '000'
CSP AC                             and %subst(sidisp:4:3) <= '999'
CSP A
CSP AC                   eval      allchrslot = *off
CSP AC                   else
CSP AC                   eval      allchrslot = *on
CSP AC                   endif
CSP A
CSP A
CSP AC                   select
CSP A
CSP A*  No dashes specified. All character slot.
CSP AC                   when      allchrslot = *on
CSP AC
CSP AC                   eval      kydisp = sidisp
CSP AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CSP AC
CSP AC                   eval      dftlocation = dftlocation + 1
CSP AC                   eval      loca   = %char(dftlocation)
CSP AC                   eval      slloc  = dftlocation
CSP AC
CSP AC                   eval      slrlvl = 1
CSP AC                   eval      lvla   = '1'
CSP AC
CSP AC                   eval      slhand  = '  '
CSP AC                   eval      dashpos = -1
CSP A
CSP A*  One Dash specified. Double character aisle (Ex 40-351A)
CSP AC                   when          %subst(sidisp:3:1) = '-'
CSP AC                             and %subst(sidisp:4:3) >= '000'
CSP AC                             and %subst(sidisp:4:3) <= '999'
CSP AC                             and %subst(sidisp:7:1) >= 'A'
CSP AC                             and %subst(sidisp:7:1) <= 'Z'
CSP AC                   eval      dashpos = -1
CSP AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CSP AC                   eval      loca  = %subst(sidisp:4:3)
CSP AC                   move      loca          slloc
CSP A*
CSP A*      Convert alpha level into numeric value.
CSP AC                   eval      lvla    = %subst(sidisp:7:1)
CSP AC                   evalr     wkchar = %trimr(lvla)
CSP AC                   exsr      zzcvt2nbr
CSP AC                   if        nwchar > ' '
CSP AC                   evalr     lvla   = %trimr(nwchar)
CSP AC                   eval      slrlvl = %dec(nwchar:2:0)
CSP AC                   else
CSP AC                   evalr     lvla  = '0' + %subst(sidisp:7:1)
CSP AC                   move      lvla          slrlvl
CSP AC                   endif
CSP AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CSP A
CSP A*  Two Dashes specified. Single character aisle (Ex 4-351-1)
CSP AC                   when          %subst(sidisp:2:1) = '-'
CSP AC                             and %subst(sidisp:3:3) >= '000'
CSP AC                             and %subst(sidisp:3:3) <= '999'
CSP AC                             and %subst(sidisp:6:1) = '-'
CSP AC                             and %subst(sidisp:7:1) >= '0'
CSP AC                             and %subst(sidisp:7:1) <= '9'
CSP AC                   eval      dashpos = -1
CSP AC                   eval      slaisl = ' 0' + %subst(sidisp:1:1)
CSP AC                   eval      loca  = %subst(sidisp:3:3)
CSP AC                   move      loca          slloc
CSP A*
CSP AC                   evalr     lvla  = '0' + %subst(sidisp:7:1)
CSP AC                   move      lvla          slrlvl
CSP AC
CSP AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CSP A
CSP A*  Two Dashes specified. Double character aisle (Ex 40-351-1)
CSP AC                   when          %subst(sidisp:3:1) = '-'
CSP AC                             and %subst(sidisp:4:3) >= '000'
CSP AC                             and %subst(sidisp:4:3) <= '999'
CSP AC                             and %subst(sidisp:7:1) = '-'
CSP AC                             and %subst(sidisp:8:1) >= '0'
CSP AC                             and %subst(sidisp:8:1) <= '9'
CSP2AC                             and %subst(sidisp:9:1) >= ' '
CSP2AC                             and %subst(sidisp:9:1) <= 'Z'
CSP AC                   eval      dashpos = -1
CSP AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CSP AC                   eval      loca  = %subst(sidisp:4:3)
CSP AC                   move      loca          slloc
CSP A*
CSP AC                   evalr     lvla  = '0' + %subst(sidisp:8:1)
CSP AC                   move      lvla          slrlvl
CSP AC
CSP AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CSP A
CSP2A
CSP2A*  Two Dashes specified. Double character aisle (Ex 40-351-01A)
CSP2AC                   when          %subst(sidisp:3:1) = '-'
CSP2AC                             and %subst(sidisp:4:3) >= '000'
CSP2AC                             and %subst(sidisp:4:3) <= '999'
CSP2AC                             and %subst(sidisp:7:1) = '-'
CSP2AC                             and %subst(sidisp:8:1) >= '0'
CSP2AC                             and %subst(sidisp:8:1) <= '9'
CSP2AC                             and %subst(sidisp:9:1) >= '0'
CSP2AC                             and %subst(sidisp:9:1) <= '9'
CSP2AC                   eval      dashpos = -1
CSP2AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CSP2AC                   eval      loca  = %subst(sidisp:4:3)
CSP2AC                   move      loca          slloc
CSP2A*
CSP2AC                   eval      lvla  = %subst(sidisp:9:1)
CSP2AC                   evalr     lvlaa = %subst(sidisp:8:2)
CSP2AC                   move      lvlaa         slrlvl
CSP2AC
CSP2AC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
CSP2A
CSP AC                   endsl
CSP A
CSP A*  Begin testing parts for ALL slots.
CSP AC                   testn                   loca                 5050
CSP AC                   if        *in50 = *off
CSP AC                   eval      locnotnum = *on
CSP A
CSP AC                   else
CSP AC                   select
CSP AC                   when      slloc  = 0
CSP AC                   eval      slloc = slloc + 100
CSP AC                   when      slloc < 0
CSP AC                   eval      slloc = slloc * -1
CSP AC                   endsl
CSP AC                   endif
CSP A
CSP AC                   testn                   lvla                 50
CSP AC                   if        *in50 = *off
CSP AC                   eval      lvlnotnum = *on
CSP AC                   else
CSP AC                   select
CSP AC                   when      slrlvl = 0
CSP AC                   eval      slrlvl = slrlvl + 1
CSP AC                   when      slrlvl < 0
CSP AC                   eval      slrlvl = slrlvl * -1
CSP AC                   endsl
CSP AC                   endif
CSP A
CSP A*    Convert numeric handstack to alpha character.
CSP A
CSP AC                   if            slhand >= ' 0'
CSP AC                             and slhand <= '99'
CSP AC                   eval      wkchar = slhand
CSP AC                   exsr      zzcvt2ltr
CSP AC                   eval      slhand = nwchar
CSP AC                   endif
CSP A
CSP AC     slloc         div       2             dummy
CSP AC                   mvr                     oddeven
CSP AC                   if        oddeven <> 0
CSP AC                   eval      slside = 1
CSP AC                   else
CSP AC                   eval      slside = 0
CSP AC                   endif
CSP A
CSP A*    See if slot meets criteria for allowing it to be created.
CSP A
CSP AC                   select
CSP A
CSP A*    If non-special slot doesn't have hypens, then don't add it.
CSP A
CSP AC                   when      dashpos = 0
CSP AC                   eval      notcreated = *on
CSP AC                   goto      endcreate18
CSP A
CSP A*    Don't allow creation if department is unknown.
CSP A
CSP AC                   when      validdept = '*NO '
CSP AC                   eval      notcreated = *on
CSP AC                   goto      endcreate18
CSP A
CSP A*    If location or level is not numeric, then don't add.
CSP A
CSP AC                   when      locnotnum or lvlnotnum
CSP AC                   eval      notcreated = *on
CSP AC                   goto      endcreate18
CSP A
CSP A*    Otherwise, slot is ok to be created.
CSP A
CSP AC                   other
CSP AC                   eval      slwhdp = siwhdp
CSP AC                   eval      sldisp = sidisp
CSP AC                   eval      slstyp = sistyp
CSP A
CSP AC                   endsl
CSP A
CSP A*    Try and create the imported slot.
CSP A
CSP AC                   eval      slwhse = siwhse
CSP AC                   eval      slpseq = sipseq
CSP AC*
CSP AC                   select
CSP AC                   when      slpseq = 0
CSP AC                   eval      slpseq = slloc
CSP AC                   when      slpseq < 0
CSP AC                   eval      slpseq = slpseq * -1
CSP AC                   endsl
CSP AC                   if        slitem > ' '
CSP AC                   eval      slstat = 'A'
CSP AC                   else
CSP AC                   eval      slstat = 'V'
CSP AC                   endif
CSP A*
CSP AC                   eval      slrsrv = sirsrv
CSP2A*
CSP2AC                   if        sidgtp > ' '
CSP2AC                   eval      slsdef = sidgtp
CSP2AC                   else
CSP2A*
CSP AC                   eval      slsdef = 'XX'
CSP2AC                   endif
CSP2A*
CSP2AC                   eval      slbld  = 'NW'
CSP AC                   eval      slpick = sipick
CSP A
CSP AC                   write (e) slrec
CSP AC                   if        %error
CSP AC                   eval      notcreated = *on
CSP AC                   endif
CSP A
CSP AC     endcreate18   endsr
CPC A
CPC A*----------------------------------------------------------------
CPC A*  crtslot19  Try and create physical slot. Crumbley Paper & Foodsvc
CPC A*----------------------------------------------------------------
CPC A
CPC AC     crtslot19     begsr
CPC AC                   eval      notcreated = *off
CPC A
CPC A*  Turn on SlotCreated flag even if slot isn't created
CPC A*  so ZZUPD routine doesn't get executed.
CPC AC                   eval      slotcreated= *on
CPC AC                   eval      handstack  = *off
CPC AC                   clear                   slrec
CPC A
CPC A*  Extract location and level. Test if they are numeric.
CPC A
CPC AC                   eval      locnotnum = *off
CPC AC                   eval      lvlnotnum = *off
CPC AC                   eval      dashpos = 0
CPC AC                   eval      loca  = ' '
CPC AC                   eval      lvla  = ' '
CPC A
CPC A*  Check for all alpha slot. If no digits, default slot location
CPC A*  will be assigned.
CPC AC                   If            %subst(sidisp:2:4) >= '0000'
CPC AC                             and %subst(sidisp:2:4) <= '9999'
CPC AC                             and %subst(sidisp:6:1)  = ' '
CPC A
CPC AC                             or  %subst(sidisp:3:4) >= '0000'
CPC AC                             and %subst(sidisp:3:4) <= '9999'
CPC AC                             and %subst(sidisp:7:1)  = ' '
CPC A
CPC AC                   eval      allchrslot = *off
CPC AC                   else
CPC AC                   eval      allchrslot = *on
CPC AC                   endif
CPC A
CPC A
CPC AC                   select
CPC A
CPC A*  No dashes specified. All character slot.
CPC AC                   when      allchrslot = *on
CPC AC
CPC AC                   eval      kydisp = sidisp
CPC AC                   if        %subst(sidisp:6:1) = ' '
CPC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
CPC AC                   else
CPC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CPC AC                   endif
CPC AC
CPC AC                   eval      dftlocation = dftlocation + 1
CPC AC                   eval      loca   = %char(dftlocation)
CPC AC                   eval      slloc  = dftlocation
CPC AC
CPC AC                   eval      slrlvl = 1
CPC AC                   eval      lvla   = '1'
CPC AC
CPC AC                   eval      slhand  = '  '
CPC AC                   eval      dashpos = -1
CPC A
CPC A*  No Dash specified. Single character aisle (Ex B1234A)
CPC AC                   when          %subst(sidisp:2:2) >= '00'
CPC AC                             and %subst(sidisp:2:2) <= '99'
CPC AC                             and %subst(sidisp:4:1) >= '0'
CPC AC                             and %subst(sidisp:4:1) <= '9'
CPC AC                             and %subst(sidisp:5:1) >= '0'
CPC AC                             and %subst(sidisp:5:1) <= '9'
CPC AC                             and %subst(sidisp:6:1)  = ' '
CPC AC                   eval      dashpos = -1
CPC AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
CPC AC                   eval      loca  = '0' + %subst(sidisp:2:2)
CPC AC                   move      loca          slloc
CPC A*
CPC AC                   eval      lvla = %subst(sidisp:4:1)
CPC AC                   move      lvla          slrlvl
CPC A*
CPC AC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
CPC AC                   if           slhand = '  '
CPC AC                             or slhand = ' 0'
CPC AC                   eval      slhand = ' 1'
CPC AC                   endif
CPC A
CPC A*  No Dashes specified. Double character aisle (Ex 121234)
CPC AC                   when          %subst(sidisp:3:2) >= '00'
CPC AC                             and %subst(sidisp:3:2) <= '99'
CPC AC                             and %subst(sidisp:4:1) >= '0'
CPC AC                             and %subst(sidisp:4:1) <= '9'
CPC AC                             and %subst(sidisp:5:1) >= '0'
CPC AC                             and %subst(sidisp:5:1) <= '9'
CPC AC                             and %subst(sidisp:7:1)  = ' '
CPC AC                   eval      dashpos = -1
CPC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CPC AC                   eval      loca  = '0' + %subst(sidisp:3:2)
CPC AC                   move      loca          slloc
CPC A*
CPC AC                   eval      lvla = %subst(sidisp:5:1)
CPC AC                   move      lvla          slrlvl
CPC AC
CPC AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
CPC AC                   if           slhand = '  '
CPC AC                             or slhand = ' 0'
CPC AC                   eval      slhand = ' 1'
CPC AC                   endif
CPC A
CPC AC                   endsl
CPC A
CPC A*  Begin testing parts for ALL slots.
CPC AC                   testn                   loca                 5050
CPC AC                   if        *in50 = *off
CPC AC                   eval      locnotnum = *on
CPC A
CPC AC                   else
CPC AC                   select
CPC AC                   when      slloc  = 0
CPC AC*                  eval      slloc = slloc + 100
CPC AC                   when      slloc < 0
CPC AC                   eval      slloc = slloc * -1
CPC AC                   endsl
CPC AC                   endif
CPC A
CPC AC                   testn                   lvla                 50
CPC AC                   if        *in50 = *off
CPC AC                   eval      lvlnotnum = *on
CPC AC                   else
CPC AC                   select
CPC AC                   when      slrlvl = 0
CPC AC                   eval      slrlvl = slrlvl + 1
CPC AC                   when      slrlvl < 0
CPC AC                   eval      slrlvl = slrlvl * -1
CPC AC                   endsl
CPC AC                   endif
CPC A
CPC A*    Convert numeric handstack to alpha character.
CPC A
CPC AC                   if            slhand >= ' 0'
CPC AC                             and slhand <= '99'
CPC AC**                 eval      wkchar = slhand
CPC AC**                 exsr      zzcvt2ltr
CPC AC**                 eval      slhand = nwchar
CPC AC                   endif
CPC A
CPC AC     slloc         div       2             dummy
CPC AC                   mvr                     oddeven
CPC AC                   if        oddeven <> 0
CPC AC                   eval      slside = 1
CPC AC                   else
CPC AC                   eval      slside = 0
CPC AC                   endif
CPC A
CPC A*    See if slot meets criteria for allowing it to be created.
CPC A
CPC AC                   select
CPC A
CPC A*    If non-special slot doesn't have hypens, then don't add it.
CPC A
CPC AC                   when      dashpos = 0
CPC AC                   eval      notcreated = *on
CPC AC                   goto      endcreate19
CPC A
CPC A*    Don't allow creation if department is unknown.
CPC A
CPC AC                   when      validdept = '*NO '
CPC AC                   eval      notcreated = *on
CPC AC                   goto      endcreate19
CPC A
CPC A*    If location or level is not numeric, then don't add.
CPC A
CPC AC                   when      locnotnum or lvlnotnum
CPC AC                   eval      notcreated = *on
CPC AC                   goto      endcreate19
CPC A
CPC A*    Otherwise, slot is ok to be created.
CPC A
CPC AC                   other
CPC AC                   eval      slwhdp = siwhdp
CPC AC                   eval      sldisp = sidisp
CPC AC                   eval      slstyp = sistyp
CPC A
CPC AC                   endsl
CPC A
CPC A*    Try and create the imported slot.
CPC A
CPC AC                   eval      slwhse = siwhse
CPC AC                   eval      slpseq = sipseq
CPC AC*
CPC AC                   select
CPC AC                   when      slpseq = 0
CPC AC                   eval      slpseq = slloc
CPC AC                   when      slpseq < 0
CPC AC                   eval      slpseq = slpseq * -1
CPC AC                   endsl
CPC AC                   if        slitem > ' '
CPC AC                   eval      slstat = 'A'
CPC AC                   else
CPC AC                   eval      slstat = 'V'
CPC AC                   endif
CPC A*
CPC AC                   eval      slrsrv = sirsrv
CPC AC                   eval      slsdef = 'XX'
CPC AC                   eval      slpick = sipick
CPC A
CPC AC                   write (e) slrec
CPC AC                   if        %error
CPC AC                   eval      notcreated = *on
CPC AC                   endif
CPC A
CPC AC     endcreate19   endsr
NCH A
NCH A*----------------------------------------------------------------
NCH A*  crtslot20  Try and create physical slot. Nicholas & Co.
NCH A*----------------------------------------------------------------
NCH A
NCH AC     crtslot20     begsr
NCH AC                   eval      notcreated = *off
NCH A
NCH A*  Turn on SlotCreated flag even if slot isn't created
NCH A*  so ZZUPD routine doesn't get executed.
NCH AC                   eval      slotcreated= *on
NCH AC                   eval      handstack  = *off
NCH AC                   clear                   slrec
NCH A
NCH A*  Extract location and level. Test if they are numeric.
NCH A
NCH AC                   eval      locnotnum = *off
NCH AC                   eval      lvlnotnum = *off
NCH AC                   eval      dashpos = 0
NCH AC                   eval      loca  = ' '
NCH AC                   eval      lvla  = ' '
NCH A
NCH A*  Check for all alpha slot. If no digits, default slot location
NCH A*  will be assigned.
NCH AC                   If            %subst(sidisp:3:3) >= '000'
NCH AC                             and %subst(sidisp:3:3) <= '999'
NCH A
NCH AC                             or  %subst(sidisp:3:4) >= '0000'
NCH AC                             and %subst(sidisp:3:4) <= '9999'
NCH A
NCH AC                   eval      allchrslot = *off
NCH AC                   else
NCH AC                   eval      allchrslot = *on
NCH AC                   endif
NCH A
NCH A
NCH AC                   select
NCH A
NCH A*  No dashes specified. All character slot.
NCH AC                   when      allchrslot = *on
NCH AC
NCH AC                   eval      kydisp = sidisp
NCH AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
NCH AC
NCH AC                   eval      dftlocation = dftlocation + 1
NCH AC                   eval      loca   = %char(dftlocation)
NCH AC                   eval      slloc  = dftlocation
NCH AC
NCH AC                   eval      slrlvl = 1
NCH AC                   eval      lvla   = '1'
NCH AC
NCH AC                   eval      slhand  = '  '
NCH AC                   eval      dashpos = -1
NCH A
NCH A*  No Dash specified. Single character aisle (Ex CD075S or DN111R1).
NCH AC                   when          %subst(sidisp:3:3) >= '000'
NCH AC                             and %subst(sidisp:3:3) <= '999'
NCH AC                             and %subst(sidisp:7:1)  = ' '
NCH A*
NCH AC                             or  %subst(sidisp:3:3) >= '000'
NCH AC                             and %subst(sidisp:3:3) <= '999'
NCH AC                             and %subst(sidisp:7:1) >= '0'
NCH AC                             and %subst(sidisp:7:1) <= '9'
NCH AC                   eval      dashpos = -1
NCH2DC*                  eval      slaisl = %trimr(%subst(sidisp:1:3))
NCH2MC                   eval      slaisl = %trimr(%subst(sidisp:1:2))
NCH2DC*                  eval      loca  = '0' + %subst(sidisp:4:2)
NCH2MC                   eval      loca  = %subst(sidisp:3:3)
NCH AC                   move      loca          slloc
NCH A*
NCH AC                   select
NCH AC                   when      %subst(sidisp:7:1) = ' '
NCH AC                   eval      lvla = '1'
NCH A*
NCH AC                   when          %subst(sidisp:7:1) >= '0'
NCH AC                             and %subst(sidisp:7:1) <= '9'
NCH AC                   eval      lvla = %subst(sidisp:7:1)
NCH AC                   move      lvla          slrlvl
NCH AC                   endsl
NCH A*
NCH AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
NCH A
NCH A*  No Dash specified. Single character aisle (Ex DT5120A).
NCH AC                   when          %subst(sidisp:3:4) >= '0000'
NCH AC                             and %subst(sidisp:3:3) <= '9999'
NCH AC                             and %subst(sidisp:7:1) >= 'A'
NCH AC                             and %subst(sidisp:7:1) <= 'Z'
NCH AC                   eval      dashpos = -1
NCH2DC*                  evalr     slaisl = %trimr(%subst(sidisp:1:3))
NCH2MC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
NCH2DC*                  eval      loca  = '0' + %subst(sidisp:4:2)
NCH2MC                   eval      loca  = %subst(sidisp:3:3)
NCH AC                   move      loca          slloc
NCH A*
NCH AC                   select
NCH AC                   when      %subst(sidisp:6:1) = ' '
NCH AC                   eval      lvla = '1'
NCH A*
NCH AC                   when          %subst(sidisp:6:1) >= '0'
NCH AC                             and %subst(sidisp:6:1) <= '9'
NCH AC                   eval      lvla = %subst(sidisp:6:1)
NCH AC                   move      lvla          slrlvl
NCH AC                   endsl
NCH A*
NCH AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
NCH A
NCH AC                   endsl
NCH A
NCH A*  Begin testing parts for ALL slots.
NCH AC                   testn                   loca                 5050
NCH AC                   if        *in50 = *off
NCH AC                   eval      locnotnum = *on
NCH A
NCH AC                   else
NCH AC                   select
NCH AC                   when      slloc  = 0
NCH AC*                  eval      slloc = slloc + 100
NCH AC                   when      slloc < 0
NCH AC                   eval      slloc = slloc * -1
NCH AC                   endsl
NCH AC                   endif
NCH A
NCH AC                   testn                   lvla                 50
NCH AC                   if        *in50 = *off
NCH AC                   eval      lvlnotnum = *on
NCH AC                   else
NCH AC                   select
NCH A*    Needed to add 1 to Rack Level for all slots because
NCH A*    not all slots have a rack level as part of slot.
NCH AC                   when      slrlvl >= 0
NCH AC                   eval      slrlvl = slrlvl + 1
NCH AC                   when      slrlvl < 0
NCH AC                   eval      slrlvl = slrlvl * -1
NCH AC                   endsl
NCH AC                   endif
NCH A
NCH A*    Convert numeric handstack to alpha character.
NCH A
NCH AC                   if            slhand >= ' 0'
NCH AC                             and slhand <= '99'
NCH AC**                 eval      wkchar = slhand
NCH AC**                 exsr      zzcvt2ltr
NCH AC**                 eval      slhand = nwchar
NCH AC                   endif
NCH A
NCH AC     slloc         div       2             dummy
NCH AC                   mvr                     oddeven
NCH AC                   if        oddeven <> 0
NCH AC                   eval      slside = 1
NCH AC                   else
NCH AC                   eval      slside = 0
NCH AC                   endif
NCH A
NCH A*    See if slot meets criteria for allowing it to be created.
NCH A
NCH AC                   select
NCH A
NCH A*    If non-special slot doesn't have hypens, then don't add it.
NCH A
NCH AC                   when      dashpos = 0
NCH AC                   eval      notcreated = *on
NCH AC                   goto      endcreate20
NCH A
NCH A*    Don't allow creation if department is unknown.
NCH A
NCH AC                   when      validdept = '*NO '
NCH AC                   eval      notcreated = *on
NCH AC                   goto      endcreate20
NCH A
NCH A*    If location or level is not numeric, then don't add.
NCH A
NCH AC                   when      locnotnum or lvlnotnum
NCH AC                   eval      notcreated = *on
NCH AC                   goto      endcreate20
NCH A
NCH A*    Otherwise, slot is ok to be created.
NCH A
NCH AC                   other
NCH AC                   eval      slwhdp = siwhdp
NCH AC                   eval      sldisp = sidisp
NCH AC                   eval      slstyp = sistyp
NCH A
NCH AC                   endsl
NCH A
NCH A*    Try and create the imported slot.
NCH A
NCH AC                   eval      slwhse = siwhse
NCH AC                   eval      slpseq = sipseq
NCH AC*
NCH AC                   select
NCH AC                   when      slpseq = 0
NCH AC                   eval      slpseq = slloc
NCH AC                   when      slpseq < 0
NCH AC                   eval      slpseq = slpseq * -1
NCH AC                   endsl
NCH AC                   if        slitem > ' '
NCH AC                   eval      slstat = 'A'
NCH AC                   else
NCH AC                   eval      slstat = 'V'
NCH AC                   endif
NCH A*
NCH AC                   eval      slrsrv = sirsrv
NCH AC                   eval      slsdef = 'XX'
NCH AC                   eval      slpick = sipick
NCH A
NCH AC                   write (e) slrec
NCH AC                   if        %error
NCH AC                   eval      notcreated = *on
NCH AC                   endif
NCH A
NCH AC     endcreate20   endsr
GFCaA*----------------------------------------------------------------
GFCaA*  crtslot21  Try and create physical slot.
GFCaA*----------------------------------------------------------------
GFCaA
GFCaAC     crtslot21     begsr
GFCaAC                   eval      notcreated = *off
GFCaA*  Turn on SlotCreated flag even if slot isn't created
GFCaA*  so ZZUPD routine doesn't get executed.
GFCaAC                   eval      slotcreated= *on
GFCaAC                   eval      handstack  = *off
GFCaAC                   eval      wkchar = ' '
GFCaAC                   clear                   slrec
GFCaA
GFCaA*  Extract location and level. Test if they are numeric.
GFCaA
GFCaAC                   eval      locnotnum = *off
GFCaAC                   eval      lvlnotnum = *off
GFCaAC                   eval      dashpos = 0
GFCaAC                   eval      loca  = ' '
GFCaAC                   eval      lvla  = ' '
GFCaA
GFCaA*  Check for all alpha slot. If no digits, default slot location
GFCaA*  will be assigned.
GFCaAC                   If            %subst(sidisp:4:2) >= '00'
GFCaAC                             and %subst(sidisp:4:2) <= '99'
GFCaAC                             and %subst(sidisp:7:2) >= '00'
GFCaAC                             and %subst(sidisp:7:2) <= '99'
GFCfA*
GFCfAC                             or  %subst(sidisp:3:2) >= '00'
GFCfAC                             and %subst(sidisp:3:2) <= '99'
GFCfAC                             and %subst(sidisp:5:2) >= '00'
GFCfAC                             and %subst(sidisp:5:2) <= '99'
GFCaAC                   eval      allchrslot = *off
GFCaAC                   else
GFCaAC                   eval      allchrslot = *on
GFCaAC                   endif
GFCaA
GFCaAC                   select
GFCaA
GFCaA*  Dashes specified. Single character aisle
GFCaAC                   when      %subst(sidisp:2:1) = '-'
GFCeDC*                            and %subst(sidisp:6:1) = '-'
GFCeMC                             and %subst(sidisp:5:1) = '-'
GFCaAC                   eval      dashpos = 2
GFCaAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
GFCeDC*                  eval      loca  = %subst(sidisp:3:3)
GFCeMC                   eval      loca  = '0' + %subst(sidisp:3:2)
GFCaAC                   move      loca          slloc
GFCeDC*                  eval      wkchar = %subst(sidisp:3:2)
GFCeDC*                  eval      lvla  = %subst(sidisp:7:1)
GFCeMC                   eval      lvla  = %subst(sidisp:6:1)
GFCaAC                   move      lvla          slrlvl
GFCeDC*                  eval      slhand  = ' ' + %subst(sidisp:8:1)
GFCeMC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
GFCaAC                   if        slhand > ' '
GFCaAC**                 eval      handstack = *on
GFCaAC                   endif
GFCaA
GFCaA*  Dashes specified. Double character aisle
GFCaAC                   when      %subst(sidisp:3:1) = '-'
GFCaAC                             and %subst(sidisp:6:1) = '-'
GFCaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
GFCeDC*                  evalr     loca  = %trimr(%subst(sidisp:4:2))
GFCeDC*                                    + %subst(sidisp:8:1)
GFCeMC                   evalr     loca  = '0' + %trimr(%subst(sidisp:4:2))
GFCaAC                   move      loca          slloc
GFCeDC*                  eval      wkchar = %subst(sidisp:4:2)
GFCaAC                   eval      lvla  = %subst(sidisp:7:1)
GFCaAC                   move      lvla          slrlvl
GFCeDC*                  eval      slhand  = ' ' + %subst(sidisp:9:1)
GFCeMC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
GFCaAC                   if        slhand > ' '
GFCaAC**                 eval      handstack = *on
GFCaAC                   endif
GFCaAC                   eval      dashpos = 3
GFCaA
GFCaA*  No dashes specified. All character slot.
GFCaAC                   when      allchrslot = *on
GFCaAC
GFCaAC                   eval      kydisp = sidisp
GFCaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
GFCaAC
GFCaAC                   eval      dftlocation = dftlocation + 1
GFCaAC                   eval      loca   = %char(dftlocation)
GFCaAC                   eval      slloc  = dftlocation
GFCaAC
GFCaAC                   eval      slrlvl = 1
GFCaAC                   eval      lvla   = '1'
GFCaAC
GFCaAC                   eval      slhand  = '  '
GFCaAC                   eval      dashpos = -1
GFCaA
GFCaA*  No dashes specified. Double character aisle, numeric rack level.
GFCaAC                   when           %subst(sidisp:2:1) >= 'A'
GFCaAC                             and  %subst(sidisp:2:1) <= 'Z'
GFCfDC*                            and (%subst(sidisp:6:1) >= '0'
GFCfMC                             and (%subst(sidisp:3:2) >= '00'
GFCfDC*                            and  %subst(sidisp:6:1) <= '9')
GFCfMC                             and  %subst(sidisp:3:2) <= '99')
GFCfAC                             and (%subst(sidisp:5:2) >= '00'
GFCfAC                             and  %subst(sidisp:5:2) <= '99')
GFCaAC
GFCaAC                   eval      kydisp = %subst(sidisp:1:6)
GFCaAC                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
GFCaA
GFCeDC*                  evalr     loca    = %trimr(%subst(sidisp:3:3))
GFCfDC*                  evalr     loca    = '0' + %trimr(%subst(sidisp:2:2))
GFCfMC                   evalr     loca    = '0' + %trimr(%subst(sidisp:3:2))
GFCaAC                   move (p)  loca          slloc
GFCeDC*                  eval      wkchar = %subst(sidisp:3:2)
GFCaA
GFCeDC*                  eval      lvla    = %subst(sidisp:6:1)
GFCeMC                   eval      lvla    = %subst(sidisp:5:1)
GFCaAC                   move (p)  lvla          slrlvl
GFCaAC*                  eval      slrlvl  = slrlvl + 1
GFCaA
GFCaA*   Special reserved slot. Don't break out handstack characters.
GFCaAC                   if        %subst(sidisp:6:3) = 'OVR'
GFCaAC                   eval      slhand  = '  '
GFCaAC                   else
GFCeDC*                  evalr     slhand  = %trimr(%subst(sidisp:7:1))
GFCeMC                   evalr     slhand  = ' ' + %trimr(%subst(sidisp:6:1))
GFCaAC                   endif
GFCaAC                   if        slhand > ' '
GFCaAC**                 eval      handstack = *on
GFCaAC                   endif
GFCaAC                   eval      dashpos = -1
GFCaA
GFCaA*  No dashes specified. Extract out slot breakdown.
GFCaAC                   other
GFCaAC
GFCaAC                   eval      kydisp = %subst(sidisp:1:6)
GFCaAC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
GFCaA
GFCeDC*                  evalr     loca    = %trimr(%subst(sidisp:3:3))
GFCeMC                   evalr     loca    = %trimr(%subst(sidisp:3:2))
GFCaAC                   move      loca          slloc
GFCaA
GFCeDC*                  eval      lvla    = %subst(sidisp:6:1)
GFCeMC                   eval      lvla    = %subst(sidisp:5:1)
GFCaAC                   move      lvla          slrlvl
GFCaAC**                 eval      slrlvl  = slrlvl + 1
GFCaA
GFCaA*   Special reserved slot. Don't break out handstack characters.
GFCaAC                   if        %subst(sidisp:6:3) = 'OVR'
GFCaAC                   eval      slhand  = '  '
GFCaAC                   else
GFCeDC*                  evalr     slhand  = %trimr(%subst(sidisp:7:1))
GFCeMC                   evalr     slhand  = ' ' + %trimr(%subst(sidisp:6:1))
GFCaAC                   endif
GFCaAC                   if        slhand > ' '
GFCaAC**                 eval      handstack = *on
GFCaAC                   endif
GFCaAC                   eval      dashpos = -1
GFCaA
GFCaAC                   endsl
GFCaA
GFCaA
GFCaA*  Begin testing parts for ALL slots.
GFCaAC                   testn                   loca                 5050
GFCaAC                   if        *in50 = *off
GFCaAC                   eval      locnotnum = *on
GFCaA
GFCaAC                   else
GFCaA
GFCaAC                   if        %subst(sidisp:6:3) = 'OVR'
GFCaAC**                 eval      slloc = slloc + 200
GFCaAC                   else
GFCaAC**                 eval      slloc = slloc + 100
GFCaAC                   endif
GFCaA
GFCaAC                   endif
GFCaA
GFCaAC                   testn                   lvla                 50
GFCaAC                   if        *in50 = *off
GFCaAC                   eval      lvlnotnum = *on
GFCaAC                   else
GFCaA*    Need to unconditionlly add 1 to Rack Level because
GFCaA*    Glazier has slots with zero rack level.
GFCcDC*                  eval      slrlvl = slrlvl + 1
GFCaAC                   select
GFCaAC                   when      slrlvl = 0
GFCaAC                   eval      slrlvl = slrlvl + 1
GFCaAC                   when      slrlvl < 0
GFCaAC                   eval      slrlvl = slrlvl * -1
GFCaAC                   endsl
GFCaAC                   endif
GFCaA
GFCaA*    Convert numeric handstack to alpha character.
GFCaA
GFCaAC                   if            slhand >= ' 0'
GFCaAC                             and slhand <= '99'
GFCaAC                   eval      wkchar = slhand
GFCaAC                   exsr      zzcvt2ltr
GFCaAC                   eval      slhand = nwchar
GFCaAC                   endif
GFCaA
GFCaAC                   if        wkchar > ' '
GFCaAC                   move      wkchar        wkloc             3 0
GFCaAC     wkloc         div       2             dummy
GFCaAC                   mvr                     oddeven
GFCaAC                   else
GFCaAC     slloc         div       2             dummy
GFCaAC                   mvr                     oddeven
GFCaAC                   endif
GFCaAC                   if        oddeven <> 0
GFCaAC                   eval      slside = 1
GFCaAC                   else
GFCaAC                   eval      slside = 0
GFCaAC                   endif
GFCaA*
GFCaA*    Check if base slot exists for imported slot with handstacks.
GFCaA*
GFCaAC                   eval      crtbaseslot = *off
GFCaAC                   if        handstack = *on
GFCaAC     keysl2b       setll     slot2
GFCaAC                   if        not %equal(slot2)
GFCaAC                   eval      crtbaseslot = *on
GFCaAC                   endif
GFCaAC                   endif
GFCaA
GFCaA*    See if slot meets criteria for allowing it to be created.
GFCaA
GFCaAC                   select
GFCaA
GFCaA*    If non-special slot doesn't have hypens, then don't add it.
GFCaA
GFCaAC                   when      dashpos = 0
GFCaAC                   eval      notcreated = *on
GFCaAC                   goto      endcreate21
GFCaA
GFCaA*    Don't allow creation if department is unknown.
GFCaA
GFCaAC                   when      validdept = '*NO '
GFCaAC                   eval      notcreated = *on
GFCaAC                   goto      endcreate21
GFCaA
GFCaA*    If location or level is not numeric, then don't add.
GFCaA
GFCaAC                   when      locnotnum or lvlnotnum
GFCaAC                   eval      notcreated = *on
GFCaAC                   goto      endcreate21
GFCaA
GFCaA*    Otherwise, slot is ok to be created.
GFCaA
GFCaAC                   other
GFCaAC                   eval      slwhdp = siwhdp
GFCaAC                   eval      sldisp = sidisp
GFCaAC                   eval      slstyp = sistyp
GFCaA
GFCaAC                   endsl
GFCaA
GFCaA*    Try and create the Base slot.
GFCaA
GFCaAC                   if        crtbaseslot = *on
GFCaA*    Save handstack for virtual slot.
GFCaAC                   eval      svhand = slhand
GFCaA
GFCaAC                   eval      slwhse = siwhse
GFCaAC                   eval      sldisp = kydisp
GFCaAC                   eval      slpseq = sipseq
GFCaAC                   select
GFCaAC                   when      slpseq = 0
GFCaAC                   eval      slpseq = slloc
GFCaAC                   when      slpseq < 0
GFCaAC                   eval      slpseq = slpseq * -1
GFCaAC                   endsl
GFCaAC                   eval      slstat = 'V '
GFCaAC                   eval      slhand = '  '
GFCaAC                   eval      slrsrv = sirsrv
GFCaAC                   eval      slsdef = 'XX'
GFCaAC                   eval      slpick = sipick
GFCaA
GFCaAC                   write (e) slrec
GFCaAC                   if        %error
GFCaAC                   eval      notcreated = *on
GFCaAC                   endif
GFCaA*
GFCaAC                   endif
GFCaA
GFCaA*    Try and create the imported slot.
GFCaA
GFCaAC                   eval      slwhse = siwhse
GFCaA*
GFCaA*    Replace base slot display, handstack w/ imported fields.
GFCaAC                   if        crtbaseslot = *on
GFCaAC                   eval      slhand = svhand
GFCaAC                   eval      sldisp = sidisp
GFCaAC                   endif
GFCaA*
GFCfAC                   select
GFCfA*      Dashes specified. Double character aisle.
GFCfDC*                  if            %subst(sidisp:3:1) = '-'
GFCfMC                   when          %subst(sidisp:3:1) = '-'
GFCaAC                             and %subst(sidisp:4:2) >= '00'
GFCaAC                             and %subst(sidisp:4:2) <= '99'
GFCaAC                             and %subst(sidisp:6:1) = '-'
GFCaAC                             and %subst(sidisp:7:2) >= '00'
GFCaAC                             and %subst(sidisp:7:2) <= '99'
GFCaAC                   eval      work4a =   %subst(sidisp:4:2)
GFCaAC                                      + %subst(sidisp:7:2)
GFCaAC                   eval      slpseq = %dec(work4a:4:0)
GFCfA*
GFCfA*      No dashes specified. Double character aisle.
GFCfAC                   when          %subst(sidisp:3:2) >= '00'
GFCfAC                             and %subst(sidisp:3:2) <= '99'
GFCfAC                             and %subst(sidisp:5:2) >= '00'
GFCfAC                             and %subst(sidisp:5:2) <= '99'
GFCfAC                   eval      work4a =   %subst(sidisp:3:2)
GFCfAC                                      + %subst(sidisp:5:2)
GFCfAC                   eval      slpseq = %dec(work4a:4:0)
GFCfA*
GFCfDC*                  else
GFCfMC                   other
GFCaAC                   eval      slpseq = sipseq
GFCfDC*                  endif
GFCfMC                   endsl
GFCaAC*
GFCaAC                   select
GFCaAC                   when      slpseq = 0
GFCaAC                   eval      slpseq = slloc
GFCaAC                   when      slpseq < 0
GFCaAC                   eval      slpseq = slpseq * -1
GFCaAC                   endsl
GFCaAC                   if        slitem > ' '
GFCaAC                   eval      slstat = 'A'
500iAC                   else
500iAC                   eval      slstat = 'V'
500iAC                   endif
GFCfAC                   eval      slsdte = impdte
GFCfAC                   eval      slstim = imptim
GFCaA*
GFCaA*    Slot has handstack, create as virtual slot.
GFCaAC                   if        handstack = *on
GFCaAC                   eval      slrsrv = 'V'
GFCaAC                   else
GFCaAC                   eval      slrsrv = sirsrv
GFCaAC                   endif
GFCaAC                   if        sidgtp > ' '
GFCaAC                   eval      slsdef = sidgtp
GFCaAC                   else
GFCaAC                   eval      slsdef = 'XX'
GFCaAC                   endif
GFCaAC                   eval      slpick = sipick
GFCaA
GFCaAC                   write (e) slrec
GFCaAC                   if        %error
GFCaAC                   eval      notcreated = *on
GFCaAC                   endif
GFCaA
GFCaA*    Create Virtual slot record.
GFCaA
GFCaAC                   if        handstack = *on
GFCaAC                   eval      vswhse = slwhse
GFCaAC                   eval      vswhdp = slwhdp
GFCaAC                   eval      vsaisl = slaisl
GFCaAC                   eval      vsloc  = slloc
GFCaAC                   eval      vsrlvl = slrlvl
GFCaAC                   eval      vshand = slhand
GFCaAC                   eval      vsdisp = sldisp
GFCaAC                   eval      vspdis = kydisp
GFCaAC                   eval      vscdte = impdte
GFCaAC                   eval      vsctim = imptim
GFCaAC                   add       1             vsctim
GFCaAC                   write (e) vsrec
GFCaAC                   if        %error
GFCaAC                   eval      error  = *on
GFCaAC                   eval      detmsg = desc(8)
GFCaAC                   add       1             notcrt
GFCaAC                   goto      endcreate21
GFCaAC                   endif
GFCaA
GFCaAC                   endif
GFCaA
GFCaA
GFCaAC     endcreate21   endsr

JTD A*----------------------------------------------------------------
JTD A*  crtslot22  Try and create physical slot.
JTD A*----------------------------------------------------------------
JTD A
JTD AC     crtslot22     begsr
JTD AC                   eval      notcreated = *off
JTD AC                   eval      handstack  = *off
JTD AC                   clear                   slrec
JTD A
JTD A*  Extract location and level. Test if they are numeric.
JTD A
JTD AC                   eval      locnotnum = *off
JTD AC                   eval      lvlnotnum = *off
JTD AC                   eval      dashpos = 0
JTD AC                   eval      loca  = ' '
JTD AC                   eval      lvla  = ' '
AVL A
AVL A*  Check for all alpha slot. If no digits, default slot location
AVL A*  will be assigned.
AVL AC                   If            %subst(sidisp:3:2) >= '00'
AVL AC                             and %subst(sidisp:3:2) <= '99'
AVL AC                             and %subst(sidisp:5:2) >= '00'
AVL AC                             and %subst(sidisp:5:2) <= '99'
AVL AC                             and %subst(sidisp:7:1)  = ' '
AVL A*
AVL AC                             or  %subst(sidisp:4:2) >= '00'
AVL AC                             and %subst(sidisp:4:2) <= '99'
AVL AC                             and %subst(sidisp:6:2) >= '00'
AVL AC                             and %subst(sidisp:6:2) <= '99'
AVL AC                             and %subst(sidisp:8:5) >= '0'
AVL AC                             and %subst(sidisp:8:5) <= '9'
AVL AC                             and %subst(sidisp:9:1)  = ' '
AVL AC                   eval      allchrslot = *off
AVL AC                   else
AVL AC                   eval      allchrslot = *on
AVL AC                   endif
JTD A
JTD AC                   select
JTD A
JTD A*  No dashes specified. Double character aisle, numeric rack level.
JTD AC                   when          (%subst(sidisp:2:1) >= 'A'
JTD AC                             and  %subst(sidisp:2:1) <= 'Z')
JTD AC                             and (%subst(sidisp:5:1) >= '0'
JTD AC                             and  %subst(sidisp:5:1) <= '9')
JTD MC                             and  %subst(sidisp:7:1)  = ' '
AVL AC                             and  allchrslot          = '0'
JTD AC
JTD AC                   eval      kydisp = %subst(sidisp:1:12)
JTD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
JTD A
JTD MC                   evalr     loca   = '0' + %trimr(%subst(sidisp:3:2))
JTD AC                   move (p)  loca          slloc
JTD AC                   if        slloc <= 0
JTD DC*                  eval      slloc = slloc + 100
JTD AC                   endif
JTD A
JTD MC                   eval      lvla    = %subst(sidisp:5:1)
JTD AC                   move (p)  lvla          slrlvl
JTD AC                   eval      slrlvl = slrlvl + 1
AVL A
AVL AC                   evalr     slhand  = %trimr(%subst(sidisp:6:1))
JTD A
JTD AC                   eval      dashpos = -1
JTD A
JTD A*  No dashes specified. Triple character aisle, numeric rack level.
JTD MC                   when          (%subst(sidisp:3:1) >= 'A'
JTD MC                             and  %subst(sidisp:3:1) <= 'Z')
JTD AC                             and (%subst(sidisp:6:1) >= '0'
JTD MC                             and  %subst(sidisp:6:1) <= '9')
JTD MC                             and  %subst(sidisp:8:1)  = ' '
AVL AC                             and  allchrslot          = '0'
JTD AC
JTD AC                   eval      kydisp = %subst(sidisp:1:12)
JTD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
JTD A
JTD AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:4:2))
JTD AC                   move (p)  loca          slloc
JTD AC                   if        slloc <= 0
JTD DC*                  eval      slloc  = slloc + 100
JTD AC                   endif
JTD A
JTD MC                   eval      lvla   = %subst(sidisp:6:1)
JTD AC                   move (p)  lvla          slrlvl
JTD AC                   eval      slrlvl = slrlvl + 1
AVL A
AVL AC                   evalr     slhand = %trimr(%subst(sidisp:7:1))
JTD A
JTD AC                   eval      dashpos = -1
JTD A
JTD A*  No dashes specified. Triple character aisle, numeric rack level.
JTD MC                   when          (%subst(sidisp:3:1) >= 'A'
JTD MC                             and  %subst(sidisp:3:1) <= 'Z')
JTD AC                             and (%subst(sidisp:7:1) >= '0'
JTD MC                             and  %subst(sidisp:7:1) <= '9')
JTD MC                             and  %subst(sidisp:9:1)  = ' '
AVL AC                             and  allchrslot          = '0'
JTD AC
JTD AC                   eval      kydisp = %subst(sidisp:1:12)
JTD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
JTD A
JTD AC                   eval      loca   = %subst(sidisp:4:3)
JTD AC                   move (p)  loca          slloc
JTD AC                   if        slloc <= 0
JTD DC*                  eval      slloc = slloc + 100
JTD AC                   endif
JTD A
JTD MC                   eval      lvla    = %subst(sidisp:7:1)
JTD AC                   move (p)  lvla          slrlvl
JTD AC                   eval      slrlvl = slrlvl + 1
AVL A
AVL AC                   evalr     slhand  = %trimr(%subst(sidisp:8:1))
JTD A
JTD AC                   eval      dashpos = -1
JTD A
AVL A*  No dashes specified. All character slot.
AVL AC                   when      allchrslot = *on
AVL AC
AVL AC                   eval      kydisp = sidisp
AVL AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
AVL AC*
AVL AC                   eval      dftlocation = dftlocation + 1
AVL AC                   eval      loca   = %char(dftlocation)
AVL AC                   eval      slloc  = dftlocation
AVL AC*
AVL AC                   eval      slrlvl = 1
AVL AC                   eval      lvla   = '1'
AVL AC*
AVL AC                   eval      slhand  = '  '
AVL AC                   eval      dashpos = -1
AVL A
JTD A*  No dashes specified. Extract out slot breakdown.
JTD AC                   other
JTD AC
JTD AC                   eval      kydisp = %subst(sidisp:1:12)
JTD AC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
JTD A
JTD AC                   evalr     loca    = %trimr(%subst(sidisp:4:3))
JTD AC                   move      loca          slloc
JTD AC                   if        slrlvl <= 0
JTD AC                             or client = JTD
JTD AC                   eval      slrlvl  = slrlvl + 1
JTD AC                   endif
JTD A
JTD AC                   eval      lvla    = %subst(sidisp:7:1)
JTD AC                   move      lvla          slrlvl
JTD AC                   eval      slrlvl  = slrlvl + 1
JTD A
JTD A*   Special reserved slot. Don't break out handstack characters.
JTD AC                   if        %subst(sidisp:7:3) = 'OVR'
JTD AC                   eval      slhand  = '  '
JTD AC                   else
JTD AC                   evalr     slhand  = %trimr(%subst(sidisp:8:2))
JTD AC                   endif
JTD AC                   if        slhand > ' '
JTD AC                   eval      handstack = *on
JTD AC                   endif
JTD AC                   eval      dashpos = -1
JTD A
JTD AC                   endsl
JTD A
JTD A
JTD A*  Begin testing parts for ALL slots.
JTD AC                   testn                   loca                 5050
JTD AC                   if        *in50 = *off
JTD AC                   eval      locnotnum = *on
JTD A
JTD AC                   else
JTD A
JTD AC                   if        %subst(sidisp:8:3) = 'OVR'
JTD AC                   eval      slloc = slloc + 200
JTD AC                   endif
JTD A
JTD AC                   endif
JTD A
JTD AC                   testn                   lvla                 50
JTD AC                   if        *in50 = *off
JTD AC                   eval      lvlnotnum = *on
JTD AC                   else
JTD AC                   select
JTD AC                   when      slrlvl = 0
JTD AC                   eval      slrlvl = slrlvl + 1
JTD AC                   when      slrlvl < 0
JTD AC                   eval      slrlvl = slrlvl * -1
JTD AC                   endsl
JTD AC                   endif
JTD A
JTD A*    Convert numeric handstack to alpha character.
JTD A
JTD AC                   if            slhand >= ' 0'
JTD AC                             and slhand <= '99'
AVL DC*                  eval      wkchar = slhand
AVL DC*                  exsr      zzcvt2ltr
AVL DC*                  eval      slhand = nwchar
JTD AC                   endif
JTD A
JTD AC     slloc         div       2             dummy
JTD AC                   mvr                     oddeven
JTD AC                   if        oddeven <> 0
JTD AC                   eval      slside = 1
JTD AC                   else
JTD AC                   eval      slside = 0
JTD AC                   endif
JTD A*
JTD A*    Check if base slot exists for imported slot with handstacks.
JTD A*
JTD AC                   eval      crtbaseslot = *off
JTD AC                   if        handstack = *on
JTD AC     keysl2b       setll     slot2
JTD AC                   if        not %equal(slot2)
JTD AC                   eval      crtbaseslot = *on
JTD AC                   endif
JTD AC                   endif
JTD A
JTD A*    See if slot meets criteria for allowing it to be created.
JTD A
JTD AC                   select
JTD A
JTD A*    If non-special slot doesn't have hypens, then don't add it.
JTD A
JTD AC                   when      dashpos = 0
JTD AC                   eval      notcreated = *on
JTD AC                   goto      endcreate22
JTD A
JTD A*    Don't allow creation if department is unknown.
JTD A
JTD AC                   when      validdept = '*NO '
JTD AC                   eval      notcreated = *on
JTD AC                   goto      endcreate22
JTD A
JTD A*    If location or level is not numeric, then don't add.
JTD A
JTD AC                   when      locnotnum or lvlnotnum
JTD AC                   eval      notcreated = *on
JTD AC                   goto      endcreate22
JTD A
JTD A*    Otherwise, slot is ok to be created.
JTD A
JTD AC                   other
JTD AC                   eval      slwhdp = siwhdp
JTD AC                   eval      sldisp = sidisp
JTD AC                   eval      slstyp = sistyp
JTD A
JTD AC                   endsl
JTD A
JTD A*    Try and create the Base slot.
JTD A
JTD AC                   if        crtbaseslot = *on
JTD A*    Save handstack for virtual slot.
JTD AC                   eval      svhand = slhand
JTD A
JTD AC                   eval      slwhse = siwhse
JTD AC                   eval      sldisp = kydisp
JTD AC                   eval      slpseq = sipseq
JTD AC                   select
JTD AC                   when      slpseq = 0
JTD AC                   eval      slpseq = slloc
JTD AC                   when      slpseq < 0
JTD AC                   eval      slpseq = slpseq * -1
JTD AC                   endsl
JTD AC                   eval      slstat = 'V '
JTD AC                   eval      slhand = '  '
JTD AC                   eval      slrsrv = sirsrv
JTD AC                   eval      slsdef = 'XX'
JTD AC                   eval      slpick = sipick
JTD A
JTD AC                   write (e) slrec
JTD AC                   if        %error
JTD AC                   eval      notcreated = *on
JTD AC                   endif
JTD A*
JTD AC                   endif
JTD A
JTD A*    Try and create the imported slot.
JTD A
JTD AC                   eval      slwhse = siwhse
JTD A*
JTD A*    Replace base slot display, handstack w/ imported fields.
JTD AC                   if        crtbaseslot = *on
JTD AC                   eval      slhand = svhand
JTD AC                   eval      sldisp = sidisp
JTD AC                   endif
JTD A*
JTD AC                   eval      slpseq = sipseq
JTD AC                   select
JTD AC                   when      slpseq = 0
JTD AC                   eval      slpseq = slloc
JTD AC                   when      slpseq < 0
JTD AC                   eval      slpseq = slpseq * -1
JTD AC                   endsl
JTD AC                   eval      slstat = 'V'
JTD A*
JTD A*    Slot has handstack, create as virtual slot.
JTD AC                   if        handstack = *on
JTD AC                   eval      slrsrv = 'V'
JTD AC                   else
JTD AC                   eval      slrsrv = sirsrv
JTD AC                   endif
JTD AC                   eval      slsdef = 'XX'
JTD AC                   eval      slpick = sipick
JTD A
JTD AC                   write (e) slrec
JTD AC                   if        %error
JTD AC                   eval      notcreated = *on
JTD AC                   endif
JTD A
JTD A*    Create Virtual slot record.
JTD A
JTD AC                   if        handstack = *on
JTD AC                   eval      vswhse = slwhse
JTD AC                   eval      vswhdp = slwhdp
JTD AC                   eval      vsaisl = slaisl
JTD AC                   eval      vsloc  = slloc
JTD AC                   eval      vsrlvl = slrlvl
JTD AC                   eval      vshand = slhand
JTD AC                   eval      vsdisp = sldisp
JTD AC                   eval      vspdis = kydisp
JTD AC                   eval      vscdte = impdte
JTD AC                   eval      vsctim = imptim
JTD AC                   add       1             vsctim
JTD AC                   write (e) vsrec
JTD AC                   if        %error
JTD AC                   eval      error  = *on
JTD AC                   eval      detmsg = desc(8)
JTD AC                   add       1             notcrt
JTD AC                   goto      endcreate22
JTD AC                   endif
JTD A
JTD AC                   endif
JTD A
JTD A
JTD AC     endcreate22   endsr

ASC A*----------------------------------------------------------------
ASC A*  crtslot23  Try and create physical slot.
ASC A*----------------------------------------------------------------
ASC A
ASC AC     crtslot23     begsr
ASC AC                   eval      notcreated = *off
ASC AC                   eval      handstack  = *off
ASC AC                   clear                   slrec
ASC A
ASC A*  Extract location and level. Test if they are numeric.
ASC A
ASC AC                   eval      locnotnum = *off
ASC AC                   eval      lvlnotnum = *off
ASC AC                   eval      dashpos = 0
ASC AC                   eval      loca  = ' '
ASC AC                   eval      lvla  = ' '
ASC AC                   eval      lvlaa = ' '
ASC A
ASC A*  Check for all alpha slot. If no digits, default slot location
ASC A*  will be assigned.
ASC AC                   If            %subst(sidisp:4:2) >= '00'
ASC AC                             and %subst(sidisp:4:2) <= '99'
ASC AC                             and %subst(sidisp:7:2) >= '00'
ASC AC                             and %subst(sidisp:7:2) <= '99'
ASC AC                             and %subst(sidisp:9:1)  = ' '
ASC A*
ASC AC                   eval      allchrslot = *off
ASC AC                   else
ASC AC                   eval      allchrslot = *on
ASC AC                   endif
ASC A
ASC AC                   select
ASC A
ASC A*  Dashes specified. Double character aisle, numeric rack level.
ASC AC                   when           %subst(sidisp:4:2) >= '00'
ASC AC                             and  %subst(sidisp:4:2) <= '99'
ASC AC                             and  %subst(sidisp:7:2) >= '00'
ASC AC                             and  %subst(sidisp:7:2) <= '99'
ASC AC                             and  %subst(sidisp:3:1)  = '-'
ASC AC                             and  %subst(sidisp:6:1)  = '-'
ASC AC                             and  allchrslot          = '0'
ASC AC
ASC AC                   eval      kydisp = %subst(sidisp:1:12)
ASC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ASC A
ASC AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:4:2))
ASC AC                   move (p)  loca          slloc
ASC A
ASC AC                   eval      lvlaa   = %subst(sidisp:7:2)
ASC AC                   move (p)  lvlaa         slrlvl
ASC A
ASC AC                   evalr     slhand  = %trimr(%subst(sidisp:9:1))
ASC A
ASC AC                   eval      dashpos = -1
ASC A
ASC A*  Dashes specified. Triple character aisle, numeric rack level.
ASC AC                   when           %subst(sidisp:5:2) >= '00'
ASC AC                             and  %subst(sidisp:5:2) <= '99'
ASC AC                             and  %subst(sidisp:8:2) >= '00'
ASC AC                             and  %subst(sidisp:8:2) <= '99'
ASC AC                             and  %subst(sidisp:4:1)  = '-'
ASC AC                             and  %subst(sidisp:7:1)  = '-'
ASC AC                             and  allchrslot          = '0'
ASC AC
ASC AC                   eval      kydisp = %subst(sidisp:1:12)
ASC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
ASC A
ASC AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:5:2))
ASC AC                   move (p)  loca          slloc
ASC A
ASC AC                   eval      lvlaa   = %subst(sidisp:8:2)
ASC AC                   move (p)  lvlaa         slrlvl
ASC A
ASC AC                   evalr     slhand  = %trimr(%subst(sidisp:10:1))
ASC A
ASC AC                   eval      dashpos = -1
ASC A
ASC A*  No dashes specified. All character slot.
ASC AC                   when      allchrslot = *on
ASC AC
ASC AC                   eval      kydisp = sidisp
ASC2A*
ASC2AC                   select
ASC2A*      3-character aisle with dash specified.
ASC2AC                   when      %subst(sidisp:4:1) = '-'
ASC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
ASC2A*
ASC2A*      2-character aisle with dash specified.
ASC2AC                   when      %subst(sidisp:3:1) = '-'
ASC2AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ASC2A*
ASC2A*      1-character aisle with dash specified.
ASC2AC                   when      %subst(sidisp:2:1) = '-'
ASC2AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
ASC2A*
ASC2AC                   other
ASC2AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ASC2A*
ASC2AC                   endsl
ASC AC*
ASC AC                   eval      dftlocation = dftlocation + 1
ASC AC                   eval      loca   = %char(dftlocation)
ASC AC                   eval      slloc  = dftlocation
ASC AC*
ASC AC                   eval      slrlvl = 1
ASC AC                   eval      lvla   = '1'
ASC2AC                   eval      lvlaa  = '01'
ASC AC*
ASC AC                   eval      slhand  = '  '
ASC AC                   eval      dashpos = -1
ASC A
ASC A*  No dashes specified. Extract out slot breakdown.
ASC AC                   other
ASC AC
ASC AC                   eval      kydisp = %subst(sidisp:1:12)
ASC AC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
ASC A
ASC AC                   evalr     loca    = '0' + %trimr(%subst(sidisp:3:2))
ASC AC                   move      loca          slloc
ASC A
ASC AC                   eval      lvlaa   = %subst(sidisp:5:2)
ASC AC                   move      lvlaa         slrlvl
ASC A
ASC AC                   evalr     slhand  = %trimr(%subst(sidisp:7:1))
ASC AC                   eval      dashpos = -1
ASC A
ASC AC                   endsl
ASC A
ASC A
ASC A*  Begin testing parts for ALL slots.
ASC AC                   testn                   loca                 5050
ASC AC                   if        *in50 = *off
ASC AC                   eval      locnotnum = *on
ASC A
ASC AC                   endif
ASC A
ASC AC                   testn                   lvlaa                50
ASC AC                   if        *in50 = *off
ASC AC                   eval      lvlnotnum = *on
ASC AC                   else
ASC AC                   select
ASC AC                   when      slrlvl = 0
ASC AC                   eval      slrlvl = slrlvl + 1
ASC AC                   when      slrlvl < 0
ASC AC                   eval      slrlvl = slrlvl * -1
ASC AC                   endsl
ASC AC                   endif
ASC A
ASC AC     slloc         div       2             dummy
ASC AC                   mvr                     oddeven
ASC AC                   if        oddeven <> 0
ASC AC                   eval      slside = 1
ASC AC                   else
ASC AC                   eval      slside = 0
ASC AC                   endif
ASC A
ASC A*    See if slot meets criteria for allowing it to be created.
ASC AC                   select
ASC A
ASC A*    If non-special slot doesn't have hypens, then don't add it.
ASC A
ASC AC                   when      dashpos = 0
ASC AC                   eval      notcreated = *on
ASC AC                   goto      endcreate23
ASC A
ASC A*    Don't allow creation if department is unknown.
ASC A
ASC AC                   when      validdept = '*NO '
ASC AC                   eval      notcreated = *on
ASC AC                   goto      endcreate23
ASC A
ASC A*    If location or level is not numeric, then don't add.
ASC A
ASC AC                   when      locnotnum or lvlnotnum
ASC AC                   eval      notcreated = *on
ASC AC                   goto      endcreate23
ASC A
ASC A*    Otherwise, slot is ok to be created.
ASC A
ASC AC                   other
ASC AC                   eval      slwhdp = siwhdp
ASC AC                   eval      sldisp = sidisp
ASC AC                   eval      slstyp = sistyp
ASC A
ASC AC                   endsl
ASC A
ASC A*    Try and create the imported slot.
ASC A
ASC AC                   eval      slwhse = siwhse
ASC A*
ASC AC                   eval      slpseq = sipseq
ASC AC                   select
ASC AC                   when      slpseq = 0
ASC AC                   eval      slpseq = slloc
ASC AC                   when      slpseq < 0
ASC AC                   eval      slpseq = slpseq * -1
ASC AC                   endsl
ASC AC                   eval      slstat = 'V'
ASC A*
ASC AC                   eval      slrsrv = sirsrv
ASC AC                   eval      slsdef = 'XX'
ASC AC                   eval      slpick = sipick
ASC A
ASC AC                   write (e) slrec
ASC AC                   if        %error
ASC AC                   eval      notcreated = *on
ASC AC                   endif
ASC A
ASC AC     endcreate23   endsr

GMM A*----------------------------------------------------------------
GMM A*  crtslot24  Try and create physical slot.
GMM A*----------------------------------------------------------------
GMM A
GMM AC     crtslot24     begsr
GMM AC                   eval      notcreated = *off
GMM AC                   eval      handstack  = *off
GMM AC                   clear                   slrec
GMM A
GMM A*  Extract location and level. Test if they are numeric.
GMM A
GMM AC                   eval      locnotnum = *off
GMM AC                   eval      lvlnotnum = *off
GMM AC                   eval      dashpos = 0
GMM AC                   eval      loca  = ' '
GMM AC                   eval      lvla  = ' '
GMM AC                   eval      lvlaa = ' '
GMM A
GMM A*  Check for all alpha slot. If no digits, default slot location
GMM A*  will be assigned.
GMM AC                   If            %subst(sidisp:2:2) >= '00'
GMM AC                             and %subst(sidisp:2:2) <= '99'
GMM A*
GMM AC                             or  %subst(sidisp:4:3) >= '000'
GMM AC                             and %subst(sidisp:4:3) <= '999'
GMM AC                             and %subst(sidisp:8:1) >= '0'
GMM AC                             and %subst(sidisp:8:1) <= '9'
GMM A*
GMM AC                   eval      allchrslot = *off
GMM AC                   else
GMM AC                   eval      allchrslot = *on
GMM AC                   endif
GMM A
GMM AC                   select
GMM A
GMM A*  Dash specified. Single character aisle, alpha rack level.
GMM AC                   when           %subst(sidisp:2:2) >= '00'
GMM AC                             and  %subst(sidisp:2:2) <= '99'
GMM AC                             and  %subst(sidisp:4:1)  = '-'
GMM AC                             and  %subst(sidisp:5:1) >= 'A'
GMM AC                             and  %subst(sidisp:5:1) <= 'Z'
GMM AC                             and  allchrslot          = '0'
GMM AC
GMM AC                   eval      kydisp = %subst(sidisp:1:12)
GMM AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
GMM A
GMM AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:2:2))
GMM AC                   move (p)  loca          slloc
GMM A*
GMM A*      Convert alpha level into numeric value.
GMM AC                   eval      lvla    = %subst(sidisp:5:1)
GMM AC                   evalr     wkchar = %trimr(lvla)
GMM AC                   exsr      zzcvt2nbr
GMM AC                   if        nwchar > ' '
GMM AC                   evalr     lvla   = %trimr(nwchar)
GMM AC                   eval      slrlvl = %dec(nwchar:2:0)
GMM AC                   else
GMM AC                   evalr     lvla  = '1'
GMM AC                   move      lvla          slrlvl
GMM AC                   endif
GMM A
GMM AC                   evalr     slhand  = %trimr(%subst(sidisp:6:1))
GMM A
GMM AC                   eval      dashpos = -1
GMM A
GMM A*  Dash specified. Single character aisle, numeric rack level.
GMM AC                   when           %subst(sidisp:2:2) >= '00'
GMM AC                             and  %subst(sidisp:2:2) <= '99'
GMM AC                             and  %subst(sidisp:4:1)  = '-'
GMM AC                             and  %subst(sidisp:5:1) >= '0'
GMM AC                             and  %subst(sidisp:5:1) <= '9'
GMM AC                             and  allchrslot          = '0'
GMM AC
GMM AC                   eval      kydisp = %subst(sidisp:1:12)
GMM AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
GMM A
GMM AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:2:2))
GMM AC                   move (p)  loca          slloc
GMM A*
GMM AC                   evalr     lvla  = %subst(sidisp:5:1)
GMM AC                   move      lvla          slrlvl
GMM AC                   eval      slrlvl = slrlvl + 2
GMM A
GMM AC                   evalr     slhand  = %trimr(%subst(sidisp:6:1))
GMM A
GMM AC                   eval      dashpos = -1
GMM A
GMM A*  No Dashes specified. Single character aisle, alpha rack level.
GMM AC                   when           %subst(sidisp:2:2) >= '00'
GMM AC                             and  %subst(sidisp:2:2) <= '99'
GMM AC                             and  %subst(sidisp:4:1) >= 'A'
GMM AC                             and  %subst(sidisp:4:1) <= 'Z'
GMM AC                             and  allchrslot          = '0'
GMM AC
GMM AC                   eval      kydisp = %subst(sidisp:1:12)
GMM AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
GMM A
GMM AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:2:2))
GMM AC                   move (p)  loca          slloc
GMM A*
GMM A*      Convert alpha level into numeric value.
GMM AC                   eval      lvla    = %subst(sidisp:4:1)
GMM AC                   evalr     wkchar = %trimr(lvla)
GMM AC                   exsr      zzcvt2nbr
GMM AC                   if        nwchar > ' '
GMM AC                   evalr     lvla   = %trimr(nwchar)
GMM AC                   eval      slrlvl = %dec(nwchar:2:0)
GMM AC                   else
GMM AC                   evalr     lvla  = '1'
GMM AC                   move      lvla          slrlvl
GMM AC                   endif
GMM A
GMM AC                   evalr     slhand  = %trimr(%subst(sidisp:5:1))
GMM A
GMM AC                   eval      dashpos = -1
GMM5A
GMM5A*  No Dashes specified. Single character aisle, numeric rack level.
GMM5AC                   when           %subst(sidisp:2:2) >= '00'
GMM5AC                             and  %subst(sidisp:2:2) <= '99'
GMM5AC                             and  %subst(sidisp:4:1) >= '0'
GMM5AC                             and  %subst(sidisp:4:1) <= '9'
GMM7AC                             and  %subst(sidisp:3:1) <> '-'
GMM7AC                             and  %subst(sidisp:7:1) <> '-'
GMM5AC                             and  allchrslot          = '0'
GMM5AC
GMM5AC                   eval      kydisp = %subst(sidisp:1:12)
GMM5AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
GMM5A
GMM5AC                   evalr     loca   = '0' + %trimr(%subst(sidisp:2:2))
GMM5AC                   move (p)  loca          slloc
GMM5A*
GMM5A*      Convert alpha level into numeric value.
GMM5AC                   eval      lvla    = %subst(sidisp:4:1)
GMM5AC                   move      lvla          slrlvl
GMM5A
GMM5AC                   evalr     slhand  = %trimr(%subst(sidisp:5:1))
GMM5A
GMM5AC                   eval      dashpos = -1
GMM A
GMM A*  Dashes specified. Double character aisle, numeric rack level.
GMM AC                   when           %subst(sidisp:4:3) >= '000'
GMM AC                             and  %subst(sidisp:4:3) <= '999'
GMM AC                             and  %subst(sidisp:3:1)  = '-'
GMM AC                             and  %subst(sidisp:7:1)  = '-'
GMM AC                             and  allchrslot          = '0'
GMM AC
GMM AC                   eval      kydisp = %subst(sidisp:1:12)
GMM AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
GMM A
GMM AC                   evalr     loca   = %trimr(%subst(sidisp:4:3))
GMM AC                   move (p)  loca          slloc
GMM A*
GMM AC                   eval      lvla    = %subst(sidisp:8:1)
GMM AC                   move      lvla          slrlvl
GMM A
GMM AC                   evalr     slhand  = %trimr(%subst(sidisp:9:1))
GMM A
GMM AC                   eval      dashpos = -1
GMM A
GMM A*  No dashes specified. All character slot.
GMM AC                   when      allchrslot = *on
GMM AC
GMM AC                   eval      kydisp = sidisp
GMM AC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
GMM AC*
GMM AC                   eval      dftlocation = dftlocation + 1
GMM AC                   eval      loca   = %char(dftlocation)
GMM AC                   eval      slloc  = dftlocation
GMM AC*
GMM AC                   eval      slrlvl = 1
GMM AC                   eval      lvla   = '1'
GMM AC*
GMM AC                   eval      slhand  = '  '
GMM AC                   eval      dashpos = -1
GMM A
GMM AC                   endsl
GMM A
GMM A
GMM A*  Begin testing parts for ALL slots.
GMM AC                   testn                   loca                 5050
GMM AC                   if        *in50 = *off
GMM AC                   eval      locnotnum = *on
GMM A
GMM AC                   endif
GMM A
GMM AC                   testn                   lvla                 50
GMM AC                   if        *in50 = *off
GMM AC                   eval      lvlnotnum = *on
GMM AC                   else
GMM AC                   select
GMM AC                   when      slrlvl = 0
GMM AC*                  eval      slrlvl = slrlvl + 1
GMM AC                   when      slrlvl < 0
GMM AC                   eval      slrlvl = slrlvl * -1
GMM AC                   endsl
GMM AC                   endif
GMM A
GMM AC     slloc         div       2             dummy
GMM AC                   mvr                     oddeven
GMM AC                   if        oddeven <> 0
GMM AC                   eval      slside = 1
GMM AC                   else
GMM AC                   eval      slside = 0
GMM AC                   endif
GMM A
GMM A*    See if slot meets criteria for allowing it to be created.
GMM AC                   select
GMM A
GMM A*    If non-special slot doesn't have hypens, then don't add it.
GMM A
GMM AC                   when      dashpos = 0
GMM AC                   eval      notcreated = *on
GMM AC                   goto      endcreate24
GMM A
GMM A*    Don't allow creation if department is unknown.
GMM A
GMM AC                   when      validdept = '*NO '
GMM AC                   eval      notcreated = *on
GMM AC                   goto      endcreate24
GMM A
GMM A*    If location or level is not numeric, then don't add.
GMM A
GMM AC                   when      locnotnum or lvlnotnum
GMM AC                   eval      notcreated = *on
GMM AC                   goto      endcreate24
GMM A
GMM A*    Otherwise, slot is ok to be created.
GMM A
GMM AC                   other
GMM AC                   eval      slwhdp = siwhdp
GMM AC                   eval      sldisp = sidisp
GMM AC                   eval      slstyp = sistyp
GMM A
GMM AC                   endsl
GMM A
GMM A*    Try and create the imported slot.
GMM A
GMM AC                   eval      slwhse = siwhse
GMM A*
GMM AC                   eval      slpseq = sipseq
GMM AC                   select
GMM AC                   when      slpseq = 0
GMM AC                   eval      slpseq = slloc
GMM AC                   when      slpseq < 0
GMM AC                   eval      slpseq = slpseq * -1
GMM AC                   endsl
GMM AC                   eval      slstat = 'V'
GMM A*
GMM AC                   eval      slrsrv = sirsrv
GMM6A*
GMM6A*      Load slot type if not fully numeric.
GMM6AC                   if        sidgtp < '00'
GMM6AC                             and sidgtp > ' '
GMM9AC                             and clientloc = 'MAIN'
GMM6AC                   eval      slsdef  = sidgtp
GMM6AC                   else
GMM6A*
GMM AC                   eval      slsdef = 'XX'
GMM6AC                   endif
GMM6A*
GMM8AC                   if        slloc = 199
GMM8AC                   eval      sldesg = 'SPCL '
GMM8AC                   endif
GMM8A*
GMM AC                   eval      slpick = sipick
GMM AC                   eval      slrsrv = sirsrv
GMM A
GMM AC                   write (e) slrec
GMM AC                   if        %error
GMM AC                   eval      notcreated = *on
GMM AC                   endif
GMM A
GMM AC     endcreate24   endsr

HMW A*----------------------------------------------------------------
HMW A*  crtslot25  Try and create physical slot.
HMW A*----------------------------------------------------------------
HMW A
HMW AC     crtslot25     begsr
HMW AC                   eval      notcreated = *off
HMW A
HMW A*  Turn on SlotCreated flag even if slot isn't created
HMW A*  so ZZUPD routine doesn't get executed.
HMW AC                   eval      slotcreated= *on
HMW AC                   eval      handstack  = *off
HMW AC                   clear                   slrec
HMW A
HMW A*  Extract location and level. Test if they are numeric.
HMW A
HMW AC                   eval      locnotnum = *off
HMW AC                   eval      lvlnotnum = *off
HMW AC                   eval      dashpos = 0
HMW AC                   eval      loca  = ' '
HMW AC                   eval      lvla  = ' '
HMW A
HMW A*  Check for all alpha slot. If no digits, default slot location
HMW A*  will be assigned.
HMW AC                   If            %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMWcA*  No dashes specified. 3 character aisle, rack level=4th position.
HMWcA*  Slot format: ZXCR11
HMWcAC                             or  (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or  %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and %subst(sidisp:4:1) >= 'A'
HMWcAC                             and %subst(sidisp:4:1) <= 'Z'
HMWcA*  No dashes specified. 3 character aisle, rack level=5th position.
HMWcA*  Slot format: ZXC1A1
HMWcAC                             or  (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or  %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and %subst(sidisp:4:1) >= '0'
HMWcAC                             and %subst(sidisp:4:1) <= '9'
HMWdA*  Dashes specified. 2 character aisle, rack level=8th position.
HMWdA*  Slot format: 10-105-1A
HMWdAC                             or  (%subst(sidisp:3:1) = '-'
HMWdAC                             and %subst(sidisp:4:3) >= '000'
HMWdAC                             and %subst(sidisp:4:3) <= '999'
HMWdAC                             and %subst(sidisp:7:1) = '-')
HMWdAC                             and %subst(sidisp:8:1) >= '0'
HMWdAC                             and %subst(sidisp:8:1) <= '9'
HMWdA*  Dashes specified. 3 character aisle, rack level=8th position.
HMWdA*  Slot format: 110-105-1A
HMWdAC                             or  (%subst(sidisp:4:1) = '-'
HMWdAC                             and %subst(sidisp:5:3) >= '000'
HMWdAC                             and %subst(sidisp:5:3) <= '999'
HMWdAC                             and %subst(sidisp:8:1) = '-')
HMWdAC                             and %subst(sidisp:9:1) >= '0'
HMWdAC                             and %subst(sidisp:9:1) <= '9'
HMW AC                   eval      allchrslot = *off
HMW AC                   else
HMW AC                   eval      allchrslot = *on
HMW AC                   endif
HMW A
HMW A
HMW AC                   select
HMW A
HMW A*  No dashes specified. All character slot.
HMW AC                   when      allchrslot = *on
HMW AC
HMW AC                   eval      kydisp = sidisp
HMW AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
HMW AC
HMW AC                   eval      dftlocation = dftlocation + 1
HMW AC                   eval      loca   = %char(dftlocation)
HMW AC                   eval      slloc  = dftlocation
HMW AC
HMW AC                   eval      slrlvl = 1
HMW AC                   eval      lvla   = '1'
HMW AC
HMW AC                   eval      slhand  = '  '
HMW AC                   eval      dashpos = -1
HMW A
HMW A*  No Dashes specified. Dbl char aisle, alpha rack lvl (Ex 2232D1).
HMW AC                   when          %subst(sidisp:2:1) > ' '
HMW AC                             and %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMW AC                             and %subst(sidisp:5:1) >= 'A'
HMW AC                             and %subst(sidisp:5:1) <= 'Z'
HMW AC                   eval      dashpos = -1
HMW AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMW AC                   eval      loca  = '0' + %subst(sidisp:3:2)
HMW AC                   move      loca          slloc
HMW A*
HMW A*      Convert alpha level into numeric value.
HMW AC                   eval      lvla    = %subst(sidisp:5:1)
HMW AC                   evalr     wkchar = %trimr(lvla)
HMW AC                   exsr      zzcvt2nbr
HMW AC                   if        nwchar > ' '
HMW AC                   evalr     lvla   = %trimr(nwchar)
HMW AC                   eval      slrlvl = %dec(nwchar:2:0)
HMW AC                   else
HMW AC                   evalr     lvla  = '1'
HMW AC                   move      lvla          slrlvl
HMW AC                   endif
HMW AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMW A
HMW A
HMW A*  No Dashes specified. Dbl char aisle, numeric rack lvl (Ex SC053A)
HMW AC                   when          %subst(sidisp:2:1) > ' '
HMW AC                             and %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMW AC                             and %subst(sidisp:5:1) >= '0'
HMW AC                             and %subst(sidisp:5:1) <= '9'
HMW AC                   eval      dashpos = -1
HMW AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMW AC                   eval      loca  = %subst(sidisp:3:3)
HMW AC                   move      loca          slloc
HMW A*
HMW AC                   evalr     lvla  = %subst(sidisp:6:1)
HMW AC                   move      lvla          slrlvl
HMW AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
HMWcA
HMWcA*  No Dashes specified. 3 char aisle, alpha rack lvl (Ex ZXC1A1).
HMWcAC                   when          %subst(sidisp:2:1) > ' '
HMWcAC                             and (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or   %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and  %subst(sidisp:4:1) >= '0'
HMWcAC                             and  %subst(sidisp:4:1) <= '9'
HMWcAC                   eval      dashpos = -1
HMWcAC                   eval      slaisl = %subst(sidisp:1:3)
HMWcAC                   eval      loca  = '00' + %subst(sidisp:4:1)
HMWcAC                   move      loca          slloc
HMWcA*
HMWcA*      Convert alpha level into numeric value.
HMWcAC                   eval      lvla    = %subst(sidisp:5:1)
HMWcAC                   evalr     wkchar = %trimr(lvla)
HMWcAC                   exsr      zzcvt2nbr
HMWcAC                   if        nwchar > ' '
HMWcAC                   evalr     lvla   = %trimr(nwchar)
HMWcAC                   eval      slrlvl = %dec(nwchar:2:0)
HMWcAC                   else
HMWcAC                   evalr     lvla  = '1'
HMWcAC                   move      lvla          slrlvl
HMWcAC                   endif
HMWcAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMWcA
HMWcA*  No Dashes specified. 3 char aisle, alpha rack lvl (Ex ZXCR11).
HMWcAC                   when          %subst(sidisp:2:1) > ' '
HMWcAC                             and (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or   %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and  %subst(sidisp:4:1) >= 'A'
HMWcAC                             and  %subst(sidisp:4:1) <= 'Z'
HMWcAC                   eval      dashpos = -1
HMWcAC                   eval      slaisl = %subst(sidisp:1:3)
HMWcAC                   eval      loca  = '00' + %subst(sidisp:5:1)
HMWcAC                   move      loca          slloc
HMWcA*
HMWcA*      Convert alpha level into numeric value.
HMWcAC                   eval      lvla    = %subst(sidisp:4:1)
HMWcAC                   evalr     wkchar = %trimr(lvla)
HMWcAC                   exsr      zzcvt2nbr
HMWcAC                   if        nwchar > ' '
HMWcAC                   evalr     lvla   = %trimr(nwchar)
HMWcAC                   eval      slrlvl = %dec(nwchar:2:0)
HMWcAC                   else
HMWcAC                   evalr     lvla  = '1'
HMWcAC                   move      lvla          slrlvl
HMWcAC                   endif
HMWcAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMWdA
HMWdA*  No Dashes specified. Double character aisle (Ex 10-101-1)
HMWdAC                   when          %subst(sidisp:3:1) = '-'
HMWdAC                             and %subst(sidisp:4:3) >= '000'
HMWdAC                             and %subst(sidisp:4:3) <= '999'
HMWdAC                             and %subst(sidisp:7:1) = '-'
HMWdAC                             and %subst(sidisp:8:1) >= '0'
HMWdAC                             and %subst(sidisp:8:1) <= '9'
HMWdAC                             and (%subst(sidisp:9:1) = ' '
HMWdAC                               or %subst(sidisp:9:1) >= 'A'
HMWdAC                              and %subst(sidisp:9:1) <= 'Z')
HMWdAC                   eval      dashpos = -1
HMWdA*
HMWdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMWdA*
HMWdAC                   eval      loca  = %subst(sidisp:4:3)
HMWdAC                   move      loca          slloc
HMWdA*
HMWdAC                   evalr     lvla  = %subst(sidisp:8:1)
HMWdAC                   move      lvla          slrlvl
HMWdA*
HMWdAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
HMWdA
HMWdA*  No Dashes specified. Double character aisle (Ex 10-101-10)
HMWdAC                   when          %subst(sidisp:3:1) = '-'
HMWdAC                             and %subst(sidisp:4:3) >= '000'
HMWdAC                             and %subst(sidisp:4:3) <= '999'
HMWdAC                             and %subst(sidisp:7:1) = '-'
HMWdAC                             and %subst(sidisp:8:2) >= '00'
HMWdAC                             and %subst(sidisp:8:2) <= '99'
HMWdAC                   eval      dashpos = -1
HMWdA*
HMWdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMWdA*
HMWdAC                   eval      loca  = %subst(sidisp:4:3)
HMWdAC                   move      loca          slloc
HMWdA*
HMWdAC                   evalr     lvla  = %subst(sidisp:8:2)
HMWdAC                   move      lvla          slrlvl
HMWdA*
HMWdAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
HMW A
HMW AC                   endsl
HMW A
HMW A*  Begin testing parts for ALL slots.
HMW AC                   testn                   loca                 5050
HMW AC                   if        *in50 = *off
HMW AC                   eval      locnotnum = *on
HMW A
HMW AC                   else
HMW AC                   select
HMW AC                   when      slloc  = 0
HMW AC*                  eval      slloc = slloc + 100
HMW AC                   when      slloc < 0
HMW AC                   eval      slloc = slloc * -1
HMW AC                   endsl
HMW AC                   endif
HMW A
HMW AC                   testn                   lvla                 50
HMW AC                   if        *in50 = *off
HMW AC                   eval      lvlnotnum = *on
HMW AC                   else
HMW AC                   select
HMW AC                   when      slrlvl = 0
HMW AC*                  eval      slrlvl = slrlvl + 1
HMW AC                   when      slrlvl < 0
HMW AC                   eval      slrlvl = slrlvl * -1
HMW AC                   endsl
HMW AC                   endif
HMW A
HMW A*    Convert numeric handstack to alpha character.
HMW A
HMW AC*                  if            slhand >= ' 0'
HMW AC*                            and slhand <= '99'
HMW AC*                  eval      wkchar = slhand
HMW AC*                  exsr      zzcvt2ltr
HMW AC*                  eval      slhand = nwchar
HMW AC*                  endif
HMW A
HMW AC     slloc         div       2             dummy
HMW AC                   mvr                     oddeven
HMW AC                   if        oddeven <> 0
HMW AC                   eval      slside = 1
HMW AC                   else
HMW AC                   eval      slside = 0
HMW AC                   endif
HMW A
HMW A*    See if slot meets criteria for allowing it to be created.
HMW A
HMW AC                   select
HMW A
HMW A*    If non-special slot doesn't have hypens, then don't add it.
HMW A
HMW AC                   when      dashpos = 0
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    Don't allow creation if department is unknown.
HMW A
HMW AC                   when      validdept = '*NO '
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    If location or level is not numeric, then don't add.
HMW A
HMW AC                   when      locnotnum or lvlnotnum
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    Otherwise, slot is ok to be created.
HMW A
HMW AC                   other
HMW AC                   eval      slwhdp = siwhdp
HMW AC                   eval      sldisp = sidisp
HMW AC                   eval      slstyp = sistyp
HMW A
HMW AC                   endsl
HMW A
HMW A*    Try and create the imported slot.
HMW A
HMW AC                   eval      slwhse = siwhse
HMW AC                   eval      slpseq = sipseq
HMW AC*
HMW AC                   select
HMW AC                   when      slpseq = 0
HMW AC                   eval      slpseq = slloc
HMW AC                   when      slpseq < 0
HMW AC                   eval      slpseq = slpseq * -1
HMW AC                   endsl
HMW AC                   if        slitem > ' '
HMW AC                   eval      slstat = 'A'
HMW AC                   else
HMW AC                   eval      slstat = 'V'
HMW AC                   endif
HMW A*
HMW AC                   eval      slrsrv = sirsrv
HMWdA*
HMWdAC                   if        sidgtp > ' '
HMWdAC                   eval      slsdef = sidgtp
HMWdAC                   else
HMWdA*
HMW AC                   eval      slsdef = 'XX'
HMWdAC                   endif
HMWdA*
HMW AC                   eval      slpick = sipick
HMW A
HMW AC                   write (e) slrec
HMW AC                   if        %error
HMW AC                   eval      notcreated = *on
HMW AC                   endif
HMW A
HMW AC     endcreate25   endsr

RFS A*----------------------------------------------------------------
RFS A*  crtslot26  Try and create physical slot. Reinhart Foodsvc/Agar
RFS A*----------------------------------------------------------------
RFS A
RFS AC     crtslot26     begsr
RFS AC                   eval      notcreated = *off
RFS A
RFS A*  Turn on SlotCreated flag even if slot isn't created
RFS A*  so ZZUPD routine doesn't get executed.
RFS AC                   eval      slotcreated= *on
RFS AC                   eval      handstack  = *off
RFS AC                   clear                   slrec
RFS A
RFS A*  Extract location and level. Test if they are numeric.
RFS A
RFS AC                   eval      locnotnum = *off
RFS AC                   eval      lvlnotnum = *off
RFS AC                   eval      dashpos = 0
RFS AC                   eval      loca  = ' '
RFS AC                   eval      lvla  = ' '
RFS A
RFS A*  Check for all alpha slot. If no digits, default slot location
RFS A*  will be assigned.
RFS AC                   If            %subst(sidisp:4:4) >= '0000'
RFS AC                             and %subst(sidisp:4:4) <= '9999'
RFS AC                             and %subst(sidisp:3:1)  = '-'
RFS AC                             and %subst(sidisp:8:1)  = ' '
RFS A
RFS AC                             or  %subst(sidisp:4:4) >= '0000'
RFS AC                             and %subst(sidisp:4:4) <= '9999'
RFS AC                             and %subst(sidisp:3:1)  = '-'
RFS AC                             and %subst(sidisp:9:1)  = ' '
RFS A
RFS AC                   eval      allchrslot = *off
RFS AC                   else
RFS AC                   eval      allchrslot = *on
RFS AC                   endif
RFS A
RFS A
RFS AC                   select
RFS A
RFS A*  No dashes specified. All character slot.
RFS AC                   when      allchrslot = *on
RFS AC
RFS AC                   eval      kydisp = sidisp
RFS AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
RFS AC
RFS AC                   eval      dftlocation = dftlocation + 1
RFS AC                   eval      loca   = %char(dftlocation)
RFS AC                   eval      slloc  = dftlocation
RFS AC
RFS AC                   eval      slrlvl = 1
RFS AC                   eval      lvla   = '1'
RFS AC
RFS AC                   eval      slhand  = '  '
RFS AC                   eval      dashpos = -1
RFS A*
RFS A*  Dashes specified. Double character aisle (Ex FK-0701)
RFS AC                   when          %subst(sidisp:4:4) >= '0000'
RFS AC                             and %subst(sidisp:4:4) <= '9999'
RFS AC                   eval      dashpos = -1
RFS AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
RFS AC                   eval      loca  = %subst(sidisp:4:3)
RFS AC                   move      loca          slloc
RFS A*
RFS A*      Convert alpha level into numeric value.
RFS AC                   eval      lvla    = %subst(sidisp:8:1)
RFS AC                   evalr     wkchar = %trimr(lvla)
RFS AC                   exsr      zzcvt2nbr
RFS AC                   evalr     lvla   = %trimr(nwchar)
RFScAC                   monitor
RFS AC                   eval      slrlvl = %dec(nwchar:2:0)
RFScAC                   on-error
RFScAC                   endmon
RFS AC                   if        %subst(sidisp:8:1) > ' '
RFS AC                   eval      slrlvl = slrlvl + 1
RFS AC                   endif
RFS AC
RFS AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
RFS A
RFS AC                   endsl
RFS A
RFS A*  Begin testing parts for ALL slots.
RFS AC                   testn                   loca                 5050
RFS AC                   if        *in50 = *off
RFS AC                   eval      locnotnum = *on
RFS A
RFS AC                   else
RFS AC                   select
RFS AC                   when      slloc  = 0
RFS AC*                  eval      slloc = slloc + 100
RFS AC                   when      slloc < 0
RFS AC                   eval      slloc = slloc * -1
RFS AC                   endsl
RFS AC                   endif
RFS A
RFS AC                   testn                   lvla                 50
RFS AC                   if        *in50 = *off
RFS AC                   eval      lvlnotnum = *on
RFS AC                   else
RFS AC                   select
RFS AC                   when      slrlvl = 0
RFS AC                   eval      slrlvl = slrlvl + 1
RFS AC                   when      slrlvl < 0
RFS AC                   eval      slrlvl = slrlvl * -1
RFS AC                   endsl
RFS AC                   endif
RFS A
RFS AC     slloc         div       2             dummy
RFS AC                   mvr                     oddeven
RFS AC                   if        oddeven <> 0
RFS AC                   eval      slside = 1
RFS AC                   else
RFS AC                   eval      slside = 0
RFS AC                   endif
RFS A
RFS A*    See if slot meets criteria for allowing it to be created.
RFS A
RFS AC                   select
RFS A
RFS A*    If non-special slot doesn't have hypens, then don't add it.
RFS A
RFS AC                   when      dashpos = 0
RFS AC                   eval      notcreated = *on
RFS AC                   goto      endcreate26
RFS A
RFS A*    Don't allow creation if department is unknown.
RFS A
RFS AC                   when      validdept = '*NO '
RFS AC                   eval      notcreated = *on
RFS AC                   goto      endcreate26
RFS A
RFS A*    If location or level is not numeric, then don't add.
RFS A
RFS AC                   when      locnotnum or lvlnotnum
RFS AC                   eval      notcreated = *on
RFS AC                   goto      endcreate26
RFS A
RFS A*    Otherwise, slot is ok to be created.
RFS A
RFS AC                   other
RFS AC                   eval      slwhdp = siwhdp
RFS AC                   eval      sldisp = sidisp
RFS AC                   eval      slstyp = sistyp
RFS A
RFS AC                   endsl
RFS A
RFS A*    Try and create the imported slot.
RFS A
RFS AC                   eval      slwhse = siwhse
RFS AC                   eval      slpseq = sipseq
RFS AC*
RFS AC                   select
RFS AC                   when      slpseq = 0
RFS AC                   eval      slpseq = slloc
RFS AC                   when      slpseq < 0
RFS AC                   eval      slpseq = slpseq * -1
RFS AC                   endsl
RFS AC                   if        siitem > ' '
RFS AC                   eval      slstat = 'A'
RFS AC                   else
RFS AC                   eval      slstat = 'V'
RFS AC                   endif
RFS A*
RFS AC                   eval      slrsrv = sirsrv
RFS AC                   eval      slsdef = 'XX'
RFS AC                   eval      slpick = sipick
RFS A
RFS AC                   write (e) slrec
RFS AC                   if        %error
RFS AC                   eval      notcreated = *on
RFS AC                   endif
RFS A
RFS AC     endcreate26   endsr

GLP A*----------------------------------------------------------------
GLP A*  crtslot27  Try and create physical slot. Greenleaf Produce
GLP A*----------------------------------------------------------------
GLP A
GLP AC     crtslot27     begsr
GLP AC                   eval      notcreated = *off
GLP A
GLP A*  Turn on SlotCreated flag even if slot isn't created
GLP A*  so ZZUPD routine doesn't get executed.
GLP AC                   eval      slotcreated= *on
GLP AC                   eval      handstack  = *off
GLP AC                   clear                   slrec
GLP A
GLP A*  Extract location and level. Test if they are numeric.
GLP A
GLP AC                   eval      locnotnum = *off
GLP AC                   eval      lvlnotnum = *off
GLP AC                   eval      dashpos = 0
GLP AC                   eval      loca  = ' '
GLP AC                   eval      lvla  = ' '
GLP A
GLP A*  Check for all alpha slot. If no digits, default slot location
GLP A*  will be assigned.
GLP AC                   If            %subst(sidisp:1:4) >= '0000'
GLP AC                             and %subst(sidisp:1:4) <= '9999'
GLP AC                             and %subst(sidisp:5:1)  = '-'
GLP AC                             and %subst(sidisp:6:1) >= 'A'
GLP AC                             and %subst(sidisp:6:1) <= 'Z'
GLP AC                   eval      allchrslot = *off
GLP AC                   else
GLP AC                   eval      allchrslot = *on
GLP AC                   endif
GLP A
GLP A
GLP AC                   select
GLP A
GLP A*  No dashes specified. All character slot.
GLP AC                   when      allchrslot = *on
GLP AC
GLP AC                   eval      kydisp = sidisp
GLP AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
GLP AC
GLP AC                   eval      dftlocation = dftlocation + 1
GLP AC                   eval      loca   = %char(dftlocation)
GLP AC                   eval      slloc  = dftlocation
GLP AC
GLP AC                   eval      slrlvl = 1
GLP AC                   eval      lvla   = '1'
GLP AC
GLP AC                   eval      slhand  = '  '
GLP AC                   eval      dashpos = -1
GLP A*
GLP A*  Dashes specified. Double character aisle (Ex 7004-A1)
GLP AC                   when          %subst(sidisp:1:4) >= '0000'
GLP AC                             and %subst(sidisp:1:4) <= '9999'
GLP AC                             and %subst(sidisp:5:1)  = '-'
GLP AC                             and %subst(sidisp:6:1) >= 'A'
GLP AC                             and %subst(sidisp:6:1) <= 'Z'
GLP A*
GLP AC                   eval      dashpos = -1
GLP AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
GLP A*
GLP AC                   eval      loca  = '0' + %subst(sidisp:3:2)
GLP AC                   move      loca          slloc
GLP A*
GLP A*      Convert alpha level into numeric value.
GLP AC                   eval      lvla    = %subst(sidisp:6:1)
GLP AC                   evalr     wkchar = %trimr(lvla)
GLP AC                   exsr      zzcvt2nbr
GLP AC                   evalr     lvla   = %trimr(nwchar)
GLP AC                   eval      slrlvl = %dec(nwchar:2:0)
GLP AC
GLP AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
GLP A
GLP AC                   endsl
GLP A
GLP A*  Begin testing parts for ALL slots.
GLP AC                   testn                   loca                 5050
GLP AC                   if        *in50 = *off
GLP AC                   eval      locnotnum = *on
GLP A
GLP AC                   else
GLP AC                   select
GLP AC                   when      slloc  = 0
GLP AC*                  eval      slloc = slloc + 100
GLP AC                   when      slloc < 0
GLP AC                   eval      slloc = slloc * -1
GLP AC                   endsl
GLP AC                   endif
GLP A
GLP AC                   testn                   lvla                 50
GLP AC                   if        *in50 = *off
GLP AC                   eval      lvlnotnum = *on
GLP AC                   else
GLP AC                   select
GLP AC                   when      slrlvl = 0
GLP AC                   eval      slrlvl = slrlvl + 1
GLP AC                   when      slrlvl < 0
GLP AC                   eval      slrlvl = slrlvl * -1
GLP AC                   endsl
GLP AC                   endif
GLP A
GLP AC     slloc         div       2             dummy
GLP AC                   mvr                     oddeven
GLP AC                   if        oddeven <> 0
GLP AC                   eval      slside = 1
GLP AC                   else
GLP AC                   eval      slside = 0
GLP AC                   endif
GLP A
GLP A*    See if slot meets criteria for allowing it to be created.
GLP A
GLP AC                   select
GLP A
GLP A*    If non-special slot doesn't have hypens, then don't add it.
GLP A
GLP AC                   when      dashpos = 0
GLP AC                   eval      notcreated = *on
GLP AC                   goto      endcreate27
GLP A
GLP A*    Don't allow creation if department is unknown.
GLP A
GLP AC                   when      validdept = '*NO '
GLP AC                   eval      notcreated = *on
GLP AC                   goto      endcreate27
GLP A
GLP A*    If location or level is not numeric, then don't add.
GLP A
GLP AC                   when      locnotnum or lvlnotnum
GLP AC                   eval      notcreated = *on
GLP AC                   goto      endcreate27
GLP A
GLP A*    Otherwise, slot is ok to be created.
GLP A
GLP AC                   other
GLP AC                   eval      slwhdp = siwhdp
GLP AC                   eval      sldisp = sidisp
GLP AC                   eval      slstyp = sistyp
GLP A
GLP AC                   endsl
GLP A
GLP A*    Try and create the imported slot.
GLP A
GLP AC                   eval      slwhse = siwhse
GLP AC                   eval      slpseq = sipseq
GLP AC*
GLP AC                   select
GLP AC                   when      slpseq = 0
GLP AC                   eval      slpseq = slloc
GLP AC                   when      slpseq < 0
GLP AC                   eval      slpseq = slpseq * -1
GLP AC                   endsl
GLP AC                   if        siitem > ' '
GLP AC                   eval      slstat = 'A'
GLP AC                   else
GLP AC                   eval      slstat = 'V'
GLP AC                   endif
GLP A*
GLP AC                   eval      slrsrv = sirsrv
GLP AC                   eval      slsdef = 'XX'
GLP AC                   eval      slpick = sipick
GLP A
GLP AC                   write (e) slrec
GLP AC                   if        %error
GLP AC                   eval      notcreated = *on
GLP AC                   endif
GLP A
GLP AC     endcreate27   endsr
WIF A
WIF A*----------------------------------------------------------------
WIF A*  crtslot28  Try and create physical slot. Williams Foods
WIF A*----------------------------------------------------------------
WIF A
WIF AC     crtslot28     begsr
WIF AC                   eval      notcreated = *off
WIF A
WIF A*  Turn on SlotCreated flag even if slot isn't created
WIF A*  so ZZUPD routine doesn't get executed.
WIF AC                   eval      slotcreated= *on
WIF AC                   eval      handstack  = *off
WIF AC                   clear                   slrec
WIF A
WIF A*  Extract location and level. Test if they are numeric.
WIF A
WIF AC                   eval      locnotnum = *off
WIF AC                   eval      lvlnotnum = *off
WIF AC                   eval      dashpos = 0
WIF AC                   eval      loca  = ' '
WIF AC                   eval      lvla  = ' '
WIF A
WIF A*  Check for all alpha slot. If no digits, default slot location
WIF A*  will be assigned.
WIF AC                   If            %subst(sidisp:2:3) >= '000'
WIF AC                             and %subst(sidisp:2:3) <= '999'
WIF A*
WIF AC                             or  %subst(sidisp:2:2) >= '00'
WIF AC                             and %subst(sidisp:2:2) <= '99'
WIF AC                             and %subst(sidisp:4:1)  = ' '
WIF AC                   eval      allchrslot = *off
WIF AC                   else
WIF AC                   eval      allchrslot = *on
WIF AC                   endif
WIF A
WIF A
WIF AC                   select
WIF A
WIF A*  No dashes specified. All character slot.
WIF AC                   when      allchrslot = *on
WIF AC
WIF AC                   eval      kydisp = sidisp
WIF AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
WIF AC
WIF AC                   eval      dftlocation = dftlocation + 1
WIF AC                   eval      loca   = %char(dftlocation)
WIF AC                   eval      slloc  = dftlocation
WIF AC
WIF AC                   eval      slrlvl = 1
WIF AC                   eval      lvla   = '1'
WIF AC
WIF AC                   eval      slhand  = '  '
WIF AC                   eval      dashpos = -1
WIF A*
WIF A*  No Dashes specified. Single character aisle (Ex A031)
WIF AC                   when          %subst(sidisp:2:2) >= '00'
WIF AC                             and %subst(sidisp:2:2) <= '99'
WIF AC                             and %subst(sidisp:4:1) >= '0'
WIF AC                             and %subst(sidisp:4:4) <= '9'
WIF A*
WIF AC                   eval      dashpos = -1
WIF AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
WIF A*
WIF AC                   eval      loca  = '0' + %subst(sidisp:2:2)
WIF AC                   move      loca          slloc
WIF A*
WIF AC                   eval      lvla    = %subst(sidisp:4:1)
WIF AC                   eval      slrlvl = %dec(lvla:2:0)
WIFbAC                   eval      slrlvl = slrlvl + 1
WIF AC
WIF AC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
WIF A*
WIF A*  No Dashes specified. Single character aisle (Ex A03)
WIF AC                   when          %subst(sidisp:2:2) >= '00'
WIF AC                             and %subst(sidisp:2:2) <= '99'
WIF AC                             and %subst(sidisp:4:1)  = ' '
WIF A*
WIF AC                   eval      dashpos = -1
WIF AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
WIF A*
WIF AC                   eval      loca  = '0' + %subst(sidisp:2:2)
WIF AC                   move      loca          slloc
WIF A*
WIFcDC*                  eval      slrlvl = 1
WIFcMC                   eval      slrlvl = 0
WIFcDC*                  eval      lvla   = '1'
WIFcMC                   eval      lvla   = '0'
WIF AC
WIF AC                   eval      slhand  = ' '
WIF A
WIF AC                   endsl
WIF A
WIF A*  Begin testing parts for ALL slots.
WIF AC                   testn                   loca                 5050
WIF AC                   if        *in50 = *off
WIF AC                   eval      locnotnum = *on
WIF A
WIF AC                   else
WIF AC                   select
WIF AC                   when      slloc  = 0
WIF AC*                  eval      slloc = slloc + 100
WIF AC                   when      slloc < 0
WIF AC                   eval      slloc = slloc * -1
WIF AC                   endsl
WIF AC                   endif
WIF A
WIF AC                   testn                   lvla                 50
WIF AC                   if        *in50 = *off
WIF AC                   eval      lvlnotnum = *on
WIF AC                   else
WIF AC                   select
WIF AC                   when      slrlvl = 0
WIFbDC*                  eval      slrlvl = slrlvl + 1
WIF AC                   when      slrlvl < 0
WIF AC                   eval      slrlvl = slrlvl * -1
WIF AC                   endsl
WIF AC                   endif
WIF A
WIF AC     slloc         div       2             dummy
WIF AC                   mvr                     oddeven
WIF AC                   if        oddeven <> 0
WIF AC                   eval      slside = 1
WIF AC                   else
WIF AC                   eval      slside = 0
WIF AC                   endif
WIF A
WIF A*    See if slot meets criteria for allowing it to be created.
WIF A
WIF AC                   select
WIF A
WIF A*    If non-special slot doesn't have hypens, then don't add it.
WIF A
WIF AC                   when      dashpos = 0
WIF AC                   eval      notcreated = *on
WIF AC                   goto      endcreate28
WIF A
WIF A*    Don't allow creation if department is unknown.
WIF A
WIF AC                   when      validdept = '*NO '
WIF AC                   eval      notcreated = *on
WIF AC                   goto      endcreate28
WIF A
WIF A*    If location or level is not numeric, then don't add.
WIF A
WIF AC                   when      locnotnum or lvlnotnum
WIF AC                   eval      notcreated = *on
WIF AC                   goto      endcreate28
WIF A
WIF A*    Otherwise, slot is ok to be created.
WIF A
WIF AC                   other
WIF AC                   eval      slwhdp = siwhdp
WIF AC                   eval      sldisp = sidisp
WIF AC                   eval      slstyp = sistyp
WIF A
WIF AC                   endsl
WIF A
WIF A*    Try and create the imported slot.
WIF A
WIF AC                   eval      slwhse = siwhse
WIF AC                   eval      slpseq = sipseq
WIF AC*
WIF AC                   select
WIF AC                   when      slpseq = 0
WIF AC                   eval      slpseq = slloc
WIF AC                   when      slpseq < 0
WIF AC                   eval      slpseq = slpseq * -1
WIF AC                   endsl
WIF AC                   if        siitem > ' '
WIF AC                   eval      slstat = 'A'
WIF AC                   else
WIF AC                   eval      slstat = 'V'
WIF AC                   endif
WIF A*
WIF AC                   eval      slrsrv = sirsrv
WIF AC                   eval      slsdef = 'XX'
WIF AC                   eval      slpick = sipick
WIF A
WIF AC                   write (e) slrec
WIF AC                   if        %error
WIF AC                   eval      notcreated = *on
WIF AC                   endif
WIF A
WIF AC     endcreate28   endsr
WIF A
JOR A*----------------------------------------------------------------
JOR A*  crtslot29  Try and create physical slot for Jodano's.
JOR A*----------------------------------------------------------------
JOR A
JOR AC     crtslot29     begsr
JOR AC                   eval      notcreated = *off
JOR AC                   eval      handstack  = *off
JOR AC                   clear                   slrec

     *  Extract location and level. Test if they are numeric.

     C                   eval      locnotnum = *off
     C                   eval      lvlnotnum = *off
     C                   eval      dashpos = 0
     C                   eval      loca  = ' '
     C                   eval      lvla  = ' '
JOR4AC                   eval      lvla2 = '  '

     *  Check for all alpha slot. If no digits, default slot location
     *  will be assigned.
     C                   If            %subst(sidisp:2:2) >= '00'
     C                             and %subst(sidisp:2:2) <= '99'
     C                             or  %subst(sidisp:3:2) >= '00'
     C                             and %subst(sidisp:3:2) <= '99'
JOR5A*
JOR5AC                             or  %subst(sidisp:4:1) >= '0'
JOR5AC                             and %subst(sidisp:4:1) <= '9'
JOR5AC                             and %subst(sidisp:6:1) >= '0'
JOR5AC                             and %subst(sidisp:6:1) <= '9'
JOR5A*
JOR5AC                             or  %subst(sidisp:4:2) >= '00'
JOR5AC                             and %subst(sidisp:4:2) <= '99'
JOR5AC                             and %subst(sidisp:7:1) >= '0'
JOR5AC                             and %subst(sidisp:7:1) <= '9'
     C                   eval      allchrslot = *off
     C                   else
     C                   eval      allchrslot = *on
     C                   endif

     C                   select

     *  Dashes specified. Single character aisle
     C                   when      %subst(sidisp:2:1) = '-'
     C                             and %subst(sidisp:6:1) = '-'
     C                   eval      dashpos = 2
     C                   eval      slaisl = '  ' + %subst(sidisp:1:1)
     C                   eval      loca  = %subst(sidisp:3:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:7:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:8:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *off
     C                   endif
     *      Create new Slot Display minus dashes.
     C                   eval      sidisp = %subst(sidisp:1:1)
     C                                      + %subst(sidisp:3:3)
     C                                      + %subst(sidisp:7:6)

     *  Dashes specified. Double character aisle
     C                   when      %subst(sidisp:3:1) = '-'
     C                             and %subst(sidisp:7:1) = '-'
     C                   eval      slaisl = ' ' + %subst(sidisp:1:2)
     C                   eval      loca  = %subst(sidisp:4:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:8:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:9:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = 3
     *      Create new Slot Display minus dashes.
     C                   eval      sidisp = %subst(sidisp:1:2)
     C                                      + %subst(sidisp:4:3)
     C                                      + %subst(sidisp:8:5)

JOR5A*  Dashes specified. Double character aisle, single digit location
JOR5A*  or Dashes specified. Double character aisle, double digit location
JOR5AC                   when      %subst(sidisp:3:1) = '-'
JOR5AC                             and %subst(sidisp:5:1) = '-'
JOR5AC                             or %subst(sidisp:3:1) = '-'
JOR5AC                             and %subst(sidisp:6:1) = '-'
JOR5AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
JOR5A*
JOR5AC                   select
JOR5A*       Import slot format example: SA-10-1A
JOR5AC                   when      %subst(sidisp:6:1) = '-'
JOR5AC                   eval      loca  = '0' + %subst(sidisp:4:2)
JOR5AC                   move      loca          slloc
JOR5AC                   eval      lvla  = %subst(sidisp:7:1)
JOR5AC                   move      lvla          slrlvl
JOR5AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
JOR5A*      Create new Slot Display minus dashes.
JOR5AC                   eval      sidisp = %subst(sidisp:1:2)
JOR5AC                                      + %subst(sidisp:4:2)
JOR5AC                                      + %subst(sidisp:7:6)
JOR5A*
JOR5A*       Import slot format example: SA-1-1A
JOR5AC                   other
JOR5A*
JOR5AC                   eval      loca  = '00' + %subst(sidisp:4:1)
JOR5AC                   move      loca          slloc
JOR5AC                   eval      lvla  = %subst(sidisp:6:1)
JOR5AC                   move      lvla          slrlvl
JOR5AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
JOR5AC                   if        slhand > ' '
JOR5AC*                  eval      handstack = *on
JOR5AC                   endif
JOR5A*      Create new Slot Display minus dashes.
JOR5AC                   eval      sidisp = %subst(sidisp:1:2)
JOR5AC                                      + %subst(sidisp:4:1)
JOR5AC                                      + %subst(sidisp:6:7)
JOR5AC                   endsl
JOR5A*
JOR5AC                   eval      dashpos = 3
JOR4A
JOR4A*  No Dashes specified. Single digit level w/ Single character aisle
JOR4AC                   when          %subst(sidisp:2:3) >= '000'
JOR4AC                             and %subst(sidisp:2:3) <= '999'
JOR4AC                             and %subst(sidisp:5:1) >= '0'
JOR4AC                             and %subst(sidisp:5:1) <= '9'
JOR4AC                             and (%subst(sidisp:6:1) >= 'A'
JOR4AC                             and  %subst(sidisp:6:1) <= 'Z')
JOR4AC                   eval      dashpos = -1
JOR4AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
JOR4AC                   eval      loca  = %subst(sidisp:2:3)
JOR4AC                   move      loca          slloc
JOR4AC                   eval      slloc   = slloc  + 100
JOR4AC                   eval      lvla  = %subst(sidisp:5:1)
JOR4AC                   move      lvla          slrlvl
JOR4AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
JOR4AC                   if        slhand > ' '
JOR4AC                   eval      handstack = *off
JOR4AC                   endif
JOR4A
JOR4A*  No Dashes specified. Double digit level w/ Single character aisle
JOR4AC                   when          %subst(sidisp:2:3) >= '000'
JOR4AC                             and %subst(sidisp:2:3) <= '999'
JOR4AC                             and %subst(sidisp:5:2) >= '00'
JOR4AC                             and %subst(sidisp:5:2) <= '99'
JOR4AC                             and (%subst(sidisp:7:1) >= 'A'
JOR4AC                             and  %subst(sidisp:7:1) <= 'Z')
JOR4AC                   eval      dashpos = -1
JOR4AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
JOR4AC                   eval      loca  = %subst(sidisp:2:3)
JOR4AC                   move      loca          slloc
JOR4AC                   eval      slloc   = slloc  + 100
JOR4AC                   eval      lvla2 = %subst(sidisp:5:2)
JOR4AC                   move      lvla2         slrlvl
JOR4AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
JOR4AC                   if        slhand > ' '
JOR4AC                   eval      handstack = *off
JOR4AC                   endif

     *  No dashes specified. All character slot.
     C                   when      allchrslot = *on
     C
     C                   eval      kydisp = sidisp
     C                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
     C
     C                   eval      dftlocation = dftlocation + 1
     C                   eval      loca   = %char(dftlocation)
     C                   eval      slloc  = dftlocation
     C
     C                   eval      slrlvl = 1
     C                   eval      lvla   = '1'
     C
     C                   eval      slhand  = '  '
     C                   eval      dashpos = -1

     *  No dashes specified. Extract out slot breakdown.
     C                   other
     C
JOR1DC*                  eval      kydisp = %subst(sidisp:1:4)
JOR1MC                   eval      kydisp = sidisp
JOR1DC*                  eval      slaisl  = ' ' + %subst(sidisp:1:2)
JOR1MC                   eval      slaisl  = '  ' + %subst(sidisp:1:1)

JOR1DC*                  evalr     loca    = %trimr(%subst(sidisp:3:2))
JOR1MC                   evalr     loca    = %trimr(%subst(sidisp:2:3))
     C                   move      loca          slloc
JOR1AC                   eval      slloc   = slloc  + 100

     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   move      lvla          slrlvl
JOR1DC*                  eval      slrlvl  = slrlvl + 1

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
JOR2DC*                  eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     C                   endsl


     *  Begin testing parts for ALL slots.
     C                   testn                   loca                 5050
     C                   if        *in50 = *off
     C                   eval      locnotnum = *on
     C                   endif

JOR4AC                   if        lvla2 > ' '
JOR4AC                   testn                   lvla2                5050
JOR4AC                   else
     C                   testn                   lvla                 50
JOR4AC                   endif
JOR4A
     C                   if        *in50 = *off
     C                   eval      lvlnotnum = *on
     C                   else
     C                   select
     C                   when      slrlvl = 0
     C                   eval      slrlvl = slrlvl + 11
     C                   when      slrlvl < 0
     C                   eval      slrlvl = slrlvl * -1
     C                   endsl
     C                   endif

     *    Convert numeric handstack to alpha character.

     C                   if            slhand >= ' 0'
     C                             and slhand <= '99'
     C                   eval      wkchar = slhand
     C                   exsr      zzcvt2ltr
     C                   eval      slhand = nwchar
     C                   endif

     C     slloc         div       2             dummy
     C                   mvr                     oddeven
     C                   if        oddeven <> 0
     C                   eval      slside = 1
     C                   else
     C                   eval      slside = 0
     C                   endif
     *
     *    Check if base slot exists for imported slot with handstacks.
     *
     C                   eval      crtbaseslot = *off
     C                   if        handstack = *on
     C     keysl2b       setll     slot2
     C                   if        not %equal(slot2)
     C                   eval      crtbaseslot = *on
     C                   endif
     C                   endif

     *    See if slot meets criteria for allowing it to be created.

     C                   select

     *    If non-special slot doesn't have hypens, then don't add it.

     C                   when      dashpos = 0
     C                   eval      notcreated = *on
     C                   goto      endcreate29

     *    Don't allow creation if department is unknown.

500gMC                   when      validdept = '*NO '
     C                   eval      notcreated = *on
     C                   goto      endcreate29

     *    If location or level is not numeric, then don't add.

     C                   when      locnotnum or lvlnotnum
     C                   eval      notcreated = *on
     C                   goto      endcreate29

     *    Otherwise, slot is ok to be created.

     C                   other
     C                   eval      slwhdp = siwhdp
     C                   eval      sldisp = sidisp
     C                   eval      slstyp = sistyp

     C                   endsl

     *    Try and create the imported slot.

     C                   eval      slwhse = siwhse
     *
     C                   eval      slpseq = sipseq
     C                   select
     C                   when      slpseq = 0
     C                   eval      slpseq = slloc
     C                   when      slpseq < 0
     C                   eval      slpseq = slpseq * -1
     C                   endsl
JOR AC                   if        slitem > ' '
     C                   eval      slstat = 'A'
JOR AC                   else
JOR AC                   eval      slstat = 'V'
JOR AC                   endif
     *
     *    Slot has handstack, create as virtual slot.
     C                   if        handstack = *on
     C                   eval      slrsrv = 'V'
     C                   else
     C                   eval      slrsrv = sirsrv
     C                   endif
     C                   if        sidgtp > '  '
     C                   movel     sidgtp        slsdef
     C                   else
     C                   eval      slsdef = 'XX'
     C                   endif
     C                   eval      slpick = sipick

     C                   write (e) slrec
     C                   if        %error
     C                   eval      notcreated = *on
     C                   endif

     C     endcreate29   endsr

PFC A*----------------------------------------------------------------
PFC A*  crtslot30  Try and create physical slot. Presto Foods
PFC A*----------------------------------------------------------------
PFC A
PFC AC     crtslot30     begsr
PFC AC                   eval      notcreated = *off
PFC A
PFCbA*  Uppercase SIDISP
PFCbAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
PFCbA*  Uppercase SIITEM
PFCbAC                   eval      siitem = %xlate(lower:UPPER:siitem)
PFCbA
PFC A*  Turn on SlotCreated flag even if slot isn't created
PFC A*  so ZZUPD routine doesn't get executed.
PFC AC                   eval      slotcreated= *on
PFC AC                   eval      handstack  = *off
PFC AC                   clear                   slrec
PFC A
PFC A*  Extract location and level. Test if they are numeric.
PFC A
PFC AC                   eval      locnotnum = *off
PFC AC                   eval      lvlnotnum = *off
PFC AC                   eval      dashpos = 0
PFC AC                   eval      loca  = ' '
PFC AC                   eval      lvla  = ' '
PFC A
PFC A*  Check for all alpha slot. If no digits, default slot location
PFC A*  will be assigned.
PFC AC                   If            %subst(sidisp:4:3) >= '000'
PFC AC                             and %subst(sidisp:4:3) <= '999'
PFC AC                             and %subst(sidisp:3:1)  = '-'
PFC AC                             and %subst(sidisp:7:1)  = '-'
PFC AC                   eval      allchrslot = *off
PFC AC                   else
PFC AC                   eval      allchrslot = *on
PFC AC                   endif
PFC A
CFIbA*  Check for SP slots, treat as allchrslot
CFIbAC                   If           %subst(sidisp:1:2) = 'SP'
CFIbAC                             or %subst(sidisp:8:2) = 'SP'
CFIbAC                   eval      allchrslot = *on
CFIbAC                   endif
PFC A
PFC AC                   select
PFC A
PFC A*  No dashes specified. All character slot.
PFC AC                   when      allchrslot = *on
PFC AC
PFC AC                   eval      kydisp = sidisp
PFC AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
PFC AC
PFC AC                   eval      dftlocation = dftlocation + 1
PFC AC                   eval      loca   = %char(dftlocation)
PFC AC                   eval      slloc  = dftlocation
PFC AC
PFC AC                   eval      slrlvl = 1
PFC AC                   eval      lvla   = '1'
PFC AC
PFC AC                   eval      slhand  = '  '
PFC AC                   eval      dashpos = -1
PFC A
PFC A*  Dashes specified. Double character aisle (Ex CA-172-A)
PFC AC                   when          %subst(sidisp:3:1) = '-'
PFC AC                             and %subst(sidisp:4:3) >= '000'
PFC AC                             and %subst(sidisp:4:3) <= '999'
PFC AC                             and %subst(sidisp:7:1)  = '-'
PFC AC                             and %subst(sidisp:8:1) >= 'A'
PFC AC                             and %subst(sidisp:8:1) <= 'Z'
PFC AC                   eval      dashpos = -1
PFC AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
PFC AC                   eval      loca  = %subst(sidisp:4:3)
PFC AC                   move      loca          slloc
PFC A*
PFC A*      Convert alpha level into numeric value.
PFC AC                   eval      lvla    = %subst(sidisp:8:1)
PFC AC                   evalr     wkchar = %trimr(lvla)
PFC AC                   exsr      zzcvt2nbr
PFC AC                   if        nwchar > ' '
PFC AC                   evalr     lvla   = %trimr(nwchar)
PFC AC                   eval      slrlvl = %dec(nwchar:2:0)
PFC AC                   else
PFC AC                   evalr     lvla  = %subst(sidisp:8:1)
PFC AC                   move      lvla          slrlvl
PFC AC                   eval      slrlvl = slrlvl + 3
PFC AC                   endif
PFC AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
PFC A
PFC AC                   endsl
PFC A
PFC A*  Begin testing parts for ALL slots.
PFC AC                   testn                   loca                 5050
PFC AC                   if        *in50 = *off
PFC AC                   eval      locnotnum = *on
PFC A
PFC AC                   else
PFC AC                   select
PFC AC                   when      slloc  = 0
PFC AC                   eval      slloc = slloc + 100
PFC AC                   when      slloc < 0
PFC AC                   eval      slloc = slloc * -1
PFC AC                   endsl
PFC AC                   endif
PFC A
PFC AC                   testn                   lvla                 50
PFC AC                   if        *in50 = *off
PFC AC                   eval      lvlnotnum = *on
PFC AC                   else
PFC AC                   select
PFC AC                   when      slrlvl = 0
PFC AC                   eval      slrlvl = slrlvl + 1
PFC AC                   when      slrlvl < 0
PFC AC                   eval      slrlvl = slrlvl * -1
PFC AC                   endsl
PFC AC                   endif
PFC A
PFC A*    Convert numeric handstack to alpha character.
PFC A
PFC AC                   if            slhand >= ' 0'
PFC AC                             and slhand <= '99'
PFC AC                   eval      wkchar = slhand
PFC AC                   exsr      zzcvt2ltr
PFC AC                   eval      slhand = nwchar
PFC AC                   endif
PFC A
PFC AC     slloc         div       2             dummy
PFC AC                   mvr                     oddeven
PFC AC                   if        oddeven <> 0
PFC AC                   eval      slside = 1
PFC AC                   else
PFC AC                   eval      slside = 0
PFC AC                   endif
PFC A
PFC A*    See if slot meets criteria for allowing it to be created.
PFC A
PFC AC                   select
PFC A
PFC A*    If non-special slot doesn't have hypens, then don't add it.
PFC A
PFC AC                   when      dashpos = 0
PFC AC                   eval      notcreated = *on
PFC AC                   goto      endcreate30
PFC A
PFC A*    Don't allow creation if department is unknown.
PFC A
PFC AC                   when      validdept = '*NO '
PFC AC                   eval      notcreated = *on
PFC AC                   goto      endcreate30
PFC A
PFC A*    If location or level is not numeric, then don't add.
PFC A
PFC AC                   when      locnotnum or lvlnotnum
PFC AC                   eval      notcreated = *on
PFC AC                   goto      endcreate30
PFC A
PFC A*    Otherwise, slot is ok to be created.
PFC A
PFC AC                   other
PFC AC                   eval      slwhdp = siwhdp
PFC AC                   eval      sldisp = sidisp
PFC AC                   eval      slstyp = sistyp
PFC A
PFC AC                   endsl
PFC A
PFC A*    Try and create the imported slot.
PFC A
PFC AC                   eval      slwhse = siwhse
PFC AC                   eval      slpseq = sipseq
PFC AC*
PFC AC                   select
PFC AC                   when      slpseq = 0
PFC AC                   eval      slpseq = slloc
PFC AC                   when      slpseq < 0
PFC AC                   eval      slpseq = slpseq * -1
PFC AC                   endsl
PFC AC                   if        slitem > ' '
PFC AC                   eval      slstat = 'A'
PFC AC                   else
PFC AC                   eval      slstat = 'V'
PFC AC                   endif
PFC A*
PFC AC                   eval      slrsrv = sirsrv
PFC AC                   eval      slsdef = 'XX'
PFC AC                   eval      slpick = sipick
PFC A
PFC AC                   write (e) slrec
PFC AC                   if        %error
PFC AC                   eval      notcreated = *on
PFC AC                   endif
PFC A
PFC AC     endcreate30   endsr
FPR
FPR A*----------------------------------------------------------------
FPR A*  crtslot31  Try and create physical slot. FoodPro
FPR A*----------------------------------------------------------------
FPR A
FPR AC     crtslot31     begsr
FPR AC                   eval      notcreated = *off
FPR A
FPR A*  Uppercase SIDISP - Not applicable.
FPR AC**                 eval      sidisp = %xlate(lower:UPPER:sidisp)
FPR A*  Uppercase SIITEM - Not applicable.
FPR AC**                 eval      siitem = %xlate(lower:UPPER:siitem)
FPR A
FPR A*  Turn on SlotCreated flag even if slot isn't created
FPR A*  so ZZUPD routine doesn't get executed.
FPR AC                   eval      slotcreated= *on
FPR AC                   eval      handstack  = *off
FPR AC                   clear                   slrec
FPR A
FPR A*  Extract location and level. Test if they are numeric.
FPR A
FPR AC                   eval      locnotnum = *off
FPR AC                   eval      lvlnotnum = *off
FPR AC                   eval      dashpos = 0
FPR AC                   eval      loca  = ' '
FPR AC                   eval      lvla  = ' '
FPR3AC                   eval      lvlaa = ' '
FPR A
FPR A*  Check for all alpha slot. If no digits, default slot location
FPR A*  will be assigned.
FPR AC                   If            %subst(sidisp:2:2) >= '00'
FPR AC                             and %subst(sidisp:2:2) <= '99'
FPR AC                             and %subst(sidisp:5:1) >= '0'
FPR AC                             and %subst(sidisp:5:1) <= '9'
FPR A*
FPR AC                             or  %subst(sidisp:3:2) >= '00'
FPR AC                             and %subst(sidisp:3:2) <= '99'
FPR AC                             and %subst(sidisp:6:1) >= '0'
FPR AC                             and %subst(sidisp:6:1) <= '9'
FPR2A*
FPR2AC                             or  %subst(sidisp:3:2) >= '00'
FPR2AC                             and %subst(sidisp:3:2) <= '99'
FPR2AC                             and %subst(sidisp:6:1) >= ' '
FPR2AC                             and %subst(sidisp:6:1) <= 'Z'
FPR A*
FPR AC                   eval      allchrslot = *off
FPR AC                   else
FPR AC                   eval      allchrslot = *on
FPR AC                   endif
FPR A
FPR A
FPR AC                   select
FPR A
FPR A*  No dashes specified. All character slot.
FPR AC                   when      allchrslot = *on
FPR AC
FPR AC                   eval      kydisp = sidisp
FPR AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
FPR AC
FPR AC                   eval      dftlocation = dftlocation + 1
FPR AC                   eval      loca   = %char(dftlocation)
FPR AC                   eval      slloc  = dftlocation
FPR AC
FPR AC                   eval      slrlvl = 1
FPR AC                   eval      lvla   = '1'
FPR AC
FPR AC                   eval      slhand  = '  '
FPR AC                   eval      dashpos = -1
FPR A
FPR A*  No Dashes specified. Single character aisle (Ex A03B1)
FPR AC                   when          %subst(sidisp:2:2) >= '00'
FPR AC                             and %subst(sidisp:2:2) <= '99'
FPR AC                             and %subst(sidisp:5:1) >= '0'
FPR AC                             and %subst(sidisp:5:1) <= '9'
FPR AC                   eval      dashpos = -1
FPR AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
FPR AC                   eval      loca  = '0' + %subst(sidisp:2:2)
FPR AC                   move      loca          slloc
FPR A*
FPR A*      Convert alpha level into numeric value.
FPR AC                   eval      lvla    = %subst(sidisp:5:1)
FPR AC                   evalr     wkchar = %trimr(lvla)
FPR AC                   exsr      zzcvt2nbr
FPR AC                   if        nwchar > ' '
FPR AC                   evalr     lvla   = %trimr(nwchar)
FPR AC                   eval      slrlvl = %dec(nwchar:2:0)
FPR AC                   else
FPR AC                   evalr     lvla  = %subst(sidisp:5:1)
FPR AC                   move      lvla          slrlvl
FPR AC                   endif
FPR A*
FPR AC                   eval      slhand  = ' ' + %subst(sidisp:4:1)
FPR A
FPR A*  No Dashes specified. Double character aisle (Ex EG01A1)
FPR A*  No Dashes specified. Double character aisle (Ex EG01AB)
FPR AC                   when          %subst(sidisp:3:2) >= '00'
FPR AC                             and %subst(sidisp:3:2) <= '99'
FPR AC                             and %subst(sidisp:6:1) >= '0'
FPR AC                             and %subst(sidisp:6:1) <= '9'
FPR3AC                             and %subst(sidisp:7:1)  = ' '
FPR2A*
FPR2AC                             or  %subst(sidisp:3:2) >= '00'
FPR2AC                             and %subst(sidisp:3:2) <= '99'
FPR2AC                             and %subst(sidisp:6:1) >= ' '
FPR2AC                             and %subst(sidisp:6:1) <= 'Z'
FPR3AC                             and %subst(sidisp:7:1)  = ' '
FPR AC                   eval      dashpos = -1
FPR AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FPR A*
FPR AC                   eval      loca  = '0' + %subst(sidisp:3:2)
FPR AC                   move      loca          slloc
FPR A*
FPR A*      Convert alpha level into numeric value.
FPR AC                   eval      lvla    = %subst(sidisp:6:1)
FPR AC                   evalr     wkchar = %trimr(lvla)
FPR AC                   exsr      zzcvt2nbr
FPR AC                   if        nwchar > ' '
FPR AC                   evalr     lvla   = %trimr(nwchar)
FPR AC                   eval      slrlvl = %dec(nwchar:2:0)
FPR AC                   else
FPR AC                   evalr     lvla  = %subst(sidisp:6:1)
FPR AC                   move      lvla          slrlvl
FPR AC                   endif
FPR AC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
FPR A
FPR3A
FPR3A*  No Dashes spec. Double character aisle/2-digit lvl (Ex EG01A10)
FPR3AC                   when          %subst(sidisp:3:2) >= '00'
FPR3AC                             and %subst(sidisp:3:2) <= '99'
FPR3AC                             and %subst(sidisp:6:1) >= '0'
FPR3AC                             and %subst(sidisp:6:1) <= '9'
FPR3AC                             and %subst(sidisp:7:1) >= '0'
FPR3AC                             and %subst(sidisp:7:1) <= '9'
FPR3A*
FPR3AC                   eval      dashpos = -1
FPR3AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
FPR3A*
FPR3AC                   eval      loca  = '0' + %subst(sidisp:3:2)
FPR3AC                   move      loca          slloc
FPR3A*      Slot has double digit rack level.
FPR3AC                   eval      lvlaa = %subst(sidisp:6:2)
FPR3AC                   move      lvlaa         slrlvl
FPR3AC
FPR3AC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
FPR3A
FPR AC                   endsl
FPR A
FPR A*  Begin testing parts for ALL slots.
FPR AC                   testn                   loca                 5050
FPR AC                   if        *in50 = *off
FPR AC                   eval      locnotnum = *on
FPR A
FPR AC                   else
FPR AC                   select
FPR AC                   when      slloc  = 0
FPR AC                   eval      slloc = slloc + 100
FPR AC                   when      slloc < 0
FPR AC                   eval      slloc = slloc * -1
FPR AC                   endsl
FPR AC                   endif
FPR A
FPR3AC                   if        lvlaa > ' '
FPR3AC                   testn                   lvlaa                5050
FPR3AC                   else
FPR3A*
FPR AC                   testn                   lvla                 50
FPR3AC                   endif
FPR3A*
FPR AC                   if        *in50 = *off
FPR AC                   eval      lvlnotnum = *on
FPR AC                   else
FPR AC                   select
FPR AC                   when      slrlvl = 0
FPR AC                   eval      slrlvl = slrlvl + 1
FPR AC                   when      slrlvl < 0
FPR AC                   eval      slrlvl = slrlvl * -1
FPR AC                   endsl
FPR AC                   endif
FPR A
FPR A*    Convert numeric handstack to alpha character.
FPR A
FPR AC                   if            slhand >= ' 0'
FPR AC                             and slhand <= '99'
FPR AC                   eval      wkchar = slhand
FPR AC                   exsr      zzcvt2ltr
FPR AC                   eval      slhand = nwchar
FPR AC                   endif
FPR A
FPR AC                   select
FPR AC                   when      %subst(sidgtp:1:1) = 'L'
FPR AC                   eval      slside = 1
FPR A*
FPR AC                   when      %subst(sidgtp:1:1) = 'R'
FPR AC                   eval      slside = 0
FPR AC                   other
FPR A*
FPR AC     slloc         div       2             dummy
FPR AC                   mvr                     oddeven
FPR AC                   if        oddeven <> 0
FPR AC                   eval      slside = 1
FPR AC                   else
FPR AC                   eval      slside = 0
FPR AC                   endif
FPR A*
FPR AC                   endsl
FPR A
FPR A*    See if slot meets criteria for allowing it to be created.
FPR A
FPR AC                   select
FPR A
FPR A*    If non-special slot doesn't have hypens, then don't add it.
FPR A
FPR AC                   when      dashpos = 0
FPR AC                   eval      notcreated = *on
FPR AC                   goto      endcreate31
FPR A
FPR A*    Don't allow creation if department is unknown.
FPR A
FPR AC                   when      validdept = '*NO '
FPR AC                   eval      notcreated = *on
FPR AC                   goto      endcreate31
FPR A
FPR A*    If location or level is not numeric, then don't add.
FPR A
FPR AC                   when      locnotnum or lvlnotnum
FPR AC                   eval      notcreated = *on
FPR AC                   goto      endcreate31
FPR A
FPR A*    Otherwise, slot is ok to be created.
FPR A
FPR AC                   other
FPR AC                   eval      slwhdp = siwhdp
FPR AC                   eval      sldisp = sidisp
FPR AC                   eval      slstyp = sistyp
FPR A
FPR AC                   endsl
FPR A
FPR A*    Try and create the imported slot.
FPR A
FPR AC                   eval      slwhse = siwhse
FPR AC                   eval      slpseq = sipseq
FPR AC*
FPR AC                   select
FPR AC                   when      slpseq = 0
FPR AC                   eval      slpseq = slloc
FPR AC                   when      slpseq < 0
FPR AC                   eval      slpseq = slpseq * -1
FPR AC                   endsl
FPR AC                   if        slitem > ' '
FPR AC                   eval      slstat = 'A'
FPR AC                   else
FPR AC                   eval      slstat = 'V'
FPR AC                   endif
FPR A*
FPR AC                   eval      slrsrv = sirsrv
FPR A*
FPR AC                   if        %subst(sidgtp:2:1) > ' '
FPR3DC*                  eval      slsdef = %subst(sidgtp:2:1) + ' '
FPR3MC                   eval      slsdef = sidgtp
FPR AC                   else
FPR A*
FPR AC                   eval      slsdef = 'XX'
FPR AC                   endif
FPR A*
FPR AC                   eval      slpick = sipick
FPR A
FPR AC                   write (e) slrec
FPR AC                   if        %error
FPR AC                   eval      notcreated = *on
FPR AC                   endif
FPR A
FPR AC     endcreate31   endsr
CBIb
CBIbA*----------------------------------------------------------------
CBIbA*  crtslot32  Try and create physical slot. Cheney Pate Dawson.
CBIbA*----------------------------------------------------------------
CBIbA
CBIbAC     crtslot32     begsr
CBIbAC                   eval      notcreated = *off
CBIbA
CBIbA*  Turn on SlotCreated flag even if slot isn't created
CBIbA*  so ZZUPD routine doesn't get executed.
CBIbAC                   eval      slotcreated= *on
CBIbAC                   eval      handstack  = *off
CBIbAC                   clear                   slrec
CBIbA
CBIbA*  Extract location and level. Test if they are numeric.
CBIbA
CBIbAC                   eval      locnotnum = *off
CBIbAC                   eval      lvlnotnum = *off
CBIbAC                   eval      dashpos = 0
CBIbAC                   eval      loca  = ' '
CBIbAC                   eval      lvla  = ' '
CBIbA
CBIbA*  Check for all alpha slot. If no digits, default slot location
CBIbA*  will be assigned.
CBIbAC                   If            %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:7:1) >= '0'
CBIbAC                             and %subst(sidisp:7:1) <= '9'
CBIbAC                             and %subst(sidisp:8:1) >= '0'
CBIbAC                             and %subst(sidisp:8:1) <= '9'
CBIbA*
CBIbAC                             or  %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:7:1) >= 'A'
CBIbAC                             and %subst(sidisp:7:1) <= 'Z'
CBIbAC                             and %subst(sidisp:8:1) >= '0'
CBIbAC                             and %subst(sidisp:8:1) <= '9'
CBIdA*
CBIdAC                             or  %subst(sidisp:3:1) =  '-'
CBIdAC                             and %subst(sidisp:4:3) >= '000'
CBIdAC                             and %subst(sidisp:4:3) <= '999'
CBIdAC                             and %subst(sidisp:7:1) =  '-'
CBIdAC                             and %subst(sidisp:8:2) >= '00'
CBIdAC                             and %subst(sidisp:8:2) <= '99'
CBIbA*
CBIbAC                   eval      allchrslot = *off
CBIbAC                   else
CBIbAC                   eval      allchrslot = *on
CBIbAC                   endif
CBIbA
CBIbA
CBIbAC                   select
CBIbA
CBIbA*  No dashes specified. All character slot.
CBIbAC                   when      allchrslot = *on
CBIbAC
CBIbAC                   eval      kydisp = sidisp
CBIbAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CBIbAC
CBIbAC                   eval      dftlocation = dftlocation + 1
CBIbAC                   eval      loca   = %char(dftlocation)
CBIbAC                   eval      slloc  = dftlocation
CBIbAC
CBIbAC                   eval      slrlvl = 1
CBIbAC                   eval      lvla   = '1'
CBIbAC
CBIbAC                   eval      slhand  = '  '
CBIbAC                   eval      dashpos = -1
CBIbA
CBIbA*  Dashes specified. Double character aisle (Ex AC-64-B4)
CBIbAC                   when          %subst(sidisp:3:1)  = '-'
CBIbAC                             and %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:6:1)  = '-'
CBIbAC                             and (%subst(sidisp:7:1) >= '0'
CBIbAC                              and %subst(sidisp:7:1) <= '9'
CBIbAC                              or  %subst(sidisp:7:1) >= 'A'
CBIbAC                              and %subst(sidisp:7:1) <= 'Z')
CBIbAC                   eval      dashpos = -1
CBIbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CBIbA*
CBIbAC                   eval      loca  = '0' + %subst(sidisp:4:2)
CBIbAC                   move      loca          slloc
CBIbA*
CBIbA*      Convert alpha level into numeric value.
CBIbAC                   eval      lvla    = %subst(sidisp:7:1)
CBIbAC                   evalr     wkchar = %trimr(lvla)
CBIbAC                   exsr      zzcvt2nbr
CBIbAC                   if        nwchar > ' '
CBIbAC                   evalr     lvla   = %trimr(nwchar)
CBIbAC                   eval      slrlvl = %dec(nwchar:2:0)
CBIbAC                   else
CBIbAC                   evalr     lvla  = %subst(sidisp:7:1)
CBIbAC                   move      lvla          slrlvl
CBIbAC                   endif
CBIbAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CBIdA
CBIdA*  Dashes specified. Double character aisle (Ex 10-104-01)
CBIdAC                   when          %subst(sidisp:3:1)  = '-'
CBIdAC                             and %subst(sidisp:4:3) >= '000'
CBIdAC                             and %subst(sidisp:4:3) <= '999'
CBIdAC                             and %subst(sidisp:7:1)  = '-'
CBIdAC                             and (%subst(sidisp:8:2) >= '00'
CBIdAC                             and  %subst(sidisp:8:2) <= '09'
CBIdAC                              or  %subst(sidisp:7:1) >= 'A'
CBIdAC                              and %subst(sidisp:7:1) <= 'Z')
CBIdAC                   eval      dashpos = -1
CBIdAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CBIdA*
CBIdAC                   eval      loca  = %subst(sidisp:4:3)
CBIdAC                   move      loca          slloc
CBIdA*
CBIdAC                   evalr     lvlaa = %subst(sidisp:8:2)
CBIdAC                   move      lvlaa         slrlvl
CBIdA*
CBIdAC                   eval      slhand  = %subst(sidisp:10:2)
CBIbA
CBIbAC                   endsl
CBIbA
CBIbA*  Begin testing parts for ALL slots.
CBIbAC                   testn                   loca                 5050
CBIbAC                   if        *in50 = *off
CBIbAC                   eval      locnotnum = *on
CBIbA
CBIbAC                   else
CBIbAC                   select
CBIbAC                   when      slloc  = 0
CBIbAC**                 eval      slloc = slloc + 100
CBIbAC                   when      slloc < 0
CBIbAC                   eval      slloc = slloc * -1
CBIbAC                   endsl
CBIbAC                   endif
CBIbA
CBIdAC                   if        lvlaa > ' '
CBIdAC                   testn                   lvlaa                5050
CBIdAC                   else
CBIdA*
CBIbAC                   testn                   lvla                 50
CBIdAC                   endif
CBIdA*
CBIbAC                   if        *in50 = *off
CBIbAC                   eval      lvlnotnum = *on
CBIbAC                   else
CBIbAC                   select
CBIbAC                   when      slrlvl = 0
CBIbAC*                  eval      slrlvl = slrlvl + 1
CBIbAC                   when      slrlvl < 0
CBIbAC                   eval      slrlvl = slrlvl * -1
CBIbAC                   endsl
CBIbAC                   endif
CBIbA
CBIbA*    Convert numeric handstack to alpha character.
CBIbA
CBIbAC                   if            slhand >= ' 0'
CBIbAC                             and slhand <= '99'
CBIbAC                   eval      wkchar = slhand
CBIbAC                   exsr      zzcvt2ltr
CBIbAC                   eval      slhand = nwchar
CBIbAC                   endif
CBIbA*
CBIbAC     slloc         div       2             dummy
CBIbAC                   mvr                     oddeven
CBIbAC                   if        oddeven <> 0
CBIbAC                   eval      slside = 1
CBIbAC                   else
CBIbAC                   eval      slside = 0
CBIbAC                   endif
CBIbA
CBIbA*    See if slot meets criteria for allowing it to be created.
CBIbA
CBIbAC                   select
CBIbA
CBIbA*    If non-special slot doesn't have hypens, then don't add it.
CBIbA
CBIbAC                   when      dashpos = 0
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate32
CBIbA
CBIbA*    Don't allow creation if department is unknown.
CBIbA
CBIbAC                   when      validdept = '*NO '
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate32
CBIbA
CBIbA*    If location or level is not numeric, then don't add.
CBIbA
CBIbAC                   when      locnotnum or lvlnotnum
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate32
CBIbA
CBIbA*    Otherwise, slot is ok to be created.
CBIbA
CBIbAC                   other
CBIbAC                   eval      slwhdp = siwhdp
CBIbAC                   eval      sldisp = sidisp
CBIbAC                   eval      slstyp = sistyp
CBIbA
CBIbAC                   endsl
CBIbA
CBIbA*    Try and create the imported slot.
CBIbA
CBIbAC                   eval      slwhse = siwhse
CBIbAC                   eval      slpseq = sipseq
CBIbAC*
CBIbAC                   select
CBIbAC                   when      slpseq = 0
CBIbAC                   eval      slpseq = slloc
CBIbAC                   when      slpseq < 0
CBIbAC                   eval      slpseq = slpseq * -1
CBIbAC                   endsl
CBIbAC                   if        slitem > ' '
CBIbAC                   eval      slstat = 'A'
CBIbAC                   else
CBIbAC                   eval      slstat = 'V'
CBIbAC                   endif
CBIbA*
CBIbAC                   eval      slrsrv = sirsrv
CBIbA*
CBIbAC                   if        %subst(sidgtp:2:1) > ' '
CBIbAC                   eval      slsdef = %subst(sidgtp:2:1) + ' '
CBIbAC                   else
CBIbA*
CBIbAC                   eval      slsdef = 'XX'
CBIbAC                   endif
CBIbA*
CBIbAC                   eval      slpick = sipick
CBIbA
CBIbAC                   write (e) slrec
CBIbAC                   if        %error
CBIbAC                   eval      notcreated = *on
CBIbAC                   endif
CBIbA
CBIbAC     endcreate32   endsr
ADFaA
ADFaA*----------------------------------------------------------------
ADFaA*  crtslot33  Try and create physical slot. 5B107-3
ADFaA*----------------------------------------------------------------
ADFaA
ADFaAC     crtslot33     begsr
ADFaAC                   eval      notcreated = *off
ADFaA
ADFaA*  Turn on SlotCreated flag even if slot isn't created
ADFaA*  so ZZUPD routine doesn't get executed.
ADFaAC                   eval      slotcreated= *on
ADFaAC                   eval      handstack  = *off
ADFaAC                   clear                   slrec
ADFaA
ADFaA*  Extract location and level. Test if they are numeric.
ADFaA
ADFaAC                   eval      locnotnum = *off
ADFaAC                   eval      lvlnotnum = *off
ADFaAC                   eval      dashpos = 0
ADFaAC                   eval      loca  = ' '
ADFaAC                   eval      lvla  = ' '
ADFaA
ADFaA*  Check for all alpha slot. If no digits, default slot location
ADFaA*  will be assigned.
ADFaAC                   If            %subst(sidisp:3:3) >= '000'
ADFaAC                             and %subst(sidisp:3:3) <= '999'
ADFaAC                             and %subst(sidisp:6:1)  = '-'
ADFaAC                   eval      allchrslot = *off
ADFaAC                   else
ADFaAC                   eval      allchrslot = *on
ADFaAC                   endif
ADFaA
ADFaAC                   select
ADFaA
ADFaA*  No dashes specified. All character slot.
ADFaAC                   when      allchrslot = *on
ADFaAC
ADFaAC                   eval      kydisp = sidisp
ADFaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ADFaAC
ADFaAC                   eval      dftlocation = dftlocation + 1
ADFaAC                   eval      loca   = %char(dftlocation)
ADFaAC                   eval      slloc  = dftlocation
ADFaAC
ADFaAC                   eval      slrlvl = 1
ADFaAC                   eval      lvla   = '1'
ADFaAC
ADFaAC                   eval      slhand  = '  '
ADFaAC                   eval      dashpos = -1
ADFaA
ADFaA*  Dashes specified. Double character aisle (Ex 5B107-3)
ADFaAC                   when          %subst(sidisp:6:1) = '-'
ADFaAC                             and %subst(sidisp:3:3) >= '000'
ADFaAC                             and %subst(sidisp:3:3) <= '999'
ADFaAC                             and %subst(sidisp:7:1) >= '0'
ADFaAC                             and %subst(sidisp:7:1) <= '9'
ADFaAC                   eval      dashpos = -1
ADFaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
ADFaAC                   eval      loca  = %subst(sidisp:3:3)
ADFaAC                   move      loca          slloc
ADFaA*
ADFaAC                   evalr     lvla  = %subst(sidisp:7:1)
ADFaAC                   move      lvla          slrlvl
ADFaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
ADFaA
ADFaAC                   endsl
ADFaA
ADFaA*  Begin testing parts for ALL slots.
ADFaAC                   testn                   loca                 5050
ADFaAC                   if        *in50 = *off
ADFaAC                   eval      locnotnum = *on
ADFaA
ADFaAC                   else
ADFaAC                   select
ADFaAC                   when      slloc  = 0
ADFaAC                   eval      slloc = slloc + 100
ADFaAC                   when      slloc < 0
ADFaAC                   eval      slloc = slloc * -1
ADFaAC                   endsl
ADFaAC                   endif
ADFaA
ADFaAC                   testn                   lvla                 50
ADFaAC                   if        *in50 = *off
ADFaAC                   eval      lvlnotnum = *on
ADFaAC                   else
ADFaAC                   select
ADFaAC                   when      slrlvl = 0
ADFaAC                   eval      slrlvl = slrlvl + 1
ADFaAC                   when      slrlvl < 0
ADFaAC                   eval      slrlvl = slrlvl * -1
ADFaAC                   endsl
ADFaAC                   endif
ADFaA
ADFaA*    Convert numeric handstack to alpha character.
ADFaA
ADFaAC                   if            slhand >= ' 0'
ADFaAC                             and slhand <= '99'
ADFaAC                   eval      wkchar = slhand
ADFaAC                   exsr      zzcvt2ltr
ADFaAC                   eval      slhand = nwchar
ADFaAC                   endif
ADFaA
ADFaAC     slloc         div       2             dummy
ADFaAC                   mvr                     oddeven
ADFaAC                   if        oddeven <> 0
ADFaAC                   eval      slside = 1
ADFaAC                   else
ADFaAC                   eval      slside = 0
ADFaAC                   endif
ADFaA
ADFaA*    See if slot meets criteria for allowing it to be created.
ADFaA
ADFaAC                   select
ADFaA
ADFaA*    If non-special slot doesn't have hypens, then don't add it.
ADFaA
ADFaAC                   when      dashpos = 0
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    Don't allow creation if department is unknown.
ADFaA
ADFaAC                   when      validdept = '*NO '
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    If location or level is not numeric, then don't add.
ADFaA
ADFaAC                   when      locnotnum or lvlnotnum
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    Otherwise, slot is ok to be created.
ADFaA
ADFaAC                   other
ADFaAC                   eval      slwhdp = siwhdp
ADFaAC                   eval      sldisp = sidisp
ADFaAC                   eval      slstyp = sistyp
ADFaA
ADFaAC                   endsl
ADFaA
ADFaA*    Try and create the imported slot.
ADFaA
ADFaAC                   eval      slwhse = siwhse
ADFaAC                   eval      slpseq = sipseq
ADFaAC*
ADFaAC                   select
ADFaAC                   when      slpseq = 0
ADFaAC                   eval      slpseq = slloc
ADFaAC                   when      slpseq < 0
ADFaAC                   eval      slpseq = slpseq * -1
ADFaAC                   endsl
ADFaAC                   if        slitem > ' '
ADFaAC                   eval      slstat = 'A'
ADFaAC                   else
ADFaAC                   eval      slstat = 'V'
ADFaAC                   endif
ADFaA*
ADFaAC                   eval      slrsrv = sirsrv
ADFaAC                   eval      slsdef = 'XX'
ADFaAC                   eval      slpick = sipick
ADFaA
ADFaAC                   write (e) slrec
ADFaAC                   if        %error
ADFaAC                   eval      notcreated = *on
ADFaAC                   endif
ADFaA
ADFaAC     endcreate33   endsr
ADFa

KHLaA*----------------------------------------------------------------
KHLaA*  crtslot34  Try and create physical slot.
KHLaA*----------------------------------------------------------------
KHLaA
KHLaAC     crtslot34     begsr
KHLaAC                   eval      notcreated = *off
KHLaA
KHLaA*  Turn on SlotCreated flag even if slot isn't created
KHLaA*  so ZZUPD routine doesn't get executed.
KHLaAC                   eval      slotcreated= *on
KHLaAC                   eval      handstack  = *off
KHLaAC                   clear                   slrec
KHLaA
KHLaA*  Extract location and level. Test if they are numeric.
KHLaA
KHLaAC                   eval      locnotnum = *off
KHLaAC                   eval      lvlnotnum = *off
KHLaAC                   eval      dashpos = 0
KHLaAC                   eval      loca  = ' '
KHLaAC                   eval      lvla  = ' '
KHLaA
KHLaA*  Check for all alpha slot. If no digits, default slot location
KHLaA*  will be assigned.
KHLaAC                   If            %subst(sidisp:2:2) >= '00'
KHLaAC                             and %subst(sidisp:2:2) <= '99'
KHLaAC                             or  %subst(sidisp:3:2) >= '00'
KHLaAC                             and %subst(sidisp:3:2) <= '99'
KHLaAC                   eval      allchrslot = *off
KHLaAC                   else
KHLaAC                   eval      allchrslot = *on
KHLaAC                   endif
KHLaA
KHLaAC                   select
KHLaA
KHLaA*  No Dashes specified. Single character aisle
KHLaAC                   when          %subst(sidisp:2:2) >= '00'
KHLaAC                             and %subst(sidisp:2:2) <= '99'
KHLaAC                   eval      dashpos = -1
KHLaAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
KHLaAC                   eval      loca  = '0' + %subst(sidisp:2:2)
KHLaAC                   move      loca          slloc
KHLaAC                   eval      lvla  = %subst(sidisp:4:1)
KHLaAC                   move      lvla          slrlvl
KHLaAC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
KHLaAC                   if        slhand > ' '
KHLaAC*                  eval      handstack = *on
KHLaAC                   endif
KHLaA
KHLaA*  No Dashes specified. Double character aisle
KHLaAC                   when          %subst(sidisp:3:2) >= '00'
KHLaAC                             and %subst(sidisp:3:2) <= '99'
KHLaAC                   eval      dashpos = -1
KHLaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KHLaAC                   eval      loca  = '00' + %subst(sidisp:3:1)
KHLaAC                   move      loca          slloc
KHLaAC                   eval      lvla  = %subst(sidisp:4:1)
KHLaAC                   move      lvla          slrlvl
KHLaAC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
KHLaAC                   if        slhand > ' '
KHLaAC*                  eval      handstack = *on
KHLaAC                   endif
KHLaA
KHLaA*  No dashes specified. All character slot.
KHLaAC                   when      allchrslot = *on
KHLaAC
KHLaAC                   eval      kydisp = sidisp
KHLaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:1))
KHLaAC
KHLaAC                   if        dftlocation < 999
KHLaAC                   eval      dftlocation = dftlocation + 1
KHLaAC                   endif
KHLaAC                   eval      loca   = %char(dftlocation)
KHLaAC                   eval      slloc  = dftlocation
KHLaAC
KHLaAC                   eval      slrlvl = 1
KHLaAC                   eval      lvla   = '1'
KHLaAC
KHLaAC                   eval      slhand  = '  '
KHLaAC                   eval      dashpos = -1
KHLaA
KHLaAC                   endsl
KHLaA
KHLaA*  Begin testing parts for ALL slots.
KHLaAC                   testn                   loca                 5050
KHLaAC                   if        *in50 = *off
KHLaAC                   eval      locnotnum = *on
KHLaA
KHLaAC                   else
KHLaAC                   select
KHLaAC                   when      slloc  = 0
KHLaAC                   eval      slloc = slloc + 100
KHLaAC                   when      slloc < 0
KHLaAC                   eval      slloc = slloc * -1
KHLaAC                   endsl
KHLaAC                   endif
KHLaA
KHLaAC                   testn                   lvla                 50
KHLaAC                   if        *in50 = *off
KHLaAC                   eval      lvlnotnum = *on
KHLaAC                   else
KHLaAC                   select
KHLaAC                   when      slrlvl = 0
KHLaAC                   eval      slrlvl = slrlvl + 10
KHLaAC                   when      slrlvl < 0
KHLaAC                   eval      slrlvl = slrlvl * -1
KHLaAC                   endsl
KHLaAC                   endif
KHLaA
KHLaA*    Convert numeric handstack to alpha character.
KHLaA
KHLaAC                   if            slhand >= ' 0'
KHLaAC                             and slhand <= '99'
KHLaAC                   eval      wkchar = slhand
KHLaAC                   exsr      zzcvt2ltr
KHLaAC                   eval      slhand = nwchar
KHLaAC                   endif
KHLaA
KHLaAC                   eval      loca_x  = ' '
KHLaAC                   evalr     loca_x  = %trimr(%subst(sidisp:2:2))
KHLaAC                   move (p)  loca_x        loc2_3
KHLaMC     loc2_3        div       2             dummy
KHLaAC                   mvr                     oddeven
KHLaAC                   if        oddeven <> 0
KHLaAC                   eval      slside = 1
KHLaAC                   else
KHLaAC                   eval      slside = 0
KHLaAC                   endif
KHLaA*
KHLaA*    Check if base slot exists for imported slot with handstacks.
KHLaA*
KHLaAC                   eval      crtbaseslot = *off
KHLaAC                   if        handstack = *on
KHLaAC     keysl2b       setll     slot2
KHLaAC                   if        not %equal(slot2)
KHLaAC                   eval      crtbaseslot = *on
KHLaAC                   endif
KHLaAC                   endif
KHLaA
KHLaA*    See if slot meets criteria for allowing it to be created.
KHLaA
KHLaAC                   select
KHLaA
KHLaA*    If non-special slot doesn't have hypens, then don't add it.
KHLaA
KHLaAC                   when      dashpos = 0
KHLaAC                   eval      notcreated = *on
KHLaAC                   goto      endcreate34
KHLaA
KHLaA*    Don't allow creation if department is unknown.
KHLaA
KHLaAC                   when      validdept = '*NO '
KHLaAC                   eval      notcreated = *on
KHLaAC                   goto      endcreate34
KHLaA
KHLaA*    Skip Dept 5 slots if weren't corrected earlier.
KHLaA
KHLaAC                   when      siwhdp = '5   '
KHLaAC                   eval      notcreated = *on
KHLaAC                   goto      endcreate34
KHLaA
KHLaA*    If location or level is not numeric, then don't add.
KHLaA
KHLaAC                   when      locnotnum or lvlnotnum
KHLaAC                   eval      notcreated = *on
KHLaAC                   goto      endcreate34
KHLaA
KHLaA*    Otherwise, slot is ok to be created.
KHLaA
KHLaAC                   other
KHLaAC                   eval      slwhdp = siwhdp
KHLaAC                   eval      sldisp = sidisp
KHLaAC                   eval      slstyp = sistyp
KHLaA
KHLaAC                   endsl
KHLaA
KHLaA*    Try and create the Base slot.
KHLaA
KHLaAC                   if        crtbaseslot = *on
KHLaA*    Save handstack for virtual slot.
KHLaAC                   eval      svhand = slhand
KHLaA
KHLaAC                   eval      slwhse = siwhse
KHLaAC                   eval      sldisp = kydisp
KHLaAC                   eval      slpseq = sipseq
KHLaAC                   select
KHLaAC                   when      slpseq = 0
KHLaAC                   eval      slpseq = slloc
KHLaAC                   when      slpseq < 0
KHLaAC                   eval      slpseq = slpseq * -1
KHLaAC                   endsl
KHLaAC                   eval      slstat = 'V '
KHLaAC                   eval      slhand = '  '
KHLaAC                   eval      slrsrv = sirsrv
KHLaAC                   eval      slsdef = 'XX'
KHLaAC                   eval      slpick = sipick
KHLaA
KHLaAC                   write (e) slrec
KHLaAC                   if        %error
KHLaAC                   eval      notcreated = *on
KHLaAC                   endif
KHLaA*
KHLaAC                   endif
KHLaA
KHLaA*    Try and create the imported slot.
KHLaA
KHLaAC                   eval      slwhse = siwhse
KHLaA*
KHLaA*    Replace base slot display, handstack w/ imported fields.
KHLaAC                   if        crtbaseslot = *on
KHLaAC                   eval      slhand = svhand
KHLaAC                   eval      sldisp = sidisp
KHLaAC                   endif
KHLaA*
KHLaAC                   eval      slpseq = sipseq
KHLaAC*
KHLaAC                   eval      pseq4 = %subst(sidisp:2:4)
KHLaAC     digits        check     pseq4                                  68
KHLaAC                   if        *in68 = *off
KHLaAC                   move      pseq4         slpseq
KHLaAC                   endif
KHLaAC*
KHLaAC                   select
KHLaAC                   when      slpseq = 0
KHLaAC                   eval      slpseq = slloc
KHLaAC                   when      slpseq < 0
KHLaAC                   eval      slpseq = slpseq * -1
KHLaAC                   endsl
KHLaAC                   if        slitem > ' '
KHLaAC                   eval      slstat = 'A'
KHLaAC                   else
KHLaAC                   eval      slstat = 'V'
KHLaAC                   endif
KHLaA*
KHLaA*    Slot has handstack, create as virtual slot.
KHLaAC                   if        handstack = *on
KHLaAC                   eval      slrsrv = 'V'
KHLaAC                   else
KHLaAC                   eval      slrsrv = sirsrv
KHLaAC                   endif
KHLaAC                   eval      slsdef = 'XX'
KHLaAC                   eval      slpick = sipick
KHLaA
KHLaAC                   write (e) slrec
KHLaAC                   if        %error
KHLaAC                   eval      notcreated = *on
KHLaAC                   endif
KHLaA
KHLaA*    Create Virtual slot record.
KHLaA
KHLaAC                   if        handstack = *on
KHLaAC                   eval      vswhse = slwhse
KHLaAC                   eval      vswhdp = slwhdp
KHLaAC                   eval      vsaisl = slaisl
KHLaAC                   eval      vsloc  = slloc
KHLaAC                   eval      vsrlvl = slrlvl
KHLaAC                   eval      vshand = slhand
KHLaAC                   eval      vsdisp = sldisp
KHLaAC                   eval      vspdis = kydisp
KHLaAC                   eval      vscdte = impdte
KHLaAC                   eval      vsctim = imptim
KHLaAC                   add       1             vsctim
KHLaAC                   write (e) vsrec
KHLaAC                   if        %error
KHLaAC                   eval      error  = *on
KHLaAC                   eval      detmsg = desc(8)
KHLaAC                   add       1             notcrt
KHLaAC                   goto      endcreate34
KHLaAC                   endif
KHLaA
KHLaAC                   endif
KHLaA
KHLaAC     endcreate34   endsr
SOFbA*----------------------------------------------------------------
SOFbA*  crtslot35  Try and create physical slot. 80124A1  Sofo Foods
SOFbA*----------------------------------------------------------------
SOFbA
SOFbAC     crtslot35     begsr
SOFbAC                   eval      notcreated = *off
SOFbA
SOFbA*  Turn on SlotCreated flag even if slot isn't created
SOFbA*  so ZZUPD routine doesn't get executed.
SOFbAC                   eval      slotcreated= *on
SOFbAC                   eval      handstack  = *off
SOFbAC                   clear                   slrec
SOFbA
SOFbA*  Extract location and level. Test if they are numeric.
SOFbA
SOFbAC                   eval      locnotnum = *off
SOFbAC                   eval      lvlnotnum = *off
SOFbAC                   eval      dashpos = 0
SOFbAC                   eval      loca  = ' '
SOFbAC                   eval      lvla  = ' '
SOFbA
SOFbA*  Check for all alpha slot. If no digits, default slot location
SOFbA*  will be assigned.
SOFbAC                   If            %subst(sidisp:3:3) >= '000'
SOFbAC                             and %subst(sidisp:3:3) <= '999'
SOFbAC                             and %subst(sidisp:6:1)  = '-'
SOFbA*       Ohio slots.
SOFbAC                             or  %subst(sidisp:1:2) >= '00'
SOFbAC                             and %subst(sidisp:1:2) <= '99'
SOFbAC                             and %subst(sidisp:3:3) >= '000'
SOFbAC                             and %subst(sidisp:3:3) <= '999'
SOFbAC                             and %subst(sidisp:7:1) >= '0'
SOFbAC                             and %subst(sidisp:7:1) <= '9'
SOFbA*
SOFbAC                   eval      allchrslot = *off
SOFbAC                   else
SOFbAC                   eval      allchrslot = *on
SOFbAC                   endif
SOFbA
SOFbAC                   select
SOFbA
SOFbA*  No dashes specified. All character slot.
SOFbAC                   when      allchrslot = *on
SOFbAC
SOFbAC                   eval      kydisp = sidisp
SOFbAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
SOFbAC
SOFbAC                   eval      dftlocation = dftlocation + 1
SOFbAC                   eval      loca   = %char(dftlocation)
SOFbAC                   eval      slloc  = dftlocation
SOFbAC
SOFbAC                   eval      slrlvl = 1
SOFbAC                   eval      lvla   = '1'
SOFbAC
SOFbAC                   eval      slhand  = '  '
SOFbAC                   eval      dashpos = -1
SOFbA
SOFbA*  No Dashes specified. Double character aisle (Ex 80124A1)
SOFbAC                   when          %subst(sidisp:1:2) >= '00'
SOFbAC                             and %subst(sidisp:1:2) <= '99'
SOFbAC                             and %subst(sidisp:3:3) >= '000'
SOFbAC                             and %subst(sidisp:3:3) <= '999'
SOFdAC                             and %subst(sidisp:6:1) >= 'A'
SOFdAC                             and %subst(sidisp:6:1) <= 'Z'
SOFbAC                             and %subst(sidisp:7:1) >= '0'
SOFbAC                             and %subst(sidisp:7:1) <= '9'
SOFbAC                   eval      dashpos = -1
SOFbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SOFbAC                   eval      loca  = %subst(sidisp:3:3)
SOFbAC                   move      loca          slloc
SOFbA*
SOFbA*      Convert alpha level into numeric value.
SOFbAC                   eval      lvla    = %subst(sidisp:6:1)
SOFbAC                   evalr     wkchar = %trimr(lvla)
SOFbAC                   exsr      zzcvt2nbr
SOFbAC                   if        nwchar > ' '
SOFbAC                   evalr     lvla   = %trimr(nwchar)
SOFbAC                   eval      slrlvl = %dec(nwchar:2:0)
SOFbAC                   else
SOFbAC                   evalr     lvla  = %subst(sidisp:6:1)
SOFbAC                   move      lvla          slrlvl
SOFbAC                   endif
SOFbA*
SOFbAC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
SOFbA
SOFbA
SOFbA*  Dashes specified. Double character aisle (Ex 5B107-3)
SOFbAC                   when          %subst(sidisp:6:1) = '-'
SOFbAC                             and %subst(sidisp:3:3) >= '000'
SOFbAC                             and %subst(sidisp:3:3) <= '999'
SOFbAC                             and %subst(sidisp:7:1) >= '0'
SOFbAC                             and %subst(sidisp:7:1) <= '9'
SOFbAC                   eval      dashpos = -1
SOFbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SOFbAC                   eval      loca  = %subst(sidisp:3:3)
SOFbAC                   move      loca          slloc
SOFbA*
SOFbAC                   evalr     lvla  = %subst(sidisp:7:1)
SOFbAC                   move      lvla          slrlvl
SOFbAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
SOFbA
SOFbAC                   endsl
SOFbA
SOFbA*  Begin testing parts for ALL slots.
SOFbAC                   testn                   loca                 5050
SOFbAC                   if        *in50 = *off
SOFbAC                   eval      locnotnum = *on
SOFbA
SOFbAC                   else
SOFbAC                   select
SOFbAC                   when      slloc  = 0
SOFbAC                   eval      slloc = slloc + 100
SOFbAC                   when      slloc < 0
SOFbAC                   eval      slloc = slloc * -1
SOFbAC                   endsl
SOFbAC                   endif
SOFbA
SOFbAC                   testn                   lvla                 50
SOFbAC                   if        *in50 = *off
SOFbAC                   eval      lvlnotnum = *on
SOFbAC                   else
SOFbAC                   select
SOFbAC                   when      slrlvl = 0
SOFbAC                   eval      slrlvl = slrlvl + 1
SOFbAC                   when      slrlvl < 0
SOFbAC                   eval      slrlvl = slrlvl * -1
SOFbAC                   endsl
SOFbAC                   endif
SOFbA
SOFbA*    Convert numeric handstack to alpha character.
SOFbA
SOFbAC                   if            slhand >= ' 0'
SOFbAC                             and slhand <= '99'
SOFbAC                   eval      wkchar = slhand
SOFbAC                   exsr      zzcvt2ltr
SOFbAC                   eval      slhand = nwchar
SOFbAC                   endif
SOFbA
SOFbAC     slloc         div       2             dummy
SOFbAC                   mvr                     oddeven
SOFbAC                   if        oddeven <> 0
SOFbAC                   eval      slside = 1
SOFbAC                   else
SOFbAC                   eval      slside = 0
SOFbAC                   endif
SOFbA
SOFbA*    See if slot meets criteria for allowing it to be created.
SOFbA
SOFbAC                   select
SOFbA
SOFbA*    If non-special slot doesn't have hypens, then don't add it.
SOFbA
SOFbAC                   when      dashpos = 0
SOFbAC                   eval      notcreated = *on
SOFbAC                   goto      endcreate35
SOFbA
SOFbA*    Don't allow creation if department is unknown.
SOFbA
SOFbAC                   when      validdept = '*NO '
SOFbAC                   eval      notcreated = *on
SOFbAC                   goto      endcreate35
SOFbA
SOFbA*    If location or level is not numeric, then don't add.
SOFbA
SOFbAC                   when      locnotnum or lvlnotnum
SOFbAC                   eval      notcreated = *on
SOFbAC                   goto      endcreate35
SOFbA
SOFbA*    Otherwise, slot is ok to be created.
SOFbA
SOFbAC                   other
SOFbAC                   eval      slwhdp = siwhdp
SOFbAC                   eval      sldisp = sidisp
SOFbAC                   eval      slstyp = sistyp
SOFbA
SOFbAC                   endsl
SOFbA
SOFbA*    Try and create the imported slot.
SOFbA
SOFbAC                   eval      slwhse = siwhse
SOFbAC                   eval      slpseq = sipseq
SOFbAC*
SOFbAC                   select
SOFbAC                   when      slpseq = 0
SOFbAC                   eval      slpseq = slloc
SOFbAC                   when      slpseq < 0
SOFbAC                   eval      slpseq = slpseq * -1
SOFbAC                   endsl
SOFbAC                   if        slitem > ' '
SOFbAC                   eval      slstat = 'A'
SOFbAC                   else
SOFbAC                   eval      slstat = 'V'
SOFbAC                   endif
SOFbA*
SOFbAC                   eval      slrsrv = sirsrv
SOFbAC                   if        sidgtp > ' '
SOFbAC                   eval      slsdef = sidgtp
SOFbAC                   else
SOFbAC                   eval      slsdef = 'XX'
SOFbAC                   endif
SOFbAC                   eval      slpick = sipick
SOFbA
SOFbAC                   write (e) slrec
SOFbAC                   if        %error
SOFbAC                   eval      notcreated = *on
SOFbAC                   endif
SOFbA
SOFbAC     endcreate35   endsr
SOFbA
SFPaA*----------------------------------------------------------------
SFPaA*  crtslot36  Try and create physical slot. Ex: 10-10-AB
SFPaA*----------------------------------------------------------------
SFPaA
SFPaAC     crtslot36     begsr
SFPaAC                   eval      notcreated = *off
SFPaA
SFPaA*  Turn on SlotCreated flag even if slot isn't created
SFPaA*  so ZZUPD routine doesn't get executed.
SFPaAC                   eval      slotcreated= *on
SFPaAC                   eval      handstack  = *off
SFPaAC                   clear                   slrec
SFPaA
SFPaA*  Extract location and level. Test if they are numeric.
SFPaA
SFPaAC                   eval      locnotnum = *off
SFPaAC                   eval      lvlnotnum = *off
SFPaAC                   eval      dashpos = 0
SFPaAC                   eval      loca  = ' '
SFPaAC                   eval      lvla  = ' '
SFPaA
SFPaA*  Check for all alpha slot. If no digits, default slot location
SFPaA*  will be assigned.
SFPaAC                   If            %subst(sidisp:4:2) >= '00'
SFPaAC                             and %subst(sidisp:4:2) <= '99'
SFPaAC                             and %subst(sidisp:3:1)  = '-'
SFPaAC                             and %subst(sidisp:6:1)  = '-'
SFPaAC                   eval      allchrslot = *off
SFPaAC                   else
SFPaAC                   eval      allchrslot = *on
SFPaAC                   endif
SFPaA
SFPaAC                   select
SFPaA
SFPaA*  No dashes specified. All character slot.
SFPaAC                   when      allchrslot = *on
SFPaAC
SFPaAC                   eval      kydisp = sidisp
SFPaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
SFPaAC
SFPaAC                   eval      dftlocation = dftlocation + 1
SFPaAC                   eval      loca   = %char(dftlocation)
SFPaAC                   eval      slloc  = dftlocation
SFPaAC
SFPaAC                   eval      slrlvl = 1
SFPaAC                   eval      lvla   = '1'
SFPaAC
SFPaAC                   eval      slhand  = '  '
SFPaAC                   eval      dashpos = -1
SFPaA
SFPaA*  Dashes specified. Double character aisle (Ex CA-172-A)
SFPaAC                   when          %subst(sidisp:3:1) = '-'
SFPaAC                             and %subst(sidisp:4:2) >= '00'
SFPaAC                             and %subst(sidisp:4:2) <= '99'
SFPaAC                             and %subst(sidisp:6:1)  = '-'
SFPaAC                             and %subst(sidisp:7:1) >= 'A'
SFPaAC                             and %subst(sidisp:8:1) <= 'Z'
SFPaAC                   eval      dashpos = -1
SFPaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SFPaAC                   eval      loca  = '0' + %subst(sidisp:4:2)
SFPaAC                   move      loca          slloc
SFPaA*
SFPaA*      Convert alpha level into numeric value.
SFPaAC                   eval      lvla    = %subst(sidisp:7:1)
SFPaAC                   evalr     wkchar = %trimr(lvla)
SFPaAC                   exsr      zzcvt2nbr
SFPaAC                   if        nwchar > ' '
SFPaAC                   evalr     lvla   = %trimr(nwchar)
SFPaAC                   eval      slrlvl = %dec(nwchar:2:0)
SFPaAC                   else
SFPaAC                   evalr     lvla  = %subst(sidisp:7:1)
SFPaAC                   move      lvla          slrlvl
SFPaAC                   eval      slrlvl = slrlvl + 3
SFPaAC                   endif
SFPaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
SFPaA
SFPaAC                   endsl
SFPaA
SFPaA*  Begin testing parts for ALL slots.
SFPaAC                   testn                   loca                 5050
SFPaAC                   if        *in50 = *off
SFPaAC                   eval      locnotnum = *on
SFPaA
SFPaAC                   else
SFPaAC                   select
SFPaAC                   when      slloc  = 0
SFPaAC                   eval      slloc = slloc + 100
SFPaAC                   when      slloc < 0
SFPaAC                   eval      slloc = slloc * -1
SFPaAC                   endsl
SFPaAC                   endif
SFPaA
SFPaAC                   testn                   lvla                 50
SFPaAC                   if        *in50 = *off
SFPaAC                   eval      lvlnotnum = *on
SFPaAC                   else
SFPaAC                   select
SFPaAC                   when      slrlvl = 0
SFPaAC                   eval      slrlvl = slrlvl + 1
SFPaAC                   when      slrlvl < 0
SFPaAC                   eval      slrlvl = slrlvl * -1
SFPaAC                   endsl
SFPaAC                   endif
SFPaA
SFPaA*    Convert numeric handstack to alpha character.
SFPaA
SFPaAC                   if            slhand >= ' 0'
SFPaAC                             and slhand <= '99'
SFPaAC                   eval      wkchar = slhand
SFPaAC                   exsr      zzcvt2ltr
SFPaAC                   eval      slhand = nwchar
SFPaAC                   endif
SFPaA
SFPaAC     slloc         div       2             dummy
SFPaAC                   mvr                     oddeven
SFPaAC                   if        oddeven <> 0
SFPaAC                   eval      slside = 1
SFPaAC                   else
SFPaAC                   eval      slside = 0
SFPaAC                   endif
SFPaA
SFPaA*    See if slot meets criteria for allowing it to be created.
SFPaA
SFPaAC                   select
SFPaA
SFPaA*    If non-special slot doesn't have hypens, then don't add it.
SFPaA
SFPaAC                   when      dashpos = 0
SFPaAC                   eval      notcreated = *on
SFPaAC                   goto      endcreate36
SFPaA
SFPaA*    Don't allow creation if department is unknown.
SFPaA
SFPaAC                   when      validdept = '*NO '
SFPaAC                   eval      notcreated = *on
SFPaAC                   goto      endcreate36
SFPaA
SFPaA*    If location or level is not numeric, then don't add.
SFPaA
SFPaAC                   when      locnotnum or lvlnotnum
SFPaAC                   eval      notcreated = *on
SFPaAC                   goto      endcreate36
SFPaA
SFPaA*    Otherwise, slot is ok to be created.
SFPaA
SFPaAC                   other
SFPaAC                   eval      slwhdp = siwhdp
SFPaAC                   eval      sldisp = sidisp
SFPaAC                   eval      slstyp = sistyp
SFPaA
SFPaAC                   endsl
SFPaA
SFPaA*    Try and create the imported slot.
SFPaA
SFPaAC                   eval      slwhse = siwhse
SFPaAC                   eval      slpseq = sipseq
SFPaAC*
SFPaAC                   select
SFPaAC                   when      slpseq = 0
SFPaAC                   eval      slpseq = slloc
SFPaAC                   when      slpseq < 0
SFPaAC                   eval      slpseq = slpseq * -1
SFPaAC                   endsl
SFPaAC                   if        slitem > ' '
SFPaAC                   eval      slstat = 'A'
SFPaAC                   else
SFPaAC                   eval      slstat = 'V'
SFPaAC                   endif
SFPaA*
SFPaAC                   eval      slrsrv = sirsrv
SFPaAC                   eval      slsdef = 'XX'
SFPaAC                   eval      slpick = sipick
SFPaA
SFPaAC                   write (e) slrec
SFPaAC                   if        %error
SFPaAC                   eval      notcreated = *on
SFPaAC                   endif
SFPaA
SFPaAC     endcreate36   endsr
SFPaA
KFSaA*----------------------------------------------------------------
KFSaA*  crtslotKfs  Try and create physical slot. See KFSa comment.
KFSaA*----------------------------------------------------------------
KFSaA /free
KFSaA    begsr crtslotKfs;
KFSaA
KFSaA      // reset flags and work fields
KFSaA      slotcreated= *on;
KFSaA      notcreated = *off;
KFSaA      handstack  = *off;
KFSaA      clear slrec;
KFSaA      locnotnum = *off;
KFSaA      lvlnotnum = *off;
KFSaA      dashpos = 0;
KFSaA      loca  = ' ';
KFSaA      lvla  = ' ';
KFSaA
KFSaA      // check slot format
KFSaA      select;
KFSaA
KFSaA        // format: 99-999-1A
KFSaA        when %subst(sidisp:3:1) = '-'
KFSaA         and %subst(sidisp:7:1) = '-';
KFSaA          dashpos = -1;
KFSaA          slaisl = ' ' + %subst(sidisp:1:2);
KFSaA          loca = %subst(sidisp:4:3);
KFSaA          monitor;
KFSaA            slloc = %dec(loca:3:0);
KFSaA          on-error;
KFSaA            slloc = 0;
KFSaA            locnotnum = *on;
KFSaA          endmon;
KFSaA          lvla  = %subst(sidisp:8:1);
KFSaA          monitor;
KFSaA            slrlvl = %dec(lvla:1:0);
KFSaA          on-error;
KFSaA            slrlvl = 1;
KFSaA          endmon;
KFSaA          slhand = %subst(sidisp:9:1);
KFSaA
KFSaA        // format: 999-999-1A
KFSaA        when %subst(sidisp:4:1) = '-'
KFSaA         and %subst(sidisp:8:1) = '-';
KFSaA          dashpos = -1;
KFSaA          slaisl = %subst(sidisp:1:3);
KFSaA          loca = %subst(sidisp:5:3);
KFSaA          monitor;
KFSaA            slloc = %dec(loca:3:0);
KFSaA          on-error;
KFSaA            slloc = 0;
KFSaA            locnotnum = *on;
KFSaA          endmon;
KFSaA          lvla  = %subst(sidisp:9:1);
KFSaA          monitor;
KFSaA            slrlvl = %dec(lvla:1:0);
KFSaA          on-error;
KFSaA            slrlvl = 1;
KFSaA          endmon;
KFSaA          slhand = %subst(sidisp:10:1);
KFSaA
KFSaA        // format: 99-99-1A
KFSaA        when %subst(sidisp:3:1) = '-'
KFSaA         and %subst(sidisp:6:1) = '-';
KFSaA          dashpos = -1;
KFSaA          slaisl = ' ' + %subst(sidisp:1:2);
KFSaA          loca = '0' + %subst(sidisp:4:2);
KFSaA          monitor;
KFSaA            slloc = %dec(loca:3:0);
KFSaA          on-error;
KFSaA            slloc = 0;
KFSaA            locnotnum = *on;
KFSaA          endmon;
KFSaA          lvla  = %subst(sidisp:7:1);
KFSaA          monitor;
KFSaA            slrlvl = %dec(lvla:1:0);
KFSaA          on-error;
KFSaA            slrlvl = 1;
KFSaA          endmon;
KFSaA          slhand = %subst(sidisp:8:1);
KFSaA
KFSaA        // Unknown Format
KFSaA        other;
KFSaA      endsl;
KFSaA
KFSaA /end-free
KFSaAC     slloc         div       2             dummy
KFSaAC                   mvr                     oddeven
KFSaA /free
KFSaA      if oddeven <> 0;
KFSaA        slside = 1;
KFSaA      else;
KFSaA        slside = 0;
KFSaA      endif;
KFSaA
KFSaA      // See if slot meets criteria for allowing it to be created.
KFSaA      select;
KFSaA        // Don't allow creation if department is unknown.
KFSaA        when validdept = '*NO ';
KFSaA          notcreated = *on;
KFSaA        // If location or level is not numeric, then don't add.
KFSaA        when locnotnum or lvlnotnum;
KFSaA          notcreated = *on;
KFSaA        // Otherwise, slot is ok to be created.
KFSaA        other;
KFSaA          notcreated = *off;
KFSaA          slwhdp = siwhdp;
KFSaA          sldisp = sidisp;
KFSaA          slstyp = sistyp;
KFSaA      endsl;
KFSaA
KFSaA      // Try and create the imported slot.
KFSaA      if notcreated = *off;
KFSaA
KFSaA        slwhse = siwhse;
KFSaA        slpseq = sipseq;
KFSaA        select;
KFSaA          when slpseq = 0;
KFSaA            slpseq = slloc;
KFSaA          when slpseq < 0;
KFSaA            slpseq = slpseq * -1;
KFSaA        endsl;
KFSaA        slstat = 'V';
KFSaA        slsdef = 'XX';
KFSaA        slpick = sipick;
KFSaA        slrsrv = sirsrv;
KFSaA
KFSaA        write(e) slrec;
KFSaA        if %error;
KFSaA          notcreated = *on;
KFSaA        endif;
KFSaA      endif;
KFSaA
KFSaA   endsr; // crtslotKfs

ACCaA*----------------------------------------------------------------
ACCaA*  crtslotacc   Try and create physical slot. Presto Foods
ACCaA*----------------------------------------------------------------
ACCaA
ACCaAC     crtslotacc    begsr
ACCaAC                   eval      notcreated = *off
ACCaA
ACCaA*  Uppercase SIDISP
ACCaAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
ACCaA*  Uppercase SIITEM
ACCaAC                   eval      siitem = %xlate(lower:UPPER:siitem)
ACCaA
ACCaA*  Turn on SlotCreated flag even if slot isn't created
ACCaA*  so ZZUPD routine doesn't get executed.
ACCaAC                   eval      slotcreated= *on
ACCaAC                   eval      handstack  = *off
ACCaAC                   clear                   slrec
ACCaA
ACCaA*  Extract location and level. Test if they are numeric.
ACCaA
ACCaAC                   eval      locnotnum = *off
ACCaAC                   eval      lvlnotnum = *off
ACCaAC                   eval      dashpos = 0
ACCaAC                   eval      loca  = ' '
ACCaAC                   eval      lvla  = ' '
ACCaA
ACCaA*  Check for all alpha slot. If no digits, default slot location
ACCaA*  will be assigned.
ACCaAC                   If            %subst(sidisp:5:3) >= '000'
ACCaAC                             and %subst(sidisp:5:3) <= '999'
ACCaAC                             and %subst(sidisp:4:1)  = '-'
ACCaAC                             and %subst(sidisp:8:1)  = '-'
ACCaAC                   eval      allchrslot = *off
ACCaAC                   else
ACCaAC                   eval      allchrslot = *on
ACCaAC                   endif
ACCaA
ACCaAC                   select
ACCaA
ACCaA*  No dashes specified. All character slot.
ACCaAC                   when      allchrslot = *on
ACCaAC
ACCaAC                   eval      kydisp = sidisp
ACCaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ACCaAC
ACCaAC                   eval      dftlocation = dftlocation + 1
ACCaAC                   eval      loca   = %char(dftlocation)
ACCaAC                   eval      slloc  = dftlocation
ACCaAC
ACCaAC                   eval      slrlvl = 1
ACCaAC                   eval      lvla   = '1'
ACCaAC
ACCaAC                   eval      slhand  = '  '
ACCaAC                   eval      dashpos = -1
ACCaA
ACCaA*  Dashes specified. Double character aisle (Ex CA-172-A)
ACCaAC                   when          %subst(sidisp:4:1) = '-'
ACCaAC                             and %subst(sidisp:5:3) >= '000'
ACCaAC                             and %subst(sidisp:5:3) <= '999'
ACCaAC                             and %subst(sidisp:8:1)  = '-'
ACCaAC                             and %subst(sidisp:9:1) >= '0'
ACCaAC                             and %subst(sidisp:9:1) <= '9'
ACCaAC                   eval      dashpos = -1
ACCaAC                   eval      slaisl = %subst(sidisp:1:3)
ACCaAC                   eval      loca  = %subst(sidisp:5:3)
ACCaAC                   move      loca          slloc
ACCaA*
ACCaA*      Convert alpha level into numeric value.
ACCaAC                   eval      lvla    = %subst(sidisp:9:1)
ACCaAC                   evalr     wkchar = %trimr(lvla)
ACCaAC                   exsr      zzcvt2nbr
ACCaAC                   if        nwchar > ' '
ACCaAC                   evalr     lvla   = %trimr(nwchar)
ACCaAC                   eval      slrlvl = %dec(nwchar:2:0)
ACCaAC                   else
ACCaAC                   evalr     lvla  = %subst(sidisp:9:1)
ACCaAC                   move      lvla          slrlvl
ACCaAC                   endif
ACCaAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
ACCaA
ACCaAC                   endsl
ACCaA
ACCaA*  Begin testing parts for ALL slots.
ACCaAC                   testn                   loca                 5050
ACCaAC                   if        *in50 = *off
ACCaAC                   eval      locnotnum = *on
ACCaA
ACCaAC                   else
ACCaAC                   select
ACCaAC                   when      slloc  = 0
ACCaAC                   eval      slloc = slloc + 100
ACCaAC                   when      slloc < 0
ACCaAC                   eval      slloc = slloc * -1
ACCaAC                   endsl
ACCaAC                   endif
ACCaA
ACCaAC                   testn                   lvla                 50
ACCaAC                   if        *in50 = *off
ACCaAC                   eval      lvlnotnum = *on
ACCaAC                   else
ACCaAC                   select
ACCaAC                   when      slrlvl = 0
ACCaAC                   eval      slrlvl = slrlvl + 1
ACCaAC                   when      slrlvl < 0
ACCaAC                   eval      slrlvl = slrlvl * -1
ACCaAC                   endsl
ACCaAC                   endif
ACCaA
ACCaA*    Convert numeric handstack to alpha character.
ACCaA
ACCaAC                   if            slhand >= ' 0'
ACCaAC                             and slhand <= '99'
ACCaAC                   eval      wkchar = slhand
ACCaAC                   exsr      zzcvt2ltr
ACCaAC                   eval      slhand = nwchar
ACCaAC                   endif
ACCaA
ACCaAC     slloc         div       2             dummy
ACCaAC                   mvr                     oddeven
ACCaAC                   if        oddeven <> 0
ACCaAC                   eval      slside = 1
ACCaAC                   else
ACCaAC                   eval      slside = 0
ACCaAC                   endif
ACCaA
ACCaA*    See if slot meets criteria for allowing it to be created.
ACCaA
ACCaAC                   select
ACCaA
ACCaA*    If non-special slot doesn't have hypens, then don't add it.
ACCaA
ACCaAC                   when      dashpos = 0
ACCaAC                   eval      notcreated = *on
ACCaAC                   goto      endcreateacc
ACCaA
ACCaA*    Don't allow creation if department is unknown.
ACCaA
ACCaAC                   when      validdept = '*NO '
ACCaAC                   eval      notcreated = *on
ACCaAC                   goto      endcreateacc
ACCaA
ACCaA*    If location or level is not numeric, then don't add.
ACCaA
ACCaAC                   when      locnotnum or lvlnotnum
ACCaAC                   eval      notcreated = *on
ACCaAC                   goto      endcreateacc
ACCaA
ACCaA*    Otherwise, slot is ok to be created.
ACCaA
ACCaAC                   other
ACCaAC                   eval      slwhdp = siwhdp
ACCaAC                   eval      sldisp = sidisp
ACCaAC                   eval      slstyp = sistyp
ACCaA
ACCaAC                   endsl
ACCaA
ACCaA*    Try and create the imported slot.
ACCaA
ACCaAC                   eval      slwhse = siwhse
ACCaAC                   eval      slpseq = sipseq
ACCaAC*
ACCaAC                   select
ACCaAC                   when      slpseq = 0
ACCaAC                   eval      slpseq = slloc
ACCaAC                   when      slpseq < 0
ACCaAC                   eval      slpseq = slpseq * -1
ACCaAC                   endsl
ACCaAC                   if        slitem > ' '
ACCaAC                   eval      slstat = 'A'
ACCaAC                   else
ACCaAC                   eval      slstat = 'V'
ACCaAC                   endif
ACCaA*
ACCaAC                   eval      slrsrv = sirsrv
ACCaAC                   eval      slsdef = 'XX'
ACCaAC                   eval      slpick = sipick
ACCaA
ACCaAC                   write (e) slrec
ACCaAC                   if        %error
ACCaAC                   eval      notcreated = *on
ACCaAC                   endif
ACCaA
ACCaAC     endcreateacc  endsr
ACCa
DFCaA*----------------------------------------------------------------
DFCaA*  crtslotdfc   Try and create physical slot. Dependable Food Corp
DFCaA*----------------------------------------------------------------
DFCaA
DFCaAC     crtslotdfc    begsr
DFCaAC                   eval      notcreated = *off
DFCaA
DFCaA*  Uppercase SIDISP
DFCaAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
DFCaA*  Uppercase SIITEM
DFCaAC                   eval      siitem = %xlate(lower:UPPER:siitem)
DFCaA
DFCaA*  Turn on SlotCreated flag even if slot isn't created
DFCaA*  so ZZUPD routine doesn't get executed.
DFCaAC                   eval      slotcreated= *on
DFCaAC                   eval      handstack  = *off
DFCaAC                   clear                   slrec
DFCaA
DFCaA*  Extract location and level. Test if they are numeric.
DFCaA
DFCaAC                   eval      locnotnum = *off
DFCaAC                   eval      lvlnotnum = *off
DFCaAC                   eval      dashpos = 0
DFCaAC                   eval      loca  = ' '
DFCaAC                   eval      lvla  = ' '
DFCaA
DFCaA*  Check for all alpha slot. If no digits, default slot location
DFCaA*  will be assigned.
DFCaAC                   if            %subst(sidisp:2:1)  = '-'
DFCaAC                             and %subst(sidisp:3:3) >= '000'
DFCaAC                             and %subst(sidisp:3:3) <= '999'
DFCaAC                             and %subst(sidisp:6:1)  = '-'
DFCaAC                   eval      allchrslot = *off
DFCaAC                   else
DFCaAC                   eval      allchrslot = *on
DFCaAC                   endif
DFCaA
DFCaAC                   select
DFCaA
DFCaA*  No dashes specified. All character slot.
DFCaAC                   when      allchrslot = *on
DFCaAC
DFCaAC                   eval      kydisp = sidisp
DFCaAC***                evalr     slaisl = %trimr(%subst(sidisp:1:1))
DFCaAC                   if        %subst(sidisp:2:1) = '-'
DFCaAC                   evalr     slaisl = '  ' + %trimr(%subst(sidisp:1:1))
DFCaAC                   else
DFCaAC                   evalr     slaisl = ' XX'
DFCaAC                   endif
DFCaAC
DFCaAC                   if        dftlocation = 999
DFCaAC                   eval      dftlocation = 600
DFCaAC                   else
DFCaAC                   eval      dftlocation = dftlocation + 1
DFCaAC                   endif
DFCaAC                   eval      loca   = %char(dftlocation)
DFCaAC                   eval      slloc  = dftlocation
DFCaAC
DFCaAC                   eval      slrlvl = 1
DFCaAC                   eval      lvla   = '1'
DFCaAC
DFCaAC                   eval      slhand  = '  '
DFCaAC                   eval      dashpos = -1
DFCaA
DFCaA*  Dashes specified. Single character aisle (Ex C-072-A)
DFCaAC                   when          %subst(sidisp:2:1) = '-'
DFCaAC                             and %subst(sidisp:3:3) >= '000'
DFCaAC                             and %subst(sidisp:3:3) <= '999'
DFCaAC                             and %subst(sidisp:6:1)  = '-'
DFCaAC                   eval      dashpos = -1
DFCaAC                   evalr     slaisl = '  ' + %subst(sidisp:1:1)
DFCaAC                   eval      loca  = %subst(sidisp:3:3)
DFCaAC                   move      loca          slloc
DFCaA*
DFCaA*      Convert alpha level into numeric value.
DFCaAC                   eval      lvla    = %subst(sidisp:7:1)
DFCaAC                   evalr     wkchar = %trimr(lvla)
DFCaAC                   exsr      zzcvt2nbr
DFCaAC                   if        nwchar > ' '
DFCaAC                   evalr     lvla   = %trimr(nwchar)
DFCaAC                   eval      slrlvl = %dec(nwchar:2:0)
DFCaAC                   else
DFCaAC                   evalr     lvla  = %subst(sidisp:7:1)
DFCaAC                   move      lvla          slrlvl
DFCaAC                   endif
DFCaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
DFCaA
DFCaAC                   endsl
DFCaA
DFCaA*  Begin testing parts for ALL slots.
DFCaAC                   testn                   loca                 5050
DFCaAC                   if        *in50 = *off
DFCaAC                   eval      locnotnum = *on
DFCaA
DFCaAC                   else
DFCaAC                   select
DFCaAC                   when      slloc  = 0
DFCaAC                   eval      slloc = slloc + 100
DFCaAC                   when      slloc < 0
DFCaAC                   eval      slloc = slloc * -1
DFCaAC                   endsl
DFCaAC                   endif
DFCaA
DFCaAC                   testn                   lvla                 50
DFCaAC                   if        *in50 = *off
DFCaAC                   eval      lvlnotnum = *on
DFCaAC                   else
DFCaAC                   select
DFCaAC                   when      slrlvl = 0
DFCaAC                   eval      slrlvl = slrlvl + 1
DFCaAC                   when      slrlvl < 0
DFCaAC                   eval      slrlvl = slrlvl * -1
DFCaAC                   endsl
DFCaAC                   endif
DFCaA
DFCaA*    Convert numeric handstack to alpha character.
DFCaA
DFCaAC                   if            slhand >= ' 0'
DFCaAC                             and slhand <= '99'
DFCaAC                   eval      wkchar = slhand
DFCaAC                   exsr      zzcvt2ltr
DFCaAC                   eval      slhand = nwchar
DFCaAC                   endif
DFCaA
DFCaAC     slloc         div       2             dummy
DFCaAC                   mvr                     oddeven
DFCaAC                   if        oddeven <> 0
DFCaAC                   eval      slside = 1
DFCaAC                   else
DFCaAC                   eval      slside = 0
DFCaAC                   endif
DFCaA
DFCaA*    See if slot meets criteria for allowing it to be created.
DFCaA
DFCaAC                   select
DFCaA
DFCaA*    If non-special slot doesn't have hypens, then don't add it.
DFCaA
DFCaAC                   when      dashpos = 0
DFCaAC                   eval      notcreated = *on
DFCaAC                   goto      endcreatedfc
DFCaA
DFCaA*    Don't allow creation if department is unknown.
DFCaA
DFCaAC                   when      validdept = '*NO '
DFCaAC                   eval      notcreated = *on
DFCaAC                   goto      endcreatedfc
DFCaA
DFCaA*    If location or level is not numeric, then don't add.
DFCaA
DFCaAC                   when      locnotnum or lvlnotnum
DFCaAC                   eval      notcreated = *on
DFCaAC                   goto      endcreatedfc
DFCaA
DFCaA*    Otherwise, slot is ok to be created.
DFCaA
DFCaAC                   other
DFCaAC                   eval      slwhdp = siwhdp
DFCaAC                   eval      sldisp = sidisp
DFCaAC                   eval      slstyp = sistyp
DFCaA
DFCaAC                   endsl
DFCaA
DFCaA*    Try and create the imported slot.
DFCaA
DFCaAC                   eval      slwhse = siwhse
DFCaAC                   eval      slpseq = sipseq
DFCaAC*
DFCaAC                   select
DFCaAC                   when      slpseq = 0
DFCaAC                   eval      slpseq = slloc
DFCaAC                   when      slpseq < 0
DFCaAC                   eval      slpseq = slpseq * -1
DFCaAC                   endsl
DFCaAC                   if        slitem > ' '
DFCaAC                   eval      slstat = 'A'
DFCaAC                   else
DFCaAC                   eval      slstat = 'V'
DFCaAC                   endif
DFCaA*
DFCaAC                   eval      slrsrv = sirsrv
DFCaAC                   eval      slsdef = 'XX'
DFCaAC                   eval      slpick = sipick
DFCaA
DFCaAC                   write (e) slrec
DFCaAC                   if        %error
DFCaAC                   eval      notcreated = *on
DFCaAC                   endif
DFCaA
DFCaAC     endcreatedfc  endsr
DFCaA
FRFcA*----------------------------------------------------------------
FRFcA*  write01roc  Write out record to IMPPCKQ.
FRFcA*----------------------------------------------------------------
FRFcA
FRFcAC     write01roc    begsr
FRFcA
FRFcAC                   clear                   ipqrec
FRFcA
FRFcAC                   eval      ipqwhs = siwhse
FRFcAC                   eval      ipqwhd = siwhdp
FRFcAC                   eval      ipqdsp = sldisp
FRFcAC                   eval      ipqitm = siitem
FRFcA*      Convert qty's so that they will be added to onhand.
FRFcAC                   eval      ipqqp1 = siqty1 * -1
FRFcAC                   eval      ipqqp2 = siqty2 * -1
FRFcAC                   eval      ipqqp3 = siqty3 * -1
FRFcAC                   eval      ipqadj = 'RO'
FRFcAC                   eval      ipqsof = 'N'
FRFcAC                   write     ipqrec
FRFcA
FRFcAC     endwriteroc   endsr
FRFcA
     *----------------------------------------------------------------
     *  zzcvt2ltr   Convert numeric handstack to alpha character.
     *----------------------------------------------------------------

     C     zzcvt2ltr     begsr

     C                   eval      nwchar = '  '

GFCeAC                   if        client = Glazier
CFIaAC                             or client = Colony
GFCeAC                   select
GFCeAC                   when      wkchar = ' 1'
GFCeAC                   eval      nwchar = ' A'
GFCeAC
GFCeAC                   when      wkchar = ' 2'
GFCeAC                   eval      nwchar = ' B'
GFCeAC
GFCeAC                   when      wkchar = ' 3'
GFCeAC                   eval      nwchar = ' C'
GFCeAC
GFCeAC                   when      wkchar = ' 4'
GFCeAC                   eval      nwchar = ' D'
GFCeAC
GFCeAC                   when      wkchar = ' 5'
GFCeAC                   eval      nwchar = ' E'
GFCeAC
GFCeAC                   when      wkchar = ' 6'
GFCeAC                   eval      nwchar = ' F'
GFCeAC
GFCeAC                   when      wkchar = ' 7'
GFCeAC                   eval      nwchar = ' G'
GFCeAC
GFCeAC                   when      wkchar = ' 8'
GFCeAC                   eval      nwchar = ' H'
GFCeAC
GFCeAC                   when      wkchar = ' 9'
GFCeAC                   eval      nwchar = ' I'
GFCeAC
GFCeAC                   when      wkchar = ' 0'
GFCeAC                   eval      nwchar = ' J'
GFCeAC
GFCeAC                   other
GFCeAC                   eval      nwchar = ' K'
GFCeAC
GFCeAC                   endsl
GFCeAC*
GFCeAC                   else
GFCeAC*

     C                   select
     C                   when         wkchar = ' 0'
     C                             or wkchar = '  '
     C                   eval      nwchar = ' A'
     C
     C                   when      wkchar = ' 1'
     C                   eval      nwchar = ' B'
     C
     C                   when      wkchar = ' 2'
     C                   eval      nwchar = ' C'
     C
     C                   when      wkchar = ' 3'
     C                   eval      nwchar = ' D'
     C
     C                   when      wkchar = ' 4'
     C                   eval      nwchar = ' E'
     C
     C                   when      wkchar = ' 5'
     C                   eval      nwchar = ' F'
     C
     C                   when      wkchar = ' 6'
     C                   eval      nwchar = ' G'
     C
     C                   when      wkchar = ' 7'
     C                   eval      nwchar = ' H'
     C
     C                   when      wkchar = ' 8'
     C                   eval      nwchar = ' I'
     C
     C                   when      wkchar = ' 9'
     C                   eval      nwchar = ' J'
     C
     C                   endsl
GFCeAC
GFCeAC                   endif

     C     endcvt2ltr    endsr

     *----------------------------------------------------------------
     *  zzcvt2nbr   Convert alpha character to numeric character.
     *----------------------------------------------------------------

     C     zzcvt2nbr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' A'
     C                             or wkchar = '  '
     C                   eval      nwchar = '01'
     C
     C                   when      wkchar = ' B'
     C                   eval      nwchar = '02'
     C
     C                   when      wkchar = ' C'
     C                   eval      nwchar = '03'
     C
     C                   when      wkchar = ' D'
     C                   eval      nwchar = '04'
     C
     C                   when      wkchar = ' E'
     C                   eval      nwchar = '05'
     C
     C                   when      wkchar = ' F'
     C                   eval      nwchar = '06'
     C
     C                   when      wkchar = ' G'
     C                   eval      nwchar = '07'
     C
     C                   when      wkchar = ' H'
     C                   eval      nwchar = '08'
     C
     C                   when      wkchar = ' I'
     C                   eval      nwchar = '09'
     C
     C                   when      wkchar = ' J'
     C                   eval      nwchar = '10'
     C
     C                   when      wkchar = ' K'
     C                   eval      nwchar = '11'
     C
     C                   when      wkchar = ' L'
     C                   eval      nwchar = '12'
     C
     C                   when      wkchar = ' M'
     C                   eval      nwchar = '13'
     C
     C                   when      wkchar = ' N'
     C                   eval      nwchar = '14'
     C
     C                   when      wkchar = ' O'
     C                   eval      nwchar = '15'
     C
     C                   when      wkchar = ' P'
     C                   eval      nwchar = '16'
     C
     C                   when      wkchar = ' Q'
     C                   eval      nwchar = '17'
     C
     C                   when      wkchar = ' R'
     C                   eval      nwchar = '18'
     C
     C                   when      wkchar = ' S'
     C                   eval      nwchar = '19'
     C
     C                   when      wkchar = ' T'
     C                   eval      nwchar = '20'
     C
     C                   when      wkchar = ' U'
     C                   eval      nwchar = '21'
     C
     C                   when      wkchar = ' V'
     C                   eval      nwchar = '22'
     C
     C                   when      wkchar = ' W'
     C                   eval      nwchar = '23'
     C
     C                   when      wkchar = ' X'
     C                   eval      nwchar = '24'
     C
     C                   when      wkchar = ' Y'
     C                   eval      nwchar = '25'
     C
     C                   when      wkchar = ' Z'
     C                   eval      nwchar = '26'
     C
     C                   endsl

     C     endcvt2nbr    endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*                     DRI SUBROUTINES
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  clr$item  Clear $item data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  zzzdricop  Call DRICOP
600bA*----------------------------------------------------------------
600bA
600bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
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
     C*                  select
     C*                  when      zmsflag
     C*                  exsr      zm0105s
     C*                  when      zmflag
     C*                  exsr      zm0105
     C*                  endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C*                  select
     C*                  when      zmsflag
     C*                  exsr      zm0001s
     C*                  when      zmflag
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C*                  eval      zmflag = *off
     C*                  eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID SLOT*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID ITEM TYPE*
*CAN'T CREATE VS/1*
*SLOT NOT UPDATED*
*CAN'T CREATE VS/2*
*CAN'T CREATE VS/3*
*INVALID FIFO DATE*
*DEPT/SECT MISMATCH*
*NO SLOT SENT*
*CK DIGIT NOT UPD*
*CAN'T CREATE OSS*
**
FTP StuffIt Import
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
