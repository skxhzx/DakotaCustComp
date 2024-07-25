      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M136003U     Purchase Order Receiving Entry
     *  25 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    02/16/16  LMC  7.00
     *      - Created. Copied from M13600U - phase 1 gui receiving
     *      - Returns values for displaying correct fields on entry screen
     *      - Incorporated UCI receiving logic PO137/PO237
     *      - using the bypassedit for multiple purposes.
     *        for UCI receiving - this flag will allow us to know that the
     *        user is sending subsequent uci's. NOT THE FIRST SCAN.
700aA*    04/19/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
700bA*    04/20/16  LMC  7.00b
     *      - Fix: Only execute exsr zzdlcw logic if user has not
     *        entered individual catchweights.
     *        If user has entered/scanned individual weights, we want
     *        to keep these detail records.
700cA*    05/25/16  LMC  7.00c
     *      - Created. Copied from M136002U - phase 2 gui receiving
     *      - Added Branded Item Logic
     *      - Changed the UPC exist message for better information.
     *      - Fixed CW over fields need to be stored in pirhold file.
     *
700dA*    06/22/16  LMC  7.00d
     *      - Fix - set pndwtchkw = Y, if weight entered is changed
     *        The override checkbox was staying on after the user
     *        changed the weight, anytime the weight is changed we
     *        will reset the ND for the warning.
700eA*    07/11/16  LMC  7.00e
     *      - Enh - Adding 2 new parms to be sent to PO840.
     *        Outside Storage, needs the session id and the user.
     *      - Enh - force ossprint to Y when client has Use Generic
     *        License = 'N' and outside storage has been selected.
     *      - Enh - Branded item sent to PO840 if needed.
700fA*    10/14/16  LMC  7.00f
     *      - Enh: Find the double quotes replace with \".
     *        Then gui will be able to process the json without error.
700gA*    12/16/16  DAS  7.00g
     *      - Fix: Return error if date conversion fails.
700hA*    12/21/16  KDE/LMC  7.00h
     *      - Fix: Set Expiration date for first pass
     *        This problem existed for mfg dated items
     *        copied logic from zzupd1 into zzchk1 - w1exdt is not
     *        being populated until after the check.
700iA*    11/04/16  LMC  7.00i
     *      - Enh: UPC file changed need to load additional fields for
     *        UPC by UOM.
710aA*    01/30/17  LMC      7.10a
     *      - Fix: Edit for zero date before executing 700h code
710bA*    02/03/17  LMC      7.10b
     *      - Fix: 700h mfg date edits are incorrect - edits fail
     *        if # of days out is zero.
710cA*    04/13/17  LMC      7.10c
     *      - Enh: for clients that use Generic License = 'N', and
     *        receiving OSS, they will be required to scan/enter
     *        a license, just as if they had receiving options set
     *        to use Generic License = 'Y'.
710dA*    04/27/17  LMC      7.10d
     *      - Enh: We are enhancing the date error messages to make
     *        them more meaningful for the receiver.
710eA*    05/02/17  LMC  7.10e
     *      - Enh: Added edit for clients who have new option
     *        Allow Gui multiple pallet Receiving = 'N'.
     *        # of Pallets can only be 1, in this situation.
710fA*    06/15/17  LMC  7.10f
     *      - Enh: Added edit for same UOM in normal and breakdown.
     *        In gui we don't know which uom to apply the receipt to
     *        for license entry, so we will stop them here.
710gA*    09/26/17  LMC  7.10g
     *      - Enh: Allow for a user to select cross dock XD status.
     *        treat the receipt just like if the podtl pdspcl field
     *        was set to XD.
710hA*    10/09/17  LMC  7.10h
     *      - Fix: Found the issue where date fields where not getting
     *        populated correctly. If the upc that was scanned was
     *        invalid, we still let the user load it if the click on
     *        the item to receive, but the upc check was failing, and
     *        setting on error, but not loading the error message.
     *        we allow the user to load an invalid upc code.
     *        Problem was the rest of the edits were not occurring do
     *        to error being on, but no message sent back to gui, so
     *        the gui program thought everything was good to go.
     *        If the user is loading an invalid upc code, we will no
     *        longer set on the error indicator.
710iA*    10/19/17  LMC  7.10i
     *      - Fix: If user enters an invlaid date, need to edit for
     *        that before it calls clcdur2.
720aA*    05/25/18  LMC  7.20a
     *      - Fix: Notlive departments were not processing correctly.
720bA*    07/31/18  LMC  7.20b
     *      - Fix: Non stock items were not processing correctly.
720cA*    08/24/18  LMC  7.20c
     *      - Fix: Allow SSB item to be received to pick slot.
     *        when I installed branded item logic, I had an error
     *        using the wrong field to get the pick slot.
720dA*    08/03/16  LMC  7.20d
     *      - Enh: UCI Tracking.
730aA*    02/28/19  LMC  7.30a
     *      - Enh: Send the user signed on in gui to RC161, so the
     *        porcv file will have the actual user who did receipt
     *        for non stock items.
730bA*    03/01/19  LMC  7.30b
     *      - Fix: Not live receipt must be # of pallets = 1.
730cA*    04/25/19  LMC  7.30c
     *      - Enh: Limit weight entry to 99999.99. because pocwexcp
     *        can only handle a weight this large.
730dA*    06/05/19  LMC  7.30d
     *      - Fix: Pick slot Receiving on ssb, was not closing
     *        transaction.
730eA*    08/07/19  LMC  7.30e
     *      - Enh: Add the ability to auto load all uci's that have
     *        been created for canopy gs1 labels. so user only has
     *        to scan one label in the set, and we auto load the rest.
730fA*    09/13/19  LMC  7.30f
     *      - Enh: Limit extended wgt to 99999.99. because pocwexcp
     *        can only handle a weight this large. This came up
     *        because a user entered qty received of 578 on an item
     *        that had a shipping weight of 1125.00.
730gA*    10/28/19  LMC/RH  7.30g
     *      - FIX: Use ITFLGD to test for earlier expiration date
     *        error, was not processing if override was taken for
     *        not enough shelf life days.
730hA*    11/01/19  LMC     7.30h
     *      - ENH: Send user to RC160. This will allow RC160 to use
     *        the actual user and not the #curruser.
740aA*    05/01/20  LMC     7.40a
     *      - ENH: Condition breakdown2 weight calculations to execute
     *        only if breakdown1 & 2 vaules exist.
740bA*    06/29/20  LMC     7.40b
     *      - ENH: Send pick slot receiving flag to RC160.
740cA*    07/17/20  LMC     7.40c
     *      - ENH: Adding new receiving option edits.
     *      - Lot required if turned on at the item level. This was
     *        previously handled by a client modification.
     *        I will leave the client mod, but add the new option so
     *        anyone who needs this going forward will use the new
     *        option and not require a client custom mod.
     *      - Expiration date error/warning
     *        There was previously a mod for this for ADF,FPR and CFI
     *        I will leave the client mod, but add the new option so
     *        anyone who needs this going forward will use the new
     *        option and not require a client custom mod.
740dA*    07/27/20  LMC     7.40d
     *      - ICB and ISupply when printing oss license, # of pallets
     *        must be one. Since we default the oss license for the
     *        license entry. Found this in po236.
740eA*    08/12/20  LMC     7.30e
     *      - ENH: Init numeric fields in $mparm - appears to be the
     *        cause of decimal data error at statement *init.
740fA*    09/08/20  LMC     7.40f
     *      - ENH: Moved *system record to optionrec2.
     *        CW vairiances were not calculating correctly.
740gA*    12/30/20  LMC  7.40g
     *      - Enh: Added edit for recieving ssb item when there is
     *        No breakdown uom setup on base item.
750a *    06/03/21  LMC  7.50a
     *      - Enh: CW variances for breakdown were not being
     *        calculated.
750b *    06/30/21  LMC  7.50b
     *      - Enh: Directed putaway call to rc160 has to happen
     *        in the zzchk1 routine, doing it in zzupd1 is too late
     *        if there are no slots.
750cA*    07/14/21  MLB/LMC  7.50c
     *      - Enh: Revised routine, ZZGET1 to set PODTL numeric fields
     *        to zeros when record isn't found. Found at A&D who does
     *        R=Replace updates on their p/o's.
750d *    07/23/21  LMC  7.50d
     *      - Enh: The expiration date in not calculated in zzchk1
     *        before the directed logic executes, need to add that
     *        into the special receiving routine.
750e *    01/03/22  LMC  7.50e
     *      - Enh: Check for Barcode maintenance for the po vendor
     *        if found only load the GTIN into the upc file.
770b *    08/08/23  RH   7.70b
     *      - Enh: Add error if dept = 'UNK' for FreshByte default.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    06/08/16  LMC DRYa
     *      - Enh: Bypass hard edit on expiration date. User will
     *        get this warning instead.
     *        "Item cannot be accepted - Use by date"  will allow them
     *        to receive expired product on date sensitive items, just
     *        as it does on Mfg Dated items, with the warning "Not
     *        Enough Shelf life remaining"
     *----------------------------------------------------------------
     * Client Custom Revisions: A&D
     *
ADFaA*    04/21/17  LMC Adfa
     *      - Enh: Bypass hard edit on expiration date. User will
     *        get this warning instead.
     *        "Item cannot be accepted - Use by date"  will allow them
     *        to receive expired product on date sensitive items, just
     *        as it does on Mfg Dated items, with the warning "Not
     *        Enough Shelf life remaining"
     *----------------------------------------------------------------
     * Client Custom Revisions: Colony Foods
CFIaA*    05/16/18  LMC  CFIa
     *      - Enh: Bypass hard edit on expiration date. User will
     *        get this warning instead.
     *        "Item cannot be accepted - Use by date"  will allow them
     *        to receive expired product on date sensitive items, just
     *        as it does on Mfg Dated items, with the warning "Not
     *        Enough Shelf life remaining"
CFIb *    08/18/20  RTR  CFIb
     *      - Added CFI to BIR mod to log UPC codes.
     *      - This was mod CFIa in PO232, was missing here.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
ACCaA*    01/03/19  LMC  ACCa
     *      - Revised pgm to not issue expiration date warning/days
     *        out if the days out is 999. Per Roxanne.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWTaA*    02/27/19  LMC  SWTa
     *      - Client must enter a lot code on an item that is set to
     *        Lot code item (Y). Per Roxanne.  IMLOT
SWTbA*    01/24/22  RH   SWTb
     *      - Only allow Status QU, XD or blank,
     *        Decided during set up for Whse 20.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BADaA*    08/28/19  LMC  BADa
     *      - Client must enter a lot code on an item that is set to
     *        Lot code item (Y). Per Roxanne.  IMLOT
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPaA*    10/02/19  LMC  CSPa
     *      - Make sure coastal itdesg = JIT is treated like crossdock
CSPbA*    07/27/20  LMC  CSPb - found in PO236 cspa 07/10/19 RH
     *      - When calling DRISLOT with %CRTXDOCK, force aisle
     *        to be 'PC ' if pdspcl = 'XD'.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRaA*    06/09/20  RH   FPRa
     *      - Enh: Bypass hard edit on expiration date.  Add to ADFa
     *        mod.
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Sequence
     *      pPOItem     Item
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemdef   if   e           k disk
     Fdesigsp   if   e           k disk
     Fslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
     Fslot3     if   e           k disk
     F                                     rename(slrec:s3rec)
     Fpocwexcp  uf a e           k disk    Prefix(cw_) rename(exrec:cwexrec)
     Fpoexcp    if   e           k disk
     Fpoctype   uf a e           k disk
     Fupclog    if a e           k disk
     Fupc3      uf a e           k disk
     Fupc1      if   e           k disk
     F                                     rename(uprec:u1rec)
     Fpirhold   uf a e           k disk
     Flabel2    if   e           k disk    prefix(lb_)
730eAFuciwork   uf   e           k disk    prefix(can_)


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const

     D calcpti         pr                  extpgm('CALCPTI')
      * Input
     D   pGTIN                             like($pgtin)
     D   pLOT                              like($pbclot)
     D   pPackDate                         like(pmfgdt)
     D   pPTI                              like(pppti)
     D po840           pr                  extpgm('PO840')
      * Input
     D   oWhse                             like(pWhse)
     D   oWhdp                             like($itwhdp)
     D   oOCode                            like(osscode)
     D   oPlates                           like(possplates)
     D   oPrint                            like(ossprint)
     D   oLcns                       15
     D   oExpd                             like(expd)
     D   oStat                        2
     D   oDev                        10
     D   oItem                             like($ititem)
     D   oSTyp                             like($itstyp)
     D   oItdesc                           like($itdesc)
700eAD   oSessid                           like(pSessId)
700eAD   oUser                             like(pUser)

     D m13700u         pr                  extpgm('M13700U')
     D  message                      99
     D  session                      40
     D  user                         10
     D  pgm                          20
     D  whse                          3p 0
     D  PO                            9
     D  seq#                          5p 0
     D  item                         15
     D  lcns                         15
     D  qty                           5p 0
     D  uom                           5
     D  done                          1

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtbar
      /copy qcopysrc,p.cvtdte
700cA /copy qcopysrc,p.GETBRAND

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D a13             s              1    dim(13)
     D lbl             s             13    dim(4) ctdata perrcd(1)
     D typ             s             10    dim(1) ctdata perrcd(1)
     D cwt             s             27    dim(3) ctdata perrcd(1)
     D $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#birite
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#finkle
      /copy qcopysrc,id#renzi
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#sofo
      /copy qcopysrc,id#yhata
      /copy qcopysrc,id#yhahilo
      /copy qcopysrc,id#jordano
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#glazier
      /copy qcopysrc,id#icb
      /copy qcopysrc,id#westsid
ADFaA /copy qcopysrc,id#adf
CFIaA /copy qcopysrc,id#cfi
ACCaA /copy qcopysrc,id#acc
SWTaA /copy qcopysrc,id#swt
BADaA /copy qcopysrc,id#bad
CSPaA /COPY QCOPYSRC,Id#Coastal
FPRaA /copy qcopysrc,id#fpr
740dA /COPY QCOPYSRC,Id#ISupply

     *----------------------------------------------------------------
     *  P/O Detail Misc. /copy mbrs
     *
      /copy qcopysrc,podm1_rtx
      /copy qcopysrc,podm2_rtx
      /copy qcopysrc,podm3_rtx
      /copy qcopysrc,podm4_rtx
      /copy qcopysrc,podm5_rtx
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             20
     D pbypassedit     s              1
     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D pPOItem         s             15
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     Dblanklcns        s             15
720dAD blank6          s              6
     D xdockkey        s             35
     D woslot          s             12
     D woqor           s             15
     D woostk          s              1
     D NDFifo          s              1
     D NDLot           s              1
     D NDQord          s              1
     D NDcw            s              1
     D NDcwex          s              1
     D NDexpd          s              1
     D NDMfgd          s              1
     D NDlive          s              1
     D NDpti           s              1
     D NDBrand         s              1
700iAD Ntype           s              7

      * these were copies from Po232 - delete what isn't needed
     D $ldwgt          s              9  2
     D $lflag          s              1
     D $lseq           s              5  0
     D $lum1           s              5
     D $lum2           s              5
     D $lum3           s              5
     D $lven           s             11  0
     D $lvitm          s             15
     D $lvnam          s             40
     D $pw1pti         s              4  0
     d $prsqt          s              7  0
     D $swhse          s                   like(pwhse)
     D $msgf           s             10
     D $unext          s             13  0
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #oswgt          s              7  2
     D #oswt2          s              7  2
     D #oswt3          s              7  2
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum2q          s              3s 0
     D #oum3           s              2
     D #oum3q          s              3s 0
     D #oven#          s             10  0
     D #sitem          s             15
     D caltol1         s             11  4
     D caltol2         s             11  4
     D caltol1x100     s             13  4
     D caltol2x100     s             13  4
     D chk4err         s               n
     D ckexdt          s              8  0
     D ckqrc1          s                   like(pdqrc1)
     D clear           s              5  0
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D cwcalc          s              1  0
     D date1           s              8  0
     D date16          s              6  0
     D date2           s              8  0
     D date2o          s              6  0
     D date26          s              6  0
     D done            s              1
     D dtfrmt          s              1  0
     D e               s              2  0
710fDD*eof             s              1
700gAD errDate         s                   like(pMessage)
     D exdtj           s              5  0
     D expdj           s              5  0
700cDD*exwgt           s              9  2
     D forevr          s              1
     D full            s              1
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D help            s              5  0
700cDD*hirng           s              9  2
     D hivar           s              9  2
     D hostcw0         s              7  0
     D hostcwa         s              7
     D hostcw2dec      s              7  2
     D hostUnitWgt     s              9  4
     D hvskp           s              1
     D iaflag          s              1
     D iatest          s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
     D kgs2lbs         c                   2.20462262
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D ltstd6          s              6  0
     D ltstd8          s              8  0
     D glzmfd          s              8  0
     D lcnsExists      s               n
     D lvskp           s              1
700cDD*lwrng           s              9  2
     D lwvar           s              9  2
     D mfdtj           s              5  0
     D mfgd            s              8  0
     D netdays         s              3  0
     D maxqty          s                   like(pdqrc1)
     D nxtscr          s              3
     D ocode           s              8
     D ovrrid          s              1
     D part            s              1
     D poppcs          s                   like($lpcs)
700cDD*prg1c           s              4  3
700cDD*prg2c           s              4  3
     d pplot           s             20
     d pppti           s              4  0
     d ptinodate       s              6P 0
     D qtyDiff         s              5  0
     D qtyord          s              5  0
     D qtyord1         s              5  0
     D qtyord2         s              5  0
     D qtyord3         s              5  0
     D qtyrcv          s              5  0
     D qtyrcv1         s              5  0
     D qtyrcv2         s              5  0
     D qtyrcv3         s              5  0
     D rcvpocomplete   s               n
     D rcvUnitWgt      s             11  4
     D recv            s              1
     d rcverr          s                   like(error)
     D rolldn          s              5  0
     D rollup          s              5  0
700gAD savDate         s                   like(pexmf)
     D sclear          s              1
     D sdesig          s              1
     D ssbflg          s              1
     D stop            s              1
     D svcwen          s              1
     D svcwfr          s              1
     D svcwtp          s              1
     D svexck          s              1
     D svhi            s              2  0
700aAD svopwum         s                   like(opwum)
     D svqrc1          s                   like(pdqrc1)
     D svqrc2          s                   like(pdqrc2)
     D svqrc3          s                   like(pdqrc3)
     D svrupc          s              1
710eAD svmplt          s              1
     D svtie           s              4  0
     d sprcv           s              1
     D temp10          s             10
     D tmpwgt          s              9  2
     D today           s              8  0
     D todayo          s              6  0
     D todyj           s              5  0
     D uciexists       s               n
     D unexta          s             13
     D uxflag          s              1
     D vrfycw          s              1
     D wgtDiff         s             11  4
     D whse            s              3  0
     D wkmday          s              3  0
     D wkwhse          s                   like(pwhse)
     D woexdt          s              8  0
     D wofifo          s              8  0
     D womfdt          s              8  0
     D work2           s              2
     D work4           s              4
720dAD workupc         s                   like(upupc)
     D wotcw           s              9  2
     D wrttyp          s              1
     D zmflag          s               n
     D zmsflag         s               n
     D $cstr           s             30
     D wocrcv          s             27
     D w1note          s             15
      * screens from entry form
     d Inupc           s             50
     d pqty1           s              5p 0
     d pqty2           s              5p 0
     d pqty3           s              5p 0
     d p#plt           s              5p 0
     d pexmf           s             10
     d pfifo           s             10
     d pwgt            s              9p 2
     d plbskilo        s              1
     d pavg            s              1
     d InSlot          s             12
     d pmfgdt          s              6p 0
     d bcprodd         s              6p 0
     d plot            s             30
     d pbrand          s             10
     d ppti            s              4p 0
     d $pcmd           s              8
     d $prtn           s              8
     d $pupc           s             20
     d $lexpdat        s              6s 0
     d $lmfrdat        s              6s 0

     d ulcns           s             15
     d uqty            s              5p 0
     d uuom            s              5
     d udone           s              1
     d uhodata         s                   like(Hodata)

     D expdwarn        s              1
     D expdovr         s              1
     D difflot         s               n
     D diffexpd        s               n
     D lastseq         s                   like($lnseq)
     D licinfoupd      s               n
     D lotwarn         s              1
     D lotovr          s              1
     D saveexpd        s                   like(expd)
     D saveqty         s                   like(sdqrc1)
     D savewgt         s                   like(w1dwgt)
     D savew1uci       s                   like(uciscanned)
     D templcns        s             15
     D UPCwarn         s              1
     D UPCovr          s              1
     D $code           s             10
     D $crew           s              6
     D $emp#           s              5  0
     D $fnam           s             15
     D $init           s              1
     D $lnam           s             20
     D $nhrs           s             31
     D $rtn            s              8
     D $shft           s              6
     D $styp           s              1
     D $whdp           s              5
     D $whse           s              3  0
