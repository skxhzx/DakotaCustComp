     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OP160     PIR options - General picking
     *  13 November 1998
     *  Roxanne Harrison
     *    4.10 CREATED
     *
     *  SK112 - 1.01
     *
     *----------------------------------------------------------------
     *  Revisions
     *
413aA*    03/13/00  MLB  4.13a
     *      - Revised routine ZZCHK1 to edit value entered into W1NRSC.
     *      - Revised routine ZZFIL1 to move OPNRSC to W1NRSC.
     *      - Revised routine ZZUPD1 to move W1NRSC to OPNRSC.
     *      - Added new field OPNRSC to *GENPICK DS.
     *      - Added new error message routine ZM0112.
     *      - Added new description to array DESC.
414aA*    03/30/00  MLB  4.14a
     *      - Revised routine ZZCHK1 to edit value entered into W1HPWC.
     *      - Revised routine ZZFIL1 to move OPHPWC to W1HPWC.
     *      - Revised routine ZZUPD1 to move W1HPWC to OPHPWC.
     *      - Added new field OPHPWC to *GENPICK DS.
     *      - Added new description to array DESC.
     *
416 A*    07/27/01  MLB  4.16
     *      - Revised routine ZZCHK1 to edit value entered into W1MRGA.
     *      - Revised routine ZZFIL1 to move OPMRGA to W1MRGA.
     *      - Revised routine ZZUPD1 to move W1MRGA to OPMRGA.
     *      - Added new field OPMRGA to *GENPICK DS.
     *      - Added new description to array DESC.
416aA*    08/06/01  MLB  4.16a
     *      - Revised routine ZZCHK1 to edit value entered into W1PLSQ.
     *      - Revised routine ZZFIL1 to move OPPLSQ to W1PLSQ.
     *      - Revised routine ZZUPD1 to move W1PLSQ to OPPLSQ.
     *      - Added new field OPPLSQ to *GENPICK DS.
     *      - Added new description to array DESC.
416bA*    04/19/02  RH   4.16a
     *      - Added new field OPEADJ to close out labels without
     *        an adjustment (slot will go negative)
     *
417 A*    07/03/03  MLB  4.17
     *      - Added new field OPNOPK to set flag for items without
     *        pick slots picked as bulk pick. (Y/N)
     *        Added new description to array DESC.
417aA*    03/31/04  DAS  4.17a
     *      - Fix: Revised ZZDFT1 to initialize all fields.
417bA*    05/18/04  MLB  4.17b
     *      - Added new field OPCLRF to Clear runner flags if qty
     *        still short/out. (Y/N)
     *        Added new description to array DESC.
417cA*    08/12/04  MLB  4.17c
     *      - Enh: Added new field OPRNRM to Sene break message to user
     *        when new Flag Runner task has been assigned.
     *      - Added new description to array DESC.
417dA*    09/21/04  RH   4.17d
     *      - Enh: Added new field OPJITR create JIT Letdown or Replenish
     *
500 A*    07/08/05  MLB  5.00
     *      - Enh: Added new code for OPJITR, N=No replenishments created.
500aA*    10/05/05  MLB  5.00a
     *      - Enh: Added new code for OPJITR, P=Regular letdowns created.
     *        Revised desc(14) to add new code to list of valid values.
500bA*    10/07/05  MLB  5.00b
     *      - Enh: Added new code for field W1JITR to screen. Converted
     *        all letter codes to numbers. Updated *GENPICK options with
     *        new values. All previous 5.00 changes for W1JITR have been
     *        overwritten for clarity.
500cA*    10/28/05  MLB  5.00c
     *      - Enh: Remove Runner options from program. Options being
     *        moved to new *RUNNER options record. Fields OPCLRF, OPRNRM.
500dA*    04/06/05  HNK  5.00d
     *      - Enh: Added new field OPPSET - Print separate Set Summary
     *        label for each pallet.
     *      - Added new description to array DESC.
500eA*    01/18/06  RH   5.00e
     *      - Enh: Added new field OPRFUC - RF Pick Verify with UPC
     *      - Enh: Added new field OPRFLC - RF Pick Verify with License
600aA*    05/09/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Renamed OP160FM to OP16001.
     *      - Removed JIT Letdown options 1, 3.
     *        Letdowns not allowed in license tracking.
610aA*    08/25/09  RH   6.10a
     *      - Enh: Added missed 5.20 change below.
     *      - Renamed OP16001 to OP16002.
     *      - 04/17/09  GJA  5.20a
     *      - Enh: Added new field OPRFSL - RF Pick Verify slot
     *      - Added new description to array DESC.
640aA*    01/17/12  JCJ  6.40a
     *      - Converted to RPGIV.
     *      - Renamed OP16002 to OP16003.
     *      - Added options OPRBN1, OPRBN2, OPSUBT
     *      - Added new description to array DESC.
     *      - Added screen 2.
650aA*    11/25/13  LMC  6.50a
     *      - Renamed OP16003 to OP16004.
     *      - Added options OPRFQT
     *      - moved RF pick fields to screen2
650bA*    12/02/13  LMC  6.50b
     *      - Renamed OP16004 to OP16005.
     *      - Added options OPRFCS - allow change slot
700aA*    09/09/16  MR   7.00a
     *      - Renamed OP16005 to OP16006.
     *      - Add RF Pick Method
     *      - Modify RF Pick Allow Qty Entry
     *      - Modify RF Pick Verify Slot
     *      - Use position 27-33 for ISupply because USF
     *      - is using 23-26.
700b *    10/10/16  GJA  7.00b
     *      - Renamed OP16006 to OP16007.
     *      - Put all RF Pick options on screen3
700c *    11/22/16  NLK  7.00c
     *      - FIX: Move field checks from zzchk2 to zzchk3
     *             w1rfuc, w1rflc, w1rfsl from 700b change
700d *    01/11/17  JCJ  7.00d
     *      - Renamed OP16007 to OP16008.
     *      - Enh: Added Print Pallet Label option.
710a *    01/18/17  LMC  7.00a
     *      - Renamed OP16008 to OP16009.
     *      - Fix: W1RFQTO was defined as alpha which caused OR400
     *        to blow up. Field should only allow numeric.
710b *    03/31/17  NLK  7.10b
     *      - Fix: oprfqto is numeric and may be blanks.
     *
720a *    05/30/18  LMC  7.20a
     *      - Enh: Renamed OP16009 to OP16010.
     *        Added new field to control whether the user will be
     *        required to scan the upc for each unit selected, or
     *        just a one time scan of the UPC.
     *
720b *    06/08/18  LMC  7.20b
     *      - Enh: Renamed OP16010 to OP16011.
     *        Added two new fields. Zone Pickup and auto load
     *        weight from individual upc scan.
     *
730a *    05/20/19  KDE  7.30a
     *      - Enh: Renamed OP16011 to OP16012.
     *        Added W2PSEQ (Pick Sequence)
     *
740a *    05/27/20  KDE  7.40a
     *      - Enh: Renamed OP16012 to OP16013. Added field OPCAD
     *        Customer Audit Duration (New Customers)
     *
