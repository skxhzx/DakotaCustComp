      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  DLTGLOMNU   Delete global menu detail
     *  12 October 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    10/12/13  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglomenu   uf   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMenu        Menu
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg          99
     C                   parm                    pMenu            20

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // Copy GLOMENU

         setll (pMenu) glomenu;

         dow forever = forever;

           reade (pMenu) glomenu;

           if %eof(glomenu);
             leave;
           endif;

           delete(e) gmrec;
           if %error();
           endif;

         enddo;

         return;
      /end-free
