     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  CK370A    Manager Ship List - Options
     F*  30 June     2021
     F*  Nancy Koelz (Copy from CK370 now using ORDHEXA)
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    12/30/03  MLB  4.17
     F*      - Created.
417aAF*    02/26/04  RH   4.17a
     F*      - Change to redisplay screen 1 after print, F3 to EXIT.
700aAF*    09/07/16  JCJ  7.00a
     F*      - ENH: Added Customer Order Lookup.
700bAF*    10/13/16  JCJ  7.00b
     F*      - ENH: Do not edit flag customer order if entered.
     F*
750 AF*    06/30/21  NLK  7.50
     F*      - Created.
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
750  FCK370AFM  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
750 D *ORDH4     IF   E           K DISK
750 MFORDH      IF   E           K DISK
     FREPORTS   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
700aD ***                 DESC    1   5 60
700aMD DESC            S             60    DIM(6) CTDATA PERRCD(1)
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
     D  $LRTID                22     26
750  D  $LCORD                27     37
750 D * $LCORD                27     33  0
     D*----------------------------------------------------------------
     D*  Redefinition fields
     D*
     D                 DS
     D  $CLIST                18     18
     D  OHMISC                 1     20
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
750 AD @getcl          C                   CONST('GETCLIENT ')
     D*
750  D/copy qcopysrc,id#cheney
750  D/copy qcopysrc,p.exordh
750  D/copy qcopysrc,c#stdvar
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Name constants
     D*
     D DIGIT           C                   CONST('0123456789 ')
750  D kycord          s             11
750  D pos             s              1  0
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
     C*      $WHSE - Warehosue
     C*      $RTID - BFC internal route number
     C*      $CRTE - Customer route number
     C*
     C*    Returned Parameters
     C*      $PRTN   *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $WHSE             3
     C                   PARM                    $RTID             5
     C                   PARM                    $CRTE             5
     C                   PARM                    $PRTN             8
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   EXSR      ZZINZ2
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
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
     C                   MOVE      *ON           *INLR
     C*
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
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR                 SELECT
     CSR   NXTSCR        WHENEQ    '01 '
     CSR                 EXFMT     SCREEN1                              50
     CSR                 ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       30
     CSR                 SETOFF                                       98
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CMDTKN            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 ENDSR
750 A*----------------------------------------------------------------
750 A*
750 A*  GETOHa  Retrieve Order Header Expanded fields OHORD & OHCUS
750 A*
750 AC     getoha        begsr
750 A /free
750 A    exWhse = w1whse;
750 A    ohaorda = w1cord;
750 A      exordh ('*GETID': exRtnCode: exRtnMsg: exWhse: ohaord:
750 A              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
750 A              ohaorda: ohacusta);
750 A /end-free
750 AC                   endsr
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
     C*    Fill screen fields with data.
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
     CSR   *INKC         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 ENDIF
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
     CSR   ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  Call report printing program.
     CSR                 EXSR      ZZNXT1
417b CSR                 EXSR      SCR01I
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
750  *
750  * Get client id.
750  *
750  C                   call      @getcl
750  C                   parm                    client           10
750  C                   parm                    clientloc        10
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
     CSR                 MOVE      *OFF          *IN97
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
     CSR                 PARM                    #PGMQ
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
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*  Verify customer order number.
     CSR   W1CORD        IFNE      '*ALL   '
     C*
     CSR                 MOVE      *OFF          *IN81
     CSR   DIGIT         CHECK     W1CORD                                 81
     C*
     CSR                 SELECT
     C*  *IN81 = *ON - Found character other than that contained
     C*           in the field DIGIT.
     CSR   *IN81         WHENEQ    *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM1001
     C*
     C*  *IN81 = *OFF - Found only digits. Order number.
     C*
     CSR   *IN81         WHENEQ    *OFF
     CSR                 MOVE      *ZEROS        KYCORD
     CSR                 MOVE      *BLANKS       $CSTR
     CSR                 MOVEL     W1CORD        $CSTR
     CSR                 CALL      'ADJUST'
     CSR                 PARM      '*RIGHT  '    $CCMD             8
     CSR                 PARM                    $CSTR            30
     CSR                 MOVE      $CSTR         KYCORD
     C*
750  C*  zero fill kycord since they didn't enter all 11 digits
750  C                   eval      pos = %scan (' ':kycord)
750  C                   dow       pos <> 0
750  C                   eval      kycord = %replace ('0':kycord:pos:1)
750  C                   eval      pos = %scan (' ':kycord)
750  C                   enddo
750  C                   eval      w1cord = kycord
     C*
     C*  Extended Order# needed (was 7 long, now 11 long)
     C*
750  C                   EXSR      getoha
      *
