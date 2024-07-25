     F*----------------------------------------------------------------
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. LOAD4BFM WILL BE REPALCED WITH LOAD4B01
     *----------------------------------------------------------------
     F*
     F*  LOADR4B   Pallet History View Screen - Loader Module
     F*  January 26, 2007
     F*  Jose Duque
     F*
     F*  Revisions
     F*
530 A*    06/30/10  JCJ  5.30
     *      - Converted to RPGIV.
     *      - Recompiled becuase w1trl# changed from 6 to 8 in length.
     *
530aA*    07/06/10  RBD  5.30a
     *      - Fix: HDRKEY key field $HDRID should be $PRTID.
530bA*    07/08/10  RH   5.30b
     *      - Enh: Added client custom code support to program.
     *      - Enh: Display dock door assinged in truck builder.       .
     *
650aA*    01/20/15  RBD  6.50a
     *      - Recompiled, LDRHDETL file changed.
     *
     F*----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
     F*    ##/##/##  XXX-XXX
     F*      - Text . . .
     F*----------------------------------------------------------------
     F*  Cheney Custom Revisions:
CBI AF*    07/08/10  RH   CBI
     F*      - Use door from OHMISC for Cheney only.
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
530 D***LOAD4BFM  CF   E             WORKSTN
530 MFLOAD4B01  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     F*PIRUSER IF  E           K        DISK
     F*
     FPIRUSER1  IF   E           K DISK
     F                                     RENAME(USREC:USREC1)
     F*
     FORDH1     IF   E           K DISK
530bAFDocmtrx2  if   e           k disk
     F*
     FRTEHED    IF   E           K DISK
     F*
     FLDRHHDR   IF   E           K DISK
     F*
     FLDRHDTL2  IF   E           K DISK
     F*
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     *
CBI A /COPY QCOPYSRC,ID#CHENEY
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D $PARMS          DS
     D  $PWHSE                 1      3  0
     D  $PRTE#                 4      8
     D  $PRTID                 9     13
     D  $PLTID                14     20  0
      *
     D*>                                      1   30$PWHSE
     D*                                       4   8 $PRTE#
     D*                                       9  150$PLTID
     D*                                      16  210$PLSTD
     D*                                      22  26 $PRTID
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
530bAD @getcl          c                   const('GETCLIENT')
     D*----------------------------------------------------------------
     D*  Called program parameters
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
     C                   PARM                    $PARMS
     C                   PARM                    $PSTRD            8
     C                   PARM                    $PSTRT            6
     C                   PARM                    $PPRG            10
     C                   PARM                    $PRTN             8
     C                   PARM                    $HDRID            5
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   EXSR      ZZINZ1
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   ENDCS
     C*
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   SETON                                        LR
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
     CSR                 EXFMT     WINDW1                               50
     CSR                 END
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
     CSR                 SETOFF                                         2526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
     CSR                 SETOFF                                       333435
     CSR                 SETOFF                                       36
     CSR                 SETOFF                                       9098
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
     CSR                 EXSR      ZMCMSG
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
     C*> Test for F5 - Refresh
     C*>
     C*>         *INKE     IFEQ '1'
     C*>         $PCMD     IFNE '*VIEW   '
     C*>                   EXSR SCR01I
     C*>                   END
     C*>                   GOTO ENDSC1
     C*>                   END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C                   MOVE      '*OK     '    $PRTN
      *
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     *
530bA*  Get Client ID
     *
530bAC                   call      @getcl
530bAC                   parm                    client           10
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
     CSR                 MOVEA     ERRMSG        $MD(1)
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
     C     $PRTN         IFEQ      'VIEW    '
     C                   MOVE      LDHEMP        W1LDR#
     C                   ELSE
     C                   MOVE      USEMP#        W1LDR#
     C                   ENDIF
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
     C*  ZZINZ1   Program initialization. Called from main line.
     C*
     CSR   ZZINZ1        BEGSR
      *
      *  Define key for main file.
      *
     C     TRLKEY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    HLDTRL            8
     C*>                   KFLD           W1TRL#
     C*
     C     RCDEKY        KLIST
     C                   KFLD                    $PWHSE
     C*>                   KFLD           W1RCDE
      *
     C     HDRKEY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTE#
530aDC**                 KFLD                    $HDRID
530aMC                   KFLD                    $PRTID
     C                   KFLD                    PSTRD
     C                   KFLD                    PSTRT
      *
     C     DTLKEY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTE#
     C                   KFLD                    $PRTID
     C                   KFLD                    $PLTID
      *
     C     DTLKY2        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTE#
      *
     C     RTKEY         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
      *
     C     OHKEY         KLIST
     C                   KFLD                    RHPBAT
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
      *
     * Dock Door key
530b C     dckey         klist
530b C                   kfld                    $pwhse
530b C                   kfld                    $prtid
      *
     C*
     C                   MOVEL     $PRTE#        W1RTE#
     C                   MOVE      $PSTRD        PSTRD             8 0
     C                   MOVE      $PSTRT        PSTRT             6 0
     C*
     C*---->     $PRTN     IFEQ 'VIEW    '                 Viewing a
     C                   Z-ADD     $PLTID        W1PLT#
     C                   SETON                                        9091
     C                   MOVE      *BLANKS       $PRTN
      *
      *
     C     DTLKEY        CHAIN(N)  LDRHDTL2                           7978
      *
      * Check if record is in use
     C     *IN78         IFEQ      *ON
     C                   MOVE      '*LOCKED '    $PRTN
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDINZ
     C                   ENDIF
      *
     C     *IN79         IFEQ      *OFF
     C     LDHEMP        CHAIN(N)  PIRUSER1                           79
     C     *IN79         IFEQ      *OFF
     C                   EXSR      ZZFNAM
     C                   ENDIF
     C                   ELSE
     C                   Z-ADD     *ZEROS        W1LDR#
     C                   ENDIF
      *
     C     HDRKEY        CHAIN(N)  LDRHHDR                            79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     LHHTRL        W1TRL#
     C                   ENDIF
      *
     C*>                   ELSE
     C*          #USER     CHAINPIRUSER              79
     C*          *IN79     IFEQ *OFF
     C*                    EXSR ZZFNAM
      *
      * If want pallet to show
     C*                    Z-ADD$PLTID    W1PLT#           loading a
     C*                    MOVE *BLANKS   W1TRL#           pallet
     C*                    SETON                     27
     C*                    ENDIF
      *
      * Check if record is in use
     C*          DTLKEY    CHAINLDRHDTL2             7978
     C*          *IN78     IFEQ *ON
     C*                    MOVE '*LOCKED '$PRTN
     C*                    MOVE 'EOJ'     NXTSCR
     C*                    GOTO ENDINZ
     C*                    ENDIF
      *
     C*---->               ENDIF
      *
      *
      *  Get loading door number
     C                   MOVE      *BLANKS       W1DOOR
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *OFF
      *
530b C                   SELECT
530bAC                   WHEN      CLIENT = CHENEY
     C     OHKEY         SETLL     ORDH1
     C     OHKEY         READE     ORDH1                                  79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      OHMISC        DSMISC
     C                   MOVEL     DSDOOR        W1DOOR
     C                   ENDIF
530bAC                   other
530bAC     dckey         setll     docmtrx2
530bAC     dckey         reade     docmtrx2                               79
530bAC                   if        not *in79
530bAC                   move      dmdoor        w1door
530bAC                   endif
530bAC                   endsl
     C                   ENDIF
      *
     C     BYPAS1        TAG
     C                   MOVE      '01 '         NXTSCR
     CSR   ENDINZ        ENDSR
