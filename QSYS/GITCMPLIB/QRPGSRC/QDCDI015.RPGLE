      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *   Date: March 20, 2013 / MLB
     *   Pgm: QDCDI015 - Create missing level 1, level 2 slots from level 3.
     *
     *----------------------------------------------------------------
     Fslot1     if   e           k disk    prefix(sl1)
     Fslot2     uf a e           k disk    rename(slrec : slrec2)
     Fqsysprt   O    F  132        PRINTER OFLIND(*IN90)
     *
     D ermsg1          c                   const('Dup. key error creating slot')
     *
     C     *like         define    slwhse        kywhse
     C     *like         define    slwhdp        kywhdp
     C     *like         define    slaisl        kyaisl
     C     *like         define    slloc         kyloc
     C     *like         define    slrlvl        kyrlvl
     C     *like         define    slhand        kyhand
     C     *like         define    sldisp        kydisp
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
     C     kywhse        setll     slot1
     C                   dow       forever = forever
     C
     C     kywhse        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
     *           Look for level 3 slots that are not virutals.
     C                   if        %subst(sl1sldisp:6:1) = '3'
     C                             and sl1slrsrv <> 'V'
     C                   eval      kywhdp = sl1slwhdp
     c                   eval      kydisp = sl1sldisp
     *
     *           Check for level 2 slot.
     C                   eval      kydisp = %replace('2':kydisp:6:1)
     C     sl2key        setll     slot2
     C                   if        not %equal(slot2)
     C     *nokey        clear                   slrec2
     C                   eval      slwhse = sl1slwhse
     C                   eval      slwhdp = sl1slwhdp
     C                   eval      slstyp = sl1slstyp
     C                   eval      slaisl = sl1slaisl
     C                   eval      slloc  = sl1slloc
     C                   eval      slrlvl = 2
     C                   eval      slhand = sl1slhand
     C                   eval      sldisp = kydisp
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slsdef = 'XX'
     C                   eval      slstat = 'NW'
     C                   eval      slside = sl1slside
     *
     C                   write (e) slrec2
     C                   if        %error
     C                   eval      erdesc = ermsg1
     C                   exsr      zzprterr
     C                   endif                                                  Endif - %error
     *
     C                   endif                                                  Endif - Level 2
     *
     *           Check for level 1 slot.
     C                   eval      kydisp = %replace('1':kydisp:6:1)
     C     sl2key        setll     slot2
     C                   if        not %equal(slot2)
     C     *nokey        clear                   slrec2
     C                   eval      slwhse = sl1slwhse
     C                   eval      slwhdp = sl1slwhdp
     C                   eval      slstyp = sl1slstyp
     C                   eval      slaisl = sl1slaisl
     C                   eval      slloc  = sl1slloc
     C                   eval      slrlvl = 1
     C                   eval      slhand = sl1slhand
     C                   eval      sldisp = kydisp
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slsdef = 'XX'
     C                   eval      slstat = 'NW'
     C                   eval      slside = sl1slside
     *
     C                   write (e) slrec2
     C                   if        %error
     C                   eval      erdesc = ermsg1
     C                   exsr      zzprterr
     C                   endif                                                  Endif - %error
     C
     C                   endif                                                  Endif - Lvl 1 <> FD
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
     O                                            8 'QDCDI015'
     O                                           76 'Create Missing Pick Slots '
     O                                           89 '- Exceptions '
     O                                          127 'Page'
     O                       PAGE               132
     O          E            HDR            1
     O                       RDATE         Y      8
     O                       RTIME               18 '  :  :  '
     O                                           81 '001 - CDI Jax Whse'
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