750 D **   OHKEY         CHAIN     ORDH4                              79
750 MC     OHKEYE        CHAIN     ORDH                               79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVEL     DESC(5)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C*
700bDC     *IN79         IFEQ      *OFF
700bDC     $CLIST        ANDNE     'Y'
700bD ***                  MOVE *ON       ERROR
700bD ***                  MOVE *ON       *IN21
700bD ***                  MOVE *ON       *IN01
700bD ***                  MOVE *BLANKS   ERRMSG
700bD ***                  MOVELDESC,6    ERRMSG
700bD ***                  EXSR ZM0105
700bDC                   ENDIF
     C*
     CSR                 ENDSL
     C*
     CSR                 ENDIF
     C*
     C*  Verify jobq option
     C*
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify default device
     C*
     CSR                 MOVEL     W1DEV         WORK1A            1
     CSR   WORK1A        IFEQ      '*'
     CSR   W1DEV         ANDNE     '*SYSVAL'
     CSR   W1DEV         ANDNE     '*JOB'
     CSR   W1DEV         OREQ      *BLANKS
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(3)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     C*  Verify default form type
     C*
     CSR                 MOVEL     W1FORM        WORK1A            1
     CSR   WORK1A        IFEQ      '*'
     CSR   W1FORM        ANDNE     '*STD'
     CSR   W1FORM        OREQ      *BLANKS
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN24
     CSR                 MOVE      *ON           *IN04
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(4)       ERRMSG
     CSR                 EXSR      ZM1001
     CSR                 ENDIF
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
      *
      *  ZZCMD1   User defined command keys for screen 1.
      *
     C     ZZCMD1        BEGSR
     *
700aA*  Test for F4 - Lookup
     *
     C     *INKD         IFEQ      *ON
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     *
700aA*     Customer Order Lookup.
     *
     C     ROW#          IFEQ      10
     C     COL#          ANDGE     34
     C     COL#          ANDLE     40
     C                   MOVE      *ON           *IN12
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   MOVE      $WHSE         $LWHSE
     C                   MOVE      $RTID         $LRTID
     C                   MOVE      *ZEROS        $LCORD
     C                   CALL      'OR903'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   MOVE      $LCORD        W1CORD
     C                   MOVE      *ON           CMDTKN
     C                   GOTO      ENDCM1
     C                   ENDIF
     C                   ELSE
     *
     *     Cursor not on a valid lookup field.
     *
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDIF
     C                   GOTO      ENDCM1
     C                   ENDIF
     *
     C                   MOVE      *OFF          CMDTKN
      *
     C     ENDCM1        ENDSR
      *----------------------------------------------------------------
      *
      *  ZZFIL1   Fill screen 1 fields with info from file.
      *
     CSR   ZZFIL1        BEGSR
      *
     CSR                 MOVE      $WHSE         W1WHSE
     CSR                 MOVE      $CRTE         W1CRTE
      *
     CSR                 MOVE      *BLANKS       W1CORD
     C*
     CSR                 MOVE      'N'           W1JOBQ
     C*
     C*   Initialize printer device/form
     C*
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      RPDEV         W1DEV
     CSR                 MOVE      RPFORM        W1FORM
     CSR                 ELSE
     CSR                 MOVEL     '*JOB    '    W1DEV
     CSR                 MOVEL     '*STD    '    W1FORM
     CSR                 ENDIF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
750 D **   *LIKE  **     DEFINE    OHCORD        KYCORD
     CSR   OHKEY         KLIST
     CSR                 KFLD                    W1WHSE
     CSR                 KFLD                    $RTID
     CSR                 KFLD                    KYCORD
     C*
750 AC     OHKEYE        KLIST
750 AC                   KFLD                    W1WHSE
750 AC                   KFLD                    ohaord
     C*
     CSR   *LIKE         DEFINE    RPPRTF        KYPRTF
     CSR   RPKEY         KLIST
     CSR                 KFLD                    KYPRTF
     C*
     CSR                 MOVEL     'CK375APR'    KYPRTF
     CSR                 MOVE      *BLANKS       RPTTTL
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVEL     RPDESC        $PSTR            60
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       $PSTR
     CSR                 ENDIF
     CSR                 Z-ADD     40            $PLEN             3 0
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         RPTTTL
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
     CSR                 MOVE      *ON           *IN97
     CSR                 MOVE      *OFF          *IN90
     CSR                 MOVE      *OFF          *IN91
     CSR                 MOVE      *OFF          ERROR
     C*
     C*   Select first screen to display.
     C*
     CSR                 EXSR      SCR01I
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZNXT1   What to do next when screen 1 input is ok.
     C*
     CSR   ZZNXT1        BEGSR
     C*
     CSR   W1CORD        IFNE      '*ALL   '
     CSR                 MOVE      OHORD         $PORD#
     CSR                 ELSE
     CSR                 MOVE      W1CORD        $PORD#
     CSR                 ENDIF
     C*
     C*    Call Manager Ship List print program.
     CSR                 CALL      'CK370CL'
     CSR                 PARM      $WHSE         $PWHSE            3
     CSR                 PARM      $RTID         $PRTID            5
     CSR                 PARM                    $PORD#            7
     CSR                 PARM      W1JOBQ        $PJOBQ            1
     CSR                 PARM      W1DEV         $PDEV            10
     CSR                 PARM      W1FORM        $PFORM           10
     C*
417bDC***                  MOVE 'EOJ'     NXTSCR
     C*
     CSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Customer order number
Job queue option
Printer device
Form type
Order number not found.
Order not flagged.
