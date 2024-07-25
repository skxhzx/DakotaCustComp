      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SI255S   Stage - FTP StuffIt Import - Post
     *  14 Feb 2011
     *  Retha Davis
     *  Cloned from Cheney's SI255
     *----------------------------------------------------------------
     *
     *  NOTE:
417  *    02/18/04
     *      - SITYPE = 'I' - Inventory quantity need to manually run
     *        recalculate *ALL when finished, replaces slot quantity.
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    06/03/00  DAS 4.14
     *      - Created
     *
414aA*    06/21/00  DAS 4.14a
     *      - Revised to get *PICK options when department changes
     *        not when warehouse changes.
     *      - Revised routine ZZMAN to initialize EXIST flag.
     *      - Revised routine ZZCKNS to initialize NEWVS flag.
     *      - Added two descriptions to identify exact cause of
     *        virtual slot not being created.
     *
414bA*    06/26/00  DAS 4.14b
     *      - Revised mainline to initialize NEWVS flag.
     *
414cA*    06/27/00  DAS 4.14c
     *      - Modified handstack loop to check pointer against
     *        702 instead of 720 in ZZCKNS.
     *
415aA*    12/14/00  MLB  4.15a
     *      - Revised ZZSSB to set on SSBFLG if item found.
     *
417 A*    01/13/03  HNK  4.17
     *      - Revised to subtract qty from slot if type='P'. Replace
     *        quantity if type='I'.
     *        SITYPE = 'P' - Picked quantity
     *               = 'I' - Inventory quantity
417aA*    02/02/04  MLB  4.17a
     *      - Fix: Added call to pgm GETSLOT to retrieve base or
     *        virtual slot display where item exists when SITYPE = 'P'.
417bA*    02/19/04  RH   4.17b
     *      - Fix: subtract qty from ITEMQTY if type='P', picked qty.
417cA*    05/10/04  RH   4.17c
     *      - ENH: Write an adjustment label record.
417dA*    06/07/04  RH   4.17d
     *      - ENH: For Inventory SITYPE='I', restore dates from saved
     *             file if item in slot did NOT change.
     *
510 A*    03/22/07  MLB  5.10
     *      - Enh: Added client custom code support to program.
510aA*    03/22/07  MLB  5.10a
     *      - Enh: Revised program to allow Item Type R=Repack item to
     *        be populated into the SLOT file.
510bA*    10/08/07  RBD & RH  5.10b
     *      - Enh: Added support for *VIRTUAL slot option OPVPCK.
520aA*    03/26/09  GJA  5.20a
     *      - Enh: clear RCV, PCK, ALC, and TFR buckets before
     *             writing to SLOT file.
530aA*    12/07/09  RH   5.30a
     *      - Add Designation code to parms for CHKSTAT.
640aA*    02/14/11  RBD  6.40a
     *      - Converted to ILE.
     *      - Revised to used staging file impfstuf in place of
     *        file impsstuf.
640bA*    05/09/12  MLB  6.40b
     *      - Fix: Revised proram to only verify item number when sent
     *        with slot.
     *
650 A*    01/10/13  MLB  6.50
     *      - Fix: Revised to remove CRLF characters from import pick
     *        slot Re: HM Wagner had these characters in their pick slot
     *        which caused problems in rendering DragDrop screen.
     *
650aA*    08/16/13  MLB  6.50a
     *      - Enh: Revised pgm to allow support for 0-9 in SLHAND field.
700a *    04/19/16  RTR  7.00a
     *      - Fix: change to 640b, was still doing breakdown logic when
     *        item not sent.
720a *    08/30/18  RTR  7.20a
     *      - Enh: change to not run if Inbound or Full System.
720bA*    12/11/18  MLB  7.20b
     *      - Enh: Revised 7.20a mod to move code that populates $pwhse
     *        to routine, *INZSR ahead of *FEATURE retrieval.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal Foodservice
     *
ROY A*    03/22/07  MLB  ROY
     *      - Revised program to populate Fixed pick slots even if
     *        qty sent is zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPC A*    03/24/07  MLB  TPC
     *      - Revised program to populate Fixed pick slots even if
     *        qty sent is zero. Added TPC to ROY mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    04/23/12  MLB  HMW
     *      - Revised program to populate Fixed pick slots even if
     *        qty sent is zero. Added HMW to ROY mod.
HMWaA*    04/23/12  MLB  HMWa
     *      - Revised program to create slots based on HMW formats.
     *        Wagner's slot format is 2232D1, Where aisle=22,
     *        location=32 and rlvl=4(D=4) and Handstack=1.
     *      - New routine, CRTSLOT25 will be used for HMW.
HMWaA*    04/04/12  MLB  HMWa
     *      - Revised program to omit all slots that begin with 'S'
     *        which are showroom slots.
     *      - Revised program to set department codes as follows:
     *        Aisles 00-99 = DRY
     *        Aisles ZC, ZD-ZE, ZM = REF.
     *        Aisle  ZF = FRZ.
     *        Aisle  ZX = ZX.
     *        Aisle  ZXC = ZXC.
     *        Aisle  ZXF = ZXF.
HMWcA*    04/05/12  MLB  HMWc
     *      - Revised program to add support for new slot formats:
     *        Wagner's slot format is ZXC1A1, Where aisle=ZXC,
     *        location=1 and rlvl=1(A=1) and Handstack=1.
     *        Wagner's slot format is ZXCR1, Where aisle=ZXC,
     *        location=1 and rlvl=18(R=18) and Handstack=' '.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
     *
KFS A*    06/29/12  MLB  KFS
     *      - Revised program to map Kelly's slot format into the
     *        Dakota slot master.
     *        Kelly's slot format is FA02A, Where aisle=FA,
     *        location=02 and rlvl=1(A=1) and Handstack=blanks.
     *      - New routine, CRTSLOT26 will be used for KFS.
KFSaA*    08/20/12  MLB  KFSa
     *      - Revised program to map Kelly's slot format into the
     *        Dakota slot master.
     *        Kelly's slot format is FA-02-A, Where aisle=FA,
     *        location=02 and rlvl=1(A=1) and Handstack=blanks.
     *      - Kelly's slot format is FA-02-1, Where aisle=FA,
     *        location=02 and rlvl=1 and Handstack=blanks.
     *      - Kelly's slot format is X01A, Where aisle=X,
     *        location=01 and rlvl=1(A=1) and Handstack=blanks.
KFSbA*    08/16/13  MLB  KFSb
     *      - Revised program to populate Fixed pick slots even if
     *        qty sent is zero. Added KFSb to ROY mod.
KFScA*    01/31/18  MLB  KFSc
     *      - Revised program to map Kelly's slot format into the
     *        Dakota slot master.
     *        Kelly's slot format is DA-152-1A, Where aisle=DA,
     *        location=152 and rlvl=1 and Handstack=A.
     *        qty sent is zero. Added KFSb to ROY mod.
KFSdA*    10/03/18  MLB  KFSd
     *      - Revised program to map Kelly's slot format into the
     *        Dakota slot master. Certain slots now support 3 char
     *        aisles. WGD-241-1, Where aisle=WGD, location=241 and
     *        rlvl=1.
KFSe *    02/02/19  RTR  KFSe
     *      - Do not run for Kelly's, now on Full System.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Wholesale
     *
HARa *    05/23/17  RTR  HARa
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: PFG Performance Food Group
     *
PFG A*    10/29/18  MLB  PFG
     *      - Revised program to map PFG's slot format into the
     *        Dakota slot master.
     *        PFG's slot format is CA1231, Where aisle=CA,
     *        location=123 and rlvl=1 and Handstack=blanks.
     *      - New routine, CRTSLOT27 will be used for PFG.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*impfstuf  if   e           k disk
640aMFimpsstuf  uf   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
510bAFoptions   if   e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    uf a e           k disk
417b Fitemqty   uf   e           k disk
417d Fsslot2    if   e           k disk
417d Fsvslot2   if   e           k disk
     Fsi255pr   o    e             printer oflind(*in91)
417cAFLabel     o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
414aD*                   DESC    1   6 20
510bD*                   DESC    1  10 20
510bMD desc            s             20    dim(11) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
650aDD*hnd             s              2    dim(702)
650aMD hnd             s              2    dim(972)
650aDD*ltr             s              1    dim(27) ctdata perrcd(27)
650aMD ltr             s              1    dim(37) ctdata perrcd(37)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
640aM /COPY QCOPYSRC,ID#ROYAL
640aM /COPY QCOPYSRC,ID#TPC
HMW M /COPY QCOPYSRC,ID#HMWAGNE
KFS M /COPY QCOPYSRC,ID#KFS
PANaA /COPY QCOPYSRC,ID#PAN
HARaA /copy qcopysrc,id#harbor
PFG A /COPY QCOPYSRC,ID#PFG
     *----------------------------------------------------------------
     *  Called programs
     *
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
     D opddta          ds
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
     *----------------------------------------------------------------
510bA*  *VIRTUAL  -  Virtual Slot options
510bA*----------------------------------------------------------------
510bA*
510bA* Fields
510bA*
510bA*    OPVALL  -  Always create Virtual slot. (Y/N)
510bA*    OPVPCK  -  Allow Virtual pick slots to be created.  (Y/N)
510bA*    OPVSLT  -  Create Virtual slot for item when base slot and
510bA*               corresponding Virtual slot(s) item(s) are different.
510bA*               Always Yes.
510bA*    OPVEXP  -  Create Virtual slot when item exists and
510bA*               expiration date is different.  (Y/N)
510bA*    OPVEND  -  Create Virtual slot when item exists and
510bA*               entered date is different.  (Y/N)
510bA*    OPVSAM  -  Merge product when entered/expiration dates
510bA*               are the same.  (Y/N)
510bA*    OPVEDF  -  Merge product when entered dates are different and
510bA*               expiration dates are the same.  (Y/N)
510bA*
510bA* Data structure
510bA*
510bAD opdat4          ds
510bAD  opvall                 1      1
510bAD  opvpck                 2      2
510bAD  opvslt                 3      3
510bAD  opvexp                 4      4
510bAD  opvend                 5      5
510bAD  opvsam                 6      6
510bAD  opvedf                 7      7
510bAD  opten4               117    117
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     *----------------------------------------------------------------
     *  Variables
     *
     D $jobq           s              1
     D $pwhs           s             15  5
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
HMW AD allchrslot      s              1    inz('0')
     D count           s              3  0                                      LINE COUNTER
