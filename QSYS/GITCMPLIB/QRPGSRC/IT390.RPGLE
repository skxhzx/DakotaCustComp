     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT390     Expired items report - Options
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
     *
     *    07/31/96  RH   2.14
     *      - Change options, include previous expired items Y,N
     *      - Select items that will expire within entered days.
     *
219  *    03/14/97  RH   2.19
     *      - Correct error message for  view/print options.
414a *    08/28/00  RRH  4.14
     *      - Change options, add Department or *all.
415a *    03/26/01  RRH  4.15a
     *      - Change options, add From date, default to today.
     *
417  *    08/25/03  HNK  4.17
     *      - Add option to include Overflow slots, pick slots or both
     *        Add error table entry and change array DESC to 7
417a *    03/31/04  MLB  4.17a
     *      - Fix: Revised program to initialize $CVPRG with calling
     *        program id in ZZCHK1.
500a *    07/29/05  RH   5.00a
     *      - ENH: Add option to sort by date or slot (slot is new)
     *        Add error table entry and change array DESC to 8
     *
510a *  06/29/06  HNK  5.10a
     *    - Default to View.
     *
     *----------------------------------------------------------------
530aA*    11/01/10  RH   5.30a
     *      - Enh: Added client custom code support to program.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JORaA*    11/01/10  RH   JORa
     *      - Default print/view to print
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Glazier
GFCa *  10/29/10  GJA  GFCa
     *    - Enh:  Add Buyer as option
     *
GFCb *  10/29/10  GJA  GFCb
     *    - Enh:  Add "C" for custom
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
     *
FFCaA*    10/21/15  RH   FFCa
     *      - Default print/view to print
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
GFCbDF**it390fm   cf   e             workstn
GFCbMFit39001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
210 D*IRUSER IF  E           K        DISK
     Freports   if   e           k disk
     *----------------------------------------------------------------
530aA*  Client ID's
     *
JOR A /COPY QCOPYSRC,ID#JORDANO
FFC A /COPY QCOPYSRC,ID#FISCHER
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500aMD desc            s             60    dim(8) ctdata perrcd(1)
500aD*                   DESC    1   7 60
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @getcl          c                   const('GETCLIENT')
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
415aAD  erdate                 1      6  0
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D begjul          s              5  0
     D cmdtkn          s              1
     D dtfrmt          s              1  0
     D e               s              2  0
     D endgrg          s              6
     D endjul          s              5  0
     D error           s              1
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
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D today           s              8  0
     D todt            s              8  0
     D warn            s              1
     D wkprtf          s             10
     D wkwhse          s              3  0
     D work1a          s              1
     D work2           s              2
     D work4           s              4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $vp               1
     C                   parm                    $jobq             1
     C                   parm                    $dev             10
     C                   parm                    $form            10
214 AC                   parm                    $pexp             1
214 AC                   parm                    $nexp             8
214 AC                   parm                    $today            8
414aAC                   parm                    $whdp             5
417 AC                   parm                    $pick             1
500aAC                   parm                    $sort             1
GFCaAC                   parm                    $buyer            3
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
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
     *  Get existing record.
     *
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
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
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
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
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
     *
530aA*  Get Client ID
     *
530aAC                   call      @getcl
530aAC                   parm                    client           10
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
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
415a *----------------------------------------------------------------
415a *
415a *    PIR9906  Invalid date entered.
415a *
415a C     zm9906        begsr
415a C                   eval      #msgid = 'PIR9906'
415a C                   eval      #msgtp = '*DIAG  '
415a C                   movea     errmsg        $md(1)
415a C                   exsr      zmpmsg
415a C                   endsr
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
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
214 A*    IT39001  Exp within days must be > 0 when
214 A*             Include previous expired items is No.
214 A*
214 AC     zm3901        begsr
214 AC                   eval      #msgid = 'IT39001'
214 AC                   eval      #msgtp = '*DIAG  '
214 AC                   movea     errmsg        $md
214 AC                   exsr      zmpmsg
214 AC                   endsr
     *----------------------------------------------------------------
