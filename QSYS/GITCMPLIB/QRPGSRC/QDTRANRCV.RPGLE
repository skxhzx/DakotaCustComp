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
     FJRNTRAN   IP   E             DISK    prefix(jr_)
     FPIRTRAN   UF   E           K DISK

     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   if        jr_jopgm =  'INZTBS'
     C                             and jr_joentt =  'UB'

     C     jr_pttrn#     chain     pirtran
     C                   if        %found
     C                   eval      ptstat = jr_ptstat
     C                   eval      ptedte = jr_ptedte
     C                   eval      ptetim = jr_ptetim
     C                   eval      ptcdte = jr_ptcdte
     C                   eval      ptctim = jr_ptctim
     C                   update    ptrec
     C                   endif
     C                   endif

     C     bottom        tag
