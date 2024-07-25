530 D**COPY *libl/qcopysrc,hspecs
530 M /copy qcopysrc,hspecstrnc
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER370     Task report for an employee
     *  March 24, 2000
     *  Hemant Kapadia
     *
     *  03/24/00  HNK  4.13
     *    Created
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *  09/18/09   GJA  5.30
     *     -Convert to RPGLE, cleaned up and revamped for suspended
     *      transactions.
     *
530 A*    11/17/09  MLB  5.30
     *      - Fix: Changed hspec /copy mbr to hspectrnc which has
     *        option truncate(*Yes) instead of std /copy w/ *NO.
     *        Truncate *NO was causing MCH1210 Receiver value too
     *        small to hold result errors.
     *
530aA*    02/05/10  GJA  5.30a
     *      - Fix: Option screen was allowing the employee number
     *        to be left blank.
530b *    01/22/10  GJA  5.30b
     *      - Enh: Add client code
     *
640a *    11/16/11  GJA  6.40a
     *      - Enh: Crew selection
     *
640b *    05/16/12  GJA  6.40b
     *      - Fix: Force entry of crew or employee
700a *    11/25/15  RH   7.00a
     *      - Fix: Move selected crew from F4 into screen field
     *----------------------------------------------------------------
     *  Custom Client Revisions:   Springfield
     *
SGCa *  01/22/10   GJA  SGCa
     *      - Enh: Default merge to "Y", default days to selection
     *             date range.
     *----------------------------------------------------------------
     *  Notes
     *       The format for this program needs to be compiled with
     *       DFRWRT=*NO so that status messages can be displayed.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 31   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer370fm   cf   e             workstn
     F                                     infds(infds)
     Fpiruser1  if   e           k disk
     Foptione   if   e           k disk
530bA*----------------------------------------------------------------
530bA*  Customer id
530bA*----------------------------------------------------------------
530bA
530bA /copy qcopysrc,id#sgc
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
640bDD*desc            s             60    dim(9) ctdata perrcd(1)
640bMD desc            s             60    dim(10) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
530bAD @client         c                   const('GETCLIENT')
     D @cvtdt          c                   const('CVTDTE')
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
     D                 ds
     D  t#date                 1      6
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
     *----------------------------------------------------------------
     *  Program parameters
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
     D  $ltask                19     24
     *
     D  $lwhse                19     21  0
     D  $lcrew                22     27
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      4p 0
     D  erday                  5     14
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
     D                 ds
     D  wrkhh                  1      2  0
     D  wrkmm                  3      4  0
     D  wrkss                  5      6  0
     D  wrktim                 1      6  0
     *----------------------------------------------------------------
     *  *USER   -  User Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N)
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Voice Module? (Y/N)
     *    OPZORD  -  Zone or Department. (Z/D)
     *    OPTBD   -  Tote/Box/Drop? (Y/N)
     *
     * Data structure
     *
     *----------------------------------------------------------------
     D opdta           ds
     D  OPMAN                  1      1
     D  OPNXTE                 2      6  0
     D  OPVYN                  7      7
     D  OPZORD                 8      8
     D  OPTBD                  9      9
     *----------------------------------------------------------------
     *  Variables
     *
     D KYwhse          s              3  0
     D opcode          s              8
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D begjul          s              5  0
     D cmdtkn          s              1
     D dayolp          s              4
     D dtfrmt          s              1  0
     D e               s              2  0
     D endgrg          s              6
     D endjul          s              5  0
     D error           s              1
     D forevr          s              1
     D fromdt          s              8  0
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D gtdate          s              8  0
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D shift           s              6
     D todt            s              8  0
     D usname          s             40
SGCaAD w@date          s               d
     D warn            s              1
     D whdp            s              5
     D work1a          s              1
     D work2           s              2
     D work4           s              4
     D wenddte         s             10a
     D enddte          s               d   datfmt(*ISO)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PENDT  End date (YYYYMMDD) - Calculated (To date + 1)
     *      $PWHSE  Warehouse code
     *      $PEMP#  Employee number
     *      $PDETL  Detail report (Y,N)
     *      $PJOBQ  Put on jobq (Y,N)
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *      $PMRG   Include merge pieces (Y,N)
     *      $PVYN   Voice (Y,N)
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pdetl            1
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $ptodt            8
     C                   parm                    $pcrew            6
     C                   parm                    $pdmin            3
     C                   parm                    $pmrg             1
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
     C                   parm                    $pvyn             1
     C                   parm                    $pzndp            1
     C                   parm                    $ptbd             1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zmcpmq
     C                   exsr      zzinz2
     C                   if        error = *on
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
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *   Set ON alarm indicator if error occured
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *   Overlay screen with error messages
     C                   exsr      zmdmsg
     *  Overlay screen with screen to be processed.
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *   Initialize error indicators and fields
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
     C                   setoff                                       30
     C                   setoff                                       31
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *   Initialize error subfile
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
     *  Get existing record.
     C                   exsr      zzfil1
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
     *  Test for F3 - Exit
     C                   if        *inkc
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *  Test for F5 - Refresh
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *  Test for F12 - Previous
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *  Test for other command keys
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *  Some other key pressed.
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     *  Put out info message.
     C                   exsr      zm2102
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zznxt1
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
     C                   eval      gtdate = 0
     C                   eval      usname = *blanks
     C                   eval      forevr = *blanks
     *
