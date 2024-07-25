     H option(*NODEBUGIO)
640cAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
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
640aA*  11/15/11  RH   6.40a
     *    - Enh: Revised program to process cmd *CHGOUT to find slot
     *      for OUT label with no slot and reduce qty.
640bA*  02/09/12  MLB  6.40b
     *    - Fix: Change to 6.40a mod. Revised pgm to load $PWHSE
     *      with value of IPQWHS. When pgm was run for cmds other than
     *      *CHGOUT, $PWHSE was not properly initialized.
640cA*  06/25/12  MLB/RBD  6.40c
     *    - Fix: Revised program to populate LLADDEMP with user id that
     *      is running the job. This will correct a problem in the
     *      license tracking module with incorrect data being logged.
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
     *      some mod marks may have changed
650cA*  06/03/13  MLB  6.50c
     *    - Fix: Revised program to save item type into wkItType. Item
     *      Type for repack item was being lost when parent item info
     *      was retrieved.
650dA*  09/06/13  KDE  6.50d
     *    - Fix: Revised program to run Repack routines when Alias Item
     *      calls a Repack Item
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
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    07/11/11  MLB  CPC
     *      - Revised program to check the item master record for each
     *        item and if Brkdwn 1 UoM > blanks and Brkdwn 1 Qty > 0
     *        and Allow Entry Flag 1 = Y, move invoice qty from IPQQP1
     *        into IPQQP2 and zero out IPQQP1.  Dynamics GP is sending
     *        invoice qty as Eaches in IPQQP1 and it needs to be moved
     *        so that eaches are adjusted instead of cases.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICB A*  08/13/12  MLB  ICB
     *    - Revised program to extract customer order number from IPQMEM.
     *      Next, take customer order number and see if order is on file
     *      in TruckBuilder. If found, skip item adjustment processing.
ICBbA*  09/16/12  RTR  ICBb
     *    - Added customer number to check for existing order.
ICBcA*  01/31/14  mlb  ICBc
     *    - Fix: Changed size of field, CHECKRTE to 7,0 from 5,0.
     *      Was causing SQL stmt to fail with SQLSTT = 22003 status
     *      which is "Numeric value out of range".
ICBdA*  04/05/16  MLB  ICBd
     *    - Fix: Revised ICBb mod. NDS converted customer number to
     *      alpha and now sends customer number in OHMISC in positions
     *      11-15.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greve's Menu Maker
     *
GMM A*  01/23/13  MLB  GMM
     *    - Revised program to change the sign on the qty when the
     *      adjustment code = TF. TF codes are for feeder truck ad-
     *      justments from Jefferson whse to Vinita whse.
     *    - If the item adjustment can't be processed, then pgm will
     *      attempt to create virtual pick slot for item and then com-
     *      plete adjustment into the new slot.
GMMaA*  02/13/13  MLB  GMMa
     *    - Revised GMM mod. NDS can't send type S, B item nbr and qty
     *      to adj. NDS to send each qty as decimal whole nbr in IPQP2
     *      and flag in IPQMEM position 3=Y=Yes.  Program will post
     *      adjustment to item using Eaches item number.
     *    - Added file ITEMLNK1 to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*  02/27/13  MLB  GFS
     *    - Revised program to pass XD as GETPSLTMV using designation
     *      field. Pgm will look for XDK slot to post adjustment to.
GFSaA*  03/04/13  MLB  GFSa
     *    - Revised program to flip sign on qty sent from Host when
     *      IPQADJ = CR. Per Roxanne, Hemant phone call.
GFSbA*  03/07/13  MLB  GFSb
     *    - Note: On mod, GFS, be sure to include 6.50 mod to pgm,
     *      GETPSLTMV in order for it to work correctly.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*  04/05/13  MLB  GLP
     *    - Revised program to pass XD as GETPSLTMV using designation
     *      field. Pgm will first look for XDK slot to post adjustment to.
     *      If no XDK slot is found, pgm will look for regular/pick over-
     *      slot(s) to adjust.
     *    - Note: On mod, GLP, be sure to include 6.50 mod to pgm,
     *      GETPSLTMV in order for it to work correctly.
GLPaA*  04/16/13  MLB  GLPa
     *    - Revised program to update qty's to negative when adj code
     *      is RT - Repack - To Item Adjustment so Repack qty will be
     *      added into pick slot.
GLPbA*  04/19/13  MLB  GLPb
     *    - Revised program to update qty's to negative when adj code
     *      is SI - Startup Pick Slot Adjustment so Whse qty will be
     *      added into pick slot.
GLPcA*  04/20/13  MLB  GPLc
     *    - Fix: Revised program to correctly create adjustments against
     *      the Repack slot for OnDemand Repack Items using the Parent
     *      item. The ODR pick slot is set to status RP.
     *    - Note: On mod, GLPc, be sure to include mod 6.50a to pgm,
     *      GETPSLTMV in order for it to work correctly.
GLPdA*  05/15/13  MLB  GLPd
     *    - Revised pgm to create Cross Dock slot, XDK-nnn-1 if
     *      program is unable to find an existing XDK slot when
     *      item sent with adjust code XD.
GLPeA*  05/15/13  MLB  GLPe
     *    - Revised mod GLP to create Cross Dock Slot, if no Regular
     *      pick or overflow slot is found for the item.
GLPfA*  05/16/13  MLB  GLPf
     *    - Revised program to update qty's to negative when adj code
     *      is SC - Shipping Qty Changes will be added to pick slot.
GLPgA*  05/22/13  MLB  GPLg
     *    - Fix: Revised GLPc mod to remove limitation for setting $GDESG
     *      = ODRRP when IPQADJ = SI.  Need to apply adjustment to JIT
     *      items whenever they are sent for adjustment.
GLPhA*  06/03/13  MLB  GLPh
     *    - Fix: Revised GLPd mod to set off ODRITEMFLAG when making
     *      another pass to look up XDK slot that was created for the
     *      item. ODRITEMFLAG was preventing GETPSLTMV from looking
     *      for XDK slots.
GLPiA*  06/10/13  MLB  GLPi
     *    - Fix: Revised pgm to look for pick slot assigned to item
     *      that is identified as an ODR item. If pick slot found,
     *      adjust qty from pick slot.  If no pick slot found, look
     *      for pick slot at RP status with Parent item# assigned and
     *      apply adjustment to that RP slot. If no slot found at RP
     *      status, create XDK slot and post adjustment.
GLPjA*  07/09/13  MLB  GLPj
     *    - Fix: Change to mod, GLPi. If parent item of ODR Repack
     *      item is an ODR Repack item, check to see if item has a
     *      active pick slot assigned. If yes, post adjustment to the
     *      slot. If no active pick slot found, look for slot with
     *      status RP to apply the adjustment. If no RP slot found,
     *      allow XDK slot to be created.
GLPkA*  07/16/13  MLB  GLPk
     *    - Fix: Change to mod, GLPi. For ODR repack item, add test
     *      to look for RP slot attached to repack item. If none
     *      found, look for slots attached to parent.
GLPlA*  08/29/13  KDE  GLPl
     *    - Enh: Change to drive return pick slots to ZERO instead of
     *      driving negative.  If the associated parent has a RP
     *      status slot pull remaining quantity from that slot
     *      otherwise create a cross dock slot
GLPmA*  02/19/14  KDE  GLPm
     *    - Enh: Change to look for regular pick after the RP slot on
     *      an ODR parent before creating and applying to a XDK slot
     *      Also corrected if looking at available stock
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *  08/24/16  RTR  FGLa
     *    - Added to GLPd, GLPe, GLPh mods to look for XDK slot, then
     *      pick/overflow, then create XDK if nothing found.
