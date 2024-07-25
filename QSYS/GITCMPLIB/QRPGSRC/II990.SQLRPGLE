      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II990     Item Import - Validation Report
     *  13 August 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    08/13/15  RTR  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     fpiritem   if   e           k disk    infds(file1ds)

     *----------------------------------------------------------------
     *  File information data structure
      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  *RETURNS -  Customer Returns options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRQCH  -  Allow changes to return quantity. (Y,N).
     *    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
     *    OPRFLB  -  Force return label entry. (Y/N)
     *    OPREXQ  -  Export Quick returns.(Y/N)
     *    OPRULB  -  Use label for putaway.(Y/N)
     *    OPREAD  -  Export as adjustments. (Y/N)
     *    OPREAC  -  Adjustment code to use.
     *
     * Data structure
     *
     D oprdta          ds
     D  oprqch                 1      1
     D  oprqec                 2      2
     D  oprflb                 3      3
     D  oprexq                 4      4
     D  oprulb                 5      5
     D  opread                 6      6
     D  opreac                 7      8
     D  oprend               117    117
     D  oprdata                1    117

     *----------------------------------------------------------------
     *  Working variables

     d msgtext         s           1024a
     d runid           s             10a

     d totalcount      s             10i 0

     d workcount1      s             10i 0
     d workcount2      s             10i 0
     d workcount3      s             10i 0
     d workpct1        s              5s 2
     d workpct2        s              5s 2
     d workpct3        s              5s 2
     d workvalue1      s             10a
     d workvalue2      s             10a
     d workvalue3      s             10a
     d wn1             s              5i 0

     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Prototypes
     *
     D Main            pr                  extpgm('II990')
      * Input
      * Output

     D WrtDebug        pr                  extpgm('WRTDEBUG')
     D   dbPgm                       10    const
     D   dbType                      10    const
     D   dbText                    1024

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        // Use time for run ID key
        runid = %char(#jobtime);

        // File Library
        msgtext = 'Item Analysis for Data Library: ' + f1library;
        WrtDebug(#pgm: runid: msgtext);
        msgtext = '----------------------------------------------------------';
        WrtDebug(#pgm: runid: msgtext);

        // Total Count
        exec sql select count(*) into :totalcount from piritem;
        if sqlstt = sqlsuccess;
          msgtext = '  Total Items in PIRITEM:                   '
                  + %char(totalcount);
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of items - 001';
          WrtDebug(#pgm: runid: msgtext);
        endif;

        exec sql declare cwhse cursor for
             select itwhse, count(*) from piritem
                    group by itwhse;
        exec sql open cwhse;
        exec sql fetch cwhse into :workcount2, :workcount1;
        if sqlstt = sqlsuccess;
          dow sqlstt = sqlsuccess;
            workpct1 = (workcount1 / totalcount) * 100;
            msgtext = '  Warehouse ' + %trim(%char(workcount2))
                    + ':                            '
                    + %char(workcount1) + ' - ' + %char(workpct1) + '%';
            WrtDebug(#pgm: runid: msgtext);
            exec sql fetch cwhse into :workcount2, :workcount1;
          enddo;
        else;
          msgtext = '*** ERROR selecting warehouses - 020';
          WrtDebug(#pgm: runid: msgtext);
        endif;
        exec sql close cwhse;

        msgtext = '----- Departments ----------------------------------------';
        WrtDebug(#pgm: runid: msgtext);
        exec sql declare cwhdp cursor for
             select itwhdp, count(*) from piritem
                    group by itwhdp;
        exec sql open cwhdp;
        exec sql fetch cwhdp into :workvalue1 :wn1, :workcount1;
        if sqlstt = sqlsuccess;
          dow sqlstt = sqlsuccess;
            workpct1 = (workcount1 / totalcount) * 100;
            msgtext = '  Department ' + %trim(workvalue1)
                    + ':                           '
                    + %char(workcount1) + ' - ' + %char(workpct1) + '%';
            WrtDebug(#pgm: runid: msgtext);
            exec sql fetch cwhdp into :workvalue1, :workcount1;
          enddo;
        else;
          msgtext = '*** ERROR selecting departments - 021'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;
        exec sql close cwhdp;

        // Item Type Section
        msgtext = '----- Item Types -----------------------------------------';
        WrtDebug(#pgm: runid: msgtext);

        // Total Count of Normal Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = ' ';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total Normal Items:                       '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of normal items - 002'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of SSB Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = 'S';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total S - Same Slot Breakdown Items:      '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of S items - 003'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of B Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = 'B';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total B - Different Slot Breakdown Items: '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of B items - 004'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of A Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = 'A';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total A - Alias Items:                    '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of A types - 004'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of C Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = 'C';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total C - Contract Items:                 '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of C types - 005'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of R Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype = 'R';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total R - Repack Items:                   '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of R types - 006'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of Other Items
        exec sql select count(*) into :workcount1 from piritem
                  where ittype <> ' ' and ittype <> 'B'
                    and ittype <> 'S' and ittype <> 'A'
                    and ittype <> 'C' and ittype <> 'R';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Total Other - Invalid Types:              '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting total number of other types - 007'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Item Dimension Section
        msgtext = '----- Item Dimensions ------------------------------------';
        WrtDebug(#pgm: runid: msgtext);

        // Total Count of Cubes
        exec sql select count(*) into :workcount1 from piritem
                  where itcube > 0;
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Items with Cube Value:                    '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting cube counts - 011'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Count of Weights
        exec sql select count(*) into :workcount1 from piritem
                  where itswgt > 0;
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Items with Weight Value:                  '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting weight counts - 012'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Total Catchweight Items
        exec sql select count(*) into :workcount1 from piritem
                  where itcwgt = 'Y';
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Catchweight Items:                        '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting catchweight items - 013'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        // Catchweight Items without weight
        exec sql select count(*) into :workcount1 from piritem
                  where itcwgt = 'Y' and itswgt <= 0;
        if sqlstt = sqlsuccess;
          workpct1 = (workcount1 / totalcount) * 100;
          msgtext = '  Catchweight Items missing Weight:         '
                  + %char(workcount1) + ' - ' + %char(workpct1) + '%';
          WrtDebug(#pgm: runid: msgtext);
        else;
          msgtext = '*** ERROR selecting catchweight missing wgt - 014'
                  + ' SQL:' + sqlstt;
          WrtDebug(#pgm: runid: msgtext);
        endif;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   endsr
