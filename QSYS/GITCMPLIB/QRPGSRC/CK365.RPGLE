     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CK365     Ship check list - Print    CBI
     F*  25 Aug, 2003
     F*  Roxanne Harrison
     F*
     F*----------------------------------------------------------------
     F*
     F*  Program Modification History
     F*  Revisions:
     F*
     F*    08/25/03  RH  4.17
     F*      - Created using SL401
     F*
700 AQ*    10/30/16  MLB  7.00
     F*      - Enh: Converted to ILE.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  91        Overflow Indicator
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FCK365     IP   E           K DISK
     FWAREHS    IF   E           K DISK
     FREPORTS   IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FITEMMSC   IF   E           K DISK
     FITEMDSC   IF   E           K DISK
     FPIRTRAN   IF   E           K DISK
     FRTEHED    IF   E           K DISK
     FPLTSUM2   IF   E           K DISK
     FORDH      IF   E           K DISK
     FCK365PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D RECK            S              7  0 DIM(4)
     D LVLK            S              7  0 DIM(4)
     D*----------------------------------------------------------------
     D*  Pallet id data structure
     D*
     D*    DSPLID  -  Pallet id.
     D*    DSPLXX  -  Unused.
     D*    DSPLGN  -  Generation.
     D*    DSPLRW  -  Pallet row.
     D*    DSPLCL  -  Pallet column.
     D*    DSPLSQ  -  Sequence number.
     D*               Equal to zero     - Only one pallet in this position.
     D*               Greater than zero - Multiple pallets in this position.
     D*
     D*
     D PLTID           DS
     D  DSPLID                 1      7  0 INZ(0)
     D  DSPLXX                 1      2  0
     D  DSPLGN                 3      3  0
     D  DSPLRW                 4      5  0
     D  DSPLCL                 6      6  0
     D  DSPLSQ                 7      7  0
     D*
     D*----------------------------------------------------------------
     D                 DS
     D  DSMISC                 1     20
     D  DSSDTE                 1      8
     D  DSSPCL                 9     11
     D  DSRPCK                12     12
     D  DSDOOR                13     14
     D  DSMEAT                15     15
     I*
     I*----------------------------------------------------------------
     IOQREC
     I                                          WBPAL#        L1
     I*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PRTID            5
     C                   PARM                    $PPGM            10
     C                   PARM                    $RTNCD            8
     C*
     C*
     C*  Report Heading
     C*
     C*
     C     *IN90         IFEQ      '1'
     C     FIRST         OREQ      *ON
