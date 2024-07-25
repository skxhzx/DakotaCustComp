     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT312     Item/Slot activity - Options
     *  Hemant Kapadia
     *  Roxanne Harrison
     *
     *  Revisions
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
     *
     *    06/05/96  RH   2.13
     *      - Add options to select order of report, item or All &
     *        slot or All.
     *      - Remove RPTTTL from screen, code as a constant.
416a *    01/02/02  RH   4.16a
     *      - Write base item and alias items to work file if base
     *        item # was entered. If alias entered, write only alias.
416b *    01/07/02  RH   4.16b
     *      - Set flag if alias item exists, pass parm.
416c *    12/17/02  RH   4.16c
     *      - Must enter valid base slot or *all
     *      - Add $DISP1 to contain base slot with *
416dA*    01/31/03  MLB  4.16d
     *      - Enh: Revised ZZFIL1 to load blanks for W1ITEM
     *        instead of defaulting to *ALL.
     *        Revised ZZCHK1 to not allow item number to be blank.
417aA*    05/21/03  RH   4.17a
     *      - FIX: Replace ZZITEM with call to IT312A.
510a *    06/28/06  HNK  5.10a
     *      - Enh: Default dates to today's date and Print or view
     *             option to View.
510bA*    07/07/06  MLB  5.10b
     *      - Fix: Add option 4 to list of valid sort by options.
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
     Fit312fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
210 D*IRUSER IF  E           K        DISK
     Freports   if   e           k disk
     Frptovr1   if   e           k disk
416a Fpiritem   if   e           k disk
416c Fslot2     if   e           k disk
416a Fitemlnk1  if   e           k disk
416b Fitemlnk   if   e           k disk
     F                                     rename(ilrec:record)
416a Fit312     o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
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
213 AD  $lwhdp                22     26
213 AD  $litem                27     41
213 AD  $ldisp                42     53
213 A*
213 AD  $litm1                22     36
213 A*
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      6  0
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Working variables
     *
     D $link           s              1
     D $msgf           s             10
     D $rtncd          s              8
     D $whsea          s              3
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D kyitem          s                   like(w1item)
     D kywhse          s              3  0
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D stop            s              1
     D warn            s              1
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
     D wkwhse          s              3  0
     D work1a          s              1
     D w1frm8          s              8  0
     D w1to8           s              8  0
     *
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *PIR     - Select only PIR items
     *              *FIXED   - Select only Fixed items
     *              *BOTH    - Select all items
     *      $PLNK   'Y'      - Linked item exists
     *              'N'      - No linked items.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $jobq             1
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   parm                    $from             8
     C                   parm                    $to               8
     C                   parm                    $vp               1
