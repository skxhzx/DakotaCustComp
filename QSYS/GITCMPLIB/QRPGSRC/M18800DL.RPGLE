      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M18800DL    Handles delete for Trailer detail files
     *  11 June 2015
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/11/15  LMC  7.00a
     *      - Created.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Ftrailerax uf   e           k disk
     Ftrailerdr uf   e           k disk

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDPCombo    Dictionary/Program combo
     *      pWhse       Warehouse
     *      pTrl        trailer
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg          99
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pDPCombo         20
     C                   parm                    pWhse             3 0
     C                   parm                    pTrl              8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // If from trailer is blank, assume normal Add and get out

         if pTrl = '';
           return;
         endif;


         // Delete trailer detail files TRAILERAX & TRAILERDR
         // Trailer header will be deleted by MRC

         setll (pwhse:ptrl) trailerax;
         dow not %eof(trailerax);
           reade (pwhse:ptrl) trailerax;
           if %eof(trailerax);
             leave;
           endif;
           delete tlarec;
         enddo;

         setll (pwhse:ptrl) trailerdr;
         dow not %eof(trailerdr);
           reade (pwhse:ptrl) trailerdr;
           if %eof(trailerdr);
             leave;
           endif;
           delete tldrec;
         enddo;

         return;
      /end-free
