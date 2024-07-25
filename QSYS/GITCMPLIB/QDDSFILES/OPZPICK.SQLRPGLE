      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPZPICK    SQL View for OPTIONZ *PICK
     *  12 September 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    09/12/11  DAS  6.40
     *      - Created.
     *
640aA*    04/10/12  DAS  6.40a
     *      - Fix: OPTECB changed to have 2 decimal places.
     *
650aA*    05/06/14  DAS  6.50a
     *      - Added field oplbl
     *
700aA*    06/02/15  LMC  7.00a
     *      - Added field opdddo,opmcub,oppmtz,opgcde
     *
710aA*    06/05/17  LMC  7.10a
     *      - Added field opnbps
     *
720aA*    05/30/18  DAS  7.20a
     *      - Added fields opfwgt, opfplt, opbseq.
     *
720bA*    08/31/18  DAS  7.20b
     *      - Added field opsstp
     *
740aA*    05/27/20  DAS  7.40a
     *      - Added field ozrfzp
     *      - Needed to use a larger sqlstmt variable.
     *
740bA*    08/13/20  KDE  7.40b
     *      - Added fields opicub, oppisplt, opmscb, opmsvh,opmsvm,opmsvl,
     *        opoacb, opzplt, opbplt
     *
750 A*    02/18/21  KDE  7.50
     *      - Added field oppstuff
     *
750aA*    03/19/21  KDE  7.50
     *      - Added fields oppmsp, oppmstp, oppmord.  OPPMORD is not
     *        being used yet but will be in a future release
     *
760aA*    09/26/22  KDE  7.60a
     *      - Added field opppbs (pick by stop)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   - This does not include the USF OPGCDE field in pos 62.
     *     Instead it includes the standard OPPKUP field.
     *
700aA*   - This now includes USF OPGCDE field in pos 76.
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
740aAD  sqlstmt2       s           3000
     D  debugStr1      s           1000
     D  debugStr2      s           1000
740aAD  debugStr3      s           1000
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
                     + 'CALL OPZPICK (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONZ';
        code = '*PICK';
        view = 'OPZPICK';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

740aM   sqlstmt2 = 'drop view ' + %trimr(viewLibFile);

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

740aM   sqlstmt2 = 'create view ' + %trimr(viewLibFile) + ' '
                + '('
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
                +   'opnxtp,'
                +   'oppcub,'
                +   'opfpal,'
                +   'opfcub,'
                +   'opincl,'
                +   'opsrch,'
                +   'opfstp,'
                +   'opfbld,'
                +   'opbpck,'
                +   'oppbrk,'
                +   'oppbld,'
                +   'opselm,'
                +   'opsplt,'
                +   'opbmrg,'
                +   'opnwpl,'
                +   'opford,'
                +   'opptyp,'
                +   'opftot,'
                +   'optecb,'
                +   'opticb,'
                +   'optstp,'
                +   'optord,'
                +   'optpcs,'
                +   'opstop,'
                +   'oppkup,'
                +   'opspal,'
650aM           +   'oppitm,'
700aM           +   'oplbl,'
700aA           +   'opdddo,'
700aA           +   'opmcub,'
700aA           +   'oppmtz,'
700aA           +   'opgcde,'
710aA           +   'opnbps,'
720aA           +   'opfwgt,'
720aA           +   'opfplt,'
720aA           +   'opbseq,'
720bA           +   'opsstp,'
740aA           +   'ozrfzp,'
740bA           +   'opicub,'
740bA           +   'oppisplt,'
740bA           +   'opmscb,'
740bA           +   'opmsvh,'
740bA           +   'opmsvm,'
740bA           +   'opmsvl,'
740bA           +   'opoacb,'
740bA           +   'opzplt,'
740bA           +   'opbplt,'
750 A           +   'oppstuff,'
750aA           +   'oppmsp,'
750aA           +   'oppmstp,'
750aA           +   'oppmord,'
760aA           +   'opppbs'
                + ') '
                + 'as ('
                + 'select '
                +   'opzwhs,'
                +   'opztrk,'
                +   'opzzon,'
       // opnxtp                 1      7  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,1,7),''0'','' '')'
                +   ',7,0),'
       // oppcub                10     14  2 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,10,3),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opzdta,13,2),''0'','' '')'
                +   ',5,2),'
       // opfpal                15     15  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,15,1),''0'','' '')'
                +   ',1,0),'
       // opfcub                16     20  2 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,16,3),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opzdta,19,2),''0'','' '')'
                +   ',5,2),'
       // opincl                22     22
                +   'substr(opzdta,22,1),'
       // opsrch                23     24  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,23,2),''0'','' '')'
                +   ',2,0),'
       // opfstp                25     26  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,25,2),''0'','' '')'
                +   ',2,0),'
209 A  // opfbld                27     27  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,27,1),''0'','' '')'
                +   ',1,0),'
213 A  // opbpck                28     30  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,28,3),''0'','' '')'
                +   ',3,0),'