650 AD crlf            c                   const(x'0D25')
650 AD spaces          c                   const('  ')
HMW AD dashpos         s              2  0
HMW AD dummy           s                   like(slloc)
HMW AD loca            s              3
HMW AD loca_x          s              3
HMW AD lvla            s              1
HMW AD lvlaa           s              2
HMW AD locnotnum       s               n
HMW AD lvlnotnum       s               n
HMW AD notcreated      s               n
HMW AD dftlocation     s              3  0 inz(600)
640aDD*error           s              1
640aMD error           s               n
     D exist           s              1
     D exsts           s              1
     D flaghs          s              1
     D forevr          s              1
     D good1           s              1
HMW AD handstack       s              1     inz('0')
     D i               s              2  0
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
HMW AD kydisp          s                   like(sldisp)
     D kyocod          s                   like(opcode)
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D lstwhd          s              5
     D lstwhs          s              3  0
     D newvs           s              1
HMW AD nwchar          s              2
HMW AD oddeven         s                   like(slloc)
     D odisp           s                   like(sldisp)
720aAD optFeature      s              1a
     D pflag           s              1
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D pos             s              1  0
HMW AD sipick          s                   like(slpick)
HMW AD                                     inz('Y')
HMW AD sipseq          s                   like(slpseq)
HMW AD                                     inz(0)
HMW AD sirsrv          s                   like(slrsrv)
HMW AD                                     inz('Y')
HMW AD sistyp          s                   like(slstyp)
HMW AD                                     inz('F')
HMW AD slotcreated     s               n
     D ssbflg          s              1
640aAD stamp           s               z
640aAD stampUC         s               z
     D svexpd          s                   like(slexpd)
HMW AD svwhdp          s                   like(slwhdp)
     D today           s              8  0
HMW AD validdept       s              4    inz('*YES')
HMW AD wkchar          s              2
     D work3a          s              3
PANbAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
PANbAD upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
720bDc*                  eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
720aAC                             or optFeature <> '3'
640aAC                   return
640aAC                   endif
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      noslot = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     C                   eval      badtyp = 0
     C                   eval      notcrt = 0
     C                   eval      notupd = 0
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      forevr = *on
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 999                                  LINE COUNTER
     C                   eval      lstwhs = -(1)
414aAC                   eval      lstwhd = '@@@@@'
     *
640aAC     keysi         setll     impsstuf
     C                   dow       forevr = forevr
     *
640aDC**                 read      impfstuf                               79
640aMC     keysi         reade     impsstuf                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   add       1             grdlin
     *
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        sistatus <> 'R'
640aAC                   iter
640aAC                   endif

650 A*      Strip out any cr/lf values.
650 AC                   eval      sidisp = %xlate(crlf: spaces: sidisp)
HMWaAC                   select
HMWaA*
HMWaAC                   when      client = HMWagner
HMWaAC                   select
HMWaAC                   when      %subst(sidisp:1:1) = 'S'
HMWaA*      Skip showroom slots.
HMWaAC                   iter
HMWaA*
HMWaAC                   when      %subst(sidisp:1:3) = 'ZXC'
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'ZXC  '
HMWaA*
HMWaAC                   when      %subst(sidisp:1:3) = 'ZXF'
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'ZXF  '
HMWaA*
HMWaAC                   when      %subst(sidisp:1:2) = 'ZX'
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'ZX   '
HMWaA*
HMWaAC                   when          (%subst(sidisp:1:2) >= 'ZC'
HMWaAC                             and %subst(sidisp:1:2) <= 'ZE'
HMWaAC                             or  %subst(sidisp:1:2)  = 'WP'
HMWaAC                             or  %subst(sidisp:1:2)  = 'ZM'
HMWaAC                             or  %subst(sidisp:1:2)  = 'ZZ')
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'REF  '
HMWaA*
HMWaAC                   when      %subst(sidisp:1:2) = 'ZF'
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'FRZ  '
HMWaA*
HMWaAC                   when          (%subst(sidisp:1:2) >= '00'
HMWaAC                             and %subst(sidisp:1:2) <= '99')
HMWaAC                             and siwhdp = ' '
HMWaAC                   eval      siwhdp = 'DRY  '
HMWaA*
HMWaAC                   endsl
HMWaA*
HMWaMC                   endsl
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> siwhse
     *
     C                   if        lstwhs > 0
     C                   exsr      zzrcal
     C                   endif
     *
510bA*   If warehouse changed, get all new options.
510bA*    Get virtual slot options.
510bAC                   exsr      zzvrto
510bA*
     *
414aD**                   MOVE '*PICK   'KYCODE
414aD**         KEYOP     CHAINOPTIOND              79
414aD**         *IN79     IFEQ *ON
414aD**                   MOVE 'N'       OPMPUT
414aD**                   ENDIF
     *
     C                   eval      whcode = siwhse
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      siwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     C                   eval      lstwhs = siwhse
     C                   eval      count = 999
     C                   endif
414aA*
414aA*  Get options when department changes
414aA*
414aAC                   if        lstwhd <> siwhdp
414aAC                   eval      kycode = '*PICK   '
414aAC     keyop         chain     optiond                            79
414aAC                   if        *in79
414aAC                   eval      opmput = 'N'
414aAC                   endif
414aAC                   eval      lstwhd = siwhdp
414aAC                   endif
     *
     C                   eval      itdesc = *blanks
     C                   eval      ittype = *blanks
     C                   eval      detmsg = *blanks
417aA*
417aA*  Find actual slot for item based on slot sent in.
417aA*
417aAC                   if        sitype = 'P'
417aAC                   call      'GETSLOT'
640aDC**                 parm      siwhse        $pwhse            3 0
640aMC                   parm      siwhse        $swhse            3 0
417aAC                   parm      siwhdp        $pwhdp            5
417aAC                   parm      sidisp        $pbase           12
417aAC                   parm      siitem        $pitem           15
417aAC                   parm      *blanks       $pslot           12
417aAC                   parm      *blanks       $prtn             8
417aA*
417aA*    Item found in slot. Replace slot sent in.
417aAC                   if        $prtn = '*FOUND  '
417aAC                   eval      sidisp = $pslot
417aAC                   endif
417aAC                   endif
     *
     *  If slot doesn't exist write error message.
     *
     C     keysl2        chain(n)  slot2                              76
     C                   if        *in76

HMW AC                   select

HMW AC                   when      client = HMWagner
HMWaA*
HMWaAC                   if        siwhdp <> svwhdp
HMWaAC                   eval      dftlocation = 600
HMWaAC                   eval      svwhdp      = siwhdp
HMWaAC                   endif
HMW AC                   exsr      crtslot25

KFS AC                   when      client = Kellys
KFS A*
KFS AC                   if        siwhdp <> svwhdp
KFS AC                   eval      dftlocation = 600
KFS AC                   eval      svwhdp      = siwhdp
KFS AC                   endif
KFS AC                   exsr      crtslot26
PANaA*
PANaAC                   when      client = Panos
PANaA*
PANaAC                   if        siwhdp <> svwhdp
PANaAC                   eval      dftlocation = 600
PANaAC                   eval      svwhdp      = siwhdp
PANaAC                   endif
PANaAC                   exsr      crtslot30
HARaA*
HARaAC                   when      client = Harbor
HARaA*
HARaAC                   if        siwhdp <> svwhdp
HARaAC                   eval      dftlocation = 600
HARaAC                   eval      svwhdp      = siwhdp
HARaAC                   endif
HARaAC                   exsr      crtslot31
PFG A*
PFG AC                   when      client = PFG
PFG A*
PFG AC                   if        siwhdp <> svwhdp
PFG AC                   eval      dftlocation = 600
PFG AC                   eval      svwhdp      = siwhdp
PFG AC                   endif
PFG AC                   exsr      crtslot27
HMW A
HMW AC                   endsl


HMW AC                   if        notcreated
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   goto      prndtl
     C                   endif
HMW AC                   endif
     *
     *  If item doesn't exist write error message.
     *
640bAC                   eval      ittype = *blanks
640bAC                   if        siitem > ' '
640bA*
     C     keyit         chain     piritem                            76
     C                   if        *in76
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   goto      prndtl
     C                   endif
     *
     *  If item type not ' ' or 'B' write error message.
510aA*  and not type 'R' write error message.
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'  and
510aAC                             ittype <> 'R'
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(4)
     C                   add       1             badtyp
     C                   goto      prndtl
     C                   endif
     *
417  *  If item sent is not in the slot, write error message.
417  *
417  C                   if        sitype = 'P'  and
417  C                             siitem <> slitem
640aAC                   eval      error = *on
417  C                   eval      detmsg = desc(9)
417  C                   add       1             badtyp
417  C                   goto      prndtl
417  C                   endif
640bA*
700aDC***                endif
     *
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *  Check if breakdown qty is allowed using piritem file.
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *
     C                   eval      good1 = 'N'
     C                   exsr      zzbkdn
640aAC                   if        good1 = 'N'
640aAC                   eval      error = *on
700aAC                   eval      detmsg = desc(3)
640aAC                   endif
     C     good1         cabeq     'N'           prndtl
     *
     *  If doing manual putaway,
     *   Then get actual slot to use for the putaway.
     *
414bAC                   eval      newvs = *off
     C                   if        opmput = 'Y'
     C                   exsr      zzman
     C     error         cabeq     *on           prndtl
     C                   endif
     *
700aAC                   endif
     *
     *  Update slot record.
     *
     C                   exsr      zzupd
     *
     *  Print detail and update subtotals
     *
     C     prndtl        tag
     C                   if        detmsg <> *blanks
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      sistatus = 'E'
640aAC                   eval      sitext   = detmsg
640aAC                   else
640aAC                   eval      sistatus = 'S'
700aAC                   eval      sitext = 'Slot added/updated successfully'
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      siststs = stamp
640aAC                   eval      sistsuc = stampuc
640aAC                   update    sirec
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   exsr      zrhead
     C                   write     grndttl
     *
     *  We are finished so get out
     *
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 AC                   parm                    cliloc           10
510 A*
     C                   eval      error = *off
     C                   eval      exist = *off
     C                   eval      newvs = *off
720bAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     *
     * Key definitions
     *
640aA*
640aA*  Define key for impsstuf file.
640aA*
640aAC     keysi         klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
     * Item file
     *
     C     keyit         klist
     C                   kfld                    siwhse
     C                   kfld                    siitem
     *
     * Slot2 file
     *
     C     keysl2        klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp
     *
     *  OPTIOND file
     *
     C     keyop         klist
     C                   kfld                    kycode
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     *
510bA*    Define key for OPTIONS file.
     *
510bAC     opkey         klist
510bAC                   kfld                    siwhse
510bAC                   kfld                    kyocod
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    vsdisp
     *