214 A*
214 AC     gtoj$         begsr
214 AC                   eval      g$date = g$date
214 A* SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
214 AC                   if        dtfrmt = 1                                   BLVL-01
214 AC                   movel     g$date        g$yy
214 AC                   move      g$date        work4
214 AC                   movel     work4         g$mm
214 AC                   move      work4         g$dd
214 AC                   else                                                   EELS-01
214 AC                   movel     g$date        g$mm
214 AC                   move      g$date        work4
214 AC                   movel     work4         g$dd
214 AC                   move      work4         g$yy
214 AC                   endif                                                  EEND-01
214 A* CREATE 4 DIGIT YEAR
214 AC                   move      g$yy          g$yyyy
214 AC                   if        g$yy >= 60                                   BLVL-01
214 AC                   movel     '19'          g$yyyy
214 AC                   else                                                   EELS-01
214 AC                   movel     '20'          g$yyyy
214 AC                   endif                                                  EEND-01
214 AC                   eval      g$jd = 0
214 AC                   eval      g$mmwk = g$mm - 3
214 AC                   eval      gmwksv = g$mmwk
214 AC                   if        g$mmwk < 0                                    LVL-01
214 AC                   add       12            g$mmwk
214 AC                   endif                                                   END-01
214 AC                   if        gmwksv <> 0                                   LVL-01
214 AC                   eval(h)   g$jd = g$mmwk * 30.6
214 AC                   endif                                                   END-01
214 AC                   add       g$dd          g$jd
214 AC     g$yyyy        sub       1900          g$yywk
214 AC                   if        g$yywk <> 0                                   LVL-01
214 AC                   if        gmwksv < 0                                    LVL-02
214 AC                   eval      g$yywk = g$yywk - 1
214 AC                   endif                                                   END-02
214 AC                   endif                                                   END-01
214 AC                   eval      g$jyd = g$yywk * 365.25
214 AC                   add       g$jyd         g$jd
214 AC     g$jd          div       7             g$wk7
214 AC                   mvr                     g$dw
214 A* MAKE SUNDAY = 1ST DAY OF THE WEEK
214 AC                   if        g$dw <= 3
214 AC                   add       4             g$dw
214 AC                   else
214 AC                   eval      g$dw = g$dw - 3
214 AC                   endif
214 AC                   endsr
214 A*----------------------------------------------------------------
214 A*
214 A*  JTOJ$    Julian to Julian date conversion
214 A*
214 AC     jtog$         begsr
214 AC     j$jd          div       365.25        j$yywk
214 AC     j$jd          div       365.25        j$tst
214 AC                   if        j$tst = 0                                     LVL-01
214 AC                   eval      j$yywk = j$yywk - 1
214 AC                   endif                                                   END-01
214 AC                   eval      j$yd = j$yywk * 365.25
214 AC                   eval      j$yd = j$jd - j$yd
214 AC                   if        j$yd > 306                                    LVL-01
214 AC                   add       1             j$yywk
214 AC                   endif                                                   END-01
214 AC                   eval      j$x = 0
214 AC                   dou       j$yd <= j$md                                  LVL-01
214 AC                   add       1             j$x
214 AC     j$x           mult(h)   30.6          j$md
214 AC                   enddo                                                   END-01
214 AC                   eval      j$x = j$x - 1
214 AC     j$x           mult(h)   30.6          j$md
214 AC     j$yd          sub       j$md          j$dd
214 AC     j$x           add       3             j$mm
214 AC                   if        j$mm > 12                                     LVL-01
214 AC                   eval      j$mm = j$mm - 12
214 AC                   endif                                                   END-01
214 AC     j$yywk        add       1900          j$yyyy
214 AC                   if        dtfrmt = 1                                   BLVL-01
214 AC                   move      j$yyyy        work2
214 AC                   movel     j$mm          work4
214 AC                   move      j$dd          work4
214 AC                   movel     work2         j$date
214 AC                   move      work4         j$date
214 AC                   else                                                   EELS-01
214 AC                   move      j$yyyy        work2
214 AC                   movel     j$mm          work4
214 AC                   move      j$dd          work4
214 AC                   move      work2         j$date
214 AC                   movel     work4         j$date
214 AC                   endif                                                  EEND-01
214 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
414a *  Verify warehouse department.
414a *
414a C                   if        w1whdp <> '*ALL '
414a C                   eval      $lcmd = '*VERIFY '
414a C                   eval      $lwhse = w1whse
414a C                   eval      $lwhdp = w1whdp
414a C                   call      'WD900'
414a C                   parm                    $lparm
414a C                   if        $lrtn = '*ERROR  '
414a C                   eval      error = *on
414a C                   eval      *in28 = *on
414a C                   eval      *in08 = *on
414a C                   movel     $lerm         errmsg
414a C                   exsr      zm0105
414a C                   else
414a C                   if        $lrtn = '*PGMQ   '
414a C                   eval      error = *on
414a C                   eval      *in28 = *on
414a C                   eval      *in08 = *on
414a C                   eval      #msgk = $lmsg
414a C                   exsr      zmqmsg
414a C                   endif
414a C                   endif
414a C                   endif
     *
