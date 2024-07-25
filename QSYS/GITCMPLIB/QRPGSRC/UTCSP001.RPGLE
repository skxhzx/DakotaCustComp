     F*----------------------------------------------------------------
     F*
     F*  UTCSP001   Reset REF Aisle 63 Pick Sequence to Negative Value. Coastal
     F*  06 May 2014
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
     C                   kfld                    kyloc
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
     C*    Aisle 60 - Odd-side only from back of aisle
     C*
     C                   MOVE      'REF  '       KYWHDP
     C                   MOVE      ' 63'         KYAISL
     C                   Z-ADD     107           KYLOC
     C                   Z-SUB     2000          INCODD            5 0
     C                   Z-SUB     2000          INCEVN            5 0
     C                   EXSR      RESEQCSP
     C*
     C                   MOVE      *ON           *INLR
     C*----------------------------------------------------------------
     C*
     C*          Subroutines In Alphabetical Order
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
     C     *LIKE         DEFINE    SLLOC         KYLOC
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
     C*
     C*----------------------------------------------------------------
     C*
     C*  RESEQCSP   Re-sequence routine - Coastal Sunbelt
     C*
     CSR   RESEQCSP      BEGSR
     C*
     C*  Loop through all the records for the aisle.
     C*
     CSR   SLKEY         SETLL     SLOT1                              7979
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   SLOTKY        READE     SLOT1                                  79
     CSR   *IN79         IFEQ      *ON
     CSR                 LEAVE
     CSR                 ENDIF
     C*
     C*     Change picking sequence for odd-side only.
     C                   if            slwhdp = 'REF'
     C                             and slloc >= 107
     C                             and slloc <= 171
     C                             and slside = 1
     C                             and slpick = 'Y'
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
     C                   ENDIF
     C*
     CSR                 ENDDO
     CSR                 ENDSR
