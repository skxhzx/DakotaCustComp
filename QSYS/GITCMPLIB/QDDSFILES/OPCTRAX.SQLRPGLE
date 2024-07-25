      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPCTRAX  SQL View for OPTIONC *TRAX Customer level
     *  05 March 2018
     *  Retha Davis
     *
     *  Revisions
     *
720 A*    03/05/18  RBD  7.20
     *      - Created.
     *
730 A*    03/13/19  RBD  7.30
     *      - Added opcsor, opcodx, opcodp, opcont, opcotp and opcnsb.
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
                     + 'CALL OPCTRAX (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONC';
        code = '*TRAX';
        view = 'OPCTRAX';
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
                +   'opcwhs,'
                +   'opccus,'
                +   'opccwr,'
                +   'opcbda,'
                +   'opcgbd,'
                +   'opcrtq,'
                +   'opcotq,'
                +   'opccce,'
                +   'opcsig,'
                +   'opcpiv,'
                +   'opcsda,'
                +   'opcare,'
                +   'opcpal,'
                +   'opcbul,'
                +   'opcgss,'
                +   'opcgsu,'
                +   'opcnsr,'
                +   'opcfbd,'
730 A           +   'opcsor,'
730 A           +   'opcodx,'
730 A           +   'opcodp,'
730 A           +   'opcont,'
730 A           +   'opcotp,'
730 A           +   'opcnsb'
                + ') '
                + 'as ('
                + 'select '
                +   'opcwhs,'
                +   'opccus,'
       //                                     5   5 OPCCWR
                +   'substr(opcdta,5,1),'
       //                                    14  14 OPCBDA
                +   'substr(opcdta,14,1),'
       //                                    15  15 OPCGBD
                +   'substr(opcdta,15,1),'
       //                                    16  16 OPCRTQ
                +   'substr(opcdta,16,1),'
       //                                    17  17 OPCOTQ
                +   'substr(opcdta,17,1),'
       //                                    18  18 OPCCCE
                +   'substr(opcdta,18,1),'
       //                                    19  19 OPCSIG
                +   'substr(opcdta,19,1),'
       //                                    20  20 OPCPIV
                +   'substr(opcdta,20,1),'
       //                                    21  21 OPCSDA
                +   'substr(opcdta,21,1),'
       //                                    76  76 OPCARE
                +   'substr(opcdta,76,1),'
       //                                    79  79 OPCPAL
                +   'substr(opcdta,79,1),'
       //                                    82  82 OPCBUL
                +   'substr(opcdta,82,1),'
       //                                    89  89 OPCGSS
                +   'substr(opcdta,89,1),'
       //                                    90  90 OPCGSU
                +   'substr(opcdta,90,1),'
       //                                   100 100 OPCNSR
                +   'substr(opcdta,100,1),'
       //                                   101 101 OPCFBD
                +   'substr(opcdta,101,1),'
730 A  //                                   103 103 OPCSOR
730 A           +   'substr(opcdta,103,1),'
730 A  //                                   104 104 OPCODX
730 A           +   'substr(opcdta,104,1),'
730 A  //                                   105 1060OPCODP
730 A           +   'zoned('
730 A           +     'translate(substr(opcdta,105,2),''0'','' '')'
730 A           +   ',2,0),'
730 A  //                                   107 107 OPCONT
730 A           +   'substr(opcdta,107,1),'
730 A  //                                   108 108 OPCOTP
730 A           +   'substr(opcdta,108,1),'
730 A  //                                   109 109 OPCNSB
730 A           +   'substr(opcdta,109,1)'
                + ' from ' + %trim(pfLibFile)
                + ' where opccod = ' + sq + %trim(code) + sq
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
                + 'field view - 7.30''';

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
                +   'opccwr is ''Catchweight '
                +               'required'','
                +   'opcbda is ''Breakdowns '
                +               'allowed'','
                +   'opcgbd is ''Generic breakdown '
                +               'allowed'','
                +   'opcrtq is ''Pre-trip '
                +               'questions'','
                +   'opcotq is ''Post-trip '
                +               'questions'','
                +   'opccce is ''Credit card '
                +               'enabled'','
                +   'opcsig is ''Signature '
                +               'enabled'','
                +   'opcpiv is ''Print '
                +               'invoice'','
                +   'opcsda is ''Send data '
                +               'after stop'','
                +   'opcare is ''Add return '
                +               'enabled'','
                +   'opcpal is ''Pallets '
                +               'enabled'','
                +   'opcbul is ''Bulk items '
                +               'enabled'','
                +   'opcgss is ''GS1 '
                +               'scanning'','
                +   'opcgsu is ''GS1 '
                +               'unique'','
                +   'opcnsr is ''Non scan reason '
                +               'prompt'','
                +   'opcfbd is ''Filter by '
                +               'department'','
730 A           +   'opcsor is ''Sort items by '
730 A           +               'compartment'','
730 A           +   'opcodx is ''Cust on site delivery '
730 A           +               'enable'','
730 A           +   'opcodp is ''Cust on site delivery '
730 A           +               'verification period'','
730 A           +   'opcont is ''On truck '
730 A           +               'picking'','
730 A           +   'opcotp is ''Override truck '
730 A           +               'picking'','
730 A           +   'opcnsb is ''No signee button on '
730 A           +               'signature screen'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
