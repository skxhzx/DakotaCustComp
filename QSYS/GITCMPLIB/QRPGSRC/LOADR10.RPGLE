     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LOADR10   RF Loader Module - Clear Flag thru pick Label scanning
     F*  December 14, 2006
     F*  Jose G. Duque
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*      11 X 20 Screens for hand held scanners
     F*
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    04/01/09  RBD  5.20
     *      - Enh: Added error checking logic to ensure that the
     *        runner label has been picked and closed.
     *      - Removed call to RU310B.
     *      - Added call to LOADR11.
     *
520aA*    09/23/09  RBD  5.20a   P#00221
     *      - If called from RU310, display 'F8=Return' rather
     *        than 'F3=Exit'.
     *
530aA*    09/10/10  RBD  5.30a
     *      - Enh: increase label entry to 10 positions for Trax.
     *      - Changed scrn fmt to LOADR1001.
     *
700aA*    10/19/15  RBD  7.00a
     *      - Enh: added client custom code support.
     *
710aA*    09/14/17  RBD  7.10a
     *      - Call RU310 instead of RU310B because we've merged
     *        RU310B into RU310 and discontinued RU310B.
     *
720aA*    05/25/18  RBD  7.20a
     *      - Pass label number to RU310, will need it in RU310 if
     *        user scans label rather than transaction.
     *      - Add return parm to RU310 for error message in case RU310
     *        errors out.
     *
730 A*    07/23/19  MLB  7.30
     *      - Fix: Revised ZZCHK1 to add check for Runner Flag status
     *        S=Staged. If S=Staged, client uses Loader Module.
     *
750aA*    08/18/21  RBD  7.50a
     *      - Only verify runner flag exists if this is NOT a
     *        substitute item.
     *      - Only verify runner flag closed if new runner option
     *        opscnl "Scan short to Loader required before clearing
     *        runner flag" is N and this is NOT a substitute item.
     *      - Fix: blank label on screen1 when returning from call
     *        to Loadr11 and return cmd is *OK.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
CBIaA*    10/19/15  RBD  CBIa
     *      - Reversed some 520 mods by re-enabling call to RU310B and
     *        ignoring call to LOADR11 if Cheney.  Cheney calls RU310B
     *        (their version of RU310) from this pgm, however, Dakota was
     *        changed years ago to call LOADR10 from RU310 if the user
     *        presses F8=Load.  When time permits RU310B mods should be
     *        merged into RU310 as CBI mods, then change this pgm to call
     *        RU310 instead of RU310B, then say bye-bye to RU310B.  The
     *        reason we changed it in Dakota to call LOADR10 from RU310
     *        instead of the other way around like Cheney, is because
     *        all of our clients don't use the Loader Module, but for
     *        those that do, they can get here by pressing F8=Load
     *        from RU310.
     *
     *----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
530aDF*LOADR10FM CF   E             WORKSTN
530aMFLOADR1001 CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FRUNNER6   IF   E           K DISK
520 AFLABEL     IF   E           K DISK
750aAFoptions   if   e           k disk
750aAFordd      if   e           k disk
     *----------------------------------------------------------------
700aA*  Client ID's
700aA*
CBIaA /copy qcopysrc,id#cheney
CLD A /copy qcopysrc,id#citylin
700aA*
700aAD @getcl          c                   const('GETCLIENT')
     *
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
520 DD*DESC            S             50    DIM(1) CTDATA PERRCD(1)
520 MD DESC            S             50    DIM(2) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
530aAD @cvtbarsel      c                   const('CVTBARSEL')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
520 AD $PARMS          DS
520 AD  $PWHSE                 1      3  0
520 AD  $PRTID                 4      8
520 AD  $PLID                  9     15  0
520 AD  $PLBL                 16     22  0
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LCODE                22     29
     D*
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D*                                   P   1   20ERWHSE
     D*
     D  ERFLD                  1     30
     D*
     D  ERQTY                  1      4P 0
     D  ERNQTY                 5      8P 0
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4

