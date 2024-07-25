      /copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  TAX110  Tax-Right options - Cleanup
     F*  07 July 2006
     F*  Robin Clark
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
500 AF*    07/07/06  RMC
     F*      - Created. Copied from RED110
     F*
510 AF*    12/17/06  JCJ
     F*      - Added postion to warehouse and $pcmd selection.
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
     FTAX110FM  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FOPTIONS   UF A E           K DISK
     F                                     RENAME(OPREC:RECORD)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             50    DIM(2) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D $PARMS          DS
     D  $PCMDX                 1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTNX                69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
      *
      *----------------------------------------------------------------
510 A *  *TAXR  -  Tax Rite - Options
      *----------------------------------------------------------------
      *
      * Fields
      *
      *    OPTXHS  -  Days to keep Tax-Right export data (1-999).
510 A *    OPCMD1  -  Command for Tax-Right file processing in OR605
      *
      * Data structure
      *
     D OPDATA          DS
     D  OPTXHS                 1      3  0 INZ(0)
510 AD  opcmd1                 4     11
     D  OPTEND               117    117
      *----------------------------------------------------------------
      *  Called program parameters
      *
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
      *
      *   Redefine key
      *
     D  $LWHSE                19     21  0
      *
      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *
     D $MDT            DS
     D  ERRMSG                 1     50
      *
     D  ERFLD                  1     30
     D  ERFROM                31     40
     D  ERTO                  41     50
     D                 DS
     D  $EC                    1      2P 0
      *----------------------------------------------------------------
      *  Message control
      *
     D #MSGF           C                   CONST('PIRMSGF   ')
      *
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
      *----------------------------------------------------------------
      *  Program info data structure
      *
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
      *----------------------------------------------------------------
      *  Workstation exception data structure
      *
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure
      *
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
510 A *----------------------------------------------------------------
510 A *  Variables
510 A *----------------------------------------------------------------
510 Ad $pwhse          s              3  0
510 Ad #whse           s              3  0
510 AD $pcmd           s              8
510 AD $prtn           s              8
510 AD repos           s              1
      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $PCMD   *CHANGE  - Change record.
      *
      *    Returned Parameters
      *      $PRTN   blank    - No problem encountered.
      *              *ERROR   - Error occured. Message in $PERM
      *              *PGMQ    - Error occured. Message sent to pgmq.
      *
      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $prtn

      *----------------------------------------------------------------
      *  Main line
      *
