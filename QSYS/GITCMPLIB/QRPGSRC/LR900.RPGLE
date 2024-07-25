     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LR900     Lot/License plate Lookup/Verify
     F*  17 January 2003
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    01/17/03  MLB  4.17
     F*      - Created.
417aAF*    08/13/03  MLB  4.17a
     F*      - Enh: Added two new fields to $RDATA dats structure.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        POSITION CURSOR
     F*  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  79        CHAIN INDICATOR
     F*  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     F*  91        PROTECT "POSITION TO" FIELD #1
     F*  92        PROTECT "POSITION TO" FIELD #2
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLR900FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     FWORKOPT   UF A E           K DISK
     FLICHIST2  IF   E           K DISK
     F                                     RENAME(LRREC:RECORD)
     FWAREHS    IF   E           K DISK
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
     D DESC            S             20    DIM(1) CTDATA PERRCD(1)
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
     D  $LWHDP                22     26
     D  $LAISL                27     29
     D  $LLOC                 30     32  0
     D  $LLVL                 33     34  0
     D  $LHAND                35     36
417aAD  $LFSLP                35     36P 0
417aAD  $LTSLP                37     38P 0
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     D                 DS
     D  DSKEY                  1     50
     D  LRWHSE                 1      3  0 INZ(0)
     D  LRLCNS                 4     18
     D  LRLTRN                19     25  0
     D  LRTWHD                26     30
     D  LRTASL                31     33
     D  LRTLOC                34     36  0
     D  LRTLVL                37     38  0
     D  LRTHND                39     40
