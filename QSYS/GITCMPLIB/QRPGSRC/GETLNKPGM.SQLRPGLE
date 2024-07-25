      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETLNKPGM    Get link programs
     *  15 January 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    01/15/14  DAS  6.50
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
650bAD pgm             s             20
     D propStr         s             50

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pLinkId*    Link id's to get program to call.
     *                  Links id's will come in with an underscore
     *                  instead of a period because MRC is incorrectly
     *                  removing everything before a period and including
     *                  the period when generating the SQL statement.
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * JSON string
     *
     *  Property name: pLinkId with period changed to underscore.
     *  Property value: Program to call or "NA" if not authorized.
     *
     *  Example JSON string:
     *
     *   {"BFCDAKOTA_M01500":"BFCDAKOTA.M01501","BFCDAKOTA_M02000":"NA"}
     *
     *----------------------------------------------------------------

     D getlnkpgm       pr                  extpgm('GETLNKPGM')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pLinkId1                     20    varying
     D  pLinkId2                     20    varying
     D  pLinkId3                     20    varying
     D  pLinkId4                     20    varying
     D  pLinkId5                     20    varying
     D  pLinkId6                     20    varying
     D  pLinkId7                     20    varying
     D  pLinkId8                     20    varying
     D  pLinkId9                     20    varying
     D  pLinkId10                    20    varying
     D  pOutStr                    1024    varying

     D getlnkpgm       pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pLinkId1                     20    varying
     D  pLinkId2                     20    varying
     D  pLinkId3                     20    varying
     D  pLinkId4                     20    varying
     D  pLinkId5                     20    varying
     D  pLinkId6                     20    varying
     D  pLinkId7                     20    varying
     D  pLinkId8                     20    varying
     D  pLinkId9                     20    varying
     D  pLinkId10                    20    varying
     D  pOutStr                    1024    varying

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
         //*inlr = *on;

         pOutStr = '';

         // Convert parms into fixed length variables

         chrSessId = %trim(pSessId);
         chrUser   = %trim(pUser);

         // Create JSON string

         chrPgmId  = %trim(pLinkId1);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId2);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId3);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId4);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId5);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId6);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId7);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId8);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId9);
         exsr GetPgm;

         chrPgmId  = %trim(pLinkId10);
         exsr GetPgm;

         // Put braces around the JSON string

         pOutStr = '{' + %trimr(pOutStr) + '}';

        return;

      /end-free

     *----------------------------------------------------------------
     *  GetPgm    Get program to call
     *----------------------------------------------------------------

      /free
       begsr GetPgm;

         viewFlag = 0;
         addFlag = 0;
         chgFlag = 0;
         dltFlag = 0;
650bA    pgm = ' ';

         if chrPgmId = ' ';
           leavesr;
         endif;

         prdPgmId = %xlate('_': '.': chrPgmId);

         authmenu(prdPgmId :
                  chrUser :
                  viewFlag :
                  addFlag :
                  chgFlag :
650bM             dltFlag :
650bA             pgm);

650bM      if viewflag = 0;
650bM        propStr = '"' + %trimr(chrPgmId) + '":"NA"';
650bM      else;
650bM        propStr = '"' + %trimr(chrPgmId) + '":"' + %trimr(pgm) + '"';
           endif;

650bM      if pOutStr = '';
650bM        pOutStr = propStr;
650bM      else;
650bM        pOutStr = %trimr(pOutStr) + ',' + propStr;
650bM      endif;

       endsr;
      /end-free
