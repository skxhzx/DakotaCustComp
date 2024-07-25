      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER340     Letdown/Replenishment transactions for an employee
     *  July 2, 1999
     *  Hemant Kapadia
     *
     *  7.2.99  HNK  4.11
     *  - Created
     *
     *  Revisions
 530 *  09/18/09   GJA  5.30
     *     -Convert to RPGLE, cleaned up and revamped for suspended
     *      transaction
 530a*  02/11/10   GJA  5.30a
     *     -Fix:  Do not allow employee to be blank
     *
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
     Fer340fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser1  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *  Constants
     D digits          c                   const('0123456789 ')
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
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D forevr          s              1
     D fromdt          s              8  0
     D gtdate          s              8  0
     D kyemp#          s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D todt            s              8  0
     D usname          s             40
     D warn            s              1
     D work1a          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PTODT  To date (YYYYMMDD)
     *      $PWHSE  Warehouse code
     *      $PEMP#  Employee number
     *      $PJOBQ  Put on jobq (Y,N)
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *      $PDEV   Printer Device
     *      $PFORM  Printer Form
     *      $PFMTM  From time (HHMMSS)
     *      $PTOTM  To time (HHMMSS)
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $ptodt            8
     C                   parm                    $pwhse            3
     C                   parm                    $pemp#            5
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
     *   Do some clean up before leaving.
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
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
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *   Initialize error subfile
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
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
     *  Initialize message handling
     C                   exsr      zmimsg
     *   Call user added initialization routine.
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
     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
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
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *  Verify From Date.
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      w1fmdt = $cvd6o
     C                   endif
     *  Verify To Date.
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      w1todt = $cvd6o
     C                   endif
     *  Verify warehouse code.
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
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
530aA*  Verify Employee Number is entered
     C                   if        w1emp# = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     *
     *  Verify Employee Number
     C                   if        w1emp# <> '*ALL '
     C     digits        check     w1emp#                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     C                   if        w1emp# <> '*ALL '
     C                   eval      $cstr = *blanks
     C                   move      w1emp#        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         kyemp#
     C     kyemp#        chain     piruser1                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   else
     C                   move      kyemp#        w1emp#
     C                   endif
     C                   endif
     *  Verify jobq option
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
     *  Verify default device
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *  Verify default form type
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
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
     *  Test for F4 - Lookup
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *     Warehouse code.
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
     C                   other
     *     Cursor not on a valid lookup field.
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
     C                   eval      w1fmtm = 0600
     C                   eval      w1totm = 1500
     C                   eval      w1emp# = *blanks
     C                   eval      w1jobq = 'N'
     *   Get Report Title
     C                   call      'GETRPTE'
     C                   parm      '*DESC  '     $cmd              8
     C                   parm      'ER341PR'     $lrpt            10
     C                   parm      0             $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      rptttl = $desc
     *   Center report title.
     C                   movel     rptttl        $pstr
     C                   eval      $plen = 50
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *   Get Device and Form
     C                   call      'GETRPTE'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'ER341PR'     $lrpt
     C                   parm      0             $whse
     C                   parm      ' '           $styp
     C                   parm      ' '           $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   eval      w1dev = $dev
     C                   eval      w1form = $form
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1fmdt
     C                   move      $cvd6o        w1todt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      #pgmq = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *   Select first screen to display.
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
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
     C                   move      $cvd8o        $ptodt
     *
     C                   move      w1whse        $pwhse
     C                   eval      $pemp# = w1emp#
     C                   eval      $pjobq = w1jobq
     C                   eval      $pdev = w1dev
     C                   eval      $pform = w1form
     C                   eval      $prtn = '*OK     '
     *
     C                   move      '000000'      $ptotm
     C                   movel     w1totm        $ptotm
     C                   move      '000000'      $pfmtm
     C                   movel     w1fmtm        $pfmtm
     C                   eval      $prtn = '*OK     '
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Job queue option
Printer device
Form type
Employee number