750aA*----------------------------------------------------------------
750aA*  *RUNNER  -  PIR Runner Flag Options
750aA*----------------------------------------------------------------
750aA*
750aA* Fields
750aA*
750aA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
750aA*    OPUPLR  -  Update Label with quantity shorted during manual
750aA*               flag entry (Y/N)
750aA*               NOTE: Any change to this field will cause OPUPLV
750aA*                     in the *VOICE options record to be updated.
750aA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
750aA*               & create Priority Replenishment if necessary.
750aA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
750aA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
750aA*    OPRNRM  -  Send break message to user when new Runner
750aA*               task has been assigned. (Y/N)
750aA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
750aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
750aA*    OPRPCK  -  Print Runner pick list. (Y/N)
750aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
750aA*               printer, 2=Belt printer
750aA*    OPRBDU  -  Allow shorts to be filled with breakdown units. (Y/N)
750aA*    OPRSCN  -  Scan tran# or label# to start pick.
750aA*                 1=tran#, 2=label#.
750aA*    OPRVFS  -  Verify pick slot, Y/N.
750aA*    OPRVFQ  -  Verify qty found, Y/N.
750aA*    OPRLOA  -  Using loader module, Y/N.
750aA*    OPSCNL  -  Scan short to loader required before
750aA*               clearing runner flag, Y/N.
750aA*
750aA* Data structure
750aA*
750aAD oprdta          ds
750aAD  opcrtm                 1      1
750aAD  opuplr                 2      2
750aAD  oprplf                 3      3
750aAD  opmrgf                 4      4
750aAD  opclrf                 5      5
750aAD  oprnrm                 6      6
750aAD  opclsf                 7      7
750aAD  opoutf                 8      8
750aAD  oprpck                 9      9
750aAD  oprlbl                10     10
750aAD  oprbdu                11     11
750aAD  oprscn                12     12
750aAD  oprvfs                13     13
750aAD  oprvfq                14     14
750aAD  oprloa                15     15
750aAD  opscnl                16     16
750aAD  optendr              117    117

      *----------------------------------------------------------------
520aA *  Variables
      *
520aAD @Caller         S             10
520aAD @Counter        S             15  5
530aAD w1lbl#          s              7  0
720aAD $emsg           S             50
750aAD subItem         S              1
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------

520aAC     UI866P        Plist
520aAC                   Parm                    @Caller
520aAC                   Parm                    @Counter

     C*----------------------------------------------------------------
     C*  Main line
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      ZZINZ2
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   SETON                                        LR
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*----------------------------------------------------------------
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   ELSE
     C                   MOVE      *ON           *IN02
     C                   ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     C                   select
     C                   when      nxtscr = '01 '
     C                   EXFMT     SCREEN1                              50
     C*
     C                   ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       010203
     C                   SETOFF                                       040506
     C                   SETOFF                                       070809
     C                   SETOFF                                       101112
     C                   SETOFF                                       131415
     C                   SETOFF                                       161718
     C                   SETOFF                                       1920
     C                   SETOFF                                       212223
     C                   SETOFF                                       242526
     C                   SETOFF                                       272829
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       9298
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   MOVE      *OFF          REDSPL            1
     C                   Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*  Screen 01 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZFIL1
     C                   MOVE      *OFF          REFRSH            1
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*  SC1  -  Screen 1
     C*----------------------------------------------------------------
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
520aAC     *INKH         OREQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   MOVE      *ON           REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C
     C*
CBIaAc                   if        client = cheney
     C*
520 DC*  Pgm 'RU310B' is a copy, with minor mods, of Pgm 'RU310'
     C*
710aDC**                 CALL      'RU310B'
710aMC                   CALL      'RU310'
CBIaMC                   PARM                    RUTRN#
720aAC                   parm                    w1lbl#b
720aAC                   parm                    $emsg
720aAC     $emsg         ifne      *blanks
720aAC                   eval      error = '1'
720aAC                   eval      *in21 = '1'
720aAC                   eval      *in01 = '1'
720aAC                   eval      errmsg = $emsg
720aAC                   exsr      zm0105
720aAc                   endif
CBIaAc                   else
     C*
520 DC**   ERROR         CABEQ     *ON           ENDSC1
     *
520 A*  Call LOADR11 to load cleared flag item onto trailer.
     *
