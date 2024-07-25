      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSTRAX2  SQL View for OPTIONS *TRAX2
     *  07 March 2018
     *  Retha Davis
     *
     *  Revisions
     *
720 A*    03/07/18  RBD  7.20
     *      - Created.
     *
720aA*    07/02/18  DAS  7.20a
     *      - Added field OPTOSIG.
     *
730 A*    03/13/19  RBD  7.30
     *      - Added several new options.
     *
740a *    09/24/20  GJA  7.40a
     *      - Add OPTSYG for Sygic Truck Intregation
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
                     + 'CALL OPSTRAX2 (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*TRAX2';
        view = 'OPSTRAX2';
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
                +   'optsbu,'
                +   'optsb,'
                +   'optseu,'
                +   'optse,'
                +   'optbbu,'
                +   'optbb,'
                +   'optbeu,'
                +   'optbe,'
                +   'optv12,'
                +   'optv20,'
                +   'optdir,'
                +   'optiu,'
720aA           +   'optosig,'
730 A           +   'optsvl,'
730 A           +   'optssp,'
730 A           +   'optsss,'
730 A           +   'optsst,'
730 A           +   'optmul,'
730 A           +   'optkpl,'
730 A           +   'optshl,'
730 A           +   'optprt,'
730 A           +   'optspk,'
730 A           +   'optgps,'
730 A           +   'optmin,'
730 A           +   'optmet,'
730 A           +   'optpwd,'
730 A           +   'optoff,'
730 A           +   'optaut,'
730 A           +   'optph1,'
730 A           +   'optph2,'
730 A           +   'optcam,'
730 A           +   'optdil,'
740mA           +   'optdip,'
740aA           +   'optsyg'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPTSBU
                +   'substr(opdata,1,1),'
       //                                     2   40OPTSB
                +   'zoned('
                +     'translate(substr(opdata,2,3),''0'','' '')'
                +   ',3,0),'
       //                                     5   5 OPTSEU
                +   'substr(opdata,5,1),'
       //                                     6   80OPTSE
                +   'zoned('
                +     'translate(substr(opdata,6,3),''0'','' '')'
                +   ',3,0),'
       //                                     9   9 OPTBBU
                +   'substr(opdata,9,1),'
       //                                    10  130OPTBB
                +   'zoned('
                +     'translate(substr(opdata,10,4),''0'','' '')'
                +   ',4,0),'
       //                                    14  14 OPTBEU
                +   'substr(opdata,14,1),'
       //                                    15  170OPTBE
                +   'zoned('
                +     'translate(substr(opdata,15,3),''0'','' '')'
                +   ',3,0),'
       //                                    18  18 OPTV12
                +   'substr(opdata,18,1),'
       //                                    19  19 OPTV20
                +   'substr(opdata,19,1),'
       //                                    20  39 OPTDIR
                +   'substr(opdata,20,20),'
       //                                    40  49 OPTIU
                +   'substr(opdata,40,10),'
