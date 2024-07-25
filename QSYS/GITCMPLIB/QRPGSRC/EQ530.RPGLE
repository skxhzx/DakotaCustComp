     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  EQ530     Equipment Work Order repair (one whse) - Display
     F*  16 July, 2003
     F*  Roxanne Harrison
     F*
     F*  SK110 - 1.01
     F*
     F*  Revisions
417aaF*    08/06/03  RH   4.17a
     F*      - FIX: Add I/O to $prtky.                                 h
     F*
     F*  NOTES:
     *      - This list display does not use OPTION.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        POSITION CURSOR
     F*  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  79        CHAIN INDICATOR
     F*  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FEQ530FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FWORKOPT   UF A E           K DISK
     FEQUIPR    IF   E           K DISK
     F                                     RENAME(ERREC:RECORD)
     Fpiruser1  IF   E           K DISK
     Fequipw2   IF   E           K DISK
     Fequipa1   IF   E           K DISK
     FREPORTS   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A2              S              1    DIM(2)
     D A10             S              1    DIM(10)
     D A75             S              1    DIM(75)
     D FKEY            S             50    DIM(10)
     D UKEY            S             50    DIM(10)
     D OPTLST          S              2    DIM(24)
     D CMDLST          S              2    DIM(24)
     D ZOPT            S              2    DIM(20) CTDATA PERRCD(20)
     D OPTLN           S             75    DIM(1) CTDATA PERRCD(1)
     D CMDLN           S             79    DIM(1) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     D $PRTKY          DS
     D  $LEN50                 1     50
     D  $KWHSE                 1      3  0
     D  $KTRN#                 4     10  0
     D  $KIO                  11     11
     D  $KSEQ#                12     16  0
417d D  $KWRK#                17     23  0
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     D                 DS
     D  DSFKEY                 1     50
     D  DSUKEY                 1     50
     D  ERWHSE                 1      3  0 INZ(0)
     D  ERTRN#                 4     10  0 INZ(0)
     D  ERIO                  11     11
     D  ERSEQ#                12     16  0 INZ(0)
