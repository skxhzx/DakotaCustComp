      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SU140     RF Set slot item/qty
     *  14 July, 1999
     *  Roxanne Harrison
     *
     *  Notes
     *       Created using SL160
     *       Previous revisions were removed to read easier.
     *       8 X 20 Screens for hand held scanners
     *       Program to be used for start up only.
     *        - All overflow slots must have Status = V, no item, and
     *          no quantity.
     *        - No virtual slots can exist in the SLOT or VSLOT file.
     *        - Program will create virtual slots for manual put away.
     *        - Use item maintenance to change an item in a slot,
     *          program will not replace an item already in a slot.
     *
     *
     *----------------------------------------------------------------
     *  Revisions
413aA*    01/12/00  RH  4.13a
     *      - Revised for virtual slots.
413bA*    02/03/00  RH  4.13b
     *      - Fix, ZZCKNS was resetting ERROR and allowing item type
     *        'S' into slot for some cases.
     *
414aA*    07/19/00  RRH  4.14a
     *      - Correct # for Do loop in ZZCKNS
414bA*    10/25/00  RRH  4.14b
     *      - Don't lock VSLOT records in ZZCKSL.
     *
415 A*    03/28/01  DAS  4.15
     *      - Changed SCREEN2 to get item number.
     *      - Added SCREEN3 to get quantity.
     *      - Added some supporting files and routines.
     *      - Saved some of the old SCREEN2 routines by making them
     *        SCREEN99 routines.
     *
415aA*    03/29/01  DAS  4.15a
     *      - Added APICVTDLT.
     *
415bA*    04/17/01  DAS  4.15b
     *      - Added W1SCAN to SCREEN2 & 3.
     *      - Only needed to recompile this program.
     *
416 A*    07/04/02  DAS  4.16
     *      - Added logic to extract item # from Vigo license #
     *      - Enh: Added call to pgm APICVTITM to extract item number
     *             out of data scanned in. Revised routines: SC5, ZZCHK5,
     *             ZZINZ.
416aA*    07/27/02  MLB  4.16a
     *      - FIX: Revised ZZUPD3 when adding a slot record to
     *             initialize all qty fields to zero.
     *             Revised ZZUPD3 when updating a slot record to
     *             move W2QT01,W2QT02,W2QT03 into slot fields if
     *             screen qty's GE zero.
416bA*    09/25/02  RH   4.16b
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
417aA*    04/14/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
     *
500 A*    01/10/05  DAS  5.00
     *      - Enh: Converted to ILE.
     *      - Enh: Added "client" logic.
     *
500aA*    01/10/05  DAS  5.00a
     *      - Enh: Revised to call LT210 for license tracking.
     *      - Enh: Revised to use DRI to update slot.
     *
500bA*    03/30/05  DAS  5.00b
     *      - Enh: Added SCREEN4 to capture expiration date.
     *
500cA*    04/07/05  DAS  5.00c
     *      - Enh: Revised to not look for or throw an error after
     *        calling UT812.
     *
500dA*    04/08/05  DAS  5.00d
     *      - Fix: Revised to set pallet position to zero for verify.
     *        This is because we haven't asked for one yet.
     *      - Fix: Revised SCR04I to call ZZFIL4 instead of ZZFIL2.
     *
500eA*    04/30/05  DAS  5.00e
     *      - Enh: Added $tnorm1/2/3 parms.
     *
510 A*    09/07/06  MLB  5.10
     *      - Fix: Changed handstack loop in ZZCKNS to be LT 702
     *        instead of LE 702.
     *      - *** Not needed because of DRI programs ***
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/28/08  DAS  6.00a
     *      - Modified TPC code to work with DRI fields.
     *
600bA*    02/19/09  DAS  6.00b
     *      - Revised to work with new license tracking.
     *      - Removed old commented code for readability.
     *      - Revised to call DRISLOT with %STUFFDLT before doing
     *        %STUFFIT in order to delete any existing slots that
     *        already contain the item.
530a *    01/28/10  GJA  5.30a
     *      - Revised to accept Mfr Item# in SCREEN2.
     *
610a *    08/17/10  DAS  6.10a
     *      - Revised to call LT210 to get new license for
     *        Medium/High tracked items.
610b *    11/03/10  GJA  6.10b
     *      - Enh: Revised to allow entry of pack date.
640a *    12/28/10  RH   6.40a
     *      - Enh: Rename format to SU14001
650a *    01/16/13  RH   6.50a
     *      - Enh: Revised to allow entry of entered date for FIFO
650b *    09/02/14  RH   6.50b
     *      - Enh: Revised to capture UPC code.
650cA*    09/10/14  MLB  6.50c
     *      - Fix: Revised screen 3 to correctly display Normal, Brkdwn 1
     *        entry fields when item has SSB item attached.
700aA*    03/07/16  RH   7.00a
     *      - Enh: Display license on sc2 for all clients. Use licensen 1
     *        to get item # from SU240WK Work file.
     *
700bA*    11/01/16  LMC  7.00b
     *      - Enh: Added UPC breakdown.                               n 1
     *      - Fix: Edit on upc code not issueing correct error.       n 1
710 A*    01/19/17  MLB  7.10
     *      - Enh: Added parm, clientloc to GETCLIENT call.
740 A*    03/16/20  RH   7.40
     *      - Enh: Add W2FLD1 to display LIC/SLT to get item from
     *        License or Slot. Renamed format to SU14004
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * City Line Mods
     *
     *   All City Line custom mods should be conditioned with ...
     *      'if client = cityline'
     *   or 'client  cabne  cityline   skipcityln1'
     *   or 'select / when client = cityline / other / endsl'
     *
     *
CLD A*    01/10/05  DAS  CLD
     *      - Enh: Revised to allow scanning of license plate to get item.
     *      - Enh: Added screen
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Stern Produce
SPIaA*    08/23/17  NLK/RH  SPIa
     *      - Enh: Revised pgm to set Ind 02 = on to position cursor
     *        on item# on screen 2.
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    01/31/11  RH   DRYa
     *      - Enh: Revised to NOT capture new license in LT210
DRYbA*    03/23/11  RH   DRYb
     *      - Enh: Force capture new license in LT210, reversed DRYa
DRYcA*    01/19/17  MLB/RH  DRYc
     *      - Enh: Revised pgm for whse 70 start-up to not capture
     *        dates for date sensitive items.
     *      - Per Melissa M email dated 01.19.17.
DRYdA*    01/19/17  MLB/RH  DRYd
     *      - Enh: Revised pgm to set Ind 02 = on to position cursor
     *        on item# on screen 2.
     *      - Previously undocumented mod id'd as DRYc.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    01/16/13  RH   HKWa
     *      - Revised program to capture FIFO entered date for non-
     *        date sensitive items.
     *----------------------------------------------------------------
     * Client Custom Revisions: TPC
     *
TPC A*    03/28/07  MLB  TPC
     *      - Revised program to not allow pick slots to be stuff'd.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Will Foods
     *
WIL A*    09/10/14  MLB  WIL
     *      - Revised program to not remove/delete item from pick slot
     *        which was added as part of 6.00b mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: S.Bertram
SBRaA*    11/25/15  RH   SBRa
     *      - Revised program to not remove/delete item from overflow
     *        which was added as part of 6.00b mod.
     *      - Overflow slots will create virutal slots for same item.
     *      - Pick slots will create additional license for same item.
     *      - If quantity needs to be added to slot, scan and stuff
     *        added quantity.
     *      - Adjust quantity out to remove from slot if necessary.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Sofo Foods
     *
SOFaA*    01/17/17  RH/MLB  SOFa
     *      - Revised program to not remove/delete item from pick slot
     *        which was added as part of 6.00b mod.
     *      - Added SOFa to WIL mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: KFS
KFS A*    09/25/18  RH   KFS
     *      - Revised program to not allow pick slots to be stuff'd.
     *      - Revised program to not remove/delete item from overflow
     *        which was added as part of 6.00b mod.
     *      - Overflow slots will create virutal slots for same item.
     *      - If quantity needs to be added to slot, scan and stuff
     *        added quantity.
     *      - Adjust quantity out to remove from slot if necessary.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Colony Foods
CFIaA*    04/18/18  RH   CFIa
     *      - Revised program to not remove/delete item from slots,
     *        will create virutal slots and additional license.
     *----------------------------------------------------------------
     * Client Custom Revisions: Greco & Sons
     *
GRCaA*    07/10/18  RH   GRC
     *      - Revised program to not allow pick slots to be stuff'd.
     *----------------------------------------------------------------
     * Client Custom Revisions: Merit Foods
     *
MRTaA*    07/11/18  RH    MRTa
     *      - Revised program to not remove/delete item from pick slot
     *      - Revised program to not capture license
     *----------------------------------------------------------------
     * Client Custom Revisions: Dependable
DFCaA*    03/12/20  RH    DFCa
     *      - Revised program to enable use pick slot to get item #.
     *      - Revised program to not remove/delete item from pick slot
     *      - Revised program to not allow pick slots to be stuff'd.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
CLD A*  81        Display license entry field on screen 2
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

640aDF*u140fm   cf   e             workstn
650aMD*u14001   cf   e             workstn
700bDF*su14002   cf   e             workstn
740aDF*u14003   cf   e             workstn
740aMFsu14004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
413aAFoptiond   if   e           k disk
415 AFupc       if   e           k disk
650aMFupc2      uf a e           k disk
640uAF                                     rename(uprec:uprec2)
415 AFunmesr    if   e           k disk
530aAFpiritem4  if   e           k disk
610bAFitemmsc   if   e           k disk
700aAFsu240wk   uf a e           k disk