740b *    08/24/20  KDE  7.40b
     *      - Enh: Renamed OP16013 to OP16014. Added fields opmsc,
     *        oppsvh,oppsvm,oppsvl,oppissv,oppissp,oppmssv,oppmssp,
     *        oppfdb
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
600aD*P160FM CF  E                    WORKSTN
610AD*P16001 CF  E                    WORKSTN
640aDF*op16002   cf   e             workstn
650aDF*op16003   cf   e             workstn
650bdF*op16004   cf   e             workstn
650bDF*op16005   cf   e             workstn
700aDF*op16006   cf   e             workstn
700bDF*op16007   cf   e             workstn
710aDF*op16008   cf   e             workstn
720aDF*op16009   cf   e             workstn
720bDF*op16010   cf   e             workstn
730aMF*op16011   cf   e             workstn
740aDF*p16012   cf   e             workstn
740bDF*op16013   cf   e             workstn
740bMFop16014   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
700dAFoptionz4  if   e           k disk
700dAFLblfmtd   if   e           k disk
740bAfopfeat    if   e           k disk    extfile(*EXTDESC)
740bAf                                     extdesc('OPTIONS')
740bAf                                     usropn prefix(f_)
740bAf                                     rename(oprec:oprecf)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
410BD*                   DESC    1   2 50
413aD*                   DESC    1   4 50
414aD*                   DESC    1   5 50
416 D*                   DESC    1   6 50
416aD*                   DESC    1   7 50
416bD*                   DESC    1   8 50
417 D*                   DESC    1   9 50
417bD*                   DESC    1  10 50
417cD*                   DESC    1  11 50
417DD*                   DESC    1  12 50
500dD*                   DESC    1  13 50
500eD*                   DESC    1  14 50
610aD*                   DESC    1  16 50
640aD * desc            s             50    dim(17) ctdata perrcd(1)
650aDD*desc            s             50    dim(20) ctdata perrcd(1)
650bDD*desc            s             50    dim(21) ctdata perrcd(1)
700aDD*desc            s             50    dim(22) ctdata perrcd(1)
700dDD*desc            s             50    dim(24) ctdata perrcd(1)
720bDD*desc            s             50    dim(26) ctdata perrcd(1)
730aMD*desc            s             50    dim(29) ctdata perrcd(1)
730aAD desc            s             50    dim(30) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     *----------------------------------------------------------------
     *  *GENPICK -  General picking.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N).
410BA*    OPRFWC  -  Using RF will call (Y,N).
413aA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
416 A*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
416aA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
416bA*    OPEADJ  -  Close short labels without adjustment (Y,N).
417 A*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500cM*    OPGPK1  -  <Not Used / Available>
500cM*    OPGPK2  -  <Not Used / Available>
417cA*               task has been assigned. (Y/N)
500bM*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500bM*                 0=None. No replenishments are created.
500bA*                 1=Letdowns are created during Truck Builder
500bA*                   Pick/Print processing.
500bA*                 2=Priority Replenishments are created during
500bA*                   Truck Builder Pick/Print processing.
500bA*                 3=JIT Letdowns created when transaction is
500bA*                   checked out.
500bA*                 4=JIT Priority Replenishments created when
500bA*                   transaction is checked out.
500dA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
500eA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
500eA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
700aA*    OPRFSL  -  RF Pick Verify slot
700aA*               Y=Yes
700aA*               N=No
700aA*               C=Scan Check Digit
700aA*               E=Enter to Continue
640aA*    OPRBN1  -  Round robin printing compatable (Y/N)
640aA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640aA*               1=Off
640aA*               2=By route
640aA*               3=By transaction
640aA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
650aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y/N)
700aA*    OPRFQTO -     With Quantity Over (if RF Pick Allow Qty Entry = Y)
710bA*    OPRFQTX -     Used to see if numeric field is blanks
650bA*    OPRFCS  -  RF Pick Allow Change Slot (Y/N)
700aA*    OPRFPM  -  RF Pick Method
700aA*               1=Manual
700aA*               2=Directed
700dA*    OPRPLT  -  Print Pallet Label
700dA*               1=Normal
700dA*               2=Big
700dA*               3=Both
700dA*               4=No
720aA*    OPRFUI  -  Scan individual UPC for each unit. (Y/N)
720bA*    OPRFZP  -  Zone Pickup
720bA*    OPRFUW  -  Auto load weight from individual UPC
730aA*    OPPSEQ  -  Slot Pick Sequence
740aA*    OPCAD   -  Customer Audit Duration (New Customers)
740bA*    OPPMSC  -  Allow merging with other Stops when cube less than this value
740bA*    OPPSVH  -    When above true allow stop as highest on pallet
740bA*    OPPSVM  -    When above true allow stop as middle on pallet
740bA*    OPPSVL  -    When above true allow stop as lowest on pallet
740bA*    OPPISSV -  Ideal trailer side-to-side weight difference
740bA*    OPPISSP -  Ideal trailer side-to-side percent difference
740bA*    OPPMSSV -  Max trailer side-to-side weight difference
740bA*    OPPMSSP -  Max trailver side-to-side percent difference
740bA*    OPPFDB  -  Allow Freezer pallet at rear door
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
410BAD  oprfwc                 3      3
413aAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
416 AD  opmrga                 6      6
416aAD  opplsq                 7      7
416aAD  opeadj                 8      8
417 AD  opnopk                 9      9
500cMD  opgpk1                10     10
500cMD  opgpk2                11     11
417dAD  opjitr                12     12
500dAD  oppset                13     13
500eAD  oprfuc                14     14
500eAD  oprflc                15     15
510hAD  opusf1                16     16
520aAD  oprfsl                17     17
640aAD  oprbn1                18     18
640aAD  oprbn2                19     19
640aAD  opsubt                20     20
650aAD  oprfqt                21     21
650bAD  oprfcs                22     22
700aAD  oprUSF                23     26
710bAD  oprfqtx               27     29
710aMD  oprfqto               27     29  0
700aAD  oprfpm                30     30
700dAD  oprplt                31     31
720aAD  oprfui                32     32
720bAD  oprfzp                33     33
720bAD  oprfuw                34     34
730aAD  oppseq                35     35
740aAD  opcad                 39     40  0
740bcD  oppmsc                41     42  0
740bcD  oppsvh                43     43
740bcD  oppsvm                44     44
740bcD  oppsvl                45     45
740bcD  oppissv               46     50  0
740bcD  oppissp               51     53  0
740bcD  oppmssv               54     58  0
740bcD  oppmssp               59     61  0
740bcD  oppfdb                62     62
     D  optend               117    117
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
410BA*
410BAD  erfld1                 1     20
410BAD  erfld2                21     40
410BAD  erval1                41     45
410BAD  erval2                46     50
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D warn            s              1
700dAD $plset          s              6
700dAD kyfmt           s                   like(lfdfmt)
700dAD forever         s               n
740bAd wkpltbl         s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
640aAC     nxtscr        caseq     '02 '         sc2
700aAC     nxtscr        caseq     '03 '         sc3
740bAC     nxtscr        caseq     '04 '         sc4
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
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
640aAC                   if        nxtscr = '02 '
640aAC                   exfmt     screen2                              50
640aAC                   endif
700aAC                   if        nxtscr = '03 '
700aAC                   exfmt     screen3                              50
700aAC                   endif
740bAC                   if        nxtscr = '04 '
740bAC                   exfmt     screen4                              50
740bAC                   endif
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
650bDC*                  setoff                                       3940
650bMC                   setoff                                       394041
720aMC                   setoff                                       424344
720bMC                   setoff                                       4546
740bAC                   setoff                                       474849
740bAc                   setoff                                       5556
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
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
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  Screen 02 initialization
640aA*
640aAC     scr02i        begsr
640aAC                   eval      nxtscr = '02 '
640aA*
640aAC                   if        $pcmd = '*VIEW   '
640aAC                   eval      *in90 = *on
640aAC                   endif
640aA*
640aA*  Get field defaults if this is an add.
640aA*
640aAC                   if        $pcmd = '*ADD    '
640aAC                   exsr      zzdft2
640aAC                   else
640aA*
640aA*  Otherwise get existing record(s).
640aA*
640aAC                   eval      *in91 = *on
640aAC                   exsr      zzget2
640aAC                   exsr      zzfil2
640aAC                   endif
640aAC     end02i        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  Screen 03 initialization
700aA*
700aAC     scr03i        begsr
700aAC                   eval      nxtscr = '03 '
700aA*
700aAC                   if        $pcmd = '*VIEW   '
700aAC                   eval      *in90 = *on
700aAC                   endif
700aA*
700aA*  Get field defaults if this is an add.
700aA*
700aAC                   if        $pcmd = '*ADD    '
700aAC                   exsr      zzdft3
700aAC                   else
700aA*
700aA*  Otherwise get existing record(s).
700aA*
700aAC                   eval      *in91 = *on
700aAC                   exsr      zzget3
700aAC                   exsr      zzfil3
700aAC                   endif
700aAC     end03i        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  Screen 04 initialization
740bA*
740bAC     scr04i        begsr
740bAC                   eval      nxtscr = '04 '
740bA*
740bAC                   if        $pcmd = '*VIEW   '
740bAC                   eval      *in90 = *on
740bAC                   endif
740bA*
740bA*  Get field defaults if this is an add.
740bA*
740bAC                   if        $pcmd = '*ADD    '
740bAC                   exsr      zzdft4
740bAC                   else
740bA*
740bA*  Otherwise get existing record(s).
740bA*
740bAC                   eval      *in91 = *on
740bAC                   exsr      zzget4
740bAC                   exsr      zzfil4
740bAC                   endif
740bAC     end04i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
640aAC                   exsr      scr02i
     *
     C     endsc1        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  SC2  -  Screen 2
