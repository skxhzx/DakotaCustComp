      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSIMPITEM  SQL View for OPTIONS *IMPITEM
     *  29 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/29/11  RBD  6.40
     *      - Created.
     *
640aA*    08/15/12  DAS  6.40a
     *      - Changed the field names. Re: MRC cannot have field names
     *        that are the same but with different lengths.
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
                     + 'CALL OPSIMPITEM (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*IMPITEM';
        view = 'OPSIMPITEM';
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
                +   'opiwhse,'
                +   'opiityp,'
                +   'opidesc,'
                +   'opiwhdp,'
                +   'opistyp,'
                +   'opidesg,'
                +   'opiactv,'
                +   'opibld,'
                +   'opiven#,'
                +   'opivit#,'
                +   'opipdsc,'
                +   'opium1,'
                +   'opium2,'
                +   'opiumq2,'
                +   'opiflg1,'
                +   'opium3,'
                +   'opiumq3,'
                +   'opiflg2,'
                +   'opiulen,'
                +   'opiuwdt,'
                +   'opiuhgt,'
                +   'opicube,'
                +   'opiswgt,'
                +   'opicwgt,'
                +   'opirepl,'
                +   'opiflgd,'
                +   'opiflgb,'
                +   'opislif,'
                +   'opinday,'
                +   'opitie,'
                +   'opihigh,'
                +   'opimflg,'
                +   'opidday,'
                +   'opiuday,'
                +   'opimday,'
                +   'opimitm,'
                +   'opicitm,'
                +   'opinslt,'
                +   'opixdck,'
                +   'opibnbr,'
                +   'opibnam,'
                +   'opivnam,'
                +   'opibrnd,'
                +   'opilot,'
                +   'opiltrk'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPITYP
                +   'substr(opdata,1,1),'
       //                                     2   2 OPDESC
                +   'substr(opdata,2,1),'
       //                                     3   3 OPWHDP
                +   'substr(opdata,3,1),'
       //                                     4   4 OPSTYP
                +   'substr(opdata,4,1),'
       //                                     5   5 OPDESG
                +   'substr(opdata,5,1),'
       //                                     6   6 OPACTV
                +   'substr(opdata,6,1),'
       //                                     7   7 OPBLD
                +   'substr(opdata,7,1),'
       //                                     8   8 OPVEN#
                +   'substr(opdata,8,1),'
       //                                     9   9 OPVIT#
                +   'substr(opdata,9,1),'
       //                                    10  10 OPPDSC
                +   'substr(opdata,10,1),'
       //                                    11  11 OPUM1
                +   'substr(opdata,11,1),'
       //                                    12  12 OPUM2
                +   'substr(opdata,12,1),'
       //                                    13  13 OPUMQ2
                +   'substr(opdata,13,1),'
       //                                    14  14 OPFLG1
                +   'substr(opdata,14,1),'
       //                                    15  15 OPUM3
                +   'substr(opdata,15,1),'
       //                                    16  16 OPUMQ3
                +   'substr(opdata,16,1),'
       //                                    17  17 OPFLG2
                +   'substr(opdata,17,1),'
       //                                    18  18 OPULEN
                +   'substr(opdata,18,1),'
       //                                    19  19 OPUWDT
                +   'substr(opdata,19,1),'
       //                                    20  20 OPUHGT
                +   'substr(opdata,20,1),'
       //                                    21  21 OPCUBE
                +   'substr(opdata,21,1),'
       //                                    22  22 OPSWGT
                +   'substr(opdata,22,1),'
       //                                    23  23 OPCWGT
                +   'substr(opdata,23,1),'
       //                                    24  24 OPREPL
                +   'substr(opdata,24,1),'
       //                                    25  25 OPFLGD
                +   'substr(opdata,25,1),'
       //                                    26  26 OPFLGB
                +   'substr(opdata,26,1),'
       //                                    27  27 OPSLIF
                +   'substr(opdata,27,1),'
       //                                    28  28 OPNDAY
                +   'substr(opdata,28,1),'
       //                                    29  29 OPTIE
                +   'substr(opdata,29,1),'
       //                                    30  30 OPHIGH
                +   'substr(opdata,30,1),'
       //                                    31  31 OPMFLG
                +   'substr(opdata,31,1),'
       //                                    32  32 OPDDAY
                +   'substr(opdata,32,1),'
       //                                    33  33 OPUDAY
                +   'substr(opdata,33,1),'
       //                                    34  34 OPMDAY
                +   'substr(opdata,34,1),'
       //                                    35  35 OPMITM
                +   'substr(opdata,35,1),'
       //                                    36  36 OPCITM
                +   'substr(opdata,36,1),'
       //                                    37  37 OPNSLT
                +   'substr(opdata,37,1),'
       //                                    38  38 OPXDCK
                +   'substr(opdata,38,1),'
       //                                    39  39 OPBNBR
                +   'substr(opdata,39,1),'
       //                                    40  40 OPBNAM
                +   'substr(opdata,40,1),'
       //                                    41  41 OPVNAM
                +   'substr(opdata,41,1),'
       //                                    42  42 OPBRND
                +   'substr(opdata,42,1),'
       //                                    43  43 OPLOT
                +   'substr(opdata,43,1),'
       //                                    44  44 OPLTRK
                +   'substr(opdata,44,1)'
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
                +   'opiityp is ''Item                '
                +               'type'','
                +   'opidesc is ''Item                '
                +               'desc'','
                +   'opiwhdp is ''Whse                '
                +               'dept'','
                +   'opistyp is ''Section             '
                +               'type'','
                +   'opidesg is ''Designation'','
                +   'opiactv is ''Activity'','
                +    'opibld is ''Build               '
                +               'code'','
                +   'opiven# is ''Vendor              '
                +               'number'','
                +   'opivit# is ''Vendor              '
                +               'item #'','
                +   'opipdsc is ''Pack                '
                +               'desc'','
                +    'opium1 is ''Normal              '
                +               'UOM'','
                +   ' opium2 is ''Brkdn1              '
                +               'UOM'','
                +   'opiumq2 is ''Brkdn1              '
                +               'UOM qty'','
                +   'opiflg1 is ''Allow brkdn1        '
                +               'sale'','
                +    'opium3 is ''Brkdn2              '
                +               'UOM'','
                +   'opiumq3 is ''Brkdn2              '
                +               'UOM qty'','
                +   'opiflg2 is ''Allow brkdn2        '
                +               'sale'','
                +   'opiulen is ''Unit                '
                +               'length'','
                +   'opiuwdt is ''Unit                '
                +               'width'','
                +   'opiuhgt is ''Unit                '
                +               'height'','
                +   'opicube is ''Cube/Unit'','
                +   'opiswgt is ''Shipping            '
                +               'weight'','
                +   'opicwgt is ''Catch               '
                +               'weight'','
                +   'opirepl is ''Repl                '
                +               'level'','
                +   'opiflgd is ''Date                '
                +               'sensitive'','
                +   'opiflgb is ''Allow               '
                +               'bulk pick'','
                +   'opislif is ''Shelf               '
                +               'life days'','
                +   'opinday is ''Notice              '
                +               'days'','
                +    'opitie is ''Mfr                 '
                +               'tie'','
                +   'opihigh is ''Mfr                 '
                +               'high'','
                +   'opimflg is ''Mfr                 '
                +               'date'','
                +   'opidday is ''Dist                '
                +               'days'','
                +   'opiuday is ''End user            '
                +               'days'','
                +   'opimday is ''Mfr shelf           '
                +               'life days'','
                +   'opimitm is ''Master item         '
                +               'number'','
                +   'opicitm is ''Contract            '
                +               'base item'','
                +   'opinslt is ''Non-slotted         '
                +               'item'','
                +   'opixdck is ''Crossdock           '
                +               'item'','
                +   'opibnbr is ''Buyer               '
                +               'number'','
                +   'opibnam is ''Buyer               '
                +               'name'','
                +   'opivnam is ''Vendor              '
                +               'name'','
                +   'opibrnd is ''Brand'','
                +    'opilot is ''Lot code            '
                +               'item'','
                +   'opiltrk is ''Track by            '
                +               'license'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
