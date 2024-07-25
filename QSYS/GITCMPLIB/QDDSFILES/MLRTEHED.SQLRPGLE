      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  MLRTEHED  Multi Lib SQL View - RTEHED
     *  28 January 2016
     *  Dave Sommerville
     *
     *  Revisions
     *
700 A*    01/28/16  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglowhse   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
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

     D  debugStr1      s           1000
     D  debugStr2      s           1000
     D  dsplyMsg       s             52
     D  file           s             10
     D  libCount       s              3  0
     D  pfLibFile      s             21
     D  stmt           s           4096    varying
     D  view           s             10
     D  viewLibFile    s             21
     D  whseFld        s             10

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pViewLib       s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pViewLib     Library where View is to be created
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pViewLib

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        file = 'RTEHED';
        whseFld = 'RHWHSE';
        view = 'MLRTEHED';

        // Verify parameters have been sent in

        if %parms < 1
          or pViewLib = '';
            dsplyMsg = 'Error: Missing Parm - '
                     + 'CALL ' + %trimr(file) + ' (viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // First, delete existing view

        viewLibFile = %trim(pViewLib) + '/' + view;
        stmt = 'drop view ' + %trimr(viewLibFile);

        exec sql execute immediate :stmt;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Start View statement

        stmt = 'create view ' + %trimr(viewLibFile) + ' as (';

        // Loop through libraries

        libCount = 0;

        dow forever = forever;

          read glowhse;
          if %eof(glowhse);
            leave;
          endif;

          if gwfilelib = '';
            iter;
          endif;

          libCount += 1;

          if libCount > 1;
            stmt += ' UNION ';
          endif;

          stmt = stmt
               + 'select * '
               + 'from ' + %trim(gwfilelib) + '/' + %trimr(file) + ' '
               + 'where ' + %trim(whseFld) + '=' + %char(gwwhse);

        enddo;

        // End View statement

        stmt += ')';

        //debugStr1 = %subst(sqlstmt:1:1000);
        //debugStr2 = %subst(sqlstmt:1001);

        exec sql execute immediate :stmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

        sqlstmt = 'grant select '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        sqlstmt = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''Multi Lib View for '
                + %trimr(file) + ' ''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''Multi Lib View for '
                + %trimr(file) + ' - 7.00''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
