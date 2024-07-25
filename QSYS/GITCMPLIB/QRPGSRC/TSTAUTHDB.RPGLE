      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTAUTHDB   Test AUTHDB
     *  30 March 2015
     *  Dave Sommerville
     *----------------------------------------------------------------

     Fglodbsrc  if   e           k disk

     D pUser           s             10
     D aFlag           s              1p 0

     D authdb          pr                  extpgm('AUTHDB')
     D  pDBid                        10    const
     D  pUser                        10    const
     D  aFlag                         1p 0

      /free
        *inlr = *on;

        pUser = 'DEMO700H';
        dump(a);

        dow 1 = 1;
          read glodbsrc;
          if %eof(glodbsrc);
            leave;
          endif;
          authdb(gdsid: pUser: aFlag);
          dsply aFlag;
        enddo;

        return;
      /end-free
