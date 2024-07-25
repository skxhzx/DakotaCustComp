      /copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  LN830     Change Lot in Licinfo
     F*  04 May 2017
     F*  Lynn McMahon
     F*
     F*  Revisions
     F*
710 AF*    05/04/17  LMC  7.10
     F*      - Created
     F*      - Copied from LA830, will use the same processing just
     F*        add an update to licinfo. This will allow us to get
     F*        a liclog reords written.
     F*
760aAF*    11/29/22  LMC  7.60a
     F*      - If original license does not exist in LICINFO we will
     F*        add it so we can store a lot code for the original
     F*        license going forward.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (reverse display)
     F*  90        View mode (protect all fields)
     F*  91        Change mode (protect key fields)
     F*  97        Alawys on (used for SFLEND keyword)
     F*  98        Error on screen (sound alarm)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLN830FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FLICACTIVE iF   E           K DISK
     F*
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
     D*savesubcmd      s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($liver#)
     D drilicense      s               n   inz(*off)

     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             30    DIM(4) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Data structures for comparing original and current records.
     D*
     D CURREC        E DS                  EXTNAME(LICACTIVE)
     D ORGREC        E DS                  EXTNAME(LICACTIVE)
     D                                     prefix(O_)
     D*
     D*----------------------------------------------------------------
     D*  Called program
     D*
     D @OPNSQ          C                   CONST('OPNSQTYCL ')
     D @fmtit          c                   const('FRMTIT')
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
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LWHDP                22     26
     D  $LITEM                27     41
     D  $LDISP                42     53
     D  $LDESG                54     58
     D  $LSTAT                59     60
     D  $LSDEF                61     62
     D  $LACTV                63     64
     D*
     D  $LDES2                19     23
     D*
     D  $LACT2                19     20
     D*
     D  $LBC2                 19     20
     D*
     D  $LSTA2                19     20
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
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
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
      /Copy qcopysrc,c#pgminfds
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
     D*  Program Described Fields
     D*
     D chk4err         s               n
     D cancel          s               n
760aAD doAddLicinfo    s               n
     D error           s               n
     D WKLCNS          s             15
     D zmflag          s               n
     D zmsflag         s               n
     D*----------------------------------------------------------------
     D*  Constants
     D*
     D CSPRGM          c                   'LN830'
     d err03           c                   const('Not authorized t-
     d                                     o use Program')
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   Command: *CHANGE, *VIEW, *FIXLOT
     C*      $PWHSE  Warehouse code.
     C*      $PLCNS  License.
     C*
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD             8
     C                   PARM                    $PWHSE            3 0
     C                   PARM                    $PLCNS           15
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     c                   if        cancel = *on
     c                   eval      *in90 = *on
     c                   else
     C                   EXSR      ZZINZ2
     c                   endif
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   END
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
     C     NXTSCR        CASEQ     '04 '         SC4
     C     NXTSCR        CASEQ     '05 '         SC5
     C                   END
     C                   END
     C*
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   eval      *inlr = *on
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     C     DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C     ERROR         IFEQ      *ON
     C                   MOVE      *ON           *IN98
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
     C     NXTSCR        IFEQ      '02 '
     C                   EXFMT     SCREEN2                              50
     C                   END
     C*
     C     NXTSCR        IFEQ      '03 '
     C                   EXFMT     SCREEN3                              50
     C                   END
     C*
     C     NXTSCR        IFEQ      '04 '
     C                   EXFMT     SCREEN4                              50
     C                   END
     C*
     C     NXTSCR        IFEQ      '05 '
     C                   EXFMT     SCREEN5                              50
     C                   eval      nxtscr = 'EOJ'
     C                   END
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
     C                   SETOFF                                       242526
     C                   SETOFF                                       272829
     C                   SETOFF                                       30
     C                   SETOFF                                       98
     C*
     C                   MOVE      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR
     C                   MOVE      *OFF          CMDTKN            1
     C*
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
     C*
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZDFT1
     C*
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     C     SCR02I        BEGSR
     C*
     C                   MOVE      '02 '         NXTSCR            3
     C*
     C*  Get existing record(s).
     C*
     C                   EXSR      ZZFIL2
     C*
     C     END02I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 03 initialization
     C*
     C     SCR03I        BEGSR
     C                   MOVE      '03 '         NXTSCR            3
     C*
     C*  Get existing record(s).
     C*
     C                   EXSR      ZZFIL3
     C     END03I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 04 initialization
     C*
     C     SCR04I        BEGSR
     C*
     C                   MOVE      '04 '         NXTSCR            3
     C*
     C*  Get existing record(s).
     C*
     C                   EXSR      ZZFIL4
     C*
     C     END04I        ENDSR
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
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC1
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
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
     C     ERROR         CABEQ     *ON           ENDSC1
     C                   EXSR      ZZUPD
     C     ERROR         CABEQ     *ON           ENDSC1
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     C     SC2           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC2
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR02I
     C                   GOTO      ENDSC2
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC2
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK2
     C     ERROR         CABEQ     *ON           ENDSC2
     C                   EXSR      ZZUPD2
     C     ERROR         CABEQ     *ON           ENDSC2
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC3  -  Screen 3
     C*
     C     SC3           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC3
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR03I
     C                   GOTO      ENDSC3
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      '02 '         NXTSCR
     C                   GOTO      ENDSC3
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK3
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C     ENDSC3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC4  -  Screen 4
     C*
     C     SC4           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC4
     C                   END
     C*
     C*  Test for F5 - Refresh
     C*
     C     *INKE         IFEQ      *ON
     C                   EXSR      SCR04I
     C                   GOTO      ENDSC4
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C*                  EXSR      SCR01I
     C                   GOTO      ENDSC4
     C                   END
     C*
     C*  Test for other command keys
     C*
     C                   EXSR      ZZCMD4
     C     CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK4
     C     ERROR         CABEQ     *ON           ENDSC4
     C                   EXSR      ZZUPD4
     C     ERROR         CABEQ     *ON           ENDSC4
     C     ENDSC4        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC5  -  Screen 5
     C*
     C     SC5           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C     *INKC         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC5
     C                   END
     C*
     C*  Test for F12 - Previous
     C*
     C     *INKL         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   GOTO      ENDSC5
     C                   END
     C*
     C*
     C*  Some other key pressed.
     C*
     C     ENDSC5        ENDSR
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
     c                   call      'CHKLIST'
     c                   parm      #prog         $cpgm            10
     c                   parm      '*ALL'        $copt            20
     c                   parm      #user         $cuser           10
     c                   parm      *blanks       $crtn            10
     C*       User not authorized to use this option.
     c     $crtn         ifeq      '*NO '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   movel(p)  err03         errmsg
     c                   exsr      zm0105
     c                   endif
     c                   if        cancel = *off
     C                   EXSR      ZZINZ
     c                   else
     C                   MOVE      '05 '         NXTSCR
     c                   endif
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
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
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     C     ZMDMSG        BEGSR
     C                   MOVE      *ON           *IN97
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
     C*    ZSCLR   Clear screen
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
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C     ZMSMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM                    #PGMQ2           10
     C                   PARM                    #MSGK             4
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

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
     C*   PIR0112  Invalid range entered.
     C*
     C     ZM0112        BEGSR
     C                   MOVE      'PIR0112'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD
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
     C*----------------------------------------------------------------
     C*   PIR7983  Record changed by another user.
     C*
     C     ZM83          BEGSR
     C                   MOVE      'PIR7983'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
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
     C*     IT12210  Can't lock item record.
     C*
     C     ZM10          BEGSR
     C                   MOVE      'IT12210'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     IT12273  Item does not exist.
     C*
     C     ZM73I         BEGSR
     C                   MOVE      'IT12273'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*   PIR9806
     C*
     C     ZM9806        BEGSR
     C                   MOVE      'PIR9806'     #MSGID
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
     C     ActLicKey     chain     licactive
     C                   if        not %found(licactive)
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   MOVE      *ON           *IN22
     C                   MOVE      *ON           *IN23
     C                   MOVE      *ON           *IN01
     c                   eval      errmsg = 'Invalid License'
     c                   exsr      zm0105
     c                   leavesr
     C                   endIf
      * licinfo record must exist to go on
     C                   exsr      clr$licinfo
     C                   eval      $lnwhse  = lawhse
     C                   eval      $lnlcns  = laolcns
     C                   eval      $lnseq   = 1
     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
760aAc                   eval      doAddLicinfo = *off
     c                   if        $drireturn <> '*OK'
760aA /free
760aA   // we will allow to add the licinfo if the user continues on
760aA   // So this is no longer an error.
760aA   doAddLicinfo = *on;
760aA /end-free
760aDC*                  eval      error = *on
760aDc*                  eval      errmsg = $drimessage
760aDc*                  exsr      zm0105
     c                   endif
     C*
     C     ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     C     ZZCHK2        BEGSR
     C                   MOVE      *OFF          ERROR
     C     ENDCK2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK3   Screen 3 error checking.
     C*
     C     ZZCHK3        BEGSR
     C                   MOVE      *OFF          ERROR
     C     ENDCK3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK4   Screen 4 error checking.
     C*
     C     ZZCHK4        BEGSR
     C                   MOVE      *OFF          ERROR

     C     ENDCK4        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C     ZZCMD1        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C*
     C*  Test for F4 - Lookup
     C*
     C     *INKD         IFEQ      '1'
     C                   MOVE      '1'           CMDTKN
     C                   Z-ADD     0             ROW#
     C                   MOVE      ROWIN         ROW
     C                   Z-ADD     0             COL#
     C                   MOVE      COLIN         COL
     C*
     C                   SELECT
     C*
     C*     Warehouse.
     C*
     C     ROW#          WHENEQ    8
     C                   MOVE      *ON           *IN01
     C                   MOVE      '*LOOKUP '    $LCMD
     C                   Z-ADD     W1WHSE        $LWHSE
     C                   CALL      'WH900'
     C                   PARM                    $LPARM
     C     $LRTN         IFEQ      '*SELECT '
     C                   Z-ADD     $LWHSE        W1WHSE
     C                   ENDIF
     C*
     C                   OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     C                   MOVE      '1'           ERROR
     C                   EXSR      ZM9905
     C                   ENDSL
     C*
     C                   ENDIF
     C*
     C     ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   User defined command keys for screen 2.
     C*
     C     ZZCMD2        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C     ENDCM2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD3   User defined command keys for screen 2.
     C*
     C     ZZCMD3        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C*
     C*  Test for F10 - Update
     C*
     C     *INKJ         IFEQ      '1'
     C                   MOVE      '1'           CMDTKN
     C                   EXSR      ZZUPD3
     C                   ENDIF
     C     ENDCM3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD4   User defined command keys for screen 4.
     C*
     C     ZZCMD4        BEGSR
     C                   MOVE      *OFF          CMDTKN
     C     ENDCM4        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     C     ZZDFT1        BEGSR
     C                   MOVE      *OFF          *IN90
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     C     ZZFIL2        BEGSR
     C*
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      *OFF          *IN90
     C                   ELSE
     C                   MOVE      *ON           *IN90
     C                   ENDIF
     C*
     C*   Get LICLOG Fields
     C*
     C     actlickey     chain     licactive
     C                   if        %found(licactive)
     C                   movel     currec        orgrec
     C                   eval      wklcns = lalcns
     C                   eval      w2whse = w1whse
     C                   eval      w2lcns = w1lcns
     C*
     C                   eval      w2Disp = laDisp
     C                   eval      w2Item = laItem
     C*
     C                   eval      w2qty1 = laqty1
     C                   eval      w2qty2 = laqty2
     C                   eval      w2qty3 = laqty3
     C*
     C                   eval      w2ityp = laitype
     C                   eval      w2code = lacode
     C                   eval      w2aisl = laaisl
     C                   eval      w2loc  = laloc
     C                   eval      w2lvl  = larlvl
     C                   eval      w2hand = lahand
     C                   eval      w2area = laarea
     C                   eval      w2whdp = lawhdp
     C                   eval      w2pos  = lapos
     C                   eval      w2ord  = laord
     C                   eval      w2seq  = laseq
     C                   eval      w2entd = laentd
     C                   eval      w2expd = laexpd
     C                   eval      w2emus = lachgeusr
     C                   eval      w2crus = lachgcusr
     C                   eval      w2cjus = lachgjusr
     C                   eval      w2cgem = lachgemp
     C                   eval      w2cgpg = lachgpgm
     C                   eval      w2cgjb = lachgjob
     C                   eval      w2cgjn = lachgnbr
     C                   eval      w2chgu = lachguc
     C                   eval      w2chgt = lachgts
     C                   eval      w2prty = laprty
     C                   eval      w2sity = lasitype
     C                   eval      w2olcn = laolcns
     C                   eval      w2sitm = lasitem
     C                   eval      w2base = labase
     C                   endIf
     C*
     C                   endSr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*
     C     ZZFIL3        BEGSR
     C*
     C                   eval      w3whse = w1whse
     C                   eval      w3lcns = w1lcns
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL4   Fill screen 4 fields with info from file.
     C*
     C     ZZFIL4        BEGSR
     C*
     C     $PCMD         IFEQ      '*FIXLOT'
     C                   MOVE      *OFF          *IN90
     C                   ELSE
     C                   MOVE      *ON           *IN90
     C                   ENDIF
     C*
     C*   Get LICLOG Fields
     C*
     C     actlickey     chain     licactive
     C                   if        %found(licactive)
     C                   movel     currec        orgrec
     C                   eval      wklcns = lalcns
     C                   eval      w2whse = w1whse
     C                   eval      w2lcns = w1lcns
     C*
     C                   eval      w2Disp = laDisp
     C                   eval      w2Item = laItem
     C*
     C                   eval      w2qty1 = laqty1
     C                   eval      w2qty2 = laqty2
     C                   eval      w2qty3 = laqty3
     C*
     C                   eval      w2ityp = laitype
     C                   eval      w2code = lacode
     C                   eval      w2aisl = laaisl
     C                   eval      w2loc  = laloc
     C                   eval      w2lvl  = larlvl
     C                   eval      w2hand = lahand
     C                   eval      w2area = laarea
     C                   eval      w2whdp = lawhdp
     C                   eval      w2pos  = lapos
     C                   eval      w2ord  = laord
     C                   eval      w2seq  = laseq
     C                   eval      w2entd = laentd
     C                   eval      w2expd = laexpd
     C                   eval      w2emus = lachgeusr
     C                   eval      w2crus = lachgcusr
     C                   eval      w2cjus = lachgjusr
     C                   eval      w2cgem = lachgemp
     C                   eval      w2cgpg = lachgpgm
     C                   eval      w2cgjb = lachgjob
     C                   eval      w2cgjn = lachgnbr
     C                   eval      w2chgu = lachguc
     C                   eval      w2chgt = lachgts
     C                   eval      w2prty = laprty
     C                   eval      w2sity = lasitype
     C                   eval      w2olcn = laolcns
     C                   eval      w2sitm = lasitem
     C                   eval      w2base = labase
     C                   endIf
     C*
      * build item description
     *   Item description and pack description.

     C                   eval      w2itemd = *blanks

     C                   exsr      clr$item
     C                   eval      $itwhse  = lawhse
     C                   eval      $ititem  = laitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   eval      $iitem = laitem
     C                   eval      $idesc = $itdesc
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w2itemd
      * get the licinfo record to load lot
     C                   exsr      clr$licinfo
     C                   eval      $lnwhse  = lawhse
     C                   eval      $lnlcns  = laolcns
     C                   eval      $lnseq   = 1
     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     c                   eval      w2olot = $lnlot
     c                   eval      w2lot = $lnlot
     C                   endSr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     C     zzInz         begSr
     C*
     C*  Define key for License Log File
     C*
     C     actlickey     klist
     C                   kfld                    w1Whse
     C                   kfld                    w1Lcns
     C*
     C                   MOVE      #PROG         $LPRG
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     C     ZZINZ2        BEGSR
     *
     *   Get employee options.
     *
     C                   call      'GETUSER'
     C                   parm      #curruser     e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C*
     C     $PCMD         IFNE      '*CHANGE '
     C     $PCMD         ANDNE     '*VIEW   '
     C     $PCMD         ANDNE     '*FIXLOT'
     C                   EXSR      ZZPWRD
     C                   ENDIF
     C*
     c                   Select
     c                   When      $pcmd = '*FIXLOT'
     C                   move      'FIX   '      wotype
     c                   other
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      'CHANGE'      WOTYPE
     C                   ELSE
     C                   MOVE      'VIEW  '      WOTYPE
     C                   ENDIF
     C                   endsl
     C*
     C*   Select first screen to display.
     C*
     C                   SELECT
     C     $PLCNS        WHENEQ    *BLANKS
     C*
     C                   CALL      'GETWHSE'
     C                   PARM                    #curruser
     C     W1WHSE        PARM      0             #WHSE             3 0
     C*
     C                   EXSR      SCR01I
     C*
     C                   OTHER
     C                   Z-ADD     $PWHSE        W1WHSE
     C                   MOVE      $PLCNS        W1LCNS
     C                   EXSR      ZZCHK1
     C     ERROR         IFEQ      *ON
     C                   EXSR      SCR01I
     C                   ELSE
     c                   select
     c                   when      $pcmd = '*FIXLOT'
     C                   exsr      scr04i
     c                   other
     C                   EXSR      SCR02I
     c                   endsl
     C                   ENDIF
     C                   ENDSL
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPWRD   Get password
     C*
     C*    Note: Password becomes value for $CMD. Therefore, the
     C*          password to allow changes is *CHANGE.
     C*
     C     ZZPWRD        BEGSR
     C*
     C                   MOVE      *BLANKS       W1PWRD
     C*
     C                   DOU       W1PWRD = '*CHANGE ' or
     C                             W1PWRD <> '*CHANGE '
     C                   EXFMT     PASWRD
     C                   ENDDO
     C*
     C                   MOVE      W1PWRD        $PCMD
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     C     ZZUPD         BEGSR
     C                   MOVE      *OFF          ERROR
     C                   Z-ADD     W1WHSE        $PWHSE
     C                   MOVE      W1LCNS        $PLCNS
     c                   select
     c                   when      $pcmd = '*FIXLOT'
     C                   exsr      scr04i
     c                   other
     C                   EXSR      SCR02I
     c                   endsl
     C     ENDUPD        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Update record.
     C*
     C     ZZUPD2        BEGSR
     C                   MOVE      *OFF          ERROR
     C     $PCMD         IFEQ      '*CHANGE'
     C                   EXSR      SCR03I
     C                   ELSE
     C                   MOVE      'EOJ'         NXTSCR
     C*                  EXSR      SCR01I
     C                   ENDIF
     C     ENDUP2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     C     ZZUPD3        BEGSR
     C*
     C*
     C*     If license change, zero out old license.
     C*
     C                   if        w2lcns <> wklcns
     C*
     C                   exsr      clr$license
     C                   eval      $liActionU = *on
     C                   eval      $liAction  = 'LOT'
     C                   eval      $liToDispU = *on
     C                   eval      $litoDisp  = o_ladisp
     C                   eval      $liToItemU = *on
     C                   eval      $litoItem  = o_laitem
     C                   eval      $liToITypeU = *on
     C                   eval      $litoItype = o_laitype
     C                   eval      $liToCodeu = *on
     C                   eval      $litoCode  = o_lacode
     C                   eval      $liToAislu = *on
     C                   eval      $litoAisl  = o_laaisl
     C                   eval      $liToLocU = *on
     C                   eval      $litoLoc   = o_laloc
     C                   eval      $liToRlvlU = *on
     C                   eval      $litorlvl  = o_larlvl
     C                   eval      $liToHandU = *on
     C                   eval      $litoHand  = o_lahand
     C                   eval      $liToAreaU = *on
     C                   eval      $litoArea  = o_laarea
     C                   eval      $liToWhdpU = *on
     C                   eval      $litoWhdp  = o_lawhdp
     C                   eval      $liToPosU = *on
     C                   eval      $litoPos   = o_lapos
     C                   eval      $liToOrdU = *on
     C                   eval      $litoOrd   = o_laord
     C                   eval      $liToSeqU = *on
     C                   eval      $litoSeq   = o_laseq
     C                   eval      $liToEntDU = *on
     C                   eval      $litoEntd  = o_laentd
     C                   eval      $liToExpDU = *on
     C                   eval      $litoExpd  = o_laexpd
     C                   eval      $liToPrtyU = *on
     C                   eval      $litoPrty = o_laprty
     C                   eval      $liToSITypeU = *on
     C                   eval      $litoSitype = o_lasitem
     C                   eval      $liOLcnsU = *on
     C                   eval      $liOlcns = o_laolcns
     C                   eval      $liToSItemU = *on
     C                   eval      $litosItem = o_lasitem
     C                   eval      $liToBaseU = *on
     C                   eval      $litoBase  = o_labase
     C                   eval      $liToWhseU = *on
     C                   eval      $litoWhse  = o_lawhse
     C*
     C*
     C* Setup DRILICENSE Record Delete if License Changed
     C*
     C                   eval      $liAQty1U = *on
     C                   eval      $liaQty1  = -(o_laqty1)
     C                   eval      $liaQty2  = -(o_laqty2)
     C                   eval      $liaQty3  = -(o_laqty3)
     C                   eval      $liToRQty1U = *on
     C                   eval      $liToRQty1  = 0
     C                   eval      $liToRQty2  = 0
     C                   eval      $liToRQty3  = 0
     C                   eval      $liToLcnsU = *on
     C                   eval      $litoLcns = wklcns
     C                   eval      $liFrmOldLcnsU = *on
     C                   eval      $liFrmOldLcns = w2lcns
     C*
     C                   eval      drilicense = *on
     C*
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%SETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      nxtscr = '02 '
     C                   leavesr
     C                   endif
     C*
     C                   endif
     C*
     C* Setup Add or Update Record
     C*
     C                   exsr      clr$license
     C                   eval      $liActionU = *on
     C                   eval      $liAction  = 'LOT'
     C                   eval      $liToDispU = *on
     C                   eval      $litoDisp  = w2Disp
     C                   eval      $liToItemU = *on
     C                   eval      $litoItem  = w2Item
     C                   eval      $liToITypeU = *on
     C                   eval      $litoItype = w2ityp
     C                   eval      $liToCodeu = *on
     C                   eval      $litoCode  = w2code
     C                   eval      $liToAislu = *on
     C                   eval      $litoAisl  = w2aisl
     C                   eval      $liToLocU = *on
     C                   eval      $litoLoc   = w2loc
     C                   eval      $liToRlvlU = *on
     C                   eval      $litorlvl  = w2lvl
     C                   eval      $liToHandU = *on
     C                   eval      $litoHand  = w2hand
     C                   eval      $liToAreaU = *on
     C                   eval      $litoArea  = w2area
     C                   eval      $liToWhdpU = *on
     C                   eval      $litoWhdp  = w2whdp
     C                   eval      $liToPosU = *on
     C                   eval      $litoPos   = w2pos
     C                   eval      $liToOrdU = *on
     C                   eval      $litoOrd   = w2ord
     C                   eval      $liToSeqU = *on
     C                   eval      $litoSeq   = w2seq
     C                   eval      $liToEntDU = *on
     C                   eval      $litoEntd  = w2entd
     C                   eval      $liToExpDU = *on
     C                   eval      $litoExpd  = w2expd
     C                   eval      $liToPrtyU = *on
     C                   eval      $litoPrty = w2prty
     C                   eval      $liToSITypeU = *on
     C                   eval      $litoSitype = w2sity
     C                   eval      $liOLcnsU = *on
     C                   eval      $liOlcns = w2olcn
     C                   eval      $liToSItemU = *on
     C                   eval      $litosItem = w2sitm
     C                   eval      $liToBaseU = *on
     C                   eval      $litoBase  = w2base
     C                   eval      $liToWhseU = *on
     C                   eval      $litoWhse  = w2Whse
     C*
     C                   eval      $liAQty1U = *on
     C                   if        w2lcns = wklcns
     C                   eval      $liaQty1  = w2qty1 - o_laqty1
     C                   eval      $liaQty2  = w2qty2 - o_laqty2
     C                   eval      $liaQty3  = w2qty3 - o_laqty3
     C                   else
     C                   eval      $liaQty1  = w2qty1
     C                   eval      $liaQty2  = w2qty2
     C                   eval      $liaQty3  = w2qty3
     C                   endif
     C                   eval      $liToRQty1U = *on
     C                   eval      $liToRQty1  = w2Qty1
     C                   eval      $liToRQty2  = w2Qty2
     C                   eval      $liToRQty3  = w2Qty3
     C                   eval      $liToLcnsU = *on
     C                   eval      $litoLcns = w2lcns
     C                   eval      $liFrmOldLcnsU = *on
     C                   eval      $liFrmOldLcns = wklcns
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%SETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      nxtscr = '02 '
     C                   leavesr
     C                   endif
760aA /free
760aA   if doAddLicinfo;
760aA     $lnpgm  = #pgm;
760aA     $lnjob  = #job;
760aA     $lnjobnbr  = #jobnbr;

760aA     $lnseq = 1;
760aA     $lnitem = w2item;
760aA     $lnrcvtyp = '6';

760aA     $dricommand = '*LICINFO';
760aA     $drisubcmd  = '%ADDS';
760aA     $drisys2upd = 'D';
760aA     exsr zzzdricop;
760aA   endif;
760aA /end-free
     c* now update licinfo
     C                   eval      $lnlot = w2lot
     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%CHANGES'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C*
     C*
     C                   MOVE      'EOJ'         NXTSCR
     C*
     C                   MOVE      *OFF          ERROR
     C     ENDUP3        ENDSR

     C*----------------------------------------------------------------
     C*
     C*  ZZUPD4   Update record.
     C*
     C     ZZUPD4        BEGSR
     C                   MOVE      *OFF          ERROR
     C     $PCMD         IFEQ      '*FIXLOT'
     C                   EXSR      SCR03I
     C                   ELSE
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
     C     ENDUP4        ENDSR
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = e$emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = e$emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*LICENSE'
     C                             or $dricommand = '*ITEM'
     C                             or $dricommand = '*LICINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C**                 exsr      zm0105s
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C**                 exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C**                 exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
* * Invalid Warehouse * *
* * Invalid Slot * *
* * No item in slot * *
* * Record Not Found * *
