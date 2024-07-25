      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  HQ245     Item Adjustments From Host Picking
     *  27 April 2008
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*  04/27/08  CWM  5.20
     *    - Created.
520aA*  05/17/08  MLB  5.20a
     *    - Revised pgm to verify slot sent contains item. if not,
     *      call GETPSLT pgm to find slot in location that has item.
     *    - Added SLOT4 to pgm.
520bA*  07/01/08  MLB  5.20b
     *    - Fix: Revised program to convert ipqqp1, ipqqp2 and ipqqp3
     *      fields to opposite sign so that incoming invoice qty's are
     *      sent to Dakota as negative qty's reducing on-hand qty's.
     *      Credit memo qty's will be sent as positive qty's increasing
     *      onhand quantities.
520cA*  07/02/08  MLB  5.20c
     *    - Fix: Revised program to call AD900 with *VERIFYB so that
     *      AD900FM isn't opened when called in batch mode.
520dA*  07/15/08  MLB  5.20d
     *    - Fix: Revised program to use different method to search for
     *      slot to adjust when item not found in base slot.
     *      Remove call to GETPSLT since it would not always return
     *      correct slot to adjust.
     *
610 A*  11/05/09  MLB  6.10
     *    - Enh: Revised prFil$Adj to set action code and update flag.
610aA*  03/16/10  MLB  6.10a
     *      - Enh: Added support to pass $slot2 to DRICOP when cmd *SLOT.
530 A*  11/11/09  MLB  5.30
     *    - Fix: Revised program to correctly process adjustments
     *      for SSB items.
530aA*  11/11/09  MLB  5.30a
     *    - Fix: Corrected problems with program when looking for
     *      slot to adjust when no slot sent for item.
530bA*  11/11/09  MLB  5.30b
     *    - Enh: Revised program to populdate RDATE/RTIME with
     *      current date/time.
530cA*  04/29/10  MLB  5.30c
     *    - Fix: Revised program to load WKQTY1 with value from IPQQP1.
     *      Program was not correctly loading cases value when looking
     *      for slot to deduct qty from.
530dA*  05/27/10  MLB  5.30d
     *    - Fix: Revised program to loop until all 3 qty fields are zero.
     *      Fields IPQQP2, IPQQP3 were not be correctly adjusted in
     *      certain situations.
530eA*  05/30/10  MLB  5.30e
     *    - Enh: Added clientloc field to GETCLIENT call in *INZSR.
530fA*  06/02/10  MLB  5.30f
     *    - Fix: Revised program to loop and find next pick slot when
     *      2 pick slots have been read and both have zero available
     *      qty.
530gA*  07/17/10  MLB  5.30g
     *    - Fix: Revised program to handle negative adjustment qty's.
     *      Force adjustment qty to slot found since this will be con-
     *      verted into a plus adjustment.
530hA*  09/09/10  MLB  5.30h
     *    - Enh: Revised program to convert JIT Repack item qty's into
     *      parent item qty's so that the adjustment can be posted
     *      against the parent item pick slot instead of the JIT item's
     *      pick slot.
     *
640aA*    03/08/11  DAS  6.40a
     *      - Revised to used staging file impspckq in place of
     *        file impfpckq.
     *
640bA*    03/11/11  DAS  6.40b
     *      - Revised to only call IT506S one time, not for each record.
640cA*    04/13/11  MLB  6.40c
     *      - Enh: Revised to retrieve report default for processing
     *        override for printer file.
     *
650 A*  03/04/13  MLB  6.50
     *    - Fix: Revised program to no longer report as an exception,
     *      items sent with qty1, qty2, qty3 = zero. Item will still
     *      be written to the history file.
650aA*  05/28/13  MLB  6.50a
     *    - Fix: Revised program to set Brkdwn 1, Brkdwn 2 qty fields
     *      to 1. Qty is sent from Host in lowest qty format in IPQQP1
     *      so no conversion is necessary.
650bA*  03/11/13  KDE      6.50b
     *    - Enh: Added new KITITEM table to pull in On-Demand Pick    t
     *      slot
     *    - Changed to work with KITCOMP now containing On-Demand     t
     *      slot for parent(component)
     *    - Large chunk of mainline code was moved to several
     *      procedures.  This was done to accomondate the
     *      enchancement of allowing multiple parents for a repack itm
     *
700a *  09/02/15  RTR  7.00a
     *    - Fix: added IPQREC update for missing error types.
700b *  07/02/16  RTR  7.00b
     *    - Fix: add savety check for NECS entree host to not process
     *      positive MV adjustments.
700c *  01/04/17  RTR  7.00c
     *    - Fix: Added employee number to DRI call, was causing LICLOG
     *      records to not show user.
     *
710a *  11/01/17  RTR  7.10a
     *    - Enh: Adding OPTIONINT option to create XDK when no other
     *      slots found. Also added option for debug logging in BFCLOG.
710bA*  06/03/13  MLB  7.10b  was 6.50c in HQ245.
     *    - Fix: Revised program to save item type into wkItType. Item
     *      Type for repack item was being lost when parent item info
     *      was retrieved.
710cA*  09/06/13  KDE  7.10c  was 6.50d in HQ245.
     *    - Fix: Revised program to run Repack routines when Alias Item
     *      calls a Repack Item
710dA*  12/01/17  MLB  7.10d  was 6.50b in HQ245.
     *    - Fix: Added mods missed from 6.50b in HQ245.
720a *  07/25/18  RTR  7.20a
     *    - Fix: Set whse before getting *HOST option.
720b *  09/24/18  KDE  7.20b
     *    - Enh: Changed to allow inbound only to process on-demand
     *      as is processed duing outbound processing
     *      Performed at Merit Foods first
720c *  10/28/18  RTR  7.20c
     *    - Enh: Skip picks for non-stock items.
720d *  10/29/18  RTR  7.20d
     *    - Fix: Wasn't clearing wkCrtXDKErr, so XDK only created on
     *      first attempt. Subsequent items errored.
720e *  11/30/18  KDE  7.20e
     *    - Fix: In new Ondemand code make sure any ondemand repacks
     *      have a virtual pick slot to prevent them falling through
     *      and having XDK slots generated instead
730a *  01/28/19  RTR  7.30a
     *    - Enh: Check if order previously posted invoice or TruckBuilder
     *      order.
730b *  02/02/19  RTR  7.30b
     *    - Enh: Adding GMM mod to create virtual pick from HQ245.
730c *  03/02/19  KDE  7.30c
     *    - Enh: Add Batch id to sql select when creating ODR records
730d *  10/14/19  RTR  7.30d
     *    - Fix: Fix breakdown 2 save value.
     *
740a *  08/31/20  RTR  7.40a
     *    - Enh: Changed STGBATCH text message to include counts.
740b *  09/14/20  RTR  7.40b
     *    - Enh: Pass customer order number through for ADJUSTORD.
     *
750 A*  03/29/21  MLB  7.50
     *    - Fix: Revised 7.40b mod to correct start position of extract
     *      of customer order/invoice number. Was causing RNX0105 - Char-
     *      acter representation of decimal value is in error.
     *      Found at Sunrise after Dakota v7.40 upgrade.
750a *  03/09/21  RTR  7.50a
     *    - Fix: For 740b, handle if not numeric.
750b *  12/17/21  RH   7.50b
     *    - add missed 720c mod for Earls 10/14/18  RTR  7.20c
     *      - Changed to call V2 for decimal qty hosts.
760  *    09/02/22  KDE  7.60
     *      - Enh:  Add call to interface error reporting in Report
     *        Scheduler when import has a failure or error
760a *    01/08/23  KDE  7.60d
     *      - Enh:  Change interface error report to R42600.  Also
     *        Add extended message for complete Stage Batch
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*  05/30/10  MLB  CSP
     *    - Revised program to ignore value sent in ipqdsp. The pgm
     *      will search for pick slot(s) and if none found, look for
     *      overflow slots.
CSPaA*  09/09/10  MLB  CSPa
     *    - Revised program to load the JIT repack item into the
     *      memo field when call the DRISLOT interface to post the
     *      adjustment. Done to make tracking back on adjustments
     *      easier.
CSPbA*  03/02/11  MLB  CSPb
     *    - Revised program to pass item designation to GETPSLTMV
     *      so that slots with XD status can be retrieved for
     *      adjustment. This is being done so that JIT cross dock
     *      items can be correctly adjusted until fuly live on TB.
CSPcA*  05/11/11  MLB  CSPc
     *    - Revised program to disable mod CSP done on 05/30/10
     *      per Rich K.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*  01/20/13  MLB  HKW
     *    - Revised program to make 2nd attempt to adjust an item if
     *      the call to GETPSLTMV returns with no slots found for item.
HKWaA*  01/21/13  MLB  HKWa
     *    - Revised program to not change the sign on the qty when the
     *      adjustment code = TR. TR codes are for repack adjustments.
HKWbA*  01/28/13  MLB  HKWb
     *    - Revised mod HKW to create Cross Dock slot, XDK-nnn-1 if
     *      program is unable to find an existing XDK slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WILa *  09/25/14  RTR  WILa
     *    - Added Will Foods to HKW, HKWa, HKWb mods to check other slots
     *      and create XDK if no slot found.
WILb *  09/01/15  RTR  WILb
     *    - Added Will Foods to HKW, HKWa, HKWb mods to check other slots
     *      and create XDK if no slot found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *  07/18/14  RTR  JSLa
     *    - Added Julius Silvert to HKW, HKWa, HKWb mods to check other slots
     *      and create XDK if no slot found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *  08/29/16  RTR  FGLa
     *    - Added Foods Galore to HKW, JSL mods to check other slots
     *      and create XDK if no slot found.
FGLb *  01/09/16  RTR  FGLb
     *    - Added Foods Galore to routine to check for existing order
     *      but checking for previous MV in ITEMADJ.
FGLc *  06/28/17  RTR  FGLc
     *    - Change to first check for existing XDK slot, if found use it.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FBYa *  01/02/17  RTR  FBYa
     *    - Added Farm Boy to HKW, JSL mods to check other slots
     *      and create XDK if no slot found.
     *    - Skip when dept <> 3, *** temp until fully live.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SPIa *  08/28/17  RTR  SPIa
     *    - Changed to create PA adjustments for repack items for Thyme.
SPIb *  10/31/17  RTR  SPIb
     *    - Added SternProduce to GLPe mods to create XDK slot if no other
     *      slots found.
SPIc *  01/30/18  RTR  SPIc
     *    - Change slot lookup order: mods to create XDK slot if no other
     *      slots found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SFPa *  02/26/18  RTR  SFPa
     *    - Added SFP to SPI mods.
SFPb *  02/27/18  RTR  SFPb
     *    - Create virtual pick slot for 99-99-A if slot not found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: T & T Produce
     *
TNTa *  02/06/18  RTR  TNTa
     *    - Change slot lookup order: mods to create XDK slot if no other
     *      slots found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Frech Cuts
     *
FRCa *  11/29/18  MR   FRCa
     *    - Run process for adjustment code 'LN' before main process
     *      runs.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's
     *
KFSa *  02/02/19  RTR  KFSa
     *    - Changed to create 99-999-1 if no pick slot found.
KFSbA*  03/02/19  MLB  KFSb
     *    - Revised pgm to bypass any items where IPQWHD = CHK or
     *      ITWHDP = CHK. Per Roxanne H. CHK dept not active on BFC.
KFScA*  06/08/19  MLB  KFSc
     *    - Revised pgm to add temporary mod to check for slot 99999
     *      and replace it with 99-999-1. Was causing pgm to loop
     *      since pick slot did not exist.
KFSdA*  06/10/19  MLB  KFSd
     *    - Revised pgm to add flag, KFSONETRY to routine PRLOCATESLOT.
     *      Needed to prevent routine from looping when problems creating
     *      default slot, 99-999-1.
KFSeA*  04/07/22  RH   KFSe
     *    - Reverse KFSb, no not bypass items where IPQWHD = CHK or
     *      ITWHDP = CHK. CHK dept is live on BFC.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *  11/05/18  RTR  CFIa
     *    - Added Colony to CSP mod to ignore slot sent from host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLD A*  01/12/22  MLB  CLD
     *    - Revised pgm to change sign on 'CM' Cut Meat adjustments so
     *      that the qty sent from Eagle can be plussed into inventory.
     *      This will allow City Line to better track inventory of cut
     *      meat items in the warehouse instead of treating slots as
     *      black holes with negative on-hand qty's.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

640aDf*mpfpckq  if   e           k disk
720bD**fimpspckq  uf   e           k disk
720bMfimpspckq  uf a e           k disk    usropn
530hAfkitcomp   if   e           k disk
650bAfkititem   if   e           k disk
     fpiritem   if   e           k disk
     fpiritem3  if   e           k disk    rename(itrec:itrec3)
     f                                     prefix(i3)
     fitemlnk   if   e           k disk
     fslot2     if   e           k disk    rename(slrec:slrec2)
520aAfslot4     if   e           k disk    rename(slrec:slrec4)
720eAfvslot1    if   e           k disk    rename(vsrec:vsrec2)
720eAf                                     prefix(v_)
520dAfvslot2    if   e           k disk
     fpckqadj   uf a e           k disk
SPIaAfitemadj   uf a e           k disk
700bAFoptions   if   e           k disk
     fhq245pr   o    e             printer oflind(*in90)
640cAF                                     usropn
530eA
530eA*----------------------------------------------------------------
530eA*  Customer id
530eA*----------------------------------------------------------------
530eA
CSP A /copy qcopysrc,id#coastal
HKW A /copy qcopysrc,id#hkw
WILaA /copy qcopysrc,id#wil
JSLaA /copy qcopysrc,id#jsl
FGLaA /copy qcopysrc,id#fgl
FBYaA /copy qcopysrc,id#fby
FRCaA /copy qcopysrc,id#frc
FRCaA /copy qcopysrc,id#gfk
SPIaA /copy qcopysrc,id#spi
SFPaA /copy qcopysrc,id#sfp
CFIaA /copy qcopysrc,id#cfi
TNTaA /copy qcopysrc,id#tnt
KFSaA /copy qcopysrc,id#kfs
EOPaA /copy qcopysrc,id#eop
CLD A /copy qcopysrc,id#citylin

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     d prAvailSlot     pr