417aAD  LRFSLP                41     42P 0
417aAD  LRTSLP                43     44P 0
     D*----------------------------------------------------------------
     D*  Data structure for PgUp/Dn routines
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
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
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
     C*      $LCMD   *SELECT  - Selection lookup.
     C*              *VERIFY  - Verify key.
     C*      $LPRG   Program to send messages back to.
     C*      $LUKY   Contains key to be verified.
     C*
     C*    Returned Parameters
     C*      $LUKY   Contains first key selected.
     C*      $LRTN   blank    - No problem encountered.
     C*              *OK      - Unique key exists for *VERIFY
     C*              *CANCEL  - CMD12 was entered
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*              -or- Description of verified code.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $LPARM
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *BLANKS       $LRTN
     C                   EXSR      ZZINZ2
     C     $LCMD         IFEQ      '*VERIFY '
     C                   EXSR      ZZVRFY
     C                   MOVE      'EOJ'         NXTSCR
     C                   ELSE
     C                   EXSR      CLRSCH
     C                   EXSR      SCR01I
     C                   ENDIF
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   ENDCS
     C                   ENDDO
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
     CSR   NXTSCR        IFEQ      '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      POSTNREC                               50
     CSR                 ENDIF
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
     CSR                 ENDCS
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
     C*  Initialize subfile (DSPSFL) record
     C*
     C                   Z-ADD     1             RECNO
     C                   WRITE     DSPSFL                               79
     C*
     C*   Make sure option work file is empty.
     C*
     C                   EXSR      CLRSCH
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
     CSR                 ENDDO
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
     CSR                 MOVE      '*EXIT   '    $LRTN
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $LRTN
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 ENDDO
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     C*
     C*  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     C*
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     *ON           CMD01E
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
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
     CSR                 ENDIF
     C*
     C*     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     C*
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      UKEY(ROW#)    $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     C*
     C*  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     C*
     CSR   *INKR         IFEQ      *ON
     CSR                 MOVE      '*TOP    '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     C*
     C*  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     C*
     CSR   *INKS         IFEQ      *ON
     CSR                 MOVE      '*BOTTOM '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     CSR   CMD01E        ENDSR
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
     CSR                 MOVE      DSKEY         $POFKY
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ENT01E
     CSR                 ENDIF
     C*
     C*  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     C*
     CSR                 EXSR      OPTNS
     C*
     C*  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     C*
     CSR   OTAKEN        IFEQ      *OFF
     CSR                 MOVE      '*CANCEL '    $LRTN
     CSR                 ELSE
     CSR                 MOVE      '*SELECT '    $LRTN
     CSR                 ENDIF
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR   ENT01E        ENDSR
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
     CSR                 ENDCS
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are the same.
     C*
     CSR   FGET          BEGSR
     CSR                 MOVE      $POUKY        DSKEY
     CSR   FILEKY        CHAIN     RECORD                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      '*NOTFND '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 ENDIF
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
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FPOS2    Position to record
     C*
     CSR   FPOS2         BEGSR
     CSR                 MOVE      $POFKY        DSKEY
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
     C*  OPTNS    Perform options that user entered
     C*
     CSR   OPTNS         BEGSR
     C*
     C*  Move first selected value to $LUKY  parameter and set
     C*     the option taken flag.
     C*
     CSR                 MOVE      *OFF          OTAKEN            1
     CSR   WKOPRT        SETLL     WORKOPT
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      *ON           OTAKEN
     CSR                 MOVE      WKOKYU        $LUKY
     CSR                 ENDIF
     CSR   OPTNSE        ENDSR
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
     CSR                 ENDIF
     CSR                 EXSR      FGTWAY
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
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 MOVE      *BLANKS       PAGCMD            8
     CSR   PAG01E        ENDSR
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
     CSR                 GOTO      ENDFWD
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDFWD        TAG
     CSR                 ENDDO
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
     CSR                 ENDIF
     CSR                 MOVE      '*BOTTOM '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ADD       1             GOBACK
     CSR                 ENDIF
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
     CSR                 ENDIF
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      *ON           STOP
     CSR                 ENDIF
     CSR   ENDBK         TAG
     CSR                 ENDDO
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     CSR   TOP           IFEQ      *ON
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ENDIF
     CSR                 EXSR      PAG1FW
     CSR   ENDB          ENDSR
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
     CSR                 ENDIF
     C*
     C*  TEST FOR ROLLDOWN
     C*
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     *ON           ROL01E
     CSR                 MOVE      '*PREV   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 ENDIF
     CSR   ROL01E        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SAVOPT   Verify and save options that were entered
     C*
     CSR   SAVOPT        BEGSR
     C*
     C*  Read only the changed options.
     C*
     CSR                 MOVE      *OFF          NOMORE            1
     CSR   NOMORE        DOUEQ     *ON
     CSR                 MOVE      *OFF          *IN21
     CSR                 READC     DSPSFL                                 79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           NOMORE
     CSR                 GOTO      ENDDO1
     CSR                 ENDIF
     C*
     C*  Display error if option is not valid.
     C*
     CSR   OPTION        IFNE      *BLANKS
     CSR   OPTION        ANDNE     '1'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM0108
     CSR                 ENDIF
     C*
     C*  Save option
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
     CSR                 ENDIF
     CSR                 ELSE
     CSR   OPTION        IFNE      *BLANKS
     CSR                 MOVE      #USER         WKOUSR
     CSR                 MOVE      #PROG         WKOPGM
     CSR                 MOVE      FKEY(Y)       WKOKYF
     CSR                 MOVE      UKEY(Y)       WKOKYU
     CSR                 MOVE      OPTION        WKOOPT
     CSR                 MOVE      *IN21         WKOERR
     CSR                 WRITE     WKOREC
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDDO1        TAG
     CSR                 ENDDO
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
     CSR                 ENDIF
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
     C*
     CSR   ERROR         IFNE      *ON
     CSR   1             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      *ON           *IN20
     CSR                 UPDATE    DSPSFL
     CSR                 ENDIF
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 UPDATE    DSPSFL
     CSR                 ENDIF
     CSR                 ENDDO
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
     CSR                 ENDIF
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
     CSR                 ENDIF
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
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM      $LPRG         #PGMQ
     CSR                 PARM                    #MSGK
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*
     C*    ZMnnnn  Build and send message nnnn to this program
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
     C*     PIR1001  Invalid code.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     DESC          ERRMSG
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $LMSG
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
     C*R                   READ RECORD                   79
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
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     CSR   ZZFILL        BEGSR
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  Define keys
     C*
     C*     WORKOPT  (Unique key)
     C*
     CSR   WKOUNQ        KLIST
     CSR                 KFLD                    #USER
     CSR                 KFLD                    #PROG
     CSR                 KFLD                    WKOKYF
     CSR                 KFLD                    WKOKYU
     C*
     C*     WORKOPT  (Partial key)
     C*
     CSR   WKOPRT        KLIST
     CSR                 KFLD                    #USER
     CSR                 KFLD                    #PROG
     C*
     C*     WORKOPT  (Save key for top record on delete display)
     C*
     CSR   *LIKE         DEFINE    WKOKYF        $WKOF
     CSR   *LIKE         DEFINE    WKOKYU        $WKOU
     CSR   DELTOP        KLIST
     CSR                 KFLD                    #USER
     CSR                 KFLD                    #PROG
     CSR                 KFLD                    $WKOF
     CSR                 KFLD                    $WKOU
     C*
     C*  Define key for main file.
     C*
     C*
     C*  Define full key for main file.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    $LWHSE
     CSR                 KFLD                    LRTWHD
     CSR                 KFLD                    LRTASL
     CSR                 KFLD                    LRTLOC
     CSR                 KFLD                    LRTLVL
     CSR                 KFLD                    LRTHND
     C*
     C*  Define partial key for main file (if needed).
     C*
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $LWHSE
     CSR                 KFLD                    $LWHDP
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Initialization every time program is called.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   Get warehouse description.
     C*
     CSR   $LCMD         IFNE      '*VERIFY '
     CSR   $LWHSE        CHAIN     WAREHS                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     CSR   ZZKEYF        BEGSR
     CSR                 MOVE      DSKEY         $POFKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     CSR   ZZKEYU        BEGSR
     CSR                 MOVE      DSKEY         $POUKY
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     CSR   ZZPOS         BEGSR
     C*
     C*  See if user is trying to position to a certain spot
     C*
     CSR   PTINP1        IFNE      *BLANKS
     CSR                 MOVE      PTINP1        LRTWHD
     CSR                 MOVE      *BLANKS       PTINP1
     CSR                 MOVE      *ON           REPOS
     CSR                 ENDIF
     CSR                 ENDSR
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
     C*R                   ENDIF
     C*R                   ENDIF
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     CSR   $POCMD        IFEQ      '*TOP'
     CSR   PARTKY        SETLL     RECORD
     CSR                 ELSE
     CSR   $POCMD        IFEQ      '*BOTTOM'
     CSR   PARTKY        SETGT     RECORD
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZVRFY   Verify unique key.
     C*
     CSR   ZZVRFY        BEGSR
     CSR                 MOVE      $LUKY         DSKEY
     CSR   FILEKY        CHAIN     RECORD                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      '*OK     '    $LRTN
     CSR                 ELSE
     CSR                 MOVE      '*PGMQ   '    $LRTN
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Lot/License plate
