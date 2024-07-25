     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT530     Recommended Transfer from Outside Storage
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
520 AF*  05/26/09  MLB  5.20
     F*      - Created
530aAF*  12/18/09  RH   5.30a
     F*      - Default JOBQ to 'N'
640aAF*  03/15/12  RH   6.40a
     F*      - Enh: Add client code.
640bAF*  05/10/12  RTR  6.40b
     F*      - Enh: Add sort option.
640cAF*  05/14/12  RTR  6.40c
     F*      - Enh: Add selection option.
     F*
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter Country Bakers
     *
ICBaA*   03/15/12  RH   ICBa
     *     - Changed to allow blank aisle, OSS whse has 'H, I, N, P,
     *       R and T aisles
ICBbA*   03/27/12  RH   ICBb
     *     - Enh: allow *ORD for aisle, will use ITEMORD file in place
     *       of ITEMSLS (average sales)
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*   09/24/13  LMC  GLPa
     *     - Days supply cannot be more than 7 days.
GLPbA*   10/04/13  RH   GLPb
     *     - Change default values/days/sort/OSS whse
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods Company
     *
FFCaA*   11/25/14  LMC  FFCa
     *     - Do not require enter of OSS location. It534 has client
     *       code for aisle 20.
FFCbA*   12/01/14  RH   FFCb
     *     - Default whse to DRY, not *ALL
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*   04/29/19  DAS  DRYa
     *     - Do not require enter of oss location for whse 55.
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
640bDF*IT530FM   CF   E             WORKSTN
640bAFIT53001   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
640cDD*DESC            S             60    DIM(5) CTDATA PERRCD(1)
640cMD DESC            S             60    DIM(7) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Customer id
ICBaA /copy qcopysrc,id#icb
GLPaA /copy qcopysrc,id#glp
FFCaAD/copy qcopysrc,id#fischer
DRYaA /copy qcopysrc,id#dairyla
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
     C*      $WHSE   Warehouse
     C*      $WHDP   Warehouse Department
     C*      $PDAYSP Days Supply
     C*      $POSSLC OSS Slot
     C*      $PDEV   Printer Device
     C*      $PFORM  Form type
     C*      $PRTN   Return Code
640bAC*      $PSORT  Sort order - Item or OSS Slot
640cAC*      $PSEL   Selection - Order or Sales Averages
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PDAYSP           3
     C                   PARM                    $POSSLC          12
     C                   PARM                    $PDEV            10
     C                   PARM                    $PFORM           10
     C                   PARM                    $PRTN             8
640bAC                   PARM                    $PSORT            5
640cAC                   PARM                    $PSEL             4
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
     CSR                 EXFMT     SCREEN1                              50
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       30
     CSR                 SETOFF                                       98
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CMDTKN            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
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
     C*
     C*  Get existing record.
     C*
     CSR                 EXSR      ZZFIL1
     C*
     CSR   END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     CSR   SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      '1'
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys
     C*
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     '1'           ENDSC1
     CSR                 EXSR      ZZNXT1
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
640a C*
640a C* Get client id.
640a C*
640a C                   CALL      'GETCLIENT'
640a C                   PARM                    CLIENT           10
640a C                   PARM                    CLIENTLOC        10
     C*
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
     CSR                 PARM                    #PGMQ
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
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
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
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1006  Invalid jobq option for view report option.
     C*
     CSR   ZM1006        BEGSR
     CSR                 MOVE      'PIR1006'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*  Verify warehouse code.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
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
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Verify warehouse department.
     C*
     CSR   W1WHDP        IFNE      '*ALL '
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      '1'           *IN02
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Verify Days Supply value.
     C*
     CSR   W1DYSP        IFLE      0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
GLPaAc                   if        client = greenleaf
GLPaAC     W1DYSP        IFGT      7
GLPaAC                   MOVE      *on           ERROR
GLPaAC                   MOVE      *ON           *IN23
GLPaAC                   MOVE      *ON           *IN03
GLPaAC                   MOVE      *BLANKS       ERRMSG
GLPaAC                   MOVEL     DESC(1)       ERRMSG
GLPaAC                   EXSR      ZM1001
GLPaAC                   ENDIF
GLPaAC                   endif
     C*
     C*  Verify OSS storage location.
     C*
     CSR   W1OSSL        IFEQ      ' '