640aA*
640aAC     sc2           begsr
640aA*
640aA*  Test for F3 - Exit
640aA*
640aAC                   if        *inkc
640aAC     *loval        setll     record
640aAC                   eval      nxtscr = 'EOJ'
640aAC                   eval      $prtn = '*EXIT   '
640aAC                   goto      endsc2
640aAC                   endif
640aA*
640aA*  Test for F5 - Refresh
640aA*
640aAC                   if        *inke
640aAC                   if        $pcmd <> '*VIEW   '
640aAC                   exsr      scr02i
640aAC                   endif
640aAC                   goto      endsc2
640aAC                   endif
640aA*
640aA*  Test for F12 - Previous
640aA*
640aAC                   if        *inkl
640aAC     *loval        setll     record
640aAC                   eval      nxtscr = 'EOJ'
640aAC                   eval      $prtn = '*CANCEL '
640aAC                   goto      endsc2
640aAC                   endif
640aA*
640aA*  Test for other command keys BEFORE verification and update.
640aA*
640aAC                   eval      cmdchk = '*BEFORE '
640aAC                   exsr      zzcmd2
640aAC     cmdtkn        cabeq     *on           endsc2
640aA*
640aA*  Some other key pressed.
640aA*
640aA*     Check input and write/update record.
640aA*
640aAC                   if        $pcmd = '*ADD    '  or
640aAC                             $pcmd = '*CHANGE '
640aAC                   exsr      zzchk2
640aAC     error         cabeq     '1'           endsc2
640aAC                   exsr      zzupd2
640aAC     error         cabeq     '1'           endsc2
640aAC                   endif
640aA*
640aA*  Test for other command keys AFTER verification and update.
640aA*
640aAC                   eval      cmdchk = '*AFTER  '
640aAC                   exsr      zzcmd2
640aAC     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
700aAC                   exsr      scr03i
700aDC*                  eval      nxtscr = 'EOJ'
640aAC     endsc2        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  SC3  -  Screen 3
700aA*
700aAC     sc3           begsr
700aA*
700aA*  Test for F3 - Exit
700aA*
700aAC                   if        *inkc
700aAC     *loval        setll     record
700aAC                   eval      nxtscr = 'EOJ'
700aAC                   eval      $prtn = '*EXIT   '
700aAC                   goto      endsc3
700aAC                   endif
700aA*
700aA*  Test for F5 - Refresh
700aA*
700aAC                   if        *inke
700aAC                   if        $pcmd <> '*VIEW   '
700aAC                   exsr      scr03i
700aAC                   endif
700aAC                   goto      endsc3
700aAC                   endif
700aA*
700aA*  Test for F12 - Previous
700aA*
700aAC                   if        *inkl
700aAC     *loval        setll     record
700aAC                   eval      nxtscr = 'EOJ'
700aAC                   eval      $prtn = '*CANCEL '
700aAC                   goto      endsc3
700aAC                   endif
700aA*
700aA*  Test for other command keys BEFORE verification and update.
700aA*
700aAC                   eval      cmdchk = '*BEFORE '
700aAC                   exsr      zzcmd3
700aAC     cmdtkn        cabeq     *on           endsc3
700aA*
700aA*  Some other key pressed.
700aA*
700aA*     Check input and write/update record.
700aA*
700aAC                   if        $pcmd = '*ADD    '  or
700aAC                             $pcmd = '*CHANGE '
700aAC                   exsr      zzchk3
700aAC     error         cabeq     '1'           endsc3
700aAC                   exsr      zzupd3
700aAC     error         cabeq     '1'           endsc3
700aAC                   endif
700aA*
700aA*  Test for other command keys AFTER verification and update.
700aA*
700aAC                   eval      cmdchk = '*AFTER  '
700aAC                   exsr      zzcmd3
700aAC     cmdtkn        cabeq     *on           endsc3
700aA*
700aA*  Everything went fine so get out of program.
700aA*
740bAc                   if        wkpltbl <> '1' and wkpltbl<> *blanks
740bAC                   exsr      scr04i
740bAc                   else
700aAC                   eval      nxtscr = 'EOJ'
740bAc                   endif
740bAC     endsc3        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  SC4  -  Screen 4
740bA*
740bAC     sc4           begsr
740bA*
700aA*  Test for F3 - Exit
740bA*
740bAC                   if        *inkc
740bAC     *loval        setll     record
740bAC                   eval      nxtscr = 'EOJ'
740bAC                   eval      $prtn = '*EXIT   '
740bAC                   goto      endsc4
740bAC                   endif
740bA*
740bA*  Test for F5 - Refresh
700aA*
740bAC                   if        *inke
740bAC                   if        $pcmd <> '*VIEW   '
740bAC                   exsr      scr04i
740bAC                   endif
740bAC                   goto      endsc4
740bAC                   endif
740bA*
740bA*  Test for F12 - Previous
740bA*
700aAC                   if        *inkl
740bAC     *loval        setll     record
740bAC                   eval      nxtscr = 'EOJ'
740bAC                   eval      $prtn = '*CANCEL '
740bAC                   goto      endsc4
740bAC                   endif
740bA*
740bA*  Test for other command keys BEFORE verification and update.
740bA*
740bAC                   eval      cmdchk = '*BEFORE '
740bAC                   exsr      zzcmd4
740bAC     cmdtkn        cabeq     *on           endsc4
740bA*
740bA*  Some other key pressed.
740bA*
740bA*     Check input and write/update record.
740bA*
700aAC                   if        $pcmd = '*ADD    '  or
740bAC                             $pcmd = '*CHANGE '
740bAC                   exsr      zzchk4
740bAC     error         cabeq     '1'           endsc4
740bAC                   exsr      zzupd4
740bAC     error         cabeq     '1'           endsc4
740bAC                   endif
740bA*
740bA*  Test for other command keys AFTER verification and update.
740bA*
740bAC                   eval      cmdchk = '*AFTER  '
740bAC                   exsr      zzcmd4
740bAC     cmdtkn        cabeq     *on           endsc4
740bA*
740bA*  Everything went fine so get out of program.
740bA*
740bAC                   eval      nxtscr = 'EOJ'
740bAC     endsc4        endsr
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
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
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
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
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
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
413aA*----------------------------------------------------------------
413aA*   PIR0112  Invalid range entered.
413aA*
413aAC     zm0112        begsr
413aAC                   eval      #msgid = 'PIR0112'
413aAC                   eval      #msgtp = '*DIAG  '
413aAC                   movea     errmsg        $md
413aAC                   exsr      zmpmsg
413aAC                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
600aA*----------------------------------------------------------------
600aA*   PIR1001  Invalid value entered
600aA*
600aAC     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     *R                   MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     *R                   MOVE #MSGK     $PMSG
     C                   endsr
