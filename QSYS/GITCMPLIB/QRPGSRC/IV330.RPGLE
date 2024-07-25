500 A /copy *libl/qcopysrc,hspecs
500eA*----------------------------------------------------------------
500eA*  Multilingual Verision
500eA*  Every screen and message has a corresponding Spanish version.
500eA*  Any changes must be made to both languages.
500eA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV330   RF  Inventory entry
     *  22 April, 1999
     *  Roxanne Harrison
     *
     *  Notes:
     *       Created using IT220
     *       8 X 20 Screens for hand held scanners
     *  Revisions:
414aA*    05/12/00  RH   4.14a
     *      - Recompiled, file INVSLOT changed.
414 A*    05/15/00  RH   4.14a
     *      - Change key to VSLOT2 file to use physical slot.
414bA*    05/23/00  RH   4.14b
     *      - Call CHKSSB if type S item exists for base item,
     *        enable breakdown quantity fields.
414dA*    06/20/00  RH   4.14d
     *      - Add W3ITM3 field to display pack size on screen 3.
415aA*    08/06/01  RH   4.15a
     *      - Add error if qty entered SC4 and item is blank.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
416aA*  04/01/02  RH   4.16a
     *    - FIX - Was not clearing W3ITM3 field.
416bA*    12/13/02  MLB  4.16b
     *      - Enh: Added support to program to call APICVTSLT
     *        to properly format slot info scanned by user.
     *      - Fix: Revised ZZCMD2 when F10 slot exception is
     *        logged to run routine ZZCK2A to validate info
     *        entered by user.
416cA*    04/29/02  DAS  4.16c
     *      - Enh: Revised message IV33002 to have a parameter.
417bA*    11/06/03  RH   4.17b
     *      - FIX: Revised ZZCMD2, was preventing F10 slot exception.
417cA*    12/10/03  RH   4.17c
     *      - Enh: If slot has pending quantity, remove from scope.
     *        write to INVCHK slot to be manually checked for count.
     *
500 A*    04/04/05  DAS  5.00
     *      - Converted to ILE.
     *      - Added DRI logic.
     *      - Using DRIITEM to get item information instead of PIRITEM file
     *      - Added License tracking LT210 logic.
     *      - Added file INVSLTPOS to record slot position.
500aA*    05/25/06  RH   5.00a
     *      - Enh: Add F8=Override to allow re-scan and entry of slot.
500bA*    05/30/06  RH   5.00b
     *      - Enh: Add INVSCW and Screen5 for catch weight entry.
500cA*    06/27/05  DAS  5.00c
     *      - Added quantities to LT210 call.
500dA*    06/17/06  MLB  5.00d
     *      - Fix: Revised ZZCHK1 to allow zero catchweight.
500eA*    05/31/06  JCJ  5.00e
     *      - Enh: Added Multilingual logic.
510aA*    07/10/06  RH   5.10a
     *      - Fix: Add 5.00d to V5.10 update, not in V5.0.
510bA*    08/23/06  RH    5.10b
     *      - Enh:Added client code.
510cA*    11/15/06  RH    5.10c
     *      - Enh:Added UPC scan to Screen 3 to verify item being counted
510dA*    11/21/06  RH    5.10d
     *      - Enh:Added F6 to add item to Screen 2.
510eA*    12/15/06  RH    5.10e
     *      - Enh:Add Inventory count options UPC scan,               ted
510fA*    01/22/07  RH    5.10f
     *      - Fix: Reset INVSLOT status from 'X' if INVEXCP is removedted
510gA*    06/23/07  MLB   5.10g
     *      - Fix: Revised ZZUOM to setoff *in92, *in93.
520aA*    05/12/08  RH    5.20a
     *      - Enh: Remove UPC code from screen 4 to verify item(5.10e)
520bA*    05/12/08  RH    5.20b
     *      - Enh: Add Screen 6 to scan License, UCI, UPC to verify
     *        item being counted.
520cA*    04/27/09  RH    5.20c
     *      - Fix: Unlock INVSLOT file when F6=Add is taken on Screen2
     *        Causing record lock error in IV333 when trying to add
     *        item to slot.
     *
610aA*    09/10/09  DAS   6.10a
     *      - Revised zzchk2 to get slot info using DRISLOT.
     *      - Revised to pass lcns to lt210.
     *
610bA*    09/14/09  DAS   6.10b
     *      - Revised to not call lt210 if license not found.
     *
610cA*    09/16/09  DAS   6.10c
     *      - Revised to not call lt210. Instead, display license
     *        on screen 3.
     *      - Revised to display an empty base slot first, then
     *        display slots with low tracking items, then Medium/High
     *        tracking items that have a non-'*' license, then the
     *        Medium/High tracking items that have a '*' license.
     *
610dA*    09/17/09  DAS   6.10d
     *      - Reinstated turning off alarm ind 98 after screen displayed.
     *      - Stopped using pwhdp and pdisp for F10 in zzcmd2
     *
530aA*    11/03/09  RH    5.30a
     *      - Fix: Unlock INVSLOT and INVPAGE files when F12 taken on
     *        screen2, was leaving INVSLOT locked.
530bA*    11/23/09  RH    5.30b
     *      - Fix: Correct options, add OPCSCN and OPCKIN before
     *        OPCCWT capture catch weight.
     *
610eA*    09/17/09  DAS   6.10e
     *      - Fix: Initialized W3ITEM in ZZFIL3 correctly.
     *      - Fix: Revised to get invslot record that corresponds to
     *        the record chosen by zzgetslot.
610fA*    05/17/10  RH    6.10f
     *      - Fix: Initialized W3ITEM to IVSITM if status ='Z'
     *        using $slitem was allowing INVSLOT to have qty with
     *        no item.
640aA*    02/09/12  LMC   6.40a
     *      - Ehn: Edit to make sure print sheet option has been processed.
650aA*    05/03/13  RH    6.50a
     *      - Fix: Add client location.                               ssed.
650bA*    01/16/15  LMC  6.50b
     *      - Fix: zzchk2 - Problem at presto when F8  override - slot
     *        would go thru convert slot to check for double scan,
     *        skip converting slot if the w2disp = savdsp, if slot has
     *        not changed.
700aA*    03/28/15  MR   7.00a
700aA*      - Add Pounds/Kilograms functionality
700bA*    06/27/16  LMC  7.00b
     *      - Reserved - UCI Tracking
700cA*  09/16/16  LMC  7.00c
     *    - Enh: Update history detail file to show slot counted = P
     *      to Explain why slot was not counted.
     *
700dA*    11/03/16  LMC  7.00d
     *      - Enh: UPC file has a database change. Recompile only.
710aA*    03/23/17  LMC  7.10a
     *      - Enh: Database change to INVHSTD. Recompile only.
710bA*  12/22/17  LMC  7.10b
     *    - Enh: Database change to INVHSTD. Recompile only.
720aA*  04/19/18  LMC  7.20a
     *    - Enh: When marking invhstd record with a P to note that the
     *      slot was not counted due to pending quantities. Update the
     *      item number from the invslot file into the invshtd file.
720bA*    06/27/16  LMC  7.20b
     *      - UCI Tracking - New Item tracking level 'U'
730aA*    05/30/19  LMC  7.30a
     *      - Corrected field name in *count options record
750aA*    01/29/21  LMC  7.50a
     *      - Enh: When return from cvtbar with *upcwarn is good.
750b *    03/31/21  GJC  7.50b
     *      - Enh: New display IV33003
     *
     *----------------------------------------------------------------
     *  Custom
PAKaA*    08/23/06  RH    PAKa
     *      - Enh:Do not capture CW.
JORaA*    06/07/07  RH    JORa
     *      - Fix:Reverse 500e call to GETUSER for spanish until 5.00 update
     *        is in place.
SGCaA*    12/01/09  RH    SGCa
     *      - Enh:Default screen count to slot count.
GFCaA*    Custom - Glazier Foods
GFCaA*    08/18/10  RH    GFCa
     *      - Enh:Default screen count to slot count.
EIaaA*    Custom - European Imports
EIaaA*    09/12/11  RH    EIa
     *      - Enh:Default screen count to slot count.
CDIaA *    Custom - CDI
      *    04/17/08  RH    CDIa
      *      - Enh: Add mfg item#, can replace pack desc on screen 3
CDIbA *    05/03/13  RH   CDIb
      *      -  Revised program to NOT exclude slots with pending qty
      *         for JAX only.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    01/16/15  LMC  PFCa
     *      -  Enh: Add the '.' to the end of the next virtual slot
     *         to have counts entered.
     *
     *----------------------------------------------------------------
KFSaA*    Custom - Kelly's Foodservice
KFSaA*    09/12/18  RH    KFSa
     *      - Enh:Add to CDIb, don't exclude slots with pending qty
     *        per Kelly's request 9-7-18 for full system Dakota
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
700aA*  31        Pounds/Kilograms Toggle
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
700aDF*iv330fm   cf   e             workstn
720bDF*iv33001   cf   e             workstn
720bDF*iv33002   cf   e             workstn
750bMFiv33003   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Finvteam   if   e           k disk
     Finvslot4  uf   e           k disk
     Finvpage   uf   e           k disk
500 DF**ritem   if   e           k disk
500bAFitemmsc   if   e           k disk
500b Foptions   if   e           k disk
     Funmesr    if   e           k disk
     Fvslot2    if   e           k disk
610aDF*lot2     if   e           k disk
417c Finvbslt4  uf   e           k disk
417c Finvslot1  if   e           k disk
     F                                     rename(ivsrec:ivsrc1)
500aDF*nvexcp   o  a e           k disk
500a Finvexcp2  uf a e           k disk
417c Finvchk    o  a e           k disk
500aMFinvspos   uf a e           k disk
500aDF*nvspos   o  a e           k disk
500b Finvscw    uf a e           k disk
520b Flabel90   if a e           k disk
520b Flicense   if a e           k disk
520b Fucicw     if a e           k disk
510c Fupc       if a e           k disk
720bAFupc2      if   e           k disk    rename(uprec:uprec2)
700cAFinvinuse  if   e           k disk
700cAFinvhstd   uf   e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
510bAD @getcl          c                   const('GETCLIENT')
510bAD*
510bA /COPY QCOPYSRC,ID#PACKERS
SGCaA /COPY QCOPYSRC,ID#SGC
GFCaA /COPY QCOPYSRC,ID#GLAZIER
EIa A /COPY QCOPYSRC,ID#EI
CDIaA /COPY QCOPYSRC,ID#CDI
PFCaA /COPY QCOPYSRC,ID#PFC
KFSaA /COPY QCOPYSRC,ID#KFS
700aA /copy qcopysrc,p.getimuom
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
520bMD desc            s             20    dim(10) ctdata perrcd(1)
520bDD*desc            s             20    dim(8) ctdata perrcd(1)
510cDD*desc            s             20    dim(6) ctdata perrcd(1)
500bDD*desc            s             20    dim(5) ctdata perrcd(1)
510cDD*descsp          s             20    dim(6) ctdata perrcd(1)
520bDD*descsp          s             20    dim(8) ctdata perrcd(1)
520bMD descsp          s             20    dim(10) ctdata perrcd(1)

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
720bA*----------------------------------------------------------------
720bA*  Prototypes
720bA*----------------------------------------------------------------
720bA /copy qcopysrc,p.cvtbar
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
720bA /COPY *libl/qcopysrc,C#BARCODE
720bA /COPY *libl/qcopysrc,C#CVTPARMS
500 A /COPY *libl/qcopysrc,C#ITEM
500 A /COPY *libl/qcopysrc,C#SLOT
720bA /COPY *libl/qcopysrc,C#UCIINFO
720bA /COPY *libl/qcopysrc,C#LICENSE
500 AD saveVer#        s                   like($slver#)
610cDD*save$slot       s                   like($slot)

610cA*----------------------------------------------------------------
610cA*  Tracking variables
610cA*----------------------------------------------------------------
610cA
610cA /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $puser                39     48
720bAD  $SlotLcns             49     63
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
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $luser                19     28
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
     D  $lusr1                54     63
     *
510d D  $lteam                27     36
510e D  $lcupc                37     37
510e D  $lcadd                38     38
510e D  $lccwt                39     39
     *
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
     *                                       1   8 $CVDOP
     *                                       9  140$CVDD6
     *                                      15  220$CVDD8

500 A*----------------------------------------------------------------
500 A*  LT210 parameters
500 A*----------------------------------------------------------------

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
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
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

416bA*----------------------------------------------------------------
416bA*  API programs
416bA*
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
     D  erdate                 1      6  0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500eAD #msgsp          c                   const('PIRMSGFSP ')
510c D #msgfc          c                   const('QCPFMSG   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
720bA /Copy qcopysrc,c#pgminfds
720bDD*               sds
720bDD* #prog            *proc
720bDD* #pgm             *proc
720bDD* #job                 244    253
720bDD* #user                254    263
720bDD* #jobn                264    269
720bDD* #jobdt               276    281  0
720bDD* #jobtm               282    287  0
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
     *  Variables
     *

