      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UMWORKLBL    WORKLBLUM file operations
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
     d lwurec        e ds                  extname(worklblum) inz(*EXTDFT)

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

     d UMWORKLBL       pr                  extpgm('UMWORKLBL')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilwuwhse                            like(lwuwhse)
     d  ilwulbl#                            like(lwulbl#)
     d  ilwufpflg                           like(lwufpflg) options(*nopass)
     d  ilwualq1                            like(lwualq1) options(*nopass)
     d  ilwualu1                            like(lwualu1) options(*nopass)
     d  ilwualq2                            like(lwualq2) options(*nopass)
     d  ilwualu2                            like(lwualu2) options(*nopass)
     d  ilwualq3                            like(lwualq3) options(*nopass)
     d  ilwualu3                            like(lwualu3) options(*nopass)
     d  ilwualman                           like(lwualman) options(*nopass)
     d  ilwualmab1                          like(lwualmab1) options(*nopass)
     d  ilwualmab2                          like(lwualmab2) options(*nopass)
     d  ilwualmrn                           like(lwualmrn) options(*nopass)
     d  ilwualmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwualmrb2                          like(lwualmrb2) options(*nopass)
     d  ilwupkq1                            like(lwualq1) options(*nopass)
     d  ilwupku1                            like(lwualu1) options(*nopass)
     d  ilwupkq2                            like(lwualq2) options(*nopass)
     d  ilwupku2                            like(lwualu2) options(*nopass)
     d  ilwupkq3                            like(lwualq3) options(*nopass)
     d  ilwupku3                            like(lwualu3) options(*nopass)
     d  ilwupkman                           like(lwualman) options(*nopass)
     d  ilwupkmab1                          like(lwualmab1) options(*nopass)
     d  ilwupkmab2                          like(lwualmab2) options(*nopass)
     d  ilwupkmrn                           like(lwualmrn) options(*nopass)
     d  ilwupkmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwupkmrb2                          like(lwualmrb2) options(*nopass)

     d UMWORKLBL       pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilwuwhse                            like(lwuwhse)
     d  ilwulbl#                            like(lwulbl#)
     d  ilwufpflg                           like(lwufpflg) options(*nopass)
     d  ilwualq1                            like(lwualq1) options(*nopass)
     d  ilwualu1                            like(lwualu1) options(*nopass)
     d  ilwualq2                            like(lwualq2) options(*nopass)
     d  ilwualu2                            like(lwualu2) options(*nopass)
     d  ilwualq3                            like(lwualq3) options(*nopass)
     d  ilwualu3                            like(lwualu3) options(*nopass)
     d  ilwualman                           like(lwualman) options(*nopass)
     d  ilwualmab1                          like(lwualmab1) options(*nopass)
     d  ilwualmab2                          like(lwualmab2) options(*nopass)
     d  ilwualmrn                           like(lwualmrn) options(*nopass)
     d  ilwualmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwualmrb2                          like(lwualmrb2) options(*nopass)
     d  ilwupkq1                            like(lwualq1) options(*nopass)
     d  ilwupku1                            like(lwualu1) options(*nopass)
     d  ilwupkq2                            like(lwualq2) options(*nopass)
     d  ilwupku2                            like(lwualu2) options(*nopass)
     d  ilwupkq3                            like(lwualq3) options(*nopass)
     d  ilwupku3                            like(lwualu3) options(*nopass)
     d  ilwupkman                           like(lwualman) options(*nopass)
     d  ilwupkmab1                          like(lwualmab1) options(*nopass)
     d  ilwupkmab2                          like(lwualmab2) options(*nopass)
     d  ilwupkmrn                           like(lwualmrn) options(*nopass)
     d  ilwupkmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwupkmrb2                          like(lwualmrb2) options(*nopass)

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

        sqlStmt1 = 'insert into worklblum (';
        sqlStmt2 = 'values (';

        sqlStmt1 += 'lwuwhse';
        sqlStmt2 += %char(ilwuwhse);

        sqlStmt1 += ',lwulbl#';
        sqlStmt2 += ',' + %char(ilwulbl#);

        if parmsSent > 5;
          sqlStmt1 += ',lwufpflg';
          sqlStmt2 += ',' + sq + %trimr(ilwufpflg) + sq;
        endif;
        if parmsSent > 6;
          sqlStmt1 += ',lwualq1';
          sqlStmt2 += ',' + %char(ilwualq1);
        endif;
        if parmsSent > 7;
          sqlStmt1 += ',lwualu1';
          sqlStmt2 += ',' + sq + %trimr(ilwualu1) + sq;
        endif;
        if parmsSent > 8;
          sqlStmt1 += ',lwualq2';
          sqlStmt2 += ',' + %char(ilwualq2);
        endif;
        if parmsSent > 9;
          sqlStmt1 += ',lwualu2';
          sqlStmt2 += ',' + sq + %trimr(ilwualu2) + sq;
        endif;
        if parmsSent > 10;
          sqlStmt1 += ',lwualq3';
          sqlStmt2 += ',' + %char(ilwualq3);
        endif;
        if parmsSent > 11;
          sqlStmt1 += ',lwualu3';
          sqlStmt2 += ',' + sq + %trimr(ilwualu3) + sq;
        endif;
        if parmsSent > 12;
          sqlStmt1 += ',lwualman';
          sqlStmt2 += ',' + %char(ilwualman);
        endif;
        if parmsSent > 13;
          sqlStmt1 += ',lwualmab1';
          sqlStmt2 += ',' + %char(ilwualmab1);
        endif;
        if parmsSent > 14;
          sqlStmt1 += ',lwualmab2';
          sqlStmt2 += ',' + %char(ilwualmab2);
        endif;
        if parmsSent > 15;
          sqlStmt1 += ',lwualmrn';
          sqlStmt2 += ',' + %char(ilwualmrn);
        endif;
        if parmsSent > 16;
          sqlStmt1 += ',lwualmrb1';
          sqlStmt2 += ',' + %char(ilwualmrb1);
        endif;
        if parmsSent > 17;
          sqlStmt1 += ',lwualmrb2';
          sqlStmt2 += ',' + %char(ilwualmrb2);
        endif;
        if parmsSent > 18;
          sqlStmt1 += ',lwupkq1';
          sqlStmt2 += ',' + %char(ilwupkq1);
        endif;
        if parmsSent > 19;
          sqlStmt1 += ',lwupku1';
          sqlStmt2 += ',' + sq + %trimr(ilwupku1) + sq;
        endif;
        if parmsSent > 20;
          sqlStmt1 += ',lwupkq2';
          sqlStmt2 += ',' + %char(ilwupkq2);
        endif;
        if parmsSent > 21;
          sqlStmt1 += ',lwupku2';
          sqlStmt2 += ',' + sq + %trimr(ilwupku2) + sq;
        endif;
        if parmsSent > 22;
          sqlStmt1 += ',lwupkq3';
          sqlStmt2 += ',' + %char(ilwupkq3);
        endif;
        if parmsSent > 23;
          sqlStmt1 += ',lwupku3';
          sqlStmt2 += ',' + sq + %trimr(ilwupku3) + sq;
        endif;
        if parmsSent > 24;
          sqlStmt1 += ',lwupkman';
          sqlStmt2 += ',' + %char(ilwupkman);
        endif;
        if parmsSent > 25;
          sqlStmt1 += ',lwupkmab1';
          sqlStmt2 += ',' + %char(ilwupkmab1);
        endif;
        if parmsSent > 26;
          sqlStmt1 += ',lwupkmab2';
          sqlStmt2 += ',' + %char(ilwupkmab2);
        endif;
        if parmsSent > 27;
          sqlStmt1 += ',lwupkmrn';
          sqlStmt2 += ',' + %char(ilwupkmrn);
        endif;
        if parmsSent > 28;
          sqlStmt1 += ',lwupkmrb1';
          sqlStmt2 += ',' + %char(ilwupkmrb1);
        endif;
        if parmsSent > 29;
          sqlStmt1 += ',lwupkmrb2';
          sqlStmt2 += ',' + %char(ilwupkmrb2);
        endif;

        sqlStmt1 += ') ';
        sqlStmt2 += ') ';

        sqlStmt1 += sqlStmt2;

        exec sql execute immediate :sqlStmt1;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ilwuwhse) + '/' + %char(ilwulbl#)
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

        sqlStmt1 = 'update worklblum set ';
        separator = '';

        if parmsSent > 5;
          sqlStmt1 += 'lwufpflg='
                  + sq + %trimr(ilwufpflg) + sq;
          separator = ',';
        endif;
        if parmsSent > 6;
          sqlStmt1 += separator + 'lwualq1='
                  + %char(ilwualq1);
          separator = ',';
        endif;
        if parmsSent > 7;
          sqlStmt1 += separator + 'lwualu1='
                  + sq + %trimr(ilwualu1) + sq;
          separator = ',';
        endif;
        if parmsSent > 8;
          sqlStmt1 += separator + 'lwualq2='
                  + %char(ilwualq2);
          separator = ',';
        endif;
        if parmsSent > 9;
          sqlStmt1 += separator + 'lwualu2='
                  + sq + %trimr(ilwualu2) + sq;
          separator = ',';
        endif;
        if parmsSent > 10;
          sqlStmt1 += separator + 'lwualq3='
                  + %char(ilwualq3);
          separator = ',';
        endif;
        if parmsSent > 11;
          sqlStmt1 += separator + 'lwualu3='
                  + sq + %trimr(ilwualu3) + sq;
          separator = ',';
        endif;
        if parmsSent > 12;
          sqlStmt1 += separator + 'lwualman='
                  + %char(ilwualman);
          separator = ',';
        endif;
        if parmsSent > 13;
          sqlStmt1 += separator + 'lwualmab1='
                  + %char(ilwualmab1);
          separator = ',';
        endif;
        if parmsSent > 14;
          sqlStmt1 += separator + 'lwualmab2='
                  + %char(ilwualmab2);
          separator = ',';
        endif;
        if parmsSent > 15;
          sqlStmt1 += separator + 'lwualmrn='
                  + %char(ilwualmrn);
          separator = ',';
        endif;
        if parmsSent > 16;
          sqlStmt1 += separator + 'lwualmrb1='
                  + %char(ilwualmrb1);
          separator = ',';
        endif;
        if parmsSent > 17;
          sqlStmt1 += separator + 'lwualmrb2='
                  + %char(ilwualmrb2);
          separator = ',';
        endif;
        if parmsSent > 18;
          sqlStmt1 += separator + 'lwupkq1='
                  + %char(ilwupkq1);
          separator = ',';
        endif;
        if parmsSent > 19;
          sqlStmt1 += separator + 'lwupku1='
                  + sq + %trimr(ilwupku1) + sq;
          separator = ',';
        endif;
        if parmsSent > 20;
          sqlStmt1 += separator + 'lwupkq2='
                  + %char(ilwupkq2);
          separator = ',';
        endif;
        if parmsSent > 21;
          sqlStmt1 += separator + 'lwupku2='
                  + sq + %trimr(ilwupku2) + sq;
          separator = ',';
        endif;
        if parmsSent > 22;
          sqlStmt1 += separator + 'lwupkq3='
                  + %char(ilwupkq3);
          separator = ',';
        endif;
        if parmsSent > 23;
          sqlStmt1 += separator + 'lwupku3='
                  + sq + %trimr(ilwupku3) + sq;
          separator = ',';
        endif;
        if parmsSent > 24;
          sqlStmt1 += separator + 'lwupkman='
                  + %char(ilwupkman);
          separator = ',';
        endif;
        if parmsSent > 25;
          sqlStmt1 += separator + 'lwupkmab1='
                  + %char(ilwupkmab1);
          separator = ',';
        endif;
        if parmsSent > 26;
          sqlStmt1 += separator + 'lwupkmab2='
                  + %char(ilwupkmab2);
          separator = ',';
        endif;
        if parmsSent > 27;
          sqlStmt1 += separator + 'lwupkmrn='
                  + %char(ilwupkmrn);
          separator = ',';
        endif;
        if parmsSent > 28;
          sqlStmt1 += separator + 'lwupkmrb1='
                  + %char(ilwupkmrb1);
          separator = ',';
        endif;
        if parmsSent > 29;
          sqlStmt1 += separator + 'lwupkmrb2='
                  + %char(ilwupkmrb2);
          separator = ',';
        endif;

        sqlStmt1 += ') ';

        sqlStmt1 += 'where ';

        sqlStmt1 += 'lwuwhse='
                + %char(ilwuwhse);

        sqlStmt1 += ' and lwulbl#='
                + sq + %char(ilwulbl#) + sq;

        exec sql execute immediate :sqlStmt1;


        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ilwuwhse) + '/' + %char(ilwulbl#)
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
          delete from worklblum
          where lwuwhse = :ilwuwhse
            and lwulbl# = :ilwulbl#;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ilwuwhse) + '/' + %char(ilwulbl#)
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

        exec sql select lwuwhse,
                        lwulbl#,
                        lwufpflg,
                        lwualq1,
                        lwualu1,
                        lwualq2,
                        lwualu2,
                        lwualq3,
                        lwualu3,
                        lwualman,
                        lwualmab1,
                        lwualmab2,
                        lwualmrn,
                        lwualmrb1,
                        lwualmrb2,
                        lwupkq1,
                        lwupku1,
                        lwupkq2,
                        lwupku2,
                        lwupkq3,
                        lwupku3,
                        lwupkman,
                        lwupkmab1,
                        lwupkmab2,
                        lwupkmrn,
                        lwupkmrb1,
                        lwupkmrb2

                 into   :lwuwhse,
                        :lwulbl#,
                        :lwufpflg,
                        :lwualq1,
                        :lwualu1,
                        :lwualq2,
                        :lwualu2,
                        :lwualq3,
                        :lwualu3,
                        :lwualman,
                        :lwualmab1,
                        :lwualmab2,
                        :lwualmrn,
                        :lwualmrb1,
                        :lwualmrb2,
                        :lwupkq1,
                        :lwupku1,
                        :lwupkq2,
                        :lwupku2,
                        :lwupkq3,
                        :lwupku3,
                        :lwupkman,
                        :lwupkmab1,
                        :lwupkmab2,
                        :lwupkmrn,
                        :lwupkmrb1,
                        :lwupkmrb2

                 from worklblum
                 where lwuwhse = :ilwuwhse
                   and lwulbl# = :ilwulbl#;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ilwuwhse) + '/' + %char(ilwulbl#)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear lwurec;
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
         clear lwurec;
         lwuwhse = ilwuwhse;
         lwulbl# = ilwulbl#;
       endif;

        if parmsSent > 5;
          if direction = 'ParmsToRec';
            lwufpflg = ilwufpflg;
          else;
            ilwufpflg = lwufpflg;
          endif;
        endif;
        if parmsSent > 6;
          if direction = 'ParmsToRec';
            lwualq1 = ilwualq1;
          else;
            ilwualq1 = lwualq1;
          endif;
        endif;
        if parmsSent > 7;
          if direction = 'ParmsToRec';
            lwualu1 = ilwualu1;
          else;
            ilwualu1 = lwualu1;
          endif;
        endif;
        if parmsSent > 8;
          if direction = 'ParmsToRec';
            lwualq2 = ilwualq2;
          else;
            ilwualq2 = lwualq2;
          endif;
        endif;
        if parmsSent > 9;
          if direction = 'ParmsToRec';
            lwualu2 = ilwualu2;
          else;
            ilwualu2 = lwualu2;
          endif;
        endif;
        if parmsSent > 10;
          if direction = 'ParmsToRec';
            lwualq3 = ilwualq3;
          else;
            ilwualq3 = lwualq3;
          endif;
        endif;
        if parmsSent > 11;
          if direction = 'ParmsToRec';
            lwualu3 = ilwualu3;
          else;
            ilwualu3 = lwualu3;
          endif;
        endif;
        if parmsSent > 12;
          if direction = 'ParmsToRec';
            lwualman = ilwualman;
          else;
            ilwualman = lwualman;
          endif;
        endif;
        if parmsSent > 13;
          if direction = 'ParmsToRec';
            lwualmab1 = ilwualmab1;
          else;
            ilwualmab1 = lwualmab1;
          endif;
        endif;
        if parmsSent > 14;
          if direction = 'ParmsToRec';
            lwualmab2 = ilwualmab2;
          else;
            ilwualmab2 = lwualmab2;
          endif;
        endif;
        if parmsSent > 15;
          if direction = 'ParmsToRec';
            lwualmrn = ilwualmrn;
          else;
            ilwualmrn = lwualmrn;
          endif;
        endif;
        if parmsSent > 16;
          if direction = 'ParmsToRec';
            lwualmrb1 = ilwualmrb1;
          else;
            ilwualmrb1 = lwualmrb1;
          endif;
        endif;
        if parmsSent > 17;
          if direction = 'ParmsToRec';
            lwualmrb2 = ilwualmrb2;
          else;
            ilwualmrb2 = lwualmrb2;
          endif;
        endif;
        if parmsSent > 18;
          if direction = 'ParmsToRec';
            lwupkq1 = ilwupkq1;
          else;
            ilwupkq1 = lwupkq1;
          endif;
        endif;
        if parmsSent > 19;
          if direction = 'ParmsToRec';
            lwupku1 = ilwupku1;
          else;
            ilwupku1 = lwupku1;
          endif;
        endif;
        if parmsSent > 20;
          if direction = 'ParmsToRec';
            lwupkq2 = ilwupkq2;
          else;
            ilwupkq2 = lwupkq2;
          endif;
        endif;
        if parmsSent > 21;
          if direction = 'ParmsToRec';
            lwupku2 = ilwupku2;
          else;
            ilwupku2 = lwupku2;
          endif;
        endif;
        if parmsSent > 22;
          if direction = 'ParmsToRec';
            lwupkq3 = ilwupkq3;
          else;
            ilwupkq3 = lwupkq3;
          endif;
        endif;
        if parmsSent > 23;
          if direction = 'ParmsToRec';
            lwupku3 = ilwupku3;
          else;
            ilwupku3 = lwupku3;
          endif;
        endif;
        if parmsSent > 24;
          if direction = 'ParmsToRec';
            lwupkman = ilwupkman;
          else;
            ilwupkman = lwupkman;
          endif;
        endif;
        if parmsSent > 25;
          if direction = 'ParmsToRec';
            lwupkmab1 = ilwupkmab1;
          else;
            ilwupkmab1 = lwupkmab1;
          endif;
        endif;
        if parmsSent > 26;
          if direction = 'ParmsToRec';
            lwupkmab2 = ilwupkmab2;
          else;
            ilwupkmab2 = lwupkmab2;
          endif;
        endif;
        if parmsSent > 27;
          if direction = 'ParmsToRec';
            lwupkmrn = ilwupkmrn;
          else;
            ilwupkmrn = lwupkmrn;
          endif;
        endif;
        if parmsSent > 28;
          if direction = 'ParmsToRec';
            lwupkmrb1 = ilwupkmrb1;
          else;
            ilwupkmrb1 = lwupkmrb1;
          endif;
        endif;
        if parmsSent > 29;
          if direction = 'ParmsToRec';
            lwupkmrb2 = ilwupkmrb2;
          else;
            ilwupkmrb2 = lwupkmrb2;
          endif;
        endif;

      /end-free

     p                 e

