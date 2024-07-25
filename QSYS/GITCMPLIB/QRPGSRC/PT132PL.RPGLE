500oA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT132PL   Close single picking label for voice selection.
     *  31 January 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/31/01  DAS
     *      - Created.
     *
417 A*    06/10/04  DAS  4.17
     *      - Added flexible custom mod logic.
     *      - Revised to set flag to 'F', instead of 'T' when
     *        quantity has been changed, whether the quantity
     *        was changed in the Label file or not.
417a *    07/09/04  HNK  4.17a
     *      - Enh: Changed to add records to RUNNER file.
     *
417bA*    07/13/04  DAS  4.17b
     *      - Added call to ZZINZ, which was never called.
     *        Unfortunately, this is where I put the logic to get
     *        the client code from the data area.
     *
417cA*    07/14/04  DAS  4.17c
     *      - Added logic to initialize the Printed and Closed Runner
     *        datastamp fields to '0001-01-01.00.00.00.000000'.
     *
417dA*    07/19/04  DAS  4.17d
     *      - Moved runner logic to right after updating label record.
     *        in it's previous position after updating the tran rec
     *        the logic was being skipped when label was an OUT label.
     *      - Just moved code. Didn't change lines to 417d.
     *
417eA*    08/25/04  HNK  4.17e
     *      - Unlock RUNNER record.
     *
500 A*    02/21/05  MLB  5.00
     *      - Fix: Revised program to only flag label record closed by
     *        Voice when LBVRFY not equal 'F' and not equal 'T'.
500aA*    03/15/05  MLB  5.00a
     *      - Enh: Revised program to only flag label record closed by
     *        Voice when LBVRFY not equal 'F' and not equal 'T'.
500bA*    03/18/05  RLP/MLB  5.00b
     *      - Enh: Added DRI interface support
500cA*    03/18/05  RLP/MLB  5.00c
     *      - Enh: Added check of SLOTOUT file.
     *      - Attempt Priority Replenishment if not in SLOTOUT.
500dA*    03/18/05  MLB  5.00d
     *      - Enh: Converted program to ILE to support addition of
     *        DRI interface.
     *      - Program no longer needs to be compiled with *DATETIME option.
500eA*    05/27/05  MLB  5.00e
     *      - Enh: Revise ZZREPL to use *CRTRPFSQ1 instead of *CRTRPLSQ1.
     *        *CRTRPFSQ1 will force a Priority Replenishment to be created
     *        even if there is available qty in pick slot.
500fA*    06/20/05  MLB  5.00f
     *      - Fix: Revise ZZREPL to calculate qty needed instead of using
     *        NEWQTY. NEWQTY is qty picked by user, not qty shorted.
500gA*    07/10/05  MLB  5.00g
     *      - Enh: Revise program to update new fields in RUNNER file.
     *      - Added file OPTIONS. Retrieve *GENPICK options record.
500hAF*    09/14/05  MLB  5.00h
     F*      - Fix: Revised program to compute qty short to be used
     F*        to update RUNNER file with qty shorted.
500iAF*    09/14/05  MLB  5.00i
     F*      - Enh: Revised program to add *VOICE options to program to
     F*        determine whether to create RUNNER entries for shorted
     F*        product. Added file OPTIONS to pgm.
500jAF*    10/11/05  MLB  5.00j
     F*     - Fix: Revised program to test DIFPCK <> 0 instead of
     F*       LBQPCK <> NEWPCK when deciding to flag LBVRFY=F.  This
     F*       was causing the Label record to not be flagged that a
     F*       short was created when LBQPCK updated by this pgm.
500kA*    10/03/05  MLB  5.00k
     *      - Fix: Revise program to prevent duplicate record error on
     *        write to RUNNER file. KYTYPE field wasn't being properly
     *        initialized prior to each chain.
500lA*    12/05/05  JCJ  5.00l
     *      - Enh: Revise program to retrieve *VOICE options instead
     *        *GENPICK options.
     *      - Enh: Moved all the runner code to subroutine ZZRUNNER.
     *      - Enh: Moved Check for open letdown and/or priority
     *        replenishment code to subroutine ZZCKREPL.
500mA*    01/12/06  MLB  5.00m
     *      - Enh: Revised *VOICE options to remove field OPFRPL since
     *        it was not used. Renamed OPFRPL to OPFCLR - Clear RUNNER
     *        flag if quantity still short/out.
500nA*    01/14/06  MLB  5.00n
     *      - Fix: Revised program to release record lock on SLOT1 if
     *        slot found, but wrong item in slot.
500oA*    01/15/06  MLB  5.00o
     *      - Fix: Revised ZZRUNNER to use DIFPCK instead of computing
     *        short qty using NEWPCK. When Label rcd is updated with pick
     *        qty, calculation didn't compute correct short qty.
500pA*    03/31/06  RH   5.00p
     *      - Enh: Create cmd *BLKPICK for RF Bulk Pick, does not
     *        update label or slot records.
500qA*    04/26/06  MLB  5.00q
     *      - Fix: Change to 5.00l mod. Revised program to add check
     *        for $pcmd='*PICK' when testing OPUPLV to see if Label
     *        record should be updated.
500rA*    06/07/06  MLB  5.00r
     *      - Fix: Revise program to allow slot picked qty and w/h
     *        allocated qty to be updated when closing flag trans-
     *        actions.
     *
510 A*    07/19/06  MLB  5.10
     *      - Fix: Revised program to prevent merge label record from
     *        being flagged unless opvmrg = 'Y' and not allow slot
     *        to be updated.
510aA*    10/19/06  RH   5.10a
     *      - Fix: Revised program to prevent SLPCK from going negative
     *
520aA*    11/08/08  DAS  5.20a
     *      - Fix: Revised zzupwq to send positive qty for *ALLOC.
520bA*    11/08/08  DAS  5.20b  P#00140
     *      - Revised to up qty before updating Whse/Slot qtys.
     *        Re: We were running into breakdown 1 ordered qtys
     *            that were greater than 999.
520cA*    02/06/09  MLB  5.20c
     *      - Fix: Revised program to retrieve System Feature option.
     *        If Feature Option set to 3=Stand Alone, then always force
     *        replenishment flag found to Yes since Outbound Only does
     *        not create replenishments. This is needed with Voice/Runner
     *        option (OPFCLR) Clear flag if qty short/out set to N=No.
     *
