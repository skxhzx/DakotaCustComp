      /copy *libl/qcopysrc,hspecs
      *----------------------------------------------------------------
      *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  LOADR9V   Loader Module - RF - VIP Pallet Loading/Unloading
      *            11 X 20 Screens for hand held scanners
      *
      *  March 19, 2013
      *  Retha Davis
      *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    03/19/13  RBD  6.50a  Quote 1111
     *      - Created for VIP.
     *      - Scan an infinite number of pallets which will be loaded onto
     *        the same trailer, and only when the last merged pallet is
     *        scanned will the loader scan the Trailer Id.
     *      - Removed pallet countdown from the display.
     *      - As pallets are scanned, load them into an array.
     *      - Capture LOAD trans start time when the first pallet is scanned.
     *      - Don't require Trlr Id to be scanned for each pallet, instead,
     *        when it IS scanned, assume that's the last pallet and capture
     *        the LOAD trans end time. Then write the LOAD transactions and
     *        update LDRHDR and LDRDETL for each pallet in the array.
     *      - Having said all this, of course the loader will still be able
     *        to scan only one pallet and then the Trlr Id if he wishes.
     *      - Commented out exsr zzwrttrand. If/when they use wrttran1,
     *        just uncomment the exsr statement.
     *
650bA*    05/28/13  RBD  6.50b
     *      - Fix: In zzupd2 use new key hdkey4 to retrieve loader header
     *        with saved route and route id retrieved from screen 1.
     *        Without this fix, if no trailer was assigned and user
     *        entered a trailer already assigned to another route,
     *        then entered a valid trailer, the key in zzupd2 contained
     *        the route and route id for the trailer already assigned.
     *
650cA*    01/20/15  RBD  6.50c
     *      - Recompiled, LDRDETL and LDRDTLBK files changed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
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
     FLOADR9VFM CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FEQUIP     IF   E           K DISK
     FLDRHDR2   IF   E           K DISK
     F                                     RENAME(LHREC:LHREC2)
     FLDRHDR3   UF   E           K DISK
     F                                     RENAME(LHREC:LHREC3)
     FRTEHED    IF   E           K DISK
     FPIRUSER   IF   E           K DISK
     FLDRHDR    UF   E           K DISK
     FLDRDETL   UF   E           K DISK
     FLDRDTLBK  IF   E           K DISK
     Fpirtran   o  a e           k disk
     Ftask      if   e           k disk
     *----------------------------------------------------------------
     *  Client ID's
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(21) CTDATA PERRCD(1)
     D pallets         s              5  0 dim(999)
     *----------------------------------------------------------------
     *  Data structure for time calculations
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     *----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D route           c                   const('Route ')
     D loaded          c                   const('loaded')
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
     D  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LCODE                22     29
     D*
     *----------------------------------------------------------------
     *  Partial key redifinition
     *
     D $prtky          ds
     D $len50                  1     50
     D  $kwhse                 1     30
     D  $kcode                 4     11
     D*----------------------------------------------------------------
     D*
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
     D                 DS
     D  DSMISC                 1     20
     D  DSSDTE                 1      8
     D  DSSPCL                 9     11
     D  DSRPCK                12     12
     D  DSDOOR                13     14
     D  DSMEAT                15     15
     D  DSCODE                16     16
     D  DSRVS                 19     19
     D*
     D*----------------------------------------------------------------
     D RTE             DS
     D  RTE1                   1      5
     D*
     D*----------------------------------------------------------------
     D PALLET          DS
     D  PLTID                  1      7  0
     D*
     D*   Redefine DS
     D*
     D  PLT12                  1      2  0
     D  PLT37                  3      7  0
     D*
     D  PLT#                   3      7
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERFLD                  1     30
     D*
     D  ERQTY                  1      4P 0
     D  ERNQTY                 5      8P 0
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
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D wrttran1        pr                  extpgm('WRTTRAN1')
      * Input
     D   ppcmd                        8
     D   ppwait                       2  0
     D   ppwhse                       3  0
     D   pptran#                      7  0
     D   ppfromdate                   8  0
     D   pptodate                     8  0
     D   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Variables
     *
     D cnt             s              2  0
     D firstPal        s               n
     D forevr          s              1
     D hdrctr          s              1  0
