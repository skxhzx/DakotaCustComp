     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LOADR19   RF Loader Module - Load Route.
     F*  April 2, 2007
     F*  Jose G. Duque
     F*
     F*  Notes
     F*      11 X 20 Screens for hand held scanners
     F*
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    06/25/09  RBD  5.20
     *      - Enh: Added client custom code support to program.
     *
530aA*    09/10/10  RBD  5.30a
     *      - Enh: increase label entry to 10 positions for Trax.
     *      - Changed scrn fmt to LOAD1901.
     *
650aA*    01/20/15  RBD  6.50a
     *      - Recompiled, LDRDETL file changed.
     *
700aA*    02/01/16  RBD  7.00a
     *      - Changed format from LOAD1901 to LOAD1902 because
     *        item fields on screens 2 and 3 were increased
     *        from 6 to 15. Jose originally had it defined as
     *        length 6, then later at 8 ... the length 8 change
     *        did not make it into Dakota and was keeping
     *        LOADR19 from creating flags because the item from
     *        the screen no longer matched the item in ldrpltq.
     *        So I went ahead and changed it to length 15 since
     *        Dakota allows 15.
     *      - Changed SAVITM length from 6 to 15.
     *
700bA*    09/06/16  RBD  7.00b
     *      - If new field *LOADER/OPEQIP is Y call Load Equip program.
     *
700cA*    01/12/17  RBD  7.00c
     *      - Added CHKLIST user authorization.
     *
710aA*    10/17/17  RBD  7.10a
     *      - Added parms cmd, pgm and route id to call to Load Eq pgm.
     *
720aA*    05/03/18  RBD  7.20a
     *      - When F7=Excp is selected and status of runner record = S
     *        change it to O.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    06/25/09  RBD  CBI
     *      - Coded large qty logic as specific to Cheney.
     *
CBIaA*    01/12/17  RBD  CBIa
     *      - Added CHKLIST user authorization for call to Load Equip pgm.
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
530aDF*LOAD19FM  CF   E             WORKSTN
700aDF*LOAD1901  CF   E             WORKSTN
700aMFLOAD1902  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FEQUIP     IF   E           K DISK
     FLDRHDR2   IF   E           K DISK
     F                                     RENAME(LHREC:LHREC2)
     FLABEL13   IF   E           K DISK
     F                                     RENAME(LBREC:LBREC2)
     FORDH1     IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FPIRUSER   IF   E           K DISK
     FRTEHED    IF   E           K DISK
     FRUNNER6   iF   E           K DISK
     F                                     RENAME(RUREC:RUREC2)
     FLABEL     UF   E           K DISK
     FLDRHDR    UF   E           K DISK
     FLDRDETL   UF   E           K DISK
     FLDRPLTQ   UF A E           K DISK
     FLDRPLTQ2  UF A E           K DISK
     F                                     RENAME(LPREC:LPREC2)
     FRUNNER    UF A E           K DISK
700bAFpltsum15  IF   E           K DISK
700bAFoptions   if   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(17) CTDATA PERRCD(1)
     *----------------------------------------------------------------
700cA /copy qcopysrc,p.chklist
     *----------------------------------------------------------------
520 A*  Client ID's
520 A*
CBI A /copy qcopysrc,id#cheney
520 A*
520 AD @getcl          c                   const('GETCLIENT')
     *
700bA*----------------------------------------------------------------
700bA*  *LOADER  -  Loader options
700bA*----------------------------------------------------------------
700bA*
700bA* Fields
     *
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *    OPLDOR  -  Loading order.
     *    OPTLID  -  Speak trailer id.
     *    OPRWCL  -  Speak row/column.
     *    OPVYPL  -  Verify pallet position.
     *    OPVFYP  -  Verify pallet label against pick label.
     *    OPADDO  -  Auto define add-on routes Y/N.
     *    OPEQIP  -  Load Equip by zone Y/N.
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
     D  ldrend               117    117
     *
     *----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
530aAD @cvtbarsel      c                   const('CVTBARSEL')
     D*----------------------------------------------------------------
     D route           c                   const('Route ')
     D loaded          c                   const('loaded')
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
700bA*----------------------------------------------------------------
700bA*  Prototypes
700bA*----------------------------------------------------------------

700bAD eq480           pr                  extpgm('EQ480')
710aAD   pCommand                     8
710aAD   pProg                       10
700bAD   pZone                        5
710aAD   pPrtid                       5

     *----------------------------------------------------------------
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
     D*
     D*
     D*----------------------------------------------------------------
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
     D*----------------------------------------------------------------
     D* Work fields
     I*----------------------------------------------------------------
500dAD  Currstamp      s               z
     D  Label#         s              7  0
     D  Pckqty         s              5  0
     I*----------------------------------------------------------------
530aA *  Variables
      *
530aAD w1lbl#          s              7  0
700cAD chklistrtn      s             10
700cAD chklistopt      s             20
710aAD pCmd            s              8
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $WHSE  Warehouse
     C*      $RTE#  Route number
     C*      $RTEID Route Id
     C*      $PLT#  Pallet number
     C*      $DOOR# Door number
     C*
     C*
     C*    Returned Parameters
     C*      $RTNCD
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*----------------------------------------------------------------
      *
     C     *ENTRY        PLIST
     C                   PARM                    $WHSE             3
     C                   PARM                    $RTE#             5
     C                   PARM                    $RTEID            5
     C                   PARM                    $PLT#             5
     C                   PARM                    $DOOR#            2
     C                   PARM                    $PCS#             5
     C                   PARM                    $RTNCD            8
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
     C*>   NXTSCR        CASEQ     '02 '         SC2
     C*>   NXTSCR        CASEQ     '03 '         SC3
     C                   ENDCS
     C                   ENDDO
     C*
