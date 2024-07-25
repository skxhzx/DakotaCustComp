      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTOTCOL  SQL View for PS313WF TOTCOL Data
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
        view = 'TSTOTCOL';
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
                +   'pswtotcol1,'
                +   'pswtotcol2,'
                +   'pswtotcol3,'
                +   'pswtotcol4,'
                +   'pswtotcol5,'
                +   'pswtotcol6,'
                +   'pswtotcol7,'
                +   'pswtotcol8,'
                +   'pswtotcol9,'
                +   'pswtcol10'
                + ') '
                + 'as ('
                + 'select '
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
       //                                     1  50 PSWTOTCOL1
                +   'substr(pswdata,1,50),'
       //                                    51 100 PSWTOTCOL2
                +   'substr(pswdata,51,50),'
       //                                   101 150 PSWTOTCOL3
                +   'substr(pswdata,101,50),'
       //                                   151 200 PSWTOTCOL4
                +   'substr(pswdata,151,50),'
       //                                   201 250 PSWTOTCOL5
                +   'substr(pswdata,201,50),'
       //                                   251 300 PSWTOTCOL6
                +   'substr(pswdata,251,50),'
       //                                   301 350 PSWTOTCOL7
                +   'substr(pswdata,301,50),'
       //                                   351 400 PSWTOTCOL8
                +   'substr(pswdata,351,50),'
       //                                   401 450 PSWTOTCOL9
                +   'substr(pswdata,401,50),'
       //                                   451 500 PSWTCOL10
                +   'substr(pswdata,451,50)'
                + ' from ' + %trim(pfLibFile)
                + ' where pswrpttp = ' + sq + 'GH' + sq
                + ' and pswrecf = ' + sq + 'TOTCOL' + sq
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
                +   'pswtotcol1 is ''TOTCOL field 1'
                +               ''','
                +   'pswtotcol2 is ''TOTCOL field 2 '
                +               ''','
                +   'pswtotcol3 is ''TOTCOL field 3 '
                +               ''','
                +   'pswtotcol4 is ''TOTCOL field 4 '
                +               ''','
                +   'pswtotcol5 is ''TOTCOL field 5 '
                +               ''','
                +   'pswtotcol6 is ''TOTCOL field 6'
                +               ''','
                +   'pswtotcol7 is ''TOTCOL field 7'
                +               ''','
                +   'pswtotcol8 is ''TOTCOL field 8'
                +               ''','
                +   'pswtotcol9 is ''TOTCOL field 9'
                +               ''','
                +   'pswtcol10 is ''TOTCOL field 10'
                +               ''''
                + ')';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