650bAD hldrte          s              5
650bAD hldrtid         s              5
     D idx             s              2  0
     D idxplid         s              7  0
     D lcmd            s              8
     D lprg            s             10
     D lrtn            s              8
     D ltcode          s              8
     D lwhse           s              3  0
     D sort            s              1
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D wrtpcmd         s             10
     D wrtpwait        s              2  0
     D wrtpwhse        s              3  0
     D wrtptran#       s                   like(pttrn#)
     D wrtpfrmdate     s              8  0
     D wrtptodate      s              8  0
     d wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      ZZINZ2
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
     C     NXTSCR        CASEQ     '04 '         SC4
     C                   ENDCS
     C*
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   SETON                                        LR
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*----------------------------------------------------------------
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   ELSE
     C                   MOVE      *ON           *IN02
     C*  Default to position cursor on route id for screen1.
     C                   if        nxtscr = '01'
     C                   eval      *in02 = '0'
     C                   eval      *in09 = '1'
     C                   endif
     C                   ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     C                   select
     C                   when      nxtscr = '01 '
     C                   EXFMT     SCREEN1                              50
     C*
     C                   when      nxtscr = '02 '
     C                   EXFMT     SCREEN2                              50
     C*
     C                   when      nxtscr = '03 '
     C                   EXFMT     SCREEN3                              50
     C*
     C                   when      nxtscr = '04 '
     C                   EXFMT     SCREEN4                              50
     C*
     C                   ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       010203
     C                   SETOFF                                       040506
     C                   SETOFF                                       070809
     C                   SETOFF                                       101112
     C                   SETOFF                                         1415
     C                   SETOFF                                       161718
     C                   SETOFF                                       192021
     C                   SETOFF                                       2429
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       9298
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   MOVE      *OFF          REDSPL            1
     C                   Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*  Screen 01 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZFIL1
     C                   MOVE      *OFF          REFRSH            1
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 02 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR02I        BEGSR
     C                   MOVE      '02 '         NXTSCR            3
     C                   EXSR      ZZFIL2
     C                   MOVE      *OFF          REFRSH
     C     END02I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 03 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR03I        BEGSR
     C                   MOVE      '03 '         NXTSCR            3
     C                   EXSR      ZZFIL3
     C                   MOVE      *OFF          REFRSH
     C     END03I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 04 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR04I        BEGSR
     C                   MOVE      '04 '         NXTSCR
     C                   EXSR      ZZFIL4
     C                   MOVE      *OFF          REFRSH
     C     END04I        ENDSR
     C*----------------------------------------------------------------
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*  SC1  -  Screen 1
     C*----------------------------------------------------------------
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   MOVE      *ON           REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F1 - UNLOAD pallet
     C*
     C     *INKA         IFEQ      *ON
     C                   MOVE      *OFF          REFRSH
     C                   EXSR      SCR04I
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F11 - Link to close rte application.
     C*
     C     *INKK         IFEQ      *ON
     C*
     C     @PRTN         IFEQ      '*NO'
     C*
     C*  Not authorized to close routes.
     C                   GOTO      ENDSC1
     C                   ELSE
     C                   CALL      'LOADR22'
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C
     C     DSPSCR2       IFEQ      '1'
     C                   EXSR      ZZUPD1
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   ELSE
     C                   EXSR      SCR03I
     C                   ENDIF
     C
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*  SC2  -  Screen 2
     C*----------------------------------------------------------------
     C*
     C     SC2           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   MOVE      *ON           REFRSH
     C                   EXSR      SCR02I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      *OFF          REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK2
     C     ERROR         CABEQ     *ON           ENDSC2
      *
     C                   EXSR      ZZUPD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C                   EXSR      ZZFIL2
     C*
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*  SC3  -  Screen 3
     C*----------------------------------------------------------------
     C*
     C     SC3           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC3
     C                   ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      *OFF          REFRSH
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC3
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK3
      *
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C*  Hold pallet starting date & time when first pallet is scanned.
     C                   if        firstPal
     C                   eval      firstPal = *off
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        HLDSTD
     C                   TIME                    HLDSTT            6 0
     C                   endif
     C*
     C*  Load pallet into array.
     C*
     C                   eval      idx = idx + 1
     C                   eval      pallets(idx) = plt37
     C*
     C                   if        w3trl# = *blanks
     c                   if        *in25
     C                   exsr      zzfil3
     c                   endif
     C                   goto      endsc3
     C                   endif
     C*
     C                   EXSR      ZZUPD3
     C*
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C                   EXSR      ZZFIL3
     C*
     C     *IN12         IFEQ      *ON
     C*  Display 'Route loaded' msg.
     C     ROUTE         CAT       W1RTE#        MSG1             10
     C     MSG1          CAT       LOADED        ERRMSG
     C                   EXSR      ZM0105
     C                   MOVE      '01 '         NXTSCR
     C                   ENDIF
     C
     C     ENDSC3        ENDSR
     C*----------------------------------------------------------------
     C*  SC4  -  Screen 4   -   Unload pallet
     C*----------------------------------------------------------------
     C*
     C     SC4           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC4
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD4
     C     CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK4
      *
     C     ERROR         CABEQ     *ON           ENDSC4
      *
     C                   EXSR      ZZUPD4
     C     ERROR         CABEQ     *ON           ENDSC4
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD4
     C     CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C                   EXSR      ZZFIL4
     C*
     C     ENDSC4        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
     *
     *  Get Client ID
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
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
     C*----------------------------------------------------------------
     C*    ZMCMSG  Clear message record subfile
     C*----------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C*    ZMDMSG  Display message record subfile
     C*----------------------------------------------------------------
     C*
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
     C     MSGK          IFGT      0
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK
     C                   END
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMIMSG  Initialization necessary for message subfile
     C*----------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C*    ZSCLR   Clear screen
     C*----------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
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
     C*      0105
     C*
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*      0110  Number must be > 0
     C*
     C     ZM0110        BEGSR
     C                   MOVE      'PIR0110'     #MSGID
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
     *----------------------------------------------------------------
     *   EQ52003  Equipment type not valid.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'EQ52003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   EQ52004  Equipment status not valid.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'EQ52004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     C*  ZZCHK1   Screen 1 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK1        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      '0'           DSPSCR2           1
     C*
     C*   Verify warehouse and get description.
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
      *
      *  Check if user id is found in user file.
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   if        w1rtid = ' '
     C                   MOVE      *ON           *IN02
     C                   else
     C                   eval      *in09 = '1'
     C                   endif
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C*
     C*  Verify route id if entered, otherwise, verify route.
     C*
     C                   select
     C*
     C                   when      w1rtid <> ' '
     C*
     C*  Verify route id entered.
     C*
     C     HDKEY3        CHAIN(N)  ldrhdr3                            79
     C                   IF        *IN79
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN29
     C                   MOVE      *ON           *IN09
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(16)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
     C                   eval      w1rte# = lhrte
     C*
     C                   other
     C*
     C*  Verify route entered.
     C*
     C                   EVAL      HDRCTR = 0
     C     HDKEY         SETLL     LHREC
     C                   DOW       FOREVR = FOREVR
     C     HDKEY         READE     LHREC                                  79
     C                   IF        *IN79
     C                   IF        HDRCTR > 0
     C                   LEAVE
     C                   ENDIF
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
     C                   EVAL      HDRCTR = HDRCTR + 1
     C                   IF        HDRCTR > 1
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN29
     C                   MOVE      *ON           *IN09
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(19)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
     C                   ENDDO
      *
     C                   endsl
      *
      *  Check if all pallets are already loaded for this route.
      *
     C                   EXSR      ZZCHKL
     C     *IN12         IFEQ      *ON
     C     PLTCNT        ANDGT     *ZEROS
      *
      *  Route is loaded, display friendly msg using error routine
     C                   MOVE      *ON           ERROR
     C                   if        w1rtid <> ' '
     C                   eval      *in09 = '1'
     C                   eval      *in29 = '1'
     C                   else
     C                   MOVE      *ON           *IN02
     C                   MOVE      *ON           *IN22
     C                   endif
     C                   MOVEL     DESC(5)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *  Pltcnt=0  Rte has no pallets (error).
     C     PLTCNT        IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   if        w1rtid <> ' '
     C                   eval      *in09 = '1'
     C                   eval      *in29 = '1'
     C                   else
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN02
     C                   endif
     C                   MOVE      *OFF          *IN01
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(14)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
      *
      *  Check if route has not been assigned to a loader,
      *  if not, display screen to assign trailer#.
      *  NOTE: If Lhemp#=0=Rte not assigned
      *
     C     LHEMP#        IFEQ      *ZEROS
     C                   MOVE      '1'           DSPSCR2
     C                   ENDIF
      *
      *
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK2   Screen 2 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK2        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
      *
      *  Validate trailer id against equipment file.
      *
     C                   MOVEL     W2TRL#        HLDTRL
     C     TRLKEY        CHAIN     EQUIP                              79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN01
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(4)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK2
     C                   ENDIF
     C                   ELSE
     C                   EXSR      ZZTRLR
     C                   GOTO      ENDCK2
     C                   ENDIF
      *
      *
      *  Make sure trailer is not being used to load another route.
      *
     C     TRLKEY        CHAIN     LDRHDR2                            79
     C     *IN79         IFEQ      *OFF
     C     W1RTE#        ANDNE     LHRTE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN01
     C     ERRMSG        IFEQ      *BLANKS
     C     DESC(7)       CAT       LHRTE:1       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK2
     C                   ENDIF
     C                   ENDIF
     C*
      *
     C     ENDCK2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK3   Screen 3 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK3        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVE      LHRTID        RTEID#            5
     C*
     C*  The last two numbers of the route ID # have being added to the
     C*  pallet id label (only) to prevent loading a pallet into the
     C*  wrong trailer since the actual pallet ids (in BFC files) have
     C*  two zeros as first digits and the same pallet id numbers are
     C*  used in all routes, one could load a pallet on any trailer
     C*  without knowing that it belongs to a different route.
     C*
     C*  Verify pallet # entered.
     C*
     C                   MOVE      lhrtid        RTE1
     C                   Z-ADD     W3PLT#        PLTID
     C*
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      lhrtid        $cstr            30
     C                   move      $cstr         last2rte          2 0
     C*
     C*  Pallet is not part of route being loaded
     C*
     C     last2rte      IFNE      PLT12
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN25
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C*
     C*  Zero out first two positions of scanned pallet id,
     C*  the first two digits are zeros in orig  pallet id.
     C*  that is how they are stored in the file.
     C*
     C                   Z-ADD     *ZEROS        PLT12
     C*
     C     CHAIN         TAG
     C     DTKEY         CHAIN     LDDREC                             79
     C*
     C*  Invalid pallet Id.
     C                   IF        *IN79
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN25
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C*
     C     LDENDD        IFNE      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN25
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEL     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Verify trailer # if it is entered.
     C*
     C     W3TRL#        IFNE      LHTRLR
     C     W3TRL#        andne     *blanks
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(20)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK3
     C                   ENDIF
     C                   ENDIF
      *
     c                   if        *in25
     c                   eval      *in25 = *off
     c                   eval      *in23 = *on
     c                   else
     c                   eval      *in25 = *on
     c                   eval      *in23 = *off
     c                   endif
      *
     C     ENDCK3        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK4   Screen 4 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK4        BEGSR
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C*
     C*   Verify warehouse and get description.
     C*
     C                   MOVE      '*VERIFY '    $LCMD
     C                   Z-ADD     W4WHSE        $LWHSE
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
      *
     C*  Verify route id
     C*
     C     HDKEY2        CHAIN(N)  ldrhdr3
     C                   IF        not %found(ldrhdr3)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(16)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C*  Verify route not closed to loader module
     C*
     C                   if        %found(ldrhdr3)
     C                             and lhclsd <> 0
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(17)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
      *  Verify pallet and trailer have been loaded to the route id entered
      *  so that it can be unloaded.
      *
     C                   MOVE      w4plt#        plt#              5
     C                   MOVE      plt#          kyplt#            7 0
     C     dtkey4        chain     ldrdetl
     C                   if        not %found(ldrdetl)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C                   if        %found(ldrdetl)
     C                             and ldendt = 0
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(18)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C                   if        w4trl# <> lhtrlr
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(20)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK4
     C                   ENDIF
     C                   ENDIF
      *
     C     ENDCK4        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHKL   Check if route to be loaded is already loaded.
     C*----------------------------------------------------------------
     C*
     C     ZZCHKL        BEGSR
     C                   MOVE      *OFF          ERROR
      *
      *  Check if all pallets are loaded for this route.
      *
     C                   SETON                                        12
     C                   Z-ADD     *ZEROS        PLTCNT            3 0
     C     DTKEY2        SETLL     LDRDETL
     C     DTKEY2        READE(N)  LDRDETL                                79
     C     *IN79         DOWEQ     *OFF
     C                   ADD       1             PLTCNT
     C     LDENDD        IFEQ      *ZEROS
     C                   SETOFF                                           12
     C                   LEAVE
     C                   ENDIF
     C     DTKEY2        READE(N)  LDRDETL                                79
     C                   ENDDO
     *
     C     ENDCKL        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD1   User defined command keys for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      *ON
     C                   MOVE      *ON           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C                   SELECT
     C*
     C                   OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   GOTO      ENDCM1
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD2   User defined command keys for screen 2.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD2        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C*
     C*  Command keys to check AFTER verification and update.
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
     C                   SELECT
     *
     C     csrfld        wheneq    'W2TRL#'
     C                   move      *off          error
     C                   move      '*LOOKUP '    lcmd
     C                   z-add     1             lwhse
     C                   movel     $lwhse        $kwhse
     C                   move      #prog         lprg
     C                   movel     'TRAILR'      $kcode
     C                   move      *blanks       ltcode
     C                   move      '1'           sort
     C                   call      'EQ910'
     C                   parm                    $prtky
     C                   parm                    lrtn
     C                   parm                    ltcode
     C                   parm                    sort
     C     lrtn          ifeq      '*SELECT '
     C                   movel     ltcode        w2trl#
     C                   exsr      zztrlr
     C                   endif
     C*
     C                   other
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C                   ENDIF
     C                   ENDIF
     C*
     C     ENDCM2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD3   User defined command keys for screen 3.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD3        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM3        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCMD4   User defined command keys for screen 4.
     C*----------------------------------------------------------------
     C*
     C     ZZCMD4        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     C     CMDCHK        IFEQ      '*BEFORE '
     C*
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM4        ENDSR
     C*----------------------------------------------------------------
     C*  zzCrtTrn  Create LOAD transaction record.
     C*
     C     zzCrtTrn      BEGSR
     C*
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '4'
     C                   eval      pttask = 'LOAD'
     C     pttask        chain     task
     C                   if        %found(task)
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   else
     C                   eval      ptcat = ' '
     C                   eval      ptsub = ' '
     C                   endif
     C                   eval      ptwhse = ldwhse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = ldemp#
     C                   eval      ptcube = ldcube
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = ldpcs
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = ldstrd
     C                   eval      ptstim = ldstrt
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptedte = ldendd
     C                   eval      ptetim = ldendt
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = ldendd
     C                   eval      ptctim = ldendt
     C                   eval      ptrtpo = ldrtid
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     * Calc direct/indirect time
     C                   exsr      zzTime
     C                   write     ptrec                                79
     C     *in79         ifeq      '1'
     C                   move      '1'           error
     C                   exsr      zm71
     C                   goto      endcrtt
     C                   endif
