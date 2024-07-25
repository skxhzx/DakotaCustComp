      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LOADR11   Load Cleared Flag - Loader Module, evoked
     *            by loader pgms LOADR10-->RU310B-->LOADR11.
     *
     *            This is an RF application, the user profile
     *            of the flag runner that signs on will
     *            execute CLP LOADRFCL2-->LOADR10.
     *
     *  October 31, 2006
     *  Jose Duque
     *
     *  Revisions
     *
520 A*   09/18/08  RBD  5.20   P#00060
     *     - Right adjust route and use the last 2 chars for
     *       comparison to route from the route/pallet id combo
     *       field on the LOADR11 scrn.  Because some clients use
     *       2 chars for route, some use 3, etc, this logic won't
     *       care, it will simply use the last 2 chars.  The same
     *       logic should be used in PFMT when building the combo
     *       route/pallet id field which prints on the pallet label.
     *
530 A*    05/07/10  RBD  5.30
     *      - Converted to ILE.
     *      - Enh: Added client custom code support to program.
     *
530aA*    06/23/10  JCJ  5.30a
     *      - Enh: Recompiled - Increase W1TRL# field size from 6 to 8.
     *
530bA*    06/28/10  JCJ  5.30b
     *      - Fix: change program to use route id instead of route
     *        to get the 2 char piece of pallet id.
530cA*    07/08/10  RH   5.30c
     *      - Enh: Display dock door assinged in truck builder.       .
     *
650aA*    01/20/15  RBD  6.50a
     *      - Recompiled, LDRDETL file changed.
     *
650bA*    06/02/15  RBD  6.50b
     *      - Changed format name to LOAD1101.
     *      - Increased size of entry field which holds the barcode scanned
     *        on the pallet label. Previously it was the last 2 char of
     *        route id + pallet id, now it's the full route id + pallet id.
     *        We're making this change because Coastal has more than 100
     *        trucks, which means we need more than the last 2 char of
     *        route id to ensure the barcode is unique for the day's routes.
     *        By using the full route id + pallet id we can be sure the
     *        combo field will always be unique, thus making it as fail safe
     *        as possible that the pallet gets loaded onto the right truck.
     *
710aA*    08/24/17  RBD  7.10a
     *      - Changed format name to LOAD1102 for screen title change.
     *
750aA*    05/04/21  RBD  7.50a
     *      - Changed format name to LOAD1103.
     *      - Changed pallet barcode scan from 10 pos to 9 to avoid potential
     *        conflict with Trax# barcode which is 10 pos. The pallet barcode
     *        will now consist of last 4 of route id + last 5 of pallet.
     *
750bA*    08/19/21  RBD  7.50b
     *      - Added new runner option opscnl "Scan short to Loader required
     *        before clearing runner flag".
     *      - If opscnl is Y when short is scanned and runner status is 'L'
     *        set it to 'C'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  City Line
     *
CLD A*    05/07/10  RBD  CLD
     *      - Bypass merge pallet processing, treat PIR as normal
     *        pallet.  Without this rev, the pgm supplies the route/
     *        pallet for w1plt# if it's a merge pallet.  Steve wants
     *        his users to scan it and it be edited just like a
     *        normal pallet.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  60        Display product temps at item level.
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650bDF*Load11fm  cf   e             workstn
710aDF*Load1101  cf   e             workstn
750aDF*Load1102  cf   e             workstn
750aMFLoad1103  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
     Fpiruser1  if   e           k disk
     F                                     rename(usrec:usrec1)
     Fequip     if   e           k disk
     FLdrhdr    if   e           k disk
     Frtehed    if   e           k disk
     Fordh1     if   e           k disk
     FLabel     if   e           k disk
     FLabel1    if   e           k disk    rename(lbrec:lbrec1)
     FLdrdetl   if   e           k disk
530cAFDocmtrx2  if   e           k disk
     FLdrovrfl  o    e           k disk
750bAFoptions   if   e           k disk
750bAFrunner6   uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             70    dim(8) ctdata perrcd(1)
     *----------------------------------------------------------------
530 A*  Client ID's
     *
