     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*  LOADR51  Loader Module - Close Open Trailer Equipment - Display.
     F*           Reads input files LDRTRLE and LDRTEQ loaded by Loadr1.
     F*
     F*  October 29, 2008
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
     F*    XX/XX/XX  CBI-JGD
     F*      TEXT. . . .
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        Position cursor
     F*  21 - 29   Field input error (reverse display)
     F*  79        Chain indicator
     F*  97        Used by error message subfile
     F*  98        Error occured (sound buzzer)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLOAD51FM  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FWORKOPT   UF A E           K DISK
     FLDRTRLE1  IF   E           K DISK
     F                                     RENAME(EQREC:RECORD)
     FLDRTEQ    IF   E           K DISK
     F*PIRUSER1  IF   E           K DISK
     F*
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
     D MSG             S             50    DIM(3) CTDATA PERRCD(1)
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
     D  LEWHSE                 1      3  0
     D  LERTE                  4      8
     D*
     D* Note: You only need a seperate data structure if the keys are
     D*       different. If they are the same you can put DSUKEY
     D*       right after DSFKEY and remove this second data structure.
     D*
     D                 DS
     D  DSUKEY                 1     50
     D  UKWHSE                 1      3  0
     D  UKRTE#                 4      8
     D*----------------------------------------------------------------
     D*  Called programs-constants
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @CHGPG          C                   CONST('*NONE')
     D @DELPG          C                   CONST('*NONE')
     D @CLP            C                   CONST('LOADTEQCL2')
     D NOFND           C                   CONST('Employee# no found')
      *----------------------------------------------------------------
      * Program variables.
      *
     D $PGMID          s              7
     D*
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
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PRTE#                22     26
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
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERDATE                 1      6  0
     D*                                       1  10 ERRCL1
     D*                                      11  16 ERRCL2
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
     C*>                 PARM                    $PRTKY           50
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
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           *IN98
     CSR                 ELSE
     CSR                 SETON                                        02
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
     C*
     C*   If no error and no positioning to specific record
     C*   set cursor to 'Position to Code' field.
     C*
     CSR   *IN45         IFEQ      *OFF
     CSR   *IN98         ANDEQ     *OFF
     CSR                 SETOFF                                       03
     CSR                 WRITE     POSTNREC
     CSR                 ENDIF
     C*
     CSR                 READ      POSTNREC                               50
     CSR                 END
     CSR   NXTSCR        IFEQ      '02 '
     CSR                 EXSR      DELDSP
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       202122
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
     CSR                 MOVE      *ON           *IN90
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
     C*  TEST FOR CMD13 - LINK OUT
     C*
     CSR   *INKM         IFEQ      '1'
     C                   MOVEL     'LOADR51'     $PGMID
     CSR                 CALL      @CLP
     C                   PARM                    $PGMID
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD21 - PRINT
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
     CSR   *INKE         IFEQ      *ON
     CSR                 EXSR      CLRSCH
     CSR   1             DO        10            X
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      *OFF
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
     CSR   ERROR         CABEQ     *ON           CMD01E
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     C*
     C*
     C*  TEST FOR CMD6 - ADD RECORD
     C*
     CSR   *INKF         IFEQ      *ON
     C*  Verify if user has update authorization.
     C*
     CSR                 CALL      'CHKLIST'
     CSR                 PARM                    #PROG
     CSR                 PARM                    OPTION
     CSR                 PARM                    #USER
     CSR                 PARM      ' '           @PRTN             8
     C*
     CSR   @PRTN         IFEQ      '*NO'
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     MSG(2)        ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     C*
     CSR                 EXSR      INZPAR
     C*-11/9/07            MOVE WKOKYU    $PUKY            ADDED
     CSR                 MOVE      '*ADD    '    $PCMD
     C*>                 CALL      @CHGPG
     C*>                 PARM                    $PARMS
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
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 END
     C*
     C*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     C*
     CSR   *INKJ         IFEQ      *ON
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
     CSR                 MOVE      *ON           *IN01
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
     CSR   ERROR         CABEQ     *ON           ENT01E
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     CSR                 MOVE      *OFF          REPOS             1
     CSR                 EXSR      ZZPOS
     CSR   ERROR         CABEQ     *ON           ENT01E
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
     CSR   WKOOPT        IFEQ      ' 4'
     C*  Verify if user has update authorization.
     C*
     CSR                 CALL      'CHKLIST'
     CSR                 PARM                    #PROG
     CSR                 PARM                    OPTION
     CSR                 PARM                    #USER
     CSR                 PARM      ' '           @PRTN             8
     C*
     CSR   @PRTN         IFEQ      '*NO'
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     MSG(3)        ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      ENT02E
     CSR                 ENDIF
     C*
     C*
     C*  Call delete program
     C*
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
     C*>                 CALL      @DELPG
     C*>                 PARM                    $PARMS
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
     CSR   *IN79         IFEQ      *ON
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
     CSR   *IN79         IFEQ      *ON
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
     C     $POFKY        IFNE      *BLANKS
     CSR                 MOVE      $POFKY        DSFKEY
     C                   ENDIF
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
     C*     DO ALL DELETES FIRST (OPTION 4)
     C*
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      *OFF          STOP
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         DOWEQ     *OFF
     CSR   WKOOPT        ANDNE     ' 4'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR                 ENDDO
     CSR   *IN79         IFEQ      *OFF
     CSR   WKOOPT        ANDEQ     ' 4'
     C*  Verify if user has update authorization.
     C*
     CSR                 CALL      'CHKLIST'
     CSR                 PARM                    #PROG
     CSR                 PARM                    OPTION
     CSR                 PARM                    #USER
     CSR                 PARM      ' '           @PRTN
     C*
     CSR   @PRTN         IFEQ      '*NO'
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     MSG(3)        ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      OPTNSE
     CSR                 ENDIF
     C*
     CSR                 MOVE      *ON           OTAKEN
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 EXSR      SCR02I
     CSR                 GOTO      OPTNSE
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR   CANCEL        IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 ENDIF
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      *OFF          REFRSH
     CSR                 ENDIF
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
     CSR                 MOVEL     WKOKYU        $PUKY
     C*
     C*   Receive and close trailer equipment process
     C*
     CSR   WKOOPT        IFEQ      ' 2'
     C*  Verify if user has update authorization.
     C*
     CSR                 CALL      'CHKLIST'
     CSR                 PARM                    #PROG
     CSR                 PARM                    OPTION
     CSR                 PARM                    #USER
     CSR                 PARM      ' '           @PRTN
     C*
     CSR   @PRTN         IFEQ      '*NO'
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     MSG(1)        ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      OPNS2E
     CSR                 ENDIF
     C*
     CSR                 MOVE      '*CHANGE '    $PCMD
     CSR                 CALL      'LOADR53'
     CSR                 PARM                    LEWHSE
     CSR                 PARM                    $PCMD
     CSR                 PARM                    W1RTE#
     CSR                 PARM                    W1RTEI
     CSR                 PARM                    $PPRG
     CSR                 PARM                    $PRTN
     C*
     CSR                 ELSE
     C*
     C*   View
     C*
     CSR   WKOOPT        IFEQ      ' 5'
     CSR                 MOVE      '*VIEW   '    $PCMD
     CSR                 CALL      'LOADR53'
     CSR                 PARM                    LEWHSE
     CSR                 PARM                    $PCMD
     CSR                 PARM                    W1RTE#
     CSR                 PARM                    W1RTEI
     CSR                 PARM                    $PPRG
     CSR                 PARM                    $PRTN
     CSR                 ELSE
     C*
     C*   Print
     C*
     CSR   WKOOPT        IFEQ      ' 6'
     CSR                 MOVE      '*PRINT  '    $PCMD
     C*>                 CALL      @PRTPG
     C*>                 PARM                    $PARMS
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
     CSR   OPNS2E        ENDSR
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
     CSR   WKOOPT        IFEQ      ' 4'
     C*  Verify if user has update authorization.
     C*
     CSR                 CALL      'CHKLIST'
     CSR                 PARM                    #PROG
     CSR                 PARM                    OPTION
     CSR                 PARM                    #USER
     CSR                 PARM      ' '           @PRTN
     C*
     CSR   @PRTN         IFEQ      '*NO'
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     MSG(3)        ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 GOTO      ENDF2
     CSR                 ENDIF
     C*
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
     C*  READ FILE
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
     CSR                 MOVE      *OFF          *IN21
     CSR                 READC     DSPSFL                                 79
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
     CSR   *IN79         IFEQ      *OFF
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
     CSR                 MOVE      *OFF          *IN01
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
     C*  AND WHEN POSITIONING TO SPECIFIC RECORD ON THE SCREEN.
     C*
     CSR   ERROR         IFNE      *ON
     CSR   *IN45         ANDEQ     *ON
     CSR   1             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      *ON           *IN20
     CSR                 UPDATE    DSPSFL
     CSR                 END
     CSR                 END
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     CSR                 MOVE      *ON           *IN01
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
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      FKEY(X)       WKOKYF
     CSR                 MOVE      UKEY(X)       WKOKYU
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR   *IN78         IFEQ      *OFF
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 MOVE      WKOERR        *IN21
     CSR                 MOVE      WKOERR        *IN20
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       OPTION
     CSR                 MOVE      *OFF          *IN21
     CSR                 MOVE      *OFF          *IN20
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
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0102  Program not found.
     C*
     CSR   ZM0102        BEGSR
     CSR                 MOVE      'PIR0102'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0103  Program not found while exec. subroutine.
     C*
     CSR   ZM0103        BEGSR
     CSR                 MOVE      'PIR0103'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
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
     C*
     C*    PIR9906  Invalid date entered.
     C*
     CSR   ZM9906        BEGSR
     CSR                 MOVE      'PIR9906'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD    Process non-standard function keys
     C*
     CSR   ZZCMD         BEGSR
     C*
     C*  Test for F9 - Display one warehouses
     C*
     CSR   *INKI         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*F9     '    $RTNCD
     CSR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     CSR   ZZFGET        BEGSR
     C*
     C*    Code to use when file key and unique key are the same.
     C*
     C*R         FILUKY    CHAINRECORD               79
     C*
     C*    Code to use when file key and unique key are different.
     C*
     CSR   FILUKY        CHAIN     RECORD                             79
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
     CSR                 READ      RECORD                                 79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     C*R         *LOVAL    READERECORD                   79
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
     CSR                 READP     RECORD                                 79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     C*R         *LOVAL    REDPERECORD                   79
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     CSR   ZZFILL        BEGSR
     C*
     C*>   LDDEMP        CHAIN     PIRUSER1                           79
     C*    *IN79         IFEQ      *ON
     C*                  MOVE      *BLANKS       WEMPNA
     C*                  MOVEL     NOFND         WEMPNA
     C*                  MOVE      *BLANKS       WUSRCD
     C*                  ELSE
     C*
     C* All commented    MOVEL     USCODE        WUSRCD
     C*     out          MOVE      '*LFM    '    $CMD              8
     C* on 10/29/08      MOVE      *BLANKS       $NAME            40
     C*                  CALL      'FRMTNM'
     C*                  PARM                    $CMD
     C*                  PARM                    USFNAM
     C*                  PARM                    USINIT
     C*                  PARM                    USLNAM
     C*                  PARM                    $NAME
     C*                  MOVEL     $NAME         WEMPNA
     C*>                 ENDIF
     C*
     C*    Load screen with values from Ldrtrle file.
     C*    This file holds trailer equipment loaded by
     C*    route loader.
     C                   MOVE      LERTE         W1RTE#
     C                   MOVE      LERTID        W1RTEI
     C                   MOVE      LETRL#        W1TRL#
     C     LESTAT        IFEQ      'O'
     C                   MOVE      'OPEN'        W1STAT
     C                   ELSE
     C                   MOVE      'CLSE'        W1STAT
     C                   ENDIF
     C*
     C*    Get equipment loading date and time
     C     TEQKEY        CHAIN     LDRTEQ                             78
     C     *IN78         IFEQ      *ON
     C                   Z-ADD     *ZEROS        W1LDTE
     C                   Z-ADD     *ZEROS        W1LTIM
     C                   ELSE
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LTLDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1LDTE
     C                   MOVE      LTLTIM        W1LTIM
     C                   ENDIF
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  Define unique file key.
     C*
     CSR   FILUKY        KLIST
     C*>                 KFLD                    $LWHSE
     CSR                 KFLD                    LEWHSE
     CSR                 KFLD                    UKRTE#
     C*
     C*  Define full key for main file.
     C*
     CSR   FILEKY        KLIST
     C*>                 KFLD                    $LWHSE
     CSR                 KFLD                    LEWHSE
     C                   KFLD                    LERTE
     C*
     C*  Define partial key for main file (if needed).
     C*
     C*>         PARTKY    KLIST
     C*>                   KFLD           $LWHSE
     C*
     C*  Define full key for Ldrteq file.
     C*
     C     TEQKEY        KLIST
     C                   KFLD                    LEWHSE
     C                   KFLD                    LERTE
     C                   KFLD                    LERTID
     C*
     C*  Setup option and command display lines.
     C*
     CSR                 MOVE      OPTLN(1)      OPTLN1
     CSR                 MOVE      CMDLN(1)      CMDLN1
     C*
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $CVPRG
     CSR                 MOVE      #PROG         $LPRG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   Get warehouse for user.
     C*
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR                 PARM      0             #WHSE             3 0
     C*
     C*   Verify warehouse and get description.
     C*
     CSR                 Z-ADD     #WHSE         WHCODE
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     #WHSE         $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN03
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN03
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     CSR                 Z-ADD     #WHSE         $KWHSE
     CSR                 Z-ADD     #WHSE         WHCODE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 END
     CSR                 END
     C*
     CSR                 SETOFF                                       01
     CSR                 SETON                                        02
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
     CSR                 Z-ADD     LEWHSE        UKWHSE
     CSR                 MOVE      LERTE         UKRTE#
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
     C*  See if user is trying to position to a certain spot
     C*