500 AD #toititem       s                   like($ititem)
500 AD #toittype       s                   like($ittype)
500 AD #toitdesc       s                   like($itdesc)
500 AD #toitpdsc       s                   like($itpdsc)
500 AD #toithead       s             70
500 AD #toitwhdp       s                   like($itwhdp)
500 AD #toitstyp       s                   like($itstyp)
500 AD #toitdesg       s                   like($itdesg)
500 AD #toitum1        s                   like($itum1)
500 AD #toitflg1       s                   like($itflg1)
500 AD #toitum2        s                   like($itum2)
500 AD #toitumq2       s                   like($itumq2)
500 AD #toitflg2       s                   like($itflg2)
500 AD #toitum3        s                   like($itum3)
500 AD #toitumq3       s                   like($itumq3)
500 AD #toitnrpk       s                   like($imnrpk)
500 AD #toitflgd       s                   like($itflgd)
500 AD #toitcube       s                   like($itcube)
500 AD #toitswgt       s                   like($itswgt)
500 AD #toitcwgt       s                   like($itcwgt)
CDIaAD #toitvit#       s                   like($itvit#)
500 AD #toitmitem      s                   like($itmitem)
500 AD #toitsdef       s                   like($idsdef)
500 AD #toittie        s                   like($idtie)
500 AD #toithigh       s                   like($idhigh)

500 AD #tossbititem    s                   like($ititem)
500 AD #tossbittype    s                   like($ittype)
500 AD #tossbitdesc    s                   like($itdesc)
500 AD #tossbitpdsc    s                   like($itpdsc)
500 AD #tossbitwhdp    s                   like($itwhdp)
500 AD #tossbitstyp    s                   like($itstyp)
500 AD #tossbitdesg    s                   like($itdesg)
500 AD #tossbitum1     s                   like($itum1)
500 AD #tossbitum2     s                   like($itum2)
500 AD #tossbitumq2    s                   like($itumq2)
500 AD #tossbitum3     s                   like($itum3)
500 AD #tossbitumq3    s                   like($itumq3)
CDI AD #tossbitvit#    s                   like($itvit#)

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
610cAD baseDisp        s                   like($sldisp)
610aAD cancel          s               n
500 AD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
JORa D e$bpu           s              1
JORa D e$lng           s              2
     D enter           s              5  0
500 MD error           s               n
     D excode          s              1
500b D exwgt           s              9  2
500b D exwg2           s              7  2
610cAD firstSlotEnt    s                   like($sldisp)
500 AD forevr          s               n
610cAD forever         s               n
     D help            s              5  0
500b D hirng           s              9  2
500b D hivar           s              9  2
500b D hvskp           s              1
500b D ihrng           s              9  2
500b D ihvar           s              9  2
500b D ilrng           s              9  2
500b D ilvar           s              9  2
610cAD initSC2         s               n
520b D kylic           s                   like(lilcns)
520b D kyuci           s                   like(ucinbr)
510c D kyupc           s                   like(upupc)
500b D lvskp           s              1
500b D lwrng           s              9  2
500b D lwvar           s              9  2
     D msgk            s              4  0
610cAD nomore          s               n
510c D noupc           s              1
     D nsctr           s              1  0
     D nxtscr          s              3
500a D ovrrid          s              1
610cAD pass            s              1  0
     D pdisp           s                   like(ivsdsp)
500b D prg1c           s              4  3
500b D prg2c           s              4  3
     D pwhdp           s                   like(ivswhd)
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D scode           s              2
500a D slchk           s              1
500 AD ssbflg          s               n
500a D svdisp          s                   like(ivsdsp)
500b D swgt2           s              7  2
610cAD temp2A          s              2
610cAD touched         s              5  0
610cAD touchedList     s           2106
610cAD trackLevel      s              1
510c D upcctr          s              3  0
610cAD useSlot         s               n
610cDD*vflag           s              1
     D warn            s              1
500b D wkcode          s              8
500b D wkwhse          s                   like($lwhse)
     D woidte          s              8  0
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
520b D woupc           s                   like(upupc)
500b D wtchk           s              1
500 AD zmsflag         s               n
700aAD KiloLbs         s              1
700aAD BegKiloLbs      s              1
700aAD kgs2lbs         c                   2.20462262
700aAD CnvWgt          s              9  2
700aAD IMUOM           s              3
720bAD  $ppartime      s               Z
720bAD* uciqty         s              5  0
720bAD  uciwgttot      s              9  2
720bAD today           s              8  0
     *----------------------------------------------------------------
500b I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
500b D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
500b D  optend               117    117
     *----------------------------------------------------------------
510eA*----------------------------------------------------------------
510eA*  *COUNT   -  Inventory count options.
510eA*----------------------------------------------------------------
510eA*
510eA* Fields
510eA*
510eA*    OPCUPC  -  Scan UPC to confirm item counted Y/N
510eA*    OPCADD  -  RF add item in slot Y/N
530bA*    OPCSCN  -  RF scan UPC or Lic to add item Y/N
530bA*    OPCKIN  -  RF key in item to add item Y/N
510eA*    OPCCWT  -  Caputure catch weight Y/N
510eA*
510eA* Data structure
510eA*
510eAD opdat1          ds
510eAD  opcupc                 1      1
510eAD  opcadd                 2      2
530bAD  opcscn                 3      3
530bAD  opckin                 4      4
530bAD  opccwt                 5      5
530bDD* opccwt                 3      3
730aDD* opdqty                 6      6
730aMD  opcdqt                 6      6
510eAD  op1end               117    117
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
610cDC**                 eval      vflag = *off
     *
610cDC**                 call      'BFCADR'
610cDC**                 parm                    $rtn              8
610cDC**                 if        $rtn = '*EXPIRED'
610cDC**                 eval      nxtscr = 'EOJ'
610cDC**                 else
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
610cDC**                 endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
500b C     nxtscr        caseq     '05 '         sc5
520b C     nxtscr        caseq     '06 '         sc6
720b C     nxtscr        caseq     '07 '         sc7
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
500 AC                   exsr      zzzdriclose
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
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
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn1sp                              50
500eAC                   other
     C                   exfmt     screen1                              50
500eAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn2sp                              50
500eAC                   other
     C                   exfmt     screen2                              50
500eAC                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn3sp                              50
500eAC                   other
     C                   exfmt     screen3                              50
500eAC                   endsl
     C                   endif
     C                   if        nxtscr = '04 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn4sp                              50
500eAC                   other
     C                   exfmt     screen4                              50
500eAC                   endsl
     C                   endif
500bAC                   if        nxtscr = '05 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn5sp                              50
500eAC                   other
500bAC                   exfmt     screen5                              50
500eAC                   endsl
500bAC                   endif
520b C                   if        nxtscr = '06 '
520bAC                   select
520bAC                   when      e$lng = 'SP'
520bAC                   exfmt     scrn6sp                              50
520bAC                   other
520b C                   exfmt     screen6                              50
520bAC                   endsl
520b C                   endif
720bAC                   if        nxtscr = '07 '
720bAC                   select
720bAC                   when      e$lng = 'SP'
720bAC                   exfmt     scrn7sp                              50
720bAC                   other
720bAC                   exfmt     screen7                              50
720bAC                   endsl
720bAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
610dMC                   setoff                                       98
510cDC*                  setoff                                       929398
     C                   eval      warn = *off
     C                   eval      error = *off
610aAC                   eval      cancel = *off
     C                   eval      cmdtkn = *off
416bAC                   eval      redspl = *off
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
500bA*----------------------------------------------------------------
     *
500bA*  Screen 05 initialization
     *
500bAC     scr05i        begsr
500bAC                   eval      nxtscr = '05 '
500bAC                   exsr      zzfil5
500bAC                   eval      refrsh = *off
500bAC     end05i        endsr
520bA*----------------------------------------------------------------
520bA*
520bA*  Screen 06 initialization
520bA*
520bAC     scr06i        begsr
520bAC                   eval      nxtscr = '06 '
520bAC                   exsr      zzfil6
520bAC                   eval      refrsh = *off
520bAC     end06i        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  Screen 07 initialization
720bA*
720bAC     scr07i        begsr
720bAC                   move      '07 '         nxtscr
720bA*
720bA*
720bA*  Get field defaults.
720bA*
720bAC                   exsr      zzdft7
720bA*
720bAC                   eval      refrsh = *off
720bAC                   eval      ovrrid = *off
720bAC     end07i        endsr
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
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
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
530aAC                   unlock    invslot4
530aAC                   unlock    invpage
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
530aAC                   unlock    invslot4
530aAC                   unlock    invpage
     C                   eval      refrsh = *off
     C                   exsr      zzinz2
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
416bAC     redspl        cabeq     *on           endsc2
610cDC**                 if        vflag = *off
610cDC**                 exsr      zzchkv
610cDC**                 endif
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
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
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
     C                   exsr      scr02i
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
610aAC     cancel        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
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
520b C*                  if        *in94 = *on
520b C                   if        opcupc = 'Y'
520b C                   exsr      scr06i
520b C                   else
     C                   exsr      scr03i
520b C                   endif
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
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
500bA*  SC5  -  Screen 5
     *
500bAC     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      refrsh = *off
     C*                  exsr      scr04i
     C*                  goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
500bAC     endsc5        endsr
520b *----------------------------------------------------------------
520b *
520b *  SC6  -  Screen 6
520b *
520b C     sc6           begsr
520b *
520b *  Test for F3 - Exit
520b *
520b C                   if        *inkc
520b C                   eval      nxtscr = 'EOJ'
520b C                   goto      endsc6
520b C                   endif
520b *
520b *  Test for F5 - Refresh
520b *
520b C                   if        *inke
520b C                   eval      refrsh = *on
520b C                   exsr      scr06i
520b C                   goto      endsc6
520b C                   endif
520b *
520b *  Test for F12 - Previous
520b *
520b C                   if        *inkl
520b C                   eval      refrsh = *off
520b C                   exsr      scr03i
520b C                   goto      endsc6
520b C                   endif
520b *
520b *  Test for other command keys BEFORE verification and update.
520b *
520b C                   eval      cmdchk = '*BEFORE '
520b C                   exsr      zzcmd6
520b C     cmdtkn        cabeq     *on           endsc6
520b *
520b *  Some other key pressed.
520b *
520b *     Check input and write/update record.
520b *
520b C                   exsr      zzchk6
520b C     error         cabeq     *on           endsc6
520b C                   exsr      zzupd6
520b C     error         cabeq     *on           endsc6
520b *
520b *  Test for other command keys AFTER verification and update.
520b *
520b C                   eval      cmdchk = '*AFTER  '
520b C                   exsr      zzcmd6
520b C     cmdtkn        cabeq     *on           endsc6
520b *
520b C     endsc6        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  SC7  -  Screen 7
720bA*
720bAC     sc7           begsr
720bA*
720bA*  Test for F3 - Exit
720bA*
720bAC                   if        *inkc
720bAC                   eval      nxtscr = 'EOJ'
720bAC                   goto      endsc7
720bAC                   endif
720bA*
720bA*  Test for F5 - Refresh
720bA*
720bAC                   if        *inke
720bAC                   eval      refrsh = *on
720bAC                   exsr      scr07i
720bAC                   goto      endsc7
720bAC                   endif
720bA*
720bA*  Test for F12 - Previous
720bA*
720bAC                   if        *inkl
720bAC                   eval      refrsh = *off
720bAC                   exsr      scr04i
720bAC                   goto      endsc7
720bAC                   endif
720bA*
720bA*  Test for other command keys BEFORE verification and update.
720bA*
720bAC                   eval      cmdchk = '*BEFORE '
720bAC                   exsr      zzcmd7
720bAC     cmdtkn        cabeq     *on           endsc7
720bA*
720bA*  Some other key pressed.
720bA*
720bA*     Check input and write/update record.
720bA*
720bAC                   exsr      zzchk7
720bAC     error         cabeq     *on           endsc7
720bAC                   exsr      zzupd7
720bAC     error         cabeq     *on           endsc7
720bA*
720bA*  Test for other command keys AFTER verification and update.
720bA*
720bAC                   eval      cmdchk = '*AFTER  '
720bAC                   exsr      zzcmd7
720bAC     cmdtkn        cabeq     *on           endsc7
720bA*
720bAC     endsc7        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
650aAC                   parm                    clientloc        10
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
720bA*
720bA*  Convert today's date into century format.
720bA*
720bAC                   eval      $cvcmd = '*CURCMD '
720bAC                   call      @cvtdt
720bAC                   parm                    $cvtdt
720bAC                   eval      today = $cvd8o
720bA*
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
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      $msgf = #msgsp
500eAC                   other
     C                   eval      $msgf = #msgf
500eAC                   endsl
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
510c *    ZMPCPF  Add CPF message record to subfile
510c *
510c C     zmpcpf        begsr
510c C                   if        $msgf = *blanks
510c C                   eval      $msgf = #msgfc
510c C                   endif
510c C                   call      'PUTMSG'
510c C                   parm                    $msgf
510c C                   parm                    #msgid
510c C                   parm                    #msgtp
510c C                   parm                    #msgdt
510c C                   parm                    #pgmq
510c C                   parm                    #msgk
510c C                   if        #msgid <> '*CLEAR '
510c C                   add       1             msgk
510c C                   write     msgrec
510c C                   endif
510c C                   eval      #msgdt = *blanks
510c C                   eval      $msgf = *blanks
510c C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      $msgf = #msgsp
500eAC                   other
     C                   eval      $msgf = #msgf
500eAC                   endsl
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

500 A*----------------------------------------------------------------
500 A*    DRI0001  Local system caused error
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001        begsr
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

500 A*----------------------------------------------------------------
500 A*    DRI0001s Local system caused error (send to different program)
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001s       begsr
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

     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*      0105s
500 A*
500 AC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
500b *      0110
     *
