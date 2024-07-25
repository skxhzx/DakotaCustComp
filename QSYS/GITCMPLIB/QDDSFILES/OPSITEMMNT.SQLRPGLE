      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSITEMMNT  SQL View for OPTIONS *ITEMMNT
     *  21 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/21/11  RBD  6.40
     *      - Created.
     *
640aA*    08/15/12  DAS  6.40a
     *      - Added OPHVY
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
                     + 'CALL OPSITEMMNT (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*ITEMMNT';
        view = 'OPSITEMMNT';
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
                +   'opstyp,'
                +   'opwhdp,'
                +   'opum1,'
                +   'opdum,'
                +   'opcum,'
                +   'opcdiv,'
                +   'opcaut,'
                +   'opcwrn,'
                +   'opcrng,'
                +   'opwum,'
                +   'opxdsc,'
640aA           +   'ophvy'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPSTYP
                +   'substr(opdata,1,1),'
       //                                     2   6 OPWHDP
                +   'substr(opdata,2,5),'
       //                                     7   8 OPUM1
                +   'substr(opdata,7,2),'
       //                                     9  23 OPDUM
                +   'substr(opdata,9,15),'
       //                                    24  43 OPCUM
                +   'substr(opdata,24,20),'
       //                                    44  522OPCDIV
                +   'zoned('
                +     'translate(substr(opdata,44,7),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opdata,51,2),''0'','' '')'
                +   ',9,2),'
       //                                    53  53 OPCAUT
                +   'substr(opdata,53,1),'
       //                                    54  54 OPCWRN
                +   'substr(opdata,54,1),'
       //                                    55  571OPCRNG
                +   'zoned('
                +     'translate(substr(opdata,55,2),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opdata,57,1),''0'','' '')'
                +   ',3,1),'
       //                                    58  72 OPWUM
                +   'substr(opdata,58,15),'
       //                                    73  73 OPXDSC
                +   'substr(opdata,73,1),'
       //                                    74  750OPHVY
                +   'zoned('
                +     'translate(substr(opdata,74,2),''0'','' '')'
                +   ',2,0)'
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
                +   'opstyp is ''Default             '
                +               'section type'','
                +   'opwhdp is ''Default warehouse   '
                +               'department'','
                +   'opum1  is ''Default normal      '
                +               'unit of measure'','
                +   'opdum  is ''Unit of measure     '
                +               'for dimensions'','
                +   'opcum  is ''Unit of measure     '
                +               'for cube'','
                +   'opcdiv is ''Divisor             '
                +               'for cube'','
                +   'opcaut is ''Auto calc cube      '
                +               'when zero'','
                +   'opcwrn is ''Display cube        '
                +               'warning'','
                +   'opcrng is ''Display cube warning'
                +               'range percentage'','
                +   'opwum  is ''Unit of measure     '
                +               'for weight'','
                +   'opxdsc is ''Use extended        '
                +               'description'','
640aA           +   'ophvy  is ''Heavy item          '
640aA           +               'minimum'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
