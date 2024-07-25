      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTPHRASE2  Test BFCPHRASE
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
600bAD  pPhrase        s            100
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
600bAD  pVars          s            100

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
         pTrn# = 12345;
         pLcns = 'LIC999';
         pLtrn = 0;
         pVars = '07updputp08*CLSPUTP';
         pPhrase = '<P>'
                 +   '<T>Var1: </T>'
                 +   '<V1/>'
                 +   '<T> Var2: </T>'
                 +   '<V2/>'
                 +   '<T> Pgm: </T>'
                 +   '<PGM/>'
                 + '</P>';

         pPhrase = fmtPhrase(pPhraseId:
                         pPhrase:
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
                         pVars
               );

         pPhrase = '<P>'
                 +   '<T>ID: </T>'
                 +   '<ID/>'
                 +   '<T> Emp#: </T>'
                 +   '<EMP/>'
                 +   '<T> Item: </T>'
                 +   '<ITEM/>'
                 +   '<T> Loc: </T>'
                 +   '<LOC/>'
                 + '</P>';

         pPhrase = fmtPhrase(pPhraseId:
                         pPhrase:
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
                         pVars
               );

         pPhrase = '<P>'
                 +   '<T> Trn#: </T>'
                 +   '<TRN/>'
                 +   '<T> Whse: </T>'
                 +   '<WHSE/>'
                 +   '<T> Lcns: </T>'
                 +   '<LCNS/>'
                 +   '<T> Ltrn: </T>'
                 +   '<LTRN/>'
                 +   '<XYZ/>'
                 + '</P>';

         pPhrase = fmtPhrase(pPhraseId:
                         pPhrase:
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
                         pVars
               );


         pPhrase = '<P>'
                 +   '<T>Screen </T>'
                 +   '<PGM/>'
                 +   '<T>-</T>'
                 +   '<V1/>'
                 +   '<T> displayed for </T>'
                 +   '<USER/>'
                 +   '<T>-</T>'
                 +   '<EMP/>'
                 + '</P>';
         pVars = '03SC2';

         pPhrase = fmtPhrase(pPhraseId:
                         pPhrase:
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
                         pVars
               );

         *inlr = *on;
         return;

      /end-free
