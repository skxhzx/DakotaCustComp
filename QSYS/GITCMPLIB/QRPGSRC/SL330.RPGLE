     F*----------------------------------------------------------------
     F*   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  SL330     Slot listing
     F*  Hemant Kapadia
     F*  Dave Sommerville
     F*
     F*  **NOTE**  when compiling make sure DFTACTGRP is set to *NO
     F*            ACTGRP should then default to QILE
     F*            SL330CL is a CLLE with a OPNQRY
     F*
     F*  Revisions
     F*
219  F*    03/17/97  RH   2.19
     F*      - Correct error message for slot type & printing sequence.
413a F*    03/06/00  RH   4.13a
     F*      - Add option to include item/description (W1ITMD)
     F*
520 AF*    03/26/09  CWM  5.20
     F*      - Enh: Added Report Distribution / Print Override function
     F*             Converted to ILE
530a F*    11/05/09  GJA  6.10a
     F*      - Recompile only.  Changed item/description to be
     F*          description/license.
640a F*    04/18/11  RH   6.40a
     F*      - FIX: 6.10a missed in previous verison, rename format
640b F*    04/13/12  RH   6.40b
     F*      - ENH: Add slot status to selection, rename format
650a F*    04/05/13  GJA  6.50a
     F*      - ENH: Add slot location, side, virtual, rename format
     F*             Default item description/license to "Y"
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
640aDF*L330FM   CF   E             WORKSTN
640bDF*L33001   CF   E             WORKSTN
640bDF*L33002   CF   E             WORKSTN
650aMFSL33003   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FREPORTS   IF   E           K DISK
     FRPTOVR1   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
413aDD*                   DESC    1   6 60
520 DD*DESC            S             60    DIM(7) CTDATA PERRCD(1)
520 AD*DESC            S             60    DIM(8) CTDATA PERRCD(1)
650aAD DESC            S             60    DIM(12) CTDATA PERRCD(1)
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
     D*
640bAD  $LSTAT                19     20
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
     C                   PARM                    $AISL             3
     C                   PARM                    $PICK             1
     C                   PARM                    $SEQ              1
640bAC                   PARM                    $STAT             2
     C                   PARM                    $PRTN             8
     C                   PARM                    $VP               1
     C                   PARM                    $JOBQ             1
413aAC                   PARM                    $ITMD             1
520 AC                   PARM                    $POVR             1
650aAC                   PARM                    $SIDE             1
650aAC                   PARM                    $VSLT             1
650aAC                   PARM                    $LOCS             3
650aAC                   PARM                    $LOCE             3
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
     CSR                 SETOFF                                       3031
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
413a C*
413a C*  Verify Include item/description.
413a C*
413a CSR   W1ITMD        IFNE      'Y'
413a CSR   W1ITMD        ANDNE     'N'
413a CSR                 MOVE      *ON           ERROR
413a CSR                 MOVE      *ON           *IN30
413a CSR                 MOVE      *ON           *IN13
413a CSR                 MOVE      *BLANKS       ERRMSG
413a CSR                 MOVEL     DESC(7)       ERRMSG
413a CSR                 EXSR      ZM1001
413a CSR                 ENDIF
     C*
     C*  Verify slot type.
     C*
     CSR   W1TYPE        IFNE      '1'
     CSR   W1TYPE        ANDNE     '2'
     CSR   W1TYPE        ANDNE     '3'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN24
     CSR                 MOVE      *ON           *IN04
219 DC*R                   MOVE *BLANKS   $MD
219 DC*R                   MOVEADESC,1    $MD
219 MCSR                 MOVE      *BLANKS       ERRMSG
219 MCSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
640bAC
640bAC*  Verify slot status.
640bAC*
640bACSR   W1STAT        IFNE      '*ALL'
640bACSR                 MOVE      '*VERIFY '    $LCMD
640bACSR                 MOVEL     W1STAT        $LSTAT
640bACSR                 CALL      'SS900'
640bACSR                 PARM                    $LPARM
640bACSR   $LRTN         IFEQ      '*ERROR  '
640bACSR                 MOVE      *ON           ERROR
640bACSR                 MOVE      *ON           *IN31
640bACSR                 MOVE      *ON           *IN09
640bACSR                 MOVEL     $LERM         ERRMSG
640bACSR                 EXSR      ZM0105
640bACSR                 ELSE
640bACSR   $LRTN         IFEQ      '*PGMQ   '
640bACSR                 MOVE      *ON           ERROR
640bACSR                 MOVE      *ON           *IN31
640bACSR                 MOVE      *ON           *IN09
640bACSR                 MOVE      $LMSG         #MSGK
640bACSR                 EXSR      ZMQMSG
640bACSR                 ENDIF
640bACSR                 ENDIF
640bACSR                 ENDIF
     C*
     C*  Verify print order.
     C*
     CSR   W1SEQ         IFNE      '1'
     CSR   W1SEQ         ANDNE     '2'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN25
     CSR                 MOVE      *ON           *IN05
