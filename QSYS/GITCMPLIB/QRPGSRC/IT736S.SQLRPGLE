640aA /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT736S    Stage Export - Item quantities
     *  14 February 2011
     *  Dave Sommerville
     *
     *  This program was based on IT736. All IT736 revision comments
     *  were kept in this program. See 640 notes.
     *
     *  Revisions
     *
416 A*   12/26/01  DAS  4.16
     *     - Added fields to export file.
     *
417 A*   02/13/04  MLB  4.17
     *     - Enh: Removed check for expired slots. All pick slots
     *       will be exported even if slot is expired.
     *
500 A*   03/15/05  MLB  5.00
     *     - Enh: Added custom client code support to program.
     *
610 A*   05/25/10  MLB  6.10
     *     - Enh: Revised program to skip slots with SLDESG = BFC.
     *       Slots with designation = BFC are internal use slots.
     *
640aA*    02/14/11  DAS  640a
     *      - IT739S created.
     *      - Revised to use staging file EXPSQTY instead of EXPFQTY.
     *      - Added field QEWHDP from file EXPFQTY2.
     *      - Removed contract item code.
     *      - Revised to select all departments and sections.
     *
640bA*    02/24/11  DAS  640b
     *      - Changed batch type from EXPADJUST to EXPITEMQTY.
650aA*   03/21/13  KDE  6.50a
     *      - Enh: Added the ability to have more than one component  tus
     *        item on a Repack Item.  This required a loop and the
     *        moving of some code from the mainline to a subroutine
730a *   01/19/19  RTR  7.30a
     *      - Enh: Added OPTIONINT values for BIR mod to send overflow
     *        and CSP mod to send base for virtuals.
730b *   11/06/18  RTR  7.30b
     *      - Enh: Added file LASTPICK to store previous and only send
     *        changes. Some hosts only use for pick updates. Controlled
     *        via OPTIONINT flag Interfaces|Export Qty|Only Pick Changes.
740a *   12/03/20  RTR  7.40a
     *      - Fix: Handle when stock qty 1 > 99999.
760a *   04/29/22  DAS  7.60a
     *      - Addef file SLOT3ASL, which is used for Marques.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *
BIR A*   02/03/05  MLB  BIR
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Donson's
     *
DON A*   03/15/05  MLB  DON
     *     - Revised GETPCK to remove '-' from slot display when
     *       updating QEDSP1. From: R-26-22 To: R2622.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF - Allen Foods
     *
ALN A*   01/10/07  MLB  ALN
     *     - Added USF-Allen to BIR mod listed above.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*   09/01/09  RH   SVLa
     *     - Enh: Revised program to export type 'S' qty brk qty field
     *       of parent item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*   05/10/10  MLB  CCP
     *     - Enh: Revised program to export type 'R' items quantity
     *       onhand converted to full cases. Eaches left over are not
     *       included. Qty is added to parent item full case qty.
     *     - Added file KITCOMP.
CCPaA*   05/10/10  MLB  CCPa
     *     - Enh: Revised program to allow type 'B and 'R' items to
     *       be written into the export file to be used to update the
     *       pick slot info on the Host system.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*   05/25/10  MLB  CSP
     *     - Enh: Revised program to look for overflow slots if no
     *       pick slots are found for item. Per Roxanne. On-Site.
CSPaA*   05/25/10  MLB  CSPa
     *     - Enh: Revised program to send 74-111-1 for items with item
     *       designation of JIT if no slot(s) found for item.
CSPbA*   05/25/10  MLB  CSPb
     *     - Enh: Revised program to send BRKN for pick slot when
     *       item designation is BRKN or slot 63-200-1.
     *     - Added VSLOT1 to program.
CSPcA*   05/26/10  MLB  CSPc
     *     - Enh: Revised program to allow Alias items to be exported.
     *       Send base item pick slot for Alias item.
CSPdA*   08/24/10  MLB  CSPd
     *     - Enh: Revised program to retrieve pick slot for JIT repack
     *       items using call to pgm GETITMFLD.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WILa *   01/05/14  RTR  WILa
     *     - Added Will Foods to BIR mod listed above.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFSa *   05/07/18  RTR  KFSa
     *     - Added Will Foods to BIR mod listed above.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQSa *   05/10/18  DAS  MQSa
     *     - Replaced SLOT3 with SLOT3ASL, which puts SLAISL first,
     *       after SLPICK.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
CSPbA*  74        NRF on chain to VSLOT1
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     Fpiritem1  if   e           k disk
     F                                     rename(itrec:itrec1)
     Fitemqty   if   e           k disk
     Fitemlnk   if   e           k disk
CCP AFkitcomp   if   e           k disk    usropn
     Fslot3     if   e           k disk
