      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSINTERLV  SQL View for OPTIONS *INTERLV
     *  10 November 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    11/10/11  RBD  6.40
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
                     + 'CALL OPSINTERLV (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*INTERLV';
        view = 'OPSINTERLV';
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
                +   'opintl,'
                +   'opmaxr,'
                +   'opfsab,'
                +   'opfsaa,'
                +   'opfsbb,'
                +   'opfsba,'
                +   'optsab,'
                +   'optsaa,'
                +   'optsbb,'
                +   'optsba'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPINTL
                +   'substr(opdata,1,1),'
       //                                     2   30OPMAXR
                +   'zoned('
                +     'translate(substr(opdata,2,2),''0'','' '')'
                +   ',2,0),'
       //                                     4   50OPFSAB
                +   'zoned('
                +     'translate(substr(opdata,4,2),''0'','' '')'
                +   ',2,0),'
       //                                     6   70OPFSAA
                +   'zoned('
                +     'translate(substr(opdata,6,2),''0'','' '')'
                +   ',2,0),'
       //                                     8  100OPFSBB
                +   'zoned('
                +     'translate(substr(opdata,8,3),''0'','' '')'
                +   ',3,0),'
       //                                    11  130OPFSBA
                +   'zoned('
                +     'translate(substr(opdata,11,3),''0'','' '')'
                +   ',3,0),'
       //                                    14  150OPTSAB
                +   'zoned('
                +     'translate(substr(opdata,14,2),''0'','' '')'
                +   ',2,0),'
       //                                    16  170OPTSAA
                +   'zoned('
                +     'translate(substr(opdata,16,2),''0'','' '')'
                +   ',2,0),'
       //                                    18  200OPTSBB
                +   'zoned('
                +     'translate(substr(opdata,18,3),''0'','' '')'
                +   ',3,0),'
       //                                    21  230OPTSBA
                +   'zoned('
                +     'translate(substr(opdata,21,3),''0'','' '')'
                +   ',3,0)'
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
                +   'opintl is ''Allow               '
                +               'interleaving'','
                +   'opmaxr is ''Max # of repl       '
                +               'allowed'','
                +   'opfsab is ''FROM slot-aisles    '
                +               'before curr aisle'','
                +   'opfsaa is ''FROM slot-aisles    '
                +               'after curr aisle'','
                +   'opfsbb is ''FROM slot-bays      '
                +               'before curr loc'','
                +   'opfsba is ''FROM slot-bays      '
                +               'after curr loc'','
                +   'optsab is ''TO slot-aisles      '
                +               'before curr aisle'','
                +   'optsaa is ''TO slot-aisles      '
                +               'after curr aisle'','
                +   'optsbb is ''TO slot-bays        '
                +               'before curr loc'','
                +   'optsba is ''TO slot-bays        '
                +               'after curr loc'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
