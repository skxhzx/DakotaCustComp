      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CW112     Catch weight maint - Change
     *  22 July 1999
     *  Roxanne Harrison
     *  Created using WL112
     *  CHANGED TO ONLY USE SC3
     *
     *  SK112 - 1.02
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *
409 A*    07/07/98  HNK
     *      - Revised to page up after the subfile page is full.
     *
412aA*    08/12/99  HNK
     *      - Quantity and Stop number added on screen 3.
412BA*    08/23/99  RH
     *      - Add LBL# to PARMS, key for ORDC1 changed.
     *      - Change to use LABEL file.
412BA*    08/23/99  HNK
     *      - Accept variance on catch weight.
     *
412cA*    08/25/99  DAS  4.12c
     *      - Added command *CHANGEP. This command is sent from PT132
     *        when an error was found during posting. When this
     *        command is sent, indicator 92 is set on to disable F12.
     *      - Revised ZZUSUB to check record count.
     *
412dA*    08/30/99  HNK  4.12d
     *      - PIRITEM file added.
     *      - Item description added on screen.
     *
413 A*    10/25/99  DAS  4.13
     *      - Recompiled because of changed to CW112FM.
414aA*    07/10/00  RH   4.14a
     *      - Add code to force individual F20 to be taken for each
     *        warning condition.
416aA*    12/20/01  RH   4.16a
     *      - Make CW positive if negative CW was entered.
416bA*    01/22/02  RH   4.16b
     *      - Do not allow F20 to override error for # of catch weight
     *        entered if called when closing trans. (*92 = ON)
416cA*    07/02/02  RH   4.16c
     *      - Recompiled, ITEMMSC changed.
416dA*    07/29/02  MLB  4.16d
     *      - FIX: Recompile program. Changed size of W1SEQ to 3,0
     *             from 2,0. No program changes.
     *
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
417bA*    08/14/03  RH   4.17b
     *      - FIX: Do not write ORDC record if weight is 0.
417cA*    08/28/03  RH   4.17c
     *      - ENH: Add route to screen 3.
417dA*    03/19/04  MLB  4.17d
     *      - Fix: Revise program to not allow catchwgts entered
     *        to exceed quantity picked.
     *
500 A*    06/17/05  MLB  5.00
     *      - Fix: Revise ZZCHKT to not allow catchwgts entered
     *        to exceed quantity picked when OPICW = 'N' - Individual
     *        catchwgt entry not required.
500aA*    06/20/05  MLB  5.00a
     *      - Enh: Added client custom code support to program.
500bA*    06/24/05  MLB  5.00b
     *      - Enh: Revise ZZCHK3 to send message PT13021 when entered
     *        catchweight is out of range. Pgm was sending PT13019
     *        for single weight entered when out of range. Added
     *        msg routine ZM21.
500cA*    07/15/05  MLB  5.00c
     *      - Enh: Revise program to pass back number of catch-
     *        weights entered by user.
     *
510 A*    01/30/07  TLJ  5.10
     *      - Fix: Total Catch Weight and Qty at top of screen
     *        were being doubled when F5 was pressed, due to not
     *        being initialized in SCR03I. Also fixed error on F5
     *        not clearing/resetting seq correctly.
     *
520 A*    11/03/08  MLB/DAS  5.20
     *      - Fix: Revised routine ZZFIL3 to clear PRG1C / PRG2C.
     *        These fields were not being cleared when an item did
     *        not have any item variance overrides.
     *
520 A*    02/05/09  CWM/MLB 5.20  01/25  02/02
     *      - Enh: Added support for new extended stop number.
     *        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     *
520aA*    03/20/09  JCJ  5.20a
     *      - Enh: Converted to rpg4
     *
520bA*    04/08/09  JCJ  5.20b
     *      - Enh: Do not allow F20 override if catch weight count is
     *             zero.
     *
530 A*    02/02/10  JCJ  5.30
     *      - Enh: Added client location to Get Client.
     *
530a *    05/13/10  GJA  5.30a
     *      - Enh: change UCI to be option driven.
     *
530bA*    05/13/10  JCJ  5.30b
     *      - Fix: change ZZCHKT to use OPICW instead of OPWRNC.
     *      - Enh: change to use new option values for OPICW.
     *      - Enh: change to use new option values for OPWRNC.
     *      - Enh: added field mode to identify closing mode (PT132)
     *      - Enh: added $pcmd = '*NOCHECK'
     *
530cA*    06/15/10  JCJ  5.30c
     *      - Fix: Force at least on catch weight entry at close.
     *
530dA*    06/21/10  JCJ  5.30d
     *      - Fix: If catch weight count is one, total catch weight
     *             has to be greater then 0.
     *
640aA*    04/14/11  JCJ  6.40a
     *      - Enh: Changed format to CW11201.
     *      - Added UOM to screen.
     *
640bA*    09/23/12  JCJ  6.40b
     *      - Enh: Changed format to CW11202.
     *
640cA*    12/28/12  JCJ  6.40c
     *      - Fix: Commented out 530bX mode to allow variance checking
     *
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
650bA*    10/30/14  RH   6.50b
     *      - Enh: Changed IF to WHEN statement for DRYA CW tolerance
     *
700aA*    03/24/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
730aA*    08/16/19  DAS  7.30a
     *      - Revised to not allow change for UCI Selection item.
730eA*    08/17/19  ???  7.30e (may be related to 730a)
     *      - Get Item Information
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports, Ltd.
     *
EI  A*    06/30/06  MLB  EI
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP to not set on *in92. *in92 prevents user
     *        from exiting and overriding any warnings.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Tiffin Paper Co.
TPC A*    08/30/07  RH   TPC
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP to not set on *in92. *in92 prevents user
     *        from exiting and overriding any warnings. Will allow
     *        total catch weight to be entered, not one for each qty.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Tiffin Paper Co.
RNZ A*    04/08/09  JCJ  RNZ
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP to not set on *in92. *in92 prevents user
     *        from exiting and overriding any warnings. Will allow
     *        total catch weight to be entered, not one for each qty.
     *
SVL  *----------------------------------------------------------------
SVL  *  Client Custom Revisions: Saval
SVLaA*    04/06/09  RH   SVLa
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP & IMWRNC=Y, to NOT set on *in92 Will allow
     *        total catch weight to be entered, not one for each qty.
     *
CWD  *----------------------------------------------------------------
CWD  *  Client Custom Revisions: Cash-Wa
CWD A*    02/02/10  JCJ  CWD
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP & IMWRNC=Y, to NOT set on *in92 Will allow
     *        total catch weight to be entered, not one for each qty.
     *
DRY  *----------------------------------------------------------------
DRY  *  Client Custom Revisions: Dairyland
DRY A*    02/18/10  JCJ  DRY
     *      - Revised program when called from PT132 with $pcmd
     *        *CHANGEP & IMWRNC=Y, to NOT set on *in92 Will allow
     *        total catch weight to be entered, not one for each qty.
     *