ICBaACSR   CLIENT        ANDNE     ICB
FCCaACSR   CLIENT        ANDNE     fischerfoods
DRYaACSR   CLIENT        ANDNE     dairyland
DRYaACSR   W1OSSL        OREQ      ' '
DRYaACSR   CLIENT        ANDEQ     dairyland
DRYaACSR   W1WHSE        ANDNE     55
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN24
     CSR                 MOVE      *ON           *IN04
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
640bAC*
640bAC*  Verify Days Supply value.
640bAC*
640bACSR   W1SORT        IFNE      '*ITEM'
640bACSR   W1SORT        ANDNE     '*SLOT'
640bACSR                 MOVE      *ON           ERROR
640bACSR                 MOVE      *ON           *IN28
640bACSR                 MOVE      *ON           *IN08
640bACSR                 MOVE      *BLANKS       ERRMSG
640bACSR                 MOVEL     DESC(6)       ERRMSG
640bACSR                 EXSR      ZM1001
640bACSR                 ENDIF
640cAC*
640cAC*  Verify Selection value.
640cAC*
640cACSR   W1SEL         IFNE      '*ORD'
640cACSR   W1SEL         ANDNE     '*SLS'
640cACSR                 MOVE      *ON           ERROR
640cACSR                 MOVE      *ON           *IN29
640cACSR                 MOVE      *ON           *IN09
640cACSR                 MOVE      *BLANKS       ERRMSG
640cACSR                 MOVEL     DESC(7)       ERRMSG
640cACSR                 EXSR      ZM1001
640cACSR                 ENDIF
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
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(5)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     CSR                 MOVE      '0'           CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     C*
     C*     Warehouse department.
     C*
     CSR                 SELECT
     CSR   ROW#          WHENEQ    08
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 MOVE      #PROG         $LPRG
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 Z-ADD     $LWHSE        W1WHSE
     CSR                 ENDIF
     C*
     C*     Department.
     C*
     CSR   ROW#          WHENEQ    9
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 MOVE      W1WHDP        $LWHDP
     CSR                 CALL      'WD900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVE      $LWHDP        W1WHDP
     CSR                 END
     C*
     CSR                 OTHER
     C*
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR   W1WHSE        PARM      0             #WHSE             3 0
     C*
FCCbACSR                 select
FCCbACSR                 when      client = fischerfoods
FFCbACSR                 MOVE      'DRY  '       W1WHDP
FCCbACSR                 other
     CSR                 MOVE      '*ALL '       W1WHDP
FCCbACSR                 endsl
GLPbAC                   select
GLPbAc                   when      client = greenleaf
GLPbACSR                 MOVE      002           W1DYSP
GLPbACSR                 MOVEL     'JERROLD'     W1OSSL
GLPbAc                   other
     CSR                 MOVE      005           W1DYSP
     CSR                 MOVE      *BLANKS       W1OSSL
GLPbAc                   endsl
     C*
640bAC*  Default value for Sort
640bAC                   select
640bAc                   when      client = icb
640bAC                   eval      W1SORT = '*SLOT'
GLPbAc                   when      client = greenleaf
GLPbAC                   eval      W1SORT = '*SLOT'
640bAc                   other
640bAC                   eval      W1SORT = '*ITEM'
640bAC                   endsl
     C*
640cAC*  Default value for Selection
640cAC                   select
640cAc                   when      client = icb
640cAC                   eval      W1SEL = '*ORD'
640cAc                   other
640cAC                   eval      W1SEL = '*SLS'
640cAC                   endsl
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
530aDC*R                 MOVE      'Y'           W1JOBQ
530aMCSR                 MOVE      'N'           W1JOBQ
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     CSR                 MOVE      #PROG         $LPRG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   Select first screen to display.
     C*
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZNXT1   What to do next when screen 1 input is ok.
     C*
     CSR   ZZNXT1        BEGSR
     C*
     CSR                 MOVE      W1WHSE        $PWHSE
     C*
     CSR                 MOVE      W1WHDP        $PWHDP
     CSR                 MOVE      W1DYSP        $PDAYSP
     CSR                 MOVE      W1OSSL        $POSSLC
640bACSR                 MOVE      W1SORT        $PSORT
640cACSR                 MOVE      W1SEL         $PSEL
     C*
     CSR                 MOVE      W1DEV         $PDEV
     CSR                 MOVE      W1FORM        $PFORM
     C*
     C                   if        w1jobq = 'Y'
     C                   eval      $prtn = '*JOBQ   '
     C                   endif
     C*
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 ENDSR
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
Sort by option
Selection option
