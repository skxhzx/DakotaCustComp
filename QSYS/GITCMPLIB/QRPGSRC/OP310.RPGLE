     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OP310     PIR options - Voice
     *  17 May 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    05/17/04  DAS  4.17
     *      - Created.
     *
500 A*    09/14/05  MLB  5.00
     *      - Enh: Added new option to control if RUNNER entries
     *        are created for shorts/outs.
     *
500aA*    11/25/05  JCJ  5.00a
     *      - Enh: add new *voice options
     *
500bA*    01/03/06  DAS  5.00b
     *      - Enh: add new *voice options
500cA*    01/12/06  MLB  5.00c
     *      - Enh: Revised *VOICE options to remove field OPFRPL since
     *        it was not used. Renamed OPFRPL to OPFCLR - Clear RUNNER
     *        flag if quantity still short/out.
     *      - Enh: Added new parm on call to OP331 to send field name to
     *        to be updated.
520 A*    03/31/09  CWM  5.20
     *      - Enh: Change error msg for W1OUTF to match same in OP330
     *      - Enh: Change to sync 5 flags between Runner and Voice
700aA*    11/14/16  NLK  7.00a
     *      - Enh: Add stop number length per Jeff on Cheney conversn
     *
710a *    01/30/17  GJA  7.10a  (was not brought back from IFD)
     *      - Enh: Change pallet speak options
     *      - Enh: Change screen format to OP31003
     *
710b *    07/20/17  GJA  7.10b
     *      - Fix: error message
     *      - Enh: Change screen format to OP31004
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

700aD *p31001   cf   e             workstn
700aAF*op31002   cf   e             workstn
710aAF*op31003   cf   e             workstn
710bAFop31004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)

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

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pvoice               22     22
500cDD* $preturn              23     23
500cMD  $prunner              23     23
520 AD  $pflgpl               24     24
520 AD  $pflgrt               25     25
520 AD  $pflgmr               26     26
520 AD  $pflgtf               27     27
520 AD  $pflgcl               28     28
520 DD* $pflag                24     24
520 DD* $pupdfld              25     34

     *----------------------------------------------------------------
     *  *VOICE  -  PIR Voice options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINCP  -  Include pack description (Y/N)
500 A*    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
500aA*    OPUPLV  -  Update Label with quantity picked during Voice
500aA*               selection (Y/N)
500aA*               NOTE: Any change to this field will cause OPUPLR
500aA*                     in the *RUNNER options record to be updated.
500aA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
500aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500cM*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
500cA*               NOTE: Any change to this field will cause OPCLRF
500cA*                     in the *RUNNER options record to be updated.
500kA*    OPVMLT  -  Allow multiple transaction (Y/N)
710aD**** OPVSPN  -  Speak pallet number (Y/N)
710aD*    OPVSPN  -  Speak pallet number 0=No, 1=Always, 2=Only multip
500kA*    OPVSPZ  -  Speak pallet zone (Y/N)
500kA*    OPVSLW  -  Speak large quantity warning (Y/N)
500kA*    OPVSUW  -  Speak unit of measure change warning (Y/N)
     *
     * Data structure
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  opincp                 1      1
500 AD  opcrtr                 2      2
500aAD  opuplv                 3      3
500aAD  opvmrg                 4      4
500aAD  opoutf                 5      5
500cMD  opfclr                 6      6
500kAD  opvmlt                 7      7
500kAD  opvspn                 8      8
500kAD  opvspz                 9      9
500kAD  opvslw                10     10
500kAD  opvcep                11     11
500kAD  opvssn                12     12
500kAD  opvcpz                13     13
700aAD  opestp                14     14
     D  optend               117    117

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
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

     *----------------------------------------------------------------
     *  Misc variables created by RPG4MAX.
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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

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
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     *----------------------------------------------------------------
     *   OP16021  Passwords do not match.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'OP16021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Value can not be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1011  Value of OPUPLV must be 'Y' if OPOUTF = 'N'
     *
     C     zm1011        begsr
     C                   eval      #msgid = 'PIR1011'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify pack description option.

     C                   if        w1incp <> 'Y'  and
     C                             w1incp <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Pack Description'
     C                   exsr      zm1005
     C                   endif

500aA*  Verify Update label with qty picked during voice selection

500aAC                   if        w1uplv <> 'Y'  and
500aAC                             w1uplv <> 'N'
500aAC                   eval      error = *on
500aAC                   eval      *in23 = *on
500aAC                   eval      *in03 = *on
500aAC                   eval      errmsg = 'Update Label    '
500aAC                   exsr      zm1005
500aAC                   endif

