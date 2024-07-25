      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  US212     Program user authority display
     *  28 Nov, 2007
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*  12/03/07  CM   5.10
     *   - Created.
520 A*  06/25/08  RBD  5.20
     *   - Fix:  Changed pgm option field to allow blanks.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  XX        XXXXXXXX XXXXXXXXX
     *
     *----------------------------------------------------------------
     *
     * ********************************
     ** File Specs
     * ********************************
     *
     fus212fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fpgmusrid  uf a e           k disk
     f                                     rename(pgRec:record)
     d*----------------------------------------------------------------
     d*  Table and array definitions
     d*
     d A10             s              1    DIM(10)
     d DESC            s             20    DIM(1) CTDATA PERRCD(1)
     d*
     d nxtScr          s              3
     d warn            s              1
     d error           s              1
     d cmdTkn          s              1
     d E               s              2  0
     d msgk            s              4  0
     d #MsgId          s              7
     d #MsgTp          s              7
     d #pgmq           s             10
     d $msgf           s             10
     d sClear          s              1
     d*
     d*----------------------------------------------------------------
     d*  Program parameters
     d*
     d*
     d $PARMS          DS
     d  $PCMD                  1      8
     d  $PPRG                  9     18
     d  $PUKY                 19     68
     d  $PRTN                 69     76
     d  $PERM                 77    136
     d  $PMSG                 77     80
     d*
     d** Redefine key
     d*
     d  $pPgm                 19     28
     d  $pOpt                 29     48
     d  $pUsr                 49     58
     d*
     d*----------------------------------------------------------------
     d** Called programs
     d*
     d*----------------------------------------------------------------
     d*  Data structure for error message parameters
     d*
     d $MDT            DS
     d  ERRMSG                 1     50
     d*
     d  ERPO#                  1      5P 0
     d  ERITEM                 6     20
     d                 DS
     d  $EC                    1      2P 0
     d*----------------------------------------------------------------
     d*  Message control
     d*
     d #MSGF           c                   CONST('PIRMSGF   ')
     d cEoj            c                   'EOJ'
     d cOne            c                   '01 '
     d*
     d cAdd            c                   '*ADD    '
     d cExit           c                   '*EXIT   '
     d cPgmQ           c                   '*PGMQ   '
     d cView           c                   '*VIEW   '
     d cClear          c                   '*CLEAR  '
     d cChange         c                   '*CHANGE '
     d cCancel         c                   '*CANCEL '
     d cNull           c                   '*NULL  '
     d*
     d                 DS
     d  #MSGDT                 1    128
     d  $MD                    1    128
     d                                     DIM(128)
     d*----------------------------------------------------------------
     d*  Program info data structure
     d*
     d                SDS
     d  #PROG            *PROC
     d  #JOB                 244    253
     d  #USER                254    263
     d  #JOBN                264    269
     d  #JOBDT               276    281  0
     d  #JOBTM               282    287  0
     d*----------------------------------------------------------------
     d*  Workstation exception data structure
     d*
     d INFDS           DS
     d  STATUS           *STATUS
     d  ROWIN                370    370
     d  COLIN                371    371
     d*----------------------------------------------------------------
     d*  Workstation exception redefinition data structure
     d*
     d                 DS
     d  ROW#                   1      2B 0
     d  ROW                    2      2
     d  COL#                   3      4B 0
     d  COL                    4      4
     d*----------------------------------------------------------------
     c*  Parameters
     c*
     c*    Input Parameters
     c*      $PCMD   *ADD     - Create new batch.
     c*              *EDIT    - Edit batch.
     c*              *DELETE  - Delete batch.
     c*              *PRINT   - Print batch edit listing.
     c*              *POST    - Post batch.
     c*      $PPRG   Program to send messages back to.
     c*      $PUKY   Contains key for everything by *ADD.
     c*
     c*    Returned Parameters
     c*      $PUKY   Contains new batch number for *ADD.
     c*              Unchanged for everything else.
     c*      $PRTN   blank    - No problem encountered.
     c*              *ERROR   - Error occured. Message in $PERM
     c*              *PGMQ    - Error occured. Message sent to pgmq.
     c*      $PERM   Error message or pointer to message in pgmq.
     c*
     c*----------------------------------------------------------------
     c*  Let the show begin .....
     c*
     c     *entry        pList
     c                   parm                    $parms
     c*
     c*----------------------------------------------------------------
     c*  Main line
     c*
     c                   eval      *in97 = *on
     c                   eval      *in90 = *off
     c                   eval      *in91 = *off
     c*
     c                   eval      error = *off
     c                   eval      $prtn = *blanks
     c                   eval      $perm = *blanks
     c*
     c                   exsr      zzInz2
     c*
     c                   if        error = *on
     c                   eval      nxtScr = cEoj
     c                   endIf
     c*
     c                   dow       nxtScr <> cEoj
     c                   exsr      dspScr
     c     nxtScr        casEq     cOne          SC1
     c                   end
     c                   endDo
     c*
     c** Do some clean up before leaving.
     c*
     c                   exsr      zscLr
     c*
     c                   return
     c*
     c*----------------------------------------------------------------
     c*  DSPSCR - Display screen
     c*
     c     dspScr        begSr
     c*
     c** Set ON alarm indicator if error occured
     c*
     c                   if        error = *on
     c                   eval      *in98 = *on
     c                   endIf
     c*
     c** Overlay screen with error messages
     c*
     c                   exsr      zmdMsg
     c*
     c** Overlay screen with screen to be processed.
     c*
     c                   if        nxtScr = cOne
     c                   exfmt     screen1                              50
     c                   endIf
     c*
     c** Initialize error indicators and fields
     c*
     c                   eval      warn = *off
     c                   eval      error = *off
     c                   eval      cmdTkn = *off
     c                   eval      E = 0
     c*
     c** Initialize error subfile
     c*
     c                   exsr      zmcMsg
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c*     Screen initialization and wrap-up routines
     c*
     c*----------------------------------------------------------------
     c*
     c*  Screen 01 initialization
     c*
     c     scr01i        begSr
     c*
     c                   eval      nxtScr = cOne
     c*
     c                   if        $pCmd = cView
     c                   eval      *in90 = *on
     c                   endIf
     c*
     c*  Get field defaults if this is an add.
     c*
     c                   if        $pCmd = cAdd
     c                   exsr      zzDft1
     c                   else
     c*
     c** Otherwise get existing record(s).
     c*
     c                   eval      *in91 = *on
     c                   exsr      zzGet1
     c                   exsr      zzFil1
     c                   endIf
     c*
     c     end01i        endSr
     c*
     c*----------------------------------------------------------------
     c*
     c*              Screen Processing Routines
     c*
     c*----------------------------------------------------------------
     c*
     c** SC1  -  Screen 1
     c*
     c     sc1           begSr
     c*
     c** Test for F5 - Refresh
     c*
     c                   if        *inke = *on and
     c                             $pcmd <> cView
     c                   exsr      scr01i
     c                   goto      endSc1
     c                   endIf
     c*
     c** Test for F12 - Previous
     c*
     c                   if        *inkl = *on
     c     *loval        setll     record
     c                   eval      nxtScr = cEoj
     c                   eval      $prtn = cCancel
     c                   goto      endSc1
     c                   endIf
     c*
     c** Check input and write/update record.
     c*
     c                   if        $pCmd = cAdd or $pCmd = cChange
     c                   exsr      zzChk1
     c     error         cabEq     '1'           endSc1
     c                   exsr      zzUpd
     c     error         cabEq     '1'           endSc1
     c                   endIf
     c*
     c                   eval      nxtScr = cEoj
     c*
     c     endSc1        endSr
     c*
     c*----------------------------------------------------------------
     c*
     c*          SUBROUTINES IN ALPHABETICAL ORDER
     c*
     C*----------------------------------------------------------------
     c*
     c*  *INZSR  Initialization subrotine
     c*
     c     *inzSr        begSr
     c*
     c** Initialize special keys
     c*
     c                   Z-ADD     0             ENTER             5 0
     c                   Z-ADD     2             COMAND            5 0
     c                   Z-ADD     01122         ROLLUP            5 0
     c                   Z-ADD     01123         ROLLDN            5 0
     c                   Z-ADD     01124         CLEAR             5 0
     c                   Z-ADD     01125         HELP              5 0
     c*
     c** Initialize message handling
     c*
     c                   exsr      zmiMsg
     c*
     c** Call user added initialization routine.
     c*
     c                   exsr      zzInz
     c*
     c                   endSr
     c*
     c*---------------------------------------------------------------
     c*
     c*  SUBROUTINE ZMxxxx  Control message display subfile
     c*
     c*    ZMCMSG  Clear message record subfile
     c*
     c     zmcMsg        begSr
     c*
     c                   eval      *in97 = *off
     c                   write     msgCtl
     c                   eval      msgk = *zero
     c                   write     msgClr
     c                   eval      #msgId = cCLEAR
     c                   eval      #msgTp = cNull
     c                   exsr      zmpMsg
     c                   endSr
     c*
     c*  ZMDMSG  Display message record subfile
     c*
     c     zmdMsg        begSr
     c*
     c                   eval      *in97 = *on
     c*
     c                   if        msgK > 0
     c                   write     msgCtl
     c                   eval      msgK = *zero
     c                   end
     c*
     c                   endSr
     c*
     c*  ZMIMSG  Initialization necessary for message subfile
     c*
     c     zmiMsg        begSr
     c*
     c                   eval      #pgmq = #prog
     c                   exsr      zmcMsg
     c*
     c                   endSr
     c*
     c**   ZMPMSG  Add message record to subfile
     c*
     c     zmpMsg        begSr
     c*
     c                   if        $msgf = *blanks
     c                   eval      $msgf = #msgf
     c                   endIf
     c*
     c                   CALL      'PUTMSG'
     c                   PARM                    $MSGF
     c                   PARM                    #MSGID
     c                   PARM                    #MSGTP
     c                   PARM                    #MSGDT
     c                   PARM                    #PGMQ
     c                   PARM                    #MSGK
     c*
     c                   if        #msgId <> cClear
     c                   eval      msgk = msgk + 1
     c                   write     msgRec
     c                   endIf
     c*
     c                   eval      #msgDt = *blanks
     c                   eval      $msgf = *blanks
     c                   endSr
     c*
     C*    ZSCLR   Clear screen
     C*
     C     zsClr         begSr
     C                   write     clrScr
     C                   eval      sClear = *on
     C*
     C                   endSr
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C     ZMSMSG        BEGSR
     C*
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF
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
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     C     ZM01          BEGSR
     C                   MOVE      'PIR0201'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     DESC          ERRMSG
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     C     ZM02          BEGSR
     C                   MOVE      'PIR0202'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     DESC          ERRMSG
     C                   MOVEA     ERRMSG        $MD(1)
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
     C* ---------------------------------------------------------------
     C*     PIR7973  Slot record does not exist.
     C*
     C     ZM73          BEGSR
     C                   MOVE      'PIR7973'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   MOVE      #MSGK         $PMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     PIR7974  Slot record is locked.
     C*
     C     ZM74          BEGSR
     c                   MOVE      'PIR7974'     #MSGID
     c                   MOVE      '*DIAG  '     #MSGTP
     c                   MOVEA     ERRMSG        $MD(1)
     c                   EXSR      ZMSMSG
     c                   MOVE      #MSGK         $PMSG
     c                   ENDSR
     c*----------------------------------------------------------------
     c*
     c*  ZZCHK1   Screen 1 error checking.
     c*
     c     zzChk1        begSr
     c*
     c                   eval      error = *off
     c                   eval      *in21 = *off
     c                   eval      *in22 = *off
     c                   eval      *in23 = *off
     c*
     c** Make sure fields were populated
     c*
     c                   select
     c*
     c                   when      w2PgPgm = *blanks
     c                   eval      *in21 = *on
     c*