500 A*----------------------------------------------------------------
500 A*  Client id's for custom mods.
500 A*----------------------------------------------------------------
500 A
500 A /copy qcopysrc,id#citylin
SPIaA /copy qcopysrc,id#spi
TPC A /copy qcopysrc,id#tpc
DRYaA /copy qcopysrc,id#dairyla
DRYcA /copy qcopysrc,id#dryqchi
HKW A /copy qcopysrc,id#hkw
WIL A /copy qcopysrc,id#wil
SBRaA /copy qcopysrc,id#sbr
SOFaA /copy qcopysrc,id#sofo
KFSaA /copy qcopysrc,id#kfs
MRTaA /copy qcopysrc,id#mrt
CFIaA /copy qcopysrc,id#cfi
GRCaA /copy qcopysrc,id#grc
DFCaA /copy qcopysrc,id#dfc
500 AD client          s             10
710 AD clientloc       s             10

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

413aAD a2              s              1    dim(2)
413aAD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
530aDD*desc            s             60    dim(3) ctdata perrcd(1)
650bDD*desc            s             60    dim(5) ctdata perrcd(1)
650bMD desc            s             60    dim(6) ctdata perrcd(1)

500aA*----------------------------------------------------------------
500aA*  DRI parameters
500aA*----------------------------------------------------------------
500aA
500aA /COPY *libl/qcopysrc,C#DRIPARMS
500aA
500aA*----------------------------------------------------------------
500aA*  Data Formats
500aA*----------------------------------------------------------------
500aA
500aA /COPY *libl/qcopysrc,C#ITEM
500aA /COPY *libl/qcopysrc,C#SLOT
500aA /COPY *libl/qcopysrc,C#SLOTDEF
500aAD saveVer#        s                   like($slver#)
500aAD save$slot       s                   like($slot)

610aA*----------------------------------------------------------------
610aA*  Tracking variables
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,c#trackvar

415aA*----------------------------------------------------------------
415aA*  API programs
415aA*----------------------------------------------------------------
415aA
     D @apics          c                   const('APICVTSLT ')
     D @apici          c                   const('APICVTITM ')

500bA*----------------------------------------------------------------
500bA*  LT210 parameters
500bA*----------------------------------------------------------------

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
500aAD  $tnorm1        s              5  0
500aAD  $tnorm2        s              3  0
500aAD  $tnorm3        s              3  0
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
415aA
     *----------------------------------------------------------------
     *  Redefinition data structures
     *----------------------------------------------------------------

     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4

413aA*----------------------------------------------------------------
413aA*  *PICK  -  Picking options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    OPNXTP  -  Next pallet number.
413aA*    OPBPCK  -  Bulk pick definition.
413aA*    OPPCUB  -  Maximum cube for PIR.
413aA*    OPFPAL  -  Pallets on fixed fork lift.
413aA*    OPFCUB  -  Maximum cube per fixed pallet.
413aA*    OPFSTP  -  Maximum stops per fixed pallet.
413aA*    OPINCL  -  Include PIR in fixed cube.
413aA*    OPSRCH  -  Number of previous pallets to search for space.
413aA*    OPFBLD  -  Fixed pallet building method.
413aA*                1 = By piece without concern for splitting stop.
413aA*                2 = By stop without splitting stop between plts.
413aA*    OPPBRK  -  Break pallets by aisle (Y,N).
413aA*    OPMPUT  -  Manual Put away (Y,N).
413aA*
413aA* Data structure
413aA*
413aAD opddta          ds
413aAD  opnxtp                 1      7  0 inz(0)
413aAD  oppcub                10     14  2 inz(0)
413aAD  opfpal                15     15  0 inz(0)
413aAD  opfcub                16     20  2 inz(0)
413aAD  opincl                22     22
413aAD  opsrch                23     24  0 inz(0)
413aAD  opfstp                25     26  0 inz(0)
413aAD  opfbld                27     27  0 inz(0)
413aAD  opbpck                28     30  0 inz(0)
413aAD  oppbrk                31     33
413aAD  opmput                34     34
413aAD  opdend               117    117
413aA
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT2')

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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $litm                 22     36
     *
417a D  $lupc                 22     41
417a D  $litm1                42     56
     *----------------------------------------------------------------
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
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
     *
413 AD  errit1                 1     15
413 AD  errtyp                16     16
413 AD  errit2                17     31
     D                 ds
     D  $ec                    1      2p 0

TPC AD Errmsg01        c                   const('Pck slot not allowed')

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
     *  PIRTRAN record layout for use as parameters
     *----------------------------------------------------------------

     D ptparm        e ds                  extname(pirtran)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
500aAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
500aAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

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
610bA*------------------------------------------------------------------
610bA* CLCDUR2 parameters
610bA*------------------------------------------------------------------

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
     *  Variables
     *----------------------------------------------------------------

500aAD #stufitwhse     s                   like($itwhse)
500aAD #stufititem     s                   like($ititem)
500aAD #stufittype     s                   like($ittype)
500aAD #stufitdesc     s                   like($itdesc)
500aAD #stufitpdsc     s                   like($itpdsc)
500aAD #stufitwhdp     s                   like($itwhdp)
500aAD #stufitstyp     s                   like($itstyp)
500aAD #stufitdesg     s                   like($itdesg)
500aAD #stufitum1      s                   like($itum1)
500aAD #stufitflg1     s                   like($itflg1)
500aAD #stufitum2      s                   like($itum2)
500aAD #stufitumq2     s                   like($itumq2)
500aAD #stufitflg2     s                   like($itflg2)
500aAD #stufitum3      s                   like($itum3)
500aAD #stufitumq3     s                   like($itumq3)
500aAD #stufitnrpk     s                   like($imnrpk)
500aAD #stufitflgd     s                   like($itflgd)
500aAD #stufitcube     s                   like($itcube)
500aAD #stufitswgt     s                   like($itswgt)
500aAD #stufitcwgt     s                   like($itcwgt)
500aAD #stufitmitem    s                   like($itmitem)
500aAD #stufitsdef     s                   like($idsdef)
500aAD #stufittie      s                   like($idtie)
500aAD #stufithigh     s                   like($idhigh)

500aAD #stufssbflag    s               n
500aAD #stufssbititem  s                   like($ititem)
500aAD #stufssbittype  s                   like($ittype)
500aAD #stufssbitdesc  s                   like($itdesc)
500aAD #stufssbitpdsc  s                   like($itpdsc)
500aAD #stufssbitwhdp  s                   like($itwhdp)
500aAD #stufssbitstyp  s                   like($itstyp)
500aAD #stufssbitdesg  s                   like($itdesg)
500aAD #stufssbitum1   s                   like($itum1)
500aAD #stufssbitum2   s                   like($itum2)
500aAD #stufssbitumq2  s                   like($itumq2)
500aAD #stufssbitum3   s                   like($itum3)
500aAD #stufssbitumq3  s                   like($itumq3)

500aAD #stufslwhse     s                   like($slwhse)
500aAD #stufslwhdp     s                   like($slwhdp)
500aAD #stufslstyp     s                   like($slstyp)
500aAD #stufsldisp     s                   like($sldisp)
500aAD #stufslaisl     s                   like($slaisl)
500aAD #stufslloc      s                   like($slloc)
500aAD #stufslpseq     s                   like($slpseq)
500aAD #stufslrlvl     s                   like($slrlvl)
500aAD #stufslhand     s                   like($slhand)
500aAD #stufslstat     s                   like($slstat)
500aAD #stufslrsrv     s                   like($slrsrv)
500aAD #stufslentd     s                   like($slentd)
500aAD #stufslexpd     s                   like($slexpd)
500aAD #stufslslfd     s                   like($slslfd)
500aAD #stufslactv     s                   like($slactv)
500aAD #stufslbld      s                   like($slbld)
500aAD #stufslpick     s                   like($slpick)
500aAD #stufslitem     s                   like($slitem)
500aAD #stufslsdef     s                   like($slsdef)
500aAD #stufslpos      s                   like($sdpos)
500aAD #stufslvirt     s                   like($sfvirt)
500aAD #stufslstk1     s                   like($slstk1)
500aAD #stufslstk2     s                   like($slstk2)
500aAD #stufslstk3     s                   like($slstk2)
500aAD #stufslalc1     s                   like($slalc1)
500aAD #stufslalc2     s                   like($slalc2)
500aAD #stufslalc3     s                   like($slalc3)
500aAD #stufsltfr1     s                   like($sltfr1)
500aAD #stufsltfr2     s                   like($sltfr2)
500aAD #stufsltfr3     s                   like($sltfr3)
500aAD #stufslpck1     s                   like($slpck1)
500aAD #stufslpck2     s                   like($slpck2)
500aAD #stufslpck3     s                   like($slpck3)
500aAD #stufslrcv1     s                   like($slrcv1)
500aAD #stufslrcv2     s                   like($slrcv2)
500aAD #stufslrcv3     s                   like($slrcv3)
500aAD #stufslphy1     s                   like($slphy1)
500aAD #stufslphy2     s                   like($slphy2)
500aAD #stufslphy3     s                   like($slphy3)
500aAD #stufslavl1     s                   like($slavl1)
500aAD #stufslavl2     s                   like($slavl2)
500aAD #stufslavl3     s                   like($slavl3)
500aAD #stufbasesldsp  s                   like($sldisp)

     D $itemds         s             15
     D $jobq           s              1
     D $msgf           s             10
     D $pwhs           s             15  5
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
700bAD b1type          s              7
700bAD b2type          s              7
700bAD b1upc           s                   like(upupc)
700bAD b2upc           s                   like(upupc)
610aAD cancel          s               n
500aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
500aMD error           s               n
     D exist           s              1
