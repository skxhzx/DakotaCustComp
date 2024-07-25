      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M18800C     Handles copy for Trailer detail files
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
     Ftrailerax if a e           k disk
     Ftrailerdr if a e           k disk

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
     *      pFromTrl    From trailer
     *      pNewTrl     New trailer
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
     C                   parm                    pFromTrl          8
     C                   parm                    pNewTrl           8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // If from trailer is blank, assume normal Add and get out

         if pFromTrl = '';
           return;
         endif;

         // Trailers cannot be the same

         if pFromTrl = pNewTrl;
           pErrMsg = 'From/New trailers cannot be the same';
           return;
         endif;

         // Copy trailer detail files TRAILERAX & TRAILERDR
         // Trailer header will be copied by MRC

         setll (pwhse:pfromtrl) trailerax;
         dow not %eof(trailerax);
           reade (pwhse:pfromtrl) trailerax;
           if %eof(trailerax);
             leave;
           endif;
           tlacode = pnewtrl;
           write tlarec;
         enddo;

         setll (pwhse:pfromtrl) trailerdr;
         dow not %eof(trailerdr);
           reade (pwhse:pfromtrl) trailerdr;
           if %eof(trailerdr);
             leave;
           endif;
           tldcode = pnewtrl;
           write tldrec;
         enddo;

         return;
      /end-free
