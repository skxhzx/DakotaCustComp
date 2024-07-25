      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *   Date: April 3, 2013 / MLB
     *   Pgm: QDBIR018 - Create missing level 4 slots from level 3.
     *
     *----------------------------------------------------------------
     Fslot1     if   e           k disk    prefix(sl1)
     Fslot2     uf a e           k disk    rename(slrec : slrec2)
     Fqsysprt   O    F  132        PRINTER OFLIND(*IN90)
     *
     D ermsg1          c                   const('Dup. key error creating slot')
     *
     C     *like         define    slwhse        kywhse
     C     *like         define    slwhse        kywhse1
     C     *like         define    slwhdp        kywhdp
     C     *like         define    slwhdp        kywhdp1
     C     *like         define    slaisl        kyaisl1
     C     *like         define    slloc         kyloc
     C     *like         define    slrlvl        kyrlvl
     C     *like         define    slhand        kyhand
     C     *like         define    sldisp        kydisp
     *
     *       Slot1 file key.
     C     sl1key        klist
     C                   kfld                    kywhse1
     C                   kfld                    kywhdp1
     C                   kfld                    kyaisl1
     *
     *       Slot2 file key.
     C     sl2key        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kydisp
     C                   eval      kywhse = 001
     C                   eval      *in90 = '1'
     C                   move      '1'           forever           1
     C                   move      ' '           erdesc           40
     C                   time                    hmsmdy           12 0
     C                   Move      hmsmdy        rdate             6 0
     C                   movel     hmsmdy        rtime             6 0
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *
     C                   eval      kywhse1 = 001
     C                   eval      kywhdp1 = 'DRY  '
     C                   eval      kyaisl1 = '  T'
     C     sl1key        setll     slot1
     C                   dow       forever = forever
     C
     C     sl1key        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
     *           Look for level 3 slots that are not virutals on even side.
     C                   if        sl1slrlvl = 3
     C                             and sl1slside = 0
     C                             and sl1slrsrv <> 'V'
     C                   eval      kywhdp = sl1slwhdp
     c                   eval      kydisp = sl1sldisp
     *
     *           Check for level 4 slot.
     C                   eval      kydisp = %replace('4':kydisp:7:1)
     C     sl2key        setll     slot2
     C                   if        not %equal(slot2)
     C     *nokey        clear                   slrec2
     C                   eval      slwhse = sl1slwhse
     C                   eval      slwhdp = sl1slwhdp
     C                   eval      slstyp = sl1slstyp
     C                   eval      slaisl = sl1slaisl
     C                   eval      slloc  = sl1slloc
     C                   eval      slrlvl = 4
     C                   eval      slhand = sl1slhand
     C                   eval      sldisp = kydisp
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slsdef = sl1slsdef
     C                   eval      slstat = 'NW'
     C                   eval      slside = sl1slside
     C                   eval      slpseq = sl1slpseq
     *
     C                   write (e) slrec2
     C                   if        %error
     C                   eval      erdesc = ermsg1
     C                   exsr      zzprterr
     C                   endif                                                  Endif - %error
     *
     C                   endif                                                  Endif - Level 4
     C
     C                   endif                                                  Endif - Lvl 3 slot

     C                   enddo
     *
     C                   eval      *inlr = '1'
     *
     ***********************************************************
     C     zzprterr      begsr
     C                   if        *in90 = '1'
     C                   except    hdr
     C                   endif
     C
     C                   except    detail

     C                   endsr
     *
     ***********************************************************
     *          *****  OUTPUT *****                            *
     ***********************************************************
     OQSYSPRT   E            HDR            1  2
     O                                            8 'QDBIR015'
     O                                           76 'Create Missing O/Flow Slot'
     O                                           89 '- Exceptions '
     O                                          127 'Page'
     O                       PAGE               132
     O          E            HDR            1
     O                       RDATE         Y      8
     O                       RTIME               18 '  :  :  '
     O                                           81 '001 - BiRite Whse '
     O          E            HDR            1
     O                                           12 'Warehouse : '
     O                       kywhse              15
     O          E            HDR            1
     O                                          132 ' '
     O          E            HDR            0
     O                                            6 '______'
     O                                           18 '___________'
     O                                           30 '________'
     O                                           51 '___________________'
     O                                           69 '________'
     O                                           79 '________'
     O                                           89 '________'
     O                                           99 '________'
     O                                          107 '_____'
     O                                          121 '________'
     O                                          132 '________'
     O          E            HDR            1
     O                                            5 'Dept'
     O                                           11 'Slot'
     O                                           80 'Error Message'
     O          E            DETAIL      1  1
     O                       sl1slwhdp            5
     O                       kydisp              20
     O                       ERDESC              80
