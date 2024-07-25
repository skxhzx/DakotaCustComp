      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  EQ480  RF Route Equipment - Load
     *         16 X 20 screens
     *
     *  20 April 2016
     *  Retha Davis
     *
     *  Revisions
     *
700 A*    04/20/16  RBD  7.00
     *      - Created.
     *
710 A*    02/03/17  RBD  7.10
     *      - Changed format name to EQ48001.
     *      - Fixed typo.
     *
710aA*    02/14/17  RBD  7.10a
     *      - Update unique equipment's last load record if not returned.
     *        If a unique equipment code is scanned look for a matching
     *        load record which has no return data populated, if you
     *        find one then update that load record's return data with
     *        the current timestamp and user SYSTEM to identify it as
     *        not having been scanned through one of the returns pgms.
     *        Note: a unique equipment code is one whose equipment
     *        type equals UNQ in positions 1 - 3.
     *
710bA*    05/01/17  RBD  7.10b
     *      - Add edit to ensure that the route scanned is current.
     *          1. If the current time is >= the route loading start
     *             time then only routes imported today at or after
     *             the start time are current.
     *          2. If the current time is <= the route loading end
     *             time then only routes imported today and routes
     *             imported yesterday at or after the route loading
     *             start time are current.
     *      - Add edits for unique equipment; throw error if the route id
     *        and unq code have already been scanned, or if the unq code
     *        has been scanned for another current route.
     *
710cA*    10/23/17  RBD  7.10c
     *      - Changed format name to EQ48002.
     *      - Added F1=Merge to override the error that the unique
     *        eq just scanned has already been scanned to this route.
     *      - Changed screen2 Fkey text from hardcoded to softcoded.
     *
     *----------------------------------------------------------------
CBIaA*  Client Custom Revisions: Cheney
     *
CBIaA*    07/27/17  RBD  CBIa
     *      - Equipment scanned must be equipment type 'UNQTOT'.
     *      - Don't allow F3 to exit pgm if nothing has been scanned.
     *
CBIbA*    10/16/17  RBD  CBIb
     *      - If cmd = *BYPASS1 (which will be sent by LOADR19) bypass
     *        display of screen1 and go straight to checking the input
     *        fields. And when the user presses F3 from screen2
     *        and cmd = *BYPASS1 return the user to LOADR19 without
     *        going back to screen1 first. When cmd = *BYPASS1 screen1
     *        will only be displayed if an error occurs.
     *      - Only disallow F3 when nothing scanned if this pgm was
     *        called by LOADR19. And move this logic to screen2 since
     *        they only use screen2 when called by LOADR19.
     *        Move eval of 'scanned' outside the select group.
     *      - Changed pZone to $pZone. Added parms cmd, pgm and route id.
     *      - Added equipment type 'MISC' to CBIa rev.
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
     F*
710 DF*EQ480FM   CF   E             WORKSTN
710cDF*EQ48001   CF   E             WORKSTN
710cMFEQ48002   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FEQUIP     IF   E           K DISK
     FPIRUSER   IF   E           K DISK
     FRTEEQUIP  UF A E           K DISK
710aAFrteequip1 uf   e           k disk    rename(reqrec:reqrec1)
     FRTEHED    IF   E           K DISK
     FOPTIONS   if   e           k disk
     Frteeqzon  if   e           k disk
     *----------------------------------------------------------------
     *  Client ID's
     *
