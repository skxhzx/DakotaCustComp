      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  DLTSESSINF   Delete session info
     *  21 April 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    04/21/10  DAS  6.10
     *      - Created.
     *
740a *    04/15/20  KDE  7.40
     *      - Delete all session records upper or mixed case with same value
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
     *  Parameters
     *----------------------------------------------------------------

     D  pSessId        s             40
     D  pUser          s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser        User
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        exec sql delete from glosess
740aD            //where gssessid = :pSessId;
740aM            where upper(gssessid) = upper(:pSessId);

        If sqlstt <> sqlSuccess;
        endif;

        return;
