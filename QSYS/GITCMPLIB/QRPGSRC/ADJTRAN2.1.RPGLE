      /COPY *libl/qcopysrc,hspecs
750bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
750bAH bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ADJTRAN     Adjust transaction record (EPM version)
     *  04 February, 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Old ADJTRAN Revisions
     *
412 A*    08/31/99  RH   4.12
     *      - Change to not remove employee # for *UNDO.
     *
414 A*    06/28/00  DAS  4.14
     *      - Added commands *DECTTL and *INCTTL. These commands
     *        are used when multiple license plates are scanned as
     *        a single transaction. An example would be the RC300
     *        staged putaway program.
     *      - Added command *CLOSE to do simple close of transaction
     *        that has no label records to close.
     *      - Added routine ZZCKU1 and ZZCKU2 to check for
     *        overlapping manual transactions.
     *      - Added routine ZZTIME used by ZZCKU2
     *      - Added file PIRTRAN2 used by ZZCKU2
     *      - Added command *ENDCUR to end current transaction
     *        for user.
     *
415 A*    06/14/01  HNK  4.15
     *      - Get current date just before updating the record instead
     *        of in *INZSR routine.
     *
     *  Old ADDSTDTRN/2 Revisions
     *
213 A*    05/22/96  DAS
     *      - Added new fields to PIRTRAN (PTRDTE, PTGRP1, PTGRP2).
     *      - Added GRP1 and GRP2 to parameter list.
     *      - Moved values into new PIRTRAN fields.
     *
218 A*    01/23/97  HNK
     *      - Added one more parameter $PCMD. Logic added to create
     *        and start transaction. Call ADJTSKDET program with
     *        with "*START" command to start the task.
     *
415 A*    06/14/01  HNK  4.15
     *      - Get current date just before updating the record instead
     *        of in *INZSR routine.
     *
     *  Revisions for ADJTRAN2
     *
417 A*    05/01/03  DAS  4.17
     *      - Converted to ILE.
     *      - Used ADJTRAN as a base.
     *      - Added Date/Time parameters, which were used in ADDSTDTRN2.
     *      - Added ADDSTDTRN logic.
     *      - Revised ADJTRAN, ADDSTDTRN/2 to call this program.
     *      - Changed $PCMD to 10.
     *      - Added $PTYPE, $PUSER, $PDATE and $PTIME.
     *      - Revised to always end current trans for *START and *CRTSTRT.
     *      - Added *ENDNONIDL to end current tran if not IDLE.
     *      - Added *UPDTIME to update total time for a transaction.
     *
417aA*    02/12/03  MLB  4.17a
     *      - Enh: Added new command *CLOSEI to close active Indirect
     *        task.
417bA*    05/19/03  MLB  4.17b
     *      - Enh: Revised routine ZZENDI,ZZTSKI to look for active
     *        IDLE tasks in addition to active indirect tasks.
417cA*    07/21/03  MLB  4.17c
     *      - Enh: Revised program when processing command *UNDO to
     *        clear employee number from transaction. Transactions
     *        later deleted were being attributed to the last employee
     *        to have worked with the transaction when they actually
     *        didn't have anything to do with the transaction.
417dA*    07/24/03  MLB  4.17d
     *      - Enh: Revised program when processing command *UNDO to
     *        pass back start date/time for transaction being reset.
417eA*    07/25/03  MLB  4.17e
     *      - Enh: Revised program when processing command *ABORT to
     *        pass back start date/time for transaction being aborted.
     *
417fA*    09/17/03  DAS  4.17f
     *      - Revised routine ZZTIME to initialize strtim/endtim variables
     *        with ptstim/ptetim fields.
     *      - Revised call to ZZTIME for *UPDTIME to update ptdmin or
     *        ptimin depending on tktype field.
     *      - Revised *CLOSE to make sure dates are not zero.
     *      - Revised *CLOSE to execute ZZTIME.
     *      - Revised to get TASK record after getting transaction record.
     *
500aA*    08/10/04  DAS  5.00a
     *      - Added commands *STARTMULT.
     *      - Revised routine ZZEND to call TE130 if transaction
     *        being ended exists in the MULTRAN file.
     *      - Revised ZZENDC to only end an IDLE task for *STARTMULT.
     *      - Added logic to ZZCREATE to get task info because it was
     *        getting wiped out when looking for overlapping tasks.
     *      - Revised *UNDO to try and delete transaction from MULTRAN file
     *      - Added *ENDNONSEL to end current tran if not Selection task.
     *
500bA*    09/14/05  DAS  5.00b
     *      - Revised ENDC for *ENDNONSEL to check for IDLE tran.
     *
500cA*    11/28/05  DAS  5.00c
     *      - Added command *SUSPEND.
     *
500dA*    01/11/06  DAS  5.00d
     *      - Revised to use $pdate and $ptime for *START, if sent.
510aA*    03/09/07  RH   5.10a
     *      - Fix: Call ADJTASKDET with end date and time for *CRTSTRT
     *        to end previous transaction with same start date/time as
     *        new transaction.  The start date/time was saved when
     *        IT276 was entered.
510bA*    08/31/07  DAS  5.10b
     *      - Added *BEGDAY and *ENDDAY.
     *      - This mod was made to version in socketmods on 9/22/06.
510cA*    08/31/07  DAS  5.10c
     *      - Revised routine ZZENDC. Before, when it came across an
     *        Indirect task it would close it and all other open
     *        tasks, which was incorrect when the command was
     *        *ENDNONSEL.
     *      - Added command *STARTI.
     *      - Revised to send back $prtn codes in *BATCH mode.
     *
520 A*    01/24/08  MLB  5.20
     *      - Fix: Revised GETDATTIM routine to compute change in
     *        days to determine whether to retrieve get new
     *        system date.
     *
530aA*    08/24/10  MLB  5.30
     *      - Fix: Revised ZZTASK to change PIRTRAN2 to use READE
     *        instead of READ. Believe that this may be the source
     *        of LCKW states appearing on other users' jobs.
     *
610aA*    08/25/10  DAS  6.10a
     *      - Added phrase logging.
     *      - Only used for a custom logging situation at Royal.
     *      - Added client code
610bA*    08/26/10  DAS/MLB  6.10b
     *      - Fix: Revised routine ZZCREATE to move ENDSL stmt
     *        so that transactions created using $pcmd *CRTSTRT
     *        will get transaction start date/time initialized.
640aA*    02/21/12  DAS  6.40a
     *      - Revised to set PTWHSE to USWHSE if PTWHSE is zero.
640bA*    03/07/12  LMC  6.40b
     *      - Revised to create and IDLE
     *        if the command that was sent in is *CLOSEI and the
     *        indirect task that was just closed is not an IDLE task,
     *        then start an IDLE task if there is no error and no
     *        current transaction running
640cA*    06/04/12  LMC  6.40c
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
700a *    02/29/16  GJA  7.00a
     *      - Enh: Don't end selection transaction if begday or endday
     *          Custom Client to work with their version of task.  It
     *          will have the "See supervisor" when they try to end."
710  *    07/24/17  KDE  7.10
     *      - Enh: Production Module Adjustments
720  *    07/30/18  KDE  7.20
     *      - Fix: Correct situation where ADJTRANP was placing zero
     *             in PTTRN#
730aA*    06/15/19  DAS  7.30a
     *      - Added command *CRTCLOSED.
     *      - Originally used for auto closing MLK zone transactions
     *        in OR630 for Cheney.
730bA*    08/06/19  RBD  7.30b
     *      - Fix: Was going into infinite loop if the trans exists in
     *        MULTRAN with a different emp#. This can happen when a
     *        trans doesn't get purged from MULTRAN when it should and
     *        the same trans# gets used again when trans#'s trip. Will
     *        now require emp# match in sr getmultran.
730dA*    10/14/19  DAS  7.30d
     *      - Revised to use PIRTRANW, PIRTRAN1W, PIRTRAN2W,
     *        MUTRANW and MULTRAN1W.
     *      - Initilaized $pwhse to uswhse when zero.
730cA*    12/05/19  NLK  7.30c
     *      - Rserve CBI - XDK and *CRTCLOSED.
740aA*    01/23/20  LMC  7.40a
     *      - Revised to not lock file multran on the chain.
750aA*    09/18/21  DAS  7.50a
     *      - Moved APT call after the transaction is ended.
750bA*    03/16/22  KDE  7.50b
     *      - Add logging for APT issues at Y-Hata
     *----------------------------------------------------------------
     *  Custom
CBI A*    12/09/03  MLB  CBI (from old ADJTRAN)
     *      - Disable 4.17c change.  Want employee number of last
     *        person to handle transaction left behind when trans-
     *        action is aborted.
     *