720a   //                                    50  50 OPTOSIG
720a            +   'substr(opdata,50,1),'
730 A  //                                    51  51 OPTSVL
730 A           +   'substr(opdata,51,1),'
730 A  //                                    52  52 OPTSSP
730 A           +   'substr(opdata,52,1),'
730 A  //                                    53  53 OPTSSS
730 A           +   'substr(opdata,53,1),'
730 A  //                                    54  54 OPTSST
730 A           +   'substr(opdata,54,1),'
730 A  //                                    55  55 OPTMUL
730 A           +   'substr(opdata,55,1),'
730 A  //                                    56  56 OPTKPL
730 A           +   'substr(opdata,56,1),'
730 A  //                                    57  57 OPTSHL
730 A           +   'substr(opdata,57,1),'
730 A  //                                    58  58 OPTPRT
730 A           +   'substr(opdata,58,1),'
730 A  //                                    59  59 OPTSPK
730 A           +   'substr(opdata,59,1),'
730 A  //                                    60  60 OPTGPS
730 A           +   'substr(opdata,60,1),'
730 A  //                                    61  630OPTMIN
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,61,3),''0'','' '')'
730 A           +   ',3,0),'
730 A  //                                    64  690OPTMET
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,64,6),''0'','' '')'
730 A           +   ',6,0),'
730 A  //                                    70  89 OPTPWD
730 A           +   'substr(opdata,70,20),'
730 A  //                                    90  910OPTOFF
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,90,2),''0'','' '')'
730 A           +   ',2,0),'
730 A  //                                    92  92 OPTAUT
730 A           +   'substr(opdata,92,1),'
730 A  //                                    93 1020OPTPH1
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,93,10),''0'','' '')'
730 A           +   ',10,0),'
730 A  //                                   103 1120OPTPH2
730 A           +   'zoned('
730 A           +     'translate(substr(opdata,103,10),''0'','' '')'
730 A           +   ',10,0),'
730 A  //                                   113 113 OPTCAM
730 A           +   'substr(opdata,113,1),'
730 A  //                                   114 114 OPTDIL
730 A           +   'substr(opdata,114,1),'
730 A  //                                   115 115 OPTDIP
740MA           +   'substr(opdata,115,1),'
740aA  //                                   116 116 OPTsyg
740aA           +   'substr(opdata,116,1)'
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
                +   'optsbu is ''Use sys susp batt '
                +               'power timeout'','
                +   'optsb  is ''Sys susp batt '
                +               'power timeout'','
                +   'optseu is ''Use sys susp ext '
                +               'power timeout'','
                +   'optse  is ''Sys susp ext '
                +               'power timeout'','
                +   'optbbu is ''Use bklit off batt '
                +               'power timeout'','
                +   'optbb  is ''Bklit off batt '
                +               'power timeout'','
                +   'optbeu is ''Use bklit off ext '
                +               'power timeout'','
                +   'optbe  is ''Bklit off ext '
                +               'power timeout'','
                +   'optv12 is ''Create V1.2 '
                +               'xml'','
                +   'optv20 is ''Create V2.0 '
                +               'xml'','
                +   'optdir is ''IFS main '
                +               'directory'','
                +   'optiu  is ''IFS '
                +               'user'','
720aA           +   'optosig is ''Cust ord '
720aA           +               'sig'','
730 A           +   'optsvl is ''Save login '
730 A           +               'info'','
730 A           +   'optssp is ''Send stop '
730 A           +               'pictures enable'','
730 A           +   'optsss is ''Send stop '
730 A           +               'sigs enable'','
730 A           +   'optsst is ''Send stop Trax '
730 A           +               'log enable'','
730 A           +   'optmul is ''Multi route '
730 A           +               'enable'','
730 A           +   'optkpl is ''Keep log '
730 A           +               'info'','
730 A           +   'optshl is ''Show log '
730 A           +               'info'','
730 A           +   'optprt is ''Enable '
730 A           +               'printer'','
730 A           +   'optspk is ''Enable '
730 A           +               'speak'','
730 A           +   'optgps is ''Enable '
730 A           +               'GPS'','
730 A           +   'optmin is ''GPS period '
730 A           +               'minutes'','
730 A           +   'optmet is ''GPS distance '
730 A           +               'meters'','
730 A           +   'optpwd is ''Admin '
730 A           +               'password'','
730 A           +   'optoff is ''Admin password '
730 A           +               'encryption offset'','
730 A           +   'optaut is ''App auto '
730 A           +               'update'','
730 A           +   'optph1 is ''Company '
730 A           +               'phone'','
730 A           +   'optph2 is ''Dispatch phone '
730 A           +               'for texting'','
730 A           +   'optcam is ''Camera barcode '
730 A           +               'scanner'','
730 A           +   'optdil is ''Disable driver id '
730 A           +               'login validation'','
730 A           +   'optdip is ''Disable driver pwd '
740mA           +               'login validation'','
740aA           +   'optsyg is ''Enable Sygic Truck '
740aA           +               'integration'''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
