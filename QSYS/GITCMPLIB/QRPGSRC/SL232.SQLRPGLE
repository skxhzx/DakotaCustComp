     *----------------------------------------------------------------
     *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL232     Change status for a group of slots
     *  Hemant Kapadia
     *
     *  Revisions
     *
214 A*    07/15/96  RH  V2.14
     *      - Add from status field, allow to change from any status
     *      - Display # of slots changed & # unable to change.
     *      - Unable to change if any qty <> 0, changes all others.
411 A*    06/04/99  RH  V4.11
     *      - Allow status to change to 'A' if all qty = 0.
412 A*    08/19/99  HNK V4.12
     *      - Level added.
740aA*    11/30/20  RH  7.40a
     *      - Enh: Allow valid code from status table
     *      - Converted to ILE
     *
     *----------------------------------------------------------------
     *  Notes
     *       The format for this program needs to be compiled with
     *       DFRWRT=*NO so that status messages can be displayed.
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT LOG NUMBER)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fsl232fm   cf   e             workstn
     F                                     infds(infds)
740aAFslotstat  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(3) ctdata perrcd(1)
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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  ercnt                  1      3p 0
214 AD  cgcnt                  4      6p 0
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
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D asle            s              3
     D cmdchk          s              8
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D loc             s              3  0
     D nxtscr          s              3
     *R SLALC2 <> 0   s          OR
     *R SLPCK3 <> 0   s          OR
     *R SLSTK3 <> 0   s          OR
     *R SLTFR3 <> 0   s          OR
     D sclear          s              1
     D warn            s              1
     D whdp            s              5
     D w1cnt           s              5  0
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
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   exsr      zmcpmq
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
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
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
    MC                   exsr      zmcpmq
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record.
     *
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   exsr      zzfil3
     C     end03i        endsr
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
     C                   exsr      zznxt1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     *R         *INKC     IFEQ *ON
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC2
     *R                   END
     *
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *
     *  Test for other command keys AFTER verification and update.
     *
     *R                   MOVE '*AFTER  'CMDCHK
     *R                   EXSR ZZCMD2
     *R         CMDTKN    CABEQ*ON       ENDSC2
     *
     *  Everything went fine so get out of program.
     *
     *R                   MOVE 'EOJ'     NXTSCR
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     *R         *INKC     IFEQ *ON
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC3
     *R                   END
     *
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *
     *  Test for other command keys AFTER verification and update.
     *
     *R                   MOVE '*AFTER  'CMDCHK
     *R                   EXSR ZZCMD3
     *R         CMDTKN    CABEQ*ON       ENDSC3
     *
     *  Everything went fine so get out of program.
     *
     *R                   MOVE 'EOJ'     NXTSCR
     C     endsc3        endsr
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
    D*                    EXSR ZMIMSG
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL23201  Invalid status code entered.
     *
     C     zm2301        begsr
     C                   eval      #msgid = 'SL23201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL23202  Cannot change status, active slots in group selected
     *
     C     zm2302        begsr
     C                   eval      #msgid = 'SL23202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL23203  Slot status changed.
     *
     C     zm2303        begsr
     C                   eval      #msgid = 'SL23203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL23204  Checking for active slots (Info msg)
     *
     C     zm2304        begsr
     C                   eval      #msgid = 'SL23204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL23205  Changing records (Info msg)
     *
     C     zm2305        begsr
     C                   eval      #msgid = 'SL23205'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
214 A*   SL23206  Can not change from status A.
214 A*
214 AC     zm2306        begsr
214 AC                   eval      #msgid = 'SL23206'
214 AC                   eval      #msgtp = '*DIAG  '
214 AC                   movea     errmsg        $md
214 AC                   exsr      zmpmsg
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
    D**                   EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     *  Verify warehouse department code.
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
    D**                   EXSR ZMQMSG
     C                   endif
     C                   endif
     C                   endif
     *
     *    Make sure aisle was entered.
     *
     C                   if        w1asle = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify slot location is within range.
     *
     C                   if        w1floc < 1  or
     C                             w1floc > 999  or
     C                             w1tloc <= 0  or
     C                             w1tloc < w1floc
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
412 A*  Verify slot location is within range.
     *
