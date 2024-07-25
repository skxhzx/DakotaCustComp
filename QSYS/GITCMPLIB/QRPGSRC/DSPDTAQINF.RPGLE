     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2003')

     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  DSPDTAQINF   Display data queue information
     F*  03 April 2003
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    04/03/03  DAS  4.17
     F*      - Created.                                                d
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
     FDSPDTAQINFCF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)

      * Include data queue prototypes.
      /copy qcopysrc,p.dtaq

      * Program variable definitions
     D  Length         S             10I 0
      *
      * Data received structure
     D  dqinfo         DS
     D   dqbytesrtnd                 10I 0
     D   dqbytesavail                10I 0
     D   dqmsglength                 10I 0
     D   dqkeylength                 10I 0
     D   dqsequence                   1
     D   dqsenderflag                 1
     D   dqforceflag                  1
     D   dqdesc                      50
     D   dqtype                       1
     D   dqreclaimflg                 1
     D   dqreserved                   1
     D   dqmessages                  10I 0
     D   dqentriesalc                10I 0
     D   dqname                      10
     D   dqlib                       10
     D   dqmaxentries                10I 0
     D   dqintentries                10I 0

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERPO#                  1      5P 0
     D  ERITEM                 6     20
     D                 DS
     D  $EC                    1      2P 0

      *----------------------------------------------------------------
      *  Message control
      *------------------------------------------------------------------
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)

      *----------------------------------------------------------------
      *  Program info data structure
      *----------------------------------------------------------------
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0

      *----------------------------------------------------------------
      *  Workstation exception data structure
      *----------------------------------------------------------------
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371

      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure
      *----------------------------------------------------------------
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
     C*      None
     C*
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
     C*    PIR0110  Number must be greater than zero
     C*
     CSR   ZM0110        BEGSR
     CSR                 MOVE      'PIR0110'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR0203  Value can not be blank.
     C*
     CSR   ZM0203        BEGSR
     CSR                 MOVE      'PIR0203'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1005  Invalid value entered.
     C*
     CSR   ZM1005        BEGSR
     CSR                 MOVE      'PIR1005'     #MSGID
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
     C*  Port must be greater than 0
     C*
     CSR   W1PORT        IFLE      0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
214 ACSR                 MOVEL     DESC(1)       ERRMSG
     CSR                 EXSR      ZM0110
     CSR                 ENDIF
     C*
     C*  Minutes must be greater than 0
     C*
     CSR   W1MIN         IFLE      0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
214 ACSR                 MOVEL     DESC(2)       ERRMSG
     CSR                 EXSR      ZM0110
     CSR                 ENDIF
     C*
     C*  Command can not be blank
     C*
     CSR   W1CMD         IFEQ      *BLANKS
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN23
     CSR                 MOVE      *ON           *IN03
214 ACSR                 MOVEL     DESC(3)       ERRMSG
     CSR                 EXSR      ZM0203
     CSR                 ENDIF
     C*
     C*  Verify expecte response
     C*
     CSR   W1RESP        IFNE      'Y'
     CSR   W1RESP        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN26
     CSR                 MOVE      *ON           *IN06
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(6)       ERRMSG
     CSR                 EXSR      ZM1005
     CSR                 ENDIF
     C*
     C*  Verify jobq option
     C*
     CSR   W1JOBQ        IFNE      'Y'
     CSR   W1JOBQ        ANDNE     'N'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN24
     CSR                 MOVE      *ON           *IN04
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     DESC(4)       ERRMSG
     CSR                 EXSR      ZM1005
     CSR                 ENDIF
     C*
     C*  Instance must be greater than 0 when using jobq
     C*
     CSR   W1JOBQ        IFEQ      'Y'
     CSR   W1INST        ANDLE     0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN25
     CSR                 MOVE      *ON           *IN05
214 ACSR                 MOVEL     DESC(5)       ERRMSG
     CSR                 EXSR      ZM0110
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
     C*     Command
     C*
     CSR                 SELECT
     CSR   ROW#          WHENEQ    9
     CSR                 MOVE      *ON           *IN08
     CSR                 MOVE      '*LOOKUP '    $LCMD
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      *BLANKS       $LDTA
     CSR                 MOVE      *BLANKS       $LRRTN
     CSR                 CALL      'TMR900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*SELECT '
     CSR                 MOVEL(P)  $LDTA         W1CMD
     CSR                 MOVE      $LRRTN        W1RESP
     CSR                 ENDIF
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
     CSR                 Z-ADD     27850         W1PORT
     CSR                 Z-ADD     3             W1MIN
     CSR                 MOVE      *BLANKS       W1CMD
     CSR                 MOVE      'N'           W1RESP
     CSR                 MOVE      'N'           W1JOBQ
     CSR                 Z-ADD     5             W1INST
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
      *
      * Get data queue description
      *
     C                   eval      length = %len(dqinfo)
     C                   CallP     RcvDtaQDesc(
     C                                         dqinfo :
     C                                         Length :
     C                                         'RDQD0100' :
     C                                         'DTAQKEYED RPGISCOOL '
     C                                        )
     C*
     CSR                 Z-ADD     W1PORT        $PPORT
     CSR                 Z-ADD     W1MIN         $PMIN
     CSR                 MOVE      W1CMD         $PCMD
     CSR                 MOVE      W1RESP        $PRESP
     CSR                 MOVE      W1JOBQ        $PJOBQ
     CSR                 Z-ADD     W1INST        $PINST
     C*
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 ENDSR
     C*
