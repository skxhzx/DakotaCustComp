      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSSYSTEM  SQL View for OPTIONS *SYSTEM
     *  22 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/22/11  RBD  6.40
     *      - Created.
     *
640aA*    08/13/12  DAS  6.40a
     *      - Added optaxr, opchkr, opvoice.
     *
750 A*    04/13/21  KDE  7.50
     *      - Added opsrte (Super Routes Allowed)
     *
750aA*    08/26/21  KDE  7.50a
     *      - Added optrna (Auto Assignment Selection)
     *      - Added opsrta (Auto Assignment Selection Order)
     *
750bA*    09/15/21  KDE  7.50b
     *      - Change positions of OPSRTE, OPTRNA, OPSRTA, and OPTALL
     *
750cA*    01/31/22  KDE  7.50c
     *      - Add option for Dock Vue under System Modules
     *
760 A*    04/25/22  KDE  7.60
     *      - Add additional options for Auto Assignment
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
                     + 'CALL OPSSYSTEM (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*SYSTEM';
        view = 'OPSSYSTEM';
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
                +   'opepm,'
                +   'oprf,'
                +   'opcapc,'
                +   'opletd,'
                +   'opwrnc,'
                +   'oprg1c,'
                +   'oprg2c,'
                +   'opimpi,'
                +   'opicw,'
                +   'opmpck,'
                +   'oprcdy,'
                +   'oppkdy,'
                +   'oprths,'
                +   'opcrhs,'
                +   'oppohs,'
                +   'opiahs,'
                +   'opmshs,'
                +   'optbjq,'
                +   'opishs,'
                +   'opuci,'
                +   'opwrncr,'
                +   'opicwr,'
                +   'optrax,'
640aA           +   'optaxr,'
640aA           +   'opchkr,'
750 M           +   'opvoice,'
750 M           +   'opslot,'
750 M           +   'opdspl,'
750 M           +   'optbpm,'
750 A           +   'opsrte,'
750aA           +   'optrna,'
750aA           +   'opsrta,'
750bA           +   'optall,'
750cA           +   'opdckv,'
760 A           +   'opaepf,'
760 A           +   'opaepo,'
760 A           +   'opamrt'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPEPM
                +   'substr(opdata,1,1),'
       //                                     2   2 OPRF
                +   'substr(opdata,2,1),'
       //                                     3   3 OPCAPC
                +   'substr(opdata,3,1),'
       //                                     4   4 OPLETD
                +   'substr(opdata,4,1),'
       //                                     5   5 OPWRNC
                +   'substr(opdata,5,1),'
       //                                     6   81OPRG1C
                +   'zoned('
                +     'translate(substr(opdata,6,2),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opdata,8,1),''0'','' '')'
                +   ',3,1),'
       //                                     9  111OPRG2C
                +   'zoned('
                +     'translate(substr(opdata,9,2),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opdata,11,1),''0'','' '')'
                +   ',3,1),'
       //                                    12  12 OPIMPI
                +   'substr(opdata,12,1),'
       //                                    13  13 OPICW
                +   'substr(opdata,13,1),'
       //                                    14  14 OPMPCK
                +   'substr(opdata,14,1),'
       //                                    15  150OPRCDY
                +   'zoned('
                +     'translate(substr(opdata,15,1),''0'','' '')'
                +   ',1,0),'
       //                                    16  160OPPKDY
                +   'zoned('
                +     'translate(substr(opdata,16,1),''0'','' '')'
                +   ',1,0),'
       //                                    17  190OPRTHS
                +   'zoned('
                +     'translate(substr(opdata,17,3),''0'','' '')'
                +   ',3,0),'
       //                                    20  220OPCRHS
                +   'zoned('
                +     'translate(substr(opdata,20,3),''0'','' '')'
                +   ',3,0),'
       //                                    23  250OPPOHS
                +   'zoned('
                +     'translate(substr(opdata,23,3),''0'','' '')'
                +   ',3,0),'
       //                                    26  280OPIAHS
                +   'zoned('
                +     'translate(substr(opdata,26,3),''0'','' '')'
                +   ',3,0),'
       //                                    29  310OPMSHS
                +   'zoned('
                +     'translate(substr(opdata,29,3),''0'','' '')'
                +   ',3,0),'
       //                                    32  32 OPTBJQ
                +   'substr(opdata,32,1),'
       //                                    33  350OPISHS
                +   'zoned('
                +     'translate(substr(opdata,33,3),''0'','' '')'
                +   ',3,0),'
       //                                    36  36 OPUCI
                +   'substr(opdata,36,1),'
       //                                    37  37 OPWRNCR
                +   'substr(opdata,37,1),'
       //                                    38  38 OPICWR
                +   'substr(opdata,38,1),'
       //                                    39  39 OPTRAX
                +   'substr(opdata,39,1),'