0493 D*----------------------------------------------------------------
.    D*  Called program parameters
0493 D*
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
     D  $LTRN#                22     28  0
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @CHGPG          C                   CONST('NONE   ')
     D @DELPG          C                   CONST('NONE   ')
     D @PRTPG          C                   CONST('NONE   ')
     D*----------------------------------------------------------------
     D*  Called program parameters
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
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $ptrn#                22     28  0
     D  $pio                  29     29
     D  $pseq#                30     34  0
     D  $pwrk#                35     41  0
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0 INZ(0)
     D  $CVD8O                39     46  0 INZ(0)
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D**                                      1   8 $CVDOP
     D**                                      9  140$CVDD6
     D**                                     15  220$CVDD8
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
     D                 DS
     D  $EC                    1      2P 0
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D noon            s               t   inz(t'12.00.00')

     D currtimestamp   s               z

     D $fromdate       s               d
     D $todate         s               d

     D datestamp       s               d
     D timestamp       s               t

     D datedsp         s              8
     D timedsp         s              8

     D nodate          s               d   inz(d'0001-01-01')

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
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PRTKY  Partial key
     C*
     C*    Returned Parameters
     C*      $RTNCD  *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PRTKY           50
     C                   PARM                    $RTNCD            8
     C*
     C*  Define keys
     C*
     C*     WORKOPT  (Unique key)
     C*
     C     WKOUNQ        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C                   KFLD                    WKOKYF
     C                   KFLD                    WKOKYU
     C*
     C*     WORKOPT  (Partial key)
     C*
     C     WKOPRT        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C*
     C*     WORKOPT  (Save key for top record on delete display)
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
     C*
     C*     Work order
     C*
     C     wkkey         KLIST
     C                   KFLD                    $kwhse
     C                   KFLD                    $ktrn#
     C*----------------------------------------------------------------
     C*  Main line
     C*
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
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   EXSR      CLRSCH
     C*
     C     $RTNCD        IFEQ      '*EXIT   '
     C     $RTNCD        OREQ      '*CANCEL '
     C                   SETON                                        LR
     C                   END
     C                   RETURN
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
     C*   Set OFF command key indicators
     C*
     CSR                 SETOFF                                       KCKEKF
     CSR                 SETOFF                                       KL
     C*
     C*   Overlay screen with title
     C*
     CSR                 WRITE     TITLE
     C*
     C*   Overlay screen with error messages
     C*
     CSR                 EXSR      ZMDMSG
     C*
     C*   Overlay screen with subfile screen
     C*
     CSR   NXTSCR        IFEQ      '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      POSTNREC                               50
     CSR                 END
     CSR   NXTSCR        IFEQ      '02 '
     CSR                 EXSR      DELDSP
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       2021
     CSR                 SETOFF                                       98
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CANCEL            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 READ      DSPSFC                                 50
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
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 WRITE     CLR0306
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
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
     C*  Screen 02 wrap-up
     C*
     CSR   SCR02E        BEGSR
     CSR                 MOVE      '01 '         NXTSCR
     CSR                 MOVE      '0'           *IN90
     CSR                 WRITE     CLR0306
     C*
     C*   If delete was not canceled (no errors)
     C*     then reposition to record just before first deleted rec.
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
     C*   Otherwise, position to last record read.
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
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     CSR   SC1           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL01
     CSR   STATUS        CASEQ     ROLLDN        ROLL01
     CSR   STATUS        CASEQ     COMAND        CMD01
     CSR                 CAS                     ENT01
     CSR                 END
     CSR   ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     CSR   SC2           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL02
     CSR   STATUS        CASEQ     ROLLDN        ROLL02
     CSR   STATUS        CASEQ     COMAND        CMD02
     CSR                 CAS                     ENT02
     CSR                 END
     CSR   ENDSC2        ENDSR
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
     C                   MOVE      *BLANKS       OPTION            2
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*  Initialize subfile (DSPSFL) record
     C*
     C                   Z-ADD     1             RECNO
     C                   WRITE     DSPSFL                               79
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CLRSCH   Clear everything out of work file
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
     C*  CMD01    Screen 1 command key routine
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
220 ACSR                 MOVE      '*REFRESH'    PAGCMD
220 ACSR                 EXSR      PAG01
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
     C*   Process non-standard function keys.
     C*
     CSR                 EXSR      ZZCMD
     CSR   CMD01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CMD02    Screen 2 command key routine
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
     C*  DELADD   Add record to subfile for delete display
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
     C*  DELDSP   Display subfile of records marked for deletion
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
     C*  ENT01    Screen 1 enter key routine
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
     C*R         OTAKEN    IFEQ '0'
     C*R                   MOVE 'EOJ'     NXTSCR
     C*R                   GOTO ENT01E
     C*R                   END
     CSR   ENT01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ENT02    Screen 2 enter key routine
     C*
     CSR   ENT02         BEGSR
     C*
     C*  Save first delete key.
     C*
     CSR   *LIKE         DEFINE    $PUKY         FRSTKY
     CSR                 MOVE      $PUKY         FRSTKY
     C*
     C*  Delete the records that have been selected
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
     C*  Call delete program
     C*
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 CALL      @DELPG
     CSR                 PARM                    $PARMS
     C*
     C*     Error occured - Error message sent back
     C*
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     C*
     C*     Error occured - Error message sent to program msgq
     C*
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     C*
     C*     Delete canceled
     C*
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     C*
     C*     Delete was successful.
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
     C*  FGTWAY   Gateway to file handling routines
     C*
     C*    Input Parameters
     C*      $POCMD   *INIT    - Initialize and return
     C*               *GET     - Get record for $POUKY value
     C*               *GETNEXT - Get next record
     C*               *GETPREV - Get previous record
     C*               *WRITPOS - Write position record to display
     C*               *READPOS - Read position record
     C*               *POSTN2  - Position to $POFKY
     C*               *POSTN2U - Position to $POUKY
     C*               *TOP     - Position to top of file
     C*               *BOTTOM  - Position to bottom of file
     C*      $POFKY   Key for positioning within file
     C*      $POUKY   Unique key used for change/delete operations
     C*
     C*    Returned Parameters
     C*      $PORTN   *NOMORE  - Beginning/End of file was reached
     C*               *NOTFND  - Record not found on a GET
     C*               *FOUND   - Record found
     C*               *REPOS   - Repositioning took place
     C*               *ERROR   - Error occured
     C*      $POERM   Error message
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
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are the same.
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
     C*  FGETN    Get next record
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
     C*  FGETP    Get previous record
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
     C*----------------------------------------------------------------
     C*
     C*  FPOS2    Position to record
     C*
     CSR   FPOS2         BEGSR
     CSR                 MOVE      $POFKY        DSFKEY
     CSR   FILEKY        SETLL     RECORD
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FPOS2U   Position to record using unique key
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
     C*----------------------------------------------------------------
     C*
     C*  INZPAR   Initialize parameters for calling add/chg/del program
     C*
     CSR   INZPAR        BEGSR
     CSR                 CLEAR                   $PARMS
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      $PRTKY        $PUKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  OPTNS    Perform options that user entered
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
     C*  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
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
     C*  OPTNS2   Execute individual options
     C*
     CSR   OPTNS2        BEGSR
     CSR                 EXSR      INZPAR
     CSR                 MOVE      WKOKYU        $PUKY
     C*
     C*   Change
     C*
     CSR   WKOOPT        IFEQ      ' 2'
     C*
     C*
     CSR                 ELSE
     C*
     C*   View
     C*
     CSR   WKOOPT        IFEQ      ' 5'
     CSR                 ELSE
     C*
     CSR                 ENDIF
     CSR                 ENDIF
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
     C*  PAG01    Screen 1 page routines
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
     C*  PAG02    Screen 2 page routines
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
     C*----------------------------------------------------------------
     C*
     C*  PAG1FW   Let's see that next page of records
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
     CSR                 MOVE      'Bottom '     MORELN
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
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 ELSE
     CSR                 MOVE      'More...'     MORELN
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
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
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
     C*  PAG2FW   Let's see that next page of delete records
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
     CSR                 MOVE      'Bottom '     MORELN
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
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 ELSE
     CSR                 MOVE      'More...'     MORELN
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
     C*  PAG2BK   Let's see the previous page of delete records
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
     C*  ROLL01   Screen 1 roll up/down routine
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
     C*  ROLL02   Screen 2 roll up/down routine
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
     C*  SAVOPT   Verify and save options that were entered
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
     C*  SFLADD   Add record to subfile
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
     C*  SFLCLR   Clear display subfile
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
     C*  SFLDSP   Display subfile
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
     C*  SFLOPT   Initialize options for subfile
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
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
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
     C*    ZMDMSG  Display message record subfile
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
     C*
     C*    ZMSMSG  Send program message to a different program msgq
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
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0101  Program not found.
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
     C*      0102  Program not found.
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
     C*      0103  Program not found while exec. subroutine.
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
     C*      0104  Pressed an invalid key.
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
     C*      0106  Invalid cursor position.
     C*
     CSR   ZM0106        BEGSR
     CSR                 MOVE      'PIR0106'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0107  Invalid value for "position To"
     C*
     CSR   ZM0107        BEGSR
     CSR                 MOVE      'PIR0107'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0108  Invalid Option.
     C*
     CSR   ZM0108        BEGSR
     CSR                 MOVE      'PIR0108'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEL     OPTION        ERRMSG
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
     C*  ZZCMD    Process non-standard function keys
     C*
     CSR   ZZCMD         BEGSR
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      '1'
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     CSR                 ELSE
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      '1'           ERROR
     CSR                 EXSR      ZM9905
     CSR                 END
     CSR                 GOTO      ENDCM1
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     CSR   ZZFGET        BEGSR
     C*
     C*    Code to use when file key and unique key are the same.
     C*
     CSR   FILUKY        CHAIN     RECORD                             79
     C*
     C*    Code to use when file key and unique key are different.
     C*
     C*R         FILUKY    CHAINRECORDU              79
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     CSR   ZZFGTN        BEGSR
     CSR   TRY1          TAG
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R                 read      record                                 79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     CSR   PARTKY        READE     RECORD                                 79
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   Get previous record
     C*
     CSR   ZZFGTP        BEGSR
     CSR   TRY2          TAG
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R                   READPRECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     CSR   PARTKY        READPE    RECORD                                 79
     C*                  if        *in79 ='0' and eaexcp ='0'
     C*                  goto      try2
     C*                  endif
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     CSR   ZZFILL        BEGSR
     C*
     C                   move      *blanks       w1by
     C                   move      *blanks       w1cdte
     C                   move      ermemo        w1memo
     C                   move      ercmpl        w1cmpl
     C                   if        eremp#<>0
     C     eremp#        chain     piruser1                           77
     C*
     C                   if        *in77 = *off
     C                   move      '*LFM    '    $cmd              8
     C                   move      *blanks       $name            40
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   movel     $name         w1by
     C                   endif
     C                   endif
     C*
     C                   move      easdts        datestamp
     C                   if        datestamp <> nodate
     C     *MDY/         movel     datestamp     datedsp
     C                   move      datedsp       w1cdte
     C                   else
     C                   eval      w1cdte = *blanks
     C                   endif
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     CSR   RPKEY         KLIST
     CSR                 KFLD                    WKPRTF           10
     C*
     C*  Define unique file key.
     C*
     CSR   FILUKY        KLIST
     CSR                 KFLD                    ERWHSE
     CSR                 KFLD                    ERTRN#
     CSR                 KFLD                    ERIO
     CSR                 KFLD                    ERSEQ#
     C*
     C*  Define full key for main file.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    ERWHSE
     CSR                 KFLD                    ERTRN#
     CSR                 KFLD                    ERIO
     CSR                 KFLD                    ERSEQ#
     C*
     C*  Define partial key for main file (if needed).
     C*
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    $KTRN#
     CSR                 KFLD                    $KIO
     CSR                 KFLD                    $KSEQ#
     C*
     C*  Key for EQUIPA file.
     C*
     CSR   KEYEA         KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    $KTRN#
     CSR                 KFLD                    $KIO
     CSR                 KFLD                    $KSEQ#
     C*
     C*  Setup option and command display lines.
     C*
     CSR                 MOVE      OPTLN(1)      OPTLN1
     CSR                 MOVE      CMDLN(1)      CMDLN1
     C*
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $LPRG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*
     C*   Verify warehouse and get description.
     C*
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     $KWHSE        $LWHSE
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
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 END
     CSR                 END
     C*
     C*   Get work order # for transaction
     C*
