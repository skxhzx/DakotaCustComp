     F*----------------------------------------------------------------
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. LOAD21FM WILL BE REPALCED WITH LOAD2101
     *----------------------------------------------------------------
     F*
     F*  LOADR21   Loader Module - RF Load Trailer Equipment Detail
     F*  December 21, 2006
     F*  Jose Duque
     F*
     F*  Revisions
     F*
530 A*    06/30/10  JCJ  5.30
     *      - Converted to RPGIV.
     *      - Recompiled becuase w1trl# changed from 6 to 8 in length.
530bA*    07/08/10  RH   5.30b
     *      - Enh: Added client custom code support to program.
     *      - Enh: Display dock door assinged in truck builder.       .
     F*
640 A*    03/21/11  JGD  6.40
     *      - Enh: Add logic to load new output file record   .
     *      - Enh: Ldrtrle1/Eqrec, also, change start date    .
     *      - Enh: and time field names to "LTLDTE" and "LTLTIM".
     F*
700aA*    02/01/16  RBD  7.00a
     *      - Fix: Changed $pwhse from alpha to num to fix dec data error.
     *
     F*----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
     F*    ##/##/##  XXX-XXX
     F*      - Text . . .
     F*
     F*----------------------------------------------------------------
     F*  Cheney Custom Revisions:
CBI AF*    07/08/10  RH   CBI
     F*      - Use door from OHMISC for Cheney only.
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  60        Display product temps at item level.
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
530 D***LOAD21FM  CF   E             WORKSTN
530 MFLOAD2101  CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     FPIRUSER   IF   E           K DISK
     F*
     FPIRUSER1  IF   E           K DISK
     F                                     RENAME(USREC:USREC1)
     F*
     FORDH1     IF   E           K DISK
530bAFDocmtrx2  if   e           k disk
     F*
     FRTEHED    IF   E           K DISK
     F*
     FLDRHCOM   O    E           K DISK
     F*
     FLDRDCOM   O    E           K DISK
     F*
     FLDRTEQ    UF A E           K DISK
640 AFLDRTRLE1  UF A E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A4              S              1    DIM(4)
     D DESC            S             70    DIM(2) CTDATA PERRCD(1)
     *----------------------------------------------------------------
530bA*  Client ID's
     *
CBI A /COPY QCOPYSRC,ID#CHENEY
     *
530bAD @getcl          c                   const('GETCLIENT')
     *
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D*$PARMS      DS
     D*                                       1   30$PWHSE
     D*                                       4   8 $PRTE#
     D*                                       9  13 $PRTID
     D*                                      14  21 $PTLR#
     D*                                      22  31 $PPRG
     D*                                      32  39 $PRTN
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*  Constants
     D DIGITS          C                   CONST('0123456789 ')
     D BLNKT           C                   CONST('BLANKETS = ')
     D BLKHED          C                   CONST('BULK HEADS = ')
     D LOADBR          C                   CONST('LOAD BARS = ')
     D ICBINS          C                   CONST('IC BINS-SMALL = ')
     D ICBINM          C                   CONST('IC BINS-MEDIUM = ')
     D ICBINL          C                   CONST('IC BINS-LARGE = ')
     D SFBINS          C                   CONST('SF BINS = ')
     D STGPLT          C                   CONST('STAGED PALLET = ')
     D TOTPLT          C                   CONST('TOTAL PALLETS = ')
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
     D  $LCODE                22     23
     D*
     D SCRN1           DS
     D  CVALI                  1      4
     D  NVALO                  1      4  0
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
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERFLD                  1     30
     D  ERFROM                31     40
     D  ERTO                  41     50
     D                 DS
     D  $EC                    1      2P 0
     D*
     D                 DS
     D  DSMISC                 1     20
     D  DSSDTE                 1      8
     D  DSSPCL                 9     11
     D  DSRPCK                12     12
     D  DSDOOR                13     14
     D  DSMEAT                15     15
     D  DSCODE                16     16
     D  DSRVS                 19     19
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
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*
     C*
     C     *ENTRY        PLIST
