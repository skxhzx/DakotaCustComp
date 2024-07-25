      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSDAYEND  SQL View for OPTIONS *DAYEND
     *  28 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/28/11  RBD  6.40
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
                     + 'CALL OPSDAYEND (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*DAYEND';
        view = 'OPSDAYEND';
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
                +   'opwhse,'
                +   'opstr1,'
                +   'opstr2,'
                +   'opstr3,'
                +   'opstr4,'
                +   'opstr5,'
                +   'opstr6,'
                +   'opstr7,'
                +   'opltdt,'
                +   'oplttm,'
                +   'oplodt,'
                +   'oplotm,'
                +   'opweek,'
                +   'opwkav,'
                +   'opdyav'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   60OPSTR1
                +   'zoned('
                +     'translate(substr(opdata,1,6),''0'','' '')'
                +   ',6,0),'
       //                                     7  120OPSTR2
                +   'zoned('
                +     'translate(substr(opdata,7,6),''0'','' '')'
                +   ',6,0),'
       //                                    13  180OPSTR3
                +   'zoned('
                +     'translate(substr(opdata,13,6),''0'','' '')'
                +   ',6,0),'
       //                                    19  240OPSTR4
                +   'zoned('
                +     'translate(substr(opdata,19,6),''0'','' '')'
                +   ',6,0),'
       //                                    25  300OPSTR5
                +   'zoned('
                +     'translate(substr(opdata,25,6),''0'','' '')'
                +   ',6,0),'
       //                                    31  360OPSTR6
                +   'zoned('
                +     'translate(substr(opdata,31,6),''0'','' '')'
                +   ',6,0),'
       //                                    37  420OPSTR7
                +   'zoned('
                +     'translate(substr(opdata,37,6),''0'','' '')'
                +   ',6,0),'
       //                                    43  500OPLTDT
                +   'zoned('
                +     'translate(substr(opdata,43,8),''0'','' '')'
                +   ',8,0),'
       //                                    51  560OPLTTM
                +   'zoned('
                +     'translate(substr(opdata,51,6),''0'','' '')'
                +   ',6,0),'
       //                                    57  640OPLODT
                +   'zoned('
                +     'translate(substr(opdata,57,8),''0'','' '')'
                +   ',8,0),'
       //                                    65  700OPLOTM
                +   'zoned('
                +     'translate(substr(opdata,65,6),''0'','' '')'
                +   ',6,0),'
       //                                    71  720OPWEEK
                +   'zoned('
                +     'translate(substr(opdata,71,2),''0'','' '')'
                +   ',2,0),'
       //                                    73  750OPWKAV
                +   'zoned('
                +     'translate(substr(opdata,73,3),''0'','' '')'
                +   ',3,0),'
       //                                    76  760OPDYAV
                +   'zoned('
                +     'translate(substr(opdata,76,1),''0'','' '')'
                +   ',1,0)'
                + ' from ' + %trim(pfLibFile)
                + ' where opcode = ' + sq + %trim(code) + sq
                + ')';

        debugStr1 = %subst(sqlstmt:1:1000);
        debugStr2 = %subst(sqlstmt:1001);

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

        sqlstmt = 'grant select,insert,update,delete '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        sqlstmt = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''View to split out '
                + %trimr(file) + ' ' + %trim(code) + ' fields''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' ' + %trimr(code) + ' '
                + 'field view - 6.40''';

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
                +   'opstr1 is ''Sunday whse         '
                +               'start time'','
                +   'opstr2 is ''Monday whse         '
                +               'start time'','
                +   'opstr3 is ''Tuesday whse        '
                +               'start time'','
                +   'opstr4 is ''Wednesday whse      '
                +               'start time'','
                +   'opstr5 is ''Thursday whse       '
                +               'start time'','
                +   'opstr6 is ''Friday whse         '
                +               'start time'','
                +   'opstr7 is ''Saturday whse       '
                +               'start time'','
                +   'opltdt is ''Last transaction    '
                +               'processed date'','
                +   'oplttm is ''Last transaction    '
                +               'processed time'','
                +   'oplodt is ''Last order          '
                +               'processed date'','
                +   'oplotm is ''Last order          '
                +               'processed time'','
                +   'opweek is ''Curr                '
                +               'wk #'','
                +   'opwkav is ''# of wks            '
                +               'for avg'','
                +   'opdyav is ''Day to compute avgs:'
                +               '1=Sun - 7=Sat'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