530bA
530bA*  Get client id.
530bA
530bAC                   call      @client
530bAC                   parm                    client           10
530bAC                   parm                    clientloc        10
530bA
     *  Initialize message handling
     *
     *   Call user added initialization routine.
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *
     *    PIR9901  From date greater than To date.
     *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
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
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0110  Number must be >0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      PIR0204
     *
417 AC     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
417 AC                   endsr
     *----------------------------------------------------------------
     *    ER27002  Records are being selected. (Info message)
     *
     C     zm2102        begsr
     C                   eval      #msgid = 'ER21002'
     C                   eval      #msgtp = '*INFO  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     C     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
     * MAKE SUNDAY = 1ST DAY OF THE WEEK
     C                   if        g$dw <= 3
     C                   add       4             g$dw
     C                   else
     C                   eval      g$dw = g$dw - 3
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  JTOG$    Julian to Gregorian date conversion
     *
     C     jtog$         begsr
     C     j$jd          div       365.25        j$yywk
     C     j$jd          div       365.25        j$tst
     C                   if        j$tst = 0
     C                   eval      j$yywk = j$yywk - 1
     C                   endif
     C                   eval      j$yd = j$yywk * 365.25
     C                   eval      j$yd = j$jd - j$yd
     C                   if        j$yd > 306
     C                   add       1             j$yywk
     C                   endif
     C                   eval      j$x = 0
     C                   dou       j$yd <= j$md
     C                   add       1             j$x
     C     j$x           mult(h)   30.6          j$md
     C                   enddo
     C                   eval      j$x = j$x - 1
     C     j$x           mult(h)   30.6          j$md
     C     j$yd          sub       j$md          j$dd
     C     j$x           add       3             j$mm
     C                   if        j$mm > 12
     C                   eval      j$mm = j$mm - 12
     C                   endif
     C     j$yywk        add       1900          j$yyyy
     C                   if        dtfrmt = 1
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   movel     work2         j$date
     C                   move      work4         j$date
     C                   else
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   move      work2         j$date
     C                   movel     work4         j$date
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify From Date.
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $cvmsg
    D*                    EXSR ZMQMSG
     C                   else
     C                   eval      w1fmdt = $cvd6o
     C                   endif
     *
     *  Verify To Date.
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
    D*                    EXSR ZMQMSG
     C                   else
     C                   eval      w1todt = $cvd6o
     C                   endif
     *
     *  Verify From date <= To date
     *
     C                   if        not *in21  and
     C                             not *in22
     *
     C                   if        w1fmdt = 0
     C                   eval      $pfmdt = *blanks
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $pfmdt
     C                   endif
     *
     C                   if        w1todt = 0
     C                   eval      $pendt = *blanks
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $pendt
     C                   endif
     *
     C                   if        w1fmdt <> 0  and
     C                             w1todt <> 0  and
     C                             $pfmdt > $pendt
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm9901
     C                   endif
     *
     C                   endif
520aA*
     *  Verify From Time.
     *
     C                   eval      wrktim = w1fmtm
     C                   if        w1fmtm < 0  or
     C                             w1fmtm > 2359  or
     C                             wrkhh > 23  or
     C                             wrkmm > 59
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel(p)  desc(7)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify To Time.
     *
     C                   eval      wrktim = w1totm
     C                   if        w1totm < 0  or
     C                             w1totm > 2359  or
     C                             wrkhh > 23  or
     C                             wrkmm > 59
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   movel(p)  desc(8)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify from/to time against dates entered.
     *
     C                   if        w1fmdt = w1todt  and
     C                             w1totm < w1fmtm
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel(p)  desc(9)       errmsg
     C                   exsr      zm0105
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
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
    D*                    EXSR ZMQMSG
     C                   endif
     C                   endif