610bAD expd            s              8  0
     D flaghs          s              1
     D forevr          s              1
     D help            s              5  0
     D i               s              2  0
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kyupc           s                   like(upupc)
530aAD mfrctr          s              3  0
     D more            s              1
     D msgk            s              4  0
     D newvs           s              1
     D noupc           s              1
700bAD Needb1          s               n
700bAD Needb2          s               n
700bAD Ntype           s              7
     D nxtscr          s              3
650bAD ovrrid          s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sitem           s             15
     D ssbflg          s              1
     D svscan          s             12
650bAD svupc           s                   like(upupc)
     D today           s              8  0
610aAD trackLevel      s              1
     D upcctr          s              3  0
DFCaAD uselic          s               n
500bAD w4expdymd       s              8  0
     D warn            s              1
700bAD Writeb1         s               n
700bAD Writeb2         s               n
500aAD zmsflag         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in99 = *off
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
415 AC     nxtscr        caseq     '03 '         sc3
500bAC     nxtscr        caseq     '04 '         sc4
650bAC     nxtscr        caseq     '05 '         sc5
700bAC     nxtscr        caseq     '05B'         sc5B
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
500aAC                   exsr      zzzdriclose
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
415 AC                   if        nxtscr = '03 '
415 AC                   exfmt     screen3                              50
415 AC                   endif
500bAC                   if        nxtscr = '04 '
500bAC                   exfmt     screen4                              50
500bAC                   endif
650bAC                   if        nxtscr = '05 '
650bAC                   exfmt     screen5                              50
650bAC                   endif
700bAC                   if        nxtscr = '05B'
700bAC                   exfmt     screen5B                             50
700bAC                   endif
     *
     *   Initialize error indicators and fields
     *
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
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
610aAC                   eval      cancel = *off
     C                   eval      cmdtkn = *off
415aAC                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr

     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr02i        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
DRYdAC                   select
DRYdAC                   when      client = dairyland
SPIaAC                             or client = SternProduce
DRYdAC                   eval      *in02 = *on
DRYdAC                   endsl
     C     end02i        endsr

415 A*----------------------------------------------------------------
415 A*  Screen 03 initialization
415 A*----------------------------------------------------------------

415 AC     scr03i        begsr
415 AC                   eval      exist = *off
415 AC                   eval      newvs = *off
415 AC                   eval      nxtscr = '03 '
415 AC                   exsr      zzfil3
415 AC                   eval      refrsh = *off
415 AC     end03i        endsr

500bA*----------------------------------------------------------------
500bA*  Screen 04 initialization
500bA*----------------------------------------------------------------
500bA
500bAC     scr04i        begsr
     C                   eval      nxtscr = '04 '
500dMC                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr

650bA*----------------------------------------------------------------
650bA*  Screen 05 initialization
650bA*----------------------------------------------------------------
650bA
650bAC     scr05i        begsr
650bAC                   eval      nxtscr = '05 '
650bAC                   exsr      zzfil5
650bAC                   eval      refrsh = *off
650bAC     end05i        endsr

700bA*----------------------------------------------------------------
700bA*  Screen 05B initialization
700bA*----------------------------------------------------------------
700bA
700bAC     scr05ib       begsr
700bA*  This screen will get initiated if ifrcvmth = 3 to
700bA*  capture upc's for breakdown.
700bA*
700bA*  We will display the screen2b if the item has breakdowns
700bA*  defined, and we do not have a UPC record for the breakdown uom
700bA*
700bA /free
700bA   writeb1 = *off;
700bA   writeb2 = *off;
700bA   w5buom1 = ' ';
700bA   w5bupc1 = ' ';
700bA   w5buom2 = ' ';
700bA   w5bupc2 = ' ';
700bA   *in15 = *off;
700bA   *in16 = *off;
700bA   // breakdown 1 is setup on item
700bA   if #stufitum2 <> ' ';
700bA     Needb1  = *on;
700bA     // do we have a upc loaded for this breakdown uom
700bA     setll ($itwhse: $ititem) upc2;
700bA     dow forevr = forevr;
700bA       reade(n) ($itwhse: $ititem) upc2;
700bA       if %eof(upc2);
700bA         leave;
700bA       endif;
700bA       if upuom = #stufitum2;
700bA         needb1  = *off;
700bA         leave;
700bA       endif;
700bA     enddo;
700bA   endif;
700bA   // breakdown 2 is setup on item
700bA   if #stufitum3 <> ' ';
700bA     Needb2  = *on;
700bA     // do we have a upc loaded for this breakdown uom
700bA     setll ($itwhse: $ititem) upc2;
700bA     dow forevr = forevr;
700bA       reade(n) ($itwhse: $ititem) upc2;
700bA       if %eof(upc2);
700bA         leave;
700bA       endif;
700bA       if upuom = #stufitum3;
700bA         needb2  = *off;
700bA         leave;
700bA       endif;
700bA     enddo;
700bA   endif;
700bA   // need to capture a breakdown upc
700bA   if needb1 = *on or needb2 = *on;
700bA     nxtscr = '05B';
700bA     exsr zzfil5b;
700bA   else;
700bA     exsr scr03i;
700bA   endif;
700bA /end-free
700bAC
700bAC                   eval      refrsh = *off
700bAC     end05ib       endsr


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
415aAC     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr

     *----------------------------------------------------------------
     *  SC2  -  Screen 2
     *----------------------------------------------------------------

     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   eval      w1scan = svscan
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr

415 A*----------------------------------------------------------------
415 A*  SC3  -  Screen 3
415 A*----------------------------------------------------------------

415 AC     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
650bDC*                  eval      nxtscr = '02 '
650bMC                   eval      nxtscr = '05 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
610aAC     cancel        cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr

500bA*----------------------------------------------------------------
500bA*  SC4  -  Screen 4
500bA*----------------------------------------------------------------
500bA
500bAC     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '03 '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '03 '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
610aAC     cancel        cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr

650bA*----------------------------------------------------------------
650bA*  SC5  -  Screen 5
650bA*----------------------------------------------------------------
650bA
650bAC     sc5           begsr
650bA*
650bA*  Test for F3 - Exit
650bA*
650bAC                   if        *inkc
650bAC                   eval      refrsh = *off
650bAC                   eval      nxtscr = '04 '
650bAC                   goto      endsc5
650bAC                   endif
650bA*
650bA*  Test for F5 - Refresh
650bA*
650bAC                   if        *inke
650bAC                   eval      refrsh = *on
650bAC                   exsr      scr05i
650bAC                   goto      endsc5
650bAC                   endif
650bA*
650bA*  Test for F12 - Previous
650bA*
650bAC                   if        *inkl
650bAC                   eval      refrsh = *off
650bAC                   eval      nxtscr = '02 '
650bAC                   goto      endsc5
650bAC                   endif
650bA*
650bA*  Test for other command keys BEFORE verification and update.
650bA*
650bAC                   eval      cmdchk = '*BEFORE '
650bAC                   exsr      zzcmd5
650bAC     cmdtkn        cabeq     *on           endsc5
650bA*
650bA*  Some other key pressed.
650bA*
650bA*     Check input and write/update record.
650bA*
650bAC                   exsr      zzchk5
650bAC     error         cabeq     *on           endsc5
650bAC                   exsr      zzupd5
650bAC     error         cabeq     *on           endsc5
650bAC     cancel        cabeq     *on           endsc5
650bA*
650bA*  Test for other command keys AFTER verification and update.
650bA*
650bAC                   eval      cmdchk = '*AFTER  '
650bAC                   exsr      zzcmd5
650bAC     cmdtkn        cabeq     *on           endsc5
650bA*
650bAC     endsc5        endsr
650bA
700bA*----------------------------------------------------------------
700bA*  SC5B -  Screen 5B
700bA*----------------------------------------------------------------
700bA
700bAC     sc5B          begsr
700bA*
700bA*  Test for F3 - Exit
700bA*
700bAC                   if        *inkc
700bAC                   eval      refrsh = *off
700bAC                   eval      nxtscr = '04 '
700bAC                   goto      endsc5b
700bAC                   endif
700bA*
700bA*  Test for F5 - Refresh
700bA*
700bAC                   if        *inke
700bAC                   eval      refrsh = *on
700bAC                   exsr      scr05ib
700bAC                   goto      endsc5b
700bAC                   endif
700bA*
700bA*  Test for F12 - Previous
700bA*
700bAC                   if        *inkl
700bAC                   eval      refrsh = *off
700bAC                   eval      nxtscr = '05 '
700bAC                   goto      endsc5b
700bAC                   endif
700bA*
700bA*  Test for other command keys BEFORE verification and update.
700bA*
700bAC                   eval      cmdchk = '*BEFORE '
700bAC                   exsr      zzcmd5b
700bAC     cmdtkn        cabeq     *on           endsc5b
700bA*
700bA*  Some other key pressed.
700bA*
700bA*     Check input and write/update record.
700bA*
700bAC                   exsr      zzchk5b
700bAC     error         cabeq     *on           endsc5b
700bAC                   exsr      zzupd5b
700bAC     error         cabeq     *on           endsc5b
700bAC     cancel        cabeq     *on           endsc5b
700bA*
700bA*  Test for other command keys AFTER verification and update.
700bA*
700bAC                   eval      cmdchk = '*AFTER  '
700bAC                   exsr      zzcmd5b
700bAC     cmdtkn        cabeq     *on           endsc5b
700bA*
700bAC                   exsr      scr03i
700bAC     endsc5b       endsr
700bA
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
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
     *   Call user added initialization routine.
     *
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
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
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZSCLR   Clear screen
     *----------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr

     *----------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *----------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

