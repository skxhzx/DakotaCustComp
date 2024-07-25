     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  OR670     Route summary by stop
     F*  15 August 2000
     F*  Dave Sommerville
     F*
510 AF*----------------------------------------------------------------
     F*  Revisions:
     F*
414 AF*    08/15/00  DAS  4.14
     F*      - Created
     F*
415 AF*    02/16/01  DAS  4.15
     F*      - Added REPORTS override for OR670PR.
     F*
417 AF*    06/27/01  HNK  4.17
     F*      - Added line to include department 'CLR'
     F*
510 AF*    08/29/06  MLB  5.10
     F*      - Added line to include department 'COOLR' and 'FROZ'
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/26  02/04
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     F*
520AAF*    05/08/09  CWM 5.20A
     F*      - Enh: Added support for new Report Distribution
     F*             Converted To ILE
     *
530 A*    11/08/10  MLB  5.30
     *      - Enh: Revised program to use OUTQ instead of DEV when
     *        processing OVRPRTF cmd.
     *
640a *    07/11/12  GJA  6.40a
     *      - Enh: Added custom client code support to program.
     *
650aA*    06/03/13  RBD  6.50a
     *      - Enh: Added new stop/drop field.  Will print and use
     *        as control break instead of label stop.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Intercounty Bakers
ICBa *    07/11/12  GJA  ICBa
     *      - Enh: Revised program because they use 1 for Dry/Cooler
     *        and 2 for Freezer.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer Foodservice
     *
JPFaA*    03/16/09  RH   JPFa
     *      - Revised to include D, R and F departments.
     *
     *----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
650aDF*LABEL71   IP   E           K DISK
650aMFLABEL71D  IP   E           K DISK
     FRTEHED    IF   E           K DISK
415 DF**670PR O   E             90     PRINTER
520aDF** OR670PR O   E             90     PRINTER                        UC
520aAFOR670PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
415 AD A80             S              1    DIM(80)
     D TTL             S             40    DIM(1) CTDATA PERRCD(1)
     D RPD             S             25    DIM(5) CTDATA PERRCD(1)
     D RECK            S              7  0 DIM(5)
     D LVLK            S              7  0 DIM(5)
     D*
     D QDRY            S              5  0 DIM(5)
     D QFRZ            S              5  0 DIM(5)
     D QREF            S              5  0 DIM(5)
     D QOTH            S              5  0 DIM(5)
415 AD OVRPRT          S             80    DIM(1) CTDATA PERRCD(1)
640aAD*----------------------------------------------------------------
640aAD*  Customer id
640aAD*
     D @GETCL          C                   CONST('GETCLIENT')
     D*----------------------------------------------------------------
ICBaA /COPY QCOPYSRC,ID#ICB
JPF A /COPY QCOPYSRC,ID#PALMER
     D*
520aAD lstdev          s             10
520aAD lstfrm          s             10
520aAD lstwhs          s              3  0
     I*
     I*----------------------------------------------------------------
650aDI*L71REC
650aMIL71DREC
650aDI*                                         LBSTOP        L1
650aMI                                          RTSSD         L1
     I                                          OHCUST        L1
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C*----------------------------------------------------------------
     C*
     C*  Report Heading
     C*
     C*
     C*  Start new page if one of following happened.
     C*     - Overflow occurred.
     C*
     C     *IN90         IFEQ      *ON
     C     FIRST         OREQ      *ON
520aDC**                   EXSR OPNPRT
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
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
650aDC*                  Z-ADD     $SSTP         WOSTOP
650aMC                   MOVE      $SSD          WOSTOP
520 AC                   ELSE
650aDC*                  Z-ADD     LBSTOP        WOSTOP
650aMC                   MOVE      LBSTOP        WOSTOP
520 AC                   ENDIF
     C                   Z-ADD     OHCUST        WOCUST
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
     C***                  WRITEDETAIL1
     C*
     C*  Accumulate totals
     C*
     C                   SELECT
     C     LBWHDP        WHENEQ    'DRY'
ICBaAC     LBWHDP        OREQ      '1    '
JPFaAC     LBWHDP        OREQ      'D    '
     C                   ADD       LBQPCK        QDRY(1)
     C*
     C     LBWHDP        WHENEQ    'FRZ'
510 AC     LBWHDP        OREQ      'FROZ '
ICBaAC     LBWHDP        OREQ      '2    '
JPFaAC     LBWHDP        OREQ      'F    '
     C                   ADD       LBQPCK        QFRZ(1)
     C*
     C     LBWHDP        WHENEQ    'REF'