DRYaA*    01/30/14  RBD  DRYa
     *      - Allow F12 unconditionally.
     *      - Do not allow override of c/w tolerance errors.
     *      - When c/w is entered, if it doesn't fall within individual
     *        c/w tolerance, check to see if it plus the sum of any
     *        other c/w's entered fall within the total c/w tolerance.
     *        For example, if qty picked = 5, they may enter 1 c/w or
     *        multiple c/w's, just as long as the sum of them all falls
     *        within the total c/w tolerance.
     *
DRYbA*    11/18/20  JCJ  DRYb
     *      - Removed DRYa mod per Kelly.
     *      - Changed the DRYa to FSHa.
     *      - Original version is in PIR730.
     *
PAK  *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
PAK  *    04/18/07  RBD  PAK
     *      - If catchweight has UCI label, bypass weight $pcmd
     *        variance checks.
     *
PAKa *    04/28/07  DAS  PAKa    (removed  5.30a)
     *      - Revised ZZFLG to always set UCIFLG *ON which will
     *        prevent catchweight variance from being checked.
     *
NCSa *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas
NCSa *    04/18/11  JCJ  NCSa
     *      - Do not performe total catch weight variance.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foodservice
GFC A*    08/05/11  MLB  GFC
     *      - Revised program to not allow individual catchwgts to be
     *        entered that are greater than 9,999.99 when the RHRTE
     *        field starts with I or H.  These are reg. or Hotshot
     *        transfer orders and the H&S transfer catchwgt detail
     *        file does not allow wgts greater than 9,999.99.
GFCaA*    09/15/11  MLB  GFCa
     *      - Revision to mod GFC above. Need additional changes to
     *        prevent user from changing weights in subfile to a wgt
     *        greater than 9,999.99 lbs.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
CBIaA*    10/06/03  RH   CBIa
     *      - ENH: Get OHMISC, if type E=Export, allow total CW entry.
CBIbA*    03/31/04  DAS  CBIb
     *      - ENH: Revised ZZINZ2 to call ZZUPD3 to do range check on
     *             existing catchweights.
CBIcA*    10/04/04  RH   CBIc
     *      - ENH: Change ZZCHKT don't allow F20 to override 0 total
     *             weight.
CBIdA*    06/18/14  DAS  CBId
     *      - ENH: do not perform catch weight count check for Cheney
     *        GWB. No longer needed our system options CW count will
     *        handle this.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
FSH A*    10/30/14  RH   FSH
     *      - ENH: Not check individual cw only total tolerance.
FSHaA*    11/18/29  JCJ  FSHa
     *      - ENH: Changed DRYa to FSHa mod.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640aD **cw112fm   cf   e             workstn
640bD **cw11201   cf   e             workstn
700aDF*cw11202   cf   e             workstn
700aMFcw11203   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     *AYOUTH UF  E           K        DISK                      A
     *           LHREC                             KRENAMERECORD
     Fordc1     uf a e           k disk
     F                                     rename(ocrec:record2)
     Fwarehs    if   e           k disk
405 AFoptions   if   e           k disk
412BMFLabel     if   e           k disk
412BD*ABEL7  IF  E           K        DISK
     Fitemmsc   if   e           k disk
412dAFpiritem   if   e           k disk
417cAFrtehed    if   e           k disk
CBIaAFordh      if   e           k disk
PAK AFucicw9    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
DRYaDD*desc            s             50    dim(8) ctdata perrcd(1)
730aDD*desc            s             50    dim(9) ctdata perrcd(1)
730aMD desc            s             50    dim(10) ctdata perrcd(1)
700aAD cmdln           s             79    dim(3)ctdata perrcd(1)
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
     D @getcl          c                   const('GETCLIENT')
500aA*
EI  A /COPY QCOPYSRC,ID#EI
TPC A /COPY QCOPYSRC,ID#TPC
RNZ A /copy qcopysrc,id#renzi
SVLaA /copy qcopysrc,id#saval
CWD A /copy qcopysrc,id#cashwa
DRY A /copy qcopysrc,id#dairyla
PAK A /copy qcopysrc,id#packers
NCSaA /copy qcopysrc,id#nichola
GFC A /copy qcopysrc,id#glazier
CBIdA /COPY QCOPYSRC,ID#CHENEY
CBIdA /COPY QCOPYSRC,Id#CHENEYG
CBIdA /COPY QCOPYSRC,Id#CHENEYO
CBIdA /COPY QCOPYSRC,Id#CHENEYR
FSH A /copy qcopysrc,id#fischer

730aA*----------------------------------------------------------------
730aA*  DRI parameters
730aA*----------------------------------------------------------------
730aA
730aA /COPY *libl/qcopysrc,C#DRIPARMS
730aA
500aA*
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
730aA /COPY *libl/qcopysrc,C#ITEM
650aA /COPY *libl/qcopysrc,C#CWLOG
650aAD savever#        s                   like($cwver#)
CBIa *----------------------------------------------------------------
CBIa D                 ds
CBIa D  dsmisc                 1     20
CBIa D  dssdte                 1      8
CBIa D  dsspcl                 9     11
CBIa D  dsrpck                12     12
CBIa D  dsdoor                13     14
CBIa D  dsmeat                15     15
CBIa D  dscode                16     16
CBIa *
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
     D  $ptrn#                22     28  0
     D  $pitem                29     43
     D  $pseq#                44     48  0
412B D  $plbl#                49     55  0
500cAD  $pcw#                 56     58  0
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
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
410aA*  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
410 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPICW   -  Individual catch weight entry (Y,N).
530aA*    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
530aAD  opuci                 36     36
     D  optend               117    117
700aA*
700aAD opdataIM        ds
700aAD  opwum                 58     72
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
410 A*
410 AD  ertcwt                 1      5p 2
410 AD  erlrng                 6     10p 2
410 AD  erhrng                11     15p 2
410 AD  errg1c                16     17p 1
410 AD  errg2c                18     19p 1
410 AD  erexwt                20     24p 2
FSHaAD  erum                  25     26
FSHaAD  erilrng               27     31p 2
FSHaAD  erihrng               32     36p 2
     *
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
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
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
650aA /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * Work Variable
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
700aAD CnvWgt          s                   like(w1addw)
     D comand          s              5  0
     D cweck           s              1
     D cwtck           s              1
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D exwgt           s              9  2
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
CBIbAD inzerr          s              1
CBIbAD inzflg          s              1
700aAD kgs2lbs         c                   2.20462262
700aAD KiloLbs         s              1
     D lstseq          s                   like(ocseq)
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D posrec          s              4  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svaddw          s              7  0
     D svcw#           s              7  0
     D svtcw           s              9  2
     D taddw           s              7  2
GFC AD tfrorder        s              4    inz('*NO ')
     D twtck           s              1
     D warn            s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D wttcw           s              7  2
