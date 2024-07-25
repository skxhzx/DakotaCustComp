      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDROLE01     Create @SELECT Zone Header records
     *  June 24, 2021
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
ACC  *    06/21/21  KDE
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     fzoneh     uf a e           k disk
     *----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Working variables
     d zonecnt         s              2  0

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Read all the Zone Header Templates
        exec sql delete from zoneh where substring(zhtruk,1,1)='@';
        setll (0:'*') zoneh;
        dow forever = forever;
          read zoneh;

          if %eof(zoneh);
            leave;
          endif;

          if %subst(zhtruk:1:1)<>'*';
            iter;
          endif;

          if zhgen<>1 and zhgen<>2 and zhgen<>3;
            iter;
          endif;

          zonecnt=0;
          exec sql select count(*) into :zonecnt
                     from zoneh
                 where zhwhse=:zhwhse and zhtruk='@SELECT'
                   and zhzone=:zhzone;
          if zonecnt=0;
            zhtruk='@SELECT';
            write zhrec;
          endif;
        enddo;

        *inlr = *on;
      /end-free
