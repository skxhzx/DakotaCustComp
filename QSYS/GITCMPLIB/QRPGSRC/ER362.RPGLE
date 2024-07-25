     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  ER362     Management report for a selector (Summary)
     F*  22 March, 2000
     F*  Hemant Kapadia
     F*
     F*  03.22.00  HNK  4.13
     F*   Created
     F*
     F* Note: Replaces ER272
     F*
     F*  Revisions:
     F*
     F*  10/11/00  HNK  4.14
     F*    - Revised to accumulate Hrs only when Tran changes.
     F*
415 AF*  11/16/00  HNK  4.15
     F*    - Check against shift time removed, as it is being done in
     F*      previous prog ER361A.  We want to process all the records
     F*      in ER361A file.
     F*    - SHIFT file removed as it was not used by the prog.
     F*
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
     FER361A    IP   E           K DISK
     FTASK      IF   E           K DISK
415 DF*HIFT   IF  E           K        DISK
     FPIRUSER1  IF   E           K DISK
     FREPORTE   IF   E           K DISK
     FER362PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D RPD             S             25    DIM(3) CTDATA PERRCD(1)
     D RECK            S              7  0 DIM(3)
     D LVLK            S              7  0 DIM(3)
     D*
     D DTOT            S              7  2 DIM(3)
     D PTOT            S              7  0 DIM(3)
     D ITOT            S              7  2 DIM(3)
     D*
     D DTE             S             22    DIM(4) CTDATA PERRCD(1)
     D A22             S              1    DIM(22)
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
     I*
     I*----------------------------------------------------------------
     IWKREC
     I                                          WKTASK        L2
     I                                          WKWHDP        L1
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PFMDT  From date (YYYYMMDD)
     C*      $PTODT  To date (YYYYMMDD)
     C*      $PWHSE  Warehouse number
     C*      $PEMP#  Employee number
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PFMDT
     C                   PARM                    $PTODT
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PEMP#            5
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C*  Report Heading
     C*
     C*
     C*  Start new page if one of following happened.
     C*     - Overflow occurred.
     C*
     C     *IN90         IFEQ      *ON
     C     FIRST         OREQ      *ON
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C*  Init total levels
     C*
     C*  Level 2 break - TASK
     C*
     C     *INL2         IFEQ      *ON
     C                   Z-ADD     2             L
     C                   EXSR      ZRZERO
     C*
     C*     Get task description.
     C*
     C     TKKEY         CHAIN     TASK                               79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       W1DESC
     C                   ELSE
     C                   MOVEL     TKDESC        W1DESC
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Level 1 break - DEPT code
     C*
     C     *INL1         IFEQ      *ON
     C                   Z-ADD     1             L
     C                   EXSR      ZRZERO
     C                   ENDIF
     C*
415 DC*   Getout if we have gone past the begining shift time on next
415 DC*   day.(Day following the To date entered) If we get out from
415 DC*   here, it means that ENDDAY task was not found for this
415 DC*   employee for the date range.
415 DC*
415 DC*                    MOVE $PTODT    TODT    80
415 DC*          WKSDTE    IFEQ TODT
415 DC*          WKSTIM    ANDGESHSTIM
415 DC*                    MOVE *ON       *INLR
415 DC*                    GOTO SKIP
415 DC*                    ENDIF
     C*
     C*  Print headings.
     C*
     C*
     C*          *IN92     IFEQ *ON
     C*          *INL2     OREQ *ON
     C*                    ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C* Start date
     C     WKSDTE        IFNE      0
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      WKSDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1SDTE            6 0
     C                   ELSE
     C                   Z-ADD     0             W1SDTE
     C                   ENDIF
     C* End date
     C*          WKEDTE    IFNE 0
     C*                    MOVE '*CMDMDY '$CVCMD
     C*                    MOVE WKEDTE    $CVD8I
     C*                    CALL @CVTDT
     C*                    PARM           $CVTDT
     C*                    Z-ADD$CVD6O    W1EDTE
     C*                    ELSE
     C*                    Z-ADD0         W1EDTE
     C*                    ENDIF
     C*
     C     WKDMIN        DIV(H)    60            W1DHRS            5 2
     C     WKIMIN        DIV(H)    60            W1IHRS            5 2
     C*
     C*  Accumulate totals
     C*
     C                   ADD       WKPCS         PTOT(1)
414 AC     WKTRN#        IFNE      SVTRN#
     C                   ADD       W1DHRS        DTOT(1)
     C                   ADD       W1IHRS        ITOT(1)