214 A*
214 A*  Verify include prev. expired items option.
214 A*
214 AC                   if        w1pexp <> 'Y'  and
214 AC                             w1pexp <> 'N'
214 AC                   eval      error = *on
214 AC                   eval      *in22 = *on
214 AC                   eval      *in02 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   movel     desc(6)       errmsg
214 AC                   exsr      zm1001
214 AC                   endif
214 A*
214 A*  Can't exclude prev expire items and enter 0 expire within days
214 A*
214 AC                   if        w1pexp = 'N'  and
214 AC                             w1nexp = 0
214 AC                   eval      error = *on
214 AC                   eval      *in23 = *on
214 AC                   eval      *in03 = *on
214 AC                   eval      errmsg = *blanks
214 AC                   exsr      zm3901
214 AC                   endif
214 A*
415a *
415a *     Verify FROM date
415a *
415a C                   eval      $cvcmd = '*MDYEDT '
417aAC                   eval      $cvprg = #prog
415a C                   move      w1fmdt        $cvd6i
415a C                   call      @cvtdt
415a C                   parm                    $cvtdt
415a C                   if        $cvrtn = '*ERROR  '
415a C                   eval      error = *on
415a C                   eval      *in28 = *on
415a C                   eval      *in08 = *on
415a C                   movel     $cverm        errmsg
415a C                   exsr      zm0105
415a C                   else
415a C                   if        $cvrtn = '*PGMQ   '
415a C                   eval      error = *on
415a C                   eval      *in28 = *on
415a C                   eval      *in08 = *on
415a C                   eval      #msgk = $cvmsg
415a C                   eval      erdate = w1fmdt
415a C                   exsr      zm9906
415a C                   else
415a C                   eval      w1fmdt = $cvd6o
415a C                   endif
415a C                   endif
     *
     *
     *  Verify view/print.
     *
     C                   if        w1vp <> 'V'  and
     C                             w1vp <> 'P'  and
GFCbAC                             w1vp <> 'C'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
219 D*R                   MOVE *BLANKS   $MD
219 D*R                   MOVEADESC,2    $MD
219 MC                   eval      errmsg = *blanks
219 MC                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Cannot run on jobq, if we want to view the report.
     *
     C                   if        w1vp = 'V'  and
     C                             w1jobq = 'Y'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1006
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
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
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
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
417 A*  Include slot option must be either "O", "P" or "B".
     *
417 AC                   if        w1pick <> 'O'  and
417 AC                             w1pick <> 'P'  and
417 AC                             w1pick <> 'B'
417 AC                   eval      error = *on
417 AC                   eval      *in30 = *on
417 AC                   eval      *in10 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   movel     desc(7)       errmsg
417 AC                   exsr      zm1001
417 AC                   endif
     *