640aA  //                                    40  40 OPTAXR
640aA           +   'substr(opdata,40,1),'
640aA  //                                    41  41 OPCHKR
640aA           +   'substr(opdata,41,1),'
640aA  //                                    42  42 OPVOICE
640aA           +   'substr(opdata,42,1),'
640aA  //                                    43  43 OPSLOT
640aA           +   'substr(opdata,43,1),'
640aA  //                                    44  44 OPDSPL
640aA           +   'substr(opdata,44,1),'
640aA  //                                    45  45 OPTBPM
640aA           +   'substr(opdata,45,1),'
750bM  //                                    46  46 OPSRTE
750bM           +   'substr(opdata,46,1),'
750bM  //                                    47  47 OPTRNA
750bM           +   'substr(opdata,47,1),'
750bM  //                                    48  48 OPSRTA
750bM           +   'substr(opdata,48,1),'
750bM  //                                    49  49 OPTALL
750bM           +   'substr(opdata,49,1),'
750bM  //                                    50  50 OPDCKV
750bM           +   'substr(opdata,50,1),'
760 A  //                                    51  51 OPAEPF
760 A           +   'substr(opdata,51,1),'
760 A  //                                    52  52 OPAEPF
760 A           +   'substr(opdata,52,1),'
760 A  //                                    53  53 OPAMRT
760 A           +   'substr(opdata,53,1)'
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
                +   'opepm  is ''Using EPM           '
                +               'module'','
                +   'oprf   is ''Using RF            '
                +               'module'','
                +   'opcapc is ''Capture CWs at      '
                +               'pick closing'','
                +   'opletd is ''Print letdown       '
                +               'labels'','
                +   'opwrnc is ''Check CW var during '
                +               'selection closing'','
                +   'oprg1c is ''CW low var          '
                +               'percentage'','
                +   'oprg2c is ''CW high var         '
                +               'percentage'','
                +   'opimpi is ''Import item         '
                +               'fields from host'','
                +   'opicw  is ''Check CW cnt during '
                +               'selection closing'','
                +   'opmpck is ''Multiple pick slots '
                +               'for fixed items'','
                +   'oprcdy is ''# of days to keep   '
                +               'receiving logs'','
                +   'oppkdy is ''# of days to keep   '
                +               'picking logs'','
                +   'oprths is ''# of wks exported   '
                +               'routes to keep'','
                +   'opcrhs is ''# of wks exported   '
                +               'cust rtns to keep'','
                +   'oppohs is ''# of wks exported   '
                +               'POs to keep'','
                +   'opiahs is ''# of wks exported   '
                +               'inv adj to keep'','
                +   'opmshs is ''# of wks exported   '
                +               'misc trans to keep'','
                +   'optbjq is ''Run Truck Builder   '
                +               'on jobq'','
                +   'opishs is ''# of wks to keep    '
                +               'history file'','
                +   'opuci  is ''Use UCI             '
                +               'processing'','
                +   'opwrncr is ''Ck CW var during    '
                +               'receiving closing'','
                +   'opicwr is ''Ck CW cnt during    '
                +               'receiving closing'','
                +   'optrax is ''Using Trax          '
                +               'module'','
640aA           +   'optaxr is ''Using Tax Right     '
640aA           +               'module'','
640aA           +   'opchkr is ''Using Check         '
640aA           +               'Right module'','
640aA           +   'opvoice is ''Using Voice         '
640aA           +               'module'','
750 A           +   'opsrte  is ''Allow Super '
750 A           +               'Routes'','
750aA           +   'optrna  is ''On-Demand '
750aA           +               'Transactions'','
750aA           +   'opsrta  is ''On-Demand '
750aA           +               'Sort Order'','
750bA           +   'optall  is ''On-Demand '
750bA           +               'All/Select'','
750bA           +   'opdckv is ''Using Dockvue '
750bA           +               'Module'','
760 A           +   'opaepf is ''Assign Trans in order '
760 A           +               'of #pallet positions'','
760 A           +   'opaepo is ''** Open for Use '
760 A           +               ''','
760 A           +   'opamrt is ''Assign Trans from '
760 A           +               'multiple Route'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