750bAD rc160good       s               n
     *----------------------------------------------------------------
     *  Working variables
     *
     D rtxall9item     C                   const('9999999999')
     D digits          c                   const('0123456789')
     D pos             s              2  0
     D day             s              2
     D yr              s              2
     D wkdate          s              6
     D pqtchkw         s              1
     D pqtchk1w        s              1
     D pdtchkw         s              1
     D pdtchk2w        s              1
     D pdtchk3w        s              1
     D pdtchk4w        s              1
     D pwtchkw         s              1
     D pptichkw        s              1
     D pNDqtchkw       s              1
     D pNDqtchk1w      s              1
     D pNDdtchkw       s              1
     D pNDdtchk2w      s              1
     D pNDdtchk3w      s              1
     D pNDdtchk4w      s              1
     D pNDwtchkw       s              1
     D pNDptichkw      s              1
     D pw1stat         s              2
     D posscode        s              1
     D possprint       s              1
     D possplates      s              4  0
     D possdev         s             10
     D ppsrusr         s              1
     D pdecvalue       s             15
     D pokey           s             50
700bAD pokeyt          s             50
     D plcns           s             15
700cAD pBrandItm       s             15
     D pdifflot        s              1
     D pdiffexpd       s              1
     D pUCIDone        s              1
700cAD bCmd            s             10
700cAD bBrand          s             10
700cAD bParentitm      s             15
700cAD bBranditm       s             15
700cAD bBrandFlg       s              1
700cAD rc160Itm        s             15
700eAD ossItem         s             15
700fAd dblqte          s              1    inz('"')
700fAd rpldblqte       s              2    inz('\"')

      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLLCN
      /copy qcopysrc,C#PIRHLDUC
      /copy qcopysrc,C#PIRHLDUE
     *----------------------------------------------------------------
     * Data structure
     *
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
710eA*    OPMPLT  -  Allow Gui Multiple Pallet Receiving (Y/N)        (Y/N)
740cA*    OPPEXP  -  Allow Partial Export in gui Receiving  (Y,N)     (Y/N)
740cA*    OPLOTR  -  Lot required if lot item               (Y,N)     (Y/N)
740cA*    OPPSRA  -  Allow Pick slot receiving              (Y,L,N)   (Y/N)
740cA*    OPPLTD  -  Default pallets to 1                   (Y,N)     (Y/N)
740cA*    OPOSSA  -  Allow offsite storage receipt          (Y,N)     (Y/N)
740cA*    OPSQTO  -  Show qty ordered during receiving      (Y,N)     (Y/N)
740cA*    OPBRKA  -  Allow breakdown qty to be received     (Y,N)     (Y/N)
740cA*    OPEXPE  -  Expiration date Error or Warning       (E,W)     (Y/N)
740cA*    OPSPN1  -  Spin pallet for license placement      (Y,N)     (Y/N)
740cA*    OPSPN2  -  Spin pallet length                               (Y/N)
740cA*    OPSPN3  -  Spin pallet text                                 (Y/N)
     *
     D*opdata          ds
     D optionrec       ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