500b C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
500b C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Code must be entered.
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
520bA*   PIR0204  Enter only one value.
520bA*
520bAC     zm04          begsr
520bAC                   move      'PIR0204'     #msgid
520bAC                   move      '*DIAG  '     #msgtp
520bAC                   eval      $md = *blanks
520bAC                   exsr      zmpmsg
520bAC                   endsr
520bA*----------------------------------------------------------------
520bA*   PIR0205  Must enter one value.
520bA*
520bAC     zm05          begsr
520bAC                   move      'PIR0205'     #msgid
520bAC                   move      '*DIAG  '     #msgtp
520bAC                   eval      $md = *blanks
520bAC                   exsr      zmpmsg
520bAC                   endsr
     *----------------------------------------------------------------
     *   PIR1008  Date can't be blank.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
415a *----------------------------------------------------------------
415a *   IV21201  Qty entered without item.
415a *
415a C     zm1201        begsr
415a C                   eval      #msgid = 'IV21201'
415a C                   eval      #msgtp = '*DIAG  '
415a C                   movea     errmsg        $md
415a C                   exsr      zmpmsg
415a C                   endsr
500bA*----------------------------------------------------------------
500bA*     PT13021  Warning: Entered catch wt not within +/- range.
500bA*
500b C     zm21          begsr
500b C                   eval      #msgid = 'PT13021'
500b C                   eval      #msgtp = '*DIAG  '
500b C                   movea     errmsg        $md(1)
500b C                   exsr      zmpmsg
500b C                   endsr
     *----------------------------------------------------------------
     *   IV33001  No team defined for date.
     *
     C     zm3001        begsr
     C                   eval      #msgid = 'IV33001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33002  Slot not in inventory scope.
     *
     C     zm3002        begsr
     C                   eval      #msgid = 'IV33002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33003  Slot already entered.
     *
     C     zm3003        begsr
     C                   eval      #msgid = 'IV33003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
510e *----------------------------------------------------------------
510e *  IV33004   Option not set to add item to slot
510e *
510e C     zm3004        begsr
510e C                   eval      #msgid = 'IV33004'
510e C                   eval      #msgtp = '*DIAG  '
510e C                   movea     errmsg        $md
510e C                   exsr      zmpmsg
510e C                   endsr
520b *----------------------------------------------------------------
520b *  IV33006   Qty entered without item confirmation entered.
520b *
520b C     zm3006        begsr
520b C                   eval      #msgid = 'IV33006'
520b C                   eval      #msgtp = '*DIAG  '
520b C                   movea     errmsg        $md
520b C                   exsr      zmpmsg
520b C                   endsr
640aA*----------------------------------------------------------------
640aA*  IV33007   Print Sheet option must be run before count entry.
640aA*
640aAC     zm3007        begsr
640aAC                   eval      #msgid = 'IV33007'
640aAC                   eval      #msgtp = '*DIAG  '
640aAC                   movea     errmsg        $md
640aAC                   exsr      zmpmsg
640aAC                   endsr
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
510c *----------------------------------------------------------------
510c *   CPF9898  Generic error message
510c *
510c C     zm9898        begsr
510c C                   eval      #msgid = 'CPF9898'
510c C                   eval      #msgtp = '*DIAG  '
510c C                   movea     errmsg        $md
510c C                   exsr      zmpcpf
510c C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
510cA*----------------------------------------------------------------
510cA*   PO20029  UPC not on file.
510cA*----------------------------------------------------------------

510cAC     zm29          begsr
510cAC                   eval      #msgid = 'PO20029'
510cAC                   eval      #msgtp = '*DIAG  '
510cAC                   movea     errmsg        $md(1)
510cAC                   exsr      zmpmsg
510cAC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Make sure WHSE was entered.
     *
     C                   if        w1whse = *zero
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(1)     errmsg
500eAC                   other
     C                   movel     desc(1)       errmsg
500eAC                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify warehouse code.
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
     *    Make sure DATE was entered.
     *
     C                   if        w1idte = *zero
     C                   eval      error = *on
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(2)     errmsg
500eAC                   other
     C                   movel     desc(2)       errmsg
500eAC                   endsl
     C                   exsr      zm1008
     C                   endif
     *
     *
     *     Verify date
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
     C                   eval      erdate = w1idte
     C                   exsr      zm9906
     C                   else
     C                   eval      w1idte = $cvd6o
     *   Convert date and save.
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      woidte = $cvd8o
     C                   endif
     C                   endif
     *
     *    Make sure Team was entered.
     *
     C                   if        w1team = *blanks
     C                   eval      error = *on
     C                   eval      *in04 = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
     C                   movel     desc(3)       errmsg
500eAC                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify team.
     C                   if        not *in22
     C     vtkey         setll     invteam
     C     vtkey         reade     invteam                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
     C                   movel     desc(3)       errmsg
500eAC                   endsl
     C                   exsr      zm3001
     C                   endif
     C                   endif
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
500a *   SLCHK, Flags are used to force F20 for each test
500a *   Values: Flag = 0 Do check.
500a *           Flag = 1 Check was done, ok.
500a *           Flag = 2 Warning condition.
500a *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *
     *    Make sure Dept was entered.
     *
     C                   if        w2whdp = *blanks
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descSP(5)     errmsg
500eAC                   other
     C                   movel     desc(5)       errmsg
500eAC                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w2whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
650bA * need to skip slot conversion if svdisp = w3scan and override is on
650bAc                   if        svdisp <> w2disp
650bAc                             or *inkh = *off
416bA*
416bA*  Call API for slot.
416bA*
416bAC                   call      @apics
416bAC                   parm                    w2disp
416bAC                   parm      4             worow
416bAC                   parm      08            wocol
416bAC                   parm                    @artn             8
416bAC                   if        @artn = '*REDSPLY'
416bAC                   eval      redspl = *on
416bAC                   goto      endck2
416bAC                   endif
650bAc                   endif
610aA
610aA*  Get slot information.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = w1whse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = w2whdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = w2disp
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%GET'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmsflag = *off
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   eval      *in26 = *on
610aAC                   eval      *in06 = *on
610aAC                   goto      endck2
610aAC                   endif
610cA
610cAC                   eval      baseDisp = $sacdsp
     *
     *  Verify slot is in inventory scope.
     *
     C     slkey         chain     invslot4                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
416cD*R                   MOVELDESC,4    ERRMSG
416cMC     '"'           cat       w2disp        errmsg
416cMC     errmsg        cat       '"':0         errmsg
     C                   exsr      zm3002
     C                   else
640aA*  Verify print option has been run.
640aAc                   if        ivspag = 0
640aAC                   eval      error = *on
640aAC                   eval      *in23 = *on
640aAC                   eval      *in03 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   exsr      zm3007
640aAC                   goto      endck2
640aAc                   endif
     *  Verify slot has not been entered.
500a *
500aAC                   if        svdisp <> w2disp
500aAC                   eval      slchk = '0'
500aAC                   endif
500a *
500aAC                   if        slchk = '2'  and
500aAC                             ovrrid = *on
500aAC                   eval      slchk = '1'
500a *  Remove slot from INVEXCP
500a C     slkey         chain     invexcp2                           75
500a C                   if        not *in75
500a C                   delete    iverec
510f *  Reset status for iNVSLOT
610aDC**   slkey         chain     slot2                              78
610aDC**                 if        not *in78
610aMC                   eval      ivssta = $slstat
510f C                   update    ivsrec
610cAC     slkey         chain     invslot4                           79
610cAC                   if        *in79
610cAC                   eval      error = *on
610cAC                   eval      *in23 = *on
610cAC                   eval      *in03 = *on
610cAC                   eval      errmsg = *blanks
610cAC     '"'           cat       w2disp        errmsg
610cAC     errmsg        cat       '"':0         errmsg
610cAC                   exsr      zm3002
610cAC                   endif
610aDC**                 endif
500a C                   endif
500a *
500aAC                   endif
500a *
500aAC                   if        slchk <> '1'
500aAC                   eval      slchk = '1'
     C                   if        ivsedt <> *zero
     C                   eval      error = *on
500aAC                   eval      slchk = '2'
500aAC                   eval      warn = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(4)     errmsg
500eAC                   other
     C                   movel     desc(4)       errmsg
500eAC                   endsl
     C                   exsr      zm3003
     C                   endif
500aAC                   endif
500aAC     error         cabeq     *on           enderr
     C                   endif
417c *
417c *  Check if slot has pending quantities.
610aDC**   slkey         chain     slot2                              78
610aDC**                 if        not *in78
CDIbA *  For CDI JAX, skip pending quantities process.
CDIbAC     clientloc     cabeq     'CDIJAX'      enderr
KFSaAC     client        cabeq     kellys        enderr
610aMC                   if        $slalc1 <> 0  or
610aMC                             $slalc2 <> 0  or
610aMC                             $slalc3 <> 0  or
610aMC                             $sltfr1 <> 0  or
610aMC                             $sltfr2 <> 0  or
610aMC                             $sltfr3 <> 0  or
610aMC                             $slpck1 <> 0  or
610aMC                             $slpck2 <> 0  or
610aMC                             $slpck3 <> 0  or
610aMC                             $slrcv1 <> 0  or
610aMC                             $slrcv2 <> 0  or
610aMC                             $slrcv3 <> 0
417c *  Write to Inventory Check file.
417c C                   exsr      zzupck
417c *  Remove slot from INVPAGE count
417c C     keypg         chain     invpage                            75
417c C                   if        not *in75
417c *  IF slot is first or last on page, update INVPAGE with new slot
417c C                   if        ivpfrm = w2disp  or
417c C                             ivpto = w2disp
417c C                   exsr      zzuppg
417c C                   endif
417c C                   eval      ivpcnt = ivpcnt - 1
417c C                   if        ivpfrm = w2disp
417c C                   eval      ivpfrm = ivsdsp
417c C                   endif
417c C                   if        ivpto = w2disp
417c C                   eval      ivpto = ivsdsp
417c C                   endif
417c *  IF slot is only one on the page, update INVPAGE as entered.
417c C                   if        ivpfrm = w2disp  and
417c C                             ivpto = w2disp
417c C                   exsr      zzupdp
417c C                   else
417c C                   update    ivprec                               79
417c C                   endif
417c C                   endif
417c *  Remove slot from INVBSLT
417c C     slkey         chain     invbslt4                           75
417c C                   if        not *in75
417c C                   delete    ibsrec
417c C                   endif
417c *  Remove slot from scope.
417c C     slkey         chain     invslot4                           79
417c C                   if        not *in79
417c C                   delete    ivsrec
700cA*  udpate history records to show slot counted = P for pending
700cA /free
700cA   chain (ivswhs: ivswhd) invinuse;
700cA   if %found(invinuse);
700cA     icduid = inuuid;
700cA   endif;
700cA   chain (icduid: ivswhs: ivswhd: ivsdsp) invhstd;
700cA   if %found(invhstd);
700cA     icdslcnt= 'P';
700cA     icdsltts= %timestamp;
720aA     icditem = ivsitm;
700cA     update icdrec;
700cA   endif;
700cA /end-free
417c C                   endif
417c *  Display error, slot not in scope.
417c C                   eval      error = *on
417c C                   eval      *in23 = *on
417c C                   eval      *in03 = *on
417c C                   eval      errmsg = *blanks
417cMC     '"'           cat       w2disp        errmsg
417cMC     errmsg        cat       '"':0         errmsg
417c C                   exsr      zm3002
417c C                   goto      endck2
417c *
417c C                   endif
610aDC**                 endif
     *
500aAC     enderr        tag
500aA*
500aA*   Save screen fields.
500aAC                   move      w2disp        svdisp
     C     endck2        endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZCK2A   Screen 2A error checking. Called from ZZCMD2.
416bA*
416bAC     zzck2a        begsr
416bAC                   eval      error = *off
416bA*
416bA*    Make sure Dept was entered.
416bA*
416bAC                   if        w2whdp = *blanks
416bAC                   eval      error = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(5)     errmsg
500eAC                   other
416bAC                   movel     desc(5)       errmsg
500eAC                   endsl
416bAC                   exsr      zm03
416bAC                   endif
416bA*
416bA*  Verify warehouse department.
416bA*
416bAC                   eval      $lcmd = '*VERIFY '
416bAC                   eval      $lwhse = w1whse
416bAC                   eval      $lwhdp = w2whdp
416bAC                   call      'WD900'
416bAC                   parm                    $lparm
416bAC                   if        $lrtn = '*ERROR  '
416bAC                   eval      error = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in05 = *on
416bAC                   movel     $lerm         errmsg
416bAC                   exsr      zm0105
416bAC                   else
416bAC                   if        $lrtn = '*PGMQ   '
416bAC                   eval      error = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      #msgk = $lmsg
416bAC                   exsr      zmqmsg
416bAC                   endif
416bAC                   endif
416bA*
416bA*  Call API for slot.
416bA*
416bAC                   call      @apics
416bAC                   parm                    w2disp
416bAC                   parm      4             worow
416bAC                   parm      08            wocol
416bAC                   parm                    @artn
416bAC                   if        @artn = '*REDSPLY'
416bAC                   eval      redspl = *on
416bAC                   goto      enck2a
416bAC                   endif
610aA
610aA*  Get slot information.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = w1whse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = w2whdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = w2disp
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%GET'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmsflag = *off
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   eval      *in26 = *on
610aAC                   eval      *in06 = *on
610aAC                   goto      enck2a
610aAC                   endif
610cA
610cAC                   eval      baseDisp = $sacdsp
416bA*
416bA*  Verify slot is in inventory scope.
416bA*
416bAC     slkey         chain     invslot4                           79
416bAC                   if        *in79
416bAC                   eval      error = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in03 = *on
416bAC                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(4)     errmsg
500eAC                   other
416bAC                   movel     desc(4)       errmsg
500eAC                   endsl
416bAC                   exsr      zm3002
416bAC                   endif
416bA*
416bAC     enck2a        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     *
     *