700aDC**                 PARM                    $PWHSE            3
700aMC                   PARM                    $PWHSE            3 0
     C                   PARM                    $PRTE#            5
     C                   PARM                    $PRTID            5
     C                   PARM                    $PTLR#            8
     C                   PARM                    $PPRG            10
     C                   PARM                    $PRTN             8
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   EXSR      ZZINZ1
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC1
     C     NXTSCR        CASEQ     '04 '         SC1
     C                   ENDCS
     C*
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   SETON                                        LR
     C*----------------------------------------------------------------
     C*
     C*  CHKSAV   Check if 'Trailer Equipment' screen values were
     C*  changed by supervisor when he was closing route due to
     C*  wrong date input by loader.
     C*
     C*  The comment will be based on the first input field
     C*  found with invalid data. Comment on one field will
     C*  be enough to make the point that the loader is typing
     C*  wrong data on 'Trailer Equipment' screen.
     C*
     C*----------------------------------------------------------------
     C     CHKSAV        BEGSR
     C*
     C                   MOVE      *BLANKS       HLDCO1           35
     C                   MOVE      *BLANKS       HLDCO2           35
     C*
     C     S1BK1         IFNE      W1BK1
     C     'BEFORE: '    CAT       BLNKT         HLDCO1
     C     HLDCO1        CAT       S1BK1:1       HLDCO1
     C     'AFTER:  '    CAT       BLNKT         HLDCO2
     C     HLDCO2        CAT       W1BK1:1       HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1BH1         IFNE      W1BH1
     C     'BEFORE: '    CAT       BLKHED        HLDCO1
     C     HLDCO1        CAT       S1BH1:1       HLDCO1
     C     'AFTER:  '    CAT       BLKHED        HLDCO2
     C     HLDCO2        CAT       W1BH1:1       HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1LB1         IFNE      W1LB1
     C     'BEFORE: '    CAT       LOADBR        HLDCO1
     C     HLDCO1        CAT       S1LB1:1       HLDCO1
     C     'AFTER:  '    CAT       LOADBR        HLDCO2
     C     HLDCO2        CAT       W1LB1:1       HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1ICS1        IFNE      W1ICS1
     C     'BEFORE: '    CAT       ICBINS        HLDCO1
     C     HLDCO1        CAT       S1ICS1:1      HLDCO1
     C     'AFTER:  '    CAT       ICBINS        HLDCO2
     C     HLDCO2        CAT       W1ICS1:1      HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1ICM1        IFNE      W1ICM1
     C     'BEFORE: '    CAT       ICBINM        HLDCO1
     C     HLDCO1        CAT       S1ICM1:1      HLDCO1
     C     'AFTER:  '    CAT       ICBINM        HLDCO2
     C     HLDCO2        CAT       W1ICM1:1      HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1ICL1        IFNE      W1ICL1
     C     'BEFORE: '    CAT       ICBINL        HLDCO1
     C     HLDCO1        CAT       S1ICL1:1      HLDCO1
     C     'AFTER:  '    CAT       ICBINL        HLDCO2
     C     HLDCO2        CAT       W1ICL1:1      HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1SFB1        IFNE      W1SFB1
     C     'BEFORE: '    CAT       SFBINS        HLDCO1
     C     HLDCO1        CAT       S1SFB1:1      HLDCO1
     C     'AFTER:  '    CAT       SFBINS        HLDCO2
     C     HLDCO2        CAT       W1SFB1:1      HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1SPL1        IFNE      W1SPL1
     C     'BEFORE: '    CAT       STGPLT        HLDCO1
     C     HLDCO1        CAT       S1SPL1:1      HLDCO1
     C     'AFTER:  '    CAT       STGPLT        HLDCO2
     C     HLDCO2        CAT       W1SPL1:1      HLDCO2
     C                   GOTO      WRITE
     C                   ENDIF
     C*
     C     S1TPL1        IFNE      W1TPL1
     C     'BEFORE: '    CAT       TOTPLT        HLDCO1
     C     HLDCO1        CAT       S1TPL1:1      HLDCO1
     C     'AFTER:  '    CAT       TOTPLT        HLDCO2
     C     HLDCO2        CAT       W1TPL1:1      HLDCO2
     C                   ENDIF
      *
     C     WRITE         TAG
     C     HLDCO1        IFNE      *BLANKS
     C                   EXSR      WRTCOM
     C                   ENDIF
      *
     C     ENDCHK        ENDSR
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
     CSR                 EXFMT     WINDW1                               50
     CSR                 END
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       040506
     CSR                 SETOFF                                       070809
     CSR                 SETOFF                                       101112
     CSR                 SETOFF                                       1314
     CSR                 SETOFF                                       1920
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
     CSR                 SETOFF                                       333435
     CSR                 SETOFF                                       36
     CSR                 SETOFF                                       98
      *
     CSR                 MOVE      '0'           WARN              1
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      '0'           CMDTKN            1
      *
     CSR                 Z-ADD     0             E                 2 0
      *
     C*   Prod Integrity info is no required if HACCP flag = 'Y'
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SAVVAL   Save 'Trailer Equipment' screen values.
     C*
     C*----------------------------------------------------------------
     C     SAVVAL        BEGSR
     C*
     C                   MOVEL     W1BK1         S1BK1             4
     C                   MOVEL     W1BH1         S1BH1             4
     C                   MOVEL     W1LB1         S1LB1             4
     C                   MOVEL     W1ICS1        S1ICS1            4
     C                   MOVEL     W1ICM1        S1ICM1            4
     C                   MOVEL     W1ICL1        S1ICL1            4
     C                   MOVEL     W1SFB1        S1SFB1            4
     C                   MOVEL     W1SPL1        S1SPL1            4
     C                   MOVEL     W1TPL1        S1TPL1            4
     C*
     C     ENDSAV        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen1
     C*
     C*----------------------------------------------------------------
     CSR   SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR            3
     CSR                 MOVE      '*EXIT   '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*> Test for F5 - Refresh
     C*>
     C*>         *INKE     IFEQ '1'
     C*>         $PCMD     IFNE '*VIEW   '
     C*>                   EXSR SCR01I
     C*>                   END
     C*>                   GOTO ENDSC1
     C*>                   END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      '1'
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 MOVE      '*CANCEL '    $PRTN
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys
     C*
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*     Check input.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     '1'           ENDSC1
     C*
      *----------------------------------------------------------------
     C     PRTN2         IFEQ      'CLOSING '
     C                   EXSR      CHKSAV
     C                   ENDIF
      *----------------------------------------------------------------
     C*
