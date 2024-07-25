      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSSYSTEM  SQL View for OPTIONS *GENPICK
     *  23 September 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    09/23/11  RBD  6.40
     *      - Created.
     *
640aA*    08/13/12  DAS  6.40a
     *      - Added OPRBN1, OPRBN2, OPSUBT.
700aA*    04/16/15  LMC  7.00a
     *      - Added OPRFQT, OPRFCS.
     *      - Added OPPMTA, OPMAXA, OPDOCK - Used by USF
     *
710aA*    01/20/17  LMC  7.10a
     *      - Added OPRFQTO, OPRFPM, OPRPLT
720aA*    05/30/18  LMC  7.20a
     *      - Added OPRFUI
720bA*    07/16/18  LMC  7.20b
     *      - Added OPRFZP & OPRFUW
730aA*    05/20/19  KDE  7.30a
     *      - Added OPPSEQ
740aA*    03/25/20  LMC  7.40a
     *      - Added OPRVUP
     *      - Added OPRVSL
     *      - Added OPRVCD
740bA*    05/27/20  KDE  7.40b
     *      - Added OPCAD - Customer Audit Duration(New Customers)
740cA*    08/17/20  KDE  7.40c
     *      - Added OPPMSC, OPPSVH, OPPSVM, OPPSVL, OPPISSV, OPPISSP,
     *        OPPMSSV, OPPMSSP, OPPFDB
740dA*    09/29/20  RBD  7.40d
     *      - Added OPBARC.
     *      - Added missing options.
     *      - Had to use work variable sqlstmt1 for column labels
     *        sql rather than c#stdsql/sqlstmt because length 2000
     *        wasn't long enough after adding missing options.
750aA*    05/25/21  LMC  7.50a
     *      - Added new options for SelectPrime
     *      - OPRFQTCW-  SelectPrime - allow Qty entry on cw items.
     *      - OPRFQTAS-  SelectPrime - assume short from qty entry.
     *      - OPRFSSSV-  SelectPrime - Same Slot skip Loc verification
     *      - OPSPPS  -  SelectPrime - Auto display pallet Summary-82
     *      - OPSPATRN-  SelectPrime - Auto assign transactions
     *      - OPSPPLBL-  SelectPrime - Print pallet label on Belt Printer
     *      - OPSPBTXT-  SelectPrime - Next Item breakdown warning text
     *      - OPSPPSH -  SelectPrime - Print SetHed Label
     *      - OPSPPSS -  SelectPrime - Print SetSum Label
750bA*    06/11/21  RBD  7.50b
     *      - Added OPAUTS, Allow auto substitutions.
750cA*    06/18/21  LMC  7.50c
     *      - Added OPSPPBA-SelectPrime - Print Before/After pick(B/A)
750dA*    01/14/22  LMC  7.50d
     *      - Added OPSPJP -SelectPrime-Pallet jack prefix equip type
750eA*    03/04/22  LMC  7.50e
     *      - Added new options for SelectPrime
     *      - OPSPSSN-  SelectPrime - Same Slot/More Qty visual Notif ication
     *      - OPSPPLDL-  SelectPrime - remove items from pick list as
     *                   they are picked.
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
     D  debugStr3      s           1000
     D  file           s             10
     D  dsplyMsg       s             52
     D  pfLibFile      s             21
740dAD sqlstmt1        s           3000a   inz(' ')
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
                     + 'CALL OPSGENPICK (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*GENPICK';
        view = 'OPSGENPICK';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

        //sqlstmt = 'drop view ' + %trimr(viewLibFile);
        sqlstmt1= 'drop view ' + %trimr(viewLibFile);

        //exec sql execute immediate :sqlstmt;
        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

        //sqlstmt = 'create view ' + %trimr(viewLibFile) + ' '
        sqlstmt1 = 'create view ' + %trimr(viewLibFile) + ' '
                + '('
                +   'opwhse,'
                +   'operpt,'
                +   'opelbl,'
                +   'oprfwc,'
                +   'opnrsc,'
                +   'ophpwc,'
                +   'opmrga,'
                +   'opplsq,'
                +   'opeadj,'
                +   'opnopk,'
                +   'opjitr,'
                +   'oppset,'
                +   'oprfuc,'
                +   'oprflc,'
                +   'opusf1,'
                +   'oprfsl,'