417d C     keysvs        klist
417d C                   kfld                    siwhse
417d C                   kfld                    siwhdp
417d C                   kfld                    vxdisp
     *
     C     ckkey         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    $vdisp
     *
417  *  Convert today's date into century format.
417  *
417  C                   eval      $cvcmd = '*CURCMD '
417  C                   call      @cvtdt
417  C                   parm                    $cvtdt
417  C                   eval      today = $cvd8o
     *
     *
     *  Define variables
     *
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
650aDC*    1             do        27            i
650aMC     1             do        37            i
650aDC*    2             do        27            j
650aMC     2             do        37            j
650aA*
650aA*      Values 0 - 9 not allowed for position 2 with A-Z Handstack.
650aAC                   if        I >= 2 and I <= 27
650aAC                             and J >= 28
650aA*
650aA*      Values 0 - 9 not allowed for position 2 with 0-9 Handstack.
650aAC                              or I >= 28
650aAC                             and J >= 28
650aAC                   leave
650aAC                   endif
650aA*
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      $lprg = #prog
     *
720a  /free
720a    // Get Feature Code from OPTIONS
720a    chain ($pWhse: '*FEATURE') options;
720a    if %found(options);
720a      optFeature = %subst(opdata: 1: 1);
720a    else;
720a      optFeature = ' ';
720a    endif;
720a  /end-free

KFSeA /free
KFSeA    // Special client preprocessing
KFSeA    select;
KFSeA      when client = Kellys;
KFSeA        // Kelly's on Full System, do not load slots
KFSeA        exsr zzzEnd;
KFSeA        *inlr = *on;
KFSeA        return;
KFSeA    endsl;
KFSeA /end-free
     *
     C                   endsr