700bA*  If Load Equip by zone option = Y call the Load Equip pgm
700bAC                   if        opeqip = 'Y'
700bAC                   exsr      loadeq
700bAC                   endif
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
     C*>                 when      nxtscr = '02 '
     C*>                 EXFMT     SCREEN2                              50
     C*
     C*>                 when      nxtscr = '03 '
     C*>                 EXFMT     SCREEN3                              50
     C*
     C                   ENDSL
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
     C                   SETOFF                                       2426
     C                   SETOFF                                       272829
     C                   SETOFF                                       303132
     C                   SETOFF                                       333435
     C                   SETOFF                                       363738
     C                   SETOFF                                       3940
     C                   SETOFF                                       909298
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   MOVE      *OFF          CMDTKN            1
     C                   MOVE      *OFF          REDSPL            1
     C                   MOVE      *OFF          LABLIN            1
     C                   MOVE      *OFF          ITEMIN            1
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
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*  GETUT    Get AS/400 User Id and current time.
     C*----------------------------------------------------------------
     C*
     C     GETUT         BEGSR
      *
      *  Create Ldrpltq flag records for large qty label
      *
     C*  Move ending loading date and time into Ldrpltq file
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LPSTRD
     C                   Z-ADD     $CVD8O        LPENDD
     C*
     C                   TIME                    LPSTRT
     C                   TIME                    LPENDT
      *
      *  Get loader emp#
      *
     C     #USER         CHAIN     PIRUSER                            77
     C     *IN77         IFEQ      *OFF
     C                   Z-ADD     USEMP#        LPEMP#
     C                   ENDIF
     C*
     C*
     C     ENDUT         ENDSR
     C*----------------------------------------------------------------
     C*  LRGQTY   Process selector large qty label flag(s).
     C*----------------------------------------------------------------
     C*
     C     LRGQTY        BEGSR
      *
     C                   Z-ADD     *ZEROS        SCNQTY            5 0
      *
      *  Update qty bucket on a flagged large qty label.
      *  and create Ldrpltq flag record for large qty label.
      *
     C                   EXSR      GETUT
      *
      *  Update Ldrpltq qty bucket.
     C                   EVAL      SCNQTY = LPQTY - W3QTY
     C                   EVAL      LPSCNQ = SCNQTY
     C                   EVAL      LPSTAT = 'C'
     C                   UPDATE    LPREC2
      *
      *  Create Ldrpltq flag record.
     C                   EVAL      LPQTY = W3QTY
     C                   EVAL      LPSCNQ = *ZEROS
     C                   EVAL      LPSEQ  = LPSEQ + 1
     C                   EVAL      LPSTAT = 'F'
     C                   WRITE     LPREC2
     C*
     C                   EVAL      UPDYES = '1'
     C*
     C     ENDLQ         ENDSR
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
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for F6 - Show items remaining to be scanned.
     C*
     C     *INKF         IFEQ      *ON
     C                   EXSR      ZZREM
     C     UPDYES        IFEQ      *ON
     C*
     C*  Flag exception processed, clear Screen1 input fields.
     C                   EVAL      W1LBL# = *ZEROS
     C                   EVAL      W1ITM# = *BLANKS
     C                   EVAL      W1QTY  = *ZEROS
     C                   ENDIF
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
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
      *
     C                   EXSR      ZZUPD1
     C     ERROR         CABEQ     *ON           ENDSC1
     C*
     C     W1LBL#        IFNE      *ZEROS
     C                   MOVE      *ON           *IN25
     C                   ENDIF
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C                   EXSR      ZZFIL1
     C*
     C*
     C*  Check if all items in merged pallet were scanned
     C*
     C     W1ITMC        IFEQ      *ZEROS
     C                   MOVE      '*OK     '    $RTNCD
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
     C
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
520 A*
520 A*  Get Client ID
     *
520 AC                   call      @getcl
520 AC                   parm                    client           10
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
     C     ZM2003        begsr
     C                   eval      #msgid = 'EQ52003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   EQ52004  Equipment status not valid.
     *
     C     ZM2004        begsr
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
     C                   MOVE      *OFF          FLGLBL            1
     C                   Z-ADD     *ZEROS        FLAGLB            7 0
     C                   Z-ADD     *ZEROS        SAVLBL            7 0
      *
