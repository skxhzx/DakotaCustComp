610bA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO122     PO detail maint - Change
     *  08 October, 1996
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
402 A*    07/29/97  HNK  4.02
     *      - Catch weight entry allowed.
404  *    09/04/97  RH      4.04
     *      - Changed to handle cross docking.
     *      - If Cross dock rec exists for PO & item, update with PDSEQ.
     *
405 A*    09/17/97  HNK     4.05
     *      - PO seq # update corrected.
     *
413 A*    02/03/00  HNK     4.13
     *      - PO seq # check added.
     *
415 A*    03/23/01  DAS     4.15
     *      - Revised ZZDFT1 to clear all fields.
     *
415aA*    04/25/01  HNK  4.15a
     *      - Changed to enable qty receive fields if the item has '*'
     *        in right most position of designation code.
     *
415bA*    06/29/01  DAS     4.15a
     *      - Revised ZZUPD1 to zero receiving fields for *ADD.
416aA*    10/18/01  RH      4.16a
     *      - Fix - increase catch weight W1DWGT to 9.2
     *
500 A*    11/10/05  MLB  5.00
     *      - Enh: Revised program to add buyer number/name to display.
     *        Added file ITEMMSC.
     *
720aA*    12/10/18  LMC  7.20a
     *      - Enh: Added client logic.                                .
750aA*    03/03/21  LMC  7.50a
     *      - Enh: F21 key is now conditioned to be used if *in51=off .
     *        change display file to PO12201                          .
     *
770aA*   07/15/22  TDC  7.70a
     *      - DockVue: Added update of POSTATUS table when the PO is
     *        updated.
     *      - Added check for the dockvue system option (opdckv)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSTaA*    12/10/18  LMC  WSTa
     *      - Po seq# being added must be > 899.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse
     *
DRYaA*    03/03/21  LMC  DRYa
     *      - Disable F21 - to create new item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
     *
CDI A*    11/18/22  MLB  CDI
     *      - Po seq# must be in range of 1 - 9,000.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
500 A*  74        NRF on chain to ITEMMSC
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
750aDF*po122fm   cf   e             workstn
750aMFpo12201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpodtl     uf a e           k disk
     F                                     rename(pdrec:record)
404 AFcrossdk3  if   e           k disk
404 AFcrossdk2  uf   e           k disk
     Fwarehs    if   e           k disk
402 AFpiritem   if   e           k disk
500 AFitemmsc   if   e           k disk
405 AFordd      if   e           k disk
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA
770aA /copy qcopysrc,c#stdsql
770aA*----------------------------------------------------------------
770aA*  System options
770aA*----------------------------------------------------------------
770aAD sysoptrec     E Ds                  Extname(options)
770aA*----------------------------------------------------------------
770aA*  *SYSTEM   -  System options.
770aA*----------------------------------------------------------------
770aA*
770aA* Data structure
770aA*
770aAD sysoptions      ds
770aAD  opepm                  1      1
770aAD  oprf                   2      2
770aAD  opcapc                 3      3
770aAD  opletd                 4      4
770aAD  opwrnc                 5      5
770aAD  oprg1c                 6      8  1
770aAD  oprg2c                 9     11  1
770aAD  opimpi                12     12
770aAD  opicw                 13     13
770aAD  opmpck                14     14
770aAD  oprcdy                15     15  0
770aAD  oppkdy                16     16  0
770aAD  oprths                17     19  0
770aAD  opcrhs                20     22  0
770aAD  oppohs                23     25  0
770aAD  opiahs                26     28  0
770aAD  opmshs                29     31  0
770aAD  optbjq                32     32
770aAD  opishs                33     35  0
770aAD  opishsa               33     35
770aAD  opuci                 36     36
770aAD  opwrncr               37     37
770aAD  opicwr                38     38
770aAD  optrax                39     39
770aAD  opdckv                50     50
770aAD  sysoptionsend        117    117
     *----------------------------------------------------------------
770aAD* Variables
770aAd dockvue         s               n   inz('0')
770aAD nostamp         s               z     inz
770aAD ocode           s              8
770aAD wkwhse          s              3  0
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
402 MD desc            s             50    dim(12) ctdata perrcd(1)
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
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     *----------------------------------------------------------------
     *
     *
415aAD                 ds
415aAD  dsdesg                 1      5
415aAD  dsdes5                 5      5
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
     D  $litem                22     36
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
     *  Variables
     *
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
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D seq             s                   like(pdseq)
     D svitem          s             15
     D warn            s              1
