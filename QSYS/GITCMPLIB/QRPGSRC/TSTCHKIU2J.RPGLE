      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTCHKIU2J   Test CHKINUSE2
     *  02 May 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3p 0
     D pCmd            s              8    varying
     D pOutStr         s            512    varying
     D pSessId         s             40    varying
     D pUser           s             10    varying
     D pRtid           s              5    varying
     D pDict           s             10    varying
     D pPgm            s             10    varying

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D chkiuse2j       pr                  extpgm('CHKIUSE2J')
     D  pCmd                          8    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pOutStr                     512    varying

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         pCmd = '*INUSE24';
         pWhse = 900;
         pRtid = '00016';
         pSessId  = 'ZZZZZZZ7D71BE1C174A5027F10A0739A';
         pUser = 'dave';
         pDict = 'BFCDAKOTA';
         pPgm  = 'TEST';
         pOutStr = '';

         chkiuse2j(pCmd:
                   pWhse:
                   pRtid:
                   pSessId:
                   pUser:
                   pDict:
                   pPgm:
                   pOutStr);

         if %error();
           pWhse=pWhse;
         endif;

         return;
      /end-free