410BA*----------------------------------------------------------------
410BA*   PIR2101  Invalid value for field 1 because of field 2 value.
410BA*
410BAC     zm2101        begsr
410BAC                   eval      #msgid = 'PIR2101'
410BAC                   eval      #msgtp = '*DIAG  '
410BAC                   movea     errmsg        $md(1)
410BAC                   exsr      zmpmsg
410BAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify Print exception (shorts) error reports
     *
     C                   if        w1per <> 'Y'  and
     C                             w1per <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify Print exception (shorts) labels.
     *
     C                   if        w1pel <> 'Y'  and
     C                             w1pel <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm1005
     C                   endif
416b *
416b *  Verify Close short labels without adjustment.
416b *
416b C                   if        w1eadj <> 'Y'  and
416b C                             w1eadj <> 'N'
416b C                   eval      error = *on
416b C                   eval      *in23 = *on
416b C                   eval      *in03 = *on
416b C                   eval      errmsg = *blanks
416b C                   movea     desc(9)       errmsg
416b C                   exsr      zm1005
416b C                   endif
     *
416b *  Close short labels without adj must be N if out label is N.
416b *
416b C                   if        w1eadj = 'Y'  and
416b C                             w1pel = 'N'
416b C                   eval      error = *on
416b C                   eval      *in22 = *on
416b C                   eval      *in23 = *on
416b C                   eval      *in03 = *on
416b C                   eval      errmsg = *blanks
416b C                   movea     desc(9)       erfld1
416b C                   movea     desc(2)       erfld2
416bAC                   movel     w1eadj        erval1
416bAC                   movel     'N'           erval2
416b C                   exsr      zm2101
416b C                   endif
     *
410BA*
410BA*  Verify using RF will call option.
     *
410BAC                   if        w1rfwc <> 'Y'  and
410BAC                             w1rfwc <> 'N'
410BAC                   eval      error = *on
410BAC                   eval      *in26 = *on
410BAC                   eval      *in06 = *on
410BAC                   eval      errmsg = *blanks
410BAC                   eval      errmsg = desc(3)
410BAC                   exsr      zm1005
410BAC                   endif
     *
410BAC                   if        prodt <> '*RF     '  and
410BAC                             w1rfwc = 'Y'
410BAC                   eval      error = *on
410BAC                   eval      *in26 = *on
410BAC                   eval      *in06 = *on
410BAC                   eval      errmsg = *blanks
410BAC                   movel     desc(3)       erfld1
410BAC                   movel     desc(4)       erfld2
410BAC                   movel     w1rfwc        erval1
410BAC                   movel     'N'           erval2
410BAC                   exsr      zm2101
410BAC                   endif
     *
413aA*    Verify number of pallet sections.
413aA*
413aAC                   if        w1nrsc < 1  or
413aAC                             w1nrsc > 9
413aAC                   eval      error = *on
413aAC                   eval      *in27 = *on
413aAC                   eval      *in07 = *on
413aAC                   eval      errmsg = *blanks
413aAC                   movel     desc(5)       erfld
413aAC                   movel     '1'           erfrom
413aAC                   movel     '9'           erto
413aAC                   exsr      zm0112
413aAC                   endif
414aA*
414aA*  Verify Host pick Will Call.
414aA*
414aAC                   if        w1hpwc <> 'Y'  and
414aAC                             w1hpwc <> 'N'
414aAC                   eval      error = *on
414aAC                   eval      *in28 = *on
414aAC                   eval      *in08 = *on
414aAC                   eval      errmsg = *blanks
414aAC                   movea     desc(6)       errmsg
414aAC                   exsr      zm1005
414aAC                   endif
416 A*
416 A*  Verify Merge Add-on Orders.
416 A*
416 AC                   if        w1mrga <> 'Y'  and
416 AC                             w1mrga <> 'N'
416 AC                   eval      error = *on
416 AC                   eval      *in29 = *on
416 AC                   eval      *in09 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movea     desc(7)       errmsg
416 AC                   exsr      zm1005
416 AC                   endif
416aA*
416aA*    Verify Pallet number sequence selected. (Unload or Load).
416aA*
416aAC                   if        w1plsq < '1'  or
416aAC                             w1plsq > '2'
416aAC                   eval      error = *on
416aAC                   eval      *in30 = *on
416aAC                   eval      *in10 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   movel     desc(8)       erfld
416aAC                   movel     '1'           erfrom
416aAC                   movel     '2'           erto
416aAC                   exsr      zm0112
416aAC                   endif
417 A*
417 A*  Verify Pick items without pick slot as bulk pick.
417 A*
417 AC                   if        w1nopk <> 'Y'  and
417 AC                             w1nopk <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in31 = *on
417 AC                   eval      *in11 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   movea     desc(10)      errmsg
417 AC                   exsr      zm1005
417 AC                   endif
417bA*
500cD*  Verify Clear runner flags if qty still short/out?
500cD*
500cD*          W1CLRF    IFNE 'Y'
500cD*          W1CLRF    ANDNE'N'
500cD*                    MOVE *ON       ERROR
500cD*                    MOVE *ON       *IN31
500cD*                    MOVE *ON       *IN11
500cD*                    MOVE *BLANKS   ERRMSG
500cD*                    MOVEADESC,11   ERRMSG
500cD*                    EXSR ZM1005
500cD*                    ENDIF
     *
500dA*  Verify "Print separate label... Y/N"
500dA*
500dAC                   if        w1pset <> 'Y'  and
500dAC                             w1pset <> 'N'
500dAC                   eval      error = *on
500dAC                   eval      *in35 = *on
500dAC                   eval      *in15 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   movea     desc(14)      errmsg
500dAC                   exsr      zm1005
500dAC                   endif
     *
