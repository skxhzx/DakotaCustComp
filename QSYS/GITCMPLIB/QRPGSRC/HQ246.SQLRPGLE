      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  HQ246     Host Item Picked Qty's Adjst - Convert to Staging
     *  29 July 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes:
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here to change/handle incoming item data.
     *    Do that in the staging version, HQ245S. This is to follow
     *    our intent to move everything through Staging going forward.
     *----------------------------------------------------------------
     *
     *  Revisions
     *
700  *   08/29/16  RTR  7.00
     *     - Created
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     fimpfpckq  if   e           k disk    prefix(ftp_)
     fimpspckq  uf a e           k disk    prefix(stg_)
     f                                     rename(ipqrec:stgrec)
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

     d RunStage        pr                  extpgm('HQ245S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const
     d   pType                       10    const
      * Output
     d   pReturn                     10
     d   pMessage                   200
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     d batId           s             11a
     d batText         s            200a   inz('Converted from FTP - HQ246')
     d batType         s             10a   inz('IMPPCKDEM ')
     d havebatid       s               n
     d rtnCode         s             10
     d rtnMessage      s            200
     d stamp           s               z
     d stampUC         s               z

     d dsWhse          ds
     d  batWhse                1      3  0
     d  batWhsea               1      3a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE      Warehouse
     *
     *    Returned Parameters
     *      $PWHSE      Warehouse
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('HQ246')
     d  $pReturn                     10

     d main            pi
     d  $pReturn                     10
     *----------------------------------------------------------------
     * Main line
     /free

        read impfpckq;

        dow not %eof(impfpckq);

          // Get batch id and stamps
          if havebatid = *off;
            exsr zzzGetBatId;                // Get staging batch id
            exsr zzzGetStamps;               // Get timestamps
            if havebatid = *off;
              leave;                         // Get out if no batch id
            endif;
          endif;

          // Write records to staging table
          stg_ipqwhs = ftp_ipqwhs;
          stg_ipqbatid = batid;
          stg_ipqitm = ftp_ipqitm;
          stg_ipqstatus = 'R';
          stg_ipqststs = stamp;
          stg_ipqstsuc = stampuc;
          stg_ipqtext = battext;
          stg_ipqwhd = ftp_ipqwhd;
          stg_ipqdsp = ftp_ipqdsp;
          stg_ipqqp1 = ftp_ipqqp1;
          stg_ipqqp2 = ftp_ipqqp2;
          stg_ipqqp3 = ftp_ipqqp3;
          stg_ipqadj = ftp_ipqadj;
          stg_ipqmem = ftp_ipqmem;
          stg_ipqsof = ftp_ipqsof;
          stg_ipqaddts = stamp;
          stg_ipqadduc = stampuc;
          write stgrec;

          // Next record
          read impfpckq;
        enddo;

        // Update batch status
        if havebatid = *on;
          exec sql
            update stgbatch
               set sbstatus = 'R',
                   sbtext = :batText
             where sbwhse = :batWhse
               and sbbatid = :batId;

          // Run Staging Import
          RunStage(batWhsea: batId: batType: rtncode: rtnMessage);
        else;
          rtncode = '*ERROR   ';
        endif;

        // We are finished so get out
        $pReturn = rtncode;
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

         exec sql select min(ipqwhs) into :batWhse
                    from impfpckq;
         if sqlstt <> sqlsuccess;
           batWhse = 0;
           havebatid = *off;
         endif;

       endsr; // *inzsr
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        havebatid = *on;
        monitor;
          GetBatId(batWhse: batType: 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          havebatid = *off;
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
