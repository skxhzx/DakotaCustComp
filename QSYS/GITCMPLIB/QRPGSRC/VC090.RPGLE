     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  VC099     Talkman Simulation program
     F*  15 December 2000
     F*  Hemant Kapadia
     F*
     F*  Revisions
     F*
     F*    12/15/00  HNK  4.15
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   Field position to
     F*  21 - 40   Field input error (reverse display)
     F*  81        Display subfile records (SFLDSP)
     F*  82        Display subfile screen (SFLDSPCTL)
     F*  83        Clear subfile (SFLCLR)
     F*  84        Allow subfile to display '+' (SFLEND)
     F*  85        Manually set subfile change flag (SFLNXTCHG)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (protect key)
     F*  97        Error message subfile indicator
     F*  98        Error on screen (sound buzzer)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FVC090FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DETAIL1:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FVcLabel1  IF   E           K Disk
     FLabel     IF   E           K Disk

     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
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
     C*----------------------------------------------------------------
     C*  Main line
     C*

     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      *ON
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
     CSR                 SELECT
     C*
     CSR   NXTSCR        WHENEQ    '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      HEAD1                                  50
     C*
     CSR                 ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       040506
     CSR                 SETOFF                                       070809
     CSR                 SETOFF                                       101112
     CSR                 SETOFF                                       131415
     CSR                 SETOFF                                       161718
     CSR                 SETOFF                                       1920
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
     CSR                 SETOFF                                       333435
     CSR                 SETOFF                                       363738
     CSR                 SETOFF                                       3940
     CSR                 SETOFF                                       98
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CMDTKN            1
     CSR                 MOVE      *OFF          REDSPL            1
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
     CSR                 EXSR      ZZDFT1
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
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     *ON           ENDSC1
     CSR                 EXSR      ZZUPD1
     CSR   REDSPL        CABEQ     *ON           ENDSC1
     CSR   ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
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
     C*  Initialize subfile values
     C*
     C*                    Z-ADD1         RECNO
     C*                    WRITEDETAIL1                79
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   Add record to subfile
     C*
     CSR   SFLADD        BEGSR
     CSR                 ADD       1             RECCNT
     CSR                 Z-ADD     RECCNT        RECNO
X12  CSR                 MOVE      *ON           *IN85
     CSR                 MOVE      *BLANKS       W1TYPE
     CSR                 Z-ADD     0             W1TRN#
     CSR                 Z-ADD     0             W1LBL#
     CSR                 Z-ADD     0             W1QPCK
     CSR                 WRITE     HEAD1
     CSR                 WRITE     DETAIL1
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   Clear display subfile
     C*
     CSR   SFLCLR        BEGSR
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     CSR                 Z-ADD     0             RECNO             4 0
     CSR                 Z-ADD     0             RECCNT            4 0
     CSR                 Z-ADD     1             POSREC            4 0
     C*
     CSR                 MOVE      *OFF          *IN81
     CSR                 MOVE      *OFF          *IN82
     CSR                 MOVE      *ON           *IN83
     CSR                 MOVE      *ON           *IN84
     CSR                 WRITE     HEAD1
     CSR                 MOVE      *ON           *IN82
     CSR                 MOVE      *OFF          *IN83
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile
     C*
     CSR   SFLDSP        BEGSR
     C*
     C*  WRITE OPTION AND COMMAND LINES TO DISPLAY
     C*
     C**                   WRITEOPTREC
     CSR                 WRITE     CMDREC
     C*
     C*  WRITE POSITION TO FIELD TO DISPLAY
     C*
     C**                   WRITEPOSTNREC
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     CSR   RECCNT        IFGT      0
     CSR                 MOVE      *ON           *IN81
     CSR                 ENDIF
     CSR   RECCNT        IFGT      12
     CSR                 Z-ADD     RECCNT        POSREC
     CSR                 ENDIF
     CSR                 Z-ADD     POSREC        RECNO
     CSR                 WRITE     HEAD1
     CSR                 ENDSR
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
     CSR                 WRITE     CLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
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
     C*   PIR1001  Invalid value entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     CSR   W1TYPE        IFNE      'PICKS'
     CSR   W1TRN#        ANDGT     0
     CSR                 Move      *On           Error
     CSR                 Endif
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     CSR                 END
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     CSR   ZZDFT1        BEGSR
     CSR                 MOVE      ' '           W1TYPE
     C                   Eval      W1Trn# = 0
     CSR                 EXSR      SFLCLR
     CSR                 Z-ADD     1             POSREC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      *ON           FOREVR            1
     CSR   Lbkey         KList
     CSR                 Kfld                    SvTrn#
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
     C*  ZZUPD1   Update record.
     C*
     CSR   ZZUPD1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     CSR   SVTRN#        IFEQ      0
     CSR                 Z-add     W1trn#        Svtrn#            7 0
     CSR                 CALL      'VC100'
     CSR                 PARM                    W1type
     CSR                 PARM                    W1trn#
     CSR                 PARM                    W1lbl#            7 0
     CSR                 PARM                    W1qpck            5 0
     CSR                 PARM                    W1cwgt            7 2
     CSR                 Endif
      *
      *  Update qty if label number entered.
      *
     CSR   W1Type        IfEq      'PICK'
     CSR   W1lbl#        AndGt     0
     CSR                 CALL      'VC100'
     CSR                 PARM                    W1type
     CSR                 PARM                    W1trn#
     CSR                 PARM                    W1lbl#
     CSR                 PARM                    W1qpck
     CSR                 PARM                    W1cwgt            7 2
     CSR                 Endif
      *
      *  Update catch wgt.
      *
     CSR   W1Type        IfEq      'WEIGHT'
     CSR   W1lbl#        AndGt     0
     CSR                 CALL      'VC091'
     CSR                 PARM                    W1type
     CSR                 PARM                    W1trn#
     CSR                 PARM                    W1lbl#
     CSR                 PARM                    W1qpck
     CSR                 PARM                    W1cwgt            7 2
     CSR                 Endif
      *
      *  Read the incoming request...
      *
     CSR                 EXSR      SFLCLR
     CSR                 Z-ADD     1             POSREC
     C                   Move      *Off          Done              1
      *
     C     Lbkey         Setll     VcLabel1
     C                   DoW       0 = 0
     C     Lbkey         Reade     VcLabel1                               79
     C     *In79         IfEq      *On
     C                   Leave
     C                   Endif
     C     VcLbl#        Chain     Label                              79
     C     *In79         IfEq      *On
     C                   Eval      LbQpck = 0
     C                   Endif
     CSR                 EXSR      SFLADD
     C                   EndDo
      *
     C*
     CSR   ENDUP1        ENDSR
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