415a *    Item must exist if quantity is entered
415a *
415aAC                   if        w4qt01 <> 0  or
415aAC                             w4qt02 <> 0  or
415aAC                             w4qt03 <> 0
415aAC                   if        w3item = *blanks
415aAC                   eval      error = *on
415aAC                   eval      *in06 = *on
415aAC                   eval      *in26 = *on
415aAC                   eval      errmsg = *blanks
415aAC                   exsr      zm1201
415aAC                   endif
520b *    Code for UPC scan moved from here to SCREEN 6.
520bA *  If UPC protected,values entered on Screen 6
520bA *   can not enter quantity if X was entered on Screen 6
520bAC                   if        opcupc = 'Y' and
520bAC                             woupc = 'X'
520bAC                   eval      error = *on
520bAC                   eval      *in06 = *on
520bAC                   eval      *in26 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   exsr      zm3006
520bAC                   goto      endck4
520bAC                   endif
415aAC                   endif
     *
     C     endck4        endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     *
     *
500bA*    Weight can't be zero.
     *
     C                   if        w5cwgt = 0
500dDC*                  eval      error = *on
500dDC*                  eval      *in09 = *on
500dDC*                  eval      *in29 = *on
500dDC*                  eval      errmsg = *blanks
500dDC*                  movel     desc(6)       errmsg
500dDC*                  exsr      zm0110
500dDC*                  goto      endck5
     C                   endif
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
500b C                   z-add     0             taddw             7 2
700aAc                   exsr      zzcnvwgt
700aDC*                  eval      taddw = w5cwgt
700aAC                   eval      taddw = cnvwgt
     *
     *   WTCHK, Flags are used to force F8 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     * Set flag
     C                   if        wtchk = '2' and
     C                             ovrrid = *on
     C                   eval      wtchk = '1'
     C                   endif
     *  Verify catch weight.
     C                   if        wtchk <> '1'
     C                   eval      wtchk = '1'
     *
     C*     Check individual CW if variance check = Y.
     C                   if        opwrnc = 'Y'
    DC**                           opicw  = 'Y'
     C**                 z-add     w5cwgt        cwgt              7 0
     C**   cwgt          div       100           taddw             7 2
500b C*                  z-add     0             taddw             7 2
500b C*                  eval      taddw = w5cwgt
     C                   if        lvskp = *off and
     C                             taddw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     lwrng         erlrng
     *
     C                   if        hvskp  = *on
     C                   z-add     0             erhrng
     C                   else
     C                   z-add     hirng         erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C*                  z-add     lbuwgt        erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   if        hvskp  = *off and
     C                             taddw  > hirng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   if        lvskp = *on
     C                   z-add     0             erlrng
     C                   else
     C                   z-add     lwrng         erlrng
     C                   endif
     C                   z-add     hirng         erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   endif
     C                   endif
     *
     *
     C     endck5        endsr
520bA*----------------------------------------------------------------
520bA*
520bA*  ZZCHK6   Screen 6 error checking.
520bA*
520bAC     zzchk6        begsr
520bAC                   eval      error = *off
520bAC                   eval      woupc = *blanks
520bA*
520bA** Enter only one, either license, UCI or UPC.
520bAC                   if        w6lcn <> *blanks  and
520bAC                             w6uci <> *blanks  and
520bAC                             w6upcd <> *blanks
520bAC                   move      *on           error
520bAC                   eval      *in26 = *on
520bAC                   eval      *in06 = *on
520bAC                   eval      *in27 = *on
520bAC                   eval      *in07 = *on
520bAC                   eval      *in30 = *on
520bAC                   eval      *in10 = *on
520bAC                   exsr      zm04
520bAC                   endif
520bA*
520bA*    Must enter one value License, UCI, UPC.
520bA*
520bAC                   if        w6lcn = *blanks  and
520bAC                             w6uci = *blanks  and
520bAC                             w6upcd = *blanks
500bAC                   eval      error = *on
520bAC                   eval      *in26 = *on
520bAC                   eval      *in06 = *on
520bAC                   eval      *in27 = *on
520bAC                   eval      *in07 = *on
520bAC                   eval      *in30 = *on
520bAC                   eval      *in10 = *on
520bAC                   exsr      zm05
520bAC                   endif
520bA*  Skip check if X is entered.
520bAC                   if        w6upcd = 'X'
520bAC                   eval      woupc = w6upcd
520bAC                   goto      endck6
520bAC                   endif
520bA*
520bA*    License entered
520bAC                   if        w6lcn <> *blanks
520bA*  Left justify license.
520bAC                   eval      $cstr = *blanks
520bAC                   move      w6lcn         $cstr
520bAC                   call      'ADJUST'
520bMC                   parm      '*LEFTNOZ'    $ccmd             8
520bAC                   parm                    $cstr            30
520bAC                   movel     $cstr         kylic
520b *
520b *  Verify license plate number.
520b *
520bAC     likey         setll     license
520bAC     likey         reade     license
520bAC                   if        not %eof
520bAC     lbkey         setll     label90
520bAC     lbkey         reade     label90
520bAC                   if        not %eof
520bAC                   if        lbitem = w3item
520b C                   goto      endck6
520b C                   endif
520b C                   endif
520b C                   endif
520b *  Invalid license-not found in LICENSE or LABEL or not for item
520b C                   eval      error = *on
520b C                   eval      *in26 = *on
520b C                   eval      *in06 = *on
520b C                   eval      errmsg = *blanks
520b C                   select
520b C                   when      e$lng = 'SP'
520b C                   movel     descsp(9)     errmsg
520b C                   other
520b C                   movel     desc(9)       errmsg
520bAC                   endsl
520b C                   exsr      zm9898
520b C                   goto      endck6
520b C                   endif
     *
520bA*    UCI entered.
520b C                   if        w6uci <> *blanks
520bAC                   eval      kyuci = w6uci
520b C     keyuci        chain     ucicw
520b C                   if        %found(ucicw)
520bAC                   if        uciitm = w3item
520bAC                   goto      endck6
520b C                   endif
520b C                   endif
520b C                   eval      error = *on
520b C                   eval      errmsg = *blanks
520bAC                   select
520bAC                   when      e$lng = 'SP'
520bAC                   eval      errmsg = descsp(10)
520bAC                   other
520b C                   eval      errmsg = desc(10)
520bAC                   endsl
520b C                   eval      *in27 = *on
520b C                   eval      *in07 = *on
520b C                   exsr      zm9898
520b C                   goto      endck6
520b C                   endif
     *
520bA*
520bA*  UPC entered
520bA*
520bAC                   if        w6upcd <> *blanks
520bA*
520bA*     UPC code not on file.
520bA*
520bAC                   eval      $cbcmd = '*UPC    '
520bAC                   movel     w6upcd        $cbbar
520bAC                   call      'CVTBAR'
520bAC                   parm                    $cbcmd            8
520bAC                   parm                    $cbbar          100
520bAC                   parm                    $cbcod            3 0
520bAC                   parm                    $cbdec            1 0
520bAC                   parm                    $cbdsc           30
520bAC                   parm                    $cbpos            3 0
520bAC                   parm                    $cbtyp            1 0
520bAC                   parm                    $cbv1            11 3
520bAC                   parm                    $cbv2            50
520bAC                   parm                    $cbrtn            8
520bAC                   parm                    $cberm           60
520bA*
520bAC                   if        $cbrtn = '*OK'
750aAC                             or $cbrtn = '*UPCWARN'
520bAC                   eval      w6upcd = $cbv2
520bAC                   endif
520bA*
520bA*   Right adjust UPC code for file.
520bA*
520bAC                   eval      $cstr = *blanks
520bAC                   movel     w6upcd        $cstr
520bAC                   call      'ADJUST'
520bAC                   parm      '*RIGHT  '    $ccmd             8
520bAC                   parm                    $cstr            30
520bAC                   move      $cstr         kyupc
520bA*    UPCCTR = 0, error, upc code not found.
520bA*    UPCCTR = 1, UPC found,
520bAC                   eval      upcctr = 0
520bAC     upckey        setll     upc
520bAC                   dow       forevr = forevr
520bAC     upckey        reade     upc                                    79
520bA*
520bAC                   if        *in79
520bAC                   leave
520bAC                   else
520bAC                   if        w3item = upitem
520bAC                   add       1             upcctr
520bAC                   leave
520bAC                   endif
520bAC                   endif
520bA*
520bAC                   enddo
520bA* UPC not found for item
520bAC                   if        upcctr = 0
520bAC                   eval      error = *on
520bAC                   eval      *in30 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   eval      w6upcd = *blanks
520bAC                   select
520bAC                   when      e$lng = 'SP'
520bAC                   movel     descsp(8)     errmsg
520bAC                   other
520bAC                   movel     desc(8)       errmsg
520bAC                   endsl
520bAC                   exsr      zm9898
520bAC                   goto      endck6
520bAC                   endif
520bA*
520bAC                   endif
520bA*
520bAC     endck6        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  ZZCHK7   Screen 7 error checking.
720bA
720bAC     zzchk7        begsr
720bAC                   eval      error = *off
720bA
720bA*   Edit for correct scan qty matching count qty - f22
720bA /free
720bA   if *inkw;
720bA     if w4qt01 <> uciqty1 or
720bA        w4qt02 <> uciqty2 or
720bA        w4qt03 <> uciqty3;
720bA       error = *on;
720bA       errmsg = 'Count Qty and Scan qty do not match';
720bA       exsr zm0105;
720bA       leavesr;
720bA     endif;
720bA   endif;
720bA /end-free
720bA*   Verify UCI scannin Rules
720bA
720bAC                   if        w7uci = ' '
720bAC                   eval      error = *on
720bAC                   eval      *in35 = *on
720bAC                   eval      *in01 = *on
720bAC                   select
720bAC                   when      e$lng = 'SP'
720bAC                   eval      errmsg = 'uci'
720bAC                   other
720bAC                   eval      errmsg = 'uci must be scanned'
720bAC                   endsl
720bAC                   exsr      zm0105
720bAc                   leavesr
720bAC                   endif
720bA
720bA /free
720bA   // has the uci already been scanned for this adjustment
720bA   w7uci = %TrimL(w7uci);
720bA   exsr clr$uciinfo;

720bA   $uiWhse = $pwhse;
720bA   $uiuci  = w7uci;
720bA   $uiapartlts = $ppartime;

720bA   $dricommand = '*UCIINFO';
720bA   $drisubcmd  = '%VFYCURMV';
720bA   $drisys2upd = 'D';
720bA   exsr zzzdricop;
720bA   // if return is *OK we can continue
720bA   if $drireturn <> '*OK';
720bA     error = *on;
720bA     *in21 = *on;
720bA     *in01 = *on;
720bA     errmsg = $drimessage;
720bA     exsr zm0105;
720bA     leavesr;
720bA   endif;
720bA   // is the UCI active in the system
720bA   exsr clr$uciinfo;

720bA   $uiWhse = $pwhse;
720bA   $uiuci  = w7uci;
720bA   $uiitem = $slitem;

720bA   $dricommand = '*UCIINFO';
720bA   $drisubcmd  = '%CHK4ADJ';
720bA   $drisys2upd = 'D';
720bA   //chk4err = *on;
720bA   exsr zzzdricop;

720bA       select;

720bA         // return= *OK, that means the uci is already in uciinfo
720bA         when $drireturn = '*OK';
720bA           error = *off;
720bA           // if the uci is attached to the license being adjusted
720bA           // it can not be scanned for an add adjustment

720bA           // adjustment to pick slot could have *MULTIPLE in
720bA           // $slotlcns - this will need a further check to
720bA           // determine if the uci is already in the pick slot
720bA           if $slotlcns = '*MULTIPLE';
720bA             exsr clr$license;
720bA             $liToWhseU = *on;
720bA             $liToWhse = $pWhse;
720bA             $liToWhdpU = *on;
720bA             $liToWhdp = $slwhdp;
720bA             $liToDispU = *on;
720bA             $liToDisp = $pdisp;
720bA             $liToLcnsU = *on;
720bA             $liToLcns = $uilcns;
720bA             $dricommand = '*LICENSE';
720bA             $drisubcmd  = '%GETLCNS';
720bA             $drisys2upd = 'D';
720bA             chk4err = *on;
720bA             exsr zzzdricop;
720bA             if $pdisp = $LITOBASE;
720bA               errmsg = 'UCI Is Already in this Slot';
720bA               error = *on;
720bA               exsr zm0105;
720bA               leavesr;
720bA             endif;
720bA             // should have the licative slot for the license
720bA             // the uci is attached to, if it is the slot being
720bA             // adjusted - this is an error.
720bA           endif;

720bA           //if $slotLcns = $uilcns;
720bA             //errmsg = 'UCI Is Already in this Slot';
720bA             //error = *on;
720bA             //exsr zm0105;
720bA             //leavesr;
720bA           //endif;
720bA           $uiaction = 'ADJUPD';