530aA*  Scanned field may be label# or it may be route id/Trax#.
530aA*  CVTBARSEL converts it from route id/Trax# to label#.
530aAC                   if        w1lbl#b <> *blanks
530aAC                   move      $whse         $bwhseb
530aAC                   movel     w1lbl#b       $bbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $bwhseb           3
530aAC                   parm                    $bbarcode        15
530aAC                   parm                    $blbl#            7 0
530aAC                   parm                    $brtid            5
530aAC                   parm                    $bunq#            5
530aAC                   parm                    $breturn          8
530aAC                   parm                    $berrmsg         60
530aAC                   if        $breturn = '*OK'
530aAC                   eval      w1lbl# = $blbl#
530aAC                   move      *blanks       w1lbl#b
530aAC                   move      $blbl#        w1lbl#b
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      *in22 = *on
530aAC                   movel     desc(4)       errmsg
530aAC                   exsr      zm0110
530aAC                   endif
530aAC                   endif
      *
     C     W1LBL#        IFEQ      *ZEROS
     C     W1ITM#        ANDEQ     *BLANKS
     C     W1LBL#        ANDEQ     *ZEROS
     C     W1QTY         ANDEQ     *ZEROS
      *  Invalid input.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN23
     C                   MOVE      *ON           *IN24
     C                   MOVEL     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *
     C     W1LBL#        IFNE      *ZEROS
     C     W1ITM#        ANDNE     *BLANKS
     C     W1LBL#        ORNE      *ZEROS
     C     W1QTY         ANDNE     *ZEROS
      *  Label or item not both
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           FLGLBL
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN23
     C                   MOVEL     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *
      *----------> Processing (scaning) label #. <-------------*
      *
     C     W1LBL#        IFNE      *ZEROS
     C                   Z-ADD     W1LBL#        LBLBL#
     C                   Z-ADD     W1LBL#        SAVLBL
      *
      *
     C     PLTQKY        SETLL     LDRPLTQ
     C     PLTQKY        READE     LDRPLTQ                                79
     C                   IF        *IN79
      *  Invalid label #.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVEL     DESC(4)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
     C                   MOVE      *OFF          LABLIN
     C                   Z-ADD     *ZEROS        SELFLG            3 0
      *
      *  Verify if item being scanned is a selector flagged item
      *  and if it has been accounted for as such by the loader.
     C                   DOW       *IN79 = *OFF
     C     LPSTAT        IFEQ      'F'
     C                   ADD       1             SELFLG
     C                   ENDIF
     C     LPSCNQ        IFNE      LPQTY
     C     LPSTAT        ANDEQ     *BLANK
     C                   MOVE      *ON           LABLIN
     C                   LEAVE
     c                   ENDIF
     C     PLTQKY        READE     LDRPLTQ                                79
     C                   ENDDO
      *
     C     LABLIN        IFEQ      *OFF
      *  Label already scanned.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   MOVEL     DESC(6)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *----------------------- FROM HERE 7/16/07 ---------------------------
     C     RN6KEY        CHAIN     RUNNER6                            78
     C                   IF        NOT*IN78
      *
      *  Verify if flag is open.
     C                   EXSR      ZZVFY1
      *
     C                   IF        NOFL   = *ON
      *  Flag is closed.
     C                   UNLOCK    LDRPLTQ2
     C                   GOTO      NOFLG
     C                   ENDIF
      *
      *  Flag is open.
     C                   Z-ADD     W1LBL#        FLAGLB
      *
     C     DSPMSG        TAG
      *----------------------- TO   HERE 7/16/07 ---------------------------
      *  This label has been flagged by a selector and
      *  can not be scanned using label#, scan thru item#
      *  if flagged qty <> number of pieces to pick
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   IF        RUTYPE = 'U'
     C                   MOVEL     DESC(16)      ERRMSG
     C                   ELSE
     C                   MOVEL     DESC(14)      ERRMSG
     C                   ENDIF
     C                   EXSR      ZM0105
     C                   UNLOCK    LDRPLTQ
     C                   GOTO      ENDCK1
      *
     C                   ENDIF
      *
     C     NOFLG         TAG
      *
     C
      *  End for stmt 'W1lbl# IfNe *Zeros' above   <------*
     C                   ENDIF
      *
      *
      *------------> Processing thru item # <------------*
      *
     C     W1ITM#        IFNE      *BLANKS
     C     W1QTY         ANDEQ     *ZEROS
      *  Invalid item qty.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   MOVEL     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
     C     W1ITM#        IFNE      *BLANKS
      *
     C                   Z-ADD     *ZEROS        ITMPCS            5 0
     C                   MOVEL     W1ITM#        ITEM#            15
     C                   Z-ADD     *ZEROS        RECSEQ
      *
     C     PLTQK2        SETLL     LDRPLTQ2
     C     PLTQK2        READE     LDRPLTQ2                               79
     C                   IF        *IN79
      *  Invalid item #.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   MOVEL     DESC(5)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ELSE
     C*>8/06/07          Z-ADD     LPLBL#        SAVLBL
     C*>8/06/07          Z-ADD     LPSEQ         RECSEQ
     C                   ENDIF
      *
     C                   MOVE      *OFF          ITEMIN
     C                   Z-ADD     *ZEROS        SELFLG
      *
      *
     C                   DOW       *IN79 = *OFF
      *
     C     LPSTAT        IFEQ      'F'
     C                   ADD       1             SELFLG
     C                   ENDIF
      *
     C     LPSCNQ        IFNE      LPQTY
     C     LPSTAT        ANDEQ     *BLANK
     C                   ADD       LPQTY         ITMPCS
     C                   MOVE      *ON           ITEMIN
     C     SAVLBL        IFEQ      *ZEROS
     C                   Z-ADD     LPLBL#        SAVLBL
     C                   Z-ADD     LPSEQ         RECSEQ
     C                   ENDIF
     C                   ENDIF
     C     PLTQK2        READE     LDRPLTQ2                               79
     C                   ENDDO
      *
     C     ITEMIN        IFEQ      *OFF
      *  Item already scanned.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   MOVEL     DESC(7)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *
      *
      *----------------------- FROM HERE 7/19/07 ---------------------------
     C     RN6KEY        CHAIN     RUNNER6                            78
     C                   IF        *IN78
     C                   GOTO      NOFLG2
     C                   ENDIF
      *
     C                   IF        NOT*IN78
      *
      *  Verify if flag is open.
     C                   EXSR      ZZVFY1
      *
     C                   IF        NOFL   = *ON
      *  Flag is closed.
     C                   UNLOCK    LDRPLTQ2
     C                   GOTO      NOFLG2
     C                   ENDIF
      *
      *  Flag is open.
     C                   Z-ADD     W1LBL#        FLAGLB
      *
     C     DSPMSG2       TAG
      *----------------------- TO   HERE 7/19/07 ---------------------------
      *  This item has been flagged by a selector and can not
      *  be processed using item #. Create exception rec and scan
      *  the rest if flagged qty <> number of pieces to pick
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   IF        RUTYPE = 'U'
     C                   MOVEL     DESC(16)      ERRMSG
     C                   ELSE
     C                   MOVEL     DESC(14)      ERRMSG
     C                   ENDIF
     C                   EXSR      ZM0105
     C                   UNLOCK    LDRPLTQ2
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *
      *
     C     ITMPCS        IFEQ      RUQYSO
     C     ITMPCS        ANDEQ     LPSCNQ
     C     ITMPCS        OREQ      *ZEROS
      *  Item already scanned.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   MOVEL     DESC(7)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
      *  Invalid qty.
     C     ITMPCS        IFGT      RUQYSO
     C     ITMPCS        SUB       RUQYSO        FLG2SC            5 0
     C     W1QTY         IFNE      FLG2SC
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   MOVEL     DESC(12)      ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
      *
     C     NOFLG2        TAG
      *
     C     PLTQK3        CHAIN     LDRPLTQ2                           79
      *
     C     W1QTY         IFNE      LPQTY
      *  Invalid item qty.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   MOVEL     DESC(3)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Move starting loading date and time into Ldrpltq file
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LPSTRD
     C*
     C                   TIME                    HLDSTT            6 0
      *
      *
     C     ENDCK1        TAG
     C     ERROR         IFEQ      *ON
     C     *IN14         ANDEQ     *OFF
     C*---->To stop item count from going to zero when invalid input.
     C*---->             MOVE      *ON           *IN21
     C                   ENDIF
      *
     C                   ENDSR
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
     C*  ZZEXCP   Process exception screen and create record.
     C*----------------------------------------------------------------
      *
     C     ZZEXCP        BEGSR
      *
     C                   MOVE      W2RTE#        W3RTE#
     C                   MOVE      W2DOOR        W3DOOR
     C                   MOVE      *BLANK        W3CODE
     C                   MOVE      *BLANK        W3FLAG
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *OFF          SCRN2             1
     C                   MOVE      *OFF          UPDYES            1
     C                   MOVE      *BLANKS       ERRMSG
     C                   Z-ADD     *ZEROS        W3QTY
     C                   Z-ADD     *ZEROS        QTYCNT            5 0
     C                   Z-ADD     *ZEROS        LABEL#            7 0
     C                   Z-ADD     *ZEROS        HLDLRG            5 0
     C                   Z-ADD     W2PLT#        W3PLT#
     C                   Z-ADD     W2ITMC        W3ITMC
     C                   SETOFF                                       082728
     C                   SETOFF                                       90
      *
      *   Initialize error subfile
     C                   EXSR      ZMCMSG
      *
     C*
     C*  Check if processing selector generated flag.
     C                   IF        W2FLGQ <> *ZEROS
     C                   EVAL      W3FLAG =  'F'
     C                   EVAL      W3QTY  =  W2FLGQ
     C                   SETON                                        0890
     C                   ENDIF
      *
     C                   IF        NOFL   = *ON AND
     C                             SELFLG = *ZEROS AND
     C                             STATD  = *OFF
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
      *   *in90 protects flag type and qty fields from any input
      *   on "Exception" screen.
     C*-it has not being MOVE      *ON           *IN90 *-used 8/14/07
      *   Flag qty found by flag runner
     C                   MOVEL     DESC(17)      ERRMSG
     C                   EXSR      ZM0105
      *   Overlay screen with informative message.
     C                   EXSR      ZMDMSG
     C                   ENDIF
      *
     C                   EXFMT     SCREEN3
      *
     C                   IF        ERROR = *ON
      *   Initialize error subfile
     C                   EXSR      ZMCMSG
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   ENDIF
      *
      *
     C     AGAIN         TAG
      *
      *  Test for F3 - Exit
      *
     C     *INKC         IFEQ      *ON
      *  Signal back to display screen 2
     C                   MOVE      *ON           SCRN2
     C                   MOVE      *OFF          *IN90
     C                   GOTO      ENDEXC
     C                   ENDIF
      *
     C     W3CODE        IFNE      'M'
     C     W3CODE        ANDNE     'S'
     C     *IN08         ANDNE     *ON
      *  Invalid code.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN27
     C                   MOVEL     DESC(11)      ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
      *
      *
     C     W3QTY         IFLE      *ZEROS
     C     W3QTY         ORGT      W2QTY
      *  Invalid qty.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN28
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEL     DESC(12)      ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
      *
     C     ERROR         IFEQ      *ON
      *
      *   Overlay screen with error messages.
     C                   EXSR      ZMDMSG
     C                   EXFMT     SCREEN3
      *
      *   Initialize error subfile
     C                   EXSR      ZMCMSG
      *
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *BLANKS       ERRMSG
     C                   SETOFF                                       2728
     C                   GOTO      AGAIN
     C                   ENDIF
      *
      *   Update merged items work file 'Ldrpltq'.
      *   Move current item# to 'Pltqk2' key member.
      *
     C                   EVAL      ITEM# = W2ITM#
      *
     C     PLTQK2        SETLL     LDRPLTQ2
     C     PLTQK2        READE     LDRPLTQ2                               78
      *
     C     *IN78         DOWEQ     *OFF
     C     QTYCNT        ANDLT     W3QTY
      *
     C     LPSTAT        IFEQ      *BLANK
     C     W2FLGQ        IFEQ      *ZEROS
     C*
     C*  Loader generated flag.
     C                   EVAL      LPSTAT = W3CODE
     C                   ELSE
     C*  Selector generated flag.
     C     LPQTY         IFGE      16
