     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
      *
      *  CW133     UCI Inventory Maintenance
      *  20 September 2006
      *  Randy Haselhorst
      *  Created using CW132
      *
      *----------------------------------------------------------------
      *  Revisions
      *
510 A *    09/20/06  RAH  5.10
      *      - Created.
      *
510aA *    10/06/06  JCJ  5.10a
      *      Enh: Allow UCI code to be added if a weight is entered and
      *           F20 is pressed.
      *
510bA *    10/17/06  JCJ  5.10b
      *      Enh: Added file orrtnm processing.
      *
510cA *    10/31/06  JCJ  5.10c
      *      Enh: Added processing to calculate total uci weight.
      *
510dA *    11/28/06  JCJ  5.10d
      *      Fix: Revised routine ZZCHK3 for uci unique edit to UCIADJ
      *
510eA *    12/06/06  JCJ  5.10e
      *      Fix: do not issue uciadj already exists error is uci
      *           is a negative adjustment.  output weight to uciadj
      *           file.
      *
510fA *    12/18/07  JCJ  5.10f
      *      Fix: used %ABS if uciadj is negative for uci entry loop.
      *      Enh: changed program to not allow a negative adjustmnet
      *           if the uci is flagged as not in stock.
      *
510gA *    02/16/07  JCJ  5.10g
      *      Enh: removed file orrtnm processing.
      *
510HA *    02/20/07  JCJ  5.10h
      *      Enh: recompiled for changed weight fields from 5,2 to 7,2
      *
510IA *    03/14/07  HNK  5.10I
      *      Enh: INITIALIZE SOME FIELDS FOR ADJUSTMENTS.
      *
510jA *    03/15/07  jcj  5.10j
      *      Fix: Initialize UCIPCK to 'N'.
      *
510kA *    09/20/07  HNK  5.10k
      *      Fix: Update some fields for Returns.
      *           Add new error msg - UCI - Delevery # mismatch
      *
      *  ***** UCi-Delivery # mismatch temporarily disabled *****
      *  ***** Must put this back after they have cleaned up UCI file**
      *
510l  *    10/23/07  HNK  5.10l
      *      Fix: Do not allow F12 if all UCI's are not entered.
510m  *    10/29/07  HNK  5.10m
      *      Fix: Move 510i change to proper place in logic.
      *
510n  *    12/06/07  JCJ  5.10n
      *      Fix: Reactivate Delivery # edit.
      *
      **************************************************************
      **************************************************************
      *
510l  *           Allow F12 for Adjustments.. per Ernesto.  This
510l  *           temp change to removed when live with SAP.
510l  *           Ernesto to remind BFC.
      *
700aA*    08/30/16  LMC  700a
     *      - Enh: UCILOG file was renamed to PUCILOG, so we could
     *             reuse UCILOG for our uci tracking.
      **************************************************************
      **************************************************************
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  01 - 20   Field position to
      *  21 - 40   Field input error (reverse display)
      *  81        Display subfile records (SFLDSP)
      *  82        Display subfile screen**SFLDSPCTL)
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

     FCW133FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DETAIL1:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     Fucicw     uf a e           k disk    rename(ucirec:record)
510dD *uciadj    o  a e           k disk
510dMFuciadj    if a e           k disk
700aDF*ucilog    o  a e           k disk
700aMFpucilog   o  a e           k disk
     Foptions   if   e           k disk
      *----------------------------------------------------------------
      *  Table and array definitions

     D A10             s              1    DIM(10)
     D uci             s             10    dim(500)
510dD *desc            s             50    DIM(12) CTDATA PERRCD(1)
510k D*desc            s             50    DIM(14) CTDATA PERRCD(1)
510l D*desc            s             50    DIM(15) CTDATA PERRCD(1)
510l D desc            s             50    DIM(16) CTDATA PERRCD(1)
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

     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $pcode                37     38
     D  $ptype                39     39
     D  $pqty1                40     44  0
     D  $pqty2                45     47  0
     D  $pqty3                48     50  0
     D  $pcwgt                51     59  2
     D  $pdate                60     64p 0
     D  $ptime                65     68p 0
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
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
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
     D $cbv1           S             11  3
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
     D count           S              4  0
     D posrec          S              4  0
     D msgk            S              4  0
     D l               s              3  0
     D $cbcod          S              3  0
     D $cbpos          S              3  0
     D e               S              2  0
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
     D @Caller         S             10
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
     C                   parm                    $batch            7 0
     C                   parm                    $delvry           9
     C                   parm                    $bildoc          10
510bAC                   parm                    $dcode            5

     C     UI866P        Plist
     C                   Parm                    @Caller
     C                   Parm                    @Counter

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
     c                   eval      *inlr = *on
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
     C                   read      head1                                  50
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
     C                   eval      error = *off

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

      *  Get field defaults

     C                   exsr      zzdft3

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
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif

      *  Test for F12 - Previous

     C                   if        *inkl = *on
     C*  Remove $ptype='R' condition when live with SAP.
