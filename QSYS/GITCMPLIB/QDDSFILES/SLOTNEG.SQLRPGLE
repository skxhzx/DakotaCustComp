      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  SLOTNEG    SQL View for SLOGNEG - Negative Slots with other slots
     *  11 Spt 2017
     *  Kenneth Elder
     *
     *  Revisions
     *
710 A*    09/11/17  KDE  7.10
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cityline
CLD A*    11/12/18  KDE  CLD
     *      - Revised exclude certain slots
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

CLD A*----------------------------------------------------------------
CLD A*  Customer id
CLD A*----------------------------------------------------------------
CLD A
CLD A /copy qcopysrc,id#citylin

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
                     + 'CALL SLOTNEG (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'SLOTNEG';
        view = 'SLOTNEGV';
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

       //sqlstmt = 'create view ' + %trimr(viewLibFile) + ' '
       //+ 'as (SELECT '
       //+ 's1.slwhse,s1.slwhdp,s1.sldisp,s1.slitem,s1.slstk1,s1.slstk2,'
       //+ ' s1.slstk3 from slot as s1 left outer join piritem as i on '
       //+ 's1.slwhse=i.itwhse and s1.slwhdp=i.itwhdp and '
       //+ 's1.slitem=i.ititem '
       //+ ' where (select count(*) from slot as s2 where '
       //+ 's1.slwhse=s2.slwhse and s1.slwhdp=s2.slwhdp and '
       //+ 's1.slitem=s2.slitem and (s2.slstk1<0 or s2.slstk2<0'
       //+ 'or slstk3<0))<>0 '
       //+ ')';
       sqlstmt = 'create view ' + %trimr(viewLibFile) + ' '
       + 'as (SELECT '
       + 's1.slwhse,s1.slwhdp,s1.sldisp,s1.slitem, s1.slstyp, '
       + 's1.slpick '
       + ' from slot as s1 left outer join piritem as i on '
       + 's1.slwhse=i.itwhse and s1.slwhdp=i.itwhdp and '
       + 's1.slitem=i.ititem '
        + ' where (select count(*) from slot as s2 where '
        + 's1.slwhse=s2.slwhse and s1.slwhdp=s2.slwhdp and '
        + 's1.slitem=s2.slitem and '
        + '(((((s2.slstk1+s2.slrcv1)-s2.sltfr1)-s2.slpck1)-s2.slalc1) < 0 or '
        + '((((s2.slstk2+s2.slrcv2)-s2.sltfr2)-s2.slpck2)-s2.slalc2) < 0 or '
        + '((((s2.slstk3+s2.slrcv3)-s2.sltfr3)-s2.slpck3)-s2.slalc3) <  0 '
CLD D   // + ')) <> 0)';
CLD M   + ')) <> 0';

CLD A   // Exclude slots M-519-2, M-400-1, M-400-2 and M-404-1
CLD A   // when client is City Line
CLD A   if client = cityline;
CLD A      sqlStmt = %trim(sqlStmt) + ' and substring(s1.sldisp,1,7)'
CLD A              + '<>' + sq + 'M-519-2' + sq + ' and '
CLD A              + 'substring(s1.sldisp,1,7)<>' + sq + 'M-400-1' + sq
CLD A              + ' and substring(s1.sldisp,1,7)<>' + sq + 'M-400-2'
CLD A              + sq + ' and substring(s1.sldisp,1,7)<>' + sq +
CLD A              'M-404-1' + sq;
CLD A   endif;
CLD A   sqlStmt = %trim(sqlStmt) + ')';

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

        // Add comment to file

        sqlstmt = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''Distinct Levels''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' '
                + 'Negative Slot 7.10''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free

CLD A*----------------------------------------------------------------
CLD A*  *Inzsr  Initialization subroutine
CLD A*----------------------------------------------------------------
CLD A
CLD A /free
CLD A  begsr *Inzsr;
CLD A
CLD A /end-free
CLD A
CLD A * Get client id.
CLD A
CLD AC                   call      'GETCLIENT'
CLD AC                   parm                    client           10
CLD A /free
CLD A
CLD A  endsr;
CLD A /end-free
