     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  OR671    Route detail by stop
     F*  06 July 2001
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
     F*
415 AF*    07/06/01  RH   4.15
     F*  Renamed from SFC100
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/26  02/04
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
520AAF*    05/08/09  CWM 5.20A
     F*      - Enh: Converted to RPG ILE
     F*
530 AF*    02/20/10  MLB  5.30  Note: Was 5.20 mod at MJ Kellner.
     F*      - Enh: Added functionality to select 'Exceptions' and have
     F*        the report only print detail lines where the pick qty is
     F*        different from the order qty.   Added "Exceptions" to the
     F*        report title when that option is selected.
530aAF*    04/30/10  MLB  5.30a
     F*      - Enh: Added client custom code support to program.
530bAF*    04/30/10  MLB  5.30b
     F*      - Fix: Pgm was starting new page when it shouldn't be.
     F*        This would only happen when running in Exception mode
     F*        and short occured on first line of order.
     F*
640aAF*    09/20/12  RTR  6.40a
     F*      - Enh: Expand DETAIL1 WOFLG to 3.
     F*             Add DETAIL3 format.
     F*
650aA*    06/06/13  RBD  6.50a
     *      - Enh: Added new stop/drop field.  Will print and use
     *        as control break instead of order header stop.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Dairyland
     F*
DRY AF*    04/30/10  MLB  DRY
     F*      - Revised program to add item description, pack/size, load
     F*        customer number from OHMISC and add pick slot to report.
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
     FOR671     IP   E           K DISK
DRY AFPIRITEM   IF   E           K DISK    usropn
DRY AFORDDS     IF   E           K DISK    usropn
     FOR671PR   O    E             PRINTER OFLIND(*IN90)
530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*----------------------------------------------------------------
530aA
530aA /copy qcopysrc,id#dairyla
530aA
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
530 DD*TTL             S             40    DIM(1) CTDATA PERRCD(1)
530 MD TTL             S             40    DIM(2) CTDATA PERRCD(1)
     D RPD             S             25    DIM(5) CTDATA PERRCD(1)
     D RECK            S              7  0 DIM(5)
     D LVLK            S              7  0 DIM(5)
     I*
     I*----------------------------------------------------------------
     IOQREC
650aDI**                                        OHSTOP        L1
650aMI                                          RTSSD         L1
     I                                          OHCUST        L1
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
530 AC     *entry        plist
530 AC                   parm                    rtds              1
530 AC*
     C*----------------------------------------------------------------
     C*
     C*  Report Heading
     C*
     C*
     C*  Start new page if one of following happened.
     C*     - Overflow occurred.
     C*
520 AC     rtds          ifne      'E'
     C     *IN90         IFEQ      *ON
     C     FIRST         OREQ      *ON
     C     *INL1         OREQ      *ON
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
530 AC                   endif
     C*
     C*  Init total levels
     C*
     C*  Level 1 break - Stop/Cust#
     C*
     C     *INL1         IFEQ      *ON
     C                   Z-ADD     1             L
     C                   EXSR      ZRZERO
     C                   ENDIF
     C*
520 AC                   EXSR      ZZFGTS
520 AC     $SSTP         IFGT      0
650aDC**                 Z-ADD     $SSTP         WOSTOP
650aMC                   MOVE      $SSD          WOSTOP
520 AC                   ELSE
650aDC**                 Z-ADD     OHSTOP        WOSTOP
650aMC                   MOVE      OHSTOP        WOSTOP
520 AC                   ENDIF
DRY AC*
DRY AC                   if        client = Dairyland
DRY AC                   eval      wocustd = %subst(ohmisc:11:10)
DRY AC                   else
DRY AC*
     C                   Z-ADD     OHCUST        WOCUST
