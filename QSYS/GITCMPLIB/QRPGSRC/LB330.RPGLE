      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB330   Check Digits - Random - options
     *  28 December 2007
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
520 A*    01/15/00  JCJ  520 A
     *      - Revised to produce 1 label spool file instead of several
     *
520dA*    10/20/09  JCJ  520dA
     *      - Soft coded label set.
     *
700a *    11/15/16  MR   700a
     *      - Change code to handle 5 digit check digit.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
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
700aDF*lb330fm   cf   e             workstn
700aAFlb33001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
700aAFoptions   if   e           k disk
520dAFlblfmtd   if   e           k disk
     FReports   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(9) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
     D @random2        c                   const('RANDOM2')
520dD *** @lblset         c                   const('ZBRCBI')
     D @plfmtl         c                   const('CDLARGE1')
     D @plfmts         c                   const('CDSMALL1')

700aA*----------------------------------------------------------------
700aA*  *CHKDGT  -  Check digit options.
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
700aA*    OPCOD#  -  Number of check digit codes per slot (1,2,3)
700aA*    OPDGT#  -  Maximum number of digits per code  (2,3)
700aA*    OPIDC1  -  Code 1 identifier
700aA*    OPIDC2  -  Code 2 identifier
700aA*    OPUNU2  -  Unused
700aA*    OPIDC3  -  Code 3 identifier
700aA*    OPUNU3  -  Unused
700aA*    OPIDD1  -  Digit 1 identifier
700aA*    OPIDD2  -  Digit 2 identifier
700aA*    OPIDD3  -  Digit 3 identifier
700aA*    OPRCOD  -  Current code to read (S=Single,R=Random)
700aA*    OPRCD1  -  Use code 1 for current reading (Y,N)
700aA*    OPRCD2  -  Use code 2 for current reading (Y,N)
700aA*    OPRCD3  -  Use code 3 for current reading (Y,N)
700aA*    OPRORD  -  Current read order (S=Single, R=Random)
700aA*    OPRLCR  -  Use read order Left/Center/Right (Y,N)
700aA*    OPRRCL  -  Use read order Right/Center/Left (Y,N)
700aA*    OPRLRC  -  Use read order Left/Right/Center (Y,N)
700aA*    OPRRLC  -  Use read order Right/Left/Center (Y,N)
700aA*    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
700aA*    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
700aA*    OPREAD  -  Number of digits user reads for codes
700aA*               less than 100.
700aA*    OP5NUM  -  Using 5 numeric check digit
700aA*
700aA* Data structure
700aA*
700aAD opdata          ds
700aAD  opcod#                 1      1  0
700aAD  opdgt#                 2      2  0
700aAD  opidc1                 3      8
700aAD  opidc2                 9     14
700aAD  opunu2                15     16
700aAD  opidc3                17     22
700aAD  opunu3                23     24
700aAD  opidd1                25     30
700aAD  opidd2                31     36
700aAD  opidd3                37     42
700aAD  oprcod                43     43
700aAD  oprcd1                44     44
700aAD  oprcd2                45     45
700aAD  oprcd3                46     46
700aAD  oprord                47     47
700aAD  oprlcr                48     48
700aAD  oprrcl                49     49
700aAD  oprlrc                50     50
700aAD  oprrlc                51     51
700aAD  oprclr                52     52
700aAD  oprcrl                53     53
700aAD  opread                54     54  0
700aAD  opreada               54     54
700aAD  op5num                55     55
700aAD  optend               117    117
     *----------------------------------------------------------------
700aAD                 ds
700aAD chkDgt                         5
700aAD  chkDa                  1      3
700aAD  chkDb                  2      4
700aAD  chkDc                  3      5
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ernam1                 1     20
     D  ernam2                21     40
