      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSCOLS  SQL View for PS313WF COLUMNS Data
     *  12 September 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
640 A*    09/12/18  KDE  7.20
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
        view = 'TSCOLS';
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
                +   'pswcol1,'
                +   'pswcol2,'
                +   'pswcol3,'
                +   'pswcol4,'
                +   'pswcol5,'
                +   'pswcol6,'
                +   'pswcol7,'
                +   'pswcol8,'
                +   'pswcol9,'
                +   'pswcol10'
                + ') '
                + 'as ('
                + 'select '
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
       //                                     1  50 PSWCOL1
                +   'substr(pswdata,1,50),'
       //                                    51 100 PSWCOL2
                +   'substr(pswdata,51,50),'
       //                                   101 150 PSWCOL3
                +   'substr(pswdata,101,50),'
       //                                   151 200 PSWCOL4
                +   'substr(pswdata,151,50),'
       //                                   201 250 PSWCOL5
                +   'substr(pswdata,201,50),'
       //                                   251 300 PSWCOL6
                +   'substr(pswdata,251,50),'
       //                                   301 350 PSWCOL7
                +   'substr(pswdata,301,50),'
       //                                   351 400 PSWCOL8
                +   'substr(pswdata,351,50),'
       //                                   401 450 PSWCOL9
                +   'substr(pswdata,401,50),'
       //                                   451 500 PSWCOL10
                +   'substr(pswdata,451,50)'
                + ' from ' + %trim(pfLibFile)
                + ' where pswrpttp = ' + sq + 'H' + sq
                + ' and pswrecf = ' + sq + 'COLUMNS' + sq
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
                +   'pswcol1 is ''HEAD2 field 1'
                +               ''','
                +   'pswcol2 is ''HEAD2 field 2 '
                +               ''','
                +   'pswcol3 is ''HEAD2 field 3 '
                +               ''','
                +   'pswcol4 is ''HEAD2 field 4 '
                +               ''','
                +   'pswcol5 is ''HEAD2 field 5 '
                +               ''','
                +   'pswcol6 is ''HEAD2 field 6'
                +               ''','
                +   'pswcol7 is ''HEAD2 field 7'
                +               ''','
                +   'pswcol8 is ''HEAD2 field 8'
                +               ''','
                +   'pswcol9 is ''HEAD2 field 9'
                +               ''','
                +   'pswcol10 is ''HEAD2 field 10'
                +               ''''
                + ')';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