730bAd prCrtSlot       pr             8
730bA
HKWbAd prCrtXDK        pr             8
HKWbA
SFPbAd prCrtVirt       pr             8
SFPbA
     d prFil$Adj       pr

     d prGetDktItm     pr             8

     d prGetSlot       pr

     d prGetSl2        pr

     d prGetWhse       pr             8

     d prLocateSlot    pr

     d prLodAdjHst     pr

     d prNonRepack     pr

     d prPrtItmErr     pr

     d prRepackItem    pr

WILbAd prRtvOrdNbr     pr

     d prVfyAdjCde     pr             8

     d prVfyAdjQty     pr             8

     d prZzGetIl       pr

     d prZzInz2        pr

     d prZzUpd         pr

     d prZzzDriCop     pr

     d prSPIPackout    pr

SPIaAD getRecId        pr                  extpgm('GETRECID')
SPIaAD  pWhse                         3s 0 const
SPIaAD  pFile                        10    const
SPIaAD  pRecId                       11p 0

720cAd hq245s2         pr                  extpgm('HQ245S2')
720cAd  pWhsa                         3a   const
720cAd  pBat                         11a   const
720cAd  pTyp                         10a   const
720cAd  pRet                         10a   const
720cAd  pMess                       200a   const

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     d a10             s              1    dim(10)
530hDd*desc            s             40    dim(10) ctdata perrcd(1)
530hMd desc            s             40    dim(11) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT

     d savever#        s                   like($slver#)
     d slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     d slphy1          s                   like(slstk1)
     d slphy2          s                   like(slstk2)
     d slphy3          s                   like(slstk3)
     d slavl1          s                   like(slstk1)
     d slavl2          s                   like(slstk2)
     d slavl3          s                   like(slstk3)
     d sladj1          s                   like(slstk1)
     d sladj2          s                   like(slstk2)
     d sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     d $vcommand       s              8
     d $vdesc          s             30
     d $vmessage       s             60
     d $vmsgk          s              4
     d $vprg           s             10
     d $vreturn        s             10
     d $vwhdp          s                   like($slwhdp)
     d $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

SPIaAd aliasflag       s               n
     d avail1          s              5  0 inz
     d avail2          s              3  0 inz
     d avail3          s              3  0 inz
720eAd baseODRSlot     s                   like(kidisp)
FGLbAd checkmemo       s             30a   inz
FGLbAd checkorder      s             30a   inz
WILbAd checkrte        s              7  0 inz
720bAd chkstk1         s                   like(slstk1)
720bAd Newqtyn         s              5  0
720bAd Newqty1         s              5  0
720bAd Newqty2         s              5  0
720bAd numToProduce    s              4  0
     d client          s             10    inz
FGLbAd custmemo        s             30a   inz
WILbAd custorder       s              7  0 inz
710aAd DebugFlag       s               n   inz('0')
720bDd*error           s               n
720bDd*forever         s              1    inz('1')
     d hmsmdy          s             12  0 inz
700bAD host            s             20a
640aAD importError     s               n
700aAD ipqupdated      s               n
KFCdAd kfsonetry       s              4    inz('*NO ')
710aAD NoSlotXDK       s               n   inz('0')
530hAD odritemflag     s               n   inz('0')
WILbAd orderfound      s              4    inz('*NO ')
     d rdate           s              6  0 inz
SPIaAD recidnum        s             11p 0
530cAd remAdjQty       s              7  0 inz
     d rtime           s              6  0 inz
640aAD savdsp          s                   like(ipqdsp)
640aAD savwhd          s                   like(ipqwhd)
640aAD savqp1          s                   like(ipqqp1)
640aAD savqp2          s                   like(ipqqp2)
640aAD savqp3          s                   like(ipqqp3)
640aAD stamp           s               z
640aAD stampUC         s               z
     d stock1          s              5  0 inz
     d stock2          s              3  0 inz
     d stock3          s              3  0 inz
     d svittype        s              1    inz
530cAd totAdjQty       s              7  0 inz
SFPbAd virtflag        s              4    inz('*NO ')
740aAd totread         s              7  0 inz
740aAd toterror        s              7  0 inz
720bAd useAdjust       s               n
     d woDesc          s             55    inz
     d woWhse          s             55    inz
     d w1Code          s              2    inz
     d w1Cwtr          s              9  2 inz
     d w1Memo          s             30    inz
     *
     d wkAdjErr        s              8    inz
730bAd wkCrtSltErr     s              8    inz
HKWbAd wkCrtXDKErr     s              8    inz
SFPbAd wkCrtVirtErr    s              8    inz
     d wkErDesc        s             40    inz
     d wkError         s               n
     d wkItmErr        s              8    inz
     d wkItType        s              1    inz
     d wkKeyItm        s             15    inz
     d wkLstSlt        s              4    inz('*NO ')
     d wkPrcErr        s              8    inz
     d wkPrtFlg        s               n
     d wkQtyAdj        s              7  0 inz
530cAd wkQtyAdj2       s              7  0 inz
530cAd wkQtyAdj3       s              7  0 inz
     d wkQtyErr        s              8    inz
     d wkQty1          s                   like($saqty1)
     d wkQty2          s                   like($saqty2)
     d wkQty3          s                   like($saqty3)
     d wkSavCmd        s                   like($gcmd)
     d wkSavItm        s             15    inz
     d wkSavSlt        s                   like($sldisp)
     d wkSndBfc        s              4    inz('*NO ')
     d wkTimStp        s               z   inz
     d wkTtlQty        s              7  0 inz
     d wkWhse          s              3  0 inz
     d wkWhsErr        s              8    inz
HKW Ad xdkflag         s              4    inz('*NO ')

     d $ccmd           s              8    inz
     d $cstr           s             30    inz
     d $gaisl          s              3    inz
     d $gcmd           s              8    inz
CSPbAd $gdesg          s              5    inz
     d $ghand          s              2    inz
     d $gitem          s             15    inz
     d $gloc           s              3  0 inz
     d $grlvl          s              2  0 inz
     d $grtn           s              8    inz
     d $gslot          s             12    inz
     d $gwhdp          s              5    inz
     d $gwhse          s              3  0 inz

760 AD currReport      s             20
760 AD url             s           3000
760 AD schEmail        s           1000
760 AD orient          s              1
760 AD grDev           s             10
760 Ad sbmusr          s             10
760 Ad sbmjobd         s             10
760 Ad sbmlibl         s             10
760 AD cmd             s           3000    varying
760 AD opmusr          s             10
760 Ad opjobd          s             10

760 A*----------------------------------------------------------------
760 A*  Sub-procedure prototypes
760 A*----------------------------------------------------------------

760 Ad getSchTimeEml   pr
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     d cstItmErr       c                   '#itError'
     d cstAdjErr       c                   '#adError'
     d cstQtyErr       c                   '#qtError'
     d cstWhsErr       c                   '#whError'

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     d
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     *
     *   Redefine key
     *
640aDd**$pwhse                19     21  0
     d  $pwhdp                22     26
     d  $pdisp                27     38
     d  $puser                39     48

     *----------------------------------------------------------------
     *  Redefinition data structures
     *----------------------------------------------------------------

     d $aerm           ds
     d  xaerm                  1     60
     d  $amsg                  1      4
     *
     d $cerm           ds
     d  xcerm                  1     60
     d  $cmsg                  1      4

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------

     d @cvtdt          c                   const('CVTDTE')
     d @fmtit          c                   const('FRMTIT')
530hAD @getit          c                   const('GETITEMFLD')

     *----------------------------------------------------------------
     *  Called Program Parameters
     *----------------------------------------------------------------
      /copy *libl/qcopysrc,p.getopint
      /copy *libl/qcopysrc,p.wrtlog
760aAd/copy qcopysrc,p.wIntLog

     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     *
     *   Redefine key
     *
     d  $lcode                19     20
     *
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     d $mdt            ds
     d  errmsg                 1     50
     *
     d  eritem                 1     15
     *
     d  eridsg                 1      5
     d  ersdsg                 6     10

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

640aA /copy qcopysrc,c#pgminfds
640aDd*               sds
640aDd* #prog            *proc
640aDd* #job                 244    253
640aDd* #user                254    263
640aDd* #jobn                264    269
640aDd* #jobdt               276    281  0
640aDd* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
720bA /copy qcopysrc,c#stdvar
640aA /copy qcopysrc,c#stdsql
760 AD/copy qcopysrc,p.mrcrptsc
760 AD/copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Externally Defined Data Structure
     *----------------------------------------------------------------

     d  dsWrkItm     e ds                  extname(piritem) prefix(ds)
     d  dsPirItm     e ds                  extname(piritem)
640aAD  sbrec        e ds                  extname(stgbatch) inz(*EXTDFT)

720bA*----------------------------------------------------------------
720bA*  Data Structure for ODR Repack Items sent from Customer
720bA*----------------------------------------------------------------
720bA
720bAd odRpk           ds           100
720bAd   odwhse                       3  0 overlay(odrpk)
720bAd   odritm                      15    overlay(odrpk:*next)
720bAd   odpitm                      15    overlay(odrpk:*next)
720bAd   odrdis                      12    overlay(odrpk:*next)
720bAd   odpdis                      12    overlay(odrpk:*next)
720bAd   odbdis                      12    overlay(odrpk:*next)
720bAd   odoutq                       3  0 overlay(odrpk:*next)
720bAd   odpqtn                       5  0 overlay(odrpk:*next)
720bAd   odpqt1                       3  0 overlay(odrpk:*next)
720bAd   odpqt2                       3  0 overlay(odrpk:*next)
720bAd   odpck1                       5  0 overlay(odrpk:*next)
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pType          s             10
640aAD $pReturn        s             10
640aAD $pMessage       s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
640aA*      $pType  - Batch type
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pType
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *  Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
FRCaA*
FRCaA*  Process LIN slot adjustment records for Fresh Cuts
FRCaA*
FRCaAc                   if        client = FreshCuts
FRCaAc                             or client = GFKKitchen
FRCaAc                   call      'HQ245P'
FRCaAc                   parm                    $pWhse3A
FRCaAc                   parm                    $pBatId
FRCaAc                   parm                    $pType
FRCaAc                   parm                    $pReturn
FRCaAc                   parm                    $pMessage
FRCaAc                   endif
720bA*
720bA*  Generate ondemand ajdustment records to keep
720bA*  things balanced
720bA*
720bAc                   exsr      crtODRRecords
720bAc                   open      impspckq
640aA*
640aA* Whip through import records
640aA*
640aDc**   *loval        setll     impfPckq
640aMc     keyipq        setll     impsPckq
640aMc                   dou       %eof(impsPckq)
640aDc**                 read      impfPckq
640aMc     keyipq        reade     impsPckq
     *
740aAc                   eval      totread = totread + 1
720bAc                   if        %subst(ipqmem:1:3)='R1X'
720bAc                   eval      useAdjust=*on
720bAc                   eval      ipqmem=%subst(ipqmem:5:25)
720bAc                   else
720bAc                   eval      useAdjust=*off
720bAc                   endif
700aAc                   eval      ipqupdated = *off
640aDc**                 if        not %eof(impsPckq)
640aMc                   if        %eof(impsPckq)
640aAc                   leave
640aAc                   endif
     *
     c                   if        ipqstatus <> 'R'
     c                   iter
     c                   endif
KFSbA*
KFSeA*      Code commented out, reverse KFSb mod.
KFSbMc*                  if        client = Kellys
KFSbMC*                            and ipqwhd = 'CHK'
KFSbMC*                  eval      ipqstatus = 'S'
KFSbMc*                  eval      ipqtext = 'Dept CHK not Active. Bypass'
KFSbMc*                  exsr      updateIPQREC
KFSbMc*                  iter
KFSbMC*                  endif
KFScA*
KFScA*      Temp mod to check for invalid slot.
KFScAc                   if        client = Kellys
KFScAC                             and ipqdsp = '99999'
KFScAC                   eval      ipqdsp = '99-999-1'
KFScAC                   endif
     *
FBYaAC                   eval      ipqtext = ' '
640aAc                   eval      savdsp = ipqdsp
640aAc                   eval      savwhd = ipqwhd
640aAc                   eval      savqp1 = ipqqp1
730dDc***                eval      savqp2 = ipqqp3
730dDc***                eval      savqp2 = ipqqp3
730dMc                   eval      savqp2 = ipqqp2
730dMc                   eval      savqp3 = ipqqp3
WILaAC                   eval      xdkflag = '*NO'
SFPbAC                   eval      virtflag = '*NO'
     *
     c                   if        ipqWhs <> wkWhse
     c                   callp     prZzInz2
     *
     ** Get BFC Warehouse Desc
     *
     c                   eval      wkWhsErr = prGetWhse()
     *
     c                   eval      wkWhse = ipqWhs
     c                   endif
     *
     ** Check for previously posted invoice
     *
WILbAC                   eval      orderfound = '*NO '
WILbAC                   select
WILbAC                   when      client = willfoods
FGLbAC                             or client = FoodsGalore
730aAC                             or checkOrder = *on
WILbAC                   callp     prRtvOrdNbr
WILbAC                   if        orderfound = '*YES'
WILbAC                   eval      ipqmem = %replace('*S':ipqmem:29)
WILbAC                   endif
WILbAC                   endsl
     *
     ** Write import record to history file.
     *
     c                   callp     prLodAdjHst
650 A*
650 AC                   if            ipqqp1 = 0
650 AC                             and ipqqp2 = 0
650 AC                             and ipqqp3 = 0
650 A*      Bypass processing items with no qty to adjust.
700aAC                   eval      ipqstatus = 'S'
700aAc                   eval      ipqtext = 'Skipped - No picked quantity'
700aAc                   exsr      updateIPQREC
650 AC                   iter
650 AC                   endif

