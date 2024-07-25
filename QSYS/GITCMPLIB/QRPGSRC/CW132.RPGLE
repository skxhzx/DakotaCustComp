      *----------------------------------------------------------------
      *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
      *   West Chicago, IL  60185
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  CW132     UCI Catch weight maint - Change
      *  14 June  2006
      *  Jeffrey Jahnke
      *  Created using CW122
      *
      *----------------------------------------------------------------
      *  Revisions
      *
510 A *    06/14/06  JCJ  5.10
      *      - Created.
510aA*    09/29/06  RAH  510a
     *      - Enh: Add output to UCI Log File - UCILOG
510bA*    10/05/06  RAH  510b
     *      - Enh: Add 16x20 screen support
510cA*    10/31/06  JCJ  510c
     *      - Fix: Initialized UCISTS, UCIPCK, UCIRTS, UCIRCT
510dA*    11/03/06  JCJ  510d
     *      - Enh: Add 08x20 screen support
510eA*    11/14/06  JCJ  510e
     *      - Enh: output po sequence number to UCICW
510fA*    01/11/06  JCJ  510f
     *      - Fix: position to weight after uci scan
510gA*    04/28/07  JCJ  510g
     *      - Enh: add new edit to require UCI to be 10 digits.
510hA*    10/23/07  JCJ  510h
     *      - Enh: Do not allow F12 if all UCI's are not entered.
510iA*    10/28/07  JCJ  510i
     *      - Fix: Initialized UCISQO, UCILBL, UCIVAL
700aA*    08/30/16  LMC  700a
     *      - Enh: UCILOG file was renamed to PUCILOG, so we could
     *             reuse UCILOG for our uci tracking.
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  01 - 20   Field position to
      *  21 - 40   Field input error (reverse display)
      *  81        Display subfile records (SFLDSP)
      *  82        Display subfile screen (SFLDSPCTL)
      *  83        Clear subfile (SFLCLR)
      *  84        Allow subfile to display '+' (SFLEND)
      *  85        Manually set subfile change flag (SFLNXTCHG)
      *  90        View mode (Protect input fields)
      *  91        Change mode (protect key)
      *  97        Error message subfile indicator
      *  98        Error on screen (sound buzzer)
      *  99        Universal record indicator (very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs

     FCW132FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DETAIL1:RECNO)
     F                                     SFILE(MSGREC:MSGK)
510bAF                                     SFILE(D16AIL1:RECNO)
510bAF                                     SFILE(M16REC:MSGK)
     Fucicw     if   e           k disk    rename(ucirec:record)
     Fucicw1    uf a e           k disk    rename(ucirec:record1)
     Fucicw2    if   e           k disk    rename(ucirec:record2)
     Fwarehs    if   e           k disk
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpiritem   if   e           k disk
700aDF*ucilog    o  a e           k disk
700aMFpucilog   o  a e           k disk
      *----------------------------------------------------------------
      *  Table and array definitions

     D A10             s              1    DIM(10)
     D uci             s             10    dim(500)
510gD**desc            s             50    DIM(10) CTDATA PERRCD(1)
510hM**desc            s             50    DIM(11) CTDATA PERRCD(1)
510hMD desc            s             50    DIM(12) CTDATA PERRCD(1)
      *----------------------------------------------------------------
      *  Program parameters

     D $parms          DS
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

      *   Redefine key

     D  $pwhse                19     20P 0
     D  $ppo                  21     29
     D  $pseq                 30     32P 0
     D  $pitem                33     47
     D  $pqyr1                48     50P 0
     D  $pqyr2                51     53P 0
     D  $pqyr3                54     56P 0
     D  $pcwte                57     59P 0
     D  $pcwtt                60     64P 2
     D  $pcwta                65     68P 2
      *----------------------------------------------------------------
      *  Called program parameters

     D $lparm          DS
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

      * Redefine key

     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lrack                22     26

     D  $lbld                 19     20
      *----------------------------------------------------------------
      *  *SYSTEM  -  System options.
      *
      * Fields
      *
      *    OPEPM   -  Using EPM module (Y,N).
      *    OPRF    -  Using RF module (Y,N).
      *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
      *    OPLETD  -  Print letdown labels (Y,N).
      *    OPWRNC  -  Perform catch weight variance check (Y,N).
      *    OPRG1C  -  Catch weight low variance percentage.
      *    OPRG2C  -  Catch weight high variance percentage.
      *    OPIMPI  -  Import item fields from host.(Y,N).
      *    OPICW   -  Individual catch weight entry (Y,N).

      * Data structure

     D opdata          DS
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
      *----------------------------------------------------------------
      *  Called programs

     D @cvtdt          C                   CONST('CVTDTE')
      *----------------------------------------------------------------
      *  Called program parameters

     D $cvtdt          DS
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
      *----------------------------------------------------------------
      *  Data structure for error message parameters

     D $mdt            DS
     D  errmsg                 1     50

     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50

     D  ertcwt                 1      5P 2
     D  erlrng                 6     10P 2
     D  erhrng                11     15P 2
     D  errg1c                16     17P 1
     D  errg2c                18     19P 1
     D  erexwt                20     24P 2

     D  ertcw#                 1      3P 0
     D  erqpck                 4      6P 0

     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42P 0
     D  erclvl                43     44P 0
     D                 DS
     D  $ec                    1      2P 0
      *----------------------------------------------------------------
      *  Message control

     D #msgf           C                   CONST('PIRMSGF   ')

     D                 DS
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
      *----------------------------------------------------------------
      *  Program info data structure

     D                SDS
     D  #prog            *PROC
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
      *----------------------------------------------------------------
      *  Workstation exception data structure

     D infds           DS
     D  status           *STATUS
     D  rowin                370    370
     D  colin                371    371
      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure

     D                 DS
     D  row#                   1      2B 0
     D  row                    2      2
     D  col#                   3      4B 0
     D  col                    4      4

      *----------------------------------------------------------------
      *  Variables
      *
     D @Counter        S             15  5
