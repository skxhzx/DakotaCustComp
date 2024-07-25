      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETPGM    Get single program link
     *  14 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/14/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D addFlag         s              1p 0
     D chgFlag         s              1p 0
     D dltFlag         s              1p 0
     D viewFlag        s              1p 0

     D chrSessId       s             40
     D chrUser         s             10
     D chrPgmId        s             20
     D prdPgmId        s             20
     D pgm             s             20
     D propStr         s             50

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgmId      Program Id
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     D getpgm          pr                  extpgm('GETPGM')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgmId                       20    varying
     D  pOutStr                      20    varying

     D getpgm          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgmId                       20    varying
     D  pOutStr                      20    varying

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D authmenu        pr                  extpgm('AUTHMENU')
     D  pMenuId                      20    const
     D  pUser                        10    const
     D  pViewFLag                     1p 0
     D  pAddFlag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0
     D  pPgm                         20

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         // Default to menu program

         pOutStr = 'BFCSIGNON.M00020';

         // Convert parms into fixed length variables

         chrSessId = %trim(pSessId);
         chrUser   = %trim(pUser);
         chrPgmId  = %trim(pPgmId);

         if chrPgmId = ' ';
           return;
         endif;

         // Get program

         viewFlag = 0;
         addFlag = 0;
         chgFlag = 0;
         dltFlag = 0;
         pgm = ' ';

         prdPgmId = %xlate('_': '.': chrPgmId);

         authmenu(prdPgmId :
                  chrUser :
                  viewFlag :
                  addFlag :
                  chgFlag :
                  dltFlag :
                  pgm);

           if viewflag = 0;
             // Use default defined above.
           else;
             pOutStr = %trimr(pgm);
           endif;

        return;

      /end-free
