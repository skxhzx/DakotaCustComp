      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTPHRASE   Test BFCPHRASE
     *  14 July 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

600bA /copy qcopysrc,p.bfcphras

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

600bAD  pPhraseId      s              5p 0
600bAD  pWhse          s              3s 0
600bAD  pEmp#          s              5s 0
600bAD  pUser          s             10
600bAD  pPgm           s             10
600bAD  pItem          s             15
600bAD  pWhdp          s              5
600bAD  pLocation      s             15
600bAD  pTrn#          s              7p 0
600bAD  pLcns          s             15
600bAD  pLtrn          s              7p 0
600bAD  v1             s             30
600bAD  v2             s             30
600bAD  v3             s             30
600bAD  v4             s             30
600bAD  v5             s             30

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         pPhraseId = 99999;
         pWhse = 900;
         pEmp# = 10;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = 'DA999';
         pWhdp = 'DRY';
         pLocation = 'DA-999-1';
         pTrn# = 1234567;
         pLcns = 'LIC999';
         pLtrn = 0;
         v1 = 'wrtPhrase';

         callp(e) wrtPhrase(pPhraseId:
                         pWhse:
                         pEmp#:
                         pUser:
                         pPgm:
                         pItem:
                         pWhdp:
                         pLocation:
                         pTrn#:
                         pLcns:
                         pLtrn:
                         v1:
                         v2:
                         v3:
                         v4:
                         v5
               );

         if %error;
           eval v1=v1;
         endif;

         *inlr = *on;
         return;

      /end-free
