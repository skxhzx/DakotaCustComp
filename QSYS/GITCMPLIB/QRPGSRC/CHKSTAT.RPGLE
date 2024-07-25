     *----------------------------------------------------------------
     *   Copyright (C) 1995 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CHKSTAT   Check slot status.
     *  03 March 1995
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
404 A*    08/18/97  DAS  4.04
     *      - Revised to never change a fixed pick slot to 'Z'.
408 A*    01/20/98  RH   4.08
     *      - Revised to never change a PIR Reserved slot to 'Z'.
     *
412 A*    08/18/99  DAS  4.12
     *      - Revised to change a fixed, pick, non-reserved slot
     *        slot to 'Z' when no overflow slots exist for the item.
414aA*    07/28/00  RRH  4.14a
     *      - Revised to change status exceptions.
     *      - Add OPTIONS, ITEMMSC to check multiple pick slots.
415aA*    07/28/01  RRH  4.15a
     *      - Revised to only change status to Z if qty is 0,
     *        do not change if qty is negative.
416aA*    07/02/02  RH   4.16a
     *      - Recompiled, ITEMMSC changed.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *
500zA*    12/20/04  MLB  5.00z
     *      - Enh: Revised program to add support for new Client id
     *        modifications.
530aA*    11/06/09  RH   5.30a
     *      - Enh: Add Designation code to parms, use to test for
     *        setting SPCL slots to status 'Z'
     *
640aA*    07/11/11  RH   6.40a
     *      - Enh: Add Exception 'F' SPCL desg pick slot if overflow
     *        exists.
     *
640bA*    10/11/12  DSA  6.40b
     *      - Added $pwhdp, $pdisp to parameters
     *      - Revised to look for open Directed Putaways
     *      - Removed some very old commented code.
     *
650 A*    02/10/14  KDE  6.50
     *      - When searching for pick slot it now looks for RP slot
     *        as well as normal pick slot.  It was forcing the slot
     *        status to "Z" if option opmpck was No and RP
     *        status was on slot instead of A
     *
700aA*    06/16/16  LMC  7.00
     *      - When counting the number of pick slots, check to see
     *        if the item being sent is in has a *EACH pick slot.
     *        if so reduce the nbrpck field by 1. We only allow 1
     *        *EACH pick slot.
720aA*    11/19/18  RH   7.20a
     *      - Fix: Skip USR slots when counting overflow.
     *
740aA*    06/23/20  RH   7.40a
750 A*    11/16/21  KDE  7.50
     *      - Fix: Do not change status for Drop Pick base slots
     *
FFC A*----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
FFCaA*    12/08/14  RTR  FFCa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
FFCbA*    03/09/15  RH   FFCb
     *      -  Fix: FFCa was not changing status for Virutal PIR slots
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    12/20/04  MLB  CLD
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    10/15/21  KDE  DRYa
     *      -  Enh: Revised program to allow non reserved pick slot
     *         to be changed to "Z" status even when overflow slots exists
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSTa *    04/24/14  GJA  WSTa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
WSTb *      11/10/16  GJA  WSTb
     *        -  Remove WSTa
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    10/13/14  GJA  PFCa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earls
     *
EOPaA*    10/11/18  KDE  EOPa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
EOPbA*    10/11/18  KDE  EOPb
     *      -  Enh: Revised program to change status of Virtual
     *         Pick Slots to Zero if nbr of pick slots exceeds
     *         number defined for item.
EOPcA*    10/11/18  KDE  EOPc
     *      - Enh: Adjustment for virtual pick slots
EOPdA*    12/07/18  RH   EOPd
     *      - Enh: Zero virtual pick slots not in aisle GRC
EOPeA*    03/07/19  MLB  EOPe
     *      - Enh: Added test for ind SlotSentIn to EOPd mod. Not
     *        passed in to pgm in all cases.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland Foods
     *
EFC A*    09/27/11  RH   EFC
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
EI  A*    09/01/11  RH   EIa
     *      -  Enh: Allow SPCL designatio code slots to go to 'Z'
     *         status.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle Distributing
     *
FDI A*    06/20/08  MLB  FDI
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
FPRa *    03/16/15  RH   FPRa
     *      - Enh: Add to HMW mod to not change status of SR showroom
     *        slots.
FPRb *    06/07/16  RH   FPRb
     *      - Fix: Change to NOT zero virtual pick slot unless SPCL
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
     *
GMM A*    09/18/12  RH   GMM
     *      -  Enh: Only allow virutal pick slots for SPCL desig to
     *         go to 'z' status.
GMMcA*    02/12/13  LMC  GMMc
     *      -  Enh: Only allow virutal pick slots location 199 whse 10
     *         go to 'z' status.
GMMdA*    08/05/13  RH   GMMd
     *      -  Fix: Add code like GFCb, transfer to change pick slot
     *         was leaving the from pick slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWa *    01/12/15  RTR  HMWa
     *      -  Enh: Revised program to not change status of Showroom
     *         status SR slots.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALaA*    10/13/09  MLB  HALa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
ICBaA*    07/15/12  GJA  ICBa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    07/22/15  GJA  JSLa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    04/12/05  MLB  JOR
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
JOR1A*    05/02/05  MLB  JOR1
     *      -  Enh: Revised program to change status of Virtual
     *         Pick Slots to Zero if nbr of pick slots exceeds
     *         number defined for item.