640 A*    01/05/12  MLB  6.40
     *      - Fix: Revised program to not allow updates to the SLOT
     *        file or ITEMQTY file when OPFEAT=3=Outbound Only.
     *
650 A*    03/27/14  MLB  6.50
     *      - Fix: Revised program to retrieve *GENPICK options record.
     *        Need value in OPJITR to determine whether JIT replenish-
     *        ments should be created.
     *
710aA*    06/05/17  TAB  7.10a
     *      - Enh: Added new runner type for Box Breaker / create
     *        runner record with type 'B' when breakdown qty is being
     *        shorted.
730aA*    08/12/19  LMC  7.30a
     *      - Enh - Added Pick to wgt logic.
     *
750aA*    06/09/21  LMC  7.50a
     *      - Enh - Adding a call to driordc with Delete99 command
     *        added a call to driordc to delete the transaction
     *        record from ordcflg if the 99/4 all good record exist
     *        if a pick qty was changed.
     *        Reference ZD#4473 for additional details that prompted
     *        the need for this change.
     *
417aA*----------------------------------------------------------------
     * **** Note *****
500dA* **** 5.00d Note *****
     *        This compile option no longer needed. Pgm converted to ILE.
     * ***************
     *      This progrm must be compiled with option CVTOPT(*DATETIME)
     * ***************
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
ADW A*    08/01/06  MLB  ADW
     *      - Revised program to not allow runner flag to be created
     *        when department = GHOST.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf
     *
GLPaA*    07/14/16  NLK  GLP
     *      - Revised program to not allow runner flag to be created
     *        when AMP route
GLPbA*    08/01/16  NLK  GLP
     *      - Revised program to not allow 'F' flag to lbvrfy,
     *        when AMP route
GLPcA*    08/25/16  NLK  GLP
     *      - Revised program to change virtual slot to status 'z'
     *        if not picked in AMP
     *
417 A*----------------------------------------------------------------
417 A*  Custom mods for Cheney.
417 A*
CBI  *    01/13/03  HNK
     *      - Do not update quantity for short product.  Update
     *        LBVRFY with 'F' instead.
CBIa *    07/21/04  HNK
     *      - Skip some logic for CHENEY
CBIbA*    03/18/05  MLB  CBIb
     *      - Note: Program converted to ILE. Copy source member changed
     *        to ID#CHENEY from IL#CHENEY.
CBIcA*    11/09/07  MLB  CBIc
     *      - Revised program to create 999's item numbers as Runner
     *        Type Out flags when flags DSMEAT,DSPPCK are not both Y=Yes.
     *      - Add file, ORDH to program.
     *
417 A*----------------------------------------------------------------
417 A*  Custom mods for City Line.
417 A*
CLD A*    06/10/04  DAS  CLD
     *      - Added City Line to CBI mod.
CLDaA*    03/18/05  MLB  CLDa
     *      - Note: Program converted to ILE. Copy source member changed
     *        to ID#CITYLIN from IL#CITYLIN.
     *        Client id field changed from CITYLN to CITYLINE
     *
     *----------------------------------------------------------------
     *  File Specs
     *
500gAFoptions   if   e           k disk
CBIcAFordh      if   e           k disk    usropn
     Fpiritem   if   e           k disk
     Fpirtran   uf   e           k disk
     Fslot1     uf   e           k disk
500cAFslotout   uf a e           k disk
     FLabel     uf   e           k disk
417a Frunner    uf a e           k disk
GLPaAFampxref   if   e           k disk
710aAFitemfld   if   e           k disk
730aAFordc1     if   e           k disk
730aA*----------------------------------------------------------------
730aA* Function prototypes.
730aA*----------------------------------------------------------------

730aA /copy qcopysrc,p.umlabel
750aA /copy qcopysrc,p.driordc

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500bA*----------------------------------------------------------------
500bA*  DRI parameters
500bA*----------------------------------------------------------------
500bA /COPY *libl/qcopysrc,C#DRIPARMS

500bA*----------------------------------------------------------------
500bA*  Data Formats
500bA*----------------------------------------------------------------
500bA /COPY *libl/qcopysrc,C#PRTYRPL
750aA /COPY *libl/qcopysrc,C#ORDC
500bAD savever#        s                   like($prver#)

417 A*----------------------------------------------------------------
417 A*  Customer id
417 A*
ADW D /COPY QCOPYSRC,ID#ANDREWS
GLP D /COPY QCOPYSRC,ID#GLP
CBIbD */COPY QCOPYSRC,IL#CHENEY
CBIbM /COPY QCOPYSRC,ID#CHENEY
CLDaD */COPY QCOPYSRC,IL#CITYLIN
CLDaM /COPY QCOPYSRC,ID#CITYLIN
500gA*----------------------------------------------------------------
500gA*  *GENPICK -  General picking.
500gA*----------------------------------------------------------------
500gA*
500gA* Fields
500gA*
500gA*    OPERPT  -  Print exception (short) error report (Y,N).
500gA*    OPELBL  -  Print exception (short) labels (Y,N).
500gA*    OPRFWC  -  Using RF will call (Y,N).
500gA*    OPNRSC  -  Number of pallet sections (1-9).
500gA*    OPHPWC  -  Host pick Will Call (Y/N).
500gA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
500gA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
500gA*    OPEADJ  -  Close short labels without adjustment (Y,N).
500gA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500mD*    OPCLRF  -  Clear runner flags if qty still short/out? (Y/N)
650 A*    OPJITR  -  Create JIT Letdown or JIT Replenishment
650 A*                 0=None. No replenishments are created.
650 A*                 2=Priority Replenishments are created during
650 A*                   Truck Builder Pick/Print processing.
650 A*                 4=JIT Priority Replenishments created when
650 A*                   transaction is checked out.
500gA*
500gA* Data structure
500gA*
500gAD opdta1          DS
500gAD  OPERPT                 1      1
500gAD  OPELBL                 2      2
500gAD  OPRFWC                 3      3
500gAD  OPNRSC                 4      4  0
500gAD  OPHPWC                 5      5
500gAD  OPMRGA                 6      6
500gAD  OPPLSQ                 7      7
500gAD  OPEADJ                 8      8
500gAD  OPNOPK                 9      9
500mDD* OPCLRF                10     10
650 AD  opjitr                12     12
500gAD  OPTEND               117    117
500iA*
500iA*----------------------------------------------------------------
500iA*  *VOICE  -  PIR Voice options.
500iA*----------------------------------------------------------------
500iA*
500iA* Fields
500iA*
500iA*    OPINCP  -  Include pack description (Y/N)
500iA*    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
500lA*    OPUPLV  -  Update Label with quantity picked during Voice
500lA*               selection (Y/N)
500lA*               NOTE: Any change to this field will cause OPUPLR
500lA*                     in the *RUNNER options record to be updated.
500lA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
500lA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500mM*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
500mA*               NOTE: Any change to this field will cause OPCLRF
500mA*                     in the *RUNNER options record to be updated.
500iA*
500iA* Data structure
500iA*
500iAD opvdta          DS
500iAD  OPINCP                 1      1
500iAD  OPCRTR                 2      2
500lAD  opuplv                 3      3
500lAD  opvmrg                 4      4
500lAD  opoutf                 5      5
500mDD* opfrpl                 6      6
500mMD  opfclr                 6      6
500iAD  OPVEND               117    117
520cA*
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
520cA*
730aA*----------------------------------------------------------------
730aA*  Standard variables and constants
730aA*----------------------------------------------------------------