214 A  // oppbrk                31     33
                +   'substr(opzdta,31,3),'
400 A  // oppbld                34     34
                +   'substr(opzdta,34,1),'
400 A  // opselm                35     35
                +   'substr(opzdta,35,1),'
400 A  // opsplt                36     36
                +   'substr(opzdta,36,1),'
500aA  // opbmrg                37     37
                +   'substr(opzdta,37,1),'
500aA  // opnwpl                38     38
                +   'substr(opzdta,38,1),'
500dA  // opford                39     40  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,39,2),''0'','' '')'
                +   ',2,0),'
500cM  // opptyp                41     41
                +   'substr(opzdta,41,1),'
500dA  // opftot                42     43  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,42,2),''0'','' '')'
                +   ',2,0),'
500dA  // optecb                44     48  2 inz(0)
640aD       //  +   'zoned('
640aD       //  +     'translate(substr(opzdta,44,5),''0'','' '')'
640aD       //  +   ',5,0),'
640aM           +   'zoned('
640aM           +     'translate(substr(opzdta,44,3),''0'','' '')'
640aM           +     '||''.''||'
640aM           +     'translate(substr(opzdta,47,2),''0'','' '')'
640aM           +   ',5,2),'
500dA  // opticb                49     53  2 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,49,3),''0'','' '')'
                +     '||''.''||'
                +     'translate(substr(opzdta,52,2),''0'','' '')'
                +   ',5,2),'
500dA  // optstp                54     55  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,54,2),''0'','' '')'
                +   ',2,0),'
500dA  // optord                56     57  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,56,2),''0'','' '')'
                +   ',2,0),'
500dA  // optpcs                58     60  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,58,3),''0'','' '')'
                +   ',3,0),'
510 A  // opstop                61     61
                +   'substr(opzdta,61,1),'
520 A  // oppkup                62     62
                +   'substr(opzdta,62,1),'
520 A  // opspal                63     63
                +   'substr(opzdta,63,1),'
520 A  // oppitm                64     67  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,64,4),''0'','' '')'
650aM           +   ',4,0),'
650aA  // oplbl                 68     68
700aM           +   'substr(opzdta,68,1),'
700aA  // opdddo                69     69
700aA           +   'substr(opzdta,69,1),'
700aA  // opmcub                70     74  2 inz(0)
700aA           +   'zoned('
700aA           +     'translate(substr(opzdta,70,3),''0'','' '')'
700aA           +     '||''.''||'
700aA           +     'translate(substr(opzdta,73,2),''0'','' '')'
700aA           +   ',5,2),'
700aA  // oppmtz                75     75
                +   'substr(opzdta,75,1),'
700aA  // opgcde                76     76
                +   'substr(opzdta,76,1),'
710a   // opnbps                77     77  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,77,1),''0'','' '')'
                +   ',1,0),'
720a   // opfwgt                78     81  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,78,4),''0'','' '')'
                +   ',4,0),'
720a   // opfplt                82     87
                +   'substr(opzdta,82,6),'
720a   // opbseq                88     89  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,88,2),''0'','' '')'
                +   ',2,0),'
720b   // opsstp                90     91  0 inz(0)
                +   'zoned('
                +     'translate(substr(opzdta,90,2),''0'','' '')'
                +   ',2,0),'
740a   // ozrfzp                92     92
                +   'substr(opzdta,92,1),'
740bA  // opicub                93     97  2 inz(0)
740bA           +   'zoned('
740bA           +     'translate(substr(opzdta,93,3),''0'','' '')'
740bA           +     '||''.''||'
740bA           +     'translate(substr(opzdta,96,2),''0'','' '')'
740bA           +   ',5,2),'
740bA  // oppisplt              98     98
740bA           +   'substr(opzdta,98,1),'
740bA  // opmscb                99    100  0 inz(0)
740bA           +   'zoned('
740bA           +     'translate(substr(opzdta,99,2),''0'','' '')'
740bA           +   ',2,0),'
740bA  // opmsvh               101    101
740bA           +   'substr(opzdta,101,1),'
740bA  // opmsvm               102    102
740bA           +   'substr(opzdta,102,1),'
740bA  // opmsvl               103    103
740bA           +   'substr(opzdta,103,1),'
740bA  // opoacb               104    105  0 inz(0)
740bA           +   'zoned('
740bA           +     'translate(substr(opzdta,104,2),''0'','' '')'
740bA           +   ',2,0),'
740bA  // opzplt               106    106
740bA           +   'substr(opzdta,106,1),'
740bA  // opbplt               107    107
740bA           +   'substr(opzdta,107,1),'
750 A  // oppstuff             108    108
750 A           +   'substr(opzdta,108,1),'
750aA  // oppmsp               109    109
750aA           +   'substr(opzdta,109,1),'
750aA  // oppmstp              110    110
750aA           +   'substr(opzdta,110,1),'
750aA  // oppmord              111    111
750aA           +   'substr(opzdta,111,1),'
760aA  // opppbs               112    112
760aA           +   'substr(opzdta,112,1)'

                + ' from ' + %trim(pfLibFile)
                + ' where opzcod = ' + sq + %trim(code) + sq
                + ')';