414 AC                   ENDIF
414 AC                   Z-ADD     WKTRN#        SVTRN#
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      *OFF          *IN92
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          FIRST
     C*
     C*   Getout when you come to ENDDAY
     C*
     C**         PTTASK    IFEQ 'ENDDAY'
     C**                   MOVE *ON       *INLR
     C**                   RETRN
     C**                   ENDIF
     C*
     C     SKIP          TAG
     C*----------------------------------------------------------------
     C*
     C* DEPT
     C*
     CL1                 Z-ADD     1             L
     CL1                 EXSR      ZRROLL
     C*
     CL1   RECK(L)       IFGT      0
     CL1                 EXSR      ZRTOTL
     CL1                 WRITE     DETAIL1
     CL1                 WRITE     SKIP1
     CL1                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* TASK
     C*
     CL2                 Z-ADD     2             L
     CL2                 EXSR      ZRROLL
     C*
     CL2   RECK(L)       IFGT      0
     C**                   EXSR ZRTOTL
     C**                   WRITEDETAIL1
     C**                   WRITESKIP1
     C**                   WRITESKIP1
     CL2                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Batch totals
     C*
     CLR                 Z-ADD     3             L
     C*
     CLR   RECK(L)       IFGT      0
     CLR                 EXSR      ZRTOTL
     CLR                 WRITE     TOTAL1
     CLR                 WRITE     SKIP1
     CLR                 WRITE     FOOT1
     CLR                 ENDIF
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
     C     RPKEY         KLIST
     C                   KFLD                    WKPRTF           10
     C*
     C     TKKEY         KLIST
     C                   KFLD                    WKTASK
     C*
415 DC*          SHKEY     KLIST
415 DC*                    KFLD           USWHSE
415 DC*                    KFLD           W1WHDP  5
415 DC*                    KFLD           USSHFT
     C*
     C                   MOVE      $PEMP#        EMP#              5 0
     C     EMP#          CHAIN     PIRUSER1                           79
     C*
     C                   MOVE      '*LFM    '    $CMD              8
     C                   MOVE      *BLANKS       $NAME            40
     C                   CALL      'FRMTNM'
     C                   PARM                    $CMD
     C                   PARM                    USFNAM
     C                   PARM                    USINIT
     C                   PARM                    USLNAM
     C                   PARM                    $NAME
     C                   MOVEL     $NAME         WKNAME
     C*
415 DC*                    MOVE *BLANKS   W1WHDP
415 DC*          SHKEY     CHAINSHIFT                79
415 DC*          *IN79     IFEQ *ON
415 DC*                    Z-ADD0         SHSTIM
415 DC*                    Z-ADD0         SHETIM
415 DC*                    ENDIF
     C*
     C     *LIKE         DEFINE    WKTRN#        SVTRN#
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
     C                   Z-ADD     1             L                 1 0
     C                   Z-ADD     0             N                 3 0
     C                   MOVE      *OFF          BEGIN             1
     C                   EXSR      ZRZERO
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Format report title.
     C*
     C*  Get report title.
     C*
     C                   MOVEL     'ER362PR '    WKPRTF
     C                   MOVE      *BLANKS       RPTTTL
     C     RPKEY         CHAIN     REPORTE                            79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     ERDESC        $PSTR            60
     C                   ELSE
     C                   MOVE      *BLANKS       $PSTR
     C                   ENDIF
     C                   Z-ADD     60            $PLEN             3 0
     C*
     C*   Center report title.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         RPTTTL
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
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C     *INL2         IFEQ      *OFF
     C                   MOVE      *ON           *IN92
     C                   END
     C*
     C     *INL1         IFEQ      *OFF
     C                   MOVE      *ON           *IN91
     C                   END
     C*
     C                   MOVE      *OFF          *IN90
     C*
     C                   WRITE     HEAD1
     C*
     C*  Get employee name
     C*
     C                   WRITE     EPHEAD
     C*  Columns
     C                   WRITE     COLUMNS
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
     C                   ADD       DTOT(L)       DTOT(M)
     C                   ADD       PTOT(L)       PTOT(M)
     C                   ADD       ITOT(L)       ITOT(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C                   Z-ADD     DTOT(L)       T#DTOT
     C                   Z-ADD     PTOT(L)       T#PTOT
     C                   Z-ADD     ITOT(L)       T#ITOT
     C*
     C     T#DTOT        IFGT      0
     C     T#PTOT        DIV(H)    T#DTOT        T#CSPH
     C                   ELSE
     C                   Z-ADD     0             T#CSPH
     C                   ENDIF
     C*
     C                   MOVE      *BLANKS       $RPD
     C                   MOVEL     RPD(L)        $RPD             20
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRZERO        BEGSR
     C*
     C                   Z-ADD     0             LVLK(L)
     C                   Z-ADD     0             RECK(L)
     C*
     C                   Z-ADD     0             DTOT(L)
     C                   Z-ADD     0             PTOT(L)
     C                   Z-ADD     0             ITOT(L)
     C*
     C                   ENDSR
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**      RPD   Report level descriptions
 * Department *
 ** Task **
 *** Totals
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