640 AC*     Write or update 'Ldrteq' and 'Ldrtrle' files.
     C*
     C     UPDT          IFEQ      '1'
     C                   UPDATE    LTREC
     C                   ELSE
     C                   WRITE     LTREC
     C                   ENDIF
      *
640 AC     UPDT2         IFEQ      '1'
640 AC                   UPDATE    EQREC
640 AC                   ELSE
640 AC                   WRITE     EQREC
640 AC                   ENDIF
      *
     C                   MOVE      '*OK     '    $PRTN
      *
     C                   MOVE      'EOJ'         NXTSCR
     C*
      *
     C     ENDSC1        ENDSR
      *
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZFNAM   Format loader name.
     C*
     C*----------------------------------------------------------------
     CSR   ZZFNAM        BEGSR
     C*
     C                   MOVE      *BLANKS       FNAME
     C                   MOVE      *BLANKS       LNAME
     C*
     C                   MOVE      USEMP#        LTEMP#
     C     ' '           SCAN      USFNAM        P1                2 0
     C     P1            SUBST     USFNAM:1      FNAME            12
     C     ' '           SCAN      USLNAM        P2                2 0
     C     P2            SUBST     USLNAM:1      LNAME            16
     C*>         FNAME     CAT  LNAME:1   W1USER
     C*
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C*----------------------------------------------------------------
     CSR   *INZSR        BEGSR
     *
530bA*  Get Client ID
     *