MQSaAFslot3asl  if   e           k disk    usropn
MQSaAF                                     rename(slrec:slrec3)
CSPbAFvslot1    if   e           k disk
416 AFitemdef   if   e           k disk
416 AFslotdef   if   e           k disk
CCP D*EXPFQTY O   E           K        DISK                      A
640aDF*xpfqty   uf a e           k disk
640aMFexpsqty   uf a e           k disk
730bAflastpick  uf a e           k disk
500 A*----------------------------------------------------------------
500 A*  Client id's for custom mods.
500 A*----------------------------------------------------------------
500 AD/COPY QCOPYSRC,ID#DONSONS
BIR A /COPY QCOPYSRC,ID#BIRITE
ALN AD/COPY QCOPYSRC,ID#ALLEN
SVLaA /COPY QCOPYSRC,ID#SAVAL
CCP A /COPY QCOPYSRC,ID#CAPITOL
CSP A /COPY QCOPYSRC,ID#COASTAL
WILaA /copy qcopysrc,id#wil
KFSaA /copy qcopysrc,id#kfs
MQSaA /copy qcopysrc,id#mqs

500 AD                 ds
500 AD  client                 1     10
     D @getcl          c                   const('GETCLIENT')
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aA*   Old parms from IT736 that are not used anymore.
640aA*   Hardcoded values to keep program changes to a minimum.
640aAD $pWhdp          s              5    inz('*ALL')
640aAD $pStyp          s              1    inz('B')
640aAD $pIncl          s              1    inz('N')
640aAD $pRFlg          s              1    inz('N')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @itmfl          c                   const('GETITEMFLD')
730bA /copy *libl/qcopysrc,p.getopint

DON A*----------------------------------------------------------------
DON A*  Working variables
DON A*
DON AD                 ds
DON AD  aisle                  1      1
DON AD  loc                    2      3
DON AD  lvlhnd                 4      5
DON AD  donslt                 1      5
CCP AD                 ds
CCP AD  extqty                 1      7  0
CCP AD  whlcas                 8     14  0

650aAdsavExpF          ds
650aAd savwhse                             like(qewhse)
650aAd savitem                             like(qeitem)
650aAd savtype                             like(qetype)
650aAd savbitm                             like(qebitm)
650aAd savstk1                             like(qestk1)
650aAd savstk2                             like(qestk2)
650aAd savstk3                             like(qestk3)
650aAd savdsp1                             like(qedsp1)
650aAd savdsp2                             like(qedsp2)
650aAd savdsp3                             like(qedsp3)
650aAd savcube                             like(qecube)
650aAd savsdf1                             like(qesdf1)
650aAd savpal1                             like(qepal1)
650aAd savpos1                             like(qepos1)
650aAd savti1                              like(qeti1)
650aAd savhi1                              like(qehi1)
650aAd savsdf2                             like(qesdf2)
650aAd savpal2                             like(qepal2)
650aAd savpos2                             like(qepos2)
650aAd savti2                              like(qeti2)
650aAd savhi2                              like(qehi2)
650aAd savsdf3                             like(qesdf3)
650aAd savpal3                             like(qepal3)
650aAd savpos3                             like(qepos3)
650aAd savti3                              like(qeti3)
650aAd savhi3                              like(qehi3)
DON A*----------------------------------------------------------------
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
     *  Variables
     *
640aAD batId           s             11
640aAD forever         s               n
     D forevr          s              1
640aAD haveBatId       s               n
650aAD multicount      s              4  0
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D opnkit          s              1
730aAD optOverflow     s               n
730aAD optSendBase     s               n
730bAd optPickOnly     s               n
730bAd pickChange      s               n
640aAD rtnCode         s             10
640aAD rtnMessage      s            200
     D scount          s              1  0
640aAD stamp           s               z
640aAD stampUC         s               z
     D today           s              8  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
640aAC                   eval      haveBatId = *off
     *
     *  Set beginning limits on appropriate file.
     *
     C                   if        $pwhdp = '*ALL'
     C     keyitw        setll     piritem
     C                   else
     C     keyitd        setll     piritem1
     C                   endif
     *
     *  Loop through item records.
     *
     C                   dou       forevr <> forevr
     C                   if        $pwhdp = '*ALL'
     C     keyitw        reade     piritem                                77
     C                   else
     C     keyitd        reade     piritem1                               77
     C                   endif
     *
     *    Get out if EOF or Department doesn't match.
     *
     C                   if        *in77  or
     C                             $pwhdp <> '*ALL'  and
     C                             itwhdp <> $pwhdp
     C                   leave
     C                   endif
     *
     *    Accept or Reject based on section type.
     *
     C                   if        $pstyp = 'F'  and
     C                             itstyp <> 'F'  or
     C                             $pstyp = 'P'  and
     C                             itstyp <> 'P'
     C                   iter
     C                   endif
     *
     *    Accept or Reject based on item type.
     *
     C                   if        ittype = 'A'  and
