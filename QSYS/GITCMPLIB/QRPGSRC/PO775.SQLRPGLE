     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PO775     FTP Export Closed P.O. Smartdock Appointments
     *  Rod Roller
     *  27 June 2014
     *
     *----------------------------------------------------------------
     *  Notes
     *  - This program calles the Staging Smartdock Export to generate
     *    the records, then moves them to the FTP member to be sent
     *    via FTP. This is to follow our intent to move everything
     *    through Staging going forward.
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    06/27/14  RTR  6.50a
     *      - Created
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
     D RunStage        pr                  extpgm('PO775S')
      * Input
     D   pWhsea                       3    const
      * Output
     D   pBatId                      11    const
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
     *      iWhse      Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('PO775')
      * Input
     D   iWhsea                       3    const
      * Output
     D   iRtn                         8

     D main            pi
      * Input
     D   iWhsea                       3a   const
      * Output
     D   iRtn                         8a
     *----------------------------------------------------------------

     * Main line
     *
      /free

        // Run Staging Smartdock Export
        RunStage(batWhsea: batId: rtncode: rtnMessage);
        iRtn = rtncode;

        // Check for errors
        if rtncode = '*OK';
          exsr MoveRecs;
        endif;

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
      /free
       begsr *inzsr;

         batWhsea = iWhsea;

       endsr;  // *inzsr
      /end-free

     *----------------------------------------------------------------
     *  MoveRecs      Move records from staging to ftp file
     *----------------------------------------------------------------

      /free
       begsr MoveRecs;

        exec sql
          insert into expfposd
            (select psdapt, psdpo, psdstr, psdstp, char(psdwhs)
               FROM expsposd
              where PSDWHS = :batWhse
                and PSDBATID= :batId
                and PSDSTATUS ='R');

        if sqlstt <> sqlSuccess;
          rtncode = '*ERROR';
          rtnMessage = 'Error converting to FTP in PO775. SQLSTT: '
                       + sqlstt;
          exec sql
            update stgbatch
               set sbstatus = 'E',
                   sbtext   = :rtnMessage,
                   sbststs  = current_timestamp,
                   sbstsuc  = current_timestamp - current_timezone
             where sbwhse   = :batWhse
               and sbbatid  = :batId;
        else;
          exec sql
            update stgbatch
               set sbstatus = 'S',
                   sbtext   = 'Batch converted to FTP records by PO775.',
                   sbststs  = current_timestamp,
                   sbstsuc  = current_timestamp - current_timezone
             where sbwhse   = :batWhse
               and sbbatid  = :batId;
          exec sql
            update expsposd
               set psdstatus = 'S',
                   psdtext   = 'Record moved to FTP export by PO775.',
                   psdststs  = current_timestamp,
                   psdstsuc  = current_timestamp - current_timezone
             where psdwhs    = :batWhse
               and psdbatid  = :batId;
        endif;

       endsr; // MoveRecs
      /end-free