510bAD $cbv1           S             11  3
     D lstseq          S              5  0
     D lwvar           S              9  2
     D hivar           S              9  2
     D lwrng           S              9  2
     D hirng           S              9  2
     D exwgt           S              9  2
     D ilvar           S              9  2
     D ihvar           S              9  2
     D ilrng           S              9  2
     D ihrng           S              9  2
     D svtcw           S              9  2
     D $prcvd          S              8  0
     D $pexpd          S              8  0
     D taddw           S              7  2
     D wttcw           S              7  2
     D w1addw          S              7  0
     D svaddw          S              7  0
     D svcw#           S              7  0
510cAD $portrn         S              7  0
     D enter           S              5  0
     D comand          S              5  0
     D rollup          S              5  0
     D rolldn          S              5  0
     D clear           S              5  0
     D help            S              5  0
     D prg1c           S              4  3
     D prg2c           S              4  3
     D recno           S              4  0
     D reccnt          S              4  0
510hAD count           S              4  0
     D posrec          S              4  0
     D msgk            S              4  0
     D l               s              3  0
     D $cbcod          S              3  0
     D $cbpos          S              3  0
     D e               S              2  0
     D LenOfUci#       S              2  0
     D $cbdec          S              1  0
     D $cbtyp          S              1  0
     D $cbbar          S            100
     D $cberm          S             60
     D $cbv2           S             50
     D $cbdsc          S             30
     D $plotc          S             30
     D $plcns          S             15
     D blkuci          S             10
     D #pgmq           S             10
     D #pgmq2          S             10
     D $msgf           S             10
510aAD @Caller         S             10
     D $cbcmd          S              8
     D $cbrtn          S              8
     D cmdchk          S              8
     D #msgid          S              7
     D #msgtp          S              7
     D #msgk           S              4
     D nxtscr          S              3
     D ovrrid          S              1
     D stop            S              1
     D warn            S              1
     D error           S              1
     D cmdtkn          S              1
     D redspl          S              1
     D cwtck           S              1
     D cweck           S              1
     D twtck           S              1
     D sclear          S              1
     D lvskp           S              1
     D hvskp           S              1

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $PCMD   *ADD     - Create new batch.
      *              *CHANGEP - Change during post from PT132.
     *              *VIEW    - View record.
      *      $PPRG   Program to send messages back to.
      *      $PUKY   Contains key for everything by *ADD.
      *
      *    Returned Parameters
      *      $PUKY   Contains new batch number for *ADD.
      *              Unchanged for everything else.
      *      $PRTN   blank    - No problem encountered.
      *              *ERROR   - Error occured. Message in $PERM
      *              *PGMQ    - Error occured. Message sent to pgmq.
      *      $PERM   Error message or pointer to message in pgmq.
      *
      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms
510 AC                   parm                    $plcns
510 AC                   parm                    $pexpd
510 AC                   parm                    $plotc
510 AC                   parm                    $prcvd
510cAC                   parm                    $portrn

510aAC     UI866P        Plist
510aAC                   Parm                    @Caller
510aAC                   Parm                    @Counter
      *----------------------------------------------------------------
      *  Main line

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

     C     nxtscr        downe     'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '03 '         SC3
     C                   endcs
     C                   enddo

      *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return
      *----------------------------------------------------------------
      *  DSPSCR - Display screen

     C     dspscr        begsr

      *   Set ON alarm indicator if error occured

     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif

      *   Overlay screen with error messages

     C                   exsr      zmdmsg

      *  Overlay screen with screen to be processed.

     C                   select
     C                   when      nxtscr = '03 '
     C                   exsr      sfldsp
510dAC                   select
510bAc                   when      #lline = '16'
510bAC                   read      h16d1                                  50
510bAc                   when      #lline = '08'
510dAC                   read      h16d1                                  50
510bAc                   other
     C                   read      head1                                  50
510bAc                   endsl
     C                   endsl

      *   Initialize error indicators and fields

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
     C                   eval      e = *zeros

      *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr
      *----------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *
      *  Screen 03 initialization

     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   eval      ovrrid = *off

     C                   select
     C                   when      $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3

      *  Get field defaults if this is an add.

     C                   when      $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   exsr      zzfil3

      *  Otherwise get existing record(s).

     C                   other
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endsl
     C     end03i        endsr
      *----------------------------------------------------------------
      *
      *              Screen Processing Routines
      *
      *----------------------------------------------------------------
      *
      *  SC3  -  Screen 3

     C     sc3           begsr

      *  Test for F3 - Exit

     C                   if        *inkc = *on
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif

      *  Test for F5 - Refresh

     C                   if        *inke = *on
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif

      *  Test for F12 - Previous

     C                   if        *inkl = *on
     C*