650aD*  Verify "RF Pick verify item UPC... Y/N"
650aD *
650aDC*                  if        w1rfuc <> 'Y'  and
650aDC*                            w1rfuc <> 'N'
650aDC*                  eval      error = *on
650aDC*                  eval      *in36 = *on
650aDC*                  eval      *in16 = *on
650aDC*                  eval      errmsg = *blanks
650aDC*                  movea     desc(15)      errmsg
650aDC*                  exsr      zm1005
650aDC*                  endif
     *
650aD*  Verify "RF Pick verify item License... Y/N"
650aD*
650aDC*                  if        w1rflc <> 'Y'  and
650aDC*                            w1rflc <> 'N'
650aDC*                  eval      error = *on
650aDC*                  eval      *in37 = *on
650aDC*                  eval      *in17 = *on
650aDC*                  eval      errmsg = *blanks
650aDC*                  movea     desc(16)      errmsg
650aDC*                  exsr      zm1005
650aDC*                  endif
417cA*
500cD*  Verify Send break msg to user when new Flag runner task ready.
500cD*
500cD*          W1RNRM    IFNE 'Y'
500cD*          W1RNRM    ANDNE'N'
500cD*                    MOVE *ON       ERROR
500cD*                    MOVE *ON       *IN31
500cD*                    MOVE *ON       *IN11
500cD*                    MOVE *BLANKS   ERRMSG
500cD*                    MOVEADESC,12   ERRMSG
500cD*                    EXSR ZM1005
500cD*                    ENDIF
414aA*
414aAC                   if        prodt = '*RF     '  and
414aAC                             w1rfwc = 'Y'  and
414aAC                             w1hpwc = 'Y'
414aAC                   eval      error = *on
414aAC                   eval      *in26 = *on
414aAC                   eval      *in06 = *on
414aAC                   eval      *in28 = *on
414aAC                   eval      *in08 = *on
414aAC                   eval      errmsg = *blanks
414aAC                   movel     desc(6)       erfld1
414aAC                   movel     desc(3)       erfld2
414aAC                   movel     w1hpwc        erval1
414aAC                   movel     'Y'           erval2
414aAC                   exsr      zm2101
414aAC                   endif
650aD*
650aD*  Verify RF Pick Verify slot.
650aD*
650aDC*                  if        w1rfsl <> 'Y'  and
650aDC*                            w1rfsl <> 'N'
650aDC*                  eval      error = *on
650aDC*                  eval      *in38 = *on
650aDC*                  eval      *in18 = *on
650aDC*                  eval      errmsg = *blanks
650aDC*                  movea     desc(17)      errmsg
650aDC*                  exsr      zm1005
650aDC*                  endif
640a *
640a *  Verify Allow Substitues.
640a *
640a C                   if        w1subt <> 'Y'
640a C                             and w1subt <> 'N'
640a C                   eval      error = *on
640a C                   eval      *in39 = *on
640a C                   eval      *in19 = *on
640a C                   eval      errmsg = *blanks
640a C                   movea     desc(18)      errmsg
640a C                   exsr      zm1005
640a C                   endif
700dA*
700dA*  Verify Pallet label flag
700dA*
700dAC                   if        w1plt <> '1'
700dAC                             and w1plt <> '2'
700dAC                             and w1plt <> '3'
700dAC                             and w1plt <> '4'
700dAC                   eval      error = *on
700dAC                   eval      *in32 = *on
700dAC                   eval      *in12 = *on
700dAC                   eval      errmsg = *blanks
700dAC                   movel     desc(25)      erfld
700dAC                   movel     '1'           erfrom
700dAC                   movel     '4'           erto
700dAC                   exsr      zm0112
700dAC                   endif
     *
700dAC                   select
700dAC                   when      error = *off
700dAC                   if        w1plt = '2'
700dAC                             or w1plt = '3'
700dAC                   eval      kyfmt = 'BIGPAL  '
     *
700dAC     keylfd        setll     lblfmtd
700dAC                   dow       forever = forever
700dAC     keylfd        reade     lblfmtd
700dAC                   if        %eof(lblfmtd)
700dAC                   eval      error = *on
700dAC                   eval      *in32 = *on
700dAC                   eval      *in12 = *on
700dAC                   eval      errmsg = *blanks
700dAC                   movel     desc(26)      errmsg
700dAC                   exsr      zm0105
700dAC                   leave
700dAC                   endif
700dAC                   leave
700dAC                   enddo

700dAC                   endif
700dAC                   endsl
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
730aA*
730aA*  Verify Slot Pick Sequence setting
730aA*
730aAC                   if        w2pseq <> 'A'  and
730aAC                             w2pseq <> 'D'  and
730aAC                             w2pseq <> 'P'
730aAC                   eval      error = *on
730aAC                   eval      *in33 = *on
730aAC                   eval      *in13 = *on
730aAC                   eval      errmsg = *blanks
730aAC                   movea     desc(30)      errmsg
730aAC                   exsr      zm1001
730aAC                   endif
417dA*
417dA*  Verify JIT Letdown or JIT Replenishment.
417dA*
600aMC                   if        w2jitr <> '0'  and
600aMC                             w2jitr <> '2'  and
600aMC                             w2jitr <> '4'
417dAC                   eval      error = *on
417dAC                   eval      *in34 = *on
417dAC                   eval      *in14 = *on
417dAC                   eval      errmsg = *blanks
417dAC                   movea     desc(13)      errmsg
600aMC                   exsr      zm1001
417dAC                   endif
640aA*
640aA*  Round Robin Compatable flag.
640aA*
640aAC                   if        w2rbn1 <> 'Y'
640aAC                             and w2rbn1 <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in24 = *on
640aAC                   eval      *in04 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movea     desc(19)      errmsg
640aAC                   exsr      zm1005
640aAC                   endif
640aA*
640aA*  Round Robin Type.
640aA*
640aAC                   if        w2rbn2 <> '1'
640aAC                             and w2rbn2 <> '2'
640aAC                             and w2rbn2 <> '3'
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movea     desc(20)      errmsg
640aAC                   exsr      zm0105
640aAC                   endif
700cM*
700cM*  moved code from zzchk2 to zzchk3 for fields
700cM*    w1rfuc, w1rflc, w1rfsl now on following scrn.
700aD*
700aD*  Verify RF Pick Allow Quantity Entry
700aD*
700aDC*                  if        w1rfqt <> 'Y'  and
700aDC*                            w1rfqt <> 'N'
700aDC*                  eval      error = *on
700aDC*                  eval      *in40 = *on
700aDC*                  eval      *in20 = *on
700aDC*                  eval      errmsg = *blanks
700aDC*                  movea     desc(21)      errmsg
700aDC*                  exsr      zm1005
700aDC*                  endif
700aD*
     *
     C     endck2        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZCHK3   Screen 3 error checking.