640b *
640b *  Must enter either employee# or crew code
640b *
640bAC                   IF        w1emp# = 0  and
640bAC                             W1CREW = *BLANKS
640bAC                   MOVE      *ON           ERROR
640bAC                   MOVE      *ON           *IN24
640bAC                   MOVE      *ON           *IN29
640bAC                   MOVE      *ON           *IN04
640bAC                   movel(p)  desc(10)      errmsg
640bAC                   exsr      zm0105
640bAC                   GOTO      ENDCK1
640bAC                   endif
640a *
640a *  Verify Crew code.
640a *
640aAC                   if        w1crew <> *blanks
640aAC                   move      '*VERIFY '    $LCMD
640aAC                   Z-ADD     W1WHSE        $LWHSE
640aAC                   MOVE      W1CREW        $LCREW
640aAC                   CALL      'CR900'
640aAC                   PARM                    $LPARM
640aAC                   IF        $LRTN = '*ERROR  '
640aAC                   MOVE      *ON           ERROR
640aAC                   MOVE      *ON           *IN29
640aAC                   MOVE      *ON           *IN09
640aAC                   MOVEL     $LERM         ERRMSG
640aAC                   EXSR      ZM0105
640aAC                   ELSE
640aAC                   if        $lrtn = '*PGMQ   '
640aAC                   MOVE      *ON           ERROR
640aAC                   MOVE      *ON           *IN29
640aAC                   MOVE      *ON           *IN09
640aAC                   MOVE      $LMSG         #MSGK
640aAC                   endif
640aAC                   endif
640aAC                   endif
640a *
640a *  Cannot enter both employee# and crew code
640a *
640aAC                   IF        w1emp# > 0  and
640aAC                             W1CREW > *BLANKS
640aAC                   MOVE      *ON           ERROR
640aAC                   MOVE      *ON           *IN24
640aAC                   MOVE      *ON           *IN29
640aAC                   MOVE      *ON           *IN04
640aAC                   MOVE      *BLANKS       ERRMSG
640aAC                   EXSR      ZM0204
640aAC                   GOTO      ENDCK1
640aAC                   endif
     *
     *  Verify Employee Number
     *
417 AC                   if        w1emp# > 0
     C     w1emp#        chain     piruser1                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
640aAC                   goto      endck1
530aAC                   endif
417 AC                   endif
510aA*  Verify include merge pieces option
     *
510aAC                   if        w1mrg <> 'Y'  and
510aAC                             w1mrg <> 'N'
510aAC                   eval      error = *on
510aAC                   eval      *in31 = *on
510aAC                   eval      *in11 = *on
510aAC                   eval      errmsg = *blanks
510aAC                   movel     desc(6)       errmsg
510aAC                   exsr      zm1001
510aAC                   endif
     *
     *  Verify detail report option
     *
     C*                  if        w1detl <> 'Y'  and
     C*                            w1detl <> 'N'
     C*                  eval      error = *on
     C*                  eval      *in25 = *on
     C*                  eval      *in05 = *on
     C*                  eval      errmsg = *blanks
     C*                  movel     desc(5)       errmsg
     C*                  exsr      zm1001
     C*                  endif
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
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
     *     Warehouse code.
     *
     C                   when      row# = 9
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
417 A*     Crew code.
417 A*
417 AC                   when      row# = 12
417 AC                   eval      *in04 = *on
417 AC                   eval      $lcmd = '*LOOKUP '
417 AC                   eval      $lwhse = w1whse
417 AC                   call      'CR900'
417 AC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
700aAC                   eval      w1crew = $lcrew
700aAC                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
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
     C                   eval      w1fmdt = *zeros
     C                   eval      w1todt = *zeros
     C                   eval      w1emp# = 0
     C                   eval      w1crew = *blanks
SGCaAC                   if        client = sgc
SGCaAC                   eval      w1mrg = 'Y'
SGCaAC                   eval      *in04 = *on
SGCaAC                   else
510aAC                   eval      w1mrg = 'N'
SGCaAC                   endif
     C*                  eval      w1detl = 'Y'
     C                   eval      w1jobq = 'N'
     *   Get Report Title
     C                   call      'GETRPTE'
     C                   parm      '*DESC  '     $cmd              8
     C                   parm      'ER371PR'     $lrpt            10
     C                   parm      0             $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      rptttl = $desc
     *
     *   Center report title.
     *
     C                   movel     rptttl        $pstr
     C                   eval      $plen = 50
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *   Get Device and Form
     C                   call      'GETRPTE'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'ER371PR'     $lrpt
     C                   parm      0             $whse
     C                   parm      ' '           $styp
     C                   parm      ' '           $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   eval      w1dev = $dev
     C                   eval      w1form = $form
     *
SGCaAC                   if        client = sgc
SGCaAC                   eval      $cvcmd = '*CURMDY '
SGCaAC                   call      @cvtdt
SGCaAC                   parm                    $cvtdt
SGCaAC     *MDY          move      $cvd6o        w@date
SGCaAC                   eval      w@date -= %Days(1)
SGCaAC     *MDY          move      w@date        w1fmdt
SGCaAC                   move      $cvd6o        w1todt
SGCaAC                   else
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1fmdt
     C                   move      $cvd6o        w1todt
SGCaAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
510 A*
510 A* Shift file key
640aA*
640aAC     crkey         klist
640aAC                   kfld                    w1whse
640aAC                   kfld                    w1crew
510 A*
510 A* Shift file key
510 A*
510 AC     shkey         klist
510 AC                   kfld                    w1whse
510 AC                   kfld                    whdp
510 AC                   kfld                    shift
     *  Define key for OPTIONS file.
     C     keyop         klist
     C                   kfld                    opcode
     C                   kfld                    KYwhse
510 A*
    AC                   eval      #pgmq = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
520aAC                   exsr      zzvoic
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        fromdt
     C                   move      $cvd8o        $pfmdt
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        todt
415 MC                   move      $cvd8o        $ptodt
415 MC                   move      $ptodt        $pendt
     *
     C                   move      w1whse        $pwhse
     C                   move      w1emp#        $pemp#
     C                   move      w1crew        $pcrew
     C                   move      '000000'      $pfmtm
     C                   move      '000000'      $ptotm
     C                   movel     w1fmtm        $pfmtm
     C                   movel     w1totm        $ptotm
     **                   MOVE $CVD8O    $PTODT
510 A*
510 AC                   select
510 AC                   when      w1crew <> *blanks
510 AC                   eval      $pcrew = w1crew
510 AC                   when      uscrew <> *blanks
510 AC                   eval      $pcrew = uscrew
510 AC                   endsl
510 A*
510 AC                   if        w1fmtm = 0 and w1totm = 0
510 AC                   call      'GETSHFT'
510 AC                   parm      w1whse        $pwhs2            3 0
510 AC                   parm                    $pcrew
510 AC                   parm                    $pdesc           30
510 AC                   parm                    $pshft            6
510 AC                   parm                    $pshtd           30
     *
510 AC                   parm                    $pstim            6 0
510 AC                   parm                    $petim            6 0
510 AC                   parm                    $prtn
     C                   move      $pstim        $pfmtm
     C                   move      $petim        $ptotm
510 AC                   if        $prtn = '*OK     '
510 A*    Time criteria overlaps two days. Use overlap selection.
510 AC                   if        $petim < $pstim  and
510 AC                             $petim > *zeros  and
510 AC                             $pfmdt = $pendt
     C                   eval      wenddte=%subst($pendt:1:4) + '-' +
     C                             %subst($pendt:5:2) + '-' +
     C                             %subst($pendt:7:2)
     C                   move      wenddte       enddte
     C                   adddur    1:*D          enddte
     C                   move      enddte        wenddte
     C                   eval      $pendt=%subst(wenddte:1:4) +
     C                             %subst(wenddte:6:2) +
     C                             %subst(wenddte:9:2)
     C                   move      $pendt        $ptodt
510 AC                   endif
510 AC                   endif
510 AC                   endif
     *
     C                   move      w1whse        $pwhse
417 AC                   if        w1emp# <> 0
     C                   move      w1emp#        $pemp#
417 AC                   else
417 AC                   eval      $pemp# = *blanks
417 AC                   endif
417 AC                   if        w1crew <> *blanks
     C                   move      w1crew        $pcrew
417 AC                   else
417 AC                   eval      $pcrew = *blanks
417 AC                   endif
417 AC*                  move      w1dmin        $pdmin
     C*                  eval      $pdetl = w1detl
     C                   eval      $pjobq = w1jobq
     C                   eval      $pdev = w1dev
     C                   eval      $pform = w1form
     C                   eval      $prtn = '*OK     '
510aAC                   move      w1mrg         $pmrg
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZVOIC  Find out if client is using voice
520aA*
520aAC     zzvoic        begsr
520aA*
     C                   Z-ADD     0             KYwhse
520aAC                   eval      opcode = '*USER   '
520aAC     keyop         chain     optione                            77
520aAC                   if        not *in77
520aAC                   eval      opdta = opedta
520aAC                   eval      $pvyn = opvyn
520aAC                   eval      $pzndp= opzord
520aAC                   eval      $ptbd = optbd
520aAC                   else
520aAC                   eval      opdta = *blanks
520aAC                   eval      $pvyn = 'N'
520aAC                   eval      $pzndp= 'N'
520aAC                   eval      $ptbd = 'N'
520aAC                   endif
520aA*
520aAC                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Job queue option
Printer device
Form type
Employee number
Detail report
Include merge pieces
From time invalid.
To time invalid.
End time less than start time.
Must enter emply or crew.
