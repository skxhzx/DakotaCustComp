500 AF*----------------------------------------------------------------
500 AF*  Multilingual Verision
500 AF*  Every screen and message has a corresponding Spanish version.
500 AF*  Any changes must be made to both languages.
500 AF*  If necessary, contact appropriate person to do translation.
     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  IT220   RF  Inventory adjustments by slot
     F*  07 April, 1997
     F*  Roxanne Harrison
     F*
     F*  Notes:
     F*       Created using IT120
     F*       8 X 20 Screens for hand held scanners
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
     F*
409 AF*    02/11/98  RH   4.09
     F*      - Major revision to use virtual slots.
     F*
414 AF*    06/22/99  DAS  4.14
     F*      - Added APICVTSLT to ZZCHK1 routine.
     F*
415 AF*    06/04/01  DAS  4.15
     F*      - Removed user id from screen.
     F*        No need to get user id here when you can make an
     F*        adjustment from slot info (SL630) where you don't
     F*        have to enter a user id.
     F*      - Revised to default department code.
     F*      - Revised to call SL630 instead of IT221, which will not
     F*        be used anymore.
     F*
417 AF*    07/15/03  MLB  4.17
     F*      - Fix: Revised program to no longer pass $LUSR1 to SL630.
     F*        $LUSR1 was overlaying field in position 54 in SL630.
     F*
500 AF*    05/24/06  DAS  5.00
     F*      - Added Multilingual logic.
510aAF*    12/06/06  RH   5.10A
     F*      - Enh: Remove BFCADR, no long used.
640aAF*    03/12/12  RH   6.40a
     F*      - Fix: Call VS820 (small screen) list display like
     F*        SL620.
     F*
710 AF*    03/01/17  MLB  7.10
     F*      - Enh: Revised pgm to correct Row value sent to APICVTSLT.
740aAF*    07/09/20  LMC  7.40a
     F*      - Enh: Added incoming License parm, if client is trying
     F*        to reactivate a license. Place license in the slot.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     *  Client Custom Mods - DRYa
     *
DRYbA*   03/27/19  NLK  DRYb      (same chg in IT130)
     *     - Revised pgm to not allow adjustments to OSS slots.
     *       Per Melissa M email dated 02.25.2019.
     *     - Added GetClient
     *
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (reverse display)
     F*  90        View mode (protect all fields)
     F*  91        Change mode (protect key fields)
     F*  97        Alawys on (used for SFLEND keyword)
     F*  98        Error on screen (sound alarm)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FIT220FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
409 AFVSLOT2    IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
DRYbA /copy qcopysrc,id#dairyla

     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PWHDP                22     26
     D  $PDISP                27     38
     D  $PUSER                39     48
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LWHDP                22     26
     D  $LITEM                27     41
     D  $LDISP                42     53
     D  $LDESG                54     58
     D  $LSTAT                59     60
     D  $LSDEF                61     62
     D  $LACTV                63     64
     D*
     D  $LUSER                19     28
     D*
     D  $LDSP1                27     38
     D  $LITM1                39     53
     D  $LUSR1                54     63
     D*
     D*----------------------------------------------------------------
     *  Called programs
     D*
DRYbAD @getcl          c                   const('GETCLIENT')
     D*
    AD*----------------------------------------------------------------
414 AD*  API programs
414 AD*
     D @APICS          C                   CONST('APICVTSLT ')
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERPO#                  1      5P 0
     D  ERITEM                 6     20
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D #MSGSP          C                   CONST('PIRMSGFSP ')
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
740aA*----------------------------------------------------------------
740aA*  Variables
740aA*
740aAD $plcns          s             15
740aAD $pitmwhdp       s              5
     C*----------------------------------------------------------------
740aA*----------------------------------------------------------------
740aA*  Let the show begin .....
740aA*
740aAC     *entry        plist
740aAC                   parm                    $plcns
740aAC                   parm                    $pitmwhdp
     C*  Main line
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       $PRTN
     C                   MOVE      *BLANKS       $PERM
     C*
510aDC*                    CALL 'BFCADR'
510aDC*                    PARM           $RTN    8
510aDC*          $RTN      IFEQ '*EXPIRED'
510aDC*                    MOVE 'EOJ'     NXTSCR
510aDC*                    ELSE
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   END
510aDC*                    END
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   END
     C                   END
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   RETURN
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           *IN98
     CSR                 END
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR   NXTSCR        IFEQ      '01 '
500 ACSR                 SELECT
500 ACSR   E$LNG         WHENEQ    'SP'
500 ACSR                 EXFMT     SCREENSP                             50
500 ACSR                 OTHER
     CSR                 EXFMT     SCREEN1                              50
