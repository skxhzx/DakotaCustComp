     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LOADR60G  Returned Trailer Equipment Summary by Driver - Report
     F*
     F*  January 22, 2009
     F*  Jose G. Duque
     F*
     F*  Revisions:
     F*
     F*    03/10/11  JGD  6.40
     F*      - Created
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLDR27B    IP   E           K DISK
     F*
     FWAREHS    IF   E           K DISK
     F*
     FLOAD60GPR O    E             PRINTER OFLIND(*IN90)
     I*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Constants
     F*
     D NAME            C                   CONST('MOLTIER CHARLES')
     F*
     I*----------------------------------------------------------------
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
      *
     C     *ENTRY        PLIST
     C                   PARM                    $FDTE6            6
     C                   PARM                    $TDTE6            6
     C*
     C*
     C*
     C*
     D*----------------------------------------------------------------
     C*  Report Heading
     C*  Start new page if first time thru.
     C*
     C     FIRST         IFEQ      *ON
     C                   Z-ADD     LTDRV#        SAVDRV#           5 0
     C                   MOVEL     LTDRVN        W1USER
     C                   EXSR      ZRCLER
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     C*
     C     LTDRVN        IFEQ      NAME
     C                   MOVE      'Y'           YES               1
     C                   ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C     LTDRV#        IFNE      SAVDRV#
     C                   EXSR      ZRDETL
     C                   Z-ADD     LTDRV#        SAVDRV#
     C                   MOVEL     LTDRVN        W1USER
     C                   EXSR      ZRCLER
     C*--->              EXSR      ZRCHKL
     C                   ENDIF
      *
     C     LTEQUP        IFEQ      SAVEQP
     C                   ADD       LTSHRT        HLDSHRT           6 0
     C                   ADD       LTOVER        HLDOVER           6 0
     C                   ADD       LTDIFF        HLDDIFF           6 0
     C                   ELSE
     C                   EXSR      ZRDETL
     C                   MOVEL     LTEQUP        W1DESC
     C                   MOVEL     LTEQUP        SAVEQP
     C                   Z-ADD     LTSHRT        HLDSHRT
     C                   Z-ADD     LTOVER        HLDOVER
     C                   Z-ADD     LTDIFF        HLDDIFF
     C                   ENDIF
      *
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
     CLR   REC#          IFGT      0
     CLR   RECPAG        SUB       COUNT         LINLFT            3 0
      *
     CLR   COUNT         IFNE      RECPAG
     CLR   LINLFT        IFGE      3
     CLR                 WRITE     DETAIL1
     CLR                 ELSE
     CLR                 EXSR      ZRCHKL
     CLR                 ENDIF
     CLR                 ENDIF
      *
     C*>LR                 WRITE     TOTAL2
     CLR                 WRITE     FOOT1
     CLR                 ENDIF
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
     C*
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
     C                   Z-ADD     0             REC#              3 0
     C                   Z-ADD     0             COUNT             3 0
     C                   Z-ADD     1             LTWHSE            3 0
     C                   Z-ADD     55            RECPAG            3 0
      *
     C                   EXSR      ZRZERO
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRCHKL        BEGSR
     C*----------------------------------------------------------------
      *
     C     RECPAG        SUB       COUNT         LINLFT            3 0
      *
     C     COUNT         IFNE      RECPAG
     C     LINLFT        IFGT      3
     C     LTDRV#        ANDNE     SAVDRV#
     C                   WRITE     SKIP1
     C                   ADD       1             COUNT
     C                   ENDIF
     C*
     C     LINLFT        IFLT      3
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C                   ELSE
     C                   EXSR      ZRHEAD
     C                   ENDIF
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRFRMT        BEGSR
     C*----------------------------------------------------------------
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      $FDTE6        FRMDTE
     C                   MOVE      $TDTE6        TODTE
     C                   MOVE      *BLANKS       WHSE
     C                   MOVE      *BLANKS       $PSTR
     C     LTWHSE        CHAIN     WAREHS                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     WHDESC        $PSTR            60
     C                   ELSE
     C                   MOVE      *BLANKS       $PSTR
     C                   ENDIF
     C                   Z-ADD     30            $PLEN             3 0
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         WHSE
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRHEAD        BEGSR
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *OFF          *IN90
      *
     C*  Print headings for the next page.
     C*
     C                   WRITE     HEAD1
     C                   WRITE     COLUMNS
     C                   WRITE     SKIP1
     C*
     C                   Z-ADD     1             COUNT
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRCLER        BEGSR
     C*----------------------------------------------------------------
     C*
     C*   Initialize all data structures.
     C*
     C                   MOVEL     LTEQUP        SAVEQP           15
     C                   MOVEL     LTEQUP        W1DESC
     C                   Z-ADD     *ZEROS        HLDSHRT
     C                   Z-ADD     *ZEROS        HLDOVER
     C                   Z-ADD     *ZEROS        HLDDIFF
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRDETL        BEGSR
     C*----------------------------------------------------------------
      *
     C                   Z-ADD     HLDSHRT       W1SHRT
     C                   Z-ADD     HLDOVER       W1OVER
     C                   Z-ADD     HLDDIFF       W1DIFF
      *
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       1             COUNT
     C                   ADD       1             REC#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRZERO        BEGSR
     C*----------------------------------------------------------------
     C*
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