CSPcAC                             client <> coastl  or
CSPcA*
     C                             ittype = 'C'  and
     C                             $pincl <> 'Y'
     C                   iter
     C                   endif
SVLa *    Skip type'S' items, qty will be included with parent item.
SVLa *
SVLa C                   if        client = saval  and
SVLa C                             ittype = 'S'
SVLa C                   iter
SVLa C                   endif
640aA
640aA*    If first time, get batch id.
640aA*      If error, get out.
640aA
640aAC                   if        not haveBatId
640aAC                   exsr      zzzGetBatId
640aAC                   if        batId = ' '
640aAC                   leave
640aAC                   endif
640aAC                   eval      haveBatId = *on
640aAC                   endif
     *
     *    Record accepted for Export.
     *
     C                   clear                   qerec
     C                   eval      qewhse = itwhse
     C                   eval      qeitem = ititem
640aAC                   eval      qewhdp = itwhdp
     C                   eval      qetype = ittype
416 AC                   eval      qecube = itcube

640aAC                   exsr      zzzGetStamps
640aAC                   eval      qebatid = batId
640aAC                   eval      qestatus = 'R'
640aAC                   eval      qeststs = stamp
640aAC                   eval      qestsuc = stampuc
640aAC                   eval      qeaddts = stamp
640aAC                   eval      qeadduc = stampuc
     *
     *    Get corresponding base item.
     *
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   if        ittype <> ' '
650aAC                              and ittype <> 'R'
     C     keyil         chain     itemlnk                            78
     C                   if        *in78
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   endif
     C                   endif
     C                   eval      qebitm = ilitm2
640aDC**                 eval      qecitm = ilitm3
     *
     *  Get item stock quantity.
     *
     C                   exsr      getqty
     *
     *  Get pick slots for item (max of 3)
     *
     C                   exsr      getpck
     *
     *  Add export record
     *
CCPaA*
CCPaAC                   if        client = capcty
CCPaA*
CCPaAC                   select
CCPaA*     Brkdwn item being processed.
CCPaAC                   when      ittype = 'B'  or
CCPaA*     Repack item being processed.
CCPaAC                             ittype = 'R'
CCPaA*     Do not allow any qty info to be sent to Host.
CCPaA*     Quantity is included in Parent Item Case qty.
CCPaAC                   eval      qestk1 = *zeros
CCPaAC                   eval      qestk2 = *zeros
CCPaAC                   eval      qestk3 = *zeros
CCPaAC                   endsl
CCPaA*
CCPaAC                   endif
CCPaA*
640aDC**                 eval      qedate = today
640aDC**                 time                    qetime
730bA /free
730bA   // Only send changes if option set
730bA   if optPickOnly;
730bA     exsr zzPickChange;
730bA     if not pickChange;
730bA       iter;
730bA     endif;
730bA   endif;
730bA /end-free
     C                   write     qerec                                79
CCP A*
650aA*  The following Capitol code was moved to routine zzUpConvert
650aDC*                  if        client = capcty
650aD*
650aDC*                  select
650aD*     Add Brkdwn Qty into Parent Case Qty.
650aDC*                  when      ittype = 'B'  or
650aD*     Add Repack Qty into Parent Case Qty.
650aDC*                            ittype = 'R'
650aD*
650aD*     Retrieve Parent Item Qty record.
650aDC**   kyqeb         chain     expfqty                            79
650aDC*    kyqeb         chain     expsqty                            79
650aDC*                  if        *in79
650aDC*                  eval      qeitem = qebitm
650aDC*                  eval      qebitm = *blanks
650aDC*                  eval      qetype = *blanks
650aDC**                 eval      qedate = today
650aDC**                 time                    qetime
650aDC*                  z-add     whlcas        qestk1
650aDC*                  write     qerec                                79
650aDC*                  else
650aDC*    qestk1        add       whlcas        qestk1
650aDC*                  update    qerec
650aDC*                  endif
650aD*
650aDC*                  endsl
650aD*
650aDC*                  endif
     *
     C                   enddo
     *
640aA /free
640aA
640aA    if haveBatId;
640aA      exsr zzzEnd;
640aA    endif;
640aA
640aA /end-free
     *
