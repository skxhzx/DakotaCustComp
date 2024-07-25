      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTOTSUM  SQL View for PS313WF TOTAL1 Data
     *  13 September 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
640 A*    09/13/18  KDE  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Dealing with numeric fields
     *
     *   - The SQL 'zoned' function is used to create numeric fields.
     *   - To ensure that the characters are not blank, the 'translate'
     *     function is also used to convert blanks into zeros.
     *   - If the field contains any other non-numeric characters,
     *     the field will end up with invalid data.
     *   - Example code for a zero decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opdata,1,7,''0'','' '')'
     *       + ',7,0)'
     *   - Example code for a 2 decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opdata,16,3,''0'','' '')'
     *       +   '||''.''||'
     *       +   'translate(substr(opdata,19,2,''0'','' '')'
     *       + ',5,2)'
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
     d  sqlStmtLarge   s           8192

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pPFLib         s             10
     D  pViewLib       s             10

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
     c                   parm                    pViewLib

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Verify parameters have been sent in

        if %parms < 2
          or pPFLib = ''
          or pViewLib = '';
            dsplyMsg = 'Error: Missing Parm - '
                     + 'CALL OPSGENPICK (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'PS313WF';
        view = 'TSTOTSUM';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

        sqlstmtLarge = 'drop view ' + %trimr(viewLibFile);

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

        sqlstmtLarge = 'create view ' + %trimr(viewLibFile) + ' '
                + '('
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
                +   'pswtotsum1,'
                +   'pswtotsum2,'
                +   'pswtotsum3,'
                +   'pswtotsum4,'
                +   'pswtotsum5,'
                +   'pswtotsum6,'
                +   'pswtotsum7,'
                +   'pswtotsum8,'
                +   'pswtotsum9,'
                +   'pswtsum10'
                + ') '
                + 'as ('
                + 'select '
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
       //                                     1  50 PSWTOTSUM1
                +   'substr(pswdata,1,50),'
       //                                    51 100 PSWTOTSUM2
                +   'substr(pswdata,51,50),'
       //                                   101 150 PSWTOTSUM3
                +   'substr(pswdata,101,50),'
       //                                   151 200 PSWTOTSUM4
                +   'substr(pswdata,151,50),'
       //                                   201 250 PSWTOTSUM5
                +   'substr(pswdata,201,50),'
       //                                   251 300 PSWTOTSUM6
                +   'substr(pswdata,251,50),'
       //                                   301 350 PSWTOTSUM7
                +   'substr(pswdata,301,50),'
       //                                   351 400 PSWTOTSUM8
                +   'substr(pswdata,351,50),'
       //                                   401 450 PSWTOTSUM9
                +   'substr(pswdata,401,50),'
       //                                   451 500 PSWTSUM10
                +   'substr(pswdata,451,50)'
                + ' from ' + %trim(pfLibFile)
                + ' where pswrecf = ' + sq + 'TOTAL1' + sq
                + ' or pswrecf = ' + sq + 'TOTAL2' + sq
                + ')';

        debugStr1 = %subst(sqlstmtLarge:1:1000);
        debugStr2 = %subst(sqlstmtLarge:1001);

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

        sqlstmtLarge = 'grant select,insert,update,delete '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        sqlstmtLarge = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''View to split out '
                + %trimr(file) + ' ' + %trim(code) + ' fields''';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmtLarge = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' ' + %trimr(code) + ' '
                + 'field view - 6.40''';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmtLarge = 'label on column ' + %trimr(viewLibFile) + ' '
                + '('
                +   'pswtotsum1 is ''TOTSUM field 1'
                +               ''','
                +   'pswtotsum2 is ''TOTSUM field 2 '
                +               ''','
                +   'pswtotsum3 is ''TOTSUM field 3 '
                +               ''','
                +   'pswtotsum4 is ''TOTSUM field 4 '
                +               ''','
                +   'pswtotsum5 is ''TOTSUM field 5 '
                +               ''','
                +   'pswtotsum6 is ''TOTSUM field 6'
                +               ''','
                +   'pswtotsum7 is ''TOTSUM field 7'
                +               ''','
                +   'pswtotsum8 is ''TOTSUM field 8'
                +               ''','
                +   'pswtotsum9 is ''TOTSUM field 9'
                +               ''','
                +   'pswtsum10 is ''TOTSUM field 10'
                +               ''''
                + ')';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