CBIaA*    06/14/19  LMC  CBIa
     *      - Condition the code that deleted the line by mod cbi
     *        to only be CBI.
     *----------------------------------------------------------------
     *  Cityline Custom Mods
     *
CLDa *     11/27/17  GJA  CLDa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  Custom - Royal
     *
RYLaA*    08/25/10  DAS  RYLa
     *      - Added phrase logging for emp# 779.
     *
     *----------------------------------------------------------------
     *  Graves Foods Custom Mods
     *
GMMa *     06/14/118 GJA GMMa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  European Import Custom Mods
     *
EIa  *     05/25/16  GJA EIa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  S. Bertram Custom Mods
     *
SBRa *     08/21/18  GJA SBRa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  Custom Client Revisions - TPC
     *
TPCa *     09/01/18  GJA TPCa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    01/30/19  GJA  CFIa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy Foods
     *
FBYa *    09/26/18  GJA  FBYa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chefs Warehouse
     *
DRYa *    01/26/21  GJA  DRYa
     *       - Added to 700a enhancement to stop premature end
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    03/24/21 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
PFCb *    05/13/21 RTR PFCb
     *      - Fix: Added to zzendi also, was only closing direct.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y-Hata
     *
YHAa *    03/11/22 KDE YHAa
     *      - Enh: Prevent current APT writes since their selection
     *        is handled in different process call in wrttrand
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftask      if   e           k disk
730dDF*irtran   uf a e           k disk
730dMFpirtranw  uf a e           k disk
     Fpiruser   if   e           k disk
730dDF*irtran1  if   e           k disk
730dMFpirtran1w if   e           k disk
     F                                     rename(ptrec:ptrec1)
730dDF*irtran2  if   e           k disk
730dMFpirtran2w if   e           k disk
     F                                     rename(ptrec:ptrec2)
730dDF*ultran   uf a e           k disk
730dMFmultranw  uf a e           k disk
730dDF*ultran1  uf   e           k disk
730dMFmultran1w uf   e           k disk
     F                                     rename(murec:murec1)
PFCaAfoptions   if   e           k disk
750bAFbfcsktlog o    e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D desc            s             50    dim(1) ctdata perrcd(1)

610aA*----------------------------------------------------------------
610aA*  Customer id
610aA*----------------------------------------------------------------
610aA
610aA /copy qcopysrc,id#royal
700aA /copy qcopysrc,id#isupply
700aA /copy qcopysrc,id#sofo
700aA /copy qcopysrc,id#jsl
700aA /copy qcopysrc,id#capitol
700aA /copy qcopysrc,id#fpr
EIa A /copy qcopysrc,id#ei
SBRaA /copy qcopysrc,id#sbr
GMMaA /copy qcopysrc,id#gmm
TPCaA /copy qcopysrc,id#tpc
CFIaA /copy qcopysrc,id#cfi
CLDaA /copy qcopysrc,id#citylin
FBYaA /copy qcopysrc,id#fby
CBIaA /copy qcopysrc,id#cheney
DRYaA /copy qcopysrc,id#dairyla
YHAaA /copy qcopysrc,ID#YHata

     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *----------------------------------------------------------------

     D ptparm        e ds                  extname(pirtran)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @adjtd          c                   const('ADJTSKDET')
     D @cvtdt          c                   const('CVTDTE')
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

414 A*----------------------------------------------------------------
414 A* Time Data Structure
414 A*----------------------------------------------------------------
414 A
414 AD                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0

PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
PFCaAd aptsk1          c                   'SIGNON    '
PFCaAd aptsk2          c                   '*JOB0100  '
PFCaAd apclos          c                   '*CLOSE    '
PFCaAd @gtstd          c                   'GETEPMSTD'
PFCaA
PFCaAd logapt          s               n   inz(*on)
PFCaAd wdwuse          s              4a

414 A*----------------------------------------------------------------
414 A* Program variables.
414 A*----------------------------------------------------------------
414 A
     D $MSGF           s             10
417fAD curdate         s              8  0
417fAD curtime         s              6  0
     D curent          s              1
520 AD currentstamp    s               z
     D curtrn          s              7  0
     D curtsk          s                   like(TKCODE)
     D curtyp          s                   like(TKTYPE)
     D error           s              1
     D fintim          s              6  0
     D forevr          s              1
     D forever         s              1
     D Found           s              1
     D kystat          s                   like(PTSTAT)
500aAD kystat2         s                   like(MUSTAT)
730dAD kytrn#          s                   like(pttrn#)
417fAD lasttime        s              6  0
520 AD laststamp       s               z
500aAD mufound         s               n
700aAD opfound         s               n
     D stdate          s                   like(PTSDTE)
     D strtim          s              6  0
     D sttime          s                   like(PTSTIM)
     D svtlen          s                   like(PTDMIN)
     D svtrn#          s                   like(PTTRN#)
     D timlen          s                   like(PTDMIN)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
640cAD wrtpcmd         s             10
640cAD wrtpwait        s              2  0
640cAD wrtpwhse        s              3  0
640cAD wrtptran#       s                   like(pttrn#)
640cAD wrtpfrmdate     s              8  0
640cAD wrtptodate      s              8  0
640cAd wrtpemp#        s                   like(ptemp#)
     D zzedte          s              8  0
     D zzetim          s              6  0
     D zzsdte          s              8  0
     D zzstim          s              6  0
750bAd  spUid          s             32

750bA*----------------------------------------------------------------
750bA*  Time variables
750bA*----------------------------------------------------------------
750bA
750bAD CurrStamploc    s               z
750bAD CurrStampsys    s               z
750bAD CurrStampuc     s               z
750bAD FromStamp       s               z
750bAD ToStamp         s               z
750bAD oldeststamp     s               z
750bAD ts              s               z
750bA
750bAD Duration        s              7  2
750bAD TtlMin          s              5  0
750bAD TtlMinSec       s              9  0
750bAD TtlSec          s              9  0
750bAD RemSec          s              3  0
750bA
750bAD bfcoffset       s              3  0 inz(0)
750bAD ucOffset        s              3  0

500aA*----------------------------------------------------------------
500aA*  TE130 Key Data Structure
500aA*----------------------------------------------------------------
500aA
500aAD $te130          ds
     D  $tlen                  1     50
     D  $temp#                 1      5  0
     D  $tstat                 6      6
414 A
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  erqty                  1     10
     D  erpal                 11     12p 0
     D  eritem                13     27
     D                 ds
     D  $ec                    1      2p 0

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
     *  Program info data structure
     *----------------------------------------------------------------

610aA /Copy qcopysrc,c#pgminfds
500cA /copy qcopysrc,p.bfcdteti

610aDD**              sds
610aDD**#prog            *proc
610aDD**#job                 244    253
610aDD**#user                254    263
610aDD**#jobn                264    269
610aDD**#jobdt               276    281  0
610aDD**#jobtm               282    287  0

640cA*----------------------------------------------------------------
640cA*  Prototypes
640cA*----------------------------------------------------------------
640cA
640cAD wrttran1        pr                  extpgm('WRTTRAN1')
640cA * Input
640cAD   ppcmd                        8
640cAD   ppwait                       2  0
640cAD   ppwhse                       3  0
640cAD   pptran#                      7  0
640cAD   ppfromdate                   8  0
640cAD   pptodate                     8  0
640cAD   ppemp#                       5  0

750bAd writeVoiceLog   pr
750bAd  type                               const like(slgtyp)
750bAd  buffer                             const like(slgbuf)

750bAd GetCurrStamp    pr

610aA*----------------------------------------------------------------
610aA*  Phrase Variables
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,c#phrasvar
610aAD  currFile       s             10
610aAD  currRoutine    s             20
610aAD  lastnxtscr     s              3
610aAD  stackCount     s              3  0
610aAD  aRoutine       s             20    dim(30)
610aAD  i              s              3  0
610aA
610aA*----------------------------------------------------------------
610aA*  Phrases
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *START     = Start transaction
500aA*              *STARTMULT = Start transaction that is part of a
500aA*                           multiple transaction selection task.
510cA*              *STARTI    = Start indirect transaction
     *              *ABORT     = Abort a transaction
     *              *UNDO      = Undo a transaction
414 A*              *DECTTL    = Decrease transaction totals
414 A*              *INCTTL    = Increase transaction totals
414 A*              *CLOSE     = Close transaction w/no label records.
500aA*              *CLOSEI    = Close Indirect transaction w/no label records.
414 A*              *ENDCUR    = End current transaction for user.
     *              *CREATE    = Create transaction
     *              *CRTSTRT   = Create and start transaction
730aA*              *CRTCLOSED = Create transaction with status '4'
     *              *ENDNONIDL = End current trans if not 'IDLE' task.
500aA*              *ENDNONSEL = End current trans if not 'Selection task.
     *              *UPDTIME   = Update total time for a transaction.