CBI AC     client        andeq     cheney
     C*  Large qty label.
     C                   Z-ADD     LPQTY         HLDLRG            5 0
     C                   EXSR      LRGQTY
     C                   LEAVE
     C                   ELSE
     C*  Single case label.
     C                   EVAL      LPSTAT = W3FLAG
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Get user emp# and loading date and time info into Ldrpltq.
     C                   EXSR      GETUT
      *
      *
      *  Update Pallet qty file 'Ldrpltq'.
     C                   UPDATE    LPREC2
      *
     C                   EVAL      QTYCNT = QTYCNT + 1
     C                   EVAL      LABEL# = LPLBL#
     C                   EVAL      UPDYES = '1'
     C                   ENDIF
      *
     C     PLTQK2        READE     LDRPLTQ2                               78
     C                   ENDDO
     C*
     C                   UNLOCK    LDRPLTQ2
      *
720aA *   If runner is at status S change it to O
720aA
720aAc                   if        rustat = 'S'
720aAc     kyrunner      chain     runner
720aAc                   if        %found(runner)
720aAc                   eval      rustat = 'O'
720aAc                   update    rurec
720aAc                   unlock    runner
720aAc                   endif
720aAc                   endif
720aA
      *   Adjust screen 2 item count value.
     C     HLDLRG        IFGE      16
