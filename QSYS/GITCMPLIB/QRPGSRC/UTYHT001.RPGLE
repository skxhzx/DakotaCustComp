     *----------------------------------------------------------------
     *
     *  UTYHT001     Recalculate PIR picking sequences - Y.Hata
     *  27 January 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Notes: Y.Hata chose to have PIR aisles resequenced from
     *         Level 1 to Level 9 by bay, then move to next bay and
     *         sequence slots in descending sequence for aisle 61
     *         and aisle 63. Aisle 62 will be done the same except
     *         in descending sequence from the back of the aisle.
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $paisl          s                   like(slaisl)
     D $pwhdp          s                   like(slwhdp)
     D $pwhse          s                   like(slwhse)
     D forever         s              1
     D hldseq          s              5  0
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
BS  D**                   GOTO #PAST2
     *
     *  Hard code aisle being resequenced.
     *
     *    Resequence Dry PIR Aisle 61.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' 61'
     C                   eval      forever = *on
     *
     *  Loop through all the records for the aisle.
     *
     C     slotky        setll     slot1
     C                   dow       forever = forever
     C     slotky        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
     *     Call program to calculate picking sequence.
     *
     C                   eval      hldseq = slpseq
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd             8
     C                   parm      ' '           $lprg            10
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C     slpseq        parm      0             $ppseq            5 0
     C                   parm      ' '           $lrtn             8
     C                   parm      ' '           $lerm            60
     *
     *     Update slot record with new sequence.
     *
     C                   update    slrec
     *
     C                   enddo
     *
BS  DC***                GOTO      #PAST
     *
     *    Resequence Dry PIR Aisle 62.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' 62'
     *
     *  Loop through all the records for the aisle.
     *
     C     slotky        setll     slot1
     C                   dow       forever = forever
     C     slotky        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
     *     Call program to calculate picking sequence.
     *
     C                   eval      hldseq = slpseq
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd
     C                   parm      ' '           $lprg
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C     slpseq        parm      0             $ppseq
     C                   parm      ' '           $lrtn
     C                   parm      ' '           $lerm
     *
     *     Update slot record with new sequence.
     *
     C                   update    slrec
     *
     C                   enddo
     *
BS  AC                   GOTO      #PAST
     *
     *
     *    Resequence Dry PIR Aisle 63. Done using pgm, UTYHT003.
     *    Aisle 63 required separate custom pgm, due to odd, even slots
     *    not starting at the same location values. Even started with 522
     *    and Odd started with 649. Also, odd-side had not hand-stack slots.
     *    Odd-side had 6 each non-handstack slots per bay.
     **         #PAST2    TAG
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' 63'
     *
     *  Loop through all the records for the aisle.
     *
     C     slotky        setll     slot1
     C                   dow       forever = forever
     C     slotky        reade     slot1
     C                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
     *     Call program to calculate picking sequence.
     *
     C                   eval      hldseq = slpseq
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd
     C                   parm      ' '           $lprg
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C     slpseq        parm      0             $ppseq
     C                   parm      ' '           $lrtn
     C                   parm      ' '           $lerm
     *
     *     Update slot record with new sequence.
     *
     C                   update    slrec
     *
     C                   enddo
     *
BS  AC     #past         tag
     *
     C                   eval      *inlr = '1'
