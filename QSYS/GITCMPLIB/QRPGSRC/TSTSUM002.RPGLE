      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTSUM002   Test UPDSUM002
     *  29 September 2014
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0

      /free
         pSessId = '1234';
         pUser = 'USER';
         pPgm = 'TSTSUM002';
         pObjLoc = '';
         pWhse = 1  ;
      /end-free

     c                   call      'UPDSUM002'
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pWhse

      /free
       *inlr = *on;
      /end-free
