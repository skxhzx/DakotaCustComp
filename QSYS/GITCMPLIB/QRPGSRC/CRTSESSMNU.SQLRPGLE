      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H*BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     * Must compile with RPGPPOPT(*LVL1) RPG Preprocessor Options
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  CRTSESSMNU  Create session menu IFS file
     *  17 May 2010
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    05/17/10  DAS  6.10
     *      - Created.
     *
610aA*    06/21/10  DAS  6.10a
     *      - Revised WrtStr to not split line that was sent in.
     *
610bA*    07/04/10  DAS  6.10b
     *      - Added authorization check
     *
610cA*    07/14/10  DAS  6.10c
     *      - Revised icon logic.
     *
610dA*    08/28/10  DAS  6.10d
     *      - Revised to use internal jQuery menu.
     *      - Kept nodeFire logic.
     *
640aA*    06/28/11  DAS  6.40a
     *      - Added field GMIWFLD, Warehouse Field Name.
     *      - Added field GMIUFLD, User Field Name.
     *      - Added field GMISFLD, Session Field Name.
     *      - Revised to add above information to URL if provided.
     *      - Removed GetSessMenu.
     *      - Added GetSessInfo.
     *      - Revised to get out if session id not passed in.
     *
640bA*    08/20/11  DAS  6.40b
     *      - Revised FmtPgm to change '&' into '%26' in the tmplink
     *        field. Re: The MRC PDF converter didn't like the '&'.
     *
640cA*    11/04/11  DAS  6.40c
     *      - Reversed 6.40b because the link will only work with
     *        a '&' character. Also, pdf's will now use their own
     *        page that will not include the menu.
     *
640dA*    11/04/11  DAS  6.40d
     *      - Revised fmtPgm to not add 'mrcjava/servlet/' to the
     *        link. This allows for the Tomcat context to use a
     *        different url like /BFCDakota/servlet ...
     *
640eA*    08/16/12  DAS  6.40e
     *      - Revised to add link as a parameter if it starts with '?'
     *
640eA*    09/21/12  DAS  6.40f
     *      - Revised to use description if Item Text is blank.
     *
650aA*    03/16/13  DAS  6.50a
     *      - Revised to use new field GMIPGM for the the program
     *        instead of GMIID.
     *
650bA*    06/01/13  DAS  6.50b
     *      - Revised FmtPgm to do extra checking on link. Received
     *        error when checking for '?' and link was null.
     *
700aA*    05/10/16  MR   7.00
     *      - Change class to force Global Admin submenu to show
     *        to the left.  Change dropdown class to menu class
     *        new css.
     *      - Above goes is used when file pOutputType is FILE2 (DAS)
     *      - Would only compile with RPGPPOPT(*LVL1). Otherwise,
     *        would throw error "*RNF7030 30 017300 The name or
     *        indicator SQL_00005 is not defined."
     *
740aA*    04/15/20  KDE  7.40a
     *      - Revised always look for uppercase session
     *
750aA*    01/20/20  DAS  7.50a
     *      - Added special logic whe *TREE sent as pMenu. This is
     *        used for desplaying all defined menus in a tree format.
     *        https://www.cssscript.com/tree-view-nested-list/
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *      - Use BFCIFSBND binding directory.
     *
     *      - Used code page logic to write the file as an
     *        ASCII file so that when downloaded to a PC it
     *        will be readable ... by wordpad or notepad.
     *        In essence, it will be written as ccsid 819
     *        rather than ccsid 37.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglomenu   if   e           k disk
     Fglomenuitmif   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h

     D*chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D* path                        640A   const
     D* authority                    10A   const

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gFD             s             10I 0
     D gFormatOutput   s               n
750aDD*gIndentLevel    s              1  0
750aMD gIndentLevel    s              3  0
     D gLanguage       s              2
     D gMenu           s             20a
     D gOutputType     s             10a
     D gSessId         s             40a
     D gTmpStr         s            200A   varying
700aAD gTopCount       s              2  0
     D gUser           s             10a
610dAD gNodeFire       s               n
610dAD gJQuery         s               n
750aAD gTree           s               n
750aAD gTreeText       s            100    varying

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

     d BldMenu         pr
     D  menu                         20a   const
