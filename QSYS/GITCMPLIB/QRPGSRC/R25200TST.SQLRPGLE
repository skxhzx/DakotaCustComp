      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  R25200TST   Test for R25200
     *  06 November 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  ptran          s              7  0
     D  plabel         s              7  0
     D  psplnet        s              5  0
     D  psplnetadj     s              5  0

     C                   call      'R25200'
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm      3808782       pTran
     C                   parm                    pLabel
     C                   parm                    pSplNet
     C                   parm                    pSplNetAdj

     C                   eval      *inlr = *on