730aDC**                 select
730aDC**                 when      client = willfoods
WILbAC                   if        orderfound = '*YES'
WILbAC                   eval      ipqstatus = 'S'
WILbAc                   eval      ipqtext = 'Skipped - Order on picked route'
WILbAc                   exsr      updateIPQREC
WILbAC                   iter
WILbAC                   endif
CLD A*
CLD A*------------------------------------------------------------------
CLD AC                   select
CLD AC                   when      client = CityLine
CLD A*
CLD A*      Cut Meat adj sent from Host. Flip sign so qty will be added in.
CLD AC                   if        ipqadj = 'CM'
CLD AC                   if        ipqqp1 > 0
CLD AC                   eval      ipqqp1 = ipqqp1 * -1
CLD AC                   endif
CLD A*
CLD AC                   if        ipqqp2 > 0
CLD AC                   eval      ipqqp2 = ipqqp2 * -1
CLD AC                   endif
CLD A*
CLD AC                   if        ipqqp3 > 0
CLD AC                   eval      ipqqp3 = ipqqp3 * -1
CLD AC                   endif
CLD A*
CLD AC                   endif
CLD A*
CLD AC                   endsl
CLD A*
730aDC**                 endsl
     *
700bA /free
700bA   // If NECS entree sends a return invoice, skip it.
700bA   if host = 'NECS-ENTREE'
700bA    and ipqadj = 'MV'
700bA    and ipqqp1 < 0;
700bA     ipqstatus = 'S';
700bA     ipqtext = 'Skipped - Returned item';
700bA     exsr updateIPQREC;
700bA     iter;
700bA   endif;
700bA /end-free
     *
     ** Get Dakota Item Master
     *
     c                   eval      wkKeyItm = ipqItm
     *
     c                   eval      wkSavItm = *blanks
     *
     c                   eval      wkItmErr = prGetDktItm()

720cA /free
720cA   // Skip pick if non-stock item.
720cA   if itdesg = 'NSTK*';
720cA     ipqstatus = 'S';
720cA     ipqtext = 'Skipped - Non-Stock Item';
720cA     exsr updateIPQREC;
720cA     iter;
720cA   endif;
720cA /end-free

KFSeA*      Code commented out, reverse KFSb mod.
KFSbA //free
KFSbA   // Skip pick if dept-CHK item.
KFSbA //  if     client = Kellys
KFSbA //     and itwhdp = 'CHK';
KFSbA //    ipqstatus = 'S';
KFSbA //    ipqtext = 'Dept CHK not Active. Bypass';
KFSbA //    exsr updateIPQREC;
KFSbA //    iter;
KFSbA //  endif;
KFSbA //end-free

FBYaAC
FBYaAC***                select
FBYaAC*                  when      client = FarmBoy
FBYaAC*                            and itwhdp = '1'
FBYaAC*                  eval      ipqstatus = 'S'
FBYaAc*                  eval      ipqtext = 'Skipped - Freezer Item'
FBYaAc*                  exsr      updateIPQREC
FBYaAC*                  iter
FBYaAC*                  other
FBYaAC***                endsl
FBYaAC
SPIaA /free
SPIaA    select;
SPIaA      when ittype = 'A';
SPIaA        aliasflag = *on;
SPIaA      other;
SPIaA        aliasflag = *off;
SPIaA    endsl;
SPIaA /end-free
     *
     ** Verify Adjustment Code
     *
     c                   eval      wkAdjErr = prVfyAdjCde()
     *
     ** Verify Adjustment Qtys
     *
     c                   eval      wkQtyErr = prVfyAdjQty()
     *
     c                   if        wkError = *on
     c                   callp     prPrtItmErr
     c                   eval      wkError = *off
     c                   eval      wkPrtFlg = *on
640aAc                   exsr      updateIPQREC
     c                   iter
     c                   endIf
     *
     ** Save SSB Item Number & Type.
     *
     c                   eval      wkItType = *blank
     *
     c                   if        dsItType = 'S'
710bAc                             or dsItType = 'R'
     c                   eval      wkItType = dsItType
     c                   endif
     *
     ** Get Alias Item Base item.
     ** Get SSB Item Base item.
530hA** Get Repack Item Base item.
     *
     c                   if        dsItType = 'A'
     c                               or dsItType = 'S'
710dDc*                              or dsItType = 'R'
     c                   callp     prZzGetIl
     *
     c                   if        wkError = *on
     c                   eval      wkErDesc = desc(2)
     c                   callp     prPrtItmErr
640aAc                   exsr      updateIPQREC
     c                   iter
     c                   endif
     *
     ** Load base item instead.
     *
530 A*      Only load Base item for Alias items.
530 Ac                   if        dsItType = 'A'
     c                   eval      wkKeyItm = *blanks
     c                   eval      wkKeyItm = %TRIM(ilitm2)
530 Ac                   endif
     c                   endif
     *
     ** If Alias item, get type for base item.
     *
     c                   if        dsItType = 'A'
     c     keyit3        chain     pirItem3
     c                   if        not %found(pirItem3)
     c                   eval      i3ItType = *blanks
     c                   endif
     *
     ** If base item for Alias is SSB, get Base item for SSB.
     *
     c                   if        i3ItType = 'S'
530aDc*                  eval      wkSavItm = wkKeyItm
     c     keyil3        chain     itemLnk
     c                   if        not %found(itemLnk)
     c                   clear                   ilitm2
     c                   clear                   ilitm3
     c                   endif
530aDc*                  move      ilitm2        wkKeyItm
     c                   endif
     *
     c                   endif
530hA*
650bA*  There was a block of code in this area move to procedure
710dM*    prRepackItem.  Copy was placed in ENH650 HQ245.v640
650bA*    The select below goes to the procedure for R type and
650bA*    continues with previous code for other types
     *
     ** Get Pick Slot For Item.
     *
     c                   eval      $gcmd  = '*FIRST  '
     c                   eval      $gwhse = $pwhse
720dAc                   eval      wkCrtXDKErr = *blanks

650bAc                   select
     *
650bAc                   when      dsItType = 'R'
710cAc                             or (i3ItType = 'R'
710cAc                               and dsItType='A')
650bAc                   callp     prRepackItem
650aAc                   if        wkError = *on
640aAc                   exsr      updateIPQREC
650aAc                   iter
650aAc                   endif

650bAc                   when      dsItType <> 'R'
530aA*
530aA*      In order to find pick slot, need base item#.
530aAC                   if           dsItType = 'A'
530aAC                             or dsItType = 'S'
530hA*
530aAC                   eval      $gitem = ilitm2
530aAC                   else
     c                   eval      $gitem = wkKeyItm
530aAC                   endif
     c                   eval      $gslot = *blanks
     *
     ** Process Slot Recvd in Import File
     *
KFSaAc                   if        client = Kellys
KFSaAC                             and ipqadj = 'MV'
KFSaAC                   eval      ipqdsp = *blanks
KFSaAC                   eval      ipqsof = 'N'
KFSaAC                   endif

     c                   if        ipqDsp <> *blanks
CSPcDc*                            and client <> CoastalSunbelt
CFIaAc                             and client <> Colony
     *
     * Setup Valid Department
     *
     c                   if        ipqWhd = *blanks
     c                   eval      ipqWhd = dsItWhDp
     c                   endIf
520aA*
520aA* Verify that dept/slot sent contains item.
520aAC     keysl4        setll     slot4
520aAC                   if        not %equal(slot4)
520aA*
520aA* Item not found in base slot. Check virtual slots for item.
520dAC     keyvs2        setll     vslot2
520dAC                   dow       forever = forever
520dAC     keyvs2        reade     vslot2
520dAC                   if        %eof(vslot2)
520dAC                   leave
520dAC                   endif
520dA*
520dAC     keyvs4        setll     slot4
520dA*      Virtual slot found. Update import slot field to use.
520dAC                   if        %equal(slot4)
520dAC                   eval      ipqdsp = vsdisp
520dAC                   leave
520dAC                   endif
520dA*
520dAC                   enddo
520dA*  end to slot found in slot4 above using passed in slot
520aAC                   endif
     *
     * Load DRI Interface Fields
     *
520bAc                   eval      wkQty1 = ipqqp1 * -1
520bAc                   eval      wkQty2 = ipqqp2 * -1
520bAc                   eval      wkQty3 = ipqqp3 * -1

     *  write adjustment for transaction

     c                   callp     prZzUpd
     *
     c                   if        wkError = *on
     c                   eval      wkErDesc = desc(10)
     c                   callp     prPrtItmErr
700aAc                   exsr      updateIPQREC
     c                   iter
     c                   endif
     *   else ipqdsp = blanks
     c                   else
     c                   callp     prNonRepack
     *   ipqdsp <> blanks
     c                   endif
     *   when select for either Repack or Not
650bAc                   endsl
SPIaA /free
SPIaA    if (client = SternProduce
SFPaA     or client = Seashore)
SPIaA     and aliasflag;
SPIaA      callp prSPIPackout();
SPIaA    endif;
SPIaA /end-free
640aD **
640aD ** EndIf %eof(impfPckq)
640aD **
640aDc**                 endif

640aAc                   exsr      updateIPQREC
     *
     *  EndDo IMPFPCKQ
     *
     c                   enddo
     *
     * Write Exception Report Total
     *
     c                   if        wktote > 0
     c                   if        *in90 = *on
     c                   write     header
     c                   endif
     c                   write     total
     c                   endif
     * End Program
640aAC                   exsr      zzzEnd

640bA*  Update daily demand if requested.
640bA
640bAC                   if        $pType = 'IMPDEMAND'
640bAC                             or $pType = 'IMPPCKDEM'
640bAC                   call      'IT506S'
640bAC                   parm      $pwhse        $dwhse            3 0
640bAC                   parm      $pbatid       $dbatid          11
640bAC                   parm      '*TODAY'      $dcmd             8
640bAC                   parm      ' '           $drtn             8
640bAC                   parm      ' '           $dmsg             4
640bAC                   endif
     *
640aDc**                 eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr

     * Get client id.

     c                   call      'GETCLIENT'
     c                   parm                    client           10
530eAc                   parm                    clientloc        10
700cA*
700cA*       Retrieve current user number from PIR User table.
700cAC                   call      'GETUSER'
700cAC                   parm                    #user
700cAC                   parm      0             #whse             3 0
700cAC                   parm      0             #emp#             5 0
700cAC                   parm                    #fnam            15
700cAC                   parm                    #init             1
700cAC                   parm                    #lnam            20
700cAC                   parm                    #whdp             5
700cAC                   parm                    #styp             1
700cAC                   parm                    #shft             6
700cAC                   parm                    #crew             6
700cAC                   parm      0             #nhrs             3 1
700cAC                   parm                    #rtn              8
720cA /free
EOPaA   select;
EOPaA    when client = EarlsOrganic;
720cA     callp hq245s2($pWhse3A: $pBatId: $pType:
720cA                   $pReturn: $pMessage);
EOPaA     *inlr = *on;
EOPaA     return;
EOPaA   endsl;
720cA /end-free
700cA*
     c                   eval      *in90 = *on
     c                   time                    wkTimStp
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     *
     c                   eval      $lprg = #prog

     *   Set warehouse defaults.

     c                   eval      w1Cwtr = *zeros
640aDc**                 eval      $pcmd  = '*CHANGE '
640aDc**                 eval      $pwhse = 1
     c                   eval      $pwhdp = '*ALL '
530bA*
530bA* Retrieve current date/time for report printing.
530bAc                   eval      $cvcmd = '*CURMDY '
530bAc                   call      @cvtdt
530bAc                   parm                    $cvtdt
530bAc                   eval      rdate = $cvd6o
530bAc                   time                    rtime
640aA*
640aA* Define partial key fpr IMPSPCKQ
640aA*
640aAc     keyipq        klist
640aAc                   kfld                    $pWhse
640aAc                   kfld                    $pBatId
     *
     * Define full key for SLOT2.
     *
     c     *like         define    slwhdp        kywhdp
     c     *like         define    sldisp        kydisp
     *
     c     keysl2        klist
     c                   kfld                    $pwhse
     c                   kfld                    kywhdp
     c                   kfld                    kydisp
520dA*
520dAc     keyvs2        klist
520dAc                   kfld                    ipqwhs
520dAc                   kfld                    ipqwhd
520dAc                   kfld                    ipqdsp
520aA*
520aA* Define full key for SLOT4.
520aA*
520aAc     keysl4        klist
520aAc                   kfld                    ipqwhs
520aAc                   kfld                    ipqwhd
520aAc                   kfld                    wkkeyitm
520aAc                   kfld                    ipqdsp
520dA*
520dAc     keyvs4        klist
520dAc                   kfld                    ipqwhs
520dAc                   kfld                    ipqwhd
520dAc                   kfld                    wkkeyitm
520dAc                   kfld                    vsdisp
     *
     * ITEMLINK Full file key
     *
     c     keyit         klist
     c                   kfld                    $pwhse
     c                   kfld                    wkKeyItm
530hA*
530hA* KITCOMP  Partial file key
530hA*
530hAc     keykc         klist
530hAc                   kfld                    $pwhse
530hAc                   kfld                    ipqItm
     *
     * Define key for PIRITEM3 file
     *
     c     keyit3        klist
     c                   kfld                    wkKeyItm
     c                   kfld                    itwhse
     *
     * ITEMLINK Full file key
     *
     c     keyil         klist
     c                   kfld                    $pwhse
     c                   kfld                    wkKeyItm
     *
     * ITEMLINK Full file key
     *
     c     keyil3        klist
     c                   kfld                    itwhse
     c                   kfld                    wkKeyItm
700bA*
700bA*   Get import item fields options.
700bA*
700bA /free
720aA   $pWhse = %dec($pWhse3A: 3: 0);
700bA   chain ($pWhse:'*HOST') options;
700bA   if %found(options);
700bA     host = opdata;
700bA   else;
700bA     host = '*NOT FOUND';
700bA   endif;
700bA /end-free
710aA*
710aA*   Get option for debugging.
710aA*
700bA /free
710aA   // Get debug flag
710aA   optint.type = 'Interface   ';
710aA   optint.cat  = 'Import Picked Qty   ';
710aA   optint.name = 'Debug Flag          ';
710aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
710aA             optint.valn: optint.vala: optint.return);
710aA   if optint.return = '*OK'
710aA    and optint.vala = 'Y';
710aA     debugflag = *on;
710aA   else;
710aA     debugflag = *off;
710aA   endif;

710aA   // Log program start
710aA   if debugflag;
710aA     log.pgm = #pgm;
710aA     log.type = 'Start    ';
710aA     log.text = 'Import Host Picked Quantities for: ' + $pBatId;
710aA     WrtLog(log.pgm: log.type: log.text);
710aA   endif;
710aA /end-free