DRY AC                   endif
DRY AC*
     C                   MOVEL     OHCNAM        WOCNAM
     C*
     C*                    MOVE *BLANKS   $CSTR
     C*                    MOVE *BLANKS   CUST#
     C*                    MOVE OHCUST    $CSTR
     C*                    CALL 'ADJUST'
     C*                    PARM '*LEFT   '$CCMD   8
     C*                    PARM           $CSTR  30
     C*                    MOVEL$CSTR     CUST#  11
     C*                    MOVELOHCNAM    CSNAME
     C*
     C*  Print headings.
     C*
     C     *IN91         IFEQ      *ON
     C     *INL1         OREQ      *ON
     C*                    WRITESKIP1
     C                   ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*
     C*    Create a quantity string for qty ordered
     C*
     C                   MOVE      '*QTY2STR'    $PCMD
     C                   Z-ADD     ODQOR1        $PQTY1
     C                   Z-ADD     ODQOR2        $PQTY2
     C                   Z-ADD     ODQOR3        $PQTY3
     C                   MOVE      *BLANKS       $PQSTR
     C*
     C                   CALL      'CVTQTY'
     C                   PARM                    $PCMD             8
     C                   PARM                    $PPRG            10
     C                   PARM                    $PQTY1            7 0
     C                   PARM                    $PQTY2            7 0
     C                   PARM                    $PQTY3            7 0
     C                   PARM                    $PUM1             2
     C                   PARM                    $PUM2             2
     C                   PARM                    $PUM3             2
     C                   PARM                    $PQSTR           10
     C                   PARM                    $PUSTR           17
     C                   PARM                    $PRTN             8
     C                   PARM                    $PERM            60
     C*
     C                   MOVEL     $PQSTR        WOQORD
     C*
     C*    Create a quantity string for qty picked
     C*
     C                   MOVE      '*QTY2STR'    $PCMD
     C                   Z-ADD     ODQPK1        $PQTY1
     C                   Z-ADD     ODQPK2        $PQTY2
     C                   Z-ADD     ODQPK3        $PQTY3
     C                   MOVE      *BLANKS       $PQSTR
     C*
     C                   CALL      'CVTQTY'
     C                   PARM                    $PCMD             8
     C                   PARM                    $PPRG            10
     C                   PARM                    $PQTY1            7 0
     C                   PARM                    $PQTY2            7 0
     C                   PARM                    $PQTY3            7 0
     C                   PARM                    $PUM1             2
     C                   PARM                    $PUM2             2
     C                   PARM                    $PUM3             2
     C                   PARM                    $PQSTR           10
     C                   PARM                    $PUSTR           17
     C                   PARM                    $PRTN             8
     C                   PARM                    $PERM
     C*
     C                   MOVEL     $PQSTR        WOQPCK
     C*
     C*    Flag detail line if ordered and picked don't match.
     C*
     C     ODQOR1        IFNE      ODQPK1
     C     ODQOR2        ORNE      ODQPK2
     C     ODQOR3        ORNE      ODQPK3
     C                   MOVE      '*'           WOFLG
     C                   ELSE
     C                   MOVE      ' '           WOFLG
     C                   ENDIF
640aAC*
640aAC*    Flag detail line based on ODOITM
640aAC*
640aAC                   if        odoitm = *blanks
640aAC                   eval      woflg = '*  '
640aAC                   else
640aAC                   eval      woflg = 'Sub'
640aAC                   endif
     C*
     C*    Write detail line.
     C*
530 AC                   if        rtds = 'E'
530 AC                   exsr      zrexcp
530 AC                   else
     C                   MOVEL     ODITEM        WOITEM
     C                   WRITE     DETAIL1
640aAC*
640aAC*    Print DETAIL3 if Sub
640aAC*
640aAC                   if        WOFLG = 'Sub'
640aAC*
640aAC                   select
640aAC                   when      ODQOR1 > 0
640aAC                   eval      P1QORD = %char(ODQOR1)
640aAC                   when      ODQOR2 > 0
640aAC                   eval      P1QORD = %char(ODQOR2)
640aAC                   when      ODQOR3 > 0
640aAC                   eval      P1QORD = %char(ODQOR3)
640aAC                   other
640aAC                   eval      P1QORD = '0'
640aAC                   endsl
640aAC*
640aAC                   select
640aAC                   when      ODQPK1 > 0
640aAC                   eval      P1QPCK = %char(ODQPK1)
640aAC                   when      ODQPK2 > 0
640aAC                   eval      P1QPCK = %char(ODQPK2)
640aAC                   when      ODQPK3 > 0
640aAC                   eval      P1QPCK = %char(ODQPK3)
640aAC                   other
640aAC                   eval      P1QPCK = '0'
640aAC                   endsl
640aAC*
640aAC                   eval      p1seq = odor2
640aAC                   eval      p1item = odoitm
640aAC                   eval      woflg = 'Ord'
640aAC                   write     detail3
640aAC                   endif
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          FIRST
530 AC                   endif
     C*----------------------------------------------------------------
     C*
     C* Stop/Cust# totals
     C*
     CL1                 Z-ADD     1             L
     CL1                 EXSR      ZRROLL
     C*
     CL1   RECK(L)       IFGT      0
     CL1   *IN90         IFEQ      *ON
     CL1                 EXSR      ZRHEAD
     CL1                 ENDIF
     CL1                 EXSR      ZRTOTL
     CL1                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Batch totals
     C*
     CLR                 Z-ADD     2             L
     C*
     CLR   RECK(L)       IFGT      0
     C**         *IN90     IFEQ *ON
     C**                   EXSR ZRHEAD
     C**                   ENDIF
     C**                   EXSR ZRTOTL
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
530aA
530aA* Get client id.
530aA
530aAC                   call      'GETCLIENT'
530aAC                   parm                    client           10
530aAC                   parm                    clientloc        10
     C*
