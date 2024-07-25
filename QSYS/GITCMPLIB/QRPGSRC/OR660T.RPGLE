     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  OR660T    Truck Pallet Tote Report.
     F*  17 March, 2006
     F*  Jeffrey Jahnke
     F*
     F*  Revisions:
     F*
500 AF*    03/17/06   JCJ  5.00
     F*      - Copied from OR660.
     F*
500aAF*    04/10/06   DAS  5.00a
     F*      - Revised to work with new Tote item number.
     F*        (i.e., "TOTE - 1", "TOTE - 2", etc ...)
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/29  02/02
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     F*
650aA*    05/31/13  RBD  6.50a
     *      - Enh: Added new stop/drop field.  Will print and use
     *        as control break instead of label stop.
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
     FOR660T    IP   E           K DISK
     FWAREHS    IF   E           K DISK
     FRTEHED    IF   E           K DISK
     FLABEL     IF   E           K DISK    prefix(Z)
     FLABEL13   IF   E           K DISK    rename(lbrec:lbr13) prefix(X)
     FPIRITEM   IF   E           K DISK    prefix(Y)
     FITEMMSC   IF   E           K DISK
     FOPTIONS   IF   E           K DISK
     FITEMDSC   IF   E           K DISK
     FOR660TPR  O    E             PRINTER OFLIND(*IN90)
     F                                     USROPN
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D A80             S              1    DIM(80)
     D TTL             S             40    DIM(2) CTDATA PERRCD(1)
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
     D @DOOR           C                   CONST('Door:')
500aDD**TOTE           C                   CONST('TOTE ')
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

      *---------------------------------------------------------------------
      * Variable fields
      *---------------------------------------------------------------------

     D TotFlag         S              1
     D PrtTotLine      S              1    Inz('Y')

     I*----------------------------------------------------------------
     IOQREC
     I                                          PSCOMP        L4
     I                                          PSUNLD        L3
     I                                          PSPLID        L3
650aDI**                                        LBSTOP        L2
650aMI                                          RTSSD         L2
     I                                          LBSEQ         L1
     I                                          LBITEM        L1
     I                                          LBUCOD        L1
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $CMD              8
     C                   PARM                    $RTYPE            8
     C                   PARM                    $DEV             10
     C                   PARM                    $FORM            10
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
     C                   EXSR      OPNPRT
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C*  Init total levels
     C*
     C*  Level 1 break - Item
     C*
     C     *INL1         IFEQ      *ON
     C                   Z-ADD     1             L
     C                   EXSR      ZRZERO
     C                   ENDIF
     C*
     C*  Level 2 break - Stop
     C*
     C     *INL2         IFEQ      *ON
     C                   Z-ADD     2             L
     C                   EXSR      ZRZERO
     C*
520 AC                   EXSR      ZZFGTS
520 AC*
     C                   MOVE      *BLANKS       $CSTR
     C                   MOVE      *BLANKS       CUST#
     C                   MOVE      OHCUST        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         CUST#            11
     C                   MOVEL     OHCNAM        CSNAME
     C                   ENDIF
     C*
     C*  Level 3 break - Pallet ID/Unload sequence
     C*
     C     *INL3         IFEQ      *ON
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
     C*          P#DESC    CAT  ' ** - ':1P#DESC
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
     C                   MOVE      $LDOOR        $CSTR
     C                   CALL      'ADJUST'
     C                   PARM      '*LEFT   '    $CCMD             8
     C                   PARM                    $CSTR            30
     C                   MOVEL     $CSTR         DDOOR             3
     C     P#DESC        CAT       '    - ':1    P#DESC
     C     P#DESC        CAT       @DOOR:1       P#DESC
     C     P#DESC        CAT       DDOOR:1       P#DESC
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
     C                   WRITE     HEAD2
     C                   ENDIF
     C*
     C     *IN92         IFEQ      *ON
     C     *INL2         OREQ      *ON
     C     $RTYPE        IFEQ      '*DETAIL '
     C                   WRITE     DETAIL1
     C                   ENDIF
     C                   ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*  Accumulate totals
     C*