710aA*
710aA*   Get option for creating XDK when no slot found.
710aA*
710aA /free
710aA   // Get No Slot XDK flag
710aA   optint.type = 'Interface   ';
710aA   optint.cat  = 'Import Picked Qty   ';
710aA   optint.name = 'HQ245S No Slot XDK  ';
710aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
710aA             optint.valn: optint.vala: optint.return);
710aA   if optint.return = '*OK'
710aA    and optint.vala = 'Y';
710aA     NoSlotXDK = *on;
710aA   else;
710aA     NoSlotXDK = *off;
710aA   endif;
710aA /end-free

     c                   endsr

720bA*----------------------------------------------------------------
720bA*  crtODRRecords  Create additional ODR records required to
720bA*                 keep everything in balance
720bA*----------------------------------------------------------------
720bA
720bAc     crtODRRecords begsr
720bA /free
720bA       // This routine summarizes quantity invoiced for
720bA       // on-demand Repack Item and generates a record
720bA       // in the IMPSPCKQ (Import Invoicing) file to apply
720bA       // not only the invoicing but also generates records
720bA       // to adjust up the quantity produced for on-demand
720bA       // repack pick slot, as well as reducing the Case
720bA       // "RP" status slot by what would have been consumed.
720bA       // It is the responsibility of the customer to
720bA       // use Dakota Transfer to move product from the warehouse
720bA       // slot(s) to the on-demand Case "RP" slot.
720eA       // First lets loop through the ondemand items in this
720eA       // batch and ensure they have virtual pick slots
720eA       sqlstmt = 'select i.ipqwhs,i.ipqwhd,i.ipqitm,k.kidisp' +
720eA                 ' from impspckq as i' +
720eA                 ' left outer join slot2 as s' +
720eA                 ' on i.ipqwhs=s.slwhse and' +
720eA                 ' i.ipqwhd=s.slwhdp and i.ipqitm=s.slitem' +
720eA                 ' left outer join kititem as k' +
720eA                 ' on i.ipqwhs=k.kiwhse and' +
720eA                 ' i.ipqitm=k.kiitem' +
720eA                 ' where' +
720eA                 ' k.kirptp=' + sq + '2' + sq +
720eA                 ' and s.sldisp is null' +
720eA                 ' and i.ipqstatus=' + sq + 'R' + sq +
730cA                 ' and i.ipqbatid=' + sq + %trim($pBatid) + sq;
720eA       exec sql PREPARE sc FROM :SqlStmt;
720eA       exec sql DECLARE scRpk SCROLL CURSOR FOR sc;
720eA       exec sql OPEN scRpk;
720eA       exec sql fetch first from scRpk into :ipqwhs,:ipqwhd,
720eA                                            :ipqitm,:kidisp;
720eA
720eA       dow sqlStt=sqlSuccess;
720eA          baseODRSlot = kidisp;
720eA          chain (ipqwhs:ipqitm) piritem;
720eA          // when found see if virtual or base
720eA          chain (ipqwhs:itwhdp:kidisp) vslot1;
720eA          if %found(vslot1);
720eA             baseODRSlot = v_vspdis;
720eA          endif;
720eA          savever# = $slver#;
720eA          $slver# = savever#;
720eA          clear $slot;
720eA          clear $slot2;
720eA          $slwhseu = *on;
720eA          $slwhse  = ipqwhs;
720eA          $slwhdpu = *on;
720eA          $slwhdp  = itwhdp;
720eA          $sldispu = *on;
720eA          $sldisp  = baseODRSlot;
720eA          $slitemu = *on;
720eA          $slitem  = ipqitm;
720eA          $dricommand = '*SLOT';
720eA          $drisubcmd = '%CRTVPICK';
720eA          $drisys2upd = 'D';
720eA          callp prZzzDriCop();
720eA          if $drireturn = 'VRTPCKCRT';
720eA             // make sure repack virtual is stat A
720eA             exec sql update slot2 set slstat='A'
720eA                  where slwhse=:ipqwhs and
720eA                        sldisp=:$sldisp and
720eA                        slwhdp=:itwhdp and
720eA                        slitem=:ipqitm;
720eA          endif;
720eA          exec sql fetch next from scRpk into :ipqwhs,:ipqwhd,
720eA                                              :ipqitm,:kidisp;
720eA       enddo;
720eA
720bA       sqlstmt = 'select ipqwhs,ipqitm,kccitm,kidisp,' +
720bA                 'kcdisp,vspdis,kiqty1,kcqty1,kcqty2,kcqty3,' +
720bA                 'sum(ipqqp1)' +
720bA                 ' from impspckq,kititem,vslot,kitcomp,itemlnk,slot' +
720bA                 ' where ipqwhs=kiwhse and ipqitm=kiitem' +
720bA                 ' and ipqwhs=vswhse' +
720bA                 ' and (kidisp=vsdisp or kidisp=vspdis) and ' +
720bA                 ' vswhse=slwhse and vsdisp=sldisp and vswhdp=slwhdp' +
720bA                 ' and slstat = ' + sq + 'A' + sq +
720bA                 ' and kirptp=' + sq +
720bA                 '2' + sq + ' and ipqwhs=kcwhse and ' +
720bA                 'ipqstatus=' + sq + 'R' + sq + ' and ' +
720bA                 'ipqitm=kcitem and ipqwhs=ilwhse and ' +
730cM                 'ipqitm=ilitem and ilitm2=kccitm' +
730cA                 ' and ipqbatid=' + sq + %trim($pBatid) + sq +
730cM                 ' group by ipqwhs,ipqitm,kccitm,kidisp,' +
720bA                 'kcdisp,vspdis,kiqty1,kcqty1,' +
720bA                 'kcqty2,kcqty3 order by' +
720bA                 ' ipqwhs,ipqitm,kccitm,kidisp,' +
720bA                 'kcdisp,vspdis,kiqty1,kcqty1,kcqty2,kcqty3';
720bA
720bA       open impspckq;
720bA       exsr zzzgetStamps;
720bA       exec sql PREPARE od FROM :SqlStmt;
720bA       exec sql DECLARE odRpk SCROLL CURSOR FOR od;
720bA       exec sql OPEN odRpk;
720bA       exec sql fetch first from odRpk into :odrpk;
720bA
720bA       dow sqlStt=sqlSuccess;
720bA         // check to see if Repack ODR slot has quantity
720bA         // to handle demand sent
720bA         // ensure we are getting correct slot for odr
720bA         exec sql select vsdisp into :odrdis
720bA              from slot2,vslot1
720bA             where slwhse=vswhse and slwhdp=vswhdp and
720bA                   sldisp=vsdisp and vspdis=:odbdis and
720bA                   slitem=:odritm and slpick='Y' and
720bA                   slrsrv='V' and slstat='A';
720bA         chain (odwhse:odritm) piritem;
720bA         chain (odwhse:itwhdp:odrdis) slot2;
720bA         if %found(slot2);
720bA           // since parent odr slot found we should check
720bA           // to see if required quantity exists
720bA           if slstk1 >= odpck1;
720bA              // when slot quantity for ODR Repack covers
720bA              // demand sent we do not need to add other
720bA              // adjustment records.  This one will simply
720bA              // reduce the quantity found in ODR pick slot
720bA           else;
720bA              // when the slot quantity will not cover the
720bA              // sent demand we must determine how short we
720bA              // are and what we must make in ODR Repack
720bA              // slot and what we should show consumed in
720bA              // parent/case RP pick slot
720bA              chkstk1 = slstk1;
720bA              numToProduce = *zeros;
720bA              // Determine how many iterations of the repack
720bA              // configuation must be produced to accomodate
720bA              // quantities invoiced
720bA              dow chkstk1 < odpck1;
720bA                 numToProduce = numToProduce + 1;
720bA                 chkstk1 = chkstk1 + odoutq;
720bA              enddo;
720bA              // if numToProduce is greater than 0 then
720bA              // do what is necessary to generate adjustment
720bA              // for the Repack ODR plus adjustment and the
720bA              // Repack Case RP slot minus adjustment.  Use
720bA              // the respective "R" adjustment codes from Repack
720bA              if numToProduce > *zeros;
720bA                 // first lets generate the plus adjustment to
720bA                 // the ODR Repack Pick Slot
720bA                 ipqwhs=$pwhse;
720bA                 ipqbatid=$pBatid;
720bA                 ipqitm=odritm;
720bA                 ipqstatus='R';
720bA                 ipqststs=stamp;
720bA                 ipqstsuc=stampuc;
720bA                 ipqtext=*blanks;
720bA                 ipqwhd=itwhdp;
720bA                 ipqdsp=odrdis;
720bA                 // odoutq is the output quantity defined in
720bA                 // field KIQTY1 in KITITEM. You can either
720bA                 // say one repack consumes "X" quantity of
720bA                 // parent item, or you can say "X" number of
720bA                 // repacks get generated from one case of parent
720bA                 // by making the quantity negative it is added
720bA                 // by HQ245s
720bA                 ipqqp1=(numToProduce * odoutq)*-1;
720bA                 ipqqp2=*zeros;
720bA                 ipqqp3=*zeros;
720bA                 ipqadj='R1';
720bA                 // when added by hq245s it uses %ADJUST of
720bA                 // ipqmem begins with R1X meaning it come from
720bA                 // this routine
720bA                 ipqmem = 'R1X Rpk Adj ODR';
720bA                 ipqsof='N';
720bA            //   ipqlcns=*blanks;
720bA                 ipqaddts=stamp;
720bA                 ipqadduc=stampuc;
720bA                 write ipqrec;
720bA                 // next lets generate the adjustment to
720bA                 // for the parent "RP" status item for what
720bA                 // was used for these repacks
720bA                 ipqwhs=$pwhse;
720bA                 ipqbatid=$pBatid;
720bA                 ipqitm=odpitm;
720bA                 ipqstatus='R';
720bA                 ipqststs=stamp;
720bA                 ipqstsuc=stampuc;
720bA                 ipqtext=*blanks;
720bA                 chain ($pWhse:odpitm) piritem;
720bA                 ipqwhd=itwhdp;
720bA                 ipqdsp=odpdis;
720bA                 // for this calculation you are only number of
720bA                 // iterations times the kit configuration for
720bA                 // said parent to record usage.  The KIQTY1 is
720bA                 // only considered for the repack quantity
720bA                 // produced, not what was consumed
720bA                 ipqqp1=(numToProduce * odpqtn);
720bA                 ipqqp2=(numToProduce * odpqt1);
720bA                 ipqqp3=(numToProduce * odpqt2);
720bA                 select;
720bA                   when itumq3<>0;
720bA                     newqty2 = ((ipqqp1 * itumq2 * itumq3) +
720bA                                (ipqqp2 * itumq3) +
720bA                                 ipqqp3);
720bA                     newqty1=*zeros;
720bA                   when itumq2<>0;
720bA                     newqty1 = ((ipqqp1 * itumq2) +
720bA                                 ipqqp2);
720bA                     newqty2=*zeros;
720bA                     newqtyn=*zeros;
720bA                   other;
720bA                     newqtyn = ipqqp1;
720bA                     newqty1 = *zeros;
720bA                     newqty2 = *zeros;
720bA                 endsl;
720bA                 exsr zzupQty;
720bA                 ipqqp1 = newqtyn;
720bA                 ipqqp2 = newqty1;
720bA                 ipqqp3 = newqty2;
720bA                 ipqadj='R1';
720bA                 ipqmem = 'Rpk Adj Case';
720bA                 ipqsof='N';
720bA            //   ipqlcns=*blanks;
720bA                 ipqaddts=stamp;
720bA                 ipqadduc=stampuc;
720bA                 write ipqrec;
720bA              endif;
720bA           endif;
720bA         endif;
720bA         exec sql fetch next from odRpk into :odrpk;
720bA       enddo;
720bA       close impspckq;
720bA       exec sql close odRpk;
720bA       // we now return to normal HQ245s process and it will
720bA       // actually process the adjustments just added to
720bA       // IMPSPCKQ to address any on-demand Repack adjustments
      /end-free
720bAc                   endsr


640aA*----------------------------------------------------------------
640aA*  updateIPQREC   Update impspckq record
640aA*----------------------------------------------------------------
640aA
640aAc     updateIPQREC  begsr

     C                   if        ipqstatus = 'E'
740aAc                   eval      toterror = toterror + 1
     C                   eval      importError = *on
     C                   else
     C                   eval      ipqstatus = 'S'
FBYaDC****               eval      ipqtext = ' '
     C                   endif
     C                   exsr      zzzGetStamps
     C                   eval      ipqststs = stamp
     C                   eval      ipqstsuc = stampuc
640aAc                   eval      ipqdsp = savdsp
640aAc                   eval      ipqwhd = savwhd
640aAc                   eval      ipqqp1 = savqp1
640aAc                   eval      ipqqp2 = savqp2
640aAc                   eval      ipqqp3 = savqp3

700aAc                   if        ipqupdated = *off
     C                   update    ipqrec
700aAc                   eval      ipqupdated = *on
700aAc                   endif

     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impspckq file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzend';
          leavesr;
        endif;

        // Log program end
        if debugflag;
          log.pgm = #pgm;
          log.type = 'End      ';
          log.text = $pMessage;
          WrtLog(log.pgm: log.type: log.text);
        endif;

760 A   if importError;
760 A     // if Staging Interface error report is scheduled then submit
760 A     // Use a timestamp as a session id.  MRCRPTSCH will call the
760 A     // update program to update the correct work file to report
760 A     exsr zzErrRpt;
760 A   endif;

      /end-free
     c                   endsr

760 A*----------------------------------------------------------------
760 A*  zzErrRpt   Send Error report for Staging File if scheduled
760 A*----------------------------------------------------------------
760 A
760 Ac     zzErrRpt      begsr
760 A /free
760 A
760 A *   Determine if scheduled, and if so what email to use based
760 A *   on current time compared to scheduled time(s).
760 A *   Loops thru BFCMRCRPRM looking for scheduled events and
760 A *   determining which one is closest to current time, but not
760 A *   after current time.
760aD     //currReport = 'BFCREPORTS.R40700';
760aM     currReport = 'BFCREPORTS.R42600';
760 A     // get the closest scheduled email address to current time.
760 A     // if email is return empty we assume not schedule and
760 A     // nothing is sent
760 A     schEmail=*blanks;
760 A     getSchTimeEml();

          // if email is returned then send out requested error report
          if schEmail <> *blanks;
            orient = 'P';
            grDev=*blanks;
            // Format URL
            // Note: pdf fields are genreated by MRCRPTSCH program
            url = '&OUTFMT=11'
                + '&D_DETAIL=1'
