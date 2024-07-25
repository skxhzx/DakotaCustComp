      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT728B    FTP Export item adjustment file w/sign - LICADJ
     *  27 March 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    03/27/15  RTR  7.00
     *      - Created.
700a *    11/11/15  RTR  7.00a
     *      - Added EXPFADJL record call.
700b *    02/01/16  RTR  7.00b
     *      - Change to check CI and TF for matching record, if none
     *        found leave record for next run.
700c *    02/10/16  RTR  7.00c
     *      - Change to call IT781 for L records passing license.
     *        Needed to ensure record written in case LICLOG not found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    02/09/16  RTR  SBRa
     *      - If both sides of a TF or CI are OSS, do not send to host.
SBRb *    05/18/17  RTR  SBRb
     *      - Add OSS location F for whse 6 per Chaim.
SBRc *    08/01/18  RTR  SBRc
     *      - Add OSS location I for whse 9 per Chaim.
     *
     *----------------------------------------------------------------
     * File Specs
     Fexpfadjs  o  a e           k disk

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
     *  Customer id
      /copy qcopysrc,id#sbr

     *----------------------------------------------------------------
     *  Working variables
     D clear           s              5  0
700cAD chkdisp         s                   like(adjdisp)
     D cntexp          s              9s 0
     D cntskp          s              9s 0
     D cwgt            S                   like(adjcqta)
700bAD reccnt          s              6  0
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
     D main            pr                  extpgm('IT728B')
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
             where adjexpflag = ' '
700bA        order by adjnbr;

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
700bA      or (adjitem = *blanks);
            exec sql update licadj
                     set adjexpflag = 'X'
                     where current of recs;
            cntskp = cntskp + 1;
            iter;
          endif;

700bA     // If first Transfer or Change Item, look for matching
700bA     // record. If not found, leave record for next time.
700bA     // These must export as a pair.
700bA     if (adjcode = 'TF' or adjcode = 'CI')
700bA      and adjparent = *blanks;
700bA       exec sql select count(*) into :reccnt
700bA                  from licadj
700bA                 where adjparent = :adjnbr;
700bA       select;
700bA        when reccnt >= 1;
700bA         // continue
700bA        other;
700bA         cntskp = cntskp + 1;
700bA         iter;
700bA       endsl;
700bA     endif;

SBRaA     // If both sides of transfer/change are OSS, don't export.
SBRaA     if client = SBertram
SBRaA      and adjaisl = 'OSS'
SBRaA      and (adjcode = 'TF' or adjcode = 'CI');
SBRaA       if adjparent = *blanks;
SBRaA         exec sql select adjdisp into :chkdisp
SBRaA                    from licadj
SBRaA                   where adjparent = :adjnbr;
SBRaA         if %subst(chkdisp:1:3) = 'OSS';
SBRaA           exec sql update licadj
SBRaA                       set adjexpflag = 'X'
SBRaA                     where current of recs;
SBRaA           cntskp = cntskp + 1;
SBRaA           iter;
SBRaA         endif;
SBRaA       else;
SBRaA         exec sql select adjdisp into :chkdisp
SBRaA                    from licadj
SBRaA                   where adjnbr = :adjparent;
SBRaA         if %subst(chkdisp:1:3) = 'OSS';
SBRaA           exec sql update licadj
SBRaA                       set adjexpflag = 'X'
SBRaA                     where current of recs;
SBRaA           cntskp = cntskp + 1;
SBRaA           iter;
SBRaA         endif;
SBRaA       endif;
SBRaA     endif;

          if client = SBertram
           and adjaisl = 'OSS';
            select;
              when %subst(adjdisp:4:1) = 'A';
                iewhse = 1;
              when %subst(adjdisp:4:1) = 'B';
                iewhse = 2;
              when %subst(adjdisp:4:1) = 'C';
                iewhse = 3;
              when %subst(adjdisp:4:1) = 'D';
                iewhse = 4;
              when %subst(adjdisp:4:1) = 'E';
                iewhse = 5;
SBRbA         when %subst(adjdisp:4:1) = 'F';
SBRbA           iewhse = 6;
SBRcA         when %subst(adjdisp:4:1) = 'I';
SBRcA           iewhse = 9;
              other;
                iewhse = adjwhs;
            endsl;
          else;
            iewhse = adjwhs;
          endif;

          ieitem = adjitem;
          iedate = %int(%char(%date(ADJADDTS): *iso0));
          ietime = %int(%char(%time(ADJADDTS): *hms0));
          ieby = adjaddcusr;
          iewhdp = adjwhdp;
          iedisp = adjdisp;

          if adjcqta >= 0;
            iecwta = %editc(adjcqta:'X');
          else;
            cwgt = %abs(adjcqta);
            iecwta = %editc(cwgt:'X') + '-';
          endif;
          ieqty1 = %editc(adjaqty1:'L');
          ieqty2 = %editc(adjaqty2:'L');
          ieqty3 = %editc(adjaqty3:'L');

          iecode = adjcode;
          iememo = adjmemo;
          iestat = adjstat;
          write ierec;

          cntexp = cntexp + 1;

700aA     // Create license records for adjustment
700aA     exsr zzcrtlic;

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

      /end-free
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
      /free

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

700aA*----------------------------------------------------------------
700aA*
700aA*  ZZCRTLIC   Create license export record
700aA*
700aAC     zzcrtlic      begsr
700bA*
700bAC                   eval      iewhse = adjwhs
700aA*
700aA*  Create license records for adjustment
700cDC**                 call      'IT780'
700cMC                   call      'IT781'
700aAC                   parm                    iewhse
700aAC                   parm                    ieitem
700aAC                   parm                    iedate
700aAC                   parm                    ietime
700aAC                   parm                    ieby
700aAC                   parm                    iewhdp
700aAC                   parm                    iedisp
700aAC                   parm                    adjaqty1
700aAC                   parm                    adjaqty2
700aAC                   parm                    adjaqty3
700cAC                   parm                    adjlcns
700aA*
700aAC                   endsr
