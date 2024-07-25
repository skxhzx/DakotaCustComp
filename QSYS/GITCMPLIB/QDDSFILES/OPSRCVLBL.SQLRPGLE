      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSRCVLBL  SQL View for OPTIONS *RCVLBL
     *  20 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/20/11  RBD  6.40
     *      - Created.
710aA*    07/20/17  LMC  7.10a
     *      - Added new fields
740aA*    07/14/20  LMC  7.40a
     *      - Added new fields
750aA*    12/13/21  LMC  7.50a
     *      - Added new fields OPSPCK & OPSBRD
760aA*    05/09/22  LMC  7.60a
     *      - Added new fields OPNUPC
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
                     + 'CALL OPSRCVLBL (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*RCVLBL';
        view = 'OPSRCVLBL';
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
                +   'oplpgm,'
                +   'opupct,'
                +   'oppdef,'
                +   'oppbld,'
                +   'oppact,'
                +   'opfdef,'
                +   'opfasl,'
                +   'opfsid,'
                +   'opflvl,'
                +   'oppasl,'
                +   'oppfrc,'
                +   'opplcn,'
                +   'oppchm,'
                +   'oppmix,'
                +   'opapck,'
                +   'opfrcm,'
                +   'opexck,'
                +   'opcwen,'
                +   'opcwtp,'
                +   'opcwfr,'
                +   'opipck,'
                +   'oprupc,'
                +   'oprups,'
                +   'oprupf,'
                +   'opmspo,'
710aA           +   'opmplt,'
710aA           +   'oppexp,'
740aA           +   'oplotr,'
740aA           +   'oppsra,'
740aA           +   'oppltd,'
740aA           +   'opossA,'
740aA           +   'opsqto,'
740aA           +   'opbrka,'
740aA           +   'opexpe,'
740aA           +   'opspn1,'
740aA           +   'opspn2,'
740aA           +   'opspn3,'
750aA           +   'opspck,'
750aA           +   'opsbrd,'
760aA           +   'opnupc'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1  10 OPLPGM
                +   'substr(opdata,1,10),'
       //                                    11  130OPUPCT
                +   'zoned('
                +     'translate(substr(opdata,11,3),''0'','' '')'
                +   ',3,0),'
       //                                    14  140OPPDEF
                +   'zoned('
                +     'translate(substr(opdata,14,1),''0'','' '')'
                +   ',1,0),'
       //                                    15  150OPPBLD
                +   'zoned('
                +     'translate(substr(opdata,15,1),''0'','' '')'
                +   ',1,0),'
       //                                    16  160OPPACT
                +   'zoned('
                +     'translate(substr(opdata,16,1),''0'','' '')'
                +   ',1,0),'
       //                                    17  170OPFDEF
                +   'zoned('
                +     'translate(substr(opdata,17,1),''0'','' '')'
                +   ',1,0),'
       //                                    18  180OPFASL
                +   'zoned('
                +     'translate(substr(opdata,18,1),''0'','' '')'
                +   ',1,0),'
       //                                    19  190OPFSID
                +   'zoned('
                +     'translate(substr(opdata,19,1),''0'','' '')'
                +   ',1,0),'
       //                                    20  200OPFLVL
                +   'zoned('
                +     'translate(substr(opdata,20,1),''0'','' '')'
                +   ',1,0),'
       //                                    21  210OPPASL
                +   'zoned('
                +     'translate(substr(opdata,21,1),''0'','' '')'
                +   ',1,0),'
       //                                    22  22 OPPFRC
                +   'substr(opdata,22,1),'
       //                                    23  23 OPPLCN
                +   'substr(opdata,23,1),'
       //                                    24  24 OPPCHM
                +   'substr(opdata,24,1),'
       //                                    25  25 OPPMIX
                +   'substr(opdata,25,1),'
       //                                    26  26 OPAPCK
                +   'substr(opdata,26,1),'
       //                                    27  27 OPFRCM
                +   'substr(opdata,27,1),'
       //                                    28  28 OPEXCK
                +   'substr(opdata,28,1),'
       //                                    29  29 OPCWEN
                +   'substr(opdata,29,1),'
       //                                    30  30 OPCWTP
                +   'substr(opdata,30,1),'
       //                                    31  31 OPCWFR
                +   'substr(opdata,31,1),'
       //                                    32  32 OPIPCK
                +   'substr(opdata,32,1),'
       //                                    33  33 OPRUPC
                +   'substr(opdata,33,1),'
       //                                    34  34 OPRUPS
                +   'substr(opdata,34,1),'
       //                                    35  35 OPRUPF
                +   'substr(opdata,35,1),'
       //                                    36  36 OPMSPO
                +   'substr(opdata,36,1),'
       //                                    37  37 OPMPLT
                +   'substr(opdata,37,1),'
       //                                    38  38 OPPEXP
                +   'substr(opdata,38,1),'
