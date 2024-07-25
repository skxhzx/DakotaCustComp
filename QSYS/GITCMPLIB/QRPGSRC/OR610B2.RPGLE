      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR610B2   Truck build - Select orders - Batch pick items only
     *  October 7, 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
520 A*    08/11/09  JCJ  5.20
     *      -  Created from OR610
530 A*    02/23/10  JCJ  5.30
     *      -  removed client code around open or ORDDM.
     *
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
     *      - Revised to ignore special license tracking slots,
     *        which are identified with SLDESG = 'BFC'.
610aA*    02/23/10  DAS  6.10a
     *      - Added custom Dierks mod DRKa
     *
640 A*    07/20/11  MLB  6.40
     *      - Fix: Revised routine GETOD to move code added for batch
     *        pick processing to after item number information has been
     *        resolved. Batch pick processing was not working because
     *        field #SITEM was not being populated before routine
     *        BATCHPICK can be executed.
     *        Note: Batch pick code moved without commenting out old
     *              code for clarity. Any new code commented with new id.
     *
640aA*    10/02/12  JCJ  6.40a
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *
650aA*    07/23/13  LMC  6.50a
     *      - Enh: Batch pick is not allowed on UCI/PTI selection
     *        items. Added to check for this situation.
720aA*    10/25/18  DAS  7.20a
     *      - Enh: Add fields to GETZONE call.
730aA*    12/05/19  DAS  7.30a
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dierks Waukesha
     *
DRKaA*    02/23/10  DAS  DRKa
     *      - Temp mod to force Letdowns (OPJITR = '1')
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLBaA*    08/21/11  JCJ  SLBa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas
     *
NCSaA*    10/17/11  JCJ  NCSa
     *      - Enh: Instead of looking at truck's maximum cube to build
     *        the pallet, truck builder will look at the Tie/Hi of the
     *        item.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash-Wa
     *
CWDaA*    02/27/12  JCJ  CWDa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    02/27/12  JCJ  CTWa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly Foods
     *
KFS A*    10/02/12  MLB  KFS
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *      - Added KFS to SLBa mod.
     *
640aA*----------------------------------------------------------------
640aA*  Batch Pick Notes
     *
     *    - A Batch Pick is similar to a Bulk Pick, where we grab qty
     *      from overflow slots until the remaining cube does not
     *      meet the minimum cube criteria.
     *    - An order detail line will only have its status changed
     *      if its entire qty has been allocated.
     *    - OR610 has been revised to get any allocated qty from the
     *      WORKLBL file for Batch Pick items.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
530 A*  75        Record lock error on SLOT3
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640aAFordh      uf   e           k disk
     Fordh2     uf   e           k disk
640aAF                                     rename(ohrec:ohrec1)
640aAFordd      uf   e           k disk
640aDF*rdd1     uf   e           k disk
640aMFordd1     if   e           k disk
640aAF                                     rename(odrec:odrec1)
640aDF*rddm     if   e           k disk    usropn
640aMForddm     if   e           k disk
     Fslot3     uf   e           k disk
     Fpiritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Fitemdef1  if   e           k disk
     Fitemmsc   if   e           k disk
     Foptionz   if   e           k disk
     Foptions   if   e           k disk
     Ftruckh    if   e           k disk
     Fslot2     if   e           k disk
     F                                     rename(slrec:slrec2)
     Fordbsum   uf a e           k disk
     Fordbsum1  uf   e           k disk    rename(bprec:bprec1)
640aAFordbdtl   uf a e           k disk
     Fcrossdk1  if   e           k disk
     Fpirtrck2  o    e             disk
     Fworklbl   o  a e           k disk
     For610pr   o    e             printer oflind(*in90)
     F                                     usropn
730aAFbfcdebug  o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
     D a80             s              1    dim(80)
     D msg             s             40    dim(5) ctdata perrcd(1)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#CITYLIN
      /COPY QCOPYSRC,ID#USFCRP
      /COPY QCOPYSRC,ID#MJKELLN
      /COPY QCOPYSRC,ID#VIP
      /COPY QCOPYSRC,ID#PACKERS
      /COPY QCOPYSRC,ID#SGC
      /COPY QCOPYSRC,ID#SAVAL
DRKaA /copy qcopysrc,id#dierks
      /COPY QCOPYSRC,ID#MATT
      /COPY QCOPYSRC,ORDDM1_MAT