740cAD optionrec1      ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
710eAD  opmplt                37     37
740cAD  oppexp                38     38
740cAD  oplotr                39     39
740cAD  oppsra                40     40
740cAD  oppltd                41     41
740cAD  opossa                42     42
740cAD  opsqto                43     43
740cAD  opbrka                44     44
740cAD  opexpe                45     45
740cAD  opspn1                46     46
740cAD  opspn2                47     49  0
740cAD  opspn3                50     59
     *  *SYSTEM  -  System options.
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance in Truck Builder (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count in Truck Builder. (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPPKDY  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -
     *    OPWRNCR -  Check CW var during RCV individual Entry
     *    OPICWR  -  Check CW count during RCV individual Entry
     *    OPTRAX  -  Using TRAX module (Y/N).
     *
740fAD optionrec2      ds
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
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opishsa               33     35
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
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
     D optiondrec      ds
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
     *
     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     78
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                16     27
     *
     D  ermday                 1      2p 0
     D  ermfdt                 3      6p 0
     D  erexdt                 7     10p 0
     D  erltst                11     14p 0
     D  erdday                15     16p 0
     D  eruday                17     18p 0
     D  $ec                    1      2p 0
     *
     D  erused                 1      4p 0
     D  erdisd                 5      6p 0
     D  erusrd                 7      8p 0
     D  ersell                 9     12p 0
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erentd                 1      5p 0
     D  ertod                  6     10p 0
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Constants
     D move1           c                   const('MOVEIN PICK')
     D move2           c                   const('MOVEIN OVERFLOW')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @pwd            c                   const('CHKLIST')
     D @fmtit          c                   const('FRMTIT')
     D @crtrcv         c                   const('CRTRCVTRN')
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
     *
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
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lmfr#                22     32  0
     D  $lmfritem             33     47
     D  $ldakitem             48     62
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     *   Redefine key
     D  $mwhs3                19     20p 0
     D  $mpo3                 21     29
     D  $mseq                 30     32p 0
     D  $mitm3                33     47
     D  $mqyr1                48     50p 0
     D  $mqyr2                51     53p 0
     D  $mqyr3                54     56p 0
     D  $mcwte                57     59p 0
     D  $mcwtt                60     64p 2
     D  $mcwta                65     68p 2

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
     D savever#        s                   like($itver#)
     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
     D pdmrec        E Ds                  Extname(podtlm)
     D phrec         E Ds                  Extname(pohdr)
     D oprec         E Ds                  Extname(options)
     D umrec         E Ds                  Extname(unmesr)
     D*uprec         E Ds                  Extname(upc)
     D ossrec        E Ds                  Extname(ossloc)
     D opdrec        E Ds                  Extname(optiond)
     D horecreload   E Ds                  Extname(pirhold)
     D horecuci      E Ds                  Extname(pirhold) prefix(u_)
700bAD horecct       E Ds                  Extname(pirhold) prefix(ct_)
720dAD uprecuom      E ds                  extname(upc) inz(*EXTDFT)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    pqty1
     c                   parm                    pqty2
     c                   parm                    pqty3
     c                   parm                    p#plt
     c                   parm                    pexmf
     c                   parm                    pfifo
     c                   parm                    pmfgdt
     c                   parm                    pwgt
     c                   parm                    plbskilo
     c                   parm                    pavg
     c                   parm                    ppti
     c                   parm                    plot
     c                   parm                    pbrand
     c                   parm                    pqtchkw
     c                   parm                    pNDqtchkw
     c                   parm                    pqtchk1w
     c                   parm                    pNDqtchk1w
     c                   parm                    pdtchkw
     c                   parm                    pNDdtchkw
     c                   parm                    pdtchk2w
     c                   parm                    pNDdtchk2w
     c                   parm                    pdtchk3w
     c                   parm                    pNDdtchk3w
     c                   parm                    pdtchk4w
     c                   parm                    pNDdtchk4w
     c                   parm                    pwtchkw
     c                   parm                    pNDwtchkw
     c                   parm                    pptichkw
     c                   parm                    pNDptichkw
     c                   parm                    pw1stat
     c                   parm                    posscode
     c                   parm                    possprint
     c                   parm                    possplates
     c                   parm                    possdev
     c                   parm                    pdecvalue
     c                   parm                    pbypassedit
     c                   parm                    ppsrusr
     c                   parm                    plcns
700cAc                   parm                    pBrandItm
     c                   parm                    pdifflot
     c                   parm                    pdiffexpd
     c                   parm                    pUCIDone

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
700gA    errDate = '';
         puser = %xlate(xlower: xupper: puser);
         plcns = %xlate(xlower: xupper: plcns);
700cA    pBrandItm = %xlate(xlower: xupper: pBrandItm);
         if pdifflot = 'Y';
           difflot = *on;
         else;
           difflot = *off;
         endif;
         if pdiffexpd = 'Y';
           diffexpd = *on;
         else;
           diffexpd = *off;
         endif;

         if pbypassedit <> 'Y';
           $lsavetrn = savetrn;
           exsr zzrcvpocheck;

           // uci complete license will get pirhold to set all the values
           Select;
             when pucidone = 'Y';
               // retrieve the original pirhold podtl record for uci
               pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                     + %trim(pPOItem) + 'UCIHOLD';
               exec sql select * into :horecreload
                    from pirhold
                    where hosess = :pSessId
                      and hotype = 'PODTL'
                      and hokey  = :pokey;

               // if we don't find a record - we have a problem
               If sqlstt = sqlSuccess;
                 pirhldPOds = hodata;
               endif;
             other;
               // initizlize fields from entry form
700cD          //w1upcd = Inupc;
               w1qrc1 = pqty1;
               w1qrc2 = pqty2;
               w1qrc3 = pqty3;
               w1plts = p#plt;
               KiloLbs = plbskilo;
               $ldecvalue = pdecvalue;

               select;
                 when pbypassedit = 'U';
                   if NDexpd <> 'Y' and pexmf <> ' ';
                     // date sent in from M19600 is formatted MMDDYY already
700gA                monitor;
                       w1exdt= %dec(pexmf:6:0);
700gA                on-error;
700gA                  w1exdt= 0;
700gA                  errDate  = 'Invalid expiration date '
700gA                           + '(pexmf=' + %trim(pexmf) + ')';
700gA                endmon;
                   endif;
                 other;
                   if NDexpd <> 'Y';
700gA                savDate = pexmf;
                     // need to convert this for expd date field
                     pos = %scan('/':pexmf);
                     if pos > 0;
                       day = %subst(pexmf:pos+1:2);
                       yr  = %subst(pexmf:pos+4:2);
                       pexmf = %replace(day:pexmf:pos:2);
                       pexmf = %replace(yr:pexmf:pos+2:4);
                       wkdate = %trim(pexmf);
                       if wkdate <> ' ';
700gA                    monitor;
                           w1exdt= %dec(wkdate:6:0);
700gA                    on-error;
700gA                      w1exdt= 0;
700gA                      errDate  = 'Invalid expiration date '
700gA                               + '(pexmf=' + %trim(savDate) + ', '
700gA                               +  'wkdate=' + %trim(wkdate) + ')';
700gA                    endmon;
                       else;
                         w1exdt = 0;
                       endif;
                     else;
                       w1exdt = 0;
                     endif;
                   endif;
               endsl;
               // need to convert this for fifo date field

700gA          savDate = pfifo;
               pos = %scan('/':pfifo);
               if pos > 0;
                 day = %subst(pfifo:pos+1:2);
                 yr  = %subst(pfifo:pos+4:2);
                 pfifo = %replace(day:pfifo:pos:2);
                 pfifo = %replace(yr:pfifo:pos+2:4);
                 wkdate = %trim(pfifo);
                 if wkdate <> ' ';
700gA              monitor;
                     w1fifo= %dec(wkdate:6:0);
700gA              on-error;
700gA                w1fifo= 0;
700gA                errDate  = 'Invalid fifo date '
700gA                         + '(pfifo=' + %trim(savDate) + ', '
700gA                         +  'wkdate=' + %trim(wkdate) + ')';
700gA              endmon;
                 else;
                   w1fifo = 0;
                 endif;
               else;
                 w1fifo = 0;
               endif;

               w1dwgt = pwgt;
               w1avg  = pavg;
               w1slot = InSlot;
               w1stat = pw1stat;
710gA          if w1stat = 'XD';
710gA            w1plts = 1;
710gA            p#plt  = 1;
710gA          endif;
               osscode =  posscode;
700cA          BrandedItm =  pBrandItm;
700eA          // need to force ossprint if use generic license = 'N' and
700eA          // osscode has been selected
710cA          // We will treat oss receiving as if the client has
710cA          // generic license set to 'Y'
710cA          if posscode <> ' ';
710cA            eval lflag = *on;
710cA          endif;
700eA          if lflag = *off and posscode <> ' ';
700eA            possprint = 'Y';
700eA            possplates = p#plt;
700eA            possdev = '*JOB';
700eA          endif;
               ossprint = possprint;
               ossplates = possplates;
               ossdev = possdev;
               psrusr = ppsrusr;

               select;
                 when pbypassedit = 'U';
                   if NDmfgd <> 'Y' and pexmf <> ' ';
700gA                monitor;
                       w1mfdt= %dec(pexmf:6:0);
700gA                on-error;
700gA                  w1mfdt= 0;
700gA                  errDate  = 'Invalid Mfg date '
700gA                           + '(pexmf=' + %trim(pexmf) + ')';
700gA                endmon;
                   endif;
                 other;
                   if NDmfgd <> 'Y';
700gA                savDate = pexmf;
                     // need to convert this for mfg date field
                     pos = %scan('/':pexmf);
                     if pos > 0;
                       day = %subst(pexmf:pos+1:2);
                       yr  = %subst(pexmf:pos+4:2);
                       pexmf = %replace(day:pexmf:pos:2);
                       pexmf = %replace(yr:pexmf:pos+2:4);
                       wkdate = %trim(pexmf);
                       if wkdate <> ' ';
700gA                    monitor;
                           w1mfdt= %dec(wkdate:6:0);
700gA                    on-error;
700gA                      w1mfdt= 0;
700gA                      errDate  = 'Invalid Mfg date '
700gA                               + '(pexmf=' + %trim(savDate) + ', '
700gA                               +  'wkdate=' + %trim(wkdate) + ')';
700gA                    endmon;
                       else;
                         w1mfdt = 0;
                       endif;
                     else;
                       w1mfdt = 0;
                     endif;
                   endif;
               endsl;

               w1lotc = plot;
700cA          // if branded item sent, needs to get brand from ITEMBRD
700cA            bCmd = '*GET4BITM';
700cA            bBrand = ' ';
700cA            bParentItm = ' ';
700cA            bBrandItm = pBrandItm;
700cA            bBrandFlg = ' ';
700cA          if pBrandItm <> ' ';
700cA            GetBranded(bCmd: pwhse: bParentItm: bBrand:
700cA                       bBrandItm: bBrandFlg);

700cA          endif;
700cA            if bBrand <> ' ';
700cA              w1Brand = bBrand;
700cA            else;
                   w1brand= pbrand;
700cA            endif;
               w1pti  = ppti;
           endsl;
           $PCMD = '*CHANGE ';

700hA      // setup w1exdt if zero for first pass
700hA      //if w1exdt = *zeros;
700hA      //   monitor;
700hA      //     w1exdt= %dec(pexmf:6:0);
700hA      //   on-error;
700hA      //     w1exdt= 0;
700hA      //   endmon;
700hA      //endif;

           // execute screen processing
           exsr sc1;

         endif;
700fA    // let's check for our double quotes and replace
700fA    // woitem
700fA    pos = %scan(dblqte: woitem);
700fA    dow pos > 0;
700fA       woitem = %replace(rpldblqte: woitem: pos: %len(dblqte)) ;
700fA       if (pos+%len(rpldblqte) > %len(woitem));
700fA          pos = 0;
700fA       else;
700fA          pos = %scan(dblqte: woitem: pos+%len(rpldblqte));
700fA       endif;
700fA    enddo;
700fA    // wositm
700fA    pos = %scan(dblqte: wositm);
700fA    dow pos > 0;
700fA       wositm = %replace(rpldblqte: wositm: pos: %len(dblqte)) ;
700fA       if (pos+%len(rpldblqte) > %len(wositm));
700fA          pos = 0;
700fA       else;
700fA          pos = %scan(dblqte: wositm: pos+%len(rpldblqte));
700fA       endif;
700fA    enddo;
700fA    // wodsc1
700fA    pos = %scan(dblqte: wodsc1);
700fA    dow pos > 0;
700fA       wodsc1 = %replace(rpldblqte: wodsc1: pos: %len(dblqte)) ;
700fA       if (pos+%len(rpldblqte) > %len(wodsc1));
700fA          pos = 0;
700fA       else;
700fA          pos = %scan(dblqte: wodsc1: pos+%len(rpldblqte));
700fA       endif;
700fA    enddo;
700fA    // wodsc2
700fA    pos = %scan(dblqte: wodsc2);
700fA    dow pos > 0;
700fA       wodsc2 = %replace(rpldblqte: wodsc2: pos: %len(dblqte)) ;
700fA       if (pos+%len(rpldblqte) > %len(wodsc2));
700fA          pos = 0;
700fA       else;
700fA          pos = %scan(dblqte: wodsc2: pos+%len(rpldblqte));
700fA       endif;
700fA    enddo;
700fA    // wopdsc
700fA    pos = %scan(dblqte: wopdsc);
700fA    dow pos > 0;
700fA       wopdsc = %replace(rpldblqte: wopdsc: pos: %len(dblqte)) ;
700fA       if (pos+%len(rpldblqte) > %len(wopdsc));
700fA          pos = 0;
700fA       else;
700fA          pos = %scan(dblqte: wopdsc: pos+%len(rpldblqte));
700fA       endif;
700fA    enddo;
         // Put together JSON string

         pOutStr = '{'
                +  '"Err":"'  + %trimr(Errmsg) + '",'
                +  '"NDFifo":"'  + %trimr(NDFifo) + '",'
                +  '"NDQord":"'  + %trimr(NDQord) + '",'
                +  '"NDcw":"'  + %trimr(NDcw) + '",'
                +  '"NDcwex":"'  + %trimr(NDcwex) + '",'
                +  '"NDexpd":"'  + %trimr(NDexpd) + '",'
                +  '"NDmfgd":"'  + %trimr(NDmfgd) + '",'
                +  '"NDlive":"'  + %trimr(NDlive) + '",'
                +  '"NDLot":"'  + %trimr(NDLot) + '",'
                +  '"NDpti":"'  + %trimr(NDpti) + '",'
                +  '"NDBrand":"'  + %trimr(NDBrand) + '",'
                +  '"wocrcv":"'  + %trimr(wocrcv) + '",'
                +  '"w1avg":"'  + %trimr(w1avg) + '",'
                +  '"woslot":"'  + %trimr(woslot) + '",'
                +  '"woostk":"'  + %trimr(woostk) + '",'
                +  '"wolbl":"'  + %trimr(wolbl) + '",'
                +  '"woitem":"'  + %trimr(woitem) + '",'
                +  '"w1fifo":"'  + %char(w1fifo) + '",'
                +  '"w1plts":"'  + %char(w1plts) + '",'
                +  '"w1note":"'  + %trimr(w1note) + '",'
                +  '"wositm":"'  + %trimr(wositm) + '",'
                +  '"wodsc1":"'  + %trimr(wodsc1) + '",'
                +  '"wodsc2":"'  + %trimr(wodsc2) + '",'
                +  '"wopdsc":"'  + %trimr(wopdsc) + '",'
                +  '"woqor":"'  + %trimr(woqor) + '",'
                +  '"w1um1":"'  + %trimr(w1um1) + '",'
                +  '"w1um2":"'  + %trimr(w1um2) + '",'
                +  '"w1um3":"'  + %trimr(w1um3) + '",'
                +  '"wotie":"'  + %char(wotie) + '",'
                +  '"wohi":"'  + %char(wohi) + '",'
                +  '"wolbls":"'  + %trimr(wolbls) + '"';

         // Close off the JSON string
         pOutStr += '}';

         if pmessage = ' ';

           // load the reload field, if no erorrs.
           // This is used if the user backs up from M13700
           reload = 'Y';
           uhodata = pirhldpods;
           if pmessage = ' ' and moretoscan = '1' and pbypassedit <> 'U';
             // don't change pirhold backup record on subsequent uci scan
             // need to have a backup of pirhold PODTL, so that pirhold can
             // be updated if any errors occur when UCI receiving.
             // this record will be used on completion of the license
             // it is created only when the first scan has passed all edits.
             hokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem)
                     + 'UCIHOLD';
             hotype = 'PODTL';
             hosess = psessid;
             hodata = uhodata;
             write horec;
           endif;
             uhodata = pirhldpods;
           pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
           exec sql update pirhold
                    set hodata  = :uhodata
             where hosess = :psessid
               and hotype = 'PODTL'
               and hokey  = :pokey;
         endif;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;


         getclient(client: clientLoc);
         exsr zzinz;
         exsr zzinz2;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *           copied from PO232
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    PROTECTBK1 *IN94=Protect & non-display breakdown1 unit of measure
     *    PROTECTBK2 *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      wolbl = ' '
     C                   eval      woitem = ' '
     C                   eval      wodsc1 = ' '
     C                   eval      wodsc2 = ' '
     *
     C                   eval      ssbflg = *off
     C                   eval      wolbls = ' '
     C                   eval      wositm = ' '
     C                   eval      w1um1 = ' '
     C                   eval      w1um2 = ' '
     C                   eval      w1um3 = ' '
     *
      * add dri to get data from itemfld
      /free
            exsr clr$item;

            $itWhse = pwhse;
            $ititem = pPoItem;

            $dricommand = '*ITEM';
            $drisubcmd  = '%GETALL';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            if error = *on;
              $ifucicde = ' ';
              $ifrcvmth = ' ';
              $ifbrdflg = ' ';
            endif;
            if $ifbrdflg = 'Y';
              NDBrand = ' ';
            else;
              NDBrand = 'Y';
            endif;
            if $ifsltmth = '3' or
               $ifucicde <> '1'and $ifrcvmth <> '2';
              //*in73 = *off;
              NDpti = ' ';
            else;
              //*in73 = *on;
              NDpti = 'Y';
            endif;
      /end-free
     C                   if        error = *on
     C                   eval      $itdesc = *blanks
     C                   eval      $itpdsc = *blanks
     C                   eval      $itcwgt = 'N'
     C                   eval      wopdsc = *blanks
     C                   eval      wolbl = lbl(4)
     c                   eval      woitem = '* * INVALID ITEM * *'
     C     '-'           cat       woitem:1      woitem
     C     pPOItem       cat       woitem:1      woitem
     C                   goto      enduom
     C                   else
     C*
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $itwhdp = rtxdm1_dnwhdp
     C                   eval      $itdesc = pdmods
     C                   eval      $itcwgt = rtxdm1_dncwcd
     C                   eval      $itswgt = rtxdm1_dnwtiw
     C                   eval      $itcube = rtxdm1_dncbec
     C                   endif
     C                   endif
     C*
     C                   eval      wopdsc = $itpdsc
     C                   exsr      zztihi
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #oven# = $itven#
     C                   eval      #otype = $ittype
700cAC                   if        pBrandItm <> ' '
700cAC                   eval      #oitem = pBrandItm
700cAC                   else
     C                   eval      #oitem = $ititem
700cAc                   endif
     C                   eval      #odesc = $itdesc
     C                   eval      #opdsc = $itpdsc
     C                   eval      #oswgt = $itswgt
     C                   eval      #oum1 = $itum1
     C                   eval      #oum2 = $itum2
     C                   eval      #oum2q = $itumq2
     C                   eval      #oswt2 = 0
     C                   if        #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt2
     C                   endif
     C                   eval      #oum3 = $itum3
     C                   eval      #oum3q = $itumq3
     C                   eval      #oswt3 = 0
     C                   if        #oum3q <> 0
740aAc                             and #oum2q <> 0
     C     $itswgt       div(h)    #oum2q        #oswt3
     C     #oswt3        div(h)    #oum3q        #oswt3
     C                   endif
     *
     C                   if        client = Renzi
     *   Force standard-wgt catchwgt to non-catchwgt.
     C                   if        $itcwgt = 'S'
     C                   eval      $itcwgt = 'N'
     C                   endif
     *
     C                   endif
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
      /free
         if $itum1 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum1;

           If sqlstt = sqlSuccess;
             #osu1 = umshrt;
           else;
             #osu1 = %trim($itum1);
           endif;
         endif;

         if $itum2 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum2;

           If sqlstt = sqlSuccess;
             #osu2 = umshrt;
           else;
             #osu2 = %trim($itum2);
           endif;
         endif;

         if $itum3 <> *blanks;
           exec sql select * into :umrec
              from unmesr
              where umcode = :$itum3;

           If sqlstt = sqlSuccess;
             #osu3 = umshrt;
           else;
             #osu3 = %trim($itum3);
           endif;
         endif;
      /end-free
     *
     *   Initialize base information.
     *
      /free
        #bitem = $ititem;
700cA   if pBrandItm <> ' ';
700cA     #sitem = pBrandItm;
700cA   else;
          #sitem = $ititem;
700cA   endif;
        #bityp = $ittype;
        #bdesc = $itdesc;
        #bpdsc = $itpdsc;
        #bum1 = $itum1;
        #bum2 = $itum2;
        #bum3 = $itum3;
        #bsu1 = #osu1;
        #bsu2 = #osu2;
        #bsu3 = #osu3;
      /end-free
     *
     *   Get SSB item, if one exists
     *
     C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
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
     *
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        $ittype = 'C'  or
     C                             $ittype = 'A'  or
     C                             $ittype = 'S'  or
     C                             $ittype = 'B'
     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn
     C                   endif
     *   Get slot item.
     C                   call      @getsi
     C                   parm      $itwhse       $gwhse
     C                   parm      $ititem       $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
      /free
         if #bum1 <> #oum1;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum1;

           If sqlstt = sqlSuccess;
             #bsu1 = umshrt;
           else;
             #bsu1 = %trim(#bum1);
           endif;
         endif;

         if #bum2 <> #oum2;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum2;

           If sqlstt = sqlSuccess;
             #bsu2 = umshrt;
           else;
             #bsu2 = %trim(#bum2);
           endif;
         endif;

         if #bum3 <> #oum3;
           exec sql select * into :umrec
              from unmesr
              where umcode = :#bum3;

           If sqlstt = sqlSuccess;
             #bsu3 = umshrt;
           else;
             #bsu3 = %trim(#bum3);
           endif;
         endif;
      /end-free

     *
     *   Set indicators to protect breakdown quantities.
     *
      *   don't need this code for gui - 8/24/15
     C*                  if        $itflg1 = 'N'  and
     C*                            ssbflg = *off
     C*                  endif
     C*                  if        $itflg2 = 'N'  and
     C*                            ssbflg = *off  or
     C*                            $itflg2 = 'N'  and
     C*                            ssbflg = *on  and
     C*                            $itum3 = *blanks
     C*                  endif
     *
     *   When dealing with an SSB item, the quantity is actually
     *   received into the "normal" screen quantity. If a third
     *   breakdown is allowed, then that will be received into the
     *   breakdown 1 quantity on the screen. The second breakdown
     *   screen quantity is always protected for an SSB item.
     *
      * this code is not needed for gui 8/24/15
     C*                  if        $ittype = 'S'  and
     C*                            $itflg2 = 'Y'
     c*                  else
     c*                  if        $ittype = 'S'
     c*                  endif
     C*                  endif
     *
     C*                  if        $ittype = 'S'
     C*                  endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a13
     C                   if        #otype = 'S'
     C                   movea     #osu2         a13(7)
     C                   else
     C                   movea     #osu1         a13(7)
     C                   endif
     C                   movea     a13           wolbl
     C     wolbl         cat       ')':0         wolbl
     C                   move      ':'           wolbl
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      woitem
     C     woitem        cat       '-':1         woitem
     C     woitem        cat       #odesc:1      woitem
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a13
     C                   movea     #bsu2         a13(6)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
     C                   movea     lbl(2)        a13
     C                   movea     'N/A'         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a13
     C                   movea     #bsu1         a13(7)
     C                   movea     a13           wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
     C     #sitem        cat       temp10:1      wositm
     C     wositm        cat       '-':1         wositm
     C     wositm        cat       #bdesc:1      wositm
     *
     C                   endsl
     *
     *   Determine item number going into slot.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C                   eval      #sitem = #oitem
     C                   endif
     *
     *   Get extend description headings if being used.
     *
     C                   if        uxflag = *off
     C                   else
     C*
     C                   if        client = Renzi
     C                             or client = Finkle
     C                             or client = SoFo
     C                   if        pditem = rtxall9item
     C                   eval      $ixdsc1 = pdmods
     C                   endif
     C                   endif
     C*
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
     C                   endif
     *
     *   Initialize unit of measure names for quantity fields.
     *
     C                   if        #otype = 'S'
     C                   eval      w1um1 = #osu2
     C                   else
     C                   eval      w1um1 = #osu1
     C                   endif
     *
     C                   if        #otype = 'S'
     C                   eval      w1um2 = #osu3
     C                   else
     C                   eval      w1um2 = #osu2
     C                   endif
     *
     C                   eval      w1um3 = #osu3
     *
     *   Determine if this item should be put away into warehouse.
     *   An '*' in last position of designation says that the item
     *   will NOT be put away into the warehouse.
     *
     C                   move      $itdesg       iatest
     C                   if        iatest = '*'
     C                   eval      iaflag = *on
     C                   eval      *in64 = *off
     C                   else
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   endif

     *  ... Or department isn't live (this overrides iaflag).

     C                   call      'CHKLIVE'
     C                   parm      pwhse         $swhse
     C                   parm                    $itwhdp
     C                   parm                    livestat          8

     C                   if        livestat = '*NOTLIVE'
     c                   eval      NDLive = ' '
     C                   eval      iaflag = *off
     C                   eval      *in64 = *on
     C                   else
     c                   eval      NDLive = 'Y'
     C                   endif
     *
     *    The following EndIf is for statment *IN75 IFEQ *ON, which
     *    comes after the chain to PIRITEM.
     *
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr
     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720dAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = 0
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C*                  eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUCIADD Add weight record to uciinfo.
     *
     C     zzuciadd      begsr
      /free
        exsr clr$uciinfo;
        $uiWhse = pwhse;
        $uiItem = ppoitem;
        $uiuci = %editc(w1twgt:'X');
        ucilic#($unext: pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        $uiLcns = 'T' + ppo + %editc(pposeq:'X');
720dA   $uialcns = $uilcns;
720dA   $uiaolcns = $uilcns;
        $uiseq = 1;
        $uiSerial = ' ';
        $uiwgtlbs = w1twgt;
        $uiWgtKgs = 0;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '7';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        chk4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error = *on;
          uciExists = *on;
          error = *on;
          leavesr;
        else;
          UciExists = *off;
          error = *off;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUCI    Delete UCI records.
     *
      /free
        begsr zzuci;
          exsr clr$uciinfo;
          // warehouse
          $uiWhse = pwhse;

          // This is a temporary catch weight license
          $uiLcns = 'T' + ppo + %editc(pposeq:'X');

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CANCEL';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUCICHK Check to see if UCI's have been entered for CW
     *
      /free
        begsr zzucichk;
          exsr clr$uciinfo;
          // warehouse
          $uiWhse = pwhse;

          // This is a temporary catch weight license
          $uiLcns = 'T' + ppo + %editc(pposeq:'X');

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%GETLICREC';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error = *on;
            // No detail records in uciinfo for cw
            // Write one summary record
            exsr zzuciadd;
            error = '0';
          endif;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720dAC                   eval      $dridata2 = $uciinfo2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720dAC                             or $dricommand = '*UCIINFO'
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
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720dAC                   eval      $uciinfo2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  ZZTIHI   Get use Preferred or 1st tie hi record.
     *
     C     zztihi        begsr
     *
     *  GET TIE HI, PREFERRED OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
      /free
         setll (pwhse: pPOItem) itemdef;
         dou done = *on;
           reade (pwhse: pPOItem) itemdef;
           if %eof(itemdef);
             done = *on;
             leave;
           endif;
      /end-free
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = idtie
     C                   eval      svhi = idhigh
     C                   endif
     C                   if        idpref = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   eval      done = *on
     C                   endif
     C                   enddo
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
     *
     c                   if        client = finkle
     C                   eval      *in86 = *on
     C                   else
     C                   eval      *in86 = *off
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVPOCHECK check for started RCVPO Transaction
     *
     C     zzrcvpocheck  begsr
     *
     *  See if RCVPO transaction is status 2 - start new if needed
     *
     C                   call      @crtrcv
     C                   parm      '*PO'         $lcmdr           10
     C                   parm      '*CHECK '     $lsubcmd         10
     C                   parm      pwhse         @lwhse            3 0
     C                   parm      0             $lpcs             5 0
     C                   parm      0             $lpallets         5 0
     C                   parm                    $lsavetrn         7 0
     C                   parm                    ppo
     C                   parm      $itstyp       $litstyp          1
     C                   parm      $itwhdp       $litwhdp          5
     C                   parm                    $lrtnr           10
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Initialize error subfile
     *
     *
     *   Set Non Display FIFO flag.
      /free
         NDFifo = ' ';
         exec sql select * into :phrec
              from pohdr
              where phwhse = :pWhse
                and phpo   = :pPO;

         If sqlstt = sqlSuccess;
           select;
             when phvnam = 'MOVEIN' or
                  phvnam = move1  or
                  phvnam = move2;
               NDFifo = ' ';
             other;
               NDFifo = 'Y';
           endsl;
         else;
           phven = 0;
           phvnam = *blanks;
         endif;

         // Remove any existing catchweight entry records.
700bA    // check to see if individual catch weight have been entered
700bA    // if so do not delete catch weight entries
700bA     pokeyt = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
700bA     exec sql select * into :horecct
700bA        from pirhold
700bA        where hosess = :psessid
700bA          and hotype = 'PODTLCT '
700bA          and hokey  = :pokeyt;
700bA    If sqlstt = sqlSuccess;
700bA    else;
           exsr zzdlcw;
700bA    endif;
         lflag = *off;
         exsr zzxopt;
         exsr zzlcns;

         ocode = '*SYSTEM ';
         wkwhse = 0;
         exec sql select * into :oprec
              from options
              where opwhse = :wkwhse
                and opcode = :ocode;

         If sqlstt = sqlSuccess;
740fD      //optionrec = opdata;
740fM      optionrec2= opdata;
         else;
           opcapc = 'Y';
           opwrnc = 'N';
           oprg1c = 0;
           oprg2c = 0;
           opicw = 'N';
         endif;
         // get put away option
         ocode = '*PICK   ';
         wkwhse = pwhse;
         exec sql select * into :opdrec
              from optiond
              where opdwhs = :wkwhse
                and opdwdp = :$itwhdp
                and opdcod = :ocode;

         If sqlstt = sqlSuccess;
           optiondrec = opddta;
         else;
           opmput = 'N';
         endif;
      /end-free
     *
     *   Select first screen to display.
     *
      * temporarily taken out until mrc scanning installed
     C*                  if        $pupc <> *blanks
     C*                  eval      *in92 = *on
     *
     *    Left adjust UPC for better and easier viewing.
     C*                  move(p)   $pupc         $cstr
     C*                  call      'ADJUST'
     C*                  parm      '*LEFTNOZ'    $ccmd
     C*                  parm                    $cstr
     C*                  movel     $cstr         w1upcd
     C*                  endif
     *
     C                   movel     w1upcd        w1upc
     *
     C                   exsr      scr01i
     *
     *    Confirm Retail UPC on file before continuing with receiving.
     *
      ****** this was marked out temporary for first round mrc
     C                   if        svrupc = 'Y'
     C*                  exsr      zzrupc
     C     error         cabeq     *on           endinz
     C                   endif
     *
     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZDLCW   Delete catchweight entry records.
     *
     C     zzdlcw        begsr
     *
     C                   eval      $mwhs3 = pwhse
     C                   eval      $mpo3 = pPO
     C                   eval      $mseq = pPOSeq
740eAc                   eval      $mqyr1 = 0
740eAc                   eval      $mqyr2 = 0
740eAc                   eval      $mqyr3 = 0
740eAc                   eval      $mcwte = 0
740eAc                   eval      $mcwtt = 0
740eAc                   eval      $mcwta = 0
     C                   call      'DELTMPCW'
     C                   parm                    $mparm
     c                   exsr      zzuci
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
      /free
        uxflag = *off;
        ocode = '*ITEMMNT';
        exec sql select * into :oprec
             from options
             where opwhse = :pWhse
               and opcode = :ocode;

        If sqlstt = sqlSuccess;
          optionrec = opdata;
          if opxdsc = 'Y';
            uxflag = *on;
          endif;
700aA     // We will set the default for lbs/kgs from the option file
700aA     // save the field for later use
700aA     svopwum = opwum;
700aA     select;
700aA       when opwum = 'KGS'
700aA        or opwum = 'kgs'
700aA        or opwum = 'Kgs';
700aA         KiloLbs = 'K';
700aA       other;
700aA         KiloLbs = 'P';
700aA     endsl;
        endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
      /free
        lflag = *off;
        svexck = *on;
        svcwen = *on;
        svcwtp = *on;
        svcwfr = 'N';
        svrupc = 'N';
710eA   svmplt = 'Y';
        ocode = '*RCVLBL ';
        wkwhse = pwhse;
        exec sql select * into :oprec
             from options
             where opwhse = :wkwhse
               and opcode = :ocode;

        if client = Dairyland;
          opcwen = '2';
          opcwtp = '2';
          opcwfr = 'Y';
        endif;
        If sqlstt = sqlSuccess;
740cD     //optionrec = opdata;
740cM     optionrec1 = opdata;
          if opplcn = 'Y';
            lflag = *on;
          endif;
          svexck = opexck;
          svcwen = opcwen;
          svcwtp = opcwtp;
          svcwfr = opcwfr;
          svrupc = oprupc;
710eA     if opmplt = ' ';
710eA       svmplt = 'Y';
710eA     else;
710eA       svmplt = opmplt;
710eA     endif;
        endif;
      /end-free
     *
     *
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
     *
     *  get existing record(s).
     *
      /free
        *in91 = *on;
        exsr zzget1;
        exsr zzfil1;
        ovrrid = *off;
      /end-free
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
      /free
        exec sql select * into :pdrec
             from podtl
             where pdwhse = :pWhse
               and pdpo   = :pPO
               and pdseq  = :pPOSeq
               and pditem = :pPOItem;
        If sqlstt = sqlSuccess;
        else;
          error = *on;
          errmsg = 'Po Sequence does not exist';
750cA     pdseq  = 0;
750cA     pdqor1 = 0;
750cA     pdqor2 = 0;
750cA     pdqor3 = 0;
750cA     pdqrc1 = 0;
750cA     pdqrc2 = 0;
750cA     pdqrc3 = 0;
750cA     pddwgt = 0;
          leavesr;
        endif;
        if client = Renzi
           or client = Finkle
           or client = SoFo
           or client = Dairyland;
          // Retrieve P/O Detail Misc. record.
          if pditem = rtxall9item
             or client = Dairyland;
            exsr zzgtpdm;
          endif;
        endif;
      /end-free
     C*
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *    Default FIFO entered date if entry is allowed.
     *    Retrieve Item Lot/license plate tracking info.
     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = pwhse
     C                   eval      $litem = pPOItem
     *    Protect,non-display lot code entry field.
     c                   eval      NDLot = 'Y'
     C                   call      'GETLLP'
     C                   parm                    $lparm
     *
     C                   select
     *    Lot/license plate tracking values found.
     C                   when      $lrtn = '*OK     '
     C                   if        $llot = 'Y'
      * temp removed until uci mrc receiving installed
     c*                            or $plot <> ' '
     C                   eval      lottrk = '*YES'
     *    Display lot code entry field.
     c                   eval      NDLot = ' '
     C                   else
     C                   eval      lottrk = '*NO '
     C                   endif
     C                   if        $lltrk = 'Y'
     C                   eval      lictrk = '*YES'
     C                   else
     C                   eval      lictrk = '*NO '
     C                   endif
     C                   other
     C                   eval      lottrk = '*NO '
     C                   eval      lictrk = '*NO '
     C                   endsl
     *
     c                   eval      w1plts = p#plt
     C                   eval      iatest = *blanks
     C                   eval      iaflag = *off
     C                   eval      w1avg = 'N'
     *
     *   Get Unit of measure fields
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
     C                   if        client = cheney
     C     $itdesg       chain     desigsp                            79
     C                   if        *in79 = *off
     C                   eval      sdesig = *on
     C                   else
     C                   eval      sdesig = *off
     C                   eval      dsscde = *blanks
     C                   endif
     C                   endif
     C                   if        client = yhata
     C                   eval      ndqord = ' '
     C*   Convert quantity to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #prog
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   eval      woqor = $cqstr
     C*
     C                   else
     C                   eval      ndqord = 'Y'
     C                   eval      woqor = *blanks
     C                   endif
     *
     *   Enable/Disable catch weight fields.
     *
     C                   eval      vrfycw = *off
     c                   eval      ndcw = ' '
     *
     *     First, see if catch weight entry is allowed.
     *
     C                   if        ($itcwgt <> 'Y'  and
     C                              $itcwgt <> 'S') or
     C                             svcwen = '3'
     C                   eval      *in95 = *on
     C                   eval      vrfycw = *off
     C                   else
     C                   eval      *in95 = *off
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see if we should block entry ...
     *       because catch weight previously entered.
     *
     C                   if        svcwen = '2'  and
     C                             pddwgt <> 0
     c                   eval      ndcw = 'Y'
     C                   eval      vrfycw = *off
     C                   endif
     *     if uci receiving and item is catch weight must get catchweigt
     *       either from barcode or from entry.
     C                   if        $itcwgt = 'Y' and
     C                             $ifucicde = '2'
     C                   eval      *in95 = *off
     C                   eval      vrfycw = *on
     C                   endif
     *
     *     Then see what value is to be entered (1=Choice,2=Ttl,3=Avg)
     *
     C                   select
     C                   when      svcwtp = '2'
     C                   eval      w1avg = 'N'
     C                   eval      ndcwex= 'Y'
     C                   eval      wocrcv = cwt(2)
     C                   when      svcwtp = '3'
     C                   eval      ndcwex= 'Y'
     C                   eval      w1avg = 'Y'
     C                   eval      pavg = 'Y'
     C                   eval      wocrcv = cwt(3)
     C                   other
     C                   eval      *in81 = *off
     C                   eval      w1avg = 'N'
     C                   eval      ndcwex= ' '
     C                   eval      wocrcv = cwt(1)
     C                   endsl
     *
     *   Enable/Disable expiration date fields.
     *
     C                   if        $itflgd <> 'Y'
     C                   eval      NDExpd = 'Y'
     C                   else
     C                   eval      NDExpd = ' '
     C                   endif
     *
     *   Get the picking slot for the item.
     *
     C                   if        $itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse
     C                   parm                    #sitem
     C                   parm                    woslot
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm                    $srtn             8
     *
     * Try to display Special Designation slot.
     C                   select
     C                   when      Client = cheney
     C                   if        woslot = '*NONE*  ' and
     C                             sdesig = *on
     C                   eval      woslot = dssdsp
     C                   endif
     C                   endsl
     *
      /free
        // see if any stock in overflow slot.
        wOostk = 'N';
        kystat = 'A ';
        kypick = 'N';

        setll (pwhse: $ititem: kystat: kypick) slot3;
        dow forevr = forevr;
          reade (pwhse: $ititem: kystat: kypick) slot3;
          if %eof(slot3);
            leave;
          endif;

          if sldesg = 'BFC';
            iter;
          endif;

          if slstk1 > 0  or
             slstk2 > 0  or
             slstk3 > 0;
            wOostk = 'Y';
            leave;
          endif;
        enddo;
        // Enable Mfg date and disable Exp date, if Mfg date flag='Y'
        if $immflg = 'Y';
          NDMfgd = ' ';
          NDExpd = 'Y';
        else;
          *in87 = *on;
          NDMfgd = 'Y';
        endif;
      /end-free
      * This was marked out for first go at receiving in mrc
      * load up fields from gs1 incoming information
      * Expiration Date
      * this is handled a different way in gui receiving phase 2
     c*                  If        not *in96
     c*                  if        $pexpdt > 0
     C*                  move      $pexpdt       $cvd6i
     C*                  eval      $cvcmd = '*YMDMDY '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd6o        w1exdt
     c*                  endif
     c*                  endif
      * Manufacturing Date
     c*                  If        $immflg = 'Y'
     c*                  if        $pmfgdt > 0
     C*                  move      $pmfgdt       $cvd6i
     C*                  eval      $cvcmd = '*YMDMDY '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd6o        w1mfdt
     c*                  endif
     c*                  endif
      * Lot
     c*                  If        lottrk = '*YES'
     c*                  if        $pLot <> ' '
     c*                  eval      w1lotc = $plot
     c*                  endif
     c*                  endif
      * Catch Weight
     c*                  If        vrfycw = *on
     c*                  if        $pwgt > 0
     c*                  eval      w1dwgt = $pwgt
     c*                  endif
     c*                  endif
      * Quantity
     c*                  if        $pqty > 0
     c*                  eval      w1qrc1 = $pqty
     c*                  endif
      * # of Pallets
     c*                  if        $p#pall > 0
     c*                  eval      w1plts = $p#pall
     c*                  endif
      * Cross Dock - use temporary license
      /free
        if $ifrcvmth = '2';
710gD     //if xdockflg = 'Y';
710gM     if xdockflg = 'Y' or w1stat = 'XD';
            plcns  = 'Cross Dock';
            templcns = 'XD' +  #jobnbr;
            //*in73 = *on;
            *in15 = *off;
          else;
            //*in73 = *off;
            templcns = ' ';
          endif;
        endif;
        // OSS Receiving
        w1note = ' ';
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTPDM  Get P/O Detail Misc. file
     *
     C     ZZGTPDM       Begsr
     C*
      /free
         exec sql select * into :pdmrec
              from podtlm
              where pdmwhs = :pWhse
                and pdmpo  = :pPO
                and pdmseq = :pPOSeq
                and pdmitm = :pPOItem;
         If sqlstt = sqlSuccess;
           podm1_rtx = pdmms1;
           podm2_rtx = pdmms2;
           podm3_rtx = pdmms3;
           podm4_rtx = pdmms4;
           podm5_rtx = pdmms5;
         else;
           pdmitm = ' ';
           pdmpom = ' ';
           pdmods = ' ';
           pdmms1 = ' ';
           pdmms2 = ' ';
           pdmms3 = ' ';
           pdmms4 = ' ';
           pdmms5 = ' ';
           podm1_rtx = ' ';
           rtxdm1_dnpckm = 0;
           rtxdm1_dniaov = 'N';
           rtxdm1_dncwcd = 'N';
           rtxdm1_dnwtiw = 0;
           rtxdm1_dncbec = 0;
           podm2_rtx = ' ';
           podm3_rtx = ' ';
           podm4_rtx = ' ';
           podm5_rtx = ' ';
         endif;
      /end-free
     C*
     C                   Endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *on
      /free
         hotype = 'PODTL';
         pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
         chain(N) (psessid: hotype: pokey) pirhold;
         if %found(pirhold);
           pirhldpods = hodata;
         endif;
      /end-free
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $cvprg = #prog
     C                   eval      $rprg = #prog
     C                   endsr
     C*
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *   Remove any existing catchweight entry records.
     C                   if        $itcwgt = 'Y'
     C                             or $itcwgt = 'S'
      /free
700bA    // check to see if individual catch weight have been entered
700bA    // if so do not delete catch weight entries
700bA     pokeyt = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
700bA     exec sql select * into :horecct
700bA        from pirhold
700bA        where hosess = :psessid
700bA          and hotype = 'PODTLCT '
700bA          and hokey  = :pokeyt;
700bA    If sqlstt = sqlSuccess;
700bA    else;
           exsr zzdlcw;
700bA    endif;
700bA /end-free
     C                   endif
     *
     *     Check input and write/update record.
     *
      /free
        if $pcmd = '*ADD    '  or
           $pcmd = '*CHANGE ';

          // Setup convertd weight field.

          exsr zzcnvwgt;

          exsr zzchk1;
          if error;
            leavesr;
          endif;

          Select;
720aD       //when $ifrcvmth = '2' and pUCIDone <> 'Y';
720aM         when $ifrcvmth = '2' and pUCIDone <> 'Y'
720aA                              and LIVESTAT <> '*NOTLIVE'
720bA                              and iatest <> '*';
              // user is still scanning uci's no final update at this point
            other;
              exsr zzupd1;
          endsl;
          if error;
            leavesr;
          endif;
        endif;
      /end-free
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
700aD***  If in kilograms mode, convert into pounds for processing.
     *
700aA* If item options is setup as kgs and user enters kgs no conversion
700aA* If item options is setup as kgs and user enters lbs need conversion
700aA* If item options is setup as lbs and user enters lbs no conversion
700aA* If item options is setup as lbs and user enters kgs need conversion
700aA /free
700aA   select;
700aA     when svopwum = 'KGS'
700aA      or svopwum = 'kgs'
700aA      or svopwum = 'Kgs';
700aA       if KiloLbs = 'K';
700aA         eval cnvwgt = w1dwgt;
700aa       else;
700aA         eval(h) cnvwgt = w1dwgt / kgs2lbs;
700aA       endif;
700aA     other;
700aM       if KiloLbs = 'K';
700aM         eval(h) cnvwgt = w1dwgt * kgs2lbs;
700aM       else;
700aM         eval cnvwgt = w1dwgt;
700aM       endif;
700aA   endsl;
700aA /end-free
700aDC*                  if        KiloLbs = 'K'
700aDC*                  eval(h)   cnvwgt = w1dwgt * kgs2lbs
700aDC*                  else
700aDC*                  eval      cnvwgt = w1dwgt
700aDC*                  endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     *   OAOVR = Manufacture date override, Caluclated exp date
     *           comes before existing overflow exp date. (PO13233)
     *   OBOVR = Manufacture date override, Manufacture date entered
     *           is greater than today.(PIR1010)
     *   OCOVR = Expiration date override, Expiration date is greater
     *           than allowed # of days out. (PO13243)
     *   ODOVR = Use by date override, Not enough user/dist days to
     *           sell before expiration date (PO13229)
     *   OEOVR = Mfg date override, Not enough user/dist days to
     *           sell before calculated expiration date (PO13228)
     *   OFOVR = Expiration date override, Expiration date entered
     *           comes before existing overflow exp date. (PO13231)
     *   DDCODE= Invalid Date returned from the Decipher progrmas
     *   CWOVR = Weight error override taken.
     *   PTIOVR= PTI override taken.
     *   DTCHK, QTCHK, WTCHK Flags are used to force F20 for each test
     *   DTCHK2 DTCHK3, DTCHK4,UPCHK2 PTICHK
     *   QTCHK1
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
      /free
        error = *off;
        // user has checked override do not display checkbox again
        if pNDqtchkw = 'N' and pqtchkw = 'Y';
          pNDqtchkw = 'Y';
        endif;
        if pNDqtchk1w = 'N' and pqtchk1w = 'Y';
          pNDqtchk1w = 'Y';
        endif;
        if pNDdtchkw = 'N' and pdtchkw = 'Y';
          pNDdtchkw = 'Y';
        endif;
        if pNDdtchk2w = 'N' and pdtchk2w = 'Y';
          pNDdtchk2w = 'Y';
        endif;
        if pNDdtchk3w = 'N' and pdtchk3w = 'Y';
          pNDdtchk3w = 'Y';
        endif;
        if pNDdtchk4w = 'N' and pdtchk4w = 'Y';
          pNDdtchk4w = 'Y';
        endif;
        if pNDwtchkw = 'N' and pwtchkw = 'Y';
          pNDwtchkw = 'Y';
        endif;
        if pNDptichkw = 'N' and pptichkw = 'Y';
          pNDptichkw = 'Y';
        endif;
        exsr zzrcvpocheck;
      /end-free
     * Error if item dept = UNK.
770b  /free
770b    if $itwhdp = 'UNK';
770b      error = *on;
770b      pmessage = 'Invalid Item Department';
770b      exsr zzsave;
770b      leavesr;
770b    endif;
770b  /end-free

700g  /free
700g    // Check if a date conversion error occured earlier
700g    if errDate <> '';
700g      pmessage = errDate;
700g      error = '1';
700g      exsr zzsave;
700g      leavesr;
700g    endif;
700g  /end-free

      /free
        // the edit in original po137/po237 to check if uci exist
        // is checked in a previous program with gui.
        // License must be entered when doing uci receiving
        if $ifrcvmth = '2';
          // license cannot be blank
          if plcns = ' ';
            pmessage = 'License must be entered';
            error = '1';
            exsr zzsave;
            leavesr;
          endif;
          exsr zzchklcns;
        endif;

      /end-free
740dA*  ICB & ISUPPLY # of pallets must be 1, when ossprint = 'Y'
740dA /free
740dA   Select;
740dA     when client = icb or
740dA          client = isupply;
740dA       if w1plts <> 1 and ossprint = 'Y';
740dA         pmessage = 'Number of pallets must be 1';
740dA         error = '1';
740dA         exsr zzsave;
740dA         leavesr;
740dA       endif;
740dA     other;
740dA   endsl;
740dA
740dA /end-free
     *  Extract UPC code from entered string.
     *
     C                   if        w1upcd <> *blanks
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upcd
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   movel     $cbv2         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   eval      w1upc = *blanks
     C                   move      $cstr         w1upc
     C                   endif
      /free
        // Do UPC Check
        if w1upcd <> *blanks  and
           $pupc = *blanks;
          if svupc <> w1upcd;
            upchk = *off;
            upchk2 = *off;
          endif;

          if client = yhata;
            if upchk <> '2'  and
               ovrrid = *on;
              upchk = *on;
            endif;
          else;
            if upchk <> '2'  and
               ovrrid = *on  and
               $cbrtn <> '*INVALID';
              upchk = *on;
            endif;
            // Allow invalid UPC code to be entered.
            if client = saval;
              upchk = *on;
            endif;
          endif;
      /end-free
     *
     C                   if        upchk <> '1'
     C                   eval      upchk = *on
     *
     *  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING

     C                   select
     *
     C                   when      $cbrtn = '*OK'
     *
     C                   other
710hDC*                  eval      error = *on
710hDC*                  eval      *in26 = *on
710hDC*                  eval      *in06 = *on
710hDC*                  movel     $cberm        errmsg
     C                   endsl
     *
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     *
     *   Right adjust UPC code.
     *
     *   Allow multiple upc for whse/item, must be different vendor.
     *   No longer need to check if UPC exists for WHSE/ITEM/UPC
     C                   endif
     *
     C                   if        upchk2 = '0'  and
     C                             ovrrid = *on
     C                   eval      ovrrid = *off
     C                   endif
     C                   if        client = finkle and
     C                             upchk2 <> '2'  and
     C                             ovrrid = *on
     C                   eval      upchk2 = '0'
     C                   else
     C                   if        upchk2 <> '2'  and
     C                             ovrrid = *on
     C                   eval      upchk2 = *on
     C                   endif
     C                   endif
     *
      /free
        if upchk2 <> '1';
          upchk2 = *on;
          // error - upc code exists for item/vendor
          if w1upcd <> *blanks  and $pupc = *blanks;
700cA       if pBrandItm <> ' ';
700cA         chain (pwhse: pBrandItm: phven) upc1;
700cA         if %found(upc1) and upupc <> w1upc;
700cA           error = *on;
700cA           pMessage = '';
700cM           pMessage = 'A UPC already exists for this item/Brand -
700cM                       Accept to Load';
              endif;
700cA       else;
              chain (pwhse: pPOitem: phven) upc1;
              if %found(upc1) and upupc <> w1upc;
                error = *on;
                pMessage = '';
700cM           pMessage = 'A UPC already exists for this item -
700cM                       Accept to Load';
              endif;
700cA       endif;
          endif;
          if error;
            exsr zzsave;
            leavesr;
          endif;
        endif;
      /end-free
710fA*
710fA*  check for same UOM at normal and breakdowns
710fa*
710fA /free
710fA   if $itum1 = $itum2 and $itflg1 = 'Y' or
710fA      $itum1 = $itum3 and $itflg2 = 'Y' or
710fA      $itum2 = $itum3 and $itflg2 = 'Y' or
710fA      $itum3 = $itum2 and $itflg1 = 'Y';
710fA     error = *on;
710fA     pMessage = '';
710fA     pMessage = 'Duplicate UOM codes not allowed.';
710fA     exsr zzsave;
710fA     leavesr;
710fA   endif;
710fA /end-free
740gA*
740gA*  check to make sure ssb item has a breakdown uom defined
740ga*
740gA /free
740gA   if $ittype = 'S' and $itum2 = ' ';
740gA     error = *on;
740gA     pMessage = '';
740gA     pMessage = 'Missing Breakdown UOM - Fix item.';
740gA     exsr zzsave;
740gA     leavesr;
740gA   endif;
740gA /end-free
     *
     *  Verify normal quantity.
     *
      /free
        if w1qrc1 = 0  and
           w1qrc2 = 0  and
           w1qrc3 = 0;
          error = *on;
          pMessage = '';
          pMessage = 'Quantity Received must be entered';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
      /free
        if w1qrc1 < 0  or
           w1qrc1 > 99999;
          error = *on;
          pMessage = '';
          pMessage = 'Normal Quantity Received must be 0 - 99999';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
      /free
        if w1qrc2 < 0  or
           w1qrc2 > 99999;
          error = *on;
          pMessage = '';
          pMessage = 'Breakdown 1 quantity Received must be 0 - 99999';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
      /free
        if w1qrc3 < 0  or
           w1qrc3 > 99999;
          error = *on;
          pMessage = '';
          pMessage = 'Breakdown 2 quantity Received must be 0 - 99999';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *  Verify # of Pallets.
     *
      /free
        // pallet verification is not done on pick slot receiving
        // pallet verification is not done on directed putaway
        // pallet verification is not done on cross dock
        select;
          when ppsrusr = 'Y';
700cA       // if this is branded item need to make sure a pick slot is
700cA       // Assigned, if not change the flag back for ppsrusr to blank
700cA       // and load up message
700cA       if pBranditm <> ' ';
700cA /end-free
700cA*
700cA*   Get the picking slot for the item.
700cA*
700cA /free
700cA         kystat = 'A ';
700cA         kypick = 'Y';
700cA         chain (pwhse: pBrandItm: kystat: kypick) slot3;
            else;
700cA         kystat = 'A ';
700cA         kypick = 'Y';
720cD         //chain (pwhse: ppoitem: kystat: kypick) slot3;
720cM         chain (pwhse: #sitem: kystat: kypick) slot3;
700cA       endif;
700cA       if not %found(slot3);
700cA         ppsrusr = ' ';
700cA         error = *on;
700cA         pMessage = '';
700cA       if pBranditm <> ' ';
700cA         pMessage = 'No Pick Slot Assigned to Branded Item ' + pBrandItm;
            else;
700cA         pMessage = 'No Pick Slot Assigned to Item ' + ppoitem;
            endif;
700cA         exsr zzsave;
700cA         leavesr;
700cA       endif;
          when psrcvreq = 'Y';
          when xdockflg = 'Y';
          when directed = 'Y';
710gA     when w1stat = 'XD';
          other;
710eA       select;
730bD         //when svmplt = 'N';
730bM         when svmplt = 'N' or
730bA              LIVESTAT = '*NOTLIVE';
710eA           if w1plts <> 1;
710eA             error = *on;
710eA             pMessage = '';
710eA             pMessage = 'Number of pallets must be 1';
710eA             exsr zzsave;
710eA             leavesr;
710eA           endif;
710eA         other;
                if w1plts <= 0  or w1plts > 999;
                  error = *on;
                  pMessage = '';
                  pMessage = 'Valid range for Number of pallets ' +
                             'is 1 to 999';
                  exsr zzsave;
                  leavesr;
                endif;
710eA       endsl;
        endsl;
      /end-free
     *
     *  Verify fifo if needed.
     *
      /free
        if NDFifo = ' ' and w1fifo = 0;
          error = *on;
          pMessage = '';
          pMessage = 'Fifo Date must be entered';
          leavesr;
        endif;
        // THIS IS TURNED OFF TEMPORARILY FOR FIRST ROUND MRC RECEIVING
        // pti check
            // calculate the PTI.
            if $pbclot <> ' ' and $pgtin <> ' ' and ndpti = ' ';
              if w1pti = 0;
                error = *on;
                pMessage = '';
                pMessage = 'PTI must be greater than 0';
              endif;
            endif;
      /end-free
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *  Verify FIFO (entered) date.
     *
     c                   if        NDFifo  = ' ' and
     C                             w1fifo <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fifo        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
      /free
        if $cvrtn = '*PGMQ   ';
          error = *on;
          pMessage = '';
          pMessage = 'Invalid Date Entered';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   eval      w1fifo = $cvd6o
     C                   endif
     *
     *  Verify expiration date.
     *
      /free
        if NDexpd = ' ' and
           w1exdt = 0;
          error = *on;
          pMessage = 'Expiration Date is required';
          exsr zzsave;
          leavesr;
      /end-free
     C                   else
710iAc                   if        ndexpd =  ' ' and w1exdt <> 0
710iAC                   eval      $cvcmd = '*MDYEDT '
710iAC                   move      w1exdt        $cvd6i
710iAC                   call      @cvtdt
710iAC                   parm                    $cvtdt
710iA /free
710iA   if $cvrtn = '*PGMQ   ';
710iA     error = *on;
710iA     pMessage = '';
710iA     pMessage = 'Invalid Date Entered';
710iA     exsr zzsave;
710iA     leavesr;
710iA   endif;
710iA   endif;
710iA /end-free
     *  Moved code here to calculate CKEXDT
     *  Verify Expiration date is within parameter (# of days out)     days)
     *  Calculate (Today + # days out)  = CHEXDT                       days)
     *

     C                   if        client = glazier
     C                   z-add     $itslif       $imoday
     C                   endif
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imoday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ckexdt        parm      0             $cddateout
     C                   parm      0             $cdtimeout

700hAC                   if        $immflg = 'Y'
710aA /free
710aA    if w1mfdt = 0;
710aA      error = *on;
710aA      pMessage = '';
710aA      pMessage = 'Date must be entered';
710aA      exsr zzsave;
710aA      leavesr;
710iA      else;
710iA /end-free
710iAC                   eval      $cvcmd = '*MDYEDT '
710iAC                   move      w1mfdt        $cvd6i
710iAC                   call      @cvtdt
710iAC                   parm                    $cvtdt
710iA /free
710iA   if $cvrtn = '*PGMQ   ';
710iA     error = *on;
710iA     pMessage = '';
710iA     pMessage = 'Invalid Date Entered';
710iA     exsr zzsave;
710iA     leavesr;
710iA   endif;
710aA   endif;
710aA /end-free
700hA*
700hA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
700hA*

700hAC                   eval      $cvcmd = '*MDYCMD '
700hAC                   move      w1mfdt        $cvd6i
700hAC                   call      @cvtdt
700hAC                   parm                    $cvtdt
700hAC                   move      $cvd8o        expd
700hAC                   move      $cvd8o        womfdt


700hAC                   call      'CLCDUR2'
700hAC                   parm      '*ADD'        $cdcmd
700hAC                   parm      expd          $cddatein
700hAC                   parm      0             $cdtimein
700hAC                   parm      0             $cdyears
700hAC                   parm      0             $cdmonths
700hAC                   parm      $immday       $cddays
700hAC                   parm      0             $cdhours
700haC                   parm      0             $cdminutes
700hAC                   parm      0             $cdseconds
700hAC                   parm      0             $cddateout
700hAC                   parm      0             $cdtimeout

700hAC                   call      'CLCDUR2'
700hAC                   parm      '*SUB'        $cdcmd
700hAC                   parm      $cddateout    $cddatein
700hAC                   parm      0             $cdtimein
700hAC                   parm      0             $cdyears
700hAC                   parm      0             $cdmonths
700hAC                   parm      $imuday       $cddays
700hAC                   parm      0             $cdhours
700hAC                   parm      0             $cdminutes
700hAC                   parm      0             $cdseconds
700hAC     expd          parm      0             $cddateout
700hAC                   parm      0             $cdtimeout

700hAC                   eval      $cvcmd = '*CMDMDY '
700hAC                   move      expd          $cvd8i
700hAC                   call      @cvtdt
700hAC                   parm                    $cvtdt
700hAC                   move      $cvd6o        w1exdt

700hA*
700hAC                   endif
     C                   if        w1exdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      pMessage = $cvmsg
      /free
        exsr zzsave;
        leavesr;
      /end-free
     C                   else
     C                   eval      w1exdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        woexdt
     *  check expiration date enter to make sure it is greater than today.
      /free
DRYaA   Select;
DRYaA     when client = Dairyland;
ADFaA     when client = AandDFoods;
FPRaA     when client = foodpro;
CFIaA     when client = colony;
740cA     when opexpe = 'W';
DRYaA     other;
            if expd <= today;
              error = *on;
              pMessage = '';
710dD         //pMessage = 'Date must be greater than today';
710dA         if $immflg = 'Y';
710dM           pMessage = 'Calculated Expiration Date ' +
                            %trim(%editc(expd:'X'))  +
710dA                      ' Product already Expired. Check Item';
710dA         else;
710dM           pMessage = 'Expiration Date ' +
                            %trim(%editc(expd:'X'))  +
710dA                      ' Product already Expired.';
710dA         endif;
              exsr zzsave;
              leavesr;
            endif;
DRYaA   Endsl;
      /end-free
     *  Code to calculate CKEXDT was moved from here to above.
     *
     *
     *  Verify Use by date.                                            days)
     *  Calculate (Today + Dist Days)  = DATE1                         days)
     *  Calculate  (Use By - User Days) = DATE2                        days)
     *

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date1         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   if        $immflg = 'Y'
     C                   eval      date2 = expd
     C                   else
     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif
     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     date2         parm      0             $cddateout
     C                   parm      0             $cdtimeout
     C                   endif

     *
     C                   move      date2         $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        date2o
     *
     C                   endif
     C                   endif
     C                   endif
     ***
     *  Verify Expire date and # of days out                           days)
     *  Allow warning and override                                     days)
     C                   if        expd <> 0
      /free
        if svexdt <> w1exdt;
          dtchk = *off;
          ocovr = *off;
        endif;
      /end-free
     *
     C                   if        dtchk = '2'  and
     C                             pdtchkw = 'Y'
     c                   eval      pNDdtchkw = 'Y'
     C                   if        client = Glazier
      * taken out client No longer using our software.
     C*                  exsr      zzpwd
      /free
        if $prtn = '*NO';
          pdtchkw = ' ';
          error  = *on;
          exsr zzsave;
          leavesr;
        else;
          error = *on;
          dtchk = '2';
          warn = *on;
          erused = w1exdt;
          erdisd = $imoday;
          pMessage = '';
          pMessage = 'Warning: Item cannot be accepted - Expiration date';
          pNDdtchkw = 'N';
          // setof all other data check boxes
          pNDdtchk2w = 'Y';
          pNDdtchk3w = 'Y';
          pNDdtchk4w = 'Y';
          pdtchkw = ' ';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     c                   endif
     C                   eval      ocovr = *on
     C                   eval      dtchk = *on
     C                   endif
     *
     C                   if        dtchk <> '1'
     C                   eval      dtchk = *on
     *
     *   If EXPD > /CKEXDT - Reject.
     *
      /free
