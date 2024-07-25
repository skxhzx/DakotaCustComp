      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSTRAX  SQL View for OPTIONS *TRAX
     *  21 December 2011
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    12/21/11  RBD  6.40
     *      - Created.
     *
720 A*    03/06/18  RBD  7.20
     *      - Added optbul, opteys, optsas, optsdl, optsdt, optlrk,
     *        optgss, optgsu, optsbv, optrag, optrd, optrdt, optrfp,
     *        optrfm, optnsr, optfbd, optdsf.
     *
730 A*    03/13/19  RBD  7.30
     *      - Added optsor, optode, optodp, optont, optotp and optnsb.
     *
740aA*    11/02/20  RBD  7.40a
     *      - Added optraxinv.
     *
760aA*    06/27/22  RBD  7.60a
     *      - Added optcut.
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
        code = '*TRAX';
        view = 'OPSTRAX';
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
                +   'opthst,'
                +   'optsli,'
                +   'optcwr,'
                +   'optoft,'
                +   'optdft,'
                +   'optrft,'
                +   'optcap,'
                +   'optdbl,'
                +   'optekd,'
                +   'optdar,'
                +   'optidb,'
                +   'optbda,'
                +   'optgbd,'
                +   'optrtq,'
                +   'optotq,'
                +   'optcce,'
                +   'optsig,'
                +   'optpiv,'
                +   'optsda,'
                +   'optwsp,'
                +   'optwsi,'
                +   'optsvd,'
                +   'optert,'
                +   'optedv,'
                +   'opteos,'
                +   'optesw,'
                +   'optesh,'
                +   'optare,'
                +   'optidl,'
                +   'optdci,'
                +   'optpal,'
                +   'optcra,'
720 M           +   'optdrv,'
720 A           +   'optbul,'
720 A           +   'opteys,'
720 A           +   'optsas,'
720 A           +   'optsdl,'
720 A           +   'optsdt,'
720 A           +   'optlrk,'
720 A           +   'optgss,'
720 A           +   'optgsu,'
720 A           +   'optsbv,'
720 A           +   'optrag,'
720 A           +   'optrd,'
720 A           +   'optrdt,'
720 A           +   'optrfp,'
720 A           +   'optrfm,'
720 A           +   'optnsr,'
720 A           +   'optfbd,'
720 A           +   'optdsf,'
730 A           +   'optsor,'
730 A           +   'optode,'
730 A           +   'optodp,'
730 A           +   'optont,'
730 A           +   'optotp,'
730 A           +   'optnsb,'
740aA           +   'optraxinv,'
760aA           +   'optcut'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   30OPTHST
                +   'zoned('
                +     'translate(substr(opdata,1,3),''0'','' '')'
                +   ',3,0),'
       //                                     4   4 OPTSLI
                +   'substr(opdata,4,1),'
       //                                     5   5 OPTCWR
                +   'substr(opdata,5,1),'
       //                                     6   6 OPTOFT
                +   'substr(opdata,6,1),'
       //                                     7   7 OPTDFT
                +   'substr(opdata,7,1),'
       //                                     8   8 OPTRFT
                +   'substr(opdata,8,1),'
       //                                     9   9 OPTCAP
                +   'substr(opdata,9,1),'
       //                                    10  10 OPTDBL
                +   'substr(opdata,10,1),'
       //                                    11  11 OPTEKD
                +   'substr(opdata,11,1),'
       //                                    12  12 OPTDAR
                +   'substr(opdata,12,1),'
       //                                    13  13 OPTIDB
                +   'substr(opdata,13,1),'
       //                                    14  14 OPTBDA
                +   'substr(opdata,14,1),'
       //                                    15  15 OPTGBD
                +   'substr(opdata,15,1),'
       //                                    16  16 OPTRTQ
                +   'substr(opdata,16,1),'
       //                                    17  17 OPTOTQ
                +   'substr(opdata,17,1),'
       //                                    18  18 OPTCCE
                +   'substr(opdata,18,1),'
       //                                    19  19 OPTSIG
                +   'substr(opdata,19,1),'
       //                                    20  20 OPTPIV
                +   'substr(opdata,20,1),'
       //                                    21  21 OPTSDA
                +   'substr(opdata,21,1),'
       //                                    22  260OPTWSP
                +   'zoned('
                +     'translate(substr(opdata,22,5),''0'','' '')'
                +   ',5,0),'
       //                                    27  41 OPTWSI
                +   'substr(opdata,27,15),'
       //                                    42  430OPTSVD
                +   'zoned('
                +     'translate(substr(opdata,42,2),''0'','' '')'
                +   ',2,0),'
       //                                    44  47 OPTERT
                +   'substr(opdata,44,4),'
       //                                    48  57 OPTEDV
                +   'substr(opdata,48,10),'
       //                                    58  67 OPTEOS
                +   'substr(opdata,58,10),'
       //                                    68  710OPTESW
                +   'zoned('
                +     'translate(substr(opdata,68,4),''0'','' '')'
                +   ',4,0),'
       //                                    72  750OPTESH
                +   'zoned('
                +     'translate(substr(opdata,72,4),''0'','' '')'
                +   ',4,0),'
       //                                    76  76 OPTARE
                +   'substr(opdata,76,1),'
       //                                    77  77 OPTIDL
                +   'substr(opdata,77,1),'
       //                                    78  78 OPTDCI
                +   'substr(opdata,78,1),'
       //                                    79  79 OPTPAL
                +   'substr(opdata,79,1),'
       //                                    80  80 OPTCRA
                +   'substr(opdata,80,1),'
