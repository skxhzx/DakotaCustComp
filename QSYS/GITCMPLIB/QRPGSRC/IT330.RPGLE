     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*---------------------------------------------------------------
     F*
     F*  IT330     Warehouse book by slot
     F*  Hemant Kapadia
     F*
     F*  Revisions
     F*
     F*    01/12/96  DAS  2.10
     F*      - Took out PIRUSER file and corresponding code and replaced
     F*        with call to GETWHSE.
     F*
219  F*    03/14/97  RH   2.19
     F*      - Correct error message for section & view/print options.
     F*
412 AF*    08/20/99  HNK  4.12
     F*      - Slot side option added.
     F*
414 AF*    07/20/00  HNK  4.14
     F*      - Slot type option added.(P=Pick, O=Overflow, B=Both)
     F*
510a F*  06/29/06  HNK  5.10a
     F*    - Default to View.
     F*
520aAF*    03/31/09  CWM  5.20a
     F*      - Added code for report distribution processing.
     F*      - Converted to ILE
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
     FIT330FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
210 DF*IRUSER IF  E           K        DISK
     FREPORTS   IF   E           K DISK
520aDF* RPTOVR1 IF  E           K        DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
520aDD*                    DESC    1   7 60
520aAD DESC            S             60    DIM(9) CTDATA PERRCD(1)
414 DD*                   DESC    1   6 60
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
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
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      $PRTN   *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $WHSE             3
     C                   PARM                    $WHDP             5
     C                   PARM                    $SECTN            1
414 AC                   PARM                    $PICK             1
412 AC                   PARM                    $SIDE             1
     C                   PARM                    $PRTN             8
     C                   PARM                    $VP               1
     C                   PARM                    $JOBQ             1
520AAC                   PARM                    $POVR             1
520aDC*                  PARM                    $DEV             10
520aDC*                  PARM                    $FORM            10
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      '1'           *IN97
     C                   MOVE      '0'           *IN90
     C                   MOVE      '0'           *IN91
     C                   MOVE      '0'           ERROR
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      '1'
     C                   MOVE      'EOJ'         NXTSCR
     C                   END
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
     C                   MOVE      '1'           *INLR
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     CSR   ERROR         IFEQ      '1'
     CSR                 MOVE      '1'           *IN98
     CSR                 END
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR   NXTSCR        IFEQ      '01 '
     CSR                 EXFMT     SCREEN1                              50
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       30
     CSR                 SETOFF                                       98
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CMDTKN            1
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
     C*
     C*  Get existing record.
     C*
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
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      '1'
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys
     C*
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     '1'           ENDSC1
     CSR                 EXSR      ZZNXT1
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
     CSR                 MOVE      '0'           *IN97
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
     CSR                 MOVE      '1'           *IN97
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
     CSR                 MOVE      #MSGF         $MSGF            10
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
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*
     C*    ZSCLR   Clear screen
     C*
     CSR   ZSCLR         BEGSR
     C*R                   WRITECLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
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
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1006  Invalid jobq option for view report option.
     C*
     CSR   ZM1006        BEGSR
     CSR                 MOVE      'PIR1006'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
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
     C*
     C*  Verify warehouse department.
     C*
     CSR   W1VP          IFEQ      'P'
     CSR   W1WHDP        IFNE      '*ALL '
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      '1'           *IN02
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
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Verify section type.
     C*
     CSR   W1SECN        IFNE      'P'
     CSR   W1SECN        ANDNE     'F'
     CSR   W1SECN        ANDNE     'B'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
219 DC*R                   MOVE *BLANKS   $MD
219 DC*R                   MOVEADESC,1    $MD
219 MCSR                 MOVE      *BLANKS       ERRMSG
219 MCSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
414 AC*  Verify slot type. (P=Pick, O=Overflow, B=Both)
     C*
414 ACSR   W1PICK        IFNE      'P'
414 ACSR   W1PICK        ANDNE     'O'
414 ACSR   W1PICK        ANDNE     'B'
414 ACSR                 MOVE      *ON           ERROR
414 ACSR                 MOVE      *ON           *IN24
414 ACSR                 MOVE      *ON           *IN04
414 ACSR                 MOVE      *BLANKS       ERRMSG
414 ACSR                 MOVEL     DESC(7)       ERRMSG
414 ACSR                 EXSR      ZM1001
414 ACSR                 ENDIF
     C*
412 AC*  Verify slot side.
     C*
