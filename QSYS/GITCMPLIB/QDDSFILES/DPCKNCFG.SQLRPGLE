      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  DPCKNCFG  Sql View over SLot and DRPRNGE to show overflow
     *            slots without Pick Slot but no Drop Pick Configuration
     *  14 May 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*    05/14/19  KDE  7.40
     *      - Created.
     *
750aA*    08/10/21  KDE  7.50a
     *      - Exclude items with Designation code
     *
750bA*    08/11/21  KDE  7.50b
     *      - Use libraries from parms in SQL statement
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
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

     D  debugStr1      s           1000
     D  debugStr2      s           1000
     D  file           s             10
     D  dsplyMsg       s             52
     D  pfLibFile      s             21
     d sltCnt          s              5  0
     d  sqlstmtx       s           2048
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
                     + 'CALL SLOT16 (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'SLOT';
        view = 'DPCKNCFG';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

        sqlstmtx = 'drop view ' + %trimr(viewLibFile);

        exec sql execute immediate :sqlstmtx;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

        sqlstmtx = 'create view ' + %trimr(viewLibFile) + ' '
                + 'as ('
                + 'select distinct '
                +   'a.slwhse,'
                +   'a.slwhdp,'
                +   'a.slitem,'
                +   'a.sldisp'
750bM           + ' from ' + %trim(pPFlib) + '/slot as a'
                + ' where a.slpick=' + sq + 'N' + sq
                + '  and a.slstat=' + sq + 'A' + sq
                + '  and a.sldesg<>' + sq + 'BFC' + sq
                + '  and (a.slstk1<>0 or a.slstk2<>0 or a.slstk3<>0)'
750bM           + '  and (select count(*) from ' + %trim(pPFLIB) + '/slot as b'
                + '  where a.slwhse=b.slwhse and a.slwhdp=b.slwhdp'
                + '  and  a.slitem=b.slitem and b.slpick=' + sq + 'Y' + sq
                + '  )=0 and '
750bM           + '  (select count(*) from ' + %trim(pPFLIB) + '/piritem where'
                + '   itwhse=a.slwhse and ititem=a.slitem and '
                + '   itstyp=' + sq + 'F' + sq + ')>0 and '
750bM           + '  (select count(*) from ' + %trim(pPFLIB) + '/piritem where'
750aA           + '   itwhse=a.slwhse and ititem=a.slitem and '
750aA           + '   (itdesg=' + sq + sq + ' or itdesg=' + sq
750aA           +      '*DROP' + sq + '))>0'
                + ')';





        debugStr1 = %subst(sqlstmtx:1:1000);
        debugStr2 = %subst(sqlstmtx:1001);

        exec sql execute immediate :sqlstmtx;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Add comment to file

        sqlstmtx = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''Overflow Drop Pick No Config''';

        exec sql execute immediate :sqlstmtx;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmtx = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' '
                + 'Overflow Drop Pick No Config view - 7.40''';

        exec sql execute immediate :sqlstmtx;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;
