      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  entryNSTR  SQL Create Table file
     *  10 Feb 2017
     *  Thomas Bryant
     *
     *  If reran just pass one parm for library where to build.
     *  This is building a physical file, not a view
     *
     *  Revisions
     *
650 A*    02/11/17  TAB  7.10
     *      - Created.
     *
720 A*    01/17/18  KDE  7.20
     *      - Added Primary Key
     *
     *----------------------------------------------------------------

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

     D  code           s              8
     D  debugStr1      s           1000
     D  debugStr2      s           1000
     D  file           s             10
     D  dsplyMsg       s             52
     D  pfLibFile      s             21
     D  view           s             10
     D  viewLibFile    s             21

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pPFLib         s             10
     D  pPfile         s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pPFLib       Library where PF is located
     *      pViewLib     Library where View is to be created
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pPFLib

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Verify parameters have been sent in

        if %parms < 1
          or pPFLib = '';
            dsplyMsg = 'Error: Missing Parm - '
                     + 'CALL PBOMINSTR (pfLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        pPfile = 'PBOMI';
        pfLibFile = %trim(pPFLib) + '/' + %trim(pPfile);

        // Create file

        sqlstmt = 'create table ' + %trimr(pfLibFile) + ' '
                + '('
720 D         //  +   'BIWHSE DECIMAL(3,0) NOT NULL PRIMARY KEY,'
                +   'BIWHSE DECIMAL(3,0) NOT NULL,'
                +   ' BIFGI VARCHAR(15) NOT NULL,'
                +   ' BIINST VARCHAR(5000) ALLOCATE(500) NOT NULL,'
720 A           +   'PRIMARY KEY(BIWHSE,BIFGI)'
                + ')'
                + ' RCDFMT BIREC';

        debugStr1 = %subst(sqlstmt:1:1000);
        debugStr2 = %subst(sqlstmt:1001);

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          If sqlstt <> '01567';
            dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
            dsply dsplyMsg;
            dsplyMsg = 'Table ' + %trimr(pfLibFile) + ' not created.';
            dsply dsplyMsg;
            return;
          endif;
        endif;

        // Grant permission to file

        sqlstmt = 'grant select '
                + 'on ' + %trim(pfLibFile) + ' '
                + 'to public';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        sqlstmt = 'comment on table ' + %trimr(pfLibFile) + ' '
                + 'is ''Marinade Instruction Table''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(pfLibFile) + ' '
                + 'is ''Marinade Instructions Table -7.10''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmt = 'label on column ' + %trimr(pfLibFile) + ' '
                + '('
                +   'BIWHSE is ''Warehouse'','
                +   'BIFGI  is ''FG Item'','
                +   'BIINST is ''Instructions'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column Text
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmt = 'label on column ' + %trimr(pfLibFile) + ' '
                + '('
                +   'BIWHSE TEXT is ''Warehouse'','
                +   'BIFGI  TEXT is ''FG Item'','
                +   'BIINST TEXT is ''Instructions'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;
        return;

      /end-free
