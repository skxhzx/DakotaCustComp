      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PI415S    Stage Import - Purchase orders
     *  18 June 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    06/18/14  RTR  6.50a
     *      - Created using bits of PI265S.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there are only P.O.'s for one
     *    warehouse in the member.
     *
     *----------------------------------------------------------------
     * File Specs
     Fimpsposd  uf   e           k disk
     Fsmartdock uf a e           k disk
     *
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     D importError     s               n
     D sbstatus        s              1a
     D sbtext          s            200a
     D stamp           s               z
     D stampUC         s               z

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

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
     *
      /free

         // Update stgbatch record to start process
         exsr zzzStart;
         if $pReturn <> '*OK';
           return;
         endif;

         // Whip through all the download header records
         setll ($pwhse:$pBatId) impsposd;
         dow forever = forever;

           reade ($pwhse:$pBatId) impsposd;
           if %eof(impsposd);
             leave;
           endif;

           // Skip processed records.
           if psdstatus <> 'R';
             iter;
           endif;

           exsr zzzGetStamps;
           psdststs = stamp;
           psdstsuc = stampuc;

           // Only process 'Add' record types
           if psdtyp <> 'A';
           //psdstatus = 'E';
           //psdtext = 'SKIPPED - Record type not Add.';
           //update psdrec;
           //iter;
           endif;

           // Check for existing PO
           chain (psdwhs:psdpo) smartdock;

           if %found(smartdock);
             // If exists, log error in staging record
             importError = *on;
             psdstatus = 'E';
             psdtext = 'SKIPPED - Appointment already exists for PO.';
             update psdrec;

           else;
             // If not exists, write to SMARTDOCK
             clear smdrec;
             smdwhs = psdwhs;
             smdpo  = psdpo;
             smdapp = psdapt;
             smdstr = *blanks;
             smdstp = *blanks;
             clear smdexpts;
             write smdrec;
             // mark staging record processed
             psdstatus = 'S';
             psdtext = 'Appointment added for PO in SMARTDOCK file.';
             update psdrec;
           endif;

         enddo;

         // We are finished so leave
         exsr zzzEnd;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

         $pWhse = %dec($pWhse3A: 3: 0);
         $pReturn = '*OK';
         $pMessage = ' ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). '
                   + 'See IMPSPOSD file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- PI415S/zzzend';
          leavesr;
        endif;

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzStart   Start processing
     *----------------------------------------------------------------
      /free
       begsr zzzStart;

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- PI415S/zzzstart';
          leavesr;
        endif;

        importError = *off;
        *inlr = *on;

       endsr;
      /end-free
