     *----------------------------------------------------------------
     *
     *  UTYHT003     Recalculate PIR picking sequences - Y.Hata
     *  06 February 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     if   e           k disk    rename(SLREC : SLREC1)
     F                                     prefix(sl1)
     Fslot2     uf   e           k disk    rename(SLREC : SLREC2)
     Fslot8qdyhtuf   e           k disk    rename(slrec : slrec8)
     F                                     prefix(sl8)
     *
     *----------------------------------------------------------------
     *  Notes: Y.Hata chose to have PIR aisles resequenced from
     *         Level 1 to Level 9 by bay, then move to next bay and
     *         sequence slots in descending sequence for aisle 61
     *         and aisle 63. Aisle 62 will be done the same except
     *         in descending sequence from the back of the aisle.
     *       - Aisle 63 is different in that the odd slots start at
     *         649 - 855 and even slots start at 522 - 552. Pgm
     *         reads slot from each aisle and feeds the slot to pgm
     *         PIRPCK.
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $paisl          s                   like(sl1slaisl)
     D $ploc           s                   like(sl1slloc )
     D $prlvl          s                   like(sl1slrlvl)
     D $pstyp          s                   like(sl1slstyp)
     D $pwhdp          s                   like(sl1slwhdp)
     D $pwhse          s                   like(sl1slwhse)
     D forever         s              1
     D hldseq          s              5  0
     D hldloc          s                   like(sl1slloc)
     D                                     inz(-999)
     D hldloc8         s                   like(sl1slloc)
     D hldlvl          s                   like(sl1slrlvl)
     D                                     inz(-99)
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *  Define partial key for SLOT1.
     *
     C     slotky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $paisl
     *
     C     *like         define    sl1sldisp     kydisp
     C     slotky2       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    kydisp
     *
     C     slotky8       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pstyp
     C                   kfld                    $paisl
     C                   kfld                    $prlvl
     C                   kfld                    $ploc
     *
     C     slotky8a      klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pstyp
     C                   kfld                    $paisl
     C                   kfld                    $prlvl
     *
     C     slotky8b      klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pstyp
     C                   kfld                    $paisl
     *
BS  D**                   GOTO #PAST2
     *
     *  Hard code aisle being resequenced.
     *
     *    Resequence Dry PIR Aisle 63.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' 63'
     C                   eval      $pstyp = 'P'
     C                   eval      $ploc  = 647
     C                   eval      hldloc = 522
     C                   eval      forever = *on
     C                   move      '0'           done1             1
     C                   move      '0'           done8             1
     *
     *  Loop through all the records for the aisle.
     *
     C     slotky        setll     slot1
     C                   dow       forever = forever
     *
     C     #tag1         tag
     C     slotky        reade     slot1                                78
     C                   if        %eof(slot1)
     C                             or sl1slloc > 552
     C                   leave
     C                   endif
     *
     *          Bypass slots with zero location or odd-side slots.
     C                   if           *in78 = '1'
     C                             or sl1slloc <= 0
     C                             or sl1slside = 1
     C                   goto      #tag1
     C                   endif
     *
     *
     *     Call program to calculate picking sequence.
     *
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd             8
     C                   parm      ' '           $lprg            10
     C                   parm                    sl1slwhse
     C                   parm                    sl1slwhdp
     C                   parm                    sl1slaisl
     C                   parm                    sl1slloc
     C                   parm                    sl1slrlvl
     C     sl1slpseq     parm      0             $ppseq            5 0
     C                   parm      ' '           $lrtn             8
     C                   parm      ' '           $lerm            60
     *
     *     Update Even-side slot record with new sequence.
     *
     C                   eval      kydisp = sl1sldisp
     C     slotky2       chain     slot2
     C                   if        %found(slot2)
     C                   eval      slpseq = sl1slpseq
     C                   update    slrec2
     C                   eval      hldseq = sl1slpseq
     C                   endif
     *
     *      Everytime bay changes, advance odd-side slots.
     C                   if        sl1slloc <> hldloc
     C                   eval      $ploc  = hldloc8
     C                   eval      hldloc = sl1slloc
     C                   endif
     *
     *      Everytime Rack Level changes, update 6 ea odd-side slots.
     C                   if        sl1slrlvl <> hldlvl
     C                   eval      $prlvl = sl1slrlvl
     C                   eval      hldseq = sl1slpseq - 1
     C                   eval      hldlvl = sl1slrlvl
     C     slotky8       setgt     slot8qdyht
     C     1             do        6             x                 3 0
     C     slotky8a      reade     slot8qdyht
     C                   if        not %eof(slot8qdyht)
     *
     C                   eval      sl8slpseq = hldseq
     C                   update    slrec8
     C                   endif
     *
     C                   enddo
     C                   eval      hldloc8 = sl8slloc
     *
     C                   endif
     *
     C                   enddo
     *
     *      Process last bay on odd-side of aisle.
     C                   eval      hldseq = 8279
     C     1             do        9             r                 3 0
     C                   eval      $prlvl = r
     *
     C                   if        r > 1
     C     r             div       2             oddeven           5 0
     C                   mvr                     side              5 0
     C                   if        side = 0
     C                   eval      hldseq = hldseq + 2
     C                   else
     C                   eval      hldseq = hldseq + 4
     C                   endif
     *
     C                   endif
     *
     C                   eval      $ploc  = 845
     C     slotky8       setll     slot8qdyht
     C     1             do        6             x
     C     slotky8a      reade     slot8qdyht
     C                   if        not %eof(slot8qdyht)
     C                   eval      sl8slpseq = hldseq
     C                   update    slrec8
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
BS  AC     #past         tag
     *
     C                   eval      *inlr = '1'
