     *----------------------------------------------------------------
     *
     *  UTCBI005     Recalculate PIR picking sequences - Cheney PG
     *  13 February 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Notes: Cheney PG chose to have PIR aisles resequenced starting
     *         with even slots aisle DX, then DY, then start with odd
     *         slots, aisle DX, then DY. Per Mark E.
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $paisl          s                   like(slaisl)
     D $pwhdp          s                   like(slwhdp)
     D $pwhse          s                   like(slwhse)
     D forever         s              1
     D hldseq          s              5  0
     D side            s              1  0
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
     *    Resequence Dry PIR Aisle DX Even Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DX'
     C                   eval      forever = *on
     C                   eval      side    = 0
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
     C                   if        slside <> side
     C                   iter
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
     *    Resequence Dry PIR Aisle DY Even Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DY'
     C                   eval      forever = *on
     C                   eval      side    = 0
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
     C                   if        slside <> side
     C                   iter
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
     *    Resequence Dry PIR Aisle DX Odd Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DX'
     C                   eval      forever = *on
     C                   eval      side    = 1
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
     C                   if        slside <> side
     C                   iter
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
     *    Resequence Dry PIR Aisle DY Odd Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DY'
     C                   eval      forever = *on
     C                   eval      side    = 1
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
     C                   if        slside <> side
     C                   iter
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