640aA           +   'oprbn1,'
640aA           +   'oprbn2,'
640aA           +   'opsubt,'
700aA           +   'oprfqt,'
700aA           +   'oprfcs,'
700aA           +   'oppmta,'
700aA           +   'opmaxa,'
710aM           +   'opdock,'
710aA           +   'oprfqto,'
710aA           +   'oprfpm,'
710aA           +   'oprplt,'
720aA           +   'oprfui,'
720bA           +   'oprfzp,'
720bA           +   'oprfuw,'
730aA           +   'oppseq,'
740aA           +   'oprvup,'
740aA           +   'oprvsl,'
740bM           +   'oprvcd,'
740bM           +   'opcad,'
740cA           +   'oppmsc,'
740cA           +   'oppsvh,'
740cA           +   'oppsvm,'
740cA           +   'oppsvl,'
740cA           +   'oppissv,'
740cA           +   'oppissp,'
740cA           +   'oppmssv,'
740cA           +   'oppmssp,'
740cA           +   'oppfdb,'
750aM           +   'opbarc,'
750aA           +   'oprfqtcw,'
750aA           +   'oprfqtas,'
750aA           +   'oprfsssv,'
750aA           +   'opspps,'
750aA           +   'opspatrn,'
750aA           +   'opspplbl,'
750aA           +   'opspbtxt,'
750aA           +   'opsppsh,'
750aA           +   'opsppss,'
750bA           +   'opauts,'
750cA           +   'opsppba,'
750dA           +   'opspjp,'
750eA           +   'opspssn,'
750eA           +   'opsppldl'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPERPT
                +   'substr(opdata,1,1),'
       //                                     2   2 OPELBL
                +   'substr(opdata,2,1),'
       //                                     3   3 OPRFWC
                +   'substr(opdata,3,1),'
       //                                     4   40OPNRSC
                +   'zoned('
                +     'translate(substr(opdata,4,1),''0'','' '')'
                +   ',1,0),'
       //                                     5   5 OPHPWC
                +   'substr(opdata,5,1),'
       //                                     6   6 OPMRGA
                +   'substr(opdata,6,1),'
       //                                     7   7 OPPLSQ
                +   'substr(opdata,7,1),'
       //                                     8   8 OPEADJ
                +   'substr(opdata,8,1),'
       //                                     9   9 OPNOPK
                +   'substr(opdata,9,1),'
       //                                    12  12 OPJITR
                +   'substr(opdata,12,1),'
       //                                    13  13 OPPSET
                +   'substr(opdata,13,1),'
       //                                    14  14 OPRFUC
                +   'substr(opdata,14,1),'
       //                                    15  15 OPRFLC
                +   'substr(opdata,15,1),'
       //                                    16  16 OPUSF1
                +   'substr(opdata,16,1),'
       //                                    17  17 OPRFSL
                +   'substr(opdata,17,1),'
