     F*----------------------------------------------------------------
     F*   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. LOAD16FM WILL BE REPALCED WITH LOAD1601
     *----------------------------------------------------------------
     F*
     F*  LOADR16   Loader/Trailer View - Loader Module
     F*  January 11, 2007
     F*  Jose Duque
     F*
     F*  Revisions:
     F*
530 A*    06/30/10  JCJ  5.30
     *      - Converted to RPGIV.
     *      - Recompiled becuase w1trl# changed from 6 to 8 in length.
530bA*    07/08/10  RH   5.30b
     *      - Enh: Added client custom code support to program.
     *      - Enh: Display dock door assinged in truck builder.       .
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
CBI AF*    07/08/10  RH   CBI
     F*      - Use door from OHMISC for Cheney only.
     F*
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
530 D ***LOAD16FM  CF   E             WORKSTN
530 MFLOAD1601  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FPIRUSER   IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
     F                                     RENAME(USREC:USREC1)
     FLRSNCODE  IF   E           K DISK
     FLDRHHDR   IF   E           K DISK
     FLDREXCP2  IF   E           K DISK
     FORDH1     IF   E           K DISK
     FRTEHED    IF   E           K DISK
530bAFDocmtrx2  if   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             70    DIM(15) CTDATA PERRCD(1)
     *----------------------------------------------------------------
530 A*  Client ID's
     *
CLD A /COPY QCOPYSRC,ID#CHENEY
     *
530 AD @getcl          c                   const('GETCLIENT')
     *
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
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
     C                   PARM                    $PWHSE            3 0
     C                   PARM                    $PRTE#            5
     C                   PARM                    $PRTID            5
     C                   PARM                    $PSTRD            8
     C                   PARM                    $PSTRT            6
     C                   PARM                    $PTLR#            8
     C                   PARM                    $PEMP#            5
     C                   PARM                    $PPRG            10
     C                   PARM                    $PAORC            1
     C                   PARM                    $PCOM1           35
     C                   PARM                    $PCOM2           35
     C                   PARM                    $PRCDE            2
     C                   PARM                    $PRTN             8
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
     CSR                 SETOFF                                       98
      *
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CMDTKN            1
      *
     CSR                 Z-ADD     0             E                 2 0
      *
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
      *
     C     ENDSC1        ENDSR
      *
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
     C                   MOVE      USEMP#        $PEMP#
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
     *
530 A*  Get Client ID
     *