JOR2A*    05/05/05  MLB  JOR2
     *      -  Enh: Revised original change done with JOR to allow
     *         virtual pick slots to go to Zero status if the item
     *         number is 6 characters long and not a E.
JOR3A*    02/01/06  RH   JOR3
     *      -  Enh: Revised JOR2 change, to allow virtual
     *         pick slots to go to Zero status if the item
     *         number is 6 characters long and not a E and does
     *         NOT have overflow.
JOR4A*    10/15/07  MLB  JOR4
     *      -  Enh: Revised JOR change. Revised program to allow
     *         PIR slots to be verified and removed if virtual slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPC A*    03/26/07  MLB  TPC
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *      -  Added TPC to JOR modification.
TPC1A*    05/08/07  RH   TPC1
     *      -  Enh: Revised program to change status of Virtual
     *         Pick Slots to Zero if nbr of pick slots exceeds
     *         number defined for item.
TPC2A*    08/14/18  MLB  TPC2
     *      -  Enh: Revised program to allow PIR slots to be changed
     *         to Zero status. Fixed, virtual pick slots will be kept
     *         active.
TPC3A*    02/20/20  RH   TPC3
     *      -  Fix: TPC2 was keeping ALL virual pick slots even when
     *         Pick slot was changing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC A*    05/18/09  MLB  SGC  (applied GJA 1/13/11)
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
     *
YHAaA*    12/31/07  RH   YHAa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVLaA*    09/06/09  MLB  SVLa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
SVLbA*    11/06/09  RH   SVLb
     *      -  Enh: Allow SPCL designatio code slots to go to 'Z'
     *         status.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCaA*    12/16/10  GJA  GFCa
     *      -  Enh: Revised program to not change status of Virtual
GFCbA*    12/22/10  GJA  GFCb
     *      -  Fix: If transferring from one pick slot to another
     *         it was leaving the from pick slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy
     *
FBYa *    09/07/16  RTR  FBYa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Z.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*    03/16/16  RH   SBR
     *      - Enh: Revised program to not change status of Virtual
     *        Pick Slots to Zero.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *    09/07/16  RTR  FGLa
     *      - Enh: Added FGL to mod to not change status of Virtual
     *        Pick Slots to Z.
FGLb *    01/11/17  RH   FGLb
     *      - Fix: Added code for virutal pick slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
     *
PANaA*    07/28/17  RH   PANa
     *      - Enh: Revised program to not change status of Virtual
     *        Pick Slots to Zero
PANbA*    10/03/17  RH   PANb
     *      - Enh: Add if number of pick slots < max to PANa.
     *        Was not setting virutal pick to Z if moved to new
     *        virtual pick slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    02/26/18  MLB  SFP
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
SFP1A*    02/26/18  MLB  SFP1
     *      -  Enh: Revised program to change status of Virtual
     *         Pick Slots to Zero if nbr of pick slots exceeds
     *         number defined for item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQS A*    03/18/18  MLB  MQS
     *      - Enh: Revised program to only change status of Virtual
     *        Pick Slots with designation = SPCL or I/P.
     *        Per call from Roxanne.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cotati Foods
     *
COTaA*    06/21/18  MLB  COTa
     *      - Enh: Revised program to not change status of Virtual
     *        Pick Slots to Zero
COTbA*    06/21/18  MLB  COTb
     *      - Enh: Add if number of pick slots < max to PANa.
     *        Was not setting virutal pick to Z if moved to new
     *        virtual pick slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit
     *
MRTaA*    09/04/18  RH   MRTa
     *      - Enh: Revised program to not change status of Virtual
     *        Pick Slots to Zero like COT
MRTbA*    09/04/18  RH   MRTb
     *      - Enh: Add if number of pick slots < max to PANa.
     *        Was not setting virutal pick to Z if moved to new
     *        virtual pick slot.
MRTcA*    09/20/18  KDE  MRTc
     *      - Enh: Adjustment for virtual pick slots
MRTdA*    11/07/18  RTR  MRTd
     *      - Enh: changed previous Merit mods to only skip where
     *        status = 'RP', they have regular virtual picks that need
     *        to be removed.  ***** TEMP REMOVED ****
MRTeA*    11/19/18  RH   MRTe
     *      - Fix: Moved code to leave virtual pick slots if number
     *        of pick slot < max pick slots.  Previous mod error.
     *      - Fix: Treat aisle 99 like spcl order slots, Z if no
     *        overflow
MRTfA*    10/18/19  KDE  MRTf
     *      - Enh: Prevent 42-250-1 or 84-280-1 from being zero verified
     *        Requires 7.30c mod in PT132.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit
     *
GRC A*    07/30/18  MLB  GRC
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Zero.
GRC1A*    07/30/18  MLB  GRC1
     *      -  Enh: Revised program to change status of Virtual
     *         Pick Slots to Zero if nbr of pick slots exceeds
     *         number defined for item.
GRCcA*    10/02/18  KDE  GRCc
     *      - Enh: Adjustment for virtual pick slots
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's
     *
KFSaA*    03/14/19  RH   KFSa
     *      - Enh: Revised program to not change status of Virtual
     *        Pick Slots to Zero like COT
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
BADaA*    10/11/19  RH   BADa
     *      -  Enh: Revised to not remove virutal pick slots if not
     *         SPCL or # of pick slots < max.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vitco
