      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPDPICK    SQL View for OPTIOND *PICK
     *  07 September 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    09/07/11  DAS  6.40
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
     *       +   'translate(substr(opddta,1,7,''0'','' '')'
     *       + ',7,0)'
     *   - Example code for a 2 decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opddta,16,3,''0'','' '')'
     *       +   '||''.''||'
     *       +   'translate(substr(opddta,19,2,''0'','' '')'
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
                     + 'CALL OPZPICK (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIOND';
        code = '*PICK';
        view = 'OPDPICK';
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
                +   'opdwhs,'
                +   'opdwdp,'
                +   'opnxtp,'
                +   'oppcub,'
                +   'opfpal,'
                +   'opfcub,'
                +   'opincl,'
                +   'opsrch,'
                +   'opfstp,'
                +   'opfbld,'
                +   'opbpck,'
                +   'oppbrk,'
                +   'opmput'
                + ') '
                + 'as ('
                + 'select '
                +   'opdwhs,'
                +   'opdwdp,'
       //                                     1   70OPNXTP
                +   'zoned('
                +     'translate(substr(opddta,1,7),''0'','' '')'
                +   ',7,0),'
       //                                    10  142OPPCUB
                +   'zoned('
                +     'translate(substr(opddta,10,3),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opddta,13,2),''0'','' '')'
                +   ',5,2),'
       //                                    15  150OPFPAL
                +   'zoned('
                +     'translate(substr(opddta,15,1),''0'','' '')'
                +   ',1,0),'
       //                                    16  202OPFCUB
                +   'zoned('
                +     'translate(substr(opddta,16,3),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opddta,19,2),''0'','' '')'
                +   ',5,2),'
       //                                    22  22 OPINCL
                +   'substr(opddta,22,1),'
       //                                    23  240OPSRCH
                +   'zoned('
                +     'translate(substr(opddta,23,2),''0'','' '')'
                +   ',2,0),'
       //                                    25  260OPFSTP
                +   'zoned('
                +     'translate(substr(opddta,25,2),''0'','' '')'
                +   ',2,0),'
209 A  //                                    27  270OPFBLD
                +   'zoned('
                +     'translate(substr(opddta,27,1),''0'','' '')'
                +   ',1,0),'
213 A  //                                    28  300OPBPCK
                +   'zoned('
                +     'translate(substr(opddta,28,3),''0'','' '')'
                +   ',3,0),'
214 A  //                                    31  33 OPPBRK
                +   'substr(opddta,31,3),'
409 A  //                                    34  34 OPMPUT
                +   'substr(opddta,34,1)'
                + ' from ' + %trim(pfLibFile)
                + ' where opdcod = ' + sq + %trim(code) + sq
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
                +   'opnxtp is ''Next Plt#'','
                +   'oppcub is ''Min PIR Cube'','
                +   'opfpal is ''Plts on Fork'','
                +   'opfcub is ''Max Fixed Cube'','
                +   'opincl is ''Include PIR         '
                +               'in Fixed Cube'','
                +   'opsrch is ''Previous plts       '
                +               'to search'','
                +   'opfstp is ''Max stops on plt'','
                +   'opfbld is ''Bld Method'','
                +   'opbpck is ''Min cube for        '
                +               'Bulk Pick'','
                +   'oppbrk is ''Aisle to start      '
                +               'new pallet'','
                +   'opmput is ''Manual putaway'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
