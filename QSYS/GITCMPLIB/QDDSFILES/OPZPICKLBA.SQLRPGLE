      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPZPICKLBA   SQL View for OPTIONZ *PICKLBA
     *  13 September 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    09/13/11  DAS  6.40
     *      - Created.
     *
760aA*    03/30/22  DAS  7.60a
     *      - Added OPPCK1 - Suppress Pick Desktop Printing
     *              OPBLK1 - Suppress Bulk Desktop Printing
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
        code = '*PICKLBA';
        view = 'OPZPICKLBA';
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
                +   'oplb1,'
                +   'opcu1,'
                +   'oplp1,'
                +   'opdv1,'
                +   'opfm1,'
760aA           +   'oppck1,'
760aA           +   'opblk1,'
                +   'oplb2,'
                +   'opcu2,'
                +   'oplp2,'
                +   'opdv2,'
                +   'opfm2,'
                +   'oplb3,'
                +   'opcu3,'
                +   'oplp3,'
                +   'opdv3,'
                +   'opfm3'
                + ') '
                + 'as ('
                + 'select '
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
       // oplb1                  1      1
                +   'substr(opzdta,1,1),'
       // opcu1                  2      2
                +   'substr(opzdta,2,1),'
       // oplp1                  3     12
                +   'substr(opzdta,3,10),'
       // opdv1                 13     22
                +   'substr(opzdta,13,10),'
       // opfm1                 23     32
                +   'substr(opzdta,23,10),'
760aA  // opplt1                97     97
760aA           +   'substr(opzdta,97,1),'
760aA  // opblk1                98     98
760aA           +   'substr(opzdta,98,1),'
       // oplb2                 33     33
                +   'substr(opzdta,33,1),'
       // opcu2                 34     34
                +   'substr(opzdta,34,1),'
       // oplp2                 35     44
                +   'substr(opzdta,35,10),'
       // opdv2                 45     54
                +   'substr(opzdta,45,10),'
       // opfm2                 55     64
                +   'substr(opzdta,55,10),'
       // oplb3                 65     65
                +   'substr(opzdta,65,1),'
       // opcu3                 66     66
                +   'substr(opzdta,66,1),'
       // oplp3                 67     76
                +   'substr(opzdta,67,10),'
       // opdv3                 77     86
                +   'substr(opzdta,77,10),'
       // opfm3                 87     96
                +   'substr(opzdta,87,10)'

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
                +   'oplb1  is ''Std Pick Lbl        '
                +               'Print'','
                +   'opcu1  is ''Std Pick Lbl        '
                +               'Cutter'','
                +   'oplp1  is ''Std Pick Lbl        '
                +               'Program'','
                +   'opdv1  is ''Std Pick Lbl        '
                +               'Device'','
                +   'opfm1  is ''Std Pick Lbl        '
                +               'Form'','
760aA           +   'oppck1 is ''Std Pick Lbl        '
760aA           +               'Suppress Pck desktop'','
760aA           +   'opblk1 is ''Std Pick Lbl        '
760aA           +               'Suppress Blk desktop'','
                +   'oplb2  is ''Retail Lbl          '
                +               'Print'','
                +   'opcu2  is ''Retail Lbl          '
                +               'Cutter'','
                +   'oplp2  is ''Retail Lbl          '
                +               'Program'','
                +   'opdv2  is ''Retail Lbl          '
                +               'Device'','
                +   'opfm2  is ''Retail Lbl          '
                +               'Form'','
                +   'oplb3  is ''Tote Lbl            '
                +               'Print'','
                +   'opcu3  is ''Tote Lbl            '
                +               'Cutter'','
                +   'oplp3  is ''Tote Lbl            '
                +               'Program'','
                +   'opdv3  is ''Totel Lbl           '
                +               'Device'','
                +   'opfm3  is ''Tote Lbl            '
                +               'Form'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