720aA*----------------------------------------------------------------
720aA*  Customer id
720aA*
720aAD @getcl          c                   const('GETCLIENT')
720aA*
WST A /COPY QCOPYSRC,ID#WESTSID
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
CDI A /COPY QCOPYSRC,ID#CDI
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
720aA*
720aA* Get client id.
720aA*
720aAC                   call      @getcl
720aAC                   parm                    client           10
720aAC                   parm                    client2          10
720aA*
      /free
DRYaA   if client = Dairyland;
DRYaA     *in51 = *on;
750aA   else;
750aA     *in51 = *off;
DRYaA   endif;
      /end-free

     *  Initialize message handling
     *
     C                   exsr      zmimsg
770aA
770aA*  Get System options.
770aA /free
770aA   ocode = '*SYSTEM ';
770aA   exec sql select * into :sysoptrec
770aA        from options
770aA        where opwhse = 0
770aA          and opcode = :ocode;
770aA
770aA   If sqlstt = sqlSuccess;
770aA     sysoptions = opdata;
770aA   else;
770aA     opdckv = 'N';
770aA   endif;
770aA
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
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
402 A*   PIR1005  Value must be 'Y' or 'N'
402 A*
402 AC     zm1005        begsr
402 AC                   eval      #msgid = 'PIR1005'
402 AC                   eval      #msgtp = '*DIAG  '
402 AC                   movea     errmsg        $md
402 AC                   exsr      zmpmsg
402 AC                   endsr
402 A*----------------------------------------------------------------
402 A*   PIR0110  Value must be > 0.
402 A*
402 AC     zm0110        begsr
402 AC                   eval      #msgid = 'PIR0110'
402 AC                   eval      #msgtp = '*DIAG  '
402 AC                   movea     errmsg        $md
402 AC                   exsr      zmpmsg
402 AC                   endsr
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
413 D**                   MOVEADESC      ERRMSG
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
402 A*----------------------------------------------------------------
402 A*    PO21001  Multiple qty entered, Catch wt avg must be 'N'
402 A*
402 AC     zm2101        begsr
402 AC                   eval      #msgid = 'PO21001'
402 AC                   eval      #msgtp = '*DIAG  '
402 AC                   eval      $md = *blanks
402 AC                   exsr      zmpmsg
402 AC                   endsr
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
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
     *  Verify item number
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1itm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *    Make sure code doesn't already exist.
     *
     C                   eval      $pitem = w1itm
     C     podkey        chain     record                             79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
413 AC                   eval      errmsg = *blanks
413 AC                   movea     desc(1)       errmsg
     C                   exsr      zm02
     C                   endif
WSTaAC                   if        client = westside
WSTaA* Make sure sequence number is > 899.
WSTaAC                   if        w1seq <= 899
WSTaAC                   eval      error = *on
WSTaAC                   eval      *in21 = *on
WSTaAC                   eval      *in01 = *on
WSTaAC                   eval      errmsg = *blanks
WSTaAC                   eval      errmsg = 'Seq# must be 900 or higher'
WSTaAC                   exsr      zm0105
WSTaAC                   endif
WSTaAC                   endif
WSTaA*
CDI AC                   if        client = CDI
CDI A* Make sure sequence number is < 9000.
CDI AC                   if        w1seq > 9000
CDI AC                   eval      error = *on
CDI AC                   eval      *in21 = *on
CDI AC                   eval      *in01 = *on
CDI AC                   eval      errmsg = *blanks
CDI AC                   eval      errmsg = 'Seq# must be 9000 or less.'
CDI AC                   exsr      zm0105
CDI AC                   endif
CDI AC                   endif
CDI A*
413 A* Make sure sequence number is not already used.
413 AC     podky1        setll     podtl                                  79
413 A* Record Found.
413 AC                   if        *in79
413 AC                   eval      error = *on
413 AC                   eval      *in21 = *on
413 AC                   eval      *in01 = *on
413 AC                   eval      errmsg = *blanks
413 AC                   eval      errmsg = desc(10)
413 AC                   exsr      zm02
413 AC                   endif
413 A*
     C                   endif
     *
     C                   if        w1seq <= 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(10)      erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify normal qty ordered is within range - optional.
     *
     C                   if        w1qor1 < 0  or
     C                             w1qor1 > 99999
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 1 qty ordered is within range - optional.
     *
     C                   if        w1qor2 < 0  or
     C                             w1qor2 > 99999
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify breakdown 2 qty ordered is within range - optional.
     *
     C                   if        w1qor3 < 0  or
     C                             w1qor3 > 99999
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
402 A*
402 A*  Verify Catch weight average  (Y/N).
402 A*
402 AC                   if        w1avg <> 'Y'  and
402 AC                             w1avg <> 'N'
402 AC                   eval      error = *on
402 AC                   eval      *in32 = *on
402 AC                   eval      *in12 = *on
402 AC                   eval      errmsg = *blanks
402 AC                   eval      errmsg = desc(12)
402 AC                   exsr      zm1005
402 AC                   endif
     *