510 AC                   eval      *in01 = *on
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       $PRTN
     C                   MOVE      *BLANKS       $PERM
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
      *
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   ENDCS
     C                   ENDDO
      *
      *   Do some clean up before leaving.
      *
     C                   EXSR      ZSCLR
     C                   EVAL      *INLR = *ON
     C                   RETURN
      *----------------------------------------------------------------
      *  DSPSCR - Display screen
      *
     C     DSPSCR        BEGSR
      *
      *   Set ON alarm indicator if error occured
      *
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   ENDIF
      *
      *   Overlay screen with error messages
      *
     C                   EXSR      ZMDMSG
      *
      *  Overlay screen with screen to be processed.
      *
     C                   SELECT
     C     NXTSCR        WHENEQ    '01 '
     C                   EXFMT     SCREEN1                              50
     C                   ENDSL
      *
      *   Initialize error indicators and fields
      *
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
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       98
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   Z-ADD     0             E                 2 0
      *
      *   Initialize error subfile
      *
     C                   EXSR      ZMCMSG
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *----------------------------------------------------------------
      *
      *  Screen 01 initialization
      *
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
      *
     C     $PCMD         IFEQ      '*VIEW   '
     C                   MOVE      *ON           *IN90
     C                   ENDIF
      *
      *  Get field defaults if this is an add.
      *
     C     $PCMD         IFEQ      '*ADD    '
     C                   EXSR      ZZDFT1
     C                   ELSE
      *
      *  Otherwise get existing record(s).
      *
     C                   MOVE      *ON           *IN91
     C                   EXSR      ZZGET1
     C                   EXSR      ZZFIL1
     C                   END
     C     END01I        ENDSR
      *----------------------------------------------------------------
      *
      *              Screen Processing Routines
      *
      *----------------------------------------------------------------
      *
      *  SC1  -  Screen 1
      *
     C     SC1           BEGSR
      *
      *  Test for F3 - Exit
      *
     C     *INKC         IFEQ      *ON
     C     *LOVAL        SETLL     RECORD
     C                   MOVE      'EOJ'         NXTSCR
     C                   MOVE      '*EXIT   '    $PRTN
     C                   GOTO      ENDSC1
     C                   END
      *
      *  Test for F5 - Refresh
      *
     C     *INKE         IFEQ      *ON
     C     $PCMD         IFNE      '*VIEW   '
     C                   EXSR      SCR01I
     C                   END
     C                   GOTO      ENDSC1
     C                   END
      *
      *  Test for F12 - Previous
      *
     C     *INKL         IFEQ      *ON
     C     *LOVAL        SETLL     RECORD
     C                   MOVE      'EOJ'         NXTSCR
     C                   MOVE      '*CANCEL '    $PRTN
     C                   GOTO      ENDSC1
     C                   END
      *
      *  Test for other command keys BEFORE verification and update.
      *
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C                   exsr      zzpos
510 AC     repos         cabeq     *on           endsc1
      *
      *  Some other key pressed.
      *
      *     Check input and write/update record.
      *
     C     $PCMD         IFEQ      '*ADD    '
     C     $PCMD         OREQ      '*CHANGE '
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   EXSR      ZZUPD
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   END
      *
      *  Test for other command keys AFTER verification and update.
      *
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
      *
      *  Everything went fine so get out of program.
      *
     C                   MOVE      'EOJ'         NXTSCR
     C     ENDSC1        ENDSR
      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *INZSR        BEGSR
      *
      *  Initialize special keys
      *
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
      *
      *  Initialize message handling
      *
     C                   EXSR      ZMIMSG
      *
      *   Call user added initialization routine.
      *
     C                   EXSR      ZZINZ
     C                   ENDSR
      *---------------------------------------------------------------
      *
      *  SUBROUTINE ZMxxxx  Control message display subfile
      *
      *    ZMCMSG  Clear message record subfile
      *
     C     ZMCMSG        BEGSR
     C                   MOVE      *OFF          *IN97
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK              4 0
     C                   WRITE     MSGCLR
     C                   MOVE      '*CLEAR '     #MSGID            7
     C                   MOVE      '*NULL  '     #MSGTP            7
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *
      *    ZMDMSG  Display message record subfile
      *
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
     C     MSGK          IFGT      0
     C                   WRITE     MSGCTL
     C                   Z-ADD     *ZERO         MSGK
     C                   END
     C                   ENDSR
      *
      *    ZMIMSG  Initialization necessary for message subfile
      *
     C     ZMIMSG        BEGSR
     C                   MOVE      #PROG         #PGMQ            10
     C                   EXSR      ZMCMSG
     C                   ENDSR
      *
      *    ZMPMSG  Add message record to subfile
      *
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
      *
      *    ZMQMSG  Add message record to subfile from program queue
      *
     C     ZMQMSG        BEGSR
     C                   ADD       1             MSGK
     C                   WRITE     MSGREC
     C                   ENDSR
      *
      *    ZSCLR   Clear screen
      *
     C     ZSCLR         BEGSR
     C                   WRITE     CLRSCR
     C                   MOVE      *ON           SCLEAR            1
     C                   ENDSR
      *
      *    ZMSMSG  Send program message to a different program msgq
      *
     C     ZMSMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM      $PPRG         #PGMQ2           10
     C                   PARM                    #MSGK             4
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *      0105
      *
     C     ZM0105        BEGSR
     C                   MOVE      'PIR0105'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR7971  Error in writing a record.
      *
     C     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR7972  Error in updating a record.
      *
     C     ZM72          BEGSR
     C                   MOVE      'PIR7972'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *     PIR7973  Record does not exist.
      *
     C     ZM73          BEGSR
     C                   MOVE      'PIR7973'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   MOVE      #MSGK         $PMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *     PIR7974  Record is locked.
      *
     C     ZM74          BEGSR
     C                   MOVE      'PIR7974'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   MOVE      #MSGK         $PMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR9905  Cursor not in correct position for lookup.
      *
     C     ZM9905        BEGSR
     C                   MOVE      'PIR9905'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR1001  Invalid value entered.
      *
     C     ZM1001        BEGSR
     C                   MOVE      'PIR1001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR0112  Invalid range entered.
      *
     C     ZM0112        BEGSR
     C                   MOVE      'PIR0112'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *   PIR1005  Value must be 'Y' or 'N'
      *
     C     ZM1005        BEGSR
     C                   MOVE      'PIR1005'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZCHK1   Screen 1 error checking.
      *
     C     ZZCHK1        BEGSR
     C                   MOVE      *OFF          ERROR
      *
      *  Verify Number of days to keep Tax Rite export data.
      *
     C     W1TXHS        IFLT      1
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN01
     C                   MOVE      *BLANKS       ERRMSG
     C                   MOVEL     DESC(1)       ERFLD
     C                   MOVEL     '1'           ERFROM
     C                   MOVEL     '999'         ERTO
     C                   EXSR      ZM0112
     C                   ENDIF
      *
      *  Verify File Processing options.
      *