VFIaA*    10/18/19  RH   VFIa
     *      -  Enh: Revised to not remove virutal pick slots if not
     *         SPCL or # of pick slots < max.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
HPCaA*    02/20/20  RH   HPCa
     *      -  Enh: Revised to not remove virutal pick slots if not
     *         SPCL or # of pick slots < max.
HPCbA*    06/23/20  RH   HPCb
     *      -  Enh: Add sr to treat virtual slots same as base slot
     *         set as reserve Y/N or SPCL.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Natalies
NOJa *    03/09/21  RH   NOJa
     *      -  Enh: Revised program to not change status of Virtual
     *         Pick Slots to Z.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Natalies
CBIa *    08/02/21  NLK  CBIa
     *      -  Enh: Revised program to not change status of Virtual
     *         Slots to Zero verify if Reserve is 'Y'.
     *----------------------------------------------------------------
     *  File Specs
     *
414aAFitemmsc   if   e           k disk
414aAFoptions   if   e           k disk
414aAFslot3     if   e           k disk
740aAFvslot1    if   e           k disk
740aAFslot2     if   e           k disk
     F                                     rename(slrec:slrec2)
500zA*----------------------------------------------------------------
500zA*  Customer id
500zA*
500zA /COPY QCOPYSRC,ID#CITYLIN
FDI A /COPY QCOPYSRC,ID#FINKLE
JOR A /COPY QCOPYSRC,ID#JORDANO
YHAaA /COPY QCOPYSRC,ID#YHATA
SGC A /COPY QCOPYSRC,ID#SGC
DRYaA /copy qcopysrc,id#dairyla
SVLaA /COPY QCOPYSRC,ID#SAVAL
EIa A /COPY QCOPYSRC,ID#EI
EFCaA /COPY QCOPYSRC,ID#EASTLAN
GFCaA /COPY QCOPYSRC,ID#GLAZIER
HALaA /COPY QCOPYSRC,ID#HALSEY
ICBaA /COPY QCOPYSRC,ID#ICB
GMMaA /COPY QCOPYSRC,ID#GMM
JSLaA /COPY QCOPYSRC,ID#JSL
SBRaA /COPY QCOPYSRC,ID#SBR
HMWaA /COPY QCOPYSRC,ID#hmwagne
WSTaA /COPY QCOPYSRC,ID#WESTSID
PFCaA /COPY QCOPYSRC,ID#PFC
FFCaA /COPY QCOPYSRC,ID#FISCHER
FPRaA /COPY QCOPYSRC,Id#fpr
FGLaA /COPY QCOPYSRC,ID#fgl
TPC A /copy qcopysrc,id#tpc
FBYaA /COPY QCOPYSRC,Id#fby
PANaA /COPY QCOPYSRC,Id#PAN
COTaA /COPY QCOPYSRC,Id#COT
SFP A /COPY QCOPYSRC,Id#SFP
MQS A /COPY QCOPYSRC,Id#MQS
EOPaA /COPY QCOPYSRC,Id#EOP
GRC A /COPY QCOPYSRC,Id#GRC
MRTaA /COPY QCOPYSRC,Id#MRT
KFSaA /COPY QCOPYSRC,Id#KFS
BADaA /COPY QCOPYSRC,Id#bad
VFIaA /COPY QCOPYSRC,Id#vfi
HPCaA /COPY QCOPYSRC,Id#hpc
NOJaA /COPY QCOPYSRC,Id#noj
CBIaA /COPY QCOPYSRC,Id#cheney
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
JOR2AD                 ds
JOR2AD  itpos6                 6      6
JOR2AD  slitem                 1     15
JOR2A*
414aA*----------------------------------------------------------------
414aA*  *SYSTEM  -  System options.
414aA*----------------------------------------------------------------
414aA*
414aA* Fields
414aA*
414aA*    OPEPM   -  Using EPM module (Y,N).
414aA*    OPRF    -  Using RF module (Y,N).
414aA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
414aA*    OPLETD  -  Print letdown labels (Y,N).
414aA*    OPWRNC  -  Perform catch weight variance check (Y,N).
414aA*    OPRG1C  -  Catch weight low variance percentage.
414aA*    OPRG2C  -  Catch weight high variance percentage.
414aA*    OPIMPI  -  Import item fields from host.(Y,N).
414aA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
414aA*
414aA* Data structure
414aA*
414aAD opdat2          ds
414aAD  opepm                  1      1
414aAD  oprf                   2      2
414aAD  opcapc                 3      3
414aAD  opletd                 4      4
414aAD  opwrnc                 5      5
414aAD  oprg1c                 6      8  1
414aAD  oprg2c                 9     11  1
414aAD  opimpi                12     12
414aAD  opmpck                14     14
414aAD  opten2               117    117
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
     *---------------------------------------------------------------
     *  Variables
     *
     D eof             s              1
     D kywhse          s                   like($pwhse)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
740aAD bsrsrv          s                   like(slrsrv)
     D nbrovr          s              5  0
     D nbrpck          s              5  0
     D slotSentIn      s               n
