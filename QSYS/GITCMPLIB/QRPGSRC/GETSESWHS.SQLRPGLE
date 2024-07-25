      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETSESWHS    Get session warehouse
     *  14 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    05/14/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D chrSessId       s             40

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *
     *    Returned Parameters
     *      pWhse       Session warehouse
     *
     *----------------------------------------------------------------

     D getseswhs       pr                  extpgm('GETSESWHS')
     D  pSessId                      40    varying
     D  pWhse                         3p 0

     D getseswhs       pi
     D  pSessId                      40    varying
     D  pWhse                         3p 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        chrSessId = pSessId;

        exec sql select gswhse into :pWhse
                 from glosess
                 where gssessid = :chrSessId;

         If sqlstt <> sqlSuccess;
           pWhse = 0;
         endif;

        return;

      /end-free
