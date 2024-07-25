     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DH130  Dock Door Assignment for Route - Display
     *  18 April 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    04/18/02  MLB  4.16
     *      - Created.
     *
500 A*    09/22/05  MLB  5.00
     *      - Fix: Revised SFLADD to allow door entry to be created
     *        when door assignment is Manual and load method is
     *        Single Door. Dock door department is blank and routine
     *        wasn't writing out door entry.
510 A*    11/13/07  RBD  5.10
     *      - Fix: Modified rev 500 to apply when door assignment is
     *        greater than ' ', rather than = '2'.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Revised program to add assignment type to file keys
     *        when processing DOCMTRX1. Assignment type was added to the
     *        file keys to keep automatic and manual dock door moves
     *        separated so that the next dock door for automatic
     *        assignment was not disrupted.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  41        Condition door status field RED.
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FDH130FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(DSPSFL:RECNO)
     F                                     SFILE(MSGREC:MSGK)
     Fdocmtrx1  IF   E           K DISK
     F                                     RENAME(dmrec:dmrec1)
     Fdocmtrx2  IF   E           K DISK
     FOPTIONS   IF   E           K DISK
     FRTECSUM   IF   E           K DISK
     F                                     RENAME(RCREC:RECORD)
     FRTECSUM1  IF   E           K DISK
     F                                     RENAME(RCREC:RCREC1)
     FWORKOPT   UF A E           K DISK
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D A2              S              1    DIM(2)
     D A10             S              1    DIM(10)
     D A75             S              1    DIM(75)
     D FKEY            S             50    DIM(10)
     D UKEY            S             50    DIM(10)
     D DDR             S              5    DIM(50)
     D OPTLST          S              2    DIM(24)
     D CMDLST          S              2    DIM(24)
     D ZOPT            S              2    DIM(20) CTDATA PERRCD(20)
     D OPTLN           S             75    DIM(1) CTDATA PERRCD(1)
     D CMDLN           S             79    DIM(1) CTDATA PERRCD(1)
     D DRSTS           S             15    DIM(2) CTDATA PERRCD(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $PRTKY          DS
     D  $LEN50                 1     50
     D  $KWHSE                 1      3  0
     D  $KRTE                  4      8
     D  $KRTID                 9     13
     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 1=Auto, 2=Manual.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D OPDATA          DS
     D  OPATYP                 1      1
     D  OPLTYP                 2      2
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D dsfds           DS
     D  DSFKEY                 1     50
     D  DSUKEY                 1     50
     D  dmwhse                 1      3  0 INZ(0)
     D  dmhdte                 4     11  0 inz(0)
     D  dmhtim                12     17  0 inz(0)
     D  dmpass                18     20  0 inz(0)
     D  dmdoor                21     23  0 inz(0)
     D  dmwhdp                24     28    inz(*blanks)
     D  dmrtid                29     33    inz(*blanks)
     D  dmrtec                34     38p 3 inz(0)
520 AD  dmatyp                39     39    inz('A')
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D asnerr          s              4    inz('*NO ')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @CVTDT          C                   CONST('CVTDTE')
     D @CHGPG          C                   CONST('DH122')
     D @DELPG          C                   CONST('@NONE')
     D @PRTPG          C                   CONST('@NONE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     *
     *   Redefine key
     *
     D  $LWHSE                19     21  0
     D  $LTRUK                22     31
     D  $LTRK2                32     41
     *
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
     *----------------------------------------------------------------
     *  Other data structures
     *
     D                 DS
     D  DSHMS                  1      6  0
     D  DSHH                   1      2  0
     D  DSMM                   3      4  0
     D  DSSS                   5      6  0
     D svpcmd          s              8
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
     D                 DS
     D  $EC                    1      2P 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #MSGF           C                   CONST('PIRMSGF   ')
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     *----------------------------------------------------------------
     *  Renamed fields - Route Compartment Summary - Logical
     *----------------------------------------------------------------
     IRCREC1
     I              RCWHSE                      R1WHSE
     I              RCRTID                      R1RTID
     I              RCCOMP                      R1COMP
     I              RCDRDP                      R1DRDP
     I              RCPCKC                      R1PCKC
     I              RCPCKW                      R1PCKW
     I              RCPCKP                      R1PCKP

     *----------------------------------------------------------------
     *  Renamed fields - Dock door matrix by dept/pass - Logical
     *----------------------------------------------------------------
     IDMREC1
     I              dmwhse                      d1whse
     I              dmhdte                      d1hdte
     I              dmhtim                      d1htim
     I              dmpass                      d1pass
     I              dmdoor                      d1door
     I              dmwhdp                      d1whdp
     I              dmmaxc                      d1maxc
     I              dmrtid                      d1rtid
     I              dmrtec                      d1rtec
     I              dmstat                      d1stat
     I              dmovrf                      d1ovrf
     I              dmskpr                      d1skpr
     I              dmatyp                      d1atyp
     I              dmaby                       d1aby
     I              dmadte                      d1adte
     I              dmatim                      d1atim
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change mode.
     *              *VIEW    - View mode.
     *              *VERIFY  - Verify all dock doors assigned.
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Not all door(s) assigned upon exit from
     *                         *VERIFY mode.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD2            8
     C                   PARM                    $PRTKY           50
     C                   PARM                    $RTNCD            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   MOVE      *ON           *IN97
     C                   MOVE      *BLANKS       $RTNCD
     C                   MOVE      $PCMD2        SVPCMD
     C                   EXSR      ZZINZ2
     *
     C                   select
     *    Verify complete and all dock door(s) assigned.
     C                   when      svpcmd = '*VERIFY ' and asnerr = '*NO '
     C                   eval      nxtscr = 'EOJ'
     *
     *    Not all dock door(s) assigned, diplay door summary.
     C                   when      svpcmd = '*VERIFY ' and asnerr = '*YES'
     C                   eval      errmsg = $krte
     C                   exsr      zm1054
     C                   endsl
     *
     C                   select
     *
     *    Route assigned to single dock door.
     C*****              when      opltyp = '1'
     C*****              exsr      zzsngdr
     *
     *    Route assigned by deparment/door.
     C                   other
     *
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C                   ENDCS
     C                   ENDDO
     *
     C                   select
     *    Not all dock door(s) assigned, return error to calling pgm.
     C                   when      svpcmd = '*VERIFY ' and asnerr = '*YES'
     C                   eval      $rtncd = '*ERROR  '
     C                   endsl
     *
     C                   ENDSL
     *
     *   Do some clean up before leaving.
     *
     C                   EXSR      ZSCLR
     C                   EXSR      CLRSCH
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     CSR   DSPSCR        BEGSR
     *
     *   Set ON alarm indicator if error occured
     *
     CSR                 IF        error = *ON
     CSR                 eval      *in98 = *ON
     CSR                 ENDIF
     *
     *   Set OFF command key indicators
     *
     CSR                 SETOFF                                       KCKEKF
     CSR                 SETOFF                                       KL
     *
     *   Overlay screen with title
     *
     CSR                 WRITE     TITLE
     *
     *   Overlay screen with error messages
     *
     CSR                 EXSR      ZMDMSG
     *
     *   Overlay screen with subfile screen
     *
     CSR                 SELECT
     CSR   NXTSCR        WHENEQ    '01 '
     CSR                 EXSR      SFLDSP
     CSR                 READ      POSTNREC                               50
     *
     CSR   NXTSCR        WHENEQ    '02 '
     CSR                 EXSR      DELDSP
     CSR                 ENDSL
     *
     *   Initialize error indicators and fields
     *
     CSR                 SETOFF                                       2021
     CSR                 SETOFF                                       98
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CANCEL            1
     CSR                 MOVE      *ZEROS        E                 2 0
     *
     *   Initialize error subfile
     *
     CSR                 EXSR      ZMCMSG
     *
     CSR                 READ      DSPSFC                                 50
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     CSR   SCR01I        BEGSR
     CSR                 MOVE      '01 '         NXTSCR            3
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 WRITE     CLR0306
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
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
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     CSR   SCR02E        BEGSR
     CSR                 MOVE      '01 '         NXTSCR
     CSR                 MOVE      *ON           *IN90
     CSR                 WRITE     CLR0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     CSR   CANCEL        IFEQ      *OFF
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 MOVE      FRSTKY        $POFKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*GETPREV'    $POCMD
     CSR                 EXSR      FGTWAY
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 ELSE
     *
     *   Otherwise, position to last record read.
     *
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 ENDIF
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
     CSR                 ENDIF
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     CSR   SC1           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL01
     CSR   STATUS        CASEQ     ROLLDN        ROLL01
     CSR   STATUS        CASEQ     COMAND        CMD01
     CSR                 CAS                     ENT01
     CSR                 ENDCS
     CSR   ENDSC1        ENDSR
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     CSR   SC2           BEGSR
     CSR   STATUS        CASEQ     ROLLUP        ROLL02
     CSR   STATUS        CASEQ     ROLLDN        ROLL02
     CSR   STATUS        CASEQ     COMAND        CMD02
     CSR                 CAS                     ENT02
     CSR                 ENDCS
     CSR   ENDSC2        ENDSR
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     CSR   *INZSR        BEGSR
     *
     *  Initialize special keys
     *
     CSR                 Z-ADD     0             ENTER             5 0
     CSR                 Z-ADD     2             COMAND            5 0
     CSR                 Z-ADD     01122         ROLLUP            5 0
     CSR                 Z-ADD     01123         ROLLDN            5 0
     CSR                 Z-ADD     01124         CLEAR             5 0
     CSR                 Z-ADD     01125         HELP              5 0
     *
     *  Initialize message handling
     *
     CSR                 EXSR      ZMIMSG
     *
     *  Initialize subfile (DSPSFL) record
     *
     CSR                 Z-ADD     1             RECNO
     CSR                 WRITE     DSPSFL                               79
     *
     *   Call user added initialization routine.
     *
     CSR                 EXSR      ZZINZ
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     CSR   CLRSCH        BEGSR
     CSR   WKOPRT        SETLL     WORKOPT
     CSR   WKOPRT        READE     WORKOPT                              7979
     CSR   *IN79         DOWEQ     '0'
     CSR                 DELETE    WKOREC
     CSR   WKOPRT        READE     WORKOPT                              7979
     CSR                 ENDDO
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     CSR   CMD01         BEGSR
     *
     *  TEST FOR CMD3 - EXIT
     *
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*EXIT   '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $RTNCD
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     CSR   *INKE         IFEQ      '1'
     CSR                 EXSR      CLRSCH
     CSR   1             DO        10            X
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      '  '          OPTION
     CSR                 eval      *in41 = ind41
     CSR                 UPDATE    DSPSFL
     CSR                 ENDIF
     CSR                 ENDDO
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           CMD01E
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
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
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     CSR   *INKR         IFEQ      '1'
     CSR                 MOVE      '*TOP    '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     CSR   *INKS         IFEQ      '1'
     CSR                 MOVE      '*BOTTOM '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      CMD01E
     CSR                 ENDIF
     *
     *   Process non-standard function keys.
     *
     CSR                 EXSR      ZZCMD
     CSR   CMD01E        ENDSR
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     CSR   CMD02         BEGSR
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      '1'           CANCEL
     CSR                 EXSR      SCR02E
     CSR                 GOTO      CMD02E
     CSR                 ENDIF
     CSR   CMD02E        ENDSR
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     CSR   DELADD        BEGSR
     CSR   RECNO         IFLT      11
     CSR                 ADD       1             RECNO
     CSR                 Z-ADD     RECNO         Y
     *
     *  GET RECORD INFO
     *
     CSR                 MOVE      '*GET    '    $POCMD
     CSR                 MOVE      WKOKYU        $POUKY
     CSR                 EXSR      FGTWAY
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     CSR   RECNO         IFEQ      1
     CSR                 MOVE      WKOKYF        $WKOF
     CSR                 MOVE      WKOKYU        $WKOU
     CSR                 END
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     CSR                 EXSR      ZZFILL
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 WRITE     DSPSFL
     CSR                 ENDIF
     CSR   DELADE        ENDSR
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     CSR   DELDSP        BEGSR
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     CSR                 WRITE     MORREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     CSR                 MOVE      *ON           *IN01
     CSR                 Z-ADD     1             RECNO
     CSR                 WRITE     DSPSFC
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     CSR   ENT01         BEGSR
     *
     *  VERIFY AND SAVE OPTIONS
     *
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ENT01E
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     CSR                 MOVE      *OFF          REPOS             1
     CSR                 EXSR      ZZPOS
     CSR   REPOS         IFEQ      *ON
     CSR                 MOVE      DSFKEY        $POFKY
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ENT01E
     CSR                 ENDIF
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     CSR                 EXSR      OPTNS
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     CSR   OTAKEN        IFEQ      '0'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENT01E
     CSR                 ENDIF
     CSR   ENT01E        ENDSR
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     CSR   ENT02         BEGSR
     *
     *  Save first delete key.
     *
     CSR   *LIKE         DEFINE    $PUKY         FRSTKY
     CSR                 MOVE      $PUKY         FRSTKY
     *
     *  Delete the records that have been selected
     *
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      '0'           STOP
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     *
     CSR   WKOOPT        IFEQ      ' 4'
     *
     *  Call delete program
     *
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 CALL      @DELPG
     CSR                 PARM                    $PARMS
     *
     *     Error occured - Error message sent back
     *
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     *
     *     Error occured - Error message sent to program msgq
     *
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     *
     *     Delete canceled
     *
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     *
     *     Delete was successful.
     *
     CSR   $PRTN         IFEQ      '*OK     '
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   CANCEL        IFEQ      '0'
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      '1'           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 ENDIF
     CSR                 ENDIF
     *
     CSR                 ENDIF
     CSR                 ENDDO
     CSR                 EXSR      SCR02E
     CSR   ENT02E        ENDSR
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
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
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     CSR   FGET          BEGSR
     CSR                 MOVE      $POUKY        DSUKEY
     CSR                 EXSR      ZZFGET
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOTFND '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 ENDIF
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     CSR   FGETN         BEGSR
     CSR                 EXSR      ZZFGTN
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 EXSR      ZZKEYU
     CSR                 ENDIF
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     CSR   FGETP         BEGSR
     CSR                 EXSR      ZZFGTP
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '*NOMORE '    $PORTN
     CSR                 MOVE      *BLANKS       $POUKY
     CSR                 ELSE
     CSR                 MOVE      '*FOUND  '    $PORTN
     CSR                 EXSR      ZZKEYF
     CSR                 EXSR      ZZKEYU
     CSR                 ENDIF
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     CSR   FPOS2         BEGSR
     CSR                 MOVE      $POFKY        DSFKEY
     CSR   FILEKY        SETLL     RECORD
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     CSR   FPOS2U        BEGSR
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     CSR                 EXSR      FGET
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     CSR                 EXSR      FPOS2
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     CSR   INZPAR        BEGSR
     CSR                 CLEAR                   $PARMS
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      $PRTKY        $PUKY
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     CSR   OPTNS         BEGSR
     CSR                 MOVE      '0'           OTAKEN            1
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 MOVE      '0'           STOP
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR   *IN79         DOWEQ     '0'
     CSR   WKOOPT        ANDNE     ' 4'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR                 ENDDO
     CSR   *IN79         IFEQ      '0'
     CSR   WKOOPT        ANDEQ     ' 4'
     CSR                 MOVE      '1'           OTAKEN
     CSR                 MOVE      WKOKYU        $PUKY
     CSR                 EXSR      SCR02I
     CSR                 GOTO      OPTNSE
     CSR                 ENDIF
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
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
     CSR                 ENDIF
     CSR   CANCEL        IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR   ERROR         IFEQ      '1'
     CSR                 MOVE      '1'           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 ENDIF
     CSR                 MOVE      '*POSTN2U'    $POCMD
     CSR                 MOVE      $PUKY         $POUKY
     CSR                 EXSR      FGTWAY
     CSR                 MOVE      '*REPOS  '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      '0'           REFRSH
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDDO
     CSR   REFRSH        IFEQ      '1'
     CSR                 MOVE      '*REFRESH'    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 MOVE      '0'           REFRSH            1
     CSR                 ENDIF
     CSR   OPTNSE        ENDSR
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     CSR   OPTNS2        BEGSR
     CSR                 EXSR      INZPAR
     CSR                 MOVE      WKOKYU        $PUKY
     *
     *   Change
     *
     CSR                 SELECT
     CSR   WKOOPT        WHENEQ    ' 2'
     CSR   SVPCMD        ANDEQ     '*CHANGE '
     CSR   WKOOPT        OREQ      ' 2'
     CSR   SVPCMD        ANDEQ     '*VERIFY '
     CSR                 MOVE      '*CHANGE '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     *
     *   View
     *
     CSR   WKOOPT        WHENEQ    ' 5'
     CSR                 MOVE      '*VIEW   '    $PCMD
     CSR                 CALL      @CHGPG
     CSR                 PARM                    $PARMS
     *
     *   Print
     *
     CSR   WKOOPT        WHENEQ    ' 6'
     CSR                 MOVE      '*PRINT  '    $PCMD
     CSR                 CALL      @PRTPG
     CSR                 PARM                    $PARMS
     CSR                 OTHER
     CSR                 EXSR      ZZOPT
     CSR                 ENDSL
     *
     CSR                 SELECT
     CSR   $PRTN         WHENEQ    '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     *
     CSR   $PRTN         WHENEQ    '*ERROR  '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     *
     CSR   $PRTN         WHENEQ    '*PGMQ   '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDSL
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     CSR   PAG01         BEGSR
     *
     *  NEXT PAGE
     *
     CSR   PAGCMD        IFEQ      '*NEXT   '
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     *
     *  PREVIOUS PAGE
     *
     CSR   PAGCMD        IFEQ      '*PREV   '
     CSR                 EXSR      PAG1BK
     CSR                 ELSE
     *
     *  TOP
     *
     CSR   PAGCMD        IFEQ      '*TOP    '
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 EXSR      FGTWAY
      *R         CLERR     CABEQ'1'       PAG01E
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           FORCEB
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     *
     *  BOTTOM
     *
     CSR   PAGCMD        IFEQ      '*BOTTOM '
     CSR                 MOVE      '1'           BOT
     CSR                 Z-ADD     0             DSPLYD
     CSR                 EXSR      PAG1BK
     CSR                 ELSE
     *
     *  REFRESH SCREEN
     *
     CSR   PAGCMD        IFEQ      '*REFRESH'
     CSR   FKEY(1)       IFEQ      *LOVAL
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 ELSE
     CSR                 MOVE      '*POSTN2 '    $POCMD
     CSR                 MOVE      FKEY(1)       $POFKY
     CSR                 END
     CSR                 EXSR      FGTWAY
      *R  CLERR          CABEQ'1'  PAG01E
     CSR                 MOVE      '0'           BOT
     CSR                 EXSR      PAG1FW
     CSR                 ELSE
     *
     *  REPOSITIONING
     *
     CSR   PAGCMD        IFEQ      '*REPOS  '
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           FORCEB
     CSR                 EXSR      PAG1FW
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 MOVE      *BLANKS       PAGCMD            8
     CSR   PAG01E        ENDSR
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     CSR   PAG02         BEGSR
     *
     *  NEXT PAGE
     *
     CSR   PAGCMD        IFEQ      '*NEXT   '
     CSR                 EXSR      PAG2FW
     CSR                 ELSE
     *
     *  PREVIOUS PAGE
     *
     CSR   PAGCMD        IFEQ      '*PREV   '
     CSR                 EXSR      PAG2BK
     CSR                 ELSE
     *
     *  REFRESH SCREEN
     *
     CSR   PAGCMD        IFEQ      '*REFRESH'
     CSR   DELTOP        SETLL     WORKOPT
     CSR                 MOVE      '0'           BOT
     CSR                 EXSR      PAG2FW
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 MOVE      *BLANKS       PAGCMD
     CSR   PAG02E        ENDSR
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     CSR   PAG1FW        BEGSR
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     CSR   BOT           CABEQ     '1'           ENDF
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        FKEY
     CSR                 MOVE      *LOVAL        UKEY
     CSR                 MOVE      *OFF          BOT               1
     CSR                 MOVE      *OFF          TOP               1
     CSR                 MOVE      *OFF          STOP              1
     CSR                 MOVE      *OFF          FRSTPS            1
     CSR                 MOVE      *LOVAL        SVDRDP
     CSR                 Z-ADD     0             P                 2 0
     C                   eval      DDR = *blanks
     C                   eval      asnerr = '*NO '
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     CSR   STOP          DOUEQ     '1'
     CSR                 MOVE      '*GETNEXT'    $POCMD
     CSR                 EXSR      FGTWAY
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 GOTO      ENDFAC
     CSR                 ENDIF
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     CSR                 ADD       1             P
     CSR                 EXSR      SFLADD
     *
     *    If single dock door used, force exit since one record has been
     *    read and loaded into the subfile for display.
     C                   if        opltyp = '1'
     C                   eval      forceb = *on
     C                   endif
     *
     CSR   P             IFGE      10
     C     OPLTYP        OREQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR   FORCEB        IFEQ      '1'
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 ELSE
     CSR                 MOVE      'More...'     MORELN
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDFAC        TAG
     CSR                 ENDDO
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     CSR                 Z-ADD     P             DSPLYD            2 0
     CSR                 MOVE      '0'           FORCEB
     CSR   ENDF          ENDSR
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     CSR   PAG1BK        BEGSR
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     CSR   TOP           CABEQ     '1'           ENDB
     CSR                 MOVE      '0'           FORCEB            1
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      '1'
     CSR   GOBACK        IFEQ      10
     CSR                 MOVE      '1'           FORCEB
     CSR                 ENDIF
     CSR                 MOVE      '*BOTTOM '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ADD       1             GOBACK
     CSR                 ENDIF
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     CSR                 Z-ADD     0             P
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           STOP
     CSR                 MOVE      *OFF          FRSTPS            1
     CSR                 MOVE      *LOVAL        SVDRDP
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     CSR   STOP          DOUEQ     '1'
     CSR                 MOVE      '*GETPREV'    $POCMD
     CSR                 EXSR      FGTWAY
     *
     *  HIT TOP OF FILE
     *
     CSR   $PORTN        IFEQ      '*NOMORE '
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           TOP
     CSR                 GOTO      ENDBK
     CSR                 ENDIF
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      '1'           STOP
     CSR                 ENDIF
     CSR   ENDBK         TAG
     CSR                 ENDDO
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     CSR   TOP           IFEQ      '1'
     CSR                 MOVE      '*TOP    '    $POCMD
     CSR                 EXSR      FGTWAY
     CSR                 ENDIF
     CSR                 EXSR      PAG1FW
     CSR   ENDB          ENDSR
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     CSR   PAG2FW        BEGSR
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     CSR   BOT           CABEQ     '1'           ENDF2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     CSR                 EXSR      SFLCLR
     CSR                 MOVE      *LOVAL        $WKOF
     CSR                 MOVE      *LOVAL        $WKOU
     CSR                 MOVE      '0'           BOT               1
     CSR                 MOVE      '0'           TOP               1
     CSR                 MOVE      '0'           STOP              1
     CSR                 Z-ADD     0             P                 2 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           BOT
     CSR                 MOVE      'Bottom '     MORELN
     CSR                 GOTO      ENDFW2
     CSR                 ENDIF
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
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
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDFW2        TAG
     CSR                 ENDDO
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     CSR                 Z-ADD     P             DSPLYD            2 0
     CSR                 MOVE      '0'           FORCEB
     CSR   ENDF2         ENDSR
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     CSR   PAG2BK        BEGSR
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     CSR   TOP           CABEQ     '1'           ENDB2
     CSR                 MOVE      '0'           FORCEB            1
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     CSR   DSPLYD        ADD       10            GOBACK            2 0
     CSR   BOT           IFEQ      '1'
     CSR   WKOPRT        SETGT     WORKOPT
     CSR                 ADD       1             GOBACK
     CSR                 ENDIF
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     CSR                 Z-ADD     0             P
     CSR                 MOVE      '0'           TOP
     CSR                 MOVE      '0'           BOT
     CSR                 MOVE      '0'           STOP
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READPE    WORKOPT                                79
     *
     *  HIT TOP OF FILE
     *
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      '1'           TOP
     CSR                 GOTO      ENDBK2
     CSR                 ENDIF
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     CSR   WKOOPT        IFEQ      ' 4'
     CSR                 ADD       1             P
     CSR   P             IFGE      GOBACK
     CSR                 MOVE      '1'           STOP
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDBK2        TAG
     CSR                 ENDDO
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     CSR   TOP           IFEQ      '1'
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 ENDIF
     CSR                 EXSR      PAG2FW
     CSR   ENDB2         ENDSR
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     CSR   ROLL01        BEGSR
     *
     *  TEST FOR ROLLUP
     *
     CSR   STATUS        IFEQ      ROLLUP
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ROL01E
     CSR                 MOVE      '*NEXT   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 ENDIF
     *
     *  TEST FOR ROLLDOWN
     *
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 EXSR      SAVOPT
     CSR   ERROR         CABEQ     '1'           ROL01E
     CSR                 MOVE      '*PREV   '    PAGCMD
     CSR                 EXSR      PAG01
     CSR                 GOTO      ROL01E
     CSR                 ENDIF
     CSR   ROL01E        ENDSR
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     CSR   ROLL02        BEGSR
     *
     *  TEST FOR ROLLUP
     *
     CSR   STATUS        IFEQ      ROLLUP
     CSR                 MOVE      '*NEXT   '    PAGCMD
     CSR                 EXSR      PAG02
     CSR                 GOTO      ROL02E
     CSR                 ENDIF
     *
     *  TEST FOR ROLLDOWN
     *
     CSR   STATUS        IFEQ      ROLLDN
     CSR                 MOVE      '*PREV   '    PAGCMD
     CSR                 EXSR      PAG02
     CSR                 GOTO      ROL02E
     CSR                 ENDIF
     CSR   ROL02E        ENDSR
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     CSR   SAVOPT        BEGSR
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     CSR                 MOVE      '0'           NOMORE            1
     CSR   NOMORE        DOUEQ     '1'
     CSR                 MOVE      '0'           *IN21
     CSR                 READC     DSPSFL                                 79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           NOMORE
     CSR                 GOTO      ENDDO1
     CSR                 ENDIF
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     CSR   OPTION        IFNE      *BLANKS
     CSR                 MOVEA     OPTION        A2
     CSR   A2(2)         IFEQ      ' '
     CSR                 MOVE      A2(1)         A2(2)
     CSR                 MOVE      ' '           A2(1)
     CSR                 MOVEA     A2            OPTION
     CSR                 ENDIF
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     CSR   OPTION        LOOKUP    ZOPT                                   50
     CSR   *IN50         IFEQ      *OFF
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM0108
     CSR                 ENDIF
     CSR                 ENDIF
     *
     *  SAVE OPTION
     *
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
     CSR                 ENDIF
     CSR                 ENDIF
     CSR   ENDDO1        TAG
     CSR                 ENDDO
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     CSR   SFLADD        BEGSR
     CSR   RECCNT        IFLT      11
     *
     *    Dock door loading is by Department.
     *
     CSR                 SELECT
     *
     *    Dock department same as last compartment.
     *    Clear dock door totals.
     CSR   RCDRDP        WHENEQ    SVDRDP
     CSR                 MOVE      *BLANKS       W1DRDP
     CSR                 MOVE      *ZEROS        W1PCKC
     CSR                 MOVE      *ZEROS        W1PCKW
     CSR                 MOVE      *ZEROS        W1PCKP
     CSR                 reset                   dsfds
     C                   goto      endadd
     *
     *    Dock door dept changed....
     CSR   RCDRDP        WHENNE    SVDRDP
     *
     CSR                 MOVE      '*NO '        CLRTOT
     CSR                 MOVE      '*NO '        CLCTOT
     *    See if dock door dept already processed. 50=Yes.
     CSR                 Z-ADD     1             K
     CSR   RCDRDP        LOOKUP    DDR(K)                                 50
500 A*
500 A*    When door assignment is manual and loading method
500 A*    Single Door, no dept is assigned. Treat as if dept assigned.
510 DC**                 if            opatyp = '2'
510 MC                   if            opatyp > ' '
500 AC                             and opltyp = '1'
500 AC                   eval      *in50 = *off
500 AC                   endif
500 A*
     CSR                 SELECT
     *
     *    Dock door has already been processed. Skip this compartment.
     CSR   *IN50         WHENEQ    *ON
     CSR                 goto      endadd
     *
     *      Dock door not found. Find next empty array element.
     CSR   *IN50         WHENEQ    *OFF
     CSR                 Z-ADD     1             K
     CSR   '     '       LOOKUP    DDR(K)                                 50
     CSR   *IN50         IFEQ      *ON
     CSR                 MOVE      RCDRDP        DDR(K)
     CSR                 MOVE      '*YES'        CLRTOT
     CSR                 MOVE      '*YES'        CLCTOT
     CSR                 ELSE
     CSR                 goto      endadd
     CSR                 ENDIF
     CSR                 ENDSL
     *
     *    Clear dock door totals before starting.
     CSR   CLRTOT        IFEQ      '*YES'
     CSR                 MOVE      *BLANKS       W1DRDP
     CSR                 MOVE      *ZEROS        W1PCKC
     CSR                 MOVE      *ZEROS        W1PCKW
     CSR                 MOVE      *ZEROS        W1PCKP
     CSR                 reset                   dsfds
     CSR                 ENDIF
     *
     *    Dock door loading is by Department.
     *
     *    Accumulate totals for door summary based on dock
     *    door dept where product will be loaded onto truck.
     *
     *    Only do this once for each dock door department.
     CSR   CLCTOT        IFEQ      '*YES'
     CSR                 MOVE      RCDRDP        KYDRDP
     C                   if        opltyp = '1'
     C     keyrc2        setll     rtecsum1
     C                   else
     CSR   KEYRC1        SETLL     RTECSUM1
     C                   endif
     CSR   FOREVR        DOWEQ     FOREVR
     C                   if        opltyp = '1'
     C     keyrc2        reade     rtecsum1                               76
     C                   else
     CSR   KEYRC1        READE     RTECSUM1                               76
     C                   endif
     CSR                 SELECT
     CSR   *IN76         WHENEQ    *ON
     CSR                 LEAVE
     CSR                 OTHER
     CSR                 ADD       R1PCKC        W1PCKC
     CSR                 ADD       R1PCKW        W1PCKW
     CSR                 ADD       R1PCKP        W1PCKP
     CSR                 ENDSL
     CSR                 ENDDO
     CSR                 ENDIF
     *
     CSR                 MOVE      R1DRDP        W1DRDP
     *    Fill hold field(s).
     CSR                 MOVE      RCDRDP        SVDRDP
     CSR                 ENDSL
     *
     *    Route assigned to department/door. Retrieve route from matrix.
     *
     C                   select
     C                   when      opltyp = '1'
     C     kydm2a        setll     docmtrx2
     C     kydm2a        reade     docmtrx2
     *
     C                   when      opltyp = '2'
     C     kydm2         setll     docmtrx2
     C     kydm2         reade     docmtrx2
     *
     C                   endsl
     *
     C                   select
     C                   when      %eof(docmtrx2)
     C                   eval      w1door = *zeros
     *
     C                   other
     *
     C                   eval      w1door = dmdoor
     *
     C                   endsl
     *
     *    If door not assigned, show status in RED.
     C                   if        w1door <= *zeros
     C                   eval      asnerr = '*YES'
     C                   eval      *in41 = *on
     C                   eval      ind41 = *on
     C                   eval      w1stat= drsts(2)
     *
     *    Initialize save DS fields if no matrix record found.
     C                   eval      dmwhse = $kwhse
     C                   eval      dmrtid = $krtid
     C                   eval      dmwhdp = w1drdp
     C                   eval      dmrtec = w1pckc
     *
     *    Door assigned.  Show status in default color (GRN).
     C                   else
     *
     C                   eval      *in41 = *off
     C                   eval      ind41 = *off
     C                   eval      w1stat= drsts(1)
     C                   endif
     *
     *    Check if route has overflow at dock door.
     *
     C                   exsr      zzoflw
     *
     *    Write display line to subfile.
     *
     C                   ADD       1             RECCNT
     C                   Z-ADD     RECCNT        RECNO
     C                   Z-ADD     RECCNT        Y
     *
     *    Save file and unique keys.
     *
     CSR                 MOVE      dsfkey        FKEY(Y)
     CSR                 MOVE      dsfkey        UKEY(Y)
     CSR                 EXSR      ZZFILL
     CSR                 WRITE     DSPSFL
     CSR                 ENDIF
     CSR   endadd        ENDSR
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     CSR   SFLCLR        BEGSR
     *
     *  CLEAR DISPLAY SUBFILE
     *
     CSR                 MOVE      *OFF          *IN81
     CSR                 MOVE      *OFF          *IN82
     CSR                 MOVE      *ON           *IN83
     CSR                 MOVE      *ON           *IN84
     *
     CSR                 WRITE     DSPSFC
     CSR                 Z-ADD     0             RECCNT            4 0
     CSR                 Z-ADD     1             POSREC            4 0
     CSR                 Z-ADD     0             RECNO             4 0
     *
     CSR                 MOVE      *ON           *IN82
     CSR                 MOVE      *OFF          *IN83
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     CSR   SFLDSP        BEGSR
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     CSR                 WRITE     OPTREC
     CSR                 WRITE     CMDREC
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     CSR                 WRITE     MORREC
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     CSR                 WRITE     POSTNREC
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     CSR                 EXSR      SFLOPT
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     CSR   ERROR         IFNE      '1'
     CSR   1             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      '1'           *IN20
     CSR                 eval      *in41 = ind41
     CSR                 UPDATE    DSPSFL
     CSR                 ENDIF
     CSR                 ENDIF
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     CSR                 MOVE      *ON           *IN81
     CSR                 Z-ADD     POSREC        RECNO
     CSR                 WRITE     DSPSFC
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     CSR   SFLOPT        BEGSR
     CSR   1             DO        10            X                 3 0
     CSR   X             CHAIN     DSPSFL                             79
     CSR   *IN79         IFEQ      '0'
     CSR                 MOVE      FKEY(X)       WKOKYF
     CSR                 MOVE      UKEY(X)       WKOKYU
     CSR                 eval      *in41 = ind41
     CSR   WKOUNQ        CHAIN     WORKOPT                            78
     CSR   *IN78         IFEQ      '0'
     CSR                 MOVE      WKOOPT        OPTION
     CSR                 MOVE      WKOERR        *IN21
     CSR                 MOVE      WKOERR        *IN20
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       OPTION
     CSR                 MOVE      '0'           *IN21
     CSR                 MOVE      '0'           *IN20
     CSR                 ENDIF
     CSR                 UPDATE    DSPSFL
     CSR                 ENDIF
     CSR                 ENDDO
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      '0'           *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *
     *    ZMDMSG  Display message record subfile
     *
     CSR   ZMDMSG        BEGSR
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '1'           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 ENDIF
     CSR                 ENDSR
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     *
     *    ZMPMSG  Add message record to subfile
     *
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
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     *
     *    ZSCLR   Clear screen
     *
     CSR   ZSCLR         BEGSR
      *R                 WRITECLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 ENDIF
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
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     CSR   ZM0101        BEGSR
     CSR                 MOVE      'PIR0101'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
      *R                 MOVE CLPRGM    ERRCL1
      *R                 MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     CSR   ZM0102        BEGSR
     CSR                 MOVE      'PIR0102'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
      *R                 MOVE CLPRGM    ERRCL1
      *R                 MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     CSR   ZM0103        BEGSR
     CSR                 MOVE      'PIR0103'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
      *R                   MOVE CLPRGM    ERRCL1
      *R                   MOVE CLINFO    ERRCL2
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     CSR   ZM0104        BEGSR
     CSR                 MOVE      'PIR0104'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0105
     *
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     CSR   ZM0106        BEGSR
     CSR                 MOVE      'PIR0106'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     CSR   ZM0107        BEGSR
     CSR                 MOVE      'PIR0107'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     CSR   ZM0108        BEGSR
     CSR                 MOVE      'PIR0108'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEL     OPTION        ERRMSG
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
416cA*----------------------------------------------------------------
416cA*      1053  Not all dock door(s) assigned to route.
416cA*
416cACSR   ZM1054        BEGSR
416cACSR                 MOVE      'PIR1054'     #MSGID
416cACSR                 MOVE      '*DIAG  '     #MSGTP
416cACSR                 MOVEA     ERRMSG        $MD(1)
416cACSR                 EXSR      ZMPMSG
416cACSR                 ENDSR
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     CSR   ZZCMD         BEGSR
     CSR   ENDCM1        ENDSR
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     CSR   ZZFGET        BEGSR
     *
     *    Code to use when file key and unique key are the same.
     *
     CSR   FILEKY        CHAIN     RECORD                             79
     *
     *    Code to use when file key and unique key are different.
     *
      *R         FILUKY    CHAINRECORDU              79
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     CSR   ZZFGTN        BEGSR
     CSR   TRY1          TAG
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     CSR   PARTKY        READE     RECORD                                 79
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     CSR   ZZFGTP        BEGSR
     CSR   TRY2          TAG
     *
     *    Code to use when we are not using a partial key.
     *
      *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     CSR   PARTKY        READPE    RECORD                                 79
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     CSR   ZZFILL        BEGSR
     *
     *    When loading through a single door, make sure door
     *    dept field is clear.
     *
     CSR   OPLTYP        IFEQ      '1'
     CSR                 MOVE      *BLANKS       W1DRDP
     CSR                 ENDIF
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      *ON           FOREVR            1
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     WKOUNQ        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C                   KFLD                    WKOKYF
     C                   KFLD                    WKOKYU
     *
     *     WORKOPT  (Partial key)
     *
     C     WKOPRT        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     *LIKE         DEFINE    WKOKYF        $WKOF
     C     *LIKE         DEFINE    WKOKYU        $WKOU
     C     DELTOP        KLIST
     C                   KFLD                    #USER
     C                   KFLD                    #PROG
     C                   KFLD                    $WKOF
     C                   KFLD                    $WKOU
     *
     *  Define full key for main file.
     *
     CSR   FILEKY        KLIST
     CSR                 KFLD                    RCWHSE
     CSR                 KFLD                    RCRTID
     *
     *  Define UNIQ key for main file.
     *
     CSR   FILUKY        KLIST
     CSR                 KFLD                    RCWHSE
     CSR                 KFLD                    RCRTID
     CSR                 KFLD                    RCCOMP
     *
     *  Define partial key for main file (if needed).
     *
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    $KRTID
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     keydm         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
     *  Define key for DOCMTRX2 - Partial  (used when opltyp = '2')
     *
     C     kydm2         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     C                   kfld                    rcdrdp
     *
     *  Define key for DOCMTRX2 - Partial  (used when opltyp = '1')
     *
     C     kydm2a        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
     *  Define key for DOCMTRX1 - Full key.
     *
     C     kydm1         klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmwhdp
     C                   kfld                    dmpass
     C                   kfld                    dmdoor
     *
     *  Define key for DOCMTRX1 - Partial key.
     *
     C     kydm1a        klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmwhdp
     C                   kfld                    dmpass
     *
     *  Define Full key for OPTIONS file.
     *
     CSR   KEYOP         KLIST
     CSR                 KFLD                    OPWHSE
     CSR                 KFLD                    OPCODE
     *
     *  Define Full key for RTECSUM1.
     *
     CSR   *LIKE         DEFINE    RCDRDP        KYDRDP
     CSR   KEYRC1        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    $KRTID
     CSR                 KFLD                    KYDRDP
     *
     *  Define Partial key for RTECSUM1.
     *
     CSR   KEYRC2        KLIST
     CSR                 KFLD                    $KWHSE
     CSR                 KFLD                    $KRTID
     *
     *  Setup option and command display lines.
     *
     CSR                 MOVE      OPTLN(1)      OPTLN1
     CSR                 MOVE      CMDLN(1)      CMDLN1
     *
     *    Define work fields.
     *
     CSR   *LIKE         DEFINE    RCDRDP        SVDRDP
     CSR                 MOVE      '*NO '        CLRTOT            4
     CSR                 MOVE      '*NO '        CLCTOT            4
     CSR                 MOVE      *ZEROS        K                 3 0
     *
     *    Initialize messaging fields.
     *
     CSR                 MOVE      #PROG         $PPRG
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      #PROG         $CVPRG
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     CSR   ZZINZ2        BEGSR
     CSR                 MOVE      $PRTKY        DSFKEY
     *
     *   Verify warehouse and get description.
     *
     CSR                 Z-ADD     $KWHSE        WHCODE
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     $kwhse        rcwhse
     CSR                 Z-ADD     $kwhse        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           *IN21
     CSR                 MOVE      '1'           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     CSR                 Z-ADD     RCWHSE        $KWHSE
     CSR                 Z-ADD     RCWHSE        WHCODE
     CSR                 MOVEL     $LERM         WHDESC
     CSR                 ENDIF
     *
     *    Retrieve Dock Door Options record.
     *
     CSR                 Z-ADD     $KWHSE        OPWHSE
     CSR                 MOVE      '*DOCDOOR'    OPCODE
     CSR   KEYOP         CHAIN     OPTIONS                            79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      '1'           OPATYP
     CSR                 MOVE      '1'           OPLTYP
     CSR                 ENDIF
     *
     CSR                 EXSR      CLRSCH
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     CSR   ZZKEYF        BEGSR
     CSR                 MOVE      DSFKEY        $POFKY
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     CSR   ZZKEYU        BEGSR
     CSR                 MOVE      DSUKEY        $POUKY
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZOFLW   Check for overflow for dock door.
     *
     CSR   ZZOFLW        BEGSR
     *
     C     kydm1         setgt     docmtrx1
     C     kydm1a        reade     docmtrx1
     C                   select
     *    No overflow found.
     C                   when      %eof
     C                   eval      w1ovrf = 'N'
     C                   eval      w1ofdr = *zeros
     *
     *   Overflow found. Load display fields.
     C                   when      d1ovrf = 'Y' and d1rtid = dmrtid and
     C                             d1whdp = dmwhdp and dmstat = '2'
     C                   eval      w1ovrf = d1ovrf
     C                   eval      w1ofdr = d1door
     *
     *   No overflow found.
     C                   other
     C                   eval      w1ovrf = 'N'
     C                   eval      w1ofdr = *zeros
     *
     C                   endsl
     *
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     CSR   ZZOPT         BEGSR
     CSR                 ENDSR
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     CSR   ZZPOS         BEGSR
     *
     *
     CSR   ENDZPS        ENDSR
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     CSR   ZZPOS2        BEGSR
     *
     *    Code to use when we are not using a partial key.
     *
      *R         $POCMD    IFEQ '*TOP'
      *R         *LOVAL    SETLLRECORD
      *R                   ELSE
      *R         $POCMD    IFEQ '*BOTTOM'
      *R         *HIVAL    SETLLRECORD
      *R                   END
      *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     CSR   $POCMD        IFEQ      '*TOP'
     CSR   PARTKY        SETLL     RECORD
     CSR                 ELSE
     CSR   $POCMD        IFEQ      '*BOTTOM'
     CSR   PARTKY        SETGT     RECORD
     CSR                 END
     CSR                 END
     CSR                 ENDSR

     *----------------------------------------------------------------
     *
     *  ZZSNGDR   Find single dock door assigned to route. Then display
     *            maintenace program.
     *
     C     ZZSNGDR       BEGSR
     *
     *
     C     keydm         setll     docmtrx2
     C     keydm         reade     docmtrx2
     C                   select
     C                   when      %eof(docmtrx2)
     C                   eval      dmhdte = *zeros
     C                   eval      dmhtim = *zeros
     C                   eval      dmpass = *zeros
     C                   eval      dmdoor = *zeros
     C                   eval      dmwhdp = *blanks
     *
     C                   other
     *
     C                   endsl
     *
     *   Change
     *
     C                   MOVE      '*CHANGE '    $PCMD
     C                   MOVE      DSFKEY        $PUKY
     C                   CALL      @CHGPG
     C                   PARM                    $PARMS
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 5
**  OPTLN - Option display line
2=Change  5=Display
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F12=Cancel
**  DRSTS - Dock door status
Assigned
Not assigned