730aA /copy qcopysrc,c#stdvar

500iA*----------------------------------------------------------------
500iA*
    A*----------------------------------------------------------------
    A*  Working variables
    A*
CBIcAD                 DS
CBIcAD  ohmisc                 1     20
CBIcAD  dssdte                 1      8
CBIcAD  dsspcl                 9     11
CBIcAD  dsrpck                12     12
CBIcAD  dxdoor                13     14
CBIcAD  dsmeat                15     15
CBIcAD  dsppck                17     17
CBIcA*
GLPaAD AMPpickLabel    s               n
710aAD UCISelect       s               n
GLPcAD AMPpick0        s               n
     D #bitem          s                   like(ititem)
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #sitem          s             15
500dAD currstamp       s               z
     D difcub          s                   like(lbcube)
     D difpck          s                   like(lbqpck)
     D difwgt          s                   like(lbswgt)
500bAD errmsg          s             50
730aDD*error           s              1
     D itmflg          s              1
     D kyitem          s                   like(lbitem)
     D kywhse          s                   like(lbwhse)
     D newcub          s                   like(lbcube)
     D newpck          s                   like(lbqpck)
     D newwgt          s                   like(lbswgt)
     D pckqty          s                   like(lbqpck)
     D svitem          s                   like($aitem)
     D svqpck          s                   like(lbqpck)
520bDD svqty2          s                   like(lbqpck)
     D svutyp          s                   like(lbutyp)
500lAD svwhse          s                   like(lbwhse)
500lAD $slotout        s              4

730aAD Pick2lbs        s              6  2
730aAd hlddifpck       s                   like(lbqpck)