760aD           //+ '&CALCULA001=' + %char(%timestamp())
760aD           //+ '&CALCULA002=' + %char($pWhse)
760aD           //+ '&CALCULA003=' + $pBatid;
760aM           + '&R001=' + %char($pWhse)
760aM           + '&R002=' + $pBatid;

760aA       // Call program to populate Subject and Email Body to
760aA       // file intlog.  These are printed on Email error Report
760aA       // R42600 called below
760aA       wintlog ($pWhse:$pBatid);

            // Call program to print report

            monitor;

760 A         // get iSeries user and jobd from Report Scheduling
760 A         exec sql select opmusr,opjobd into :opmusr,:opjobd
760 A                   from opsmrcrpt
760 A                where opwhse=:$pwhse
760 A               fetch first row only;
760 A         if sqlstt = '00000';
760 A            sbmusr = opmusr;
760 A            sbmjobd = opjobd;
760 A            sbmlibl = '*JOBD';
760 A         else;
760 A            sbmusr = '*CURRENT';
760 A            sbmjobd = '*USRPRF';
760 A            sbmlibl = '*CURRENT';
760 A         endif;
760 A
760 A         cmd = 'sbmjob '
760 A               +   'cmd('
760 A               +      'MRCRPTSCH ' +
760 A                    'WHSE(' + %char($pwhse) + ') '  +
760 A                    'RPTNAM(''' + %trim(currReport) + ''') ' +
760 A                    'URL(''' + %trim(url) + ''') ' +
760 A                    'EMAIL(' + sq + %trim(schEmail) + sq + ') ' +
760 A                    'PRINTER(' + sq + %trim(grdev) + sq + ') ' +
760 A                    'ORIENT(' + sq + %trim(orient) + sq + ')) ' +
760 A               'inllibl(' + %trim(sbmlibl) + ') ' +
760 A               'jobd(' + %trim(sbmjobd) + ') ' +
760 A               'user(' + %trim(sbmusr) + ') ' +
760 A               'jobq(QSYSNOMAX) ' +
760 A               'job(OI285SRSCH)';
760 A         qcmdexc(cmd: %len(cmd));

            on-error;
            endmon;
          endif;
760 A
760 A /end-free
760 Ac                   endsr

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
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr
720bA
720bA *----------------------------------------------------------------
720bA *  ZZUPQTY       Up quantity
720bA *----------------------------------------------------------------
720bA
720bAC     zzupqty       begsr
720bA
720bA /free
720bA       // check for negative quantities
720bA       *in49=*off;
720bA       if newqtyn<0;
720bA          *in49=*on;
720bA          newqtyn = %abs(newqtyn);
720bA       endif;
720bA       if newqty1<0;
720bA          *in49=*on;
720bA          newqty1 = %abs(newqty1);
720bA       endif;
720bA       if newqty2<0;
720bA          *in49=*on;
720bA          newqty2 = %abs(newqty2);
720bA       endif;
720bA /end-free
720bA
720bAC                   dow       itumq3 > 0 and +
720bAC                               newqty2 >= itumq3
720bAC                   eval      newqty2 -= itumq3
720bAC                   eval      newqty1 += 1
720bAC                   enddo
720bA
720bAC                   dow       itumq2 > 0 and +
720bAC                               newqty1 >= itumq2
720bAC                   eval      newqty1 -= itumq2
720bAc                   eval      newqtyn += 1
720bAC                   enddo
720bA
720bA /free
720bA                    if *in49;
720bA                       newqtyn = newqtyn * -1;
720bA                       newqty1 = newqty1 * -1;
720bA                       newqty2 = newqty2 * -1;
720bA                    endif;
720bA /end-free
720bA
720bAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *            Compute Available Qty In From Slot.
     *
     p prAvailSlot     b
     d  prAvailSlot    pi
     *
     c
     c                   call      'SLOTQTY'
     c                   parm                    SLSTK1
     c                   parm                    SLSTK2
     c                   parm                    SLSTK3

     c                   parm                    SLALC1
     c                   parm                    SLALC2
     c                   parm                    SLALC3

     c                   parm                    SLTFR1
     c                   parm                    SLTFR2
     c                   parm                    SLTFR3

     c                   parm                    SLPCK1
     c                   parm                    SLPCK2
     c                   parm                    SLPCK3

     c                   parm                    SLRCV1
     c                   parm                    SLRCV2
     c                   parm                    SLRCV3

     c                   parm                    stock1
     c                   parm                    stock2
     c                   parm                    stock3

     c                   parm                    avail1
     c                   parm                    avail2
     c                   parm                    avail3

     c                   return

     p prAvailSlot     e
HKWbA*
730bA*----------------------------------------------------------------
730bA*
730bA*  prCrtSlot - Creat Virtual Pick slot.
730bAA*
730bAp prCrtSlot       b
730bAd  prCrtSlot      pi             8
730bA*
730bAd wkCrtSlotErr    s              8    inz('*SLOTCRT')
730bA*
730bA*  Use DRI interface to create virtual pick slot.
730bA
730bAC                   eval      savever# = $slver#
730bAC                   clear                   $slot
730bAc                   clear                   $slot2
730bAC                   eval      $slver# = savever#
730bA*
730bAC                   eval      $slwhseu = *on
730bAC                   eval      $slwhse  = pqhwhs
730bAC                   eval      $slwhdpu = *on
730bAC                   eval      $slwhdp  = itwhdp
730bA*
730bAC                   eval      $sldispu = *on
730bAC                   eval      $sldisp = ipqdsp
730bA*
730bAC                   eval      $slitemu = *on
730bAC                   eval      $slitem  = $gitem
730bAC                   eval      $dricommand = '*SLOT'
730bAC                   eval      $drisubcmd = '%CRTVPICK'
730bAC                   eval      $drisys2upd = 'D'
730bAc                   callp     prZzzDriCop
730bAC                   if        wkerror
730bAC                   eval      wkCrtSlotErr = '*SLTCRTER'
730bAC                   endif
730bA*
730bAc                   return    wkCrtSlotErr
730bA*
730bAp prCrtSlot       e
730bA*
HKWbA*----------------------------------------------------------------
HKWbA*
HKWbA*  ZZCrtXDK - Creat XDK slot for item.
HKWbA*
HKWbAp prCrtXDK        b
HKWbAd  prCrtXDK       pi             8
HKWbA*
HKWbAd wkCrtXDKErr     s              8    inz('*XDKCRT')
HKWbA*
HKWbA*  Use DRI interface to create XDK slot.
HKWbA
HKWbAC                   eval      savever# = $slver#
HKWbAC                   clear                   $slot
HKWbAc                   clear                   $slot2
HKWbAC                   eval      $slver# = savever#
HKWbA*
HKWbAC                   eval      $slwhseu = *on
HKWbAC                   eval      $slwhse  = pqhwhs
HKWbA*
HKWbAC                   eval      $slwhdpu = *on
HKWbAC                   eval      $slwhdp  = itwhdp
HKWbA*
HKWbAC                   eval      $slitemu = *on
HKWbAC                   eval      $slitem  = $gitem
HKWbA*
HKWbAC                   eval      $slaislu = *on
HKWbAC                   eval      $slaisl  = 'XDK'
HKWbA*
HKWbAC                   eval      $dricommand = '*SLOT'
HKWbAC                   eval      $drisubcmd = '%CRTXDOCK'
HKWbAC                   eval      $drisys2upd = 'D'
HKWbAc                   callp     prZzzDriCop
HKWbAC                   if        wkerror
HKWbAC                   eval      wkCrtXDKErr = '*XDKCRTER'
HKWbAC                   endif
HKWbA*
HKWbAc                   return    wkCrtXDKErr
HKWbA*
HKWbAp prCrtXDK        e
SFPbA*
SFPbA*----------------------------------------------------------------
SFPbA*
SFPbA*  ZZCrtVirt - Creat Virtual pick slot for item.
SFPbA*
SFPbAp prCrtVirt       b
SFPbAd  prCrtVirt      pi             8
SFPbA*
SFPbAd wkCrtVirtErr    s              8    inz('*VPKCRT')
SFPbA*
SFPbA*  Use DRI interface to create XDK slot.
SFPbA
SFPbAC                   eval      savever# = $slver#
SFPbAC                   clear                   $slot
SFPbAc                   clear                   $slot2
SFPbAC                   eval      $slver# = savever#
SFPbA*
SFPbAC                   eval      $slwhseu = *on
SFPbAC                   eval      $slwhse  = pqhwhs
SFPbA*
SFPbAC                   eval      $slwhdpu = *on
SFPbAC                   eval      $slwhdp  = itwhdp
SFPbA*
SFPbAC                   eval      $slitemu = *on
SFPbAC                   eval      $slitem  = $gitem
SFPbA*
SFPbAC                   eval      $slaislu = *on
SFPbAC                   eval      $slaisl  = ' 99'
SFPbA*
SFPbAC                   eval      $sldispu = *on
SFPbAC                   eval      $sldisp  = '99-99-A'
SFPbA*
SFPbAC                   eval      $dricommand = '*SLOT'
SFPbAC                   eval      $drisubcmd = '%CRTVPICK'
SFPbAC                   eval      $drisys2upd = 'D'
SFPbAc                   callp     prZzzDriCop
SFPbAC                   if        wkerror
SFPbAC                   eval      wkCrtVirtErr = '*VPKCRTER'
SFPbAC                   endif
SFPbA*
SFPbAc                   return    wkCrtVirtErr
SFPbA*
SFPbAp prCrtVirt       e
     *
     *----------------------------------------------------------------
     *
     *  prFil$Adj - Fill $slot data structure fields for adjustment.
     *
     p prFil$Adj       b
     d  prFil$Adj      pi

     *  Initialize data structure

     c                   eval      savever# = $slver#
     c                   clear                   $slot
610aAc                   clear                   $slot2
     c                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     c                   eval      $slwhseu = *on
     c                   eval      $slwhse  = ipqWhs
     c**                 eval      $slwhse  = $pwhse

     c                   eval      $slwhdpu = *on
     c                   eval      $slwhdp  = ipqWhd
     c**                 eval      $slwhdp  = $pwhdp

     c                   eval      $sldispu = *on
     c                   eval      $sldisp  = ipqDsp
     c**                 eval      $sldisp  = $pdisp

     c                   eval      $saitemu = *on
     *
530 D*  Use SSB item when making item adjustment.
530 D*
530 Dc*                  If        svittype = 'S'
530 Dc*                  move      *blanks       $saitem
530 Dc*                  eval      $saitem  = %trim(ipqitm)
530 Dc*                  else
530 D*
530 D*  Use SSB item when making item adjustment for Alias item.
530 D*
530 Dc*                  If        wkSavItm  > ' '
530 Dc*                  eval      $saitem  = wkSavItm
530 Dc*                  else
     c                   eval      $saitem  = wkKeyItm
530 Dc*                  endIf
     *
530 Dc*                  endIf

     c                   eval      $saqtyu  = *on

     c**                 eval      $saqty1  = wkQty1
     c**                 eval      $saqty2  = wkQty2
     c**                 eval      $saqty3  = wkQty3

520bDc*                  eval      $saqty1  = ipqqp1
520bMc                   eval      $saqty1  = wkQty1
520bDc*                  eval      $saqty2  = ipqqp2
520bMc                   eval      $saqty2  = wkQty2
520bDc*                  eval      $saqty3  = ipqqp3
520bMc                   eval      $saqty3  = wkQty3

520aDc*                  eval      $sacwtau = *on
520aMc                   eval      $sacwtau = *off
520aDc*                  eval      $sacwta  = w1cwtr
520aMc                   eval      $sacwta  = 0

     c                   eval      $sacodeu = *on
     c                   eval      $sacode  = ipqAdj
     c**                 eval      $sacode  = w1code

     c                   eval      $samemou = *on
     c                   eval      $samemo  = ipqMem
     c**                 eval      $samemo  = w1memo

     c                   eval      $sabyu   = *on
     c                   eval      $saby    = #user
     c**                 eval      $saby    = $puser
610 AC                   eval      $saActionU = *on
610 AC                   eval      $saAction = 'ADJ'
700cAC                   eval      $saemp#U = *on
700cAC                   eval      $saemp#  = #emp#

740bAc                   eval      $saToOrdU = *on
750aAc                   monitor
750 Dc*                  eval      $saToOrd = %dec(%subst(ipqmem:1:7):7:0)
750 Mc                   eval      $saToOrd = %dec(%subst(ipqmem:10:7):7:0)
750aAc                   on-error
750aAc                   eval      $saToOrdU = *off
750aAc                   endmon

     c                   return

     p prFil$Adj       e
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIT - Get Dakota Item Master Record
     *
     p prGetDktItm     b
     d  prGetDktItm    pi             8
     *
     d prItmErr        s              8    inz('#NoError')
     *
     *   Get Record From Item Master
     *
     c                   eval      wkError = *off
     c     keyIt         chain     pirItem
     c                   if        %found(pirItem)
     c                   eval      dsWrkItm = dsPirItm
     c                   else
     c                   eval      prItmErr = cstItmErr
     c                   eval      wkError = *on
     c                   eval      slDisp = ' '
     c                   endif
     *
     c                   return    prItmErr
     *
     p prGetDktItm     e
     *
     *------------------------------------------------------------------*
     *
     *    Get Pick Slot For Item.
     *
     p prGetSlot       b
     d  prGetSlot      pi
     *
CSPbAC                   if        client = CoastalSunbelt
HKW AC                             or client = Hearnkirkwood
HKW AC                             and xdkflag = '*YES'
WILaAC                             or (client = WillFoods
WILaAC                             and xdkflag = '*YES')
JSLaAC                             or (client = jsilvert
JSLaAC                             and xdkflag = '*YES')
FGLaAC                             or (client = FoodsGalore
FGLaAC                             and xdkflag = '*YES')
FBYaAC                             or (client = FarmBoy
FBYaAC                             and xdkflag = '*YES')
710aAC                             or (NoSlotXDK = *on
710aAC                             and xdkflag = '*YES')
SPIbAC                             or (client = SternProduce
SPIbAC                             and xdkflag = '*YES')
SFPaAC*                            or (client = Seashore
SFPaAC*                            and xdkflag = '*YES')
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
WILaAC                             or client = WillFoods
WILaAC                             or client = jsilvert
WILaAC                             or NoSlotXDK = *on
HKW AC                   eval      $gdesg = 'XDK  '
HKW AC                   other
HKW AC                   eval      $gdesg = itdesg
HKW AC                   endsl
HKW A*
CSPbAc                   call      'GETPSLTMV'
CSPbAc                   parm                    $gcmd
CSPbAc                   parm                    $gwhse
CSPbAc                   parm      *blanks       $gwhdp
CSPbAc                   parm                    $gitem
CSPbAc                   parm                    $gslot
CSPbAc                   parm      *blanks       $gaisl
CSPbAc                   parm      *zeros        $gloc
CSPbAc                   parm      *zeros        $grlvl
CSPbAc                   parm      *blanks       $ghand
CSPbAc                   parm      *blanks       $grtn
HKW Dc*                  parm      itdesg        $gdesg
HKW Mc                   parm                    $gdesg
CSPbAC                   else
CSPbA*
     c                   call      'GETPSLTMV'
     c                   parm                    $gcmd
     c                   parm                    $gwhse
     c                   parm      *blanks       $gwhdp
     c                   parm                    $gitem
     c                   parm                    $gslot
     c                   parm      *blanks       $gaisl
     c                   parm      *zeros        $gloc
     c                   parm      *zeros        $grlvl
     c                   parm      *blanks       $ghand
     c                   parm      *blanks       $grtn
CSPbA*
CSPbAC                   endif
     c
     c                   return
     *
     p prGetSlot       e
     *
     *----------------------------------------------------------------
     *
     *  PRGETSL2 - Get Actual Slot Record For Item.
     *
     p prGetSl2        b
     d  prGetSl2       pi

     c     keysl2        chain     slot2

     c                   return

     p prGetSl2        e
     *
     *----------------------------------------------------------------
     *
     *   Get warehouse description.
     *
     p prGetWhse       b
     d  prGetWhse      pi             8
     *
     d prWhsErr        s              8    inz('#NoError')
     *
     c                   eval      wowhse = *blanks
     c                   eval      $cstr = *blanks
     *
     c                   call(e)   'VFYWHSE'
     c                   parm      '*VERIFY'     $vcommand
     c                   parm      '*NONE'       $vprg
     c                   parm      ipqwhs        $vwhse
     c                   parm      ' '           $vdesc
     c                   parm      ' '           $vreturn
     c                   parm      ' '           $vmessage
     c                   parm      ' '           $vmsgk
     *
     c                   select
     *
     c                   when      %error
     c                   eval      prWhsErr = cstWhsErr
     c                   eval      wkError = *on
     *
     c                   when      $vreturn <> '*OK'
     c                   eval      prWhsErr = cstWhsErr
     c                   eval      wkError = *on
     *
     c                   endsl
     *
     c                   move      $pwhse        $cstr
     *
     * Right / Left Adjust
     *
     c                   call      'ADJUST'
     c                   parm      '*LEFT   '    $ccmd
     c                   parm                    $cstr
     *
     c                   eval      wowhse = %trim($cstr) + '/'
     c                                    + %trim($pwhdp) + ' - '
     c                                    + %trim($vdesc)
     *
     c                   return    prWhsErr
     *
     p prGetWhse       e
     *
     *----------------------------------------------------------------
     *
     *    Locate Slot when one is not passed in with FTP data
     *
     p prLocateSlot    b
     d  prLocateSlot   pi
KFSdAC                   if        client = Kellys
KFSdAC                   eval      KfsOneTry = '*NO '
KFSdAC                   endif
KFSdA*
     ** Create Adjustments for Item without slot passed in FTP import
     *
     *    Set Brkdwn 1 qty for conversion calcs below.
     C                   if        itumq2 <= 0
650aAC                             or ittype = 'S'
     C                   eval      itumq2 = 1
     C                   endif

     *    Set Brkdwn 2 qty for conversion calcs below.
     C                   if        itumq3 <= 0
650aAC                             or ittype = 'S'
     C                   eval      itumq3 = 1
     C                   endif
CSPcD
CSPcD*    Clear slot sent down from Host. Look for slots on Dakota.
CSPcDc*                  if        client = CoastalSunbelt
CSPcDC*                  eval      ipqdsp = ' '
CSPcDC*                  endif
530hA
CSPaA*
CSPaAC                   if        client = CoastalSunBelt
CSPaA*      Save item info from Host in Memo field.
CSPaAC                   eval      ipqmem = %trim(ipqitm) + '/'
CSPaAC                             + %trim(%editc(ipqqp1:'L')) + '/'
CSPaAC                             + %trim(%editc(ipqqp2:'L')) + '/'
CSPaAC                             + %trim(%editc(ipqqp3:'L'))
CSPaAC                   endif
CSPaA*
FGLcAC                   if        client = FoodsGalore
710aAC**                           or NoSlotXDK = *on
SPIcAC                             or client = SternProduce
SFPaAC**                           or client = Seashore
TNTaAC                             or client = TnTProduce
FGLcAC                   eval      xdkflag = '*YES'
FGLcAC                   eval      $gcmd  = '*FRSTOFL'
FGLcAC                   eval      $gdesg = 'XDK  '
FGLcAc                   callp     prGetSlot
FGLcAC                   if        $gslot <> '*NONE*'
FGLcAC                   goto      slotskip
FGLcAC                   else
FGLcAC                   eval      $gcmd  = '*FIRST '
FGLcAC                   eval      $gdesg = *blank
FGLcAC                   endif
FGLcAC                   endif
FGLcA*
     C                   dow       ipqqp1 <> 0
     C                             or ipqqp2 <> 0
     C                             or ipqqp3 <> 0
     *
     c                   callp     prGetSlot
     *
     c                   Select
     *
     *     No pick slot found for item. Look for first overflow slot.
     *
     C                   When          ipqsof = 'Y'
     C                             and ($gslot = '*NONE*  '
     C                             and  $gcmd  = '*FIRST  '
     C                             and  itstyp = 'F')
     C                   eval      $gcmd  = '*FRSTOFL'
     C                   Iter
     *
     ** No pick/overflow slot found for item, print error.
     *
     c                   when      $gslot = '*NONE*  '
SPIbAC                   select
KFSaA *
KFSaAC                   when      client = Kellys
KFSdAC                             and KfsOneTry = '*NO '
KFSdAC                   eval      ipqwhd = dsItWhDp
KFSaAC                   eval      ipqdsp = '99-999-1'
KFSaAC                   eval      wkCrtSltErr = prCrtSlot()
KFSaAC                   eval      $gcmd  = '*FIRST  '
KFSdAC                   eval      KfsOneTry = '*YES'
KFSaAC                   iter
KFSaA *
SPIbAC                   when      client = SternProduce
SPIbAC                             and xdkflag = '*NO '
SPIbAC                   eval      xdkflag = '*YES'
SPIbAC                   iter
SPIbA*
SFPbAC                   when      client = Seashore
SFPbAC                             and virtflag = '*NO '
SFPbAC                   eval      virtflag = '*YES'
SFPbAC                   iter
SPIbA*
SPIbAC                   when      client = SternProduce
SPIbAC                             and xdkflag = '*YES'
SPIbAC                             and wkCrtXDKErr = ' '
SPIbAC                   eval      wkCrtXDKErr = prCrtXDK()
SPIbAC                   if        wkCrtXDKErr = '*XDKCRT'
SPIbA*      Force cmd to First Overflow slot, in case IPQSOF <> 'Y'.
SPIbAC                   eval      $gcmd  = '*FRSTOFL'
SPIbA*      Cross dock slot created, re-try adjustment sent from Host.
SPIbAC                   iter
SPIbAC                   endif

SFPbAC                   when      client = Seashore
SFPbAC                             and virtflag = '*YES'
SFPbAC                             and wkCrtVirtErr = ' '
SFPbAC                   eval      wkCrtVirtErr = prCrtVirt()
SFPbAC                   if        wkCrtVirtErr = '*VPKCRT'
SFPbAC                   eval      $gcmd  = '*FIRST  '
SFPbA*      Virtual pick slot created, re-try adjustment sent from Host.
SFPbAC                   iter
SFPbAC                   endif

SPIbAC                   endsl
SPIbA*
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW AC                             and xdkflag = '*NO '
HKW AC                   eval      xdkflag = '*YES'
HKW AC                   iter
HKWbA*
WILaAC                   when      client = WillFoods
WILaAC                             and xdkflag = '*NO '
WILaAC                   eval      xdkflag = '*YES'
WILaAC                   iter
WILaA*
JSLaAC                   when      client = jsilvert
JSLaAC                             and xdkflag = '*NO '
FGLaAC                             or client = FoodsGalore
FGLaAC                             and xdkflag = '*NO '
FBYaAC                             or client = FarmBoy
FBYaAC                             and xdkflag = '*NO '
710aAC                             or NoSlotXDK = *on
710aAC                             and xdkflag = '*NO '
JSLaAC                   eval      xdkflag = '*YES'
JSLaAC                   iter
WILaA*
WILaDC*                  when          client = Hearnkirkwood
WILaMC                   when      (client = Hearnkirkwood
JSLaAC                               or client = jsilvert
FGLaAC                               or client = FoodsGalore
FBYaAC                               or client = FarmBoy
710aAC                               or NoSlotXDK = *on
WILaAC                               or client = WillFoods)
HKWbAC                             and xdkflag     = '*YES'
HKWbAC                             and wkCrtXDKErr = ' '
HKWbAC                   eval      wkCrtXDKErr = prCrtXDK()
HKWbAC                   if        wkCrtXDKErr = '*XDKCRT'
HKWbA*      Force cmd to First Overflow slot, in case IPQSOF <> 'Y'.
HKWbAC                   eval      $gcmd  = '*FRSTOFL'
700cAC                   eval      wkCrtXDKErr = ' '
HKWbA*      Cross dock slot created, re-try adjustment sent from Host.
HKWbAC                   iter
HKWbAC                   endif
HKW AC                   endsl
HKW A*
     c                   if        $Pcmd = '*OUTCHG'
     c                   eval      $Prtn = '*No Adj'
     c                   leave
     c                   endif
     c                   eval      wkErDesc = desc(3)
     c                   callp     prPrtItmErr
700aAC                   eval      ipqstatus = 'E'
740aAc                   eval      toterror = toterror + 1
700aAC                   eval      importError = *on
700aAc                   eval      ipqtext = desc(3)
700aAc                   if        ipqupdated = *off
700aAC                   update    ipqrec
700aAc                   eval      ipqupdated = *on
700aAc                   endif
     c                   leave
     *
     c                   endsl
     *
     c     slotskip      tag
     *
     ** Active Slot Found. Compute Available Qty.
     *
     c                   if        $gwhdp > ' '
     c                   eval      kyWhdp = $gwhdp
     c                   else
     c                   eval      kyWhdp = dsItWhDp
     c                   endif
     c                   eval      ipqwhd = kyWhdp
     *
     c                   eval      kyDisp = $gslot
     *
     c                   callp     prGetSl2
     *
     ** Slot not found. Shouldn't ever happen, but if it does....
     *
     c                   if        not %found(slot2)
     c                   eval      wkErDesc = desc(3)
     c                   callp     prPrtItmErr
700aAC                   eval      ipqstatus = 'E'
740aAc                   eval      toterror = toterror + 1
700aAC                   eval      importError = *on
700aAc                   eval      ipqtext = desc(3)
700aAc                   if        ipqupdated = *off
700aAC                   update    ipqrec
700aAc                   eval      ipqupdated = *on
700aAc                   endif
     c                   iter
     c                   endif
     *
     ** Check To See If This Is Last Slot Available For Item.
     *
     c                   eval      wkSavCmd  = $gcmd
     c                   eval      wkSavSlt = $gslot
     c                   eval      wkLstSlt = '*NO '
     *
     ** Check For More Available Slots.
     *
     c                   select
     *
     *  Has pick slots, get next available
     *
     c                   when      $gcmd = '*FIRST'
     c                                 or $gcmd = '*NEXT '
     c                   eval      $gcmd = '*MORPICK'
     *
     *  No Pick Slots, Get Next Available Overflow Slot.
     *
     c                   when      $gcmd = '*FRSTOFL'
     c                                 or $gcmd = '*NEXTOFL'
     c                   eval      $gcmd = '*MOROVFL'
     *
     c                   endsl
     *
     c                   callp     prGetSlot
     *
     ** No More Slots Found. Adjust Remaining Qty From This Slot.
     *
     c                   if        $gslot = '*NONE*'
     c                   eval      wkLstSlt = '*YES'
     c                   endif
     *
     ** Restore previous values after lookup.
     *
     c                   eval      $gcmd   = wkSavCmd
     c                   eval      $gslot  = wkSavSlt
     c                   eval      ipqdsp  = wkSavSlt
     *
     ** Slot found. Compute available qty in slot.
     *
     c                   callp     prAvailSlot
     *
     ** If not a credit memo, check if more slots are available.
     *
     c                   if        avail1 = 0
     c                             and avail2 = 0
     c                             and avail3 = 0
     c                             and wkLstSlt = '*NO '
     *
     c**                           and obtype <> 'C'
     *
     *    Normal item, not a credit memo, no qty available this
     *
     c***                          or  avail1 = 0
     c***                          and ooibccd <> 'Y'
     c***                          and wkLstSlt = '*NO '
     c***                          and obtype <> 'C'

     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     c                   Iter
     *
     *    Pick slot read has zero available qty, find next slot.
     *
     c                   when         $gcmd = '*NEXT'
     c                             or $gcmd = '*NEXTOFL'
     c                   Iter
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = '*FRSTOFL'
     c                   eval      $gcmd = '*NEXTOFL'
     *
     c                   Iter
     *
     c                   endsl
     *
     c                   endif
     *
     *    Slot found with available qty. If broken case picked, convert cases
     *    to total eaches.
     *
     C                   eval      wkTtlQty = (avail1 * itumq2 * itumq3)
     C                                      + (avail2 * itumq3)
     C                                      +  avail3
     *
     *    Convert imported adjusted qty's to lowest form.
     C                   eval      totAdjQty = (ipqqp1 * itumq2 * itumq3)
     C                                      + (ipqqp2 * itumq3)
     C                                      +  ipqqp3
     *
     c*                  if        (ipqqp2 <> 0
     c*                               or ittype = 'S'
     c*                                 or ittype = 'A'
     c*                             and i3ittype = 'S')
     c*                               and (itumq2 > 0)
     c*                  eval      wkTtlQty = (avail1 * itumq2)
     c*                            + avail2
     c*                  else
     c*                  eval      wkTtlQty = avail1
     c*                  endif
     *
     c     #start_adj    tag
     *
     c                   eval      $pwhdp = slwhdp
     *
     ** Load Info From File For Adjustment.
     *
     c                   eval      wkQty1 = 0
     c                   eval      wkQty2 = 0
     c                   eval      wkQty3 = 0
     *
     c                   eval      w1Cwtr = 0
     c                   eval      w1Code = '  '
     c                   eval      wkError = *off
     *
     *   Last slot available for item or qty available greater than
     *   qty picked or this is a credit memo.
     *
     c                   select
     *
     c                   when      wkLstSlt = '*YES'
     *
     c                             or totAdjQty <= wkTtlQty
     *
     c                             or totAdjQty < 0
     *
     *      Remainder zeroed because entire qty will be adjusted
     *      from the selected slot.
     C                   eval      remAdjQty = 0
     *
     C                   eval      wkQty3    = %rem(totAdjQty : itumq3)
     c                   eval      wkQty3    = wkQty3 * -1
     C                   eval      wkTtlQty  = %div(totAdjQty : itumq3)
     *
     C                   eval      wkQty2    = %rem(wkTtlQty : itumq2)
     c                   eval      wkQty2    = wkQty2 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq2)
     *
     C                   eval      wkQty1    = wkTtlQty
     c                   eval      wkQty1    = wkQty1 * -1
     *
     c                   eval      w1Cwtr = 0
     *
     *   Slot does not have sufficient qty to cover qty picked.
     *   Take all available from this slot.
     *
     c                   when      totAdjQty > wkTtlQty
     c
     C                   eval      remAdjQty = totAdjQty - wkTtlQty
     *
     C                   eval      wkQty3    = %rem(wkTtlQty : itumq3)
     c                   eval      wkQty3 = wkQty3 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq3)
     *
     C                   eval      wkQty2    = %rem(wkTtlQty : itumq2)
     c                   eval      wkQty2 = wkQty2 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq2)
     *
     C                   eval      wkQty1    = wkTtlQty
     c                   eval      wkQty1 = wkQty1 * -1
     *
     c                   eval      w1Cwtr = 0
     *
     c                   endsl
     *
     c                   eval      w1Code = ipqAdj
     *
     c                   eval      w1Memo = ipqmem
     *
     *   Send adjustment to be processed.
     *
     c                   callp     prZzUpd
     *
     c                   if        wkError = *On
     c                   eval      wkErDesc = desc(5)
     c                   callp     prPrtItmErr
700aAC                   eval      ipqstatus = 'E'
740aAc                   eval      toterror = toterror + 1
700aAC                   eval      importError = *on
700aAc                   eval      ipqtext = desc(5)
700aAc                   if        ipqupdated = *off
700aAC                   update    ipqrec
700aAc                   eval      ipqupdated = *on
700aAc                   endif
     *
     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = '*FRSTOFL'
     c                   eval      $gcmd = '*NEXTOFL'
     *
     c                   endsl
     *
     c                   Iter
     c                   Endif
     *
     *   Reduce pick qty by qty adjusted from slot.
     *
530cDc*                  eval      ipqqp1 = ipqqp1 - wkQtyAdj
530Ca*
530cAC                   eval      ipqqp3    = %rem(remAdjqty : itumq3)
530cAC                   eval      remAdjQty = %div(remAdjQty : itumq3)
530cA*
530cAC                   eval      ipqqp2    = %rem(remAdjQty : itumq2)
530cAC                   eval      remAdjQty = %div(remAdjQty : itumq2)
530cA*
530cAC                   eval      ipqqp1    = remAdjQty
530cA*
     *
     *   Pick qty still remaining. Set cmd to look for next slot.
     *
     c                   If        ipqqp1 <> 0
530cAc                             or ipqqp2 <> 0
530cAc                             or ipqqp3 <> 0
     *
     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = '*FRSTOFL'
     c                   eval      $gcmd = '*NEXTOFL'
     c                   endsl
     c                   endif
     *   dow ipqqp1-3 <> 0
     c                   enddo
     p prLocateSlot    e
     *
     *----------------------------------------------------------------
     *
     *   Load Adjustment History Fields
     *
     p prLodAdjHst     b
     d  prLodAdjHst    pi
     *
     c                   eval      pqhwhs = ipqwhs
     c                   eval      pqhwhd = ipqwhd
     c                   eval      pqhdsp = ipqdsp
     c                   eval      pqhitm = ipqitm
     c                   eval      pqhqp1 = ipqqp1
     c                   eval      pqhqp2 = ipqqp2
     c                   eval      pqhqp3 = ipqqp3
     c                   eval      pqhadj = ipqadj
     c                   eval      pqhmem = ipqmem
     c                   eval      pqhsof = ipqsof
     c                   eval      pqhids = wkTimStp
     *
     c                   write     pqhrec
     *
     c                   return
     *
     p prLodAdjHst     e
     *
     *----------------------------------------------------------------
     *
     *    GETIT - Get Dakota Item Master Record
     *
     p prPrtItmErr     b
     d  prPrtItmErr    pi
     *
     ** Print Header Record
     *
     c                   if        wkPrtFlg = *off or
     c                               *in90 = *on
     c                   write     header
     c                   eval      wkPrtFlg = *on
     c                   eval      *in90 = *off
     c                   endif
     *
     ** Print Detail Record
     *
     c                   eval      wktote = wktote + 1
     *
     ** Setup Detail Line Error Desc
     *
     c                   select
     *
     c                   when      wkWhsErr = cstQtyErr
     c                   eval      wkrerr = desc(9)
     c                   write     detail
     *
     c                   when      wkAdjErr = cstAdjErr
     c                   eval      wkrerr = desc(7)
     c                   write     detail
     *
     c                   when      wkItmErr = cstItmErr
     c                   eval      wkrerr = desc(1)
     c                   write     detail
     *
     c                   when      wkQtyErr = cstQtyErr
     c                   eval      wkrerr = desc(8)
     c                   write     detail
     *
     c                   when      wkErDesc <> *blanks
     c                   eval      wkrerr = wkErDesc
     c                   write     detail
     c                   if        wkrerr2 <> *blanks
     c                   write     detail2
     c                   endIf
     *
     c                   endsl

640aAc                   eval      ipqStatus = 'E'
640aAc                   if        ipqText = ' '
640aAc                   eval      ipqText = wkrerr
640aAc                   else
640aAc                   eval      ipqText = %trimr(ipqText) + ' // '
640aAc                                     + wkrerr
640aAc                   endif
640aAc                   if        wkrerr2 <> ' '
640aAc                   eval      ipqText = %trimr(ipqText) + ' :: '
640aAc                                     + wkrerr2
640aAc                   endif
     *
     ** Clear Error Work Fields
     *
     c                   eval      wkAdjErr = *blanks
     c                   eval      wkItmErr = *blanks
     c                   eval      wkQtyErr = *blanks
     c                   eval      wkWhsErr = *blanks
     c                   eval      wkErDesc = *blanks
     c                   eval      wkrerr2  = *blanks
     *
     c                   return
     *
     p prPrtItmErr     e
     *
WILbA*----------------------------------------------------------------
WILbA*
WILbA*   Retrieve customer order number and check for existing
WILbA*
WILbAp prRtvOrdNbr     b
WILbAd prRtvOrdNbr     pi
WILbA *
WILbA *  Parse customer order number from memo
WILbA *
WILbAC                   monitor
WILbAC                   select
WILbAC                   when      client = willfoods
WILbAC                   eval      custorder = %dec(%subst(ipqmem:10:6):6:0)
WILbA /free
WILbA     Exec Sql Select max(ohord) into :checkrte
WILbA                from ordh5, rtehed
WILbA               where ohrte = rhrtid
WILbA                 and ohwhse = :ipqWhs
WILbA                 and ohcord = :custorder
WILbA                 and rhstat >= '1'
WILbA                 and rhstat <= '6';
WILbA
WILbA     if SQLCOD = 0;
WILbA       orderfound = '*YES';
WILbA     endif;
WILbA /end-free
FGLbA
FGLbA /free
FGLbA   when client = FoodsGalore;
FGLbA     custmemo = %subst(ipqmem:1:6);
FGLbA     exec Sql Select max(iamemo) into :checkorder
FGLbA                 from itemadj
FGLbA               where iawhse = :ipqwhs
FGLbA                 and iaitem = :ipqitm
FGLbA                 and iamemo = :custmemo;
FGLbA
FGLbA     if SQLCOD = 0;
FGLbA       orderfound = '*YES';
FGLbA     endif;
FGLbA /end-free
WILbA
WILbAC                   other
WILbAC                   eval      custorder = 0
WILbAC                   endsl
WILbAC                   on-error
WILbAC                   eval      custorder = 0
WILbAC                   endmon
WILbA *
WILbA *  * Check route for order for active status
WILbA /free
WILbA     Exec Sql Select max(ohord) into :checkrte
WILbA                from ordh5, rtehed
WILbA               where ohrte = rhrtid
WILbA                 and ohwhse = :ipqWhs
WILbA                 and ohcord = :custorder
WILbA                 and rhstat >= '1'
WILbA                 and rhstat <= '6';
WILbA
WILbA     if SQLCOD = 0;
WILbA       orderfound = '*YES';
WILbA     endif;
WILbA /end-free
WILbAC                   return
WILbA *
WILbAp prRtvOrdNbr     e

SPIaA*----------------------------------------------------------------
SPIaA*
SPIaA*            Stern Produce - Alias Packouts
SPIaA*
SPIaAp prSPIPackout    b
SPIaAd  prSPIPackout   pi
SPIaA /free

SPIaA    // get recid for matching adjustment number
SPIaA        GetRecId(ipqwhs: 'WR112': recidnum);
SPIaA
SPIaA    // write minus from alias parent
SPIaA    iawhse = ilwhse;
SPIaA    iaitem = ilitm2;
SPIaA    iadate = %dec(%char(%date():*iso0):8:0);
SPIaA    iatime = %dec(%char(%time():*hms0):6:0);
SPIaA    iaby = 'HQ245';
SPIaA    iawhdp = ipqwhd;
SPIaA    iadisp = ' ';
SPIaA    iacwta = 0;
SPIaA    iaqty1 = wkQty1;
SPIaA    iaqty2 = wkQty2;
SPIaA    iaqty3 = wkQty3;
SPIaA    iaudte = 0;
SPIaA    iautim = 0;
SPIaA    iacode = 'PA';
SPIaA    iamemo = 'RPK ' + %editc(recidnum:'X');
SPIaA    write iarec;
SPIaA
SPIaA    // write plus for alias item
SPIaA    iaitem = ipqitm;
SPIaA    iaqty1 = -1 * wkQty1;
SPIaA    iaqty2 = -1 * wkQty2;
SPIaA    iaqty3 = -1 * wkQty3;
SPIaA    write iarec;
SPIaA
SPIaA /end-free
SPIaAp prSPIPackout    e
SPIaA*
     *----------------------------------------------------------------
     *
     *            Verify Adjustment Code
     *
     p prVfyAdjCde     b
     d  prVfyAdjCde    pi             8
     *
     d prAdjErr        s              8    inz('#NoError')
     *
     *   Check Adj Code File Master File
     *
520cDc*                  eval      $lcmd  = '*VERIFY '
520cMc                   eval      $lcmd  = '*VERIFYB'
     c                   eval      $lCode = ipqAdj
     *
     c                   call      'AD900'
     c                   parm                    $lparm
     *
     c                   if        $lrtn = '*ERROR  '  or
     c                               $lrtn <> '*OK     '
     c                   eval      prAdjErr = cstAdjErr
     c                   eval      wkError = *on
     c                   endIf
     *
     c                   return    prAdjErr
     *
     p prVfyAdjCde     e
     *
     *----------------------------------------------------------------
     *
     *            Verify Adjustment Code
     *
     p prVfyAdjQty     b
     d  prVfyAdjQty    pi             8
     *
     d prQtyErr        s              8    inz('#NoError')
     *
     *   Check Quantities
     *
     c                   if        ipqqp1 = *zeros and
     c                             ipqqp2 = *zeros and
     c                             ipqqp3 = *zeros
     c                   eval      prQtyErr = cstQtyErr
     c                   eval      wkError = *on
     c                   endIf
     *
     c                   return    prQtyErr
     *
     p prVfyAdjQty     e
     *
     *----------------------------------------------------------------
     *
     *    Read KITCOMP and KITITEM for Repack information
     *
     p prNonRepack     b
     d  prNonRepack    pi
      /free
        odritemflag = *off;
        wkSavItm = ' ';
        wkitmErr = prGetDktItm();  //get master item info
        if wkError = *on;
           wkItmErr = ' ';
           wkErDesc = desc(11);
           callp prPrtItmErr();
700aA      ipqstatus = 'E';
740aA      toterror = toterror + 1;
700aA      importError = *on;
700aA      ipqtext = desc(11);
700aA      if ipqupdated = *off;
700aA        update ipqrec;
700aA        ipqupdated = *on;
700aA      endif;
           return;
        endif;
650bA   callp prLocateSlot();
      /end-free
     p prNonRepack     e
     *
     *----------------------------------------------------------------
     *
     *    Create adjustments for Repack Items
     *
     p prRepackItem    b
     d  prRepackItem   pi
     *
     ** Create Adjustments for Repack Items
     *
      /free
         odritemflag = *off;
710cD    //setll ($pwhse:ipqitm) kitcomp;
710cM    setll ($pwhse:wkKeyItm) kitcomp;
710dD    //reade ($pwhse:ipqitm) kitcomp;
710dD    //dow %equal and not %eof;
710dM    dow forever = forever;
710dA       odritemflag = *off;

650dD   //    reade ($pwhse:ipqitm) kitcomp;
710dM       reade ($pwhse:wkKeyItm) kitcomp;
710dA       if %eof(kitcomp) or not %found(kitcomp);
710dA          leave;
710dA       endif;

650bA       //loop through kitcomp writing adjustments for all parents
            ilitm2 = %trim(kccitm);
            ilitm3 = ' ';
            wkKeyitm = %trim(kccitm);
710dD       //chain ($pwhse:ipqitm) kititem;
650dA       chain ($pwhse:wkKeyItm) kititem;
650bA       if %found (kititem);
650bA          if kirptp = '2';    //On-Demand Repack Item
                  ipqqp3 = ipqqp1 * kcqty3;
                  ipqqp2 = ipqqp1 * kcqty2;
                  ipqqp1 = ipqqp1 * kcqty1;
                  odritemflag = *on;
                  wkSavItm = ' ';
710bA             wkKeyItm = %trim(ilitm2);
                  wkitmErr = prGetDktItm();  //get master item info
                  if wkError = *on;
                     wkItmErr = ' ';
                     wkErDesc = desc(11);
                     callp prPrtItmErr();
700aA                ipqstatus = 'E';
740aA                toterror = toterror + 1;
700aA                importError = *on;
700aA                ipqtext = desc(11);
700aA                if ipqupdated = *off;
700aA                  update ipqrec;
700aA                  ipqupdated = *on;
700aA                endif;
                     return;
                  endif;
650bA          endif;
650bA       endif;

HKWaA /end-free
HKWaAC                   if        client = Hearnkirkwood
HKWaA*
HKWaA*      Flip sign on qty imported for Repack adjustments.
HKWaA*      Host is sending neg. qty for From Item adjustment and
HKWaA*      positive qty for To Item adjustment.
HKWaAC                   if        ipqadj = 'TR'
HKWaAC                   eval      ipqqp1 = ipqqp1 * -1
HKWaAC                   eval      ipqqp2 = ipqqp2 * -1
HKWaAC                   eval      ipqqp3 = ipqqp3 * -1
HKWaAC                   endif
HKWaA*
HKWaAC                   endif
HKWaA*
HKW AC                   eval      xdkflag = '*NO '
HKWbAC                   eval      wkCrtXDKErr = ' '
HKWbA /free
710bM       $gcmd = '*FIRST';
            $gwhse = $pwhse;
710bA       if     odrItemFlag
710bA          and wkItType = 'R';
710bA          $gitem = ilitm2;
710bA       else;
710bD       //$gitem = kccitm;
710bM         $gitem = ipqitm;
710xM         wkKeyitm = ipqitm;
710bA       endif;

            if ipqdsp <> ' ';  //On-Demand Slot sent with data

               if ipqwhd = ' ';
                  ipqwhd = dsItWhdp;
               endif;

               //  verify slot passed in is valid for item
               setll (ipqwhs:ipqwhd:wkKeyItm:ipqdsp) slot4;
               if not %equal(slot4);
                 // if item not found in given slot check virtual slots
                  setll (ipqwhs:ipqwhd:ipqdsp) vslot2;
                  dow forever = forever;
                     reade (ipqwhs:ipqwhd:ipqdsp) vslot2;
                     if %eof(vslot2);
                        leave; //once end of file reached leave
                     endif;
                     setll (ipqwhs:ipqwhd:wkKeyItm:vsdisp) slot4;
                     if %equal(slot4);
                        //  virtual slot found so update imported slot
                        ipqdsp = vsdisp;
                        leave;
                     endif;
                  enddo;   // loop through vslot2
                  // if it falls through it means it did not find the passed
                  // slot.  Lets try the defined slot in item maintenance
                  setll (ipqwhs:ipqwhd:wkKeyItm:kcdisp) slot4;
                  if not %equal(slot4);
                    // if item not found in given slot check virtual slots
                     setll (ipqwhs:ipqwhd:kcdisp) vslot2;
                     dow forever = forever;
                        reade (ipqwhs:ipqwhd:kcdisp) vslot2;
                        if %eof(vslot2);
                           ipqdsp = kcdisp;
                           leave; //once end of file reached leave
                        endif;
                        setll (ipqwhs:ipqwhd:wkKeyItm:vsdisp) slot4;
                        if %equal(slot4);
                           //  virtual slot found so update imported slot
                           ipqdsp = vsdisp;
                           leave;
                        endif;
                     enddo;
                  else;
                     // found item maintenance slot so move it in
                     ipqdsp = kcdisp;
                  endif;
               endif;
               wkQty1 = ipqqp1 * -1;
               wkQty2 = ipqqp2 * -1;
               wkQty3 = ipqqp3 * -1;
               callp prZzUpd();
               if wkError = *on;
                  wkErDesc = desc(10);
                  callp prPrtItmErr();
700aA             ipqstatus = 'E';
740aA             toterror = toterror + 1;
700aA             importError = *on;
700aA             ipqtext = desc(10);
700aA             if ipqupdated = *off;
700aA               update ipqrec;
700aA               ipqupdated = *on;
700aA             endif;
                  return;
               endif;
            else;
              // transactions are written from the LocateSlot procedure
               callp prLocateSlot();
            endif;

710dD     //reade ($pwhse:ipqitm) kitcomp;
650bA    enddo;

      /end-free
     *
     c                   return
     *
     p prRepackItem    e
     *
     *
     *----------------------------------------------------------------
     *
     *  PRZZGETIL - Get Dakota Item Link Record
     *
     p prZzGetIl       b
     d  prZzGetIl      pi
     *
     ** Get Record From Main File.
     *
     c                   eval      wkError = *off
     *
     c     keyil         chain     itemLnk
     c                   if        not %found(itemLnk)
     c                   eval      wkError = *on
530 Ac                   eval      ilitm2  = ' '
530 Ac                   eval      ilitm3  = ' '
     c                   endif
     *
     c                   return
     *
     p prZzGetIl       e
     *
     *----------------------------------------------------------------
     *
     *  PRZZINZ2 - Program Initialization. Called From Main Line
     *
     p prZzInz2        b
     d  prZzInz2       pi
     *
640cAC                   if        %open(hq245pr)
640cA*
640cA* Write Exception Report Total
640cA*
640cAc                   if        wktote > 0
640cAc                   if        *in90 = *on
640cAc                   write     header
640cAc                   endif
640cAc                   write     total
640cAc                   endif
640cA*
640cAC                   close     hq245pr
640cAC                   endif
640cAC                   eval      wktote = 0
640cA*
640cA*      Retrieve report device override.
640cAC                   if        not %open(hq245pr)
640cA*
640cAC                   call      'GETRPT'
640cAC                   parm      '*DEVFORM'    $cmd              8
640cAC                   parm      'HQ245PR'     $lrpt            10
640cAC                   parm      ipqwhs        $whse             3 0
640cAC                   parm      ' '           $styp             1
640cAC                   parm      ' '           $whdp             5
640cAC                   parm                    $desc            50
640cAC                   parm      ' '           $dev             10
640cAC                   parm      ' '           $form            10
640cA*
640cAC                   if        $dev = ' '
640cAC                   eval      $dev = '*JOB'
640cAC                   endif
640cAC                   if        $form = ' '
640cAC                   eval      $form = '*STD'
640cAC                   endif
640cA*
640cAC                   eval      qcmd = 'OVRPRTF '
640cAC                                  + 'FILE(HQ245PR) '
640cAC                                  + 'OUTQ(' + %trim($dev) + ') '
640cAC                                  + 'FORMTYPE(' + %trim($form) + ') '
640cA
640cAC                   call      'QCMDEXC'
640cAC                   parm                    qcmd             80
640cAC                   parm      80            qlen             15 5
640cA
640cA*  Open printer file
640cA
640cAc                   eval      *in90 = *on
640cAC                   open(e)   hq245pr
640cAC                   if        %error
640cAC                   endif
640cA*
640cAC                   endif
640cA*
     c                   eval      wkError = *off
     c                   eval      $prtn = *blanks
     c                   eval      $perm = *blanks
     c                   eval      wkErDesc = *blanks
     c                   Move      *Blanks       Wodesc
     *
     c                   return
     *
     p prZzInz2        e
     *
     *----------------------------------------------------------------
     *
     *  PRZZUPD - Update Record
     *
     p prZzUpd         b
     d  prZzUpd        pi
     *
     c                   eval      wkError = *off

     *   Fill interface data structure fields.

     c                   callp     prFil$Adj
720bA *   if Repack ODR then mark with action of ODR
720bAc                   if        ipqadj='R1'
720bAc                   eval      $saactionu=*on
720bAc                   eval      $saaction='ODR'
720bAc                   endif

     *   Call interface to do update.

     c                   eval      $dricommand = '*SLOT'
720bAc                   if        useAdjust
720bAc                   eval      $drisubcmd  = '%ADJUST'
720bAc                   else
     c                   eval      $drisubcmd  = '%ADJUSTORD'
720bAc                   endif
     c                   eval      $drisys2upd = 'D'
     *
     c                   callp     prZzzDriCop
     *
     c                   return
     *
     p prZzUpd         e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p prZzzDriCop     b
     d  prZzzDriCop    pi
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
610aAc                   eval      $dridata2 = $slot2

     c                   when      $dricommand = '*ITEM'
     c                   eval      $dridata = $item
     c                   eval      $dridata2 = $item2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*ITEM'
610aAc                             or $dricommand = '*SLOT'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

SFPbAc                   when      $drisubcmd = '*CRTVPICK'
SFPbAc                             and $drireturn = 'VRTPCKCRT'
SFPbAc                   eval      wkError = *off

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
610aAc                   eval      $slot2 = $dridata2
     c                   when      $dricommand = '*ITEM'
     c                   eval      $item = $dridata
     c                   eval      $item2 = $dridata2
     c                   endsl

     c                   return

     p prZzzDriCop     e

     *----------------------------------------------------------------
     *  zzzds2slot  Move slot ds fields into std slot fields.
     *----------------------------------------------------------------

     C*    zzzds2slot    begsr

     C*                  eval      slwhse = $slwhse
     C*                  eval      slwhdp = $slwhdp
     C*                  eval      sldisp = $sldisp
     C*                  eval      slaisl = $slaisl
     C*                  eval      slloc  = $slloc
     C*                  eval      slrlvl = $slrlvl
     C*                  eval      slhand = $slhand
     C*                  eval      slside = $slside
     C*                  eval      slstyp = $slstyp
     C*                  eval      slstat = $slstat
     C*                  eval      slsdte = $slsdte
     C*                  eval      slstim = $slstim
     C*                  eval      slsdef = $slsdef
     C*                  eval      sldesg = $sldesg
     C*                  eval      slactv = $slactv
     C*                  eval      slbld  = $slbld
     C*                  eval      slpick = $slpick
     C*                  eval      slpseq = $slpseq
     C*                  eval      slprty = $slprty
     C*                  eval      slentd = $slentd
     C*                  eval      slexpd = $slexpd
     C*                  eval      slslfd = $slslfd
     C*                  eval      slrsrv = $slrsrv
     C*                  eval      slitem = $slitem
     C*                  eval      slstk1 = $slstk1
     C*                  eval      slstk2 = $slstk2
     C*                  eval      slstk3 = $slstk3
     C*                  eval      slalc1 = $slalc1
     C*                  eval      slalc2 = $slalc2
     C*                  eval      slalc3 = $slalc3
     C*                  eval      sltfr1 = $sltfr1
     C*                  eval      sltfr2 = $sltfr2
     C*                  eval      sltfr3 = $sltfr3
     C*                  eval      slpck1 = $slpck1
     C*                  eval      slpck2 = $slpck2
     C*                  eval      slpck3 = $slpck3
     C*                  eval      slrcv1 = $slrcv1
     C*                  eval      slrcv2 = $slrcv2
     C*                  eval      slrcv3 = $slrcv3
     C*                  eval      slphy1 = $slphy1
     C*                  eval      slphy2 = $slphy2
     C*                  eval      slphy3 = $slphy3
     C*                  eval      slavl1 = $slavl1
     C*                  eval      slavl2 = $slavl2
     C*                  eval      slavl3 = $slavl3
     C*                  eval      sladj1 = $sladj1
     C*                  eval      sladj2 = $sladj2
     C*                  eval      sladj3 = $sladj3

     C*    endds2item    endsr

760 A *----------------------------------------------------------------
760 A *  getSchTimeEml - Get Email address for specific error  report
760 A *----------------------------------------------------------------

760 Ap getSchTimeEml   b
760 Ad getSchTimeEml   pi

      *  Local Variables

     D weekday         s              3
     D currTime        s              5

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // get current time (hh:mm)
            currTime = %subst(%char(%time():*ISO):1:5);

            // now query scheduled entries for closest
            // time to current system time that is active
            // for the current Report being processed
            exec sql select bsvalue into :schEmail
                from bfcmrcrprm as a where a.bswhse=:$pWhse and
              a.bsrptpgm=:currReport and a.bsmrctbl='E' and
              a.bsmrcprm='EMAIL' and
               (select b.bsvalue from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='D'
                 and b.bsmrcprm=:weekday)='Y' and
               (select min(b.bsvalue) from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='X'
                 and b.bsmrcprm='SCHTIME')<:currTime;

760 Ap getSchTimeEml   e
760 A*----------------------------------------------------------------*
760 A* Procedure:  DayOfWeek
760 A* Purpose:  Determine the day of week for a particular date
760 A* Parameters:
760 A*    I: dt   -- date
760 A* Returns:
760 A*    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
760 A* Notes:
760 A*    January 5, 1800 is a Sunday.  This procedure only works for
760 A*    dates later than 1800-01-05.
760 A*----------------------------------------------------------------*

760 AP DayOfWeek       b
760 AD DayOfWeek       pi            10i 0
760 AD   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
760 AP DayOfWeek       e
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Item Not Found In Dakota. Not Adjusted.
Alias Link Rcd Missing. Not Adjusted.
Slot Not Found. Not Adjusted.
Item Verify Failed. Not Adjusted.
Item Adjustment Not Posted.
DRI Interface Error. Slot Not Found.
Adj Code Not Found, Not Adjusted.
Quantity is Zero, Not Adjusted.
Warehouse Not Found, Not Adjusted.
DRI Interface Error.
Parent for JIT Rpk missing.Not Adjusted.