FGLb *  08/29/16  RTR  FGLb
     *    - Fix FRZ dept sent from host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCaA*  09/30/14  RTR  PFCa
     *    - Revised program to ignore value sent in ipqdsp. The pgm
     *      will search for pick slot(s) and if none found, look for
     *      overflow slots. (used removed CSP mod)
PFCbA*  10/03/14  RTR  PFCb
     *      - Added conversion to uppercase for IPQITM.
PFCcA*  11/05/14  RTR  PFCb
     *      - Added conversion to uppercase for IPQITM.
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

     fimpfpckq  if   e           k disk
530hAfkitcomp   if   e           k disk
650bAfkititem   if   e           k disk
     fpiritem   if   e           k disk
     fpiritem3  if   e           k disk    rename(itrec:itrec3)
     f                                     prefix(i3)
     fitemlnk   if   e           k disk
GMMaAfitemlnk1  if   e           k disk    usropn
GMMaAf                                     rename(ilrec:ilrec1)
     fslot2     if   e           k disk    rename(slrec:slrec2)
520aAfslot4     if   e           k disk    rename(slrec:slrec4)
520dAfvslot2    if   e           k disk
     fpckqadj   uf a e           k disk
     fhq245pr   o    e             printer oflind(*in90)
530eA
530eA*----------------------------------------------------------------
530eA*  Customer id
530eA*----------------------------------------------------------------
530eA
CSP A /copy qcopysrc,id#coastal
CPC A /copy qcopysrc,id#cpc
ICB A /copy qcopysrc,id#icb
GMM A /copy qcopysrc,id#gmm
GMM A /copy qcopysrc,id#gmmvini
GFS A /copy qcopysrc,id#gfs
GLP A /copy qcopysrc,id#glp
FGLaA /copy qcopysrc,id#fgl
PFCaA /copy qcopysrc,id#pfc

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     d prAvailSlot     pr

GMM Ad prCrtSlot       pr             8
GMM A
GLPdAd prCrtXDK        pr             8
GLPdA
     d prFil$Adj       pr

640aAd prFilImpf       pr

GMMaAd prCvtBrkQty     pr
GMMaAd  gbrkpct                       7s 3 const
GMMaAd  gipqqp1                       7s 0
GMMaAd  gipqqp2                       7s 0
GMMaAd  gadjitm                      15a
GMMaA
     d prGetDktItm     pr             8

     d prGetSlot       pr

     d prGetSl2        pr

     d prGetWhse       pr             8

     d prLocateSlot    pr

     d prLodAdjHst     pr

     d prNonRepack     pr

     d prPrtItmErr     pr

     d prRepackItem    pr

ICB Ad prRtvOrdNbr     pr

PFCcAd prRtvOrdNbr2    pr

     d prVfyAdjCde     pr             8

     d prVfyAdjQty     pr             8

     d prZzGetIl       pr

     d prZzInz2        pr

     d prZzUpd         pr

     d prZzzDriCop     pr

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
GMMaA /copy qcopysrc,ipqmem_gmm

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

     d avail1          s              5  0 inz
     d avail2          s              3  0 inz
     d avail3          s              3  0 inz
     d client          s             10    inz
ICBcDd*checkrte        s              5  0 inz
ICBcMd checkrte        s              7  0 inz
ICBdDd*custnumber      s              5  0 inz
ICBdMd custnumber      s              5    inz(' ')
ICB Ad custorder       s              7  0 inz
520dAd forever         s              1    inz('1')
GMMaAd   gBrkPct       s              7s 3
GMMaAd   gIpqQp1       s              7s 0
GMMaAd   gIpqQp2       s              7s 0
GMMaAd   gAdjItm       s             15a
640aAd good1           s              1    inz('0')
     d hmsmdy          s             12  0 inz
ICB Ad i               s              3  0 inz
GLPjAD Look4RegPick    s              1    inz('0')
530hAD odritemflag     s               n   inz('0')
GLPlAD OriginalWasRpk  s               n   inz('0')
ICB Ad orderfound      s              4    inz('*NO ')
GMM Ad onetry          s              4    inz('*NO ')
ICB Ad pos             s              3  0 inz
     d rdate           s              6  0 inz
530cAd remAdjQty       s              7  0 inz
GLPkAD rpslotfound     s               n   inz('0')
GLPlAD zeroPickthen    s               n   inz('0')
     d rtime           s              6  0 inz
     d stock1          s              5  0 inz
     d stock2          s              3  0 inz
     d stock3          s              3  0 inz
     d svittype        s              1    inz
530cAd totAdjQty       s              7  0 inz
640cAD usrfound        s              1    inz('0')
     d woDesc          s             55    inz
     d woWhse          s             55    inz
     d w1Code          s              2    inz
     d w1Cwtr          s              9  2 inz
     d w1Memo          s             30    inz
     *
     d wkAdjErr        s              8    inz
GMM Ad wkCrtSltErr     s              8    inz
GLPdAd wkCrtXDKErr     s              8    inz
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
GMMaAd svUmq2          s                   like(itumq2)
GMMaAd svUmq3          s                   like(itumq3)
     d wkWhse          s              3  0 inz
     d wkWhsErr        s              8    inz
GFS Ad xdkflag         s              4    inz('*NO ')

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
640aAd  $pmem                 77    106
     *
     *   Redefine key
     *
     d  $pwhse                19     21  0
     d  $pwhdp                22     26
     d  $pdisp                27     38
     d  $puser                39     48
640aAd  $pitem                27     41
640a d  $pqp1                 42     48  0
640a d  $pqp2                 49     55  0
640a d  $pqp3                 56     62  0
640a d  $padj                 63     64

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
PFCbAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
PFCbAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Called Program Parameters
     *----------------------------------------------------------------

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

     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Externally Defined Data Structure
     *----------------------------------------------------------------

     d  dsWrkItm     e ds                  extname(piritem) prefix(ds)
     d  dsPirItm     e ds                  extname(piritem)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -None-
     *
     *    Returned Parameters
     *      -None -
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
640aAC     *entry        plist
640aAC                   parm                    $parms
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     c     *loval        setll     impfPckq
     c                   dou       %eof(impfPckq)
640aAc                   if        $Pcmd = '*OUTCHG'
640aAc                   callp     prFilImpf
640aAc                   else
     c                   read      impfPckq
640aAc                   endif
     *
PFCbA*  Uppercase IPQITM
PFCbAC                   eval      ipqitm = %xlate(lower:UPPER:ipqitm)
     *
     *
GLPlAc                   eval      OriginalWasRpk = *off
640aAc                   if        $Pcmd = '*OUTCHG' and
640aAc                             good1 = *on
640aAc                   if        $Prtn = ' '
640aAc                   eval      $Prtn = '*OK'
640aAc                   endif
640aAc                   leave
640aAc                   endif
     *
     c                   if        not %eof(impfPckq)
     *
     c                   if        ipqWhs <> wkWhse
     c                   callp     prZzInz2
     *
     ** Get BFC Warehouse Desc
     *
     c                   eval      wkWhsErr = prGetWhse()
     *
640bAc                   if        $Pcmd <> '*OUTCHG'
640bAc                   eval      $pWhse = ipqWhs
640bAc                   endif
     c                   eval      wkWhse = ipqWhs
     c                   endif
