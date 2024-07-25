      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT976     Item Quantity Compare Report - Convert to Staging
     *  January 2, 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes:
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here to change/handle incoming item data.
     *    Do that in the staging version, IT981S. This is to follow
     *    our intent to move everything through Staging going forward.
     *----------------------------------------------------------------
     *
     *  Revisions
     *
720  *   01/02/19  RTR  7.20
     *     - Created
720a *   01/02/19  RTR  7.20a
     *     - Enh: If using Aspen multi-whse, convert item numbers.
750  *   02/25/22  KDE  7.50
     *     - Enh: Correct mod 7.20a to only turn on flag aspenwhse
     *       when system is ASPEN warehouse
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     fimpfcqty  if   e           k disk    prefix(ftp_)
     fimpscqty  uf a e           k disk    prefix(stg_)
     f                                     rename(icrec:stgrec)
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

     d RunStage        pr                  extpgm('IT981S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const

750 AD getClient       pr                  extpgm('GETCLIENT')
750 Ad   iclientid                   10
750 Ad   iclientloc                  10
750 Ad   iclientinit                  3
750 Ad   ihostsys                    10
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
750 Dd*AspenWhse       s               n   inz('1')
750 Md AspenWhse       s               n   inz('0')
     d batId           s             11a
     d batText         s            200a   inz('Converted from FTP - IT976')
     d batType         s             10a   inz('IMPCOMPQTY')
     d havebatid       s               n
750 Ad pClientid       s             10
750 Ad pClientloc      s             10
750 Ad phostsys        s             10
750 Ad pClientinit     s              3
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
     d main            pr                  extpgm('IT976')
     d  $pReturn                     10

     d main            pi
     d  $pReturn                     10
     *----------------------------------------------------------------
     * Main line
     /free

        read impfcqty;

        dow not %eof(impfcqty);

          // Get batch id and stamps
          if havebatid = *off;
            exsr zzzGetBatId;                // Get staging batch id
            exsr zzzGetStamps;               // Get timestamps
            if havebatid = *off;
              leave;                         // Get out if no batch id
            endif;
          endif;

          // Write records to staging table
720aA     select;
720aA       when AspenWhse;
720aA         stg_icitem = %trim(ftp_icitem) + '-'
720aA                    + %subst(%editc(ftp_icwhse:'X'):2:2);
720aA         stg_icwhse = 1;
720aA       other;
              stg_icitem = ftp_icitem;
              stg_icwhse = ftp_icwhse;
720aA     endsl;
          stg_icbatid = batid;
          stg_icstatus = 'R';
          stg_icststs = stamp;
          stg_icstsuc = stampuc;
          stg_ictext = battext;
          stg_ictqh1 = ftp_ictqh1;
          stg_ictqh2 = ftp_ictqh2;
          stg_ictqh3 = ftp_ictqh3;
          stg_icbrnd = *blanks;
          stg_icaddts = stamp;
          stg_icadduc = stampuc;
          stg_iclcns = *blanks;
          write stgrec;

          // Next record
          read impfcqty;
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
          RunStage(batWhsea: batId);
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

         exec sql select min(icwhse) into :batWhse
                    from impfcqty;
         if sqlstt <> sqlsuccess;
           batWhse = 0;
           havebatid = *off;
         endif;

         // get host system
750 A    pclientid=*blanks;
750 A    pclientloc=*blanks;
750 A    pclientinit=*blanks;
750 A    phostsys=*blanks;

750 A    getclient (pclientid:pclientloc:pclientinit:phostsys);
         if phostsys = 'ASPEN';
           aspenwhse = '1';
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