510l C                   if        $ptype='R' and count<%ABS(wopqty)
510l C                   eval      error = *on
510l C                   eval      *in16 = *on
510l C                   eval      *in36 = *on
510l C                   movea     desc(16)      errmsg
510l C                   movea     errmsg        $md(1)
510l C                   exsr      zm9999
510l C                   goto      endsc3
510l C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
510l C                   endif
     C*
     C                   endif

      *  Test for F20 override

     C                   if        *inku = *on
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif

      *  Some other key pressed.

      *     Check input and write/update record.

     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3

      *  If they've entered all UCI's, update and get out of program.

510fD ***                if        count >= wopqty
510fMc                   if        count >= %ABS(wopqty)
     C                   exsr      zzusub
     C                   eval      nxtscr = 'EOJ'
     c                   endif

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
     C*  Convert today's date into century format.
     C*
     c                   move      '*CURCMD '    $cvcmd
     c                   call      @cvtdt
     c                   parm                    $cvtdt

      * Determine Calling program

     C                   Eval      @Counter = 4
     C                   Eval      @Caller  = *Blanks

     C                   Call      'UI866'       UI866P

     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLADD   Add record to subfile

     C     sfladd        begsr
     C                   eval      reccnt = reccnt + 1
     C                   eval      recno = reccnt
     C                   eval      count = count + 1
     C                   eval      *in85 = *on
     C                   write     detail1

     * Save UCI Numbers entered so user doesn't scan same number twice.
     C                   eval      l = 1
     C                   eval      blkuci = *blanks
     C     blkuci        lookup    uci(l)                                 80
     C                   if        *in80
     C                   eval      uci(l) = w1uci
     C                   endif
     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLCLR   Clear display subfile

     C     sflclr        begsr

      *  clear display subfile

     C                   eval      recno = *zeros
     C                   eval      reccnt = *zeros
     C                   eval      count = *zeros
     C                   eval      posrec = 1

     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off

     C                   endsr
      *----------------------------------------------------------------
      *
      *  SFLDSP   Display subfile
      *
     C     sfldsp        begsr

      *  write option and command lines to display

     C                   write     cmdrec

      *  write position to field to display

      *  write subfile to display

     C                   if        reccnt > *zeros
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = reccnt
     C                   write     head1
     C                   endsr
      *---------------------------------------------------------------
      *
      *  SUBROUTINE ZMxxxx  Control message display subfile
      *
      *    ZMCMSG  Clear message record subfile

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
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
     C                   write     msgctl
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
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks
     C                   endsr

      *---------------------------------------------------------------
      *
      *    ZMQMSG  Add message record to subfile from program queue

     C     zmqmsg        begsr
     C                   eval      msgk = msgk + 1
     C                   write     msgrec
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
      *   PIR7979  UCI Number doesn't exist.

     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *   PIR9905  Cursor not in correct position for lookup.

     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR9999  Generic error for message from array.

     C     zm9999        begsr
     C                   eval      #msgid = 'PIR9999'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmpmsg
     C                   endsr
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

     * Enter pressed, no UCI entered.

     C                   if        w1uci = *blanks
     c                   eval      w1wgt = *zero
     C                   eval      error = *on
     C                   eval      *in16 = *on
     C                   eval      *in36 = *on
     C                   movea     desc(12)      errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zm9999
     C                   goto      endck3
     c                   endif

     * UCI number must be unique.

     C     ucikey        chain     ucicw                              79
     C                   if        *in79 = *on

     c                   if        ovrrid <> *on
     C                   eval      error = *on
     C                   eval      *in16 = *on
     C                   eval      *in36 = *on
     C                   exsr      zm7979
     c                   eval      *in91 = *on
     C                   goto      endck3
     c                   endif

     c                   else

510k c                   if        uciout <> $delvry
510nMC                   eval      error = *on
510nMC                   eval      *in16 = *on
510nMC                   eval      *in36 = *on
510nMC                   movea     desc(15)      errmsg
510nMC                   exsr      zm0105
510nMC                   goto      endck3
510k c                   endif

510eAc                   if        $pcmd = '*DLTADJ' and
510eAc                             ucists = 'N'
     C                   eval      error = *on
     C                   eval      *in16 = *on
     C                   eval      *in36 = *on
     C                   movea     desc(14)      errmsg
     C                   exsr      zm0105
     C                   goto      endck3
     c                   endif

     c                   if        w1wgt = *zero
     c                   eval      w1wgt = uciwgt
     c                   endif

     c                   if        uciitm <> $pitem and
     c                             uciitm <> *blanks
     c                   eval      w1wgt = *zeros
     C                   eval      error = *on
     C                   eval      *in16 = *on
     C                   eval      *in36 = *on
     C                   movea     desc(11)      errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zm9999
     C                   goto      endck3
     c                   endif

     c                   endif

     c                   if        uciwgt = *zero and
     c                             w1wgt = *zero

     c                   eval      *in91 = *on
     C                   eval      error = *on
     C                   eval      *in17 = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erfld = desc(1)
     C                   eval      erfrom = '0'
     C                   eval      erto = '9999999'
     C                   exsr      zm0112
     C                   goto      endck3

     c                   else
     c                   eval      *in91 = *off
     C                   endif

