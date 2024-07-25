      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CPYGLOMNU   Copy global menu detail
     *  12 October 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    10/12/13  DAS  6.50
     *      - Created.
     *
650aA*    12/17/14  DAS  6.50a
     *      - Revised to convert menus to uppercase
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglomenu   uf a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

650aA*----------------------------------------------------------------
650aA*  Translation strings
650aA*----------------------------------------------------------------
650aA
650aAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
650aAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pFromMenu    From menu
     *      pNewMenu     New menu
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg          99
     C                   parm                    pFromMenu        20
     C                   parm                    pNewMenu         20

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

650aA    // Convert menu names to uppercase
650aA
650aA    pFromMenu = %xlate(xlower: xupper: pFromMenu);
650aA    pNewMenu = %xlate(xlower: xupper: pNewMenu);

         // Menus cannot be the same

         if pFromMenu = pNewMenu;
           pErrMsg = 'From/New menus cannot be the same';
           return;
         endif;

         // Copy GLOMENU

         setll (pFromMenu) glomenu;

         dow forever = forever;

           reade(n) (pFromMenu) glomenu;

           if %eof(glomenu);
             leave;
           endif;

           gmname = pNewMenu;
           write(e) gmrec;
           if %error();
           endif;

         enddo;

         return;
      /end-free
