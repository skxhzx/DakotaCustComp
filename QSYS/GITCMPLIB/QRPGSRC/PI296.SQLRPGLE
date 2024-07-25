      /copy qcopysrc,hspecs
     h fixnbr(*ZONED)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II296     FTP - Import PO updates - Convert to Staging
     *  15 July 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes:
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here to change/handle incoming item data.
     *    Do that in the staging version, PI265S. This is to follow
     *    our intent to move everything through Staging going forward.
     *----------------------------------------------------------------
     *
     *  Revisions
     *
700  *   07/15/16  RTR  7.00
     *     - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     fimpfpoh2  if   e           k disk    rename(pihrec: ftppih)
     fimpfpod2  if   e           k disk    rename(pidrec: ftppid)
     fimpspoh   uf a e           k disk    rename(pihrec: stgpih)
     f*                                    prefix(stg_)
     fimpspod   uf a e           k disk    rename(pidrec: stgpid)
     f*                                    prefix(stg_)
     *
     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar
     *
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *
      /copy qcopysrc,c#stdsql
     *
     *----------------------------------------------------------------
     *  Prototypes
     *
     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

     d RunStage        pr                  extpgm('PI265S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const
      * Output
     d   pReturn                     10
     d   pMessage                   200
     *
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
     /free

        // Get first record.
        read ftppih;
        // If records found, create staging batch.
        if %found(impfpoh2);
          batWhse = pihwhs;
          // Get staging batch ID
          exsr zzzGetBatId;
          // Get timestamps
          exsr zzzGetStamps;
        endif;

        exsr writeheader;
        exsr writedetail;

        // Update batch status
        exec sql
          update stgbatch
             set sbstatus = :batstat,
                 sbtext = :battext
           where sbwhse = :batwhse
             and sbbatid = :batid;

        // Run Staging Import
        // RunStage(batWhsea: batId: rtncode: rtnMessage);

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

     *----------------------------------------------------------------
     *  writeheader    Write header records
     *----------------------------------------------------------------
      /free
       begsr writeheader;

        dow not %eof(impfpoh2);

          // Write record to staging file
          pihbatid = batid;
          pihstatus = 'R';
          pihststs = stamp;
          pihstsuc = stampuc;
          pihtext = *blanks;
          pihaddts = stamp;
          pihadduc = stampuc;
          write stgpih;

          read ftppih;

        enddo;

       endsr;  // writeheader
      /end-free

     *----------------------------------------------------------------
     *  writedetail    Write detail records
     *----------------------------------------------------------------
      /free
       begsr writedetail;

        read ftppid;
        dow not %eof(impfpod2);

          // Write record to staging file
          pidbatid = batid;
          pidstatus = 'R';
          pidststs = stamp;
          pidstsuc = stampuc;
          pidtext = *blanks;
          pidaddts = stamp;
          pidadduc = stampuc;
          write stgpid;

          read ftppid;

        enddo;

       endsr;  // writedetail
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'IMPITEM': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr;  // zzzGetBatId
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

       endsr;  // zzzGetStamps
      /end-free