CBI AC     client        andeq     cheney
     C                   EVAL      W2ITMC = W2ITMC - HLDLRG
     C                   EVAL      W2QTY  = W2QTY  - HLDLRG
     C                   ELSE
     C                   EVAL      W2ITMC = W2ITMC - W3QTY
     C                   EVAL      W2QTY  = W2QTY  - W3QTY
     C                   ENDIF
      *
     C                   IF        W2ITMC = *ZEROS
      *
      *   Then, this flagged item was the last one in the
      *   item count list, therefore, control should be sent
      *   back to calling pgm 'Loadr9'.
      *
     C                   EVAL      W1ITMC = W2ITMC
     C                   MOVE      '*OK     '    $RTNCD
     C                   MOVE      'EOJ'         NXTSCR
     C                   ELSE
     C                   MOVE      *ON           SCRN2
     C                   ENDIF
     C*
     C     W2FLGQ        IFNE      *ZEROS
     C                   Z-ADD     *ZEROS        W2FLGQ
     C                   MOVE      *BLANK        LETTRF
     C                   SETOFF                                       0990
     C                   GOTO      ENDEXC
     C                   ENDIF
      *
      *
      *   Exit this routine if this is a selector initiaded flag.
      *   Label rec update and creation of flag record are already done.
      *
     C                   IF        W3FLAG =  'F'
     C                   GOTO      ENDEXC
     C                   ENDIF
      *
      *   Update label rec and Load runner file with new flag rec.
      *
     C     LABEL#        CHAIN     LABEL                              78
     C     *IN78         IFEQ      *OFF
     C                   EVAL      LBVRFY = 'F'
     C                   UPDATE    LBREC
      *
     C                   EVAL      HLDSTA = *BLANK
     C                   EVAL      HLDTYP = *BLANK
      *
     C     KEYRU         CHAIN     RUNNER                             78
     C                   IF        *IN78  OR
     C                             NOT*IN78 AND
     C                             RUSTAT = 'D'
      *
     C                   EVAL      HLDSTA = RUSTAT
     C                   EVAL      HLDTYP = RUTYPE
      *
     C                   CLEAR                   RUREC
     C                   EVAL      RUWHSE = LBWHSE
     C                   EVAL      RULBL# = LBLBL#
     C                   EVAL      RUQYSO = W3QTY
     C                   EVAL      RUOQYS = RUQYSO
     C                   EVAL      RUOTRN = LBTRN#
     C                   EVAL      RUDISP = LBDISP
     C                   EVAL      RUSTAT = 'O'
      *
     C                   IF        HLDSTA <> 'D'
     C                   EVAL      RUTYPE = 'M'
     C                   GOTO      GETITM
     C                   ENDIF
      *
      *   If "Rustat" is equal to "D", it means that a flag for this
      *   label was created and deleted at some time (reason not known
      *   at this point), at the same time the loader is missing a case
      *   under this label# and a flag rec needs to be created in Runner,
      *   so in order to avoid "dup rec" condition, the flag type has to
      *   be changed to account for this loader created short case flag.
      *
     C                   IF        HLDTYP = 'U'
     C                   EVAL      RUTYPE = 'M'
     C                   ENDIF
      *
     C                   IF        HLDTYP = 'N'
     C                   EVAL      RUTYPE = 'M'
     C                   ENDIF
      *
     C                   IF        HLDTYP = 'M'
     C                   EVAL      RUTYPE = 'U'
     C                   ENDIF
      *
      *
     C     GETITM        TAG
     C     ITMKY1        CHAIN     PIRITEM                            78
     C                   IF        *IN78  = *OFF
     C                   EVAL      RUWHDP = ITWHDP
     C                   ENDIF
      *
     C                   TIME                    CURRSTAMP
     C                   EVAL      RUODTS = CURRSTAMP
     C                   WRITE     RUREC
     C                   ELSE
     C                   UNLOCK    RUNNER
     C                   ENDIF
     C                   ENDIF
      *
      *
     C     ENDEXC        ENDSR
     C*----------------------------------------------------------------
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*----------------------------------------------------------------
      *
     C     ZZFIL1        BEGSR
      *
     C                   SETON                                        25
     C                   EVAL      W1LBL# = *ZEROS
     C                   EVAL      W1ITM# = *BLANKS
     C                   EVAL      W1ITMC = *ZEROS
     C                   EVAL      W1ITC2 = *ZERO
     C                   EVAL      W1QTY  = *ZEROS
     C                   Z-ADD     *ZEROS        W1LBL#
      *
      *
      *  Find how many cases in this pallet and calc how many
      *  cases have been scanned.
      *
     C                   EVAL      W1ITMC = PCS#
     C     LBLKY1        SETLL     LABEL13
     C     LBLKY1        READE     LABEL13                                79
      *
     C                   DOW       *IN79 = *OFF
     C     LBTYPE        IFEQ      'R'
     C     LBTYPE        OREQ      'A'
      *  Skip this rec, it is a repl or adjustment
      *  rec for Route/Pallet/Item being loadedd.
     C                   GOTO      READL
     C                   ENDIF
      *
     C                   Z-ADD     *ZEROS        CASES             3 0
      *
     C     PLTQKY        SETLL     LDRPLTQ
     C     PLTQKY        READE     LDRPLTQ                                78
      *
     C     *IN78         IFEQ      *ON
     C                   Z-ADD     1             SEQ#              3 0
      *
      *  Label not found in pallet qty file, load it up.
      *  Write as many recs as cases to be picked for this label.
     C                   DOW       CASES < LBQALC
      *
     C                   EVAL      LPWHSE = LBWHSE
     C                   EVAL      LPRTE  = $RTE#
     C                   EVAL      LPRTID = $RTEID
     C                   EVAL      LPPLID = LBPAL#
     C                   EVAL      LPITEM = LBITEM
     C                   EVAL      LPSEQ  = SEQ#
     C                   EVAL      LPSTOP = LBSTOP
     C                   EVAL      LPLBL# = LBLBL#
     C                   EVAL      LPSCNQ = *ZEROS
      *
     C     ITMKY1        CHAIN     PIRITEM                            78
     C     *IN78         IFEQ      *OFF
     C                   EVAL      LPDESC = ITDESC
     C                   EVAL      LPPKD  = ITPDSC
     C                   ELSE
     C                   EVAL      LPDESC = *BLANKS
     C                   EVAL      LPPKD  = *BLANKS
     C                   ENDIF
      *
     C                   EVAL      SEQ# = SEQ# + 1
     C     LBQALC        IFLT      16