510hAC                   if        count<%ABS(wopqty)
510hAC                   eval      error = *on
510hAC                   eval      *in16 = *on
510hAC                   eval      *in36 = *on
510hAC                   movea     desc(12)      errmsg
510hAC                   movea     errmsg        $md(1)
510hAC                   exsr      zm9999
510hAC                   goto      endsc3
510hAC                   else
510dD ***                if        $pcmd = '*ADD    ' or $pcmd = '*VIEW   '
     C                   eval      nxtscr = 'EOJ'
510dD ***                endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
     C                   endif
510hAC*
510hAC                   endif

      *  Test for other command keys BEFORE verification and update.

     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3

      *  Some other key pressed.

      *     Check input and write/update record.

     C                   if        $pcmd = '*ADD    ' or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     REDSPL        CABEQ     *ON           ENDSC3
     C     ERROR         CABEQ     *ON           ENDSC3
     C                   endif

      *  Test for other command keys AFTER verification and update.

     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3

      *  Everything went fine so get out of program.

     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr

      *  Initialize special keys

     C                   eval      enter  = *zeros
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear  = 01124
     C                   eval      help   = 01125

      *  Initialize message handling

     C                   exsr      zmimsg

      *   Call user added initialization routine.

     C                   exsr      zzinz

510aA * Determine Calling program
510aA
510aAC                   Eval      @Counter = 4
510aAC                   Eval      @Caller  = *Blanks

510aAC                   Call      'UI866'       UI866P
      *
     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLADD   Add record to subfile

     C     sfladd        begsr
     C                   eval      reccnt = reccnt + 1
     C                   eval      recno = reccnt
510hAC                   eval      count = count + 1
     C                   eval      *in85 = *on
510dAC                   Select
510bAc                   when      #lline = '16'
510bAc                   write     d16ail1
510bAc                   when      #lline = '08'
510bAc                   write     d16ail1
510bAc                   other
     C                   write     detail1
510bAc                   endsl
     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLCLR   Clear display subfile

     C     sflclr        begsr

      *  clear display subfile

     C                   eval      recno = *zeros
     C                   eval      reccnt = *zeros
510hAC                   eval      count = *zeros
     C                   eval      posrec = 1

     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
510dAC                   Select
510bAc                   when      #lline = '16'
510bAc                   write     h16d1
510bAc                   when      #lline = '08'
510bAc                   write     h16d1
510bAc                   other
     C                   write     head1
510bAc                   endsl
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off

     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLDSP   Display subfile
      *
     C     sfldsp        begsr

      *  write option and command lines to display

510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     c16rec
510bAc                   when      #lline = '08'
510bAc                   write     c16rec
510bAc                   other
     C                   write     cmdrec
510bAc                   endsl

      *  write position to field to display

      *  write subfile to display

     C                   if        reccnt > *zeros
     C                   eval      *in81 = *on
     C                   endif
     C                   if        reccnt > 40
     C                   eval      posrec = reccnt
     C                   endif
     C                   eval      recno = posrec
510dAC                   select
510bAc                   when      #lline = '16'
510bAC                   write     h16d1
510bAc                   when      #lline = '08'
510bAC                   write     h16d1
510bAc                   other
     C                   write     head1
510bAc                   endsl
     C                   endsr
      *---------------------------------------------------------------
      *
      *  SUBROUTINE ZMxxxx  Control message display subfile
      *
      *    ZMCMSG  Clear message record subfile

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     m16ctl
510bAc                   when      #lline = '08'
510bAc                   write     m16ctl
510bAc                   other
     C                   write     msgctl
510bAc                   endsl
     C                   eval      msgk = *zeros
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     m16clr
510bAc                   when      #lline = '08'
510bAc                   write     m16clr
510bAc                   other
     C                   write     msgclr
510bAc                   endsl
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZMDMSG  Display message record subfile

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > *zeros
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     m16ctl
510bAc                   when      #lline = '08'
510bAc                   write     m16ctl
510bAc                   other
     C                   write     msgctl
510bAc                   endsl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZMIMSG  Initialization necessary for message subfile

     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZMPMSG  Add message record to subfile

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
     C                   eval      msgk = msgk + 1
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     m16rec
510bAc                   when      #lline = '08'
510bAc                   write     m16rec
510bAc                   other
     C                   write     msgrec
510bAc                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZMQMSG  Add message record to subfile from program queue

     C     zmqmsg        begsr
     C                   eval      msgk = msgk + 1
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   write     m16rec
510bAc                   when      #lline = '08'
510bAc                   write     m16rec
510bAc                   other
     C                   write     msgrec
