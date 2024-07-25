     *----------------------------------------------------------------
     * File Specs
     *
     FSLOT      UF   E           K DISK
     FPIRITEM   IF   E           K DISK
     *----------------------------------------------------------------
     *  Data Specification
     *
     D FOREVR          s              1
     D KYWHSE          s              3  0
     * Main line
     *
     C     SLKEY         KLIST
     C                   KFLD                    SLWHSE
     C                   KFLD                    SLITEM
     *
     C                   READ      SLOT
     C                   IF        NOT %EOF
     C     SLKEY         setll     PIRITEM
520aAC                   dow       forevr = forevr
     C     SLKEY         reade     PIRITEM                                71
     C                   IF        *IN71
     C                   LEAVE
     C                   Else
     C                   IF        ITDESG <> *BLANKS
     C                             and sldesg <> 'BFC  '
     C                   EVAL      SLDESG = ITDESG
     C                   UPDATE    SLrec
     C                   ENDIF
     C                   ENDIF
     C                   ENDDO
     C                   ELSE
     C                   MOVE      *ON           *INLR
     C                   RETURN
     C                   ENDIF
