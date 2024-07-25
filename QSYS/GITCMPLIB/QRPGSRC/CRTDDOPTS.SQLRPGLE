      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  CRTDDOPTS    Create DDOPTS codes
     *  20 July 2016
     *  Dave Sommerville
     *
     *  Revisions
     *
700a *    07/20/16  DAS  7.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D dorec         E ds                  extname(ddopts) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D  dsplyMsg       s             52
     D  gPart1         s            200

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d WrtRec          pr
     d  val                         200    const

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        gPart1 = 'insert into '
               + 'ddopts (docode, dovalue)';

        // Create options (add new options in alpha order)

        WrtRec('''BFC_AXLE_US'',''ON''');
        WrtRec('''BFC_AXLE_FRAME'',''OFF''');
        WrtRec('''BFC_AXLE_FRAME_HEIGHT'',''10''');
        WrtRec('''BFC_CUBE_HILITE_ZERO'',''OFF''');
        WrtRec('''BFC_CUBE_MAX_HILITE'',''ON''');
        WrtRec('''BFC_CUBE_MIN_HILITE'',''OFF''');
        WrtRec('''BFC_DD_ITEM_SORT'',''ITEM''');
        WrtRec('''BFC_DD_LOGFILE_DIRECTORY'','' ''');
        WrtRec('''BFC_DD_PRINT_ROUTE'',''ON''');
        WrtRec('''BFC_DD_REBUILD_ROUTE'',''OFF''');
        WrtRec('''BFC_DD_TIPS'',''ON''');
        WrtRec('''BFC_DD_TRUCK_PALLETS'',''ON''');
        WrtRec('''BFC_EXPAND_ITEM_SPLITS'',''ON''');
        WrtRec('''BFC_ITEM_DISPLAY_PIECES'',''ON''');
        WrtRec('''BFC_ITEM_DISPLAY_WEIGHT'',''ON''');
        WrtRec('''BFC_ITEM_FLAGS'',''OFF''');
        WrtRec('''BFC_LOADING_SCREEN'',''ON''');
        WrtRec('''BFC_MAX_CUBE_WARNING'',''ON''');
        WrtRec('''BFC_ORIGINAL_OVERFLOW'',''ON''');
        WrtRec('''BFC_PALLET_DISPLAY_PIECES'',''OFF''');
        WrtRec('''BFC_PALLET_FLAGS'',''OFF''');
        WrtRec('''BFC_PRINT_AFTER_DONE'',''OFF''');
        WrtRec('''BFC_PRINT_BYPASS_DIALOG'',''OFF''');
        WrtRec('''BFC_PRINT_COLOR'',''ON''');
        WrtRec('''BFC_PRINT_LAYOUT'',''PORTRAIT''');
        WrtRec('''BFC_PRINT_STYLE'',''ALL''');
        WrtRec('''BFC_SPLIT_ITEM'',''ON''');
        WrtRec('''BFC_STOP_DISPLAY_CUSTOMER_NAME'',''ON''');
        WrtRec('''BFC_STOP_DISPLAY_CUSTOMER_NUMBER'',''ON''');
        WrtRec('''BFC_STOP_DISPLAY_PIECES'',''ON''');
        WrtRec('''BFC_STOP_DISPLAY_WEIGHT'',''ON''');
        WrtRec('''BFC_STOP_FLAGS'',''OFF''');
        WrtRec('''BFC_SUMMARY_FRAME_HEIGHT'',''200''');
        WrtRec('''BFC_USE_OMODSC'',''OFF''');

        return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  WrtRec  Build/Execute SQL statement to write record
     *----------------------------------------------------------------

     p WrtRec          b
     d WrtRec          pi
     d  val                         200    const

      /free

        sqlstmt = %trimr(gPart1) + ' values ('
                + %trim(val)
                +')';

        exec sql execute immediate :sqlstmt;

        if sqlstt <> sqlSuccess;
          if sqlstt <> sqlDupRecd;
            if sqlstt = sqlUndefObject;
              dsplyMsg = 'WrtRec Error ' + sqlstt + ' - File not found';
              dsply dsplyMsg;
            else;
              dsplyMsg = 'WrtRec Error ' + sqlstt + sqlerm;
              dsply dsplyMsg;
            endif;
            dsplyMsg = %subst(sqlstmt:13);
            dsply dsplyMsg;
          endif;
        endif;

        return;

      /end-free

     p WrtRec          e