HMW A*----------------------------------------------------------------
HMW A*  crtslot25  Try and create physical slot.
HMW A*----------------------------------------------------------------
HMW A
HMW AC     crtslot25     begsr
HMW AC                   eval      notcreated = *off
HMW A
HMW A*  Turn on SlotCreated flag even if slot isn't created
HMW A*  so ZZUPD routine doesn't get executed.
HMW AC                   eval      slotcreated= *on
HMW AC                   eval      handstack  = *off
HMW AC                   clear                   slrec
HMW A
HMW A*  Extract location and level. Test if they are numeric.
HMW A
HMW AC                   eval      locnotnum = *off
HMW AC                   eval      lvlnotnum = *off
HMW AC                   eval      dashpos = 0
HMW AC                   eval      loca  = ' '
HMW AC                   eval      lvla  = ' '
HMW A
HMW A*  Check for all alpha slot. If no digits, default slot location
HMW A*  will be assigned.
HMW AC                   If            %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMWcA*  No dashes specified. 3 character aisle, rack level=4th position.
HMWcA*  Slot format: ZXCR11
HMWcAC                             or  (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or  %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and %subst(sidisp:4:1) >= 'A'
HMWcAC                             and %subst(sidisp:4:1) <= 'Z'
HMWcA*  No dashes specified. 3 character aisle, rack level=5th position.
HMWcA*  Slot format: ZXC1A1
HMWcAC                             or  (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or  %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and %subst(sidisp:4:1) >= '0'
HMWcAC                             and %subst(sidisp:4:1) <= '9'
HMW AC                   eval      allchrslot = *off
HMW AC                   else
HMW AC                   eval      allchrslot = *on
HMW AC                   endif
HMW A
HMW A
HMW AC                   select
HMW A
HMW A*  No dashes specified. All character slot.
HMW AC                   when      allchrslot = *on
HMW AC
HMW AC                   eval      kydisp = sidisp
HMW AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
HMW AC
HMW AC                   eval      dftlocation = dftlocation + 1
HMW AC                   eval      loca   = %char(dftlocation)
HMW AC                   eval      slloc  = dftlocation
HMW AC
HMW AC                   eval      slrlvl = 1
HMW AC                   eval      lvla   = '1'
HMW AC
HMW AC                   eval      slhand  = '  '
HMW AC                   eval      dashpos = -1
HMW A
HMW A*  No Dashes specified. Dbl char aisle, alpha rack lvl (Ex 2232D1).
HMW AC                   when          %subst(sidisp:2:1) > ' '
HMW AC                             and %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMW AC                             and %subst(sidisp:5:1) >= 'A'
HMW AC                             and %subst(sidisp:5:1) <= 'Z'
HMW AC                   eval      dashpos = -1
HMW AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMW AC                   eval      loca  = '0' + %subst(sidisp:3:2)
HMW AC                   move      loca          slloc
HMW A*
HMW A*      Convert alpha level into numeric value.
HMW AC                   eval      lvla    = %subst(sidisp:5:1)
HMW AC                   evalr     wkchar = %trimr(lvla)
HMW AC                   exsr      zzcvt2nbr
HMW AC                   if        nwchar > ' '
HMW AC                   evalr     lvla   = %trimr(nwchar)
HMW AC                   eval      slrlvl = %dec(nwchar:2:0)
HMW AC                   else
HMW AC                   evalr     lvla  = '1'
HMW AC                   move      lvla          slrlvl
HMW AC                   endif
HMW AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMW A
HMW A
HMW A*  No Dashes specified. Dbl char aisle, numeric rack lvl (Ex SC053A)
HMW AC                   when          %subst(sidisp:2:1) > ' '
HMW AC                             and %subst(sidisp:3:2) >= '00'
HMW AC                             and %subst(sidisp:3:2) <= '99'
HMW AC                             and %subst(sidisp:5:1) >= '0'
HMW AC                             and %subst(sidisp:5:1) <= '9'
HMW AC                   eval      dashpos = -1
HMW AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HMW AC                   eval      loca  = %subst(sidisp:3:3)
HMW AC                   move      loca          slloc
HMW A*
HMW AC                   evalr     lvla  = %subst(sidisp:6:1)
HMW AC                   move      lvla          slrlvl
HMW AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
HMWcA
HMWcA*  No Dashes specified. 3 char aisle, alpha rack lvl (Ex ZXC1A1).
HMWcAC                   when          %subst(sidisp:2:1) > ' '
HMWcAC                             and (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or   %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and  %subst(sidisp:4:1) >= '0'
HMWcAC                             and  %subst(sidisp:4:1) <= '9'
HMWcAC                   eval      dashpos = -1
HMWcAC                   eval      slaisl = %subst(sidisp:1:3)
HMWcAC                   eval      loca  = '00' + %subst(sidisp:4:1)
HMWcAC                   move      loca          slloc
HMWcA*
HMWcA*      Convert alpha level into numeric value.
HMWcAC                   eval      lvla    = %subst(sidisp:5:1)
HMWcAC                   evalr     wkchar = %trimr(lvla)
HMWcAC                   exsr      zzcvt2nbr
HMWcAC                   if        nwchar > ' '
HMWcAC                   evalr     lvla   = %trimr(nwchar)
HMWcAC                   eval      slrlvl = %dec(nwchar:2:0)
HMWcAC                   else
HMWcAC                   evalr     lvla  = '1'
HMWcAC                   move      lvla          slrlvl
HMWcAC                   endif
HMWcAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMWcA
HMWcA*  No Dashes specified. 3 char aisle, alpha rack lvl (Ex ZXCR11).
HMWcAC                   when          %subst(sidisp:2:1) > ' '
HMWcAC                             and (%subst(sidisp:1:3) = 'ZXC'
HMWcAC                             or   %subst(sidisp:1:3) = 'ZXF')
HMWcAC                             and  %subst(sidisp:4:1) >= 'A'
HMWcAC                             and  %subst(sidisp:4:1) <= 'Z'
HMWcAC                   eval      dashpos = -1
HMWcAC                   eval      slaisl = %subst(sidisp:1:3)
HMWcAC                   eval      loca  = '00' + %subst(sidisp:5:1)
HMWcAC                   move      loca          slloc
HMWcA*
HMWcA*      Convert alpha level into numeric value.
HMWcAC                   eval      lvla    = %subst(sidisp:4:1)
HMWcAC                   evalr     wkchar = %trimr(lvla)
HMWcAC                   exsr      zzcvt2nbr
HMWcAC                   if        nwchar > ' '
HMWcAC                   evalr     lvla   = %trimr(nwchar)
HMWcAC                   eval      slrlvl = %dec(nwchar:2:0)
HMWcAC                   else
HMWcAC                   evalr     lvla  = '1'
HMWcAC                   move      lvla          slrlvl
HMWcAC                   endif
HMWcAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
HMW A
HMW AC                   endsl
HMW A
HMW A*  Begin testing parts for ALL slots.
HMW AC                   testn                   loca                 5050
HMW AC                   if        *in50 = *off
HMW AC                   eval      locnotnum = *on
HMW A
HMW AC                   else
HMW AC                   select
HMW AC                   when      slloc  = 0
HMW AC*                  eval      slloc = slloc + 100
HMW AC                   when      slloc < 0
HMW AC                   eval      slloc = slloc * -1
HMW AC                   endsl
HMW AC                   endif
HMW A
HMW AC                   testn                   lvla                 50
HMW AC                   if        *in50 = *off
HMW AC                   eval      lvlnotnum = *on
HMW AC                   else
HMW AC                   select
HMW AC                   when      slrlvl = 0
HMW AC*                  eval      slrlvl = slrlvl + 1
HMW AC                   when      slrlvl < 0
HMW AC                   eval      slrlvl = slrlvl * -1
HMW AC                   endsl
HMW AC                   endif
HMW A
HMW A*    Convert numeric handstack to alpha character.
HMW A
HMW AC*                  if            slhand >= ' 0'
HMW AC*                            and slhand <= '99'
HMW AC*                  eval      wkchar = slhand
HMW AC*                  exsr      zzcvt2ltr
HMW AC*                  eval      slhand = nwchar
HMW AC*                  endif
HMW A
HMW AC     slloc         div       2             dummy
HMW AC                   mvr                     oddeven
HMW AC                   if        oddeven <> 0
HMW AC                   eval      slside = 1
HMW AC                   else
HMW AC                   eval      slside = 0
HMW AC                   endif
HMW A
HMW A*    See if slot meets criteria for allowing it to be created.
HMW A
HMW AC                   select
HMW A
HMW A*    If non-special slot doesn't have hypens, then don't add it.
HMW A
HMW AC                   when      dashpos = 0
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    Don't allow creation if department is unknown.
HMW A
HMW AC                   when      validdept = '*NO '
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    If location or level is not numeric, then don't add.
HMW A
HMW AC                   when      locnotnum or lvlnotnum
HMW AC                   eval      notcreated = *on
HMW AC                   goto      endcreate25
HMW A
HMW A*    Otherwise, slot is ok to be created.
HMW A
HMW AC                   other
HMW AC                   eval      slwhdp = siwhdp
HMW AC                   eval      sldisp = sidisp
HMW AC                   eval      slstyp = sistyp
HMW A
HMW AC                   endsl
HMW A
HMW A*    Try and create the imported slot.
HMW A
HMW AC                   eval      slwhse = siwhse
HMW AC                   eval      slpseq = sipseq
HMW AC*
HMW AC                   select
HMW AC                   when      slpseq = 0
HMW AC                   eval      slpseq = slloc
HMW AC                   when      slpseq < 0
HMW AC                   eval      slpseq = slpseq * -1
HMW AC                   endsl
HMW AC                   if        slitem > ' '
HMW AC                   eval      slstat = 'A'
HMW AC                   else
HMW AC                   eval      slstat = 'V'
HMW AC                   endif
HMW A*
HMW AC                   eval      slrsrv = sirsrv
HMW AC                   eval      slsdef = 'XX'
HMW AC                   eval      slpick = sipick
HMW A
HMW AC                   write (e) slrec
HMW AC                   if        %error
HMW AC                   eval      notcreated = *on
HMW AC                   endif
HMW A
HMW AC     endcreate25   endsr

KFS A*----------------------------------------------------------------
KFS A*  crtslot26  Try and create physical slot.
KFS A*----------------------------------------------------------------
KFS A
KFS AC     crtslot26     begsr
KFS AC                   eval      notcreated = *off
KFS A
KFS A*  Turn on SlotCreated flag even if slot isn't created
KFS A*  so ZZUPD routine doesn't get executed.
KFS AC                   eval      slotcreated= *on
KFS AC                   eval      handstack  = *off
KFS AC                   clear                   slrec
KFS A
KFS A*  Extract location and level. Test if they are numeric.
KFS A
KFS AC                   eval      locnotnum = *off
KFS AC                   eval      lvlnotnum = *off
KFS AC                   eval      dashpos = 0
KFS AC                   eval      loca  = ' '
KFS AC                   eval      lvla  = ' '
KFS A
KFS A*  Check for all alpha slot. If no digits, default slot location
KFS A*  will be assigned.
KFS AC                   If            %subst(sidisp:3:2) >= '00'
KFS AC                             and %subst(sidisp:3:2) <= '99'
KFS AC                             and %subst(sidisp:5:1) >= 'A'
KFS AC                             and %subst(sidisp:5:1) <= 'Z'
KFSaA*
KFSaAC                             or  %subst(sidisp:3:1) = '-'
KFSaAC                             and %subst(sidisp:4:2) >= '00'
KFSaAC                             and %subst(sidisp:4:2) <= '99'
KFSaAC                             and %subst(sidisp:6:1) = '-'
KFSaAC                             and %subst(sidisp:7:1) >= 'A'
KFSaAC                             and %subst(sidisp:7:1) <= 'Z'
KFSaA*
KFSaAC                             or  %subst(sidisp:3:1) = '-'
KFSaAC                             and %subst(sidisp:4:2) >= '00'
KFSaAC                             and %subst(sidisp:4:2) <= '99'
KFSaAC                             and %subst(sidisp:6:1) = '-'
KFSaAC                             and %subst(sidisp:7:1) >= '0'
KFSaAC                             and %subst(sidisp:7:1) <= '9'
KFSaA*
KFSaAC                              or %subst(sidisp:2:2) >= '00'
KFSaAC                             and %subst(sidisp:2:2) <= '99'
KFS AC                             and %subst(sidisp:4:1) >= 'A'
KFS AC                             and %subst(sidisp:4:1) <= 'Z'
KFS AC                             and %subst(sidisp:5:1)  = ' '
KFScA*
KFScAC                             or  %subst(sidisp:3:1) = '-'
KFScAC                             and %subst(sidisp:4:3) >= '000'
KFScAC                             and %subst(sidisp:4:3) <= '999'
KFScAC                             and %subst(sidisp:7:1) = '-'
KFScAC                             and %subst(sidisp:8:1) >= '0'
KFScAC                             and %subst(sidisp:8:1) <= '9'
KFSdA*
KFSdAC                             or  %subst(sidisp:4:1) = '-'
KFSdAC                             and %subst(sidisp:5:3) >= '000'
KFSdAC                             and %subst(sidisp:5:3) <= '999'
KFSdAC                             and %subst(sidisp:8:1) = '-'
KFSdAC                             and %subst(sidisp:9:1) >= '0'
KFSdAC                             and %subst(sidisp:9:1) <= '9'
KFS AC                   eval      allchrslot = *off
KFS AC                   else
KFS AC                   eval      allchrslot = *on
KFS AC                   endif
KFS A
KFS A
KFS AC                   select
KFS A
KFS A*  No dashes specified. All character slot.
KFS AC                   when      allchrslot = *on
KFS AC
KFS AC                   eval      kydisp = sidisp
KFS AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
KFS AC
KFS AC                   eval      dftlocation = dftlocation + 1
KFS AC                   eval      loca   = %char(dftlocation)
KFS AC                   eval      slloc  = dftlocation
KFS AC
KFS AC                   eval      slrlvl = 1
KFS AC                   eval      lvla   = '1'
KFS AC
KFS AC                   eval      slhand  = '  '
KFS AC                   eval      dashpos = -1
KFSaA
KFSaA*  No Dashes specified. Single char aisle, alpha rack lvl (Ex F02A).
KFSaAC                   when          %subst(sidisp:2:2) >= '00'
KFSaAC                             and %subst(sidisp:2:2) <= '99'
KFSaAC                             and %subst(sidisp:4:1) >= 'A'
KFSaAC                             and %subst(sidisp:4:1) <= 'Z'
KFSaAC                             and %subst(sidisp:5:1)  = ' '
KFSaAC                   eval      dashpos = -1
KFSaAC                   eval      slaisl = ' .' + %subst(sidisp:1:1)
KFSaAC                   eval      loca  = '0' + %subst(sidisp:2:2)
KFSaAC                   move      loca          slloc
KFSaA*
KFSaA*      Convert alpha level into numeric value.
KFSaAC                   eval      lvla    = %subst(sidisp:4:1)
KFSaAC                   evalr     wkchar = %trimr(lvla)
KFSaAC                   exsr      zzcvt2nbr
KFSaAC                   if        nwchar > ' '
KFSaAC                   evalr     lvla   = %trimr(nwchar)
KFSaAC                   eval      slrlvl = %dec(nwchar:2:0)
KFSaAC                   else
KFSaAC                   evalr     lvla  = '1'
KFSaAC                   move      lvla          slrlvl
KFSaAC                   endif
KFSaAC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
KFS A
KFS A*  No Dashes specified. Dbl char aisle, alpha rack lvl (Ex FA02A).
KFS AC                   when          %subst(sidisp:3:2) >= '00'
KFS AC                             and %subst(sidisp:3:2) <= '99'
KFS AC                             and %subst(sidisp:5:1) >= 'A'
KFS AC                             and %subst(sidisp:5:1) <= 'Z'
KFS AC                   eval      dashpos = -1
KFS AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KFS AC                   eval      loca  = '0' + %subst(sidisp:3:2)
KFS AC                   move      loca          slloc
KFS A*
KFS A*      Convert alpha level into numeric value.
KFS AC                   eval      lvla    = %subst(sidisp:5:1)
KFS AC                   evalr     wkchar = %trimr(lvla)
KFS AC                   exsr      zzcvt2nbr
KFS AC                   if        nwchar > ' '
KFS AC                   evalr     lvla   = %trimr(nwchar)
KFS AC                   eval      slrlvl = %dec(nwchar:2:0)
KFS AC                   else
KFS AC                   evalr     lvla  = '1'
KFS AC                   move      lvla          slrlvl
KFS AC                   endif
KFS AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
KFS A
KFS A
KFS A*  No Dashes specified. Dbl char aisle, numeric rack lvl (Ex FA021)
KFS AC                   when          %subst(sidisp:3:2) >= '00'
KFS AC                             and %subst(sidisp:3:2) <= '99'
KFS AC                             and %subst(sidisp:5:1) >= '0'
KFS AC                             and %subst(sidisp:5:1) <= '9'
KFS AC                   eval      dashpos = -1
KFS AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KFSaDC*                  eval      loca  = %subst(sidisp:3:3)
KFSaNC                   eval      loca  = '0' + %subst(sidisp:3:2)
KFS AC                   move      loca          slloc
KFS A*
KFS AC                   evalr     lvla  = %subst(sidisp:5:1)
KFS AC                   move      lvla          slrlvl
KFS AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
KFSaA
KFSaA*  Dashes specified. Dbl char aisle, alpha rack lvl (Ex FA-02-A).
KFSaAC                   when          %subst(sidisp:3:1)  = '-'
KFSaAC                             and %subst(sidisp:4:2) >= '00'
KFSaAC                             and %subst(sidisp:4:2) <= '99'
KFSaAC                             and %subst(sidisp:6:1)  = '-'
KFSaAC                             and %subst(sidisp:7:1) >= 'A'
KFSaAC                             and %subst(sidisp:7:1) <= 'Z'
KFSaAC                   eval      dashpos = -1
KFSaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KFSaAC                   eval      loca  = '0' + %subst(sidisp:4:2)
KFSaAC                   move      loca          slloc
KFSaA*
KFSaA*      Convert alpha level into numeric value.
KFSaAC                   eval      lvla    = %subst(sidisp:7:1)
KFSaAC                   evalr     wkchar = %trimr(lvla)
KFSaAC                   exsr      zzcvt2nbr
KFSaAC                   if        nwchar > ' '
KFSaAC                   evalr     lvla   = %trimr(nwchar)
KFSaAC                   eval      slrlvl = %dec(nwchar:2:0)
KFSaAC                   else
KFSaAC                   evalr     lvla  = '1'
KFSaAC                   move      lvla          slrlvl
KFSaAC                   endif
KFSaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
KFSaA
KFSaA
KFSaA*  Dashes specified. Dbl char aisle, numeric rack lvl (Ex FA-02-1)
KFSaAC                   when          %subst(sidisp:3:1)  = '-'
KFSaAC                             and %subst(sidisp:4:2) >= '00'
KFSaAC                             and %subst(sidisp:4:2) <= '99'
KFSaAC                             and %subst(sidisp:6:1)  = '-'
KFSaAC                             and %subst(sidisp:7:1) >= '0'
KFSaAC                             and %subst(sidisp:7:1) <= '9'
KFSaAC                   eval      dashpos = -1
KFSaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KFSaAC                   eval      loca  = '0' + %subst(sidisp:4:2)
KFSaAC                   move      loca          slloc
KFSaA*
KFSaAC                   evalr     lvla  = %subst(sidisp:7:1)
KFSaAC                   move      lvla          slrlvl
KFSaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
KFSaA
KFScA
KFScA*  Dashes specified. Dbl char aisle, numeric rack lvl (Ex DA-152-1A)
KFScAC                   when          %subst(sidisp:3:1)  = '-'
KFScAC                             and %subst(sidisp:4:3) >= '000'
KFScAC                             and %subst(sidisp:4:3) <= '999'
KFScAC                             and %subst(sidisp:7:1)  = '-'
KFScAC                             and %subst(sidisp:8:1) >= '0'
KFScAC                             and %subst(sidisp:8:1) <= '9'
KFScAC                   eval      dashpos = -1
KFScAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
KFScAC                   eval      loca  = %subst(sidisp:4:3)
KFScAC                   move      loca          slloc
KFScA*
KFScAC                   evalr     lvla  = %subst(sidisp:8:1)
KFScAC                   move      lvla          slrlvl
KFScAC                   evalr     slhand  = %trimr(%subst(sidisp:9:2))
KFScA
KFSdA
KFSdA*  Dashes specified. Triple char aisle, numeric rack lvl (Ex WGD-241-1)
KFSdAC                   when          %subst(sidisp:4:1)  = '-'
KFSdAC                             and %subst(sidisp:5:3) >= '000'
KFSdAC                             and %subst(sidisp:5:3) <= '999'
KFSdAC                             and %subst(sidisp:8:1)  = '-'
KFSdAC                             and %subst(sidisp:9:1) >= '0'
KFSdAC                             and %subst(sidisp:9:1) <= '9'
KFSdAC                   eval      dashpos = -1
KFSdAC                   eval      slaisl = %subst(sidisp:1:3)
KFSdAC                   eval      loca  = %subst(sidisp:5:3)
KFSdAC                   move      loca          slloc
KFSdA*
KFSdAC                   evalr     lvla  = %subst(sidisp:9:1)
KFSdAC                   move      lvla          slrlvl
KFSdAC                   evalr     slhand  = %trimr(%subst(sidisp:10:2))
KFSdA
KFS AC                   endsl
KFS A
KFS A*  Begin testing parts for ALL slots.
KFS AC                   testn                   loca                 5050
KFS AC                   if        *in50 = *off
KFS AC                   eval      locnotnum = *on
KFS A
KFS AC                   else
KFS AC                   select
KFS AC                   when      slloc  = 0
KFS AC*                  eval      slloc = slloc + 100
KFS AC                   when      slloc < 0
KFS AC                   eval      slloc = slloc * -1
KFS AC                   endsl
KFS AC                   endif
KFS A
KFS AC                   testn                   lvla                 50
KFS AC                   if        *in50 = *off
KFS AC                   eval      lvlnotnum = *on
KFS AC                   else
KFS AC                   select
KFS AC                   when      slrlvl = 0
KFS AC*                  eval      slrlvl = slrlvl + 1
KFS AC                   when      slrlvl < 0
KFS AC                   eval      slrlvl = slrlvl * -1
KFS AC                   endsl
KFS AC                   endif
KFS A
KFS AC     slloc         div       2             dummy
KFS AC                   mvr                     oddeven
KFS AC                   if        oddeven <> 0
KFS AC                   eval      slside = 1
KFS AC                   else
KFS AC                   eval      slside = 0
KFS AC                   endif
KFS A
KFS A*    See if slot meets criteria for allowing it to be created.
KFS A
KFS AC                   select
KFS A
KFS A*    If non-special slot doesn't have hypens, then don't add it.
KFS A
KFS AC                   when      dashpos = 0
KFS AC                   eval      notcreated = *on
KFS AC                   goto      endcreate26
KFS A
KFS A*    Don't allow creation if department is unknown.
KFS A
KFS AC                   when      validdept = '*NO '
KFS AC                   eval      notcreated = *on
KFS AC                   goto      endcreate26
KFS A
KFS A*    If location or level is not numeric, then don't add.
KFS A
KFS AC                   when      locnotnum or lvlnotnum
KFS AC                   eval      notcreated = *on
KFS AC                   goto      endcreate26
KFS A
KFS A*    Otherwise, slot is ok to be created.
KFS A
KFS AC                   other
KFS AC                   eval      slwhdp = siwhdp
KFS AC                   eval      sldisp = sidisp
KFS AC                   eval      slstyp = sistyp
KFS A
KFS AC                   endsl
KFS A
KFS A*    Try and create the imported slot.
KFS A
KFS AC                   eval      slwhse = siwhse
KFS AC                   eval      slpseq = sipseq
KFS AC*
KFS AC                   select
KFS AC                   when      slpseq = 0
KFS AC                   eval      slpseq = slloc
KFS AC                   when      slpseq < 0
KFS AC                   eval      slpseq = slpseq * -1
KFS AC                   endsl
KFS AC                   if        slitem > ' '
KFS AC                   eval      slstat = 'A'
KFS AC                   else
KFS AC                   eval      slstat = 'V'
KFS AC                   endif
KFS A*
KFS AC                   eval      slrsrv = sirsrv
KFS AC                   eval      slsdef = 'XX'
KFS AC                   eval      slpick = sipick
KFS A
KFS AC                   write (e) slrec
KFS AC                   if        %error
KFS AC                   eval      notcreated = *on
KFS AC                   endif
KFS A
KFS AC     endcreate26   endsr

PFG A*----------------------------------------------------------------
PFG A*  crtslot27  Try and create physical slot. PFG Performance Food Grp
PFG A*----------------------------------------------------------------
PFG A
PFG AC     crtslot27     begsr
PFG AC                   eval      notcreated = *off
PFG A
PFG A*  Turn on SlotCreated flag even if slot isn't created
PFG A*  so ZZUPD routine doesn't get executed.
PFG AC                   eval      slotcreated= *on
PFG AC                   eval      handstack  = *off
PFG AC                   clear                   slrec
PFG A
PFG A*  Extract location and level. Test if they are numeric.
PFG A
PFG AC                   eval      locnotnum = *off
PFG AC                   eval      lvlnotnum = *off
PFG AC                   eval      dashpos = 0
PFG AC                   eval      loca  = ' '
PFG AC                   eval      lvla  = ' '
PFG A
PFG A*  Check for all alpha slot. If no digits, default slot location
PFG A*  will be assigned.
PFG AC                   If            %subst(sidisp:3:3) >= '000'
PFG AC                             and %subst(sidisp:3:3) <= '999'
PFG AC                             and %subst(sidisp:6:1) >= '0'
PFG AC                             and %subst(sidisp:6:1) <= '9'
PFG AC                   eval      allchrslot = *off
PFG AC                   else
PFG AC                   eval      allchrslot = *on
PFG AC                   endif
PFG A
PFG A
PFG AC                   select
PFG A
PFG A*  No dashes specified. All character slot.
PFG AC                   when      allchrslot = *on
PFG AC
PFG AC                   eval      kydisp = sidisp
PFG AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
PFG AC
PFG AC                   eval      dftlocation = dftlocation + 1
PFG AC                   eval      loca   = %char(dftlocation)
PFG AC                   eval      slloc  = dftlocation
PFG AC
PFG AC                   eval      slrlvl = 1
PFG AC                   eval      lvla   = '1'
PFG AC
PFG AC                   eval      slhand  = '  '
PFG AC                   eval      dashpos = -1
PFG A
PFG A*  No Dashes specified. Dbl char aisle, alpha rack lvl (Ex CA123A).
PFG AC                   when          %subst(sidisp:3:3) >= '000'
PFG AC                             and %subst(sidisp:3:3) <= '999'
PFG AC                             and %subst(sidisp:6:1) >= 'A'
PFG AC                             and %subst(sidisp:6:1) <= 'Z'
PFG AC                   eval      dashpos = -1
PFG AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
PFG AC                   eval      loca  = %subst(sidisp:3:3)
PFG AC                   move      loca          slloc
PFG A*
PFG A*      Convert alpha level into numeric value.
PFG AC                   eval      lvla    = %subst(sidisp:6:1)
PFG AC                   evalr     wkchar = %trimr(lvla)
PFG AC                   exsr      zzcvt2nbr
PFG AC                   if        nwchar > ' '
PFG AC                   evalr     lvla   = %trimr(nwchar)
PFG AC                   eval      slrlvl = %dec(nwchar:2:0)
PFG AC                   else
PFG AC                   evalr     lvla  = '1'
PFG AC                   move      lvla          slrlvl
PFG AC                   endif
PFG AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
PFG A
PFG A
PFG A*  No Dashes specified. Dbl char aisle, numeric rack lvl (Ex CA1231)
PFG AC                   when          %subst(sidisp:3:3) >= '000'
PFG AC                             and %subst(sidisp:3:3) <= '999'
PFG AC                             and %subst(sidisp:6:1) >= '0'
PFG AC                             and %subst(sidisp:6:1) <= '9'
PFG AC                   eval      dashpos = -1
PFG AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
PFG AC                   eval      loca  = %subst(sidisp:3:3)
PFG AC                   move      loca          slloc
PFG A*
PFG AC                   evalr     lvla  = %subst(sidisp:6:1)
PFG AC                   move      lvla          slrlvl
PFG AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
PFG AC                   endsl
PFG A
PFG A*  Begin testing parts for ALL slots.
PFG AC                   testn                   loca                 5050
PFG AC                   if        *in50 = *off
PFG AC                   eval      locnotnum = *on
PFG A
PFG AC                   else
PFG AC                   select
PFG AC                   when      slloc  = 0
PFG AC*                  eval      slloc = slloc + 100
PFG AC                   when      slloc < 0
PFG AC                   eval      slloc = slloc * -1
PFG AC                   endsl
PFG AC                   endif
PFG A
PFG AC                   testn                   lvla                 50
PFG AC                   if        *in50 = *off
PFG AC                   eval      lvlnotnum = *on
PFG AC                   else
PFG AC                   select
PFG AC                   when      slrlvl = 0
PFG AC*                  eval      slrlvl = slrlvl + 1
PFG AC                   when      slrlvl < 0
PFG AC                   eval      slrlvl = slrlvl * -1
PFG AC                   endsl
PFG AC                   endif
PFG A
PFG AC     slloc         div       2             dummy
PFG AC                   mvr                     oddeven
PFG AC                   if        oddeven <> 0
PFG AC                   eval      slside = 1
PFG AC                   else
PFG AC                   eval      slside = 0
PFG AC                   endif
PFG A
PFG A*    See if slot meets criteria for allowing it to be created.
PFG A
PFG AC                   select
PFG A
PFG A*    If non-special slot doesn't have hypens, then don't add it.
PFG A
PFG AC                   when      dashpos = 0
PFG AC                   eval      notcreated = *on
PFG AC                   goto      endcreate27
PFG A
PFG A*    Don't allow creation if department is unknown.
PFG A
PFG AC                   when      validdept = '*NO '
PFG AC                   eval      notcreated = *on
PFG AC                   goto      endcreate27
PFG A
PFG A*    If location or level is not numeric, then don't add.
PFG A
PFG AC                   when      locnotnum or lvlnotnum
PFG AC                   eval      notcreated = *on
PFG AC                   goto      endcreate27
PFG A
PFG A*    Otherwise, slot is ok to be created.
PFG A
PFG AC                   other
PFG AC                   eval      slwhdp = siwhdp
PFG AC                   eval      sldisp = sidisp
PFG AC                   eval      slstyp = sistyp
PFG A
PFG AC                   endsl
PFG A
PFG A*    Try and create the imported slot.
PFG A
PFG AC                   eval      slwhse = siwhse
PFG AC                   eval      slpseq = sipseq
PFG AC*
PFG AC                   select
PFG AC                   when      slpseq = 0
PFG AC                   eval      slpseq = slloc
PFG AC                   when      slpseq < 0
PFG AC                   eval      slpseq = slpseq * -1
PFG AC                   endsl
PFG AC                   if        slitem > ' '
PFG AC                   eval      slstat = 'A'
PFG AC                   else
PFG AC                   eval      slstat = 'V'
PFG AC                   endif
PFG A*
PFG AC                   eval      slrsrv = sirsrv
PFG AC                   eval      slsdef = 'XX'
PFG AC                   eval      slpick = sipick
PFG A
PFG AC                   write (e) slrec
PFG AC                   if        %error
PFG AC                   eval      notcreated = *on
PFG AC                   endif
PFG A
PFG AC     endcreate27   endsr

PANaA*----------------------------------------------------------------
PANaA*  crtslot30  Try and create physical slot.
PANaA*----------------------------------------------------------------
PANaA
PANaAC     crtslot30     begsr
PANaAC                   eval      notcreated = *off
PANaA
PANaA*  Uppercase SIDISP
PANaAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
PANaA*  Uppercase SIITEM
PANaAC                   eval      siitem = %xlate(lower:UPPER:siitem)
PANaA
PANaA*  Turn on SlotCreated flag even if slot isn't created
PANaA*  so ZZUPD routine doesn't get executed.
PANaAC                   eval      slotcreated= *on
PANaAC                   eval      handstack  = *off
PANaAC                   clear                   slrec
PANaA
PANaA*  Extract location and level. Test if they are numeric.
PANaA
PANaAC                   eval      locnotnum = *off
PANaAC                   eval      lvlnotnum = *off
PANaAC                   eval      dashpos = 0
PANaAC                   eval      loca  = ' '
PANaAC                   eval      lvla  = ' '
PANaA
PANaA*  Check for all alpha slot. If no digits, default slot location
PANaA*  will be assigned.
PANaAC                   If            %subst(sidisp:4:3) >= '000'
PANaAC                             and %subst(sidisp:4:3) <= '999'
PANaAC                             and %subst(sidisp:3:1)  = '-'
PANaAC                             and %subst(sidisp:7:1)  = '-'
PANaAC                   eval      allchrslot = *off
PANaAC                   else
PANaAC                   eval      allchrslot = *on
PANaAC                   endif
PANaA
PANaA
PANaAC                   select
PANaA
PANaA*  No dashes specified. All character slot.
PANaAC                   when      allchrslot = *on
PANaAC
PANaAC                   eval      kydisp = sidisp
PANaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
PANaAC
PANaAC                   eval      dftlocation = dftlocation + 1
PANaAC                   eval      loca   = %char(dftlocation)
PANaAC                   eval      slloc  = dftlocation
PANaAC
PANaAC                   eval      slrlvl = 1
PANaAC                   eval      lvla   = '1'
PANaAC
PANaAC                   eval      slhand  = '  '
PANaAC                   eval      dashpos = -1
PANaA
PANaA*  Dashes specified. Double character aisle (Ex CA-172-A)
PANaAC                   when          %subst(sidisp:3:1) = '-'
PANaAC                             and %subst(sidisp:4:3) >= '000'
PANaAC                             and %subst(sidisp:4:3) <= '999'
PANaAC                             and %subst(sidisp:7:1)  = '-'
PANaAC                             and %subst(sidisp:8:1) >= 'A'
PANaAC                             and %subst(sidisp:8:1) <= 'Z'
PANaAC                   eval      dashpos = -1
PANaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
PANaAC                   eval      loca  = %subst(sidisp:4:3)
PANaAC                   move      loca          slloc
PANaA*
PANaA*      Convert alpha level into numeric value.
PANaAC                   eval      lvla    = %subst(sidisp:8:1)
PANaAC                   evalr     wkchar = %trimr(lvla)
PANaAC                   exsr      zzcvt2nbr
PANaAC                   if        nwchar > ' '
PANaAC                   evalr     lvla   = %trimr(nwchar)
PANaAC                   eval      slrlvl = %dec(nwchar:2:0)
PANaAC                   else
PANaAC                   evalr     lvla  = %subst(sidisp:8:1)
PANaAC                   move      lvla          slrlvl
PANaAC                   eval      slrlvl = slrlvl + 3
PANaAC                   endif
PANaAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
PANaA
PANaAC                   endsl
PANaA
PANaA*  Begin testing parts for ALL slots.
PANaAC                   testn                   loca                 5050
PANaAC                   if        *in50 = *off
PANaAC                   eval      locnotnum = *on
PANaA
PANaAC                   else
PANaAC                   select
PANaAC                   when      slloc  = 0
PANaAC                   eval      slloc = slloc + 100
PANaAC                   when      slloc < 0
PANaAC                   eval      slloc = slloc * -1
PANaAC                   endsl
PANaAC                   endif
PANaA
PANaAC                   testn                   lvla                 50
PANaAC                   if        *in50 = *off
PANaAC                   eval      lvlnotnum = *on
PANaAC                   else
PANaAC                   select
PANaAC                   when      slrlvl = 0
PANaAC                   eval      slrlvl = slrlvl + 1
PANaAC                   when      slrlvl < 0
PANaAC                   eval      slrlvl = slrlvl * -1
PANaAC                   endsl
PANaAC                   endif
PANaA
PANaA*    Convert numeric handstack to alpha character.
PANaA
PANaAC                   if            slhand >= ' 0'
PANaAC                             and slhand <= '99'
PANaAC                   eval      wkchar = slhand
PANaAC                   exsr      zzcvt2ltr
PANaAC                   eval      slhand = nwchar
PANaAC                   endif
PANaA
PANaAC     slloc         div       2             dummy
PANaAC                   mvr                     oddeven
PANaAC                   if        oddeven <> 0
PANaAC                   eval      slside = 1
PANaAC                   else
PANaAC                   eval      slside = 0
PANaAC                   endif
PANaA
PANaA*    See if slot meets criteria for allowing it to be created.
PANaA
PANaAC                   select
PANaA
PANaA*    If non-special slot doesn't have hypens, then don't add it.
PANaA
PANaAC                   when      dashpos = 0
PANaAC                   eval      notcreated = *on
PANaAC                   goto      endcreate30
PANaA
PANaA*    Don't allow creation if department is unknown.
PANaA
PANaAC                   when      validdept = '*NO '
PANaAC                   eval      notcreated = *on
PANaAC                   goto      endcreate30
PANaA
PANaA*    If location or level is not numeric, then don't add.
PANaA
PANaAC                   when      locnotnum or lvlnotnum
PANaAC                   eval      notcreated = *on
PANaAC                   goto      endcreate30
PANaA
PANaA*    Otherwise, slot is ok to be created.
PANaA
PANaAC                   other
PANaAC                   eval      slwhdp = siwhdp
PANaAC                   eval      sldisp = sidisp
PANaAC                   eval      slstyp = sistyp
PANaA
PANaAC                   endsl
PANaA
PANaA*    Try and create the imported slot.
PANaA
PANaAC                   eval      slwhse = siwhse
PANaAC                   eval      slpseq = sipseq
PANaAC*
PANaAC                   select
PANaAC                   when      slpseq = 0
PANaAC                   eval      slpseq = slloc
PANaAC                   when      slpseq < 0
PANaAC                   eval      slpseq = slpseq * -1
PANaAC                   endsl
PANaAC                   if        slitem > ' '
PANaAC                   eval      slstat = 'A'
PANaAC                   else
PANaAC                   eval      slstat = 'V'
PANaAC                   endif
PANaA*
PANaAC                   eval      slrsrv = sirsrv
PANaAC                   eval      slsdef = 'XX'
PANaAC                   eval      slpick = sipick
PANaA
PANaAC                   write (e) slrec
PANaAC                   if        %error
PANaAC                   eval      notcreated = *on
PANaAC                   endif
PANaA
PANaAC     endcreate30   endsr
PANaA
HARaA*----------------------------------------------------------------
HARaA*  crtslot31  Try and create physical slot.
HARaA*----------------------------------------------------------------
HARaA
HARaAC     crtslot31     begsr
HARaAC                   eval      notcreated = *off
HARaA
HARaA*  Uppercase SIDISP
HARaAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
HARaA
HARaA*  Turn on SlotCreated flag even if slot isn't created
HARaA*  so ZZUPD routine doesn't get executed.
HARaAC                   eval      slotcreated= *on
HARaAC                   eval      handstack  = *off
HARaAC                   clear                   slrec
HARaAC                   eval      slside = 0
HARaA
HARaA*    Don't allow creation if department is unknown.
HARaA
HARaAC                   if        validdept = '*NO '
HARaAC                   eval      notcreated = *on
HARaAC                   goto      endcreate31
HARaAC                   endif
HARaA
HARaA*    Otherwise, slot is ok to be created.
HARaA
HARaAC                   eval      slwhdp = siwhdp
HARaAC                   eval      sldisp = sidisp
HARaAC                   eval      slstyp = sistyp
HARaA
HARaA
HARaA*    Try and create the imported slot.
HARaA
HARaAC                   eval      slwhse = siwhse
HARaAC                   eval      slpseq = sipseq
HARaAC                   eval      slloc  = dftlocation
HARaAC*
HARaAC                   select
HARaAC                   when      slpseq = 0
HARaAC                   eval      slpseq = slloc
HARaAC                   when      slpseq < 0
HARaAC                   eval      slpseq = slpseq * -1
HARaAC                   endsl
HARaA*
HARaAC                   eval      slstat = 'V'
HARaAC                   eval      slrsrv = sirsrv
HARaAC                   eval      slsdef = 'XX'
HARaAC                   eval      slpick = sipick
HARaA
HARaAC                   write (e) slrec
HARaAC                   if        %error
HARaAC                   eval      notcreated = *on
HARaAC                   endif
HARaA
HARaAC     endcreate31   endsr
HARaA
     *----------------------------------------------------------------
     *
     *  FILLSL  Fill order detail fields.
     *
     C     fillsl        begsr
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   exsr      zzssb
     *
     C                   if        siqty2 <> 0  and
     C                             itflg1 <> 'Y'  and
     C                             ssbflg = *off
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty3 <> 0  and
     C                             itflg2 <> 'Y'  and
     C                             ssbflg = *off
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty2 <> 0  and
     C                             itflg1 = 'Y'  or
     C                             siqty2 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty3 <> 0  and
     C                             itflg2 = 'Y'  or
     C                             siqty3 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
ROY A*
ROY A*    Allow item to be updated into fixed pick slot even if all
ROY A*    quantities are zero.
ROY A*
ROY AC                   if        client = royal  or
TPC AC                             client = tpc
HMW AC                             or client = hmwagner
KFSbAC                             or client = Kellys
ROY A*
ROY AC                   if        siqty1 = 0  and
ROY AC                             siqty2 = 0  and
ROY AC                             siqty3 = 0  and
ROY AC                             slpick = 'Y'  and
ROY AC                             slstyp = 'F'
ROY AC                   eval      good1 = 'Y'
ROY AC                   endif
ROY A*
ROY AC                   endif
     *
     C                   endsr
417d *----------------------------------------------------------------
417d *
417d *  ZZCKDT   Check if item exists in reg or V slot for date
417d *
417d C     zzckdt        begsr
417d C                   eval      exsts = *off
640aDC**   keysl2        chain(n)  sslot2                             79
640aMC     keysl2        chain     sslot2                             79
417d C                   if        not *in79  and
417d C                             ssitem = siitem
417d C                   eval      exsts = *on
417d C                   goto      endckd
417d C                   else
417d C     keysl2        setll     svslot2
417d C     nxts1         tag
417d C     keysl2        reade     svslot2                                78
417d C                   if        not *in78
640aDC**   keysvs        chain(n)  sslot2                             79
640aMC     keysvs        chain     sslot2                             79
417d C                   if        not *in79  and
417d C                             ssitem = siitem
417d C                   eval      exsts = *on
417d ***                  MOVE SLDISP    SIDISP
417d C                   goto      endckd
417d C                   else
417d C                   goto      nxts1
417d C                   endif
417d C                   endif
417d C                   endif
417d *
417d C     endckd        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKNS   Use reg slot or get new Vslot.
     *
     C     zzckns        begsr
414aAC                   eval      newvs = *off
     C                   eval      error = *on
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   eval      error = *off
     C                   goto      endckn
     C                   else
     *
510bA*   When option 'allow virtual pick slots' is not Yes,
510bA*   get out if physical slot is a pick slot so we do not
510bA*   create virtual pick slots.
510bAC                   if        slpick = 'Y'  and
510bAC                             opvpck <> 'Y'
510bAC                   eval      error = *on
510bAC                   goto      endckn
510bAC                   endif
510bA*
     *
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     *
     C                   movea     slhand        a2
     C                   if        a2(1) <> ' '
     C                   goto      endckn
     C                   endif
     *
     *   Set handstack flag for later use.
     *
     C                   if        slhand <> ' '
     C                   eval      flaghs = *on
     C                   else
     C                   eval      flaghs = *off
     C                   endif
     *
     * SAVE PHYSICAL SLOT FIELDS
     *
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
     C                   eval      phaisl = slaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld = slbld
     C                   eval      phslfd = slslfd
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *
     *** Loop & increment handstack to find new v-slot to create.
     *
414cD**         K         DOWLE720
650aDC*                  dow       k < 702
650aMC                   dow       k < 802
     C                   add       1             k
     *
     *     If physical slot had handstack then limit hs we can use.
     *
     C                   if        flaghs = *on
     C                   movea     hnd(k)        a2n
     C                   if        a2n(1) <> a2(2)
     C                   iter
     C                   endif
     C                   endif
     C                   eval      $vhand = hnd(k)
     C                   call      'FRMTVS'
     C                   parm                    phdisp
     C                   parm                    flaghs
     C                   parm                    $vhand            2
     C                   parm                    $vdisp           12
     *
     C     ckkey         chain(n)  slot2                              79
     C                   if        *in79
     C                   eval      newvs = *on
     C                   eval      error = *off
     C                   eval      sidisp = $vdisp
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C     endckn        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKSL   Check if item exists in reg or V slot
     *
     C     zzcksl        begsr
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
     C                   eval      exist = *on
     C                   goto      endcks
     C                   else
     C     keysl2        setll     vslot2
     C     nxt1          tag
     C     keysl2        reade     vslot2                                 78
     C                   if        not *in78
     C     keyvs         chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
     C                   eval      exist = *on
     C                   eval      sidisp = sldisp
     C                   goto      endcks
     C                   else
     C                   goto      nxt1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcks        endsr
417c *----------------------------------------------------------------
417c *
417c *  ZZCRTL   Create adjustment label record.
417c *
417c C     zzcrtl        begsr
417cA*
417cAC                   clear                   lbrec
417cAC                   eval      lbwhse = slwhse
417cAC                   eval      lbwhdp = slwhdp
417cAC                   eval      lbaisl = slaisl
417cAC                   eval      lbloc = slloc
417cAC                   eval      lbrlvl = slrlvl
417cAC                   eval      lbhand = slhand
417cAC                   eval      lbpseq = slpseq
417cAC                   eval      lbstyp = slstyp
417cAC                   if        slstyp = 'P'
417cAC                   eval      lbqryf = 1
417cAC                   else
417cAC                   eval      lbqryf = 0
417cAC                   endif
417cAC                   eval      lbdisp = sldisp
417cAC                   eval      lbitem = slitem
417cAC                   eval      lbseq = 0
417cAC                   eval      lbpbat = 0
417cAC                   eval      lbpo = *blanks
417cAC                   eval      lbord = 0
417cAC                   eval      lbqalc = 0
417cAC                   eval      lbucub = 0
417cAC                   eval      lbcube = 0
417cAC                   eval      lbuwgt = 0
417cAC                   eval      lbswgt = 0
417cAC                   eval      lbtie = 0
417cAC                   eval      lbhigh = 0
417cAC                   eval      lbtrn# = 0
417cA*    Normal UOM
417cAC                   if        siqty1 <> 0
417cAC                   eval      lbqpck = siqty1
417cAC                   call      'PIRLBL#'
417cAC                   parm                    lblbl#
417cAC                   eval      lbgrp1 = *blanks
417cAC                   eval      lbgrp2 = *blanks
417cAC                   eval      lbutyp = 'N'
417cAC                   eval      lbucod = *blanks
417c *          *IN75     IFEQ *OFF
417cAC                   eval      lbucod = itum1
417c *                    ENDIF
417cAC                   eval      lbtype = 'A'
417cAC                   eval      lbstat = 'C'
417cAC                   eval      lbsdte = impdte
417cAC                   eval      lbstim = imptim
417cAC                   eval      lbrdte = impdte
417cAC                   eval      lbswgt = 0
417cAC                   write     lbrec
417cAC                   endif
417cA*
417cA*    BRK1 UOM
417cAC                   if        siqty2 <> 0
417cAC                   eval      lbqpck = siqty2
417cAC                   call      'PIRLBL#'
417cAC                   parm                    lblbl#
417cAC                   eval      lbgrp1 = *blanks
417cAC                   eval      lbgrp2 = *blanks
417cAC                   eval      lbutyp = *on
417cAC                   eval      lbucod = *blanks
417c *          *IN75     IFEQ *OFF
417cAC                   eval      lbucod = itum2
417c *                    ENDIF
417cAC                   eval      lbtype = 'A'
417cAC                   eval      lbstat = 'C'
417cAC                   eval      lbsdte = impdte
417cAC                   eval      lbstim = imptim
417cAC                   eval      lbrdte = impdte
417cAC                   eval      lbswgt = 0
417cAC                   write     lbrec
417cAC                   endif
417cA*
417cA*    BRK2 UOM
417cAC                   if        siqty3 <> 0
417cAC                   eval      lbqpck = siqty3
417cAC                   call      'PIRLBL#'
417cAC                   parm                    lblbl#
417cAC                   eval      lbgrp1 = *blanks
417cAC                   eval      lbgrp2 = *blanks
417cAC                   eval      lbutyp = '2'
417cAC                   eval      lbucod = *blanks
412 A*          *IN75     IFEQ *OFF
417cAC                   eval      lbucod = itum3
412aA*                    ENDIF
417cAC                   eval      lbtype = 'A'
417cAC                   eval      lbstat = 'C'
417cAC                   eval      lbsdte = impdte
417cAC                   eval      lbstim = imptim
417cAC                   eval      lbrdte = impdte
417cAC                   eval      lbswgt = 0
417cAC                   write     lbrec
417cAC                   endif
417c C     endctl        endsr
HMW A*
HMW A*----------------------------------------------------------------
HMW A*  zzcvt2ltr   Convert numeric handstack to alpha character.
HMW A*----------------------------------------------------------------
HMW A
HMW AC     zzcvt2ltr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' 0'
     C                             or wkchar = '  '
     C                   eval      nwchar = ' A'
     C
     C                   when      wkchar = ' 1'
     C                   eval      nwchar = ' B'
     C
     C                   when      wkchar = ' 2'
     C                   eval      nwchar = ' C'
     C
     C                   when      wkchar = ' 3'
     C                   eval      nwchar = ' D'
     C
     C                   when      wkchar = ' 4'
     C                   eval      nwchar = ' E'
     C
     C                   when      wkchar = ' 5'
     C                   eval      nwchar = ' F'
     C
     C                   when      wkchar = ' 6'
     C                   eval      nwchar = ' G'
     C
     C                   when      wkchar = ' 7'
     C                   eval      nwchar = ' H'
     C
     C                   when      wkchar = ' 8'
     C                   eval      nwchar = ' I'
     C
     C                   when      wkchar = ' 9'
     C                   eval      nwchar = ' J'
     C
     C                   endsl
HMW A
HMW AC     endcvt2ltr    endsr
HMW A
HMW A*----------------------------------------------------------------
HMW A*  zzcvt2nbr   Convert alpha character to numeric character.
HMW A*----------------------------------------------------------------
HMW A
HMW AC     zzcvt2nbr     begsr
HMW A
     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' A'
     C                             or wkchar = '  '
     C                   eval      nwchar = '01'
     C
     C                   when      wkchar = ' B'
     C                   eval      nwchar = '02'
     C
     C                   when      wkchar = ' C'
     C                   eval      nwchar = '03'
     C
     C                   when      wkchar = ' D'
     C                   eval      nwchar = '04'
     C
     C                   when      wkchar = ' E'
     C                   eval      nwchar = '05'
     C
     C                   when      wkchar = ' F'
     C                   eval      nwchar = '06'
     C
     C                   when      wkchar = ' G'
     C                   eval      nwchar = '07'
     C
     C                   when      wkchar = ' H'
     C                   eval      nwchar = '08'
     C
     C                   when      wkchar = ' I'
     C                   eval      nwchar = '09'
     C
     C                   when      wkchar = ' J'
     C                   eval      nwchar = '10'
     C
     C                   when      wkchar = ' K'
     C                   eval      nwchar = '11'
     C
     C                   when      wkchar = ' L'
     C                   eval      nwchar = '12'
     C
     C                   when      wkchar = ' M'
     C                   eval      nwchar = '13'
     C
     C                   when      wkchar = ' N'
     C                   eval      nwchar = '14'
     C
     C                   when      wkchar = ' O'
     C                   eval      nwchar = '15'
     C
     C                   when      wkchar = ' P'
     C                   eval      nwchar = '16'
     C
     C                   when      wkchar = ' Q'
     C                   eval      nwchar = '17'
     C
     C                   when      wkchar = ' R'
     C                   eval      nwchar = '18'
     C
     C                   when      wkchar = ' S'
     C                   eval      nwchar = '19'
     C
     C                   when      wkchar = ' T'
     C                   eval      nwchar = '20'
     C
     C                   when      wkchar = ' U'
     C                   eval      nwchar = '21'
     C
     C                   when      wkchar = ' V'
     C                   eval      nwchar = '22'
     C
     C                   when      wkchar = ' W'
     C                   eval      nwchar = '23'
     C
     C                   when      wkchar = ' X'
     C                   eval      nwchar = '24'
     C
     C                   when      wkchar = ' Y'
     C                   eval      nwchar = '25'
     C
     C                   when      wkchar = ' Z'
     C                   eval      nwchar = '26'
     C
     C                   endsl
HMW A
HMW AC     endcvt2nbr    endsr
HMW A
     *----------------------------------------------------------------
     *
     *  ZZMAN    Get slot to use for manual putaway.
     *
     C     zzman         begsr
     C                   eval      error = *off
414aAC                   eval      exist = *off
     *
     *  Check if item already exists in the base slot
     *    or in a corresponding virtual slot.
     *
     C                   exsr      zzcksl
     *
     *  If item doesn't already exist in the slot,
     *    Then try to get a new virtual slot number for it.
     *
     C                   if        exist = *off
     C                   exsr      zzckns
     C                   if        error = *on
510bAC                   if        slpick = 'Y'  and
510bAC                             opvpck <> 'Y'
510bAC                   eval      detmsg = desc(11)
510bAC                   else
     C                   eval      detmsg = desc(5)
510bAC                   endif
     C                   add       1             notcrt
     C                   goto      endman
     C                   endif
     C                   endif
     C     endman        endsr
     *----------------------------------------------------------------
     *
     *  ZZRCAL   Recalculate item quantity from slots.
     *
     C     zzrcal        begsr
     C                   eval      error = *off
     *
     * Recalculate item qty.
     C                   eval      $pwhs = lstwhs
     C                   eval      $jobq = 'N'
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm      '*ALL    '    $item            15
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcal        endsr
     *----------------------------------------------------------------
     *
     *  ZZSSB   Check for SSB item.
     *
     C     zzssb         begsr
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
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
415aA*    Same slot breakdown was found.
415aAC                   if        #brtn = '*FOUND  '
415aAC                   eval      ssbflg = *on
415aAC                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update slot file
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *   Update record.
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on                                       B01
417  C                   if        sitype = 'I'                                 SITYPE = 'I'
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
     C                   eval      slstat = 'A '
     C                   eval      slaisl = $vaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = phactv
     C                   eval      slbld = phbld
     C                   eval      slpseq = $vpseq
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
     C                   eval      slprty = 0
     C                   eval      slentd = impdte
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   eval      slitem = siitem
     *
     C                   eval      slstk1 = siqty1
     *
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     *
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
417d *  Check for item in saved files (sslot or svslot)
417d C                   exsr      zzckdt                                       SITYPE = 'I'
417d C                   if        exsts = *on
417d C                   eval      slexpd = ssexpd
417d C                   eval      slentd = ssentd
417d C                   endif
417d *
520aA*  clear allocate bucket
520aAC                   eval      slalc1 = 0
520aAC                   eval      slalc2 = 0
520aAC                   eval      slalc3 = 0
520aA*  clear receive bucket
520aAC                   eval      slrcv1 = 0
520aAC                   eval      slrcv2 = 0
520aAC                   eval      slrcv3 = 0
520aA*  clear pick bucket
520aAC                   eval      slpck1 = 0
520aAC                   eval      slpck2 = 0
520aAC                   eval      slpck3 = 0
520aA*  clear transfer bucket
520aAC                   eval      sltfr1 = 0
520aAC                   eval      sltfr2 = 0
520aAC                   eval      sltfr3 = 0
520aA*
     C                   write     slrec                                79
     C                   if        *in79                                               B03
     C                   eval      error = *on
414aMC                   eval      detmsg = desc(7)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif                                                         E03
     C                   add       1             sltcrt
     *
     *  create vslot record.
     *
     C                   eval      vswhse = $vwhse
     C                   eval      vswhdp = $vwhdp
     C                   eval      vsaisl = $vaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   eval      vspdis = phdisp
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79                                               B04
     C                   eval      error = *on
414aMC                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif                                                         E04
     *
417  C                   else                                                   SITYPE = 'P'
417  C                   eval      error = *on
417  C                   eval      detmsg = desc(10)
417  C                   add       1             notcrt
417  C                   goto      endupd
417  C                   endif                                                  SITYPE = 'I'
     ***
     C                   else                                                          XX
     *
     *** Update slot record
     *
     C     keysl2        chain     slot2                              79
     *
     C                   if        not *in79                                           B05
     *
     C                   eval      slitem = siitem
     C                   if        slstat = 'V '  or
     C                             slstat = 'Z '
     C                   eval      slstat = 'A '
     C                   endif
     *
417  C                   if        sitype = 'P'
417  C                   eval      slstk1 = slstk1 - siqty1
417  C                   else
     C                   eval      slstk1 = siqty1
417  C                   endif
     C                   if        itflg1 = 'Y'
417  C                   if        sitype = 'P'
417  C                   sub       siqty2        slstk2
417  C                   else
     C                   z-add     siqty2        slstk2
417  C                   endif
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
417  C                   if        sitype = 'P'
417  C                   sub       siqty3        slstk3
417  C                   else
     C                   z-add     siqty3        slstk3
417  C                   endif
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   eval      slentd = impdte
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
417d *  Check for item in saved files (sslot or svslot)
417d C                   exsr      zzckdt                                       SITYPE = 'I'
417d C                   if        exsts = *on
417d C                   eval      slexpd = ssexpd
417d C                   eval      slentd = ssentd
417d C                   endif
417d *
417  C                   if        sitype = 'P'
417  *
417  *   Check if status needs to be changed
417  *
417  C                   call      'CHKSTAT'
417  C                   parm                    slwhse
417  C                   parm                    slitem
417  C                   parm                    slstyp
417  C                   parm                    slrsrv
417  C                   parm                    slpick
417  C                   parm                    slstat
530aAC                   parm                    sldesg
417  C                   parm                    slstk1
417  C                   parm                    slstk2
417  C                   parm                    slstk3
417  C                   parm                    slalc1
417  C                   parm                    slalc2
417  C                   parm                    slalc3
417  C                   parm                    sltfr1
417  C                   parm                    sltfr2
417  C                   parm                    sltfr3
417  C                   parm                    slpck1
417  C                   parm                    slpck2
417  C                   parm                    slpck3
417  C                   parm                    slrcv1
417  C                   parm                    slrcv2
417  C                   parm                    slrcv3
417  C                   parm                    $cnews            2
417  C                   parm                    $crtn             8
     *
417  C                   if        $crtn = '*CHANGED'
417  C                   eval      slstat = $cnews
417  C                   eval      slsdte = today
417  C                   time                    slstim
417  C                   endif
417  C                   endif
     *
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
417b *  Reduce pick qty from ITEMQTY file.
417b C                   if        sitype = 'P'
417b C     keyit         chain     itemqty                            79
417b C                   if        not *in79
417b C                   eval      iqstk1 = iqstk1 - siqty1
417b C                   if        itflg1 = 'Y'
417b C                   sub       siqty2        slstk2
417b C                   endif
417b C                   if        itflg2 = 'Y'
417b C                   sub       siqty3        slstk3
417b C                   endif
417b C                   update    iqrec                                79
417b C                   endif
417b C                   endif
     *
417cMC     endupd        tag
417cAC                   if        error = *off
417cAC                   exsr      zzcrtl
417cAC                   endif
417cD**         ENDUPD    ENDSR
417cMC                   endsr
     *----------------------------------------------------------------
     *
510bA*  ZZVRTO   Get Virtual slot options
510bA*
510bAC     zzvrto        begsr
510bA*
510bAC                   eval      kyocod = '*VIRTUAL'
510bAC     opkey         chain     options                            79
510bAC                   if        *in79
510bAC                   eval      opvpck = 'N'
510bAC                   eval      opvall = 'N'
510bAC                   eval      opvslt = 'Y'
510bAC                   eval      opvexp = 'N'
510bAC                   eval      opvend = 'N'
510bAC                   eval      opvsam = 'N'
510bAC                   eval      opvedf = 'N'
510bAC                   else
510bAC                   eval      opdat4 = opdata
510bAC                   endif
510bA*
510bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsstuf file.';
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
                    + '- si255s/zzzend';
          leavesr;
        endif;

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
                  current_timestamp-current_timezone)
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
                    + '- si255s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID SLOT*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID ITEM TYPE*
*CAN'T CREATE VS/1*
*SLOT NOT UPDATED*
*CAN'T CREATE VS/2*
*CAN'T CREATE VS/3*
ITEM MISMATCH IN SLT
SLOT NOT FOUND
VIR PCK/SL NOT ALLOW         510bA
**
FTP StuffIt Import
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
