      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETPGMINFO   Get program info
     *  11 April 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650  *    04/11/13  DAS  6.50
     *      - Created.
     *
650a *    10/29/13  DAS  6.50a
     *      - Added database source code
     *
650b *    12/18/13  DAS  6.50b
     *      - Enhanced to get actual program to call for links
     *
650c *    12/19/13  DAS  6.50c
     *      - Enhanced to get database source used in
     *        mrc-spring-context.xml file.
     *
650d *    01/15/14  DAS  6.50d
     *      - Revised to change an underscore in the program id
     *        to a period. This is necessary because sometimes MRC
     *        will strip out the dictionary portion of the id.
     *
650e *    02/03/14  DAS  6.50e
     *      - Revised session job info to be returned in sess variables.
     *      - Added returning program job info
     *
650f *    02/04/14  DAS  6.50f
     *      - Added call to WRTSESSLOG
     *
650g *    06/22/14  DAS  6.50g
     *      - Prototype was using FGETPGMINF instead of GETPGMINFO
     *
730a *    04/05/19  DAS  7.30
     *      - Added TBType and TBCol
     *
750a *    02/12/21  DAS  7.50a
     *      - Added dktver
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
USFaA*    03/21/16  DAS  USFa
     *      - Revised to set refresh time to zero, to disable auto refresh
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
gRCaA*    02/07/19  MLB  GRCa
     *      - Revised to set refresh time to zero, to disable auto refresh
     *      - Added GRCa to USFa mod.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

USFaA /copy qcopysrc,id#usfcrp
GRCaA /copy qcopysrc,id#grc

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

     D whse            s              3p 0
     D whseName        s             30
     D user            s             10
     D empNbr          s              5p 0
     D empName         s             40
     D language        s              2
     D client          s             10
     D clientLoc       s             10
650a D dbSrcId         s             10
650c D dbSrcCtxId      s             30
     D touch           s              1
     D menu            s             20
     D job             s             10
     D jobNbr          s              6
     D jobUser         s             10
     D jobCurrUser     s             10
650eAD sessjob         s             10
650eAD sessjobNbr      s              6
650eAD sessjobUser     s             10
650eAD sessjobCurrUsr  s             10
     D iSize1          s              3p 0
     D iSize2          s              3p 0
     D refresh         s              7p 0
730aAD tbType          s              1
730aAD tbcol           s              1
750aAD dktver          s              5

     D addFlag         s              1p 0
     D chgFlag         s              1p 0
     D dltFlag         s              1p 0
     D viewFlag        s              1p 0

     D chrSessId       s             40
     D chrUser         s             10
     D chrPgmId        s             20
650bAD pgm             s             20

730aAD $gfFeature      s              1
730aAD $gfLight        s              1
730aAD $gfTBType       s              1
730aAD $gfTBCol        s              1
730aAD $gfWhse         s              3p 0

730aA*----------------------------------------------------------------
730aA* Called program prototypes.
730aA*----------------------------------------------------------------
730aA
730aA /copy qcopysrc,p.getfeat

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

     *----------------------------------------------------------------
     * JSON string
     *
     *  Variables (flags: 1=Authorized, 0=Not authorized)
     *
     *    "client"  - PIRCLIENT value
     *    "loc"     - PIRCLIENT2 value
     *    "whs"     - Session warehouse
     *    "wnm"     - Warehouse name
     *    "enbr"    - Employee number
     *    "enam"    - Employee name
     *    "lng"     - Language
     *    "tch"     - Touch screen
     *    "mnu"     - Main menu
     *    "job"     - Job name
     *    "jnbr"    - Job number
     *    "jusr"    - Job user
     *    "jcur"    - Job Current user
650eA*    "sessjob" - Job name
650eA*    "sessjnbr" - Job number
650eA*    "sessjusr" - Job user
650eA*    "sessjcur" - Job Current user
     *    "view"    - View flag
     *    "add"     - Add flag
     *    "chg"     - Change flag
     *    "dlt"     - Delete flag
     *    "isize1"  - Icon size for add/chg/del
     *    "isize2"  - Icon size for link icons
     *    "refresh" - Refresh delay in milliseconds
650a *    "dsid"    - Database source id
650c *    "dsctx"   - Database spring-context id
     *    "alwlnk1" - Link 1 authorization flag
650bA*    "lnk1"    - Program to call for Link 1
     *    "alwlnk2" - Link 2 authorization flag
