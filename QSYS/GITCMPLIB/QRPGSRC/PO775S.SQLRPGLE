      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PO775S    Stage Export - P.O. Smartdock Appointments
     *  24 June 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    06/24/14  RTR  6.50a
     *      - Created.
650b *    08/28/14  RTR  6.50b
     *      - Change to only send one record for appointment when all
     *        POs for that appointment have been received, using the
     *        earliest start time and latest end time for appointment.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fexpsposd  uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *
     D smartdock     e ds                  extname(smartdock) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Working variables
     *
     D batId           s             11a
     D batStat         s              1a
     D batText         s            200a
650bAD cnt             s             10i 0
     D haveBatId       s               n
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stamploval      s               z
     D stampUC         s               z
650bAD workapt         s             11a

     D dsWhse          ds
     D  batWhse                1      3  0
     D  batWhsea               1      3a

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

     *----------------------------------------------------------------
     *  Parameters
     *
     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        exsr ProcRecs;

        if haveBatId;
          $pBatId = batid;
          $pReturn = '*OK';
          $pMessage = 'Smartdock export batch created.';
          exsr zzzEnd;
        else;
          $pBatId = *blanks;
650bD   //$pReturn = '*ERROR';
650bD   //$pMessage = 'Batch not created.';
650bM     $pReturn = '*EMPTY';
650bM     $pMessage = 'No records found.';
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
      /free
       begsr *inzsr;

         batWhsea = $pWhse3a;
         haveBatId = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ProcRecs       Process Records
     *----------------------------------------------------------------
      /free
       begsr ProcRecs;

650bD  //   select * from smartdock
        exec Sql
          declare recs cursor for
650bM       select distinct smdapp from smartdock
            where smdwhs = :batwhse
              and smdstp <> ' '
              and smdexpts = :stamploval;

        exec sql open recs;
        if sqlstt <> sqlSuccess;
          leavesr;
        endif;

        dow forever = forever;

          exec sql fetch next from recs
650bM              into :workapt;
650bD         //   into :smartdock;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

650bA     // check for POs still not received, if any, skip.
650bA     cnt = 0;
650bA     exec sql select count(*) into :cnt
650bA                from smartdock
650bA               where smdwhs = :batwhse
650bA                 and smdapp = :workapt
650bA                 and smdstp = ' ';
650bA
650bA     if sqlstt <> sqlSuccess
650bA      or cnt <> 0;
650bA       iter;
650bA     endif;
650bA
650bA     // get min/max times for appointment.
650bA     exec sql select min(smdstr), max(smdstp)
650bA                into :smdstr, :smdstp
650bA                from smartdock
650bA               where smdwhs = :batwhse
650bA                 and smdapp = :workapt;
650bA
650bA     if sqlstt <> sqlSuccess;
650bA       iter;
650bA     endif;

          // If first time, get batch id. If error, get out.
          if not haveBatId;
            exsr zzzGetBatId;
            if batId = *blanks;
              leave;
            endif;
            haveBatId = *on;
          endif;

          exsr zzzGetStamps;

          // Write staging record
650bD  // psdwhs = smdwhs;
650bM     psdwhs = batwhse;
          psdbatid = batId;
          psdstatus = 'R';
          psdtext = 'Ready for export';
650bD  // psdpo = smdpo;
650bM     psdpo = *blanks;
650bD  // psdapt = smdapp;
650bM     psdapt = workapt;
          psdstr = smdstr;
          psdstp = smdstp;
          psdaddts = stamp;
          psdadduc = stampUC;
          write psdrec;

          exec sql update smartdock
                      set smdexpts = :stamp
650bM               where smdapp = :workapt;
650bD  //           where current of recs;

        enddo;

        exec sql close recs;

       endsr;   // ProcRecs
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'EXPPOSD': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr;
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

        stamploval = *loval;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :batWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*ERROR';
          $pMessage = 'Unable to update batch record.';
        endif;

       endsr;   // zzzEnd
      /end-free