650aDc**                 exsr      zzwrttrand
     C*
     C     endcrtt       endsr
     C*
     C*----------------------------------------------------------------
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL1        BEGSR
     C*
     C                   MOVE      *BLANKS       W1RTE#
     C                   MOVE      *BLANKS       W1RTID
     C                   eval      *in25 = *on
     C                   eval      *in23 = *off
     C                   eval      firstPal = *on
     C                   eval      idx = 0
     C                   eval      pallets = 0
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL2        BEGSR
     C*
     C                   EVAL      W2RTE# = W1RTE#
     C                   EVAL      W2TRL# = *BLANKS
      *
      *
      *  Get loading door number
     C                   EVAL      W2DOOR = *BLANKS
     C     RTKEY         CHAIN     RTEHED                             79
      *
650bAC                   eval      hldrte = lhrte
650bAC                   eval      hldrtid = lhrtid
      *
     C     ENDFL2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL3        BEGSR
     C*
     C                   EVAL      W3RTE# = W1RTE#
      *
     C                   EVAL      W3PLT# = *ZEROS
      *
     C                   EVAL      W3TRL# = *BLANKS
      *
      *  Get loading door number
     C                   EVAL      W3DOOR = *BLANKS
     C     RTKEY         CHAIN     RTEHED                             79
      *
     C     ENDFL3        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL4   Fill screen 4 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL4        BEGSR
      *
     C                   EVAL      W4WHSE = W1WHSE
     C                   EVAL      W4RTID = *blanks
     C                   EVAL      W4PLT# = *ZEROS
     C                   EVAL      W4TRL# = *BLANKS
     C                   EVAL      KYPLT# = *ZEROS
      *
     C     ENDFL4        ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      #PROG         $PPRG            10
     C                   MOVE      '1'           MRGSCN            1
     C                   eval      *in09 = '1'
     *
     *  Define key for main file.
     *
     C     HDKEY         KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     *
     C     HDKEY2        KLIST
     C                   KFLD                    W4WHSE
     C                   KFLD                    W4RTID
     *
     C     HDKEY3        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTID
     *
