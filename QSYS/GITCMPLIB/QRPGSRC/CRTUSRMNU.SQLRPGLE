      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *
     *  CRTUSRMNU  Create user menu IFS file
     *  06 February 2010
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/06/10  DAS  6.10
     *      - Created.
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
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gDivMenu        s               n
     D gFormatOutput   s               n
     D gIndentLevel    s              1  0
     D gULMenu         s               n
     D gFD             s             10I 0

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
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d BldMenu         pr
     d CrtIfsFile      pr            10i 0
     d FmtEndMenu      pr           200a   varying
     d FmtEndSub       pr           200a   varying
     d FmtLineDivider  pr           200a   varying
     d FmtLink         pr           200a   varying
     D  target                        1a   const
     D  text                         20a   const
     D  link                        100a   const
     D  icon                         50a   const
     d FmtTextDivider  pr           200a   varying
     D  text                         20a   const
     d FmtStartMenu    pr           200a   varying
     d FmtStartSub     pr           200a   varying
     d FmtSubMenu      pr           200a   varying
     D  text                         20a   const
     D  link                        100a   const
     D  icon                         50a   const
     d FmtUserDefined  pr           200a   varying
     D  link                        100a   const
     D  icon                         50a   const
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
     *      pUser        User code
     *      pOutputType  IFS  - Write to IFS file.
     *                   FILE - Write to file GLOUSRMNU
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pUser            10
     C                   parm                    pOutputType      10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pOutputType = 'FILE';

         // Define if output should be formatted.
         //   Formatting will add indentation and crlf's

         gFormatOutput = *off;

         // Define menu type - Only one should be set on.
         //   gULMenu uses <ul><li>
         //   gDivMenu uses <div>

         gULMenu = *off;
         gDivMenu = *on;

600fA    // Connect to the database - Get out if error

600fA    exsr SqlConnect;

600fA    // Create/Open output file - Get out if error

600fA    select;

600fA      // Clear file
600fA      when pOutputType = 'FILE';
600fA        exec sql delete from glousrmnu where gumuser = :pUser;

600fA      // Create IFS file (it will be cleared if it exists)
600fA      when pOutputType = 'IFS';
600fA        gFD = CrtIfsFile();
600fA        if gFD < 0;
600fA          return;
600fA        endif;

600fA      other;
600fA        return;

600fA    endsl;

600fA    // Build menu for user

         exsr sqlclean;
         exsr sqlbldstmt;
         exsr sqlprep;
600fA    BldMenu();

600fA    // Close IFS file

600fA    if pOutputType = 'IFS';
           callp close(gFD);
600fA    endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt  - Build SQL statment
     *----------------------------------------------------------------

      /free
       begsr SqlBldStmt;

         sqlstmt = 'SELECT gmline,gmmain,gmsub1,gmsub2,gmsub3,gmsub4,gmsub5,'
                 +        'gmitext,gmilink,gmiicon,gmitype,gmitarget '
                 + 'FROM glomenu '
                 + 'INNER JOIN glomenuitm ON gmiid = gmmiid '
                 + 'WHERE gmline=1 '
                 + 'ORDER BY gmline,gmmain,gmsub1,gmsub2,gmsub3,gmsub4,gmsub5';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr SqlClean;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SqlConnect - Connect to database
     *----------------------------------------------------------------

      /free
       begsr SqlConnect;