500aA*  Verify Create RUNNER entries for shorts

500aAC                   if        w1crtr <> 'Y'  and
500aAC                             w1crtr <> 'N'
500aAC                   eval      error = *on
500aAC                   eval      *in22 = *on
500aAC                   eval      *in02 = *on
500aAC                   eval      errmsg = 'Create shorts   '
500aAC                   exsr      zm1005
500aAC                   endif

500aA*  Verify create runner entries for merge records

500aAC                   if        w1vmrg <> 'Y'  and
500aAC                             w1vmrg <> 'N'
500aAC                   eval      error = *on
500aAC                   eval      *in24 = *on
500aAC                   eval      *in04 = *on
500aAC                   eval      errmsg = 'Merge Records   '
500aAC                   exsr      zm1005
500aAC                   endif

500aA*  Verify create runner entry after slot marked out

500aAC                   if        w1outf <> 'Y'  and
500aAC                             w1outf <> 'N'
500aAC                   eval      error = *on
500aAC                   eval      *in25 = *on
500aAC                   eval      *in05 = *on
520 DC*                  eval      errmsg = 'Slot Marked Out '
520 AC                   eval      errmsg = 'After Slot Marked Out '
500aAC                   exsr      zm1005
500aAC                   endif

500aA*  Verify Update label entry if create shorts = 'N'

500aAC                   if        w1outf =  'N'  and
500aAC                             w1uplv <> 'Y'
500aAC                   eval      error = *on
500aAC                   eval      *in23 = *on
500aAC                   eval      *in03 = *on
500aAC                   eval      errmsg = 'Update Label    '
500aAC                   exsr      zm1011
500aAC                   endif

500aA*  Verify replenish flagged items before print report

500cDC*                  if        w1frpl <> 'Y'  and
500cDC*                            w1frpl <> 'N'
500cMC                   if        w1fclr <> 'Y'  and
500cMC                             w1fclr <> 'N'
500aAC                   eval      error = *on
500aAC                   eval      *in26 = *on
500aAC                   eval      *in06 = *on
500cDC*                  eval      errmsg = 'Replenish Flagged Items'
500cMC                   eval      errmsg = 'Clear Runner flags'
500aAC                   exsr      zm1005
500aAC                   endif

500bA*  Verify allow multiple transactions.
500bA
500bAC                   if        w1vmlt <> 'Y'  and
500bAC                             w1vmlt <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in27 = *on
500bAC                   eval      *in07 = *on
500bAC                   eval      errmsg = 'Allow Multiple Transactions'
500bAC                   exsr      zm1005
500bAC                   endif

500bA*  Verify speak pallet number.
500bA
710aDC***                if        w1vspn <> 'Y'  and
710aDC***                          w1vspn <> 'N'
710aAC                   if        w1vspn <> '0'  and
710aAC                             w1vspn <> '1'  and
710aAC                             w1vspn <> '2'
500bAC                   eval      error = *on
500bAC                   eval      *in28 = *on
500bAC                   eval      *in08 = *on
500bAC                   eval      errmsg = 'Speak Pallet Number'
500bAC***710bD           exsr      zm1005
710bMC                   exsr      zm1001
500bAC                   endif

500bA*  Verify confirm pallet zone.
500bA
500bAC                   if        w1vcpz <> 'Y'  and
500bAC                             w1vcpz <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in33 = *on
500bAC                   eval      *in13 = *on
500bAC                   eval      errmsg = 'Confirm pallet zone'
500bAC                   exsr      zm1005
500bAC                   endif

500bA*  Verify speak pallet zone.
500bA
500bAC                   if        w1vspz <> 'Y'  and
500bAC                             w1vspz <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in29 = *on
500bAC                   eval      *in09 = *on
500bAC                   eval      errmsg = 'Speak Pallet Zone'
500bAC                   exsr      zm1005
500bAC                   endif

500bA*  Verify speak large quantity warning.
500bA
500bAC                   if        w1vslw <> 'Y'  and
500bAC                             w1vslw <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in30 = *on
500bAC                   eval      *in10 = *on
500bAC                   eval      errmsg = 'Speak Large Quantity Warning'
500bAC                   exsr      zm1005
500bAC                   endif

