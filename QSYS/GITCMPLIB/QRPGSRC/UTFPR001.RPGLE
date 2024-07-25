     *----------------------------------------------------------------
     *
     *  UTFPR001     Recalculate PIR picking sequences - FoodPro
     *  12 March 2020
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Notes: FoodPro implemented PIR in dept DRY with custom formatted
     *         slots. Starting pick level is 6 to 10 then 1 to 5.
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
     *
     *  Hard code aisle being resequenced.
     *
     *    Resequence Dry PIR Aisle DA.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DA'
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
     C*                  if        slrlvl < 6
     C*                  iter
     C*                  endif
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
     *    Resequence Dry PIR Aisle DB.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DB'
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
     *    Resequence Dry PIR Aisle DC.
     C                   eval      $pwhse = 001
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = ' DC'
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