417cA*----------------------------------------------------------------
417cA*  Constants
417cA*
500dDD*tsinz           c                   const('0001-01-01-00.00.00.-
500dDD*                                    000000')
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
500qM*      $PCMD   *PICK    - When called from Voice socket pgm.
500lA*              *MANFLAG - Manual flag entry, called by RU110.
500lA*              *CLSFLAG - Clear flag entry, called by RU310.
500pA*              *BLKPICK - When called from RF Bulk Pick OR680
     *      $PLBL#  Label number.
     *      $PQTY   Quantity picked.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
500lAC                   parm                    $pcmd             8
     C                   parm                    $plbl#            7 0
     C                   parm                    $pqty             5 0
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      error = *off
     C                   eval      newpck = $pqty
     C                   eval      lblbl# = $plbl#
500gAC                   eval      $drireturn = ' '
500lAC                   eval      $slotout = '*NO'
417aAC                   exsr      zzinz
     *
     *  Get label record
     *
     C     lblbl#        chain     label                              79
     C                   if        *in79
     C                   goto      bottom
     C                   endif
730aA /free
730aA
730aA  monitor;
730aA    umWhse = lbwhse;
730aA    umlabel('*GET': umRtnCode: umRtnMsg:
730aA            umWhse: lblbl#:
730aA            umFlexPickFlag:
730aA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730aA  on-error;
730aA    umRtnCode = '*ERROR';
730aA  endmon;
730aA
730aA  if umRtnCode = '*OK';
730aA    select;
730aA      when umFlexPickFlag = 'P2W';
730aA        pick2lbs = lbswgt;
730aA      when umFlexPickFlag = 'PAQ';
730aA    endsl;
730aA  endif;
730aA
730aA /end-free
CBIcA*
CBIcAC                   if        client = cheney
CBIcAC
CBIcA*      Retrieve order header for dsmeat/dsppck flags.
CBIcAC                   if        lbitem >= '997000'
CBIcAC     keyoh         chain     ordh
CBIcAC                   if        not %found(ordh)
CBIcAC                   eval      ohmisc = ' '
CBIcAC                   endif
CBIcAC                   endif
CBIcAC
CBIcAC                   endif
500gA*
500lA*  Get *Voice Options
500lAC                   if        svwhse <> lbwhse
520cA*     Retrieve System Feature setting.
520cAC                   exsr      zzgetft
650 A*     Retrieve General Pick options
650 AC                   exsr      zzgetgp
520cA*     Retrieve Voice options.
500gAC                   exsr      zzgetop
500lAC                   endif
ADW A*
ADW A*     Don't allow updates for Ghost dept.
ADW AC                   if            client = Andrews
ADW AC                             and lbwhdp = 'GHOST'
ADW AC                   unlock    label
ADW AC                   goto      bottom
ADW AC                   endif
GLP A*
GLP A*     Don't allow updates for AMP routes.
GLP A*     **Not here - need to update Label file still
GLP AC*                  exsr      zzpickAMPchk
GLP AC*                  if            client = Greenleaf
GLP AC*                            and AMPpickLabel = *on
GLP AC*                  unlock    label
GLP AC*                  goto      bottom
GLP AC*                  endif
     *
     *  Calculate qty, cube and weight.
     *
500lAC                   select
500lAC                   when      $pcmd = '*MANFLAG' and opuplv = 'Y'
500qAC                             or $pcmd = '*CLSFLAG' and opuplv = 'N'
500lAC                   eval      newpck = lbqpck - newpck
500lAC                   when      $pcmd = '*CLSFLAG' and opuplv = 'Y'
500lAC                   eval      newpck = lbqpck + newpck
500lAC                   endsl
500lA*
     *     New qty, cube and weight.
     *
730aAc                   if        umFlexPickFlag = 'P2W'
730aAC                   eval      newcub = lbcube
730aA /free
730aA   newwgt = 0;
730aA   setll (lbwhse: lblbl#) ordc1;
730aA   dow forever = forever;
730aA     reade (lbwhse: lblbl#) ordc1;
730aA     if %eof(ordc1);
730aA       leave;
730aA     endif;
730aA     newwgt = newwgt + OCCWGT;
730aA   enddo;
730aA /end-free
730aAc                   else
     C     lbucub        mult      newpck        newcub
     C     lbuwgt        mult      newpck        newwgt
730aAc                   endif
     *
     *     Difference in qty, cube and weight.
     *
500pAC                   select
500pAC                   when      $pcmd = '*BLKPICK'
500pA*    Label quantity already updated in calling program OR680
500pAC                   eval      difpck = lbqalc - newpck
500pAC                   eval      difcub = lbucub * difpck
500pAC                   eval      difwgt = lbuwgt * difpck
500pAC                   other
730aAc                   if        umFlexPickFlag = 'P2W'
730aAC                   eval      difpck = 0
730aAC                   eval      difcub = 0
730aAC                   eval      difwgt = lbswgt - newwgt
730aAC                   eval      hlddifpck = lbqpck - newpck
730aAc                   else
     C                   eval      difpck = lbqpck - newpck
     C                   eval      difcub = lbcube - newcub
     C                   eval      difwgt = lbswgt - newwgt
730aAc                   endif
500pAC                   endsl
     *
     *  Update label record
     *
417 A*    Certain client's don't want the quantity update.
417 A*
417 AC                   select
CBI A ****500lA          when      client = cheney  or
CLDbM ****500lA                    client = cityline

500lAC                   When      opuplv = 'N'
500qAC                             and $pcmd = '*PICK   '
500pAC                             or $pcmd = '*BLKPICK'

417 A*                <do nothing>
417 A*
417 A*    For everyone else, update quantity.
417 A*
417 AC                   other
510 AC                   if        lbtype <> 'M'
750aA /free
750aA   if $pcmd = '*CLSFLAG' and lbqpck <> newpck;
750aA     exsr calldriordc;
750aA   endif;
     C                   eval      lbqpck = newpck
     C                   eval      lbcube = newcub
     C                   eval      lbswgt = newwgt
510 AC                   endif
417 A*
417 AC                   endsl
500cA*
500cA*    Check for open letdown and/or priority replenishment. If found,
500gA*    don't create new priority replenishment.
500gA*    and only when Runner Flag isn't cleared if qty not found.
520cA*    and System Feature is set not 3=Outbound only.
500gAC                   if        lbtype <> 'M'
500mMC                             and opfclr = 'N'
520cAC                             and opfeat <> '3'
500gAC                             and lbqpck <> newpck
500lAC                             and $pcmd = '*PICK'
650 AC                             and opjitr > '0'
500gA*
500lAC                   exsr      zzckrepl
500cA*
520cAC                   else
520cA*     Force system to think replenishment was created,
520cA*     when running Outbound only.
520cAC                   if        opfeat = '3'
520cAC                   eval      $drireturn = '*OK       '
520cAC                   endif
520cA*
500gAC                   endif
CBIcA*
CBIcAC                   if        client = Cheney
CBIcAC
CBIcA*     Force Runner flag to be created as Out flag.
CBIcAC                   if            lbitem >= '997000'
CBIcAC                             and dsmeat <> 'Y'
CBIcAC                             and dsppck <> 'Y'
CBIcAC                   eval      $drireturn = '*ERROR'
CBIcAC                   endif
CBIcAC
CBIcAC                   endif
417 A*
417 A*  Set flag to 'F' if quantity was changed.
500jAC*  and Create RUNNER entries = Yes.
417 A*
500lAC                   if        $pcmd = '*PICK'
500pAC                             or $pcmd = '*BLKPICK'
500jDC****               if        lbqpck <> newpck
500jMC                   if        difpck <> 0  and
500jMC                             opcrtr = 'Y'
510 AC                             and (lbtype = 'O' or
510 AC                                  lbtype = 'B')
510 A*
510 AC                             or lbtype = 'M'
510 AC                             and difpck <> 0
510 AC                             and opcrtr = 'Y'
510 AC                             and opvmrg = 'Y'
510 A*
510 DC*                  if        $drireturn = '*OK'
510 DC*                            or opfclr = 'Y'
510 MC                   if        ($drireturn = '*OK'
510 MC                             or opfclr = 'Y')
510 AC                             and lbtype <> 'M'
417 AC                   eval      lbvrfy = 'F'
GLP A*
GLP A*     Don't allow AMP routes to move 'F'
GLP A*           move 'T' to complete this pick in voice
GLP A*           item will be complete on the Delv Rt
GLPbAC                   exsr      zzpickAMPchk
GLPbAC                   if        AMPpickLabel = *on
GLPbAC                   eval      lbvrfy = 'T'
      *  AMPxRef SLOT change to 'Z' status if picking 0
GLPcAC                   eval      AMPpick0 = *off
GLPcAC                   if        lbqpck = 0
GLPcAC                   eval      AMPpick0 = *on
GLPcAC                   endif
      *
GLPbAC                   endif
    A*
500cAC                   else
500cAC                   eval      lbvrfy = 'I'
500cAC                   endif
417 AC                   else
500 A*
500 A*    Only flag label as closed by Voice when not previously
500 A*    flagged with a Runner flag.
500 A*
500 AC                   if        lbvrfy <> 'F'  and
500 AC                             lbvrfy <> 'I'
     C                   eval      lbvrfy = 'T'
500 AC                   endif
417 AC                   endif
500lAC                   endif
417 A*
     C                   update    lbrec
417a *
417a *  Write records to RUNNER file, if quantity was shorted.
500i *  and Create RUNNER entries = Yes.
417a *
500lAC                   if        $pcmd = '*PICK'
500pMC                             or $pcmd = '*BLKPICK'
417a C                   if        lbtype = 'O'  and
500hDC*                            lbqpck <> newpck
500hMC                             difpck <> 0  and
500iMC                             opcrtr = 'Y'
500gAC                             or lbtype = 'B'  and
500pDC*                            lbqpck <> newpck and
500pMC                             difpck <> 0  and
500lAC                             opcrtr = 'Y'
500gAC                             or lbtype = 'M'  and
500gAC                             lbqpck <> newpck and
500lAC                             opcrtr = 'Y'     and
500lAC                             opvmrg = 'Y'
500gA*
500lAC                   if        opoutf = 'Y' or  opoutf   = 'N'
500lAC                                          and $slotout = '*NO'
GLP A*
GLP A*     Don't allow AMP routes to create Runner Flag
GLP A*
GLPaAC                   exsr      zzpickAMPchk
GLPaAC                   if        AMPpickLabel = *off
500lAC                   exsr      zzrunner
GLPaAC                   endif
500lAC                   endif
417a C                   endif
500lAC                   endif
417a *
     *
     *  If no change or 'OUT' label
     *   then skip to the bottom because there is nothing to do.
730aAc                   if        umFlexPickFlag = 'P2W'
730aAc                   eval      difpck = hlddifpck
730aAc                   endif
     *
     C                   if        difpck = 0  or
     C                             lbasl2 = 'OUT'  or
500lAC                             opuplv = 'N'
500rAC                             and $pcmd <> '*CLSFLAG'
510 A*      Skip slot update for Merge records.
510 AC                             or lbtype = 'M'
510 A*
CBIa  ****500lA                    client = cheney  or
CLDbM ****500lA                    client = cityline
     C                   goto      bottom
     C                   endif
     *
     *  Get item information.
     *
     C                   eval      kywhse = lbwhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     C                   if        error = *on
     C                   goto      bottom
     C                   endif
     *
     *     Slot record / upd AMP's empty slot to 'Z' status
     *          DOR slots not picked
GLPcAC                   if        AMPpick0 = *on
GLPcAC     keysl1a       chain     slot1                              79
GLPcAC                   if        not *in79
GLPcAC                   eval      slstat = 'Z'
GLPcAC                   update    slrec                                70
GLPcAC                   endif
GLPcAC                   endif
     *
     *
     *     Slot record. Deduct Qty here
     *
500pAC                   if        $pcmd <> '*BLKPICK'
640 AC                             and opfeat <> '3'
     C     keysl1        chain     slot1                              79
     C                   if        not *in79  and
     C                             slitem = #sitem
     *
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      slpck1 = slpck1 - difpck
510a C                   if        slpck1 < 0
510a C                   eval      slpck1 = 0
510a C                   endif
     C                   when      lbutyp = '1'
520bAC                   if        difpck < 0
520bAC                   eval      svqty2 = -(difpck)
520bAC                   exsr      zzAlloc1
520bAC                   else
520bAC                   eval      svqty2 = difpck
520bAC                   exsr      zzUnpick1
520bAC                   endif
520bDC**                 sub       difpck        slpck2
520bDC**                 if        slpck2 < 0
520bDC**                 eval      slpck2 = 0
520bDC**                 endif
     C                   when      lbutyp = '2'
     C                   sub       difpck        slpck3
510a C                   if        slpck3 < 0
510a C                   eval      slpck3 = 0
510a C                   endif
     C                   endsl
     *
     C                   update    slrec                                70
500nA*
500nAC                   else
500nAC                   unlock    slot1
     *
     C                   endif
500pAC                   endif
     *
     *     Transaction record.
     *
     C     lbtrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptpcs = ptpcs - difpck
     C                   eval      ptcube = ptcube - difcub
     C                   eval      ptswgt = ptswgt - difwgt
     C                   update    ptrec
     C                   endif
     *
     *     Warehouse record (Ignore if Replenishment transaction).
     *
640 AC                   if        opfeat <> '3'
     C                   exsr      zzupwq
640 AC                   endif
     *
     *  Return
     *
     C     bottom        tag
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------

500lA*----------------------------------------------------------------
500lA*
500lA*  ZZckrepl Check for open letdown and/or priority replenishment
500lA*
500lAC     zzckrepl      begsr
500lA*
500cAC                   call      'GETREPL'
500cAC                   parm      '*LTDWNPRTY'  $pcmd10          10
500cAC                   parm      lbwhse        $pwhse            3 0
500cAC                   parm      lbwhdp        $pwhdp            5
500cAC                   parm      lbdisp        $pdisp           12
500cAC                   parm      lbitem        $pitem           15
500cAC                   parm      0             $ptrn#            7 0
500cAC                   parm      0             $pseq#            5 0
500cAC                   parm      *blanks       $prtn             8
500cAC                   select
500cA*
500cA*    Open Letdown and/or Priority Replenishment found for item.
500cAC                   when      $prtn = '*OK'
500cAC                   eval      $drireturn = '*OK'
500cA*
500cA*    No open Letdown and/or Priority Replenishment found.
500cAC                   other
500cA*
500cA*    Check if record in SLOTOUT file, if not found, attempt replenishment,
500cA*    if replenishment fails, write a SLOTOUT record and continue to check
500cA*    runner file. If record in SLOTOUT, create Runner entry with status U=
500cAC                   eval      $drireturn =  *blanks
500cAC     keyso         chain (n) slotout
500cAC                   If        not %found(Slotout)
500cAC                   exsr      zzrepl
500cAC                   if        $drireturn <> '*OK'
500cAC                   exsr      zzslot
500lAC                   else
500lAC                   eval      $slotout = '*YES'
500cAC                   endif
500cAC                   endif
500cAC                   endsl
500lA*
500lAC                   endsr

500lA*----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
417 A*
417 A* Get client id.
417 A*
417 AC     *dtaara       define    pirclient     client           10
417 AC                   in        client
500iAC*
500iAC* Get voice options.
500iAC*
500i C**500l             eval      wkcode = '*VOICE'
500i C**500l             eval      wkswhs = 0
500i C**500lopkey         chain     options                           79
500i C**500l             if        *in79 = *off
500i C**500l             movel     opdata        opvdta
500i C**500l             else
500i C**500l             eval      opincp = 'Y'
500i C**500l             eval      opcrtr = 'N'
500i C**500l             endif
     *
     *  Define save fields for different item types.
     *
     C                   eval      #otype = *blanks
500gA*
500gA*  Define key for OPTIONS file.
500gA*
500iAC     *like         define    opwhse        wkswhs
500iAC     *like         define    opcode        wkcode
500gAC     opkey         klist
500iAC                   kfld                    wkswhs
500iAC                   kfld                    wkcode
500iAC*                  kfld                    lbwhse
500iAC*                  kfld                    opcode
500bA*
500gA*
500gA*  Define full key for RUNNER file.
500gA*
500gAC     *like         define    rutype        kytype
500gAC     keyru         klist
500gAC                   kfld                    lbwhse
500gAC                   kfld                    kytype
500gAC                   kfld                    lblbl#
     *
     *  Define key for SLOT1 file.
     *
     C     keysl1        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbaisl
     C                   kfld                    lbloc
     C                   kfld                    lbrlvl
     C                   kfld                    lbhand
     *
     *  Define key for SLOT1 file using AMPxRef for cleanup
     *
GLPcAC     keysl1a       klist
GLPcAC                   kfld                    axwhse
GLPcAC                   kfld                    axawhdp
GLPcAC                   kfld                    axaaisl
GLPcAC                   kfld                    axaloc
GLPcAC                   kfld                    axarlvl
GLPcAC                   kfld                    axahand
500cA*
500cA*  Define full key for SLOTOUT file.
500cA*
500cAC     keyso         klist
500cAC                   kfld                    lbwhse
500cAC                   kfld                    lbwhdp
500cAC                   kfld                    lbdisp
500cAC                   kfld                    lbitem
CBIcA*
CBIcA*  Define key for ORDH file.
CBIcA*
CBIcAC     keyoh         klist
CBIcAC                   kfld                    lbwhse
CBIcAC                   kfld                    lbord
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem
     *
GLPaA*  Define key for ORDC1 file.
     *
     C     keyoc1        klist
     C                   kfld                    lbwhse
     C                   kfld                    lblbl#
     *
CBIcAC                   if        client = Cheney
CBIcAC
CBIcAC                   if        not %open(ordh)
CBIcAC                   open      ordh
CBIcAC                   endif
CBIcAC
CIBcAC                   endif
     *
     C                   endsr

520bAC*----------------------------------------------------------------
520bAC*  zzAlloc1    Allocate increased pick qty
520bAC*----------------------------------------------------------------
520bA
520bAC     zzAlloc1      begsr

     C*  Allocate full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then return the rest from the brkdn1 qty.

     C                   eval      slpck2 += svqty2

     C*  Now see if pick brkdn1 can be converted to cases.

     C                   dow       slpck2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      slpck2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 is needed to cover brkdn1 allocated.

     C                   exsr      avail
     C                   dow       avail2 < 0
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   enddo

     C                   endsr

520bAC*----------------------------------------------------------------
520bAC*  avail   Calculate slot available qtys
520bAC*----------------------------------------------------------------
520bA
520bAC     avail         begsr

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

     C                   endsr
650 A*
650 A*----------------------------------------------------------------
650 A*
650 A*  ZZGETGP  Get *GENPICK Options
650 A*
650 AC     zzgetgp       begsr
650 A*
650 AC                   eval      wkswhs = lbwhse
650 AC                   eval      wkcode = '*GENPICK'
650 A*
650 AC     opkey         chain     options
650 AC                   if        not %found(options)
650 AC                   eval      opjitr = '0'
650 AC                   else
650 AC                   movel     opdata        opdta1
650 AC                   endif
650 A*
650 AC                   endsr
500gA*
500gA*----------------------------------------------------------------
500gA*
500lA*  ZZGETOP  Get *Voice Options
500gA*
500gAC     zzgetop       begsr
500gA*
500gA ****               MOVE      '*GENPICK'    opcode
500lAC                   eval      opcode = '*VOICE'
500gAC                   eval      wkcode = opcode
500gAC                   eval      wkswhs = lbwhse
500lAC                   eval      svwhse = lbwhse
500gA*
500gAC     opkey         chain     options
500gAC                   if        not %found(options)
500gA ****500lA          eval      opclrf = 'Y'
500mAC                   eval      opfclr = 'Y'
500lAC                   eval      opincp = 'Y'
500lAC                   eval      opcrtr = 'N'
500gAC                   else
500gA ****500lA          movel     opdata        opdta1
500lAC                   movel     opdata        opvdta
500gAC                   endif
500gA*
500gAC                   endsr
520cA*
520cA*----------------------------------------------------------------
520cA*
520cA*  ZZGETFT  Get *FEATURE Options
520cA*
520cAC     zzgetft       begsr
520cA*
520cAC                   eval      opcode = '*FEATURE'
520cAC                   eval      wkcode = opcode
520cAC                   eval      wkswhs = lbwhse
520cA*
520cAC     opkey         chain     options
520cAC                   if        not %found(options)
520cAC                   eval      opfeat = '2'
520cAC                   else
520cAC                   eval      opfdta = opdata
520cAC                   endif
520cA*
520cAC                   endsr
500gA*
     *----------------------------------------------------------------
     *
     *  ZZITEM   Get item information.
     *
     *    Input:  KYWHSE, KYITEM
     *
     C     zzitem        begsr
     *
     *  Get item information.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
     C                   eval      error = *on
     C                   endif
     C                   eval      #bitem = ititem
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     C                   eval      #bum2 = itum2
     C                   eval      #bumq2 = itumq2
     C                   eval      #bum3 = itum3
     C                   eval      #bumq3 = itumq3
     *
     *  If Contract, Alias or Same Slot Breakdown item
     *   Then verify Base item exists.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'B'
     *
     C                   call      'GETBASE'
     C                   parm      lbwhse        $gwhse            3 0
     C                   parm      lbitem        $gitem           15
     C                   parm      ' '           #bitem
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
     *
     C                   endif
     *
     *    Determine slot item.
     *
     C                   select
     C                   when      ittype = 'A'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C                   eval      #sitem = #bitem
     C                   other
     C                   eval      #sitem = ititem
     C                   endsl
     *
     C                   eval      itmflg = *on
     C     enditm        endsr
     *
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZITEMFLD Get item field infotmation for Box Breaker runner
710aA*
710aA*    Input:  KYWHSE, KYITEM
710aA*
710aAC     zzitemfld     begsr
710aAC                   Eval      UCISelect = *Off
710aAC     keyit         chain     itemfld

710aAC                   If        %Found(itemfld)
710aAC                   Select

710aAC                   When      IFSLTMTH = '2'
710aAC                   Eval      UCISelect = *On

710aAC                   Other
710aAC                   EndSl
710aAC                   EndIf

710aAC                   endsr
     *
GLPaA*----------------------------------------------------------------
GLPaA*  ZZpickAMPCHK   Check if AMPpick label.
GLPaA*----------------------------------------------------------------
GLPaA
GLPaAC     zzpickAMPchk  begsr

     *  See if label record is a AMPpick label (add key whse with label)

     C     keyoc1        chain     ampxref
     C                   if        %found
     C                   eval      AMPpickLabel = *on
     C                   else
     C                   eval      AMPpickLabel = *off
     C                   endif

     C                   endsr

500cA*----------------------------------------------------------------
500cA*
500cA*  ZZrepl   Create Priority Replenishment
500cA*
500cAC     zzrepl        begsr
500cAC                   exsr      clr$prtyrpl

500cAC                   eval      $prwhseu = *on
500cAC                   eval      $prwhse  = lbwhse

500cAC                   eval      $pritemu = *on
500cAC                   eval      $pritem  = lbitem

500cAC                   eval      $prwhdpu = *on
500cAC                   eval      $prwhdp  = lbwhdp

500cAC                   eval      $prslotu = *on
500cAC                   eval      $prslot  = lbdisp

500cA*   Note, DRIPRTYRPL will determine qty needed.
500cAC                   eval      $prqtynu = *on
500fAC                   eval      $prqtyn  = lbqpck - newpck

500cA*   Note, DRIPRTYRPL will determine if slot is filled to needed qty.
500cAC**                 eval      $prfillu = *on
500cAC**                 eval      $prfill  = 'Y'

500cAC                   eval      $dricommand = '*PRTYRPL'
500eDC*                  eval      $drisubcmd  = '*CRTRPLSQ1'
500eMC                   eval      $drisubcmd  = '*CRTRPFSQ1'

500cAC                   eval      $drisys2upd = 'D'
500cAC                   exsr      zzzdricop
500cAC                   if        error = *on
500cA*   Note, following two lines for debugging purposes.
500cAC*                  eval      errmsg = $drimessage
500cAC*                  exsr      zm0105
500cAC                   eval      error = *off
500cAC                   endif
     *
500cAC     endrepl       endsr

500lA*----------------------------------------------------------------
500lA*
500lA*  ZZrunner   Create Runner records
500lA*
500lAC     zzrunner      begsr

710aAC                   eval      kywhse = lbwhse
710aAC                   eval      kyitem = lbitem
710aAC                   exsr      zzitemfld

500kAC                   select
500kA*    When Merge label, set flag type M=Merge.
500kAC                   when      lbtype = 'M'
500kAC                   eval      kytype = lbtype
500kA*
500kA*    Item can be replenished, set type to N=Normal.
500kA*    or Flags are cleared even if entire qty isn't found.
500kAC                   when      $drireturn = '*OK'
500mMC                             or opfclr = 'Y'
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      kytype = 'B'
710aAC                   else
500gAC                   eval      kytype = 'N'
710aAC                   EndIf
500kA*
500kA*    Item can't be replenished, set type to U=Out.
500kAC                   other
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      kytype = 'B'
710aAC                   else
500kAC                   eval      kytype = 'U'
710aAC                   EndIf
500kA*
500kAC                   endsl
500kA*
500gDC*    lblbl#        chain     runner                             79
500gMC     keyru         chain     runner                             79
417a C                   if        *in79
417a C                   clear                   rurec
417a C                   eval      ruwhse = lbwhse
417a C                   eval      ruwhdp = lbwhdp
417a C                   eval      rulbl# = lblbl#
500oAC                   if        difpck > 0
500oDC*                  eval      ruqyso = lbqpck - newpck
500oMC                   eval      ruqyso = difpck
500oAC                   endif
500gAC                   eval      ruoqys = ruqyso
417a C                   eval      ruotrn = lbtrn#
417a C                   eval      rudisp = lbdisp
417a C                   eval      rustat = 'O'
500g *
500g * If priority replenishment created, set status to O=Open.
500gAC                   select
500gA*    When Merge label, set flag type M=Merge.
500gAC                   when      lbtype = 'M'
500gAC                   eval      rutype = lbtype
510 AC                   eval      kywhse = lbwhse
500gAC                   eval      kyitem = lbitem
500gAC                   exsr      zzitem
500gA*
500gA*  Use item's dept. when adding Merge record. Dept in
500gA*  Merge record is actually item zone.
500gAC                   eval      ruwhdp = itwhdp
500gA*
500gA*    Item can be replenished, set type to N=Normal.
500gA*    or Flags are cleared even if entire qty isn't found.
500gAC                   when      $drireturn = '*OK'
500mMC                             or opfclr = 'Y'
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500gAC                   eval      rutype = 'N'
710aAC                   EndIf
500gA*
500gA*    Item can't be replenished, set type to U=Out.
500gAC                   other
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500gAC                   eval      rutype = 'U'
710aAC                   EndIf
500gA*
500gAC                   endsl
417a *
417a * Update the datestamp field with the current time.
417a *
500dDC*                  call      'GETTS'
500dDC*                  parm                    ruodts
500dA*
500dAC                   time                    currstamp
500dAC                   eval      ruodts = currstamp
417c *
417c * Initialize other datestamp fields.
417c *
500dDC*                  movel(p)  tsinz         rupdts
500dDC*                  movel(p)  tsinz         rucdts
417a *
417a C                   write     rurec
417e C                   else
417e C                   unlock    runner
417a C                   endif

500lAC                   endsr

500cA*----------------------------------------------------------------
500cA*
500cA*  ZZslot  - write record to SLOTOUT file
500cA*
500cAC     zzslot        begsr

500cAC                   clear                   sorec
500cAC                   eval      sowhse  = lbwhse
500cAC                   eval      sowhdp  = lbwhdp
500cAC                   eval      sodisp  = lbdisp
500cAC                   eval      soitem  = lbitem
500cAC                   time                    currstamp
500cAC                   eval      soadts  = currstamp
500cAC                   eval      soaby   = #job
     *
500cAC                   write     sorec
500lAC                   eval      $slotout = '*YES'
     *
500cAC     endslot       endsr

520bAC*----------------------------------------------------------------
520bAC*  zzUnpick1   Unpick breakdown qty 1
520bAC*----------------------------------------------------------------
520bA
520bAC     zzUnpick1     begsr

     C*  Unpick full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and slpck1 > 0
     C                              and itumq2 > 0
     C                   eval      slpck1 -= 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     C*     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slpck2
     C                   eval      slpck2 -= svqty2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif

     C*     Not enough avaialble, break down a case and loop.

     C                   if        slpck1 > 0
     C                              and itumq2 > 0
     C                   eval      slpck1 -= 1
     C                   eval      slpck2 += itumq2
     C                   iter
     C                   endif

     C*     Case not available, zero out allocated qty.

     C                   eval      slpck2 = 0

     C                   leave
     C                   enddo

     C*  Now see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 is needed to cover brkdn1 allocated.

     C                   exsr      avail
     C                   dow       avail2 < 0
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUPWQ   Update warehouse quantities when CLSFLG = *OFF
     *
     *    This routine is called from ZZUPDW when CLSFLG = *NO.
     *    Essentially, this routine replaces ZZUPDW in that situation.
     *    All this routine does, is to update the allocated warehouse
     *    quantities with the calculated difference.
     *
     C     zzupwq        begsr
     *
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     *
     *      Reduce allocation by difference except when
     *      label is for a special order.
     *
     C                   if        lbspcl = *blanks
500lA*
500lA* Runner flag is being closed and qty was found.  Update Allocated
500lA* qty to add back in qty found.                                  d

500lAC                   if        $pcmd = '*CLSFLAG' and difpck < 0
520bDC**                 eval      $acmd = '*ALLOC  '
520aAC                   eval      difpck = %abs(difpck)
520bAC                   select
520bAC                   when      lbutyp = 'N'
520bAC                   eval      $acmd = '*ALLOCN'
520bAC                   when      lbutyp = '1'
520bAC                   eval      $acmd = '*ALLOC1'
520bAC                   when      lbutyp = '2'
520bAC                   eval      $acmd = '*ALLOC2'
520bAC                   endsl
500lAC                   else
520bDC**                 eval      $acmd = '*UNALLOC'
520bAC                   select
520bAC                   when      lbutyp = 'N'
520bAC                   eval      $acmd = '*UNALOCN'
520bAC                   when      lbutyp = '1'
520bAC                   eval      $acmd = '*UNALOC1'
520bAC                   when      lbutyp = '2'
520bAC                   eval      $acmd = '*UNALOC2'
520bAC                   endsl
500lAC                   endif
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      $aqty1 = difpck
     C                   when      lbutyp = '1'
     C                   eval      $aqty2 = difpck
     C                   when      lbutyp = '2'
     C                   eval      $aqty3 = difpck
     C                   endsl
     C                   exsr      zzwhse
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWHSE   Update warehouse quantities.
     *
     C     zzwhse        begsr
     *
     C                   eval      svitem = $aitem
     *
     *    If Alias item or Same Slot Breakdown item
     *      Then DO NOT update quantity of label item.
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
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
     C                   parm                    $aerm            60
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   endif
     C                   endif
     *
     *  If Alias or SSB item
     *   Then update Base item warehouse quantity.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
     C                   eval      $aitem = #bitem
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
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   endif
     C                   endif
     *
     *  If Contract item and *STOCK or *UNSTOCK
     *   Then update Base item warehouse quantity.
     *    and allocate/unallocate Base item warehouse quantity.
     *
     *  Note: The *UNALLOC command does not effect the Contract
     *        item's Base item Allocated quantities.
     *
     C                   if        ittype = 'C'
     C                   if        $acmd <> '*UNALLOC'
     C                   eval      $aitem = #bitem
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
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   endif
     C                   endif
     *
     C                   if        $acmd = '*STOCK  '  or
     C                             $acmd = '*UNSTOCK'
     C                   if        $acmd = '*STOCK  '
     C                   eval      $acmd = '*ALLOC  '
     C                   else
     C                   eval      $acmd = '*UNALLOC'
     C                   endif
     C                   eval      $aitem = #bitem
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
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   endif
     C                   endif
     C                   endif
     *
     C                   eval      $aitem = svitem
     C                   endsr
500bA*----------------------------------------------------------------
500bA*                     DRI Subroutines
500bA*----------------------------------------------------------------

750aA*----------------------------------------------------------------
750aA*  calldriordc Calls DRIORDC to delete the 99/4 ordcflg record
750aA*----------------------------------------------------------------
750aA
750aAC     calldriordc   begsr
750aA /free
750aA   savever# = $ocver#;
750aA   clear $ordc;
750aA   $ocver# = savever#;

750aA    $ocwhseu = *on;
750aA    $ocwhse = lbwhse;
750aA    $octranu = *on;
750aA    $octran = lbtrn#;
750aA    $dridata = $ordc;

750aA    driOrdc('%DELETE99': #prog: $drireturn:
750aA             $drimessage: $dridata);

         $ordc = $dridata;
750aA /end-free
750aAC                   endsr

500bA*----------------------------------------------------------------
500bA*  clr$prtyrpl  Clear $prtyrpl data structure fields
500bA*----------------------------------------------------------------

500bAC     clr$prtyrpl   begsr
500bAC                   eval      savever# = $prver#
500bAC                   clear                   $prtyrpl
500bAC                   eval      $prver# = savever#
500bAC                   endsr

500bA*----------------------------------------------------------------
500bA*  zzzdricop  Call DRICOP
500bA*----------------------------------------------------------------

500bAC     zzzdricop     begsr
500bAC                   eval      error = *off

500bAC                   select
500bAC                   when      $dricommand = '*PRTYRPL'
500bAC                   eval      $dridata = $prtyrpl
500bAC                   endsl

500bAC                   call(e)   'DRICOP'
500bAC                   parm                    $dricommand
500bAC                   parm                    $drisubcmd
500bAC                   parm                    $drisys2upd
500bAC                   parm      #prog         $driprogram
500bAC                   parm      ' '           $drireturn
500bAC                   parm      ' '           $drimessage
500bAC                   parm                    $dridata

500bAC                   select

500bAC                   when      %error
500bAC                   eval      error = *on
500bAC                   eval      errmsg    = 'Error occured on call to '
500bAC                                       + 'DRICOP'
500bAC                                       + '/' + %trim($drisubcmd)
500bAC                                       + ' from ' + #prog

500bAC                   when      $drireturn <> '*OK'
500bAC                   eval      error = *on

500bAC                   endsl

500bAC                   select
500bAC                   when      $dricommand = '*PRTYRPL'
500bAC                   eval      $prtyrpl = $dridata
500bAC                   endsl

500bAC     enddricop     endsr