720 M  //                                    81  81 OPTDRV
720 M           +   'substr(opdata,81,1),'
720 A  //                                    82  82 OPTBUL
720 A           +   'substr(opdata,82,1),'
720 A  //                                    83  83 OPTEYS
720 A           +   'substr(opdata,83,1),'
720 A  //                                    84  84 OPTSAS
720 A           +   'substr(opdata,84,1),'
720 A  //                                    85  860OPTSDL
720 A           +   'zoned('
720 A           +     'translate(substr(opdata,85,2),''0'','' '')'
720 A           +   ',2,0),'
720 A  //                                    87  87 OPTSDT
720 A           +   'substr(opdata,87,1),'
720 A  //                                    88  88 OPTLRK
720 A           +   'substr(opdata,88,1),'
720 A  //                                    89  89 OPTGSS
720 A           +   'substr(opdata,89,1),'
720 A  //                                    90  90 OPTGSU
720 A           +   'substr(opdata,90,1),'
720 A  //                                    91  910OPTSBV
720 A           +   'zoned('
720 A           +     'translate(substr(opdata,91,1),''0'','' '')'
720 A           +   ',1,0),'
720 A  //                                    92  92 OPTRAG
720 A           +   'substr(opdata,92,1),'
720 A  //                                    93  93 OPTRD
720 A           +   'substr(opdata,93,1),'
720 A  //                                    94  970OPTRDT
720 A           +   'zoned('
720 A           +     'translate(substr(opdata,94,4),''0'','' '')'
720 A           +   ',4,0),'
720 A  //                                    98  98 OPTRFP
720 A           +   'substr(opdata,98,1),'
720 A  //                                    99  99 OPTRFM
720 A           +   'substr(opdata,99,1),'
720 A  //                                   100 100 OPTNSR
720 A           +   'substr(opdata,100,1),'
720 A  //                                   101 101 OPTFBD
720 A           +   'substr(opdata,101,1),'
720 A  //                                   102 102 OPTDSF
730 M           +   'substr(opdata,102,1),'
730 A  //                                   103 103 OPTSOR
730 A           +   'substr(opdata,103,1),'
730 A  //                                   104 104 OPTODE
730 A           +   'substr(opdata,104,1),'
730 A  //                                   105 1060OPTODP
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,105,2),''0'','' '')'
730 A           +   ',2,0),'
730 A  //                                   107 107 OPTONT
730 A           +   'substr(opdata,107,1),'
730 A  //                                   108 108 OPTOTP
730 A           +   'substr(opdata,108,1),'
730 A  //                                   109 109 OPTNSB
730 A           +   'substr(opdata,109,1),'
740aA  //                                   110 110 OPTRAXINV
740aA           +   'substr(opdata,110,1),'
760aA  //                                   111 111 OPTCUT
760aA           +   'substr(opdata,111,1)'
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
                + 'field view - 7.30''';

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
                +   'opthst is ''Days to keep '
                +               'Trax export data'','
                +   'optsli is ''Save log '
                +               'info'','
                +   'optcwr is ''Catchweight '
                +               'required'','
                +   'optoft is ''Order number '
                +               'field type'','
                +   'optdft is ''Driver '
                +               'field type'','
                +   'optrft is ''Route '
                +               'field type'','
                +   'optcap is ''Capitalize '
                +               'input'','
                +   'optdbl is ''Double click '
                +               'delivery'','
                +   'optekd is ''Entery key '
                +               'delivery'','
                +   'optdar is ''Delivery '
                +               'after return'','
                +   'optidb is ''Include item '
                +               'data base'','
                +   'optbda is ''Breakdowns '
                +               'allowed'','
                +   'optgbd is ''Generic breakdown '
                +               'allowed'','
                +   'optrtq is ''Pre-trip '
                +               'questions'','
                +   'optotq is ''Post-trip '
                +               'questions'','
                +   'optcce is ''Credit card '
                +               'enabled'','
                +   'optsig is ''Signature '
                +               'enabled'','
                +   'optpiv is ''Print '
                +               'invoice'','
                +   'optsda is ''Send data '
                +               'after stop'','
                +   'optwsp is ''Ws '
                +               'port'','
                +   'optwsi is ''Ws '
                +               'IP'','
                +   'optsvd is ''Save '
                +               'days'','
                +   'optert is ''Environment '
                +               'run time'','
                +   'optedv is ''Environment '
                +               'device'','
                +   'opteos is ''Environment '
                +               'OS'','
                +   'optesw is ''Environment '
                +               'screen width'','
                +   'optesh is ''Environment '
                +               'screen height'','
                +   'optare is ''Add return '
                +               'enabled'','
                +   'optidl is ''Icon '
                +               'delivery'','
                +   'optdci is ''Double click '
                +               'icons'','
                +   'optpal is ''Pallets '
                +               'enabled'','
                +   'optcra is ''Cradle upload '
                +               'enabled'','
