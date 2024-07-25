     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDHAL020  Update INVSLOT IVSPCK=N with Stock Qty from SLOT file.
     *  23 July 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
710 A*  07/23/17  MLB  7.10
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *  - This program was created to update IVSPCK=N records with qty
     *    from SLOT3 file. This was needed since Halsey could not
     *    complete their inventory and needed the current inventory to
     *    be updated as counted.
     *
     *----------------------------------------------------------------

     finvslot   uf   e           k disk
     fslot4     if   e           k disk
     *
     D kywhse          s              3  0
     D today           s              8  0 inz(0)
     *----------------------------------------------------------------
     *  Called programs
     *
     d @cvtdt          c                   const('CVTDTE')
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
     *----------------------------------------------------------------
     *
     C     keyivs        klist
     C                   kfld                    ivswhs
     *
     C     keysl         klist
     C                   kfld                    ivswhs
     C                   kfld                    ivswhd
     C                   kfld                    ivsitm
     C                   kfld                    ivsdsp
     *
     *  Convert today's date into century format.
     *
     c                   eval      $cvcmd = '*CURCMD '
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   eval      today = $cvd8o
     c                   time                    updtime           6 0
     *
     C                   eval      ivswhs = 001
     C     keyivs        setll     invslot
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C     keyivs        reade     invslot
     C                   if        %eof(invslot)
     C                   leave
     C                   endif
     *
     *      Update Overflow Slots to show that they've been counted.
     C                   if            ivspck = 'N'
HAL AC                             and ivswhd = 'FRZ'
HAL AC                             and ivsedt = 0
     *
     C     keysl         chain     slot4
     C                   if        %found(slot4)
     C                   eval      ivsqt1 = slstk1
     C                   eval      ivsqt2 = slstk2
     C                   eval      ivsqt3 = slstk3
     *
     C                   eval      ivseby = 'BFC'
     C                   eval      ivsedt = today
     C                   eval      ivsetm = updtime
     *
     C                   eval      ivscby = 'BFC'
     C                   eval      ivscdt = today
     C                   eval      ivsctm = updtime
     *
     C                   update    ivsrec
     *
     c                   endif
     C                   unlock    invslot
     *
     c                   endif
     *
     c                   enddo
     *
     C                   eval      *inlr = '1'
     *