700aA*
700aAC     zzchk3        begsr
700aAC                   eval      error = *off
700aA
700aA*  Verify RF Pick Allow Quantity Entry
700aA*
700aAC                   if        w1rfqt <> 'Y'  and
700aAC                             w1rfqt <> 'N'
700aAC                   eval      error = *on
700aAC                   eval      *in20 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movea     desc(21)      errmsg
700aAC                   exsr      zm1005
700aAC                   endif
700aA*  Verify RF Pick Allow Quantity Entry When Qty Over ?
700aAC                   if        w1rfqt = 'Y'  and
710aDC*                            w1rfqto = *blanks
710aMC                             w1rfqto = 0
700aAC                   eval      error = *on
700aAC                   eval      *in43 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movea     desc(23)      errmsg
700aAC                   exsr      zm1001
700aAc                   endif
700aA*
700aA*  Verify RF Allow Change Slot
700aA*
700aAC                   if        w1rfcs <> 'Y'  and
700aAC                             w1rfcs <> 'N'
700aAC                   eval      error = *on
700aAC                   eval      *in41 = *on
700aAC*                  eval      *in20 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movea     desc(22)      errmsg
700aAC                   exsr      zm1005
700aAC                   endif
700aA*
700aA*  Verify RF Pick Method
700aA*
700aAC                   if        w1rfpm <> '1'  and
700aAC                             w1rfpm <> '2'
700aAC                   eval      error = *on
700aAC                   eval      *in42 = *on
700aAC*                  eval      *in20 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movea     desc(24)      errmsg
700aAC                   exsr      zm1001
700aAC                   endif
700cM*
700cM*  moved code to zzchk3 from zzchk2 for fields
700cM*    w1rfuc, w1rflc, w1rfsl now on following scrn.
650aM*
650aM*  Verify "RF Pick verify item UPC... Y/N"
650aM*
650aMC                   if        w1rfuc <> 'Y'  and
650aMC                             w1rfuc <> 'N'
650aMC                   eval      error = *on
650aMC                   eval      *in36 = *on
650aMC                   eval      *in16 = *on
650aMC                   eval      errmsg = *blanks
650aMC                   movea     desc(15)      errmsg
650aMC                   exsr      zm1005
650aMC                   endif
650aM*
650aM*  Verify "RF Pick verify item License... Y/N"
650aM*
650aMC                   if        w1rflc <> 'Y'  and
650aMC                             w1rflc <> 'N'
650aMC                   eval      error = *on
650aMC                   eval      *in37 = *on
650aMC                   eval      *in17 = *on
650aMC                   eval      errmsg = *blanks
650aMC                   movea     desc(16)      errmsg
650aMC                   exsr      zm1005
650aMC                   endif
650aM*
650aM*  Verify RF Pick Verify slot.
650aM*
700aMC                   if        w1rfsl <> 'Y'  and
700aMC                             w1rfsl <> 'N'  and
700aMC                             w1rfsl <> 'C'  and
700aMC                             w1rfsl <> 'E'
650aMC                   eval      error = *on
650aMC                   eval      *in38 = *on
650aMC                   eval      *in18 = *on
650aMC                   eval      errmsg = *blanks
650aMC                   movea     desc(17)      errmsg
700aDC*                  exsr      zm1005
700aAC                   exsr      zm1001
650aMC                   endif
720aA*
720aA*  Verify RF verify individual UPC
720aA*
720aAC                   if        w1rfui <> 'Y'
720aAC                             and w1rfui <> 'N'
720aAC                   eval      error = *on
720aAC                   eval      *in44 = *on
720aAC                   eval      errmsg = *blanks
720bDC*                  movea     desc(18)      errmsg
720bMC                   movea     desc(27)      errmsg
720aAc                   exsr      zm1005
720aAC                   endif
720bA*
720bA*  Verify Auto load weights from individual upc
720bA*
720bAC                   if        w1rfuw <> 'Y'
720bAC                             and w1rfuw <> 'N'
720bAC                   eval      error = *on
720bAC                   eval      *in46 = *on
720bAC                   eval      errmsg = *blanks
720bAC                   movea     desc(28)      errmsg
720bAc                   exsr      zm1005
720bAC                   endif
720bA*
720bA*  Verify RF Zone Pickup.
720bA*
720bAC                   if        w1rfzp <> 'Y'  and
720bAC                             w1rfzp <> 'N'  and
720bAC                             w1rfzp <> 'M'
720bAC                   eval      error = *on
720bAC                   eval      *in45 = *on
720bAC                   eval      errmsg = *blanks
720bAC                   movea     desc(29)      errmsg
720bAC                   exsr      zm1001
720bAC                   endif
700aA*
700aAC     endck3        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZCHK4   Screen 4 error checking.
740bA*
740bAC     zzchk4        begsr
740bAC                   eval      error = *off
740bA*
740bA*  Verify Highest on Pallet setting
740bA*
740bAC                   if        w4pmsc <> *zeros and
740bAC                             w4psvh <> 'Y'  and
740bAC                             w4psvh <> 'N'
740bAC                   eval      error = *on
740bAC                   eval      *in47 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = 'Highest stop on pallet'
740bAC                   exsr      zm1005
740bAC                   endif
740bA*
740bA*  Verify Middle Pallet setting
740bA*
740bAC                   if        w4pmsc <> *zeros and
740bAC                             w4psvm <> 'Y'  and
740bAC                             w4psvm <> 'N'
740bAC                   eval      error = *on
740bAC                   eval      *in48 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = 'Middle stop on pallet'
740bAC                   exsr      zm1005
740bAC                   endif
740bA*
740bA*  Verify Lowest on Pallet setting
740bA*
740bAC                   if        w4pmsc <> *zeros and
740bAC                             w4psvl <> 'Y'  and
740bAC                             w4psvl <> 'N'
740bAC                   eval      error = *on
740bAC                   eval      *in49 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = 'Lowest stop on pallet'
740bAC                   exsr      zm1005
740bAC                   endif
740bA*
740bA*  Verify Allow Freezer pallet at rear door
740bA*
740bAC                   if        w4pfdb <> 'Y'  and
740bAC                             w4pfdb <> 'N'
740bAC                   eval      error = *on
740bAC                   eval      *in49 = *on
740bAC                   eval      errmsg = *blanks
740bAC                   eval      errmsg = 'Allow Freezer pallet at rear door'
740bAC                   exsr      zm1005
740bAC                   endif
740bA*
740bAC     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
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
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     C     endcm2        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZCMD3   User defined command keys for screen 3.
700aA*
700aAC     zzcmd3        begsr
700aA*
700aA*  Command keys to check BEFORE verification and update.
700aA*
700aAC                   if        cmdchk = '*BEFORE '
700aAC                   endif
700aA*
700aA*  Command keys to check AFTER verification and update.
700aA*
700aAC                   if        cmdchk = '*AFTER  '
700aAC                   endif
700aAC     endcm3        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZCMD4   User defined command keys for screen 4.
740bA*
740bAC     zzcmd4        begsr
740bA*
740bA*  Command keys to check BEFORE verification and update.
740bA*
740bAC                   if        cmdchk = '*BEFORE '
740bAC                   endif
740bA*
740bA*  Command keys to check AFTER verification and update.
740bA*
740bAC                   if        cmdchk = '*AFTER  '
740bAC                   endif
740bAC     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      operpt = 'Y'
     C                   eval      opelbl = 'Y'