530bAC                   call      @getcl
530bAC                   parm                    client           10
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
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*---------------------------------------------------------------
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
     C*---------------------------------------------------------------
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     C*---------------------------------------------------------------
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     C*---------------------------------------------------------------
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
     C*---------------------------------------------------------------
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     C*---------------------------------------------------------------
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     C*---------------------------------------------------------------
     CSR   ZSCLR         BEGSR
     C                   WRITE     CLRSCR
     C                   MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C*---------------------------------------------------------------
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
     C*      PIR0105 Gneric message
     C*
     C*----------------------------------------------------------------
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*    PIR0203  Value cannot be blank.
     C*
     C*----------------------------------------------------------------
     CSR   ZM0203        BEGSR
     CSR                 MOVE      'PIR0203'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     C*----------------------------------------------------------------
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Window1 error checking.
     C*
     C*----------------------------------------------------------------
     CSR   ZZCHK1        BEGSR
      *
     C                   MOVE      '0'           ERROR
     C                   MOVE      *BLANKS       ERRMSG
      *
      *  Check if user id is found in user file.
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN26
     C                   MOVEA     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   GOTO      ENDCK1
     C                   ENDIF
      *
     C     W1BK1         IFNE      *BLANKS
     C     DIGITS        CHECK     W1BK1                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C                   ELSE
     C                   MOVEL     W1BK1         HOLD4             4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTBK1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN21
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1BH1         IFNE      *BLANKS
     C     DIGITS        CHECK     W1BH1                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C                   ELSE
     C                   MOVEL     W1BH1         HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTBH1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN22
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1LB1         IFNE      *BLANKS
     C     DIGITS        CHECK     W1LB1                                  79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C                   ELSE
     C                   MOVEL     W1LB1         HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTLB1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN23
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICS1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICS1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C                   ELSE
     C                   MOVEL     W1ICS1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICS1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN24
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICM1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICM1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN25
     C                   ELSE
     C                   MOVEL     W1ICM1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICM1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN25
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1ICL1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1ICL1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN26
     C                   ELSE
     C                   MOVEL     W1ICL1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTICL1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN26
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1SFB1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1SFB1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN27
     C                   ELSE
     C                   MOVEL     W1SFB1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTSFB1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN27
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1SPL1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1SPL1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN28
     C                   ELSE
     C                   MOVEL     W1SPL1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTSPL1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN28
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
     C     W1TPL1        IFNE      *BLANKS
     C     DIGITS        CHECK     W1TPL1                                 79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN29
     C                   ELSE
     C                   MOVEL     W1TPL1        HOLD4
     C                   EXSR      ZZCONV
     C                   Z-ADD     NVALO         LTTPL1
     C                   ENDIF
     C                   ELSE
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN29
     C     ERRMSG        IFEQ      *BLANKS
     C                   MOVEA     DESC(2)       ERRMSG
     C                   EXSR      ZM0105
     C                   ENDIF
     C                   ENDIF
      *
      *
     C     ENDCK1        ENDSR
      *
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     C*----------------------------------------------------------------
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
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCONV   Convert character input to numeric value.
     C*
     C*----------------------------------------------------------------
     CSR   ZZCONV        BEGSR
      *
     C     FRFIL         IFEQ      '1'
     C                   GOTO      FRMFIL
     C                   ENDIF
      *
     C                   MOVE      '0000'        A4
     C                   MOVE      '0000'        CVALI
     C                   MOVE      ' '           HOLD1             1
     C                   Z-ADD     4             P1
     C                   Z-ADD     4             P2
      *
     C     P1            DOWNE     *ZEROS
     C                   SUBST     HOLD4:P1      HOLD1
     C     HOLD1         IFNE      *BLANK
     C                   MOVEA     HOLD1         A4(P2)
     C                   SUB       1             P2
     C                   ENDIF
     C                   SUB       1             P1
     C                   ENDDO
     C                   MOVEA     A4            CVALI
     C                   GOTO      ENDCNV
      *
      *
     C     FRMFIL        TAG
      *
     C                   MOVE      *BLANKS       A4
     C                   MOVE      *BLANKS       CVALO             4
     C                   MOVE      ' '           HOLD1
     C                   Z-ADD     1             P1
     C                   Z-ADD     1             P2
      *
     C     P1            DOWNE     5
     C                   SUBST     HOLD4:P1      HOLD1
     C     HOLD1         IFNE      '0'
     C     P2            ORGT      1
     C                   MOVEA     HOLD1         A4(P2)
     C                   ADD       1             P2
     C                   ENDIF
     C                   ADD       1             P1
     C                   ENDDO
     C                   MOVEA     A4            CVALO
      *
     CSR   ENDCNV        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ1   Program initialization. Called from main line.
     C*
     C*----------------------------------------------------------------
     CSR   ZZINZ1        BEGSR
     C*
640 AC                   MOVE      $PWHSE        WHSE              3 0
     C*
     C*  Define key for main file.
     C*
     C     HDRKEY        KLIST
640 DC*                  KFLD                    $PWHSE
640 MC                   KFLD                    WHSE
     C                   KFLD                    $PRTE#
     C                   KFLD                    $PRTID
      *
     C     RTKEY         KLIST
640 DC*                  KFLD                    $PWHSE
640 MC                   KFLD                    WHSE
     C                   KFLD                    $PRTID
      *
     C     OHKEY         KLIST
     C                   KFLD                    RHPBAT
