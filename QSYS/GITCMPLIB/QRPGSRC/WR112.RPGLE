      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WR112   Work orders / Repack - Entry
     *  23 February 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    02/23/07  DAS  5.10
     *      - Created
     *
510aA*    03/20/07  TJ   5.10a
     *      - Add edit for entering Repack Item
     *      - Add Date Needed By field
     *      - Add edit for mandatory entry on License
     *      - Add code to see how many Repack Items already built
     *        for this Work Order
     *
510bA*    07/03/07  DAS  5.10b
     *      - Added logic to create putaway transaction.
     *
510cA*    07/20/07  TJ   5.10c
     *      - After F6 Create Work Order, do not display Build Scrn 2
     *
530 A*    03/04/10  JCJ  5.30
     *      - ENH: Add License Tracking
     *
530aA*    03/20/10  JCJ  5.30
     *      - Enh:  Default Date needed to todays date.
     *      - Enh:  Added edit to require break down 1 quantity for
     *              parent.
     *
530bA*    03/29/10  JCJ  5.30b
     *      - Enh:  Added Expiration date to screen2
     *
610 A*    04/15/10  JCJ  6.10
     *      - Enh:  Save $saOLcns & $saToLcns after %GETREPACK
     *
610aA*    04/28/10  JCJ  6.10a
     *      - Enh:  Add edit to force expiration date for date
     *              sensative items.
     *
610bA*    04/30/10  RH   6.10b
     *      - Enh:  Add cmd ZEROVFY to zero verify RPK-01-1 slots
     *
610cA*    04/30/10  JCJ  6.10c
     *      - Enh:  If each quantity exceeds system limit of 999 force
     *              porduct build process in two phases.
     *
610dA*    05/03/10  JCJ  6.10d
     *      - Enh:  Issue warning in parent item qty is zero.
     *
610eA*    05/11/10  JCJ  6.10e
     *      - Enh:  allow override of slot going negative warning.
     *
610fA*    06/02/10  JCJ  6.10f
     *      - Enh:  License # must be unique.
     *
610gA*    07/07/10  JCJ  6.10g
     *      - Enh:  Non display expiration date if item is not date
     *              sensative.
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
650aA*    02/25/13  KDE  6.50a
     *      - Enh: Add ability to capture multiple components(parents)
     *        per a single Repack item
     *      - Enh: Added string RPKWO plus the reference field KOHREF
     *        from work order header to IAMEMO field in ITEMADJ
     *      - Chg: Read all KITCOMP/Parent data into an array during
     *        screen load since the user will not have to page through
     *        all data in 5 record subfile.  This will ensure that I
     *        update all parent items inventory used.  I also
     *        maintain any waste by parent in this same array
     *      - Enh: Screen format updated from WR11201 to WR11202
     *        aded subfile
650bA*    03/01/13  JCJ  6.50b
     *      - Enh: Add Item adjustment for repack item.
650cA*    03/07/13  DAS  6.50c
     *      - Enh: Revised to handle large quantities.
     *      - Enh: Removed 610c change that limited a parent breakdown
     *        adjustment to 999.
650dA*    04/09/13  KDE  6.50d
     *      - Enh: Add code to ensure quantity is replenished properly
     *             for repacks when more parent quantity is required
     *             than available pick slot quantity
650eA*    05/20/13  JCJ  6.50e
     *      - Fix: commented out upload date/time for R3 adjustment.
     *        This will allow the adjustment to get back to host.
650fA*    04/19/13  KDE  6.50f
     *      - Enh: Add code to allow Repack item(s) to be a parent
     *             item on another repack item              '
650gA*    05/06/13  KDE  6.50g
     *      - Enh: Add code to allow On Demand Repacks using the Work
     *             Order screen
650hA*    05/13/13  KDE  6.50h
     *      - Add code to not request Lot number if item is not setup
     *             to require LOT number
650iA*    05/20/13  KDE  6.50i
     *      - Add code properly handle parent usage when repack output
     *             exceed 1
700aA*    01/22/15  KDE  7.00a
     *      - Fix: Changed to prevent ODR replenishment when repack
     *             item is defined as Work Order
710 A*    08/06/17  KDE  7.10
     *      - Fix: Changed to allow Breakdown quantities if Breakdown
     *        unit of measure exist instead of breakdown kit qty
710aA*    08/31/17  KDE  7.10a
     *      - Enh: Changed to allow user to override the Negative Qty
     *        error for RPK slot.
740 A*    09/08/20  KDE  7.40
     *      - Enh: Changed force 1 to Breakdown quantities during checks
     *      - Enh: Ensure all parent RPK slots exist before creating
     *        new work order
750 A*    02/17/21  KDE  7.50
     *      - Enh: Add licadj using code from PO236
PAN A*
PAN A*----------------------------------------------------------------
PAN A*  Client Custom Revisions: Panos
PAN A*
PAN A*    06/06/17  KDE  PAN
PAN A*      - Enh: Changed to adjust full case between case item and
PAN A*             breakdown item when a partial is used or wasted
PAN A*----------------------------------------------------------------
DRYaA*  Client Custom Revisions: Dairyland
DRYaA*
DRYaA*    10/15/21  KDE  DRYa
DRYaA*      - Enh: Changed to send back RPKWO12345 where 12345 is the
DRYaA*             Repack Work Order Number
SPIaA*----------------------------------------------------------------
SPIaA*  Client Custom Revisions: Stern Produce
SPIaA*
SPIaA*    08/24/17  RTR  SPIa
SPIaA*      - Enh: Changed to get unique number and use in memo for
SPIaA*             adjustments. Needed for Thyme to match parts of
SPIaA*             repack adjustments for cost handling.
SPIaA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

610gD *** wr112fm   cf   e             workstn
650aD *** wr11201   cf   e             workstn
650aAFwr11202   cf   e             workstn
     F                                     infds(infds)
650aAF                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
650gAFkitordh2  if a e           k disk    prefix(k2_)
650gAF                                     rename(kohrec:k2rec)
650gAFkitordh3  if a e           k disk    prefix(k3_)
650gAF                                     rename(kohrec:k3rec)
     Fkitordh   uf a e           k disk
     F                                     rename(kohrec:record)
     Fkitordd   uf a e           k disk
     Fkitcomp   if   e           k disk
650aAF                                     rename(kcrec:recordp)
650aAFkititem   if   e           k disk
     Foptions   if   e           k disk
     Flabel     o  a e           k disk
     Flicense   uf a e           k disk
650bAFitemadj   o  a e             disk
650hAfitemmsc   if   e           k disk
750 AFlicadj    o  a e           k disk    usropn

PAN A*----------------------------------------------------------------
PAN A*  Customer id
PAN A*----------------------------------------------------------------
PAN A
PAN A /copy qcopysrc,id#pan
SPIaA /copy qcopysrc,id#spi
DRYaA /copy qcopysrc,id#dairyla

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#ITEMQTY
      /COPY *libl/qcopysrc,C#SLOT
510aA /COPY *libl/qcopysrc,C#PRTYRPL
510bA /COPY *libl/qcopysrc,C#LICINFO
530 D**COPY *libl/qcopysrc,C#LICHIST
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

650aA*----------------------------------------------------------------
650aA*  Called program parameters
650aA*----------------------------------------------------------------
650aA
650aAD $postn          ds
650aAD  $pocmd                 1      8
650aAD  $poprg                 9     18
650aAD  $pofky                19     68
650aAD  $pouky                69    118
650aAD  $podsc               119    307
650aAD                                     dim(3)
650aAD  $popt1               308    322
650aAD  $popt2               323    335
650aAD  $portn               336    343
650aAD  $poerm               344    403
650aAD  $pomsg               336    339

650aA*----------------------------------------------------------------
650aA*  Program parameters
650aA*----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
650aAD  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
510aAD  $pndt                 22     29  0
     D  $pord                 30     36  0
     D  $pitem                37     51

     *----------------------------------------------------------------
     *  *REPACK  -  Repack options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPADJ  -  Parent adjustment code
     *    OPWADJ  -  Parent waste adjustment code
     *    OPRADJ  -  Repack adjustment code
     *    OPRASL  -  Repack area aisle
     *
      * Data structure
     *
510aAD opdat1          ds
510aAD  opfeat                 1      1
     D  oppadj                 1      2
     D  opwadj                 3      4
     D  opradj                 5      6
     D  oprasl                 7      9
     D  optend               117    117

510aA
510aA*----------------------------------------------------------------
510aA*  *REPLEN  -  Replenishment options.
510aA*----------------------------------------------------------------
510aA*
510aA* Fields
510aA*
510aA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
510aA*    OPOQRP  -  Order qty replenishment (Y/N).
510aA*
510aA* Data structure
510aA*
510aAD opdat2          ds
510aAD  oprplb                 1      8
510aAD  opoqrp                 9      9
510aAD  opten2               117    117

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     60

     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
      *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)

650aA*----------------------------------------------------------------
650aA*  Program info data structure
650aA*
650aAD                sds
650aAD  #prog            *proc
650aAD  #pgm             *proc
650aAD  #status               11     15
650aAD  #stmt                 21     28  0
650aAD  #pgmmsg               91    170
650aAD  #job                 244    253
650aAD  #user                254    263
650aAD  #jobn                264    269
650aAD  #jobdt               276    281  0
650aAD  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
650aDD* status           *status
650aAD  status               369    369
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

     D                 ds
650iDD* wopqndec               1      5  2
650iMD  wopqndec               1     15  2
650iDD* dec                    4      5  0
650iMD  dec                   14     15  0
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

510aA*----------------------------------------------------------------
510aA*  Called programs
510aA*----------------------------------------------------------------
510aAD @cvtdt          c                   const('CVTDTE')
510bAD @addtr          c                   const('ADDSTDTRN')

750 A /copy qcopysrc,p.getoptio

SPIaAD GetRecId        pr                  extpgm('GETRECID')
SPIaAD  grWhse                        3s 0 const
SPIaAD  grFile                       10    const
SPIaAD  grRecId                      11p 0

750 AD getAdjCode      pr                  extpgm('GETADJCOD')
750 AD  pCode                         2    const
750 AD  pDesc                        30
750 AD  pSys                          1

     *----------------------------------------------------------------
     *  CVTDTE parameters
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

530aAD Today                           d   Datfmt(*ISO) Inz
530aAD  TodayYear                     4    overlay(Today)
530aAD  TodayMonth                    2    overlay(Today:6)
530aAD  TodayDay                      2    overlay(Today:9)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aA*
650aA*  Data Structure (array) to save any waste being entered by item
650aA*
650aAD                 ds
650aA
     D chk4err         s               n
     D drierr          s               n
     D startFlag       s               n
     D zmsflag         s               n
650gAD onDmdonDmd      s               n
650gAd $odrneed        s              5  0
650gAd woopnqty        s              5  0
650gAD main3err        s               n
650gAD main3callerr    s               n
650gAD main3rtnerr     s               n
650gAd subRec          s              5  0
     D $msgf           s             10
650gAD $twhse          s              3
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
650gAD woStat          s              1
     D comand          s              5  0
     D curdate         s              8  0
     D curtime         s              6  0
650iAD wrkqty1         s              5  0
650iAD wrkqty2         s              5  0
650iAD wrkqty3         s              5  0
510aAD w2ndtc          s              8  0
     D e               s              2  0
650aAd dsplyd          s              4  0
650aAd reccnt          s              4  0
650aAd WstPtr          s              3  0
650aAd p               s              4  0
650aAd savNxt          s              4  0 inz(0)
650aAd gobrik          s              4  0
650aAD clear           c                   const(X'BD')
650aAD help            c                   const(X'F3')
650aAD enter           c                   const(X'F1')
650aAD rolldn          C                   const(X'F4')
650aAD rollup          C                   const(X'F5')
650aAD f20             C                   const(X'B8')
650aAD f12             C                   const(X'3C')
650aAD sclear          s              1
650aAD redspl          s               n
650aAD forever         s               n
650aAD byPassRepl      s               n
650aAD FirstPass       s               n
650aAD FrmRollUp       s               n
650aAD bot             s               n
650aAD stop            s               n
650aAD top             s               n
     D error           s               n
     D kycode          s                   like(opcode)
     D lasttime        s              6  0
     D msgk            s              4  0
     D nxtscr          s              3
     D total           s              5  0
650iAD adjQty1         s              5  0
650iAD adjQty2         s              5  0
650iAD adjQty3         s              5  0
     D warn            s              1    inz('0')