CLD A /COPY QCOPYSRC,ID#CITYLIN
CLD A /COPY QCOPYSRC,ID#CHENEY
     *
530 AD @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pwhse                 1      3  0
     D  $prtid                 4      8
     D  $pltid                 9     15  0
     D  $labl#                16     22  0
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
     *
     *----------------------------------------------------------------
     *  Data structures
     *
     D                 ds
     D  dsmisc                 1     20
     D  dssdte                 1      8
     D  dsspcl                 9     11
     D  dsrpck                12     12
     D  dsdoor                13     14
     D  dsmeat                15     15
     D  dscode                16     16
     D  dsrvs                 19     19
     *----------------------------------------------------------------
     D                 ds
     D  rte1                   1      5
     *
     *   Redefine DS
     *
     D  rte23                  2      3  0
     D  rte32                  2      3
     *
     *----------------------------------------------------------------
     D                 ds
     D  pltid                  1      7  0
     *
     *   Redefine DS
     *
     D  plt12                  1      2  0
     D  plt37                  3      7  0
     D  plt73                  3      7
     *
     *----------------------------------------------------------------
     D                 ds
     D  plt#                   1      7  0
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

750bA*----------------------------------------------------------------
750bA*  *RUNNER  -  PIR Runner Flag Options
750bA*----------------------------------------------------------------
750bA*
750bA* Fields
750bA*
750bA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
750bA*    OPUPLR  -  Update Label with quantity shorted during manual
750bA*               flag entry (Y/N)
750bA*               NOTE: Any change to this field will cause OPUPLV
750bA*                     in the *VOICE options record to be updated.
750bA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
750bA*               & create Priority Replenishment if necessary.
750bA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
750bA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
750bA*    OPRNRM  -  Send break message to user when new Runner
750bA*               task has been assigned. (Y/N)
750bA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
750bA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
750bA*    OPRPCK  -  Print Runner pick list. (Y/N)
750bA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
750bA*               printer, 2=Belt printer
750bA*    OPRBDU  -  Allow shorts to be filled with breakdown units. (Y/N)
750bA*    OPRSCN  -  Scan tran# or label# to start pick.
750bA*                 1=tran#, 2=label#.
750bA*    OPRVFS  -  Verify pick slot, Y/N.
750bA*    OPRVFQ  -  Verify qty found, Y/N.
750bA*    OPRLOA  -  Using loader module, Y/N.
750bA*    OPSCNL  -  Scan short to loader required before
750bA*               clearing runner flag, Y/N.
750bA*
750bA* Data structure
750bA*
750bAD oprdta          ds
750bAD  opcrtm                 1      1
750bAD  opuplr                 2      2
750bAD  oprplf                 3      3
750bAD  opmrgf                 4      4
750bAD  opclrf                 5      5
750bAD  oprnrm                 6      6
750bAD  opclsf                 7      7
750bAD  opoutf                 8      8
750bAD  oprpck                 9      9
750bAD  oprlbl                10     10
750bAD  oprbdu                11     11
750bAD  oprscn                12     12
750bAD  oprvfs                13     13
750bAD  oprvfq                14     14
750bAD  oprloa                15     15
750bAD  opscnl                16     16
750bAD  optendr              117    117

     *----------------------------------------------------------------
     *  Variables

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D batch#          s              7  0
     D catplt          s              7
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D hldemp          s              5  0
     D hldend          s              8  0
     D hldent          s              6  0
     D hlditm          s             15
     D hldlbl          s              7  0
     D hldmsg          s             17
     D hldord          s              7  0
CLD AD hldplid         s              5  0
     D hldplt          s              5
     D hldtrl          s              8
     D last2a          s              2
     D last2r          s              2  0
     D merge           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
