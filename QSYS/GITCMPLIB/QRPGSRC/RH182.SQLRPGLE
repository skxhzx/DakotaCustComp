417cA /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *  Note, when implementing this for a client, the client's
     *  PFMT program may need to be changed to support the printing
     *  of a single label. Also, pay attention to the PFMT parms.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  RH182     View order detail - Add
     *  09 December 2004
     *  Dave Sommerville
     *
760aA*      If you change this program, check RTESUB, it likely needs
760aA*        the same changes.
     *
     *  Revisions
     *
500 A*    12/09/04  DAS  5.00
     *      - Created.
510 A*    06/15/07  RBD  5.10
     *      - If open route, require a qty to be entered.
     *      - Update route summary file/rtesum when substitute
     *        item is added.
     *      - Update route compartment summary file/rtecsum when
     *        substitute item is added.
     *      - Use different klist, with w1seq from screen1 for
     *        chain to ORDD when checking for existence of ORDD record.
     *      - Eliminate hardcoding uom's for qty ordered (normal,
     *        brkdown 1, and brkdwn 2) by using headings to identify
     *        them as such.
     *      - Display error msg if a brkdwn qty is entered but is
     *        not allowed, or if a brkdwn qty is entered for a Same
     *        Slot Breakdown item.
     *      - Chg logic for determining SSB item, use GETSSB.
     *      - Use slot item's unit weight for calculating label
     *        weight.
     *      - Use original item to populate errmsg when pallet for
     *        original item is not found.
     *      - Fix both chains to optionz to use 'not %found' rather
     *        than %eof.
     *      - Set picking priority to 9- so that no slot records
     *        get missed.
510aA*    07/18/07  RBD  5.10a
     *      - Send *PICK to PFMT instead of *PRTLBL.
510bA*    07/18/07  DAS  5.10a
     *      - Added client logic.
     *      - Reversed 510a changes.
     *      - Revised to use client logic and 2 sets of parms
     *        for call to PFMT. The first set is for City Line,
     *        which is an old version of PFMT and the other is
     *        initially for Royal.
510cA*    07/20/07  RBD  5.10c
     *      - For printed routes, write rec to PLTSUM if tran# > 0.
     *      - Update bulk pick label and add on flag.
     *      - Add logic to update PIRTRAN.
510dA*    10/23/07  RBD  5.10d
     *      - Enh: Revised program to retrieve printer defaults.
520 A*    01/18/08  RBD  5.20
     *      - Fix: If user selected F9=Pallet for orig item, was
     *        only getting pallet if generation 1 record. Rev'd
     *        so that if it's a gen 2 record and lwctr# is
     *        populated, use that pallet, which in effect is the
     *        gen 1 pallet of the original item.
520aA*    04/15/08  RBD  5.20a
     *      - Enh: Added alternative method for assigning odseq for
     *        subbed items. Existing method finds the highest seq#
     *        for the order and adds 1 to it ... the alternative
     *        method uses the original item's seq# plus 1.
     *        This rev requested by CityLine. Their original item
     *        seq#'s are incremented by 5, thus allowing the subbed
     *        item's seq# to be inserted, immediately following the
     *        original item.
520bA*    12/18/08  RBD  5.20b
     *      - Only allow subs for specific clients.
520cA*    02/11/09  RBD  5.20c
     *      - Revised program to retrieve System Feature option.
     *        If Feature Option set to 3=Outbound Only, disable
     *        F9=Pick slot for item function, bypass DRICOP slot
     *        edits, but verify that the slot entered is the same
     *        dept/section as the sub item.
     *        Also, do not update slots if Outbound Only.
     *        Note: Outbound Only and Stand Alone are synonymous.
520dA*    02/20/09  RH   5.20d
     *      - Enh: Check allow sub flag in OHMISC (pos 10)to allow
     *        option substitute.
     *      - Enh: Add Jack Palmer to list of clients for subs.
530 A*    08/05/10  RBD  5.30
     *      - Added logic to prevent the user from entering the
     *        original item and u/m qty as the sub item and u/m qty.
     *        Example: Original item = ABC and u/m qty = case.
     *        Sub item ABC and u/m qty = case will not be accepted,
     *        however, if ABC is also sold in eaches, sub item ABC
     *        and u/m qty of Eaches would be acceptable.
530a *    07/01/10  GJA  5.30a
     *      - Fix:  If substitution and item is type='S' it was not
     *        using correct UOM.
640 A*    01/05/10  JCJ  6.40
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
640a *    01/27/11  GJA  6.40a
     *      - Fix:  If substitution and item is type ' ' it was not
     *        using correct UOM.
640bA*    09/01/11  RBD  6.40b
     *      - Create an ORDP record for substitute item ... it is
     *        necessary for Trax.
640cA*    02/15/12  JCJ  6.40c
     *      - Enh: add *GENPICK options for Sub item flag.
640dA*    04/24/12  JCJ  6.40d
     *      - Enh: get original label record to get section code.
     *      - Fix: add OHORD to the pallet selection criteria.
640eA*    05/02/12  RBD  6.40e
     *      - Fix: Send new cmd *SUBITEM and parms for pallet id
     *        and trans to OR626 for updating RTECSUM at pallet and
     *        transaction level for substitute items.
     *        Before this fix, sub items were causing RTECSUM to be
     *        updated multiple times for the same pallet/tran because
     *        the logic wasn't written to handle there being more than
     *        1 transaction per pallet in PLTSUM, which is the case
     *        for subbed items.
     *      - Fix: If printed route, update route summary picked flds.
640f *    05/14/12  GJA  6.40f
     *      - Fix: Printer dev was not using correct OPTIONZ code.
640gA*    08/22/12  RBD  6.40g
     *      - Fix: Unit cube and unit weight were not being calculated
     *        correctly for SSB items.
640hA*    09/12/12  RBD  6.40h
     *      - Renamed RH182FM to RH18201.
     *      - Added item substitutes logic.
     *        Added item substitute parm.
     *        Revised F4 to call new pgm IT1900 subs lookup if there
     *        are sub records for the item.
     *        Revised check routine to call GETITEMSUB to verify the
     *        item substitute.
640iA*    10/24/12  RBD  6.40i
     *      - Added new cmd *SUBRUN and 8 x 20 screen to be used by
     *        runners.  Added these dspf changes to RH18201 since it
     *        has not yet been moved into production.
     *      - When cmd = *SUBRUN call ADJTRAN2 to end the selection
     *        transaction that was just created.
     *
650 A*    04/22/13  MLB  6.50
     *      - Fix: Revised routine ZZDFT1 to correct problem caused by
     *        6.40i mod that allowed pgm to assign line nbr + 1 instead
     *        of last line nbr + 1.
     *
650aA*    05/09/13  RBD  6.50a
     *      - Fix: Instead of just creating 1 ORDP record for the sub
     *        item, call OR637S to determine how many should be created
     *        and let it create them.
     *
650bA*    05/15/13  RBD  6.50b
     *      - Enh: When sub item is passed in, exec zzcmdgetslot and
     *        zzcmdgetplt in zzdft1 to populate slot and pallet row/col
     *        for the user. The user may still change the values if
     *        desired or press F9 to get the values.
     *      - Fix: Populate hld_$p fields in zzinz2 instead of zzinz.