500cA*              *SUSPEND   = Suspend current trans. Set stat to '8'.
510bA*              *BEGDAY    = Create BEGDAY transaction.
510bA*              *ENDDAY    = Create ENDDAY transaction.
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER, *BATCH
     *      $PTRN#  Transaction number
     *      $PTASK  Task code
     *      $PWHSE  Warehouse
     *      $PWHDP  Department
     *      $PSTYP  Section
     *      $PCUBE  Cube
     *      $PSWGT  Weight
     *      $PPCS   Pieces
     *      $PAISL  Aisles
     *      $PQTY1  User quantity 1
     *      $PQTY2  User quantity 2
     *      $PQTY3  User quantity 3
     *      $PRTE   Route
     *      $PPO    P.O.
     *      $PGRP1  Group 1 code
     *      $PGRP2  Group 2 code
     *      $PDATE  Transaction date  (use if greater than zero)
     *      $PTIME  Transaction time
     *      $PUSER  User code (use if not blank)
     *
     *    Returned Parameters
417eM*      $PDATE  Transaction start date  (used with *UNDO,*ABORT)
417eM*      $PTIME  Transaction start time  (used with *UNDO,*ABORT)
     *      $PRTN   *OK      - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pprg            10
     C                   parm                    $ptype            8
     C                   parm                    $ptrn#            7 0
     C                   parm                    $ptask            6
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pcube            9 3
     C                   parm                    $pswgt            9 2
     C                   parm                    $ppcs             5 0
     C                   parm                    $paisl            5 0
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $prte             5
     C                   parm                    $ppo              9
     C                   parm                    $pgrp1            1
     C                   parm                    $pgrp2            1
     C                   parm                    $pdate            8 0
     C                   parm                    $ptime            6 0
     C                   parm                    $puser           10
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
610aAC                   eval      stackCount = 0
610aAC                   eval      currRoutine = 'main'
610aAC                   exsr      phpgmV1V2V3s

     C                   eval      $prtn = *blanks
     C                   eval      $pmsg = *blanks
     C                   move      *off          error

     *  Get task information.

     C     $ptask        chain     task                               79
 1B  C                   if        *in79
     C                   eval      tkcat = *blanks
     C                   eval      tksub = *blanks
 1E  C                   endif
510cA
510cA*  If task not found for *STARTI, send back error.
510cA
510cAC                   if        *in79
510cAC                             and $pcmd = '*STARTI'
510cAC                   eval      $prtn = '*INVLDCD'
510cAC                   goto      out
510cAC                   endif

     *  Get user information.

     C                   exsr      zzgetu
730dA
730dA*  Set zero sent warehouse to user warehouse
730dA
730dAC                   if        $pwhse = 0
730dAC                   eval      $pwhse = uswhse
730dAC                   endif

510bA*  For *BEGDAY and *ENDDAY,
510bA*    End current transaction, then create transaction.
510bA
510bAC                   if        $pcmd = '*BEGDAY' or
510bAC                             $pcmd = '*ENDDAY'
510bAC                   exsr      zzendc
510bAC                   exsr      zzbegendday
510bAC                   goto      out
510bAC                   endif

     *  For *CRTSTRT and *START, end current transaction.

 1X  C                   if        $pcmd = '*CRTSTRT' or
500aAC                             $pcmd = '*STARTMULT' or
 1X  C                             $pcmd = '*START'
     C                   exsr      zzendc
     C                   endif
510cA
510cA*  For *STARTI, end current indirect transaction.
510cA
510cAC                   if        $pcmd = '*STARTI'
510cAC                   exsr      zzendi
510cAC                   endif

     *  For *CREATE and *CRTSTRT, do it and leave.
510cA*    and *STARTI
730aA*    and *CRTCLOSED

 1X  C                   if        $pcmd = '*CREATE'  or
510cMC                             $pcmd = '*CRTSTRT' or
730aAC                             $pcmd = '*CRTCLOSED' or
510cAC                             $pcmd = '*STARTI'
     C                   exsr      zzcreate
     C                   goto      out
     C                   endif

     *  For *ENDCUR and *ENDNONIDL, do it and leave.

 1X  C                   if        $pcmd = '*ENDCUR'    or
500aAC                             $pcmd = '*ENDNONSEL' or
 1X  C                             $pcmd = '*ENDNONIDL'
     C                   exsr      zzendc
     C                   goto      out
     C                   endif
500cA
500cA*  For *SUSPEND, do it and leave.
500cA
500cAC                   if        $pcmd = '*SUSPEND'
500cAC                   exsr      zzsus
500cAC                   goto      out
500cAC                   endif

     *  For *CLOSEI, do it and leave.

417aAC                   if        $pcmd = '*CLOSEI'
417aAC                   exsr      zzendi
417aAC                   goto      out
417aAC                   endif
     *
     *  Get transaction record.
     *
 1B  C*******            if        $pcmd <> '*ENDCUR '
730dDC**   $ptrn#        chain     pirtran                            7978
730dAC                   eval      kytrn# = $ptrn#
730dMC     ptkeyw        chain     pirtranw                           7978
     *
     *     Record is locked.
     *
 2B  C                   if        *in78
     C                   move      *on           error
510cAC                   if        $ptype = '*BATCH'
510cAC                   eval      $prtn = '*TRNLOCK'
510cAC                   else
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7978
     C                   eval      $prtn = '*PGMQ   '
510cAC                   endif
 2E  C                   endif
     *
     *     Record not found.
     *
 2B  C                   if        *in79
     C                   move      *on           error
510cAC                   if        $ptype = '*BATCH'
510cAC                   eval      $prtn = '*INVLDTR'
510cAC                   else
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7979
     C                   eval      $prtn = '*PGMQ   '
510cAC                   endif
 2E  C                   endif
     *
     C     error         cabeq     *on           out
 1E  C**********         endif
417fA
417fA*  Get task information.
417fA
417fAC     pttask        chain     task                               79
417fAC                   if        *in79
417fAC                   eval      tkcat = *blanks
417fAC                   eval      tksub = *blanks
417fAC                   eval      tktype = 'I'
417fAC                   endif
     *
     *  Update transaction detail record.
     *
 1B  C                   if        $pcmd <> '*INCTTL '  and
     C                             $pcmd <> '*DECTTL '  and
417aMC                             $pcmd <> '*ENDCUR '  and
417aAC                             $pcmd <> '*CLOSEI '
     C                   call      @adjtd
     C                   parm      $pcmd         @pcmd             8
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
 1E  C                   endif
     *
     *  Update transaction record.
     *
 1B  C                   select
 1X  C                   when      $pcmd = '*START  '
     C                   eval      ptstat = '2'
     C**   #user         chain     piruser                            79
 2B  C**                 if        not *in79
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#
 2X  C**                 else
     C**                 eval      ptshft = *blanks
     C**                 eval      ptcrew = *blanks
     C**                 eval      ptemp# = 0
 2E  C**                 endif
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptsdte = $cvd8o
417fDC**                 time                    ptstim
500dAC                   select
500dA
500dA*    Use date/time passed in for Transaction start date/time.
500dA
500dAC                   when      $pdate > *zeros
500dAC                   eval      ptsdte = $pdate
500dAC                   eval      ptstim = $ptime
500dA
500dAC                   other
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime
500dAC                   endsl
     *
500aAC                   when      $pcmd = '*STARTMULT'
500aAC                   exsr      getmultran2
500aAC                   eval      ptstat = '2'
500aAC                   eval      ptshft = usshft
500aAC                   eval      ptcrew = uscrew
500aAC                   eval      ptemp# = usemp#
500aAC                   if        mufound
500aAC                   eval      ptsdte = musdte
500aAC                   eval      ptstim = mustim
500aAC                   else
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime
500aAC                   endif
500aAC                   exsr      addmultran
500aA*
 1X  C                   when      $pcmd = '*UNDO   '
500aAC                   exsr      delmultran
     C                   eval      ptstat = '1'
417dA*
417dA*    Pass back start date/time for use in starting IDLE task.
417dAC                   eval      $pdate = ptsdte
417dAC                   eval      $ptime = ptstim
     C                   eval      ptsdte = 0
     C                   eval      ptstim = 0
     C                   eval      ptshft = *blanks
     C                   eval      ptcrew = *blanks
 2B  C                   if        ptemp# = 0
     C                   eval      ptemp# = 99999
 2E  C                   endif
CBIaAc                   if        client = cheney
CBI DC*                  eval      ptemp# = 0
CBIaAc                   else
CBIaAC                   eval      ptemp# = 0
CBIaAc                   endif
     *
 1X  C                   when      $pcmd = '*ABORT  '