219 DC*R                   MOVE *BLANKS   $MD
219 DC*R                   MOVEADESC,2    $MD
219 MCSR                 MOVE      *BLANKS       ERRMSG
219 MCSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify view/print.
     C*
     CSR   W1VP          IFNE      'V'
     CSR   W1VP          ANDNE     'P'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN26
     CSR                 MOVE      *ON           *IN06
219 DC*R                   MOVE *BLANKS   $MD
219 DC*R                   MOVEADESC,3    $MD
219 MCSR                 MOVE      *BLANKS       ERRMSG
219 MCSR                 MOVEL     DESC(3)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify jobq option
     C*
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(4)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Cannot run on jobq, if we want to view the report.
     C*
     CSR   W1VP          IFEQ      'V'
     CSR   W1JOBQ        ANDEQ     'Y'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM1006
     CSR                 ENDIF
520 AC*
520 AC*  Verify Print Override Flag
520 AC*
520 AC     W1POVR        IFNE      'Y'
520 AC     W1POVR        ANDNE     'N'
520 AC                   MOVE      '1'           ERROR
520 AC                   MOVE      '1'           *IN35
520 AC                   MOVE      '1'           *IN15
520 AC                   MOVE      *BLANKS       ERRMSG
520 AC                   MOVEL     DESC(8)       ERRMSG
520 AC                   EXSR      ZM1001
520 AC                   ENDIF
650aAC*  Verify Virtual Slot Flag
650aAC*
650aAC     W1VSLT        IFNE      'Y'
650aAC     W1VSLT        ANDNE     'N'
650aAC                   MOVE      '1'           ERROR
650aAC                   MOVE      '1'           *IN30
650aAC                   MOVE      '1'           *IN08
650aAC                   MOVE      *BLANKS       ERRMSG
650aAC                   MOVEL     DESC(9)       ERRMSG
650aAC                   EXSR      ZM1001
650aAC                   ENDIF
650aAC*  Verify Side Flag
650aAC*
650aAC     W1SIDE        IFNE      'B'
650aAC     W1SIDE        ANDNE     'E'
650aAC     W1SIDE        ANDNE     'O'
650aAC                   MOVE      '1'           ERROR
650aAC                   MOVE      '1'           *IN34
650aAC                   MOVE      '1'           *IN14
650aAC                   MOVE      *BLANKS       ERRMSG
650aAC                   MOVEL     DESC(10)      ERRMSG
650aAC                   EXSR      ZM1001
650aAC                   ENDIF
650aAC*  Verify Location Range
650aAC*
650aAC     W1locs        IFGT      w1loce
650aAC                   MOVE      '1'           ERROR
650aAC                   MOVE      '1'           *IN33
650aAC                   MOVE      '1'           *IN13
650aAC                   MOVE      *BLANKS       ERRMSG
650aAC                   MOVEL     DESC(11)      ERRMSG
650aAC                   EXSR      ZM1001
650aAC                   ENDIF
650aAC     W1loce        IFLT      w1locs
650aAC                   MOVE      '1'           ERROR
650aAC                   MOVE      '1'           *IN32
650aAC                   MOVE      '1'           *IN12
650aAC                   MOVE      *BLANKS       ERRMSG
650aAC                   MOVEL     DESC(11)      ERRMSG
650aAC                   EXSR      ZM1001
650aAC                   ENDIF
     C*
     C*  Verify default device
     C*
     CSR                 MOVEL     W1DEV         WORK1A            1
520 DC*    WORK1A        IFEQ      '*'
520 DC*    W1DEV         ANDNE     '*SYSVAL'
520 DC*    W1DEV         ANDNE     '*JOB'
520 DC*    W1DEV         OREQ      *BLANKS
520 DC*                  MOVE      '1'           ERROR
520 DC*                  MOVE      '1'           *IN28
520 DC*                  MOVE      '1'           *IN08
520 DC*                  MOVE      *BLANKS       ERRMSG
520 DC*                  MOVEL     DESC(5)       ERRMSG
520 DC*                  EXSR      ZM1001
520 DC*                  ENDIF
520 DC*
520 DC*  Verify default form type
520 DC*
     CSR                 MOVEL     W1FORM        WORK1A            1
