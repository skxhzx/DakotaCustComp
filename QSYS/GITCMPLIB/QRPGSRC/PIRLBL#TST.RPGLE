     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PIRLBL#     Get next PIR label number
     F*  29 August 1994
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*
     F*  File specs
     F*
     FLABEL     IF   E           K DISK
     C*----------------------------------------------------------------
     C*
     C*  Subprogram parameters
     C*
     C*    Input Parameters
     C*    - None -
     C*
     C*    Returned Parameters
     C*    $NXTNM  Next PIR label number (guarenteed to be
     C*            unique; not guarenteed to be the next used in
     C*            sequence; 000000 is not used)
     C*
     C*----------------------------------------------------------------
     C* Main Line
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $NXTNM            7 0
     C     *DTAARA       DEFINE    PIRLABEL      NEXT#             7 0
     C     *LOCK         IN        NEXT#
     C*
     C*  Data area contains the next sequence number to use.  If it
     C*  has already been used then keep adding 1 until we find one
     C*  that hasn't been used (we will take the chance that all
     C*  9999999 have not been used).
     C*
     C                   MOVE      *OFF          STOP              1
     C     STOP          DOUEQ     *ON
     C     NEXT#         IFEQ      0
     C                   Z-ADD     1             NEXT#
     C                   ENDIF
     C                   Z-ADD     NEXT#         LBLBL#
     C     FILEKY        SETLL     LABEL                                  50
     C     *IN50         IFEQ      *OFF
     C                   MOVE      *ON           STOP
     C                   ELSE
     C                   ADD       1             NEXT#
     C                   ENDIF
     C                   ENDDO
     C*
     C*  Return the unique sequence number.
     C*
     C                   Z-ADD     NEXT#         $NXTNM
     C*
     C*  Update the data area with the next number to be used.
     C*
     C                   ADD       1             NEXT#
     C                   OUT       NEXT#
     C                   RETURN
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Define partial key for LABEL.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    LBLBL#
     CSR                 ENDSR
