     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PI415     Import FTP purchase orders - Multi Whse
     *  Rod Roller
     *  17 June 2014
     *
     *----------------------------------------------------------------
     *  Notes
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here to move the data to the Smartdock or
     *    PO files. Do that in the staging version, PI415S. This is
     *    to follow our intent to move everything through Staging
     *    going forward.
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    06/17/14  RTR  6.50a
     *      - Created
     *
740aA*    03/19/20  JCJ  7.40a
     *      - Recompiled for IMPFPOSD change.
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

     D RunStage        pr                  extpgm('PI415S')
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
          insert into impsposd
            select :batwhse, :batid, 'R', :stamp, :stampuc, ' ',
                   psdapt, psdpo, psdtyp, :stamp, :stampuc
              from impfposd;

        // Check for errors
        if sqlstt <> sqlSuccess;
          batstat = 'E';
          battext = 'FTP Conversion error: ' + SQLSTT;
        else;
          batstat = 'R';
          battext = 'Converted from FTP Import.';
        endif;

        // Update batch status
        exec sql
          update stgbatch
             set sbstatus = :batstat,
                 sbtext = :battext
           where sbwhse = :batwhse
             and sbbatid = :batid;

        // Run Staging Smartdock Import
        RunStage(batWhsea: batId: rtncode: rtnMessage);

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

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId(batWhse: 'IMPPOSD': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

