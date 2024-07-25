      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSPLTPRTY  SQL View for OPTIONS *PLTPRTY
     *  31 August 2020
     *  Dave Sommerville
     *
     *  Revisions
     *
740 A*    08/31/20  DAS  7.40
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
     *       +   'translate(substr(opdata,1,7),''0'','' '')'
     *       + ',7,0)'
     *   - Example code for a 2 decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opdata,16,3),''0'','' '')'
     *       +   '||''.''||'
     *       +   'translate(substr(opdata,19,2),''0'','' '')'
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
                     + 'CALL OPSPLTPRTY (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*PLTPRTY';
        view = 'OPSPLTPRTY';
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
                +   'opSplitItem,'
                +   'opSplitStop,'
                +   'opIdealCube,'
                +   'opMinPallets,'
                +   'opSideWgt,'
                +   'opZoneWgt,'
                +   'opZoneCube,'
                +   'opMinStops,'
                +   'opBulkhead'
                + ') '
                + 'as ('
                + 'select '
       //                                           opwhse
                +   'opwhse,'
       //                                           opSplitItem
                +   'zoned('
                +     'translate(substr(opdata,1,2),''0'','' '')'
                +     ',2,0),'
       //                                           opSplitStop
                +   'zoned('
                +     'translate(substr(opdata,3,2),''0'','' '')'
                +     ',2,0),'
       //                                           opIdealCube
                +   'zoned('
                +     'translate(substr(opdata,5,2),''0'','' '')'
                +     ',2,0),'
       //                                           opMinPallets
                +   'zoned('
                +     'translate(substr(opdata,7,2),''0'','' '')'
                +     ',2,0),'
       //                                           opSideWgt
                +   'zoned('
                +     'translate(substr(opdata,9,2),''0'','' '')'
                +     ',2,0),'
       //                                           opZoneWgt
                +   'zoned('
                +     'translate(substr(opdata,11,2),''0'','' '')'
                +     ',2,0),'
       //                                           opZoneCube
                +   'zoned('
                +     'translate(substr(opdata,13,2),''0'','' '')'
                +     ',2,0),'
       //                                           opMinStops
                +   'zoned('
                +     'translate(substr(opdata,15,2),''0'','' '')'
                +     ',2,0),'
       //                                           opBulkhead
                +   'zoned('
                +     'translate(substr(opdata,17,2),''0'','' '')'
                +     ',2,0)'
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
                + 'field view - 7.40''';

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
                +   'opwhse is ''Warehouse           '','
                +   'opSplitItem is ''No Split Items      '','
                +   'opSplitStop is ''No Split Stops      '','
                +   'opIdealCube is ''Build to Ideal Cube '','
                +   'opMinPallets is ''Minimize Pallets    '','
                +   'opSideWgt is ''Balance Side Wgt    '','
                +   'opZoneWgt is ''Balance Zone Wgt    '','
                +   'opZoneCube is ''Balance Zone Cube   '','
                +   'opMinStops is ''Minimize Stops on   '
                +                   'pallet '','
                +   'opBulkhead is ''Get to Bulkhead     '''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
