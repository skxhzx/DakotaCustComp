     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1969
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDGLP020  Extract data from PCKQADJ into IMPFPCKQ
     *  26 August 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  08/26/13  MLB  6.50
     *    - Created.
     *
     *----------------------------------------------------------------

     fpckqadj   if   e           k disk
     fimpfpckq  o    e             disk
     *
     D datestamp       s               d
     D timestamp       s               t
     D kywhse          s              3  0
     D kyids           s                   like(pqhids)
640 AD dftdatetime     s             26    inz('2011-03-04-15.30.34.000000')
     D wkdate          s              8  0
     D wktime          s              6  0
     *
640 AC     keypqh        klist
640 AC                   kfld                    kywhse
640 AC***                kfld                    kyids
     *
640 AC                   eval      kywhse = 001
     C     *iso          move      dftdatetime   kyids
     C     keypqh        setll     pckqadj
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      pckqadj
     C                   if        %eof(pckqadj)
     C                   leave
     C                   endif
     C*
     C                   move      pqhids        datestamp
640 AC                   move      pqhids        timestamp
     C     *iso          move      datestamp     wkdate
640 AC     *iso          move      timestamp     wktime
     C                   if            wkdate >= 20130825
     C                             and wkdate <= 20130826
640 AC***                          and wktime >= 153034
640 AC***                          and wktime <= 240000
     c                   eval      ipqwhs = pqhwhs
     c                   eval      ipqwhd = pqhwhd
     c                   eval      ipqdsp = pqhdsp
     c                   eval      ipqitm = pqhitm
     c                   eval      ipqqp1 = pqhqp1
     c                   eval      ipqqp2 = pqhqp2
     c                   eval      ipqqp3 = pqhqp3
     c                   eval      ipqadj = pqhadj
     c                   eval      ipqmem = pqhmem
     c                   eval      ipqsof = pqhsof
     *
     c                   write     ipqrec
     *
     c                   endif
     *
     c                   enddo
     *
     C                   eval      *inlr = '1'
     *