ICB A*
ICB AC                   eval      orderfound = '*NO '
ICB AC                   select
ICB AC                   when      client = icb
ICB AC                   callp     prRtvOrdNbr
ICB AC                   if        orderfound = '*YES'
ICB A*      Write out flag in history rcd to indicate item was skipped.
ICB AC                   eval      ipqmem = %replace('*S':ipqmem:29)
ICB AC                   endif
ICB A*
PFCcAC                   when      client = prestofoods
PFCcAC                   callp     prRtvOrdNbr2
PFCcAC                   if        orderfound = '*YES'
PFCcAC                   eval      ipqmem = %replace('*S':ipqmem:29)
PFCcAC                   endif
ICB AC                   endsl
     *
     ** Write import record to history file.
     *
     c                   callp     prLodAdjHst
650 A*
650 AC                   if            ipqqp1 = 0
650 AC                             and ipqqp2 = 0
650 AC                             and ipqqp3 = 0
650 A*      Bypass processing items with no qty to adjust.
650 AC                   iter
650 AC                   endif
ICB A*
ICB AC                   select
ICB AC                   when      client = icb
PFCcAC                             or client = prestofoods
ICB AC                   if        orderfound = '*YES'
ICB AC                   iter
ICB AC                   endif
GMM A*
GMM AC                   when          client = menumaker
GMM AC                             and clientloc = gmmvinita
GMM A*      Flip sign on quantity so that qty is "added" to slot.
GMM A*      Product is arriving from Jefferson whse.
GMM AC                   if            ipqadj = 'TF'
GMM A*
GMMaAC                   eval      gmmmsc_base  = ipqmem
GMMaAC                   eval      gmmmsc_ogitm = ' '
GMMaA*
GMMaAC                   if        gmmmsc_bkflg = 'Y'
GMMaAC                   eval      gBrkPct = ipqqp2 * .001
GMMaAC                   eval      gIpqQp1 = ipqqp1
GMMaAC                   eval      gIpqQp2 = ipqqp2
GMMaA /free
GMMaA     prCvtBrkQTy(gBrkPct: gIpqQp1: gIpqQp2: gAdjItm);
GMMaA /end-free
GMMaAC                   eval      ipqitm = gAdjItm
GMMaAC                   eval      ipqqp1 = gIpqQp1
GMMaAC                   eval      ipqqp2 = gIpqQp2
GMMaAC                   endif
GMMaA*
GMM AC                   if        ipqqp1 > 0
GMM AC                   eval      ipqqp1 = ipqqp1 * -1
GMM AC                   endif
GMM A*
GMM AC                   if        ipqqp2 > 0
GMM AC                   eval      ipqqp2 = ipqqp2 * -1
GMM AC                   endif
GMM A*
GMM AC                   if        ipqqp3 > 0
GMM AC                   eval      ipqqp3 = ipqqp3 * -1
GMM AC                   endif
GMM A*
GMM AC                   endif
GFSaA*
GFSaA*------------------------------------------------------------------
GFSaAC                   when      client = Getfresh
GFSaA*
GFSaA*      Credit memo sent from Host. Flip sign so qty will be added in.
GFSaAC                   if        ipqadj = 'CR'
GFSaAC                   if        ipqqp1 > 0
GFSaAC                   eval      ipqqp1 = ipqqp1 * -1
GFSaAC                   endif
GFSaA*
GFSaAC                   if        ipqqp2 > 0
GFSaAC                   eval      ipqqp2 = ipqqp2 * -1
GFSaAC                   endif
GFSaA*
GFSaAC                   if        ipqqp3 > 0
GFSaAC                   eval      ipqqp3 = ipqqp3 * -1
GFSaAC                   endif
GFSaA*
GFSaAC                   endif
GLPaA*
GLPaA*------------------------------------------------------------------
GLPaAC                   when      client = Greenleaf
GLPaA*
GLPaA*      Repack - To Item sent from Host. Flip sign so qty will be added in.
GLPaAC                   if        ipqadj = 'RT'
GLPbAC                             or ipqadj = 'SI'
GLPfAC                             or ipqadj = 'SC'
GLPaA*
GLPaAC                   if        ipqqp1 > 0
GLPaAC                   eval      ipqqp1 = ipqqp1 * -1
GLPaAC                   endif
GLPaA*
GLPaAC                   if        ipqqp2 > 0
GLPaAC                   eval      ipqqp2 = ipqqp2 * -1
GLPaAC                   endif
GLPaA*
GLPaAC                   if        ipqqp3 > 0
GLPaAC                   eval      ipqqp3 = ipqqp3 * -1
GLPaAC                   endif
GLPaA*
GLPaAC                   endif
FGLbA*------------------------------------------------------------------
FGLbAC                   when      client = foodsgalore
FGLbAC                   if        ipqwhd = 'FRO'
FGLbAC                   eval      ipqwhd = 'FRZ'
FGLbAC                   endif
ICB A*
ICB AC                   endsl
     *
     ** Get Dakota Item Master
     *
     c                   eval      wkKeyItm = ipqItm
     *
     c                   eval      wkSavItm = *blanks
     *
     c                   eval      wkItmErr = prGetDktItm()
     *
     ** Verify Adjustment Code
     *
     c                   eval      wkAdjErr = prVfyAdjCde()
     *
     ** Verify Adjustment Qty's
     *
     c                   eval      wkQtyErr = prVfyAdjQty()
     *
     c                   if        wkError = *on
     c                   callp     prPrtItmErr
     c                   eval      wkError = *off
     c                   eval      wkPrtFlg = *on
     c                   iter
     c                   endIf
CPC A*
CPC AC                   if        client = CPC
CPC A*
CPC A*       For items that are setup as normal case/each item,
CPC A*       move invoice qty into IPQQP2 because CPC always sends
CPC A*       Each qty invoiced in IPQQP1.
CPC AC                   if            itum2  > ' '
CPC AC                             and itumq2 > 0
CPC AC                             and itflg1 = 'Y'
CPC AC                   eval      ipqqp2 = ipqqp1 + ipqqp2
CPC AC                   eval      ipqqp1 = 0
CPC AC                   endif
CPC A*
CPC AC                   endif
     *
     ** Save SSB Item Number & Type.
     *
     c                   eval      wkItType = *blank
     *
     c                   if        dsItType = 'S'
650cAc                             or dsItType = 'R'
     c                   eval      wkItType = dsItType
     c                   endif
     *
     ** Get Alias Item Base item.
     ** Get SSB Item Base item.
     *
     c                   if        dsItType = 'A'
     c                               or dsItType = 'S'
650bDc*                              or dsItType = 'R'
     c                   callp     prZzGetIl
     *
     c                   if        wkError = *on
     c                   eval      wkErDesc = desc(2)
     c                   callp     prPrtItmErr
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
650bA*    prRepackItem. Copy was placed in ENH650 HQ245.v640
650bA*    The select below goes to the procedure for R type and
650bA*    continues with previous code for other types
     *
     ** Get Pick Slot For Item.
     *
     c                   eval      $gcmd  = '*FIRST  '