720bA         // return= *NOTACTIVE is a good return, proceed to update
720bA         // means the uci does not exist as active in the warehouse
720bA         when $drireturn = '*NOTACTIVE';
720bA           error = *off;
720bA           // need to convert the barcode to extract the GTIN
720bA           cvtbar('*ALL': w7UCI:
720bA             $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
720bA             $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
720bA           $barcode = $cvtdata;
720bA           $barcode2 = $cvtdata2;
720bA           // make sure the gtin is for the item being adjusted
                if $bcgtinsent;
      /end-free
720bA*   Right adjust UPC code for edit.
720bA*
720bAC                   eval      $cstr = *blanks
720bAC                   movel     $bcgtin       $cstr
720bAC                   call      'ADJUST'
720bAC                   parm      '*RIGHT  '    $ccmd             8
720bAC                   parm                    $cstr            30
720bAC                   move      $cstr         kyupc
720bA /free
720bA             chain ($pwhse: $slitem: kyupc) upc2;
720bA             if not %found(upc2);
720bA               errmsg = 'UCI does not match Item';
720bA               error = *on;
720bA               exsr zm0105;
720bA               leavesr;
720bA             endif;
720bA           else;
720bA             // invalid gtin
720bA             // 99 uci?
720bA             if %subst(w7uci:1:3) = '99I';
720bA               errmsg = 'GS1-99 must be assigned first';
720bA               error = *on;
720bA               exsr zm0105;
720bA               leavesr;
720bA             else;
720bA               errmsg = 'No GTIN Found-Invalid UCI';
720bA               error = *on;
720bA               exsr zm0105;
720bA               leavesr;
720bA             endif;
720bA           endif;

720bA           $uiaction = 'ADJADD';
720bA           leavesr;
              other;
720bA           errmsg = $drimessage;
720bA           error = *on;
720bA           exsr zm0105;
720bA           leavesr;
720bA       endsl;
720bA /end-free
720bA
720bA*  If error has occured then skip the rest of the checks.
720bA
720bAC     error         cabeq     *on           endck7
720bA
720bAC     endck7        endsr
610cDC**---------------------------------------------------------------
610cDC**
610cDC** ZZCHKV   Check if slot has virtual slots.
610cDC**
610cDC**   zzchkv        begsr
610cDC**                 eval      error = *off
610cDC**                 eval      pwhdp = w2whdp
610cDC**                 eval      pdisp = w2disp
414 D *R         SLKEY     SETLLVSLOT2
414 D *R         SLKEY     READEVSLOT2                   79
610cDC**   pskey         setll     vslot2
610cDC**   pskey         reade     vslot2                                 79
610cDC**
610cDC** If vslots exist, set flag.
610cDC**
610cDC**                 if        not *in79
610cDC**                 eval      vflag = *on
414 D *R         SLKEY     SETLLVSLOT2
610cDC**   pskey         setll     vslot2
610cDC**                 endif
610cDC**
610cDC**   endckv        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 3
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     SLOT.
     *
4    *R         ROW#      WHEQ 6
     *R                   MOVE *ON       *IN03
     *R                   MOVE '*GENERAL'$LCMD
     *R                   Z-ADDW1WHSE    $LWHSE
     *R                   MOVE W1WHDP    $LWHDP
     *R                   MOVE *BLANKS   $LITEM
     *R                   MOVE W2DISP    $LDISP
     *R                   CALL 'SL900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*SELECT '
     *R                   MOVE $LDISP    W2DISP
     *R                   ENDIF
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
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse department.
     *
     C                   when      row# = 3
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w2whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w2whdp = $lwhdp
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
510d *
510d *  F6 - Add item.
510d *
510d C                   if        *inkf
610xAC                   unlock    invslot4
510e *  Check option to allow add item.
510e C                   if        opcadd <> 'Y'
510e C                   eval      error = *on
510e C                   eval      *in05 = *on
510e C                   eval      *in25 = *on
510e C                   eval      errmsg = *blanks
510eAC                   select
510eAC                   when      e$lng = 'SP'
510eAC                   movel     descSP(5)     errmsg
510eAC                   other
510e C                   movel     desc(5)       errmsg
510eAC                   endsl
510e C                   exsr      zm3004
510eAC                   else
510d *
510d C                   if        w2whdp = *blanks
510d C                   eval      error = *on
510d C                   eval      *in05 = *on
510d C                   eval      *in25 = *on
510d C                   eval      errmsg = *blanks
510dAC                   select
510dAC                   when      e$lng = 'SP'
510eAC                   movel     descSP(5)     errmsg
510eAC                   other
510d C                   movel     desc(5)       errmsg
510dAC                   endsl
510d C                   exsr      zm03
510d C                   else
520c C                   unlock    invslot4
520c C                   unlock    invpage
     C                   eval      cmdtkn = *on
510d C                   eval      $lcmd = '*CREATE '
510d C                   eval      $lprg = #prog
510d C**                 z-add     $pwhse        $lwhse
510d C                   eval      $lwhdp = w2whdp
510d C                   eval      $lteam = ivttem
510e C                   eval      $lcupc = opcupc
510e C                   eval      $lcadd = opcadd
510e C                   eval      $lccwt = opccwt
510d C                   call      'IV333'
510d C                   parm                    $lparm
     C                   goto      endcm2
510d C                   endif
510e C                   endif
510d C                   endif
     *
     *  F8 - Override Slot already entered error, accept warning
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C                   else
     C                   move      *off          ovrrid
     C                   endif
     *
     *
     *  Test for F10 - EXCEPTION - SLOT
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
416bD*R                   MOVE PWHDP     W2WHDP
416bD*R                   MOVE PDISP     W2DISP
610dDC**                 eval      w2whdp = pwhdp
610dDC**                 eval      w2disp = pdisp
416bA*
416bA*  Call edit routine before logging exception.
416bA*
417bAC                   if        w2disp <> *blanks
416bAC                   exsr      zzck2a
416bAC                   if        error = *on  or
416bAC                             redspl = *on
416bAC                   goto      endcm2
416bAC                   endif
417bAC                   endif
416bA*
     C     slkey         chain     invslot4                           79
     C                   eval      cmdtkn = *on
     C                   eval      excode = *on
     C                   exsr      zzexcp
     C                   eval      scode = 'X '
     C                   exsr      zzupdi
610cAC                   exsr      zzTouch
     C                   exsr      scr02i
     C                   goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - EXCEPTION - ITEM
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   eval      excode = '2'
     C                   exsr      zzexcp
     C                   eval      scode = 'X '
     C                   exsr      zzupdi
610cAC                   exsr      zzTouch
     C                   exsr      scr02i
     C                   goto      endcm3
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm4
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - EXCEPTION - BREAKDOWN QTY
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   eval      excode = '3'
     C                   exsr      zzexcp
     C                   eval      scode = 'X '
     C                   exsr      zzupdi
610cAC                   exsr      zzTouch
     C                   exsr      scr02i
     C                   goto      endcm4
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZCMD5   User defined command keys for screen 5.
     *
500bAC     zzcmd5        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F8 - EXCEPTION - Catch Weight Override
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C*                  eval      cmdtkn = *on
     C                   eval      excode = '4'
     C                   exsr      zzexcp
     C                   eval      scode = '  '
     C                   goto      endcm5
     C                   else
     C                   move      *off          ovrrid
     C                   endif
700aA*
700aA*      F7 - kilograms/Pounds Toggle
700aA*
700aAC                   if        *inkg
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W5um1   = 'Kgs'
700aAC                   Eval      *in31 = *off
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W5um1   = 'Lbs'
700aAC                   Eval      *in31 = *on
700aAC                   endif
700aAC                   endif
700aAC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
500bAC     endcm5        endsr
520b *----------------------------------------------------------------
520b *
520b *  ZZCMD6   User defined command keys for screen 6.
520b *
520b C     zzcmd6        begsr
520b C                   eval      cmdtkn = *off
520b *
520b *  Test for F4 - Lookup
520b *
520b C                   if        *inkd
520b C                   eval      cmdtkn = *on
520b C                   z-add     0             row#
520b C                   eval      row = rowin
520b C                   z-add     0             col#
520b C                   eval      col = colin
520b *
520b C                   select
520b *
520b C                   other
520b *
520b *     Cursor not on a valid lookup field.
520b *
520b C                   eval      error = *on
520b C                   exsr      zm9905
520b C                   endsl
520b C                   goto      endcm6
520b C                   endif
520b *
520b *  Command keys to check BEFORE verification and update.
520b *
520b C                   if        cmdchk = '*BEFORE '
520b *
520b C                   endif
520b *
520b *  Command keys to check AFTER verification and update.
520b *
520b C                   if        cmdchk = '*AFTER  '
520b C                   endif
520b C     endcm6        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  ZZCMD7   User defined command keys for screen 7.
720bA*
720bAC     zzcmd7        begsr
720bAC                   eval      cmdtkn = *off
720bA*
720bA*  Test for F4 - Lookup
720bA*
720bAC                   if        *inkd
720bAC                   eval      cmdtkn = *on
720bAC                   z-add     0             row#
720bAC                   eval      row = rowin
720bAC                   z-add     0             col#
720bAC                   eval      col = colin
720bA*
720bAC                   goto      endcm7
720bAC                   endif
720bAC                   if        cmdchk = '*AFTER  '
720bA*
720bA*      F22 - Done scanning.
720bA*
720bAC                   if        *inkw
720bAC                   eval      cmdtkn = *on
720bA*
720bA*  Capture CW if catch weight item if option = Y and
720bA*  item is cw item.
720bAC                   if        opccwt = 'Y' and
720bAC                             #toitcwgt = 'Y' and
720bAC                             Client <> packers
720bAC                   exsr      scr05i
720bAC                   else
720bAC                   eval      woqt01 = 0
720bAC                   eval      woqt02 = 0
720bAC                   eval      woqt03 = 0
720bAC                   exsr      scr02i
720bAC                   endif
720bAC                   endif
720bAC                   endif
720bA*
720bAC     endcm7        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  ZZDFT7   Get default values.
720bA*
720bAC     zzdft7        begsr
720bA*
720bAc                   eval      w7uci  = ' '
720bA*
720bAC                   endsr
500bA*----------------------------------------------------------------
500bA*
500bA*  ZZCWGT   Calculate catch weight variance values.
500bA*
500bAC     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
     C                   if        opwrnc = 'Y'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             exwg2
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     C                   z-add     0             swgt2
     *   Calc extended wt.
500b C**   $slvlopickqty mult      $slvlouwgt    exwgt
     C     woqt01        mult      #toitswgt     exwgt
     *   Calc extended wt for each item.
     C                   if        #toitumq2 <> 0
     C     #toitswgt     div       #toitumq2     swgt2
     C     woqt02        mult      swgt2         exwg2
     C                   add       exwg2         exwgt
     C                   endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C*    $slvlouwgt    mult      prg1c         ilvar
     C     #toitswgt     mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
     C*    $slvlouwgt    sub       ilvar         ilrng
     C     #toitswgt     sub       ilvar         ilrng
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C*    $slvlouwgt    mult      prg2c         ihvar
     C     #toitswgt     mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
     C*    $slvlouwgt    add       ihvar         ihrng
     C     #toitswgt     add       ihvar         ihrng
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Create Exception record.
     *
     C     zzexcp        begsr
     C                   eval      ivewhs = ivswhs
     C                   eval      ivepag = ivspag
     C                   eval      ivedsp = ivsdsp
500b C                   if        excode = '4'
500b C                   eval      ivesta = '4'
500b C                   else
     C                   eval      ivesta = *on
500b C                   endif
     C                   eval      ivewhd = ivswhd
     C                   eval      iveasl = ivsasl
     C                   eval      iveloc = ivsloc
     C                   eval      ivelvl = ivslvl
     C                   eval      ivehnd = ivshnd
     C                   eval      ivestp = ivsstp
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      iveedt = $cvd8o
     C                   time                    iveetm
     C                   eval      iveeby = ivttem
     C                   eval      iveecd = excode
     C                   write     iverec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endexc
     C                   endif
     C     endexc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     C                   eval      w1team = *blanks
     C                   eval      w1idte = *zeros
610cA
610cAC                   eval      initSC2 = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
610cDC**                 if        vflag = *on
610cDC**   pskey         reade     vslot2                                 79
610cDC**                 if        not *in79
610cDC**                 eval      w2whdp = vswhdp
610cDC**                 eval      w2disp = vsdisp
610cDC**                 else
610cDC**                 eval      vflag = *off
610cDC**                 endif
610cDC**                 endif

610cA*   If not initializing SC2
610cA*     Then look for next slot to display.
610cA
610cAC                   if        not initSC2
610cAC                   exsr      zzGetSlot
610cAC                   if        nomore
610cAC                   eval      initSC2 = *on
610cAC                   else
PFCaAc                   Select
PFCaAC                   when      client = presto
PFCaAC                   eval      w2disp = %trim($sldisp) + '.'
PFCaAc                   other
610cAC                   eval      w2disp = $sldisp
PFCaAC                   endsl
610cAC                   endif
610cAC                   endif
610cA
610cA*   Clear display field if necessary.
610cA
610cDC**                 if        vflag = *off
610cAC                   if        initSC2
     C                   eval      w2disp = *blanks
650bAC                   eval      svdisp = *blanks
610cAC                   eval      pass = 1
610cAC                   eval      touchedList = ' '
610cAC                   eval      firstSlotEnt = ' '
     C                   endif
     *
610cAC                   eval      initSC2 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
610eDC**                 eval      w3item = ivsitm
610fAC                   if        ivssta = 'Z'
610fAC                   eval      w3item = ivsitm
610fAC                   else
610eMC                   eval      w3item = $slitem
610fAC                   endif
     *
     *   Get item description.
     *
610cAC                   exsr      zzgetitem
500 DC**   keyit         chain     piritem                            79
500 DC**                 if        *in79
610cDC**
610cDC** Use DRI interface to get item.
610cDC**
610cDC**                 exsr      clr$item
610cDC**                 eval      $itwhse  = w1whse
610cDC**                 eval      $ititem  = ivsitm
610cDC**
610cDC**                 eval      $dricommand = '*ITEM'
610cDC**                 eval      $drisubcmd  = '%GETMAIN'
610cDC**                 eval      $drisys2upd = 'D'
610cDC**                 eval      chk4err = *on
610cDC**                 eval      zmsflag = *off
610cDC**                 exsr      zzzdricop
610cDC**                 if        error
610cDC**                 eval      error = *off
610cDC**                 eval      $itdesc = 'ITEM NOT FOUND'
500 DC**                 eval      w3itm1 = *blanks
500 DC**                 eval      w3itm2 = *blanks
500 DC**                 eval      w3itm3 = *blanks
500 DC**                 eval      itumq2 = 0
500 DC**                 eval      itumq3 = 0
500 DC**                 else
610cDC**                 endif
610cDC**
610cDC**                 eval      #toititem = $ititem
610cDC**                 eval      #toittype = $ittype
610cDC**                 eval      #toitdesc = $itdesc
610cDC**                 eval      #toitpdsc = $itpdsc
610cDC**                 eval      #toitwhdp = $itwhdp
610cDC**                 eval      #toitstyp = $itstyp
610cDC**                 eval      #toitdesg = $itdesg
610cDC**                 eval      #toitum1  = $itum1
610cDC**                 eval      #toitflg1 = $itflg1
610cDC**                 eval      #toitum2  = $itum2
610cDC**                 eval      #toitumq2 = $itumq2
610cDC**                 eval      #toitflg2 = $itflg2
610cDC**                 eval      #toitum3  = $itum3
610cDC**                 eval      #toitumq3 = $itumq3
610cDC**                 eval      #toitnrpk = $imnrpk
610cDC**                 eval      #toitflgd = $itflgd
610cDC**                 eval      #toitcube = $itcube
610cDC**                 eval      #toitswgt = $itswgt
610cDC**                 eval      #toitcwgt = $itcwgt
610cDC**                 eval      #toitmitem = $itmitem
610cDC**
610cDC** Use DRI interface to get corresponding SSB item, if any.
610cDC**
610cDC**                 exsr      clr$item
610cDC**                 eval      $itwhse  = w1whse
610cDC**                 eval      $ititem  = ivsitm
610cDC**
610cDC**                 eval      $dricommand = '*ITEM'
610cDC**                 eval      $drisubcmd  = '%GETSSB'
610cDC**                 eval      $drisys2upd = 'D'
610cDC**                 eval      chk4err = *off
610cDC**                 eval      zmsflag = *off
610cDC**                 exsr      zzzdricop
610cDC**                 if        $drireturn = 'SSBNOTFND'
610cDC**                 eval      ssbflg  = *off
610cDC**                 eval      #tossbititem = ' '
610cDC**                 eval      #tossbittype = ' '
610cDC**                 eval      #tossbitdesc = ' '
610cDC**                 eval      #tossbitpdsc = ' '
610cDC**                 eval      #tossbitwhdp = ' '
610cDC**                 eval      #tossbitstyp = ' '
610cDC**                 eval      #tossbitdesg = ' '
610cDC**                 eval      #tossbitum1  = ' '
610cDC**                 eval      #tossbitum2  = ' '
610cDC**                 eval      #tossbitumq2 = 0
610cDC**                 eval      #tossbitum3  = ' '
610cDC**                 eval      #tossbitumq3 = 0
610cDC**                 else
610cDC**                 eval      ssbflg  = *on
610cDC**                 eval      #tossbititem = $ititem
610cDC**                 eval      #tossbittype = $ittype
610cDC**                 eval      #tossbitdesc = $itdesc
610cDC**                 eval      #tossbitpdsc = $itpdsc
610cDC**                 eval      #tossbitwhdp = $itwhdp
610cDC**                 eval      #tossbitstyp = $itstyp
610cDC**                 eval      #tossbitdesg = $itdesg
610cDC**                 eval      #tossbitum1  = $itum1
610cDC**                 eval      #tossbitum2  = $itum2
610cDC**                 eval      #tossbitumq2 = $itumq2
610cDC**                 eval      #tossbitum3  = $itum3
610cDC**                 eval      #tossbitumq3 = $itumq3
610cDC**                 endif

500 A
500 A*  Initialize screen fields.
500 A
500 DC**                 movel     itdesc        w3itm1
500 DC**                 move      itdesc        w3itm2
500 DC**                 eval      w3itm3 = itpdsc
610fAC                   if        ivssta = 'Z'
610fAC                   eval      w3itm1 = 'ITEM NOT FOUND'
610fAC                   eval      w3itm2 = *blanks
610fAC                   eval      w3itm3 = *blanks
610fAC                   else
500 MC                   movel     #toitdesc     w3itm1
500 MC                   move      #toitdesc     w3itm2
500 MC                   eval      w3itm3 = #toitpdsc
CDIaAC                   if        Client = cdi
CDIaAC                   eval      w3itm3 = #toitvit#
CDIaAC                   endif
500 DC**                 endif
610fAC                   endif
500 A
610cA*  Initialize license field
610cA
610cAC                   if        trackLevel = tLow
610cAC                   eval      w3lcns = 'n/a - Low'
610cAC                   else
610cAC                   eval      w3lcns = $saToLcns
610cAC                   endif
610cA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     *   Get Unit of measure fields
     C                   eval      w4um1 = *blanks
     C                   eval      w4um2 = *blanks
     C                   eval      w4um3 = *blanks
     C                   exsr      zzuom
     *
     *   Initialize entry fields
     *
SGCaAC                   if        Client = SGC
SGCaAC                             or client = glazier
EIa AC                             or client = EI
SGCaAC                   eval      w4qt01 = $slstk1
SGCaAC                   eval      w4qt02 = $slstk2
SGCaAC                   eval      w4qt03 = $slstk3
SGCaAC                   else
     C                   eval      w4qt01 = 0
     C                   eval      w4qt02 = 0
     C                   eval      w4qt03 = 0
SGCaAC                   endif
510c C*                  eval      w4upcd = *blanks
720bA /free
730aD   //if opdqty = 'Y';
730aM   if opcdqt = 'Y';
720bA     w4stk1 = %trim(%editc($slstk1:'L'));
720bA     w4stk2 = %trim(%editc($slstk2:'L'));
720bA     w4stk3 = %trim(%editc($slstk3:'L'));
720bA   endif;
720bA /end-free
    D*R                   Z-ADD0         W4QTY1
    D*R                   Z-ADD0         W4QTY2
    D*R                   Z-ADD0         W4QTY3
    D*R                   Z-ADD0         W1CWTR
     *
411 D*R         ITCWGT    IFNE 'Y'
     *R                   MOVE *ON       *IN95
     *R                   ELSE
     *R                   MOVE *OFF      *IN95
     *R                   ENDIF
     *
     C                   endsr
500b *----------------------------------------------------------------
     *
500bA*  ZZFIL5   Fill screen 5 fields with info from file.
     *
500bAC     zzfil5        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w5cwgt = 0
     *
500bAC                   endsr
520b *----------------------------------------------------------------
520b *
520b *  ZZFIL6   Fill screen 6 fields with info from file.
520b *
520b C     zzfil6        begsr
520b *
520b *   Initialize entry fields
520b *
520b C                   eval      w6lcn = *blanks
520b C                   eval      w6uci = *blanks
520b C                   eval      w6upcd = *blanks
520b *
520b C                   endsr

610cA*----------------------------------------------------------------
610cA*  zzgetitem   Get item info
610cA*----------------------------------------------------------------
610cA
610cAC     zzgetitem     begsr

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      $itdesc = 'ITEM NOT FOUND'
     C                   eval      $imltrk = 'L'
     C                   endif

     C                   eval      #toititem = $ititem
     C                   eval      #toittype = $ittype
     C                   eval      #toitdesc = $itdesc
     C                   eval      #toitpdsc = $itpdsc
     C                   eval      #toitwhdp = $itwhdp
     C                   eval      #toitstyp = $itstyp
     C                   eval      #toitdesg = $itdesg
     C                   eval      #toitum1  = $itum1
     C                   eval      #toitflg1 = $itflg1
     C                   eval      #toitum2  = $itum2
     C                   eval      #toitumq2 = $itumq2
     C                   eval      #toitflg2 = $itflg2
     C                   eval      #toitum3  = $itum3
     C                   eval      #toitumq3 = $itumq3
     C                   eval      #toitnrpk = $imnrpk
     C                   eval      #toitflgd = $itflgd
     C                   eval      #toitcube = $itcube
     C                   eval      #toitswgt = $itswgt
     C                   eval      #toitcwgt = $itcwgt
     C                   eval      #toitmitem = $itmitem
CDIaAC                   eval      #toitvit# = $itvit#

     C                   if        $slpick = 'Y'
     C                             or ($imltrk <> tlow
     C                                 and $imltrk <> tmedium
720bDC*                                and $imltrk <> thigh)
720bMC                                 and $imltrk <> thigh
720bAC                                 and $imltrk <> tUCI)
     C                   eval      trackLevel = tLow
     C                   else
     C                   eval      trackLevel = $imltrk
     C                   endif

     *  Use DRI interface to get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      ssbflg  = *off
     C                   eval      #tossbititem = ' '
     C                   eval      #tossbittype = ' '
     C                   eval      #tossbitdesc = ' '
     C                   eval      #tossbitpdsc = ' '
     C                   eval      #tossbitwhdp = ' '
     C                   eval      #tossbitstyp = ' '
     C                   eval      #tossbitdesg = ' '
     C                   eval      #tossbitum1  = ' '
     C                   eval      #tossbitum2  = ' '
     C                   eval      #tossbitumq2 = 0
     C                   eval      #tossbitum3  = ' '
     C                   eval      #tossbitumq3 = 0
