      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LT312     Licative FIFO Update
     *  17 July, 2009
     *  Chuck Manny
     *
     *  Revisions:
     *
     *    07/17/09  CWM  6.10
     *      - Created
     *
610a *    04/09/10  DAS  6.10a
     *      - Revised to allow changing Priority for RCV/STG slots.
     *      - Added F5 logic to SC1.
     *
640a *    01/10/12  DAS  6.40a
     *      - Revised %SETFIFO call to pass in item number, which is
     *        needed by DRILICENSE to get FIFO info for slot.
     *
640b *    05/23/12  RBD  6.40b
     *      - Fix: Revised %SETFIFO call to pass action, emp#,
     *        original license, and tran#, which are needed by
     *        DRILICENSE to write to LICLOG file.
640c *    10/03/12  RH   6.40c
     *      - Fix: Revised %SETFIFO set Trans parms = off if trans not
     *        found in license record, was causing decimal data error
     *        in DRISLOT.
640d *    11/19/12  DAS  6.40d
     *      - Remove LICENSE file from program. First, this file should
     *        not be used in any new programming. Second, the license
     *        log file should record the trans# of the action. Since
     *        changing the FIFO doesn't create a transaction no trn#
     *        should be sent.
     *      - Now we always send zero for trn# so we don't need to
     *        modify DRISLOT.
     *      - Added call to clr$Slot.
720a *    12/27/18  LMC  7.20a
     *      - Fix: edit for dates where the user has entered yymmdd
     *        instead of ccyymmdd.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: XXXXXX'x
     *      - Enh:
     *----------------------------------------------------------------
     *  Indicator usage                                              2
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     FLT312FM   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Flicactive if   e           k disk
640dDF*icense   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a3              s              1    dim(3)
     D a10             s              1    dim(10)
     D desc            s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Data structures for comparing original and current records.---
     *----------------------------------------------------------------

     D CURREC        E DS                  EXTNAME(LICACTIVE)
     D ORGREC        E DS                  EXTNAME(LICACTIVE)
     D                                     prefix(O_)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D usesc           s              1  0
     D warn            s               n
     D whse            s              3  0
     D w1entdc         s              8  0
     D w1expdc         s              8  0
     D dtchk           s              1
     D dfchk           s              1
     D expd            s              8  0
     D today           s              8  0
     D zmflag          s               n
     D zmsflag         s               n
     D client          s             10

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmnd                 1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D  $lcodeu               37     38
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $lwhs                 19     21  0
     D  $lwhd                 22     26
     D  $ldis                 27     38
     D  $litm                 39     53
     *
     D  $luser                19     28
     *
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  erdisp                16     27
     *
     D  ersdpt                28     32
     D  erstyp                33     33
     D  ersdsg                34     38
     *
     D  eridpt                39     43
     D  erityp                44     44
     D  eridsg                45     49
     *
     D  erslot                 1     12
     D  erstat                13     42
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
      /Copy qcopysrc,c#pgminfds
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
     *
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change FIFO Data.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY
     *
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pWhse            3 0
     C                   parm                    $pLcns           15
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     *
     C                   exsr      zzinz1
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
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
     *
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
610aDC**                 if        laaisl = 'RCV' or laaisl = 'STG'
610aDC**                 eval      $PCMD  = '*VIEW  '
610aDC**                 eval      *in90  = *on
610aDC**                 eval      error = *on
610aDC**                 eval      errmsg = desc(1)
610aDC**                 exsr      zm0105
610aDC**                 endif
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
     *
     C                   move      '01 '         nxtscr
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
     C                   exsr      zzLodRcdScr1
     C                   endif
     *
     C                   eval      ovrrid = *off
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
610aA*
610aA*  Test for F5 - Refresh
610aA*
610aAC                   if        *inke
610aAC                   exsr      zzlodrcdscr1
610aAC                   goto      endsc1
610aAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
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
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr
     *
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
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     *
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *----------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *                                 4
     *    ZMIMSG  Initialization necessary for message subfile
     *----------------------------------------------------------------
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

     *----------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr

     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif

     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg

     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *----------------------------------------------------------------
     *    PIR1002  Invalid date entered.
     *
     C     zm1002        begsr
     C                   eval      #msgid = 'PIR1002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1010  Date must be less than or equal to today
     *
     C     zm1010        begsr
     C                   eval      #msgid = 'PIR1010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZSCLR   Clear screen
     *----------------------------------------------------------------

     C     zsclr         begsr

     C                   write     clrscr
     C                   move      *on           sclear

     C                   endsr

     *----------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *----------------------------------------------------------------

     C     zmqmsg        begsr

     C                   add       1             msgk
     C                   write     msgrec

     C                   endsr

     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------

     C     zmsmsg        begsr

     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify Entered Date