650bAD w1rtid          s              5
750aAD w1rtid4         s              4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $pprg            10
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz1
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     *
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     *--------------->    RETRN
     C                   eval      *inlr = *on
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
     C                   exfmt     windw4                               50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       1314
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                         2526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       36
     C                   setoff                                       9098
     *
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     *
     C                   eval      e = 0
     *
     *   Prod Integrity info is no required if HACCP flag = 'Y'
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen1
     *
     *----------------------------------------------------------------
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
     *> Test for F5 - Refresh
     *>
     *>         *INKE     IFEQ '1'
     *>         $PCMD     IFNE '*VIEW   '
     *>                   EXSR SCR01I
     *>                   END
     *>                   GOTO ENDSC1
     *>                   END
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     *
     C                   eval      $prtn = '*OK     '
     *
     C                   if        w1plt# <> *zeros
     C     dtlky2        chain     ldrdetl                            79
     C                   else
     C     dtlkey        chain     ldrdetl                            79
     C                   endif
     *
     C                   if        not *in79
     *
     *-->       LDSTRD    IFEQ *ZEROS
     *
     *  Move starting loading date and time into Ldrdetl file
     *
     *> This code was     MOVE '*MDYCMD '$CVCMD
     *> deleted because   MOVE #JOBDT    $CVD6I
     *> it was overriding CALL @CVTDT
     *> the loader pallet PARM           $CVTDT
     *> load Start Time,  MOVE $CVD8O    LDSTRD
     *  End Time and Loader
     *> Employee # with   TIME           LDSTRT
     *> Flag Runner clear ENDIF
     *  Flag Info.
     *----------------------------------------------------------------
     *
     C                   eval      hldend = *zeros
     C                   eval      hldent = *zeros
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      #jobdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        hldend
     C                   time                    hldent
     *
     *
     *>         W1TRL#    IFNE *BLANKS
     *>         LDENDD    ANDEQ*ZEROS
     *
     *  Move ending loading date and time into Ldrdetl file
     *>                   MOVE HLDEND    LDENDD
     *>                   MOVE HLDENT    LDENDT
     *>                   ENDIF
     *
     *  Get loader emp#
     *
     C                   eval      hldemp = *zeros
     *
     C     #user         chain     piruser                            79
     C                   if        not *in79
     *>                   Z-ADDUSEMP#    LDEMP#
     C                   eval      hldemp = usemp#
     C                   endif
     *
     *
     *-->                 UPDATLDDREC
     *
     *  Load Ldrovrfl file with flag closing info.
     *
     C     $labl#        chain     label                              79
     C                   if        not *in79
     C                   eval      hlditm = lbitem
     C                   else
     C                   eval      hlditm = *blanks
     C                   movel     'NOTFND'      hlditm
     C                   endif
     *
     C                   eval      lowhse = ldwhse
     C                   eval      lorte = ldrte
     C                   eval      lortid = ldrtid
     C                   eval      loplt# = ldplid
     C                   eval      lolbl# = $labl#
     C                   eval      loitem = hlditm
     C                   eval      loemp# = hldemp
     C                   eval      lostdt = hldend
     C                   eval      lostim = hldent
     *
     C                   eval      locls2 = *blanks
     *
     C                   if        w1plt# <> *zeros
     C                   move      w1plt#        locls2
     C                   else
     C                   move      w1trl#        locls2
     C                   endif
     *
     C                   write     loovrc
     *
750bA /free

750bA     // If runner status is 'L' update it to status 'C'

