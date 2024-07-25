      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  SLOT18   SQL View for SLOT18 - Picks with later Expiration than Overflo
     *  23 May 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
720 A*    05/23/19  KDE  7.30
     *      - Created.
     *
740 A*    04/22/20  KDE  7.40
     *      - Ignore slots with zero quantity
     *
750aA*    03/07/22  RBD  7.50a
     *      - Ignore expired overflow slots.
     *
760aA*    11/06/22  DAS  7.60a
     *      - Ignore expired overflow slots.
     *
760bA*    12/14/22  KDE  7.60b
     *      - Include Drop Pick slots
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
750aAD  today          s              8  0
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
                     + 'CALL SLOT18 (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'SLOT';
        view = 'SLOT18';
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
        // The select clause selects any records in Slot where
        // the pick slot has a greater expiration than overflows

        sqlstmt = 'create view ' + %trimr(viewLibFile) + ' '
                + 'as ('
                + 'select '
                +   'slwhse,'
                +   'slwhdp,'
                +   'slaisl,'
                +   'slitem,'
                +   'sldisp,'
                +   'slpick,'
                +   'slentd,'
                +   'slexpd,'
                +   'slstk1,'
                +   'slstk2,'
                +   'slstk3'
                + ' from ' + %trim(pfLibFile) + ' as p'
760bD       //  + ' where (p.slpick=' + sq + 'Y' + sq + ' and p.slexpd<>0 and'
760bM           + ' where ((p.slpick=' + sq + 'Y' + sq + ' or '
760bA           + ' p.sldesg=' + sq + '*DROP' + sq + ')'
                + ' and p.slexpd<>0 and'
740 A           + ' (p.slstk1<>0 or p.slstk2<>0 or p.slstk3<>0) and'
760aD       //  + ' (select count(*) from slot as o'
760aM           + ' (select count(*) from ' + %trim(pfLibFile) + ' as o'
                + ' where p.slwhse=o.slwhse and p.slwhdp=o.slwhdp and'
760bD       //  + ' p.slitem=o.slitem and slpick<>' + sq + 'Y' +sq + ' and '
760bM           + ' p.slitem=o.slitem and o.slpick<>' + sq + 'Y' +sq + ' and '
760bA           + ' o.sldesg<>' + sq + '*DROP' + sq + ' and '
740 A           + ' (o.slstk1<>0 or o.slstk2<>0 or o.slstk3<>0) and'
                + ' p.slexpd>o.slexpd)<>0) or'
750aD       //  + ' (p.slpick<>' + sq + 'Y' + sq + ' and p.slexpd<>0 and'
750aM           + ' (p.slpick<>' + sq + 'Y' + sq
750aM           +    ' and p.slexpd>= ' + %char(today) + ' and '
760aD       //  + ' (select count(*) from slot as o'
760aM           + ' (select count(*) from  ' + %trim(pfLibFile) + ' as o'
                + ' where p.slwhse=o.slwhse and p.slwhdp=o.slwhdp and'
                + ' p.slitem=o.slitem and slpick=' + sq + 'Y' +sq + ' and '
740 A           + ' (o.slstk1<>0 or o.slstk2<>0 or o.slstk3<>0) and'
                + ' p.slexpd<o.slexpd)<>0)'
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

        // Add comment to file

        sqlstmt = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''Expiration Pick less Overflow''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' '
                + 'Pick Expiration less than Overflow(s)''';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free

750aA*----------------------------------------------------------------
750aA*          SUBROUTINES IN ALPHABETICAL ORDER
750aA*----------------------------------------------------------------

750aA*----------------------------------------------------------------
750aA*  *INZSR  Initialization subrotine
750aA*----------------------------------------------------------------

750aAc     *inzsr        begsr

750aA* Get today's date in ccyymmdd format

750aAc                   eval      today=%dec(%date():*iso)

750aAc                   endsr

     *----------------------------------------------------------------