750aAd BldTree         pr
     d CrtIfsFile      pr            10i 0
     d FmtEndMenu      pr
     d FmtEndSub       pr
     d FmtLineDivider  pr
     d FmtPgm          pr
     D  id                           20a   const
     D  target                        1a   const
640fDD**text                         20a   const
640fMD  text                         30a   const
640aMD  link                        500a   varying const
610cMD  icon                        500a   varying const
     d FmtTextDivider  pr
640fDD**text                         20a   const
640fMD  text                         30a   const
     d FmtStartMenu    pr
     d FmtStartSub     pr
640fDD**text                         20a   const
640fMD  text                         30a   const
640aMD  link                        500a   varying const
610cMD  icon                        500a   varying const
     d FmtUserDefined  pr
640aMD  link                        500a   varying const
610cMD  icon                        500a   varying const
640aAd GetSessInfo     pr            10i 0
     d WriteStr        pr
     D  inStr                       200A   varying const
     d WriteStr2File   pr
     D  inStr                       300A   varying
     d WriteStr2IFS    pr
     D  inStr                       300A   varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id
     *      pUser        User code
     *      pOutputType  IFS  - Write to IFS file.
     *                   FILE - Write to file GLOSESSMNU
     *      pMenu        Menu
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pOutputType      10
     C                   parm                    pMenu            20

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         gLanguage = 'EN';

610dA    // Define menu type
610dA
610dA    gNodeFire = *off;
610dA    gJQuery   = *on;
750aA    if %parms >= 4 and pMenu = '*TREE';
750aA      gJQuery = *off;
750aA      gTree = *on;
750aA    endif;

640aA    // Get out if session id not passed in.
640aA
640aA    if %parms < 1 or pSessId = ' ';
640aA      return;
640aA    endif;

640aA    // Get session information before menu parameter check
640aA    // Get out if not found
640aA
640aD    gSessId = pSessId;
640aA    if GetSessInfo() < 0;
640aA      return;
640aA    endif;

         // Initialize incoming parameters

         if %parms < 2 or pUser = ' ';
           gUser = #curruser;
         else;
           gUser = pUser;
         endif;

         if %parms < 3
           or (pOutputType <> 'IFS' and pOutputType <> 'FILE'
700aA          and pOutputType <> 'FILE2');
             gOutputType = 'FILE';
         else;
             gOutputType = pOutputType;
         endif;

         if %parms < 4 or pMenu = ' ';
           gMenu = gsmenu;
         else;
           gMenu = pMenu;
         endif;

         // Define if output should be formatted.
         //   Formatting will add indentation and crlf's

         gFormatOutput = *on;

         // Create/Open output file - Get out if error

         select;

           // Clear file
           when gOutputType = 'FILE'
700aA         or gOutputType = 'FILE2';
750aA           if pMenu = '*TREE';
750aA             exec sql delete from glosessmnu where gsmsess = :gMenu;
750aA           else;
740aD             //exec sql delete from glosessmnu where gsmsess = :gSessId;
740aM             exec sql delete from glosessmnu where upper(gsmsess) =
740aM                                                   upper(:gSessId);
750aA           endif;

           // Create IFS file (it will be cleared if it exists)
           when gOutputType = 'IFS';
             gFD = CrtIfsFile();
             if gFD < 0;
               return;
             endif;

           other;
             return;

         endsl;

         // Write out starting menu record.

         FmtStartMenu();

         // Build menu for user

750aA    if pMenu = '*TREE';
750aA      BldTree();
750aA    else;
           BldMenu(gMenu);
750aA    endif;

         // Write out ending menu record.

         FmtEndMenu();

         // Flush output buffer

         WriteStr('*FLUSH');

         // Close IFS file

         if gOutputType = 'IFS';
           callp close(gFD);
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  crtIfsFile   Create IFS file
     *----------------------------------------------------------------

     p CrtIfsFile      b
     d CrtIfsFile      pi            10i 0

     *  Local Variables

     D fd              s             10I 0
     D fileName        s            100

      /free

         // Open/Create file.

         fileName = '/m-power/mrcjava/bfc/menu/bfcmenu_'
                  + %trim(gSessId)
                  + '.html';

         //fd = open(%trimr(fileName):
         //          O_TRUNC+O_CREAT+O_WRONLY+
         //          O_CODEPAGE:
         //          S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
         //          819);

         if fd < 0;
           return fd;
         endif;

         // Close file and reopen it in text mode.

         callp close(fd);
         //fd = open(%trimr(fileName):
         //          O_WRONLY+O_TEXTDATA);

         if fd < 0;
           return fd;
         endif;

         return fd;
      /end-free

     p CrtIfsFile      e

     *----------------------------------------------------------------
     *  BldMenu   Build menu
     *----------------------------------------------------------------

     p BldMenu         b
     d BldMenu         pi
     D  menu                         20a   const

     *  Local Variables

     D currMenu        s                   like(gmname)
