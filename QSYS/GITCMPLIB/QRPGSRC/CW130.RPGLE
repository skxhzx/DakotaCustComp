      *----------------------------------------------------------------
      *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  CW130     Scan pallet license plate prompt for UCI entry
      *  Jeffrey Jahnke
      *  14 June, 2006
      *
      *  Revisions
      *
510 A *    06/12/06  JJ   5.10
      *      - Created.
      *
510aA *    06/12/06  JJ   5.10a
      *      - added Transaction number to *entry plist
      *
510bA *    11/05/06  JCJ  5.10b
      *      - added F3 and F12 Functions key processing
      *
510cA *    10/23/07  JCJ  5.10c
      *      - removed F3 and F12 Functions key processing
      *
510dA *    11/01/07  JCJ  5.10d
      *      - Fix: changed receiving transaction parm.
      *
      *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fcw130fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fucicw2    if   e           k disk    rename(ucirec:record)
     Flicense   if   e           k disk
     Fpirtran   if   e           k disk
      *----------------------------------------------------------------
      *  Table and array definitions

510 AD lcns            s             15    dim(500)
     D desc            s             50    dim(01) ctdata perrcd(1)
      *----------------------------------------------------------------
      *  Called programs
      *
      *----------------------------------------------------------------
      *  Program parameters

     D $lparm          DS
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $liky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     D  $mtype                81     88
     *
     D  $mwhs2                19     20P 0
     D  $mpo2                 21     29
     D  $mseq                 30     32P 0
     D  $mitem                33     47
     D  $mqyr1                48     50P 0
     D  $mqyr2                51     53P 0
     D  $mqyr3                54     56P 0
     D  $mcwte                57     59P 0
     D  $mcwtt                60     64P 2
     D  $mcwta                65     68P 2
      *----------------------------------------------------------------
      *  Data structure for error message parameters

     D $mdt            DS
     D  errmsg                 1     50

      *----------------------------------------------------------------
      *  Message control

     D #msgf           C                   CONST('PIRMSGF   ')

     D                 DS
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)
     *----------------------------------------------------------------
     *  Called programs

     D @cwght          c                   const('CW132')

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
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure

     D                 DS
     D  row#                   1      2B 0
     D  row                    2      2
     D  col#                   3      4B 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s              5
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $prcvd          S              8  0
     D $pexpd          S              8  0
510aAD $portrn         S              7  0
     D $pseq           S              5  0
     D msgk            S              4  0
     D i               S              3  0
     D e               S              2  0
     D $woitem         S             65
     D $cstr           S             30
     D $plotc          S             30
     D $msgf           S             10
     D $ccmd           S              8
     D #msgid          S              7
     D #msgtp          S              7
     D nxtscr          S              3
     D warn            S              1
     D error           S              1
     D cmdtkn          S              1
     D forevr          S              1
     D finished        S              1
     D sclear          S              1

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      None
      *
      *    Returned Parameters
      *      $PWHSE  Warehouse
      *      $PRTN   *EXIT    - CMD3 was entered
      *              *CANCEL  - CMD12 was entered
      *
      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $woitem
     C                   parm                    lcns
     C                   parm                    $pseq
     C                   parm                    $pexpd
     C                   parm                    $plotc
     C                   parm                    $prcvd
510aAC                   parm                    $portrn
      *----------------------------------------------------------------
      *  Main line

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C                   select
     C                   when      nxtscr = '01 '
     C                   exsr      sc1
     C                   endsl
     C                   enddo

      *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *  DSPSCR - Display screen

     C     dspscr        begsr

      * Set ON alarm indicator if error occured

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
     C                   eval      cmdtkn = *off
     C                   eval      e = *zeros

      *   Initialize error subfile

     C                   exsr      zmcpmq

     C                   endsr
      *----------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *----------------------------------------------------------------
      *
      *  Screen 01 initialization

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
      *
      *  SC1  -  Screen 1

     C     sc1           begsr

      *  Test for F3 - Exit

     C                   if        *inkc = *on
510cD ***                eval      $prtn = '*EXIT   '
510cD ***                eval      nxtscr = 'EOJ'
510cD ***                goto      endsc1
     C                   endif

      *  Test for F5 - Refresh

     C                   if        *inke = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif

      *  Test for F12 - Previous

     C                   if        *inkl = *on
