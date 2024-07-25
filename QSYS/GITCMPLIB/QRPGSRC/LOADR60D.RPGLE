     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LOADR60D  Verified Returned Trailer Equip - Driver Invoice Report
     F*
     F*  December 11, 2008
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
     FLDR26b    IP   E           K DISK
     F*
     FWAREHS    IF   E           K DISK
     FLDRHHDR   IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
     F*
     FLOAD60DPR O    E             PRINTER OFLIND(*IN90)
     I*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Constants
     D DESC1           C                   CONST('BLANKETS       ')
     D DESC2           C                   CONST('BULKHEADS      ')
     D DESC3           C                   CONST('BARS           ')
     D DESC4           C                   CONST('IC BINS-SMALL  ')
     D DESC5           C                   CONST('IC BINS-MEDIUM ')
     D DESC6           C                   CONST('IC BINS-LARGE  ')
     D DESC7           C                   CONST('SEA FOOD BINS  ')
     D DESC8           C                   CONST('STAGED PALLETS ')
     D DESC9           C                   CONST('TOTAL PALLETS  ')
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
     ILTREC3
     I                                          LTDEMP        L1
     I*----------------------------------------------------------------
     C*
     C*  Report Heading
     C*
     C*
     C*  Start new page if one of following happened.
     C*     - Level break occurred.
     C*     - Filled page.
     C*
      *
     C     *ENTRY        PLIST
     C                   PARM                    $FDTE6            6
     C                   PARM                    $TDTE6            6
     C*
     C     FIRST         IFEQ      *ON
     C                   Z-ADD     LTDEMP        SAVEMP            5 0
     C                   EXSR      ZRFRMT
     C*>                 MOVE      *OFF          FIRST
     C                   ENDIF
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C                   EXSR      ZRDETL
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
     CLR   REC#          IFGT      0
     CLR   RECPAG        SUB       COUNT         LINLFT            3 0
      *
      *
     C*>LR   COUNT         IFNE      RECPAG
     CLR   LINLFT        IFGE      6
     CLR                 WRITE     SKIP1
     CLR                 EXSR      ZZSUBT
     CLR                 ELSE
     CLR                 WRITE     SKIPAG
     C*>LR                 EXSR      ZRHEAD
     CLR                 EXSR      ZZSUBT
     CLR                 ENDIF
     C*>LR                 ENDIF
      *
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
     C                   Z-ADD     0             EXCPT#            5 0
     C                   Z-ADD     55            RECPAG            3 0
      *
     C     HDRKEY        KLIST
     C                   KFLD                    LTWHSE
     C                   KFLD                    LTRTE
     C                   KFLD                    LTRTID
      *
     C                   EXSR      ZRCLER
     C                   EXSR      ZRZERO
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRCHKL        BEGSR
     C*----------------------------------------------------------------
      *
     C     RECPAG        SUB       COUNT         LINLFT            3 0
      *
     C     COUNT         IFNE      RECPAG
     C     *INL1         IFEQ      *ON
      *
     C     LINLFT        IFGE      6
     C                   EXSR      ZZSUBT
     C                   EXSR      ZRHEAD
     C                   SETOFF                                       L1
     C                   ELSE
     C                   WRITE     SKIPAG
     C                   EXSR      ZZSUBT
     C                   EXSR      ZRHEAD
     C                   SETOFF                                       L1
     C                   ENDIF
      *
     C                   GOTO      BYPASS
     C                   ENDIF
     C                   GOTO      BYPASS
     C                   ENDIF
      *
     C     COUNT         IFEQ      RECPAG
     C     *INL1         IFEQ      *ON
     C                   WRITE     SKIPAG
     C                   EXSR      ZZSUBT
     C                   EXSR      ZRHEAD
     C                   SETOFF                                       L1
     C                   ELSE
     C                   WRITE     SKIPAG
     C                   WRITE     COLUMNS
     C                   Z-ADD     *ZEROS        COUNT
     C*-->               EXSR      ZRHEAD
     C                   ENDIF
     C                   ENDIF
      *
     C     BYPASS        TAG
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    Original ZRCHKL 12/12/08  Delete when rtn above is OK
     C*----------------------------------------------------------------
     C     ZRCHKL1       BEGSR
     C*----------------------------------------------------------------
      *
     C     RECPAG        SUB       COUNT         LINLFT            3 0
      *
     C     COUNT         IFNE      RECPAG
     C     *INL1         IFEQ      *ON
     C                   EXSR      ZZSUBT
     C*>                 EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   SETOFF                                       L1
     C                   ENDIF
     C*-->               GOTO      BYPASS
     C                   ENDIF
      *
     C     COUNT         IFEQ      RECPAG
     C     *INL1         IFEQ      *ON
     C                   EXSR      ZZSUBT
     C*>                 EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   SETOFF                                       L1
     C                   ENDIF
     C                   ELSE
     C*                  EXSR      ZZSUBT
     C                   EXSR      ZRHEAD
     C                   ENDIF
      *
     C*--> BYPASS        TAG
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
      *  Set name of loader that loaded equipment
      *
     C*
     C*  Print headings for the next page.
     C*
     C                   WRITE     HEAD1
     C                   WRITE     COLUMNS
     C*
     C*
     C*  Print previous page detail lines.
     C*
     C                   Z-ADD     0             COUNT
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRCLER        BEGSR
     C*----------------------------------------------------------------
     C*
     C*   Initialize all data structures.
     C*
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRDETL        BEGSR
     C*----------------------------------------------------------------
      *
     C                   MOVE      *BLANKS       W1DESC
     C                   Z-ADD     *ZEROS        W1LOAD
     C                   Z-ADD     *ZEROS        W1UNLD
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
      *--->
     C     LTRTE         IFNE      SAVRTE
     C     LTRTID        ANDNE     SAVRTI
     C     HDRKEY        CHAIN     LDRHHDR                            79
     C     *IN79         IFEQ      *OFF
      *
     C                   MOVEL     LTRTE         SAVRTE            5
     C                   MOVEL     LTRTID        SAVRTI            5
      *
     C                   MOVEL     LHHRTE        W1RTE#
      *
      *  Set name of loader that loaded equipment
      *
     C                   MOVEL     LTDNAM        W1DNAM
      *
      *  Get loading door number
     C                   MOVE      LHHDOR        W1DOOR
     C*
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LHHSTD        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1DATE
     C*
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LTRDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1RDTE
     C*>                 MOVE      LTRTIM        W1RTIM
      *
      *  Move Route Driver name into report
     C*--->              MOVEL     LTDNAM        W1DNAM
      *
      *  Set name of user who verified the equipment return
      *
     C     LTREMP        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       W1RUSR
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   MOVEL     HLDNAM        W1RUSR
     C                   ENDIF
      *
     C*  Skip a print line.
     C                   WRITE     SKIP1
     C                   ADD       1             COUNT
     C                   EXSR      ZRCHKL
      *
     C                   ENDIF
     C                   ENDIF
      *--->
     C     LTSO1         IFNE      *ZEROS
     C                   MOVEL     DESC1         W1DESC
     C                   Z-ADD     LTBK1         W1LOAD
     C                   Z-ADD     LTBK2         W1UNLD
     C     LTSO1         IFLT      *ZERO
     C                   Z-ADD     LTSO1         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO1         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO2         IFNE      *ZEROS
     C                   MOVEL     DESC2         W1DESC
     C                   Z-ADD     LTBH1         W1LOAD
     C                   Z-ADD     LTBH2         W1UNLD
     C     LTSO2         IFLT      *ZERO
     C                   Z-ADD     LTSO2         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO2         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO3         IFNE      *ZEROS
     C                   MOVEL     DESC3         W1DESC
     C                   Z-ADD     LTLB1         W1LOAD
     C                   Z-ADD     LTLB2         W1UNLD
     C     LTSO3         IFLT      *ZERO
     C                   Z-ADD     LTSO3         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO3         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO4         IFNE      *ZEROS
     C                   MOVEL     DESC4         W1DESC
     C                   Z-ADD     LTICS1        W1LOAD
     C                   Z-ADD     LTICS2        W1UNLD
     C     LTSO4         IFLT      *ZERO
     C                   Z-ADD     LTSO4         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO4         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO5         IFNE      *ZEROS
     C                   MOVEL     DESC5         W1DESC
     C                   Z-ADD     LTICM1        W1LOAD
     C                   Z-ADD     LTICM2        W1UNLD
     C     LTSO5         IFLT      *ZERO
     C                   Z-ADD     LTSO5         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO5         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO6         IFNE      *ZEROS
     C                   MOVEL     DESC6         W1DESC
     C                   Z-ADD     LTICL1        W1LOAD
     C                   Z-ADD     LTICL2        W1UNLD
     C     LTSO6         IFLT      *ZERO
     C                   Z-ADD     LTSO6         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO6         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO7         IFNE      *ZEROS
     C                   MOVEL     DESC7         W1DESC
     C                   Z-ADD     LTSFB1        W1LOAD
     C                   Z-ADD     LTSFB2        W1UNLD
     C     LTSO7         IFLT      *ZERO
     C                   Z-ADD     LTSO7         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO7         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO8         IFNE      *ZEROS
     C                   MOVEL     DESC8         W1DESC
     C                   Z-ADD     LTSPL1        W1LOAD
     C                   Z-ADD     LTSPL2        W1UNLD
     C     LTSO8         IFLT      *ZERO
     C                   Z-ADD     LTSO8         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO8         W1SHRT
     C                   ENDIF
     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   Z-ADD     *ZEROS        W1OVER
     C                   Z-ADD     *ZEROS        W1SHRT
      *
     C     LTSO9         IFNE      *ZEROS
     C                   MOVEL     DESC9         W1DESC
     C                   Z-ADD     LTTPL1        W1LOAD
     C                   Z-ADD     LTTPL2        W1UNLD
     C     LTSO9         IFLT      *ZERO
     C                   Z-ADD     LTSO9         W1OVER
     C                   ELSE
     C                   Z-ADD     LTSO9         W1SHRT
     C                   ENDIF
      *
     C                   MOVEL     LTRTE         W1RTE#

     C*  Print detail line.
     C                   WRITE     DETAIL1
     C                   ADD       2             COUNT
     C                   ADD       1             REC#
     C                   ADD       1             EXCPT#
     C                   EXSR      ZRCHKL
     C*
     C                   ENDIF
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZZSUBT        BEGSR
     C*----------------------------------------------------------------
     C     FIRST         IFEQ      *ON
     C                   MOVE      *OFF          FIRST
     C                   GOTO      BYPAS2
     C                   ENDIF
      *
     C                   WRITE     SKIP1
     C                   Z-ADD     SAVEMP        W1EMP#
     C                   Z-ADD     EXCPT#        W1EXCP
     C                   WRITE     TOTAL1
      *
     C                   Z-ADD     *ZEROS        EXCPT#            5 0
     C                   Z-ADD     LTDEMP        SAVEMP
      *
     C     BYPAS2        TAG
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRZERO        BEGSR
     C*----------------------------------------------------------------
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZFNAM   Format loader name.
     C*----------------------------------------------------------------
     CSR   ZZFNAM        BEGSR
     C*----------------------------------------------------------------
     C*
     C                   MOVE      *BLANKS       FNAME
     C                   MOVE      *BLANKS       LNAME
     C                   MOVE      *BLANKS       HLDNAM
     C*
     C     ' '           SCAN      USFNAM        P1                2 0
     C     P1            SUBST     USFNAM:1      FNAME            12
     C     ' '           SCAN      USLNAM        P2                2 0
     C     P2            SUBST     USLNAM:1      LNAME            16
     C     FNAME         CAT       LNAME:1       HLDNAM           28
     C*
      *
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
