500 A /copy *libl/qcopysrc,hspecs
500eA*----------------------------------------------------------------
500eA*  Multilingual Verision
500eA*  Every screen and message has a corresponding Spanish version.
500eA*  Any changes must be made to both languages.
500eA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd.  #8-51
     *   West Chicago, IL. 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IV333   Rf inventory entry - Virtual slot
     *  21 November, 2006
     *  Roxanne Harrison
     *
     *  ****************************************************************
     *  Notes:  Temporary version for Halsey
     *  ****************************************************************
     *  Revisions
     *
     *    11/21/06  RH   5.10
     *      - Created using IV213
     *      - Must scan UPC code or license for item
510b *    12/19/06  RH   5.10b
     *      - ENH:Added *COUNT options to capture CW.
510c *    12/20/06  RH   5.10c
     *      - FIX: Move code to check if item exists in location.
510d *    05/23/07  RH   5.10d
     *      - ENH: Add screen 6 to key item if OPCKIN option = 'Y'
510e *    06/08/07  RH   5.10e
     *      - ENH: Error if add pick slot exceeds # of pick allowed.
510e *    06/19/07  RH   5.10r
     *      - ENH: Add new errorfor 5.10e change, displays pick slot.
520a *    05/05/08  RH   5.20a
     *      - ENH: Add item to verified zero or 0 qty slot if possible.
520b *    11/18/08  RH   5.20b
     *      - FIX: Do not check # of pick slots for PIR item.         .
520c *    11/20/08  RH   5.20c
     *      - FIX: Change to get base item for alias.
520d *    11/20/08  RH   5.20d
     *      - FIX: Change to use API for slot, was not allowing
     *        slot to be scanned without embedded '-'
     *
610aA*    09/14/09  DAS  6.10a
     *      - Revised zzchk2 to use drilicense to get license info.
     *      - Revised zzchk2 to not check if item is in slot.
     *      - Moved some code from SC2 into zzchk2 and zzupd2.
     *
610bA*    09/17/09  DAS  6.10b
     *      - Revised to use DRISLOT to create virtual slot.
     *      - Revised to call LT210 to get new license for
     *        Medium/High tracked items.
     *
610cA*    09/21/09  DAS  6.10c
     *      - Added screen 7 to display item info.
     *
610dA*    09/21/09  DAS  6.10d
     *      - Revised SC5 to ignore F3/F12. User must go forward.
530a *    11/02/09  RH   5.30a
     *      - Enh: Add Vendor item # field to add item. SCREEN6
640aA*    05/03/12  RH   6.40a
     *      - Fix: Initialize IVSPCK, field was not set for virtual
     *
     *----------------------------------------------------------------
JORaA*    06/07/07  RH    JORa
     *      - Fix:Change call to GETUSER for spanish until 5.00 update
     *        is in place.
     *----------------------------------------------------------------
