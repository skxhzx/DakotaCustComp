     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  OR660C    Catchweight report
     F*  28 March, 2007
     F*  Retha Davis
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
     F*
510  F*    03/28/07  RBD  510
     F*      - Copied from OR660.
     F*
510aAF*    04/04/07  DAS  510a
     F*      - Changed L1 break to include OCSEQ# and OCSEQ.
     F*        Re: To print individual lines for ORDC records.
     F*      - Added L2 total for item.
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/29  02/02
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     F*
520aAF*    03/11/09  CWM  520a
     F*      - Enh: Changed program to use new print override process.
     F*             Converted to ILE
     F*
650aAF*    01/11/13  RBD  6.50a
     F*      - Fix: Compare trans# to previous trans.  Sub items create
     F*        a situation where the same pallet has 2 transactions,
     F*        and this was causing the open query file to have two
     F*        records for the pallet with the sub.
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
740aA*    08/21/20  DAS  7.40a
     *      - Moved ENDDTL tag to before turning off header indicators.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Renzi Foodservice
     F*
RNZaAF*    03/27/09  MLB  RNZa
     F*      - Revised array OVR to use OUTQ instead of DEV on prtf
     F*        overrides. Removed parm OUTQ(*DEV).
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
     FOR660C    IP   E           K DISK
     FWAREHS    IF   E           K DISK
     FRTEHED    IF   E           K DISK
     FOR660CPR  O    E             PRINTER OFLIND(*IN90)
520aDF*                                    USROPN
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D A80             S              1    DIM(80)
     D TTL             S             40    DIM(1) CTDATA PERRCD(1)
     D RPD             S             25    DIM(5) CTDATA PERRCD(1)
     D RECK            S              7  0 DIM(5)
     D LVLK            S              7  0 DIM(5)
     D*
     D QPCK            S              5  0 DIM(5)
     D CUBE            S              9  3 DIM(5)
     D WGHT            S              9  2 DIM(5)
     D OVRPRT          S             80    DIM(1) CTDATA PERRCD(1)
     D*
     D*----------------------------------------------------------------
     D @UNLD           C                   CONST('Unload Seq:')
     D @COMP           C                   CONST('Compartment:')
     D @PALT           C                   CONST('Pallet:')
     D @TRAN           C                   CONST('Tran:')
     D*----------------------------------------------------------------
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
     D  $LRTID                22     26
     D  $LTRN#                27     33  0
     D  $LWHDP                34     38
     D  $LDOOR                39     41  0
     D*
     D*----------------------------------------------------------------
     D* Data structure
     D*
     D OPDATA          DS
     D  OPSTYP                 1      1
     D  OPWHDP                 2      6
     D  OPUM1                  7      8
     D  OPDUM                  9     23
     D  OPCUM                 24     43
     D  OPCDIV                44     52  2
     D  OPCAUT                53     53
     D  OPCWRN                54     54
     D  OPCRNG                55     57  1
     D  OPWUM                 58     72
     D  OPXDSC                73     73
     D  OPTEND               117    117
     I*----------------------------------------------------------------
     IOQREC
     I                                          PSCOMP        L4
     I                                          PSPLID        L3
650aAI                                          PSTRN#        L3
510aMI                                          LBITEM        L2
510aMI                                          OHCORD        L2
510aAI                                          OCSEQ#        L2
510aAI                                          OCSEQ         L1
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $CMD              8
     C                   PARM                    $RTYPE            8
520aDC*                  PARM                    $DEV             10
520aDC*                  PARM                    $FORM            10
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
520aDC*                  EXSR      OPNPRT
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C*  Init total levels
     C*
510aMC*  Level 1 break - ORDC record
     C*
     C     *INL1         IFEQ      *ON
     C                   Z-ADD     1             L
     C                   EXSR      ZRZERO
     C                   ENDIF
