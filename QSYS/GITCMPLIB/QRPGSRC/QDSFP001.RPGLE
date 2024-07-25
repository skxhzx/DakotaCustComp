     F*----------------------------------------------------------------
     F*
     F*  QDTRANRCV   Recover tran records from journal.
     F*  18 May 2005
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FJRNITEM   IP   E             DISK    prefix(jr_)
     FPIRITEM   UF   E           K DISK

     C*----------------------------------------------------------------
     C* Main line
     C*
     C     keyit         klist
     C                   kfld                    jr_itwhse
     C                   kfld                    jr_ititem

     C                   if        jr_jopgm =  'II295 '
     C                             and jr_joentt =  'UB'

     C     keyit         chain     piritem
     C                   if        %found
     C                   eval      itslif = jr_itslif
     C                   update    itrec
     C                   endif
     C                   endif

     C     bottom        tag
