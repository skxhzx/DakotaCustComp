500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OI287     FTP Orders V4 - Convert to Staging
     *  Rod Roller
     *  October 22, 2018
     *
     *----------------------------------------------------------------
     *  Notes
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here to move the data staging files. Do
     *    that in the staging import program. This is following our
     *    intent to move everything through Staging going forward.
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    10/22/18  RTR  7.20
     *      - Created.
     *
     *----------------------------------------------------------------
     fimpfordh4 if   e           k disk    prefix(ftph_)
     f                                     rename(oihrec: ftphdr)
     fimpfordd4 if   e           k disk    prefix(ftpd_)
     f                                     rename(oidrec: ftpdtl)
     fimpsordh  o  a e           k disk    prefix(stgh_)
     f                                     rename(oihrec: stghdr)
     fimpsordd  o  a e           k disk    prefix(stgd_)
     f                                     rename(oidrec: stgdtl)
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

     d RunStage        pr                  extpgm('OI285S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const
      * Output
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *      pWhsea     Warehouse
     *      pReturn    Return Code
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('OI287')
      * Input
      * Output
     d   pWhsea                       3
     d   pReturn                      8

     d main            pi
      * Input
      * Output
     d   pWhsea                       3
     d   pReturn                      8

     *----------------------------------------------------------------
     *  Working Variables
     *
     d batId           s             11a
     d batStat         s              1a
     d batText         s            200a
     d cmdexcerr       s              1    inz('0')
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
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

        exsr LoadHeader;

        if havebatid = *on;
          exsr LoadDetail;

          // Update STGBATCH record
          exec sql update stgbatch
               set sbstatus = 'R',
                   sbtext = :batText
             where sbwhse = :batWhse
               and sbbatid = :batId;

          // Run Staging Import
          RunStage(batWhsea: batId: rtncode: rtnMessage);
        else;
          preturn = '*ERROR   ';
        endif;

        // We are finished so get out
        pWhsea = batWhsea;
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

         exec sql select min(oihwhs) into :batWhse
                    from impfordh;
         if sqlstt <> sqlsuccess;
           batWhse = 0;
         endif;
         batWhsea = %editc(batWhse:'X');
         havebatid = *off;

       endsr; // *inzsr
      /end-free

     *----------------------------------------------------------------
     *  LoadHeader     Write header records to staging
     *----------------------------------------------------------------
      /free
       begsr LoadHeader;

        read impfordh4;

        dow not %eof(impfordh4);
          // Get batch id and stamps
          if havebatid = *off;
            batWhse = ftph_oihwhs;
            exsr zzzGetBatId;                // Get staging batch id
            exsr zzzGetStamps;               // Get timestamps
            if havebatid = *off;
              leavesr;
            endif;
          endif;

          // Write records to staging table
          stgh_oihwhs = ftph_oihwhs;
          stgh_oihbatid = batid;
          stgh_oihrteid = *blanks;
          stgh_oihordid = 0;
          stgh_oihstatus = 'R';
          stgh_oihststs = stamp;
          stgh_oihstsuc = stampuc;
          stgh_oihtext = battext;
          stgh_oihord = ftph_oihord;
          stgh_oihtyp = ftph_oihtyp;
          stgh_oihcus = ftph_oihcus;
          stgh_oihcpo = ftph_oihcpo;
          stgh_oihcnm = ftph_oihcnm;
          stgh_oihca1 = ftph_oihca1;
          stgh_oihca2 = ftph_oihca2;
          stgh_oihcct = ftph_oihcct;
          stgh_oihcst = ftph_oihcst;
          stgh_oihczp = ftph_oihczp;
          stgh_oihrte = ftph_oihrte;
          stgh_oihstp = 0;
          stgh_oihtrk = ftph_oihtrk;
          stgh_oihmsc = ftph_oihmsc;
          stgh_oihest = ftph_oihest;
          stgh_ohmms1 = *blanks;
          stgh_ohmms2 = *blanks;
          stgh_ohmms3 = *blanks;
          stgh_ohmms4 = *blanks;
          stgh_ohmms5 = *blanks;
          stgh_oihaddts = stamp;
          stgh_oihadduc = stampuc;
          write stghdr;

          // Next record
          read impfordh4;
        enddo;

       endsr; // LoadHeader;
      /end-free

     *----------------------------------------------------------------
     *  LoadDetail     Write detail records to staging
     *----------------------------------------------------------------
      /free
       begsr LoadDetail;

        read impfordd4;

        dow not %eof(impfordd4);

          // Write records to staging table
          stgd_oidwhs = stgh_oihwhs;
          stgd_oidbatid = batid;
          stgd_oidordid = 0;
          stgd_oidstatus = 'R';
          stgd_oidststs = stamp;
          stgd_oidstsuc = stampuc;
          stgd_oidtext = battext;
          stgd_oidord = ftpd_oidord;
          stgd_oidseq = ftpd_oidseq;
          stgd_oiditm = ftpd_oiditm;
          stgd_oidq1 = ftpd_oidq1;
          stgd_oidq2 = ftpd_oidq2;
          stgd_oidq3 = ftpd_oidq3;
          stgd_oidwh2 = ftpd_oidwh2;
          stgd_oidor2 = ftpd_oidor2;
          stgd_oidoit = ftpd_oidoit;
          stgd_oidspc = ftpd_oidspc;
          stgd_oidpo  = ftpd_oidpo;
          stgd_oimdsc = *blanks;
          stgd_oimpds = *blanks;
          stgd_oimrds = *blanks;
          stgd_oimbox = *blanks;
          stgd_oimexp = *blanks;
          stgd_oimms1 = *blanks;
          stgd_oimms2 = *blanks;
          stgd_oimms3 = *blanks;
          stgd_oimms4 = *blanks;
          stgd_oimms5 = *blanks;
          stgd_oidslt = *blanks;
          stgd_oidblk = *blanks;
          stgd_oidaddts = stamp;
          stgd_oidadduc = stampuc;
          write stgdtl;

          // Next record
          read impfordd4;
        enddo;

       endsr; // LoadDetail;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        havebatid = *on;
        monitor;
          GetBatId(batWhse: 'IMPROUTE': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
          havebatid = *off;
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