740aA  //                                    39  39 OPLOTR
740aA           +   'substr(opdata,39,1),'
740aA  //                                    40  40 OPPSRA
740aA           +   'substr(opdata,40,1),'
740aA  //                                    41  41 OPPLTD
740aA           +   'substr(opdata,41,1),'
740aA  //                                    42  42 OPOSSA
740aA           +   'substr(opdata,42,1),'
740aA  //                                    43  43 OPSQTO
740aA           +   'substr(opdata,43,1),'
740aA  //                                    44  44 OPBRKA
740aA           +   'substr(opdata,44,1),'
740aA  //                                    45  45 OPEXPE
740aA           +   'substr(opdata,45,1),'
740aA  //                                    46  46 OPSPN1
740aA           +   'substr(opdata,46,1),'
740aA  //                                    47  490OPSPN2
740aA           +   'zoned('
740aA           +     'translate(substr(opdata,47,3),''0'','' '')'
740aA           +   ',3,0),'
740aA  //                                    50  59 OPSPN3
740aA           +   'substr(opdata,50,10),'
740aA  //                                    60  60 OPSPCK
740aA           +   'substr(opdata,60,1),'
740aA  //                                    61  61 OPSBRD
740aA           +   'substr(opdata,61,1),'
760aA  //                                    62  62 OPNUPC
760aA           +   'substr(opdata,62,1)'
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
                +   'oplpgm is ''Receiving           '
                +               'label pgm'','
                +   'opupct is ''Ideal slot usage    '
                +               'percentage'','
                +   'oppdef is ''PIR min # of        '
                +               'slots priority'','
                +   'oppbld is ''PIR same build      '
                +               'code priority'','
                +   'oppact is ''PIR same activity   '
                +               'zone priority'','
                +   'opfdef is ''Fixed min # of      '
                +               'slots priority'','
                +   'opfasl is ''Fixed same          '
                +               'aisle priority'','
                +   'opfsid is ''Fixed same          '
                +               'side priority'','
                +   'opflvl is ''Fixed highest       '
                +               'level priority'','
                +   'oppasl is ''PIR same            '
                +               'aisle priority'','
                +   'oppfrc is ''Force PIR same      '
                +               'aisle priority'','
                +   'opplcn is ''Use generic         '
                +               'license plates'','
                +   'oppchm is ''Check               '
                +               'chimney'','
                +   'oppmix is ''Allow mixed exp dtes'
                +               'in fixed home slot'','
                +   'opapck is ''Assgn pck slots auto'
                +               'for fixed items'','
                +   'opfrcm is ''Force marking of all'
                +               'PO detail lines'','
                +   'opexck is ''Expiration          '
                +               'date check'','
                +   'opcwen is ''Allow C/W           '
                +               'entry'','
                +   'opcwtp is ''C/W value           '
                +               'entered'','
                +   'opcwfr is ''Force C/W           '
                +               'entry'','
                +   'opipck is ''Ignore existing     '
                +               'pick slots'','
                +   'oprupc is ''Prompt Retail UPC   '
                +               'during receiving'','
                +   'oprups is ''Allow to skip       '
                +               'Retail UPC scan'','
                +   'oprupf is ''Require Retail UPC  '
                +               'before receipt'','
                +   'opmspo is ''Allow single PO to  '
                +               'multiple Super P/Os'','
                +   'opmplt is ''Allow Gui Multiple  '
                +               'pallet Receiving'','
                +   'oppexp is ''Allow partial Export'','
740aA           +   'oplotr is ''Lot Required if Lot '
740aA           +               'item'','
740aA           +   'oppsra is ''Allow Pick Slot     '
740aA           +               'receiving'','
740aA           +   'oppltd is ''Default pallets     '
740aA           +               'to 1'','
740aA           +   'opossa is ''Allow offsite       '
740aA           +               'storage receipt'','
740aA           +   'opsqto is ''Show qty orderded   '
740aA           +               'during receving'','
740aA           +   'opbrka is ''Allow Breakdown     '
740aA           +               'Qty to be received'','
740aA           +   'opexpe is ''Expiration date     '
740aA           +               'error/warning'','
740aA           +   'opspn1 is ''Spin pallet for     '
740aA           +               'license placement'','
740aA           +   'opspn2 is ''Spin pallet length  '','
740aA           +   'opspn3 is ''Spin pallet text    '','
750aA           +   'opspck is ''Show Pack Desc      '','
750aA           +   'opsbrd is ''Show Brand          '','
760aA           +   'opnupc is ''Do Not Allow UPCs to'
760aA           +               ' be loaded in receiving'''
                + ')';

        debugStr1 = %subst(sqlstmt:1:1000);
        debugStr2 = %subst(sqlstmt:1001);

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