410BAC                   eval      oprfwc = 'N'
417aAC                   eval      opnrsc = 0
417aAC                   eval      ophpwc = ' '
417aAC                   eval      opmrga = ' '
417aAC                   eval      opplsq = ' '
417aAC                   eval      opeadj = ' '
417 AC                   eval      opnopk = 'Y'
500cD*                    MOVE 'Y'       OPCLRF
500cD*                    MOVE 'N'       OPRNRM
500bD*R                   MOVE 'R'       OPJITR
500bMC                   eval      opjitr = '2'
500dAC                   eval      oppset = 'N'
650aDC*                  eval      oprfuc = 'N'
650aDC*                  eval      oprflc = 'N'
650aDC*                  eval      oprfsl = 'N'
640aAC                   eval      opsubt = 'Y'
700dAC                   eval      oprplt = '1'
720aAC                   eval      oprfui = 'Y'
720bAC                   eval      oprfzp = 'N'
720bAC                   eval      oprfuw = 'N'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
500bMC                   eval      opjitr = '2'
640aAC                   eval      oprbn1 = 'N'
640aAC                   eval      oprbn2 = '1'
650aMC                   eval      oprfuc = 'N'
650aMC                   eval      oprflc = 'N'
650aMC                   eval      oprfsl = 'N'
700aAC*                  eval      oprfqt = 'N'
700aDC*                  eval      oprfcs = 'N'
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZDFT3   Get default values for add.
700aA*
700aAC     zzdft3        begsr
700aAC                   eval      oprfqt = 'N'
710aDc*                  eval      oprfqto=  *blanks
710aMc                   eval      oprfqto=  0
700aAC                   eval      oprfcs = 'N'
700aAC                   eval      oprfpm = '1'
700aAC                   endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZDFT4   Get default values for add.
740bA*
740bAC     zzdft4        begsr
740bAC                   eval      oppmsc = 0
740bAc                   eval      oppsvh=  'N'
740bAc                   eval      oppsvm=  'N'
740bAC                   eval      oppsvl=  'N'
740bAC                   eval      oppissv= 0
740bAC                   eval      oppissp= 0
740bAC                   eval      oppmssv= 0
740bAC                   eval      oppmssv= 0
740bAC                   eval      oppfdb=  'N'
740bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1per = operpt
     C                   eval      w1pel = opelbl
410BAC                   eval      w1rfwc = oprfwc
413aAC                   eval      w1nrsc = opnrsc
414aAC                   eval      w1hpwc = ophpwc
416 AC                   eval      w1mrga = opmrga
416aAC                   eval      w1plsq = opplsq
416bAC                   eval      w1eadj = opeadj
417 AC                   eval      w1nopk = opnopk
500cD*                    MOVE OPCLRF    W1CLRF
500cD*                    MOVE OPRNRM    W1RNRM
500dAC                   eval      w1pset = oppset
650aDC*                  eval      w1rfuc = oprfuc
650aDC*                  eval      w1rflc = oprflc
650aDC*                  eval      w1rfsl = oprfsl
640a C                   eval      w1subt = opsubt
700dAC                   if        oprplt <> *blanks
700dAC                   eval      w1plt  = oprplt
700dAC                   else
700dAC                   eval      w1plt  = '1'
700dAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
417dAC                   eval      w2jitr = opjitr
640aAC                   eval      w2rbn1 = oprbn1
640aAC                   eval      w2rbn2 = oprbn2
650aMC                   eval      w1rfuc = oprfuc
650aMC                   eval      w1rflc = oprflc
650aMC                   eval      w1rfsl = oprfsl
700aDC*                  eval      w1rfqt = oprfqt
700aDC*                  eval      w1rfcs = oprfcs
730aAC                   eval      w2pseq = oppseq
730aAc                   if        w2pseq = *blanks
730aAc                   eval      w2pseq = 'P'
730aAc                   endif
740aAc                   monitor
740aAc                   eval      w2cad=opcad
740aAc                   on-error
740aAc                   eval      opcad=0
740aAc                   endmon
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZFIL3   Fill screen 3 fields with info from file.
700aA*
700aAC     zzfil3        begsr
710bAC                   if        oprfqtx = '   '
710bAC                   eval      oprfqto = 0
710bAC                   endif
700aAC                   eval      w1rfqt = oprfqt
700aAc                   eval      w1rfqto= oprfqto
700aAC                   eval      w1rfcs = oprfcs
700aAC                   eval      w1rfpm = oprfpm
720aAC                   if        oprfui <> *blanks
720aAC                   eval      w1rfui = oprfui
720aAC                   else
720aAC                   eval      w1rfui = 'Y'
720aAC                   endif
720bAC                   if        oprfzp <> *blanks
720bAC                   eval      w1rfzp = oprfzp
720bAC                   else
720bAC                   eval      w1rfzp = 'N'
720bAC                   endif
720bAC                   if        oprfuw <> *blanks
720bAC                   eval      w1rfuw = oprfuw
720bAC                   else
720bAC                   eval      w1rfuw = 'N'
720bAC                   endif
700aAC                   endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZFIL4   Fill screen 4 fields with info from file.
740bA*
740bAC     zzfil4        begsr
740bAc                   monitor
740bAc                   eval      w4pmsc=oppmsc
740bAc                   on-error
740bAc                   eval      w4pmsc=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      w4pissv=oppissv
740bAc                   on-error
740bAc                   eval      w4pissv=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      w4pissp=oppissp
740bAc                   on-error
740bAc                   eval      w4pissp=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      w4pmssv=oppmssv
740bAc                   on-error
740bAc                   eval      w4pmssv=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      w4pmssp=oppmssp
740bAc                   on-error
740bAc                   eval      w4pmssp=0
740bAc                   endmon
740bAc                   eval      w4psvh=oppsvh
740bAc                   eval      w4psvm=oppsvm
740bAc                   eval      w4psvl=oppsvl
740bAc                   eval      w4pfdb=oppfdb
740bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*GENPICK'
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*GENPICK'
     *
     C                   eval      tmpflg = *off
     *
     C     beggt2        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft2
     C                   write     record
     C                   goto      beggt2
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C                   endif
     *
     C     endgt2        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZGET3   Get record(s) for screen 3.
700aA*
700aAC     zzget3        begsr
700aA*
700aAC                   eval      opwhse = $pwhse
700aAC                   eval      opcode = '*GENPICK'
700aA *
700aAC                   eval      tmpflg = *off
700aA*
700aAC     beggt3        tag
700aA *
700aA *   Get record from main file.
700aA *
700aAC                   if        $pcmd = '*VIEW   '
700aAC     fileky        chain(n)  record                             7978
700aAC                   else
700aAC     fileky        chain     record                             7978
700aAC                   endif
700aA*
700aA*  Record locked.
700aA*
700aAC                   if        *in78
700aAC                   eval      error = *on
700aAC                   eval      $prtn = '*PGMQ   '
700aAC                   exsr      zm74
700aAC                   goto      endgt3
700aAC                   endif
700aA*
700aA*  Record not found - Create it.
700aA*
700aAC                   if        *in79
700aAC                   if        tmpflg = *off
700aAC                   eval      tmpflg = *on
700aAC                   exsr      zzdft3
700aAC                   write     record
700aAC                   goto      beggt3
700aAC                   else
700aAC                   eval      error = *on
700aAC                   eval      $prtn = '*PGMQ   '
700aAC                   exsr      zm73
700aAC                   goto      endgt3
700aAC                   endif
700aAC                   endif
700aA*
700aAC     endgt3        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZGET4   Get record(s) for screen 4.
740bA*
740bAC     zzget4        begsr
740bA*
740bAC                   eval      opwhse = $pwhse
740bAC                   eval      opcode = '*GENPICK'
740bA *
740bAC                   eval      tmpflg = *off
740bA*
740bAC     beggt4        tag
740bA *
740bA *   Get record from main file.
740bA *
740bAC                   if        $pcmd = '*VIEW   '
740bAC     fileky        chain(n)  record                             7978
740bAC                   else
740bAC     fileky        chain     record                             7978
740bAC                   endif
740bA*
740bA*  Record locked.
740bA*
740bAC                   if        *in78
740bAC                   eval      error = *on
740bAC                   eval      $prtn = '*PGMQ   '
740bAC                   exsr      zm74
740bAC                   goto      endgt4
740bAC                   endif
740bA*
740bA*  Record not found - Create it.
740bA*
740bAC                   if        *in79
740bAC                   if        tmpflg = *off
740bAC                   eval      tmpflg = *on
740bAC                   exsr      zzdft4
740bAC                   write     record
740bAC                   goto      beggt4
700aAC                   else
740bAC                   eval      error = *on
740bAC                   eval      $prtn = '*PGMQ   '
740bAC                   exsr      zm73
740bAC                   goto      endgt4
740bAC                   endif
740bAC                   endif
740bA*
740bAC     endgt4        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
700dA*
700dA*  Define key for LBLFMTD file.
700dA*
700dAC     keylfd        klist
700dAC                   kfld                    $plset
700dAC                   kfld                    kyfmt
     *
