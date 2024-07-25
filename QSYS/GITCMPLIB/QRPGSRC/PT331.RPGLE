     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PT331     Print Open Put-away transactions
     F*  Hemant Kapadia
     F*  17 September, 1999
     F*
     F*  9.17.99 HNK  4.12
     F*  - Created
     F*
     F*  Revisions
413 AF*    03/23/00  RH   4.13
     F*      - Add status, 1=OPEN 2=STARTED 3=ENDED 4=FINISHED
414aAF*    06/28/00  RH   4.14a
     F*      - Add first pick slot, W1PICK
414bAF*    08/04/00  RH   4.14b
     F*      - Add Trans. date, W1GDTE
416 AF*    09/07/01  HNK  4.16
     F*      - Add department.
416aAF*    09/18/01  RH   4.16a
     F*      - Add generated time, W1GTIM
     F*
417 AF*    05/16/03  MLB  4.17
     F*      - Enh: Program recompiled after printer file reformatted
     F*        to support extended license plate field.
700 AF*    02/02/16  RH   7.00
     F*      - Enh: Replace status with item department.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Cheney Brothers.
     F*
CBIaAF*    12/06/16  JGD  CBIa
     F*      - Report on new field W1ACTV to hold Piritem/Itactv
     F*        when client is Cheney.
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
     FPT331     IP   E           K DISK
     FWAREHS    IF   E           K DISK
     FLABEL7    IF   E           K DISK
414aAFSLOT3     IF   E           K DISK
     FPT331PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D*                   RPD     1   3 30
     D RECK            S              7  0 DIM(3)
     D LVLK            S              7  0 DIM(3)
     D A22             S              1    DIM(22)
     D DTE             S             22    DIM(4) CTDATA PERRCD(1)
413 AD STA             S              8    DIM(4) CTDATA PERRCD(1)
     D*
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

CBIaA /copy qcopysrc,id#cheney

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
     D*  Date redefinition data structure
     D*
     D $PFMDT          DS
     D  $PFMCC                 1      2
     D  $PFMYY                 3      4
     D  $PFMMM                 5      6
     D  $PFMDD                 7      8
     D $PTODT          DS
     D  $PTOCC                 1      2
     D  $PTOYY                 3      4
     D  $PTOMM                 5      6
     D  $PTODD                 7      8
     *----------------------------------------------------------------
     *  Variables
     *
     D client          s             10
     *----------------------------------------------------------------

650cAD $emp#           s              5  0
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PFMDT            8
     C                   PARM                    $PTODT            8
416 AC                   PARM                    $PWHDP            5
     C*
     C*----------------------------------------------------------------
     C*
     C*  Report Heading
     C*
     C*
     C     *IN90         IFEQ      '1'
     C     FIRST         OREQ      *ON
     C                   EXSR      ZRZERO
     C                   EXSR      ZRHEAD
     C                   END
     C*
     C*  Init total levels
     C*
     C*
     C*  Level 1 break -
     C*
     C*          *INL1     IFEQ '1'
     C*                    Z-ADD1         L
     C*                    END
     C*
     C*  Output Headings
     C*
     C     *IN91         IFEQ      *ON
     C     FIRST         OREQ      *ON
     C                   WRITE     COLUMNS
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*
     C*  Write detail line
     C*
     C* Label7 file is a join file to item file.  There will be only
     C* one putaway label for a transaction.
     C*
     C     LB7KEY        SETLL     LABEL7
     C     1             DOWEQ     1
     C     LB7KEY        READE     LABEL7                                 79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C                   MOVE      LBITEM        W1ITEM
     C                   MOVEL     ITDESC        W1DESC
     C                   MOVE      LBDISP        W1DISP
700  C                   MOVE      ITWHDP        W1WHDP
     C                   Z-ADD     LBQALC        W1QTY

CBIaAC                   IF        CLIENT = CHENEY
CBIaAC                   MOVEL     LILCNS        LIC#
CBIaAC                   ELSE
CBIaAC                   MOVE      *BLANKS       LIC#
CBIaAC                   ENDIF

CBIaAC                   MOVE      ITACTV        W1ACTV
     C                   ENDDO
413 AC*
413 AC*  Fill status.
413 AC*
413 AC                   MOVE      *BLANKS       W1STAT            8
413 AC     PTSTAT        IFNE      ' '
413 AC                   MOVE      PTSTAT        S                 1 0
413 AC                   MOVEA     STA(S)        W1STAT
413 AC                   ENDIF
     C*
     C*  Get first picking slot for item.
414aAC*
414aAC                   MOVE      'A '          K3STAT
414aAC                   MOVE      'Y'           K3PICK
414aAC     KEYS3         SETLL     SLOT3
414aAC     KEYS3         READE     SLOT3                                  79
414aAC     *IN79         IFEQ      *ON
414aAC                   MOVE      *BLANKS       W1PICK
414aAC                   ELSE
414aAC                   MOVE      SLDISP        W1PICK
414aAC                   ENDIF
414b C*  Format trans. generated date.
414bAC                   MOVE      '*CMDMDY '    $CVCMD
414bAC                   MOVE      PTGDTE        $CVD8I
414bAC                   CALL      @CVTDT
414bAC                   PARM                    $CVTDT
414bAC                   Z-ADD     $CVD6O        W1GDTE            6 0
     C*