510aAC*
510aAC*  Level 2 break - Order detail line
510aAC*
510aAC     *INL2         IFEQ      *ON
510aAC                   Z-ADD     2             L
     C                   EXSR      ZRZERO
     C                   ENDIF
     C*
     C* Left justify order number
     C*
     C                   MOVE      *BLANKS       $CSTR
     C                   MOVE      *BLANKS       ORDN#
     C                   MOVE      OHCORD        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         ORDN#
520 AC                   EXSR      ZZFGTS
     C*
     C*  Level 3 break - Pallet ID/Unload sequence
     C*
     C     *INL3         IFEQ      *ON
650aAC                   Z-ADD     PSTRN#        SAVTRN            7 0
     C                   Z-ADD     3             L
     C                   EXSR      ZRZERO
     C*
     C     PSTRN#        IFEQ      0
     C                   MOVE      'B'           WKTYPE            1
     C                   Z-ADD     0             WKTRN#            7 0
     C                   CALL      'GETBLTRN'
     C                   PARM                    PSWHSE
     C                   PARM                    PSRTID
     C                   PARM                    PSCOMP
     C                   PARM                    PSTZON
     C                   PARM                    PSGEN
     C                   PARM                    PSSZON
     C                   PARM                    WKTYPE
     C                   PARM                    PSUNLD
     C                   PARM                    PSROW
     C                   PARM                    PSCOL
     C                   PARM                    WKTRN#
     C                   ELSE
     C                   Z-ADD     LBTRN#        WKTRN#
     C                   ENDIF
     C*
     C*     Get dock door for the transaction.
     C*
     C                   Z-ADD     PSWHSE        $LWHSE
     C                   MOVE      PSRTID        $LRTID
     C                   Z-ADD     WKTRN#        $LTRN#
     C                   MOVE      *BLANKS       $LWHDP
     C                   Z-ADD     0             $LDOOR
     C                   CALL      'DH900'
     C                   PARM                    $LPARM
     C*
     C                   MOVE      *BLANKS       P#DESC
     C     P#DESC        CAT       '** ':1       P#DESC
     C     P#DESC        CAT       @COMP:1       P#DESC
     C     P#DESC        CAT       '-':1         P#DESC
     C     P#DESC        CAT       PSCOMP:1      P#DESC
     C     P#DESC        CAT       '    - ':1    P#DESC
     C     P#DESC        CAT       @UNLD:1       P#DESC
     C                   MOVE      *BLANKS       $CSTR
     C                   MOVE      PSUNLD        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         PSUNL             2
     C     P#DESC        CAT       PSUNL:1       P#DESC
     C     P#DESC        CAT       '    - ':1    P#DESC
     C     P#DESC        CAT       @PALT:1       P#DESC
     C                   MOVE(P)   PSPAL#        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         PSPAL             2
     C     P#DESC        CAT       PSPAL:1       P#DESC
     C*
     C                   MOVE      *BLANKS       $CSTR
     C                   MOVE      $LTRN#        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         DTRAN             7
     C     P#DESC        CAT       '    - ':1    P#DESC
     C     P#DESC        CAT       @TRAN:1       P#DESC
     C     P#DESC        CAT       DTRAN:1       P#DESC
     C                   ENDIF
     C*
     C*  Level 4 break - Compartment
     C*
     C     *INL4         IFEQ      *ON
     C                   Z-ADD     4             L
     C                   EXSR      ZRZERO
     C                   ENDIF
     C*
     C*  Print headings.
     C*
     C     *IN93         IFEQ      *ON
     C     *INL3         OREQ      *ON
650aAC     PSTRN#        ANDEQ     OCTRAN
     C                   WRITE     HEAD2
     C                   ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*  Accumulate totals
     C*