610dAD ovrrid          s              1
710aAD ovrQty          s              1
510bAD $rcmd           s             10
510bAD $rwhse          s              3  0
510bAD $ritem          s             15
510bAD $rqty           s              5  0
510bAD $rby            s              1
510bAD $rref           s             15
510bAD $rrtn           s             10
510bAD $rmsg           s             60
510bAD $rord           s              7  0
510bAD $rndtc          s              8  0
510bAD $pbat           s              7  0
510bAD pttrn#          s              7  0
510bAD livestat        s              8
510bAD @pcmd           s              8
510bAD @ptrn#          s              7  0
510bAD @ptask          s              6
510bAD @pwhse          s              3  0
510bAD @pwhdp          s              5
510bAD @pstyp          s              1
510bAD @pcube          s              9  3
510bAD @pswgt          s              9  2
510bAD @ppcs           s              5  0
510bAD @paisl          s              5  0
510bAD @pqty1          s              5  0
510bAD @pqty2          s              5  0
510bAD @pqty3          s              5  0
510bAD @prte           s              5
510bAD @ppo            s              9
510bAD @pgrp1          s              1
650aAD @pgrp2          s              1
510bAD @prtn           s              8
510bAD @pmsg           s              4
510bAD ck4err          s              1
510bAD rcvdday         s              3
510bAD rcvmday         s              3
510bAD rcvuday         s              3
510bAD $ppo            s              9
510bAD $pseq           s              5  0
510bAD $pindt          s              8  0
510bAD $pfifo          s              8  0
510bAD $pexpd          s              8  0
510bAD $pawt1          s              7  2
510bAD $pawt2          s              7  2
510bAD $pawt3          s              7  2
510bAD $code           s             10
510bAD $whse           s              3  0
510bAD $emp#           s              5  0
510bAD $fnam           s             15
510bAD $init           s              1
510bAD $lnam           s             20
510bAD $whdp           s              5
510bAD $styp           s              1
510bAD $shft           s              6
510bAD $crew           s              6
510bAD $nhrs           s              3  1
510bAD $rtn            s              8
510bAD w1umt           s              1    inz('N')
510bAD w1xdk           s              1    inz('N')
530aAD MDY             s               d   DatFmt(*MDY)
530bAD ISO             s               d   DatFmt(*ISO)
530bAD #rcvarea        s              6
610cAD w1limit         s              5  0
610eAD qty1            s              5  0
610eAD qty2            s              3  0
610eAD qty3            s              3  0
610fAD $ccmd           s              8
610fAD $cstr           s             30
650aAd wopdsp          s             12
650aAd wopitm          s             50
650aAd wopqn           s              3  0
650aAd wopqnu          s              2
650aAd woratio         s             50
650aAd woruom          s              2
650aAd wouom           s             40
650aAd prvkey          s                   like(#parentititem)
650aAd wowuom          s             40
SPIaAd RpkID           s             11p 0 inz(0)
750 AD useLicAdj       s               n
750 AD recidnum        s             11p 0
750 AD gaDesc          s             30a
750 AD gaSys           s              1a
750 AD getoptval       s            117a
650aA
650aAd Frmtit          PR                  extpgm('FRMTIT')
650aAd  frmitm                             like(#parentititem)
650aAd  frmdesc                            like(#parentitdesc)
650aAd  frmpdsc                            like(#parentitpdsc)
650aAd  frmhead                            like(#parentithead)
650aA
510bAD currtimestamp   s               z

650aAd                 ds
650aAd arySFL                              dim(250)

650aAD  #parentitwhse                      like($itwhse)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentititem                      like($ititem)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentittype                      like($ittype)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitdesc                      like($itdesc)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitpdsc                      like($itpdsc)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentithead                70
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitwhdp                      like($itwhdp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitstyp                      like($itstyp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitdesg                      like($itdesg)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitum1                       like($itum1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitflg1                      like($itflg1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitum2                       like($itum2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitumq2                      like($itumq2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitflg2                      like($itflg2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitum3                       like($itum3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitumq3                      like($itumq3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitnrpk                      like($imnrpk)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitflgd                      like($itflgd)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitcube                      like($itcube)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitswgt                      like($itswgt)
650aAD                                     overlay(arySFL:*next)
650aAD  #parentitcwgt                      like($itcwgt)
650aAd                                     overlay(arySFL:*next)
650aAD #parentitmitem                      like($itmitem)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentitsdef                      like($idsdef)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentittie                       like($idtie)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentithigh                      like($idhigh)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentqty1                        like(w1sqty1)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentqty2                        like(w1sqty2)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentqty3                        like(w1sqty3)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentWaste1                      like(w1swq1)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentWaste2                      like(w1swq2)
650aAd                                     overlay(arySFL:*next)
650aAd  #parentWaste3                      like(w1swq3)
650aAd                                     overlay(arySFL:*next)

650aAD  #parentslwhse                      like($slwhse)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslwhdp                      like($slwhdp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslstyp                      like($slstyp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentsldisp                      like($sldisp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslaisl                      like($slaisl)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslloc                       like($slloc)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslpseq                      like($slpseq)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslrlvl                      like($slrlvl)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslhand                      like($slhand)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslstat                      like($slstat)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslrsrv                      like($slrsrv)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslentd                      like($slentd)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslexpd                      like($slexpd)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslslfd                      like($slslfd)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslactv                      like($slactv)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslbld                       like($slbld)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslpick                      like($slpick)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslitem                      like($slitem)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslsdef                      like($slsdef)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslvirt                      like($sfvirt)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslstk1                      like($slstk1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslstk2                      like($slstk2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslstk3                      like($slstk2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslalc1                      like($slalc1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslalc2                      like($slalc2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslalc3                      like($slalc3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentsltfr1                      like($sltfr1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentsltfr2                      like($sltfr2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentsltfr3                      like($sltfr3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslpck1                      like($slpck1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslpck2                      like($slpck2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslpck3                      like($slpck3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslrcv1                      like($slrcv1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslrcv2                      like($slrcv2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslrcv3                      like($slrcv3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslphy1                      like($slphy1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslphy2                      like($slphy2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslphy3                      like($slphy3)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslavl1                      like($slavl1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslavl2                      like($slavl2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentslavl3                      like($slavl3)
650aAd                                     overlay(arySFL:*next)
650aAD #parentbasedsp                      like($sldisp)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentiqavl1                      like($iqavl1)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentiqavl2                      like($iqavl2)
650aAd                                     overlay(arySFL:*next)
650aAD  #parentiqavl3                      like($iqavl3)
650aAd                                     overlay(arySFL:*next)
650aMD  #bypassrepl                        like(byPassRepl)
650aAd                                     overlay(arySFL:*next)
650aA
650aAD  #repackitwhse                      like($itwhse)
650aAD  #repackititem                      like($ititem)
650aAD  #repackittype                      like($ittype)
650aAD  #repackitdesc                      like($itdesc)
650aAD  #repackitpdsc                      like($itpdsc)
650aAD  #repackithead                70
650aAD  #repackitwhdp                      like($itwhdp)
650aAD  #repackitstyp                      like($itstyp)
650aAD  #repackitdesg                      like($itdesg)
650aAD  #repackitum1                       like($itum1)
650aAD  #repackitflg1                      like($itflg1)
650aAD  #repackitum2                       like($itum2)
650aAD  #repackitumq2                      like($itumq2)
650aAD  #repackitflg2                      like($itflg2)
650aAD  #repackitum3                       like($itum3)
650aAD  #repackitumq3                      like($itumq3)
650aAD  #repackimdday                      like($imdday)
650aAD  #repackimmday                      like($immday)
650aAD  #repackimmflg                      like($immflg)
650aAD  #repackimuday                      like($imuday)
650aAD  #repackitnrpk                      like($imnrpk)
650aAD  #repackitflgd                      like($itflgd)
650aAD  #repackitcube                      like($itcube)
650aAD  #repackitswgt                      like($itswgt)
650aAD  #repackitcwgt                      like($itcwgt)
650aAD #repackitmitem                      like($itmitem)
650aAD  #repackitsdef                      like($idsdef)
650aAD  #repackittie                       like($idtie)
650aAD  #repackithigh                      like($idhigh)
650aAd  #repackoutqty                      like(kiqty1)

650aAD  #repackslwhse                      like($slwhse)
650aAD  #repackslwhdp                      like($slwhdp)
650aAD  #repackslstyp                      like($slstyp)
650aAD  #repacksldisp                      like($sldisp)
650aAD  #repackslaisl                      like($slaisl)
650aAD  #repackslloc                       like($slloc)
650aAD  #repackslpseq                      like($slpseq)
650aAD  #repackslrlvl                      like($slrlvl)
650aAD  #repackslhand                      like($slhand)
650aAD  #repackslstat                      like($slstat)
650aAD  #repackslrsrv                      like($slrsrv)
650aAD  #repackslentd                      like($slentd)
650aAD  #repackslexpd                      like($slexpd)
650aAD  #repackslslfd                      like($slslfd)
650aAD  #repackslactv                      like($slactv)
650aAD  #repackslbld                       like($slbld)
650aAD  #repackslpick                      like($slpick)
650aAD  #repackslitem                      like($slitem)
650aAD  #repackslsdef                      like($slsdef)
650aAD  #repackslvirt                      like($sfvirt)
650aAD  #repackslstk1                      like($slstk1)
650aAD  #repackslstk2                      like($slstk2)
650aAD  #repackslstk3                      like($slstk2)
650aAD  #repackslalc1                      like($slalc1)
650aAD  #repackslalc2                      like($slalc2)
650aAD  #repackslalc3                      like($slalc3)
650aAD  #repacksltfr1                      like($sltfr1)
650aAD  #repacksltfr2                      like($sltfr2)
650aAD  #repacksltfr3                      like($sltfr3)
650aAD  #repackslpck1                      like($slpck1)
650aAD  #repackslpck2                      like($slpck2)
650aAD  #repackslpck3                      like($slpck3)
650aAD  #repackslrcv1                      like($slrcv1)
650aAD  #repackslrcv2                      like($slrcv2)
650aAD  #repackslrcv3                      like($slrcv3)
650aAD  #repackslphy1                      like($slphy1)
650aAD  #repackslphy2                      like($slphy2)
650aAD  #repackslphy3                      like($slphy3)
650aAD  #repackslavl1                      like($slavl1)
650aAD  #repackslavl2                      like($slavl2)
650aAD  #repackslavl3                      like($slavl3)
650aAd  repackbasedsp                      like($sldisp)
700aAd  #repackkirptp                      like(kirptp)

     D pSavOLcns       s                   like($saOLcns)
     D pSavToLcns      s                   like($saToLcns)
     D rSavOLcns       s                   like($saOLcns)
     D rSavToLcns      s                   like($saToLcns)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
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

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr

     *   Set ON alarm indicator if error occured

     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif

     *   Overlay screen with error messages

     C                   exsr      zmdmsg

     *  Overlay screen with screen to be processed.

     C                   if        nxtscr = '01 '
650aDC*                  exfmt     screen1                              50
650aAC                   exsr      sfldsp
650aAC                   read      head1                                  50
     C                   endif

     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif

     *   Initialize error indicators and fields

     C                   setoff                                       010203
     C                   setoff                                       04
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
650aAC                   eval      redspl = *off
     C                   eval      e = 0

     *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Get Next record
     *----------------------------------------------------------------

650aAC     fgetn         begsr
650aA /free
650aA    reade partky recordp;
650aA    If %equal and not %eof;
650aA       $portn = '*FOUND';
650aA    else;
650aA       $portn = '*NOMORE';
650aA    endif;
650aA /end-free
650aAc                   endsr

     *----------------------------------------------------------------
     *  Get Previous record
     *----------------------------------------------------------------

650aAC     fgetp         begsr
650aA /free
650aA    readpe partky recordp;
650aA    If not %eof;
650aA       $portn = '*FOUND';
650aA    else;
650aA       $portn = '*NOMORE';
650aA    endif;
650aA /end-free
650aAc                   endsr

650aA*----------------------------------------------------------------
650aA*  zzLoad_Parent array
650aA*----------------------------------------------------------------
650aAc     zzLoad_Parent begsr
650aA
650aA*  Get Parent Item information.
650aA*    This array will be searched during checks and updates.
650aA*    The subfile only loads 5 records.  The Repack item in
650aA*    theory could have more than 5 records.  Therefore during
650aA*    checks, and updates of parent quantities and waste this
650aA*    array will be used.  As waste quantities are entered via
650aA*    the subfile they are transfered to this array for update
650aA
650aAc                   eval      savNxt = 0
650aAC     keykc2        setll     kitcomp
650aAC     keykc2        reade(e)  kitcomp
650aAc                   dow       %equal and not %eof
650aAc                   eval      savNxt = savNxt + 1
650aAC                   eval      kohwhs = $pwhse
650aAc                   exsr      zzgetparentit
650aAc                   exsr      zzgetparentiq
650aAc                   exsr      zzgetparentsl
740 A*    Create RPK slot when not foundf
740 A
740 Ac                   if        $drireturn='RPKNOTFND'
740 AC                   call      'CRTWRKORD'
740 AC                   parm      '*CRTRPKSLT'  $rcmd
740 AC                   parm      $pwhse        $rwhse
740 AC                   parm      w2item        $ritem
740 AC                   parm      0             $rqty
740 AC                   parm      'M'           $rby
740 AC                   parm      ' '           $rref
740 AC                   parm      ' '           $rrtn
740 AC                   parm      ' '           $rmsg
740 AC                   parm      0             $rord
740 AC                   parm      w2ndtc        $rndtc
740 Ac                   exsr      zzgetparentsl
740 Ac                   endif

650aAc                   eval      #parentqty1(savNxt) = kcqty1
650aAc                   eval      #parentqty2(savNxt) = kcqty2
650aAc                   eval      #parentqty3(savNxt) = kcqty3
650aAc                   eval      #parentwaste1(savNxt) = 0
650aAc                   eval      #parentwaste2(savNxt) = 0
650aAc                   eval      #parentwaste3(savNxt) = 0

650aAC                   eval      w2edt = *zeros
650aMC                   if        #parentslexpd(savNxt) > *zeros
650aAc                   eval      iso=%date(#parentslexpd(savNxt):*iso)
650aAC                   move      iso           mdy
650aAC                   move      mdy           w2edt
650aAC                   endif

650aAC                   if        #parentiqavl1(savNxt) = 0
650aAC                             and #parentiqavl2(savNxt) = 0
650aAc                   eval      #bypassrepl(savNxt)=*on
650aAc                   else
650aAc                   eval      #bypassrepl(savNxt)=*off
650aAc                   endif
650aAC                   eval      woword = kohord
650aAC                   eval      wopitm = #parentithead(savNxt)
650aAC                   eval      wopdsp = #parentsldisp(savNxt)
650aAC                   eval      woritm = #repackithead
     C
650aAC                   eval      wouom  = '  '
650aAC                   select
650aAC                   when      w1sqty1 > 0
650aAC                   eval      wouom  = '* No Breakdown Needed *'
650aAC                   when      w1sqty2 > 0
650aAC                   if        #parentitumq2(savNxt) > 0
650aMC                   eval      wouom  = %trim(%editc(#parentitumq2(savNxt):
650aAC                                         'P'))
650aAC                                    + ' '
650aMC                                    + #parentitum2(savNxt) +
650aAC                                    ' / ' + #parentitum1(savNxt)
650aAC                   endif
650aMC                   when      w1sqty3 > 0
650aMC                   if        #parentitumq3(savNxt) > 0
650aMC                   eval      total = #parentitumq3(savNxt) *
650aAC                                     #parentitumq2(savNxt)
650aAC                   eval      wouom  = %trim(%editc(total:'P'))
650aAC                                    + ' '
650aMC                                    + #parentitum3(savNxt)
650aAC                                    + ' / ' + #parentitum1(savNxt)
650aAC                   endif
650aAC                   endsl

650aAC                   if        wouom  = ' '
650aAC                   eval      wouom  = '* Not Defined *'
650aAC                   endif

650aAC                   eval      woratio = ' '
650aAC                   select
650aMC                   when      w1sqty1 > 0
650aMC                   eval      wopqn   = w1sqty1
650aMC                   eval      wopqnu  = #parentitum1(savNxt)
650aMC                   eval      woratio = %trim(%editc(w1sqty1:'P'))
650aAC                                    + ' '
650aMC                                    + #parentitum1(savNxt)
650aAC                   when      w1sqty2 > 0
740 Ac                   monitor
650aMC                   eval(h)   wopqndec= (kohqty * w1sqty2)
650aMC                                       / #parentitumq2(savNxt)
740 Ac                   on-error
740 AC                   eval(h)   wopqndec= (kohqty * w1sqty2)
740 Ac                   endmon
510aAC                   eval      wopqn = wopqndec
510aAC                   if        dec >= 01
510aAC                   eval      wopqn   = wopqn + 1
510aAC                   endif
650aMC                   eval      wopqnu  = #parentitum1(savNxt)
650aMC                   eval      woratio = %trim(%editc(w1sqty2:'P'))
650aAC                                    + ' '
650aMC                                    + #parentitum2(savNxt)
650aAC                   when      w1sqty3 > 0
740 Ac                   monitor
650aMC                   eval(h)   wopqndec= (kohqty * w1sqty3)
650aMC                                       / (#parentitumq2(savNxt)
650aMC                                           * #parentitumq3(savNxt))
740 Ac                   on-error
740 AC                   eval(h)   wopqndec= (kohqty * w1sqty3)
740 Ac                   endmon
510aAC                   eval      wopqn = wopqndec
510aAC                   if        dec >= 01
510aAC                   eval      wopqn   = wopqn + 1
510aAC                   endif
650aMC                   eval      wopqnu  = #parentitum1(savNxt)
650aMC                   eval      woratio = %trim(%editc(w1sqty3:'P'))

650aMC                                    + #parentitum3(savNxt)
650aAC                   endsl
650aAC                   eval      woratio = %trim(woratio)
650aAC                                     + ' to 1 Repack'

650aAC                   eval      worqn   = kohqty
650aMC                   eval      woruom  = #repackitum1

650aAC                   eval      w1swq1 = 0
650aAC                   eval      w1swq2 = 0
650aAC                   eval      w1swq3 = 0

650aAC                   select
650aMC                   when      w1sqty1 > 0
650aMC                   eval      wowuom  = #parentitum1(savNxt)
650aMC                   when      w1sqty2 > 0
650aMC                   eval      wowuom  = #parentitum2(savNxt)
650aMC                   when      w1sqty3 > 0
650aMC                   eval      wowuom  = #parentitum3(savNxt)
650aMC                   endsl

650aAC     keykc2        reade(e)  kitcomp
650aAc                   enddo
650aAC     *loval        setll     kitcomp
650aAc                   endsr

650gA*----------------------------------------------------------------
650gA*  Create Priority Replenishment for On-Demand Work Order when
650gA*   breaker slot has too few to process the request
650gA*----------------------------------------------------------------
650gAc     zzOdrReplen   begsr
650gA*
650gA* Create Priority Replenishment to move parent qty to repack area
650gA
650gA*  Loop through each parent item associated to the repack item
650gA
650gAc                   if        %subst($sldisp:1:3)<>'RPK'
650gAC                   exsr      clr$prtyrpl
650gAc                   eval      $odrneed = 0
650gA*
650gA*    Retrieve FS-WMS replenishment options.
650gA*
650gAC                   eval      kycode = '*REPLEN '
650gAC     keyop         chain     options                            79
650gAC                   select
650gAC                   when      *in79
650gAC                   eval      opoqrp = 'N'
650gAC                   when      not *in79
650gAC                   eval      opdat2 = opdata
650gAC                   endsl
650gA*
650gA*  determine replenishment quantity required for on-demand item
650gA*** Get available quantities from breaker slot
650gAC                   exsr      clr$slot
650gAC                   eval      $slwhseu = *on
650gAC                   eval      $slwhse  = #parentitwhse(wstPtr)
650gAC                   eval      $slwhdpu = *on
650gAC                   eval      $slwhdp  = #parentitwhdp(wstPtr)
650gAC                   eval      $sldispu = *on
650gAC                   eval      $sldisp  = #parentsldisp(wstPtr)
650gA
650gAC                   eval      $dricommand = '*SLOT'
650gAC                   eval      $drisubcmd  = '%GET'
650gAC                   eval      $drisys2upd = 'D'
650gAC                   eval      chk4err = *on
650gAC                   eval      zmsflag = *on
650gAC                   exsr      zzzdricop
650gA /free
650gA    select;
650gA       when #parentitumq3(wstPtr)<>0;
650gA          wopqndec = (($slavl1 * #parentitumq2(wstPtr)
650gA            * #parentitumq3(wstPtr) + ($slavl2 * #parentitumq3(wstPtr))
650gA              + $slavl3));
650gA          wopqndec = wopqndec -
650gA            (adjQty1 * kcqty3);
650gA       // if available minus need is less than zero then we need replen
650gA          if wopqndec <  0;
650gA             $saqty1 = 0;
650gA             $saqty2 = 0;
650gA             $saqty3 = %abs(wopqndec);  // set bkd 2 qty needed
650gA             exsr zzupqty;
650gA          else;
650gA             $saqty1 = 0;
650gA             $saqty2 = 0;
650gA             $saqty3 = 0;  // no replen needed
650gA          endif;
650gA
650gA       when #parentitumq2(wstPtr)<>0;
650gA          wopqndec =   (($slavl1 * #parentitumq2(wstPtr)
650gA              + $slavl2));
650gA          wopqndec = wopqndec -
650gA                (adjQty2 * kcqty2);
650gA       // if available minus need is less than zero then we need replen
650gA          if wopqndec <  0;
650gA             $saqty1 = 0;
650gA             $saqty3 = 0;
650gA             $saqty2 = %abs(wopqndec);  // set bk1 qty needed
650gA             exsr zzupqty;
650gA          else;
650gA             $saqty1 = 0;
650gA             $saqty3 = 0;
650gA             $saqty2 = 0;    // no replen needed
650gA          endif;
650gA
650gA          other;
650gA          wopqndec = $slavl1 - adjQty1;
650gA       // if available minus need is less than zero then we need replen
650gA          if wopqndec <  0;
650gA             $saqty1 = %abs(wopqndec);  // set normal quantity needed
650gA             $saqty2 = 0;
650gA             $saqty3 = 0;
650gA          else;
650gA             $saqty1 = 0;    // no replen needed
650gA             $saqty2 = 0;
650gA             $saqty3 = 0;
650gA          endif;
650gA
650gA    endsl;
650gA
650gA    // set full case quantity for replen
650gA    select;
650gA
650gA       when $saqty1<>0;
650gA          $odrneed = $saqty1;
650gA          if $saqty2<>0 or $saqty3<>0;
650gA             $odrneed = $odrneed + 1;
650gA          endif;

650gA       other;
650gA          if $saqty2<>0 or $saqty3<>0;
650gA             $odrneed = 1;
650gA          endif;

650gA    endsl;
650gA
650gA /end-free
650gA*
650gAc                   if        $odrneed > 0
650gAC                   eval      $prwhseu = *on
650gAC                   eval      $prwhse = #parentitwhse(wstPtr)
650gA
650gAC                   eval      $pritemu = *on
650gAC                   eval      $pritem  = #parentititem(wstPtr)
650gA
650gAC                   eval      $prwhdpu = *on
650gAC                   eval      $prwhdp  = #parentitwhdp(wstPtr)
650gA
650gAC                   eval      $prslotu = *on
650gAC                   eval      $prslot  = $sldisp
650gA
650gAC                   eval      $prqtynu = *on
650gAC                   eval      $prqtyn  = $odrneed
650gA
650gAC                   eval      $prfillu = *on
650gAC                   eval      $prfill  = 'Y'
650gA
650gA*  Call program to create priority replenishments.
650gA
650gA*  Note: the priority replenishment program will send back a
650gA*        non-*OK return code explaining why a replenishment
650gA*        couldn't be created, as well as errors, of course.
650gA*        Since, creating a priority replenishment is not our
650gA*        primary concern, we ignore all return codes.
650gA
650gAC                   eval      $dricommand = '*PRTYRPL'
650gAC                   eval      $drisubcmd = '*CRTRPLODR'
650gAC                   exsr      zzzdricop
650gAc                   endif
650gAc                   endif
650gA
650gAc                   endsr
650gA*----------------------------------------------------------------
650gA*  Calculate open quantity in Work Order file for sleected
650gA*   on-demand item to verify Replenishment Quantity
650gA*----------------------------------------------------------------
650gAc     zzOpnWOQty    begsr
650gA /free
650gA    woopnqty = 0;
650gA    setll (#repackitwhse:#repackititem) kitordh2;
650gA    reade (#repackitwhse:#repackititem) kitordh2;
650gA    dow not %eof and %found; //process orders setup but no builds
650gA       woopnqty = woopnqty + k2_kohqty;
650gA       reade (#repackitwhse:#repackititem) kitordh2;
650gA    enddo;
650gA
650gA    setll (#repackitwhse:#repackititem) kitordh3;
650gA    reade (#repackitwhse:#repackititem) kitordh3;
650gA    dow not %eof and %found; //process orders with builds not cls
            if k3_kohsta = '2';
650gA          woopnqty = woopnqty + k3_kohqty;
650gA          setll (k3_kohwhs:k3_kohord:k3_kohitm) kitordd;
650gA          reade (k3_kohwhs:k3_kohord:k3_kohitm) kitordd;
650gA          dow not %eof and %found;
650gA             woopnqty = woopnqty - kodqty;
650gA             reade (k3_kohwhs:k3_kohord:k3_kohitm) kitordd;
650gA          enddo;
650gA       endif;
650gA       reade (#repackitwhse:#repackititem) kitordh3;
650gA    enddo;
650gA /end-free
650gAc                   endsr
650aA*----------------------------------------------------------------
650aA*  Roll Up was pressed
650aA*----------------------------------------------------------------
650aA
650aAC     pag1bk        begsr
650aA /free
650aA     if not top;
650aA        // get that previous page pointer
650aA        gobrik = dsplyd + 5;
650aA        if bot;
650aA           gobrik +=1;
650aA        endif;
650aA        p = 0;
650aA        bot = *off;
650aA        top = *off;
650aA        stop = *off;
650aA        setll compky recordp;
650aA        // get previous 5 records to display
650aA        dou stop;
650aA           exsr fgetp;
650aA           // hit top of file
650aA           if $portn = '*NOMORE ';
650aA              stop = *on;
650aA              top = *on;
650aA           else;
650aA              //  more records exist so keep reading backwards
650aA              p +=1;
650aA              if p >= gobrik;
650aA                 stop = *on;
650aA              endif;
650aA           endif;
650aA        enddo;
650aA        if top = *on;
650aA           setll partky recordp;
650aA        endif;
650aA        FrmRollUp = *on;
650aA        exsr pag1fw;
650aA     endif;
650aA /end-free
650aAC                   endsr
650aA*----------------------------------------------------------------
650aA*  Roll down was pressed
650aA*----------------------------------------------------------------
650aA
650aAC     pag1fw        begsr
650aA /free
650aA     if not bot;
650aA        //set pointer before initialize
650aA        if not FirstPass and not FrmRollUp;
650aA           setll compky recordp;
650aA           exsr fgetn;
650aA        endif;
650aA        // initialize variables
650aA        exsr sflclr;
650aA        p = 0;
650aA        bot = *off;
650aA        top = *off;
650aA        stop = *off;
650aA     // exsr zzget1;
650aA        if FirstPass and not FrmRollUp;
650aA           setll partky recordp;
650aA           firstpass = *off;
650aA        endif;
650aA        // get 5 records to display
650aA        dou stop;
650aA           exsr fgetn;
650aA           // out of records inform user and set flag
650aA           if $portn = '*NOMORE ';
650aA                 prvkey = w1sitm2;
650aA              stop = *on;
650aA              bot = *on;
650aA              moreln = 'Bottom ';
650aA           else;
650aA              //  more records exist so keep on rolling
650aA              exsr sfladd;
650aA              p +=1;
650aA              if p >= 5;
650aA                 prvkey = w1sitm2;
650aA                 stop = *on;
650aA                 moreln = 'More...';
650aA              endif;
650aA           endif;
650aA        enddo;
650aA        dsplyd = reccnt;
650aA        exsr zzfil1;
650aA     endif;
650aA     redspl = *on;
650aA     FrmRollUp = *off;
650aA /end-free
650aAC                   endsr
650aA*----------------------------------------------------------------
650aA*  Add/Update Waste Entry array between screen movement for updates
650aA*----------------------------------------------------------------
650aA
650aAC     savWaste      begsr
650aA /free
650aA    for p = 1 to 5;
650aA       chain p detail1;
650aA       if %found;
650aA          WstPtr = %lookup(w1sitm2:#parentititem);
650aA          if wstptr > 0;
650aA             //since found from previous action update waste value
650aA             #parentwaste1(WstPtr) = w1swq1;
650aA             #parentwaste2(WstPtr) = w1swq2;
650aA             #parentwaste3(WstPtr) = w1swq3;
650aA          endif;
650aA       endif;
650aA    endfor;
650aA /end-free
650aAc                   endsr
     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
610eAC                   eval      ovrrid = *off
710aAC                   eval      ovrQty = *off

     *  Otherwise get existing record(s).

     C                   eval      w1lic = ' '
650aAc                   eval      w1lot = ' '
     C                   eval      *in91 = *on
650aAc                   eval      bot = *off
650aAc                   exsr      zzget1
650aDC*                  exsr      zzfil1
650aAc                   exsr      pag1fw

     C     end01i        endsr

     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzdft2
610dAC                   eval      ovrrid = *off
     C     end02i        endsr

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
     *  Test roll keys BEFORE verification and update.
     *
650aAc                   exsr      savWaste
650aAc     status        caseq     rollup        pag1fw
650aAc     status        caseq     rolldn        pag1bk
650aAc                   endcs
650aAc     redspl        cabeq     *on           endsc1
     *  Test for F3 - Exit

     C                   if        *inkc
     C     *loval        setll     record
650aAC     *loval        setll     recordp
     C                   exsr      zzwounstart
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
650aAC     *loval        setll     recordp
     C                   exsr      zzwounstart
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif

     *  Test for other command keys

     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Some other key pressed.

     *     Check input and write/update record.

     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     c                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr

     *----------------------------------------------------------------
     *  SC2  -  Screen 2
     *----------------------------------------------------------------

     C     sc2           begsr

     *  Test for F3 - Exit

     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif

     *  Test for other command keys

     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2

     *  Some other key pressed.

     *     Check input and write/update record.

     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
510aAC                   exsr      zzgetrepackit
650aAc                   exsr      zzLoad_Parent
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif

510cD***                 exsr      scr01i
510cD***                 if        error = *off
510cD***                 exsr      zzstart
510cD***                 endif

510cAC                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr

     *----------------------------------------------------------------
650aA*
650aA*  SFLADD   Subfile Add
650aA*
650aAc     sfladd        begsr
650aA /free
650aA   reccnt +=1;
650aA   recno = reccnt;
650aA   *in85 = *on;
650aA   w1sitm2 = kccitm;
650aA   w1sqty1 = kcqty1;
650aA   w1sqty2 = kcqty2;
650aA   w1sqty3 = kcqty3;
650aA
650aA   //  if item already exist in waste array show with value
650aA   WstPtr = %lookup(w1sitm2:#parentititem);
650aA   if wstptr > 0;
650aA      w1swq1 = #parentwaste1(WstPtr);
650aA      w1swq2 = #parentwaste2(WstPtr);
650aA      w1swq3 = #parentwaste3(WstPtr);
650aA      w1sum1 = #parentitum1(WstPtr);
650aA      w1sum2 = #parentitum2(WstPtr);
650aA      w1sum3 = #parentitum3(WstPtr);
650aA      w1swu1 = #parentitum1(WstPtr);
650aA      w1swu2 = #parentitum2(WstPtr);
650aA      w1swu3 = #parentitum3(WstPtr);
710 A      // as part of mod 7.10 I moved the in92 thru in94 compares
710 A      // down inside this if instead of above it for array ptr
710 A      // it use to compare off the kit comp quantity instead uom
650aA      // Protect waste quantities that do not apply based on parent itm
650aA      *in92 = *off;
650aA      *in93 = *off;
650aA      *in94 = *off;
710 D      // if kcqty1 <= 0;
710 A      if #parentitum1(WstPtr) = *blanks;
650aA         *in92 = *on;
650aA      endif;
710 D      // if kcqty2 <= 0;
710 A      if #parentitum2(WstPtr) = *blanks;
650aA         *in93 = *on;
650aA      endif;
710 A      // if kcqty3 <= 0;
710 A      if #parentitum3(WstPtr) = *blanks;
650aA         *in94 = *on;
650aA      endif;
650aA
650aA   else;
650aA     //this should never happen since array is loaded completely
650aA     //during startup and user cannot add or delete to sfl
650aA      w1sqty1 = 0;
650aA      w1sqty2 = 0;
650aA      w1sqty3 = 0;
650aA      w1swq1 = 0;
650aA      w1swq2 = 0;
650aA      w1swq3 = 0;
650aA      w1sum1 = ' ';
650aA      w1sum2 = ' ';
650aA      w1sum3 = ' ';
650aA      w1swu1 = ' ';
650aA      w1swu2 = ' ';
650aA      w1swu3 = ' ';
650aA   endif;
650aA
650aA   write detail1;
650aA /end-free
650aAc                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  SFLCLR   Subfile Clear
650aA*
650aAC     sflclr        begsr
650aA /free
650aA    recno = 0;
650aA    reccnt = 0;
650aA    *in81 = *off;
650aA    *in82 = *off;
650aA    *in83 = *on;
650aA    *in84 = *on;
650aA    write head1;
650aA    *in82 = *on;
650aA    *in83 = *off;
650aA   // if error = *off;
650aA   //    exsr zsclr;
650aA   // endif;
650aA /end-free
650aAc                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  SFLDSP   Display subfile
650aA*
650aAC     sfldsp        begsr
650aA*
650aA*  WRITE COMMAND LINES TO DISPLAY
650aA*
650aA /free
650aA     write cmdrec;
650aA     write morrec;
650aA     // write subfile to display
650aA     if recno > 0;
650aA        exsr sflprc;
650aA        *in81 = *on;
650aA     endif;
650aA     write head1;
650aA /end-free
650aAC                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  SFLPRC   Process entries into sub file
650aA*
650aAC     sflprc        begsr
650aA /free
650aA /end-free
650aAc                   endsr
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10

     *  Initialize special keys

650aDC*                  eval      enter = 0
650aDC*                  eval      comand = 2
650aDC*                  eval      rollup = 01122
650aDC*                  eval      rolldn = 01123
650aDC*                  eval      clear = 01124
650aDC*                  eval      help = 01125

530aAC                   move      *year         TodayYear
530aAC                   move      *month        TodayMonth
530aAC                   move      *day          TodayDay

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
650aDC*                  eval      #pgmq = #pgm
650aAC                   eval      #pgmq = #prog
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

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
650aAc     *loval        setll     recordp
     C                   eval      sclear = *on
650aAc                   eval      bot = *off
650aAc                   eval      top = *off
650aAc                   eval      FirstPass = *on
650aAc                   eval      FrmRollUp = *off
650aA /free
650aA                    %subarr(arySFL:1:%elem(arySFL)) = *loval;
650aA /end-free
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
     *---------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *---------------------------------------------------------------

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

     *---------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *---------------------------------------------------------------

     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
610fA*----------------------------------------------------------------
610fA*    PO20034  License already exists.
610fA*
610fAC     zm034         begsr
610fAC                   eval      #msgid = 'PO20034'
610fAC                   eval      #msgtp = '*DIAG  '
610fAC                   eval      $md = *blanks
610fAC                   exsr      zmpmsg
610fAC                   endsr

510aA*---------------------------------------------------------------
510aA*   PIR0143  Item entered must be Repack Item Type 'R'
510aA*---------------------------------------------------------------
510aA
510aAC     zm0120        begsr
510aAC                   eval      #msgid = 'PIR0143'
510aAC                   eval      #msgtp = '*DIAG  '
510aAC                   movea     errmsg        $md(1)
510aAC                   exsr      zmpmsg
510aAC                   endsr
510aA
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *---------------------------------------------------------------

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
     *   PIR0105  Generic message.
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
     *     PIR0110  Number must be greater than zero
     *----------------------------------------------------------------

     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

510aA*----------------------------------------------------------------
510aA*   PIR1007  Invalid Date entered.
510aA*----------------------------------------------------------------
510aA
510aAC     zm1007        begsr
510aAC                   eval      #msgid = 'PIR1007'
510aAC                   eval      #msgtp = '*DIAG  '
510aAC                   eval      $md = *blanks
510aAC                   exsr      zmpmsg
510aAC                   endsr

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
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  ZZ Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

650iA*----------------------------------------------------------------
650iA*  ZZADJQTY Adjust parent quantity required per the output
650iA*           factor configured in KITITEM as part of Repack Itm
650iA*----------------------------------------------------------------
650iA
650iAC     zzadjqty      begsr
650iA /free
650iA
650iA    $saqty1 = 0;
650iA    $saqty2 = 0;
650iA    $saqty3 = 0;
650iA
650iA  // Each quantity will be reviewed.  The total quantity requested
650iA  // will be divided by the output quantity defined in item maint.
650iA  // This value is found in KITITEM.  If that value exceeds 1 then
650iA  // the user is saying this repack configuration makes for than
650iA  // one of these items.  Therefore, if the user requested 10 and
650iA  // the components say they make 2 then we would divide the 10
650iA  // by 2 to get 5.  5 times the component list is what would be
650iA  // consumed to make these 10 pieces. The remainder is placed in
650iA  // the breakdown quantity below that level
650iA
650iA     // determine lowest level defined in item maintenance
650iA     select;
650iA        when #parentitumq3(wstPtr)<>0;
650iA           wopqndec = (wrkqty1 * #parentitumq2(wstPtr)
650iA                         * #parentitumq3(wstPtr)) +
650iA                      (wrkqty2 * #parentitumq3(wstPtr)) +
650iA                       wrkqty3;
650iA           wopqndec = (wopqndec / #repackoutqty);
650iA  // if it is decided later to enforce zero decimals between
650iA  // output quantity in kititem and parent quantity in kitcomp
650iA  // just take out the adding 1 if dec>0.  You will also need
650iA  // to make changes marked in IT116
650iA          if dec>0;
650iA             $saqty3 = wopqndec +1;
650iA          else;
650iA             $saqty3 = wopqndec;
650iA          endif;
650iA           $saqty1 = 0;
650iA           $saqty2 = 0;
650iA
650iA        when #parentitumq2(wstPtr)<>0;
650iA           wopqndec = (wrkqty1 * #parentitumq2(wstPtr)) +
650iA                       wrkqty2;
650iA           wopqndec = (wopqndec / #repackoutqty);
650iA  // if it is decided later to enforce zero decimals between
650iA  // output quantity in kititem and parent quantity in kitcomp
650iA  // just take out the adding 1 if dec>0.  You will also need
650iA  // to make changes marked in IT116
650iA          if dec>0;
650iA             $saqty2 = wopqndec + 1;
650iA          else;
650iA             $saqty2 = wopqndec;
650iA          endif;
650iA           $saqty1 = 0;
650iA           $saqty3 = 0;
650iA
650iA        other;
650iA           wopqndec = (wrkqty1 / #repackoutqty);
650iA  // if it is decided later to enforce zero decimals between
650iA  // output quantity in kititem and parent quantity in kitcomp
650iA  // just take out the adding 1 if dec>0.  You will also need
650iA  // to make changes marked in IT116
650iA          if dec>0;
650iA             $saqty1 = wopqndec + 1;
650iA          else;
650iA             $saqty1 = wopqndec;
650iA          endif;
650iA           $saqty2 = 0;
650iA           $saqty3 = 0;
650iA
650iA     endsl;
650iA
650iA     // save for later use if replenishment is required
650iA     adjQty1 = $saqty1;
650iA     adjQty2 = $saqty2;
650iA     adjQty3 = $saqty3;
650iA
650iA /end-free
650iAc                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr

650aA *   confirm subfile entry
650aAc                   eval      subRec = 1
650aAc     subRec        chain     detail1                            79
650aAc                   dow       *in79 = *off

650aA *  get pointer for this parent ite data
650aA /free
650aA   WstPtr = %lookup(w1sitm2:#parentititem);
650aA   if wstPtr = 0;
650aA     // this should never happen since complete kitcomp data is
650aA     // loaded at the start of screen.  Just in case this error
650aA     // will be thrown and highlight parent line in issue.
650aA      *in21 = *on;
650aA      *in85 = *on;
650aA      error = *on;
650aA      errmsg = 'Parent item not found';
650aA      exsr zm0105;
650aA      update detail1;
650aA   endif;
650aA /end-free
     C                   eval      error = *off
     C                   eval      $prtn = *blanks

650cA** Verify quantity build does not exceed system limitation of 999

650cAC**                 select
650cAC**                 when      w1sqty1 > 0
650cAC**                 eval      w1limit = w1made * w1sqty1
650cAC**                 when      w1sqty2 > 0
650cAC**                 eval      w1limit = w1made * w1sqty2
650cAC**                 when      w1sqty3 > 0
650cAC**                 eval      w1limit = w1made * w1sqty3
650cAC**                 other
650cAC**                 eval      w1limit = *zeros
650cAC**                 endsl

650cAC**                 if        w1limit > 999
650cAC**                 move      '1'           error
650cAC**                 eval      *in21 = *on
650cAC**                 eval      *in85 = *on
650cAC**                 eval      errmsg = 'Qty made > 999 eaches limit.  Buil-
650cAC**                           d in 2 phases.'
650cAC**                 exsr      zm0105
650cAc**                 update    detail1
650cAC**                 goto      endck1
650cAc**
650cAC**                 endif

     *  Verify Parent adjustment.

610eAC                   if        ovrrid = *off
710aAC                             and ovrQty = *off
     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
650aAC                   eval      $slwhse   = #parentslwhse(wstPtr)
     C                   eval      $slwhdpu  = *on
650aAC                   eval      $slwhdp   = #parentslwhdp(wstPtr)
     C                   eval      $sldispu  = *on
650aAC                   eval      $sldisp   = #parentsldisp(wstPtr)
650aAC                   eval      $saitemu  = *on
650aAC                   eval      $saitem   = #parentslitem(wstPtr)
     C                   eval      $sacodeu  = *on
     C                   eval      $sacode   = oppadj
     C                   eval      $saqtyu   = *on
650cDC**                 eval      $saqty1   = -(w1made * w1sqty1)
650cDC**                 eval      $saqty2   = -(w1made * w1sqty2)
650cDC**                 eval      $saqty3   = -(w1made * w1sqty3)

650iAc                   if        #repackoutqty > 1
650iMC                   eval      $saqty1   = w1made * w1sqty1
650iMC                   eval      $saqty2   = w1made * w1sqty2
650iMC                   eval      $saqty3   = w1made * w1sqty3
650cA*  consider waste in total to ensure enough stock pulled
650cAc                   eval      $saqty1 += w1swq1
650cAc                   eval      $saqty2 += w1swq2
650cAc                   eval      $saqty3 += w1swq3
650iAc                   exsr      zzUpqty
650iAc                   eval      wrkQty1 = $saqty1
650iAc                   eval      wrkQty2 = $saqty2
650iAc                   eval      wrkQty3 = $saqty3
650iAc                   exsr      zzadjQty
650iAc                   else
650cMC                   eval      $saqty1   = w1made * w1sqty1
650cMC                   eval      $saqty2   = w1made * w1sqty2
650cMC                   eval      $saqty3   = w1made * w1sqty3
650cA*  consider waste in total to ensure enough stock pulled
650cAc                   eval      $saqty1 += w1swq1
650cAc                   eval      $saqty2 += w1swq2
650cAc                   eval      $saqty3 += w1swq3
650iAc                   endif

650cMC                   exsr      zzupqty
650cAc                   eval      adjQty1 = $saqty1
650cAc                   eval      adjQty2 = $saqty2
650cAc                   eval      adjQty3 = $saqty3
650cMC                   eval      $saqty1 *= -1
650cMC                   eval      $saqty2 *= -1
650cMC                   eval      $saqty3 *= -1

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFY'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
650aAc                   eval      *in21 = *on
650aAc                   eval      *in85 = *on
     C                   eval      error = *on
650iAC                   eval      $drimessage = 'Parent-Waste: '
650iAC                                + $drimessage
710aAc*  If Negative Slot Available Message allow override
710aAc                   if        $drireturn='NEGAVLSLT'
710aAc                   eval      $drimessage = 'Output qty made drives' +
710aAc                              ' Repck Slt negative - F20 to Proceed'
710aAc                   endif
     C                   exsr      zm0001
650aAc                   update    detail1
     C                   goto      endck1
     C                   endif
610eAC                   endif

     *  Verify Parent Waste adjustment.

650cDC*                  if         (w1swq1+w1swq2+w1swq3) > 0

650cDC*                  exsr      clr$slot
650cDC*                  eval      $slwhseu  = *on
650cDC*                  eval      $slwhse   = #parentslwhse(wstPtr)
650cDC*                  eval      $slwhdpu  = *on
650cDC*                  eval      $slwhdp   = #parentslwhdp(wstPtr)
650cDC*                  eval      $sldispu  = *on
650cDC*                  eval      $sldisp   = #parentsldisp(wstPtr)
650cDC*                  eval      $saitemu  = *on
650cDC*                  eval      $saitem   = #parentslitem(wstPtr)
650cDC*                  eval      $sacodeu  = *on
650cDC*                  eval      $sacode   = opwadj
650cDC*                  eval      $saqtyu   = *on
650iDC*                  select
650iDC*                  when      w1sqty1 > 0
650cDC**                 eval      $saqty1   = -(w1swq1)
650cDC*                  eval      $saqty1   = w1swq1
650cDC*                  when      w1sqty2 > 0
650cDC**                 eval      $saqty2   = -(w1swq2)
650cDC*                  eval      $saqty2   = w1swq2
650cDC*                  when      w1sqty3 > 0
650cDC**                 eval      $saqty3   = -(w1swq3)
650cDC*                  eval      $saqty3   = w1swq3
650cDC*                  endsl
650cDC*                  exsr      zzupqty
650cDC*                  eval      $saqty1 *= -1
650cDC*                  eval      $saqty2 *= -1
650cDC*                  eval      $saqty3 *= -1

650cDC*                  eval      $dricommand = '*SLOT'
650cDC*                  eval      $drisubcmd  = '%VERIFY'
650cDC*                  eval      $drisys2upd = 'D'
650cDC*                  eval      chk4err = *on
650cDC*                  eval      zmsflag = *off
650cDC*                  exsr      zzzdricop
650cDC*                  if        drierr
650cDC*                  eval      error = *on
650cDc*                  eval      *in21 = *on
650cDc*                  eval      *in85 = *on
650cDc*                  update    detail1
650cDC*                  eval      $drimessage = 'Waste: ' + $drimessage
650cDC*                  exsr      zm0001
650cDC*                  goto      endck1
650cDC*                  endif

650cDC*                  endif

     *  Verify Repack adjustment.

530 D ***                exsr      clr$slot
530 D ***                eval      $slwhseu  = *on
530 D ***                eval      $slwhse   = #repackslwhse
530 D ***                eval      $slwhdpu  = *on
530 D ***                eval      $slwhdp   = #repackslwhdp
530 D ***                eval      $sldispu  = *on
530 D ***                eval      $sldisp   = #repacksldisp
530 D ***                eval      $saitemu  = *on
530 D ***                eval      $saitem   = #repackslitem
530 D ***                eval      $sacodeu  = *on
530 D ***                eval      $sacode   = opradj
530 D ***                eval      $saqtyu   = *on
530 D ***                eval      $saqty1   = w1made
530 D ***                eval      $saqty2   = 0
530 D ***                eval      $saqty3   = 0

530 D ***                eval      $dricommand = '*SLOT'
530 D ***                eval      $drisubcmd  = '%VERIFY'
530 D ***                eval      $drisys2upd = 'D'
530 D ***                eval      chk4err = *on
530 D ***                eval      zmsflag = *off
530 D ***                exsr      zzzdricop
530 D ***                if        drierr
530 D ***                eval      error = *on
530 D ***                eval      $drimessage = 'Repack: ' + $drimessage
530 D ***                exsr      zm0001
530 D ***                goto      endck1
530 D ***                endif
650aAc                   eval      subRec = subRec + 1
650aAc     subRec        chain     detail1                            79
650aAc                   enddo

650aA*  Date sensative items require expiration date
650aA*   at Repack Item level.  Therefore 1 entry in ary will suffice

650aAC                   if        #repackitflgd = 'Y'
650aAC                             and w2edt = *zeros
650aAC                   move      '1'           error
650aAC                   eval      *in25 = *on
650aDC*                  eval      *in01 = *on
650aAC                   eval      errmsg = 'Expiration Date required for date -
650aAC                             sensative items.'
650aAC                   exsr      zm0105
650aAC                   goto      endck1
650aAC                   endif
650aA
650aA*  Verify entered date
650aA
650aAC                   if        w2edt > *zeros
650aAC                   eval      $cvcmd = '*MDYEDT '
650aAC                   move      w2edt         $cvd6i
650aAC                   eval      $cvprg = #prog
650aAC                   call      @cvtdt
650aAC                   parm                    $cvtdt
650aAC                   if        $cvrtn = '*PGMQ   '
650aAC                   move      '1'           error
650aDC*                  eval      *in24 = *on
650aDC*                  eval      *in24 = *on
650aDC*                  eval      *in01 = *on
650aDC*                  eval      *in01 = *on
650aAc                   eval      *in25 = *on
650aAC                   eval      errmsg = 'Date'
650aAC                   eval      #msgk = $cvmsg
650aAC                   exsr      zm1007
650aAC                   goto      endck1
650aAC                   endif
650aAC                   endif

510a *   License must be entered.

510a C                   if        w1lic = *blanks
510a C                   eval      error = *on
510a C                   eval      *in23 = *on
510a C                   eval      *in01 = *on
510a C                   eval      errmsg = 'Lic '
510a C                   exsr      zm01
510a C                   endif
610fA*
610fA*  Left justify license.
610fA*
610fAC                   eval      $cstr = *blanks
610fAC                   move      w1lic         $cstr
610fAC                   call      'ADJUST'
610fMC                   parm      '*LEFTNOZ'    $ccmd
610fAC                   parm                    $cstr
610fAC                   movel     $cstr         w1lic
610fA*
610fA*  License # must be unique.
610fA*
610fAC                   if        w1lic <> *blanks
610fAC     filek2        setll     license                                79
610fAC                   if        *in79
610fAC                   eval      error = *on
610fAC                   eval      *in23 = *on
610fAC                   eval      *in01 = *on
610fAC                   exsr      zm034
610fAC                   endif
610fAC                   endif
650iD*  Date sensative items require expiration date
650iD
650iDC*                  if        #repackitflgd = 'Y'
650iDC*                            and w2edt = *zeros
650iDC*                  move      '1'           error
650iDC*                  eval      *in24 = *on
650iDC*                  eval      *in01 = *on
650iDC*                  eval      errmsg = 'Expiration Date required for date -
650iDC*                            sensative items.'
650iDC*                  exsr      zm0105
650iDC*                  goto      endck1
650iDC*                  endif

650iD*  Verify entered date
650iD *
650iDC*                  if        w2edt > *zeros
650iDC*                  eval      $cvcmd = '*MDYEDT '
650iDC*                  move      w2edt         $cvd6i
650iDC*                  eval      $cvprg = #pgm
650iDC*                  call      @cvtdt
650iDC*                  parm                    $cvtdt
650iDC*                  if        $cvrtn = '*PGMQ   '
650iDC*                  move      '1'           error
650iDC*                  eval      *in24 = *on
650iDC*                  eval      *in01 = *on
650iDC*                  eval      errmsg = 'Date'
650iDC*                  eval      #msgk = $cvmsg
650iDC*                  exsr      zm1007
650iDC*                  goto      endck1
650iDC*                  endif
650iDC*                  endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
650aAc                   eval      reccnt = 0
     C                   eval      error = *off
     C                   eval      $prtn = *blanks

     *   Item must be entered.

     C                   if        w2item = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Item'
     C                   exsr      zm01
     C                   endif

510aA*   Item entered must be Repack Type Item.
510aA
510aAC                   if        w2item <> *blanks
510aAC                             and #repackittype <> 'R'
510aAC                   eval      error = *on
510aAC                   eval      *in21 = *on
510aAC                   eval      *in01 = *on
510aAC                   eval      errmsg = 'Item'
510aAC                   exsr      zm0120
510aAC                   endif

     *   Quantity must be greater than zero.

     C                   if        w2qty <= 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Quantity'
     C                   exsr      zm0110
     C                   endif

510aA*   Date Needed By must be entered.
510aA
510aAC                   if        w2ndt = *zeros
510aAC                   eval      error = *on
510aAC                   eval      *in23 = *on
510aAC                   eval      *in01 = *on
510aAC                   eval      errmsg = 'Date'
510aAC                   exsr      zm01
510aAC                   endif

510aA*  Verify entered date
510aA
510aAC                   if        w2ndt > *zeros
510aAC                   eval      $cvcmd = '*MDYEDT '
510aAC                   move      w2ndt         $cvd6i
650aDC*                  eval      $cvprg = #pgm
650aAC                   eval      $cvprg = #prog
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   if        $cvrtn = '*PGMQ   '
510aAC                   move      '1'           error
510aAC                   eval      *in23 = *on
510aAC                   eval      *in01 = *on
510aAC                   eval      errmsg = 'Date'
510aAC                   eval      #msgk = $cvmsg
510aAC                   exsr      zm1007
510aAC                   goto      endck2
510aAC                   else
510aAC                   eval      w2ndt  = $cvd6o
510aAC                   eval      $cvcmd = '*MDYCMD '
510aAC                   move      w2ndt         $cvd6i
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   eval      w2ndtc  = $cvd8o
510aAC                   endif
510aAC                   endif

530aA*  Verify parent item has breakdown 1 quantity.
530aA*  Get Kit Component information.

530aAC                   if        error <> '1'
650aAC                   eval      reccnt = 0
530aAC     keykc2        setll     kitcomp
530aAC     keykc2        reade(e)  kitcomp
650aAc                   dow       %equal and not %eof
530aAC                   eval      kohwhs = $pwhse
650aA /free
650aA                    WstPtr = %lookup(kccitm:#parentititem);
650aA  //should never happen, but just in case to prevent hard error
650aA                    if WstPtr = 0;
650aA                       wstPtr = 1;
650aA                    endif;
650aA /end-free
740 Ac                   if        #parentitumq2(wstPtr)=*zeros
740 Ac                             and kcqty1>0
740 Ac                   eval      #parentitumq2(wstPtr)=1
740 Ac                   endif
650aAC                   if        #parentitumq2(wstPtr) <= *zeros
650fAC                              and #parentittype(wstPtr)<>'R'
530aAC                   eval      error = *on
530aAC                   eval      *in21 = *on
530aAC                   eval      *in01 = *on
530aAC                   eval      errmsg = 'Breakdown Quantity'
530aAC                   exsr      zm0110
650aAC                   leave
530aAC                   endif
650aDC*                  endif
650dDC*                  endif
610dA*  Get Parent Item information.

650aDC*                  if        error <> '1'
650aDC*                  if        error <> '1'
650dDC*                  if        #parentiqavl1(wstPtr) = 0
650dDC*                            and #parentiqavl2(wstPtr) = 0
650fAc                   select
650fAc                   when      #parentitumq2(wstPtr) > 0
740 DC*                  if        ((#parentiqavl1(wstPtr) *
740 MC                   if        (((#parentiqavl1(wstPtr)+
740 Ac                                  #parentslstk1(wstPtr))
650dAC                                * #parentitumq2(wstPtr))
650dAC                              + #parentiqavl2(wstPtr))< ((kcqty2*w2qty)
650dAc                              + kcqty1 * #parentitumq2(wstPtr))
610dAC                   if        ovrrid = *off
610dAC                   eval      error = *on
650dDC*                  eval      errmsg = 'Parent has no avail qty. No Repl w-
650dDC*                            ill be created.'
650dMC                   eval      errmsg = 'Parent is short of required qty. F-
650dMC                             20 to create.'
610cAC                   exsr      zm0105
610cAC                   leave
650cDc*                  else
650cDc*                  eval      bypassrepl = *on
650aAC                   endif
650aAC                   endif
650fAc                   when      #parentitumq2(wstPtr) = 0
740 DC*                  if        #parentiqavl1(wstPtr) <
740 MC                   if        (#parentiqavl1(wstPtr) +
740 Ac                              #parentslstk1(wstPtr))
650fAC                                < w2qty
650cAC                   if        ovrrid = *off
650cAC                   eval      error = *on
650fMC                   eval      errmsg = 'Parent is short of required qty. F-
650fMC                             20 to create.'
650fAC                   exsr      zm0105
650fAC                   leave
650fAC                   endif
650fAC                   endif
650fAc                   endsl
650aAC     keykc2        reade(e)  kitcomp
650aAC                   enddo
650fAC     *loval        setll     kitcomp
610dAC                   endif

     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Test for F8 - View parent quantities

650aA *  have to change calls to works with long parms.
650aA *  kde 02/26/2013
650aA *  remakr out for now
650aDC*                  if        *inkh
650aDC*                  eval      cmdtkn = *on
650aDC*                  call      'IT810'
650aDC*                  parm      #parentitwhse $iwhse            3 0
650aDC*                  parm                    #parentititem
650aDC*                  endif

650aD*  Test for F9 - zzupd1epack quantities

650aDC*                  if        *inki
650aDC*                  eval      cmdtkn = *on
650aDC*                  call      'IT810'
650aDC*                  parm      #repackitwhse $iwhse            3 0
650aDC*                  parm                    #repackititem
650aDC*                  endif
610eA*
610eA*      F20 - Accept Warning.
610eA*
610eAC                   if        *inku
610eAC                   eval      ovrrid = *on
710aAC                   eval      ovrQty = *on
610eAC                   else
610eAC                   eval      ovrrid = *off
710aAC                   eval      ovrQty = *off
610eAC                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
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

     *     Item.

     C                   when      row# = 8
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
650aDC*                  eval      $lprg = #pgm
650aAC                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = ' '
     C                   call      'IT920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w2item = $litem
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
goto C                   goto      endcm2
     C                   endif
610dA*
610dA*      F20 - Accept Warning.
610dA*
610dAC                   if        *inku
610dAC                   eval      ovrrid = *on
610dAC                   else
610dAC                   eval      ovrrid = *off
610dAC                   endif

     C     endcm2        endsr

510bA*----------------------------------------------------------------
510bA*  ZZ$RTTRAN     Create putaway transaction
510bA*----------------------------------------------------------------

510bAC     zzcrttran     begsr

     *  Get batch number for labels.

530 D ***                call      'PIRBAT#'
530 D ***                parm      *zeros        $pbat

     *  Get transaction number.

530 D ***                call      'PIRTRN#'
530 D ***                parm                    pttrn#

     *  Create label record for Normal qty.

530 D ***                clear                   lbrec
530 D ***                eval      lbwhse = $pwhse
530 D ***                eval      lbwhdp = #repackitwhdp
530 D ***                eval      lbaisl = *blanks
530 D ***                eval      lbloc = *zeros
530 D ***                eval      lbrlvl = *zeros
530 D ***                eval      lbhand = *blanks
530 D ***                eval      lbpseq = *zeros
530 D ***                eval      lbstyp = *blanks
530 D ***                eval      lbqryf = *zeros
530 D ***                eval      lbdisp = *blanks
530 D ***                movel     '*MANUAL'     lbdsp2
530 D ***                eval      lbitem = #repackititem
530 D ***                eval      lbseq = *zeros
530 D ***                eval      lbpbat = $pbat
530 D ***                eval      lbpo = *blanks
530 D ***                eval      lbord = $pord
530 D ***                eval      lbqalc = w1made
530 D ***                eval      lbqpck = w1made
530 D ***                eval      lbtie = *zeros
530 D ***                eval      lbhigh = *zeros

     *  Create label record for Normal qty.

530 D ***                eval      lbutyp = 'N'
530 D ***                eval      lbucod = #repackitum1
530 D ***                eval      lbucub = #repackitcube
530 D ***  lbucub        mult      w1made        lbcube
530 D ***                eval      lbuwgt = #repackitswgt
530 D ***  lbuwgt        mult      w1made        lbswgt
     *
530 D ***                eval      lbtrn# = pttrn#
530 D ***                call      'PIRLBL#'
530 D ***                parm                    lblbl#
530 D ***                eval      lbgrp1 = 'K'
530 D ***                eval      lbgrp2 = *blanks
530 D ***                eval      lbtype = 'P'
530 D ***                eval      lbstat = 'P'

     *  Get live status for item's department.

530 D ***                call      'CHKLIVE'
530 D ***                parm                    #repackitwhdp
530 D ***                parm                    livestat

     *    If dept not live, then set status to Closed.

530 D ***                if        livestat = '*NOTLIVE'
530 D ***                eval      lbstat = 'C'
530 D ***                endif

530 D ***                eval      lbsdte = curdate
530 D ***                time                    lbstim
530 D ***                eval      lbrdte = curdate
530 D ***                if        w1xdk = 'Y'
530 D ***                eval      lbaisl = #repackslaisl
530 D ***                eval      lbloc = #repackslloc
530 D ***                eval      lbrlvl = #repackslrlvl
530 D ***                eval      lbhand = #repackslhand
530 D ***                eval      lbpseq = #repackslpseq
530 D ***                eval      lbstyp = #repackslstyp
530 D ***                eval      lbdisp = #repacksldisp
530 D ***                eval      lbdsp2 = *blanks
530 D ***                eval      lbasl2 = 'XDK'
530 D ***                endif
530 D ***                write     lbrec
     *
     *        Create transaction record.
     *
     C                   eval      @pwhdp = #repackslwhdp
     C                   eval      @pstyp = #repackslstyp
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm      'PUTEMP'      @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm                    @pwhdp
     C                   parm                    @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'K'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg

     *  Create license record.

     C                   if        w1xdk <> 'Y'
     C     filek2        chain     license                            7978
     *
     C                   eval      liwhse = $pwhse
     C                   eval      lilcns = w1lic
     C                   eval      litrn# = pttrn#
     *     Record not found. Try adding record.
     *
     C                   if        *in79
     C                   write     lirec                                76
     C                   endif
     C                   endif
     *
530 D*  Add license to license history.

530 D ***                exsr      clr$lichist
530 D ***                eval      $lrlcnsu = *on
530 D ***                eval      $lrlcns  = w1lic
530 D ***                eval      $lrtrn#u = *on
530 D ***                eval      $lrtrn#  = pttrn#
530 D ***                eval      $lrlbl#u = *on
530 D ***                eval      $lrlbl#  = lblbl#
530 D ***                select
530 D ***                when      w1umt = '1'
530 D ***                eval      $lrlqy2u = *on
530 D ***                eval      $lrlqy2  = w1made
530 D ***                when      w1umt = '2'
530 D ***                eval      $lrlqy3u = *on
530 D ***                eval      $lrlqy3  = w1made
530 D ***                other
530 D ***                eval      $lrlqy1u = *on
530 D ***                eval      $lrlqy1  = w1made
530 D ***                endsl
530 D ***                eval      $lrfcodu = *on
530 D ***                eval      $lrfcod  = 'R'
530 D ***                eval      $lrfarau = *on
530 D ***                eval      $lrfara  = 'Receiving'
530 D ***                eval      $lrfitmu = *on
530 D ***                eval      $lrfitm  = #repackititem
530 D ***                eval      $lrfitypu = *on
530 D ***                eval      $lrfityp = #repackittype
530 D ***                eval      $lrtcodu = *on
530 D ***                eval      $lrtcod  = 'D'
530 D ***                eval      $lrtarau = *on
530 D ***                eval      $lrtara  = 'Dock'
530 D ***                eval      $lrtitmu = *on
530 D ***                eval      $lrtitm  = #repackslitem
530 D ***                eval      $lrtitypu = *on
530 D ***                eval      $lrtityp = #repackslstyp
530 D ***
530 D***   If department is not live, then override some values.

530 D ***                if        livestat = '*NOTLIVE'
530 D ***                eval      $lrlcns = '*PO'
530 D ***                eval      $lrtcod = 'X'
530 D ***                eval      $lrtwhd = #repackitwhdp
530 D ***                eval      $lrtara = 'Dept Not Live'
530 D ***                endif

530 D ***                eval      $dricommand = '*LICHIST'
530 D ***                eval      $drisubcmd  = '%ADDLIC'
530 D ***                eval      $drisys2upd = 'D'
530 D ***                exsr      zzzdricop
530 D ***                if        error
530 D ***                endif

530 D ***                if        livestat = '*NOTLIVE'
530 D ***                eval      w1lic = $lrlcns
530 D ***                endif

530 A*    Update licinfo.

530 AC                   exsr      zzlicinfo

     C     endcrttran    endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZDFT2   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft2        begsr
     C                   eval      w2item = ' '
     C                   eval      w2qty  = 0
     C                   eval      w2ref  = ' '
530aAC                   move      today         mdy
530aAC                   move      mdy           w2ndt
530aD ***                eval      w2ndt  = 0
     C                   endsr
     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

650aDC*                  eval      woword = kohord
650aDC*                  eval      wopitm = #parentithead
650aDC*                  eval      wopdsp = #parentsldisp
650aDC*                  eval      woritm = #repackithead
650aDC*
650aDC*                  eval      wouom  = '  '
650aDC*                  select
650aDC*                  when      kcqty1 > 0
650aDC*                  eval      wouom  = '* No Breakdown Needed *'
650aDC*                  when      kcqty2 > 0
650aDC*                  if        #parentitumq2 > 0
650aDC*                  eval      wouom  = %trim(%editc(#parentitumq2:'P'))
650aDc*                                   + ' '
650aDC*                                   + #parentitum2 + ' / ' + #parentitum1
650aDC*                  endif
650aDC*                  when      kcqty3 > 0
650aDC*                  if        #parentitumq3 > 0
650aDC*                  eval      total = #parentitumq3 * #parentitumq2
650aDC*                  eval      wouom  = %trim(%editc(total:'P'))
650aDC*                                   + ' '
650aDC*                                   + #parentitum3 + ' / ' + #parentitum1
650aDC*                  endif
650aDC*                  endsl

650aDC*                  if        wouom  = ' '
650aDC*                  eval      wouom  = '* Not Defined *'
650aDC*                  endif

650aDC*                  eval      woratio = ' '
650aDC*                  select
650aDC*                  when      kcqty1 > 0
650aDC*                  eval      wopqn   = kcqty1
650aDC*                  eval      wopqnu  = #parentitum1
650aDC*                  eval      woratio = %trim(%editc(kcqty1:'P'))
650aDC*                                   + ' '
650aDC*                                   + #parentitum1
650aDC*                  when      kcqty2 > 0
650aDC*                  eval(h)   wopqndec= (kohqty * kcqty2)
650aDC*                                      / #parentitumq2
650aDC*                  eval      wopqn = wopqndec
650aDC*                  if        dec >= 01
650aDC*                  eval      wopqn   = wopqn + 1
650aDC*                  endif
650aDC*                  eval      wopqnu  = #parentitum1
650aDC*                  eval      woratio = %trim(%editc(kcqty2:'P'))
650aDC*                                   + ' '
650aDC*                                   + #parentitum2
650aDC*                  when      kcqty3 > 0
650aDC*                  eval(h)   wopqndec= (kohqty * kcqty3)
650aDC*                                      / (#parentitumq2
650aDC*                                          * #parentitumq3)
650aDC*                  eval      wopqn = wopqndec
650aDC*                  if        dec >= 01
650aDC*                  eval      wopqn   = wopqn + 1
650aDC*                  endif
650aDC*                  eval      wopqnu  = #parentitum1
650aDC*                  eval      woratio = %trim(%editc(kcqty3:'P'))
650aDC*                                   + ' '
650aDC*                                   + #parentitum3
650aDC*                  endsl
650aDC*                  eval      woratio = %trim(woratio)
650aDC*                                    + ' to 1 Repack'
650aD
650aDC*                  eval      worqn   = kohqty
650aDC*                  eval      w1made  = 0
650aDC*                  eval      woruom  = #repackitum1

650aDC*                  eval      w1waste = 0

650aDC*                  select
650aDC*                  when      kcqty1 > 0
650aDC*                  eval      wowuom  = #parentitum1
650aDC*                  when      kcqty2 > 0
650aDC*                  eval      wowuom  = #parentitum2
650aDC*                  when      kcqty3 > 0
650aDC*                  eval      wowuom  = #parentitum3
650aDC*                  endsl

650aDC*                  eval      w1lic   = ' '
510aA * Read Order Detail file to see how many repack items previously
510aA * made.
510aAC                   eval      worqp = 0
510aAC     fileky        setll     kitordd
510aAC     fileky        reade     kitordd
510aAC                   dow       not %eof
510aAC                   eval      worqp = worqp + kodqty
510aAC     fileky        reade     kitordd
650aAc                   enddo

650aDC*                  eval      w2edt = *zeros
650aDC*                  if        #parentslexpd > *zeros
650aDC*    *iso          move      #parentslexpd iso
650aDC*                  move      iso           mdy
650aDC*                  move      mdy           w2edt
650aDC*                  endif

610gAC                   eval      *in70 = *off
610gAC                   if        #repackitflgd = 'N'
610gAC                   eval      *in70 = *on
610gAC                   endif

650hAc     keykc2        chain     itemmsc                            95
650hAc                   if        *in95 = *off
650hAc                   if        imlot = 'N'
650hAc                   eval      *in95 = *on
650hAc                   endif
650hAc                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get record from main file.

     C     fileky        chain     record                             7978

     *  Record locked.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif

     *  Record not found.

     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif

     *   If viewing, release record.

     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif

     *  Get Kit Component information.
      *  move to zzfil1 for sub file processing and multiple records

650aD ***  keykc         setll     kitcomp
650aD ***  keykc         reade(e)  kitcomp
650aD ***                if        %eof
650aD ***                endif

     *  Get Repack Item information.

650aAc                   exsr      zzgetrepackit
650 D *                  exsr      zzgetrepacksl

     *  Get Parent Item information.

650aAc                   exsr      zzLoad_Parent
650aD ***                exsr      zzgetparentit
650aD ***                exsr      zzgetparentiq
650aD ***                exsr      zzgetparentsl

     C     endgt1        endsr

     *----------------------------------------------------------------
     *  zzgetdatetime  Get current date & time
     *----------------------------------------------------------------
     *
     C     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETPARENTIT   Get Parent item
     *----------------------------------------------------------------

     C     zzgetparentit begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = kohwhs
     C                   eval      $ititem  = kccitm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetparenti
     C                   endif

650aDC*                  eval      #parentitwhse = $itwhse
650aDC*                  eval      #parentititem = $ititem
650aDC*                  eval      #parentittype = $ittype
650aDC*                  eval      #parentitdesc = $itdesc
650aDC*                  eval      #parentitpdsc = $itpdsc
650aDC*                  eval      #parentitwhdp = $itwhdp
650aDC*                  eval      #parentitstyp = $itstyp
650aDC*                  eval      #parentitdesg = $itdesg
650aDC*                  eval      #parentitum1  = $itum1
650aDC*                  eval      #parentitflg1 = $itflg1
650aDC*                  eval      #parentitum2  = $itum2
650aDC*                  eval      #parentitumq2 = $itumq2
650aDC*                  eval      #parentitflg2 = $itflg2
650aDC*                  eval      #parentitum3  = $itum3
650aDC*                  eval      #parentitumq3 = $itumq3
650aDC*                  eval      #parentitnrpk = $imnrpk
650aDC*                  eval      #parentitflgd = $itflgd
650aDC*                  eval      #parentitcube = $itcube
650aDC*                  eval      #parentitswgt = $itswgt
650aDC*                  eval      #parentitcwgt = $itcwgt
650aDC*                  eval      #parentitmitem = $itmitem
650aDC*                  eval      #parentitsdef = ' '
650aDC*                  eval      #parentittie  = 0
650aDC*                  eval      #parentithigh = 0

650aAC                   eval      #parentitwhse(savNxt) = $itwhse
650aAC                   eval      #parentititem(savNxt) = $ititem
650aAC                   eval      #parentittype(savNxt) = $ittype
650aAC                   eval      #parentitdesc(savNxt) = $itdesc
650aAC                   eval      #parentitpdsc(savNxt) = $itpdsc
650aAC                   eval      #parentitwhdp(savNxt) = $itwhdp
650aAC                   eval      #parentitstyp(savNxt) = $itstyp
650aAC                   eval      #parentitdesg(savNxt) = $itdesg
650aAC                   eval      #parentitum1(savNxt)  = $itum1
650aAC                   eval      #parentitflg1(savNxt) = $itflg1
650aAC                   eval      #parentitum2(savNxt)  = $itum2
650aAC                   eval      #parentitumq2(savNxt) = $itumq2
650aAC                   eval      #parentitflg2(savNxt) = $itflg2
650aAC                   eval      #parentitum3(savNxt)  = $itum3
650aAC                   eval      #parentitumq3(savNxt) = $itumq3
650aAC                   eval      #parentitnrpk(savNxt) = $imnrpk
650aAC                   eval      #parentitflgd(savNxt) = $itflgd
650aAC                   eval      #parentitcube(savNxt) = $itcube
650aAC                   eval      #parentitswgt(savNxt) = $itswgt
650aAC                   eval      #parentitcwgt(savNxt) = $itcwgt
650aAC                   eval      #parentitmitem(savNxt) = $itmitem
650aAC                   eval      #parentitsdef(savNxt) = ' '
650aAC                   eval      #parentittie(savNxt)  = 0
650aAC                   eval      #parentithigh(savNxt) = 0

     *  Create heading description.

650aA /free
650aA    callp FRMTIT(#parentititem(savNxt):
650aA                 #parentitdesc(savNxt):
650aA                 #parentitpdsc(savNxt):
650aA                 #parentithead(savNxt));
650aA /end-free
650aD *                  call      'FRMTIT'
650aD *                  parm                    #parentititem
650aD *                  parm                    #parentitdesc
650aD *                  parm                    #parentitpdsc
650aD *                  parm      ' '           #parentithead

     C     endgetparenti endsr

     *----------------------------------------------------------------
     *  ZZGETPARENTIQ   Get Parent warehouse item quantity
     *----------------------------------------------------------------

     C     zzgetparentiq begsr

     *  Get warehouse quantity

     C                   exsr      clr$itemqty
650aDC*                  eval      $iqwhse  = kohwhs
650aMC                   eval      $iqwhse  = $pwhse
     C                   eval      $iqitem  = kccitm

     C                   eval      $dricommand = '*ITEMQTY'
     C                   eval      $drisubcmd  = '*GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetparentq
     C                   endif

650aDC*                  eval      #parentiqavl1 = $iqavl1
650aDC*                  eval      #parentiqavl2 = $iqavl2
650aDC*                  eval      #parentiqavl3 = $iqavl3
650aMC                   eval      #parentiqavl1(savNxt) = $iqavl1
650aMC                   eval      #parentiqavl2(savNxt) = $iqavl2
650aMC                   eval      #parentiqavl3(savNxt) = $iqavl3

     C     endgetparentq endsr

     *----------------------------------------------------------------
     *  zzgetparentsl  Get Parent Rwouom slot
     *----------------------------------------------------------------

     C     zzgetparentsl begsr

650gA*  if parent is on-demand repack make sure on-demand pick slot
650gA*     exists
650aDC*                  eval      $slwhse  = #parentitwhse
650aDC*                  eval      $slwhdp  = #parentitwhdp
650aDC*                  eval      $slitem  = #parentititem
650gA /free
650gA     onDmdonDmd = *off;
650gA     $slwhse  = #parentitwhse(savNxt);
650gA     $slwhdp  = #parentitwhdp(savNxt);
650gA     $slitem  = #parentititem(savNxt);
650gA     chain ($slwhse:$slitem) kititem;
650gA        if %found and kidisp <> ' ';
650gA           exsr clr$slot;
650gA           $slwhseu = *on;
650gA           $slwhse  = #parentitwhse(savNxt);
650gA           $slwhdpu = *on;
650gA           $slwhdp  = #parentitwhdp(savNxt);
650gA           $slitemu = *on;
650gA           $slitem  = #parentititem(savNxt);
650gA           $sldispu = *on;
650gA           $sldisp  = kidisp;
650gA           onDmdonDmd = *on;
650gA
650gA           $dricommand = '*SLOT';
650gA           $drisubcmd  = '%CRTREPAKD';
650gA           $drisys2upd = 'D';
650gA           chk4err = *on;
650gA           exsr zzzdricop;
650gA           error = *off;
650gA        endif;
650gA /end-free

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #parentitwhse(savNxt)
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #parentitwhdp(savNxt)
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #parentititem(savNxt)

     C                   eval      $dricommand = '*SLOT'
     c                   select
650gA*  In this case KCDISP represents the on-demand slot for the parent
650gA*  item currently being processed and the kidisp represents whether
650gA*  that parent is a on-demand item whether it has a on-demand slot
650gA*  associated with the work order or not.  If kidisp not equal blank
650gA*  the system will get the on-demand pick slot to pull parent qty from
650gA*  if kidisp is blank and kcdisp <> blank then it will pass the
650gA*  parent slot and use it for the parent instead of a RPK slot
650gAc                   when      kcdisp <> ' ' or kidisp <> ' '
650gAc                   eval      $sldispu = *on
650gAc                   eval      $sldisp = kcdisp
650gAc                   if        onDmdonDmd
650gAc                   eval      $sldisp = kidisp
650gAC                   eval      $slitem  = kccitm
650gAC                   eval      $drisubcmd  = '%GETODRRPK'
650gAc                   else
650gAC                   eval      $drisubcmd  = '%GET'
650gAc                   endif
650gAc                   other
     C                   eval      $drisubcmd  = '%GETREPACK'
650gAc                   endsl
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     c                   eval      #parentslexpd(savNxt)=0
     C                   goto      endgetparentsl
     C                   endif

650aDC*                  eval      #parentslwhse = $slwhse
650aDC*                  eval      #parentslwhdp = $slwhdp
650aDC*                  eval      #parentslstyp = $slstyp
650aDC*                  eval      #parentsldisp = $sldisp
650aDC*                  eval      #parentslaisl = $slaisl
650aDC*                  eval      #parentslloc  = $slloc
650aDC*                  eval      #parentslpseq = $slpseq
650aDC*                  eval      #parentslrlvl = $slrlvl
650aDC*                  eval      #parentslhand = $slhand
650aDC*                  eval      #parentslstat = $slstat
650aDC*                  eval      #parentslrsrv = $slrsrv
650aDC*                  eval      #parentslentd = $slentd
650aDC*                  eval      #parentslexpd = $slexpd
650aDC*                  eval      #parentslslfd = $slslfd
650aDC*                  eval      #parentslactv = $slactv
650aDC*                  eval      #parentslbld  = $slbld
650aDC*                  eval      #parentslpick = $slpick
650aDC*                  eval      #parentslitem = $slitem
650aDC*                  eval      #parentslsdef = $slsdef
650aDC*                  eval      #parentslvirt = $sfvirt
650aDC*                  eval      #parentslstk1 = $slstk1
650aDC*                  eval      #parentslstk2 = $slstk2
650aDC*                  eval      #parentslstk3 = $slstk3
650aDC*                  eval      #parentslalc1 = $slalc1
650aDC*                  eval      #parentslalc2 = $slalc2
650aDC*                  eval      #parentslalc3 = $slalc3
650aDC*                  eval      #parentsltfr1 = $sltfr1
650aDC*                  eval      #parentsltfr2 = $sltfr2
650aDC*                  eval      #parentsltfr3 = $sltfr3
650aDC*                  eval      #parentslpck1 = $slpck1
650aDC*                  eval      #parentslpck2 = $slpck2
650aDC*                  eval      #parentslpck3 = $slpck3
650aDC*                  eval      #parentslrcv1 = $slrcv1
650aDC*                  eval      #parentslrcv2 = $slrcv2
650aDC*                  eval      #parentslrcv3 = $slrcv3
650aDC*                  eval      #parentslphy1 = $slphy1
650aDC*                  eval      #parentslphy2 = $slphy2
650aDC*                  eval      #parentslphy3 = $slphy3
650aDC*                  eval      #parentslavl1 = $slavl1
650aDC*                  eval      #parentslavl2 = $slavl2
650aDC*                  eval      #parentslavl3 = $slavl3

650aAC                   eval      #parentslwhse(savNxt) = $slwhse
650aAC                   eval      #repackslwhse = $slwhse
650aAC                   eval      #parentslwhdp(savNxt) = $slwhdp
650aAC                   eval      #repackslwhdp = $slwhdp
650aAC                   eval      #parentslstyp(savNxt) = $slstyp
650aAC                   eval      #parentsldisp(savNxt) = $sldisp
650aAC                   eval      #parentslaisl(savNxt) = $slaisl
650aAC                   eval      #parentslloc(savNxt)  = $slloc
650aAC                   eval      #parentslpseq(savNxt) = $slpseq
650aAC                   eval      #parentslrlvl(savNxt) = $slrlvl
650aAC                   eval      #parentslhand(savNxt) = $slhand
650aAC                   eval      #parentslstat(savNxt) = $slstat
650aAC                   eval      #parentslrsrv(savNxt) = $slrsrv
650aAC                   eval      #parentslentd(savNxt) = $slentd
650aAC                   eval      #parentslexpd(savNxt) = $slexpd
650aAC                   eval      #parentslslfd(savNxt) = $slslfd
650aAC                   eval      #parentslactv(savNxt) = $slactv
650aAC                   eval      #parentslbld(savNxt)  = $slbld
650aAC                   eval      #parentslpick(savNxt) = $slpick
650aAC                   eval      #parentslitem(savNxt) = $slitem
650aAC                   eval      #parentslsdef(savNxt) = $slsdef
650aAC                   eval      #parentslvirt(savNxt) = $sfvirt
650aAC                   eval      #parentslstk1(savNxt) = $slstk1
650aAC                   eval      #parentslstk2(savNxt) = $slstk2
650aAC                   eval      #parentslstk3(savNxt) = $slstk3
650aAC                   eval      #parentslalc1(savNxt) = $slalc1
650aAC                   eval      #parentslalc2(savNxt) = $slalc2
650aAC                   eval      #parentslalc3(savNxt) = $slalc3
650aAC                   eval      #parentsltfr1(savNxt) = $sltfr1
650aAC                   eval      #parentsltfr2(savNxt) = $sltfr2
650aAC                   eval      #parentsltfr3(savNxt) = $sltfr3
650aAC                   eval      #parentslpck1(savNxt) = $slpck1
650aAC                   eval      #parentslpck2(savNxt) = $slpck2
650aAC                   eval      #parentslpck3(savNxt) = $slpck3
650aAC                   eval      #parentslrcv1(savNxt) = $slrcv1
650aAC                   eval      #parentslrcv2(savNxt) = $slrcv2
650aAC                   eval      #parentslrcv3(savNxt) = $slrcv3
650aAc                   eval      #parentslphy1(savNxt) = $slphy1
650aAC                   eval      #parentslphy2(savNxt) = $slphy2
650aAC                   eval      #parentslphy3(savNxt) = $slphy3
650aAC                   eval      #parentslavl1(savNxt) = $slavl1
650aAC                   eval      #parentslavl2(savNxt) = $slavl2
650aAC                   eval      #parentslavl3(savNxt) = $slavl3

610 AC                   eval      pSavOLcns = $saOLcns
610 AC                   eval      pSavToLcns = $saToLcns

     C     endgetparentslendsr

     *----------------------------------------------------------------
     *  ZZGETREPACKIT Get Repack item
     *----------------------------------------------------------------

     C     zzgetrepackit begsr

     *  Get item.

     C                   exsr      clr$item
510aAC                   if        nxtscr = '01'
     C                   eval      $itwhse  = kohwhs
     C                   eval      $ititem  = kohitm
650aAc                   eval      w2item   = kohitm
510aAC                   else
510aAC                   eval      $itwhse  = $pwhse
510aAC                   eval      $ititem  = w2item
510aAC                   endif

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetrepacki
     C                   endif

650iA *  get output quantity or Repack item from KITITEM
650iA /free
700aD  //chain(n) (kohwhs:kohitm) kititem;
700aA    chain(n) ($itwhse:$ititem) kititem;
650iA    if not %error and %found;
650iA       #repackoutqty = kiqty1;
700aA       #repackkirptp = kirptp;
650iA    else;
650iA       #repackoutqty = 1;
700aA       #repackkirptp = '1';
650iA    endif;
650iA    setll *loval kititem;
650iA /end-free
     C                   eval      #repackitwhse = $itwhse
     C                   eval      #repackititem = $ititem
     C                   eval      #repackittype = $ittype
     C                   eval      #repackitdesc = $itdesc
     C                   eval      #repackitpdsc = $itpdsc
     C                   eval      #repackitwhdp = $itwhdp
     C                   eval      #repackitstyp = $itstyp
     C                   eval      #repackitdesg = $itdesg
     C                   eval      #repackitum1  = $itum1
     C                   eval      #repackitflg1 = $itflg1
     C                   eval      #repackitum2  = $itum2
     C                   eval      #repackitumq2 = $itumq2
     C                   eval      #repackitflg2 = $itflg2
     C                   eval      #repackitum3 = $itum3
     C                   eval      #repackitumq3 = $itumq3
     C                   eval      #repackitnrpk = $imnrpk
510bAC                   eval      #repackimmflg = $immflg
510bAC                   eval      #repackimdday = $imdday
510bAC                   eval      #repackimmday = $immday
510bAC                   eval      #repackimuday = $imuday
510bAC                   eval      #repackitflgd = $itflgd
     C                   eval      #repackitcube = $itcube
     C                   eval      #repackitswgt = $itswgt
     C                   eval      #repackitcwgt = $itcwgt
     C                   eval      #repackitmitem = $itmitem
     C                   eval      #repackitsdef = ' '
     C                   eval      #repackittie  = 0
     C                   eval      #repackithigh = 0

     *  Create heading description.

650aA /free
650aA    callp FRMTIT(#repackititem:
650aA                 #repackitdesc:
650aA                 #repackitpdsc:
650aA                 #repackithead);
650aA /end-free
650aD *                  call      'FRMTIT'
650aD *                  parm                    #repackititem
650aD *                  parm                    #repackitdesc
650aD *                  parm                    #repackitpdsc
650aD *                  parm      ' '           #repackithead

     C     endgetrepacki endsr

     *----------------------------------------------------------------
     *  zzgetrepacksl  Get Repack item Repack slot
     *----------------------------------------------------------------

     C     zzgetrepacksl begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #repackitwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #repackitwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #repackititem

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETREPACK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetrepacksl
     C                   endif

     C                   eval      #repackslwhse = $slwhse
     C                   eval      #repackslwhdp = $slwhdp
     C                   eval      #repackslstyp = $slstyp
     C                   eval      #repacksldisp = $sldisp
     C                   eval      #repackslaisl = $slaisl
     C                   eval      #repackslloc  = $slloc
     C                   eval      #repackslpseq = $slpseq
     C                   eval      #repackslrlvl = $slrlvl
     C                   eval      #repackslhand = $slhand
     C                   eval      #repackslstat = $slstat
     C                   eval      #repackslrsrv = $slrsrv
     C                   eval      #repackslentd = $slentd
     C                   eval      #repackslexpd = $slexpd
     C                   eval      #repackslslfd = $slslfd
     C                   eval      #repackslactv = $slactv
     C                   eval      #repackslbld  = $slbld
     C                   eval      #repackslpick = $slpick
     C                   eval      #repackslitem = $slitem
     C                   eval      #repackslsdef = $slsdef
     C                   eval      #repackslvirt = $sfvirt
     C                   eval      #repackslstk1 = $slstk1
     C                   eval      #repackslstk2 = $slstk2
     C                   eval      #repackslstk3 = $slstk3
     C                   eval      #repackslalc1 = $slalc1
     C                   eval      #repackslalc2 = $slalc2
     C                   eval      #repackslalc3 = $slalc3
     C                   eval      #repacksltfr1 = $sltfr1
     C                   eval      #repacksltfr2 = $sltfr2
     C                   eval      #repacksltfr3 = $sltfr3
     C                   eval      #repackslpck1 = $slpck1
     C                   eval      #repackslpck2 = $slpck2
     C                   eval      #repackslpck3 = $slpck3
     C                   eval      #repackslrcv1 = $slrcv1
     C                   eval      #repackslrcv2 = $slrcv2
     C                   eval      #repackslrcv3 = $slrcv3
     C                   eval      #repackslphy1 = $slphy1
     C                   eval      #repackslphy2 = $slphy2
     C                   eval      #repackslphy3 = $slphy3
     C                   eval      #repackslavl1 = $slavl1
     C                   eval      #repackslavl2 = $slavl2
     C                   eval      #repackslavl3 = $slavl3

610 AC                   eval      rSavOLcns = $saOLcns
610 AC                   eval      rSavToLcns = $saToLcns

     C     endgetrepackslendsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
     C                   kfld                    $pitem

     *  Define key for LICENSE file.

     C     filek2        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lic

     *  Define key for KITCOMP file.

     C     keykc         klist
     C                   kfld                    $pwhse
     C                   kfld                    kohitm
     *  Define key for subfile paging

650aAC     partky        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    kohitm
     *  Define key for subfile paging

650aAC     compky        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    kohitm
650aAC                   kfld                    prvkey

530aA*  Define key for KITCOMP file.

530aAC     keykc2        klist
530aAC                   kfld                    $pwhse
530aAC                   kfld                    w2item

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    kycode

650aAc                   eval      FirstPass = *on
650aAc                   eval      FrmRollUp = *off

     C                   endsr
     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Get Repack options.

     C                   eval      kycode = '*REPACK'
     C     keyop         chain(e)  options
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      errmsg = 'Repack options not defined'
     C                   exsr      zm0105s
510aAC                   else
510aAC                   eval      opdat1 = opdata
     C                   endif

510bA*    Get User's employee number to be written to PORCV file
510bA*    if any records are flagged as touched.

510bAC                   call      'GETUSER'
510bAC                   parm      #user         $code            10
510bAC                   parm      0             $whse             3 0
510bAC                   parm      0             $emp#             5 0
510bAC                   parm      *blanks       $fnam            15
510bAC                   parm      *blanks       $init             1
510bAC                   parm      *blanks       $lnam            20
510bAC                   parm      *blanks       $whdp             5
510bAC                   parm      *blanks       $styp             1
510bAC                   parm      *blanks       $shft             6
510bAC                   parm      *blanks       $crew             6
510bAC                   parm      0             $nhrs             3 1
510bAC                   parm      *blanks       $rtn              8

     *   Select first screen to display.

     C                   if        $pcmd = '*ADD    '
     C                   exsr      scr02i
     C                   else
650aA*    Ensure that Repack slots are still available for work order
650aA*    when user returns to build more or review before closing
650aA*    if the previous build used all parent quantity in a repack
650aA*    slot the system would remove and generate error upon return

650aAC                   call      'CRTWRKORD'
650aAC                   parm      '*CRTRPKSLT'  $rcmd
650aAC                   parm      $pwhse        $rwhse
650aAC                   parm      $pitem        $ritem
650aAC                   parm      0             $rqty
650aAC                   parm      'M'           $rby
650aAC                   parm      ' '           $rref
650aAC                   parm      ' '           $rrtn
650aAC                   parm      ' '           $rmsg
650aAC                   parm      0             $rord
650aAC                   parm      w2ndtc        $rndtc

650aAC                   if        $rrtn = '*ERROR'
650aAC                   eval      error = *on
650aAC                   eval      errmsg = $rmsg
650aAC                   exsr      zm0105
650aAc                   eval      nxtscr = 'EOJ'
650aAc                   endif

     C                   exsr      scr01i
     C                   if        error = *off
     C                   exsr      zzstart
     C                   endif
     C                   endif
650aAc                   eval      w1made = 0

     C                   endsr

530 A*----------------------------------------------------------------
530 A*  ZZLICINFO   Update licinfo
530 A*----------------------------------------------------------------
530 A
530 AC     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

530 D ***                eval      $lnemp# = 0
530 D ***                eval      $lnuser = #user
650aDC*                  eval      $lnpgm  = #pgm
650aAC                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
650aDC*                  eval      $lnjobnbr  = #jobnbr
650aAC                   eval      $lnjobnbr  = #jobn

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
530 D ***                eval      $lnlcns  = w1lic
530 MC                   eval      $lnlcns  = $saToLcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*PO'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $ppo
     C                   eval      $lnvalnum(1) = 0

     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*POSEQ'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pseq

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*ITEM'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = $pitem
     C                   eval      $lnvalnum(3) = 0

530 D ***                eval      $lncodeu(4) = *on
530 D ***                eval      $lncode(4) = '*RCVJOB'
530 D ***                eval      $lncseq(4) = 1
530 D ***                eval      $lnvaltyp(4) = 'A'
530 D ***                eval      $lnvalchr(4) = %trim(#user) + '/'
530 D ***                                       + %trim(#job) + '/'
530 D ***                                       + %trim(#jobn)
530 D ***                eval      $lnvalnum(4) = 0

     C                   eval      $lncodeu(5) = *on
     C                   eval      $lncode(5) = '*RCVTRN#'
     C                   eval      $lncseq(5) = 1
     C                   eval      $lnvaltyp(5) = 'N'
     C                   eval      $lnvalchr(5) = ' '
     C                   eval      $lnvalnum(5) = pttrn#

530 A ***                eval      $lncodeu(6) = *on
530 D ***                eval      $lncode(6) = '*RCVTS'
530 D ***                eval      $lncseq(6) = 1
530 D ***                eval      $lnvaltyp(6) = 'A'
530 D ***                time                    currtimestamp
530 D ***                eval      $lnvalchr(6) = %char(currtimestamp)
530 D ***                eval      $lnvalnum(6) = 0

     C                   eval      $lncodeu(7) = *on
     C                   eval      $lncode(7) = '*RCVLQTY'
     C                   eval      $lncseq(7) = 1
     C                   eval      $lnvaltyp(7) = 'N'
     C                   eval      $lnvalchr(7) = ' '
     C                   eval      $lnvalnum(7) = w1made

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

530 D ***                eval      $lnemp# = 0
530 D ***                eval      $lnuser = #user
650aDC*                  eval      $lnpgm  = #pgm
650aAC                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
650aDC*                  eval      $lnjobnbr  = #jobnbr
650aAC                   eval      $lnjobnbr  = #jobn

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
530 D ***                eval      $lnlcns  = w1lic
530 MC                   eval      $lnlcns  = $saToLcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lblbl#

     C                   if        $pexpd > *zeros
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pexpd
     C                   endif

     C                   if        $pindt > *zeros
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = $pindt
     C                   endif

     C                   if        $pfifo > *zeros
     C                   eval      $lncodeu(4) = *on
     C                   eval      $lncode(4) = '*FIFODTE'
     C                   eval      $lncseq(4) = 1
     C                   eval      $lnvaltyp(4) = 'N'
     C                   eval      $lnvalchr(4) = ' '
     C                   eval      $lnvalnum(4) = $pfifo
     C                   endif

650aDC*                  if        $plotc <> ' '
650aAC                   if        w1lot <> ' '
     C                   eval      $lncodeu(5) = *on
     C                   eval      $lncode(5) = '*LOT'
     C                   eval      $lncseq(5) = 1
     C                   eval      $lnvaltyp(5) = 'A'
650aDC*                  eval      $lnvalchr(5) = $plotc
650aAC                   eval      $lnvalchr(5) = w1lot
     C                   eval      $lnvalnum(5) = 0
     C                   endif

     C                   if        w1umt = 'N' and $pawt1 > *zeros
     C                             or w1umt = '1' and $pawt2 > *zeros
     C                             or w1umt = '2' and $pawt3 > *zeros
     C                   eval      $lncodeu(6) = *on
     C                   eval      $lncode(6) = '*AVGWGT'
     C                   eval      $lncseq(6) = 1
     C                   eval      $lnvaltyp(6) = 'N'
     C                   eval      $lnvalchr(6) = ' '
     C                   select
     C                   when      w1umt = '1'
     C                   eval      $lnvalnum(6) = $pawt2
     C                   when      w1umt = '2'
     C                   eval      $lnvalnum(6) = $pawt3
     C                   other
     C                   eval      $lnvalnum(6) = $pawt1
     C                   endsl
     C                   endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out date type license information.

     C                   exsr      clr$licinfo

530 D ***                eval      $lnemp# = 0
530 D ***                eval      $lnuser = #user
650aDC*                  eval      $lnpgm  = #pgm
650aAC                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
650aDC*                  eval      $lnjobnbr  = #jobnbr
650aAC                   eval      $lnjobnbr  = #jobn

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
530 D ***                eval      $lnlcns  = w1lic
530 MC                   eval      $lnlcns  = $saToLcns

     C                   if        $pfifo > *zeros
     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*DATETYP'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = '*FIFODT'
     C                   eval      $lnvalnum(1) = 0
     C                   else
     C                   if        #repackitflgd = 'Y'
     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*DATETYP'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalnum(1) = 0
     C                   select
     C                   when      #repackimuday > 0 or
     C                             #repackimdday > *zeros
     C                   if        #repackimmflg = 'Y'
     C                   eval      $lnvalchr(1) = '*MFGDTE'
     C                   else
     C                   eval      $lnvalchr(1) = '*USEDTE'
     C                   endif
     C                   other
     C                   eval      $lnvalchr(1) = '*EXPDTE'
     C                   endsl
     C                   else
     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*DATETYP'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = '*ENTDTE'
     C                   eval      $lnvalnum(1) = 0
     C                   endif

650aDC*                  move      #repackimuday rcvuday
650aDC*                  move      #repackimdday rcvdday
650aDC*                  move      #repackimmday rcvmday
650aAC                   eval      rcvuday=%char(#repackimuday)
650aAC                   eval      rcvdday=%char(#repackimdday)
650aAC                   eval      rcvmday=%char(#repackimmday)
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*DTESET1'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'A'
     C                   eval      $lnvalchr(2) = '&DTEF='+
     C                               (#repackitflgd)+
     C                             ' &MFGF='+(#repackimmflg)
     C                   eval      $lnvalnum(2) = 0

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DTESET2'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = '&MFGD='+(rcvmday) +
     C                             ' &USRD='+(rcvuday) +
     C                             ' &DSTD='+(rcvdday)
     C                   eval      $lnvalnum(3) = 0
     C                   endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

530 AC                   endsr

PAN A*----------------------------------------------------------------
PAN A*  ZZBREAKCHK  Checks to see if full case from Case item stock needs
PAN A*              to be moved into same slot Breakdown item.  In this
PAN A*              the customer keeps separate inventories on host side
PAN A*              for the Case and Breakdown items. When repack has to
PAN A*              breakdown the case if we do not show enough stock in
PAN A*              the breakdown case we issue a transfer so the host will
PAN A*              move a full case to the breakdown item before the repack
PAN A*              adjustment is processed
PAN A*----------------------------------------------------------------
PAN A
PAN AC     zzBreakChk    begsr
PAN A
PAN A*    Move one full case from the RPK slot for Case Item to breakdown
PAN A*    for breakdown item if there are not enough breakdown quantities
PAN A*    to cover the breakdown need per this transaction
PAN A
PAN Ac                   select
PAN A*    If either the RPK slot has enough breakdown quantities for request
PAN A*    or there is no case quantitiy in the Repack slot we should not
PAN A*    attempt to breakdown additional case quantity.  There is a When clause
PAN A*    for items when both breakdowns are used or only one breakdown is used
PAN Ac                   when      #parentitumq3(reccnt) <> 0
PAN Ac                   if        ((($saqty2 * #parentitumq3(reccnt))
PAN Ac                              + $saqty3) <= (#parentslstk2(reccnt) *
PAN Ac                                #parentitumq3(reccnt) + #parentslstk3
PAN Ac                                  (reccnt)))
PAN Ac                                or #parentslstk1(reccnt) < 1
PAN Ac                   goto      endBreak
PAN Ac                   endif
PAN Ac                   other
PAN Ac                   if        $saqty2 <= #parentslstk2(reccnt)
PAN Ac                             or #parentslstk1(reccnt) < 1
PAN Ac                   goto      endBreak
PAN Ac                   endif
PAN Ac                   endsl
PAN A
PAN Ac*   plus adjust to breakdown item first to prevent RPK slot from being moved to
PAN Ac*   "Z" status if this is last case being converted to eaches
PAN AC                   exsr      clr$slot
PAN AC                   eval      $saemp#u = *on
PAN AC                   eval      $saemp# = $emp#
PAN AC                   eval      $slwhseu  = *on
PAN AC                   eval      $slwhse   = #parentslwhse(reccnt)
PAN AC                   eval      $slwhdpu  = *on
PAN AC                   eval      $slwhdp   = #parentslwhdp(reccnt)
PAN AC                   eval      $sldispu  = *on
PAN AC                   eval      $sldisp   = #parentsldisp(reccnt)
PAN AC                   eval      $saitemu  = *on
PAN AC                   eval      $saitem   = #parentslitem(reccnt)
PAN AC                   eval      $sacodeu  = *on
PAN AC                   eval      $sacode   = oppadj
PAN AC                   eval      $saqtyu   = *on
PAN AC                   eval      $saqty1   = 0
PAN AC                   eval      $saqty2   = #parentitumq2(reccnt)
PAN AC                   eval      $saqty3   = 0
PAN AC                   eval      $sabyu   = *on
PAN AC                   eval      $saby    = #user
PAN A
PAN Ac                   eval      $samemoU = *on
PAN Ac                   eval      $samemo = 'Case to Breakdown Adj'
PAN A
PAN AC                   eval      $saActionU = *on
PAN AC                   eval      $saAction = 'RPK'
PAN AC                   eval      $saETrn#U = *on
PAN AC                   eval      $saETrn# = 0
PAN AC                   eval      $saFrmLcnsU = *on
PAN AC                   eval      $saFrmLcns = w1lic
PAN A
PAN AC                   eval      $dricommand = '*SLOT'
PAN AC                   eval      $drisubcmd  = '%ADJUST'
PAN AC                   eval      $drisys2upd = 'D'
PAN AC                   eval      chk4err = *on
PAN AC                   eval      zmsflag = *off
PAN AC                   exsr      zzzdricop
PAN AC                   if        drierr
PAN AC                   eval      error = *on
PAN AC                   eval      $drimessage = 'Parent: ' + $drimessage
PAN AC                   exsr      zm0001
PAN AC                   goto      endBreak
PAN AC                   endif
PAN A
PAN Ac*     now subtract a full case from Case item
PAN AC                   exsr      clr$slot
PAN AC                   eval      $saemp#u = *on
PAN AC                   eval      $saemp# = $emp#
PAN AC                   eval      $slwhseu  = *on
PAN AC                   eval      $slwhse   = #parentslwhse(reccnt)
PAN AC                   eval      $slwhdpu  = *on
PAN AC                   eval      $slwhdp   = #parentslwhdp(reccnt)
PAN AC                   eval      $sldispu  = *on
PAN AC                   eval      $sldisp   = #parentsldisp(reccnt)
PAN AC                   eval      $saitemu  = *on
PAN AC                   eval      $saitem   = #parentslitem(reccnt)
PAN AC                   eval      $sacodeu  = *on
PAN AC                   eval      $sacode   = oppadj
PAN AC                   eval      $saqtyu   = *on
PAN AC                   eval      $saqty1   = -1
PAN AC                   eval      $saqty2   = 0
PAN AC                   eval      $saqty3   = 0
PAN AC                   eval      $sabyu   = *on
PAN AC                   eval      $saby    = #user
PAN A
PAN Ac                   eval      $samemoU = *on
PAN Ac                   eval      $samemo = 'Case to Breakdown Adj'
PAN A
PAN AC                   eval      $saActionU = *on
PAN AC                   eval      $saAction = 'RPK'
PAN AC                   eval      $saETrn#U = *on
PAN AC                   eval      $saETrn# = 0
PAN AC                   eval      $saFrmLcnsU = *on
PAN AC                   eval      $saFrmLcns = w1lic
PAN A
PAN AC                   eval      $dricommand = '*SLOT'
PAN AC                   eval      $drisubcmd  = '%ADJUST'
PAN AC                   eval      $drisys2upd = 'D'
PAN AC                   eval      chk4err = *on
PAN AC                   eval      zmsflag = *off
PAN AC                   exsr      zzzdricop
PAN AC                   if        drierr
PAN AC                   eval      error = *on
PAN AC                   eval      $drimessage = 'Parent: ' + $drimessage
PAN AC                   exsr      zm0001
PAN AC                   goto      endBreak
PAN AC                   endif
PAN A
PAN Ac*       setup for original transaction before we return after making case to
PAN Ac*       breakdown inventory adjustment
PAN AC                   exsr      clr$slot
PAN AC                   eval      $saemp#u = *on
PAN AC                   eval      $saemp# = $emp#
PAN AC                   eval      $slwhseu  = *on
PAN AC                   eval      $slwhse   = #parentslwhse(reccnt)
PAN AC                   eval      $slwhdpu  = *on
PAN AC                   eval      $slwhdp   = #parentslwhdp(reccnt)
PAN AC                   eval      $sldispu  = *on
PAN AC                   eval      $sldisp   = #parentsldisp(reccnt)
PAN AC                   eval      $saitemu  = *on
PAN AC                   eval      $saitem   = #parentslitem(reccnt)
PAN AC                   eval      $sacodeu  = *on
PAN AC                   eval      $sacode   = oppadj
PAN AC                   eval      $saqtyu   = *on
PAN A
PAN Ac                   if        #repackoutqty > 1
PAN Ac                   eval      $saqty1 = w1made*#parentqty1(reccnt)
PAN Ac                   eval      $saqty2 = w1made*#parentqty2(reccnt)
PAN Ac                   eval      $saqty3 = w1made*#parentqty3(reccnt)
PAN Ac                   exsr      zzUpqty
PAN Ac                   eval      wrkQty1 = $saqty1
PAN Ac                   eval      wrkQty2 = $saqty2
PAN Ac                   eval      wrkQty3 = $saqty3
PAN Ac                   eval      wstPtr = reccnt
PAN Ac                   exsr      zzadjQty
PAN Ac                   else
PAN AC                   eval      $saqty1   = w1made * #parentqty1(reccnt)
PAN AC                   eval      $saqty2   = w1made * #parentqty2(reccnt)
PAN AC                   eval      $saqty3   = w1made * #parentqty3(reccnt)
PAN Ac                   endif
PAN AC                   exsr      zzupqty
PAN A
PAN Ac     endBreak      endsr
     c
     *----------------------------------------------------------------
     *  ZZSTART   Start work order.
     *----------------------------------------------------------------

     C     zzstart       begsr

     C                   eval      startFlag = *off
     C                   if        kohsta = '1'
     C                   eval      startFlag = *on
     C                   eval      kohsta = '2'
     C                   exsr      zzgetdatetime
     C                   eval      kohsdt = curdate
     C                   eval      kohstm = curtime
     C                   update    record
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

SPIaA /free
SPIaA   // Call program to get 11 digit batch id
SPIaA   select;
SPIaA     when client = SternProduce;
SPIaA       GetRecId($pwhse: 'WR112': RpkId);
SPIaA   endsl;
SPIaA /end-free

650aA*    loop through parent array completing updates
     c                   for       reccnt = 1 to savNxt
     c                   eval      wstPtr = reccnt
650aA*    if bypass flag set in sfl then turn on ovrrid, otherwise
650aA*       turn it off to simulate a one to one flow previously
650aAC                   if        #bypassrepl(reccnt) = *on
650aAc                   eval      ovrrid = *on
650aAc                   else
650aAc                   eval      ovrrid = *off
650aAc                   endif

     *    Remove quantity from Parent slot.

     C                   exsr      clr$slot
710 AC                   eval      $saemp#u = *on
710 AC                   eval      $saemp# = $emp#
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = #parentslwhse(reccnt)
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #parentslwhdp(reccnt)
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #parentsldisp(reccnt)
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #parentslitem(reccnt)
     C                   eval      $sacodeu  = *on
     C                   eval      $sacode   = oppadj
     C                   eval      $saqtyu   = *on
650cDC**                 eval      $saqty1   = -(w1made * #parentqty1(reccnt))
650cDC**                 eval      $saqty2   = -(w1made * #parentqty2(reccnt))
650cDC**                 eval      $saqty3   = -(w1made * #parentqty3(reccnt))

650iAc                   if        #repackoutqty > 1
650iAc                   eval      $saqty1 = w1made*#parentqty1(reccnt)
650iAc                   eval      $saqty2 = w1made*#parentqty2(reccnt)
650iAc                   eval      $saqty3 = w1made*#parentqty3(reccnt)
650iAc                   exsr      zzUpqty
650iAc                   eval      wrkQty1 = $saqty1
650iAc                   eval      wrkQty2 = $saqty2
650iAc                   eval      wrkQty3 = $saqty3
650iAc                   eval      wstPtr = reccnt
650iAc                   exsr      zzadjQty
650iAc                   else
650cMC                   eval      $saqty1   = w1made * #parentqty1(reccnt)
650cMC                   eval      $saqty2   = w1made * #parentqty2(reccnt)
650cMC                   eval      $saqty3   = w1made * #parentqty3(reccnt)
650iAc                   endif
650cMC                   exsr      zzupqty

PAN Ac*    If Panos and breakdown quantities exist we should go determine if a transfer
PAN Ac*    of case stock to breakdown stock should occur.  On the Dakota side this will
PAN Ac*    only look like an in and out but on the Panos side it will move a full case from
PAN Ac*    the case item to the breakdown item
PAN A
PAN Ac                   if        client = panos
PAN Ac                             and ($saQty2<>0 or $saqty3<>0)
PAN Ac                   exsr      zzBreakChk
PAN Ac                   endif
PAN A
650cMC                   eval      $saqty1 *= -1
650cMC                   eval      $saqty2 *= -1
650cMC                   eval      $saqty3 *= -1
610uAC                   eval      $sabyu   = *on
610uAC                   eval      $saby    = #user

650aA
650aAc                   eval      $samemoU = *on
SPIaAc                   select
SPIaAc                   when      client = SternProduce
SPIaAc                   eval      $samemo = 'RPK ' + %editc(RpkID:'X')
DRYaAc                   when      client = Dairyland
DRYaAc                   eval      $samemo = 'RPKWO' + %editc(woword:'X')
SPIaAc                   other
650aAc                   eval      $samemo = 'RPKWO - ' + kohref
SPIaAc                   endsl
650aA
610uAC                   eval      $saActionU = *on
610uAC                   eval      $saAction = 'RPK'
610uAC                   eval      $saETrn#U = *on
610uAC                   eval      $saETrn# = 0
610uAC                   eval      $saFrmLcnsU = *on
610uAC                   eval      $saFrmLcns = w1lic

     C                   eval      $dricommand = '*SLOT'
610eAC                   select
610eAC                   when      ovrrid = *on
710aAC                             or ovrQty = *on
610eAC                   eval      $drisubcmd  = '%ADJUSTORD'
610eAC                   when      ovrrid = *off
710aAC                             and ovrQty = *off
     C                   eval      $drisubcmd  = '%ADJUST'
610eAC                   endsl
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $drimessage = 'Parent: ' + $drimessage
     C                   exsr      zm0001
     C                   goto      endup1
     C                   endif

610eAC                   if        ovrrid = *on
650aDC*                  exsr      zzgetparentsl
650aDC*                  exsr      zzgetparentsl
650aMC                   if        #parentslstk1(reccnt) < 0
650aMC                             or #parentslstk2(reccnt) < 0
650aMC                             or #parentslstk3(reccnt) < 0
650aMC                   eval      qty1 = #parentslstk1(reccnt)
650aMC                   eval      qty2 = #parentslstk2(reccnt)
650aMC                   eval      qty3 = #parentslstk3(reccnt)

610eA*    Add quantity to Parent slot if slot is negative.

610eAC                   exsr      clr$slot
610eAC                   eval      $slwhseu  = *on
650aAC                   eval      $slwhse   = #parentslwhse(reccnt)
610eAC                   eval      $slwhdpu  = *on
650aAC                   eval      $slwhdp   = #parentslwhdp(reccnt)
610eAC                   eval      $sldispu  = *on
650aAC                   eval      $sldisp   = #parentsldisp(reccnt)
610eAC                   eval      $saitemu  = *on
650aAC                   eval      $saitem   = #parentslitem(reccnt)
610eAC                   eval      $sacodeu  = *on
610eAC                   eval      $sacode   = 'R4'
610eAC                   eval      $saqtyu   = *on
610eAC                   eval      $saqty1   = -(qty1)
610eAC                   eval      $saqty2   = -(qty2)
610eAC                   eval      $saqty3   = -(qty3)
610eAC                   eval      $sabyu   = *on
610eAC                   eval      $saby    = #user
610eA
650aAc                   eval      $samemoU = *on
SPIaAc                   select
SPIaAc                   when      client = SternProduce
SPIaAc                   eval      $samemo = 'RPK ' + %editc(RpkID:'X')
DRYaAc                   when      client = Dairyland
DRYaAc                   eval      $samemo = 'RPKWO' + %editc(woword:'X')
SPIaAc                   other
650aAc                   eval      $samemo = 'RPKWO - ' + kohref
SPIaAc                   endsl
650aA
610eAC                   eval      $saActionU = *on
610eAC                   eval      $saAction = 'RPK'
610eAC                   eval      $saETrn#U = *on
610eAC                   eval      $saETrn# = 0
610eAC                   eval      $saFrmLcnsU = *on
610eAC                   eval      $saFrmLcns = w1lic
610eA
610eAC                   eval      $dricommand = '*SLOT'
610eAC                   eval      $drisubcmd  = '%ADJUSTORD'
610eAC                   eval      $drisys2upd = 'D'
610eAC                   eval      chk4err = *on
610eAC                   eval      zmsflag = *off
610eAC                   exsr      zzzdricop
610eAC                   if        drierr
610eAC                   eval      error = *on
610eAC                   eval      $drimessage = 'Parent: ' + $drimessage
610eAC                   exsr      zm0001
610eAC
610eAC                   endif
610eAC                   endif
610eAC                   endif

     *    Remove waste quantity from Parent slot.

650aAC                   if        #parentwaste1(reccnt) > 0
650aAC                              or #parentwaste2(reccnt) > 0
650aAC                               or #parentwaste3(reccnt) > 0

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
650aAC                   eval      $slwhse   = #parentslwhse(reccnt)
     C                   eval      $slwhdpu  = *on
650aAC                   eval      $slwhdp   = #parentslwhdp(reccnt)
     C                   eval      $sldispu  = *on
650aAC                   eval      $sldisp   = #parentsldisp(reccnt)
     C                   eval      $saitemu  = *on
650aAC                   eval      $saitem   = #parentslitem(reccnt)
     C                   eval      $sacodeu  = *on
     C                   eval      $sacode   = opwadj
     C                   eval      $saqtyu   = *on
710 DC*                  select
710 DC*                  when      #parentwaste1(reccnt) > 0
710 AC                   if        #parentwaste1(reccnt) > 0
650cDC**                 eval      $saqty1   = -(#parentwaste1(reccnt))
650cMC                   eval      $saqty1   = #parentwaste1(reccnt)
710 Ac                   endif
710 DC*                  when      #parentwaste2(reccnt) > 0
710 AC                   if        #parentwaste2(reccnt) > 0
650cDC**                 eval      $saqty2   = -(#parentwaste2(reccnt))
650cMC                   eval      $saqty2   = #parentwaste2(reccnt)
710 Ac                   endif
710 DC*                  when      #parentwaste3(reccnt) > 0
710 AC                   if        #parentwaste3(reccnt) > 0
650cDC**                 eval      $saqty3   = -(#parentwaste3(reccnt))
650cMC                   eval      $saqty3   = #parentwaste3(reccnt)
710 Ac                   endif
710 DC*                  endsl
650cMC                   exsr      zzupqty

PAN Ac*    If Panos and breakdown quantities exist we should go determine if a transfer
PAN Ac*    of case stock to breakdown stock should occur.  On the Dakota side this will
PAN Ac*    only look like an in and out but on the Panos side it will move a full case from
PAN Ac*    the case item to the breakdown item
PAN A
PAN Ac                   if        client = panos
PAN Ac                             and ($saQty2<>0 or $saqty3<>0)
PAN Ac                   exsr      zzBreakChk
PAN Ac                   endif
PAN A
650cMC                   eval      $saqty1 *= -1
650cMC                   eval      $saqty2 *= -1
650cMC                   eval      $saqty3 *= -1
610uAC                   eval      $sabyu   = *on
610uAC                   eval      $saby    = #user

650aAc                   eval      $samemoU = *on
SPIaAc                   select
SPIaAc                   when      client = SternProduce
SPIaAc                   eval      $samemo = 'RPK ' + %editc(RpkID:'X')
DRYaAc                   when      client = Dairyland
DRYaAc                   eval      $samemo = 'RPKWO' + %editc(woword:'X')
SPIaAc                   other
650aAc                   eval      $samemo = 'RPKWO - ' + kohref
SPIaAc                   endsl
650aA
610uAC                   eval      $saActionU = *on
610uAC                   eval      $saAction = 'RPK'
610uAC                   eval      $saETrn#U = *on
610uAC                   eval      $saETrn# = 0
610uAC                   eval      $saFrmLcnsU = *on
610uAC                   eval      $saFrmLcns = w1lic

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $drimessage = 'Waste: ' + $drimessage
     C                   exsr      zm0001
     C                   goto      endup1
     C                   endif

     C                   endif
610bA*    Zero verify if status is 'Z'.
610bAC                   if        $slstat = 'Z'
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
650cAC                   eval      $slwhse  = #parentslwhse(reccnt)
     C                   eval      $slwhdpu = *on
650cAC                   eval      $slwhdp  = #parentslwhdp(reccnt)
     C                   eval      $sldispu = *on
650cAC                   eval      $sldisp  = #parentsldisp(reccnt)

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ZEROVFY'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
610bAC                   endif
510bA
     *    loop for next subfile record
650aAc                   endfor

650iA*    Put license into RCV slot for Repack Item

650iAC                   exsr      zzurcvSlot

     *    This should be performed once versus the loop above for all the
     *    parents included on the repack item

     *    Create ItemAdj record for Repack Item

      /free
650bA    exsr zzgetdatetime;
650bA    iawhse = $slwhse;
650bA    iaitem = $slitem;
650bA    iadate = curdate;
650bA    iatime = curtime;
650bA    iaby   = #user;
650bA    iawhdp = $slwhdp;
650bA    iadisp = $sldisp;
650bA    iacwta = 0;
650bA    iaqty1 = w1made;
650bA    iaqty2 = 0;
650bA    iaqty3 = 0;
650eA   //  iaudte = curdate;
650eA   //  iautim = curtime;
650eM    iaudte = 0;
650eM    iautim = 0;
650aA    iacode = opradj;
SPIaA    select;
SPIaA     when client = SternProduce;
SPIaA      iamemo = 'RPK ' + %editc(RpkID:'X');
DRYaA     when client = Dairyland;
DRYaA      iamemo = 'RPKWO' + %editc(kohord:'X');
SPIaA     other;
650aA    iamemo = 'RPKWO - ' + kohref;
SPIaA    endsl;
650aA    write iarec;
750 A    exsr wrtlicadj;
      /end-free

     *    Write out work order detail record (KITORDD)

650bAC                   eval      kodwhs = kohwhs
650bAC                   eval      kodord = kohord
650bAC                   eval      koditm = kohitm
650bAC                   eval      kodqty = w1made
650bAC                   eval      koddte = curdate
650bAC                   eval      kodtim = curtime
650bAC                   write     kodrec

     *    Add quantitiy to Repack slot

650aD ***                exsr      clr$slot
650aD ***                eval      $slwhseu  = *on
650aD ***                eval      $slwhse   = #repackslwhse
650aD ***                eval      $slwhdpu  = *on
650aD ***                eval      $slwhdp   = #repackslwhdp
650aD ***                eval      $sldispu  = *on
650aD ***                eval      $sldisp   = #repacksldisp
650aD ***                eval      $saitemu  = *on
650aD ***                eval      $saitem   = #repackslitem
650aD ***                eval      $sacodeu  = *on
650aD ***                eval      $sacode   = opradj
650aD ***                eval      $saqtyu   = *on
650aD ***                eval      $saqty1   = w1made
650aD ***                eval      $saqty2   = 0
650aD ***                eval      $saqty3   = 0

650aAc                   eval      $samemoU = *on
SPIaAc                   select
SPIaAc                   when      client = SternProduce
SPIaAc                   eval      $samemo = 'RPK ' + %editc(RpkID:'X')
DRYaAc                   when      client = Dairyland
DRYaAc                   eval      $samemo = 'RPKWO' + %editc(woword:'X')
SPIaAc                   other
650aAc                   eval      $samemo = 'RPKWO - ' + kohref
SPIaAc                   endsl
650aA

530 D ***                eval      $dricommand = '*SLOT'
530 D ***                eval      $drisubcmd  = '%ADJUST'
530 D ***                eval      $drisys2upd = 'D'
530 D ***                eval      chk4err = *on
530 D ***                eval      zmsflag = *off
530 D ***                exsr      zzzdricop
530 D ***                if        drierr
530 D ***                eval      error = *on
530 D ***                eval      $drimessage = 'Repack: ' + $drimessage
530 D ***                exsr      zm0001
530 D ***                goto      endup1
530 D ***                endif

510bA*    Create putaway transaction for Repack Item
510bA
510bAC                   exsr      zzcrttran

     *   Move key values to parameters

     C*                  eval      $pcode = adcode
     C     endup1        endsr
750 A*---------------------------------------------------------------
750 A*
750 A*  WRTLICADJ  Write LICADJ record.
750 A /free
750 A  begsr wrtlicadj;
750 A   monitor;
750 A     GetOptions(%editc(iawhse:'X'): '*ADJUST': '002': '001': getoptval);
750 A     if getoptval = 'Y';
750 A       useLicAdj = *on;
750 A     else;
750 A       useLicAdj = *off;
750 A     endif;
750 A   on-error;
750 A     useLicAdj = *off;
750 A   endmon;
750 A
750 A   // If option not on, do nothing.
750 A   if useLicAdj = *off;
750 A     leavesr;
750 A   endif;
750 A
750 A   // If file not open, open it.
750 A   if not %open(licadj);
750 A     open LicAdj;
750 A   endif;
750 A
750 A   // Get unique adjustment record id.
750 A   GetRecId(iawhse: 'LICADJ': recidnum);
750 A
750 A   // Get adjustment code description/system.
750 A   GetAdjCode(iacode: gaDesc: gaSys);
750 A
750 A   adjwhs = iawhse;
750 A   adjnbr = %char(recidnum);
750 A   adjparent = *blanks;
750 A   adjcode = iacode;
750 A   adjcsys = gaSys;
750 A   adjitem = iaitem;
750 A   adjaqty1 = iaqty1;
750 A   adjaqty2 = iaqty2;
750 A   adjaqty3 = iaqty3;
750 A   adjcqta = iacwta;
750 A   adjwhdp = iawhdp;
750 A   adjdisp = iadisp;
750 A   adjaisl = $slaisl;
750 A   adjloc = $slloc;
750 A   adjrlvl = $slrlvl;
750 A   adjhand = $slhand;
750 A   adjstat = 'A';
750 A   adjmemo = iamemo;
750 A   adjlcns = *blank;
750 A   adjaddts = %timestamp();
750 A   adjadduc = %timestamp();
750 A   adjaddcpgm = #prog;
750 A   adjaddjpgm = #prog;
750 A   adjaddemp = *zero;
750 A   adjaddcusr = #user;
750 A   adjaddjusr = #user;
750 A   adjaddjob = #job;
750 A   adjaddnbr = #jobn;
750 A   adjexpflag = *blank;
750 A   adjdrislot = *blanks;
750 A   adjdrilic = *blanks;
750 A
750 A   write adjrec;
750 A
750 A  endsr;  // wrtlicadj
750 A /end-free

     *----------------------------------------------------------------
     *  ZZUPD2   Update record.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      warn = *off

     *   Create work order
650aA*    Create one Work Order Header and any Repack Slots required
650aA*    per the parent list assocaited with the repack item

510aAC                   call      'CRTWRKORD'
510aAC                   parm      '*CRTWRKORD'  $rcmd
510aAC                   parm      $pwhse        $rwhse
510aAC                   parm      w2item        $ritem
510aAC                   parm      w2qty         $rqty
510aAC                   parm      'M'           $rby
510aAC                   parm      w2ref         $rref
510aAC                   parm      ' '           $rrtn
510aAC                   parm      ' '           $rmsg
510aAC                   parm      0             $rord
510aAC                   parm      w2ndtc        $rndtc

     C                   if        $rrtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      errmsg = $rmsg
     C                   exsr      zm0105
     C                   goto      endup2
     C                   endif

     *   Move key values to parameters

     C                   eval      $pitem = w2item
     C                   eval      $pord  = $rord
     C                   eval      $pndt  = $rndtc

610dA*   Bypass replenishment if Parent pick slot has 0 qty avail.
650aDC*                  if        bypassrepl = *on
650aDC*                  if        bypassrepl = *on
650aDC*                  eval      bypassrepl = *off
650aDC*                  eval      bypassrepl = *off
650aDC*                  goto      endup2
650aDC*                  goto      endup2
650aDC*                  endif
650aDC*                  endif

650gA* Create Priority Replenishment for ODR Items only
650gA* Work Order replenishments are created in CRTWRKORD
650gA /free
650gA                    WstPtr = %lookup(w2item:#parentititem);
650gA  //should never happen, but just in case to prevent hard error
650gA                      if WstPtr = 0;
650gA                       wstPtr = 1;
650gA                      endif;
650gA
                       if #parentsldisp(wstPtr)<>' '
650gA                      and %subst($sldisp:1:3)<>'RPK'
700aA                      and #repackkirptp <> '1';
650gA                      exsr zzopnWOQty;
650gA                      chain(n) (#parentitwhse(wstPtr):
650gA                                #repackititem:
650gA                                #parentititem(wstPtr)) kitcomp;
650gA                      if        not %found;
650gA                         kcqty1 = 0;
650gA                         kcqty2 = 0;
650gA                         kcqty3 = 0;
650gA                      endif;
650gA                      select;
650gA                      when #parentitumq3(wstptr)<>0;
650gA                      adjQty1 = 0;
650gA                      adjQty2 = 0;
650gA                      adjQty3 = woopnqty;
650gA                      when #parentitumq2(wstptr)<>0;
650gA                      adjQty1 = 0;
650gA                      adjQty2 = woopnqty;
650gA                      adjQty3 = 0;
650gA                      other;
650gA                      adjQty1 = woopnqty;
650gA                      adjQty2 = 0;
650gA                      adjQty3 = 0;
650gA                      endsl;
650gA                      exsr zzodrReplen;
                       endif;
650gA  /end-free
510aA* Create Priority Replenishment to move parent qty to repack area

650aA*  Loop through each parent item associated to the repack item
650aA
650aDC*    keykc2        setll     kitcomp
650aDC*                  dow       forever = forever
650aDC*    keykc2        reade(e)  kitcomp
650aDC*                  if        %eof
650aDC*                  leave
650aDC*                  endif

650aDC*                  exsr      clr$prtyrpl
510aA
510aA*
510aA*    Retrieve FS-WMS replenishment options.
510aA*
650aDC*                  eval      kycode = '*REPLEN '
650aDC*    keyop         chain     options                            79
650aDC*                  select
650aDC*                  when      *in79
650aDC*                  eval      opoqrp = 'N'
650aDC*                  when      not *in79
650aDC*                  eval      opdat2 = opdata
650aDC*                  endsl
650aD*
650aDC*                  move      $pwhse        $twhse            3
650aDc*                  eval      $twhdp = #repackitwhdp
650aDc*                  eval      $twhdp = #parentitwhdp(wstptr)
650aDc*                  eval      $tpitm = #repackitmitem
650aDc*                  eval      $tpitm = #parentititem(wstptr)
650aDC*                  call      'LT110E'
650aDC*                  parm                    $twhse
650aDC*                  parm                    $twhdp            5
650aDC*                  parm      oprplb        $tplb             8
650aDC*                  parm                    $tpitm           15
650aDC*                  parm                    $trtn             8

650aAD*                  enddo

     C     endup2        endsr

530 A*---------------------------------------------------------------
530 A*
530 A*  zzurcvSlot   Put license into RCV slot
530 A*
530 AC     zzurcvSlot    begsr

530 AC                   if        w2edt <> *zeros
530 AC     *mdy          move      w2edt         mdy
530 AC                   move      mdy           iso
530 AC                   move      iso           $pexpd
530 AC                   endif
530 AC                   move      today         $pindt

     *  Get batch number for labels.

     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat

     *  Get transaction number.

     C                   call      'PIRTRN#'
     C                   parm                    pttrn#

     *  Create label record for Normal qty.

     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = #repackitwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = *zeros
     C                   eval      lbrlvl = *zeros
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = *zeros
     C                   eval      lbstyp = *blanks
     C                   eval      lbqryf = *zeros
     C                   eval      lbdisp = *blanks
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = #repackititem
     C                   eval      lbseq = *zeros
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbord = $pord
     C                   eval      lbqalc = w1made
     C                   eval      lbqpck = w1made
     C                   eval      lbtie = *zeros
     C                   eval      lbhigh = *zeros

     *        Create label record for Normal qty.

     C                   eval      lbutyp = 'N'
650aAC                   eval      lbucod = #repackitum1
650aAC                   eval      lbucub = #repackitcube
     C     lbucub        mult      w1made        lbcube
650aAC                   eval      lbuwgt = #repackitswgt
     C     lbuwgt        mult      w1made        lbswgt
     *
     C                   eval      lbtrn# = pttrn#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbgrp1 = 'K'
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'

     *  Get live status for item's department.

650aAc                   eval      $twhdp = #repackitwhdp
     C                   call      'CHKLIVE'
640aAC                   parm      $pwhse        $iwhse            3 0
     C                   parm                    $twhdp            5
     C                   parm                    livestat

     *    If dept not live, then set status to Closed.

     C                   if        livestat = '*NOTLIVE'
     C                   eval      lbstat = 'C'
     C                   endif

     C                   eval      lbsdte = curdate
     C                   time                    lbstim
     C                   eval      lbrdte = curdate
     C                   if        w1xdk = 'Y'
650aAC                   eval      lbaisl = #repackslaisl
650aAC                   eval      lbloc = #repackslloc
650aAC                   eval      lbrlvl = #repackslrlvl
650aAC                   eval      lbhand = #repackslhand
650aAC                   eval      lbpseq = #repackslpseq
650aAC                   eval      lbstyp = #repackslstyp
650aAC                   eval      lbdisp = #repacksldisp
     C                   eval      lbdsp2 = *blanks
     C                   eval      lbasl2 = 'XDK'
     C                   endif
     C                   write     lbrec

     *  Only do update for live departments.

     C                   if        livestat <> '*LIVE'
     C                   exsr      clr$slot
     C                   leavesr
     C                   endif

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'REPACK'

     C                   exsr      clr$slot
610 AC                   eval      $saemp#u = *on
610 AC                   eval      $saemp# = $emp#
     C                   eval      $slwhseu = *on
650aAC                   eval      $slwhse  = #repackslwhse
     C                   eval      $slwhdpu = *on
650aAC                   eval      $slwhdp  = #repackslwhdp
     C                   eval      $slitemu = *on
650aAC                   eval      $slitem  = #repackititem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
650aAC                   eval      $slstyp = #repackitstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
650aAC                   eval      $saitem  = #repackititem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = w1made
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
     C                   when      w1umt = 'N'
     C                   eval      $saqty1 = w1made
     C                   when      w1umt = '1'
     C                   eval      $saqty2 = w1made
     C                   when      w1umt = '2'
     C                   eval      $saqty3 = w1made
     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RPK'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = pSavToLcns
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = w1lic
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = pSavOLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmsflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

530 AC     endurcvslot   endsr

     *----------------------------------------------------------------
     *  ZZWOUNSTART   Unstart work order.
     *----------------------------------------------------------------

     C     zzwounstart   begsr

     *   If not originally started during this instance
     *     Then leave the status alone.

     C                   if        not startFlag
     C                   goto      endunstart
     C                   endif

     *   Get kitordh record.

     C     fileky        chain(e)  record

     C                   if        not %found
     C                   goto      endunstart
     C                   endif

     *   Change status back to Open.

     C                   eval      kohsta = '1'
     C                   eval      kohsdt = 0
     C                   eval      kohstm = 0
     C                   update    record

     C     endunstart    endsr

650cA*----------------------------------------------------------------
650cA*  ZZUPQTY       Up quantity
650cA*----------------------------------------------------------------
650cA
650cAC     zzupqty       begsr


650cAC                   dow       #parentitumq3(wstPtr) > 0 and +
650cAC                               $saqty3 >= #parentitumq3(wstPtr)
650cAC                   eval      $saqty3 -= #parentitumq3(wstPtr)
650cAC                   eval      $saqty2 += 1
650cAC                   enddo

650cAC                   dow       #parentitumq2(wstPtr) > 0 and +
650cAC                               $saqty2 >= #parentitumq2(wstPtr)
650cAC                   eval      $saqty2 -= #parentitumq2(wstPtr)
650cAc                   eval      $saqty1 += 1
650cAC                   enddo

650cAC                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
      *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

530 D*----------------------------------------------------------------
530 D*  clr$lichist  Clear $lichist data structure fields
530 D*----------------------------------------------------------------

530 D ***  clr$lichist   begsr
530 D ***                eval      savever# = $lrver#
530 D ***                clear                   $lichist
530 D ***                eval      $lrver# = savever#
530 D ***                eval      $lremp# = $emp#
530 D ***                eval      $lruser = #user
530 D ***                eval      $lrpgm  = #prog
530 D ***                eval      $lrjob  = #job
530 D ***                eval      $lrjobn = #jobn
530 D ***                eval      $lrwhse = $pwhse
530 D ***                eval      $lrwhseu = *on
530 D ***                endsr

510bA*----------------------------------------------------------------
510bA*  clr$licinfo  Clear $licinfo data structure fields
510bA*----------------------------------------------------------------

510bAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
530 AC                   eval      $lnemp# = $emp#
650aDC*                  eval      $lnpgm  = #pgm
650aAC                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
650aDC*                  eval      $lnjobnbr = #jobnbr
650aAC                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  clr$itemqty  Clear $itemqty data structure fields
     *----------------------------------------------------------------

     C     clr$itemqty   begsr
     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#
     C                   endsr

510aA*----------------------------------------------------------------
510aA*  clr$prtyrpl  Clear $prtyrpl data structure fields
510aA*----------------------------------------------------------------
510aA
510aAC     clr$prtyrpl   begsr
510aAC                   eval      savever# = $prver#
510aAC                   clear                   $prtyrpl
510aAC                   eval      $prver# = savever#
510aAC                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*ITEMQTY'
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

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $dridata = $itemqty
510aAC                   when      $dricommand = '*PRTYRPL'
510aAC                   eval      $dridata = $prtyrpl
530 AC                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   endsl

510aAC                   select
510aMC                   when      $dricommand = '*ITEM'
530 AC                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
650aDC*                  parm      #pgm          $driprogram
650aAC                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
510aAC                   when      $dricommand = '*PRTYRPL'
510aAC                   call(e)   'DRICOP'
510aAC                   parm                    $dricommand
510aAC                   parm                    $drisubcmd
510aAC                   parm                    $drisys2upd
510aAC                   parm                    $driprogram
510aAC                   parm      ' '           $drireturn
510aAC                   parm      ' '           $drimessage
510aAC                   parm                    $dridata
510aAC                   parm                    $dridata2
510aMC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
650aDC*                  parm      #pgm          $driprogram
650aAC                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
510aMC                   endsl

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
650aDC*                                      + ' from ' + #pgm
650aAC                                       + ' from ' + #prog
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
     C***                exsr      zm0001
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
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $itemqty = $dridata
510aAC                   when      $dricommand = '*PRTYRPL'
510aAC                   eval      $prtyrpl = $dridata
530 AC                   when      $dricommand = '*LICINFO'
530 AC                   eval      $licinfo = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     endPRTYRPL    endsr