730dDC**   $ptrn#        chain     pirtran                            79
730dAC                   eval      kytrn# = $ptrn#
730dMC     ptkeyw        chain     pirtranw                           79
 2B  C                   if        not *in79
710 A*   delete Production Transaction Data
710 Ac                   call      'ADJTRANP'
710 Ac                   parm                    pttrn#
710 Ac                   parm                    pttask
710 Ac                   parm                    ptcat
710 Ac                   parm                    ptsub
710 Ac                   parm                    $pwhse
710 Ac                   parm      'D'           pcmd              1
710 Ac                   parm                    $puser
417eA*
417eA*    Pass back start date/time for use in starting IDLE task.
417eAC                   eval      $pdate = ptsdte
417eAC                   eval      $ptime = ptstim
     C                   delete    ptrec
640cAc                   exsr      zzwrttrandl
 2E  C                   endif
goto C                   goto      out
     *
 1X  C                   when      $pcmd = '*INCTTL '
     C                   call      @adjtd
     C                   parm      '*DECACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   add       $ppcs         ptpcs
     C                   add       $pcube        ptcube
     C                   add       $pswgt        ptswgt
     C                   add       $paisl        ptaisl
     C                   add       $pqty1        ptqty1
     C                   add       $pqty2        ptqty2
     C                   add       $pqty3        ptqty3
     *
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
 1X  C                   when      $pcmd = '*DECTTL '
     C                   call      @adjtd
     C                   parm      '*DECACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   eval      ptpcs = ptpcs - $ppcs
     C                   eval      ptcube = ptcube - $pcube
     C                   eval      ptswgt = ptswgt - $pswgt
     C                   eval      ptaisl = ptaisl - $paisl
     C                   eval      ptqty1 = ptqty1 - $pqty1
     C                   eval      ptqty2 = ptqty2 - $pqty2
     C                   eval      ptqty3 = ptqty3 - $pqty3
 2B  C                   if        ptpcs < 0
     C                   eval      ptpcs = 0
 2E  C                   endif
 2B  C                   if        ptcube < 0
     C                   eval      ptcube = 0
 2E  C                   endif
 2B  C                   if        ptswgt < 0
     C                   eval      ptswgt = 0
 2E  C                   endif
 2B  C                   if        ptaisl < 0
     C                   eval      ptaisl = 0
 2E  C                   endif
 2B  C                   if        ptqty1 < 0
     C                   eval      ptqty1 = 0
 2E  C                   endif
 2B  C                   if        ptqty2 < 0
     C                   eval      ptqty2 = 0
 2E  C                   endif
 2B  C                   if        ptqty3 < 0
     C                   eval      ptqty3 = 0
 2E  C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
 1X  C                   when      $pcmd = '*CLOSE  '
     C                   eval      ptstat = '4'
     C****               exsr      zzgetu
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

417fAC                   if        ptsdte = 0
417fAC                   eval      ptsdte = ptgdte
417fAC                   eval      ptstim = ptgtim
417fAC                   endif

417fAC                   if        ptedte = 0
417fAC                   if        $pdate > 0
417fAC                   eval      ptedte = $pdate
417fAC                   eval      ptetim = $ptime
417fAC                   else
417fAC                   exsr      getdatetime
417fAC                   eval      ptedte = curdate
417fAC                   eval      ptetim = curtime
417fAC                   endif
417fAC                   endif

417fAC                   if        ptcdte = 0
417fAC                   eval      ptcdte = ptedte
417fAC                   eval      ptctim = ptetim
417fAC                   endif

710 Ac*     Set Ending and Close date with passed date for PRoduction
710 Ac*     transactions if passed.  Also call ADJTRANP to generate
710 Ac*     a transaction record to record, Mfg Line, WO# and Prod Date
710 Ac                   if        ptcat = 'PROD'
710 Ac                   if        $pdate>*zeros
710 AC                   eval      ptedte = $pdate
710 AC                   eval      ptetim = $ptime
710 AC                   eval      ptcdte = $pdate
710 AC                   eval      ptctim = $ptime
710 Ac                   endif
710 Ac                   eval      $pWhse = ptWhse
710 Ac                   call      'ADJTRANP'
710 Ac                   parm      $ptrn#        pttrn#
710 Ac                   parm                    pttask
710 Ac                   parm                    ptcat
710 Ac                   parm                    ptsub
710 Ac                   parm                    $pwhse
710 Ac                   parm      'A'           pcmd              1
710 Ac                   parm                    $puser
710 Ac                   endif
710 Ac
417fAC                   exsr      zztime
417fAC                   if        tktype = 'D'
417fAC                   eval      ptdmin = timlen
417fAC                   eval      ptimin = 0
417fAC                   else
417fAC                   eval      ptimin = timlen
417fAC                   eval      ptdmin = 0
417fAC                   endif
     *
 1X  C****               when      $pcmd = '*ENDCUR '
     C****               exsr      zzgetu
     C****               eval      ptshft = usshft
     C****               eval      ptcrew = uscrew
     C****               eval      ptemp# = usemp#
     C****               exsr      zzendc
     *
 1X  C                   when      $pcmd = '*UPDTIME'
     C                   exsr      zztime
417aAC                   if        tktype = 'D'
417fAC                   eval      ptdmin = timlen
417fAC                   eval      ptimin = 0
417fAC                   else
417fAC                   eval      ptimin = timlen
417fAC                   eval      ptdmin = 0
417fAC                   endif
     *
 1E  C                   endsl
     *
 1B  C****               if        $pcmd <> '*ENDCUR '
     C                   update    ptrec
640cAc                   exsr      zzwrttrand
 1E  C****               endif
     *
     *  When *CLOSEing a task, the possibility exists that a manual
     *  task might have been added during the task that is being
     *  closed. Therefore, check it out and make any necessary
     *  adjustments.
     *
 1B  C                   if        $pcmd = '*CLOSE  ' or
 1B  C                             $pcmd = '*UPDTIME'
     C                   exsr      zzcku1
 1E  C                   endif
     *
     C     out           tag
610aAC                   exsr      phpgmV1V2V3e
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
610aA*
610aA* Get client id.
610aA*
610aAC                   call      'GETCLIENT'
610aAC                   parm                    client           10
730dA*
730dA*  Define key for PIRTRANW
730dA*
730dAC     ptkeyw        klist
730dAC                   kfld                    $pwhse
730dAC                   kfld                    kytrn#
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
730dAC                   kfld                    $pwhse
     C                   kfld                    usemp#
     C                   kfld                    stdate
     *
     *     PIRTRAN2 file.
     *
     C     ptke22        klist
730dAC                   kfld                    $pwhse
     C                   kfld                    usemp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *     PIRTRAN1 file.
     *
     C     ptkey1        klist
730dAC                   kfld                    $pwhse
     C                   kfld                    usemp#
     C                   kfld                    kystat
500aA*
500aA*     Partial key for MULTRAN file.
500aA*
500aAC     keymu         klist
730dAC                   kfld                    $pwhse
500aAC                   kfld                    usemp#
500aAC                   kfld                    kystat2
730dA*
730dA*  Define partial key of whse/emp#
730dA*
730dAC     kyWhsEmp      klist
730dAC                   kfld                    $pwhse
     C                   kfld                    usemp#

PFCaA*  Define partial key for OPTIONS file.
PFCaAc     opkey2        klist
PFCaAc                   kfld                    kywhse            3 0
PFCaAc                   kfld                    kycode            8
PFCaA
PFCaA*   Check for APT logging option
PFCaAc                   eval      kywhse = 1
PFCaAc                   eval      kycode = '*APTFTP '
PFCaAc     opkey2        chain     options                            79
PFCaAc                   if        %found(options)
PFCaAc                             and %subst(opdata:1:1) = 'Y'
PFCaAc                   eval      logapt = *on
PFCaAc                   else
PFCaAc                   eval      logapt = *off
PFCaAc                   endif

     *
     *  Convert today's date into century format.
     *
     **                   MOVE '*CURCMD '$CVCMD
     **                   CALL @CVTDT
     **                   PARM           $CVTDT
     **                   Z-ADD$CVD8O    TODAY   80
     C                   endsr

500aA*----------------------------------------------------------------
500aA*  addmultran   Add MULTRAN record for employee.
500aA*----------------------------------------------------------------
500aA
500aAC     addmultran    BegSr

     C                   eval      muwhse = ptwhse
     C                   eval      mutrn# = pttrn#
     C                   eval      muemp# = ptemp#
     C                   eval      mustat = '1'
     C                   eval      musdte = ptsdte
     C                   eval      mustim = ptstim
     C                   eval      muedte = 0
     C                   eval      muetim = 0
     C                   write(e)  murec
     C                   if        %error
     C                   endif

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  delmultran   Delete MULTRAN record for transaction.
500aA*----------------------------------------------------------------
500aA
500aAC     delmultran    BegSr