700aAD hasEachSlot     s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse number.
     *      $PITEM  Item number.
     *      $PSTYP  Section type (P,F)
     *      $PRSRV  Reserve (Y,N)
     *      $PPICK  Pick slot (Y,N)
     *      $PSTAT  Current status
     *      $PSTK_  Quantity in slot.
     *      $PALC_  Quantity selected for picking but not yet
     *              printed on labels.
     *      $PTFR_  Quantity printed on labels for transfer to
     *              another slot.
     *      $PPCK_  Quantity printed on labels for picking.
     *
     *      $PRCV_  Quantity printed on labels to be received into
     *              this slot.
     *      $PWHDP  Department
     *      $PDISP  Slot
     *
     *    Returned Parameters
     *      $PNEWS  New status
     *      $PRTN   *OK      - Status is ok. No change was needed.
     *              *CHANGED - Status was changed.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pstyp            1
     C                   parm                    $prsrv            1
     C                   parm                    $ppick            1
     C                   parm                    $pstat            2
530aAC                   parm                    $pdesg            5
     C                   parm                    $pstk1            5 0
     C                   parm                    $pstk2            3 0
     C                   parm                    $pstk3            3 0
     C                   parm                    $palc1            5 0
     C                   parm                    $palc2            3 0
     C                   parm                    $palc3            3 0
     C                   parm                    $ptfr1            5 0
     C                   parm                    $ptfr2            3 0
     C                   parm                    $ptfr3            3 0
     C                   parm                    $ppck1            5 0
     C                   parm                    $ppck2            3 0
     C                   parm                    $ppck3            3 0
     C                   parm                    $prcv1            5 0
     C                   parm                    $prcv2            3 0
     C                   parm                    $prcv3            3 0
     C                   parm                    $pnews            2
     C                   parm                    $prtn             8
640bAC                   parm                    $pwhdp            5
640bAC                   parm                    $pdisp           12
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $pnews = *blanks
     C                   eval      $prtn = '*OK     '

640bAC                   if        %parms < 25
640bAC                   eval      slotSentIn = *off
640bAC                   else
640bAC                   eval      slotSentIn = *on
640bAC                   endif
     *
     C                   select
     *
     *    When at least one slot qty is greater than zero a status
     *    of 'Z' or 'V' should be changed to 'A'.
     *
415aMC                   when      $pstk1 <> 0  or
415aMC                             $pstk2 <> 0  or
415aMC                             $pstk3 <> 0  or
415aMC                             $palc1 <> 0  or
415aMC                             $palc2 <> 0  or
415aMC                             $palc3 <> 0  or
415aMC                             $ptfr1 <> 0  or
415aMC                             $ptfr2 <> 0  or
415aMC                             $ptfr3 <> 0  or
415aMC                             $ppck1 <> 0  or
415aMC                             $ppck2 <> 0  or
415aMC                             $ppck3 <> 0  or
415aMC                             $prcv1 <> 0  or
415aMC                             $prcv2 <> 0  or
415aMC                             $prcv3 <> 0
     *
     C                   if        $pstat = 'Z '  or
     C                             $pstat = 'V '
     C                   eval      $pnews = 'A '
     C                   endif
MRTfA*
MRTfA*    When Merit foods do not allow base slots 42-250-1 or
MRTfA*    84-208-1 to be removed.  They use these base slots for
MRTfA*    all there ondemand repack slots
MRTfA*
MRTfAC                   when      client = Merit and
MRTfAc                             (%trim($pDisp)='42-250-1' or
MRTfAc                              %trim($pdisp)='84-208-1')
MRTfA *
MRTfAC                   if        $pstat = 'Z '  or
MRTfAc                             $pstat = 'V '
MRTfAC                   eval      $pnews = 'A '
MRTfAC                   endif
     *
     *    Otherwise, when all the qty's are less than or equal to
     *    zero the status should be set to 'Z'. The only exception
     *    is for a fixed picking slot that has existing replenishment
     *    slots. In that case the status is left alone.
     *
404 A*    The 'only exception' has been changed to be a fixed picking
404 A*    slot whether or not it has exitsting replenishment slots.
408 A*    The 'only other exception' is a PIR reserved slot.
     *
412 A*    The 'only exception' has been changed again for fixed
412 A*    picking slots. Now, a fixed pick slot that is reserved
412 A*    will not be touched (status is left alone). A fixed
412 A*    pick slot that in NOT reserved is allowed to goto a
412 A*    status of 'Z' if there are no corresponding overflow
412 A*    slots.
     *
414aA*    Exceptions: (not set to status of Z)
414aA*    A) If Reserved, PIR.
414aA*    B) If Non reserved, Fixed, Pick and no other pick slots
414aA*       exist and product exists.
414aA*    C) If Reserved, Fixed, Pick and no other pick slot exists.
414aA*    D) If Reserved, Fixed, Pick and multiple pick slots are
414aA*       allowed and the # of pick slots (including checked slot)
414aA*       is less than the # of pick slots allowed.
CLD A*    E) If Virtual Pick Slot, Do not change status. This applies
CLD A*       to both Fixed and PIR sections.
640aA*    F) If SPCL desg pick slot, overflow exists, Do not change
640aA*       status.
750 A*    G) Do not change status for Drop Pick Base slots
     *
     C                   other
