     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC004  Q&D SGC Fix SLEXPD from Journal UB entries.
     *  20 May 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    05/20/09  MLB  5.20
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fjrnslotmb if   e           k disk
     F                                     prefix(UB_)
     Fslot2     uf   e           k disk

     C     sl2key        klist
     C                   kfld                    ub_slwhse
     C                   kfld                    ub_slwhdp
     C                   kfld                    ub_sldisp
     C
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      jrnslotmb
     C                   if        %eof(jrnslotmb)
     C                   leave
     C                   endif
     C
     C                   if        ub_slpick = 'N'
     C     sl2key        chain     slot2
     C                   if        %found(slot2)
     C                   eval      slexpd = ub_slexpd
     C                   update    slrec
     C*
     C                   endif
     C*
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
