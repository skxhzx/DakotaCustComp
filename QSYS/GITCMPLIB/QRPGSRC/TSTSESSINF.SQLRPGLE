      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTSESSINF   Set session info
     *
     *----------------------------------------------------------------

     D glosess       E ds

     D  pDtaSrc        s             10

     c     *entry        plist
     c                   parm                    pDtaSrc

      /free

        *inlr = *on;

610bA   exec sql select gdsmenu into :gsmenu
610bA            from glodbsrc
610bA            where gdsid = :pDtaSrc;
610bA
610bA   If sqlstt <> '00000' or gsmenu = ' ';
610aA     //gsmenu = 'MAIN';
610aA     gsmenu = sqlstt;
610bA   endif;

        return;