500bA*  Verify confirm EACH pick.
500bA
500bAC                   if        w1vcep <> 'Y'  and
500bAC                             w1vcep <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in31 = *on
500bAC                   eval      *in11 = *on
500bAC                   eval      errmsg = 'Confirm EACH pick'
500bAC                   exsr      zm1005
500bAC                   endif

500bA*  Verify speak stop number.
500bA
500bAC                   if        w1vssn <> 'Y'  and
500bAC                             w1vssn <> 'N'
500bAC                   eval      error = *on
500bAC                   eval      *in32 = *on
500bAC                   eval      *in12 = *on
500bAC                   eval      errmsg = 'Speak stop number'
500bAC                   exsr      zm1005
500bAC                   endif

700aA*  Verify Stop number length
700aA
700aAC                   if        w1estp < '2'  or
700aAC                             w1estp > '5'
700aAC                   eval      error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   eval      errmsg = 'Stop Number length '
700aAC                   exsr      zm1001
700aAC                   endif

     C     endck1        endsr
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
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      opincp = 'Y'
500 AC                   eval      opcrtr = 'N'
500aAC                   eval      opuplv = 'N'
500aAC                   eval      opvmrg = 'N'
500aAC                   eval      opoutf = 'N'
500cDC*                  eval      opfrpl = 'N'
500cMC                   eval      opfclr = 'Y'
500bAC                   eval      opvmlt = 'N'
710aDC***                eval      opvspn = 'N'
710aMC                   eval      opvspn = '0'
500bAC                   eval      opvspz = 'N'
500bAC                   eval      opvslw = 'N'
500bAC                   eval      opvcep = 'N'
500bAC                   eval      opvssn = 'N'
500bAC                   eval      opvcpz = 'N'
700aAC                   eval      opestp = '3'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1incp = opincp
500 AC                   eval      w1crtr = opcrtr
500aAC                   eval      w1uplv = opuplv
500aAC                   eval      w1vmrg = opvmrg
500aAC                   eval      w1outf = opoutf
500cDC*                  eval      w1frpl = opfrpl
500cMC                   eval      w1fclr = opfclr
500bAC                   eval      w1vmlt = opvmlt
500bAC                   eval      w1vspn = opvspn
500bAC                   eval      w1vspz = opvspz
500bAC                   eval      w1vslw = opvslw
500bAC                   eval      w1vcep = opvcep
500bAC                   eval      w1vssn = opvssn
500bAC                   eval      w1vcpz = opvcpz
700aAC                   if        opestp = ' '
700aAC                   eval      w1estp = '3'
700aAC                   eval      opestp = '3'
700aAC                   else
700aAC                   eval      w1estp = opestp
700aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
500aAC                   eval      opwhse = $pwhse
     C                   eval      opcode = '*VOICE'
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
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
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
     C                   eval      opincp = w1incp
500 AC                   eval      opcrtr = w1crtr
500aAC                   eval      opuplv = w1uplv
500aAC                   eval      opvmrg = w1vmrg
500aAC                   eval      opoutf = w1outf
500cDC*                  eval      opfrpl = w1frpl
500cMC                   eval      opfclr = w1fclr
500bAC                   eval      opvmlt = w1vmlt
500bAC                   eval      opvspn = w1vspn
500bAC                   eval      opvspz = w1vspz
500bAC                   eval      opvslw = w1vslw
500bAC                   eval      opvcep = w1vcep
500bAC                   eval      opvssn = w1vssn
500bAC                   eval      opvcpz = w1vcpz
700aAC                   eval      opestp = w1estp
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd

500cM* update option *RUNNER flags
500aAC                   else
500cDC*                  eval      $preturn = 'Y'
500cMC                   eval      $prunner = 'Y'
520 DC*                  eval      $pflag   = opuplv
520 DC*                  eval      $pupdfld = 'OPUPLV    '
520 AC                   eval      $pflgpl  = opuplv
520 AC                   eval      $pflgrt  = opcrtr
520 AC                   eval      $pflgmr  = opvmrg
520 AC                   eval      $pflgtf  = opoutf
520 AC                   eval      $pflgcl  = opfclr
500aAC                   call      'OP331'
500aAC                   parm                    $parms
500cA*
500cA*    Update OPCLRF in *RUNNER options record with *VOICE value.
520 DC*                  eval      $prunner = 'Y'
520 DC*                  eval      $pflag   = opfclr
520 DC*                  eval      $pupdfld = 'OPFCLR    '
520 DC*                  call      'OP331'
500 DC*                  parm                    $parms
500aAC                   endif
     *
     C     endupd        endsr
