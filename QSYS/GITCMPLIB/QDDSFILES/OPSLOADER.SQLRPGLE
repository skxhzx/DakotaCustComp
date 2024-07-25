      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSLOADER  SQL View for OPTIONS *LOADER
     *  21 December 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    12/21/11  RBD  6.40
     *      - Created.
     *
740aA*    09/28/20  RBD  7.40a
     *      - Added opldor, optlid, oprwcl, opvypl, opvfyp, opaddo,
     *        opeqip, opbypl and opbypr ... which yours truly forgot
     *        to add over the years.
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
                     + 'CALL OPSLOADER (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*LOADER';
        view = 'OPSLOADER';
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
                +   'opsttm,'
                +   'opentm,'
740aA           +   'opldor,'
740aA           +   'optlid,'
740aA           +   'oprwcl,'
740aA           +   'opvypl,'
740aA           +   'opvfyp,'
740aA           +   'opaddo,'
740aA           +   'opeqip,'
740aA           +   'opbypl,'
740aA           +   'opbypr'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   60OPSTTM
                +   'zoned('
                +     'translate(substr(opdata,1,6),''0'','' '')'
                +   ',6,0),'
       //                                     7  120OPENTM
                +   'zoned('
                +     'translate(substr(opdata,7,6),''0'','' '')'
                +   ',6,0),'
740aA  //                                    13  13 OPLDOR
740aA           +   'substr(opdata,13,1),'
740aA  //                                    14  14 OPTLID
740aA           +   'substr(opdata,14,1),'
740aA  //                                    15  15 OPRWCL
740aA           +   'substr(opdata,15,1),'
740aA  //                                    16  16 OPVYPL
740aA           +   'substr(opdata,16,1),'
740aA  //                                    17  17 OPVFYP
740aA           +   'substr(opdata,17,1),'
740aA  //                                    18  18 OPADDO
740aA           +   'substr(opdata,18,1),'
740aA  //                                    19  19 OPEQIP
740aA           +   'substr(opdata,19,1),'
740aA  //                                    20  20 OPBYPL
740aA           +   'substr(opdata,20,1),'
740aA  //                                    21  21 OPBYPR
740aA           +   'substr(opdata,21,1)'
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
                +   'opsttm is ''Earliest route load '
                +               'start time'','
                +   'opentm is ''Latest route load   '
                +               'end time'','
740aA           +   'opldor is ''Loading order       '','
740aA           +   'optlid is ''Speak trailer id    '','
740aA           +   'oprwcl is ''Speak row/column    '','
740aA           +   'opvypl is ''Verify pallet pos   '','
740aA           +   'opvfyp is ''Vfy pal to pick lbl '','
740aA           +   'opaddo is ''Auto define addons  '','
740aA           +   'opeqip is ''Load equip by zone  '','
740aA           +   'opbypl is ''Bypass qty at load  '','
740aA           +   'opbypr is ''Bypass qty at rtn   '''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
