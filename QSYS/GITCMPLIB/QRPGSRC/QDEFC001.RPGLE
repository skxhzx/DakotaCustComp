     F*----------------------------------------------------------------
     F*
     F*  QDEFC001  Create Deleted ORDD records from LABEL90
     F*  25 July 2011
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
640 AF*    07/25/11  MLB  6.40
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     FLABEL90   IF   E           K DISK
     FORDD      uf a E           K DISK
     C*
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $ptrn             7
     C*
     C*  Define keys
     C*
     C     LBKEY         KLIST
     C                   KFLD                    kyWHSE            3 0
     C                   KFLD                    kytrn#            7 0
     C*
     C     odKEY         KLIST
     C                   KFLD                    lbwhse
     C                   KFLD                    lbord
     C                   KFLD                    lbseq
     C                   KFLD                    lbitem
     C*
     C                   move      $pwhs         kywhse
     C                   move      $ptrn         kytrn#
     C                   MOVE      *OFF          forever           1
     C     lbkey         setll     label90
     C                   dow       forever = '0'
     C     lbkey         reade     label90
     C*
     C                   SELECT
     C                   when      %eof(label90)
     C                   leave
     C*
     C                   when         lbtype = 'B'
     C                             or lbtype = 'O'
     C     odkey         chain     ordd
     C                   if        not %found(ordd)
     C                   clear                   odrec
     C*
     C*      Order detail not on file, create record.
     C                   eval      odwhse = lbwhse
     C                   eval      odord  = lbord
     C                   eval      odseq  = lbseq
     C                   eval      oditem = lbitem
     C                   endif
     C*
     C                   select
     C                   when      lbtype = '2'
     C                   eval      odqor3 = odqor3 + lbqalc
     C                   when      lbtype = '1'
     C                   eval      odqor2 = odqor2 + lbqalc
     C                   other
     C                   eval      odqor1 = odqor1 + lbqalc
     C                   endsl
     C*
     C*      Order detail not on file, create record.
     C                   if        not %found(ordd)
     C                   write     odrec
     C*
     C                   else
     C                   update    odrec
     C*
     C                   endif
     C*
     C                   endsl
     C*
     C                   ENDDO
     C*
     C                   MOVE      *ON           *INLR
     C*
     C*----------------------------------------------------------------
