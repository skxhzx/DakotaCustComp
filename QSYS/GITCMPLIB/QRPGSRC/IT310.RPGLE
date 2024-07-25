     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  IT310     Inventory register
     F*  Hemant Kapadia
     F*
     F*  Revisions
     F*
     F*    01/12/96  DAS  2.10
     F*      - Took out PIRUSER file and corresponding code and replaced
     F*        with call to GETWHSE.
     F*
219  F*    03/17/97  RH   2.19
     F*      - Correct error message for section.
     F*
520AAF*    02/17/09  CWM  5.20a
     F*      - Added code for report distribution processing. Commentedd
     F*        out code that was no longer needed.
     F*      - Converted to ILE
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
     FIT310FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
210 DF*IRUSER IF  E           K        DISK
     FREPORTS   IF   E           K DISK
520ADF*RPTOVR1 IF  E           K        DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
520ADD*                   DESC    1   4 60
520aAD DESC            S             60    DIM(5) CTDATA PERRCD(1)
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
     C*              *PIR     - Select only PIR items
     C*              *FIXED   - Select only Fixed items
     C*              *BOTH    - Select all items
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $WHSE             3
     C                   PARM                    $PRTN             8
     C                   PARM                    $JOBQ             1
520AAC                   PARM                    $POVR             1
520ADC*                    PARM           $DEV   10
520ADC*                    PARM           $FORM  10
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
     C*  Verify options
     C*
     CSR   W1OPT         IFNE      'P'
     CSR   W1OPT         ANDNE     'F'
     CSR   W1OPT         ANDNE     'B'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify jobq option
     C*
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify default device
     C*
520ADC*SR                   MOVELW1DEV     WORK1A  1
     C*SR         WORK1A    IFEQ '*'
     C*SR         W1DEV     ANDNE'*SYSVAL'
     C*SR         W1DEV     ANDNE'*JOB'
     C*SR         W1DEV     OREQ *BLANKS
     C*SR                   MOVE '1'       ERROR
     C*SR                   MOVE '1'       *IN24
     C*SR                   MOVE '1'       *IN04
     C*SR                   MOVE *BLANKS   ERRMSG
     C*SR                   MOVELDESC,3    ERRMSG
     C*SR                   EXSR ZM1001
     C*SR                   ENDIF
     C*
     C*  Verify default form type
     C*
     C*SR                   MOVELW1FORM    WORK1A  1
     C*SR         WORK1A    IFEQ '*'
     C*SR         W1FORM    ANDNE'*STD'
     C*SR         W1FORM    OREQ *BLANKS
     C*SR                   MOVE '1'       ERROR
     C*SR                   MOVE '1'       *IN25
     C*SR                   MOVE '1'       *IN05
     C*SR                   MOVE *BLANKS   ERRMSG
     C*SR                   MOVELDESC,4    ERRMSG
     C*SR                   EXSR ZM1001
     C*SR                   ENDIF
     C*  Verify default PRINT OVERRIDE FLAG
     C*
520AAC     W1POVR        IFNE      'Y'
520AAC     W1POVR        ANDNE     'N'
520AAC                   MOVE      '1'           ERROR
520AAC                   MOVE      '1'           *IN25
520AAC                   MOVE      '1'           *IN05
520AAC                   MOVE      *BLANKS       ERRMSG
520AAC                   MOVEL     DESC(5)       ERRMSG
520AAC                   EXSR      ZM1001
520AAC                   ENDIF
520AAC*
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
     CSR   ROW#          WHENEQ    08
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 MOVE      #PROG         $LPRG
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        W1WHSE
     CSR                 ENDIF
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
     CSR                 MOVE      'B'           W1OPT
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
     CSR                 MOVE      *BLANKS       WKSTYP
     CSR                 MOVE      *BLANKS       WKWHDP
     CSR                 MOVE      'N'           W1JOBQ
     C*
520ADC*SR         ROKEY     CHAINRPTOVR1              79
520ADC*SR         *IN79     IFEQ *OFF
520ADC*SR                   MOVE RODEV     W1DEV
520ADC*SR                   MOVE ROFORM    W1FORM
520ADC*SR                   ENDIF
520ADC*
520ADC*SR         *IN79     IFEQ *ON
520ADC*SR         RPKEY     CHAINREPORTS              79
520ADC*SR         *IN79     IFEQ *OFF
520ADC*SR                   MOVE RPDEV     W1DEV
520ADC*SR                   MOVE RPFORM    W1FORM
520ADC*SR                   ELSE
520ADC*SR                   MOVEL'*JOB    'W1DEV
520ADC*SR                   MOVEL'*STD    'W1FORM
520ADC*SR                   ENDIF
520ADC*SR                   ENDIF
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
     CSR                 MOVEL     'IT311PR '    WKPRTF
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
520AAC                   MOVE      'N'           W1POVR
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
     CSR   W1OPT         IFEQ      'P'
     CSR                 MOVE      '*PIR    '    $PRTN
     CSR                 ELSE
     CSR   W1OPT         IFEQ      'F'
     CSR                 MOVE      '*FIXED  '    $PRTN
     CSR                 ELSE
     CSR                 MOVE      '*BOTH   '    $PRTN
     CSR                 END
     CSR                 END
     C*
     CSR                 MOVE      W1JOBQ        $JOBQ
520AAC*
520AAC                   MOVE      W1POVR        $POVR
     C*
520ADC*SR                   MOVE W1DEV     $DEV
     C*
520ADC*SR                   MOVE W1FORM    $FORM
     C*
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Section type
Job queue option
Printer device
Form type
Print Over Ride