500 ACSR                 ENDSL
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       30
     CSR                 SETOFF                                       98
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CMDTKN            1
414 ACSR                 MOVE      *OFF          REDSPL            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     CSR   SCR01I        BEGSR
     CSR                 MOVE      '01 '         NXTSCR            3
     CSR                 EXSR      ZZFIL1
     CSR   END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     CSR   SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *OFF          *IN20
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     *ON           ENDSC1
414 ACSR   REDSPL        CABEQ     *ON           ENDSC1
     CSR                 EXSR      ZZUPD
     CSR   ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  The after update redisplay screen. The only way out is F3.
     C*
     CSR   ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
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
     C*    ZMCMSG  Clear message record subfile
     C*
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      *OFF          *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     CSR   ZMDMSG        BEGSR
     CSR                 MOVE      *ON           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 END
     CSR                 ENDSR
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     CSR   ZMPMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
500 ACSR                 SELECT
500 ACSR   E$LNG         WHENEQ    'SP'
500 ACSR                 MOVE      #MSGSP        $MSGF
500 ACSR                 OTHER
     CSR                 MOVE      #MSGF         $MSGF            10
500 ACSR                 ENDSL
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM                    #PGMQ
     CSR                 PARM                    #MSGK
     CSR   #MSGID        IFNE      '*CLEAR '
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 END
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*
     C*    ZSCLR   Clear screen
     C*
     CSR   ZSCLR         BEGSR
     CSR                 WRITE     CLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
500 ACSR                 SELECT
500 ACSR   E$LNG         WHENEQ    'SP'
500 ACSR                 MOVE      #MSGSP        $MSGF
500 ACSR                 OTHER
     CSR                 MOVE      #MSGF         $MSGF            10
500 ACSR                 ENDSL
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM      $PPRG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
DRYbA*
DRYbA*     Verify user not adjusting OSS slot.
DRYbAC                   if           client = Dairyland
DRYbA*
DRYbAC                   eval      $pdisp = w1disp
DRYbAC                   if           %subst($pdisp:1:3) = 'OSS'
DRYbAC                   eval      error = '1'
DRYbAC                   eval      *in21 = '1'
DRYbAC                   eval      *in01 = '1'
DRYbAC                   eval      errmsg = 'Transfer to CW Slot, then adjust'
DRYbAC                                    + ' item.'
DRYbAC                   exsr      zm0105
DRYbAC                   goto      endck1
DRYbAC                   endif
DRYbA*
DRYbAC                   endif
DRYbA*
     C*
     C*  Verify warehouse code.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
415 DC**
415 DC** Verify user id.
415 DC**
415 DC**                   MOVE '*VERIFY '$LCMD
415 DC**                   MOVE W1USER    $LUSER
415 DC**                   CALL 'US900'
415 DC**                   PARM           $LPARM
415 DC**         $LRTN     IFEQ '*PGMQ   '
415 DC**                   MOVE *ON       ERROR
415 DC**                   MOVE *ON       *IN24
415 DC**                   MOVE *ON       *IN04
415 DC**                   MOVE $LMSG     #MSGK
415 DC**                   EXSR ZMQMSG
415 DC**                   ENDIF
     C*
     C*
     C*  Verify warehouse department.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
414 AC*
414 AC*  Call API for slot.
414 AC*
414 ACSR                 CALL      @APICS
414 ACSR                 PARM                    W1DISP
710 D **                 PARM  **  6             WOROW
710 MC                   PARM      5             WOROW
414 ACSR                 PARM      8             WOCOL
414 ACSR                 PARM                    @ARTN             8
414 ACSR   @ARTN         IFEQ      '*REDSPLY'
414 ACSR                 MOVE      *ON           REDSPL
414 ACSR                 GOTO      ENDCK1
414 ACSR                 ENDIF
409 AC*
740aA /free
740aA   // skip these checks if the license is being reactivated
740aA   if %parms >=02;
740aA     if w1whdp <> $pitmwhdp;
740aA       error = *on;
740aA       *in22 = *on;
740aA       *in02 = *on;
740aA       errmsg = 'Lcns Activation - Wrong dept for Item';
740aA       exsr zm0105;
740aA     endif;
740aA   else;
740aA /end-free
409 AC*  Check if slot has V-slots.
409 AC*
409 ACSR   VSKEY         SETLL     VSLOT2
409 ACSR   VSKEY         READE     VSLOT2                                 79
409 AC*     DISPLAY VSLOT LISTING
409 ACSR   *IN79         IFEQ      '0'
409 ACSR                 MOVE      '*LOOKUP '    $PCMD
409 ACSR                 Z-ADD     W1WHSE        $PWHSE
409 ACSR                 MOVE      W1WHDP        $PWHDP
409 ACSR                 MOVE      W1DISP        $PDISP
640aDC**                   CALL 'VS910'
640aMCSR                 CALL      'VS820'
409 ACSR                 PARM                    $PARMS
409 ACSR                 MOVE      $PDISP        W1DISP
409 ACSR   $PRTN         IFEQ      '*CANCEL '
409 ACSR                 MOVE      *ON           CANCEL            1
409 ACSR                 GOTO      ENDCK1
409 ACSR                 ENDIF
409 ACSR                 ENDIF
740aAc                   endif
     C*
     C*  Verify slot.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 MOVE      *BLANKS       $LITEM
     CSR                 MOVE      W1DISP        $LDISP
     CSR                 CALL      'SL900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 END
     CSR                 END
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     CSR                 MOVE      *OFF          CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      '1'
     CSR                 MOVE      '1'           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     CSR                 SELECT
     C*
     C*     Warehouse.
     C*
     CSR   ROW#          WHENEQ    3
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        W1WHSE
     CSR                 ENDIF
     C*
     C*     Warehouse department.
     C*
     CSR   ROW#          WHENEQ    5
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVE      $LWHDP        W1WHDP
     CSR                 ENDIF
     C*
     C*     SLOT.
     C*
     CSR   ROW#          WHENEQ    6
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVE      '*GENERAL'    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 MOVE      *BLANKS       $LITEM
     CSR                 MOVE      W1DISP        $LDISP
     CSR                 CALL      'SL900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVE      $LDISP        W1DISP
     CSR                 ENDIF
     C*
     CSR                 OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 GOTO      ENDCM1
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR   W1WHSE        PARM      0             #WHSE             3 0
     C*