600fA    // Establish the connection to the remote machine. The -842 return
600fA    // code indicates that the connection is already established. If
600fA    // you want to connect to the local machine, use CONNECT RESET.
600fA
600fA    exec sql CONNECT RESET;
600fA
600fA    If sqlstt <> sqlSuccess;
600fA      return;
600fA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr SqlPrep;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares th cursor.

         exec sql PREPARE sel FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the cursor to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR SCROLL CURSOR FOR SEL;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR;

         sqlstt = sqlstt;

       endsr;
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
                  + %trim(pUser)
                  + '.html';

         fd = open(%trimr(fileName):
                   O_TRUNC+O_CREAT+O_WRONLY+
                   O_CODEPAGE:
                   S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
                   819);

         if fd < 0;
           return fd;
         endif;

         // Close file and reopen it in text mode.

         callp close(fd);
         fd = open(%trimr(fileName):
                   O_WRONLY+O_TEXTDATA);

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

     *  Local Variables

     D changedLevel    s              1  0
     D curSub          s              2  0
     D first           s               n
     D lastSubs        s              2  0 dim(6)
     D recSubs         s              2  0 dim(6)

     *  File field data structure.

     D glomenu       e ds
     D glomenuitm    e ds

     *  SQL fetch fields

     D fetchds         ds
     D   #gmline                           like(gmline)
     D   #gmmain                           like(gmmain)
     D   #gmsub1                           like(gmsub1)
     D   #gmsub2                           like(gmsub2)
     D   #gmsub3                           like(gmsub3)
     D   #gmsub4                           like(gmsub4)
     D   #gmsub5                           like(gmsub5)
     D   #gmitext                          like(gmitext)
     D   #gmilink                          like(gmilink)
     D   #gmiicon                          like(gmiicon)
     D   #gmitype                          like(gmitype)
     D   #gmitarget                        like(gmitarget)

      /free

         changedlevel = 0;
         curSub = 0;
         lastSubs = 0;
         recSubs = 0;
         first = *on;

         // Write out starting menu record.

         WriteStr(FmtStartMenu());
         gIndentLevel = 1;

         // Process the records in the SQL cursor until the return not = 0

         dow forever = forever;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt <> sqlSuccess;
             leave;
           endif;

           // Move fields into array for easier processing.

           recSubs(1) = #gmmain;
           recSubs(2) = #gmsub1;
           recSubs(3) = #gmsub2;
           recSubs(4) = #gmsub3;
           recSubs(5) = #gmsub4;
           recSubs(6) = #gmsub5;

           // First time through ...

           if first;
             lastSubs = recSubs;
             first = *off;
           endif;

           // When a level changes, see if any sub menus need to be closed.

           for changedLevel = 0 to 5;
             if recSubs(changedLevel+1) <> lastSubs(changedLevel+1);
               for curSub = curSub downto changedLevel+1;
                 WriteStr(FmtEndSub());
                 gIndentLevel -= 1;
               endfor;
               //curSub += 1;
               gIndentLevel = curSub + 1;
               leave;
             endif;
           endfor;

           lastSubs = recSubs;

           // Skip record if it doesn't match the current sub menu level.

           if recSubs(curSub+2) <> 0;
             leave;
           endif;

           // We have a good record, so write it out.

           select;
             when #gmitype = '1';
               WriteStr(FmtLink(#gmitarget:#gmitext:#gmilink:#gmiicon));
             when #gmitype = '2';
               WriteStr(FmtSubMenu(#gmitext:#gmilink:#gmiicon));
               WriteStr(FmtStartSub());
               curSub += 1;
             when #gmitype = '3';
               WriteStr(FmtTextDivider(#gmitext));
             when #gmitype = '4';
               WriteStr(FmtLineDivider());
             when #gmitype = '5';
               WriteStr(FmtUserDefined(#gmilink:#gmiicon));
           endsl;

         enddo;

         // Close any sub menus

         for curSub = curSub downto 1;
           WriteStr(FmtEndSub());
           lastSubs(curSub+1) = recSubs(curSub+1);
           gIndentLevel -= 1;
         endfor;

         // Write out ending menu record.

         gIndentLevel = 0;
         WriteStr(FmtEndMenu());

600fA    // Flush output buffer

         WriteStr('*FLUSH');

      /end-free

     p BldMenu         e

     *----------------------------------------------------------------
     *  FmtEndMenu   Format end menu string
     *----------------------------------------------------------------

     p FmtEndMenu      b
     d FmtEndMenu      pi           200a   varying

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         clear tmpStr;

         select;
           when gULMenu;
             tmpStr = '</ul>';
           when gDivMenu;
             tmpStr = '</div>';
         endsl;

         return tmpStr;

      /end-free

     p FmtEndMenu      e

     *----------------------------------------------------------------
     *  FmtEndSub   Format end sub menu string
     *----------------------------------------------------------------

     p FmtEndSub       b
     d FmtEndSub       pi           200a   varying

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         clear tmpStr;

         select;
           when gULMenu;
             tmpStr = '</ul></li>';
           when gDivMenu;
             tmpStr = '</div>';
         endsl;

         return tmpStr;

      /end-free

     p FmtEndSub       e

     *----------------------------------------------------------------
     *  FmtLineDivider   Format line divider string
     *----------------------------------------------------------------

     p FmtLineDivider  b
     d fmtLineDivider  pi           200a   varying

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         clear tmpStr;

         if gULMenu;
           tmpStr = '<li>';
         endif;

         tmpStr += '<span class="qmdivider qmdividerx"></span>';

         if gULMenu;
           tmpStr += '</li>';
         endif;

         return tmpStr;

      /end-free

     p FmtLineDivider  e

     *----------------------------------------------------------------
     *  FmtLink     Format link string
     *----------------------------------------------------------------

     p FmtLink         b
     d FmtLink         pi           200a   varying
     D  target                        1a   const
     D  text                         20a   const
     D  link                        100a   const
     D  icon                         50a   const

     *  Local Variables

     D tmpLink         s            100A
     D tmpStr          s            200A   varying

      /free

         if link = ' ';
           tmpLink = 'javascript:void(0)';
         else;
           tmpLink = link;
         endif;

         clear tmpStr;

         if gULMenu;
           tmpStr = '<li>';
         endif;

         tmpStr += '<a href="' + %trimr(tmpLink) + '"';

         if target = '2';
           tmpStr += ' target="_blank"';
         endif;

         tmpStr += '>' + %trimr(text) + '</a>';

         if gULMenu;
           tmpStr += '</li>';
         endif;

         return tmpStr;

      /end-free

     p FmtLink         e

     *----------------------------------------------------------------
     *  FmtTextDivider   Format text divider string
     *----------------------------------------------------------------

     p FmtTextDivider  b
     d fmtTextDivider  pi           200a   varying
     D  text                         20a   const

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         clear tmpStr;

         if gULMenu;
           tmpStr = '<li>';
         endif;

         tmpStr += '<span class="qmtitle">'
                 + %trimr(text)
                 + '</span>';

         if gULMenu;
           tmpStr += '</li>';
         endif;

         return tmpStr;

      /end-free

     p FmtTextDivider  e

     *----------------------------------------------------------------
     *  FmtStartMenu   Format start menu string
     *----------------------------------------------------------------

     p FmtStartMenu    b
     d FmtStartMenu    pi           200a   varying

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         clear tmpStr;

         select;
           when gULMenu;
             tmpStr = '<ul id="qm0" class="qmmc">';
           when gDivMenu;
             tmpStr = '<div id="qm0" class="qmmc">';
         endsl;

         return tmpStr;

      /end-free

     p FmtStartMenu    e

     *----------------------------------------------------------------
     *  FmtStartSub   Format start sub menu string
     *----------------------------------------------------------------

     p FmtStartSub     b
     d FmtStartSub     pi           200a   varying

     *  Local Variables

     D tmpStr          s            200A   varying

      /free

         gIndentLevel += 1;

         clear tmpStr;

         select;
           when gULMenu;
             tmpStr = '<ul>';
           when gDivMenu;
             tmpStr = '<div>';
         endsl;

         return tmpStr;

      /end-free

     p FmtStartSub     e

     *----------------------------------------------------------------
     *  FmtSubMenu  Format submenu string
     *----------------------------------------------------------------

     p FmtSubMenu      b
     d FmtSubMenu      pi           200a   varying
     D  text                         20a   const
     D  link                        100a   const
     D  icon                         50a   const

     *  Local Variables

     D tmpLink         s            100A
     D tmpStr          s            200A   varying

      /free

         if link = ' ';
           tmpLink = 'javascript:void(0)';
         else;
           tmpLink = link;
         endif;

         clear tmpStr;

         if gULMenu;
           tmpStr = '<li>';
         endif;

         tmpStr += '<a class="qmparent" href="' + %trimr(tmpLink) + '">'
                 + %trimr(text) + '</a>';

         return tmpStr;

      /end-free

     p FmtSubMenu      e

     *----------------------------------------------------------------
     *  FmtUserDefined  Format user defined string
     *----------------------------------------------------------------

     p FmtUserDefined  b
     d FmtUserDefined  pi           200a   varying
     D  link                        100a   const
     D  icon                         50a   const

     *  Local Variables

     D tmpLink         s            100A
     D tmpStr          s            200A   varying

      /free

         if link = ' ';
           tmpLink = '<a href="javascript:void(0)">blank usrdef</a>';
         else;
           tmpLink = link;
         endif;

         clear tmpStr;

         if gULMenu;
           tmpStr = '<li>';
         endif;

         tmpStr += %trimr(tmpLink);

         if gULMenu;
           tmpStr += '</li>';
         endif;

         return tmpStr;

      /end-free

     p FmtUserDefined  e

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

         if pOutputType = 'IFS'
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
           when pOutputType = 'IFS';
             WriteStr2IFS(indentedStr);
           when pOutputType = 'FILE';
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
     *    of an MRC file in its dictionary.
     *    This can be changed to 16384 if the MRC program(s) that
     *    use the glousrmnu file are manually changed to accept
     *    the variable field.

     D addStr          s            300A   varying
     D noMore          s               n
     D outStr          s          16384A   varying static
     D maxStrSize      c                   const(999)
     D seq             s              3  0 static
     D user            s             10

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

           if %len(outStr) = maxStrSize
              or inStr = '*FLUSH';
             seq += 1;
             user = pUser;
             exec sql insert into glousrmnu
                      values(:user, :seq, :outStr);
             clear outStr;
           endif;

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
             writeline(gFD: %addr(outStr)+2: %len(outStr));
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