650aAC     SAVTRN        IFNE      OCTRAN
750aAC                   GOTO      ENDDTL
650aAC                   ENDIF
     C*
     C                   ADD       LBQPCK        QPCK(1)
     C                   ADD       LBCUBE        CUBE(1)
     C                   ADD       OCCWGT        WGHT(1)
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
740aAC     ENDDTL        TAG
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      *OFF          *IN94
     C                   MOVE      *OFF          *IN93
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          FIRST
     C*
740aDC**** ENDDTL        TAG
     C*----------------------------------------------------------------
     C*
510aAC* ORDC totals
     CL1                 Z-ADD     1             L
     CL1                 EXSR      ZRROLL
     C*
     CL1   RECK(L)       IFGT      0
     CL1   *IN90         IFEQ      *ON
     CL1                 EXSR      ZRHEAD
     CL1                 ENDIF
     CL1                 EXSR      ZRTOTL
     CL1                 ENDIF
510aAC*----------------------------------------------------------------
510aAC*
510aAC* Order detail line totals
510aACL2                 Z-ADD     2             L
510aACL2                 EXSR      ZRROLL
510aAC*
510aACL2   RECK(L)       IFGT      0
510aACL2   *IN90         IFEQ      *ON
510aACL2                 EXSR      ZRHEAD
510aACL2                 ENDIF
510aACL2                 EXSR      ZRTOTL
510aACL2                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Pallet totals
     C*
650aACL3   PSTRN#        IFEQ      SAVTRN
     CL3                 Z-ADD     3             L
     CL3                 EXSR      ZRROLL
     C*
     CL3   RECK(L)       IFGT      0
     CL3   *IN90         IFEQ      *ON
     CL3                 EXSR      ZRHEAD
     CL3                 ENDIF
     CL3                 EXSR      ZRTOTL
     CL3                 ENDIF
650aACL3                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Compartment totals
     C*
     CL4                 Z-ADD     4             L
     CL4                 EXSR      ZRROLL
     C*
     CL4   RECK(L)       IFGT      0
     CL4   *IN90         IFEQ      *ON
     CL4                 EXSR      ZRHEAD
     CL4                 ENDIF
     CL4                 EXSR      ZRTOTL
     CL4                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Batch totals
     C*
     CLR                 Z-ADD     5             L
     C*
     CLR   RECK(L)       IFGT      0
     CLR   *IN90         IFEQ      *ON
     CLR                 EXSR      ZRHEAD
     CLR                 ENDIF
     CLR                 EXSR      ZRTOTL
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
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
     C                   Z-ADD     1             L                 1 0
     C                   EXSR      ZRZERO
     C*
     C*  Variables and constants.
     C*
     CSR   *LIKE         DEFINE    $WHSE         LSTWHS
     CSR   *LIKE         DEFINE    $DEV          LSTDEV
     CSR   *LIKE         DEFINE    $FORM         LSTFRM
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  OPNPRT  Open printer file.
     C*
     CSR   OPNPRT        BEGSR
     C*
     C*   Get device and form type for department.
     C*
     CSR   PSWHSE        IFNE      LSTWHS
     CSR   $DEV          ANDEQ     '*JOB'
     C*
     CSR                 CALL      'GETRPT'
     CSR                 PARM      '*DEVFORM'    $CMD              8
     C                   PARM      'OR660CPR'    $LRPT            10
     CSR                 PARM      PSWHSE        $WHSE             3 0
     CSR                 PARM      ' '           $STYP             1
     CSR                 PARM      ' '           $WHDP             5
     CSR                 PARM                    $DESC            50
     CSR                 PARM                    $DEV             10
     CSR                 PARM                    $FORM            10
     CSR                 Z-ADD     $WHSE         LSTWHS
     CSR                 ENDIF
     C*
     C*   Open printer file for department.
     C*
     CSR   OPENED        IFNE      *ON
     CSR   $DEV          ORNE      LSTDEV
     CSR   $FORM         ORNE      LSTFRM
     C*
     C*      If printer already open then close it.
     C*
     CSR   OPENED        IFEQ      *ON
     CSR                 CLOSE     OR660CPR
     CSR                 ENDIF
     C*
     C*      Override printer file.
     C*
     C*          OVRPRTF FILE(OR660CPR) OUTQ(*DEV) DEV($dev)
     C*                  FORMTYPE($form)
     C*
     CSR                 MOVEA     OVRPRT(1)     A80