213 AC                   parm                    $whdp             5
213 AC                   parm                    $sort             1
213 AC                   parm                    $item            15
213 AC                   parm                    $disp            12
416bAC                   parm                    $plnk             1
416cAC                   parm                    $disp1           12
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
     C                   setoff                                       3031
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
416a C                   eval      stop = *off
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
     *    PIR9901  Invalid date entered.
     *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
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
213 A*    PIR0203  Value cannot be blank.
213 A*
213 AC     zm0203        begsr
213 AC                   eval      #msgid = 'PIR0203'
213 AC                   eval      #msgtp = '*DIAG  '
213 AC                   movea     desc(6)       errmsg
213 AC                   movea     errmsg        $md(1)
213 AC                   exsr      zmpmsg
213 AC                   endsr
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
416cA*    IT31201  Can't enter virtual slot, enter base.
416cA*
416cAC     zm1201        begsr
416cAC                   eval      #msgid = 'IT31201'
416cAC                   eval      #msgtp = '*DIAG  '
416cAC                   movea     errmsg        $md
416cAC                   exsr      zmpmsg
416cAC                   endsr
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
213 A*
213 A*  Verify warehouse department.
213 A*
213 AC                   if        w1whdp <> *blanks
213 AC                   eval      $lcmd = '*VERIFY '
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $lwhdp = w1whdp
213 AC                   call      'WD900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*ERROR  '
213 AC                   eval      error = *on
213 AC                   eval      *in31 = *on
213 AC                   eval      *in11 = *on
213 AC                   movel     $lerm         errmsg
213 AC                   exsr      zm0105
213 AC                   else
213 AC                   if        $lrtn = '*PGMQ   '
213 AC                   eval      error = *on
213 AC                   eval      *in31 = *on
213 AC                   eval      *in11 = *on
213 AC                   eval      #msgk = $lmsg
213 AC                   exsr      zmqmsg
213 AC                   endif
213 AC                   endif
213 AC                   endif
     *
     *  Verify dates.
     *
     *
     *     Verify FROM date
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
213 D*R                   EXSR ZMCMSG
     C                   eval      erdate = w1fmdt
     C                   exsr      zm9906
     C                   else
     C                   eval      w1fmdt = $cvd6o
     C                   endif
     C                   endif
     *
     *     Verify TO date
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $cvmsg
213 D*R                   EXSR ZMCMSG
     C                   eval      erdate = w1todt
     C                   exsr      zm9906
     C                   else
     C                   eval      w1todt = $cvd6o
     C                   endif
     C                   endif
     *
     *     FROM date can not be greater than TO date.
     *
     C                   if        error = *off
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1frm8 = $cvd8o
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1to8 = $cvd8o
     *
     C                   if        w1frm8 > w1to8
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     C                   exsr      zm9901
     C                   endif
     C                   endif
213 A*
213 A*  Verify order by option.
213 A*
213 AC                   if        w1sort <> 1  and
213 AC                             w1sort <> 2  and
213 AC                             w1sort <> 3  and
510bAC                             w1sort <> 4
213 AC                   eval      error = *on
213 AC                   eval      *in28 = *on
213 AC                   eval      *in08 = *on
213 AC                   eval      errmsg = *blanks
213 AC                   movel     desc(5)       errmsg
213 AC                   exsr      zm1001
213 AC                   endif
213 A*
213 A*  Verify item number if entered.
213 A*
213 AC                   if        w1item <> '*ALL'
416dD*R         W1ITEM    ANDNE*BLANKS
213 AC                   eval      $lcmd = '*VERIFY '
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $litm1 = w1item
213 AC                   call      'IT900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*ERROR  '
213 AC                   eval      error = *on
213 AC                   eval      *in29 = *on
213 AC                   eval      *in09 = *on
213 AC                   movel     $lerm         errmsg
213 AC                   exsr      zm0105
213 AC                   else
213 AC                   if        $lrtn = '*PGMQ   '
213 AC                   eval      error = *on
213 AC                   eval      *in29 = *on
213 AC                   eval      *in09 = *on
213 AC                   eval      #msgk = $lmsg
213 AC                   exsr      zmqmsg
213 AC                   endif
213 AC                   endif
213 AC                   endif
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
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
     C                   movel     desc(3)       errmsg
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
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify view/print.
     *
     C                   if        w1vp <> 'V'  and
     C                             w1vp <> 'P'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