520 Dc**                 when      w2PgOpt = *blanks
520 Dc**                 eval      *in22 = *on
     c*
     c                   when      w2PgUsr = *blanks
     c                   eval      *in23 = *on
     c*
     c                   endSl
     c*
     c                   if        *in21 = *on or *in22 = *on or
     c                                                *in23 = *on
     c                   eval      error = *on
     c                   exsr      zm01
     c                   endIf
     c*
     c** Make sure code doesn't already exist.
     c*
     c                   eval      $pPgm = w2pgPgm
     c                   eval      $pOpt = w2pgOpt
     c                   eval      $pUsr = w2pgUsr
     c*
     c     fileKy        chain     record
     c                   if        %found
     c                   eval      error = *on
     c                   eval      *in21 = *on
     c                   exsr      zm02
     c                   endIf
     c*
     c                   endSr
     c*
     C*----------------------------------------------------------------
     c*
     c** zzDft1   Get default values for add.
     c*
     c     zzDft1        begSr
     c*
     c                   eval      w2pgPgm = *blanks
     c                   eval      w2pgOpt = *blanks
     c                   eval      w2pgUsr = *blanks
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c*  ZZFIL1   Fill screen 1 fields with info from file.
     c*
     c     zzFil1        begSr
     c*
     c                   eval      w2pgPgm = pgPgm
     c                   eval      w2pgOpt = pgOpt
     c                   eval      w2pgUsr = pgUser
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c** ZZGET1   Get record(s) for screen 1.
     c*
     c     zzGet1        begSr
     c*
     c**  Get record from main file.
     c*
     c                   if        $pCmd = cView
     c     FILEKY        CHAIN(N)  RECORD                             7978
     c                   ELSE
     c     FILEKY        CHAIN     RECORD                             7978
     c                   ENDIF
     c*
     c** Record locked.
     c*
     c                   if        *in78 = *on
     c                   eval      error = *on
     c                   eval      $prtn = '*PGMQ   '
     c                   exsr      zm74
     c                   goto      endGt2
     c                   endIf
     c*
     c** Record not found.
     c*
     c                   if        *in79 = *on
     c                   eval      error = *on
     c                   eval      $prtn = '*PGMQ   '
     c                   exsr      zm73
     c                   goto      endGt2
     c                   endIf
     c*
     c     endGt2        endSr
     c*
     c*----------------------------------------------------------------
     c*
     c** ZZINZ    Extra program initialization. Called from *INZSR.
     c*
     c     zzInz         begSr
     c*
     c** Define key for main file.
     c*
     c     fileKy        kList
     c                   kFld                    $pPgm
     c                   kFld                    $pOpt
     c                   kFld                    $pUsr
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c** ZZINZ2   Program initialization. Called from main line.
     c*
     c     zzInz2        BegSr
     c*
     c** Select first screen to display.
     c*
     c                   if         $pCmd = cAdd
     c                   eval       $pPgm = *blanks
     c                   eval       $pOpt = *blanks
     c                   eval       $pUsr = *blanks
     c                   endIf
      *
     c                   exsr      scr01i
      *
     c                   endSr
      *
     C*----------------------------------------------------------------
     c*
     c** ZZUPD    Update record.
     c*
     c     zzUpd         begSr
     c*
     c                   eval      error = *off
     c*
     c** Move screen fields to record fields
     c*
     c                   eval      pgPgm  = w2pgPgm
     c                   eval      pgOpt  = w2pgOpt
     c                   eval      pgUser = w2pgUsr
     c*
     c** Add record
     c*
     c                   if        $pcmd = cAdd
     c                   write     record                               79
     c                   if        *in79 = *ON
     c                   eval      error = *on
     c                   exsr      zm71
     c                   goto      endUpd
     c                   endIf
     c*
     c                   else
     c*
     c** -OR- Update record (it was read and locked in ZZGET2)
     c*
     c                   upDate    record                               79
     c*
     c                   if        *in79 = *on
     c                   eval      error = *on
     c                   exsr      zm72
     c                   goto      endUpd
     C                   endIf
     C                   endIf
     c*
     c** Move key values to parameters
     c*
     c                   eval      $pPgm = w2pgPgm
     c                   eval      $pOpt = w2pgOpt
     c                   eval      $pUsr = w2pgUsr
     c*
     c     endUpd        endSr
     c*
     o*----------------------------------------------------------------*********
     o*
     o*  COMPILE TIME TABLES
     o*
**
Program,Option,User