412 ACSR   W1SIDE        IFNE      'O'
412 ACSR   W1SIDE        ANDNE     'E'
412 ACSR   W1SIDE        ANDNE     'B'
412 ACSR                 MOVE      *ON           ERROR
412 ACSR                 MOVE      *ON           *IN25
412 ACSR                 MOVE      *ON           *IN05
412 ACSR                 MOVE      *BLANKS       ERRMSG
412 ACSR                 MOVEL     DESC(6)       ERRMSG
412 ACSR                 EXSR      ZM1001
412 ACSR                 ENDIF
     C*
     C*  Verify view/print.
     C*
     CSR   W1VP          IFNE      'V'
     CSR   W1VP          ANDNE     'P'
     CSR                 MOVE      *ON           ERROR
414 DC**                   MOVE *ON       *IN24
414 DC**                   MOVE *ON       *IN04
414 MCSR                 MOVE      *ON           *IN26
414 MCSR                 MOVE      *ON           *IN06
219 DC*R                   MOVE *BLANKS   $MD
219 DC*R                   MOVEADESC,2    $MD
219 MCSR                 MOVE      *BLANKS       ERRMSG
219 MCSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify jobq option
     C*
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
414 DC**                   MOVE *ON       *IN25
414 DC**                   MOVE *ON       *IN05
414 MCSR                 MOVE      *ON           *IN27
414 MCSR                 MOVE      *ON           *IN07
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(3)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Cannot run on jobq, if we want to view the report.
     C*
     CSR   W1VP          IFEQ      'V'
     CSR   W1JOBQ        ANDEQ     'Y'
     CSR                 MOVE      *ON           ERROR
414 DC**                   MOVE *ON       *IN25
414 DC**                   MOVE *ON       *IN05
414 MCSR                 MOVE      *ON           *IN27
414 MCSR                 MOVE      *ON           *IN07
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM1006
     CSR                 ENDIF
     C*
     C*  Verify default device
     C*
520aDC*SR                 MOVEL     W1DEV         WORK1A            1
520aDC*SR   WORK1A        IFEQ      '*'
520aDC*SR   W1DEV         ANDNE     '*SYSVAL'
520aDC*SR   W1DEV         ANDNE     '*JOB'
520aDC*SR   W1DEV         OREQ      *BLANKS
520aDC*SR                 MOVE      '1'           ERROR
414 DC**                   MOVE '1'       *IN26
414 DC**                   MOVE '1'       *IN06
520aDC*SR                 MOVE      '1'           *IN28
520aDC*SR                 MOVE      '1'           *IN08
520aDC*SR                 MOVE      *BLANKS       ERRMSG
520aDC*SR                 MOVEL     DESC(4)       ERRMSG
520aDC*SR                 EXSR      ZM1001
520aDC*SR                 ENDIF
     C*
     C*  Verify default form type
     C*
520aDC*SR                 MOVEL     W1FORM        WORK1A            1
520aDC*SR   WORK1A        IFEQ      '*'
520aDC*SR   W1FORM        ANDNE     '*STD'
520aDC*SR   W1FORM        OREQ      *BLANKS
520aDC*SR                 MOVE      '1'           ERROR
414 DC**                   MOVE '1'       *IN27
414 DC**                   MOVE '1'       *IN07
520aDC*SR                 MOVE      '1'           *IN29
520aDC*SR                 MOVE      '1'           *IN09
520aDC*SR                 MOVE      *BLANKS       ERRMSG
520aDC*SR                 MOVEL     DESC(5)       ERRMSG
520aDC*SR                 EXSR      ZM1001
520aDC*SR                 ENDIF
     C*
     C*  Verify default PRINT OVERRIDE FLAG
     C*
520AAC     W1POVR        IFNE      'Y'
520AAC     W1POVR        ANDNE     'N'
520AAC                   MOVE      '1'           ERROR
520AAC                   MOVE      '1'           *IN29
520AAC                   MOVE      '1'           *IN09
520AAC                   MOVE      *BLANKS       ERRMSG
520AAC                   MOVEL     DESC(8)       ERRMSG
520AAC                   EXSR      ZM1001
520AAC                   ENDIF
520AAC*
520AAC*  Cannot set one time override, if we want to view the report.
520AAC*
520AAC     W1VP          IFEQ      'V'
520AAC     W1POVR        ANDEQ     'Y'
520AAC                   MOVE      *ON           ERROR
520AAC                   MOVE      *ON           *IN29
520AAC                   MOVE      *ON           *IN09
520AAC                   MOVE      *BLANKS       ERRMSG
520AAC                   MOVEL     DESC(9)       ERRMSG
520AAC                   EXSR      ZM1001
520AAC                   ENDIF
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     CSR                 MOVE      '0'           CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     C*     Warehouse.
     C*
     CSR                 SELECT
     CSR   ROW#          WHENEQ    08
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 MOVE      #PROG         $LPRG
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        W1WHSE
     CSR                 ENDIF
     C*
     C*     Department.
     C*
     CSR   ROW#          WHENEQ    9
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVE      $LWHDP        W1WHDP
     CSR                 END
     C*
     CSR                 OTHER
     C*
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     C*   Initialize printer device/form
     C*
     C*      Get warehouse for user.
     C*
