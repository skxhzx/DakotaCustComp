      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPSPROD  SQL View for OPTIONS *PROD
     *  09 May 2014
     *  Kenneth Elder
     *
     *  Revisions
     *
640 A*    05/09/14  KDE  6.50
     *      - Created.
640 A*    03/26/15  KDE  6.50
     *      - Added option to generate Breakdown Replenishment
640 A*    04/29/15  KDE  7.00
     *      - Added Box Breaker options
700aA*    12/28/16  LMC  7.00a
     *      - Added Allocate against Cust. Order Pck Aisle from PLINED
     *      - Added Create production work orders for qty
     *        Allocated against Cust. Order Pck Aisle.
710 A*    09/22/15  KDE  7.10
     *      - Added Standard Only option for Production Costing
730 A*    02/20/19  KDE  7.30
     *      - Added options for Use Costing and Generate replenishments
     *        component items as becoming available
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
                     + 'CALL OPSPROD (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'OPTIONS';
        code = '*PROD';
        view = 'OPSPROD';
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
                +   'oplbrp,'
                +   'oplbdl,'
                +   'opvarm,'
                +   'opimpgtin,'
                +   'opgengtin,'
                +   'opprddte,'
                +   'oppckdte,'
                +   'opexpdte,'
                +   'opnetlbs,'
                +   'oplbsdec,'
                +   'opnetkg,'
                +   'opkgdec,'
                +   'oprepln,'
                +   'optyprp,'
                +   'oppro,'
                +   'opgs1,'
                +   'opbrkr,'
700 A           +   'opbxbu,'
700 A           +   'opbxbp,'
700aD           //+   'opbxbs'
700aM           +   'opbxbs,'
700aA           +   'opalccopa,'
700aA           +   'opcrtwo,'
710 A           +   'opstdonly,'
730 A           +   'opusecost,'
730 A           +   'opcmprepln'
                + ') '
                + 'as ('
                + 'select '
                +   'opwhse,'
       //                                     1   1 OPLBRP
                +   'substr(opdata,1,1),'
       //                                     2   2 OPLBDL
                +   'substr(opdata,2,1),'
       //                                     3   3 OPVARM
                +   'substr(opdata,3,1),'
       //                                     4   4 OPIMPGTIN
                +   'substr(opdata,4,1),'
       //                                     5   5 OPGENGTIN
                +   'substr(opdata,5,1),'
       //                                     6   6 OPPRDDTE
                +   'substr(opdata,6,1),'
       //                                     7   7 OPPCKDTE
                +   'substr(opdata,7,1),'
       //                                     8   8 OPEXPDTE
                +   'substr(opdata,8,1),'
       //                                     9   9 OPNETLBS
                +   'substr(opdata,9,1),'
       //                                    10  10 OPLBSDEC
                +   'zoned('
                +     'translate(substr(opdata,10,1),''0'','' '')'
                +   ',1,0),'
       //                                    11  11 OPNETKG
                +   'substr(opdata,11,1),'
       //                                    12  12 OPKGDEC
                +   'zoned('
                +     'translate(substr(opdata,12,1),''0'','' '')'
                +   ',1,0),'
       //                                    13  13 OPREPLN
                +   'substr(opdata,13,1),'
       //                                    14  20 OPTYPRP
                +   'substr(opdata,14,7),'
       //                                    21  21 OPPRO
                +   'substr(opdata,21,1),'
       //                                    22  22 OPGS1
                +   'substr(opdata,22,1),'
       //                                    23  23 OPBRKR
                +   'substr(opdata,23,1),'
700 A  //                                    24  24 OPBXBU
700 A           +   'substr(opdata,24,1),'
700 A  //                                    25  25 OPBXBP
700 A           +   'substr(opdata,25,1),'
700 A  //                                    26  26 OPBXBS
700aD           //+   'substr(opdata,26,1)'
700aM           +   'substr(opdata,26,1),'
700aA  //                                    27  27 OPALCCOPA
700aA           +   'substr(opdata,27,1),'
700aA  //                                    28  28 OPCRTWO
700aA           +   'substr(opdata,28,1),'
710 A  //                                    29  29 OPSTDONLY
710 A           +   'substr(opdata,29,1),'
730 A  //                                    30  30 OPUSECOST
730 A           +   'substr(opdata,30,1),'
730 A  //                                    31  31 OPCMPREPLN
730 A           +   'substr(opdata,31,1)'
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
                + 'field view - 6.50''';

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
                +   'oplbrp is ''Allow label '
                +               'Reprint'','
                +   'oplbdl is ''Allow label '
                +               'delete'','
                +   'opvarm is ''Variable '
                +               'measure'','
                +   'opimpgtin is ''Import '
                +               'GTIN Xref'','
                +   'opgengtin is ''Generate GTIN '
                +               'on the fly'','
                +   'opprddte is ''Include Production '
                +               'date in GS1'','
                +   'oppckdte is ''Include Package '
                +               'date in GS1'','
                +   'opexpdte is ''Include Expiration '
                +               'date in GS1'','
                +   'opnetlbs is ''Include Net '
                +               'pounds in GS1'','
                +   'oplbsdec is ''Number of decimals '
                +               'for Net pounds'','
                +   'opnetkg is ''Include Net KG '
                +               'in GS1'','
                +   'opkgdec is ''Number of decimals '
                +               'for Net KG'','
                +   'oprepln is ''Automated Replenis'
                +               'hments'','
                +   'optyprp is ''Type of automated '
                +               'Replenishments'','
                +   'oppro   is ''Produce '
                +               'Configuation'','
                +   'opgs1   is ''GS1 '
                +               'Replenishments'','
                +   'opbrkr  is ''Allow Breakdown '
                +               'Replenishments'','
                +   'opbxbu  is ''Use Box Breaker '
                +               ' '','
                +   'opbxbp  is ''Box Break at '
                +               'Pick Slot'','
                +   'opbxbs  is ''Box Breaker uses '
700aD           //+               'system gen lic'''
70OaM           +               'system gen lic'','
700aA           +   'opalccopa  is ''Allocate against    '
700aA           +               'Cust. Order Pick '
700aA           +               'Aisle'','
700aA           +   'opcrtwo  is ''Create Prod WO for  '
700aA           +                'qty allocated '
700aA           +               'Cust. Order Pick Aisle'','
730 A           +   'opstdonly is ''Std Cost Only '
730 A           +               ' '','
730 A           +   'opusecost is ''Use Std Cost '
730 A           +               ' '','
730 A           +   'opcmprepln is ''Generate CMP '
730 A           +               'Replen '''
                + ')';

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