213 A*
213 A*  Cannot run on jobq, if we want to view the report.
213 A*
213 AC                   if        w1vp = 'V'  and
213 AC                             w1jobq = 'Y'
213 AC                   eval      error = *on
213 AC                   eval      *in24 = *on
213 AC                   eval      *in04 = *on
213 AC                   eval      errmsg = *blanks
213 AC                   exsr      zm1006
213 AC                   endif
213 A*
213 A*  Verify slot.
213 A*
213 AC                   if        w1disp <> '*ALL'
213 AC                   eval      $lcmd = '*VERIFY '
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $lwhdp = w1whdp
213 AC                   eval      $litem = *blanks
213 AC                   eval      $ldisp = w1disp
213 AC                   call      'SL900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*ERROR  '
213 AC                   eval      error = *on
213 AC                   eval      *in30 = *on
213 AC                   eval      *in10 = *on
213 AC                   movel     $lerm         errmsg
213 AC                   exsr      zm0105
213 AC                   else
213 AC                   if        $lrtn = '*PGMQ   '
213 AC                   eval      error = *on
213 AC                   eval      *in30 = *on
213 AC                   eval      *in10 = *on
213 AC                   eval      #msgk = $lmsg
213 AC                   exsr      zmqmsg
213 AC                   endif
213 AC                   endif
213 AC                   endif
213 A*
213 A*  If slot was entered, Whse department can't be blank.
213 A*
213 AC                   if        w1disp <> *blanks  and
213 AC                             w1disp <> '*ALL'  and
213 AC                             w1whdp = *blanks
213 AC                   eval      error = *on
213 AC                   eval      *in31 = *on
213 AC                   eval      *in11 = *on
213 AC                   eval      errmsg = *blanks
213 AC                   exsr      zm0203
213 AC                   endif
213 A*
416cA*  Entered slot can not be virtual slot.
416cA*
416cAC                   if        error = *off  and
416cAC                             w1disp <> '*ALL'
416cAC     slkey         chain     slot2                              79
416cAC                   if        not *in79  and
416cAC                             slrsrv = 'V'
416cAC                   eval      error = *on
416cAC                   eval      *in30 = *on
416cAC                   eval      *in10 = *on
416cAC                   eval      errmsg = *blanks
416cAC                   exsr      zm1201
416cAC                   endif
416cAC                   endif
416cA*
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
213 A*
213 A*     Warehouse department.
213 A*
213 AC                   when      row# = 9
213 AC                   eval      *in11 = *on
213 AC                   eval      $lcmd = '*LOOKUP '
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $lwhdp = w1whdp
213 AC                   call      'WD900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*SELECT '
213 AC                   eval      w1whdp = $lwhdp
213 AC                   endif
213 A*
213 A*     Item.
213 A*
213 AC                   when      row# = 14
213 AC                   eval      *in09 = *on
213 AC                   eval      $lcmd = '*LOOKUP '
213 AC                   eval      $lprg = #prog
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $litm1 = w1item
213 AC                   call      'IT900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*SELECT '
213 AC                   eval      w1item = $litm1
213 AC                   endif
213 A*
213 A*
213 A*     SLOT.
213 A*
213 AC                   when      row# = 15
213 AC                   eval      *in10 = *on
213 AC                   eval      $lcmd = '*GENERAL'
213 AC                   eval      $lwhse = w1whse
213 AC                   eval      $lwhdp = w1whdp
213 AC                   eval      $litem = *blanks
213 AC                   eval      $ldisp = w1disp
213 AC                   call      'SL900'
213 AC                   parm                    $lparm
213 AC                   if        $lrtn = '*SELECT '
213 AC                   eval      w1disp = $ldisp
213 AC                   endif
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
510aD**                   MOVE 'P'       W1VP
510a C                   eval      w1vp = 'V'
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
210 D*R         #USER     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *ON
210 D*R                   Z-ADD1         WKWHSE
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
     *
510a *  Convert today's date into MMDDYY format.
     *
510a C                   eval      $cvcmd = '*CURMDY '
510a C                   call      @cvtdt
510a C                   parm                    $cvtdt
510a C                   eval      w1fmdt = $cvd6o
510a C                   eval      w1todt = $cvd6o
     *
     C                   eval      wkstyp = *zeros
     C                   eval      wkwhdp = *zeros
     C                   eval      w1jobq = 'N'
213 AC                   eval      w1whdp = *blanks
213 AC                   eval      w1sort = 1
416dD*R                   MOVEL'*ALL'    W1ITEM
416dMC                   eval      w1item = *blanks
213 AC                   movel     '*ALL'        w1disp
     *
     C     rokey         chain     rptovr1                            79
     C                   if        not *in79
     C                   eval      w1dev = rodev
     C                   eval      w1form = roform
     C                   endif
     *
     C                   if        *in79
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   eval      w1dev = rpdev
     C                   eval      w1form = rpform
     C                   else
     C                   movel     '*JOB    '    w1dev
     C                   movel     '*STD    '    w1form
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
416a C     itkey         klist
416a C                   kfld                    kywhse
416a C                   kfld                    kyitem
     *