640fDD*menuText        s                   like(gmtext)
640fMD menuText        s                   like(gmidesc)
     D savSeq#         s                   like(gmseq#)
     D authView        s              1p 0
     D authAdd         s              1p 0
     D authChg         s              1p 0
     D authDlt         s              1p 0

      /free

         currMenu = menu;
         gIndentLevel += 1;

         // Read through glomenu file for sent menu

           setll (currMenu) glomenu;

         dow forever = forever;

           reade (currMenu) glomenu;

           if %eof(glomenu);
             leave;
           endif;

           // Get corresponding glomenuitm record

           chain (gmid) glomenuitm;

           if not %found;
             iter;
           endif;

           // User must have View authority
650a       // We use the GMIID for checking authority, not GMIPGM.

750aA      if not gTree;

             AuthMenu(gmiid: pUser: authView: authAdd: authChg: authDlt);

             if authView <> 1;
               iter;
             endif;

750aA      endif;

           // Determine which text to use.

           select;
             when gLanguage = 'SP';
               select;
                 when gmtextsp <> '';
                   menuText = gmtextsp;
                 when gmitextsp <> '';
                   menuText = gmitextsp;
                 when gmtext <> '';
                   menuText = gmtext;
                 when gmitext <> '';
                   menuText = gmitext;
640fA            when gmidesc <> '';
640fA              menuText = gmidesc;
650aA            when gmipgm <> '';
650aA              menuText = gmipgm;
                 other;
                     menuText = gmiid;
                 endsl;
             other;
               select;
                 when gmtext <> '';
                   menuText = gmtext;
                 when gmitext <> '';
                   menuText = gmitext;
640fA            when gmidesc <> '';
640fA              menuText = gmidesc;
650aA            when gmipgm <> '';
650aA              menuText = gmipgm;
                 other;
                   menuText = gmiid;
               endsl;
           endsl;

700aA      // Count Level 1 entries
700aA
700aA      if menu = gMenu;
700aA        gTopCount +=  1;
700aA        //menuText = %char(gTopCount) + %trim(menuText);
700aA      endif;

           // Call appropriate item type routine.

           select;

             when gmitype = 'P';
650aA          if gmipgm <> '';
650aA            FmtPgm(gmipgm:gmtarget:menuText:gmilink:gmiicon);
650aA          else;
                 FmtPgm(gmiid:gmtarget:menuText:gmilink:gmiicon);
650aA          endif;

             when gmitype = 'M';
               savSeq# = gmseq#;