650bA*    "lnk2"    - Program to call for Link 2
     *    "alwlnk3" - Link 3 authorization flag
650bA*    "lnk3"    - Program to call for Link 3
     *    "alwlnk4" - Link 4 authorization flag
650bA*    "lnk4"    - Program to call for Link 4
     *    "alwlnk5" - Link 5 authorization flag
650bA*    "lnk5"    - Program to call for Link 5
730aA*    "tbtype"  - TruckBuilder type (S=Standard, E=Enhanced/Advanced, B=Both)
730aA*    "tbcol"   - TruckBuilder columns (N=Std 2 Col, Y=Allow 3+ col)
750aA*    "dktver"  - Dakota version from VERSION data area
     *
     *----------------------------------------------------------------

650gDD*fgetpgminf      pr                  extpgm('FGETPGMINF')
650gMD getpgminfo      pr                  extpgm('GETPGMINFO')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgmId                       20    varying
     D  pLinkId1                     20    varying
     D  pLinkId2                     20    varying
     D  pLinkId3                     20    varying
     D  pLinkId4                     20    varying
     D  pLinkId5                     20    varying
     D  pOutStr                    1024    varying

650gDD*fgetpgminf      pi
650gMD getpgminfo      pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgmId                       20    varying
     D  pLinkId1                     20    varying
     D  pLinkId2                     20    varying
     D  pLinkId3                     20    varying
     D  pLinkId4                     20    varying
     D  pLinkId5                     20    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650fA /copy qcopysrc,p.wrtsessl

     D authmenu        pr                  extpgm('AUTHMENU')
     D  pMenuId                      20    const
     D  pUser                        10    const
     D  pViewFLag                     1p 0
     D  pAddFlag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0
650bAD  pPgm                         20

     D getsessinf      pr                  extpgm('GETSESSINF')
     D  pSessId                      40
     D  pWhse                         3p 0
     D  pWhseName                    30
     D  pUser                        10
     D  pEmpNbr                       5p 0
     D  pEmpName                     40
     D  pLanguage                     2
     D  pClient                      10
     D  pClientLoc                   10
     D  pTouch                        1
     D  pMenu                        20
     D  pJob                         10
     D  pJobNbr                       6
     D  pJobUser                     10
     D  pJobCurrUser                 10
     D  pISize1                       3p 0
     D  pISize2                       3p 0
650aDD  pDbSrcId                     10
650cDD  pDbSrcCtxId                  30

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

750aAC     *DTAARA       define    version       vernum            4 2
750aAC                   in(e)     vernum
750aAC                   if        %error
750aAC                   eval      dktver = 'Unknown'
750aAC                   else
750aAC                   eval      dktver = %char(vernum)
750aAC                   endif

      /free
         //*inlr = *on;

         pOutStr = '';

         // Convert parms into fixed length variables
         chrSessId = %trim(pSessId);
         chrUser   = %trim(pUser);
650fA    chrPgmId  = %trim(pPgmId);

650fA    // Write GLOSESSLOG record
650fA    //wrtsesslog(chrSessId: #pgm: chrPgmId: chrUser);

         // Hardcode refresh delay (in seconds)
         // Zero means no refresh.
         refresh = 10;

         // Get session information
         getsessinf(chrSessId :
                    whse :
                    whseName :
                    user :
                    empNbr :
                    empName :
                    language :
                    client :
                    clientLoc:
                    touch :
                    menu :
650eM               sessjob :
650eM               sessjobNbr :
650eM               sessjobUser :
650eM               sessjobCurrUsr :
                    iSize1 :
650aM               iSize2 :
650aA               dbSrcId:
650cA               dbSrcCtxId);

USFaA    // Disable refresh for USF
USFaA
USFaA    if client = usfcrp
GRCaA    or client = Greco;
USFaA      refresh = 0;
USFaA    endif;

         // Get program authorizations
         chrPgmId  = %trim(pPgmId);
650cA    chrPgmId = %xlate('_': '.': chrPgmId);
         exsr GetAuth;

730aA    // Get TruckBuilder info
730aA    exsr GetTBInfo;