GFS A*
GFS AC                   if        client = Getfresh
GFS A*
GFS A*      Get Fresh wants to search for XDK slots first.
GFS AC                   if        ipqadj = 'XD'
GFS AC                   eval      $gcmd  = '*FRSTOFL'
GFS AC                   eval      xdkflag = '*YES'
GFS AC                   else
GFS AC                   eval      xdkflag = '*NO '
GFS AC                   endif
GFS A*
GFS AC                   endif
GFS A*
GLP AC                   if        client = Greenleaf
GLP A*
GLPdAC                   if        ipqadj = 'XD'
GLP A*      Greenleaf wants to search for XDK slots first.
GLP AC                   eval      $gcmd  = '*FRSTOFL'
GLP AC                   eval      xdkflag = '*YES'
GLPdAC                   else
GLPdAC                   eval      xdkflag = '*NO '
GLPdAC                   endif
GLP A*
GLP AC                   endif
GLP A*
     c                   eval      $gwhse = $pwhse

650bAc                   select
     *
650bAc                   when      dsItType = 'R'
650dAc                             or (i3ItType = 'R'
650dAc                               and dsItType='A')
650bAc                   callp     prRepackItem
650bAc                   if        wkError = *on
650bAc                   iter
650bAc                   endif

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
     c                   if        ipqDsp <> *blanks
PFCaAc                             and client <> PrestoFoods
CSPcDc*                            and client <> CoastalSunbelt
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
     c                   iter
     c                   endif
     *   else ipqdsp = blanks
     c                   else
     c                   callp     prNonRepack
     *   ipqdsp <> blanks
     c                   endif
     *   when select for either Repack or Not
650bAc                   endsl
530aA*
     *  EndIf %eof(impfPckq)
     c                   endif
     *
640aAc                   if        $Pcmd = '*OUTCHG'
640aAc                   eval      good1 = *on
640aAc                   endif
     *
     *  EndDo IMPFPCKQ
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
     c                   eval      *inlr = *on
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
     *
GMMaAC                   if        client = Menumaker
GMMaA*
GMMaAC                   if        not %open(itemlnk1)
GMMaAC                   open      itemlnk1
GMMaAC                   endif
GMMaA*
GMMaAC                   endif
GMMaA*
     c                   eval      *in90 = *on
     c                   time                    wkTimStp
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     *
     c                   eval      $lprg = #prog

     *   Set warehouse defaults.

     c                   eval      w1Cwtr = *zeros
640aAc                   select
640aAc                   when      $pcmd  = '        '
     c                   eval      $pcmd  = '*CHANGE '
     c                   eval      $pwhse = 1
     c                   eval      $pwhdp = '*ALL '
640aAc                   when      $Pcmd = '*OUTCHG'
640aAc                   eval      good1 = *off
640aAc                   endsl
530bA*
530bA* Retrieve current date/time for report printing.
530bAc                   eval      $cvcmd = '*CURMDY '
530bAc                   call      @cvtdt
530bAc                   parm                    $cvtdt
530bAc                   eval      rdate = $cvd6o
530bAc                   time                    rtime
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
GMMaA* Define Full key for PIRITEM file
GMMaA*
GMMaAc     keyitgmm      klist
GMMaAc                   kfld                    $pwhse
GMMaAc                   kfld                    gAdjItm
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
GMMaA*
GMMaA* ITEMLINK1 Partial file key
GMMaA*
GMMaAc     keyil1        klist
GMMaAc                   kfld                    $pwhse
GMMaAc                   kfld                    ipqitm
     *
     * ITEMLINK Full file key
     *
     c     keyil3        klist
     c                   kfld                    itwhse
     c                   kfld                    wkKeyItm
     *
640cA*   Get default values for the user.
640cA*
640cAC                   call      'GETUSER'
640cAC                   parm                    #user
640cAC                   parm      0             #whse             3 0
640cAC                   parm      0             #emp#             5 0
640cAC                   parm                    #fnam            15
640cAC                   parm                    #init             1
640cAC                   parm                    #lnam            20
640cAC                   parm                    #whdp             5
640cAC                   parm                    #styp             1
640cAC                   parm                    #shft             6
640cAC                   parm                    #crew             6
640cAC                   parm      0             #nhrs             3 1
640cAC                   parm                    #rtn              8
640cAC                   if        #rtn = '*OK'
640cAC                   eval      usrfound = '1'
640cAC                   else
640cAC                   eval      usrfound = '0'
640cAC                   endif
     *
     c                   endsr
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
GMM A*
GMM A*----------------------------------------------------------------
GMM A*
GMM A*  prCrtSlot - Creat Virtual Pick slot.
GMM  A*
GMM Ap prCrtSlot       b
GMM Ad  prCrtSlot      pi             8
GMM A*
GMM Ad wkCrtSlotErr    s              8    inz('*SLOTCRT')
GMM A*
GMM A*  Use DRI interface to create virtual pick slot.
GMM A
GMM AC                   eval      savever# = $slver#
GMM AC                   clear                   $slot
GMM Ac                   clear                   $slot2
GMM AC                   eval      $slver# = savever#
GMM A*
GMM AC                   eval      $slwhseu = *on
GMM AC                   eval      $slwhse  = pqhwhs
GMM AC                   eval      $slwhdpu = *on
GMM AC                   eval      $slwhdp  = itwhdp
GMM A*
GMM AC                   eval      $sldispu = *on
GMM AC                   select
GMM AC                   when      itwhdp = '1    '
GMM AC                   eval      $sldisp = '37-199-1'
GMM AC                   when      itwhdp = '2    '
GMM AC                   eval      $sldisp = '64-199-1'
GMM AC                   when      itwhdp = '3    '
GMM AC                   eval      $sldisp = '14-199-1'
GMM AC                   when      itwhdp = '9    '
GMM AC                   eval      $sldisp = '37-199-1'
GMM AC                   other
GMM AC                   eval      $sldisp = ipqdsp
GMM AC                   endsl
GMM A*
GMM AC                   eval      $slitemu = *on
GMM AC                   eval      $slitem  = $gitem
GMM AC                   eval      $dricommand = '*SLOT'
GMM AC                   eval      $drisubcmd = '%CRTVPICK'
GMM AC                   eval      $drisys2upd = 'D'
GMM Ac                   callp     prZzzDriCop
GMM AC                   if        wkerror
GMM AC                   eval      wkCrtSlotErr = '*SLTCRTER'
GMM AC                   endif
GMM A*
GMM Ac                   return    wkCrtSlotErr
GMM A*
GMM Ap prCrtSlot       e
GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*
GMMaA*  prCvtBrkQty - Convert brkdwn percentage into eaches qty.
GMMa A*
GMMaAp prCvtBrkQty     b
GMMaAd  prCvtBrkQty    pi
GMMaAd   gBrkPct                      7s 3 const
GMMaAd   gIpqQp1                      7s 0
GMMaAd   gIpqQp2                      7s 0
GMMaAd   gAdjItm                     15a
GMMaA*
GMMaAC     keykc         chain     piritem
GMMaAC                   if        not %found(piritem)
GMMaAC                   eval      ittype = ' '
GMMaAC                   eval      itum2  = ' '
GMMaAC                   eval      itum3  = ' '
GMMaAC                   eval      itumq2 = 0
GMMaAC                   eval      itumq3 = 0
GMMaAC                   else
GMMaAC                   eval      svumq2 = itumq2
GMMaAC                   eval      svumq3 = itumq3
GMMaAC                   endif
GMMaA*
GMMaA*      Find Eaches item number for Parent/Base item.
GMMaAC     keyil1        setll     itemlnk1
GMMaAC     keyil1        reade     itemlnk1
GMMaAC                   if        %eof(itemlnk1)
GMMaAC                   eval      gAdjItm = ipqitm
GMMaAC                   else
GMMaAC                   eval      gAdjItm = ilitem
GMMaAC                   endif
GMMaA*
GMMaA*      Retrieve each item number to determine Item Type (ITTYPE)
GMMaAC     keyitgmm      chain     piritem
GMMaAC                   select
GMMaAC                   when      not %found(piritem)
GMMaAC                   eval      ittype = ' '
GMMaAC                   eval      itum2  = ' '
GMMaAC                   eval      itum3  = ' '
GMMaAC                   eval      itumq2 = 0
GMMaAC                   eval      itumq3 = 0
GMMaA*
GMMaA*
GMMaAC                   when      ittype = 'B'
GMMaA*      Qty needs to be posted to type B item nbr.
GMMaA*
GMMaA*      Save original item nbr when type B item used for adj.
GMMaAC                   eval      gmmmsc_ogitm = ipqitm
GMMaAC                   eval      ipqmem       = gmmmsc_base
GMMaA*
GMMaA*      Convert percentage into eaches qty.
GMMaAC                   eval (h)  gIpqQp2 = gBrkPct * svumq2
GMMaA*      Convert cases qty into eaches qty plus eaches.
GMMaAC                   eval      gIpqQp1 = (gIpqQp1 * svumq2) + gIpqQp2
GMMaAC                   eval      gIpqQP2 = 0
GMMaA*
GMMaAC                   other
GMMaA*      Replace original item number for all other item types.
GMMaAC                   eval      gAdjItm = ipqitm
GMMaAC                   eval (h)  gIpqQp2 = gBrkPct * svumq2
GMMaAC                   endsl
GMMaA*
GMMaAc                   return
GMMaA*
GMMaAp prCvtBrkQty     e
     *
     *----------------------------------------------------------------
