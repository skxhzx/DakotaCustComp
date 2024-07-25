      /copy qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  POPTCDE Po Special Status Table Lookup.
     F*  April 13, 2011
     F*  Jose G. Duque
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
640 AF*    04/13/11  JGD  6.40
     F*      - Created
     F*
     F*---------------------------------------------------------------
     F*  INDICATOR USAGE
     F*
     F*  20        POSITION CURSOR
     F*  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  79        CHAIN INDICATOR
     F*  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*---------------------------------------------------------------
     F*  FILE SPECS
     F*
     FPOPTCDEFM CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FWORKOPT   UF A E           K DISK
     FPOPTCDE   IF   E           K DISK
     F                                     RENAME(POPREC:RECORD)
     FPIRUSER   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  TABLE AND ARRAY DEFINITIONS
     D*
     D A2              S              1    DIM(2)
     D A10             S              1    DIM(10)
     D A75             S              1    DIM(75)
     D FKEY            S             50    DIM(10)
     D UKEY            S             50    DIM(10)
     D ZOPT            S              2    DIM(20) CTDATA PERRCD(20)
     D OPTLN           S             75    DIM(1) CTDATA PERRCD(1)
     D CMDLN           S             79    DIM(1) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  PARTIAL KEY REDEFINITION
     D*
     D $PRTKY          DS
     D  $LEN50                 1     50
     D  $KWHSE                 1      3  0
     D  $KCODE                 4      9
     D*----------------------------------------------------------------
     D*  DATA STRUCTURE FOR FKEY AND UKEY
     D*
     D                 DS
     D  DSFKEY                 1     50
     D  DSUKEY                 1     50
     D  POWHSE                 1      3  0 INZ(0)
     D  POCODE                 4      4
     D*----------------------------------------------------------------
     D*  CALLED PROGRAM PARAMETERS
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D*
     D*   REDEFINE KEY
     D*
     D  $LWHSE                19     21  0
     D*  CALLED PROGRAMS
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @CHGPG          C                   CONST('EQ112')
     D @DELPG          C                   CONST('EQ114')
     D @PRTPG          C                   CONST('*NONE')
     D*----------------------------------------------------------------
     D*  CALLED PROGRAM PARAMETERS
     D*
     D $POSTN          DS
     D  $POCMD                 1      8
     D  $POPRG                 9     18
     D  $POFKY                19     68
     D  $POUKY                69    118
     D  $PODSC               119    307
     D                                     DIM(3)
     D  $POPT1               308    322
     D  $POPT2               323    335
     D  $PORTN               336    343
     D  $POERM               344    403
     D  $POMSG               336    339
     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D $CVTDT          DS
     D  $CVDOP                 1      8
     D  $CVDD6                 9     14  0
     D  $CVDD8                15     22  0
     D*----------------------------------------------------------------
     D*  DATA STRUCTURE FOR ERROR MESSAGE PARAMETERS
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  MESSAGE CONTROL
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  WORKSTATION EXCEPTION DATA STRUCTURE
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  WORKSTATION EXCEPTION REDEFINITION DATA STRUCTURE
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
     D*----------------------------------------------------------------
     D*  PROGRAM INFO DATA STRUCTURE
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  PARAMETERS
     C*
     C*    INPUT PARAMETERS
     C*      $PRTKY  PARTIAL KEY
     C*
     C*    RETURNED PARAMETERS
     C*      $RTNCD  *EXIT    - CMD3 WAS ENTERED
     C*              *CANCEL  - CMD12 WAS ENTERED
     C*
     C*---------------------------------------------------------------
     C*
     C*  LET THE SHOW BEGIN .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PRTKY           50
     C                   PARM                    $RTNCD            8
     C                   PARM                    $LTCODE           1
     C*
     C*  DEFINE KEYS
     C*
     C*     WORKOPT  (UNIQUE KEY)
     C*
     C     WKOUNQ        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C                   KFLD                    WKOKYF
     C                   KFLD                    WKOKYU
     C*
     C*     WORKOPT  (PARTIAL KEY)
     C*
     C     WKOPRT        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C*
     C*     WORKOPT  (SAVE KEY FOR TOP RECORD ON DELETE DISPLAY)
     C*
     C     *LIKE         DEFINE    WKOKYF        $WKOF
     C     *LIKE         DEFINE    WKOKYU        $WKOU
     C     DELTOP        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C                   KFLD                    $WKOF
     C                   KFLD                    $WKOU
     C*
     C*     USERCODE
     C*
     C     USKEY         KLIST
     C                   KFLD                    #USER
     C*----------------------------------------------------------------
     C*  MAIN LINE
     C*
     C*>   $SORT         IFEQ      '2'
     C*>                 SETON                                        22
     C*>                 ENDIF
      *
     C                   MOVE      '1'           *IN97
     C                   MOVE      *BLANKS       $RTNCD
     C                   EXSR      ZZINZ2
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C                   END
     C                   END
     C*
     C*   DO SOME CLEAN UP BEFORE LEAVING.
     C*
     C                   EXSR      ZSCLR
     C                   EXSR      CLRSCH
     C*
     C*>   $RTNCD        IFEQ      '*EXIT   '
     C*>   $RTNCD        OREQ      '*CANCEL '
     C                   SETON                                        LR
     C*>                 END
      *
     C                   RETURN
     C*----------------------------------------------------------------
     C*  DSPSCR - DISPLAY SCREEN
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   SET ON ALARM INDICATOR IF ERROR OCCURED
     C*
     CSR   ERROR         IFEQ      '1'
     CSR                 MOVE      '1'           *IN98
     CSR                 END
     C*
     C*   SET OFF COMMAND KEY INDICATORS
     C*
     CSR                 SETOFF                                       KCKEKF
     CSR                 SETOFF                                       KL
     C*
     C*   OVERLAY SCREEN WITH TITLE
     C*
     CSR                 WRITE     TITLE
     C*
     C*   OVERLAY SCREEN WITH ERROR MESSAGES
     C*
     CSR                 EXSR      ZMDMSG
     C*
     C*   OVERLAY SCREEN WITH SUBFILE SCREEN
     C*
     CSR   NXTSCR        IFEQ      '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      POSTNREC                               50
     CSR                 END
     CSR   NXTSCR        IFEQ      '02 '
     CSR                 EXSR      DELDSP
     CSR                 END
     C*
     C*   INITIALIZE ERROR INDICATORS AND FIELDS
     C*
     CSR                 SETOFF                                       2021
     CSR                 SETOFF                                       98
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CANCEL            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   INITIALIZE ERROR SUBFILE
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 READ      DSPSFC                                 50
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*     SCREEN INITIALIZATION AND WRAP-UP ROUTINES
     C*
     C*----------------------------------------------------------------
     C*
     C*  SCREEN 01 INITIALIZATION
     C*
     CSR   SCR01I        BEGSR
     CSR                 MOVE      '01 '         NXTSCR            3
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 WRITE     CLR0306
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SCREEN 02 INITIALIZATION
     C*
     CSR   SCR02I        BEGSR
     CSR                 MOVE      '02 '         NXTSCR
     CSR                 MOVE      '1'           *IN90
     CSR                 MOVE      *LOVAL        $WKOF
     CSR                 MOVE      *LOVAL        $WKOU
     CSR                 WRITE     CLR0306
     CSR                 WRITE     DELREC
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG02
     CSR                 WRITE     CMDDEL
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SCREEN 02 WRAP-UP
     C*
     CSR   SCR02E        BEGSR
     CSR                 MOVE      '01 '         NXTSCR
     CSR                 MOVE      '0'           *IN90
     CSR                 WRITE     CLR0306
     C*
     C*   IF DELETE WAS NOT CANCELED (NO ERRORS)
     C*     THEN REPOSITION TO RECORD JUST BEFORE FIRST DELETED REC.
     C*
     CSR   CANCEL        IFEQ      *OFF
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 MOVE      FRSTKY        $POFKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*GETPREV'    $POCMD
     CSR                 EXSR      FGTWAY
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 ELSE
     C*
     C*   OTHERWISE, POSITION TO LAST RECORD READ.
     C*
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 END
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 EXSR      OPTNS
     CSR                 ELSE
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*              SCREEN PROCESSING ROUTINES
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  SCREEN 1
     C*
     CSR   SC1           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL01
     CSR   STATUS        CASEQ     ROLLDN        ROLL01
     CSR   STATUS        CASEQ     COMAND        CMD01
     CSR                 CAS                     ENT01
     CSR                 END
     CSR   ENDSC1        ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SC2  -  SCREEN 2
     C*
     CSR   SC2           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL02
     CSR   STATUS        CASEQ     ROLLDN        ROLL02
     CSR   STATUS        CASEQ     COMAND        CMD02
     CSR                 CAS                     ENT02
     CSR                 END
     CSR   ENDSC2        ENDSR
     C*---------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*---------------------------------------------------------
     C*
     C*  *INZSR  INITIALIZATION SUBROTINE
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  INITIALIZE SPECIAL KEYS
     C*
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
     C*
     C*  INITIALIZE MESSAGE HANDLING
     C*
     C                   EXSR      ZMIMSG
     C*
     C*  INITIALIZE SUBFILE (DSPSFL) RECORD
     C*
     C                   Z-ADD     1             RECNO
     C                   WRITE     DSPSFL                               79
     C*
     C*   CALL USER ADDED INITIALIZATION ROUTINE.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CLRSCH   CLEAR EVERYTHING OUT OF WORK FILE
     C*
     CSR   CLRSCH        BEGSR
     CSR   WKOPRT        SETLL     WORKOPT
     CSR   WKOPRT        READE     WORKOPT                              7979
     CSR   *IN79         DOWEQ     '0'
     CSR                 DELETE    WKOREC
     CSR   WKOPRT        READE     WORKOPT                              7979
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CMD01    SCREEN 1 COMMAND KEY ROUTINE
     C*
     CSR   CMD01         BEGSR
     C*
     C*  TEST FOR CMD3 - EXIT
     C*
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*EXIT   '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*
     C*  TEST FOR CMD21 - PRINT REPORT
     C*
     CSR   *INKV         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*F21    '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     C*
     C*     TEST FOR CMD5 - REFRESH
     C*
     CSR   *INKE         IFEQ      '1'
     CSR                 EXSR      CLRSCH
     CSR   1             DO        10            X
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      '  '          OPTION
     CSR                 UPDATE    DSPSFL
     CSR                 END
     CSR                 END
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     C*
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           CMD01E
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     C*
     C*  TEST FOR CMD6 - ADD RECORD
     C*
     CSR   *INKF         IFEQ      '1'
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*ADD    '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     CSR   $PRTN         IFNE      '*CANCEL '
     CSR   $PRTN         ANDNE     '*EXIT   '
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     C*
     CSR   *INKJ         IFEQ      '1'
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     C*     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     C*
     CSR                 SUB       10            ROW#
     CSR   ROW#          IFLT      1
     CSR   ROW#          ORGT      DSPLYD
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM0106
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     C*
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      UKEY(ROW#)    $POUKY
     CSR                 EXSR      FGTWAY
     C*R         CLERR     CABEQ'1'       CMD01E
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     C*
     CSR   *INKR         IFEQ      '1'
     CSR                 MOVE      '*TOP    '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     C*
     CSR   *INKS         IFEQ      '1'
     CSR                 MOVE      '*BOTTOM '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*   PROCESS NON-STANDARD FUNCTION KEYS.
     C*
     CSR                 EXSR      ZZCMD
     CSR   CMD01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CMD02    SCREEN 2 COMMAND KEY ROUTINE
     C*
     CSR   CMD02         BEGSR
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      '1'           CANCEL
     CSR                 EXSR      SCR02E
     CSR                 GOTO      CMD02E
     CSR                 END
     CSR   CMD02E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  DELADD   ADD RECORD TO SUBFILE FOR DELETE DISPLAY
     C*
     CSR   DELADD        BEGSR
     CSR   RECNO         IFLT      11
     CSR                 ADD       1             RECNO
     CSR                 Z-ADD     RECNO         Y
     C*
     C*  GET RECORD INFO
     C*
     CSR                 MOVE      '*GET    '    $POCMD
     CSR                 MOVE      WKOKYU        $POUKY
     CSR                 EXSR      FGTWAY
     C*R         CLERR     CABEQ'1'       DELADE
     C*
     C*  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     C*
     CSR   RECNO         IFEQ      1
     CSR                 MOVE      WKOKYF        $WKOF
     CSR                 MOVE      WKOKYU        $WKOU
     CSR                 END
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     CSR                 EXSR      ZZFILL
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 WRITE     DSPSFL
     CSR                 END
     CSR   DELADE        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  DELDSP   DISPLAY SUBFILE OF RECORDS MARKED FOR DELETION
     C*
     CSR   DELDSP        BEGSR
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     CSR                 WRITE     MORREC
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     CSR                 MOVE      '1'           *IN01
     CSR                 Z-ADD     1             RECNO
     CSR                 WRITE     DSPSFC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ENT01    SCREEN 1 ENTER KEY ROUTINE
     C*
     CSR   ENT01         BEGSR
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ENT01E
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     CSR                 MOVE      *OFF          REPOS             1
     CSR                 EXSR      ZZPOS
     CSR   ERROR         CABEQ     '1'           ENT01E
     CSR   REPOS         IFEQ      *ON
     CSR                 MOVE      DSFKEY        $POFKY
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ENT01E
     CSR                 END
     C*
     C*  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     C*
     CSR                 EXSR      OPTNS
     C*
     C*  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     C*
     C     OTAKEN        IFEQ      '0'
     C                   MOVE      '*CANCEL '    $LRTN
     C                   ELSE
     C                   MOVE      '*SELECT '    $RTNCD
     C                   END
     C                   MOVE      'EOJ'         NXTSCR
     CSR   ENT01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ENT02    SCREEN 2 ENTER KEY ROUTINE
     C*
     CSR   ENT02         BEGSR
     C*
     C*  SAVE FIRST DELETE KEY.
     C*
     CSR   *LIKE         DEFINE    $PUKY         FRSTKY
     CSR                 MOVE      $PUKY         FRSTKY
     C*
     C*  DELETE THE RECORDS THAT HAVE BEEN SELECTED
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      '0'           STOP
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     C*
     CSR   WKOOPT        IFEQ      ' 4'
     C*
     C*  CALL DELETE PROGRAM
     C*
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 CALL      @DELPG
     CSR                 PARM                    $PARMS
     C*
     C*     ERROR OCCURED - ERROR MESSAGE SENT BACK
     C*
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     C*
     C*     ERROR OCCURED - ERROR MESSAGE SENT TO PROGRAM MSGQ
     C*
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     C*
     C*     DELETE CANCELED
     C*
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     C*
     C*     DELETE WAS SUCCESSFUL.
     C*
     CSR   $PRTN         IFEQ      '*OK     '
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR   CANCEL        IFEQ      '0'
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      '1'           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 END
     C*
     CSR                 END
     CSR                 END
     CSR                 EXSR      SCR02E
     CSR   ENT02E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FGTWAY   GATEWAY TO FILE HANDLING ROUTINES
     C*
     C*    INPUT PARAMETERS
     C*      $POCMD   *INIT    - INITIALIZE AND RETURN
     C*               *GET     - GET RECORD FOR $POUKY VALUE
     C*               *GETNEXT - GET NEXT RECORD
     C*               *GETPREV - GET PREVIOUS RECORD
     C*               *WRITPOS - WRITE POSITION RECORD TO DISPLAY
     C*               *READPOS - READ POSITION RECORD
     C*               *POSTN2  - POSITION TO $POFKY
     C*               *POSTN2U - POSITION TO $POUKY
     C*               *TOP     - POSITION TO TOP OF FILE
     C*               *BOTTOM  - POSITION TO BOTTOM OF FILE
     C*      $POFKY   KEY FOR POSITIONING WITHIN FILE
     C*      $POUKY   UNIQUE KEY USED FOR CHANGE/DELETE OPERATIONS
     C*
     C*    RETURNED PARAMETERS
     C*      $PORTN   *NOMORE  - BEGINNING/END OF FILE WAS REACHED
     C*               *NOTFND  - RECORD NOT FOUND ON A GET
     C*               *FOUND   - RECORD FOUND
     C*               *REPOS   - REPOSITIONING TOOK PLACE
     C*               *ERROR   - ERROR OCCURED
     C*      $POERM   ERROR MESSAGE
     C*
     CSR   FGTWAY        BEGSR
     CSR                 MOVE      *BLANKS       $PORTN
     CSR   $POCMD        CASEQ     '*GET    '    FGET
     CSR   $POCMD        CASEQ     '*GETNEXT'    FGETN
     CSR   $POCMD        CASEQ     '*GETPREV'    FGETP
     CSR   $POCMD        CASEQ     '*POSTN2 '    FPOS2
     CSR   $POCMD        CASEQ     '*POSTN2U'    FPOS2U
     CSR   $POCMD        CASEQ     '*TOP'        ZZPOS2
     CSR   $POCMD        CASEQ     '*BOTTOM'     ZZPOS2
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FGET     GET RECORD USING FILE WITH UNIQUE KEY
     C*
     C*              IN THIS CASE THE LOOKUP FILE AND THE UNIQUE KEY
     C*              FILE ARE THE SAME.
     C*
     CSR   FGET          BEGSR
     CSR                 MOVE      $POUKY        DSUKEY
     CSR                 EXSR      ZZFGET
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOTFND '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 MOVE      *BLANKS       $POFKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FGETN    GET NEXT RECORD
     C*
     CSR   FGETN         BEGSR
     CSR                 EXSR      ZZFGTN
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 MOVE      *BLANKS       $POFKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 EXSR      ZZKEYU
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FGETP    GET PREVIOUS RECORD
     C*
     CSR   FGETP         BEGSR
     CSR                 EXSR      ZZFGTP
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 MOVE      *BLANKS       $POFKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 EXSR      ZZKEYU
     CSR                 END
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  FPOS2    POSITION TO RECORD
     C*
     CSR   FPOS2         BEGSR
     CSR                 MOVE      $POFKY        DSFKEY
     CSR   FILEKY        SETLL     RECORD
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  FPOS2U   POSITION TO RECORD USING UNIQUE KEY
     C*
     CSR   FPOS2U        BEGSR
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     CSR                 EXSR      FGET
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     CSR                 EXSR      FPOS2
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  INZPAR   INITIALIZE PARAMETERS FOR CALLING ADD/CHG/DEL PROGRA
     C*
     CSR   INZPAR        BEGSR
     CSR                 CLEAR                   $PARMS
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      $PRTKY        $PUKY
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  OPTNS    PERFORM OPTIONS THAT USER ENTERED
     C*
     CSR   OPTNS         BEGSR
     CSR                 MOVE      '0'           OTAKEN            1
     C*
     C*     DO ALL DELETES FIRST (OPTION 4)
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      '0'           STOP
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         DOWEQ     '0'
     CSR   WKOOPT        ANDNE     ' 4'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR                 END
     CSR   *IN79         IFEQ      '0'
     CSR   WKOOPT        ANDEQ     ' 4'
     CSR                 MOVE      '1'           OTAKEN
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 EXSR      SCR02I
     CSR                 GOTO      OPTNSE
     CSR                 END
     C*
     C*  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERE
     C*     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      '0'           CANCEL            1
     CSR                 MOVE      '0'           STOP              1
     CSR   STOP          DOUEQ     '1'
     CSR   CANCEL        OREQ      '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     CSR   WKOOPT        IFNE      '  '
     CSR                 MOVE      '1'           OTAKEN
     CSR                 EXSR      OPTNS2
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR                 MOVE      '1'           REFRSH
     CSR   ERROR         IFEQ      '0'
     CSR                 DELETE    WKOREC
     CSR                 END
     CSR   CANCEL        IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR   ERROR         IFEQ      '1'
     CSR                 MOVE      '1'           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      '0'           REFRSH
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR   REFRSH        IFEQ      '1'
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      '0'           REFRSH            1
     CSR                 END
     CSR   OPTNSE        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  OPTNS2   EXECUTE INDIVIDUAL OPTIONS
     C*
     CSR   OPTNS2        BEGSR
     CSR                 EXSR      INZPAR
     CSR                 MOVE      WKOKYU        $PUKY
     C*
     C*   SELECT
     C*
     CSR   WKOOPT        IFEQ      ' 1'
     CSR                 MOVE      POCODE        $LTCODE
     CSR                 ELSE
     C*
     C*   CHANGE
     C*
     CSR   WKOOPT        IFEQ      ' 2'
     CSR                 MOVE      '*CHANGE '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     CSR                 ELSE
     C*
     C*   VIEW
     C*
     C*>   WKOOPT        IFEQ      ' 5'
     C*>                 MOVE      '*VIEW   '    $PCMD
     C*>                 CALL      @CHGPG
     C*>                 PARM                    $PARMS
     C*>                 ELSE
     C*
     C*   PRINT
     C*
     CSR   WKOOPT        IFEQ      ' 6'
     CSR                 MOVE      '*PRINT  '    $PCMD
     CSR                 CALL      'none'
     CSR                 PARM                    $PARMS
     CSR                 ELSE
     CSR                 EXSR      ZZOPT
     CSR                 END
     CSR                 END
     CSR                 END
     C*
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG01    SCREEN 1 PAGE ROUTINES
     C*
     CSR   PAG01         BEGSR
     C*
     C*  NEXT PAGE
     C*
     CSR   PAGCMD        IFEQ      '*NEXT   '
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     C*
     C*  PREVIOUS PAGE
     C*
     CSR   PAGCMD        IFEQ      '*PREV   '
     CSR                 EXSR      PAG1BK
     CSR                 ELSE
     C*
     C*  TOP
     C*
     CSR   PAGCMD        IFEQ      '*TOP    '
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 EXSR      FGTWAY
     C*R         CLERR     CABEQ'1'       PAG01E
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           FORCEB
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     C*
     C*  BOTTOM
     C*
     CSR   PAGCMD        IFEQ      '*BOTTOM '
     CSR                 MOVE      '1'           BOT
     CSR                 Z-ADD     0             DSPLYD
     CSR                 EXSR      PAG1BK
     CSR                 ELSE
     C*
     C*  REFRESH SCREEN
     C*
     CSR   PAGCMD        IFEQ      '*REFRESH'
     CSR   FKEY(1)       IFEQ      *LOVAL
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 ELSE
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 MOVE      FKEY(1)       $POFKY
     CSR                 END
     CSR                 EXSR      FGTWAY
     C*R         CLERR     CABEQ'1'       PAG01E
     CSR                 MOVE      '0'           BOT
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     C*
     C*  REPOSITIONING
     C*
     CSR   PAGCMD        IFEQ      '*REPOS  '
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           FORCEB
     CSR                 EXSR      PAG1FW
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 MOVE      *BLANKS       PAGCMD            8
     CSR   PAG01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG02    SCREEN 2 PAGE ROUTINES
     C*
     CSR   PAG02         BEGSR
     C*
     C*  NEXT PAGE
     C*
     CSR   PAGCMD        IFEQ      '*NEXT   '
     CSR                 EXSR      PAG2FW
     CSR                 ELSE
     C*
     C*  PREVIOUS PAGE
     C*
     CSR   PAGCMD        IFEQ      '*PREV   '
     CSR                 EXSR      PAG2BK
     CSR                 ELSE
     C*
     C*  REFRESH SCREEN
     C*
     CSR   PAGCMD        IFEQ      '*REFRESH'
     CSR   DELTOP        SETLL     WORKOPT
     CSR                 MOVE      '0'           BOT
     CSR                 EXSR      PAG2FW
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 MOVE      *BLANKS       PAGCMD
     CSR   PAG02E        ENDSR
     C*---------------------------------------------------------------
     C*
     C*  PAG1FW   LET'S SEE THAT NEXT PAGE OF RECORDS
     C*
     CSR   PAG1FW        BEGSR
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     CSR   BOT           CABEQ     '1'           ENDF
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 MOVE      '0'           BOT               1
     CSR                 MOVE      '0'           TOP               1
     CSR                 MOVE      '0'           STOP              1
     CSR                 Z-ADD     0             P                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     CSR   STOP          DOUEQ     '1'
     CSR                 MOVE      '*GETNEXT'    $POCMD
     CSR                 EXSR      FGTWAY
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'BOTTOM '     MORELN
     CSR                 GOTO      ENDFAC
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     CSR                 ADD       1             P
     CSR                 EXSR      SFLADD
     CSR   P             IFGE      10
     CSR                 MOVE      '1'           STOP
     CSR   FORCEB        IFEQ      '1'
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'BOTTOM '     MORELN
     CSR                 ELSE
     CSR                 MOVE      'MORE...'     MORELN
     CSR                 END
     CSR                 END
     CSR   ENDFAC        TAG
     CSR                 END
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     CSR                 Z-ADD     P             DSPLYD            2 0
     CSR                 MOVE      '0'           FORCEB
     CSR   ENDF          ENDSR
     C*---------------------------------------------------------------
     C*
     C*  PAG1BK   LET'S SEE THE PREVIOUS PAGE
     C*
     CSR   PAG1BK        BEGSR
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     CSR   TOP           CABEQ     '1'           ENDB
     CSR                 MOVE      '0'           FORCEB            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      '1'
     CSR   GOBACK        IFEQ      10
     CSR                 MOVE      '1'           FORCEB
     CSR                 END
     CSR                 MOVE      '*BOTTOM '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ADD       1             GOBACK
     CSR                 END
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 Z-ADD     0             P
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           STOP
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     CSR   STOP          DOUEQ     '1'
     CSR                 MOVE      '*GETPREV'    $POCMD
     CSR                 EXSR      FGTWAY
     C*
     C*  HIT TOP OF FILE
     C*
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           TOP
     CSR                 GOTO      ENDBK
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      '1'           STOP
     CSR                 END
     CSR   ENDBK         TAG
     CSR                 END
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     CSR   TOP           IFEQ      '1'
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 END
     CSR                 EXSR      PAG1FW
     CSR   ENDB          ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG2FW   LET'S SEE THAT NEXT PAGE OF DELETE RECORDS
     C*
     CSR   PAG2FW        BEGSR
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     CSR   BOT           CABEQ     '1'           ENDF2
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        $WKOF
     CSR                 MOVE      *LOVAL        $WKOU
     CSR                 MOVE      '0'           BOT               1
     CSR                 MOVE      '0'           TOP               1
     CSR                 MOVE      '0'           STOP              1
     CSR                 Z-ADD     0             P                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'BOTTOM '     MORELN
     CSR                 GOTO      ENDFW2
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     CSR   WKOOPT        IFEQ      ' 4'
     CSR                 ADD       1             P
     CSR                 EXSR      DELADD
     CSR   P             IFGE      10
     CSR                 MOVE      '1'           STOP
     CSR   FORCEB        IFEQ      '1'
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'BOTTOM '     MORELN
     CSR                 ELSE
     CSR                 MOVE      'MORE...'     MORELN
     CSR                 END
     CSR                 END
     CSR                 END
     CSR   ENDFW2        TAG
     CSR                 END
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     CSR                 Z-ADD     P             DSPLYD            2 0
     CSR                 MOVE      '0'           FORCEB
     CSR   ENDF2         ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG2BK   LET'S SEE THE PREVIOUS PAGE OF DELETE RECORDS
     C*
     CSR   PAG2BK        BEGSR
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     CSR   TOP           CABEQ     '1'           ENDB2
     CSR                 MOVE      '0'           FORCEB            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      '1'
     CSR   WKOPRT        SETGT     WORKOPT
     CSR                 ADD       1             GOBACK
     CSR                 END
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 Z-ADD     0             P
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           STOP
     C*
     C*  READ FILE
     C*
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READPE    WORKOPT                                79
     C*
     C*  HIT TOP OF FILE
     C*
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           TOP
     CSR                 GOTO      ENDBK2
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     CSR   WKOOPT        IFEQ      ' 4'
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      '1'           STOP
     CSR                 END
     CSR                 END
     CSR   ENDBK2        TAG
     CSR                 END
     C*
     C* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     C*
     CSR   TOP           IFEQ      '1'
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 END
     CSR                 EXSR      PAG2FW
     CSR   ENDB2         ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ROLL01   SCREEN 1 ROLL UP/DOWN ROUTINE
     C*
     CSR   ROLL01        BEGSR
     C*
     C*  TEST FOR ROLLUP
     C*
     CSR   STATUS        IFEQ      ROLLUP
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ROL01E
     CSR                 MOVE      '*NEXT   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 END
     C*
     C*  TEST FOR ROLLDOWN
     C*
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ROL01E
     CSR                 MOVE      '*PREV   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 END
     CSR   ROL01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ROLL02   SCREEN 2 ROLL UP/DOWN ROUTINE
     C*
     CSR   ROLL02        BEGSR
     C*
     C*  TEST FOR ROLLUP
     C*
     CSR   STATUS        IFEQ      ROLLUP
     CSR                 MOVE      '*NEXT   '    PAGCMD
     CSR                 EXSR      PAG02
     CSR                 GOTO      ROL02E
     CSR                 END
     C*
     C*  TEST FOR ROLLDOWN
     C*
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 MOVE      '*PREV   '    PAGCMD
     CSR                 EXSR      PAG02
     CSR                 GOTO      ROL02E
     CSR                 END
     CSR   ROL02E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SAVOPT   VERIFY AND SAVE OPTIONS THAT WERE ENTERED
     C*
     CSR   SAVOPT        BEGSR
     C*
     C*  READ ONLY THE CHANGED OPTIONS
     C*
     CSR                 MOVE      '0'           NOMORE            1
     CSR   NOMORE        DOUEQ     '1'
     CSR                 MOVE      '0'           *IN21
     CSR                 READC     DSPSFL                                 79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           NOMORE
     CSR                 GOTO      ENDDO1
     CSR                 END
     C*
     C*  DISPLAY ERROR IF OPTION IS NOT VALID
     C*
     CSR   OPTION        IFNE      *BLANKS
     CSR                 MOVEA     OPTION        A2
     CSR   A2(2)         IFEQ      ' '
     CSR                 MOVE      A2(1)         A2(2)
     CSR                 MOVE      ' '           A2(1)
     CSR                 MOVEA     A2            OPTION
     CSR                 END
     C*
     C*    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     C*
     CSR   OPTION        LOOKUP    ZOPT                                   50
     CSR   *IN50         IFEQ      *OFF
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM0108
     CSR                 END
     CSR                 END
     C*
     C*  SAVE OPTION
     C*
     CSR                 Z-ADD     RECNO         Y                 3 0
     CSR                 MOVE      FKEY(Y)       WKOKYF
     CSR                 MOVE      UKEY(Y)       WKOKYU
     CSR   WKOUNQ        CHAIN     WORKOPT                            79
     CSR   *IN79         IFEQ      '0'
     CSR   OPTION        IFEQ      *BLANKS
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      OPTION        WKOOPT
     CSR                 MOVE      *IN21         WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 ELSE
     CSR   OPTION        IFNE      *BLANKS
     CSR                 MOVE      #USER         WKOUSR
     CSR                 MOVE      #PROG         WKOPGM
     CSR                 MOVE      FKEY(Y)       WKOKYF
     CSR                 MOVE      UKEY(Y)       WKOKYU
     CSR                 MOVE      OPTION        WKOOPT
     CSR                 MOVE      *IN21         WKOERR
     CSR                 WRITE     WKOREC
     CSR                 END
     CSR                 END
     CSR   ENDDO1        TAG
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   ADD RECORD TO SUBFILE
     C*
     CSR   SFLADD        BEGSR
     CSR   RECNO         IFLT      11
     CSR                 ADD       1             RECNO
     CSR                 Z-ADD     RECNO         Y
     C*
     C*  SAVE FILE AND UNIQUE KEYS
     C*
     CSR                 MOVE      $POFKY        FKEY(Y)
     CSR                 MOVE      $POUKY        UKEY(Y)
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     CSR                 EXSR      ZZFILL
     CSR                 WRITE     DSPSFL
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   CLEAR DISPLAY SUBFILE
     C*
     CSR   SFLCLR        BEGSR
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     CSR                 MOVE      '0'           *IN01
     CSR                 WRITE     DSPSFC
     CSR                 Z-ADD     0             RECNO             4 0
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   DISPLAY SUBFILE
     C*
     CSR   SFLDSP        BEGSR
     C*
     C*  WRITE OPTION AND COMMAND LINES TO DISPLAY
     C*
     CSR                 WRITE     OPTREC
     CSR                 WRITE     CMDREC
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     CSR                 WRITE     MORREC
     C*
     C*  WRITE POSITION TO FIELD TO DISPLAY
     C*
     CSR                 WRITE     POSTNREC
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     CSR                 EXSR      SFLOPT
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     CSR   ERROR         IFNE      '1'
     CSR   1             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      '1'           *IN20
     CSR                 UPDATE    DSPSFL
     CSR                 END
     CSR                 END
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     CSR                 MOVE      '1'           *IN01
     CSR                 Z-ADD     1             RECNO
     CSR                 WRITE     DSPSFC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLOPT   INITIALIZE OPTIONS FOR SUBFILE
     C*
     CSR   SFLOPT        BEGSR
     CSR   1             DO        10            X                 3 0
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      FKEY(X)       WKOKYF
     CSR                 MOVE      UKEY(X)       WKOKYU
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR   *IN78         IFEQ      '0'
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 MOVE      WKOERR        *IN21
     CSR                 MOVE      WKOERR        *IN20
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       OPTION
     CSR                 MOVE      '0'           *IN21
     CSR                 MOVE      '0'           *IN20
     CSR                 END
     CSR                 UPDATE    DSPSFL
     CSR                 END
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMXXXX  CONTROL MESSAGE DISPLAY SUBFILE
     C*
     C*    ZMCMSG  CLEAR MESSAGE RECORD SUBFILE
     C*
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      '0'           *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMDMSG  DISPLAY MESSAGE RECORD SUBFILE
     C*
     CSR   ZMDMSG        BEGSR
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '1'           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 END
     CSR                 ENDSR
     C*
     C*    ZMIMSG  INITIALIZATION NECESSARY FOR MESSAGE SUBFILE
     C*
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*
     C*    ZMPMSG  ADD MESSAGE RECORD TO SUBFILE
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
     CSR                 PARM      #PROG         #PGMQ
     CSR                 PARM                    #MSGK
     CSR   #MSGID        IFNE      '*CLEAR '
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 END
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*
     C*    ZMQMSG  ADD MESSAGE RECORD TO SUBFILE FROM PROGRAM QUEUE
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*
     C*    ZSCLR   CLEAR SCREEN
     C*
     CSR   ZSCLR         BEGSR
     C*R                   WRITECLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*
     C*    ZMSMSG  SEND PROGRAM MESSAGE TO A DIFFERENT PROGRAM MSGQ
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM      '*PREV'       #PGMQ
     CSR                 PARM                    #MSGK
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*
     C*    ZMNNNN  BUILD AND SEND MESSAGE NNNN TO THIS PROGRAM
     C*----------------------------------------------------------------
     C*      0101  PROGRAM NOT FOUND.
     C*
     CSR   ZM0101        BEGSR
     CSR                 MOVE      'PIR0101'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0102  PROGRAM NOT FOUND.
     C*
     CSR   ZM0102        BEGSR
     CSR                 MOVE      'PIR0102'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0103  PROGRAM NOT FOUND WHILE EXEC. SUBROUTINE.
     C*
     CSR   ZM0103        BEGSR
     CSR                 MOVE      'PIR0103'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0104  PRESSED AN INVALID KEY.
     C*
     CSR   ZM0104        BEGSR
     CSR                 MOVE      'PIR0104'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
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
     C*      0106  INVALID CURSOR POSITION.
     C*
     CSR   ZM0106        BEGSR
     CSR                 MOVE      'PIR0106'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0107  INVALID VALUE FOR "POSITION TO"
     C*
     CSR   ZM0107        BEGSR
     CSR                 MOVE      'PIR0107'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0108  INVALID OPTION.
     C*
     CSR   ZM0108        BEGSR
     CSR                 MOVE      'PIR0108'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEL     OPTION        ERRMSG
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  CURSOR NOT IN CORRECT POSITION FOR LOOKUP.
     C*
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD    PROCESS NON-STANDARD FUNCTION KEYS
     C*
     CSR   ZZCMD         BEGSR
     C*
     C*  TEST FOR F4 - LOOKUP
     C*
     CSR   *INKD         IFEQ      '1'
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     C*     WAREHOUSE DEPARTMENT.
     C*
     CSR   ROW#          IFEQ      4
     CSR   COL#          ANDGE     48
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     PTINP1        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        PTINP1
     CSR                 END
     CSR                 ELSE
     C*
     C*     CURSOR NOT ON A VALID LOOKUP FIELD.
     C*
     CSR                 MOVE      '1'           ERROR
     CSR                 EXSR      ZM9905
     CSR                 END
     CSR                 GOTO      ENDCM1
     CSR                 END
     C*
     C*  TEST FOR F9 - DISPLAY ALL WAREHOUSES
     CSR   *INKI         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*F9     '    $RTNCD
     CSR                 GOTO      ENDCM1
     CSR                 ENDIF
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   GET RECORD WITH UNIQUE KEY.
     C*
     CSR   ZZFGET        BEGSR
     C*
     C*    CODE TO USE WHEN FILE KEY AND UNIQUE KEY ARE THE SAME.
     C*
     CSR   FILUKY        CHAIN     RECORD                             79
     C*
     C*    CODE TO USE WHEN FILE KEY AND UNIQUE KEY ARE DIFFERENT.
     C*
     C*R         FILUKY    CHAINRECORDU              79
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   GET NEXT RECORD
     C*
     CSR   ZZFGTN        BEGSR
     CSR   TRY1          TAG
     C*
     C*    CODE TO USE WHEN WE ARE NOT USING A PARTIAL KEY.
     C*
     C*R                   READ RECORD                   79
     C*
     C*    CODE TO USE WHEN WE DO HAVE A PARTIAL KEY TO USE.
     C*
     CSR   PARTKY        READE     RECORD                                 79
     C*>                 IF        EQTYPE <> $KCODE AND
     C*>                           *IN79  <> *ON
     C*>                 GOTO      TRY1
     C*>                 ENDIF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   GET PREVIOUS RECORD
     C*
     CSR   ZZFGTP        BEGSR
     CSR   TRY2          TAG
     C*
     C*    CODE TO USE WHEN WE ARE NOT USING A PARTIAL KEY.
     C*
     C*R                   READPRECORD                   79
     C*
     C*    CODE TO USE WHEN WE DO HAVE A PARTIAL KEY TO USE.
     C*
     CSR   PARTKY        READPE    RECORD                                 79
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   FILL DISPLAY LINE WITH VALUES THAT NEED
     C*           TO BE CONVERTED.
     C*
     CSR   ZZFILL        BEGSR
     C*
     C*>                 MOVE      POCODE        POCOD2
     C*>                 MOVE      EQTYPE        EQTYP2
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    EXTRA PROGRAM INITIALIZATION. CALLED FROM *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  DEFINE UNIQUE FILE KEY.
     C*
     CSR   FILUKY        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    POCODE
     C*
     C*  DEFINE FULL KEY FOR MAIN FILE.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    POCODE
     C*
     C*  DEFINE PARTIAL KEY FOR MAIN FILE (IF NEEDED).
     C*
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $KWHSE
     C*
     C*  SETUP OPTION AND COMMAND DISPLAY LINES.
     C*
     CSR                 MOVE      OPTLN(1)      OPTLN1
     CSR                 MOVE      CMDLN(1)      CMDLN1
     C*
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $LPRG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   EXTRA PROGRAM INITIALIZATION. CALLED FROM MAIN LINE.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   GET WAREHOUSE FOR USER.
     C*
     CSR   USKEY         CHAIN     PIRUSER                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 Z-ADD     USWHSE        POWHSE
     CSR                 ELSE
     CSR                 Z-ADD     1             POWHSE
     CSR                 ENDIF
     C*
     C*   VERIFY WAREHOUSE AND GET DESCRIPTION.
     C*
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     POWHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     CSR                 Z-ADD     POWHSE        $KWHSE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 END
     CSR                 END
     C*
     CSR                 EXSR      CLRSCH
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   CREATE KEY FOR FILE BEING USED
     C*
     CSR   ZZKEYF        BEGSR
     CSR                 MOVE      DSFKEY        $POFKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   CREATE UNIQUE KEY FOR FILE
     C*             (TO BE USED IN DELETE AND CHANGE PROGRAMS)
     C*
     CSR   ZZKEYU        BEGSR
     CSR                 MOVE      DSUKEY        $POUKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOPT    PROCESS NON-STANDARD OPTIONS.
     C*              NOTE: ERROR HANDLING IS DONE IN ROUTINE OPTNS2.
     C*
     CSR   ZZOPT         BEGSR
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    POSITION TO A DIFFERENT RECORD.
     C*
     CSR   ZZPOS         BEGSR
     C*
     C*  SEE IF USER IS TRYING TO CHANGE WAREHOUSE.
     C*
     CSR   PTINP1        IFNE      0
     C*
     C*      VERIFY WAREHOUSE ENTRY.
     C*
     CSR                 Z-ADD     PTINP1        POWHSE
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     PTINP1        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      ENDZPS
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 GOTO      ENDZPS
     CSR                 ELSE
     CSR                 Z-ADD     PTINP1        POWHSE
     CSR                 Z-ADD     POWHSE        $KWHSE
     CSR                 MOVE      *BLANKS       POCODE
     CSR                 Z-ADD     PTINP1        POWHSE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 Z-ADD     0             PTINP1
     CSR                 MOVE      *ON           REPOS
     CSR                 END
     CSR                 END
     CSR                 END
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO CODE
     C*
     CSR   PTINP2        IFNE      *BLANKS
     CSR                 MOVE      PTINP2        POCODE
     CSR                 MOVE      *BLANKS       PTINP2
     CSR                 MOVE      *ON           REPOS
     CSR                 END
     C*
     CSR   ENDZPS        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   POSITION TO RECORD
     C*
     CSR   ZZPOS2        BEGSR
     C*
     C*    CODE TO USE WHEN WE ARE NOT USING A PARTIAL KEY.
     C*
     C*R         $POCMD    IFEQ '*TOP'
     C*R         *LOVAL    SETLLRECORD
     C*R                   ELSE
     C*R         $POCMD    IFEQ '*BOTTOM'
     C*R         *HIVAL    SETLLRECORD
     C*R                   END
     C*R                   END
     C*
     C*    CODE TO USE WHEN WE DO HAVE A PARTIAL KEY TO USE.
     C*
     CSR   $POCMD        IFEQ      '*TOP'
     CSR   PARTKY        SETLL     RECORD
     CSR                 ELSE
     CSR   $POCMD        IFEQ      '*BOTTOM'
     CSR   PARTKY        SETGT     RECORD
     CSR                 END
     CSR                 END
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  COMPILE TIME TABLES
     O*
**  ZOPT - VALID OPTIONS
 1
**  OPTLN - OPTION DISPLAY LINE
  1=Select
**  CMDLN - COMMAND DISPLAY LINE
F3=Exit  F4=Prompt  F5=Refresh  F12=Cancel