750aA    // Get Dakota version
750aA    exsr GetTBInfo;

         // Create JSON string to return
         pOutStr = '{'
                +  '"cli":"'  + %trimr(client) + '",'
                +  '"loc":"'  + %trimr(clientloc) + '",'
                +  '"whs":'   + %char(whse) + ','
                +  '"wnm":"'  + %trimr(whseName) + '",'
                +  '"enbr":'  + %char(empNbr) + ','
                +  '"enam":"' + %trimr(empName) + '",'
                +  '"lng":"'  + %trimr(language) + '",'
                +  '"tch":"'  + %trimr(touch) + '",'
                +  '"mnu":"'  + %trimr(menu) + '",'
                +  '"job":"'  + %trimr(#job) + '",'
                +  '"jnbr":"' + %trimr(#jobnbr) + '",'
                +  '"jusr":"' + %trimr(#user) + '",'
                +  '"jcur":"' + %trimr(#curruser) + '",'
650eA           +  '"sessjob":"'  + %trimr(sessjob) + '",'
650eA           +  '"sessjnbr":"' + %trimr(sessjobNbr) + '",'
650eA           +  '"sessjusr":"' + %trimr(sessjobUser) + '",'
650eA           +  '"sessjcur":"' + %trimr(sessjobCurrUsr) + '",'
                +  '"view":'  + %char(viewFlag) + ','
                +  '"add":'  + %char(addFlag) + ','
                +  '"chg":'  + %char(chgFlag) + ','
                +  '"dlt":'  + %char(dltFlag) + ','
                +  '"isize1":'  + %char(iSize1) + ','
                +  '"isize2":'  + %char(iSize2) + ','
650aM           +  '"refresh":'  + %char(refresh) + ','
650aA           +  '"dsid":"'  + %trimr(dbSrcId) + '",'
730aA           +  '"tbtype":"'  + $gfTBType + '",'
730aA           +  '"tbcol":"'  + $gfTBCol + '",'
750aA           +  '"dktver":"'  + %trimr(dktver) + '",'
650cA           +  '"dsctx":"'  + %trimr(dbSrcCtxId) + '"';


         // Add link authorizations only if sent
         if pLinkId1 <> '';
           chrPgmId  = %trim(pLinkId1);
           exsr GetAuth;
650bM      pOutStr += ',"alwlnk1":'  + %char(viewFlag)
650bA              + ',"lnk1":"'  + %trimr(pgm) + '"';
         endif;
         if pLinkId2 <> '';
           chrPgmId  = %trim(pLinkId2);
           exsr GetAuth;
650bM      pOutStr += ',"alwlnk2":'  + %char(viewFlag)
650bA              + ',"lnk2":"'  + %trimr(pgm) + '"';
         endif;
         if pLinkId3 <> '';
           chrPgmId  = %trim(pLinkId3);
           exsr GetAuth;
650bM      pOutStr += ',"alwlnk3":'  + %char(viewFlag)
650bA              + ',"lnk3":"'  + %trimr(pgm) + '"';
         endif;
         if pLinkId4 <> '';
           chrPgmId  = %trim(pLinkId4);
           exsr GetAuth;
650bM      pOutStr += ',"alwlnk4":'  + %char(viewFlag)
650bA              + ',"lnk4":"'  + %trimr(pgm) + '"';
         endif;
         if pLinkId5 <> '';
           chrPgmId  = %trim(pLinkId5);
           exsr GetAuth;
650bM      pOutStr += ',"alwlnk5":'  + %char(viewFlag)
650bA              + ',"lnk5":"'  + %trimr(pgm) + '"';
         endif;

         // Close off the JSON string
         pOutStr += '}';

        return;

      /end-free

     *----------------------------------------------------------------
     *  GetAuth   Get program authorization
     *----------------------------------------------------------------

      /free
       begsr GetAuth;

         viewFlag = 0;
         addFlag = 0;
         chgFlag = 0;
         dltFlag = 0;
650bA    pgm = ' ';

         if chrPgmId = ' ';
           leavesr;
         endif;

         authmenu(chrPgmId :
                  chrUser :
                  viewFlag :
                  addFlag :
                  chgFlag :
650bM             dltFlag :
650bA             pgm);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetTBInfo      Get TruckBuilder info
     *----------------------------------------------------------------

      /free
       begsr GetTBInfo;

         // Get Truck Builder Process Feature
         //   tbType: S=Standard, E=Advanced/Enhanced, B=Both
         //   tbCol: N=Std 2 Col, Y=Allow 3+ Col

         monitor;
           $gfWhse = whse;
           GetFeat ('*GET': $gfwhse: $gfFeature: $gfLight: $gfTBType: $gfTBCol);
         on-error;
           $gfTBType = 'S';
           $gfTBCol  = 'N';
         endmon;

       endsr;
      /end-free

