     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDICB100  Extract data from PCKQADJ into IMPFPCKQ
     *  17 September 2012
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*  09/17/12  MLB  6.40
     *    - Created.
     *
640 A*  03/05/11  MLB  6.40
     *    - Revised to test date/time stamp pqhids for rcds to select.
     *      Needed to fix problem with mod to hq245 that did not include
     *      customer number as part of the lookup when determining to
     *      skip and adjustment or not. Extract all rcds with *S in memo
     *      code field and MV code. Write out rcds with F2 code.
     *    - Pgm copied from QDCSP100 and revised for ICB.
     *
     *----------------------------------------------------------------

640 Df*pckqadj   if   e           k disk
640 Mfpckqadj1  if   e           k disk
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
640 AC                   kfld                    kyids
     *
640 AC                   eval      kywhse = 001
640 AC     *iso          move      dftdatetime   kyids
640 AC     keypqh        setll     pckqadj1
     C                   move      '1'           forever           1
     C                   dow       forever = forever
640 DC*                  read      pckqadj
640 MC                   read      pckqadj1
640 DC*                  if        %eof(pckqadj)
640 MC                   if        %eof(pckqadj1)
     C                   leave
     C                   endif
     C*
     C                   move      pqhids        datestamp
640 AC                   move      pqhids        timestamp
     C     *iso          move      datestamp     wkdate
640 AC     *iso          move      timestamp     wktime
     C**                 if            wkdate >= 20110304
     C**                           and wkdate <= 20110304
640 AC**                           and wktime >= 153034
640 AC**                           and wktime <= 240000
640 AC**                           or  wkdate >= 20110305
640 AC**                           and wkdate <= 20110305
640 AC**                           and wktime >= 000000
640 AC**                           and wktime <= 092247
ICB MC                   if            %subst(pqhmem:29:2) = '*S'
ICB MC                             and pqhadj = 'MV'
     c                   eval      ipqwhs = pqhwhs
     c                   eval      ipqwhd = pqhwhd
     c                   eval      ipqdsp = pqhdsp
     c                   eval      ipqitm = pqhitm
     c                   eval      ipqqp1 = pqhqp1
     c                   eval      ipqqp2 = pqhqp2
     c                   eval      ipqqp3 = pqhqp3
ICB Dc*                  eval      ipqadj = pqhadj
ICB MC                   eval      ipqadj = 'F2'
     c                   eval      ipqmem = pqhmem
ICB AC                   eval      ipqmem = %replace('  ':ipqmem:29)
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
