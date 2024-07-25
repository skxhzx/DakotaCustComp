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
     F*  EQ613     RF Equipment - Yard Status - Update
     F*  16 February 2004
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*       8 X 20 Screens for hand held scanners
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    02/16/04  MLB  4.17
     F*      - Created.
417b F*    04/29/04  RH   4.17b
     F*      - EQCODE increased from 6 to 8
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     F*
     F*----------------------------------------------------------------
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
     FEQ613FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FEQUIP     IF   E           K DISK
     FEQUIPYS   UF A E           K DISK
     F                                     RENAME(ESREC:RECORD)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             50    DIM(2) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     *----------------------------------------------------------------
     *  Equipment types
     *
     D type01          c                   const('TRACTR')
     D type02          c                   const('TRAILR')
     D type03          c                   const('TRUCKS')
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @FMTIT          C                   CONST('FRMTIT')
     D @ADDTR          C                   CONST('ADDSTDTRN')
     D @ADJTD          C                   CONST('ADJTSKDET')
     D @ADJTR          C                   CONST('ADJTRAN  ')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
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
417b D  $LCODE                22     29
417b D* $LCODE                22     27
     D*
     D*----------------------------------------------------------------
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
     D CurrStamp       s               z
     D*----------------------------------------------------------------
     D*
     D                 DS
     D  DSHMS                  1      6  0
     D  DSHM                   1      4  0
     D  DSHH                   1      2  0
     D  DSMM                   3      4  0
     D  DSSS                   5      6  0
414 AD*----------------------------------------------------------------
414 AD*  API programs
414 AD*
     D @APICS          C                   CONST('APICVTSLT ')
