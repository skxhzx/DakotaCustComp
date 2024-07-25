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
GMM A*  08/31/16  MLB  GMM
     *    - Revised pgm to extract duplicated adj's from 8/30/16
     *      at 18:11:35 - 18:11:36.
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
     C                   eval      kydate = 20160830
     C     keyia         setll     itemadj3
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemadj3
     C                   if        %eof(itemadj3)
     C                   leave
     C                   endif
     C*
GMM MC                   if            iadate >= 20160830
GMM MC                             and iadate <= 20160830
GMM MC                             and iatime >= 181135
GMM MC                             and iatime <= 181136
GMM MC                             and (iacode =  'TF')
GMM DC**                             or iacode =  'RF'
GMM DC**                             or iacode =  'RT'
GMM DC**                             or iacode =  'XD')
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