500aA*----------------------------------------------------------------
500aA*    DRI0001  Local system caused error
500aA*----------------------------------------------------------------
500aA
500aAC     zm0001        begsr
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
     *   PIR0105  Invalid slot entered.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *----------------------------------------------------------------

     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

415 A*----------------------------------------------------------------
415 A*   PIR0205  Value must be entered
415 A*----------------------------------------------------------------

415 AC     zm0205        begsr
415 AC                   eval      #msgid = 'PIR0205'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr

     *----------------------------------------------------------------
     *   IT28001  Invalid slot entered.
     *----------------------------------------------------------------

     C     zm2801        begsr
     C                   eval      #msgid = 'IT28001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *----------------------------------------------------------------

     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *----------------------------------------------------------------

     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
500bA*----------------------------------------------------------------
500bA*    PIR1008  Date is required.
500bA*
500bAC     zm1008        begsr
     C                   move      'PIR1008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
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

415 A*----------------------------------------------------------------
415 A*   PO20029  UPC not on file.
415 A*----------------------------------------------------------------

415 AC     zm29          begsr
415 AC                   eval      #msgid = 'PO20029'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Slot can't be blank
     *
     C                   if        w1scan = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
415aA*
415aA*  Call API for slot.
415aA*
415aAC                   call      @apics
415aAC                   parm                    w1scan
415aAC                   parm      5             worow
415aAC                   parm      8             wocol
415aAC                   parm                    @artn             8
415aAC                   if        @artn = '*REDSPLY'
415aAC                   eval      redspl = *on
415aAC                   goto      endck1
415aAC                   endif
     *
     *  Verify slot
     *
500aAC                   exsr      zzgetstufsl
500aAC                   if        error
500aAC                   eval      *in24 = *on
500aAC                   eval      *in04 = *on
500aAC                   goto      endck1
500aAC                   endif
TPC A*
TPC AC                   if        client = TPC
KFS AC                             or client = kellys
GRC AC                             or client = Greco
DFCaAC                             or client = dependable
TPC A*      StuffIt not allowed for pick slots.
600aDC**   keysl2        chain (n) slot2
600aDC**                 if        %found
600aDC**                           and slpick ='Y'
600aMC                   if        #stufslpick ='Y'
TPC AC                   eval      error = *on
TPC AC                   eval      *in24 = *on
TPC AC                   eval      *in04 = *on
TPC AC                   eval      errmsg = errmsg01
TPC AC                   exsr      zm0105
TPC AC                   goto      endck1
TPC AC                   endif
TPC A*
TPC AC                   endif
     *
     C     endck1        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCHK2   Screen 2 error checking.
415 A*----------------------------------------------------------------

415 AC     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      noupc = *off
     *
     *  At least one value must be entered.
     *
     C                   if        w2upc = *blanks  and
CLD AC                             w2lic = *blanks  and
530aAC                             w2mfri = *blanks  and
     C                             w2item = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
CLD AC                   eval      *in23 = *on
530aAC                   eval      *in24 = *on
     C                   eval      *in01 = *on
CLD AC                   eval      *in03 = *on
530aAC                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0205
     C                   goto      endck2
     C                   endif
     *
     C                   select
500 A*
500 A*  License entered
500 A*
500 AC                   when      w2lic <> *blanks
DFCaAC                   if        client = dependable
DFCaAC                   eval      uselic = *on
DFCaAC                   exsr      zzgetstufsl
DFCaAC                   eval      w2item = #stufslitem
DFCaAC                   eval      $sldisp  = w1scan
DFCaAC                   eval      uselic = *off
DFCaAC                   exsr      zzgetstufsl
DFCaAC                   else
700aAC     su2key        chain(n)  su240wk
700aAC                   if        %found(su240wk)
700aAC                   eval      w2item = suitem
700aAC                   endif
DFCaAC                   endif
     *
     *  UPC entered
     *
     C                   when      w2upc <> *blanks
     *
     *     UPC code not on file.
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w2upc         $cbbar
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
     C                   if        $cbrtn = '*OK'
     C                   eval      w2upc = $cbv2
     C                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         kyupc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm29
     C                   goto      endck2
     C                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   eval      $lupc = kyupc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litm1
     *
417a C                   endif
     *
     C                   eval      w2item = upitem
530aA *
530aA *  Mfr Item Number Entered
530aA *
530aAC                   when      w2mfri <> *blanks
530aA *
530aAC                   z-add     0             mfrctr
530aAC     mfrkey        setll     piritem4
530aA *
530aAC                   dou       forevr <> forevr
530aAC     mfrkey        reade(n)  piritem4
530aA *
530aAC                   if        not %EOF(PIRITEM4) and itvit#=w2mfri
530aAC                   add       1             mfrctr
530aAC                   else
530aAC                   leave
530aAC                   endif
530aA *
530aAC                   enddo
530aA *
530aAC                   select
530aA *
530aAC                   when      mfrctr = 0
530aAC                   eval      error = *on
530aAC                   eval      *in24 = *on
530aAC                   eval      *in04 = *on
530aAC                   movel     desc(5)       errmsg
530aAC                   exsr      zm0105
530aAC                   goto      endck2
530aA *
530aAC                   when      mfrctr > 1
530aAC                   eval      error = *on
530aAC                   eval      *in24 = *on
530aAC                   eval      *in04 = *on
530aAC                   movel     desc(4)       errmsg
530aAC                   exsr      zm0105
530aAC                   goto      endck2
530aA *
530aAC                   other
530aAC                   eval      w2item = ititem
530aA *
530aAC                   endsl
530aA *
     *
     C                   endsl
416 A*
416 A*  Determine if item # or license # entered.
416 A*
416 A*    A vigo license plate is 15 char, same as our item #.
416 A*    A vigo item number is 8 char.
416 A*    A vigo license contains item number in pos 8 - 15.
416 A*    If pos 9-15 are not blank, then assume vigo license.
416 A*
416 A*
416 A*  Call API for item.
416 A*
416 AC                   call      @apici
416 AC                   parm                    w2item
416 AC                   parm      5             worow             3 0
416 AC                   parm      6             wocol             3 0
416 AC                   parm                    @artn
416 AC                   if        @artn = '*REDSPLY'
416 AC                   endif
     *
     *  Verify item #
     *
500aAC                   exsr      zzgetstufit
500aAC                   if        error
500aAC                   eval      *in22 = *on
500aAC                   eval      *in02 = *on
500aAC                   goto      endck2
500aAC                   endif
     *
     C     endck2        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCHK3   Screen 3 error checking.
415 A*----------------------------------------------------------------

415 AC     zzchk3        begsr
     C                   eval      error = *off
500bA
500bA*  For date sensitive items, delay verification until after getting
500bA*  the expiration date from screen 4.
500bA
HKWaAC                   select
HKWaAC                   when      client = HKW
HKWaAC                   exsr      scr04i
HKWaAC                   other
DRYcA*
DRYcAC                   if            client = Dairyland
DRYcAC                             and clientloc = dryqznchicago
DRYcA*      Turn off date capture for whse 70 startup.
DRYcAC                   if        #stufitflgd = 'Y'
DRYcAC                   eval      #stufitflgd = 'N'
DRYcAC                   endif
DRYcA*
DRYcAC                   endif
DRYcA*
500bAC                   if        #stufitflgd = 'Y'
500bAC                   exsr      scr04i
500bAC                   else
500bAC                   exsr      zzstuffitvfy
500bAC                   endif
HKWaAC                   endsl
     *
     C     endck3        endsr

500bA*----------------------------------------------------------------
500bA*  ZZCHK4   Screen 4 error checking.
500bA*----------------------------------------------------------------
500bA
500bAC     zzchk4        begsr
     C                   eval      error = *off

     *  Verify expired date

610bDC*                  if        w4expd = 0
610bMC                   if        w4expd = 0 and *in31 = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   goto      endck4
     C                   endif
640aA*  Verify mfg/pack date
610bAC                   if        w4expd = 0 and *in32 = *on
610bAC                   eval      error = *on
610bAC                   eval      *in21 = *on
610bAC                   eval      *in01 = *on
610bAC                   eval      errmsg = *blanks
610bAC                   exsr      zm1008
610bAC                   goto      endck4
610bAC                   endif

