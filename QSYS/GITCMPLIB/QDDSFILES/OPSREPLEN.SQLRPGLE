      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSREPLEN  SQL View for OPTIONS *REPLEN
     *  04 October 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    10/04/11  RBD  6.40
     *      - Created.
     *
640aA*    08/13/12  DAS  6.40a
     *      - Added oprsrt
     *
720 A*    02/23/18  KDE  7.20
     *      - Added opskpr, opjitw, oplqty, opsslcn, oprzst
     *
740 A*    08/18/20  KDE  7.40
     *      - Added opckdd
     *
750 A*    08/13/21  KDE  7.50
     *      - Added opddmax
     *
750 A*    08/13/21  KDE  7.50
     *      - Added opddmax
     *
760aA*    09/15/22  KDE  7.60a
     *      - Added opddl
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
                     + 'CALL OPSREPLEN (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*REPLEN';
        view = 'OPSREPLEN';
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
                +   'oprplb,'
                +   'opoqrp,'
                +   'oprpex,'
                +   'oprpfi,'
                +   'oplmts,'
                +   'opcqty,'
                +   'opbdrp,'
720 M           +   'oprsrt,'
720 A           +   'opskpr,'
720 A           +   'opjitw,'
720 A           +   'oplqty,'
720 A           +   'opsslcn,'
720 A           +   'oprzst,'
740 A           +   'opckdd,'
750 A           +   'opddmax,'
760aA           +   'opddl'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   8 OPRPLB
                +   'substr(opdata,1,8),'
       //                                     9   9 OPOQRP
                +   'substr(opdata,9,1),'
       //                                    10  10 OPRPEX
                +   'substr(opdata,10,1),'
       //                                    11  11 OPRPFI
                +   'substr(opdata,11,1),'
       //                                    12  12 OPLMTS
                +   'substr(opdata,12,1),'
       //                                    13  13 OPCQTY
                +   'substr(opdata,13,1),'
       //                                    14  14 OPBDRP
                +   'substr(opdata,14,1),'
640aA  //                                    15  24 OPRSRT
640aA           +   'substr(opdata,15,10),'
720 A  //                                    25  25 OPSKPR
720 A           +   'substr(opdata,25,1),'
720 A  //                                    26  26 OPJITW
720 A           +   'substr(opdata,26,1),'
720 A  //                                    27  280OPLQTY
                +   'zoned('
                +     'translate(substr(opdata,27,2),''0'','' '')'
                +   ',2,0),'
720 A  //                                    29  29 OPSSLCN
720 A           +   'substr(opdata,29,1),'
720 A  //                                    30  31 OPRZST
720 A           +   'substr(opdata,30,2),'
740 A  //                                    32  32 OPCKDD
740 A           +   'substr(opdata,32,1),'
750 A  //                                    33  330OPDDMAX
750 A           +   'zoned('
750 A           +     'translate(substr(opdata,33,2),''0'','' '')'
750 A           +   ',2,0),'
760aA  //                                    35  35 OPDDL
760aA           +   'substr(opdata,35,1)'
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
                +   'oprplb is ''Replenishment basis '
                +               '*AVGQTY/*ORDQTY'','
                +   'opoqrp is ''Order               '
                +               'qty repl'','
                +   'oprpex is ''Allow repl on       '
                +               'expired items'','
                +   'oprpfi is ''Allow repl out      '
                +               'of FIFO order'','
                +   'oplmts is ''Limit Spec Slot repl'
                +               'disp 1 O/F at a time'','
                +   'opcqty is ''Check qty           '
                +               'of TO SLOT'','
                +   'opbdrp is ''Check for           '
                +               'bulk drops'','
640aA           +   'oprsrt is ''Sort                '
640aA           +               'Replenishment'','
720 A           +   'opskpr is ''Skip if Pck Slot    '
720 A           +               'Greater'','
720 A           +   'opjitw is ''No JITS             '
720 A           +               ' '','
720 A           +   'oplqty is ''Show only less this '
720 A           +               'Pck Slts'','
720 A           +   'opsslcn is ''Initiate Specific S '
720 A           +               'lot w/Lcns   '','
720 A           +   'oprzst is ''Slot Type when Pick '
720 A           +               'in Str and WH'','
740 A           +   'opckdd is ''Chk for Drop Pick '
740 A           +               'replens'','
740 A           +   'opddmax is ''Max items per Drop'
740 A           +               ' Pick Slot'','
760aA           +   'opddl   is ''Req license for DD'
760aA           +               ' Replen'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