510bAc                   endsl
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZSCLR   Clear screen

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZMSMSG  Send program message to a different program msgq

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $PPRG         #pgmq2
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C
     C                   endsr
      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *      0105

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR0201  Code must be entered for create.

     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR0202  Code already exists.

     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(9)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR0203  Value required

     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(9)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PT13019  # of catch weights entered must = Quantity picked.

     C     zm20          begsr
     C                   eval      #msgid = 'PT13020'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PT13020  Warning: Entered catch weight not within +/- range.

     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR7871  Error in writing a record.

     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR7872  Error in updating a record.

     C     ZM7872        BEGSR
     C                   MOVE      'PIR7872'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR7971  Error in writing a record.

     C     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR7972  Error in updating a record.

     C     ZM72          BEGSR
     C                   MOVE      'PIR7972'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR9905  Cursor not in correct position for lookup.

     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
510hA *----------------------------------------------------------------
510hA *   PIR9999  Generic error for message from array.

510hAC     zm9999        begsr
510hAC                   eval      #msgid = 'PIR9999'
510hAC                   eval      #msgtp = '*DIAG  '
510hAC                   exsr      zmpmsg
510hAC                   endsr
      *----------------------------------------------------------------
      *   PIR0112  Invalid range entered.

     C     ZM0112        BEGSR
     C                   MOVE      'PIR0112'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR1001  Invalid value entered.

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZCHK3   Screen 3 error checking.

     C     zzchk3        begsr

     * UCI number must be unique.

     C                   if        w1uci <> *blanks
     C     ucikey        chain     ucicw                              79
     C                   if        *in79 = *off
     C                   eval      error = *on
     C                   eval      *in16 = *on
     C                   eval      *in36 = *on
     C                   exsr      zm02
     C                   goto      endck3
     C                   endif

510gA* UCI number must be 10 characters long.

510gAC                   if        w1uci <> *blanks
510gAC                   Eval      LenOfUci# = %Len(%Trim(w1uci))
510gAC                   if        LenOfUci# <> 10
510gAC                   eval      error = *on
510gAC                   eval      *in16 = *on
510gAC                   eval      *in36 = *on
510gAC                   movea     desc(11)      errmsg
510gAC                   exsr      zm0105
510gAC                   goto      endck3
510gAC                   endif
510gAC                   endif

     * Verify user hasn't scanned same uci# multiple times.

     C                   eval      l = 1
     C     w1uci         lookup    uci(1)                                 80
     C                   if        *in80
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   eval      errmsg = desc(10)
     C                   exsr      zm0105
     C                   goto      endck3
     C                   endif
     C                   endif

     C                   if        w1uci = *blanks and w1wgt <> *blanks
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   exsr      zm02
     C                   goto      endck3
     C                   endif

510fA * Added code to position cursor to weight after usi is scanned

510fAC                   if        w1uci <> *blanks and w1wgt = *blanks
510fAC                   eval      error = *on
510fAC                   eval      *in17 = *on
510fAC                   goto      endck3
510fAC                   endif

      *   CWTCK Flags are used to force F20 for each test
      *   Values: Flag = 0 Do check.
      *           Flag = 1 Check was done, ok.
      *           Flag = 2 Warning condition.

     C                   eval      error = *off

     C                   movel(P)  w1wgt         $CBBAR
     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd
     C                   parm                    $cbbar
     C                   parm      *zeros        $cbcod
     C                   parm      *zeros        $cbdec
     C                   parm      *blanks       $cbdsc
     C                   parm      *zeros        $cbpos
     C                   parm      *zeros        $cbtyp
     C                   parm      *zeros        $cbv1
     C                   parm      *blanks       $cbv2
     C                   parm      *blanks       $cbrtn
     C                   parm      *blanks       $cberm

      *    Weight converted successfully.
     C                   select
     C                   when      $cbrtn = '*OK'
     C                   eval      w1addw = $cbv1 * 100

      *    Error occured while converting weight.
     C                   other
     C                   eval      error = *on
     C                   eval      *in17 = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = $cberm
     C                   exsr      zm0105
     C                   goto      endck3
     C                   endsl

      *   Verify catch weight add.

     C                   if        w1addw <> *zeros

     C                   if        svaddw <> w1addw
     C                   eval      cwtck = *off
     C                   endif

     C                   if        cwtck = '2' and ovrrid = *on
     C                   eval      cwtck = *on
     C                   endif

     C                   if        cwtck <> '1'
     C                   eval      cwtck = *on

      *     Verify catch weight is within range.

     C                   if        w1addw < *zeros or w1addw > 9999999
     C                   eval      error = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erfld = desc(1)
     C                   eval      erfrom = '0'
     C                   eval      erto = '9999999'
     C                   exsr      zm0112
     C                   endif

      *     Check individual CW if variance check = Y.

     C                   if        opwrnc = 'Y' and opicw = 'Y'
     C                   eval      taddw = w1addw / 100

     C                   if        lvskp = *off and taddw < ilrng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   MOVE      '2'           CWTCK
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     ilrng         erlrng
     C                   if        hvskp = *on
     C                   eval      erhrng = *zeros
     C                   else
     C                   eval      erhrng = ihrng
     C                   endif
     C                   eval      errg1c = prg1c * 100
     C                   eval      errg2c = prg2c * 100
     C                   exsr      zm19
     C                   endif

     C                   if        hvskp = *off and
     C                             taddw > ihrng
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   if        lvskp = *on
     C                   eval      erlrng = *zeros
     C                   else
     C                   eval      erlrng = ilrng
     C                   endif
     C                   eval      erhrng = ihrng
     C                   eval      errg1c = prg1c * 100
     C                   eval      errg2c = prg2c * 100
     C                   exsr      zm19
     C                   endif

     C                   endif

     C                   endif
     C                   endif

      *   Verify changed subfile records.