CDIaAC                   eval      #tossbitvit# = ' '
     C                   else
     C                   eval      ssbflg  = *on
     C                   eval      #tossbititem = $ititem
     C                   eval      #tossbittype = $ittype
     C                   eval      #tossbitdesc = $itdesc
     C                   eval      #tossbitpdsc = $itpdsc
     C                   eval      #tossbitwhdp = $itwhdp
     C                   eval      #tossbitstyp = $itstyp
     C                   eval      #tossbitdesg = $itdesg
     C                   eval      #tossbitum1  = $itum1
     C                   eval      #tossbitum2  = $itum2
     C                   eval      #tossbitumq2 = $itumq2
     C                   eval      #tossbitum3  = $itum3
     C                   eval      #tossbitumq3 = $itumq3
CDIaAC                   eval      #tossbitvit# = $itvit#
     C                   endif

     C                   endsr
610cA
610cA*----------------------------------------------------------------
610cA*  ZZGETSLOT   Get next slot
610cA*----------------------------------------------------------------
610cA
610cAC     zzGetSlot     begsr
     C                   eval      nomore = *on

     *  Save the first slot that was entered.

     C                   if        firstSlotEnt = ' '
     C                   eval      firstSlotEnt = w2disp
     C                   endif

     *  Multiple pass loop (pass is initialized in zzfil2)

     *    Pass 1 - Low tracked items or empty base slot.
     *    Pass 2 - Medium/High tracked items with non-'*' license.
     *    Pass 2 - Medium/High tracked items with '*' license.

     C                   dou       pass > 3

     *    First, check the first slot that was entered.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w2whdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = firstSlotEnt
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn <> '*OK'
     C                   leavesr
     C                   endif

     C                   exsr      zzGetSlotChk
     C                   if        useSlot
     C                   eval      nomore = *off
     C                   leavesr
     C                   endif

     *    If first slot entered is not a base slot, then grab it and leave.

     C                   if        w2disp = firstSlotEnt
     C                             and w2disp <> baseDisp
     C                   eval      nomore = *off
     C                   leavesr
     C                   endif

     *    Otherwise, loop through the rest of the slots.

     *      Note, we do not clear the slot fields because we
     *      want to start with the one read above.


     C                   dow       forever = forever

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   if        $drireturn <> '*OK'
     C                             or $sacdsp <> baseDisp
     C                   eval      pass += 1
     C                   leave
     C                   endif

     C                   exsr      zzGetSlotChk
     C                   if        useSlot
     C                   eval      nomore = *off
     C                   leavesr
     C                   endif

     C                   enddo

     C                   enddo

     C                   endsr
610cA
610cA*----------------------------------------------------------------
610cA*  ZZGETSLOTCHK   Check if we can use slot
610cA*----------------------------------------------------------------
610cA
610cAC     zzGetSlotChk  begsr
     C                   eval      useSlot = *off

     *  See if slot has already been touched this round.
     *  If it has, leave.

     C                   eval      temp2A = $slhand

     C                   if        %subst(temp2A:1:1) = ' '
     C                   eval      %subst(temp2A:1:1) = '.'
     C                   endif

     C                   if        %subst(temp2A:2:1) = ' '
     C                   eval      %subst(temp2A:2:1) = '.'
     C                   endif

     C                   eval      touched = %scan('.'+temp2a: touchedList)
     C                   if        touched > 0
     C                   leavesr
     C                   endif

     *  Get item information.

     C                   exsr      zzgetitem

     *  If Pass 1 and slot is first entered slot and not a base slot,
     *    Then use slot.

     C                   if        pass = 1
     C                             and $sldisp = firstSlotEnt
     C                             and $sldisp <> baseDisp
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 1 and empty base slot,
     *    Then use slot.

     C                   if        pass = 1
     C                             and $sldisp = baseDisp
     C                             and $slavl1 = 0
     C                             and $slavl2 = 0
     C                             and $slavl3 = 0
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 1 and Low tracking item,
     *    Then use slot.

     C                   if        pass = 1
     C                             and trackLevel = tLow
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 2 and Medium/High tracking item and non-'*' license,
     *    Then use slot.
