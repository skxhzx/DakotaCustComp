     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LL830     License Log File
     F*  06 July 2009
     F*  Chuck Manny
     F*
     F*  Revisions
     F*
610 AF*    07/06/09  CWM  6.10
     F*      - Created
     F*
610aAF*    07/06/09  CWM  6.10
     F*      - Fixed *CHANGE on Password Screen forcing loop.
     F*
640aAF*    06/02/11  DAS  6.40a
     F*      - Recompiled becuase of change to LICLOG file.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (reverse display)
     F*  90        View mode (protect all fields)
     F*  91        Change mode (protect key fields)
     F*  97        Alawys on (used for SFLEND keyword)
     F*  98        Error on screen (sound alarm)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLL830FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FLICLOG    UF   E           K DISK
     FPIRITEM   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             30    DIM(4) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Data structures for comparing original and current records.
     D*
     D CURREC        E DS                  EXTNAME(SLOT)
     D ORGREC          DS
     D  DS1000              1000   1000
     D*----------------------------------------------------------------
     D*  Called program
     D*
     D @OPNSQ          C                   CONST('OPNSQTYCL ')
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
     D  $LWHDP                22     26
     D  $LITEM                27     41
     D  $LDISP                42     53
     D  $LDESG                54     58
     D  $LSTAT                59     60
     D  $LSDEF                61     62
     D  $LACTV                63     64
     D*
     D  $LDES2                19     23
     D*
     D  $LACT2                19     20
     D*
     D  $LBC2                 19     20
     D*
     D  $LSTA2                19     20
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
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
     C*      $PCMD   Command: *CHANGE, *VIEW
     C*      $PWHSE  Warehouse code.
     C*      $PLCNS  License.
     C*      $PDDUC  UC Timestamp.
     C*
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD             8
     C                   PARM                    $PWHSE            3 0
     C                   PARM                    $PLCNS           15
     C                   PARM                    $PDDUC           26
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
     C                   END
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
     C                   END
     C                   END
     C*
     C                   eval      nxtscr = 'EOJ'
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   RETURN
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   END
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     C     NXTSCR        IFEQ      '01 '
     C                   EXFMT     SCREEN1                              50
     C                   END
     C     NXTSCR        IFEQ      '02 '
     C                   EXFMT     SCREEN2                              50
     C                   eval      nxtscr = 'EOJ'
     C                   END
     C     NXTSCR        IFEQ      '03 '
     C                   EXFMT     SCREEN3                              50
     C                   END
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       010203
     C                   SETOFF                                       040506
     C                   SETOFF                                       070809
     C                   SETOFF                                       101112
     C                   SETOFF                                       131415
     C                   SETOFF                                       161718
     C                   SETOFF                                       1920
     C                   SETOFF                                       212223
     C                   SETOFF                                       242526
     C                   SETOFF                                       272829
     C                   SETOFF                                       30
     C                   SETOFF                                       98
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZDFT1
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     C     SCR02I        BEGSR
     C                   MOVE      '02 '         NXTSCR            3
     C*
     C*  Get existing record(s).
     C*
     C                   EXSR      ZZFIL2
     C     END02I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 03 initialization
     C*
     C     SCR03I        BEGSR
     C                   MOVE      '03 '         NXTSCR            3
     C*
     C*  Get existing record(s).
     C*
     C                   EXSR      ZZFIL3
     C     END03I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   EXSR      ZZUPD
     C     ERROR         CABEQ     *ON           ENDSC1
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     C     SC2           BEGSR
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR02I
     C                   GOTO      ENDSC2
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK2
     C     ERROR         CABEQ     *ON           ENDSC2
     C                   EXSR      ZZUPD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC3  -  Screen 3
     C*
     C     SC3           BEGSR
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR03I
     C                   GOTO      ENDSC3
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      '02 '         NXTSCR
     C                   GOTO      ENDSC3
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK3
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C     ENDSC3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
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
     C     ZMCMSG        BEGSR
     C                   MOVE      *OFF          *IN97
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK              4 0
     C                   WRITE     MSGCLR
     C                   MOVE      '*CLEAR '     #MSGID            7
     C                   MOVE      '*NULL  '     #MSGTP            7
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
     C     MSGK          IFGT      0
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK
     C                   END
     C                   ENDSR
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     C     ZMIMSG        BEGSR
     C                   MOVE      #PROG         #PGMQ            10
     C                   EXSR      ZMCMSG
     C                   ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     C     ZMPMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM                    #PGMQ
     C                   PARM                    #MSGK
     C     #MSGID        IFNE      '*CLEAR '
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   END
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*
     C*    ZSCLR   Clear screen
     C*
     C     ZSCLR         BEGSR
     C                   WRITE     CLRSCR
     C                   MOVE      *ON           SCLEAR            1
     C                   ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C     ZMQMSG        BEGSR
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   ENDSR
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C     ZMSMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM                    #PGMQ2           10
     C                   PARM                    #MSGK             4
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0105
     C*
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR0112  Invalid range entered.
     C*
     C     ZM0112        BEGSR
     C                   MOVE      'PIR0112'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     C     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     C     ZM72          BEGSR
     C                   MOVE      'PIR7972'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR7983  Record changed by another user.
     C*
     C     ZM83          BEGSR
     C                   MOVE      'PIR7983'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     IT12210  Can't lock item record.
     C*
     C     ZM10          BEGSR
     C                   MOVE      'IT12210'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     IT12273  Item does not exist.
     C*
     C     ZM73I         BEGSR
     C                   MOVE      'IT12273'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR9806
     C*
     C     ZM9806        BEGSR
     C                   MOVE      'PIR9806'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     C     ZZCHK1        BEGSR
     C                   MOVE      *OFF          ERROR
     C*
     C*  Verify warehouse code.
     C*
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVEL     $LERM         ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C     $LRTN         IFEQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      $LMSG         #MSGK
     C                   EXSR      ZMQMSG
     C                   ENDIF
     C                   ENDIF
     C*
     C     lcLog         chain(n)  licLog
     C                   if        not %found(licLog)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN23
     C                   MOVE      *ON           *IN01
     C                   EXSR      ZM9806
     C                   endIf
     C*
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     C     ZZCHK2        BEGSR
     C                   MOVE      *OFF          ERROR
     C     ENDCK2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK3   Screen 3 error checking.
     C*
     C     ZZCHK3        BEGSR
     C                   MOVE      *OFF          ERROR
     C     ENDCK3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C     ZZCMD1        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      '1'
     C                   MOVE      '1'           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C*
     C                   SELECT
     C*
     C*     Warehouse.
     C*
     C     ROW#          WHENEQ    8
     C                   MOVE      *ON           *IN01
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   Z-ADD     $LWHSE        W1WHSE
     C                   ENDIF
     C*
     C                   OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      '1'           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C*
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   User defined command keys for screen 2.
     C*
     C     ZZCMD2        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C     ENDCM2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD3   User defined command keys for screen 2.
     C*
     C     ZZCMD3        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C*
     C*  Test for F10 - Update
     C*
     C     *INKJ         IFEQ      '1'
     C                   MOVE      '1'           CMDTKN
     C                   EXSR      ZZUPD3
     C                   ENDIF
     C     ENDCM3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     C     ZZDFT1        BEGSR
     C                   MOVE      *OFF          *IN90
     C**   $PDISP        IFNE      *BLANKS
     C**                 MOVE      'EOJ'         NXTSCR
     C**                 END
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     C     ZZFIL2        BEGSR
     C*
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      *OFF          *IN90
     C                   ELSE
     C                   MOVE      *ON           *IN90
     C                   ENDIF
     C*
     C*   Get LICLOG Fields
     C*
     C     lcLog         chain(n)  licLog
     C                   if        %found(licLog)
     C                   eval      w2whse = w1whse
     C                   eval      w2lcns = w1lcns
     C                   eval      w2dduc = w1dduc
     C*
     C                   eval      w2ltrn = llltrn
     C                   eval      w2vrfy = llvrfy
     C*
     C                   eval      w2Disp = llDisp
     C                   eval      w2Item = llItem
     C                   eval      w2actn = llaction
     C*
     C                   eval      w2aqt1 = llaqty1
     C                   eval      w2aqt2 = llaqty2
     C                   eval      w2aqt3 = llaqty3
     C*
     C                   eval      w2rqt1 = llrqty1
     C                   eval      w2rqt2 = llrqty2
     C                   eval      w2rqt3 = llrqty3
     C*
     C                   eval      w2sqt1 = llsqty1
     C                   eval      w2sqt2 = llsqty2
     C                   eval      w2sqt3 = llsqty3
     C*
     C                   eval      w2ityp = llitype
     C                   eval      w2ichg = llichg
     C                   eval      w2sitm = llsitem
     C                   eval      w2sity = llsitype
     C                   eval      w2tocd = llcode
     C                   eval      w2aisl = llaisl
     C                   eval      w2loc  = llloc
     C                   eval      w2lvl  = llrlvl
     C                   eval      w2hand = llhand
     C                   eval      w2area = llarea
     C                   eval      w2whdp = llwhdp
     C                   eval      w2prty = llprty
     C                   eval      w2pos  = llpos
     C                   eval      w2ord  = llord
     C                   eval      w2seq  = llseq
     C                   eval      w2adts = lladdts
     C                   eval      w2entd = llentd
     C                   eval      w2expd = llexpd
     C                   eval      w2emus = lladdeusr
     C                   eval      w2crus = lladdcusr
     C                   eval      w2jusr = lladdjusr
     C                   eval      w2aemp = lladdemp
     C                   eval      w2cpgm = lladdcpgm
     C                   eval      w2jpgm = lladdjpgm
     C                   eval      w2excd = llexcd
     C                   eval      w2ajob = lladdjob
     C                   eval      w2ajnb = lladdnbr
     C                   eval      w2drsc = lldrislot
     C                   eval      w2drlc = lldrilic
     C                   eval      w2trn# = lltrn#
     C                   eval      w2etrn = lletrn#
     C                   eval      w2lbl# = lllbl#
     C                   eval      w2olcn = llolcns
     C                   eval      w2flcn = llflcns
     C                   eval      w2base = llbase
     C                   endIf
     C*
     C                   endSr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*
     C     ZZFIL3        BEGSR
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     C     zzInz         begSr
     C*
     C*  Define key for License Log File
     C*
     C     lcLog         klist
     C                   kfld                    w1Whse
     C                   kfld                    w1Lcns
     C                   kfld                    w1Dduc
     C*
     C                   MOVE      #PROG         $LPRG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     C     ZZINZ2        BEGSR
     C*
     C     $PCMD         IFNE      '*CHANGE '
     C     $PCMD         ANDNE     '*VIEW   '
     C                   EXSR      ZZPWRD
     C                   ENDIF
     C*
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      'CHANGE'      WOTYPE
     C                   ELSE
     C                   MOVE      'VIEW  '      WOTYPE
     C                   ENDIF
     C*
     C*   Select first screen to display.
     C*
     C                   SELECT
     C     $PLCNS        WHENEQ    *BLANKS
     C*
     C                   CALL      'GETWHSE'
     C                   PARM                    #USER
     C     W1WHSE        PARM      0             #WHSE             3 0
     C*
     C                   EXSR      SCR01I
     C*
     C                   OTHER
     C                   Z-ADD     $PWHSE        W1WHSE
     C                   MOVE      $PLCNS        W1LCNS
     C                   MOVE      $PDDUC        W1DDUC
     C                   EXSR      ZZCHK1
     C     ERROR         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   ELSE
     C                   EXSR      SCR02I
     C                   ENDIF
     C                   ENDSL
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPWRD   Get password
     C*
     C*    Note: Password becomes value for $CMD. Therefore, the
     C*          password to allow changes is *CHANGE.
     C*
     C     ZZPWRD        BEGSR
     C*
     C                   MOVE      *BLANKS       W1PWRD
     C*