417a C*R   wkKEY         chain     equipw2                            79
417a C*R   *IN79         IFEQ      *OFF
417a C*R                 Z-ADD     EWWRK#        WOWRK#
417a C*R                 ELSE
417a C*R                 Z-ADD     0             WOWRK#
417a C*R                 ENDIF
417aACSR                 Z-ADD     $KWRK#        WOWRK#
     C*
     C*   Get question for work order#
     C*
     CSR   keyea         chain     equipa1                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 move      eaqstn        woqstn
     CSR                 ELSE
     CSR                 move      *blanks       woqstn
     CSR                 ENDIF
     C*
     CSR                 EXSR      CLRSCH
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     CSR   ZZKEYF        BEGSR
     CSR                 MOVE      DSFKEY        $POFKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     CSR   ZZKEYU        BEGSR
     CSR                 MOVE      DSUKEY        $POUKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOPT    Process non-standard options.
     C*              Note: Error handling is done in routine OPTNS2.
     C*
     CSR   ZZOPT         BEGSR
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     CSR   ZZPOS         BEGSR
     C*
     C*  See if user is trying to change warehouse.
     C*
     C***  PTINP1        IFNE      0
     C*
     C*R                 Z-ADD     PTINP1        EAWHSE
     C*R                 Z-ADD     EAWHSE        $KWHSE
     C*R                 Z-ADD     0             EATRN#
     C*R                 MOVEL     $LERM         WHDESC
     C*R                 Z-ADD     0             PTINP1
     C*R                 MOVE      *ON           REPOS
     C***                END
     C*
     C*  See if user is trying to position to code
     C*
     C**   PTINP2        IFNE      *BLANKS
     C*R                 MOVE      PTINP2        EWWRK#
     C*R                 MOVE      *BLANKS       PTINP2
     C*R                 MOVE      *ON           REPOS
     C*R                 END
     C*
     CSR   ENDZPS        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     CSR   ZZPOS2        BEGSR
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R         $POCMD    IFEQ '*TOP'
     C*R         *LOVAL    SETLLRECORD
     C*R                   ELSE
     C*R         $POCMD    IFEQ '*BOTTOM'
     C*R         *HIVAL    SETLLRECORD
     C*R                   END
     C*R                   END
     C*
     C*    Code to use when we do have a partial key to use.
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
     O*  Compile time tables
     O*
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3=Exit  F12=Cancel