720bA*  Treat tUCI just like high tracking item and non-'*' license,

     C                   if        pass = 2
     C                             and (trackLevel = tMedium
720bAC                                  or trackLevel = tUCI
     C                                  or trackLevel = tHigh)
     C                             and %subst($saToLcns:1:1) <> '*'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 3 and Medium/High tracking item and '*' license,
     *    Then use slot.
720bA*  Treat tUCI just like high tracking item and non-'*' license,

     C                   if        pass = 3
     C                             and (trackLevel = tMedium
720bAC                                  or trackLevel = tUCI
     C                                  or trackLevel = tHigh)
     C                             and %subst($saToLcns:1:1) = '*'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
500b *     INVSCW file -
500b C     cwkey         klist
500b C                   kfld                    w1whse
500b C                   kfld                    ivswhd
500b C                   kfld                    ivsdsp
500b C                   kfld                    ivsitm
500b *     ITEMMSC file -
     *
500b C     imkey         klist
500b C                   kfld                    w1whse
500b C                   kfld                    w3item
520bA*  Define key for LABEL90 file
520bA*
520bAC     lbkey         klist
520bAC                   kfld                    w1whse
520bAC                   kfld                    litrn#
     *
520bA*  Define key for License file
520bA*
520bAC     likey         klist
520bAC                   kfld                    w1whse
520bAC                   kfld                    kylic
     *
500b *     OPTIONS file
500b C     opkeys        klist
500b C                   kfld                    wkwhse
500b C                   kfld                    wkcode
     *
     *
     *  Define key for INVSLOT4 file.
     *
     C     slkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w2whdp
     C                   kfld                    w2disp
414 A*
414 A*  Define key for VSLOT2 file.
414 A*
414 AC     pskey         klist
414 AC                   kfld                    w1whse
414 AC                   kfld                    pwhdp
414 AC                   kfld                    pdisp
415 A*
520bA*  Define key for UCI file.
520bA*
520bAC     keyuci        klist
520bAC                   kfld                    w1whse
512bAC                   kfld                    kyuci
510cA*  Define key for UPC file.
510cA*
510cAC     upckey        klist
510cAC                   kfld                    w1whse
510cAC                   kfld                    kyupc
     *
     *  Define partial key for INVTEAM file.
     *
     C     vtkey         klist
     C                   kfld                    w1whse
     C                   kfld                    woidte
     C                   kfld                    w1team
     *
     *  Define key for PIRITEM file.
     *
500 DC**   keyit         klist
500 DC**                 kfld                    w1whse
500 DC**                 kfld                    ivsitm
     *
     *  Define key for INVPAGE file.
     *
     C     keypg         klist
     C                   kfld                    w1whse
     C                   kfld                    ivspag
500a *
500a *  Define key for INVSLTPOS file.
500a *
500a C     keysp         klist
500a C                   kfld                    ivswhs
500a C                   kfld                    ivswhd
500a C                   kfld                    ivsasl
500a C                   kfld                    ivsloc
500a C                   kfld                    ivslvl
500a C                   kfld                    ivshnd
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500eA*
500eA*   Get employee options.
500eA*
JORaA*  Set language to english until Jordano's is updated to V5.0
JORaAC                   eval      e$lng = 'EN'
500eAC                   call      'GETUSER'
500eAC                   parm      #user         e$code           10
500eAC                   parm                    e$whse            3 0
500eAC                   parm                    e$emp#            5 0
500eAC                   parm                    e$fnam           15
500eAC                   parm                    e$init            1
500eAC                   parm                    e$lnam           20
500eAC                   parm                    e$whdp            5
500eAC                   parm                    e$styp            1
500eAC                   parm                    e$shft            6
500eAC                   parm                    e$crew            6
500eAC                   parm                    e$nhrs            3 1
500eAC                   parm                    e$rtn             8
JORaDC**                 parm                    e$bpu             1
JORaDC**                 parm                    e$lng             2
500eAC                   if        e$rtn <> '*OK'
500eAC                   eval      e$lng = 'EN'
500eAC                   endif
500eA*
416bAC                   eval      worow = *zeros
416bAC                   eval      wocol = *zeros
500b *   Get options
500b C                   exsr      zzoptn
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZOPTN   Get options
     *
500b C     zzoptn        begsr
510e *   Get Inv count options.
510e C                   eval      wkcode = '*COUNT  '
510e C                   eval      wkwhse = e$whse
510e *
510e C     opkeys        chain     options                            79
510e C                   if        *in79
510e C                   eval      opcupc = 'N'
510e C                   eval      opcadd = 'N'
510e C                   eval      opccwt = 'N'
510e C                   else
510e C                   move      opdata        opdat1
510e C                   endif
     C*
700aA*   Get Item Maint Options
700aA /free
700aA    getimuom(e$whse: BegKilolbs: IMUom);
700aA    select;
700aA      when Begkilolbs = 'K';
700aA        KiloLbs = 'K';
700aA        eval *In31 = *off;
700aA        W5UM1  = IMUom;
700aA      other;
700aA        kiloLbs = 'P';
700aA        eval *In31 = *on;
700aA        W5UM1  = 'Lbs';
700aA    endsl;
700aA /end-free
     *
500b *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
     C                   endsr
610cA
610cA*----------------------------------------------------------------
610cA*  ZZTOUCH        Mark slot as touched
610cA*----------------------------------------------------------------
610cA
610cAC     zzTouch       begsr

     C                   eval      temp2A = $slhand

     C                   if        %subst(temp2A:1:1) = ' '
     C                   eval      %subst(temp2A:1:1) = '.'
     C                   endif

     C                   if        %subst(temp2A:2:1) = ' '
     C                   eval      %subst(temp2A:2:1) = '.'
     C                   endif

     C                   eval      touchedList = %trim(touchedList)
     C                                         + '.' + temp2A

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
510gAC                   eval      *in92 = *off
510gAC                   eval      *in93 = *off
     *
500 DC**                 eval      $gexst = 'N'
500 DC**   keyit         chain     piritem                            75
500 DC**                 if        *in75
500 MC                   if        #toititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
500 DC**                 call      'CHKSSB'
500 DC**                 parm      itwhse        $gwhse            3 0
500 DC**                 parm      ititem        $gitem           15
500 DC**                 parm                    $gexst            1
500 DC**                 if        $gexst = 'N'  and
500 DC**                           itflg1 = 'N'
500 MC                   if        ssbflg = *off and
500 MC                             #toitflg1 = 'N'
414bD*R         ITFLG1    IFEQ 'N'
     C                   eval      *in92 = *on
     C                   endif
500 DC**                 if        $gexst = 'N'  and
500 DC**                           itflg2 = 'N'
500 MC                   if        ssbflg = *off and
500 MC                             #toitflg2 = 'N'
414bD*R         ITFLG2    IFEQ 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
500 MC                   if        #toitum2 = *blanks
414bMC                   eval      *in92 = *on
414bMC                   endif
500 MC                   if        #toitum3 = *blanks
414bMC                   eval      *in93 = *on
414bMC                   endif
     *
500 MC     #toitum1      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w4um1 = umshrt
     C                   else
     C                   eval      w4um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
500 MC     #toitum2      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w4um2 = umshrt
     C                   else
     C                   eval      w4um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
500 MC     #toitum2      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w4um3 = umshrt
     C                   else
     C                   eval      w4um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
417c *----------------------------------------------------------------
417c *
417c *  ZZUPCK   Create Inventory Check record
417c *
417c C     zzupck        begsr
417c C                   eval      ivcwhs = ivswhs
417c C                   eval      ivcdsp = ivsdsp
417c C                   eval      ivcsta = *on
417c C                   eval      ivcwhd = ivswhd
417c C                   eval      ivcasl = ivsasl
417c C                   eval      ivcloc = ivsloc
417c C                   eval      ivclvl = ivslvl
417c C                   eval      ivchnd = ivshnd
417c C                   eval      ivcstp = ivsstp
417c C                   eval      $cvcmd = '*CURCMD '
417c C                   call      @cvtdt
417c C                   parm                    $cvtdt
417c C                   eval      ivcsdt = $cvd8o
417c C                   time                    ivcstm
417c C                   eval      ivceby = ivttem
417c C                   eval      ivcedt = $cvd8o
417c C                   movel     '*PNDQTY'     ivcrsn
417c C                   write     ivcrec                               79
417c C                   if        *in79
417c C                   eval      error = *on
417c C                   exsr      zm71
417c C                   goto      endckc
417c C                   endif
417c C     endckc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to parameter fields.
     *
     C                   eval      $pwhse = w1whse
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Convert date and save.
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      woidte = $cvd8o
     *
     *
     *  LINES FROM IT290  CHECK IF WE NEED.
     *R         DONE      IFEQ *ON
     *R                   MOVE *ON       DONE    1
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN21
     *R                   MOVE *ON       *IN22
     *R                   MOVE *ON       *IN01
     *R                   MOVE *BLANKS   ERRMSG
     *R                   EXSR ZM2906
     *R                   GOTO ENDUP1
     *R                   ENDIF
720bAc                   eval      $pwhse = w1whse
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      *in20 = *on
     C                   eval      ovrrid = *off
     C                   eval      error = *off
610cA
610cAC                   if        firstSlotEnt = ' '
610cAC                   exsr      zzGetSlot
610cAC                   if        nomore
610cAC                   eval      initSC2 = *on
610cAC                   endif
610cAC                   endif
610cA
610cAC                   if        initSC2 = *off
610cAC                   eval      w2disp = $sldisp
610eAC     slkey         chain     invslot4                           79
610eAC                   if        *in79
610eAC                   eval      error = *on
610eAC                   eval      *in23 = *on
610eAC                   eval      *in03 = *on
610eAC                   eval      errmsg = *blanks
610eAC     '"'           cat       w2disp        errmsg
610eAC     errmsg        cat       '"':0         errmsg
610eAC                   exsr      zm3002
610eAC                   leavesr
610eAC                   endif
     C                   eval      refrsh = *on
     C                   exsr      scr03i
610cAC                   endif
610cA
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
610cDC**
610cDC**   Call license tracking - Before
610cDC**
610cDC**                 if        $saToLcns <> '*NONE'
610cDC**
610cDC**                 exsr      zzzclr$lt210
610cDC**                 eval      $tcmd     = '*INVCNTB'
610cDC**                 eval      $twhse    = w1whse
610cDC**                 eval      $twhdp    = $slwhdp
610cDC**                 eval      $tslot    = $sldisp
610cDC**                 eval      $titem    = $slitem
610cDC**                 eval      $titemdsc = #toithead
610cDC**                 eval      $tlic#    = $saToLcns
610cDC**                 exsr      zzzcall$lt210
610cDC**
610cDC**                 select
610cDC**                 when      $treturn = '*OK'
610cDC**
610cDC**                 when      $treturn = '*CANCEL'
610cDC**                           or $treturn = '*SKIP'
610cDC**                 eval      cancel = *on
610cDC**                 leavesr
610cDC**
610cDC**                 when      $treturn = '*NOTFND'
610cDC**                 eval      cancel = *on
610cDC**                 leavesr
610cDC**
610cDC**                 other
610cDC**                 eval      error = *on
610cDC**                 eval      errmsg = $terrmsg
610cDC**                 exsr      zm0105
610cDC**                 leavesr
610cDC**
610cDC**                 endsl
610cDC**
610cDC**                 endif
610aA
     C                   eval      refrsh = *on
520bAC                   eval      woupc = *blanks
520bAC*                  if        Client = packers
520bAC                   eval      *in94 = *on
520bAC                   if        opcupc = 'Y'
     C                   exsr      scr06i
520b C                   else
520b C*                  eval      *in94 = *off
     C                   exsr      scr04i
520b C                   endif
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      scode = '  '
610aDC**
610aDC**   Call license tracking - Before
610aDC**
610aDC**                 exsr      zzzclr$lt210
610aDC**                 eval      $tcmd     = '*INVCNTB'
610aDC**                 eval      $twhse    = w1whse
610aDC**                 eval      $twhdp    = $slwhdp
610aDC**                 eval      $tslot    = $sldisp
610aDC**                 eval      $titem    = $slitem
610aDC**                 eval      $titemdsc = #toithead
610aDC**                 eval      $tqty1    = w4qt01
610aDC**                 eval      $tqty2    = w4qt02
610aDC**                 eval      $tqty3    = w4qt03
610aDC**                 eval      $tlic#    = $saToLcns
610aDC**                 exsr      zzzcall$lt210
610aDC**
610aDC**                 if        $treturn <> '*OK'
610aDC**                 eval      error = *on
610aDC**                 eval      errmsg = $terrmsg
610aDC**                 exsr      zm0105
610aDC**                 goto      endup4
610aDC**                 endif
610cA
610cA*    Marked slot as touched for this round.
610cA
610cAC                   exsr      zzTouch
500 A
500 A*    Update inventory files.
500 A
     C                   eval      woqt01 = w4qt01
     C                   eval      woqt02 = w4qt02
     C                   eval      woqt03 = w4qt03
     C                   exsr      zzupdi
     C     keypg         chain     invpage                            75
     C                   if        not *in75
     C                   exsr      zzupdp
500 AC                   exsr      zzupdsp
     C                   endif
720bA*
720bA*  UCI Tracking
720bAC                   time                    $ppartime
720bA /free
720bA   if trackLevel = tUCI
720bA      and (w4qt01 <> $slstk1
720bA      or w4qt02 <> $slstk2
720bA      or w4qt03 <> $slstk3);
720bA     exsr scr07i;
720bA   else;
720bA /end-free
500bA*
510eA*  Capture CW if catch weight item if option = Y and
510eA*  item is cw item.
510eAC                   if        opccwt = 'Y' and
510eMC                             #toitcwgt = 'Y' and
PAKaAC                             Client <> packers
510eDC*                            #toitcwgt <> 'Y' or
510eAC                   exsr      scr05i
510eAC                   else
PAKaAC**                           Client = packers
     C                   eval      woqt01 = 0
     C                   eval      woqt02 = 0
     C                   eval      woqt03 = 0
     C                   exsr      scr02i
