      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTDDOPTSG    Test DDOPTSGET
     *  05 September 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    09/05/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     D  pCallNum       s              1p 0
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pJSON          s           2000    varying

     D ddoptsget       pr                  extpgm('DDOPTSGET')
     D  pCallNum                      1p 0
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pJSON                      2000    varying

      /free

         pSessId = '123456';
         pUser   = 'TEST';
         pPgm    = 'TSTDDOPTSG';
         pJSON   = '';

         pCallNum = 1;
         ddoptsget(pCallNum:
                   pSessId:
                   pUser:
                   pPgm:
                   pJSON);

         pCallNum = 2;
         ddoptsget(pCallNum:
                   pSessId:
                   pUser:
                   pPgm:
                   pJSON);

         pCallNum = 3;
         ddoptsget(pCallNum:
                   pSessId:
                   pUser:
                   pPgm:
                   pJSON);

       return;
      /end-free