610bAC                   if        *in32
610bA*
610bA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
610bA*
610bA
610bAC                   eval      $cvcmd = '*MDYCMD '
610bAC                   move      w4expd        $cvd6i
610bAC                   call      @cvtdt
610bAC                   parm                    $cvtdt
610bAC                   move      $cvd8o        expd
610bA
610bAC                   call      'CLCDUR2'
610bAC                   parm      '*ADD'        $cdcmd
610bAC                   parm      expd          $cddatein
610bAC                   parm      0             $cdtimein
610bAC                   parm      0             $cdyears
610bAC                   parm      0             $cdmonths
610bAC                   parm      immday        $cddays
610bAC                   parm      0             $cdhours
610bAC                   parm      0             $cdminutes
610bAC                   parm      0             $cdseconds
610bAC                   parm      0             $cddateout
610bAC                   parm      0             $cdtimeout
610bA
610bAC                   call      'CLCDUR2'
610bAC                   parm      '*SUB'        $cdcmd
610bAC                   parm      $cddateout    $cddatein
610bAC                   parm      0             $cdtimein
610bAC                   parm      0             $cdyears
610bAC                   parm      0             $cdmonths
610bAC                   parm      imuday        $cddays
610bAC                   parm      0             $cdhours
610bAC                   parm      0             $cdminutes
610bAC                   parm      0             $cdseconds
610bAC     expd          parm      0             $cddateout
610bAC                   parm      0             $cdtimeout
610bA
610bAC                   eval      $cvcmd = '*CMDMDY '
610bAC                   move      expd          $cvd8i
610bAC                   call      @cvtdt
610bAC                   parm                    $cvtdt
610bAC                   move      $cvd6o        w4expd
610bA
610bAC                   else
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w4expd        $cvd6i
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt

     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck4
     C                   endif
610d C                   endif

     *  Convert expiration date into YYYYMMDD format.

     C                   eval      w4expd = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w4expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w4expdymd = $cvd8o

     *  Verify that expiration date isn't already expired.

     C                   if        w4expdymd < today
650aAC                             and #stufitflgd = 'Y'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Error: Date already expired'
     C                   exsr      zm0105
     C                   goto      endck4
     C                   endif

     *  Do StuffIt verification.

     C                   exsr      zzstuffitvfy

     C     endck4        endsr

650bA*----------------------------------------------------------------
650bA*  ZZCHK5   Screen 5 error checking.
650bA*----------------------------------------------------------------
650bA
650bAC     zzchk5        begsr
650bAC                   eval      error = *off
650bA*  Skip UPC logic if UPC is blank.
650bAC                   if        w5upc = *blanks
650bAC****               eval      wkupc = *blanks
650bAC                   goto      endck5
650bAC                   endif
650bA
650bA*  Skip UPC verification if override was taken
650bAC                   if        ovrrid = *on and
650bAC                             w5upc = svupc
650bAC                   goto      endck5
650bAC                   endif
650bA
650bAC                   eval      svupc = w5upc
650bA*  UPC entered
650bA*
650bAC                   if        w5upc <> *blanks
650bA*
650bA*     Extract UPC code.
650bA*
650bAC                   eval      $cbcmd = '*UPC    '
650bAC                   movel     w5upc         $cbbar
650bAC                   call      'CVTBAR'
650bAC                   parm                    $cbcmd            8
650bAC                   parm                    $cbbar          100
650bAC                   parm                    $cbcod            3 0
650bAC                   parm                    $cbdec            1 0
650bAC                   parm                    $cbdsc           30
650bAC                   parm                    $cbpos            3 0
650bAC                   parm                    $cbtyp            1 0
650bAC                   parm                    $cbv1            11 3
650bAC                   parm                    $cbv2            50
650bAC                   parm                    $cbrtn            8
650bAC                   parm                    $cberm           60
650bA*
700bAC* moved the select so the field is not adjusted on error
700bMC                   select
700bMC                   when      $cbrtn = '*OK'
650bAC                   eval      w5upc = $cbv2
700bAc                   eval      ntype = %trimr($cbdsc)
650bA*
650bA*   Right adjust UPC code for file.
650bA*
700bDC*                  eval      $cstr = *blanks
700bDC*                  movel     w5upc         $cstr
700bDC*                  call      'ADJUST'
700bDC*                  parm      '*RIGHT  '    $ccmd             8
700bDC*                  parm                    $cstr            30
700bDC*                  move      $cstr         kyupc
700bDC*                  eval      w5upc = kyupc
700bDC*                  select
700bDC*                  when      $cbrtn = '*OK'
650bAC                   other
650bA
650bAC                   eval      error = *on
650bAC                   eval      warn = *on
650bAC                   eval      *in29 = *on
650bAC                   eval      *in09 = *on
650bAC                   eval      errmsg = *blanks
700bDC*                  movel     desc(5)       errmsg
700bMC                   movel     $cberm        errmsg
650bAC                   exsr      zm0105
650bAC                   goto      endck5
650bAC                   endsl
650bAC                   endif
650bAC                   eval      svupc = w5upc

650bAC     endck5        endsr
700bA*----------------------------------------------------------------
700bA*  ZZCHK5B  Screen 5B error checking.
700bA*----------------------------------------------------------------
700bA
700bAC     zzchk5b       begsr
700bAC                   eval      error = *off
700bA*  at least one UPC must be entered or f9 to skip.
700bA*
700bA*  Extract UPC code from entered string.
700bA*
700bA * reset indicators so we only display the needed breakdowns
700bA /free
700bA   if w5buom1 = ' ';
700bA     *in38 = *on;
700bA   endif;
700bA   if w5buom2 = ' ';
700bA     *in39 = *on;
700bA   endif;
700bA /end-free
700bA * edit breakdown 1 upc
700bAc                   if        w5buom1 <> ' ' and
700bAC                             w5bupc1 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w5bupc1
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b1upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w5bupc1 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb1 = *on
700bAc                   eval      b1type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in15 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck5b
700bAC                   endif
700bA*
700bA * edit breakdown 2 upc
700bAc                   if        w5buom2 <> ' ' and
700bAC                             w5bupc2 <> *blanks
700bAC                   eval      $cbcmd = '*UPC    '
700bAC                   eval      $cbbar = w5bupc2
700bA*
700bAC                   call      'CVTBAR'
700bAC                   parm                    $cbcmd            8
700bAC                   parm                    $cbbar          100
700bAC                   parm                    $cbcod            3 0
700bAC                   parm                    $cbdec            1 0
700bAC                   parm                    $cbdsc           30
700bAC                   parm                    $cbpos            3 0
700bAC                   parm                    $cbtyp            1 0
700bAC                   parm                    $cbv1            11 3
700bAC                   parm                    $cbv2            50
700bAC                   parm                    $cbrtn            8
700bAC                   parm                    $cberm           60
700bA*
700bAC                   movel     $cbv2         $cstr
700bAC                   call      'ADJUST'
700bAC                   parm      '*RIGHT  '    $ccmd             8
700bAC                   parm                    $cstr            30
700bAC                   move      $cstr         b2upc
700bAC                   endif
700bA*   Do UPC Check
700bAC                   if        w5bupc2 <> ' '
700bA*
700bA*  MOVED CODE TO EXTRACT UPC CODE FROM ENTERED STRING
700bAC                   select
700bA*
700bAC                   when      $cbrtn = '*OK'
700bAc                   eval      writeb2 = *on
700bAc                   eval      b2type = %trimr($cbdsc)
700bA*
700bAC                   other
700bAC                   eval      error = *on
700bAC                   eval      *in16 = *on
700bAC                   movel     $cberm        errmsg
700bAC                   exsr      zm0105
700bAC                   endsl
700bA*
700bAC     error         cabeq     *on           endck5b
700bAC                   endif
700bA*

700bAC     endck5b       endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCMD3   User defined command keys for screen 3.
415 A*----------------------------------------------------------------

415 AC     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr

500bA*----------------------------------------------------------------
500bA*  ZZCMD4   User defined command keys for screen 4.
500bA*----------------------------------------------------------------
500bA
500bAC     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr

650bA*----------------------------------------------------------------
650bA*  ZZCMD5   User defined command keys for screen 5.
650bA*----------------------------------------------------------------
650bA
650bAC     zzcmd5        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *  Test for F10- Accept Warning
     *
     C                   if        *inkj
700bDC*                  eval      cmdtkn = *on
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   eval      col = colin
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr

700bA*----------------------------------------------------------------
700bA*  ZZCMD5B  User defined command keys for screen 5B.
700bA*----------------------------------------------------------------
700bA
700bAC     zzcmd5b       begsr
700bA*
700bA*  Command keys to check BEFORE verification and update.
700bA*
700bAC                   if        cmdchk = '*BEFORE '
700bA*
700bAC                   endif
700bA*
700bA*  Command keys to check AFTER verification and update.
700bA*
700bAC                   if        cmdchk = '*AFTER  '
700bAC                   endif
700bAC     endcm5b       endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
     *
     C                   eval      w1scan = *blanks
     C                   endsr

415 A*----------------------------------------------------------------
415 A*  ZZFIL2   Fill screen 2 fields with info from file.
415 A*----------------------------------------------------------------

415 AC     zzfil2        begsr
     *
CLD AC                   eval      w2lic = *blanks
     C                   eval      w2upc = *blanks
     C                   eval      w2item = *blanks
     C                   eval      *in99 = *on
CLD A*
CLD A*  See if license entry field should be displayed.
CLD A*
CLD AC                   if        client = cityline
CLD AC                   eval      *in81 = *on
CLD AC                   else
700aA*  Display icense entry field for all clients.
700aDC**                 eval      *in81 = *off
700aMC                   eval      *in81 = *on
CLD AC                   endif
     *
