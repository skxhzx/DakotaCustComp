      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPZPICKLBB   SQL View for OPTIONZ *PICKLBB
     *  13 September 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    09/13/11  DAS  6.40
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
        code = '*PICKLBB';
        view = 'OPZPICKLBB';
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
                +   'oplb4,'
                +   'opcu4,'
                +   'oplp4,'
                +   'opdv4,'
                +   'opfm4,'
                +   'oplb5,'
                +   'opcu5,'
                +   'oplp5,'
                +   'opdv5,'
                +   'opfm5,'
                +   'oplb6,'
                +   'opcu6,'
                +   'oplp6,'
                +   'opdv6,'
                +   'opfm6,'
                +   'oplb7'
                + ') '
                + 'as ('
                + 'select '
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
       // oplb4                  1      1
                +   'substr(opzdta,1,1),'
       // opcu4                  2      2
                +   'substr(opzdta,2,1),'
       // oplp4                  3     12
                +   'substr(opzdta,3,10),'
       // opdv4                 13     22
                +   'substr(opzdta,13,10),'
       // opfm4                 23     32
                +   'substr(opzdta,23,10),'
       // oplb5                 33     33
                +   'substr(opzdta,33,1),'
       // opcu5                 34     34
                +   'substr(opzdta,34,1),'
       // oplp5                 35     44
                +   'substr(opzdta,35,10),'
       // opdv5                 45     54
                +   'substr(opzdta,45,10),'
       // opfm5                 55     64
                +   'substr(opzdta,55,10),'
       // oplb6                 65     65
                +   'substr(opzdta,65,1),'
       // opcu6                 66     66
                +   'substr(opzdta,66,1),'
       // oplp6                 67     76
                +   'substr(opzdta,67,10),'
       // opdv6                 77     86
                +   'substr(opzdta,77,10),'
       // opfm6                 87     96
                +   'substr(opzdta,87,10),'
       // oplb7                 97     97
                +   'substr(opzdta,97,1)'

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
                +   'oplb4  is ''Pick List Lbl       '
                +               'Print'','
                +   'opcu4  is ''Pick List Lbl       '
                +               'Cutter'','
                +   'oplp4  is ''Pick List Lbl       '
                +               'Program'','
                +   'opdv4  is ''Pick List Lbl       '
                +               'Device'','
                +   'opfm4  is ''Pick List Lbl       '
                +               'Form'','
                +   'oplb5  is ''ASN Lbl             '
                +               'Print'','
                +   'opcu5  is ''ASN Lbl             '
                +               'Cutter'','
                +   'oplp5  is ''ASN Lbl             '
                +               'Program'','
                +   'opdv5  is ''ASN Lbl             '
                +               'Device'','
                +   'opfm5  is ''ASN Lbl             '
                +               'Form'','
                +   'oplb6  is ''Pick List Rpt       '
                +               'Print'','
                +   'opcu6  is ''Pick List Rpt       '
                +               'Cutter'','
                +   'oplp6  is ''Pick List Rpt       '
                +               'Program'','
                +   'opdv6  is ''Pick List Rpt       '
                +               'Device'','
                +   'opfm6  is ''Pick List Rpt       '
                +               'Form'','
                +   'oplb7  is ''Pint PICK Lbls For  '
                +               'ZONPKUP D/S'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
