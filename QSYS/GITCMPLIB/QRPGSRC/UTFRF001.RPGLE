     F*----------------------------------------------------------------
     F*
     F*  UTFRF001   Reset DRY/FRZ picking sequences to Negative Value. Fox River
     F*  13 November 2013
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FSLOT1     UF   E           K DISK
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C     slkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kyaisl
     C*
     C*  Hard code warehouse and department.
     C*
     C*  Resequence each aisle in department.
     C*
     C*    - Using Z-SUB 2000 will reverse the picking sequence
     C*      order verses the actual slot location (SLLOC).
     C*
     C*    - Up/Back is from front of warehouse.
     C*
     C                   Z-ADD     001           KYWHSE
     C*
     C*    Aisle 46 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 46'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 47 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 47'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 48 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 48'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 49 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 49'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 50 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 50'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 51 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 51'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 52 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 52'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 53 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 53'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 54 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 54'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 08 - Odd/even from back of aisle
     C*
     C                   MOVE      'FRZ  '       KYWHDP
     C                   MOVE      ' 08'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C                   MOVE      *ON           *INLR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     CSR   *INZSR        BEGSR
     C                   MOVE      *ON           FOREVR            1
     C*
     C*  Define partial key for SLOT1.
     C*
     C     *LIKE         DEFINE    SLWHSE        KYWHSE
     C     *LIKE         DEFINE    SLWHDP        KYWHDP
     C     *LIKE         DEFINE    SLAISL        KYAISL
     C     SLOTKY        KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    KYWHDP
     C                   KFLD                    KYAISL
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  RESEQ   Initialization subroutine
     C*
     CSR   RESEQ         BEGSR
     C*
     C*  Loop through all the records for the aisle.
     C*
     CSR   SLOTKY        SETLL     SLOT1                              7979
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   SLOTKY        READE     SLOT1                                  79
     CSR   *IN79         IFEQ      *ON
     CSR                 LEAVE
     CSR                 ENDIF
     C*
     C*     Change picking sequence to slot location.
     C*
     CSR   SLSIDE        IFEQ      1                                            Odd
     CSR   SLLOC         ADD       INCODD        SLPSEQ
     CSR                 ELSE                                                   Even
     CSR   SLLOC         ADD       INCEVN        SLPSEQ
     CSR                 ENDIF
     C*
     CSR   SLPSEQ        IFLT      0
     CSR                 Z-SUB     SLPSEQ        SLPSEQ
     CSR                 ENDIF
     C*
     C*     Update slot record with new sequence.
     C*
     CSR                 UPDATE    SLREC
     C*
     CSR                 ENDDO
     CSR                 ENDSR
