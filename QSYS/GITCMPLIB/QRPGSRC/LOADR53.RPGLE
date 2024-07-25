     F*----------------------------------------------------------------
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*  LOADR53  Close Open Trailer Equipment - Detail.
     F*           Reads input files LDRTRLE and LDRTEQ loaded by Loadr1.
     F*
     F*  October 30, 2008
     F*  Jose G. Duque
     F*
     F*  Revisions
     F*
     F*    03/15/11  JGD  6.40
     F*      - Created
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
     F*    ##/##/##  XXX-XXX
     F*      - Text . . .
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  60        Display product temps at item level.
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLOAD53FM  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FPIRUSER   IF   E           K DISK
     F*
     FPIRUSER1  IF   E           K DISK
     F                                     RENAME(USREC:USREC1)
     F*
     FLDRHHDR   IF   E           K DISK
     FLDRTRLE1  UF   E           K DISK
     F*
     FLDRTEQ    UF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A4              S              1    DIM(4)
     D DESC            S             70    DIM(4) CTDATA PERRCD(1)
     D EMP#5           S              5  0
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D*$PARMS      DS
     D*                                        1   30$PWHSE
     D*                                        4   8 $PRTE#
     D*                                        9  16 $PTLR#
     D*                                       17  26 $PPRG
     D*                                       27  34 $PRTN
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*  Constants
     D DIGITS          C                   CONST('0123456789 ')
     D*----------------------------------------------------------------
     D*  Called program parameters
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
     D  $LCODE                22     23
     D*
     D SCRN1           DS
     D  CVALI                  1      4
     D  NVALO                  1      4  0
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
     D  ERFLD                  1     30
     D  ERFROM                31     40
     D  ERTO                  41     50
     D                 DS
     D  $EC                    1      2P 0
     D*
     D                 DS
     D  DSMISC                 1     20
     D  DSSDTE                 1      8
     D  DSSPCL                 9     11
     D  DSRPCK                12     12
     D  DSDOOR                13     14
     D  DSMEAT                15     15
     D  DSCODE                16     16
     D  DSRVS                 19     19
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
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PCMD             8
     C                   PARM                    $PRTE#            5
     C                   PARM                    $PRTID            5
     C                   PARM                    $PPRG            10
     C                   PARM                    $PRTN             8
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   EXSR      ZZINZ1
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C                   ENDCS
     C*
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   SETON                                        LR
     C*----------------------------------------------------------------
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
     CSR                 EXFMT     WINDW1
     CSR                 END
     C*
     C     NXTSCR        IFEQ      '02 '
     C                   WRITE     WINDW1
     C                   WRITE     WINDW2
     C                   EXFMT     WINDW2
     C                   ENDIF
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       040506
     CSR                 SETOFF                                       070809
     CSR                 SETOFF                                       101112
     CSR                 SETOFF                                       1314
     CSR                 SETOFF                                       1920
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
     CSR                 SETOFF                                       333435
     CSR                 SETOFF                                       3670
     CSR                 SETOFF                                       98
      *
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CMDTKN            1
      *
     CSR                 Z-ADD     0             E                 2 0
      *
     C*   Prod Integrity info is no required if HACCP flag = 'Y'
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen1
     C*
     C*----------------------------------------------------------------
     CSR   SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR            3
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      '1'
     C     $PCMD         IFNE      '*VIEW   '
     C                   EXSR      ZZINZ1
     C                   END
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys
     C*
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*     Check input and write/update record.
     C*
     C     $PCMD         IFNE      '*VIEW   '
     C     LESTAT        ANDNE     'C'
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     '1'           ENDSC1
     C*
     C                   MOVE      '02 '         NXTSCR
     C                   ENDIF
      *
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*  SC2  -  Windw2
     C*----------------------------------------------------------------
     C     SC2           BEGSR
     C*
     C*     Check input and write record
     C*
     C                   EXSR      ZZCHK2
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C     YN            IFEQ      'N'
     C                   MOVE      '01 '         NXTSCR
     C                   MOVE      *BLANK        YN
     C                   SETON                                        01
     C                   GOTO      ENDSC2
     C                   ENDIF
      *
     C     UPDT          IFEQ      '1'
      *    Update loader trailer equipment files.
     C                   EXSR      ZZUPDT
     c                   ENDIF
     C*
     C                   MOVE      '*OK     '    $PRTN
     C                   MOVE      'EOJ'         NXTSCR
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFNAM   Format loader name.
     C*
     C*----------------------------------------------------------------
     CSR   ZZFNAM        BEGSR
     C*
     C                   MOVE      *BLANKS       W1USER
     C                   MOVE      *BLANKS       FNAME
     C                   MOVE      *BLANKS       LNAME
     C*
     C                   MOVE      USEMP#        W1LDR#
     C                   MOVE      USEMP#        W1LDR#
     C                   MOVE      USEMP#        LTEMP#
     C     ' '           SCAN      USFNAM        P1                2 0
     C     P1            SUBST     USFNAM:1      FNAME            12
     C     ' '           SCAN      USLNAM        P2                2 0
     C     P2            SUBST     USLNAM:1      LNAME            16
     C     FNAME         CAT       LNAME:1       W1USER
     C*
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C*----------------------------------------------------------------
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
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*---------------------------------------------------------------
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
     C*---------------------------------------------------------------
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     C*---------------------------------------------------------------
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     C*---------------------------------------------------------------
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
     C*---------------------------------------------------------------
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C*---------------------------------------------------------------
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     C*---------------------------------------------------------------
     CSR   ZSCLR         BEGSR
     CSR                 WRITE     CLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C*---------------------------------------------------------------
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
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
     C*      PIR0105 Gneric message
     C*
     C*----------------------------------------------------------------
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEL     ERRMSG        $MD(1)
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
     C*    PIR0203  Value cannot be blank.
     C*
     C*----------------------------------------------------------------
     CSR   ZM0203        BEGSR
     CSR                 MOVE      'PIR0203'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     C*----------------------------------------------------------------
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Window1 and Window2 error checking.
     C*
     C*----------------------------------------------------------------
     CSR   ZZCHK1        BEGSR
      *
     C                   MOVE      '0'           ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      '0'           UPDT              1
     C                   MOVE      '0'           FRFIL
      *
      *  Check if user id is found in user file. This piece was cancelled
      *  because Employee # is a required input field and the authorized
      *  access check is done by the routine that follows.
      *
     C*>   #USER         CHAIN     PIRUSER                            79
     C*>   *IN79         IFEQ      *ON
     C*>                 MOVE      *ON           ERROR
     C*>                 MOVE      *ON           *IN01
     C*>                 MOVE      *ON           *IN21
     C*>                 MOVEA     DESC(1)       ERRMSG
     C*>                 GOTO      ENDCK1
     C*>                 ENDIF
      *
      *  Check if the employee trying to do the trailer equipment
      *  closing is a valid empl # and is allowed to do the update.
      *
     C                   Z-ADD     W1EMP#        EMP#5
     C     EMP#5         CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN10
     C                   MOVE      *ON           *IN20
     C                   MOVEA     DESC(3)       ERRMSG
     C                   GOTO      ENDCK1
     C                   ENDIF
     C*
     C*  Verify if user has update authorization.
     C*
     C                   CALL      'CHKLIST'
     C                   PARM                    #PROG
     C                   PARM                    OPTION            2 0
     C                   PARM                    USCODE
     C                   PARM      ' '           @PRTN             8
     C*
     C     @PRTN         IFEQ      '*NO'
     C                   MOVE      '1'           ERROR
     C                   MOVE      *ON           *IN10
     C                   MOVE      *ON           *IN20
     C                   MOVEL     DESC(4)       ERRMSG
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
     C     W1BK2         IFNE      *BLANKS
     C     DIGITS        CHECK     W1BK2                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN21
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1BK2         HOLD4             4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTBK2
     C     LTBK1         SUB       LTBK2         LTSO1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN21
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1BH2         IFNE      *BLANKS
     C     DIGITS        CHECK     W1BH2                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN02
     C                   MOVE      *ON           *IN22
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1BH2         HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTBH2
     C     LTBH1         SUB       LTBH2         LTSO2
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN02
     C                   MOVE      *ON           *IN22
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1LB2         IFNE      *BLANKS
     C     DIGITS        CHECK     W1LB2                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN03
     C                   MOVE      *ON           *IN23
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1LB2         HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTLB2
     C     LTLB1         SUB       LTLB2         LTSO3
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN03
     C                   MOVE      *ON           *IN23
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICS2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICS2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN04
     C                   MOVE      *ON           *IN24
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1ICS2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICS2
     C     LTICS1        SUB       LTICS2        LTSO4
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN04
     C                   MOVE      *ON           *IN24
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICM2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICM2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN05
     C                   MOVE      *ON           *IN25
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1ICM2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICM2
     C     LTICM1        SUB       LTICM2        LTSO5
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN05
     C                   MOVE      *ON           *IN25
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICL2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICL2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN06
     C                   MOVE      *ON           *IN26
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1ICL2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICL2
     C     LTICL1        SUB       LTICL2        LTSO6
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN06
     C                   MOVE      *ON           *IN26
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1SFB2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1SFB2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN07
     C                   MOVE      *ON           *IN27
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1SFB2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTSFB2
     C     LTSFB1        SUB       LTSFB2        LTSO7
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN07
     C                   MOVE      *ON           *IN27
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1SPL2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1SPL2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN08
     C                   MOVE      *ON           *IN28
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1SPL2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTSPL2
     C     LTSPL1        SUB       LTSPL2        LTSO8
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN08
     C                   MOVE      *ON           *IN28
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     W1TPL2        IFNE      *BLANKS
     C     DIGITS        CHECK     W1TPL2                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN09
     C                   MOVE      *ON           *IN29
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ELSE
     C                   MOVEL     W1TPL2        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTTPL2
     C     LTTPL1        SUB       LTTPL2        LTSO9
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN09
     C                   MOVE      *ON           *IN29
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   ENDIF
     C                   ENDIF
      *
     C     ERROR         IFEQ      *OFF
     C     W1BK2         ANDNE     *BLANKS
     C                   MOVE      '1'           UPDT              1
     C                   ENDIF
      *
     C     ENDCK1        ENDSR
      *
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C*----------------------------------------------------------------
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
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK2   Window2 error checking.
     C*----------------------------------------------------------------
     C     ZZCHK2        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *OFF          *IN70
     C*
     C*   Verify input is either 'Y' or 'N'
     C*
     C     YN            IFNE      'Y'
     C     YN            ANDNE     'N'
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN70
     C                   ENDIF
     C*
     C     ENDCK2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCONV   Convert character input to numeric value.
     C*
     C*----------------------------------------------------------------
     CSR   ZZCONV        BEGSR
      *
     C     FRFIL         IFEQ      '1'
     C                   GOTO      FRMFIL
     C                   ENDIF
      *
     C                   MOVE      '0000'        A4
     C                   MOVE      '0000'        CVALI
     C                   MOVE      ' '           HOLD1             1
     C                   Z-ADD     4             P1
     C                   Z-ADD     4             P2
      *
     C     P1            DOWNE     *ZEROS
     C                   SUBST     HOLD4:P1      HOLD1
     C     HOLD1         IFNE      *BLANK
     C                   MOVEA     HOLD1         A4(P2)
     C                   SUB       1             P2
     C                   ENDIF
     C                   SUB       1             P1
     C                   ENDDO
     C                   MOVEA     A4            CVALI
     C                   GOTO      ENDCNV
      *
      *
     C     FRMFIL        TAG
      *
     C                   MOVE      *BLANKS       A4
     C                   MOVE      *BLANKS       CVALO             4
     C                   MOVE      ' '           HOLD1
     C                   Z-ADD     1             P1
     C                   Z-ADD     1             P2
      *
     C     P1            DOWNE     5
     C                   SUBST     HOLD4:P1      HOLD1
     C     HOLD1         IFNE      '0'
     C     P2            ORGT      1
     C                   MOVEA     HOLD1         A4(P2)
     C                   ADD       1             P2
     C                   ENDIF
     C                   ADD       1             P1
     C                   ENDDO
     C                   MOVEA     A4            CVALO
      *
     CSR   ENDCNV        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ1   Program initialization. Called from main line.
     C*
     C*----------------------------------------------------------------
     CSR   ZZINZ1        BEGSR
     C*
     C                   MOVE      $PWHSE        PWHSE             3 0
     CSR                 MOVE      #PROG         $PPRG
     C*
     C*  Define key for main file.
     C*
     C     TRLKEY        KLIST
     C                   KFLD                    PWHSE
     C                   KFLD                    HLDTRL            8
     C*
     C     HDRKEY        KLIST
     C                   KFLD                    PWHSE
     C                   KFLD                    $PRTE#
     C                   KFLD                    $PRTID
      *
     C     RTKEY         KLIST
     C                   KFLD                    PWHSE
     C                   KFLD                    $PRTID
      *
     C*
     C*  Convert today's date into century format.
     C*
     C*>                   MOVE '*CURMDY '$CVCMD
     C*                    CALL @CVTDT
     C*                    PARM           $CVTDT
     C*                    Z-ADD$CVD6O    W1FMDT
     C*>                   Z-ADD$CVD6O    W1TODT
     C*
     C     HDRKEY        CHAIN     LDRHHDR                            79
     C*
     C     *IN79         IFEQ      *OFF
     C                   MOVE      LHHSTT        W1STRT
     C                   MOVEL     LHHRTE        W1RTE#
     C                   MOVE      LHHTRL        W1TRL#
     C                   MOVE      LHHDOR        W1LDR#
     C                   MOVE      *BLANKS       W1BK1
     C                   MOVE      *BLANKS       W1BK2
     C                   MOVE      *BLANKS       W1SO1
     C                   MOVE      *BLANKS       W1BH1
     C                   MOVE      *BLANKS       W1BH2
     C                   MOVE      *BLANKS       W1SO2
     C                   MOVE      *BLANKS       W1LB1
     C                   MOVE      *BLANKS       W1LB2
     C                   MOVE      *BLANKS       W1SO3
     C                   MOVE      *BLANKS       W1ICS1
     C                   MOVE      *BLANKS       W1ICS2
     C                   MOVE      *BLANKS       W1SO4
     C                   MOVE      *BLANKS       W1ICM1
     C                   MOVE      *BLANKS       W1ICM2
     C                   MOVE      *BLANKS       W1SO5
     C                   MOVE      *BLANKS       W1ICL1
     C                   MOVE      *BLANKS       W1ICL2
     C                   MOVE      *BLANKS       W1SO6
     C                   MOVE      *BLANKS       W1SFB1
     C                   MOVE      *BLANKS       W1SFB2
     C                   MOVE      *BLANKS       W1SO7
     C                   MOVE      *BLANKS       W1SPL1
     C                   MOVE      *BLANKS       W1SPL2
     C                   MOVE      *BLANKS       W1SO8
     C                   MOVE      *BLANKS       W1TPL1
     C                   MOVE      *BLANKS       W1TPL2
     C                   MOVE      *BLANKS       W1SO9
     C                   MOVE      *BLANKS       ERRMSG
     C*
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LHHSTD        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1DATE
      *
      *
      *  Get loading door number
     C                   MOVE      LHHDOR        W1DOOR
     C                   ENDIF
      *
     C                   MOVE      '01 '         NXTSCR
     C     BYPAS1        TAG
      *
     C                   MOVE      '0'           FRFIL             1
      *
     C     HDRKEY        CHAIN     LDRTEQ                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      '1'           FRFIL
      *
     C     HDRKEY        CHAIN     LDRTRLE1                           79
     C     *IN79         IFEQ      *OFF
     C     $PCMD         ANDEQ     '*VIEW   '
     C                   SETON                                        90
     C                   ENDIF
      *
     C     LTBK1         IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1BK1
     C                   ELSE
     C                   MOVEL     LTBK1         HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1BK1
     C                   ENDIF
      *
     C     LTBK2         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1BK2
     C                   ELSE
     C                   MOVEL     LTBK2         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1BK2
     C                   ENDIF
      *
     C     LTSO1         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1SO1
     C                   MOVEL     '0'           W1SO1B
     C                   ELSE
     C                   MOVEL     LTSO1         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C                   MOVEL     CVALO         W1SO1
     C                   MOVEL     CVALO         W1SO1B
     C                   ELSE
     C     LTSO1         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO1
     C*>                 MOVEL     '0'           W1SO1B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO1B
     C*>                 MOVEL     '0'           W1SO1
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTBH1         IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1BH1
     C                   ELSE
     C                   MOVEL     LTBH1         HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1BH1
     C                   ENDIF
      *
     C     LTBH2         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1BH2
     C                   ELSE
     C                   MOVEL     LTBH2         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1BH2
     C                   ENDIF
      *
     C     LTSO2         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO2
     C*>                 MOVEL     '0'           W1SO2B
     C                   ELSE
     C                   MOVEL     LTSO2         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO2
     C*>                 MOVEL     CVALO         W1SO2B
     C                   ELSE
     C     LTSO2         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO2
     C*>                 MOVEL     '0'           W1SO2B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO2B
     C*>                 MOVEL     '0'           W1SO2
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTLB1         IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1LB1
     C                   ELSE
     C                   MOVEL     LTLB1         HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1LB1
     C                   ENDIF
      *
     C     LTLB2         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1LB2
     C                   ELSE
     C                   MOVEL     LTLB2         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1LB2
     C                   ENDIF
      *
     C     LTSO3         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO3
     C*>                 MOVEL     '0'           W1SO3B
     C                   ELSE
     C                   MOVEL     LTSO3         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO3
     C*>                 MOVEL     CVALO         W1SO3B
     C                   ELSE
     C     LTSO3         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO3
     C*>                 MOVEL     '0'           W1SO3B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO3B
     C*>                 MOVEL     '0'           W1SO3
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTICS1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1ICS1
     C                   ELSE
     C                   MOVEL     LTICS1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1ICS1
     C                   ENDIF
      *
     C     LTICS2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1ICS2
     C                   ELSE
     C                   MOVEL     LTICS2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICS2
     C                   ENDIF
      *
     C     LTSO4         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO4
     C*>                 MOVEL     '0'           W1SO4B
     C                   ELSE
     C                   MOVEL     LTSO4         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO4
     C*>                 MOVEL     CVALO         W1SO4B
     C                   ELSE
     C     LTSO4         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO4
     C*>                 MOVEL     '0'           W1SO4B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO4B
     C*>                 MOVEL     '0'           W1SO4
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTICM1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1ICM1
     C                   ELSE
     C                   MOVEL     LTICM1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1ICM1
     C                   ENDIF
      *
     C     LTICM2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1ICM2
     C                   ELSE
     C                   MOVEL     LTICM2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICM2
     C                   ENDIF
      *
     C     LTSO5         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO5
     C*>                 MOVEL     '0'           W1SO5B
     C                   ELSE
     C                   MOVEL     LTSO5         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO5
     C*>                 MOVEL     CVALO         W1SO5B
     C                   ELSE
     C     LTSO5         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO5
     C*>                 MOVEL     '0'           W1SO5B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO5B
     C*>                 MOVEL     '0'           W1SO5
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTICL1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1ICL1
     C                   ELSE
     C                   MOVEL     LTICL1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1ICL1
     C                   ENDIF
      *
     C     LTICL2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1ICL2
     C                   ELSE
     C                   MOVEL     LTICL2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICL2
     C                   ENDIF
      *
     C     LTSO6         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO6
     C*>                 MOVEL     '0'           W1SO6B
     C                   ELSE
     C                   MOVEL     LTSO6         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO6
     C*>                 MOVEL     CVALO         W1SO6B
     C                   ELSE
     C     LTSO6         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO6
     C*>                 MOVEL     '0'           W1SO6B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO6B
     C*>                 MOVEL     '0'           W1SO6
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTSFB1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1SFB1
     C                   ELSE
     C                   MOVEL     LTSFB1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1SFB1
     C                   ENDIF
      *
     C     LTSFB2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1SFB2
     C                   ELSE
     C                   MOVEL     LTSFB2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1SFB2
     C                   ENDIF
      *
     C     LTSO7         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO7
     C*>                 MOVEL     '0'           W1SO7B
     C                   ELSE
     C                   MOVEL     LTSO7         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO7
     C*>                 MOVEL     CVALO         W1SO7B
     C                   ELSE
     C     LTSO7         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO7
     C*>                 MOVEL     '0'           W1SO7B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO7B
     C*>                 MOVEL     '0'           W1SO7
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTSPL1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1SPL1
     C                   ELSE
     C                   MOVEL     LTSPL1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1SPL1
     C                   ENDIF
      *
     C     LTSPL2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1SPL2
     C                   ELSE
     C                   MOVEL     LTSPL2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1SPL2
     C                   ENDIF
      *
     C     LTSO8         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO8
     C*>                 MOVEL     '0'           W1SO8B
     C                   ELSE
     C                   MOVEL     LTSO8         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO8
     C*>                 MOVEL     CVALO         W1SO8B
     C                   ELSE
     C     LTSO8         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO8
     C*>                 MOVEL     '0'           W1SO8B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO8B
     C*>                 MOVEL     '0'           W1SO8
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
     C     LTTPL1        IFEQ      *ZEROS
     C*>                 MOVEL     '0'           W1TPL1
     C                   ELSE
     C                   MOVEL     LTTPL1        HOLD4
     C                   EXSR      ZZCONV
     C*>                 MOVEL     CVALO         W1TPL1
     C                   ENDIF
      *
     C     LTTPL2        IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C                   MOVEL     '0'           W1TPL2
     C                   ELSE
     C                   MOVEL     LTTPL2        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1TPL2
     C                   ENDIF
      *
     C     LTSO9         IFEQ      *ZEROS
     C     LESTAT        ANDEQ     'C'
     C*>                 MOVEL     '0'           W1SO9
     C*>                 MOVEL     '0'           W1SO9B
     C                   ELSE
     C                   MOVEL     LTSO9         HOLD4
     C                   EXSR      ZZCONV
     C     CVALO         IFEQ      *BLANKS
     C*>                 MOVEL     CVALO         W1SO9
     C*>                 MOVEL     CVALO         W1SO9B
     C                   ELSE
     C     LTSO9         IFLT      *ZERO
     C*>                 MOVEL     CVALO         W1SO9
     C*>                 MOVEL     '0'           W1SO9B
     C                   ELSE
     C*>                 MOVEL     CVALO         W1SO9B
     C*>                 MOVEL     '0'           W1SO9
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *
      *  Set name of user found in record
      *  (trailer equipment info already existed).
      *
     C     LTEMP#        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN26
     C                   MOVEA     DESC(1)       ERRMSG
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   ENDIF
      *
      *
     C     LTLDTE        IFNE      *ZEROS
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LTLDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1DATE
     C                   Z-ADD     LTLTIM        W1STRT
     C                   ENDIF
      *
      *  Set name of return user verifying trailer equipment (NO USED)
      *
     C*>   #USER         CHAIN     PIRUSER                            79
     C*    *IN79         IFEQ      *ON
     C* If needed, see   MOVE      *ON           ERROR
     C* Loadr56 L# 939.02MOVE      *ON           *IN01
     C*                  MOVE      *ON           *IN26
     C*                  MOVEA     DESC(1)       ERRMSG
     C*                  ELSE
     C*                  EXSR      ZZFNAM
     C*>                 ENDIF
      *
     C                   MOVEL     LTDNAM        W1DNAM
     C                   ELSE
     C                   MOVE      '0'           UPDT
     C                   ENDIF
      *
     CSR   ENDINZ        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPDT
     C*
     C*----------------------------------------------------------------
     CSR   ZZUPDT        BEGSR
     C*
      *    Update loader trailer equipment file - Ldrteq
