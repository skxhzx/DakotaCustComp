610aA /copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LA830     Change Active License
     F*  07 July 2009
     F*  Chuck Manny
     F*
     F*  Revisions
     F*
600 AF*    07/07/09  CWM  6.00
     F*      - Created
     F*
600aAF*    07/14/09  CWM  6.00 A
     F*      - Modify to allow changes with DRILICENSE
     F*
600bAF*    07/14/09  CWM  6.00 b
     F*      - Fix F12 and F3 on screens 2 and 3.
     F*
610aAF*    07/15/09  DAS  6.10a
     F*      - Revised to use zzzdricop routines.
     F*      - Revised to send original info when getting rid of
     F*        the original license when the lcns is changed.
     F*      - Added c#license 'U' fields.
     F*      - Added $liToRQty's and revised what is sent is $laAQty's.
650aAF*    05/03/13  LMC  6.50a
     F*      - Enh - Added a fix license function.
     F*        renamed display file from LA830FM to LA83001.
650bAF*    05/08/14  LMC  6.50b
     F*      - Fix - Make sure new license does not already exist.
720aA*    07/22/16  LMC  7.20a
     *      - UCI Tracking - When license is changed update uciinfo
740aA*    07/27/20  LMC  7.40a
     *      - New license edit. Cannot be blank.
750aA*    05/19/21  LMC  7.50a
     *      - New process for replace license for clients who use
     *        item license.
750bA*    07/08/21  LMC  7.50b
     *      - Only execute the replace license printing process
     *        on $PCMD = '*RPCLCNS';
770A *    02/24/23  LMC  770a  Send the Lot code to RFMT, parm 27
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
650aDF*LA830FM   CF   E             WORKSTN
750ADF*LA83001   CF   E             WORKSTN
750aMFLA83002   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FLICACTIVE iF   E           K DISK
750aAFitemdef   if   e           k disk
     F*
750aA*----------------------------------------------------------------
750aA*  Standard SQL variables and constants
750aA*----------------------------------------------------------------

750aA /copy qcopysrc,c#stdsql

750aA*----------------------------------------------------------------
750aA* Function prototypes.
750aA*----------------------------------------------------------------

750aA /copy qcopysrc,p.cvtdte
750aA /copy qcopysrc,p.getclien
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
     D*savesubcmd      s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICENSE
650aA /COPY *libl/qcopysrc,C#ITEM
720aA /COPY *libl/qcopysrc,C#UCIINFO
750aA /COPY *libl/qcopysrc,C#LICINFO
600aAD saveVer#        s                   like($liver#)
600aAD drilicense      s               n   inz(*off)

750aA*----------------------------------------------------------------
750aA*  Files
750aA*----------------------------------------------------------------

750aAD oprec         E Ds                  Extname(opsrcvlbl)
750aAD lbrec         E Ds                  Extname(label)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A10             S              1    DIM(10)
     D DESC            S             30    DIM(4) CTDATA PERRCD(1)
750aA*----------------------------------------------------------------
750aA*  Customer id
750aA*----------------------------------------------------------------

750aA /copy qcopysrc,id#finkle
     D*----------------------------------------------------------------
     D*  Data structures for comparing original and current records.
     D*
     D CURREC        E DS                  EXTNAME(LICACTIVE)
