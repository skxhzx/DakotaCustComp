      *----------------------------------------------------------------
      *
      *  APTCLRDTAQ   Clear APTDTAQ data queue
      *  November 1, 2011
      *  Rod Roller
      *
      *  Revisions
      *
      *----------------------------------------------------------------

     C     *Entry        PList
     C                   Parm                    $plib            10

     C                   call      'QCLRDTAQ'
     C                   parm      'APTDTAQ '    dqname           10
     C                   parm                    $plib

     C                   eval      *inlr = *on