520 AC                   eval      $pwhse = lbwhse
520 AC                   eval      $prtid = lbrte
520 AC                   eval      $plid  = lbpal#
520 AC                   eval      $plbl  = lblbl#
520 AC                   call      'LOADR11'
520 AC                   parm                    $parms
520 AC                   parm      #prog         pprg             10
520 AC                   parm      ' '           rtncd             8

750aAc                   if        rtncd = '*OK'
750aAc                   eval      w1lbl#b = ' '
750aAc                   endif
     *
CBIaAc                   endif
     *
     C                   EXSR      SCR01I
     C
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
700aA*
700aA*  Get Client ID
     *
700aAC                   call      @getcl
700aAC                   parm                    client           10
     *
     C*
     C*  Initialize special keys
     C*
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*----------------------------------------------------------------
     C*    ZMCMSG  Clear message record subfile
     C*----------------------------------------------------------------
     C*
     C     ZMCMSG        BEGSR
     C                   MOVE      *OFF          *IN97
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK              4 0
     C                   WRITE     MSGCLR
     C                   MOVE      '*CLEAR '     #MSGID            7
     C                   MOVE      '*NULL  '     #MSGTP            7
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMDMSG  Display message record subfile
     C*----------------------------------------------------------------
     C*
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
     C     MSGK          IFGT      0
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK
     C                   END
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMIMSG  Initialization necessary for message subfile
     C*----------------------------------------------------------------
     C*
     C     ZMIMSG        BEGSR
     C                   MOVE      #PROG         #PGMQ            10
     C                   EXSR      ZMCMSG
     C                   ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     C     ZMPMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM                    #PGMQ
     C                   PARM                    #MSGK
     C     #MSGID        IFNE      '*CLEAR '
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   END
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZSCLR   Clear screen
     C*----------------------------------------------------------------
     C*
     C     ZSCLR         BEGSR
     C                   WRITE     CLRSCR
     C                   MOVE      *ON           SCLEAR            1
     C                   ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C     ZMQMSG        BEGSR
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     C     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     C     ZM72          BEGSR
     C                   MOVE      'PIR7972'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*      0105
     C*
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*      0110  Number must be > 0
     C*
     C     ZM0110        BEGSR
     C                   MOVE      'PIR0110'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     C     ZM1001        BEGSR
     C                   MOVE      'PIR1001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *   EQ52003  Equipment type not valid.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'EQ52003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   EQ52004  Equipment status not valid.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'EQ52004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK1   Screen 1 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK1        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C*
     C*   Verify warehouse and get description.
     C*
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVEL     $LERM         ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C     $LRTN         IFEQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      $LMSG         #MSGK
     C                   EXSR      ZMQMSG
     C                   ENDIF
     C                   ENDIF
     C*
530aA*  Scanned field may be label# or it may be route id/Trax#.
530aA*  CVTBARSEL converts it from route id/Trax# to label#.
530aAC                   if        w1lbl#b <> *blanks
530aAC                   move      w1whse        $bwhseb
530aAC                   movel     w1lbl#b       $bbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $bwhseb           3
530aAC                   parm                    $bbarcode        15
530aAC                   parm                    $blbl#            7 0
530aAC                   parm                    $brtid            5
530aAC                   parm                    $bunq#            5
530aAC                   parm                    $breturn          8
530aAC                   parm                    $berrmsg         60
530aAC                   if        $breturn = '*OK'
530aAC                   eval      w1lbl# = $blbl#
530aAC                   move      *blanks       w1lbl#b
530aAC                   move      $blbl#        w1lbl#b
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      *in22 = *on
530aAC                   movel     desc(1)       errmsg
530aAC                   exsr      zm0110
530aAC                   endif
530aAC                   endif
     C*
750aA   subitem = 'N';

750aA   exec sql select lbwhse, lbord, lbseq, lbitem,
750aA                   odwhse, odord, odseq, oditem, odoitm
750aA             into :lbwhse, :lbord, :lbseq, :lbitem,
750aA                  :odwhse, :odord, :odseq, :oditem, :odoitm
750aA            from label
750aA            inner join ordd
750aA              on lbwhse = odwhse
750aA                and lbord  = odord
750aA                and lbseq  = odseq
750aA                and lbitem = oditem
750aA            where lbwhse = :w1whse
750aA              and lblbl# = :w1lbl#
750aA              and odoitm <> ' ';