700dAC                   eval      $plset = *blanks
700dAC     *loval        setll     optionz4
700dAC                   dow       forever = forever
700dAC                   read      optionz4
700dAC                   select
700dAC                   when      not %eof(optionz4)
700dAC                             and %subst(opzdta:13:10) <> 'WILLCALL  '
700dAC                   eval      $plset = %subst(opzdta:7:6)
700dAC                   if        $plset <> *blanks
700dAC                   leave
700dAC                   endif
700dAC                   when      %eof(optionz4)
700dAC                   leave
700dAC                   endsl
700dAC                   enddo
     *
410BAC     *dtaara       define    product       prodt             8
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get and verify warehouse description.
     *
     C                   eval      whcode = $pwhse
     C                   if        whcode = 0
     C                   eval      whdesc = *blanks
     C     'All ware'    cat       'houses':0    whdesc
     C                   else
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg = $pprg
     C                   eval      $lwhse = whcode
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '  or
     C                             $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      $prtn = $lrtn
     C                   eval      $perm = $lerm
     C                   goto      endin2
     C                   else
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
410BA*
410BA*  Get product level from data area.
410BA*
410BAC                   in        prodt
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
740bA /free
740bA    // get pallet building type from Feature setting
740bA    if not %open(opfeat);
740bA      monitor;
740bA        open opfeat;
740bA        chain (whcode:'*FEATURE') opfeat;
740bA        if %found(opfeat);
740bA          if %subst(f_opdata:7:1) <> *blanks;
740bA            wkpltbl = %subst(f_opdata:7:1);
740bA          else;
740bA            wkpltbl = '1';
740bA          endif;
740bA        else;
740bA          wkpltbl = '1';
740bA        endif;
740bA      on-error;
740bA        wkpltbl = '1';
740bA      endmon;
740bA    endif;
740bA /end-free
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      operpt = w1per
     C                   eval      opelbl = w1pel
410BAC                   eval      oprfwc = w1rfwc
413aAC                   eval      opnrsc = w1nrsc
414aAC                   eval      ophpwc = w1hpwc
416 AC                   eval      opmrga = w1mrga
416aAC                   eval      opplsq = w1plsq
416bAC                   eval      opeadj = w1eadj
417 AC                   eval      opnopk = w1nopk
500cD*                    MOVE W1CLRF    OPCLRF
500cD*                    MOVE W1RNRM    OPRNRM
500dAC                   eval      oppset = w1pset
650aDC*                  eval      oprfuc = w1rfuc
650aDC*                  eval      oprflc = w1rflc
650aDC*                  eval      oprfsl = w1rfsl
640aAC                   eval      opsubt = w1subt
700dAC                   eval      oprplt = w1plt
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     *
     C     endupd        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZUPD2   Update record.
640aA*
640aAC     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opjitr = w2jitr
640aAC                   eval      oprbn1 = w2rbn1
640aAC                   eval      oprbn2 = w2rbn2
650aMC***700bD           eval      oprfuc = w1rfuc
650aMC***700bD           eval      oprflc = w1rflc
650aMC***700bD           eval      oprfsl = w1rfsl
700aDC*                  eval      oprfqt = w1rfqt
700aDC*                  eval      oprfcs = w1rfcs
730aAC                   eval      oppseq = w2pseq
740aAC                   eval      opcad  = w2cad
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup2
     C                   endif
     *
640aAC     endup2        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZUPD3   Update record.
700aA*
700aAC     zzupd3        begsr
700aAC                   eval      error = *off
700aA*
700aA*  Move screen fields to record fields
700aA*
700bMC                   eval      oprfuc = w1rfuc
700bMC                   eval      oprflc = w1rflc
700bMC                   eval      oprfsl = w1rfsl
700aAC                   eval      oprfqt = w1rfqt
700aAC                   eval      oprfqto= w1rfqto
700aAC                   eval      oprfcs = w1rfcs
700aAC                   eval      oprfpm = w1rfpm
720aAC                   eval      oprfui = w1rfui
720bAC                   eval      oprfuw = w1rfuw
720bAC                   eval      oprfzp = w1rfzp
700aA*
700aA*   Update record (it was read and locked in ZZGET1)
700aA*
700aAC                   update    record                               79
700aAC                   if        *in79
700aAC                   eval      error = *on
700aAC                   exsr      zm72
700aAC                   goto      endup3
700aAC                   endif
700aA*
700aAC     endup3        endsr
740bA*----------------------------------------------------------------
740bA*
740bA*  ZZUPD4   Update record.
740bA*
740bAC     zzupd4        begsr
740bAC                   eval      error = *off
740bA*
740bA*  Move screen fields to record fields
740bA*
740bAC                   eval      oppmsc = w4pmsc
740bAC                   eval      oppsvh = w4psvh
740bAC                   eval      oppsvm = w4psvm
740bAC                   eval      oppsvl = w4psvl
740bAC                   eval      oppissv= w4pissv
740bAC                   eval      oppissp= w4pissp
740bAC                   eval      oppmssv= w4pmssv
740bAC                   eval      oppmssp= w4pmssp
740bAC                   eval      oppfdb = w4pfdb
740bA*
740bA*   Update record (it was read and locked in ZZGET4)
740bA*
740bAC                   update    record                               79
740bAC                   if        *in79
740bAC                   eval      error = *on
740bAC                   exsr      zm72
740bAC                   goto      endup4
740bAC                   endif
740bA*
740bAC     endup4        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Print exception (shorts) reports
Print exception (shorts) labels
Using RF Will Call
RF Product level
Number of pallet sections
Host pick Will Call
Merge Add-on Orders
Pallet Number Sequence
Close shorts without adjustment
Pick items without pick slot as bulk pick
 <Not Used>
 <Not Used>
Create JIT Priority Replenishment.
Print separate set summary label value.
RF Pick verify item, scan UPC.
RF Pick verify item, scan license.
RF Pick verify slot
Substitution flag
Round Robin compatable flag
Round Robin type must be 1, 2, or 3
RF Pick Allow Quantity Entry
RF Pick Allow Change Slot
When Quantity Over
RF Pick Method
Pallet label
Option not valid - Big Pallet not found.
Verify Individual UPC
Auto Load Weights from UPC
RF Zone Pickup
Slot Pick Sequence