700aDD* erval1                41     42P 0
700aDD* erval2                43     44P 0
700aMD  erval1                41     45P 0
700aMD  erval2                46     50P 0
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#cheneyo
      /COPY QCOPYSRC,id#cheneyr

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
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D forevr          s              1    inz('1')
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
     D wkwhse          s              3  0
     D work1a          s              1
     D w1whse          s              3  0
     D lblcount        s              3  0
     D @plfmt          s              8
520 AD w1tst           s              3  0
520dAD @lblset         s              6
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
     C                   parm                    $fcheck           3 0
     C                   parm                    $tcheck           3 0
     C                   parm                    $qty              2 0
     C                   parm                    $ltype            1
     C                   parm                    $dev             10
     C                   parm                    $form            10
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
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
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
     *      0110 - Check Digit / Quantity Range
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0121 - Check Digit
     *
700aAC     zm0121        begsr
700aAC                   eval      #msgid = 'PIR0121'
700aAC                   eval      #msgtp = '*DIAG  '
700aAC                   movea     errmsg        $md(1)
700aAC                   exsr      zmpmsg
700aAC                   endsr
     *----------------------------------------------------------------
     *      0113 - From / To Level Range
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0152 - Label Type
     *
     C     zm0152        begsr
     C                   eval      #msgid = 'PIR0152'
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify From Check digit.
     *
700aAC                   if        op5num <> '5'
700aDC*                  if        w1fchk <= *zeros or w1fchk > 999
700aAC                   if        w1fchk > 999
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = desc(1)
700aDC*                  exsr      zm0110
700aAC                   exsr      zm0121
     C                   endif
700aAC                   endif
     C
700aAC                   if        w1fchk <= *zeros
700aAC                   eval      error = *on
700aAC                   eval      *in21 = *on
700aAC                   eval      *in01 = *on
700aAC                   eval      errmsg = desc(1)
700aAC                   exsr      zm0110
700aAC                   endif
     *
     *  Verify To Check digit.
     *
700aAC                   if        op5num <> '5'
700aDC*                  if        w1tchk <= *zeros or w1tchk > 999
700aAC                   if        w1tchk > 999
700aAC                   eval      error = *on
700aAC                   eval      *in22 = *on
700aAC                   eval      *in02 = *on
700aAC                   eval      errmsg = desc(1)
700aDC*                  exsr      zm0110
700aAC                   exsr      zm0121
700aAC                   endif
700aAC                   endif
     C
700aAC                   if        w1tchk <= *zeros
700aAC                   eval      error = *on
700aAC                   eval      *in22 = *on
700aAC                   eval      *in02 = *on
700aAC                   eval      errmsg = desc(2)
700aAC                   exsr      zm0110
700aAC                   endif
     *
     *  Verify From Checkdigit is less than To Check digit
     *
     C                   if        w1fchk > w1tchk
     C                   eval      error = *on
700aDC*                  eval      *in21 = *on
700aMC                   eval      *in22 = *on
     C                   eval      *in01 = *on
700aDC*                  eval      ernam1 = desc(1)
700aDC*                  eval      ernam2 = desc(2)
700aMC                   eval      ernam1 = desc(2)
700aMC                   eval      ernam2 = desc(1)
     C                   eval      erval1 = w1fchk
     C                   eval      erval2 = w1tchk
     C                   exsr      zm0113
     C                   endif
     *
     *  Verify Quantity
     *
     C                   if        w1qty <= *zeros or w1qty > 99
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify Label type.
     *
     C                   if        w1ltype <> 'L' and w1ltype <> 'S'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0152
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
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(8)       errmsg
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
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(9)       errmsg
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
     *     Prompt
     *
     C                   select
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
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1fchk  = 1
     C                   eval      w1tchk  = 1
     C                   eval      w1qty   = 1
     C                   eval      w1ltype = 'L'
     *
     *   Initialize printer device/form
     *
     C                   eval      wkprtf = 'PMFTPR    '
     C     rpkey         Chain     reports
     C                   If        %Found(reports)
     C                   eval      w1dev = rpdev
     C                   eval      w1form = rpform
     C                   else
     C                   eval      w1dev = '*JOB    '
     C                   eval      w1form = '*STD    '
     C                   endif
