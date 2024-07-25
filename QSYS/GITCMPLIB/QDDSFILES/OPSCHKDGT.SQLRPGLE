      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSCHKDGT  SQL View for OPTIONS *CHKDGT
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
                     + 'CALL OPSCHKDGT (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*CHKDGT';
        view = 'OPSCHKDGT';
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
                +   'opcod#,'
                +   'opdgt#,'
                +   'opidc1,'
                +   'opidc2,'
                +   'opunu2,'
                +   'opidc3,'
                +   'opunu3,'
                +   'opidd1,'
                +   'opidd2,'
                +   'opidd3,'
                +   'oprcod,'
                +   'oprcd1,'
                +   'oprcd2,'
                +   'oprcd3,'
                +   'oprord,'
                +   'oprlcr,'
                +   'oprrcl,'
                +   'oprlrc,'
                +   'oprrlc,'
                +   'oprclr,'
                +   'oprcrl,'
                +   'opread'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   10OPCOD#
                +   'zoned('
                +     'translate(substr(opdata,1,1),''0'','' '')'
                +   ',1,0),'
       //                                     2   20OPDGT#
                +   'zoned('
                +     'translate(substr(opdata,2,1),''0'','' '')'
                +   ',1,0),'
       //                                     3   8 OPIDC1
                +   'substr(opdata,3,6),'
       //                                     9  14 OPIDC2
                +   'substr(opdata,9,6),'
       //                                    15  16 OPUNU2
                +   'substr(opdata,15,2),'
       //                                    17  22 OPIDC3
                +   'substr(opdata,17,6),'
       //                                    23  24 OPUNU3
                +   'substr(opdata,23,2),'
       //                                    25  30 OPIDD1
                +   'substr(opdata,25,6),'
       //                                    31  36 OPIDD2
                +   'substr(opdata,31,6),'
       //                                    37  42 OPIDD3
                +   'substr(opdata,37,6),'
       //                                    43  43 OPRCOD
                +   'substr(opdata,43,1),'
       //                                    44  44 OPRCD1
                +   'substr(opdata,44,1),'
       //                                    45  45 OPRCD2
                +   'substr(opdata,45,1),'
       //                                    46  46 OPRCD3
                +   'substr(opdata,46,1),'
       //                                    47  47 OPRORD
                +   'substr(opdata,47,1),'
       //                                    48  48 OPRLCR
                +   'substr(opdata,48,1),'
       //                                    49  49 OPRRCL
                +   'substr(opdata,49,1),'
       //                                    50  50 OPRLRC
                +   'substr(opdata,50,1),'
       //                                    51  51 OPRRLC
                +   'substr(opdata,51,1),'
       //                                    52  52 OPRCLR
                +   'substr(opdata,52,1),'
       //                                    53  53 OPRCRL
                +   'substr(opdata,53,1),'
       //                                    54  540OPREAD
                +   'zoned('
                +     'translate(substr(opdata,54,1),''0'','' '')'
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
                +   'opcod# is ''# of chk digit      '
                +               'codes per slot'','
                +   'opdgt# is ''Max # of digits     '
                +               'per code'','
                +   'opidc1 is ''Code 1              '
                +               'identifier'','
                +   'opidc2 is ''Code 2              '
                +               'identifier'','
                +   'opunu2 is ''Unused'','
                +   'opidc3 is ''Code 3              '
                +               'identifier'','
                +   'opunu3 is ''Unused'','
                +   'opidd1 is ''Digit 1             '
                +               'identifier'','
                +   'opidd2 is ''Digit 2             '
                +               'identifier'','
                +   'opidd3 is ''Digit 3             '
                +               'identifier'','
                +   'oprcod is ''Curr cd to read     '
                +               'S=Single R=Random'','
                +   'oprcd1 is ''Use cd 1 for        '
                +               'curr reading'','
                +   'oprcd2 is ''Use cd 2 for        '
                +               'curr reading'','
                +   'oprcd3 is ''Use cd 3 for        '
                +               'curr reading'','
                +   'oprord is ''Curr read order     '
                +               'S=Single R=Random'','
                +   'oprlcr is ''Use read order      '
                +               'Left/Ctr/Right'','
                +   'oprrcl is ''Use read order      '
                +               'Right/Ctr/Left'','
                +   'oprlrc is ''Use read order      '
                +               'Left/Right/Ctr'','
                +   'oprrlc is ''Use read order      '
                +               'Right/Left/Ctr'','
                +   'oprclr is ''Use read order      '
                +               'Ctr/Left/Right'','
                +   'oprcrl is ''Use read order      '
                +               'Ctr/Right/Left'','
                +   'opread is ''# of digits user    '
                +               'reads for codes <100'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
