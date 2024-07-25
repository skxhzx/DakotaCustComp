      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UMLABEL   LABELUM file operations
     *  13 August 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
720aA*   08/13/19  DAS  7.30
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program only does file operations, it does not do any
     *   field error checking.
     *
     *   *INLR is only set on with *CLOSE is sent in.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d lburec        e ds                  extname(labelum) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables
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
     *  Variables
     *----------------------------------------------------------------

     d parmsSent       s              3  0
     d fld             s             10    varying
     d sqlStmt1        s           3000    varying
     d sqlStmt2        s           2000    varying
     d separator       s              1    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d DoAdd           pr

     d DoChange        pr

     d DoDelete        pr

     d DoGet           pr

     d Move            pr
     d  direction                    10    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *  iCmd      - *ADD, *CHANGE, *DELETE, *GET, *CLOSE
     *  iRtnCode
     *  iRtnMsg
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d UMLABEL         pr                  extpgm('UMLABEL')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilbuwhse                            like(lbuwhse)
     d  ilbulbl#                            like(lbulbl#)
     d  ilbufpflg                           like(lbufpflg) options(*nopass)
     d  ilbualq1                            like(lbualq1) options(*nopass)
     d  ilbualu1                            like(lbualu1) options(*nopass)
     d  ilbualq2                            like(lbualq2) options(*nopass)
     d  ilbualu2                            like(lbualu2) options(*nopass)
     d  ilbualq3                            like(lbualq3) options(*nopass)
     d  ilbualu3                            like(lbualu3) options(*nopass)
     d  ilbualman                           like(lbualman) options(*nopass)
     d  ilbualmab1                          like(lbualmab1) options(*nopass)
     d  ilbualmab2                          like(lbualmab2) options(*nopass)
     d  ilbualmrn                           like(lbualmrn) options(*nopass)
     d  ilbualmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbualmrb2                          like(lbualmrb2) options(*nopass)
     d  ilbupkq1                            like(lbualq1) options(*nopass)
     d  ilbupku1                            like(lbualu1) options(*nopass)
     d  ilbupkq2                            like(lbualq2) options(*nopass)
     d  ilbupku2                            like(lbualu2) options(*nopass)
     d  ilbupkq3                            like(lbualq3) options(*nopass)
     d  ilbupku3                            like(lbualu3) options(*nopass)
     d  ilbupkman                           like(lbualman) options(*nopass)
     d  ilbupkmab1                          like(lbualmab1) options(*nopass)
     d  ilbupkmab2                          like(lbualmab2) options(*nopass)
     d  ilbupkmrn                           like(lbualmrn) options(*nopass)
     d  ilbupkmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbupkmrb2                          like(lbualmrb2) options(*nopass)

     d UMLABEL         pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilbuwhse                            like(lbuwhse)
     d  ilbulbl#                            like(lbulbl#)
     d  ilbufpflg                           like(lbufpflg) options(*nopass)
     d  ilbualq1                            like(lbualq1) options(*nopass)
     d  ilbualu1                            like(lbualu1) options(*nopass)
     d  ilbualq2                            like(lbualq2) options(*nopass)
     d  ilbualu2                            like(lbualu2) options(*nopass)
     d  ilbualq3                            like(lbualq3) options(*nopass)
     d  ilbualu3                            like(lbualu3) options(*nopass)
     d  ilbualman                           like(lbualman) options(*nopass)
     d  ilbualmab1                          like(lbualmab1) options(*nopass)
     d  ilbualmab2                          like(lbualmab2) options(*nopass)
     d  ilbualmrn                           like(lbualmrn) options(*nopass)
     d  ilbualmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbualmrb2                          like(lbualmrb2) options(*nopass)
     d  ilbupkq1                            like(lbualq1) options(*nopass)
     d  ilbupku1                            like(lbualu1) options(*nopass)
     d  ilbupkq2                            like(lbualq2) options(*nopass)
     d  ilbupku2                            like(lbualu2) options(*nopass)
     d  ilbupkq3                            like(lbualq3) options(*nopass)
     d  ilbupku3                            like(lbualu3) options(*nopass)
     d  ilbupkman                           like(lbualman) options(*nopass)
     d  ilbupkmab1                          like(lbualmab1) options(*nopass)
     d  ilbupkmab2                          like(lbualmab2) options(*nopass)
     d  ilbupkmrn                           like(lbualmrn) options(*nopass)
     d  ilbupkmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbupkmrb2                          like(lbualmrb2) options(*nopass)

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

       iRtnCode = '*OK';
       iRtnMsg = '';
       parmsSent = %parms;

       select;

         when iCmd = '*ADD';
           Move('ParmsToRec');
           DoAdd();

         when iCmd = '*CHANGE';
           Move('ParmsToRec');
           DoChange();

         when iCmd = '*DELETE';
           DoDelete();

         when iCmd = '*GET';
           DoGet();
           Move('RecToParms');

         when iCmd = '*CLOSE';
           *inlr = *on;

       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         iRtnCode = '*ERROR';
         iRtnMsg = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DoAdd    Add record
     *----------------------------------------------------------------

     p DoAdd           b
     d DoAdd           pi

     * Local Variables

     d count           s              1  0

      /free

        sqlStmt1 = 'insert into labelum (';
        sqlStmt2 = 'values (';

        sqlStmt1 += 'lbuwhse';
        sqlStmt2 += %char(ilbuwhse);

        sqlStmt1 += ',lbulbl#';
        sqlStmt2 += ',' + %char(ilbulbl#);

        if parmsSent > 5;
          sqlStmt1 += ',lbufpflg';
          sqlStmt2 += ',' + sq + %trimr(ilbufpflg) + sq;
        endif;
        if parmsSent > 6;
          sqlStmt1 += ',lbualq1';
          sqlStmt2 += ',' + %char(ilbualq1);
        endif;
        if parmsSent > 7;
          sqlStmt1 += ',lbualu1';
          sqlStmt2 += ',' + sq + %trimr(ilbualu1) + sq;
        endif;
        if parmsSent > 8;
          sqlStmt1 += ',lbualq2';
          sqlStmt2 += ',' + %char(ilbualq2);
        endif;
        if parmsSent > 9;
          sqlStmt1 += ',lbualu2';
          sqlStmt2 += ',' + sq + %trimr(ilbualu2) + sq;
        endif;
        if parmsSent > 10;
          sqlStmt1 += ',lbualq3';
          sqlStmt2 += ',' + %char(ilbualq3);
        endif;
        if parmsSent > 11;
          sqlStmt1 += ',lbualu3';
          sqlStmt2 += ',' + sq + %trimr(ilbualu3) + sq;
        endif;
        if parmsSent > 12;
          sqlStmt1 += ',lbualman';
          sqlStmt2 += ',' + %char(ilbualman);
        endif;
        if parmsSent > 13;
          sqlStmt1 += ',lbualmab1';
          sqlStmt2 += ',' + %char(ilbualmab1);
        endif;
        if parmsSent > 14;
          sqlStmt1 += ',lbualmab2';
          sqlStmt2 += ',' + %char(ilbualmab2);
        endif;
        if parmsSent > 15;
          sqlStmt1 += ',lbualmrn';
          sqlStmt2 += ',' + %char(ilbualmrn);
        endif;
        if parmsSent > 16;
          sqlStmt1 += ',lbualmrb1';
          sqlStmt2 += ',' + %char(ilbualmrb1);
        endif;
        if parmsSent > 17;
          sqlStmt1 += ',lbualmrb2';
          sqlStmt2 += ',' + %char(ilbualmrb2);
        endif;
        if parmsSent > 18;
          sqlStmt1 += ',lbupkq1';
          sqlStmt2 += ',' + %char(ilbupkq1);
        endif;
        if parmsSent > 19;
          sqlStmt1 += ',lbupku1';
          sqlStmt2 += ',' + sq + %trimr(ilbupku1) + sq;
        endif;
        if parmsSent > 20;
          sqlStmt1 += ',lbupkq2';
          sqlStmt2 += ',' + %char(ilbupkq2);
        endif;
        if parmsSent > 21;
          sqlStmt1 += ',lbupku2';
          sqlStmt2 += ',' + sq + %trimr(ilbupku2) + sq;
        endif;
        if parmsSent > 22;
          sqlStmt1 += ',lbupkq3';
          sqlStmt2 += ',' + %char(ilbupkq3);
        endif;
        if parmsSent > 23;
          sqlStmt1 += ',lbupku3';
          sqlStmt2 += ',' + sq + %trimr(ilbupku3) + sq;
        endif;
        if parmsSent > 24;
          sqlStmt1 += ',lbupkman';
          sqlStmt2 += ',' + %char(ilbupkman);
        endif;
        if parmsSent > 25;
          sqlStmt1 += ',lbupkmab1';
          sqlStmt2 += ',' + %char(ilbupkmab1);
        endif;
        if parmsSent > 26;
          sqlStmt1 += ',lbupkmab2';
          sqlStmt2 += ',' + %char(ilbupkmab2);
        endif;
        if parmsSent > 27;
          sqlStmt1 += ',lbupkmrn';
          sqlStmt2 += ',' + %char(ilbupkmrn);
        endif;
        if parmsSent > 28;
          sqlStmt1 += ',lbupkmrb1';
          sqlStmt2 += ',' + %char(ilbupkmrb1);
        endif;
        if parmsSent > 29;
          sqlStmt1 += ',lbupkmrb2';
          sqlStmt2 += ',' + %char(ilbupkmrb2);
        endif;

        sqlStmt1 += ') ';
        sqlStmt2 += ') ';

        sqlStmt1 += sqlStmt2;

        exec sql execute immediate :sqlStmt1;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ilbuwhse) + '/' + %char(ilbulbl#)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoChange    Update record
     *----------------------------------------------------------------

     p DoChange        b
     d DoChange        pi

     * Local Variables

     d count           s              1  0

      /free

        sqlStmt1 = 'update labelum set ';
        separator = '';

        if parmsSent > 5;
          sqlStmt1 += 'lbufpflg='
                  + sq + %trimr(ilbufpflg) + sq;
          separator = ',';
        endif;
        if parmsSent > 6;
          sqlStmt1 += separator + 'lbualq1='
                  + %char(ilbualq1);
          separator = ',';
        endif;
        if parmsSent > 7;
          sqlStmt1 += separator + 'lbualu1='
                  + sq + %trimr(ilbualu1) + sq;
          separator = ',';
        endif;
        if parmsSent > 8;
          sqlStmt1 += separator + 'lbualq2='
                  + %char(ilbualq2);
          separator = ',';
        endif;
        if parmsSent > 9;
          sqlStmt1 += separator + 'lbualu2='
                  + sq + %trimr(ilbualu2) + sq;
          separator = ',';
        endif;
        if parmsSent > 10;
          sqlStmt1 += separator + 'lbualq3='
                  + %char(ilbualq3);
          separator = ',';
        endif;
        if parmsSent > 11;
          sqlStmt1 += separator + 'lbualu3='
                  + sq + %trimr(ilbualu3) + sq;
          separator = ',';
        endif;
        if parmsSent > 12;
          sqlStmt1 += separator + 'lbualman='
                  + %char(ilbualman);
          separator = ',';
        endif;
        if parmsSent > 13;
          sqlStmt1 += separator + 'lbualmab1='
                  + %char(ilbualmab1);
          separator = ',';
        endif;
        if parmsSent > 14;
          sqlStmt1 += separator + 'lbualmab2='
                  + %char(ilbualmab2);
          separator = ',';
        endif;
        if parmsSent > 15;
          sqlStmt1 += separator + 'lbualmrn='
                  + %char(ilbualmrn);
          separator = ',';
        endif;
        if parmsSent > 16;
          sqlStmt1 += separator + 'lbualmrb1='
                  + %char(ilbualmrb1);
          separator = ',';
        endif;
        if parmsSent > 17;
          sqlStmt1 += separator + 'lbualmrb2='
                  + %char(ilbualmrb2);
          separator = ',';
        endif;
        if parmsSent > 18;
          sqlStmt1 += separator + 'lbupkq1='
                  + %char(ilbupkq1);
          separator = ',';
        endif;
        if parmsSent > 19;
          sqlStmt1 += separator + 'lbupku1='
                  + sq + %trimr(ilbupku1) + sq;
          separator = ',';
        endif;
        if parmsSent > 20;
          sqlStmt1 += separator + 'lbupkq2='
                  + %char(ilbupkq2);
          separator = ',';
        endif;
        if parmsSent > 21;
          sqlStmt1 += separator + 'lbupku2='
                  + sq + %trimr(ilbupku2) + sq;
          separator = ',';
        endif;
        if parmsSent > 22;
          sqlStmt1 += separator + 'lbupkq3='
                  + %char(ilbupkq3);
          separator = ',';
        endif;
        if parmsSent > 23;
          sqlStmt1 += separator + 'lbupku3='
                  + sq + %trimr(ilbupku3) + sq;
          separator = ',';
        endif;
        if parmsSent > 24;
          sqlStmt1 += separator + 'lbupkman='
                  + %char(ilbupkman);
          separator = ',';
        endif;
        if parmsSent > 25;
          sqlStmt1 += separator + 'lbupkmab1='
                  + %char(ilbupkmab1);
          separator = ',';
        endif;
        if parmsSent > 26;
          sqlStmt1 += separator + 'lbupkmab2='
                  + %char(ilbupkmab2);
          separator = ',';
        endif;
        if parmsSent > 27;
          sqlStmt1 += separator + 'lbupkmrn='
                  + %char(ilbupkmrn);
          separator = ',';
        endif;
        if parmsSent > 28;
          sqlStmt1 += separator + 'lbupkmrb1='
                  + %char(ilbupkmrb1);
          separator = ',';
        endif;
        if parmsSent > 29;
          sqlStmt1 += separator + 'lbupkmrb2='
                  + %char(ilbupkmrb2);
          separator = ',';
        endif;

        sqlStmt1 += ') ';

        sqlStmt1 += 'where ';

        sqlStmt1 += 'ilbuwhse='
                + %char(ilbuwhse);

        sqlStmt1 += ' and ilbulbl#='
                + sq + %char(ilbulbl#) + sq;

        exec sql execute immediate :sqlStmt1;


        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ilbuwhse) + '/' + %char(ilbulbl#)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoDelete    Delete record
     *----------------------------------------------------------------

     p DoDelete        b
     d DoDelete        pi

     * Local Variables

     d count           s              1  0

      /free

        exec sql
          delete from labelum
          where lbuwhse = :ilbuwhse
            and lbulbl# = :ilbulbl#;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ilbuwhse) + '/' + %char(ilbulbl#)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoGet   Get record
     *----------------------------------------------------------------

     p DoGet           b
     d DoGet           pi

      /free

        exec sql select lbuwhse,
                        lbulbl#,
                        lbufpflg,
                        lbualq1,
                        lbualu1,
                        lbualq2,
                        lbualu2,
                        lbualq3,
                        lbualu3,
                        lbualman,
                        lbualmab1,
                        lbualmab2,
                        lbualmrn,
                        lbualmrb1,
                        lbualmrb2,
                        lbupkq1,
                        lbupku1,
                        lbupkq2,
                        lbupku2,
                        lbupkq3,
                        lbupku3,
                        lbupkman,
                        lbupkmab1,
                        lbupkmab2,
                        lbupkmrn,
                        lbupkmrb1,
                        lbupkmrb2

                 into   :lbuwhse,
                        :lbulbl#,
                        :lbufpflg,
                        :lbualq1,
                        :lbualu1,
                        :lbualq2,
                        :lbualu2,
                        :lbualq3,
                        :lbualu3,
                        :lbualman,
                        :lbualmab1,
                        :lbualmab2,
                        :lbualmrn,
                        :lbualmrb1,
                        :lbualmrb2,
                        :lbupkq1,
                        :lbupku1,
                        :lbupkq2,
                        :lbupku2,
                        :lbupkq3,
                        :lbupku3,
                        :lbupkman,
                        :lbupkmab1,
                        :lbupkmab2,
                        :lbupkmrn,
                        :lbupkmrb1,
                        :lbupkmrb2

                 from labelum
                 where lbuwhse = :ilbuwhse
                   and lbulbl# = :ilbulbl#;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ilbuwhse) + '/' + %char(ilbulbl#)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear lburec;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  Move        Move fields to/from between parameters and record
     *----------------------------------------------------------------

     p Move            b
     d Move            pi
     d  direction                    10    const

      /free

       if direction = 'ParmsToRec';
         clear lburec;
         lbuwhse = ilbuwhse;
         lbulbl# = ilbulbl#;
       endif;

        if parmsSent > 5;
          if direction = 'ParmsToRec';
            lbufpflg = ilbufpflg;
          else;
            ilbufpflg = lbufpflg;
          endif;
        endif;
        if parmsSent > 6;
          if direction = 'ParmsToRec';
            lbualq1 = ilbualq1;
          else;
            ilbualq1 = lbualq1;
          endif;
        endif;
        if parmsSent > 7;
          if direction = 'ParmsToRec';
            lbualu1 = ilbualu1;
          else;
            ilbualu1 = lbualu1;
          endif;
        endif;
        if parmsSent > 8;
          if direction = 'ParmsToRec';
            lbualq2 = ilbualq2;
          else;
            ilbualq2 = lbualq2;
          endif;
        endif;
        if parmsSent > 9;
          if direction = 'ParmsToRec';
            lbualu2 = ilbualu2;
          else;
            ilbualu2 = lbualu2;
          endif;
        endif;
        if parmsSent > 10;
          if direction = 'ParmsToRec';
            lbualq3 = ilbualq3;
          else;
            ilbualq3 = lbualq3;
          endif;
        endif;
        if parmsSent > 11;
          if direction = 'ParmsToRec';
            lbualu3 = ilbualu3;
          else;
            ilbualu3 = lbualu3;
          endif;
        endif;
        if parmsSent > 12;
          if direction = 'ParmsToRec';
            lbualman = ilbualman;
          else;
            ilbualman = lbualman;
          endif;
        endif;
        if parmsSent > 13;
          if direction = 'ParmsToRec';
            lbualmab1 = ilbualmab1;
          else;
            ilbualmab1 = lbualmab1;
          endif;
        endif;
        if parmsSent > 14;
          if direction = 'ParmsToRec';
            lbualmab2 = ilbualmab2;
          else;
            ilbualmab2 = lbualmab2;
          endif;
        endif;
        if parmsSent > 15;
          if direction = 'ParmsToRec';
            lbualmrn = ilbualmrn;
          else;
            ilbualmrn = lbualmrn;
          endif;
        endif;
        if parmsSent > 16;
          if direction = 'ParmsToRec';
            lbualmrb1 = ilbualmrb1;
          else;
            ilbualmrb1 = lbualmrb1;
          endif;
        endif;
        if parmsSent > 17;
          if direction = 'ParmsToRec';
            lbualmrb2 = ilbualmrb2;
          else;
            ilbualmrb2 = lbualmrb2;
          endif;
        endif;
        if parmsSent > 18;
          if direction = 'ParmsToRec';
            lbupkq1 = ilbupkq1;
          else;
            ilbupkq1 = lbupkq1;
          endif;
        endif;
        if parmsSent > 19;
          if direction = 'ParmsToRec';
            lbupku1 = ilbupku1;
          else;
            ilbupku1 = lbupku1;
          endif;
        endif;
        if parmsSent > 20;
          if direction = 'ParmsToRec';
            lbupkq2 = ilbupkq2;
          else;
            ilbupkq2 = lbupkq2;
          endif;
        endif;
        if parmsSent > 21;
          if direction = 'ParmsToRec';
            lbupku2 = ilbupku2;
          else;
            ilbupku2 = lbupku2;
          endif;
        endif;
        if parmsSent > 22;
          if direction = 'ParmsToRec';
            lbupkq3 = ilbupkq3;
          else;
            ilbupkq3 = lbupkq3;
          endif;
        endif;
        if parmsSent > 23;
          if direction = 'ParmsToRec';
            lbupku3 = ilbupku3;
          else;
            ilbupku3 = lbupku3;
          endif;
        endif;
        if parmsSent > 24;
          if direction = 'ParmsToRec';
            lbupkman = ilbupkman;
          else;
            ilbupkman = lbupkman;
          endif;
        endif;
        if parmsSent > 25;
          if direction = 'ParmsToRec';
            lbupkmab1 = ilbupkmab1;
          else;
            ilbupkmab1 = lbupkmab1;
          endif;
        endif;
        if parmsSent > 26;
          if direction = 'ParmsToRec';
            lbupkmab2 = ilbupkmab2;
          else;
            ilbupkmab2 = lbupkmab2;
          endif;
        endif;
        if parmsSent > 27;
          if direction = 'ParmsToRec';
            lbupkmrn = ilbupkmrn;
          else;
            ilbupkmrn = lbupkmrn;
          endif;
        endif;
        if parmsSent > 28;
          if direction = 'ParmsToRec';
            lbupkmrb1 = ilbupkmrb1;
          else;
            ilbupkmrb1 = lbupkmrb1;
          endif;
        endif;
        if parmsSent > 29;
          if direction = 'ParmsToRec';
            lbupkmrb2 = ilbupkmrb2;
          else;
            ilbupkmrb2 = lbupkmrb2;
          endif;
        endif;

      /end-free

     p                 e