720 M           +   'optdrv is ''Driver assigned '
720 M           +               'before download'','
720 A           +   'optbul is ''Bulk items '
720 A           +               'enabled'','
720 A           +   'opteys is ''Display empty '
720 A           +               'stops'','
720 A           +   'optsas is ''Save after '
720 A           +               'scan'','
720 A           +   'optsdl is ''Save '
720 A           +               'delay'','
720 A           +   'optsdt is ''Sync date '
720 A           +               'and time'','
720 A           +   'optlrk is ''Left/right '
720 A           +               'keys enabled'','
720 A           +   'optgss is ''GS1 '
720 A           +               'scanning'','
720 A           +   'optsbv is ''Scan beep '
720 A           +               'volume'','
720 A           +   'optrag is ''Restart after '
720 A           +               'get route'','
720 A           +   'optrd  is ''Restart '
720 A           +               'daily'','
720 A           +   'optrdt is ''Restart '
720 A           +               'daily time'','
720 A           +   'optrfp is ''Reader focus '
720 A           +               'position'','
720 A           +   'optrfm is ''Reader focus '
720 A           +               'mode'','
720 A           +   'optnsr is ''Non scan '
720 A           +               'reason prompt'','
720 A           +   'optfbd is ''Filter by '
720 A           +               'department'','
720 M           +   'optdsf is ''Display stop flags '
730 M           +               'before restart'','
730 A           +   'optsor is ''Sort items by '
730 A           +               'compartment'','
730 A           +   'optode is ''Cust on site delivery '
730 A           +               'enable'','
730 A           +   'optodp is ''Cust on site delivery '
730 A           +               'verification period'','
730 A           +   'optont is ''On truck '
730 A           +               'picking'','
730 A           +   'optotp is ''Override truck '
730 A           +               'picking'','
730 A           +   'optnsb is ''No signee button on '
730 A           +               'signature screen'','
740aA           +   'optraxinv is ''Print Trax '
740aA           +               'invoice'','
760aA           +   'optcut is ''Use '
760aA           +               'Cut+Dry'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
