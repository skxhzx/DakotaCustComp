     H option(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  RU122     Work with Flag Entries - Change
     F*  26 May 2004
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    05/26/04  MLB  4.17
     F*      - Created.
     F*
500aAF*    07/10/05  MLB  5.00a
     F*      - Enh: Revised program to receive flag type code and use
     F*        flag type code as part of key.
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/26  02/02
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
750aA*    08/19/21  RBD  7.50a
     *      - Added new runner status 'L', closed but not loaded.
     *
750bA*    09/29/21  RH   7.50b
     *      - Enh: Add Item Qty fields, change to use RU12201
750cA*    11/08/21  RH   7.50c
     *      - Enh: Add if item can sub, change to use RU12202
750dA*    11/08/21  RH   7.50d
     *      - Enh: Add Client code
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
JDOa *    11/08/21  RH   JDOa
     *      - Get ORDH misc to see if cust allows subs.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
750bDF*RU122FM   CF   E             WORKSTN
750cDF*RU12201   CF   E             WORKSTN
750cMFRU12202   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FLabel     if   e           k disk
     Fordh      if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   if   e           k disk
     Fpiruser1  if   e           k disk
     Frtehed    if   e           k disk
     FRUNNER    UF A E           K DISK
     F                                     RENAME(RUREC:RECORD)
     Fwarehs    if   e           k disk
750bAFitemqty   if   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             78    DIM(3) CTDATA PERRCD(1)
750dA*----------------------------------------------------------------
750dA*  Customer id
750dA*
JDOaA /copy qcopysrc,id#jordano
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
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
     D  $PLBL#                27     33  0
500aAD  $Ptype                34     34
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     *
     *----------------------------------------------------------------
     * Status message(s)
     *
     D sts01           c                   const('Open')
     D sts02           c                   const('Printed')
     D sts03           c                   const('Closed')
500aAD sts04           c                   const('Replenished')
750aAD sts05           c                   const('Not loaded')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVDOP                 1      8
     D  $CVDD6                 9     14  0
     D  $CVDD8                15     22  0
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
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  Errfld1                1     30
     D  Errfld2               31     40
     D  Errfld3               41     50
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
     *
     *----------------------------------------------------------------
     * Working variable(s)
     *
     D svcmd           s                   like($pcmd)
     D svstat          s                   like(rustat)
     D svqyso          s                   like(ruqyso)
     *
JDOa *----------------------------------------------------------------
JDOa *  Re-definition of OHMISC field.
JDOa *
JDOaAD                 ds
JDOaAD  ohdoor                13     14
JDOaAD  ohsub                 20     20
JDOaAD  ohmisc                 1     20
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
     C*      $PCMD   *ADD     - * Not Supported *
     C*              *CHANGE  - Change runner flag entry qty.
     C*              *VIEW    - View runner flag entry.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything.
     C*
     C*    Returned Parameters
     C*      $PUKY   Contains key for everything.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PARMS
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      '1'           *IN97
     C                   MOVE      '0'           *IN90
     C                   MOVE      '0'           *IN91
     C                   MOVE      '0'           ERROR
     C                   MOVE      *BLANKS       $PRTN
     C                   MOVE      *BLANKS       $PERM
     C*
     C                   EXSR      ZZINZ2
     C*
     C     ERROR         IFEQ      '1'
     C                   MOVE      'EOJ'         NXTSCR
     C                   END
     C*
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
     C                   SELECT
     CSR   NXTSCR        WHENEQ    '01 '
     C                   EXFMT     SCREEN1                              50
     CSR                 ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       040506
     CSR                 SETOFF                                       070809
     CSR                 SETOFF                                       101112
     CSR                 SETOFF                                       131415
     CSR                 SETOFF                                       161718
     CSR                 SETOFF                                       1920
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
     CSR                 SETOFF                                       333435
     CSR                 SETOFF                                       363738
     CSR                 SETOFF                                       3940
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
     CSR   $PCMD         IFEQ      '*VIEW   '
     CSR                 MOVE      '1'           *IN90
     CSR                 ENDIF
     C*
     C*  Get field defaults if this is an add.
     C*
     CSR   $PCMD         IFEQ      '*ADD    '
     CSR                 EXSR      ZZDFT1
     CSR                 ELSE
     C*
     C*  Otherwise get existing record(s).
     C*
     CSR                 MOVE      *ON           *IN91
     CSR                 EXSR      ZZGET1
     CSR                 EXSR      ZZFIL1
     CSR                 END
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
     CSR   *LOVAL        SETLL     RECORD
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      '1'
     CSR   $PCMD         IFNE      '*VIEW   '
     CSR                 EXSR      SCR01I
     CSR                 END
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR   *LOVAL        SETLL     RECORD
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR   $PCMD         IFEQ      '*ADD    '
     CSR   $PCMD         OREQ      '*CHANGE '
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     '1'           ENDSC1
     CSR                 EXSR      ZZUPD
     CSR   ERROR         CABEQ     '1'           ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Everything went fine so get out of program.
     C*
     CSR                 MOVE      'EOJ'         NXTSCR
     C*
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
750dAC                   call      'GETCLIENT'
750dAC                   parm      *blanks       Client           10
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
     C*
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
     CSR                 WRITE     CLRSCR
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
     CSR                 PARM      $PPRG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     CSR   ZM01          BEGSR
     CSR                 MOVE      'PIR0201'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     DESC          ERRMSG
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
     C*      0110 - Qty must be greater than zero.
     C*
     CSR   ZM0110        BEGSR
     CSR                 MOVE      'PIR0110'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0112 - Valid range for x must be y to z.
     C*
     CSR   ZM0112        BEGSR
     CSR                 MOVE      'PIR0112'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR1001  Invalid value entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7871  Error in writing a record.
     C*
     CSR   ZM7871        BEGSR
     CSR                 MOVE      'PIR7871'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7872  Error in updating a record.
     C*
     CSR   ZM7872        BEGSR
     CSR                 MOVE      'PIR7872'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7974  Record is locked.
     C*
     CSR   ZM7974        BEGSR
     CSR                 move      'PIR7974'     #MSGID
     CSR                 move      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 exsr      ZMSMSG
     CSR                 move      #MSGK         $PMSG
     CSR                 endsr
     C*----------------------------------------------------------------
     C*   PIR7983  *WARNING* Record chg'd by another user before update.
     C*
     CSR   ZM7983        BEGSR
     CSR                 MOVE      'PIR7983'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
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
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      '0'           ERROR
     C*
     C*  When adding ....
     C*
     CSR   $PCMD         IFEQ      '*ADD    '
     C*
     C*    Make sure code was entered.
     C*
     C*R         W1CODE    IFEQ *BLANKS
     C*R                   MOVE '1'       ERROR
     C*R                   MOVE '1'       *IN21
     C*R                   EXSR ZM01
     C*R                   END
     C*
     C*    Make sure code doesn't already exist.
     C*
     C*R                   MOVE W1CODE    $PCODE
     C*R         FILEKY    CHAINRECORD               79
     C*R         *IN79     IFEQ '0'
     C*R                   MOVE '1'       ERROR
     C*R                   MOVE '1'       *IN21
     C*R                   EXSR ZM02
     C*R                   END
     CSR                 END
     *
     *    Qty short/out must be greater than zero.
     C                   If        w1qyso <= 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     *    Qty short/out can't be greater than original pick qty.
     C                   If        w1qyso >  lbqpck
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(1)       errmsg
     C                   eval      errfld2 = '1'
     C                   eval      errfld3 = %trim(%editc(lbqpck:'4'))
     C                   exsr      zm0112
     C                   Endif
     *
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     CSR                 END
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 END
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     CSR   ZZDFT1        BEGSR
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM      '*ORDSTP '    $SCMD             8
520 MC                   PARM      $PWHSE        $SWHSE            3 0
520 MC                   PARM      lbrte         $SRTEID           5
520 MC                   PARM      LBORD         $sord             7 0
520 MC                   PARM                    $sDSTP            2 0
520 MC                   PARM                    $sSTP             5 0
710aAC                   PARM                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     C                   eval      w1trn# = rutrn#
     C*
     C                   select
     C                   when      rustat = 'O'
     C                   eval      w1stat = sts01
     *
     C                   when      rustat = 'P'
     C                   eval      w1stat = sts02
     *
     C                   when      rustat = 'C'
     C                   eval      w1stat = sts03
500aA*
500aAC                   when      rustat = 'R'
500aAC                   eval      w1stat = sts04
     *
750aAC                   when      rustat = 'L'
750aAC                   eval      w1stat = sts05
     *
     C                   other
     C                   eval      w1stat = *blanks
     *
     C                   endsl
     *
     C                   if        ptemp# > 0
     C                   eval      w1emp = %trim(%editc(ptemp#:'4')) +
     C                             ' - ' + %trim(usfnam) +
     C                             ' ' + %trim(uslnam)
     C                   else
     C                   eval      w1emp = ' '
     C                   endif
     C                   eval      w1otrn = ruotrn
     C                   eval      w1rte  = rhrte
     C                   eval      w1stop = lbstop
520 A*
520 AC                   if        $sstp > 0
520 AC                   eval      dspstp = $sstp
520 AC                   else
520 AC                   eval      dspstp = lbstop
520 AC                   endif
520 A*
750cAC                   eval      w1sub = *blanks
JDOa *  Load Jordano's Sub
JDOaAC                   if        Client = Jordanos
JDOaAC                   select
JDOaAC                   when      ohsub = 'Y'
JDOaAC                   eval      w1sub = '*SUB*'
JDOaAC                   other
JDOaAC                   eval      w1sub = 'NO   '
JDOaAC                   endsl
JDOaAC                   endif
     C                   eval      w1cord = ohcord
     C                   eval      w1cnam = ohcnam
     C                   eval      w1lbl# = rulbl#
     C                   eval      w1whdp = ruwhdp
     C                   eval      w1item = %trim(lbitem) + ' - ' +
     C                             %trim(itpdsc) + ' ' + itdesc
     C                   eval      w1disp = rudisp
500aAC                   eval      w1oqys = ruoqys
     C                   eval      w1qyso = ruqyso
     C                   eval      w1ucod = lbucod
     C                   eval      w1ucd2 = lbucod
500aAC                   eval      w1ucd3 = lbucod
     C                   eval      w1qyfd = ruqyfd
     *
750bAC                   eval      iqstk1 = 0
750bAC                   eval      iqstk2 = 0
750bAC                   eval      iqstk3 = 0
750bAC                   eval      iqalc1 = 0
750bAC                   eval      iqalc2 = 0
750bAC                   eval      iqalc3 = 0
750bAC                   eval      iqhld1 = 0
750bAC                   eval      iqhld2 = 0
750bAC                   eval      iqhld3 = 0
750bAC                   eval      iqavl1 = 0
750bAC                   eval      iqavl2 = 0
750bAC                   eval      iqavl3 = 0
750bAC     keyit         chain     itemqty
750bAC                   if        %found
750bAC                   eval      iqavl1 = iqstk1 - iqalc1
750bAC                   eval      iqavl2 = iqstk2 - iqalc2
750bAC                   eval      iqavl3 = iqstk3 - iqalc3
750bAC                   if        iqhld1 > 0
750bAC                   eval      iqavl1 = iqavl1 - iqhld1
750bAC                   endif
750bAC                   if        iqhld2 > 0
750bAC                   eval      iqavl2 = iqavl2 - iqhld2
750bAC                   endif
750bAC                   if        iqhld3 > 0
750bAC                   eval      iqavl3 = iqavl3 - iqhld3
750bAC                   endif
750bAC                   endif
     *
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     CSR   ZZGET1        BEGSR
     C*
     C*   Get record from main file.
     C*
     CSR   $PCMD         IFEQ      '*VIEW   '
     CSR   $PCMD         OREQ      '*CHANGE '
     CSR   FILEKY        CHAIN(N)  RECORD                             7978
     CSR                 ELSE
     CSR   FILEKY        CHAIN     RECORD                             7978
     CSR                 ENDIF
     C*
     C                   eval      svstat = rustat
     C                   eval      svqyso = ruqyso
     C*
     C*  Record locked.
     C*
     CSR   *IN78         IFEQ      *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      '*PGMQ   '    $PRTN
     CSR                 EXSR      ZM7974
     CSR                 GOTO      ENDGT1
     CSR                 END
     C*
     C*  Record not found.
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      '*PGMQ   '    $PRTN
     CSR                 EXSR      ZM7983
     CSR                 GOTO      ENDGT1
     CSR                 END
     *
     C     $plbl#        chain     label
     C                   if        not %found
     C                   eval      lbitem = ' '
     C                   eval      lblbl# = 0
     C                   eval      lbrte  = ' '
     C                   eval      lbucod = ' '
     C                   endif
     *
     C     keyit         chain     piritem
     C                   if        not %found
     C                   eval      itdesc = ' '
     C                   eval      itpdsc = ' '
     C                   endif
     *
     C     keyrh         chain     rtehed
     C                   if        not %found
     C                   eval      rhrte = ' '
     C                   endif
     *
     *  Get Customer Order number.
     C     ohkey         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohcord = 0
     C                   endif
     *
     C     rutrn#        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      ptemp# = 0
     C                   endif
     *
     *   Get employee name assigned to transaction.
     C     ptemp#        chain     Piruser1
     C                   if        not %found(Piruser1)
     C                   eval      uscode = ' '
     C                   eval      usfnam = ' '
     C                   eval      uslnam = ' '
     C                   endif
     *
     C*
     CSR   ENDGT1        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  Define key for main file.
     C*
     CSR   FILEKY        KLIST
500aAC                   KFLD                    $Pwhse
500aAC                   KFLD                    $Ptype
     CSR                 KFLD                    $PLBL#
     *
     *  Define FULL key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbitem
     *
     *  Define FULL key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbrte
     *
     *   Full ORDH key
     C     ohkey         klist
     C                   kfld                    ruwhse
     C                   kfld                    lbord
     C*
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      *OFF          FOREVR            1
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*   Get warehouse description.
     C*
     CSR   $PWHSE        CHAIN     WAREHS                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *BLANKS       WHDESC
     CSR                 END
     C*
     C*   Select first screen to display.
     C*
     CSR   $PCMD         IFEQ      '*ADD    '
     C*R                   MOVE *BLANKS   $PCODE
     CSR                 END
     C*
     CSR                 EXSR      SCR01I
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     CSR   ZZUPD         BEGSR
     CSR                 MOVE      '0'           ERROR
     C                   eval      svcmd = $pcmd
     C                   eval      $pcmd = '*UPDATE '
     C                   exsr      zzget1
     C                   eval      $pcmd = svcmd
     C     Error         cabeq     *on           ENDUPD
     C*
     C                   select
     C*
     C*   Status not Open. Update not allowed.
     C                   when      rustat <> 'O'
500aAC                             and rustat <> 'R'
     C                   eval      error  = *on
     C                   eval      *in02  = *on
     C                   eval      *in22  = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C*
     C*   Check if runner status or qty changed.
     C                   when      rustat <> svstat
     C                             or ruqyso <> svqyso
     C                   eval      error = *on
     C                   exsr      zm7983
     C                   endsl
     C*
     C     Error         cabeq     *on           ENDUPD
     C*
     C*   Add record
     C*
     CSR   $PCMD         IFEQ      '*ADD    '
     C                   exsr      zzget1
     C     Error         cabeq     *on           ENDUPD
     CSR                 WRITE     RECORD                               79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           ERROR
     CSR                 EXSR      ZM7871
     CSR                 GOTO      ENDUPD
     CSR                 END
     C*
     CSR                 ELSE
     C*
     C*   -OR- Update record
     C*
     CSR                 eval      ruqyso = w1qyso
     CSR                 UPDATE    RECORD                               79
     CSR   *IN79         IFEQ      '1'
     CSR                 MOVE      '1'           ERROR
     CSR                 EXSR      ZM7872
     CSR                 GOTO      ENDUPD
     CSR                 END
     CSR                 END
     C*
     CSR   ENDUPD        ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Quantity short/out
Status no longer at Open. Update not allowed.

