      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  REDIRECT     Get redirect program
     *  24 March 2013
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    03/24/13  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds
     D glomenuitm    E ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

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

     D  pSessId        s             40    varying
     D  pUser          s             10    varying
610aAD  pDict          s             20    varying
610aAD  pPgmId         s             20    varying
610aAD  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D authView        s              1p 0
     D authAdd         s              1p 0
     D authChg         s              1p 0
     D authDlt         s              1p 0
     D user            s             10

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D AUTHMENU        pr                  extpgm('AUTHMENU')
     D  pMenuItemId                  20
     D  pUser                        10
     D  pViewFlag                     1p 0
     D  pAddflag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d FmtPgm          pr           512    varying

     d GetMenuItm      pr            10i 0
640aMD  dict                         20    varying const
610cMD  id                           20    varying const

640aAd GetSessInfo     pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser        User code (upper case)
     *      pDict        Dictionary
     *      pPgmId       Program Id
     *
     *    Returned Parameters
     *      pOutStr      Redirect string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgmId
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get glomenuitm record

640aA   if GetMenuItm(pDict:pPgmId) < 0;
          pOutStr = 'BFCGLOBAL.I00002s';
640aA     return;
640aA   endif;

        // User must have View authority
650a    // We use the GMIID for checking authority, not GMIPGM.

        user = pUser;
        AuthMenu(gmiid: user: authView: authAdd: authChg: authDlt);

        if authView <> 1;
          pOutStr = 'BFCGLOBAL.I00003s';
640aA     return;
        endif;

        // Format return string

        select;
          when gmitype = 'P';
650aA       pOutStr = FmtPgm();
          when gmitype = 'U';
            pOutStr = gmilink;
          other;
            pOutStr = %trimr(pDict) + '.' + %trimr(pPgmId);
        endsl;

        return;

      /end-free

     *----------------------------------------------------------------
     *  FmtPgm      Format program link string
     *----------------------------------------------------------------

     p FmtPgm          b
     d FmtPgm          pi           512    varying

     *  Local Variables

640aMD tmpLink         s            512    varying
     D id              s             20
640aAD sepChar         s              1
640aAD sessId          s             40

      /free

650aA    if gmipgm <> '';
           id = gmipgm;
         else;
           id = gmiid;
         endif;

         if gmilink = ' '
640eM     or %subst(gmilink:1:1) = '?';
640dA      tmpLink = %trim(id) + 's';
         else;
           tmpLink = gmilink;
         endif;

640eM    if %subst(gmilink:1:1) = '?';
640aA      tmpLink = %trimr(tmpLink) + %trimr(gmilink);
640eM    endif;

640aA    // Add optional parameters
640aA
640aA    if %scan('?':tmpLink) = 0;
640aA      sepChar = '?';
640aA    else;
640aA      sepChar = '&';
640aA    endif;
640aA
640aA    if gmiwfld <> ' ';
640aA      GetSessInfo();
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmiwfld) + '=' + %char(gswhse);
640aA      sepChar = '&';
640aA    endif;

640aA    // Get session information before menu parameter check
640aA    // Get out if not found
640aA
640aA
640aA    if gmiufld <> ' ';
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmiufld) + '=' + %trim(pUser);
640aA      sepChar = '&';
640aA    endif;
640aA
640aA    if gmisfld <> ' ';
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmisfld) + '=' + %trim(pSessId);
640aA      sepChar = '&';
640aA    endif;

         return tmpLink;

      /end-free

     p FmtPgm          e

640aA*----------------------------------------------------------------
640aA*  GetMenuItm  Get GLOMENUITM record
640aA*----------------------------------------------------------------
640aA
640aAp GetMenuItm      b
     d GetMenuItm      pi            10i 0
640aMD  dict                         20a   varying const
610cMD  id                           20a   varying const

     *  Local Variables

     D menuItemId      s             40    static

      /free

        menuItemId = %trim(pDict) + '.' + %trim(pPgmId);

        exec sql select gmiid,gmipgm,gmilink,gmitype,
                        gmiwfld,gmiufld,gmisfld
                 into   :gmiid,:gmipgm,:gmilink,:gmitype,
                        :gmiwfld,:gmiufld,:gmisfld
                 from glomenuitm
                 where gmiid = :menuItemId;

         If sqlstt <> sqlSuccess;
           return -1;
         endif;

         return 0;

      /end-free

     p GetMenuItm      e

640aA*----------------------------------------------------------------
640aA*  GetSessInfo  Get session info
640aA*----------------------------------------------------------------
640aA
640aAp GetSessInfo     b
     d GetSessInfo     pi

     *  Local Variables

     D sessId          s             40    static

      /free

        sessId = pSessId;

        exec sql select gswhse
                 into  :gswhse
                 from glosess
                 where gssessid = :sessId;

         If sqlstt <> sqlSuccess;
           gswhse = 0;
         endif;

      /end-free

     p GetSessInfo     e