417XXC     *INL1         OREQ      *ON
     C                   EXSR      ZRHEAD
     C                   END
     C*
     C*  Init total levels
     C*
     C*
     C*  Level 1 break - PALLET
     C*
     C     *INL1         IFEQ      *ON
     C                   Z-ADD     1             L
     C                   EXSR      ZRZERO
     C                   END
     C*
     C*  Output Headings
     C*
     C     *IN91         IFEQ      '1'
     C     FIRST         OREQ      *ON
     C     *INL1         OREQ      '1'
     C                   MOVE      *OFF          FIRST
     C**         *INL1     OREQ '1'
     C**         *IN91     IFEQ '1'
     C                   WRITE     RPHEAD
     C**                   END
     C                   WRITE     COLUMNS
     C                   END
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*
     C*
     C*
     C     ITKEY         CHAIN     PIRITEM                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       W1PDSC           15
     C                   ELSE
     C                   MOVE      ITPDSC        W1PDSC
     C                   ENDIF
     C*
     C     ITKEY         CHAIN     ITEMDSC                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       W1DESC           60
     C                   ELSE
     C     IXDSC1        CAT       IXDSC2        W1DESC
     C                   ENDIF
     C*
     C     ITKEY         CHAIN     ITEMMSC                            79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       W1BRND           10
     C                   ELSE
     C                   MOVE      IMBRND        W1BRND
     C                   ENDIF
     C                   WRITE     DETAIL
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      '0'           *IN92
     C                   MOVE      '0'           *IN91
     C*----------------------------------------------------------------
     C*
     C* NEW PALLET
     C*
     CL1                 Z-ADD     1             L
     CL1                 EXSR      ZRROLL
     C*
     CL1   RECK(L)       IFGT      0
     CL1                 WRITE     SKIP1
     CL1                 END
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
     CLR                 Z-ADD     3             L
     CLR                 EXSR      ZRROLL
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
     CSR   ITKEY         KLIST
     CSR                 KFLD                    WBWHSE
     CSR                 KFLD                    WBITEM
     C*
     CSR   ORKEY         KLIST
     CSR                 KFLD                    WBWHSE
     CSR                 KFLD                    WBORD
     C*
     CSR   PLKEY         KLIST
     CSR                 KFLD                    WBWHSE
     CSR                 KFLD                    WBRTE
     CSR                 KFLD                    KYTYPE
     CSR                 KFLD                    DSPLGN
     CSR                 KFLD                    DSPLRW
     CSR                 KFLD                    DSPLCL
     C*
     C*
     CSR   RTKEY         KLIST
     CSR                 KFLD                    WBWHSE
     CSR                 KFLD                    WBRTE
     C*
     CSR   RPKEY         KLIST
     CSR                 KFLD                    WKPRTF           10
     C*
     C*   Get report title.
     C*
     CSR                 MOVEL     'CK365PR '    WKPRTF
     CSR                 MOVE      *BLANKS       RPTTTL
     C                   MOVE      *BLANKS       $PSTR
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVEL     RPDESC        $PSTR            60
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       $PSTR
     CSR                 ENDIF
     CSR                 Z-ADD     40            $PLEN             3 0
     C*
     C*   Center report title.
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         RPTTTL
     C*
     CSR                 MOVE      *ON           FIRST             1
     CSR                 TIME                    TIME
     CSR                 Z-ADD     3             L                 1 0
     CSR                 Z-ADD     0             N                 3 0
     CSR                 EXSR      ZRZERO
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFILL        BEGSR
     C*
     C*  Get info to fill HEAD2 fields.
     C*
     CSR   WBTRN#        CHAIN     PIRTRAN                            79
     CSR   *IN79         IFEQ      *ON
     CSR                 Z-ADD     0             W1EMP
     CSR                 ELSE
     CSR                 Z-ADD     PTEMP#        W1EMP
     CSR                 ENDIF
     C*
     CSR                 MOVE      WBWHDP        W1DPT
     CSR                 Z-ADD     WBTRN#        W1TRN
     C*
     CSR   RTKEY         CHAIN     RTEHED                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *BLANKS       W1RTE
     CSR                 ELSE
     CSR                 MOVE      RHRTE         W1RTE
     CSR                 ENDIF
     C*
     CSR                 MOVE      'O'           KYTYPE            1
     CSR                 Z-ADD     WBPAL#        DSPLID
     CSR   PLKEY         CHAIN     PLTSUM2                            79
     CSR   *IN79         IFEQ      *ON
     CSR                 Z-ADD     0             W1PLT
     CSR                 ELSE
     CSR                 Z-ADD     PSPAL#        W1PLT
     CSR                 ENDIF
     C*
     CSR   ORKEY         CHAIN     ORDH                               79
     CSR   *IN79         IFEQ      *ON
     CSR                 Z-ADD     0             W1DOOR
     CSR                 ELSE
     CSR                 MOVEL     OHMISC        DSMISC
     CSR                 MOVE      DSDOOR        W1DOOR
     CSR                 ENDIF
     C*
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C     *INL1         IFEQ      '0'
     C                   MOVE      '1'           *IN91
     C                   END
     C*
     C                   MOVE      '0'           *IN90
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE
     C                   MOVE      *BLANKS       $PSTR
     C     WBWHSE        CHAIN     WAREHS                             79
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
     C                   EXSR      ZRFILL
     C                   WRITE     HEAD2
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
