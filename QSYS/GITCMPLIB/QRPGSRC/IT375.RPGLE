     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT375     Item Slot List in Picking Order
     *  January 17, 2002
     *  Roxanne Harrison
     *
416 A*  01-17-02  RH  4.16
     *  - Created
     *
     *  NOTE:
     *    - $PTITM To Item is for future use to select a range of
     *      item numbers.
     *  Revisions
     *
     *    03/18/03  RH   4.17
     *      - Add W1TITM field for item range.
     *
710a *    10/06/17  GJA  7.10a
     *      - Change IT110A to now call IT375CL to override printer.
     *        Defaulted from and to item from parameters if sent.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
CBIa *    04/23/03  RH   CBIa
     *      - If TO item field is blank, fill with FROM item so user
     *        does not need to enter both field to select one item
     *
CBI A*    06/01/04  CBI-JGD
     *      Set 'FROM ITEM' field as cursor default location.
     *
CBI1A*    08/25/08  CBI-JGD
     *      Added logic to 'ZZCHK1' routine to avoid the printing
     *      of very large report, any report of 50 items or more
     *      will be directed internally by 'IT375CL' to outq 'PRT01'.
     *
CBI0a*    09/27/17  NLK  Upgrade to 7.1
     *      - Enh: Wrap the CBI code to allow back to DEV
     *
CBIb *    05/25/21  NLK  Upgrade to 7.4  (CBIa)
     *      - FIX: Issue w CBIa when converting, merge incorrect
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
CBI0D*IT375FM CF  E                    WORKSTN
CBI0MFit37501   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
CBI1AFpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getcl          c                   const('GETCLIENT')
     *  Constants
     D digits          c                   const('0123456789 ')
     D cheney          c                   const('CHENEYBROS')
     *----------------------------------------------------------------
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
     D  $lwhse                19     21  0
     D  $litm1                22     36
     *
     *----------------------------------------------------------------
CBI1A*  Numeric item #
CBI1A*
CBI1AD                 ds
CBI1AD  itm1                   1     15  0
CBI1A*
CBI1AD                 ds
CBI1AD  itm2                   1     15  0
CBI1A*  Alpha item #
CBI1A*
CBI1AD alpnum          ds
CBI1AD  alphan                 1    105
CBI1A*
CBI1AD  itm6                   1      6
CBI1AD  itm7                   7     13
CBI1AD  itm8                  14     21
CBI1AD  itm9                  22     30
CBI1AD  itm10                 31     40
CBI1AD  itm11                 41     51
CBI1AD  itm12                 52     63
CBI1AD  itm13                 64     76
CBI1AD  itm14                 77     90
CBI1AD  itm15                 91    105
CBI1A*
CBI1A*
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D forevr          s              1
     D gtdate          s              8  0
     D item#           s             15
     D len             s              3  0
     D msgk            s              4  0
     D numitm          s              6  0
     D nxtscr          s              3
     D pos             s              3  0
     D rptttl          s             50
     D sclear          s              1
     D usname          s             40
     D warn            s              1
     D work1a          s              1
     D x               s              3  0
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PWHSE  Warehouse code
     *      $PJOBQ  Put on jobq (Y,N)
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $prtn             8
     C                   parm                    $pjobq            1
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pitem           15
     C                   parm                    $ptitm           15
CBI1AC                   parm                    $items            6
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
CBI1AC     warn          caseq     '1'           wr1
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
CBI A*  Set cursor default location to 'MODE' field.
CBI AC                   if        client = cheney
CBI AC                   setoff                                       01
CBI AC                   seton                                        09
CBI AC                   endif
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
CBI1AC                   if        warn = *on
CBI1AC                   exfmt     warnmsg                              50
CBI1AC                   endif
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
     C     error         cabeq     *on           endsc1
CBI1AC     warn          cabeq     *on           endsc1
     C                   exsr      zznxt1
     C     endsc1        endsr