600aAD ORGREC        E DS                  EXTNAME(LICACTIVE)
600aMD                                     prefix(O_)
610aDD**                                   prefix(#)
     D*
600aDD*ORGREC          DS
600aDD* DS1000              1000   1000
     D*----------------------------------------------------------------
     D*  Called program
     D*
     D @OPNSQ          C                   CONST('OPNSQTYCL ')
650aAD @fmtit          c                   const('FRMTIT')
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
610aA /Copy qcopysrc,c#pgminfds
610aDD*               SDS
610aDD* #PROG            *PROC
610aDD* #JOB                 244    253
610aDD* #USER                254    263
610aDD* #JOBN                264    269
610aDD* #JOBDT               276    281  0
610aDD* #JOBTM               282    287  0
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
610aAD chk4err         s               n
610aAD error           s               n
750aAD $apslt          s             12
750aAd $pdev           s             10
750aAD $pform          s             10
750aAD nxtrpcl#        s              7  0
750aAD woslot          s             12
750aAD phven           s             11  0
750aAD pprinter        s             10
750aAD lblpgm          s                   like(oplpgm)
     D WKLCNS          s             15
610aAD zmflag          s               n
610aAD zmsflag         s               n
750aAD client          s             10
750aAD clientloc       s             10
750aAD done            s              1
750aAD svhi            s              2  0
750aAD svtie           s              4  0
750aAD today6          s              6  0
750aAD today6a         s              6
750aA*----------------------------------------------------------------
750aA*  CVTDTE constant and parameter data structure.
750aA*----------------------------------------------------------------

750aAD $cvtdt          ds
750aAD  $cvcmd                 1      8
750aAD  $cvprg                 9     18
750aAD  $cvd6i                19     24
750aAD  $cvd8i                25     32
750aAD  $cvd6o                33     38  0
750aAD  $cvd8o                39     46  0
750aAD  $cvsto                47     64
750aAD  $cvrtn                65     72
750aAD  $cverm                73    132
750aAD  $cvmsg                73     76

     D*----------------------------------------------------------------
     D*  Constants
     D*
     D CSPRGM          c                   'LA830'
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
650aMC*      $PCMD   Command: *CHANGE, *VIEW, *FIXLCNS
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
     C                   EXSR      ZZINZ2
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
650aAC     NXTSCR        CASEQ     '04 '         SC4
     C                   END
     C                   END
     C*
600aDC*                  eval      nxtscr = 'EOJ'
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C*                  CLOSE     LA830FM
     C                   RETURN
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
600aDC*                  eval      nxtscr = 'EOJ'
     C                   END
     C*
     C     NXTSCR        IFEQ      '03 '
     C                   EXFMT     SCREEN3                              50
     C                   END
     C*
650aAC     NXTSCR        IFEQ      '04 '
650aAC                   EXFMT     SCREEN4                              50
650aAC                   END
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
610aDC**                 MOVE      *OFF          ERROR             1
610aMC                   MOVE      *OFF          ERROR
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
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  Screen 04 initialization
650aAC*
650aAC     SCR04I        BEGSR
650aAC*
650aAC                   MOVE      '04 '         NXTSCR            3
650aAC*
650aAC*  Get existing record(s).
650aAC*
650aAC                   EXSR      ZZFIL4
650aAC*
650aAC     END04I        ENDSR
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
600aAC*
600aAC*  Test for F3 - Exit
600bAC*
600bAC     *INKC         IFEQ      *ON
600bAC                   MOVE      'EOJ'         NXTSCR
600bAC                   GOTO      ENDSC2
600bAC                   END
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
600bAC                   MOVE      'EOJ'         NXTSCR
600bDC*                  EXSR      SCR01I
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
600aAC*
600aAC*  Test for F3 - Exit
600bAC*
600bAC     *INKC         IFEQ      *ON
600bAC                   MOVE      'EOJ'         NXTSCR
600bAC                   GOTO      ENDSC3
600bAC                   END
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
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  SC4  -  Screen 4
650aAC*
650aAC     SC4           BEGSR
650aAC*
650aAC*  Test for F3 - Exit
650aAC*
650aAC     *INKC         IFEQ      *ON
650aAC                   MOVE      'EOJ'         NXTSCR
650aAC                   GOTO      ENDSC4
650aAC                   END
650aAC*
650aAC*  Test for F5 - Refresh
650aAC*
650aAC     *INKE         IFEQ      *ON
650aAC                   EXSR      SCR04I
650aAC                   GOTO      ENDSC4
650aAC                   END
650aAC*
650aAC*  Test for F12 - Previous
650aAC*
650aAC     *INKL         IFEQ      *ON
650aAC                   MOVE      'EOJ'         NXTSCR
650aAC*                  EXSR      SCR01I
650aAC                   GOTO      ENDSC4
650aAC                   END
650aAC*
650aAC*  Test for other command keys
650aAC*
650aAC                   EXSR      ZZCMD4
650aAC     CMDTKN        CABEQ     *ON           ENDSC4
650aAC*
650aAC*  Some other key pressed.
650aAC*
650aAC*     Check input and write/update record.
650aAC*
650aAC                   EXSR      ZZCHK4
650aAC     ERROR         CABEQ     *ON           ENDSC4
650aAC                   EXSR      ZZUPD4
650aAC     ERROR         CABEQ     *ON           ENDSC4
650aAC     ENDSC4        ENDSR
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
     C                   EXSR      ZZINZ
750aA /free
750aA   getclient(client: clientLoc);
750aA /free
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

610aA*----------------------------------------------------------------
610aA*    DRI0001  Local system caused error
610aA*----------------------------------------------------------------
610aA
610aAC     zm0001        begsr
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
     C                   EXSR      ZM9806
     C                   endIf
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
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  ZZCHK4   Screen 4 error checking.
650aAC*
650aAC     ZZCHK4        BEGSR
650aAC                   MOVE      *OFF          ERROR
740aAc* make sure new license is not blank
740aA /free
740aA    if w2lcns = ' ';
740aA      error = *on;
740aA    endif;
740aA /end-free
650bAc* make sure new license does not already exist
650bA /free
650bA    chain (w1whse: w2lcns) licactive;
650bA    if %found(licactive);
650bA      error = *on;
650bA    endif;
650bA /end-free
650bA
650aAC     ENDCK4        ENDSR
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
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  ZZCMD4   User defined command keys for screen 4.
650aAC*
650aAC     ZZCMD4        BEGSR
650aAC                   MOVE      *OFF          CMDTKN
650aAC     ENDCM4        ENDSR
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
600aAC                   movel     currec        orgrec
600cAC                   eval      wklcns = lalcns
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
600aAC*
600aAC                   eval      w3whse = w1whse
600aAC                   eval      w3lcns = w1lcns
     C*
     C                   ENDSR
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  ZZFIL4   Fill screen 4 fields with info from file.
650aAC*
650aAC     ZZFIL4        BEGSR
650aAC*
650aAC     $PCMD         IFEQ      '*FIXLCNS'
650aAC                   MOVE      *OFF          *IN90
650aAC                   ELSE
650aAC                   MOVE      *ON           *IN90
650aAC                   ENDIF
750aAC     $PCMD         IFEQ      '*RPCLCNS'
750aAC                   MOVE      *OFF          *IN90
750aAC                   MOVE      *ON           *IN91
750aAC                   ELSE
750aAC                   MOVE      *ON           *IN90
750aAC                   ENDIF
650aAC*
650aAC*   Get LICLOG Fields
650aAC*
650aAC     actlickey     chain     licactive
650aAC                   if        %found(licactive)
650aAC                   movel     currec        orgrec
650aAC                   eval      wklcns = lalcns
650aAC                   eval      w2whse = w1whse
650aAC                   eval      w2lcns = w1lcns
650aAC*
650aAC                   eval      w2Disp = laDisp
650aAC                   eval      w2Item = laItem
650aAC*
650aAC                   eval      w2qty1 = laqty1
650aAC                   eval      w2qty2 = laqty2
650aAC                   eval      w2qty3 = laqty3
650aAC*
650aAC                   eval      w2ityp = laitype
650aAC                   eval      w2code = lacode
650aAC                   eval      w2aisl = laaisl
650aAC                   eval      w2loc  = laloc
650aAC                   eval      w2lvl  = larlvl
650aAC                   eval      w2hand = lahand
650aAC                   eval      w2area = laarea
650aAC                   eval      w2whdp = lawhdp
650aAC                   eval      w2pos  = lapos
650aAC                   eval      w2ord  = laord
650aAC                   eval      w2seq  = laseq
650aAC                   eval      w2entd = laentd
650aAC                   eval      w2expd = laexpd
650aAC                   eval      w2emus = lachgeusr
650aAC                   eval      w2crus = lachgcusr
650aAC                   eval      w2cjus = lachgjusr
650aAC                   eval      w2cgem = lachgemp
650aAC                   eval      w2cgpg = lachgpgm
650aAC                   eval      w2cgjb = lachgjob
650aAC                   eval      w2cgjn = lachgnbr
650aAC                   eval      w2chgu = lachguc
650aAC                   eval      w2chgt = lachgts
650aAC                   eval      w2prty = laprty
650aAC                   eval      w2sity = lasitype
650aAC                   eval      w2olcn = laolcns
650aAC                   eval      w2sitm = lasitem
650aAC                   eval      w2base = labase
650aAC                   endIf
650aAC*
650aA * build item description
650aA*   Item description and pack description.
650aA
650aAC                   eval      w2itemd = *blanks
650aA
650aAC                   exsr      clr$item
650aAC                   eval      $itwhse  = lawhse
650aAC                   eval      $ititem  = laitem
650aA
650aAC                   eval      $dricommand = '*ITEM'
650aAC                   eval      $drisubcmd  = '%GETALL'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      chk4err = *off
650aAC                   eval      zmsflag = *off
650aAC                   exsr      zzzdricop
650aAC                   eval      $iitem = laitem
650aAC                   eval      $idesc = $itdesc
650aAC                   eval      $ipdsc = $itpdsc
650aAC                   eval      $istr = *blanks
650aAC                   call      @fmtit
650aAC                   parm                    $iitem           15
650aAC                   parm                    $idesc           30
650aAC                   parm                    $ipdsc           15
650aAC                   parm                    $istr            70
650aAC                   movel     $istr         w2itemd
750aA /free
750aA   if $PCMD = '*RPCLCNS';
750aA     // get next seq# for replace license
750aA /end-free
750aAc                   call      'PIRRPCL#'
750aAc                   parm      0             nxtrpcl#
750aA /free
750aA     w2lcns = 'I' + %char(%editC(nxtrpcl#:'X'));
750aA   endif;
750aA /end-free
650aAC                   endSr
650aAC*
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
610 A*
610 A*   Get employee options.
610 A*
610 AC                   call      'GETUSER'
610 AC                   parm      #curruser     e$code           10
610 AC                   parm                    e$whse            3 0
610 AC                   parm                    e$emp#            5 0
610 AC                   parm                    e$fnam           15
610 AC                   parm                    e$init            1
610 AC                   parm                    e$lnam           20
610 AC                   parm                    e$whdp            5
610 AC                   parm                    e$styp            1
610 AC                   parm                    e$shft            6
610 AC                   parm                    e$crew            6
610 AC                   parm                    e$nhrs            3 1
610 AC                   parm                    e$rtn             8
610 AC                   parm                    e$bpu             1
610 AC                   parm                    e$lng             2
     C*
     C     $PCMD         IFNE      '*CHANGE '
     C     $PCMD         ANDNE     '*VIEW   '
650aAC     $PCMD         ANDNE     '*FIXLCNS'
750aAC     $PCMD         ANDNE     '*RPCLCNS'
     C                   EXSR      ZZPWRD
     C                   ENDIF
     C*
650aAc                   Select
650aAc                   When      $pcmd = '*FIXLCNS'
650aAC                   move      'FIX   '      wotype
650aAc                   When      $pcmd = '*RPCLCNS'
650aAC                   move      'RPC   '      wotype
650aAc                   other
     C     $PCMD         IFEQ      '*CHANGE'
     C                   MOVE      'CHANGE'      WOTYPE
     C                   ELSE
     C                   MOVE      'VIEW  '      WOTYPE
     C                   ENDIF
650aAC                   endsl
     C*
     C*   Select first screen to display.
     C*
     C                   SELECT
     C     $PLCNS        WHENEQ    *BLANKS
     C*
     C                   CALL      'GETWHSE'
610aDC**                 PARM                    #USER
610aMC                   PARM                    #curruser
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
650aAc                   select
650aAc                   when      $pcmd = '*FIXLCNS'
650aAC                   exsr      scr04i
750aAc                   when      $pcmd = '*RPCLCNS'
750aAC                   exsr      scr04i
650aAc                   other
     C                   EXSR      SCR02I
650aAc                   endsl
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
600aAC                   DOU       W1PWRD = '*CHANGE ' or
600aAC                             W1PWRD <> '*CHANGE '
     C                   EXFMT     PASWRD
600aAC                   ENDDO
     C*
600aDC*                  if        w1pwrd = '*CHANGE '
600aDC*                  DOU       W1PWRD <> '*CHANGE '
600aDC*                  EXFMT     PASWRD
600aDC*                  ENDDO
600aDC*                  endIf
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
650aAc                   select
650aAc                   when      $pcmd = '*FIXLCNS'
650aAC                   exsr      scr04i
750aAc                   when      $pcmd = '*RPCLCNS'
750aAC                   exsr      scr04i
650aAc                   other
     C                   EXSR      SCR02I
650aAc                   endsl
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
600aAC                   MOVE      'EOJ'         NXTSCR
600aDC*                  EXSR      SCR01I
     C                   ENDIF
     C     ENDUP2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update for screen 3.
     C*
     C     ZZUPD3        BEGSR
600aAC*
600aAC*  Check to see if record was changed by someone else.
600aAC*
600aAC*    CURREC        IFNE      ORGREC
600aAC*                  MOVE      *ON           ERROR
600aAC*                  EXSR      ZM83
600aAC*                  MOVE      '02 '         NXTSCR
600aAC*                  unLock    licactive
600aAC*                  GOTO      ENDUP3
600aAC*                  ENDIF
600aAC*    *in79         ifeq      *off
600aAC*
610aAC*     If license change, zero out old license.
610aAC*
610aAC                   if        w2lcns <> wklcns
600aAC*
610aAC                   exsr      clr$license
610aAC                   eval      $liActionU = *on
750aAc                   select
750aAc                   when      $PCMD = '*RPCLCNS'
750aAc                             or $pcmd = '*FIXLCNS'
750aAC                   eval      $liAction  = %subst($pcmd:2:3)
750aAc                   other
600aAC                   eval      $liAction  = 'UTL'
750aAc                   endsl
610aAC                   eval      $liToDispU = *on
610aMC                   eval      $litoDisp  = o_ladisp
610aAC                   eval      $liToItemU = *on
610aMC                   eval      $litoItem  = o_laitem
610aAC                   eval      $liToITypeU = *on
610aMC                   eval      $litoItype = o_laitype
610aAC                   eval      $liToCodeu = *on
610aMC                   eval      $litoCode  = o_lacode
610aAC                   eval      $liToAislu = *on
610aMC                   eval      $litoAisl  = o_laaisl
610aAC                   eval      $liToLocU = *on
610aMC                   eval      $litoLoc   = o_laloc
610aAC                   eval      $liToRlvlU = *on
610aMC                   eval      $litorlvl  = o_larlvl
610aAC                   eval      $liToHandU = *on
610aMC                   eval      $litoHand  = o_lahand
610aAC                   eval      $liToAreaU = *on
610aMC                   eval      $litoArea  = o_laarea
610aAC                   eval      $liToWhdpU = *on
610aMC                   eval      $litoWhdp  = o_lawhdp
610aAC                   eval      $liToPosU = *on
610aMC                   eval      $litoPos   = o_lapos
610aAC                   eval      $liToOrdU = *on
610aMC                   eval      $litoOrd   = o_laord
610aAC                   eval      $liToSeqU = *on
610aMC                   eval      $litoSeq   = o_laseq
610aAC                   eval      $liToEntDU = *on
610aMC                   eval      $litoEntd  = o_laentd
610aAC                   eval      $liToExpDU = *on
610aMC                   eval      $litoExpd  = o_laexpd
610aDC**                 eval      $liUser   = w2crus
610aDC**                 eval      $liemp#   = w2cgem
610aDC**                 eval      $lipgm    = w2cgpg
610aDC**                 eval      $lijob    = w2cgjb
610aDC**                 eval      $lijobn   = w2cgjn
610aDC**                 eval      $liStampUc = w2chgu
610aDC**                 eval      $liStampSys = w2chgt
610aAC                   eval      $liToPrtyU = *on
610MAC                   eval      $litoPrty = o_laprty
610aAC                   eval      $liToSITypeU = *on
610aMC                   eval      $litoSitype = o_lasitem
610aAC                   eval      $liOLcnsU = *on
610aMC                   eval      $liOlcns = o_laolcns
610aAC                   eval      $liToSItemU = *on
610aMC                   eval      $litosItem = o_lasitem
610aAC                   eval      $liToBaseU = *on
610aMC                   eval      $litoBase  = o_labase
610aAC                   eval      $liToWhseU = *on
610aMC                   eval      $litoWhse  = o_lawhse
600aAC*
610aDC**                 eval      $litoWhseE = *on
610aDC**                 eval      $litoLcnsE = *on
600aAC*
600aAC* Setup DRILICENSE Record Delete if License Changed
600aAC*
610aDC**                 if        w2lcns <> wklcns
610aAC                   eval      $liAQty1U = *on
610aMC                   eval      $liaQty1  = -(o_laqty1)
610aMC                   eval      $liaQty2  = -(o_laqty2)
610aMC                   eval      $liaQty3  = -(o_laqty3)
610aAC                   eval      $liToRQty1U = *on
610aAC                   eval      $liToRQty1  = 0
610aAC                   eval      $liToRQty2  = 0
610aAC                   eval      $liToRQty3  = 0
610aAC                   eval      $liToLcnsU = *on
600aAC                   eval      $litoLcns = wklcns
610aAC                   eval      $liFrmOldLcnsU = *on
610aAC                   eval      $liFrmOldLcns = w2lcns
610aDC**                 eval      wkLcns = w2Lcns
600aAC*
600aAC                   eval      drilicense = *on
600aAC*
610aDC**                 call(e)   'DRILICENSE'
610aDC**                 parm      '%SETLCNS'    $drisubcmd
610aDC**                 parm      CSPRGM        $driprogram
610aDC**                 parm      ' '           $drireturn
610aDC**                 parm      ' '           $drimessage
610aDC**   $license      parm      $license      $dridata
610aDC**                 parm      ' '           $dridata2
610aAC                   eval      $dricommand = '*LICENSE'
610aAC                   eval      $drisubcmd  = '%SETLCNS'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmflag  = *on
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   eval      nxtscr = '02 '
610aAC                   leavesr
610aAC                   endif
     C*
600aAC                   endif
600aAC*
600aAC* Setup Add or Update Record
600cAC*
600aAC*
610aDC**                 if        w2lcns = wklcns
600aAC*
610aAC                   exsr      clr$license
610aAC                   eval      $liActionU = *on
750aAc                   select
750aAc                   when      $PCMD = '*RPCLCNS'
750aAc                             or $pcmd = '*FIXLCNS'
750aAC                   eval      $liAction  = %subst($pcmd:2:3)
750aAc                   other
610aAC                   eval      $liAction  = 'UTL'
750aAc                   endsl
610aAC                   eval      $liToDispU = *on
610aAC                   eval      $litoDisp  = w2Disp
610aAC                   eval      $liToItemU = *on
610aAC                   eval      $litoItem  = w2Item
610aAC                   eval      $liToITypeU = *on
610aAC                   eval      $litoItype = w2ityp
610aAC                   eval      $liToCodeu = *on
610aAC                   eval      $litoCode  = w2code
610aAC                   eval      $liToAislu = *on
610aAC                   eval      $litoAisl  = w2aisl
610aAC                   eval      $liToLocU = *on
610aAC                   eval      $litoLoc   = w2loc
610aAC                   eval      $liToRlvlU = *on
610aAC                   eval      $litorlvl  = w2lvl
610aAC                   eval      $liToHandU = *on
610aAC                   eval      $litoHand  = w2hand
610aAC                   eval      $liToAreaU = *on
610aAC                   eval      $litoArea  = w2area
610aAC                   eval      $liToWhdpU = *on
610aAC                   eval      $litoWhdp  = w2whdp
610aAC                   eval      $liToPosU = *on
610aAC                   eval      $litoPos   = w2pos
610aAC                   eval      $liToOrdU = *on
610aAC                   eval      $litoOrd   = w2ord
610aAC                   eval      $liToSeqU = *on
610aAC                   eval      $litoSeq   = w2seq
610aAC                   eval      $liToEntDU = *on
610aAC                   eval      $litoEntd  = w2entd
610aAC                   eval      $liToExpDU = *on
610aAC                   eval      $litoExpd  = w2expd
610aAC                   eval      $liToPrtyU = *on
610aAC                   eval      $litoPrty = w2prty
610aAC                   eval      $liToSITypeU = *on
610aAC                   eval      $litoSitype = w2sity
610aAC                   eval      $liOLcnsU = *on
610aAC                   eval      $liOlcns = w2olcn
610aAC                   eval      $liToSItemU = *on
610aAC                   eval      $litosItem = w2sitm
610aAC                   eval      $liToBaseU = *on
610aAC                   eval      $litoBase  = w2base
610aAC                   eval      $liToWhseU = *on
610aAC                   eval      $litoWhse  = w2Whse
610aAC*
610aAC                   eval      $liAQty1U = *on
610aAC                   if        w2lcns = wklcns
610aAC                   eval      $liaQty1  = w2qty1 - o_laqty1
610aAC                   eval      $liaQty2  = w2qty2 - o_laqty2
610aAC                   eval      $liaQty3  = w2qty3 - o_laqty3
610aAC                   else
610aAC                   eval      $liaQty1  = w2qty1
610aAC                   eval      $liaQty2  = w2qty2
610aAC                   eval      $liaQty3  = w2qty3
610aAC                   endif
610aAC                   eval      $liToRQty1U = *on
610aAC                   eval      $liToRQty1  = w2Qty1
610aAC                   eval      $liToRQty2  = w2Qty2
610aAC                   eval      $liToRQty3  = w2Qty3
610aAC                   eval      $liToLcnsU = *on
610aMC                   eval      $litoLcns = w2lcns
610aAC                   eval      $liFrmOldLcnsU = *on
610aAC                   eval      $liFrmOldLcns = wklcns
600aAC*
610aDC**                 call(e)   'DRILICENSE'
610aDC**                 parm      '%SETLCNS'    $drisubcmd
610aDC**                 parm      CSPRGM        $driprogram
610aDC**                 parm      ' '           $drireturn
610aDC**                 parm      ' '           $drimessage
610aDC**   $license      parm      $license      $dridata
610aDC**                 parm      ' '           $dridata2
610aAC                   eval      $dricommand = '*LICENSE'
610aAC                   eval      $drisubcmd  = '%SETLCNS'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmflag  = *on
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   eval      nxtscr = '02 '
610aAC                   leavesr
610aAC                   endif
720aA /free
720aA   exsr clr$uciinfo;
720aA   $uiWhse = $pwhse;
720aA   $uilcns = $liFrmOldLcns;
720aA   $uitolcns = $litoLcns;
720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%UPDATELIC';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA /End-free
750aA /free
750bA  if $PCMD = '*RPCLCNS';
750aA   // need to print new license
750aA*
750aA*  Get receiving options.
750aA*
750aA /free
750aA   exec sql select * into :oprec
750aA        from opsrcvlbl
750aA        where opwhse = :$pwhse;
750aA   If sqlstt = sqlSuccess;
750aA     OPLPGM = OPLPGM;
750aA     if %subst(oplpgm:1:4) = 'RFMT';
750aA       lblset = %subst(oplpgm: 5 : 6);
750aA       lblpgm = %subst(oplpgm: 1 : 4);
750bA     else;
750bA       return;
750aA     endif;
750aA   else;
750aA     return;
750aA   endif;
750aA   exsr clr$licinfo;
750aA   $lnwhse  = $pwhse;
750aA   $lnlcns = w2olcn;
750aA   $lnseq  = 1;
750aA   $dricommand = '*LICINFO';
750aA   $drisubcmd  = '%GET';
750aA   $drisys2upd = 'D';
750aA   exsr zzzdricop;
750aA   if $drireturn = '*OK';
750aA   endif;
750aA /end-free
750aA   // get the pick slot from drislot
750aAC                   call      'GETPSLT'
750aAC                   parm                    $scmd             8
750aAC                   parm      $pwhse        $pwhse
750aAC                   parm                    $lnitem
750aAC                   parm                    woslot
750aAC                   parm      *blanks       $saisl            3
750aAC                   parm      *zeros        $sloc             3 0
750aAC                   parm      *zeros        $srlvl            2 0
750aAC                   parm      *blanks       $shand            2
750aAC                   parm                    $srtn             8
750aA /free
750aA*
750aA   exsr zztihi;
750aA   today6a = %SUBST (%CHAR($lnaddts):6:2) +
750aA             %SUBST (%CHAR($lnaddts):9:2) +
750aA             %SUBST (%CHAR($lnaddts):3:2);
750aA   today6 = %DEC(today6a:6:0);
750aA   // need uom from label
750aA   exec sql select * into :lbrec
750aA        from label
750aA        where lbwhse = :$pwhse
750aA          and lblbl# = :$LNRCVLBL#;
750aA   If sqlstt = sqlSuccess;
750aA   else;
750aA     lbucod = ' ';
750aA   endif;
750aA /end-free
750aAC                   call      lblpgm
750aAC                   parm                    $acmd             8
750aAC                   parm                    lblset            6
750aAC                   parm      ' '           $plfmt            8
750aAC                   parm                    $lnrcvtrn#
750aAC                   parm                    $pwhse
750aAC                   parm                    lawhdp
750aAC                   parm                    $astyp            1
750aAC                   parm                    $adisp           12
750aAC                   parm      woslot        $apslt
750aAC                   parm                    $lnrcvqty
750aAC                   parm                    lbucod
750aAC                   parm                    wotie             4 0
750aAC                   parm                    wohi              2 0
750aAC                   parm                    $lnitem
750aAC                   parm                    $itdesc
750aAC                   parm                    $itpdsc
750aAC                   parm                    $itupc
750aAC                   parm                    phven
750aAC                   parm                    $itvit#
750aAC                   parm                    $lnpo
750aAC                   parm                    today6
750aAC                   parm                    $aexpd            6 0
750aAC                   parm      pprinter      $pdev
750aAC                   parm                    $pform
750aAC                   parm                    w2lcns           15
770aAC                   parm      ' '           bBrand           10
770aAC                   parm                    $lnlot
750bA /free
750bA  endif;
750bA /end-free
     C*
610aDC**                 endif
600aAC*
600aAC                   MOVE      'EOJ'         NXTSCR
600aAC*                  endIf
600aAC*
     C                   MOVE      *OFF          ERROR
600aDC*                  EXSR      SCR01I
     C     ENDUP3        ENDSR

650aAC*----------------------------------------------------------------
650aAC*
650aAC*  ZZUPD4   Update record.
650aAC*
650aAC     ZZUPD4        BEGSR
650aAC                   MOVE      *OFF          ERROR
650aAC     $PCMD         IFEQ      '*FIXLCNS'
750aAc     $PCMD         oreq      '*RPCLCNS'
650aAC                   EXSR      SCR03I
650aAC                   ELSE
650aAC                   MOVE      'EOJ'         NXTSCR
650aAC*                  EXSR      SCR01I
650aAC                   ENDIF
650aAC     ENDUP4        ENDSR
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

650aA*----------------------------------------------------------------
650aA*  clr$item  Clear $item data structure fields
650aA*----------------------------------------------------------------
650aA
650aAC     clr$item      begsr
650aAC                   eval      savever# = $itver#
650aAC                   clear                   $item
650aAC                   eval      $itver# = savever#
650aAC                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$license  Clear $license data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = e$emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   endsr
750aA*----------------------------------------------------------------
750aA*  clr$licinfo  Clear $licinfo data structure fields
750aA*----------------------------------------------------------------

750aAC     clr$licinfo   begsr
750aAC                   eval      savever# = $lnver#
750aAC                   clear                   $licinfo
750aAC                   clear                   $licinfo2
750aAC                   eval      $lnver# = savever#

750aAC                   eval      $lnuser = #curruser
750aAC                   eval      $lnpgm  = #pgm
750aAC                   eval      $lnjob  = #job
750aAC                   eval      $lnjobnbr = #jobnbr

750aAC                   endsr

720aA*----------------------------------------------------------------
720aA*  clr$uciinfo  Clear $uciinfo data structure fields
720aA*----------------------------------------------------------------
720aA
720aAC     clr$uciinfo   begsr
720aAC                   eval      savever# = $uiver#
720aAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
720aAC                   eval      $uiver# = savever#
720aAC                   eval      $uiaddemp = e$emp#
720aAC                   eval      $uiaddusr = #curruser
720aAC                   eval      $uiaddpgm  = #pgm
720aAC                   eval      $uiaddjob  = #job
720aAC                   eval      $uiaddnbr = #jobnbr
720aAC                   endsr

610aA
610aA*----------------------------------------------------------------
610aA*  zzzdricop  Call DRICOP
610aA*----------------------------------------------------------------
610aA
610aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $dridata = $item
650aAC                   eval      $dridata2 = $item2
720aAC                   when      $dricommand = '*UCIINFO'
720aAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
750aAC                   when      $dricommand = '*LICINFO'
750aAC                   eval      $dridata = $licinfo
750aAC                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*LICENSE'
650aAC                             or $dricommand = '*ITEM'
720aAC                             or $dricommand = '*UCIINFO'
750aAC                             or $dricommand = '*LICINFO'
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
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $item = $dridata
650aAC                   eval      $item2 = $dridata2
720aAC                   when      $dricommand = '*UCIINFO'
750aDC*                  eval      $item = $uciinfo
750aDC*                  eval      $item2 = $uciinfo2
750aMC                   eval      $uciinfo = $dridata
750aMC                   eval      $uciinfo2 = $dridata2
750AAC                   when      $dricommand = '*LICINFO'
750aMC                   eval      $licinfo = $dridata
750aMC                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
750aA*----------------------------------------------------------------
750aA*
750aA*  ZZTIHI   Get use Preferred or 1st tie hi record.
750aA*
750aAC     zztihi        begsr
750aA*
750aA*  GET TIE HI, PREFERRED OR 1ST RECORD.
750aAC                   eval      done = *off
750aAC                   eval      wotie = 0
750aAC                   eval      wohi = 0
750aAC                   eval      svtie = 0
750aAC                   eval      svhi = 0
750aA /free
750aA    setll ($pwhse: $lnitem) itemdef;
750aA    dou done = *on;
750aA      reade ($pwhse: $lnitem) itemdef;
750aA      if %eof(itemdef);
750aA        done = *on;
750aA        leave;
750aA      endif;
750aA /end-free
750aAC                   if        svtie = 0  and
750aAC                             svhi = 0
750aAC                   eval      svtie = idtie
750aAC                   eval      svhi = idhigh
750aAC                   endif
750aAC                   if        idpref = 'Y'
750aAC                   eval      wotie = idtie
750aAC                   eval      wohi = idhigh
750aAC                   eval      done = *on
750aAC                   endif
750aAC                   enddo
750aAC                   if        wotie = 0  and
750aAC                             wohi = 0
750aAC                   eval      wotie = svtie
750aAC                   eval      wohi = svhi
750aAC                   endif
750aA*
750aAc                   if        client = finkle
750aAC                   eval      *in86 = *on
750aAC                   else
750aAC                   eval      *in86 = *off
750aAC                   endif
750aAC                   endsr
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
* * Invalid Warehouse * *
* * Invalid Slot * *
* * No item in slot * *
* * Record Not Found * *