640aA*
640aA*  prFilImpf - Fill IMPFPCKQ fields fields for *CHGOUT cmd.
640aA*
640aAp prFilImpf       b
640aAd  prFilImpf      pi

640aA*  Initialize fields
640aAc                   eval      ipqWhs  = $pwhse
640aAc                   eval      ipqWhd  = $pwhdp
640aAc                   eval      ipqDsp  = *blanks
640aAc                   eval      ipqItm  = $pitem
640aAc                   eval      ipqQp1  = $pqp1
640aAc                   eval      ipqQp2  = $pqp2
640aAc                   eval      ipqQp3  = $pqp3
640aAc                   eval      ipqadj  = $padj
640aAc                   eval      ipqmem  = $pmem
640aAc                   eval      ipqsof  = 'Y'
640aAc                   return

640aAp prFilImpf       e
640aA*
GLPdA*----------------------------------------------------------------
GLPdA*
GLPdA*  ZZCrtXDK - Creat XDK slot for item.
GLPdA*
GLPdAp prCrtXDK        b
GLPdAd  prCrtXDK       pi             8
GLPdA*
GLPdAd wkCrtXDKErr     s              8    inz('*XDKCRT')
GLPdA*
GLPdA*  Use DRI interface to create XDK slot.
GLPdA
GLPdAC                   eval      savever# = $slver#
GLPdAC                   clear                   $slot
GLPdAc                   clear                   $slot2
GLPdAC                   eval      $slver# = savever#
GLPdA*
GLPdAC                   eval      $slwhseu = *on
GLPdAC                   eval      $slwhse  = pqhwhs
GLPdA*
GLPdAC                   eval      $slwhdpu = *on
GLPdAC                   eval      $slwhdp  = itwhdp
GLPdA*
GLPdAC                   eval      $slitemu = *on
GLPdAC                   eval      $slitem  = $gitem
GLPdA*
GLPdAC                   eval      $slaislu = *on
GLPdAC                   eval      $slaisl  = 'XDK'
GLPdA*
GLPdAC                   eval      $dricommand = '*SLOT'
GLPdAC                   eval      $drisubcmd = '%CRTXDOCK'
GLPdAC                   eval      $drisys2upd = 'D'
GLPdAc                   callp     prZzzDriCop
GLPdAC                   if        wkerror
GLPdAC                   eval      wkCrtXDKErr = '*XDKCRTER'
GLPdAC                   endif
GLPdA*
GLPdAc                   return    wkCrtXDKErr
GLPdA*
GLPdAp prCrtXDK        e
GLPdA*
640aA*
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
640cA
640cAC                   if        usrfound = '1'
640cAC                   eval      $saemp#U = *on
640cAC                   eval      $saemp#  = #emp#
640cAC                   else
640cAC                   eval      $saemp#U = *off
640cAC                   eval      $saemp#  = 0
640cAC                   endif

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
GLP A*
GLP DC*                            or client = Getfresh
GLP MC                             or (client = Getfresh
GLP AC                             or client = Greenleaf)
GFS AC                             and xdkflag = '*YES'
GLPcA*
GLPcAC                             or client = Greenleaf
GLPcAC                             and odritemflag = '1'
GLPgDC**                           and ipqadj  = 'SI'
GFS A*
GFS AC                   select
GFS AC                   when      client = Getfresh
GLP AC                             or client = Greenleaf
GLPcA*
GLPcAC                   if        client = Greenleaf
GLPcAC                             and odritemflag = '1'
GLPjAC                             and Look4RegPick = '0'
GLPgDC**                           and ipqadj  = 'SI'
GLPcAC                   eval      $gdesg = 'ODRRP'
GLPcAC                   else
GLPcA*
GFS AC                   eval      $gdesg = 'XDK  '
GLPcAC                   endif
GLPcA*
GFS AC                   other
GFS AC                   eval      $gdesg = itdesg
GFS AC                   endsl
GFS A*
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
GFS Dc*                  parm      itdesg        $gdesg
GFS Mc                   parm                    $gdesg
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
     *
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
PFCaAc                   if        client = PrestoFoods
PFCaAC                   eval      ipqdsp = ' '
PFCaAC                   eval      ipqsof = 'Y'
PFCaAC                   endif
CSPcDc*                  if        client = CoastalSunbelt
CSPcDC*                  eval      ipqdsp = ' '
CSPcDC*                  endif
CSPaA*
CSPaAC                   if        client = CoastalSunBelt
CSPaA*      Save item info from Host in Memo field.
CSPaAC                   eval      ipqmem = %trim(ipqitm) + '/'
CSPaAC                             + %trim(%editc(ipqqp1:'L')) + '/'
CSPaAC                             + %trim(%editc(ipqqp2:'L')) + '/'
CSPaAC                             + %trim(%editc(ipqqp3:'L'))
CSPaAC                   endif
CSPaA*
GMM AC                   if        client = Menumaker
GMM AC                   eval      onetry = '*NO '
GMM AC                   endif
GLPdAC                   eval      wkCrtXDKErr = ' '

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
     c                   if        $Pcmd = '*OUTCHG'
     c                   eval      $Prtn = '*No Adj'
     c                   leave
     c                   endif