210 DC*R         #USER     CHAINPIRUSER              79
210 DC*R         *IN79     IFEQ *ON
210 DC*R                   Z-ADD1         WKWHSE
210 DC*R                   Z-ADD1         W1WHSE
210 DC*R                   ELSE
210 DC*R                   Z-ADDUSWHSE    WKWHSE
210 DC*R                   Z-ADDUSWHSE    W1WHSE
210 DC*R                   ENDIF
210 AC*
210 ACSR                 CALL      'GETWHSE'
210 ACSR                 PARM                    #USER
210 ACSR   W1WHSE        PARM      0             #WHSE             3 0
210 ACSR                 Z-ADD     W1WHSE        WKWHSE
210 AC*
     C*
     CSR                 MOVE      '*ALL '       W1WHDP
     CSR                 MOVE      'B'           W1SECN
414 ACSR                 MOVE      'B'           W1PICK
412 ACSR                 MOVE      'B'           W1SIDE
510a CSR                 MOVE      'V'           W1VP
510A C**                   MOVE 'P'       W1VP
     C*
     CSR                 MOVE      *BLANKS       WKSTYP
     CSR                 MOVE      *BLANKS       WKWHDP
     CSR                 MOVE      'N'           W1JOBQ
     C*
520aDC*R   ROKEY         CHAIN     RPTOVR1                            79
520aDC*SR   *IN79         IFEQ      *OFF
520aDC*SR                 MOVE      RODEV         W1DEV
520aDC*SR                 MOVE      ROFORM        W1FORM
520aDC*SR                 ENDIF
520aDC*
520aDC*SR   *IN79         IFEQ      *ON
520aDC*R   RPKEY         CHAIN     REPORTS                            79
520aDC*SR   *IN79         IFEQ      *OFF
520aDC*SR                 MOVE      RPDEV         W1DEV
520aDC*SR                 MOVE      RPFORM        W1FORM
520aDC*SR                 ELSE
520aDC*SR                 MOVEL     '*JOB    '    W1DEV
520aDC*SR                 MOVEL     '*STD    '    W1FORM
520aDC*SR                 ENDIF
520aDC*SR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     CSR   ROKEY         KLIST
     CSR                 KFLD                    WKPRTF           10
     CSR                 KFLD                    WKWHSE            3 0
     CSR                 KFLD                    WKSTYP            1
     CSR                 KFLD                    WKWHDP            5
     C*
     CSR   RPKEY         KLIST
     CSR                 KFLD                    WKPRTF
     C*
     CSR                 MOVEL     'IT331PR '    WKPRTF
     CSR                 MOVE      *BLANKS       RPTTTL
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVEL     RPDESC        $PSTR            60
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       $PSTR
     CSR                 ENDIF
     CSR                 Z-ADD     40            $PLEN             3 0
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         RPTTTL
     C*
     CSR                 MOVE      #PROG         $LPRG
520AAC                   MOVE      'N'           W1POVR            1
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   Select first screen to display.
     C*
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZNXT1   What to do next when screen 1 input is ok.
     C*
     CSR   ZZNXT1        BEGSR
     C*
     CSR                 MOVE      W1WHSE        $WHSE
     C*
     CSR                 MOVE      W1WHDP        $WHDP
     CSR                 MOVE      W1SECN        $SECTN
414 ACSR                 MOVE      W1PICK        $PICK
412 ACSR                 MOVE      W1SIDE        $SIDE
     C*
     CSR                 SELECT
     CSR   W1SECN        WHENEQ    'P'
     CSR                 MOVE      '*PIR    '    $PRTN
     CSR   W1SECN        WHENEQ    'F'
     CSR                 MOVE      '*FIXED  '    $PRTN
     CSR   W1SECN        WHENEQ    'B'
     CSR                 MOVE      '*BOTH   '    $PRTN
     CSR                 ENDSL
     C*
     CSR                 MOVE      W1VP          $VP
     C*
     CSR                 MOVE      W1JOBQ        $JOBQ
     C*
520aDC*SR                 MOVE      W1DEV         $DEV
     C*
520aDC*SR                 MOVE      W1FORM        $FORM
     C*
520aAC                   MOVE      W1POVR        $POVR
520aAC*
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Section type
Print option
Job queue option
Printer device
Form type
Slot side
Slot type
Print Over Ride
View / Print Override Combination
