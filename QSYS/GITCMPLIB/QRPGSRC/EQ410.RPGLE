      /copy qcopysrc,hspecs

      *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  EQ410     Equipment Check In/Out
     *  06 January 2003
     *  Roxanne Harrison
     *
NOTE *  NOTE:  Need to create indirect task entry for EQCHK
     *
     *  Revisions
417  *    01/06/03  RH   4.17
     *      - Created.
417a *    03/27/03  RH   4.17a
     *      - Program will skip questions if employee # is 88888 for repair
417b *    06/23/03  RH   4.17b
     *      - Will NOT create work order if open work order exists for the
     *        same question. Will update EQUIPA with the existing work order#
417c *    02/18/04  RH   4.17c
     *      - Update EQUIPA status=3 if rec has existing work order.
417c *    04/29/04  RH   4.17d
     *      - Increase EQ ID from 6 to 8
500 A*    02/09/05  RH   500
     *      - Added F7 to print test label for belt printer BLTPRT.
500aA*    03/01/05  DAS  500a
     *      - Added routine ZZPRTLBL to be called with F7 is pressed.
500aA*    09/12/05  RH   500b
     *      - Enh: Add SCREEN3 for Meter hour entry.
510aA*    03/06/07  RH   610a
      *      Added 1/13/12 to V6.40, missed in update
     *      - Fix: Get current task to set CURTASK and CURTYP values
     *        Was closing transaction with previous transaction values
     *        leaving EQCHK transaction at '3' status in error.
520aA*    01/30/09  RH   520a
     *      - Enh: Add window to begin / end day for BLTPRT check in
     *        or out. Does BEGDAY before EQCHK, ENDDAY after EQCHK
520bA*    04/16/09  RBD  5.20b
     *      - Fix: Commented out 'enter' field, which is not being
     *        used, but because C#STDVAR now includes 'enter' as a
     *        constant, this pgm would not compile because of the 2
     *        different definitions for 'enter'.
640aA*    12/02/11  RH   6.40a
     *      - Fix: Update Add next work order record if not found.
     *        Increment work order# and retry add if error writing.
640bA*    06/05/12  LMC  6.40b
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
640cA*    10/25/12  JCJ  6.40c
     *      - Enh: Renamed EQ410FM to EQ41001.
650aA*    03/28/14  LMC  6.50a
     *      - Enh: Added EQUIPM file with link to process control.
700a *    07/15/16  GJA  7.00a
     *      - Fix: When you checked in/out equipment it was ending
     *             the selection transaction if you answered "N" to
700b *    08/09/16  NLK  7.00b
     *      - Fix: Add PirUserA to make sure empl# is a belt prt user
700c *    12/14/16  NLK  7.00c
     *      - Fix: Add PirUserA ONLY if Checking OUT a belt prt user
     *      - ENH: Add w1type to know input equipment
710a *    02/15/17  RH   7.10a
     *      - Enh: Add small 20 character screens for 8X20 & 16X20
     *        screens.
710a *    12/19/17  MR
     *      - Recompiled due to database change to PIRUSERA
720a *    07/23/18  LMC
     *      - Added retreiving the empl# for the signed on user.
     *        This will only occur if the future RF option opeqpj
     *        is turned on
     *      - This new RF option will tell us if the client forces
     *        Their user to checkout a pallet jack.
     *      - Temporarily defining the opeqpj field until the RF
     *        option is created.
     *----------------------------------------------------------------
     *  CUSTOM:
     *----------------------------------------------------------------
     * Cheney Custom Mods
     *   All Cheney custom mods should be conditioned with ...
     *      'if client = cheney'
     *   or 'client  cabne  cheney   skipcheney1'
     *   or 'select / when client = cheney / other / endsl'
     *
CBIa *    03/30/04  RH   CBIa
     *      - Remove check to prevent check out if already checked out.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLD A*    09/23/09  RBD  CLD   P#00221
     *      - Default 'Begin day' / 'End day' to Y rather than N.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/04/19  KDE   DRY
     *      - Override Belt Printer error for user
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHL A*    07/25/18  LMC  KHLa
     *      - Seton opeqpj until the rf option is created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHL A*    07/25/18  LMC  KHLa
     *      - Seton opeqpj until the rf option is created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SouthWest Trader
     *
SWTa *    03/31/19  GJA  SWTa
     *      - Seton opeqpj until the rf option is created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  70        Error on update to SLOT1 record
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
500 A*  89        Client    (Non-display fields)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640cD *EQ410fm   cf   e             workstn usropn
710aD *EQ41001   cf   e             workstn usropn
710aMFEQ41002   cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fequip     if   e           k disk
     Fequipt1   if   e           k disk
     Fequipt2   if   e           k disk
     F                                     rename(etrec:etrec2)
     Fpiruser1  if   e           k disk
700bAFpirusera  if   e           k disk
     Fequipq    if   e           k disk
     Fequipa    uf a e           k disk
417b Fequipa2   if   e           k disk
417b F                                     rename(earec:earec2)
650aAFequipm    if   e           k disk
     Fequipw    uf a e           k disk
417b Fequipw2   if   e           k disk
417b F                                     rename(ewrec:ewrec2)
640aDF*irew#    uf   e           k disk
640aMFpirew#    uf a e           k disk
     Fpirtran   uf a e           k disk
     Ftask      if   e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
500b Fequiph    uf a e           k disk
500b Fequiph1   if   e           k disk
500b F                                     rename(ehrec:ehrec1)
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

417nA /copy qcopysrc,id#cheney
CLD A /copy qcopysrc,id#citylin
DRY A /copy qcopysrc,id#dairyla
KHLaA /copy qcopysrc,id#khl
SWTaA /copy qcopysrc,id#swt
417nAD client          s             10

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
415eAD a30             s              1    dim(30)
415eDD*desc            s             50    dim(5) ctdata perrcd(1)
520aDD*desc            s             50    dim(7) ctdata perrcd(1)
700bDD*desc            s             50    dim(9) ctdata perrcd(1)
700bMD desc            s             50    dim(10) ctdata perrcd(1)
650aAD $lparm1         s             48    dim(20)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

416lA /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#EQUIPT
     D saveVer#        s                   like($etver#)
     D savetrn#        s                   like($ettrn#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

640bA*----------------------------------------------------------------
640bA*  Prototypes
640bA*----------------------------------------------------------------
640bA
640bAD wrttran1        pr                  extpgm('WRTTRAN1')
640bA * Input
640bAD   ppcmd                        8
640bAD   ppwait                       2  0
640bAD   ppwhse                       3  0
640bAD   pptran#                      7  0
640bAD   ppfromdate                   8  0
640bAD   pptodate                     8  0
640bAD   ppemp#                       5  0
     D ha412           pr                  extpgm('HA412')
      * Input
     D   pparm                       80
     *----------------------------------------------------------------
     *  Misc variables
     *----------------------------------------------------------------

     D dftemp#         s              5  0 inz(1)
     D dfttranin       s              7  0 inz(1235)
     D dfttranout      s              7  0 inz(1234)
     D dftwhse         s              3  0 inz(900)
     D CurrStamp       s               z

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