510dA* UCI number must be unique to adjustment file

510eD ***                if        $pcmd = '*ADDADJ' or
510eD ***                          $pcmd = '*DLTADJ'
510eMc                   if        $pcmd = '*ADDADJ'
510dAc     ucikey        chain     uciadj
510dAc                   if        %found(uciadj)

510dAc                   if        ovrrid <> *on
510dAc                   eval      error = *on
510dAc                   eval      *in16 = *on
510dAc                   eval      *in36 = *on
510dAc                   eval      errmsg = desc(13)
510dAc                   exsr      zm0105
510dAc                   eval      *in91 = *on
510dAc                   goto      endck3
510dAc                   endif
510dAc                   endif
510dAc                   endif

     * Verify user hasn't scanned same uci# multiple times.

     C                   eval      l = 1
     C     w1uci         lookup    uci(l)                                 80
     C                   if        *in80
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   eval      errmsg = desc(10)
     C                   exsr      zm0105
     C                   goto      endck3
     C                   endif

     c                   exsr      zzupd3

      *   Verify changed subfile records.

     c                   eval      count = 0

     C                   if        reccnt > *zeros
     C                   eval      *in79 = *off
     C                   dou       *in79 = *on

     C                   readc     detail1                                79
     C                   if        *in79 = *on
     C                   leave
     C                   endif

     C                   eval      *in19 = *off
     C                   eval      *in20 = *off
     C                   eval      *in39 = *off
     C                   eval      *in40 = *off

      *      Verify right definition.

     c                   if        w1swgt = *zero
     C                   eval      *in85 = *off
     C                   update    detail1
     c                   iter
     c                   endif

     c                   eval      count = count + 1
     C                   eval      *in85 = *on
     C                   update    detail1

     c                   enddo
     c                   endif

     C     endck3        endsr
      *----------------------------------------------------------------
      *
      *  ZZDFT3   Get default values for add.

     C     zzdft3        begsr

     C                   exsr      sflclr

     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     ucikey        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1uci

      *  Define key for OPTIONS file.

     C     *like         define    opwhse        wkwhse
     C     *like         define    opcode        wkcode

     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode

     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

     C                   eval      $lprg = #prog

     C                   endsr
      *----------------------------------------------------------------
      *  ZZINZ2   Program initialization. Called from main line.

     C     zzinz2        begsr

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

      *    Compute total qty received.
     C                   eval      wopqty = $pqty1 + $pqty2 + $pqty3

      *   Select first screen to display.

     C                   exsr      scr03i

     C                   endsr
      *----------------------------------------------------------------
      *  ZZUSUB   Update using subfile records.

     C     zzusub        begsr

     C                   eval      error = *off
510cAc                   eval      $pcwgt = *zeros
     C                   if        reccnt > *zeros

      *   Loop through changed subfile records and add/update file.

     C                   eval       uciwhs = $pwhse

     C                   eval      *in77 = *off
     C                   dou       *in77 = *on
     C                   readc     detail1                                77
     C                   if        *in77 = *on
     C                   leave
     C                   endif

     c                   if        w1swgt = *zero
     c                   iter
510cAc                   eval      $pcwgt = $pcwgt + w1swgt
     c                   endif

      *     Get detail record.

     c                   eval      w1uci = w1suci
     C     ucikey        chain     record                             7978

      *     Record locked. Tell user to try again.

     C                   if        *in78 = *ON
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

      *     Initialize record fields before trying to add or update.

     C                   eval       ucinbr = w1suci
     C                   eval       uciwgt = w1swgt
     C                   eval       ucircd = $pcode
     c                   if         $pcmd = '*ADDADJ '
      * stock code flag
     c                   eval       ucists = 'Y'
     c                   eval       uciqty = 1
510i c**                 eval       uciinb = *blanks
510i c**                 eval       ucisqo = 0
     c                   else
      * stock code flag
     c                   eval       ucists = 'N'
     c                   eval       uciqty = 1
     c                   endif

      *  If record not found. Try adding record.

     C                   if        *in79 = *on
     C                   eval       uciitm = $pitem
     C                   eval       uciout = *blanks
     c                   eval       ucirdt = $pdate
     C                   eval       ucirtm = $ptime
     C                   eval       uciedt = $pexpd