CBI AC     client        andeq     cheney
     C                   EVAL      CASES = CASES + 1
     C                   EVAL      LPQTY  = 1
     C                   ELSE
      *
      *  Large qty label.
     C                   EVAL      LPQTY  = LBQALC
     C                   EVAL      CASES  = LBQALC
     C                   ENDIF
      *
     C                   WRITE     LPREC
     C                   ENDDO
     C                   GOTO      READL
     C                   ENDIF
      *
      *
      *  The loop below calcs the number of items remaining, in the
      *  pallet being scanned by loader. This logic is activated
      *  if the current label info from 'Label13' file is already
      *  loaded into 'Ldrpltq' file.
      *
     C                   DOW       *IN78  = *OFF
      *
     C     LPSTAT        IFNE      *BLANK
     C     LPSCNQ        IFEQ      *ZEROS
      *
      *  Calc item qty, rec status is an exception.
     C                   EVAL      W1ITMC = W1ITMC - LPQTY
     C                   ELSE
      *
      *  Calc item qty rec status is closed.
     C                   EVAL      W1ITMC = W1ITMC - LPSCNQ
     C                   ENDIF
     C                   ENDIF
      *
     C     PLTQKY        READE     LDRPLTQ                                78
     C                   ENDDO
      *
      *
     C     READL         TAG
     C     LBLKY1        READE     LABEL13                                79
     C                   ENDDO
      *
     C     W1ITMC        IFEQ      *ZEROS
     C                   SETON                                        21
     C                   ENDIF
      *
      *
     C     ENDFL3        ENDSR
     C*----------------------------------------------------------------
     C*  ZZGET1   Get . . .
     C*----------------------------------------------------------------
     C*
     C     ZZGET1        BEGSR
     *
      *
     C     ENDGT1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      $WHSE         WHSE              3 0
     C                   MOVE      $PLT#         PLT#              7 0
     C                   MOVE      $PCS#         PCS#              5 0
     C                   EVAL      W1RTE# = $RTE#
     C                   EVAL      W1DOOR = $DOOR#
     C                   EVAL      W1PLT# = PLT#
     C                   EVAL      W2PLT# = PLT#
     C                   EVAL      W3PLT# = PLT#
     C                   MOVE      *BLANKS       $RTNCD
     C                   MOVE      'M'           TYPE              1
     C                   Z-ADD     *ZEROS        RECSEQ            5 0
     *
     *  Define key for main file.
     *
     C     LBLKY1        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    $RTEID
     C                   KFLD                    PLT#
      *
     C     PLTQKY        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    $RTE#
     C                   KFLD                    $RTEID
     C                   KFLD                    PLT#
     C                   KFLD                    LBLBL#
     C*>To be used later KFLD                    RECSEQ
      *
     C     PLTQK2        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    $RTE#
     C                   KFLD                    $RTEID
     C                   KFLD                    PLT#
     C                   KFLD                    ITEM#
     C*>8/6/07           KFLD                    SAVLBL
     C*>To be used later KFLD                    RECSEQ
      *
     C     PLTQK3        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    $RTE#
     C                   KFLD                    $RTEID
     C                   KFLD                    PLT#
     C                   KFLD                    ITEM#
     C                   KFLD                    SAVLBL
     C                   KFLD                    RECSEQ
      *
     C     ITMKY1        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    LBITEM
      *
     C     DTKEY3        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    W1RTE#
     C                   KFLD                    LBRTE
     C                   KFLD                    LBPAL#
    A*
    A*  Define full key for RUNNER file.
    A*
    AC     KEYRU         KLIST
    AC                   KFLD                    LPWHSE
    AC                   KFLD                    TYPE
    AC                   KFLD                    LPLBL#
720aA*
720aA*  Define full key for RUNNER file.
720aA*
720aAc     kyrunner      klist
720aAc                   kfld                    whse
720aAc                   kfld                    rutype
720aAc                   kfld                    rulbl#
      *
      *    Runner6 key
     C     RN6KEY        KLIST
     C                   KFLD                    WHSE
     C                   KFLD                    SAVLBL
      *
700bA*  Define key for OPTIONS file.
700bA
700bAC     opkey         klist
700bAC                   kfld                    whse
700bAC                   kfld                    opcode
700bA*
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZINZ2   Program initialization. Called from main line.
     C*----------------------------------------------------------------
     C*
     C     ZZINZ2        BEGSR
     C*
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
      *
      *  Check if user id is found in user file.
      *
     C     #EMP#         IFEQ      *ZEROS
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN02
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C*
700bA*  Get loader options.
700bA
700bAC                   eval      opcode = '*LOADER'
700bAC     opkey         chain     options
     C*
     C                   EXSR      SCR01I
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*----------------------------------------------------------------
     C*
     C     ZZREM         BEGSR
     C*
     C*
     C                   Z-ADD     W1LBL#        FLAGLB
     C                   MOVEL     W1ITMC        W2ITMC
     C     TOP           TAG
     C                   MOVEL     W1RTE#        W2RTE#
     C                   MOVEL     W1DOOR        W2DOOR
     C                   MOVEL     W1RTE#        W2RTE#
     C                   Z-ADD     1             ONE               2 0
     C                   MOVE      *BLANKS       PRTN              5
     C                   MOVE      *BLANK        LETTRF            1
      *
      *   Begin reading scanned pallet info file.
      *
     C     DTKEY3        SETLL     LDRPLTQ
     C     ONEMORE       TAG
     C     DTKEY3        READE     LDRPLTQ                                79
     C     *IN79         IFEQ      *OFF
     C     LPLBL#        IFNE      FLAGLB
     C     FLAGLB        ANDNE     *ZEROS
     C                   GOTO      ONEMORE
     C                   ENDIF
     C                   ENDIF
     C*
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(8)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   GOTO      ENDREM
     C                   ENDIF
      *
      *
      *   Save first record read info.