740aA*
740aA*  See if field will use License or Slot to get item #.
740aA*
740aAC                   if        client = dependable
740aAC                   eval      w2fld1 = 'SLT:'
740aAC                   else
740aAC                   eval      w2fld1 = 'LIC:'
740aAC                   endif
     C                   endsr

415 A*----------------------------------------------------------------
415 A*  ZZFIL3   Fill screen 3 fields with info from file.
415 A*----------------------------------------------------------------

415 AC     zzfil3        begsr
500aA*
500aA*   Format item description
500aA*
500aAC                   call      @fmtit
500aAC                   parm      #stufititem   $iitem           15
500aAC                   parm      #stufitdesc   $idesc           30
500aAC                   parm      #stufitpdsc   $ipdsc           15
500aAC                   parm      ' '           $istr            70
500aAC                   movel     $istr         woitem
500aA
500aA*
500aA*   Format UOM description
500aA*
     C                   exsr      zzuom
500aA*
500aA*   Initialize quantities
500aA*
     C                   eval      w2qt01 = 0
     C                   eval      w2qt02 = 0
     C                   eval      w2qt03 = 0
     *
     C                   endsr

500bA*----------------------------------------------------------------
500bA*  ZZFIL4   Fill screen 4 fields with info from file.
500bA*----------------------------------------------------------------
500bA
500bAC     zzfil4        begsr
     *
610bAC                   setoff                                       3132
650aAC                   setoff                                       33
     C                   eval      w4expd = 0
     C                   eval      wodte = *blanks
610bAC     msckey        chain     itemmsc
610bAC                   if        %found(itemmsc)
610bAC                   if        immflg = 'Y'
610bAC                   eval      *in32 = *on
640aAC                   eval      wodte = 'Pack Dte:'
610bAC                   else
650aAC                   if        #stufitflgd = 'Y'
610bAC                   eval      *in31 = *on
640aAC                   eval      wodte = 'Exp. Dte:'
650aAC                   endif
610bAC                   endif
610bAC                   endif
650aAC
500aA*   To capture entered date if not date sensitive.
HKWaAC                   if        client = HKW
650aAC                             and *in31 = *off
650aAC                             and *in32 = *off
650aAC                   eval      *in33 = *on
650aAC                   eval      wodte = 'Ent. Dte:'
HKWaAC                   endif
     *
     C                   endsr
500aA
650bA*----------------------------------------------------------------
650bA*  ZZFIL5   Fill screen 5 fields with info from file.
650bA*----------------------------------------------------------------
650bA
650bAC     zzfil5        begsr
     *
650bAC*                  setoff                                       3132
650bAC*                  setoff                                       33
650bAC                   eval      w5upc = *blanks
650aAC
650dA*
650dA*   Format item description
650dA*
650dAC                   call      @fmtit
650dAC                   parm      #stufititem   $iitem           15
650dAC                   parm      #stufitdesc   $idesc           30
650dAC                   parm      #stufitpdsc   $ipdsc           15
650dAC                   parm      ' '           $istr            70
650dAC                   movel     $istr         woitem
     *
     C                   endsr
700bA*----------------------------------------------------------------
700bA*  ZZFIL5B  Fill screen 5B fields with info from file.
700bA*----------------------------------------------------------------
700bA
700bAC     zzfil5B       begsr
700bA /free
700bA   // setup which fields are displayed
700bA   if needb1 = *on;
700bA     w5bupc1 = ' ';
700bA     w5buom1 = #stufitum2;
700bA     *in38 = *off;
700bA   else;
700bA     *in38 = *on;
700bA   endif;
700bA   if needb2 = *on;
700bA     w5bupc2 = ' ';
700bA     w5buom2 = #stufitum3;
700bA     *in39 = *off;
700bA   else;
700bA     *in39 = *on;
700bA   endif;
700bA /end-free
     *
     *
700bAC                   endsr
500aA
500aA*----------------------------------------------------------------
500aA*  ZZGETSTUFIT   Get item being stuffed into slot.
500aA*----------------------------------------------------------------
500aA
500aAC     zzgetstufit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #stufslwhse
     C                   eval      $ititem  = w2item

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endgetstufit
     C                   endif

     C                   eval      #stufitwhse = $itwhse
     C                   eval      #stufititem = $ititem
     C                   eval      #stufittype = $ittype
     C                   eval      #stufitdesc = $itdesc
     C                   eval      #stufitpdsc = $itpdsc
     C                   eval      #stufitwhdp = $itwhdp
     C                   eval      #stufitstyp = $itstyp
     C                   eval      #stufitdesg = $itdesg
     C                   eval      #stufitum1  = $itum1
     C                   eval      #stufitflg1 = $itflg1
     C                   eval      #stufitum2  = $itum2
     C                   eval      #stufitumq2 = $itumq2
     C                   eval      #stufitflg2 = $itflg2
     C                   eval      #stufitum3  = $itum3
     C                   eval      #stufitumq3 = $itumq3
     C                   eval      #stufitnrpk = $imnrpk
     C                   eval      #stufitflgd = $itflgd
     C                   eval      #stufitcube = $itcube
     C                   eval      #stufitswgt = $itswgt
     C                   eval      #stufitcwgt = $itcwgt
     C                   eval      #stufitmitem = $itmitem
     C                   eval      #stufitsdef = ' '
     C                   eval      #stufittie  = 0
     C                   eval      #stufithigh = 0
610aAC                   eval      tracklevel = $imltrk

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #stufslsdef
     C                   eval      #stufitsdef = $idsdef(i)
     C                   eval      #stufittie  = $idtie(i)
     C                   eval      #stufithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo

     *  Get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #stufitwhse
     C                   eval      $ititem  = #stufititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      #stufssbflag = *off
650cAC                   eval      ssbflg       = *off
     C                   eval      #stufssbititem = ' '
     C                   eval      #stufssbittype = ' '
     C                   eval      #stufssbitdesc = ' '
     C                   eval      #stufssbitpdsc = ' '
     C                   eval      #stufssbitwhdp = ' '
     C                   eval      #stufssbitstyp = ' '
     C                   eval      #stufssbitdesg = ' '
     C                   eval      #stufssbitum1  = ' '
     C                   eval      #stufssbitum2  = ' '
     C                   eval      #stufssbitumq2 = 0
     C                   eval      #stufssbitum3  = ' '
     C                   eval      #stufssbitumq3 = 0
     C                   else
     C                   eval      #stufssbflag = *on
650cAC                   eval      ssbflg       = *on
     C                   eval      #stufssbititem = $ititem
     C                   eval      #stufssbittype = $ittype
     C                   eval      #stufssbitdesc = $itdesc
     C                   eval      #stufssbitpdsc = $itpdsc
     C                   eval      #stufssbitwhdp = $itwhdp
     C                   eval      #stufssbitstyp = $itstyp
     C                   eval      #stufssbitdesg = $itdesg
     C                   eval      #stufssbitum1  = $itum1
     C                   eval      #stufssbitum2  = $itum2
     C                   eval      #stufssbitumq2 = $itumq2
     C                   eval      #stufssbitum3  = $itum3
     C                   eval      #stufssbitumq3 = $itumq3
     C                   endif

     C     endgetstufit  endsr
500aA
500aA*----------------------------------------------------------------
500aA*  ZZGETSTUFSL   Get slot being stuffed.
500aA*----------------------------------------------------------------
500aA
500aAC     zzgetstufsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1whdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1scan
DFCaAC                   if        client = dependable and
DFCaAC                             uselic = *on
DFCaAC                   eval      $sldisp  = w2lic
DFCaAC                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endgetstufsl
     C                   endif

     C                   eval      #stufslwhse = $slwhse
     C                   eval      #stufslwhdp = $slwhdp
     C                   eval      #stufslstyp = $slstyp
     C                   eval      #stufsldisp = $sldisp
     C                   eval      #stufslaisl = $slaisl
     C                   eval      #stufslloc  = $slloc
     C                   eval      #stufslpseq = $slpseq
     C                   eval      #stufslrlvl = $slrlvl
     C                   eval      #stufslhand = $slhand
     C                   eval      #stufslstat = $slstat
     C                   eval      #stufslrsrv = $slrsrv
     C                   eval      #stufslentd = $slentd
     C                   eval      #stufslexpd = $slexpd
     C                   eval      #stufslslfd = $slslfd
     C                   eval      #stufslactv = $slactv
     C                   eval      #stufslbld  = $slbld
     C                   eval      #stufslpick = $slpick
     C                   eval      #stufslitem = $slitem
     C                   eval      #stufslsdef = $slsdef
     C                   eval      #stufslvirt = $sfvirt
     C                   eval      #stufslstk1 = $slstk1
     C                   eval      #stufslstk2 = $slstk2
     C                   eval      #stufslstk3 = $slstk3
     C                   eval      #stufslalc1 = $slalc1
     C                   eval      #stufslalc2 = $slalc2
     C                   eval      #stufslalc3 = $slalc3
     C                   eval      #stufsltfr1 = $sltfr1
     C                   eval      #stufsltfr2 = $sltfr2
     C                   eval      #stufsltfr3 = $sltfr3
     C                   eval      #stufslpck1 = $slpck1
     C                   eval      #stufslpck2 = $slpck2
     C                   eval      #stufslpck3 = $slpck3
     C                   eval      #stufslrcv1 = $slrcv1
     C                   eval      #stufslrcv2 = $slrcv2
     C                   eval      #stufslrcv3 = $slrcv3
     C                   eval      #stufslphy1 = $slphy1
     C                   eval      #stufslphy2 = $slphy2
     C                   eval      #stufslphy3 = $slphy3
     C                   eval      #stufslavl1 = $slavl1
     C                   eval      #stufslavl2 = $slavl2
     C                   eval      #stufslavl3 = $slavl3

     C                   eval      #stufbasesldsp = $sacdsp

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #stufslpos = $sdpos

     C     endgetstufsl  endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