730dDC**   pttrn#        chain     multran1
730dAC                   eval      kytrn# = $ptrn#
730dMC     ptkeyw        chain     multran1w
     C                   if        %found
     C                   delete    murec1
     C                   endif

     C                   endsr

417fA*----------------------------------------------------------------
417fA*  getdatetime  Get current date & time
417fA*----------------------------------------------------------------
417fA
417fAC     getdatetime   begsr

     C                   time                    curtime
     C                   time                    currentstamp

520 DC*                  if        curtime < lasttime or curdate = 0
520 MC                   if        curdate = 0 or
520 AC                             %date(currentstamp)<>%date(laststamp)
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime
520 AC                   eval      laststamp = currentstamp

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  getmultran   Get MULTRAN record for employee, if any.
500aA*----------------------------------------------------------------
500aA
500aAC     getmultran    BegSr

730dDC**   curtrn        chain(n)  multran1
730dAC                   eval      kytrn# = curtrn
740aDC*    ptkeyw        chain     multran1w
740aMC     ptkeyw        chain(n)  multran1w
     C                   if        %found
730bAC                             and ptemp# = muemp#
     C                   eval      mufound = *on
     C                   else
     C                   eval      mufound = *off
     C                   endif

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  gegmultran2  Get first MULTRAN record for employee.
500aA*----------------------------------------------------------------
500aA
500aAC     getmultran2   BegSr

     C                   eval      kystat2 = '1'
730dDC**   keymu         setll     multran
730dMC     keymu         setll     multranw
730dDC**   keymu         reade(n)  multran
730dMC     keymu         reade(n)  multranw
     C                   if        %eof
     C                   eval      mufound = *off
     C                   else
     C                   eval      mufound = *on
     C                   endif

     C                   endsr

     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
     C                   call      'PUTMSGP'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR7872  Record not updated.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7978  Record is locked.
     *
     C     zm7978        begsr
     C                   eval      #msgid = 'PIR7978'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

