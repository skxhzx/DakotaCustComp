     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDGLP010  Extract data from ITEMADJ into IMPFPCKQ
     *  02 August 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  08/08/13  MLB  6.50
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
     C                   eval      kydate = 20130801
     C     keyia         setll     itemadj3
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemadj3
     C                   if        %eof(itemadj3)
     C                   leave
     C                   endif
     C*
     C                   if            iadate >= 20130801
     C                             and iadate <= 20130801
     C                             and iatime >= 185100
     C                             and iatime <= 193900
     C                             and (iacode =  'MV'
     C                               or iacode =  'RF'
     C                               or iacode =  'RT'
     C                               or iacode =  'XD')
     *
     c                   eval      ipqwhs = iawhse
     c                   eval      ipqwhd = iawhdp
     c                   eval      ipqdsp = iadisp
     c                   eval      ipqitm = iaitem
     c                   eval      ipqqp1 = iaqty1
     c                   eval      ipqqp2 = iaqty2
     c                   eval      ipqqp3 = iaqty3
     c                   eval      ipqadj = 'FX'
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
