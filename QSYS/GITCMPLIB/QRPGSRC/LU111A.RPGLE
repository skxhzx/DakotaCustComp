      /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LU111A    Transactions lookup by user/start date - Print
     F*  24 September 2008
     F*  Ginger Andrews
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
     F*    09/24/08  GJA   6.00
     F*      - Creation
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FPIRTRAN2  IF   E           K DISK             rename(ptrec:record)
     FPIRUSER1  IF   E           K DISK
     FTASKDET   IF   E           K DISK
     FSHIFT1    IF   E           K DISK
     FLABEL90   IF   E           K DISK
     FWORKLBL   IF   E           K DISK
     FLU111PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
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
     D  ERCNT                  1      3P 0
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
     D*  Table and Array
     D*
     D A80             s              1    dim(80)
     D OVRPRT          s             80    dim(1) CTDATA PERRCD(1)
     D NOTFND          s             22    dim(1)
     D*----------------------------------------------------------------
     Dget              S              1
     Dfirst            S              1
     I*----------------------------------------------------------------
     I*  Input record
     I*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $RTNCD            8
     C                   PARM                    $PFMDT            8
     C                   PARM                    $PENDT            8
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PTASK            6
     C                   PARM                    $PCAT             6
     C                   PARM                    $PSCAT            6
     C                   PARM                    $PFMTM            6
     C                   PARM                    $PTOTM            6
     C*----------------------------------------------------------------
     C*  Main Line
     C*
     C                   READ      RECORD                                 79
     C     *IN79         IFEQ      *OFF
     C*
     C*  Get employee name
     C*
     C                   EXSR      ZEMP#
     C*
     C*  Start new page if one of following happened.
     C*
     C     FIRST         IFEQ      *OFF
     C                   TIME                    TIME
     C                   EXSR      ZRHEAD
     C                   MOVE      *ON           FIRST
     C                   ENDIF
     C*
     C*
     C*  Print detail line.
     C*
     C*
     C                   IF        get=*on
     C                   IF        *in90=*on
     C                   EXSR      ZRHEAD
     C                   eval      *in90=*off
     C                   ENDIF
     C                   WRITE     DETAIL1
     C                   eval      get=*off
     C                   ENDIF
     C                   ELSE
     C                   MOVE      '*CANCEL '    $RTNCD
     C                   MOVE      *ON           *INLR
     C                   RETURN
     C                   ENDIF
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
     C*  Define keys
     C                   MOVE      *OFF          FIRST
     C*  Define variables
     C*
     C                   MOVE      $PFMDT        FRMDTE            8 0
     C                   MOVE      $PENDT        ENDDTE            8 0
     C*
     C     TDKEY         KLIST
     C                   KFLD                    PTTASK
     C                   KFLD                    PTWHSE
     C                   KFLD                    W1WHDP
     C                   KFLD                    PTSTYP
     C*
     C     LBKEY         KLIST
     C                   KFLD                    PTWHSE
     C                   KFLD                    PTTRN#
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY             8 0
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C*   Print title and headings
     C*
     C                   WRITE     HEAD1
     C                   WRITE     COLUMN
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZEMP#         BEGSR
     C*
     C*   Get employee name
     C*
     C                   MOVE      *BLANKS       W1UNAM
     C     PTEMP#        IFGT      0
     C     PTEMP#        CHAIN     PIRUSER1                           71
     C     *IN71         IFEQ      *OFF
     C                   MOVE      '*LFM    '    $CMD              8
     C                   MOVE      *BLANKS       $NAME            40
     C                   CALL      'FRMTNM'
     C                   PARM                    $CMD
     C                   PARM                    USFNAM
     C                   PARM                    USINIT
     C                   PARM                    USLNAM
     C                   PARM                    $NAME
     C                   MOVEL     $NAME         W1UNAM
     C                   ELSE
     C                   MOVEA     NOTFND        W1UNAM
     C                   ENDIF
     C                   ENDIF
     C                   exsr      zshift
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZSHIFT        BEGSR
     C*
     C*   Get shift
     C*
     C                   MOVE      $PFMTM        SHSTIM
     C                   MOVE      $PTOTM        SHETIM
     C                   IF        SHETIM = 0 AND SHSTIM = 0
     C     SHKEY1        KLIST
     C                   KFLD                    USSHFT
     C     SHKEY1        SETLL     SHIFT1
     C     SHKEY1        READE     SHIFT1                                 72
     C     *IN72         IFEQ      *ON
     C                   Z-ADD     0             SHSTIM
     C                   Z-ADD     0             SHETIM
     C                   ENDIF
     C                   ENDIF
     C*
     C     PTSDTE        IFEQ      FRMDTE
     C     PTSTIM        ANDLT     SHSTIM
     C     PTSDTE        orEQ      ENDDTE
     C     PTSTIM        ANDGT     SHETIM
     C                   Else
     C                   exsr      Zzone
     C                   ENDIF
     C*                  ENDIF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     Zzone         BEGSR
     C*
     C*  Check for selection records
     C*
     C                   MOVE      PTWHDP        W1WHDP
     C     PTCAT         IFEQ      'SELECT'
     C     LBKEY         CHAIN     LABEL90                            73
     C     *IN73         IFEQ      *OFF
     C     LBLBL#        CHAIN     WORKLBL                            74
     C     *IN74         IFEQ      *OFF
     C                   MOVEL     LWSZON        W1WHDP
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
     C     $PWHDP        IFEQ      '*ALL '
     C     $PWHDP        OREQ      '     '
     C     W1WHDP        OREQ      $PWHDP
     C                   Exsr      zstds
     C                   ENDIF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     Zdate         BEGSR
     C*
     C*
     C*   Start date
     C*
     C     PTSDTE        IFEQ      0
     C                   Z-ADD     0             W1SDTE
     C                   ELSE
     C                   MOVE      '*YMDMDY '    $CVCMD
     C                   MOVE      PTSDTE        $CVD6I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1SDTE
     C                   ENDIF
     C*
     C*   End date
     C*
     C     PTEDTE        IFEQ      0
     C                   Z-ADD     0             W1EDTE
     C                   ELSE
     C                   MOVE      '*YMDMDY '    $CVCMD
     C                   MOVE      PTEDTE        $CVD6I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1EDTE
     C                   ENDIF
     C*  Calculate time
     C     PTDMIN        IFGT      0
     C     PTDMIN        DIV       60            W1HRS
     C                   MVR                     W1MIN
     C                   ELSE
     C     PTIMIN        DIV       60            W1HRS
     C                   MVR                     W1MIN
     C                   ENDIF
     C                   eval      get=*ON
     C                   ENDsr
     C*----------------------------------------------------------------
     C*
     C     Zstds         BEGSR
     C*
     C*  Get standards
     C     TDKEY         CHAIN     TASKDET                            75
     C     *IN75         IFEQ      *OFF
     C                   Z-ADD     TDSTDP        W1STDP
     C                   ELSE
     C                   Z-ADD     0             W1STDP
     C                   ENDIF
     C*
     C                   Z-ADD     0             STDPPM            9 5
     C                   Z-ADD     0             ACTPPM            9 5
     C*   Std pcs per hr / 60 =  Std pcs per min
     C     W1STDP        DIV       60            STDPPM
     C*   Pcs picked / Min =  Pcs picked per min
     C     PTDMIN        IFGT      0
     C     PTPCS         DIV       PTDMIN        ACTPPM
     C                   ENDIF
     C     PTIMIN        IFGT      0
     C     PTPCS         DIV       PTIMIN        ACTPPM
     C                   ENDIF
     C*   Pcs picked per min / Std pcs per min = % of standard
     C     STDPPM        IFGT      0
     C     ACTPPM        DIV       STDPPM        T#PCNT            9 5
     C     T#PCNT        MULT      100           W1PCNT
     C                   ELSE
     C                   Z-ADD     0             W1PCNT
     C                   ENDIF
     C                   Exsr      zdate
     C                   ENDsr
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**   OVRPRTF statment
OVRPRTF FILE(LU111PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