GMM A*
GMM AC                   select
GMM AC                   when          client = menumaker
GMM AC                             and clientloc = gmmvinita
GMM A*      Attempt to create virtual pick slot for item and then
GMM A*      re-try adjustment sent from Host.
GMM AC                   if                ipqadj = 'TF'
GMM AC                                 and onetry = '*NO '
GMM AC                   eval      wkCrtSltErr = prCrtSlot()
GMM A*      Re-try adjustment sent from Host.
GMM AC                   eval      $gcmd  = '*FIRST  '
GMM AC                   eval      onetry = '*YES'
GMM AC                   iter
GMM AC                   endif
GMM A*
GLP DC*                  when      client = Getfresh
GLP MC                   when      (client = Getfresh
GLPdDC*                            or client = Greenleaf)
FGLaDC***                                               )
FGLaMC                             or client = FoodsGalore)
GFS AC                             and xdkflag = '*YES'
GFS A*      No XDK slots found. Look for regular pick/ovrflow slots.
GFS AC                   eval      xdkflag = '*NO '
GFS AC                   eval      $gcmd  = '*FIRST  '
GFS AC                   iter
GFS A*
GLPdAC                   when          client = Greenleaf
GLPdAC                             and xdkflag     = '*YES'
GLPdAC                             and wkCrtXDKErr = ' '
GLPdAC                   eval      wkCrtXDKErr = prCrtXDK()
GLPdAC                   if        wkCrtXDKErr = '*XDKCRT'
GLPdA*      Force cmd to First Overflow slot, in case IPQSOF <> 'Y'.
GLPdAC                   eval      $gcmd  = '*FRSTOFL'
GLPdA*      Cross dock slot created, re-try adjustment sent from Host.
GLPdAC                   iter
GLPdAC                   endif
GLPeA*
GLPeA*      Reg. adjustment and no pick/overflow slot found. Create XDK.
FGLaDC***                when          client = Greenleaf
FGLaMC                   when         (client = Greenleaf
FGLaMC                              or client = FoodsGalore)
GLPeAC                             and xdkflag     = '*NO '
GLPeAC                             and wkCrtXDKErr = ' '
GLPeDC***                eval      wkCrtXDKErr = prCrtXDK()
GLPeDC***                if        wkCrtXDKErr = '*XDKCRT'
GLPeA*      Force cmd to First Overflow slot, in case IPQSOF <> 'Y'.
GLPeAC                   eval      $gcmd   =  '*FRSTOFL'
GLPeA*      Turn on flag so that pgm will look for XDK slot.
GLPeAC                   eval      xdkflag = '*YES'
GLPeAC                   eval      odritemflag = '0'
GLPeA*      Go look for cross dock slot to adjust.
GLPeAC                   iter
GLPeDC***                endif
GLPdA*
GMM AC                   endsl
GMM A*
     c                   eval      wkErDesc = desc(3)
     c                   callp     prPrtItmErr
     c                   leave
     *
     c                   endsl
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
     *   If Green Leaf, ODR item, only slot, and quantity to be
     *   driven negative then set flag to force pick slot or RP slot
     *   to zero and then put remaining quantity in cross dock slot
     *
     *   Flag zeroPickthen will be seton to force either the Pick
     *   slot or RP status slot to zero.  Once the pick slot is forced
     *   to zero the remaining quantity will either be pulled from the
     *   RP status slot or create a Cross Dock slot
     *
GLPlAc                   if        client = Greenleaf
GLPlAc                   eval      zeroPickthen = *off
GLPlA *   item originally called from ODR item
GLPlAc                   if        wkLstSlt = '*YES'
GLPlAc                             and OriginalWasRpk
GLPlAc                             and KIRPTP = '2'
GLPlAc                             and totAdjQty > wkTtlQty
GLPlA *   do not look for RP slot if it is already setting on a cross dock
GLPlAc                             and slstat<>'XD'
GLPlA *   if the normal above via the mainline of code has already made it
GLPlA *   to the calling item on the ODR KITCOMP list then force a cross
GLPLA *   dock slot
GLPlAc                   if        $gitem <> ilitm2
GLPlAc                             and slstat <> 'RP'
GLPlA*
GLPLA *   if we are still on the original ODR then force it to zero,
GLPlA*   but NOT negative
GLPlA*
GLPlAc                   eval      zeroPickthen = *on
GLPlA *
GLPlA *   if this is the parent/case item and the quantity is zero we
GLPlA *   and it is not a RP status slot then leave zero and push qty
GLPlA *   to a cross dock slot
GLPlA *
GLPlAc                   else
GLPlAc                   if        wkTtlQty = 0
GLPlAc                             and slstat <> 'RP'
GLPlAC                   eval      wkCrtXDKErr = prCrtXDK()
GLPlAC                   if        wkCrtXDKErr = '*XDKCRT'
GLPlAC                   eval      $gcmd  = '*FRSTOFL'
GLPlAc                   eval      odritemflag = *off
GLPlAc                   eval      XDKFlag = '*YES'
GLPlA*      Cross dock slot created, re-try adjustment sent from Host.
GLPlAC                   iter
GLPdAC                   endif
GLPlAc                   endif
GLPlAc                   endif
GLPlAc                   endif
GLPlAc                   endif
     *
     *   Last slot available for item or qty available greater than
     *   qty picked or this is a credit memo.
GLPlA*   if zeroPickthen below is ON it forces the pick or RP slot
GLPlA*   to zero and either looks for RP slot or cross dock in next
GLPlA*   pass.  zeroPickthen ONLY gets turned on for Greenleaf and
GLPlA*   along with the conditions below and original item was an ODR
     *
     c                   select
GLPlAc                   when      (client = Greenleaf
GLPlAc                             and (wkLstSlt = '*YES'
GLPlAc                             or totAdjQty <= wkTtlQty
GLPlAc                             or totAdjQty < 0)
GLPlAc                             and not zeroPickthen)
GLPlA*
GLPlA*   if NOT Greenleaf the original conditions apply.
GLPlDc*                  when      kLstSlt = '*YES'
GLPlAc                             or (client <> Greenleaf
GLPlMc                             and (wkLstSlt = '*YES'
     c                             or totAdjQty <= wkTtlQty
GLPlDc*                            or totAdjQty < 0
GLPlMc                             or totAdjQty < 0))
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
GLPlAc                   if        wkQty3 <> 0
GLPlAc                             or wkQty2 <> 0
GLPlAc                             or wkQty1 <> 0
     c                   callp     prZzUpd
     *
     c                   if        wkError = *On
     c                   eval      wkErDesc = desc(5)
     c                   callp     prPrtItmErr
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
GLPlAc                   Endif
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
GLPlA*
GLPlA*
GLPlA*    If Green Leaf and pick slot driven to zero then look for
GLPlA*    slot for remaining quantity
GLPlA*
GLPlAc                   when      client = Greenleaf
GLPlAc                             and zeroPickthen
GLPlAc                             and XDKFlag <> '*YES'
GLPlAc                   eval      zeroPickthen = *off
GLPlAc                   eval      odritemflag = *on
GLPlAc                   eval      $gcmd = '*FIRST'
GLPlA /free
GLPlA   //  if just applied to repack item "A" stat pick slot then
GLPlA   //  look for RP stat slot before moving to parent item
GLPlA                    if $gitem<>ilitm2 and $gslot<>'*NONE*  '
GLPLA                       and slstat='A' and slpick='Y';
GLPlA                       callp prGetSlot();
GLPlA                       if $gslot <> '*NONE*  ';
GLPlA                          iter;
GLPlA                       endif;
GLPlA                    endif;
GLPlA   //  get item master information for parent called from ODR
GLPlA                    $gitem = %trim(ilitm2);
GLPlA                    wkKeyItm = %trim(ilitm2);
GLPlA                    wkItmErr = prGetDKtItm();
GLPlA                    if wkError = *on;
GLPlA                       wkItmErr = ' ';
GLPlA                       wkerDesc = desc(11);
GLPlA                       callp prPrtItmErr();
GLPlA                       Return;
GLPlA                    endif;
GLPlA
GLPlA                    if itumq3 <=0;
GLPlA                       itumq3 = 1;
GLPlA                    endif;
GLPlA                    if itumq2 <=0;
GLPlA                       itumq2 = 1;
GLPlA                    endif;
GLPlA
GLPlA                    ipqqp3 = ipqqp1 * kcqty3;
GLPlA                    ipqqp2 = ipqqp1 * kcqty2;
GLPlA                    ipqqp1 = ipqqp1 * kcqty1;
GLPlA /end-free
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
650dD  //  setll ($pwhse:ipqitm) kitcomp;
650dM    setll ($pwhse:wkKeyItm) kitcomp;
650bA    dow forever = forever;

            odritemflag = *off;
