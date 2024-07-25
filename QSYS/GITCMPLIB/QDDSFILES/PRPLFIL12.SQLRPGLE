      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  PRPLFIL12  SQL View to Summarize PRPLFIL
     *  20 March 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    03/20/19  KDE  7.30
     *      - Created.
730aA*    04/09/19  KDE  7.30a
     *      - Greco asked that we include a column for negative
     *        pick slots in Aisle
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
                     + 'CALL OPSPROD (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'PRPLFIL';
        view = 'PRPLFIL12';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

        sqlstmt = 'drop view ' + %trimr(viewLibFile);

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

        sqlstmt = 'create view ' + %trimr(viewLibFile) + ' '
                + '('
                +   'prwhse,'
                +   'prrplt,'
                +   'prwhdp,'
                +   'prtdsc,'
                +   'prtail,'
                +   'prqty,'
                +   'prcnt,'
                +   'prnegslt'
                + ') '
                + 'as '
                + 'select '
                +   'prwhse,prrplt,prwhdp,Case prrplt'
                +   '  when ' + sq + ' ' + sq + ' then ' + sq + 'Normal' + sq
                +   '  when ' + sq + 'B' + sq + ' then ' + sq + 'Breakdown' + sq
                +  '  when ' + sq + 'D' + sq + ' then ' + sq + 'Production' + sq
                +   ' when ' + sq + 'R' + sq + ' then ' + sq + 'Repacks' + sq
                +   ' when ' + sq + 'F' + sq + ' then ' + sq + 'Flowrack' + sq
                +   ' when ' + sq + 'S' + sq + ' then ' + sq + 'Staging' + sq
                +   ' else ' + sq + 'Unknown' + sq
                +   ' End as prtdsc'
                +   ',prtail, sum(prqty) as prqty,count(*) as prcnt'
                +   ',(select distinct count(*) from ' + %trim(pPfLib) + '/SLOT'
                +   ' where slwhse=prwhse'
                +   ' and prtail=slaisl and (slstk1<0 or slstk2<0 or slstk3<0))'
                +   ' from ' + %trim(pfLibFile)
                +   ' where prflag <> ' + sq + 'D' + sq
                +   ' group by prwhse, prrplt, prwhdp, prtail'
                + '';

        exec sql execute immediate :sqlstmt;
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
                + 'is ''View to sum PRPLFIL '
                + %trimr(file) + ' ' + ' fields''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' '
                + 'field view - 7.30''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmt = 'label on column ' + %trimr(viewLibFile) + ' '
                + '('
                +   'prwhse is ''Warehouse '
                +               '       '','
                +   'prrplt is ''Replen     '
                +               'Type      '','
                +   'prwhdp is ''Warehouse  '
                +               'Dept      '','
                +   'prtdsc is ''Replen '
                +               'Type Desc'','
                +   'prqty  is ''Replen '
                +               'Quantity '','
                +   'prcnt  is ''Replen   '
                +               'Count     '','
                +   'prnegslt  is ''Slots    '
                +               'Negative  '''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