SLBaA /copy qcopysrc,id#silberm
NCSaA /copy qcopysrc,id#nichola
CWDaA /copy qcopysrc,id#cashwa
CTWaA /copy qcopysrc,id#citywho
KKFS  /copy qcopysrc,id#kfs
SGC1A*
SGC1A*----------------------------------------------------------------
SGC1A*
SGC1A /COPY QCOPYSRC,orddm1_sgc
SGC1A*
SGC1A*
     *
     *----------------------------------------------------------------
     *  Tie/High definitions data structure.
     *
     D defs            ds                  occurs(9)
     D  dssdef                 1      2
     D  dstie                  3      6  0
     D  dshigh                 7      8  0
     D  dsqmax                 9     15  0
     D  dsqmin                16     22  0
     D  dsmtch                23     23
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     D                 DS
     D  HCMPN                  1      3
     D  HDIVN                  4      6
     D  HDPTN                  7      9
     D  HWHSN                 10     12
     D  OHMISC                 1     20
     D*
     D vip999          c                   const('9999999999')
      /copy qcopysrc,orddm1_svl
     D vipms1          ds
     D  ommsc1                 1     40
     D  ompckm                 1      4  0
     D  omwhdp                 5      9
     D  omvpsz                10     24
     D  omiaov                25     25
     D  omsltn                26     32
     D  omcwcd                33     33
     D  omwtiw                34     37p 2
     D  omcbec                38     40p 3
     *
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximu orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTORD  -  Maximum orders per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opzdta          ds
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
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D  opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opdend               117    117
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *    OPJITR  -  Create JIT Letdown or JIT Replenishment
     *                 0=None. No replenishments are created.
     *                 1=Letdowns are created during Truck Builder
     *                   Pick/Print processing.
     *                 2=Priority Replenishments are created during
     *                   Truck Builder Pick/Print processing.
     *                 3=JIT Letdowns created when transaction is
     *                   checked out.
     *                 4=JIT Priority Replenishments created when
     *                   transaction is checked out.
     *
     * Data structure
     *
     D opdta1          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
     D  opjitr                12     12
     D  optend               117    117
     D opdta2          ds
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
     *----------------------------------------------------------------
     *
     * The following data structures are for capturing picking
     * tracking info.
     *
     *----------------------------------------------------------------
     *  *PCK001   -  Picking Batch detail info
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRPCMD  -  Program processing option
     *    TRPPRG  -  Calling program
     *    TROTYP  -  Order type
     *    TRRORD  -  Restart order number
     *    TRPKST  -  Picking status
     *    TRFLPK  -  Picking options error flag (0=Rcd found, 1=Missing)
     *    TRFLTK  -  Truck options error flag (0=Rcd found, 1=Missing)
     *
     * Data structure
     *
     D tr01ds          ds
     D  trpcmd                 1      8
     D  trprg                  9     18
     D  trotyp                19     19
     D  trrord                20     26  0
     D  trpkst                27     46
     D  trflpk                47     47
     D  trfltk                48     48
     D  trdt01                 1    150
     *----------------------------------------------------------------
     *  *PCK002  -  General Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    Note: See general picking options definition.
     *
     * Data structure
     *
     D tr02ds          ds
     D  trdt02                 1    150
     *----------------------------------------------------------------
     *  *PCK003  -  Truck Header info
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRROWS -  Row in trailer
     *    TRCOLS -  Column in trailer
     *    TRBULK -  Allow bulk picks (Y/N)
     *    TRBAT  -  Allow batch picks (Y/N)
     *
     * Data structure
     *
     D tr03ds          ds
     D  trrows                 1      2  0
     D  trcols                 3      3  0
     D  trbulk                 4      4
     D  trbat                  5      5
     D  trdt03                 1    150
     *----------------------------------------------------------------
     *  *PCK010  -  Zone pick options definition.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRZONE  -  Picking zone
     *    TRDT10  -  See defintion for zone pick options.
     *
     * Data structure
     *
     D tr10ds          ds
     D  trzone                 1     10
     D  trdt10                11    150
     *----------------------------------------------------------------
     *  *PCK040  -  Subroutines entered
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRSUBR  -  Subroutines entered.
     *
     * Data structure
     *
     D tr40ds          ds
     D  trr                    1    150
     D                                     DIM(25)
     D  trrfld                 1    150
     *----------------------------------------------------------------
     *  *PCK050  -  Tracking message(s)
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TRSR50  -  Subroutine sending message
     *    TRDT50  -  Tracking message(s)
     *
     * Data structure
     *
     D tr50ds          ds
     D  trsr50                 1     10
     D  trdt50                11    150
     *----------------------------------------------------------------
     *  Tracking messages
     *----------------------------------------------------------------
     D tr05            c                   const('QtyOrd:')
     D tr06            c                   const('QtyAlc:')
     D tr07            c                   const('QtyPck:')
     D tr08            c                   const('ExpDate:')
     D tr09            c                   const('Slot bypassed: Produ-
     D                                     ct has expired.')
     D tr10            c                   const('Slot bypassed: No pr-
     D                                     oduct in slot.')
     D tr11            c                   const('Slot bypassed: No pr-
     D                                     oduct available in s-
     D                                     lot.')
     D tr12            c                   const('Warehouse allocation-
     D                                      completed with no e-
     D                                     rrors.')
     D tr13            c                   const('Warehouse allocation-
     D                                      complete with at le-
     D                                     ast one allocation e-
     D                                     xception.')
     D tr14            c                   const('No overflow slots me-
     D                                     t bulk pick criteria-
     D                                     .')
     D tr15            c                   const('Qty remaining not en-
     D                                     ough for bulk pick:')
     D tr16            c                   const('Slot bypassed: Short-
     D                                      qty for bulk pick.')
     D tr17            c                   const('No tie/high availabl-
     D                                     e. Available qty is -
     D                                     one full pallet.')
     D tr18            c                   const('Bulk pick created.')
     D tr19            c                   const('Looking for qty to b-
     D                                     ulk pick.')
     D tr20            c                   const('Key:')
     D tr21            c                   const('QtyAvail:')
     D tr22            c                   const('QtyPicked:')
     D tr23            c                   const('Ck slots w/same date')
     *  Allocation status messages.
     D trerfl          c                   const('*NOTFOUND')
     D tr80            c                   const('Allocated           ')
     D tr81            c                   const('Allocation error    ')
     *----------------------------------------------------------------
     D                 ds
     D  wkoitm                 1     15
     D  wkaisl                 1      3
     D  wkdsh1                 4      4
     D  wkloc                  5      7  0
     D  wkdsh2                 8      8
     D  wkrlvl                 9     10  0
     D  wkhand                11     12
     D  wkbulk                15     15
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getsi          c                   const('GETSLOTITM')
     D @cvtdt          c                   const('CVTDTE')
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
650aA*----------------------------------------------------------------
650aA*  DRI parameters
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#DRIPARMS
650aA
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#ITEM

650aAD savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Program info data structure
     *
650aA /COPY *libl/qcopysrc,C#PGMINFDS
650aDD*               sds
650aDD* #prog            *proc
650aDD* #job                 244    253
650aDD* #user                254    263
650aDD* #jobn                264    269
650aDD* #jobdt               276    281  0
650aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D #dbpck                         3  0
     D $msgf           s             10
     D #bitem          s                   like(ititem)
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #sitem          s                   like(ititem)
640aAD batchID         s              3  0
     D blkpct          s                   like(#dbpck)
640aAD bpdRecFound     s               n
     D bppass          s              1  0
     D c#cube          s                   like(itcube)
650aAD chk4err         s               n
     D cvt1a           s              1
     D cvt5a           s              5
     D cvt8a           s              8
     D diffq1          s                   like(odqor1)
     D diffq2          s                   like(odqor2)
     D diffq3          s                   like(odqor3)
     D dscln           s             80
     D eofod           s              1
     D eofoh           s              1
650aAD error           s              1
     D excpq1          s              5  0
     D excpq2          s              5  0
     D excpq3          s              5  0
     D flgpck          s              1
     D flgtrk          s              1
     D forevr          s              1
640aAD forever         s               n
     D found           s              1
     D hmaisl          s                   like(slaisl)
     D hmdisp          s                   like(sldisp)
     D hmhand          s                   like(slhand)
     D hmloc           s                   like(slloc)
     D hmrlvl          s                   like(slrlvl)
     D hmstyp          s                   like(slstyp)
     D hmwhdp          s                   like(slwhdp)
     D hmwhse          s                   like(slwhse)
640aAD itemFound       s               n
640aAD kyitem          s                   like(ititem)
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opzcod)
     D kyentd          s                   like(slentd)
     D kyexpd          s                   like(slexpd)
     D kyhand          s                   like(slhand)
     D kyopen          s              1
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D kypseq          s                   like(slpseq)
     D kyrlvl          s                   like(slrlvl)
     D kyslvp          s                   like(sldisp)
     D kystat          s                   like(slstat)
     D kystyp          s                   like(slstyp)
     D kyum            s                   like(idum)
     D kywhdp          s                   like(slwhdp)
640aAD lastOrd         s                   like(ohord)
640aAD lblLeft1        s              5  0
     D leftq1          s              5  0
     D leftq2          s              5  0
     D leftq3          s              5  0
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstopt          s              2  0
     D lstqty          s                   like(odqor1)
     D lstwhs          s                   like($whse)
     D lwlas2          s              3
     D lwlqav          s              5  0
     D lwltyp          s              1
     D mjkcon          s              1
     D mjkpir          s              1
640aAD newItem         s               n
     D nonalc          s              1
     D ocode           s              8
     D odflag          s              1
640aAD odLeft1         s              5  0
     D ohflag          s              1
     D opened          s              1
     D opndm           s              1
640aAD oslotFound      s               n
     D pckall          s              1
     D pckcnt          s              3  0
     D pickq1          s              5  0
     D pickq2          s              5  0
     D pickq3          s              5  0
     D picku1          s              5  0
     D picku2          s              5  0
     D picku3          s              5  0
     D prflag          s              1
     D qtylft          s                   like(odqor1)
     D r               s              3  0
640aAD recCreated      s               n
     D remain          s              5  0
     D savdisp         s                   like(sldisp)
     D s#cube          s                   like(itcube)
     D sgcbulk         s              1    inz('0')
     D stop            s              1
     D svaisl          s                   like(slaisl)
     D svavl1          s                   like(avail1)
     D svavl2          s                   like(avail2)
     D svavl3          s                   like(avail3)
     D svdisp          s                   like(sldisp)
     D svhand          s                   like(slhand)
     D svloc           s                   like(slloc)
     D svpseq          s                   like(slpseq)
     D svqty2          s              5  0
     D svrlvl          s                   like(slrlvl)
     D svrtq1          s                   like($artq1)
     D svrtq2          s                   like($artq2)
     D svrtq3          s                   like($artq3)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
     D temp2a          s              2
     D temp30          s             30
     D tmavl1          s                   like(avail1)
     D tmavl2          s                   like(avail2)
     D tmavl3          s                   like(avail3)
     D tmpflg          s              1
     D today           s              8  0
     D topick          s                   like(odqor1)
     D trerr           s              1
     D tried           s              1
     D trkey           s             10
     D trnbr           s              4
     D trsq10          s              3  0
     D trsq40          s              3  0
     D trsq50          s              3  0
     D trsubr          s              6
     D ttlpk1          s              5  0
     D ttlpk2          s              5  0
     D ttlpk3          s              5  0
     D updflg          s             10
     D uxflag          s              1
     D xopt            s              2  0
     D i               s              3  0
650aAD zmflag          s               n
650aAD zmsflag         s               n
     D ztype           s              1
     D batchpickflag   s              1
     D $ptmpl          s             10
730aAD pNextLbl#       s             11  0
730aAd nextLbl#        s                   like(lwlbl#)

730aA*----------------------------------------------------------------
730aA*  Prototypes
730aA*----------------------------------------------------------------
730aA
730aA /copy qcopysrc,p.pirlbl#w
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PICK    - Picking new orders.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PPRG   Program to send messages back to.
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PRTE   Route
     *      $PORD   Order
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $pord             7 0
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     C                   eval      $prtn = *blanks
     *
     *   Set MJK Contract flag.
640aA*    - For these, get out and let OR610 handle them.
     *
     C                   eval      mjkcon = *off
     C                   if        client = mjkeln
     C     KEYOH2        SETLL     ORDH2
     C     KEYOH2        READE(N)  ORDH2                                  79
     C                   if        hdivn = '  1'
     C                   eval      mjkcon = *on
640aAC                   goto      bottom
     C                   endif
     C                   endif
     *
     *  The program will execute CRTLBL only if UPDFLG is set to
     *  '*NOUPDAT'.  This flag should be custom set if the client
     *  wants to use truck builder without allocating qty on BFC side.
640aA*    - For these, get out and let OR610 handle them.
     *
     C                   eval      updflg = *blanks
     C                   if        updflg = '*NOUPDAT'
640aAC                   goto      bottom
     C                   endif
     *
     * Build ordbsum file
     *
     C                   exsr      ordbsumbuild
640aAC                   if        not recCreated
640aAC                   goto      bottom
640aAC                   endif
640aDC**                 if        i = 99
640aDC**                 goto      endpgm
640aDC**                 endif
     *
     * Open printer
     *
     C                   exsr      opnprt
640aA
640aA* Loop through ORDBSUM file.
640aA
640aAC                   eval      batchID = 99
640aAC     keybp1        setll     ordbsum
640aA
640aAC                   dow       forever = forever
640aA
640aAC     keybp1        reade     ordbsum
640aAC                   if        %eof(ordbsum)
640aAC                   leave
640aAC                   endif
640aA
640aA*   Get item info
640aA
640aAC                   eval      kyitem = bpitem
640aAC                   exsr      getItem
640aAC                   if        not itemFound
640aAC                   iter
640aAC                   endif
640aA
640aA*   Get an overflow slot for the item.
640aA
640aAC                   exsr      getoslot
640aAC                   if        not oslotFound
640aAC                   iter
640aAC                   endif
640aA
640aA*   Get batch zone for item.
640aA
640aAC                   eval      ztype = 'B'
640aAC                   exsr      getopt
640aA
640aA*   If batch zone not found, get next item.
640aA
640aAC                   if        opptyp <> 'B'
640aAC                   iter
640aAC                   endif
640aA
640aA*   See if total cube meets Batch pick criteria.
640aA
NCSaAC                   select
NCSaAC                   when      client = nicholas
NCSaAC                   eval      dsqmax = 0
NCSaA ***  keyim         chain     itemmsc
NCSaA ***                if        not %found(itemmsc)
NCSaA ***                eval      imtie = *zeros
NCSaA ***                eval      imhigh = *zeros
NCSaA ***                eval      dsqmax = opbpck
NCSaA ***                else
NCSaA ***                eval      dsqmax = imtie * imhigh
NCSaA ***                if        bpcube < dsqmax
NCSaA ***                iter
NCSaM ***                endif
NCSaA ***                endif
NCSaMC                   when      bpcube < opbpck
640aAC                   iter
NCSaMC                   endsl
640aA
640aA*   Do batch pick.
640aA
640aAC                   eval      newItem = *on
640aAC                   eval      blkpct = #dbpck
640aAC                   exsr      BatchPick
640aA
640aAC                   enddo
     *
     *
     * Close up shop and return home.
     *
     C                   if        prflag = *on
     C                   write     foot1
     C                   endif

640aAC     bottom        tag
     *
     *  Write out completion message.
     *
     C                   select
     C                   when      $pcmd <> '*OPEN'
     C                   if        trerr = *on
     C                   eval      trnbr = 'TR13'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'MAINLN  '    trsr50
     C                   exsr      zztrck
     C                   else
     C                   eval      trnbr = 'TR12'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'MAINLN  '    trsr50
     C                   exsr      zztrck
     C                   endif
     *
     *  Write out tracking record, force out contents of array.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'EXIT    '    trsubr
     C                   eval      r = 32
     C                   exsr      zztrck
     *
     *    Write out tracking record *PCK001.
     *
     C                   eval      trcode = '*PCK001 '
     C                   exsr      zztrck
     C                   endsl
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
     *
     *  Initialize tracking key.
     *
     C                   eval      trwhse = $pwhse
     C                   movel(p)  #prog         trpgm
     C                   eval      trjbnr = #jobn
     C                   eval      $cvcmd = '*MDYCMD '
650aDC*                  move      #jobdt        $cvd6i
650aMC                   move      #jobdate      $cvd6i
     C                   eval      $cvd8o = *zeros
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      trjbdt = $cvd8o
650aDC*                  eval      trjbtm = #jobtm
650aMC                   eval      trjbtm = #jobtime
     C                   eval      trdev = #job
     C                   eval      truser = #user
     C                   eval      trtruk = $ptruk
     C                   eval      trrte = $prte
     C                   eval      trrtid = $prtid
     C                   eval      trpbat = $pbat
     C                   eval      r = *zeros
     C                   eval      trsubr = *blanks
     C                   eval      trkey = *blanks
     C                   eval      trrfld = *blanks
     C                   eval      trsq10 = *zeros
     C                   eval      trsq40 = *zeros
     C                   eval      trsq50 = *zeros
     C                   eval      trnbr = *blanks
     C                   eval      cvt1a = *blanks
     C                   eval      cvt5a = *blanks
     C                   eval      cvt8a = *blanks
     C                   eval      trkey = *blanks
     C                   eval      trerr = *off
     C                   eval      flgpck = *off
     C                   eval      flgtrk = *off
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     '*INZSR  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      kyopen = 'O'
     *
     *  Define save fields for different item types.
     *
     C                   eval      #otype = *blanks
     *
     *  Define key for CROSSDK1 file.
     *
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     *     EXTENDED ITEM DESCRIPTION
     *
     C     idkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     *
     C     keycd1        klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
640aA*
640aA*  Define key for ORDH file.
640aA*
640aAC     keyoh         klist
640aAC                   kfld                    bpdwhs
640aAC                   kfld                    bpdord
     *
     *  Define partial key for ORDH2 file.
     *
     C     keyoh2        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyopen
     C                   kfld                    $potyp
     C                   kfld                    $prtid
640aA*
640aA*  Define key for ORDD file.
640aA*
640aAC     keyod         klist
640aAC                   kfld                    bpdwhs
640aAC                   kfld                    bpdord
640aAC                   kfld                    bpdseq
640aAC                   kfld                    bpditm
     *
     *  Define partial key for ORDD1 file.
     *
     C     keyod1        klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C                   kfld                    kyopen
640aA*
640aA*  Define partial key for ORDBDTL file
640aA*
640aAC     keybpd        klist
640aAC                   kfld                    bpwhse
640aAC                   kfld                    bprte
640aAC                   kfld                    bpitem
     *
     *  Define partial key for ORDDM file.
     *
     C     keyom         klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
640AMC                   kfld                    kyitem
640aDC**                 kfld                    oditem
     *
     *  Define partial key for ITEMDEF1 file.
     *
     C     keyid1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oditem
     C                   kfld                    kyum
     C                   eval      kyum = 'N'
     *
     *  Define key for ITEMDEF1 file.
     *
     C     keydef        klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     C                   kfld                    kyum
     C                   kfld                    slsdef
     *
     *  Define key for SLOT2 file.
     *
     C     keysl2        klist
     C                   kfld                    cdwhse
     C                   kfld                    cdwhdp
     C                   kfld                    cdslot
     *
     C     vipsl2        klist
     C                   kfld                    omwhse
     C                   kfld                    omwhdp
     C                   kfld                    kyslvp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define partial key for SLOT3 file including dates.
     *
     C     keys3b        klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     *
     *  Define full key for SLOT3 file.
     *
     C     keys3c        klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     C                   kfld                    kywhdp
     C                   kfld                    kystyp
     C                   kfld                    kyaisl
     C                   kfld                    kypseq
     C                   kfld                    kyrlvl
     C                   kfld                    kyhand
     *
     *  Define partial key for SLOT3 file for special orders.
     *
     C     keyspc        klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     C                   kfld                    kystat
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
530aA ***                kfld                    $ptruk
530aAC                   kfld                    $ptmpl
     *
     *  Define key for truck file.
     *
     C     keyth         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
     *  Define key for zone detail search file.
     *
     C     keyzd2        klist
     C                   kfld                    $pwhse
530aA ***                kfld                    $ptruk
530aAC                   kfld                    $ptmpl
530aAC                   kfld                    itwhdp
     *
     *  Define key for ITEMMSC file.
     *
     C     keyim         klist
     C                   kfld                    $pwhse
     C                   kfld                    #sitem
     *
     *  Define full key for ORDBSUM file.
     *
     C     keybp         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    oditem
     *
     *  Define full key for ORDBSUM1 file.
     *
     C     keybp1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     C                   eval      pckcnt = 0
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Create report heading.
     *
     *    Start with batch number ...
     *
     C                   time                    time
     C                   move      $pbat         temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd             8
     C                   parm                    temp30
     C     'BATCH:'      cat       temp30:1      hedln2
     *
     *    Then add warehouse ...
     *
     C     hedln2        cat       'WARE':2      hedln2
     C     hedln2        cat       'HOUSE:':0    hedln2
     C                   eval      temp30 = *blanks
     C                   move      $pwhse        temp30
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $acmd
     C                   parm                    temp30
     C     hedln2        cat       temp30:1      hedln2
     *
     *    Finish with route.
     *
     C     hedln2        cat       'ROUTE:':2    hedln2
     C     hedln2        cat       $prte:1       hedln2
     *
     *    Center it so it will look pretty.
     *
     C                   call      'CENTER'
     C                   parm                    hedln2
     C                   parm      60            $clen             3 0
     *
     *    Get general picking options from options file.
     *
     C                   eval      opcode = '*GENPICK'
     C     keyop         chain     options                            79
     C                   eval      opdta1 = opdata
     C                   if        *in79
     C                   eval      operpt = 'Y'
     C                   eval      opelbl = 'N'
     C                   eval      ophpwc = 'N'
     C                   eval      opjitr = '2'
     C                   eval      flgpck = *on
     C                   endif
     *
     *    Get truck information.
     *
     C     keyth         chain     truckh                             79
     C                   if        *in79
     C                   eval      thbulk = 'N'
     C                   eval      flgtrk = *on
     C                   endif
530aAC                   if        %found(truckh)
530aAC                             and thtype = 'T'
530aAC                   eval      $ptmpl = thztmp
530aAC                   else
530aAC                   eval      $ptmpl = $ptruk
530aAC                   endif
     *
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK002 '
     C                   exsr      zztrck
     C                   eval      trcode = '*PCK003 '
     C                   exsr      zztrck
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  clr$item  Clear $item data structure fields
650aA*----------------------------------------------------------------

650aAC     clr$item      begsr
650aAC                   eval      savever# = $itver#
650aAC                   clear                   $item
650aAC                   clear                   $item2
650aAC                   eval      $itver# = savever#
650aAC                   endsr

     *----------------------------------------------------------------
     *  ForceAlloc   Force allocation from ITEMQTY.
     *----------------------------------------------------------------

     C     ForceAlloc    begsr

     C                   eval      $acmd = '*ALLOCFR'

     C                   eval      $aprg = #prog
     C                   eval      $atype = '*BATCH  '
     C                   eval      $awhse = $pwhse
     C                   if        ittype = 'A'
     C                   eval      $aitem = #sitem
     C                   else
     C                   eval      $aitem = oditem
     C                   endif
     C                   eval      $aqty1 = pickq1
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     *
     C                   call      'ADJQTY'
     C                   parm                    $acmd
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
     C                   parm                    $aerm
     *
     *   Convert allocated quantity to string for error msg.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   if        ittype = 'S'
     C                   eval      $cqty1 = $artq2
     C                   eval      $cqty2 = $artq3
     C                   eval      $cqty3 = 0
     C                   else
     C                   eval      $cqty1 = $artq1
     C                   eval      $cqty2 = $artq2
     C                   eval      $cqty3 = $artq3
     C                   endif
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
     C                   eval      p1qalc = $cqstr

     C                   endsr
     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     C     avail         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'AVAIL   '    trsubr
     C                   exsr      zztrck
     *
     *  Call program to calculate availabe slot quantities.
     *
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
     *
     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  Getoslot - Get overflow slot
     *
     C     getoslot      begsr
640aAC                   eval      oslotFound = *off
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICKRP  '    trsubr
     C                   exsr      zztrck
     *
     *   Loop through overflow slots for item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
640aMC     keysl3        reade     slot3
640aMC                   if        %eof(slot3)
     C                   leave
     C                   endif
     *
     *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
     *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
     *     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
     *
     C                   if        client = packers
     C                   if        slaisl >= ' 66'
     C                   iter
     C                   endif
     *
     C                   if        slwhdp = 'DRY  '
     C                             and slaisl >= ' 01'
     C                             and slaisl <= ' 10'
     C                   iter
     C                   endif
     C                   endif
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0
     C                             and slexpd < today
     C                             and itflgd = 'Y'
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     C                   if        avail1 > 0
640aDC**                           or avail2 > 0
640aDC**                           or avail3 > 0
640aAC                   eval      oslotFound = *on
     C                   leave
     C                   endif
     *
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *  BatchPick  Batch pick check
     *    - Based on OR610 BulkPk routine.
     *----------------------------------------------------------------

     C     batchpick     begsr

413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*PCK040 '
413aAC                   movel     'BULKPK  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     *
     C                   eval      s#cube = blkpct
MJKbA*
MJKbA*   For MJK PIR pick, run 2 passes.
SGCbA*   or  SGC Bulk picks, run 2 passes.
MJKbA*   For all other routes, only do single pass.
MJKbA*
MJKbAC     1             do        2             bppass
MJKbA*
MJKbAC                   if        mjkpir <> *on  and
MJKbAC                             bppass = 2
SGCbAC                             and client <> MJKellner
SGCbA*
SGCbAC                             and sgcbulk <> *on
SGCbAC                             and bppass = 2
SGCbAC                             and client <> SGC
SGCbA*
MJKbAC                   leave
MJKbAC                   endif
MJKbA*
     C                   eval      tmpflg = *off
640aA
640aA*   See if item has a pick slot.
640aA*     If it doesn't, we will pick everything from overflow
640aA*        regardless if it meets the minimum cube.
640aA
640aAC                   exsr      Chk4PickSlot
     *
     *   Loop while ....
     *
     *       There is quantity left to be picked
     *       And something was picked last time through.
     *
     C                   eval      lstqty = 0
640aAC                   eval      leftq1 = bpqpck
     *
     C                   dow       leftq1 <> 0  and
     C                             leftq1 <> lstqty
     *
     *   TMPFLG=*ON We did not find any slot that met bulk pick
     *              criteria.
     *
     C                   if        tmpflg = *on
413aAC                   eval      trnbr = 'TR14'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     *   Quantity left is not enough for bulk pick. Go home.
640aA*     If slot does not have a pick slot,
640aA*       Then we will ignore the minimum cube criteria.
     *
     C     leftq1        mult      itcube        c#cube
     C                   if        c#cube < s#cube
640aAC                             and pckcnt > 0
413aAC                   eval      trnbr = 'TR15'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     C                   eval      lstqty = leftq1
     *
     *     Loop through reserved slots to fulfill bulk pick.
     *
     C                   eval      kystat = 'A '
USF AC                   select
USF A*
USF A*    Look in pick slots to generate bulk pick.
USF AC                   when      client = usfcrp  or
MJKaAC                             mjkpir = *on
USF AC                   eval      kypick = 'Y'
USF A*
USF AC                   other
     C                   eval      kypick = 'N'
USF AC                   endsl
413aAC                   eval      trnbr = 'TR20'
413aAC                   eval      trkey = 'KEYSL3'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
     *
PCKd *     Ignore slot if in aisle 44 or higher.  These are off site
     *     locations.
     *
PCKe *     Ignore slot if in aisle 66 or higher.  These are off site
     *     locations.
PCKhD*     Ignore slot if in aisle 1 thru 10 for DRY department.
     *
PCKd ****       SLAISL    IFGE ' 44'
520fAC                   if        client = packers
PCKe C                   if        slaisl >= ' 66'
PCKd C                   iter
PCKd C                   endif
     *
PCKhDC*                  if        slwhdp = 'DRY  '  and
PCKhDC*                            slaisl >= ' 01'  and
PCKhDC*                            slaisl <= ' 10'
PCKhDC****               iter
PCKhDC*                  endif
520fAC                   endif
     *
     *        Ignore slot if no normal stock or past expiration date.
     *
     C                   if        slstk1 <= 0  or
     C                             slexpd <> 0  and
     C                             slexpd < today  and
413bAC                             itflgd = 'Y'
413aAC                   select
413aAC                   when      slstk1 <= 0
413aAC                   eval      trnbr = 'TR10'
413aAC                   when      slexpd <> 0  and
413aAC                             slexpd < today  and
413aAC                             itflgd = 'Y'
413aAC                   eval      trnbr = 'TR09'
413aAC                   endsl
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Calculate quantity available in slot.
     *
     C                   exsr      avail
     *
     C                   if        avail1 <= 0
413aAC                   eval      trnbr = 'TR11'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   movel     'BULKPK  '    trsr50
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Save slot information and available quantities.
     *
     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand
     *
     *     Calculate available cube.
     *
     C     avail1        mult      itcube        c#cube
     *
     *     Slot does not have enough for bulk pick.  Look for other
     *     slot with same date.
     *
     C                   eval      found = *off
     C                   if        c#cube < s#cube
640aAC                   iter
     *     This subroutine is commented out because, looking for
     *     slots with the same priority and dates ignored other
     *     valid overflow slots from being considered.
640aA ***                exsr      look4nxtslot
     *
     *     Found enough for bulk pick.  Take and run.
     *
     C                   else
     C                   eval      found = *on
     C                   endif
     *
     *   We did not find any slot that met bulk pick criteria.
     *
     C                   if        found = *off
     C                   eval      tmpflg = *on
413aAC                   eval      trnbr = 'TR14'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     *   Get "Normal" Tie/High definitions for item.
MJKcA*     For MJK PIR, if not found, use Mfr ti/hi.
     *
     C     keydef        chain     itemdef1                           77
MJKcA*
MJKcAC                   if        *in77  and
MJKcAC                             mjkpir = *on
SGCbA*
SGCbAC                             or *in77  and
SGCbAC                             sgcbulk = *on
SGCbA*
MJKcAC     keyim         chain     itemmsc                            77
MJKcAC                   if        not *in77
MJKcAC                   if        imtie = 0  and
MJKcAC                             imhigh = 0
MJKcAC                   eval      *in77 = *on
MJKcAC                   else
MJKcAC                   eval      idtie = imtie
MJKcAC                   eval      idhigh = imhigh
MJKcAC                   endif
MJKcAC                   endif
MJKcAC                   endif
MJKcA*
     C                   if        not *in77
     C     1             occur     defs
     C                   eval      dssdef = idsdef
     C                   eval      dstie = idtie
     C                   eval      dshigh = idhigh
     C                   select
     C                   when      idtie = 0
     C                   eval      dsqmax = idhigh
     C                   when      idhigh = 0
     C                   eval      dsqmax = idtie
     C                   other
     C                   eval      dsqmax = idtie * idhigh
     C                   endsl
     C                   if        avail1 < dsqmax  or
520dAC                             dsqmax <= 0
MJKbA*            For MJK PIR, we only want full pallets for pass 1.
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1
SGCbA*
SGCbAC                             or sgcbulk = *on  and
SGCbAC                             bppass = 1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
     C                   eval      dsqmax = avail1
     C                   endif
     *
     *   If no tie/high defined, then consider qty available as
     *   one full pallet load.
     *
     C                   else
MJKbA*            For MJK PIR, we must have a ti/hi for pass 1.
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1
SGCbA*
SGCbA*            For SGC bulkpicks, we must have a ti/hi for pass 1.
SGCbAC                             or sgcbulk = *on  and
SGCbAC                             bppass = 1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
     C                   eval      dsqmax = avail1
     C                   eval      idtie = 0
     C                   eval      idhigh = 0
     C                   eval      dstie = 0
     C                   eval      dshigh = 0
413aAC                   eval      trnbr = 'TR17'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   endif
MJKbA*
MJKbA*       For MJK PIR, we only want full pallets for pass 1.
MJKbA*
MJKbAC                   if        mjkpir = *on  and
MJKbAC                             bppass = 1  and
MJKbAC                             dsqmax > leftq1
SGCbA*
SGCbAC                             or sgcbulk = *on and
SGCbAC                                bppass = 1 and
SGCbAC                                dsqmax > leftq1
SGCbA*
MJKbAC                   iter
MJKbAC                   endif
     *
     *       Calculate quantity to pick.
     *
     C                   if        dsqmax <= leftq1
     C                   z-add     dsqmax        pickq1
     C                   eval      remain = 0
     C                   else
     C                   eval      pickq1 = leftq1
     C     dsqmax        sub       leftq1        remain
     C                   endif
     *
     *       Create label for batch pick
     *
640aAC                   exsr      crtBatchLbl
640aA
640aA*       Force allocation from warehouse
640aA
640aAC                   exsr      ForceAlloc
     *
     *       Update slot allocation.
     *
     C                   add       pickq1        slalc1
     C                   update    slrec
     *
     *       Reduce quantity left to pick.
     *
     C                   eval      leftq1 = leftq1 - pickq1
     C                   add       pickq1        ttlpk1
     *
     *       Leave slot reading loop.
     *
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'BULKPK'
413aAC                   eval      trcode = '*PCK050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   enddo
640aA
640aA*     If we ran out of detail records, get out.
640aA
640aAC                   if        not bpdRecFound
640aAC                   leave
640aAC                   endif
     *
     C                   enddo
     *
MJKbAC                   enddo
640aA
640aA*   Check to see if we need to unlock detail record.
640aA
640aAC                   if        bpdRecFound
640aAC                   unlock    ordd
640aAC                   endif
640aA
     C     endbp         endsr
640aA
640aA*----------------------------------------------------------------
640aA*  CrtBatchLbl   Create batch pick label
640aA*----------------------------------------------------------------
640aA
640aAC     CrtBatchLbl   Begsr

     C                   if        batchId < 999
     C                   eval      batchId += 1
     C                   endif
     C                   eval      lblLeft1 = pickq1

     *  Allocate qty from order detail records.
     *    - In theory, there should be enough qty in order detail records
     *      to fullfil the pickq1 quantity.

     *  If this is the first time into this routine for an item,
     *    Then get the first batch pick detail record for batch item.
     *    If detail rec not found, set pickq1 to zero so that nothing
     *       is allocated from the slot.

     C                   if        newItem
     C                   exsr      GetBPD
     C                   if        not bpdRecFound
     C                   eval      pickq1 = 0
     C                   leavesr
     C                   endif
     C                   eval      odLeft1 = odqor1
     C                   endif

     *  Now create label records that correspond to batch pick detail recs.

     C                   dou       lblLeft1 = 0

     C                   clear                   lwrec

     C                   if        odLeft1 <= lblLeft1
     C                   eval      lwqalc = odLeft1
     C                   else
     C                   eval      lwqalc = lblLeft1
     C                   endif

     C                   eval      lwwhse = slwhse
640aD ***                select
640aD ***                when      client = silberman
640aD ***                          or client = cashwa
640aD ***                          or client = citywho
640aD ***                          or client = kellys
SLBaAC                   eval      lwtruk = $ptmpl
640aD ***                other
640aD ***                eval      lwtruk = $ptruk
640aD ***                endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   eval      lwqryf = 0
     C                   eval      lwdisp = sldisp
     C                   eval      lwasl2 = ' '
     C                   eval      lwqavl = 0
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = ohtype
     C                   eval      lwtype = 'O'
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     C                   eval      lwspcl = odspcl
     C                   eval      lwpo = %replace(%char(batchId):lwpo:6:3)
     C                   eval      lwszon = $zszon
     C                   eval      lwtzon = lwszon
     C                   eval      lwpzon = ' '
     C                   eval      lwgen  = 1
     C                   eval      lwcomp = $zcomp
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C                   eval      lwcube = lwqalc * itcube
     C                   eval      lwuwgt = itswgt
     C                   eval      lwswgt = lwqalc * itswgt
730aDC**                 call      'PIRLBL#'
730aDC**                 parm                    lwlbl#
730aMC                   exsr      GetNextLbl#
730aMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec

     *    Reduce quantities

     C                   eval      lblLeft1 -= lwqalc
     C                   eval      odLeft1 -= lwqalc

     *    If no qty left for order detail record,
     *      Then update its status and get next detail record.
     *      If detail rec not found, reduce pickq1 to what was
     *         written to label records and get out.

     C                   if        odLeft1 <= 0
     C                   eval      odstat = 'P'
     C                   update    odrec
     C                   exsr      getbpd
     C                   if        not bpdRecFound
     C                   eval      pickq1 -= lblLeft1
     C                   leave
     C                   endif
     C                   eval      odLeft1 = odqor1
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  DUPPRT  Dup. printer file.
     *
     C     dupprt        begsr
     *
     *      Duplicate printer file.
     *
     C                   close     or610pr
     *  DUPPRTCL will execute the DUPSPLF command.
     *
     C                   movel     'OR610PR'     $lfile
     C                   movel     'HEMANT'      $loutq
     C                   movel     '*LAST'       $lspln
     C                   movel     'OR610PR'     $lnnam
     *
     C                   call      'DUPPRTCL'
     C                   parm                    $lfile           10
     C                   parm                    #jobn
     C                   parm                    #user
     C                   parm                    #job
     C                   parm                    $loutq           10
     C                   parm      '*LIBL'       $lqlib           10
     C                   parm                    $lspln            6
     C                   parm      1             $lcpys            3 0
     C                   parm                    $lnnam           10
     C                   parm      '*NO'         $ldlto            4
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get picking options for zone.
     *          This routine is only called when looking for a bulk pick.
     *
     C     getopt        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOPT  '    trsubr
     C                   exsr      zztrck

     C                   call      'GETZONE'
     C                   parm      '*GET'        $zcmd             8
     C                   parm      $ptruk        $ztruk           10
     C                   parm      ' '           $zrtid            5
     C                   parm      ohtype        $zotype           1
     C                   parm      slwhse        $zwhse            3 0
     C                   parm      slwhdp        $zwhdp            5
     C                   parm      sldisp        $zdisp           12
     C                   parm      slstyp        $zstyp            1
     C                   parm      slaisl        $zaisl            3
     C                   parm      slloc         $zloc             3 0
     C                   parm      slrlvl        $zrlvl            2 0
     C                   parm      slhand        $zhand            2
     C                   parm      slitem        $zitem           15
     C                   parm      sldesg        $zdesg            5
     C                   parm      ' '           $zutyp            1
     C                   parm      ztype         $ztote            1
     C                   parm      ' '           $zszon            6
     C                   parm      ' '           $zpzon            6
     C                   parm      ' '           $ztzon            6
     C                   parm      ' '           $zcomp            1
     C                   parm      0             $zgen             1 0
     C                   parm                    opzdta
720aAC                   parm      ohord         $zord             7 0
720aAC                   parm      slactv        $zactv            2
720aAC                   parm      slpick        $zpick            1

     C                   if        $zszon = 'ZZZZZZ'
     C                   eval      #dbpck = 999
     C                   else
     C                   eval      #dbpck = opbpck
     C                   endif
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  GetBPD  Get Batch Pick Detail record
640aA*----------------------------------------------------------------
640aA
640aAC     GetBPD        begsr
     C                   eval      bpdRecFound = *off

     *  Write out tracking record.

     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETBPD  '    trsubr
     C                   exsr      zztrck

     *   Set record pointer when working with new item.

     C                   if        newItem
     C     keybpd        setll     ordbdtl
     C                   eval      newItem = *off
     C                   endif

     *   Get next Batch Pick Detail rec for current Batch item

     C                   dow       forever = forever

     C     keybpd        reade(n)  ordbdtl

     C                   if        %eof(ordbdtl)
     C                   leave
     C                   endif

     C     keyod         chain     ordd
     C                   if        not %found(ordd)
     C                   leave
     C                   endif

     C                   eval      bpdRecFound = *on

     C                   if        bpdord <> lastOrd
     C                   exsr      GetOH
     C                   eval      lastOrd = bpdord
     C                   endif

     C                   leave
     C                   enddo

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  GetItem   Get item record
640aA*----------------------------------------------------------------
640aA
640aAC     GetItem       begsr
     C                   eval      itemFound = *off

     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      p1msg = msg(1)
     C                   exsr      prterr
     C                   eval      trnbr = 'TR01'
     C                   eval      trcode = '*PCK050 '
     C                   movel     'GETOD   '    trsr50
     C                   exsr      zztrck
     C                   leavesr
     C                   endif

     C                   eval      itemFound = *on
     C                   exsr      zzxopt
     C                   eval      dscln = *blanks
     C                   if        uxflag = *off
     C                   movel     itdesc        dscln
     C                   else
     C                   movel     ixdsc1        dscln
     C                   move      ixdsc2        dscln
     C                   endif

     *  Save information about item being picked (Item that was ordered)

     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #bitem = ititem
     C                   eval      #sitem = ititem
     C                   eval      #bityp = ittype
     C                   eval      #sityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc

     *  If Contract, Alias or SSB item
     *   Then get Base item.

     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
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
     C                   endif

     *  If Contract, Alias or SSB item
     *   Then get Base Slot item.

     C                   if        ittype = 'A'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60
     C                   endif

     C                   endsr

650aA*----------------------------------------------------------------
650aA*
650aA*  GETITEMSEL Get Item to check for selection method.
650aA *
650aAC     getitemsel    begsr
650aA * add dri to get data from itemfld
650aA /free
650aA       exsr clr$item;

650aA       $itWhse = $pwhse;
650aA       $ititem = oditem;

650aA       $dricommand = '*ITEM';
650aA       $drisubcmd  = '%GETALL';
650aA       $drisys2upd = 'D';
650aA       chk4err = *on;
650aA       zmflag  = *off;
650aA       exsr zzzdricop;
650aA       if error = *on;
650aA         $ifsltmth = ' ';
650aA       endif;
650aA /end-free
650aAC                   endsr

730aA*----------------------------------------------------------------
730aA*  GetNextLbl#    Get next label number
730aA*----------------------------------------------------------------
730aA
730aAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lwwhse) + ', '
                    + 'Rtid: ' + %trimr(lwrte) + ', '
                    + 'Ord: ' + %char(lword) + ', '
                    + 'Seq: ' + %char(lwseq) + ', '
                    + 'Itm: ' + %trimr(lwitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *  GETOH   Get order header record.
     *----------------------------------------------------------------

     C     getoh         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'GETOH   '    trsubr
     C                   exsr      zztrck

640aA*   Get Order Header rec
640aA
640aAC     keyoh         chain     ordh
640aA
640aAC                   if        not %found(ordh)
640aAC                   clear                   ohrec
640aAC                   endif
     *
     C                   movel     ohcnam        p1cnam
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        $pwhse <> lstwhs
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OR610PR'     $lrpt            10
     C                   parm      $pwhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $whse
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or610pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR610PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or610pr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ordbsumbuild - Build ordbsum file
     *
     C     ordbsumbuild  begsr
640aAC                   eval      recCreated = *off

     *  clear file

640aDC**                 eval      i = 99

     C     keybp1        setll     ordbsum1
     C                   dou       %eof(ordbsum1)
     C     keybp1        reade     ordbsum1
     C                   if        not %eof(ordbsum1)
     C                   delete    bprec1
     C                   endif
     C                   enddo

640aAC     keybp1        setll     ordbdtl
640aAC                   dou       %eof(ordbdtl)
640aAC     keybp1        reade     ordbdtl
640aAC                   if        not %eof(ordbdtl)
640aAC                   delete    bpdrec
640aAC                   endif
640aAC                   enddo

     *    Loop thru header records.

     C     keyoh2        setll     ordh2
     C                   dou       %eof(ordh2)
     C     keyoh2        reade     ordh2                                  79
640aDC**                 if        not %eof(ordh2)
640aMC                   if        %eof(ordh2)
640aMC                   leave
640aMC                   endif

     *    Loop thru detail records.

     C     keyod1        setll     ordd1
     C                   dou       %eof(ordd1)
     C     keyod1        reade     ordd1                                  78
640aDC**                 if        not %eof(ordd1)
640aMC                   if        %eof(ordd1)
640aMC                   leave
640aMC                   endif

     *    only process batch pick items

     C     keyom         chain     orddm
     C                   if        not %found(orddm)
     C                             or  %found(orddm)
     C                             and %subst(ommsc1:1:1) <> 'Y'
     C                   iter
     C                   endif
640aA
640aA*    Only normal qty is allowed to be batched picked.
640aA
640aAC                   if        odqor1 <= 0
640aAC                   iter
640aAC                   endif
640aA
640aA*    ODSPCL items are not allowed to be batched picked.
640aA
640aAC                   if        odspcl <> ' '
640aAC                   iter
640aAC                   endif
640aA
640aA*    Get item info
640aA
640aAC                   eval      kyitem = oditem
640aAC     keyit         chain     piritem
640aAC                   if        not %found(piritem)
640aAC                   iter
640aAC                   endif
640aA
640aA*    Only normal and alias items are allowed to be batched picked.
640aA
640aAC                   if        ittype <> ' ' and ittype <> 'A'
640aAC                   iter
640aAC                   endif
     *    PTI & UCI selection items cannot be batch picked.
650aAc                   exsr      getitemsel
650aAc                   if        $ifsltmth = '2' or
650aAc                             $ifsltmth = '3'
650aAC                   iter
650aAC                   endif
640aA
640aA*    Get qty to be picked
640aA
640aDC**                 select
640aDC**                 when      odqor1 > 0
     C                   eval      pickq1 = odqor1
640aDC**                 when      odqor2 > 0
640aDC**                 eval      pickq1 = odqor2
640aDC**                 when      odqor3 > 0
640aDC**                 eval      pickq1 = odqor3
640aDC**                 endsl

640aDC**   keyit         chain     piritem
640aDC**                 if        not %found(piritem)
640aDC**                 eval      itcube = 0
640aDC**                 endif
     *
     C     itcube        mult      pickq1        lwcube
     *
     C     keybp         chain     ordbsum

     C                   select

     C                   when      not %found
     C                   eval      bpwhse = $pwhse
     C                   eval      bprte  = $prtid
     C                   eval      bpitem = ititem
     C                   eval      bpcube = lwcube
     C                   eval      bpqpck = pickq1

640aD**     No longer assigning number here.
640aD**     Now we assign it for each slot we pull from.
640aD**     This will make it closer to a Bulk pick.
640aD**     Otherwise, we could end up splitting a slot into 2 pallets.
640aDC**                 if        i <> 999
640aDC**                 eval      i = i + 1
640aDC**                 endif
640aD **
640aDC**                 eval      bpgrp2 = %char(i)

640aAC                   eval      recCreated = *on
     C                   write     bprec

     C                   when      %found
     C                   eval      bpcube = bpcube + lwcube
     C                   eval      bpqpck = bpqpck + pickq1
     C                   update    bprec

     C                   endsl

640aAC                   eval      bpdwhs = $pwhse
640aAC                   eval      bpdrte = $prtid
640aAC                   eval      bpdord = odord
640aAC                   eval      bpdseq = odseq
640aAC                   eval      bpditm = oditem
640aAC                   write     bpdrec
     *
640aDC**                 endif
     C                   enddo
     * End detail loop
640aDC**                 endif
     C                   enddo
     * End header loop
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  Chk4PickSlot     Check for Pick slot for item
640aA*----------------------------------------------------------------
640aA
640aAC     Chk4PickSlot  begsr

     C                   eval      pckcnt = 0
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     *
     C                   dow       forevr = forevr
     C     keysl3        reade     slot3
     C                   if        %eof(slot3)
     C                   leave
     C                   endif
600aA*
600aA*     Skip special license tracking slots
600aA*
600aAC                   if        sldesg = 'BFC'
600aAC                   iter
600aAC                   endif
     *
     *    Skip expired slots.
     *      For VIP, process pick slots even if expired.
     *
     C                   if        itflgd = 'Y'  and
     C                             slexpd <> 0  and
     C                             slexpd < today  and
     *
     C                             client <> vip
     C                   iter
     C                   endif

     *    Increment pick slot counter

     C                   add       1             pckcnt
     C                   leave

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  PICK0   Pick quantity needed.
     *
     C     pick0         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK0   '    trsubr
     C                   exsr      zztrck
     *
     *     Initialize pick quantities.
     *
     C                   eval      pickq1 = 0
     C                   eval      pickq2 = 0
     C                   eval      pickq3 = 0
     *
     C                   eval      picku1 = 0
     C                   eval      picku2 = 0
     C                   eval      picku3 = 0
     *
     *     Try to pick normal quantity.
     *
     C                   if        leftq1 > 0
     C                   exsr      pick1
     C                   endif
     *
     *     Try to pick breakdown 1 quantity.
     *
     C                   if        leftq2 > 0
     C                   exsr      pick2
     C                   endif
     *
     *     Try to pick breakdown 2 quantity.
     *
     C                   if        leftq3 > 0
     C                   exsr      pick3
     C                   endif
     *
     C                   eval      pckall = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK1  Pick normal quantity.
     *
     C     pick1         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK1   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough normal qty available then grab it.
     *     Otherwise, just grab what is available.
     *
     C                   if        leftq1 <= avail1  or
     C                             pckall = *on  or
     *
     C                             client = vip  and
     *     IDS allocation override flag Y=Yes.
     C                             omiaov = 'Y'  or
     *
     C                             client = mjkeln  and
     *     IDS allocation override flag Y=Yes.
     C                             omiaov = 'Y'
     C*
     C                             or client = SGC
     C*     SGC allocation override flag Y=Yes.
     C                             and sgcdm1_omalco = 'Y'
     C*
     *
     C                   eval      pickq1 = leftq1
     C                   else
     C                   eval      pickq1 = avail1
     C                   endif
     *
     C                   eval      avail1 = avail1 - pickq1
     C                   eval      picku1 = pickq1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK2  Pick breakdown 1 quantity.
     *
     C     pick2         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK2   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough breakdown 1 qty available then grab it.
     *
     C                   select
     C                   when      leftq2 <= avail2  or
     *
     C                             client = vip  and
     *     IDS allocation override flag Y=Yes.
     C                             omiaov = 'Y'  or
     *
     C                             client = mjkeln  and
     *     IDS allocation override flag Y=Yes.
     C                             omiaov = 'Y'
     C*
     C                             or client = SGC
     C*     SGC allocation override flag Y=Yes.
     C                             and sgcdm1_omalco = 'Y'
     C*
     *
     C                   eval      picku2 = leftq2
     C                   eval      pickq2 = leftq2
     C                   sub       leftq2        avail2
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a normal unit.
     *           (This is not true)
     *
     *     As of 520a we try to pick full cases then eaches. This is
     *     because brkdn 1 qty's over 999 were being sent to be picked.
     *     The 'PICKU' qtys reflect the actual uom qty's we picked
     *     from the slot, while the 'PICKQ' qty's is what we picked
     *     of the label.
     *
     C                   other
     *
     *   First, try to pick full cases
     *
     C                   eval      svqty2 = leftq2
     C                   dow       svqty2 >= itumq2  and
     C                             avail1 > 0  and
     C                             itumq2 > 0
     C                   add       1             picku1
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        pickq2
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     *
     *   Then pick the remaining qty from the brkdn 1 qty
     *
     C                   dow       svqty2 > 0
     *
     *       If enough available, pick entire qty.
     *
     C                   if        svqty2 <= avail2
     C                   add       svqty2        picku2
     C                   add       svqty2        pickq2
     C                   sub       svqty2        avail2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif
     *
     *       Not enough availalbe, break down a case and loop.
     *
     C                   if        avail1 > 0  and
     C                             itumq2 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   iter
     C                   endif
     *
     *       Case not available, take what we can get.
     *
     C                   if        avail2 > 0
     C                   add       avail2        picku2
     C                   add       avail2        pickq2
     C                   eval      svqty2 = svqty2 - avail2
     C                   eval      avail2 = 0
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     *   If any qty still remains and we are to pick it all
     *     Then pick it all, cases first, then brkdn 1.
     *
     C                   if        pckall = *on
     *
     C                   if        svqty2 > 0
     C                   dow       svqty2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             picku1
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        pickq2
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     C                   endif
     *
     C                   if        svqty2 > 0
     C                   add       svqty2        picku2
     C                   add       svqty2        pickq2
     C                   sub       svqty2        avail2
     C                   eval      svqty2 = 0
     C                   endif
     *
     C                   endif
     *
     *   Last of all, convert brkdn1 into cases
     *
     C                   dow       svqty2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             picku1
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        pickq2
     C                   eval      svqty2 = svqty2 - itumq2
     C                   enddo
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PICK3  Pick breakdown 2 quantity.
     *
     C     pick3         begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PICK3   '    trsubr
     C                   exsr      zztrck
     *
     *   If there is enough breakdown 2 qty available then grab it.
     *
     C                   select
     C                   when      leftq3 <= avail3
     C                   eval      pickq3 = leftq3
     *
     *   Otherwise try to break a larger unit to get qty needed.
     *
     *     Note: The qty needed will always be less than the qty
     *           in a breakdown 1 unit.
     *
     C                   other
     *     Unfortunately, this was not the case until 520b, when
     *     the code was changed to up the LEFTQ1/2/3 fields.
     *
     *
     *      Try to break a breakdown 1 unit and grab what's needed.
     *
     C                   select
     C                   when      avail2 > 0
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Then try to break a normal unit and grab what's needed.
     *
     C                   when      avail1 > 0
     C                   eval      avail1 = avail1 - 1
     C                   add       itumq2        avail2
     C                   eval      slstk1 = slstk1 - 1
     C                   add       itumq2        slstk2
     C                   eval      avail2 = avail2 - 1
     C                   add       itumq3        avail3
     C                   eval      slstk2 = slstk2 - 1
     C                   add       itumq3        slstk3
     C                   eval      pickq3 = leftq3
     *
     *      Otherwise, just grab what is available for breakdown 2.
     *
     C                   other
     C                   eval      pickq3 = avail3
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   sub       pickq3        avail3
     C                   eval      picku3 = pickq3
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  POST    Post picking labels.
     *
     C     post          begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'POST    '    trsubr
     C                   exsr      zztrck
     *
     *   Create picking labels - one for each quantity breakdown.
     *
     C                   if        client = cityln
     *    Don't create label for PIR item that doesn't have
     *    any slots in the warehouse.
     C                   if        itstyp = 'P'  and
     C                             lwlas2 = 'OUT'  and
     C                             sldisp = *blanks
     C                   goto      endpst
     *
     C                   endif
     C                   endif
     *
     *      If OUT doesn't have a slot, try to get one.
     *
     C                   if        lwlas2 = 'OUT'  and
     C                             sldisp = *blanks
     C                   if        itstyp = 'P'
     C                   eval      $scmd = '*LAST'
     C                   else
     C                   eval      $scmd = '*FIRST'
     C                   endif
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      itwhse        $swhse            3 0
     C                   parm      oditem        $sitem           15
     C                   parm                    sldisp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    $srtn             8
     C                   parm                    slpseq
     C                   if        $srtn = '*NONE'
     C                   eval      sldisp = *blanks
     C                   eval      slaisl = *blanks
     C                   eval      slloc = 0
     C                   eval      slrlvl = 0
     C                   eval      slhand = *blanks
     C                   eval      slpseq = 0
     C                   endif
     C                   endif
     *
     *      Initialize label fields.
     *
     C                   clear                   lwrec
     C                   eval      lwwhse = slwhse
640aA ***                select
640aA ***                when      client = silberman
640aA ***                          or client = cashwa
640aA ***                          or client = citywho
640aA ***                          or client = kellys
SLBaAC                   eval      lwtruk = $ptmpl
640aA ***                other
640aA ***                eval      lwtruk = $ptruk
640aA ***                endsl
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
     C                   eval      lwasl2 = lwlas2
     C                   eval      lwqavl = lwlqav
     C                   eval      lwrte = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword = ohord
     C                   eval      lwseq = odseq
     C                   eval      lwitem = oditem
     C                   eval      lwpbat = $pbat
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = ohtype
     C                   eval      lwtype = lwltyp
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     C                   eval      lwspcl = odspcl
     C                   eval      lwucub = 0
     C                   eval      lwcube = 0
     C                   eval      lwuwgt = 0
     C                   eval      lwswgt = 0
     *
     *      Create label for normal quantity.
     *
     C                   if        pickq1 > 0
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C     lwucub        mult      pickq1        lwcube
     C                   eval      lwuwgt = itswgt
     C     lwuwgt        mult      pickq1        lwswgt
     C                   eval      lwqalc = pickq1
730aDC**                 call      'PIRLBL#'
730aDC**                 parm                    lwlbl#
730aMC                   exsr      GetNextLbl#
730aMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 1 quantity.
     *
     C                   if        pickq2 > 0
     C                   eval      lwutyp = *on
     C                   eval      lwucod = itum2
     C                   if        itumq2 <> 0
     C     itcube        div(h)    itumq2        lwucub
     C     lwucub        mult      pickq2        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
     C     lwuwgt        mult      pickq2        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq2
730aDC**                 call      'PIRLBL#'
730aDC**                 parm                    lwlbl#
730aMC                   exsr      GetNextLbl#
730aMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     *      Create label for breakdown 2 quantity.
     *
     C                   if        pickq3 > 0
     C                   eval      lwutyp = '2'
     C                   eval      lwucod = itum3
     C                   if        itumq2 <> 0  and
     C                             itumq3 <> 0
     C     itcube        div(h)    itumq2        lwucub
     C     lwucub        div(h)    itumq3        lwucub
     C     lwucub        mult      pickq3        lwcube
     C     itswgt        div(h)    itumq2        lwuwgt
     C     lwuwgt        div(h)    itumq3        lwuwgt
     C     lwuwgt        mult      pickq3        lwswgt
     C                   endif
     C                   eval      lwqalc = pickq3
730aDC**                 call      'PIRLBL#'
730aDC**                 parm                    lwlbl#
730aMC                   exsr      GetNextLbl#
730aMC                   eval      lwlbl# = nextLbl#
     C                   write     lwrec
     C                   endif
     *
     *   Update slot allocation.
     *
     *     - Corss dock items were allocated during import.
     *
     C                   if        odspcl <> 'XD'
     *
     C                   add       slalc1        picku1
     C                   add       slalc2        picku2
     C                   add       slalc3        picku3
     *
     C                   dow       picku2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             picku1
     C                   eval      picku2 = picku2 - itumq2
     C                   enddo
     *
     C                   eval      slalc1 = picku1
     C                   z-add     picku2        slalc2
     C                   z-add     picku3        slalc3
     *
     C                   exsr      avail
     C                   dow       avail2 >= itumq2  and
     C                             slstk2 >= itumq2  and
     C                             itumq2 > 0
     C                   add       1             slstk1
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      avail2 = avail2 - itumq2
     C                   enddo
     *
     C                   endif
     C                   if        lwlas2 <> 'OUT'
     C                   update    slrec
     C                   endif
     *
     C     endpst        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTERR  Print error exception.
     *
     C     prterr        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'PRTERR  '    trsubr
     C                   exsr      zztrck
     C                   if        operpt <> 'N'  and
     C                             ophpwc = 'N'  or
     *
     C                             operpt <> 'N'  and
     C                             ophpwc = 'Y'  and
     C                             $potyp <> 'W'
     *
     *  See if we should printer header.
     *
     C                   if        prflag <> *on  or
     C                             *in90
     C                   write     head1
     C                   if        *in90
     C                   write     head2
     C                   endif
     C                   write     columns
     C                   eval      prflag = *on
     C                   eval      *in90 = *off
     C                   endif
     *
     *   Print detail line.
     *
     C                   write     detail1
     C                   write     detail2
     C                   endif
     C                   endsr
730aA*----------------------------------------------------------------
730aA*  wrtDebug    Write out debug record
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*PCK040 '
     C                   movel     'ZMSMSG  '    trsubr
     C                   exsr      zztrck
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     ZZTRCK - Write tracking records to tracking file
     *
     C     zztrck        begsr
     C                   select
     C                   when      trcode = '*PCK001 '
     C                   eval      trpcmd = $pcmd
     C                   eval      trprg = $pprg
     C                   eval      trpbat = $pbat
     C                   eval      trrord = $pord
     C                   eval      trotyp = $potyp
     C                   eval      trrtid = $prtid
     C                   select
     C                   when      trerr = *off
     C                   eval      trpkst = tr80
     C                   when      trerr = *on
     C                   eval      trpkst = tr81
     C                   endsl
     C                   eval      trflpk = flgpck
     C                   eval      trfltk = flgtrk
     C                   eval      trdata = tr01ds
     C                   eval      trsqnr = *zeros
     C                   write     tr01rec
     *
     C                   when      trcode = '*PCK002 '
     C                   if        flgpck = *on
     C                   eval      trdata = trerfl
     C                   else
     C                   eval      trdata = opdata
     C                   endif
     C                   eval      trsqnr = *zeros
     C                   write     tr02rec
     *
     C                   when      trcode = '*PCK003 '
     C                   if        flgpck = *on
     C                   eval      trdata = trerfl
     C                   else
     C                   eval      trrows = throws
     C                   eval      trcols = thcols
     C                   eval      trbulk = thbulk
     C                   eval      trbat = thbat
     C                   eval      trdata = tr03ds
     C                   endif
     C                   eval      trsqnr = *zeros
     C                   write     tr03rec
     *
     C                   when      trcode = '*PCK010 '
     C                   add       1             trsq10
     C                   movel     opzzon        trzone
     C                   eval      trdt10 = opzdta
     C                   eval      trdata = tr10ds
     C                   eval      trsqnr = trsq10
     C                   write     tr10rec
     *
     C                   when      trcode = '*PCK040 '
     C                   add       1             r
     *    Array is full, add to file and then reset array.
     C                   if        r > 25
     C                   add       1             trsq40
     C                   eval      trsqnr = trsq40
     C                   eval      trdata = tr40ds
     C                   write     tr40rec
     C                   eval      trrfld = *blanks
     C                   eval      r = 1
     C                   endif
     C                   eval      trr(r) = trsubr
     *
     C                   when      trcode = '*PCK050 '
     C                   add       1             trsq50
     C                   eval      trord = ohord
     C                   eval      trstop = ohstop
     C                   eval      tritem = oditem
     C                   eval      trmsgt = 'S'
     *
     C                   select
     C                   when      trnbr = 'TR01'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(1)
     C     trdt50        cat       tr05:2        trdt50
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cqty1 = odqor1
     C                   eval      $cqty2 = odqor2
     C                   eval      $cqty3 = odqor3
     C                   eval      $cqstr = *blanks
     C                   exsr      zzcvqy
     C     trdt50        cat       $cqstr:1      trdt50
     *
     C                   when      trnbr = 'TR03'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(3)
     C     trdt50        cat       tr05:2        trdt50
     C     trdt50        cat       p1qord:0      trdt50
     C     trdt50        cat       tr06:2        trdt50
     C     trdt50        cat       p1qalc:0      trdt50
     C     trdt50        cat       tr07:2        trdt50
     C     trdt50        cat       p1qpck:0      trdt50
     *
     C                   when      trnbr = 'TR04'
     C                   eval      trerr = *on
     C                   eval      trdt50 = msg(4)
     C     trdt50        cat       tr05:2        trdt50
     C     trdt50        cat       p1qord:0      trdt50
     C     trdt50        cat       tr06:2        trdt50
     C     trdt50        cat       p1qalc:0      trdt50
     C     trdt50        cat       tr07:2        trdt50
     C     trdt50        cat       p1qpck:0      trdt50
     *
     C                   when      trnbr = 'TR09'
     C                   eval      trdt50 = %trimr(tr09) + ' ' + sldisp
     C     trdt50        cat       tr08:2        trdt50
     C                   move      slexpd        cvt8a
     C     trdt50        cat       cvt8a:0       trdt50
     *
     C                   when      trnbr = 'TR10'
     C                   eval      trdt50 = %trimr(tr10) + ' ' + sldisp
     *
     C                   when      trnbr = 'TR11'
     C                   eval      trdt50 = %trimr(tr11) + ' ' + sldisp
     *
     C                   when      trnbr = 'TR12'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr12
     *
     C                   when      trnbr = 'TR13'
     C                   eval      trord = *zeros
     C                   eval      trstop = *zeros
     C                   eval      tritem = *blanks
     C                   eval      trdt50 = tr13
     *
     C                   when      trnbr = 'TR14'
     C                   eval      trdt50 = tr14
     *
     C                   when      trnbr = 'TR15'
     C                   eval      trdt50 = tr15
     C                   move      leftq1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR16'
     C                   eval      trdt50 = %trimr(tr16) + sldisp
     C     trdt50        cat       tr23:1        trdt50
     *
     C                   when      trnbr = 'TR17'
     C                   eval      trdt50 = %trimr(tr17) + ' ' + sldisp
     C     trdt50        cat(p)    tr21:2        trdt50
     C                   move      avail1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR18'
     C                   eval      trdt50 = %trimr(tr18) + ' ' + sldisp
     C     trdt50        cat(p)    tr22:2        trdt50
     C                   move      pickq1        cvt5a
     C     trdt50        cat       cvt5a:0       trdt50
     *
     C                   when      trnbr = 'TR19'
     C                   eval      trdt50 = tr19
     *
     C                   when      trnbr = 'TR20'
     C                   eval      trdt50 = %trimr(tr20) + trkey
     C                   eval      trmsgt = 'D'
     *
     C                   select
     C                   when      trkey = 'KEYSL3'
     C     trdt50        cat       'Stat:':1     trdt50
     C     trdt50        cat       kystat:1      trdt50
     C     trdt50        cat       'Pick:':1     trdt50
     C     trdt50        cat       kypick:1      trdt50
     *
     C                   when      trkey = 'KEYS3B'
     C     trdt50        cat       'Stat:':1     trdt50
     C     trdt50        cat       kystat:1      trdt50
     C     trdt50        cat       'Pick:':1     trdt50
     C     trdt50        cat       kypick:1      trdt50
     C     trdt50        cat       'Prty:':1     trdt50
     C                   move      kyprty        cvt1a
     C     trdt50        cat       cvt1a:1       trdt50
     C     trdt50        cat       'Expd:':1     trdt50
     C                   move      kyexpd        cvt8a
     C     trdt50        cat       cvt8a:0       trdt50
     C     trdt50        cat       'Entd:':1     trdt50
     C                   move      kyentd        cvt8a
     C     trdt50        cat       cvt8a:0       trdt50
     *
     C                   endsl
     *
     C                   endsl
     C                   eval      trdata = tr50ds
     C                   eval      trmsgn = trnbr
     C                   eval      trsqnr = trsq50
     C                   write     tr50rec
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCVQY - Convert receive qty's to string for msg display
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   move      opdata        opdta2
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     C                   endif
     *
     C                   if        uxflag = *on
     C     idkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      ixdsc1 = *blanks
     C                   eval      ixdsc2 = *blanks
     C                   endif
     C                   endif
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  zzzdricop  Call DRICOP
650aA*----------------------------------------------------------------

650aAC     zzzdricop     begsr
650aAC                   eval      error = *off

650aAC                   select
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $dridata = $item
650aAC                   eval      $dridata2 = $item2
650aAC                   endsl

650aAC                   if        $dricommand = '*ITEM'
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #pgm          $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   parm                    $dridata2
650aAC                   else
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #pgm          $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   endif

650aAC                   select

650aAC                   when      chk4err and %error
650aAC                   eval      error = *on

650aAC                   when      chk4err and $drireturn <> '*OK'
650aAC                   eval      error = *on

650aAC                   endsl

650aAC                   select
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $item = $dridata
650aAC                   eval      $item2 = $dridata2
650aAC                   endsl

650aAC                   eval      zmflag = *off
650aAC                   eval      zmsflag = *off
650aAC                   eval      chk4err = *off
650aAC     enddricop     endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   Error messages
Item master record not on file.
First item after restarting batch.
Not enough stock available for order.
Slots did not contain enough stock.
No picking slot defined for item.
**   OVRPRTF statment
OVRPRTF FILE(OR610PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