640aDC**                 eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500 A*
500 A*  Get client id
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client
500 A*
MQSaAC                   if        client = marques
MQSaAC                   open      slot3asl
MQSaAC                   endif
     *
     *  Define key for PIRITEM file.
     *
     C     keyitw        klist
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM1 file.
     *
     C     keyitd        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for ITEMQTY file.
     *
     C     keyiq         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     *
     *  Define key for ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
CCP A*
CCP A*  Define key for EXPFQTY file.
CCP A*
CCP AC     kyqeb         klist
CCP AC                   kfld                    $pwhse
640aAC                   kfld                    batId
CCP AC                   kfld                    qebitm
CCP A*
CCP A*  Define key for KITCOMP file.
CCP A*
CCP AC     keykc         klist
CCP AC                   kfld                    $pwhse
CCP AC                   kfld                    ititem
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
CSPbA*
CSPbA*  Define full key for VSLOT1 file.
CSPbA*
CSPbAC     keyvs1        klist
CSPbAC                   kfld                    itwhse
CSPbAC                   kfld                    slwhdp
CSPbAC                   kfld                    sldisp
416 A*
416 A*  Define key for SLOTDEF file.
416 A*
416 AC     keysd         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slsdef
416 A*
416 A*  Define key for ITEMDEF file.
416 A*
416 AC     keyid         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slitem
416 AC                   kfld                    slsdef
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
CCP A*
CCP AC                   eval      opnkit = *off
CCP AC                   if        client = capcty
CCP A*
CCP AC                   if        opnkit = '0'
CCP AC                   open      kitcomp
CCP AC                   eval      opnkit = *on
CCP AC                   endif
CCP A*
CCP AC                   endif
CCP A*
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
730aA /free
730aA   // Get Option to see if overflow when no pick.
730aA   optint.type = 'Interface   ';
730aA   optint.cat  = 'Export ItemQty      ';
730aA   optint.name = 'Overflow if no Pick ';
730aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730aA             optint.valn: optint.vala: optint.return);
730aA   if optint.return = '*OK'
730aA    and optint.vala = 'Y';
730aA     optOverflow = *on;
730bA   else;
730bA     optOverflow = *off;
730aA   endif;

730aA   // Get Option to see if to send base for virtuals.
730aA   optint.type = 'Interface   ';
730aA   optint.cat  = 'Export ItemQty      ';
730aA   optint.name = 'Send Base if Virtual';
730aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730aA             optint.valn: optint.vala: optint.return);
730aA   if optint.return = '*OK'
730aA    and optint.vala = 'Y';
730aA     optSendBase = *on;
730bA   else;
730bA     optSendBase = *off;
730aA   endif;

730bA   // Get option for only pick slot changes
730bA   optint.type = 'Interface   ';
730bA   optint.cat  = 'Export ItemQty      ';
730bA   optint.name = 'Only Pick Changes   ';
730bA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
730bA             optint.valn: optint.vala: optint.return);
730bA   if optint.return = '*OK'
730bA    and optint.vala = 'Y';
730bA     optPickOnly = *on;
730bA   else;
730bA     optPickOnly = *off;
730bA   endif;
730bA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPCK  Get pick slots for item (max of 3)
     *
     C     getpck        begsr
     C                   eval      scount = 0
     *
     *  If Contract or SSB item
     *   Then use Base item to look for slots
     *   Otherwise use record item
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'S'  or
CSPcA*
CSPcAC                             client = coastl  and
CSPcAC                             ittype = 'A'
CSPcA*
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   endif
CSPdA*
CSPdAC                   if        client = coastl
CSPdA*
CSPdA*  If item is JIT repack item, load slot returned with item.
CSPdAC                   if        ittype = 'R'
CSPdAC                   call      @itmfl
CSPdAC                   parm      $pwhse        rwhse             3 0
CSPdAC                   parm      kyitem        ritem            15
CSPdAC                   parm      ' '           rcat             10
CSPdAC                   parm      ' '           rcasof            1
CSPdAC                   parm      *blanks       rodrsl           12
CSPdAC                   if        rodrsl > ' '
CSPdAC                   eval      qedsp1 = rodrsl
CSPdAC                   eval      scount = 1
CSPdAC                   goto      #csp
CSPdAC                   endif
CSPdA*
CSPdAC                   endif
CSPdA*
CSPdAC                   endif
     *
     *   Loop through picking slots for base item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
MQSaAC                   if        client = marques
MQSaAC     keysl3        setll     slot3asl
MQSaAC                   else
     C     keysl3        setll     slot3
MQSaAC                   endif
     C                   dou       forevr <> forevr
MQSaAC                   if        client = marques
MQSaAC     keysl3        reade     slot3asl
MQSaAC                   else
     C     keysl3        reade     slot3                                  77
MQSaAC                   endif
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
     C                             slexpd < today
417 D*R                   ITER
     C                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
