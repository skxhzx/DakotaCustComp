     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  UI350     RF UCI Inv Adj - Stuffit Report Options
     F*  04 April,  2007
     F*  Jeff Jahnke
     F*
     F*  Revisions
     F*
510 AF*    04/04/07  JCJ  5.10 A
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program fm needs to be compiled with DEFER=*NO so the status
     F*    messages can be displayed.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (Reverse Display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (Protect key)
     F*  97        Always ON (Used for SFLEND Keyword)
     F*  98        Error on screen (Sound buzzer)
     F*  99        Universal record indicator (Very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     Fui350fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
      *----------------------------------------------------------------
      *  Table and array definitions
      *
     D a10             S              1    DIM(10)
     D desc            S             60    DIM(7) CTDATA PERRCD(1)
      *----------------------------------------------------------------
      *  Program parameters
      *
     D $lparm          DS
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
      *
      *   Redefine key
      *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *
     D $mdt            ds
     D  errmsg                 1     50
      *
     D  ercnt                  1      4P 0
     D  ercode                 1      3P 0
     D                 ds
     D  $ec                    1      2P 0
      *----------------------------------------------------------------
      *  Message control
      *
     D #msgf           C                   const('PIRMSGF   ')
     D*
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
      *----------------------------------------------------------------
      *  Program info data structure
      *
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
      *----------------------------------------------------------------
      *  Workstation exception data structure
      *
     D infds           DS
     D  status           *STATUS
     D  rowin                370    370
     D  colin                371    371
      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure
      *
     D                 DS
     D  row#                   1      2B 0
     D  row                    2      2
     D  col#                   3      4B 0
     D  col                    4      4
      *---------------------------------------------------------------------
      * variables
      *
     D help            s              5  0
     D enter           s              5  0
     D clear           s              5  0
     D comand          s              5  0
     D msgk            s              4  0
     D $whse           s              3  0
     D #whse           s              3  0
     D w1whse          s              3  0
     D $plen           s              3  0
     D e               s              2  0
     D $desc           s             50
     D $item           s             15
     D $pslot          s             12
     D $msgf           s             10
     D $dev            s             10
     D $form           s             10
     D $pdev           s             10
     D $pform          s             10
     D $lrpt           s             10
     D #pgmq2          s             10
     D $prtn           s              8
     D $cmd            s              8
     D #msgid          s              7
     D #msgtp          s              7
     D $pavr           s              5
     D $whdp           s              5
     D $dept           s              5
     D $pwhse          s              3
     D nxtscr          s              3
     D warn            s              1
     D error           s              1
     D cmdtkn          s              1
     D sclear          s              1
     D $padj           s              1
     D $psum           s              1
     D $pjobq          s              1
     D $styp           s              1
     D work1a          s              1
      *---------------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      None
      *
      *    Returned Parameters
      *      $PRTN   *EXIT    - CMD3 was entered
      *              *CANCEL  - CMD12 was entered
      *      $PXCP   Y - Print exceptions only
      *              N - Print all detail
      *      $PSUM   Y - Print summary only-one line per item #
      *              N - Print all detail
      *      $PJOBQ  Put on jobq (Y,N)
      *      $PWHSE  Warehouse #
      *
      *----------------------------------------------------------------
      *  Let the show begin .....
      *
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $dept
     C                   parm                    $padj
     C                   parm                    $pjobq
     C                   parm                    $prtn
     C                   parm                    $pdev
     C                   parm                    $pform
      *----------------------------------------------------------------
      *  Main line
      *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOF'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo

      *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *  DSPSCR - Display screen
      *
     C     dspscr        begsr

      *   Set ON alarm indicator if error occured

     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif

      *   Overlay screen with error messages

     C                   exsr      zmdmsg

      *  Overlay screen with screen to be processed.

     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif

      *   Initialize error indicators and fields

     C                   eval      *in01 = *off
     C                   eval      *in02 = *off
     C                   eval      *in03 = *off
     C                   eval      *in04 = *off
     C                   eval      *in05 = *off
     C                   eval      *in06 = *off
     C                   eval      *in07 = *off
     C                   eval      *in08 = *off
     C                   eval      *in09 = *off
     C                   eval      *in10 = *off
     C                   eval      *in21 = *off
     C                   eval      *in22 = *off
     C                   eval      *in23 = *off
     C                   eval      *in24 = *off
     C                   eval      *in25 = *off
     C                   eval      *in26 = *off
     C                   eval      *in27 = *off
     C                   eval      *in28 = *off
     C                   eval      *in29 = *off
     C                   eval      *in30 = *off
     C                   eval      *in98 = *off
     C                   eval      warn  = *off
     C                   eval      error = *off
     C                   eval      cmdtkn= *off
     C                   eval      e     = *zeros

      *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr
      *----------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *----------------------------------------------------------------
      *
      *  Screen 01 initialization
      *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '

      *  Get existing record.

     C                   exsr      zzfil1
     C     end01i        endsr
      *----------------------------------------------------------------
      *
      *              Screen Processing Routines
      *
      *----------------------------------------------------------------

      *  sc1  -  Screen 1

     C     sc1           begsr

      *  Test for F3 - Exit

     C                   if        *INKC  = '1'
     C                   eval      $prtn  = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif

      *  Test for F5 - Refresh

     C                   if        *inke = '1'
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif

      *  Test for F12 - Previous

     C                   if        *inkl = '1'
     C                   eval      $prtn  = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif

      *  Test for other command keys

     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

      *  Some other key pressed.

      *     Check input and write/update record.

     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *inzsr  Initialization subrotine
      *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
      *
      *   Call user added initialization routine.
      *
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     C                   parm      #prog         #pgmq2
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *   PIR9905  Cursor not in correct position for lookup.
      *
     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *      0105
      *
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *      0110 Number must be greater than zero
      *
     C     ZM0110        BEGSR
     C                   MOVE      'PIR0110'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *    PIR1001  Invalid option entered.
      *
     C     ZM1001        BEGSR
     C                   MOVE      'PIR1001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *    PIR1006  Invalid jobq option for view report option.
      *
     C     ZM1006        BEGSR
     C                   MOVE      'PIR1006'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  zzchk1   Screen 1 error checking.
      *
     C     zzchk1        begsr
     C                   eval      error = *off

      *  Verify warehouse code.

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = $lerm
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   endif
     C                   endif

      *  Verify warehouse department.

     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = 'ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = $lerm
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = $lerm
     C                   eval      #msgk = $lmsg
     C                   endif
     C                   endif
     C                   endif

      *  Verify variances flag.

     C                   if        w1adj <> 'Y' and
     C                             w1adj <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
     C                   endif

     C                   if        w1jobq <> 'Y' and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm1001
     C                   endif

      *  Verify default device

     C                   eval      work1a = w1dev
     C                   if        work1a =  '*'       and
     C                             w1dev  <> '*SYSVAL' and
     C                             w1dev  <> '*JOB'    or
     C                             w1dev  =   *blanks  or
     c                             work1a = *blank
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   endif

      *  Verify default form type

     C                   eval      work1a = w1form
     C                   if        work1a =  '*'    and
     C                             w1form <> '*STD' or
     C                             w1form =   *blanks or
     c                             work1a = *blank
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     C                   endif

     C     endck1        endsr
      *----------------------------------------------------------------
      *
      *  zzcmd1   User defined command keys for screen 1.
      *
     C     zzcmd1        begsr
     C                   MOVE      '0'           CMDTKN

      *  Test for F4 - Lookup

     C     *INKD         IFEQ      *ON
     C                   MOVE      *ON           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL

      *  Warehouse

     C                   SELECT
     C     CSRFLD        WHENEQ    'W1WHSE'
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   MOVE      #PROG         $LPRG
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   Z-ADD     $LWHSE        W1WHSE
     C                   ENDIF

      *     Department.

     C     CSRFLD        WHENEQ    'W1WHDP'
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   MOVE      W1WHDP        $LWHDP
     C                   CALL      'WD900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   MOVE      $LWHDP        W1WHDP
     C                   END

     C                   OTHER

      *     Cursor not on a valid lookup field.

     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   ENDIF

     C     ENDCM1        ENDSR
      *----------------------------------------------------------------
      *
      *  zzfil1   Fill screen 1 fields with info from file.
      *
     C     zzfil1        begsr
      *
      * Get device and form
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'IV161PR'     $lrpt
     C                   parm      0             $whse
     C                   parm      ' '           $styp
     C                   parm      ' '           $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form

     C                   eval      w1dev = $dev
     C                   eval      w1form = $form
     C                   eval      w1jobq = 'N'
     C                   eval      w1adj  = 'N'

     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.
      *
     C     zzinz         begsr

     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         #PGMQ

      * Get warehouse for user.

     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse

     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  zzinz2   Program initialization. Called from main line.
      *
     C     zzinz2        begsr

      *  Select first screen to display.

     C                   exsr      scr01i
     C                   endsr
      *----------------------------------------------------------------
      *
      *  zznxt1   What to do next when screen 1 input is ok.
      *
     C     zznxt1        BEGSR
     C                   MOVE      W1WHSE        $PWHSE
     C                   eval      $dept = w1whdp
     C                   MOVE      W1adj         $padj
     C                   MOVE      W1JOBQ        $PJOBQ
     C                   MOVE      W1DEV         $PDEV
     C                   MOVE      W1FORM        $PFORM
     C                   MOVE      '*OK     '    $PRTN
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZUPD1   Update IV161 with type for report.
      *
     C     zzupd1        begsr

     C     endup1        endsr
      *----------------------------------------------------------------
      *
      *  zzzfil   Move selected record fields to output.
      *
     C     zzzfil        begsr

     C                   endsr
      *----------------------------------------------------------------
      *
      *----------------------------------------------------------------
      *
      *  COMPILE TIME TABLES
      *
**
Section type
Adjustment flag
job queue option
printer device
form type
item
Minimum variance