CWD AD cashwak         c                   const('KEARNEY')
530bAD @Caller         S             10
530bAD @Counter        S             15  5
530bAD opicwflag       s              1
530bAD opwrncflag      s              1
530bAD mode            s              8
530bAD mode2           s              8
530bAD uciflg          s              1    inz('0')
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
650aAD e$whse          s              3  0
650aAD e$emp#          s              5  0
650aAD e$fnam          s             15
650aAD e$init          s              1
650aAD e$lnam          s             20
650aAD e$whdp          s              5
650aAD e$styp          s              1
650aAD e$shft          s              6
650aAD e$crew          s              6
650aAD e$nhrs          s              3  1
650aAD e$rtn           s              8
650aAD e$bpu           s              1
650aAD e$lng           s              2
730aAD drierr          s               n
730aAD chk4err         s               n
730aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
412cA*              *CHANGEP - Change during post from PT132.
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
530bA*
530bA*  return calling program
530bA*
530bAC     UI866P        Plist
530bAC                   Parm                    @Caller
530bAC                   Parm                    @Counter
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
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
CBIbAc                   if        client = cheney
CBIbAC                   eval      error = inzerr
CBIbAc                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
500cA*
500cA*   Load number of catchwgts entered back to calling pgm.
500cAC                   z-add     wocw#         $pcw#
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
730aAC                   exsr      zzzdriclose
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
     C                   select
     *
     **         NXTSCR    WHEQ '01 '
     *R                   EXFMTSCREEN1
     *
     *R         NXTSCR    WHEQ '02 '
     *R                   EXFMTSCREEN2
     *
     C                   when      nxtscr = '03 '
     C                   exsr      sfldsp
     C                   read      head1                                  50
     *
     C                   endsl
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
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
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
410 AC                   eval      ovrrid = *off
510 AC                   eval      wotcw = 0
510 AC                   eval      wocw# = 0
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
520 AC                   exsr      zzfgts
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC1
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*CANCEL '$PRTN
     *R                   GOTO ENDSC1
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
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC2
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
     *R         *LOVAL    SETLLRECORD
     *R         $PCMD     IFEQ '*ADD    '
     *R                   MOVE '01 '     NXTSCR
     *R                   ELSE
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   ENDIF
     C                   eval      $prtn = '*CANCEL '
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
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     redspl        cabeq     *on           endsc2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     *R         *LOVAL    SETLLRECORD
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
700aA*
700aA*  Test for F7 - kilograms/Pounds toggle
700aa*
700aAC                   if        *inkg
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W1KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W1KgLb  = 'Lbs'
700aAC                   endif
700aAC                   select

700aAC                   when      KiloLbs = 'K'
700aAC                   eval      cmdln1 = cmdln(2)

700aaC                   when      KiloLbs = 'P'
700aaC                   eval      cmdln1 = cmdln(1)

700aaC                   endsl
700aaC                   goto      endsc3
700aaC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     *R         *LOVAL    SETLLRECORD
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
700aA*     Setup converted weight field.
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
530bA*
530bAC                   if        $pcmd = '*CHKNONE'
530bAC                   exsr      zzchkt
530bAC     error         cabeq     *on           endsc3
530bAC                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
530 AC                   parm                    cliloc           10
500aA*
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
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL1                79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz

530bA * Determine Calling program

530bAC                   Eval      @Counter = 4
530bAC                   Eval      @Caller  = *Blanks

530bAC                   Call      'UI866'       UI866P

650aA /free
650aA    getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA            e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA            e$bpu: e$lng);
650aA /end-free
530bAC                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
X12  C                   eval      *in85 = *on
     C                   write     detail1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
510 AC                   eval      lstseq = 0
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
510 AC                   exsr      zsclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     **                   WRITEOPTREC
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   if        reccnt > 12
     C                   eval      posrec = reccnt
     C                   endif
     C                   eval      recno = posrec
     C                   write     head1
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
     *----------------------------------------------------------------
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
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
410 A*----------------------------------------------------------------
500bM*   PT13020  # of catch weights entered must = Quantity picked.
410 A*
410 AC     zm20          begsr
410 AC                   eval      #msgid = 'PT13020'
410 AC                   eval      #msgtp = '*DIAG  '
410 AC                   movea     errmsg        $md
410 AC                   exsr      zmpmsg
410 AC                   endsr
410 A*----------------------------------------------------------------
500bM*   PT13019  Warning: Entered catch weight not within +/- range.
410 A*
410 AC     zm19          begsr
410 AC                   eval      #msgid = 'PT13019'
410 AC                   eval      #msgtp = '*DIAG  '
410 AC                   movea     errmsg        $md
410 AC                   exsr      zmpmsg
410 AC                   endsr
500bA*----------------------------------------------------------------
500bM*   PT13021  Warning: Entered catch weight not within +/- range.
500bA*
500bAC     zm21          begsr
500bAC                   eval      #msgid = 'PT13021'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md
500bAC                   exsr      zmpmsg
500bAC                   endsr
     *----------------------------------------------------------------
FSHaA*   PT13024  C/W not within xx range x - x or total range x - x.
FSHaA*
FSHaAC     zm24          begsr
FSHaAC                   eval      #msgid = 'PT13024'
FSHaAC                   eval      #msgtp = '*DIAG  '
FSHaAC                   movea     errmsg        $md
FSHaAC                   exsr      zmpmsg
FSHaAC                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
413g *   CWTCK Flags are used to force F20 for each test
413g *   Values: Flag = 0 Do check.
413g *           Flag = 1 Check was done, ok.
413g *           Flag = 2 Warning condition.
413g *
     C                   eval      error = *off
FSHaAC                   eval      taddw = 0
     *
     *
416a *
416a *   Make catch weight positive # if negative was entered.
416a C                   if        w1addw < *zero
416a C                   eval      w1addw = w1addw * -1
416aAC                   endif
416a *
     *
     *   Verify catch weight add.
     *
     C                   if        w1addw <> *zero
414aD*R         OVRRID    ANDEQ*OFF
414aA*
414aAC                   if        svaddw <> w1addw
414aAC                   eval      cwtck = *off
414aAC                   endif
414a *
414aAC                   if        cwtck = '2'  and
414aAC                             ovrrid = *on
414aAC                   eval      cwtck = *on
414aAC                   endif
GFC A*
GFC AC                   if            client   = Glazier
GFC AC                             and tfrorder = '*YES'
GFC AC                             and w1addw   > 999999
GFC AC                             and ovrrid   = '1'
GFC A*      Make this a hard-error for Transfer orders.
GFC AC                   eval      cwtck = '0'
GFC AC                   eval      ovrrid = '0'
GFC AC                   endif
GFC A*
414a *
414aMC                   if        cwtck <> '1'
414aAC                   eval      cwtck = *on
     *
     *     Verify catch weight is within range.
     *
     C                   if        w1addw < 0  or
     C                             w1addw > 9999999
GFC A*
GFC AC                             or client = Glazier
GFC AC                             and tfrorder = '*YES'
GFC AC                             and w1addw > 999999
GFC A*
     C                   eval      error = *on
