     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDCSP100  Extract data from ITEMADJ into IMPFPCKQ
     *  05 March 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*  03/05/11  MLB  6.40
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *  - This program was created to extract adjustments that posted
     *    successfully via HQ245, but needed to be reversed when the
     *    import batch needed to reprocessed via HQ245 since a large
     *    number of adjustments did not post due to programming error
     *    in HQ245, GETPSLTMV.
     *
     *----------------------------------------------------------------

     fitemadj3  if   e           k disk
     fimpfpckq  o    e             disk
     *
     D kywhse          s              3  0
     D kydate          s              8  0
     *
     C     keyia         klist
     C                   kfld                    kywhse
     C                   kfld                    kydate
     *
     C                   eval      kywhse = 001
     C                   eval      kydate = 20110304
     C     keyia         setll     itemadj3
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemadj3
     C                   if        %eof(itemadj3)
     C                   leave
     C                   endif
     C*
     C                   if            iadate >= 20110304
     C                             and iadate <= 20110304
     C                             and iatime >= 153034
     C                             and iatime <= 240000
     C                             and iacode =  '00'
     C*
     C                             or  iadate >= 20110305
     C                             and iadate <= 20110305
     C                             and iatime >= 000001
     C                             and iatime <= 092247
     C                             and iacode =  '00'
     *
     c                   eval      ipqwhs = iawhse
     c                   eval      ipqwhd = iawhdp
     c                   eval      ipqdsp = ' '
     c                   eval      ipqitm = iaitem
     c                   eval      ipqqp1 = iaqty1
     c                   eval      ipqqp2 = iaqty2
     c                   eval      ipqqp3 = iaqty3
     c                   eval      ipqadj = '95'
     c                   eval      ipqmem = iamemo
     c                   eval      ipqsof = 'Y'
     *
     c                   write     ipqrec
     *
     c                   endif
     *
     c                   enddo
     *
     C                   eval      *inlr = '1'
     *
