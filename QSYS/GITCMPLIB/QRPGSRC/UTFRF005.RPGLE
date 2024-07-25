     *----------------------------------------------------------------
     *
     *  UTFRF005     Recalculate PIR picking sequences - Fox River Foods
     *  13 February 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Notes: Fox River chose to have PIR aisles resequenced from
     *         Level 4 to Level 7 by bay, then move to next bay and
     *         sequence slots in descending sequence for aisle 70.
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
     *    Resequence Dry PIR Aisle 70.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' 70'
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
BS  AC     #past         tag
     *
     C                   eval      *inlr = '1'