510hAc                   eval      count = 0

     C                   if        reccnt > *zeros
     C                   eval      posrec = *zeros
     C                   eval      *in79 = *off
     C                   dou       *in79 = *on
510dAC                   select
510bAc                   when      #lline = '16'
510bAc                   readc     d16ail1                                79
510bAc                   when      #lline = '08'
510bAc                   readc     d16ail1                                79
510bAc                   other
     C                   readc     detail1                                79
510bAc                   endsl

     C                   if        *in79 = *on
     C                   leave
     C                   endif

     C                   eval      *in19 = *off
     C                   eval      *in20 = *off
     C                   eval      *in39 = *off
     C                   eval      *in40 = *off

      *      Verify right definition.

510hAc                   eval      count = count + 1
     C                   eval      *in85 = *on
510dAC                   select
510dAc                   when      #lline = '16'
510bAc                   update    d16ail1
510dAc                   when      #lline = '08'
510dAc                   update    d16ail1
510bAc                   other
     C                   update    detail1
510bAc                   endsl
     C                   if        posrec = *zeros
     C                   if        *in38 = *on or
     C                             *in39 = *on
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo

     C                   if        posrec = *zeros
     C                   eval      posrec = 1
     C                   endif

     C                   endif

      *   Save screen fields.
     C                   eval      svaddw = w1addw

     C                   if        not *in80 and error = *off
     C                                       and w1wgt <> *blanks
     * uci# not found.  Find next empty element.
     C                   eval      l = 1
     C                   eval      blkuci = *blanks
     C     blkuci        lookup    uci(l)                                 80
     C                   if        *in80
     C                   eval      uci(l) = w1uci
     C                   endif
     C                   endif

     C     endck3        endsr
      *----------------------------------------------------------------
      *
      *  ZZCHKT   Screen 3 error check totals

     C     zzchkt        begsr
      *   CWECK, TWTCK Flags are used to force F20 for each test
      *   Values: Flag = 0 Do check.
      *           Flag = 1 Check was done, ok.
      *           Flag = 2 Warning condition.

     C                   eval      error = *off

      *     Check # of entrys if individual catchweight entry = Y

     C                   if        opwrnc = 'Y' and opicw = 'Y'

     C                   if        svcw# <> wocw#
     C                   eval      cweck = '0'
     C                   endif

     C                   if        cweck = '2' and
     C                             ovrrid = *on
     C                   eval      cweck = '1'
     C                   endif

     C                   if        cweck <> '1'
     C                   eval      cweck = '1'

     C                   if        wocw# <> totrcv
     C                   eval      posrec = 1
     C                   eval      error = *on
417bA *    Nbr catchwgts entered cannot exceed quantity received.
     C                   if        wocw# > totrcv
     C                   eval      cweck = '0'
417bAC                   else
     C                   eval      cweck = '2'
