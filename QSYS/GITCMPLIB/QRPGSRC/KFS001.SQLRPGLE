      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  KFS001    KFS - Create PRC Room adjustments
     *  Rod Roller
     *  February 7, 2019
     *
     *----------------------------------------------------------------
     *  Notes
     *  - This is a custom program for Kelly's Foods to create
     *    adjustments in IMPSPCKQ for PRC-100-1 slots to zero the qty.
     *    Kelly's converts all PRC qty daily to other items which are
     *    then received on POS.
     *----------------------------------------------------------------
     *  Revisions
     *
730  *    02/07/19  RTR  7.30
     *      - Created.
     *
     *----------------------------------------------------------------
     fslot2     if   e           k disk
     fimpspckq  uf a e           k disk
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Prototypes
     d kfs001          pr                  extpgm('KFS001')
      * Input
     d   pWhsea                       3    const
     d kfs001          pi
      * Input
     d   pWhsea                       3    const

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

        // Read records
        setll (batWhse: 'REF': 'PRC-100-1') slot2;
        read slot2;

        dow not %eof(slot2);

          // end when past PRC-100-1 slots
          if %subst(sldisp:1:9) <> 'PRC-100-1';
            leave;
          endif;

          // read next record if status not active
          if slstat <> 'A';
            iter;
          endif;

          // Get batch id and stamps
          if havebatid = *off;
            exsr zzzGetBatId;                // Get staging batch id
            exsr zzzGetStamps;               // Get timestamps
            if havebatid = *off;
              leave;                         // Get out if no batch id
            endif;
          endif;

          // Write record to staging table
          exsr zzFill;
          write ipqrec;

          // Next record
          read slot2;
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
          RunStage(batWhsea: batId: 'IMPPCKDEM': rtncode: rtnMessage);
        else;
          rtncode = '*ERROR   ';
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

         monitor;
           batwhsea = pWhsea;
         on-error;
           batwhse = 1;
         endmon;

       endsr; // *inzsr
      /end-free

     *----------------------------------------------------------------
     *  zzFill         Fill Fields
     *----------------------------------------------------------------
      /free
        begsr zzFill;

          ipqwhs    = slwhse;
          ipqbatid  = batid;
          ipqitm    = slitem;
          ipqstatus = 'R';
          ipqststs  = stamp;
          ipqstsuc  = stampuc;
          ipqtext   = *blanks;
          ipqwhd    = slwhdp;
          ipqdsp    = sldisp;
          ipqqp1    = slstk1;
          ipqqp2    = slstk2;
          ipqqp3    = slstk3;
          ipqadj    = 'R1';
          ipqmem    = 'Processing Room Adj';
          ipqsof    = 'N';
          ipqaddts  = stamp;
          ipqadduc  = stampuc;

        endsr; // zzFill;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
        begsr zzzGetBatId;

        havebatid = *on;
        monitor;
          GetBatId(batWhse: 'IMPPCKDEM': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
          havebatid = *off;
        endmon;

        endsr; // zzzGetBatid
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

        endsr; // zzzGetStamps;
      /end-free

