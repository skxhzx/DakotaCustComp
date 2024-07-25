     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT540     Outside storage Listing
     F*  Ginger Andrews
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
520 AF*  09/02/09  GJA  6.10
     F*      - Created
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (Reverse Display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (Protect key)
     F*  97        Always ON (Used for SFLEND Keyword)
     F*  98        Error on screen (Sound buzzer)
     F*  99        Universal record indicator (Very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FIT540FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FPIRITEM1  IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             60    DIM(5) CTDATA PERRCD(1)
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
     D*----------------------------------------------------------------
     D*  *FTP      -  FTP options
     D*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPFTP   -  Use FTP for exporting (Y,N)
     D*    OPSRVR  -  FTP Server name
     D*    OPUSER  -  FTP User id
     D*    OPPWD   -  FTP Password
     D*
     D* Data structure
     D*
     D OPDATA          DS
     D  OPFTP                  1      1
     D  OPSRVR                 2     33
     D  OPUSER                34     48
     D  OPPWD                 49     63
     D  OPTEND               117    117
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERPO#                  1      5P 0
     D  ERITEM                 6     20
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
     C*      None
     C*
     C*    Returned Parameters
     C*      $PWHSE   Warehouse
     C*      $PWHDP   Warehouse department or *ALL
     C*      $POSSLC  Outside storage location
     C*      $PDEV    Printer device
     C*      $PFORM   Printer form type
     C*      $PPRTN   *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PWHDP            5
     C                   PARM                    $POSSLC          12
     C                   PARM                    $PDEV            10
     C                   PARM                    $PFORM           10
     C                   PARM                    $PRTN             8
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      '1'           *IN97
     C                   MOVE      '0'           *IN90
     C                   MOVE      '0'           *IN91
     C                   MOVE      '0'           ERROR
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      '1'
     C                   MOVE      'EOJ'         NXTSCR
     C                   END
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   END
     C                   END
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   MOVE      '1'           *INLR
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      '1'
     C                   MOVE      '1'           *IN98
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
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       212223
     C                   SETOFF                                       242526
     C                   SETOFF                                       272829
     C                   SETOFF                                       30
     C                   SETOFF                                       98
     C                   MOVE      '0'           WARN              1
     C                   MOVE      '0'           ERROR             1
     C                   MOVE      '0'           CMDTKN            1
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
     C*
     C*  Get existing record.
     C*
     C                   EXSR      ZZFIL1
     C*
     C     END01I        ENDSR
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
     C     *INKC         IFEQ      '1'
     C                   MOVE      '*EXIT   '    $PRTN
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      '1'
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      '1'
     C                   MOVE      '*CANCEL '    $PRTN
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
     C     ERROR         CABEQ     '1'           ENDSC1
     C                   EXSR      ZZNXT1
     C     ENDSC1        ENDSR
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
     C                   MOVE      '0'           *IN97
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
     C                   MOVE      '1'           *IN97
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
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C     ZMQMSG        BEGSR
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   ENDSR
     C*
     C*    ZSCLR   Clear screen
     C*
     C     ZSCLR         BEGSR
     C*                    WRITECLRSCR
     C                   MOVE      *ON           SCLEAR            1
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
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
     C*      0105
     C*
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     C     ZM1001        BEGSR
     C                   MOVE      'PIR1001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    PIR1006  Invalid jobq option for view report option.
     C*
     C     ZM1006        BEGSR
     C                   MOVE      'PIR1006'     #MSGID
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
     C*  Verify warehouse department.
     C*
     C     W1WHDP        IFNE      '*ALL '
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   MOVE      W1WHDP        $LWHDP
     C                   CALL      'WD900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      '1'           *IN02
     C                   MOVEL     $LERM         ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C     $LRTN         IFEQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
     C                   MOVE      $LMSG         #MSGK
     C                   EXSR      ZMQMSG
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Verify OSS storage location.
     C*
     C     W1OSSL        IFEQ      ' '
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   MOVE      *ON           *IN04
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM1001
     C                   ENDIF
     C*
     C*  Verify default device
     C*
     C
     C                   IF        %subst(w1dev:1:1) = '*'
     C                             and W1DEV <> '*SYSVAL'
     C                             and W1DEV <> '*JOB'
     C                             or  W1DEV = ' '
     C                   eval      error = '1'
     C                   eval      *in25 = '1'
     C                   eval      *in05 = '1'
     C                   eval      errmsg = *blanks
     C                   movel     DESC(3)       ERRMSG
     C                   exsr      ZM1001
     C                   endif
     C*
     C*  Verify default form type
     C*
     C                   IF        %subst(w1form:1:1) = '*'
     C                             and W1FORM <> '*STD'
     C                             or  W1FORM = ' '
     C                   eval      error = '1'
     C                   eval      *in26 = '1'
     C                   eval      *in06 = '1'
     C                   eval      errmsg = *blanks
     C                   movel     DESC(4)       ERRMSG
     C                   exsr      ZM1001
     C                   endif
     C*
     C*  Verify jobq option
     C*
     C     W1JOBQ        IFNE      'Y'
     C     W1JOBQ        ANDNE     'N'
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN27
     C                   MOVE      *ON           *IN07
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVEL     DESC(5)       ERRMSG
     C                   EXSR      ZM1001
     C                   ENDIF
     C*
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C     ZZCMD1        BEGSR
     C                   MOVE      '0'           CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      *ON
     C                   MOVE      *ON           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C*
     C*     Warehouse department.
     C*
     C                   SELECT
     C     ROW#          WHENEQ    08
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   MOVE      #PROG         $LPRG
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   Z-ADD     $LWHSE        W1WHSE
     C                   ENDIF
     C*
     C*     Department.
     C*
     C     ROW#          WHENEQ    9
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   MOVE      W1WHDP        $LWHDP
     C                   CALL      'WD900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   MOVE      $LWHDP        W1WHDP
     C                   END
     C*
     C                   OTHER
     C*
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     C     ZZFIL1        BEGSR
     C*
     C                   CALL      'GETWHSE'
     C                   PARM                    #USER
     C     W1WHSE        PARM      0             #WHSE             3 0
     C*
     C                   MOVE      '*ALL '       W1WHDP
     C                   MOVE      *BLANKS       W1OSSL
     C*
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'IT535PR'     $lrpt            10
     C                   parm      w1whse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   MOVEL     $dev          W1DEV
     C                   MOVEL     $form         W1FORM
     C*
     C                   MOVE      'Y'           W1JOBQ
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     C     ZZINZ         BEGSR
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
     C*   Select first screen to display.
     C*
     C                   EXSR      SCR01I
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZNXT1   What to do next when screen 1 input is ok.
     C*
     C     ZZNXT1        BEGSR
     C*
     C                   MOVE      W1WHSE        $PWHSE
     C*
     C                   MOVE      W1WHDP        $PWHDP
     C                   MOVE      W1OSSL        $POSSLC
     C*
     C                   MOVE      W1DEV         $PDEV
     C                   MOVE      W1FORM        $PFORM
     C*
     C                   if        w1jobq = 'Y'
     C                   eval      $prtn = '*JOBQ   '
     C                   endif
     C*
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Days supply onhand
OSS location
Printer device
Form type
Job queue option