640bA
640bA*    Let's create a DO structure so we can jump out of this monster OTHER.
640bA
640bAC                   do
640bA
640bA*    Before getting to exceptions, let's look for an open Directed Putaway
640bA
640bAC                   if        slotSentIn
640bAC                   call      'CHKOPNDP'
640bAC                   parm      $pwhse        dpWhse            3 0
640bAC                   parm      $pwhdp        dpWhdp            5
640bAC                   parm      $pdisp        dpDisp           12
640bAC                   parm      $pitem        dpItem           15
640bAC                   parm                    dpTotal           3 0
640bAC                   parm                    dpItmTtl          3 0
640bAC                   parm                    dpQty1            5 0
640bAC                   parm                    dpQty2            5 0
640bAC                   parm                    dpQty3            5 0
640bAC                   if        dpQty1 > 0
640bAC                             or dpQty2 > 0
640bAC                             or dpQty3 > 0
640bAC                   if        $pstat = 'Z '  or
640bAC                             $pstat = 'V '
640aAC                   eval      $pnews = 'A '
640bAC                   endif
640bAC                   leave
640bAC                   endif
640bAC                   endif
640bA
640bA*    Otherwise, we can move on to the normal exceptions
     *
     C                   eval      $pnews = 'Z '
     *
HPCbAC                   if        client = holt                                    B05
HPCbAC                   exsr      chkbase                                          B05
HPCbAC                   endif                                                      B05
     *
414aA*    Exception A:
414aMC                   if        $pstyp = 'P'  and
408 AC                             $prsrv = 'Y'  or
750 A*
750 A*    Exception G:
750 MC                             $pstat = 'DP' and
750 AC                             $prsrv = 'N'  or
CLD A*
CLD A*    Exception E:
CLD AC                             client = cityln  and                             B05
CLD AC                             $pstyp = 'P'  and
CLD AC                             $prsrv = 'V'  or                                 B05

TPC AC                             client =  tpc and
TPC3MC                             $pstyp = 'P'  and
TPC3MC                             $prsrv = 'V'  or                                 B05
TPC2DC*                            $pstyp = 'P'  and
TPC3DC**                           $pstyp = 'F'  and
TPC3DC**                           $ppick = 'Y'  and
TPC3DC**                           $prsrv = 'V'  or
ICBaAC**                           client = icb  and                                B05
ICBaAC                             $pstyp = 'P'  and
ICBaAC                             $prsrv = 'V'  or                                 B05
JSLaAC                             client = jsilvert  and                           B05
JSLaAC                             $pstyp = 'P'  and
JSLaAC                             $prsrv = 'V'  or                                 B05
WSTbDC***                          client = westside and                            B05
WSTbDC***                          $pstyp = 'P'  and
WSTbDC***                          $prsrv = 'V'  or                                 B05
PFCaAC                             client = presto and                              B05
PFCaAC                             $pstyp = 'P'  and
PFCaAC                             $prsrv = 'V'  or                                 B05
HMWaAC                             client = hmwagner and                            B05
HMWaAC                             $pstat = 'SR' or
FPRaAC                             client = FoodPro and                             B05
FPRaAC                             $pstat = 'SR' or
EFC AC                             client = eastln  and                             B05
EFC AC                             $pstyp = 'P'  and
EFC AC                             $prsrv = 'V'  or                                 B05
PANaAC                             client = panos and                               B05
PANaAC                             $pstyp = 'P'  and
PANaAC                             $prsrv = 'V'  or                                 B05
EOPcAC                             client = Earls and
EOPcAC                             $pstyp = 'P'  and
EOPcAC                             $ppick = 'Y'  and
EOPcAC                             $prsrv = 'V'  or
COTaAC                             client = cotati and                               B05
COTaAC                             $pstyp = 'P'  and
COTaAC                             $prsrv = 'V'  or                                 B05
MRTaAC                             client = merit and                                B05
MRTeAC                             $pstyp = 'P'  and
MRTaAC                             $prsrv = 'V'  or                                 B05
MRTeDC***                          $ppick = 'Y'  and
MRTdAC***                          $pstat = 'RP' and
GRCcAC                             client = greco and
GRCcAC                             $pstyp = 'P'  and
GRCcAC                             $ppick = 'Y'  and
GRCcAC                             $prsrv = 'V'  or
KFSaAC                             client = kellys and                               B05
KFScAC                             $ppick = 'Y'  and
KFSaAC                             $prsrv = 'V'  or                                 B05
SBR AC                             client = SBertram and                            B05
SBR AC                             $pstyp = 'P'  and
SBR AC                             $prsrv = 'V'  or                                 B05
FGLaAC                             client = foodsgalore and
FGLaAC                             $pstyp = 'P'  and
FGLaAC                             $prsrv = 'V'  or
JOR4D*          CLIENT    OREQ JORDAN                         B05
JOR4D*          $PSTYP    ANDEQ'P'
JOR4D*          $PRSRV    ANDEQ'V'                            B05
YHAaAC                             client = yhata  and                              B05
YHAaAC                             $pstyp = 'P'  and
YHAaAC                             $prsrv = 'V'  or                                 B05
HALaAC                             client = halsey and
HALaAC                             $pstyp = 'P'  and
HALaAC                             $prsrv = 'V'  or
SGC AC                             client = sgc  and                                B05
SGC AC                             $pstyp = 'P'  and
SGC AC                             $prsrv = 'V'  or                                 B05
FDI AC                             client = finkle  and                             B05
FDI AC                             $pstyp = 'P'  and
FDI AC                             $prsrv = 'V'  or                                 B05
GFCaAC                             client = 'GLAZIER'  and                          B05
GFCaAC                             $pstyp = 'P'  and
GFCaAC                             $prsrv = 'V'  or                                 B05
FFCbDC*                            client = 'FISCHER'  and                          B05
FFCbDC*                            $pstyp = 'P'  and
FFCbDC*                            $prsrv = 'V'  or                                 B05
FBYaAC                             client = farmboy and
FBYaAC                             $pstyp = 'P'  and
FBYaAC                             $prsrv = 'V'  or
CBIaAC                             client = cheney and
CBIaAC                             $pstyp = 'F'  and
CBIaAC                             $prsrv = 'Y'  or
SVLaAC                             client = saval  and                              B05
SVLaAC                             $pstyp = 'P'  and
SVLaAC                             $prsrv = 'V'  and                                B05
SVLbAC                             $pdesg <> 'SPCL'                                 B05
     *
     C                   eval      $pnews = *blanks
     *
     C                   endif
     *
