510cA /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  QDGMM010  Update SLOT file with NDS slots from ORDDS.
     F*  30 July 2012
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
GMM AF*    07/30/12  MLB  GMM
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Notes:
     F*
     F*    This program was created as a Q&D pgm to populate the SLOT
     F*    file with item number information so that pgm, QDGMM015 can
     F*    be run to migrate items from the NDS slots into the Dakota
     F*    formatted slots.  Partly, this pgm is being created so that
     F*    Roxanne can go on-site to train GMM users.
     F*
     F*----------------------------------------------------------------
     FRTEHED5   IF   E           K DISK
     FORDH3     IF   E           K DISK
     FORDDS     IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FSLOT2     UF   E           K DISK
     C*
     C*  Define keys
     C*
     C     RHKEY1        KLIST
     C                   KFLD                    KYWHSE            3 0
     C                   KFLD                    KYPRTD            8 0
     C                   Z-ADD     001           KYWHSE
     C                   Z-ADD     20120722      KYPRTD
     C     RHKEY2        KLIST
     C                   KFLD                    KYWHSE
     C*
     C     OH3KEY        KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    RHRTID
     C*
     C     OSKEY         KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    OHORD
     C*
     C     ITKEY         KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    ositem
     C*
     C     sl2key        KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    itwhdp
     C                   KFLD                    osdisp
     C*
     C                   MOVE      *OFF          *IN79
     C     RHKEY1        SETLL     RTEHED5
     C                   dow       not %eof(rtehed5)
     C     RHKEY2        READE     RTEHED5
     C*
     C                   SELECT
     C                   when      %eof(rtehed5)
     C                   LEAVE
     C*
     C     RHSTAT        WHENNE    '6'
     C                   ITER
     C*
     C     RHSTAT        WHENEQ    '6'
     C     RHPRTD        ANDGE     20120722
     C*
     C     OH3key        SETLL     ORDH3
     C                   dow       not %eof(ordh3)
     C     oh3key        READE     ordh3
     C*
     C                   SELECT
     C                   when      %eof(ordh3)
     C                   LEAVE
     C*
     C                   other
     C*
     C     oskey         SETLL     ordds
     C                   dow       not %eof(ordds)
     C     oskey         READE     ordds
     C*
     C                   SELECT
     C                   when      %eof(ordds)
     C                   LEAVE
     C*
     C*      slot assigned to item for picking.
     C                   when      osdisp > ' '
     C*
     C     itkey         chain     piritem
     C*      Item is Normal or type B=Breakdown item.
     C                   if        %found(piritem)
     C                             and (ittype = ' '
     C                               or ittype = 'B')
     C*
     C     sl2key        chain     slot2
     C                   if        %found(slot2)
     C                             and slitem = ' '
     C                             and slstat = 'V'
     C                   eval      slitem = ositem
     C                   eval      slstat = 'A '
     C                   update    slrec
     C*
     C                   else
     C                   unlock    slot2
     C                   endif                                                  Slot2 Endif
     C*
     C                   endif                                                  Piritem Endif
     C*
     C                   ENDSL                                                  Ordds Endsl
     C*
     C                   ENDDO                                                  Ordds Enddo
     C*
     C                   ENDSL                                                  Ordh3 Endsl
     C*
     C                   ENDDO                                                  Ordh3 Enddo
     C*
     C                   ENDSL                                                  Rtehed Endsl
     C*
     C                   ENDDO                                                  Rtehed Enddo
     C*
     C                   MOVE      *ON           *INLR
     C*
     C*----------------------------------------------------------------