416aAD*----------------------------------------------------------------
416aAD*  *ZEROVFY -  Zero verify options
416aAD*----------------------------------------------------------------
416aAD*
416aAD* Fields
416aAD*
416aAD*    OPVFYV  -  Verify virtual slot using RF (Y,N)
416aAD*
416aAD* Data structure
416aAD*
416aAD OPDATA          DS
416aAD  OPVFYV                 1      1
416aAD  OPTEND               117    117
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
     D*  PIRTRAN record layout for use as parameters
     D*
     D PTPARM        E DS                  EXTNAME(PIRTRAN)
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
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line
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
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   RETURN
     C*
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           *IN98
     CSR                 ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR                 select
     CSR                 when      nxtscr = '01 '
     CSR                 EXFMT     SCREEN1                              50
     C*
     CSR                 when      nxtscr = '02 '
     CSR                 EXFMT     SCREEN2                              50
     C*
     CSR                 when      nxtscr = '03 '
     CSR                 EXFMT     SCREEN3                              50
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
     CSR                 SETOFF                                       9298
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
     CSR                 EXSR      ZZFIL1
     CSR                 MOVE      *OFF          REFRSH            1
     CSR   END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     CSR   SCR02I        BEGSR
     CSR                 MOVE      '02 '         NXTSCR            3
     CSR                 EXSR      ZZFIL2
     CSR                 MOVE      *OFF          REFRSH
     CSR   END02I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 03 initialization
     C*
     CSR   SCR03I        BEGSR
     CSR                 MOVE      '03 '         NXTSCR            3
     CSR                 EXSR      ZZFIL3
     CSR                 MOVE      *OFF          REFRSH
     CSR   END03I        ENDSR
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
     C*
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     C*
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
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
     C*  SC2  -  Screen 2
     C*
     CSR   SC2           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
     CSR                 MOVE      '01 '         NXTSCR
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR02I
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      *OFF          REFRSH
     CSR                 MOVE      '01 '         NXTSCR
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD2
     CSR   CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK2
     CSR   ERROR         CABEQ     *ON           ENDSC2
     CSR   REDSPL        CABEQ     *ON           ENDSC2
     CSR                 EXSR      ZZUPD2
     CSR   ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD2
     CSR   CMDTKN        CABEQ     *ON           ENDSC2
     C*
     CSR   ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC3  -  Screen 3
     C*
     CSR   SC3           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
     CSR                 EXSR      SCR02I
     CSR                 GOTO      ENDSC3
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR03I
     CSR                 GOTO      ENDSC3
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 EXSR      SCR02I
     CSR                 GOTO      ENDSC3
     CSR                 ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD3
     CSR   CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK3
     CSR   ERROR         CABEQ     *ON           ENDSC3
     CSR   REDSPL        CABEQ     *ON           ENDSC3
     C*
     CSR                 EXSR      ZZUPD3
     CSR   ERROR         CABEQ     *ON           ENDSC3
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD3
     CSR   CMDTKN        CABEQ     *ON           ENDSC3
     C*
     CSR   ENDSC3        ENDSR
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
     C*----------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     CSR   ZM71          BEGSR
     CSR                 MOVE      'PIR7971'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     CSR   ZM72          BEGSR
     CSR                 MOVE      'PIR7972'     #MSGID
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
     C*      0110  Number must be > 0
     C*
     CSR   ZM0110        BEGSR
     CSR                 MOVE      'PIR0110'     #MSGID
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
     C*
     C*   Verify warehouse and get description.
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
     C*  Verify equipment code entered.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1CODE        $LCODE
     CSR                 CALL      'EQ900'
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
     C*
     C*  Retrieve equipment type.
     C*
     CSR                 IF        Error = *off
     CSR                 EXSR      ZZGET1
     *
     *    Validate Equipment type entered.
     C                   if        eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   eval      error = *on
     C                   movel     W1code        errmsg
     C                   exsr      zm2003
     C                   goto      endck1
     C                   endif
     C                   ENDIF
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     CSR   ZZCHK2        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*  Verify status code entered.
     C*
     C                   IF        W2STS <> 'I' and
     C                             W2STS <> 'O' and
     C                             W2STS <> 'D' and
     C                             W2STS <> 'L' and
     C                             W2STS <> 'N'
     C                   eval      error = *on
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   movel     desc(2)       errmsg
     C                   exsr      zm0105
     CSR                 ENDIF
     C*
     CSR   ENDCK2        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK3   Screen 3 error checking.
     C*
     CSR   ZZCHK3        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*  Verify dock door number entered.
     C*
     C                   select
     *    Dock door must be greater than zero.
     C                   when      w3door <= 0
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   movel     desc(1)       errmsg
     C                   exsr      zm0105
     *
     C                   endsl
     C*
     CSR   ENDCK3        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     CSR                 SELECT
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
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   User defined command keys for screen 2.
     C*
     CSR   ZZCMD2        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM2        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD3   User defined command keys for screen 3.
     C*
     CSR   ZZCMD3        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM3        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     CSR                 MOVE      *BLANKS       W1CODE
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     CSR   ZZFIL2        BEGSR
     C*
     CSR                 eval      w2code = w1code
     CSR                 eval      w2desc = eqdesc
     CSR                 eval      w2sts  = ' '
      *
     CSR   ENDFL2        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*
     CSR   ZZFIL3        BEGSR
     C*
     CSR                 eval      w3door = 0
      *
     CSR   ENDFL3        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZGet1   Get  Equipment master record.
     C*
     CSR   ZZGet1        BEGSR
     *
     C     fileky        chain     equip                              79
     C                   if        *in79
     C                   eval      eqcode = *blanks
     C                   eval      eqdesc = *blanks
     C                   eval      eqtype = *blanks
     C                   eval      eqsfct = *zeros
     C                   endif
      *
     CSR   ENDGT1        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      #PROG         $CVPRG
     CSR                 MOVE      *OFF          FOREVR            1
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1code
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     CSR                 MOVE      *ON           REFRSH
     CSR                 MOVE      *OFF          MORE              1
     CSR                 MOVE      *OFF          DONE              1
     CSR                 MOVE      *OFF          EXCPTN            1
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
     C*
     CSR                 EXSR      SCR01I
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD1   Update for screen 1.
     C*
     CSR   ZZUPD1        BEGSR
     C*
     CSR                 MOVE      *OFF          ERROR
     C*
     CSR                 EXSR      SCR02I
     C*
     CSR   ENDUP1        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Update for screen 2.
     C*
     CSR   ZZUPD2        BEGSR
     C*
     CSR                 MOVE      *OFF          ERROR
     C*
     CSR                 SELECT
     *
     *    Equipment at Dock. Get door number from user.
     CSR                 when      W2sts = 'D'
     CSR                 EXSR      SCR03I
     *
     *    Otherwise, update status specified by user.
     CSR                 OTHER
     *
     C     fileky        chain     record                             7978
     *
     *  Move screen fields to record fields
     *
     C                   select
     *    Equipment 'In Yard' - Empty
     C                   when      w2sts  = 'I'
     C                   eval      esloc  = '01'
     C                   eval      esio   = *off
     C                   eval      esstat = '01'
     *
     *    Equipment 'At the Dock'
     C                   when      w2sts  = 'D'
     C                   eval      esloc  = '02'
     C                   eval      esio   = *off
     C                   eval      esstat = '02'
     *
     *    Equipment 'Loaded'
     C                   when      w2sts  = 'L'
     C                   eval      esloc  = '03'
     C                   eval      esio   = *off
     C                   eval      esstat = '04'
     *
     *    Equipment 'Out for Delivery' - Unloading.
     C                   when      w2sts  = 'O'
     C                   eval      esloc  = '04'
     C                   eval      esio   = *on
     C                   eval      esstat = '03'
     *
     *    Equipment 'Out of Service' - Out of Svc.
     C                   when      w2sts  = 'N'
     C                   eval      esloc  = '05'
     C                   eval      esio   = *off
     C                   eval      esstat = '05'
     *
     *    Equipment Status Error. Invalid code entered.
     C                   other
     C                   eval      esio   = '0'
     C                   eval      esloc  = '  '
     C                   eval      esstat = '  '
     *
     C                   endsl
     *
     C                   eval      esdoor = *zeros
     *
     *   Update Status Change fields.
     *
     C                   eval      esemp# = #emp#
     C                   eval      esuser = #user
     C                   time                    currstamp
     C                   eval      essdts = currstamp
     *
     *   Add record
     *
     C                   if        *in79
     C                   eval      eswhse = w1whse
     C                   eval      escode = w1code
     *
     C                   write     record                               79
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd2
     C                   endif
     *
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZUPD)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd2
     C                   endif
     C                   endif
     *
     *    Return to first screen. Scan next unit.
     C                   exsr      Scr01i
     *
     C                   ENDSL
     *
     C     endupd2       ENDSR
     *
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     CSR   ZZUPD3        BEGSR
     CSR                 MOVE      *OFF          ERROR
     *
     C     fileky        chain     record                             7978
     *
     *  Move screen fields to record fields
     *
     C                   select
     *
     *    Equipment 'At the Dock'. Update door# entered by user.
     C                   when      w2sts  = 'D'
     C                   eval      esloc  = '02'
     C                   eval      esio   = *off
     C                   eval      esstat = '02'
     C                   eval      esdoor = w3door
     *
     *    Equipment Status Error. Invalid code entered.
     C                   other
     C                   eval      esio   = ' '
     C                   eval      esloc  = '  '
     C                   eval      esstat = '  '
     C                   eval      esdoor = 0
     *
     C                   endsl
     *
     *   Update Status Change fields.
     *
     C                   eval      esemp# = #emp#
     C                   eval      esuser = #user
     C                   time                    currstamp
     C                   eval      essdts = currstamp
     *
     *   Add record
     *
     C                   if        *in79
     C                   eval      eswhse = w1whse
     C                   eval      escode = w1code
     *
     C                   write     record                               79
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd3
     C                   endif
     *
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZUPD)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd3
     C                   endif
     C                   endif
     *
     *    Return to first screen. Scan next unit.
     C                   exsr      Scr01i
     *
     CSR   endupd3       ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Dock door must be greater than zero.
Invalid status code entered.
