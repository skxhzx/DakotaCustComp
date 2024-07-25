     F*----------------------------------------------------------------
     F*
     F*  TIEHIGHH Create a file holding slotted and not slotted items.
     F*  February 1, 2011
     F*  Jose G. Duque
     F*                     Copied from Pirmodscbi, compiled into
     F*                     Pircstm700 - it was not found in N.V.
     F*                     7/20/15
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FPIRITEM   IF   E           K DISK
     FSLOT3     IF   E           K DISK
     FITEMDEF   IF   E           K DISK
     FTIHIGHSND UF   E           K DISK
     F*
     FTIEHIGHCC O    E             DISK
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
CBI AA*    09/12/13  CBI-JGD
     F*      Switch of primary input file from being Piritem to be
     F*      Tihighsnd. this was needed to be able to pick up all
     F*      records in Tihighsnd file that had an "N" in the
     F*      SNSEND field.
     F*
CBIaAF*    09/12/13  CBIa-JGD
     F*      Add logic for new TIEHIGHCC field "TSLOTYP", this new
     F*      field carries the slot definition.
     F*
     E*----------------------------------------------------------------
     I*  Data structure.
     E*----------------------------------------------------------------
     I*
     C     SLOTKY        KLIST
     C                   KFLD                    ITWHSE
     C                   KFLD                    ITITEM
     C*
CBI AC     PIRKEY        KLIST
CBI AC                   KFLD                    SNWHSE
CBI AC                   KFLD                    SNITEM
      *
      *
      *

     ***PROCESS 1 STARTS-------***----------***----------***----------
      *
      *          Find if tie/high or location changed on item being
      *          processed. File TIHIGHSND is created by Menu:
      *          Pirinv/Opt # 2 and Opt # 12
      *
CBI AC                   READ      TIHIGHSND                              LR
      *
     C     *INLR         DOWNE     *ON
CBI AC                   IF        SNSEND = 'Y'
CBI AC                   GOTO      BYPASS
CBI AC                   ENDIF
      *
CBI AC     PIRKEY        CHAIN     PIRITEM                            79
CBI AC                   IF        *IN79  = *ON
CBI AC                   GOTO      BYPASS
CBI AC                   ENDIF
      *
     C                   CLEAR                   TEREC
     C                   Z-ADD     *ZEROS        CNTR              4 0
      *
     C                   MOVE      ITWHSE        TWHSE
     C                   MOVEL     ITITEM        TITEM
      *
      *          Load tie/High info.
      *
CBI MC     PIRKEY        CHAIN     ITEMDEF                            79
     C     *IN79         IFEQ      *OFF
     C                   Z-ADD     IDTIE         TTIE
     C                   Z-ADD     IDHIGH        THIGH
     C                   ELSE
     C                   MOVE      *ZEROS        TTIE
     C                   MOVE      *ZEROS        THIGH
     C                   ENDIF
      *
      *          Load slot definition
      *
CBIaAC     IDSDEF        IFNE      *BLANKS
CBIaAC                   MOVE      IDSDEF        TSLOTYP
CBIaAC                   ELSE
CBIaAC                   MOVE      '00'          TSLOTYP
CBIaAC                   ENDIF
      *
      *          Load loc# if active slot
      *
     C     SLOTKY        CHAIN     SLOT3                              79
     C     *IN79         IFEQ      *OFF
     C     SLSTAT        IFEQ      'Z'
     C     SLPICK        OREQ      'N'
     C                   MOVE      *BLANKS       TDISP
     C                   ELSE
     C                   MOVE      SLDISP        TDISP
     C                   ENDIF

     C                   WRITE     TEREC
     C                   Z-ADD     *ZEROS        CNTR              4 0
     C                   ELSE
     C                   WRITE     TEREC
     C                   ENDIF
     C                   MOVE      'Y'           SNSEND
     C                   UPDATE    SNDREC
      *
      *
     C     BYPASS        TAG
CBI AC                   READ      TIHIGHSND                              LR
     C                   ENDDO
     ***PROCESS 1 ENDS---------***----------***----------***----------
     C*
      *
     C*
      *                    See Qrpgsrc/Pir/Testlen for Msg Display
     C*          CNTR      DSPLY
      *
