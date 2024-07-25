     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDKHL020  Update INVSLOT IVSPCK=N with Stock Qty from SLOT file.
     *  16 December 2014
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  12/16/14  MLB  6.50
     *    - Created.
730aA*  03/15/19  RH   7.30a
     *    - Enh: Update INVPAGE to show page was entered when program
     *      updated INVSLOT with quantity.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *  - This program was created to update IVSPCK=N records with qty
     *    from SLOT3 file. This was needed since Kohl is going to only
     *    physically count the pick slots. The overflow slots have been
     *    previously counted and updated.
     *
     *----------------------------------------------------------------

     finvslot   uf   e           k disk
     fslot4     if   e           k disk
730aAfinvpage   uf   e           k disk
730aAfinvslot1  if   e           k disk    prefix(x)
730aAF                                     rename(ivsrec:ivsrec1)
     *
     D kywhse          s              3  0
     D today           s              8  0 inz(0)
     D kyspag          s                   like(ivspag)
     D kyswhs          s                   like(ivswhs)
     D svpage          s                   like(ivspag)
     D svseby          s                   like(ivseby)
     D svsedt          s                   like(ivsedt)
     D svsetm          s                   like(ivsetm)
     D svscby          s                   like(ivscby)
     D svscdt          s                   like(ivscdt)
     D svsctm          s                   like(ivsctm)
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
730aAC     keyiv1        klist
730aAC                   kfld                    kyswhs
730aAC**                 kfld                    kyspag
     *
730aAC     keyivp        klist
730aAC                   kfld                    ivswhs
730aAC                   kfld                    svpage
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
     *
     C     keysl         chain     slot4
     C                   if        %found(slot4)
     C                   eval      ivsqt1 = slstk1
     C                   eval      ivsqt2 = slstk2
     C                   eval      ivsqt3 = slstk3
     *
     C                   eval      ivseby = 'BFCKHL'
     C                   eval      ivsedt = today
     C                   eval      ivsetm = updtime
     *
     C                   eval      ivscby = 'BFCKHL'
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
730aA*  Update page as entered if all slots for page are entered
730aAC                   eval      kyswhs = 001
730aAC*                  eval      kyspag = 0
730aA*
730aAC     keyiv1        setll     invslot1
730aAC                   move      '1'           forever           1
730aAC                   dow       forever = forever
730aAC     keyiv1        reade     invslot1
730aAC                   if        %eof(invslot1)
730aAC                   exsr      uppage
730aAC                   leave
730aAC                   endif
730aA*
730aAC                   if        svpage = 0
730aAC                   eval      svpage = xivspag
730aAC                   endif
730aAC     svpage        cabeq     xivspag       next1
730aA*
730aA*      Update page, Slots have been entered.
730aAC                   if        good1 = *on
730aAC                   exsr      uppage
730aAC                   endif
730aA*
730aAC     next1         tag
730aAC                   if        xivseby <> ' '
730aAC                   move      '1'           good1             1
730aAC                   else
730aAC                   eval      good1 = *off
730aAC                   endif
730aAC                   eval      svseby = xivseby
730aAC                   eval      svsedt = xivsedt
730aAC                   eval      svsetm = xivsetm
730aA*
730aAC                   eval      svscby = xivscby
730aAC                   eval      svscdt = xivscdt
730aAC                   eval      svsctm = xivsctm
730aAC                   eval      svpage = xivspag
730aA*
730aAc***                iter
730aAc                   enddo
730aA*
730aA**
730aAC                   eval      *inlr = '1'
730aA*
730aA*----------------------------------------------------------------
730aA*
730aA*  UPPAGE  Updte page as entered.
730aA*
730aAC     uppage        begsr
730aA*
730aA*      Update page, Slots have been entered.
730aAC                   if        good1 = *on
730aAC     keyivp        chain     invpage
730aAC                   if        %found(invpage)
730aA*
730aAC                   eval      ivpsta = 'E'
730aAC                   eval      ivpeby = svseby
730aAC                   eval      ivpedt = svsedt
730aAC                   eval      ivpetm = svsetm
730aA*
730aAC                   eval      ivpcby = svscby
730aAC                   eval      ivpcdt = svscdt
730aAC                   eval      ivpctm = svsctm
730aA*
730aAC                   update    ivprec
730aAC                   endif
730aAC                   endif
730aA*
730aAC                   endsr