GLPjA       look4regpick = '0';
GLPkA       rpslotfound  = '0';
GLPlA       OriginalWasRpk = *on;
GLPlA       zeroPickthen = *off;
GLPlA       XDKFlag = '*NO';

650dD   //    reade ($pwhse:ipqitm) kitcomp;
650dM       reade ($pwhse:wkKeyItm) kitcomp;
            if %eof(kitcomp) or not %found(kitcomp);
               leave;
            endif;

650bA       // loop through kitcomp writing adjustments for all parents
            ilitm2 = %trim(kccitm);
            ilitm3 = ' ';
650dD       // chain ($pwhse:ipqitm) kititem;
650dA       chain ($pwhse:wkKeyItm) kititem;
650bA       if %found (kititem);
650bA          if kirptp = '2';    // On-Demand Repack Item
GLPiA /end-free
GLPiA*
GLPiAC                   if        client = Greenleaf
GLPiAc                   eval      xdkflag= '*NO '
GLPiAc                   eval      $gcmd  = '*FIRST  '
GLPiAc                   eval      $gwhse = $pwhse
GLPiAc                   eval      $gitem = wkKeyItm
GLPiAc                   callp     prGetSlot
GLPiA*      Pick slot assigned to ODR item. Post adj. to Repack item
GLPlA*      if quantity is available
GLPiAC                   if        $gslot <> '*NONE*      '
     c                   if        $gwhdp > ' '
     c                   eval      kyWhdp = $gwhdp
     c                   else
     c                   eval      kyWhdp = dsItWhDp
     c                   endif
     c                   eval      ipqwhd = kyWhdp
     c                   eval      kyDisp = $gslot
     *
     c                   callp     prGetSl2
GLPlAc                   callp     prAvailSlot
GLPmDc*                  if        avail1<>0 or avail2<>0 or avail3<>0
GLPmA /free
GLPmA                    if itumq3 <=0;
GLPmA                       itumq3 = 1;
GLPmA                    endif;
GLPmA                    if itumq2 <=0;
GLPmA                       itumq2 = 1;
GLPmA                    endif;
GLPmA /end-free
GLPmAC                   if        ((avail1 * itumq2 * itumq3)
GLPmAC                               + (avail2 * itumq3)
GLPmAC                                   +  avail3) > 0
GLPiAC                   goto      #bypassODR
GLPlAC                   endif
GLPiAC                   endif
GLPkAC                   eval      odritemflag = *on
GLPkAc                   eval      $gcmd  = '*FIRST  '
GLPkAc                   eval      $gwhse = $pwhse
GLPkAc                   eval      $gitem = wkKeyItm
GLPkAc                   callp     prGetSlot
GLPkA*      Repack slot assigned to ODR item. Post adj. to Repack item.
GLPkAC                   if        $gslot <> '*NONE*      '
GLPkAc                   eval      rpslotfound  = '1'
530hAC                   eval      kcqty1       = 1
530hAC                   eval      kcqty2       = 0
530hAC                   eval      kcqty3       = 0
GLPkAC                   goto      #bypassODR
GLPkAC                   endif
GLPlAC                   endif
GLPiA /free
                  odritemflag = *on;
                  ipqqp3 = ipqqp1 * kcqty3;
                  ipqqp2 = ipqqp1 * kcqty2;
                  ipqqp1 = ipqqp1 * kcqty1;
                  wkSavItm = ' ';
                  wkKeyItm = %trim(ilitm2);
                  wkitmErr = prGetDktItm();  // get master item info
                  if wkError = *on;
                     wkItmErr = ' ';
                     wkErDesc = desc(11);
                     callp prPrtItmErr();
                     return;
                  endif;
      /end-free
GLPiA*
GLPlAC                   if        client = Greenleaf
GLPkAC                   eval      odritemflag = *on
GLPkAc                   eval      $gcmd  = '*FIRST  '
GLPkAc                   eval      $gwhse = $pwhse
GLPkAc                   eval      $gitem = wkKeyItm
GLPkAc                   callp     prGetSlot
GLPkA*      Repack slot assigned to ODR item. Post adj. to Repack item.
GLPkAC                   if        $gslot <> '*NONE*      '
GLPkAc                   eval      rpslotfound  = '1'
530hAC                   eval      kcqty1       = 1
530hAC                   eval      kcqty2       = 0
530hAC                   eval      kcqty3       = 0
GLPkAC                   goto      #bypassODR
GLPkAC                   endif
GLPmA*      Pick slot (A status) assigned to ODR item. Post adj. to Repack item
GLPmAc                   if        dsitType = 'R'
GLPmAC                   eval      odritemflag = *off
GLPmAc                   eval      $gcmd  = '*FIRST  '
GLPmAc                   eval      $gwhse = $pwhse
GLPmAc                   eval      $gitem = wkKeyItm
GLPmAc                   callp     prGetSlot
GLPmAC                   if        $gslot <> '*NONE*      '
GLPmAc                   eval      rpslotfound  = '1'
GLPmAC                   eval      kcqty1       = 1
GLPmAC                   eval      kcqty2       = 0
GLPmAC                   eval      kcqty3       = 0
GLPmAC                   goto      #bypassODR
GLPmAC                   endif
GLPmAC                   endif
GLPmA *
GLPiAC                   endif
GLPiA*
      /free
650bA          endif;
650bA       endif;

GLPjA /end-free
GLPjA*
GLPjAC*                  if        client = Greenleaf
GLPjA*
GLPjA*      Check if parent item has active pick slot Repack item.
GLPjAC*                  if        ittype = 'R'
GLPjAc*                  eval      look4regpick = '1'
GLPjAc*                  eval      xdkflag= '*NO '
GLPjAc*                  eval      $gcmd  = '*FIRST  '
GLPjAc*                  eval      $gwhse = $pwhse
GLPjAc*                  eval      $gitem = wkKeyItm
GLPjAc*                  callp     prGetSlot
GLPjA*      Pick slot assigned to ODR item. Post adj. to Repack item.
GLPjAC*                  if        $gslot <> '*NONE*      '
GLPjAC*                  goto      #bypassODR
GLPjAC*                  endif
GLPjAc*                  eval      look4regpick = '0'
GLPjA*
GLPjAC*                  endif
GLPjA*
GLPjAC*                  endif
GLPiA*
GLPiAC     #bypassODR    tag
     *
     ** Get Pick Slot For Item.
     *
     c                   eval      $gcmd  = '*FIRST  '
