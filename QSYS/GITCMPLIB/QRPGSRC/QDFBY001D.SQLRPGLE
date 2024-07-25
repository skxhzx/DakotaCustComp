      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY001  Remove Duplicates
     *  09 September 2016
     *  Rod Roller
     *
700  *  09/09/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fimpfstuf3 uf   e           k disk    extmbr('OLDSLOTS')
     f                                     usropn

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Table and array definitions
     d lower           c                   'abcdefghijklmnopqrstuvwxyz'
     d upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Variables
     d holddisp        s             12a
     d recdisp         s             12a

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        // uppercase everything
        open impfstuf3;
        dou forever <> forever;
          read impfstuf3;

          if %eof(impfstuf3);
            leave;
          endif;

          sidisp = %xlate(lower:upper:sidisp);
          update sirec;
        enddo;
        close impfstuf3;

        // remove duplicates
        exec sql declare c1 cursor for
                  select sidisp from oldslots
                   order by sidisp;
        exec sql open c1;
        dou forever <> forever;
          exec sql fetch c1 into :recdisp;

          if sqlstt <> sqlsuccess;
            leave;
          endif;

          if recdisp <> holddisp;
            holddisp = recdisp;
          else;
            exec sql delete from oldslots
                     where current of c1;
          endif;
        enddo;
        exec sql close c1;

        *inlr = *on;
      /end-free