ICBaA*    05/03/12  RH    ICBa
     *      - ENH:Only check # of pick slots if slots is empty.
     *        ICB has base pick slots with virtuals set as overflow.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  90        View moSe (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
HAL  F*iv333fm   cf   e             workstn
HAL  Fiv33301   cf   e             workstn
     F                                     infds(infds)
     Fslotdef   if   e           k disk
     Fslot2     uf a e           k disk
510e Fslot3     if a e           k disk
510e F                                     rename(slrec:slrec3)
     Finvexcp2  o  a e           k disk
     Finvpage2  uf a e           k disk
     Finvnxtp   uf   e           k disk
     Finvscw    uf a e           k disk
HAL  Finvsdate  uf a e           k disk
     Finvslot   uf a e           k disk
     *           IVSREC                            KRENAMERECORD
     Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
     Fvslot2    uf a e           k disk
520aDF*nvslot4  if   e           k disk
520aMFinvslot4  uf   e           k disk
     F                                     rename(ivsrec:ivsrec4)
     Finvspos   o  a e           k disk
     Fpiritem   if   e           k disk
530a Fpiritem4  if   e           k disk
530a F                                     rename(itrec:itrec4)
     Flabel7    if   e           k disk
     Flicense   if   e           k disk
     Funmesr    if   e           k disk
     Fupc       if   e           k disk
     *----------------------------------------------------------------
      *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     D*
      /COPY QCOPYSRC,ID#PACKERS
ICBaA /copy qcopysrc,id#icb
HAL   /copy qcopysrc,p.caldktex
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
     D desc            s             20    dim(7) ctdata perrcd(1)
     D descsp          s             20    dim(7) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
610aA /COPY *libl/qcopysrc,C#LICENSE
610bA /COPY *libl/qcopysrc,C#SLOT
500 AD saveVer#        s                   like($itver#)

610bA*----------------------------------------------------------------
610bA*  LT210 parameters
610bA*----------------------------------------------------------------

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

610bA*----------------------------------------------------------------
610bA*  Tracking variables
610bA*----------------------------------------------------------------
610bA
610bA /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
500  *  Variables
HAL  d perrmsg         s             99
HAL  d psessid         s             40
HAL  d pdpcombo        s             20
HAL  d calpwhse        s              3  0
HAL  d calpentdate     s              8  0
HAL  d calpdktexpd     s              8  0
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
HAL AD #toimmflg       s                   like($immflg)
500 AD #toitcube       s                   like($itcube)
500 AD #toitswgt       s                   like($itswgt)
500 AD #toitcwgt       s                   like($itcwgt)
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
     D $msgf           s             10
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
610bDC*#bitem          s                   like(ititem)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
610bAD cancel          s               n
     D chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
JORa D e$bpu           s              1
JORa D e$lng           s              2
     D enter           s              5  0
     D error           s               n
     D exwgt           s              9  2
     D exwg2           s              7  2
     D excode          s              1
     D exist           s              1
     D flaghs          s              1
     D forevr          s               n
     D forever         s               n
520cAD gtitem          s             15
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D i               s              2  0
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D j               s              2  0
     D k               s              3  0
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D kypage          s              5  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
510e D nbrpck          s              5  0
     D newvs           s              1
     D nxtscr          s              3
     D ovrrid          s              1
HAL  D skipdate        s              1
     D pexp            s              1
     D prg1c           s              4  3
     D prg2c           s              4  3
520dAD redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sadj            s                   like(ivsadj)
     D sclear          s              1
     D sheet           s                   like(ivppag)
     D ssbflg          s               n
     D svactv          s                   like(slactv)
     D svaisl          s                   like(slaisl)
     D svbld           s                   like(slbld)
     D svdesg          s                   like(sldesg)
     D svdisp          s                   like(sldisp)
     D svhand          s                   like(slhand)
     D svitem          s                   like(slitem)
     D svloc           s                   like(slloc)
610bAD svpick          s                   like(slpick)
     D svprty          s                   like(slprty)
     D svpseq          s                   like(slpseq)
     D svrlvl          s                   like(slrlvl)
     D svsdef          s                   like(slsdef)
     D svside          s                   like(slside)
     D svslfd          s                   like(slslfd)
     D svstat          s                   like(slstat)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
     D swgt2           s              7  2
     D today           s              8  0
610bAD trackLevel      s              1
     D upcctr          s              3  0
     D warn            s              1
     D wkcode          s              8
     D wkwhse          s                   like($pwhse)
     D womult          s              1
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
     D wsitem          s             15
     D wtchk           s              1
     D w2up20          s             20
     D zmsflag         s               n
     *----------------------------------------------------------------
     I*  *SYSTEM  -  System options.
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
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  optend               117    117
510eA*----------------------------------------------------------------
510eA*  *COUNT   -  Inventory count options.
510eA*----------------------------------------------------------------
510eA*
510eA* Fields
510eA*
510eA*    OPCUPC  -  Scan UPC to confirm item counted Y/N
510eA*    OPCADD  -  RF add item in slot Y/N
510iA*    OPCSCN  -  RF scan UPC or Lic to add item Y/N
510iA*    OPCKIN  -  RF key in item to add item Y/N
510eA*    OPCCWT  -  Caputure catch weight Y/N
510eA*
510eA* Data structure
510eA*
510eAD opdat1          ds
510eAD  opcupc                 1      1
510eAD  opcadd                 2      2
510iAD  opcscn                 3      3
510iAD  opckin                 4      4
510eAD  opccwt                 5      5
510eAD  op1end               117    117
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
     D  $pwhdp                22     26
     D  $pteam                27     36
510b D  $pcupc                37     37
510b D  $pcadd                38     38
510b D  $pccwt                39     39
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
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
     *
     D  $lwhdp                22     26
     D  $lupc                 22     41
     D  $litm1                42     56
     *
     *
     *
520dA*----------------------------------------------------------------
520dA*  API programs
520dA*
520dAD @apics          c                   const('APICVTSLT ')
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
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                 1     12
     D* erdisp                16     27
414cA*
414cAD  ernpck                 1      3p 0
414cAD  erapck                 4      6p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
610aA /Copy qcopysrc,c#pgminfds
610aDD**              sds
610aDD**#prog            *proc
610aDD**#pgm             *proc
610aDD**#job                 244    253
610aDD**#user                254    263
610aDD**#jobn                264    269
610aDD**#jobdt               276    281  0
610aDD**#jobtm               282    287  0
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
     C                   eval      *in92 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
610cAC     nxtscr        caseq     '07 '         sc7
HAL AC     nxtscr        caseq     '08 '         sc8
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn1sp                              50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn2sp                              50
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn3sp                              50
     C                   other
     C                   exfmt     screen3                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '04 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn4sp                              50
     C                   other
     C                   exfmt     screen4                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '05 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn5sp                              50
     C                   other
     C                   exfmt     screen5                              50
     C                   endsl
     C                   endif
     *
510d C                   if        nxtscr = '06 '
510d C                   select
510d C                   when      e$lng = 'SP'
510d C                   exfmt     scrn6sp                              50
510d C                   other
510d C                   exfmt     screen6                              50
510d C                   endsl
510d C                   endif
     *
610cAC                   if        nxtscr = '07 '
610cAC                   select
610cAC                   when      e$lng = 'SP'
610cAC                   exfmt     scrn7sp                              50
610cAC                   other
610cAC                   exfmt     screen7                              50
610cAC                   endsl
610cAC                   endif
HAL AC                   if        nxtscr = '08 '
HAL AC                   exfmt     screen8                              50
HAL AC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       14
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333440
     C                   setoff                                       414243
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
610bAC                   eval      cancel = *off
     C                   eval      cmdtkn = *off
520dAC                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
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
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget3
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget4
     C                   exsr      zzdft4
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget4
     C                   exsr      zzfil4
     C                   endif
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget5
     C                   exsr      zzdft5
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget5
     C                   exsr      zzfil5
     C                   endif
     C     end05i        endsr
     *----------------------------------------------------------------
510d *
510d *  Screen 06 initialization
510d *
510d C     scr06i        begsr
510d C                   eval      nxtscr = '06 '
510d *
510d *  Get field defaults if this is an add.
510d *
510d C                   if        $pcmd = '*ADD    '
510d C                   exsr      zzget6
510d C                   exsr      zzdft6
510d C                   else
510d *
510d *  Otherwise get existing record(s).
510d *
510d C                   eval      *in91 = *on
510d C                   exsr      zzget6
510d C                   exsr      zzfil6
510d C                   endif
510d C     end06i        endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  Screen 07 initialization
610cA*
610cAC     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   exsr      zzfil7
     C     end07i        endsr
HAL A*----------------------------------------------------------------
HAL A*
HAL A*  Screen 08 initialization
HAL A*
HAL AC     scr08i        begsr
HAL AC                   eval      nxtscr = '08 '
HAL AC                   exsr      zzfil8
HAL AC*****              eval      refrsh = *off
HAL AC     end08i        endsr
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
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
     C     error         cabeq     *on           endsc1
520dAC     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
510d C                   if        opcscn = 'Y'
     C                   exsr      scr02i
510d C                   else
510d C                   exsr      scr06i
510d C                   endif
409 D*R                   MOVE '02 '     NXTSCR
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
610aDC**                 if        w2upcd = *blanks and
610aDC**                           w2lcn = *blanks and
610aDC**                           opckin = 'Y'
610aDC**                 goto      skip2
610aDC**                 endif
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif
610aDC**   skip2         tag
610aDC**                 if        w2upcd = *blanks and
610aDC**                           w2lcn = *blanks and
610aDC**                           opckin = 'Y'
610aDC**                 exsr      scr06i
610aDC**                 else
610aDC**                 exsr      scr03i
610aDC**                 endif
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
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '02 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
610bAC     cancel        cabeq     *on           endsc3
     C                   endif
     *
     C                   select
610bDC**                 when      womult = 'Y'
610bDC**                 exsr      scr04i
510bDC*                  when      #toitcwgt = 'Y' and
510bMC                   when      $pccwt = 'Y' and
510bMC                             #toitcwgt = 'Y' and
PAKaAC                             Client <> packers
     C                   exsr      scr05i
HAL  C***** halsey special date capture
HAL  C                   when      #toitflgd = 'Y'
HAL  c*                            and $SLEXPD = 0
HAL  C                   exsr      scr08i
     C                   other
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   endsl
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
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr04i
     C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '03 '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     C                   endif
     *
     C                   select
510bDC*                  when      #toitcwgt = 'Y' and
510bMC                   when      $pccwt = 'Y' and
510bMC                             #toitcwgt = 'Y' and
PAKaAC                             Client <> packers
     C                   exsr      scr05i
HAL  C***** halsey special date capture
HAL  C                   when      #toitflgd = 'Y'
HAL  c*                            and $SLEXPD = 0
HAL  C                   exsr      scr08i
     C                   other
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   endsl
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
610dDC**                 eval      nxtscr = 'EOJ'
610dDC**                 eval      $prtn = '*EXIT   '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr05i
     C                   endif
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     *
610dDC**                 select
610dDC**                 when      womult = 'Y'
610dDC**                 exsr      scr04i
610dDC**                 eval      nxtscr = '04 '
610dDC**                 other
610dDC**                 exsr      scr03i
610dDC**                 eval      nxtscr = '03 '
610dDC**                 endsl
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
510d *  SC6  -  Screen 6
     *
510d C     sc6           begsr
510d *
510d *  Test for F3 - Exit
510d *
510d C                   if        *inkc
510d C                   eval      nxtscr = 'EOJ'
510d C                   eval      $prtn = '*EXIT   '
510d C                   goto      endsc6
510d C                   endif
510d *
510d *  Test for F5 - Refresh
510d *
510d C                   if        *inke
510d C                   if        $pcmd <> '*VIEW   '
510d C                   exsr      scr06i
510d C                   endif
510d C                   goto      endsc6
510d C                   endif
510d *
510d *  Test for F12 - Previous
510d *
510d C                   if        *inkl
510d C                   eval      nxtscr = '02 '
510d C                   goto      endsc6
510d C                   endif
510d *
510d *  Test for other command keys BEFORE verification and update.
510d *
510d C                   eval      cmdchk = '*BEFORE '
510d C                   exsr      zzcmd6
510d C     cmdtkn        cabeq     *on           endsc6
510d *
510d *  Some other key pressed.
510d *
510d *     Check input and write/update record.
510d *
510d C                   if        $pcmd = '*ADD    '  or
510d C                             $pcmd = '*CHANGE '
510d C                   exsr      zzchk6
510d C     error         cabeq     *on           endsc6
510d C                   exsr      zzupd6
510d C     error         cabeq     *on           endsc6
510d C                   endif
610cDC**                 exsr      scr03i
510d *
510d *  Test for other command keys AFTER verification and update.
510d *
510d C                   eval      cmdchk = '*AFTER  '
510d C                   exsr      zzcmd6
510d C     cmdtkn        cabeq     *on           endsc6
510d *
510d C     endsc6        endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  SC7  -  Screen 7
610cA*
610cAC     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr07i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C     cancel        cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
HAL A*----------------------------------------------------------------
HAL A*
HAL A*  SC8  -  Screen 8
     *
HAL AC     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C****               eval      refrsh = *on
     C                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     *
HAL AC     endsc8        endsr
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
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
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZM0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105s
     *
     C     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *----------------------------------------------------------------
     *    PO20029  UPC not on file.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1slot
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    LP11022  License not on file.
     *
     C     zm102         begsr
     C                   eval      #msgid = 'LP11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21201  Quantity entered without item number.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IV21201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21203  Pallet position required.
     *
     C     zm1203        begsr
     C                   eval      #msgid = 'IV21203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
520a *     IV21301  Item exists in location.
     *
     C     zm1301        begsr
     C                   eval      #msgid = 'IV21301'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21302  Not a physical slot
     *
     C     zm1302        begsr
     C                   eval      #msgid = 'IV21302'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21303  Virtual slot not allowed for slot w/2-Char handstk
     *
     C     zm1303        begsr
     C                   eval      #msgid = 'IV21303'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21304  Virtual slot not created
     *
     C     zm1304        begsr
     C                   eval      #msgid = 'IV21304'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21306  Item dept not the same as slot department
     *
     C     zm1306        begsr
     C                   eval      #msgid = 'IV21306'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PT13021  Warning: Entered catch wt not within +/- range.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PT13021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV33002  Slot not in inventory scope.
     *
     C     zm3002        begsr
     C                   eval      #msgid = 'IV33002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
510fA*     IV33005  # of pick slots exceeds # allowed.
510fA*
510fAC     zm3005        begsr
510fAC                   eval      #msgid = 'IV33005'
510fAC                   eval      #msgtp = '*DIAG  '
510fAC*                  eval      erdisp = imnrpk
510fAC                   movea     errmsg        $md(1)
510fAC                   exsr      zmpmsg
510eAC                   endsr
530a *----------------------------------------------------------------
530a *     IV33006  Invalid item.
530a *
530a C     zm3006        begsr
530a C                   eval      #msgid = 'IV33006'
530a C                   eval      #msgtp = '*DIAG  '
530a C                   movea     errmsg        $md(1)
530a C                   exsr      zmpmsg
530a C                   endsr
     *----------------------------------------------------------------
510eA*     IT25206  # of pick slots exceeds # allowed.
510eA*
510eAC     zm5206        begsr
510eAC                   eval      #msgid = 'IT25206'
510eAC                   eval      #msgtp = '*DIAG  '
510eAC                   eval      ernpck = nbrpck
510eAC                   eval      erapck = imnrpk
510eAC                   movea     errmsg        $md(1)
510eAC                   exsr      zmpmsg
510eAC                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
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
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
520dA*
520dA*  Call API for slot.
520dA*
520dAC                   call      @apics
520dAC                   parm                    w1slot
520dAC                   parm      4             worow
520dAC                   parm      08            wocol
520dAC                   parm                    @artn             8
520dAC                   if        @artn = '*REDSPLY'
520dAC                   eval      redspl = *on
520dAC                   goto      endck1
520dAC                   endif
610bDC**
610bDC** Verify "Physical slot" number.
610bDC**
610bDC**   slkey         chain     slot2                              79
610bDC**
610bDC**     Slot doesn't exist.
610bDC**
610bDC**                 if        *in79
610bDC**                 eval      error = *on
610bDC**                 eval      *in33 = *on
610bDC**                 eval      *in13 = *on
610bDC**                 eval      errmsg = *blanks
610bDC**                 movel     w1slot        errmsg
610bDC**                 exsr      zm04
610bDC**                 goto      endck1
610bDC**                 endif
610bA
610bA*  Get slot information.
610bA
610bAC                   exsr      clr$slot
610bAC                   eval      $slwhseu = *on
610bAC                   eval      $slwhse  = $pwhse
610bAC                   eval      $slwhdpu = *on
610bAC                   eval      $slwhdp  = $pwhdp
610bAC                   eval      $sldispu = *on
610bAC                   eval      $sldisp  = w1slot
610bA
610bAC                   eval      $dricommand = '*SLOT'
610bAC                   eval      $drisubcmd  = '%GET'
610bAC                   eval      $drisys2upd = 'D'
610bAC                   eval      chk4err = *on
610bAC                   eval      zmsflag = *off
610bAC                   exsr      zzzdricop
610bAC                   if        error
610bAC                   eval      *in33 = *on
610bAC                   eval      *in13 = *on
610bAC                   eval      errmsg = w1slot
610bAC                   exsr      zm04
610bAC                   goto      endck1
610bAC                   endif
     *
     *  Verify "Physical slot" is in scope.
     *
610xDC*    slkey         chain     invslot4                           77
610xMC     slkey         chain(n)  invslot4                           77
     *      Slot doesn't exist in scope
     *
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3002
     C                   goto      endck1
     C                   else
     C                   eval      sadj = ivsadj
     C                   endif
     C                   endif
    A*
    A*  Slot must be a physical slot.
    A*
610bAC                   if        $slrsrv = 'V'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = *blanks
610bMC                   movel     $sldisp       errmsg
     C                   exsr      zm1302
     C                   goto      endck1
     C                   endif
     *
     *  Physical slot can not have two character handstack code.
      *
610aMC                   movea     $slhand       a2
    AC                   if        a2(1) <> ' '
    AC                   eval      error = *on
    AC                   eval      *in33 = *on
    AC                   eval      *in13 = *on
    AC                   eval      errmsg = *blanks
610aMC                   movel     $sldisp       errmsg
    AC                   exsr      zm1303
    AC                   goto      endck1
    AC                   endif
    A*
    A*  Save slot info.
    A*
610bMC                   eval      svitem = $slitem
610bMC                   eval      svwhse = $slwhse
610bMC                   eval      svwhdp = $slwhdp
610bMC                   eval      svstat = $slstat
610bMC                   eval      svaisl = $slaisl
610bMC                   eval      svloc = $slloc
610bMC                   eval      svrlvl = $slrlvl
610bMC                   eval      svhand = $slhand
610bMC                   eval      svside = $slside
610bMC                   eval      svstyp = $slstyp
610bMC                   eval      svdisp = $sldisp
610bMC                   eval      svsdef = $slsdef
610bMC                   eval      svdesg = $sldesg
610bMC                   eval      svactv = $slactv
610bMC                   eval      svbld = $slbld
610bMC                   eval      svpseq = $slpseq
610bMC                   eval      svslfd = $slslfd
610bMC                   eval      svprty = $slprty
610bAC                   eval      svpick = $slpick
610bDC**
610bDC** Verify that a virtual slot can be created for slot.
610bDC**
610bDC**                 exsr      zzckns
610bDC**                 if        error = *on
610bDC**                 eval      *in33 = *on
610bDC**                 eval      *in13 = *on
610bDC**                 eval      errmsg = *blanks
610bDC**                 movel     w1slot        errmsg
610bDC**                 exsr      zm1304
610bDC**                 goto      endck1
610bDC**                 endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
610bDC**                 if        $pcmd = '*CHANGE '  or
610bDC**                           $pcmd = '*ADD    '
610aA
610aA*    Get out if nothing entered and user allowed to enter item number.
610aA
610aAC                   if        w2upcd = *blanks and
610aAC                             w2lcn = *blanks and
610aAC                             opckin = 'Y'
610aAC                   leavesr
610aaC                   endif
     *
     *    Make sure code was entered.
     *
     C                   if        w2upcd = *blanks  and
     C                             w2lcn = *blanks and
     C                             opckin = 'N'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in40 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Check UPC code if entered.
     *
     C                   if        w2upcd <> *blanks
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w2upcd        $cbbar
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
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upcd        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w2up20
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     C                   eval      upcctr = 0
     C     upckey        setll     upc
     C                   dow       forevr = forevr
     C     upckey        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
     C                   add       1             upcctr
     C                   endif
     *
     C                   enddo
     *
     C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   exsr      zm022
     C                   goto      endck2
     C                   endif
     *
     *   Multiple items exist for UPC
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   move      w2up20        $lupc
     C                   call      'UC920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      errmsg = $lmsg
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endif
     C                   endif
     C                   eval      upitem = $litm1
     *
     C                   eval      wsitem = upitem
     *
     *
     C                   endif
     *
     *    Check License if entered.
     *
     C                   if        w2lcn <> *blanks
     *   Right adjust license for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2lcn         $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         w2lcn
     *   Verify license #
610aDC**   lcnsky        chain     license                            79
610aDC**                 if        *in79
610aAC                   exsr      clr$license
610aAC                   eval      $liToLcnsU = *on
610aAC                   eval      $liToLcns = w2lcn
610aAC                   eval      $dricommand = '*LICENSE'
610aAC                   eval      $drisubcmd  = '%GETLCNS'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aDC**                 eval      error = *on
     C                   eval      *in40 = *on
     C                   exsr      zm102
610aAC                   leavesr
610aAC                   endif
610aA
610aAC                   eval      wsitem = $liToSItem
610aA
610aDC**                 else
     *   Get item from Label
610aDC**   lbkey         setll     label7
610aDC**   lbkey         reade     label7                                 79
610aDC**                 if        *in79
610aDC**                 eval      error = *on
610aDC**                 eval      *in40 = *on
610aDC**                 exsr      zm102
610aDC**                 else
610aDC**                 eval      wsitem = lbitem
610aDC**                 endif
610aDC**                 endif
610aA
     C                   endif
610bA
610bA*   For the rest of the checks we call zzchk6.
610bA
610bAC                   eval      w6item = wsitem
610bAC                   exsr      zzchk6
610bA
610bDC**   Get base item for alias.
610bDC**                 eval      gtitem = wsitem
610bDC**   #geti         tag
610bDC**   keyit         chain     piritem                            79
610bDC**                 if        *in79
610bDC**                 eval      ittype = *blanks
610bDC**                 endif
610bDC**                 if        ittype = 'A'
610bDC**
610bDC**                 eval      gtitem = wsitem
610bDC**                 call      'GETBASE'
610bDC**                 parm      $pwhse        $gwhse            3 0
610bDC**                 parm      gtitem        $gitem           15
610bDC**                 parm      ' '           #bitem
610bDC**                 parm                    #bityp            1
610bDC**                 parm                    #bdesc           30
610bDC**                 parm                    #bpdsc           15
610bDC**                 parm                    #bwhdp            5
610bDC**                 parm                    #bstyp            1
610bDC**                 parm                    #bum              2
610bDC**                 parm                    #bum2             2
610bDC**                 parm                    #bumq2            3 0
610bDC**                 parm                    #bum3             2
610bDC**                 parm                    #bumq3            3 0
610bDC**                 parm      ' '           #bcitm           15
610bDC**                 parm                    #bctyp            1
610bDC**                 parm                    #bcdsc           30
610bDC**                 parm                    #bcpds           15
610bDC**                 parm                    #bcwdp            5
610bDC**                 parm                    #bcstp            1
610bDC**                 parm                    #bcum             2
610bDC**                 parm                    #bcum2            2
610bDC**                 parm                    #bcuq2            3 0
610bDC**                 parm                    #bcum3            2
610bDC**                 parm                    #bcuq3            3 0
610bDC**                 parm                    #brtn             8
610bDC**
610bDC**                 if        #bityp = 'C'  or
610bDC**                           #bityp = 'A'  or
610bDC**                           #bityp = 'S'
610bDC**                 eval      gtitem = #bitem
610bDC**                 goto      #geti
610bDC**                 endif
610bDC**
610bDC**                 eval      wsitem = #bitem
610bDC**                 endif
610aDC**
610aDC**   Skip check if slot allows multiple positions.
610aDC**   Check if item exists in physical slot or virtual slot.
610aDC**
610aDC**                 if        womult <> 'Y'
610aDC**                 exsr      zzcksl
610aDC**                 if        exist = *on
610aDC**                 eval      error = *on
610aDC**                 eval      *in40 = *on
610aDC**                 eval      *in55 = *off
610aDC**                 exsr      zm1301
610aDC**                 endif
610aDC**                 endif
610bDC**
610bDC**   If slot is pick slot, check if # of pick slots.
610bDC**
610bDC**                 if        svpick = 'Y' and
610bDC**                           svstyp = 'F'
610bDC**  Count # of pick slots.
610bDC**                 exsr      chkpck
610bDC**                 add       1             nbrpck
610bDC**
610bDC**  Error if new # of pick slots is > number allowed.
610bDC**
610bDC**                 if        nbrpck > imnrpk
610bDC**   keys3         setll     slot3
610bDC**   keys3         reade     slot3
610bDC**                 if        %found
610bDC**                 eval      erdisp = sldisp
610bDC**                 endif
610bDC**                 eval      error = *on
610bDC**                 eval      *in30 = *on
610bDC**                 eval      *in01 = *on
610bDC**                 exsr      zm3005
610bDC**                 exsr      zm5206
610bDC**                 endif
610bDC**
610bDC**                 endif
610bDC**                 endif
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   if        $pcmd = '*CHANGE '  or
     C                             $pcmd = '*ADD    '
     *
     *  Verify normal quantity is within range.
     *
     C                   if        w3sqt1 < 0  or
     C                             w3sqt1 > 99999
     C                   eval      error = *on
     C                   eval      *in41 = *on
     C                   eval      *in55 = *off
     *
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(3)     errmsg
     C                   other
     C                   movel     desc(3)       erfld
     C                   endsl
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify Breakdown qty 1 is within range.
     *
     C                   if        w3sqt2 < 0  or
     C                             w3sqt2 > 999
     C                   eval      error = *on
     C                   eval      *in42 = *on
     C                   eval      *in55 = *off
     *R                   MOVE *ON       *IN10
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(4)     errmsg
     C                   other
     C                   movel     desc(4)       erfld
     C                   endsl
     C                   movel     '0'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify Breakdown qty 2 is within range.
     *
     C                   if        w3sqt3 < 0  or
     C                             w3sqt3 > 999
     C                   eval      error = *on
     C                   eval      *in43 = *on
     C                   eval      *in55 = *off
     *R                   MOVE *ON       *IN10
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(5)     errmsg
     C                   other
     C                   movel     desc(5)       erfld
     C                   endsl
     C                   movel     '0'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
     *
     C                   endif
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     C                   if        $pcmd = '*CHANGE '  or
     C                             $pcmd = '*ADD    '
     *
     *    Must enter pallet position if multi position slot def.
     *
     C                   if        w4spos = 0  and
     C                             womult = 'Y'
     C                   eval      error = *on
     C                   eval      *in44 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1203
     C                   endif
     *
     *
     *    Skip check if slot allows mult position - MOVED to ZZCHK2
     *
     *
     C                   endif
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     C                   if        $pcmd = '*CHANGE '  or
     C                             $pcmd = '*ADD    '
     *
     *    Get item info for CW.
     C                   exsr      zzgeti
     C                   eval      woqt01 = w3sqt1
     C                   eval      woqt02 = w3sqt2
     C                   eval      woqt03 = w3sqt3
     *    Weight can't be zero.
     *
     C                   if        w5cwgt = 0
     C                   endif
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
     C                   z-add     0             taddw             7 2
     C                   eval      taddw = w5cwgt
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
    DC**                 z-add     w2cwgt        cwgt              7 0
    DC**   cwgt          div       100           taddw             7 2
    DC*                  z-add     0             taddw             7 2
    DC*                  eval      taddw = cwgt
     C                   if        lvskp = *off and
     C                             taddw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in46 = *on
     C*                  eval      *in21 = *on
     C*                  eval      *in01 = *on
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
     *
     C                   endif
     C     enderr        tag
     *
     C                   endif
     C     endck5        endsr
     *----------------------------------------------------------------
510d *
510d *  ZZCHK6   Screen 6 error checking.
510d *
510d C     zzchk6        begsr
510d C                   eval      error = *off
510d C                   if        $pcmd = '*CHANGE '  or
510d C                             $pcmd = '*ADD    '
510d *
510d *    Make sure item was entered.
510d *
510d C*                  if        w6item = *blanks
530aMC                   if        w6item = *blanks and
530aMC                             w6vit# = *blanks
510d C                   eval      error = *on
510d C                   eval      *in30 = *on
510d C                   eval      *in40 = *on
510d C                   exsr      zm01
510d C                   goto      endck6
510d C                   endif
530a *
530a *    Get item # if Mfg item # was entered.
530a *
530aMC                   if        w6vit# <> *blanks
530a C                   eval      wsitem = w6vit#
530aAC     itkey         chain     piritem4                           79
530aAC                   if        *in79
530a C                   eval      error = *on
530a C                   eval      *in31 = *on
510a C**                 eval      *in40 = *on
530aAC*                  eval      $itdesc = 'ITEM NOT FOUND'
530a C                   exsr      zm3006
530a C                   goto      endck6
530a C                   else
530a C                   eval      wsitem = *blanks
530a C                   eval      w6item = ititem
530a C                   endif
530a C                   endif
530a *
510d *
510d *    Verify item.
510dA*  Use DRI interface to get item.
610bA*  We now verify the item by getting its correpsonding slot item.
510dA
510dAC                   exsr      clr$item
510dAC                   eval      $itwhse  = $pwhse
510dAC                   eval      $ititem  = w6item
510dA
510dAC                   eval      $dricommand = '*ITEM'
610bDC**                 eval      $drisubcmd  = '%VERIFY '
610bAC                   eval      $drisubcmd  = '%GETSLOT'
510dAC                   eval      $drisys2upd = 'D'
510dAC                   eval      chk4err = *on
510dAC                   eval      zmsflag = *off
510dAC                   exsr      zzzdricop
510dAC                   if        error
510d C                   eval      *in30 = *on
510d C                   exsr      zm022
510d C                   goto      endck6
510 AC**                 eval      $itdesc = 'ITEM NOT FOUND'
510dAC                   endif
510dA
510dAC                   eval      #toititem = $ititem
510dAC                   eval      #toittype = $ittype
510dAC                   eval      #toitdesc = $itdesc
510dAC                   eval      #toitpdsc = $itpdsc
510dAC                   eval      #toitwhdp = $itwhdp
510dAC                   eval      #toitstyp = $itstyp
510dAC                   eval      #toitdesg = $itdesg
510dAC                   eval      #toitum1  = $itum1
510dAC                   eval      #toitflg1 = $itflg1
510dAC                   eval      #toitum2  = $itum2
510dAC                   eval      #toitumq2 = $itumq2
510dAC                   eval      #toitflg2 = $itflg2
510dAC                   eval      #toitum3  = $itum3
510dAC                   eval      #toitumq3 = $itumq3
510dAC                   eval      #toitnrpk = $imnrpk
510dAC                   eval      #toitflgd = $itflgd
510dAC                   eval      #toitcube = $itcube
510dAC                   eval      #toitswgt = $itswgt
510dAC                   eval      #toitcwgt = $itcwgt
510dAC                   eval      #toitmitem = $itmitem
510d *
510d C                   eval      wsitem = $ititem
610bAC                   eval      tracklevel = $imltrk
610bDC**
610bDC**   Skip check if slot allows multiple positions.
610bDC**   Check if item exists in physical slot or virtual slot.
610bDC**
610bDC**                 if        womult <> 'Y'
610bDC**                 exsr      zzcksl
610bDC**                 if        exist = *on
610bDC**                 eval      error = *on
610bDC**                 eval      *in40 = *on
610bDC**                 eval      *in55 = *off
610bDC**                 exsr      zm1301
610bDC**                 endif
610bDC**                 endif
610bA
610bA*    For a low tracked item, see if it is already in slot.
610bA
610bAC                   if        tracklevel = tLow
610bA
610bAC                   exsr      clr$slot
610bAC                   eval      $slwhseu = *on
610bAC                   eval      $slwhse  = $pwhse
610bAC                   eval      $slwhdpu = *on
610bAC                   eval      $slwhdp  = $pwhdp
610bAC                   eval      $sldispu = *on
610bAC                   eval      $sldisp  = w1slot
610bAC                   eval      $saitemu = *on
610bAC                   eval      $saitem  = wsitem
610bA
610bAC                   eval      $dricommand = '*SLOT'
610bAC                   eval      $drisubcmd  = '%VFYINSLOT'
610bAC                   eval      $drisys2upd = 'D'
610bAC                   eval      chk4err = *off
610bAC                   eval      zmsflag = *off
610bAC                   exsr      zzzdricop
610bAC                   if        $drireturn = 'ITMFOUND'
610bAC                   eval      error = *on
610bAC                   eval      *in30 = *on
610bAC                   eval      errmsg = 'Item already in slot'
610bAC                   exsr      zm0105
610bAC                   goto      endck6
610bAC                   endif
610bA
610bAC                   endif
510e *
510e *    If slot is pick slot, check if # of pick slots.
510e *
610bMC                   if        svpick = 'Y' and
610bMC                             svstyp = 'F'
510eA*   Count # of pick slots.
510eAC                   exsr      chkpck
510eAC                   add       1             nbrpck
510eA*
510eA*   Error if new # of pick slots is > number allowed.
ICBa * ICB*  If Pick slot is active, skip error for # of pick slots
ICBa C                   select
ICBa C                   when      client = icb
ICBa C                   if        svpick = 'Y' and
ICBa C                             svstat = 'A'
ICBa C                   eval      nbrpck = imnrpk
ICBa C                   endif
ICBa C                   endsl
     *
     *
510eAC                   if        nbrpck > imnrpk
510e C     keys3         setll     slot3
510e C     keys3         reade     slot3
510e C                   if        %found
510e C                   eval      erdisp = sldisp
510e C                   endif
510eAC                   eval      error = *on
610bAC                   eval      *in30 = *on
610bDC**                 eval      *in21 = *on
610bDC**                 eval      *in01 = *on
510fAC                   exsr      zm3005
510fAC*                  exsr      zm5206
510eAC                   endif
510eA*
510eAC                   endif
510d *
510d C                   endif
510d C     endck6        endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  ZZCHK7   Screen 7 error checking.
610cA*
610cAC     zzchk7        begsr
     C                   eval      error = *off
     *
     C     endck7        endsr
HAL A*----------------------------------------------------------------
     *
HAL A*  ZZCHK8   Screen 8 error checking.
     *
HAL  C     zzchk8        begsr
     C                   eval      error = *off
     *
HAL A*    Date must be a valid date
     *
     *     Verify date
     *
     c                   if        skipdate = ' '
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w8date        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C                   goto      endck8
     C                   endif
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      #msgk = $cvmsg
     C****               eval      erdate = w8date
     C                   exsr      zm9906
     C                   endif
     C                   endif
     *
     *
     *
     C     endck8        endsr
610bDC**---------------------------------------------------------------
610bDC**
610bDC**
610bDC** ZZCKNS   Get new Vslot.
610bDC**
610bDC**   zzckns        begsr
610bDC**                 eval      error = *on
610bDC**  Set handstack flag for later use.
610bDC**                 if        svhand <> ' '
610bDC**                 eval      flaghs = *on
610bDC**                 else
610bDC**                 eval      flaghs = *off
610bDC**                 endif
610bDC***
610bDC**                 eval      $vdisp = *blanks
610bDC**                 eval      k = 0
610bDC**                 eval      $vwhse = svwhse
610bDC**                 eval      $vwhdp = svwhdp
610bDC**                 eval      $vaisl = svaisl
610bDC**                 eval      $vloc = svloc
610bDC**                 eval      $vrlvl = svrlvl
610bDC**                 eval      $vhand = *blanks
610bDC**                 eval      $vstyp = svstyp
610bDC**                 eval      $vpseq = svpseq
610bDC**                 eval      $vdisp = *blanks
610bDC**                 eval      $vpick = slpick
610bDC*** Loop & increment handstack to find new v-slot to create.
610bDC**         K         DOWLE720
610bDC**                 dow       k <= 702
610bDC**                 add       1             k
610bDC**    If physical slot had handstack then limit hs we can use.
610bDC**                 if        flaghs = *on
610bDC**                 movea     hnd(k)        a2n
610bDC**                 if        a2n(1) <> a2(2)
610bDC**                 iter
610bDC**                 endif
610bDC**                 endif
610bDC**                 eval      $vhand = hnd(k)
610bDC**                 call      'FRMTVS'
610bDC**                 parm                    svdisp
610bDC**                 parm                    flaghs
610bDC**                 parm                    $vhand            2
610bDC**                 parm                    $vdisp           12
     *
412 D*R                   CALL 'FRMTSL'
412 D*R                   PARM           $VWHSE  30
412 D*R                   PARM           $VWHDP  5
412 D*R                   PARM           $VAISL  3
412 D*R                   PARM           $VLOC   30
412 D*R                   PARM           $VRLVL  20
412 D*R                   PARM           $VHAND  2
412 D*R                   PARM           $VSTYP  1
412 D*R                   PARM           $VPSEQ  50
412 D*R                   PARM           $VDISP 12
610bDC**   ckkey         chain(n)  slot2                              79
610bDC**                 if        *in79
610bDC**                 eval      newvs = *on
610bDC**                 eval      error = *off
     *R                   MOVE $VDISP    W1DISP
610bDC**                 leave
610bDC**                 else
610bDC**                 iter
610bDC**                 endif
610bDC**                 enddo
610bDC**
610bDC**   endckn        endsr
610bDC**---------------------------------------------------------------
610bDC**
610bDC**
610bDC** ZZCKSL   Check if item exists in reg or V slot
610bDC**
610bDC**   zzcksl        begsr
610bDC**                 eval      exist = *off
610bDC**                 if        svitem = wsitem
610bDC**                 eval      exist = *on
610bDC**                 goto      endcks
610bDC**                 else
610bDC**   vskey         setll     vslot2
610bDC**   nxt1          tag
414gD**         VSKEY     READEVSLOT2                   78
610bDC**   vskey         reade(n)  vslot2                                 78
610bDC**                 if        not *in78
610bDC**                 eval      $vdisp = vsdisp
610bDC**   ckkey         chain(n)  slot2                              79
610bDC**                 if        not *in79  and
610bDC**                           slitem = wsitem
610bDC**                 eval      exist = *on
610bDC**                 goto      endcks
610bDC**                 else
610bDC**                 goto      nxt1
610bDC**                 endif
610bDC**                 endif
610bDC**                 endif
610bDC**
610bDC**   endcks        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - EXCEPTION - SLOT
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
417bMC***                eval      w2whdp = pwhdp
417bMC***                eval      w2disp = pdisp
416bA*
610xDC**   slkey         chain     invslot4                           79
610xMC     slkey         chain(n)  invslot4                           79
     C                   eval      cmdtkn = *on
     C                   eval      excode = '1'
     C                   exsr      zzexcp
     C***                eval      scode = 'X '
     C***                exsr      zzupdi
     C                   eval      nxtscr = 'EOJ'
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
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F8 -  Catch Weight Override
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C*                  eval      cmdtkn = *on
     C                   goto      endcm5
     C                   else
     C                   move      *off          ovrrid
     C                   endif
     *
     C     endcm5        endsr
510d *----------------------------------------------------------------
510d *
510d *  ZZCMD6   User defined command keys for screen 6.
510d *
510d C     zzcmd6        begsr
510d C                   eval      cmdtkn = *off
510d *
510d *  Command keys to check BEFORE verification and update.
510d *
510d C                   if        cmdchk = '*BEFORE '
510d *
510d *  Test for F10 - EXCEPTION - SLOT
510d *
510d C                   if        *inkj
510d C                   eval      cmdtkn = *on
510d *
610xDC**   slkey         chain     invslot4                           79
610xMC     slkey         chain(n)  invslot4                           79
510d C                   eval      cmdtkn = *on
510d C                   eval      excode = '1'
510d C                   exsr      zzexcp
510d C                   eval      nxtscr = 'EOJ'
510d C                   goto      endcm6
510d C                   endif
510d C                   endif
510d *
510d *  Command keys to check AFTER verification and update.
510d *
510d C                   if        cmdchk = '*AFTER  '
510d C                   endif
510d C     endcm6        endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  ZZCMD7   User defined command keys for screen 7.
610cA*
610cAC     zzcmd7        begsr
     C                   eval      cmdtkn = *off
     C     endcm7        endsr
HAL A*----------------------------------------------------------------
     *
HAL A*  ZZCMD8   User defined command keys for screen 8.
     *
HLA AC     zzcmd8        begsr
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
     C                   goto      endcm8
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F9 - SKIP - Date Entry
     *
     C                   if        *inkI
     c                   eval      skipdate = 'Y'
     C                   else
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
HAL AC     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCWGT   Calculate catch weight variance values.
     *
     C     zzcwgt        begsr
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
    DC**   $slvlopickqty mult      $slvlouwgt    exwgt
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
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1slot = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
     C                   eval      w2upcd = *blanks
     C                   eval      w2up20 = *blanks
     C                   eval      w2lcn = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   eval      w3sqt1 = 0
     C                   eval      w3sqt2 = 0
     C                   eval      w3sqt2 = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT4   Get default values for add.
     *
     C     zzdft4        begsr
     C                   eval      w4spos = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT5   Get default values for add.
     *
     C     zzdft5        begsr
     *    Get CW options
     C                   exsr      zzoptn
     C                   eval      w5cwgt = 0
     C                   endsr
510d *----------------------------------------------------------------
510d *
510d *  ZZDFT6   Get default values for add.
510d *
510d C     zzdft6        begsr
510d C                   eval      exist = *off
510d C                   eval      newvs = *off
510d C                   eval      w6item = *blanks
530a C                   eval      w6vit# = *blanks
510d C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Create Exception record.
     *
     C     zzexcp        begsr
     C                   eval      ivewhs = ivswhs
     C                   eval      ivepag = ivspag
     C                   eval      ivedsp = ivsdsp
     C                   if        excode = '4'
     C                   eval      ivesta = '4'
     C                   else
     C                   eval      ivesta = *on
     C                   endif
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
     C                   eval      iveeby = $pteam
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     C                   endsr
510d *----------------------------------------------------------------
510d *
510d *  ZZFIL6   Fill screen 6 fields with info from file.
510d *
510d C     zzfil6        begsr
510d C                   endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  ZZFIL7   Fill screen 7 fields with info from file.
610cA*
610cAC     zzfil7        begsr

     C                   eval      w7item = #toititem
     C                   movel     #toitdesc     w7itm1
     C                   move      #toitdesc     w7itm2
     C                   eval      w7itm3 = #toitpdsc

     C                   endsr
HAL A*----------------------------------------------------------------
     *
HAL A*  ZZFIL8   Fill screen 8 fields with info from file.
     *
HAL AC     zzfil8        begsr
     *
     *   Initialize entry fields
     *
HAL  C                   if        #toimmflg = 'Y'
HAL  C                   eval      w8datetype = 'Mfg Date'
HAL  C                   else
HAL  C                   eval      w8datetype = 'Exp Date'
HAL  C                   endif
HAL  C                   eval      w8date = 0
HAL  C                   eval      skipdate = ' '
     *
HAL AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
510d *   Code below was moved to ZZGETM
510d *   Check if slot has multiple positions
510d C                   exsr      zzgetm
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     *
     *   Get item description.
     *
    DC**   keyit         chain     piritem                            79
    DC**                 if        *in79
    A
    A*  Use DRI interface to get item.
    A
    AC                   exsr      clr$item
    AC                   eval      $itwhse  = $pwhse
    AC                   eval      $ititem  = wsitem
    A
    AC                   eval      $dricommand = '*ITEM'
    AC                   eval      $drisubcmd  = '%GETMAIN'
    AC                   eval      $drisys2upd = 'D'
    AC                   eval      chk4err = *on
    AC                   eval      zmsflag = *off
    AC                   exsr      zzzdricop
    AC                   if        error
    AC                   eval      error = *off
    AC                   eval      $itdesc = 'ITEM NOT FOUND'
    DC**                 eval      w3itm1 = *blanks
    DC**                 eval      w3itm2 = *blanks
    DC**                 eval      w3itm3 = *blanks
    DC**                 eval      itumq2 = 0
    DC**                 eval      itumq3 = 0
    DC**                 else
    AC                   endif
    A
    AC                   eval      #toititem = $ititem
    AC                   eval      #toittype = $ittype
    AC                   eval      #toitdesc = $itdesc
    AC                   eval      #toitpdsc = $itpdsc
    AC                   eval      #toitwhdp = $itwhdp
    AC                   eval      #toitstyp = $itstyp
    AC                   eval      #toitdesg = $itdesg
    AC                   eval      #toitum1  = $itum1
    AC                   eval      #toitflg1 = $itflg1
    AC                   eval      #toitum2  = $itum2
    AC                   eval      #toitumq2 = $itumq2
    AC                   eval      #toitflg2 = $itflg2
    AC                   eval      #toitum3  = $itum3
    AC                   eval      #toitumq3 = $itumq3
    AC                   eval      #toitnrpk = $imnrpk
    AC                   eval      #toitflgd = $itflgd
HAL  C                   eval      #toimmflg = $immflg
    AC                   eval      #toitcube = $itcube
    AC                   eval      #toitswgt = $itswgt
    AC                   eval      #toitcwgt = $itcwgt
    AC                   eval      #toitmitem = $itmitem
    A
    A*  Use DRI interface to get corresponding SSB item, if any.
    A
    AC                   exsr      clr$item
    AC                   eval      $itwhse  = $pwhse
    AC                   eval      $ititem  = wsitem
    A
    AC                   eval      $dricommand = '*ITEM'
    AC                   eval      $drisubcmd  = '%GETSSB'
    AC                   eval      $drisys2upd = 'D'
    AC                   eval      chk4err = *off
    AC                   eval      zmsflag = *off
    AC                   exsr      zzzdricop
    AC                   if        $drireturn = 'SSBNOTFND'
    AC                   eval      ssbflg  = *off
    AC                   eval      #tossbititem = ' '
    AC                   eval      #tossbittype = ' '
    AC                   eval      #tossbitdesc = ' '
    AC                   eval      #tossbitpdsc = ' '
    AC                   eval      #tossbitwhdp = ' '
    AC                   eval      #tossbitstyp = ' '
    AC                   eval      #tossbitdesg = ' '
    AC                   eval      #tossbitum1  = ' '
    AC                   eval      #tossbitum2  = ' '
    AC                   eval      #tossbitumq2 = 0
    AC                   eval      #tossbitum3  = ' '
    AC                   eval      #tossbitumq3 = 0
    AC                   else
    AC                   eval      ssbflg  = *on
    AC                   eval      #tossbititem = $ititem
    AC                   eval      #tossbittype = $ittype
    AC                   eval      #tossbitdesc = $itdesc
    AC                   eval      #tossbitpdsc = $itpdsc
    AC                   eval      #tossbitwhdp = $itwhdp
    AC                   eval      #tossbitstyp = $itstyp
    AC                   eval      #tossbitdesg = $itdesg
    AC                   eval      #tossbitum1  = $itum1
    AC                   eval      #tossbitum2  = $itum2
    AC                   eval      #tossbitumq2 = $itumq2
    AC                   eval      #tossbitum3  = $itum3
    AC                   eval      #tossbitumq3 = $itumq3
    AC                   endif

    A
    A*  Initialize screen fields.
    A
    DC**                 movel     itdesc        w3itm1
    DC**                 move      itdesc        w3itm2
    DC**                 eval      w3itm3 = itpdsc
    DC*                  movel     #toitdesc     w3itm1
    DC*                  move      #toitdesc     w3itm2
    DC*                  eval      w3itm3 = #toitpdsc
    DC**                 endif
     *
     *   Get Unit of measure fields
     C                   eval      w3um1 = *blanks
     C                   eval      w3um2 = *blanks
     C                   eval      w3um3 = *blanks
     C                   exsr      zzuom
     *
510cD*   Check if slot has multiple positions CODE MOVED to ZZGET2
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET4   Get record(s) for screen 4.
     *
     C     zzget4        begsr
     *
     C     endgt4        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET5   Get record(s) for screen 5.
     *
     C     zzget5        begsr
     C     endgt5        endsr
510d *----------------------------------------------------------------
510d *
510dA*  ZZGET6   Get record(s) for screen 6.
510d *
510d C     zzget6        begsr
510d *
510d *   Check if slot has multiple positions
510d C                   exsr      zzgetm
510d C     endgt6        endsr
     *----------------------------------------------------------------
     *
    AC*  ZZGETI   Get item info
     *
    AC     zzgeti        begsr
    A
    A*  Use DRI interface to get item.
    A
    AC                   exsr      clr$item
    AC                   eval      $itwhse  = $pwhse
    AC                   eval      $ititem  = wsitem
    A
    AC                   eval      $dricommand = '*ITEM'
    AC                   eval      $drisubcmd  = '%GETMAIN'
    AC                   eval      $drisys2upd = 'D'
    AC                   eval      chk4err = *on
    AC                   eval      zmsflag = *off
    AC                   exsr      zzzdricop
    AC                   if        error
    AC                   eval      error = *off
    AC                   eval      $itdesc = 'ITEM NOT FOUND'
    AC                   endif
    A
    AC                   eval      #toititem = $ititem
    AC                   eval      #toittype = $ittype
    AC                   eval      #toitdesc = $itdesc
    AC                   eval      #toitpdsc = $itpdsc
    AC                   eval      #toitwhdp = $itwhdp
    AC                   eval      #toitstyp = $itstyp
    AC                   eval      #toitdesg = $itdesg
    AC                   eval      #toitum1  = $itum1
    AC                   eval      #toitflg1 = $itflg1
    AC                   eval      #toitum2  = $itum2
    AC                   eval      #toitumq2 = $itumq2
    AC                   eval      #toitflg2 = $itflg2
    AC                   eval      #toitum3  = $itum3
    AC                   eval      #toitumq3 = $itumq3
    AC                   eval      #toitnrpk = $imnrpk
    AC                   eval      #toitflgd = $itflgd
    AC                   eval      #toitcube = $itcube
    AC                   eval      #toitswgt = $itswgt
    AC                   eval      #toitcwgt = $itcwgt
    AC                   eval      #toitmitem = $itmitem
    A
    A*  Use DRI interface to get corresponding SSB item, if any.
    A
    AC                   exsr      clr$item
    AC                   eval      $itwhse  = $pwhse
    AC                   eval      $ititem  = wsitem
    A
    AC                   eval      $dricommand = '*ITEM'
    AC                   eval      $drisubcmd  = '%GETSSB'
    AC                   eval      $drisys2upd = 'D'
    AC                   eval      chk4err = *off
    AC                   eval      zmsflag = *off
    AC                   exsr      zzzdricop
    AC                   if        $drireturn = 'SSBNOTFND'
    AC                   eval      ssbflg  = *off
    AC                   eval      #tossbititem = ' '
    AC                   eval      #tossbittype = ' '
    AC                   eval      #tossbitdesc = ' '
    AC                   eval      #tossbitpdsc = ' '
    AC                   eval      #tossbitwhdp = ' '
    AC                   eval      #tossbitstyp = ' '
    AC                   eval      #tossbitdesg = ' '
    AC                   eval      #tossbitum1  = ' '
    AC                   eval      #tossbitum2  = ' '
    AC                   eval      #tossbitumq2 = 0
    AC                   eval      #tossbitum3  = ' '
    AC                   eval      #tossbitumq3 = 0
    AC                   else
    AC                   eval      ssbflg  = *on
    AC                   eval      #tossbititem = $ititem
    AC                   eval      #tossbittype = $ittype
    AC                   eval      #tossbitdesc = $itdesc
    AC                   eval      #tossbitpdsc = $itpdsc
    AC                   eval      #tossbitwhdp = $itwhdp
    AC                   eval      #tossbitstyp = $itstyp
    AC                   eval      #tossbitdesg = $itdesg
    AC                   eval      #tossbitum1  = $itum1
    AC                   eval      #tossbitum2  = $itum2
    AC                   eval      #tossbitumq2 = $itumq2
    AC                   eval      #tossbitum3  = $itum3
    AC                   eval      #tossbitumq3 = $itumq3
    AC                   endif

    AC     endgti        endsr
510d *----------------------------------------------------------------
510d *
510dA*  ZZGETM   Get multiple slot positions
510d *
510d C     zzgetm        begsr
510d *
510d *   Check if slot has multiple positions
510d C                   eval      womult = ' '
510d C                   eval      *in45 = *on
510d C     slskey        chain     slotdef                            76
510d C                   if        not *in76  and
510d C                             sdpos > 1
510d C                   eval      womult = 'Y'
510d C                   eval      *in45 = *off
510d C                   endif
510d C     endgtm        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
510eA*
510eA*  Define partial key for SLOT3 file.
510eA*
510eAC     keys3         klist
510eAC                   kfld                    $pwhse
510eMC                   kfld                    wsitem
510eAC                   kfld                    k3stat
510eAC                   kfld                    k3pick
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w2lcn
     *
     *  Define key for SLOT2 file.
     *
     C     slkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    w1slot
     *
     *  Define key for UPC file.
     C     upckey        klist
     C                   kfld                    $pwhse
     C                   kfld                    w2up20
610bDC**
610bDC** Define key for VSLOT2 file.
610bDC**
610bDC**   vskey         klist
610bDC**                 kfld                    $pwhse
610bDC**                 kfld                    $pwhdp
610bDC**                 kfld                    w1slot
610bDC**
610bDC** Define key for SLOT2 file.
610bDC**
610bDC**   ckkey         klist
610bDC**                 kfld                    $pwhse
610bDC**                 kfld                    $pwhdp
610bDC**                 kfld                    $vdisp
     *  Define key for INVSCW file.
     *
     C     cwkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    sldisp
     C                   kfld                    wsitem
     *
     *     ITEMMSC file -
     C     imkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    wsitem
     *
     *  Define key for INVSLOT file.
     *
     C     ivskey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
610xAC                   kfld                    $slaisl
610xAC                   kfld                    $slloc
610xAC                   kfld                    $slrlvl
610xAC                   kfld                    $slhand
     *
     *     OPTIONS file
     C     opkeys        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *  Define key for INVPAGE2 file.
     *
     C     pagkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    kypage
     *
     *     PIRITEM file
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    wsitem
610bDC**    PIRITEM file
610bDC**   keyit         klist
610bDC**                 kfld                    $pwhse
610bDC**                 kfld                    gtitem
     *
     *     LABEL   file
     C     lbkey         klist
     C                   kfld                    litrn#
     *
     *  Define key for SLOTDEF.
     C     slskey        klist
     C                   kfld                    slwhse
     C                   kfld                    slsdef
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      #pgmq = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
    A*
    A*   Get employee options.
    A*
JORaA*  Set language to english until Jordano's is updated to V5.0
JORaAC                   eval      e$lng = 'EN'
    AC                   call      'GETUSER'
    AC                   parm      #user         e$code           10
    AC                   parm                    e$whse            3 0
    AC                   parm                    e$emp#            5 0
    AC                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
    AC                   parm                    e$whdp            5
    AC                   parm                    e$styp            1
    AC                   parm                    e$shft            6
    AC                   parm                    e$crew            6
    AC                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
JORaDC**                 parm                    e$bpu             1
JORaDC**                 parm                    e$lng             2
    AC                   if        e$rtn <> '*OK'
    AC                   eval      e$lng = 'EN'
    AC                   endif
    A*
520dAC                   eval      worow = *zeros
520dAC                   eval      wocol = *zeros
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      newvs = *off
     *
412 AC                   eval      $pcmd = '*ADD    '
     C                   exsr      scr01i
     *
     C     endinz        endsr
     *----------------------------------------------------------------
510d *
510d *  ZZOPTC   Get COUNT options
     *
510d C     zzoptc        begsr
     *
     *   Get count options.
     C                   eval      wkcode = '*COUNT  '
     C                   eval      wkwhse = $pwhse
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcupc = 'N'
     C                   eval      opcadd = 'Y'
     C                   eval      opcscn = 'Y'
     C                   eval      opckin = 'N'
     C                   eval      opccwt = 'N'
     C                   else
     C                   eval      opdat1 = opdata
     C                   endif
     C*
510d C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPTN   Get options
     *
     C     zzoptn        begsr
     *
     *   Get catch wt options.
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
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
510d *  Get *COUNT options
510d C                   exsr      zzoptc
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off

610aAC                   if        w2upcd = *blanks and
610aAC                             w2lcn = *blanks and
610aAC                             opckin = 'Y'
610aAC                   exsr      scr06i
610aAC                   else
610cDC**                 exsr      scr03i
610cMC                   exsr      scr07i
610aAC                   endif

     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
610bA
610bA*  Call license tracking - Before
610bA
610bAC                   if        tracklevel = tLow
610bAC                   eval      $tlic# = '*CC'
610bAC                   eval      $tinlic# = '*CC'
610bAC                   else
610bAC                   exsr      zzzclr$lt210
610bAC                   eval      $tcmd     = '*GETNEW'
610bAC                   eval      $twhse    = svwhse
610bAC                   eval      $titem    = wsitem
610bAC                   eval      $titemdsc = wsitem
610bAC                   eval      $tlic#    = ' '
610bAC                   exsr      zzzcall$lt210
610bAC
610bAC                   if        $treturn <> '*OK'
610bAC                   eval      cancel = *on
610bAC                   leavesr
610bAC                   endif
610bA
610bAC                   endif
610bA
610bA*  Put qty in slot.
610bA
610bAC                   exsr      clr$slot
610bAC                   eval      $slwhseu = *on
610bAC                   eval      $slwhse  = svwhse
610bAC                   eval      $slwhdpu = *on
610bAC                   eval      $slwhdp  = svwhdp
610bAC                   eval      $sldispu = *on
610bAC                   eval      $sldisp  = svdisp
610bAC                   eval      $slstatu = *on
610bAC                   if        svstat <> 'Z '  and
610bAC                             svstat <> 'V '
610bAC                   eval      $slstat = svstat
610bAC                   else
610bAC                   eval      $slstat = 'A '
610bAC                   endif
610bA
610bAC                   if        w2lcn <> ' '
610bAC                   eval      $slentdu = *on
610bAC                   eval      $slentd  = $liToEntD
610bAC                   eval      $slexpdu = *on
610bAC                   eval      $slexpd  = $liToExpD
610bAC                   endif
610bA
610bAC                   eval      $saitemu = *on
610bAC                   eval      $saitem  = #toititem
610bAC                   eval      $saqtyu = *on
610bAC                   eval      $saqty1 = 0
610bAC                   eval      $saqty2 = 0
610bAC                   eval      $saqty3 = 0
610bA
610bAC                   eval      $saActionU = *on
610bAC                   eval      $saAction = 'CNT'
610bAC                   eval      $saETrn#U = *on
610bAC                   eval      $saETrn# = 0
610bAC                   eval      $saToLcnsU = *on
610bAC                   eval      $saToLcns = $tinlic#
610bAC                   eval      $saToPosU = *on
610bAC                   eval      $saToPos = 1
610bAC                   eval      $saToVrfyU = *on
610bAC                   eval      $saToVrfy = 'Y'
610bAC                   eval      $saToCodeu = *on
610bAC                   eval      $saToCode = 'S'
610bAC                   eval      $saToAreaU = *on
610bAC                   eval      $saToArea = 'Slot'
610bAC                   if        w2lcn <> ' '
610bAC                   eval      $saOLcnsU = *on
610bAC                   eval      $saOLcns = $liOLcns
610bAC                   endif
610bA
610bAC                   eval      $dricommand = '*SLOT'
610bAC                   eval      $drisubcmd  = '%QTY2PUT0'
610bAC                   eval      $drisys2upd = 'D'
610bAC                   eval      chk4err = *on
610bAC                   eval      zmsflag = *off
610bAC                   exsr      zzzdricop
610bAC                   if        error
610bAC                   goto      endup3
610bAC                   endif
610bDC**
610bDC**  Add item to existing zero verified or empty slot if possible.
610bDC**   slkey         chain     invslot4                           79
610bDC**                 if        not *in79
610bDC**                 if        ivsitm = ' ' or
610bDC**                           ivsqt1 = 0   and
610bDC**                           ivsqt2 = 0   and
610bDC**                           ivsqt3 = 0
610bDC**                 eval      $cvcmd = '*CURCMD '
610bDC**                 call      @cvtdt
610bDC**                 parm                    $cvtdt
610bDC**                 eval      ivsedt = $cvd8o
610bDC**                 time                    ivsetm
610bDC**                 eval      ivseby = $pteam
610bDC**                 eval      ivsitm = wsitem
610bDC**                 eval      ivsqt1 = w3sqt1
610bDC**                 eval      ivsqt2 = w3sqt2
610bDC**                 eval      ivsqt3 = w3sqt3
610bDC**                 if        ivssta = 'V'
610bDC**                 eval      ivssta = 'A'
610bDC**                 endif
610bDC**                 update    ivsrec4
610bDC**                 goto      endup3
610bDC**                 endif
610bDC**                 endif
     *
     *   Get last page of INVPAGE2
     *
     C                   eval      kypage = 99999
     C     pagkey        setgt     invpage2
     C                   readp     invpage2                               79
     C                   if        not *in79
     C                   eval      sheet = ivppag
     C                   if        ivpvtl = *off  or
     C                             ivpcnt = 15
     *
     C     $pwhse        chain     invnxtp                            7978
     *
     *  Record locked.
     *
     C                   select
     C                   when      *in78
     C                   eval      error = *on
     *
     *  Record found - Get next page number and update record.
     *
     C                   other
     C                   eval      sheet = ivxpag
     C                   add       1             ivxpag
     C                   update    ivxrec
     *
     C                   endsl
     *
     *     Initialize fields for the next page record.
     *
     C                   clear                   ivprec
     C                   eval      ivppag = sheet
610bMC                   eval      ivpwhs = $slwhse
     C                   eval      ivpsta = 'E'
610bMC                   eval      ivpwhd = $slwhdp
610bMC                   eval      ivpasl = $slaisl
610bMC                   eval      ivplvl = $slrlvl
610bMC                   eval      ivpstp = $slstyp
     C                   movel     'VIRTUAL'     ivpfrm
     C                   movel     'VIRTUAL'     ivpto
     C                   eval      ivpcnt = 1
     C                   eval      ivppdt = today
     C                   time                    ivpptm
     C                   eval      ivpedt = today
     C                   time                    ivpetm
     C                   eval      ivpmor = *off
     C                   eval      ivpvtl = *on
     C                   write     ivprec
     C                   else
     C     ivpcnt        add       1             ivpcnt
     C                   update    ivprec
     C                   endif
     C                   endif
     *
     C     ivskey        chain(n)  invslot                            79
     C                   if        not *in79
     C                   eval      pexp = ivspex
     C                   else
     C                   eval      pexp = 'N'
     C                   endif
610bDC**  Create Virtual Slot
610bDC**
610bDC**                 exsr      zzckns
610bDC**                 if        error = *on
610bDC**                 eval      *in21 = *on
610bDC**                 eval      *in01 = *on
610bDC**                 eval      errmsg = *blanks
610bDC**                 movel     w1slot        errmsg
610bDC**                 exsr      zm1304
610bDC**                 goto      endup3
610bDC**                 endif
610bDC**
610bDC**                 if        newvs = *on
610bDC**                 eval      slitem = wsitem
610bDC**                 eval      slwhse = $vwhse
610bDC**                 eval      slwhdp = $vwhdp
610bDC**                 if        svstat <> 'Z '  and
610bDC**                           svstat <> 'V '
610bDC**                 eval      slstat = svstat
610bDC**                 else
610bDC**                 eval      slstat = 'A '
610bDC**                 endif
610bDC**                 eval      slaisl = $vaisl
610bDC**                 eval      slloc = $vloc
610bDC**                 eval      slrlvl = $vrlvl
610bDC**                 eval      slhand = $vhand
610bDC**                 eval      slside = svside
610bDC**                 eval      slstyp = $vstyp
610bDC**                 eval      sldisp = $vdisp
610bDC**                 eval      slsdef = svsdef
610bDC**                 eval      sldesg = svdesg
610bDC**                 eval      slactv = svactv
610bDC**                 eval      slbld = svbld
610bDC**
610bDC**                 eval      slpick = $vpick
610bDC**                 eval      slpseq = $vpseq
610bDC**                 eval      slslfd = svslfd
610bDC**                 eval      slslfd = 0
610bDC**                 eval      slrsrv = 'V'
610bDC**                 eval      slentd = today
610bDC**                 eval      slexpd = 0
610bDC**                 eval      slsdte = today
610bDC**                 time                    slstim
610bDC**                 eval      slprty = svprty
610bDC**                 eval      slstk1 = 0
610bDC**                 eval      slstk2 = 0
610bDC**                 eval      slstk3 = 0
610bDC**                 eval      slalc1 = 0
610bDC**                 eval      slalc2 = 0
610bDC**                 eval      slalc3 = 0
610bDC**                 eval      sltfr1 = 0
610bDC**                 eval      sltfr2 = 0
610bDC**                 eval      sltfr3 = 0
610bDC**                 eval      slpck1 = 0
610bDC**                 eval      slpck2 = 0
610bDC**                 eval      slpck3 = 0
610bDC**                 eval      slrcv1 = 0
610bDC**                 eval      slrcv2 = 0
610bDC**                 eval      slrcv3 = 0
610bDC***
610bDC**                 write     slrec                                79
610bDC**                 if        *in79
610bDC**                 eval      $prtn = '*PGMQ   '
610bDC**                 eval      error = *on
610bDC**                 exsr      zm72
610bDC**                 goto      endup3
610bDC**                 endif
610bDC** create vslot record.
610bDC**                 eval      vswhse = $vwhse
610bDC**                 eval      vswhdp = $vwhdp
610bDC**                 eval      vsaisl = $vaisl
610bDC**                 eval      vsloc = $vloc
610bDC**                 eval      vsrlvl = $vrlvl
610bDC**                 eval      vshand = $vhand
610bDC**                 eval      vsdisp = $vdisp
610bDC**                 eval      vspdis = svdisp
610bDC**                 eval      $cvcmd = '*CURCMD '
610bDC**                 call      @cvtdt
610bDC**                 parm                    $cvtdt
610bDC**                 eval      vscdte = $cvd8o
610bDC**                 time                    vsctim
610bDC**                 add       1             vsctim
610bDC**                 write     vsrec                                79
610bDC**                 if        *in79
610bDC**                 eval      $prtn = '*PGMQ   '
610bDC**                 eval      error = *on
610bDC**                 exsr      zm72
610bDC**                 goto      endup3
610bDC**                 endif
     *
     *     Initialize record fields before add.
     *
     C     ivskey        chain     invslot                            79
     *
     C                   if        *in79
610bMC                   eval      ivswhs = $slwhse
     C                   eval      ivspag = sheet
610bMC                   eval      ivsdsp = $sldisp
610bMC                   eval      ivssta = $slstat
610bMC                   eval      ivswhd = $slwhdp
610bMC                   eval      ivsasl = $slaisl
610bMC                   eval      ivsloc = $slloc
610bMC                   eval      ivslvl = $slrlvl
610bMC                   eval      ivshnd = $slhand
610bMC                   eval      ivsstp = $slstyp
610bMC                   eval      ivssid = $slside
640aAC                   eval      ivspck = $slpick
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivspdt = $cvd8o
     C                   time                    ivsptm
     C                   eval      ivsedt = $cvd8o
     C                   time                    ivsetm
     C                   eval      ivseby = $pteam
     C                   eval      ivscdt = 0
     C                   eval      ivsctm = 0
     C                   eval      ivscby = *blanks
     C                   eval      ivspex = pexp
     C                   eval      ivsitm = wsitem
     C                   eval      ivsqt1 = w3sqt1
     C                   eval      ivsqt2 = w3sqt2
     C                   eval      ivsqt3 = w3sqt3
     C                   eval      ivsadj = sadj
     C                   write     ivsrec                               79
     C                   if        *in79
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
610bDC**                 endif
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update record.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
     C                   if        womult = 'Y'
     C                   eval      ivowhs = ivswhs
     C                   eval      ivodsp = ivsdsp
     C                   eval      ivowhd = ivswhd
     C                   eval      ivoasl = ivsasl
     C                   eval      ivoloc = ivsloc
     C                   eval      ivolvl = ivslvl
     C                   eval      ivohnd = ivshnd
     C                   eval      ivopos = w4spos
     C                   write     ivorec
     C                   endif
     C     endup4        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update record.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     C     cwkey         chain     invscw                             79
     *
     C                   if        not *in79
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivwedt = $cvd8o
     C                   time                    ivwctm
     C                   eval      ivwcby = $pteam
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
     C                   eval      ivweby = $pteam
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
     *
     C                   write     ivwrec
     C                   endif
     *
     C                   eval      ovrrid = *off
     C                   eval      wtchk = *off
     C                   eval      woqt01 = 0
     C                   eval      woqt02 = 0
     C                   eval      woqt03 = 0
     *
     C     endup5        endsr
510d *----------------------------------------------------------------
510d *
510d *  ZZUPD6   Update record.
510d *
510d C     zzupd6        begsr
510d C                   eval      error = *off
610cAC                   exsr      scr07i
510dA
510d C     endup6        endsr
610cA*----------------------------------------------------------------
610cA*
610cA*  ZZUPD7   Update for screen 7.
610cA*
610cAC     zzupd7        begsr
     C                   eval      error = *off
     C                   exsr      scr03i
     C     endup7        endsr
HAL A*----------------------------------------------------------------
HAL  *
HAL A*  ZZUPD8   Update for screen 8.
HAL  *
HAL AC     zzupd8        begsr
HAL  C                   if        skipdate = ' '
     C                   exsr      zzupddate
HAL  C                   endif
     C                   eval      error = *off
     C                   eval      ovrrid = *off
     C                   eval      skipdate = ' '
     C                   eval      wtchk = *off
     C******             eval      refrsh = *on
     C******             eval      scode = '  '
     C                   eval      woqt01 = 0
     C                   eval      woqt02 = 0
     C                   eval      woqt03 = 0
     C******             exsr      scr02i
    A
HAL AC     endup8        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDF   Update records
     *
     C     zzupdf        begsr
     C                   eval      error = *off
     C     endupf        endsr
HAL A*----------------------------------------------------------------
HAL A*
HAL A*  ZZUPDDATE    Update INVSDATE
HAL A*
HAL AC     zzupddate     begsr

      /free
         calpentdate = 0;
      /end-free
     *   Convert date and save.
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w8date        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      calpentdate = $cvd8o
      /free
        calpdktexpd = 0;
        calpwhse = $pwhse;
        perrmsg = ' ';
        psessid = ' ';
        //#user  = ivttem;
        pdpcombo =  ' ';
        if calpentdate > 0;
        caldktexp(perrmsg: psessid: $pteam: pdpcombo:
                calpwhse: ivsitm: calpentdate: calpdktexpd);
        endif;
        chain (calpwhse: ivswhd: ivsdsp: ivsitm) invsdate;
          if %found(invsdate);
      /end-free
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivdedt = $cvd8o
     C                   time                    ivwetm
     C                   eval      ivdeby = $pteam
     c                   eval      ivddte = w8date
     c                   eval      ivdexp = calpdktexpd
     C                   update    ivdrec
     C                   else
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivdedt = $cvd8o
     C                   time                    ivwetm
     C                   eval      ivdeby = $pteam
     c                   eval      ivddte = w8date
     c                   eval      ivdexp = calpdktexpd
     C                   eval      ivdwhs = ivswhs
     C                   eval      ivddsp = ivsdsp
     C                   eval      ivdwhd = ivswhd
     C                   eval      ivdasl = ivsasl
     C                   eval      ivdloc = ivsloc
     C                   eval      ivdlvl = ivslvl
     C                   eval      ivdhnd = ivshnd
     C                   eval      ivdstp = ivsstp
     C                   eval      ivditm = ivsitm
     C                   eval      ivdsid = ivssid

     C                   write     ivdrec
     C                   endif
     C                   if        %error
     C                   goto      endupddate
     C                   endif

HAL  C     endupddate    endsr

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
     *
    DC**                 eval      $gexst = 'N'
    DC**   keyit         chain     piritem                            75
    DC**                 if        *in75
    MC                   if        #toititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        ssbflg = *off and
     C                             #toitflg1 = 'N'
    D*R         ITFLG1    IFEQ 'N'
     C                   eval      *in92 = *on
     C                   endif
     C                   if        ssbflg = *off and
     C                             #toitflg2 = 'N'
    D*R         ITFLG2    IFEQ 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
    MC                   if        #toitum2 = *blanks
    MC                   eval      *in92 = *on
    MC                   endif
    MC                   if        #toitum3 = *blanks
    MC                   eval      *in93 = *on
    MC                   endif
     *
    MC     #toitum1      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w3um1 = umshrt
     C                   else
     C                   eval      w3um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
    MC     #toitum2      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w3um2 = umshrt
     C                   else
     C                   eval      w3um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
    MC     #toitum2      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w3um3 = umshrt
     C                   else
     C                   eval      w3um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
500cA*----------------------------------------------------------------
    A*----------------------------------------------------------------
    A*                     DRI SUBROUTINES
    A*----------------------------------------------------------------
    A*----------------------------------------------------------------
     *
    A*----------------------------------------------------------------
    A*  clr$item  Clear $item data structure fields
    A*----------------------------------------------------------------
     *
    AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$license  Clear $license data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = e$emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

610bA*----------------------------------------------------------------
610bA*  clr$slot  Clear $slot data structure fields
610bA*----------------------------------------------------------------
610bA
610bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr
     *
    A*----------------------------------------------------------------
    A*  zzzdricop  Call DRICOP
    A*----------------------------------------------------------------
     *
    AC     zzzdricop     begsr
     C                   eval      error = *off
      *
     C                   select
610bAC                   when      $dricommand = '*SLOT'
610bAC                   eval      $dridata = $slot
610bAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
610aAC                   when      $dricommand = '*LICENSE'
610aAC                   eval      $dridata = $license
610aAC                   eval      $dridata2 = $license2
     C                   endsl
     *
     C                   if        $dricommand = '*ITEM'
610aAC                             or $dricommand = '*SLOT'
610aAC                             or $dricommand = '*LICENSE'
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
     *
     C                   select
     *
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
     *
     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif
     *
     C                   endsl
     *
     C                   select
610bAC                   when      $dricommand = '*SLOT'
610bAC                   eval      $slot = $dridata
610bAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
610aAC                   when      $dricommand = '*LICENSE'
610aAC                   eval      $license = $dridata
610aAC                   eval      $license2 = $dridata2
     C                   endsl
     *
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

510eA*---------------------------------------------------------------
510eA*  Retrieve number of pick slots for item and accumulate
510eA*  number of pick slots assigned to item.
510eA*
510eAC     chkpck        begsr
510eAC     itkey         chain     itemmsc                            79
510eAC                   if        *in79
510eAC                   eval      imnrpk = 1
510cAC                   endif
510eA*
510eA*    Accumulate number of pick slots assigned to item.
510eA*
510eAC                   eval      k3stat = 'A '
510eAC                   eval      k3pick = 'Y '
510e C     keys3         setll     slot3
510e C                   z-add     0             nbrpck
510e C                   dow       forevr = forevr
510e C     keys3         reade     slot3                                  79
     *
510e C                   if        *in79
510e C                   leave
510e C                   else
510e C                   add       1             nbrpck
510e C                   iter
510e C                   endif
510e C                   enddo
510e *
510eAC                   endsr

610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------
610bA*  License Plate Tracking Routines
610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------

610bA*----------------------------------------------------------------
610bA*  ZZZCLR$LT210  -  Clear LT210 parameters.
610bA*----------------------------------------------------------------
610bA
610bAC     ZZZCLR$LT210  begsr

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

610bA*----------------------------------------------------------------
610bA*  ZZZCALL$LT210  -  Call LT210 program.
610bA*----------------------------------------------------------------
610bA
610bAC     ZZZCALL$LT210 begsr

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
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   if        %error
     C                   eval      $treturn = $treturn
     C                   endif
     C                   endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