640 DC*                  KFLD                    $PWHSE
640 MC                   KFLD                    WHSE
     C                   KFLD                    $PRTID
     *
530b C     dckey         klist
640 DC*                  kfld                    $pwhse
640 MC                   kfld                    whse
530b C                   kfld                    $prtid
      *
      * Load output file 'Ldrteq' fields and screen fields.
      *
640 DC*                  MOVE      $PWHSE        LTWHSE
640 MC                   MOVE      WHSE          LTWHSE
     C                   MOVEL     $PRTE#        W1RTE#
     C                   MOVEL     $PRTE#        LTRTE
     C                   MOVEL     $PRTID        LTRTID
     C                   MOVEL     $PTLR#        W1TRL#
     C                   MOVE      $PTLR#        LTTRLR
     C                   MOVEL     $PRTN         PRTN2             8
     C                   MOVE      *BLANKS       $PRTN
     C                   MOVE      *BLANKS       W1BK1
     C                   MOVE      *BLANKS       W1BH1
     C                   MOVE      *BLANKS       W1LB1
     C                   MOVE      *BLANKS       W1ICS1
     C                   MOVE      *BLANKS       W1ICM1
     C                   MOVE      *BLANKS       W1ICL1
     C                   MOVE      *BLANKS       W1SFB1
     C                   MOVE      *BLANKS       W1SPL1
     C                   MOVE      *BLANKS       W1TPL1
     C                   MOVE      *BLANKS       ERRMSG
     C*
     C                   MOVE      '*MDYCMD '    $CVCMD
     C                   MOVE      #JOBDT        $CVD6I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
640 MC                   MOVE      $CVD8O        LTLDTE
640 MC                   TIME                    LTLTIM
      *
      *
      *  Get loading door number
     C                   MOVE      *BLANKS       W1DOOR
      *
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *OFF
      *
530b C                   SELECT
530bAC                   WHEN      CLIENT = CHENEY
     C     OHKEY         SETLL     ORDH1
     C     OHKEY         READE     ORDH1                                  79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      OHMISC        DSMISC
     C                   MOVEL     DSDOOR        W1DOOR
     C                   ENDIF
530bAC                   other
530bAC     dckey         setll     docmtrx2
530bAC     dckey         reade     docmtrx2                               79
530bAC                   if        not *in79
530bAC                   move      dmdoor        w1door
530bAC                   endif
530bAC                   endsl
     C                   ENDIF
      *
     C                   SETON                                          90
      *
     C                   MOVE      '01 '         NXTSCR
     C     BYPAS1        TAG
      *
     C                   MOVE      '0'           FRFIL             1
      *
     C     HDRKEY        CHAIN     LDRTEQ                             79
     C     *IN79         IFEQ      *OFF
      *
      *  Trailer Equipment has been loaded.
     C                   MOVE      '1'           FRFIL
      *
     C     LTBK1         IFEQ      *ZEROS
     C                   MOVEL     '0'           W1BK1
     C                   ELSE
     C                   MOVEL     LTBK1         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1BK1
     C                   ENDIF
      *
     C     LTBH1         IFEQ      *ZEROS
     C                   MOVEL     '0'           W1BH1
     C                   ELSE
     C                   MOVEL     LTBH1         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1BH1
     C                   ENDIF
      *
     C     LTLB1         IFEQ      *ZEROS
     C                   MOVEL     '0'           W1LB1
     C                   ELSE
     C                   MOVEL     LTLB1         HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1LB1
     C                   ENDIF
      *
     C     LTICS1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1ICS1
     C                   ELSE
     C                   MOVEL     LTICS1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICS1
     C                   ENDIF
      *
     C     LTICM1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1ICM1
     C                   ELSE
     C                   MOVEL     LTICM1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICM1
     C                   ENDIF
      *
     C     LTICL1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1ICL1
     C                   ELSE
     C                   MOVEL     LTICL1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1ICL1
     C                   ENDIF
      *
     C     LTSFB1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1SFB1
     C                   ELSE
     C                   MOVEL     LTSFB1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1SFB1
     C                   ENDIF
      *
     C     LTSPL1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1SPL1
     C                   ELSE
     C                   MOVEL     LTSPL1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1SPL1
     C                   ENDIF
      *
     C     LTTPL1        IFEQ      *ZEROS
     C                   MOVEL     '0'           W1TPL1
     C                   ELSE
     C                   MOVEL     LTTPL1        HOLD4
     C                   EXSR      ZZCONV
     C                   MOVEL     CVALO         W1TPL1
     C                   ENDIF
      *
      *  Set name of user found in record
      *  (trailer equipment info already existed).
      *
     C     LTEMP#        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN26
     C                   MOVEA     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   ENDIF
      *
      *
