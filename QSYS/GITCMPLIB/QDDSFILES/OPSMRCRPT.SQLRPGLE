      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSTRAX  SQL View for OPTIONS *TRAX
     *  23 August 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
720 A*    08/23/18  KDE  7.20
     *      - Created.
730 A*    04/11/19  KDE  7.30
     *      - Remove email from options, add checkbox to include/exclude
     *        date/time in file name, and add number of days to archive
     *        and add number o days to purge from Archive
730aA*    05/08/19  KDE  7.30a
     *      - Remove Archvie and Purge days.  Controlled in IFS Purge GUI
     *        by directory
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
                     + 'CALL OPSTRAX (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*MRCRPT';
        view = 'OPSMRCRPT';
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
                +   'opip,'
                +   'opport,'
                +   'opdprt,'
                +   'opgsdv,'
                +   'opmusr,'
                +   'opcpre,'
                +   'opjobd,'
                +   'opdbsrc,'
                +   'opincldd,'
                +   'opincldt,'
                +   'oprptdir'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1  15 OPIP
                +   'substr(opdata,1,15),'
       //                                    16  200OPPORT
                +   'zoned('
                +     'translate(substr(opdata,16,5),''0'','' '')'
                +   ',5,0),'
       //                                    21  30 OPDPRT
                +   'substr(opdata,21,10),'
       //                                    31  39 OPGSDV
                +   'substr(opdata,31,9),'
       //                                    40  49 OPMUSR
                +   'substr(opdata,40,10),'
       //                                    50  52 OPCPRE
                +   'substr(opdata,50,3),'
       //                                    53  62 OPJOBD
                +   'substr(opdata,53,10),'
       //                                    63  92 OPDBSRC
                +   'substr(opdata,63,30),'
       //                                    93  93 OPINCLDD
                +   'substr(opdata,93,1),'
       //                                    94  94 OPINCLDT
                +   'substr(opdata,94,1),'
       //                                    95  95 OPRPTDIR
                +   'substr(opdata,95,1)'
                + ' from ' + %trim(pfLibFile)
                + ' where opcode = ' + sq + %trim(code) + sq
                + ')';

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
                + 'field view - 7.20''';

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
                +   'opip is ''Tomcat '
                +               'IP'','
                +   'opport is ''Tomcat '
                +               'Port'','
                +   'opdprt is ''Default '
                +               'Printer'','
                +   'opgsdv is ''GhostScript '
                +               'Device (ljet4)'','
                +   'opmusr is ''MRC '
                +               'User'','
                +   'opcpre is ''Customer '
                +               'Prefix'','
                +   'opjobd is ''Runtime '
                +               'JOBD'','
                +   'opdbsrc is ''Runtime '
                +               'Datasource'','
                +   'opincldd is ''Include '
                +               'Date in File Name'','
                +   'opincldt is ''Include '
                +               'Time in File Name'','
                +   'oprptdir is ''Include '
                +               'Report in Directory Structure'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