CBI1A*----------------------------------------------------------------
     *
     *  WR1  -  Screen 1    (THIS ROUTINE WAS ADDED THRU 'CBI1' MOD.)
CBI1A*----------------------------------------------------------------
     *
     C     wr1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endwr1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endwr1
     C                   endif
     *
     *  Some other key pressed.
     *
     *
     C                   exsr      zznxt1
     C     endwr1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
CBI0a*
CBI0a* Get client id.
CBI0a*
CBI0aC                   call      @getcl
CBI0aC                   parm                    client           10
CBI0a*
     C                   eval      gtdate = 0
     C                   eval      usname = *blanks
     C                   eval      forevr = *blanks
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
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(4)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
CBI1AC                   eval      warn = *off
     *
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
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify item entered.
     *
     C                   if        w1item = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0203
     C                   endif
     *
     *
     *  Verify item number if entered.
     *
     C                   if        w1item <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litm1 = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
417a *
417a *  Verify item entered.
417a *
CBIb *     was checking at w1item above, move CBIa down here.
417a C                   if        w1titm = *blanks
CBIaAC                   if        client = cheney
CBIa C                   eval      w1titm = w1item
CBIaAC                   else
417a C                   eval      error = *on
417a C                   eval      *in28 = *on
417a C                   eval      *in08 = *on
417a C                   eval      errmsg = *blanks
417a C                   exsr      zm0203
CBIaAC                   endif
417a C                   endif
     *
417a *  Verify item number if entered.
417a *
417a C                   if        w1titm <> *blanks
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   eval      $litm1 = w1titm
417a C                   call      'IT900'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
417a C                   eval      *in29 = *on
417a C                   eval      *in09 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
417a C                   eval      *in29 = *on
417a C                   eval      *in09 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   endif
417a *
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
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
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
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
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
CBI0AC                   if        client = cheney
CBI1AC                   if        error = *on
CBI1AC                   goto      endck1
CBI1AC                   endif
     *
CBI1A* ---------------------------------------------------------------
CBI1A*  Verify that number of items to be processed
CBI1A*  does not go over twenty to avoid creating a
CBI1A*  large report.
     *
CBI1AC                   eval      x = 1
CBI1AC                   eval      itm1 = *zeros
CBI1AC                   eval      itm2 = *zeros
     *
CBI1AC                   eval      item# = w1item
     *
CBI1AC                   dow       x <= 2
     *
CBI1AC     ' '           scan      item#         pos
CBI1AC                   if        pos > 1
CBI1AC                   eval      len = pos - 1
     *
CBI1AC                   select
CBI1AC                   when      len = 6
CBI1AC     len           subst     item#:1       itm6
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm6          itm1
CBI1AC                   else
CBI1AC                   move      itm6          itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 7
CBI1AC     len           subst     item#:1       itm7
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm7          itm1
CBI1AC                   else
CBI1AC                   move      itm7          itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 8
CBI1AC     len           subst     item#:1       itm8
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm8          itm1
CBI1AC                   else
CBI1AC                   move      itm8          itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 9
CBI1AC     len           subst     item#:1       itm9
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm9          itm1
CBI1AC                   else
CBI1AC                   move      itm9          itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 10
CBI1AC     len           subst     item#:1       itm10
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm10         itm1
CBI1AC                   else
CBI1AC                   move      itm10         itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 11
CBI1AC     len           subst     item#:1       itm11
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm11         itm1
CBI1AC                   else
CBI1AC                   move      itm11         itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 12
CBI1AC     len           subst     item#:1       itm12
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm12         itm1
CBI1AC                   else
CBI1AC                   move      itm12         itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 13
CBI1AC     len           subst     item#:1       itm13
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm13         itm1
CBI1AC                   else
CBI1AC                   move      itm13         itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 14
CBI1AC     len           subst     item#:1       itm14
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm14         itm1
CBI1AC                   else
CBI1AC                   move      itm14         itm2
CBI1AC                   endif
     *