750aA          gTreeText = %trimr(gmid) + ' - ' + %trimr(menuText);
               FmtStartSub(menuText:gmilink:gmiicon);
               BldMenu(gmid);
               FmtEndSub();
               setgt (currMenu: savSeq#) glomenu;

             when gmitype = 'D' and menuText <> '';
               FmtTextDivider(menuText);

             when gmitype = 'D' and menuText = '';
               FmtLineDivider();

             when gmitype = 'U';
               FmtUserDefined(gmilink:gmiicon);

           endsl;

         enddo;

         gIndentLevel -= 1;

      /end-free

     p BldMenu         e

     *----------------------------------------------------------------
     *  BldTree   Build menu tree
     *----------------------------------------------------------------

     p BldTree         b
     d BldTree         pi

     *  Local Variables

     D currMenu        s                   like(gmname)
     D menuText        s                   like(gmidesc)

      /free

         // Read through glomenu

         setll ('') glomenu;

         dow forever = forever;

           read glomenu;

           if %eof(glomenu);
             leave;
           endif;

          currMenu = gmname;

           // Get corresponding glomenuitm record

           chain (currMenu) glomenuitm;

           if not %found;
             iter;
           endif;

           // Determine which text to use.

           select;
             when gLanguage = 'SP';
               select;
                 when gmtextsp <> '';
                   menuText = gmtextsp;
                 when gmitextsp <> '';
                   menuText = gmitextsp;
                 when gmtext <> '';
                   menuText = gmtext;
                 when gmitext <> '';
                   menuText = gmitext;
640fA            when gmidesc <> '';
640fA              menuText = gmidesc;
650aA            when gmipgm <> '';
650aA              menuText = gmipgm;
                 other;
                     menuText = gmiid;
                 endsl;
             other;
               select;
                 when gmtext <> '';
                   menuText = gmtext;
                 when gmitext <> '';
                   menuText = gmitext;
640fA            when gmidesc <> '';
640fA              menuText = gmidesc;
650aA            when gmipgm <> '';
650aA              menuText = gmipgm;
                 other;
                   menuText = gmiid;
               endsl;
           endsl;

           gTreeText = %trimr(currMenu) + ' - ' + %trimr(menuText);

           // Call appropriate item type routine.

           select;

             when gmitype = 'M';
               FmtStartSub(menuText:gmilink:gmiicon);
               BldMenu(currMenu);
               FmtEndSub();
               setgt (currMenu) glomenu;

           endsl;

         enddo;

      /end-free

     p BldTree         e

     *----------------------------------------------------------------
     *  FmtEndMenu   Format end menu string
     *----------------------------------------------------------------

     p FmtEndMenu      b
     d FmtEndMenu      pi

      /free

         clear gTmpStr;
         gTmpStr = '</ul>';
         WriteStr(gTmpStr);

      /end-free

     p FmtEndMenu      e

     *----------------------------------------------------------------
     *  FmtEndSub   Format end sub menu string
     *----------------------------------------------------------------

     p FmtEndSub       b
     d FmtEndSub       pi

      /free

         clear gTmpStr;
         gTmpStr = '</ul>';
         WriteStr(gTmpStr);
         gIndentLevel -= 1;

         clear gTmpStr;
         gTmpStr = '</li>';
         WriteStr(gTmpStr);

      /end-free

     p FmtEndSub       e

     *----------------------------------------------------------------
     *  FmtLineDivider   Format line divider string
     *----------------------------------------------------------------

     p FmtLineDivider  b
     d fmtLineDivider  pi

      /free

750aA    if gTree;
750aA      return;
750aA    endif;

         clear gTmpStr;
         gTmpStr = '<li>'
                 + '<span class="qmdivider qmdividerx"></span>'
                 + '</li>';
         WriteStr(gTmpStr);

      /end-free

     p FmtLineDivider  e

     *----------------------------------------------------------------
     *  FmtPgm      Format program link string
     *----------------------------------------------------------------

     p FmtPgm          b
     d FmtPgm          pi
     D  id                           20a   const
     D  target                        1a   const
640fDD**text                         20a   const
640fMD  text                         30a   const
640aMD  link                        500a   varying const
610cMD  icon                        500a   varying const

     *  Local Variables

640aMD tmpLink         s            500A   varying
610dAD aClass          s             25A
610dAD liClass         s             25A
640aAD sepChar         s              1A
640bAD position        s              3  0

      /free

610dA    select;
610dA      when gNodeFire;
610dA        liClass = 'nfItem';
610dA        aClass  = 'nfLink';
610dA      when gJQuery;
610dA        liClass = 'cli';
610dA        aClass  = 'hLink';
610dA    endsl;

         if link = ' '
640eM     or %subst(link:1:1) = '?';
640dD      //tmpLink = '/mrcjava/servlet/'
640dD      //        + %trim(id) + 's';
640dA      tmpLink = %trim(id) + 's';
         else;
           tmpLink = link;
         endif;

650bD    //if %subst(link:1:1) = '?';
640eM    if link<>' ' and %subst(link:1:1) = '?';
640aA      tmpLink = %trimr(tmpLink) + %trimr(link);
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
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmiwfld) + '=' + %char(gswhse);
640aA      sepChar = '&';
640aA    endif;
640aA
640aA    if gmiufld <> ' ';
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmiufld) + '=' + gUser;
640aA      sepChar = '&';
640aA    endif;
640aA
640aA    if gmisfld <> ' ';
640aA      tmpLink = %trimr(tmpLink) + sepChar
640aA              + %trim(gmisfld) + '=' + gSessId;
640aA      sepChar = '&';
640aA    endif;