510aMCSR                 MOVEA     $DEV          A80(39)
510aMCSR                 MOVEA     $FORM         A80(60)
     CSR                 MOVEA     A80           QCMD
     C*
     CSR                 CALL      'QCMDEXC'
     CSR                 PARM                    QCMD             80
     CSR                 PARM      80            QLEN             15 5
     C*
     C*      Open printer file.
     C*
     CSR                 OPEN      OR660CPR
     CSR                 MOVE      *ON           OPENED            1
     CSR                 MOVE      $DEV          LSTDEV
     CSR                 MOVE      $FORM         LSTFRM
     C*
     CSR                 ENDIF
     C*
     CSR                 ENDSR
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
     C     LBWHSE        CHAIN     WAREHS                             79
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
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         LBBAT             7
     C*
     C*   Format Route number.
     C*
     C     RTKEY         KLIST
     C                   KFLD                    PSWHSE
     C                   KFLD                    PSRTID
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
     C     *INL4         IFEQ      *OFF
     C                   MOVE      *ON           *IN94
     C                   END
     C*
     C     *INL3         IFEQ      *OFF
     C                   MOVE      *ON           *IN93
     C                   END
510aAC*
510aAC     *INL2         IFEQ      *OFF
510aAC                   MOVE      *ON           *IN92
510aAC                   END
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
      *
510aDC**   (skip L2 totals)
510aDC**         L         IFEQ 1
510aDC**                   Z-ADD3         M
510aDC**                   ENDIF
     C*
     C                   ADD       1             LVLK(M)
     C                   ADD       RECK(L)       RECK(M)
     C*
     C                   ADD       QPCK(L)       QPCK(M)
     C                   ADD       CUBE(L)       CUBE(M)
     C                   ADD       WGHT(L)       WGHT(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
510aDC**                   Z-ADDQPCK,L    T#QPCK
510aDC**                   Z-ADDCUBE,L    T#CUBE
     C                   Z-ADD     WGHT(L)       T#WGHT
     C*
     C                   MOVE      RPD(L)        $RPD
     C*
     C     L             IFEQ      1
     C                   WRITE     DETAIL1
     C                   END
510aAC*
510aAC     L             IFEQ      2
510aAC                   WRITE     SKIP1
510aAC                   WRITE     TOTAL1
510aAC                   END
     C*
     C     L             IFEQ      3
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL2
     C                   END
     C*
     C     L             IFEQ      4
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL3
     C                   END
     C*
     C     L             IFEQ      5
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL4
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
     C*                    Z-ADD0         CLS,L
     C                   Z-ADD     0             QPCK(L)
     C                   Z-ADD     0             CUBE(L)
     C                   Z-ADD     0             WGHT(L)
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
520 MC                   PARM      PSWHSE        $SWHSE            3 0
520 MC                   PARM      PSRTID        $SRTID            5
520 MC                   PARM      LBORD         $SORD             7 0
520 MC                   PARM      0             $SDSTP            2 0
520 MC                   PARM                    $SSTP             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC     $SSTP         IFGT      0
520 AC                   Z-ADD     $SSTP         DSPSTP
520 AC                   ELSE
520 AC                   Z-ADD     LBSTOP        DSPSTP
520 AC                   ENDIF
520 AC*
520 AC                   ENDSR
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**      TTL   Report title description
Truck Pallet Catchweight Report
**      RPD   Report level descriptions

 * Dtl Line totals *
 ** Pallet totals **
 *** Compartment totals ***
 **** Totals ****
**   OVRPRTF statment
OVRPRTF FILE(OR660CPR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