650bAC     HDKEY4        KLIST
650bAC                   KFLD                    W1WHSE
650bAC                   KFLD                    HLDRTE
650bAC                   KFLD                    HLDRTID
     *
     C     DTKEY         KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     C                   KFLD                    LHRTID
     C                   KFLD                    PLTID
      *
     C     DTKEY2        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     C                   KFLD                    LHRTID
      *
     C     DTKEY3        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    W1RTE#
     C                   KFLD                    LHRTID
     C                   KFLD                    idxplid
      *
     C     DTKEY4        KLIST
     C                   KFLD                    w4whse
     C                   KFLD                    lhrte
     C                   KFLD                    w4rtid
     C                   KFLD                    kyplt#
      *
     C     DTKEY5        KLIST
     C                   KFLD                    w1whse
     C                   KFLD                    lhrte
     C                   KFLD                    lhrtid
     *
     C     RTKEY         KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    LHRTID
      *
     C     TRLKEY        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    HLDTRL            8
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ2   Program initialization. Called from main line.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ2        BEGSR
     C*
     C                   MOVE      *ON           REFRSH
     C                   MOVE      *OFF          MORE              1
     C                   MOVE      *OFF          DONE              1
     C                   MOVE      *OFF          EXCPTN            1
     C                   MOVE      *ZEROS        HLDSTT            6 0
     C                   MOVE      *ZEROS        HLDSTD            8 0
     C                   MOVE      *ZEROS        HLDENT            6 0
     C                   MOVE      *ZEROS        HLDEND            8 0
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   Z-ADD     #WHSE         W1WHSE
      *
      *
      *  Check if user id is found in user file.
      *
     C     #EMP#         IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
      *
      *  Check if user is a loading supervisor or is allowed to close rtes.
      *
     C                   CALL      'CHKLIST'
     C                   PARM                    #PROG
     C                   PARM      ' '           @POPT            20
     C                   PARM                    #USER
     C                   PARM      ' '           @PRTN             8
     C*
     C     @PRTN         IFEQ      '*YES'
     C                   MOVE      *ON           *IN27
     C                   ENDIF
     C*
     C                   EXSR      SCR01I
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     *
     *  ZZTIME   Calculate direct/indirect time
     *
     C     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = ptstim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = ptetim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        ptetim < ptstim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     pttask        chain     task
     C                   if        not %found(task)
     C                   eval      ptimin = 0
     C                   eval      ptdmin = 0
     C                   goto      endtim
     C                   endif
     C                   if        tktype = 'I'
     C                   eval      ptimin = timlen
     C                   eval      ptdmin = 0
     C                   else
     C                   eval      ptdmin = timlen
     C                   eval      ptimin = 0
     C                   endif
     *
     C     endtim        endsr
     *----------------------------------------------------------------
     *
     *  ZZTRLR   Validate trailer.
     *
     *----------------------------------------------------------------
     C     zztrlr        begsr
     *
     C                   movel     w2trl#        hldtrl
     *
     C     trlkey        chain     ldrhdr2                            79
     C                   if        not *in79
     C                   if        w1rte# <> lhrte   or
     C                             W1rtid <> *blanks and
     C                             W1rtid <> lhrtid
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C     desc(21)      cat       lhrte:1       errmsg
     C     errmsg        cat       lhrtid:1      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     *
     C     endtrl        endsr
     C*----------------------------------------------------------------
     C*  ZZUPD1   Update for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZUPD1        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      SCR02I
     C*
     C     ENDUP1        ENDSR
     C*----------------------------------------------------------------
     C     ZZUPD2        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C*