410 AC                   MOVE      '*CURCMD '    $CVCMD
410 AC                   CALL      @CVTDT
410 AC                   PARM                    $CVTDT
410 AC                   Z-ADD     $CVD8O        LTRDTE
410 AC                   TIME                    LTRTIM
     C                   Z-ADD     USEMP#        LTREMP
     C                   MOVE      'C'           LTSTAT
     C                   UPDATE    LTREC
      *
      *    Update return trailer equipment file - Ldrtrle
     C                   MOVE      'C'           LESTAT
     C                   UPDATE    EQREC
      *
     CSR   ENDUPD        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZVIEW   Trailer/Loader info (View Mode).
     C*
     C*----------------------------------------------------------------
     CSR   ZZVIEW        BEGSR
     C*
     C*
     C     TOP           TAG
     C                   SETOFF                                       202124
     C                   SETON                                        2990
     C                   Z-ADD     1             ONE               2 0
     C*
     C*>   HDRKEY        CHAIN     LDRHDR                             79
     C*    *IN79         IFEQ      *OFF
     C*   Load current Trailer/Loader info on screen
     C*                  MOVE      LHRTE         W1RTE#
     C*                  MOVE      LHEMP#        W1LDR#
     C*                  MOVEL     LHTRLR        W1TRL#
     C*    LHEMP#        CHAIN     PIRUSER1                           78
     C*    *IN78         IFEQ      *OFF
     C*                  EXSR      ZZFNAM
     C*                  ENDIF
     C*
     C*    LHSTRD        IFEQ      0
     C*>                 Z-ADD     0             W1DTEC
     C*                  ELSE
     C*                  MOVE      '*CMDMDY '    $CVCMD
     C*                  MOVE      LHSTRD        $CVD8I
     C*                  CALL      @CVTDT
     C*                  PARM                    $CVTDT
     C*                  Z-ADD     $CVD6O        W1DTEC
     C*                  ENDIF
     C*>                 ENDIF
     C*
     C*
      *
     O*----------------------------------------------------------------*********
     O*
      *
     CSR                 ENDSR
     C*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*
**  DESC
User not found
Invalid input, type a numeric value
Invalid Employee #
Not authorized to use option (2=Close)