417a C                   eval      forevr = *off
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   eval      kycode = '*PICK   '
415 A*
415 A*  Define key for UPC file.
415 A*
415 AC     upckey        klist
415 AC                   kfld                    w1whse
415 AC                   kfld                    kyupc
650bA*
650bA*  Define key for UPC2 file.
650bA*
650bAC     keyupc        klist
650bAC                   kfld                    w1whse
650dDC*                  kfld                    #stufititem
650dMC                   kfld                    w2item
650bAC                   kfld                    kyupc
530aA*
530aA*  Define key for ITEM file, by vendor item.
530aA*
530aAC     mfrkey        klist
530aAC                   kfld                    w1whse
530aAC                   kfld                    w2mfri
610bA*
610bA*  Define key for ITEMMSC file.
610bA*
610bAC     msckey        klist
610bAC                   kfld                    #stufitwhse
610bAC                   kfld                    #stufititem
700aA*
700aA*  Define key for SU240WK file.
700aA*
700aAC     su2key        klist
700aAC                   kfld                    w1whse
700aAC                   kfld                    w2lic
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *    - Get default warehouse for the user.
     *
VGOaMC                   call      'GETUSER'
VGOaAC                   parm                    #user
VGOaAC                   parm      0             #whse             3 0
VGOaAC                   parm                    #emp#             5 0
VGOaAC                   parm                    #fnam            15
VGOaAC                   parm                    #init             1
VGOaAC                   parm                    #lnam            20
VGOaAC                   parm      *blanks       #whdp             5
VGOaAC                   parm                    #styp             1
VGOaAC                   parm                    #shft             6
VGOaAC                   parm                    #crew             6
VGOaAC                   parm                    #nhrs             3 1
VGOaAC                   parm                    #rtn              8
     *
     C                   eval      w1whse = #whse
VGOaMC                   eval      w1whdp = #whdp

500 A* Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client
710 AC                   parm                    clientloc
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
     C                   eval      refrsh = *on
     C                   eval      more = *off
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *  ZZRCAL   Recalculate item quantity from slots.
     *----------------------------------------------------------------

     C     zzrcal        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     * Recalculate item qty.
     C                   eval      $jobq = 'N'
     C                   call      'UT812'
500aMC                   parm      #stufitwhse   $pwhs
500aMC                   parm                    #stufititem
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   if        $lrtn = '*PGMQ   '
     C                   endif
     *
     C     endcal        endsr

415 A*----------------------------------------------------------------
415 A*  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
415 A*
415 A*    *IN95=Protect & non-display breakdown1 unit of measure
415 A*----------------------------------------------------------------

415 AC     zzuom         begsr
     *
     *   Determine which UOM's are needed.
     *
     C                   if        #stufitflg1 = 'Y'  or
     C                             ssbflg = *on
     C                   eval      *in95 = *off
     C                   else
     C                   eval      *in95 = *on
     C                   endif
     *
     C                   if        #stufitflg2 = 'Y'  or
     C                             ssbflg = *on  and
     C                             #stufitum3 <> *blanks
     C                   eval      *in96 = *off
     C                   else
     C                   eval      *in96 = *on
     C                   endif
     *
     *   Get Unit of Measures.
     *
     *
     C     #stufitum1    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum1 = umshrt
     C                   else
     C                   eval      woum1 = *blanks
     C                   endif
     *
     C                   eval      woum2 = *blanks
     C                   if        #stufitflg1 = 'Y'  or
     C                             ssbflg = *on
     C     #stufitum2    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum2 = umshrt
     C                   else
     C                   eval      woum2 = *blanks
     C                   endif
     C                   endif
     *
     C                   eval      woum3 = *blanks
     C                   if        #stufitflg2 = 'Y'  or
     C                             ssbflg = *on  and
     C                             #stufitum3 <> *blanks
     C     #stufitum3    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum3 = umshrt
     C                   else
     C                   eval      woum3 = *blanks
     C                   endif
     C                   endif
     *
     C     enduom        endsr

500bA*----------------------------------------------------------------
500bA*  ZZSTUFFITUPD  Do StuffIt update.
500bA*----------------------------------------------------------------
500bA
500bAC     zzstuffitupd  begsr
     C                   eval      error = *off
DRYaAC                   select
DRYaAC                   when      client = dairyland
DRYbDC**                 eval      tracklevel = tLow
DRYbMC                   eval      tracklevel = tMedium
MRTaAC                   when      client = merit
MRTaAC                   eval      tracklevel = tLow
DRYaAC                   endsl
610aA
610aA*  Call license tracking - Before
610aA
610aAC                   if        tracklevel = tLow
610aAC                   eval      $tlic# = '*SI'
610aAC                   eval      $tinlic# = '*SI'
610aAC                   else
610aAC                   exsr      zzzclr$lt210
610aAC                   eval      $tcmd     = '*GETNEW'
610aAC                   eval      $twhse    = #stufitwhse
610aAC                   eval      $titem    = #stufititem
610aAC                   eval      $titemdsc = woitem
610aAC                   eval      $tlic#    = ' '
610aAC                   exsr      zzzcall$lt210
610aAC
610aAC                   if        $treturn <> '*OK'
610aAC                   eval      cancel = *on
610aAC                   leavesr
610aAC                   endif
610aA
610aAC                   endif
600bA
600bA*  Call DRI interface to delete existing slots with item.
600bA
WIL AC                   if        client = Willfoods or
GRCaAC                             client = Greco or
SBRaAC                             client = sbertram
CFIaAC                             or client = colony
SOFaAC                             or client = sofofoods
KFSaAC                             or client = kellys
MRTaAC                             or client = merit
DFCaAC                             or client = dependable
WIL A*    Leave item(s) in the slot.
WIL AC                   else
WIL A*
600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = #stufslwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = #stufslwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = #stufsldisp
600bAC                   eval      $slitemu = *on
600bAC                   eval      $slitem  = #stufititem
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'STF'
600bA
600bAC                   eval      $dricommand = '*SLOT'
600bAC                   eval      $drisubcmd  = '%STUFFDLT'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *on
600baC                   exsr      zzzdricop
600bAC                   if        error
600bAC                   leavesr
600baC                   endif
WIL A*
WIL AC                   endif
610aDC**
610aDC** License tracking. Do Putaway Before update processing.
610aDC**
610aDC**                 exsr      zzzclr$lt210
610aDC**                 eval      $tcmd   = '*PUTSTFB'
610aDC**                 eval      $twhse  = #stufitwhse
610aDC**                 eval      $titem  = #stufititem
610aDC**                 eval      $titemdsc = woitem
610aDC**                 eval      $twhdp  = #stufslwhdp
610aDC**                 eval      $tslot  = #stufsldisp
610aDC**                 eval      $tlic#  = '*SI'
610aDC**                 eval      $tqty1  = w2qt01
610aDC**                 eval      $tqty2  = w2qt02
610aDC**                 eval      $tqty3  = w2qt03
610aDC**                 eval      $tnorm1 = w2qt01
610aDC**                 eval      $tnorm2 = w2qt02
610aDC**                 eval      $tnorm3 = w2qt03
610aDC**                 exsr      zzzcall$lt210
610aDC**                 if        $treturn <> '*OK'
610aDC**                 eval      error = *on
610aDC**                 eval      errmsg = $terrmsg
610aDC**                 exsr      zm0105
610aDC**                 goto      endstuffitupd
610aDC**                 endif

     *  Call DRI interface to do update.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #stufslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #stufslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #stufsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #stufititem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = w2qt01
     C                   eval      $saqty2 = w2qt02
     C                   eval      $saqty3 = w2qt03
     C                   eval      $satasku = *on
     C                   eval      $satask  = 'STUFIT'
     C                   if        #stufitflgd = 'Y'
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w4expdymd
650aAC                   else
HKWaAC                   if        client = HKW
650aAC                   eval      $slentdu = *on
650aAC                   eval      $slentd  = w4expdymd
HKWaAC                   endif
     C                   endif
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'STF'
600bAC                   eval      $saETrn#U = *on
600bAC                   eval      $saETrn# = 0
600bAC                   eval      $saToLcnsU = *on
600bAC                   eval      $saToLcns = $tinlic#
600bAC                   eval      $saToPosU = *on
600bAC                   eval      $saToPos = $tslotpos
600bAC                   eval      $saToVrfyU = *on
600bAC                   eval      $saToVrfy = 'N'
600bAC                   eval      $saToCodeu = *on
600bAC                   eval      $saToCode = 'S'
600bAC                   eval      $saToAreaU = *on
600bAC                   eval      $saToArea = 'Slot'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%STUFFIT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