412 AC                   if        w1flvl < 1  or
412 AC                             w1flvl > 99  or
412 AC                             w1tlvl <= 0  or
412 AC                             w1tlvl < w1flvl
412 AC                   eval      error = *on
412 AC                   eval      *in28 = *on
412 AC                   eval      *in29 = *on
412 AC                   eval      *in08 = *on
412 AC                   eval      errmsg = *blanks
412 AC                   movel     desc(3)       erfld
412 AC                   movel     '1'           erfrom
412 AC                   movel     '99'          erto
412 AC                   exsr      zm0112
412 AC                   endif
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      whdp = w1whdp
     C                   endif
     *
     C                   if        w1asle <> '*ALL '
     C                   move      w1asle        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         asle
     C                   endif
     *
     C                   eval      loc = w1floc
     *
     *  New status code must be 'I', 'V', 'Z'
740aA*  New status code must be valid in Status Table
     *
740aAC     w1stat        chain     slotstat                           79
740aAC                   if        *in79
740aD*R         W1STAT    IFNE 'I '
740aD*R         W1STAT    ANDNE'V '
740aD*R         W1STAT    ANDNE'Z '
740aD*R         W1STAT    ANDNE'A '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm2301
     C                   endif
     *
214 A*
214 A*  From status code can not be 'A'
214 A*
214 D*R         W1FSTS    IFEQ 'A '
214 D*R                   MOVE *ON       ERROR
214 D*R                   MOVE *ON       *IN27
214 D*R                   MOVE *ON       *IN07
214 D*R                   MOVE *BLANKS   ERRMSG
214 D*R                   EXSR ZM2306
214 D*R                   ENDIF
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C     endck3        endsr
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
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
     C                   when      row# = 9
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - continue
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = '03 '
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F22 - continue
     *
     C                   if        *inkw
     *
     *  Put out info message.
     C                   exsr      zm2304
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   eval      w1cnt = 0
     C                   exsr      zzsel
214 D*R         W1CNT     IFGT 0
214 D*R                   MOVE *ON       ERROR
     C                   eval      ercnt = w1cnt
214 D*R                   EXSR ZM2302
214 D*R                   MOVE *ON       CMDTKN
214 D*R                   MOVE '01 '     NXTSCR
214 D*R                   GOTO ENDCM3
214 D*R                   ENDIF
     *
     *  Put out info message.
     C                   exsr      zm2305
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   eval      w1cnt = 0
     C                   exsr      zzcnt
     C                   exsr      zzchg
     C                   eval      error = *on