417bAC                   endif
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcw# = wocw#
     C                   eval      erqpck = totrcv
     C                   exsr      zm20
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     C                   endif

      *     Compare total catchweight to expected catchweight

     C                   if        opwrnc = 'Y'

     C                   if        svtcw <> wotcw
     C                   eval      twtck = *off
     C                   endif

     C                   if        twtck = '2' and
     C                             ovrrid = *on
     C                   eval      twtck = '1'
     C                   endif

     C                   if        twtck <> '1'
     C                   eval      twtck = '1'

     C                   if        lvskp = *off and
     C                             wotcw < lwrng
     C                   eval      posrec = 1
     C                   eval      error  = *on
     C                   eval      twtck  = '2'
     C                   eval      warn   = *on
     C                   eval      *in28  = *on
     C                   eval      *in08  = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = *zeros
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C                   eval      errg1c = prg1c * 100
     C                   eval      errg2c = prg2c * 100
     C                   exsr      zm19
     C                   endif

     C                   if        hvskp = *off and
     C                             wotcw > hirng
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn   = *on
     C                   eval      *in28  = *on
     C                   eval      *in08  = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = *zeros
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C                   eval      errg1c = prg1c * 100
     C                   eval      errg2c = prg2c * 100
     C                   exsr      zm19
     C                   endif

     C     error         cabeq     *on           enderr
     C                   endif

     C                   endif
     C     enderr        tag
      *   Save screen fields.
     C                   eval      svcw# = wocw#
     C                   eval      svtcw = wotcw

     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZCMD3   User defined command keys for screen 1.

     C     zzcmd3        begsr

      *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '

      *  Test for F4 - Lookup

     C                   if        *inkd = *on
     C                   eval      cmdtkn = *on
     C                   eval      row# = *zeros
     C                   eval      row = rowin
     C                   eval      col# = *zeros
     C                   eval      col = colin

      *     Build code.

     C                   select

     C                   other

      *     Cursor not on a valid lookup field.

     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif

      *      F20 - Accept Warning.

     C                   if        *inku = *on
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     C                   endif

      *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
      *----------------------------------------------------------------
      *
      *  ZZDFT3   Get default values for add.

     C     zzdft3        begsr
     C                   eval      w1addw = *zeros

     C                   exsr      sflclr
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZFIL3   Fill screen 3 fields with info from file.

     C     zzfil3        begsr
     C                   eval      w1uci = *blanks
     C                   eval      w1wgt = *blanks

      *    Compute total qty received.
     C                   eval      wopqty = $pqyr1 + $pqyr2 + $pqyr3
     C                   eval      wopo = $ppo

     C     itkey         chain     piritem                            79
     C                   if        *in79 = *off
     C                   eval      wodesc = itdesc
     C                   else
     C                   eval      wodesc = *blanks
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif

      *    Convert weight for break-down 2 qty.
     C                   if        itumq2 > *zeros
     C                   eval(H)   olywg2 = itswgt / itumq2
     C                   else
     C                   eval      olywg2 = *zeros
     C                   endif

      *    Convert weight for break-down 3 qty.
     C                   if        itumq3 > *zeros
     C                   eval(H)   olywg3 = itswgt / itumq3
     C                   else
     C                   eval      olywg3 = *zeros
     C                   endif

      *   If verify catch weight = yes,
      *     Calculate total expected catch weight,
      *     Calculate low/high ranges.
     C                   if        opwrnc = 'Y'
     C                   eval      lwvar = *zeros
     C                   eval      hivar = *zeros
     C                   eval      lwrng = *zeros
     C                   eval      hirng = *zeros
     C                   eval      exwgt = *zeros
     C                   eval      ilvar = *zeros
     C                   eval      ihvar = *zeros
     C                   eval      ilrng = *zeros
     C                   eval      ihrng = *zeros

      *    Extend weight for case qty.
     C                   eval      exwgt = $pqyr1 * itswgt

      *    Extend weight for break-down 2 qty.
     C                   if        $pqyr2 > *zeros
     C                   if        olywg2 > *zeros
     C                   eval      extwg2 = $pqyr2 * olywg2
     C                   else
     C                   eval      extwg2 = *zeros
     C                   endif
     C                   eval      exwgt = exwgt + extwg2
     C                   endif

      *    Extend weight for break-down 3 qty.
     C                   if        $pqyr3 > *zeros
     C                   if        olywg3 > *zeros
     C                   eval      extwg3 = $pqyr3 * olywg3
     C                   else
     C                   eval      extwg3 = *zeros
     C                   endif
     C                   eval      exwgt = exwgt + extwg3
     C                   endif

      *    Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
      *    Use item variance % if it exists
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off

     C                   if        imrg1c <> *zeros
     C                   eval      prg1c = imrg1c / 100
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif

     C                   if        imrg2c <> *zeros
     C                   eval      prg2c = imrg2c / 100
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif

     C                   endif

     C                   if        prg1c = *zeros
     C                   eval      prg1c = oprg1c / 100
     C                   endif
     C                   if        prg2c = *zeros
     C                   eval      prg2c = oprg2c / 100
     C                   endif

     C                   if        prg1c > *zeros
     C                   eval      lwvar = exwgt * prg1c
     C                   eval      ilvar = itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = itswgt - ilvar
     C                   if        prg2c > *zeros
     C                   eval      hivar = exwgt * prg2c
     C                   eval      ihvar = itswgt * prg2c
     C                   endif
     C                   eval      hirng = exwgt + hivar
     C                   eval      ihrng = itswgt + ihvar

     C                   endif

     C                   eval      w1addw = *zeros

     C                   exsr      sflclr
     C     uciky2        setll     ucicw2
     C                   eval      stop  = *off
     C                   dou       stop = *on
     C     uciky2        reade     ucicw2                                 79
     C                   if        *in79 = *on
     C                   eval      stop  = *on
     C                   leave
     C                   endif

     C                   eval      wotcw = wotcw + uciwgt
     C                   eval      wocw# = wocw# + 1
     C                   eval      w1seq = ucisq2
      *    Move decimal point 2 places to the right for display.
     C                   move      uciwgt        w1cwgt
     C                   eval      w1uci2 = ucinbr
     C                   exsr      sfladd
     C                   eval      lstseq = ucisq2
     C                   enddo
     C                   eval      posrec = 1
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZGET3   Get record(s) for screen 3.

     C     zzget3        begsr

     C     endgt3        endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     ucikey        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1uci

      *  Define partial key for detail file.

     C     uciky1        klist
     C                   kfld                    uciwhs
     C                   kfld                    ucilcn
     C                   kfld                    ucisq2

      *  Define full key for detail file.

     C     uciky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $plcns

      *  Define key for OPTIONS file.

     C     *like         define    opwhse        wkwhse
     C     *like         define    opcode        wkcode
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode

      *  Define full key for ITEMMSC file.

     C     imkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

      *  Define full key for item file.

     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

     C                   eval      $lprg = #prog
     C                   endsr
      *----------------------------------------------------------------
      *  ZZINZ2   Program initialization. Called from main line.

     C     zzinz2        begsr

      *   Check for *CHANGEP

     C                   if        $pcmd = '*CHANGEP'
     C                   eval      $pcmd = '*CHANGE '
     C                   eval      *in92 = *on
     C                   else
     C                   eval      *in92 = *off
     C                   endif

      *   Get warehouse description.

     C     $pwhse        chain     warehs                             79
     C                   if        *in79 = *on
     C                   eval      whdesc = *blanks
     C                   endif

     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = *zeros
     C     opkey         chain     options                            79
     C                   if        *in79 = *on
     C                   MOVE      'Y'           OPCAPC
     C                   MOVE      'N'           OPWRNC
     C                   Z-ADD     0             OPRG1C
     C                   Z-ADD     0             OPRG2C
     C                   MOVE      'N'           OPICW
     C                   endif

      *    Define working variables.
     C     *like         define    itswgt        olywg2
     C     *like         define    itswgt        olywg3
     C     *like         define    exwgt         extwg2
     C     *like         define    exwgt         extwg3
     C     *like         define    $pcwte        totrcv

     C                   eval      wopqty = $pqyr1 + $pqyr2 + $pqyr3
     C                   eval      wopo = $ppo
      *    Compute total qty received.
     C                   eval      totrcv = $pqyr1 + $pqyr2 + $pqyr3

      *   Initialize counter and total fields.
     C                   eval      wocw# = *zeros
     C                   eval      wotcw = *zeros
     C                   eval      lstseq = *zeros
     C                   eval      w1addw = *zeros
     C                   eval      cwtck = *off
     C                   eval      cweck = *off
     C                   eval      twtck = *off
     C                   eval      lvskp = *off
     C                   eval      uci = *blanks

