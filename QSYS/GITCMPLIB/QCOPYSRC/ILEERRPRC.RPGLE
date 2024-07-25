     C****************************************************************
     C* $SNDMG - Send the Program Message.
     C****************************************************************
     C     $SNDMG        BEGSR
     C* Call the send message program
     C                   CALL      'QMHSNDPM'
     C                   PARM                    bMSGID
     C                   PARM                    bMSGF
     C                   PARM                    bMSGD
     C                   PARM                    bLEN
     C                   PARM                    bTYPE
     C                   PARM                    bPGMQ
     C                   PARM                    bSTK
     C                   PARM                    bMSGK
     C                   PARM                    bERR
     C*
     C                   ENDSR
     C****************************************************************
     C* $CLRMG - Clear the Message Queue.
     C****************************************************************
     C     $CLRMG        BEGSR
     C*
     C                   MOVE      *BLANKS       bMSGK
     C* Call the Clear Message Queue API.
     C                   CALL      'QMHRMVPM'
     C                   PARM                    bPGMQ
     C                   PARM                    bSTK
     C                   PARM                    bMSGK
     C                   PARM                    bRMV
     C                   PARM                    bERR
     C*
     C                   ENDSR