640cD    //position = %scan('&': tmplink);
640cD    //dow position > 0;
640cD    //  tmplink = %replace('%26': tmplink: position: 1);
640cD    //  position = %scan('&': tmplink: position);
640cD    //enddo;

         clear gTmpStr;

750aA    if gTree;
750aA      gTmpStr = '<li>';
750aA      WriteStr(gTmpStr);
750aA      gTmpStr = %trimr(tmpLink) + ' - ' + %trimr(text);
750aA      WriteStr(gTmpStr);
750aA      gTmpStr = '</li>';
750aA      WriteStr(gTmpStr);
750aA      return;
750aA    endif;

610dD    //gTmpStr = '<li class="nfItem">';
610dM      gTmpStr = '<li class="' + %trimr(liClass) + '">';
610aA    WriteStr(gTmpStr);
610aA    clear gTmpStr;

610dD    //gTmpStr = '<a class="nfLink" href="' + %trimr(tmpLink) + '"';
610dM    gTmpStr = '<a class="' + %trimr(aClass) + '" '
610dM            + 'href="' + %trimr(tmpLink) + '"';

         if target = '2';
           gTmpStr += ' target="_blank"';
         endif;

610cD    //gTmpStr += '>' + %trimr(text) + '</a>';
610cM    gTmpStr += '>';

610cA    WriteStr(gTmpStr);
610cA    clear gTmpStr;

610cA    if icon > ' ';
610cA      gTmpStr = '<img class="menuIcon" '
610cA              + 'src="' + %trimr(icon) + '" '
610cA              + '/>';
610cA    endif;

610cA    gTmpStr += %trimr(text) + '</a>';

610aA    WriteStr(gTmpStr);
610aA    clear gTmpStr;

610aM    gTmpStr = '</li>';
         WriteStr(gTmpStr);

      /end-free

     p FmtPgm          e

     *----------------------------------------------------------------
     *  FmtTextDivider   Format text divider string
     *----------------------------------------------------------------

     p FmtTextDivider  b
     d fmtTextDivider  pi
640fDD**text                         20a   const
640fMD  text                         30a   const

      /free

750aA    if gTree;
750aA      return;
750aA    endif;

         clear gTmpStr;

         gTmpStr = '<li class="myTitle myTitleTop">'
                 + %trimr(text)
                 + '</li>';

         WriteStr(gTmpStr);

      /end-free

     p FmtTextDivider  e

     *----------------------------------------------------------------
     *  FmtStartMenu   Format start menu string
     *----------------------------------------------------------------

     p FmtStartMenu    b
     d FmtStartMenu    pi

      /free

         clear gTmpStr;

610dA    select;
610dA      when gNodeFire;
             gTmpStr = '<ul id="bfcMenu" class="nfMain nfPure">';
610dA      when gJQuery;
700aA        if gOutputType = 'FILE2';
700aA          gTmpStr = '<ul id="bfcMenuJQ" class="menu">';
700aA        else;
610dA          gTmpStr = '<ul id="bfcMenuJQ" class="dropdown">';
700aA        endif;
750aA      when gTree;
750aA        gTmpStr = '<ul class="listree">';
610dA    endsl;
         WriteStr(gTmpStr);

      /end-free

     p FmtStartMenu    e

     *----------------------------------------------------------------
     *  FmtStartSub   Format start sub menu string
     *----------------------------------------------------------------

     p FmtStartSub     b
     d FmtStartSub     pi
640fDD**text                         20a   const
640fMD  text                         30a   const
640aMD  link                        500a   varying const
610cAD  icon                        500a   varying const

     *  Local Variables

640aMD tmpLink         s            500A   varying
610dAD aClass          s             25A
610dAD liClass         s             25A
610dAD ulClass         s             25A

      /free

