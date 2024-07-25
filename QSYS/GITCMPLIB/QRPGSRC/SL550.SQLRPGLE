      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SL550   Create SLOTUSAGE records
     *  30 October 2009
     *  Dave Sommerville
     *
610 A*    10/30/09  DAS  6.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

412 AFslotusage o    e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Slot1 record fields
     *----------------------------------------------------------------

     D baseFlds      E ds                  extname(slot)
     D                                     prefix(base_)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D rptDate         s                   like(slurptdate)
     D rptTime         s                   like(slurpttime)
     D vStat           s                   like(base_slstat)
     D virtStat        s                   like(base_slstat)

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       rptDate = %date();
       rptTime = %time();

       // Remove all existing records from file

       exec sql delete from slotusage;
       if sqlstt <> sqlSuccess;
       endif;

       // Prepare selection SQL statement

       exsr sqlclean1;
       exsr sqlbldstmt1;
       exsr sqlprep1;

       // Create records

       exsr sqlfetch1;

       // Clean up and leave

       exsr sqlclean1;
       exsr sqlclean2;

       // We are finished so get out

       *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  chkVirtuals   Check virtual slots
     *----------------------------------------------------------------

      /free
       begsr chkVirtuals;

         // Start off by setting return status to base slot status
         // which will either be 'Z' or 'V'.

         vStat = base_slstat;

         // Prepare selection SQL statement

         exsr sqlclean2;
         exsr sqlbldstmt2;
         exsr sqlprep2;

         // Check virtual slot status codes

         exsr sqlfetch2;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlBldStmt1   Build SQL statement for slot selection
     *----------------------------------------------------------------

      /free
       begsr sqlBldStmt1;

         sqlStmt = 'select * '
                 + 'from slot '
                 + 'where slrsrv <> ' + sq + 'V' + sq + ' '
                 + 'order by slwhse, slwhdp, slsdef ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlBldStmt2   Build SQL statement for vslot selection
     *----------------------------------------------------------------

      /free
       begsr sqlBldStmt2;

         sqlStmt = 'select slstat '
                 + 'from vslot, slot '
                 + 'where vswhse = ' + %char(base_slwhse) + ' '
                 +   'and vswhdp = '
                 +      sq + %trim(base_slwhdp) + sq + ' '
                 +   'and vspdis = '
                 +      sq + %trim(base_sldisp) + sq + ' '
                 +   'and slwhse = vswhse '
                 +   'and slwhdp = vswhdp '
                 +   'and sldisp = vsdisp '
                 +   'and slstat <> ' + sq + 'V' + sq;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlClean1 - Close cursor 1
     *----------------------------------------------------------------

      /free
       begsr sqlClean1;

         // Close the SQL cursor after all processing is complete.

         exec sql close mycsr1;
         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlClean2 - Close cursor 2
     *----------------------------------------------------------------

      /free
       begsr sqlClean2;

         // Close the SQL cursor after all processing is complete.

         exec sql close mycsr2;
         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep1 - Prepare SQL cursor for slot selection
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlPrep1;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares the cursor.

         exec sql prepare sel1 from :sqlStmt;
         if sqlstt <> sqlSuccess;
         endif;

         // Declare the SQL cursor to hold the data retrieved from the SELECT

         exec sql declare mycsr1 dynamic scroll cursor for sel1;
         if sqlstt <> sqlSuccess;
         endif;

         // Open the SQL cursor.

         exec sql open mycsr1;
         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep2 - Prepare SQL cursor for vslot selection
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlPrep2;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares the cursor.

         exec sql prepare sel2 from :sqlStmt;
         if sqlstt <> sqlSuccess;
         endif;

         // Declare the SQL cursor to hold the data retrieved from the SELECT

         exec sql declare mycsr2 dynamic scroll cursor for sel2;
         if sqlstt <> sqlSuccess;
         endif;

         // Open the SQL cursor.

         exec sql open mycsr2;
         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlFetch1 - Fetch selected slot records
     *----------------------------------------------------------------

      /free
       begsr sqlFetch1;

         sqlFetchCount = 0;

         dow forever = forever;

           // Close the SQL cursor after all processing is complete.

           exec sql fetch next from mycsr1 into :baseFlds;

           if sqlstt <> sqlSuccess;
             leave;
           endif;

           sqlFetchCount += 1;

           if sqlFetchCount = 1;
             clear slurec;
             sluwhse = base_slwhse;
             sluwhdp = base_slwhdp;
             slusdef = base_slsdef;
           endif;

           if base_slwhse <> sluwhse
              or base_slwhdp <> sluwhdp
              or base_slsdef <> slusdef;
             exsr writeRec;
             clear slurec;
             sluwhse = base_slwhse;
             sluwhdp = base_slwhdp;
             slusdef = base_slsdef;
             sqlFetchCount = 1;
           endif;

           // If slot is not Verified, update occupied count.

           if base_slstat <> 'V';
             if base_slpick = 'Y';
               slupckocu += 1;
             else;
               sluovfocu += 1;
             endif;
             iter;
           endif;

           // Otherwise, slot is Verified, so check virtuals.

           exsr chkVirtuals;

           // If any non-Verified virtual slot exist, update occupied count.

           if vStat <> 'V';
             if base_slpick = 'Y';
               slupckocu += 1;
             else;
               sluovfocu += 1;
             endif;
             iter;
           endif;

           // Otherwise, update empty count;

           if base_slpick = 'Y';
             slupckemp += 1;
           else;
             sluovfemp += 1;
           endif;

         enddo;

         if sqlFetchCount > 0;
           exsr writeRec;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlFetch2 - Fetch selected vslot records
     *----------------------------------------------------------------

      /free
       begsr sqlFetch2;

         dow forever = forever;

           // Close the SQL cursor after all processing is complete.

           exec sql fetch next from mycsr2 into :virtStat;

           if sqlstt <> sqlSuccess;
             leave;
           endif;

           // All we need to do is grab the status of the first
           // record because we know it won't be a 'V' status,
           // then leave.

           vStat = virtStat;
           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  writeRec   Write slotusage record
     *----------------------------------------------------------------

      /free
       begsr writeRec;

         // Calculate pick slot percentage within pick slots

         if (slupckemp + slupckocu) > 0;
           slupctpe  = (slupckemp / (slupckemp + slupckocu)) * 100;
           slupctpo  = (slupckocu / (slupckemp + slupckocu)) * 100;
           slupctpo += 100 - (slupctpe + slupctpo);
         endif;

         // Calculate overflow slot percentage within overflow slots

         if (sluovfemp + sluovfocu) > 0;
           slupctoe  = (sluovfemp / (sluovfemp + sluovfocu)) * 100;
           slupctoo  = (sluovfocu / (sluovfemp + sluovfocu)) * 100;
           slupctoo += 100 - (slupctoe + slupctoo);
         endif;

         // Calculate pick slot percentage within slot def

         if (slupckemp + slupckocu + sluovfemp + sluovfocu) > 0;
           slupctsep = (slupckemp /
                       (slupckemp + slupckocu + sluovfemp + sluovfocu)) * 100;
           slupctsop = (slupckocu /
                       (slupckemp + slupckocu + sluovfemp + sluovfocu)) * 100;
         endif;

         // Calculate overflow slot percentage within slot def

         if (slupckemp + slupckocu + sluovfemp + sluovfocu) > 0;
           slupctseo = (sluovfemp /
                       (slupckemp + slupckocu + sluovfemp + sluovfocu)) * 100;
           slupctsoo = (sluovfocu /
                       (slupckemp + slupckocu + sluovfemp + sluovfocu)) * 100;
         endif;

         // Make sure we come out to 100%

         if (slupckemp + slupckocu + sluovfemp + sluovfocu) > 0;
           slupctsoo += 100 - (slupctsep + slupctsop + slupctseo + slupctsoo);
         endif;

         // Update date/time fields

         slurptdate = rptDate;
         slurpttime = rptTime;
         slustamp  = %timestamp();

         write(e) slurec;
         if %error;
         endif;

       endsr;
      /end-free