414aAC                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
GFC A*
GFC AC                   if           client = Glazier
GFC AC                             and tfrorder = '*YES'
GFC AC                             and w1addw > 999999
GFC A*      Make this a hard-error for Transfer orders.
GFC AC                   eval      cwtck = '0'
GFC AC                   eval      ovrrid = '0'
GFC AC                   movel     '999999'      erto
GFC AC                   else
GFC A*
     C                   movel     '9999999'     erto
GFC AC                   endif
GFC A*
     C                   exsr      zm0112
     C                   endif
     *
PAK A*     Set UCI flag ... if flag is on, bypass variance check
     *
PAK AC                   exsr      zzflg
700aA * at this point we need to do any necessary weight conversions
700aA * and use the converted weight field
700aAC                   exsr      zzcnvwgt
     *
     *     Check individual CW if variance check = Y.
PAK A*     and UCI flag is off.
530bD ***                if        opwrnc = 'Y'  and
530bD ***                          opicw = 'Y'
530bMC                   if        opwrncflag = 'Y'
530bx ***                          and opicwflag = 'Y'
PAK AC                             and uciflg = *OFF
700aDC*    w1addw        div       100           taddw
700aMC     cnvwgt        div       100           taddw
     *
412 AC                   if        lvskp = *off  and
412 AC                             taddw < ilrng

FSHaA*  For specified clients, when c/w entered is outside the tolerance
FSHaA*  for individual c/w, check to see if the sum of the c/w's entered
FSHaA*  is within the total tolerance, if so, allow it.
650bAC                   select
FSHaAC                   when      client = fischerfoods
FSHaAC                   exsr      zztotl
FSHaAC                   exsr      zzchkt1
FSHaAC                   if        error = *off
FSHaAC                   eval      errmsg = *blanks
FSHaAC                   goto      totCWokay
FSHaAC                   endif
650bMC                   endsl

412 A***        TADDW     ORGT IHRNG
     C                   eval      error = *on
414aAC                   eval      warn = *on
414aAC                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   eval      erlrng = ilrng
412 AC                   if        hvskp = *on
412 AC                   eval      erhrng = 0
412 AC                   else
412 AC                   eval      erhrng = ihrng
412 AC                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
500bAC                   eval      erexwt = lbuwgt
412 D*R                   Z-ADDOPRG1C    ERRG1C
412 D*R                   Z-ADDOPRG2C    ERRG2C
500bD*R                   EXSR ZM19
500bMC                   exsr      zm21
     C                   endif
     *
412 A****       HVSKP     WHEQ *OFF
412 A***        TADDW     IFLT ILRNG
412 AC                   if        hvskp = *off  and
412 AC                             taddw > ihrng

FSHaA*  For specified clients, when c/w entered is outside the tolerance
FSHaA*  for individual c/w, check to see if the sum of the c/w's entered
GSFaA*  is within the total tolerance, if so, allow it.
650bAC                   select
FSHaAC                   when      client = fischerfoods
FSHaAC                   exsr      zztotl
FSHaAC                   exsr      zzchkt1
FSHaAC                   if        error = *off
FSHaAC                   eval      errmsg = *blanks
FSHaAC                   goto      totCWokay
FSHaAC                   endif
650bMC                   endsl

     C                   eval      error = *on
414aAC                   eval      warn = *on
414aAC                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
412 AC                   if        lvskp = *on
412 AC                   eval      erlrng = 0
412 AC                   else
412 AC                   eval      erlrng = ilrng
412 AC                   endif
     C                   eval      erhrng = ihrng
412 AC     prg1c         mult      100           errg1c
412 AC     prg2c         mult      100           errg2c
500bAC                   eval      erexwt = lbuwgt
412 D*R                   Z-ADDOPRG1C    ERRG1C
412 D*R                   Z-ADDOPRG2C    ERRG2C
500bD*R                   EXSR ZM19
500bMC                   exsr      zm21
     C                   endif
     *
     *
410 AC                   endif
     *
FSHaAC     totCWokay     tag
     *
     C                   endif
414aAC                   endif
     *
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
   7 C                   leave
     C                   endif
     *
416a *   Make catch weight positive # if negative was entered.
416a C                   if        w1cwgt < *zero
416a C                   eval      w1cwgt = w1cwgt * -1
416aAC                   endif
416a *
     *
     C                   eval      *in19 = *off
     C                   eval      *in20 = *off
     C                   eval      *in39 = *off
     C                   eval      *in40 = *off
GFCaA*
GFCaAC                   if            client = Glazier
GFCaAC                             and tfrorder = '*YES'
GFCaAC                             and w1cwgt > 999999
GFCaA*
GFCaAC                   eval      error = *on
GFCaAC                   eval      cwtck = '2'
GFCaAC                   eval      *in19 = *on
GFCaAC                   eval      *in39 = *on
GFCaAC                   eval      errmsg = *blanks
GFCaAC                   movel     desc(1)       erfld
GFCaAC                   movel     '0'           erfrom
GFCaA*
GFCaA*      Make this a hard-error for Transfer orders.
GFCaAC                   eval      cwtck = '0'
GFCaAC                   eval      ovrrid = '0'
GFCaAC                   movel     '999999'      erto
GFCaAC                   exsr      zm0112
GFCaAC                   endif
GFCaA*
     *
     *
     *      Verify right definition.
     *
     C                   eval      *in85 = *on
     C                   update    detail1
     C                   if        posrec = 0
     C                   if        *in38  or
     C                             *in39
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
414aA*   Save screen fields.
414aAC                   eval      svaddw = w1addw
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
413g *   CWECK, TWTCK Flags are used to force F20 for each test
413g *   Values: Flag = 0 Do check.
413g *           Flag = 1 Check was done, ok.
413g *           Flag = 2 Warning condition.
413g *
     C                   eval      error = *off
FSHaA*
FSHaA*   For specified clients, add c/w just entered to total subfile c/w.
650bAC                   select
FSHaAC                   when      client = fischerfoods
FSHaAC                   eval      wotcw = wotcw + taddw
650bMC                   endsl
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
530cAC                   if        mode2 = '*CHKNONE'
530cAC                             and wocw# = 0
530dAC                             or mode2 = '*CHKNONE'
530dAC                             and wocw# = 1
530dAC                             and wotcw = 0
530cAC                   eval      cweck = *off
530cAC                   eval      error = *on
530cAC                   eval      *in28 = *on
530cAC                   eval      *in08 = *on
530cAC                   eval      errmsg = *blanks
530cAC                   z-add     wocw#         ertcw#
530cAC                   eval      erqpck = lbqpck
530cAC                   exsr      zm20
530cAC     error         cabeq     *on           enderr
530cAC                   endif
530bD ***                if        opwrnc = 'Y'
530bMC                   if        opicwflag = 'Y'
500 D*          OPICW     ANDEQ'Y'
414aD*R         OVRRID    ANDEQ*OFF
414aA*
414aAC                   if        svcw# <> wocw#
414aAC                   eval      cweck = *off
414aAC                   endif
414a *
414aAC                   if        cweck = '2'  and
414aAC                             ovrrid = *on  and
530bMC                             mode = 'Closing'
530bD ***                          not *in92
414aAC                   eval      cweck = *on
414aAC                   endif
414a *
414aMC                   if        cweck <> '1'
414aAC                   eval      cweck = *on
414aA*
     C                   if        wocw# <> lbqpck
