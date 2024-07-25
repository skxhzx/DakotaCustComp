      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTUSFDLTR    Test USFDLTRTE
     *  07 February 2016
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    02/07/16  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     D  pBranch        s              2
     D  pRte           s              5
     D  pReturn        s             10
     D  pMessage       s            100    varying

     D usfdltrte       pr                  extpgm('USFDLTRTE')
     D  pBranch                       2
     D  pRte                          5
     D  pReturn                      10
     D  pMessage                    100    varying

     C     *entry        plist
     C                   parm                    pBranch
     C                   parm                    pRte

      /free

         usfdltrte(pBranch:
                   pRte:
                   pReturn:
                   pMessage);

       return;
      /end-free
