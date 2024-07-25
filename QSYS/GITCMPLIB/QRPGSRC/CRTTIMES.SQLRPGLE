      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CRTTIMES     Create GLOTIMES recors
     *  01 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    05/01/10  DAS  6.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glotimes      E ds

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

     D i               s              3  0

     D dsTime          ds
     D  dsHour                        2s 0
     D  dsColon                       1    inz(':')
     D  dsMin                         2s 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Clear file

        exec sql delete from glotimes;

        // Create times 00:00 - 24:00

        for dsHour = 0 to 24;
          dsMin = 0;
          gttime = dstime;
          exec sql insert into glotimes
                 values(:gttime);
          if dsHour <> 24;
            dsMin = 30;
            gttime = dstime;
            exec sql insert into glotimes
                   values(:gttime);
          endif;
        endfor;

        return;

      /end-free