410 AC                   eval      posrec = 1
410 AC                   eval      error = *on
520bM*    Nbr catchwgts entered cannot exceed quantity picked and
520bA*    at least one catch weight must be entered.
417dAC                   if        wocw# > lbqpck
520bAC                             or wocw# = 0
417dAC                   eval      cweck = *off
417dAC                   else
414aAC                   eval      cweck = '2'
417dAC                   endif
410 AC                   eval      *in28 = *on
410 AC                   eval      *in08 = *on
410 AC                   eval      errmsg = *blanks
410 AC                   z-add     wocw#         ertcw#
410 AC                   eval      erqpck = lbqpck
410 AC                   exsr      zm20
410 AC                   endif
414aAC     error         cabeq     *on           enderr
410 AC                   endif
414aAC                   endif
     *
410 A*
410 A*
410 A*     Compare total catchweight to expected catchweight
410 A*
NCSaAC                   select
NCSaAC                   when      client = nicholas
FSHaA ****                         or client = Fischerfoods
NCSaA*     do no total variance check
NCSaAC                   other
530bD ***                if        opwrnc = 'Y'
530bMC                   if        opwrncflag = 'Y'
640cD ***                          and opicwflag = 'N'
414aD*R         OVRRID    ANDEQ*OFF
414aA*
414aAC                   if        svtcw <> wotcw
414aAC                   eval      twtck = *off
414aAC                   endif
414a *
CBIcAc                   Select
CBIcAc                   when      client = cheney
CBIcAC                   if        twtck = '2'  and
CBIcAC                             ovrrid = *on  and
CBIcAC                             wotcw > 0
CBIcAC                   eval      twtck = *on
CBIcAC                   endif
CBIcAc                   other
414aAC                   if        twtck = '2'  and
414aAC                             ovrrid = *on
414aAC                   eval      twtck = *on
414aAC                   endif
CBIcAc                   endsl
414a *
414aMC                   if        twtck <> '1'
414aAC                   eval      twtck = *on
414aA*
     *
412 AC                   if        lvskp = *off  and
412 AC                             wotcw < lwrng
     C                   eval      posrec = 1
     C                   eval      error = *on
414aAC                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
412 AC                   if        hvskp = *on
412 AC                   eval      erhrng = 0
412 AC                   else
     C                   eval      erhrng = hirng
412 AC                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
500bAC                   eval      erexwt = exwgt
410 D*                    Z-ADDOPRG1C    ERRG1C
410 D*                    Z-ADDOPRG2C    ERRG2C

FSHaAC                   if        client = Fischerfoods
FSHaAC                   eval      ertcwt = taddw
FSHaAC                   eval      erum = lbucod
FSHaAC                   eval      erilrng = ilrng
FSHaAC                   eval      erihrng = ihrng
FSHaAC                   exsr      zm24
FSHaAC                   else

     C                   exsr      zm19

FSHaAC                   endif
     C                   endif
     *
412 AC                   if        hvskp = *off  and
412 AC                             wotcw > hirng
PAK AC                             and uciflg = *off
     C                   eval      posrec = 1
     C                   eval      error = *on
414aAC                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
412 AC                   if        lvskp = *on
412 AC                   eval      erlrng = 0
412 AC                   else
     C                   eval      erlrng = lwrng
412 AC                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
500bAC                   eval      erexwt = exwgt
410 D*                    Z-ADDOPRG1C    ERRG1C
410 D*                    Z-ADDOPRG2C    ERRG2C

FSHaAC                   if        client = fischerfoods
FSHaAC                   eval      ertcwt = taddw
FSHaAC                   eval      erum = lbucod
FSHaAC                   eval      erilrng = ilrng
FSHaAC                   eval      erihrng = ihrng
FSHaAC                   exsr      zm24
FSHaAC                   else

     C                   exsr      zm19

FSHaAC                   endif
     C                   endif
     *
414aAC     error         cabeq     *on           enderr
414aAC                   endif
     *
410 AC                   endif
414aAC     enderr        tag
414aA*   Save screen fields.
414aAC                   eval      svcw# = wocw#
414aAC                   eval      svtcw = wotcw
NCSaAC                   endsl
     *
410 AC                   endsr
     *----------------------------------------------------------------
FSHaA*
FSHaA*  ZZCHKT1  Compare total c/w to expected c/w
FSHaA*
FSHaAC     zzchkt1       begsr
FSHaA*
     C                   eval      error = *off
     C                   eval      wotcw = wotcw + taddw
     *
     C                   if        opwrncflag = 'Y'
     *
     C                   if        svtcw <> wotcw
     C                   eval      twtck = *off
     C                   endif
     *
     C                   if        twtck = '2'  and
     C                             ovrrid = *on
     C                   eval      twtck = *on
     C                   endif
     *
     C                   if        twtck <> '1'
     C                   eval      twtck = *on
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   eval      ertcwt = taddw
     C                   eval      erum = lbucod
     C                   eval      erilrng = ilrng
     C                   eval      erihrng = ihrng
     C                   exsr      zm24
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                             and uciflg = *off
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   eval      erexwt = exwgt
     C                   eval      ertcwt = taddw
     C                   eval      erum = lbucod
     C                   eval      erilrng = ilrng
     C                   eval      erihrng = ihrng
     C                   exsr      zm24
     C                   endif
     *
     C                   endif
     *
     *   Save screen fields.
     C                   eval      svcw# = wocw#
     C                   eval      svtcw = wotcw
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
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
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     *
     C                   select
     *
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
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
     *
     C     zzcmd3        begsr
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
     *
     *     Build code.
     *
     C                   select
     *
     *
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

DRYbD *                  if        *inku
DRYbD *                            and client = dairyland
DRYbD *                  eval      error = *on
DRYbD *                  eval      errmsg = desc(9)
DRYbD *                  exsr      zm0105
DRYbD *                  goto      endcm3
DRYbD *                  endif
410 A*
410 A*      F20 - Accept Warning.
410 A*
410 AC                   if        *inku
410 AC                   eval      ovrrid = *on
414aAC                   else
414aAC                   eval      ovrrid = *off
410 AC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
700aA*----------------------------------------------------------------
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
700aA     when opwum = 'KGS'
700aA      or opwum = 'kgs'
700aA      or opwum = 'Kgs';
700aA       if KiloLbs = 'K';
700aA         eval cnvwgt = w1addw;
700aa       else;
700aA         eval(h) cnvwgt = w1addw / kgs2lbs;
700aA       endif;
700aA     other;
700aM       if KiloLbs = 'K';
700aM         eval(h) cnvwgt = w1addw * kgs2lbs;
700aM       else;
700aM         eval cnvwgt = w1addw;
700aM       endif;
700aA   endsl;
700aA /end-free

700aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   eval      w1addw = 0
     C                   eval      lstseq = 0
     *
     C                   exsr      sflclr
     C                   endsr
PAK A*----------------------------------------------------------------
     * ZZFLG    Set UCI flag ... if client is Packers and the
     *          catchweight has a UCI label rec, turn on UCI flag
     *
PAK AC     ZZFLG         begsr
     *
PAK AC                   move      *off          uciflg
530aDC*****              if        client = packer
530aMC                   if        opuci = 'Y'
PAK AC     uckey         chain     ucicw9
PAK AC                   if        %found(ucicw9) and
PAK AC                             ucilbl <> *zeros
PAK AC                   eval      uciflg = *on
PAK AC                   endif
PAK AC                   endif
     *  *** FORCE FLAG ON SO CATCHWEIGHT VARIANCE IS NEVER CHECKED.
     *
530aDC*****              eval      uciflg = *on
PAK AC                   endsr
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
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
     *
412aAC                   eval      wopqty = lbqpck
520 A*
520 AC                   if        $sstop > 0
520 AC                   z-add     $sstop        wostop
520 AC                   else
412aAC                   eval      wostop = lbstop
520 AC                   endif
640aA*
640aA*  load uom
640aAC                   eval      woucod = lbucod
640aA*
640aA*  load shipping wgt
640aAC                   eval      wouwgt = lbuwgt
520 A*
417cA*  Get route.
417cAC     rtkey         chain     rtehed                             77
417cAC                   if        not *in77
417c C                   eval      worte = rhrte
417cAC                   else
417cAC                   eval      worte = *blanks
417cAC                   endif
GFC A*
GFC AC                   if        client = Glazier
GFC A*
GFC A*      Check if item on regular/hotshot transfers.
GFC AC                   if           %subst(rhrte:1:1) = 'I'
GFC AC                             or %subst(rhrte:1:1) = 'H'
GFC AC                   eval      tfrorder = '*YES'
GFC AC                   else
GFC AC                   eval      tfrorder = '*NO '
GFC AC                   endif
GFC A*
GFC AC                   endif
417cA*
412dAC     itkey         chain     piritem                            79
412dAC                   if        not *in79
412dAC                   movel     itdesc        wodesc
412dAC                   else
412dAC                   eval      wodesc = *blanks
412dAC                   endif
     *
404 A*
410 A*   If verify catch weight = yes,
410 A*     Calculate total expected catch weight,
410 A*     Calculate low/high ranges.
410 AC                   if        opwrncflag = 'Y'
410 AC                   eval      lwvar = 0
410 AC                   eval      hivar = 0
410 AC                   eval      lwrng = 0
410 AC                   eval      hirng = 0
410 AC                   eval      exwgt = 0
412 AC                   eval      ilvar = 0
412 AC                   eval      ihvar = 0
412 AC                   eval      ilrng = 0
412 AC                   eval      ihrng = 0
520 AC                   eval      prg1c = *zeros
520 AC                   eval      prg2c = *zeros
410 AC     lbqpck        mult      lbuwgt        exwgt
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C     imkey         chain     itemmsc                            79
     C                   if        not *in79
     *
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
410 AC     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
410 AC     oprg2c        div       100           prg2c
     C                   endif
410 A*
412 MC                   if        prg1c > 0
410 AC     exwgt         mult      prg1c         lwvar
412 AC                   eval      ilvar = lbuwgt * prg1c
410 AC                   endif
410 AC                   eval      lwrng = exwgt - lwvar
412 AC                   eval      ilrng = lbuwgt - ilvar
412 MC                   if        prg2c > 0
410 AC     exwgt         mult      prg2c         hivar
412 AC                   eval      ihvar = lbuwgt * prg2c
410 AC                   endif
410 AC     exwgt         add       hivar         hirng
412 AC     lbuwgt        add       ihvar         ihrng
410 A*
410 AC                   endif
     *
     C                   eval      w1addw = *zeros
     *
     C                   exsr      sflclr
     C     cwkeyp        setll     ordc1
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     cwkeyp        reade(n)  ordc1                                  79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   add       occwgt        wotcw
     C                   add       1             wocw#
     C                   eval      w1seq = ocseq
     C     occwgt        mult      100           w1cwgt
     **                   MOVE LDRGHT    W1RGHT
     C                   exsr      sfladd
     C                   eval      lstseq = ocseq
     C                   endif
     C                   enddo
     C                   eval      posrec = 1
CBIbAc                   if        client = cheney
CBIbA*
CBIbA*  First time through, existing cw's against range.
CBIbA*
CBIbAC                   if        inzflg = *on
CBIbAC                   exsr      zzupd3
CBIbAC                   eval      inzerr = error
CBIbAC                   eval      error = *off
CBIbAC                   endif
CBIbA*
CBIbAc                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
520 A*  ZZFGTS   Get Host Stop Number
520 A*
520 AC     zzfgts        begsr
520 A*
520 A*    Get Stop From RTESTP
520 A*
520 AC                   call      'GETSTOP'
520 MC                   parm      '*ORDSTP '    $scmd             8
520 MC                   parm      $pwhse        $swhse            3 0
520 MC                   parm      lbrte         $srtid            5
520 MC                   parm      lbord         $sord             7 0
520 MC                   parm      0             $sstp             2 0
520 MC                   parm                    $sstop            5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 A*
520 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
412 D*R         FILEKY    CHAINRECORD              N7978
412 D*R                   ELSE
412 D*R         FILEKY    CHAINRECORD               7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     *R                   EXSR ZM74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     *R                   EXSR ZM73
     C                   goto      endgt1
     C                   endif
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C                   exsr      zzget1
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
412 D*R                   EXSR ZZGET1
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     *
     *  Define full key for detail file.
     *
     C     cwkey         klist
     C                   kfld                    $pwhse
412BD*R                   KFLD           OCTRAN
412BD*R                   KFLD           OCITEM
412BMC                   kfld                    oclbl#
     C                   kfld                    ocseq
     *
     *  Define partial key for detail file.
     *
     C     cwkeyp        klist
     C                   kfld                    $pwhse
412BMC                   kfld                    $plbl#
412BD*R                   KFLD           $PTRN#
412BD*R                   KFLD           $PITEM
405 A*
405 A*  Define key for OPTIONS file.
405 A*
405 AC     opkey         klist
405 AC                   kfld                    wkwhse
405 AC                   kfld                    wkcode
     *
412BD*  Define full key for LABEL7 file.
412BD*
412BD*R         LBKEY     KLIST
412BD*R                   KFLD           $PTRN#
412BD*R                   KFLD           $PITEM
412BD*R                   KFLD           $PSEQ#
     *
412BA*  Define full key for LABEL file.
412BA*
412BAC     lbkey         klist
412BAC                   kfld                    $plbl#
     *
     *  Define full key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