530 AC                   call      @getcl
530 AC                   parm                    client           10
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
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C*----------------------------------------------------------------
     CSR   ZZCMD1        BEGSR
     CSR                 MOVE      '0'           CMDTKN
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ1   Program initialization. Called from main line.
     C*
     C*----------------------------------------------------------------
     CSR   ZZINZ1        BEGSR
     C*
     C*  Define key for main file.
     C*
     C     TRLKEY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    HLDTRL            8
     C*
     C     RCDEKY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    LEREAS
      *
     C     HDREKY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTE#
     C                   KFLD                    $PRTID
      *
     C     HDRKEY        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTE#
     C                   KFLD                    $PRTID
     C                   KFLD                    PSTRD
     C                   KFLD                    PSTRT
      *
     C     RTKEY         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
      *
     C     OHKEY         KLIST
     C                   KFLD                    RHPBAT
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     *
530b C     dckey         klist
530b C                   kfld                    $pwhse
530b C                   kfld                    $prtid
      *
     C                   MOVE      $PSTRD        PSTRD             8 0
     C                   MOVE      $PSTRT        PSTRT             6 0
     C                   MOVEL     $PRTE#        W1RTE#
     C                   MOVE      *BLANKS       W1TRL#
     C                   MOVE      *ZEROS        W1LDR#
     C                   MOVE      *BLANKS       W1USER
     C                   MOVE      *BLANKS       W1COM1
     C                   MOVE      *BLANKS       W1COM2
     C                   MOVE      *BLANKS       W1REAS
     C                   MOVE      *BLANKS       ERRMSG
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
     C*
     C*  Check if viewing assigned route
     C*
     C     $PAORC        IFEQ      'V'
     C                   EXSR      ZZVIEW
     C                   GOTO      ENDINZ
     C                   ENDIF
      *
      *  Set name of initially assigned loader
      *  assigning loader and trailer 1st time
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN26
     C                   MOVEA     DESC(15)      ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   ENDIF
      *
     C                   MOVE      '01 '         NXTSCR
     C     BYPAS1        TAG
      *
     CSR   ENDINZ        ENDSR
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
     C     HDRKEY        CHAIN     LDRHHDR                            79
     C     *IN79         IFEQ      *OFF
     C*   Load current Trailer/Loader info on screen
     C                   MOVE      LHHRTE        W1RTE#
     C                   MOVE      LHHEMP        W1LDR#
     C                   MOVEL     LHHTRL        W1TRL#
     C                   Z-ADD     LHHSTT        W1TIMC
     C     LHHEMP        CHAIN     PIRUSER1                           78
     C     *IN78         IFEQ      *OFF
     C                   EXSR      ZZFNAM
     C                   ENDIF
     C*
     CSR   LHHSTD        IFEQ      0
     CSR                 Z-ADD     0             W1DTEC
     CSR                 ELSE
     CSR                 MOVE      '*CMDMDY '    $CVCMD
     CSR                 MOVE      LHHSTD        $CVD8I
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD6O        W1DTEC
     CSR                 ENDIF
     C*
     C*
      *
      *   Set read pointer to header exception file 'Ldrexcp2'
      *
     C     HDREKY        SETLL     LDREXCP2
     C     ONE           DOWEQ     1
     CSR                 EXFMT     WINDW1                               50
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR            3
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 LEAVE
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 LEAVE
     CSR                 END
      *
      *   See if this route has any exception record
      *
     C     HDREKY        READE(N)  LDREXCP2                               79
     C     *IN79         IFEQ      *ON
     C     *IN29         ANDEQ     *ON
     C                   MOVE      *ON           ERROR
     C*
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(7)       ERRMSG
     C                   EXSR      ZM0105
      *
      *   Overlay screen with informative messages
      *
     C                   EXSR      ZMDMSG
     C                   ENDIF
     C                   GOTO      DOBACK
     C                   ENDIF
      *
      *   End of exception records.
      *
     C     *IN79         IFEQ      *ON
     C     *IN29         ANDEQ     *OFF
     C                   SETOFF                                       28
     C                   GOTO      TOP
     C                   ENDIF
     C*
     C*   Load exception record on screen
      *
     C     *IN79         IFEQ      *OFF
     C                   SETON                                        202128
     C                   SETON                                        30
     C                   SETOFF                                       29
     C                   MOVE      LERTE         W1RTE#
     C                   MOVE      LEEMP#        W1LDR#
     C                   MOVEL     LETRLR        W1TRL#
     C                   Z-ADD     LESTIM        W1TIME
     C                   MOVE      LECOM1        W1COM1
     C                   MOVE      LECOM2        W1COM2
     C     RCDEKY        CHAIN     LRSNCODE                           79
     C                   MOVEL     LRSDSC        W1REAS
     C     LEEMP#        CHAIN     PIRUSER1                           78
     C     *IN78         IFEQ      *OFF
     C                   EXSR      ZZFNAM
     C                   ENDIF
     C                   ENDIF
     C*
     CSR   LESDTE        IFEQ      0
     CSR                 Z-ADD     0             W1DTEE
     CSR                 ELSE
     CSR                 MOVE      '*CMDMDY '    $CVCMD
     CSR                 MOVE      LESDTE        $CVD8I
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD6O        W1DTEE
     CSR                 ENDIF
     C*
      *
     C     DOBACK        TAG
     CSR                 ENDDO
     C*
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
      *
     O*----------------------------------------------------------------*********
     O*
      *
     CSR                 ENDSR
     C*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*
**  DESC
Valid trailer #                                                           1
Valid reason code                                                         2
Valid employee #                                                          3
Invalid input values, they cannot be blanks                               4
Input trailer # is being used by route                                    5
Comment is required when changing trailer                                 6
No exception found for this route                                         7
Trailer changed, reason code must be '4'                                  8
Loader & trailer changed, reason code must be '6'                         9
Comment is required when changing loader & trailer                       10
Wrong reason code, trailer was not changed                               11
Make a change or press F3 or F12 to go prev screen                       12
Comment is required when unloading trailer                               13
Reason code 7 allowed when unloading trailer only                        14
Rte can't be assigned, user not found in user file                       15
