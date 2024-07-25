      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSRUNNER  SQL View for OPTIONS *RUNNER
     *  21 October 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    10/21/11  RBD  6.40
     *      - Created.
     *
750aA*    07/07/21  RBD  7.50a
     *      - Added opscnl option.
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
                     + 'CALL OPSRUNNER (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*RUNNER';
        view = 'OPSRUNNER';
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
                +   'opcrtm,'
                +   'opuplr,'
                +   'oprplf,'
                +   'opmrgf,'
                +   'opclrf,'
                +   'oprnrm,'
                +   'opclsf,'
                +   'opoutf,'
                +   'oprpck,'
                +   'oprlbl,'
                +   'oprbdu,'
                +   'oprscn,'
                +   'oprvfs,'
                +   'oprvfq,'
                +   'oprloa,'
750aA           +   'opscnl'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPCRTM
                +   'substr(opdata,1,1),'
       //                                     2   2 OPUPLR
                +   'substr(opdata,2,1),'
       //                                     3   3 OPRPLF
                +   'substr(opdata,3,1),'
       //                                     4   4 OPMRGF
                +   'substr(opdata,4,1),'
       //                                     5   5 OPCLRF
                +   'substr(opdata,5,1),'
       //                                     6   6 OPRNRM
                +   'substr(opdata,6,1),'
       //                                     7   7 OPCLSF
                +   'substr(opdata,7,1),'
       //                                     8   8 OPOUTF
                +   'substr(opdata,8,1),'
       //                                     9   9 OPRPCK
                +   'substr(opdata,9,1),'
       //                                    10  10 OPRLBL
                +   'substr(opdata,10,1),'
       //                                    11  11 OPRBDU
                +   'substr(opdata,11,1),'
       //                                    12  12 OPRSCN
                +   'substr(opdata,12,1),'
       //                                    13  13 OPRVFS
                +   'substr(opdata,13,1),'
       //                                    14  14 OPRVFQ
                +   'substr(opdata,14,1),'
       //                                    15  15 OPRLOA
                +   'substr(opdata,15,1),'
750aA  //                                    16  16 OPSCNL
750aA           +   'substr(opdata,16,1)'
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
                +   'opcrtm is ''Create manual Runner'
                +               'ent for shorts/outs'','
                +   'opuplr is ''Upd Lbl w/ qty shrtd'
                +               'durng man flag entry'','
                +   'oprplf is ''Replen flagged items'
                +               'before print rpt'','
                +   'opmrgf is ''Crt Runner entries  '
                +               'for merge records'','
                +   'opclrf is ''Clear Runner flgs if'
                +               'qty still short/out'','
                +   'oprnrm is ''Sndbrkmsg when new  '
                +               'Runner task assigned'','
                +   'opclsf is ''Upd Label qty       '
                +               'at flag close'','
                +   'opoutf is ''Crt Runner entry aft'
                +               'slot marked out'','
                +   'oprpck is ''Print Runner        '
                +               'pick list'','
                +   'oprlbl is ''Print Runner        '
                +               'pick labels'','
                +   'oprbdu is ''Allow shorts to be  '
                +               'filled w/ bkdn units'','
                +   'oprscn is ''Scan tran# or       '
                +               'label# to start pick'','
                +   'oprvfs is ''Verify pick         '
                +               'slot'','
                +   'oprvfq is ''Verify qty          '
                +               'found'','
                +   'oprloa is ''Using loader        '
                +               'module'','
750aA           +   'opscnl is ''Scan short to loader '
750aA           +               'before clear flag'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
