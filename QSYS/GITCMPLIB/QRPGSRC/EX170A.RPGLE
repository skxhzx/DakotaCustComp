      /copy qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  EX170A  Item Runner Exceptions (One whse) - Display
     F*  24 May 2007
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
510 AF*  05/24/07  DAS  5.10
     F*    - Created.
     F*
700aA*    11/15/16  NLK  7.00a
     *      - Fix: Change to pass license # to LP130 was sending trans
     *      - Enh: Converted to ILE.
     *
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program uses two display subfiles to show more than one
     F*    view of the record. To see what was changed search for VW2
     F*    starting in column 1.
     F*
     F*    CMD5 changed to chain and update each view seperately.
     F*
     F*    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        Position Cursor
     F*  21 - 29   Field Input Error (Reverse Display)
     F*  79        Chain Indicator
     F*  81        Display subfile records (SFLDSP)
     F*  82        Display subfile screen (SFLDSPCTL)
     F*  83        Clear subfile (SFLCLR)
     F*  84        Allow subfile to display '+' (SFLEND)
     F*  85        Manually set subfile change flag (SFLNXTCHG)
     F*  90        Protect Input Fields for Delete Display
     F*  97        Always ON (Used for SFLEND Keyword)
     F*  98        Error on screen (Sound Buzzer)
     F*  99        Universal Record Indicator (Very Temporary Usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FEX170AFM  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(VW2SFL:RECNO)
     F                                     SFILE(VW3SFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FWORKOPT   UF A E           K DISK
     FITMEXCP1  IF   E           K DISK
     F                                     RENAME(EXREC:RECORD)
     FPIRITEM   IF   E           K DISK
700aAFLicense1  if   e           k disk
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
VW2 MD CMDLN           S             79    DIM(6) CTDATA PERRCD(1)
     D ERRD            S             25    DIM(1) CTDATA PERRCD(1)
     D STAT            S             10    DIM(2) CTDATA PERRCD(1)
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
700aAD pmwhse          s              3  0
700aAD pmtrn#          s              7  0

     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     D $PRTKY          DS
     D  $LEN50                 1     50
     D  $KWHSE                 1      3  0
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     D                 DS
     D  DSFKEY                 1     50
     D  DSUKEY                 1     50
     D  EXWHSE                 1      3  0 INZ(0)
     D  EXWHDP                 4      8
     D  EXSTYP                 9      9
     D  EXITEM                10     24
     D  EXGDTE                25     32  0
     D  EXGTIM                33     38  0
     D  DSTRN#                39     45  0
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D                 DS
     D  EXFDIS                 1     12
     D  EXTDIS                13     24
     D  DSRTRN                 1      7  0
     D  DSPTRN                 8     14  0
     D  DSPLBL                15     21  0
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
700aD *@CHGPG          C                   CONST('*NONE')
700aMD @chgpg          c                   const('NONE')
     D @DELPG          C                   CONST('EX174')
700aD *@PRTPG          C                   CONST('*NONE')
700aMD @prtpg          c                   const('NONE')
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
     D*
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PWHDP                22     26
     D  $PSTYP                27     27
     D  $PITEM                28     42
     D  $PGDTE                43     50  0
     D  $PGTIM                51     56  0
     D  $PTRN#                57     63  0
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
     D  $LSTYP                27     27
     D  $LITEM                28     42
     D  $LGDTE                43     50  0
     D  $LGTIM                51     56  0
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
     D*  Other data structures
     D*
     D                 DS
     D  DSHMS                  1      6  0
     D  DSHH                   1      2  0
     D  DSMM                   3      4  0
     D  DSSS                   5      6  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
414aAD*
414aAD  EROPT                  1     20
414aAD  ERSTAT                21     40
414aAD  ERTYPE                41     50
     D                 DS
     D  $EC                    1      2P 0
     D ERTYP1          C                   CONST('Item excpt')
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
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *BLANKS       $RTNCD
     C                   EXSR      ZZINZ2
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   EXSR      CLRSCH
     C                   SETON                                        LR
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
     CSR                 SELECT
     CSR   NXTSCR        WHENEQ    '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      POSTNREC                               50
     C*
     CSR   NXTSCR        WHENEQ    '02 '
     CSR                 EXSR      DELDSP
     C*
     CSR                 ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       2021
     CSR                 SETOFF                                       98
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CANCEL            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 READ      DSPSFC                                 50
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR                 READ      VW2SFC                                 50
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR                 READ      VW3SFC                                 50
VW2 ACSR                 ENDSL
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
     CSR                 MOVE      *ON           *IN90
     CSR                 MOVE      *LOVAL        $WKOF
     CSR                 MOVE      *LOVAL        $WKOU
TEST CSR                 WRITE     CLR0306
TEST C*                    WRITECLR1120
TEST C*R                   WRITECLR03END
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
     CSR                 MOVE      *OFF          *IN90
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
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*  Initialize subfile (DSPSFL) record
     C*
     C                   Z-ADD     1             RECNO
     C                   WRITE     DSPSFL                               79
222 DC*                    Z-ADD1         RECNO2
VW2 AC                   WRITE     VW2SFL                               79
222 DC*                    Z-ADD1         RECNO3
VW2 AC                   WRITE     VW3SFL                               79
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
     CSR   *IN79         DOWEQ     *OFF
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
     CSR   *INKC         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*EXIT   '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     C*
     C*     TEST FOR CMD5 - REFRESH
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 EXSR      CLRSCH
     CSR   1             DO        10            X
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      '  '          OPTION
     CSR                 UPDATE    DSPSFL
     CSR                 END
222 ACSR   X             CHAIN     VW2SFL                             79
222 ACSR   *IN79         IFEQ      *OFF
222 ACSR                 MOVE      '  '          OPTION
222 ACSR                 UPDATE    VW2SFL
222 ACSR                 END
222 ACSR   X             CHAIN     VW3SFL                             79
222 ACSR   *IN79         IFEQ      *OFF
222 ACSR                 MOVE      '  '          OPTION
222 ACSR                 UPDATE    VW3SFL
222 ACSR                 END
     CSR                 END
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     C*
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     *ON           CMD01E
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     C*
     C*  TEST FOR CMD6 - ADD RECORD
     C*
     CSR   *INKF         IFEQ      *ON
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*ADD    '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
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
VW2 MCSR   *INKU         IFEQ      *ON
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
     CSR                 MOVE      *ON           ERROR
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
     C*R         CLERR     CABEQ*ON       CMD01E
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
VW2 AC*
VW2 AC*  TEST FOR CMD10 - Previous view
VW2 AC*
VW2 ACSR   *INKJ         IFEQ      *ON
VW2 ACSR   VIEW          IFEQ      1
VW2 ACSR                 Z-ADD     MAXVW         VIEW
VW2 ACSR                 ELSE
VW2 ACSR                 SUB       1             VIEW
VW2 ACSR                 ENDIF
VW2 ACSR   VIEW          MULT      2             V                 2 0
VW2 ACSR                 MOVE      CMDLN(V)      CMDLN2
VW2 ACSR                 SUB       1             V
VW2 ACSR                 MOVE      CMDLN(V)      CMDLN1
VW2 ACSR                 GOTO      CMD01E
VW2 ACSR                 END
VW2 AC*
VW2 AC*  TEST FOR CMD11 - Next view
VW2 AC*
VW2 ACSR   *INKK         IFEQ      *ON
VW2 ACSR   VIEW          IFEQ      MAXVW
VW2 ACSR                 Z-ADD     1             VIEW
VW2 ACSR                 ELSE
VW2 ACSR                 ADD       1             VIEW
VW2 ACSR                 ENDIF
VW2 ACSR   VIEW          MULT      2             V                 2 0
VW2 ACSR                 MOVE      CMDLN(V)      CMDLN2
VW2 ACSR                 SUB       1             V
VW2 ACSR                 MOVE      CMDLN(V)      CMDLN1
VW2 ACSR                 GOTO      CMD01E
VW2 ACSR                 END
     C*
     C*  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     C*
     CSR   *INKR         IFEQ      *ON
     CSR                 MOVE      '*TOP    '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     C*
     CSR   *INKS         IFEQ      *ON
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
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      *ON           CANCEL
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
     C*R         CLERR     CABEQ*ON       DELADE
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
VW2 ACSR                 WRITE     VW2SFL
VW2 ACSR                 WRITE     VW3SFL
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
     CSR                 MOVE      *ON           *IN81
     CSR                 Z-ADD     1             RECNO
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 WRITE     DSPSFC
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR                 WRITE     VW2SFC
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR                 WRITE     VW3SFC
VW2 ACSR                 ENDSL
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
     CSR   ERROR         CABEQ     *ON           ENT01E
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     CSR                 MOVE      *OFF          REPOS             1
     CSR                 EXSR      ZZPOS
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
     C*R         OTAKEN    IFEQ *OFF
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
     CSR                 MOVE      *OFF          STOP
     CSR   STOP          DOUEQ     *ON
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR                 ELSE
     C*
     CSR   WKOOPT        IFEQ      ' 1'
     C*
     C*  Call delete program
     C*
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
414aAC*
414aAC*    Verify that route is still at "open" status.
414aAC*
414aACSR                 EXSR      ZZCKST
414aACSR   STSERR        IFEQ      *ON
414aACSR                 DELETE    WKOREC
414aACSR                 ITER
414aACSR                 ENDIF
414aAC*
     CSR                 CALL      @DELPG
     CSR                 PARM                    $PARMS
     C*
     C*     Error occured - Error message sent back
     C*
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           CANCEL
     CSR                 MOVE      *ON           STOP
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     C*
     C*     Error occured - Error message sent to program msgq
     C*
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           CANCEL
     CSR                 MOVE      *ON           STOP
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     C*
     C*     Delete canceled
     C*
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      *ON           CANCEL
     CSR                 MOVE      *ON           STOP
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
     CSR   CANCEL        IFEQ      *OFF
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      *ON           WKOERR
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
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      '*NOTFND '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
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
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
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
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
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
     CSR                 MOVE      *OFF          OTAKEN            1
     C*
     C*     Do all closes first (OPTION 1)
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      *OFF          STOP
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         DOWEQ     *OFF
     CSR   WKOOPT        ANDNE     ' 1'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR                 END
     CSR   *IN79         IFEQ      *OFF
     CSR   WKOOPT        ANDEQ     ' 1'
     CSR                 MOVE      *ON           OTAKEN
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 EXSR      SCR02I
     CSR                 GOTO      OPTNSE
     CSR                 END
     C*
     C*  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     C*     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      *OFF          CANCEL            1
     CSR                 MOVE      *OFF          STOP              1
     CSR   STOP          DOUEQ     *ON
     CSR   CANCEL        OREQ      *ON
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR                 ELSE
     CSR   WKOOPT        IFNE      '  '
     CSR                 MOVE      *ON           OTAKEN
     CSR                 EXSR      OPTNS2
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR                 MOVE      *ON           REFRSH
     CSR   ERROR         IFEQ      *OFF
     CSR                 DELETE    WKOREC
     CSR                 END
     CSR   CANCEL        IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      *OFF          REFRSH
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     CSR   REFRSH        IFEQ      *ON
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      *OFF          REFRSH            1
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
     CSR                 MOVE      '*CHANGE '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     CSR                 ELSE
     C*
     C*   View
     C*
     CSR   WKOOPT        IFEQ      ' 5'
700aD *    @CHGPG      **ANDNE     '*NONE'
700aMC     @CHGPG        ANDNE     'NONE'
     CSR                 MOVE      '*VIEW   '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     CSR                 ELSE
     C*
     C*   Print
     C*
     CSR   WKOOPT        IFEQ      ' 6'
     CSR                 MOVE      '*PRINT  '    $PCMD
     CSR                 CALL      @PRTPG
     CSR                 PARM                    $PARMS
     CSR                 ELSE
     CSR                 EXSR      ZZOPT
     CSR                 END
     CSR                 END
     CSR                 END
     C*
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      *ON           CANCEL
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           CANCEL
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           CANCEL
     CSR                 MOVE      *ON           ERROR
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
     C*R         CLERR     CABEQ*ON       PAG01E
     CSR                 MOVE      *OFF          TOP
     CSR                 MOVE      *OFF          BOT
     CSR                 MOVE      *OFF          FORCEB
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     C*
     C*  BOTTOM
     C*
     CSR   PAGCMD        IFEQ      '*BOTTOM '
     CSR                 MOVE      *ON           BOT
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
     C*R         CLERR     CABEQ*ON       PAG01E
     CSR                 MOVE      *OFF          BOT
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     C*
     C*  REPOSITIONING
     C*
     CSR   PAGCMD        IFEQ      '*REPOS  '
     CSR                 MOVE      *OFF          BOT
     CSR                 MOVE      *OFF          FORCEB
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
     CSR                 MOVE      *OFF          BOT
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
     CSR   BOT           CABEQ     *ON           ENDF
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 MOVE      *OFF          BOT               1
     CSR                 MOVE      *OFF          TOP               1
     CSR                 MOVE      *OFF          STOP              1
     CSR                 Z-ADD     0             P                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     CSR   STOP          DOUEQ     *ON
     CSR                 MOVE      '*GETNEXT'    $POCMD
     CSR                 EXSR      FGTWAY
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      *ON           STOP
     CSR                 MOVE      *ON           BOT
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 GOTO      ENDFAC
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     CSR                 ADD       1             P
     CSR                 EXSR      SFLADD
     CSR   P             IFGE      10
     CSR                 MOVE      *ON           STOP
     CSR   FORCEB        IFEQ      *ON
     CSR                 MOVE      *ON           BOT
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
     CSR                 MOVE      *OFF          FORCEB
     CSR   ENDF          ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
     C*
     CSR   PAG1BK        BEGSR
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     CSR   TOP           CABEQ     *ON           ENDB
     CSR                 MOVE      *OFF          FORCEB            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      *ON
     CSR   GOBACK        IFEQ      10
     CSR                 MOVE      *ON           FORCEB
     CSR                 END
     CSR                 MOVE      '*BOTTOM '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ADD       1             GOBACK
     CSR                 END
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 Z-ADD     0             P
     CSR                 MOVE      *OFF          TOP
     CSR                 MOVE      *OFF          BOT
     CSR                 MOVE      *OFF          STOP
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     CSR   STOP          DOUEQ     *ON
     CSR                 MOVE      '*GETPREV'    $POCMD
     CSR                 EXSR      FGTWAY
     C*
     C*  HIT TOP OF FILE
     C*
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      *ON           STOP
     CSR                 MOVE      *ON           TOP
     CSR                 GOTO      ENDBK
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      *ON           STOP
     CSR                 END
     CSR   ENDBK         TAG
     CSR                 END
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     CSR   TOP           IFEQ      *ON
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
     CSR   BOT           CABEQ     *ON           ENDF2
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        $WKOF
     CSR                 MOVE      *LOVAL        $WKOU
     CSR                 MOVE      *OFF          BOT               1
     CSR                 MOVE      *OFF          TOP               1
     CSR                 MOVE      *OFF          STOP              1
     CSR                 Z-ADD     0             P                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     CSR   STOP          DOUEQ     *ON
     CSR   WKOPRT        READE     WORKOPT                                79
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR                 MOVE      *ON           BOT
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 GOTO      ENDFW2
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     CSR   WKOOPT        IFEQ      ' 1'
     CSR                 ADD       1             P
     CSR                 EXSR      DELADD
     CSR   P             IFGE      10
     CSR                 MOVE      *ON           STOP
     CSR   FORCEB        IFEQ      *ON
     CSR                 MOVE      *ON           BOT
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
     CSR                 MOVE      *OFF          FORCEB
     CSR   ENDF2         ENDSR
     C*----------------------------------------------------------------
     C*
     C*  PAG2BK   Let's see the previous page of delete records
     C*
     CSR   PAG2BK        BEGSR
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     CSR   TOP           CABEQ     *ON           ENDB2
     CSR                 MOVE      *OFF          FORCEB            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      *ON
     CSR   WKOPRT        SETGT     WORKOPT
     CSR                 ADD       1             GOBACK
     CSR                 END
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     CSR                 Z-ADD     0             P
     CSR                 MOVE      *OFF          TOP
     CSR                 MOVE      *OFF          BOT
     CSR                 MOVE      *OFF          STOP
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     CSR   STOP          DOUEQ     *ON
     CSR   WKOPRT        READPE    WORKOPT                                79
     C*
     C*  HIT TOP OF FILE
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR                 MOVE      *ON           TOP
     CSR                 GOTO      ENDBK2
     CSR                 END
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     CSR   WKOOPT        IFEQ      ' 4'
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      *ON           STOP
     CSR                 END
     CSR                 END
     CSR   ENDBK2        TAG
     CSR                 END
     C*
     C* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     C*
     CSR   TOP           IFEQ      *ON
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
     CSR   ERROR         CABEQ     *ON           ROL01E
     CSR                 MOVE      '*NEXT   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 END
     C*
     C*  TEST FOR ROLLDOWN
     C*
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     *ON           ROL01E
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
     CSR                 MOVE      *OFF          NOMORE            1
     CSR   NOMORE        DOUEQ     *ON
     CSR                 MOVE      *OFF          *IN85
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 READC     DSPSFL                                 79
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR                 READC     VW2SFL                                 79
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR                 READC     VW3SFL                                 79
VW2 ACSR                 ENDSL
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           NOMORE
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
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN85
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM0108
     CSR                 END
     CSR                 END
     C*
     C*  SAVE OPTION
     C*
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 Z-ADD     RECNO         Y                 3 0
VW2 ACSR   VIEW          WHENEQ    2
222 DC*R                   Z-ADDRECNO2    Y       30
222 MCSR                 Z-ADD     RECNO         Y                 3 0
VW2 ACSR   VIEW          WHENEQ    3
222 DC*R                   Z-ADDRECNO3    Y       30
222 MCSR                 Z-ADD     RECNO         Y                 3 0
VW2 ACSR                 ENDSL
     CSR                 MOVE      FKEY(Y)       WKOKYF
     CSR                 MOVE      UKEY(Y)       WKOKYU
     CSR   WKOUNQ        CHAIN     WORKOPT                            79
     CSR   *IN79         IFEQ      *OFF
     CSR   OPTION        IFEQ      *BLANKS
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      OPTION        WKOOPT
     CSR                 MOVE      *IN85         WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 ELSE
     CSR   OPTION        IFNE      *BLANKS
     CSR                 MOVE      #USER         WKOUSR
     CSR                 MOVE      #PROG         WKOPGM
     CSR                 MOVE      FKEY(Y)       WKOKYF
     CSR                 MOVE      UKEY(Y)       WKOKYU
     CSR                 MOVE      OPTION        WKOOPT
     CSR                 MOVE      *IN85         WKOERR
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
     CSR   RECCNT        IFLT      11
     CSR                 ADD       1             RECCNT
     CSR                 Z-ADD     RECCNT        RECNO
222 DC*R                   Z-ADDRECCNT    RECNO2
222 DC*R                   Z-ADDRECCNT    RECNO3
     CSR                 Z-ADD     RECCNT        Y
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
VW2 ACSR                 WRITE     VW2SFL
VW2 ACSR                 WRITE     VW3SFL
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
     CSR                 MOVE      *OFF          *IN81
     CSR                 MOVE      *OFF          *IN82
     CSR                 MOVE      *ON           *IN83
     CSR                 MOVE      *ON           *IN84
     C*
     CSR                 WRITE     DSPSFC
VW2 ACSR                 WRITE     VW2SFC
VW2 ACSR                 WRITE     VW3SFC
     CSR                 Z-ADD     0             RECCNT            4 0
     CSR                 Z-ADD     1             POSREC            4 0
     CSR                 Z-ADD     0             RECNO             4 0
222 DC*R                   Z-ADD0         RECNO2  40
222 DC*R                   Z-ADD0         RECNO3  40
     C*
     CSR                 MOVE      *ON           *IN82
     CSR                 MOVE      *OFF          *IN83
     C*
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
     CSR   ERROR         IFNE      *ON
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR   1             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      *ON           *IN20
     CSR                 UPDATE    DSPSFL
     CSR                 END
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR   1             CHAIN     VW2SFL                             79
VW2 ACSR   *IN79         IFEQ      *OFF
VW2 ACSR                 MOVE      *ON           *IN20
VW2 ACSR                 UPDATE    VW2SFL
VW2 ACSR                 END
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR   1             CHAIN     VW3SFL                             79
VW2 ACSR   *IN79         IFEQ      *OFF
VW2 ACSR                 MOVE      *ON           *IN20
VW2 ACSR                 UPDATE    VW3SFL
VW2 ACSR                 END
VW2 ACSR                 ENDSL
     CSR                 END
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
222 DC*R         RECCNT    IFGT 0
     CSR                 MOVE      *ON           *IN81
222 DC*R                   ENDIF
     CSR                 Z-ADD     POSREC        RECNO
222 DC*R                   Z-ADDPOSREC    RECNO2
222 DC*R                   Z-ADDPOSREC    RECNO3
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 WRITE     DSPSFC
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR                 WRITE     VW2SFC
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR                 WRITE     VW3SFC
VW2 ACSR                 ENDSL
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLOPT   Initialize options for subfile
     C*
     CSR   SFLOPT        BEGSR
     CSR   1             DO        10            X                 3 0
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR   X             CHAIN     DSPSFL                             79
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR   X             CHAIN     VW2SFL                             79
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR   X             CHAIN     VW3SFL                             79
VW2 ACSR                 ENDSL
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      FKEY(X)       WKOKYF
     CSR                 MOVE      UKEY(X)       WKOKYU
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR   *IN78         IFEQ      *OFF
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 MOVE      WKOERR        *IN85
     CSR                 MOVE      WKOERR        *IN21
     CSR                 MOVE      WKOERR        *IN20
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       OPTION
     CSR                 MOVE      *OFF          *IN21
     CSR                 MOVE      *OFF          *IN20
     CSR                 MOVE      *OFF          *IN85
     CSR                 END
VW2 ACSR                 SELECT
VW2 ACSR   VIEW          WHENEQ    1
     CSR                 UPDATE    DSPSFL
VW2 ACSR   VIEW          WHENEQ    2
VW2 ACSR                 UPDATE    VW2SFL
VW2 ACSR   VIEW          WHENEQ    3
VW2 ACSR                 UPDATE    VW3SFL
VW2 ACSR                 ENDSL
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
     CSR                 MOVE      *OFF          *IN97
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
414aAC*----------------------------------------------------------------
414aAC*   PIR9907  &1 no longer at status of &2.
414aAC*
414aACSR   ZM9907        BEGSR
414aACSR                 MOVE      'PIR9907'     #MSGID
414aACSR                 MOVE      '*DIAG  '     #MSGTP
414aACSR                 MOVEA     ERRMSG        $MD(1)
414aACSR                 EXSR      ZMPMSG
414aACSR                 ENDSR
414aAC*----------------------------------------------------------------
414aAC*
414aAC*  ZZCKST   Check status of the item before proceeding.
414aAC*
414aACSR   ZZCKST        BEGSR
414aAC*
414aACSR                 MOVE      *OFF          STSERR
414aACSR                 MOVE      EXWHSE        KYWHSE
414aACSR                 MOVE      EXITEM        KYITEM
     CSR                 MOVE      '*MDYCMD '    $CVCMD
     CSR                 MOVE      W2GDTE        $CVD6I
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        KYGDTE
414aACSR                 MOVE      W2GTIM        KYGTIM
414aAC*
414aACSR   KEYEX         CHAIN     ITMEXCP1                           79
414aAC*
414aAC*    If *IN79 - off - Item is no longer at correct status. Halt user
414aAC*    from proceeding.
414aAC*
414aACSR                 SELECT
414aACSR   *IN79         WHENEQ    *OFF
414aACSR   EXESTA        ANDNE     '1 '
414aACSR                 MOVE      *ON           STSERR
414aACSR                 MOVE      *ON           ERROR
414aACSR                 MOVE      *ON           *IN21
414aACSR                 MOVEL(P)  KYITEM        EROPT
414aACSR                 MOVEL(P)  STAT(1)       ERSTAT
414aACSR                 MOVEL(P)  ERTYP1        ERTYPE
414aACSR                 EXSR      ZM9907
414aACSR                 ENDSL
414aAC*
414aACSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD    Process non-standard function keys
     C*
     CSR   ZZCMD         BEGSR
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     C*     Warehouse department.
     C*
     CSR   ROW#          IFEQ      4
     CSR   COL#          ANDGE     48
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     PTINP1        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        PTINP1
     CSR                 END
     CSR                 ELSE
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 END
     CSR                 GOTO      ENDCM1
     CSR                 END
     C*
     C*
     C*  Test for F8 - Truck detail
     C*
415cDC*R         *INKH     IFEQ *ON
415cDC*R                   MOVE '*CHANGE '$PCMD
415cDC*R                   CALL 'TM110A'
415cDC*R                   PARM           $PRTKY
415cDC*R                   PARM           $RTNCD
415cDC*R                   ENDIF
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     CSR   ZZFGET        BEGSR
     C*
     C*    Code to use when file key and unique key are the same.
     C*
     CSR   FILEKY        CHAIN     RECORD                             79
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
     C*                    READ RECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     CSR   PARTKY        READE     RECORD                                 79
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR   EXTASK        ANDNE     'RUNNER'
     CSR                 GOTO      TRY1
     CSR                 ENDIF
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
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR   EXTASK        ANDNE     'RUNNER'
     CSR                 GOTO      TRY2
     CSR                 ENDIF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     CSR   ZZFILL        BEGSR
     C*
     C*    Load file fields into subfile fields for display.
     C*
     CSR                 MOVE      EXITEM        W1ITEM
     C*
     CSR                 SELECT
     CSR   EXESTA        WHENEQ    '1 '
     CSR                 MOVEL     'Open    '    W1STAT
     C*
     CSR   EXESTA        WHENEQ    '4 '
     CSR                 MOVEL     'Closed  '    W1STAT
     C*
     CSR                 ENDSL
     C*
     C*   Summary totals
     C*
     CSR   KEYIT         CHAIN     PIRITEM                            79
     CSR   *IN79         IFEQ      *ON
     CSR   *NOKEY        CLEAR                   ITREC
     CSR                 ENDIF
     CSR                 MOVE      ITPDSC        W2PDSC
417a CSR                 MOVEL     ITDESC        W2DESC
417a C**                   MOVE ITDESC    W2DESC
     C*
     C*    Convert generated date to mm/dd/yy format.
     C*
     CSR   EXGDTE        IFEQ      0
     CSR                 MOVE      *ZEROS        W2GDTE
     CSR                 ELSE
     CSR                 MOVE      '*CMDMDY '    $CVCMD
     CSR                 MOVE      EXGDTE        $CVD8I
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD6O        W2GDTE
     CSR                 ENDIF
     CSR                 Z-ADD     EXGTIM        W2GTIM
     CSR                 MOVE      EXGBY         W2GBY
     C*
     CSR                 MOVE      EXTASK        W3TASK
     C*
     C*    Load error description. If no match for error id,
     C*    then load error id for description.
     C*
     CSR                 SELECT
     CSR   EXERID        WHENEQ    'OVRZRO'
     CSR                 MOVEL     ERRD(1)       W3ERDS
     CSR                 Z-ADD     DSRTRN        W1RTRN
     CSR                 Z-ADD     DSPTRN        W1PTRN
     CSR                 Z-ADD     DSPLBL        W1PLBL
     C*
     CSR                 OTHER
     CSR                 MOVEL(P)  EXERID        W3ERDS
     CSR                 ENDSL
     CSR                 MOVE      EXUSER        W3USER
     C*
     C*    Convert corrected date to mm/dd/yy format.
     C*
     CSR   EXCDTE        IFEQ      0
     CSR                 MOVE      *ZEROS        W3CDTE
     CSR                 ELSE
     CSR                 MOVE      '*CMDMDY '    $CVCMD
     CSR                 MOVE      EXCDTE        $CVD8I
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD6O        W3CDTE
     CSR                 ENDIF
     CSR                 Z-ADD     EXCTIM        W3CTIM
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      *ON           FOREVR            1
     CSR                 MOVE      *OFF          STSERR            1
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
     C*  Define full key for main file.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    EXWHSE
     CSR                 KFLD                    EXITEM
     CSR                 KFLD                    EXGDTE
     CSR                 KFLD                    EXGTIM
     C*
     C*  Define UNIQ key for main file.
     C*
     CSR   FILUKY        KLIST
     CSR                 KFLD                    EXWHSE
     CSR                 KFLD                    EXITEM
     CSR                 KFLD                    EXGDTE
     CSR                 KFLD                    EXGTIM
     C*
     C*  Define UNIQ key for main file.
     C*
     CSR   *LIKE         DEFINE    EXWHSE        KYWHSE
     CSR   *LIKE         DEFINE    EXITEM        KYITEM
     CSR   *LIKE         DEFINE    EXGDTE        KYGDTE
     CSR   *LIKE         DEFINE    EXGTIM        KYGTIM
     CSR   KEYEX         KLIST
     CSR                 KFLD                    KYWHSE
     CSR                 KFLD                    KYITEM
     CSR                 KFLD                    KYGDTE
     CSR                 KFLD                    KYGTIM
     C*
     C*  Define partial key for main file (if needed).
     C*
     CSR   *LIKE         DEFINE    EXITEM        $KITEM
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $KWHSE
     C*R                   KFLD           $KITEM
     C*
     C*  Define key for file PIRITEM.
     C*
     CSR   KEYIT         KLIST
     CSR                 KFLD                    EXWHSE
     CSR                 KFLD                    EXITEM
     *
     *  Define key for LICENSE1
     *
700aAC     keyli         klist
700aAC                   kfld                    pmwhse
700aAC                   kfld                    pmtrn#
     C*
     C*  Setup option and command display lines.
     C*
VW2 ACSR                 Z-ADD     1             VIEW              1 0
VW2 ACSR                 Z-ADD     3             MAXVW             1 0
     CSR                 MOVE      OPTLN(1)      OPTLN1
     CSR                 MOVE      CMDLN(1)      CMDLN1
VW2 ACSR                 MOVE      CMDLN(2)      CMDLN2
     C*
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      #PROG         $CVPRG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ2        BEGSR
     CSR                 MOVE      $PRTKY        DSFKEY
     C*
     C*   Get warehouse for user.
     C*
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR   EXWHSE        PARM      0             #WHSE             3 0
     C*
     C*   Verify warehouse and get description.
     C*
     CSR                 Z-ADD     EXWHSE        WHCODE
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     EXWHSE        $LWHSE
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
     CSR                 ELSE
     CSR                 Z-ADD     EXWHSE        $KWHSE
     CSR                 Z-ADD     EXWHSE        WHCODE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 END
     CSR                 END
     CSR                 MOVE      *BLANKS       EXITEM
     CSR                 MOVE      *ZEROS        EXGDTE
     CSR                 MOVE      *ZEROS        EXGTIM
     C*
     CSR                 EXSR      CLRSCH
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     CSR   ZZKEYF        BEGSR
     C*
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
     C*
     CSR                 SELECT
     C*
     C*   License Info
     C*
     C                   when      wkoopt = ' 5'
     C                   eval      dsukey = $puky
700aAC                   eval      $llcns = *blanks
700aAC                   if        dstrn# <> 0
700aAC                   eval      pmwhse = exwhse
700aAC                   eval      pmtrn# = dstrn#
700aAC     keyli         chain     license1                           78
700aAC                   if        *in78
700aAC                   eval      lilcns = *blanks
700aAC                   endif
700aAC                   endif
700aAC                   eval      $llcns = lilcns
     C                   CALL      'LP130'
     C                   PARM      '*NOOPT  '    $LPCMD            8
700aAC                   parm                    $llcns           15
700aD *                  PARM      DSTRN#   **   $LPTRN            7 0
      *
     C                   ENDSL
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     CSR   ZZPOS         BEGSR
     C*
     C*  See if user is trying to change warehouse.
     C*
     CSR   PTINP1        IFNE      0
     C*
     C*      Verify warehouse entry.
     C*
     CSR                 Z-ADD     PTINP1        WHCODE
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     PTINP1        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      ENDZPS
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 GOTO      ENDZPS
     CSR                 ELSE
     CSR                 Z-ADD     PTINP1        EXWHSE
     CSR                 Z-ADD     EXWHSE        $KWHSE
     CSR                 MOVE      *BLANKS       EXITEM
     CSR                 Z-ADD     PTINP1        WHCODE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 MOVE      *ZEROS        PTINP1
     CSR                 MOVE      *ON           REPOS
     CSR                 END
     CSR                 END
     CSR                 END
     C*
     C*  See if user is trying to position to item.
     C*
     CSR   PTINP2        IFNE      *BLANKS
     CSR                 MOVE      PTINP2        EXITEM
     CSR                 MOVE      *BLANKS       PTINP2
     CSR                 MOVE      *ON           REPOS
     CSR                 END
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
 1
**  OPTLN - Option display line
  1=Clear exception
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**  Exception error coes
Zero w/avail qty override
**  STAT - Item exception status codes
Open
Closed