500aA*  Sort option must be either "S" or "D".
500a *
500aAC                   if        w1sort <> 'S'  and
500aAC                             w1sort <> 'D'
500aAC                   eval      error = *on
500aAC                   eval      *in28 = *on
500aAC                   eval      *in08 = *on
500aAC                   eval      errmsg = *blanks
500aAC                   movel     desc(8)       errmsg
500aAC                   exsr      zm1001
500aAC                   endif
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
     *     Warehouse department.
     *
     C                   select
     C                   when      row# = 08
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     C                   other
     *
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
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
210 D*R         #USER     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *ON
210 D*R                   Z-ADD1         WKWHSE  30
210 D*R                   Z-ADD1         W1WHSE
210 D*R                   ELSE
210 D*R                   Z-ADDUSWHSE    WKWHSE
210 D*R                   Z-ADDUSWHSE    W1WHSE
210 D*R                   ENDIF
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0
210 AC                   eval      wkwhse = w1whse
210 A*
414aAC                   eval      w1whdp = '*ALL '
214 AC                   eval      w1pexp = 'Y'
     *
214 AC                   eval      w1nexp = 0
     *
JORaAC                   if        client = jordanos or
FFCaAC                             client = fischerfoods
JORA C                   eval      w1vp = 'P'
JORa C                   else
510a C                   eval      w1vp = 'V'
JORa C                   endif
510A **                   MOVE 'P'       W1VP
     *
     C                   eval      w1jobq = 'N'
     *
417 AC                   eval      w1pick = 'B'
500aAC                   eval      w1sort = 'D'
     *
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   eval      w1dev = rpdev
     C                   eval      w1form = rpform
     C                   else
     C                   movel     '*JOB    '    w1dev
     C                   movel     '*STD    '    w1form
     C                   endif
     *
415aA*   Get current date in MMDDYY to default From Date.
415aAC                   eval      $cvcmd = '*CURMDY '
415aAC                   call      @cvtdt
415aAC                   parm                    $cvtdt
415aAC                   eval      w1fmdt = $cvd6o
415aA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C                   movel     'IT391PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
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
415aD*   Get current date in YYYMMDD.
415aD*R                   MOVE '*CURCMD '$CVCMD
415aD*R                   CALL @CVTDT
415aD*R                   PARM           $CVTDT
415aD*R                   MOVE $CVD8O    TODAY   80
415aD*R                   MOVE $CVD8O    $TODAY
     *
415aA*   Get From date in YYYYMMDD.
415aAC                   eval      $cvcmd = '*MDYCMD '
415aAC                   move      w1fmdt        $cvd6i
415aAC                   call      @cvtdt
415aAC                   parm                    $cvtdt
415aAC                   move      $cvd8o        today
415aAC                   move      $cvd8o        $today
214 A*
214 A*   Convert current date to julian.
214 AC                   move      today         g$date
214 AC                   eval      dtfrmt = 1
214 AC                   exsr      gtoj$
214 AC                   eval      begjul = g$jd
214 A*
214 A*   Calculate ending date.
214 AC     begjul        add       w1nexp        endjul
214 AC                   eval      j$jd = endjul
214 AC                   exsr      jtog$
214 AC                   eval      month = j$mm
214 AC                   eval      day = j$dd
214 AC                   move      j$yyyy        year
214 AC                   eval      endgrg = t#date
214 AC                   eval      $cvcmd = '*MDYCMD '
214 AC                   eval      $cvd6i = endgrg
214 AC                   call      @cvtdt
214 AC                   parm                    $cvtdt
214 AC                   move      $cvd8o        todt
214 AC                   move      $cvd8o        $nexp
     *
     C                   move      w1whse        $whse
414aAC                   eval      $whdp = w1whdp
     *
214 AC                   eval      $pexp = w1pexp
     *
     C                   eval      $vp = w1vp
     *
     C                   eval      $jobq = w1jobq
     *
     C                   eval      $dev = w1dev
     *
     C                   eval      $form = w1form
     *
417 AC                   eval      $pick = w1pick
     *
500aAC                   eval      $sort = w1sort
     *
GFCaAC                   move      w1byr         $buyer
     *
     *R         W1VP      IFEQ 'V'
     *R                   CALL 'IT392'
     *R                   PARM           W1WHSE
     *R                   ENDIF
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Section type
Print option
Job queue option
Printer device
Form type
Include prev expired item option
Include slot option
Sort option