610aA
610aA*    Entered date cannot be changed on a RCV/STG slot.
610aA
610aAC                   if        laaisl = 'RCV'
610aAC                             or laaisl = 'STG'
610aAC                   if        w2entd <> laentd
610aAC                   eval      error = *on
610aAC                   eval      *in26 = *on
610aAC                   eval      *in06 = *on
610aAC                   eval      errmsg = 'Entered date cannot be changed '
610aAC                                    + 'for RCV/STG slots'
610aAC                   exsr      zm0105
610aAC                   leavesr
610aAC                   endif
610aAC                   endif

     *    Entered date cannot be left blank.

     C                   if        w2entd = 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm1008
610aAC                   leavesr
     C                   endif

     *    Entered date greater than today

     C                   if        w2entd > today
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm1010
610aAC                   leavesr
     C                   endif
     *
     C                   if        w2entd <> 0
     C     *iso          Test(DE)                w2entd
     C                   if        %error
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1002
610aAC                   leavesr
     C                   endif
     C                   endif

720aA*    Verify entered date has century entered
720aAC                   if        w2entd <> 0
720aAC                   if        w2entd < 19000000
720aAC                   eval      error = *on
720aAC                   eval      *in26 = *on
720aAC                   eval      *in06 = *on
720aAC                   eval      errmsg = *blanks
720aAC                   exsr      zm1002
720aAC                   leavesr
720aAC                   endif
720aAC                   endif

     *  Verify Expiration Date.
610aA
610aA*    Expiration date cannot be changed on a RCV/STG slot.
610aA
610aAC                   if        laaisl = 'RCV'
610aAC                             or laaisl = 'STG'
610aAC                   if        w2expd <> laexpd
610aAC                   eval      error = *on
610aAC                   eval      *in27 = *on
610aAC                   eval      *in07 = *on
610aAC                   eval      errmsg = 'Expire date cannot be changed '
610aAC                                    + 'for RCV/STG slots'
610aAC                   exsr      zm0105
610aAC                   leavesr
610aAC                   endif
610aAC                   endif

     C                   if        w2expd <> 0

     *    Verify expired date (optional)

     C     *iso          Test(DE)                w2expd
     C                   if        %error
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1002
610aAC                   leavesr
     C                   endif
     C                   endif