CBI1AC                   when      len = 15
CBI1AC     len           subst     item#:1       itm15
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      itm15         itm1
CBI1AC                   else
CBI1AC                   move      itm15         itm2
CBI1AC                   endif
     *
CBI1AC                   other
CBI1AC                   if        itm1 = *zeros
CBI1AC                   move      item#         itm1
CBI1AC                   else
CBI1AC                   move      item#         itm2
CBI1AC                   endif
     *
CBI1AC                   endsl
CBI1AC                   endif
     *
CBI1AC                   add       1             x
CBI1AC                   eval      item# = w1titm
CBI1AC                   enddo
     *
CBI1AC                   setoff                                       21
     *
CBI1AC                   eval      numitm = *zeros
CBI1AC                   if        itm1 <> *zeros  and
CBI1AC                             itm2 <> *zeros  and
CBI1AC                             itm1 <> itm2
     *
CBI1AC     itmkey        chain     piritem                            79
CBI1AC                   dow       not *in79  and
CBI1AC                             ititem <> w1titm
CBI1AC                   add       1             numitm
CBI1AC                   read      piritem                                79
CBI1AC                   enddo
     *
CBI1AC                   movel     numitm        $items
     *
CBI1AC                   if        numitm <= 20
CBI1AC                   goto      endck1
CBI1AC                   endif
     *
CBI1AC                   if        numitm > 20  and
CBI1AC                             numitm < 50
CBI1AC                   eval      warn = *on
CBI1AC                   eval      nxtscr = '0  '
CBI1AC                   goto      endck1
CBI1AC                   endif
     *
CBI1AC                   if        numitm >= 50
CBI1AC                   eval      warn = *on
CBI1AC                   seton                                        21
CBI1AC                   eval      nxtscr = '0  '
CBI1AC                   endif
CBI1AC                   endif
CBI0AC                   endif
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
     *     Warehouse.
     *
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
     *     Item.
     *
     C                   when      row# = 09
     C                   eval      *in09 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   eval      $litm1 = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litm1
     C                   endif
     *
417a *     Item.
417a *
417a C                   when      row# = 10
417a C                   eval      *in09 = *on
417a C                   eval      $lcmd = '*LOOKUP '
417a C                   eval      $lprg = #prog
417a C                   eval      $lwhse = w1whse
417a C                   eval      $litm1 = w1titm
417a C                   call      'IT900'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*SELECT '
417a C                   eval      w1titm = $litm1
417a C                   endif
     *
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
     C                   eval      w1item = *blanks
417A C                   eval      w1titm = *blanks
710aAC                   eval      w1item = $pitem
710aAC                   eval      w1titm = $ptitm
     C                   eval      w1jobq = 'N'
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     *   Get Report Title
     C                   call      'GETRPT'
     C                   parm      '*DESC  '     $cmd              8
     C                   parm      'IT376PR'     $lrpt            10
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
     *R                   MOVELRPTTTL    $PSTR  60
     *R                   Z-ADD50        $PLEN   30
     *R                   CALL 'CENTER'
     *R                   PARM           $PSTR
     *R                   PARM           $PLEN
     *R                   MOVEL$PSTR     RPTTTL
     *   Get Device and Form
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'IT376PR'     $lrpt
     C                   parm      0             $whse
     C                   parm      ' '           $styp
     C                   parm      ' '           $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   eval      w1dev = $dev
     C                   eval      w1form = $form
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
CBI1AC     itmkey        klist
CBI1AC                   kfld                    w1whse
CBI1AC                   kfld                    w1item
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
     *
     C                   move      w1whse        $pwhse
     C                   eval      $pjobq = w1jobq
     C                   eval      $pdev = w1dev
     C                   eval      $pform = w1form
     C                   eval      $prtn = '*OK     '
     C                   eval      $pitem = w1item
417aMC                   eval      $ptitm = w1titm
417aD**                   MOVE *BLANKS   $PTITM
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
Item number