416c C     slkey         klist
416c C                   kfld                    w1whse
416c C                   kfld                    w1whdp
416c C                   kfld                    w1disp
     *
     C     rokey         klist
     C                   kfld                    wkprtf
     C                   kfld                    wkwhse
     C                   kfld                    wkstyp
     C                   kfld                    wkwhdp
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
213 D*
213 D*R                   MOVEL'IT316PR 'WKPRTF
213 D*R                   MOVE *BLANKS   RPTTTL
213 D*R         RPKEY     CHAINREPORTS              79
213 D*R         *IN79     IFEQ *OFF
213 D*R                   MOVELRPDESC    $PSTR  60
213 D*R                   ELSE
213 D*R                   MOVE *BLANKS   $PSTR
213 D*R                   ENDIF
213 D*R                   Z-ADD40        $PLEN   30
     *
213 D*R                   CALL 'CENTER'
213 D*R                   PARM           $PSTR
213 D*R                   PARM           $PLEN
213 D*R                   MOVEL$PSTR     RPTTTL
     *
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
416a *----------------------------------------------------------------
416a *
416a *  ZZITEM   Get linked items for work file.
416a *
416a C     zzitem        begsr
416a *  Write entered item to work file
416a C                   eval      wkwhse = w1whse
416a C                   eval      wkitem = w1item
416a C                   write     wkrec
416a *  Write alias item to work file
416a C                   eval      kywhse = w1whse
416a C                   eval      kyitem = w1item
416a C     itkey         chain     piritem                            79
416a C                   if        not *in79  and
416a C                             ittype = ' '
416a C     itkey         setll     itemlnk1                           79
416a C                   dou       stop = '1'
416a C     itkey         reade     itemlnk1                               79
416a C                   if        *in79
416a C                   eval      stop = *on
416a C                   else
416a C                   eval      wkwhse = ilwhse
416a C                   eval      wkitem = ilitem
416a C                   write     wkrec
416a C                   iter
416a C                   endif
416a C                   enddo
416a C                   endif
416a *
416a *  Check if linked item exists.
416b *  Check if alias item was entered.
416b C                   eval      $plnk = 'N'
416b C     itkey         chain     itemlnk                            78
416b C                   if        not *in78
416b C                   eval      $plnk = 'Y'
416b C                   else
416b *  Check if base item was entered.
416b C     itkey         chain     itemlnk1                           78
416b C                   if        not *in78
416b C                   eval      $plnk = 'Y'
416b C                   endif
416b C                   endif
416a *
416a C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
416a C                   if        w1item <> '*ALL'  and
416a C                             w1item <> *blanks
417a C                   move      w1whse        $whsea
417aAC                   eval      $item = w1item
417aAC                   eval      $link = *blanks
417aAC                   eval      $rtncd = *blanks
417a C                   call      'IT312A'
417a C                   parm                    $whsea
417a C                   parm                    $item
417a C                   parm                    $link
417a C                   parm                    $rtncd
417aD**                   EXSR ZZITEM
416a C                   endif
     *
417a C                   eval      $plnk = $link
     *
     C                   move      w1whse        $whse
     *
     C                   eval      $jobq = w1jobq
     *
     C                   eval      $dev = w1dev
     *
     C                   eval      $form = w1form
     *
     C                   move      w1frm8        $from
     C                   move      w1to8         $to
     C                   eval      $vp = w1vp
213 AC                   eval      $whdp = w1whdp
213 AC                   move      w1sort        $sort
213 AC                   eval      $item = w1item
     C                   eval      $disp = w1disp
416CAC                   eval      $disp1 = *blanks
416cAC                   if        w1disp <> '*ALL'
416cAC     w1disp        cat       '*':0         $disp1
416cAC                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Print option
Job queue option
Printer device
Form type
Order by option
Department