416 A*
416 A*     Get slot definition information.
416 A*
416 AC     keysd         chain     slotdef                            77
416 AC                   if        *in77
416 AC                   clear                   sdpal
416 AC                   clear                   sdpos
416 AC                   endif
416 A*
416 A*     Get item tie/high information.
416 A*
416 AC     keyid         chain     itemdef                            77
416 AC                   if        *in77
416 AC                   clear                   idtie
416 AC                   clear                   idhigh
416 AC                   endif
     *
     *     Add to item's slots
     *
     C                   add       1             scount
     C                   select
     C                   when      scount = 1
DON AC                   if        client = donsons
DON AC                   eval      aisle = *blanks
DON AC                   eval      loc = *blanks
DON AC                   eval      lvlhnd = *blanks
DON AC                   eval      aisle = %subst(sldisp:1:1)
DON AC                   eval      loc = %subst(sldisp:3:2)
DON AC                   eval      lvlhnd = %subst(sldisp:6:2)
DON AC                   eval      qedsp1 = %trimr(aisle) + loc
DON AC     qedsp1        cat       lvlhnd:0      qedsp1
DON A*
DON AC                   else
CSPbA*
CSPbAC                   if        client = coastl
KFSaAC                             or client = Kellys
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedsp1 = sldisp
DON AC                   endif
416 AC                   eval      qesdf1 = slsdef
416 AC                   eval      qeti1 = idtie
416 AC                   eval      qehi1 = idhigh
416 AC                   eval      qepos1 = sdpos
416 AC                   eval      qepal1 = sdpal
     C                   when      scount = 2
CSPbA*
CSPbAC                   if        client = coastl
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedsp2 = sldisp
416 AC                   eval      qesdf2 = slsdef
416 AC                   eval      qeti2 = idtie
416 AC                   eval      qehi2 = idhigh
416 AC                   eval      qepos2 = sdpos
416 AC                   eval      qepal2 = sdpal
     C                   when      scount = 3
CSPbA*
CSPbAC                   if        client = coastl
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedsp3 = sldisp
416 AC                   eval      qesdf3 = slsdef
416 AC                   eval      qeti3 = idtie
416 AC                   eval      qehi3 = idhigh
416 AC                   eval      qepos3 = sdpos
416 AC                   eval      qepal3 = sdpal
     C                   leave
     C                   endsl
     *
     C                   enddo
BIR A*
BIR AC                   if        client = birite  or
ALN AC                             client = allen  or
WILaAC                             client = willfoods or
CSP AC                             client = coastl
730aAC                             or optOverflow = *on
BIR A*
BIR A*    Look for overflow slots when no pick slot(s) found.
BIR AC                   if        scount = 0
BIR AC                   eval      kystat = 'A '
BIR AC                   eval      kypick = 'N'
BIR AC     keysl3        setll     slot3
BIR AC                   dou       forevr <> forevr
BIR AC     keysl3        reade     slot3                                  77
BIR AC                   if        *in77
BIR AC                   leave
BIR AC                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
BIR A*
BIR A*     Get slot definition information.
BIR A*
BIR AC     keysd         chain     slotdef                            77
BIR AC                   if        *in77
BIR AC                   clear                   sdpal
BIR AC                   clear                   sdpos
BIR AC                   endif
BIR A*
BIR A*     Get item tie/high information.
BIR A*
BIR AC     keyid         chain     itemdef                            77
BIR AC                   if        *in77
BIR AC                   clear                   idtie
BIR AC                   clear                   idhigh
BIR AC                   endif
BIR A*
BIR A*     Add to item's slots
BIR A*
BIR AC                   add       1             scount
BIR AC                   select
BIR AC                   when      scount = 1
CSPbA*
CSPbAC                   if        client = coastl
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp1 = sldisp
BIR AC                   eval      qesdf1 = slsdef
BIR AC                   eval      qeti1 = idtie
BIR AC                   eval      qehi1 = idhigh
BIR AC                   eval      qepos1 = sdpos
BIR AC                   eval      qepal1 = sdpal
BIR AC                   when      scount = 2
CSPbA*
CSPbAC                   if        client = coastl
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp2 = sldisp
BIR AC                   eval      qesdf2 = slsdef
BIR AC                   eval      qeti2 = idtie
BIR AC                   eval      qehi2 = idhigh
BIR AC                   eval      qepos2 = sdpos
BIR AC                   eval      qepal2 = sdpal
BIR AC                   when      scount = 3
CSPbA*
CSPbAC                   if        client = coastl
730aAC                             or OptSendBase = *on
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedsp3 = sldisp
BIR AC                   eval      qesdf3 = slsdef
BIR AC                   eval      qeti3 = idtie
BIR AC                   eval      qehi3 = idhigh
BIR AC                   eval      qepos3 = sdpos
BIR AC                   eval      qepal3 = sdpal
BIR AC                   leave
BIR AC                   endsl
BIR A*
BIR AC                   enddo                                                  End - forevr
BIR AC                   endif                                                  End - Scount=0
BIR AC                   endif                                                  Client=BiRite
CSPaA*
CSPdAC     #csp          tag
CSPaAC                   if        client = coastl
CSPaA*
CSPaAC                   if        itdesg = 'JIT  '  and
CSPaAC                             scount = 0
CSPaAC                   eval      qedsp1 = '74-111-1'
CSPaAC                   endif                                                  Itdesg = JIT
CSPbA*
CSPbAC                   if        qedsp1 = '63-200-1'  or
CSPbAC                             qedsp2 = '63-200-1'  or
CSPbAC                             qedsp3 = '63-200-1'  or
CSPbAC                             itdesg = 'BRKN  '
CSPbAC                   eval      qedsp1 = 'BRKN'
CSPbAC                   eval      qedsp2 = *blanks
CSPbAC                   eval      qedsp3 = *blanks
CSPbAC                   endif                                                  Itdesg = BRKN
CSPbA*
CSPbAC                   endif                                                  Client=Coastal
CSPbA*
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETQTY  Get quantity for item
     *
     C     getqty        begsr
     *
     *  If SSB item
     *   Then get qty for Base item
     *   Otherwise use record item and check for existance of SSB item.
     *
     C                   if        ittype = 'S'
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   call      'CHKSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm                    $gexst            1
     C                   endif
     *
     *  Get stock quantity for item.
     *
     C     keyiq         chain     itemqty                            79
     C     *in79         cabeq     *on           endqty
     *
     C                   select
     *
     *      Same Slot Breakdown item uses the bkdn 1 & 2
     *      of the Base item's quantities.
     *
     C                   when      ittype = 'S'
     C                   eval      qestk1 = iqstk2
     C                   eval      qestk2 = iqstk3
     *
     *     For Saval, send type 'S' item quantity with parent item.