650cA*    06/14/13  MLB  6.50c  (Originally 5.20e at Jordano's)
     *      - Enh: Revised program to update order line number of
     *        line item being subbed into ODOR2 - Corresponding Order#
     *        field. This will allow for easier processing of item
     *        substitutions on customer orders.
650dA*    09/18/13  MLB  6.50d
     *      - Fix: Revised 5.10 mod. Was not correctly retrieving SSB
     *        item information.
650eA*    02/20/15  RBD  6.50e
     *      - Enh: Added logic from RC200 and OR610 to handle repack subs.
710aA*    08/30/17  RBD  7.10a
     *      - Enh: Added call to LOADR10S to load substitute item if
     *        client uses the Loader Module.
720aA*    03/30/18  RBD  7.20a
     *      - Renamed format to RH18202.
     *      - Enh: Added catchweight processing, much like RU310.
     *      - Enh: Show warning if item has been previously subbed.
720bA*    06/08/18  RBD  7.20b
     *      - Don't edit substitute if user is just subbing the same
     *        item with a different unit of measure.
720cA*    08/14/18  MLB  7.20c
     *      - Fix: Revised 7.20a mod. Pgm was using ORDD1 in update/full-
     *        procedural mode with no update being done to file. Was
     *        causing CPF5032 Rcd already locked to this job on ORDD.
     *        Changed ORDD1 to input/full-procedural.
750 A*    05/12/21  KDE  7.50
     *      - Changed to support DD2
760bA*    09/15/22  KDE  7.60a
     *      - Change to call OR630ADB when updating PLTSUM to ensure
     *        all pallets are represented in PLTMISC so Truck Map includes
     *        all pallets.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client custom revisions - City Line
     *
CLDaA*    07/18/07  DAS  CLDa
     *      - Needed a special set of PFMT parameters.
CLDbA*    09/26/07  RBD  CLDb
     *      - Added parms for call to PFMT.
CLDcA*    04/15/08  RBD  CLDc
     *      - Use alternative method for assigning seq# to subbed
     *        items, based on original item's seq#.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client custom revisions - Jordano's
     *
JOR A*    01/21/08  RBD  JOR
     *      - Added call to PFMT with $pfcmd *PRTLBL if Jordano's.
JORaA*    08/08/08  RBD  JORa
     *      - Reversed JOR rev, do not call PFMT.  Jordano's does
     *        not want to print labels for substitutes.
JORbA*    04/06/09  RH   JORb
     *      - Enh: Default slot and pallet position for sub like F9
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Palmer
     *
JPF A*    02/08/09  JCJ  JPF
     *      - Added call to PFMT with cmd *PRTLBL.
     *      - Use alternative method for assigning seq# to subbed
     *        items, based on original item's seq#.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Renzi
     *
RNZ A*    01/21/09  RBD  RNZ
     *      - Added Renzi to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Saval
     *
SVLaA*    03/25/09  RH   SVLa
     *      - Added Saval to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Indianhead
     *
IFD A*    01/26/09  RBD  IFD
     *      - Added call to PFMT with cmd *PRTLBL.
     *      - Use alternative method for assigning seq# to subbed
     *        items, based on original item's seq#.
IFDaA*    06/02/10  MLB  IFDa
     *      - Enh: Check allow sub flag in OHMISC (pos 10)to allow
     *        option substitute.
     *      - Added IFD to Palmer mod.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Cash WA
     *
CWD A*    03/30/09  MLB  CWD
     *      - Added Cash WA to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
CWDaA*    03/30/09  MLB  CWDa
     *      - Revised program to store Original Line Number in
     *        Corresponding Order Number field (ODOR2).
CWDbA*    03/01/10  MLB  CWDb
     *      - Revised mod CWDa to save Original Line Number from
     *        ODOR2 that item sub is being attached and load it
     *        into subbed item field ODOR2.
CWDcA*    11/07/16  NLK  7.00 - CWDc
     *      - Enh: Added file ORDDM to write if sub item for cashwa.
     *             This will allow Trax# to print on PICK label.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Dairyland
     *
DRY A*    12/29/09  RBD  DRY
     *      - Added Dairyland to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *----------------------------------------------------------------
     *  Client custom revisions - European Imports
     *
EI  A*    05/21/11  JCJ  EI
     *      - Added European Imports to list of clients using subs,
     *        and will call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Mattingly
     *
MAT A*    01/29/10  RBD  MAT
     *      - Added Mattingly to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Fischer Foods Company
     *
FFC A*    03/29/10  MLB  FFC
     *      - Use alternative method for assigning seq# to subbed
     *        items, based on original item's seq# + 1.
     *      - Added FFC to CLDc mod.
FFCaA*    04/07/10  MLB  FFCa
     *      - Added Fischer to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Fox River Foods
     *
FRF A*    05/13/10  MLB  FRF
     *      - Added Fox River Foods to list of clients using subs and
     *        call PFMT with cmd *PRTLBL.
FRFaA*    05/25/10  RBD  FRFa
     *      - Do not call PFMT, they do not want a sub label.
FRFbA*    05/14/10  MLB  FRFb
     *      - Revised program to store Original Line Number in
     *        Corresponding Order Number field (ODOR2).
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Capitol City Produce
     *
CCP A*    06/29/10  MLB  CCP
     *      - Added Capitol City to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *----------------------------------------------------------------
     *  Client custom revisions - Coastal Sunbelt Produce
     *
CSP A*    08/31/10  JCJ  CSP
     *      - Added Coastal to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.

     *----------------------------------------------------------------
     *  Client custom revisions - Crumbley
     *
CPC A*    01/11/11  JCJ  CPC
     *      - Added Crumbley list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *----------------------------------------------------------------
     *  Client custom revisions - Nicholas & Co
     *
NCSaA*    01/27/11  JCJ  NCS
     *      - Added Nicholas to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Dairyland
     *
EFCaA*    02/16/11  JCJ  EFCa
     *      - Added Eastland to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
EFCb *    11/11/12  GJA  EFCb
     *      - Eastland does not want to use subs.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Glazier
     *
GFCaA*    07/14/11  JCJ  GFCa
     *      - Add Glazier to the list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
GFCbA*    03/30/12  MLB  GFCb
     *      - Revised program to store Original Line Number in
     *        Corresponding Order Number field (ODOR2).
GFCcA*    06/05/12  MLB  GFCc
     *      - Revised program to check customer sub flag stored in
     *        order header Misc. field (OHMISC).
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Silberman
     *
SLBaA*    08/21/11  JCJ  SLBa
     *      - Added Silberman to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *----------------------------------------------------------------
     *  Client custom revisions - CDI
     *
CDIaA*    12/05/11  JCJ  CDIa
     *      - Added CDI to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Kelly's Foods
     *
KFSaA*    09/18/12  MLB  KFSa
     *      - Added Kelly's Foods to list of clients using subs, and will
     *        call PFMT with cmd *PRTLBL.
KFSbA*    09/18/12  MLB  KFSb
     *      - Revised program to store Original Line Number in
     *        Corresponding Order Number field (ODOR2).
     *      - Added KFSb to GFCb mod.
KFScA*    09/18/12  MLB  KFSc
     *      - Revised program to check customer sub flag stored in
     *        order header Misc. field (OHMISC).
     *      - Added KFSc to GFCc mod.
     *----------------------------------------------------------------
     *  Client custom revisions - Hearn Kirkwood
     *
HKW A*    07/09/13  MLB  HKW
     *      - Revised program to check customer sub flag stored in
     *        order header Misc. field (OHMISC).
     *      - Added HKW to GFCc mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Sofo Foods
     *
SOFbA*    04/01/15  MLB  SOFb
     *      - Revised program to store Original Line Number in
     *        Corresponding Order Number field (ODOR2).
SOFcA*    04/01/15  MLB  SOFc
     *      - Revised program to check customer sub flag stored in
     *        order header Misc. field (OHMISC).
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    - Only *ADD / *SUB are implemented.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

640hDF*rh182fm   cf   e             workstn
720aDF*rh18201   cf   e             workstn
720aMFrh18202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
640iAF                                     sfile(m08rec:msgk)
CWDcAForddm     uf a e           k disk
     Fordd      uf a e           k disk
     F                                     rename(odrec:record)
720cMFordd1     if   e           k disk    rename(odrec:odrec1)
720aAf                                     prefix(od1_)
     Fordh      if   e           k disk
     Frtehed    if   e           k disk
520cAFslot2     if   e           k disk    prefix(s_)
520cAFoptions   if   e           k disk
CBIbAFoptionz   if   e           k disk
510cDF*ltsum2   uf   e           k disk
510cMFpltsum2   uf a e           k disk
     Fpltstp1   uf a e           k disk
     Fworklbl8  if   e           k disk
     F                                     rename(lwrec:lwrec8)
510 AFrtesum    uf a e           k disk
     Fworklbl   o    e           k disk
640dMFlabel     if a e           k disk
640dD *label     o    e           k disk
640 AFtruckh    if   e           k disk
640gAFpiritem   if   e           k disk
650aDF*ordp      o    e           k disk
650eAFkititem   if   e           k disk
650eAFkitcomp   if   e           k disk
720aAFitemmsc   if   e           k disk

510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*----------------------------------------------------------------
510bA /copy qcopysrc,id#citylin
JOR A /copy qcopysrc,id#jordano
520bA /copy qcopysrc,id#sgc
520bA /copy qcopysrc,id#royal
520bA /copy qcopysrc,id#ifd
RNZ A /copy qcopysrc,id#renzi
520dA /copy qcopysrc,id#palmer
CWD A /copy qcopysrc,id#cashwa
SVLaA /copy qcopysrc,id#saval
DRY A /copy qcopysrc,id#dairyla
MAT A /copy qcopysrc,id#matt
FFC A /copy qcopysrc,id#fischer
FRF A /copy qcopysrc,id#FRF
CCP A /copy qcopysrc,id#capitol
CSP A /copy qcopysrc,id#coastal
CPC A /copy qcopysrc,id#cpc
NCSaA /copy qcopysrc,id#nichola
ESCaA /copy qcopysrc,id#eastlan
EI aA /copy qcopysrc,id#ei
GFCaA /copy qcopysrc,id#glazier
SLBaA /copy qcopysrc,id#silberm
CDIaA /copy qcopysrc,id#cdi
CDIaA /copy qcopysrc,id#cdiatl
CDIaA /copy qcopysrc,id#cdijax
KFSaA /copy qcopysrc,id#kfs
HKW A /copy qcopysrc,id#hkw
SOF A /copy qcopysrc,id#sofo

520cA*----------------------------------------------------------------
520cA*  *FEATURE  -  PIR Feature options.
520cA*----------------------------------------------------------------
520cA*
520cA* Fields
520cA*
520cA*    OPFEAT  -  PIR Installed feature.
520cA*
520cA* Data structure
520cA*
520cAD opfdta          DS
520cAD  opfeat                 1      1
520cAD  opfend               117    117

CWDcAD  hmsc1          ds
CWDcAD   hmsc1a                1     17
CWDcAD   hmsc1b               18     27
CWDcAD   hmsc1c               28     40

     *----------------------------------------------------------------
520cA* OHMISC data structure
520cAD dsmisc          DS
520cAD  dssubf                10     10
GFCcA /copy qcopysrc,ohmisc_gfc
SOFcA /copy qcopysrc,ohmisc_sof
     *----------------------------------------------------------------
510 A*  Table and array definitions

530 DD*desc            s             50    DIM(5) CTDATA PERRCD(1)
530 MD desc            s             50    DIM(7) CTDATA PERRCD(1)
520dDD*er              s             60    DIM(1) CTDATA PERRCD(1)
520dMD er              s             60    DIM(2) CTDATA PERRCD(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#item
      /COPY *libl/qcopysrc,c#slot
     D savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

     *----------------------------------------------------------------
650eAD                 ds
650eAD  wopqndec               1     15  2
650eAD  dec                   14     15  0
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $prteid               22     26
     D  $pcord                27     33  0
     D  $pord                 34     40  0
     D  $pseq                 41     45  0
     D  $pitem                46     60

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

     *   Redefine key

     D  $lwhse                19     21  0
     D  $litem                22     36
640hAD  $lcust                37     47  0
640hAD  $lisub                48     62

720aA*----------------------------------------------------------------
720aA*  Called program parameters
720aA*
720aAD $rparm          ds
720aAD  $rcmd                  1      8
720aAD  $rprg                  9     18
720aAD  $ruky                 19     68
720aAD  $rrtn                 69     76
720aAD  $rerm                 77    136
720aAD  $rmsg                 77     80
720aAD  $rtype                81     88
720aA*
720aA*   Redefine key
720aA*
720aAD  $rwhse                19     21  0
720aAD  $rlbl                 22     28  0
720aAD  $rqyfd                29     33  0
720aAD  $rhcwgt               34     40  2
720aAD  $rlcwgt               41     47  2

     *----------------------------------------------------------------

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
     *  Convert Date fields.
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

CBIbAI*----------------------------------------------------------------
CBIbAI*  *PICKLBL  -  Picking label options
CBIbAI*----------------------------------------------------------------
     I*
     I* Fields
     I*
     I*    OPCLVL  -  Qty level for combined labels.
     I*    OPCWRB  -  Print combined label warning before.
     I*    OPCWRA  -  Print combined label warning after.
     I*    OPUWRB  -  Print unit of measure warning before.
     I*    OPUWRA  -  Print unit of measure warning after.
     I*    OPTEXT  -  Text for last line of label.
     I*    OPERR   -  Error label ratio.
     I*    OPCWGT  -  Catch weight label ratio.
     I*    OPLPGM  -  Picking label program.
     I*    OPPDEV  -  Printer device.
     I*    OPPFRM  -  Printer form.
     I*
     I* Data structure
     I*
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
     D  optend               117    117

     *----------------------------------------------------------------
640fA*  *PICKLBA -  Label printing options for the standard pick,
     *              retail, and tote labels.
     *
     *     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opzdta2         ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  optend2              117    117
640cA*----------------------------------------------------------------
640cA*  *GENPICK -  General picking.
640cA*----------------------------------------------------------------
640cA*
640cA* Fields
640cA*
640cA*    OPERPT  -  Print exception (short) error report (Y,N).
640cA*    OPELBL  -  Print exception (short) labels (Y,N).
640cA*    OPRFWC  -  Using RF will call (Y,N).
640cA*    OPNRSC  -  Number of pallet sections (1-9).
640cA*    OPHPWC  -  Host pick Will Call (Y/N).
640cA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
640cA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
640cA*    OPEADJ  -  Close short labels without adjustment (Y,N).
640cA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
640cA*    OPGPK1  -  <Not Used / Available>
640cA*    OPGPK2  -  <Not Used / Available>
640cA*               task has been assigned. (Y/N)
640cA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
640cA*                 0=None. No replenishments are created.
640cA*                 1=Letdowns are created during Truck Builder
640cA*                   Pick/Print processing.
640cA*                 2=Priority Replenishments are created during
640cA*                   Truck Builder Pick/Print processing.
640cA*                 3=JIT Letdowns created when transaction is
640cA*                   checked out.
640cA*                 4=JIT Priority Replenishments created when
640cA*                   transaction is checked out.
640cA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
640cA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
640cA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
640cA*    OPRFSL  -  RF Pick Verify slot (Y/N)
640cA*    OPRBN1  -  Round robin printing compatable (Y/N)
640cA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640cA*               1=Off
640cA*               2=By route
640cA*               3=By transaction
640cA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
640cA*
640cA* Data structure
640cA*
640cAD oppdta          ds
640cAD  operpt                 1      1
640cAD  opelbl                 2      2
640cAD  oprfwc                 3      3
640cAD  opnrsc                 4      4  0
640cAD  ophpwc                 5      5
640cAD  opmrga                 6      6
640cAD  opplsq                 7      7
640cAD  opeadj                 8      8
640cAD  opnopk                 9      9
640cAD  opgpk1                10     10
640cAD  opgpk2                11     11
640cAD  opjitr                12     12
640cAD  oppset                13     13
640cAD  oprfuc                14     14
640cAD  oprflc                15     15
640cAD  opusf1                16     16
640cAD  oprfsl                17     17
640cAD  oprbn1                18     18
640cAD  oprbn2                19     19
640cAD  opsubt                20     20
640cAD  oppend               117    117

710aA*
710aA*----------------------------------------------------------------
710aA*  *RUNNER  -  PIR Runner Flag Options
710aA*----------------------------------------------------------------
710aA*
710aA* Fields
710aA*
710aA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
710aA*    OPUPLR  -  Update Label with quantity shorted during manual
710aA*               flag entry (Y/N)
710aA*               NOTE: Any change to this field will cause OPUPLV
710aA*                     in the *VOICE options record to be updated.
710aA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
710aA*               & create Priority Replenishment if necessary.
710aA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
710aA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
710aA*    OPRNRM  -  Send break message to user when new Runner
710aA*               task has been assigned. (Y/N)
710aA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
710aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
710aA*    OPRPCK  -  Print Runner pick list. (Y/N)
710aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
710aA*               printer, 2=Belt printer
710aA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
710aA*    OPRSCN  -  Scan tran# or label# to start pick.
710aA*                 1=tran#, 2=label#.
710aA*    OPRVFS  -  Verify pick slot, Y/N.
710aA*    OPRVFQ  -  Verify qty found, Y/N.
710aA*    OPRLOA  -  Using loader module, Y/N.
710aA*
710aA* Data structure
710aA*
710aAD opdat1          ds
710aAD  opcrtm                 1      1
710aAD  opuplr                 2      2
710aAD  oprplf                 3      3
710aAD  opmrgf                 4      4
710aAD  opclrf                 5      5
710aAD  oprnrm                 6      6
710aAD  opclsf                 7      7
710aAD  opoutf                 8      8
710aAD  oprpck                 9      9
710aAD  oprlbl                10     10
710aAD  oprbdu                11     11
710aAD  oprscn                12     12
710aAD  oprvfs                13     13
710aAD  oprvfq                14     14
710aAD  oprloa                15     15
710aAD  optend1              117    117
710aA*
710aA*----------------------------------------------------------------

720aA*----------------------------------------------------------------
720aA*  *SYSTEM  -  System options.
720aA*----------------------------------------------------------------
720aA*
720aA* Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPUCI   -  Use UCI processing (Y,N)
     *
     * Data structure
     *
     D opdta2          ds
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
     D  opuci                 36     36
     D  optendj              117    117

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

640hAD $cmd1           s             10
640hAD $isub           s             15
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
640 AD $ptmpl          s             10
640 AD $ptruk          s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curdate         s              8  0
     D curtime         s              6  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D forever         s               n
     D help            s              5  0
530 AD hld_$pord       s                   like($pord)
530 AD hld_$pseq       s                   like($pseq)
530 AD hld_$pitem      s                   like($pitem)
750 Ad tbEnhanced      s               n
750 Ad tbPalletType    s              1
750 Ad tbType          s              1
750 Ad oneChar         s              1
750 Ad Oplid           s              7  0
650eAD kitcnt          s              1  0
     D kycode          s                   like(opzcod)
     D kygen           s                   like(psgen)
     D kysbsq          s                   like(pssbsq)
     D kytype          s                   like(pstype)
     D lasttime        s              6  0
650eAD odrppick        s             12
650eAD odrslot         s             12
650eAD outPutQty       s              5  0
     D msgk            s              4  0
     D lastseq#        s              5  0
     D pickqty1        s                   like(w1qor1)
     D pickqty2        s                   like(w1qor2)
     D pickqty3        s                   like(w1qor3)
     D nxtscr          s              3
510dAD origitem_whdp   s              5
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtebuilt        s               n
     D rteopen         s               n
     D rteprinted      s               n
     D sclear          s              1
510 AD SSBflag         s               n
CWDbAD svor2           s                   like(odor2)
510 AD totqty          s              5  0
     D ttlcub          s              9  3
     D ttlwgt          s              9  2
     D ttlpcs          s              5  0
     D warn            s              1
650eAD wopqn1          s              3  0
650eAD wopqn2          s              3  0
650eAD wopqn3          s              3  0
640dAD sectioncode     s              2
650eAD zmsflag         s               n
720aAD prg1c           s              4  3
720aAD prg2c           s              4  3
720aAD $rwcwgt         s              7  2

     D #sentitem       s                   like($ititem)
     D #senttype       s                   like($ittype)
     D #sentdesc       s                   like($itdesc)
     D #sentpdsc       s                   like($itpdsc)
     D #sentwhdp       s                   like($itwhdp)
     D #sentstyp       s                   like($itstyp)
     D #sentdesg       s                   like($itdesg)
     D #sentum1        s                   like($itum1)
     D #sentflg1       s                   like($itflg1)
     D #sentum2        s                   like($itum2)
     D #sentumq2       s                   like($itumq2)
     D #sentflg2       s                   like($itflg2)
     D #sentum3        s                   like($itum3)
     D #sentumq3       s                   like($itumq3)
     D #sentcube       s                   like($itcube)
     D #sentswgt       s                   like($itswgt)
     D #sentmitem      s                   like($itmitem)

     D #slotitem       s                   like($ititem)
     D #slottype       s                   like($ittype)
     D #slotdesc       s                   like($itdesc)
     D #slotpdsc       s                   like($itpdsc)
     D #slotwhdp       s                   like($itwhdp)
     D #slotstyp       s                   like($itstyp)
     D #slotdesg       s                   like($itdesg)
     D #slotum1        s                   like($itum1)
     D #slotflg1       s                   like($itflg1)
     D #slotum2        s                   like($itum2)
     D #slotumq2       s                   like($itumq2)
     D #slotflg2       s                   like($itflg2)
     D #slotum3        s                   like($itum3)
     D #slotumq3       s                   like($itumq3)
     D #slotnrpk       s                   like($imnrpk)
     D #slotflgd       s                   like($itflgd)
     D #slotcube       s                   like($itcube)
     D #slotswgt       s                   like($itswgt)
     D #slotcwgt       s                   like($itcwgt)
     D #slotmitem      s                   like($itmitem)

     D #ssbitem        s                   like($ititem)
     D #ssbtype        s                   like($ittype)
     D #ssbdesc        s                   like($itdesc)
     D #ssbpdsc        s                   like($itpdsc)
     D #ssbwhdp        s                   like($itwhdp)
     D #ssbstyp        s                   like($itstyp)
     D #ssbdesg        s                   like($itdesg)
     D #ssbum1         s                   like($itum1)
     D #ssbum2         s                   like($itum2)
     D #ssbumq2        s                   like($itumq2)
     D #ssbum3         s                   like($itum3)
     D #ssbumq3        s                   like($itumq3)

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

750 A /copy qcopysrc,p.gettbtyp

720aA*----------------------------------------------------------------
720aA*  Called programs
720aA*
720aAD @catchwgt       c                   const('RU312')
720aAD @catchwgt2      c                   const('CE120')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Add detail line
     *              *CHANGE  - Change detail line
     *              *PRINT   - Print labels for detail line.
     *              *SUB     - Add substitue line (orig item sent in).
640iA*              *SUBRUN  - Runner pgm looking for sub.
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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms
640hAC                   parm                    $isub

750 A /free
750 A     // Determine if using TruckBUilder Enhanced
750 A
           $vWhse = $pWhse;
750 A      GetTBType($vWhse: $pRteId: tbType);
750 A      if tbType = 'E';
750 A        tbEnhanced = *on;
750 A        tbPalletType = 'P';
750 A      else;
750 A        tbEnhanced = *off;
750 A        tbPalletType = 'O';
750 A      endif;
750 A /end-free

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
650eA*  CRTRPKSLOT  Create virtual on-demand slot for repack sub item
650eA*----------------------------------------------------------------
650eA
650eAC     crtRpkSlot    begsr
650eA
      /free
            chain ($pwhse:w1itm) kititem;
            if not %error and %found;
               if kidisp <> ' ';
                  exsr clr$slot;
                  $slwhseu = *on;
                  $slwhse  = $pwhse;
                  $slwhdpu = *on;
                  $slwhdp  = $itWhdp;
                  $slitemu = *on;
                  $slitem  = $ititem;
                  $slstatu = *on;
                  $slstat = 'A';
                  $sldispu = *on;
                  $sldisp  = kidisp;
                  $slaislu = *on;
                  $slaisl  = ' ';
                  $slpsequ = *on;
                  $slpseq  = 0;
                  $slrlvlu = *on;
                  $slrlvl  = 0;
                  $slhandu = *on;
                  $slhand  = ' ';
                  $slprtyu = *on;
                  $slprty  = -9;
                  $slexpdu = *on;
                  $slexpd  = 0;
                  $slentdu = *on;
                  $slentd  = 0;

                  $dricommand = '*SLOT';
                  $drisubcmd  = '%CRTREPAKD';
                  $drisys2upd = 'D';
                  exsr zzzdricop;
                  error = *off;
               endif;
            endif;
      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr

     *   Set ON alarm indicator if error occured

     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif

     *   Overlay screen with error messages

     C                   exsr      zmdmsg

     *  Overlay screen with screen to be processed.

     C                   if        nxtscr = '01 '
640iAC                             and $pcmd <> '*SUBRUN '
     C                   exfmt     screen1                              50
640iAC                   else
640iAC                   exfmt     screen81                             50
     C                   endif

     *   Initialize error indicators and fields

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
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0

     *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr

650eA*----------------------------------------------------------------
650eA*  rpkqty   Calculate qtys.
650eA*----------------------------------------------------------------
650eA
650eAC     rpkqty        begsr
650eA
650eA
     *  Protect against negatives.

     C                   if        kcqty1 < 0
     C                   eval      kcqty1 = 0
     C                   endif
     C                   if        kcqty2 < 0
     C                   eval      kcqty2 = 0
     C                   endif
     C                   if        kcqty3 < 0
     C                   eval      kcqty3 = 0
     C                   endif

     *  Calculate parent qty needed.

     c                   if        kiQty1 > 1
     c                   eval      outPutQty = kiqty1
     c                   eval      wopqn1 = w1qor1*kcQty1
     c                   eval      wopqn2 = w1qor1*kcQty2
     c                   eval      wopqn3 = w1qor1*kcQty3
     c                   exsr      zzUpqty
     c                   exsr      zzadjQty
     c                   exsr      zzUpqty
     c                   else
     c                   eval      outPutQty = 1
     C                   eval      wopqn1 = kcqty1 * w1qor1
     C                   eval      wopqn2 = kcqty2 * w1qor1
     C                   eval      wopqn3 = kcqty3 * w1qor1
     c                   endif

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   eval      nxtscr = '01 '

     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif

     *  Get field defaults if this is an add.

     C                   if        $pcmd = '*ADD' or $pcmd = '*SUB'
640iAC                             or $pcmd = '*SUBRUN '
     C                   exsr      zzdft1
CWDbA*
CWDbAC                   if        client = Cashwa
GFCbAC                             or client = Glazier
KFSbAC                             or client = Kellys
HKW AC                             or client = Hearnkirkwood
SOFbAC                             or client = Sofofoods
CWDbAC                   eval      svor2 = 0
CWDbAC                   exsr      zzget1
CWDbAC                   unlock    ordd
CWDbAC                   eval      svor2 = odor2
CWDbAC                   endif
CWDbA*
     C                   else

     *  Otherwise get existing record(s).

     C                   eval      *in91 = *on
CWDbAC                   if        client = Cashwa
GFCbAC                             or client = Glazier
KFSbAC                             or client = Kellys
SOFbAC                             or client = Sofofoods
CWDbAC                   eval      svor2 = 0
CWDbAC                   endif
     C                   exsr      zzget1
CWDbAC                   if        client = Cashwa
GFCbAC                             or client = Glazier
KFSbAC                             or client = Kellys
SOFbAC                             or client = Sofofoods
CWDbAC                   eval      svor2 = odor2
CWDbAC                   endif
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

     C     sc1           begsr

     *  Test for F3 - Exit

     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif

     *  Test for other command keys BEFORE verification and update.

     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Some other key pressed.
     *
     *     Check input and write/update record.

     C                   if        $pcmd = '*ADD'
     C                             or $pcmd = '*SUB'
     C                             or $pcmd = '*CHANGE'
640iAC                             or $pcmd = '*SUBRUN '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
     C                   endif

     *  Test for other command keys AFTER verification and update.

     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

710aA*  Call program to load the sub item if client uses Loader Module

710aAC                   if        oprloa = 'Y'
710aAC                   call      'LOADR10S'
710aAC                   endif

     *  Everything went fine so get out of program.

     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
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
500mA
500mA* Get client id.
500mA
500mAC                   call      'GETCLIENT'
500mAC                   parm                    client           10
500mAC                   parm                    cliloc           10

     *  Initialize special keys

     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

     *  Initialize message handling

     C                   exsr      zmimsg

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
640iAC                   select
640iAC                   when      $pcmd = '*SUBRUN '
640iAC                   write     m08ctl
640iAC                   other
     C                   write     msgctl
640iAC                   endsl
     C                   eval      msgk = *zeros
640iAC                   select
640iAC                   when      $pcmd = '*SUBRUN '
640iAC                   write     m08clr
640iAC                   other
     C                   write     msgclr
640iAC                   endsl
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
640iAC                   select
640iAC                   when      $pcmd = '*SUBRUN '
640iAC                   write     m08ctl
640iAC                   other
     C                   write     msgctl
640iAC                   endsl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #pgm
     C                   exsr      zmcmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

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
640iAC                   select
640iAC                   when      $pcmd = '*SUBRUN '
640iAC                   write     m08rec
640iAC                   other
     C                   write     msgrec
640iAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
640iAC                   select
640iAC                   when      $pcmd = '*SUBRUN '
640iAC                   write     m08rec
640iAC                   other
     C                   write     msgrec
640iAC                   endsl
     C                   endsr

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

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

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
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

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
510 A*    PIR0110  Qty is required
     *----------------------------------------------------------------

510 AC     zm0110        begsr
510 AC                   eval      #msgid = 'PIR0110'
510 AC                   eval      #msgtp = '*DIAG  '
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zmpmsg
510 AC                   endsr

     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *----------------------------------------------------------------

     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *----------------------------------------------------------------

     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *----------------------------------------------------------------

     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *----------------------------------------------------------------

     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
510 A*   PIR9999  Generic error for message from array.
     *----------------------------------------------------------------

510 AC     zm9999        begsr
510 AC                   eval      #msgid = 'PIR9999'
510 AC                   eval      #msgtp = '*DIAG  '
510 AC                   exsr      zmpmsg
510 AC                   endsr

650eA*----------------------------------------------------------------
650eA*  ZZADJQTY Adjust parent quantity required per the output
650eA*           factor configured in KITITEM as part of Repack Itm
650eA*----------------------------------------------------------------
650eA
650eAC     zzadjqty      begsr
      /free

       // Each quantity will be reviewed.  The total quantity requested
       // will be divided by the output quantity defined in item maint.
       // This value is found in KITITEM.  If that value exceeds 1 then
       // the user is saying this represents on of these items.
       // Therefore, if the user requested 10 and
       // the components say they make 2 then we would divide the 10
       // by 2 to get 5.  5 times the component list is what would be
       // consumed to make these 10 pieces. The remainder is placed in
       // the breakdown quantity below that level

          // determine lowest level defined in item maintenance
          select;
             when #bumq3<>0;
                wopqndec = (wopqn1 * #bumq2
                              * #bumq3) +
                           (wopqn2 * #bumq3)+
                            wopqn3;
                wopqndec = (wopqndec / OutPutQty);
           // if it is decided later to enforce zero decimals between
           // output quantity in kititem and parent quantity in kitcomp
           // just take out the adding 1 if dec>0.  You will also need
           // to make changes marked in IT116
               if dec>0;
                  wopqn3 = wopqndec +1;
               else;
                  wopqn3 = wopqndec;
               endif;
                wopqn1 = 0;
                wopqn2 = 0;

             when #bumq2<>0;
                wopqndec = (wopqn1 * #bumq2) +
                            wopqn2;
                wopqndec = (wopqndec / OutPutQty);
           // if it is decided later to enforce zero decimals between
           // output quantity in kititem and parent quantity in kitcomp
           // just take out the adding 1 if dec>0.  You will also need
           // to make changes marked in IT116
               if dec>0;
                  wopqn2 = wopqndec +1;
               else;
                  wopqn2 = wopqndec;
               endif;
                wopqn1 = 0;
                wopqn3 = 0;

             other;
                wopqndec = (wopqn1 / OutPutQty);
           // if it is decided later to enforce zero decimals between
           // output quantity in kititem and parent quantity in kitcomp
           // just take out the adding 1 if dec>0.  You will also need
           // to make changes marked in IT116
               if dec>0;
                  wopqn1 = wopqndec +1;
               else;
                  wopqn1 = wopqndec;
               endif;
                wopqn2 = 0;
                wopqn3 = 0;

          endsl;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  When adding or subbing ....

     C                   if        $pcmd = '*ADD' or $pcmd = '*SUB'
640iAC                             or $pcmd = '*SUBRUN '

530 A*    Do not allow user to enter the original item and u/m qty
530 A*     as the sub item and u/m qty.

530 AC                   if        $pcmd = '*SUB'
640iAC                             or $pcmd = '*SUBRUN '

530 A*  Get original item ordd record, throw error if not found.
530 AC     origky        chain(n)  record                             79
530 AC                   if        *in79
530 AC                   eval      error = *on
530 AC                   eval      *in22 = *on
530 AC                   eval      *in02 = *on
530 AC                   movea     desc(6)       errmsg
530 AC                   movea     errmsg        $md(1)
530 AC                   exsr      zm9999
530 AC                   goto      endck1
530 AC                   endif

     *  Get original item orddm record, hold fields if not found.
CWDcAC                   if        client = Cashwa
CWDcAC     origky        chain(n)  orddm                              79
CWDcAC                   if        not *in79
CWDcAC                   eval      hmsc1 = ommsc1
CWDcAC                   endif
CWDcAC                   endif

530 A*  Compare orig item & u/m to sub item & u/m, throw error if equal.
530 AC                   select
530 AC                   when      oditem = w1itm
530 AC                   if        odqor1 > 0 and w1qor1 > 0
530 AC                             or
530 AC                             odqor2 > 0 and w1qor2 > 0
530 AC                             or
530 AC                             odqor3 > 0 and w1qor3 > 0
530 AC                   eval      error = *on
530 AC                   eval      *in22 = *on
530 AC                   eval      *in02 = *on
530 AC                   movea     desc(7)       errmsg
530 AC                   movea     errmsg        $md(1)
530 AC                   exsr      zm9999
530 AC                   goto      endck1
530 AC                   endif
530 AC                   endsl

530 AC                   endif

640hA*    Verify item substitute against ITEMSUB file.
720bA*     Unless user is subbing same item with different u/m.
720bAC                   if        oditem <> w1itm
640hA
640hAC                   eval      $cmd1 = '*VERIFY   '
640hAC                   eval      $whs30 = $pwhse
640hAC                   call      'GETITEMSUB'
640hAC                   parm                    $cmd1
640hAC                   parm                    $whs30            3 0
640hAC                   parm                    hld_$pitem
640hAC                   parm                    ohcust
640hAC                   parm                    w1itm
640hAC                   parm                    $prtn
640hAC                   parm                    $perm
640hAC                   if        $prtn = '*ERROR'
640hAC                   eval      error = *on
640hAC                   eval      *in22 = *on
640hAC                   eval      *in02 = *on
640hAC                   movea     $perm         $md(1)
640hAC                   exsr      zm9999
640hAC                   goto      endck1
640hAC                   endif
720bAC                   endif

     *    Verify item number

     C                   exsr      clr$item
     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   goto      endck1
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentcube = $itcube
     C                   eval      #sentswgt = $itswgt
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   if        #sentumq2 <= 0
     C                   eval      #sentumq2 = 1
     C                   endif
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3
     C                   if        #sentumq3 <= 0
     C                   eval      #sentumq3 = 1
     C                   endif

     *    Get corresponding "slot" item for "sent" item.

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   goto      endck1
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
     C                   if        #slotumq2 <= 0
     C                   eval      #slotumq2 = 1
     C                   endif
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   if        #slotumq3 <= 0
     C                   eval      #slotumq3 = 1
     C                   endif
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
     C                   eval      #slotcube = $itcube
     C                   eval      #slotswgt = $itswgt
     C                   eval      #slotcwgt = $itcwgt

     *    Make sure code doesn't already exist.

     C                   eval      $pitem = w1itm
510 DC**   fileky        chain     record
510 MC     kyordd        chain     record
     C                   if        %found
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = 'Order Detail Line'
     C                   exsr      zm02
     C                   goto      endck1
     C                   endif

510 A*   Get SSB item, if one exists

510 AC                   eval      SSBflag = *off
640aDC*****              if        #senttype = ' '
640aMC                   if        #senttype = 'S'
650dDC*                  call      'GETSSB'
650dDC*                  parm      $pwhse        $gwhse            3 0
650dDC*                  parm                    w1itm            15
650dDC*                  parm      ' '           #bitem           15
650dDC*                  parm                    #bdesc           30
650dDC*                  parm                    #bpdsc           15
650dDC*                  parm                    #bwhdp            5
650dDC*                  parm                    #bstyp            1
650dDC*                  parm                    #bum              2
650dDC*                  parm                    #bum2             2
650dDC*                  parm                    #bumq2            3 0
650dDC*                  parm                    #bum3             2
650dDC*                  parm                    #bumq3            3 0
650dDC*                  parm                    #brtn             8
     *
650dDC*                  if        #brtn = '*FOUND  '
510 AC                   eval      SSBflag = *on
650dDC*                  endif
510 AC                   endif

     C                   endif
     ***** End of Add / Substitute logic

     *    Verify original item number (optional)

     C                   if        w1oit <> ' '
     C                   exsr      clr$item
     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = w1oit

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify normal qty ordered is within range - optional.

     C                   if        w1qor1 < 0  or
     C                             w1qor1 > 99999
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = ' '
     C                   eval      erfld = 'Normal Qty'
     C                   eval      erfrom = '0'
     C                   eval      erto = '99999'
     C                   exsr      zm0112
     C                   endif

     *  Verify breakdown 1 qty ordered is within range - optional.

     C                   if        w1qor2 < 0  or
     C                             w1qor2 > 99999
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = ' '
     C                   eval      erfld = 'Breakdown 1 Qty'
     C                   eval      erfrom = '0'
     C                   eval      erto = '99999'
     C                   exsr      zm0112
     C                   endif

     *  Verify breakdown 2 qty ordered is within range - optional.

     C                   if        w1qor3 < 0  or
640iDC**                           w1qor3 > 99999
640iMC                             w1qor3 > 9999
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = ' '
     C                   eval      erfld = 'Breakdown 2 Qty'
     C                   eval      erfrom = '0'
640iDC**                 eval      erto = '99999'
640iMC                   eval      erto = '9999'
     C                   exsr      zm0112
     C                   endif

510 A*  Verify that a quantity was entered.

510 AC                   eval      totqty = w1qor1 + w1qor2 + w1qor3
510 AC                   if        totqty <= 0
510 AC                   eval      error = *on
510 AC                   eval      *in24 = *on
510 AC                   eval      *in04 = *on
510 AC                   eval      errmsg = 'Quantity ordered'
510 AC                   exsr      zm0110
510 AC                   goto      endck1
510 AC                   endif

510 A*  Verify that brkdwn 1 qty is allowed.

510 AC                   if        w1qor2 <> 0 and
510 AC                             #sentflg1 = 'N'
650eAC                             or w1qor2 <> 0
650eAC                             and #senttype = 'R'
510 AC                   eval      error = *on
510 AC                   eval      *in25 = *on
510 AC                   eval      *in05 = *on
510 AC                   movea     desc(1)       errmsg
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zm9999
510 AC                   goto      endck1
510 AC                   endif

510 A*  Verify that brkdwn 2 qty is allowed.

510 AC                   if        w1qor3 <> 0 and
510 AC                             #sentflg2 = 'N'
650eAC                             or w1qor3 <> 0
650eAC                             and #senttype = 'R'
510 AC                   eval      error = *on
510 AC                   eval      *in26 = *on
510 AC                   eval      *in06 = *on
510 AC                   movea     desc(2)       errmsg
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zm9999
510 AC                   goto      endck1
510 AC                   endif

510 A*  Verify that brkdwn 1 qty is 0 if SSB item.

510 AC                   if        w1qor2 <> 0 and
510 AC                             SSBflag = *on
510 AC                   eval      error = *on
510 AC                   eval      *in25 = *on
510 AC                   eval      *in05 = *on
510 AC                   movea     desc(3)       errmsg
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zm9999
510 AC                   goto      endck1
510 AC                   endif

510 A*  Verify that brkdwn 2 qty is 0 if SSB item.

510 AC                   if        w1qor3 <> 0 and
510 AC                             SSBflag = *on
510 AC                   eval      error = *on
510 AC                   eval      *in26 = *on
510 AC                   eval      *in06 = *on
510 AC                   movea     desc(4)       errmsg
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zm9999
510 AC                   goto      endck1
510 AC                   endif

JORb *  Default slot to item pick slot for Jordano's
JORbAC                   if        client = jordanos
JORbAC                   exsr      zzcmdgetslot
JORbAC                   endif
     *  Verify slot number (only when rte at Built or Printed status).

     C                   if        rtebuilt or rteprinted

650eA*  Create virtual on-demand slot for repack sub item.
650eAC                   if        #senttype = 'R'
650eAC                   exsr      crtRpkSlot
650eAC                   else

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #sentwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
520cA*  When client is Outbound Only, still need DRICOP to go and get
520cA*  slot fields, but ignore any error conditions it comes back with,
520cA*  as the slot file for Outbound Only has no item data, etc.
520cA*  See next logic which only verifies dept and section.
     C                   if        error
520cAC                             and opfeat <> '3'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   goto      endck1
520cAC                   else
520cAC                   eval      error =  *off
     C                   endif
650eAC                   endif
     C                   endif

520cA*  When client is Outbound Only, verify that the slot entered is
520cA*  in the same dept/section as the sub item.

520cAC                   if        (rtebuilt or rteprinted) and opfeat = '3'
520cAC     keysl         chain     slot2
520cAC                   if        not %found(slot2)  or
520cAC                             %found(slot2) and #sentstyp <> s_slstyp
520cAC                   eval      error = *on
520cAC                   eval      *in27 = *on
520cAC                   eval      *in07 = *on
520cAC                   movea     desc(5)       errmsg
520cAC                   movea     errmsg        $md(1)
520cAC                   exsr      zm9999
520cAC                   goto      endck1
520cAC                   endif
520cAC                   endif

     *  Verify row/col exists (only when rte at Built or Printed status).

     C                   if        rtebuilt or rteprinted
750 DC*                  eval      kytype = 'O'
750 MC                   eval      kytype = tbPalletType
     C                   eval      kygen  = 1
     C     keyps2        chain(n)  pltsum2
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = 'Row and Column'
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify printer device (only when rte at Built or Printed status).

     C                   if        rtebuilt or rteprinted
     C                   if        w1dev = ' '
     C                             or (%subst(w1dev:1:1)='*'
     C                                 and w1dev <> '*SYSVAL'
     C                                 and w1dev <> '*JOB')
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = 'Printer device'
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '

     *  Test for F4 - Lookup

     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

     C                   select

640hM*     General item lookup, no item substitute was passed in.

     C                   when      row# = 11
640hAC                             and $isub = *blanks
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1itm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1itm = $litem
     C                   endif

640hA*     Item substitute lookup, an item substitute was passed in
640hA*     so show the user any other item substitutes that are defined.
640hA
640hAC                   when      row# = 11
640hAC                             and $isub <> *blanks
640hAC                   eval      *in02 = *on
640hAC                   eval      $lcmd = *blanks
640hAC                   eval      $lwhse = $pwhse
640hAC                   eval      $litem = w1oit
640hAC                   eval      $lcust = ohcust
640hAC                   call      'IT1900'
640hAC                   parm                    $lparm
640hAC                   if        $lrtn = '*SELECT '
640hAC                   eval      w1itm = $lisub
640hAC                   endif

     C                   other

     *     Cursor not on a valid lookup field.

     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl

     C                   goto      endcm1
     C                   endif

     *  Test for F9 - Pick Slot

     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

     C                   select

     *     Slot

640iA*     Full screen
     C                   when      row# = 15 and (rtebuilt or rteprinted)
520cAC                             and opfeat <> '3'
640iAC                             and $pcmd <> '*SUBRUN '
     C                   exsr      zzcmdgetslot
     C                   eval      *in07 = *on

640iA*     8 line screen
640iAC                   when      row# = 6 and (rtebuilt or rteprinted)
640iAC                             and opfeat <> '3'
640iAC                             and $pcmd = '*SUBRUN '
640iAC                   exsr      zzcmdgetslot
640iAC                   eval      *in07 = *on

     *     Pallet

640iA*     Full screen
     C                   when      row# = 16 and (rtebuilt or rteprinted)
640iAC                             and $pcmd <> '*SUBRUN '
     C                   exsr      zzcmdgetplt
     C                   eval      *in08 = *on

640iA*     8 line screen
640iAC                   when      row# = 7 and (rtebuilt or rteprinted)
640iAC                             and $pcmd = '*SUBRUN '
640iAC                   exsr      zzcmdgetplt
640iAC                   eval      *in08 = *on

     *     Device

     C                   when      row# = 18 and rteprinted
     C                   exsr      zzcmdgetdev
     C                   eval      *in09 = *on

     C                   other

     *     Cursor not on a valid lookup field.

     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl

     C                   goto      endcm1
     C                   endif

     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMDGETDEV   Get device of pallet.
     *----------------------------------------------------------------

     C     zzcmdgetdev   begsr

     *  Get pallet.

750 DC*                  eval      kytype = 'O'
750 MC                   eval      kytype = tbPalletType
     C                   eval      kygen  = 1
     C     keyps2        chain(n)  pltsum2
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = 'Row and Column'
     C                   exsr      zm1001
     C                   goto      endcmdgetdev
     C                   endif

     *  Change truck to be template.

640 AC                   eval      $ptruk = pstruk
640 A*
640 A* Get Zone Template Code if Template type is T=Truck
640 A*
640 AC     trkey         chain     truckh
640 AC                   if        %found(truckh) and thtype = 'T'
640 AC                   eval      $ptmpl =  thztmp
640 AC                   else
640 AC                   eval      $ptmpl =  $ptruk
640 AC                   endif

     *  Get picking options for zone.

640fDC*****              eval      kycode = '*PICKLBL'
640fMC                   eval      kycode = '*PICKLBA'
     C     keyopz        chain     optionz
510 DC**                 if        %eof
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      w1dev = '*NOTFOUND*'
     C                   goto      endcmdgetdev
     C                   endif
     C                   endif

640fAC                   eval      opzdta2 = opzdta
640fDC*****              eval      w1dev = oppdev
640fMC                   eval      w1dev = opdv1

     C     endcmdgetdev  endsr

     *----------------------------------------------------------------
     *  ZZCMDGETPLT   Get pallet original item is on.
     *----------------------------------------------------------------

     C     zzcmdgetplt   begsr

     C     keylw8        setll     worklbl8

     C                   dow       forever = forever
     C     keylw8        reade     worklbl8
     C                   if        %eof
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
510 DC**                 eval      errmsg = 'Item ' + %trim(w1itm)
510 MC                   eval      errmsg = 'Item ' + %trim(w1oit)
     C                                    + ' not found on a pallet'
     C                   exsr      zm0105
     C                   leave
     C                   endif

520 DC**                 if        lwgen <> 1
520 DC**                 iter
520 DC**                 endif

640dAC                   if        ohord <> lword
640dAC                   iter
640dAC                   endif

520 AC                   if        lwgen = 1
520 AC                             or lwgen = 2
520 AC                             and lwctr# <> 0
     C                   eval      dsplid = lwpal#
     C                   eval      w1row  = dsplrw
     C                   eval      w1col  = dsplcl

640dAC                   eval      sectioncode = *blanks
640dAC                   if        rteprinted
640dAC                   exsr      zzgetsection
640dAC                   endif

     C                   leave
520 AC                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZCMDGETSLOT  Get pick slot for item.
     *----------------------------------------------------------------

     C     zzcmdgetslot  begsr

     C                   exsr      clr$item
     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   goto      endcmdgetslot
     C                   endif

650eA*  Create virtual on-demand slot for repack sub item.
650eAC                   if        $ittype = 'R'
650eAC                   exsr      crtRpkSlot
650eAC                   else

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1itm
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'A'
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = ' '
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = ' '
     C                   eval      $slpsequ = *on
     C                   eval      $slpseq  = 0
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = 0
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = ' '
     C                   eval      $slprtyu = *on
510 DC**                 eval      $slprty  = 0
510 MC                   eval      $slprty  = -9
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = 0
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTPICK'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
650eAC                   endif
     C                   if        not error
     C                   eval      w1disp = $sldisp
650bA*  If error getting pick slot, blank out w1disp and turn error
650bA*  off so it doesn't return error to calling pgm just because
650bA*  it didn't find a pick slot.
650bAC                   else
650bAC                   eval      w1disp = *blanks
650bAC                   eval      error = *off
     C                   endif

     C     endcmdgetslot endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr

     *   Get next sequence number for order.
520aAC                   select

520aA*     This method uses the original item's seq# plus 1.
640iDC**                 when      $pcmd = '*SUB'
640iDC**                           and client = cityline
640iDC**                           or $pcmd = '*SUB'
640iDC**                           and client = ifd
640iDC**                           or $pcmd = '*SUB'
640iDC**                           and client = FischerFoods
650 DC*                  when      $pcmd = '*SUB' or $pcmd = '*SUBRUN '
650 MC                   when      ($pcmd = '*SUB' or $pcmd = '*SUBRUN ')
640iMC                             and (client = cityline
640iMC                              or  client = ifd
640iMC                              or  client = FischerFoods)
520aAC                   eval      w1seq  = $pseq + 1

520aAC                   other

520aA*     This method finds the highest seq# for the order and adds 1 to it.
     C                   eval      lastseq# = 0
     C     keyoh         setll     ordd
     C                   dow       forever = forever
     C     keyoh         reade(n)  ordd
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        odseq > lastseq#
     C                   eval      lastseq# = odseq
     C                   endif
     C                   enddo
     C                   eval      w1seq  = lastseq# + 1

520aAC                   endsl

     *   Position to the item number field.

     C                   eval      *in01 = *off
     C                   eval      *in02 = *on

     *   Initialize item to blanks.
640hDC**                 eval      w1itm  = ' '
640hMC                   eval      w1itm  = $isub

     C                   eval      w1qor1 = 0
510 DC**                 eval      w1um1  = 'CS'

     C                   eval      w1qor2 = 0
510 DC**                 eval      w1um2  = 'EA'

     C                   eval      w1qor3 = 0
510 DC**                 eval      w1um3  = ' '

     *   If doing a substitue, fill in orig item with sent item.

     C                   if        $pcmd = '*SUB'
640iAC                             or $pcmd = '*SUBRUN '
     C                   eval      w1oit  = $pitem
     C                   else
     C                   eval      w1oit  = ' '
     C                   endif

     C                   eval      w1disp = ' '

     C                   eval      w1row = 0
     C                   eval      w1col = 0
JORbA*
JORbAC                   if        client = jordanos
JORbA*    Get original row and column for pallet.
JORbAC                   exsr      zzcmdgetplt
JORbAC                   endif
JORbA*
640dAC                   eval      sectioncode = *blanks

     *    Get whse/dept of original item to use when getting default printer de

510dAC                   eval      origitem_whdp = ' '
510dAC                   exsr      clr$item
510dAC                   eval      $itwhse = $pwhse
510dAC                   eval      $ititem = $pitem

510dAC                   eval      $dricommand = '*ITEM'
510dAC                   eval      $drisubcmd  = '%GETMAIN'
510dAC                   eval      $drisys2upd = 'D'
510dAC                   exsr      zzzdricop
510dAC                   if        error = *off
510dAC                   eval      origitem_whdp = $itwhdp
510dAC                   endif

     C                   eval      w1dev  = '*JOB'

510dA*       Retrieve default printer device.
510dA*
510dAC                   eval      $styp  = 'F'
510dA*
510dAC                   call      'GETRPT'
510dAC                   parm      '*DEVFORM'    $CMD              8
510dAC                   parm      'RH182PR'     $lprt            10
510dAC                   parm      $pwhse        $whse             3 0
510dAC                   parm                    $styp             1
510dAC                   parm      origitem_whdp $whdp             5
510dAC                   parm      ' '           $desc            50
510dAC                   parm      ' '           $dev             10
510dAC                   parm      ' '           $form            10
510dAC                   if        $dev > ' '
510dAC                   eval      w1dev  = $dev
510dAC                   endif
510dA*

     *   Set non-display / protect flags.

510 A*     Display Qty Ordered fields: Normal, Brk1, and Brk2.

     C                   eval      *in92 = *off

510 DC**                 eval      *in93 = *on
510 MC                   eval      *in93 = *off

     *     Display slot and plt pos when stat is built or printed.

     C                   if        rtebuilt or rteprinted
650bAC                   if        $isub <> *blanks
650bAC                   exsr      zzcmdgetslot
650bAC                   exsr      zzcmdgetplt
650bAC                   endif

     C                   eval      *in94 = *off
     C                   else
     C                   eval      *in94 = *on
     C                   endif

     *     Display device when stat is printed.

     C                   if        rteprinted
     C                   eval      *in95 = *off
     C                   else
     C                   eval      *in95 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     *    NOT USED CURRENTLY BECAUSE *CHANGE IS NOT IMPLEMENTED.

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get record from main file.

     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif

     *  Record locked.

     C                   if        *in78
     C                   eval      error = *on
CWDbAC                   eval      odor2 = 0
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif

     *  Record not found.

     C                   if        *in79
     C                   eval      error = *on
CWDbAC                   eval      odor2 = 0
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C     endgt2        endsr

     *----------------------------------------------------------------
     *  zzgetdatetime  Get current date & time
     *----------------------------------------------------------------

     C     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

640dA*----------------------------------------------------------------
640dA*  zzgetsection   Get section code
640dA*----------------------------------------------------------------

640dAC     zzgetsection  begsr

     C                   eval      sectioncode = *blanks

     C     lwlbl#        chain     label
     C                   if        %found(label)

     C                   select
     C                   when      lbhnd2 = '*P'
     C                   eval      sectioncode = 'A'
     C                   when      lbhnd2 <> *blanks
     C                   eval      sectioncode = lbhnd2
     C                   other
     C                   eval      sectioncode = *blanks
     C                   endsl

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define keys

     *    Main file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
     C                   kfld                    $pseq
     C                   kfld                    $pitem

510 A*    ORDD file, using w1seq from screen1

510 AC     kyordd        klist
510 AC                   kfld                    $pwhse
510 AC                   kfld                    $pord
510 AC                   kfld                    w1seq
520aDC**                 kfld                    $pitem
520aAC                   kfld                    w1itm

     *    ORDH File

     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord

     *    RTEHED file

     C     keyrh         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohrte

510 A*    RTESUM file

510 AC     keyrs         klist
510 AC                   kfld                    $pwhse
510 AC                   kfld                    $prteid
510 AC                   kfld                    #sentwhdp

     *    PLTSUM2 file.

     C     keyps2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prteid
     C                   kfld                    kytype
     C                   kfld                    kygen
     C                   kfld                    w1row
     C                   kfld                    w1col

     *    OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 D ***                kfld                    pstruk
640 MC                   kfld                    $ptmpl
     C                   kfld                    psszon
     C
     C     keyopz2       klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 D ***                kfld                    pstruk
640 MC                   kfld                    $ptmpl

520cA*  Define key for OPTIONS file.

520cAC     keyop         klist
520cAC                   kfld                    $pwhse
520cAC                   kfld                    optcod            8

     *  PLTSTP2 file.
     *
     C     keypss1       klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     C                   kfld                    ohstop
     C                   kfld                    kysbsq

520cA*  Define key for SLOT file.

520cAC     keysl         klist
520cAC                   kfld                    $pwhse
520cAC                   kfld                    #sentwhdp
520cAC                   kfld                    w1disp

     *    WORKLBL8 file.

     C     keylw8        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prteid
     C                   kfld                    w1oit

530 A*    Original item key

530 AC     origky        klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    hld_$pord
530 AC                   kfld                    hld_$pseq
530 AC                   kfld                    hld_$pitem
640 A*
640 A*  Define key for TRUCKH file.
640 A*
640 AC     trkey         klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $ptruk
640gA*
640gA*  Define key for PIRITEM file.
640gA*
640gAC     itkey         klist
640gAC                   kfld                    $pwhse
650dDC*                  kfld                    #bitem
650dMC                   kfld                    w1itm
650eA*
650eA*  KITCOMP key
650eA
650eAC     keykc         klist
650eAC                   kfld                    $pwhse
650eAC                   kfld                    w1itm
640cA*
640cA*  Get system options.
640cA*
640cAC                   eval      optcod = '*GENPICK'
640cAC     keyop         chain     options                            79
640cAC                   if        *in79
640cAC                   eval      opsubt = 'N'
640cAC                   else
640cAC                   movel     opdata        oppdta
640cAC                   endif

710aA*  Get runner options to see if client uses Loader Module
710aA*
710aAC                   eval      optcod = '*RUNNER '
710aAC     keyop         chain     options                            79
710aAC                   if        *in79
710aAC                   eval      oprloa = 'N'
710aAC                   else
710aAC                   eval      opdat1 = opdata
710aAC                   endif

650bDC**                 eval      hld_$pord = $pord
650bDC**                 eval      hld_$pseq = $pseq
650bDC**                 eval      hld_$pitem = $pitem

     C                   eval      $lprg = #pgm
720aAC                   eval      $rprg = #pgm
720aAC                   eval      $rwhse = $pwhse
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

520bA*  Only allow subs for specific clients.

520bAC                   if        client = cityline or
520bAC                             client = royal or
520bAC                             client = sgc or
520bAC                             client = jordanos or
520bAC                             client = ifd or
SVLaAC                             client = saval or
RNZ AC                             client = renzi or
CWD AC                             client = cashwa or
DRY AC                             client = Dairyland or
MAT AC                             client = mattfd
FFCaAC                             or client = FischerFoods
FRF AC                             or client = FRF
CCP AC                             or client = CapitolCity
CSP AC                             or client = coastalsunbelt
CPC AC                             or client = cpc
NCSaAC                             or client = nicholas
EFCbDC**                           or client = eastland
EI aAC                             or client = ei
GFCaAC                             or client = gfc
JPF AC                             or client = palmer
SLBaAC                             or client = silberman
CDIaAC                             or client = cdi
640cAC                             or opsubt = 'Y'
520bAC                   else
520bAC                   eval      error = *on
520bAC                   eval      $prtn = '*ERROR'
520bAC                   eval      $perm = er(1)
520bAC                   goto      endinz2
520bAC                   endif

     *  Get warehouse description.

     C                   eval      whdesc = ' '

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   other
     C                   eval      whdesc = $vdesc
     C                   endsl

     *   Get Order Header record.

     C     keyoh         chain     ordh
     C                   if        not %found
520dAC                   eval      dssubf = 'N'
     C                   eval      error = *on
640hAC                   eval      ohcust = *zeros
GFCcA*
GFCcAC                   if        client = Glazier
GFCcAC                   eval      gfcmsc_sub = 'N'
GFCcAC                   endif
GFCcA*
SOFcA*
SOFcAC                   if        client = Sofofoods
SOFcAC                   eval      sofmsc_sub = 'N'
SOFcAC                   endif
SOFcA*
     C                   goto      endinz2
520dAC                   else
GFCcA*
GFCcAC                   select
GFCcAC                   when      client = Glazier
GFCcAC                   eval      gfcmsc_base = ohmisc
GFCcA*
SOFcAC                   when      client = Sofofoods
SOFcAC                   eval      sofmsc_base = ohmisc
SOFcA*
GFCcAC                   other
520dAC                   eval      dsmisc = ohmisc
GFCcA*
GFCcAC                   endsl
     C                   endif
IFDaDC*                  if        client = palmer and
JPFaMC                   if        (client = palmer
KFScAC                             or client = Kellys
IFDaAC                             or client = IFD) and
520dAC                             dssubf <> 'Y'
GFCcA*
GFCcAC                             or (client = Glazier
GFCcAC                                                 ) and
GFCcAC                             gfcmsc_sub <> 'Y'
SOFcA*
SOFcAC                             or (client = Sofofoods
SOFcAC                                                 ) and
SOFcAC                             sofmsc_sub <> 'Y'
GFCcA*
520bAC                   eval      error = *on
520bAC                   eval      $prtn = '*ERROR'
520bAC                   eval      $perm = er(2)
520bAC                   goto      endinz2
520dAC                   endif

     *   Get Route Header record.

     C     keyrh         chain     rtehed
     C                   if        not %found
     C                             or rhstat > '4'
     C                   eval      error = *on
     C                   goto      endinz2
     C                   endif

     *   Set route status flags.

     C                   eval      rteopen    = *off
     C                   eval      rtebuilt   = *off
     C                   eval      rteprinted = *off

     C                   eval      *in90 = *off

     C                   select

     C                   when      rhstat = '4'
     C                   eval      rteprinted = *on
     C                   eval      wostat = 'Printed'

     C                   when      rhstat = '3'
     C                   eval      rtebuilt = *on
     C                   eval      wostat = 'Built'

     C                   when      rhstat = '1'
     C                   eval      rteopen = *on
     C                   eval      wostat = 'Open '

     C                   other
     C                   eval      *in90 = *on
     C                   eval      rteopen = *on
     C                   eval      wostat = 'Other'

     C                   endsl

520cA*   Get *FEATURE options.

520cAC                   eval      optcod = '*FEATURE'
520cAC     keyop         chain     options
520cAC                   if        not %found(options)
520cAC                   eval      opfeat = '2'
520cAC                   else
520cAC                   eval      opfdta = opdata
520cAC                   endif
520cA*

520cA*   Set scrn ind to non-display F9=Pick slot for item if
520cA*   client is Outbound Only.

520cAC                   if        opfeat = '3'
520cAC                   eval      *in96 = '1'
520cAC                   endif

650bAC                   eval      hld_$pord = $pord
650bAC                   eval      hld_$pseq = $pseq
650bAC                   eval      hld_$pitem = $pitem

720aA* get system high / low variance
720aA*
720aAC                   ExSr      zzgetsyop

720aA*    Show warning if item has been previously subbed
720aA /free

720aA   *in41 = *off;

720aA   setll ($pwhse: $pord) ordd1;

720aA   dou forever <> forever;

720aA     reade ($pwhse: $pord) ordd1;
720aA     *in41 = *off;
720aA     if %eof(ordd1);
720aA       leave;
720aA     endif;

720aA     //  If you find an 'original item' value that matches the item
720aA     //  passed in you've got an item previously subbed ... show warning

720aA     if $pitem = od1_odoitm;
720aA       *in41 = *on;
720aA       leave;
720aA     endif;

720aA   enddo;

720aA /end-free

     *
     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
720aA*
720aA*  ZZGETSYOP  Get System Options record.
720aA*
720aAC     zzgetsyop     begsr
720aA*
     C                   eval      optcod = '*SYSTEM '
     *
     C     keyop         chain     options
     C                   if        not %found(options)
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = *zeros
     C                   eval      oprg2c = *zeros
     C                   eval      opuci  = 'N'
     C                   else
     C                   movel     opdata        opdta2
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off

     *  Set qty, weight and cube to be used.
     *
     C                   select
510 DC**                 when      #senttype = 'S'
510 MC                   when      SSBflag  = *on
     C                   eval      pickqty1 = 0
     C                   eval      pickqty2 = w1qor1
     C                   eval      pickqty3 = w1qor2
     C                   other
     C                   eval      pickqty1 = w1qor1
     C                   eval      pickqty2 = w1qor2
     C                   eval      pickqty3 = w1qor3
     C                   endsl

     *  Execute appropriate routine.

     C                   select
     C                   when      $pcmd = '*ADD' or $pcmd = '*SUB'
640iAC                             or $pcmd = '*SUBRUN '
     C                   exsr      zzupdadd
     C                   when      $pcmd = '*CHANGE'
     C                   exsr      zzupdchg
     C                   endsl

     *   Move key values to parameters

     C                   eval      $pseq = odseq
     C                   eval      $pitem = oditem
     C     endupd        endsr

     *----------------------------------------------------------------
     *  ZZUPDADD   Add record.
     *----------------------------------------------------------------

     C     zzupdadd      begsr

     *  Update slot quantity - only for Built and Printed routes.
520cA*  Do not update slot quantity for Outbound Only clients.

     *  This is done first because this has the biggest potential to have
     *  an error. Therefore, if an error occurs we can just get out and
     *  display it to the user without anything else haveing been created.

520cDC**                 if        rtebuilt or rteprinted
520cMC                   if        (rtebuilt or rteprinted)
520cAC                             and opfeat <> '3'
     C                   exsr      zzzupdslot
     C     error         cabeq     *on           endupdadd
     C                   endif

     *  Create order detail record.

     C                   exsr      zzzcrtordd
     C     error         cabeq     *on           endupdadd

510 A*  If route is at Open status, update RTESUM with detail
     *  record, then we're done so get out.

     C                   if        rteopen
510 AC                   exsr      zzzcalcopen
510 AC                   exsr      zzzupdrtesum
     C                   goto      endupdadd
     C                   endif

     *  Calculate pieces, cube and weight totals.

     C                   exsr      zzzcalcttl
510 AC                   exsr      zzzupdrtesum

     *  When route is at Printed status, create a picking transaction.
510cM*  Update PLTSUM totals.

     C                   if        rteprinted
     C                   exsr      zzzcrttran
510cMC                   exsr      zzzupdpltsum
760bAC                   exsr      zzzupdpltmsc
     C                   endif

510cD*  Update PLTSUM totals.

510cDC**                 exsr      zzzupdpltsum

     *  Create label record(s).

     C                   exsr      zzzcrtworklbl

510 A*  Update RTECSUM records.

510 AC                   exsr      zzzupdrtecsum

640iA*  If this was a runner sub, end the transaction.

640iAC                   if        $pcmd = '*SUBRUN '
640iAC                   exsr      zzzendtran
640iAC                   endif

     *  We're finished !!

     C     endupdadd     endsr

     *----------------------------------------------------------------
     *  ZZUPDCHG   Change record.
     *----------------------------------------------------------------

     C     zzupdchg      begsr
     C     endupdchg     endsr

     *----------------------------------------------------------------
650eA*  ZZUPQTY       Up quantity
650eA*----------------------------------------------------------------
650eA
650eAC     zzupqty       begsr
650eA
     C                   dow       #bumq3 > 0 and +
     C                               wopqn3 >= #bumq3
     C                   eval      wopqn3 -= #bumq3
     C                   eval      wopqn2 += 1
     C                   enddo

     C                   dow       #bumq2 > 0 and +
     C                               wopqn2 >= #bumq2
     C                   eval      wopqn2 -= #bumq2
     C                   eval      wopqn1 += 1
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
510 A*  ZZZCALCOPEN    Calculate open route totals.
     *----------------------------------------------------------------

510 AC     zzzcalcopen   begsr

510 A*  Total pieces.

510 AC                   eval      ttlpcs = pickqty1 + pickqty2 + pickqty3

510 A*  Total cube

510 AC                   eval      ttlcub = (#sentcube * pickqty1)
510 AC                                    + ((#sentcube/#sentumq2) * pickqty2)
510 AC                                    + (((#sentcube/#sentumq2)/#sentumq3)
510 AC                                         * pickqty3)

510 A*  Total weight

510 AC                   eval      ttlwgt = (#sentswgt * pickqty1)
510 AC                                    + ((#sentswgt/#sentumq2) * pickqty2)
510 AC                                    + (((#sentswgt/#sentumq2)/#sentumq3)
510 AC                                         * pickqty3)

510 AC                   endsr

     *----------------------------------------------------------------
     *  ZZZCALCTTL     Calculate totals.
     *----------------------------------------------------------------

     C     zzzcalcttl    begsr

     *  Total pieces.

     C                   eval      ttlpcs = pickqty1 + pickqty2 + pickqty3

     *  Total cube

     C                   eval      ttlcub = (#slotcube * pickqty1)
     C                                    + ((#slotcube/#slotumq2) * pickqty2)
     C                                    + (((#slotcube/#slotumq2)/#slotumq3)
     C                                         * pickqty3)

     *  Total weight

     C                   eval      ttlwgt = (#slotswgt * pickqty1)
     C                                    + ((#slotswgt/#slotumq2) * pickqty2)
     C                                    + (((#slotswgt/#slotumq2)/#slotumq3)
     C                                         * pickqty3)

     C                   endsr

720aA*----------------------------------------------------------------
720aA*  ZZZCRTCW  Create normal catchweights.
720aA*----------------------------------------------------------------

720aAC     zzzcrtcw      begsr

     *  Normal uom
     C                   if        w1qor1 <> *zeros
     C                             and itcwgt = 'Y'

     C                   eval      $rwhse = $pwhse
     C                   eval      $rlbl  = lblbl#
     C                   eval      $rqyfd = w1qor1
     C                   eval      $rwcwgt = *zeros
     C                   eval      $rlcwgt = *zeros
     C                   eval      $rhcwgt = *zeros

      * Calc low catch weight Variance
     C                   eval      $rwcwgt = lbuwgt * prg1c
     C                   eval      $rlcwgt = lbuwgt - $rwcwgt

      * Calc high catch weight Variance
     C                   eval      $rwcwgt = lbuwgt * prg2c
     C                   eval      $rhcwgt = lbuwgt + $rwcwgt

     C                   if        opuci  <> 'Y'
     C                   call      @catchwgt
     C                   parm                    $rparm
     C                   else
     C                   eval      $rcmd = '*PICK   '
     C                   call      @catchwgt2
     C                   parm                    $rparm
     C                   endif

     C                   endif

     C                   endsr

720aA*----------------------------------------------------------------
720aA*  ZZZCRTCW1  Create breakdown 1 catchweights.
720aA*----------------------------------------------------------------

720aAC     zzzcrtcw1     begsr

     *  Breakdown 1
     C                   if        w1qor2 <> *zeros
     C                             and itcwgt = 'Y'

     C                   eval      $rwhse = $pwhse
     C                   eval      $rlbl  = lblbl#
     C                   eval      $rqyfd = w1qor2
     C                   eval      $rwcwgt = *zeros
     C                   eval      $rlcwgt = *zeros
     C                   eval      $rhcwgt = *zeros

      * Calc low catch weight Variance
     C                   if        prg1c <> *zeros
     C                   eval      $rwcwgt = lbuwgt * prg1c
     C                   eval      $rlcwgt = lbuwgt - $rwcwgt
     C                   endif

      * Calc high catch weight Variance
     C                   if        prg2c <> *zeros
     C                   eval      $rwcwgt = lbuwgt * prg2c
     C                   eval      $rhcwgt = lbuwgt + $rwcwgt
     C                   endif

     C                   if        opuci  <> 'Y'
     C                   call      @catchwgt
     C                   parm                    $rparm
     C                   else
     C                   eval      $rcmd = '*PICK   '
     C                   call      @catchwgt2
     C                   parm                    $rparm
     C                   endif

     C                   endif

     C                   endsr

720aA*----------------------------------------------------------------
720aA*  ZZZCRTCW2  Create breakdown 2 catchweights.
720aA*----------------------------------------------------------------

720aAC     zzzcrtcw2     begsr

     *  Breakdown 2
     C                   if        w1qor3 <> *zeros
     C                             and itcwgt = 'Y'

     C                   eval      $rwhse = $pwhse
     C                   eval      $rlbl  = lblbl#
     C                   eval      $rqyfd = w1qor3
     C                   eval      $rwcwgt = *zeros
     C                   eval      $rlcwgt = *zeros
     C                   eval      $rhcwgt = *zeros

      * Calc low catch weight Variance
     C                   if        prg1c <> *zeros
     C                   eval      $rwcwgt = lbuwgt * prg1c
     C                   eval      $rlcwgt = lbuwgt - $rwcwgt
     C                   endif

      * Calc high catch weight Variance
     C                   if        prg2c <> *zeros
     C                   eval      $rwcwgt = lbuwgt * prg2c
     C                   eval      $rhcwgt = lbuwgt + $rwcwgt
     C                   endif

     C                   if        opuci  <> 'Y'
     C                   call      @catchwgt
     C                   parm                    $rparm
     C                   else
     C                   eval      $rcmd = '*PICK   '
     C                   call      @catchwgt2
     C                   parm                    $rparm
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTORDD   Create order detail record.
     *----------------------------------------------------------------

     C     zzzcrtordd    begsr

     C                   eval      odwhse = $pwhse
     C                   eval      odord  = $pord
     C                   eval      odseq  = w1seq
     C                   eval      oditem = w1itm
     C                   eval      odoitm = w1oit
     C                   eval      odqor1 = w1qor1
     C                   eval      odqor2 = w1qor2
     C                   eval      odqor3 = w1qor3
     C                   eval      odwh2  = 0
CWDaA*
CWDaAC                   if        client = Cashwa
GFCbAC                             or client = Glazier
KFSbAC                             or client = Kellys
HKW AC                             or client = Hearnkirkwood
SOFbAC                             or client = Sofofoods
CWDaA*  Set line number of item being subbed into corresponding order#
CWDaA*  for processing at export time.
CWDbAC                   if        svor2 > 0
CWDbAC                   eval      odor2 = svor2
CWDbAC                   else
CWDaAC                   eval      odor2 = $pseq
CWDbAC                   endif
CWDaAC                   else
650cDC*                  eval      odor2  = 0
650cMC                   eval      odor2  = $pseq
CWDaAC                   endif
FRFbA*
FRFbAC                   if        client = FRF
FRFbA*  Set line number of item being subbed into corresponding order#
FRFbA*  for processing at export time.
FRFbAC                   eval      odor2 = $pseq
FRFbAC                   endif
FRFbA*
     C                   eval      odspcl = ' '
     C                   eval      odqpk1 = 0
     C                   eval      odqpk2 = 0
     C                   eval      odqpk3 = 0

     C                   if        rteopen
     C                   eval      odstat = 'O'
     C                   else
     C                   eval      odstat = 'P'
     C                   endif

     C                   write(e)  record
     C                   if        %error
     C                   eval      error = *on
     C                   exsr      zm71
     C                   endif

     *
     *  Set line number of item being subbed into corresponding order#
     *  for processing at export time.
CWDcAC                   if        client = Cashwa
     C                   eval      omwhse = $pwhse
     C                   eval      omord  = $pord
     C                   eval      omseq  = w1seq
     C                   eval      omitem = w1itm
     C                   eval      omodsc = w1itm
     C                   eval      ommsc1 = hmsc1a + 'S' + hmsc1b
     *
     C                   write(e)  omrec
     C                   if        %error
     C                   eval      error = *on
     C                   exsr      zm71
     C                   endif
CWDcAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTLABEL  Create label record from WORKLBL record.
     *----------------------------------------------------------------

     C     zzzcrtlabel   begsr

     C                   clear                   lbrec

     C                   eval      lbwhse = lwwhse
     C                   eval      lbwhdp = lwwhdp
     C                   eval      lbseq  = lwseq
     C                   eval      lbitem = lwitem
     C                   eval      lbpbat = lwpbat
     C                   eval      lbaisl = lwaisl
     C                   eval      lbloc  = lwloc
     C                   eval      lbrlvl = lwrlvl
     C                   eval      lbhand = lwhand
     C                   eval      lbpseq = lwpseq
     C                   eval      lbstyp = lwstyp
     C                   eval      lbqryf = lwqryf
     C                   eval      lbdisp = lwdisp
     C                   eval      lbrte  = lwrte
     C                   eval      lbstop = lwstop
     C                   eval      lbord  = lword
     C                   eval      lbutyp = lwutyp
     C                   eval      lbucod = lwucod
     C                   eval      lbucub = lwucub
     C                   eval      lbcube = lwcube
     C                   eval      lbuwgt = lwuwgt
     C                   eval      lbswgt = lwswgt
     C                   eval      lbqalc = lwqalc
     C                   eval      lbqpck = lwqpck
     C                   eval      lbgrp1 = lwgrp1
     C                   eval      lbgrp2 = lwgrp2
     C                   eval      lbtype = lwtype
     C                   eval      lblbl# = lwlbl#
     C                   eval      lbpal# = lwpal#
     C                   eval      lbtrn# = lwtrn#
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = lwsdte
     C                   eval      lbstim = lwstim
     C                   eval      lbrdte = lwrdte

640dAC                   if        rteprinted
640dAC                   if        sectioncode <> *blanks
640dAC                   eval      lbhnd2 = sectioncode
640dAC                   endif
640dAC                   endif

     C                   write     lbrec

640dAC                   eval      sectioncode = *blanks

     C     endcrtlabel   endsr

640bA*----------------------------------------------------------------
640bA*  ZZZORDP  Create unique piece# record.
640bA*----------------------------------------------------------------
640bA
640bAC     zzzcrtordp    begsr
640bA

650aAC                   call      'OR637S'
650aAC                   parm                    lbwhse
650aAC                   parm                    lbrte
650aAC                   parm                    lblbl#

650aDC**                 clear                   orprec

650aD***       Initialize piece record fields.

650aDC**                 eval      orpwhs = lbwhse
650aDC**                 eval      orprid = lbrte
650aDC**                 eval      orpord = lbord
650aDC**                 eval      orpsq# = lbseq
650aDC**                 eval      orpitm = lbitem
650aDC**                 eval      orplbl = lblbl#
650aDC**                 eval      orpseq = 0
650aDC**                 eval      orpwgt = 0
650aDC**                 eval      orpcnt = 1
650aDC**                 eval      orpttl = 1
650aDC**                 eval      orpscn = lbqpck

650aD***       Create piece record.

650aDC**                 dow       forever = forever
650aDC**                 call      'PIRCADEC#'
650aDC**                 parm                    orpup#
650aDC**                 write(e)  orprec
650aDC**                 if        %error
650aDC**                 iter
650aDC**                 endif
650aDC**                 leave
650aDC**                 enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTTRAN   Create transaction
     *----------------------------------------------------------------

     C     zzzcrttran    begsr

640iA* If RH182 was called by runner program RU310, create and start
640iA* the transaction, else, just create it.

640iAC                   if        $pcmd = '*SUBRUN '
640iAC                   eval      @pcmd = '*CRTSTRT'
640iAC                   else
640iAC                   eval      @pcmd = '*CREATE'
640iAC                   endif

     C                   call      'ADJTRAN2'
640iDC**                 parm      '*CREATE'     @pcmd            10
640iMC                   parm                    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'FIXED'       @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      #sentwhdp     @pwhdp            5
     C                   parm      #sentstyp     @pstyp            1
     C                   parm      ttlcub        @pcube            9 3
     C                   parm      ttlwgt        @pswgt            9 2
     C                   parm      ttlpcs        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $prteid       @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      rhtype        @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTWORKLBL   Create WORKLBL record(s)
     *----------------------------------------------------------------

     C     zzzcrtworklbl begsr

640 AC                   eval      $ptruk = pstruk
640 A*
640 A* Get Zone Template Code if Template type is T=Truck
640 A*
640 AC     trkey         chain     truckh
640 AC                   if        %found(truckh) and thtype = 'T'
640 AC                   eval      $ptmpl =  thztmp
640 AC                   else
640 AC                   eval      $ptmpl =  $ptruk
640 AC                   endif
     C                   exsr      zzgetdatetime

720aA*  Calc high and low variances for catchweights

720aAC                   eval      itcwgt = ' '
720aAC     itkey         chain     piritem
720aAC                   if        itcwgt = 'Y'

720aAC     itkey         chain     itemmsc
720aAC                   if        not %found(itemmsc)
720aAC                   eval      imrg1c = *zeros
720aAC                   eval      imrg2c = *zeros
720aAC                   endif

720aAC                   eval      prg1c = *zeros
720aAC                   eval      prg2c = *zeros

720aAC                   If        imrg1c <> *zeros
720aAC                   eval      prg1c = imrg1c / 100
720aAC                   endif

720aAC                   If        imrg2c <> *zeros
720aAC                   eval      prg2c = imrg2c / 100
720aAC                   endif

720aAC                   if        prg1c = *zeros
720aAC                   eval      prg1c = oprg1c / 100
720aAC                   endif

720aAC                   if        prg2c = *zeros
720aAC                   eval      prg2c = oprg2c / 100
720aAC                   endif
720aAC                   endif

     *  Create WORKLBL record for Normal quantity.

     C     pickqty1      cable     0             brk1label

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
530aAC                   if        #senttype = 'S'
530aAC                   eval      lwutyp = '1'
530aAC                   eval      lwucod = #sentum2
530aAC                   else
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = #slotum1
530aAC                   endif
     C                   eval      lwucub = #slotcube
     C                   eval      lwcube = lwucub * pickqty1
510 DC**                 eval      lwuwgt = $itswgt
510 AC                   eval      lwuwgt = #slotswgt
     C                   eval      lwswgt = lwuwgt * pickqty1
     C                   eval      lwqalc = pickqty1
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty1
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
     C                   exsr      zzzprtlabel
720aAC                   exsr      zzzcrtcw
     C                   endif

     C     brk1label     tag

     *  Create WORKLBL record for Beakdown 1 quantity.

     C     pickqty2      cable     0             brk2label

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
     C                   eval      lwutyp = '1'
     C                   eval      lwucod = #slotum2
640gAC                   if        SSBflag = *on
640gAC     itkey         chain     piritem
640gAC                   if        %found(piritem)
640gAC                             and itumq2 <> 0
640gAC                   eval      lwucub = itcube/itumq2
640gAC                   eval      lwcube = lwucub * pickqty2
640gAC                   eval      lwuwgt = itswgt/itumq2
640gAC                   eval      lwswgt = lwuwgt * pickqty2
640gAC                   endif
640gAC                   else
     C                   eval      lwucub = #slotcube/#slotumq2
     C                   eval      lwcube = lwucub * pickqty2
510 DC**                 eval      lwuwgt = $itswgt/#slotumq2
510 AC                   eval      lwuwgt = #slotswgt/#slotumq2
     C                   eval      lwswgt = lwuwgt * pickqty2
640gAC                   endif
     C                   eval      lwqalc = pickqty2
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty2
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
     C                   exsr      zzzprtlabel
720aAC                   exsr      zzzcrtcw1
     C                   endif

     C     brk2label     tag

     *  Create WORKLBL record for Beakdown 2 quantity.

     C     pickqty3      cable     0             endcrtworklbl

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
     C                   eval      lwutyp = '2'
     C                   eval      lwucod = #slotum3
640gAC                   if        SSBflag = *on
640gAC     itkey         chain     piritem
640gAC                   if        %found(piritem)
640gAC                             and itumq2 <> 0
640gAC                             and itumq3 <> 0
640gAC                   eval      lwucub = (itcube/itumq2)/itumq3
640gAC                   eval      lwcube = lwucub * pickqty3
640gAC                   eval      lwuwgt = (itswgt/itumq2)/itumq3
640gAC                   eval      lwswgt = lwuwgt * pickqty3
640gAC                   endif
640gAC                   else
     C                   eval      lwucub = (#slotcube/#slotumq2)/#slotumq3
     C                   eval      lwcube = lwucub * pickqty3
     C                   eval      lwuwgt = (#slotswgt/#slotumq2)/#slotumq3
     C                   eval      lwswgt = lwuwgt * pickqty3
640gAC                   endif
     C                   eval      lwqalc = pickqty3
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty3
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
720aAC                   exsr      zzzcrtcw2
     C                   exsr      zzzprtlabel
     C                   endif

     C     endcrtworklbl endsr

640iA*----------------------------------------------------------------
640iA*  ZZZENDTRAN   End transaction
640iA*----------------------------------------------------------------
640iA
640iAC     zzzendtran    begsr
640iAC
     C                   call      'ADJTRAN2'
     C                   parm      '*ENDCUR'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*INTER'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      'FIXED'       @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      *blanks       @pwhdp            5
     C                   parm      rhtype        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      rhrte         @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      rhtype        @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZPRTLABEL  Print label(s)
     *----------------------------------------------------------------

     C     zzzprtlabel   begsr

640 AC                   eval      $ptruk = pstruk
640 A*
640 A* Get Zone Template Code if Template type is T=Truck
640 A*
640 AC     trkey         chain     truckh
640 AC                   if        %found(truckh) and thtype = 'T'
640 AC                   eval      $ptmpl =  thztmp
640 AC                   else
640 AC                   eval      $ptmpl =  $ptruk
640 AC                   endif

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
510 DC**                 if        %eof
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      opclvl = 999
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      oppdev = ' '
     C                   eval      oppfrm = ' '
     C                   endif
     C                   endif

     *  Set device to what user entered.

     C                   eval      oppdev = w1dev
     C                   eval      oppfrm = '*STD'

     *  Call picking label program to print label(s).

     C                   movel     oplpgm        @pgm              4
     C                   move      oplpgm        @set              6
414 A
510bAC                   select

JORaAC                   when      client = jordanos
FRFaAC                             or client = FRF
JORaA*  Skip printing of item substitution label.
510bA
CLDaAC                   when      client = cityline
RNZ AC                             or client = renzi
IFD AC                             or client = ifd
SVL AC                             or client = saval
CWD AC                             or client = cashwa
DRY AC                             or client = Dairyland
MAT AC                             or client = mattfd
CCP AC                             or client = CapitolCity
CSP AC                             or client = coastalsunbelt
FFCaAC                             or client = FischerFoods
FRFaDC**                           or client = FRF
JOR AC** JORaD                     or client = jordanos
CPC AC                             or client = cpc
NCSaAC                             or client = nicholas
EFCaAC                             or client = eastland
EI aAC                             or client = ei
GFCaAC                             or client = gfc
SLBaAC                             or client = silberman
CDIaAC                             or client = cdi
640cAC                             or opsubt = 'Y'
     C                   call      'PFMT'
     C                   parm      '*PRTLBL'     $pfcmd            8
     C                   parm                    @set
     C                   parm                    $pffmt            8
     C                   parm                    lbwhse
     C                   parm                    lbrte
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opzdta
CLDbAC                   parm                    lbtrn#
     C                   parm                    lblbl#
CLDbAC                   parm                    lbqpck
CLDbAC                   parm      0             $xcwt

510bAC                   other
510bAC                   call      'PFMT'
510bAC                   parm      '*PICK  '     $pfcmd            8
510bAC                   parm                    @set
510bAC                   parm                    $pffmt            8
510bAC                   parm                    lbwhse
510bAC                   parm                    lbrte
510bAC                   parm                    pscomp
510bAC                   parm                    pstzon
510bAC                   parm                    psgen
510bAC                   parm                    psszon
510bAC                   parm                    rhtruk
510bAC                   parm                    rhrte
510bAC                   parm                    opzdta
510bAC                   parm                    lbtrn#
510bAC                   parm                    lblbl#
510bAC                   parm                    lbqpck            5 0
510bAC                   parm      0             $xcwt             7 2
510bA
510bAC                   endsl

     C                   endsr

760bA*----------------------------------------------------------------
760bA*  ZZZUPDPLTMSC   Update PLTMISC
760bA*----------------------------------------------------------------

760bAC     zzzupdpltmsc  begsr
760bA
760bAc                   if        not tbenhanced
760bAc                   leavesr
760bAc                   endif
760bA
760bAc                   monitor
760bAc                   call      'OR630ADB'
760bAc                   parm                    $pWhse
760bAc                   parm                    $pRteId
760bAc                   on-error
760bAc                   endmon
760bAC                   endsr

     *----------------------------------------------------------------
     *  ZZZUPDPLTSUM   Update PLTSUM totals.
     *----------------------------------------------------------------

     C     zzzupdpltsum  begsr

     *  Get PLTSUM record.

     C     keyps2        chain     pltsum2
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      errmsg = 'Row and Column'
     C                   exsr      zm1001
     C                   goto      endupdpltsum
     C                   endif

     *  Update Stop, if necessary.

     C                   if        ohstop < psstp1  or
     C                             psstp1 = 0
     C                   eval      psstp1 = ohstop
     C                   endif
     C                   if        ohstop > psstp2  or
     C                             psstp2 = 0
     C                   eval      psstp2 = ohstop
     C                   endif

     *  Update Pieces, Cube, Weight.

     C                   eval      pspcs  = pspcs + ttlpcs
     C                   eval      psswgt = psswgt + ttlwgt
     C                   eval      pscube = pscube + ttlcub

510cA*  Update bulk pick label, psflag.

510cAC                   eval      pslbl# = 0
510cAC                   eval      psflag = '1'

     *  Update Transaction number under certain conditions.

510cDC***                if        rteprinted and pstrn# = 0
510cMC                   if        pstrn# = 0
     C                   eval      pstrn# = @ptrn#
510cM*  Update PLTSUM record.
510cMC                   update(e) psrec
510cMC                   if        %error
510cMC                   endif
510cAC                   else

510cDC***                update(e) psrec
510cDC***                if        %error
510cDC***                endif

750 A /free
750 A           // if tbEnhanced get next pallet id number for dd2
750 A           if tbEnhanced;
750 A             evalr oneChar = %editc(psplid:'X');
750 A             if oneChar = '9';
750 A               // keep using 9 if we have reached 9
750 A             else;
750 A               psplid = psplid + 1;
750 A             endif;
750 A           endif;
750 A /end-free
510cAC                   eval      pstrn# = @ptrn#
510cAC                   eval      pspcs  = ttlpcs
510cAC                   eval      psswgt = ttlwgt
510cAC                   eval      pscube = ttlcub
510cAC                   write     psrec
750 A /free
750 A           // if tbEnhanced update O record to reflect sub quantities
750 A           if tbEnhanced;
750 A             evalr oneChar = %editc(psplid:'X');
750 A             Oplid = psplid - %dec(onechar:1:0);
750 A             exec sql update pltsum15 set pspcs=pspcs+:ttlpcs,
750 A                                 pscube=pscube+:ttlcub,
750 A                                 psswgt=psswgt+:ttlwgt
750 A                   where pswhse=:pswhse and psrtid=:psrtid
750 A                     and psplid=:Oplid and pstype='O';
750 A           endif;
750 A /end-free
510cAC                   endif

510cAC                   unlock    pltsum2

     *  Update/Add PLTSTP record.

     C                   eval      kysbsq = 0
     C     keypss1       chain     pltstp1

     *    Record found - Update.

     C                   if        %found
     C                   eval      psspcs = psspcs + ttlpcs
     C                   eval      psscub = psscub + ttlcub
     C                   eval      pssswt = pssswt + ttlwgt
     C                   update    pssrec
     C                   if        %error
     C                   endif

     *    Record not found - Add.

     C                   else
     C                   eval      psswhs = pswhse
     C                   eval      pssrid = psrtid
     C                   eval      pssrow = psrow
     C                   eval      psscol = pscol
     C                   eval      pssstp = ohstop
     C                   eval      pssbsq = 0
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   eval      psspli = psplid
     C                   write     pssrec
     C                   if        %error
     C                   endif

     C                   endif

     C     endupdpltsum  endsr

     *----------------------------------------------------------------
510 A*  ZZZUPDRTECSUM   Update RTECSUM records.
     *----------------------------------------------------------------

510 AC     zzzupdrtecsum begsr

510 AC                   call      'OR626'
640eDC**                 parm      '*REBUILD'    $pcmd2            8
640eMC                   parm      '*SUBITEM'    $pcmd2            8
510 AC                   parm                    $pbat             7 0
650dMC                   parm      $pwhse        $gwhse            3 0
510 AC                   parm                    $potype           1
510 AC                   parm                    $prteid
510 AC                   parm                    $truck           10
640eAC                   parm      psplid        $pplid            7 0
640eAC                   parm      pstrn#        $ptrn             7 0
510 AC                   endsr

     *----------------------------------------------------------------
510 A*  ZZZUPDRTESUM   Update RTESUM records.
     *----------------------------------------------------------------

510 AC     zzzupdrtesum  begsr

510 A*  Get RTESUM record.

510 AC     keyrs         chain     rtesum
510 AC                   if        not %found

510 AC                   eval      rswhse = $pwhse
510 AC                   eval      rsrtid = $prteid
510 AC                   eval      rswhdp = #sentwhdp
510 AC                   eval      rsordc = 0
510 AC                   eval      rsordw = 0
510 AC                   eval      rsordp = 0
510 AC                   eval      rsordc = rsordc + ttlcub
510 AC                   eval      rsordw = rsordw + ttlwgt
510 AC                   eval      rsordp = rsordp + ttlpcs
510 AC                   eval      rspckc = 0
510 AC                   eval      rspckw = 0
510 AC                   eval      rspckp = 0
640eAC                   if        rteprinted
640eAC                   eval      rspckc = rspckc + ttlcub
640eAC                   eval      rspckw = rspckw + ttlwgt
640eAC                   eval      rspckp = rspckp + ttlpcs
640eAC                   endif
510 AC                   write     rsrec

510 AC                   else

510 AC                   eval      rsordc = rsordc + ttlcub
510 AC                   eval      rsordw = rsordw + ttlwgt
510 AC                   eval      rsordp = rsordp + ttlpcs
640eAC                   if        rteprinted
640eAC                   eval      rspckc = rspckc + ttlcub
640eAC                   eval      rspckw = rspckw + ttlwgt
640eAC                   eval      rspckp = rspckp + ttlpcs
640eAC                   endif
510 AC                   update    rsrec

510 AC                   endif

510 AC                   endsr

     *----------------------------------------------------------------
     *  ZZZUPDSLOT    Update slot quantity.
     *----------------------------------------------------------------

     C     zzzupdslot    begsr

     *  Note: All of the slot fields should contain the proper information
     *  because the slot was verified in ZZCHK1. Just make sure that all of
     *  the necessary field usage flags are set *on.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhdpu = *on

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1itm
     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = w1qor1
     C                   eval      $saqty2  = w1qor2
     C                   eval      $saqty3  = w1qor3

650eA*  Processing for repack items.

650eAC                   if        #senttype = 'R'

650eA*  If there's more than 1 KITCOMP rec do not upd slot qtys,
650eA*  just get out.
650eAC                   eval      kitcnt = 0
650eAC     keykc         setll     kitcomp
650eAC                   dow       forever = forever
650eAC     keykc         reade     kitcomp
650eAC                   if        %eof
650eAC                   leave
650eAC                   endif
650eAC                   eval      kitcnt = kitcnt + 1
650eAC                   if        kitcnt = 2
650eAC                   leave
650eAC                   endif
650eAC                   enddo
650eAC                   if        kitcnt = 1
650eAC                   exsr      zzzcrtodrstk
650eAC                   eval      $slitem = w1itm
650eAC                   eval      $saitem = w1itm
650eAC                   eval      $sldisp = w1disp
650eAC                   eval      $saqty1 = w1qor1
650eAC                   eval      $saqty2 = 0
650eAC                   eval      $saqty3 = 0
650eAC                   endif
650eAC                   endif

     *  Allocate the qty for a Built route.
     *  Pick the qty for a Printed route.

     C                   eval      $dricommand = '*SLOT'

     C                   if        rteprinted
     C                   eval      $drisubcmd  = '%PICK'
     C                   else
     C                   eval      $drisubcmd  = '%ALLOCATE'
     C                   endif

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

650eA*----------------------------------------------------------------
650eA*  ZZZCRTODRSTK     Create on demand stock.
650eA*----------------------------------------------------------------
650eA
650eAC     zzzcrtodrstk  begsr
650eA
     C                   call      'GETBASE'
     C                   parm      $pwhse        $gwhse            3 0
     C                   parm      #sentitem     $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8

     * Create Virtual pick slot for on demand repack item if one does
     * not exist.

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
     C                   eval      $slwhdp = #sentwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1itm

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = w1qor1

     C                   eval      $saqty2  = w1qor2
     C                   eval      $saqty3  = w1qor3

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'SUB'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'RH182 Sub'

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'

     C                   exsr      zzzdricop

     * Take Quantity out of Breaker slot.

     *** Retrieve Slot info from parent on-demand slot
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $gwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #bwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = kcdisp

     C                   eval      $dricommand = '*SLOT'
     c                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     c                   eval      odrppick = $sldisp

     C                   eval      $saactionu = *on
     c                   eval      $saAction = ' '

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     c                   clear                   $slot2
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $gwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = #bwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = odrppick

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = kccitm

     C                   exsr      rpkqty
     C                   if        wopqn1=0 and wopqn2=0 and wopqn3=0
     C                   leavesr
     C                   endif

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = -(wopqn1)
     C                   eval      $saqty2  = -(wopqn2)
     C                   eval      $saqty3  = -(wopqn3)

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'SUB'

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'RH182 Sub'

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTORD'
     C                   eval      $drisys2upd = 'D'

     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     c                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     c                              or $dricommand = '*SLOT'
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

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C                   exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C                   if        $dricommand = '*SLOT'
     C                             and $drireturn = 'EOF'
     C                   eval      $drimessage = 'Pick slot not found for item'
     C                   endif

520cA*  If Outbound Only, do not load SLOT $drimessage into msgrec subfile.
520cAC                   if        $dricommand = '*SLOT' and opfeat = '3'
520cAC                   else
650eAC                   if        $drireturn = 'INSLOT    '
650eAC                   eval      $drimessage = *blanks
650eAC                   else
     C                   exsr      zm0001
650eAC                   endif
520cAC                   endif
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
650eAc                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C     enddricop     endsr
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
BrkDwn 1 Qty Ordered not allowed for this item.        1
Brkdwn 2 Qty Ordered not allowed for this item.        2
BrkDwn 1 Qty Ordered not allowed for SSB item.         3
Brkdwn 2 Qty Ordered not allowed for SSB item.         4
Slot dept/section is different from the item.          5
Original item not found in order detail file.          6             530
Cannot sub same item and same u/m as original.         7             530
**
Client is not set up to use substitute add-ons.                  1   520bA
Customer does not allow substitute                               2