416aAC                   Z-ADD     PTGTIM        W1GTIM
     C*
     C                   WRITE     DETAIL1
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             COUNT
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      '0'           *IN91
     C*----------------------------------------------------------------
     C*
     C* Slot type/Department totals
     C*
     C*1                   Z-ADD1         L
     C*1                   EXSR ZRROLL
     C*1                   Z-ADDCOUNT     TRNCNT
     C*1                   WRITETOTAL1
     C*1                   Z-ADD0         COUNT
     C*
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
     CLR                 Z-ADD     2             L
     C*
     CLR   RECK(L)       IFGT      0
     CLR                 WRITE     SKIP1
     CLR                 WRITE     FOOT1
     CLR                 END
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     CSR   LB7KEY        KLIST
     CSR                 KFLD                    PTTRN#
     C*
414aACSR   KEYS3         KLIST
414aACSR                 KFLD                    LBWHSE
414aACSR                 KFLD                    LBITEM
414aACSR                 KFLD                    K3STAT            2
414aACSR                 KFLD                    K3PICK            1
414aAC*
     C*
     C*   Get report title.
     C*
     CSR                 CALL      'GETRPT'
     CSR                 PARM      '*DESC  '     $CMD              8
     CSR                 PARM      'PT331PR'     $LRPT            10
     CSR                 PARM      0             $WHSE             3 0
     CSR                 PARM      ' '           $STYP             1
     CSR                 PARM      ' '           $WHDP             5
     CSR                 PARM                    $DESC            50
     CSR                 PARM                    $DEV             10
     CSR                 PARM                    $FORM            10
     CSR                 MOVEL     $DESC         RPTTTL
     C*
     C*   Center report title.
     C*
     CSR                 MOVEL     RPTTTL        $PSTR            60
     CSR                 Z-ADD     50            $PLEN             3 0
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         RPTTTL
     C*
     C*  Format date range
     C*
     C                   SELECT
     C     $PFMDT        WHENNE    *BLANKS
     C     $PTODT        ANDNE     *BLANKS
     C                   MOVEA     DTE(1)        A22
     C                   MOVEA     $PFMMM        A22(1)
     C                   MOVEA     $PFMDD        A22(4)
     C                   MOVEA     $PFMYY        A22(7)
     C                   MOVEA     $PTOMM        A22(15)
     C                   MOVEA     $PTODD        A22(18)
     C                   MOVEA     $PTOYY        A22(21)
     C                   MOVEA     A22           DTERNG
     C*
     C     $PFMDT        WHENNE    *BLANKS
     C                   MOVEA     DTE(2)        A22
     C                   MOVEA     $PFMMM        A22(11)
     C                   MOVEA     $PFMDD        A22(14)
     C                   MOVEA     $PFMYY        A22(17)
     C                   MOVEA     A22           DTERNG
     C*
     C     $PTODT        WHENNE    *BLANKS
     C                   MOVEA     DTE(3)        A22
     C                   MOVEA     $PTOMM        A22(11)
     C                   MOVEA     $PTODD        A22(14)
     C                   MOVEA     $PTOYY        A22(17)
     C                   MOVEA     A22           DTERNG
     C*
     C                   OTHER
     C                   MOVEA     DTE(4)        DTERNG
     C*
     C                   ENDSL
     C*
416 ACSR                 MOVE      $PWHDP        W1WHDP
     CSR                 MOVE      *ON           FIRST             1
     CSR                 TIME                    TIME
     CSR                 Z-ADD     0             COUNT             3 0
     CSR                 Z-ADD     2             L                 1 0
     CSR                 EXSR      ZRZERO

     *
     * Get client id.
     *
     C                   CALL      'GETCLIENT'
     C                   PARM                    CLIENT

CBIaAC                   IF        CLIENT = CHENEY
CBIaAC                   EVAL      *IN22 = *ON
CBIaAC                   ELSE
CBIaAC                   EVAL      *IN22 = *OFF
CBIaAC                   ENDIF

     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C*          *INL1     IFEQ '0'
     C*                    MOVE '1'       *IN91
     C*                    END
     C*
     C                   MOVE      '0'           *IN90
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE             50
     C                   MOVE      *BLANKS       $PSTR
     C     PTWHSE        CHAIN     WAREHS                             79
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
     C*
     C                   WRITE     HEAD1
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRROLL        BEGSR
     C*
     C     *LIKE         DEFINE    L             M
     C     L             ADD       1             M
     C*
     C                   ADD       1             LVLK(M)
     C                   ADD       RECK(L)       RECK(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C     L             IFEQ      1
     C*                    WRITETOTAL1
     C                   END
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRZERO        BEGSR
     C*
     C                   Z-ADD     0             LVLK(L)
     C                   Z-ADD     0             RECK(L)
     C*
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

**      STA   Status
Open
Started
Ended
Finished