SVLa C                   when      client = saval  and
SVLa C                             $gexst = 'Y'
SVLa C                   z-add     iqstk1        qestk1
SVLa C                   eval      qestk2 = iqstk2
CCP A*
CCP A*     For Capitol City, send type 'B' item qty with parent item.
CCP AC                   when      client = capcty  and
CCP AC                             ittype = 'B'  or
CCP A*     For Capitol City, send type 'R' item qty with parent item.
CCP AC                             client = capcty  and
CCP AC                             ittype = 'R'
CCP AC                   exsr      zzcvqy
     *
     *      If an item has a Same Slot Breakdown item
     *       then use only the Normal quantity.
     *
     C                   when      $gexst = 'Y'
     C                   z-add     iqstk1        qestk1
     *
     *      Otherwise take quantities as they are.
     *
     C                   other
740aAc                   if        iqstk1 > 99999
740aAc                   z-add     99999         qestk1
740aAc                   else
     C                   z-add     iqstk1        qestk1
740aAc                   endif
     C                   eval      qestk2 = iqstk2
     C                   eval      qestk3 = iqstk3
     *
     C                   endsl
     *
     *  Reduce qty by corresponding Contract qty's if that
     *    is what the user wants.
     *
     C                   if        $pincl = 'Y'  and
     C                             $prflg = 'Y'
     *
     C                   call      'GETCON'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm                    $gcnt             3 0
     C                   parm                    $gqty1            5 0
     C                   parm                    $gqty2            5 0
     C                   parm                    $gqty3            5 0
     *
     C                   if        $gcnt > 0