650bDC**   DTKEY5        CHAIN     LHREC                              79
650bMC     hdkey4        CHAIN     LHREC                              79
     C*  Move route starting loading date and time into Ldrhdr file.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LHSTRD
     C*
     C                   TIME                    LHSTRT
     C*
      *
      *  Get loader emp#
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *OFF
     C                   Z-ADD     USEMP#        LHEMP#
     C                   ENDIF
      *
      *  Load trailer# and set route loading to 'started' status.
      *
     C                   MOVEL     W2TRL#        LHTRLR
     C                   MOVE      '2'           LHSTAT
      *
     C*
     C                   UPDATE    LHREC
      *
     C                   MOVE      *OFF          ERROR
     C*
     C                   EXSR      SCR03I
     C*
     C     ENDUPD2       ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     C     ZZUPD3        BEGSR
     C                   MOVE      *OFF          ERROR
     C*
     C*  Get ending loading date and time
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        HLDEND
     C*
     C                   TIME                    HLDENT
      *
      *  Get loader emp#
      *
     c                   eval      usemp# = 0
     C     #USER         CHAIN     PIRUSER                            79
      *
     c                   do        idx           cnt
     c                   eval      idxplid = pallets(cnt)
     c     dtkey3        chain     lddrec
     c                   if        not %found
     c                   iter
     c                   endif
     C*
     C*  Move values into Ldrdetl fields
     C                   Z-ADD     USEMP#        LDEMP#
     C                   Z-ADD     HLDSTD        LDSTRD
     C                   Z-ADD     HLDSTT        LDSTRT
     C                   Z-ADD     HLDEND        LDENDD
     C                   Z-ADD     HLDENT        LDENDT
     C*
     C                   UPDATE    LDDREC
     C                   exsr      zzCrtTrn
     C                   enddo
      *
      *  Check if all pallets are loaded for this route to
      *  record its ended date and time in the header record.
     C*
     C                   EXSR      ZZCHKL
      *
     C     *IN12         IFEQ      *ON
     C     DTKEY5        CHAIN     LDRHDR                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      $CVD8O        LHENDD
     C                   TIME                    LHENDT
     C                   MOVE      '3'           LHSTAT
     C                   UPDATE    LHREC
     C                   ENDIF
     C                   ENDIF
     *
     C                   eval      firstPal = *on
     C                   eval      idx = 0
     C                   eval      pallets = 0
     *
     C     ENDUPD3       ENDSR
     C*
     C*----------------------------------------------------------------
     C*  ZZUPD4   Update for screen 4.
     C*
     C     ZZUPD4        BEGSR
     C*
     C                   MOVE      *OFF          ERROR
     C*
     C*  Unload pallet
     C*
     C     dtkey4        chain     ldrdetl
     C                   if        %found(ldrdetl)
     C                   eval      ldstrd = 0
     C                   eval      ldstrt = 0
     C                   eval      ldendd = 0
     C                   eval      ldendt = 0
     C*
     C*  If unloaded pallet is outed pallet, grab cube and pcs.
     C*
     C     dtkey4        chain     ldrdtlbk
     C                   if        %found(ldrdtlbk)
     C                   eval      ldcube = ldbcub
     C                   eval      ldpcs  = ldbpcs
     C                   endif
      *
     C                   update    lddrec
      *
      *  Clear date and time and set status to 'started' in loader hdr if route
      *  is 'ended' but not 'closed'.
      *
     C     hdkey2        chain     ldrhdr3
     C                   if        %found(ldrhdr3)
     C                             and lhendd <> 0
     C                             and lhclsd =  0
     C                   eval      lhendd = 0
     C                   eval      lhendt = 0
     C                   eval      lhstat = '2'
     C                   update    lhrec3
     C                   endif
      *
     C                   endif
      *
     C                   EXSR      SCR01I
     C*
     C     ENDUPD4       ENDSR
     *----------------------------------------------------------------*********
     *
     *  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
     *
      /free
        begsr zzwrttrand;
          wrtpcmd = '*ONETRAN';
          wrtpwait = 0;
          wrtpwhse = ptwhse;
          wrtptran# = pttrn#;
          wrtpfrmdate = 0;
          wrtptodate = 0;
          wrtpemp# = 0;

          wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
                    wrtpfrmdate: wrtptodate: wrtpemp#);
        endsr;
      /end-free
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
** DESC - Message
Invalid Route #                                             1
Invalid pallet #                                            2
Pallet already loaded                                       3
Invalid trailer #                                           4
Route already loaded                                        5
Rte# not assigned yet                                       6
Trailer used by                                             7
User not found                                              8
Invalid tran #                                              9
Breakers plt not found                                     10
Pallet not in Pltsum                                       11
Close Plt to trailer                                       12
Trler equip not loaded                                     13
Route has no pallets                                       14
Cannot load plt out of seq, prior plt not loaded           15    -CLD A-
Invalid Route Id                                           16
Rte has been closed                                        17
Pallet not loaded                                          18
Enter route id, duplicate route exists                     19
Wrong trailer #                                            20
Input trailer # is being used by route                     21