402 A*
402 A*  When more than one qty is entered, catch weight average must be N
402 A*
402 AC                   select
402 AC                   when      w1qrc1 <> 0  and
402 AC                             w1avg = 'Y'
402 AC                   if        w1qrc2 <> 0  or
402 AC                             w1qrc3 <> 0
402 AC                   eval      error = *on
402 AC                   eval      *in32 = *on
402 AC                   eval      *in12 = *on
402 AC                   eval      errmsg = *blanks
402 AC                   eval      errmsg = desc(12)
402 AC                   exsr      zm2101
402 AC                   endif
     *
402 AC                   when      w1qrc2 <> 0  and
402 AC                             w1avg = 'Y'
402 AC                   if        w1qrc1 <> 0  or
402 AC                             w1qrc3 <> 0
402 AC                   eval      error = *on
402 AC                   eval      *in32 = *on
402 AC                   eval      *in12 = *on
402 AC                   eval      errmsg = *blanks
402 AC                   eval      errmsg = desc(12)
402 AC                   exsr      zm2101
402 AC                   endif
     *
402 AC                   when      w1qrc3 <> 0  and
402 AC                             w1avg = 'Y'
402 AC                   if        w1qrc1 <> 0  or
402 AC                             w1qrc2 <> 0
402 AC                   eval      error = *on
402 AC                   eval      *in32 = *on
402 AC                   eval      *in12 = *on
402 AC                   eval      errmsg = *blanks
402 AC                   eval      errmsg = desc(12)
402 AC                   exsr      zm2101
402 AC                   endif
     *
402 AC                   endsl
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
     *     Item number.
     *
     C                   when      row# = 10
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1itm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1itm = $litem
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     *
     C                   goto      endcm1
     C                   endif
     *
     *      F21 - Item Maintenance.
     *
     C                   if        *inkv
     C                   eval      cmdtkn = *on
     C                   eval      $lcmd = '*ADD    '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = *blanks
     C                   eval      $lprg = #prog
     C                   call      'IT112'
     C                   parm                    $lparm
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
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1seq = 0
     C                   eval      w1itm = *blanks
     C                   eval      w1qor1 = 0
     C                   eval      w1qor2 = 0
     C                   eval      w1qor3 = 0
415 AC                   eval      w1qrc1 = 0
415 AC                   eval      w1qrc2 = 0
415 AC                   eval      w1qrc3 = 0
415 AC                   eval      w1avg = 'N'
415 AC                   eval      w1dwgt = 0
415 AC                   eval      *in95 = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
402 AC                   eval      *in95 = *off
     C                   eval      w1seq = pdseq
     C                   eval      w1itm = pditem
     C                   eval      w1qor1 = pdqor1
     C                   eval      w1qor2 = pdqor2
     C                   eval      w1qor3 = pdqor3
402 AC                   eval      w1qrc1 = pdqrc1
402 AC                   eval      w1qrc2 = pdqrc2
402 AC                   eval      w1qrc3 = pdqrc3
402 AC                   eval      w1avg = 'N'
402 AC                   eval      w1dwgt = pddwgt
     *
402 AC     ittkey        chain     piritem                            75
402 AC                   if        itcwgt <> 'Y'
402 AC                   eval      *in95 = *on
402 AC                   else
402 AC                   eval      *in95 = *off
402 AC                   endif
500 A*
500 A*   Retrieve Buyer number/name for display.
500 AC     ittkey        chain     itemmsc                            74
500 AC                   if        *in74
500 AC                   eval      w1bnbr = *zeros
500 AC                   eval      w1bnam = *blanks
500 AC                   else
500 AC                   move      imbnbr        w1bnbr
500 AC                   eval      w1bnam = imbnam
500 AC                   endif
402 A*
402 A*   Catchweight cannot be entered in this prog, if No qty is recvd
402 A*
402 AC                   if        itcwgt = 'Y'  and
402 AC                             pdqrc1 = 0  and
402 AC                             pdqrc2 = 0  and
402 AC                             pdqrc3 = 0
402 AC                   eval      *in95 = *on
402 AC                   endif
402 A*
412aA*   Enable receive qty if designation code has '*' in right most position.
415aA*
415aAC                   eval      dsdesg = itdesg
415aAC                   if        dsdes5 = '*'
415aAC                   eval      *in33 = *on
415aAC                   eval      *in34 = *on
415aAC                   eval      *in35 = *on
415aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
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
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C     endgt2        endsr
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
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define key for main file.
     *
     C     podkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    w1seq
     C                   kfld                    w1itm