417 AC     LBWHDP        OREQ      'CLR'
510 AC     LBWHDP        OREQ      'COOLR'
JPFaAC     LBWHDP        OREQ      'R    '
     C                   ADD       LBQPCK        QREF(1)
     C*
     C                   OTHER
     C                   ADD       LBQPCK        QOTH(1)
     C*
     C                   ENDSL
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
     C*
640aAC*
640aAC* Get client id.
640aAC*
640aAC                   CALL      @GETCL
640aAC                   PARM                    CLIENT           10
640aAC*
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
     C                   Z-ADD     1             L                 1 0
     C                   EXSR      ZRZERO
415 AC*
415 AC*  Variables and constants.
415 AC*
520aDC** SR   *LIKE         DEFINE    $WHSE         LSTWHS
520aDC** SR   *LIKE         DEFINE    $DEV          LSTDEV
520aDC** SR   *LIKE         DEFINE    $FORM         LSTFRM
     C*
     C                   ENDSR
415 AC*----------------------------------------------------------------
415 AC*
415 AC*  OPNPRT  Open printer file.
415 AC*
520aDC** SR         OPNPRT    BEGSR
     C*
     C*   Get device and form type for department.
     C*
520aDC** SR         LBWHSE    IFNE LSTWHS
520aDC** SR                   CALL 'GETRPT'
520aDC** SR                   PARM '*DEVFORM'$CMD    8
520aDC** SR                   PARM 'OR670PR' $LRPT  10
520aDC** SR                   PARM LBWHSE    $WHSE   30
520aDC** SR                   PARM ' '       $STYP   1
520aDC** SR                   PARM ' '       $WHDP   5
520aDC** SR                   PARM           $DESC  50
520aDC** SR                   PARM           $DEV   10
520aDC** SR                   PARM           $FORM  10
520aDC** SR                   Z-ADD$WHSE     LSTWHS
520aDC** SR                   ENDIF
     C*
     C*   Open printer file for department.
     C*
520aDC** SR         OPENED    IFNE *ON
520aDC** SR         $DEV      ORNE LSTDEV
520aDC** SR         $FORM     ORNE LSTFRM
     C*
     C*      If printer already open then close it.
     C*
520aDC** SR         OPENED    IFEQ *ON
520aDC** SR                   CLOSEOR670PR
520aDC** SR                   ENDIF
     C*
     C*      Override printer file.
     C*
     C*          OVRPRTF FILE(OR670PR) OUTQ(*DEV) DEV($dev)
     C*                  FORMTYPE($form)
     C*
520aDC** SR                   MOVEAOVRPRT,1  A80
520aDC** SR                   MOVEA$DEV      A80,38
520aDC** SR                   MOVEA$FORM     A80,59
520aDC** SR                   MOVEAA80       QCMD
     C*
520aDC** SR                   CALL 'QCMDEXC'
520aDC** SR                   PARM           QCMD   80
520aDC** SR                   PARM 80        QLEN   155
     C*
     C*      Open printer file.
     C*
520aDC** SR                   OPEN OR670PR
520aDC** SR                   MOVE *ON       OPENED  1
520aDC** SR                   MOVE $DEV      LSTDEV
520aDC** SR                   MOVE $FORM     LSTFRM
     C*
520aDC** SR                   ENDIF
     C*
520aDC** SR                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Format report title.
     C*
     C                   MOVE      TTL(1)        TITLE
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
     C     RTKEY         KLIST
     C                   KFLD                    LBWHSE
     C                   KFLD                    LBRTE
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       RHRTE
     C                   ENDIF
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
     C                   ADD       QDRY(L)       QDRY(M)
     C                   ADD       QFRZ(L)       QFRZ(M)
     C                   ADD       QREF(L)       QREF(M)
     C                   ADD       QOTH(L)       QOTH(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C                   Z-ADD     QDRY(L)       QTYDRY
     C                   Z-ADD     QFRZ(L)       QTYFRZ
     C                   Z-ADD     QREF(L)       QTYREF
     C                   Z-ADD     QOTH(L)       QTYOTH
     C*
     C                   MOVE      RPD(L)        $RPD             20
     C*
     C     L             IFEQ      1
     C                   WRITE     DETAIL1
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
     C                   Z-ADD     0             QDRY(L)
     C                   Z-ADD     0             QFRZ(L)
     C                   Z-ADD     0             QREF(L)
     C                   Z-ADD     0             QOTH(L)
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
520 MC                   PARM      LBWHSE        $SWHSE            3 0
520 MC                   PARM      OHRTE         $SRTID            5
520 MC                   PARM      LBORD         $SORD             7 0
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
Route Summary by Stop Report
**      RPD   Report level descriptions

 * TOTALS      *



**   OVRPRTF statment
OVRPRTF FILE(OR670PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
