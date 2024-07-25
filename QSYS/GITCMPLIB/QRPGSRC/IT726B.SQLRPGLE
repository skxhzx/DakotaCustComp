      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT726B    FTP Export item adjustment file - LICADJ w/status
     *  27 March 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    03/27/15  RTR  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     Fexpfadj   o  a e           k disk

     *----------------------------------------------------------------
     *  Data Formats
     D adjrec        e ds                  extname(licadj) inz(*EXTDFT)

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
     D clear           s              5  0
     D cntexp          s              9s 0
     D cntskp          s              9s 0
     D rtnCode         s             10a
     D rtnMessage      s            200a
     D logMessage      s           1024a

     *----------------------------------------------------------------
     *  Called Program Prototypes
     D WrtLog          pr                  extpgm('WRTLOG')
     D                               10    const
     D                               10    const
     D                             1024    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('IT726B')
      * Input

     D main            pi

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Select records not already processed.
        exec Sql
          declare recs dynamic scroll cursor for
            select *
              from licadj
             where adjexpflag = ' ';

        exec sql open recs;
        if sqlstt <> sqlSuccess;
          logMessage = 'SQL:' + sqlstt + ' Unable to open cursor recs.';
          WrtLog(#pgm: '*ERROR': logMessage);
        endif;

        dow forever = forever;

          // Read next record.
          exec sql fetch next from recs
                   into :adjrec;

          // If no more, you are done.
          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if (adjcsys <> 'B' and adjcsys <> 'H')
           or (%subst(adjcode:1:1) = '@')
           or adjitem = *blanks;
            exec sql update licadj
                     set adjexpflag = 'X'
                     where current of recs;
            cntskp = cntskp + 1;
            iter;
          endif;

          iewhse = adjwhs;
          ieitem = adjitem;
          iedate = %int(%char(%date(ADJADDTS): *iso0));
          ietime = %int(%char(%time(ADJADDTS): *hms0));
          ieby = adjaddcusr;
          iewhdp = adjwhdp;
          iedisp = adjdisp;
          iecwta = adjcqta;
          ieqty1 = adjaqty1;
          ieqty2 = adjaqty2;
          ieqty3 = adjaqty3;
          iecode = adjcode;
          iememo = adjmemo;
          iestat = adjstat;
          write ierec;

          cntexp = cntexp + 1;

          exec sql update licadj
                   set adjexpflag = 'S',
                       adjexpts = CURRENT_TIMESTAMP,
                       adjexpuc = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                       adjexpjusr = :#user,
                       adjexpjob = :#job,
                       adjexpnbr = :#jobnbr
                   where current of recs;
          if sqlstt <> sqlSuccess;
            logMessage = 'SQL:' + sqlstt + ' Unable to update LICADJ record.';
            WrtLog(#pgm: '*ERROR': logMessage);
          endif;

        enddo;

        exec sql close recs;
        logMessage = 'End of LICADJ Export. '
                   + %trimr(%char(cntexp)) + ' exported, '
                   + %trimr(%char(cntskp)) + ' skipped. ';
        WrtLog(#pgm: '*INFO': logMessage);
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

          WrtLog(#pgm: '*INFO': 'Running LICADJ Export.');

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------
      /free
        begsr *pssr;

          // Attempt to log, may not work.
          monitor;
            WrtLog(#pgm: '*ERROR': 'Abnormal end: *PSSR.');
          on-error;
          endmon;

          // Make sure we don't get caught in an infinite loop
          if pssrflag;
            *inlr = *on;
            return;
          endif;

          pssrflag = *on;
          *inlr = *on;
          return;

        endsr;   // *pssr
      /end-free
