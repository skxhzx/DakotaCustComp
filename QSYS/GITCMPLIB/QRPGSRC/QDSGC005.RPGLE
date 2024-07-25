     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC005  Q&D SGC Fix SLLOC, SLRVL from SLDISP field.
     *  07 February 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    02/07/11  MLB  6.40
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

     FSLOT2     uf   e           k disk
     Fvslot     uf   e           k disk
     Flicactive1uf   e           k disk

     C     sl2key        klist
     C                   kfld                    kywhse            3 0
     C                   kfld                    kywhdp            5
     C
     C                   z-add     001           kywhse
     C                   move      'FRZ  '       kywhdp
     C                   move      '1'           forever           1
     C                   move      *zeros        wkloc             3
     C                   move      *zeros        wklvl             2
     C*
     C*
     C     sl2key        setll     slot2
     C                   dow       forever = forever
     C     sl2key        reade     slot2
     C                   if        %eof(slot2)
     C                   leave
     C                   endif
     C*
     C                   if        %subst(sldisp:3:1) = '0'
     C                   iter
     C                   endif
     C*
     C*      skip zero level slots. left over from old freezer.
     C                   if        slwhdp = 'FRZ'
     C                             and %subst(sldisp:3:1) >= '1'
     C                             and %subst(sldisp:3:1) <= '9'
     C                             and %subst(sldisp:4:2) >= '00'
     C                             and %subst(sldisp:4:2) <= '99'
     C*
     C                   eval      wkloc = '0' + %subst(sldisp:4:2)
     C                   move      wkloc         slloc
     C*
     C                   eval      wklvl = '0' + %subst(sldisp:3:1)
     C                   move      wklvl         slrlvl
     C*
     C                   update    slrec
     C                   endif
     C*
     C                   enddo
     C*
     C*    Correct VSLOT VSLOC and VSRLVL fields.
     C     sl2key        setll     vslot
     C                   dow       forever = forever
     C     sl2key        reade     vslot
     C                   if        %eof(vslot)
     C                   leave
     C                   endif
     C*
     C                   if        %subst(vsdisp:3:1) = '0'
     C                   iter
     C                   endif
     C*
     C*      skip zero level slots. left over from old freezer.
     C                   if        vswhdp = 'FRZ'
     C                             and %subst(vsdisp:3:1) >= '1'
     C                             and %subst(vsdisp:3:1) <= '9'
     C                             and %subst(vsdisp:4:2) >= '00'
     C                             and %subst(vsdisp:4:2) <= '99'
     C*
     C*
     C                   eval      wkloc = '0' + %subst(vsdisp:4:2)
     C                   move      wkloc         vsloc
     C*
     C                   eval      wklvl = '0' + %subst(vsdisp:3:1)
     C                   move      wklvl         vsrlvl
     C*
     C                   update    vsrec
     C                   endif
     C*
     C                   enddo
     C*
     C*    Correct LICACTIVE LALOC and LARLVL fields.
     C     sl2key        setll     licactive1
     C                   dow       forever = forever
     C     sl2key        reade     licactive1
     C                   if        %eof(licactive1)
     C                   leave
     C                   endif
     C*
     C                   if        %subst(ladisp:3:1) = '0'
     C                   iter
     C                   endif
     C*
     C*      skip zero level slots. left over from old freezer.
     C                   if        lawhdp = 'FRZ'
     C                             and %subst(ladisp:3:1) >= '1'
     C                             and %subst(ladisp:3:1) <= '9'
     C                             and %subst(ladisp:4:2) >= '00'
     C                             and %subst(ladisp:4:2) <= '99'
     C*
     C                   eval      wkloc = '0' + %subst(ladisp:4:2)
     C                   move      wkloc         laloc
     C*
     C                   eval      wklvl = '0' + %subst(ladisp:3:1)
     C                   move      wklvl         larlvl
     C*
     C                   update    larec
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