416lAD $vcommand       s              8
416lAD $vdesc          s             30
416lAD $vmessage       s             60
416lAD $vmsgk          s              4
416lAD $vprg           s             10
416lAD $vreturn        s             10

416lAD $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $gum            s              2
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D beltprt         s               n
     D chk4err         s               n
     D clear           s              5  0
     D clsflg          s              1
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D cvt5a           s              5
     D drierrmsg       s               n
     D e               s              2  0
520bDD*enter           s              5  0
     D error2          s               n
     D error6          s               n
     D exwgt           s              9  2
     D fillscreen      s              3
     D flag8           s               n
     D forevr          s               n
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D lsttim          s              6  0
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D n               s              3  0
     D nxtscr          s              3
     D ovrrid          s              1
     D posrec          s              4  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sumav1          s              5  0
     D tempa7          s              7
     D tmpflg          s              1
     D today           s              8  0
     D kywhse          s                   like(etwhse)
     D kyactv          s                   like(etactv)
     D kyeqip          s                   like(etcode)
     D kyemp#          s                   like(w1emp#)
     D kytype          s                   like(etcode)
700cAD w1type          s                   like(etcode)
     D kystat          s                   like(ptstat)
     D kyio            s                   like(w1io)
     D stdate          s                   like(ptsdte)
     D sttime          s                   like(ptstim)
     D*nxtet#          s                   like($ltrn#)
     D strtim          s                   like(ptstim)
     D fintim          s                   like(ptetim)
     D timlen          s                   like(ptdmin)
     D w1task          s              6
     D curtsk          s              6
     D curent          s              1
     D curtyp          s              1
     D curtrn          s                   like($ltrn#)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
500b D wonorm          s              1
640bAD wrtpcmd         s             10
640bAD wrtpwait        s              2  0
640bAD wrtpwhse        s              3  0
640bAD wrtptran#       s                   like(pttrn#)
640bAD wrtpfrmdate     s              8  0
640bAD wrtptodate      s              8  0
640bAd wrtpemp#        s                   like(ptemp#)
720aA ** temporary until added to genpick
720aAD opeqpj          s              1

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
416cAD $cerm           ds
416cAD  xcerm                  1     60
416cAD  $cmsg                  1      4
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
417d D* $lcode                22     27
417d D  $lcode                22     29
     D  $ltrn#                22     28  0
     D  $litem                29     43
     D  $lseq#                44     48  0
     D  $llbl#                49     55  0
     *
650aAD  $llevl                22     25
650aAD  $llicense             26     40
650aAD  $lpo                  41     49
650aAD  $lposeq               50     54  0
650aAD  $ltype                55     57
650aAD  $lspo                 58     61
650aA*
     *----------------------------------------------------------------
     *  Called programs
     *
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
650aAD @PC             c                   const('HA410')
     D*----------------------------------------------------------------
     D*
     D                 DS
     D  DSHMS                  1      6  0
     D  DSHM                   1      4  0
     D  DSHH                   1      2  0
     D  DSMM                   3      4  0
     D  DSSS                   5      6  0
     *
     D @adjtd          c                   const('ADJTSKDET')
     *
     D @addtr          c                   const('ADDSTDTRN')

500aAI*----------------------------------------------------------------
500aAI*  *PICKLBL  -  Picking label options
500aAI*----------------------------------------------------------------
     I*
     I* Fields
     I*
     I*    OPCLVL  -  Qty level for combined labels.
     I*    OPCWRB  -  Print combined label warning before.
     I*    OPCWRA  -  Print combined label warning after.
     I*    OPUWRB  -  Print unit of measure warning before.
     I*    OPUWRA  -  Print unit of measure warning after.
     I*    OPTEXT  -  Text for last line of label.
     I*    OPERR   -  Error label ratio.
     I*    OPCWGT  -  Catch weight label ratio.
     I*    OPLPGM  -  Picking label program.
     I*    OPPDEV  -  Printer device.
     I*    OPPFRM  -  Printer form.
     I*
     I* Data structure
     I*
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
500b D  erfld1                 1     15
500b D  erfld2                16     30
500b D  ercmtr                31     34p 0
500b D  erpmtr                35     38p 0
     *
     D  erfld                  1     30
     *
     *
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
     D*----------------------------------------------------------------
     D*  PIRTRAN record layout for use as parameters
     D*
     D ptparm        e ds                  extname(pirtran)
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
     *      $PCMD   *OPEN    - Open program and return.
     *              *CHANGE  - Change before closing.
     *              *VIEW    - View transaction.
     *              *CLOSE   - Close without changing.
     *              *ZERO    - Close with zero quantity.
414eA*              *VRFYCW  - Verify catchweights.
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER   - Interactive mode.
     *              *BATCH   - Batch mode.
     *      $PUKY   Contains key of transaction.
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
     C*    *entry        plist
     C*                  parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C     $pcmd         cabeq     '*OPEN   '    bottom
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
500 AC                   eval      *in89 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
500b C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *--------------------------------------------------------------------
     * Bye, Bye
     *--------------------------------------------------------------------

     * Close file program.

     C                   eval      $drisubcmd = '*CLOSE'
     C                   exsr      callequipt

     * Bye, Bye.

     C     bottom        tag
     C                   eval      *inlr = *on
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
     C                   when      nxtscr = '01 '
710aAC                   if        #lcol = '020'
710aAC                   exfmt     screen21                             50
710aAC                   else
     C                   exfmt     screen1                              50
710aAC                   endif
     *
     C                   when      nxtscr = '02 '
710aAC                   if        #lcol = '020'
710aAC                   exfmt     screen22                             50
710aAC                   else
     C                   exfmt     screen2                              50
710aAC                   endif
     *
500b C                   when      nxtscr = '03 '
710aAC                   if        #lcol = '020'
710aAC                   exfmt     screen23                             50
710aAC                   else
500b C                   exfmt     screen3                              50
710aAC                   endif
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

700cA*    Chain to get equipment type from input
700cAC                   eval      kywhse = w1whse
700cAC                   eval      kyeqip = w1eqip
700cAC                   eval      w1type = *blanks
700cAC     typkey        chain(n)  equip
700cAC                   if        %found
700cAC                   eval      w1type = eqtype
700cAC                   endif

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
     C                   move      '01 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C     *like         define    $etoxfl       oxflg
     C     *like         define    $etixfl       ixflg
417b C     *like         define    eaexcp        kyexcp
417b C     *like         define    eaqstn        kyqstn
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
500b *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
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
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F7 - Print test label
     *
500 AC                   if        beltprt and *inkg
500 A*    Chain to get equipment type.
500 AC                   eval      kywhse = w1whse
500 AC                   eval      kyeqip = w1eqip
500 AC     typkey        chain(n)  equip
500 AC                   if        %found and eqtype = 'BLTPRT'
500aAC                   exsr      zzprtlbl
500aAC                   eval      errmsg = 'Test label sent to device '
500aAC                                    + w1eqip
500aAC                   exsr      zm0105
500 AC                   goto      endsc1
500 AC                   endif
500 AC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     CSR                 move      *off          setflg            1
     C                   eval      refrsh = *on
     CSR                 exsr      scr02i
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr02i
     C                   endif
     Csr                 goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc2
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
500b C     nxtscr        cabeq     '03 '         endsc2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Loop to display screen 2 for next question.
     C                   eval      refrsh = *on
     CSR                 exsr      scr02i
     *
     C     endsc2        endsr
500b *----------------------------------------------------------------
500b *
500b *  SC3  -  Screen 3
500b *
500b C     sc3           begsr
500b *
500b *  Test for F3 - Exit
500b *
500b C                   if        *inkc
500b C                   move      'EOJ'         nxtscr
500b C                   eval      $prtn = '*EXIT   '
500b Csr                 goto      endsc3
500b C                   endif
500b *
500b *  Test for F5 - Refresh
500b *
500b C                   if        *inke
500b C                   if        $pcmd <> '*VIEW   '
500b C                   move      *on           refrsh
500b C                   exsr      scr03i
500b C                   endif
500b Csr                 goto      endsc3
500b C                   endif
500b *
500b *  Test for F12 - Previous
500b *
500b C                   if        *inkl
500b C                   move      'EOJ'         nxtscr
500b C                   eval      $prtn = '*CANCEL '
500b Csr                 goto      endsc3
500b C                   endif
500b *
500b *  Test for other command keys BEFORE verification and update.
500b *
500b C                   eval      cmdchk = '*BEFORE '
500b C                   exsr      zzcmd3
500b C     cmdtkn        cabeq     *on           endsc3
500b *
500b *  Some other key pressed.
500b *
500b *     Check input and write/update record.
500b *
500b C                   exsr      zzchk3
500b C     error         cabeq     *on           endsc3
500b C                   exsr      zzupd3
500b C     error         cabeq     *on           endsc3
500b *
500b *  Test for other command keys AFTER verification and update.
500b *
500b C                   eval      cmdchk = '*AFTER  '
500b C                   exsr      zzcmd3
500b C     cmdtkn        cabeq     *on           endsc3
500b *
500b *  Loop to display screen 2 for next question.
500b C                   eval      refrsh = *on
500b CSR                 exsr      scr02i
500b *
500b C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A* Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client
     C                   move      *on           forevr
KHLaAc                   if        client = kohl
SWTaAc                             or client = swt
KHLaAc                   eval      opeqpj = 'Y'
KHLaAc                   endif
720aAc                   if        opeqpj = 'Y'
720aA* Get User information.
720aA
720aAC                   call      'GETUSER'
720aAC                   parm      #user         $code            10
720aAC                   parm      0             $whse             3 0
720aAC                   parm      0             $emp#             5 0
720aAC                   parm      *blanks       $fnam            15
720aAC                   parm      *blanks       $init             1
720aAC                   parm      *blanks       $lnam            20
720aAC                   parm      *blanks       $whdp             5
720aAC                   parm      *blanks       $styp             1
720aAC                   parm      *blanks       $shft             6
720aAC                   parm      *blanks       $crew             6
720aAC                   parm      0             $nhrs             3 1
720aAC                   parm      *blanks       $rtn              8
720aAc                   eval      w1emp# = $emp#
720aAc                   eval      *in03 = *on
720aAc                   endif
     *
     *  Initialize special keys
     *
520bDC**                 eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *   Get job type (0 = Batch, 1 = Interactive)
     *
     C                   call      'GETJTYPE'
     C                   parm                    $jtype            1
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $jtype = *on
640cD ***                open      eq410fm
710aDC**                 open      eq41001
710aMC                   open      eq41002
     C                   endif
     *
     *  Initialize message handling
     *
     C                   if        $jtype = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *  callequipt      Call driequipt
     *----------------------------------------------------------------

     C     callequipt    begsr
     C                   eval      error = *off

     C                   call(e)   'DRIEQUIPT'
     C                   parm                    $drisubcmd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $equipt       parm      $equipt       $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  clrequipt  Clear data structure $equipt
     *----------------------------------------------------------------

     C     clrequipt     begsr
     C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  ProcessControl Check for Process control questions
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ProcessControl;
650aA     // does a record exist in equipm?
650aA     chain (w1whse: eqtype: w1io) equipm;
650aA     if %found(equipm);
650aA       if emstat = 'A';
650aA         // load haccps session id record
650aA         $lcmd = '*START  ';
650aA         ha412($lparm);
650aA /end-free
650aAC                   eval      $lcmd = '*RANDOM '
650aAc                   eval      $lwhse  = w1whse
650aAc                   eval      $llevl = emulvl
650aAc                   eval      $llicense = ' '
650aAc                   eval      $lpo = eqcode
650aAc                   eval      $lposeq = 0
650aAc                   eval      $ltype = emutyp
650aAc                   eval      $lspo = ' '
650aAC                   call      @PC
650aAC                   parm                    $lparm
650aAC                   parm                    $lparm1
650aA * load haccps session id record
650aA /free
650aA   $lcmd = '*END    ';
650aA   ha412($lparm);
650aA   endif;
650aA   endif;
650aA /end-free
650aAc                   endsr
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   eval      #pgmq = #pgm
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
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
     C                   move      #msgf         $msgf
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
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
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
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

500b *----------------------------------------------------------------
500b *    PIR0110  Number must be greater than zero.
500b *----------------------------------------------------------------
500b
500b C     zm0110        begsr
500b C                   eval      #msgid = 'PIR0110'
500b C                   eval      #msgtp = '*DIAG'
500b C                   movea     errmsg        $md
500b C                   exsr      zmpmsg
500b C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR4001  Notify supervisor - Warning
     *
     C     zm4001        begsr
     C                   move      'PIR4001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
500b *    EQ41001  Invalid answer.
500b *
500b C     zm4101        begsr
500b C                   move      'EQ41001'     #msgid
500b C                   move      '*DIAG  '     #msgtp
500b C                   movea     errmsg        $md
500b C                   exsr      zmpmsg
500b C                   endsr
     *----------------------------------------------------------------
500b *    EQ41002  Value entered must be greater than existing value
     *
500b C     zm4102        begsr
500b C                   move      'EQ41002'     #msgid
500b C                   move      '*DIAG  '     #msgtp
500b C                   movea     errmsg        $md
500b C                   exsr      zmpmsg
500b C                   endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     CSR   zm71          begsr
     CSR                 move      'PIR7971'     #msgid
     CSR                 move      '*DIAG  '     #msgtp
     CSR                 move      *blanks       $md
     CSR                 exsr      zmpmsg
     CSR                 endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   move      *off          error
     *
     *   Verify warehouse and get description.
     *
     C**                 eval      whcode = dhwhse
     C**                 eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2X  C                   else
     C                   movel     $lerm         whdesc           30
 2E  C                   endif
 1E  C                   endif
     *
     *  verify employee number
     C     w1emp#        chain     piruser1                           79
     C                   if        *in79 = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
700b *  get employee number addtl fields
700cAC                   if        w1type = 'BLTPRT'
700bAC     uscode        chain     pirusera                           79
700bAC                   if        *in79 = *on
700bAC                   eval      usabpu = 'N'
700bAC                   endif
700cAC                   endif
     *
     *   Verify equipment code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lcode = w1eqip
     C                   call      'EQ900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2X  C                   else
 417dC                   movel     $lerm         eqcode            8
 417dC*                  movel     $lerm         eqcode            6
 2E  C                   endif
 1E  C                   endif
     *
     *  verify Check In/Out I/O
     C                   if        w1io <> 'I' and w1io <> 'O'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     *
     C                   eval      kywhse = w1whse
     C                   eval      kyeqip = W1eqip
     *
     *  Verify no active record exists if trying to check out.
CBIa *  Removed check for CBI, and Dairyland when Belt Printer
CBIaAC     client        cabeq     cheney        skipcbi1
DRY AC                   if        client=dairyland
DRY Ac                             and w1Type='BLTPRT'
DRY Ac                   goto      skipcbi1
DRY Ac                   endif
     C                   if        w1io = 'O'
     C                   eval      kyactv = '1'
     C     chkkey        setll     equipt2
     C     chkkey        reade     equipt2                                79
     C                   if        *in79 = *off
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C                   endif
CBIa C     skipcbi1      tag
700b *
700b *  Verify Current User checking out beltprt is a belt prt user
700b *
DRY Ac                   if        client <> dairyland
700bAC                   if        w1io = 'O'
700bAC                             and usabpu = 'N'
700cAC                             and w1type = 'BLTPRT'
700cD *                        **  and beltprt = *on
700bAC                   eval      *in24 = *on
700bAC                   eval      *in04 = *on
700bAC                   eval      error = *on
700bAC                   eval      errmsg = *blanks
700bAC                   movel     desc(10)      erfld
700bAC                   exsr      zm1001
700bAC                   goto      endck1
700bAC                   endif
DRY AC                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
     *
     *  verify answer Y/N
     C                   if        w2ansr <> 'Y' and w2ansr <> 'N'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       erfld
     C                   exsr      zm1001
     C                   goto      endck2
     C                   endif
500b *  Set test value to allow for meter hours test.
500b C                   eval      wonorm = eunorm
500b C                   if        eunorm = 'H'
500b C                   eval      wonorm = 'Y'
500b C                   endif
500b *  Answer must be Y for meter hours test.
500b C                   if        eunorm = 'H' and w2ansr <> 'Y'
500b C                   eval      *in25 = *on
500b C                   eval      *in05 = *on
500b C                   eval      error = *on
500b C                   eval      errmsg = *blanks
500b C                   movel     desc(5)       erfld
500b C                   exsr      zm4101
500b C                   goto      endck2
500b C                   endif
     *
     *  verify normal answer and check if warning is needed.
     C                   if        euwarn = 'Y'
500bDC*                  if        eunorm <> w2ansr and ovrrid = *off
500bMC                   if        wonorm <> w2ansr and ovrrid = *off
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C*                  movel     desc(5)       erfld
     C                   exsr      zm4001
     C                   goto      endck2
     C                   endif
     C                   endif
     *
     C     endck2        endsr
500b *----------------------------------------------------------------
     *
500b *  ZZCHK3   Screen 3 error checking.
500b *
500b C     zzchk3        begsr
500b C                   move      *off          error
500b *
500b *  verify answer > 0
500b C                   if        w3metr < 0  or  w3metr = 0
500b C                   eval      *in26 = *on
500b C                   eval      *in06 = *on
500b C                   eval      error = *on
500b C                   eval      errmsg = *blanks
500b C                   exsr      zm0110
500b C                   goto      endck3
500b C                   endif
500b *
500b *
500b *  verify answer > previous meter hours entered
500b *
500b C     ehpkey        setgt     equiph1
500b C     ehpkey        readpe    equiph1                                79
500b C                   if        *in79 = *off and
500b C                             w3metr < ehmetr
500b C                   eval      *in26 = *on
500b C                   eval      *in06 = *on
500b C                   eval      error = *on
500b C                   eval      errmsg = *blanks
500b C                   eval      erfld1 = desc(6)
500b C                   eval      erfld2 = desc(7)
500b C                   eval      ercmtr = w3metr
500b C                   eval      erpmtr = ehmetr
500b C                   exsr      zm4102
500b C                   goto      endck3
500b C                   endif
500b C     endck3        endsr
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
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  F10 - Accept warning.
     *
     C                   if        *inkj
     C                   move      *on           ovrrid
     C*                  else
     C*                  move      *off          clsflg
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm2        endsr
500b *----------------------------------------------------------------
500b *
500b *  ZZCMD3   User defined command keys for screen 3.
500b *
500b C     zzcmd3        begsr
500b *
500b *  Command keys to check BEFORE verification and update.
500b *
500b C                   if        cmdchk = '*BEFORE '
500b C                   endif
500b *
500b *  Command keys to check AFTER verification and update.
500b *
500b C                   if        cmdchk = '*AFTER  '
500b C                   endif
500b C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1whse = #whse
416cAC                   eval      w1emp# = *zeros
416cAC                   eval      w1eqip = *blanks
720aAc                   eval      w1emp# = $emp#
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
710a C                   eval      w2qstn1 = *blanks
710a C                   eval      w2qstn2 = *blanks
416cAC                   eval      w2eqip = eutype
     C                   eval      w2qstn = euqstn
416cAC                   eval      w2ansr = *blanks
710aAC                   if        #lcol = '020'
710aAC                   movel     euqstn        w2qstn1
710aAC                   move      euqstn        w2qstn2
710aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
500b *  ZZFIL3   Fill screen 3 fields with info from file.
     *
500bAC     zzfil3        begsr
710aAC                   eval      w3qstn1 = *blanks
710aAC                   eval      w3qstn2 = *blanks
500bAC                   eval      w3eqip = eutype
500bAC                   eval      w3qstn = euqstn
500bAC                   eval      w3metr = *zeros
710aAC                   if        #lcol = '020'
710aAC                   movel     euqstn        w3qstn1
710aAC                   move      euqstn        w3qstn2
710aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     Csr   zzget2        begsr
     *    Chain to get equipment type.
     C     typkey        chain     equip                              79
     C                   if        *in79 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       erfld
     C                   exsr      zm1001
     C                   goto      endgt2
     C                   endif
     *    Setll if first read for screen 2.
     C                   if        setflg = *off
     *    initalize exception flags.
     C                   eval      oxflg  = '0'
     C                   eval      ixflg  = '0'
     C                   move      *on           setflg
     C     qstkey        setll     equipq
     C                   endif
     C     nxtgt2        tag
     C     qstkey        reade     equipq                                 79
     C                   if        *in79 = *on or w1emp# = 88888
417aDC**                 if        *in79 = *on
650aAC                   exsr      processcontrol
     C                   exsr      zzupt
     C
     *  get equipment transacton record.
     C     etrnky        chain     equipt1                            79
     C                   if        *in79 = *on
     C                   move      'EOJ'         nxtscr
     C                   goto      endgt2
     C                   endif
416aAC                   time                    currstamp
     C
     *  create work order if exception occurred.
     C                   if        (oxflg = '1' or ixflg='1')
     *  get next equip work order #.
     C     kywhse        chain     pirew#                             7778
     C**                 if        *in78 = '1'
     C                   if        *in77 = '1'
     C                   eval      ewnnbr = 1
640aAC                   eval      ewnwhs = kywhse
640aAC                   write     ewnrec                               77
     C                   endif
     C
     C                   if        oxflg = '1'
     C**                 eval      ewotrn = etotrn
     C                   eval      ewio = 'O'
     C                   endif
     C                   eval      ewwhse = kywhse
     C                   if        ixflg = '1'
     C**                 eval      ewitrn = etitrn
     C                   eval      ewio = 'I'
     C                   endif
     C
     C                   eval      ewwrk# = ewnnbr
     C                   eval      ewgdte = currstamp
     C                   eval      ewetrn = savetrn#
     C***                eval      ewotrn = etotrn
     C***                eval      ewitrn = etitrn
     C**                 eval      ewitrn = 0
     C                   eval      ewpdte = 0
     C                   eval      ewemp# = 0
     C                   eval      ewcdte = 0
640aAC     tryew         tag
410 ACSR                 write     ewrec                                79
     C                   eval      ewnnbr = ewnnbr + 1
640aAC                   if        *in79 = *on
640aAC                   eval      ewwrk# = ewnnbr
640aAC                   goto      tryew
640aAC                   endif
640aMCSR                 update    ewnrec                               77
640aDC*R                 update    ewnrec                               79
     C                   endif
     C
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endgt2
     C                   endif
     *
     C     eustat        cabeq     'I'           nxtgt2
     C     euio          cabne     kyio          nxtgt2
     *
     *
     *
520aAC     endgt2        tag
520a C                   if        beltprt  and
520a C                             nxtscr = 'EOJ'
520a C                   if        kyio='I' and
520a C                             w4day = 'Y'
520aAC                   exsr      zzeday
520aAC                   endif
520aAC                   endif
520aDC*    endgt2        endsr
520aMC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
500aA*
500aA*  Define partial key for EQUIPT file.
500aA*
500aAC     keyeq         klist
500aAC                   kfld                    kywhse
     *
     *
     *  Define partial key for EQUIPT1 file.
     *
     C     etrnky        klist
     C                   kfld                    kywhse
     C                   kfld                    savetrn#
     *
     *  Define partial key for EQUIPT2 file.
     *
     C     chkkey        klist
     C                   kfld                    kywhse
     C                   kfld                    kyactv
     C                   kfld                    kyeqip
     *
     *  Define key for EQUIP file.
     *
     C     typkey        klist
     C                   kfld                    kywhse
     C                   kfld                    kyeqip
417b *  Define key for EQUIPW file.
417b *
417b C     ewkkey        klist
417b C                   kfld                    kywhse
417b C                   kfld                    eatrn#
417a *
417a *  Define key for EQUIPA file.
417a *
417b C     eqakey        klist
417b C                   kfld                    kywhse
417b C                   kfld                    kyeqip
417b C                   kfld                    kystat
417b C                   kfld                    kyexcp
417b C                   kfld                    kyqstn
500b *
500b *  Define key for EQUIPH file.
500b *
500b C     eqhkey        klist
500b C                   kfld                    kywhse
500b C                   kfld                    eatrn#
500b C                   kfld                    eaio
500b C                   kfld                    easeq#
500b *
500b *  Define key for partial key EQUIPH1 file.
500b *
500b C     ehpkey        klist
500b C                   kfld                    kywhse
500b C                   kfld                    eacode
500b C                   kfld                    easeq#
     *
     *  Define partial key for EQUIPQ file.
     *
     C     qstkey        klist
     C                   kfld                    eqtype
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    curtrn
     C*                  kfld                    wotrn#
     *
     *
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    w1emp#
     C                   kfld                    kystat
     *
     *  Define key for PIRTRAN2 file.
     *
     C     ptke22        klist
     C                   kfld                    w1emp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    w1emp#
     C                   kfld                    stdate
     *
     C     tkkey         klist
     C                   kfld                    t#task            6
     *
     C                   eval      $lprg = #pgm
     C                   eval      $cvprg = #pgm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   move      *off          error
     *  Get default warehouse for user.
     C                   call      'GETWHSE'
416cAC                   parm                    #user            10
416cAC     w1whse        parm      0             #whse             3 0
710aA*
710aAC                   call      'PIRRFSCR'
710aAC                   parm      '*GET'        #lcmd             8
710aAC                   parm                    #lline            2
710aAC                   parm                    #lcol             3
     *
500aA
500aA*  See if any belt printers are defined.
500aA
500aAC                   eval      kywhse = 0
500aAC                   eval      *in89 = *off
500aAC                   eval      beltprt = *off
500aAC     keyeq         setll     equip
500aAC                   dow       forever = forever
500aAC                   read      equip
500aAC                   if        %eof
500aAC                   leave
500aAC                   endif
500aAC                   if        eqtype = 'BLTPRT'
500aAC                   eval      *in89 = *on
500aAC                   eval      beltprt = *on
500aAC                   leave
500aAC                   endif
500aAC                   enddo
     *
     *  Convert today's date into century format.
     *
     C                   exsr      zzzdte
     *  Select first screen to display.
     C                   exsr      scr01i
     *
     C     endzi2        endsr

     *----------------------------------------------------------------
     *
     *  ZZBDAY   Start a BEGDAY task.
     *
     C     zzbday        begsr
     *  Create a new transaction record BEGDAY
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '4'
520aAC                   eval      pttask = 'BEGDAY'
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79 = *off
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   endif
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = $cvd8o
     C                   time                    ptetim
     C                   eval      ptrdte = $cvd8o
     C*                  eval      ptedte = 0
     C*                  eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     C*                    WRITEPTREC1                 79
    AC                   write     ptrec                                79
    AC     *in79         ifeq      '1'
    AC                   move      '1'           error
    AC                   exsr      zm71
    AC                   goto      endbdy
    ACSR                 endif
640bAc                   exsr      zzwrttrand
     C*
520 ACSR   endbdy        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C     *like         define    pttrn#        svtrn#
     C     *like         define    ptdmin        svtlen
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
     C     forevr        doweq     forevr
     C                   read      pirtran2                               79
     C                   if        *in79 = *on   or ptsdte < zzsdte
     C                   leave
     C                   endif
     *    Skip the task that just ended.
     C                   if        *in79 = *off and pttrn# = svtrn#
     C                   iter
     C                   endif
     *    Skip 'IDLE' task.
     C                   if        pttask = 'IDLE'
     C                   iter
     C                   endif
     *
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79 = *on
     C                   eval      tktype = ' '
     C                   endif
      *   Accumulate overlapping minutes.(Same start and end date)
      *                  Start     Start       End      End    Overlap
      *           Task    date      time       time     date   Minutes
      *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
      *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
      *
      *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
      *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
      *
     C     *in79         ifeq      *off
     C     ptsdte        andeq     zzsdte
     C     ptedte        andeq     zzedte
     C     ptstim        andeq     zzstim
     C     ptetim        andeq     zzetim
     C     tktype        andeq     'I'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
      *   Accumulate overlapping minutes(Diff start date/same end date)
      *                                  (Past midnight)
      *                  Start     Start       End      End    Overlap
      *           Task    date      time       time     date   Minutes
      *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
      *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     C     *in79         ifeq      *off
     C     ptsdte        andgt     zzsdte
     C     ptedte        andeq     zzedte
     C     ptetim        andle     zzetim
     C     tktype        andeq     'I'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
      *   Accumulate overlapping minutes.(Same start date/diff end date)
      *                  Start     Start       End      End    Overlap
      *           Task    date      time       time     date   Minutes
      *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
      *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     C*
     C     *in79         ifeq      *off
     C     ptsdte        andeq     zzsdte
     C     ptedte        andlt     zzedte
     C     ptstim        andge     zzstim
     C     tktype        andeq     'I'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     C                   enddo
     *    Update the task that just ended.
     C     svtrn#        chain     pirtran                            79
     C     *in79         ifeq      *off
     C     ptdmin        ifgt      0
     C                   eval      ptdmin = ptdmin - svtlen
     C                   else
     C                   eval      ptimin = ptimin - svtlen
     C                   endif
     C                   update    ptrec
640bAc                   exsr      zzwrttrand
     C                   endif
     C     endcu2        endsr
416cA*----------------------------------------------------------------
416cA*     ZZCVQY - Convert receive qty's to string for msg display
416cA*
416cAC     zzcvqy        begsr
416cAC                   call      'CVTQTY'
416cAC                   parm                    $ccmd             8
416cAC                   parm                    $cprg            10
416cAC                   parm                    $cqty1            7 0
416cAC                   parm                    $cqty2            7 0
416cAC                   parm                    $cqty3            7 0
416cAC                   parm                    $cum1             2
416cAC                   parm                    $cum2             2
416cAC                   parm                    $cum3             2
416cAC                   parm                    $cqstr           10
416cAC                   parm                    $custr           17
416cAC                   parm                    $crtn             8
416cAC                   parm                    $cerm
416cAC                   endsr
520aA*---------------------------------------------------------------
520aA*
520aA*  ZZDAYW   Begin - End day Window.
520aA*
520aAC     zzdayw        begsr
520aAC                   if        w1io = 'O'
520aAC                   eval      w4day = 'N'
520aAC                   eval      w4out = desc(8)
520aAC                   else
520aAC                   eval      w4day = 'N'
520aAC                   eval      w4out = desc(9)
520aAC                   endif
CLD A*
CLD A*  Default 'Begin day' / 'End day' to Y under these conditions.
CLD A
CLD AC                   if        client = cityline
CLD AC                   eval      w4day = 'Y'
CLD AC                   endif

520aAC****  display window
520aAC                   dow       forevr = forevr
520aAC                   exfmt     WBEDAY
520aAC****  if not Y or N
520aAC                   if        w4day <> 'Y' and
520aAC                             w4day <> 'N'
520aAC                   eval      *in28 = *on
520a C                   eval      error = *on
520a C                   eval      errmsg = *blanks
     C                   movel     desc(5)       erfld
     C                   exsr      zm1001
520aAC                   else
520aAC                   eval      *in28 = *off
520aAC                   leave
520aAC                   endif
520aAC                   enddo
520aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEDAY   Start a ENDDAY task.
     *
     C     zzeday        begsr
410 A *  Get current task.
     C                   exsr      zztask
     C                   select
     C                   when      curtyp = 'D'
     *  End current task.
     C                   exsr      zzend
     C                   when      curtyp = 'I'
     *  End current task and any previous open tasks.
     C                   eval      found = *on
     C     found         doweq     *on
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C     found         ifeq      *off
410 AC                   leave
410 AC                   endif
     C                   exsr      zzend
410 AC                   enddo
410 AC                   endsl
     *  Create a new transaction record ENDDAY
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '4'
520aAC                   eval      pttask = 'ENDDAY'
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79 = *off
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   endif
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C*                  eval      ptedte = $cvd8o
     C*                  time                    ptetim
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptrdte = $cvd8o
     C*                  eval      ptedte = 0
     C*                  eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     C*                    WRITEPTREC1                 79
    AC                   write     ptrec                                79
    AC     *in79         ifeq      '1'
    AC                   move      '1'           error
    AC                   exsr      zm71
    AC                   goto      endedy
    ACSR                 endif
640bAc                   exsr      zzwrttrand
     C*
520 ACSR   endedy        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZEND    End current task.
     *
     *
     C     zzend         begsr
     * No current task to end.
     C     curtrn        cabeq     0             endend
     C*                  eval      wotrn# = curtrn
     C     ptkey         chain     pirtran                            79
     C                   if        *in79 = *off
     C                   if        curtyp = 'D' and curtsk <> 'IDLE'
     C                   eval      ptstat = '3'
     C                   else
     C                   eval      ptstat = '4'
410 AC                   z-add     $cvd8o        ptcdte
410 AC                   time                    ptctim
     C                   endif
     C                   eval      ptetyp = 'N'
     C                   endif
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd             8
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   update    ptrec
640bAc                   exsr      zzwrttrand
     C                   if        curtyp = 'D'
      *        There is a posibility that a manual task might have
      *        been added before the current task was ended. Hence
      *        adjust the current task just ended, if there is
      *        any overlapping manual task.
     C                   eval      svtrn# = pttrn#
      *  Past overnight. (PTEDTE > PTSDTE)
     C                   if        ptedte > ptsdte
     C                   eval      stdate = ptedte
     C                   else
     C                   eval      stdate = ptsdte
     C                   endif
     C                   eval      zzsdte = ptsdte
     C                   eval      zzedte = ptedte
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zzcku2
     C                   endif
     * End current task.
416cAC     endend        endsr
     *----------------------------------------------------------------
     *
     *  ZZINT    Start IN transaction.
     *
     *
     C     zzint         begsr

     * Get next equipment transaction
     C*                  eval      $twhse = w1whse
     C*                  call      'PIRET#'
     C*                  parm                    $twhse            3 0
     C*                  parm      0             nxtet#            7 0
     C*                  eval      nxtet# = $ltrn#
     * Create equipment 'In' transaction

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = kywhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = kyeqip
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = kyemp#
     C                   eval      $etitrnu = '1'
     C                   eval      $etitrn  = pttrn#
     C                   eval      $etiusru = '1'
     C                   eval      $etiusr  = #user
     C                   eval      $etijobu = '1'
     C                   eval      $etijob  = #job
     C                   eval      $etinbru = '1'
     C                   eval      $etinbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKIN'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZIDLE   Create and start an Idle task.
     *
     *
     C     zzidle        begsr
410 ACSR                 call      'PIRTRN#'
410 ACSR                 parm                    pttrn#
410 ACSR                 move      '2'           ptstat
410 ACSR                 movel     'IDLE  '      pttask
410 ACSR                 movel     'IDLE  '      t#task
410 ACSR   tkkey         chain     task                               77
410 ACSR                 move      tkcat         ptcat
410 ACSR                 move      tksub         ptsub
410 ACSR                 select
410 ACSR   tktlvl        wheneq    'S'
410 ACSR                 z-add     w1whse        ptwhse
410 ACSR                 move      *blanks       ptwhdp
410 ACSR                 move      *blanks       ptstyp
410 ACSR   tktlvl        wheneq    'D'
410 ACSR                 z-add     w1whse        ptwhse
410 ACSR                 move      *blanks       ptwhdp
410 ACSR                 move      *blanks       ptstyp
410 ACSR                 other
410 ACSR                 z-add     w1whse        ptwhse
410 ACSR                 move      *blanks       ptwhdp
410 ACSR                 move      *blanks       ptstyp
410 ACSR                 endsl
410 ACSR                 move      usshft        ptshft
410 ACSR                 move      uscrew        ptcrew
410 ACSR                 z-add     w1emp#        ptemp#
410 ACSR                 z-add     0             ptcube
410 ACSR                 z-add     0             ptswgt
410 ACSR                 z-add     0             ptpcs
410 ACSR                 z-add     0             ptaisl
410 ACSR                 z-add     0             ptqty1
410 ACSR                 z-add     0             ptqty2
410 ACSR                 z-add     0             ptqty3
410 ACSR                 move      '*CURCMD '    $cvcmd
410 ACSR                 call      @cvtdt
410 ACSR                 parm                    $cvtdt
410 ACSR                 z-add     $cvd8o        ptgdte
410 ACSR                 time                    ptgtim
410 ACSR                 z-add     $cvd8o        ptsdte
410 ACSR                 time                    ptstim
410 ACSR                 z-add     0             ptedte
410 ACSR                 z-add     0             ptetim
410 ACSR                 move      *blanks       ptetyp
410 ACSR                 z-add     0             ptcdte
410 ACSR                 z-add     0             ptctim
410 ACSR                 z-add     0             ptdmin
410 ACSR                 z-add     0             ptimin
410 ACSR                 move      *blanks       ptrtpo
410 ACSR                 write     ptrec                                79
410 ACSR   *in79         ifeq      '1'
410 ACSR                 move      '1'           error
410 ACSR                 exsr      zm71
410 ACSR                 goto      endidl
410 ACSR                 endif
640bAc                   exsr      zzwrttrand
     C*
410 ACSR   endidl        endsr

     *----------------------------------------------------------------
     *
     *  ZZOUTT   Start OUT transaction.
     *
     *
     C     zzoutt        begsr


     * Get next equipment transaction
     C*                  eval      $twhse = w1whse
     C*                  call      'PIRET#'
     C*                  parm                    $twhse
     C*                  parm      0             nxtet#
     C*                  eval      nxtet# = $ltrn#
     * Create equipment 'Out' transaction'

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = kywhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = kyeqip
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = kyemp#
     C                   eval      $etotrnu = '1'
     C*                  eval      $etotrn  = dfttranout
     C                   eval      $etotrn  = pttrn#
     C                   eval      $etousru = '1'
     C                   eval      $etousr  = #user
     C                   eval      $etojobu = '1'
     C                   eval      $etojob  = #job
     C                   eval      $etonbru = '1'
     C                   eval      $etonbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKOUT'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  ZZPRTLBL   Print test label for belt printer.
500aA*----------------------------------------------------------------
500aA
500aAC     zzprtlbl      begsr

     *  Set device to equipment code being checked out.

     C                   eval      oppdev = eqcode
     C                   eval      oppfrm = '*STD'

     *  Set label format to use.

     C                   if        client = cheney
     C                   eval      @set = 'BLTCBI'
     C                   else
     C                   eval      @set = 'PLBL40'
     C                   endif

     *  Call label program to print test label.

     C                   call      'PFMT'
     C                   parm      '*TEST1'      $pfcmd            8
     C                   parm                    @set              6
     C                   parm      'PRTOK   '    $pffmt            8
     C                   parm                    $pfwhse           3 0
     C                   parm                    $pfrtid           5
     C                   parm                    $pfcomp           1
     C                   parm                    $pftzon           6
     C                   parm                    $pfgen            1 0
     C                   parm                    $pfszon           6
     C                   parm                    $pftruk          10
     C                   parm                    $pfrte            5
     C                   parm                    opzdta
     C                   parm                    $pftrn#           7 0

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new task.
     *
     C     zzstrt        begsr
     *  Create a new transaction record.
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '2'
416cAC                   eval      pttask = 'EQCHK'
416cAC                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79 = *off
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   endif
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     C*                    WRITEPTREC1                 79
410 AC                   write     ptrec                                79
410 AC     *in79         ifeq      '1'
410 AC                   move      '1'           error
410 AC                   exsr      zm71
410 AC                   goto      endstr
410 ACSR                 endif
640bAc                   exsr      zzwrttrand
     C*
410 ACSR   endstr        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTASK   Get current task.
     *
     C     zztask        begsr
     *  These variables are initialized in RC200 ZZCLSE before ZZTASK
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     *
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   eval      kystat = '2'
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
     C                   if        *in79 = *on
     C                   eval      found = *off
     C                   goto      endtsk
     C                   endif
     *
     C     ptke22        setll     pirtran2
     C     forevr        doweq     forevr
     C                   read      pirtran2                               79
     C                   if        *in79 = *on or ptemp# <> w1emp#
     C                   eval      found = *off
     C                   leave
     C                   endif
     C                   if        ptstat <> '2'
     C                   iter
     C                   endif
     *  Found an active transaction.
     C                   eval      curent = *on
     C                   eval      curtrn = pttrn#
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79 = *off
     C                   eval      curtsk = tkcode
     C                   eval      curtyp = tktype
     C                   endif
     C                   leave
     C                   enddo
     C     endtsk        endsr

     *----------------------------------------------------------------
     *
     *  ZZTIME   Calculate time.
     *
     C     zztime        begsr

     C*      Calculate length of time in minutes for output.
     C*
     CSR                 z-add     strtim        dshms
     C*   Round up minute, if the seconds is >= 30
     CSR   dsss          ifge      30
     CSR                 add       1             dsmm
     CSR                 endif
     CSR   dshh          mult      60            tmpbeg            4 0
     CSR                 add       dsmm          tmpbeg
     C*
     CSR                 z-add     fintim        dshms
     C*   Round up minute, if the seconds is >= 30
     CSR   dsss          ifge      30
     CSR                 add       1             dsmm
     CSR                 endif
     C*
     C*   If the ending time is < starting time, than
     C*   we have gone past the midnight.
     C*
     CSR   fintim        iflt      strtim
     CSR                 add       24            dshh
     CSR                 endif
     CSR   dshh          mult      60            tmpend            4 0
     CSR                 add       dsmm          tmpend
     C*
     CSR   tmpend        sub       tmpbeg        timlen
     CSR   timlen        iflt      0
     CSR                 z-add     0             timlen
     CSR                 endif
     C*
     CSR   endtim        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPT    Update transaction.
     *
     C     zzupt         begsr

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = kywhse
     C                   eval      $ettrn#u = '1'
     C                   eval      $ettrn#  = savetrn#
     C                   if        kyio = 'O'
     C                   eval      $etoqflu = '1'
     C                   eval      $etoqfl  = '1'
     C                   eval      $etoxflu = '1'
     C                   eval      $etoxfl  = oxflg
     C                   else
     C                   eval      $etiqflu = '1'
     C                   eval      $etiqfl  = '1'
     C                   eval      $etixflu = '1'
     C                   eval      $etixfl  = ixflg
     C                   endif
     C                   eval      $drisubcmd = '*CHANGE'
     C                   exsr      callequipt
     *  End PIR transaction and start IDLE.

     C                   eval      curtrn  = pttrn#
510aAC                   eval      t#task = pttask
510a C     tkkey         chain     task                               79
510a C                   if        *in79 = *off
510a C                   eval      curtsk = tkcode
510a C                   eval      curtyp = tktype
510a C                   endif
410 AC                   exsr      zzend
     C                   eval      w1task = 'IDLE  '
410 AC                   exsr      zzidle
416cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     *
     C     zzupd1        begsr
     C                   move      *off          error
     C                   eval      kyio = w1io
     C                   eval      kyemp# = w1emp#
520a *  If equipment is bltprt, display window for beg / end day.
520aAC                   if        beltprt
520aAC                   exsr      zzdayw
520aAC                   endif
410 A *  Get current task.
     C                   exsr      zztask
     C                   select
     C                   when      curtyp = 'D'
700aAC                             and not beltprt
     *  End current task.
     C                   exsr      zzend
     C                   when      curtyp = 'I'
     *  End current task and any previous open tasks.
     C                   eval      found = *on
     C     found         doweq     *on
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C     found         ifeq      *off
410 AC                   leave
410 AC                   endif
     C                   exsr      zzend
410 AC                   enddo
410 AC                   endsl
520a C                   if        beltprt
520a C                   if        kyio='O' and
520a C                             w4day = 'Y'
520aAC                   exsr      zzbday
520aAC                   endif
520aAC                   endif
     C                   exsr      zzstrt
     C                   if        w1io = 'O'
     C                   exsr      zzoutt
     C                   endif
     C                   if        w1io = 'I'
     C                   exsr      zzint
     C                   endif
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   move      *off          error
417b *  for exception check for existing work order for question.
417b C                   eval      eawrk# = 0
500bDC*                  if        w2ansr <> eunorm
500bMC                   if        w2ansr <> wonorm
417b C                   eval      eawhse = kywhse
417b C                   eval      kystat = '1'
417b C                   eval      kyexcp = '1'
417b C                   eval      kyqstn = euqstn
417b C     eqakey        setll     equipa2
417b C     nexta         tag
417b C     eqakey        reade     equipa2                                79
417b *  get existing work order using transaction #.
417b C     *in79         ifeq      *off
417b C     eawrk#        ifeq      0
417b C     ewkkey        chain     equipw2                            72
417b C     *in72         ifeq      *off
417b C                   eval      eawrk# = ewwrk#
417b C                   else
417b C                   goto      nexta
417b C                   endif
417b C                   else
417b C                   goto      nexta
417b C                   endif
417b C                   endif
417b C                   endif
     *  $etoqfl set to 1 when questions have been asked.
     C                   eval      eawhse = kywhse
     C*                  eval      eatrn#= nxtet#
     C                   eval      eatrn#= savetrn#
     C                   eval      eaio = euio
     C                   eval      easeq# = euseq#
500b C                   if        eunorm = 'H' and w2ansr = 'Y'
500b C                   eval      eaansr = eunorm
500b C                   else
     C                   eval      eaansr = w2ansr
500b C                   endif
417b C                   eval      eaqstn = euqstn
417b C                   eval      eastat = '1'
417b C                   eval      easdts = currstamp
417b C                   eval      eacode = w1eqip
417c C                   if        eawrk# <>0
417c C                   eval      eastat = '3'
417c C                   endif
500bDC*                  if        w2ansr = eunorm
500bMC                   if        w2ansr = wonorm
     C                   eval      eaexcp = *off
     C                   else
417b C                   if        eawrk# = 0
     C                   eval      eaexcp = *on
     C                   if        kyio = 'O'
     C                   eval      oxflg = '1'
     C                   endif
     C                   if        kyio = 'I'
     C                   eval      ixflg = '1'
     C                   endif
     C                   endif
417b C                   endif
     C                   write     earec
500b C                   if        eunorm = 'H'
500b C                   eval      refrsh = *on
500b C                   exsr      scr03i
500b C                   endif
     C*                  if        $pcmd = '*VIEW   '
     C*                  move      'EOJ'         nxtscr
     C*                  goto      endup2
     C*                  endif
     *
     C     endup2        endsr
500b *----------------------------------------------------------------
500b *
500b *  ZZUPD3   Update for screen 3.
500b *
500b C     zzupd3        begsr
500b C                   move      *off          error
416aAC                   time                    currstamp
500b *  $etoqfl set to 1 when questions have been asked.
500b C                   eval      ehwhse = kywhse
500b C                   eval      ehtrn#= eatrn#
500b C                   eval      ehio = eaio
500b C                   eval      ehseq# = easeq#
500b C                   eval      ehmetr = w3metr
500b C                   eval      ehedts = currstamp
500b C                   eval      ehcode = eacode
500b C                   write     ehrec
500b C                   move      '02 '         nxtscr
500b *
500b C     endup3        endsr
640bA*----------------------------------------------------------------*********
640bA*
640bA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640bA*
640bA /free
640bA   begsr zzwrttrand;
640bA     wrtpcmd = '*ONETRAN';
640bA     wrtpwait = 0;
640bA     wrtpwhse = ptwhse;
640bA     wrtptran# = pttrn#;
640bA     wrtpfrmdate = 0;
640bA     wrtptodate = 0;
640bA     wrtpemp# = 0;
640bA
640bA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640bA               wrtpfrmdate: wrtptodate: wrtpemp#);
640bA   endsr;
640bA /end-free
     *----------------------------------------------------------------
     *
     *  ZZZDTE   Get date.
     *
     C     zzzdte        begsr
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    lsttim
     *
     C                   endsr

416lA*----------------------------------------------------------------
416lA*  zzzds2item  Move item ds fields into std item fields.
416lA*----------------------------------------------------------------

416lAC     zzzds2item    begsr

     C*                  eval      itwhse = $itwhse
     C*                  eval      ititem = $ititem

     C     endds2item    endsr

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Employee #
Check In/Out
Check In/Out, Check out exists
Equipment type, type not found
answer, must be Y/N
entered meter
previous meter
Begin day
End day
Not A Belt Print User