610aDC*                  EXFMT     PASWRD
     C*
610aDC*                  if        w1pwrd = '*CHANGE '
610aDC*                  DOU       W1PWRD <> '*CHANGE '
     C*
     C                   DOU       w1Pwrd = '*CHANGE' or
     C                             w1Pwrd <> '*CHANGE'
     C                   EXFMT     PASWRD
     C                   ENDDO
610aDC*                  endIf
     C*
     C                   MOVE      W1PWRD        $PCMD
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     C     ZZUPD         BEGSR
     C                   MOVE      *OFF          ERROR
     C                   Z-ADD     W1WHSE        $PWHSE
     C                   MOVE      W1LCNS        $PLCNS
     C                   MOVE      W1DDUC        $PDDUC
     C                   EXSR      SCR02I
     C     ENDUPD        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Update record.
     C*
     C     ZZUPD2        BEGSR
     C                   MOVE      *OFF          ERROR
     C     $PCMD         IFEQ      '*CHANGE'
     C                   EXSR      SCR03I
     C                   ELSE
     C                   EXSR      SCR01I
     C                   ENDIF
     C     ENDUP2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     C     ZZUPD3        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C                   EXSR      SCR01I
     C     ENDUP3        ENDSR
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
* * Invalid Warehouse * *
* * Invalid Slot * *
* * No item in slot * *
* * LICLOG Record Not Found * *