PFCaA
PFCaA*----------------------------------------------------------------
PFCaA*  ZZAPT   Call APT processing programs.
PFCaA
PFCaAc     zzapt         begsr
PFCaA
750bA         slgbuf = '<ZZAPT> '
750bA              + 'cmd=' + %trim($pCmd) + ' '
750bA              + 'user=' + %trimr(#curruser)  + ' '
750bA              + 'client=' + %trim(client) + ' '
750bA              + 'whs=' + %char(ptwhse)  + ' '
750bA              + 'trn=' + %char(pttrn#) + ' '
750bA              + 'logapt=' + %char(logapt) + ' '
750bA              + 'ptgrp1=' + ptgrp1;
750bA         WriteVoiceLog ('Beg': slgbuf);
PFCaAc                   eval      APSEQ# = APSEQ# + 1
PFCaA
PFCaAc                   select
PFCaAc                   when      aploc = 'BEGDAY'
PFCaAc                   eval      aploc = 'S     '
PFCaAc                   when      aploc = 'BREAK '
PFCaAc                   eval      aploc = 'B     '
PFCaAc                   when      aploc = 'ENDDAY'
PFCaAc                   eval      aploc = 'E     '
PFCaAc                   when      aploc = 'IDLE  '
PFCaAc                   eval      aploc = 'I     '
PFCaAc                   when      aploc = 'LUNCH '
PFCaAc                   eval      aploc = 'L     '
PFCaAc                   when      aploc = 'BATCHG'
PFCaAc                   eval      aploc = 'X     '
PFCaAc                   when      aploc = 'CLEAN '
PFCaAc                   eval      aploc = 'C     '
PFCaAc                   when      aploc = 'DROP  '
PFCaAc                   eval      aploc = 'D     '
PFCaAc                   when      aploc = 'LOAD  '
PFCaAc                   eval      aploc = 'O     '
PFCaAc                   when      aploc = 'MTG   '
PFCaAc                   eval      aploc = 'M     '
PFCaAc                   when      aploc = 'MISC  '
PFCaAc                   eval      aploc = 'Z     '
PFCaAc                   endsl
PFCaA
PFCaAc                   CALL      'APTMAIN'
PFCaAc                   PARM                    APCMD            10
PFCaAc                   PARM      #PROG         APPGM            10
PFCaAc                   PARM      PTWHSE        APWHSE            3 0
PFCaAc                   PARM      0             APLBL#            7 0
PFCaAc                   PARM                    APTRN#            7 0
PFCaAc                   PARM      #USER         APUSER           10
PFCaAc                   PARM      USEMP#        APEMP#            5 0
PFCaAc                   PARM      *BLANKS       APRTID            5
PFCaAc                   PARM      *BLANKS       APRTE             5
PFCaAC                   PARM                    APLOC            20
PFCaAC                   PARM                    APSEQ#            5 0
PFCaAC                   PARM                    APRTN            10
PFCaAC                   PARM                    APMSG            60
PFCaA
PFCaAC                   endsr

510bA*----------------------------------------------------------------
510bA*  ZZBEGENDDAY   Create Beg/End day transaction
510bA*----------------------------------------------------------------
510bA
510bAC     zzbegendday   begsr
700aAC                   if        opfound = *off
     C                   exsr      getdatetime

     *  Get task information.

     C                   if        $pcmd = '*BEGDAY'
     C                   eval      $ptask = 'BEGDAY'
     C                   else
     C                   eval      $ptask = 'ENDDAY'
     C                   endif

     C     $ptask        chain     task                               79
     C                   if        *in79
     C                   eval      tkcat = *blanks
     C                   eval      tksub = *blanks
     C                   endif

     *  Create ended transaction record.

     C                   clear                   ptrec
     C                   call      'PIRTRN#'
     C                   parm                    $ptrn#
     C                   eval      pttrn# = $ptrn#
     C                   eval      ptwhse = $pwhse
640aAC                   if        ptwhse = 0
640aAC                   eval      ptwhse = uswhse
640aAC                   endif
     C                   eval      pttask = $ptask
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   eval      ptstat = '4'
     C                   eval      ptetyp = 'N'
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

     C                   if        $pdate > *zeros
     C                   eval      ptgdte = $pdate
     C                   eval      ptgtim = $ptime
     C                   eval      ptsdte = $pdate
     C                   eval      ptstim = $ptime
     C                   eval      ptedte = $pdate
     C                   eval      ptetim = $ptime
     C                   eval      ptrdte = $pdate
     C                   else
     C                   eval      ptgdte = curdate
     C                   eval      ptgtim = curtime
     C                   eval      ptsdte = curdate
     C                   eval      ptstim = curtime
     C                   eval      ptedte = curdate
     C                   eval      ptetim = curtime
     C                   eval      ptrdte = curdate
     C                   endif

     C                   write     ptrec
640cAc                   exsr      zzwrttrand

     *  Create Idle record after BEGDAY.

     C                   if        $pcmd = '*BEGDAY'

     C                   clear                   ptrec
     C                   call      'PIRTRN#'
     C                   parm                    $ptrn#
     C                   eval      pttrn# = $ptrn#
     C                   eval      ptwhse = $pwhse
640aAC                   if        ptwhse = 0
640aAC                   eval      ptwhse = uswhse
640aAC                   endif
     C                   eval      pttask = 'IDLE'
     C                   eval      ptcat = 'MISC'
     C                   eval      ptsub = 'IDLE'
     C                   eval      ptstat = '2'
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

     C                   if        $pdate > *zeros
     C                   eval      ptgdte = $pdate
     C                   eval      ptgtim = $ptime
     C                   eval      ptsdte = $pdate
     C                   eval      ptstim = $ptime
     C                   eval      ptrdte = $pdate
     C                   else
     C                   eval      ptgdte = curdate
     C                   eval      ptgtim = curtime
     C                   eval      ptsdte = curdate
     C                   eval      ptstim = curtime
     C                   eval      ptrdte = curdate
     C                   endif

     C                   write     ptrec
640cAc                   exsr      zzwrttrand

     C                   endif

700aAC                   endif
700aAC                   eval      opfound=*off

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU1   Check for overlapping manual task.
     *
     C     zzcku1        begsr
     *
     C                   z-add     pttrn#        svtrn#
     *  Past overnight. (PTEDTE > PTSDTE)
 1B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 1X  C                   else
     C                   z-add     ptsdte        stdate
 1E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
610aAC                   eval      currRoutine = 'zzcku2'
610aAC                   exsr      phpgmV1V2V3s
     C                   eval      svtlen = 0
730dDC**   ptkey2        setll     pirtran2
730dMC     ptkey2        setll     pirtran2w
 1B  C                   dow       forevr = forevr
730dDC**                 read      pirtran2                               79
730dMC     kyWhsEmp      reade     pirtran2w                              79
 2B  C                   if        *in79  or
     C                             ptsdte < zzsdte
 1L  C                   leave
 2E  C                   endif
     *   Skip the task that just ended.
 2B  C                   if        not *in79  and
     C                             pttrn# = svtrn#
 1I  C                   iter
 2E  C                   endif
     *
     *   Skip 'IDLE' task
     *
 2B  C                   if        pttask = 'IDLE'
 1I  C                   iter
 2E  C                   endif
     *
     C     pttask        chain     task                               79
 2B  C                   if        *in79
     C                   eval      tktype = ' '
 2E  C                   endif
     *   Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *   Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *   Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
 1E  C                   enddo
     *
     *   Update the task that just ended.
     *
730dDC**   svtrn#        chain     pirtran                            79
730dAC                   eval      kytrn# = svtrn#
730dMC     ptkeyw        chain     pirtranw                           79
 1B  C                   if        not *in79
 2B  C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
 2X  C                   else
     C                   eval      ptimin = ptimin - svtlen
 2E  C                   endif
     C                   update    ptrec
640cAc                   exsr      zzwrttrand
 1E  C                   endif
610aAC     endcu2        tag
610aAC                   exsr      phpgmV1V2V3e
610aMC                   endsr

     *----------------------------------------------------------------
     *  ZZCREATE   Create transaction (from ADDSTDTRN2)
     *----------------------------------------------------------------

     C     zzcreate      begsr
500aA
500aA*  Get task information.
500aA
500aAC     $ptask        chain     task                               79
500aAC                   if        *in79
500aAC                   eval      tkcat = *blanks
500aAC                   eval      tksub = *blanks
500aAC                   endif

     *  Create transaction record.

     *    Note: The task tracking level determines whether or not the
     *          department and the section are written to the transaction
     *          record.  This was done in order to make it possible to
     *          use a simple join between the transaction records and
     *          the task detail file which contains the standards.

     C                   clear                   ptrec
     C                   if        $ptrn# = 0
     C                   call      'PIRTRN#'
     C                   parm                    $ptrn#
     C                   endif
     C                   eval      pttrn# = $ptrn#
     C                   eval      ptwhse = $pwhse
640aAC                   if        ptwhse = 0
640aAC                   eval      ptwhse = uswhse
640aAC                   endif
     C                   eval      pttask = $ptask
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
 1B  C                   select
 1X  C                   when      tktlvl = 'D'
     C                   eval      ptwhdp = $pwhdp
 1X  C                   when      tktlvl = 'S'
     C                   eval      ptwhdp = $pwhdp
     C                   eval      ptstyp = $pstyp
 1E  C                   endsl
     C                   eval      ptcube = $pcube
     C                   eval      ptswgt = $pswgt
     C                   eval      ptpcs  = $ppcs
     C                   eval      ptaisl = $paisl
     C                   eval      ptqty1 = $pqty1
     C                   eval      ptqty2 = $pqty2
     C                   eval      ptqty3 = $pqty3

 1B  C                   select

     *    Use date/time passed in for Generated date/time.

 1X  C                   when      $pdate > *zeros
     C                   eval      ptgdte = $pdate
     C                   eval      ptgtim = $ptime

 1X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptgdte = $cvd8o
417fDC**                 time                    ptgtim
417fAC                   exsr      getdatetime
417fAC                   eval      ptgdte = curdate
417fAC                   eval      ptgtim = curtime
 1E  C                   endsl
 1B  C                   if        $ppo <> *blanks
     C                   eval      ptrtpo = $ppo
 1X  C                   else
     C                   movel     $prte         ptrtpo
 1E  C                   endif

 1B  C                   select

     *    Use date/time passed in for Report date/time.

 1X  C                   when      $pdate > *zeros
     C                   eval      ptrdte = $pdate

 1X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptrdte = $cvd8o
417fAC                   exsr      getdatetime
417fAC                   eval      ptrdte = curdate
 1E  C                   endsl

     C                   eval      ptgrp1 = $pgrp1
     C                   eval      ptgrp2 = $pgrp2

 1B  C                   select
 1X  C                   when      $pcmd = '*CREATE '
     C                   eval      ptstat = *on

 1X  C                   when      $pcmd = '*CRTSTRT'
     C                   eval      ptstat = '2'
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

730aAC                   when      $pcmd = '*CRTCLOSED'
730aAC                   eval      ptstat = '4'
730aAC                   eval      ptcdte = ptgdte
730aAC                   eval      ptctim = ptgtim

510cAC                   when      $pcmd = '*STARTI'
510cAC                   eval      ptstat = '2'
510cAC                   eval      ptshft = usshft
510cAC                   eval      ptcrew = uscrew
510cAC                   eval      ptemp# = usemp#
610bAC                   endsl

610bAC                   if           $pcmd = '*CRTSTRT'
610bAC                             or $pcmd = '*STARTI'
610bA*
 2B  C                   select

     *    Use date/time passed in for Transaction start date/time.

 2X  C                   when      $pdate > *zeros
     C                   eval      ptsdte = $pdate
     C                   eval      ptstim = $ptime

 2X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptsdte = $cvd8o
417fDC**                 time                    ptstim
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime

 2E  C                   endsl
610bDC**                 endsl
610bA*
610bMC                   endif

     C                   write     ptrec
640cAc                   exsr      zzwrttrand

     *  Update task totals

 1X  C                   if        $pcmd = '*CRTSTRT'
510cAC                             or $pcmd = '*STARTI'
     C                   eval      @pcmd = '*START'
     C                   else
     C                   eval      @pcmd = '*GEN'
     C                   endif

     C                   call      @adjtd
     C                   parm                    @pcmd             8
     C                   parm                    $ptype
     C                   parm                    ptparm
     C                   parm                    $prtn
     C                   parm                    $pmsg

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
     C     zzend         begsr
610aAC                   eval      currRoutine = 'zzend'
610aAC                   exsr      phpgmV1V2V3s
500aA*
500aA*  If transaction is part of a multiple transaction selection
500aA*   then close it with a different program.
500aA*
500aAC                   exsr      getmultran
500aAC                   if        mufound
500aAC                   eval      $temp# = usemp#
500aAC                   eval      $tstat = '*'
610aAC                   eval      currRoutine = 'TE130'
610aAC                   exsr      phpgmV1V2V3s
500aAC                   call      'TE130'
500aAC                   parm                    $te130
500aAC                   parm                    $trtn             8
610aAC                   exsr      phpgmV1V2V3e
500aAC                   goto      endend
500aAC                   endif
500aAC*
     *  No current task to end.
     C     curtrn        cabeq     0             endend
     *  End current task
730dDC**   curtrn        chain     pirtran                            79
730dAC                   eval      kytrn# = curtrn
730dMC     ptkeyw        chain     pirtranw                           79
 1B  C                   if        not *in79
 2B  C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
710 AC                             and ptcat <> 'PROD'
     C                   eval      ptstat = '3'
 2X  C                   else
     C                   eval      ptstat = '4'
 2E  C                   endif
     C                   eval      ptetyp = 'N'
 1E  C                   endif
510a *  Set END date/time for *CRTSTRT
510a C                   if        $pcmd = '*CRTSTRT' and
510a C                             $pdate > 0
510a C                   z-add     $pdate        ptedte
510a C                   z-add     $ptime        ptetim
710 Ac                   if        ptcat = 'PROD'
710  C                   z-add     $pdate        ptcdte
710  C                   z-add     $ptime        ptctim
710 Ac                   endif
510a C                   eval      @pcmd = '*END2   '
510a C                   else
710 Ac                   if        ptcat = 'PROD'
710 Ac*    If this is a Production Transaction and Date/Time is
710 Ac*    passed then force that Date/Time on Transaction, otherwise
710 Ac*    pass current system time.  The Date and Time are only passed
710 Ac*    for Standard defined transactions added during EOD from
710 Ac*    DRIPROD
710 Ac                   if        $pdate <> *zeros
710 Ac                   eval      ptedte = $pdate
710 Ac                   eval      ptetim = $ptime
710 Ac                   eval      ptcdte = $pdate
710 Ac                   eval      ptctim = $ptime
710 Ac                   else
710 AC                   exsr      getdatetime
710 AC                   eval      ptedte = curdate
710 AC                   eval      ptetim = curtime
710 AC                   eval      ptcdte = curdate
710 AC                   eval      ptctim = curtime
710 Ac                   endif
710 AC                   exsr      zztime
710 AC                   if        tktype = 'D'
710 AC                   eval      ptdmin = timlen
710 AC                   eval      ptimin = 0
710 AC                   else
710 AC                   eval      ptimin = timlen
710 AC                   eval      ptdmin = 0
710 AC                   endif
710 Ac                   endif
510a C                   eval      @pcmd = '*END    '
510a C                   endif
     *
610aAC                   eval      currRoutine = 'ADJTASKDET'
610aAC                   exsr      phpgmV1V2V3s
     C                   call      @adjtd
510aDC*                  parm      '*END    '    @pcmd
510aMC                   parm                    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
610aAC                   exsr      phpgmV1V2V3e
     *
     C                   update    ptrec                                79
 1B  C                   if        *in79
     C                   eval      error = *on
     **                   EXSR ZM72
goto Csr                 goto      endend
 1E  C                   endif
640cAc                   exsr      zzwrttrand
710 Ac                   call      'ADJTRANP'
720 Dc*                  parm      $ptrn#        pttrn#
720 Ac                   parm                    pttrn#
710 Ac                   parm                    pttask
710 Ac                   parm                    ptcat
710 Ac                   parm                    ptsub
710 Ac                   parm                    $pwhse
710 Ac                   parm      'A'           pcmd              1
710 Ac                   parm                    $puser
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *  Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
610aAC     endend        tag
610aAC                   exsr      phpgmV1V2V3e
610aMC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZENDC   End current transaction for user.
     *
     C     zzendc        begsr
610aAC                   eval      currRoutine = 'zzendc'
610aAC                   exsr      phpgmV1V2V3s

700aAC                   eval      opfound = *off

     *  Get current task.

     C                   exsr      zztask
     C     found         cabeq     *off          endendc

     *  Get out if task is IDLE but we don't want to end an IDLE task.

     C                   if        $pcmd = '*ENDNONIDL' and
     C                             pttask = 'IDLE'
     C                   goto      endendc
     C                   endif
700aA
700aA*  Get out if Selection task is open and begday or endday
700aAC                   select
700aAC                   when      client = ISupply or
700aAC                             client = SOFO or
700aAC                             client = JSilvert or
700aAC                             client = FoodPro or
700aAC                             client = CapitolCity or
SBRaAC                             client = SBertram or
GMMaAC                             client = MenuMaker or
TPCaAC                             client = TPC or
CFIaAC                             client = Colony or
CLDaAC                             client = CityLine or
FBYaAC                             client = FarmBoy  or
DRYaAC                             client = DairyLand or
EIa AC                             client = ei
700aA
700aAC                   if        $pcmd = '*BEGDAY' and
700aAC                             pttask <> 'IDLE' and
700aAC                             ptgrp1 = 'S'
700aAC                             or $pcmd = '*ENDDAY' and
700aAC                             pttask <> 'IDLE' and
700aAC                             ptgrp1 = 'S'
700aAC                   eval      opfound = *on
700aAC                   goto      endendc
700aAC                   endif
700aAC                   endsl
500aA
500aA*  Get out if Selection task but we don't want to end it.
500aA
500aAC                   if        $pcmd = '*ENDNONSEL' and
500bAC                             pttask <> 'IDLE' and
500aAC                             ptgrp1 = 'S'
500aAC                   goto      endendc
500aAC                   endif
500aA
500aA*  For *STARTMULT only end an IDLE task.
500aA
500aAC                   if        $pcmd = '*STARTMULT' and
500aAC                             pttask <> 'IDLE'
500aAC                   goto      endendc
500aAC                   endif

     *  End open task.
     *    If task is Direct, just end it and get out.
     *    If task is Indirect, end it and any other open tasks.
510cA*       unless Selection task but we don't want to end it.

 1B  C                   select
 1X  C                   when      curtyp = 'D'
     C                   exsr      zzend
750bA         slgbuf = '<ZZENDC> '
750bA              + 'cmd=' + %trim($pCmd) + ' '
750bA              + 'user=' + %trimr(#curruser)  + ' '
750bA              + 'client=' + %trim(client) + ' '
750bA              + 'whs=' + %char(ptwhse)  + ' '
750bA              + 'trn=' + %char(pttrn#) + ' '
750bA              + 'logapt=' + %char(logapt) + ' '
750bA              + 'ptgrp1=' + ptgrp1;
750bA         WriteVoiceLog ('Beg': slgbuf);

 1X  C                   when      curtyp = 'I'
 2B  C                   dow       forever = forever
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   exsr      zztask

 3B  C                   if        found = *off
 2L  C                   leave
PFCaA
750aDc**                 else
750aDc**                 if        logapt
750aDc**   Send APT INDIRECT Transaction.
750aDc**                 eval      apcmd = APTSK2
750aDc**                 eval      aptrn# = CURTRN
750aDc**                 eval      aploc = CURTSK
750aDc**                 exsr      zzapt
750aDc**                 endif

 3E  C                   endif
     *      We are going to assume that when we hit a select task and
     *      the command is *ENDNONSEL that there are no other open
     *      tasks that will come before it that will need to be closed.
     *      Therefore we will just get out of the loop.
510cAC                   if        $pcmd = '*ENDNONSEL' and
510cAC                             pttask <> 'IDLE' and
510cAC                             ptgrp1 = 'S'
510cAC                   leave
510cAC                   endif
     C                   exsr      zzend
750aAC*    Send APT INDIRECT Transaction.
750aAc                   if        logapt
750aAc                   eval      apcmd = APTSK2
750aAc                   eval      aptrn# = CURTRN
750aAc                   eval      aploc = CURTSK
YHAaAc                   if        client<>Yhata
750aAc                   exsr      zzapt
YHAaAc                   endif
750aAc                   endif
 2E  C                   enddo

 1E  C                   endsl

610aAC     endendc       tag
610aAC                   exsr      phpgmV1V2V3e
610aMC                   endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZENDI  End current Indirect task.
417aA*
417aAC     zzendi        begsr
     *
     *    Find any open tasks.
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   eval      found = *off
     C                   exsr      zztski
     *
     *    End current Indirect task
417bA*    or IDLE Direct task.
 1B  C                   if        curent = *on  and
     C                             curtyp = 'I'
417bAC                             or curent = *on  and
417bAC                             curtyp = 'D' and curtsk = 'IDLE '
     *
730dDC**   curtrn        chain     pirtran                            79
730dAC                   eval      kytrn# = curtrn
730dMC     ptkeyw        chain     pirtranw                           79
 2B  C                   if        not *in79
     C                   eval      ptstat = '4'
     C                   eval      ptetyp = 'N'
     *
 3B  C                   if        ptsdte = *zeros
     C                   eval      ptsdte = ptgdte
     C                   eval      ptstim = ptgtim
 3E  C                   endif
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptcdte = $cvd8o
     C                   time                    ptctim
     *
     C                   eval      ptedte = $cvd8o
     C                   eval      ptetim = ptctim
     *
     *    Calculate time duration for this Indirect task.
417bA*    or Direct IDLE task.
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptctim
     C                   exsr      zztime
417bAC                   if        curtyp = 'D' and curtsk = 'IDLE  '
417bAC                   eval      ptdmin = timlen
417bAC                   else
     C                   eval      ptimin = timlen
417bAC                   endif
     *
     C                   update    ptrec                                79
 3B  C                   if        *in79
     C                   move      *on           error
     C                   eval      $prtn = '*ERROR  '
goto Csr                 goto      endi
 3E  C                   endif
640cAc                   exsr      zzwrttrand
 2E  C                   endif
PFCbA
PFCbAc                   if        logapt
PFCbAc*    Send APT INDIRECT Transaction.
PFCbAc                   eval      apcmd = APTSK2
PFCbAc                   eval      aptrn# = CURTRN
PFCbAc                   eval      aploc = CURTSK
YHAaAc                   if        client<>Yhata
PFCbAc                   exsr      zzapt
YHAaAc                   endif
PFCbAc                   endif
PFCbA
 1X  C                   else
     C                   eval      $prtn = '*ERROR  '
 1E  C                   endif
640bA*   create idle if closing indirect not an IDLE
640bAC                   if        $pcmd = '*CLOSEI' and
640bAc                             $prtn <> '*ERROR  '  and
640bAc                             curtsk <> 'IDLE '
640bAc                   exsr      zztask
640bAc                   if        found = *off
640bAC                   exsr      getdatetime
640bAC                   clear                   ptrec
640bAC                   call      'PIRTRN#'
640bAC                   parm                    $ptrn#
640bAC                   eval      pttrn# = $ptrn#
640bAC                   eval      ptwhse = $pwhse
640bAC                   if        ptwhse = 0
640bAC                   eval      ptwhse = uswhse
640bAC                   endif
640bAC                   eval      pttask = 'IDLE'
640bAC                   eval      ptcat = 'MISC'
640bAC                   eval      ptsub = 'IDLE'
640bAC                   eval      ptstat = '2'
640bAC                   eval      ptshft = usshft
640bAC                   eval      ptcrew = uscrew
640bAC                   eval      ptemp# = usemp#
640bA
640bAC                   eval      ptgdte = curdate
640bAC                   eval      ptgtim = curtime
640bAC                   eval      ptsdte = curdate
640bAC                   eval      ptstim = lasttime
640bAC                   eval      ptrdte = curdate
640bA
640bAC                   write     ptrec
640cAc                   exsr      zzwrttrand
640bA
640bAc                   endif
640bAc                   endif
     *
     C     endi          endsr
     *----------------------------------------------------------------
     *
     *  ZZGETU   Get user
     *
     C     zzgetu        begsr
     C                   if        $puser <> *blanks
     C     $puser        chain     piruser                            79
     C                   else
     C     #user         chain     piruser                            79
     C                   endif
 1B  C                   if        *in79
     C                   eval      usshft = *blanks
     C                   eval      uscrew = *blanks
     C                   eval      usemp# = 0
640aAC                   eval      uswhse = 0
 1E  C                   endif
     C                   endsr

500cA*----------------------------------------------------------------
500cA*
500cA*  ZZSUS  Suspend current task.
500cA*
500cAC     zzsus         begsr
500cAC                   eval      curtrn = $ptrn#
     *
     *  If transaction is part of a multiple transaction selection
     *   then close it with a different program.
     *
     C                   exsr      getmultran
     C                   if        mufound
     C                   eval      $temp# = usemp#
     C                   eval      $tstat = 'S'
     C                   call      'TE130'
     C                   parm                    $te130
     C                   parm                    $trtn             8
     C                   goto      endsus
     C                   endif
     C*
     *  No current task to end.
     C     curtrn        cabeq     0             endsus
     *  Suspend current task
730dDC**   curtrn        chain     pirtran                            79
730dAC                   eval      kytrn# = curtrn
730dMC     ptkeyw        chain     pirtranw                           79
     C                   if        not *in79
     C                   eval      ptstat = '8'
     C                   endif
     *
     C                   update    ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   goto      endsus
     C                   endif
640cAc                   exsr      zzwrttrand
     *
     C     endsus        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
610aAC                   eval      currRoutine = 'zztask'
610aAC                   exsr      phpgmV1V2V3s

     C                   eval      found = *off

     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   move      '2'           kystat
730dDC**   ptkey1        setll     pirtran1
730dMC     ptkey1        setll     pirtran1w
610aAC                   eval      currRoutine = 'readtran1'
610aAC                   exsr      phpgmV1V2V3s
730dDC**   ptkey1        reade     pirtran1                               79
730dMC     ptkey1        reade     pirtran1w                              79
610aAC                   exsr      phpgmV1V2V3e
 1B  C                   if        *in79
goto C                   goto      endtsk
 1E  C                   endif
     *
730dDC**   ptke22        setll     pirtran2
730dMC     ptke22        setll     pirtran2w
610aAC                   eval      currRoutine = 'looptran2'
610aAC                   exsr      phpgmV1V2V3s
 1B  C                   dow       forevr = forevr
530aDC**                 read      pirtran2                               79
610aAC*****              eval      currRoutine = 'readtran2'
610aAC*****              exsr      phpgmV1V2V3s
730dDC**   usemp#        reade     pirtran2                               79
730dMC     kyWhsEmp      reade     pirtran2w                              79
610aAC*****              exsr      phpgmV1V2V3e
 2B  C                   if        *in79  or
     C                             ptemp# <> usemp#
 1L  C                   leave
 2E  C                   endif
417aMC                   if        ptstat <> '2' or
417aA*
417aA*    If closing Indirect task, make sure that current Direct
417aA*    task isn't selected to be closed.
417aAC                             $pcmd = '*CLOSEI '  and
417aAC                             pttrn# = $ptrn#
 1I  C                   iter
 2E  C                   endif
     *   Found an active transaction
     C                   move      *on           found
     C                   z-add     pttrn#        curtrn
     C     pttask        chain     task                               79
 2B  C                   if        not *in79
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 2E  C                   endif
 1L  C                   leave
 1E  C                   enddo
610aAC                   exsr      phpgmV1V2V3e
610aAC     endtsk        tag
610aAC                   exsr      phpgmV1V2V3e
610aMC                   endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZTSKI  Get current Indirect task.
417aA*
417aAC     zztski        begsr
     *
     C                   move      '2'           kystat
730dDC**   ptkey1        setll     pirtran1
730dMC     ptkey1        setll     pirtran1w
 1B  C                   dow       forevr = forevr
730dDC**   ptkey1        reade     pirtran1                               79
730dMC     ptkey1        reade     pirtran1w                              79
 2B  C                   select
 2X  C                   when      *in79
     C                   move      *off          found
     C                   move      *off          curent
 1L  C                   leave
     *
     *    When closing Indirect task, make sure that current Direct
     *    task isn't selected to be closed.
 2X  C                   when      pttrn# = $ptrn#
 1I  C                   iter
     *
 2X  C                   other
     *
     C     pttask        chain     task                               79
 3B  C                   select
     *    Task record not found. Find next record.
 3X  C                   when      *in79
 1I  C                   iter
     *    Not a Indirect task. Find next record.
417bDC*                  when      tktype <> 'I'
417bA*    or Not a Direct IDLE task. Find next record.
417bAC                   when      tktype = 'D' and tkcode <> 'IDLE  '
 1I  C                   iter
     *    Process Indirect task.
 3X  C                   when      tktype = 'I'
417bA*    or Process Direct IDLE task.
417bAC                             or tktype = 'D' and tkcode = 'IDLE  '
     C                   move      *on           curent
     C                   move      *on           found
     C                   z-add     pttrn#        curtrn
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 1L  C                   leave
 3E  C                   endsl
 2E  C                   endsl
 1E  C                   enddo
     *
     C     endtki        endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
417fAC                   eval      strtim = ptstim
417fAC                   eval      fintim = ptetim
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *   Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     C     dshh          mult      60            tmpbeg
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *   Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
 1B  C                   if        fintim < strtim
     C                   add       24            dshh
 1E  C                   endif
     C     dshh          mult      60            tmpend
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
 1B  C                   if        timlen < 0
     C                   eval      timlen = 0
 1E  C                   endif
     *
     C     endtim        endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*  Phrase Routines
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*  pushRoutine  -  Add routine to stack
610aA*----------------------------------------------------------------
610aA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

610aA*----------------------------------------------------------------
610aA*  popRoutine  -  Remove routine from stack
610aA*----------------------------------------------------------------
610aA
      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free

610aA*----------------------------------------------------------------
610aA*  phClearVars  - Clear phrase variables
610aA*----------------------------------------------------------------
610aA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


610aA*----------------------------------------------------------------
610aA*  zzWrtPhrase  - Write logging phrase
610aA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

RYLaA    if client <> royal;
RYLaA         leavesr;
RYLaA    endif;
RYLaA    if client = royal;
RYLaA      if usemp# <> 779
RYLaA         and usemp# <> 1134
RYLaA         and usemp# <> 1173;
RYLaA           leavesr;
RYLaA      endif;
RYLaA    endif;

         pWhse = 0;
         pEmp# = usemp#;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = ' ';
         pWhdp = ' ';
         pLocation = ' ';
         pTrn# = 0;
         pLcns = ' ';
         pLtrn = 0;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free

         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640cA*
640cA /free
640cA   begsr zzwrttrand;
640cA     wrtpcmd = '*ONETRAN';
640cA     wrtpwait = 0;
640cA     wrtpwhse = %dec(ptwhse);
640cA     wrtptran# = pttrn#;
640cA     wrtpfrmdate = 0;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRANDL Execute new WRTTRAN1 program to turn off flags/indicators
640cA*
640cA /free
640cA   begsr zzwrttrandl;
640cA     wrtpcmd = '*DLTTRAN';
640cA     wrtpwait = 0;
640cA     wrtpwhse = %dec(ptwhse);
640cA     wrtptran# = pttrn#;
640cA     wrtpfrmdate = 0;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
610aA*----------------------------------------------------------------
610aA*  phPgmV1V2V3e
610aA*----------------------------------------------------------------
610aA
      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

610aA*----------------------------------------------------------------
610aA*  phPgmV1V2V3s
610aA*----------------------------------------------------------------
610aA
      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free

750bA*----------------------------------------------------------------
750bA*  WriteVoiceLog    Write record to voice log BFCSKTLOG
750bA*----------------------------------------------------------------
750bA
750bAp WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       GetCurrStamp();

       slgTyp = type;

       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #pgm;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

750bAp                 e

750bA*----------------------------------------------------------------
750bA*  GetCurrStamp  Get current timestamps
750bA*----------------------------------------------------------------
750bA
750bAp GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

750bAp                 e
**
Transaction
