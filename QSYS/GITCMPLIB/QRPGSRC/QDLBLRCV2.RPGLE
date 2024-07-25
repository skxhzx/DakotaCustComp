     F*----------------------------------------------------------------
     F*
     F*  QDLBLRCV   Recover label records from journal.
     F*  18 May 2005
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FJRNLABEL  IP   E             DISK    prefix(jr_)
     FLABEL     UF   E           K DISK

     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   if        jr_jopgm =  'QDLBLRCV'
     C                             and jr_joentt =  'UB'
     C                             and jr_jotime <  '181700'

     C     jr_lblbl#     chain     label
     C                   if        %found
     C                   eval      lbstat = jr_lbstat
     C                   eval      lbsdte = jr_lbsdte
     C                   eval      lbstim = jr_lbstim
     C                   update    lbrec
     C                   endif
     C                   endif

     C     bottom        tag