610aDC** License tracking item. Do Putaway After update processing.
610aDC** Note, parms remembered from Before processing.
610aDC**
610aDC**                 eval      $tcmd   = '*PUTSTFA'
610aDC**                 eval      $twhdp  = $slwhdp
610aDC**                 eval      $tslot  = $sldisp
610aDC**                 exsr      zzzcall$lt210
700a
700a *  Recalculate item qty for slot item
700a
700aAC                   select
700aAC                   when      w2lic <> *blanks
700aAC     su2key        chain     su240wk
700aAC                   if        %found(su240wk)
700aAC                   eval      sustat = '4'
700aAC                   update    su2rec
700aAC                   endif
700aAC                   endsl

     *  Recalculate item qty for slot item

     C                   exsr      zzrcal

     C     endstuffitupd endsr

500bA*----------------------------------------------------------------
500bA*  ZZSTUFFITVFY  Do StuffIt verification
500bA*----------------------------------------------------------------
500bA
500bAC     zzstuffitvfy  begsr
     C                   eval      error = *off

     *  Call DRI interface to do verification.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #stufslwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #stufslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #stufsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #stufititem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = w2qt01
     C                   eval      $saqty2 = w2qt02
     C                   eval      $saqty3 = w2qt03
     C                   eval      $satasku = *on
     C                   eval      $satask  = 'STUFIT'
600bMC                   eval      $saToLcnsu = *on
600bMC                   eval      $saToLcns  = $tlic#
600bMC                   eval      $saToPosu = *on
500dDC**                 eval      $saslpos  = $tslotpos
600bMC                   eval      $saToPos  = 0
     C                   if        #stufitflgd = 'Y'
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w4expdymd
650aAC                   else
HKWaAC                   if        client = HKW
650aAC                   eval      $slentdu = *on
650aAC                   eval      $slentd  = w4expdymd
HKWaAC                   endif
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFYSI'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr02i
     C     endup1        endsr

415 A*----------------------------------------------------------------
415 A*  ZZUPD2   Update for screen 2.
415 A*----------------------------------------------------------------

415 AC     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
650bDC*                  exsr      scr03i
650bMC                   exsr      scr05i
     C     endup2        endsr

     *----------------------------------------------------------------
415 M*  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

415 MC     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      sitem = *blanks
500aA*
650aA*  Do same to capture entered date for FIFO
500bA*  For date sensitive items, delay verification until after getting
500bA*  the expiration date from screen 4.
500bA
500bAC                   if        #stufitflgd = 'Y'
650aAC                             or client = HKW
500bAC                   goto      endup3
500bAC                   endif
500bA
500bAC                   exsr      zzstuffitupd
500bAC                   if        error
610aAC                             or cancel
500bAC                   goto      endup3
500bAC                   endif
     *
     C                   exsr      scr01i
     C     endup3        endsr

500bA*----------------------------------------------------------------
500bA*  ZZUPD4   Update for screen 4.
500bA*----------------------------------------------------------------
500bA
500bAC     zzupd4        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      sitem = *blanks
     C                   exsr      zzstuffitupd
     C                   if        not error
610aAC                             and not cancel
     C                   exsr      scr01i
     C                   endif
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  ZZUPD5   Update for screen 5.
650bA*----------------------------------------------------------------
650bA
650bAC     zzupd5        begsr
650bAC                   eval      error = *off
650bAC                   eval      refrsh = *on
650bA*  Update/Add UPC record.
700bA*  Moved this code from zzchk5 to zzupd5
700bM*
700bM*   Right adjust UPC code for file.
700bM*
700bMC                   eval      $cstr = *blanks
700bMC                   movel     w5upc         $cstr
700bMC                   call      'ADJUST'
700bMC                   parm      '*RIGHT  '    $ccmd             8
700bMC                   parm                    $cstr            30
700bMC                   move      $cstr         kyupc
700bMC                   eval      w5upc = kyupc
650bAC                   if        w5upc <> *blanks
650bAC     keyupc        chain     upc2
650bAC                   if        %found(upc2)
650bAC*
650bAC                   else
650bAC                   eval      upwhse= w1whse
650bAC                   eval      upitem= #stufititem
700bDC*                  eval      upupc = svupc
700bMC                   eval      upupc = kyupc
700bAC                   eval      upuom = #stufitum1
700bAC                   eval      uputyp = 'N'
700bA /free
700bA   Select;
700bA     when ntype = 'UPC-12';
700bA       upctyp = '1';
700bA     when ntype = 'EAN-13';
700bA       upctyp = '2';
700bA     when ntype = 'GTIN';
700bA       upctyp = '3';
700bA     when ntype = 'SCC-14';
700bA       upctyp = '4';
700bA     when ntype = 'SSCC-18';
700bA       upctyp = '5';
700bA     when ntype = ' ';
700bA       upctyp = '6';
700bA   endsl;
700bA /end-free
650bAC                   write     uprec2
650bAC                   endif
650bAC                   eval      sitem = *blanks
650bAC                   endif
700bDC*                  exsr      scr03i
700bMC                   exsr      scr05ib
650bAC                   endsr
700bA*----------------------------------------------------------------
700bA*  ZZUPD5B  Update for screen 5B.
700bA*----------------------------------------------------------------
700bA
700bAC     zzupd5b       begsr
700bAC                   eval      error = *off
700bAC                   eval      refrsh = *on
700bA /free
700bA   // breakdown1
700bA   if writeb1 = *on;
700bA     upwhse = $itwhse;
700bA     upitem = $ititem;
700bA     upupc = b1upc;
700bA     upven = 0;
700bA     upvnam = ' ';
700bA     upvitm = $itvit#;
700bA     upbran = ' ';
700bA     upuom = w5buom1;
700bA     uputyp = '1';
700bA     Select;
700bA       when b1type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b1type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b1type = 'GTIN';
700bA         upctyp = '3';
700bA       when b1type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b1type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
700bA     write uprec2;
700bA   endif;
700bA   // breakdown2
700bA   if writeb2 = *on;
700bA     upwhse = $itwhse;
700bA     upitem = $ititem;
700bA     upupc = b2upc;
700bA     upven = 0;
700bA     upvnam = ' ';
700bA     upvitm = $itvit#;
700bA     upbran = ' ';
700bA     upuom = w5buom2;
700bA     uputyp = '2';
700bA     Select;
700bA       when b2type = 'UPC-12';
700bA         upctyp = '1';
700bA       when b2type = 'EAN-13';
700bA         upctyp = '2';
700bA       when b2type = 'GTIN';
700bA         upctyp = '3';
700bA       when b2type = 'SCC-14';
700bA         upctyp = '4';
700bA       when b2type = 'SSCC-18';
700bA         upctyp = '5';
700bA     endsl;
700bA     write uprec2;
700bA   endif;
700bA /end-free
700bAC                   endsr
500aA*----------------------------------------------------------------
500aA*----------------------------------------------------------------
500aA*                     DRI SUBROUTINES
500aA*----------------------------------------------------------------
500aA*----------------------------------------------------------------

500aA*----------------------------------------------------------------
500aA*  clr$item  Clear $item data structure fields
500aA*----------------------------------------------------------------
500aA
500aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600bAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

500aA*----------------------------------------------------------------
500aA*  clr$slot  Clear $slot data structure fields
500aA*----------------------------------------------------------------
500aA
500aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600bAC                   eval      $saemp#U = *on
600bAC                   eval      $saemp# = #emp#
     C                   endsr

500aA*----------------------------------------------------------------
500aA*  clr$slotdef  Clear $slotdef data structure fields
500aA*----------------------------------------------------------------
500aA
500aAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
500aA
500aA*----------------------------------------------------------------
500aA*  zzzdriclose   Close any open files or programs.
500aA*----------------------------------------------------------------
500aA
500aAC     zzzdriclose   begsr

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

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500aA
500aA*----------------------------------------------------------------
500aA*  zzzdricop  Call DRICOP
500aA*----------------------------------------------------------------
500aA
500aAC     zzzdricop     begsr

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
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
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C**                 if        zmsflag
     C**                 exsr      zm0105s
     C**                 else
     C                   exsr      zm0105
     C**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C**                 if        zmsflag
     C**                 exsr      zm0001s
     C**                 else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500aA*----------------------------------------------------------------
500aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
500aA*----------------------------------------------------------------
500aA
500aAC     ZZZCLR$LT210  begsr

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
500eAC                   clear                   $tnorm1
500eAC                   clear                   $tnorm2
500eAC                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
500cAC                   clear                   $tinslot
500cAC                   clear                   $tsamepos
500cAC                   clear                   $tdiffpos
500cAC                   clear                   $tpsplit
500cAC                   clear                   $tinlic#
500cAC                   clear                   $toutlic#
500caC                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  ZZZCALL$LT210  -  Call LT210 program.
500aA*----------------------------------------------------------------
500aA
500aAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'PUT'         $ttype
     C                   parm      'StuffIt'     $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
500eAC                   parm                    $tnorm1
500eAC                   parm                    $tnorm2
500eAC                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
500cAC                   parm                    $tinslot
500cAC                   parm                    $tsamepos
500cAC                   parm                    $tdiffpos
500cAC                   parm                    $tpsplit
500cAC                   parm                    $tinlic#
500cAC                   parm                    $toutlic#
500cAC                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------
     *----------------------------------------------------------------
**
Dept
Slot
Quantity
Multi MFR items
No MFR item found
Warning: Invalid UPC
