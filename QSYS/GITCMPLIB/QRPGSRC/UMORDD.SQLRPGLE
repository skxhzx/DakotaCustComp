      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UMORDD    ORDDUM file operations
     *  12 August 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
720aA*   08/12/19  DAS  7.30
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
     d odurec        e ds                  extname(orddum) inz(*EXTDFT)

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
     *  iohawhse  - Warehouse
     *  iohaord   - Order number
     *  iohaaudflg - Audit flag
     *  iohaaudid  - Audit id
     *  iohaaudcmp - Audit completed flag
     *  iohaaudby  - Audit completed by employee number
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d UMORDD          pr                  extpgm('UMORDD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ioduwhse                            like(oduwhse)
     d  ioduord                             like(oduord)
     d  ioduseq                             like(oduseq)
     d  ioduitem                            like(oduitem)
     d  iodufpflg                           like(odufpflg) options(*nopass)
     d  ioduorq1                            like(oduorq1) options(*nopass)
     d  ioduoru1                            like(oduoru1) options(*nopass)
     d  ioduorq2                            like(oduorq2) options(*nopass)
     d  ioduoru2                            like(oduoru2) options(*nopass)
     d  ioduorq3                            like(oduorq3) options(*nopass)
     d  ioduoru3                            like(oduoru3) options(*nopass)
     d  ioduorman                           like(oduorman) options(*nopass)
     d  ioduormab1                          like(oduormab1) options(*nopass)
     d  ioduormab2                          like(oduormab2) options(*nopass)
     d  ioduormrn                           like(oduormrn) options(*nopass)
     d  ioduormrb1                          like(oduormrb1) options(*nopass)
     d  ioduormrb2                          like(oduormrb2) options(*nopass)
     d  iodupkq1                            like(oduorq1) options(*nopass)
     d  iodupku1                            like(oduoru1) options(*nopass)
     d  iodupkq2                            like(oduorq2) options(*nopass)
     d  iodupku2                            like(oduoru2) options(*nopass)
     d  iodupkq3                            like(oduorq3) options(*nopass)
     d  iodupku3                            like(oduoru3) options(*nopass)
     d  iodupkman                           like(oduorman) options(*nopass)
     d  iodupkmab1                          like(oduormab1) options(*nopass)
     d  iodupkmab2                          like(oduormab2) options(*nopass)
     d  iodupkmrn                           like(oduormrn) options(*nopass)
     d  iodupkmrb1                          like(oduormrb1) options(*nopass)
     d  iodupkmrb2                          like(oduormrb2) options(*nopass)

     d UMORDD          pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ioduwhse                            like(oduwhse)
     d  ioduord                             like(oduord)
     d  ioduseq                             like(oduseq)
     d  ioduitem                            like(oduitem)
     d  iodufpflg                           like(odufpflg) options(*nopass)
     d  ioduorq1                            like(oduorq1) options(*nopass)
     d  ioduoru1                            like(oduoru1) options(*nopass)
     d  ioduorq2                            like(oduorq2) options(*nopass)
     d  ioduoru2                            like(oduoru2) options(*nopass)
     d  ioduorq3                            like(oduorq3) options(*nopass)
     d  ioduoru3                            like(oduoru3) options(*nopass)
     d  ioduorman                           like(oduorman) options(*nopass)
     d  ioduormab1                          like(oduormab1) options(*nopass)
     d  ioduormab2                          like(oduormab2) options(*nopass)
     d  ioduormrn                           like(oduormrn) options(*nopass)
     d  ioduormrb1                          like(oduormrb1) options(*nopass)
     d  ioduormrb2                          like(oduormrb2) options(*nopass)
     d  iodupkq1                            like(oduorq1) options(*nopass)
     d  iodupku1                            like(oduoru1) options(*nopass)
     d  iodupkq2                            like(oduorq2) options(*nopass)
     d  iodupku2                            like(oduoru2) options(*nopass)
     d  iodupkq3                            like(oduorq3) options(*nopass)
     d  iodupku3                            like(oduoru3) options(*nopass)
     d  iodupkman                           like(oduorman) options(*nopass)
     d  iodupkmab1                          like(oduormab1) options(*nopass)
     d  iodupkmab2                          like(oduormab2) options(*nopass)
     d  iodupkmrn                           like(oduormrn) options(*nopass)
     d  iodupkmrb1                          like(oduormrb1) options(*nopass)
     d  iodupkmrb2                          like(oduormrb2) options(*nopass)

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

        sqlStmt1 = 'insert into orddum (';
        sqlStmt2 = 'values (';

        sqlStmt1 += 'oduwhse';
        sqlStmt2 += %char(ioduwhse);

        sqlStmt1 += ',oduord';
        sqlStmt2 += ',' + %char(ioduord);

        sqlStmt1 += ',oduseq';
        sqlStmt2 += ',' + %char(ioduseq);

        sqlStmt1 += ',oduitem';
        sqlStmt2 += ',' + sq + %trimr(ioduitem) + sq;

        if parmsSent > 7;
          sqlStmt1 += ',odufpflg';
          sqlStmt2 += ',' + sq + %trimr(iodufpflg) + sq;
        endif;
        if parmsSent > 8;
          sqlStmt1 += ',oduorq1';
          sqlStmt2 += ',' + %char(ioduorq1);
        endif;
        if parmsSent > 9;
          sqlStmt1 += ',oduoru1';
          sqlStmt2 += ',' + sq + %trimr(ioduoru1) + sq;
        endif;
        if parmsSent > 10;
          sqlStmt1 += ',oduorq2';
          sqlStmt2 += ',' + %char(ioduorq2);
        endif;
        if parmsSent > 11;
          sqlStmt1 += ',oduoru2';
          sqlStmt2 += ',' + sq + %trimr(ioduoru2) + sq;
        endif;
        if parmsSent > 12;
          sqlStmt1 += ',oduorq3';
          sqlStmt2 += ',' + %char(ioduorq3);
        endif;
        if parmsSent > 13;
          sqlStmt1 += ',oduoru3';
          sqlStmt2 += ',' + sq + %trimr(ioduoru3) + sq;
        endif;
        if parmsSent > 14;
          sqlStmt1 += ',oduorman';
          sqlStmt2 += ',' + %char(ioduorman);
        endif;
        if parmsSent > 15;
          sqlStmt1 += ',oduormab1';
          sqlStmt2 += ',' + %char(ioduormab1);
        endif;
        if parmsSent > 16;
          sqlStmt1 += ',oduormab2';
          sqlStmt2 += ',' + %char(ioduormab2);
        endif;
        if parmsSent > 17;
          sqlStmt1 += ',oduormrn';
          sqlStmt2 += ',' + %char(ioduormrn);
        endif;
        if parmsSent > 18;
          sqlStmt1 += ',oduormrb1';
          sqlStmt2 += ',' + %char(ioduormrb1);
        endif;
        if parmsSent > 19;
          sqlStmt1 += ',oduormrb2';
          sqlStmt2 += ',' + %char(ioduormrb2);
        endif;
        if parmsSent > 20;
          sqlStmt1 += ',odupkq1';
          sqlStmt2 += ',' + %char(iodupkq1);
        endif;
        if parmsSent > 21;
          sqlStmt1 += ',odupku1';
          sqlStmt2 += ',' + sq + %trimr(iodupku1) + sq;
        endif;
        if parmsSent > 22;
          sqlStmt1 += ',odupkq2';
          sqlStmt2 += ',' + %char(iodupkq2);
        endif;
        if parmsSent > 23;
          sqlStmt1 += ',odupku2';
          sqlStmt2 += ',' + sq + %trimr(iodupku2) + sq;
        endif;
        if parmsSent > 24;
          sqlStmt1 += ',odupkq3';
          sqlStmt2 += ',' + %char(iodupkq3);
        endif;
        if parmsSent > 25;
          sqlStmt1 += ',odupku3';
          sqlStmt2 += ',' + sq + %trimr(iodupku3) + sq;
        endif;
        if parmsSent > 26;
          sqlStmt1 += ',odupkman';
          sqlStmt2 += ',' + %char(iodupkman);
        endif;
        if parmsSent > 27;
          sqlStmt1 += ',odupkmab1';
          sqlStmt2 += ',' + %char(iodupkmab1);
        endif;
        if parmsSent > 28;
          sqlStmt1 += ',odupkmab2';
          sqlStmt2 += ',' + %char(iodupkmab2);
        endif;
        if parmsSent > 29;
          sqlStmt1 += ',odupkmrn';
          sqlStmt2 += ',' + %char(iodupkmrn);
        endif;
        if parmsSent > 30;
          sqlStmt1 += ',odupkmrb1';
          sqlStmt2 += ',' + %char(iodupkmrb1);
        endif;
        if parmsSent > 31;
          sqlStmt1 += ',odupkmrb2';
          sqlStmt2 += ',' + %char(iodupkmrb2);
        endif;

        sqlStmt1 += ') ';
        sqlStmt2 += ') ';

        sqlStmt1 += sqlStmt2;

        exec sql execute immediate :sqlStmt1;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ioduwhse) + '/' + %char(ioduord)
                  + %char(ioduseq) + '/' + %trimr(ioduitem)
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

        sqlStmt1 = 'update orddum set ';
        separator = '';

        if parmsSent > 7;
          sqlStmt1 += 'odufpflg='
                  + sq + %trimr(iodufpflg) + sq;
          separator = ',';
        endif;
        if parmsSent > 8;
          sqlStmt1 += separator + 'oduorq1='
                  + %char(ioduorq1);
          separator = ',';
        endif;
        if parmsSent > 9;
          sqlStmt1 += separator + 'oduoru1='
                  + sq + %trimr(ioduoru1) + sq;
          separator = ',';
        endif;
        if parmsSent > 10;
          sqlStmt1 += separator + 'oduorq2='
                  + %char(ioduorq2);
          separator = ',';
        endif;
        if parmsSent > 11;
          sqlStmt1 += separator + 'oduoru2='
                  + sq + %trimr(ioduoru2) + sq;
          separator = ',';
        endif;
        if parmsSent > 12;
          sqlStmt1 += separator + 'oduorq3='
                  + %char(ioduorq3);
          separator = ',';
        endif;
        if parmsSent > 13;
          sqlStmt1 += separator + 'oduoru3='
                  + sq + %trimr(ioduoru3) + sq;
          separator = ',';
        endif;
        if parmsSent > 14;
          sqlStmt1 += separator + 'oduorman='
                  + %char(ioduorman);
          separator = ',';
        endif;
        if parmsSent > 15;
          sqlStmt1 += separator + 'oduormab1='
                  + %char(ioduormab1);
          separator = ',';
        endif;
        if parmsSent > 16;
          sqlStmt1 += separator + 'oduormab2='
                  + %char(ioduormab2);
          separator = ',';
        endif;
        if parmsSent > 17;
          sqlStmt1 += separator + 'oduormrn='
                  + %char(ioduormrn);
          separator = ',';
        endif;
        if parmsSent > 18;
          sqlStmt1 += separator + 'oduormrb1='
                  + %char(ioduormrb1);
          separator = ',';
        endif;
        if parmsSent > 19;
          sqlStmt1 += separator + 'oduormrb2='
                  + %char(ioduormrb2);
          separator = ',';
        endif;
        if parmsSent > 20;
          sqlStmt1 += separator + 'odupkq1='
                  + %char(iodupkq1);
          separator = ',';
        endif;
        if parmsSent > 21;
          sqlStmt1 += separator + 'odupku1='
                  + sq + %trimr(iodupku1) + sq;
          separator = ',';
        endif;
        if parmsSent > 22;
          sqlStmt1 += separator + 'odupkq2='
                  + %char(iodupkq2);
          separator = ',';
        endif;
        if parmsSent > 23;
          sqlStmt1 += separator + 'odupku2='
                  + sq + %trimr(iodupku2) + sq;
          separator = ',';
        endif;
        if parmsSent > 24;
          sqlStmt1 += separator + 'odupkq3='
                  + %char(iodupkq3);
          separator = ',';
        endif;
        if parmsSent > 25;
          sqlStmt1 += separator + 'odupku3='
                  + sq + %trimr(iodupku3) + sq;
          separator = ',';
        endif;
        if parmsSent > 26;
          sqlStmt1 += separator + 'odupkman='
                  + %char(iodupkman);
          separator = ',';
        endif;
        if parmsSent > 27;
          sqlStmt1 += separator + 'odupkmab1='
                  + %char(iodupkmab1);
          separator = ',';
        endif;
        if parmsSent > 28;
          sqlStmt1 += separator + 'odupkmab2='
                  + %char(iodupkmab2);
          separator = ',';
        endif;
        if parmsSent > 29;
          sqlStmt1 += separator + 'odupkmrn='
                  + %char(iodupkmrn);
          separator = ',';
        endif;
        if parmsSent > 30;
          sqlStmt1 += separator + 'odupkmrb1='
                  + %char(iodupkmrb1);
          separator = ',';
        endif;
        if parmsSent > 31;
          sqlStmt1 += separator + 'odupkmrb2='
                  + %char(iodupkmrb2);
          separator = ',';
        endif;

        sqlStmt1 += ') ';

        sqlStmt1 += 'where ';

        sqlStmt1 += 'oduwhse='
                + %char(ioduwhse);

        sqlStmt1 += ' and oduord='
                + %char(ioduord);

        sqlStmt1 += ' and oduseq='
                + %char(ioduseq);

        sqlStmt1 += ' and oduitem='
                + sq + %trimr(ioduitem) + sq;

        exec sql execute immediate :sqlStmt1;


        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ioduwhse) + '/' + %char(ioduord)
                  + %char(ioduseq) + '/' + %trimr(ioduitem)
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
          delete from orddum
          where oduwhse = :ioduwhse
            and oduord = :ioduord
            and oduseq = :ioduseq
            and oduitem = :ioduitem;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ioduwhse) + '/' + %char(ioduord)
                  + %char(ioduseq) + '/' + %trimr(ioduitem)
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

        exec sql select oduwhse,
                        oduord,
                        oduseq,
                        oduitem,
                        odufpflg,
                        oduorq1,
                        oduoru1,
                        oduorq2,
                        oduoru2,
                        oduorq3,
                        oduoru3,
                        oduorman,
                        oduormab1,
                        oduormab2,
                        oduormrn,
                        oduormrb1,
                        oduormrb2,
                        odupkq1,
                        odupku1,
                        odupkq2,
                        odupku2,
                        odupkq3,
                        odupku3,
                        odupkman,
                        odupkmab1,
                        odupkmab2,
                        odupkmrn,
                        odupkmrb1,
                        odupkmrb2

                 into   :oduwhse,
                        :oduord,
                        :oduseq,
                        :oduitem,
                        :odufpflg,
                        :oduorq1,
                        :oduoru1,
                        :oduorq2,
                        :oduoru2,
                        :oduorq3,
                        :oduoru3,
                        :oduorman,
                        :oduormab1,
                        :oduormab2,
                        :oduormrn,
                        :oduormrb1,
                        :oduormrb2,
                        :odupkq1,
                        :odupku1,
                        :odupkq2,
                        :odupku2,
                        :odupkq3,
                        :odupku3,
                        :odupkman,
                        :odupkmab1,
                        :odupkmab2,
                        :odupkmrn,
                        :odupkmrb1,
                        :odupkmrb2

                 from orddum
                 where oduwhse = :ioduwhse
                   and oduord = :ioduord
                   and oduseq = :ioduseq
                   and oduitem = :ioduitem;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ioduwhse) + '/' + %char(ioduord)
                  + %char(ioduseq) + '/' + %trimr(ioduitem)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear odurec;
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
         clear odurec;
         oduwhse = ioduwhse;
         oduord = ioduord;
         oduseq = ioduseq;
         oduitem = ioduitem;
       endif;

        if parmsSent > 7;
          if direction = 'ParmsToRec';
            odufpflg = iodufpflg;
          else;
            iodufpflg = odufpflg;
          endif;
        endif;
        if parmsSent > 8;
          if direction = 'ParmsToRec';
            oduorq1 = ioduorq1;
          else;
            ioduorq1 = oduorq1;
          endif;
        endif;
        if parmsSent > 9;
          if direction = 'ParmsToRec';
            oduoru1 = ioduoru1;
          else;
            ioduoru1 = oduoru1;
          endif;
        endif;
        if parmsSent > 10;
          if direction = 'ParmsToRec';
            oduorq2 = ioduorq2;
          else;
            ioduorq2 = oduorq2;
          endif;
        endif;
        if parmsSent > 11;
          if direction = 'ParmsToRec';
            oduoru2 = ioduoru2;
          else;
            ioduoru2 = oduoru2;
          endif;
        endif;
        if parmsSent > 12;
          if direction = 'ParmsToRec';
            oduorq3 = ioduorq3;
          else;
            ioduorq3 = oduorq3;
          endif;
        endif;
        if parmsSent > 13;
          if direction = 'ParmsToRec';
            oduoru3 = ioduoru3;
          else;
            ioduoru3 = oduoru3;
          endif;
        endif;
        if parmsSent > 14;
          if direction = 'ParmsToRec';
            oduorman = ioduorman;
          else;
            ioduorman = oduorman;
          endif;
        endif;
        if parmsSent > 15;
          if direction = 'ParmsToRec';
            oduormab1 = ioduormab1;
          else;
            ioduormab1 = oduormab1;
          endif;
        endif;
        if parmsSent > 16;
          if direction = 'ParmsToRec';
            oduormab2 = ioduormab2;
          else;
            ioduormab2 = oduormab2;
          endif;
        endif;
        if parmsSent > 17;
          if direction = 'ParmsToRec';
            oduormrn = ioduormrn;
          else;
            ioduormrn = oduormrn;
          endif;
        endif;
        if parmsSent > 18;
          if direction = 'ParmsToRec';
            oduormrb1 = ioduormrb1;
          else;
            ioduormrb1 = oduormrb1;
          endif;
        endif;
        if parmsSent > 19;
          if direction = 'ParmsToRec';
            oduormrb2 = ioduormrb2;
          else;
            ioduormrb2 = oduormrb2;
          endif;
        endif;
        if parmsSent > 20;
          if direction = 'ParmsToRec';
            odupkq1 = iodupkq1;
          else;
            iodupkq1 = odupkq1;
          endif;
        endif;
        if parmsSent > 21;
          if direction = 'ParmsToRec';
            odupku1 = iodupku1;
          else;
            iodupku1 = odupku1;
          endif;
        endif;
        if parmsSent > 22;
          if direction = 'ParmsToRec';
            odupkq2 = iodupkq2;
          else;
            iodupkq2 = odupkq2;
          endif;
        endif;
        if parmsSent > 23;
          if direction = 'ParmsToRec';
            odupku2 = iodupku2;
          else;
            iodupku2 = odupku2;
          endif;
        endif;
        if parmsSent > 24;
          if direction = 'ParmsToRec';
            odupkq3 = iodupkq3;
          else;
            iodupkq3 = odupkq3;
          endif;
        endif;
        if parmsSent > 25;
          if direction = 'ParmsToRec';
            odupku3 = iodupku3;
          else;
            iodupku3 = odupku3;
          endif;
        endif;
        if parmsSent > 26;
          if direction = 'ParmsToRec';
            odupkman = iodupkman;
          else;
            iodupkman = odupkman;
          endif;
        endif;
        if parmsSent > 27;
          if direction = 'ParmsToRec';
            odupkmab1 = iodupkmab1;
          else;
            iodupkmab1 = odupkmab1;
          endif;
        endif;
        if parmsSent > 28;
          if direction = 'ParmsToRec';
            odupkmab2 = iodupkmab2;
          else;
            iodupkmab2 = odupkmab2;
          endif;
        endif;
        if parmsSent > 29;
          if direction = 'ParmsToRec';
            odupkmrn = iodupkmrn;
          else;
            iodupkmrn = odupkmrn;
          endif;
        endif;
        if parmsSent > 30;
          if direction = 'ParmsToRec';
            odupkmrb1 = iodupkmrb1;
          else;
            iodupkmrb1 = odupkmrb1;
          endif;
        endif;
        if parmsSent > 31;
          if direction = 'ParmsToRec';
            odupkmrb2 = iodupkmrb2;
          else;
            iodupkmrb2 = odupkmrb2;
          endif;
        endif;

      /end-free

     p                 e

