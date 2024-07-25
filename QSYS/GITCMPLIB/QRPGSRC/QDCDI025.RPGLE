      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     Flabel94   uf   e           k disk
     Fslot3     if   e           k disk    rename(slrec : slrec3)
     *
     D forevr          s              1
     *
     *       Label94 file key.
     C     lbkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C     *like         define    slwhse        kywhse
     C     *like         define    slwhse        $pwhse
     C     *like         define    slpick        kypick
     C     *like         define    slstat        kystat
     *
     *       Atl Whse file key.
     C                   eval      kywhse = 002
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     sl3KEY        klist
     C                   kfld                    kywhse
     C                   kfld                    slitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $prtid            5
     *
     C                   move      $pwhs         $pwhse            3 0
     *
     C     lbkey         setll     label94
     C                   dow       forevr = forevr
     C     lbkey         reade     label94
     C                   select
     C                   when      %eof(label94)
     C                   leave
     C
     C                   when         lbwhdp = 'CLR'
     C                             or lbwhdp = 'FRZ'
     C
     *      Get pick slot from ATL whse.
     C     sl3key        setll     slot3
     C     sl3key        reade     slot3
     C                   if        %eof(slot3)
     C                   eval      lbaisl = ' '
     C                   eval      lbloc  = 0
     C                   eval      lbpseq = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = ' '
     C                   eval      lbdisp = 'NOPICKSLOT  '
     C                   update    lbrec
     C
     C                   else
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbpseq = slpseq
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbdisp = sldisp
     C                   update    lbrec
     C                   endif
     C
     C                   endsl
     C
     C                   enddo
     *
     C                   eval      *inlr = '1'
     *