510cD ***                eval      $prtn = *blanks
510cD ***                eval      NxtScr = 'EOJ'
510cD ***                goto      endsc1
     C                   endif

      *  Test for other command keys

     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

      *  Some other key pressed.

      *     Check input and write/update record.

     C                   exsr      zzchk1
     C                   if        error <> *On and w1lcns <> *blanks
     C                   exsr      zznxt1
     C                   endif

     C     endsc1        endsr
      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
      *  Initialize message handling
      *

      *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZMCPMQ  Clear program message queue.

     C     zmcpmq        begsr
     C                   eval      msgk = *Zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZMDMSG  Display message record subfile

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZMPMSG  Add message record to subfile

     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   CALL      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
      *----------------------------------------------------------------
      *
      *    ZSCLR   Clear screen
      *
     C     zsclr         begsr
     C                   eval      sclear = *on
     C                   endsr
      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *
      *    PIR9901  Invalid date entered.
      *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *    PIR9905  Cursor not in correct position for lookup.
      *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $MD = *blanks
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *    PIR9906  Invalid date entered.
      *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $MD(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *      0105
      *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *    PIR1001  Invalid option entered.
      *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *    PIR1006  Invalid jobq option for view report option.

     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
      *----------------------------------------------------------------
      *  ZZCHK1   Screen 1 error checking.

     C     zzchk1        begsr

     C                   eval      error = *off

     * Verify user scanned license# from receiving list

     C     w1lcns        lookup    lcns(1)                                80
     C                   if        *in80 = *off
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif

     C     endck1        endsr
      *----------------------------------------------------------------
      *
      *  zzcmd1   User defined command keys for screen 1.

     C     zzcmd1        begsr
     C                   eval      cmdtkn = '0'

     C     endcm1        endsr
      *----------------------------------------------------------------
      *
      *  ZZFIL1   Fill screen 1 fields with info from file.

     C     zzfil1        begsr

     C                   endsr

      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

     C                   eval      $lprg = #prog
     C                   eval      #pgmq = #prog

      *  Define full key for detail file.

     C     uciky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    lcns(i)

      *  Define partial key for license file.

     C     lcnkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns

      *  Define key for pirtran file.

     C     trnkey        klist
     C                   kfld                    litrn#

     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ2   Program initialization. Called from main line.
      *
     C     zzinz2        begsr

     *   Get warehouse description.

     C                   eval      whdesc = *blanks
     C                   eval      $cstr = *blanks

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr

     *   Put warehouse and department together.

     C                   eval      whdesc = %trim($cstr) + '-'
     C                                    + %trim($vdesc)

     C                   eval      w1po = $ppo
     C                   eval      woitem = $woitem

      *   Select first screen to display.

     C                   exsr      scr01i
     C                   endsr
      *----------------------------------------------------------------
      *
      *  ZZNXT1   What to do next when screen 1 input is ok.
      *
     C     zznxt1        begsr

     C                   eval      ptpcs = *zeros
510dAC                   eval      litrn# = *zeros
     C     lcnkey        chain     license
     C                   if        %found(license)
     C     trnkey        chain     pirtran
     C                   if        %found(pirtran)
     C                   endif
     C                   endif

     C                   eval      $mcmd = '*ADD     '
     C     lcnkey        chain     ucicw2
     C                   if        %found(ucicw2)
     C                   eval      $mcmd = '*CHANGE  '
     C                   endif

     C                   eval      $mwhs2 = $pwhse
     C                   eval      $mpo2  = $ppo
     C                   eval      $mseq  = $pseq
     C                   eval      $mitem = $pitem
     C                   eval      $mqyr1 = ptpcs
     C                   eval      $mqyr2 = *zeros
     C                   eval      $mqyr3 = *zeros
     C                   eval      $mcwte = *zeros
     C                   eval      $mcwtt = *zeros
     C                   eval      $mcwta = *zeros
     C                   call      @cwght
     C                   parm                    $mparm
     C                   parm                    w1lcns
     C                   parm                    $pexpd
     C                   parm                    $plotc
     C                   parm                    $prcvd
510dD ***                parm                    $portrn
510dMC                   parm                    litrn#

     C                   eval      i = 1
     C                   eval      finished = 'Y'
     C                   dow       forevr = forevr
     C                   if        lcns(i) = *blanks
     C                   leave
     C                   endif

     C     uciky2        chain     ucicw2
     C                   if        not %found(ucicw2)
     C                   eval      finished = 'N'
     C                   leave
     C                   endif
     C                   eval      i = i + 1
417bAC                   enddo

     C                   eval      w1lcns = *blanks
     C                   if        finished = 'Y'
     C                   eval      $prtn  = '*OK'
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   endsr
      *----------------------------------------------------------------
      *
      *  COMPILE TIME TABLES
      *
**
license number