ACCaA   // accardi doesn't get this warning if days out is set to 999
ACCaA   select;
ACCaA     when client = accardi and $imoday = 999 and expd > ckexdt;
ACCaA     other;
710bD       //if expd > ckexdt;
710bM       if expd > ckexdt
710bA         and $immflg <> 'Y';
              error = *on;
              dtchk = '2';
              warn = *on;
              erused = w1exdt;
              erdisd = $imoday;
              if client <> glazier;
                pMessage = '';
710dD     //pMessage = 'Warning: Item cannot be accepted - Expiration date';
710dM           pMessage = 'Warning: Item cannot be accepted - ' +
710dA                     ' Expiration date - Number of days out is ' +
710dA                     %trim(%editc($imoday:'X'));
                pNDdtchkw = 'N';
                // setof all other date check boxes
                pNDdtchk2w = 'Y';
                pNDdtchk3w = 'Y';
                pNDdtchk4w = 'Y';
              else;
                erdisd = $itslif;
                pMessage = '';
                pMessage = 'Warning: Days exceed Total Shelf life';
                pNDdtchkw = 'N';
                pNDdtchk2w = 'Y';
                pNDdtchk3w = 'Y';
                pNDdtchk4w = 'Y';
              endif;
            endif;
ACCaA   endsl;
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *
     *
     *  Verify Use by date.                                            days)
     C                   if        expd <> 0
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk3 = *off
     C                   endif
     *
     C                   if        dtchk3 = '2'  and
     C                             pdtchk3w = 'Y'
     c                   eval      pNDdtchk3w = 'Y'
     C                   if        client = Glazier
      * taken out client no longer using our software
     C*                  exsr      zzpwd
     C                   if        $prtn = '*NO'
     C                   eval      pdtchk3w = ' '
     C                   eval      error  = *on
     C                   eval      dtchk3 = '2'
     C                   eval      warn = *on
     C                   eval      erused = w1exdt
     C                   eval      erdisd = $imdday
     C                   eval      erusrd = $imuday
     C                   eval      ersell = date2o
      /free
        pMessage = '';
        pMessage = 'Warning: Item cannot be accepted - Use by date';
        pNDdtchk3w = 'N';
        pNDdtchk2w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk4w = 'Y';
        exsr zzsave;
        leavesr;
      /end-free
     C                   endif
     C                   endif
     C                   eval      odovr = *on
     C                   eval      dtchk3 = *on
     C                   endif
     *
     C                   if        dtchk3 <> '1'
     C                   eval      dtchk3 = *on
     *
     *   If DATE2 <= Date1 - Reject.
     *
      /free
        if date2 <= date1;
          error = *on;
          dtchk3 = '2';
          warn = *on;
          erused = w1exdt;
          erdisd = $imdday;
          erusrd = $imuday;
          ersell = date2o;
          pMessage = '';
