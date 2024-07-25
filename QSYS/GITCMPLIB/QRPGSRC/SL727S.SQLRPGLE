      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  SL727S    Staging Export - Slot Item Quantities
     *  Rod Roller
     *  20 October 2015
     *
     *----------------------------------------------------------------
     *  Notes
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    10/20/15  RTR  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     *
     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     D RunStage        pr                  extpgm('SL727S')
      * Input
     D   pWhsea                       3    const
     D   pBatId                      11    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Working Variables
     *
     D batId           s             11a
     D batStat         s              1a
     D batText         s            200a
     D cmdexcerr       s              1    inz('0')
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z

     D dsWhse          ds
     D  batWhse                1      3  0
     D  batWhsea               1      3a

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
     *
      /free

        // Default to warehouse 1 for now
        batWhse = 1;

        // Get staging batch ID
        exsr zzzGetBatId;

        // Get timestamps
        exsr zzzGetStamps;

        // Write records to staging file
        exec sql
          insert into expssqty
            select :batwhse, :batid, slwhdp, sldisp, slitem,
                   'R', :stamp, :stampuc, ' ', slentd, slexpd,
                   slstk1+slrcv1-slalc1-sltfr1-slpck1,
                   slstk2+slrcv2-slalc2-sltfr2-slpck2,
                   slstk3+slrcv3-slalc3-sltfr3-slpck3,
                   slpick, slrsrv, :stamp, :stampuc
              from slot order by slwhse, slwhdp, sldisp;

        // Check for errors
        if sqlstt <> sqlSuccess;
          batstat = 'E';
          battext = 'SQL Error reading SLOT records: ' + SQLSTT;
        else;
          batstat = 'R';
          battext = 'Slot Quantity data created.';
        endif;

        // Update batch status
        exec sql
          update stgbatch
             set sbstatus = :batstat,
                 sbtext = :battext
           where sbwhse = :batwhse
             and sbbatid = :batid;

        // We are finished so get out
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   endsr
     *
     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
        begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'EXPCBISQTY': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

        endsr; // zzzGetBatId
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
        begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        endsr; // zzzGetStamps
      /end-free