412 AC                   if        $pstyp = 'F'  and                                B01
412 AC                             $ppick = 'Y'
414aAC                   exsr      chkpck
740aAC                   exsr      chkovr
640aA*    Exception F:
640aAC                   if        $pdesg = 'SPCL' or                               B F
MRTeAC                             client = merit and                               B F
MRTeAC                             slaisl = ' 99'
640aAC                   exsr      chkovr
640aAC                   if        nbrovr > 0
640aAC                   eval      $pnews = *blanks
640aAC                   endif
640aAC                   else
414aA*    Exception B:
414aAC                   if        $prsrv = 'N'                                     B02
DRYaAc                             and client <> Dairyland
412 AC                   call      'CHKREPL'
412 AC                   parm                    $pwhse
412 AC                   parm                    $pitem
412 AC                   parm                    $crtn             8
412 AC                   if        $crtn = '*YES    '  and                          B03
414aAC                             nbrpck = 1
412 AC                   eval      $pnews = *blanks
412 AC                   endif                                                      E03
412 AC                   endif                                                      E02
412 A*
414aAC                   if        $prsrv = 'Y'                                     B02
414aA*    Exception D:
414aAC                   if        opmpck = 'Y'                                     B03
414aAC                   if        nbrpck <= imnrpk                                 B04
414aAC                   eval      $pnews = *blanks
414aAC                   endif                                                      E04
414aA*
414aAC                   else
414aA*    Exception C:
414aAC                   if        nbrpck = 1                                       B04
414aAC                   eval      $pnews = *blanks
414aAC                   endif                                                      E04
414aAC                   endif                                                      E03
414aA*
414aAC                   endif                                                      E03
JOR3A* CHECK IF OVERFLOW EXISTS.
JOR3AC                   if        client = jordanos
JOR3AC                   call      'CHKREPL'
JOR3AC                   parm                    $pwhse
JOR3AC                   parm                    $pitem
JOR3AC                   parm                    $crtn
JOR3AC                   endif
JOR3A*
EOcd C                   if        client = Earls
EOPeAC                             and slotSentIn
EOPd C                   movel     $pdisp        paisl             3
EOPd C                   endif
CLD A*
CLD A*    Exception E:
CLD AC                   if        client = cityln  and                             B05
CLD AC                             $prsrv = 'V'  or
ICBaAC                             client = icb  and
ICBaAC                             $prsrv = 'V'  or
JSLaAC                             client = jsilvert  and
JSLaAC                             $prsrv = 'V'  or
WSTbDC***                          client = westside and
WSTbDC***                          $prsrv = 'V'  or
PFCaAC                             client = presto and
PFCaAC                             $prsrv = 'V'  or
EFC AC                             client = eastln  and
EFC AC                             $prsrv = 'V'  or
PANaAC                             client = panos and
PANbAC                             nbrpck <= imnrpk  and                            B04
PANaAC                             $prsrv = 'V'  or
COTaAC                             client = cotati and
COTbAC                             nbrpck <= imnrpk  and                            B04
COTaAC                             $prsrv = 'V'  or
MRTaAC                             client = merit and
MRTdAC***                          $pstat = 'RP' and
MRTbAC                             nbrpck <= imnrpk  and                            B04
MRTaAC                             $prsrv = 'V'  or
KFSaAC                             client = kellys and
KFSbAC                             nbrpck <= imnrpk  and                            B04
KFSaAC                             $prsrv = 'V'  or
SBR AC                             client = SBertram and
SBR AC                             $prsrv = 'V'  or
FGLbAC                             client = FoodsGalore and
FGLbAC                             $prsrv = 'V'  and
FGLbAC                             nbrpck <= imnrpk or
HMWaAC                             client = hmwagner and
HMWaAC                             $pstat = 'SR'  or
FPRaAC                             client = FoodPro and                             B05
FPRaAC                             $pstat = 'SR' or
FPRaAC                             client = FoodPro and                             B05
FPRbAC                             $prsrv = 'V' and
FPRbAC                             nbrpck <= imnrpk  and                            B04
FPRbAC                             $pdesg <> 'SPCL' or
FBYaAC                             client = farmboy and
FBYaAC                             $prsrv = 'V'  and
FBYaAC                             nbrpck <= imnrpk or
NOJaAC                             client = natalies and
NOJaAC                             $prsrv = 'V'  and
NOJaAC                             nbrpck <= imnrpk or
JOR2A*
JOR2A*     Special order item. Allow vrt slot to stay.
JOR AC                             client = jordanos  and
JOR AC                             $prsrv = 'V'  and
JOR1AC                             nbrpck <= imnrpk  and                            B04
JOR2AC                             itpos6 = ' '  or
JOR2A*
JOR2A*      BrkDwn item. Allow vrt slot to stay.
JOR2AC                             client = jordanos  and
JOR2AC                             $prsrv = 'V'  and
JOR2AC                             nbrpck <= imnrpk  and                            B04
JOR2AC                             itpos6 = 'E'  or
JOR2A*
JOR3A*      Normal stock item has overflow. Allow vrt slot to stay.
JOR3AC                             client = jordanos  and
JOR3AC                             $prsrv = 'V'  and
JOR3AC                             nbrpck <= imnrpk  and                            B06
JOR3AC                             itpos6 <> ' '  and
JOR3AC                             $crtn = '*YES    '  or
TPC AC*
TPC AC*    Number of pick slots less than max, allow vrt slot to stay.
TPC AC                             client = tpc    and
TPC AC                             $prsrv = 'V'  and
TPC AC                             nbrpck <= imnrpk  or
JOR2A*
YHAaAC                             client = yhata  and
YHAaAC                             $prsrv = 'V'  or
HALaAC                             client = halsey and
HALaAC                             $prsrv = 'V'  or
SGC AC                             client = sgc  and
SGC AC                             $prsrv = 'V'  or
FDI AC                             client = finkle  and
FDI AC                             $prsrv = 'V'  or
GFCaAC                             client = 'GLAZIER'  and
GFCaAC                             $prsrv = 'V'  and
GFCbAC                             nbrpck = 1  or
FFCaAC                             client = 'FISCHER'  and
FFCaAC                             $prsrv = 'V'  and
FFCaAC                             nbrpck = 1  or
SVLaAC                             client = saval  and
SVLaAC                             $prsrv = 'V'  and
SVLbAC                             $pdesg <> 'SPCL'  or
EIa AC                             client = ei  and
EIa AC                             $pdesg = 'SPCL' or
GMMaAC                             client = mnumkr and
GMMaAC                             $prsrv = 'V'  and
GMMbAC                             $pdesg <> 'SPCL' and
GMMcAC                             slwhse <> 10 and
GMMdAC                             nbrpck = 1 or
GMMcAC                             client = mnumkr and
GMMcAC                             $prsrv = 'V'  and
GMMcAC                             slwhse = 10 and
GMMdAC                             nbrpck = 1 and
GMMcAC                             slloc <> 199
SFP A*
SFP AC                             or client = Seashore
SFP AC                             and $prsrv = 'V'
SFP1AC                             and nbrpck <= imnrpk
SFP A*
EOcd C                             or client = Earls
EOPeAC                             and SlotSentIn
EOPd C                             and paisl = 'GRC'
EOPbDC*                            and $prsrv = 'V'
EOPdDC*                            and nbrpck <= 1
EOP A *
GRC AC                             or client = Greco
GRC AC                             and $prsrv = 'V'
GRC1AC                             and nbrpck <= imnrpk
GRC A *
MQS AC                             or client = Marques
MQS AC                             and $ppick = 'Y'
MQS AC                             and $prsrv = 'V'
MQS AC                             and $pdesg <> 'SPCL'
MQS AC                             and $pdesg <> 'I/P'
MQS A*
BADaAC                             or client = BigApple
BADaAC                             and $ppick = 'Y'
BADaAC                             and $prsrv = 'V'
BADaAC                             and nbrpck <= imnrpk
BADaAC                             and $pdesg <> 'SPCL'
BADaA*
VFIaAC                             or client = vitco
VFIaAC                             and $ppick = 'Y'
VFIaAC                             and $prsrv = 'V'
VFIaAC                             and nbrpck <= imnrpk
VFIaAC                             and $pdesg <> 'SPEC'
HPCaA*
HPCaAC                             or client = holt
HPCaAC                             and $ppick = 'Y'
HPCaAC                             and $prsrv = 'V'
HPCaAC                             and nbrpck <= imnrpk
HPCbAC                             and nbrovr > 0
HPCaDC*                            and $pdesg <> 'SPEC'
HPCaA*
HPCaAC                             or client = holt
HPCaAC                             and $ppick = 'Y'
HPCaAC                             and $prsrv = 'V'
HPCaAC                             and nbrpck <= imnrpk
HPCbAC                             and nbrovr = 0
HPCbAC                             and bsrsrv = 'Y'
MQS A*
CLD AC                   eval      $pnews = *blanks
CLD AC                   endif                                                      E05
     *