520 DC*    WORK1A        IFEQ      '*'
520 DC*    W1FORM        ANDNE     '*STD'
520 DC*    W1FORM        OREQ      *BLANKS
520 DC*                  MOVE      '1'           ERROR
520 DC*                  MOVE      '1'           *IN29
520 DC*                  MOVE      '1'           *IN09
520 DC*                  MOVE      *BLANKS       ERRMSG
520 DC*                  MOVEL     DESC(6)       ERRMSG
520 DC*                  EXSR      ZM1001
520 DC*                  ENDIF
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
     C*     Warehouse department.
     C*
     CSR                 SELECT
     CSR   ROW#          WHENEQ    06
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
     CSR   ROW#          WHENEQ    7
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVE      $LWHDP        W1WHDP
     CSR                 END
640bAC*
640bAC*     Slot status
640bAC*
640bACSR   row#          wheneq    14
640bAC                   eval      *in12 = *on
640bAC                   eval      $lcmd = '*LOOKUP '
640bAC                   eval      $lstat = w1stat
640bAC                   call      'SS900'
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*SELECT '
640bAC                   movel     $lstat        w1stat
640bAC                   endif
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
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR   W1WHSE        PARM      0             #WHSE             3 0
     C*
     CSR                 MOVE      '*ALL '       W1WHDP
     CSR                 MOVE      '*ALL'        W1AISL
413aAC***                MOVE      'N'           W1ITMD
650aACSR                 MOVE      'Y'           W1ITMD
     CSR                 MOVE      '1'           W1TYPE
640bACSR                 MOVE      '*ALL'        W1STAT
     CSR                 MOVE      '1'           W1SEQ
     CSR                 MOVE      'P'           W1VP
     CSR                 MOVE      'N'           W1JOBQ
520 AC                   MOVE      'N'           W1POVR
650aAC                   MOVE      'N'           W1VSLT
650aAC                   z-add     *zeros        W1LOCS
650aAC                   z-add     999           W1LOCE
650aAC                   move      'B'           W1SIDE
     C*
     CSR   ROKEY         CHAIN     RPTOVR1                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      RODEV         W1DEV            10
     CSR                 MOVE      ROFORM        W1FORM           10
     CSR                 ENDIF
     C*
     CSR   *IN79         IFEQ      *ON
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      RPDEV         W1DEV
     CSR                 MOVE      RPFORM        W1FORM
     CSR                 ELSE
     CSR                 MOVEL     '*JOB    '    W1DEV
     CSR                 MOVEL     '*STD    '    W1FORM
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     CSR   ROKEY         KLIST
     CSR                 KFLD                    WKPRTF           10
     CSR                 KFLD                    W1WHSE
     CSR                 KFLD                    WKSTYP            1
     CSR                 KFLD                    W1WHDP
     C*
     CSR   RPKEY         KLIST
     CSR                 KFLD                    WKPRTF
     C*
     CSR                 MOVEL     'SL331PR '    WKPRTF
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
     CSR                 MOVE      W1WHDP        $WHDP
     CSR   W1AISL        IFEQ      '*ALL'
     CSR                 MOVEL     W1AISL        $AISL
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       $CSTR
     CSR                 MOVEL     W1AISL        $CSTR
     CSR                 CALL      'ADJUST'
     CSR                 PARM      '*RIGHT  '    $CCMD             8
     CSR                 PARM                    $CSTR            30
     CSR                 MOVE      $CSTR         $AISL
     CSR                 ENDIF
     CSR                 MOVE      W1TYPE        $PICK
640bAC*
640bACSR                 MOVEL     W1STAT        $STAT
     CSR                 MOVE      W1SEQ         $SEQ
413aAC*
413aACSR                 MOVE      W1ITMD        $ITMD
     C*
     CSR                 MOVE      W1VP          $VP
     C*
     CSR                 MOVE      W1JOBQ        $JOBQ
     C*
520 DC*                  MOVE      W1DEV         $DEV
     C*
520 DC*                  MOVE      W1FORM        $FORM
     C*
520 AC                   MOVE      W1POVR        $POVR
     C*
650aAC                   MOVE      W1LOCS        $LOCS
     C*
650aAC                   MOVE      W1LOCE        $LOCE
     C*
650aAC                   MOVE      W1VSLT        $VSLT
     C*
650aAC                   MOVE      W1SIDE        $SIDE
     C*
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Slot type
Printing order
Print option
Job queue option
Printer device
Form type
Item/desc. option
Override Flag
Virtual Slot Flag
Side Flag
Location Range