700aA*
700aA*   Get Check digit options
700aA*
700aA /Free
700aA                    chain     (w1whse:'*CHKDGT') options;
700aA                    if        not %found;
700aA                    eval      op5num = '3';
700aA                    endif;
700aA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     C     rpkey         Klist
     C                   Kfld                    wkprtf
     *
     C                   eval      $pstr  = 'Check digit - Random'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     *
520dAC     *loval        setll     lblfmtd
520dAC                   dou       %eof(lblfmtd)
520dAC                   read      lblfmtd
520dAC                   if        not %eof(lblfmtd)
520dAC                   if        lfdfmt = @plfmtl
520dAC                             or lfdfmt = @plfmts
520dAC                   eval      @lblset = lfdset
520dAC                   leave
520dAC                   endif
520dAC                   endif
520dAC                   enddo
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
     * label type
     C                   select
     C                   when      w1ltype = 'L'
     C                   eval      @plfmt = @plfmtl
     C                   when      w1ltype = 'S'
     C                   eval      @plfmt = @plfmts
     C                   endsl
     *
     C                   eval      lblcount = *zeros
520 AC                   if        w1qty > 1
520 AC                   eval      $pcmd = '*CHECKR '
520 AC                   eval      w1tst = w1qty - 1
520 AC                   endif
     *
     C                   dow       forevr = forevr
     *
     C                   call      @random2
     C                   parm                    $pseed            9 9
     C                   parm      w1fchk        $pmin             6 0
     C                   parm      w1tchk        $pmax             6 0
     C                   parm                    $pnum             6 0
     *
700aAc                   if        op5num = '5'
700aAC                   z-add     $pnum         $pnum5            5 0
700aAC                   eval      chkDgt  = %editc($pnum5:'X')
700aAc                   eval      $pchkd1 = chkDa
700aAc                   eval      $pchkd2 = chkDb
700aAc                   eval      $pchkd3 = chkDc
700aAc                   else
     C                   z-add     $pnum         $pnum3            3 0
     C                   eval      $pchkd1 = %editc($pnum3:'X')
700aAc                   eval      $pchkd2 = *blanks
700aAc                   eval      $pchkd3 = *blanks
700aAc                   endif
     *
     C                   call      @prtpg
     C                   parm                    $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmt        $plfmt            8
     C                   parm      wkwhse        $pwhse            3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $pwhdp            5
     C                   parm      *blanks       $pdisp           12
     C                   parm      *blanks       $pdispa           1
     C                   parm      *blanks       $pdispb          11
     C                   parm                    $pchkd1           3
700aDC*                  parm      *blanks       $pchkd2           3
700aDC*                  parm      *blanks       $pchkd3           3
700aAC                   parm                    $pchkd2           3
700aAC                   parm                    $pchkd3           3
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $plcn2           15
     C                   parm      *blanks       $pitm#           15
     C                   parm      *blanks       $brand           10
     C                   parm      *blanks       $ppdsc           15
     C                   parm      *blanks       $pdesc           30
     C                   parm      *blanks       $ptxt1           30
     C                   parm      *blanks       $ptxt2           30
     C                   parm      *blanks       $ptxt3           30
     C                   parm      *blanks       $ptrail           8
     C                   parm      *blanks       $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10
700aAC                   parm      *blanks       $pexpd            8
700aAC                   parm      *blanks       $pindt            8
700aAC                   parm      *blanks       $gs1fmt          23
     *
     C                   eval      lblcount = lblcount + 1
     *
520 AC                   if        lblcount = w1tst
520 AC                   eval      $pcmd = *blanks
520 AC                   endif
     *
     C                   if        lblcount >= w1qty
     C                   leave
     C                   endif
     *
1E   C                   enddo
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
From Check digit
To Check digit
Quantity
Label type
Printer device
Form type
