     h/copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  UTCSP010   Delete old whse SLOT/VSLOT records.
     F*  14 June 2016
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FSLOT1     UF   E           K DISK    rename(slrec : slrec1)
     Fvslot1    UF   E           K DISK    rename(vsrec : vsrec1)
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C     vskey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     C*
     C*  Hard code warehouse.
     C*
     C*
     C*    - Remove all old whse RP=Repack slots.
     C*
     C                   Z-ADD     001           KYWHSE            3 0
     C     kywhse        setll     slot1
     C                   dow       forevr = forevr
     C     kywhse        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     C
     C                   if            slbld = 'RP'
     C                             and sldesg <> 'BFC'
     C                             and (slstat  = 'I '
     C                               or slstat  = 'V ')
     C                             and slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C
     C                   if        slrsrv = 'V'
     C     vskey         chain     vslot1
     C                   if        %found(vslot1)
     C                   delete    vsrec1
     C                   endif
     C                   endif
     C
     C                   delete    slrec1
     C
     C                   endif
     C
     C                   enddo
     C*
     C*
     C*    - Remove all old whse None-Repack slots.
     C*
     C                   Z-ADD     001           KYWHSE
     C     kywhse        setll     slot1
     C                   dow       forevr = forevr
     C     kywhse        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     C
     C                   if            slbld <> 'NW'
     C                             and sldesg <> 'BFC'
     C                             and (slstat  = 'I '
     C                               or slstat  = 'V ')
     C                             and slaisl <> 'JIT'
     C                             and slaisl <> ' 52'
     C                             and slaisl <> ' 99'
     C                             and slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C
     C                   if        slrsrv = 'V'
     C     vskey         chain     vslot1
     C                   if        %found(vslot1)
     C                   delete    vsrec1
     C                   endif
     C                   endif
     C
     C                   delete    slrec1
     C
     C                   endif
     C
     C                   enddo
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
     C*
     CSR                 ENDSR