510bAC*   Get screen size being used.
     C
510bAC                   call      'PIRRFSCR'
510bAC                   parm      '*GET'        #lcmd             8
510bAC                   parm                    #lline            2
510bAC                   parm                    #lcol             3
     C
      *   Select first screen to display.

     C                   exsr      scr03i
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZTOTL   Recalculate total cw and entered cw.

     C     zztotl        begsr
     C                   eval      error = *off
     C                   eval      wotcw = *zeros
     C                   eval      wocw# = *zeros

      *   Loop through subfile records and recaluclate.
     C                   if        reccnt > *zeros
     C                   eval      *in85 = *on
     C                   eval      *in79 = *off
     C                   dou       *in79 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAc                   readc     d16ail1                                79
510dAc                   when      #lline = '08'
510dAc                   readc     d16ail1                                79
510bAc                   other
     C                   readc     detail1                                79
510bAc                   endsl

     C                   if        *in79 = *on
     C                   leave
     C                   endif

     C                   eval      *in85 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAC                   update    d16ail1
510dAc                   when      #lline = '08'
510dAC                   update    d16ail1
510bAc                   other
     C                   update    detail1
510bAc                   endsl

     C                   eval      wttcw = w1cwgt / 100
     C                   eval      wotcw = wotcw + wttcw
     C                   if        wttcw > *zeros
     C                   eval      wocw# = wocw# + 1
     C                   endif
     C                   enddo
     C                   eval      *in85 = *off
     C                   endif

     C                   endsr

      *----------------------------------------------------------------
      *
      *  ZZUSUB   Update using subfile records.

     C     zzusub        begsr
     C                   eval      error = *off
     C                   if        reccnt > *zeros

      *   Loop through changed subfile records and add/update file.

     C                   eval       uciwhs = $pwhse
     C                   eval       ucilcn = $plcns

     C                   eval      *in77 = *off
     C                   dou       *in77 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAc                   readc     d16ail1                                77
510dAc                   when      #lline = '08'
510dAc                   readc     d16ail1                                77
510bAc                   other
     C                   readc     detail1                                77
510bAc                   endsl
     C                   if        *in77 = *on
     C                   leave
     C                   endif
510cAC                   if        *in77 = *off and w1cwgt = *zeros
510cAC                   iter
510cAC                   endif

      *     Get detail record.

     C                   eval      ucisq2 = w1seq
510iAC                   eval      ucisqo = *zeros
510iAC                   eval      ucilbl = *zeros
510iAC                   eval      ucival = *blanks
     C     uciky1        chain     record1                            7978

      *     Record locked. Tell user to try again.

     C                   if        *in78 = *ON
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAc                   update    d16ail1
510dAc                   when      #lline = '08'
510dAc                   update    d16ail1
510bAc                   other
     C                   update    detail1
510bAc                   endsl
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif

      *     Initialize record fields before trying to add or update.

      *    This conversion is being done to move the implied decimal(2)
      *    for update back to the file.
     C                   eval       uciwgt = w1cwgt / 100

     C                   eval       ucinbr = w1uci2
     C                   eval       uciitm = $pitem
     C                   eval       ucilot = $plotc
     C                   eval       uciinb = $ppo
     C                   eval       uciout = *blanks
     C                   eval       ucirdt = $prcvd
     C                   time                    ucirtm
     C                   eval       uciedt = $pexpd
     C                   eval       uciqty = 1