GFS A*
GFS AC                   if        client = Getfresh
GFS A*
GFS A*      Get Fresh wants to search for XDK slots first.
GFS AC                   if        ipqadj = 'XD'
GFS AC                   eval      $gcmd  = '*FRSTOFL'
GFS AC                   eval      xdkflag = '*YES'
GFS AC                   else
GFS AC                   eval      xdkflag = '*NO '
GFS AC                   endif
GFS A*
GFS AC                   endif
GFS A*
GLP AC                   if        client = Greenleaf
GLP A*
GLPdAC                   if        ipqadj = 'XD'
GLP A*      Greenleaf wants to search for XDK slots first.
GLP AC                   eval      $gcmd  = '*FRSTOFL'
GLP AC                   eval      xdkflag = '*YES'
GLPdAC                   else
GLPdAC                   eval      xdkflag = '*NO '
GLPdAC                   endif
GLP A*
GLP AC                   endif
GLP A*
GLP A /free

            $gcmd = '*FIRST';
            $gwhse = $pwhse;
      /end-free
GLPkAC                   if        odrItemFlag
650cAC                             and wkItType = 'R'
GLPkAC                             and (client <> Greenleaf)
GLPkA*
GLPkAC                             or  (client = Greenleaf)
GLPkAC                             and odrItemFlag
GLPkAC                             and wkItType    = 'R'
GLPkAC                             and rpslotfound = '0'
530aAC                   eval      $gitem = ilitm2
530aAC                   else
     c                   eval      $gitem = wkKeyItm
530aAC                   endif
     c                   eval      $gslot = *blanks
      /free

            if ipqdsp <> ' ';  // On-Demand Slot sent with data

               if ipqwhd = ' ';
                  ipqwhd = dsItWhdp;
               endif;

               //  verify slot passed in is valid for item
               setll (ipqwhs:ipqwhd:wkKeyItm:ipqdsp) slot4;
               if not %equal(slot4);
                 //if item not found in given slot check virtual slots
                  setll (ipqwhs:ipqwhd:ipqdsp) vslot2;
                  dow forever = forever;
                     reade (ipqwhs:ipqwhd:ipqdsp) vslot2;
                     if %eof(vslot2);
                        leave; // once end of file reached leave
                     endif;
                     setll (ipqwhs:ipqwhd:wkKeyItm:vsdisp) slot4;
                     if %equal(slot4);
                        //  virtual slot found so update imported slot
                        ipqdsp = vsdisp;
                        leave;
                     endif;
                  enddo;   //loop through vslot2
                  //if it falls through it means it did not find the
                  //passed slot.  Lets try the defined slot in item
                  //maintenance.
                  setll (ipqwhs:ipqwhd:wkKeyItm:kcdisp) slot4;
                  if not %equal(slot4);
                    //if item not found in given slot check virtual slots
                     setll (ipqwhs:ipqwhd:kcdisp) vslot2;
                     dow forever = forever;
                        reade (ipqwhs:ipqwhd:kcdisp) vslot2;
                        if %eof(vslot2);
                           ipqdsp = kcdisp;
                           leave; // once end of file reached leave
                        endif;
                        setll (ipqwhs:ipqwhd:wkKeyItm:vsdisp) slot4;
                        if %equal(slot4);
                           // virtual slot found so update imported slot
                           ipqdsp = vsdisp;
                           leave;
                        endif;
                     enddo;
                  else;
                     //found item maintenance slot so move it in
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
                  return;
               endif;
            else;
              // we should chase slot since it was not passed
              // transactions are written from the LocateSlot procedure
               callp prLocateSlot();
            endif;
650bA    enddo;

      /end-free
     *
     c                   return
     *
     p prRepackItem    e
     *
ICB A*
ICB A*----------------------------------------------------------------
ICB A*
ICB A*   Retrieve customer order number
ICB A*
ICB Ap prRtvOrdNbr     b
ICB Ad prRtvOrdNbr     pi
     *
ICBbA*  Use 1-5 as Customer number
ICBbAC                   monitor
ICBdDC*                  eval      custnumber = %dec(%subst(ipqmem:1:5):5:0)
ICBdMC                   eval      custnumber = %subst(ipqmem:1:5)
ICBbAC                   on-error
ICBdDC*                  eval      custnumber = 0
ICBdMC                   eval      custnumber = ' '
ICBbAC                   endmon
ICBbA*
     *  Loop twice to find second slash
     C                   eval      i = 0
     C                   eval      pos = 1
     C                   dou       i = 2
     C     '/'           scan      ipqmem:pos    pos
     *
     C                   if        pos <= 0
     C                   leave
     C                   endif
     *
     C                   eval      pos = pos + 1
     C                   eval      i = i + 1
     C                   enddo
     *
     C                   if        pos <= 0
     C                   return
     C                   endif
     *
     *  If it made it here, we have the second slash
     *
     *  * Check if too far in the field
     C                   if        pos > 25
     C                   return
     C                   endif
     *
     *  * Get next 6 for customer order number
     *
     *  * If blank, leave
     C                   if        %subst(ipqmem: pos: 6) = *blanks
     C                   return
     C                   endif
     *
     *  * If not numeric, leave
     C                   eval      custorder = 0
     C                   monitor
     C                   eval      custorder = %dec(%subst(ipqmem: pos: 6):6:0)
     C                   on-error
     C                   return
     C                   endmon
     *
     *  If it made it here, we have a good customer order number
     *
     *  * Check route for order for active status
      /free
          Exec Sql Select max(ohord) into :checkrte
                     from ordh5, rtehed
                    where ohrte = rhrtid
                      and ohwhse = :ipqWhs
ICBdM                 and substr(ohmisc,11,5) = :custnumber
                      and ohcord = :custorder
                      and rhstat >= '1'
                      and rhstat <= '6';

          if SQLCOD = 0;
            orderfound = '*YES';
          endif;
      /end-free
     C                   return
     *
     p prRtvOrdNbr     e
PFCcA*
PFCcA*----------------------------------------------------------------
PFCcA*
PFCcA*   Retrieve customer order number - Version 2
PFCcA*
PFCcAp prRtvOrdNbr2    b
PFCcAd prRtvOrdNbr2    pi
PFCcA*
PFCcA*  Use 1-6 of memo as customer order number
PFCcA*
PFCcAC                   monitor
PFCcAC                   eval      custorder = %dec(%subst(ipqmem:1:6):6:0)
PFCcAC                   on-error
PFCcAC                   eval      custorder = 0
PFCcAC                   endmon
PFCcA*
PFCcA*  * Check route for order for active status
PFCcA /free
PFCcA     Exec Sql Select max(ohord) into :checkrte
PFCcA                from ordh5, rtehed
PFCcA               where ohrte = rhrtid
PFCcA                 and ohwhse = :ipqWhs
PFCcA                 and ohcord = :custorder
PFCcA                 and rhstat >= '1'
PFCcA                 and rhstat <= '6';
PFCcA
PFCcA     if SQLCOD = 0;
PFCcA       orderfound = '*YES';
PFCcA     endif;
PFCcA
PFCcA /end-free
PFCcAC                   return
PFCcA*
PFCcAp prRtvOrdNbr2    e
     *
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

     *   Call interface to do update.

     c                   eval      $dricommand = '*SLOT'
     c                   eval      $drisubcmd  = '%ADJUSTORD'
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

     c                   when      $drireturn <> '*OK'
GLPlAc                             and $drireturn <> 'XDKEXIST'
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
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Item Not Found In Dakota. Not Adjusted.
Alias Link Rcd Missing. Not Adjusted.
Pick Slot Not Found. Not Adjusted.
Item Verify Failed. Not Adjusted.
Item Adjustment Not Posted.
DRI Interface Error. Slot Not Found.
Adj Code Not Found, Not Adjusted.
Quantity is Zero, Not Adjusted.
Warehouse Not Found, Not Adjusted.
DRI Interface Error.
Parent for JIT Rpk missing.Not Adjusted.
