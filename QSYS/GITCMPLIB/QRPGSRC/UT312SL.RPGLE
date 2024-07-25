     *----------------------------------------------------------------
     *
     *  UT312SL Change slot locations-add new slots to front of aisle
     *  04 October 2006
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     uf   e           k disk
     Fvslot1    uf   e           k disk
     *----------------------------------------------------------------
     *  Variables
     D $paisl          s                   like(slaisl)
     D $pwhdp          s                   like(slwhdp)
     D $pwhse          s                   like(slwhse)
     D svdisp          s                   like(sldisp)
     D temp2n          s              2  0
     *----------------------------------------------------------------
     D                 ds
     D  sldisp                 1     12
     D  snloc                  2      3s 0
     *----------------------------------------------------------------
     *  Main line
     *
     *  Define partial key for SLOT1.
     *
     C     slotky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $paisl
     *  Define partial key for VSLOT1.
     *
     C     vsltky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    svdisp
     *
     *  Hard code aisle being reslotted
     *
     C                   eval      $pwhse = 1
     C                   eval      $pwhdp = 'DRY  '
     C                   eval      $paisl = '  J'
     *
     *  Loop through all the records for the aisle.
     *
     C*    slotky        setll     slot1                              7979
     C     slotky        setgt     slot1                              7979
     C                   dow       not *in79
     C     slotky        readpe    slot1                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Save original slot display to access vritual slot
     *
     C                   eval      svdisp = sldisp
     *
     *     Increment slot location - hard code.
     *
     C                   eval      slloc = slloc + 12
     C                   eval      snloc = snloc + 12
     *
     *     Update slot record with new location and display
     *
     C                   update    slrec
     *
     *     Update virtual slot with new location.
     *
     C     vsltky        chain     vslot1
     C                   if        %found
     C                   eval      vsloc = slloc
     C                   eval      vsdisp = sldisp
     C                   update    vsrec
     C                   endif
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