510jD ***                eval       ucipck = *blanks
510jMC                   eval       ucipck = 'N'
     C                   eval       ucirts = *blanks
     C                   eval       ucilcn = *blanks
     C                   eval       ucirde = *zeros
     C                   eval       ucirti = *zeros
     C                   eval       ucirct = *zeros
     C                   eval       ucipkt = *zeros
     C                   eval       ucirtt = *zeros
     C                   eval       uciped = *zeros
     C                   eval       ucipet = *zeros
     C                   eval       ucired = *zeros
     C                   eval       uciret = *zeros
510i c                   eval       uciinb = *blanks
510i c                   eval       ucisqo = 0
     C                   write     record                               76
     c                   exsr      writeadj
     C                   if        *in76 = *off
     C                   iter
     C                   else


     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      ZM7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     C                   endif

      *     Record found. Try updating record.

510k C                   if        $ptype='R'
510k C                   eval      ucirts='Y'
510k C                   eval      ucipck  = 'N'
510k C                   eval      ucircd  = $pcode
510k C                   eval      ucirde  = $pdate
510k C                   eval      ucirti  = $ptime
510k C                   endif

     C                   update    record                               76
     c                   exsr      writeadj
     C                   if        *in76 = *on
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      ZM7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif

     C                   enddo
     C                   endif

     C                   endsr
      *----------------------------------------------------------------
      *
      *  WRITEADJ - Write UCIADJ record.

     C     writeadj      begsr

     c                   eval      uawhse = $pwhse
     c                   eval      uainbr = ucinbr
     c                   eval      uarscd = $pcode
     c                   eval      uaapgm = 'CW133'
     c                   eval      uatype = *blanks
     c                   eval      uaoitm = *blanks
     c                   eval      uanitm = $pitem
     c                   eval      uadate = $pdate
     c                   eval      uatime = $ptime
     c                   eval      uaedat = *zeros
     c                   eval      uaetim = *zeros
     c                   eval      uapbat = $batch
510bD ***                eval      uadelv = $delvry
510bD ***                eval      uabdoc = $bildoc

     c                   if        $pcmd = '*ADDADJ '
     c                   eval      uacode = 'A'
     c                   else
     c                   eval      uacode = 'D'
     c                   endif
     c                   if        h1swgt <> w1swgt
     c                   eval      uaowgt = h1swgt
     c                   eval      uanwgt = w1swgt
     c                   else
     c                   eval      uaowgt = *zeros
510eDc                   eval      uanwgt = *zeros
510eMc                   eval      uanwgt = h1swgt
     c                   endif

     c                   write     uacrec

      *  Write UCILOG record.

     c                   eval      ulwhse = $pwhse
     c                   eval      ulinbr = ucinbr
     c                   eval      uliitm = $pitem
     c                   eval      ulcpgm = @caller
     c                   eval      ulcwgt = w1swgt
     c                   eval      uladte = $pdate
     c                   eval      ulatim = $ptime
     c                   eval      uluser = #user
     C                   eval      uljob  = #job
     c                   eval      uljnbr = #jobn
     c                   eval      ultype = *blank
     c                   eval      ulptyp = *blank
     c                   eval      ulupgm = 'CW133'
     c                   eval      ulpo = *blanks
     c                   eval      ulseq# = *zeros
     c                   eval      ulptrn = *zeros
     c                   eval      ullcn# = *blanks
     c                   eval      ulord  = *zeros
     c                   eval      uloseq = *zeros
     c                   eval      ulstrn = *zeros
     c                   eval      ullbl# = *zeros
     c                   eval      ulcode = $pcode
     c                   eval      ultflg = *blank

     c                   write     ulrec

     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZUPD3   Update record.

     C     zzupd3        begsr
     C                   eval      error = *off

      *  If user is adding a detail record ...
      *    - add it to subfile and return to entry screen
      *    - do not update files

     C                   if        w1uci <> *blanks
     C                   eval      w1suci = w1uci
     C                   eval      w1swgt = w1wgt
     c                   eval      h1swgt = w1swgt
     C                   eval      *in85 = *on
     C                   exsr      sfladd
     C                   eval      w1swgt = *zero
     C                   eval      w1wgt = *zero
     C                   eval      w1uci = *blanks
     C                   eval      w1suci = *blanks
     C                   endif
      *
     CSR   endup3        endsr
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Catch weight                                       1
Start From                                         2
Starting Level                                     3
Detail record                                      4
Starting Number                                    5
Current Maximum Level                              6
Future Maximum Level                               7
Racks on One Side                                  8
UCI Number                                         9
Duplicate UCI numbers found                        10
UCI - Item mismatch                                11
Qty entered < tot qty                              12
UCI already adjusted                               13
UCI not in stock                                   14
UCI - Delivery# mismatch                           15
UCI count don't match Qty                          16