214 MC                   eval      cgcnt = w1cnt
     C                   exsr      zm2303
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = '01 '
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *  ZZCNT    Count records to be changed.
     C     zzcnt         begsr
     *
     *   *ALL *ALL
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse  = :w1whse)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE CODE
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse = :w1whse)
     C+         and (slwhdp = :whdp)
     C+         and (slaisl = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
213 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   *ALL CODE
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse = :w1whse)
     C+         and (slaisl = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE *ALL
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse = :w1whse)
     C+         and (slwhdp = :whdp)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     C     endcnt        endsr
     *----------------------------------------------------------------
     *  ZZCHG    Change slot status
     C     zzchg         begsr
     *
     *   *ALL *ALL
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  update slot1
     C+  set slstat = :w1stat
     C+  where      (slwhse  = :w1whse)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE CODE
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  update slot1
     C+  set slstat = :w1stat
     C+  where      (slwhse  = :w1whse)
     C+         and (slwhdp  = :whdp)
     C+         and (slaisl  = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   *ALL CODE
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  update slot1
     C+  set slstat = :w1stat
     C+  where      (slwhse  = :w1whse)
     C+         and (slaisl  = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM  = ' ')
     C+         and (slstk1  = 0)
     C+         and (slstk2  = 0)
     C+         and (slstk3  = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE *ALL
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  update slot1
     C+  set slstat = :w1stat
     C+  where      (slwhse = :w1whse)
     C+         and (slwhdp = :whdp)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
214 D*         AND (SLITEM = ' ')
     C+         and (slstk1 = 0)
     C+         and (slstk2 = 0)
     C+         and (slstk3 = 0)
411 AC+         and (slalc1  = 0)
411 AC+         and (slalc2  = 0)
411 AC+         and (slalc3  = 0)
411 AC+         and (sltfr1  = 0)
411 AC+         and (sltfr2  = 0)
411 AC+         and (sltfr3  = 0)
411 AC+         and (slpck1  = 0)
411 AC+         and (slpck2  = 0)
411 AC+         and (slpck3  = 0)
411 AC+         and (slrcv1  = 0)
411 AC+         and (slrcv2  = 0)
411 AC+         and (slrcv3  = 0)
     C/END-EXEC
     *
     C                   endif
     *
     C     endchg        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1whse = 0
     C                   eval      w1whdp = *blanks
     C                   eval      w1asle = *blanks
     C                   eval      w1floc = 0
     C                   eval      w1tloc = 0
412 AC                   eval      w1flvl = 0
412 AC                   eval      w1tlvl = 0
214 AC                   eval      w1fsts = *blanks
     C                   eval      w1stat = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     *
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      #pgmq = #prog
     C                   eval      $lprg = #prog
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
     *
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   exsr      scr02i
     *
     C     endnx1        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT2   What to do next when screen 2 input is ok.
     *
     C     zznxt2        begsr
     *
     C     endnx2        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT3   What to do next when screen 3 input is ok.
     *
     C     zznxt3        begsr
     *
     C     endnx3        endsr
     *
     *----------------------------------------------------------------
     C     zzsel         begsr
     *
     *   *ALL *ALL
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse  = :w1whse)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
     C+         and (slstk1 <> 0 or slstk2 <> 0 or slstk3 <> 0 or
411 AC+              slalc1 <> 0 or slalc2 <> 0 or slalc3 <> 0 or
411 AC+              sltfr1 <> 0 or sltfr2 <> 0 or sltfr3 <> 0 or
411 AC+              slpck1 <> 0 or slpck2 <> 0 or slpck3 <> 0 or
411 AC+              slrcv1 <> 0 or slrcv2 <> 0 or slrcv3 <> 0)
411 D*         AND (SLSTK1 <> 0 OR SLSTK2 <> 0 OR SLSTK3 <> 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE CODE
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse  = :w1whse)
     C+         and (slwhdp  = :whdp)
     C+         and (slaisl  = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
411 MC+         and (slstk1 <> 0 or slstk2 <> 0 or slstk3 <> 0 or
411 AC+              slalc1 <> 0 or slalc2 <> 0 or slalc3 <> 0 or
411 AC+              sltfr1 <> 0 or sltfr2 <> 0 or sltfr3 <> 0 or
411 AC+              slpck1 <> 0 or slpck2 <> 0 or slpck3 <> 0 or
411 AC+              slrcv1 <> 0 or slrcv2 <> 0 or slrcv3 <> 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   *ALL CODE
     *
     C                   if        w1whdp = '*ALL '  and
     C                             w1asle <> '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse  = :w1whse)
     C+         and (slaisl  = :asle)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
411 MC+         and (slstk1 <> 0 or slstk2 <> 0 or slstk3 <> 0 or
411 AC+              slalc1 <> 0 or slalc2 <> 0 or slalc2 <> 0 or
411 AC+              sltfr1 <> 0 or sltfr2 <> 0 or sltfr3 <> 0 or
411 AC+              slpck1 <> 0 or slpck2 <> 0 or slpck3 <> 0 or
411 AC+              slrcv1 <> 0 or slrcv2 <> 0 or slrcv3 <> 0)
     C/END-EXEC
     *
     C                   endif
     *
     *   CODE *ALL
     *
     C                   if        w1whdp <> '*ALL '  and
     C                             w1asle = '*ALL '
     C/EXEC SQL
     C+  select count(*) into :w1cnt
     C+  from   slot1
     C+  where      (slwhse  = :w1whse)
     C+         and (slwhdp  = :whdp)
     C+         and (slloc  >= :w1floc and slloc  <= :w1tloc)
412 AC+         and (slrlvl  >= :w1flvl and slrlvl  <= :w1tlvl)
214 AC+         and (slstat  = :w1fsts)
411 MC+         and (slstk1 <> 0 or slstk2 <> 0 or slstk3 <> 0 or
411 AC+              slalc1 <> 0 or slalc2 <> 0 or slalc2 <> 0 or
411 AC+              sltfr1 <> 0 or sltfr2 <> 0 or sltfr3 <> 0 or
411 AC+              slpck1 <> 0 or slpck2 <> 0 or slpck3 <> 0 or
411 AC+              slrcv1 <> 0 or slrcv2 <> 0 or slrcv3 <> 0)
     C/END-EXEC
     *
     C                   endif
     *
     C     endsel        endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Slot location
Slot level