412dA*  Define full key for item file.
412dA*
412dAC     itkey         klist
412dAC                   kfld                    $pwhse
412dAC                   kfld                    $pitem
     *
417c *  Define key for RTEHED file.
417c *
417c C     rtkey         klist
417c C                   kfld                    lbwhse
417c C                   kfld                    lbrte
     *
CBIa *  Define key for ORDH file.
CBIa *
CBIa C     ohkey         klist
CBIa C                   kfld                    lbwhse
CBIa C                   kfld                    lbord
PAK A*  Define key for UCICW9 file.
     *
PAK AC     uckey         klist
PAK AC                   kfld                    $PWHSE
PAK AC                   kfld                    $PTRN#
PAK AC                   kfld                    $PLBL#
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
CBIbAc                   if        client = cheney
CBIbAC                   eval      inzflg = *on
CBIbAc                   endif
     *
     *   Check for *CHANGEP
     *
530bMC                   eval      mode  = *blanks
530bMC                   eval      *in92 = *on
530cAC                   eval      mode2 = *blanks
530cAC                   if        $pcmd = '*CHKNONE'
530cAC                   eval      mode2 = '*CHKNONE'
530cAC                   endif
530bMC                   if        $pcmd = '*CHANGEP'
530bMC                             or $pcmd = '*CHKNONE'
530bMC                   eval      mode  = 'Closing'
530bMC                   eval      $pcmd = '*CHANGE '
530bMC                   eval      *in92 = *off
     *
530bMC                   if        client = saval
530bMC                             or client = cashwa
530bMC                             and cliloc = cashwak
DRY AC                             or client = dairyland
530bMC                   eval      *in92 = *on
530bMC     imkey         chain     itemmsc                            79
530bMC                   if        *in79 = *off and
530bMC                             imwrnc = 'Y'
530bM*   Prevent user from exiting (F12), will allow total catch
530bM*   weight to be entered, not one for each quantity.
530bMC                   eval      *in92 = *off
530bMC                   endif
530bMC                   endif
530bMC                   endif

DRYbD*   For specified clients, allow F12 unconditionally.
DRYbD *                  if        client = dairyland
DRYbD *                  eval      *in92 = *off
DRYbD *                  endif
     *
530bD ***                if        $pcmd = '*CHANGEP'
530bD ***                eval      $pcmd = '*CHANGE '
530bD ***                if        client = ei  or
530bD ***                          client = tpc or
530bD ***                          client = renzi
530bD***    Allow user to override any/all warnings during close.
530bD ***                eval      *in92 = *off
530bD ***                else
530bD ***                eval      *in92 = *on
530bD ***                endif
530bD***
530bD ***                if        client = saval
530bD ***                          or client = cashwa
530bD ***                          and cliloc = cashwak
530bD ***                          or client = dairyland
530bD ***  imkey         chain     itemmsc                            79
530bD ***                if        *in79 = *off and
530bD ***                          imwrnc = 'Y'
530bD***    Allow user to override any/all warnings during close.
530bD ***                eval      *in92 = *off
530bD ***                endif
530bD ***                endif
530bD ***                else
530bD ***                eval      *in92 = *off
530bD ***                endif
530bAC                   if        mode2 = '*CHKNONE'
530bAC                   eval      *in92 = *off
530bAC                   endif
700aA*
700aA*   Get Item Maintenance options.
700aA*
700aA /free
700aA   wkcode = '*ITEMMNT';
700aA   chain ($pwhse: wkcode) options;
700aA   if %found(options);
700aA     opdataIM = opdata;
700aA     select;
700aA       when opwum = 'KGS'
700aA        or  opwum = 'kgs'
700aA        or  opwum = 'Kgs';
700aA         KiloLbs = 'K';
700aA         W1KgLb  = opwum;
700aA         cmdln1 = cmdln(2);
700aA       other;
700aA         KiloLbs = 'P';
700aA         W1KgLb  = 'Lbs';
700aA         cmdln1 = cmdln(1);
700aA     endsl;
700aA   else;
700aA     opwum = 'Lbs';
700aA     KiloLbs = 'P';
700aA     W1KgLb  = 'Lbs';
700aA     cmdln1 = cmdln(3);
700aA   endif;
700aA /end-free
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
410 AC                   eval      wkcode = '*SYSTEM '
410 AC                   eval      wkwhse = 0
410 AC     opkey         chain     options                            79
410 AC                   if        *in79
410 AC                   eval      opcapc = 'Y'
410 AC                   eval      opwrnc = 'N'
410 AC                   eval      oprg1c = 0
410 AC                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
410 AC                   endif
530bA**
530bA** determine if individual catch weight count is performed
530bA**
530bAC                   select
530bA* no individual CW count
530bAC                   when      opicw = 'N'
530bAC                   eval      opicwflag = 'N'
530bA* individual CW count during truck builder
530bAC                   when      opicw = 'M'
530bAC                             and @caller = 'CW110A'
530bAC                   eval      *in92 = *off
530bAC                   eval      opicwflag = 'Y'
530bA* individual CW count during manual entry
530bAC                   when      opicw = 'M'
530bAC                             and mode <> 'Closing'
530bAC                   eval      opicwflag = 'Y'
530bA* individual CW count during closing step
530bAC                   when      opicw = 'C'
530bAC                             and mode =  'Closing'
530bAC                   eval      opicwflag = 'Y'
530bA* perform individual CW count
530bAC                   when      opicw = 'B'
530bAC                   eval      opicwflag = 'Y'
530bAC                   eval      *in92 = *off
530bAC                   other
530bAC                   eval      opicwflag = 'N'
530bAC                   endsl
530bA**
530bA** determine if individual variance catch weight check is done
530bA**
530bAC                   select
530bA* no individual CW variance check
530bAC                   when      opwrnc = 'N'
530bAC                   eval      opwrncflag = 'N'
530bA* do individual CW variance check during manual entry
530bAC                   when      opwrnc = 'M'
530bAC                             and @caller = 'CW110A'
530bAC                   eval      opwrncflag = 'Y'
530bA* do individual CW variance check during manual entry
530bAC                   when      opwrnc = 'M'
530bAC                             and mode <> 'Closing'
530bAC                   eval      opwrncflag = 'Y'
530bA* do individual CW variance check during closing step
530bAC                   when      opwrnc = 'C'
530bAC                             and mode =  'Closing'
530bAC                   eval      opwrncflag = 'Y'
530bA* perform individual CW variance check
530bAC                   when      opwrnc = 'B'
530bAC                   eval      opwrncflag = 'Y'
530bAC                   other
530bAC                   eval      opwrncflag = 'N'
530bAC                   endsl
530bA*
     *
412BD*R         LBKEY     CHAINLABEL7               79
412BMC     lbkey         chain     label                              79
410 AC                   if        *in79
410 AC                   eval      lbqpck = 0
410 AC                   eval      lbuwgt = 0
412aAC                   eval      lbstop = 0
410 AC                   endif
     *