640aDC**                 eval      qerflg = 'Y'
     *
     C                   if        qestk1 > $gqty1
     C                   eval      qestk1 = qestk1 - $gqty1
     C                   else
     C                   eval      qestk1 = 0
     C                   endif
     *
     C                   if        qestk2 > $gqty2
     C                   eval      qestk2 = qestk2 - $gqty2
     C                   else
     C                   eval      qestk2 = 0
     C                   endif
     *
     C                   if        qestk3 > $gqty3
     C                   eval      qestk3 = qestk3 - $gqty3
     C                   else
     C                   eval      qestk3 = 0
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     C     endqty        endsr
CCP A*----------------------------------------------------------------
CCP A*
CCP A*  ZZCVQY  Convert Brkdown/Repack Item Qty into Parent Item Case Qty
CCP A*
CCP AC     zzcvqy        begsr
CCP A*
CCP A*     Retrieve base item number info for qty conversions.
650aAc                   eval      multicount = 0
CCP AC                   if        ittype = 'B'
650aDC*                              or ittype = 'R'
CCP AC                   call      'GETBASE'
CCP AC                   parm      $pwhse        $gwhse
CCP AC                   parm      ititem        $gitem
CCP AC                   parm      ' '           #bitem           15
CCP AC                   parm                    #bityp            1
CCP AC                   parm                    #bdesc           30
CCP AC                   parm                    #bpdsc           15
CCP AC                   parm                    #bwhdp            5
CCP AC                   parm                    #bstyp            1
CCP AC                   parm                    #bum1             2
CCP AC                   parm                    #bum2             2
CCP AC                   parm                    #bumq2            3 0
CCP AC                   parm                    #bum3             2
CCP AC                   parm                    #bumq3            3 0
CCP AC                   parm      ' '           #bcitm           15
CCP AC                   parm                    #bctyp            1
CCP AC                   parm                    #bcdsc           30
CCP AC                   parm                    #bcpds           15
CCP AC                   parm                    #bcwdp            5
CCP AC                   parm                    #bcstp            1
CCP AC                   parm                    #bcum1            2
CCP AC                   parm                    #bcum2            2
CCP AC                   parm                    #bcuq2            3 0
CCP AC                   parm                    #bcum3            2
CCP AC                   parm                    #bcuq3            3 0
CCP AC                   parm                    #brtn             8
CCP AC                   endif
CCP A*
CCP AC                   select
CCP A*     Up-convert Breakdown Qty into Parent Case qty.
CCP AC                   when      ittype = 'B'
CCP A*
CCP AC                   if        #bumq2 > 0
CCP AC     iqstk1        div(h)    #bumq2        whlcas
CCP AC                   else
CCP AC                   eval      whlcas = *zeros
CCP AC                   endif
650aAc                   exsr      zzUpConvert
CCP A*
CCP A*
CCP A*     Up-convert Repack Qty into Parent Case qty.
CCP AC                   when      ittype = 'R'
650aA*     Loop Kitcomp for the possibility of multiple parent items
650aA*       for each Repack Item
CCP A*     Retrieve the repack parent conversion factor.
650aAC     keykc         setll     kitcomp
650aDC*    keykc         chain     kitcomp                            79
650aAC     keykc         reade     kitcomp                                79
650aDC*                  if        *in79
650aA*
650aAC                   dow       not *in79
650aA*
650aAC                   call      'GETBASE'
650aAC                   parm      $pwhse        $gwhse
650aAC                   parm      ititem        $gitem
650aAC                   parm      kccitm        #bitem           15
650aAC                   parm                    #bityp            1
650aAC                   parm                    #bdesc           30
650aAC                   parm                    #bpdsc           15
650aAC                   parm                    #bwhdp            5
650aAC                   parm                    #bstyp            1
650aAC                   parm                    #bum1             2
650aAC                   parm                    #bum2             2
650aAC                   parm                    #bumq2            3 0
650aAC                   parm                    #bum3             2
650aAC                   parm                    #bumq3            3 0
650aAC                   parm      ' '           #bcitm           15
650aAC                   parm                    #bctyp            1
650aAC                   parm                    #bcdsc           30
650aAC                   parm                    #bcpds           15
650aAC                   parm                    #bcwdp            5
650aAC                   parm                    #bcstp            1
650aAC                   parm                    #bcum1            2
650aAC                   parm                    #bcum2            2
650aAC                   parm                    #bcuq2            3 0
650aAC                   parm                    #bcum3            2
650aAC                   parm                    #bcuq3            3 0
650aAC                   parm                    #brtn             8
CCP A*
CCP A*     Convert qty onhand into
650aAc                   eval      qebitm = kccitm
CCP AC     iqstk1        mult      kcqty2        extqty
CCP AC                   if        #bumq2 > 0
CCP AC     extqty        div(h)    #bumq2        whlcas
CCP AC                   else
CCP AC                   eval      whlcas = *zeros
CCP AC                   endif
650aAc                   exsr      zzUpConvert
650aAC     keykc         reade     kitcomp                                79
650aAC                   enddo
650aA*  if more than one repack item existed show parent as *KIT
650aAc                   if        multicount > 1
650aAc                   eval      qebitm = '*KIT'
650aAc                   endif
CCP A*
CCP AC                   endsl                                                  Endsl - ittype
CCP A*
CCP AC     endcvq        endsr

650aA*----------------------------------------------------------------
650aA*
650aA*  ZZUpConvert  Up Convert to Parent qty/item for Capitol Repack Qty
650aA*    and Breakdown items
650aA*
650aAC     zzUpConvert   begsr
650aA*     Save Repack information before parent update/add
     c                   exsr      SavEXPFValues