DRY AC                   if        client = dairyland
DRY AC*
DRY AC                   if        not %open(ordds)
DRY AC                   open      ordds
DRY AC                   endif
DRY AC*
DRY AC                   if        not %open(piritem)
DRY AC                   open      piritem
DRY AC                   endif
DRY AC*
DRY AC                   endif
DRY AC*
DRY AC*      Item master
DRY AC     itkey         klist
DRY AC                   kfld                    ohwhse
DRY AC                   kfld                    oditem
DRY AC*
DRY AC*      Order Detail - Pick Slot
DRY AC     oskey         klist
DRY AC                   kfld                    ohwhse
DRY AC                   kfld                    ohord
DRY AC                   kfld                    odseq
DRY AC                   kfld                    oditem
DRY AC*
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
     C                   Z-ADD     1             L                 1 0
     C                   EXSR      ZRZERO
     C                   ENDSR
530 AC*----------------------------------------------------------------
530 AC*
530 AC     zrexcp        begsr
530 AC*
530 AC                   if        woflg = '*'
530 AC*
530 AC                   if        *in90 = '1'
530 AC                             or first = '1'
530bDC*                            or *inL1 = '1'
530 AC                   exsr      zrfrmt
530 AC                   exsr      zrhead
530 AC                   endif
530 AC*
DRY AC                   if        client = Dairyland
DRY AC*
DRY AC     itkey         chain     piritem
DRY AC                   if        not %found(piritem)
DRY AC                   eval      itdesc = ' '
DRY AC                   eval      itpdsc = ' '
DRY AC                   endif
DRY AC
DRY AC     oskey         chain     ordds
DRY AC                   if        not %found(ordds)
DRY AC                   eval      osdisp = ' '
DRY AC                   endif
DRY AC*
DRY AC                   eval      woitemd = oditem
DRY AC                   eval      wodisp = osdisp
DRY AC                   write     detaiL1dry                           90
DRY AC                   if        *in90 = '1'
DRY AC                   exsr      zrhead
DRY AC                   endif
DRY AC                   write     detaiL2dry                           90
DRY AC*
DRY AC                   else
DRY AC*
530 AC                   movel     oditem        woitem
530 AC                   write     detaiL1
DRY AC                   endif
DRY AC*
530 AC*
530 AC*  Increment record counters
530 AC*
530 AC                   add       1             reck(1)
530 AC                   add       1             lvlk(1)
530 AC*
530 AC*  Set off top-of-page indicators
530 AC*
530 AC                   eval      *in91 = '0'
530 AC                   eval      first = '0'
530 AC                   endif
530 AC*
530 AC                   endsr
530 AC*
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Format report title.
     C*
520 AC                   if        rtds = 'E'
530 AC                   move      ttl(2)        title
530 AC                   else
530 AC*
     C                   MOVE      TTL(1)        TITLE
530 AC                   endif
530 AC*
     C                   MOVEL     TITLE         $PSTR            60
     C                   Z-ADD     40            $PLEN             3 0
     C*
     C*   Center report title.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         TITLE
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE
     C                   MOVE      *BLANKS       $PSTR
     C                   MOVEL     WHDESC        $PSTR            60
     C                   Z-ADD     30            $PLEN             3 0
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         WHSE
     C*
     C*   Format Route number.
     C*
     C                   MOVE      *BLANKS       BATCH
     C                   MOVE      *BLANKS       $PSTR
     C     BATCH         CAT       'Route:':1    BATCH
     C     BATCH         CAT       RHRTE:1       BATCH
     C                   MOVEL     BATCH         $PSTR            60
     C                   Z-ADD     30            $PLEN             3 0
     C*
     C*   Center batch/route description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR            60
     C                   PARM                    $PLEN             3 0
     C                   MOVEL     $PSTR         BATCH
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C     *INL1         IFEQ      *OFF
     C                   MOVE      *ON           *IN91
     C                   END
     C*
     C                   MOVE      *OFF          *IN90
     C*
     C                   WRITE     HEAD1
DRY AC*
DRY AC                   if        client = Dairyland
DRY AC                   write     columnsdry
DRY AC                   else
DRY AC*
     C                   WRITE     COLUMNS
DRY AC                   endif
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
     C                   MOVE      RPD(L)        $RPD             20
     C*
     C     L             IFEQ      1
     C                   ENDIF
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
     C*----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM      '*ORDSTP '    $SCMD             8
520 MC                   PARM      OHWHSE        $SWHSE            3 0
520 MC                   PARM      OHRTE         $SRTID            5
520 MC                   PARM      OHORD         $SORD             7 0
520 MC                   PARM      0             $SDSTP            2 0
520 MC                   PARM                    $SSTP             5 0
650aAC                   parm                    $sdrop            3
650aAC                   parm                    $sextd           30
650aAC                   parm                    $ssd              9
520 AC*
520 AC                   ENDSR
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**      TTL   Report title descriptions
Route Detail by Stop Report
Route Detail by Stop Report - Exceptions
**      RPD   Report level descriptions

 * TOTALS      *