CBIaAc                   if        client = cheney
CBIa *   If order is type 'E', set system options to allow total cw.
CBIa C     ohkey         chain     ordh                               79
CBIa C                   if        not *in79
CBIa C                   eval      dsmisc = ohmisc
CBIa C                   if        dscode = 'E'
CBIaDC*                  eval      opicw = 'N'
CBIaMC                   eval      opicwflag = 'N'
CBIa C                   endif
CBIa C                   endif
CBIaAc                   endif
730eA*   Get item information
730eAC                   exsr      clr$item
730eAC                   eval      $itwhse = $pwhse
730eAC                   eval      $ititem = $pitem
730eAC                   eval      $dricommand = '*ITEM'
730eAC                   eval      $drisubcmd  = '%GETALL'
730eAC                   eval      $drisys2upd = 'D'
730eAC                   eval      chk4err = *off
730eAC                   exsr      zzzdricop
730eAC                   if        $drireturn <> '*OK'
730eAC                   eval      $ifucicde = ''
730eAC                   eval      $ifrcvmth = ''
730eAC                   eval      $ifsltmth = ''
730eAC                   endif
730aA*
730aA*   Do not allow change for a UCI Selection item
730eAC                   if        $ifsltmth = '2'
730aAC                   eval      $pcmd = '*VIEW'
730aAC                   eval      errmsg = desc(10)
730aAC                   exsr      zm0105
730aAC                   endif
     *
     *   Initialize counter and total fields.
     C                   eval      wocw# = 0
     C                   eval      wotcw = 0
     C                   eval      lstseq = 0
413gAC                   eval      cwtck = *off
413gAC                   eval      cweck = *off
413gAC                   eval      twtck = *off
     *
     *   Select first screen to display.
     *
     *R         $PCMD     IFEQ '*ADD    '
     *R                   MOVE *BLANKS   $PWHDP
     *R                   MOVE *BLANKS   $PAISL
     *R                   MOVE *BLANKS   $PSTYP
     *R                   EXSR SCR01I
     *R                   ELSE
     *R         $PSTYP    IFEQ 'P'
     *R                   EXSR SCR02I
     *R                   ELSE
     C                   exsr      scr03i
     *R                   ENDIF
     *R                   ENDIF
CBIbAc                   if        client = cheney
CBIbAC                   eval      inzflg = *off
CBIbAc                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTOTL   Recalculate total cw and entered cw.
     *
     C     zztotl        begsr
     C                   eval      error = *off
X12  C                   eval      wotcw = 0
X12  C                   eval      wocw# = 0
     *
     *   Loop through subfile records and recaluclate.
     C                   if        reccnt > 0
X12 AC                   eval      *in85 = *on
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in85 = *on
     C                   update    detail1
     *
     C     w1cwgt        div       100           wttcw
X12 AC                   add       wttcw         wotcw
412bAC                   if        wttcw > 0
X12 AC                   add       1             wocw#
412bAC                   endif
     C                   enddo
     C                   eval      *in85 = *off
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
412cAC                   if        reccnt > 0
     *
     *   Loop through changed subfile records and add/update file.
     *
     C                   eval      ocwhse = $pwhse
412BAC                   eval      oclbl# = $plbl#
     C                   eval      octran = $ptrn#
     C                   eval      ocord = lbord
     C                   eval      ocseq# = lbseq
     C                   eval      ocitem = $pitem
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     detail1                                77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Get detail record.
     *
     C                   move      w1seq         ocseq
     C     cwkey         chain     record2                            7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Initialize record fields before trying to add or update.
     *
     C     w1cwgt        div       100           occwgt
     *
     *     Record not found. Try adding record.
     *
     C                   if        *in79  and
417bAC                             w1cwgt > 0
     C                   write     record2                              76
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
     C                   if        not *in76
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Record found. Try updating record.
     *
     C                   if        not *in79
     C                   if        w1cwgt = 0
     C                   delete    record2
650aAc                   eval      processstatus = '*DELETE'
650aAc                   exsr      processCWLog
     C                   else
     *
     C                   update    record2                              76
650aAc                   eval      processstatus = '*CHK4UPD'
650aAc                   exsr      processCWLog
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     C                   endif
     C                   endif
     *
     C                   enddo
412cAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Determine which screen to display next.
     *
     *R         W1STYP    IFEQ 'P'
     *R                   EXSR SCR02I
     *R                   ELSE
     *R                   EXSR SCR03I
     *R                   ENDIF
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
CBIbAc                   if        client = cheney
CBIbAC     inzflg        cabeq     *on           chkcw
CBIbAc                   endif
     *
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *    - do not update files
     *
     C                   if        w1addw <> *zero
     C                   add       1             lstseq
     C                   eval      w1seq = lstseq
700aDC*                  eval      w1cwgt = w1addw
700aMC                   eval      w1cwgt = cnvwgt
     C                   eval      *in85 = *on
     C                   exsr      sfladd
X12  C                   exsr      zztotl
     C                   eval      w1addw = 0
     C                   eval      *in17 = *on
     C                   eval      redspl = *on
412bAC                   eval      ovrrid = *off
     C                   goto      endup3
     C                   endif
     *
     *  Update detail first.
     *
CBIbAC     chkcw         tag
806X C                   exsr      zztotl
412bD**         RECCNT    IFGT 0
412bMC                   if        reccnt >= 0
X12  C                   exsr      zzchkt
X12  C     error         cabeq     *on           endup3
CBIbAc                   if        client = cheney
CBIbAC     inzflg        cabeq     *on           endup3
CBIbAc                   endif
     C                   exsr      zzusub
     C     error         cabeq     *on           endup3
     C                   endif
     *
     C     endup3        endsr
     *
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;
650aA     $cwentflg = 3;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free

730aA*----------------------------------------------------------------
730aA*----------------------------------------------------------------
730aA*                     DRI SUBROUTINES
730aA*----------------------------------------------------------------
730aA*----------------------------------------------------------------

730aA*----------------------------------------------------------------
730aA*  clr$item  Clear $item data structure fields
730aA*----------------------------------------------------------------
730aA
730aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

730aA*----------------------------------------------------------------
730aA*  zzzdriclose   Close any open files or programs.
730aA*----------------------------------------------------------------
730aA
730aAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

730aA*----------------------------------------------------------------
730aA*  zzzdricop  Call DRICOP
730aA*----------------------------------------------------------------
730aA
730aAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                             or $dricommand = '*LICINFO'
     C                             or $dricommand = '*ITEM'
     C                             or $dricommand = '*PROD'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endsl

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Catch weight
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Override not allowed
Change not allowed for UCI Selection Item
**  CMDLN - Command display line 700a
F5=Refresh  F7=Kilograms  F12=Cancel  F20=Accept Warning
F5=Refresh  F7=Pounds  F12=Cancel  F20=Accept Warning
F5=Refresh  F12=Cancel  F20=Accept Warning