750bA     chain ($pwhse: lblbl#) runner6;
750bA     if %found and rustat = 'L';
750bA       rustat = 'C';
750bA       update rurec;
750bA     endif;

750bA /end-free
     *
     C                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     *
     *
     C     endsc1        endsr
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
530 A*  Get Client ID
     *
530 AC                   call      @getcl
530 AC                   parm                    client           10
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
CLD AC                   eval      merge = '0'
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------
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
     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *
     *---------------------------------------------------------------
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZMPMSG  Add message record to subfile
     *
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
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     *---------------------------------------------------------------
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     *---------------------------------------------------------------
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
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
     *      PIR0105 Gneric message
     *
     *----------------------------------------------------------------
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *    PIR0203  Value cannot be blank.
     *
     *----------------------------------------------------------------
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     *----------------------------------------------------------------
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      errmsg = *blanks
     C                   eval      plt# = *zeros
     *
     *          Check if trailer# was input
     *
     *>         W1LDR#    IFEQ *ZEROS
     *>                   MOVE *ON       ERROR
     *>                   MOVE *ON       *IN21
     *>                   MOVE *ON       *IN01
     *>                   MOVEADESC,2    ERRMSG
     *>                   EXSR ZM0203
     *>                   GOTO ENDCK1
     *>                   ENDIF
     *
     *>         $PAORC    IFEQ 'C'
     *
     *>         W1LDR2    IFEQ W1LDR#
     *>                   MOVE *ON       ERROR
     *>                   MOVE *ON       *IN21
     *>                   MOVE *ON       *IN01
     *>                   MOVE *ON       *IN24
     *>                   MOVE *ON       *IN26
     *>         ERRMSG    IFEQ *BLANKS
     *>                   MOVEADESC,4    ERRMSG
     *>                   EXSR ZM0105
     *>                   ENDIF
     *>                   GOTO ENDCK1
     *>                   ENDIF
     *
     *>                   MOVE W1LDR2    LDRKEY  50
     *
     *>         LDRKEY    CHAINPIRUSER1             79
     *>         W1LDR2    CHAINPIRUSER1             79
     *>         *IN79     IFEQ *ON
     *>                   MOVE *ON       ERROR
     *>                   MOVE *ON       *IN21
     *>                   MOVE *ON       *IN01
     *>                   MOVE *ON       *IN24
     *>                   MOVE *ON       *IN26
     *>         ERRMSG    IFEQ *BLANKS
     *>                   MOVEADESC,3    ERRMSG
     *>                   EXSR ZM0203
     *>                   ENDIF
     *>                   GOTO ENDCK1
     *>                   ENDIF
     *>                   ENDIF
     *
     *          Validate input fields
     *
     C                   if        w1plt# = *zeros  and
     C                             w1trl# = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(4)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      endck1
     C                   endif
     *
     *
     C                   if        w1plt# <> *zeros
     *          Validate pallet id
     *
     *750aD     Get first two digits of scanned pallet# found in trlr
     *750aD     (they are the last two digits of route #) and also,
     *          get the actual 5 digits pallet #.
     *
650bDC**                 eval      pltid = w1plt#
650bMC                   move      w1plt#        pltid
     C                   eval      rte1 = *zeros
     C                   eval      plt# = plt37
     *
650bA*750aD     Entire route id is now in the route/pallet barcode
650bA*750aD     so we now verify the full route id.
750aA*          Verify route id pos 2 thru 4.
750aDC**                 movel     w1plt#        w1rtid
750aMC                   movel     w1plt#        w1rtid4
     *
     *          Get last two digits of route # from header rec,
     *          if not found get it from detail rec because the
     *          route being processed could be an ADD-ONS pallet
     *          for Breakers or any of the regular routes.
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   if        lhrte <> *blanks
530bD ***                eval      rte1 = lhrte
530bMC                   eval      rte1 = lhrtid
     C                   endif
     C                   else
     C     dtlky2        chain     ldrdetl                            79
     C                   if        not *in79
530bD ***                eval      rte1 = ldrte
530bMC                   eval      rte1 = ldrtid
     C                   endif
     *
     C                   endif
     *
650bDC**                 call      'ADJUST'
650bDC**                 parm      '*RIGHT  '    $ccmd             8
650bDC**                 parm      rte1          $cstr            30
650bDC**                 move      $cstr         last2r
     *
520 D**         RTE23     IFNE PLT12
650bDC**                 if        last2r <> plt12
750aDC**                 if        w1rtid <> rte1
750aMC                   if        w1rtid4 <> %subst(rte1:2:4)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in24 = *off
     C                   eval      *in25 = *on
     C                   eval      *in26 = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     *          Get digits three to seven of scanned pallet# found
     *          in trailer and compare them to pallet# passed as parm.
     *
     *          NOTE: $PLTID will be different than PLT37 if flag
     *                label is PIR (merge).
     *
     C                   if        plt37 <> $pltid  and
     C                             merge = '0'  or

CLD AC                             client <> cityline and
     C                             plt37 = $pltid  and
CLD MC                             merge = '1' or

CLD AC                             client = cityline and
CLD AC                             plt37 <> hldplid and
CLD AC                             merge = '1'

     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(5)       errmsg
     C                   exsr      zm0105
     C                   endif
     *>                   GOTO ENDCK1
     C                   endif
     C                   endif
     *
     *
     *          Validate input trailer#
     *
     C                   if        w1trl# <> *blanks
     C                   movel     w1trl#        hldtrl
     *
     C     trlkey        chain     equip                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
     C                   goto      endck1
     C                   endif
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   if        hldtrl <> lhtrlr
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(3)       hldmsg
     *>                   MOVEADESC,3    ERRMSG
     C     hldmsg        cat       lhtrlr        errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      endck1
     C                   endif
     C                   endif
     C                   endif
     *
     *
     C     strdte        tag
     *
     *  Store pallet start loading date and time into Ldrdetl file
     *
     *>                   MOVE '*MDYCMD '$CVCMD
     *>                   MOVE #JOBDT    $CVD6I
     *>                   CALL @CVTDT
     *>                   PARM           $CVTDT
     *>                   MOVE $CVD8O    LDSTRD  80
     *
     *>                   MOVE #JOBTM    LDSTRT  60
     *
     *
     *
     C     endck1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFNAM   Format loader name.
     *
     *----------------------------------------------------------------
     C     zzfnam        begsr
     *
     C                   eval      w1user = *blanks
     *>                   MOVE *BLANKS   FNAME
     *>                   MOVE *BLANKS   LNAME
     *
     C                   if        $prtn = 'VIEW    '
     C                   move      ldemp#        w1ldr#
     C                   else
     C                   move      usemp#        w1ldr#
     C                   endif
     *>         ' '       SCAN USFNAM    P1      20
     *          P1        SUBSTUSFNAM:1  FNAME  12
     *          ' '       SCAN USLNAM    P2      20
     *          P2        SUBSTUSLNAM:1  LNAME  16
     *>         FNAME     CAT  LNAME:1   W1USER
     C                   eval      w1user = uscode
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     *  Define key for main file.
     *
     C     trlkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    hldtrl
     *>                   KFLD           W1TRL#
     *
     C     rcdeky        klist
     C                   kfld                    $pwhse
     *>                   KFLD           W1RCDE
     *
     C     hdrkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    rhrte
     C                   kfld                    $prtid
     *
     C     dtlkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    rhrte
     C                   kfld                    $prtid
     C                   kfld                    $pltid
     *
     C     dtlky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    rhrte
     C                   kfld                    $prtid
     C                   kfld                    plt#
     *
     C     rthkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C     ohkey         klist
     C                   kfld                    rhpbat
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C     lbl1ky        klist
     C                   kfld                    batch#
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
530c C     dckey         klist
530c C                   kfld                    $pwhse
530c C                   kfld                    $prtid
     *
     *  Define Ldrovrfl file key.
     *
     C     ovrfky        klist
     C                   kfld                    ldwhse
     C                   kfld                    ldrte
     C                   kfld                    ldrtid
     C                   kfld                    ldplid
     C                   kfld                    hlditm
     *
     C     rthkey        chain     rtehed                             79
     *
     C                   eval      w1rte# = rhrte
     *
     C                   if        $prtn = 'VIEW    '
     C                   eval      w1plt# = $pltid
     C                   seton                                        9091
     C                   eval      $prtn = *blanks
     *
     C     dtlkey        chain     ldrdetl                            79
     C                   if        not *in79
     C     ldemp#        chain     piruser1                           79
     C                   if        not *in79
     C                   exsr      zzfnam
     C                   endif
     C                   else
     C                   eval      w1ldr# = *zeros
     C                   endif
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   movel     lhtrlr        w1trl#
     C                   endif
     *
     C                   else
     C                   eval      w1plt# = *zeros
     C                   eval      w1trl# = *blanks
     C                   seton                                        26
     *
     *  Chek if a merge flag is being processed
     *
     C                   exsr      zzplt
     *
     C     #user         chain     piruser                            79
     C                   if        not *in79
     C                   exsr      zzfnam
     * If want pallet to show
     C                   endif
     C                   endif
     *
     *
     *  Get loading door number
     C                   eval      w1door = *blanks
     C     rthkey        chain     rtehed                             79
     C                   if        not *in79
     *
530c C                   select
530cAC                   when      client = cheney
     C     ohkey         setll     ordh1
     C     ohkey         reade     ordh1                                  79
     C                   if        not *in79
     C                   eval      dsmisc = ohmisc
     C                   movel     dsdoor        w1door
     C                   endif
530cAC                   other
530cAC     dckey         setll     docmtrx2
530cAC     dckey         reade     docmtrx2                               79
530cAC                   if        not *in79
530cAC                   movel     dmdoor        w1door
530cAC                   endif
530cAC                   endsl
     C                   endif
     *
750bA /free

750bA     // Get *RUNNER options
750bA     chain ($pwhse: '*RUNNER') options;
750bA     if %found;
750bA       oprdta = opdata;
750bA     else;
750bA       opscnl = 'N';
750bA     endif;

750bA /end-free
     *
     C     bypas1        tag
     C                   eval      nxtscr = '01 '
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPLT    Check if pallet being passed is a merged pallet#,
     *           if it is then get the right pallet # found in
     *           the route item/label assigned to the specific
     *           selector.
     *
     *           (PIR pallet# is created when PIRselector finds
     *           a flag. This pallet# is not the same number
     *           that appears in the selector's pick label
     *           which happens to have the right pallet# on it.
     *
     *           NOTE: When a PIRselector is gathering merge items
     *                 for an specific route and one of the items
     *                 is not found, a flag is created along with
     *                 a new pick label# different than the pick
     *                 label# initially created for the selector.
     *
     *----------------------------------------------------------------
     C     zzplt         begsr
     *
     C                   eval      merge = *off
XXX AC                   eval      hldlbl = $labl#
     *
     C     dtlkey        chain     ldrdetl                            79
     C                   if        *in79
     *
     *  pallet# used in DTLKEY belongs to a PIR merged pallet
     C                   eval      merge = *on
     *
     C     $labl#        chain     label                              79
     C                   if        not *in79
     C                   eval      batch# = lbpbat
     C                   eval      hldord = lbord
     C                   eval      hlditm = lbitem
     *
     *  If the conditions below are true, it means that the
     *  selectors pick label which has the right pallet #
     *  was found. The flag error in this case does not mean
     *  an actual error, it is setup to force a message to
     *  indicate the flag runner the right pallet # to close
     *  the flagged item to. NOTE: In a situation like this
     *  there is always two label recs (pcklabl & flaglbl).
     *
     C     lbl1ky        setll     label1
     C     lbl1ky        reade     label1                                 79
     C                   dow       not *in79
     C                   if        lbitem = hlditm  and
     C                             lbord = hldord  and
     C                             lbpal# <> $pltid  and
     C                             lbctr# = hldlbl
CLD AC                   if        client = cityline
CLD AC                   eval      hldplid = lbpal#
CLD AC                   leave
CLD AC                   endif
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in26 = *on
     C                   eval      hldmsg = *blanks
     C                   movea     desc(7)       hldmsg
     C                   move      lbpal#        hldplt
     C                   move      lbpal#        pltid
530bD ***                eval      rte1 = rhrte
530bMC                   eval      rte1 = rhrtid
     *
650bDC**                 call      'ADJUST'
650bDC**                 parm      '*RIGHT  '    $ccmd
650bDC**                 parm      rte1          $cstr
650bDC**                 move      $cstr         last2a
     *
520 D**         RTE32     CAT  PLT73     CATPLT  7
650bDC**   last2a        cat       plt73         catplt
750aDC**                 movel     w1rtid        w1plt#
750aMC                   movel     w1rtid4       w1plt#
650bDC**                 move      catplt        w1plt#
650bMC                   move      plt73         w1plt#
     C                   eval      *in90 = *on
     C                   movel     desc(8)       errmsg
     C                   exsr      zm0105
     C                   eval      hldlbl = lblbl#
     C                   leave
     C                   endif
     *
     C     lbl1ky        reade     label1                                 79
     C                   enddo
     C                   endif
     C                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  DESC
Invalid pallet Id
Valid trailer #
Wrong trlr#, use-
Enter Pallet # or Trailer #
Pallet # not found in this route
Wrong Trailer #-
Look for pallet #-
Press Enter . . .
