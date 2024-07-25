     F*----------------------------------------------------------------
     F*
     F*  UTFRF001   Reset DRY/FRZ picking sequences to Negative Value.
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
     C                   Z-ADD     011           KYWHSE
     C*
     C*    Aisle 22 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 22'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 23 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 23'         KYAISL
     C                   Z-SUB     2000          INCODD            5 0          155-105
     C                   Z-SUB     2000          INCEVN            5 0          118-146
     C                   EXSR      RESEQ
     C*
     C*    Aisle 24 - Odd/even from back of aisle
     C*
     C                   MOVE      'DRY  '       KYWHDP
     C                   MOVE      ' 24'         KYAISL
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