413 A*
413 A*  Define partial key for main file.
413 A*
413 AC     podky1        klist
413 AC                   kfld                    $pwhse
413 AC                   kfld                    $ppo
413 AC                   kfld                    w1seq
402 A*
402 A*  Define key for PIRITEM file.
402 A*
402 AC     ittkey        klist
402 AC                   kfld                    $pwhse
402 AC                   kfld                    $pitem
     *
404 A* Cross Dock file
     *
404 AC     xdkey         klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $ppo
404 AC                   kfld                    seq
405 A*
405 A* Order detail file.
405 A*
405 AC     odkey         klist
405 AC                   kfld                    $pwhse
405 AC                   kfld                    cdord
405 AC                   kfld                    cdorsq
405 AC                   kfld                    svitem
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
404 AC                   eval      forevr = *off
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pseq = 0
     C                   eval      $pitem = *blanks
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      pdwhse = $pwhse
     C                   eval      pdpo = $ppo
     C                   eval      pdseq = w1seq
     C                   eval      pditem = w1itm
     C                   eval      pdqor1 = w1qor1
     C                   eval      pdqor2 = w1qor2
     C                   eval      pdqor3 = w1qor3
415aAC                   eval      pdqrc1 = w1qrc1
415aAC                   eval      pdqrc2 = w1qrc2
415aAC                   eval      pdqrc3 = w1qrc3
402 AC                   if        w1avg = 'Y'
402 AC     w1dwgt        mult      w1qrc1        pddwgt
402 AC                   else
402 AC                   eval      pddwgt = w1dwgt
402 AC                   endif
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
415bAC                   eval      pdqrc1 = 0
415bAC                   eval      pdqrc2 = 0
415bAC                   eval      pdqrc3 = 0
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
770aA /free
770aA   // Set status for DockVue for header add
770aA   // Check system option for DockVue
770aA   if dockvue;
770aA     exec sql insert into postatus
770aA              values (:pdwhse, :pdpo, '0',
770aA                      current_timestamp, :nostamp);
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql update postatus
770aA                   set posstat = '0',
770aA                       posupdts = current_timestamp
770aA                 where poswhs = :pdwhse
770aA                   and pospo = :pdpo;
770aA     endif;
770aA   endif;
770aA /end-free
404 AC                   eval      seq = 0
404 AC     xdkey         setll     crossdk3
404 AC                   dow       forevr = forevr
     *
404 AC     xdkey         reade     crossdk3                               79
404 AC                   if        *in79
404 AC                   leave
404 AC                   endif
405 AC                   eval      svitem = oditem
404 AC                   if        oditem = pditem
404 AC     xdkey         setll     crossdk2
405 AC                   dow       forevr = forevr
404 AC     xdkey         reade     crossdk2                               77
405 A*
405 AC                   if        *in77
405 AC                   leave
405 AC                   endif
405 AC     odkey         chain     ordd                               75
405 AC                   if        not *in75
405 AC                   eval      cdposq = pdseq
405 AC                   update    cdrec
405 AC                   leave
405 AC                   else
405 AC                   iter
405 AC                   endif
405 AC                   enddo
405 A*
404 AC                   endif
404 AC                   enddo
     *
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
770aA /free
770aA   // Update POSTATUS for a po change
770aA   // Check system option for DockVue
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = '0',
770aA                     posupdts = current_timestamp
770aA               where poswhs = :pdwhse
770aA                 and pospo = :pdpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:pdwhse, :pdpo, '0',
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pseq = pdseq
     C                   eval      $pitem = pditem
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item
Normal Qty Ordered
Breakdown 1 Qty Ordered
Breakdown 2 Qty Ordered
Corresponding Warehouse
Corresponding Order
Normal Qty Picked
Breakdown 1 Qty Picked
Breakdown 2 Qty Picked
Sequence number
Catch weight
Average