500bAC*                  else
500bAC*                  exsr      scr05i
500bAC                   endif
720bA /free
720bA   endif;
720bA /end-free
500bA*
     C     endup4        endsr
500bA*----------------------------------------------------------------
500b *
500bA*  ZZUPD5   Update for screen 5.
500b *
500bAC     zzupd5        begsr
     C                   exsr      zzupdcw
     C                   eval      error = *off
     C                   eval      ovrrid = *off
     C                   eval      wtchk = *off
     C                   eval      refrsh = *on
     C                   eval      scode = '  '
     C                   eval      woqt01 = 0
     C                   eval      woqt02 = 0
     C                   eval      woqt03 = 0
     C                   exsr      scr02i
500bA
500bAC     endup5        endsr
     *----------------------------------------------------------------
520b *
520b *  ZZUPD6   Update for screen 6.
520b *
520b C     zzupd6        begsr
520b C                   eval      error = *off
520b C                   eval      refrsh = *on
520b C                   exsr      scr04i
520b C     endup6        endsr
720bA*----------------------------------------------------------------
720bA*
720bA*  ZZUPD7   Update for screen 7.
720bA*
720bAC     zzupd7        begsr
720bAC                   move      *off          error
720bAC                   move      *on           refrsh

720bA /free
720bA       // are we updating an existing uci

720bA       if $uiaction = 'ADJUPD';
720bA         $uiWhse = $pwhse;
720bA         $uiuci  = w7uci;
720bA         $uiapartlts = $ppartime;

720bA         // Lets add some more stuff for tracking
720bA         //$uiolcns = $plic#;
720bA         //$uioseq = $uiseq;
720bA         $uiscan = 'Y';
720bA         $dricommand = '*UCIINFO';
720bA         $drisubcmd  = '%UPDPARTL';
720bA         $drisys2upd = 'D';
720bA         exsr zzzdricop;
720bA         // if return is *OK we updated the uci record
720bA         if $drireturn <> '*OK';
720bA           error = *on;
720bA           *in21 = *on;
720bA           *in01 = *on;
720bA           errmsg = 'problem updating uci';
720bA           exsr zm0105;
720bA           leavesr;
720bA         endif;
720bA         select;
720bA           when $uiautyp = 'N';
720bA             uciqty1 = uciqty1 + 1;
720bA           when $uiautyp = '1';
720bA             uciqty2 = uciqty2 + 1;
720bA           when $uiautyp = '2';
720bA             uciqty3 = uciqty3 + 1;
720bA         endsl;
720bA         if $uiwgtlbs > 0;
720bA           uciwgttot = uciwgttot + $uiwgtlbs;
720bA         endif;
720bA         if $uiwgtkgs > 0;
720bA           uciwgttot = uciwgttot + $uiwgtkgs;
720bA         endif;
720bA       endif;

720bA       // are we adding a new uci
720bA       if $uiaction = 'ADJADD';
720bA         $uiWhse = $pwhse;
720bA         $uiuci  = w7uci;
720bA         $uiapartlts = $ppartime;
720bA         // load up any additional information extracted from barcode
720bA         if $bcgtinsent;
720bA           $uiagtin = %dec($bcgtin:14:0);
720bA         endif;
720bA         if $bclotsent;
720bA           $uialot = $bclot;
720bA         endif;
720bA         if $bcSer#Sent;
720bA           $uiserial = $bcSer#;
720bA         endif;
720bA         if $bcPNtLbSent;
720bA           $uiWgtlbs = $bcPNtLb;
720bA         endif;
720bA         if $bcPNtKgSent;
720bA           $uiWgtKgs = $bcPNtKg;
720bA         endif;

720bA         // Lets add some more stuff for tracking
720bA         $uiaolcns = '*BFCADJADD';
720bA         $uialcns = '*BFCADJADD';
720bA         $uilcns = '*BFCADJADD';
720bA         $uiaentd = today;
720bA         //$uioseq = $uiseq;
720bA         $uiscan = 'Y';
720bA         // load some exception data since we don't know how
720bA         // this uci got in the warehouse
720bA         $uiexccode = 'UNKNWORG';
720bA         $uiexcstat = '1';
720bA         $dricommand = '*UCIINFO';
720bA         //$drisubcmd  = '%UPDPARTL';
720bA         $drisubcmd  = '%ADD';
720bA         $drisys2upd = 'D';
720bA         exsr zzzdricop;
720bA         // if return is *OK we updated the uci record
720bA         if $drireturn <> '*OK';
720bA           error = *on;
720bA           *in21 = *on;
720bA           *in01 = *on;
720bA           errmsg = 'problem updating uci';
720bA           exsr zm0105;
720bA           leavesr;
720bA         endif;
720bA         select;
720bA           when $uiautyp = 'N';
720bA             uciqty1 = uciqty1 + 1;
720bA           when $uiautyp = '1';
720bA             uciqty2 = uciqty2 + 1;
720bA           when $uiautyp = '2';
720bA             uciqty3 = uciqty3 + 1;
720bA         endsl;
720bA         if $uiwgtlbs > 0;
720bA           uciwgttot = uciwgttot + $uiwgtlbs;
720bA         endif;
720bA         if $uiwgtkgs > 0;
720bA           uciwgttot = uciwgttot + $uiwgtkgs;
720bA         endif;
720bA
720bA       endif;
720bA   w7uci = ' ';
720bA /end-free
720bAC     endup7        endsr
500bA*----------------------------------------------------------------
500bA*
500bA*  ZZUPDCW  Update INVSCW
500bA*
500bAC     zzupdcw       begsr

500b C     cwkey         chain     invscw                             75
     C                   if        not *in75
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivwedt = $cvd8o
     C                   time                    ivwetm
     C                   eval      ivweby = ivttem
     C                   eval      ivwwgt = taddw
     C                   eval      ivwlrg = lwrng
     C                   eval      ivwhrg = hirng
     C                   eval      ivwwtx = ovrrid
     C                   update    ivwrec
     C                   else
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivwedt = $cvd8o
     C                   time                    ivwetm
     C                   eval      ivweby = ivttem
     C                   eval      ivwwhs = ivswhs
     C                   eval      ivwdsp = ivsdsp
     C                   eval      ivwwhd = ivswhd
     C                   eval      ivwasl = ivsasl
     C                   eval      ivwloc = ivsloc
     C                   eval      ivwlvl = ivslvl
     C                   eval      ivwhnd = ivshnd
     C                   eval      ivwstp = ivsstp
     C                   eval      ivwitm = ivsitm
     C                   eval      ivwsid = ivssid
     C                   eval      ivwwgt = taddw
     C                   eval      ivwlrg = lwrng
     C                   eval      ivwhrg = hirng
     C                   eval      ivwwtx = ovrrid

     C                   write     ivwrec
     C                   endif
     C                   if        %error
     C                   goto      endupdcw
     C                   endif

500b C     endupdcw      endsr

     *----------------------------------------------------------------
     *
     *  ZZUPDI   Update INVSLOT with entered date & time
     *
     C     zzupdi        begsr
     C                   if        scode <> *blanks
     C                   eval      ivssta = scode
     C                   endif
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivsedt = $cvd8o
     C                   time                    ivsetm
     C                   eval      ivseby = ivttem
     C                   eval      ivsqt1 = woqt01
     C                   eval      ivsqt2 = woqt02
     C                   eval      ivsqt3 = woqt03
     C                   update    ivsrec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupi
     C                   endif
     C     endupi        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPDP   Update INVPAGE with entered date & time
     *
     C     zzupdp        begsr
     C                   eval      ivpsta = 'E'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivpedt = $cvd8o
     C                   time                    ivpetm
     C                   eval      ivpeby = ivttem
     C                   update    ivprec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupp
     C                   endif
     C     endupp        endsr
     *
417c *----------------------------------------------------------------
417c *
417c *  ZZUPPG   Update INVPAGE with new first or last record.
417c *
417c C     zzuppg        begsr
417c *
417c C                   eval      nsctr = 0
417c C                   if        ivpfrm = w2disp
417c C     keypg         setll     invslot1
417c C     nsctr         do        2
417c C     keypg         reade     invslot1                               77
417c C                   if        not *in77
417c C                   if        ivsdsp = w2disp
417c C                   iter
417c C                   endif
417c C                   endif
417c C                   enddo
417c C                   endif
417c *R
417c C                   if        ivpto = w2disp
417c C     keypg         setgt     invslot1
417c C     nsctr         do        2
417c C     keypg         readpe    invslot1                               77
417c C                   if        not *in77
417c C                   if        ivsdsp = w2disp
417c C                   iter
417c C                   endif
417c C                   endif
417c C                   enddo
417c C                   endif
417c *R
417c C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZUPDSP  Update INVSLTPOS.
500 A*
500 AC     zzupdsp       begsr

500a C     keysp         chain     invspos                            75
500a C                   if        not *in75
500a C                   eval      ivopos = $tslotpos
500a C                   update    ivorec
500a C                   else
     C                   eval      ivowhs = ivswhs
     C                   eval      ivodsp = ivsdsp
     C                   eval      ivowhd = ivswhd
     C                   eval      ivoasl = ivsasl
     C                   eval      ivoloc = ivsloc
     C                   eval      ivolvl = ivslvl
     C                   eval      ivohnd = ivshnd
     C                   eval      ivopos = $tslotpos

     C                   write     ivorec
500a C                   endif
     C                   if        %error
     C                   goto      endupdsp
     C                   endif

     C     endupdsp      endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
610aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
610aAC                   eval      $saemp#U = *on
610aAC                   eval      $saemp# = e$emp#
     C                   endsr
500 A
720bA*----------------------------------------------------------------
720bA*  clr$license  Clear $license data structure fields
720bA*----------------------------------------------------------------
720bA
720bAC     clr$license   begsr
720bAC                   eval      savever# = $liver#
720bAC                   clear                   $license
720bAC                   eval      $liver# = savever#
720bAC                   eval      $liemp# = 0
720bAC                   eval      $liuser = #curruser
720bAC                   eval      $lipgm  = #pgm
720bAC                   eval      $lijob  = #job
720bAC                   eval      $lijobn = #jobnbr
720bAC                   eval      $liTowhse = $pwhse
720bAC                   eval      $liTowhseu = *on
720bAC                   endsr
720bA
720bA*----------------------------------------------------------------
720bA*  clr$uciinfo  Clear $uciinfo data structure fields
720bA*----------------------------------------------------------------

720bAC     clr$uciinfo   begsr
720bAC                   eval      savever# = $uiver#
720bAC                   clear                   $uciinfo
720bAC                   clear                   $uciinfo2
720bAC                   eval      $uiver# = savever#
720bAC                   eval      $uiaddemp = e$emp#
720bAC                   eval      $uiaddusr = #user
720bAC                   eval      $uiaddpgm  = #prog
720bAC                   eval      $uiaddjob  = #job
720bAC                   eval      $uiaddnbr = #jobn
720bAC                   endsr

500 A*----------------------------------------------------------------
500 A*  zzzdriclose   Close any open files or programs.
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdriclose   begsr

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

     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
610aAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
720bAC                   when      $dricommand = '*UCIINFO'
720bAC                   eval      $dridata = $uciinfo
720bAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
610aAC                             or $dricommand = '*SLOT'
720bAC                             or $dricommand = '*UCIINFO'
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
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
610dAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
720bAC                   when      $dricommand = '*UCIINFO'
720bAC                   eval      $uciinfo = $dridata
720bAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500 A*----------------------------------------------------------------
700aA*
700aA*  ZZCNVWGT  Setup converted weight field.
700aA*
700aAC     zzcnvwgt      begsr
700aA*
700aA*
700aA* If item options is setup as kgs and user enters kgs no conversion
700aA* If item options is setup as kgs and user enters lbs need conversion
700aA* If item options is setup as lbs and user enters lbs no conversion
700aA* If item options is setup as lbs and user enters kgs need conversion
700aA /free
700aA   select;
700aA     when Begkilolbs = 'K';
700aA       if KiloLbs = 'K';
700aA         eval cnvwgt = w5cwgt;
700aa       else;
700aA         eval(h) cnvwgt = w5cwgt / kgs2lbs;
700aA       endif;
700aA     other;
700aM       if KiloLbs = 'K';
700aM         eval(h) cnvwgt = w5cwgt * kgs2lbs;
700aM       else;
700aM         eval cnvwgt = w5cwgt;
700aM       endif;
700aA   endsl;
700aA /end-free

700aAC                   endsr
500 A*----------------------------------------------------------------
500 A*  License Plate Tracking Routines
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  ZZZCLR$LT210  -  Clear LT210 parameters.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCLR$LT210  begsr

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
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZZCALL$LT210  -  Call LT210 program.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCALL$LT210 begsr

     C                   eval      $thead = 'Inv Count'

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'INV'         $ttype
     C                   parm                    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      0             $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm      '*STUPID'     $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

5xx AC                   if        %error
5xx AC                   eval      $treturn = $treturn
5xx  C                   endif
     C                   endsr

417c *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Warehouse
Date
Team
Slot
Dept.
Weight
UPC
UPC not for item
** DESCSP
Almacen
Fecha
Equipo
Slot
Dept.
Weight
UPC
UPC no es para prdc.