415 DC**                   MOVE *BLANKS   W1WHDP
415 ACSR                 CALL      'GETUSER'
415 ACSR                 PARM      #USER         $CODE            10
415 ACSR                 PARM      0             $WHSE             3 0
415 ACSR                 PARM      0             $EMP#             5 0
415 ACSR                 PARM      ' '           $FNAM            15
415 ACSR                 PARM      ' '           $INIT             1
415 ACSR                 PARM      ' '           $LNAM            20
415 ACSR                 PARM      ' '           $WHDP             5
415 ACSR                 PARM      ' '           $STYP             1
415 ACSR                 PARM      ' '           $SHFT             6
415 ACSR                 PARM      ' '           $CREW             6
415 ACSR                 PARM      0             $NHRS             3 1
415 ACSR                 PARM      ' '           $RTN              8
415 ACSR                 MOVE      $WHDP         W1WHDP
740aA /free
740aA   // if item department is sent in use that department
740aA   if %parms >=02;
740aA     w1whdp = $pitmwhdp;
740aA   endif;
740aA /end-free
     C*
415 DC**                   MOVE *BLANKS   W1USER
     CSR                 MOVE      *BLANKS       W1DISP
415 ACSR                 MOVE      *ON           *IN20
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     *
     *  Get client id.
     *
DRYbAC                   call      @getcl
DRYbAC                   parm                    client           10
     *
409 AC*
409 AC*  Define partial key for VSLOT2 file.
409 AC*
409 ACSR   VSKEY         KLIST
409 ACSR                 KFLD                    W1WHSE
409 ACSR                 KFLD                    W1WHDP
409 ACSR                 KFLD                    W1DISP
     C*
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $LPRG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
500 AC*
500 AC*   Get employee options.
500 AC*
500 ACSR                 CALL      'GETUSER'
500 ACSR                 PARM      #USER         E$CODE           10
500 ACSR                 PARM                    E$WHSE            3 0
500 ACSR                 PARM                    E$EMP#            5
500 ACSR                 PARM                    E$FNAM           15
500 ACSR                 PARM                    E$INIT            1
500 ACSR                 PARM                    E$LNAM           20
500 ACSR                 PARM                    E$WHDP            5
500 ACSR                 PARM                    E$STYP            1
500 ACSR                 PARM                    E$SHFT            6
500 ACSR                 PARM                    E$CREW            6
500 ACSR                 PARM                    E$NHRS            3 1
500 ACSR                 PARM                    E$RTN             8
500 ACSR                 PARM                    E$BPU             1
500 ACSR                 PARM                    E$LNG             2
500 ACSR   E$RTN         IFNE      '*OK'
500 ACSR                 MOVE      'EN'          E$LNG
500 ACSR                 ENDIF
414 ACSR                 Z-ADD     0             WOROW
414 ACSR                 Z-ADD     0             WOCOL
     C*
     C*   Select first screen to display.
     C*
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     CSR   ZZUPD         BEGSR
     CSR                 MOVE      *OFF          ERROR
740aA /free
740aA   // if client is reactivating a license
740aA   if %parms >=02;
740aA /end-free
740aAC                   CALL      'IT223'
740aAC                   PARM                    w1whse
740aAC                   PARM                    w1whdp
740aAC                   PARM                    $plcns
740aAC                   PARM                    w1disp
740aA /free
740aA   endif;
740aA /end-free
     C*
     C*  Move screen fields to parameter fields.
     C*
     CSR                 Z-ADD     W1WHSE        $PWHSE
415 DC**                   MOVE W1USER    $PUSER
415 MCSR                 MOVE      #USER         $PUSER
     CSR                 MOVE      W1WHDP        $PWHDP
     CSR                 MOVE      W1DISP        $PDISP
     C*
     CSR                 MOVE      '*VIEW   '    $LCMD
     CSR                 MOVE      W1DISP        $LDSP1
     CSR                 MOVE      *BLANKS       $LITM1
415 DC**                   MOVE W1USER    $LUSR1
417 DC**                   MOVE #USER     $LUSR1
415 DC**                   CALL 'IT221'
415 MCSR                 CALL      'SL630'
     CSR                 PARM                    $LPARM
     CSR   ENDUPD        ENDSR
     C*
     O*----------------------------------------------------------------     ****
     O*
     O*  COMPILE TIME TABLES
     O*