720aAC                   if        w2expd <> 0
720aA*    Verify expired date has century entered
720aAC                   if        w2expd < 19000000
720aAC                   eval      error = *on
720aAC                   eval      *in27 = *on
720aAC                   eval      *in07 = *on
720aAC                   eval      errmsg = *blanks
720aAC                   exsr      zm1002
720aAC                   leavesr
720aAC                   endif
720aAC                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     C                   reset                   screen1
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *           Fill Maint Screen with LICACTIVE select record
     *
     C     zzLodRcdScr1  begsr
     *
     *   Load Screen Fields
     *
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      *OFF          *IN90
     C                   ELSE
     C                   MOVE      *ON           *IN90
     C                   ENDIF
     C*
     C*   Get LICACTIVE Record
     C*
     C     actlickey     chain     licactive
     C                   if        %found(licactive)
     C                   movel     currec        orgrec
     C*
     C                   eval      w2whse = $pwhse
     C                   eval      w2lcns = $plcns
     C*
     C                   eval      w2Disp = laDisp
     C                   eval      w2Item = laItem
     C*
     C                   eval      w2qty1 = laqty1
     C                   eval      w2qty2 = laqty2
     C                   eval      w2qty3 = laqty3
     C*
     C                   eval      w2ityp = laitype
     C                   eval      w2code = lacode
     C                   eval      w2aisl = laaisl
     C                   eval      w2loc  = laloc
     C                   eval      w2lvl  = larlvl
     C                   eval      w2hand = lahand
     C                   eval      w2area = laarea
     C                   eval      w2whdp = lawhdp
     C                   eval      w2pos  = lapos
     C                   eval      w2ord  = laord
     C                   eval      w2seq  = laseq
     C                   eval      w2entd = laentd
     C                   eval      w2expd = laexpd
     C                   eval      w2emus = lachgeusr
     C                   eval      w2crus = lachgcusr
     C                   eval      w2cjus = lachgjusr
     C                   eval      w2cgem = lachgemp
     C                   eval      w2cgpg = lachgpgm
     C                   eval      w2cgjb = lachgjob
     C                   eval      w2cgjn = lachgnbr
     C                   eval      w2chgu = lachguc
     C                   eval      w2chgt = lachgts
     C                   eval      w2prty = -(laprty)
     C                   eval      w2sity = lasitype
     C                   eval      w2olcn = laolcns
     C                   eval      w2sitm = lasitem
     C                   eval      w2base = labase
     C                   endIf
     C*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C*
     C*  Define key for License Log File
     C*
     C     actlickey     klist
     C                   kfld                    $pWhse
     C                   kfld                    $pLcns
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     C                   move      '0'           dfchk
     C                   move      '0'           dtchk
     *
     *   Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #curruser
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
640dDC**                 eval      $saEmp#u   = *on
640dDC**                 eval      $saEmp#    = #emp#
     *
     *   Process Maintenance Screen
     *
     C                   exsr      scr01i
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update slot and licactive records
     *
     C     zzupd1        begsr
     *
     C                   move      *off          error

     *   Load Interface Fields

640dD **    Get license tran#
640dDC**   actlickey     chain     license
640dDC**                 if        %found(license)
640dDC**                 eval      $satrn#u = *on
640dDC**                 eval      $satrn#  = litrn#
640dDC**                 else
640dDC**                 eval      $satrn#u = *off
640dDC**                 eval      $satrn#u = *on
640cDC**                 eval      $satrn#  = 0
640dDC**                 endif

640dAC                   exsr      clr$slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w2whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w2whdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w2disp
640aAC                   eval      $slitemu = *on
640aAC                   eval      $slitem  = w2item
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w2expd
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = w2entd
     C                   eval      $slprtyu = *on
     C                   eval      $slprty  = -(w2prty)
     C                   eval      $saToLcnsu = *on
     C                   eval      $saToLcns  = w2lcns
640bAC                   eval      $saActionu = *on
640bAC                   eval      $saAction  = 'FIF'
640bAC                   eval      $saOLcnsu  = *on
640bAC                   eval      $saOLcns   = w2olcn
640dAC                   eval      $saEmp#u   = *on
640dAC                   eval      $saEmp#    = #emp#
640dAC                   eval      $satrn#u = *on
640dAC                   eval      $satrn#  = 0

     C                   eval      $dricommand = '*SLOT   '
     C                   eval      $drisubcmd  = '%SETFIFO'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C*
     C                   if        error
     C                   endif
     C*
     C     endupd1       endsr


    A*----------------------------------------------------------------
    A*----------------------------------------------------------------
    A*                     DRI SUBROUTINES
    A*----------------------------------------------------------------
    A*----------------------------------------------------------------


    A*----------------------------------------------------------------
    A*  clr$Slot   Clear $slot data structure fields
    A*----------------------------------------------------------------
    A
    AC     clr$Slot      begsr

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2

     C                   endsr

     *----------------------------------------------------------------
     *  fill$slotadd  Fill $slot data structure fields for *ADD
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr

     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT   '
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*SLOT   '
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   else

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     *  Process any returned error conditions

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   exsr      zm0001
     C                   endsl

     C                   endsl


     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      errmsg   = 'U:' + #status + '/'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   exsr      zm0105s
     C                   eval      *inlr = *on
     C                   return

     C     endpssr       endsr


     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------
**
Can not change RCV or STG slot
