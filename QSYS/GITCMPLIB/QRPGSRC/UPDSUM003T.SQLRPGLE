      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0 inz(900)
     d  pMinBefDep     s              3p 0 inz(1)
     d  pMinAftDep     s              3p 0 inz(1)
     d  pSelMrgPcs     s              1    inz('Y')
     d  pSelMrgBlk     s              1    inz('Y')
     d  pSelIdle       s              1    inz('Y')

     C                   call      'UPDSUM003'
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pWhse
     c                   parm                    pMinBefDep
     c                   parm                    pMinAftDep
     c                   parm                    pSelMrgPcs
     c                   parm                    pSelMrgBlk
     c                   parm                    pSelIdle

     c                   eval      *inlr = '1'