510 AC                   if        w1pcmd <> '*CREATE' and
510 AC                             w1pcmd <> '*SEND  ' and
510 AC                             w1pcmd <> '*NONE  '
510 AC                   MOVE      *ON           ERROR
510 AC                   MOVE      *ON           *IN22
510 AC                   MOVE      *ON           *IN02
510 AC                   MOVE      *BLANKS       ERRMSG
     C                   MOVEL     DESC(2)       ERFLD
510 AC                   EXSR      ZM1001
510 AC                   endif
      *
     C     ENDCK1        ENDSR
      *----------------------------------------------------------------
      *
      *  ZZCMD1   User defined command keys for screen 1.
      *
     C     ZZCMD1        BEGSR
      *
      *  Command keys to check BEFORE verification and update.
      *
     C     CMDCHK        IFEQ      '*BEFORE '
     C                   END
      *
      *  Command keys to check AFTER verification and update.
      *
     C     CMDCHK        IFEQ      '*AFTER  '
     C                   END
     C     ENDCM1        ENDSR
      *----------------------------------------------------------------
      *
      *  ZZDFT1   Get default values for add.
      *
     C     ZZDFT1        BEGSR
      *
     C                   Z-ADD     7             OPTXHS
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZFIL1   Fill screen 1 fields with info from file.
      *
     C     ZZFIL1        BEGSR
      *
     C                   Z-ADD     OPTXHS        W1TXHS
510 AC                   eval      w1pcmd = opcmd1
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZGET1   Get record(s) for screen 1.
      *
     C     ZZGET1        BEGSR
      *
     C                   eval      opwhse = whcode
     C                   eval      opcode = '*TAXR   '
      *
     C                   MOVE      *OFF          TMPFLG            1
      *
     C     BEGGT1        TAG
      *
      *   Get record from main file.
      *
     C     $PCMD         IFEQ      '*VIEW   '
     C     FILEKY        CHAIN(N)  RECORD                             7978
     C                   ELSE
     C     FILEKY        CHAIN     RECORD                             7978
     C                   ENDIF
      *
      *  Record locked.
      *
     C     *IN78         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      '*PGMQ   '    $PRTN
     C                   EXSR      ZM74
     C                   GOTO      ENDGT1
     C                   END
      *
      *  Record not found - Create it.
      *
     C     *IN79         IFEQ      *ON
     C     TMPFLG        IFEQ      *OFF
     C                   MOVE      *ON           TMPFLG
     C                   EXSR      ZZDFT1
     C                   WRITE     RECORD
     C                   GOTO      BEGGT1
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      '*PGMQ   '    $PRTN
     C                   EXSR      ZM73
     C                   GOTO      ENDGT1
     C                   END
     C                   END
      *
     C     ENDGT1        ENDSR
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.
      *
     C     ZZINZ         BEGSR
      *
      *  Define key for main file.
      *
     C     FILEKY        KLIST
     C                   KFLD                    OPWHSE
     C                   KFLD                    OPCODE