500aDC**                 If        LBITEM = @TOTE
500aMC                   If        %subst(lbitem:1:4) = 'TOTE'
     C                   ADD       LBQPCK        QPCK(1)
      ****               ADD       LBCUBE        CUBE(1)
      ****               ADD       LBSWGT        WGHT(1)
     C                   endif
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      *OFF          *IN94
     C                   MOVE      *OFF          *IN93
     C                   MOVE      *OFF          *IN92
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          FIRST
     C*----------------------------------------------------------------
     C*
     C* Item totals
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
     C* Stop totals
     C*
     CL2                 Z-ADD     2             L
     CL2                 EXSR      ZRROLL
     C*
     CL2   RECK(L)       IFGT      0
     CL2   *IN90         IFEQ      *ON
     CL2                 EXSR      ZRHEAD
     CL2                 ENDIF
     CL2                 EXSR      ZRTOTL
     CL2                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Pallet totals
     C*
     CL3                 Z-ADD     3             L
     CL3                 EXSR      ZRROLL
     C*
     CL3   RECK(L)       IFGT      0
     CL3   *IN90         IFEQ      *ON
     CL3                 EXSR      ZRHEAD
     CL3                 ENDIF
     CL3                 EXSR      ZRTOTL
     CL3                 ENDIF
     C*----------------------------------------------------------------
     C*
     C* Department totals
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
     C                   EXSR      ZZINZ
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
     CSR                 CALL      'GETRPT'
     CSR                 PARM      '*DEVFORM'    $CMD              8
     CSR                 PARM      'OR660TPR'    $LRPT            10
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
     CSR                 CLOSE     OR660TPR
     CSR                 ENDIF
     C*
     CSR                 MOVEA     OVRPRT(1)     A80
     CSR                 MOVEA     $DEV          A80(39)
     CSR                 MOVEA     $FORM         A80(60)
     CSR                 MOVEA     A80           QCMD
     C*
     CSR                 CALL      'QCMDEXC'
     CSR                 PARM                    QCMD             80
     CSR                 PARM      80            QLEN             15 5
     C*
     C*      Open printer file.
     C*
     CSR                 OPEN      OR660TPR
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
     C     $RTYPE        IFEQ      '*SUMMARY'
     C                   MOVE      TTL(1)        TITLE
     C                   ELSE
     C                   MOVE      TTL(2)        TITLE
     C                   ENDIF
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
     C                   ADD       QPCK(L)       QPCK(M)
      ****               ADD       CUBE(L)       CUBE(M)
      ****               ADD       WGHT(L)       WGHT(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C                   Eval      TotFlag = 'N'
500aDC**                 If        LBITEM = @TOTE
500aMC                   If        %subst(lbitem:1:4) = 'TOTE'
     C                   Eval      TotFlag = 'Y'
     C                   Z-ADD     QPCK(L)       T#QPCK
      ***                Z-ADD     CUBE(L)       T#CUBE
      ***                Z-ADD     WGHT(L)       T#WGHT
     C                   ENDIF
     C*
     C                   MOVE      RPD(L)        $RPD
     C*
     C     L             IFEQ      1
     C     $RTYPE        IFEQ      '*DETAIL '

500aDC**                 If        LBITEM = @TOTE
500aMC                   If        %subst(lbitem:1:4) = 'TOTE'

     C                   If        PrtTotLine = 'Y'
     C                   EXSR      ZZGETI
     C                   eval      t#cube = LBCUBE
     C                   WRITE     DETAIL2
     C                   eval      PrtTotLine = 'N'
     C                   endif

     C     LBKEY         chain     LABEL
     C     LBKEY13       SETLL     LABEL13
     C     *IN78         DOUEQ     *ON
     C     LBKEY13       READE     LABEL13                                78
     C     *IN78         IFEQ      *OFF
     C                   EXSR      ZZGETI2
     C                   WRITE     DETAIL3
     C                   ENDIF
     C                   ENDDO

     C                   WRITE     DETAIL4

     C                   ENDIF
      *
     C                   ENDIF
     C                   ENDIF
     C*
     C                   If        L = 2 and TotFlag = 'Y'
     C     $RTYPE        IFEQ      '*DETAIL '
     C                   WRITE     SKIP1
     C                   WRITE     TOTALD
     C                   eval      t#cube1 = *zeros
     C                   eval      t#wght1 = *zeros
     C                   ELSE
     C                   WRITE     TOTAL1
     C                   ENDIF
     C                   ENDIF
     C*
     C                   If        L = 3 and TotFlag = 'Y'
     C                   eval      PrtTotLine = 'Y'
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL2
     C                   eval      t#cube2 = *zeros
     C                   eval      t#wght2 = *zeros
     C                   endif
     C*
     C     L             IFEQ      4
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL3
     C                   eval      t#cube3 = *zeros
     C                   eval      t#wght3 = *zeros
     C                   END
     C*
     C     L             IFEQ      5
     C                   WRITE     SKIP1
     C                   WRITE     TOTAL4
     C                   eval      t#cube4 = *zeros
     C                   eval      t#wght4 = *zeros
     C                   END
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRZERO        BEGSR
     C*
     C                   Z-ADD     0             LVLK(L)
     C                   Z-ADD     0             RECK(L)
     C                   Z-ADD     0             QPCK(L)
     C                   Z-ADD     0             CUBE(L)
     C                   Z-ADD     0             WGHT(L)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZZGETI        BEGSR
     C*
     CSR                 MOVE      *BLANKS       DESCI1
     CSR                 MOVE      *BLANKS       DESCI2
     CSR                 MOVE      '*ITEMMNT'    OCODE             8
     CSR   OPKEY         CHAIN     OPTIONS                            79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      'N'           OPXDSC
     CSR                 ENDIF
     C*
     CSR   OPXDSC        IFEQ      'Y'
     CSR   IDKEY         CHAIN     ITEMDSC                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVE      IXDSC1        DESCI1
     CSR                 MOVE      IXDSC2        DESCI2
     CSR                 ENDIF
     CSR                 ELSE
     CSR                 MOVEL     ITDESC        DESCI1
     CSR                 ENDIF
     C*
     C     IDKEY         CHAIN     ITEMMSC                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       BRAND
     C                   ELSE
     C                   MOVE      IMBRND        BRAND
     C                   ENDIF
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZZGETI2       BEGSR
     C*
     CSR                 eval      t#cube = *Zeros
     CSR                 eval      t#wght = *Zeros
     C*
     CSR   IDKEY2        chain     piritem
     CSR                 if        Not %found(piritem)
     CSR                 eval      yitpdsc = *blanks
     CSR                 else
     CSR                 eval      t#cube = Yitcube * t#qpck
     CSR                 eval      t#wght = Yitswgt * t#qpck
     CSR                 eval      t#cube1 = t#cube1 + t#cube
     CSR                 eval      t#wght1 = T#wght1 + t#wght
     CSR                 eval      t#cube2 = t#cube2 + t#cube
     CSR                 eval      t#wght2 = T#wght2 + t#wght
     CSR                 eval      t#cube3 = t#cube3 + t#cube
     CSR                 eval      t#wght3 = T#wght3 + t#wght
     CSR                 eval      t#cube4 = t#cube4 + t#cube
     CSR                 eval      t#wght4 = T#wght4 + t#wght
     CSR                 endif
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
650aAC                   parm                    $sdrop            3
650aAC                   parm                    $sextd           30
650aAC                   parm                    $ssd              9
520 AC*
520 AC                   if        $SSTP > 0
650aDC**                 eval      dspstp = $sstp
650aMC                   move      $ssd          dspstp
520 MC                   else
650aDC**                 eval      dspstp = lbstop
650aMC                   move      lbstop        dspstp
520 AC                   endif
520 AC*
520 AC                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*     OPTIONS
     C*
     C     OPKEY         KLIST
     C                   KFLD                    LBWHSE
     C                   KFLD                    OCODE
     C*
     C*     EXTENDED ITEM DESCRIPTION
     C*
     C     IDKEY         KLIST
     C                   KFLD                    LBWHSE
     C                   KFLD                    LBITEM
     C*
     C*     EXTENDED ITEM DESCRIPTION
     C*
     C     IDKEY2        KLIST
     C                   KFLD                    LBWHSE
     C                   KFLD                    XLBITEM
      *
     C     LBKEY         KLIST
     C                   KFLD                    LBCTR#
      *
     C     LBKEY13       KLIST
     C                   KFLD                    zlbwhse
     C                   KFLD                    zlbrte
     C                   KFLD                    zlbpal#
      *
     CSR                 ENDSR
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**      TTL   Report title descriptions
Truck Pallet Tote Report
Truck Pallet Tote Report
**      RPD   Report level descriptions

 * Stop totals *
 ** Pallet totals **
 *** Compartment totals ***
 **** Totals ****
**   OVRPRTF statment
OVRPRTF FILE(OR660TPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