640aA  //                                    18  18 OPRBN1
640aA           +   'substr(opdata,18,1),'
640aA  //                                    19  19 OPRBN2
640aA           +   'substr(opdata,19,1),'
640aA  //                                    20  20 OPSUBT
640aA           +   'substr(opdata,20,1),'
700aA  //                                    21  21 OPRFQT
700aA           +   'substr(opdata,21,1),'
700aA  //                                    22  22 OPRFCS
700aA           +   'substr(opdata,22,1),'
700aA  //                                    23  23 OPPMTA
700aA           +   'substr(opdata,23,1),'
700aA  //                                    24  250OPMAXA
700aA           +   'zoned('
700aA           +     'translate(substr(opdata,24,2),''0'','' '')'
700aA           +   ',2,0),'
700aA  //                                    26  26 OPDOCK
710aM           +   'substr(opdata,26,1),'
710aA  //                                    27  290OPRFQTO
710aA           +   'zoned('
710aA           +     'translate(substr(opdata,27,3),''0'','' '')'
710aA           +   ',3,0),'
710aA  //                                    30  30 OPRFPM
710aA           +   'substr(opdata,30,1),'
710aA  //                                    31  31 OPRPLT
710aA           +   'substr(opdata,31,1),'
720aA  //                                    32  32 OPRFUI
720aA           +   'substr(opdata,32,1),'
720bA  //                                    33  33 OPRFZP
720bA           +   'substr(opdata,33,1),'
720bA  //                                    34  34 OPRFUW
720bA           +   'substr(opdata,34,1),'
730aA  //                                    35  35 OPPSEQ
730aA           +   'substr(opdata,35,1),'
740aA  //                                    36  36 OPRVUP
740aA           +   'zoned('
740aA           +     'translate(substr(opdata,36,1),''0'','' '')'
740aA           +   ',1,0),'
740aA  //                                    37  37 OPRVSL
740aA           +   'zoned('
740aA           +     'translate(substr(opdata,37,1),''0'','' '')'
740aA           +   ',1,0),'
740aA  //                                    38  38 OPRVCD
740aA           +   'zoned('
740aA           +     'translate(substr(opdata,38,1),''0'','' '')'
740bM           +   ',1,0),'
740aA  //                                    39  40 OPCAD
740aA           +   'zoned('
740aA           +     'translate(substr(opdata,39,2),''0'','' '')'
740aA           +   ',2,0),'
740cA  // oppmsc                             41  42 OPPMSC
740cA           +   'zoned('
740cA           +     'translate(substr(opdata,41,2),''0'','' '')'
740cA           +   ',2,0),'
740cA  // oppsvh                             43  43 OPPSVH
740cA           +   'substr(opdata,43,1),'
740dM  // oppsvm                             44  44 OPPSVM
740cA           +   'substr(opdata,44,1),'
740cA  // oppsvl                             45  45 OPPSVL
740cA           +   'substr(opdata,45,1),'
740cA  // oppissv                            46  50 OPPISSV
740cA           +   'zoned('
740cA           +     'translate(substr(opdata,46,5),''0'','' '')'
740cA           +   ',5,0),'
740cA  // oppissP                            51  53 OPPISSP
740cA           +   'zoned('
740cA           +     'translate(substr(opdata,51,3),''0'','' '')'
740cA           +   ',3,0),'
740cA  // oppmssv                            54  58 OPPMSSV
740cA           +   'zoned('
740cA           +     'translate(substr(opdata,54,5),''0'','' '')'
740cA           +   ',5,0),'
740cA  // oppmssp                            59  61 OPPMSSP
740cA           +   'zoned('
740cA           +     'translate(substr(opdata,59,3),''0'','' '')'
740cA           +   ',3,0),'
740cA  // oppfdb                             62  62 OPPFDB
740cA           +   'substr(opdata,62,1),'
740dA  // opbarc                             63  63 OPBARC
740dA           +   'substr(opdata,63,1),'
750aA  // oprfqtcw                           64  64 OPRFQTCW
750aA           +   'substr(opdata,64,1),'
750aA  // oprfqtas                           65  65 OPRFQTAS
750aA           +   'substr(opdata,65,1),'
750aA  // oprfsssv                           66  66 OPRSSSVS
750aA           +   'substr(opdata,66,1),'
750aA  // opspps                             67  67 OPSPPS
750aA           +   'substr(opdata,67,1),'
750aA  // opspatrn                           68  68 OPSPATRN
750aA           +   'substr(opdata,68,1),'
750aA  // opspplbl                           69  69 OPSPPLBL
750aA           +   'substr(opdata,69,1),'
750aA  // opspbtxt                           70  99 OPSPBTXT
750aA           +   'substr(opdata,70,30),'
750aA  // opsppsh                           100 100 OPSPPSH
750aA           +   'substr(opdata,100,1),'
750aA  // opsppss                           101 101 OPSPPSS
750aA           +   'substr(opdata,101,1),'
750bA  // opauts                            102 102 OPAUTS
750bA           +   'substr(opdata,102,1),'
750cA  // opsppba                           103 103 OPSPPBA
750cA           +   'substr(opdata,103,1),'
750dA  // opspjp                            104 108 OPSPJP
750dA           +   'substr(opdata,104,5),'
750eA  // opspssn                           109 109 OPSPSSN
750eA           +   'substr(opdata,109,1),'
750eA  // opsppldl                          110 110 OPSPPLDL
750eA           +   'substr(opdata,110,1)'
                + ' from ' + %trim(pfLibFile)
                + ' where opcode = ' + sq + %trim(code) + sq
                + ')';

        //debugStr1 = %subst(sqlstmt:1:1000);
        //debugStr2 = %subst(sqlstmt:1001:2000);
        debugStr1 = %subst(sqlstmt1:1:1000);
        debugStr2 = %subst(sqlstmt1:1001:2000);
        debugStr3 = %subst(sqlstmt1:2001);

        //exec sql execute immediate :sqlstmt;
        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

        //sqlstmt = 'grant select,insert,update,delete '
        sqlstmt1 = 'grant select,insert,update,delete '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

        //exec sql execute immediate :sqlstmt;
        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        //sqlstmt = 'comment on table ' + %trimr(viewLibFile) + ' '
        sqlstmt1 = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''View to split out '
                + %trimr(file) + ' ' + %trim(code) + ' fields''';

        //exec sql execute immediate :sqlstmt;
        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        //sqlstmt = 'label on table ' + %trimr(viewLibFile) + ' '
        sqlstmt1 = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' ' + %trimr(code) + ' '
                + 'field view - 6.40''';

        //exec sql execute immediate :sqlstmt;
        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmt1 = 'label on column ' + %trimr(viewLibFile) + ' '
                + '('
                +   'operpt is ''Print excp short    '
                +               'error report'','
                +   'opelbl is ''Print excp short    '
                +               'labels'','
                +   'oprfwc is ''Using RF            '
                +               'will call'','
                +   'opnrsc is ''# of pallet         '
                +               'sections'','
                +   'ophpwc is ''Host pick           '
                +               'Will Call'','
                +   'opmrga is ''Merge Add-on ords   '
                +               'with open routes'','
                +   'opplsq is ''Pallet number       '
                +               'sequence'','
                +   'opeadj is ''Close short labels  '
                +               'without adjustment'','
                +   'opnopk is ''Pick items w/o pick '
                +               'slot as bulk pick'','
                +   'opjitr is ''Create JIT letdown  '
                +               'or JIT replenishment'','
                +   'oppset is ''Separate set summary'
                +               'lbl for each pallet'','
                +   'oprfuc is ''RF pick verify      '
                +               'item with UPC'','
                +   'oprflc is ''RF pick verify      '
                +               'item with license'','
                +   'opusf1 is ''USF:Allow mrg items '
                +               'split across pallet'','
                +   'oprfsl is ''RF pick             '
                +               'verify slot'','
                +   'oprbn1 is ''Round Robin         '
                +               'compatable'','
                +   'oprbn2 is ''Round Robin         '
                +               'type'','
                +   'opsubt is ''Allow               '