CBIaA /copy qcopysrc,id#cheney
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  *LOADER  -  LOADER options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *    OPLDOR  -  Loading order (0=Any, 1=Standard,
     *               2=Row/Column, 3=Column
     *    OPTLID  -  Speak trailer id to user  (Y/N)
     *    OPRWCL  -  Speak row/column to user  (Y/N)
     *    OPVYPL  -  Verify pallet position on trailer (Y/N)
     *    OPVFYP  -  Verify pallet label against pick label.
     *    OPADDO  -  Auto define add-on routes Y/N.
     *    OPEQIP  -  Load Equip by zone Y/N.
     *    OPBYPL  -  Bypass entry of qty when loading equipment Y/N.
     *    OPBYPR  -  Bypass entry of qty when returning equipment Y/N.
     *
     * Data structure
     *
     D opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
     D  opldor                13     13
     D  optlid                14     14
     D  oprwcl                15     15
     D  opvypl                16     16
     D  opvfyp                17     17
     D  opaddo                18     18
     D  opeqip                19     19
     D  opbypl                20     20
     D  opbypr                21     21
     D  optend               117    117
     *
     *----------------------------------------------------------------
     D*  Table and array definitions
     D*
710bDD*desc            S             50    DIM(3) CTDATA PERRCD(1)
CBIaDD*desc            S             50    DIM(5) CTDATA PERRCD(1)
CBIaMD desc            S             50    DIM(7) CTDATA PERRCD(1)
     *----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     *----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D*                                   P   1   20ERWHSE
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
     D*  Called program parameters
     D*
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
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *
     D firstCnt        s               n
     D forevr          s              1
     D getOut          s              1
     D hdrctr          s              1  0
     d kyrtid          s                   like(rhrtid)
     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     d w1rtid5         s              5
710bAD curRoute        s              1
710bAD stime           s              6  0
710bAD etime           s              6  0
710bAD svrte           s              5
710bAD svrtid          s              5
CBIaAD scanned         s               n
710cAD ovrrid          s              1
710cAD sameRt          s              1
710cAD svW2eq          s                   like(w2eq)

     *----------------------------------------------------------------
     *  Program Parameters
     *----------------------------------------------------------------

CBIbAd  $pCmd          s              8
CBIbAd  $pPrg          s             10
CBIbMd  $pZone         s              6
CBIbAd  $pRtid         s              5

710bA*----------------------------------------------------------------
710bA*  Called program prototypes
710bA*----------------------------------------------------------------

710bAD getLoaRng       pr                  extpgm('GETLOARNG')
710bAD   pWhse                        3  0
710bAD   pStime                       6  0
710bAD   pEtime                       6  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
CBIbA*      $pCmd   *BYPASS1 - Bypass display of screen1 unless error.
CBIbA*      $pPrg   Calling program name
CBIbM*      $pZone  Truck zone
CBIbA*      $pRtid  Route Id
     *
     *    Returned Parameters
     *      None
     *

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
CBIbAC                   parm                    $pCmd
CBIbAC                   parm                    $pPrg
CBIbMC                   parm                    $pZone
CBIbAC                   parm                    $pRtid

     *----------------------------------------------------------------
     *  Main line
     *
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
CBIbAC                   if        client = cheney
CBIbAC                                  and $pCmd = '*BYPASS1'
CBIbAC                   eval      w1rtid = $pRtid
CBIbAC                   goto      skpdsp
CBIbAC                   endif
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
     C                   ELSE
     C                   MOVE      *ON           *IN09
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
     C                   ENDSL
     C*
CBIbAC     skpdsp        tag
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
     C                   SETOFF                                       24
     C                   SETOFF                                       29
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       9298
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   MOVE      *OFF          REDSPL            1
710cAC                   eval      w2Fkey = 'F3=Exit'
     C                   Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C*
CBIbAC                   if        $pcmd = '*BYPASS1'
CBIbAC                   eval      $pcmd = *blanks
CBIbAC                   endif
     *
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
     C                   MOVE      *OFF          *IN44
710cAC                   eval      samert = *off
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*  Screen 02 initialization
     C*----------------------------------------------------------------
     C*
     C     SCR02I        BEGSR
     C                   MOVE      '02 '         NXTSCR            3
     C                   EXSR      ZZFIL2
     C                   MOVE      *OFF          REFRSH
     C                   MOVE      *OFF          *IN44
     C     END02I        ENDSR
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
     C                   eval      w1rtid5 = w1rtid
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C
     C     DSPSCR2       IFEQ      '1'
     C                   EXSR      ZZUPD1
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   ELSE
     C                   EXSR      SCR02I
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
CBIbAC*  Test for F3 - Exit and specific client and pgm called by LOADR19
     C*
CBIaA /free
CBIaA
CBIbM   if *inkc = *on and client = cheney and $pPrg = 'LOADR19';
CBIbA
CBIaA   // Don't allow F3 if nothing scanned
CBIaA   // for specific client and this pgm called by LOADR19
CBIbA     if scanned = '0';
CBIaA       error = *on;
CBIaA       *in29 = *on;
CBIaA       *in09 = *on;
CBIaA       *in01 = *off;
CBIaA       errmsg = desc(7);
CBIaA       exsr zm0105;
CBIaA       leavesr;
CBIbA     else;
CBIbA       nxtscr = 'EOJ';
CBIbA       leavesr;
CBIaA     endif;
CBIbA
CBIbA   endif;
CBIbA
CBIaA /end-free
     C*
CBIbMC*  Test for F3 - Exit, no specific client and not called by LOADR19
     C*
     C     *INKC         IFEQ      *ON
     C                   EXSR      SCR01I
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
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK2
      *
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Redisplay screen to read in quantity
     C*
     *    Only redisplay screen for entering qty if bypass qty flag
     *    is not Y
     *
     C     *IN44         IFEQ      *OFF
     C     opbypl        andne     'Y'
     C                   MOVE      *ON           *IN44
     C                   MOVE      *ON           *IN23
     C                   GOTO      ENDSC2
     C                   ENDIF
      *
     C                   EXSR      ZZUPD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C                   EXSR      ZZFIL2
     C                   MOVE      *OFF          *IN44
     C*
     C                   if        *in12 = *on
     C                   exsr      zzfil1
     C                   endif
     C*
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
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
     *
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
      *
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
     C     #USER         CHAIN     PIRUSER
     C                   IF        not %found(piruser)
     C                   MOVE      *ON           ERROR
     C                   eval      *in09 = '1'
     C                   MOVEA     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C*
     C*  Verify route id
     C*
     C     rhkey         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      *in01 = *off
     C                   IF        ERRMSG =      *BLANKS
     C                   MOVEL     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
      *
710bA /free
710bA
710bA   // Verify the route is current
710bA   exsr zzChkRoute;
710bA
710bA   // Route is not current, throw an error
710bA   if curRoute = 'N';
710bA     error = *on;
710bA     *in29 = *on;
710bA     *in09 = *on;
710bA     *in01 = *off;
710bA     if errmsg = *blanks;
710bA       errmsg = desc(4);
710bA       exsr zm0105;
710bA       leavesr;
710bA     endif;
710bA   endif;
710bA
710bA /end-free

     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZCHK2   Screen 2 error checking.
     C*----------------------------------------------------------------
     C*
     C     ZZCHK2        BEGSR
     C*
     C                   eval      error = *off
     C                   eval      errmsg = *blanks
      *
710cA*  Skip equip verification if override was taken and they've
710cA*  scanned the same unique equip for the same route
710cAC                   if        ovrrid = *on and
710cAC                             w2eq = svW2eq and
710cAC                             sameRt = *on
710cAC                   eval      sameRt = *off
710cAC                   goto      endck2
710cAC                   endif
710cA
710cAC                   eval      svW2eq = w2eq
      *
      *  Validate equipment code
      *
     C     eqkey         chain     equip
     C                   if        not %found(equip)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0105
     C                   goto      endck2
     C                   endif
     C                   endif
710bA
710bA /free
CBIaA
CBIbM   // Verify equipment type is UNQTOT or MISC for specific client
CBIbM   if client = cheney and eqtype <> 'UNQTOT'
CBIbA               and eqtype <> 'MISC';
CBIaA     error = *on;
CBIaA     *in22 = *on;
CBIaA     *in01 = *on;
CBIaA     if errmsg = *blanks;
CBIaA       errmsg = desc(6);
CBIaA       exsr zm0105;
CBIaA       leavesr;
CBIaA     endif;
CBIaA   endif;
710bA
710bA   // Do some editing for unique equipment
710bA   if %subst(eqtype:1:3) = 'UNQ';

710bA     // Verify that this route/unq equip hasn't already been scanned
710bA     chain(n) (w1Whse: w1Rtid5: w2Eq) rteequip;
710bA     if %found;
710bA       error = *on;
710bA       *in22 = *on;
710bA       *in01 = *on;
710bA       if errmsg = *blanks;
710bA         errmsg = desc(5);
710cA         sameRt = *on;
710cA         w2Fkey = 'F1=Merge  F3=Exit';
710bA         exsr zm0105;
710bA         leavesr;
710bA       endif;
710bA     endif;

710bA     // Verify that this unique equip hasn't already been scanned
710bA     // to another current route
710bA     chain(n) (w1Whse: w2Eq: *blanks) rteequip1;
710bA     if %found;
710bA       // get rtehed for the route just found in rteequip
710bA       chain (w1Whse: reqrti) rtehed;
710bA       if %found;
710bA         exsr zzChkRoute;
710bA         svrte = rhrte;
710bA         svrtid = rhrtid;
710bA         // reset rtehed back to the scanned route id
710bA         chain (w1Whse: w1rtid5) rtehed;
710bA         // Route is current, throw an error
710bA         if curRoute = 'Y';
710bA           error = *on;
710bA           *in22 = *on;
710bA           *in01 = *on;
710bA           if errmsg = *blanks;
710bA             errmsg = %trim(eqcode) + ' on ' + %trim(svrte) +
710bA                      '/' + %trim(svrtid);
710bA             exsr zm0105;
710bA             leavesr;
710bA           endif;
710bA         endif;
710bA       endif;
710bA     endif;

710bA   endif;

710bA /end-free
     *
     C     endck2        endsr
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
710cA*  Test for F1=Merge - Accept Warning
710cA*
710cAC                   if        *inka
710cAC                   eval      ovrrid = *on
710cAC                   else
710cAC                   eval      ovrrid = *off
710cAC                   endif
     *
     C                   ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     C     CMDCHK        IFEQ      '*AFTER  '
     C*
     C                   ENDIF
     C*
     C     ENDCM2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL1        BEGSR
     C*
     C                   MOVE      *BLANKS       W1RTID
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*----------------------------------------------------------------
     C*
     C     ZZFIL2        BEGSR
     C*
     C                   eval      w2rte  = rhrte
     C                   EVAL      w2rtid = w1rtid
     C                   EVAL      w2eq   = *blanks
     C                   EVAL      w2qty  = 0
      *
     C     ENDFL2        ENDSR
     C*----------------------------------------------------------------
     C*  ZZGET1   Get . . .
     C*----------------------------------------------------------------
     C*
     C     ZZGET1        BEGSR
     *
     C     ENDGT1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     *
     *  Define key for RTEHED file
     *
     C     rhkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid5
     *
     *  Define key for EQUIP file
     *
     C     eqkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w2eq
     *
     *  Define key for RTEEQUIP file
     *
     C     rteeqkey      klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid5
     C                   kfld                    w2eq
      *
     *  Define key for OPTIONS file.

     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    opcode

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
     *
     *  If zone is passed in but is not found in RTEEQZON, just return,
     *  since it's not a zone they want to enter equipment for.
     *
      /free

CBIbM   if $pZone > ' ';
CBIbM     chain (w1Whse: $pZone) rteeqzon;
          if not %found;
            *inlr = *on;
            return;
          endif;
        endif;

710bA   // Get route loading start and end times
710bA   getloarng(w1whse: stime: etime);

      /end-free
     *
      *  Check if user id is found in user file.
      *
     C     #EMP#         IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVEA     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
      *
     *  Get loader options.
     C                   eval      opcode = '*LOADER'
     C     opkey         chain     options
     C                   if        not %found
     C                   eval      opbypl = 'N'
     C                   endif
     C*
     C                   EXSR      SCR01I
     C*
     C                   ENDSR
710aA *----------------------------------------------------------------
710aA *  zzUpdIfNotRet  Update load record if not previously returned
710aA *----------------------------------------------------------------
710aA
      /free
       begsr zzUpdIfNotRet;

         // Look for a route equipment record for this equipment code which
         // has NOT been returned and if found update return data
710cA    // AND it's not an F1=Merge (when F1=Merge you only want to update
710cA    // the 'changed' fields)

         setll (w1whse: w2eq) rteequip1;
         reade (w1whse: w2eq) rteequip1;

         if %eof(rteequip1) or reqradusr <> ' ';
           unlock rteequip1;
           leavesr;
         endif;

         reqradts = %timestamp;
         reqradusr = 'SYSTEM';
         reqradjob = #job;
         reqradnbr = #jobnbr;
         update reqrec1;
         unlock rteequip1;

       endsr;
      /end-free

710bAC*----------------------------------------------------------------
710bA *  zzChkRoute  Check to see if route is current or not
710bA *----------------------------------------------------------------
710bA
      /free
       begsr zzChkRoute;

         curRoute = 'N';

        // Route imported today after start time, it's current so get out
        if %dec(%time():*hms) >= stime and
          rhimpt >= stime and
          rhimpd = %dec(%date():*iso);
          curRoute = 'Y';
          leavesr;
        endif;

        // Route imported today before end time, it's current so get out
        if %dec(%time():*hms) <= etime and
          rhimpt <= etime and
          rhimpd = %dec(%date():*iso);
          curRoute = 'Y';
          leavesr;
        endif;

        // Route imported yesterday after start time, it's current so get out
        if %dec(%time():*hms) <= etime and
          rhimpt >= stime and
          rhimpd = %dec(%date()-%days(1));
          curRoute = 'Y';
          leavesr;
        endif;

       endsr;
      /end-free

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
     C     zzupd2        begsr
      *
     C                   eval      error = *off
      *
710aAC                   if        %subst(eqtype:1:3) = 'UNQ'
710cAC                             and *inka = *off
710aAC                   exsr      zzUpdIfNotRet
710aAC                   endif
      *
     C     rteeqkey      chain     rteequip
     C                   select

     C                   when      %found(rteequip)
     C                   eval      reqql  = w2qty
     C                   if        reqladjob = *blanks
     C                   eval      reqladts = %timestamp
     C                   eval      reqladusr = #user
     C                   eval      reqladjob = #job
     C                   eval      reqladnbr = #jobnbr
     C                   else
     C                   eval      reqlchts = %timestamp
     C                   eval      reqlchusr = #user
     C                   eval      reqlchjob = #job
     C                   eval      reqlchnbr = #jobnbr
     C                   endif
     C                   update    reqrec
710aAC                   unlock    rteequip

     C                   other
     C                   eval      reqwhs = w1whse
     C                   eval      reqrte = w2rte
     C                   eval      reqrti = w2rtid
     C                   eval      reqtrk = rhtruk
     C                   eval      reqcod = w2eq
     C                   eval      reqql  = w2qty
     C                   eval      reqqr  = 0
     C                   eval      reqladts = %timestamp
     C                   eval      reqladusr = #user
     C                   eval      reqladjob = #job
     C                   eval      reqladnbr = #jobnbr
     C                   eval      reqlchts = noStamp
     C                   eval      reqlchusr = *blanks
     C                   eval      reqlchjob = *blanks
     C                   eval      reqlchnbr = *blanks
     C                   eval      reqradts = noStamp
     C                   eval      reqradusr = *blanks
     C                   eval      reqradjob = *blanks
     C                   eval      reqradnbr = *blanks
     C                   eval      reqrchts = noStamp
     C                   eval      reqrchusr = *blanks
     C                   eval      reqrchjob = *blanks
     C                   eval      reqrchnbr = *blanks
     C                   write     reqrec

CBIbDC**                 if        client = cheney and scanned = '0'
CBIbDC**                 eval      scanned = '1'
CBIbDC**                 endif

     C                   endsl

CBIbAC                   if        client = cheney and scanned = '0'
CBIbAC                   eval      scanned = '1'
CBIbAC                   endif

     C     endupd2       endsr
     *----------------------------------------------------------------
     O*
     O*  COMPILE TIME TABLES
     O*
** DESC - Message
Invalid route #                                             1
Invalid equipment code                                      2
User not found                                              3
Route not current                                           4
Already scanned                                             5
Invalid equip type                                          6
Scan equip before F3                                        7