XXX  C*>   PTINP1        IFNE      *BLANKS
XXX  C* Commented out    Z-ADD     PTINP1        LERTE
XXX  C* on 10/29/08      MOVE      *BLANKS       PTINP1
XXX  C*                  MOVE      *ON           REPOS
XXX  C*>                 END
     C*
     C*
     C*
     C*  See if user is trying to position to a certain spot
     C*
     C                   SETOFF                                       45
     C     PTINP1        IFNE      *BLANKS
     C                   MOVEL     PTINP1        LERTE
     C                   MOVE      *BLANKS       PTINP1
     C                   MOVE      *ON           REPOS
     C                   SETON                                        45
     C                   SETOFF                                       02
     C                   ENDIF
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
     CSR   *LOVAL        SETLL     RECORD
     CSR                 ELSE
     CSR   $POCMD        IFEQ      '*BOTTOM'
     CSR   *HIVAL        SETGT     RECORD
     CSR                 END
     CSR                 END
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**  ZOPT - Valid options
 2 5
**  OPTLN - Option display line
  2=Close  5=View
**  CMDLN - Command display line
F3=Exit F5=Refresh F9=By trailer F12=Cancel F13=LinkToClose F21=Print/LP04
**  MSG - Error messages
Not authorized to use option (2=Change)
Not authorized to use function key (F6=Create)
Not authorized to use option (4=Delete)