610dA    select;
610dA      when gNodeFire;
610dA        liClass = 'nfItem nfParent';
610dA        aClass  = 'nfLink nfParentLink';
610dA        ulClass = 'nfSubc nfSubs';
610dA      when gJQuery and gIndentLevel = 1;
610dA        liClass = 'menuTitle';
610dA        aClass  = 'menuSet';
610dA        ulClass = 'subCheck';
610dA      when gJQuery and gIndentLevel > 1;
610dA        liClass = 'cli';
610dA        aClass  = 'subMenu';
610dA        ulClass = 'subCheck';
700aA        // Force submenus of rightmost top menu to the left
700aA        if gOutputType = 'FILE2'
700aA           and gTopCount = 7;
700aA            ulClass = 'pull-left';
700aA        endif;
750aA      when gTree;
750aA        gTmpStr = '<li>';
750aA        WriteStr(gTmpStr);
750aA        gTmpStr = '<div class="listree-submenu-heading">'
750aA                + %trimr(gTreeText) + '</div>';
750aA        WriteStr(gTmpStr);
750aA        gIndentLevel += 1;
750aA        gTmpStr = '<ul class="listree-submenu-items">';
750aA        WriteStr(gTmpStr);
750aA        return;
610dA    endsl;

         tmpLink = 'javascript:void(0)';

         clear gTmpStr;
610dD    //gTmpStr = '<li class="nfItem nfParent">';
610dM    gTmpStr = '<li class="' + %trimr(liClass) + '">';
610aA    WriteStr(gTmpStr);
610aA    clear gTmpStr;

610dD    //gTmpStr = '<a class="nfLink nfParentLink" '
610dM    gTmpStr = '<a class="' + %trimr(aClass) + '" '
610cM            + 'href="' + %trimr(tmpLink) + '">';
610cD          // + %trimr(text) + '</a>';

610cA    WriteStr(gTmpStr);
610cA    clear gTmpStr;

610cA    if icon > ' ';
610cA      gTmpStr = '<img class="menuIcon" '
610cA              + 'src="' + %trimr(icon) + '" '
610cA              + '/>';
610cA    endif;

610cA    gTmpStr += %trimr(text) + '</a>';

         WriteStr(gTmpStr);

         gIndentLevel += 1;
         clear gTmpStr;
610dD    //gTmpStr = '<ul class="nfSubC nfSubS">';
610dD    gTmpStr = '<ul class="' + %trimr(ulClass) + '">';
         WriteStr(gTmpStr);

      /end-free

     p FmtStartSub     e

     *----------------------------------------------------------------
     *  FmtUserDefined  Format user defined string
     *----------------------------------------------------------------

     p FmtUserDefined  b
     d FmtUserDefined  pi
640aMD  link                        500a   varying const
610cMD  icon                        500a   varying const

     *  Local Variables

640aMD tmpLink         s            500A   varying
610dAD aClass          s             25A
610dAD liClass         s             25A

      /free

610dA    select;
610dA      when gNodeFire;
610dA        liClass = 'nfItem';
610dA        aClass  = 'nfLink';
610dA      when gJQuery;
610dA        liClass = 'cli';
610dA        aClass  = 'hLink';
610dA    endsl;

         if link = ' ';
610dD      //tmpLink = '<a class="nfLink" '
610dM      tmpLink = '<a class="' + %trimr(aClass) + '" '
                   + 'href="javascript:void(0)">blank usrdef</a>';
         else;
           tmpLink = link;
         endif;

         clear gTmpStr;

610dD    //gTmpStr = '<li class="nfItem">'
610dM    gTmpStr = '<li class="' + %trimr(liClass) + '">'
                 + %trimr(tmpLink)
                 + '</li>';

         WriteStr(gTmpStr);

      /end-free

     p FmtUserDefined  e

640aA*----------------------------------------------------------------
640aA*  GetSessInfo  Get session info
640aA*----------------------------------------------------------------
640aA
640aAp GetSessInfo     b
     d GetSessInfo     pi            10i 0

     *  Local Variables

     D sessId          s             40    static

      /free

        sessId = gSessId;

        exec sql select gswhse, gsmenu
                 into  :gswhse,:gsmenu
                 from glosess