510cD ***                eval       ucipck = *blanks
510cMC                   eval       ucipck = 'N'
510cD ***                eval       ucirts = *blanks
510cMC                   eval       ucirts = 'N'
     C                   eval       ucirde = *zeros
     C                   eval       ucirti = *zeros
     C                   eval       ucircd = *blanks
510cD ***                eval       ucists = 'N'
510cMC                   eval       ucists = 'Y'
510cD ***                eval       ucirct = *zeros
510cMC                   eval       ucirct = $portrn
     C                   eval       ucipkt = *zeros
     C                   eval       ucirtt = *zeros
     C                   eval       uciped = *zeros
     C                   eval       ucipet = *zeros
     C                   eval       ucired = *zeros
     C                   eval       uciret = *zeros
510eAC                   eval       ucisqi = $pseq

      *     Record not found. Try adding record.

     C                   if        *in79 = *on
     C                   write     record1                              76
     C                   if        *in76 = *off
510aAc                   eval      ultflg = 'ADD   '
510aAc                   exsr      writeucilog
     C                   iter
     C                   endif

     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAc                   update    d16ail1
510dAc                   when      #lline = '08'
510dAc                   update    d16ail1
510bAc                   other
     C                   update    detail1
510bAc                   endsl
     C                   eval      errmsg = desc(4)
     C                   exsr      ZM7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif

      *     Record found. Try updating record.

     C                   if        *in79 = *off
     C                   if        w1cwgt = *zeros
     C                   delete    record1
510aAc                   eval      ultflg = 'DELETE'
510aAc                   exsr      writeucilog
     C                   else

     C                   update    record1                              76
     C                   if        *in76 = *on
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
510dAc                   select
510bAc                   when      #lline = '16'
510bAc                   update    d16ail1
510dAc                   when      #lline = '08'
510dAc                   update    d16ail1
510bAc                   other
     C                   update    detail1
510bAc                   endsl
     C                   eval      errmsg = desc(4)
     C                   exsr      ZM7872
     C                   exsr      sfldsp
     C                   leave
510aAc                   else
510aAc                   eval      ultflg = 'UPDATE'
510aAc                   exsr      writeucilog
     C                   endif
     C                   endif
     C                   endif

     C                   enddo
     C                   endif
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZUPD3   Update record.

     C     zzupd3        begsr
     C                   eval      error = *off

      *  If user is adding a detail record ...
      *    - add it to subfile and return to entry screen
      *    - do not update files

     C                   if        w1addw <> *Zeros
     C                   eval      lstseq = lstseq + 1
     C                   eval      w1seq = lstseq
     C                   eval      w1uci2 = w1uci
     C                   eval      w1cwgt = w1addw
     C                   eval      *in85 = *on
     C                   exsr      sfladd
     C                   exsr      zztotl
     C                   eval      w1addw = *zeros
     C                   eval      w1wgt = *blanks
     C                   eval      w1uci = *blanks
      ***                eval      *in17 = *on
     C                   eval      redspl = *on
     C                   eval      ovrrid = *on
     C                   goto      endup3
     C                   endif

      *  Update detail first.

     C                   exsr      zztotl
     C                   if        reccnt >= *zeros
     C                   exsr      zzchkt
     C     error         cabeq     *on           endup3
     C                   exsr      zzusub
     C     error         cabeq     *on           endup3
     C                   endif

      * Load values to pass back.

      *    Total catchweight entered.
     C                   z-add     wotcw         $pcwtt
      *    Total number of catchweights entered.
     C                   z-add     wocw#         $pcwte
      *    Compute average catchweight entered.
     C                   if        wocw# > *zeros
     C                   eval      $pcwta = wotcw / wocw#
     C                   else
     C                   eval      $pcwta = *zeros
     C                   endif
      *
     CSR   endup3        endsr
     C*
     O*----------------------------------------------------------------*********
510aA *
510aA *  Write UCILOG record.
510aA
510aAC     writeucilog   begsr
510aA
510aAc                   eval      ulwhse = $pwhse
510aAc                   eval      ulinbr = ucinbr
510aAc                   eval      uliitm = uciitm
510aAc                   eval      ulcpgm = @caller
510aAc                   eval      ulcwgt = uciwgt
510aAc                   eval      uladte = ucirdt
510aAc                   eval      ulatim = ucirtm
510aAc                   eval      uluser = #user
510aAC                   eval      uljob  = #job
510aAc                   eval      uljnbr = #jobn
510aAc                   eval      ultype = *blank
510aAc                   eval      ulptyp = *blank
510aAc                   eval      ulupgm = 'CW132'
510aAc                   eval      ulpo = $ppo
510aAc                   eval      ulseq# = *zeros
510aAc                   eval      ulptrn = *zeros
510aAc                   eval      ullcn# = ucilcn
510aAc                   eval      ulord  = *zeros
510aAc                   eval      uloseq = *zeros
510aAc                   eval      ulstrn = *zeros
510aAc                   eval      ullbl# = *zeros
510aAc                   eval      ulcode = *blanks
510aA
510aAc                   write     ulrec
510aA
510aAC                   endsr
      *----------------------------------------------------------------
     O*
     O*  COMPILE TIME TABLES
     O*
**
Catch weight
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
UCI Number
Duplicate uci numbers found
10 digits required for UCI#
UCI count don't match Qty                          12
