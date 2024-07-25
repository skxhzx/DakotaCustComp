      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPZPICKLBL   SQL View for OPTIONZ *PICKLBL
     *  13 September 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    09/13/11  DAS  6.40
     *      - Created.
     *
650aA*    05/06/14  DAS  6.50a
     *      - operr defined incorrectly.
     *
760aA*    03/30/22  DAS  7.60a
     *      - Added OPRPLTO - Pallet label override
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
     *       +   'translate(substr(opzdta,1,7,''0'','' '')'
     *       + ',7,0)'
     *   - Example code for a 2 decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opzdta,16,3,''0'','' '')'
     *       +   '||''.''||'
     *       +   'translate(substr(opzdta,19,2,''0'','' '')'
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
            dsplyMsg = 'Error Missing Parm: '
                     + 'CALL OPZPICKLBL (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONZ';
        code = '*PICKLBL';
        view = 'OPZPICKLBL';
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
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
                +   'opclvl,'
                +   'opcwra,'
                +   'opcwrb,'
                +   'opuwra,'
                +   'opuwrb,'
                +   'optext,'
                +   'operr,'
                +   'opcwgt,'
                +   'oplpgm,'
                +   'oppdev,'
                +   'oppfrm,'
                +   'opaisl,'
                +   'optaxr,'
760aM           +   'opchkr,'
760aA           +   'oprplto'
                + ') '
                + 'as ('
                + 'select '
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
       // opclvl                 1      3  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,1,3),''0'','' '')'
                +   ',3,0),'
       // opcwra                 4      4
                +   'substr(opzdta,4,1),'
       // opcwrb                 5      5
                +   'substr(opzdta,5,1),'
       // opuwra                 6      6
                +   'substr(opzdta,6,1),'
       // opuwrb                 7      7
                +   'substr(opzdta,7,1),'
       // optext                 8     50
                +   'substr(opzdta,8,43),'
       // operr                 51     52  0 inz(0)
                +   'zoned('
650aM           +     'translate(substr(opzdta,51,2),''0'','' '')'
                +   ',2,0),'
       // opcwgt                53     54  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,53,2),''0'','' '')'
                +   ',2,0),'
       // oplpgm                55     64
                +   'substr(opzdta,55,10),'
300 A  // oppdev                65     74
                +   'substr(opzdta,65,10),'
300 A  // oppfrm                75     84
                +   'substr(opzdta,75,10),'
520 A  // opaisl                85     85
                +   'substr(opzdta,85,1),'
520 A  // optaxr                86     86
                +   'substr(opzdta,86,1),'
520 A  // opchkr                87     87
760aM           +   'substr(opzdta,87,1),'
760aA  // oprplto               88     88
760aA           +   'substr(opzdta,88,1)'

                + ' from ' + %trim(pfLibFile)
                + ' where opzcod = ' + sq + %trim(code) + sq
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
                +   'opclvl is ''Combined Label      '
                +               'Qty Level'','
                +   'opcwra is ''Print Combo         '
                +               'Warning After'','
                +   'opcwrb is ''Print Combo         '
                +               'Warning Before'','
                +   'opuwra is ''Print UOM           '
                +               'Warning After'','
                +   'opuwrb is ''Print UOM           '
                +               'Warning Before'','
                +   'optext is ''Last Label          '
                +               'Line Text'','
                +   'operr  is ''Error Label         '
                +               'Ratio'','
                +   'opcwgt is ''CWgt Label          '
                +               'Ratio'','
                +   'oplpgm is ''Pick Label          '
                +               'Program'','
                +   'oppdev is ''Printer Device'','
                +   'oppfrm is ''Printer Form'','
                +   'opaisl is ''Print Aisle         '
                +               'Change Label'','
                +   'optaxr is ''Include             '
                +               'TaxRight'','
                +   'opchkr is ''Include             '
760aM           +               'CheckRight'','
760aA           +   'oprplto is ''Pallet Label        '
760aA           +                'Override'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