750aA   if sqlstt = '00000';
750aA     select;
750aA       when client = cityline and odoitm = '00000';
750aA     other;
750aA       subitem = 'Y';
750aA     endsl;
750aA   endif;
750aA*
     C*  Verify if entered label# is a flagged label.
750aA*  But only if this is NOT a substitute item, because sub items
750aA*  will not have a runner record.
     C*
750aAc                   if        subItem = 'N'
     C     RUNKEY        CHAIN     RUNNER6                            79
     C                   IF        *IN79
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
520 DC**                 GOTO      ENDCK1
     C                   ENDIF
520 MC                   GOTO      ENDCK1
     C                   ENDIF
750aAc                   endif
     C*
CBIaA*
CBIaA*  Runner flag will not be closed if Cheney, and you're not going
CBIaA*  to call LOADR11 either, so bypass the next two edits if Cheney.
     *
CBIaAC                   if        client = cheney
CBIaAC                   goto      endck1
CBIaAC                   endif
     *
520 A*  Verify that runner flag has been closed.
750aA*   But only if opscnl is N and this is not a sub item.
     *
520 AC                   if        rustat <> 'C'
730 AC                             and rustat <> 'S'
750aAC                             and opscnl = 'N'
750aAC                             and subItem = 'N'
520 AC                   eval      error = '1'
520 AC                   eval      *in22 = '1'
520 AC                   eval      *in02 = '1'
520 AC                   eval      *in01 = '0'
520 AC                   if        errmsg = ' '
520 AC                   eval      errmsg = desc(2)
520 AC                   exsr      zm0105
520 AC                   endif
520 AC                   goto      endck1
520 AC                   endif
     *
520 A*  Verify that label is valid and get route id and pallet id
520 A*  for call to LOADR11.
     *
520 AC     w1lbl#        chain     label
520 AC                   if        not %found(label)
520 AC                   eval      error = '1'
520 AC                   eval      *in22 = '1'
520 AC                   eval      *in02 = '1'
520 AC                   eval      *in01 = '0'
520 AC                   if        errmsg = ' '
520 AC                   eval      errmsg = desc(1)
520 AC                   exsr      zm0105
520 AC                   endif
520 AC                   goto      endck1
520 AC                   endif
     *
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD1   User defined command keys for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      *ON
     C                   MOVE      *ON           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C                   SELECT
     C*
     C                   OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   GOTO      ENDCM1
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL1        BEGSR
     C*
     C                   MOVE      *ZEROS        W1LBL#
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZGET1   Get . . .
     C*----------------------------------------------------------------
     C*
     C     ZZGET1        BEGSR
     *
      *
     C     ENDGT1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      *OFF          *IN44
     *
     *  Define key for main file.
     *
     C     RUNKEY        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1LBL#
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ2   Program initialization. Called from main line.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ2        BEGSR
     C*
     C                   MOVE      *ON           REFRSH
     C                   MOVE      *OFF          MORE              1
     C                   MOVE      *OFF          DONE              1
     C                   MOVE      *OFF          EXCPTN            1
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
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
     C                   Z-ADD     #WHSE         W1WHSE

750aA /free

750aA     // Get *RUNNER options
750aA     chain (#whse: '*RUNNER') options;
750aA     if %found;
750aA       oprdta = opdata;
750aA     else;
750aA       opscnl = 'N';
750aA     endif;

750aA /end-free

520aA * Determine calling program and populate function key desc
520aA
520aAC                   Eval      @Counter = 4
520aAC                   Eval      @Caller  = *Blanks
520aAC                   Call      'UI866'       UI866P
520aA
520aAC                   if        @caller = 'RU310'
520aAC                   eval      w1fkey  = 'F8=Return'
520aAC                   else
520aAC                   eval      w1fkey  = 'F3=Exit'
520aAC                   endif

     C                   EXSR      SCR01I
     C*
     C                   ENDSR
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
** DESC - Message
Invalid label #                                            1
Runner flag has not been closed                            2
