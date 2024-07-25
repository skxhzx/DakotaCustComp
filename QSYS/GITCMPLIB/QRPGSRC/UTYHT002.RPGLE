     *----------------------------------------------------------------
     *
     *  UTYHT002   Reset DRY PIR picking sequences to Negative Value. Aisle 62
     *  27 January 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     *----------------------------------------------------------------
     *  Working variables
     *
     D forever         s              1
     D incevn          s              5  0                                      118-146
     D incodd          s              5  0                                      155-105
     D kyaisl          s                   like(slaisl)
     D kywhdp          s                   like(slwhdp)
     D kywhse          s                   like(slwhse)
     *----------------------------------------------------------------
     *  Main line
     *
     C     slkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kyaisl
     *
     *  Hard code warehouse and department.
     *
     *  Resequence each aisle in department.
     *
     *    - Using Z-SUB 2000 will reverse the picking sequence
     *      order verses the actual slot location (SLLOC).
     *
     *    - Up/Back is from front of warehouse.
     *
     C                   eval      kywhse = 001
     *
     *    Aisle 62 - Odd/even from back of aisle
     *      Slots are numbered from front of whse to back.
     *
     C                   eval      kywhdp = 'DRY  '
     C                   eval      kyaisl = ' 62'
     C                   eval      incodd = -(2000)                             155-105
     C                   eval      incevn = -(2000)                             118-146
     C                   exsr      reseq
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   eval      forever = *on
     *
     *  Define partial key for SLOT1.
     *
     C     slotky        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kyaisl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  RESEQ   Initialization subroutine
     *
     C     reseq         begsr
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
     *     Change picking sequence to slot location.
     *
     C                   if        slside = 1                                   Odd
     C     slpseq        add       incodd        slpseq
     C                   else                                                   Even
     C     slpseq        add       incevn        slpseq
     C                   endif
     *
     C                   if        slpseq < 0
     C                   eval      slpseq = -(slpseq)
     C                   endif
     *
     *     Update slot record with new sequence.
     *
     C                   update    slrec
     *
     C                   enddo
     C                   endsr