640aAC                   endif                                                      E F
412 A*
412 AC                   endif                                                      E01
     *
640bAC                   enddo

     C                   endsl
     *
     *    Let calling program know if the status needed to be changed.
     *
     C                   if        $pnews <> *blanks
     C                   eval      $prtn = '*CHANGED'
     C                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
414aA*
414aA*  *INZSR  Initialization subrotine
414aA*
414aAC     *inzsr        begsr
500zA*
500zA* Get client id.
500zA*
500zAC     *dtaara       define    pirclient     client           10
500zAC                   in        client
414aA*
414aA*  Initialize special keys
414aA*
414aA*
414aA*  Initialize message handling
414aA*
414aA*                    EXSR ZMIMSG
414aA*
414aA*   Call user added initialization routine.
414aA*
414aAC                   exsr      zzinz
414aAC                   endsr
740aA*---------------------------------------------------------------
740aA*  Check Base slot reserve setting.
740aA*
740aAC     chkbase       begsr
740aA*
740aA*    Check for base slot for virtual.
740aA*
740aAC                   eval      bsrsrv = *blanks
740aAC     keyv1         chain     vslot1                             79
740aAC                   if        not *in79
740aAC     keys2         chain     slot2                              79
740aAC                   if        not *in79
740aAC                   eval      bsrsrv = slrsrv
740aAC                   endif
740aAC                   endif
740aAC                   endsr
414aA*---------------------------------------------------------------
414aA*  Retrieve number of pick slots for item and accumulate
414aA*  number of pick slots assigned to item.
414aA*
414aAC     chkpck        begsr
414aAC     itkey         chain     itemmsc                            79
414aAC                   if        *in79
414aAC                   eval      imnrpk = 1
414aAC                   endif
414aA*
414aA*    Accumulate number of normal pick slots assigned to item.
414aA*
414aAC                   eval      k3stat = 'A '
414aAC                   eval      k3pick = 'Y'
414aAC     keys3         setll     slot3
414aAC                   eval      nbrpck = *zeros
414aAC                   eval      eof = *off
414aAC                   dow       eof = *off
414aAC     keys3         reade     slot3                                  79
414aAC                   move      *in79         eof
414aAC                   if        not *in79
414aAC                   add       1             nbrpck
414aAC                   endif
414aAC                   enddo
700aAC* check for *EACH pick slot
700aAC                   call      'CHKEACH'
700aAC                   parm                    $pwhse
700aAC                   parm                    $pitem
700aAC                   parm                    hasEachSlot
700aAC
700aAC                   if        hasEachSlot
700aAc                   sub       1             nbrpck
700aAc                   endif
650 A*
650 A*    Accumulate number of RP ODR pick slots assigned to item.
650 A*      if no normal pick slots were found
650 A*
650 Ac                   if        nbrpck < 1
650 AC                   eval      k3stat = 'RP'
650 AC                   eval      k3pick = 'Y'
650 AC     keys3         setll     slot3
650 AC                   eval      nbrpck = *zeros
650 AC                   eval      eof = *off
650 AC                   dow       eof = *off
650 AC     keys3         reade     slot3                                  79
650 AC                   move      *in79         eof
650 AC                   if        not *in79
650 AC                   add       1             nbrpck
650 AC                   endif
650 AC                   enddo
650 AC                   endif
414aAC                   endsr
640aA*---------------------------------------------------------------
640aA*  Check if overflow exists.
640aA*
640aAC     chkovr        begsr
640aA*
640aA*    Check for overflow slots for item.
640aA*
640aAC                   eval      k3stat = 'A '
640aAC                   eval      k3pick = 'N'
640aAC     keys3         setll     slot3
640aAC                   eval      nbrovr = *zeros
640aAC                   eval      eof = *off
640aAC                   dow       eof = *off
640aAC     keys3         reade     slot3                                  79
640aAC                   move      *in79         eof
640aAC                   if        not *in79 and
720aAC                             slaisl<>'USR'
640aAC                   add       1             nbrovr
640aAC                   endif
640aAC                   enddo
640aAC                   endsr
414a *----------------------------------------------------------------
414aA*
414aA*  ZZINZ    Extra program initialization. Called from *INZSR.
414aA*
414aAC     zzinz         begsr
414aA*
414aA*  Define key for ITEMMSC file.
414aA*
414aAC     itkey         klist
414aAC                   kfld                    $pwhse
414aAC                   kfld                    $pitem
414a *
414a *  Define key for options file, System values.
414a *
414aAC     optsky        klist
414aAC                   kfld                    kywhse
414aAC                   kfld                    opcode
414aA*
414aA*  Define partial key for SLOT3 file.
414aA*
414aAC     keys3         klist
414aAC                   kfld                    $pwhse
414aAC                   kfld                    $pitem
414aAC                   kfld                    k3stat
414aAC                   kfld                    k3pick
740aA*
740aA*  key for VSLOT1 file.
740aA*
740aAC     keyv1         klist
740aAC                   kfld                    $pwhse
740aAC                   kfld                    $pwhdp
740aAC                   kfld                    $pdisp
740aA*
740aA*  key for SLOT2 file.
740aA*
740aAC     keys2         klist
740aAC                   kfld                    vswhse
740aAC                   kfld                    vswhdp
740aAC                   kfld                    vspdis
414a *
414aA*
414aA*   Get system options.
414aA*
414aAC                   eval      kywhse = *zeros
414aAC                   eval      opcode = '*SYSTEM '
414aAC     optsky        chain     options                            79
414aAC                   if        *in79
414aAC                   eval      opmpck = 'N'
414aAC                   else
414aAC                   eval      opdat2 = opdata
414aAC                   endif
414aAC                   eval      nbrpck = *zeros
640aAC                   eval      nbrovr = *zeros
414aA*
414aAC                   endsr