700aM           +               'Subs'','
700aA           +   'oprfqt is ''RF Pick             '
700aA           +               'Allow Qty Entry'','
700aA           +   'oprfcs is ''RF Pick             '
700aA           +               'Allow Change Slot'','
700aA           +   'oppmta is ''Allow Multi Truck   '
700aA           +               'Assigments'','
700aA           +   'opmaxa is ''Max # of Routes     '
700aA           +               'Staged Together'','
700aA           +   'opdock is ''Dock Door           '
710aM           +               'Prompt Choice'','
710aA           +   'oprfqto is ''With Qty Over      '
710aA           +               ' '','
710aA           +   'oprfpm is ''RF Pick             '
710aA           +               'Method'','
710aA           +   'oprplt is ''Print Pallet        '
710aA           +               'Label'','
740dM           +   'oprfui is ''Verify Individual   '
740bM           +               'UPC'','
740dA           +   'oprfzp is ''Zone pickup         '
740dA           +               ' '','
740dA           +   'oprfuw is ''Auto load weight if '
740dA           +               ' found in individual upc '','
740dA           +   'oppseq is ''Slot pick           '
740dA           +               ' sequence '','
740dA           +   'oprvup is ''RF location verify  '
740dA           +               ' UPC '','
740dA           +   'oprvsl is ''RF location verify  '
740dA           +               ' slot '','
740dA           +   'oprvcd is ''RF location verify  '
740dA           +               ' check digit '','
740bA           +   'opcad is ''Cust Audit Duration '
740bA           +               ' '','
740cA           +   'oppmsc is ''Allow merge with other '
740cA           +               ' Stops when cube less '','
740cA           +   'oppsvh is ''Highest Stop '
740cA           +               ' on pallet '','
740cA           +   'oppsvm is  ''Middle Stop '
740cA           +               'on pallet '','
740cA           +   'oppsvl is  ''Lowest Stop '
740cA           +               'on pallet '','
740cA           +   'oppissv is ''Ideal Trailer Diff '
740cA           +               ' not greater than X pounds '','
740cA           +   'oppissp is ''Ideal Trailer Diff '
740cA           +               ' not greater than X % total '','
740cA           +   'oppmssv is ''Max Trailer Diff '
740cA           +               ' not greater than X pounds '','
740cA           +   'oppmssp is ''Max Trailer Diff '
740cA           +               ' not greater than X % total '','
740cA           +   'oppfdb is ''Allow Freezer pallet '
740cA           +               'at rear door '','
740dA           +   'opbarc is ''Print tran and label '
740dA           +               'barcodes '','
750aA           +   'oprfqtcw is ''Allow qty Entry on '
750aA           +               'CW Items '','
750aA           +   'oprfqtas is ''Assume short from qty '
750aA           +               'entry '','
750aA           +   'oprfsssv is ''Same slot skip location '
750aA           +               'verification '','
750aA           +   'opspps is ''Auto display pallet '
750aA           +               'summary '','
750aA           +   'opspatrn is ''Auto assign '
750aA           +               'transactions '','
750aA           +   'opspplbl is ''Print pallet label on '
750aA           +               'belt printer '','
750aA           +   'opspbtxt is ''Next Item Breakdown '
750aA           +               'text '','
750aA           +   'opsppsh is ''Print SetHed '
750aA           +               'label '','
750aA           +   'opsppss  is ''Print SetSum '
750aA           +               'label '','
750bA           +   'opauts is ''Allow auto '
750bA           +               'substitutions '','
750cA           +   'opsppba is ''Allow auto '
750cA           +               'substitutions '','
750cA           +   'opspjp  is ''Pallet Jack   '
750cA           +               'prefix     '','
750eA           +   'opspssn  is ''Same Slot more '
750eA           +               'qty notification '','
750eA           +   'opsppldl  is ''Delete from   '
750eA           +               'Pick List when selected  '''
                + ')';

        exec sql execute immediate :sqlstmt1;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