700aDC**                 MOVEL     LPITEM        SAVITM            6
700aMC                   MOVEL     LPITEM        SAVITM           15
     C                   MOVEL     LPDESC        SAVDSC           13
     C                   MOVEL     LPPKD         SAVPD            13
     C                   Z-ADD     LPSTOP        SAVSTP            2 0
     C                   Z-ADD     *ZEROS        SAVQTY            5 0
     C                   Z-ADD     LPLBL#        SAVLBL            7 0
     C                   MOVE      *OFF          NXTITM            1
      *
      *
     C     *IN79         DOWEQ     *OFF
     C     ONE           ANDEQ     1
      *
      *   Check for reported exceptions (flags) in LDRPLTQ file.
     C     LPITEM        IFEQ      SAVITM
     C     LPSTAT        IFEQ      'F'
     C     LPSTAT        OREQ      'S'
     C     LPSTAT        OREQ      'M'
     C                   MOVE      LPSTAT        LETTRF
     C                   ENDIF
     C                   ENDIF
      *
     C     LPITEM        IFEQ      SAVITM
     C     LPSCNQ        ANDEQ     *ZEROS
     C     LPSTAT        ANDEQ     *BLANK
      *
      *   Accumulate # of case(s) not scanned yet for a particular item.
     C                   ADD       LPQTY         SAVQTY
     C                   GOTO      READ
     C                   ENDIF
      *
     C     LPITEM        IFNE      SAVITM
      *
     C     SAVQTY        IFNE      *ZEROS
      *
      *   *IN14 indicates there are still items to be scanned,
      *   load screen fields to be displayed.
     C                   SETON                                        14
     C                   MOVEL     SAVITM        W2ITM#
     C                   MOVEL     SAVDSC        W2IDSC
     C                   MOVEL     SAVPD         W2PKSZ
     C                   Z-ADD     SAVQTY        W2QTY
     C                   Z-ADD     SAVSTP        W2STOP
      *
      *   Check for flags.
     C                   EXSR      ZZVFY2
      *
     C     DSPLAY        TAG
     C                   EXFMT     SCREEN2                              50
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      '1'
     C                   MOVE      '*EXIT'       PRTN
     C                   LEAVE
     C                   ENDIF
     C*
      *  Test for F7 - Merged item exception screen.
     C*
     C     *INKG         IFEQ      *ON
     C                   EXSR      ZZEXCP
     C     SCRN2         IFEQ      '1'
      *
      *   Display screen 2 again.
     C                   GOTO      DSPLAY
     C                   ENDIF
     C     NXTSCR        IFEQ      'EOJ'
     C                   LEAVE
     C                   ENDIF
     C                   ENDIF
      *
     C                   ENDIF
      *
      *
     C     SCRN2         IFEQ      '1'
     C                   MOVE      *ON           NXTITM
     C                   MOVE      *OFF          SCRN2
     C                   GOTO      READ
     C                   ENDIF
      *
     C     NEXT1         TAG
     C                   MOVEL     LPITEM        SAVITM
     C                   MOVEL     LPDESC        SAVDSC
     C                   MOVEL     LPPKD         SAVPD
     C                   Z-ADD     *ZEROS        SAVQTY
     C                   Z-ADD     LPLBL#        SAVLBL
     C                   MOVE      *BLANK        LETTRF
      *
     C     LPSTAT        IFEQ      'F'
     C     LPSTAT        OREQ      'S'
     C     LPSTAT        OREQ      'M'
     C                   MOVE      LPSTAT        LETTRF
     C                   ENDIF
      *
     C     LPSCNQ        IFEQ      *ZEROS
     C     LPSTAT        ANDEQ     *BLANK
     C                   Z-ADD     LPQTY         SAVQTY
     C                   ENDIF
      *
     C                   Z-ADD     LPSTOP        SAVSTP
      *
     C                   ENDIF
      *
     C     READ          TAG
     C     DTKEY3        READE     LDRPLTQ                                79
     C     NXTITM        IFEQ      *ON
      *
     C                   MOVE      *BLANK        LETTRF
     C     LPSTAT        IFEQ      'F'
     C     LPSTAT        OREQ      'S'
     C     LPSTAT        OREQ      'M'
     C                   MOVE      LPSTAT        LETTRF
     C                   ENDIF
      *
      *   Save next first record read info.
     C                   MOVEL     LPITEM        SAVITM
     C                   MOVEL     LPDESC        SAVDSC
     C                   MOVEL     LPPKD         SAVPD
     C                   Z-ADD     LPSTOP        SAVSTP
     C                   Z-ADD     *ZEROS        SAVQTY
     C                   Z-ADD     LPLBL#        SAVLBL
     C                   MOVE      *OFF          NXTITM
     C                   ENDIF
     C                   ENDDO
      *
      *
     C     NXTSCR        IFEQ      'EOJ'
     C                   GOTO      ENDREM
     C                   ENDIF
      *
     C     PRTN          IFNE      '*EXIT'
     C     SAVQTY        ANDNE     *ZEROS
      *
      *   Display last no scanned item for this pallet.
      *
     C                   MOVEL     SAVITM        W2ITM#
     C                   MOVEL     SAVDSC        W2IDSC
     C                   MOVEL     SAVPD         W2PKSZ
     C                   Z-ADD     SAVQTY        W2QTY
     C                   Z-ADD     SAVSTP        W2STOP
      *
      *   Check for flags.
     C                   EXSR      ZZVFY2
      *
     C                   EXFMT     SCREEN2                              50
     C*
     C*  Test for F7 - Merged item exception screen.
     C*
     C     *INKG         IFEQ      *ON
     C                   EXSR      ZZEXCP
     C     SCRN2         IFEQ      '1'
      *
      *   Display screen 2 again.
     C                   GOTO      TOP
     C                   ENDIF
     C                   ENDIF
      *
     C                   ENDIF
     C*
      *   Adjust screen 1 item count value if neccessary.
     C*
     C     W1ITMC        IFNE      W2ITMC
     C                   EVAL      W1ITMC = W2ITMC
     C                   ENDIF
     C*
     C     *IN14         IFEQ      *OFF
     C     W2ITMC        ANDEQ     *ZEROS
     C*
      *   All items scanned.
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(13)      ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
     C*
     C     ENDREM        ENDSR
     C*----------------------------------------------------------------
     C*  ZZUPD1   Update for screen 1.
     C*----------------------------------------------------------------
     C*
     C     ZZUPD1        BEGSR
     C                   MOVE      *OFF          ERROR
     C*
     C*  Updating scaned qty one case at the time
     C*
     C                   EVAL      LPSCNQ = LPSCNQ + LPQTY
     C*
     C*  Move starting loading time into Ldrpltq file  loading
     C*  date was loading at the end of zzchk1 subroutine.
     C*
     C                   Z-ADD     HLDSTT        LPSTRT
     C*
     C                   SETOFF                                       13
     C*
     C*  Move ending loading date and time into Ldrpltq file
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        LPENDD
     C*
     C                   TIME                    LPENDT
     C                   SETON                                        13
      *
      *  Set rec status to closed.
     C                   MOVE      'C'           LPSTAT
      *
      *  Get loader emp#
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *OFF
     C                   Z-ADD     USEMP#        LPEMP#
     C                   ENDIF
      *
     C*
     C                   IF        LABLIN = *ON
      *  Scanned using label #
     C                   UPDATE    LPREC
     C                   ELSE
      *  Scanned using item #
     C                   UPDATE    LPREC2
     C                   ENDIF
     *
     *
     C     ENDUPD1       ENDSR
     C*----------------------------------------------------------------
     C*  ZZVFY1   Verify if item/label is flagged, not reported
     C*           in LDRPLTQ file and if qty was found.
     C*----------------------------------------------------------------
     C     ZZVFY1        BEGSR
     C*
     C                   Z-ADD     *ZEROS        HLDFND            5 0
     C                   MOVE      *BLANK        HLDSTA            1
     C                   MOVE      *BLANK        HLDTYP            1
     C                   MOVE      *OFF          DSPM              1
     C                   MOVE      *OFF          NOFL              1
     C                   MOVE      *OFF          STATD             1
      *
     C                   Z-ADD     RUQYFD        HLDFND
     C                   MOVE      RUSTAT        HLDSTA
     C                   MOVE      RUTYPE        HLDTYP
      *
     C     RN6KEY        READE     RUNNER6                                78
     C                   IF           *IN78
     C                   Z-ADD     HLDFND        RUQYFD
     C                   MOVE      HLDSTA        RUSTAT
     C                   MOVE      HLDTYP        RUTYPE
     C                   ENDIF
      *
     C                   IF        RUSTAT =  'D'
     C                   MOVE      *ON           STATD
     C                   MOVE      *ON           NOFL
      *  Flag was deleted.
     C                   GOTO      ENDVF1
     C                   ENDIF
      *
     C     TEST          TAG
     C                   IF        RUQYFD = *ZEROS AND
     C                             SELFLG = *ZEROS
     C                   IF        RUSTAT =  'O'    OR
     C                             RUSTAT =  'C'    OR
     C                             RUSTAT =  'P'    OR
     C                             RUSTAT =  'R'
     C                   MOVE      *ON           DSPM
     C                   GOTO      ENDVF1
     C                   ELSE
     C                   MOVE      *ON           STATD
     C                   MOVE      *ON           NOFL
     C                   GOTO      ENDVF1
     C                   ENDIF
     C                   ENDIF
      *
     C                   IF        RUQYFD =  *ZEROS AND
     C                             SELFLG <> *ZEROS
     C                   MOVE      *ON           STATD
     C                   MOVE      *ON           NOFL
     C                   GOTO      ENDVF1
     C                   ENDIF
      *
     C                   IF        RUQYFD <> *ZEROS
     C*>                 MOVE      *ON           STATD
     C                   MOVE      *ON           NOFL
     C                   GOTO      ENDVF1
     C                   ENDIF
      *
      *
     C     ENDVF1        ENDSR
     C*----------------------------------------------------------------
     C*  ZZVFY2   Verify if item/label is flagged and no reported
     C*           in LDRPLTQ file.
     C*----------------------------------------------------------------
     C     ZZVFY2        BEGSR
     C*
     C                   SETOFF                                       09
     C                   Z-ADD     *ZEROS        W2FLGQ
     C                   MOVE      *OFF          DSPM
     C                   MOVE      *OFF          NOFL
     C                   MOVE      *OFF          STATD
      *
     C     RN6KEY        CHAIN     RUNNER6                            78
     C                   IF        *IN78 = *OFF
     C                   EXSR      ZZVFY1
      *
     C                   IF        NOFL = *ON
     C                   GOTO      ENDVF2
     C                   ENDIF
      *
     C     LETTRF        IFNE      'F'
     C     LETTRF        ANDNE     'S'
     C     LETTRF        ANDNE     'M'
     C                   Z-ADD     RUQYSO        W2FLGQ
     C                   SETON                                        09
     C                   ENDIF
     C                   ENDIF
     C*
     C     ENDVF2        ENDSR
     C*----------------------------------------------------------------
700bA*
700bA*  LOADEQ  Call Load Equip program
700bA*
700bA /free
700bA   begsr LoadEq;
700cA     // check to see if user has access
CBIaA     if client = cheney;
700cA       chklist(#prog: chklistopt: #user: chklistrtn);
700cA       if chklistrtn = '*NO ';
700cA         leavesr;
700cA       endif;
CBIaA     endif;

          chain (lpwhse: lprtid: lpplid) pltsum15;

          if %found;
710aA       pCmd = '*BYPASS1';
710aM       eq480(pCmd: #prog: pstzon: lprtid);
          endif;

        endsr;
      /end-free
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
** DESC - Message
Invalid input
Label or Item not both
Invalid item qty
Invalid label #
Invalid Item #
Labl already scanned
Item already scanned
Rte# not assigned yet
No LDRPLTQ recs
All items scanned
Invalid code
Invalid qty
All items scanned
Flagged by selector
Scanning not allowed
Selector out
Flagged qty found