740aM   debugStr1 = %subst(sqlstmt2:1:1000);
740aM   debugStr2 = %subst(sqlstmt2:1001:1000);
740aA   debugStr3 = %subst(sqlstmt2:2001);

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

740aM   sqlstmt2 = 'grant select,insert,update,delete '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

740aM   sqlstmt2 = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''View to split out '
                + %trimr(file) + ' ' + %trim(code) + ' fields''';

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

740am   sqlstmt2 = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' ' + %trimr(code) + ' '
                + 'field view - 6.40''';

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

740aM   sqlstmt2 = 'label on column ' + %trimr(viewLibFile) + ' '
                + '('
                +   'opnxtp is ''Next Plt#'','
                +   'oppcub is ''Min PIR Cube'','
                +   'opfpal is ''Plts on Fork'','
                +   'opfcub is ''Max Fixed Cube'','
                +   'opincl is ''Include PIR         '
                +               'in Fixed Cube'','
                +   'opsrch is ''Previous plts       '
                +               'to search'','
                +   'opfstp is ''Max stops on plt'','
                +   'opfbld is ''Bld Method'','
                +   'opbpck is ''Min cube for        '
                +               'Bulk Pick'','
                +   'oppbrk is ''Aisle to start      '
                +               'new pallet'','
                +   'oppbld is ''Pallet Building     '
                +               'method'','
                +   'opselm is ''Selection           '
                +               'method'','
                +   'opsplt is ''Allow split stop'','
                +   'opbmrg is ''Allow Merge onto    '
                +               'bulk pick'','
                +   'opnwpl is ''Start new pallet    '
                +               'on aisle change'','
                +   'opford is ''Max orders          '
                +               'per pallet'','
                +   'opptyp is ''Pallet              '
                +               'Type'','
                +   'opftot is ''Max totes           '
                +               'per pallet'','
                +   'optecb is ''External            '
                +               'tote cube'','
                +   'opticb is ''Internal            '
                +               'tote cube'','
                +   'optstp is ''Max stops           '
                +               'per tote'','
                +   'optord is ''Max orders          '
                +               'per tote'','
                +   'optpcs is ''Max pieces          '
                +               'per tote'','
                +   'opstop is ''Honor *SP           '
                +               'flag'','
                +   'oppkup is ''Picked              '
                +               'up by'','
                +   'opspal is ''Merge Pallet items  '
                +               'for single truck plt'','
                +   'oppitm is ''Max items           '
                +               'per pallet'','
650aA           +   'oplbl  is ''Label print         '
700aM           +               'method'','
700aA           +   'opdddo is ''Dock Door Drop      '
700aA           +               'off order'','
700aA           +   'opmcub is ''Minimum Cube per    '
700aA           +               'Fixed pallet'','
700aA           +   'oppmtz is ''Allow Multi Truck   '
700aA           +               'Assignments'','
700aA           +   'opgcde is ''USF group           '
700aA           +               'code'','
710aA           +   'opnbps is ''# of Pallet Sections'','
720aA           +   'opfwgt is ''Max weight          '
720aA           +               'per pallet'','
720aA           +   'opfplt is ''Pallet              '
720aA           +               'Code'','
720aA           +   'opbseq is ''Build               '
720aA           +               'Sequence'','
720bA           +   'opsstp is ''Max Stops           '
720bA           +               'per section'','
740aA           +   'ozrfzp is ''RF Zone             '
740aA           +               'Pickup'','
740bA           +   'opicub is ''Ideal Cube          '
740bA           +               'per pallet'','
740bA           +   'oppisplt is ''Prevent Item        '
740bA           +               'Split'','
740bA           +   'opmscb is ''Allow merging with  '
740bA           +               'other Stops'','
740bA           +   'opmsvh is ''When merging Stop   '
740bA           +               'can be highest'','
740bA           +   'opmsvm is ''When merging Stop   '
740bA           +               'can be middle'','
740bA           +   'opmsvl is ''When merging Stop   '
740bA           +               'can be lowest'','
740bA           +   'opzplt is ''Zone Pallet '
740bA           +               'type'','
740bA           +   'opbplt is ''Bulk Pallet '
740bA           +               'type'','
750 A           +   'oppstuff is ''Stuff Pallet '
750 A           +               ''','
750aA           +   'oppmsp is ''Prevent manual merging of '
750aA           +               '*SP pallets'','
750aA           +   'oppmstp is ''Prevent manual exceeding '
750aA           +               'max stops'','
750aA           +   'oppmord is ''Prevent manual exceeding '
750aA           +               'max orders'','
760aA           +   'opppbs  is ''Pick by Stop (layers) '
760aA           +               ''''
                + ')';

740aM   exec sql execute immediate :sqlstmt2;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
