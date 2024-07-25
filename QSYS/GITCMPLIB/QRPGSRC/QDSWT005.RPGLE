     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSWT005  Q&D SWT - Update SLPSEQ in SLOT for Stockton
     *  16 July 2019
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
SWT A*    04/24/19  MLB  SWT
     *      - Created.  Uses IMPFSTUF3 file to update SLOT2.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fimpfstuf3 if   e           k disk
     Fslot2     uf   e           k disk

     D $pwhse          s                   like(slwhse) inz(0)
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhdp            5

     C     sikey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp

     C     sl2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp

     C
     C                   move      $pwhs         $pwhse
     C                   move      '1'           forever           1

     C                   if        $pwhdp = '*ALL '
     C     $pwhse        setll     impfstuf3
     C                   else
     C     sikey         setll     impfstuf3
     C                   endif

     C                   dow       forever = forever
     C                   if        $pwhdp = '*ALL '
     C     $pwhse        reade     impfstuf3
     C                   else
     C     sikey         reade     impfstuf3
     C                   endif

     C                   if        %eof(impfstuf3)
     C                   leave
     C                   endif
     C
     C     sl2key        chain     slot2
     C                   if        %found(slot2)
     C                   eval      slpseq = sipseq
     C                   update    slrec
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