510 A*
510 a*      Get warehouse for user.
510 A*
510 AC                   eval      #whse = *zeros
510 AC                   call      'GETWHSE'
510 AC                   parm                    #user
510 AC                   parm                    #whse
510 AC                   eval      $pwhse = #whse
510 AC                   eval      whcode = #whse
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZINZ2   Program initialization. Called from main line.
      *
     C     ZZINZ2        BEGSR
      *
      *   Get and verify warehouse description.
      *
510 AC                   eval      whcode = $pwhse
510 AC                   if        whcode = *zeros
510 AC                   eval      whdesc = *blanks
     C     'All ware'    CAT       'houses':0    WHDESC
     C                   ELSE
     C                   MOVE      '*VERIFY '    $LCMD
     C                   MOVE      $PPRG         $LPRG
     C                   Z-ADD     WHCODE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*ERROR  '
     C     $LRTN         OREQ      '*PGMQ   '
     C                   MOVE      *ON           ERROR
     C                   MOVE      $LRTN         $PRTN
     C                   MOVE      $LERM         $PERM
     C                   GOTO      ENDIN2
     C                   ELSE
     C                   MOVEL     $LERM         WHDESC
     C                   END
     C                   END
      *
      *   Select first screen to display.
      *
     C                   MOVE      #PROG         $LPRG
     C                   EXSR      SCR01I
     C     ENDIN2        ENDSR
510 A *----------------------------------------------------------------
510 A *
510 A *  ZZPOS    Position to a different record.
510 A *
510 AC     zzpos         begsr
510 A *
510 AC                   eval      repos = *off
510 A *
510 A *  user is trying to change warehouse.  Verify warehouse entry.
510 A *
510 AC                   if        ptinp1 <> *zeros
510 AC                   eval      repos = *on
510 A *
510 AC                   eval      whcode = ptinp1
510 AC                   eval      whdesc = *blanks
510 AC                   eval      $lcmd = '*VERIFY '
510 AC                   eval      $lwhse = ptinp1
510 AC                   call      'WH900'
510 AC                   parm                    $lparm

510 AC                   select
510 AC                   when      $lrtn = '*ERROR  '
510 AC                   eval      error = *on
510 AC                   eval      *in23 = *on
510 AC                   eval      *in03 = *on
510 AC                   eval      errmsg = $lerm
510 AC                   exsr      zm0105

510 AC                   when      $lrtn = '*PGMQ   '
510 AC                   eval      error = *on
510 AC                   eval      *in23 = *on
510 AC                   eval      *in03 = *on
510 AC                   eval      #msgk = $lmsg
510 AC                   exsr      ZMQMSG

510 AC                   other
510 AC                   eval      whcode = ptinp1
     C                   eval      opwhse = ptinp1
510 AC                   eval      whdesc = $lerm
510 AC                   eval      ptinp1 = *zeros
510 AC                   exsr      zzget1
510 AC                   exsr      zzfil1
510 AC                   endsl
510 A *
510 AC                   endif
510 A *
510 AC     endzps        endsr
      *----------------------------------------------------------------
      *
      *  ZZUPD    Update record.
      *
     C     ZZUPD         BEGSR
     C                   MOVE      *OFF          ERROR
      *
      *  Move screen fields to record fields
      *
     C                   Z-ADD     W1TXHS        OPTXHS
510 AC                   eval      opcmd1 = w1pcmd
      *
      *   Update record (it was read and locked in ZZGET1)
      *
     C                   UPDATE    RECORD                               79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   EXSR      ZM72
     C                   GOTO      ENDUPD
     C                   END
      *
     C     ENDUPD        ENDSR
      *
      *----------------------------------------------------------------*********
      *
      *  COMPILE TIME TABLES
      *
**
Days to keep export data
Tax Rite processing code