710dD    //pMessage = 'Warning: Item cannot be accepted - Use by date';
710dM     pMessage = 'Warning: Item cannot be accepted - Use by date -
710dA                 Short days to sell.';
          pNDdtchk3w = 'N';
          pNDdtchk2w = 'Y';
          pNDdtchkw = 'Y';
          pNDdtchk4w = 'Y';
        endif;
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     C                   endif
     C                   eval      expd = date2
     C                   endif
     *  Change to use DTCHK4 for override                                  )
     C                   if        svmfdt <> w1mfdt
     C                   eval      dtchk4 = *off
     C                   endif
     *
     C                   if        dtchk4 = '2'  and
     C                             pdtchk4w = 'Y'
     c                   eval      pNDdtchk4w = 'Y'
     C                   if        client = Glazier
      * taken out client no longer using our software
     C*                  exsr      zzpwd
      /free
        if $prtn = '*NO';
          pdtchk4w = ' ';
          error  = *on;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     C                   if        mfgd > today
     C                   eval      obovr = *on
     C                   endif
     C                   if        client = yhata  and
     C                             mfgd = today
     C                   eval      obovr = *on
     C                   endif
     C                   if        today > ltstd8
     C                   eval      oeovr = *on
     C                   endif
     C                   eval      dtchk4 = *on
     C                   endif
     C                   if        dtchk4 <> '1'
     C                   eval      dtchk4 = *on
     *
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      $immflg = 'Y'
     C                   if        w1mfdt = 0
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
      /free
        pMessage = '';
        pMessage = 'Manufacturing Date is required';
        return;
      /end-free
     C                   else
     C                   if        w1mfdt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
      /free
        pMessage = '';
        pMessage = 'Invalid Date Entered';
        return;
      /end-free
      /free
          exsr zzsave;
          leavesr;
      /end-free
     C                   else
     C                   eval      w1mfdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgd
     C                   if        mfgd > today
     C                   eval      error = *on
     C                   eval      dtchk4 = *off
     C                   eval      obovr = *off
      /free
        pMessage = '';
        pMessage = 'Date must be less than or equal to today';
        return;
      /end-free
     C                   endif
     C                   if        client = yhata  and
     C                             mfgd = today
     C                   eval      error = *on
     C                   eval      dtchk4 = '2'
     C                   eval      obovr = *off
      /free
        pMessage = '';
        pMessage = 'Date must be less than today';
        return;
      /end-free
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd

     C                   if        client = Glazier
     *  Create expiration date mfgdate + mfg shelf life days
     *      instead of mfgdata + mfg shelf life days - User days
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     *  Find the latest acceptable date.: Exp date -Dist days
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        ltstd8

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      ltstd8        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imdday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     ltstd8        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ltstd8        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        ltstd6

     *
     *   If Today's date is > Latest acceptable date - Reject.
     *
     C                   if        client = Glazier
     c                   eval      netdays = $immday - $imdday
     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      today         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      netdays       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     glzmfd        parm      0             $cddateout
     C                   parm      0             $cdtimeout
     C                   endif
     C                   select
     *   For Glazier mfg date < today - dist days
     C                   when      client = Glazier and
     C                             mfgd < glzmfd
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
      /free
        pMessage = '';
        pMessage = 'Warning: Not enough Shelf Life Remaining';
        pNDdtchk4w  = 'N';
        pNDdtchk2w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk3w = 'Y';
      /end-free
     C                   eval      w1exdt = 0
     C                   eval      expd = *zeros
     *   For Glazier today's date is = expiration date
     C                   when      client = Glazier and
     C                             today = mfgd
     *   For Glazier mfg date < today - dist days
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
      /free
        pMessage = '';
        pMessage = 'Production date must be prior to today';
        pNDdtchk4w  = 'N';
        pNDdtchk2w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk3w = 'Y';
      /end-free
     C                   eval      w1exdt = 0
     C                   eval      expd = *zeros
     C                   when      today > ltstd8
     C                   eval      error = *on
     C                   eval      oeovr = *off
     C                   eval      dtchk4 = '2'
     C                   eval      warn = *on
     C                   z-add     $immday       ermday
     C                   z-add     w1mfdt        ermfdt
     C                   z-add     w1exdt        erexdt
     C                   z-add     ltstd6        erltst
     C                   z-add     $imdday       erdday
     C                   z-add     $imuday       eruday
     c                   Select
     c                   when      client = yhata
      /free
        pMessage = '';
        pMessage = 'Warning: Item cannot be accepted - Mfg date';
        pNDdtchk4w  = 'N';
        pNDdtchk2w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk3w = 'Y';
      /end-free
     C                   other
      /free
        pMessage = '';
        pMessage = 'Warning: Not enough Shelf Life Remaining';
        pNDdtchk4w  = 'N';
        pNDdtchk2w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk3w = 'Y';
      /end-free
     C                   endsl
700hDC*****              eval      w1exdt = 0
700hDC*****              eval      expd = *zeros
     C                   endsl
     C                   endsl
     *
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     *
     *   Check for earlier expiration dates (optional)                 days)
     *
     *     See if we can skip the check.                               days)
     *
730gDC**                 if        w1exdt = 0  or
730gMC                   if        $itflgd = 'N'  or
     C                             svexck <> '2'  and
     C                             svexck <> '3'
     C                   goto      skpxck
     C                   endif
     *
     *     Set warning check flag.                                     days)
     *
     C                   if        svexdt <> w1exdt
     C                   eval      dtchk2 = *off
     C                   eval      oaovr = *off
     C                   eval      ofovr = *off
     C                   endif
     *
     C                   if        dtchk2 = '2'  and
     C                             pdtchk2w = 'Y'
     c                   eval      pNDdtchk2w = 'Y'
     C                   if        client = Glazier
      * taken out client no longer using our software.
     C*                  exsr      zzpwd
      /free
        if $prtn = '*NO';
          error = *on;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     C                   if        $immflg = 'Y'
     C                   eval      oaovr = *on
     C                   else
     C                   eval      ofovr = *on
     C                   endif
     C                   eval      dtchk2 = *on
     C                   goto      skpxck
     C                   endif
     *
     C     dtchk2        cabeq     '1'           skpxck
     *
     *     Do actual check                                             days)
     *
     C                   eval      dtchk2 = *on
     *
     *       Get date range of overflow slots.
     *
     C                   call      'GETEXPD'
     C                   parm      pwhse         $swhse            3 0
     C                   parm                    #sitem
     C                   parm                    $dfrom            8 0
     C                   parm                    $dto              8 0
     c                   eval      $dtosave = $dto
     *
     *       If date comes after end of range
     *         Then date can be recevied so skip the rest of the check
     *
     C                   if        expd >= $dto
     C                   goto      skpxck
     C                   endif
     *
     *       Otherwise, see if it's an error or warning.
     *
     *         '1' = Allow Let it go through
     *         '2' = Error (not allowed)
     *         '3' = Warning.
     *
     C                   eval      error = *on
     C                   if        $immflg = 'Y'
     C                   else
     C                   endif
     C                   eval      erentd = expd
     C                   eval      ertod = $dto
     C                   select
     C                   when      svexck = '2'
     C                   eval      dtchk2 = *off
      /free
        if $immflg = 'Y';
          pMessage = '';
          pMessage = 'Item cannot be accepted - +
                      Calculated Expiration Date';
        else;
          pMessage = '';
          pMessage = 'Item cannot be accepted - Expiration date';
        endif;
      /end-free
     C                   when      svexck = '3'
     C                   eval      dtchk2 = '2'
     C                   eval      warn = *on
      /free
        if $immflg = 'Y';
          oaovr = *on;
          pMessage = '';
710dD     //pMessage = 'Warning: Earlier calculated expiration date';
710dM     pMessage = 'Warning: Product will expire before +
710dA                 existing product in warehouse';
          pNDdtchk2w = 'N';
        pNDdtchk4w = 'Y';
        pNDdtchkw = 'Y';
        pNDdtchk3w = 'Y';
        else;
          ofovr = *on;
          pMessage = '';
710dA     //pMessage = 'Warning: Earlier expiration date';
710dM     pMessage = 'Warning: Product will expire before +
710dA                 existing product in warehouse';
          pNDdtchk2w = 'N';
          pNDdtchk4w = 'Y';
          pNDdtchkw = 'Y';
          pNDdtchk3w = 'Y';
        endif;
      /end-free
     C                   endsl
     *
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     C     skpxck        tag
      // THIS IS TURNED OFF TEMPORARILY FOR FIRST ROUND MRC RECEIVING
      * pti check
      /free
        // calculate the PTI.
        if $pbclot <> ' ' and $pgtin <> ' ' and ndpti = ' ';
          pplot  = %subst($pbclot: 1 : 20);
          bcprodd = $pbcProdd;
          //calcpti ($pgtin: pplot: $pbcProdD: pppti);
          calcpti ($pgtin: pplot: bcProdD: pppti);
          if svpti <> w1pti;
            ptichk = *off;
          endif;
          if ptichk = '2' and
             ovrrid = *on;
             ptiovr = *on;
             ptichk = *on;
          endif;
          if ptichk <> '1';
            ptichk = *on;
            if w1pti <> pppti
              and ptiovr <> '1';
              // recalc pti without production date
              calcpti ($pgtin: pplot: ptinodate: pppti);
              if w1pti <> pppti;
                error = *on;
                ptichk = '2';
                warn = *on;
                pMessage = '';
                pMessage = 'Warning: PTI does not match calculated PTI +
                          from barcode';
              endif;
            endif;
          endif;
        endif;
      /end-free
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *
     *  Always error if catchweight is negative
     *
      /free
        if w1dwgt < 0;
          error = *on;
          pMessage = '';
          pMessage = 'Negative catchweight entered. '
                   + 'Catchweight must be greater than zero.';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
730cA*
730cA*  Error if entered  CW is gt 99999.99
730cA*
730cA /free
730cA   if w1dwgt > 99999.99;
730cA     error = *on;
730cA     pMessage = '';
730cA     pMessage = 'Weight cannot exceed 99999.99 ';
730cA     exsr zzsave;
730cA     leavesr;
730cA   endif;
730cA /end-free
     *
     *  See if we need to verify catch weight.
     *
     C     vrfycw        cabeq     *off          skipcw
     *
     *  If Catch weight is retieved from gs1 scan do not edit
     *  If product is setup for UCI receiving
     *  This was PO237 mod 700c.
     *
      /free
        if $ifrcvmth = '2' and pucidone <> 'Y';
          // need to grab the uci scanned from the pirhold record
          pokey = ppo;
          exec sql select * into :horecuci
             from pirhold
             where hosess = :psessid
               and hotype = 'PODTLUCI'
               and hokey  = :pokey;
          If sqlstt = sqlSuccess;
            pirhlducds = U_hodata;
            // now get the extracted data from pirhold
            exec sql select * into :horecuci
               from pirhold
               where hosess = :psessid
                 and hotype = 'PODTLUCIE'
                 and hokey  = :pokey;
            If sqlstt = sqlSuccess;
              pirhldueds = U_hodata;
              $barcode = ucidata1;
              $barcode2 = ucidata2;
            endif;
          else;
          endif;
      /end-free
     C     $bcPNtLbSent  cabeq     *on           skipcw
     c                   endif
     *
     *  CW can't be zero if forced entry is selected.
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
      /free
        if svcwfr = 'Y'  and
           w1dwgt = 0;
          if svcwen = '1'  or
             svcwen = '2'  and
             w1avg <> 'Y';
            error = *on;
            pMessage = '';
            pMessage = 'Catch Weight must be greater than 0';
            exsr zzsave;
            leavesr;
          endif;
        endif;
      /end-free
     *
     *  Verify Catch weight average  (Y/N).
     *
     C                   if        w1avg <> 'Y'  and
     C                             w1avg <> 'N'
     C                   eval      error = *on
     C                   endif
     *
     *  When 'First time only' entry with Avg = 'Y'
     *    Then catch weight must be zero.
     *
      /free
        if svcwen = '2'  and
           w1avg = 'Y'  and
           w1dwgt <> 0;
          error = *on;
          pMessage = '';
          pMessage = 'CW must be zero when +
                     doing average for "First time only" +
                     CW entry';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *
     *  When more than one qty is entered, catch weight average must be N
     *
     *    One exception for 'First time only' entry with Avg = 'Y'
     *
     C                   select
     C                   when      w1qrc1 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
      /free
        if w1qrc2 <> 0  or
           w1qrc3 <> 0;
          error = *on;
          pMessage = '';
          pMessage = 'Catch weight average cannot be checked';
          return;
        endif;
      /end-free
     *
     C                   when      w1qrc2 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
      /free
        if w1qrc1 <> 0  or
           w1qrc3 <> 0;
          error = *on;
          pMessage = '';
          pMessage = 'Catch weight average cannot be checked';
          return;
        endif;
      /end-free
     *
     C                   when      w1qrc3 <> 0  and
     C                             w1avg = 'Y'  and
     C                             svcwen <> '2'
      /free
        if w1qrc1 <> 0  or
           w1qrc2 <> 0;
          error = *on;
          pMessage = '';
          pMessage = 'Catch weight average cannot be checked';
          return;
        endif;
      /end-free
     *
     C                   endsl
     *
     *
     *  Skip catch weight variance check when ...
     *    "First time only" entry
     *
     C                   if        svcwen = '2'
     *      Skip variance check once qty has been received for item.
     C                             and (pdqrc1 > 0
     C                             or   pdqrc2 > 0
     C                             or   pdqrc3 > 0)
     C
     C                   goto      skipcw
     C                   endif
     *
     *
     *  Catch weight variance check.
     C                   if        svdwgt <> w1dwgt
     C                   eval      wtchk = *off
700dAc                   eval      pNDwtchkw = 'Y'
     C                   endif
     *
     C                   select
     C                   when      client = Dairyland
     C                   if        wtchk = '2'  and
     C                             pwtchkw = 'Y'
     c                   eval      pNDwtchkw = 'Y'
     c                   eval      cwovr = *on
     C                   eval      wtchk = *on
     C                   endif
     C                   other
     C                   if        wtchk = '2'  and
     C                             pwtchkw = 'Y'
     c                   eval      pNDwtchkw = 'Y'
     c                   eval      cwovr = *on
     C                   eval      wtchk = *on
     C                   endif
     C                   endsl
     *
     C                   if        wtchk <> '1'
     C                   eval      wtchk = *on
     *   If catch weight >0,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        w1dwgt <> 0
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     C                   eval      hostcw0 = 0
     C                   eval      hostcw2dec = 0
     *
     C                   if        w1avg = 'Y'
     C                   eval      exwgt = $itswgt
     C                   eval      wotcw = cnvwgt
     C                   else
     C                   if        svcwen = '2'
750aA /free
750aA   exwgt = pdqor1 * $itswgt;
750aA   if pdqor2 > 0 and $itumq2 > 0;
750aA     exwgt = exwgt + (pdqor2 * ($itswgt /$itumq2));
750aA   endif;
750aA   if pdqor3 > 0 and $itumq3 > 0;
750aA     exwgt = exwgt + (pdqor3 * ($itswgt /$itumq3));
750aA   endif;
750aA /end-free
750aDC*    pdqor1        mult      $itswgt       exwgt
730fA*
730fA*  Error if extended weight is gt 99999.99
730fA*
730fA /free
730fA   if exwgt  > 99999.99;
730fA     error = *on;
730fA     pMessage = '';
730fA     pMessage = 'Qty Received x shipping weight exceeds 99999.99';
730fA     exsr zzsave;
730fA     leavesr;
730fA   endif;
730fA /end-free

     * If specific client, use imported c/w value for variance checking if
     * it's numeric, otherwise, use standard comparison tests.

     C                   eval      hostUnitWgt  = 0
     C                   eval      rcvUnitWgt  = 0

     C                   select
     C                   when      client = Dairyland
     C                   eval      hostcwa = %subst(pdmms1:9:7)
     C     digits        check     hostcwa                                68
     C                   if        *in68 = *off
     C                   eval      hostcw0 = %dec(%subst(pdmms1:9:7):7:0)
     C                   move      hostcw0       hostcw2dec

     C                   eval      qtyord  = 0
     C                   eval      qtyord1 = 0
     C                   eval      qtyord2 = 0
     C                   eval      qtyord3 = 0

     C                   if        pdqor1 > 0
     C                   eval      qtyord1 = pdqor1
     C                   if        $itumq2 > 0
     C                   eval      qtyord1 = qtyord1 * $itumq2
     C                   endif
     C                   if        $itumq3 > 0
     C                   eval      qtyord1 = qtyord1 * $itumq3
     C                   endif
     C                   endif

     C                   if        pdqor2 > 0
     C                   eval      qtyord2 = pdqor2
     C                   if        $itumq3 > 0
     C                   eval      qtyord2 = qtyord2 * $itumq3
     C                   endif
     C                   endif

     C                   if        pdqor3 > 0
     C                   eval      qtyord3 = pdqor3
     C                   endif

     C                   eval      qtyord = qtyord1 + qtyord2 + qtyord3

     C                   eval      exwgt = 0
     C                   eval      qtyrcv = 0
     C                   eval      qtyrcv1 = 0
     C                   eval      qtyrcv2 = 0
     C                   eval      qtyrcv3 = 0

     C                   if        w1qrc1 > 0
     C                   eval      qtyrcv1 = w1qrc1
     C                   if        $itumq2 > 0
     C                   eval      qtyrcv1 = qtyrcv1 * $itumq2
     C                   endif
     C                   if        $itumq3 > 0
     C                   eval      qtyrcv1 = qtyrcv1 * $itumq3
     C                   endif
     C                   endif

     C                   if        w1qrc2 > 0
     C                   eval      qtyrcv2 = w1qrc2
     C                   if        $itumq3 > 0
     C                   eval      qtyrcv2 = qtyrcv2 * $itumq3
     C                   endif
     C                   endif

     C                   if        w1qrc3 > 0
     C                   eval      qtyrcv3 = w1qrc3
     C                   endif

     C                   eval      qtyrcv = qtyrcv1 + qtyrcv2 + qtyrcv3

     C                   eval      hostUnitWgt = hostcw2dec / qtyord
