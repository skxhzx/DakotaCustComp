     *----------------------------------------------------------------
     *
     *  UTCBI005     Recalculate PIR picking sequences - Cheney PG
     *  22 December 2015
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Notes: Cheney PG chose to have PIR aisles resequenced starting
     *         with even slots aisle FX, then FY, then start with odd
     *         slots, aisle FX, then FY. Per Mark E.
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
     *
     *  Hard code aisle being resequenced.
     *
     *    Resequence Frz PIR Aisle FX Odd Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'FRZ  '
     C                   eval      $paisl = ' FX'
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
     *    Resequence Frz PIR Aisle FY Odd Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'FRZ  '
     C                   eval      $paisl = ' FY'
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
     *    Resequence Frz PIR Aisle FX Even Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'FRZ  '
     C                   eval      $paisl = ' FX'
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
     *    Resequence Frz PIR Aisle FY Even Side.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'FRZ  '
     C                   eval      $paisl = ' FY'
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
     C     #past         tag
     *
     C                   eval      *inlr = '1'