740aD            //where gssessid = :sessId;
740aM            where gssessid = upper(:sessId);

         If sqlstt <> sqlSuccess;
           return -1;
         endif;

         if gsmenu = ' ';
           gsmenu = 'MAIN';
         endif;

         return 0;

      /end-free

     p GetSessInfo     e

     *----------------------------------------------------------------
     *  WriteStr    Write string
     *----------------------------------------------------------------

     p WriteStr        b
     d WriteStr        pi
     D  inStr                       200A   varying const

     *  Local Variables

     D indentedStr     s            300A   varying

      /free

         // Get out if nothing to do.

         if %len(inStr) = 0;
           return;
         endif;

         // Add indentation to input string.

         clear indentedStr;

         if gOutputType = 'IFS'
            and inStr <> '*FLUSH'
            and gFormatOutput;
              i = 1;
              dow i <= gIndentLevel;
                indentedStr += '    ';
                i += 1;
              enddo;
         endif;

         indentedStr += inStr;

         // Output string

         select;
           when gOutputType = 'IFS';
             WriteStr2IFS(indentedStr);
           when gOutputType = 'FILE'
                or gOutputType = 'FILE2';
             WriteStr2File(indentedStr);
         endsl;

      /end-free

     p WriteStr        e

     *----------------------------------------------------------------
     *  WriteStr2File   Write string to file
     *----------------------------------------------------------------

     p WriteStr2File   b
     d WriteStr2File   pi
     D  inStr                       300A   varying

     *  Local Variables
     *
     *    The 999 max limitation is because that's the max def
     *    of an MRC field in its dictionary.
     *    This can be changed to 16384 if the MRC program(s) that
     *    use the glosessmnu file are manually changed to accept
     *    the variable field.

     D addStr          s            300A   varying
     D noMore          s               n
     D outStr          s          16384A   varying static
     D maxStrSize      c                   const(999)
     D seq             s              3  0 static
     D sessId          s             40    static
     D writeString     s               n

      /free

         // Loop until entire inStr is added to outStr

610aA    writeString = *off;
         noMore = *off;
         clear addStr;

         dou noMore;

           select;
             when inStr = '*FLUSH';
               noMore = *on;
             when (%len(outStr) + %len(inStr)) <= maxStrSize;
               outStr += inStr;
               noMore = *on;
610aA        when %len(inStr) > maxStrSize;
610aA          addStr = %subst(inStr: 1: (maxStrSize-%len(outStr)));
610aA          inStr = %subst(inStr: (maxStrSize-%len(outStr))+1);
610aA          outStr += addStr;
             other;
610aA          writeString = *on;
610aD          //addStr = %subst(inStr: 1: (maxStrSize-%len(outStr)));
610aD          //inStr = %subst(inStr: (maxStrSize-%len(outStr))+1);
610aD          //outStr += addStr;
           endsl;

           if %len(outStr) = maxStrSize
              or inStr = '*FLUSH'
610aM         or writeString;
             seq += 1;
             sessId = gSessId;
750aA        if gTree;
750aA          sessId = pMenu;
750aA        endif;
             exec sql insert into glosessmnu
740aD                 //values(:sessId, :seq, :outStr);
740aM                 values(upper(:sessId), :seq, :outStr);
             clear outStr;
           endif;

610aA      writeString = *off;
         enddo;

      /end-free

     p WriteStr2File   e

     *----------------------------------------------------------------
     *  WriteStr2IFS   Write string to IFS file
     *----------------------------------------------------------------

     p WriteStr2IFS    b
     d WriteStr2IFS    pi
     D  inStr                       300A   varying

     *  Local Variables

     D addStr          s            300A   varying
     D noMore          s               n
     D outStr          s          65535A   varying
     D maxStrSize      c                   const(65535)

      /free

         // Loop until entire inStr is added to outStr

         noMore = *off;
         clear addStr;

         dou noMore;

           select;
             when inStr = '*FLUSH';
               noMore = *on;
             when (%len(outStr) + %len(inStr)) <= maxStrSize;
               outStr += inStr;
               noMore = *on;
             other;
               addStr = %subst(inStr: 1: (maxStrSize-%len(outStr)));
               inStr = %subst(inStr: (maxStrSize-%len(outStr))+1);
               outStr += addStr;
           endsl;


           if gFormatOutput
              or inStr = '*FLUSH'
              or (%len(outStr) = maxStrSize);
          //   writeline(gFD: %addr(outStr)+2: %len(outStr));
             clear outStr;
           endif;

         enddo;

      /end-free

     p WriteStr2IFS    e

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h