640 AC     LTLDTE        IFNE      *ZEROS
     C*>                   MOVE '*CMDMDY '$CVCMD
640 AC*>                   MOVE LTLDTE    $CVD8I
     C*>                   CALL @CVTDT
     C*>                   PARM           $CVTDT
     C*>                   Z-ADD$CVD6O    W1DATE
     C                   ENDIF
     C                   MOVE      '1'           UPDT              1
     C                   MOVE      '0'           FRFIL
      *
     C                   ELSE
      *
      *  Trailer Equipment has not been loaded yet
      *  Set name of user loading trailer equipment
      *  information (1st time).
      *
     C                   MOVE      '0'           UPDT
      *
     C     #USER         CHAIN     PIRUSER                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *ON           ERROR
     C                   MOVE      *ON           *IN01
     C                   MOVE      *ON           *IN26
     C                   MOVEA     DESC(1)       ERRMSG
     C                   EXSR      ZM0105
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   ENDIF
     C                   ENDIF
      *
      *----------------------------------------------------------------
     C     PRTN2         IFEQ      'CLOSING '
     C                   EXSR      SAVVAL
     C                   ENDIF
      *
640 AC     HDRKEY        CHAIN     LDRTRLE1                           79
640 AC     *IN79         IFEQ      *OFF
640 AC                   MOVE      '1'           UPDT2             1
640 AC                   ELSE
640 AC                   MOVE      '0'           UPDT2
640 AC                   ENDIF
      *
      *
640 A *  Load output file 'Ldrtrle' fields.
640 AC                   Z-ADD     LTWHSE        LEWHSE
640 AC                   MOVEL     LTRTE         LERTE
640 AC                   MOVEL     LTRTID        LERTID
640 AC                   MOVE      LTTRLR        LETRL#
640 AC                   MOVE      'O'           LESTAT
640 AC                   Z-ADD     LTLDTE        LEDATE
640 AC                   Z-ADD     LTLTIM        LETIME
      *
      *----------------------------------------------------------------
     CSR   ENDINZ        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  WRTCOM   Write comment on supervisor modified loader input
     C*  'Trailer Equipment' info.
     C*
     C*----------------------------------------------------------------
     C     WRTCOM        BEGSR
640 A *
640 A *  Get emp# of user closing route and loaded in comm header & detail
640 A *
640 AC     #USER         CHAIN     PIRUSER                            79
640 AC     *IN79         IFEQ      *OFF
640 AC                   Z-ADD     USEMP#        EMPSUP            5 0
640 AC                   ELSE
640 AC                   Z-ADD     *ZEROS        EMPSUP
640 AC                   ENDIF
     C*
     C* Get current date in century format
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   MOVE      $CVD8O        DATE8             8 0
      *
     C                   CLEAR                   LCHREC
640 DC*                  Z-ADD     $PWHSE        LCHWHS
640 MC                   Z-ADD     WHSE          LCHWHS
     C                   MOVE      $PRTID        LCHRTI
     C                   MOVE      $PRTE#        LCHRTE
     C                   MOVE      $PTLR#        LCHTRL
     C                   Z-ADD     DATE8         LCHSTD
     C                   TIME                    LCHSTT
640 MC                   Z-ADD     EMPSUP        LCHEMP
     C                   WRITE     LCHREC
      *
     C                   CLEAR                   LCDREC
640 DC*                  Z-ADD     $PWHSE        LCDWHS
640 MC                   Z-ADD     WHSE          LCDWHS
     C                   MOVE      $PRTID        LCDRTI
     C                   MOVE      $PRTE#        LCDRTE
     C                   Z-ADD     DATE8         LCDSTD
     C                   TIME                    LCDSTT
      *
     C                   MOVE      HLDCO1        LCDCO1
     C                   MOVE      HLDCO2        LCDCO2
      *
     C                   MOVE      '3 '          LCDTYP
     C                   MOVE      '8 '          LCDRSC
640 MC                   Z-ADD     EMPSUP        LCDEMP
     C                   WRITE     LCDREC
      *
     C     ENDWRT        ENDSR
     C*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*
**  DESC
User not found
Invalid input
