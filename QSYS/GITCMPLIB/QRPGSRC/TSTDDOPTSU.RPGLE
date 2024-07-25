      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTDDOPTSU    Test DDOPTSUPD
     *  05 September 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    09/05/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     D  pErrMsg        s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pJSON          s           4096    varying

     D ddoptsupd       pr                  extpgm('DDOPTSUPD')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pJSON                      4096    varying

      /free

         pErrMsg = '';
         pSessId = '123456';
         pUser   = 'TEST';
         pPgm    = 'TSTDDOPTSU';
         pObjLoc = 'CALCOBJ';
         pJSON   = '';

         ddoptsupd(pErrMsg:
                   pSessId:
                   pUser:
                   pPgm:
                   pObjLoc:
                   pJSON);

       return;
      /end-free