700aDC*                  eval      rcvUnitWgt = w1dwgt / qtyrcv
700aMC                   eval      rcvUnitWgt = cnvwgt / qtyrcv
     C                   eval      wgtDiff = hostUnitWgt - rcvUnitWgt
     C                   eval      caltol1 = %abs(wgtDiff) / hostUnitWgt

     C                   if           pdqor2 > 0 or pdqor3 > 0
     C                             or w1qrc2 > 0 or w1qrc3 > 0
     C                   eval      qtyDiff  = qtyord - qtyrcv
     C                   eval      caltol2  = %abs(qtyDiff) / qtyord
     C                   endif

     C                   else
     C     w1qrc1        mult      $itswgt       exwgt
730fA*
730fA*  Error if extended weight is gt 99999.99
730fA*
730fA /free
730fA   if exwgt  > 99999.99;
730fA     error = *on;
730fA     pMessage = '';
730fA     pMessage = 'Qty Received x shipping weight exceeds 99999.99';
730fA     exsr zzsave;
730fA     leavesr;
730fA   endif;
730fA /end-free
     C                   endif
     C                   endsl

     C                   else
750aA /free
750aA   exwgt = w1qrc1 * $itswgt;
750aA   if w1qrc2 > 0 and $itumq2 > 0;
750aA     exwgt = exwgt + (w1qrc2 * ($itswgt /$itumq2));
750aA   endif;
750aA   if w1qrc3 > 0 and $itumq3 > 0;
750aA     exwgt = exwgt + (w1qrc3 * ($itswgt /$itumq3));
750aA   endif;
750aA /end-free
750aDC*    w1qrc1        mult      $itswgt       exwgt
730fA*
730fA*  Error if extended weight is gt 99999.99
730fA*
730fA /free
730fA   if exwgt  > 99999.99;
730fA     error = *on;
730fA     pMessage = '';
730fA     pMessage = 'Qty Received x shipping weight exceeds 99999.99';
730fA     exsr zzsave;
730fA     leavesr;
730fA   endif;
730fA /end-free
     C                   endif
     C                   eval      wotcw = cnvwgt
     C                   endif
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *
     **   Iniz. fields used to hold low/high variance.
     C                   eval      prg1c = 0
     C                   eval      prg2c = 0
     **   Use item variance % if it exists
     *
     C                   if        $imrg1c <> 0
     C     $imrg1c       div       100           prg1c
     C                   if        $imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        $imrg2c <> 0
     C     $imrg2c       div       100           prg2c
     C                   if        $imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     *     Don't do following extended weight calcs if you're using
     *     Dairyland's imported c/w method for comparing wgt tolerance.
     C                   select
     C                   when      hostcw2dec = 0
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = $itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = $itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = $itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     $itswgt       add       ihvar         ihrng
     *
     C                   endsl
     C                   endif
     *
     *     Check CW variance if CW > 0
     C                   if        w1dwgt > 0
     C                   if        hostcw2dec > 0
     *     Use Dairyland's tests for comparing wgt and qty tolerances.
     C                   exsr      zzchkt1
     C                   else
     C                   exsr      zzchkt
     C                   endif
     C                   endif
      /free
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     *
     C     skipcw        tag
     *
     *
     *    Make sure slot is valid.
     *
     C                   if        w1slot <> *blanks
      /free
        chain (pwhse: $itwhdp: w1slot) slot2;
        // Slot Doesn't exist
        if not %found(slot2);
          error = *on;
          pMessage = '';
          pMessage = 'Slot does not exist';
          exsr zzsave;
          leavesr;
         endif;
      /end-free
     *
     *      Slot occupied by different item.
     *
      /free
        if slstat <> 'Z'  and
           slitem <> ' '  and
           slitem <> pPOitem;
          error = *on;
          pMessage = '';
          pMessage = 'Slot is occupied with different item';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     *
     *      Slot is a zero slot.
     *
      /free
        if slstat = 'Z';
          error = *on;
          pMessage = '';
          pMessage = 'Slot is a zero slot. It must be verified first';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     *
     *      Status is not allowed can't be A,V or Z
     *
      /free
        if w1stat =  'A '  or
           w1stat = 'V '   or
           w1stat = 'Z ';
          error = *on;
          pMessage = '';
          pMessage = 'Status, cannot be A, V, or Z';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
SWTbA*
SWTbA*      Only status blank, QU and XD for Southwest Traders.
SWTbA*
SWTbA /free
SWTbA   if client = SWT;
SWTbA   if w1stat <> 'QU'  and
SWTbA      w1stat <> 'XD'  and
SWTbA      w1stat <> '  ';
SWTbA     error = *on;
SWTbA     pMessage = '';
SWTbA     pMessage = 'Status must be blank, QU or XD';
SWTbA     exsr zzsave;
SWTbA     leavesr;
SWTbA   endif;
SWTbA   endif;
SWTbA /end-free
700cA*
700cA*      Validate Branded Item is sent when needed
700cA*
700cA /free
700cA   bCmd = '*GETFLAG';
700cA   bBrand = ' ';
700cA   bBrandItm = ' ';
700cA   bBrandFlg = ' ';
700cA   GetBranded(bCmd: pwhse: ppoItem: bBrand: bBrandItm: bBrandFlg);

700cA   If bBrandFlg = 'Y';
700cA     if pBrandItm = ' ';
700cA       error = *on;
700cA       pMessage = '';
700cA       pMessage ='Brand Must be Selected';
700cA       exsr zzsave;
700cA       leavesr;
700cA     endif;
700cA   endif;
700cA /end-free
     *
     *      Print oss license valid only if oss code is sent
     *
      /free
        if osscode = ' '  and
           ossprint = 'Y';
          error = *on;
          pMessage = '';
          pMessage ='Outside storage must be selected to print Licenses';
          exsr zzsave;
          leavesr;
        endif;
      /end-free
SWTaA*
SWTaA*      Southwest Traders must enter lot code if imlot = Y
SWTaA*
SWTaA /free
SWTaA   if client = SWT   and
SWTaA      $imlot = 'Y'   and
740cD      //plot = ' ';
740cM      plot = ' '  or
740cA      oplotr = 'Y' and $imlot = 'Y' and plot = ' ';
SWTaA     error = *on;
SWTaA     pMessage = '';
SWTaA     pMessage ='Lot Must be Entered';
SWTaA     exsr zzsave;
SWTaA     leavesr;
SWTaA   endif;
SWTaA /end-free
     *
BADaA*
BADaA*      Big Apple Deli must enter lot code if imlot = Y
BADaA*
BADaA /free
BADaA   if client = BigApple  and
BADaA      $imlot = 'Y'   and
BADaA      plot = ' ';
BADaA     error = *on;
BADaA     pMessage = '';
BADaA     pMessage ='Lot Must be Entered';
BADaA     exsr zzsave;
BADaA     leavesr;
BADaA   endif;
BADaA /end-free
     *
      /free
        if pNDqtchk1w <> 'Y';
          pNDqtchk1w = ' ';
        endif;
      /end-free
     C                   if        client = sgc
     C*  Error if pallet qty > tie/hi qty.
     C                   z-add     0             maxqty
     C     $imtie        mult      $imhigh       maxqty
     C                   if        w1qrc1 > 0
     C     w1qrc1        div       w1plts        ckqrc1
     C                   endif
     C                   if        w1qrc2 > 0
     C     w1qrc2        div       w1plts        ckqrc1
     C                   endif
     C                   if        svckq1 <> ckqrc1
     C                   eval      qtchk1 = *off
     C                   endif
     *
     C                   if        qtchk1 = '2'  and
     C                             pqtchk1w = 'Y'
     c                   eval      pNDqtchk1w = 'Y'
     C                   eval      qtchk1 = *on
     C                   endif
     *
     C                   if        qtchk1 <> '1'
     C                   eval      qtchk1 = *on
      /free
        if ckqrc1 > maxqty
           and maxqty > 0;
          qtchk1 = '2';
          warn = *on;
          error = *on;
          pMessage = '';
          pMessage = 'Valid range for Tie/Hi Qty on Pallet is 1 to ' +
                      %char(maxqty) ;
          pNDqtchk1w  = 'N';
          pqtchk1w  = 'N';
        endif;
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     C                   endif
      /free
        // at this point if uci receiving - don't do any more edits
        // until the user has completed the license.
        // at this point need to write uciinfo records
        if $ifrcvmth = '2' and pucidone <> 'Y';
          // for now I am putting in temp code - this will need to
         // be updated for the final edits
          exsr zzucircv;
          leavesr;
        endif;
      /end-free
     *
     *  Warning:
     *
      /free
        if pNDqtchkw <> 'Y';
          pNDqtchkw = ' ';
        endif;
      /end-free
     C     w1qrc1        add       pdqrc1        svqrc1
     C     w1qrc2        add       pdqrc2        svqrc2
     C     w1qrc3        add       pdqrc3        svqrc3
     *
     *    Accumulate total exceptions to include in qty test.
     C                   exsr      zzttle
     *  Quantity.
      /free
        if sdqrc1 <> w1qrc1  or
           sdqrc2 <> w1qrc2  or
           sdqrc3 <> w1qrc3;
          qtchk = *off;
          // turn off qtchk parms - edits occur once qty is changed
          pdtchkw = ' ';
          pNDdtchkw = 'Y';
        endif;
      /end-free
     *
     C                   if        qtchk = '2'  and
     C                             pqtchkw = 'Y'
     c                   eval      pNDqtchkw = 'Y'
     C                   eval      qtchk = *on
     C                   endif
     *
     C                   if        qtchk <> '1'
     C                   eval      qtchk = *on
     *
      /free
        select;
          when pucidone = 'Y';
            // for uci receiving we don't warn on quantity ordered because
            // they are receiving one pallet at a time.
          other;
            if svqrc1 < pdqor1  or
               svqrc2 < pdqor2  or
               svqrc3 < pdqor3;
              warn = *on;
              error = *on;
              qtchk = '2';
              pMessage = '';
              pMessage = 'Warning, Quantity Received is not equal to +
                          Quantity ordered';
              pNDqtchkw  = 'N';
            endif;
            if svqrc1 > pdqor1  or
               svqrc2 > pdqor2  or
               svqrc3 > pdqor3;
              warn = *on;
              error = *on;
              qtchk = '2';
              pMessage = '';
              pMessage = 'Warning: Quantity received is greater than +
                         quantity ordered';
              pNDqtchkw  = 'N';
            endif;
        endsl;
        if error;
          exsr zzsave;
          leavesr;
        endif;
      /end-free
     C                   endif
     *
         // offsite storage print
      /free
         if osscode <> ' ';
700eA    if pBrandItm <> ' ';
700eA      ossItem = pBrandItm;
700eA    else;
700eA      ossItem = pPOItem;
700eA    endif;
           po840 (pWhse: $itwhdp: posscode: possplates: possprint:
700eD             //blanklcns: Expd: w1stat: possdev: ppoitem: $itstyp:
700eM             blanklcns: Expd: w1stat: possdev: ossitem: $itstyp:
700eD             //$itdesc);
700eM             $itdesc: pSessId: pUser);
         endif;
