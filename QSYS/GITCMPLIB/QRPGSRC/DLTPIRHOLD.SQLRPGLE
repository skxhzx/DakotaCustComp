      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  DLTPIRHOLD   Delete PIRHOLD records by type
     *  20 January 2016
     *  Lynn Mcmahon
     *
     *  Revisions
     *
700  *    01/20/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D pirhold       E ds

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
     D  ptype          s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pType       Type
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    ptype

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        exec sql delete from pirhold
                 where hosess = :pSessId
                   and hotype = :ptype;

        If sqlstt <> sqlSuccess;
        endif;

        return;