650aA*     Retrieve Parent Item Qty record.
650aAc                   eval      multicount = multicount + 1
650aAC     kyqeb         chain     expsqty                            79
650aAC                   if        *in79
650aAC                   eval      qeitem = qebitm
650aAC                   eval      qebitm = *blanks
650aAC                   eval      qetype = *blanks
650aAC**                 eval      qedate = today
650aAC**                 time                    qetime
650aAC                   z-add     whlcas        qestk1
650aAC                   write     qerec                                79
650aAC                   else
650aAC     qestk1        add       whlcas        qestk1
650aAC                   update    qerec
650aAC                   endif
650aA*     Return Repack information to record for update/add
     c                   exsr      rstEXPFValues
650aAC                   endsr
640bA*
640bA*----------------------------------------------------------------
640bA*
640bA*  savEXPFValues  -  Save current Repack item record values
640bA*                     prior to parent update
640bA*
640bAC     savEXPFValues begsr
     c                   eval      savwhse = qewhse
     c                   eval      savitem = qeitem
     c                   eval      savtype = qetype
     c                   eval      savbitm = qebitm
     c                   eval      savstk1 = qestk1
     c                   eval      savstk2 = qestk2
     c                   eval      savstk3 = qestk3
     c                   eval      savdsp1 = qedsp1
     c                   eval      savdsp2 = qedsp2
     c                   eval      savdsp3 = qedsp3
     c                   eval      savcube = qecube
     c                   eval      savsdf1 = qesdf1
     c                   eval      savpal1 = qepal1
     c                   eval      savpos1 = qepos1
     c                   eval      savti1 = qeti1
     c                   eval      savhi1 = qehi1
     c                   eval      savsdf2 = qesdf2
     c                   eval      savpal2 = qepal2
     c                   eval      savpos2 = qepos2
     c                   eval      savti2 = qeti2
     c                   eval      savhi2 = qehi2
     c                   eval      savsdf3 = qesdf3
     c                   eval      savpal3 = qepal3
     c                   eval      savpos3 = qepos3
     c                   eval      savti3 = qeti3
     c                   eval      savhi3 = qehi3
     c                   endsr
640bA*
640bA*----------------------------------------------------------------
640bA*
640bA*  rstEXPFValues  -  Restore Repack record values
640bA*                     after parent update
640bA*
640bAC     rstEXPFValues begsr
     c                   eval      qewhse  = savwhse
     c                   eval      qeitem  = savitem
     c                   eval      qetype  = savtype
     c                   eval      qebitm  = savbitm
     c                   eval      qestk1  = savstk1
     c                   eval      qestk2  = savstk2
     c                   eval      qestk3  = savstk3
     c                   eval      qedsp1  = savdsp1
     c                   eval      qedsp2  = savdsp2
     c                   eval      qedsp3  = savdsp3
     c                   eval      qecube  = savcube
     c                   eval      qesdf1 = savsdf1
     c                   eval      qepal1 = savpal1
     c                   eval      qepos1 = savpos1
     c                   eval      qeti1 = savti1
     c                   eval      qehi1 = savhi1
     c                   eval      qesdf2 = savsdf2
     c                   eval      qepal2 = savpal2
     c                   eval      qepos2 = savpos2
     c                   eval      qeti2 = savti2
     c                   eval      qehi2 = savhi2
     c                   eval      qesdf3 = savsdf3
     c                   eval      qepal3 = savpal3
     c                   eval      qepos3 = savpos3
     c                   eval      qeti3 = savti3
     c                   eval      qehi3 = savhi3
     c                   endsr

730bA*----------------------------------------------------------------
730bA*  zzPickChange   Check for Pick Slot Change
730bA*----------------------------------------------------------------
730bA /free
730bA   begsr zzPickChange;
730bA     pickChange = *off;
730bA     chain (qewhse: qeitem) lastpick;
730bA     select;
730bA       when %found(lastpick)
730bA        and qedsp1 <> lpdisp;
730bA         lpdisp = qedsp1;
730bA         lpststs = %timestamp();
730bA         update lprec;
730bA         pickChange = *on;
730bA       when not %found(lastpick);
730bA         lpwhse = qewhse;
730bA         lpitem = qeitem;
730bA         lpdisp = qedsp1;
730bA         lpststs = %timestamp();
730bA         write lprec;
730bA         pickChange = *on;
730bA     endsl;
730bA   endsr;
730bA /end-free

640aA*----------------------------------------------------------------
640aA*  zzzGetBatId    Get batch id
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetBatId   begsr
      /free

        monitor;
640bM     GetBatId($pWhse: 'EXPITEMQTY': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp - current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

      /end-free
     c                   endsr