750bA    if directed = 'Y' and error = *off and rc160good = '0';
750dA      // need to setup expiration date
750dA      if w1exdt = 0;
750dA        $rexpd = 0;
750dA      else;
750dA        $rexpd = expd;
750dA      endif;
750bA      exsr SpecialRCV;
750bA      if $rrtn <> '*OK   ';
750bA        error = *on;
750bA        rcverr = *on;
750bA        select;
750bA          when $rrtn = '*INVALID';
750bA            pmessage = 'Invalid item Number';
750bA          when $rrtn = '*NOOPT  ';
750bA            pmessage = 'No Receiving options defined';
750bA          when $rrtn = '*NODEF  ';
750bA            pmessage = 'No Tie/High defs defined for item';
750bA          when $rrtn = '*NODEF2 ';
750bA            pmessage = 'No Tie/High defs large enough for qty';
750bA          when $rrtn = '*NOSLOT ';
750bA            pmessage = 'No slots available for item';
750bA          when $rrtn = '*NOTENGH';
750bA            pmessage = 'Not enough slots available for item';
750bA          other;
750bA            pmessage = $rrtn;
750bA        endsl;
750bA        exsr zzsave;
750bA        leavesr;
750bA      else;
750bA        rc160good = '1';
750bA      endif;
750bA    endif;
      /end-free
     C     enderr        tag
     *
     *   Save screen fields.
     C                   eval      svdwgt = w1dwgt
     C                   eval      sdqrc1 = w1qrc1
     C                   eval      sdqrc2 = w1qrc2
     C                   eval      sdqrc3 = w1qrc3
     C                   eval      svmfdt = w1mfdt
     C                   eval      svexdt = w1exdt
     C                   eval      svupc = w1upcd
     C                   eval      svckq1 = ckqrc1
     C                   eval      svpti  = w1pti
      /free
        hotype = 'PODTL';
        Select;
          when pucidone = 'Y';
            pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                  + %trim(pPOItem) + 'UCIHOLD';
          other;
            pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        endsl;
        chain (psessid: hotype: pokey) pirhold;
        hodata = pirhldpods;
        if %found(pirhold);
          update horec;
        else;
          exsr getcurrstamp;
          hoaddts = currstampsys;
          hoadduc = currstampuc;
          hosess = psessid;
          hokey = pokey;
          write horec;
        endif;
      /end-free
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZTTLE   Accumlate total exception quantity.
     *
     C     zzttle        begsr
     *
      /free
        setll (pwhse: pPO: pPOseq: pPOItem) poexcp;
        dow forevr = forevr;
          reade (pwhse: pPO: pPOseq: pPOItem) poexcp;
          select;
            When %eof(poexcp);
              leave;
            other;
              eval svqrc1 = svqrc1 + peqex1;
              eval svqrc2 = svqrc2 + peqex2;
              eval svqrc3 = svqrc3 + peqex3;
          endsl;
        enddo;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
     *
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
     *     Compare total catchweight to expected catchweight
     *
     *
     C                   if        lvskp = *off
     C                             and wotcw < lwrng
     C                             and opwrncr = 'Y'
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   eval      CW_exrngl = erlrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   eval      CW_exrngh = erhrng
     C                   else
     C                   eval      erhrng = hirng
     C                   eval      CW_exrngh = erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
      /free
        select;
          when client = Dairyland;
            pMessage = '';
            //pMessage = 'Warning: Tot c/w ' + %char(WOTCW) +
            pMessage = 'Error: Tot c/w ' + %char(WOTCW) +
                       ' is not within -/+ range of ' + %char(CW_EXRNGL) +
                       ' / ' + %char(CW_EXRNGH);
            //pNDwtchkw  = 'N';
            pNDwtchkw  = 'Y';
          other;
            pMessage = '';
            pMessage = 'Warning: Tot c/w ' + %char(WOTCW) +
                       ' is not within -/+ range of ' + %char(CW_EXRNGL) +
                       ' / ' + %char(CW_EXRNGH);
            pNDwtchkw  = 'N';
        endsl;
      /end-free
     C                   endif
     *
     C                   if        hvskp = *off
     C                             and wotcw > hirng
     C                             and opwrncr = 'Y'
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   eval      CW_exrngl = erlrng
     C                   else
     C                   eval      erlrng = lwrng
     C                   eval      CW_exrngl = erlrng
     C                   endif
     C                   eval      erhrng = hirng
     C                   eval      CW_exrngh = erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
      /free
        select;
          when client = Dairyland;
            pMessage = '';
            //pMessage = 'Warning: Tot c/w ' + %char(WOTCW) +
            pMessage = 'Error: Tot c/w ' + %char(WOTCW) +
                       ' is not within -/+ range of ' + %char(CW_EXRNGL) +
                       ' / ' + %char(CW_EXRNGH);
            //pNDwtchkw  = 'N';
            pNDwtchkw  = 'Y';
          other;
            pMessage = '';
            pMessage = 'Warning: Tot c/w ' + %char(WOTCW) +
                       ' is not within -/+ range of ' + %char(CW_EXRNGL) +
                       ' / ' + %char(CW_EXRNGH);
            pNDwtchkw  = 'N';
        endsl;
      /end-free
     C                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT1  Screen 3 error checks:
     *           1. Compare imported cw to entered cw.
     *           2. Compare ordered qty to received qty.
     *
     C     zzchkt1       begsr
     *
     C                   if        hvskp = *off
     C                             and opwrncr = 'Y'
     C                             and caltol1 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   eval      CW_exrngl = 0
     C                   eval      CW_exrngh = caltol1
     C                   eval      caltol1x100 = caltol1 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      pMessage = 'Wgt tol% '
     C                                      + %triml(%editc(caltol1x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   goto      endckt1
     C                   endif

     C                   if        hvskp = *off
     C                             and opwrncr = 'Y'
     C                             and caltol2 >= prg2c
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   eval      CW_exrngl = 0
     C                   eval      CW_exrngh = caltol2
     C                   eval      caltol2x100 = caltol2 * 100
     C                   eval      errg2c = prg2c * 100

     C                   eval      pMessage = 'Qty tol% '
     C                                      + %triml(%editc(caltol2x100:'3'))
     C                                      + ' >= var% '
     C                                      + %triml(%editc(errg2c:'3'))
     C                   goto      endckt1
     C                   endif

     C     endckt1       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     *
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     C                   endif
     C                   if        w1upcd <> *blanks  and
     C                             w1upc <> *blanks
      /free
700cA   if pBrandItm <> ' ';
700cA     chain (pwhse: pBrandItm: w1upc: phven) upc3;
700cA   else;
          chain (pwhse: pPOitem: w1upc: phven) upc3;
700cA   endif;
        if not %found(upc3);
          *in79 = *on;
        else;
          *in79 = *off;
        endif;
      /end-free
     C                   if        *in79
     C                   eval      upwhse = pWhse
700cAc                   if        pBrandItm <> ' '
700cAC                   eval      upitem = pBrandItm
700cAc                   else
     C                   eval      upitem = pPOItem
700cAc                   endif
750eA *** see  if there is a barcode maintenance for the po vendor
750eA *** if so we only want to load the gtin to the upc file as upupc
750eAC                   call      'CVTBAR'
750eAC                   parm      '*ALL'        $cbcmd            8
750eAC                   parm      W1UPC         $cbbar          100
750eAC                   parm                    $cbcod            3 0
750eAC                   parm                    $cbdec            1 0
750eAC                   parm                    $cbdsc           30
750eAC                   parm                    $cbpos            3 0
750eAC                   parm                    $cbtyp            1 0
750eAC                   parm                    $cbv1            11 3
750eAC                   parm                    $cbv2            50
750eAC                   parm                    $cbrtn            8
750eAC                   parm                    $cberm           60
750eAC                   parm      PHVEN         $cbven           10 0
750eAC                   parm                    $cvtdata
750eAC                   parm                    $cvtdata2
750eAC                   parm                    $cbwhse
750eAC                   parm                    $cbkilolbsSent
750eAC                   parm                    $cbItem
     *
750eAC                   eval      $barcode = $cvtdata
750eAC                   eval      $barcode2 = $cvtdata2
750eAc                   if        $bcGtinSent
750eAC                   move      $bcGtin       $cstr
750eAC                   call      'ADJUST'
750eAC                   parm      '*RIGHT  '    $ccmd             8
750eAC                   parm                    $cstr            30
750eAC                   eval      w1upc = *blanks
750eAC                   move      $cstr         w1upc
750eAC                   eval      upupc = w1upc
750eAc                   else
750eAc**
     C                   eval      upupc = w1upc
750eAc                   endif
     C                   eval      upven = phven
     C                   eval      upvnam = phvnam
     C                   eval      upvitm = pdvitm
     C                   eval      upbran = *blanks
700iAc                   eval      ntype = %trimr($cbdsc)
700iA * load new upc fields
700iA /free
700iA   select;
700iA     when      w1qrc1 > 0;
700iA       eval      upuom = $itum1;
700iA       eval      uputyp = 'N';
700iA     when      w1qrc2 > 0;
700iA       eval      upuom = $itum2;
700iA       eval      uputyp = '1';
700iA     when      w1qrc3 > 0;
700iA       eval      upuom = $itum3;
700iA       eval      uputyp = '2';
700iA   endsl;
700iA   Select;
700iA     when ntype = 'UPC-12';
700iA       upctyp = '1';
700iA     when ntype = 'EAN-13';
700iA       upctyp = '2';
700iA     when ntype = 'GTIN';
700iA       upctyp = '3';
700iA     when ntype = 'SCC-14';
700iA       upctyp = '4';
700iA     when ntype = 'SSCC-18';
700iA       upctyp = '5';
700iA   endsl;
700iA   Select;
700iA     when ntype = 'UPC-12';
700iA       upctyp = '1';
700iA     when ntype = 'EAN-13';
700iA       upctyp = '2';
700iA     when ntype = 'GTIN';
700iA       upctyp = '3';
700iA     when ntype = 'SCC-14';
700iA       upctyp = '4';
700iA     when ntype = 'SSCC-18';
700iA       upctyp = '5';
700iA   endsl;
700iA /end-free
     *
     *   Add record
     *
     C                   write     uprec                                78
     C                   if        *in78
     C                   eval      error = *on
      /free
        pMessage = '';
          pMessage = 'Record was not added to the UPC file';
      /end-free
     C                   goto      endup1
     C                   endif
     C                   endif
     c                   if        client = birite
CFIbAc                             or client = Colony
     c                   exsr      outlog
     c                   endif
     C                   endif
     *
     C                   eval      $rven = phven
     C                   eval      $rvnam = phvnam
     *
     *   Call receiving program, if this is a replenishment type
     *   of transfer.(Customer order# blank)
     *
     C                   if        w1exdt = 0
     C                   eval      $rexpd = 0
     C                   else
     C                   eval      $rexpd = expd
     C                   endif
     *
     C                   exsr      zzzcw
     C                   if        w1twgt <> 0 and $ifrcvmth <> '2'
     C                   exsr      zzucichk
     C                   endif
     *
     *   If not a FSWMS item, don't put away only update PODTL
     *
     C                   if        iaflag = *on
     C                   eval      $rpo = ppo
     C                   eval      $rseq = pPOSeq
     C                   eval      $rslot = w1slot
     *
     C                   call      'RC161'
     C                   parm      '*RECEIVE'    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    pwhse
     C                   parm                    pPOitem
     C                   parm      w1qrc1        $rqrc1            5 0
     C                   parm      w1qrc2        $rqrc2            5 0
     C                   parm      w1qrc3        $rqrc3            5 0
     C                   parm                    $rpo              9
     C                   parm                    $rven            11 0
     C                   parm                    $rvnam           40
     C                   parm                    w2vitm           15
     C                   parm      0             $rord             7 0
     C                   parm      *blanks       $rrcod            2
     C                   parm      *blanks       $rrmem           30
     C                   parm      $rexpd        $expd             8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $rslot           12
     C                   parm                    $rseq             5 0
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm      w1twgt        $rtwgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
730aAC                   parm                    puser
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup1
     C                   endif
     C                   goto      jmpup1
     C                   endif
     *
      * special receiving situations
      /free
        sprcv = '0';
        select;
          when PSRcvReq = 'Y';
            sprcv = '1';
            exsr SpecialRCV;
          when Psrusr = 'Y';
            sprcv = '1';
            exsr SpecialRCV;
          when directed = 'Y';
750bA       rc160good = '0';
750bD       //exsr SpecialRCV;
750bD       //if $rrtn = '*PGMQ   ';
750bD         //error = *on;
750bD         //rcverr = *on;
750bD       //endif;
        endsl;
      /end-free
     C                   eval      $lord = $rord
     *    Lot tracking item - Pass single char flag to license entry pgm
     C                   if        lottrk = '*YES'
     C                   eval      $llott = 'Y'
     C                   else
     C                   eval      $llott = 'N'
     C                   endif
     *    Lic.tracking item - Pass single char flag to license entry pgm
     C                   if        lictrk = '*YES'
     C                   eval      $llict = 'Y'
     C                   else
     C                   eval      $llict = 'N'
     C                   endif
     *    Convert fifo date into yyyymmdd.
     C                   if        w1fifo = 0
     * if westside don't clear wofifo
     C                   if        client = westside and wofifo > 0
     c                   else
     C                   eval      wofifo = 0
     c                   endif
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fifo        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        wofifo
     C                   endif
     * Move mfg or expire or fifo date to keyed in date field
     * to send to PO236
     C                   eval      woindt = 0
     C                   select
     C                   when      w1fifo <> 0
     C                   eval      woindt = wofifo
     C                   when      w1mfdt <> 0
     C                   eval      woindt = womfdt
     C                   other
     C                   eval      woindt = woexdt
     C                   endsl
      /free
         hotype = 'PODTL';
         Select;
           when pucidone = 'Y';
             pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                   + %trim(pPOItem) + 'UCIHOLD';
           other;
             pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                   + %trim(pPOItem);
         endsl;
         chain (psessid: hotype: pokey) pirhold;
         hodata = pirhldpods;
         if %found(pirhold);
           update horec;
         else;
           exsr getcurrstamp;
           hoaddts = currstampsys;
           hoadduc = currstampuc;
           hosess = psessid;
           hokey = pokey;
           write horec;
         endif;
      /end-free
     *
     *    Write records to POMFR file.
     *    Note: RC160 returns batch number in $RORD field which is
     *          used as first part of the LBKEY.
     *
      * load new file pocwexcp
      /free
        ///cw_exwhse = lbwhse;
        ///cw_expo = lbpo;
        ///cw_exseq = lbseq;
        ///cw_exitem = lbitem;
        ///cw_extrn# = lbtrn#;
        ///cw_exlbl# = lblbl#;
        ///cw_exwgt = W1DWGT;
        ///cw_exgdte = lbsdte;
        ///cw_exgtim = lbstim;
        ///cw_exrg1c = prg1c * 100;
        ///cw_exrg2c = prg2c * 100;
        ///cw_exswgt = exwgt;
        ///select;
          ///when imrg1c > 0;
            ///cw_exrg1w = 'I';
          ///when oprg1c > 0;
            ///cw_exrg1w = 'S';
          ///other;
            ///cw_exrg1w = 'P';
        ///endsl;
        ///select;
          ///when imrg2c > 0;
            ///cw_exrg2w = 'I';
          ///when oprg2c > 0;
            ///cw_exrg2w = 'S';
          ///other;
            ///cw_exrg2w = 'P';
        ///endsl;
          ///write cwexrec;
      /end-free
     *
     *   Need to deal with x-dock or pick slot receiving
     *
      /free
        // write out lcns record to pirhold so M13700U can process
        // write one record for each uom
        select;
          when $ifrcvmth = '2' and pucidone = 'Y';
            if w1qrc1 > 0;
              hotype = 'POLCNS';
              pokey = plcns;
              chain (psessid: hotype: pokey) pirhold;
              h1xdk = ' ';
              h1PSR = ' ';
              h1qty = w1qrc1;
              h1uom = w1um1;
              h1umt = 'N';
              if directed = 'Y';
                exsr getlabel2;
              endif;
              hodata = pirhllcnds;
              if %found(pirhold);
                error = *on;
                pmessage = 'License is already in file';
                return;
              else;
                exsr getcurrstamp;
                hoaddts = currstampsys;
                hoadduc = currstampuc;
                hosess = psessid;
                hokey = pokey;
                write horec;
              endif;
            endif;
            // call the update program M13700U
            ulcns    = ' ';
            uqty     = 0;
            uuom     = ' ';
            udone    = 'U';
            m13700u(pmessage :
                    psessid :
                    puser :
                    ppgm :
                    pwhse :
                    pPO :
                    pposeq :
                    ppoitem :
                    ulcns :
                    uqty  :
                    uuom  :
                    udone );
            // if no errors in M13700u update, turn off moretoscan
            if pmessage = ' ';
              moretoscan = ' ';
            endif;
          other;
            blanklcns = ' ';
            xdockkey  = ' ';
710gD       //if pdspcl = 'XD' or sprcv = '1';
720aD       //if pdspcl = 'XD' or sprcv = '1' or w1stat = 'XD';
720aM       if pdspcl = 'XD' or sprcv = '1' or w1stat = 'XD'
720aA                        or livestat = '*NOTLIVE'
CSPaA                        or  client = CoastalSunbelt and
CSPbD                            //$itdesg = 'JIT'
CSPbM                            ($itdesg = 'JIT' or $itdesg = 'PC')
720bA                        or iatest = '*';
              if w1qrc3 > 0;
                select;
                  when pdspcl = 'XD';
                    xdockkey = 'XDOCK' + w1um3;
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPbA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               xdockkey = 'XDOCK' + w1um3;
710gA             when w1stat = 'XD';
710gA               xdockkey = 'XDOCK' + w1um3;
                  when sprcv = '1';
                    xdockkey = 'SPRCV' + w1um3;
                endsl;
                hotype = 'POLCNS';
                pokey = blanklcns + xdockkey;
                chain (psessid: hotype: pokey) pirhold;
                select;
                  when pdspcl = 'XD';
                    h1xdk = 'Y';
                    h1PSR = ' ';
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPbA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               h1xdk = 'Y';
CSPaA               h1PSR = ' ';
710gA             when w1stat = 'XD';
710gA               h1xdk = 'Y';
710gA               h1PSR = ' ';
                  when sprcv = '1';
                    h1xdk = ' ';
                    h1PSR = 'Y';
                  other;
                    h1xdk = ' ';
                    h1PSR = ' ';
                endsl;
                h1qty = w1qrc3;
                h1uom = w1um3;
                h1umt = '2';
                exsr getlabel2;
                hodata = pirhllcnds;
                if %found(pirhold);
                  error = *on;
                  pmessage = 'License is already in file';
                  return;
                else;
                  exsr getcurrstamp;
                  hoaddts = currstampsys;
                  hoadduc = currstampuc;
                  hosess = psessid;
                  hokey = pokey;
                  write horec;
                endif;
              endif;
              blanklcns = ' ';
              xdockkey  = ' ';
              if w1qrc2  > 0;
                select;
                  when pdspcl = 'XD';
                    xdockkey = 'XDOCK' + w1um2;
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPbA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               xdockkey = 'XDOCK' + w1um2;
710gA             when w1stat = 'XD';
710gA               xdockkey = 'XDOCK' + w1um2;
                  when sprcv = '1';
                    xdockkey = 'SPRCV' + w1um2;
                endsl;
                hotype = 'POLCNS';
                pokey = blanklcns + xdockkey;
                chain (psessid: hotype: pokey) pirhold;
                select;
                  when pdspcl = 'XD';
                    h1xdk = 'Y';
                    h1PSR = ' ';
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPbA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               h1xdk = 'Y';
CSPaA               h1PSR = ' ';
710gA             when w1stat = 'XD';
710gA               h1xdk = 'Y';
710gA               h1PSR = ' ';
                  when sprcv = '1';
                    h1xdk = ' ';
                    h1PSR = 'Y';
                  other;
                    h1xdk = ' ';
                    h1PSR = ' ';
                endsl;
                h1qty = w1qrc2;
                h1uom = w1um2;
                h1umt = '1';
                exsr getlabel2;
                hodata = pirhllcnds;
                if %found(pirhold);
                  error = *on;
                  pmessage = 'License is already in file';
                  return;
                else;
                  exsr getcurrstamp;
                  hoaddts = currstampsys;
                  hoadduc = currstampuc;
                  hosess = psessid;
                  hokey = pokey;
                  write horec;
                endif;
              endif;
              blanklcns = ' ';
              xdockkey  = ' ';
              if w1qrc1 > 0;
                select;
                  when pdspcl = 'XD';
                    xdockkey = 'XDOCK' + w1um1;
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPbA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               xdockkey = 'XDOCK' + w1um1;
710gA             when w1stat = 'XD';
710gA               xdockkey = 'XDOCK' + w1um1;
                  when sprcv = '1';
                    xdockkey = 'SPRCV' + w1um1;
                endsl;
                hotype = 'POLCNS';
                pokey = blanklcns + xdockkey;
                chain (psessid: hotype: pokey) pirhold;
                select;
                  when pdspcl = 'XD';
                    h1xdk = 'Y';
                    h1PSR = ' ';
CSPbD             //when client = CoastalSunbelt and $itdesg = 'JIT';
CSPbM             when client = CoastalSunbelt and
CSPaA                  ($itdesg = 'JIT' or $itdesg = 'PC');
CSPaA               h1xdk = 'Y';
CSPaA               h1PSR = ' ';
710gA             when w1stat = 'XD';
710gA               h1xdk = 'Y';
710gA               h1PSR = ' ';
                  when sprcv = '1';
                    h1xdk = ' ';
                    h1PSR = 'Y';
                  other;
                    h1xdk = ' ';
                    h1PSR = ' ';
                endsl;
                h1qty = w1qrc1;
                h1uom = w1um1;
                h1umt = 'N';
                exsr getlabel2;
                hodata = pirhllcnds;
                if %found(pirhold);
                  error = *on;
                  pmessage = 'License is already in file';
                  return;
                else;
                  exsr getcurrstamp;
                  hoaddts = currstampsys;
                  hoadduc = currstampuc;
                  hosess = psessid;
                  hokey = pokey;
                  write horec;
                endif;
              endif;
              // call the update program M13700U
              ulcns    = ' ';
              uqty     = 0;
              uuom     = ' ';
              udone    = 'Y';
              m13700u(pmessage :
                      psessid :
                      puser :
                      ppgm :
                      pwhse :
                      pPO :
                      pposeq :
                      ppoitem :
                      ulcns :
                      uqty  :
                      uuom  :
                      udone );
            endif;
        endsl;
      /end-free
     *
     *   Move key values to parameters
     *
     C     jmpup1        tag
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZmfrdates  Set manufactures dates
     *
     C     zzmfrdates    begsr
     c                   select
     c                   when      $lmfrdat > 0 and $ldecvalue > ' '
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lmfrdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout


     *
     *  Calculate Mfg date if mfg exp date is entered
     *
     c                   when      $lexpdat > 0 and $ldecvalue > ' '

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $lexpdat      $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
     C                   eval      wkmday = $immday
     *  Use By date -1 to be used as mfg shelf life days
     C                   if        client = yhata
     C                   if        $immday = 0
     C                             and $imoday > 0
     C                   eval      wkmday = $imoday - 1
     C                   endif
     C                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout
     c                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   when      w1mfdt > 0 and $itflgd = 'Y'
     *
     *  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mfgdte

     *  Create mfg expiration date mfgdate + mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      mfgdte        $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mexpd         parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   when      w1exdt > 0

     *
     *  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1exdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        mexpd
     C                   eval      wkmday = $immday
     *  Use By date -1 to be used as mfg shelf life days
     C                   if        client = yhata
     C                   if        $immday = 0
     C                             and $imoday > 0
     C                   eval      wkmday = $imoday - 1
     C                   endif
     C                   endif

     *  Create mfg date - date mfg exp date - mfg shelf life days

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      mexpd         $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      wkmday        $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     mfgdte        parm      0             $cddateout
     C                   parm      0             $cdtimeout

     c                   if        wkmday = 0
     c                   eval      mfgdte = 0
     c                   endif

     c                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Outlog - Write UPCLOG Record for BiRite.
     *
     c     outlog        begsr
     *
      /free
        chain (pwhse: pPOitem: w1upc: phven) upclog;
      /end-free
     c                   if        Not %Found(upclog)
     *
     c                   eval      ulwhse = pWhse
     c                   eval      ulitem = pPOItem
     c                   eval      ulupc  = w1upc
     c                   eval      ulven  = phven
     c                   eval      ulvnam = upvnam
     c                   eval      ulvitm = upvitm
     c                   eval      ulbran = upbran
     c                   eval      ulpo   = ppo
     c                   eval      ulposq = pPOSeq
     c                   eval      uladte = today
     c                   time                    ulatim
     c                   eval      uluser = #user
     c                   eval      uljob  = #job
     c                   eval      uljob# = #jobn
     c                   write     ulrec
     *
     c                   endif
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCW    Calculate catch weight
     *
     *
     *  Action Table
     *
     *   VRFYCW  SVCWEN  SVCWTP  W1AVG  POCTYP  Action
     *   ------  ------  ------  -----  ------  --------------------
     *     Y       1       1       N       -    CW = Calc1
     *
     *     Y       1       1       Y       -    CW = Calc2
     *
     *     Y       1       2       -       -    CW = Calc1
     *
     *     Y       1       3       -       -    CW = Calc2
     *
     *     Y       2       1       N       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       1       Y       -    CW = Calc3
     *                                          Write POCTYP = 'A'
     *
     *     Y       2       2       -       -    CW = Calc1
     *                                          Write POCTYP = 'T'
     *
     *     Y       2       3       -       -    Not allowed
     *
     *     N       1       -       -       -    Not allowed
     *
     *     N       2       -       -       T    None
     *
     *     N       2       -       -       A    CW = Calc3
     *
     *     N       3       -       -       -    None
     *
     *  Keys:
     *
     *   SVCWEN - 1=Every time, 2=First time only, 3=Never
     *   SVCWTP - 1=Choice, 2=Total, 3=Average
     *   Calc1  - Entered weight
     *   Calc2  - Qty * Entered weight
     *   Calc3  - Qty * Item weight
     *
     *----------------------------------------------------------------
     C     zzzcw         begsr
     *
     C                   eval      w1twgt = 0
     C                   eval      avgwt1 = 0
     C                   eval      avgwt2 = 0
     C                   eval      avgwt3 = 0
     C                   eval      cwcalc = 0
     C                   eval      wrttyp = ' '
     *
     *   Get POCTYPE record.
     *
     C                   if        svcwen = '2'
      /free
        chain(n) (pwhse: pPO: pPOseq) poctype;
        if not %found(poctype);
          poctyp = 'T';
        endif;
      /end-free
     C                   endif
     *
     *   Determine what needs to be done based on table.
     *
     C                   select
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '1'  and
     C                             svcwtp = '3'
     C                   eval      cwcalc = 2
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'N'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '1'  and
     C                             w1avg = 'Y'
     C                   eval      cwcalc = 3
     C                   eval      wrttyp = 'A'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '2'
     C                   eval      cwcalc = 1
     C                   eval      wrttyp = 'T'
     *
     C                   when      vrfycw = *on  and
     C                             svcwen = '2'  and
     C                             svcwtp = '3'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '1'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'T'
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '2'  and
     C                             poctyp = 'A'
     C                   eval      cwcalc = 3
     *
     C                   when      vrfycw = *off  and
     C                             svcwen = '3'
     *
     C                   endsl
     *
     *   Calculate catch weight.
     *
     C                   select
     *
     *     Straight total.
     *
     C                   when      cwcalc = 1
     C                   eval      w1twgt = cnvwgt
     C                   select
     C                   when      w1qrc1 > 0
     C     cnvwgt        div       w1qrc1        avgwt1
     C                   when      w1qrc2 > 0
     C     cnvwgt        div       w1qrc2        avgwt1
     C                   when      w1qrc3 > 0
     C     cnvwgt        div       w1qrc3        avgwt1
     C                   endsl
     *
     *     Entered quantity * Entered weight.
     *
     C                   when      cwcalc = 2
     C                   select
     C                   when      w1qrc1 > 0
     C     cnvwgt        mult      w1qrc1        w1twgt
     C                   when      w1qrc2 > 0
     C     cnvwgt        mult      w1qrc2        w1twgt
     C                   when      w1qrc3 > 0
     C     cnvwgt        mult      w1qrc3        w1twgt
     C                   endsl
     C                   z-add     cnvwgt        avgwt1
     *
     *     Entered quantity * Item weight.
     *
     C                   when      cwcalc = 3
     *
     *       Normal qty for non-SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype <> 'S'
     C     #oswgt        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswgt
     C                   endif
     *
     *       Normal qty for SSB items.
     *
     C                   if        w1qrc1 > 0  and
     C                             #otype = 'S'
     C     #oswt2        mult      w1qrc1        w1twgt
     C                   eval      avgwt1 = #oswt2
     C                   endif
     *
     *       Brk1 qty for non-SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype <> 'S'
     C     #oswt2        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt2
     C                   endif
     *
     *       Brk1 qty for SSB items.
     *
     C                   if        w1qrc2 > 0  and
     C                             #otype = 'S'
     C     #oswt3        mult      w1qrc2        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt2 = #oswt3
     C                   endif
     *
     *       Brk2 qty for non-SSB items.
     *
     C                   if        w1qrc3 > 0  and
     C                             #otype <> 'S'
     C     #oswt3        mult      w1qrc3        tmpwgt
     C                   add       tmpwgt        w1twgt
     C                   eval      avgwt3 = #oswt3
     C                   endif
     *
     C                   endsl
     *
     *   Write POCTYPE record.
     *
      /free
        if wrttyp <> ' ';
          chain (pwhse: pPO: pPOseq) poctype;
          if %found(poctype);
            poctyp = wrttyp;
            update pocrec;
          else;
            pocwhs = pWhse;
            pocpo = ppo;
            pocseq = pPOSeq;
            poctyp = wrttyp;
            write pocrec;
          endif;
        endif;
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZsave   Save all the data in pirhold
     *
     C     zzsave        begsr
     *
     *   Save screen fields.
      /free
        svdwgt = w1dwgt;
        sdqrc1 = w1qrc1;
        sdqrc2 = w1qrc2;
        sdqrc3 = w1qrc3;
        svmfdt = w1mfdt;
        svexdt = w1exdt;
        svupc = w1upcd;
        svckq1 = ckqrc1;
        svpti  = w1pti;
700hA   // clear out work fields
700hA   if $immflg = 'Y';
700hA     w1exdt = 0;
700hA     expd   = 0;
700hA   endif;
        hotype = 'PODTL';
        Select;
          when pucidone = 'Y';
            pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                  + %trim(pPOItem) + 'UCIHOLD';
          other;
            pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        endsl;
        chain (psessid: hotype: pokey) pirhold;
        hodata = pirhldpods;
        if %found(pirhold);
          update horec;
        else;
          exsr getcurrstamp;
          hoaddts = currstampsys;
          hoadduc = currstampuc;
          hosess = psessid;
          hokey = pokey;
          write horec;
        endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  SpecialRCV  - Special receiving processing
     *
     C     SpecialRcv    begsr
     *   Try to put-away the item received.
     *
     C                   eval      $rpo = ppo
     C                   eval      $rseq = pPOSeq
     C                   eval      $rslot = w1slot
     C                   eval      rcverr = *off
     *
     *   Set command to send.
     C                   select
     C                   when      phvnam = 'MOVEIN'
     C                   eval      $rcmd = '*RECEIVE'
     C                   eval      $rfifo = wofifo
     C                   when      phvnam = move1
     C                   eval      $rcmd = '*MOVEINP'
     C                   eval      $rfifo = wofifo
     C                   when      phvnam = move2
     C                   eval      $rcmd = '*MOVEINO'
     C                   eval      $rfifo = wofifo
     C                   when      sprcv = '1'
     C                   eval      $rcmd = '*SPRECV '
     C                   eval      $rfifo = 0
     C                   other
     C                   eval      $rcmd = '*RECEIVE'
     C                   eval      $rfifo = 0
     C                   endsl
700cA /free
700cA   // setup item to be sent based on branded flag
700cA   If bBrandFlg = 'Y';
700cA     rc160Itm = pBrandItm;
700cA   else;
700cA     rc160Itm = ppoitem;
700cA   endif;
700cA /end-free
     C                   call      'RC160'
     C                   parm                    $rcmd
     C                   parm                    $rprg
750bDC*                  parm      '*INTER  '    $rtype
750bMC                   parm      '        '    $rtype
     C                   parm                    pwhse
700cDC*                  parm                    ppoitem
700cMc                   parm                    rc160Itm
     C                   parm      w1qrc1        $rqrc1
     C                   parm      w1qrc2        $rqrc2
     C                   parm      w1qrc3        $rqrc3
     C                   parm                    $rpo
     C                   parm                    $rven
     C                   parm                    $rvnam
     C                   parm                    w2vitm
     C                   parm      0             $rord
     C                   parm      *blanks       $rrcod
     C                   parm      *blanks       $rrmem
     C                   parm      $rexpd        $expd
     C                   parm                    $rfifo            8 0
     C                   parm                    $pdev
     C                   parm                    $pform
     C                   parm                    $rslot
     C                   parm                    $rseq
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm      w1twgt        $rtwgt            9 2
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
730hAC                   parm                    pUser
740bAC                   parm                    ppsrusr
     *  If error, then do not update transfer order file.
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      rcverr = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   else
     c                   eval      w1plts = $rrpal
     C                   add       $rrq1         $prsqt
     C                   add       $rrq2         $prsqt
     C                   add       $rrq3         $prsqt
     *
     C                   eval      $lflag = lflag
     C                   if        lflag = *off
     C                   eval      $lcmd = '*LICONLY'
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     C                   if        sprcv = *on
     C                   eval      $lcmd = '*STUFFIT'
     C                   endif
     C                   eval      $lwhse = pwhse
     C                   eval      $lpo = ppo
700cAc                   If        bBrandFlg = 'Y'
700cAC                   eval      $litem = pBrandItm
700cAc                   else
     C                   eval      $litem = pPOItem
700cAc                   endif
     C                   eval      $lrq1 = $rrq1
     C                   eval      $lrq2 = $rrq2
     C                   eval      $lrq3 = $rrq3
     C                   eval      $lrpal = $rrpal
     C                   eval      $lum1 = w1um1
     C                   eval      $lum2 = w1um2
     C                   eval      $lum3 = w1um3
     c                   endif
     C                   endsr

     *
     *----------------------------------------------------------------
     *
     *  GetLabel2   - Get the label record
     *
     C     GetLabel2     begsr
      /free
        // need to get the correct label/tran# to load to POLCNS re    cord
        setll ($lord) label2;
        dow not %eof(label2);
          reade ($lord) label2;
          if %eof(label2);
            leave;
          endif;
          if lb_lbutyp = h1umt
730dA        or  PSRcvReq = 'Y'
730dA        or  psrusr = 'Y';
            h1lbl = lb_lblbl#;
            h1trn = lb_lbtrn#;
            leave;
          else;
            iter;
          endif;
        enddo;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKLCNS  Check for active license
     *
     C     zzchklcns     begsr
     C                   eval      lcnsExists = *off

     *  See if license exists in licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
710gDc*                  if        xdockflg = ' '
710gMc                   if        xdockflg = ' ' and w1stat <> 'XD'
     C                   eval      $liToLcns = plcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err= *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl =  'OSS'
     C                             or $drireturn = 'INVLDLCNS'
     C                   eval      lcnsExists = *off
     C                   eval      error = *off
     *
     *  Check LICLOG before accepting this license
     *
     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
710gDc*                  if        xdockflg = ' '
710gMc                   if        xdockflg = ' '  and w1stat <> 'XD'
     C                   eval      $liToLcns = plcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $liOLcnsU = *on
710gDc*                  if        xdockflg = ' '
710gMc                   if        xdockflg = ' '  and w1stat <> 'XD'
     C                   eval      $liOLcns = plcns
     c                   else
     C                   eval      $liToLcns = templcns
     c                   endif
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETINFO'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err= *off
     C                   exsr      zzzdricop
     c* if we get an ok on the return this means it exist - don't use
     C                   if        $drireturn = '*OK'
     C                             and $liToAisl <> 'OSS'
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      pmessage = 'License Already Exist'
     C                   endif

     C                   leavesr
     C                   else
     C                   eval      lcnsExists = *on
     C                   eval      error = *on
     C                   eval      *in15 = *on
     c                   eval      pmessage = 'License Already Exist'
     C                   endif


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUCIRCV Write UCI data
     *
     C     zzucircv      begsr
     c                   if        $ldecvalue = ' '
     c                   exsr      zzmfrdates
     c                   endif
     C                   if        $immflg = 'Y'
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1mfdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        womfdt

     C                   if        client = Glazier
     C                   eval      $imuday = *zeros
     C                   endif

     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cdcmd
     C                   parm      expd          $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $immday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C                   parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $cdcmd
     C                   parm      $cddateout    $cddatein
     C                   parm      0             $cdtimein
     C                   parm      0             $cdyears
     C                   parm      0             $cdmonths
     C                   parm      $imuday       $cddays
     C                   parm      0             $cdhours
     C                   parm      0             $cdminutes
     C                   parm      0             $cdseconds
     C     expd          parm      0             $cddateout
     C                   parm      0             $cdtimeout

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      expd          $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1exdt

     *
     C                   endif
     * add records to uci file
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   eval      $code = pUser
     C                   eval      $whse = *zeros
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *blanks
     C                   eval      $rtn = *blanks
     C                   call      'GETUSER'
     C                   parm                    $code
     C                   parm                    $whse
     C                   parm                    $emp#
     C                   parm                    $fnam
     C                   parm                    $init
     C                   parm                    $lnam
     C                   parm                    $whdp
     C                   parm                    $styp
     C                   parm                    $shft
     C                   parm                    $crew
     C                   parm                    $nhrs
     C                   parm                    $rtn
      /free
        // need to determine if the licinfo record already exist for
        // this lcns/lot/exp date - keep checking until we find a match
        // or no more licinfo records exist - if no match and no licinfo
        // exist need to write the next available seq# to licinfo.
        // if licinfo record exist - just update the qty and the weight
        select;
          when moretoscan = *on and difflot = *on  or
               moretoscan = *on and diffexpd = *on;
            exsr zzlicinfochk;
          when moretoscan = *on and difflot <> *on and diffexpd <> *on;
            exsr zzlicinfoseq;
        endsl;

        if licinfoupd <> *on and difflot = *on or
           licinfoupd <> *on and diffexpd = *on or
           moretoscan <> *on;
          exsr zzlicinfonew;
        endif;

        // need to grab the uci scanned from the pirhold record
           pokey = ppo;
           exec sql select * into :horecuci
              from pirhold
              where hosess = :psessid
                and hotype = 'PODTLUCI'
                and hokey  = :pokey;
             If sqlstt = sqlSuccess;
               pirhlducds = U_hodata;
               // now get the extracted data from pirhold
               exec sql select * into :horecuci
                  from pirhold
                  where hosess = :psessid
                    and hotype = 'PODTLUCIE'
                    and hokey  = :pokey;
               If sqlstt = sqlSuccess;
                 pirhldueds = U_hodata;
                 $barcode = ucidata1;
                 $barcode2 = ucidata2;
               endif;
             else;
             endif;
        exsr clr$uciinfo;
        $uiWhse = pwhse;
        $uiItem = ppoitem;
        $uiuci = uciscanned;
        ucilic#($unext: pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
710gD   //if xdockflg = ' ';
710gM   if xdockflg = ' ' and w1stat <> 'XD';
          $uiLcns = plcns;
        else;
          $uiLcns = templcns;
        endif;
        if difflot = *on or
          diffexpd = *on;
          $uiseq = $lnseq;
        else;
          $uiseq = 1;
        endif;
        $uiSerial = $bcSer#;
        // if user entered weight use that/ if uci had weight use that
        select;
          when w1dwgt > 0;
700aD       //$uiwgtlbs = w1dwgt;
700aM       $uiwgtlbs = cnvwgt;
          when $bcPNtLbSent = *on;
            $uiwgtlbs = $bcPNtLb;
          other;
            $uiwgtlbs = 0;
        endsl;
        // Weight KG  - only if uci barcode contained KG
        if $bcPNtKgSent = *on;
          $uiWgtKgs = $bcPntKg;
        else;
          $uiWgtKgs = 0;
        endif;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelCSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '1';
720dA   if $bcGtin = *blanks;
720dA      $uiaGtin = 0;
720dA   else;
720dA      $uiaGtin   = %DEC($bcGTin:14:0);
720dA   endif;
720dA   $uiaLot    = $bclot;
720dA   workupc = blank6 + $bcGtin;
720dA   uputyp     = 'N';
720dA   exec sql select * into :uprecuom
720dA          from upc
720dA          where upwhse = :pwhse
720dA            and upITEM = :ppoitem
720dA            and upupc  = :workupc
720dA          fetch first row only;
720dA   $uiaUTyp   = uputyp;
720dA   $uiaSlUTyp = uputyp;
720dA   if saveexpd = 0;
720dA      $uiaExpD = expd;
720dA   else;
720dA      $uiaExpD = saveexpd;
720dA   endif;
720dA   $uiaEntD   = today;
720dA   // Lets add some more stuff for tracking
720dA   $uiaction = 'RCV';
720dA   $uiaolcns = $uilcns;
720dA   $uialcns = $uilcns;
720dA   $uiaoseq = $uiseq;
720dA   $uiscan = 'Y';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        chk4err= *on;
        zmflag  = *off;
        exsr zzzdricop;
        if error;
          uciExists = *on;
          error = *on;
          pmessage = $drimessage;
          //errmsg= desc(11);
          leavesr;
        else;
          UciExists = *off;
          error = *off;
          // if moretoscan is off - implies first uci is being processed
          // no errors scanned uci is now in uciinfo file.
          // replace the pirhold key for PODTLUCIE to add the license
          // this will be used to check for different dates/lots on
          // remaining uci scanned to this license
          if moretoscan <> *on;
            U_hokey = %trim(pPO) +  %trim(plcns);
            exec sql insert into pirhold values(:horecuci);
            If sqlstt = sqlSuccess;
            endif;
          endif;
        endif;

        // save the values from the first scan to be used for the license
        if moretoscan <> *on;
          if $immflg = 'Y';
            savew1mfdt = w1mfdt;
          else;
            savew1mfdt = 0;
          endif;
          if $itflgd = 'Y';
            savew1exdt = w1exdt;
          else;
            savew1exdt = 0;
          endif;
          saveexpd = expd;
          savelotc = w1lotc;
        endif;
700aD   //savewgt  = savewgt + w1dwgt;
700aM   savewgt  = savewgt + cnvwgt;
        saveqty  = saveqty + 1;
        // scan some more uci barcodes
        // save first scanned lot and dates
        moretoscan = *on;
        //$puci = ' ';
        //w1uci = ' ';
        savew1uci = ' ';
        savew1uci = ' ';
        ovrrid = *off;
        difflot = *off;
        diffexpd = *off;
        lotwarn = *off;
        UPCwarn = *off;
        expdwarn = *off;
        //lotovr  = *off;
        UPCovr  = *off;
        expdovr  = *off;
        licinfoupd = *off;

730eA   // Are we loading canopy gs1 labels that have been printed
730eA   chain (pSessId: $uiwhse: $uiserial: $uiuci) uciwork;
730eA   if %found(uciwork);
730eA     can_uiwload = 'Y';
730eA     update uiwrec;
730eA     // this is a canopy gs1 label we need to auto load the others
730eA     setll (can_uiwsess: can_uiwwhse) uciwork;
730eA     dow forever = forever;
730eA       reade (can_uiwsess: can_uiwwhse) uciwork;
730eA       if %eof(uciwork);
730eA         leave;
730eA       endif;
730eA       if can_uiwload = 'Y';
730eA         iter;
730eA       endif;
730eA       if can_uiwpo <> ppo;
730eA         iter;
730eA       endif;
730eA       if can_uiwposeq <> pposeq;
730eA         iter;
730eA       endif;
730eA       if can_uiwitem <> ppoitem;
730eA         iter;
730eA       endif;
730eA       if can_uiwprint <> 'Y';
730eA         iter;
730eA       endif;
730eA       // ready to auto load a uci
730eA       exsr clr$uciinfo;
730eA       $uiWhse = can_uiwwhse;
730eA       $uiItem = can_uiwitem;
730eA       $uiuci = can_uiwuci;
730eA       ucilic#($unext: pwhse);
730eA       unexta = %editc($unext:'X');
730eA       $uiuciLcns = 'U:' + unexta;
730eA       if xdockflg = ' ' and w1stat <> 'XD';
730eA         $uiLcns = plcns;
730eA       else;
730eA         $uiLcns = templcns;
730eA       endif;
730eA       //if difflot = *on or
730eA         //diffexpd = *on;
730eA         //$uiseq = $lnseq;
730eA       //else;
730eA       $uiseq = 1;
730eA       //endif;
730eA       $uiSerial = can_uiwserial;
730eA       $uiwgtlbs = can_uiwwgtlbs;
730eA       $uiWgtKgs = 0;
730eA       $uiSelTrn# = 0;
730eA       $uiSelLbl# = 0;
730eA       $uiSelOrd = 0;
730eA       $uiSelSeq = 0;
730eA       $uiSelCSeq = 0;
730eA       $uiSelTrax = ' ';
730eA       $uiCrtBy = '1';
730eA       $uiaGtin = %dec(can_uiwgtin:14:0);
730eA       $uiaLot  = ' ';
730eA       //workupc = blank6 + $bcGtin;
730eA       //uputyp     = 'N';
730eA       //exec sql select * into :uprecuom
730eA          //from upc
730eA          //where upwhse = :pwhse
730eA            //and upITEM = :ppoitem
730eA            //and upupc  = :workupc
730eA          //fetch first row only;
730eA       $uiaUTyp   = uputyp;
730eA       $uiaSlUTyp = uputyp;
730eA       if saveexpd = 0;
730eA          $uiaExpD = expd;
730eA       else;
730eA          $uiaExpD = saveexpd;
730eA       endif;
730eA       $uiaEntD   = today;
730eA       // Lets add some more stuff for tracking
730eA       $uiaction = 'RCV';
730eA       $uiaolcns = $uilcns;
730eA       $uialcns = $uilcns;
730eA       $uiaoseq = $uiseq;
730eA       $uiscan = 'Y';
730eA
730eA       $dricommand = '*UCIINFO';
730eA       $drisubcmd  = '%ADD';
730eA       $drisys2upd = 'D';
730eA       chk4err= *on;
730eA       zmflag  = *off;
730eA       exsr zzzdricop;
730eA       if error;
730eA         error = *on;
730eA         pmessage = $drimessage;
730eA       else;
730eA         can_uiwload = 'Y';
730eA         update uiwrec;
730eA       endif;
730eA     enddo;
730eA   endif;
      /end-free
     c
     C     enducircv     endsr
     *----------------------------------------------------------------
     *  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
     *----------------------------------------------------------------

      /free
        begsr zzlicinfochk;

          Lastseq  = 1;
          dow forevr = forevr;

          exsr clr$licinfo;

          $lnwhse  = pwhse;
710gD     //if xdockflg = ' ';
710gM     if xdockflg = ' ' and w1stat <> 'XD';
            $lnlcns  = plcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = lastseq + 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err= *on;
          exsr zzzdricop;
          if error;
            leave;
          else;
            // compare lot and date fields
            if $lnlot = w1lotc and
               $lnexpdate = expd;
              // add qty and weight, update licinfo
700aD         //$lnttllbs = $lnttllbs + w1dwgt;
700aM         $lnttllbs = $lnttllbs + cnvwgt;
              $lnseqqty = $lnseqqty + 1;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              chk4err= *on;
              exsr zzzdricop;
              licinfoupd = *on;
              leave;
            endif;
            eval lastseq = lastseq + 1;
          endif;

        enddo;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
     *----------------------------------------------------------------

      /free
        begsr zzlicinfoseq;

          exsr clr$licinfo;

          $lnwhse  = pwhse;
710gD     //if xdockflg = ' ';
710gM     if xdockflg = ' ' and w1stat <> 'XD';
            $lnlcns  = plcns;
          else;
            $lnlcns  = templcns;
          endif;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err= *on;
          exsr zzzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            $lnseqqty = $lnseqqty + 1;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            chk4err= *on;
            exsr zzzdricop;
            licinfoupd = *on;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZLICINFONew Update New format of LICINFO
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = pwhse;
710gD     //if xdockflg = ' ';
710gM     if xdockflg = ' ' and w1stat <> 'XD';
            $lnlcns  = plcns;
          else;
            $lnlcns  = templcns;
          endif;

          if difflot or diffexpd;
            $lnseq = lastseq + 1;
            $lnseqqty = $lnseqqty + 1;
700aD       //$lnttllbs = w1dwgt;
700aM       $lnttllbs = cnvwgt;
          else;
            $lnseq = 1;
            $lnseqqty = 1;
          endif;
          $lnpo = ppo;
          $lnposeq = pposeq;
          $lnitem = ppoitem;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file

          select;
            when $ifucicde = ' ';
              $lnrcvtyp = '1';
            when $ifucicde = '1';
              $lnrcvtyp = '1';
            when $ifucicde = '2';
              $lnrcvtyp = '3';
            when $ifucicde = '3';
              $lnrcvtyp = '4';
            // don't know exactly what 2 will represent
          endsl;
          $lnrcvtrn# = 0;
          $lnrcvlbl# = 0;

          select;
            when w1fifo <> 0;
              $lnentdate = wofifo;
            when w1mfdt <> 0;
              $lnentdate = womfdt;
            other;
              $lnentdate = woexdt;
          endsl;

          if wofifo > 0;
            $lnenttype = '*FIFODT';
          else;
            if $itflgd = 'Y';
              select;
                when $imuday > 0 or
                     $imdday > 0;
                  if $immflg = 'Y';
                    $lnenttype = '*MFGDTE';
                  else;
                    $lnenttype = '*USEDTE';
                  endif;
                other;
                  $lnenttype = '*EXPDTE';
              endsl;
            else;
              $lnenttype = '*ENTDTE';
            endif;

            $lndateflag = $itflgd;
            $lnmfgflag = $immflg;

            $lnmfgdays = $immday;
            $lnusrdays = $imuday;
            $lndstdays = $imdday;
          endif;

          $lnmfgdate = womfdt;

          if mexpd > 0;
            $lnmfgexp = mexpd;
          endif;

          if wofifo > 0;
            $lnfifodate = wofifo;
          endif;

          if expd > 0;
            $lnexpdate = expd;
          endif;

          if $ldecvalue > ' ';
            $lnmfgcode = pdecvalue;
          endif;

          $lnavglbs = 0;

          if W1lotc <> ' ';
            $lnlot = w1lotc;
          endif;

          if w1brand <> ' ';
            $lnbrand = w1brand;
          endif;

            // calculate the PTI.
            if $bclot <> ' ' and $bcgtinsent;
              pplot  = %subst($bclot: 1 : 20);
              pmfgdt = $pmfgdt;
              //calcpti ($bcgtin: pplot: $pmfgdt: pppti);
              calcpti ($bcgtin: pplot: pmfgdt: pppti);
              if pppti > 0;
                $lnlotPTI4 = %editc(pppti:'X');
                $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
              endif;
            endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          chk4err= *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
**
Item (
Base (
SSB (
Item  . . . .
**
(Type ' ')
**
Catch weight (Ttl or Avg)
Catch weight (Total)
Catch weight (Average)
